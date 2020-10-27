/*********************************************************************************
Description:   Test Class for NetsuiteSyncAccountHelper
Author:    Joseph Barrameda
Date:      Oct 02, 2014
Note:      This class is referencing other components (NetsuiteSyncMockHttpResponseGen.cls,MockHttpResponseGeneratorFail.cls)  
**********************************************************************************/ 

@isTest(SeeAllData=true)
private class NetsuiteSyncAccountHelperTest {

    static testMethod void accountTest(){
        
        //Set mock
        Test.setMock(HttpCalloutMock.class, new NetsuiteSyncMockHttpResponseGen());
        //
        Test.startTest();
        
        //Get Account Record Type ID 
        Id oldCNRrecType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('T&L Sales Accounts').getRecordTypeId();
        
        //Insert incomplete details
        Account a = new Account();
        a.RecordTypeId = oldCNRrecType ;
        a.QWBS_Status__c = 'Active';
        a.Name = 'NS_test';
     // a.Company_Short_Name__c = 'NS';
        a.Account_Classification__c ='Customer';
        a.BillingStreet = '1st Street';
        a.BillingCity = 'Future';
        a.BillingCountry = 'Mexico';
        a.BillingPostalCode='12345';
        a.BillingState = 'AR';
        a.RFC_ID__c = 'RFC11111';
        a.CurrencyIsoCode  = 'USD';
     // a.Mailing_Street__c = '1st Street';
     // a.Mailing_City__c = 'Future';
     // a.Mailing_State_Province__c = 'AR';
     // a.Mailing_Country__c = 'Mexico';
        a.QWBS_Market__c = 'Enterprise';
        a.Segment__c  = 'Truckload';
        a.Territory__c = 'EWP6';
        insert a;     
        Set<Id> accIdList = new Set<Id>();
        accIdList.add(a.Id);
        if(accIdList.size()>0)
            NetsuiteSyncAccountHelper.postDataToNetsuite(accIdList);
        Test.stopTest();
    }    
    

    static testMethod void accountNegativeTest(){
        //Set mock
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorFail ());
        //
        Test.startTest();
        
        //Get Account Record Type ID 
        Id oldCNRrecType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('T&L Sales Accounts').getRecordTypeId();
        
        //Insert incomplete details
        Account a = new Account();
        a.RecordTypeId = oldCNRrecType ;
        a.QWBS_Status__c = 'Active';
        a.Name = 'NS_test Negative';
        a.CurrencyIsoCode  = 'USD';
        insert a;     
        Set<Id> accIdList = new Set<Id>();
        accIdList.add(a.Id);
        if(accIdList.size()>0)
            NetsuiteSyncAccountHelper.postDataToNetsuite(accIdList);
        Test.stopTest();
        
    }    

}