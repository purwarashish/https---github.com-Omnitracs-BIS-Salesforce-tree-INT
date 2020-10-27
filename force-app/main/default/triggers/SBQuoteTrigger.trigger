/***
Developer   : Sripathi Gullapalli
Date        : 10/18/2016
Description : Trigger to update the "Primary Qupote Approval Status" field on the Opportunity from the Status field on the primary Quote
**/
trigger SBQuoteTrigger on SBQQ__Quote__c (after insert, after update, before insert, before update) {
    BypassTriggerUtility u = new BypassTriggerUtility();  
    if (u.isTriggerBypassed()) {
        return;
    }
    
    if (Trigger.isBefore) {
        System.debug('SBQuoteTrigger.IsBefore');
        if(Trigger.isInsert){
            SBQuoteTriggerHandler.setContractValuesOnQuote(Trigger.New);
        }
        else if(Trigger.isUpdate){
            SBQuoteTriggerHandler.updateEndDate(Trigger.new, Trigger.oldMap);
        }
    }
    if (Trigger.isUpdate && Trigger.isAfter) {
        System.debug('SBQuoteTrigger.AfterUpdate');
        SBQuoteTriggerHandler.updateOppQuoteStatus(Trigger.New, Trigger.oldMap);
        SBQuoteTriggerHandler.updateQuoteLines(Trigger.New, Trigger.oldMap);
        
    }
}