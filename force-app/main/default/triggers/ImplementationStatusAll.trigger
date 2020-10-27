/***********************************************************************************
Date: 2 Dec 2010 
Author: David Ragsdale

Description:  This trigger will update the Implementation Status Update object
************************************************************************************/
trigger ImplementationStatusAll on Implementation_Status_Update__c (before insert) {

    if (trigger.isInsert)
    {
        //Implementation Status Updates for an Account need to have a flag set to indicate that it's the most recent record
        //  This trigger will also update the PREVIOUS Implementation Status object so that it is NOT the most recent
        List<ID> accountIdList = new List<ID>(); 
  
        for(Implementation_Status_Update__c nextRecord : Trigger.New) {
            accountIdList.Add(nextRecord.Account__c);
            nextRecord.Most_Recent__c = true;  //set most_recent record flag to true for new records
        }

        //Find last Implementation Status object; LIMIT - should result in same # of records as incoming batch size
        Implementation_Status_Update__c[] ImplementationStatusToUpdate = [SELECT Id, Most_Recent__c FROM Implementation_Status_Update__c WHERE Account__c in :accountIdList AND Most_Recent__c = true];

        for(Implementation_Status_Update__c nextRecord : ImplementationStatusToUpdate) {
            nextRecord.Most_Recent__c = false;  //set most_recent record flag to false for old records
        }

        update ImplementationStatusToUpdate;  //LIMIT - should equal the # of records in batch size
    }
}