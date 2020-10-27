/*******************************************************************************
 * File:  CaseAfterInsertTrigger
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
//  MIBOS SANDBOX
trigger CaseAfterInsertTrigger on Case (after insert)
{
     /*BypassTriggerUtility u = new BypassTriggerUtility();  
     if (u.isTriggerBypassed()) {
         return;
     }
     
    util.debug('case after insert trigger called. num queries: ' + util.queriesUsed);
    
    private List<User> allPartnerUsers;
    private Recordtype[] caseRecordTypes = null;
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
    private User loggedInUser
    {
        get
        {
            if (loggedInuser == null)
            {
                loggedInUser = [select id, profileid, profile.name from User where id =: userINfo.getUserid()];
            }
            
            return loggediNuser;
            
        }
    }
    private boolean isUserCustomerCommunity
    {
        get
        {
            if (loggedInuser != null)
            {
                return loggedInUser.Profile.Name != null && loggedInuser.Profile.Name.Contains('Customer Community');
            }
            return false;
        }
    }

    if (!MigrationUser.isMigrationUser() )   
    {
        //  be advised that while testing the EmailAlertSupportCreation method in this trigger, i realized this method was NOT getting called because of this is 
        //  callig checkRecusrive..  i am turning it off right now, but will probably have to merge th logic in this trigger in the caseTrigger if removeing the checkRecusive here causes problems
        
        //if (CheckRecursiveAfter.runOnce())
        {
            
             
            if (Trigger.isAfter && Trigger.isInsert)
            {
                try
                {
                    util.debug('case after insert.  about to creating sharing rules.  CaseShareForVarRoadnet.hasRunBefore: ' + CaseShareForVarRoadnet.hasRunBefore);
                    CaseShareForVarRoadnet singleObject = new CaseShareForVarRoadnet();
                    singleObject.CreateCustomSharingForVars(Trigger.new);
                    CaseShareForVarRoadnet.hasRunBefore = true;
                    
                }
                catch(Exception e)
                {
                    util.debug('ERROR: ' + e.getMessage());
                }
                if (!isSendingEmailsDisabled)
                {
                    handleCaseSubscriberEmailAlerts();
                }
                
                for (integer i = 0; i < trigger.new.size(); i++)
                {
                    //  customer community users dont have case times or work effort assoicated wtih them
                    if (!isUserCustomerCommunity && isCaseSupport(Trigger.new[i].recordtypeid))
                    {
                        //  this needs to be in the insert after becuase the case id needs to be set for each case time that is created
                        //  unfornatly that means i cant swipe the field so ill need to add logic to the case update
                        //  that checks if the field has changed, and if so, create the case tiems THEN it can swipe the data in the field
                        //createCaseTimeForCase(new list<Case>{Trigger.new[i]});
                        System.debug('***createCaseTimeForCasesWorkEfforr executed');
                        CaseEventExtension.createCaseTimeForCasesWorkEffort(new list<Case>{Trigger.new[i]});
                    }
                    
                    //manageEmailAlerts(Trigger.new[i]);
                } 
            }
        }
        util.debug('case after insert trigger finished. num queries used: ' + util.queriesUsed);
    }
    
    private void handleCaseSubscriberEmailAlerts()
    {
        //  this sends email alert to users in the case.email_alert_support field and the case's account.email_alert_support and the account owner
        //  if the case.account.email_alert_all_cases is set
        List<Case> roadnetCallCenterCasesBeingCreated = new List<Case>();
        
        for (integer i = 0; i < Trigger.new.size(); i++)
        {
            if (Trigger.new[i].Business_unit__c == 'Roadnet')
            {
                if (isCaseSupport(Trigger.new[i].RecordtypeId))
                {
                    //  case is being closed, we are sending emails for that case
                    roadnetCallCenterCasesBeingCreated.Add(Trigger.new[i]);
                }
            }
        }
        if (roadnetCallCenterCasesBeingCreated.size() > 0)
        {
            CaseEventExtension.emailAlertSuppportCaseCreation(roadnetCallCenterCasesBeingCreated, 'Case Created');
        }
    }
    private Case findCaseUsingContactId(Id contactId, List<Case> cases)
    {
        for (Case c : cases)
        {
            if (c.contactId == contactId)
            {
                return c;
            }
        }
        return null;
    }

    private void manageEmailAlerts(Case newCase)
    {
        //  email alert section
        if (newCase.isEmail2Case__c == 'True')
        {
            manageEmail2Case(newCase);
        }
        //  this is handlebd by the vf page now since i created a new quick save btuton.  it was moved there to prevent "Case is opened" emails everytime the use presses
        //  quick save
        //sendEmailAlertsOut(newCase);
        
    }
    
    private void manageEmail2Case(Case newCase)
    {
      
    }
    private boolean isCaseSupport(string recordtypeId)
    {
        //  we so far have 4 different suppprt recordtypes, support, rescue pin support, call center, and engineering case
        return recordTypeId == retrieveRecordType('Call Center') || 
           recordTypeId == retrieveRecordType('Rescue Pin Support') || 
           recordTypeId == retrieveRecordType('Support') ||
           recordTypeId == retrieveRecordType('Engineering Case');
           
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
    
    private class CaseTriggerException extends Exception{}
    /*
    private void handleRoadnetCustomSharingForVars(list<Case> casesToCheck)
    {
        //util.debug('handleRoadnetCustomSharingForVars method called.  num cases in trigger: ' + (casesToCheck == null ? 0 : casesToCheck.size()) );
        
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
        //util.debug('found ' + (roadnetCases == null ? 0 : roadnetCases.size()) + ' roadnet cases');
        
        if (roadnetCases != null && roadnetCases.size() > 0)
        {
            //  requery the cases for the account owner, and the account's parent account's owner
            Case[] casesRequeried = new List<Case>();
            casesRequeried = [select id, accountid, contactid, contact.name, contact.account.name, contact.account.ownerid, account.account_classification__c, account.var_account1__c, account.name, account.parentid, 
                account.ownerid from case where id =: roadnetCases];
            //util.debug('cases have been requried....');
            
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
            //util.debug('determing if the case.account is a sub var, and if can find partner user');
                boolean isCaseSubVar = isCaseAccountSubVar(c);
                // we also need to make sure that the contact of the case is a partner user
                boolean isCaseContactAPartnerUser = determineIfCaseContactIsPartnerUser(c);  
                
                //  we now need to query the partner user record for the cases contactid
                User partnerUserRecordOfCase = findPartnerUser(c.contactid);
                
                
                if (isCaseSubVar && 
                    isCaseContactAPartnerUser &&
                    partnerUserRecordOfCase != null) 
                {
                  //util.debug('about to grab the var user record that is assoicated with this subvar: ' + c.contact.name);
                  
                  //  query the var of the sub var
                  User varOfSubVar = findVar(partnerUserRecordOfCase.var_name__c);
                  //util.debug('var should have been found: ' + varOfSubVar);
                  
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
          //util.debug('could not find partner active var user with name: ' + varName);
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
    
    
    private User[] findPartnerVarUserOfSubVar(Case theCase)
    {
        util.debug('inside of findPartnerVarUserOfSubVar....');

        
        
        //  do a massive query of all contact partner accounts
        //  scroll thru them all looking for the one that points to the case.account.var_account1__c
        //  there shouyld only be one, if there is more, shouldnt be, we open up sharing for all of those returned
        //  there is nothing on the contact record that denotes if the contact has an assoicated parenter user account,
        //  so the query has to be done at the user level
        if (allPartnerUsers == null)
        {
            util.debug('quering partner users now');
            // i am unable to figure out the user.contacts query so instad i will create m apping
            allPartnerUsers = [select id, name, profileid, profile.name, contactid, isactive
            
        //(select id, accountid, name, account.ownerid, account.Account_Classification__c, account.type from contacts where inactive__c = false)
               from User 
               where Profile.Name like '%Roadnet Partner%' and isActive = true and contactid != null ];
            util.debug('num of partner users found: ' + allPartnerUsers == null ? 0 : allPartnerUsers.size());
        }
        Set<id> contactIds = new Set<Id>();
        
        for (User singleUser : allPartnerUsers)
        {
            if (!contactIds.Contains(singleuser.contactid))
            {
                contactIds.Add(singleUser.ContactId);
            }
        }
        util.debug('finished making unqiuye set of contacts.  size  = ' + contactIds.size());
        
        List<Contact> contacts = [select id, accountid, account.var_account1__c, name, account.ownerid, account.Account_Classification__c, account.type from contact where id  in: contactIds AND inactive__c = false];
        util.debug('finished querying contacts of partner users: ' + contacts == null ? 0 : contacts.size());
        
        List<User> possibleVarUsersOfCase = new List<User>();
        //  now we have a listing of all roadnet partners AND there assoicated contact records, along with the account informaiton
        //  so we need to scroll thru each of the users (and the contacts) to see if any of the contacts point to the case.account.var_account1__c
        for (User singleUser : allPartnerUsers)
        {
            util.debug('looking at partner user: ' + u);
            List<Contact> contactsOfUser  = findContactsOfUser(singleUser.contactid, contacts);
            util.debug(' found this amount of contact records: ' + contactsOfUser == null ? 0 : contactsOfUser.size());
            
            for (Contact singleContact : contactsOfUser)
            {
                util.debug('singleContact = ' + singleContact);
                boolean isContactAccountVarAccount = singleContact.AccountId == theCase.Account.var_account1__c;
                boolean isContactAccountParentAccount = singleContact.AccountId == theCase.Account.Parentid; 
                
                if (isContactAccountVarAccount || isContactAccountParentAccount)
                {
                    util.debug('adding user: ' + singleUser + ' to list of var users');
                    possibleVarUsersOfCase.add(singleUser);
                }
                
            }
        }
        util.debug('num of possibleVarUsersOfCase = ' + possibleVarUsersOfCase.size());
        
        
        
        
        // now that we have all users, hopefully only one item, but possible to be more
        // we return the list and have the calling method assign sharing to that var
        return possibleVarUsersOfCase;
        
    }
    
    private List<Contact> findContactsOfUser(Id contactid, List<Contact> contacts)
    {
        List<Contact> contactsToReturn = new List<Contact>();
        for (Contact c : contacts)
        {
            if (c.id == contactId)
            {
                contactsToReturn.add(c);
            }
            
        }
        return contactsToReturn;
        
    }*/
    public class myException extends Exception{}
}