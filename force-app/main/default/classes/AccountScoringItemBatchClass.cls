global class AccountScoringItemBatchClass implements Database.Batchable<sObject>{

        global AccountScoringItemBatchClass(){
                   // Batch Constructor
        }
       
        // Start Method
        global Database.QueryLocator start(Database.BatchableContext BC){
            
            string query = 'select id  from Account_Scoring_Item__c limit 500000';
            return Database.getQueryLocator(query);
        }
      
      // Execute Logic
       global void execute(Database.BatchableContext BC, List<Account_Scoring_Item__c>scope){
             
        delete scope;
     
       }
     
       global void finish(Database.BatchableContext BC){
            // Logic to be Executed at finish
       }
    }