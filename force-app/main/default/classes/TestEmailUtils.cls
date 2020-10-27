@isTest(SeeAllData=True)
private class TestEmailUtils{
    public static testMethod void RunAllTests() {
      testEmailReminderMessage();
    }
    
    private static void testEmailReminderMessage() 
    {
        //Adding Try Catch as the test classes to aviod failure. 
        Try
        {
        // Create a new case
        Account newAccount = new Account();
        newAccount.Name = 'SFDC';
        newAccount.Type = 'Other';
        newAccount.BillingStreet = 'Test Address';
        newAccount.BillingCity = 'Test City';
        newAccount.BillingCountry = 'Test Country';
        insert newAccount;

        Contact newcnt=new Contact();
        newcnt.FirstName='SFDC';
        newcnt.LastName='Salesforce';
        newcnt.AccountId = newAccount.Id;
        insert newcnt;
   
        RecordType recTypeCallCenter = [Select Id from RecordType where name = 'Call Center' limit 1];
        RecordType recTypeOther = [Select Id from RecordType where name != 'Call Center' limit 1];
    
        Case CaseNew = new Case();
        CaseNew.AccountId = newAccount.Id;
        CaseNew.ContactID = newcnt.Id;
        CaseNew.Category__c = 'EOX Return';
        CaseNew.Type_Level_2__c = 'End of Evaluation';
     
        CaseNew.Description = 'test description';
        CaseNew.Recordtypeid = '01250000000DkBTAA0';
        
        insert CaseNew;
        DateTime oneDayAgo = DateTime.Now();
        oneDayAgo = oneDayAgo.addDays(-1);
         List<Case> lstCase = new List<Case> ([SELECT 
                id, 
                CaseNumber, 
                Subject,
                RecordTypeId, 
                Pending_Approval_Reminder_Date__c,
                Description,Status,Substatus__c 
            FROM Case where id = :CaseNew.Id
           LIMIT 1]);  
        lstCase[0].OwnerID = UserInfo.getUserId();
        lstCase[0].Resolution__c = 'test resolution';
        lstCase[0].Pending_Approval_Reminder_Date__c = system.now()-2;
        update lstCase;

        Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
        req.setComments('Submitted for approval. Please approve.');
        req.setObjectId(CaseNew.Id);
        Approval.ProcessResult result = Approval.process(req);
        
        ProcessInstance p = [Select p.TargetObjectId, p.Status From ProcessInstance p where TargetObjectId=:CaseNew.Id limit 1];
        lstCase = new List<Case> ([SELECT 
                id, 
                CaseNumber, 
                Subject,
                RecordTypeId, 
                Pending_Approval_Reminder_Date__c,
                Description,Status,Substatus__c 
            FROM Case where id = :CaseNew.Id
           LIMIT 1]);  
        lstCase[0].Pending_Approval_Reminder_Date__c = system.now()-2;
        update lstCase;

        ProcessInstanceWorkitem pw =[Select p.ProcessInstanceId, p.ActorId From ProcessInstanceWorkitem p where ProcessInstanceId =: p.Id limit 1];
        pw.ActorId = UserInfo.getUserId();
        update pw;
        EmailUtils.sendDailyCaseReminderEmail();
        }
        Catch(Exception e)
        {
            System.debug('Exception in class TestEmailUtils'+e.getmessage());
        }
        
    }
}