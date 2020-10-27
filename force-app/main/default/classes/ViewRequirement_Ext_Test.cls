@isTest
public class ViewRequirement_Ext_Test {

    public static testMethod void testAssociateFields() {
        Requirements__c r = new Requirements__c();
        insert r;
        
        System_Field__c f1 = new System_Field__c(Name = 'Test 1', Object__c = 'Account');
        System_Field__c f2 = new System_Field__c(Name = 'Test 2', Object__c = 'Account');
        insert f1;
        insert f2;
        
        Requirement_System_Field_Relationship__c j = new Requirement_System_Field_Relationship__c(Requirements__c = r.Id, System_Field__c = f1.Id);
        insert j;
        
        Test.startTest();
        
        Test.setCurrentPage(Page.ViewRequirement);
        ApexPages.currentPage().getParameters().put('id',r.Id);
        ApexPages.StandardController con = new ApexPages.StandardController(r);
        ViewRequirement_Ext reqPage = new ViewRequirement_Ext(con);
        
        System.assert(true, reqPage.assignedFieldsList[0].getValue() == f1.Id);
        System.assert(true, reqPage.unassignedFieldsList[0].getValue() == f2.Id);
        
        List<SelectOption> newAssigned = new List<SelectOption>();
        List<SelectOption> newUnassigned = new List<SelectOption>();
        newAssigned.add(new SelectOption(f2.Id, f2.Name));
        newUnassigned.add(new SelectOption(f1.Id, f1.Name));
        
        reqPage.assignedFieldsList = newAssigned;
        reqPage.unassignedFieldsList = newUnassigned;
        
        reqPage.doSave();
        
        List<Requirement_System_Field_Relationship__c> newJunctions = [SELECT Id, System_Field__c FROM Requirement_System_Field_Relationship__c];
        
        System.assertEquals(1,newJunctions.size());
        System.assert(true, newJunctions[0].System_Field__c == f2.Id);
        
        reqPage.refreshFilter();
        
        Test.stopTest();
    }

}