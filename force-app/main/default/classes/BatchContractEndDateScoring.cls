public class BatchContractEndDateScoring implements database.batchable<sobject>{
    public string query;
    public date todays;
    
    public BatchContractEndDateScoring(){
        //todays = Date.Today();
        query = 'Select ID, Term_Type__c, Status, EndDate, Record_Type__c, Contract_Status__c, Agreement_Type__c, AccountId From Contract Where Term_Type__c = \'Fixed\' AND Record_type__c = \'Customer Agreement\' AND Status = \'Active\' AND Agreement_Type__c = \'Master\' AND EndDate = NEXT_N_YEARS:10'; 
    }    
        
    public database.querylocator start(database.batchableContext bc){
        //String query = 'Select Term_Type__c, Account, Status, EndDate, Record_Type__c, Contract_Status__c, Agreement_Type__c, AccountId From Contract Where Term_Type__c = \'Fixed\' AND Record_type__c = \'Customer Agreement\' AND Status = \'Active\' AND Agreement_Type__c = \'Master\'';
        return database.getquerylocator(query);
    }
    
    public void execute(Database.BatchableContext BC, list<sObject> scope){ 
            List<Contract> contracts = new List<Contract>();
            List<Account> listOfAccountsToUpdate = new List<Account>();
            Set<ID> usedAccountIDs = new Set<ID>();
            Map<Contract, ID> contractsToAccounts = new Map<Contract, ID>();
            
            util.debug('Contracts should have been queried.  Number passed into this method: ' + scope == null ? 0 : scope.size());
            //Date todaysDate;
            Integer numofDaysBetween;
            Decimal comparisonValue;
            Date todaysDate;
            //Contract c;
            
            //Map<Contract, ID> mapOfContractstoAccts;
            for(Sobject s : scope){
                Contract c = (contract)s;
                contractsToAccounts.put(c, c.AccountID);
                if(usedAccountIDs.contains(c.accountID) == false){
                    usedAccountIDs.add(c.AccountID);
                }
            }
                
                //if(!usedAccountIDs.contains(c.accountID)){
                //  usedAccountIDs.add(c.accountID);
                //}
            //}
            
            List<Account> usedAccounts = [Select ID, Customer_Health_ofDaystoContractTerm__c from Account where ID IN: contractsToAccounts.values() and No_Of_Active_Scoring_Subscription__c > 0];
            System.debug('Contract Scope Exists: ' + scope.isEmpty());
            
            for(Sobject s : scope){
                Contract c = (contract)s;
                todaysDate = Date.today();
                
                for(Account a : usedAccounts){
                if(c.EndDate != null && c.AccountID == a.ID){
                    if(c.EndDate < Date.Today()){
                        
                    }
                    else{
                    numofDaysBetween = todaysDate.daysBetween(c.EndDate);
                    system.debug('Contract end date: ' + c.endDate);
                    system.debug('Num of Days Between: ' + numofDaysBetween);
                    //numOfDaysBetween = numOfDaysBetween;
                    System.debug('Number of Days Between: ' + (Date)todaysDate + ' - ' + numOfDaysBetween);
                    System.debug('Current account: ' + a.ID);
                if(a.Customer_Health_ofDaystoContractTerm__c == 0.0 || a.Customer_Health_ofDaysToContractTerm__c == null){
                    System.debug('In #ofdays = 0 or null');
                    usedAccountIDs.add(c.accountID);
                    a.Customer_Health_ofDaystoContractTerm__c = numOfDaysBetween;
                    a.Customer_Health_ofDaysToContractTerm__c = math.abs(a.Customer_Health_ofDaysToContractTerm__c);
                    System.debug('Account value : ' + numOfDaysBetween + ' ' + a.Customer_Health_ofDaystoContractTerm__c);
                    //a.TEST_CH_Nearest_Renewal_Contract_ID__c = c.ID;
                }
                else{
                    System.debug('Days detected: Checking and updating.');
                    //a.TEST_CH_Nearest_Renewal_Contract_ID__c = c.ID;
                    comparisonValue = a.Customer_Health_ofDaystoContractTerm__c;
                    if(comparisonValue < numofDaysBetween){
                        usedAccountIDs.add(c.accountID);
                        //a.TEST_CH_Nearest_Renewal_Contract_ID__c = c.ID;
                        a.Customer_Health_ofDaystoContractTerm__c = numOfDaysBetween;
                        a.Customer_Health_ofDaysToContractTerm__c = math.abs(a.Customer_Health_ofDaysToContractTerm__c);
                        System.debug('Account value: ' + numOfDaysBetween + ' ' + a.Customer_Health_ofDaystoContractTerm__c);
                        }
                    
                    }
                }
                //TODO: Add Logic to determine if this one is a smaller number. If smaller, replace.
                System.debug('Account values: ' + 'Value being passed: ' + numOfDaysBetween + ' ' + 'Value in field: ' + a.Customer_Health_ofDaystoContractTerm__c);
                listOfAccountsToUpdate.add(a);
                }
            }
            if(!listOfAccountsToUpdate.isEmpty()) update listOfAccountsToUpdate;
                //mapOfContractstoAccts.put(c, c.AccountID);
        }
           
    }

    public void finish(database.batchableContext bc){ 
        
    }
}