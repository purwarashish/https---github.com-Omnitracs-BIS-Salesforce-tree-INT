/***********************************************************************************
Author: Vignesh Nayak S, Salesforce.com Developer
Tata Consultancy Services Limited
Description : Removed all the logic from exsisting account trigger and created a new one following the Salesforce Best Practices.
************************************************************************************/
Trigger AllAccountTrigger on Account (before insert, before update, before delete, after insert, after update, after undelete) 
{
    BypassTriggerUtility u = new BypassTriggerUtility();  
    if (u.isTriggerBypassed()) {   return;   }
    if(Trigger.isUpdate) 
    {
        AllAccountUtils.checkRollUpUpdate(Trigger.new,Trigger.oldMap);
    }
    
    if(trigger.isBefore)
    {
        if(trigger.isUpdate||trigger.isInsert)
        {            
           AllAccountUtils.assignRankingCargoType(Trigger.new, Trigger.oldMap);//  Ranking - Cargo Type requires logic that cannot be placed in field update  
           AllAccountUtils.calDataQualScr(trigger.new);
           AllAccountUtils.updateSicFields(trigger.new,trigger.oldMap); 
           AllAccountUtils.manageManualAssignmentForAccountTeamCreation(Trigger.old, Trigger.new);//  added by joseph hutchins 10/30/2014
           if(trigger.isUpdate)
           {
                AllAccountUtils.findAccountsToPopulateDataShare(Trigger.new, Trigger.old);               
                AllAccountUtils.changeRecordType(trigger.new);
                AllAccountUtils.RecordOwnerChange(AllAccountUtils.getAccountOwnerId(trigger.newMap,trigger.oldMap), trigger.new, trigger.old);
                AllAccountUtils.preventRecTypeChange(trigger.new, trigger.oldMap);
                AllAccountUtils.setReseller(trigger.new);
               
           }
           AllAccountUtils.ValidateAndUpdateStateCode(Trigger.New, Trigger.isBefore, Trigger.isAfter, Trigger.isInsert,Trigger.oldMap); 
           AllAccountUtils.UpdatePartnerSupport(Trigger.new, Trigger.old, trigger.isUpdate);
           RollupParentUtils.updateRollupParentForUpsert(Trigger.new, Trigger.oldMap, Trigger.isInsert, Trigger.isUpdate);
        } // End - if (trigger.isUpdate/isInsert)  
        if(Trigger.isDelete){
            RollupParentUtils.updateRollupParentForDelete(Trigger.old);
        }      
    }
     
    if(trigger.isAfter)
    {
        if(trigger.isInsert || trigger.isUpdate)
        {  
            if(!System.isBatch())
            {
                AllAccountUtils.acctUpdateAcctTerritories(trigger.old,trigger.new, trigger.isUpdate);
            }
            
            AllAccountUtils.partnerAgentUpdate(Trigger.newMap.keyset(),AllAccountUtils.isExecuted);
            if(trigger.isInsert && !System.isFuture())
            {
                AllAccountUtils.UpdateAccountForPRMUser(Trigger.newMap.keyset());                  
            } 
            
            if(!System.isBatch())
            {
             	AllAccountUtils.DataPrepPlusupdatePartnerSupportDetails(trigger.new, trigger.old, trigger.isInsert);   
            }
            
        }
        if(trigger.isUpdate)
        {
            if(!System.isBatch())
            {
                AllAccountUtils.ChangeContactStatus(trigger.newMap, trigger.oldMap, trigger.isInsert);
            }
            AllAccountUtils.sendCustomerSuccessEmails(Trigger.new, trigger.oldMap);
            if(checkRecursive.runOnce()){
             ScoringDataUtils.populateCustomerHealthFields(Trigger.new, trigger.oldMap);
            }
        }
        if(Trigger.isUndelete){
            RollupParentUtils.updateRollupParentForUndelete(Trigger.new);
        }
        if(Trigger.size == 1 && !System.isFuture() && !System.isBatch())
        {
            AllAccountUtils.NetsuiteSyncUpActivity(Trigger.New);
        }
        if(trigger.isUpdate && !System.isFuture())
        {
            AllAccountUtils.checkAndUpdateQuoteLegalName(Trigger.new, Trigger.oldmap);
            AllAccountUtils.CalculateSumOfOpenActivities(Trigger.new);
        }       
    }
}