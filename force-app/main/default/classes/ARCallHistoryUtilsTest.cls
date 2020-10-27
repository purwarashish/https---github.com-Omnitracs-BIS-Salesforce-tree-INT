@isTest
public class ARCallHistoryUtilsTest {
    private static VistaAssetHelperUtil util = new VistaAssetHelperUtil();
	
	@testSetup
	static void SetupData() {
		TestUtils.defineCustomSettings();
	}
	
	public static testMethod void TestCallAR(){
        Account acct = util.createAccount('SurveyUtils Test Account');
        List<AR_Call_History__c> ARCallInsertList = new List<AR_Call_History__c>();
        AR_Call_History__c ARCallInsert = new AR_Call_History__c();
        ARCallInsert.Account__c = acct.Id;
        ARCallInsert.Call_Type__c = 'Outbound';
        ARCallInsert.Outbound_Type__c = 'Follow-up';
        ARCallInsert.Subject__c = 'Test Subject';
        ARCallInsert.Subject_Details__c = 'Subject - Testing';
        ARCallInsert.Call_Details__c = 'Email Body - Testing';
        ARCallInsertList.add(ARCallInsert);
		Test.startTest();
		Integer emailcount = Limits.getEmailInvocations();
        insert ARCallInsertList;
        System.assertNotEquals(emailcount, Limits.getEmailInvocations());
        Test.stopTest();
    }
}