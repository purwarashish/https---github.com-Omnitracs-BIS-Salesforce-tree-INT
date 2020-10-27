public class OpportunityTriggerHandler {
    public static void onBeforeUpdate(List<Opportunity> newOppList, Map<Id, Opportunity> oldOppMap){
        oppStageOnChange(newOppList, oldOppMap);
    }
    
    private static void oppStageOnChange(List<Opportunity> newOppList, Map<Id, Opportunity> oldOppMap){
        for (Opportunity newOpp : newOppList) {
            Opportunity oldOpp = oldOppMap.get(newOpp.Id);
            if (oldOpp.StageName != newOpp.StageName && newOpp.StageName == 'Closed Won') {
                List<VCG_CPQ_Quote_Product__c> checkList  = [SELECT Id 
                                                             FROM VCG_CPQ_Quote_Product__c 
                                                             WHERE Product__r.Shipment_Schedule_Required__c = TRUE 
                                                             AND Quote__r.Is_Primary__c = TRUE 
                                                             AND Number_of_Shipment_Forecasts__c = 0 
                                                             AND Quote__r.Opportunity__c = : newOpp.Id];
                if (checkList.size() > 0){
                    newOpp.addError('Cannot change Opportunity Stage. There are missing Shipment Schedules for Products that require them.');
                }
            }
        }
    }
    
}