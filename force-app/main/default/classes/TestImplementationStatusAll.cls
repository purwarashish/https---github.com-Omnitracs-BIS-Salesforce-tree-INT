/***********************************************************************************
Date: 11 Janaury 2011 
Author: Shruti Karn

Description:  Test class for trigger "ImplementationStatusAll"  on 
              Implementation_Status_Update__c on Object
************************************************************************************/
@isTest(SeeAllData=True)
private class TestImplementationStatusAll
{
    static testMethod void insertImplementationStatus(){
        Account newAccount = new Account(); 
        newAccount.Name = 'SFDC'; 
        newAccount.Type = 'Other'; 
        newAccount.BillingStreet = 'Test Address'; 
        newAccount.BillingCity = 'Test City'; 
        newAccount.BillingCountry = 'Test Country'; 
        newAccount.QWBS_Cust_ID__c = '4567';
        insert newAccount;
        Implementation_Status_Update__c newImplemetnationRec = new Implementation_Status_Update__c();
        newImplemetnationRec.Account__c = newAccount.Id;
        insert newImplemetnationRec;
        Implementation_Status_Update__c newImplemetnationRec1 = new Implementation_Status_Update__c();
        newImplemetnationRec1.Account__c = newAccount.Id;
        insert newImplemetnationRec1;
       
    }
}