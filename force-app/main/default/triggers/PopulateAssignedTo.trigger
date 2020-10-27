trigger PopulateAssignedTo on Contract_Request__c (before update, before insert) {

Contract_Request__c ContractRequest = Trigger.New[0];
ID acctId = ContractRequest.Account__c;

    try{
    Account parentAccount = [select Id, Sales_Director__c, Contracts_Administrator__c FROM Account WHERE Id = :acctId];
    ContractRequest.Sales_Director__c = parentAccount.Sales_Director__c;
    if (ContractRequest.Assigned_To__c == NULL) {
        //Account parentAccount = [select Id, Contracts_Administrator__c FROM Account WHERE Id = :acctId];
        ContractRequest.Assigned_To__c = parentAccount.Contracts_Administrator__c;
        }         
        } catch(exception e)
        {}
      }