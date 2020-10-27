trigger updateNewCustImplementationContractStatus on Contract_Request__c (after insert, after update, after delete) {
  Id[] deletedContractRequestIdList = new List<Id>();

  if(Trigger.isDelete){
    //add all deleted records to the list of deleted contracts
    Contract_Request__c[] requestRecords =  Trigger.old;
    for (Integer i = 0; i < requestRecords.size(); i++) {
      deletedContractRequestIdList.add(requestRecords[i].Id);
    }
  } else { //insert or update
    Contract_Request__c[] requestRecords = Trigger.new;
    Map<Id,Contract_Request__c> acctContractReqMapForNewRequests = new Map<Id,Contract_Request__c>();
    Map<Id,Contract_Request__c> acctContractReqMapForCompletedRequests = new Map<Id,Contract_Request__c>();
    
    //Create 2 arrays of Account Ids, 1 for newly submitted requests and 1 for completed requests
    for (Integer i = 0; i < requestRecords.size(); i++) {
        System.debug('Contract Request type = ' + requestRecords[i].Request_Type__c);
        System.debug('Contract Request status = ' + requestRecords[i].Request_Status__c );
        
      //First off, we are only concerned with NEW customer contracts
      //  If we have some new contracts coming through, then gather 2 lists of Account IDs:
      //     1) Requests that are newly submitted or newly assigned
      //     2) Requests that have a status of 'Signed By Qualcomm'
      if (requestRecords[i].Request_Type__c == QESConstants.CONTRACT_REQ_TYPE_NEW_SALES_CONTRACT){  
          if (requestRecords[i].Request_Status__c == QESConstants.CONTRACT_REQ_STATUS_SUBMITTED
             || requestRecords[i].Request_Status__c == QESConstants.CONTRACT_REQ_STATUS_ASSIGNED){
          acctContractReqMapForNewRequests.put(requestRecords[i].Account__c, requestRecords[i]);
        } else if (requestRecords[i].Request_Status__c == QESConstants.CONTRACT_REQ_STATUS_SIGNED_BY_QUALCOMM) {
          acctContractReqMapForCompletedRequests.put(requestRecords[i].Account__c,requestRecords[i]);
        } else if (requestRecords[i].Request_Status__c == QESConstants.CONTRACT_REQ_STATUS_CANCELLED) {
          deletedContractRequestIdList.add(requestRecords[i].Id);
        }
      }
    }
    
    
    if(acctContractReqMapForNewRequests.size() > 0){
      System.debug('Account Ids that will have a New Customer Implementation record created:' + acctContractReqMapForNewRequests);
      NewCustomerImplementation.trackNewContractOrAgreement(acctContractReqMapForNewRequests);
    }
    
    if(acctContractReqMapForCompletedRequests.size() > 0){
      System.debug('Account Ids that will update New Customer Implementation record to completed:' + acctContractReqMapForCompletedRequests);
      NewCustomerImplementation.trackCompletedContractRequest(acctContractReqMapForCompletedRequests);
    }
  }  //end insert/update functionality
  
  if(deletedContractRequestIdList.size() > 0){
    System.debug('Cancelled contract request Ids that will be checked for New Customer Implementation records to cleanup:' + deletedContractRequestIdList);
    NewCustomerImplementation.trackDeletedContractOrAgreement(deletedContractRequestIdList);
  }


}