/***
Case #02275674 -- Created - Sripathi Gullapalli
***/
public with sharing class ProvisionAfterTriggerHandler {
    
 	//Method to update Cap % on Contract, when Provision "Price Increase Cap" field is changed
    public static void updateContract(Map<Id,Provision__c> newMap, Map<Id,Provision__c> oldMap){
		Boolean isInsert = (oldMap == null || oldMap.size() == 0)?true:false;
		Map<Id, Contract> updateContractMap = new Map<Id, Contract>();
		try{
	    	for (Provision__c newProv : newMap.values()){
	    		Provision__c oldProv = isInsert ? null : oldMap.get(newProv.Id);
			 	if(newProv.Contract__c != null && String.isNotBlank(newProv.Price_Increase_Cap__c) && (isInsert || (oldProv != null && newProv.Price_Increase_Cap__c != oldProv.Price_Increase_Cap__c))){
			 		updateContractMap.put(newProv.Contract__c, new Contract(Id=newProv.Contract__c, Cap_Percentage__c = newProv.Price_Increase_Cap__c));
			 	}
		    }
		    
		    if(updateContractMap.size() > 0){
		    	Database.Update(updateContractMap.values());
		    }
		}catch(Exception e){
			System.debug('******************EXCEPTION OCCURED WHILE UPDATING CONTRACT IN PROVISION -- '+e.getMessage());
		}
	}
	
}