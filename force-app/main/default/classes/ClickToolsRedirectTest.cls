/*
*    Author: JBarrameda
*    Date:    5-NOV-2014
*    Description: Test class for ClickToolsRedirect page
*/

@isTest(seeAllData=true)
private class ClickToolsRedirectTest {
    
    static testMethod void testCase(){
        
        //Set mock
        Test.setMock(HttpCalloutMock.class, new NetsuiteSyncMockHttpResponseGen());
        //
        Test.startTest();
        Id oldCNRrecType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Old CNR Sales').getRecordTypeId();
        
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
        a.Ranking__c = 'Regional';
        a.RFC_ID__c = 'RFC11111';
    //  a.District__c = 'Central';
        a.CurrencyIsoCode  = 'USD';
    //  a.Mailing_Street__c = '1st Street';
    //  a.Mailing_City__c = 'Future';
    //  a.Mailing_State_Province__c = 'AR';
    //  a.Mailing_Country__c = 'Mexico';
        insert a;     
        test.stopTest();
        
        Id CNRrecType = Schema.SObjectType.Case.getRecordTypeInfosByName().get('CNR').getRecordTypeId();
        
        //Create a Case
        Case c=new Case();
        c.CurrencyISOCode = 'USD';
        c.Type = 'Other Applications';
        c.Subject= 'Test Case Scenario';
        c.Description = 'This is just a test case scenario';
 
        c.Business_Unit__c = 'Roadnet';
        c.AccountId = a.id;
        
        c.Priority = '1-Critical';
        c.Status = 'Open';
        c.Substatus__c  = 'In Progress';
        c.Origin = 'Phone';        
        insert c;
        
        //PageReference pageRef = Page.ClickToolsRedirect;
        PageReference pageRef = new PageReference('/apex/ClickToolsRedirect?CField4=' + c.Id + '&CField5=beta&CField3=gamma');
        Test.setCurrentPage(pageRef);        
        ClickToolsRedirectController ctd1=new ClickToolsRedirectController();
        ctd1.redirect();
        
        //Update Business Unit 
        c.Business_Unit__c = 'Sylectus';
        update c;
        Test.setCurrentPage(pageRef);        
        ClickToolsRedirectController ctd2=new ClickToolsRedirectController();
        ctd2.redirect();
        
        //Update Business Unit
        c.Business_Unit__c = 'Omnitracs MX';
        update c;
        Test.setCurrentPage(pageRef);        
        ClickToolsRedirectController ctd3=new ClickToolsRedirectController();
        ctd3.redirect();
        
        //Update Business Unit
        c.Business_Unit__c = 'Omnitracs US';
        update c;
        Test.setCurrentPage(pageRef);        
        ClickToolsRedirectController ctd4=new ClickToolsRedirectController();
        ctd4.redirect();
    }

}