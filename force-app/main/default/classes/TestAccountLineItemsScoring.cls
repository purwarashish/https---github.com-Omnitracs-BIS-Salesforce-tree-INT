/*********************************************************************************
* Name: TestAccountLineItemsScoring
* Created by Omnitracs {DateCreated 7/1/2016} 
----------------------------------------------------------------------------------
* Purpose/Methods:/ 
* This is used as test class of controller AccountLineItemsScoring
----------------------------------------------------------------------------------
* Unit Test: TestAccountLineItemsScoring
---------------------------------------------------------------------------------- 
* History:
* VERSION DEVELOPER NAME DATE DETAIL FEATURES
1.0 7/1/2016 INITIAL DEVELOPMENT
 
*********************************************************************************/

@isTest
private class TestAccountLineItemsScoring {
	public static VistaAssetHelperUtil util = new VistaAssetHelperUtil();
	@testSetup
	static void SetupData() {
		TestUtils.defineCustomSettings();
	}
	static testMethod void myUnitTest1(){
		/*TestScoringUtility.allAccountRecordTypesCS(); 
		TestScoringUtility.allAccountUtilCS();*/
		//Creating Account by calling createAccount method of TestScoringUtility
		Account acct = util.createAccount('Account LineItems Scoring Test Account');
		//Creating Account_Scoring__c by calling createAccountScoring method of TestScoringUtility
		Account_Scoring__c obj = TestScoringUtility.createAccountScoring();
		obj.Account__c = acct.Id;
		insert obj;
		ApexPages.currentPage().getParameters().put('Id',obj.Id);
		AccountLineItemsScoring aos = new AccountLineItemsScoring();
		aos.BackToAccount();
	}
}