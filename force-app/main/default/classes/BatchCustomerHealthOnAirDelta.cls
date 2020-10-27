public with sharing class BatchCustomerHealthOnAirDelta implements database.batchable<sobject>{
    public string query;
    public date todays;
    
    public BatchCustomerHealthOnAirDelta(){
    	//todays = Date.Today();
    	query = 'SELECT ID, No_Of_Active_Scoring_Subscription__c, Total_On_Air_Units__c, Customer_Health_Total_On_Air_Units__c FROM account WHERE No_Of_Active_Scoring_Subscription__c > 0 AND Total_On_Air_Units__c != null'; 
    }    
        
    public database.querylocator start(database.batchableContext bc){
    	//String query = 'SELECT ID, No_Of_Active_Scoring_Subscriptions__c, Total_On_Air_Units__c FROM account WHERE No_Of_Active_Scoring_Subscriptions__c > 0 AND Total_On_Air_Units__c != null';
        return database.getquerylocator(query);
    }
    
    public void execute(Database.BatchableContext BC, list<sObject> scope){ 
    		List<Asset__c> assets = new List<Asset__c>();
    		List<Account> listOfAccountsToUpdate = new List<Account>();
    		Set<ID> usedAccountIDs = new Set<ID>();
    		Map<Asset__c, ID> assetsToAccounts = new Map<Asset__c, ID>();
    		util.debug('Accounts should have been queried.  Number passed into this method: ' + scope == null ? 0 : scope.size());
    		//Date todaysDate;
    		Integer numofDaysBetween;
    		Decimal comparisonValue;
    		Date todaysDate;
    		//Contract c;

    			
    			//if(!usedAccountIDs.contains(c.accountID)){
    			//	usedAccountIDs.add(c.accountID);
    			//}
    		//}
    		
    		List<Account> usedAccounts = [Select ID, Customer_Health_Legacy_EOL_Platform__c from Account where ID IN: assetsToAccounts.values()];
    		System.debug('Contract Scope Exists: ' + scope.isEmpty());
    		
    		for(Sobject s : scope){
    			Account a = (Account)s;
    			System.debug('Current account: ' + a.ID);
    			System.debug('Current Total On Air Units: ' + a.Total_On_Air_Units__c);
    			//Return all assets on an account if it No of Subscriptions > 0
    			if(a.Total_On_Air_Units__c != null){
    				
    				if(a.customer_health_total_on_air_units__c == null){
    					a.Customer_Health_Total_On_Air_Units_Last__c = 0;
    					a.Customer_Health_Total_On_Air_Units__c = a.Total_On_Air_Units__c;
    					listOfAccountsToUpdate.add(a);
    				}
    				
	    			else{
	    				a.Customer_Health_Total_On_Air_Units_Last__c = a.Customer_Health_Total_On_Air_Units__c;
	    				a.Customer_Health_Total_On_Air_Units__c = a.Total_On_Air_Units__c;
	    				listofAccountsToUpdate.add(a);
	    			}
    			}

    			
    			
    		}
    		
    		update listOfAccountsToUpdate;
    		
        }
        
        
    

    public void finish(database.batchableContext bc){ 
    	
    }
}