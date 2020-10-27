public class NPSSurveyUtils{
    public static void updateAvgNPSScore(List<Customer_Survey__c> objList, String triggerAction){
        Map<Id, Customer_Survey__c> acctSurveyMap = new Map<Id, Customer_Survey__c>();
        boolean isNPSSurvey = false;
        for(Customer_Survey__c custSurvey : objList) {
            Customer_Survey__c mapSurvey = acctSurveyMap.get(custSurvey.Account__c);
            if(custSurvey.Survey_Type__c == 'NPS')
                isNPSSurvey = true;
            if(mapSurvey == null || custSurvey.Completion_Date_Time__c > mapSurvey.Completion_Date_Time__c)
                acctSurveyMap.put(custSurvey.Account__c, custSurvey);
        }
        List<Customer_Survey__c> custSrvyList = [select Account__c, Completion_Date_Time__c, LastModifiedDate, Response_1_Value__c, Response_9__c from Customer_Survey__c where Survey_Type__c = 'NPS' AND Response_1_Value__c != null AND Account__c in :acctSurveyMap.keySet() Order By Account__c, Completion_Date_Time__c DESC];
        Map<Id, List<Customer_Survey__c>> objMap = new Map<Id, List<Customer_Survey__c>>();
        for(Customer_Survey__c survey : custSrvyList){
            Id acctId = survey.Account__c;
            if(!objMap.containsKey(acctId))
                objMap.put(acctId, new List<Customer_Survey__c>());
            objMap.get(acctId).add(survey);
        }
        List<Account> acctList = [select Id, Avg_NPS_Score__c, QWBS_Market__c from Account where Id in :acctSurveyMap.keySet()];
        for(Account acct : acctList){
            List<Customer_Survey__c> npsSrvyList = objMap.get(acct.Id);
            Decimal total = 0.0;
            Integer count = 0;
            if(npsSrvyList != null && npsSrvyList.size() > 0){
                Datetime latestDate = null != npsSrvyList[0].Completion_Date_Time__c ? npsSrvyList[0].Completion_Date_Time__c : npsSrvyList[0].LastModifiedDate;
                Integer month = latestDate.month();
                Integer year = latestDate.year();
                
                for(Customer_Survey__c survey : npsSrvyList){
                    Datetime surveyDate = null != survey.Completion_Date_Time__c ? survey.Completion_Date_Time__c : survey.LastModifiedDate;
                    if(surveyDate.month() == month && surveyDate.year() == year && survey.Response_1_Value__c != null){
                        total += survey.Response_1_Value__c;
                        ++count;
                    }
                }
            }
            Decimal avg = total;
            if(total > 0)
                avg = (total/count).setScale(1);
            acct.Avg_NPS_Score__c = avg;
        }
        update acctList;
        if(String.isNotBlank(triggerAction) && (triggerAction == 'insert' || triggerAction == 'update') && isNPSSurvey){
            Set<Id> contactIds = new Set<Id>();
            for(Customer_Survey__c custSurvey : objList)
                contactIds.add(custSurvey.Recipient_Contact__c);
            List<Case> cases = [Select Id, ContactId from Case where ContactId in : contactIds AND Origin = 'NPS Survey' AND CreatedDate >= LAST_N_DAYS:90];
            Map<Id, Case> caseMap = new Map<Id, Case>();
            for(Case caseObj : cases){
                caseMap.put(caseObj.ContactId, caseObj);
            }
            List<NPS_Survey_Archive__c> npsArchives = [Select Id, Recipient_Contact__c from NPS_Survey_Archive__c where Recipient_Contact__c in : contactIds AND Completion_Date_Time__c >= LAST_N_DAYS:90];
            Map<Id, NPS_Survey_Archive__c> npsArchiveMap = new Map<Id, NPS_Survey_Archive__c>();
            for(NPS_Survey_Archive__c npsArchive : npsArchives){
                npsArchiveMap.put(npsArchive.Recipient_Contact__c, npsArchive);
            }
            List<NPSConfig__c> configList = [Select Id, Trigger_Words__c, Case_Queue__c, Type__c, Region__c, Notify_CSM_and_Owner__c, Email_Notification_List__c from NPSConfig__c Order By Preference_Order__c ASC];
            List<String> queueNames = new List<String>();
            for(NPSConfig__c config : configList){
                queueNames.add(config.Case_Queue__c);
            }
            Map<String, QueueSobject> queueMap = new Map<String, QueueSobject>();
            List<QueueSobject> queueList = [Select QueueId, Queue.Name from QueueSobject where Queue.Name in :queueNames];
            for(QueueSobject queue : queueList){
                queueMap.put(queue.Queue.Name, queue);
            }
            List<Case> caseList = new List<Case>();
            List<NPS_Survey_Archive__c> npsArchiveList = new List<NPS_Survey_Archive__c>();
            Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Customer Satisfaction').getRecordTypeId();
            Id insideCSR = Id.valueOf('00550000005jQUr'); // Inside CSR User ID
            Map<Id, NPSConfig__c> npsConfigContactMap = new Map<Id, NPSConfig__c>();
            Map<ID, Account> acctMap = new Map<ID, Account>([SELECT Id, Name, OwnerId, Owner.Email, CSR__c, CSR__r.Email, QWBS_Market__c FROM Account where Id in :objMap.keySet()]);
            for(Customer_Survey__c custSurvey : objList) {
                if(custSurvey.Response_1_Value__c <= 8 && (triggerAction == 'insert' || (triggerAction == 'update' && caseMap.get(custSurvey.Recipient_Contact__c) == null))){
                    Account acct = acctMap.get(custSurvey.Account__c);
                    List<String> canadaMarketValues = new list<String> { 'Canada', 'CAN-Ent', 'CAN-New' };
                    String region = (canadaMarketValues.contains(acct.QWBS_Market__c) ? 'Canada' : (acct.QWBS_Market__c == 'LatAm' ? 'Mexico' : (acct.QWBS_Market__c == 'Sylectus' ? 'Sylectus' : 'USA')));
                    String defaultFieldQueue = (region == 'USA' ? 'Customer Sat - Field CSM' : 'Customer Sat - Field CSM_' + region);
                    String defaultInsideQueue = (region == 'USA' ? 'Customer Sat - Inside CSM' : 'Customer Sat - Inside CSM_' + region);
                    String queueName = defaultInsideQueue;
                    Id ownerId = null;
                    //String type = 'Inside CSM';
                    String type = 'CSM';
                    Integer triggerCnt = 0;
                    for(NPSConfig__c config : configList){
                        if(config.Region__c == region && containsAny(custSurvey.Response_9__c, config.Trigger_Words__c)){
                            npsConfigContactMap.put(custSurvey.Recipient_Contact__c, config);
                            if(triggerCnt > 0){
                                queueName = defaultInsideQueue;
                                ownerId = null;
                                //type = 'Inside CSM';
                                type = 'CSM';
                                break;
                            }
                            triggerCnt += 1;
                            QueueSobject queue = queueMap.get(config.Case_Queue__c);
                            if(null != queue){
                                ownerId = queue.QueueId;
                                queueName = queue.Queue.Name;
                            }
                            type = config.Type__c;
                        }
                    }
                    if(null == ownerId){
                        //ownerId = ((null == acct || null == acct.CSR__c) ? insideCSR : (acct.CSR__c == insideCSR ? queueMap.get(queueName).QueueId : acct.CSR__c));
                        boolean isInsideCSR = (null == acct || null == acct.CSR__c);
                        ownerId = (isInsideCSR ? insideCSR : acct.CSR__c);
                        queueName = (isInsideCSR ? defaultInsideQueue : (ownerId == insideCSR ? defaultInsideQueue : defaultFieldQueue));
                        //type = (isInsideCSR ? 'Inside CSM' : (ownerId == insideCSR ? 'Inside CSM' : 'Field CSM'));
                        type = 'CSM';
                        for(NPSConfig__c config : configList){
                            if(config.Case_Queue__c == queueName){
                                npsConfigContactMap.put(custSurvey.Recipient_Contact__c, config);
                                break;
                            }
                        }
                        /*ownerId = (null == acct ? null : acct.CSR__c);
                        if(null == acct || null == acct.CSR__c)
                            ownerId = '00550000005jQUr';*/// Assign to Inside CSR
                    }
                    createCase(ownerId, recordTypeId, custSurvey.Account__c, custSurvey.Recipient_Contact__c, custSurvey.Id, 'NPS: ' + (String.isNotBlank(type) ? type : 'General') + ' - Action Required', custSurvey.Response_9__c, queueName, type, caseList);
                }
                createNPSArchive(custSurvey, npsArchiveList, (triggerAction == 'update' && npsArchiveMap.get(custSurvey.Recipient_Contact__c) != null));
            }
            if(caseList.size() > 0)
                insert caseList;
            if(npsArchiveList.size() > 0)
                insert npsArchiveList;
            EmailTemplate emailTemplate = [select Id, Name from EmailTemplate where DeveloperName = 'NPS_Case_Open'][0];
            List<Messaging.SingleEmailMessage> emailsToSend = new List<Messaging.SingleEmailMessage>();
            Map<Id, List<String>> emailMap = new Map<Id, List<String>>();
            Id groupId = null;
            List<Group> groups = [select Id, Name from Group where DeveloperName = 'NPS_Email_Notification_Group']; // Default NPS Email Notification Group which will get all NPS Case Notifications
            if(groups.size() > 0){
                groupId = groups[0].Id;
            }
            for(Case caseObj : caseList) {
                Account acct = acctMap.get(caseObj.AccountId);
                NPSConfig__c config = npsConfigContactMap.get(caseObj.ContactId);
                Messaging.SingleEmailMessage email = Messaging.renderStoredEmailTemplate(emailTemplate.Id, null, caseObj.Id);
                email.setSaveAsActivity(false);
                email.setSenderDisplayName('NPS: Case Notification');
                List<String> toAddresses = emailMap.get(caseObj.OwnerId);
                if(null == toAddresses){
                    toAddresses = new List<String>();
                    Set<Id> groupIds = new Set<Id>();
                    if(!String.valueOf(caseObj.OwnerId).startsWith('00G') && caseObj.OwnerId != insideCSR)
                        groupIds.add(caseObj.OwnerId);
                    boolean queueHasGroup = false;
                    if(groupId != null && String.valueOf(groupId).startsWith('00G')){
                        for(GroupMember member : [select UserOrGroupId FROM GroupMember WHERE GroupId = :groupId]){
                            groupIds.add(member.UserOrGroupId);
                            if(String.valueOf(member.UserOrGroupId).startsWith('00G'))
                                queueHasGroup = true;
                        }
                    }
                    for(User user : [SELECT Email FROM User WHERE Id IN :groupIds])
                        toAddresses.add(user.Email);
                    if(queueHasGroup)
                        for(User user : [SELECT Email FROM User WHERE Id IN (SELECT UserOrGroupId FROM GroupMember WHERE GroupId IN :groupIds)])
                            toAddresses.add(user.Email);
                    if(String.isNotBlank(config.Email_Notification_List__c)){
                        List<String> emailsList = config.Email_Notification_List__c.split(',');
                        for(String emailAddr: emailsList){
                            toAddresses.add(emailAddr.trim());
                        }
                    }
                    if(config.Notify_CSM_and_Owner__c && String.isNotBlank(acct.Owner.Email) && (acct.OwnerId != insideCSR || caseObj.OwnerId != insideCSR))
                        toAddresses.add(acct.Owner.Email);
                    if(config.Notify_CSM_and_Owner__c && String.isNotBlank(acct.CSR__r.Email) && (acct.CSR__c != insideCSR || caseObj.OwnerId != insideCSR))
                        toAddresses.add(acct.CSR__r.Email);
                    emailMap.put(caseObj.OwnerId, toAddresses);
                }
                email.setToAddresses(toAddresses);
                emailsToSend.add(email);
            }
            if(emailsToSend.size() > 0)
                Messaging.sendEmail(emailsToSend);
        }
    }
    
    public static boolean containsAny(String response, String triggerWords){
        boolean check = false;
        if(String.isNotBlank(response) && String.isNotBlank(triggerWords)){
            List<String> wordsList = triggerWords.split(',');
            for(String word: wordsList){
                word = word.trim(); 
                if(response.containsIgnoreCase(word)){
                    check = true;
                    break;
                }
            }
        }
        return check;
    }
    
    public static void createCase(Id ownerId, Id recordTypeId, Id accountId, Id contactId, Id surveyId, String subject, String descr, String queueName, String type, List<Case> caseList){
        caseList.add(new Case(Description =  descr, Priority = '2-Medium', AccountId = accountId, ContactId = contactId, NPS_Survey__c = surveyId, Status = 'New - Unassigned', Substatus__c = '', Subject = subject, Origin = 'NPS Survey', RecordTypeId = recordTypeId, OwnerId = ownerId, Category__c = 'Internal', Queue__c = queueName, Type = type, Type_Level_2__c = 'Customer Service Support', Not_CSAT_Eligible__c = TRUE));
    }
    
    public static void createNPSArchive(Customer_Survey__c survey, List<NPS_Survey_Archive__c> npsArchiveList, boolean isDuplicate){
        npsArchiveList.add(new NPS_Survey_Archive__c(Customer_Survey__c = survey.Id, Account__c = survey.Account__c, Recipient_Contact__c = survey.Recipient_Contact__c, NPS_Wave__c = survey.NPS_Wave__c, Completion_Date_Time__c = survey.Completion_Date_Time__c, Is_Duplicate_Response__c = isDuplicate, Question_1__c = survey.Question_1__c, Question_9__c = survey.Question_9__c, Response_1__c = survey.Response_1__c, Response_9__c = survey.Response_9__c));
    }
}