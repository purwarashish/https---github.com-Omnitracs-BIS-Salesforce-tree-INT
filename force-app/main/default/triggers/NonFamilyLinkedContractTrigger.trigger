trigger NonFamilyLinkedContractTrigger on Non_Family_Linked_Contracts__c (after insert,after update) {
    if(Trigger.isAfter){
        if(Trigger.isInsert){
            NonFamilyLinkedContractTriggerHandler.insertNFLinkedContract(trigger.new);
        }
        if(Trigger.isUpdate){
            NonFamilyLinkedContractTriggerHandler.updateNFLinkedContract(trigger.new,trigger.oldMap);
        }
    }
}