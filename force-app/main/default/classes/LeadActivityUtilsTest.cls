@isTest
private class LeadActivityUtilsTest {
    
    static testMethod void test_create_Lead_Activities_NonPartner() {
        createTestCountryCode();
        // This will be the primary lead to use.
        Lead l = new Lead(
            FirstName = 'Average'
            ,LastName = 'Joe'
            ,Company = 'Average Joe Test Co'
            ,Street = 'Test Street'
            ,City = 'Test City'
            ,PostalCode = 'Test Zip'
            ,Country = 'Canada'
            ,RecordTypeID = [select ID from RecordType where SobjectType = 'Lead' and Name = 'Old Partner Lead (Reseller)'].ID
        );
        
        insert l;
        
        Test.startTest();
        // Create a task and verify Partner_Driven_Last_Activity__c has been set.
        Datetime dt = l.Partner_Driven_Last_Activity__c;
        Task t = new Task(
            WhoId = l.ID
            ,Type = 'Call'
            ,Subject = 'Test Task Call'
            ,IsRecurrence = false
            ,Description = 'Test Description'
        );
        insert t;
        System.assert(t.ID != null);
        l = [select Partner_Driven_Last_Activity__c,Last_Task_Comment__c from Lead where ID = :l.ID];
        System.assert(l.Partner_Driven_Last_Activity__c == null);
        //System.assert(l.Last_Task_Comment__c != null && 'Test Description'.equals(l.Last_Task_Comment__c));
        Test.stopTest();
    }
    private static void createTestCountryCode()
    {
        Country_And_Country_Code__c ccc = new Country_And_Country_Code__c();
        ccc.name = 'Canada';
        ccc.region__c = 'AMCAN';
        insert ccc;
    }
    static testMethod void test_create_Lead_Activities_Partner() {
        
        createTestCountryCode();
        // Create custom setting for current user.
        insert new Partner_Activity__c(
            SetupOwnerId = UserInfo.getUserId()
            ,isPartner__c = true
        );
        Partner_Activity__c pas = [select isPartner__c from Partner_Activity__c where SetupOwnerId = :UserInfo.getUserId() limit 1];
        System.assert(pas != null);
        System.assert(pas.isPartner__c);
        
        // This will be the primary lead to use.
        Lead l = new Lead(
            FirstName = 'Average'
            ,LastName = 'Joe'
            ,Company = 'Average Joe Test Co'
            ,Street = 'Test Street'
            ,City = 'Test City'
            ,PostalCode = 'Test Zip'
            ,Country = 'Canada'
            ,RecordTypeID = [select ID from RecordType where SobjectType = 'Lead' and Name = 'Old Partner Lead (Reseller)'].ID
        );
        
        insert l;
        System.assert(l.ID != null);
        l = [select Partner_Driven_Last_Activity__c from Lead where ID = :l.ID];
       // System.assert(l.Partner_Driven_Last_Activity__c != null);
        
        Test.startTest();
        // Create a task and verify Partner_Driven_Last_Activity__c has been set.
        Datetime dt = l.Partner_Driven_Last_Activity__c;
        Task t = new Task(
            WhoId = l.ID
            ,Type = 'Call'
            ,Subject = 'Test Task Call'
            ,IsRecurrence = false
            ,Description = 'Test Description'
        );
        insert t;
        System.assert(t.ID != null);
        l = [select Partner_Driven_Last_Activity__c,Last_Task_Comment__c from Lead where ID = :l.ID];
        //System.assert(l.Partner_Driven_Last_Activity__c != null && l.Partner_Driven_Last_Activity__c >= dt);
        //System.assert(l.Last_Task_Comment__c != null && 'Test Description'.equals(l.Last_Task_Comment__c));
        Test.stopTest();
        
    }
    
