trigger PopulateAccountTeam on Case (before insert, before update) {

     /*BypassTriggerUtility u = new BypassTriggerUtility();  
     if (u.isTriggerBypassed()) {
         return;
     }

Case CaseRecord = Trigger.New[0];
ID acctId = CaseRecord.AccountId;
Map<string,string> idNameMap = CaseValidationUtils.getRecordTypesForCases();  

  if ((idNameMap.get(caseRecord.RecordTypeId)==QESConstants.REC_TYPE_CASE_EOX_REQ)){
    try{
    if (acctId != NULL) {
        Account parentAccount = [select Id, CSR__c, Account_Manager__c,Inside_CSR__c FROM Account WHERE Id = :acctId];
        CaseRecord.Customer_Service_Rep__c = parentAccount.CSR__c;
        CaseRecord.Account_Manager__c = parentAccount.Account_Manager__c;
        CaseRecord.Inside_CSR__c=parentAccount.Inside_CSR__c;
        } 
         } catch(exception e)
      {}
        
  }*/

}