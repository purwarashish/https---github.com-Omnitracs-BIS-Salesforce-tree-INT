public with sharing class VCG_CPQ_ObjectManagementController {
        
        public string getSecurityRestrictionUrl()
        {
                Schema.DescribeSObjectResult r = VCG_CPQ_Security_Restriction__c.sObjectType.getDescribe();
                String keyPrefix = r.getKeyPrefix();
                
                return '/'+keyPrefix;
        }
        
        public string getPricingAccessSequenceUrl()
        {
                Schema.DescribeSObjectResult r = VCG_CPQ_Pricing_Access_Sequence__c.sObjectType.getDescribe();
                String keyPrefix = r.getKeyPrefix();
                
                return '/'+keyPrefix;
        }
        
        public string getPricingProcedureUrl()
        {
                Schema.DescribeSObjectResult r = VCG_CPQ_Pricing_Procedure__c.sObjectType.getDescribe();
                String keyPrefix = r.getKeyPrefix();
                
                return '/'+keyPrefix;
        }
        
        public string getPricingConditionUrl()
        {
                Schema.DescribeSObjectResult r = VCG_CPQ_Pricing_Condition__c.sObjectType.getDescribe();
                String keyPrefix = r.getKeyPrefix();
                
                return '/'+keyPrefix;
        }
        
        public string getPricingConditionDataUrl()
        {
                Schema.DescribeSObjectResult r = VCG_CPQ_Pricing_Condition_Data__c.sObjectType.getDescribe();
                String keyPrefix = r.getKeyPrefix();
                
                return '/'+keyPrefix;
        }
        
        public string getApprovalConditionsUrl()
        {
                Schema.DescribeSObjectResult r = VCG_CPQ_Approval_Condition__c.sObjectType.getDescribe();
                String keyPrefix = r.getKeyPrefix();
                
                return '/'+keyPrefix;
        }
        
        public string getApprovalGroupMatricesUrl()
        {
                Schema.DescribeSObjectResult r = VCG_CPQ_Approval_Group_Matrix__c.sObjectType.getDescribe();
                String keyPrefix = r.getKeyPrefix();
                
                return '/'+keyPrefix;
        }
        
        public string getApprovalGroupsUrl()
        {
                Schema.DescribeSObjectResult r = VCG_CPQ_Approval_Group__c.sObjectType.getDescribe();
                String keyPrefix = r.getKeyPrefix();
                
                return '/'+keyPrefix;
        }
        
        public string getBundlesUrl()
        {
                Schema.DescribeSObjectResult r = VCG_CPQ_Bundle__c.sObjectType.getDescribe();
                String keyPrefix = r.getKeyPrefix();
                
                return '/'+keyPrefix;
        }
        
        public string getOpportunityQuoteMapsUrl()
        {
            return getOppToQuoteMapsUrl();
        }
        public string getOppToQuoteMapsUrl()
        {
                Schema.DescribeSObjectResult r = VCG_CPQ_Opportunity_Quote_Map__c.sObjectType.getDescribe();
                String keyPrefix = r.getKeyPrefix();
                
                return '/'+keyPrefix;
        }
        
        public string getQuoteToOppMapsUrl()
        {
                Schema.DescribeSObjectResult r = VCG_CPQ_Quote_Opportunity_Map__c.sObjectType.getDescribe();
                String keyPrefix = r.getKeyPrefix();
                
                return '/'+keyPrefix;
        }
        
        public string getQLItoOLIMapsUrl()
        {
                Schema.DescribeSObjectResult r = VCG_CPQ_Quote_Product_Oppty_Product_Map__c.sObjectType.getDescribe();
                String keyPrefix = r.getKeyPrefix();
                
                return '/'+keyPrefix;
        }
        
        public string getPricingProcedureSequencesUrl()
        {
                Schema.DescribeSObjectResult r = VCG_CPQ_Pricing_Procedure_Sequence__c.sObjectType.getDescribe();
                String keyPrefix = r.getKeyPrefix();
                
                return '/'+keyPrefix;
        }
        
        public string getPricingSequenceConditionUrl()
        {
                Schema.DescribeSObjectResult r = VCG_CPQ_Pricing_Sequence_Condition__c.sObjectType.getDescribe();
                String keyPrefix = r.getKeyPrefix();
                
                return '/'+keyPrefix;
        }

    public string getProductAddonsUrl()
        {
                Schema.DescribeSObjectResult r = VCG_CPQ_Product_Addon__c.sObjectType.getDescribe();
                String keyPrefix = r.getKeyPrefix();
                
                return '/'+keyPrefix;
        }     
    
        public string getProductEquivalencyUrl()
        {
                Schema.DescribeSObjectResult r = VCG_CPQ_Product_Equivalency__c.sObjectType.getDescribe();
                String keyPrefix = r.getKeyPrefix();
                
                return '/'+keyPrefix;
        }
        
        public string getProductFilterUrl()
        {
                Schema.DescribeSObjectResult r = VCG_CPQ_Product_Filter__c.sObjectType.getDescribe();
                String keyPrefix = r.getKeyPrefix();
                
                return '/'+keyPrefix;
        }
        
        public string getProductIncompatibilitiesUrl()
        {
                Schema.DescribeSObjectResult r = VCG_CPQ_Product_Incompatibility__c.sObjectType.getDescribe();
                String keyPrefix = r.getKeyPrefix();
                
                return '/'+keyPrefix;
        }
        
        public string getProductRulesUrl()
        {
                Schema.DescribeSObjectResult r = VCG_CPQ_Product_Rule__c.sObjectType.getDescribe();
                String keyPrefix = r.getKeyPrefix();
                
                return '/'+keyPrefix;
        }
        
        public string getQuoteProductPricingResultsUrl()
        {
                Schema.DescribeSObjectResult r = VCG_CPQ_Quote_Product_Pricing_Result__c.sObjectType.getDescribe();
                String keyPrefix = r.getKeyPrefix();
                
                return '/'+keyPrefix;
        }
    
        public string getUserHierarchyUrl()
        {
                Schema.DescribeSObjectResult r = VCG_CPQ_User_Hierarchy__c.sObjectType.getDescribe();
                String keyPrefix = r.getKeyPrefix();
                
                return '/'+keyPrefix;
        }
   
        public string getFieldLayoutsUrl()
        {
                Schema.DescribeSObjectResult r = VCG_CPQ_Page_Layout__c.sObjectType.getDescribe();
                String keyPrefix = r.getKeyPrefix();
                
                return '/'+keyPrefix;
        }
   
    
}