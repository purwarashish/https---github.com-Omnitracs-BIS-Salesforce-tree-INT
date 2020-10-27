@isTest
private class SpringCMRestHelperTests {
    static testMethod void testStartWorkflow() {
       /* PSAEnhancementTestData objPSAEnhancementTestData = new PSAEnhancementTestData();
        User user= objPSAEnhancementTestData.getUser();
        Opportunity o;
     	System.runAs(user)
      	{ 
            List<AccountRecordTypes__c> accRecordType= objPSAEnhancementTestData.customSettingsAccountRecordTypes(); 
            //insert recordType
            insert accRecordType;            
            List<AllAccountUtils__c> testCustomSettings=objPSAEnhancementTestData.customSettingsAccountUtils(); 
            //insert customSettings
            insert testCustomSettings;
            Account a= objPSAEnhancementTestData.createAccount(accRecordType);
       	    insert a;
            o = (Opportunity) SpringCMTestDataFactory.createSObject(new Opportunity(AccountID = a.Id), true);   

        }
        SpringCMEos__EOS_Type__c eA = (SpringCMEos__EOS_Type__c)SpringCMTestDataFactory.createSObject(new SpringCMEos__EOS_Type__c(), true);
        SpringCMEos__EOS_Type__c eO = (SpringCMEos__EOS_Type__c)SpringCMTestDataFactory.createSObject(new SpringCMEos__EOS_Type__c(name = 'Opportunity',
                SpringCMEos__Folder_Name__c = '{!Name}',
                SpringCMEos__Folder_Name_Format__c = '{0}',
                SpringCMEos__Path__c = '/path/{!Account.Name}',
                SpringCMEos__Path_Format__c = '/path/{1}',
                SpringCMEos__Variables__c = 'Name,Account.Name'), true);
        //Account a = (Account) SpringCMTestDataFactory.createSObject(new Account(), false);
        
        SpringCMApiManagerMock mock = new SpringCMApiManagerMock();
        Boolean noErrorsThrown = true;

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, mock);
        try {
            SpringCMRestHelper.StartWorkflow(o.Id, 'Opportunity', 'workflowname', null);
        }
        catch (Exception ex) {
            noErrorsThrown = false;
        }
        Test.stopTest();

        System.assert(noErrorsThrown);*/
    }

    static testMethod void testBulkTriggerHandling() {
        /*PSAEnhancementTestData objPSAEnhancementTestData = new PSAEnhancementTestData();
        User user= objPSAEnhancementTestData.getUser();
        Account a;
     	System.runAs(user)
      	{ 
            List<AccountRecordTypes__c> accRecordType= objPSAEnhancementTestData.customSettingsAccountRecordTypes(); 
            //insert recordType
            insert accRecordType;            
            List<AllAccountUtils__c> testCustomSettings=objPSAEnhancementTestData.customSettingsAccountUtils(); 
            //insert customSettings
            insert testCustomSettings;
            a = objPSAEnhancementTestData.createAccount(accRecordType);
        	insert a;
        }
        SpringCMEos__EOS_Type__c eA = (SpringCMEos__EOS_Type__c)SpringCMTestDataFactory.createSObject(new SpringCMEos__EOS_Type__c(), true);
        SpringCMEos__EOS_Type__c eO = (SpringCMEos__EOS_Type__c)SpringCMTestDataFactory.createSObject(new SpringCMEos__EOS_Type__c(name = 'Opportunity',
                SpringCMEos__Folder_Name__c = '{!Name}',
                SpringCMEos__Folder_Name_Format__c = '{0}',
                SpringCMEos__Path__c = '/path/{!Account.Name}',
                SpringCMEos__Path_Format__c = '/path/{1}',
                SpringCMEos__Variables__c = 'Name,Account.Name'), true);
        //Account[] accounts = (Account[])SpringCMTestDataFactory.createSObjectList(new Account(), 1000);
        
        SpringCMApiManagerMock mock = new SpringCMApiManagerMock();
        Boolean noErrorsThrown = true;

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, mock);
        try {
            insert a;
        }
        catch (Exception ex) {
            noErrorsThrown = false;
        }
        Test.stopTest();

        System.assert(noErrorsThrown);*/
    }
}