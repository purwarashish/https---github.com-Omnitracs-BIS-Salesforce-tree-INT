trigger arAgingMostRecent on AR_Aging__c (before insert) {
  //Incoming AR Aging objects for an Account need to have a flag set to indicate that it's the most recent record
  //  This trigger will also update the PREVIOUS AR Aging object so that it is NOT the most recent
  List<ID> accountIdList = new List<ID>(); 
  
  for(AR_Aging__c nextRecord : Trigger.New) {
    accountIdList.Add(nextRecord.Account__c);
    nextRecord.Most_Recent__c = true;  //set most_recent record flag to true for new records
//    nextRecord.Snapshot_Date__c = System.today();  //set the Snapshot date field as today; 12/3/07 - use DEFAULT value on field, instead
  }

  //Find last month's AR Aging objects; LIMIT - should result in same # of records as incoming batch size (200?)
  AR_Aging__c[] arAgingToUpdate = [SELECT Id, Most_Recent__c FROM AR_Aging__c WHERE Account__c in :accountIdList AND Most_Recent__c = true];

  for(AR_Aging__c nextRecord : arAgingToUpdate) {
    nextRecord.Most_Recent__c = false;  //set most_recent record flag to false for old records
  }
  
  System.debug('TSCOTT update the following AR Aging objects to NOT be the most recent: ' + arAgingToUpdate);

  update arAgingToUpdate;  //LIMIT - should equal the # of records in batch size (200)

}