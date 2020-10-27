@isTest(seeAllData=true)
private class LeadConversionExtensionTest {
    public static VistaAssetHelperUtil util = new VistaAssetHelperUtil();
    static testmethod void testLeadConversionExtension(){
    Test.startTest();
    //Account acct = util.createAccount('ABC Test Account');
        Account acct = new Account(Name = 'Joseph Test Lead Company', QWBS_Market__c = 'Enterprise', Primary_Business_Unit__c = 'Omnitracs Domestic', QWBS_Cust_ID__c = '12345', Segment__c = 'TL', BillingStreet = 'BillingStreet', BillingCity = 'BillingCity', BillingCountry = 'BillingCountry',BillingState = 'BillingState', BillingPostalCode = 'BillingPostalCode', Account_Status__c = 'Active', QWBS_Status__c = 'Active',Fleet_Size__c = 5);
        insert acct;
        Contact testContact = new Contact(FirstName = 'FirstName', LastName = 'LastName', Title = 'Title', Email = 'testemail@email.com', AccountId = acct.Id, Inactive__c = FALSE, HasOptedOutOfEmail = FALSE, Contact_Alert__c = 'blarg', Phone = '999-999-9999', Decision_Maker_Influencer__c = 'No');
        insert testContact;
        OpportunityTestData opportunityTestData  = new OpportunityTestData();
        PriceBook2 stdPriceBook = TestUtils.getStandardPriceBook();  //opportunityTestData.createPriceBook();
        List<Opportunity> optyList = opportunityTestData.CreateOpportunity('validateOpptyEditability', acct.Id, 'Products, Services and Maintenance', 1, testContact.Id, stdPriceBook, null, null, null);
        insert optyList;
        Opportunity opportunity = optyList.get(0);
        
        Task testTask = new Task(whatId = opportunity.Id, whoId = testContact.id, subject = 'blarg', priority = 'Normal', description = 'blarg');
        insert testTask;
        
        
        Lead testLead = LeadConversionExtension.createTestLead(null);
        LeadConversionExtension testExtension = new LeadConversionExtension(LeadConversionExtension.generateController(testLead));
        testExtension.theContactForOwnerLookupOnly = testContact;
        
        // tons of getters and setters.....
        String testString = testExtension.mergeContactUserChoice;
        boolean testBool = testExtension.showMergeContactsSection;
        testbool = testExtension.areTaskFieldsRequired;
        testbool = testExtension.hasLeadBeenConvertedWhilePageWasOpen();
        testbool = testExtension.isRoadnetBu;
        
        testString = testExtension.leadConvertHelpMessage;
        testString = testExtension.mergeHelpMessage;
        List<SelectOption> testOptions = testExtension.convertedStatusPicklist;
        testOptions = testExtension.opptRecordTypePicklist;
        testOptions = testExtension.stageNamePicklist;

        //  this calls the various pagereference methods
        testExtension.checkIfConvertedLead();
        testExtension.doNotCreateOpptOnChange();
        testExtension.accountLookupOnBlur();
        testExtension.accountPicklistOnchange();
        testExtension.taskReminderOnChange();
        testExtension.opptRecordTypePicklistOnChange();
        testExtension.simplePageRefresh();
        testExtension.grabOnlyNonclosedStages();
        
        
        testExtension.convertedStatusUserChoice = 'Qualified';
        testExtension.accountPicklistUserChoice = LeadConversionExtension.CREATE_ACCOUNT_PICKLIST_VALUE;
        
        testExtension.doNotCreateOppt = false; //  to get proper code coverage, we should allow it to create an oppt
        testExtension.contactRoleUsedForRolePicklistOnly.Role = 'End User';
        testExtension.theTask.subject = 'Something';
        testExtension.theTask.status = 'Not Started';
        testExtension.theTask.priority = 'Normal';
        
        testExtension.theOppt.StageName = 'Sales Acceptance';
        testExtension.checkForFieldsAndForDupeContacts();
        testExtension.convertLead();
       
         LeadConversionExtension.sendTaskNotificationEmail(testTask.id);
         testBool = LeadConversionExtension.isOwnerAQueue(UserInfo.getUserId());
         testExtension.defineMergeContactPicklist();
        
        testbool = testExtension.hasLeadBeenConvertedWhilePageWasOpen();
        testExtension.updateOpptWithCustomFieldsAndUpdateContactRole(opportunity.Id, testContact.Id, testExtension.contactRoleUsedForRolePicklistOnly.Role);
        testExtension.createTaskAndSendNotifcationIfSet(testContact.Id, opportunity.Id, UserInfo.getUserId());
      
        Test.stopTest();
    }
    
      public static testMethod void testForChangeLeadOwnerExtension(){
        Test.startTest();
        //Id userId = [select Id, Name from user where profile.name = 'System Administrator' and isactive = true limit 1].Id;
        Lead testLead = LeadConversionExtension.createTestLead(null);
        
        ApexPages.standardController controller = ChangeLeadOwnerExtension.generateController(testLead);
        ChangeLeadOwnerExtension testExtension = new ChangeLeadOwnerExtension(controller);
        testExtension.notifyNewOwner = true;
        testExtension.emailComments = 'Test';
        //testExtension.Lead.ownerId = userId;
        testExtension.Lead.ownerId = UserInfo.getUserId();
        testExtension.changeOwner();
        
        Test.stopTest();
    }
}