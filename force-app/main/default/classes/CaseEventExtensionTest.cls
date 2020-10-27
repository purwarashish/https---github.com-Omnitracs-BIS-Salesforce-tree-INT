@istest
public class CaseEventExtensionTest {
    @istest(seeAllData=true)
    static void testCaseEventPage () {
        
        Account a = TestUtils.getAccount('ut1 Acc');
        insert a;
        list<Recordtype> rclist = new list<Recordtype> ();
        rclist = [select Id,name from recordtype where SobjectType = 'Case' and name='Admin'];
        user currentuser = [SELECT Id, Name,ContactId,lastname,firstname FROM User WHERE Id = :UserInfo.getUserId()];
        Contact Con = new Contact();
        con.firstName = 'TEST';
        con.lastname = 'contact';
        con.account = a;
        con.accountID = a.id;
        con.Extension__c = '9874563210';
        insert con;
        
        Case cs = new Case ();
        cs.contact = con;
        cs.contactid = con.id;
        cs.Email_Alert_Support__c = currentuser.lastname + ','+ currentuser.firstname;
        cs.recordtypeid = rclist[0].id;
        cs.Subject = 'test subject';
        cs.Status ='Open';
        cs.Category__c= 'CER';
        cs.Email__c = 'test@abc.com';
        insert cs;
        
        Case_Event__c ce = new Case_Event__c ();
        ce.Case__c = cs.id;
        ce.start_time__c = System.now();
        ce.End_Time__c = System.now().addseconds(180);
        ce.Time_Spent__c = 6;
        ce.subject__c ='test';
        ce.Assisting_Technician__c = userinfo.getuserid();
        Test.startTest();
        insert ce;
        list<Case_Event__c> caseEventlist = new list<Case_Event__c> ();
        caseEventlist.add(ce);
        ApexPages.StandardController sc = new ApexPages.StandardController(ce);
        
        
        PageReference pageRef = Page.CaseEventPage;
        pageRef.getParameters().put('id', String.valueOf(ce.Id));
        Test.setCurrentPage(pageRef);
        CaseEventExtension CaseEventExtensionObj = new CaseEventExtension(sc);
        string BuValue = CaseEventExtensionObj.Buvalue;
        Boolean IsCal1 = CaseEventExtensionObj.IsCal1;
        boolean showaccountfield = CaseEventExtensionObj.showaccountfield;
        boolean isCaseRecordTypeSupport = CaseEventExtensionObj.isCaseRecordTypeSupport;
        string contactExtension = CaseEventExtensionObj.contactExtension;
        boolean showWorkEffortField = CaseEventExtensionObj.showWorkEffortField;
        string cmibosCaseFieldId = CaseEventExtensionObj.mibosCaseFieldId;
        boolean isCaseReasonRequired = CaseEventExtensionObj.isCaseReasonRequired;
        boolean isSubReasonRequired = CaseEventExtensionObj.isSubReasonRequired;
        boolean isoldcasereason = CaseEventExtensionObj.isoldcasereason;
        string userchoicestatusfield = CaseEventExtensionObj.userchoicestatusfield;
       // integer caseeventminutes = CaseEventExtensionObj.caseeventminutes;
        String isVisibleInSelfServiceFieldLabel = CaseEventExtensionObj.isVisibleInSelfServiceFieldLabel;
        string userChoiceContactField = CaseEventExtensionObj.userChoiceContactField;
        String ContactName = CaseEventExtensionObj.ContactName;
        List<string> usersToAdd = CaseEventExtensionObj.usersToAdd;
        List<string> usersToRemove = CaseEventExtensionObj.usersToRemove;
        List<SelectOption> contactsOfCase = CaseEventExtensionObj.contactsOfCase;
        ID contactId = CaseEventExtensionObj.contactId;
        CaseEventExtensionObj.contactPicklistOnChange();
        CaseEventExtensionObj.Save();
        CaseEventExtensionObj.saveAndNew();
        CaseEventExtensionObj.saveAndClose();
        CaseEventExtensionObj.Cancel();
        CaseEventExtensionObj.UpdatecaseEvent();
        CaseEventExtension.createCaseTimesForCaseEvent(ce, CS);
        CaseEventExtension.getContactsOfAccount(a.id,1);
        CaseEventExtensionObj.getthecase();
        contactsOfCase.add(new selectOption('test','test'));
        contactsOfCase.add(new selectOption('a12test','a12test'));
        CaseEventExtension.convertSelectOptionsToString(contactsOfCase);
        Integer caseEventMinutes = CaseEventExtensionobj.caseEventMinutes;
        Test.stoptest();
        
    }

