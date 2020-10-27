/**********************************************************
* @Author       Yasir Arafat
* @Date         2019-08-01
* @Description  ProductMigration trigger
* @Requirement  There should be only one Product Migration form for a record type for a given Account
**********************************************************/
trigger ProductMigrationTrigger on Product_Migration__c (before insert) {
    if(Trigger.isInsert && Trigger.isBefore){
        List<Product_Migration__c> productMigrations = Trigger.new;
        Set<Id> acctIds = new Set<Id>();
        for(Product_Migration__c productMigration : productMigrations){
            acctIds.add(productMigration.Account__c);
        }
        List<Product_Migration__c> existingProductMigrations = [Select Id, RecordTypeId, RecordType.Name, Account__c from Product_Migration__c where Account__c IN :acctIds];
        for(Product_Migration__c productMigration : productMigrations){
            for(Product_Migration__c existingProductMigration : existingProductMigrations){
                if(productMigration.Account__c == existingProductMigration.Account__c && productMigration.RecordTypeId == existingProductMigration.RecordTypeId){
                    productMigration.addError('Product Migration Form for ' + existingProductMigration.RecordType.Name + ' already exists, please use the existing form.');
                    break;
                }
            }
        }
    }
}