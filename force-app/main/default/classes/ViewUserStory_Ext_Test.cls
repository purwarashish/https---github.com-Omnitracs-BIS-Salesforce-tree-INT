@isTest
public class ViewUserStory_Ext_Test {

    public static testMethod void testAssociateReqs() {
        User_Story__c s = new User_Story__c();
        insert s;
        
        Requirements__c r1 = new Requirements__c(Title__c = 'Test 1', Track__c = 'Customer Support');
        Requirements__c r2 = new Requirements__c(Title__c = 'Test 2', Track__c = 'Sales');
        insert r1;
        insert r2;
        
        User_Story_Requirement__c j = new User_Story_Requirement__c(User_Story__c = s.Id, Requirement__c = r1.Id);
        insert j;
        
        Test.startTest();
        
        Test.setCurrentPage(Page.ViewUserStory);
        ApexPages.currentPage().getParameters().put('id',s.Id);
        ApexPages.StandardController con = new ApexPages.StandardController(s);
        ViewUserStory_Ext storyPage = new ViewUserStory_Ext(con);
        
        System.assert(true, storyPage.assignedReqsList[0].getValue() == r1.Id);
        System.assert(true, storyPage.unassignedReqsList[0].getValue() == r2.Id);
        
        List<SelectOption> newAssigned = new List<SelectOption>();
        List<SelectOption> newUnassigned = new List<SelectOption>();
        newAssigned.add(new SelectOption(r2.Id, r2.Title__c));
        newUnassigned.add(new SelectOption(r1.Id, r1.Title__c));
        
        storyPage.assignedReqsList = newAssigned;
        storyPage.unassignedReqsList = newUnassigned;
        
        storyPage.doSave();
        
        List<User_Story_Requirement__c> newJunctions = [SELECT Id, Requirement__c FROM User_Story_Requirement__c];
        
        System.assertEquals(1,newJunctions.size());
        System.assert(true, newJunctions[0].Requirement__c == r2.Id);
        
        storyPage.refreshFilter();
        
        Test.stopTest();
    }

}