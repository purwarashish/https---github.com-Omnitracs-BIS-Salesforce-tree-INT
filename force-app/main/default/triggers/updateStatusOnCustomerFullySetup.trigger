trigger updateStatusOnCustomerFullySetup on New_Customer_Implementation__c (before update) {
  Map<Id, New_Customer_Implementation__c> oldRecordMap = Trigger.oldMap;
  New_Customer_Implementation__c[] updatedRecords = Trigger.new;
  
  for (New_Customer_Implementation__c newRecord: updatedRecords){
    New_Customer_Implementation__c oldRecord = oldRecordMap.get(newRecord.Id);
    if (newRecord.Customer_Fully_Setup__c != null && oldRecord.Customer_Fully_Setup__c == null){
      System.debug('DEBUG: the date when the Customer was fully setup was changed from null to ' + newRecord.Customer_Fully_Setup__c + ' for ' + newRecord.Name);
      NewCustomerImplementation.updateStageOnlyIfAppropriate(newRecord, QESConstants.CUST_PROVISIONING_STAGE_CUSTOMER_FULLY_SETUP);
    }
  } 
}