global class TxnLogBatch implements Database.Batchable<sObject>, Database.Stateful{
    
    public Map<String, String> eventsActionMap;
    global List<String> idQtys;
	global String mailCsvContent;
    
    global TxnLogBatch(){
        mailCsvContent = 'TXN Log, Cust ID, Oracle ID, Event Type, Event Quantity, Matching Customer Asset, Status, Add On Opportunity, Remarks\n';
		eventsActionMap = new Map<String, String>();
        idQtys = new List<String>();
        List<EventsQuantityAction__c> listEventsAction = EventsQuantityAction__c.getall().values();
        for(EventsQuantityAction__c eventAction : listEventsAction){
            eventsActionMap.put(eventAction.name, eventAction.Action__c);
        }
    }
   
    // Start Method
    global Database.QueryLocator start(Database.BatchableContext BC){
        //List<TXN_Log__c> txnLogList = [select Id, Name, Account_Cust_ID__c, Item_SKU_Product_Id__c, Event__c, Sub_Event__c, Quantity__c, IsProcessed__c from TXN_Log__c where IsProcessed__c = false];
        String query = 'select Id, Name, Account_Cust_ID__c, Item_SKU_Product_Id__c, Event__c, Sub_Event__c, Quantity__c, IsProcessed__c from TXN_Log__c where IsProcessed__c = false limit ' + (Test.isRunningTest() ? '4' : '500000');
		return Database.getQueryLocator(query);
    }
  
    // Execute Logic
    global void execute(Database.BatchableContext BC, List<TXN_Log__c> txnLogList){
        Map<String, List<String>> returnContent = TxnLogUtils.processTxnLogs(txnLogList, eventsActionMap);
		mailCsvContent += returnContent.get('mailCsvContent')[0];
		idQtys.addAll(returnContent.get('quoteLineIds'));
    }
 
    global void finish(Database.BatchableContext BC){
        // Logic to be Executed at finish
        System.debug('Batch Execution of Transaction Logs completed, proceeding with Quote Line Quantity update.');
		System.debug('mailCsvContent\n' + mailCsvContent);
		
		String sEmailBody='Please see the attached file for details of the Transaction Log records processing.';
		Blob csvBlob = Blob.valueOf(mailCsvContent);
		Messaging.EmailFileAttachment csvAttc = new Messaging.EmailFileAttachment();
		csvAttc.setFileName('Batch_Update_Result.csv');
		csvAttc.setContentType('text/csv');
        csvAttc.setBody(csvBlob);
		//Create Email      
		Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
		OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'omnitracs.sfdc.noreply@omnitracs.com'];
		if(owea.size() > 0){
			email.setOrgWideEmailAddressId(owea.get(0).Id);
		}else{
			email.setSenderDisplayName('Transaction Log Batch Job Status');
		}
		//String[] toAddresses = new list<String> {'weisheit@omnitracs.com','ichopin@omnitracs.com','usyed@omnitracs.com','alott@omnitracs.com','enovy@omnitracs.com'};
		String[] toAddresses = new list<String> {'sales.ops@omnitracs.com'};
		String[] ccAddresses = new list<String> {'weisheit@omnitracs.com','yarafat@omnitracs.com'};

		email.setSubject('Transaction Log Batch Job Status');       

		email.setToAddresses(toAddresses);
		email.setCcAddresses(ccAddresses);        

		email.setFileAttachments(new Messaging.EmailFileAttachment[]{csvAttc});
		email.setPlainTextBody(sEmailBody);

		Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
		
        Database.executeBatch(new QuoteLineUpdate(idQtys), 1);
    }
}