public class TxnLogUtils{
    public static Map<String, List<String>> processTxnLogs(List<TXN_Log__c> txnLogList, Map<String, String> eventsActionMap){
        Set<String> custIds = new Set<String>();
        Set<String> orclIds = new Set<String>();
		List<String> custAssetIds = new List<String>();
        List<String> quoteLineIds = new List<String>();
		Map<String, List<String>> returnContent = new Map<String, List<String>>();
		String mailCsvContent = '';
        for(TXN_Log__c txnLog : txnLogList){
            custIds.add(txnLog.Account_Cust_ID__c);
            orclIds.add(txnLog.Item_SKU_Product_Id__c);
        }
        List<Customer_Asset__c> custAssetList = [select Id, Name, Account__c, Asset_Account_Cust_ID__c, Asset_Status__c, Contract__c, Oracle_Id__c, Product__c, Quantity__c, Consumed_Quantity__c from Customer_Asset__c where Oracle_Id__c IN :orclIds and Asset_Account_Cust_ID__c IN :custIds];
        Map<String, Customer_Asset__c> custAssetMap = new Map<String, Customer_Asset__c>();
		for(Customer_Asset__c custAsset : custAssetList){
            custAssetMap.put(custAsset.Asset_Account_Cust_ID__c + ':' + custAsset.Oracle_Id__c.toUpperCase(), custAsset);
        }
        List<TXN_Log__c> txnLogUpdates = new List<TXN_Log__c>();
        List<Customer_Asset__c> custAssetUpdates = new List<Customer_Asset__c>();
		System.debug('TxnLogUtils: custIds ' + custIds);
		System.debug('TxnLogUtils: orclIds' + orclIds);
		System.debug('TxnLogUtils: custAssetMap' + custAssetMap);
		System.debug('TxnLogUtils: ' + 1);
        for(TXN_Log__c txnLog : txnLogList){
            System.debug('TxnLogUtils: ' + 2);
			Customer_Asset__c custAsset = custAssetMap.get(txnLog.Account_Cust_ID__c + ':' + txnLog.Item_SKU_Product_Id__c.toUpperCase());
			mailCsvContent += txnLog.Id + ',' + txnLog.Account_Cust_ID__c + ',' + txnLog.Item_SKU_Product_Id__c + ',' + txnLog.Event__c + ',' + txnLog.Quantity__c;
			String remarks = '';
			if(custAsset != null){
				System.debug('TxnLogUtils: ' + 3);
				txnLog.Matching_Customer_Asset__c = custAsset.Id;
				txnLog.Status__c = 'Failed';
				try{
					if(custAsset.Asset_Status__c == 'Active' && custAsset.Contract__c != null){
						mailCsvContent += ',' + custAsset.Id + ', Success,';
						if(eventsActionMap.get(txnLog.Event__c) == 'CALCULATE_ON_EXISTING'){
							Decimal contractedQty = custAsset.Quantity__c == null ? 0.0 : custAsset.Quantity__c;
							Decimal curConsumedQty = custAsset.Consumed_Quantity__c == null ? 0.0 : custAsset.Consumed_Quantity__c;
							List<String> billingAppPlanList = new list<String> { 'BILLING_ES_APPS', 'BILLING_ES_PLANS', 'MANUAL_ES_APPS', 'MANUAL_ES_PLANS' };
							if(txnLog.Event__c == 'ERP_SHIPMENT'){
								Decimal toBeConsumedQty = curConsumedQty + txnLog.Quantity__c;
								custAsset.Consumed_Quantity__c = toBeConsumedQty > contractedQty ? toBeConsumedQty : txnLog.Quantity__c;
								mailCsvContent = (toBeConsumedQty > contractedQty ? createAddOnOppty(custAsset, toBeConsumedQty - contractedQty, txnLog, quoteLineIds, mailCsvContent) : (custAsset.Quantity__c == null || txnLog.Quantity__c >= custAsset.Quantity__c ? createAddOnOppty(custAsset, txnLog.Quantity__c, txnLog, quoteLineIds, mailCsvContent) : mailCsvContent));
							}else if(billingAppPlanList.contains(txnLog.Event__c)){
								Decimal updatedNewQty = txnLog.Quantity__c;
								custAsset.Consumed_Quantity__c = txnLog.Event__c == 'BILLING_ES_APPS' || txnLog.Event__c == 'MANUAL_ES_APPS' || updatedNewQty <= contractedQty ? updatedNewQty : custAsset.Consumed_Quantity__c;
								if(txnLog.Event__c == 'BILLING_ES_APPS' || txnLog.Event__c == 'MANUAL_ES_APPS'){
									if(updatedNewQty > contractedQty){
										mailCsvContent = createAddOnOppty(custAsset, updatedNewQty - contractedQty, txnLog, quoteLineIds, mailCsvContent);
									}
								}else{
									remarks = updatedNewQty > contractedQty ? 'Not able to update consumed quantity as the Event Quantity is greater than the Contracted Quantity' : '';
									mailCsvContent += ' , ' + remarks;
								}
							}
						}
						txnLog.Status__c = 'Success';
						if(!custAssetIds.contains(String.valueOf(custAsset.Id)))
							custAssetUpdates.add(custAsset);
						custAssetIds.add(String.valueOf(custAsset.Id));
						mailCsvContent += '\n';
					}else{
						remarks = custAsset.Asset_Status__c != 'Active' ? 'Customer Asset is not Active Error Processing TXN Log Request' : 'Contract not found in Customer Asset Error Processing TXN Log Request';
						mailCsvContent += ',' + custAsset.Id + ', Failed, , ' + remarks + '\n';
					}
				}catch(Exception e){
					remarks = 'Error Occured: ' + e.getMessage();
					mailCsvContent = mailCsvContent.replace('Success', 'Failed');
					mailCsvContent += ',' + remarks + '\n';
				}
			}else{
				remarks = 'No Matching Customer Asset Found Error Processing TXN Log Request';
				mailCsvContent += ', , Failed, , ' + remarks + '\n';
			}
			txnLog.IsProcessed__c = true;
			txnLog.Remarks__c = remarks;
			txnLogUpdates.add(txnLog);
        }
        if(custAssetUpdates.size() > 0)
            update custAssetUpdates;
        update txnLogUpdates;
		returnContent.put('mailCsvContent', new list<String> { mailCsvContent });
		returnContent.put('quoteLineIds', quoteLineIds);
		return returnContent;
    }
    
