/**
 * Created by Arman_Shah on 10/15/18.
 */

@IsTest
private class AttachmentTriggerHandlerTest {
    public static final String SVR_FILE = 'SVR';
    public static final String SVR_EMAIL_TEMPLATE = 'Project has SVR attachment';
    public static final String SVR_EMAIL_LABEL_PROD = 'PROD';

    @testSetup
    private static void setupTest() {
        pse__Proj__c proj = new pse__Proj__c(Name='Test SVR Project', Actual_start_date__c=Date.today());
        insert proj;

        Contact contactInstance=new Contact(FirstName='Test Contact', LastName='Test Last Name', Email='test@test.com');
        insert contactInstance;
    }

    @IsTest
    static void testSendSvrAttachmentsEmail_NoTemplate() {
        ByPassTrigger__c bypassTrigger = new ByPassTrigger__c(SetupOwnerId=UserInfo.getOrganizationId(), isDisabled__c=true,
                Name='Testing TriggerHandler Bypass');
        insert bypassTrigger;

        pse__Proj__c proj = [SELECT Id FROM pse__Proj__c LIMIT 1];

        Attachment a = new Attachment(Name='Test Attachment 1', parentId = proj.Id,
                Body = EncodingUtil.base64Decode('Test Body'));
        List<Attachment> attachments = new List<Attachment>();
        attachments.add(a);
        insert attachments;

        Test.startTest();
        Messaging.SendEmailResult[] sendEmailResults = AttachmentTriggerHandler.emailAlertForFilesAttachedToProjects(attachments);
        Test.stopTest();

        System.assertEquals(null, sendEmailResults);
    }

    @IsTest
    static void testSendSvrAttachmentsEmail_WithNonSvrTemplate() {
        ByPassTrigger__c bypassTrigger = new ByPassTrigger__c(SetupOwnerId=UserInfo.getOrganizationId(), isDisabled__c=true,
                Name='Testing TriggerHandler Bypass');
        insert bypassTrigger;

        pse__Proj__c proj = [SELECT Id FROM pse__Proj__c LIMIT 1];

        Attachment a = new Attachment(Name='Test Attachment', parentId = proj.Id,
                Body = EncodingUtil.base64Decode('Test Body'));
        List<Attachment> attachments = new List<Attachment>();
        attachments.add(a);
        insert attachments;

        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs (thisUser) {
            EmailTemplate et = new EmailTemplate (developerName = 'test', IsActive = true,
                    TemplateType = 'Text', Name = 'TEST Not SVR Template', FolderId = UserInfo.getUserId()); // plus any other fields that you want to set
            insert et;
        }

        Test.startTest();
        Messaging.SendEmailResult[] sendEmailResults =
                AttachmentTriggerHandler.emailAlertForFilesAttachedToProjects(attachments);
        Test.stopTest();

        System.assertEquals(null, sendEmailResults);
    }

    @IsTest
    static void testSendSvrAttachmentsEmail_WithSvrFileAndTemplate() {
        ByPassTrigger__c bypassTrigger = new ByPassTrigger__c(SetupOwnerId=UserInfo.getOrganizationId(), isDisabled__c=true,
                Name='Testing TriggerHandler Bypass');
        insert bypassTrigger;

        pse__Proj__c proj = [SELECT Id, Name, Actual_start_date__c FROM pse__Proj__c LIMIT 1];
        System.debug('-- Project = '+proj);

        Attachment a = new Attachment(Name = SVR_FILE, parentId = proj.Id,
                Body = EncodingUtil.base64Decode('Test Body'));
        List<Attachment> attachments = new List<Attachment>();
        attachments.add(a);
        insert attachments;
        System.debug('-- attachments = '+attachments);

        //Contact contactInstance=new Contact(FirstName='Test Contact', LastName='Test Last Name', Email='test@test.com');
        //insert contactInstance;

        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs (thisUser) {
            EmailTemplate et = new EmailTemplate (developerName = 'test', IsActive = true,
                    TemplateType = 'Text', Name = SVR_EMAIL_TEMPLATE, FolderId = UserInfo.getUserId()); // plus any other fields that you want to set
            insert et;
        }

        Test.startTest();
        Messaging.SendEmailResult[] sendEmailResults =
                AttachmentTriggerHandler.emailAlertForFilesAttachedToProjects(attachments);
        Test.stopTest();

        System.assertNotEquals(null, sendEmailResults);
        System.debug('-- sendEmailResults = '+sendEmailResults);

        System.assertEquals(true, sendEmailResults[0].isSuccess());
    }

    @IsTest
    static void testEmailAlertForFilesAttachedToCases() {
        ByPassTrigger__c bypassTrigger = new ByPassTrigger__c(SetupOwnerId=UserInfo.getOrganizationId(), isDisabled__c=true,
                Name='Testing TriggerHandler Bypass');
        insert bypassTrigger;

        // Create Case
        CaseTestData caseTestData  = new CaseTestData();
        List<Attachment> attachments = new List<Attachment>();

        //insert test user
        //Profile testProfile=[select id from profile where Name = 'System Administrator'];
        List<Profile> profiles = [SELECT Id, Name FROM Profile];
        System.debug('-- Profiles: '+profiles);

        Profile testProfile=[SELECT Id FROM profile WHERE Name = 'Customer Community Profile' LIMIT 1];
        List<User> TestUserList = caseTestData.CreateUser('BURoadnet', testProfile.id, 'TestCaseUser', null, 2);
        TestUserList[0].isActive = true;
        TestUserList[1].isActive = true;
        insert TestUserList;

        System.runAs(TestUserList.get(0)) {
            //insert Account
            List<Account> accountList = caseTestData.CreateAcccount('Test Account', null, 1, null);
            insert accountList;

            //Insert Contact
            List<Contact> contactList =  caseTestData.CreateContact('Test Contact', 1, accountList.get(0).id);
            insert contactList;

            List<Case> createCaseList;
            //System.runAs(TestUserList.get(0)) {
            //User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
            //System.runAs (thisUser) {
                // Insert Case
                createCaseList = caseTestData.CreateCase('TIS', 'Call Center', accountList, contactList, TestUserList, 5);
                insert createCaseList;
                System.assert(createCaseList.get(0).id != null, 'Exception in Case Creation');
            //}

            //ByPassTrigger__c bypassTrigger = ByPassTrigger__c.getinstance();
            System.debug('-- 1: ByPassTrigger__c = '+bypassTrigger);
            bypassTrigger.isDisabled__c = false;
            update bypassTrigger;
            System.debug('-- 2: ByPassTrigger__c = '+bypassTrigger);

            // Create Attachments
            List<sObject> sObjCSList = new List<sObject>();
            sObjCSList.add(new Send_Trigger_Email_Alerts__c(Name = 'Roadnet', isDisabled__c = false));
            insert sObjCSList;

        //System.runAs(TestUserList.get(0)) {
            Attachment a = new Attachment(Name = 'Test Case Attachment 1', parentId = createCaseList[0].Id,
                    Body = EncodingUtil.base64Decode('Test Body'));

            attachments.add(a);

            //Test.startTest();
            insert attachments;
            //Test.stopTest();
        }

        Custom_Report__c cr = new Custom_Report__c();
        insert cr;

        Test.startTest();
            Attachment att = AttachmentTriggerHandler.findAttachment(cr.Id, attachments);
        Test.stopTest();
    }
}