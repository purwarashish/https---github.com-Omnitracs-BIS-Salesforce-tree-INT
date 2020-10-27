/*
String snQuery = 'select Id, Account__c from SAA_Contracts__c where Email_Schedule_Send_Date__c = :Date.today() and '+
				  'Fee_Increase_Contact__c != null and Uplift_Effective_Date__c != null and Uplift_Percent__c != null and '+
				  'Email_Actual_Sent_Date__c = null';
Id batchInstanceId = Database.executeBatch(new CreateRenewalNotificationsBatch (snQuery), 5);

*/

global class CreateRenewalNotificationsBatch implements Database.Batchable<sObject>, Database.Stateful {
    
    global String cQuery;
    
    global CreateRenewalNotificationsBatch (String query){
        cQuery = query;
    }
    
    global Database.QueryLocator start(Database.BatchableContext batchableContext){
        Date todayDate = Date.today();
        //Date startofMonth = Date.today().toStartOfMonth();
        System.debug('******CQUERY --- '+cQuery);
        return Database.getQueryLocator(cQuery);
    }

    
    global void execute(Database.BatchableContext batchableContext, List<Renewal_Notifications__c> scope) {
        System.debug('***** EXECUTE ');
        Set<String> accountSet = new Set<String>();
        Set<String> quoteSet = new Set<String>();
        Map<ID, String> quoteBUMap = new Map<ID, String>();
        Map<ID, Renewal_Notifications__c> updateRnMap = new Map<ID, Renewal_Notifications__c>();
        Map<String, Renewal_Notifications__c> emailRNMap = new Map<String, Renewal_Notifications__c>();
        List<Renewal_Notifications__c> insertRNList = new List<Renewal_Notifications__c>();
        OrgWideEmailAddress owa = [select id, DisplayName, Address from OrgWideEmailAddress where DisplayName = 'Omnitracs Support (No-Reply)' limit 1];
        
        for(Renewal_Notifications__c rn: scope) {
            accountSet.add(rn.Account__c);
        }
        
        for(Account accnt : [select Id,  (select Id, Email_Template_ID__c, Fee_Increase_Contact__c, Fee_Increase_Contact__r.email,Uplift_Effective_Date__c,
                                          			   Contract__c, Fee_Increase_Contact__r.Id, Email_Actual_Sent_Date__c, Email_Schedule_Send_Date__c
                                                  from SAA_Contracts__r where Email_Schedule_Send_Date__c = :Date.today() and Uplift_Percent__c != null and 
                                          			   Uplift_Effective_Date__c != null and Email_Actual_Sent_Date__c = null) 
                             from Account where Id in :accountSet]){
        	if(accnt.SAA_Contracts__r != null && accnt.SAA_Contracts__r.size() > 0){
                for(Renewal_Notifications__c rnotif : accnt.SAA_Contracts__r){
                    if(String.isNotBlank(rnotif.Fee_Increase_Contact__c) && String.isNotBlank(rnotif.Email_Template_ID__c) &&
                      	rnotif.Uplift_Effective_Date__c != null && rnotif.Uplift_Effective_Date__c != null &&
                        rnotif.Email_Actual_Sent_Date__c == null){
                        String mapKey = accnt.Id+'-'+rnotif.Email_Template_ID__c;
                        if(!emailRNMap.containsKey(mapKey)){
                            emailRNMap.put(mapKey, rnotif);
                        }
                        else{
                            Renewal_Notifications__c trn = emailRNMap.get(mapKey);
                            if(rnotif.Uplift_Effective_Date__c < trn.Uplift_Effective_Date__c){
                                emailRNMap.put(mapKey,rnotif);
                            }
                        }
                    	
                        rnotif.Email_Actual_Sent_Date__c = DateTime.now();
                        updateRnMap.put(rnotif.ID, rnotif);
                    }
                }
            }
        }
        
        if(emailRNMap.size() > 0){
            List<Messaging.SingleEmailMessage> allmsg = new List<Messaging.SingleEmailMessage>();
            Map<String, List<Renewal_Notifications__c>> contactRNMap = new Map<String, List<Renewal_Notifications__c>>();
            for(Renewal_Notifications__c rnEmail : emailRNMap.values()){
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            	mail.setToaddresses(new List<String> {rnEmail.Fee_Increase_Contact__r.email});
                mail.setTemplateID(rnEmail.Email_Template_ID__c); 
                mail.setSaveAsActivity(true);
                mail.setOrgWideEmailAddressId(owa.id);
                mail.setTargetObjectId(rnEmail.Fee_Increase_Contact__r.Id);
                mail.setWhatId(rnEmail.Id);
                if(!contactRNMap.containsKey(rnEmail.Fee_Increase_Contact__r.Id)){
                    contactRNMap.put(rnEmail.Fee_Increase_Contact__r.Id, new List<Renewal_Notifications__c>());
                }
                contactRNMap.get(rnEmail.Fee_Increase_Contact__r.Id).add(rnEmail);
                allmsg.add(mail);
        	}
        	Messaging.SendEmailResult[] results = Messaging.sendEmail(allmsg,false);
            System.debug('***** EMAIL MESSAGES RESULT -- '+results);
            if(results != null && results.size() > 0){
                Set<String> targetIdsFailed = new Set<String>();
				for(Messaging.SendEmailResult rr : results){
                    if(!rr.isSuccess()){
                        Messaging.SendEmailError[] errArr = rr.getErrors();  
						targetIdsFailed.add(errArr[0].getTargetObjectId());
					}
                }
                
                IF(targetIdsFailed.size() > 0){
                    for(String rnID : targetIdsFailed){
                        List<Renewal_Notifications__c> failedRN = contactRNMap.get(rnID);
                        if(failedRN != null && failedRN.size() > 0){
                            for(Renewal_Notifications__c frn : failedRN){
                                if(updateRnMap.get(frn.ID) != null){
                                    updateRnMap.get(frn.ID).Notification_Failed__c = true;
                                }
                            }
                        }
                    }
                }
            }
        	
        }
        
        if(updateRnMap.size() > 0){
            update updateRnMap.values();
        }
        
    }

    global void finish(Database.BatchableContext batchableContext) {
        
    }
}