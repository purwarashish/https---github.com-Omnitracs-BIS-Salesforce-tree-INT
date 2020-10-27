/*********************************************************************************************************
Name  : AllServiceAgreementAdjustmentTrigger
Objective: Trigger for Service Agreement Adjustment oject
Author: Rittu Roy
Date: 2/8/2016

**********************************************************************************************************/
trigger AllServiceAgreementAdjustmentTrigger on Service_Agreement_Adjustment__c (after insert, after update) {
    
    //Logic to bypass trigger execution
    BypassTriggerUtility u = new BypassTriggerUtility();  
    if (u.isTriggerBypassed()) {
        return;
    }
   
    if (trigger.isInsert){
        if (trigger.isAfter){
            ServiceAgreementAdjustmentUtils.sendUpliftNotification(trigger.newMap,trigger.oldMap);  
        }
    }
    
    if (trigger.isUpdate){
        if (trigger.isAfter){
            ServiceAgreementAdjustmentUtils.sendUpliftNotification(trigger.newMap,trigger.oldMap);  
        }
    }
    
    //Case #02275674, Sripathi Gullapalli, Method to update Last Uplifted Date on Contract from SAA
    if (trigger.isInsert || trigger.isUpdate){
    	ServiceAgreementAdjustmentUtils.updateContract(trigger.newMap,trigger.oldMap);  
    }
}