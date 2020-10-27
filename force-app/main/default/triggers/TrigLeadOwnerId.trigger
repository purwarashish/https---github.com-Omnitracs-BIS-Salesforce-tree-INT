/**@author : Amrita Ganguly
  *@Description : To populate Record owner field on lead with ownerId
**/
trigger TrigLeadOwnerId on Lead (before Insert,before Update) {
/*
     BypassTriggerUtility u = new BypassTriggerUtility();  
     if (u.isTriggerBypassed()) {
         return;
     }

for(lead currLead:trigger.new)
{
    
    string ownerId = currLead.ownerId;
    if(ownerId != null && ownerId !='')
    {
        if(ownerId.startsWith('00G'))
        {
            currLead.Record_Owner__c = null;    
        }
        else 
        {
            currLead.Record_Owner__c = currLead.ownerId ;
        }
    }

}*/
}