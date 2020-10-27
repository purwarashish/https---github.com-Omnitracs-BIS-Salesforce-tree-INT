global class ContractAutoRenewBatch implements Database.Batchable<sObject>{
    String query;
     
    global Database.querylocator start(Database.BatchableContext BC){
        Date today = date.today();
        System.debug('***SCOPE '); 
        //Status = Approved change to Active
        query = 'SELECT Id,Contract_Title__c,Name,Status,EndDate,Term_Type__c,Original_Expiration_Date__c,Renewal_Term_Length_in_months__c FROM Contract WHERE Status = \'Active\' AND EndDate = today AND Term_Type__c = \'Auto-Renewal\'';   
        return Database.getQueryLocator(Query);
    }
 
    global void execute(Database.BatchableContext BC, List<Contract> scope){
        List<Contract> contractList = new List<Contract>();
        System.debug('***SCOPE '+scope); 
        Set<Id> sContractIds = new Set<Id>();
        Map<Id,Contract> contractMap = new Map<Id,Contract>();
        Id taskRT = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Task').getRecordTypeId();
        if(scope!=null&&!scope.isEmpty()){
            for(Contract con : scope){
                sContractIds.add(con.Id);
            }
            for(Contract cont : scope){
                Contract contrct = new Contract();
                contrct.Id=cont.Id;
                contrct.Original_Expiration_Date__c = cont.Original_Expiration_Date__c;
                contrct.Renewal_Term_Length_in_months__c = cont.Renewal_Term_Length_in_months__c;
                
                if(contrct.Original_Expiration_Date__c==null){
                    contrct.Original_Expiration_Date__c=cont.EndDate;
                }
                if(contrct.Renewal_Term_Length_in_months__c==null){
                    contrct.Renewal_Term_Length_in_months__c=12;
                }
                Integer integerValue = Integer.valueOf(contrct.Renewal_Term_Length_in_months__c);
                contrct.EndDate=cont.EndDate.addMonths(integerValue);
                contractList.add(contrct); 
                contractMap.put(contrct.Id,contrct);
            }
        }
        if(contractList!=null&&!contractList.isEmpty()){
            system.debug('***contractList'+contractList);
            try{
                update contractList;
            }
            catch(DMLException e){
                System.debug('There was a problem update contracts - ' + e.getMessage());
            }
            // Contract con = [SELECT Name, Status,Contract_Title__c FROM Contract WHERE Id=:contractList[0].Id];
            // system.debug('***con'+con.Contract_Title__c);
            // system.debug('***con2'+con.Status);
        }
        List<Task>  taskTempList = new List<Task>();
        List<Task>  taskTempList2 = new List<Task>();
        List<Task>  taskListcontainer = new List<Task>();
        //List<Task>  taskList = [SELECT Id,ReminderDateTime, OwnerId, WhatId, RecordTypeId, ActivityDate, Subject, Priority, Status, WhoId,  Description, CallDurationInSeconds, Marketing_Activity_Type__c, Type, MIBOS_Migration_Name__c, Legacy_Source_ID__c, RecurrenceEndDateOnly, RecurrenceInterval, RecurrenceDayOfWeekMask, RecurrenceStartDateOnly,Contract_Expiration_Task__c, IsReminderSet FROM Task WHERE WhatId In: sContractIds AND Contract_Expiration_Task__c = True ];
        List<Task>  taskList = [    SELECT  WhoId, WhatId, Was_Emergency_Key__c, Type, Status, StageObjectiveId__c, 
                                            ReminderDateTime, RecurrenceType, 
                                            RecurrenceTimeZoneSidKey, RecurrenceStartDateOnly, RecurrenceMonthOfYear, RecurrenceInterval, RecurrenceInstance, RecurrenceEndDateOnly, RecurrenceDayOfWeekMask, RecurrenceDayOfMonth, 
                                            RecurrenceActivityId, RecordTypeId, Priority, OwnerId, ObjectiveActionID__c, 
                                            License_Type__c, License_Key_Date__c, License_Activity__c, 
                                            Key_Action__c, Is_Test_Demo_Config_Key__c, IsClosed, Id, Description,  
                                            Contract_Expiration_Task__c, 
                                            Coaching_Status__c, CallType, CallObject, 
                                            CallDurationInSeconds, CallDisposition, CTI_ANI__c, ActivityDate, AccountId
                                    FROM    Task 
                                    WHERE   WhatId In: sContractIds 
                                    AND     Contract_Expiration_Task__c = True ];
        taskListcontainer = taskList.clone();
        system.debug('***taskListcontainer '+taskListcontainer);
        if(taskList!=null&&!taskList.isEmpty()){
            for(Task tsk : taskListcontainer){
                if(contractMap.containskey(tsk.WhatId)){
                    tsk.Id=null;
                    Integer integerValue2 = Integer.valueOf(contractMap.get(tsk.WhatId).Renewal_Term_Length_in_months__c);
                    tsk.ActivityDate = tsk.ActivityDate.addMonths(integerValue2);
                    tsk.RecordTypeId = taskRT;
                    taskTempList.add(tsk);
                }
            }
            if(taskTempList!=null&&!taskTempList.isEmpty()){
                try{
                    insert taskTempList;
                }
                catch(DMLException e){
                    System.debug('There was a problem insert task - ' + e.getMessage());
                }
            }
            system.debug('***taskTempList '+taskTempList);
            for(Task tsk : taskList){
                if(tsk.Status!='Completed'){
                tsk.status='Completed';
                taskTempList2.add(tsk);
                }
            }
            if(taskTempList2!=null&&!taskTempList2.isEmpty()){
                try{
                    update taskTempList2;
                }
                catch(DMLException e){
                    System.debug('There was a problem update task - ' + e.getMessage());
                }
            }
        }
    }
    
    global void finish(Database.BatchableContext BC){
    }
}