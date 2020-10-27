@isTest(SeeAllData=True)
private class TestCusomerIdeaReport{  
    public static testmethod void testCustomReport()
    {
        Id communityId = [Select c.IsActive, c.Id From Community c where isActive = true limit 1].Id;
        Idea newIdea = new Idea();
        newIdea.CommunityId = communityId ;
        newIdea.title = 'Test Idea';
        newIdea.Categories = 'Trailer Tracking';
        insert newIdea;
        
        Account Acct = GenericTestClass.insertAccount();
        
        Customer_Idea__c newcustIdea = new Customer_Idea__c();
        newcustIdea.Idea__c = newIdea.Id;
        newcustIdea.Account__c = acct.Id;
        insert newcustIdea;
        
        IdeaReportController obj = new IdeaReportController();
        //obj.showIdeasByNumofTrucks();
        //obj.showIdeasByCustomers();
    }
 
}