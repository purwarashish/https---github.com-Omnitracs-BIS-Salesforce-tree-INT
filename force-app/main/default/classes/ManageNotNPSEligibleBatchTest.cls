@isTest
public class ManageNotNPSEligibleBatchTest {
	
	@testSetup
	static void SetupData() {
		TestUtils.defineCustomSettings();
	}
	
	static testMethod void myUnitTest() {
		Id nonNPSRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Other').getRecordTypeId();
		Account acct = new Account(Name = 'Test Account Manage NotNPSEligible Batch', RecordTypeId = nonNPSRecTypeId, QWBS_Market__c = 'Channel', Primary_Business_Unit__c = 'Omnitracs Domestic', QWBS_Cust_ID__c = '12345', Segment__c = 'TL', Fleet_Size__c = 9,  Phone = '(555) 555-5555', BillingStreet = 'Harwood St', BillingCity = 'Dallas', BillingState = 'TX', BillingPostalCode = '75201', BillingCountry = 'USA', Account_Status__c = 'Active', QWBS_Status__c = 'Contract Customer', NPS_Not_Required__c = FALSE);
		insert acct;
		Test.startTest();
		Database.executeBatch(new ManageNotNPSEligibleBatch());
        Test.stopTest();
    }
}