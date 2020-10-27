@isTest
public class ClearNonNPSAccountsWaveBatchTest {
	
	@testSetup
	static void SetupData() {
		TestUtils.defineCustomSettings();
	}
	
	static testMethod void myUnitTest() {
		Account acct = new Account(Name = 'Test Account Clear Non NPS', QWBS_Market__c = 'Channel', Primary_Business_Unit__c = 'Omnitracs Domestic', QWBS_Cust_ID__c = '12345', Segment__c = 'TL', Phone = '(555) 555-5555', BillingStreet = 'Harwood St', BillingCity = 'Dallas', BillingState = 'TX', BillingPostalCode = '75201', BillingCountry = 'USA', Account_Status__c = 'Active', Fleet_Size__c = 10, QWBS_Status__c = 'Contract Customer', NPS_Not_Required__c = TRUE);
		insert acct;
		Contact con = new Contact(FirstName = 'FirstName', LastName = 'LastName', Title = 'Title', Email = 'testemail@email.com', AccountId = acct.Id, Inactive__c = FALSE, Survey_Email_Opt_Out__c = FALSE, NPS_Wave__c = 'OTC 1');
		insert con;
		Test.startTest();
		Database.executeBatch(new ClearNonNPSAccountsWaveBatch());
        Test.stopTest();
    }
}