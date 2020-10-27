trigger updateNewCustImplementationSalesOrder on Sales_Order__c (after insert, after update) {
  Id[] accountIds = new List<Id>();
  Sales_Order__c[] salesOrderRecords = Trigger.new;
  Map<Id,Sales_Order__c> newSalesOrderMap = new Map<Id,Sales_Order__c>();
  
  //Create arrays of Account Ids
  for (Integer i = 0; i < salesOrderRecords.size(); i++) {
    accountIds.add(salesOrderRecords[i].Account__c);
    newSalesOrderMap.put(salesOrderRecords[i].Account__c,salesOrderRecords[i]);
  }
  
  if (newSalesOrderMap.size() > 0){
    NewCustomerImplementation.trackFirstOrderReceived(newSalesOrderMap);
  }
}