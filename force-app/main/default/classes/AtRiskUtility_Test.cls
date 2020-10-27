@isTest(SeeAllData=True)
public with sharing class AtRiskUtility_Test {

    static testMethod void testPrimaryAlerts() {
        Account testAcc = new Account(Name = 'Test');
        
        insert testAcc;
        
        At_Risk__c testAlert1 = new At_Risk__c(Account__c = testAcc.Id, Status__c = 'Open', Problem_Statement__c = 'Problem 1', Primary__c = true);
        At_Risk__c testAlert2 = new At_Risk__c(Account__c = testAcc.Id, Status__c = 'Open', Problem_Statement__c = 'Problem 2', Primary__c = false);
        
        Test.startTest();
        
        insert testAlert1;
        insert testAlert2;
        
        System.assertEquals(true, [SELECT Primary__c FROM At_Risk__c WHERE Id = :testAlert1.Id].Primary__c);
        System.assertEquals(false, [SELECT Primary__c FROM At_Risk__c WHERE Id = :testAlert2.Id].Primary__c);
        
        testAlert2.Primary__c = true;
        update testAlert2;
        
        System.assertEquals(false, [SELECT Primary__c FROM At_Risk__c WHERE Id = :testAlert1.Id].Primary__c);
        System.assertEquals(true, [SELECT Primary__c FROM At_Risk__c WHERE Id = :testAlert2.Id].Primary__c);
        
        Test.stopTest();
    } 

    static testMethod void testCopyAlertToAccount() {
        Account testAcc = new Account(Name = 'Test');
        
        insert testAcc;
        
        At_Risk__c testAlert1 = new At_Risk__c(Account__c = testAcc.Id, Status__c = 'Open', Problem_Statement__c = 'Problem 1', Primary__c = true);
        
        Test.startTest();
        
        insert testAlert1;
        
        System.assertNotEquals('', [SELECT Alert_Text__c FROM Account WHERE Id = :testAlert1.Account__c].Alert_Text__c);
        
        Test.stopTest();
    }

}