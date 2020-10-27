public class NewCustomerImplementation {
  static final String[] EMAIL_ERROR_TO_ADDRESSES = new String[] {'dragsdale@qualcomm.com'};
  
  //===============================================================================
  //==========  Create new New_Customer_Implementation__c records  ================
  //===============================================================================
  public static void trackNewContractOrAgreement(Map<Id,SObject> newAcctAgreementsMap){
    System.debug('Account Ids with new agreements: ' + newAcctAgreementsMap);

    //determine if the Account needs a New Customer Implementation Record 
    New_Customer_Implementation__c[] existingNewCustImplRecords = [SELECT Id, Name, currentStage__c, Account__c 
                                                                   FROM New_Customer_Implementation__c 
                                                                   WHERE Account__c in :newAcctAgreementsMap.keySet()];
    System.debug('DEBUG: Found existing New Customer Implementation records:' + existingNewCustImplRecords);
    
    Set<Id> accountsWithExistingNewCustImplRecordsSet = new Set<Id>();
    for (Integer i = 0; i < existingNewCustImplRecords.size(); i++) {
      accountsWithExistingNewCustImplRecordsSet.add(existingNewCustImplRecords[i].Account__c);
    }
    System.debug('DEBUG: These accounts already have a New Customer Implementation Record:' + accountsWithExistingNewCustImplRecordsSet);
    

   //gather a list of Account IDs that do NOT have New_Customer_Implementation records
   Id[] acctIdsWithNoNewCustImpl = new List<Id>();
   for (Id acctId : newAcctAgreementsMap.keySet()){
    if (!accountsWithExistingNewCustImplRecordsSet.contains(acctId) ){
      acctIdsWithNoNewCustImpl.add(acctId);
     }
   }

   //Filter Accounts so that we are only tracking NEW customer accounts (i.e. Cust ID is null on Accout)
   Id[] acctIdsNeedingNewCustRecord = new List<Id>();
   Account[] newCustAccounts = [SELECT Id FROM Account WHERE QWBS_Cust_ID__c = null AND Id in :acctIdsWithNoNewCustImpl];
   for (Account newCustAcct : newCustAccounts){
     acctIdsNeedingNewCustRecord.add(newCustAcct.Id);
   }    


   System.debug('DEBUG: Account Ids that need a New Customer Implementation Record: ' + acctIdsNeedingNewCustRecord);
        
   //Gather new New_Customer_Implementation__c records to insert
   New_Customer_Implementation__c[] trackingRecordsToAdd = new List<New_Customer_Implementation__c>();
   for (Integer i = 0; i < acctIdsNeedingNewCustRecord.size(); i++) {
     SObject newAgreement = (SObject) newAcctAgreementsMap.get(acctIdsNeedingNewCustRecord[i]);
     New_Customer_Implementation__c newTrackingRecord = new New_Customer_Implementation__c();
     newTrackingRecord.Account__c = acctIdsNeedingNewCustRecord[i];
     newTrackingRecord.contractRequestDate__c = System.Today();
     newTrackingRecord.currentStage__c = QESConstants.CUST_PROVISIONING_STAGE_CONTRACT_REQUESTED;     
     newTrackingRecord.Contract_Req_or_Agreement_Id__c = newAgreement.Id;
     trackingRecordsToAdd.add(newTrackingRecord);      
   }
   
   System.debug('DEBUG: Adding the following New Customer Implementation records: ' + trackingRecordsToAdd);

   if(trackingRecordsToAdd.size() > 0){
     updateAndSendEmailIfFailed(trackingRecordsToAdd, true, false);    
   }
  }

  //==============================================================================================
  //====  Delete New_Customer_Implementation__c related to cancelled contract requests ===========
  //==============================================================================================
  public static void trackDeletedContractOrAgreement(Id[] deletedAgreementIdList){
    System.debug('DEBUG: Ids of deleted agreements: ' + deletedAgreementIdList);
    //determine if any New Customer Implementation records are related to this agreement
    New_Customer_Implementation__c[] trackingRecordsToDelete = [SELECT Id FROM New_Customer_Implementation__c  WHERE Contract_Req_or_Agreement_Id__c in :deletedAgreementIdList];
    System.debug('DEBUG: NewCustomerImplementation records to delete: ' + trackingRecordsToDelete);
     
    if (trackingRecordsToDelete.size() > 0){
      updateAndSendEmailIfFailed(trackingRecordsToDelete, false, true);
    }

  }
  //===============================================================================
  //====  Update New_Customer_Implementation__c contract complete date ===========
  //===============================================================================
  public static void trackCompletedContractRequest(Map<Id,Contract_Request__c> acctCompletedContractRequestsMap){
    System.debug('DEBUG: map of completed AcctId=Contract_Request: ' + acctCompletedContractRequestsMap);
    //determine if the Account has a tracking record awaiting a completed contract
    New_Customer_Implementation__c[] trackingRecordsAwaitingContracts = [SELECT Id, contract_Fully_Executed_Date__c, currentStage__c, Account__c FROM New_Customer_Implementation__c  WHERE contract_Fully_Executed_Date__c = null and Account__c in :acctCompletedContractRequestsMap.keySet()];
    System.debug('DEBUG: NewCustomerImplementation records awaiting contract completion: ' + trackingRecordsAwaitingContracts);
     
    //Update the date that the contract was fully executed on the tracking records
    for (Integer i = 0; i < trackingRecordsAwaitingContracts.size(); i++) {
      Contract_Request__c completedContractReq = (Contract_Request__c) acctCompletedContractRequestsMap.get(trackingRecordsAwaitingContracts[i].Account__c);      
      System.debug('DEBUG: NewCustomerImplementation will be related to this contract request: ' + completedContractReq);
      trackingRecordsAwaitingContracts[i].contract_Fully_Executed_Date__c = System.Today();
      trackingRecordsAwaitingContracts[i].Contract_Req_or_Agreement_Id__c = completedContractReq.Id;
      updateStageOnlyIfAppropriate(trackingRecordsAwaitingContracts[i], QESConstants.CUST_PROVISIONING_STAGE_CONTRACT_EXECUTED);
    }
    
    if (trackingRecordsAwaitingContracts.size() > 0){
      updateAndSendEmailIfFailed(trackingRecordsAwaitingContracts);
    }
  }

  
  //===============================================================================
  //==========  Create new New_Customer_Implementation__c records ================
  //===============================================================================
  /*public static void trackSignedAgreement(Map<Id,SIGN_Agreement__c> newAcctAgreementsMap){
    System.debug('DEBUG: map of completed AcctId=Agreements: ' + newAcctAgreementsMap);
    //determine if the Account has a tracking record awaiting a completed agreement
    New_Customer_Implementation__c[] trackingRecordsAwaitingAgreements = [SELECT Id, contract_Fully_Executed_Date__c, currentStage__c, Account__c FROM New_Customer_Implementation__c  WHERE contract_Fully_Executed_Date__c = null and Account__c in :newAcctAgreementsMap.keySet()];
    System.debug('DEBUG: NewCustomerImplementation records awaiting contract completion: ' + trackingRecordsAwaitingAgreements);
     
    //Update the date that the contract was fully executed on the tracking records
    for (Integer i = 0; i < trackingRecordsAwaitingAgreements.size(); i++) {
      SIGN_Agreement__c completedAgreement;
      //SIGN_Agreement__c completedAgreement = (SIGN_Agreement__c) newAcctAgreementsMap.get(trackingRecordsAwaitingAgreements[i].Account__c);      
      System.debug('DEBUG: NewCustomerImplementation will be related to this agreement: ' + completedAgreement);
      
      //Datetime completedDatetime = completedAgreement.DateSigned__c;
      Datetime completedDatetime;
      if(completedDatetime == null) ( completedDatetime = System.Now());
      Date completedDate = Date.newInstance(completedDatetime.year(),completedDatetime.month(),completedDatetime.day());      
      trackingRecordsAwaitingAgreements[i].contract_Fully_Executed_Date__c = completedDate;
      trackingRecordsAwaitingAgreements[i].Contract_Req_or_Agreement_Id__c = completedAgreement.Id;
      updateStageOnlyIfAppropriate(trackingRecordsAwaitingAgreements[i], QESConstants.CUST_PROVISIONING_STAGE_CONTRACT_EXECUTED);
    }
    
    if (trackingRecordsAwaitingAgreements.size() > 0){
      updateAndSendEmailIfFailed(trackingRecordsAwaitingAgreements);
    }    
  }*/


  
  
  //===============================================================================
  //====  Update New_Customer_Implementation__c nmc setup complete date ==========
  //===============================================================================
  public static void trackCompletedNMCSetup(Map<Id,NMC_Account__c> newAcctNMCAcctMap){
     System.debug('DEBUG: map of new NMC Account map; AcctId=NMC_Account: ' + newAcctNMCAcctMap);
    
     //determine if the Account has a tracking record awaiting a completed nmc setup
     New_Customer_Implementation__c[] trackingRecordsAwaitingCustomerSetup = [SELECT Id, Name, currentStage__c, Account__c FROM New_Customer_Implementation__c WHERE customerNMCSetupCompleteDate__c = null and Account__c in :newAcctNMCAcctMap.keySet()];     
     System.debug('DEBUG: Found these accounts awaiting NMC Setup complete' + trackingRecordsAwaitingCustomerSetup);
      
    //Update the date that the contract was fully executed on the tracking records
    for (Integer i = 0; i < trackingRecordsAwaitingCustomerSetup.size(); i++) {
      NMC_Account__c newlyCreatedNMCAcct = (NMC_Account__c) newAcctNMCAcctMap.get(trackingRecordsAwaitingCustomerSetup[i].Account__c);      
      System.debug('DEBUG: NewCustomerImplementation will be related to this NMC Account: ' + newlyCreatedNMCAcct);
      trackingRecordsAwaitingCustomerSetup[i].customerNMCSetupCompleteDate__c = System.Today();
      trackingRecordsAwaitingCustomerSetup[i].NMC_Account__c = newlyCreatedNMCAcct.Id;
      //We will NOT track NMC Account setup as a separate stage
      //updateStageOnlyIfAppropriate(trackingRecordsAwaitingCustomerSetup[i], QESConstants.CUST_PROVISIONING_STAGE_CUSTOMER_FULLY_SETUP);
    }
    
    if(trackingRecordsAwaitingCustomerSetup.size() > 0){
      updateAndSendEmailIfFailed(trackingRecordsAwaitingCustomerSetup);
    }
  }



  //===============================================================================
  //====  Update New_Customer_Implementation__c 1st order recv'd date ============
  //===============================================================================
  public static void trackFirstOrderReceived(Map<Id,Sales_Order__c> newSalesOrderMap){
     //determine if the Account has a tracking record awaiting the first order
     New_Customer_Implementation__c[] trackingRecordAwaitingSalesOrder = [SELECT Id, Name, currentStage__c, Account__c  FROM New_Customer_Implementation__c 
                                                                           WHERE orderPlacedDate__c = null 
                                                                             AND Account__c in :newSalesOrderMap.keySet()];
     
    //Update the date that the sales order was received on the tracking records
    for (Integer i = 0; i < trackingRecordAwaitingSalesOrder.size(); i++) {
      Sales_Order__c newSalesOrder = (Sales_Order__c) newSalesOrderMap.get(trackingRecordAwaitingSalesOrder[i].Account__c);      
      if (newSalesOrder.Sales_Order_Date__c != null){
        trackingRecordAwaitingSalesOrder[i].orderPlacedDate__c = newSalesOrder.Sales_Order_Date__c;
      } else {
        trackingRecordAwaitingSalesOrder[i].orderPlacedDate__c = System.Today();
      }
      trackingRecordAwaitingSalesOrder[i].Sales_Order__c = newSalesOrder.Id;
      updateStageOnlyIfAppropriate(trackingRecordAwaitingSalesOrder[i], QESConstants.CUST_PROVISIONING_STAGE_ORDER_PLACED);
    }
    
    if(trackingRecordAwaitingSalesOrder.size() > 0){
      updateAndSendEmailIfFailed(trackingRecordAwaitingSalesOrder);
    }
  }

  //===============================================================================
  //====  Update New_Customer_Implementation__c 1st shipment date ================
  //===============================================================================
  public static void trackFirstShipment(Map<Id,Shipment_Line__c> accountIdShipmentMap){
     //determine if the Account has a tracking record awaiting a shipment line
     New_Customer_Implementation__c[] trackingRecordsAwaitingFirstShipment = [SELECT Id, Name, currentStage__c,shippedDate__c,Shipment_Line__c, Account__c FROM New_Customer_Implementation__c WHERE shippedDate__c = null and Account__c in :accountIdShipmentMap.keySet()];
     
    //Update the date that the contract was fully executed on the tracking records
    for (Integer i = 0; i < trackingRecordsAwaitingFirstShipment.size(); i++) {
      Shipment_Line__c firstAccountShipment = (Shipment_Line__c) accountIdShipmentMap.get(trackingRecordsAwaitingFirstShipment[i].Account__c);
      System.debug('DEBUG: setting shipment date as ' + firstAccountShipment.Shipped_Date__c + ' on NewCustomerImplementation record ' + trackingRecordsAwaitingFirstShipment[i].Name);
      trackingRecordsAwaitingFirstShipment[i].shippedDate__c = firstAccountShipment.Shipped_Date__c;
      System.debug('The Value of firstAccountShipment.Id is '+ firstAccountShipment.Id);
      trackingRecordsAwaitingFirstShipment[i].Shipment_Line__c = firstAccountShipment.Id;
      updateStageOnlyIfAppropriate(trackingRecordsAwaitingFirstShipment[i], QESConstants.CUST_PROVISIONING_STAGE_FIRST_SHIPMENT);
      
    }
    
    if(trackingRecordsAwaitingFirstShipment.size() > 0){
      updateAndSendEmailIfFailed(trackingRecordsAwaitingFirstShipment);
    }
  }


  //===============================================================================
  //====  Update New_Customer_Implementation__c 1st message date ================
  //===============================================================================
  public static void trackFirstMessage(Map<Id,Serialized_Units__c> newMessageMap){    
    
    //determine if the Account has a tracking record awaiting the 1st message
    New_Customer_Implementation__c[] trackingRecordsAwaitingFirstMessage = [SELECT Id, Name, currentStage__c, Account__c FROM New_Customer_Implementation__c WHERE firstMessageReceivedDate__c = null and Account__c in :newMessageMap.keySet()];
     
    //Update the date on the tracking records
    for (Integer i = 0; i < trackingRecordsAwaitingFirstMessage.size(); i++) {
      Serialized_Units__c firstMessageUnit = (Serialized_Units__c) newMessageMap.get(trackingRecordsAwaitingFirstMessage[i].Account__c);
            
      DateTime lastMsg = firstMessageUnit.Last_Message_Date_Time__c;
      DateTime lastPos = firstMessageUnit.Last_Position_Date_Time__c;
      DateTime firstMsgDateTime;
      if (lastMsg != null && lastMsg.year() > 1971){
        firstMsgDateTime = lastMsg;
        System.debug('DEBUG: lastMsg date/time is ' + lastMsg);
        if ((lastPos != null) && (lastPos < lastMsg) && lastPos.year() > 1971){
          System.debug('DEBUG: lastPos date/time is ' + lastPos);
          firstMsgDateTime = lastPos;
        }
      } else {
        //ONE of the datetime values must be populated, so let's use the last Position
        firstMsgDateTime = lastPos;      
        System.debug('DEBUG: lastPos date/time is ' + lastPos);
      }
      System.debug('DEBUG: we will use firstMsgDateTime as the date of the 1st message ' + firstMsgDateTime);
      Date firstMsgDate = Date.newInstance(firstMsgDateTime.year(),firstMsgDateTime.month(),firstMsgDateTime.day());      
      trackingRecordsAwaitingFirstMessage[i].firstMessageReceivedDate__c = firstMsgDate;
      trackingRecordsAwaitingFirstMessage[i].Serialized_Unit__c = firstMessageUnit.Id;
      //trackingRecordsAwaitingFirstMessage[i].currentStage__c = QESConstants.CUST_PROVISIONING_STAGE_FIRST_MSG;      
      updateStageOnlyIfAppropriate(trackingRecordsAwaitingFirstMessage[i], QESConstants.CUST_PROVISIONING_STAGE_FIRST_MSG);
    }
    
    if(trackingRecordsAwaitingFirstMessage.size() > 0){
      updateAndSendEmailIfFailed(trackingRecordsAwaitingFirstMessage);
    }
  }

  //===============================================================================
  //====  Update the given Sobjects and send an email if there is an error.
  //====   We don't want NewCustomerImplementation exceptions to halt other
  //====   operations, so we'll catch the errors and send an email.
  //===============================================================================
  public static void updateAndSendEmailIfFailed(SObject[] recordsToUpdate){
    updateAndSendEmailIfFailed(recordsToUpdate, false, false);  //False, False params are "not insert" And "not delete"; i.e. Update
  }
  
  //===============================================================================
  //====  Update the given Sobjects and send an email if there is an error.
  //====   We don't want NewCustomerImplementation exceptions to halt other
  //====   operations, so we'll catch the errors and send an email.
  //===============================================================================
  public static void updateAndSendEmailIfFailed(SObject[] recordsToUpdate, Boolean isInsert, Boolean isDelete){
    System.debug('DEBUG: updateAndSendEmailIfFailed');
    try{
      //===================================================================================
      //===================================================================================
      //zz DEBUG ONLY - the next line will cause the update to fail - for testing failures only!!!
      //Shipment__c tmpShipment = (Shipment__c) recordsToUpdate[0];      
      //tmpShipment.CreatedById = 'zzzz';
      //===================================================================================
      //===================================================================================
      
      if (isInsert){
        insert recordsToUpdate;
      } else if (isDelete){
        delete recordsToUpdate;
      } else {
        update recordsToUpdate;
      }
    } catch (Exception ex){
      System.debug('ERROR updating NewCustomerImplementation objects: ' + ex);
      //Send an email message so that this problem can be investigated
      Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
      mail.setToAddresses(EMAIL_ERROR_TO_ADDRESSES);
      mail.setReplyTo('sfdc.support@qualcomm.com');
      mail.setSenderDisplayName('Salesforce QES Apex Code - New Customer Implementation');
      mail.setSubject('Error updating New Customer Implementation records');
      mail.setUseSignature(false);
      mail.setPlainTextBody('The Apex Code that is updating New Customer Implementation records has failed with the following exception: ' + ex);
      Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });      
    }
  } 
   
  //===============================================================================
  //====  Update New_Customer_Implementation__c stage ONLY if the stage reached
  //====    does not set the record back in the process.  E.g. if we receive 
  //====    information about a shipment AFTER the first message, we don't want
  //====    to set the status backwards.                          
  //===============================================================================
  public static void updateStageOnlyIfAppropriate(New_Customer_Implementation__c nciRecord, String stageReached){
     //Set the current stage on the nciRecord only if the new stage moves us forward in the process     
     if(assignStageValue(nciRecord.currentStage__c) < assignStageValue(stageReached)){       
       System.debug('DEBUG: stage reached moves us forward in the process.  Update the current stage on the New Customer Implementation Record');
       nciRecord.currentStage__c = stageReached; 
     }
  }
  
  
  //===============================================================================
  //====  Return a numeric value for the stage representing it's place in sequence.
  //===============================================================================
  public static integer assignStageValue(String stageToEvaluate){
    System.debug('DEBUG: evaluateStage : ' + stageToEvaluate);
         if(stageToEvaluate == QESConstants.CUST_PROVISIONING_STAGE_CONTRACT_REQUESTED){ return 1; }
    else if(stageToEvaluate == QESConstants.CUST_PROVISIONING_STAGE_CONTRACT_EXECUTED){ return 2; }
    else if(stageToEvaluate == QESConstants.CUST_PROVISIONING_STAGE_CUSTOMER_FULLY_SETUP){ return 3; }
    else if(stageToEvaluate == QESConstants.CUST_PROVISIONING_STAGE_ORDER_PLACED){ return 4; }
    else if(stageToEvaluate == QESConstants.CUST_PROVISIONING_STAGE_FIRST_SHIPMENT){ return 5; }
    else if(stageToEvaluate == QESConstants.CUST_PROVISIONING_STAGE_FIRST_MSG){ return 6; }
    else { return 0; }
    //return value of ZERO if stage is not found
    //  If current stage is not found, then we will update record w/stage reached
    //  If stage reached is not found, then no update will occur
  }                            
  

}  //end class NewCustomerImplementation