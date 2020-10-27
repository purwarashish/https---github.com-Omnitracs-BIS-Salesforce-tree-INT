@isTest
public class ViewSystemField_Ext_Test {

    public static testMethod void testAssociateFields() {
        System_Field__c f = new System_Field__c();
        insert f;
        
        Source_Field__c sf1 = new Source_Field__c(Field_Name__c = 'Test 1', Source_System__c = 'Sylectus Other', System_Field__c = f.id, Source_Object__c = 'Account');
        Source_Field__c sf2 = new Source_Field__c(Field_Name__c = 'Test 2', Source_System__c = 'Sylectus Other', Source_Object__c = 'Account');
        insert sf1;
        insert sf2;
        
        Test.startTest();
        
        Test.setCurrentPage(Page.ViewSystemField);
        ApexPages.currentPage().getParameters().put('id',f.Id);
        ApexPages.StandardController con = new ApexPages.StandardController(f);
        ViewSystemField_Ext fieldPage = new ViewSystemField_Ext(con);
        
        System.assert(true, fieldPage.assignedFieldsList[0].getValue() == sf1.Id);
        System.assert(true, fieldPage.unassignedFieldsList[0].getValue() == sf2.Id);
        
        List<SelectOption> newAssigned = new List<SelectOption>();
        List<SelectOption> newUnassigned = new List<SelectOption>();
        newAssigned.add(new SelectOption(sf2.Id, sf2.Field_Name__c));
        newUnassigned.add(new SelectOption(sf1.Id, sf1.Field_Name__c));
                
        fieldPage.assignedFieldsList = newAssigned;
        fieldPage.unassignedFieldsList = newUnassigned;
        
        fieldPage.doSave();
        
        Source_Field__c newsf1 = [SELECT Id, System_Field__c FROM Source_Field__c WHERE Id =: sf1.Id LIMIT 1];
        Source_Field__c newsf2 = [SELECT Id, System_Field__c FROM Source_Field__c WHERE Id =: sf2.Id LIMIT 1];
        
        System.assert(true, newsf1.System_Field__c == null);
        System.assert(true, newsf2.System_Field__c == f.Id);
        
        fieldPage.refreshFilter();
        
        Test.stopTest();
    }

}