public class BatchCustomerHealthAssetData implements database.batchable<sobject>{
    public string query;
    public date todays;
    
    public BatchCustomerHealthAssetData(){
    	//todays = Date.Today();
    	query = 'SELECT Account__c, Account__r.ID, ARR__c, Maintenance_Status__c FROM Asset__c WHERE Maintenance_Status__c != \'Decommissioned\' and Account__r.No_Of_Active_scoring_Subscription__c > 0'; 
    }    
        
    public database.querylocator start(database.batchableContext bc){
    	//String query = 'Select Term_Type__c, Account, Status, EndDate, Record_Type__c, Contract_Status__c, Agreement_Type__c, AccountId From Contract Where Term_Type__c = \'Fixed\' AND Record_type__c = \'Customer Agreement\' AND Status = \'Active\' AND Agreement_Type__c = \'Master\'';
        return database.getquerylocator(query);
    }
    
    public void execute(Database.BatchableContext BC, list<sObject> scope){ 
    		List<Asset__c> assets1 = new List<Asset__c>();
    		List<Account> listOfAccountsToUpdate = new List<Account>();
    		Set<ID> usedAccountIDs = new Set<ID>();
    		Map<Asset__c, ID> assetsToAccounts = new Map<Asset__c, ID>();
    		Double additionVar;
    		
    		util.debug('Contracts should have been queried.  Number passed into this method: ' + scope == null ? 0 : scope.size());
    		//Date todaysDate;
    		Integer numofDaysBetween;
    		Decimal comparisonValue;
    		Date todaysDate;
    		//Contract c;
    		
    		//Map<Contract, ID> mapOfContractstoAccts;
    		for(Sobject s : scope){
    			Asset__c c = (Asset__c)s;
    			
    			assets1.add(c);
    			if(usedAccountIDs.contains(c.account__r.ID) == false){
    				usedAccountIDs.add(c.Account__r.Id);
    			}
    		}
    			
    			//if(!usedAccountIDs.contains(c.accountID)){
    			//	usedAccountIDs.add(c.accountID);
    			//}
    		//}
    		
    		
    		List<Account> usedAccounts = [Select ID, Customer_Health_Total_ARR__c from Account where ID IN: usedAccountIDs];
    		List<Asset__c> assets = [Select ID, Account__r.ID, ARR__c, Maintenance_Status__c from Asset__c where Maintenance_Status__c != 'Decommissioned' and Account__r.ID IN: usedAccountIDs];
    		System.debug('usedAccounts size ' + usedAccounts.size());
    		System.debug('assets size ' + assets.size());
    		for(Account a : usedAccounts){
    			a.Customer_Health_Total_ARR__c = 0.0;
    		}
    		
    		
    		for(Account a : usedAccounts){
    			System.debug('current account: ' + a);
    			for(Asset__c c : assets){
    				additionVar = 0.0;
    				system.debug('current asset: ' + c);
    				if(c.Account__r.ID == a.ID){
    					system.debug('Account and Asset matched: Value before is ' + a.Customer_Health_Total_ARR__c);
    					if(c.ARR__c == null || c.ARR__c == 0 || c.ARR__c < 0){
    					a.Customer_Health_Total_ARR__c = a.Customer_Health_Total_ARR__c;
    					}
    					else{
    						additionVar = a.Customer_Health_Total_ARR__c + c.ARR__c;
    						a.Customer_Health_Total_ARR__c = additionVar;
    					}
    					system.debug('Value after is ' + a.Customer_Health_Total_ARR__c);
    				}
    			}
    			listOfAccountsToUpdate.add(a);
    		}
    		
    		if(listOfAccountsToUpdate.isEmpty() == false) {
    			system.debug('Updating accounts...');
    			update listOfAccountsToUpdate;
    		}
    		
        }
        
        
    

    public void finish(database.batchableContext bc){ 
    	
    }
}