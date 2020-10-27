global class ManageNPSSurveyCompletedBatch implements Database.Batchable<Contact>, Database.Stateful, Schedulable{
    
    public String mailCsvContent = 'Update Result,Error (if any)\n';
    public boolean isAnyErrors = false;
    
    global ManageNPSSurveyCompletedBatch(){}
    
    // Start Method
    global List<Contact> start(Database.BatchableContext BC){
        Map<Integer, Integer> monthWaveMap = new Map<Integer, Integer>{1 =>3, 2=>4, 3=>5, 4=>6, 5=>1, 6=>2, 7=>3, 8=>4, 9=>5,10=>6, 11=>1, 12=>2};
        Integer nextMonth = date.today().month() + 1;
        String wave = '%' + String.valueOf(monthWaveMap.get(nextMonth)) + '%';
        List<Contact> contactList = [select Id, NPS_Survey_Completed__c from Contact where NPS_Wave__c like :wave AND Inactive__c = FALSE AND Account.QWBS_Status__c != 'Closed Contract Customer' AND NPS_Survey_Completed__c = TRUE];
        return contactList;
    }
  
    // Execute Logic
    global void execute(Database.BatchableContext BC, List<Contact> contactList){
        try{
            for(Contact con : contactList){
                con.NPS_Survey_Completed__c = FALSE;
            }
            if(contactList.size() > 0){
                Database.SaveResult[] lsr = Database.update(contactList, false);
                for(Database.SaveResult sr : lsr){
                    mailCsvContent += sr.isSuccess() ? '"Successfully unchecked NPS Survey Completed for Contact Id: ' + sr.getId() : '"Failed to unchecked NPS Survey Completed for Contact: ' + sr.getErrors()[0].getFields() + '","Error Message: ' + sr.getErrors()[0].getMessage();
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
        System.debug('Batch Execution of unchecking NPS Survey Completed checkbox Completed');
        String sEmailBody = 'Please see the attached file for details of the unchecking NPS Survey Completed checkbox batch processing.';
        sEmailBody += isAnyErrors ? '\n\nThere are some errors while unchecking NPS Survey Completed checkbox for contacts, please refer the attachment for more details.' : '';
        Blob csvBlob = Blob.valueOf(mailCsvContent);
        Messaging.EmailFileAttachment csvAttc = new Messaging.EmailFileAttachment();
        csvAttc.setFileName('UncheckNPSSurveyCompleted_Result.csv');
        csvAttc.setContentType('text/csv');
        csvAttc.setBody(csvBlob);
        //Create Email      
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'omnitracs.sfdc.noreply@omnitracs.com'];
        if(owea.size() > 0){
            email.setOrgWideEmailAddressId(owea.get(0).Id);
        }else{
            email.setSenderDisplayName('Uncheck NPSSurvey Completed Batch Job Status');
        }
        String[] toAddresses = new List<String> {UserInfo.getUserEmail()};
        String[] ccAddresses = new List<String> {'yarafat@omnitracs.com'};
        email.setSubject('Uncheck NPSSurvey Completed Batch Job Status');       
        email.setToAddresses(toAddresses);
        email.setCcAddresses(ccAddresses);        
        email.setFileAttachments(new Messaging.EmailFileAttachment[]{csvAttc});
        email.setPlainTextBody(sEmailBody);
        Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
    }
}