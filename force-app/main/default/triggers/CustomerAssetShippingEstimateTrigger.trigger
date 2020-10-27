/**
 * Created by CrutchfieldJody on 1/24/2017.
 */

trigger CustomerAssetShippingEstimateTrigger on Customer_Asset_Shipping_Estimate__c(after update, after delete) {
    System.debug('CustomerAssetShippingEstimateTrigger');

    if(Trigger.isAfter){
        if (Trigger.isUpdate) {
            //ARMAN: System.debug('CustomerAssetShippingEstimateTrigger.AfterUpdate');
            //ARMAN: RevenueForecastHandler.calculateCustomerAssetEstimateFinancials(Trigger.new);
        }
        /* ARMAN: if (Trigger.isDelete) {
            //ARMAN: System.debug('ShippingEstimateTrigger.AfterDelete');
            //ARMAN: RevenueForecastHandler.calculateCustomerAssetEstimateFinancials(Trigger.old);
        }*/
    }
}