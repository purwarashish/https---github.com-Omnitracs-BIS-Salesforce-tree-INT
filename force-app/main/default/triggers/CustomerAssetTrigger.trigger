///////////////////////////////////
// Modified by: Arman Shah
// Date: 8/24/2018
///////////////////////////////////
trigger CustomerAssetTrigger on Customer_Asset__c (before insert, before update, before delete,
    after insert, after update, after delete, after undelete) {
    
    System.debug('-- START CustomerAssetTrigger');
    
    if (CustomerAssetHandler.bypassTrigger == true) {
        System.debug('-- CustomerAsset bypassTrigger.returning');
        return;
    }

    if (Trigger.isBefore) {

        if (Trigger.isInsert) {
            System.debug('-- In BEFORE_INSERT CustomerAsset Trigger');
        }
        
        if (Trigger.isUpdate) {
            System.debug('-- In BEFORE_UPDATE CustomerAsset Trigger');
        }
        
        if (Trigger.isDelete) {
            System.debug('-- In BEFORE_DELETE CustomerAsset Trigger');
        }
    }
    else { // isAfter
        
        if (Trigger.isInsert) {
            System.debug('-- In AFTER_INSERT CustomerAsset Trigger');
            CustomerAssetHandler.createShippingSchedule(Trigger.new);
            // ARMAN: RevenueForecastHandler.calculateCustomerAssetFinancials(new List<Id>(Trigger.newMap.keySet()));
            CustomerAssetHandler.setContractOnAssetAndCustomerAsset(Trigger.new);
        }
        
        if (Trigger.isUpdate) {
            System.debug('-- In AFTER_UPDATE CustomerAsset Trigger');

            CustomerAssetHandler.createShippingSchedule(Trigger.new);
            // ARMAN: RevenueForecastHandler.calculateCustomerAssetFinancials(new List<Id>(Trigger.newMap.keySet()));
        }

        if (Trigger.isDelete) {
            System.debug('-- In AFTER_DELETE CustomerAsset Trigger');
        }

        if (Trigger.isUnDelete) {
            System.debug('-- In AFTER_UNDELETE CustomerAsset Trigger');
        }
    }
    
    System.debug('-- END CustomerAssetTrigger');
}