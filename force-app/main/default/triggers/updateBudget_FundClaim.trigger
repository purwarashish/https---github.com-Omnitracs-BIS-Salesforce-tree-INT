trigger updateBudget_FundClaim on SFDC_MDF_Claim__c (after insert, after update, after delete, after undelete) {

    /*
     * Recalculates The FundClaim Amount on the Budget on insert, update, delete of a fund claim.
     * Only those FundClaims are considered which are approved (approved__c = true)
     *
     */ 
    List<SFDC_Budget__c> budgetList = new List<SFDC_Budget__c>();
    Set<Id> budgetSet = new Set<Id>();
    
    if (Trigger.isDelete) {
        //for delete
        for (SFDC_MDF_Claim__c changedMDFClaim : Trigger.old) {
            if (changedMDFClaim.Budget__c != null)
                budgetSet.add(changedMDFClaim.Budget__c);
        }
        
    } else {
        if (Trigger.isUpdate) {
            for (Integer i = 0; i < Trigger.size; i++) {
                SFDC_MDF_Claim__c oldMDFClaim = Trigger.old[i];
                SFDC_MDF_Claim__c newMDFClaim = Trigger.new[i];
                Id oldBudgetId = oldMDFClaim.Budget__c;
                Id newBudgetId = newMDFClaim.Budget__c;
                if (oldBudgetId != null) {
                    if (newBudgetId == null || oldBudgetId != newBudgetId) {
                        //budget removed - need to update old budget
                        budgetSet.add(oldBudgetId);
                    }
                }   
            }
        }
        
        for (SFDC_MDF_Claim__c changedMDFClaim : Trigger.new) {
            if (changedMDFClaim.Budget__c != null)
                budgetSet.add(changedMDFClaim.Budget__c);
        }
    }
    budgetList = BudgetUtil.getBudgetListForFundClaim(budgetSet);

    //update the budget objects
    if (budgetList.size() > 0) {
        try {
           BudgetUtil.updateList(budgetList);
        } catch (DmlException e) {
            String message = 'An error occured while Updating Budget: ';
            message += '\nMessage: ' + e.getMessage();
            message += '\nCause: ' + e.getCause();
            System.debug(message);
            budgetList.get(0).addError(message);
        }
    }
}