    @istest(seeAllData=true)
    static void init () {
        
        Account a = TestUtils.getAccount('ut1 Acc');
        insert a;
        list<Recordtype> rclist = new list<Recordtype> ();
        rclist = [select Id,name from recordtype where SobjectType = 'Case' and name='Admin'];
        user currentuser = [SELECT Id, Name,ContactId,lastname,firstname FROM User WHERE Id = :UserInfo.getUserId()];
        Contact Con = new Contact();
        con.firstName = 'TEST';
        con.lastname = 'contact';
        con.account = a;
        con.accountID = a.id;
        con.Extension__c = '9874563210';
        insert con;
        
        Case cs = new Case ();
        cs.contact = con;
        cs.contactid = con.id;
        cs.Email_Alert_Support__c = currentuser.lastname + ','+ currentuser.firstname;
        cs.recordtypeid = rclist[0].id;
        cs.Subject = 'test subject';
        cs.Status ='Open';
        cs.Category__c= 'CER';
        cs.Email__c = 'test@abc.com';
        insert cs;
        
        Case_Event__c ce = new Case_Event__c ();
        ce.Case__c = cs.id;
        ce.start_time__c = System.now();
        ce.End_Time__c = System.now().addseconds(180);
        ce.Time_Spent__c = 6;
        ce.subject__c ='test';
        ce.Assisting_Technician__c = userinfo.getuserid();
        Test.startTest();
        insert ce;
        list<Case_Event__c> caseEventlist = new list<Case_Event__c> ();
        caseEventlist.add(ce);
        ApexPages.StandardController sc = new ApexPages.StandardController(ce);
        
        
        PageReference pageRef = Page.CaseEventPage;
        pageRef.getParameters().put('id', String.valueOf(ce.Id));
        Test.setCurrentPage(pageRef);
        CaseEventExtension CaseEventExtensionObj = new CaseEventExtension(sc);
        List<SelectOption> contactsOfCase = CaseEventExtensionObj.contactsOfCase;
            contactsOfCase.add(new selectOption('test','test'));
        contactsOfCase.add(new selectOption('a12test','a12test'));
        
        CaseEventExtension.convertSelectOptionsToString(contactsOfCase);
        set<id> currentUserIDSet = new set<id> ();
        currentUserIDSet.add(UserInfo.getUserId());
        CaseEventExtension.sendEmailAlertToInternalUsers(currentUserIDSet,ce,cs,'test');
        list<user> userlist = new list<user> ();
        userlist.add(currentuser);
        CaseEventExtension.isCaseContactPortaluser(con.id,userlist);
        CaseEventExtension.truncateString('abcdefghijklm',4);
        CaseEventExtension.parseStringList(null);
        CaseEventExtension.parseStringList('abc;def;hi');
        CaseEventExtension.parseUsersFromTextField('Test');
        CaseEventExtension.roundNearest5Minutes(0);
        CaseEventExtension.roundNearest5Minutes(21);
       // CaseEventExtension.sendEmailAlertNotfyingFieldsHaveChanged(true,cs,cs);
        CaseEventExtension.emailAlertSuppportCaseEventCreation(caseEventlist);
        list<Case> cslist = new list<case> ();
        cslist.add(cs);
        CaseEventExtension.emailAlertSuppportCaseCreation(cslist,'Case Created');
        CaseEventExtension.emailAlertSuppportCaseCreation(cslist,'Case Closure');
        CaseEventExtension.checkEmailSubjectForForbiddenText('test');
        CaseEventExtension.defineContactList(a.id,con.id,true);
        CaseEventExtension.idSetToList(null);
        CaseEventExtension.idSetToList(currentUserIDSet);
        CaseEventExtension.isOwnerQueue(userinfo.getUserId());
        List<QueueSobject> queues= [select Id,QueueId from QueueSobject];
        CaseEventExtension.isOwnerQueue(userinfo.getUserId(),queues);
        CaseEventExtension.sendEmailAlertToCaseOwner('test@gmail.com',null,null,null,null,null);
        CaseEventExtension.isActivePortalUser();
        CaseEventExtension.ListContains(new selectoption('abc','abc'),contactsOfCase);
        CaseEventExtension.ListContains(new selectoption('test','test'),contactsOfCase);
        CaseEventExtension.Round5Minutes(0);
        CaseEventExtension.Round5Minutes(41);
        CaseEventExtension.removeSelectOption('test',contactsOfCase);
        CaseEventExtension.removeSelectOption('test567',contactsOfCase);
        CaseEventExtension.sortByLabel(contactsOfCase);
        CaseEventExtension.queryIntlTechReps();
     //   CaseEventExtension.timeBetweenInMinutesWorkWeek(system.today(),system.today().addDays(5));
       // CaseEventExtension.timeBetweenInMinutes(system.today(),system.today().addDays(5));
        CaseEventExtension.createTestCase('Admin');
        CaseEventExtension.querycaseEvent(null);
        CaseEventExtension.generateController(ce,cs.id,cs.id);
        CaseEventExtension.sendEmailAlertCaseEventCreation(ce);
        CaseEventExtension.sendExternalEmailAlertsForPortalCases(ce,cs);
        CaseEventExtension.nullToWhiteSpace(null);
        CaseEventExtension.nullToWhiteSpace('test');
        Boolean isRoadnetUser = CaseEventExtensionobj.isRoadnetUser;
        CaseEventExtensionobj.donothing();
        CaseEventExtensionobj.returnURL ='test';
        CaseEventExtensionobj.cancel();
        CaseEventExtension.redirectUserToApprioriateSaveAndClosePage(cs);
        String contactEmail = CaseEventExtensionobj.contactEmail;
        String contactPhone = CaseEventExtensionobj.contactPhone;
       list<selectoption> assistingTechs = CaseEventExtensionobj.assistingTechs;
        //Integer caseEventMinutes = CaseEventExtensionobj.caseEventMinutes;
        CaseEventExtensionobj.getcaseEvent();
        CaseEventExtensionobj.setcaseEvent(ce);
        CaseEventExtensionobj.getIsVfPageInEditMode();
        CaseEventExtension.sendEmailAlertNotfyingFieldsHaveChanged(false,cs,cs);
        CaseEventExtension.sendEmailAlertNotfyingFieldsHaveChanged(true,cs,cs);
        Test.stoptest();
        
    }
    @istest(seeAllData=true)
    static void testCaseEventPageNewData () {
        
        Account a = TestUtils.getAccount('ut1 Acc');
        insert a;
        
        Contact Con = new Contact();
        con.firstName = 'TEST';
        con.lastname = 'contact';
        con.account = a;
        con.Extension__c = '9874';
        insert con;
        
        Case cs = new Case ();
        cs.contact = con;
        insert cs;
        
        
        
        Test.startTest();
        Case_Event__c ce = new Case_Event__c ();
        ce.Case__c = cs.id;
        //insert ce;
        ApexPages.StandardController sc = new ApexPages.StandardController(ce);
        
        string MIBOS_CASE_FIELD_ID = 'CF' + SystemIds__c.getInstance().FieldId_CaseEvent_Case__c + '_lkid';
        PageReference pageRef = Page.CaseEventPage;
        pageRef.getParameters().put(MIBOS_CASE_FIELD_ID, String.valueOf(cs.Id));
        Test.setCurrentPage(pageRef);
        CaseEventExtension CaseEventExtensionObj = new CaseEventExtension(sc);
        boolean showaccountfield = CaseEventExtensionObj.showaccountfield;
        boolean isCaseRecordTypeSupport = CaseEventExtensionObj.isCaseRecordTypeSupport;
        string contactExtension = CaseEventExtensionObj.contactExtension;
        boolean showWorkEffortField = CaseEventExtensionObj.showWorkEffortField;
        string cmibosCaseFieldId = CaseEventExtensionObj.mibosCaseFieldId;
        boolean isCaseReasonRequired = CaseEventExtensionObj.isCaseReasonRequired;
        boolean isSubReasonRequired = CaseEventExtensionObj.isSubReasonRequired;
        boolean isoldcasereason = CaseEventExtensionObj.isoldcasereason;
        string userchoicestatusfield = CaseEventExtensionObj.userchoicestatusfield;
       // integer caseeventminutes = CaseEventExtensionObj.caseeventminutes;
        String isVisibleInSelfServiceFieldLabel = CaseEventExtensionObj.isVisibleInSelfServiceFieldLabel;
        string userChoiceContactField = CaseEventExtensionObj.userChoiceContactField;
        String ContactName = CaseEventExtensionObj.ContactName;
        List<string> usersToAdd = CaseEventExtensionObj.usersToAdd;
        List<string> usersToRemove = CaseEventExtensionObj.usersToRemove;
        List<SelectOption> contactsOfCase = CaseEventExtensionObj.contactsOfCase;
        ID contactId = CaseEventExtensionObj.contactId;
        CaseEventExtensionObj.contactPicklistOnChange();
        CaseEventExtensionObj.Save();
        CaseEventExtensionObj.saveAndNew();
        CaseEventExtensionObj.saveAndClose();
        CaseEventExtensionObj.Cancel();
        CaseEventExtensionObj.insertcaseEvent();
        
        Test.stoptest();
    }
    
