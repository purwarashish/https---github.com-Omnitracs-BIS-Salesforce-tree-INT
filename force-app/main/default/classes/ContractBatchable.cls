/**
 * Batchable class used to update the QuoteLineGroup field.
 */

global class ContractBatchable implements Database.Batchable<sObject>, Database.Stateful {

    //private Integer syncFrequency = SVCCloudHelper.getSyncFrequencyFromSettings(serviceName);
    // Defines the number of minutes to schedule the job in the future. 10 = 10 minutes.
    private Integer syncFrequency = 60;
    private final String QUERY = 'SELECT Id, Name, Quote_Line_Group__c FROM Contract WHERE Quote_Line_Group__c = null';
    private Boolean manualReschedule = false;

    global ContractBatchable() {

    }

    global ContractBatchable(Boolean isManualReschedule) {
        manualReschedule = isManualReschedule;
    }

    global void isRunInTest() {
        manualReschedule = false;
    }

    global Database.QueryLocator start(Database.BatchableContext batchableContext){
        System.debug('ContractBatchable.start() Starting contract batchable.');
        return Database.getQueryLocator(QUERY);
    }

    /**
     * Receive a list of contract objects without the Quote Line Group field set.
     * Find the associated subscriptions and quote lines for the contracts.
     * Map the contract Id to the quote line group id.
     * Update the contracts.
     */
    global void execute(Database.BatchableContext batchableContext, List<sObject> scope) {
        List<Contract> contractList = new List<Contract>();
        List<Contract> updateContractList = new List<Contract>();

        for(sObject abstractObject: scope) {
            Contract contract = (Contract) abstractObject;
            contractList.add(contract);

        }

        Map<Id, Id> contractIdToQuoteLineGroupIdMap = new Map<Id, Id>();
        if(contractList.size() > 0) {
            List<SBQQ__Subscription__c> subscriptionList = [SELECT Id, SBQQ__Contract__c, SBQQ__QuoteLine__c, SBQQ__QuoteLine__r.SBQQ__Group__c FROM SBQQ__Subscription__c WHERE SBQQ__Contract__c IN :contractList];
            if(subscriptionList.size() > 0) {
                for(SBQQ__Subscription__c subscription: subscriptionList) {
                    contractIdToQuoteLineGroupIdMap.put(subscription.SBQQ__Contract__c, subscription.SBQQ__QuoteLine__r.SBQQ__Group__c);
                }
            }
        }

        for(Contract contract: contractList) {
            if(contractIdToQuoteLineGroupIdMap.containsKey(contract.Id)) {
                contract.Quote_Line_Group__c = contractIdToQuoteLineGroupIdMap.get(contract.Id);
                updateContractList.add(contract);
            }
        }

        if(updateContractList.size() > 0) {
            update updateContractList;
        }

    }

    global void finish(Database.BatchableContext batchableContext) {
        System.debug('ContractBatchable Finished');
        rescheduleThis();
    }

    private void rescheduleThis() {
        if(manualReschedule) {
            ContractBatchable batch = new ContractBatchable();
            System.scheduleBatch(batch, 'Contract Batch Sync', syncFrequency);
        }
    }
}