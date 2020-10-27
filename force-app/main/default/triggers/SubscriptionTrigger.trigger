trigger SubscriptionTrigger on SBQQ__Subscription__c (after insert) {
    System.debug('SubscriptionTrigger');

//    BypassTriggerUtility u = new BypassTriggerUtility();
//    if (u.isTriggerBypassed()) {
//        return;
//    }
    if(Trigger.isAfter){
        if(Trigger.isInsert){
            System.debug('SubscriptionTrigger.AfterInsert');
            VistaSubscriptionHandler.handleSBSubscriptions(trigger.new);
        }
    }

}