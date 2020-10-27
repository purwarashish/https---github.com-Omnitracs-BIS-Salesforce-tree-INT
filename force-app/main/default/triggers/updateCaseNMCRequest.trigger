//*****************************************************************
// Find all of the Cases that are NMC Requests for this NMC_Account
//  that do NOT have NMC_Account_Existing__c lookup field populated 
//  and update the field to add the relationship.
//*****************************************************************
trigger updateCaseNMCRequest on NMC_Account__c (before update, after insert) {

  NMC_Account__c nmcAccount = Trigger.New[0];
  Case[] nmcRequest = [SELECT Id 
                                 FROM Case 
                                 WHERE AccountId = :nmcAccount.Account__c 
                                   AND NMC_Account_Number__c =:nmcAccount.NMC_Account__c
                                   AND NMC_Account__c = null Limit 1000];

  for(Integer i = 0; i < nmcRequest.size(); i++) {
    nmcRequest[i].NMC_Account__c = nmcAccount.ID;
  }
  if(!nmcRequest.IsEmpty()){       
    try{
      update nmcRequest;
    } catch (DMLException ex){
      System.debug('DEBUG: caught DML exception while trying to relate NMC Request to updated NMC Account:' + ex);
      nmcAccount.addError(ex);
      
    }
  }
}