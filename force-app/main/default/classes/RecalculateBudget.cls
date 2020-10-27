/*
* Class to recalculate the amounts on the budget, in case sometime the budgets amounts are not
* in sync[Triggers go bad or record is manually updated]
*/
global class RecalculateBudget {

    /*
    * Called from the recalculate button on the budget object.
    * recalculates the fund request and the fund claim amounts
    */  
    WebService static void calculate(String budgetId) {
        
        Decimal fundRequestAmount = getFundRequestAmount(budgetId);
        Decimal fundClaimAmount = getFundClaimAmount(budgetId);
        //create the budget object
        SFDC_Budget__c budget = new SFDC_Budget__c(Id = budgetId, 
                                    Approved_Requests__c = fundRequestAmount, 
                                    Approved_Claims__c = fundClaimAmount,
                                    Last_Refresh_Date__c = datetime.now());      
        try {
            update budget;
        } catch (DmlException e) {
            System.debug('Update Failed: ' + e);
            throw e; //the javascript should get it
        }       
        
    }
    
    /*
    * recalculates and returns the fund request amount
    */  
    private static Decimal getFundRequestAmount(String budgetId) {
        //get all approved fund requests for the budget
        List<SFDC_MDF__c> fundRequests = [Select Id, Amount__c From SFDC_MDF__c 
            Where Budget__c = :budgetId And Approved__c = true];

        //recalculate amount
        Decimal fundRequestAmount = 0;
        for (SFDC_MDF__c fundRequest : fundRequests) {
            Decimal amount = fundRequest.Amount__c;
            if (amount != null) fundRequestAmount += amount;
        }
        return fundRequestAmount;
    }
    
    /*
    * recalculates and returns the fund claim amount
    */  
    private static Decimal getFundClaimAmount(String budgetId) {
        //get all approved FundClaims for this budget
        List<SFDC_MDF_Claim__c> fundClaims = [Select Id, Amount__c From SFDC_MDF_Claim__c 
            Where Budget__c = :budgetId And Approved__c = true];

        //recalculate amount
        Decimal fundClaimAmount = 0;
        for (SFDC_MDF_Claim__c fundClaim : fundClaims) {
            Decimal amount = fundClaim.Amount__c;
            if (amount != null) fundClaimAmount += amount;
        }
        return fundClaimAmount;
    }
    
    
}