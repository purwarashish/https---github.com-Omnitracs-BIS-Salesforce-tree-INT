/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest(seeAllData=true)
private class ScoringDataUtilsTest {

    
    
    static testMethod void testCaseEscalationsAdd ()
    {    
       //TestScoringUtility.allAccountRecordTypesCS(); 
       //TestScoringUtility.allAccountUtilCS();
         RecordType rp=[select ID from RecordType where Name='T&L Sales Accounts'];
         Account caseAccount = TestScoringUtility.createAccount();
         Database.DMLOptions dml = new Database.DMLOptions(); 
         dml.DuplicateRuleHeader.allowSave = true;
         dml.DuplicateRuleHeader.runAsCurrentUser = true;
         Database.SaveResult sr1 = Database.insert(caseAccount, dml);
         //insert caseAccount;
         TestScoringUtility.createAccountScoring();
         TestScoringUtility.createScoringModel();
         TestScoringUtility.createScoringItem();
         
        Scoring_Model__c newScoringModel = new Scoring_Model__c(Name = 'Test Data Model',
        Red_Overall_Score_To__c = 10, Red_Overall_Score_From__c = 5,Yellow_Overall_Score_To__c = 4,
        Yellow_Overall_Score_From__c = 3, Green_Overall_Score_To__c = 2, Green_Overall_Score_From__c = 0);
        
        Scoring_Subscription__C newSub = new Scoring_Subscription__c(Subscription_Status__c = 'Active', 
            Scoring_Model__c = newScoringModel.ID, Account__c = caseAccount.ID);
        
        
        insert newScoringModel;
        
        Survey__c newSurvey = new Survey__c(Quality_of_Service_Provided__c = 'Very Satisfied', Timeliness_of_service_provided__c = 'Very Satisfied', Overall_Service_Experience__c = 'Very Satisfied',
            Analyst_s_Technical_Skills_Knowledge__c = 'Very Satisfied', Courtesy_and_Professionalism_of_analyst__c = 'Very Satisfied', Account__c = caseAccount.id);

        
        test.startTest();
        /**********************************Test Case-1***********************************************************/
        
        insert newSurvey;
        insert newSub;
        
        
        test.stopTest();
}
}