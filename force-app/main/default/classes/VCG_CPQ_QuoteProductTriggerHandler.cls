public without sharing class VCG_CPQ_QuoteProductTriggerHandler {
    
    public static void onAfterInsert(map<Id,VCG_CPQ_Quote__c >newMap)
    {
        list<VCG_CPQ_Quote__c > quoteList = new list<VCG_CPQ_Quote__c >();
            
    }
    
    public static void onAfterDelete(map<Id,VCG_CPQ_Quote__c >oldMap)
    {
        list<VCG_CPQ_Quote__c > quoteList = new list<VCG_CPQ_Quote__c >();
            
    }

}