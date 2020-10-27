/*********************************************************************************
Program:   Test Class for NetsuiteSyncContactHelper
Author:    Joseph Barrameda
Date:      Oct 16, 2014
**********************************************************************************/ 

@isTest(SeeAllData=true)
private class NetsuiteSyncContactHelperTest {

    static testMethod void contactTest(){
        
        //Set mock
        Test.setMock(HttpCalloutMock.class, new NetsuiteSyncMockHttpResponseGen());
        //Start Test
        Test.startTest();
        
        //Get Account and Contact Record Type ID 
        Id tlSalesRecordType = SystemIds__c.getInstance().RecordTypeId_Account_TLSales__c;
        
        //Insert complete details
        Account a = new Account();
        a.RecordTypeId = tlSalesRecordType;
        a.QWBS_Status__c = 'Active';
        a.Name = 'NS_test';
    //  a.Company_Short_Name__c = 'NS';
        a.Account_Classification__c ='Customer';
        a.BillingStreet = '1st Street';
        a.BillingCity = 'Future';
        a.BillingCountry = 'Mexico';
        a.BillingPostalCode='12345';
        a.BillingState = 'AR';
        a.Ranking__c = 'Regional';
        a.RFC_ID__c = 'RFC11111';
     // a.District__c = 'Central';
        a.CurrencyIsoCode  = 'USD';
    //  a.Mailing_Street__c = '1st Street';
    //  a.Mailing_City__c = 'Future';
    //  a.Mailing_State_Province__c = 'AR';
    //  a.Mailing_Country__c = 'Mexico';
        a.Primary_Business_Unit__c = 'Omnitracs Mexico';
        a.Segment__c = 'Services';
        insert a;
        Set<Id> accIdList = new Set<Id>();
        accIdList.add(a.Id);
        if(accIdList.size()>0)
            NetsuiteSyncAccountHelper.postDataToNetsuite(accIdList);
        
        Contact c=new Contact();
        //c.RecordTypeId = oldCNRrecTypeForContact; 
        c.FirstName = 'Test John';
        c.LastName ='Test Doe';
        c.AccountId = a.Id;
     // c.Role__c = 'Legal Representative';
        insert c;
                
        //Stop Test
        Test.stopTest();
        
    }
    
    static testMethod void contactNegativeTest(){
        
        //Set mock
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorFail ());
        //Start Test
        Test.startTest();
        
        //Get Account Record Type ID 
        Id oldCNRrecType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('T&L Sales Accounts').getRecordTypeId();
        Id oldCNRrecTypeForContact = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Old CNR').getRecordTypeId();
        Id tlSalesRecordType = SystemIds__c.getInstance().RecordTypeId_Account_TLSales__c;
        
        //Insert incomplete details
        Account a = new Account();
        a.RecordTypeId = tlSalesRecordType ;
        a.QWBS_Status__c = 'Active';
        a.Name = 'NS_test Negative';
        a.CurrencyIsoCode  = 'USD';
        a.Segment__c = 'Services';
        insert a;   
        Set<Id> accIdList = new Set<Id>();
        accIdList.add(a.Id);
        if(accIdList.size()>0)
            NetsuiteSyncAccountHelper.postDataToNetsuite(accIdList);
        
        Contact c=new Contact();
        c.RecordTypeId = oldCNRrecTypeForContact; 
        c.FirstName = 'Test John';
        c.LastName ='Test Doe';
        c.AccountId = a.Id;
     // c.Role__c = 'Legal Representative';
        insert c;
                
        //Stop Test
        Test.stopTest();
        
    }    
    

}