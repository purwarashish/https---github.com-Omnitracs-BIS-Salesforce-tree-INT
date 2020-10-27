/*******************************************************************************
 * File:  EmailMessageTrigger.trigger
 * Date:  October 12th, 2008
 * Author:  Joseph Hutchins
 * Sandbox:  Mibos
 * The use, disclosure, reproduction, modification, transfer, or transmittal of
 * this work for any purpose in any form or by any means without the written 
 * permission of United Parcel Service is strictly prohibited.
 *
 * Confidential, unpublished property of United Parcel Service.
 * Use and distribution limited solely to authorized personnel.
 *
 * Copyright 2009, UPS Logistics Technologies, Inc.  All rights reserved.
 *
 * Purpose:  This is used in conjuction with the CaseEventTrigger.  This will create a case event at a case whenveer a customer replies to an 
 * an email sent to them from a case.  The case event will be prefaced with the text "Created Via EmailTrigger" to let the CaseEventTrigger konw
 * that the case event was created via code.  The CaseEventTrigger will have code to check for this check and prevent sending out an email to the customer
 * that says the case event was created.
 *  *******************************************************************************/
trigger EmailMessageTrigger on EmailMessage (after insert)
{
	BypassTriggerUtility u = new BypassTriggerUtility();  
    if (u.isTriggerBypassed()) {
        return;
    }
	
    if (Trigger.isAfter && Trigger.isInsert)
    {
        util.debug('email message triger called');
        
        EmailMessage[] emails = Trigger.New;
		EmailMessageUtils.processTermination(emails);
             
        for (EmailMessage em : emails)
        {
            if ( (em.subject != null && em.Subject.contains('ref:_')) ||
                 (em.TextBody != null && em.TextBody.contains('ref:_')) )//  meaning the email is assoicated with a case
            {
                //  we want to try to query the case, if we can't then nothing happens, if we can, 
                //  we want to create a case event assoicated with that case event
                util.debug('about to query record to see if it is a case assoicated with the email');
                Case caseOfEmail;
                try
                {
                    caseOfEmail =[select id, casenumber, business_unit__c, subject, description, suppliedemail, status, 
                      OwnerId, owner.name, Owner.email,Account.name, Recordtype.name, RecordTypeId from Case where id =: em.ParentId];
                    util.debug('case was queried. owner name of case = ' + caseOfEmail.Owner.name);
                }
                catch(Exception e)
                {
                }
                
                if (caseOfEmail != null) 
                {
                    util.debug('email is tied to a case.  that case should be call center and business unit of roadnet...');
                    //  declare case event here, since the email is tied to a case, per case no.01810775, a cae event should always be created for email
                    //  message, i broke this by only having the case event get created when if the case is a roadnet casew
                    
                    //  this code creates a case event "shadow copying" the email record as a case event
                        Case_Event__c ce = new Case_Event__c();
                        ce.Case__c = em.ParentId;
                    
                    //  Zach asked if cases are not reopened or updated if an auto reply email comes in
                    //  this code checks if the email is a reply to a close cased email and will query and reopen the case automatically
                    if (em.incoming &&
                        isValidRecordTypeForReopening(caseOfEmail.RecordType.Name) &&  //  only roadnet call center cases should get reopened from email
                        isValidBusinessUnitForReopening(caseOfEmail.Business_Unit__c) &&
                      !CaseEventExtension.checkEmailSubjectForForbiddenText(em.subject) &&
                        (em.subject.Contains('has been closed.') || caseOfEmail.Status == 'Closed'))
                    {
                       
                        ce.Case__c = em.ParentId;
                        //  the csae event subject can only hold 255 chars so if its larger than that we need to truncate
                        string caseEventSubject = 'Created Via EmailTrigger. Case RE-OPENED due to customer reply to Close Case Email Alert.' + 'Email Subject: ' + em.Subject;
                        if (caseEventSubject.length() > 255)
                        {
                            caseEventSubject = CaseEventExtension.truncateString(caseEventSubject, 255);
                        }
                        ce.Subject__c = caseEventSubject;
                        ce.Details__c = em.Textbody;
                        ce.Communication_Type__c = 'Email';
                        
                        //  just like in the else statmetnt below, we need to insert the case event before updating the case
                        insert ce;
                        
                        caseOfEmail.status = 'RE-OPENED';
                        update caseOfEmail;
                    }
                    else
                    {
                        string caseEventSubject;
                        
                        //  john changed mind and said if the email is coming from customer then we still want to create a case time of 5 min 
                        if (em.Incoming)//  mail is coming from customer
                        {
                          caseEventSubject = 'Email From Customer. Subject: ' + em.Subject;
                          
                          ce.Time_Spent__c = 5;
                          //  so we have new logic here from sf issue # 0003307, if the customer is replying to an email sent from us
                          //  and their case status = 'Awaiting Cusotmer/Awaiting Customer Response' then update the case status to open
                          //  we'd need to update the case BEFORE creating the case event... because the case event trigger insert updates the cases
                          //  last case event field and i believe if you try to update the same record in the same transaction you get an exception
                          if (caseOfEmail.Status == 'Awaiting Customer Response' || caseOfEmail.status == 'Awaiting Customer')
                          {
                                caseOfEmail.status = 'Open';//  case update occurs later below                                
                          }
                        }
                        else//  email came from us
                        {
                            
                            caseEventSubject = 'Email Sent to Customer From ' + userInfo.getFirstName() +  ' ' + UserInfo.getLastName() + '.  ' +
                                'Subject: ' + 
                                em.subject; 
                            //  John asked if we send an email from a case then we'd want the time spent on the case to incrmenet by 5 minute
                            ce.Time_Spent__c = 5;
                        }
                        //  we need to insert the case event before updating the case, resaon being, we are depeniding on the case event 
                        //  after trigger to create the case time, which the case before update trigger will query to update the case total work effort
                                                    
                        //  the case event subject can only hold 255 chars so if its larger than that we need to truncate
                        if (caseEventSubject.length() > 255)
                        {
                            caseEventSubject = CaseEventExtension.truncateString(caseEventSubject, 255);
                        }
                        ce.Subject__c = caseEventSubject;
                        ce.Details__c = em.Textbody;
                        ce.Communication_Type__c = 'Email';
                        Util.debug('inserting case event now');
                        
                        DataBase.saveResult sr = dataBase.insert(ce);
                        
                        //  so here the email is tied to a case, at the very miniumum, we need to update teh case, even if we aren't chaning
                        //  any fields as this will update the case's last moded date
                        try
                        {
                            update caseOfEmail;
                        }
                        catch(Exception e)
                        {
                            util.debug('EXCEPTION: when trying to update the case tied to emailMessage: ' + e.getMessage());
                        }
                        /*
                        // scratch the statement below, john said regardsless if the email is being sent or incoming, it should add 5 minutes of acvity
                        //  <scratch thru>after case event is inserted and created, create a case time record of 5 minutes (if we are the one sending the email)</scratch thru>  
                        if ( sr.isSuccess())
                        {
                            util.debug('case event created successfully');
                            
                            //  so we have an issue in the UAT sandbox that is cuasing case times to be created for email2case cases that
                            //  are email generated cases.  we want to supress the case time createion for this type of case event
                            boolean isCaseEmailGenerated = caseOfEmail.RecordTypeId != null && caseOfEmail.RecordType.Name == 'Email Generated Cases';
                            //boolean isCaseOwnerEmailAgent = caseOfEmail.OwnerId != null && caseOfEmail.Owner.name != null && caseOfEmail.Owner.Name == 'Email Agent';
                            
                            util.debug('isCaseEmailGenerated = ' + isCaseEmailGenerated);
                            //  this means the email is coming from a standard close case page, "send notification email" and we do NOT want to create case times for it
                            if (ce.Subject__c != null && 
                                !ce.Subject__c.contains('has been closed') &&
                                !isCaseEmailGenerated)
                            {
                                // case event trigger handles this now
                                //CaseEventExtension.createCaseTimesForCaseEvent(ce, caseOfEmail);
                            }
                        }
                        */
                        
                    }

                }
            }
        }
    }
    private boolean isValidRecordTypeForReopening(string caseRecordTypeName)
    {
        //  get list of record type names in the custom setting  
        Map<String, Case_Reopen_Recordtypes__c> reopenRecordTypes = Case_Reopen_Recordtypes__c.getAll();
        //  get the keys, they contain the record type names like Admin or Call Center
        set<string> validRecordTypeNames = reopenRecordTypes.KeySet();
        
        if (validRecordTypeNames == null)
        {
            return false;// by default, return falst
        }
        
        for (string singleRecordTypeName : validRecordTypeNames)
        {
            if (singleRecordTypeName == caseRecordTypeName)
            {
                return true;
            }
        }
        return false;
    }
    
    private boolean isValidBusinessUnitForReopening(string caseBusinessUnitName)
    {
        Map<String, Case_Reopen_BusinessUnits__c> reopenBUs = Case_Reopen_BusinessUnits__c.getAll();
        set<string> validBusinessUnitNames = reopenBUs.keySet();
        if (validBusinessUnitNames == null)
        {
            return false;
        }
        
        for (string bu : validBusinessUnitNames)
        {
            if (bu == caseBusinessUnitName)
            {
                return true;
            }
        }
        
        return false;
    }

    public class myException extends Exception{}  
}