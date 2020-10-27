/*******************************************************************************
 * File:  ViewVarHierarchyExtension.cls
 * Date:  Janurary 10th, 2009
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
public class ViewVarHierarchyExtension
{
    string varid;//holds the acount id of the var in this instacne of the class
    account tier1; //the var
    account theAccount;//the account the controller is assoicated with
    AccountStruct[] allAccountsInHierarchy;//list of rows for the table to display on teh vf page
    
    public ViewVarHierarchyExtension(apexpages.standardcontroller stdcontroller)
    {
        allAccountsInHierarchy=new list<AccountStruct>();
        theAccount=new Account();
        tier1=new Account();
        
        //query the account with the controllers id
        theAccount = [select id, name, sub_var_account__c, var_account1__c, type, industry, 
             owner.name from account where id=:stdcontroller.getId()];
        varid = findvar(theAccount);//determine the var assoicated with account of the controller
        
        tier1 = queryVar(varId);//  query the var for its fields
        
        querySubVarsAndAccounts(tier1);//  this is the meat and bones of this controller
    }
    
    public AccountStruct[] getallAccountsInHierarchy(){return allAccountsInHierarchy;}
    public Account getTheAccount(){return theAccount;}
    
    private void querySubVarsAndAccounts(Account varAccount)
    {
        system.assert(allAccountsInHierarchy != null);
        List<Account> customersOfVar = new List<Account>();
        List<Account> subVars = new List<Account>();
        List<Account> accountsOfSubVars = new List<Account>();
        List<Id> subVarIdList = new List<Id>();
        
        allAccountsInHierarchy.add(new AccountStruct(varAccount, 1) );//  add the var to the top of the list
        
        //  we first want to query all of the customers of the var alphabetcally, put them in the list as we get them BUT add them as
        //  tier 3 accounts so that their indentition is the same as sub var accounts
        try 
        {
            customersOfVar = [select id, name, sub_var_account__c, var_account1__c, type, industry, owner.name 
                from account where var_account1__c =: varAccount.id and 
                (type <> 'Customer - Inactive' and type <> 'Out of Business' and type <> 'Sub-VAR - Active')
                order by name];
        }
        catch(Exception e)
        {
            //  do nothing, this can be caused b no records being returned
        }
        
        //  now add all of the customers to the master list as tier 3 accounts
        for (Account singleCustomerAccount : customersOfVar)
        {
            allAccountsInHierarchy.add(new AccountStruct(singleCustomerAccount, 3));
        }
                
        try//  query all active subvars that point to the var
        {
            subVars = [select id, name, sub_var_account__c, var_account1__c, type, industry, owner.name 
                from account where var_account1__c =: varAccount.id and type = 'Sub-VAR - Active' order by name];
        }
        catch(Exception e)
        {
            //  do nothing, this can be caused by no records being returned
        }
        
        //  create a list of ids of the subvar accounts
        for (Account singleSubVar : subVars)
        {
            subVarIdList.add(singleSubVar.id);
        }
        
        if (subVarIdList.size() == 0)
        {
            return ;
        }
        
        //  using the list of subvarids, query all accounts that point to each subvar
        try
        {
            accountsOfSubVars =  [select id, name, sub_var_account__c, var_account1__c, type, industry, owner.name
                from account where Sub_Var_Account__c in: subVarIdList and (type <> 'Customer - Inactive' and type <> 'Out of Business') 
                order by name];
        }
        catch(Exception e)
        {
            //  do nothing
        }
        
        //  now we have a list of sub vars and accounts, we now do a for each and add the sub vars and accounts to the list
        //  we have to assume the accounts are still in ordered, 
        //  if they are not then we'll have to add some type of method that sorts them
        for (Account singleSubVar : subVars)
        {
            allAccountsInHierarchy.add(new AccountStruct(singleSubVar,2));
            List<Account> accountsOfSubVar = retrieveAccountsBelongingToSubVar(singleSubVar.id, accountsOfSubVars);
            for (Account singleAccountOfSubVar : accountsOfSubVar)
            {
                allAccountsInHierarchy.add(new AccountStruct(singleAccountOfSubVar, 3));
            }
        }
    }
    // done with this
        
    public string findVar(account theAccount)
    {
        string assumedvarId;
        //if the theaccount has a value in var account then thevar obviously is theaccount.var__c
        if (theaccount.var_account1__c!=null)
        {
            assumedVarId=theAccount.var_account1__c;
        }
        else if(theaccount.sub_var_account__c!=null)//if the accounts subvar is filled in, navigate to that account and see if it has a var
        {
            
            account tempaccount=[select id, name, var_account1__c, sub_var_account__c from account  where id=:theaccount.sub_var_account__c limit 1];
            if (tempaccount.var_account1__c!=null)
                assumedVarID=tempaccount.var_account1__c;
        }
        else assumedVarid=theaccount.id;//if the var still isn't found--we assume theaccount in contact is the var--pretty weak algo huh?
        return assumedVarid;
    
    }
    
    public static Account createTestAccount()
    {
        Account a = new Account();
        //  if this is set, crm fusion is throwing errors when trying to merge the accont.... i comented it out
        //  and getting errors that name needs to be set i'm going to see if we can generate random accounts names
        //  so whatever the merger is doing
        a.name = 'testAccount' + Math.roundtoLong(math.Random() * 100000.0);
        a.shippingCountry = 'United States';
        a.BillingCountry = 'United States';
        a.Territory__c = 'BlargTerr';
        a.Account_Class_1__c = 'BlargClass';
       
        
        //  populating these address fields for preventChangingOfLockedFields
        a.billingstreet = 'fake street';
        a.billingcity = 'fake city';
        a.billingstate = 'MD';
        a.BillingPostalCode = '21286';
        a.billingCountry = 'USA';
        a.shippingstreet = 'fake street';
        a.shippingcity = 'fake city';
        a.shippingcountry = 'USA';
        a.shippingPostalCode = '21286';
        a.Fleet_Size__c = 25;
        a.Segment__c = 'TL';
     // a.physical_street__c = 'fake street';
     // a.physical_city__c = 'fake city';
     // a.Physical_State_Province__c = 'MD';
     // a.Physical_zip_postal_code__c = '21286';
     // a.physical_Country__c = 'USA';
     // a.mailing_street__c = 'fake street';
     // a.mailing_city__c = 'fake city';
     // a.mailing_state_province__c = 'MD';
     // a.mailing_zip_postal_code__c = '21286';
     // a.mailing_Country__c = 'USA';
        Database.saveresult sr;
        a.recordtypeid = [select id from recordtype where sobjecttype = 'Account' and isactive = true limit 1].id;
        if(Test.isRunningTest()) {
            Database.DMLOptions dml = new Database.DMLOptions();
            dml.DuplicateRuleHeader.AllowSave = true; 
			sr = Database.insert(a, dml);
        } else {
            sr = database.insert(a);
        }
        if (sr.isSuccess())
        {
            a = [select id, name, sub_var_account__c, var_account1__c, type, industry, 
             owner.name from account where id =: sr.getId()];
        }
        else
        {
            a = null; 
        }
        return a;
    }
    
    public static Account createTestSubVarAccount(id varId)
    {
        Account a = new Account();
        a.name = 'test account';
        a.BillingCountry = a.ShippingCountry = 'Mexico';
        a.BillingStreet='Test Billing Street';
        a.BillingCity='Test Billing City';
        a.BillingState='Test Billing State';
        a.BillingPostalCode='00001';
        a.Fleet_Size__c= 25;
        a.Segment__c='TL';
        a.var_account1__c = varId;
        a.type = 'Sub-VAR - Active';
        Database.DMLOptions dml = new Database.DMLOptions();
        dml.DuplicateRuleHeader.AllowSave = true; 
        Database.SaveResult sr;
        if(Test.isrunningtest()) {
            sr = Database.insert(a, dml);
        } else {
            sr = database.insert(a);
        }
        if (sr.isSuccess())
        {
            a= [select id, name, var_account1__c  from account where id =: sr.id limit 1];
        }
        
        return a;
    }
    
    public static Account createTestAccountOfSubVarAccount(Id subVarAccountId)
    {
        Account a = new Account();
        a.name = 'test account';
        a.BillingCountry = a.ShippingCountry = 'Mexico';
        a.BillingStreet='Test Billing Street';
        a.BillingCity='Test Billing City';
        a.BillingState='Test Billing State';
        a.BillingPostalCode='00001';
        a.Fleet_Size__c= 25;
        a.Segment__c='TL';
        a.sub_var_account__c = subVarAccountId;
        a.type = 'Customer - Active';
        //a.WEb_Password__c = 'fakePasrd';
        a.Account_Class_1__c = 'BlargClass';
        
        a.Territory__c = 'TerrClass';
        
        database.saveresult sr;
        if(Test.isRunningTest()) {
            Database.DMLOptions dml = new Database.DMLOptions();
            dml.DuplicateRuleHeader.AllowSave = true; 
			sr = Database.insert(a, dml);
        } else {
            sr = database.insert(a);
        }
        
        if (sr.isSuccess())
        {
            a= [select id, name, var_account1__c, sub_var_account__c  from account where id =: sr.id limit 1];
        }
        
        return a;
    }

    private static Account queryVar(Id varAccountId)
    {
        system.assertNotEquals(null, varAccountId);
        return [select id, name, sub_var_account__c, var_account1__c, type, industry, 
                owner.name from account where id =: varAccountId];
    }
    
    private static List<Account> retrieveAccountsBelongingToSubVar(Id subVarId, List<Account> accountsOfSubVars)
    {
        system.assertNotEquals(null, subVarId);
        system.assertNotEquals(null, accountsOfSubVars);
        List <account> subVarsAccounts = new List<Account>();
        for (Account a : accountsOfSubVars)
        {
            if (a.sub_Var_Account__c == subvarId)
            {
                subVarsAccounts.add(a);
            }
        }
        
        //  if the list is not sorted alphabetcially arlready we can add a sort method
        return subVarsAccounts;
    }
    
    public class AccountStruct
    {
        //this class exist as a holder for the account information.  the vf page displays each object of this class in a table
        string id;
        string Name;
        string accountType;
        string physicalcountry;
        string owner;
        string industry;
        string spaceForIndentation;
        
        public AccountStruct(Account a, integer tier)
        {
            //  the integer specifies the tier the account belongs in, there are three tiers, for each tier the amount of
            //  indentation increases to give the list more of a strcutred look
            if (tier==1)
                spaceForIndentation='';
            else if (tier==2)
                spaceForIndentation='&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp';
            else if (tier==3)
                spaceForIndentation='&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp';
            id=a.id;
            name=a.name;
            if (a.type!=null)   accounttype=a.type;
            else accounttype='';
         /* if (a.physical_country__c!=null)    physicalcountry=a.physical_country__c;
            else physicalcountry=''; */
            if (a.industry!=null)   industry=a.industry;
            else industry='';
                        
            owner=a.owner.name;     
        }
        public string  getid(){return id;}
        public string getname(){return Name;}
        public string getaccountType(){return accountType;}
        public string getphysicalCountry(){return physicalCountry;}
        public string getOwner(){return Owner;}
        public string getIndustry(){return Industry;}
        public string getspaceForIndentation(){return spaceForIndentation;}
    }
    
}