/**********************************************************
* @Author       Heidi Tang
* @Date         2016-04-25
* @Description  KeyPlayers/Influencers trigger
* @Requirement  REQ-0482 Auto-populate Contact Roles with Key Players/Influencers value.
**********************************************************/
trigger KeyPlayersTrigger on Key_Players_Influencers__c (before insert,after insert, after update,before update, before delete) {
    
    KeyPlayersTriggerHandler handler = new KeyPlayersTriggerHandler();
    
    if(Trigger.isBefore){
        if(Trigger.isInsert){
            handler.onBeforeInsert(Trigger.new);
        } else if(Trigger.isUpdate){
            handler.onBeforeUpdate(Trigger.new,Trigger.oldMap);
        } else if(Trigger.isDelete){
            handler.onBeforeDelete(Trigger.old);            
        }
    } else if(Trigger.isAfter){
        if(Trigger.isInsert){
            handler.onAfterInsert(Trigger.newMap);            
        } else if(Trigger.isUpdate){
            handler.onAfterUpdate(Trigger.newMap, Trigger.oldMap);            
        }
    }
}