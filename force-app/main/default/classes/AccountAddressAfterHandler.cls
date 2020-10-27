public with sharing class AccountAddressAfterHandler {
    
    public static void updateQuoteAddresses(List<Address__c> newList, Map<id,Address__c> oldMap)        
    { 
    	Set<Id> addrSet = new Set<Id>();
    	List<Address__c> updateAddrList = new List<Address__c>();
    	Map<Id, SBQQ__Quote__c> updateQuoteMap = new Map<Id, SBQQ__Quote__c>();
    	
    	for(Address__c addr: newList)
        {
        	Address__c oldAddr = oldMap.get(addr.Id);
	    	if(addr.Address_Line_1__c != oldAddr.Address_Line_1__c || addr.Address_Line_2__c != oldAddr.Address_Line_2__c || addr.Location_Type__c != oldAddr.Location_Type__c ||
	    		addr.City__c != oldAddr.City__c || addr.State_Province__c != oldAddr.State_Province__c || addr.Zip_Postal_Code__c != oldAddr.Zip_Postal_Code__c || addr.Country__c != oldAddr.Country__c){
	    		addrSet.add(addr.Id);
	    	}
        }
        
        if(addrSet.size() > 0){
        	try
        	{
	        	for(Address__c uaddr : [select Id, Address_Line_1__c, Address_Line_2__c, City__c, State_Province__c, Zip_Postal_Code__c, Country__c, Location_Type__c, 
	        								   (select Id, SBQQ__ShippingStreet__c, SBQQ__ShippingCity__c, SBQQ__ShippingState__c, SBQQ__ShippingPostalCode__c,
	        								   		   SBQQ__ShippingCountry__c, Ship_To_Location_Type__c from ShipToQuotes__r where SBQQ__Status__c != 'Signed'),
	        								   (select Id, SBQQ__BillingStreet__c, SBQQ__BillingCity__c, SBQQ__BillingState__c, SBQQ__BillingPostalCode__c,
	        								   		   SBQQ__BillingCountry__c, Bill_to_Location_Type__c from BillToQuotes__r where SBQQ__Status__c != 'Signed'),
	        								   (select Id, Corporate_Street__c, Corporate_City__c, Corporate_State__c, Corporate_Postal_Code__c,
	        								   		   Corporate_Country__c, Corporate_Location_Type__c from CorporateAddressQuotes__r where SBQQ__Status__c != 'Signed')
	        							  from Address__c where Id in :addrSet]){
	        							  	
	        		if(uaddr.ShipToQuotes__r != null && uaddr.ShipToQuotes__r.size() > 0){
	        			for(SBQQ__Quote__c sQuote : uaddr.ShipToQuotes__r){
	                         sQuote.Ship_To_Location_Type__c = uaddr.Location_Type__c;
	                         sQuote.SBQQ__ShippingStreet__c = uaddr.Address_Line_1__c + ' ' + (uaddr.Address_Line_2__c == null ? '' : uaddr.Address_Line_2__c);
	                         sQuote.SBQQ__ShippingCity__c = uaddr.City__c;
	                         sQuote.SBQQ__ShippingState__c = uaddr.State_Province__c;
	                         sQuote.SBQQ__ShippingPostalCode__c = uaddr.Zip_Postal_Code__c;
	                         sQuote.SBQQ__ShippingCountry__c = uaddr.Country__c;
	                         updateQuoteMap.put(sQuote.Id, sQuote);
	        			}
	        		}
	        		if(uaddr.BillToQuotes__r != null && uaddr.BillToQuotes__r.size() > 0){
	        			for(SBQQ__Quote__c bQuote : uaddr.BillToQuotes__r){
	        				 SBQQ__Quote__c gQuote = updateQuoteMap.get(bQuote.Id);
	        				 bQuote = (gQuote != null)?gQuote:bQuote;
	        				 
	                         bQuote.Bill_to_Location_Type__c = uaddr.Location_Type__c;
	                         bQuote.SBQQ__BillingStreet__c = uaddr.Address_Line_1__c + ' ' + (uaddr.Address_Line_2__c == null ? '' : uaddr.Address_Line_2__c);
	                         bQuote.SBQQ__BillingCity__c = uaddr.City__c;
	                         bQuote.SBQQ__BillingState__c = uaddr.State_Province__c;
	                         bQuote.SBQQ__BillingPostalCode__c = uaddr.Zip_Postal_Code__c;
	                         bQuote.SBQQ__BillingCountry__c = uaddr.Country__c;
	                         updateQuoteMap.put(bQuote.Id, bQuote);
	        			}
	        		}
	        		if(uaddr.CorporateAddressQuotes__r != null && uaddr.CorporateAddressQuotes__r.size() > 0){
	        			for(SBQQ__Quote__c cQuote : uaddr.CorporateAddressQuotes__r){
	        				 SBQQ__Quote__c gQuote = updateQuoteMap.get(cQuote.Id);
	        				 cQuote = (gQuote != null)?gQuote:cQuote;
	        				 
	                         cQuote.Corporate_Location_Type__c = uaddr.Location_Type__c;
	                         cQuote.Corporate_Street__c = uaddr.Address_Line_1__c + ' ' + (uaddr.Address_Line_2__c == null ? '' : uaddr.Address_Line_2__c);
	                         cQuote.Corporate_City__c = uaddr.City__c;
	                         cQuote.Corporate_State__c = uaddr.State_Province__c;
	                         cQuote.Corporate_Postal_Code__c = uaddr.Zip_Postal_Code__c;
	                         cQuote.Corporate_Country__c = uaddr.Country__c;
	                         updateQuoteMap.put(cQuote.Id, cQuote);
	        			}
	        		}
	        	}
	        	
	        	if(updateQuoteMap.size() > 0){
	        		update updateQuoteMap.values();
	        	}
        	}catch(Exception e)
	        {
	            system.debug('***************** Exception occured update Quote addresses::'+e.getmessage());
	        }
        }
    }
}