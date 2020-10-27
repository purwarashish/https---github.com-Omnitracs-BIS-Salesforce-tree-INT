global class QuoteCalculatorBatch implements Database.Batchable<Object>, Database.Stateful{
    
    public List<Object> quoteIdInfolList;
    
    global QuoteCalculatorBatch(List<Object> dataList){
        quoteIdInfolList = dataList;
    }
    
    // Start Method
    global List<Object> start(Database.BatchableContext BC){
        return quoteIdInfolList;
    }
  
    // Execute Logic
    global void execute(Database.BatchableContext BC, List<Object> quoteIdsInfo){
        for(Object obj : quoteIdsInfo){
            String idInfo = (String) obj;
			String[] arr = idInfo.split(':::');
			String quoteId = arr[0];
			System.debug('quoteId: ' + quoteId);
			QuoteReader qr = new QuoteReader();
            QuoteModel quoteModel = qr.read(quoteId);       
            //quoteModel.record.SBQQ__LineItemsGrouped__c = true;
			if(arr.size() > 1 && String.isNotBlank(arr[1])){
				Map<String, String> idPriceMap = new Map<String, String>();
				String[] lines = arr[1].split('@@@');
				for(String line : lines){
					if(String.isNotBlank(line)){
						String[] lineInfoArr = line.split(':');
						idPriceMap.put(lineInfoArr[0], lineInfoArr[1]);
					}
				}
				System.debug('idPriceMap: ' + idPriceMap);
				QuoteLineModel[] lineItems = quoteModel.lineItems;
				for(QuoteLineModel quoteLineModel : lineItems){
					SBQQ__QuoteLine__c quoteLine = quoteLineModel.record;
					if(String.isNotBlank(idPriceMap.get(quoteLine.SBQQ__Product__c)) && quoteLine.Unit_Price__c != null){
						quoteLine.Additional_DiscQLE__c = quoteLine.Unit_Price__c - Decimal.ValueOf(idPriceMap.get(quoteLine.SBQQ__Product__c));
						quoteLine.AdditionalDiscountUnitQLE__c = '$';
					}
				}
				
			}
			QuoteSaver qs = new QuoteSaver();
			qs.save(quoteModel);
			SBQQ__Quote__c quote = [Select Id, SBQQ__LineItemsGrouped__c from SBQQ__Quote__c where Id = :quoteId];
            quote.SBQQ__LineItemsGrouped__c = true;
            update quote;
			/*QuoteCalculator calculator = new QuoteCalculator();
			if(!Test.isRunningTest()){
				calculator.calculate(quoteModel, 'QuoteSaverCallback');
			}*/
        }
    }
 
    global void finish(Database.BatchableContext BC){ }
}