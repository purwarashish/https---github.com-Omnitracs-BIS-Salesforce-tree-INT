global class FFUpdateModeBillingReleaseInvoiceBatch implements Database.Batchable<pse__Proj__c>, Database.Stateful{
    
    public List<pse__Proj__c> projectList;
	public List<Id> timecardIdsToBeExcluded;
	global String mailCsvContent;
    
    global FFUpdateModeBillingReleaseInvoiceBatch(List<pse__Proj__c> dataList, List<Id> timecardIds){
        mailCsvContent = 'Project Name,Billing Event,Status\n';
		projectList = dataList;
		timecardIdsToBeExcluded = timecardIds;
    }
    
    // Start Method
    global List<pse__Proj__c> start(Database.BatchableContext BC){
        return projectList;
    }
  
    // Execute Logic
    global void execute(Database.BatchableContext BC, List<pse__Proj__c> projList){
        Set<Id> projectIds = new Set<Id>();
		for(pse__Proj__c proj : projList){
			projectIds.add(proj.Id);
		}
		List<pse__Billing_Event__c> billingEvents = [Select Id, Name, pse__Project__c, pse__Project__r.Name, pse__Is_Released__c from pse__Billing_Event__c where pse__Project__c in : projectIds AND pse__Date__c = Today AND pse__Is_Released__c = FALSE];
		for(pse__Billing_Event__c billingEvent : billingEvents){
			billingEvent.pse__Is_Released__c = true;
		}
		update billingEvents;
		List<pse__Timecard__c> timecardsToBeUpdated = [SELECT Id, Name, pse__Exclude_from_Billing__c from pse__Timecard__c WHERE Id in :timecardIdsToBeExcluded];
		for(pse__Timecard__c timecard : timecardsToBeUpdated){
			timecard.pse__Exclude_from_Billing__c = false;
		}
		update timecardsToBeUpdated;
    }
 
    global void finish(Database.BatchableContext BC){
		try{
			Set<Id> projectIds = new Set<Id>();
			for(pse__Proj__c proj : projectList){
				projectIds.add(proj.Id);
			}
			List<pse__Billing_Event__c> billingEvents = [Select Id, Name, pse__Project__c, pse__Project__r.Name from pse__Billing_Event__c where pse__Project__c in : projectIds AND pse__Date__c = Today AND pse__Is_Released__c = TRUE AND pse__Invoiced__c = FALSE];
			List<pse.BillingEventsManager.InvoiceInfo> invoiceInfos = new List<pse.BillingEventsManager.InvoiceInfo>();
			for(pse__Billing_Event__c billingEvent : billingEvents){
				mailCsvContent += '"' + billingEvent.pse__Project__r.Name + '",' + billingEvent.Name + ',Billing Release and Invoice ' + (projectIds.contains(billingEvent.pse__Project__c) ? 'Success' : 'Failed') + '\n';
				pse.BillingEventsManager.InvoiceInfo invoiceInfo = new pse.BillingEventsManager.InvoiceInfo(billingEvent.Id, '', Date.today());
				invoiceInfos.add(invoiceInfo);
			}
			pse.APIBillingService.BillingContextInvoice bci = new pse.APIBillingService.BillingContextInvoice();
			bci.invoiceInfo = invoiceInfos;
			pse.APICommonsService.BatchStatus bs = pse.APIBillingService.invoice(bci);
			System.debug('Job Id: ' + bs.jobId);
		}catch(Exception e){
			String errMsg = 'Error Occured: ' + e.getMessage();
			mailCsvContent += ',Error Occured: ' + errMsg;
		}
		// Logic to be Executed at finish
        System.debug('Batch Execution of Billing Release and Invoice completed, proceeding with discounts if any and quote calculations.');
		
		String sEmailBody='Please see the attached file for details of the Billing Release and Invoice automated processing.';
		Blob csvBlob = Blob.valueOf(mailCsvContent);
		Messaging.EmailFileAttachment csvAttc = new Messaging.EmailFileAttachment();
		csvAttc.setFileName('BillingReleaseInvoice_Result.csv');
		csvAttc.setContentType('text/csv');
        csvAttc.setBody(csvBlob);
		//Create Email      
		Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
		OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'omnitracs.sfdc.noreply@omnitracs.com'];
		if(owea.size() > 0){
			email.setOrgWideEmailAddressId(owea.get(0).Id);
		}else{
			email.setSenderDisplayName('Billing Release and Invoice Batch Job Status');
		}
		String[] toAddresses = new List<String> {UserInfo.getUserEmail()};
		String[] ccAddresses = new List<String> {'yarafat@omnitracs.com'};

		email.setSubject('Billing Release and Invoice Batch Job Status');       

		email.setToAddresses(toAddresses);
		email.setCcAddresses(ccAddresses);        

		email.setFileAttachments(new Messaging.EmailFileAttachment[]{csvAttc});
		email.setPlainTextBody(sEmailBody);

		Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
	}
}