trigger ContractRequestAll on Contract_Request__c (before insert, before update) 
{
 //Populate Sales Director and AssignedTo from Account's record
        Set<Id> CRIds = new Set<Id>();
        //Map to hold the Contract Request and corresponding Account ID
        map<Id, Contract_Request__c> mapAccountContractReq = new map <Id, Contract_Request__c>();
        
        for(Contract_Request__c ContractRequest : trigger.New)
        {                       
            mapAccountContractReq.put(ContractRequest.Account__c, ContractRequest);            
        }
        
        if(!(mapAccountContractReq.isEmpty()))
        {
            ContractRequestUtils.updateContractRequest(mapAccountContractReq);
        }
}