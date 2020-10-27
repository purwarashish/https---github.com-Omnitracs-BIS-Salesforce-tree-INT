public class MDFTests {
    
    /**
    *   Code coverate tests for triggers.
    *
    */

    public static boolean IsTest = false;
    @isTest(SeeAllData=True)
    public static void unit(){
        
        //Set global var to true to workaround code coverage issue
        MDFTests.IsTest = true;
        
        //Create and insert each of the MDF objects with appropriate 
        //values set to execute triggers.
        
        SFDC_MDF__c mdf = new SFDC_MDF__c(name = 'test');   
        
        insert mdf;
        
        mdf.name = 'test2';
        
        update mdf;
        
        SFDC_MDF_Claim__c mdfc = new SFDC_MDF_Claim__c(name = 'test');  
        
        insert mdfc;
        
        mdfc.name = 'test2';
        
        update mdfc;    
        
        Account a = new Account(name = 'account', BillingStreet='123 somewhere', 
            BillingCity='San Diego', BillingState='CA', BillingCountry='USA');
        insert a;
        
        a.IsPartner = true;
        update a;
        
        UserRole ur = new UserRole(name = 'account Partner User'); 
        //insert ur;
        
        Group g = new Group(name = 'test');
                            
        insert g;
    
                            
        SFDC_Budget__c budget = new SFDC_Budget__c(name = 'test');  
    
        insert budget;
        
        budget.Account__c = a.Id;
        
        update budget;  
        
        //Test account set on insert    
        budget = new SFDC_Budget__c(name = 'test',
                                    Account__c = a.Id); 
    
        insert budget;
        
        budget.Account__c = null;
        
        update budget;  
        
    
    }

}