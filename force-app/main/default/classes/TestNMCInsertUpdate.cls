/*********************************************************************
Name    : TestNMCInsertUpdate
Author  : Shruti Karn
Date    : 13 December 2010

Usage   : This test method consolidates all the other test methods written to test triggers
         on NMC Object
CR # 25074    
Dependencies : none

*********************************************************************/
@isTest(SeeAllData=True)
private class TestNMCInsertUpdate {
    static testmethod void TestConvertNMCNametoUpper () {
        test.startTest();
        NMC_Account__c nmcacct = new NMC_Account__c(Name='Test NMC Acct', NMC_Account_Name__c = 'Test NMC Name',NMC_Account__c='123');
        account acct1 = new account(QWBS_Market__c = 'T&L Eastern Region', Name = 'My Test',
            BillingStreet = '123 Main', BillingCity = 'San Diego', BillingState = 'CA', BillingCountry = 'USA',QWBS_Cust_ID__c='12101986',RFC_ID__c='29051986');
        insert acct1;
        account acct2 = new account(QWBS_Market__c = 'T&L Eastern Region', Name = 'My Test',
            BillingStreet = '123 Main', BillingCity = 'San Diego', BillingState = 'CA', BillingCountry = 'USA');
        insert acct2;
        nmcacct.account__c = acct1.id;
       
        insert nmcacct;
        nmcacct.account__c = acct2.id;
        update nmcacct;
        nmcacct.account__c = null;
        update nmcacct;
        nmcacct.account__c = acct2.id;
        update nmcacct;

        test.stopTest();
        //Modified By Shruti Karn for CR# 22542
        Case newCase = new Case();
        newCase.AccountId = nmcacct.account__c;
        newCase.NMC_Account_Number__c = nmcacct.NMC_Account__c;
        insert newCase;
        
        nmcacct.Name = 'Test123';
        
        update nmcacct;
        nmcacct.Name = '';
        nmcacct.NMC_Account_Name__c  = '';
        
        try{
        update nmcacct;
        }
        
        catch(Exception e){
        System.assert( e.getMessage().contains('Update failed. First exception on row 0 with id '+nmcacct.Id+'; first error: FIELD_CUSTOM_VALIDATION_EXCEPTION, NMC Account Name / Number cannot be modified. Please press Cancel to cancel your changes.'),e.getMessage() );
        }

    }
}