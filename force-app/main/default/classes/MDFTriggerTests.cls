@isTest(SeeAllData=true)
public class MDFTriggerTests {
    
    /**
     * Unit test for Trigger - updateBudget_FundRequest
     */
    public static testMethod void testUpdateBudget_FundRequest() {
    
        //create new account
        Account a = new Account(name = 'account', BillingStreet='123 somewhere', 
            BillingCity='San Diego', BillingState='CA', BillingCountry='USA');
        insert a;

        //create new budget
        SFDC_Budget__c budget = new SFDC_Budget__c(name = 'test', Account__c = a.Id);
        insert budget;

        //create new fund request
        SFDC_MDF__c mdf = new SFDC_MDF__c(name = 'test-MDF', budget__c = budget.Id);
        mdf.amount__c = Decimal.valueOf('1000'); 
        mdf.Approved__c = true;
        insert mdf;
        System.assertEquals(1000, [select Approved_Requests__c from SFDC_Budget__c 
                             where id = :budget.id].Approved_Requests__c);
        
        mdf.amount__c = 2000;
        update mdf;
        System.assertEquals(2000, [select Approved_Requests__c from SFDC_Budget__c 
                             where id = :budget.id].Approved_Requests__c);
        
        delete mdf;
        System.assertEquals(0, [select Approved_Requests__c from SFDC_Budget__c 
                             where id = :budget.id].Approved_Requests__c);
    }
    

    /**
     * Unit test for Trigger - updateBudget_FundClaim
     */
    public static testMethod void testUpdateBudget_FundClaim() {
    
        //create new account
        Account a = new Account(name = 'account', BillingStreet='123 somewhere', 
            BillingCity='San Diego', BillingState='CA', BillingCountry='USA');
        insert a;

        //create new budget
        SFDC_Budget__c budget = new SFDC_Budget__c(name = 'test', Account__c = a.Id);
        insert budget;

        SFDC_MDF_Claim__c mdfClaim = new SFDC_MDF_Claim__c(name = 'test', 
                budget__c = budget.Id, amount__c = 1000, approved__c = true);
        insert mdfClaim;
        System.assertEquals(1000, [select Approved_Claims__c from SFDC_Budget__c 
                             where id = :budget.id].Approved_Claims__c);
        
        mdfClaim.amount__c = 2000;
        update mdfClaim;
        System.assertEquals(2000, [select Approved_Claims__c from SFDC_Budget__c 
                             where id = :budget.id].Approved_Claims__c);
        
        delete mdfClaim;
        System.assertEquals(0, [select Approved_Claims__c from SFDC_Budget__c 
                             where id = :budget.id].Approved_Claims__c);
    }    

    /**
     * Unit test for Triggers - updateFundClaimWithBudget
     */
    public static testMethod void testUpdateFundClaimWithBudget() {
    
        //create new account
        Account a = new Account(name = 'account', BillingStreet='123 somewhere', 
            BillingCity='San Diego', BillingState='CA', BillingCountry='USA');
        insert a;

        //create new budget
        SFDC_Budget__c budget = new SFDC_Budget__c(name = 'test', Account__c = a.Id);
        budget.Approved_Requests__c = Decimal.valueOf('1000');
        insert budget;

        //create new fund request
        SFDC_MDF__c mdf = new SFDC_MDF__c(name = 'test-MDF', budget__c = budget.Id);
        mdf.amount__c = Decimal.valueOf('1000'); 
        insert mdf;
        
        //create new fund claim
        SFDC_MDF_Claim__c mdfClaim = new SFDC_MDF_Claim__c(name = 'test', Fund_Request__c = mdf.id);
        insert mdfClaim;

        System.assertEquals(budget.id, [select Budget__c from SFDC_MDF_Claim__c 
                             where id = :mdfClaim.id].Budget__c);
        
    }
    
