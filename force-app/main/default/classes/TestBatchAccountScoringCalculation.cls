@isTest
private class TestBatchAccountScoringCalculation {
	public static VistaAssetHelperUtil util = new VistaAssetHelperUtil();
	@testSetup
	static void SetupData() {
		TestUtils.defineCustomSettings();
	}
    static void createTestData(){
        
        /*TestScoringUtility.allAccountRecordTypesCS(); 
        TestScoringUtility.allAccountUtilCS();*/
        
        //Creating Account by calling createAccount method of TestScoringUtility 
        Account a = util.createAccount('Batch Scoring Calculation Test Account');
        a.customer_health_nps_score__c = 5;
        a.customer_health_avg_trans_surveys__c = 500;
        update a;
        
        //Creating Scoring_Model__c by calling createScoringModel method of TestScoringUtility 
        Scoring_Model__c sm = TestScoringUtility.createScoringModel();
        
        //Creating another Scoring_Model__c by calling createScoringModel method of TestScoringUtility
        Scoring_Model__c sm2 = TestScoringUtility.createScoringModel();
        
        //Creating Scoring_Item__c by calling createScoringItem method of TestScoringUtility
        Scoring_Item__c si = TestScoringUtility.createScoringItem();
        si.Scoring_Field_API_Name__c =  'customer_health_nps_score__c';
        si.Scoring_Model__c = sm.Id;
        insert si;
        
        
        //Creating third Scoring_Item__c by calling createScoringItem method of TestScoringUtility
        Scoring_Item__c si3 = TestScoringUtility.createScoringItem();
        si3.Scoring_Field_API_Name__c =  'customer_health_avg_trans_surveys__c';
        si3.Scoring_Model__c = sm2.Id;
        insert si3;
        
        //Creating Scoring_Subscription__c object
        Scoring_Subscription__c ss = new Scoring_Subscription__c();
        ss.Scoring_Model__c = sm.Id;
        ss.Account__c = a.id;
        insert ss;
        
        //Creating second Scoring_Subscription__c object
        Scoring_Subscription__c ss2 = new Scoring_Subscription__c();
        ss2.Scoring_Model__c = sm2.Id;
        ss2.Account__c = a.id;
        insert ss2;
        
        //insert new List<sObject>{a,sm,sm2,ss,ss2, si, si2, si3};
    }
    
    static testmethod void doTest() {
    
        createTestData();
        
        Test.startTest();
        BatchAccountScoringCalculation c = new BatchAccountScoringCalculation();
        Database.executeBatch(c,1);
        Test.stopTest();
        
        List<Account_Scoring__c> acs = [Select Id From Account_Scoring__c];
        List<Account_Scoring_Item__c> acItems = [Select Id From Account_Scoring_Item__c];
        
        System.assert(acs != null && acs.size() > 0);
        System.assert(acItems != null && acItems.size() > 0);
    }
}