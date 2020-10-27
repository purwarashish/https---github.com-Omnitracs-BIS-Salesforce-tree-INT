/*
* Displays list of budgets matching by name. Assigns the selected budget to the fund request. 
*/
public class SelectBudgetController {

    private Id fundRequestId;
    private SFDC_MDF__c fundRequest;
    private List<SFDC_Budget__c> budgetList;
    private String selectedBudgetId;
    private Integer error = 0;
    
    /*
    * Constructor
    */
    public SelectBudgetController() {
        //get id from request
        try {
            this.fundRequestId = ApexPages.currentPage().getParameters().get('fr');
            String mac = ApexPages.currentPage().getParameters().get('mac');
            Boolean matchingAccount = (mac != null && mac.equals('1'));
            init(matchingAccount);
        } catch(Exception e) {
            error = 1;
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.FATAL, 'No Fund request found in request');
            ApexPages.addMessage(myMsg);
        }
    }
    
    /*
    * gets the list of budgets
    */
    public void init(Boolean matchingAccount) {
        //get the accountId associated with the fund request
        List<SFDC_MDF__c> fundRequestList = [Select s.Account__r.Name, s.Account__c, Amount__c From SFDC_MDF__c s where Id = :fundRequestId];
        if (fundRequestList == null || fundRequestList.isEmpty()) {
            System.debug('fundRequestList empty ');
            error = 1;
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.FATAL, 'No Fund request found in request.');
            ApexPages.addMessage(myMsg);
            return;
        }
        System.debug('fundRequestList = ' + fundRequestList);
        this.fundRequest = fundRequestList.get(0);
        String accountName = fundRequest.Account__r.Name;
        accountName = '%' + accountName + '%';
        
        //now get the budgets
        if (matchingAccount) {
            this.budgetList = [Select s.Unclaimed__c, s.Total_Active_Budget__c, s.Start_Date__c, s.Name, 
                s.Id, s.End_Date__c, s.Available_Budget__c, s.Approved_Requests__c, s.Approved_Claims__c, s.Active__c, 
                s.account__r.Name, s.Account__c 
                From SFDC_Budget__c s 
                where Active__c = true and Account__c = :fundRequest.Account__c  
                order by s.Start_Date__c asc];
        } else {
            this.budgetList = [Select s.Unclaimed__c, s.Total_Active_Budget__c, s.Start_Date__c, s.Name, 
                s.Id, s.End_Date__c, s.Available_Budget__c, s.Approved_Requests__c, s.Approved_Claims__c, s.Active__c, 
                s.account__r.Name, s.Account__c 
                From SFDC_Budget__c s 
                where Active__c = true and (account__r.Name like :accountName OR Account__c = '') 
                order by s.Start_Date__c asc];
            
        }
                
        if (budgetList == null || budgetList.isEmpty()) {
            error = 1;
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.FATAL, 'No Budgets available to assign.');
            ApexPages.addMessage(myMsg);
        }
    }
    
    /*
    * Action method called from page. Validates and assigns the budget.
    */
    public PageReference assignBudget() {
        error = 0;
        selectedBudgetId = ApexPages.currentPage().getParameters().get('budgetId');
        System.debug('budgetId = ' + selectedBudgetId);
        SFDC_Budget__c selectedBudget = getSelectedBudget(selectedBudgetId);
        if (selectedBudget == null) {
            error = 1;
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.FATAL, 'No Budget available to assign.');
            ApexPages.addMessage(myMsg);
            return null;
        }
        
        Decimal availableBudget = selectedBudget.Available_Budget__c;
        Decimal fundRequestAmount = fundRequest.Amount__c;
        if ((availableBudget - fundRequestAmount) < 0) {
            error = 2;
            String message = 'The fund request amount $' + fundRequestAmount.setScale(2) + ' is greater than the available budget of $' + availableBudget.setScale(2) + '. Continue with the assignment?';
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.WARNING, message);
            ApexPages.addMessage(myMsg);
            return null;    
        }

        return confirmAssignment();
    }
    
    /*
    * Action method called from page. Updates the fund request object with the budget.
    */
    public PageReference confirmAssignment() {
        error = 0;
        if (selectedBudgetId == null) {
            error = 1;
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.FATAL, 'No Budget available to assign.');
            ApexPages.addMessage(myMsg);
            return null;
        }
        fundRequest.Budget__c = selectedBudgetId;
        update fundRequest;

        return cancel();
    }
    
    /*
    * Action method called from page. navigates back to the funcd request
    */
    public PageReference cancel() {
        if (fundRequestId == null) fundRequestId = '';
        PageReference pageRef = new PageReference('/' + fundRequestId);  
        pageRef.setRedirect(true); 
        return pageRef;
    }
    
    /*
    * returns the selected budget
    */
    private SFDC_Budget__c getSelectedBudget(String budgetId) {
        for (SFDC_Budget__c budget : budgetList) {
            String id = budget.Id;
            if (id.equals(budgetId)) {
                return budget;
            }
        }
        return null;
    }
    
    /*
    * getter
    */
    public List<SFDC_Budget__c> getBudgetList() {
        return budgetList;
    }
    
    /*
    * getter
    */
    public Integer getError() {
        return error;   
    }
}