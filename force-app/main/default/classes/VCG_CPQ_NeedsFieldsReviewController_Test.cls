/**
 * @description  Tests the NeedsFieldsReviewController and associatied methods in NeedsFieldsUtility
 * 
 * @author  Lawrence Coffin <lawrence.coffin@cloudsherpas.com>
 * @since   14.Apr.2015
 */
@isTest
private class VCG_CPQ_NeedsFieldsReviewController_Test {

    static testMethod void testNeedsFieldsReviewController() {
    	//
    	// Set up some records with Needs Fields defined
    	//
        VCG_CPQ_Product_Filter__c productFilterRecord1 = new VCG_CPQ_Product_Filter__c (Needs_Fields__c = 'Opportunity__r.StageName;Is_Primary__c;Account__r.BillingCountry ', IsActive__c = true);
        insert productFilterRecord1;
        VCG_CPQ_Product_Rule__c productRuleRecord1 = new VCG_CPQ_Product_Rule__c(Needs_Fields__c = 'Opportunity__r.StageName;Status__c');
        insert productRuleRecord1;
        VCG_CPQ_Product_Addon__c productAddonRecord1 = new VCG_CPQ_Product_Addon__c(Needs_Fields__c = 'Product__r.MarketGroup__c' );
        insert productAddonRecord1;
        VCG_CPQ_Opportunity_Quote_Map__c opportunityRecord1 = new VCG_CPQ_Opportunity_Quote_Map__c(Needs_Fields__c = 'Asset__r.License_Metric_Quantity__c;Is_Primary__c;Account__r.BillingCountry;', Active__c= true, Source__c = 'Name');
        insert opportunityRecord1;
        VCG_CPQ_Approval_Condition__c approvalConditionRecord1 = new VCG_CPQ_Approval_Condition__c( Needs_Fields__c = 'Quote_Products__r.Line_Type__c;Quote_Products__r.Product__r.Family;Effective_Date__c;Is_Primary__c;Account__r.BillingCountry', IsActive__c = TRUE);
        insert approvalConditionRecord1;
        
        VCG_CPQ_Pricing_Procedure__c ppExtension = VCG_CPQ_Helper.CreatePricingProcedure('Extension', 'Extension', 30);
        VCG_CPQ_Helper.AddAccessSequence(ppExtension, 20, 'AdjListPrice2', null, null, null, 'Quote__r.Opportunity__r.Deal_Type__c;Asset__r.Annual_Subscription__c');
    	
    	//
    	// Get the list of needs fields and their sources
    	//
    	VCG_CPQ_NeedsFieldsReviewController controller = new VCG_CPQ_NeedsFieldsReviewController();
        Map<String,Map<String,List<sObject>>> needsFieldsSourceMap = controller.getNeedsFieldsSourceMap();
        
        /** @todo  Flesh this out with more tests ... */
        System.assertEquals(11, needsFieldsSourceMap.size());
        System.assertEquals(3, needsFieldsSourceMap.get('Account__r.BillingCountry').size());
        System.assertEquals(1, needsFieldsSourceMap.get('Account__r.BillingCountry').get('Approval Condition').size());
    }
}