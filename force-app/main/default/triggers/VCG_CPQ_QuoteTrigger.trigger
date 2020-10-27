trigger VCG_CPQ_QuoteTrigger on VCG_CPQ_Quote__c (after insert, after update, before insert, before update) {
    
    public enum triggerAction{afterInsert, afterUpdate, beforeInsert, beforeUpdate} 

    //Case 01796708
    //Upon saving a quote the system checks to make sure there is already a primary quote and 
    //if not it enforces that there needs to be 1 primary quote before saving
    if(trigger.isBefore)
    {
        map<Id, boolean> OppsWithApprovedQuote = new map<Id, boolean>();
        for(VCG_CPQ_Quote__c q : trigger.new)
        {
            OppsWithApprovedQuote.put(q.Opportunity__c, q.Is_Primary__c);
        }
        
        //look across all other Quotes
        for(VCG_CPQ_Quote__c q : [Select Id, Is_Primary__c, Opportunity__c 
                                     from VCG_CPQ_Quote__c 
                                   where Opportunity__c in :OppsWithApprovedQuote.keySet()
                                     and Is_Primary__c = true
                                     and (NOT(Id in :trigger.new))])
        {
            OppsWithApprovedQuote.put(q.Opportunity__c, q.Is_Primary__c);
        }
        
        for(VCG_CPQ_Quote__c q : trigger.new)
        {
            if(OppsWithApprovedQuote.get(q.Opportunity__c) == false && q.Is_Primary__c == false)
                q.Is_Primary__c.addError('An opportunity must have at least one primary quote');
        }
            
    }
    if(Trigger.isBefore) {
        if(Trigger.isInsert) {
            // Don't call any approval stuff on insert!! None of the Quote Product records will exist!
        }
        if(Trigger.isUpdate) {
            VCG_CPQ_ApprovalUtility.quoteTriggerHandler(trigger.old, trigger.new, triggerAction.beforeUpdate.name());
            
            //QuoteUtility.setMSADocIds(Trigger.newMap);    
        }       
    }
    
    if(Trigger.isAfter) {
        if(Trigger.isInsert) {
            
        }
        if(Trigger.isUpdate) {            
            VCG_CPQ_ApprovalUtility.quoteTriggerHandler(trigger.old, trigger.new, triggerAction.afterUpdate.name());
                        
            //
            // Apply Quote Status to Opp.Primary_Quote_Approval_Status__c for primary quotes
            // ... but only if Quote.Status has changed, or if the Quote has just been set to Is Primary
            //
            {
                List<Opportunity> oppsToUpdate = new List<Opportunity>();
                for (VCG_CPQ_Quote__c newQ : Trigger.new) {
                    VCG_CPQ_Quote__c oldQ = Trigger.oldMap.get(newQ.Id);
                    
                    if (newQ.Is_Primary__c == true && (newQ.Status__c != oldQ.Status__c || newQ.Is_Primary__c != oldQ.Is_Primary__c)) {
                        oppsToUpdate.add(new Opportunity( Id = newQ.Opportunity__c, Primary_Quote_Approval_Status__c = newQ.Status__c));
                    }
                }
                update oppsToUpdate;
            }
        }
    }
    
}