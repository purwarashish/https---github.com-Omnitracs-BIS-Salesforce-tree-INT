global class CalculateSumOfOpenActivities {
// Changed the following method to future method.So accordingly modified the input parameters to a list of ID
// as future method cannot take SObject as input argument.
        public static boolean firstRun = true;
        
        @future
        public static void calSumOfOpenActv(List<ID> recordIDs){
        
        List<Account> lstOfAccount = [SELECT Name,id FROM Account WHERE Id IN :recordIDs];
        
        List<String> lstAccountIds = new List<String>();
        List<Account> lstOfAccountToUpdate = new List<Account>();
        
        for(Account acct: lstOfAccount){
                lstAccountIds.add(acct.id);
        }
        
        if(!lstAccountIds.isEmpty()){
            
            //Queries open tasks for the accounts in context. Order statement is added in query to improve query performance. 
            Map<String,Account> mapOfAccountWithOpenActivities = new Map<String,Account>([Select id,
                                                                   Sum_of_Open_Activities__c,
                                                                    (Select Id From OpenActivities ORDER BY ActivityDate ASC NULLS LAST, LastModifiedDate DESC limit 500)
                                                            from 
                                                                Account 
                                                            where 
                                                                id IN :lstAccountIds 
                                                            limit 10000]);
            Map<String,Integer> mapOfAcctAndOpenActvity = new  Map<String,Integer>();
            if(mapOfAccountWithOpenActivities != null && !mapOfAccountWithOpenActivities.isEmpty()){
                system.debug('@@@@@mapOfAccountWithOpenActivities.size'+mapOfAccountWithOpenActivities);
                for(String acct:mapOfAccountWithOpenActivities.keySet()){
                    if(mapOfAccountWithOpenActivities.get(acct).OpenActivities !=null && mapOfAccountWithOpenActivities.get(acct).OpenActivities.size() > 0)
                    {
                        mapOfAccountWithOpenActivities.get(acct).Sum_of_Open_Activities__c = mapOfAccountWithOpenActivities.get(acct).OpenActivities.size();
                        Account acctToUpdt = new Account(id=mapOfAccountWithOpenActivities.get(acct).id, Sum_of_Open_Activities__c = mapOfAccountWithOpenActivities.get(acct).OpenActivities.size());
                        lstOfAccountToUpdate.add(acctToUpdt);
                    }
                    else{
                        system.debug('In else activity is zero');
                        Integer count = 0;
                        mapOfAccountWithOpenActivities.get(acct).Sum_of_Open_Activities__c = count;
                        lstOfAccountToUpdate.add(mapOfAccountWithOpenActivities.get(acct));    
                    }    
                
                }
               
            }
        }
        if(!lstOfAccountToUpdate.isEmpty()){
            try{
                    system.debug('@@@@@@lstOfAccountToUpdate'+lstOfAccountToUpdate);
                    update lstOfAccountToUpdate;
                    
                    
            }
            catch(Exception e){
                system.debug('@@@@Account cannot be updated'+e.getMessage());
            }
                
                
        }
    }
}