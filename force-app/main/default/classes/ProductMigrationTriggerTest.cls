@isTest
public class ProductMigrationTriggerTest {
    
    public static VistaAssetHelperUtil util = new VistaAssetHelperUtil();
    
    @testSetup
    static void SetupData() {
        TestUtils.defineCustomSettings();
    }

    static testMethod void myUnitTest() {
        Account account = util.createAccount('ABC ProductMigration Test Account');
        Test.startTest();
        Id productMigrationRecordTypeId = Schema.SObjectType.Product_Migration__c.getRecordTypeInfosByName().get('RTS to RNA Migration').getRecordTypeId();
        Product_Migration__c productMigration = new Product_Migration__c(RecordTypeId = productMigrationRecordTypeId, Account__c = account.Id);
        insert productMigration;
        try{
            Product_Migration__c duplicateProductMigration = new Product_Migration__c(RecordTypeId = productMigrationRecordTypeId, Account__c = account.Id);
            insert duplicateProductMigration;
        }catch(Exception e){
            Boolean expectedExceptionThrown =  e.getMessage().contains('already exists') ? true : false;
            System.AssertEquals(expectedExceptionThrown, true);
        }
        Test.stopTest();
    }
}