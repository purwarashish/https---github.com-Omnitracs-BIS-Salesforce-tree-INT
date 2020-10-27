public with sharing class MassAmendContractController {
    public Blob csvFileBody {get;set;}
    public String[] dataLines {get;set;}
	public List<QuoteLineActionModel> modelList {get;set;}
	public List<String> lstFieldNames {get;set;}
    String dataAsString;
    String fieldValue;
    Integer fieldNumber;

    public MassAmendContractController() {
        dataLines = new String[] {};
        modelList = new List <QuoteLineActionModel>();
		lstFieldNames = new List<String>();
    }
    
    public void readFromFile(){
        try{
            dataAsString = csvFileBody.toString();
            readCSVFile();
        }
        catch(exception e){
            ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.Severity.ERROR, 'Error reading CSV file' + e.getMessage());
            ApexPages.addMessage(errorMessage);
        }
    }
	
	public void readCSVFile() {
        modelList.clear();
		System.debug('dataAsString:' + dataAsString);
		dataLines = dataAsString.split('\n');
		System.debug('dataLines:' + dataLines);
		String[] csvFieldNames = dataLines[0].split(',');
		System.debug('csvFieldNames:' + dataLines[0]);
		Map<String, Integer> fieldNumberMap = new Map<String, Integer>();
		for (Integer i = 0; i < csvFieldNames.size(); i++) {
			fieldNumberMap.put(csvFieldNames[i], i);
			lstFieldNames.add(csvFieldNames[i].trim());
		}
		for (Integer i = 1; i < dataLines.size(); i++) {
			QuoteLineActionModel model = new QuoteLineActionModel();
			string[] csvRecordData = dataLines[i].split(',');
			for (String fieldName: csvFieldNames) {
				fieldNumber = fieldNumberMap.get(fieldName);
				fieldValue = csvRecordData[fieldNumber];
				System.debug('******* fieldName -- '+fieldName+ ' -- '+fieldValue);
				if(fieldName == 'ContractNumber'){
					//model.contractNumber = fieldValue;
					model.contractNumber = fieldValue.leftPad(8, '0');
				}
				if(fieldName == 'ProductId'){
					model.productId = fieldValue;
				}
				if(fieldName == 'OracleId'){
					model.oracleId = fieldValue;
				}
				if(fieldName == 'Quantity'){
					model.qty = String.isNotBlank(fieldValue) ? Decimal.ValueOf(fieldValue) : 0;
				}
				if(fieldName == 'QuantityType'){
					model.qtyType = fieldValue;
				}
				if(fieldName == 'IsNew'){
					model.isNew = Boolean.valueOf(fieldValue);
				}
				if(fieldName == 'FinalUnitPrice'){
					model.finalUnitPrice = String.isNotBlank(fieldValue) ? Decimal.ValueOf(fieldValue) : null;
				}
				if(fieldName == 'OptyRecordType'){
					model.optyRecordType = fieldValue;
				}
				if(fieldName == 'OptyOrderType'){
					model.optyOrderType = fieldValue;
				}
				if(fieldName == 'OptyOrderSubType'){
					model.optyOrderSubType = fieldValue;
				}
				if(fieldName == 'PriceBookId'){
					model.priceBookId = fieldValue;
				}
				if(fieldName == 'CurrencyCode'){
					model.currencyCode = fieldValue;
				}
				if(fieldName == 'AdditionalDiscount'){
					model.additionalDisc = String.isNotBlank(fieldValue) ? Decimal.ValueOf(fieldValue) : null;
				}
				if(fieldName == 'DiscountType'){
					model.discType = fieldValue;
				}
			}
			modelList.add(model);
			System.debug('modelList1:' + modelList);			
		}  
    }
	
	public void massAmend() {
		Set<String> contractNumbers = new Set<String>();
		System.debug('modelList2:' + modelList);
		for(QuoteLineActionModel model : modelList){
			contractNumbers.add(model.contractNumber);
		}
		Id recordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('SteelBrick CPQ Contract').getRecordTypeId();
		List<Contract> contracts = [Select Id, ContractNumber, of_Days_Remaining_in_Term__c from Contract where ContractNumber in :contractNumbers and RecordTypeId = :recordTypeId];
		Map<String, Contract> contractMap = new Map<String, Contract>();
		for(Contract contract : contracts){
			contractMap.put(contract.ContractNumber, contract);
		}
		List<QuoteLineActionModelHolder> dataList = new List<QuoteLineActionModelHolder>();
		Map<String, QuoteLineActionModelHolder> modelHolderMap = new Map<String, QuoteLineActionModelHolder>();
		for(QuoteLineActionModel model : modelList){
			QuoteLineActionModelHolder modelHolder = modelHolderMap.get(model.contractNumber);
			if(modelHolder == null){
				List<QuoteLineActionModel> quoteLineModels = new List<QuoteLineActionModel>();
				quoteLineModels.add(model);
				Contract contract = contractMap.get(model.contractNumber);
				if(null != contract){
					Decimal daysRemaining = contract.of_Days_Remaining_in_Term__c;
					Boolean isExpired = daysRemaining == null || daysRemaining <= 0;
					modelHolder = new QuoteLineActionModelHolder(model.contractNumber, String.valueOf(contract.Id), isExpired, quoteLineModels);
				}else{
					modelHolder = new QuoteLineActionModelHolder(model.contractNumber, null, false, quoteLineModels);
				}
				dataList.add(modelHolder);
				modelHolderMap.put(model.contractNumber, modelHolder);
			}else{
				modelHolder.modelList.add(model);
			}
		}
		System.debug('dataList:' + dataList);
		Database.executeBatch(new MassAmendContractBatch(dataList, 'Contracts Mass Amend'), 1);
		modelList.clear();
		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'Mass Amend Contracts batch job has started.'));
	}
}