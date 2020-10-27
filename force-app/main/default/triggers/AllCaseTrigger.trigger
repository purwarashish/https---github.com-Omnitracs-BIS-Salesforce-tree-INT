trigger AllCaseTrigger on Case (before insert,before update,after insert,after update, before delete, after delete) {

    BypassTriggerUtility u = new BypassTriggerUtility();  
    if (u.isTriggerBypassed()){
         return;
    }
     
    if(Trigger.isBefore)
    {
        if(Trigger.isInsert)
        {
            if(CheckRecursive.runOnce())
            {
                AllCaseTriggerUtils.setLastModifiedDateTimeField(Trigger.new);
                AllCaseTriggerUtils.prepopulateContactAndAccountIfEmail2Case(Trigger.new);                
                AllCaseTriggerUtils.guessWorkEffort(Trigger.new);             
                AllCaseTriggerUtils.removeHTMLMarkupFromSprint(Trigger.new);
            }
             AllCaseTriggerUtils.populateAccountTeam(Trigger.new);
             AllCaseTriggerUtils.populateQueueiQCases(Trigger.new);
             AllCaseTriggerUtils.CaseValidationForNMCRequests(Trigger.new);
            //ScoringDataUtils.isEscalatedCountOnInsertUpdateAdd(Trigger.new, Trigger.oldMap);
        }

        if(Trigger.isUpdate)
        {
            if(CheckRecursive.runOnce() || Test.isRunningTest())
            {                 
                AllCaseTriggerUtils.setLastModifiedDateTimeField(Trigger.new);
                AllCaseTriggerUtils.escalationCaseResponse(Trigger.oldMap, Trigger.new);
                AllCaseTriggerUtils.populateJiraStatusFields(Trigger.new);                 
                AllCaseTriggerUtils.validateWorkEffort(Trigger.new, Trigger.oldMap);    
                AllCaseTriggerUtils.removeHTMLMarkupFromSprint(Trigger.new);
            }
            AllCaseTriggerUtils.populateAccountTeam(Trigger.new);
            AllCaseTriggerUtils.populateOwneriQCases(Trigger.new);
            AllCaseTriggerUtils.CaseValidationForNMCRequests(Trigger.new);
            AllCaseTriggerUtils.AssignCaseToClosedCases(Trigger.oldMap, Trigger.new);
        
        }
        
        //if(Trigger.isDelete){
            //ScoringDataUtils.isEscalatedCountOnDelete(trigger.new);
        //}
    }
     
    if(Trigger.isAfter)
    {      
        if(Trigger.isInsert)
        {
            if(CreateTIS.getInsertCounter() ==0)
                AllCaseTriggerUtils.populateStatusAndQueueForTISAfterInsert(Trigger.new);
                
            //  be advised that while testing the EmailAlertSupportCreation method in this trigger, i realized this method was NOT getting called because of this is 
            //  callig checkRecusrive..  i am turning it off right now, but will probably have to merge th logic in this trigger in the caseTrigger if removeing the checkRecusive here causes problems       
            //if (CheckRecursiveAfter.runOnce())
            {
                AllCaseTriggerUtils.ShareCaseVarRoadnet(Trigger.new);
                AllCaseTriggerUtils.supportCaseEmailAlerts(Trigger.new, null);
                AllCaseTriggerUtils.ChatterCaseToAccountFeed(Trigger.new, Trigger.oldmap);
                
            }
        }
        
        if(Trigger.isUpdate)
        {
            if(CreateTIS.getInsertCounter() ==1 || CreateTIS.getUpdateCounter() < 2)
                AllCaseTriggerUtils.populateStatusAndQueueForTISAfterUpdate(Trigger.old,Trigger.new);
            if(CheckRecursiveAfter.runOnce() || Test.isRunningTest())          
            {
                AllCaseTriggerUtils.autoJIRACallout(Trigger.newMap);
                //******AllCaseTriggerUtils.createCaseTimesAfterTrigger(Trigger.new);//commented by Arindam Laik, we are achieving the same functionality in 'Case: Insert Case Time on Case updation' Process Builder 
                AllCaseTriggerUtils.ShareCaseVarRoadnet(Trigger.new);
                AllCaseTriggerUtils.supportCaseEmailAlerts(Trigger.new, Trigger.oldmap);
                AllCaseTriggerUtils.sendUpgradeCaseClosureEmail(Trigger.new, Trigger.oldmap);
                //AllCaseTriggerUtils.closeChildCases(Trigger.new, Trigger.oldmap);
            }
            AllCaseTriggerUtils.ChatterCaseToAccountFeed(Trigger.new, Trigger.oldmap);
           // ScoringDataUtils.isEscalatedCountOnInsertUpdateAdd(Trigger.new, Trigger.oldMap);
            CSATSurveyUtils.updateAvgCSATScore(Trigger.new, Trigger.oldMap);
        }
    } 
}