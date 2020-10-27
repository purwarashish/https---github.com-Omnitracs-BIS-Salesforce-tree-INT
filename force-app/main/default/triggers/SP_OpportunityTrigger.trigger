trigger SP_OpportunityTrigger on Opportunity (before update) {

    //disabled for bulk updatess
    if (Trigger.size == 1) {
        if(Trigger.new[0].ConnectionReceivedId == null) {
            SP_SalesPlanValidations.validateRequiredActions(Trigger.newMap, Trigger.oldMap);
        }
    }
}