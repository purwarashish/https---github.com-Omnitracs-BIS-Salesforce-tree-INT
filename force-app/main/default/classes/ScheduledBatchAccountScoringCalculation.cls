/*********************************************************************************
* Name: ScheduledBatchAccountScoringCalculation
* Created by Omnitracs {DateCreated 7/1/2016} 
----------------------------------------------------------------------------------
* Purpose/Methods:/ 
* This is used as scheduler class for batch apex BatchAccountScoringCalculation
----------------------------------------------------------------------------------
* Unit Test: TestScheduledBatchAccountScoringCalculation
---------------------------------------------------------------------------------- 
* History:
* VERSION DEVELOPER NAME DATE DETAIL FEATURES
1.0 7/1/2016 INITIAL DEVELOPMENT
 
*********************************************************************************/

public with sharing class ScheduledBatchAccountScoringCalculation implements Schedulable {
    
    public void execute(SchedulableContext sc) {
    	
    	// Batch jobs to process account scoring for each subscribed account
        ID BatchId = Database.executeBatch(new BatchAccountScoringCalculation(), 1);
    } 
    
    /*
    public static void SchedulerMethod() {
        string con_exp= '0 0 1 * * ?';
        System.schedule('ScheduledBatchAccountScoringCalculation', con_exp, new ScheduledBatchAccountScoringCalculation());
    }
    */
}