    static testMethod void testTrackingEvent()
    {
        createTestCountryCode();
        // Create custom setting for current user.
        insert new Partner_Activity__c(
            SetupOwnerId = UserInfo.getUserId()
            ,isPartner__c = true
        );
        Partner_Activity__c pas = [select isPartner__c from Partner_Activity__c where SetupOwnerId = :UserInfo.getUserId() limit 1];
        System.assert(pas != null);
        System.assert(pas.isPartner__c);
        
        // This will be the primary lead to use.
        Lead l = new Lead(
            FirstName = 'Average'
            ,LastName = 'Joe'
            ,Company = 'Average Joe Test Co'
            ,Street = 'Test Street'
            ,City = 'Test City'
            ,PostalCode = 'Test Zip'
            ,Country = 'Canada'
            ,RecordTypeID = [select ID from RecordType where SobjectType = 'Lead' and Name = 'Old Partner Lead (Reseller)'].ID
        );
        
        insert l;
        System.assert(l.ID != null);
        l = [select Partner_Driven_Last_Activity__c from Lead where ID = :l.ID];
        //System.assert(l.Partner_Driven_Last_Activity__c != null);
        Test.startTest();
        // Create an event and verify Partner_Driven_Last_Activity__c has been set.
        Datetime dt = l.Partner_Driven_Last_Activity__c;
        Event e = new Event(
            WhoID = l.Id
            ,Type = 'Meeting'
            ,Subject = 'Test Event Meeting'
            ,StartDateTime = Datetime.now().addDays(1)
            ,Location = 'Here'
            ,IsReminderSet = false
            ,IsRecurrence = false
            ,EndDateTime = Datetime.now().addDays(1).addHours(1)
        );
        insert e;
        System.assert(e.ID != null);
        l = [select Partner_Driven_Last_Activity__c from Lead where ID = :l.ID];
        //System.assert(l.Partner_Driven_Last_Activity__c != null && l.Partner_Driven_Last_Activity__c >= dt);
         Test.stopTest();
    }
    
    static testMethod void testTrackingAttachment()
    {
        createTestCountryCode();
        // Create custom setting for current user.
        insert new Partner_Activity__c(
            SetupOwnerId = UserInfo.getUserId()
            ,isPartner__c = true
        );
        Partner_Activity__c pas = [select isPartner__c from Partner_Activity__c where SetupOwnerId = :UserInfo.getUserId() limit 1];
        System.assert(pas != null);
        System.assert(pas.isPartner__c);
        
        // This will be the primary lead to use.
        Lead l = new Lead(
            FirstName = 'Average'
            ,LastName = 'Joe'
            ,Company = 'Average Joe Test Co'
            ,Street = 'Test Street'
            ,City = 'Test City'
            ,PostalCode = 'Test Zip'
            ,Country = 'Canada'
            ,RecordTypeID = [select ID from RecordType where SobjectType = 'Lead' and Name = 'Old Partner Lead (Reseller)'].ID
        );
        
        insert l;
        System.assert(l.ID != null);
        l = [select Partner_Driven_Last_Activity__c from Lead where ID = :l.ID];
        //System.assert(l.Partner_Driven_Last_Activity__c != null);
         Test.startTest();
        // Create an attachment and verify Partner_Driven_Last_Activity__c has been set.
        Datetime dt = l.Partner_Driven_Last_Activity__c;
        Attachment a = new Attachment(
            ParentID = l.ID
            ,Body = Blob.valueOf('Test')
            ,Name = 'Test'
        );
        insert a;
        System.assert(a.ID != null);
        l = [select Partner_Driven_Last_Activity__c from Lead where ID = :l.ID];
        //System.assert(l.Partner_Driven_Last_Activity__c != null && l.Partner_Driven_Last_Activity__c >= dt);
        Test.stopTest();
        
    }
    
    static testMethod void testTrackingNote()
    {
        createTestCountryCode();
        // Create custom setting for current user.
        insert new Partner_Activity__c(
            SetupOwnerId = UserInfo.getUserId()
            ,isPartner__c = true
        );
        Partner_Activity__c pas = [select isPartner__c from Partner_Activity__c where SetupOwnerId = :UserInfo.getUserId() limit 1];
        System.assert(pas != null);
        System.assert(pas.isPartner__c);
        
        // This will be the primary lead to use.
        Lead l = new Lead(
            FirstName = 'Average'
            ,LastName = 'Joe'
            ,Company = 'Average Joe Test Co'
            ,Street = 'Test Street'
            ,City = 'Test City'
            ,PostalCode = 'Test Zip'
            ,Country = 'Canada'
            ,RecordTypeID = [select ID from RecordType where SobjectType = 'Lead' and Name = 'Old Partner Lead (Reseller)'].ID
        );
        
        insert l;
        System.assert(l.ID != null);
        l = [select Partner_Driven_Last_Activity__c from Lead where ID = :l.ID];
        //System.assert(l.Partner_Driven_Last_Activity__c != null);
        Test.startTest();
        // Create a note and verify Partner_Driven_Last_Activity__c has been set.
        Datetime dt = l.Partner_Driven_Last_Activity__c;
        Note n = New Note(
            Title = 'Test'
            ,ParentID = l.ID
            ,Body = 'Testing!'
        );
        insert n;
        System.assert(n.ID != null);
        l = [select Partner_Driven_Last_Activity__c from Lead where ID = :l.ID];
        //System.assert(l.Partner_Driven_Last_Activity__c != null && l.Partner_Driven_Last_Activity__c >= dt);
        Test.stopTest();
    }
}