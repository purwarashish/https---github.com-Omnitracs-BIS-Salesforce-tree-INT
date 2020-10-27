/**
 * Trigger for the Customer Asset Shipping Actual Trigger.
 * Updates the shipped financials.
 */

trigger CustomerAssetShippingActualTrigger on Customer_Asset_Shipping_Actual__c (after insert, after update, after delete ) {
    System.debug('CustomerAssetShippingActualTrigger');

    if (RecursiveTriggerHandler.isFirstTime == true) {
        RecursiveTriggerHandler.isFirstTime = false;

        if (Trigger.isAfter) {
            if (Trigger.isInsert) {
                System.debug('CustomerAssetShippingActualTrigger.AfterInsert');
                // ARMAN: RevenueForecastHandler.calculateCustomerAssetShippedFinancials(new List<Id>(Trigger.newMap.keySet()));
            }
            if (Trigger.isUpdate) {
                System.debug('CustomerAssetShippingActualTrigger.AfterUpdate');
                // ARMAN: RevenueForecastHandler.calculateCustomerAssetShippedFinancials(new List<Id>(Trigger.newMap.keySet()));
            }
            if (Trigger.isDelete) {
                System.debug('CustomerAssetShippingActualTrigger.AfterDelete');
                // ARMAN: RevenueForecastHandler.calculateCustomerAssetShippedFinancials(new List<Id>(Trigger.oldMap.keySet()));
            }
        }
    }

}