    @istest(seeAllData=true)
    static void saveandNew () {
        
        Account a = TestUtils.getAccount('ut1 Acc');
        insert a;
        list<Recordtype> rclist = new list<Recordtype> ();
        rclist = [select Id,name from recordtype where SobjectType = 'Case' and name='Admin'];
        user currentuser = [SELECT Id, Name,ContactId,lastname,firstname FROM User WHERE Id = :UserInfo.getUserId()];
        Contact Con = new Contact();
        con.firstName = 'TEST';
        con.lastname = 'contact';
        con.account = a;
        con.accountID = a.id;
     // con.Extension1__c = '9874563210';
        insert con;
        
        Case cs = new Case ();
        cs.contact = con;
        cs.contactid = con.id;
        cs.Email_Alert_Support__c = currentuser.lastname + ','+ currentuser.firstname;
        //cs.recordtypeid = rclist[0].id;
        cs.Subject = 'test subject';
        cs.Status ='New - Unassigned';
        cs.Category__c= 'CER';
        insert cs;
        cs.Status = 'In progress';
        update cs;
        Case_Event__c ce = new Case_Event__c ();
        ce.Case__c = cs.id;
        ce.start_time__c = System.now();
        ce.End_Time__c = System.now().addseconds(180);
        ce.Time_Spent__c = 6;
        ce.subject__c ='test';
        
        Test.startTest();
        insert ce;
        list<Case_Event__c> caseEventlist = new list<Case_Event__c> ();
        caseEventlist.add(ce);
        ApexPages.StandardController sc = new ApexPages.StandardController(ce);
        
        
        PageReference pageRef = Page.CaseEventPage;
        pageRef.getParameters().put('id', String.valueOf(ce.Id));
        Test.setCurrentPage(pageRef);
        CaseEventExtension CaseEventExtensionObj = new CaseEventExtension(sc);
        Boolean isCaseRecordTypeSupport = CaseEventExtensionobj.isCaseRecordTypeSupport;
        CaseEventExtensionObj.saveAndNew();
        CaseEventExtensionObj.saveAndClose();
        CaseEventExtension.sendEmailAlertCaseEventCreation(ce);
        Test.stopTest();
    }
    
