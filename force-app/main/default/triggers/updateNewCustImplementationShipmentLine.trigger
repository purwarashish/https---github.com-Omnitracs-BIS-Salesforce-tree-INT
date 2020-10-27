trigger updateNewCustImplementationShipmentLine on Shipment_Line__c (after insert, after update) {
Map<Id, Shipment_Line__c> acctIdShipmentMap = new Map<Id, Shipment_Line__c>();
  
  Id[] accountIds = new List<Id>();
  Shipment_Line__c[] shipmentRecords = Trigger.new;
  
  //Create a map of <AccountId=ShipmentRecord> 
  for (Integer i = 0; i < shipmentRecords.size(); i++) {
    if(acctIdShipmentMap.containsKey(shipmentRecords[i].Account__c)){
      //Account already has a shipment in the map, so we need to compare the shipment dates
      Shipment_Line__c existingShipmentInMap = (Shipment_Line__c) acctIdShipmentMap.get(shipmentRecords[i].Account__c);
      if (shipmentRecords[i].Scheduled_Ship_Date__c < existingShipmentInMap.Scheduled_Ship_Date__c){
        //this shipments date is BEFORE the previous one, so REPLACE the shipment entry in the map
        acctIdShipmentMap.put(shipmentRecords[i].Account__c, shipmentRecords[i]);
      }
    } else {        
      //Account doesn't have any shipments in the map, so add this one
      acctIdShipmentMap.put(shipmentRecords[i].Account__c, shipmentRecords[i]);
    }
  }
  
  if(acctIdShipmentMap.size() > 0){
    //Call this method to create/update the NewCustomerImplementation object if necessary
    NewCustomerImplementation.trackFirstShipment(acctIdShipmentMap);   
  }
}