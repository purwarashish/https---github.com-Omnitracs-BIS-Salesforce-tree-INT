trigger updateNewCustImplementationAgreementStatusNew on echosign_dev1__SIGN_Agreement__c (after delete, after insert, after update) {

  Id[] deletedAgreementList = new List<Id>();

  if(Trigger.isDelete){
    //add all deleted records to the list of deleted contracts
    echosign_dev1__SIGN_Agreement__c[] agreementRecords =  Trigger.old;
    for (Integer i = 0; i < agreementRecords.size(); i++) {
      deletedAgreementList.add(agreementRecords[i].Id);
    }
  } else { //insert or update
    echosign_dev1__SIGN_Agreement__c[] agreementRecords = Trigger.new;
    Map<Id,echosign_dev1__SIGN_Agreement__c> acctAgreementMapForNewAgreements = new Map<Id,echosign_dev1__SIGN_Agreement__c>();
    Map<Id,echosign_dev1__SIGN_Agreement__c> acctAgreementMapForCompletedAgreements = new Map<Id,echosign_dev1__SIGN_Agreement__c>();
    
    //Create 2 arrays of Account Ids, 1 for newly submitted requests and 1 for completed requests
    for (Integer i = 0; i < agreementRecords.size(); i++) {
//System.debug('Agreement status = ' + agreementRecords[i].echosign_dev1__Status__c );

      //  If we have some new agreements coming through, then gather 2 lists of Account IDs:
      //     1) Agreements that are newly submitted or newly assigned 
      //     2) Agreements that have a status of 'Signed By Qualcomm'
      if (agreementRecords[i].echosign_dev1__Status__c == QESConstants.AGREEMENT_STATUS_DRAFT){
        acctAgreementMapForNewAgreements.put(agreementRecords[i].echosign_dev1__Account__c, agreementRecords[i]);
      } else if (agreementRecords[i].echosign_dev1__Status__c == QESConstants.AGREEMENT_STATUS_SIGNED) { 
        acctAgreementMapForCompletedAgreements.put(agreementRecords[i].echosign_dev1__Account__c,agreementRecords[i]);
      }
    }
        
    if(acctAgreementMapForNewAgreements.size() > 0){
//System.debug('Agreements that will have a New Customer Implementation record created:' + acctAgreementMapForNewAgreements);
      NewCustomerImplementation.trackNewContractOrAgreement(acctAgreementMapForNewAgreements);
    }
    
    if(acctAgreementMapForCompletedAgreements.size() > 0){
//System.debug('Agreements that will update New Customer Implementation record to completed:' + acctAgreementMapForCompletedAgreements);
//??      NewCustomerImplementation.trackSignedAgreement(acctAgreementMapForCompletedAgreements);
    }
  }  //end insert/update functionality
  
  if(deletedAgreementList.size() > 0){
    //System.debug('Deleted agreement Ids that will be checked for New Customer Implementation records to cleanup:' + deletedAgreementList);
    NewCustomerImplementation.trackDeletedContractOrAgreement(deletedAgreementList);
  }

}