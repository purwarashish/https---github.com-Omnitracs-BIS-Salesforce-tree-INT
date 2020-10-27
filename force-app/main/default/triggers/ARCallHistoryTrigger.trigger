trigger ARCallHistoryTrigger on AR_Call_History__c (After Insert) {
    if(trigger.isInsert){
        if(trigger.isAfter){
            ARCallHistoryUtils.ARCallHistoryInsert(Trigger.new);
        }
    }
    
}