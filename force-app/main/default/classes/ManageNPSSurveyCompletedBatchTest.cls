@isTest
public class ManageNPSSurveyCompletedBatchTest {
    private static VistaAssetHelperUtil util = new VistaAssetHelperUtil();
	
	@testSetup
	static void SetupData() {
		TestUtils.defineCustomSettings();
	}
	
    static testMethod void myUnitTest() {
        Account acct = util.createAccount('Manage NPSSurvey Completed Test Account');
		Map<Integer, Integer> monthWaveMap = new Map<Integer, Integer>{1 =>3, 2=>4, 3=>5, 4=>6, 5=>1, 6=>2, 7=>3, 8=>4, 9=>5,10=>6, 11=>1, 12=>2};
        Integer nextMonth = date.today().month() + 1;
        String wave = String.valueOf(monthWaveMap.get(nextMonth));
        Contact con = new Contact(FirstName = 'FirstName', LastName = 'LastName', Title = 'Title', Email = 'testemail@email.com', AccountId = acct.Id, Inactive__c = FALSE, HasOptedOutOfEmail = FALSE, NPS_Wave__c = wave, NPS_Survey_Completed__c = TRUE);
        insert con;
        Test.startTest();
        Database.executeBatch(new ManageNPSSurveyCompletedBatch());
        Test.stopTest();
    }
}