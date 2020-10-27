@isTest
private class SurveyUtilsTest {
	private static VistaAssetHelperUtil util = new VistaAssetHelperUtil();
	
	@testSetup
	static void SetupData() {
		TestUtils.defineCustomSettings();
	}
	static testMethod void myUnitTest() {
		
		Account acct = util.createAccount('SurveyUtils Test Account');
        Contact con = TestUtils.getContact(acct, 'Test Contact');
		insert con;
		Case caseRec = TestUtils.getCase(acct, con);
		insert caseRec;
		
		Test.startTest();
		Survey__c newSurvey = new Survey__c(Quality_of_Service_Provided__c = 'Very Satisfied', Timeliness_of_service_provided__c = 'Very Satisfied', Overall_Service_Experience__c = 'Very Satisfied', 
		Analyst_s_Technical_Skills_Knowledge__c = 'Very Satisfied', Courtesy_and_Professionalism_of_analyst__c = 'Very Satisfied', Survey_Type__c = 'CSAT', Name = 'a2i1T0000007QzF', Account__c = acct.Id, Contact_survey_lookup__c = con.Id, Case__c = caseRec.Id);
		insert newSurvey;
		caseRec.Not_CSAT_Eligible__c = TRUE;
		update caseRec;
		Test.stopTest();
	}
}