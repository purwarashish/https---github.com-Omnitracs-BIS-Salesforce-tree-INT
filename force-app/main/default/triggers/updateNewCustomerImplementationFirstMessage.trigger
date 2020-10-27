trigger updateNewCustomerImplementationFirstMessage on Serialized_Units__c (after insert, after update) {
  /*Serialized_Units__c[] sUnitRecords = Trigger.new;
  Map<Id,Serialized_Units__c> newSerialedUnitMap = new Map<Id,Serialized_Units__c>();

  //Each unit is only relevant for the New Customer Implementation milestone if it actually has
  //     either the Last_Message_Date_Time__c or Last_Position_Date_Time__c field populated.
  for (Integer i = 0; i < sUnitRecords.size(); i++) {
    Datetime lastMsgDateTime = sUnitRecords[i].Last_Message_Date_Time__c;
    Datetime lastPosDateTime = sUnitRecords[i].Last_Position_Date_Time__c;
    if (lastMsgDateTime != null || lastPosDateTime != null){

      //if the only dates are 1/1/1970, then we will ignore these dates.  They are bogus data values that comes across from
      //  the originating data feed from Oracle.  Updated 3/15/08 for Mark Silber by Tom Scott.
      System.debug('DEBUG: the lastMsgDateTime is ' + lastMsgDateTime );
      System.debug('DEBUG: the lastPosDateTime is ' + lastPosDateTime );
        
      if  ( (lastMsgDateTime == null || lastMsgDateTime.year() < 1971 )
       &&   (lastPosDateTime == null || lastPosDateTime.year() < 1971 )){
        System.debug('DEBUG: IGNORING serialized unit - the lastMsgDateTime=' + lastMsgDateTime + ' and lastPosDateTime=' + lastPosDateTime );
      } else {  
        newSerialedUnitMap.put(sUnitRecords[i].Account__c,sUnitRecords[i]);
      }
    }
  }
  

  if(newSerialedUnitMap.size() > 0){
    NewCustomerImplementation.trackFirstMessage(newSerialedUnitMap);
  }
*/
}