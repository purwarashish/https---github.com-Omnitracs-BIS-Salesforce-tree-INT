@isTest(seealldata=true)
private class TestAllIdeaController
{
    static list<Customer_Idea__c> lstCustomerIdea = new list<Customer_Idea__c>();
    public static void insertCustomerIdea()
    {
        Account newAccount = new Account();
        newAccount.Name = 'SFDC';
        newAccount.Type = 'Other';
        newAccount.BillingStreet = 'Test Address';
        newAccount.BillingCity = 'Test City';
        newAccount.BillingCountry = 'Test Country';
        insert newAccount;
        
        Idea newIdea = new Idea();
        newIdea.title = 'Test Idea';
        newIdea.communityId = '09a500000008aK5';
        //insert newIdea;
        //list<Customer_Idea__c> lstCustomerIdea = new list<Customer_Idea__c>();
        for(integer i=0;i<50;i++)
        {
            Customer_Idea__c newAcctIdea = new Customer_Idea__c();
            newAcctIdea.Account__c = newAccount.Id;
            newAcctIdea.Idea__c = newIdea.Id;
            lstCustomerIdea.add(newAcctIdea);
        }
        insert lstCustomerIdea; 
    }
    public static testmethod void testIdeasAccountController()
    {
        insertCustomerIdea();
        ShowIdeasAccountController newObj = new ShowIdeasAccountController();
        newObj.alphabetOrdering();
        newObj.changeOrder();
        newObj.pagination();
        newObj.next();
        newObj.previous();
    }
    
    public static testmethod void testNewIdea()
    {
        test.startTest();
        insertCustomerIdea();
        Customer_Idea__c newAcctIdea = new Customer_Idea__c();        
        ApexPages.StandardController sdtCon;
        if(!lstCustomerIdea.isEmpty())
        {
            Idea newIdea = new Idea();
            newIdea.title = 'Test Idea';
            Id communityId = [select Id from Community limit 1].Id;
            newIdea.communityId = communityId;
            //insert newIdea;
            newIdea = [Select id from Idea limit 1];
                        
            newAcctIdea = [Select id,idea__c,account__c from Customer_Idea__c where id =:lstCustomerIdea[0].id limit 1];
            newAcctIdea.Idea__c = newIdea.Id; 
            update newAcctIdea; 
            sdtCon = new ApexPages.StandardController(newAcctIdea);
            
        }
            
        
        NewAccountIdeaLinkController newObj = new NewAccountIdeaLinkController(sdtCon);
        newObj.acctID = newAcctIdea.account__c;
        newObj.Save();
        newObj.SaveandNew();
        newObj.acctID = newAcctIdea.account__c;
        newObj.findTotalUnits();
        newOBj.redirectionOnEdit();
        test.stopTest();
    }
}