@isTest
public class AutoWaveAssignmentBatchTest {
    
    @testSetup
    static void SetupData() {
        TestUtils.defineCustomSettings();
    }
    
    static testMethod void myUnitTest() {
        Account acct = new Account(Name = 'Test Account Auto Wave Assignment', QWBS_Market__c = 'Channel', Primary_Business_Unit__c = 'Omnitracs Domestic', QWBS_Cust_ID__c = '12345', Segment__c = 'TL', Phone = '(555) 555-5555', BillingStreet = 'Harwood St', NPS_Not_Required__c = FALSE, BillingCity = 'Dallas', BillingState = 'TX', BillingPostalCode = '75201', BillingCountry = 'USA', Account_Status__c = 'Active', Fleet_Size__c = 10, QWBS_Status__c = 'Contract Customer');
        insert acct;
        Contact con = new Contact(FirstName = 'FirstName', LastName = 'LastName Auto', Title = 'Title', Email = 'testemailauto@email.com', AccountId = acct.Id, Inactive__c = FALSE, Survey_Email_Opt_Out__c = FALSE, Notification_Type__c = 'NPS');
        insert con;
        Test.startTest();
        Database.executeBatch(new AutoWaveAssignmentBatch());
        Test.stopTest();
    }
}