   /*
    * unit test method for RecalculateBudget class
    */  
    public static testMethod void testCalculate() {
        //create new account
        Account a = new Account(name = 'account', BillingStreet='123 somewhere', 
            BillingCity='San Diego', BillingState='CA', BillingCountry='USA');
        insert a;

        //create new budget
        SFDC_Budget__c budget = new SFDC_Budget__c(name = 'test', Account__c = a.Id);
        insert budget;

        //create new fund request
        SFDC_MDF__c mdf = new SFDC_MDF__c(name = 'test-MDF', budget__c = budget.Id);
        mdf.amount__c = Decimal.valueOf('1000'); 
        mdf.Approved__c = true;
        insert mdf;
        
        //create new fund claim
        SFDC_MDF_Claim__c mdfClaim = new SFDC_MDF_Claim__c(name = 'test', 
                budget__c = budget.Id, amount__c = 1000, approved__c = true);
        insert mdfClaim;
        //assert that the budget has the right fund claim amount
        budget = [select Approved_Requests__c, Approved_Claims__c from SFDC_Budget__c 
                             where id = :budget.id];
        System.assertEquals(1000, budget.Approved_Requests__c);
        System.assertEquals(1000, budget.Approved_Claims__c);
        

        //now change the amounts on the budget
        budget.Approved_Requests__c = 2000;
        budget.Approved_Claims__c = 2000;
        update budget;
        //assert that the budgets now has the wrong fund request and claim amounts
        budget = [select Approved_Requests__c, Approved_Claims__c from SFDC_Budget__c 
                             where id = :budget.id];
        System.assertNotEquals(1000, budget.Approved_Requests__c);
        System.assertNotEquals(1000, budget.Approved_Claims__c);
        
        //now call calculate() to recalculate the amounts
        RecalculateBudget.calculate(budget.Id);
        //assert that the budget has the right fund claim amount
        budget = [select Approved_Requests__c, Approved_Claims__c from SFDC_Budget__c 
                             where id = :budget.id];
        System.assertEquals(1000, budget.Approved_Requests__c);
        System.assertEquals(1000, budget.Approved_Claims__c);

    }
    
    /**
     * Unit test for SelectBudgetController
     */
    public static testMethod void testSelectBudgetController() {
        SelectBudgetController c = new SelectBudgetController();    
        c.init(true);
        c.init(false);
        c.getError();
        c.getBudgetList();
        Account a = new Account(name = 'test', BillingStreet='123 somewhere', 
            BillingCity='San Diego', BillingState='CA', BillingCountry='USA');
        insert a;
        SFDC_Budget__c budget = new SFDC_Budget__c(Account__c = a.Id);
        insert budget;
        SFDC_MDF__c fundRequest = new SFDC_MDF__c(Account__c = a.Id, Amount__c = 1000);
        insert fundRequest;
        PageReference pageRef = Page.selectBudget;
        Test.setCurrentPage(pageRef);
        // Add parameters to page URL
        ApexPages.currentPage().getParameters().put('fr', fundRequest.Id);
        ApexPages.currentPage().getParameters().put('mac', '1');
        
        SelectBudgetController controller = new SelectBudgetController();   
        controller.init(false);
        controller.assignBudget();
        controller.cancel();
        controller.confirmAssignment();


    }
    public static testMethod void testSelectBudgetControllerwithBudgetId() {
        SelectBudgetController c = new SelectBudgetController();    
        c.init(true);
        c.init(false);
        c.getError();
        c.getBudgetList();
        Account a = new Account(name = 'test', BillingStreet='123 somewhere', 
            BillingCity='San Diego', BillingState='CA', BillingCountry='USA');
        insert a;
        
         Account newacct = new Account(name = 'test', BillingStreet='123 somewhere', 
            BillingCity='San Diego', BillingState='CA', BillingCountry='USA');
        insert newacct;
        SFDC_Budget__c budget = new SFDC_Budget__c(Account__c = a.Id);
        insert budget;
        SFDC_MDF__c fundRequest = new SFDC_MDF__c(Account__c = newacct.Id, Amount__c = 1000);
        insert fundRequest;
        PageReference pageRef = Page.selectBudget;
        Test.setCurrentPage(pageRef);
        // Add parameters to page URL
        ApexPages.currentPage().getParameters().put('fr', fundRequest.Id);
        ApexPages.currentPage().getParameters().put('mac', '1');
        ApexPages.currentPage().getParameters().put('budgetId', budget.id);
        SelectBudgetController controller = new SelectBudgetController();   
        controller.init(false);
        controller.assignBudget();
        controller.cancel();
        controller.confirmAssignment();


    }
}