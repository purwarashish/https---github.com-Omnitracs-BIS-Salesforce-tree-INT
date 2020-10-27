/*******************************************************************************
* File:  CaseShareForVarRoadnet.cls
* Date:  Feburary 2, 2015
* Author:  Joseph Hutchins
*
* The use, disclosure, reproduction, modification, transfer, or transmittal of
* this work for any purpose in any form or by any means without the written 
 * permission of United Parcel Service is strictly prohibited.
*
* Confidential, unpublished property of United Parcel Service.
* Use and distribution limited solely to authorized personnel.
*
* Copyright 2015, UPS Logistics Technologies, Inc.  All rights reserved.
*  *******************************************************************************/
public class CaseShareForVarRoadnet
{
    private List<Case> roadnetCases{get;set;}
    private List<Case> casesRequeried{get;set;}
    private List<Case> casesToCreateSharingRulesFor{get;set;}
    private List<CaseShare> caseSharingRulesToCreate{get;set;}
    private List<Contact> allActiveContactsOfVarAccounts{get;set;}
    List<User> m_allRoadnetPartnerUsers;
    List<User> allRoadnetPartnerUsers
    {
      get
      {
              if(m_allRoadnetPartnerUsers == null)
              {
                  m_allRoadnetPartnerUsers = [select id, name, contactid, Var_Name__c from User where profile.name like '%Roadnet Partner%' and isactive = true];
              }
              return m_allRoadnetPartnerUsers;
      }
    }
    
    public static boolean hasRunBefore = false;//  to prevent the case insert and update trigger to call this twice when case is being inserted
      
    //  so what we want this class to do is handle all of the logic in creating sharing for var/subvar cases
    //  it should have a main method whose job is to batch process cases
    public void CreateCustomSharingForVars(List<Case> triggerCases)
    {        
        //  what we are doing now is seeing is creating sharing rules for all active contacts at the case.account.var_account__c
        //  so that all contacts/users at that level can see/edit the cases... 
                
        roadnetCases = new List<Case>();
        casesToCreateSharingRulesFor = new List<Case>();
        caseSharingRulesToCreate = new List<CaseShare>();
        
        for(Case c : triggerCases)
        {
            if(c.Business_Unit__c == 'Roadnet')
            {
                roadnetCases.Add(c);
            }
        }
        
        if(roadnetCases.size() == 0)
        {
            return ;
        }
        //  so high level, requery the cases
        casesRequeried = [select id, casenumber, contactid, accountid, ownerid, contact.name, account.name, account.active_partner_account__c, account.Var_Account1__c, 
            account.Var_Account1__r.Name, account.parentid, account.parent.name, account.parent.active_partner_account__c, account.parent.var_account1__c, owner.name, 
            owner.profile.name, account.ownerid, account.owner.name, account.owner.profile.name, account.parent.ownerid,
            account.parent.owner.name, account.parent.owner.profile.name from Case where id in: roadnetCases];

        //  determine if case is var/subvar
        for(Case singleCase : casesRequeried)
        {
            //  the bulk of the logic should go here, well at least half of the bulk of the logic
            if(isCaseConnectedToVar(singleCase))
            {
               system.debug(singleCase.caseNumber + ' is connected to a var account');
               casesToCreateSharingRulesFor.add(singleCase);
            }
        }
        
        if(casesToCreateSharingRulesFor.size() == 0)
        {
            return ;
        }
        
        //  since we will probably have to create case shares for at least on of the cases passed in, we will need to prequery the contactsoftheaccounts
        //  just in case we have to do the 3rd check when looking for the var
        queryAllContactOfCaseAccountVarAccount(casesToCreateSharingRulesFor);
        
        for(Case singleCase : casesToCreateSharingRulesFor)
        {
            List<User> partnerUsersOfVarAccount = findVarsOfCasesAccount(singleCase);

            if(partnerUsersOfVarAccount != null && partnerUsersOfVarAccount.size() > 0)
            {               
                for (User u : partnerUsersOfVarAccount)
                {
                    system.debug('creating case share for partner user: ' + u.name);
                    CaseShare varCaseShare = new CaseShare();
                    varCaseShare.CaseId = singleCase.id;
                    varCaseShare.UserOrGroupId = u.id;
                    varCaseShare.CaseAccessLevel = 'edit';
                    
                    caseSharingRulesToCreate.Add(varCaseShare);
                }
            }
            else
            {
                system.debug('could not find any vars for caseNumber: ' + singleCase.CaseNumber + ' and account: ' + (singleCase.AccountId != null ? singleCase.Account.name : 'No Account Assoicated With Case'));
            }
        }
        
        if(caseSharingRulesToCreate.size() == 0)
        {
            return ;
        }
        
        Database.SaveResult[] saveResults = database.insert(caseSharingRulesToCreate, false);
        for(database.saveResult sr : saveResults)
        {
            if(!sr.isSuccess())
            {
                 Database.Error err = sr.getErrors()[0];

                 // Check if the error is related to trival access level.
                 // Access levels equal or more permissive than the object's default 
                 // access level are not allowed. 
                 // These sharing records are not required and thus an insert exception is acceptable. 
                if(err.getStatusCode() == StatusCode.FIELD_FILTER_VALIDATION_EXCEPTION  &&  err.getMessage().contains('AccessLevel'))
                {
                    system.debug('found expected error code, case sharing rule successul');
                }
                else
                {
                    system.debug('error occured: ' + err.getMessage());
                }                                                       
            }
        }             
    }
    
    private boolean isCaseConnectedToVar(Case theCase)
    {
        //  we have a new check that we can do, since we will eventually have the var account field popoulated for all subvars we want
        //  the account to have sharing rules created for, we ncan that field also
        return (theCase.AccountId != null && theCase.Account.Var_Account1__c != null);
            
    }
    
    private void queryAllContactOfCaseAccountVarAccount(List<Case> cases)
    {
        //  we need to get a uniqye list of VAR ACCOUNT IDs so we can query the contacts of the VAR ACCOUNT
        set<id> uniqueVarAccountIds = new Set<ID>();
        for(Case c : cases)
        {
            uniqueVarAccountIds.add(c.Account.Var_Account1__c);
        }
        if(uniqueVarAccountIds.Size() > 0)
        {
            allActiveContactsOfVarAccounts = [select id, name, accountid from Contact where Accountid in: uniqueVarAccountIds and inactive__c = false];
            system.debug('query for allActiveContactsOfVarAccounts is complete.  num returned: ' + (allActiveContactsOfVarAccounts == null ? 0 : allActiveContactsOfVarAccounts.size()));
        }
    }
    
    private List<User> findVarsOfCasesAccount(Case theCase)
    {
        List<User> varsToReturn = new List<User>();
        List<Contact> contactsOfCasesVarAccount = new List<Contact>();
        
        //  the case.account.var_account should contain a value
        //  if it does, we need to query all of the contacts of that case
        //  and use those contacts to get the partner user records of those cases
        //  the contacts were already prequeried we just need to pull them out of the list
        
        for(Contact c : allActiveContactsOfVarAccounts)
        {
            if(c.AccountId == theCase.Account.Var_Account1__c)
            {
                contactsOfCasesVarAccount.add(c);
            }
        }
        //  now that we have all of the contacts of the case.account.var acount, we will look for matching
        //  parnter user records and return them
        for(User singleUser :allRoadnetPartnerUsers)
        {
            for(Contact singleContact : contactsOfCasesVarAccount)
            {
                if(singleContact.id == singleUser.contactid)
                {
                    varsToReturn.add(singleUser);
                }
            }
        }
        return varsToReturn;               
    }
}