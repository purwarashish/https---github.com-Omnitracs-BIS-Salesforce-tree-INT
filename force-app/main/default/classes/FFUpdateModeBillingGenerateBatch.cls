global class FFUpdateModeBillingGenerateBatch implements Database.Batchable<pse__Proj__c>, Database.Stateful{
    
    public List<pse__Proj__c> projectList;
	public pse__Region__c pseRegion;
	public pse__Grp__c pseGroup;
	public pse__Practice__c psePractice;
	public pse__Time_Period__c timePeriod;
	public Date billingFromDate;
	public Date billingToDate;
	public List<Id> timecardIdsToBeExcluded;
	global String mailCsvContent;
	
    
    global FFUpdateModeBillingGenerateBatch(List<pse__Proj__c> dataList, Date billFromDate, Date billToDate){
        mailCsvContent = 'Project Name,Status,Remarks\n';
		billingFromDate = billFromDate;
		billingToDate = billToDate;
		projectList = dataList;
    }
    
    // Start Method
    global List<pse__Proj__c> start(Database.BatchableContext BC){
        pseRegion = [Select Id FROM pse__Region__c where Name = 'Corporate'];
		pseGroup = [Select Id FROM pse__Grp__c WHERE name = 'Corporate'];
		psePractice = [Select Id FROM pse__Practice__c WHERE name = 'Corporate'];
		timePeriod = [Select Id, Name from pse__Time_Period__c Where Name = 'Perpetual'];
		return projectList;
    }
  
    // Execute Logic
    global void execute(Database.BatchableContext BC, List<pse__Proj__c> projList){
        Set<Id> projectIds = new Set<Id>();
		for(pse__Proj__c proj : projList){
			projectIds.add(proj.Id);
		}
		timecardIdsToBeExcluded = new List<Id>();
		List<pse__Timecard__c> timecardsToBeExcluded = [SELECT Id, Name, pse__Exclude_from_Billing__c from pse__Timecard__c WHERE pse__Billable__c = true AND pse__Invoiced__c = false AND pse__Billed__c = false AND pse__Exclude_from_Billing__c = false AND pse__Approved__c = true AND pse__Project__c in :projectIds AND ((pse__End_Date__c > :billingToDate OR pse__End_Date__c < :billingFromDate) OR (pse__End_Date__c <= :billingToDate AND pse__End_Date__c >= :billingFromDate AND (pse__Total_Billable_Amount__c = 0 OR (pse__Approved__c = true AND pse__Status__c in ('Saved', 'Submitted')))))];
		for(pse__Timecard__c timecard : timecardsToBeExcluded){
			timecardIdsToBeExcluded.add(timecard.Id);
			timecard.pse__Exclude_from_Billing__c = true;
		}
		update timecardsToBeExcluded;
		// Financial Force APIs executes a batch Job and a batch job cannot be executed from another batch job so the API execution logic is there in finish method
    }
 
    global void finish(Database.BatchableContext BC){
        for(pse__Proj__c proj : projectList){
			String mailContent = '';
			try{
				pse.APIBillingService.BillingContextGenerate bcg = new pse.APIBillingService.BillingContextGenerate();
				bcg.regionID = pseRegion.id;
				bcg.groupID = pseGroup.id;
				bcg.practiceID = psePractice.id;
				bcg.projectID = proj.id;
				bcg.accountID = proj.pse__Account__c;
				bcg.timePeriodID = timePeriod.Id;				  
				pse.APICommonsService.BatchStatus bs = pse.APIBillingService.generate(bcg);
				System.debug('Job Id: ' + bs.jobId);
				mailContent += '"' + proj.Name + '",Billing Generation Success,';
			}catch(Exception e){
				String errMsg = 'Error Occured: ' + e.getMessage();
				mailContent += proj.Name + ',Billing Generation Failed,' + errMsg;
			}finally{
				mailCsvContent += mailContent + '\n';
			}
        }
		// Logic to be Executed at finish
        System.debug('Batch Execution of Billing Generation completed, proceeding with discounts if any and quote calculations.');
		
		String sEmailBody='Please see the attached file for details of the Billing Generation automated processing.';
		Blob csvBlob = Blob.valueOf(mailCsvContent);
		Messaging.EmailFileAttachment csvAttc = new Messaging.EmailFileAttachment();
		csvAttc.setFileName('BillingGeneration_Result.csv');
		csvAttc.setContentType('text/csv');
        csvAttc.setBody(csvBlob);
		//Create Email      
		Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
		OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'omnitracs.sfdc.noreply@omnitracs.com'];
		if(owea.size() > 0){
			email.setOrgWideEmailAddressId(owea.get(0).Id);
		}else{
			email.setSenderDisplayName('Billing Generation Batch Job Status');
		}
		String[] toAddresses = new List<String> {UserInfo.getUserEmail()};
		String[] ccAddresses = new List<String> {'yarafat@omnitracs.com'};

		email.setSubject('Billing Generation Batch Job Status');       

		email.setToAddresses(toAddresses);
		email.setCcAddresses(ccAddresses);        

		email.setFileAttachments(new Messaging.EmailFileAttachment[]{csvAttc});
		email.setPlainTextBody(sEmailBody);

		Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
		System.scheduleBatch(new FFUpdateModeBillingReleaseInvoiceBatch(projectList, timecardIdsToBeExcluded), 'FFUpdateMode Billing Release and Invoice Batch: ' + System.now(), 3, 200);
        //System.scheduleBatch(new FFUpdateModeBillingReleaseBatch(projectList, timecardIdsToBeExcluded), 'FFUpdateMode Billing Release Batch: ' + System.now(), 5, 200);
    }
}