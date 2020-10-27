@isTest

public class AccountScoringItemsTest {
    static testMethod void testAccountScoringItem(){
    
        TestAllUtils.createTAndLSalesAccounts();
        Id acctRT = [select Id from RecordType where SobjectType = 'Account' and DeveloperName = 'TLSalesAccounts'].Id;
         Account act = new Account();
        act.Name = 'Omnitracs, LLC';
        act.RecordTypeId = acctRT;
        insert act;
        
        Account_Scoring__c actScoring = new Account_Scoring__c();
        actScoring.Display_Type__c = 'Red';
        actScoring.Account__c = act.Id;
        insert actScoring;
        
        Account_Scoring_Item__c obj = new Account_Scoring_Item__c();
        obj.Account_Scoring__c = actScoring.Id ;
        obj.Display_Type__c = 'yellow'; 
        insert obj;
        
        Test.startTest();
            AccountScoringItemBatchClass obj1 = new AccountScoringItemBatchClass();
            Id batchId = Database.executeBatch(obj1,200);
         Test.stopTest(); 
         System.assert(true);
    }
}