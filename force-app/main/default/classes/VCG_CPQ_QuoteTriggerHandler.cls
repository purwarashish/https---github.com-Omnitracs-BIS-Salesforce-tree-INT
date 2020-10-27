public with sharing class VCG_CPQ_QuoteTriggerHandler {

    public enum triggeredAction{afterInsert, afterUpdate, beforeInsert, beforeUpdate}
    
    VCG_CPQ_QuoteTriggerHandler(){
    
    }
    
    public VCG_CPQ_QuoteTriggerHandler(VCG_CPQ_Quote__c[] quotes, VCG_CPQ_Quote__c[] oldQuotes, String context){
         
        //Before Insert
        if(context == triggeredAction.beforeInsert.name()){
            
            //Approval Code 

            
        }
        //Before Update
        if(context == triggeredAction.beforeUpdate.name()){
            
            // Approval Code
            // SW - disabled until approval logic is completed
            // VCG_CPW_ApprovalUtility.assignNextApprover(oldQuotes, quotes);
            
        }
        //After Insert
        if(context == triggeredAction.afterInsert.name()){
            // SW - disabled until approval logic is completed
            //VCG_CPQ_ApprovalUtility.intializeApproval(quotes);            
        }
        //After Update
        if(context == triggeredAction.afterUpdate.name()){
            
        }

    }
    
}