trigger updateBudget_FundRequest on SFDC_MDF__c (after insert, after update, after delete) {

    /*
     * Recalculates The FundRequest Amount on the Budget on insert, update, delete of a fund request.
     * Only those FundRequest are considered which are approved (approved__c = true)
     *
     */ 

    List<SFDC_Budget__c> budgetList = new List<SFDC_Budget__c>();
    Set<Id> budgetSet = new Set<Id>();
    
    if (Trigger.isDelete) {
        //for delete
        for (SFDC_MDF__c changedMDF : Trigger.old) {
            if (changedMDF.Budget__c != null) {
                //budgetList.add(BudgetUtil.getUpdatedBudget(changedMDF));
                budgetSet.add(changedMDF.Budget__c);
            }
        }
        
    } else {
        if (Trigger.isUpdate) {
            for (Integer i = 0; i < Trigger.size; i++) {
                SFDC_MDF__c oldMDF = Trigger.old[i];
                SFDC_MDF__c newMDF = Trigger.new[i];
                Id oldBudgetId = oldMDF.Budget__c;
                Id newBudgetId = newMDF.Budget__c;
                System.debug(oldBudgetId);
                if (oldBudgetId != null) {
                    if (newBudgetId == null || oldBudgetId != newBudgetId) {
                        //budget removed/changed - need to update old budget
                        budgetSet.add(oldBudgetId);
                    }
                }   
            }
        }

        for (SFDC_MDF__c changedMDF : Trigger.new) {
            if (changedMDF.Budget__c != null) {
                budgetSet.add(changedMDF.Budget__c);
            }
        }
    }
    budgetList = BudgetUtil.getBudgetList(budgetSet);

    //update the budget objects
    if (budgetList.size() > 0) {
        try {
            BudgetUtil.updateList(budgetList);
        } catch (Exception e) {
            String message = 'An error occured while Updating Budget: ';
            message += '\nMessage: ' + e.getMessage();
            message += '\nCause: ' + e.getCause();
            System.debug(message);
            budgetList.get(0).addError(message);
        }
    }

    

}