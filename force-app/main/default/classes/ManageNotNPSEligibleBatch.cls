global class ManageNotNPSEligibleBatch implements Database.Batchable<Account>, Database.Stateful, Schedulable{
	
	String mailCsvContent = 'Update Result,Error (if any)\n';
	boolean isAnyErrors = false;
	Disable_VR__c custSet = null;
	boolean isUpdateReqd = false;
	boolean isDeleteReqd = false;
    
    global ManageNotNPSEligibleBatch(){}
    
    // Start Method
    global List<Account> start(Database.BatchableContext BC){
        List<Disable_VR__c> custSetList = [select Id, IsActive__c from Disable_VR__c where SetupOwnerId = :UserInfo.getUserId()];
		if(null != custSetList && custSetList.size() > 0)
			custSet = custSetList[0];
		if(custSet == null){
			custSet = new Disable_VR__c(SetupOwnerId = UserInfo.getUserId(), IsActive__c = true);
			isDeleteReqd = true;
		}else if(!custSet.IsActive__c){
			custSet.IsActive__c = true;
			isUpdateReqd = true;
		}
		if(isUpdateReqd || isDeleteReqd)
			upsert custSet;
		List<Account> accountList = [Select Id from Account where RecordTypeId NOT IN ('01250000000DnWqAAK','01250000000DTCQAA4','01250000000QjAKAA0','01250000000DQBAAA4') AND NPS_Not_Required__c = FALSE];
        return accountList;
    }
  
    // Execute Logic
    global void execute(Database.BatchableContext BC, List<Account> accountList){
        try{
			for(Account acct : accountList){
				acct.NPS_Not_Required__c = true;
			}
			if(accountList.size() > 0){
				Database.SaveResult[] lsr = Database.update(accountList, false);
				for(Database.SaveResult sr : lsr){
					mailCsvContent += sr.isSuccess() ? '"Successfully updated Not NPS Eligible checkbox for Account Id: ' + sr.getId() : '"Failed to update Not NPS Eligible checkbox for Account: ' + sr.getErrors()[0].getFields() + '","Error Message: ' + sr.getErrors()[0].getMessage();
					mailCsvContent += '"\n';
					if(!sr.isSuccess())
						isAnyErrors = true;
				}
			}
		}catch(Exception e){
			isAnyErrors = true;
			mailCsvContent += '\n"Error Occured: ' + e.getMessage()  + '"\n\n';
		}
    }

	global void execute(SchedulableContext sc) {
        Database.executeBatch(this, 50);
    }
 
    global void finish(Database.BatchableContext BC){
        // Logic to be Executed at finish
        if(isDeleteReqd){
			delete custSet;
		}else if(isUpdateReqd){
			custSet.IsActive__c = false;
			update custSet;
		}
		System.debug('Batch Execution to update Not NPS Eligible checkbox for Accounts Completed');
        String sEmailBody = 'Please see the attached file for details of the Batch Execution of updating Not NPS Eligible checkbox for Accounts.';
		sEmailBody += isAnyErrors ? '\n\nThere are some errors while updating Not NPS Eligible checkbox for Accounts, please refer the attachment for more details.' : '';
        Blob csvBlob = Blob.valueOf(mailCsvContent);
        Messaging.EmailFileAttachment csvAttc = new Messaging.EmailFileAttachment();
        csvAttc.setFileName('ManageNotNPSEligible_Result.csv');
        csvAttc.setContentType('text/csv');
        csvAttc.setBody(csvBlob);
        //Create Email      
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'omnitracs.sfdc.noreply@omnitracs.com'];
        if(owea.size() > 0){
            email.setOrgWideEmailAddressId(owea.get(0).Id);
        }else{
            email.setSenderDisplayName('Update Not NPS Eligible checkbox for Accounts Batch Job Status');
        }
        String[] toAddresses = new List<String> {UserInfo.getUserEmail()};
        String[] ccAddresses = new List<String> {'yarafat@omnitracs.com'};
        email.setSubject('Update Not NPS Eligible checkbox for Accounts Batch Job Status');       
        email.setToAddresses(toAddresses);
        email.setCcAddresses(ccAddresses);        
        email.setFileAttachments(new Messaging.EmailFileAttachment[]{csvAttc});
        email.setPlainTextBody(sEmailBody);
        Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
    }
}