        @istest(seeAllData=true)
    static void saveandclose () {
        
        Account a = TestUtils.getAccount('ut1 Acc');
        insert a;
        list<Recordtype> rclist = new list<Recordtype> ();
        rclist = [select Id,name from recordtype where SobjectType = 'Case' and name='Admin'];
        user currentuser = [SELECT Id, Name,ContactId,lastname,firstname FROM User WHERE Id = :UserInfo.getUserId()];
        Contact Con = new Contact();
        con.firstName = 'TEST';
        con.lastname = 'contact';
        con.account = a;
        con.accountID = a.id;
        con.Extension__c = '9874563210';
        insert con;
        
        Case cs = new Case ();
        cs.contact = con;
        cs.contactid = con.id;
        cs.Email_Alert_Support__c = currentuser.lastname + ','+ currentuser.firstname;
        cs.recordtypeid = rclist[0].id;
        cs.Subject = 'test subject';
        cs.Status ='Open';
        cs.Category__c= 'CER';
        insert cs;
        
        Case_Event__c ce = new Case_Event__c ();
        ce.Case__c = cs.id;
        ce.start_time__c = System.now();
        ce.End_Time__c = System.now().addseconds(180);
        ce.Time_Spent__c = 6;
        ce.subject__c ='test';
        
        Test.startTest();
        insert ce;
        ce.Time_Spent__c = -6;
        update ce;
           
           
        list<Case_Event__c> caseEventlist = new list<Case_Event__c> ();
        caseEventlist.add(ce);
        ApexPages.StandardController sc = new ApexPages.StandardController(ce);
        
        
        string MIBOS_CASE_FIELD_ID = 'CF' + SystemIds__c.getInstance().FieldId_CaseEvent_Case__c + '_lkid';
        PageReference pageRef = Page.CaseEventPage;
        pageRef.getParameters().put(MIBOS_CASE_FIELD_ID, String.valueOf(cs.Id));
        Test.setCurrentPage(pageRef);
        CaseEventExtension CaseEventExtensionObj = new CaseEventExtension(sc);
        boolean showaccountfield = CaseEventExtensionObj.showaccountfield;
        boolean isCaseRecordTypeSupport = CaseEventExtensionObj.isCaseRecordTypeSupport;
        string contactExtension = CaseEventExtensionObj.contactExtension;
        boolean showWorkEffortField = CaseEventExtensionObj.showWorkEffortField;
        string cmibosCaseFieldId = CaseEventExtensionObj.mibosCaseFieldId;
        boolean isCaseReasonRequired = CaseEventExtensionObj.isCaseReasonRequired;
        boolean isSubReasonRequired = CaseEventExtensionObj.isSubReasonRequired;
        boolean isoldcasereason = CaseEventExtensionObj.isoldcasereason;
        string userchoicestatusfield = CaseEventExtensionObj.userchoicestatusfield;
       // integer caseeventminutes = CaseEventExtensionObj.caseeventminutes;
        String isVisibleInSelfServiceFieldLabel = CaseEventExtensionObj.isVisibleInSelfServiceFieldLabel;
        string userChoiceContactField = CaseEventExtensionObj.userChoiceContactField;
        String ContactName = CaseEventExtensionObj.ContactName;
        List<string> usersToAdd = CaseEventExtensionObj.usersToAdd;
        List<string> usersToRemove = CaseEventExtensionObj.usersToRemove;
        List<SelectOption> contactsOfCase = CaseEventExtensionObj.contactsOfCase;
        ID contactId = CaseEventExtensionObj.contactId;
        CaseEventExtensionObj.contactPicklistOnChange();
        CaseEventExtensionObj.Save();
        CaseEventExtensionObj.saveAndNew();
        CaseEventExtensionObj.saveAndClose();
        Test.stopTest();
        
    }
    @istest(seeAllData=true)
    static void sendEmailAlertCaseEventCreation () {
        
        Account a = TestUtils.getAccount('ut1 Acc');
        insert a;
        list<Recordtype> rclist = new list<Recordtype> ();
        rclist = [select Id,name from recordtype where SobjectType = 'Case' and name='Admin'];
        user currentuser = [SELECT Id, Name,ContactId,lastname,firstname FROM User WHERE Id = :UserInfo.getUserId()];
        Contact Con = new Contact();
        con.firstName = 'TEST';
        con.lastname = 'contact';
        con.account = a;
        con.accountID = a.id;
     // con.Extension1__c = '9874563210';
        insert con;
        
        Case cs = new Case ();
      //  cs.contact = con;
      //  cs.contactid = con.id;
        cs.Email_Alert_Support__c = currentuser.lastname + ','+ currentuser.firstname;
        //cs.recordtypeid = rclist[0].id;
        cs.Subject = 'test subject';
        cs.Status ='New - Unassigned';
        cs.Category__c= 'CER';
        insert cs;
        cs.Status = 'In progress';
        update cs;
        Case_Event__c ce = new Case_Event__c ();
        ce.Case__c = cs.id;
        ce.start_time__c = System.now();
        ce.End_Time__c = System.now().addseconds(180);
        ce.Time_Spent__c = -0.5;
        ce.subject__c ='test';
        
        Test.startTest();
        insert ce;
        list<Case_Event__c> caseEventlist = new list<Case_Event__c> ();
        caseEventlist.add(ce);
        ApexPages.StandardController sc = new ApexPages.StandardController(ce);
        
        
        PageReference pageRef = Page.CaseEventPage;
        pageRef.getParameters().put('id', String.valueOf(ce.Id));
        Test.setCurrentPage(pageRef);
        CaseEventExtension CaseEventExtensionObj = new CaseEventExtension(sc);
        CaseEventExtension.sendEmailAlertCaseEventCreation(ce);
        CaseEventExtensionObj.assignPicklistValues();
        
        set<string> dataset = new set<string> ();
        dataset.add('test');
        CaseEventExtension.queryActiveUserIds(dataset);
        Test.stopTest();
    }
}