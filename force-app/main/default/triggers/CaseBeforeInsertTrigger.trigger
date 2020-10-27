/*******************************************************************************
 * File:  CaseBeforeInsertTrigger
 * Date:  November 8, 2013
 * Author:  Joseph Hutchins
 * Sandbox:  RN
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
 *******************************************************************************
//  RN SANDBOX
trigger CaseBeforeInsertTrigger on Case (before insert)
{
    List<RALL_Product_Family__c> productFamilies;
    List<RecordType> caseRecordTypes;
    
    private id rtsProductfFamilyId
    {
        get
        {
            
            if (productFamilies == null)
            {
                productFamilies = [select id, name from RALL_Product_Family__c];
            }
            for (RALL_Product_Family__c pf : productFamilies)
            {
                if (pf.name == 'Roadnet Transportation Suite')
                {
                    return pf.id;
                }
            }
            return null;
        }
    }
    
    private id rnaProductFamilyId
    {
        get
        {
            if (productFamilies == null)
            {
                productFamilies = [select id, name from RALL_Product_Family__c];
            }
            for (RALL_Product_Family__c pf : productFamilies)
            {
                if (pf.Name == 'Roadnet Anywhere')
                {
                    return pf.id;
                }
            }
            return null;
        }
    }
    private id telematicsProductFamilyId
    {
        get
        {
            if (productFamilies == null)
            {
                productFamilies = [select id, name from RALL_Product_Family__c];
            }
            for (RALL_Product_Family__c pf : productFamilies)
            {
                if (pf.Name == 'RN Telematics')
                {
                    return pf.id;
                }
            }
            return null;
        }
    }
    private id m_mobileCastProductId;
    private id mobileCastProductId
    {
        get
        {
            if (m_mobileCastProductId == null)
            {
                m_mobileCastProductId = [select id from Product2 where name = 'MC Server' limit 1].id;
            }
            return m_mobileCastProductId;
        }
    }
    private id m_javaRegisId;
    private id javaRegisId
    {
        get
        {
            if (m_javaRegisId == null)
            {
                m_javaRegisId = [select id from Case_Reason__c where name = 'MC Mmgt Center Registration' limit 1].id;
            }
            return m_javaRegisId;
        }
    }
    private id m_strategicSupportQueueId;
    private id strategicSupportQueueId
    {
        get
        {
            if (m_strategicSupportQueueId == null)
            {
              m_strategicSupportQueueid = [select queueid from QueueSobject where queue.name = 'Strategic Support' and SobjectType = 'Case'].queueId;
            }
            return m_strategicSupportQueueId;
        }
    }
     
    private id supportRecordTypeId
    {
        get
        {
            if (caseRecordTypes == null)
            {
              caseRecordTypes = [select id, name from RecordType where sobjecttype = 'Case'];
            }
            for (RecordType rt : caseRecordTypes)
            {
                if (rt.Name == 'Support')
                {
                    return rt.Id;
                }
            }
            return null;
        }
    }
    
    private id m_changeRequestCaseReasonId;
    private id changeRequestCaseReasonId
    {
        get
        {
            if (m_changeRequestCaseReasonId == null)
            {
                m_changeRequestCaseReasonId = [select id from Case_Reason__c where name = 'Change Request' limit 1].id;
            }
            return m_changeRequestCaseReasonId;
        }
         
    }
    private id m_defectSubReasonId;
    private id defectSubReasonId
    {
        get
        {
            if (m_defectSubReasonId == null)
            {
                //  there are two sub reasons, we want the one tied to change request
                m_defectSubReasonId = [select id from Sub_Reason__c where name = 'Defect' and Case_Reason__r.Name = 'Change Request' limit 1].id;
            }
            return defectSubReasonId;
        }   
    }
    //  record type does exist in the sandbox now and it matches the live
    //  since the record tpe doesnt exist in the live yet, the sandbox and live wil have differnet values so we need to query directly
    private id rescuePinRecordTypeId
    {
        get
        {
            if (caseRecordTypes == null)
            {
                caseRecordTypes = [select id, name from RecordType where sobjecttype = 'Case'];
            }
            for (RecordType rt : caseRecordTypes)
            {
                if (rt.name == 'Rescue Pin Support')
                {
                    return rt.id;
                }
            }
            return null;
            
        }
    }
// Start - Added by Ravi Gandhi to Bypass based on user 
     BypassTriggerUtility u = new BypassTriggerUtility();  
     if (u.isTriggerBypassed()) {
         return;
     }
// End Added by Ravi Gandhi to Bypass based on user 
    
    if (!MigrationUser.isMigrationUser() && !CaseClassHelperClass.isUserInternalAutomation())   
    {
        if (Trigger.isBefore && Trigger.isInsert)
        {
            //  placing this outside of the for loop as it saves on queries (the method queries all prodcut families, and reasons we dont want the query
            //  to get called every time a case is processed
            CaseClassHelperClass.assignValuesToLookupFields(Trigger.New);
            
            for (integer i = 0; i < Trigger.New.size(); i++)
            {
                trigger.new[i].total_work_effort__c = roundNearest5Minutes(trigger.new[i].Work_Effort_In_Minutes__c);
                if (Trigger.New[i].Recordtypeid == rescuePinRecordTypeId)
                {
                    //  null this out so that when the user goes to edit the support case, they are forced to pick value
                    Trigger.New[i].Work_Effort_In_Minutes__c = null;
                    Trigger.New[i].RecordtypeId = supportRecordTypeId;
                }
                if (Trigger.New[i].AccountId != null &&
                    (Trigger.New[i].RecordtypeId == supportRecordTypeId || Trigger.new[i].recordtypeid == rescuePinRecordTypeId))
                {
                    //  if its a domestic cusotmer with no products prevent the case from opening
                    if (isAccountDomesticAndContainsNoProductsOrActive(trigger.new[i].accountId))
                    {
                        trigger.New[i].AccountId.AddError('This account has no active products.  You cannot create a domestic support case for an account with no active products.  Please contact your manager for more information.');
                    }
                }
                
                if (Trigger.New[i].OwnerId == strategicSupportQueueId)
                {
                    Trigger.New[i].WasEscalated__c = true;
                }
                //  with the case vf page going away, this will always be set to false,
                //  need to make sure that the prepopuatlino it does for cases is good for all case types
                if (!Trigger.New[i].Is_Case_Created_Using_VF_Page__c)//  if the case was made by web to case or connect for outlook
                {
                    //  assign custom fields that the vf page wouldve set if created using the vf page
                    setFieldsThatTheVFPageWouldveSet(Trigger.New[i]);
                }
                if (Trigger.New[i].Escalated_To_Pd__c)
                {
                    Trigger.New[i].Escalated_To_pd_timestamp__c = datetime.now();
                }
        
                //  if this is newly created record and the status is set to close (ie. save and close button)
                //  then update that save and closed field
                if (Trigger.New[i].status == 'Closed')
                {
                    CaseClassHelperClass.updateTheClosedByFieldForTheCase(Trigger.New[i]);
                }
                
                CaseClassHelperClass.checkThatCaseIsntAssigendToInvalidQueue(Trigger.New[i]);
                
                CaseClassHelperClass.updateCaseReasonSubReasonIfChangeRequest(
                    Trigger.new[i], changeRequestCaseReasonId, defectSubReasonId, caseRecordTypes);
                                    
                if (Trigger.New[i].IsEmail2Case__c == 'True')
                {
                    util.debug('isEmail2Case is set to true');
                    
                    if (Trigger.New[i].subject == null || Trigger.New[i].subject.length() == 0)
                    {
                        Trigger.New[i].subject = 'Email-to-Case';
                    }
                    if (Trigger.New[i].Description == null || Trigger.New[i].Description.length() == 0)
                    {
                       Trigger.New[i].Description = 'Email-to-Case';   
                    }
                    
                    string subjectLowerCase = Trigger.New[i].Subject.toLowerCase();
                    util.debug('subjectlowercase = ' + subjectLowerCase);
                    
                    if (subjectLowerCase.contains('voice mail received'))//  it's a zultys email
                    {
                        CaseClassHelperClass.prePopCaseForZultysVoiceEmail(subjectLowerCase, Trigger.New[i]);
                    }
                    
                    prePopCaseFieldsForEmail2Case(Trigger.New[i]);
                }
                if (Trigger.New[i].RecordtypeId == retrieveRecordType('Professional Services'))
                {
                    //  the isvisibiliinselfservice portal flag should be false for all prof services cases
                    Trigger.New[i].IsVisibleInSelfService = false;
                }
                    
            }
        }
        
    }
      public static decimal roundNearest5Minutes(decimal d)
    {
        //util.debug('Datetime passed into method = ' + theDate.format());
        if (d == null || d == 0)
        {
            return 0;
        }
        long minutes = (long)d; //theDate.Minute();
        
        while (Math.Mod(minutes, 5) != 0)
        {
            minutes++;
        }
         
        return minutes;
        
        //theDate = DateTime.NewInstance(theDate.year(), theDate.month(), theDate.day(), theDate.Hour(), Integer.valueOf(minutes), theDate.Second());
                
        //return theDate;
    }
    private boolean isCaseSupportOrRescuePin(id recordtypeId)
    {
        return recordTypeId == supportRecordTypeId || recordTypeId == rescuePinRecordTypeId;
    }
    private  boolean isAccountDomesticAndContainsNoProductsOrActive(id accountId)
    {
        try
        {
            Account tempAccount = [select id, recordtypeid, name, recordtype.name, type from Account where id =: accountId];
            boolean isAccountDomestic = tempAccount.RecordType.name.contains('Domestic');
            
            boolean doesAccountHaveNoProducts = (AccountClass.queryLineItemsThatCustomerOnlyHasServiceAgreementsFor(accountId).size() == 0);
            boolean isAccountInactive = (tempAccount.type == null ? true : tempAccount.type.contains('Inactive') || tempAccount.type == 'Out of Business');
            // want to allow cases to be created for roadnet tech accounts even if they have no products
            boolean isRoadnetTechAccount = tempAccount.name == null ? false : (tempAccount.name.contains('Roadnet') || tempAccount.Name.contains('Test Account'));  
             
            return !isRoadnetTechAccount && (isAccountDomestic && doesAccountHaveNoProducts || isAccountInactive);
        }
        catch(Exception e)
        {
            return false;//  if error occurs above, at least let the case be created.
        }            
    }
    private void prePopCaseFieldsForEmail2Case(Case c)
    {
        if (c.accountid != null)
        {
            c.Product_Version__c = CaseClassHelperClass.queryAccountProductVersion(c.accountId);
        }
        if (c.origin == 'MobileCast Support')
        {
            c.Product_Family__c = rtsProductfFamilyId;
            c.Product__c = mobileCastProductId;
            c.Reason2__c = javaRegisId;
        }
        else if (c.origin == 'RNA Support Roadnet' )
        {
            c.Product_Family__c = rnaProductFamilyId;
        }
        else if ( c.origin == 'RTS Support')
        {
            c.Product_Family__c = rtsProductfFamilyId;
        }
        else if (c.origin == 'RN Telematics')
        {
            c.product_family__c = telematicsProductFamilyId;
        }
        else if ( c.origin == 'Var Support')
        {
            c.Is_International_Support_Case__c = true;
        }
        
        //  john asked if we could default the urgency for email 2 case to 2 - Moderate Impact
        c.Urgency__c = '2 - Moderate Impact';
        
        //  im seeing lots of errors where a user tries to create a case event at the case for email2case but because the start time is not set
        //  the event cant be crated.  this should fix that issue.
        if (c.start_time__c == null)
        {
            c.start_Time__c = DAteTime.now();
        }
 
    }
    
    private Id retrieveRecordType(string recordTypeName)
    {

        //  when trying to update lots of cases via c# app script, got error too many soql queries on this method
        //  so i'm hardcoding the values here
        id valueToReturn;
        if (recordTypeName == 'Support')
        {
            valueToReturn = '0123000000086qt';
        }
        else if (recordTypeName == 'Admin')
        {
            valueToReturn = '01230000000Lu6G';
        }
        else if (recordTypeName == 'Consulting Case')
        {
            valueToReturn = '01230000000Lu6H';
        }
        else if (recordTypeName == 'Customer Portal')
        {
            valueToReturn = '01230000000hvO8';
        }
        else if (recordTypeName == 'Enhancement')
        {
            valueToReturn = '01230000000Lu6I';
        }
        else if (recordTypeName == 'Professional Services')
        {
            valueToReturn = '01230000000Lu6K';
        }
        
        if (valueToReturn == null)
        {
            throw new CaseTriggerException('Record type with name: ' + recordTypeName + ' was not found.');
        }
        else
        {
            return valueToReturn;
        }
    }
    
    private void setFieldsThatTheVFPageWouldveSet(Case theCase)
    {
        //system.debug('ctrlf ********inside of setFieldsThatTheVFPageWouldveSet method');
        system.assertNotEquals(null, theCase);
        system.assertEquals(false, theCase.Is_Case_Created_Using_VF_Page__c);
        
        Id accountId;
        
        if (theCase.accountId == null)
        {
            //  try to get the account Id from the contact
            if (theCase.ContactId != null)
            {
                accountId = [select accountId from Contact where id =: theCase.ContactId].accountId;
            }
        }
        else
        {
            accountId = theCase.accountId;
        }
        
        //  Amy has suggested it be ok for cases to be created with the contact id or account id being set.  the other case fields will not 
        //  be filled in.
        //  we dont want to this to call for prof services because we have a schdueled job that is going to create a couple of database maintance cases
        //  and we don't want too many sql querires to happen here.
        if ((accountId != null) && (theCase.REcordtypeId != retrieveRecordType('Professional Services')))
        {
            Account accountOfCase = [select id, recordtype.Name, spotLight_account__c, rts_installed_version2__c
            from Account where id =: accountId];
            //  call the public method that sets the fields by default
            CaseClassHelperClass.initFieldsForNewCase(theCase, accountOfCase.recordtype.name, 
                accountOfCase.rts_installed_version2__c, 
                accountOfCase.spotLight_account__c, theCase.contactid);
        }
    }
    
    private class CaseTriggerException extends Exception{}
    

}
*/
/*******************************************************************************
 * File:  CaseBeforeInsertTrigger
 * Date:  November 8, 2013
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
 * Purpose: 
 *   Trigger fired on Cases.
 *******************************************************************************/
 //MIBOS SANDBOX
