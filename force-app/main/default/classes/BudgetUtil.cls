public class BudgetUtil {

    /*
    * the max number of DMl operations allowed in one chunk
    */
    public static Integer SFDC_MAX_OPERATIONS = 200;
    
    /*
    * Updates the budgets in chunks of 200 at a time. this ensures limits are not exceeded
    * if number of budgets are more than allowed apex limits, it throws an exception.
    */
    public static void updateList(List<SFDC_Budget__c> budgetList) {
        System.debug(Limits.getLimitDMLRows());
        if (budgetList.size() + Limits.getDMLRows()
                            > Limits.getLimitDMLRows()) {
                
            throw new LimitException('Attempting to perform a DML operations on too many sobjects at a time. Please reduce the batch size.');
        
        }else{
            List<SFDC_Budget__c> tmp = new List<SFDC_Budget__c>();
            
            for (SFDC_Budget__c b : budgetList){
                tmp.add(b);
                if (tmp.size() == SFDC_MAX_OPERATIONS){
                    update tmp;
                    tmp.clear();
                }
            }
            if (tmp.size() > 0){
                update tmp;
                tmp.clear();
            }       
            budgetList.clear();
        }
                
    }

    /*
     * Creates and returns list of budget objects which has the updated amount and the last refresh time
     * for changes in Fund request
     */ 
    public static List<SFDC_Budget__c> getBudgetList(Set<Id> budgetSet) {
        List<SFDC_MDF__c> existingFundRequests = new List<SFDC_MDF__c>();
        for (List<SFDC_MDF__c> tmp : [Select Id, Amount__c, Budget__c From SFDC_MDF__c 
            Where Budget__c In :budgetSet And Approved__c = true])
        {
            existingFundRequests.addAll(tmp);
        }
        
        //recalculate amount
        Map<Id, SFDC_Budget__c> budgetMap = new Map<Id, SFDC_Budget__c>();
        for (SFDC_MDF__c fundRequest : existingFundRequests) {
            Decimal amount = fundRequest.Amount__c;
            if (amount != null) {
                Id budgetId = fundRequest.Budget__c;
                SFDC_Budget__c budget = budgetMap.get(budgetId);
                if (budget == null) {
                    budget = new SFDC_Budget__c(Id = budgetId, Approved_Requests__c = 0, Last_Refresh_Date__c = datetime.now());
                    budgetMap.put(budgetId, budget);
                    //once in map-remove from set
                    budgetSet.remove(budgetId); 
                }
                budget.Approved_Requests__c += amount;
            }
        }
        //now the ones still in the set have no FundRequest
        List<SFDC_Budget__c> budgetList = new List<SFDC_Budget__c>();
        if (! budgetSet.isEmpty()) {
            for (Id budgetId : budgetSet) {
                SFDC_Budget__c budget = new SFDC_Budget__c(Id = budgetId, Approved_Requests__c = 0, Last_Refresh_Date__c = datetime.now());
                budgetList.add(budget);
            }
        }
        if (! budgetMap.isEmpty()) {
            budgetList.addAll(budgetMap.values());
        }
        return budgetList;  
    }
    
    

    /*
     * Creates and returns list of budget objects which has the updated amount and the last refresh time
     * for changes in Fund claim
     */
    public static List<SFDC_Budget__c> getBudgetListForFundClaim(Set<Id> budgetSet) {
        List<SFDC_MDF_Claim__c> existingFundClaims = new List<SFDC_MDF_Claim__c>();
        for (List<SFDC_MDF_Claim__c> tmp : [Select Id, Amount__c, Budget__c From SFDC_MDF_Claim__c 
            Where Budget__c In :budgetSet And Approved__c = true])
        {
            existingFundClaims.addAll(tmp);
        }
        
        //recalculate amount
        Map<Id, SFDC_Budget__c> budgetMap = new Map<Id, SFDC_Budget__c>();
        for (SFDC_MDF_Claim__c fundClaim : existingFundClaims) {
            Decimal amount = fundClaim.Amount__c;
            if (amount != null) {
                Id budgetId = fundClaim.Budget__c;
                SFDC_Budget__c budget = budgetMap.get(budgetId);
                if (budget == null) {
                    budget = new SFDC_Budget__c(Id = budgetId, Approved_Claims__c = 0, Last_Refresh_Date__c = datetime.now());
                    budgetMap.put(budgetId, budget);
                    //once in map-remove from set
                    budgetSet.remove(budgetId); 
                }
                budget.Approved_Claims__c += amount;
            }
        }
        //now the ones still in the set have no fundClaim
        List<SFDC_Budget__c> budgetList = new List<SFDC_Budget__c>();
        if (! budgetSet.isEmpty()) {
            for (Id budgetId : budgetSet) {
                SFDC_Budget__c budget = new SFDC_Budget__c(Id = budgetId, Approved_Claims__c = 0, Last_Refresh_Date__c = datetime.now());
                budgetList.add(budget);
            }
        }
        if (! budgetMap.isEmpty()) {
            budgetList.addAll(budgetMap.values());
        }
        return budgetList;  
    }
        
    public class LimitException extends Exception {} 
}