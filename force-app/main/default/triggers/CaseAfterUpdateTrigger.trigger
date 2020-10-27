/*******************************************************************************
 * File:  CaseAfterUpdateTrigger
 * Date:  November 8, 2013
 * Author:  Joseph Hutchins
 * Sandbox: Mibos
 * The use, disclosure, reproduction, modification, transfer, or transmittal of
 * this work for any purpose in any form or by any means without the written 
 * permission of United Parcel Service is strictly prohibited.
 *
 * Confidential, unpublished property of United Parcel Service.
 * Use and distribution limited solely to authorized personnel.
 *
 * Copyright 2009, UPS Logistics Technologies, Inc.  All rights reserved.
 *
 * Purpose: 
 *   Trigger fired on Cases.
 *******************************************************************************/
trigger CaseAfterUpdateTrigger on Case (after update)
{
     /*BypassTriggerUtility u = new BypassTriggerUtility();  
     if (u.isTriggerBypassed()) {
         return;
     }
     
    util.debug('case after update trigger called. num queries: ' + util.queriesUsed);
    Recordtype[] caseRecordTypes = null;
    
    private boolean isSendingEmailsDisabled
    {
        get
        {
            Send_Trigger_Email_Alerts__c testObject = Send_Trigger_Email_Alerts__c.getInstance('Roadnet');
            if (testObject == null)
            {
                return true;
            }
            return testObject.isDisabled__c;
        }
    }
    private id supportCaseRecordtypeId
    {
        get
        {
            if (caseRecordTypes == null)
            {
                caseRecordTypes = [select id, name from RecordType where sobjecttype = 'Case'];
            }
            for (RecordType rt : caseRecordTypes)
            {
                if (rt.name == 'Support')
                {
                    return rt.id;
                }
            }
            return null;
        }
    }
    
    if (!MigrationUser.isMigrationUser() && !CaseEventExtension.isUserInternalAutomation())   
    {        
        if (CheckRecursiveAfter.runOnce())
        {
            if (Trigger.isAfter && Trigger.isUpdate)
            {
                CaseServices.autoJIRACallout(Trigger.newMap);
                
                createCaseTimesAfterTrigger(Trigger.new);
                
                try
                {
                    //  while testing, noticed that the update trigger is called on a case insert, to prevent this from being called twice
                    //  we will check if the case after insert trigger change the hasRunBeforeBool
                    util.debug('making check that if custom sharing rules have already been run on insert. CaseShareForVarRoadnet.hasRunBefore: ' + CaseShareForVarRoadnet.hasRunBefore);
                    if (!CaseShareForVarRoadnet.hasRunBefore)
                    {
                        
                        CaseShareForVarRoadnet singleObject = new CaseShareForVarRoadnet();
                        singleObject.CreateCustomSharingForVars(Trigger.new);
                        CaseShareForVarRoadnet.hasRunBefore = true;
                        //handleRoadnetCustomSharingForVars(Trigger.new);
                        
                    }
                }
                catch(Exception e)
                {
                    util.debug('ERROR: ' + e.getMessage());
                }
                
                if (!isSendingEmailsDisabled)
                {
                    handleCaseSubscriberEmailAlerts();
                }
                
                for (integer i = 0; i < Trigger.new.size(); i++)
                {
                    
                    Case newCase = Trigger.new[i];
                    Case oldCase = Trigger.oldMap.get(newCase.Id);
                    
                    /* this scnerio described below will no longer happen as the email 2 cse is handled differently
                    //  this is l;ogic copied from the case class.  esstenailtyh the idea is when an email2case is created
                    //  it can come in with no contact/account.  the tech then edits the case and assigns a 
                    //  account to the case.  we want the internal email alert to go out here when the accountid is set on case edit
                    //  be advised that when i built this, john said if it was easy to do then do it but if not dont worry about it
                    this code snippet also needs to move to a method, this is for when a cases account changes
                    if (oldCase.Accountid == null && oldCase.accountid != newCase.accountid)
                    {
                        //  this handles the sitution in which an email2case came into the system with no accountid.  a tech then edits the case
                        //  and assigns an accountid.  if so, we send the internal email alert that the case has been created for everyone signed up at  the case
                        CaseEventExtension.emailAlertSuppportCaseCreation(newCase);   
                    }
                    */
                    //  lets do owner change and then subject, change,  they should both use the same method
                    /*if ( (newCase.Email_Alert_Support__c != null) && 
                        (oldCase.OwnerId != newCase.OwnerId) || (oldCase.Subject != newCase.Subject) && newCase.isEmail2Case__c != 'True' )
                    {
                        //  what happens here?  we need to know if the owner has changed or the subject has changed
                        //  we need to email to all people signed up ot the case
                        //  and send out email stating that the field has changed
                        boolean didOwnerChange = (oldCase.OwnerId != newCase.OwnerId);
                        util.debug('sendEmailAlertNotfyingFieldsHaveChanged method should be getting called....');
                        //CaseEventExtension.sendEmailAlertNotfyingFieldsHaveChanged(didOwnerChange, oldCase, newCase);
                    }
                   
                    //  this code manages the domestic survey trigger:
                    boolean didCaseStatusChangeToClosed = (oldCase.status != newCase.status) &&
                        (newCase.status == 'Closed');
                
                    if ( didCaseStatusChangeToClosed )
                    {
                        //  we introduced a new fucntion for cases where you can convert a case to an upgrade opportunity
                        //  those cases are autoclosed by the code... however we do not wantthe standard "cae is closed" email to go out
                        //  john has a template that is informtin the customer what's happening so we wnat to send that email instead   
                        if (newCase.Is_Case_Being_Upgraded__c && newCase.recordtypeid == retrieveRecordType('Call Center'))
                        {
                            sendUpgradeCaseClosureEmail(newCase);
                        } 
                       
                                                                         
                                                                                    
                        //  BE ADVISEDD code was here to send the survey,i have removed that as i dont know what surveys are going to do in mibos
                        
                        //  looks for any cases that may point to this one and closes them
                        //  code change added 12/18/2014 to prevent engieering cases from being closed
                        util.debug('case has been closed.  here is the recordtypeid bool: ' + (newCase.RecordTypeId == retrieveRecordType('Call Center')));
                        if (newCase.RecordTypeId == retrieveRecordType('Call Center'))
                        {
                            closeChildCases(newCase);
                            
                        }
                    }
                }
            }
            
        }
        util.debug('case after update trigger finished running. queries used: ' + util.queriesUsed);
    }
    
        //  this is the new method created april 2015
    private void createCaseTimesAfterTrigger(List<Case> cases)
    {
        util.debug(' createCaseTimesAfterTrigger method called...');
        
        //  scratch the below, since i had to query the events without blarg
        //  need to query the cases again so we can get the list of case events that belong to the case for it's assiting tech field
        /*List<Case> casesRequeired = [select id, work_effort_in_minutes__c, last_case_event__c, AssistingTech__c
            from Case 
            where id in: cases ];
        */
        
        //  i tried to query the case events along with the cases but the query was not working so doing that query ehre:
        /*List<Case_Event__c> eventsOfCases = [select id, name, Assisting_Technician__c, case__c, time_spent__c from case_event__c where 
            case__c in: cases 
            order by lastmodifieddate desc, case__c  limit 10000];
        
        util.debug('finished querying case events by themselves, value outputted in for loop ');
        for (Case_Event__c ce : eventsOfCases)
        {
            util.debug('ce.name = ' + ce.name + ' time spent: ' + ce.Time_Spent__c);
        }
        
        //  so... this should get called for two reasons: 1-case was edited/update 2-case event was inserted/updated
        //  the case event insertion/update updates the case.work_effort_in_minutes__c field and then this is supposed to create
        //  case times for that case event.  
        
        //  to kiss, all case recordtypes we will create case times, changes can be made in uat testing
        List<Mibos_Case_Time__c> caseTimesToCreate = new List<Mibos_Case_Time__c>();
        for (Case c : cases)
        {
            util.debug('scrolling thru case now.  here it is: ' + c);
            
            if (!Util.zeroOrNull(c.Work_Effort_In_Minutes__c))
            {
                util.debug('last case event: ' + c.last_case_event__c);
                
                if (c.Last_Case_Event__c != null)//  this means this was called by case event insertion/update, need to create case times for the event
                {
                    MIbos_Case_Time__c caseTimeForCaseEvent = new Mibos_Case_time__c();
                    caseTimeForCaseEvent.Case__c = c.id;
                    
                    Case_Event__c lastCaseEventOfCase = findCaseEvent(c.Last_Case_Event__c, eventsOfCases);
                    util.debug('value of lastCaseEventOfCase: ' + lastCaseEventofCase);
                    
                    if (lastCaseEventOfCase != null)
                    {
                        caseTimeForCaseEvent.Case_Event__c = lastCaseEventOfCase.Id;
                        caseTimeForCaseEvent.Owner__c = userInfo.getUserId();

                        caseTimeForCaseEvent.work_effort__c = lastCaseEventOfCase.time_spent__c;//  this should be the same as the case's work effort in minutes
                        
                        util.debug('case time for case event is being added to the list...');
                        
                        //  add it to the list of case times to create only if we were able to find the case event
                        caseTimesToCreate.add(caseTimeForCaseEvent);
                        
                        util.debug('lastCaseEventOfCase.Assisting_Technician__c : ' + lastCaseEventOfCase.Assisting_Technician__c);
                        
                        if (lastCaseEventOfCase.Assisting_Technician__c != null)//  need to also create a case time for the case event's assiting tech
                        {
                            Mibos_Case_Time__c caseTimeForCaseEventAssistTech = new Mibos_Case_Time__c();
                            caseTimeForCaseEventAssistTech.Case__c = lastCaseEventOfCase.Case__c;//  same as c.id
                            caseTimeForCaseEventAssistTech.Owner__c = lastCaseEventOfCase.Assisting_Technician__c;
                            caseTimeForCaseEventAssistTech.Case_Event__c = lastCaseEventOfCase.id;
                            
                            
                            caseTimeForCaseEventAssistTech.work_effort__c = lastCaseEventofcase.time_spent__c;
                            caseTimeForCaseEventAssistTech.is_Assistant_Tech__c = true;
                            util.debug('case tiem for case events assiting tech being added to the list...');
                            caseTimesToCreate.add(caseTimeForCaseEventAssistTech);
                        }
                        
                    }
                }
                else //  no case event caused the case to update, its a simple case update
                {
                    Mibos_Case_Time__c caseTimeForCase = new Mibos_Case_Time__c();
                    caseTimeForCase.Case__c = c.id;
                    caseTimeForCase.Owner__c = userInfo.getUserId();
                    
                    caseTimeForCase.Work_Effort__c = c.work_effort_in_minutes__c;
                    
                    caseTimesToCreate.add(caseTimeForCase);
                    
                    //  this should only create case  times if the code that called this, was not due to a case event update
                    if (c.AssistingTech__c != null)
                    {
                        //  that way all we have to do is cursor thru the ids and assign a different one to the owner field
                        Mibos_Case_Time__c assistantTechCaseTime = new Mibos_Case_Time__c();
                        assistantTechCaseTime.Case__c = c.id;
                        assistantTechCaseTime.Owner__c = c.AssistingTech__c;
                        assistantTechCaseTime.is_Assistant_Tech__c = true;
                        
                        assistantTechCaseTime.Work_Effort__c = c.work_effort_in_minutes__c;
                        caseTimesToCreate.add(assistantTechCaseTime);
                    }
                }
            }
        }
        
        util.debug('about to update the case times.  num in the list: ' + (caseTimesToCreate == null ? 0 : caseTimesToCreate.size()));
        if (caseTimesToCreate.size() > 0)
        {
            insert caseTimesToCreate;
        }
    }
    private void handleCaseSubscriberEmailAlerts()
    {
        //  this sends email alert to users in the case.email_alert_support field and the case's account.email_alert_support and the account owner
        //  if the case.account.email_alert_all_cases is set
        List<Case> casesBeingClosed = new List<Case>();
        
        for (integer i = 0; i < Trigger.new.size(); i++)
        {
            if (Trigger.new[i].Business_unit__c == 'Roadnet')
            {
                if (Trigger.Old[i].status != Trigger.new[i].status && 
                    Trigger.new[i].status == 'Closed' && 
                    isCaseSupport(Trigger.new[i].RecordtypeId))
                {
                    //  case is being closed, we are sending emails for that case
                    casesBeingClosed.Add(Trigger.new[i]);
                }
            }
        }
        if (casesBeingClosed.size() > 0)
        {
            CaseEventExtension.emailAlertSuppportCaseCreation(casesBeingClosed, 'Case Closure');
        }
    }
    private Case_Event__c findCaseEvent(id caseEventId, List<Case_Event__c> caseEvents)
    {
        for (Case_Event__c ce : caseEvents)
        {
            if (ce.id == caseEventId)
            {
                return ce;
            }
        }
        return null;
    }
    
    private boolean isCaseSupport(string recordtypeId)
    {
        //  we so far have 4 different suppprt recordtypes, support, rescue pin support, call center, and engineering case
        return recordTypeId == retrieveRecordType('Call Center') || 
           recordTypeId == retrieveRecordType('Rescue Pin Support') || 
           recordTypeId == retrieveRecordType('Support') ||
           recordTypeId == retrieveRecordType('Engineering Case');
           
    }
    

    private void sendUpgradeCaseClosureEmail(Case c)
    {
        util.debug('upgrade email sent.');
        id orgWideEmail;
        if (Util.isRnEnvironment)
        {
            orgWideEmail = '0D230000000007l';//  pulled from the domestic support Survey Type  https://na1.salesforce.com/a0X30000001ao3m   i think its rts-support
        }
        else if (Util.isMibosEnvironment)
        {
            orgWideEmail = '0D2W0000000CbVi';
        }
        EmailTemplate et = [select id, name from EmailTemplate where name = 'Upgrade Request' ];
        
        if (et != null)
        {
            
            EmailClassRoadnet.EmailTemplateEx etx = new EmailClassRoadnet.EmailTemplateEx();
            etx.whatId = c.id;
            etx.targetId = c.contactId;
            etx.templateId = et.id;
            etx.orgwideEmailAddress = orgWideEmail;
            etx.saveAsActivity = true;
            EmailClassRoadnet.sendEmailsWithTemplate(new list<EmailClassRoadnet.EmailTemplateEx>{etx});
        }
        
    }
   private void closeChildCases(Case theCase)
    {
        util.debug('closeChildAccounts called');
        
        Case[] childCases;
        try
        {
            //  only try to close call center cases
            childCases = 
                [select id, status,Substatus__c, parentid, ownerid from case where 
                    parentid =: theCase.id and 
                    Status != 'Closed' and 
                    recordtype.name = 'Call Center'];
             if (childCases != null)
             {
                util.debug('num of child cases queried: ' + childCases.size());
             }
             else
             {
                util.debug('no child cases queried');
             }
             
        }
        catch(Exception e)
        {
            util.debug('when trying to query child cases, exception occured: ' + e.getMessage());
        }
        
        List<Case> casesToUpdate = new List<Case>();
        
        if (childCases != null)
        {
            //  also there is logic that prevents a case from being closed if it is in a queue... then we dont want to close it
            //  validatoin rule here: https://omnitracs.my.salesforce.com/03d500000008hJ9?setupid=CaseValidations
            
            for (Case c : childCases)
            {
                string caseOwnerId = c.OwnerId;//  so i can use the begins with method
                
                util.debug('childCase.ownerid = ' + caseOwnerId);
                
                if (caseOwnerId != null && !caseOwnerId.startsWith('00G'))//  cannot close cases belonging to queue
                {
                    c.Status = 'Closed';
                    c.Substatus__c = theCase.Substatus__c;
                    
                    casesToUpdate.add(c);
                }
            }
            if (casesToUpdate.size() > 0)
            {
                try
                {
                    util.debug('attempting to update child cases now...');
                    update casesToUpdate;
                }
                catch(Exception e)
                {
                    util.debug('While attempting to closed child cases for case ' + theCase.CaseNumber + ' error occured due to: ' + e.getMessage());
                    throw new CaseTriggerException('While attempting to closed child cases for case ' + theCase.CaseNumber + ' error occured due to: ' + e.getMessage());
                }
            }
            else
            {
                util.debug('no cases to update');
            }
        }
        
    }


    private Id retrieveRecordType(string recordTypeName)
    {
        if (caseRecordTypes == null)
        {
            caseRecordTypes = [select id, name from RecordType where sobjecttype = 'Case'];
        }
        
        for (RecordType rt : caseRecordTypes)
        {
            if (rt.name == recordTypeName)
            {
                return rt.id;
            }
        }
        
        return null;//  default is to return nothing here
    }
/* no longer need this code, but dont want to remove yet just in case new logic doesnt work
    private void handleRoadnetCustomSharingForVars(list<Case> casesToCheck)
    {
        util.debug('handleRoadnetCustomSharingForVars method called.  num cases in trigger: ' + (casesToCheck == null ? 0 : casesToCheck.size()) );
        
        List<CaseShare> caseSharingRulesToCreate = new List<CaseShare>();
        
        List<Case> roadnetCases = new List<Case>();
        Set<id> accountIds = new Set<Id>();
        //  for each case passed into the trigger, need to requery them, we can filter down the cases that need to be queried by looking at those
        for (Case c : casesToCheck)
        {
            //  whose primray business unit = roadnet
            if (c.Business_Unit__c != null && c.Business_Unit__c == 'Roadnet')
            {
                roadnetCases.add(c);
                if (c.AccountId != null && !accountIds.Contains(c.accountId))
                {
                    accountIds.add(c.accountId);
                }
            }
        }
        util.debug('found ' + (roadnetCases == null ? 0 : roadnetCases.size()) + ' roadnet cases');
        
        if (roadnetCases != null && roadnetCases.size() > 0)
        {
            //  requery the cases for the account owner, and the account's parent account's owner
            Case[] casesRequeried = new List<Case>();
            casesRequeried = [select id, accountid, contactid, contact.name, contact.account.name, contact.account.ownerid, account.account_classification__c, account.var_account1__c, account.name, account.parentid, 
                account.ownerid from case where id =: roadnetCases];
            util.debug('cases have been requried....');
            
            //  then for each of those cases, check if the account owner OR the parent account's owner is a var,
            for (Case c : casesRequeried)
            {
                //  the logic for this has chaned, we now have a text field on the user record called
                // Var name, so all we need to do is query the case.account.owner.var_name__c to find out who the var is of the sub var
                //  actually there is a little problem with this... the account owner is STILL going to be Brian Callahan
                //  so we can't use the account owner.  i am noticing that my testing shows that the contact of these var cases
                //  is the actual person creating trhe case so i am wondering if i can use that?  or i will have to use the old
                //  logic of querying all partner users, then query their contacts, then looking for whichever one points 
                //  to the account, and then guess which of the three are the actual sub var... i am going to go with the contact
                // method and we;ll see if that causes any issue
                util.debug('determing if the case.account is a sub var, and if can find partner user');
                boolean isCaseSubVar = isCaseAccountSubVar(c);
                // we also need to make sure that the contact of the case is a partner user
                boolean isCaseContactAPartnerUser = determineIfCaseContactIsPartnerUser(c);  
                
                //  we now need to query the partner user record for the cases contactid
                User partnerUserRecordOfCase = findPartnerUser(c.contactid);
                util.debug('isCaseSubVar (not checking this any longer) = ' + isCaseSubVar + ' is case contact a partner user: ' + isCaseContactAPartnerUser + ' case contactid: ' + c.contactid + ' case contact.name: ' + c.Contact.Name + 
                    ' case.account.name: ' + c.Account.Name + 'partnerUserRecordOfCase.name = ' + partnerUserRecordOfCase.name + 
                    ' partnerUserRecordOfCase.Var_Name__c: ' + partnerUserRecordOfCase.Var_Name__c);
                
                
                if (
                    //isCaseSubVar && 
                    isCaseContactAPartnerUser &&
                    partnerUserRecordOfCase != null) 
                {
                    util.debug('about to grab the var user record that is assoicated with this subvar: ' + c.contact.name);
                    
                    //  query the var of the sub var
                    User varOfSubVar = findVar(partnerUserRecordOfCase.var_name__c);
                    util.debug('var should have been found: ' + varOfSubVar);
                    
                    //  TODO Add sharing logic here
                    if (varOfSubVar != null)
                    {
                        util.debug('creating the case share');
                        CaseShare varCaseShare = new CaseShare();
                        varCaseShare.CaseId = c.id;
                        varCaseShare.UserOrGroupId = varOfSubVar.id;
                        varCaseShare.CaseAccessLevel = 'edit';
                        
                        caseSharingRulesToCreate.Add(varCaseShare);
                        
                    }
                }
             
            }
            util.debug('about to insert the case shares...');
            
            if (caseSharingRulesToCreate.size() > 0)
            {
                Database.SaveResult[] saveResults = database.insert(caseSharingRulesToCreate, false);
                for (database.saveResult sr : saveResults)
                {
                    if (!sr.isSuccess())
                    {
                         Database.Error err = sr.getErrors()[0];
         
                         // Check if the error is related to trival access level.
                         // Access levels equal or more permissive than the object's default 
                         // access level are not allowed. 
                         // These sharing records are not required and thus an insert exception is acceptable. 
                         if(err.getStatusCode() == StatusCode.FIELD_FILTER_VALIDATION_EXCEPTION  &&  
                                  err.getMessage().contains('AccessLevel'))
                            {
                                util.debug('found expected error code, case sharing rule successul');
                            }
                            else
                            {
                                util.debug('error occured: ' + err.getMessage());
                            }
                            
                    }
                }
                util.debug('case shares should have been created if there are no error messages here');
            }
        }
        
    }
    
    private boolean isCaseAccountSubVar(Case c)
    {
       //  lets get a little deeper into the logic here
       //  we need to idenfity if the account is a var or sub var
       //  if it is var, we need to find who the "partner" user/owner of the account... is that information available
       //  at the user record... it is, if the user.contact is set, we can lookup to the account
       //  so it sounds like we need to query all partner users who point to the cases account
       //  this should be only one person, if more than one person is found we have an issue
       //  now lets iron out the sub var piece
       //  i think the logic is the same here, query all roadn partners that point to the account's var account
       return c.AccountId != null && 
           (c.Account.Account_Classification__c == 'Sub-VAR');
       
       
    }
    
    private User findVar(string varName)
    {
        //User[] theVars = 
        //   [select id, name, contactid  from User where name =: varName and profile.name like '%Roadnet Partner%' and isactive = true order by lastmodifieddate desc];
        //  we should already have a list of vars in this trigger's context, we just need to scroll thru and find the one with the name that is passed in
        List<User> possibleVars = new List<user>();
        
        for (User singleUser : allRoadnetPartnerUsers)
        {
            if (singleUser.name == varName)
            {
                possibleVars.add(singleUser);
            }
        }
        if (possibleVars != null && possibleVars.size() > 0)
        {
            return possibleVars[0];
        }       
        else
        {
            util.debug('could not find partner active var user with name: ' + varName);
            return null;
        }
    }
    private User findPartnerUser(id contactId)
    {
        for (User singleUser : allRoadnetPartnerUsers)
        {
            if (singleUser.contactid == contactId)
            {
                return singleUser;
            }
        }
        return null;
    }
    
    private boolean determineIfCaseContactIsPartnerUser(Case theCase)
    {
        //  if the case.contactid points to a user.contactid in the partner user list, its a var
        for (User singleUser : allRoadnetPartnerUsers)
        {
            if (singleUser.contactId == theCase.contactid)
            {
                return true;
            }
        }
        return false;
    }
    
    private class CaseTriggerException extends Exception{}
    private class myException extends Exception{}*/
}