/**
 * Created by OzerEvin on 04/27/2017.
 */

trigger QuoteTrigger on SBQQ__Quote__c (after update) {
    System.debug('QuoteLineGroupTrigger');

    if (Trigger.isAfter) {
        if (Trigger.isUpdate) {
            System.debug('QuoteTrigger.AfterUpdate');
            if (QuoteRecursiveTriggerHandler.isFirstTime == true) {
                // Nothing needed here, at least to associate Affiliates from QLG to QLI.
            }
        }
    }
}