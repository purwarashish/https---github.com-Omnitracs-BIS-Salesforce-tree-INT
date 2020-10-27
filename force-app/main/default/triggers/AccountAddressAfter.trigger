trigger AccountAddressAfter on Address__c (after update) {
	
	if(Trigger.isUpdate){
		AccountAddressAfterHandler.updateQuoteAddresses(Trigger.new, Trigger.oldMap);
	}
    
}