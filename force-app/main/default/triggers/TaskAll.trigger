trigger TaskAll on Task (
    
    after delete, after insert, after undelete, after update, before delete, before insert, before update
) {

     BypassTriggerUtility u = new BypassTriggerUtility();  
     if (u.isTriggerBypassed()) {
         return;
     }
     
    public static final String STRING_ACCOUNT_PREFIX = '001';
    if(Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate)) {
                
        // The determination of 'interface' is in a hierarchical custom setting.
        // Don't execute if interface user.
        
        List<Task> listOfTasksToBeProcessed = new List<Task>();
        if(Interface_Users__c.getInstance().Is_Interface__c) return;
        
        for(Task t : Trigger.new)
        {
            //If not created by an interface like Eloqua
            if(!Interface_Users__c.getInstance(t.createdById).Is_Interface__c)
            listOfTasksToBeProcessed.add(t);
        }
        
        //LeadActivityUtils.updatePartnerDrivenActivity(listOfTasksToBeProcessed);
        //OpportunityActivityUtils.updatePartnerDrivenActivity(listOfTasksToBeProcessed);
        AccountActivityUtils.updateActivity(listOfTasksToBeProcessed);
    }
    
    if(trigger.isBefore && Trigger.isInsert)
    {
        LogInviteEmailsAsTask.logEmails(trigger.new);  
        PartnerActivityUtils.updatePartnerDrivenActivity(trigger.new);   
             
    }
    
     if(trigger.isBefore && Trigger.isUpdate)
    {
        PartnerActivityUtils.updatePartnerDrivenActivity(trigger.new);   
             
    }
    List<Account> lstOfAcctToUpdate = new List<Account>();
    List<String> acctIdToUpdate = new List<String>();
    if(trigger.isBefore && trigger.isDelete && system.label.Activate_Summation_of_Open_Activity == 'true'){
        
        for(Task tsk:Trigger.old){
            String acctId = tsk.whatId;
            //acctId = acctId.substring(0,3);
            
            if(acctId != null && acctId.startsWith(STRING_ACCOUNT_PREFIX))
                acctIdToUpdate.add(tsk.whatId);            
        }
        if(!acctIdToUpdate.isEmpty()){
            lstOfAcctToUpdate = [Select id from account where id IN:acctIdToUpdate limit 50000];
            if(!lstOfAcctToUpdate.isEmpty()){
                try{
                    Update lstOfAcctToUpdate;
                }
                catch(Exception e){
                    system.debug('Account cannot be updated in Task all trigger');
                }
            }
        }        
    }
}