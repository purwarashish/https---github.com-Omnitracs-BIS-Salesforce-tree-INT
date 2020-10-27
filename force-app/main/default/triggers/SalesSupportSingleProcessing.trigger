/*******************************************************************************
 * File:  SalesSupport.Trigger
 * Date:  January 21st, 2011
 * Author:  Joseph Hutchins
 *
 * The use, disclosure, reproduction, modification, transfer, or transmittal of
 * this work for any purpose in any form or by any means without the written 
 * permission of United Parcel Service is strictly prohibited.
 *
 * Confidential, unpublished property of United Parcel Service.
 * Use and distribution limited solely to authorized personnel.
 *
 * Copyright 2009, UPS Logistics Technologies, Inc.  All rights reserved.
 *  *******************************************************************************/
trigger SalesSupportSingleProcessing on Sales_Support__c (before insert, after insert, before update, after update)
{

     BypassTriggerUtility u = new BypassTriggerUtility();  
     if (u.isTriggerBypassed()) {
         return;
     }

    /*
       Be advised, this object used to have triger name SalesSupport, I had to change it to this trigger.
       The previous one was designed to handle bulk processing but when i deployed it to the live, the trigger was not working
       I created this which has the same logic but handles the oppt updtae one at a time.  
    */
    private List<RecordType> m_salesSupportRecordTypes;
    
    private List<RecordType> salesSupportRecordTypes
    {
        get
        {
            if (m_salesSupportRecordTypes == null)
            {
               m_salesSupportRecordTypes = [select id, name from RecordType where SobjectType = 'Sales_Support__c'];
            }
            return m_salesSupportRecordTypes;
        }
    }
    
    /*if (Trigger.isBefore && (Trigger.isinsert || Trigger.isUPdate))
    {
        shadowCopyProductsField(Trigger.new);
    }*/
    if (Trigger.IsAfter && (Trigger.IsUpdate || Trigger.isInsert))
    {
        sendEmailAlertPsResourcesRequested(Trigger.old, Trigger.new);
        
        //  alright, i have received another update to this logic....
        //  so. what i had before was correct.  The Current SE update logic was fine and it should only apply to those three recordtypes
        //  the update of the checkbox and support status should occur for all recordtype except for the other three
        List<Opportunity> opptsOfSalesSupports = queryOpportunites(Trigger.new);
        List<Opportunity> opptsToUpdate = new List<Opportunity>();
        
        for (Sales_Support__c singleSalesSupport : Trigger.new)
        {
            if (singleSalesSupport.Opportunity__c != null)
            {
                Opportunity opptOfSalesSupport = findOpportunity(singleSalesSupport.Opportunity__c, opptsOfSalesSupports);
                
                //  alright here is the deal, within a day the logic for this has changed like 5 times
                //  this is what i know. we DO NOT want the hassales suppor checkbox/status field to update for the three recordteyps
                //    Architecture Scoping, Gap Analysis, Technical Support,
                //  while at my desk amy said its ok if the trigger updatees the current se for the other record types (even though it was not 
                //  doing so originally) i sent email to amy and will await her response to see if can keep the logic i have now
                //  for now im going to test this to make sure it does what i think it does
                
                if (opptOfSalesSupport != null && isSalesSupportApartOfValidRecordTypes(singleSalesSupport.RecordTypeId))
                {                
                    //  per the sf issue, need to update the oppt's checkbox and the sales support activity status
                    opptOfSalesSupport.Has_Sales_Support_Activity__c = true;
                    opptOfSalesSupport.Sales_Support_Activity_Status__c = 
                       Util.isBlank(singleSalesSupport.Status__c) ? '' : singleSalesSupport.Status__c;
                    
                    //  if the sales support in contexts current se is set, update the oppt's current se with the value
                    if (singleSalesSupport.se_user__c != null)
                    {
                        opptOfSalesSupport.Current_Se__c = singleSalesSupport.se_user__c;   
                    }
                    else
                    {
                        opptOfSalesSupport.Current_Se__c = findMostCurrentSe(singleSalesSupport.Opportunity__c);
                    }
                    //  now we add the oppt to a list that we will update
                    opptsToUpdate.ADd(opptofSalesSupport);
                    
                }
                
            }
        }
        //  i only want the opppt update o curre if one of the two things that caould happen to it actgullayoccured, to acheive this i need to add b ool
        //  that will be fales and get set if tone of the if statments above abtuclly does somehtin gto hte opt
        if (opptsToUpdate != null && opptsToUpdate.Size() > 0)
        {
            Database.saveResult[] saveResults = database.update(opptsToUpdate, false);
            //  need to scrll thru each save result to see if there were any failures and if so just send errror email with the count
            integer numThatFailedUpdate = 0;
            
            for (Database.SaveResult sr : saveResults)
            {
                if (!sr.isSuccess())
                {
                    numThatFailedUpdate++;
                }
            }
            if (numThatFailedUpdate > 0)
            {
                //  i was going to have this spit out a string of oppt ids that failed, but that means i have to use a for loop coutner
                //  and the last thing i need is for an index out of bounds to occur in the live evnionment due to bad trigger logic
                //  so unless i need to know the idss, this should suffice
                //EmailClass.sendErrorEmail('Failed to update oppts after sales support activites were inserted/updated', null);
            }
        }
    }
    
    
    /*private void shadowCopyProductsField(List<Sales_Support__c> triggerRecords)
    {
        //  created a seperate products field for omnis/xrs users.  we still want to use the same report
        //  in filters/reports so we'll copy over the values in the Products_Omni_Xrs__c field to the original products fields
        for (Sales_Support__c ss : triggerRecords)
        {
            if (ss.Owner_Business_unit__c != 'Roadnet')
            {
                ss.Products__c = ss.Products_Omni_Xrs__c; 
            }
        }
    }*/
    
    private void sendEmailAlertPsResourcesRequested(List<Sales_Support__c> oldSalesSupports, List<Sales_Support__c> newSalesSupports)
    {
        util.debug('sendEmailAlertPsResourcesRequested method called');
        //  there is actually some extra logic that needds to be added that my change how this works... 
        //  not only do the ps resources get the email, but so does the primary manaed by, now that i type that out, i don't think it is that much of a change
        
        List<Sales_Support__c> salesSupportToSEndEmailAlertsFor = new List<Sales_Support__c>();
        List<EmailClassRoadnet.EmailTemplateEx> emailObjects = new List<EmailClassRoadnet.EmailTemplateEx>();
        if (oldSalesSupports == null)
        {
            //  send the email alerts for all of the sales supports that have ps resources filled in
            for (integer i = 0; i < newSalesSupports.size(); i++)
            {
                if (newSalesSupports[0].PS_Resources__c != null)
                {
                    salesSupportToSendEmailAlertsFor.add(newSalesSupports[0]);
                }
            }
        }
        else
        {
            for (integer i = 0; i < newSalesSupports.size(); i++)
            {
                if (newSalesSupports[0].PS_Resources__c != null &&
                   oldSalesSupports[0].PS_Resources__c != newSalesSupports[i].PS_Resources__c)
                {
                        
                   salesSupportToSendEmailAlertsFor.add(newSalesSupports[0]);
                }
            }
        }
        
        if (salesSupportToSendEmailAlertsFor.size() > 0)
        {
            util.debug('there are some emails that will be sent out.  num of sales supports where emails should get sent out: ' + salesSupportToSendEmailAlertsFor.size());
            
            EmailTemplate et = [select id, name from EmailTemplate where name = 'PS Resources Assigned' and IsActive = true  limit 1];
            system.assertNotEquals(null, et);
                    
            //  need to use the contacts so i can use their id for the email template.whatid
            List<Contact> activeRoadnetContacts = 
                  [select id, firstname, lastname, email, name from contact where inactive__c = false AND
                      (email like '%roadnet%') order by lastname, firstname, lastmodifieddate desc];
            //  needed to find the contact record of the Primary Managed by field if it contains value
            List<User> activeRoadnetUsers = 
                [select id, firstname, lastname from user where isactive = true AND
                      (email like '%roadnet%' or username like '%roadnet%') order by lastname, firstname];
            for (Sales_Support__c ss : salesSupportToSendEmailAlertsFor)
            {
                util.debug('SalesSupport.PS_Resources__c: ' + ss.PS_Resources__c);
                
                if (ss.PS_Resources__c != null)
                {
                    //  parse the Contacts that the email template should be sent too
                    Set<string> psResourceNames = new Set<string>();
                    List<string> psResourcesParsed = Util.parseString(ss.PS_Resources__c);
                    util.debug('ps Resources field Parsed: ' + psResourcesParsed);
                    
                    // now we have a list of Contacts, ad that to the set one by one checking that one didn't already get added to the set
                    if (psResourcesParsed != null && psResourcesParsed.size() > 0)
                    {
                        for (integer i = 0; i < psResourcesParsed.size(); i++)
                        {
                            if (!psResourceNames.contains(psResourcesParsed[i]))
                            {
                                psResourceNames.add(psResourcesParsed[i]);
                            }
                        }
                        //  we should be able to now, using the names in the list, get a list of Contacts
                        List<Contact> roadnetContactsToReceiveEmail = grabContactsUsingLastNameFirstName(psResourceNames, activeRoadnetContacts);
                        util.debug('finished retrieving Contact recors for Contacts set in ps resource list: ' + roadnetContactsToReceiveEmail.size());
                        
                        // now that we have the Contacts of the ps resources field, we need to get the Contact record for the primary managed by field
                        if (ss.se_user__c != null)
                        {
                            util.debug('the primary managed by contains value: ' + ss.se_user__c + '. will attempt to find Contact record now....');
                            Contact primaryManagedByContactRecord = findContactUsingId(ss.se_user__c, activeRoadnetContacts, activeRoadnetUsers);
                            if (primaryManagedByContactRecord != null)
                            {
                                util.debug('primary managed by Contact has been found: ' + primaryManagedByContactRecord);
                                //  make sure the primary managed by isnt elarey aded to the list
                                if (!doesContain(primaryManagedByContactRecord, roadnetContactsToReceiveEmail))
                                {
                                    util.debug('primary managed by was not found to be in the SET of Contacts who will recieve email. adding now...');
                                    roadnetContactsToReceiveEmail.add(primaryManagedByContactRecord);
                                }
                            }
                        }
                        //  now we can generate the email object, not to worry, i do not plan on sending the emails untill all of the sales supports have been cursored thru
                         //  query the email template for its id
                    
                        for (Contact tempContact : roadnetContactsToReceiveEmail)
                        {
                            EmailClassRoadnet.EmailTemplateEx tempEmailEx = new EmailClassRoadnet.EmailTemplateEx();
                            tempEmailEx.targetId = tempContact.id;
                            tempEmailEx.templateId = et.id;
                            //  so as i figured, i am unable to use a what id when sending emails to Contacts...so my option is to create a email template in the code
                            //  OR..... google search says it it not possible unles you use contacts records which i dont think we have? it looks like we do
                            //  so my options now is to keep the logic here but instead of quering Contact records, query CONTACt RECORDS
                            //  OR..... hard code the email template into my applicaiton and seeing what happens there... i like the previous idea first
                            tempEmailEx.whatid = ss.id;//  actually this might not be the route to go.  
                            //  we cannot use a what id if we are assoicating a Contact record with the email tempate
                            tempEmailex.saveAsActivity = false;
                            emailObjects.add(tempEmailEx);
                            util.debug('contact with name: ' + tempContact.name + ' will have an email sent out to email address: ' + tempContact.email);
                            
                        }
                    }
                  
                }
            }
            util.debug('about to send emails.  num of email objects: ' + (emailObjects == null ? 0 : emailObjects.size()) );
            if (emailObjects != null && emailObjects.size() > 0)
            {
                util.debug('trying to send emails now.');
               EmailClassRoadnet.sendEmailsWithTemplate(emailObjects);
               util.debug('emails should have been sent');
            }
         
        }
    }
    private static List<Contact> grabContactsUsingLastNameFirstName(set<string> contactNamesBackwards, List<Contact> activeContacts)
    {
        List<Contact> contactsToReturn = new List<Contact>();
        if (contactNamesBackwards == null || contactNamesBackwards.size() == 0)
        {
            return contactsToReturn;
        }   
        
        for (string lastNameThenFirstName : contactNamesBackwards)
        {
            for (Contact singleContact : activeContacts)
            {
                if (singleContact.LastName != null && lastNameThenFirstName.contains(singleContact.LastName) &&
                  singleContact.FirstName != null && lastNameThenFirstName.Contains(singleContact.firstName))
                {
                    contactsToReturn.add(singleContact);//  this is match return it
                }
                
            }
        }
        return contactsToReturn;
    
    }
    private static Contact findContactUsingId(Id primaryManagedById, List<Contact> activeContacts, List<User> activeUsers)
    {
        User primaryManagedbYUserRecord;
        //  need to look for the matching user record, then using that matching user record, match the firstname/lastname to the 
        //  that of the contact list
        for (User singleUser : activeUsers)
        {
            if (singleUser.id == primaryManagedById)
            {
                primaryManagedbYUserRecord = singleUser;
                break;
            }
        }
        if (primaryManagedbYUserRecord != null)
        {
            //  now scroll thru the contacts looking for matches on first name and last name
            for (Contact singleContact : activeContacts)
            {
                if (singleContact.FirstName != null && singleContact.FirstName.contains(primaryManagedbYUserRecord.firstname) &&
                    singleContact.LastName != null && singleContact.LastName.Contains(primaryManagedbYUserRecord.lastname))
                {
                    util.debug('found matching contact record for user with id: ' + primaryManagedById);
                    return singleContact;
                }
            }    
            util.debug('primary managed by user record was found, but could not find matching contact.  ' + primaryManagedbYUserRecord);
            return null;
        }
        else
        {
            util.debug('could not find matching active roadnet user record where primary managed by id: ' + primaryManagedById);
            return null;
        }
    }
    
    /*
    private static Contact findContact(string lastNameThenFirstName, List<Contact> activeContacts)
    {
        if (lastNameThenFirstName == null || lastNameThenFirstName.length() == 0)
        {
            return null;
        }
        for (Contact singleContact : activeContacts)
        {
            if (singleContact.LastName != null && lastNameThenFirstName.contains(singleContact.LastName) &&
              singleContact.FirstName != null && lastNameThenFirstName.Contains(singleContact.firstName))
            {
                return singleContact;//  this is match return it
            }
            
        }
        return null;
    }
    */
    private static boolean doesContain(Contact theContact, List<Contact> listOfContacts)
    {
        if (theContact == null)
        {
            return false;
        }
        for (Contact tempContact : listOfContacts)
        {
            if (theContact.id == tempContact.id)
            {
                return true;
            }
        }
        return false;
    }
    private List<Opportunity> queryOpportunites(List<Sales_Support__c> triggerRecords)
    {
        List<Opportunity> opptsToReturn = new List<Opportunity>();
        set<id> opptIds = new set<id>();
        for (Sales_Support__c singleRecord : triggerRecords)
        {
            if (singleRecord.Opportunity__c != null &&
              !opptIds.Contains(singleRecord.Opportunity__c))
              {
                opptids.add(singleRecord.Opportunity__c);
              }
        }
        if (opptIds != null && opptIds.Size() > 0)
        {
            return [select id, name, current_se__c, has_sales_support_activity__c, sales_support_activity_status__c from Opportunity where id in: opptIds];
        }
        else
        {
            return new List<Opportunity>();
        }
    }
    private boolean isSalesSupportApartOfValidRecordTypes(id recordtypeId)
    {
        util.debug('num of sales support record types' + salesSupportRecordTypes.size());
        util.debug('id passed into method = ' + recordTypeId);
        
        //  all sales support record types are accetable except Architecture Scoping, Gap Analysis, Technical Support
        //  tyhere might be more recordtypes creatd in the future so the way this is going to work,
        //  it will actually look for the record types we dont, and
        for (RecordType rt : salesSupportRecordTypes)
        {
            //  once we know we are looking at the right recordype, we check its name to see
            //  if its one of the three we don want
            if (rt.Id == recordTypeId) 
            {
                return rt.Name != 'Architecture Scoping' &&
                  rt.Name != 'Gap Analysis' &&
                  rt.Name != 'Technical Support';
            }
            
        }
        //  i think its safe to return true if the record name didnt match the three up there
        //  unless i typed the names wrong which is something i should catch during testing        
        return true;
    }    

    private Opportunity findOpportunity(Id opptId, List<Opportunity> opptsToCheck)
    {
        for (Opportunity singleOppt : opptsTocheck)
        {   
            if (singleOppt.Id == opptId)
            {
                return singleOppt;
            }
        }
        return null;
    }
    
    private id findMostCurrentSe(id opptId)
    {
        //  need to query all sales support activites that have a se_user__c set where the lastmodifed by is the lastes
        //  we are going to exclude sale suppport activites that are of recordtype Architecture Scoping, Gap Analysis or
        //  Technical Support as the trigger doesn't process sales support actiivites of those type
        try
        {
            List<Sales_Support__c> salesSupportOfOppt = [select id, se_user__c, opportunity__c 
               from Sales_Support__c 
               where Opportunity__c =: opptId AND
               (RecordType.Name != 'Architecture Scoping' AND RecordType.Name != 'Gap Analysis' AND  RecordType.Name != 'Technical Support') AND
               se_user__c != null
               order by LastModifiedDate desc];
             
             util.debug('number of salessupport of oppt records found: ' + salesSupportOfOppt.size());
             
            if (salesSupportOfOppt != null && salesSupportOfOppt.size() > 0)
            {
                return salesSupportOfOppt[0].se_user__c;
            }
            else
            {
                return null;
            }
        }
        catch(Exception e)
        {
            
            //  possible that the query fails if there are no records that match the criteria
            //  if that is the case, we'll return null
            return null;
        }
    
    }

    /*  these methods were used in old logic or when the trigger used to process in batch.... actually i think i can still make it so that this updates
    everyting in batch so i'll bring some of these methods back.  im not going to remove them becfuase the logic might change back to what it was
    private Opportunity queryOpportunity(Id opportunityId)
    {
        return [select id, name, current_se__c, has_sales_support_activity__c, sales_support_activity_status__c from Opportunity where id =: opportunityId];
    }

        
        
    private boolean doesExistOnlyCertainSalesSupport(Sales_Support__c currentTriggerRecord)
    {
        //  we need to look at all optts that lpoint to this oppt
        //  including this one, if the only ones that are found are of type
        //  Architecture Scope, Gap Analysis, or Tech Support
        //  then return true
        //  but if we find any other types we return false
        if (currentTriggerRecord.Opportunity__c != null)
        {
            //  so first check the record that is in the trigger to see if its one of the three, if its not we can return false quickly
            if (!isArchitectureGapOrTechnicalSupportRecordtype(currentTriggerRecord.RecordtypeId))
            {
                return false;
            }
            //  now we check that rest of the sales suppor tactiviies of the oppt
            for (Sales_Support__c singleSalesSupport : 
              [select id, recordtypeid from Sales_Support__c where Opportunity__c =: currentTriggerRecord.Opportunity__c])
            {
                if (!isArchitectureGapOrTechnicalSupportRecordtype(singleSalesSupport.RecordTypeId))
                {
                    return false;
                }
            }
            
            return true;//  after scrolling thru all sales suppor that point to the oppt, we can return true if all of them are of the three recordtypes
        }
        return false;//  if the oppt is not set, i guess we can say that all of the recorddtypes of the sales suppport are not of the type
    }
    
    private boolean isArchitectureGapOrTechnicalSupportRecordtype(Id recordTypeId)
    {
        for (RecordType rt : salesSupportRecordTypes)
        {
            if (recordtypeId == rt.id)
            {
               if (rt.name == 'Architecture Scoping' || rt.Name == 'Gap Analysis' || rt.name == 'Technical Support')
               {
                   return true;
               }
               else
               {
                   return false;
               }
            }
        }
        return false;//  by default we will reutrn false here
    }

    
    private List<Sales_Support__c> findSalesSupportOfOppt(Id opptId, List<Sales_Support__c> allSalesSupports)
    {
        List<Sales_Support__c> listToReturn = new LIst<Sales_Support__c>();
        for (Sales_Support__c ss : allSalesSupports)
        {
            if (ss.Opportunity__c == opptId)
            {
                listToReturn.add(ss);
            }
        }
        
        return listToReturn;
    }
    

   */
}