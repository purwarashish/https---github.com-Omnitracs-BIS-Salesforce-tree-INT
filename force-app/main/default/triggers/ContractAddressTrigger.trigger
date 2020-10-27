trigger ContractAddressTrigger on Contract_Address__c (after insert,after update) {
    if(Trigger.isAfter){
        if(Trigger.isInsert){
            ContractAddressTriggerHandler.insertContAddress(trigger.new);
        }
        if(Trigger.isUpdate){
            ContractAddressTriggerHandler.updateCloneCAddress(trigger.new,trigger.oldMap);
        }
    }
}