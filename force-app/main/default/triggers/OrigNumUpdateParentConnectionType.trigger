trigger OrigNumUpdateParentConnectionType on Originating_Number__c (after insert, after update) {

  //add logic here to update the parent ConnectionType object. 
  //   we will set the Last_Originating_Number_Change __c to the current date/time
  //   the plan is to have that update fire a workflow rule that sends an outbound msg for the ConnectionType.  That outbound rule already exists, but needs to fire when children "Originating Number" records are inserted/updated.  - T.Scott

  for(Originating_Number__c originatingNumber : Trigger.New) {
      String parentConnectionTypeID = originatingNumber.Connection_Type__c;

System.debug ('DEBUG: connection type id to update is ' + parentConnectionTypeID);

      Connection_Type__c connTypeToUpdate = [Select Id, Name, Last_Originating_Number_Change__c from Connection_Type__c where ID = :parentConnectionTypeID] ;
      connTypeToUpdate.Last_Originating_Number_Change__c = System.Now();

System.debug('DEBUG: connection to update, old OrigNumberChage date is ' + connTypeToUpdate.Last_Originating_Number_Change__c);
     
    Update connTypeToUpdate;

  }

}