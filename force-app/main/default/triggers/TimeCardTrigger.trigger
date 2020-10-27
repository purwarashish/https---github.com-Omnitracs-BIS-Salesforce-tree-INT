trigger TimeCardTrigger on Time_Card__c (before update)
{
    if (Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate))
    {
        //  before/after update
        for (Time_Card__c tc : Trigger.new)
        {
            Time_Card__c oldTc = Trigger.oldMap.get(tc.id);
            
            //lookforDupeTimeCard(tc);
            
            if (Trigger.isBefore && Trigger.isUpdate)
            {
                if (oldTc.Submit_Status__c != tc.Submit_Status__c &&
                   (tc.Submit_Status__c == 'Approved' ||
                   tc.Submit_Status__c == 'Rejected') )
                {
                    if (tc.Submit_Status__c == 'Approved')
                    {
                        tc.Approval_Date__c = datetime.now();
                        tc.Approved_by__c = userInfo.getUserId();
                    }
                    if (tc.Submit_Status__c == 'Rejected')                      
                    {
                        tc.Reject_date__c = datetime.now();
                        tc.Rejected_by__c = userInfo.getUserId();
                    }
                
                }
            }
        }
    }
}