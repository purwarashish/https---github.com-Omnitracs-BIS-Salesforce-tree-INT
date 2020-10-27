@isTest
public class NewRequirement_Ctrl_Test{

    public static testMethod void testSave(){
        User_Story__c testUsrSty = new User_Story__c();
        insert testUsrSty;
        PageReference testPage = new PageReference('/apex/NewRequirement?id=' + testUsrSty.id);
        Test.startTest();
            Test.setCurrentPage(testPage);
            NewRequirement_Ctrl controller = new NewRequirement_Ctrl();
            controller.req.Title__c = 'Test Requirement';
            controller.save();
        Test.stopTest();
        
        System.assertEquals(1,[SELECT id, Requirement__c FROM User_Story_Requirement__c WHERE User_Story__c = :testUsrSty.Id].size());
    }
    
    public static testMethod void testSaveAndNew(){
        User_Story__c testUsrSty = new User_Story__c();
        insert testUsrSty;
        PageReference testPage = new PageReference('/apex/NewRequirement?id=' + testUsrSty.id);
        Test.startTest();
            Test.setCurrentPage(testPage);
            NewRequirement_Ctrl controller = new NewRequirement_Ctrl();
            controller.req.Title__c = 'Test Requirement';
            controller.saveAndNew();
        Test.stopTest();
        
        System.assertEquals(1,[SELECT id, Requirement__c FROM User_Story_Requirement__c WHERE User_Story__c = :testUsrSty.Id].size());
    }
    
    public static testMethod void testCancel(){
        User_Story__c testUsrSty = new User_Story__c();
        insert testUsrSty;
        PageReference testPage = new PageReference('/apex/NewRequirement?id=' + testUsrSty.id);
        Test.startTest();
            Test.setCurrentPage(testPage);
            NewRequirement_Ctrl controller = new NewRequirement_Ctrl();
            controller.req.Title__c = 'Test Requirement';
            controller.cancel();
        Test.stopTest();
        
        System.assertEquals(0,[SELECT id, Requirement__c FROM User_Story_Requirement__c WHERE User_Story__c = :testUsrSty.Id].size());
    }
}