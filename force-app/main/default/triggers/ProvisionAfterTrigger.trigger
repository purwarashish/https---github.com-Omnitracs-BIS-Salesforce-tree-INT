/***
 Case #02275674 -- Created - Sripathi Gullapalli
 Method to update Cap % on Contract, when Provision "Price Increase Cap" field is changed
***/
trigger ProvisionAfterTrigger on Provision__c (after insert, after update) {
    
    if (trigger.isInsert || trigger.isUpdate){
    	ProvisionAfterTriggerHandler.updateContract(trigger.newMap,trigger.oldMap);  
    }
}