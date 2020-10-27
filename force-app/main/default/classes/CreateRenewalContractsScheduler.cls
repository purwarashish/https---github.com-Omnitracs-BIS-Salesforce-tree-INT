global Class CreateRenewalContractsScheduler implements Schedulable{
    public static string saaQuery;
	public void CreateRenewalContractsScheduler(){
    }
    
    global void execute(SchedulableContext SC)
    {
        String saaQuery = 'Select Id,AccountID,SBQQ__Quote__c,EndDate, (select Id, Contract__c from SAA_Contracts__r) from Contract where RecordTypeId = \'01250000000J5nX\' and '+
            			  'endDate <=:todayDate and endDate >=:startofMonth and SBQQ__RenewalOpportunity__c != null';
        CreateRenewalContractsBatch crcs = new CreateRenewalContractsBatch(saaQuery);
        database.executeBatch(crcs);
    }
}