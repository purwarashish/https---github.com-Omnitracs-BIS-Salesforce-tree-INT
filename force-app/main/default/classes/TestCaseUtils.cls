/*******************************************************************************
Date    : 13 September 2010
Author  : David Ragsdale
Overview: Test Class for CaseUtils...  
   Utils are fired from CaseUpdateHourForReport trigger

*******************************************************************************/
@isTest(SeeAllData=True)
private class TestCaseUtils {

    /* commented by Arindam Laik, as we have consolidated all Case related test class into one
    static testMethod void singleUnitTest() {
        
        account acct1 = new account(QWBS_Market__c = 'T&L Eastern Region', Name = 'My Test',            BillingStreet = '123 Main', BillingCity = 'San Diego', BillingState = 'CA', BillingCountry = 'USA',QWBS_Cust_ID__c='12101986',RFC_ID__c='29051986');        
        insert acct1;
        
        Case CaseNew = new Case();
        CaseNew.Status = 'Open';
        CaseNew.Substatus__c ='In Progress';
        CaseNew.AccountId = acct1.Id;
        insert CaseNew; 
        
        CaseNew.status = 'Pending';
        update CaseNew;   
        
    }*/
}