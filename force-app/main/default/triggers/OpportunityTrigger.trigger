trigger OpportunityTrigger on Opportunity (before update,after update) {

     /*BypassTriggerUtility u = new BypassTriggerUtility();  
     if (u.isTriggerBypassed()) {
         return;
     }
     
     
     Integer checkVal = Integer.valueof(System.Label.RecursiveTriggerCount);
     
     
      if(trigger.isBefore && trigger.isInsert) 
    if(OpportunityUtility.beforeInsertExecuted > checkVal )
      return;
    else
    {
      OpportunityUtility.beforeInsertExecuted ++;
    }
      
    if(trigger.isAfter && trigger.isInsert) 
    if(OpportunityUtility.afterInsertExecuted > checkVal)
      return;
    else{
      OpportunityUtility.afterInsertExecuted ++;
      }
    
    if(trigger.isAfter && trigger.isUpdate) 
    if(OpportunityUtility.afterUpdateExecuted > checkVal)
      return;
    else{
      OpportunityUtility.afterUpdateExecuted ++;
      }
      
    if(trigger.isBefore && trigger.isUpdate) 
    if(OpportunityUtility.beforeUpdateExecuted > checkVal)
      return;
    else{
      OpportunityUtility.beforeUpdateExecuted ++;
      }
      
    
    if  (Trigger.isBefore && Trigger.isUpdate){
        OpportunityUtility.oppStageOnChange(Trigger.new, Trigger.oldMap);
        OpportunityUtility.updateSpProduct(Trigger.new);
        OpportunityUtility.validateOpptyEditability(Trigger.new, Trigger.OldMap);
    }
    if  (Trigger.isAfter && Trigger.isUpdate) {
        OpportunityUtility.createUpdateAssets(Trigger.newMap, Trigger.oldMap); 
        //OpportunityContract.createOpportunity(Trigger.new,Trigger.isUpdate);
    }
    
    // When Legal sets Legal Review to "Waiting for Finance", trigger Finance Approval process
    if (Trigger.isBefore && Trigger.isUpdate) {
        OpportunityUtility.triggerFinanceApprovalBefore(Trigger.newMap, Trigger.oldMap);
    }
    // When Legal sets Legal Review to "Waiting for Finance", trigger Finance Approval process
    if (Trigger.isAfter && Trigger.isUpdate) {
        OpportunityUtility.triggerFinanceApprovalAfter(Trigger.newMap, Trigger.oldMap);
    }
    
    // NetSuite callout for Omni-Mex - Approved Quotes
    if ((Trigger.isAfter && Trigger.isUpdate) && Trigger.size == 1) {
        System.debug('*** BEGIN Netsuite Opportunity Integration ***');
        if (!NetsuiteSyncOpportunityHelper.hasRun){
                
            Set<Id> oppIdList = new Set<Id>();
            Set<Id> accountIdSet = new Set<Id>();
            Map<Id,Id> oppAccountIdMap = new Map<Id,Id>();
            
            for(Opportunity o : Trigger.new){
                accountIdSet.add(o.AccountId);
            }
            
            for(Account a:[SELECT Id, Send_to_NetSuite__c FROM Account WHERE Id IN: accountIdSet]){
                 if(a.Send_to_NetSuite__c == true){
                     system.debug('*** Send To Netsuite is TRUE');
                     oppAccountIdMap.put(a.Id,a.Id);
                 }
            }
            for(Opportunity o : Trigger.new){
                // We send newly approved Quotes and previously approved recalled Quotes
                system.debug('**** Old Stat Value:' + Trigger.oldMap.get(o.Id).Primary_Quote_Approval_Status__c);
                system.debug('**** New Stat Value:' + o.Primary_Quote_Approval_Status__c);
                system.debug('**** AccountIdMap:' + oppAccountIdMap.get(o.AccountId));
                if(oppAccountIdMap.get(o.AccountId) != null && 
                   ((o.Primary_Quote_Approval_Status__c == 'Approved' && Trigger.oldMap.get(o.Id).Primary_Quote_Approval_Status__c != 'Approved') ||
                   (o.Primary_Quote_Approval_Status__c == 'Recalled' && Trigger.oldMap.get(o.Id).Primary_Quote_Approval_Status__c == 'Approved'))){
                    System.debug('**** BEGIN CODE for Netsuite & Quote Integration:' + o.Id);
                    oppIdList.add(o.Id);
                }            
            }  
            
            if(oppIdList.size()>0){
                NetsuiteSyncOpportunityHelper.postDataToNetsuite(oppIdList);        
            }
            
            //Set hasRun boolean to false to prevent recursion
            NetsuiteSyncOpportunityHelper.hasRun = true;
        }  
    }*/
}