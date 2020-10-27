global class NPSNotificationBatch implements Database.Batchable<Object>, Database.Stateful, Schedulable{
    
    global NPSNotificationBatch(){}
    
    // Start Method
    global List<Object> start(Database.BatchableContext BC){
        Map<Integer, Integer> monthWaveMap = new Map<Integer, Integer>{1 =>3, 2=>4, 3=>5, 4=>6, 5=>1, 6=>2, 7=>3, 8=>4, 9=>5,10=>6, 11=>1, 12=>2};
        Integer nextMonth = date.today().month() + 1;
        String wave = '%' + String.valueOf(monthWaveMap.get(nextMonth)) + '%';
        List<NPSNotificationMapHolder> dataList = new List<NPSNotificationMapHolder>();
        Map<String, NPSNotificationMapHolder> listHolderMap = new Map<String, NPSNotificationMapHolder>();
        List<Contact> contactList = [select Id, Name, Email, NPS_Wave__c, AccountId, Account.Name, Account.District__c, 
                                    Account.Owner.Email, Account.Owner.FirstName, Account.CSR__r.Email, Account.QWBS_Market__c from Contact where NPS_Wave__c like :wave AND HasOptedOutOfEmail = FALSE AND Inactive__c = FALSE AND Account.QWBS_Status__c != 'Closed Contract Customer' 
									AND NPS_Survey_Completed__c = FALSE AND Account.QWBS_Market__c IN ('Enterprise', 'Strategic', 'CAN-Ent') Order By Account.OwnerId];
        for(Contact con: contactList){
            String acctOwnerEmail = con.Account.Owner.Email;
            NPSNotificationMapHolder listHolder = listHolderMap.get(acctOwnerEmail);
            if(listHolder == null){
                List<String> acctContactList = new List<String>();
                acctContactList.add('"' + con.Account.Name + '","' + con.Name + '"');
                listHolder = new NPSNotificationMapHolder(acctOwnerEmail, con.Account.Owner.FirstName, con.Account.CSR__r.Email, acctContactList);
                dataList.add(listHolder);
                listHolderMap.put(acctOwnerEmail, listHolder);
            }else{
                listHolder.acctContactList.add('"' + con.Account.Name + '","' + con.Name + '"');
            }
        }
        return dataList;
    }
  
    // Execute Logic
    global void execute(Database.BatchableContext BC, List<Object> npsNotificationMapList){
        Map<Integer, String> monthNameMap = new Map<Integer, String>{1 =>'January', 2=>'February', 3=>'March', 4=>'April', 5=>'May', 6=>'June', 7=>'July', 8=>'August', 9=>'September',10=>'October', 11=>'November', 12=>'December'};
        String nextMonth = monthNameMap.get(date.today().month() + 1);
        List<Messaging.SingleEmailMessage> emailsToSend = new List<Messaging.SingleEmailMessage>();
        OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'omnitracs.sfdc.noreply@omnitracs.com'];
        EmailTemplate emailTemplate = [select Id, Name, Subject, HtmlValue from EmailTemplate where DeveloperName = 'NPS_Batch_Notification_Owner'][0];
        for(Object obj : npsNotificationMapList){
            NPSNotificationMapHolder listHolder = (NPSNotificationMapHolder) obj;
            List<String> acctContactNames = listHolder.acctContactList;
            String subject = emailTemplate.Subject;
            subject = subject.replace('{nextMonth}', nextMonth);
            String htmlBody = emailTemplate.HtmlValue;
            htmlBody = htmlBody.replace('{acctOwnerFirstName}', listHolder.acctOwnerFirstName);
            htmlBody = htmlBody.replace('{nextMonth}', nextMonth);
            String mailCsvContent = 'Account Name,Contact Name';
            for(String text : acctContactNames) {
                mailCsvContent += '\n' + text;
            }
            Blob csvBlob = Blob.valueOf(mailCsvContent);
            Messaging.EmailFileAttachment csvAttc = new Messaging.EmailFileAttachment();
            csvAttc.setFileName('Contacts.csv');
            csvAttc.setContentType('text/csv');
            csvAttc.setBody(csvBlob);
            //Create Email      
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            if(owea.size() > 0){
                email.setOrgWideEmailAddressId(owea.get(0).Id);
            }else{
                email.setSenderDisplayName('Upcoming NPS Survey');
            }
            String[] toAddresses = new List<String> {listHolder.acctOwnerEmail};
			if(String.isNotBlank(listHolder.acctCSMEmail))
				toAddresses.add(listHolder.acctCSMEmail);
            //String[] ccAddresses = new List<String> {'yarafat@omnitracs.com',UserInfo.getUserEmail()};
            email.setSubject(subject);       
            email.setToAddresses(toAddresses);
            //email.setCcAddresses(ccAddresses);
            email.setFileAttachments(new Messaging.EmailFileAttachment[]{csvAttc});
            email.setHtmlBody(htmlBody);
            emailsToSend.add(email);
        }
        if(emailsToSend.size() > 0)
            Messaging.sendEmail(emailsToSend);
    }

    global void execute(SchedulableContext sc) {
        Database.executeBatch(this);
    }
 
    global void finish(Database.BatchableContext BC){
        // Logic to be Executed at finish
        System.debug('Batch Execution of NPS Notification Completed');
    }
}