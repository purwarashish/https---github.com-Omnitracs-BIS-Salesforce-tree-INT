@isTest(SeeAllData=true)
private class OpportunityActivityUtilsTest {
  
    static testMethod void test_create_Opportunity_Activities() {
        // Create custom setting for current user.
        insert new Partner_Activity__c(
            SetupOwnerId = UserInfo.getUserId()
            ,isPartner__c = true
        );
        Partner_Activity__c pas = [select isPartner__c from Partner_Activity__c where SetupOwnerId = :UserInfo.getUserId() limit 1];
        System.assert(pas != null);
        System.assert(pas.isPartner__c);
        
        // This will be the primary Opportunity to use.
        Account testaccount = new Account(
            Name = 'Test Account'
            ,BillingStreet = 'Test Billing Street'
            ,BillingCity = 'Test Billing City'
            ,BillingCountry = 'Test Billing Country'
        );
        insert testaccount;
        
        Opportunity l = new Opportunity(
            AccountId = testaccount.id
            ,Name = 'Test Opportunity'
            ,StageName = 'Test Stage'
            ,CloseDate = Date.today().addDays(1)
            ,RecordTypeID = SystemIds__c.getInstance().RecordTypeId_Opportunity_Partner__c
        );
        test.startTest();
        insert l;
        System.assert(l.ID != null);
        l = [select Partner_Driven_Last_Activity__c from Opportunity where ID = :l.ID];
        //System.assert(l.Partner_Driven_Last_Activity__c != null); // IMPORTANT: Activity has already been set here from a workflow.
        
        // Create a task and verify Partner_Driven_Last_Activity__c has been set.
        /*Datetime dt = l.Partner_Driven_Last_Activity__c;
        Task t = new Task(
            WhatId = l.ID
            ,Type = 'Call'
            ,Subject = 'Test Task Call'
            ,IsRecurrence = false
            ,Description = 'Test Description'
        );
        insert t;
        System.assert(t.ID != null);
        l = [select Partner_Driven_Last_Activity__c,Last_Task_Comment__c from Opportunity where ID = :l.ID];
        //System.assert(l.Partner_Driven_Last_Activity__c != null && l.Partner_Driven_Last_Activity__c >= dt);
        //System.assert(l.Last_Task_Comment__c != null && 'Test Description'.equals(l.Last_Task_Comment__c));
        
        // Create an event and verify Partner_Driven_Last_Activity__c has been set.
        dt = l.Partner_Driven_Last_Activity__c;
        Event e = new Event(
            WhatID = l.Id
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
        l = [select Partner_Driven_Last_Activity__c from Opportunity where ID = :l.ID];
        //System.assert(l.Partner_Driven_Last_Activity__c != null && l.Partner_Driven_Last_Activity__c >= dt);

        // Create an attachment and verify Partner_Driven_Last_Activity__c has been set.
        dt = l.Partner_Driven_Last_Activity__c;
        Attachment a = new Attachment(
            ParentID = l.ID
            ,Body = Blob.valueOf('Test')
            ,Name = 'Test'
        );
        insert a;
        System.assert(a.ID != null);
        l = [select Partner_Driven_Last_Activity__c from Opportunity where ID = :l.ID];
        //System.assert(l.Partner_Driven_Last_Activity__c != null && l.Partner_Driven_Last_Activity__c >= dt);
        
        // Create a note and verify Partner_Driven_Last_Activity__c has been set.
        dt = l.Partner_Driven_Last_Activity__c;
        Note n = New Note(
            Title = 'Test'
            ,ParentID = l.ID
            ,Body = 'Testing!'
        );
        insert n;
        System.assert(a.ID != null);
        l = [select Partner_Driven_Last_Activity__c from Opportunity where ID = :l.ID];
        //System.assert(l.Partner_Driven_Last_Activity__c != null && l.Partner_Driven_Last_Activity__c >= dt);*/
        test.stopTest();
    }
}