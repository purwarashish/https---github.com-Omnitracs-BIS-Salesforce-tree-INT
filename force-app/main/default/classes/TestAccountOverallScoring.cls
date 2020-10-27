/*********************************************************************************
* Name: TestAccountOverallScoring
* Created by Omnitracs {DateCreated 7/1/2016} 
----------------------------------------------------------------------------------
* Purpose/Methods:/ 
* This is used as test class of controller AccountOverallScoring
----------------------------------------------------------------------------------
* Unit Test: TestAccountOverallScoring
---------------------------------------------------------------------------------- 
* History:
* VERSION DEVELOPER NAME DATE DETAIL FEATURES
1.0 7/1/2016 INITIAL DEVELOPMENT
 
*********************************************************************************/

@isTest
private class TestAccountOverallScoring {
	public static VistaAssetHelperUtil util = new VistaAssetHelperUtil();
	@testSetup
	static void SetupData() {
		TestUtils.defineCustomSettings();
	}
	static testMethod void myUnitTest1(){
		/*TestScoringUtility.allAccountRecordTypesCS(); 
		TestScoringUtility.allAccountUtilCS();*/
		//Creating Account by calling createAccount method of TestScoringUtility
		Account acct = util.createAccount('Account Overall Scoring Test Account');
		//Creating Account_Scoring__c by calling createAccountScoring method of TestScoringUtility
		Account_Scoring__c obj = TestScoringUtility.createAccountScoring();
		obj.Account__c = acct.Id;
		insert obj;
		ApexPages.currentPage().getParameters().put('Id',acct.Id);
		AccountOverallScoring aos = new AccountOverallScoring(new ApexPages.StandardController(acct));
		aos.SelectedAccountScoringId = obj.Id;
		aos.ManualScoring();
		aos.DoSave();
		aos.DoCancel();
	}
}