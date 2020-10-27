trigger updateFundClaimWithBudget on SFDC_MDF_Claim__c bulk (before insert) {

    /*
     * Sets the Budget on the Fund Claim.
     * Checks if budget was null. If yes, get the budget from the associated Fundrequest
     */ 
    for (SFDC_MDF_Claim__c fundClaim : Trigger.new) {
        //if budget is null then only we should run the trigger
        if (fundClaim.Budget__c == null && fundClaim.Fund_Request__c != null) { 
            SFDC_MDF__c fundRequest = [Select Budget__c From SFDC_MDF__c where Id = :fundClaim.Fund_Request__c];
            if (fundRequest.Budget__c != null) {
                fundClaim.Budget__c = fundRequest.Budget__c;
            }
        }
    }
}