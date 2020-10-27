trigger updateNewCustomerImplementationNMCSetup on NMC_Account__c (after insert) {
  Id[] accountIds = new List<Id>();
  NMC_Account__c[] newNmcAccounts = Trigger.new;
  Map<Id,NMC_Account__c> newAcctNMCAcctMap = new Map<Id,NMC_Account__c>();
   
  //Create arrays of Account Ids
  for (Integer i = 0; i < newNmcAccounts.size(); i++) {
    newAcctNMCAcctMap.put(newNmcAccounts[i].Account__c, newNmcAccounts[i]);
  } 
  
  if (newAcctNMCAcctMap.size() > 0){
    NewCustomerImplementation.trackCompletedNMCSetup(newAcctNMCAcctMap);
  }
}