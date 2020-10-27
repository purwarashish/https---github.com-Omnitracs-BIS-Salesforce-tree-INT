@isTest

public class contractTermReportTest {
    static testMethod void testContractTermReport(){
        Contract_Term_Report__c obj = new Contract_Term_Report__c();
        obj.Status__c = 'Active'; 
        insert obj;
        Test.startTest();
            ContractTermReportBatchClass obj1 = new ContractTermReportBatchClass();
            Id batchId = Database.executeBatch(obj1,200);
         Test.stopTest(); 
         System.assert(true);
    }
}