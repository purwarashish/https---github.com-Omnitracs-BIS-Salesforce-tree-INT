trigger AtRiskTrigger on At_Risk__c (after insert, after update, before insert, before update) {

    if (Trigger.isbefore) {
        AtRiskUtility.makePrimary(Trigger.new);
    }
    
    if (Trigger.isAfter) {
        if (Trigger.isInsert){
            AtRiskUtility.copyAlertToAccount(Trigger.new);    
        }        
        If (Trigger.isUpdate){
            AtRiskUtility.updateCopyAlertToAccount(Trigger.new, Trigger.oldMap);
        }
    }
}