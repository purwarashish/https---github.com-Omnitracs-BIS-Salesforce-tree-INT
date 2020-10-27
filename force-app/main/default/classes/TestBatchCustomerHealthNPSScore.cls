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
@isTest
private class TestBatchCustomerHealthNPSScore {

    static testMethod void myUnitTest() {
        // TO DO: implement unit test
        Test.StartTest();
        database.executeBatch(new BatchCustomerHealthNPSScore(), 1);
        Test.stopTest();
        
    }
    
    static testMethod void myUnitTest2() {
        // TO DO: implement unit test
        Test.StartTest();
        database.executeBatch(new BatchCustomerHealthOnAirDelta(), 1);
        Test.stopTest();
        
    }
    
    static testMethod void myUnitTest3() {
        // TO DO: implement unit test
        Test.StartTest();
        database.executeBatch(new BatchCustomerHealthCaseEscalations(), 1);
        Test.stopTest();
        
    }
    
    static testMethod void myUnitTest4() {
        // TO DO: implement unit test
        Test.StartTest();
        database.executeBatch(new BatchContractEndDateScoring(), 1);
        Test.stopTest();
        
    }
    
    static testMethod void myUnitTest5() {
        // TO DO: implement unit test
        Test.StartTest();
        database.executeBatch(new BatchCustomerHealthAssetData(), 1);
        Test.stopTest();
        
    }
    
    
}