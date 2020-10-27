/*********************************************************************************
* Name: BatchAccountScoringCalculation
* Created by Omnitracs {DateCreated 7/1/2016} 
----------------------------------------------------------------------------------
* Purpose/Methods:/ 
* This is used as batch class for Account scoring calculations
----------------------------------------------------------------------------------
* Unit Test: TestBatchAccountScoringCalculation
---------------------------------------------------------------------------------- 
* History:
* VERSION DEVELOPER NAME DATE DETAIL FEATURES
1.0 7/1/2016 INITIAL DEVELOPMENT
 
*********************************************************************************/
 
 public class BatchAccountScoringCalculation implements database.batchable<sobject>{
        
        
    public database.querylocator start(database.batchableContext bc){
        return database.getquerylocator([Select Id From Account Where No_of_Active_Scoring_Subscription__c > 0]);
    }
    
    public void execute(database.batchablecontext bd, list<sobject> sc){ 
        
        for(Account a:(List<Account>)sc){
            
            Set<Id> scoringModel = new Set<Id>();
            Set<String> accFields = new Set<String>();
            String accountId = a.Id;
            
            string PreviousDisplayType = null;
            
            SET<ID> manualScoringModel = new SET<ID>();
            
            for(Account_Scoring__c accc: [Select Id,Display_Type__c,Scoring_Model_ID__c,Is_Manual_Scoring__c,History__c From Account_Scoring__c 
                                            Where Account__c=: a.Id AND Is_Manual_Scoring__c = true AND History__c = false]){
                    manualScoringModel.add(accc.Scoring_Model_ID__c);
            }
            
            for(Account_Scoring__c accc: [Select Id,Display_Type__c,Scoring_Model_ID__c,Is_Manual_Scoring__c,History__c From Account_Scoring__c Where Account__c=: a.Id Order By Date__c DESC limit 1]){
                PreviousDisplayType = accc.Display_Type__c;
                 
            }
            
            Map<Id,Account_Scoring__c> scoringAccountScoringMap = new Map<Id, Account_Scoring__c>();
            List<Account_Scoring_Item__c> accScoringItemToBeInserted = new List<Account_Scoring_Item__c>();
            
            for(Scoring_Subscription__c ss : [Select Id,Scoring_Model__c, Account__c from Scoring_Subscription__c 
                                                where Subscription_Status__c = 'Active' AND Account__c =: a.Id AND Scoring_Model__c NOT IN: manualScoringModel]){
                scoringModel.add(ss.Scoring_Model__c);
            }
            
            System.debug('scoringModel::'+scoringModel);
            Map<Id, Scoring_Model__c> scoringModelMap = new Map<Id, Scoring_Model__c>([Select Id, Name,Green_Overall_Score_From__c, Red_Overall_Score_From__c, Green_Overall_Score_To__c,
                                                                                        Yellow_Overall_Score_To__c, Red_Overall_Score_To__c, Yellow_Overall_Score_From__c,
                                                                                        (Select Id,Name, Default_Score_Value__c, Scoring_Field_API_Name__c, Scoring_Model__c, Scoring_Weight__c,  
                                                                                            Green_Score_From__c,Yellow_Score_From__c,Red_Score_From__c,Green_Score_To__c,Red_Score_To__c,Yellow_Score_To__c
                                                                                        From Scoring_Items__r)
                                                                                        From Scoring_Model__c Where Id IN :scoringModel]);
            // stop if no scoring model found
            if(scoringModelMap.size() == 0){
                continue;
            } 
            
            for(Scoring_Model__c sm : scoringModelMap.values()){
                for(Scoring_Item__c si:sm.Scoring_Items__r){
                    accFields.add(si.Scoring_Field_API_Name__c);
                }
            }
            
            String accQuery = 'Select '+String.join(new List<String>(accFields),', ')+' From Account Where Id = :accountId Limit 1';
            System.debug('accQuery:::'+accQuery);
            List<Account> accountInfo = Database.query(accQuery);
            
            Account_Scoring__c acs;
            for(Scoring_Model__c sm:scoringModelMap.values()){
                acs = new Account_Scoring__c(Account__c = a.Id,History__c = false, Date__c = System.today(), Scoring_Model_ID__c = sm.Id, Scoring_Model__c = sm.Name, Previous_Display_Type__c = PreviousDisplayType);
                scoringAccountScoringMap.put(sm.Id,acs);
            }
            
            if(scoringAccountScoringMap != null && scoringAccountScoringMap.keySet().size() > 0) {
                insert scoringAccountScoringMap.values();
            }
            
            // process account scoring
            for(Account acc: accountInfo){
                Account_Scoring_Item__c accScoringItem;
                
                for(Scoring_Model__c sm:scoringModelMap.values()){
                    
                    for(Scoring_Item__c si:sm.Scoring_Items__r){
                        
                        accScoringItem = new Account_Scoring_Item__c();
                        accScoringItem.Account_Scoring__c = scoringAccountScoringMap.get(sm.Id).Id;
                        accScoringItem.Scoring_Item_ID__c = si.Id;
                        accScoringItem.Scoring_Item__c = si.Name;
                        accScoringItem.Value__c = 0;
                        
                        accScoringItem.Score__c = 0;
                        
                        double maxValueOverall = 0;
                        if(maxValueOverall < sm.Green_Overall_Score_To__c){
                            maxValueOverall = sm.Green_Overall_Score_To__c;
                        }
                        if(maxValueOverall < sm.Yellow_Overall_Score_To__c){
                            maxValueOverall = sm.Yellow_Overall_Score_To__c;
                        }
                        if(maxValueOverall < sm.Red_Overall_Score_To__c){
                            maxValueOverall = sm.Red_Overall_Score_To__c;
                        }
                        
                        double maxValueMetric = 0;
                        if(maxValueMetric < si.Green_Score_To__c){
                            maxValueMetric = si.Green_Score_To__c;
                        }
                        if(maxValueMetric < si.Yellow_Score_To__c){
                            maxValueMetric = si.Yellow_Score_To__c;
                        }
                        if(maxValueMetric < si.Red_Score_To__c){
                            maxValueMetric = si.Red_Score_To__c;
                        }
                        
                        double NormalizeValue = 0;
                        if(maxValueOverall != 0 && maxValueMetric != 0){
                            NormalizeValue = maxValueOverall / maxValueMetric;
                        }
                        
                        double normalizeGreenFrom = 0;
                        double normalizeGreenTo = 0;
                        double normalizeYellowFrom = 0;
                        double normalizeYellowTo = 0;
                        double normalizeRedFrom = 0;
                        double normalizeRedTo = 0;
                        
                        if(si.Green_Score_From__c != null ){
                            normalizeGreenFrom = si.Green_Score_From__c * NormalizeValue;
                        }
                        if(si.Green_Score_To__c != null ){
                            normalizeGreenTo = si.Green_Score_To__c * NormalizeValue;
                        }
                        if(si.Yellow_Score_From__c != null ){
                            normalizeYellowFrom = si.Yellow_Score_From__c * NormalizeValue;
                        }
                        if(si.Yellow_Score_To__c != null ){
                            normalizeYellowTo = si.Yellow_Score_To__c * NormalizeValue;
                        }
                        if(si.Red_Score_From__c != null ){
                            normalizeRedFrom = si.Red_Score_From__c * NormalizeValue;
                        }
                        if(si.Red_Score_To__c != null ){
                            normalizeRedTo = si.Red_Score_To__c * NormalizeValue;
                        }
                        
                        
                        if(acc.get(si.Scoring_Field_API_Name__c) != null){ 
                        	system.debug('Pre Normalized value: ' + Double.valueOf(acc.get(si.Scoring_Field_API_Name__c)));
                        	accScoringItem.Value__c = Double.valueOf(acc.get(si.Scoring_Field_API_Name__c));
                        	system.debug('Pre Normalized value passed: ' + accScoringItem.value__c);
                       		system.debug('Normalize value used: ' + NormalizeValue);
                            accScoringItem.Score__c = Double.valueOf(acc.get(si.Scoring_Field_API_Name__c)) * NormalizeValue ; 
                            system.debug('Post Normalization value: ' + accScoringItem.score__c);
                        }
                        else if(si.Default_Score_Value__c != null ){
                        	accScoringItem.Value__c = Double.valueOf(acc.get(si.Scoring_Field_API_Name__c));
                            accScoringItem.Score__c = si.Default_Score_Value__c * NormalizeValue;
                        }
                        
                         
                        if(accScoringItem.Score__c >= normalizeRedFrom && accScoringItem.Score__c <= normalizeRedTo){
                            accScoringItem.Display_Type__c = 'Red';
                        }
                        else if(accScoringItem.Score__c >= normalizeYellowFrom && accScoringItem.Score__c <= normalizeYellowTo){
                            accScoringItem.Display_Type__c = 'Yellow';
                        }
                        else if(accScoringItem.Score__c >= normalizeGreenFrom && accScoringItem.Score__c <= normalizeGreenTo){
                            accScoringItem.Display_Type__c = 'Green';
                        }
                        
                        accScoringItem.Normalized_Score__c = accScoringItem.Score__c ;
                        if(si.Scoring_Weight__c != null && si.Scoring_Weight__c != 0 ){
                        	
                            accScoringItem.Score__c = accScoringItem.Score__c * si.Scoring_Weight__c;
                        }
                         
                        accScoringItemToBeInserted.add(accScoringItem);
                    }
                }
            }
            
            if(accScoringItemToBeInserted != null && accScoringItemToBeInserted.size() > 0) {
                // create account scoring items
                insert accScoringItemToBeInserted;
            }
            
            List<Account_Scoring__c> listAS = new List<Account_Scoring__c>();
            SET<ID> setScoringModel = new SET<ID>();
            
            for(Account_Scoring__c s: [Select Id,Scoring_Model_ID__r.Green_Overall_Score_From__c,Scoring_Model_ID__r.Red_Overall_Score_From__c,Scoring_Model_ID__r.Green_Overall_Score_To__c,
                                        Scoring_Model_ID__r.Yellow_Overall_Score_To__c,Scoring_Model_ID__r.Red_Overall_Score_To__c,Scoring_Model_ID__r.Yellow_Overall_Score_From__c,
                                        Scoring_Model_ID__c,Display_Type__c,Aggregate_Score__c From Account_Scoring__c Where Id IN: scoringAccountScoringMap.values()]){
                
                if(s.Aggregate_Score__c >= s.Scoring_Model_ID__r.Red_Overall_Score_From__c && s.Aggregate_Score__c <= s.Scoring_Model_ID__r.Red_Overall_Score_To__c){
                    s.Display_Type__c = 'Red';
                }
                else if(s.Aggregate_Score__c >= s.Scoring_Model_ID__r.Yellow_Overall_Score_From__c && s.Aggregate_Score__c <= s.Scoring_Model_ID__r.Yellow_Overall_Score_To__c){
                    s.Display_Type__c = 'Yellow';
                }
                else if(s.Aggregate_Score__c >= s.Scoring_Model_ID__r.Green_Overall_Score_From__c && s.Aggregate_Score__c <= s.Scoring_Model_ID__r.Green_Overall_Score_To__c){
                    s.Display_Type__c = 'Green';
                }
                
                setScoringModel.add(s.Scoring_Model_ID__c);
                listAS.add(s);
            }
            
            // update Account Scoring
            update listAS;
            
            
            List<Account_Scoring__c> listASHistory = new List<Account_Scoring__c>();
            
            for(Account_Scoring__c s: [Select Id,History__c From Account_Scoring__c Where Account__c =: a.Id AND Scoring_Model_ID__c IN: setScoringModel AND ID NOT IN:listAS  AND History__c = false]){
                 
                s.History__c = true;
                listASHistory.add(s);
            }
            
            // update Account Scoring history
            update listASHistory;
            
        }
    }

    public void finish(database.batchableContext bc){ 
        
    }
}