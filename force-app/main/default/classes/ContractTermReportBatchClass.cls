global class ContractTermReportBatchClass implements Database.Batchable<sObject>{

        global ContractTermReportBatchClass(){
                   // Batch Constructor
        }
       
        // Start Method
        global Database.QueryLocator start(Database.BatchableContext BC){
            
            string query = 'select id  from Contract_Term_Report__c limit 500000';
            return Database.getQueryLocator(query);
        }
      
      // Execute Logic
       global void execute(Database.BatchableContext BC, List<Contract_Term_Report__c>scope){
             
        delete scope;
     
       }
     
       global void finish(Database.BatchableContext BC){
            // Logic to be Executed at finish
       }
    }