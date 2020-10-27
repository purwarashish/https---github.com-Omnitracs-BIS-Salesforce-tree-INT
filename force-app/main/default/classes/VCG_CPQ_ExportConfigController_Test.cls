/**
 * Test class for VCG_CPQ_ExportConfigController
 *
 * @author  Lawrence Coffin <lawrence.coffin@cloudsherpas.com>
 * @since   4.May.2015
 */
@isTest
public class VCG_CPQ_ExportConfigController_Test {
    
    /**
     * Base test
     *
     * @author  Lawrence Coffin <lawrence.coffin@cloudsherpas.com>
     * @since   4.May.2015
     */
    static testMethod void testExportConfigController()
    {
        Test.startTest();
        //Insert VCG_CPQ_Pricing_Procedure__c
        VCG_CPQ_Pricing_Procedure__c PricingProcedure = new VCG_CPQ_Pricing_Procedure__c();

        PricingProcedure.Name = 'Test Pricing Procedure';
        PricingProcedure.Active__c = true;
        PricingProcedure.Description__c = 'Test Pricing Procedure';
        PricingProcedure.Needs_Fields__c = 'Test Pricing Procedure';
        PricingProcedure.Quote_Line_Type__c = 'New';
        PricingProcedure.Sequence__c = 12345;
        
        Insert PricingProcedure;
        //Insertion complete
        //Insert VCG_CPQ_Pricing_Access_Sequence__c
        VCG_CPQ_Pricing_Access_Sequence__c PricingAccessSequence = new VCG_CPQ_Pricing_Access_Sequence__c();

        PricingAccessSequence.Name = 'Test Pricing Access Sequence';
        PricingAccessSequence.Assign_To__c = 'Test User';
        PricingAccessSequence.Comments__c = 'Test Comment';
        PricingAccessSequence.Debug__c = true;
        PricingAccessSequence.Description__c = 'Test Description';
        PricingAccessSequence.Needs_Fields__c = 'Test Need';
        
        Insert PricingAccessSequence;
        //Insertion Complete
        //Insert VCG_CPQ_Pricing_Condition__c
        VCG_CPQ_Pricing_Condition__c PricingCondition = new VCG_CPQ_Pricing_Condition__c();

        PricingCondition.Calculation_Compiled__c = 'Test Pricing Condition';
        PricingCondition.Calculation__c = 'Test Pricing Condition';
        PricingCondition.Data_Key_Definition__c = 'Test Pricing Procedure';
        PricingCondition.Data_Scale_Field_1__c = 'Test Data Scale 1';
        PricingCondition.Data_Scale_Field_2__c = 'Test Data Scale 2';
        PricingCondition.Data_Scale_Field_3__c = 'Test Data Scale 3';
        PricingCondition.Description__c = 'Test Pricing Condition';
        PricingCondition.Is_Pricing_Related__c = true;
        PricingCondition.Needs_Fields__c = 'Test Pricing Condition';
        PricingCondition.Type__c = 'Static';
        
        Insert PricingCondition;
        //Insertion Complete
        //Insert VCG_CPQ_Pricing_Procedure_Sequence__c
        VCG_CPQ_Pricing_Procedure_Sequence__c PricingProcedureSequence = new VCG_CPQ_Pricing_Procedure_Sequence__c();
        PricingProcedureSequence.Name = 'Test Pricing Procedure Sequence';
        PricingProcedureSequence.Pricing_Procedure__c = PricingProcedure.Id;
        PricingProcedureSequence.Access_Sequence__c = PricingAccessSequence.Id;
        PricingProcedureSequence.Sequence__c = 12345;
        Insert PricingProcedureSequence;
        //Insertion Complete
        VCG_CPQ_ExportConfigController controller = new VCG_CPQ_ExportConfigController();
        controller.generateConfigXML();
        
        System.assertNotEquals(null, controller.configXML);
        System.assertNotEquals('', controller.configXML);
        
        Test.stopTest();
    }
}