    public static String createAddOnOppty(Customer_Asset__c custAsset, Decimal qty, TXN_Log__c txnLog, List<String> quoteLineIds, String mailCsvContent){
        System.debug('TxnLogUtils: ' + 4);
		String contractId = (String)custAsset.Contract__c;
        String quoteJSON = SBQQ.ServiceRouter.load('SBQQ.ContractManipulationAPI.ContractAmender', contractId, null);
        QuoteModel quoteModel = (QuoteModel) JSON.deserialize(quoteJSON, QuoteModel.class);
        QuoteLineModel[] lineItems = quoteModel.lineItems;
		Opportunity oppty = [Select Id, Type, OwnerId, Order_Type__c, Order_Sub_Type__c from Opportunity where Id = :quoteModel.record.SBQQ__Opportunity2__c];
		Account acct = [Select Id, OwnerId from Account where Id = :quoteModel.record.SBQQ__Account__c];
		txnLog.Add_On_Opportunity__c = oppty.Id;
		oppty.Type = 'Existing Customer';
		oppty.Order_Type__c = qty > 0 ? 'Customer Portal' : 'Decommission';
		oppty.Order_Sub_Type__c = qty > 0 ? 'AddOn' : (txnLog.Event__c == 'AUTO_TERMINATION' ? 'Full Cancellation' : 'Reduction');
		oppty.Name = txnLog.Account_Cust_ID__c + ' – ' + oppty.Order_Sub_Type__c + ' – contract #' + quoteModel.record.SBQQ__MasterContract__r.ContractNumber + ' – ' + txnLog.Name;
		oppty.OwnerId = acct.OwnerId;
		update oppty;
        boolean flag = true;
		boolean flagSW = true;
        for(QuoteLineModel quoteLineModel : lineItems){
            SBQQ__QuoteLine__c quoteLine = quoteLineModel.record;
			Id quoteLineProduct = quoteLine.SBQQ__Product__c;
            if(quoteLine.SBQQ__Description__c != 'Wrapper' && custAsset.Product__c == quoteLineProduct && flag){
                quoteLineIds.add(quoteLine.Id + '::' + String.valueOf(qty));
				if(txnLog.Event__c == 'ERP_SHIPMENT'){
					for(QuoteLineModel qlm : lineItems){
						SBQQ__QuoteLine__c ql = qlm.record;
						if(quoteLine.SBQQ__Product__r.Product_Line__c == ql.SBQQ__Product__r.Product_Line__c && quoteLine.SBQQ__Product__r.Product_Group__c == ql.SBQQ__Product__r.Product_Group__c && ql.SBQQ__Product__r.Product_Type__c == 'Software'){
							quoteLineIds.add(ql.Id + '::' + String.valueOf(qty));
							flagSW = false;
							break;
						}
					}
				}
				flag = false;
                break;
            }
        }
		String remarks = (flag ? ' No Product found to update the quantity for required Quote Line.' : '') + (txnLog.Event__c == 'ERP_SHIPMENT' && flagSW ? ' Also Not able to track the corresponding Service Plan for ERP_SHIPMENT to update the quantity.' : '');
		txnLog.Remarks__c = remarks;
		mailCsvContent += oppty.Id + ', ' + remarks;
		return mailCsvContent;
    }
}