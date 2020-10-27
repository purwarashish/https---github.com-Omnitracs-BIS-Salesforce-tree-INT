trigger EventAll on Event (
    after delete, after insert, after undelete, after update, before delete, before insert, before update
) {

     BypassTriggerUtility u = new BypassTriggerUtility();  
     if (u.isTriggerBypassed()) {
         return;
     }

    if(Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate)) {
        LeadActivityUtils.updatePartnerDrivenActivity(Trigger.new);
        OpportunityActivityUtils.updatePartnerDrivenActivity(Trigger.new);
        
    }
    
    //*Code added as a part of CR 01205420
    List<Account> lstOfAcctToUpdate = new List<Account>();
    List<String> acctIdToUpdate = new List<String>();
    if(Trigger.isAfter  && system.label.Activate_Summation_of_Open_Activity == 'true'){
        
        if(Trigger.isInsert || Trigger.isUpdate){
            for(Event evt:Trigger.new){
                String acctId = evt.whatId;
                
                
                if(acctId != null && acctId.startsWith('001'))
                    acctIdToUpdate.add(evt.whatId);            
            }
        }
        else{
            system.debug('On delete'+Trigger.old);
            for(Event evt:Trigger.old){
                String acctId = evt.whatId;
                //acctId = acctId.substring(0,3);
                if(acctId != null && acctId.startsWith('001'))
                    acctIdToUpdate.add(evt.whatId);            
                }    
            }
        
        system.debug('@@@@acctIdToUpdate'+acctIdToUpdate);
        if(!acctIdToUpdate.isEmpty()){
            lstOfAcctToUpdate = [Select id from account where id IN:acctIdToUpdate limit 50000];
            if(!lstOfAcctToUpdate.isEmpty()){
                try{
                    Update lstOfAcctToUpdate;
                }
                catch(Exception e){
                    system.debug('Account cannot be updated in Event all trigger');
                }
            }
        }        
    }
}