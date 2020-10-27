public class OpportunityQuoteTriggerHandler { 
    public static Boolean isFirstTime = true;
    public static void updateQuoteStartDate(Map<Id, Opportunity> newMap, Map<Id, Opportunity> oldMap){
        Map<ID, Opportunity> opptyMap = null;
        List<SBQQ__Quote__c> quoteList = new List<SBQQ__Quote__c>();
        for(Opportunity newOpp : newMap.values()){
            Opportunity oldOpp = oldMap.get(newOpp.Id);
            System.debug('From OpportunityQuoteTriggerHandler: ' + oldOpp.stageName + ' -- ' + newOpp.stageName);
			List<String> notToUpdateTypes = new list<String> { 'Annual Increase Within Term', 'Auto Renewal With Increase', 'Auto Renewal Without Increase', 'Renewal Within Term (No Increase)' };
			if((newOpp.stageName != oldOpp.stageName || Test.isRunningTest()) && !notToUpdateTypes.contains(newOpp.Order_Type__c) && !newOpp.Backdating_Opportunity__c && newOpp.stageName == 'Closed Won' && OpportunityQuoteTriggerHandler.isFirstTime){
                OpportunityQuoteTriggerHandler.isFirstTime = false;
                if(opptyMap == null){
                    opptyMap = new Map<ID, Opportunity>([select Id, closeDate, (select Id, SBQQ__Type__c, SBQQ__StartDate__c from SBQQ__Quotes2__r where SBQQ__Primary__c = true Order By LastModifiedDate DESC Limit 1), (SELECT Id, StartDate from Contracts1__r Order By LastModifiedDate DESC Limit 1) from Opportunity where Id in :newMap.keySet()]);
                }
                Opportunity oppty = opptyMap.get(newOpp.Id);
                SBQQ__Quote__c quote = oppty.SBQQ__Quotes2__r != null && oppty.SBQQ__Quotes2__r.size() > 0 ? oppty.SBQQ__Quotes2__r[0] : null;
				if(quote != null){
					Contract contract = oppty.Contracts1__r != null && oppty.Contracts1__r.size() > 0 ? oppty.Contracts1__r[0] : null;
					Date startDate;
					if(contract == null){
						startDate = newOpp.CloseDate;
						System.debug('Updated Date from Opportunity Scenario: ' + startDate);
						
					}else{
						startDate = contract.startDate;
						System.debug('Updated Date from Contracts Scenario: ' + startDate);
					}
					quote.SBQQ__StartDate__c = startDate;
					quoteList.add(quote);
				}
            }
        }
        if(quoteList.size() > 0)
            update quoteList;
    }
}