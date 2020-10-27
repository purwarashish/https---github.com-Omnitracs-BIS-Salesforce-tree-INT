global class ClearNonNPSAccountsWaveBatch implements Database.Batchable<Contact>, Database.Stateful, Schedulable{
	
	//public String mailCsvContent = 'Contact Id,Contact Name,Account Id,Account Name,Wave Assigned\n';
	public String mailCsvContent = 'Update Result,Error (if any)\n';
	public boolean isAnyErrors = false;
    
    global ClearNonNPSAccountsWaveBatch(){}
    
    // Start Method
    global List<Contact> start(Database.BatchableContext BC){
        List<Contact> contactList = [select Id, Notification_Type__c, NPS_Wave__c from Contact where NPS_Wave__c != '' AND Account.NPS_Not_Required__c = TRUE];
        return contactList;
    }
  
    // Execute Logic
    global void execute(Database.BatchableContext BC, List<Contact> contactList){
        try{
			String regExp = 'NPS;?';
			for(Contact con : contactList){
				con.NPS_Wave__c = '';
				String notifType = con.Notification_Type__c;
				if(String.isNotBlank(notifType))
					con.Notification_Type__c = notifType.replaceAll(regExp, '');
			}
			if(contactList.size() > 0){
				Database.SaveResult[] lsr = Database.update(contactList, false);
				for(Database.SaveResult sr : lsr){
					mailCsvContent += sr.isSuccess() ? '"Successfully cleared NPS Wave for Non NPS Account\'s Contact Id: ' + sr.getId() : '"Failed to clear NPS Wave for Non NPS Account\'s Contact: ' + sr.getErrors()[0].getFields() + '","Error Message: ' + sr.getErrors()[0].getMessage();
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
        System.debug('Batch Execution of Clear Non NPS Accounts Wave Completed');
        String sEmailBody = 'Please see the attached file for details of the Auto Wave Assignment batch processing.';
		sEmailBody += isAnyErrors ? '\n\nThere are some errors while clearing the wave for Non NPS Account\'s Contact, please refer the attachment for more details.' : '';
        Blob csvBlob = Blob.valueOf(mailCsvContent);
        Messaging.EmailFileAttachment csvAttc = new Messaging.EmailFileAttachment();
        csvAttc.setFileName('ClearNonNPSAccountsWave_Result.csv');
        csvAttc.setContentType('text/csv');
        csvAttc.setBody(csvBlob);
        //Create Email      
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'omnitracs.sfdc.noreply@omnitracs.com'];
        if(owea.size() > 0){
            email.setOrgWideEmailAddressId(owea.get(0).Id);
        }else{
            email.setSenderDisplayName('Clear Non NPS Accounts Wave Batch Job Status');
        }
        String[] toAddresses = new List<String> {UserInfo.getUserEmail()};
        String[] ccAddresses = new List<String> {'yarafat@omnitracs.com'};
        email.setSubject('Clear Non NPS Accounts Wave Batch Job Status');       
        email.setToAddresses(toAddresses);
        email.setCcAddresses(ccAddresses);        
        email.setFileAttachments(new Messaging.EmailFileAttachment[]{csvAttc});
        email.setPlainTextBody(sEmailBody);
        Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
    }
}