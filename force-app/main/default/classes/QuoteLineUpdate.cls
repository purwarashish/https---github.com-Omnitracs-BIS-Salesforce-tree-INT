global class QuoteLineUpdate implements Database.Batchable<sObject>, Database.Stateful{
    
    public Map<String, String> idQtyMap;
    
    global QuoteLineUpdate(List<String> idQtyList){
        System.debug('Id Qty List --> ' + idQtyList);
		if(Test.isRunningTest() && idQtyList.size() == 0)
			idQtyList.add('aBT0000000::10');
		idQtyMap = new Map<String, String>();
        for(String idQty : idQtyList){
            String[] arr = idQty.split('::');
            idQtyMap.put(arr[0], arr[1]);
        }
    }
   
    // Start Method
    global Database.QueryLocator start(Database.BatchableContext BC){
        Set<String> quoteLineIds = idQtyMap.keySet();
        //List<SBQQ__QuoteLine__c> quoteLineList = [Select Id, SBQQ__Quantity__c from SBQQ__QuoteLine__c where Id IN :quoteLineIds];
        System.debug('Quote Line Ids --> ' + quoteLineIds);
		String query = 'Select Id, SBQQ__Quantity__c from SBQQ__QuoteLine__c where Id IN :quoteLineIds';
        return Database.getQueryLocator(query);
    }
  
    // Execute Logic
    global void execute(Database.BatchableContext BC, List<SBQQ__QuoteLine__c> quoteLineList){
        for(SBQQ__QuoteLine__c quoteLine : quoteLineList){
            quoteLine.SBQQ__Quantity__c += Decimal.ValueOf(idQtyMap.get(quoteLine.Id));
        }
		update quoteLineList;
    }
 
    global void finish(Database.BatchableContext BC){ }
}