trigger CaseBeforeInsertTrigger on Case (before insert)
{
    
     /*BypassTriggerUtility u = new BypassTriggerUtility();  
     if (u.isTriggerBypassed()) {
         return;
     }
    
    List<RecordType> caseRecordTypes;
    private id m_strategicSupportQueueId;
    private id strategicSupportQueueId
    {
        get
        {
            if (m_strategicSupportQueueId == null)
            {
              m_strategicSupportQueueid = [select queueid from QueueSobject where queue.name = 'Strategic Support' and SobjectType = 'Case'].queueId;
            }
            return m_strategicSupportQueueId;
        }
    }
    
    private User m_emailAgent;
    private User emailAgent
    {
        get
        {
            if (m_emailAgent == null)
            {
                //  i want to assume that the email agents email is not going to change... is it a safer bet to check on the name?
                //  THE GOD DAMN USERNAME DIFFERS BETWEEN UAT AND OMNI PROD, THATS WHY IVE SPENT 3 HOURS TRYING TO FIGURE OUT WHY THIS ISNT WORKING
                util.debug('querying email agent...');
                m_emailAgent = [select id, name, username, email from user where (name = 'Email Agent' OR alias = 'eagent')];
                util.debug('email agent hopefully queried with id: ' + m_emailAgent.id);
            }
            return m_emailAgent;
        }
    }
    
    if (CheckRecursive.runOnce() && !MigrationUser.isMigrationUser())   
    {
        if (Trigger.isBefore && Trigger.isInsert)
        {
            CaseServices.setLastModifiedDateTimeField(Trigger.new);
            
            util.debug('about to call prepopulateContactAndAccountIfEmail2Case');
            try
            {
               prepopulateContactAndAccountIfEmail2Case(Trigger.new);
            }
            catch(Exception e)
            {
                util.debug('while trying to populate contact/account, exception was given: ' + e.getMessage());
            }
            
            //  placing this outside of the for loop as it saves on queries (the method queries all prodcut families, and reasons we dont want the query
            //  to get called every time a case is processed
            for (integer i = 0; i < Trigger.New.size(); i++)
            {
                //  we need to guesstimate the total work effort since we cannot query agaisnt the case time table like we can in the after trigger
                //  so we need to parse out the number of assistant techs and multple the num of assitatnt techs by work effort in minutes which will give
                //  us the total work effort
                trigger.new[i].total_work_effort__c = guessTheTotalWorkEffort(trigger.new[i]);
                
                if (Trigger.New[i].Recordtypeid == retrieveRecordType('Rescue Pin Support'))
                {
                    //  null this out so that when the user goes to edit the support case, they are forced to pick value
                    Trigger.New[i].Work_Effort_In_Minutes__c = null;
                    Trigger.New[i].RecordtypeId = retrieveRecordType('Support');
                }
                if (Trigger.New[i].AccountId != null &&
                    (Trigger.New[i].RecordtypeId == retrieveRecordType('Support') || Trigger.new[i].recordtypeid == retrieveRecordType('Rescue Pin Support')))
                {
                    
                   
                }
                
                if (Trigger.New[i].RecordtypeId == retrieveRecordType('Professional Services'))
                {
                    //  the isvisibiliinselfservice portal flag should be false for all prof services cases
                    Trigger.New[i].IsVisibleInSelfService = false;
                }
                    
            }
        }
        
    }
    
    private void prepopulateContactAndAccountIfEmail2Case(List<Case> newCases)
    {
        //  get a unique set of emails?  i dont know if there is any benefit on getting a unique set or just a list of them
        //  there is also the posiblity that more than one contact will be queried for one email 
        //  its ok if its a list i believe, i just tested this in a script and the same number of contacts were quereid without
        // any excepion being thrown
        util.debug('inside of prepopulateContactAndAccountIfEmail2Case');
        
        List<string> suppliedEmails = new List<string>();
        for (Case singleCase : newCases)
        {
            util.debug(
              'checking case is email2case with suppliedemail: ' + singleCase.SuppliedEmail + ' value of isEmail2Case: ' + isEmail2Case(singleCase));
            if (isEmail2Case(singleCase))
            {
                suppliedEmails.Add(singleCase.SuppliedEmail);
            }
        }
        util.debug('outputting supplied email list: ' + suppliedEmails);
        if (suppliedEmails != null && suppliedEmails.size() > 0)
        {
            List<Contact> contactsOfCases = 
               [select id, name, email, phone, inactive__c, accountid, account.name from contact where 
                   email in: suppliedEmails
                   order by lastmodifieddate, accountid desc limit 10000];
            
            util.debug('query for contactsOfCases finisehed.  num of contacts of cases: ' + (contactsOfCases == null ? 0 : contactsOfCases.size()));
            
            //  now scroll thru the cases, pulling out the (or mulitple) contacts and make the assignment
            for (Case singleCase : newCases)
            {
                //  this will pull out the contact, if more than one contact, it will pull out the active and/or latest modified
                Contact contactOfCase = findContactOfCase(contactsOfCases, singleCase.suppliedEmail);
                util.debug('after looking for contact of caes.. value is: ' + contactOfCase);
                
                if (contactOfCase != null)
                {
                    singleCase.ContactId = contactOfCase.id;
                    //  just did a quick test to see if the case email and phone (suppliedPHone) were set when assigning the account and contact
                    //  on my test email2case and it did not so i will those fields also, even though i feeel like suppliedphone should be system
                    //  populated, i feel like John might ask why that is not being populated also so lets just go ahead and do it
                    if (contactOfCase.email != null)
                    {
                        singleCase.Email__c = contactOfCase.email;
                    }
                    if (contactOfCase.Phone != null)
                    {
                        singleCase.SuppliedPhone = contactOfcase.phone;
                    }
                    if (contactOfCase.AccountId != null)
                    {
                        singleCase.AccountId = contactOfCase.AccountId;
                    }
                }
            }
        }
    }
    private boolean isEmail2Case(Case theCase)
    {
        //  after countless hours of testing, it looks like the only other thing we have to know this is an email2case is the userinfo.getUserId
        //  and the owner id are both the email agent, i will check for both....
        return theCase.SuppliedEmail != null && 
            (theCase.OwnerId == emailAgent.id || UserInfo.getUserId() == emailAgent.id);
    }
    private Contact findContactOfCase(List<Contact> contacts, string suppliedEmail)
    {
        if (contacts != null && contacts.size() == 0)
        {
            return null;
        }
        
        //  make a list because its possible we'll see more than one contact with the same email
        List<Contact> contactsToReturn = new List<Contact>();
        for (Contact singleContact : contacts)
        {
            if (singleContact.email == suppliedEmail)
            {
                contactsToReturn.Add(singleContact);
            }
        }
        if (contactsToReturn != null && contactsToReturn.size() == 0)
        {
            //  no matching contacts wrer found
            return null;
        }
        
        if (contactsToReturn != null && contactsToReturn.size() == 1)
        {
            return contactsToReturn[0];
        }
        else
        {
            //  so if there are more than one contact, we need to check for activeness and which one was last modified
            //  the contact query above should have sorted these in lastmodified desc so that means the first on the list
            //  we be the latest modified, so we just need to find the first ont hat is active
            Contact latestActiveContact = findLatestActiveContact(contactsToReturn);
            util.debug('latestActiveContact = ' + latestActiveContact);
            
            if (latestActiveContact != null)
            {
                return latestActiveContact;
            }
            else if (contactsToReturn.size() > 0)//  couldnt find any active contact, so just returnt he latest modified
            {
                return contactsToReturn[0];
            }
            else
            {
                return null;
            }
        }
    }
    private Contact findLatestActiveContact(List<Contact> contacts)
    {
        for (Contact singleContact : contacts )
        {
            if (!singleContact.inactive__c)
            {
                return singleContact;
            }
        }
        return null;
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
        return null;
        //throw new CaseTriggerException('Record type with name: ' + recordTypeName + ' was not found.');
    }
    private decimal guessTheTotalWorkEffort(Case theCase)
    {
        if (theCase.Assisting_techs__c != null)
        {
            List<User> assistantUsers = CaseEventExtension.parseUsersFromTextField(theCase.Assisting_techs__c);
            //  now we know ow many users we have that are assigend to assistant techs, we return the count * work effort in minutes
            if (assistantUsers == null || assistantUsers.size() == 0)
            {
                return (theCase.Work_Effort_In_Minutes__c);
            }
            else
            {
                decimal workEffort = theCase.Work_Effort_In_Minutes__c == null ? 0 : theCase.Work_Effort_In_Minutes__c;
                //workEffort = CaseEventExtension.roundNearest5Minutes(workEffort);
                return workEffort * (assistantUsers.size() + 1);
            }
        }
        else
        {
            return theCase.Work_Effort_In_Minutes__c;
        }
    }
   
    private boolean isCaseSupportOrRescuePin(id recordtypeId)
    {
        return recordTypeId == retrieveRecordType('Support') || recordTypeId == retrieveRecordType('Rescue Pin Support');
    }
   
    private void prePopCaseFieldsForEmail2Case(Case c)
    {
        
    }
  
    private class CaseTriggerException extends Exception{}*/
    
}