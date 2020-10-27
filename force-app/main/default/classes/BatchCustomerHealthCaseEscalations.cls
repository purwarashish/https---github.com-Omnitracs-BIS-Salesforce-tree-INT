public with sharing class BatchCustomerHealthCaseEscalations implements database.batchable<sobject>{
    public string query;
    public date todays;
    
    public BatchCustomerHealthCaseEscalations(){
    	//todays = Date.Today();
    	query = 'SELECT ID, Customer_Health_Of_Case_escalations__c, No_Of_Active_Scoring_Subscription__c FROM Account where No_Of_Active_Scoring_Subscription__c > 0'; 
    }    
        
    public database.querylocator start(database.batchableContext bc){
    	//String query = 'SELECT ID, No_Of_Active_Scoring_Subscriptions__c, Total_On_Air_Units__c FROM account WHERE No_Of_Active_Scoring_Subscriptions__c > 0 AND Total_On_Air_Units__c != null';
        return database.getquerylocator(query);
    }
    
    public void execute(Database.BatchableContext BC, list<sObject> scope){ 
    		List<Account> listOfAccountsToUpdate = new List<Account>();
    		Set<ID> usedAccountSet = new Set<ID>();
    		List<Case> usedCases = new List<Case>();
    		
    		Map<ID, ID> casesToAccounts = new Map<ID, ID>();
    		util.debug('Accounts should have been queried.  Number passed into this method: ' + scope == null ? 0 : scope.size());		
    		
    		for(Sobject s : scope){
    			Account a = (Account)s;
    			System.debug('Current account: ' + a.ID);
    		    if(!usedAccountSet.contains(a.ID)) usedAccountSet.add(a.ID);
    			
    		}
    		
    		List<Account> usedAccounts = [Select ID, Customer_Health_Of_Case_Escalations__c from Account where ID IN: usedAccountSet];
    		usedCases = [Select ID, IsEscalated, AccountID From Case where IsEscalated = true and AccountID IN: usedAccountSet];
    		system.debug('entering used accounts list');
    		
    		system.debug('entering used account set');
    		for(Account a : usedAccounts){
    			system.debug('in used account set');
    				a.Customer_Health_of_case_escalations__c = 0;
    			for(Case c : usedCases){
    				system.debug('in used cases');
    				if(c.AccountID == a.ID){
    						a.Customer_Health_of_Case_Escalations__c = a.Customer_Health_of_Case_escalations__c + 1;
    						system.debug('cases incremented ' + a.Customer_Health_of_case_escalations__c);
    				}
    			}
    			
    			System.debug('Account added to update: ' + a.ID + ' with value of Case Escalations ' + a.Customer_Health_of_Case_Escalations__c);
    			listOfAccountsToUpdate.add(a);
    		}
    		system.debug('post used accounts');	
    		System.debug('Case Scope Exists: ' + scope.isEmpty());
    		if(listOfAccountsToUpdate.isEmpty() == false){ 
    			system.debug('updating accounts');
    			update listOfAccountsToUpdate;
    		}
    		
        }
        
        
    

    public void finish(database.batchableContext bc){ 
    	
    }
}