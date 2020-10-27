global class AutoWaveAssignmentBatch implements Database.Batchable<Contact>, Database.Stateful, Schedulable{
	
	public Map<Id, String> accountWaveMap = new Map<Id, String>();
	public Map<Integer, Integer> waveCountMap = new Map<Integer, Integer>();
	public List<Integer> waves = new List<Integer> { 1, 2, 3, 4, 5, 6 };
	//public String mailCsvContent = 'Contact Id,Contact Name,Account Id,Account Name,Wave Assigned\n';
	public String mailCsvContent = 'Update Result,Error (if any)\n';
	public boolean isAnyErrors = false;
    
    global AutoWaveAssignmentBatch(){}
    
    // Start Method
    global List<Contact> start(Database.BatchableContext BC){
        Map<Integer, Integer> monthWaveMap = new Map<Integer, Integer>{1 =>3, 2=>4, 3=>5, 4=>6, 5=>1, 6=>2, 7=>3, 8=>4, 9=>5,10=>6, 11=>1, 12=>2};
		Integer curMonth = date.today().month();
		waves.remove(waves.indexOf(monthWaveMap.get(curMonth)));
		waves.remove(waves.indexOf(monthWaveMap.get(curMonth + 1)));
		for(Integer waveNum : waves){
			String wave = '%' + String.valueOf(waveNum) + '%';
			Integer count = [select count() from Contact where NPS_Wave__c like :wave AND Survey_Email_Opt_Out__c = FALSE 
			AND Inactive__c = FALSE AND Account.QWBS_Status__c != 'Closed Contract Customer'];
			waveCountMap.put(waveNum, count);
		}
        List<Contact> contactList = [select Id, Name, NPS_Wave__c, AccountId, Account.BillingCountry, Account.Name, Account.QWBS_Market__c 
									from Contact where NPS_Wave__c = '' AND Notification_Type__c includes ('NPS') AND Account.NPS_Not_Required__c = FALSE AND 
									Survey_Email_Opt_Out__c = FALSE AND Inactive__c = FALSE AND Account.QWBS_Status__c = 'Contract Customer' Order By AccountId];
		Set<Id> acctIds = new Set<Id>();
		for(Contact con: contactList){
			acctIds.add(con.AccountId);
		}
		List<Account> acctList = [select Id, Name, (SELECT Id, NPS_Wave__c FROM Contacts where NPS_Wave__c != '' LIMIT 1) from Account where Id IN :acctIds];
		for(Account acct: acctList){
			if(acct.Contacts.size() > 0)
				accountWaveMap.put(acct.Id, acct.Contacts[0].NPS_Wave__c);
		}
        return contactList;
    }
  
    // Execute Logic
    global void execute(Database.BatchableContext BC, List<Contact> contactList){
        List<String> billingCountryListUS = new List<String> { 'USA', 'US', 'U.S.A', 'U.S', 'UNITED STATES', 'UNITED STATES OF AMERICA' };
		List<String> billingCountryListCN = new List<String> { 'CA', 'CAN', 'CANADA' };
		List<String> billingCountryListMX = new List<String> { 'MX', 'MEX', 'MÉX', 'MEXICO', 'MÉXICO' };
		List<String> canadaMarketValues = new List<String> { 'Canada', 'CAN-Ent', 'CAN-New' };
		try{
			for(Contact con : contactList){
				Integer lowestKey = waveCountMap.isEmpty() ? null : new List<Integer>(waveCountMap.keyset())[0];
				for(Integer key : waveCountMap.keySet()) {
					lowestKey = waveCountMap.get(key) < waveCountMap.get(lowestKey) ? key : lowestKey;
				}
				String billingCountry = String.isNotBlank(con.Account.BillingCountry) ? con.Account.BillingCountry : 'USA';
				String conWave = (con.Account.QWBS_Market__c == 'Sylectus' ? 'SY ' + lowestKey : (billingCountryListCN.contains(billingCountry.toUpperCase()) ? 'OTC ' + lowestKey : (billingCountryListMX.contains(billingCountry.toUpperCase()) ? 'MX ' + lowestKey : String.valueOf(lowestKey))));
				String npsWave = accountWaveMap.get(con.AccountId) != null ? accountWaveMap.get(con.AccountId) : conWave;
				String regex = '([a-zA-Z ]+)';
				Integer npsWaveNum = Integer.valueOf(npsWave.replaceAll(regex, ''));
				if(waveCountMap.get(npsWaveNum) != null)
					waveCountMap.put(npsWaveNum, waveCountMap.get(npsWaveNum) + 1);
				accountWaveMap.put(con.AccountId, npsWave);
				con.NPS_Wave__c = npsWave;
				//mailCsvContent += con.Id + ',"' + con.Name + '",' + con.AccountId + ',"' + con.Account.Name + '",' + npsWave + '\n';
			}
			if(contactList.size() > 0){
				Database.SaveResult[] lsr = Database.update(contactList, false);
				for(Database.SaveResult sr : lsr){
					mailCsvContent += sr.isSuccess() ? '"Successfully Updated Contact Id: ' + sr.getId() : '"Failed to update Contact: ' + sr.getErrors()[0].getFields() + '","Error Message: ' + sr.getErrors()[0].getMessage();
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
        System.debug('Daily Batch Execution of Auto Wave Assignment Completed');
        String sEmailBody = 'Please see the attached file for details of the Auto Wave Assignment batch processing.';
		sEmailBody += isAnyErrors ? '\n\nThere are some errors while updating Contact with a wave, please refer the attachment for more details.' : '';
        Blob csvBlob = Blob.valueOf(mailCsvContent);
        Messaging.EmailFileAttachment csvAttc = new Messaging.EmailFileAttachment();
        csvAttc.setFileName('AutoWaveAssignment_Result.csv');
        csvAttc.setContentType('text/csv');
        csvAttc.setBody(csvBlob);
        //Create Email      
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'omnitracs.sfdc.noreply@omnitracs.com'];
        if(owea.size() > 0){
            email.setOrgWideEmailAddressId(owea.get(0).Id);
        }else{
            email.setSenderDisplayName('Auto Wave Assignment Daily Batch Job Status');
        }
        String[] toAddresses = new List<String> {UserInfo.getUserEmail()};
        String[] ccAddresses = new List<String> {'yarafat@omnitracs.com'};
        email.setSubject('Auto Wave Assignment Daily Batch Job Status');       
        email.setToAddresses(toAddresses);
        email.setCcAddresses(ccAddresses);        
        email.setFileAttachments(new Messaging.EmailFileAttachment[]{csvAttc});
        email.setPlainTextBody(sEmailBody);
        Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
    }
}