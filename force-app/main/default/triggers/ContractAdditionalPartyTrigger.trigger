trigger ContractAdditionalPartyTrigger on Contract_Additional_Parties__c (after insert,after update) {
    // if(checkRecursive.runOnce()){
        if(Trigger.isAfter){
            if(Trigger.isInsert){
                ContractAdditionalPartyTriggerHandler.insertCAParty(Trigger.new);
            }
            if(Trigger.isUpdate){
                ContractAdditionalPartyTriggerHandler.updateClonedCAParty(Trigger.new,Trigger.oldMap);
            }
        }
    // }
}