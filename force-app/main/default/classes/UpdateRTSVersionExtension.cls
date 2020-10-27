/*******************************************************************************
 * File:  UpdateRTSVersionExtension.cls
 * Date:  October 19th, 2009
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
public with sharing class UpdateRTSVersionExtension
{
    private Account account;
    
    public UpdateRTSVersionExtension(ApexPages.standardController stdController)
    {
        queryAccount(stdController.getId());
        showUpdateSuccessfulSEction = false;
    }
    
    public void setAccount(Account a){account = a;}
    public Account getAccount(){return account;} 
    public boolean showUpdateSuccessfulSEction{get;set;}
    
    
    public PageReference returnToAccount()
    {
        PageReference pr = new PageReference('/' + account.id);
        pr.setRedirect(true);
        return pr;
    }
        
    public boolean isBlankOrNone(string theString)
    {
        return Util.isBlank(theString) || theString == pl.none;
    }
    public PageReference updateRTSInstalledVersion()
    {
        if (isBlankOrNone(account.rts_installed_version__c)) 
        {
            account.RTS_INstalled_version__c.AddError('Please select an RTS Installed Version');
            return null;
        }
         
        
        List<Account> singleAccount = new List<Account>();
        if (!isNullOrBlank(account.rts_installed_version__c))
        {
            singleAccount.add(account);
            
            try
            {
               update singleAccount;//  maeke sure the account in context is updated
            }
            catch(Exception e)
            {
                account.addError('Failed update the account\'s RTS Installed version due to ' + e.getMessage());
                return null;
            }
            
            try
            {
                system.assertNotEquals(null, singleAccount[0].name);
                UpdateChildAccountRTSInstalledVersion(singleAccount);
            }
            catch(Exception e)
            {
               account.addError('Failed to update RTS installed version for account\'s children  due to: ' + e.getMessage());
               return null; 
            }
            
            queryAccount(account.Id);
            showUpdateSuccessfulSEction = true;
            return null;
        }
        else
        {
           account.addError('Please specify an RTS Installed version.');
           return null;
        }
        
    }
    public static void updateChildAccountRTSInstalledVersion(List<Account> parentAccounts)
    {
        system.assertNotEquals(null, parentAccounts);
        
        util.debug('inside of updatechildaccount rts installed version method. num of parent accounts passed into method = ' +
            parentAccounts.size());
        
        Account[] accountsToUpdateRTSInstallVersion = new List<Account>();
        Account[] childAccounts = [select id, Name, type, /*Web_Password__c,*/ RTS_Installed_Version__c,  Database_Platform__c, 
            inherit_parent_s_products__c, parentid 
            from Account where parentId in: parentAccounts AND inherit_Parent_s_products__c = true];
        
        util.debug('finished querying child accounts.  num of parent accounts = ' + parentAccounts.size() + 
            ' num of child accounts = ' + childAccounts.size());
        
        integer numberOfSoqlQueriesLeftAvailable = Limits.getLimitQueries() - Limits.getQueries();
        util.debug('numberOfSoqlQueriesLeftAvailable = ' + numberOfSoqlQueriesLeftAvailable);
        //  if the num of child accounts is greater than the number of queries we have availble, we need to gracefully
        //  let the user know that this child update isnt going to work
        
        //  i think there's a couple things here that can be done to make this more effcient... firstly
        //  we shouldnt have a query inside of a for loop never, since we have all the accounts and their id
        //  we chould be able to mass query all child accounts.  that way we know exactly how many accounts are in the trigger
        //  and how many will be processed.. if we make this simple change.... i think we eliminate the too many query error
        //  the worst error i foresee happening is too many query rows returned... was able to confirm the query change got rid
        //  of the error.  i've tested with uni-first and anhueser busch
        for (Account a : parentAccounts)
        {
            util.debug('working on parent account with name ' + a.name);
            List<Account> tempChildAccounts = findChildAccounts(a.id, childAccounts);
            
            util.debug('found ' + tempChildAccounts.size() + ' child accoutns that belong to parent account with name ' + a.name);
            
            for (Account childAccount : tempChildAccounts)
            {
                //  if inherit parent products = true, assign the rts installed version
                system.assertEquals(true, childAccount.inherit_parent_s_products__c);
                util.debug('child account installed version = ' + 
                    childAccount.RTS_Installed_Version__c + ' parent account installed version = ' + a.RTS_Installed_Version__c);
                childAccount.RTS_Installed_Version__c = a.RTS_Installed_Version__c;
                childAccount.Database_PLatform__c = a.Database_Platform__c;
                accountsToUpdateRTSInstallVersion.add(childAccount);//  add it to the list of accounts to update
            }
        }
        
        util.debug('there are ' + accountsToUpdateRTSInstallVersion.size() + ' child accounts that will be updated.  making update call now');
        update accountsToUpdateRTSInstallVersion;
       
    }
    private static List<Account> findChildAccounts(Id parentId, List<Account> childAccounts)
    {
        List<Account> childAccountsToReturn = new List<Account>();
        for (Account a : childAccounts)
        {
            if (parentId == a.parentid)
            {
                childAccountsToReturn.add(a);
            }
        }
        
        return childAccountsToReturn;
    }
    private void queryAccount(Id accountId)
    {
        system.assertNOtEquals(null, accountId);
        
        account = [ select id, name,rts_installed_version__c, parentid, database_platform__c 
            from account where id =: accountId ];
    }
   
    public static ApexPages.StandardController generateController(Account a)
    {
        pagereference pageRef=new pagereference('Page.OrderFileGenerationPage');
        test.setcurrentpage(pageRef);
        //declare apexpages.standardcontroller so that we can pass it into this class's constructor
        return new ApexPages.standardController(a);
    }
    
    @testvisible private boolean isNullOrBlank(string str)
    {
        if (str == null)
        {
            return true;
        }
        else if (str.length() == 0)
        {
            return true;
        }
        else
        {
            return false;
        }
    }

    public class myException extends Exception{}
}