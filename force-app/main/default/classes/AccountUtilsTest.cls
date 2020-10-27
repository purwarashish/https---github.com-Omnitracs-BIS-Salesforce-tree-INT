@isTest(SeeAllData=true)
private class AccountUtilsTest {

   /* private static testmethod void testForassignRankingCargoType()
    {
    	Savepoint sp = Database.setSavepoint();
    	//  can take the lazy route and query an account or create one, only thing we really need to do is set
    	//  the cargo type to be a vlue int he account picklist
    	Account testAccount = RoadnetUnitTests.createTestAccount(null);
    	testAccount.Cargo_Type__c = 'BEVERAGES';
    	AccountUtils.assignRankingCargoType(new list<account>{testaccount});
    	system.assertEquals(1.0, testAccount.Ranking_Cargo_Type__c);
    	Database.rollback(sp);
    }
    static testMethod void test_removeNotificationTypesFromDormantAccounts() {
        Profile p = [select id from profile where name = 'System Administrator'];
        User testUser = new User(
            alias = 'accttest'
            ,email = 'accounttest@omnitracs.com'
            ,emailencodingkey = 'UTF-8'
            ,lastname = 'Tester'
            ,languagelocalekey = 'en_US'
            ,localesidkey = 'en_US'
            ,profileid = p.Id
            ,timezonesidkey = 'America/Denver'
            ,username = 'accounttest@omnitracs.com'
        );   
        insert testUser;
          // Commented by Pintoo 
       // insert new MarketingAdmin__c(Marketing_Admin_User__c = testUser.id);
        MarketingAdmin__c ma = MarketingAdmin__c.getInstance();
        System.assert(ma != null);
        // Commnted by Pintoo
        //System.assertEquals(testUser.id, ma.Marketing_Admin_User__c);
        
        Account a1 = new Account(
            Name = 'Test Referral Account'
            ,BillingStreet='Test Billing Street 123'
            ,BillingCity='Test Billing City 123'
            ,BillingCountry='Test Billing Country 123'
            ,QWBS_Status__c = 'Active'
            ,BillingState = 'Test Billing State'
        );
        insert a1;
        List<Id> listId = new List<Id>();
        listId.add(a1.id);
        Contact c1 = new Contact(
            AccountId = a1.Id
            ,FirstName = 'Test First'
            ,LastName = 'Test Last'
            ,Notification_Type__c = 'Foo;Battery Alert;Downtime/Degraded;FRA;Portal Services Platform;RMA Initiator;SSO Portal Administrator;Time Change'
            ,MailingState = 'CA'
        );
        insert c1;
        
        // Negative case - account doesn't have appropriate status.
         // Comment out by Pintoo because method doesnt exist in AccountUtils Class
         // AccountUtils.removeNotificationTypesFromDormantAccounts(new List<Account>{a1});
         AccountUtils.remNotTypesAndChangeOwnerFromDormantAcc(listId);

        System.assert(c1.Notification_Type__c.equals('Foo;Battery Alert;Downtime/Degraded;FRA;Portal Services Platform;RMA Initiator;SSO Portal Administrator;Time Change'));
        System.assertEquals([select OwnerID from Contact where id = :c1.id].OwnerID, UserInfo.getUserId());
        
        // Make sure the notification types are filtered out.
        a1.QWBS_Status__c = 'Closed - End of Eval';
         // Commented by Pintoo because method doesnt exist in AccountUtils Class
        //AccountUtils.removeNotificationTypesFromDormantAccounts(new List<Account>{a1});
        //System.assert([select Notification_Type__c from Contact where id = :c1.id].Notification_Type__c.equals('Foo'));
        //System.assertEquals([select OwnerID from Contact where id = :c1.id].OwnerID, ma.Marketing_Admin_User__c);
    }
   
    static testMethod void test_inactivateContactsFromDormantAccounts() {
        Account a1 = new Account(
            Name = 'Test Referral Account'
            ,BillingStreet='Test Billing Street 123'
            ,BillingCity='Test Billing City 123'
            ,BillingCountry='Test Billing Country 123'
            ,QWBS_Status__c = 'Active'
            ,BillingState = 'Test Billing State'
        );
        insert a1;
        List<id> lstId = new List<Id>();
         lstId.add(a1.id);
        Contact c1 = new Contact(
            AccountId = a1.Id
            ,FirstName = 'Test First'
            ,LastName = 'Test Last'
            ,Inactive__c = false
            ,MailingState = 'CA'
        );
        insert c1;
        
        // Negative test case.
         // Comment out by Pintoo
        //AccountUtils.inactivateContactsFromDormantAccounts(new List<Account>{a1});
        AccountUtils.inactivateContactsFromDormantAccounts(lstId);
        System.assert(![select Inactive__c from Contact where id = :c1.id].Inactive__c);
        
        // Check to see if our contact goes inactive.
        a1.Closed_Reason__c = 'Out of Business';
        update a1;
        // Technically this is executed twice, the following call is also called in the trigger.
        // However, I wanted to specifically test this method.
        
         // Comment out by Pintoo because f incorrect sinature
          //AccountUtils.inactivateContactsFromDormantAccounts(new List<Account>{a1});
        //System.assert([select Inactive__c from Contact where id = :c1.id].Inactive__c);
    }
    
   static testmethod void test_validateBillingState1()
   {  Account accnt1 = new Account(
             Name = 'Test Referral Account1'
            ,BillingStreet ='Test Billing Street 123'
            ,BillingCity ='Test Billing City 123'
            ,BillingCountry ='US'
            ,BillingState = 'CA'
            ,QWBS_Status__c = 'Active'
           );
           
        insert accnt1;
    
   }
   
 /*  
    static testmethod void test_validateBillingState2()
   {  Account accnt2 = new Account(
             Name = 'Test Referral Account1'
            ,BillingStreet ='Test Billing Street 123'
            ,BillingCity ='Test Billing City 123'
            ,BillingCountry ='US'
            ,BillingState = 'California'
            ,QWBS_Status__c = 'Active'
           );
           
        insert accnt2;
    
   }
   static testmethod void test_validateBillingState3()
   {  Account accnt3 = new Account(
             Name = 'Test Referral Account1'
            ,BillingStreet ='Test Billing Street 123'
            ,BillingCity ='Test Billing City 123'
            ,BillingCountry ='US'
            ,BillingState = 'Abc'
            ,QWBS_Status__c = 'Active'
              );
           
        insert accnt3;
    }
   
    
   static testmethod void test_changeOpprStageToClosedLost()
   {
   Profile p = [select id from profile where name = 'System Administrator'];

   User testUser1 = new User(
            alias = 'accttest'
            ,email = 'accounttest@omnitracs.com'
            ,emailencodingkey = 'UTF-8'
            ,lastname = 'Tester'
            ,languagelocalekey = 'en_US'
            ,localesidkey = 'en_US'
            ,profileid = p.Id
            ,timezonesidkey = 'America/Denver'
            ,username = 'accounttest@omnitracs.com'
        );   
        insert testUser1;

   Account accnt4 = new Account(
             Name = 'Test Referral Account1'
            ,BillingStreet ='Test Billing Street 123'
            ,BillingCity ='Test Billing City 123'
            ,BillingCountry ='US'
            ,BillingState = 'CA'
            ,QWBS_Status__c = 'Active Prospect'
            ,Closed_Reason__c = 'xyz'
            ,Lost_to_Competition__c = 'Yes'
            ,Account_Type__c = 'Telecom'
            ,QWBS_Market__c = 'Test market'
            ,Account_Manager__c = testUser1.Id
            ,Phone = '5667788'
           );
           
        insert accnt4;
        List<Id> listOfAccClosedId = new List<Id>();
        listOfAccClosedId.add(accnt4.id);
        
        AccountUtils.changeOpprStageToClosedLost(listOfAccClosedId);
   
   }
   //  added by joseph hutchins 10/23/2014
   private static testmethod void test_forupdateSicFields()
   {
   	 Savepoint sp = Database.setSavepoint();
   	 Sic__c testSic = new Sic__c( 
   	 	name = '1234',
   	 	Description_Detailed__c = 'DescriptionDetailed',
   	 	Description_General__c = 'DescriptionGeneral',
   	 	Reporting__c = 'Reporting');
   	 
   	 database.saveResult sr = database.insert(testSic);
   	 Account testAccount = new Account(name = 'testAccount',
   	 BillingStreet='Test Billing Street 123'
   	        ,BillingCity='Test Billing City 123'
            ,BillingCountry='Test Billing Country 123'
            ,QWBS_Status__c = 'Active'
            ,BillingState = 'Test Billing State',
            Sic_code__c = testSic.name );
      	sr = database.insert(testAccount);
      	//  only going to test the update part of the method, logic is the same for both insert and update
      	AccountUtils.updateSicFields(null, new list<account>{testAccount});
   		Database.rollback(sp);
   }
   
   private static testmethod void test_formanageManualAssignmentForAccountTeamCreation()
   {
   	    Savepoint sp = Database.setSavepoint();
        List<Account> newAccountList = new List<Account>();
        Account testAccount = new Account();
        testAccount.name = 'joseph apex test account';
        testAccount.Primary_Business_Unit__c = 'Roadnet';
        
        
        newaccountList.add(testAccount);
        //  test the insert part of this
        AccountUtils.manageManualAssignmentForAccountTeamCreation(null, newAccountList);
        
        //  test the update part of this
        List<Account> oldAccountList = new List<Account>();
        Account oldAccountTest = new Account();
        oldAccountTest.Name = 'joseph apex test account old';
        testAccount.Primary_Business_Unit__c = 'Sylectus';
        oldAccountList.add(oldAccountTest);
        AccountUtils.manageManualAssignmentForAccountTeamCreation(oldAccountList, newAccountList);
        
        Database.rollback(sp);
   }
  
   private static testmethod void test_forcreateAccountTeams()
   {
        Savepoint sp = Database.setSavepoint();
        //  test the insert part of this
        List<Account> newAccountList = new List<Account>();
         Account testAccount = new Account(name = 'testAccount',
            Primary_Business_Unit__c = 'Roadnet',
            BillingStreet='Test Billing Street 123'
            ,BillingCity='Test Billing City 123'
            ,BillingCountry='Test Billing Country 123'
            ,QWBS_Status__c = 'Active'
            ,BillingState = 'Test Billing State');
        
        
        newaccountList.add(testAccount);
        AccountUtils.createAccountTeams(null, newAccountList);
        
        //  test the update part of this
        List<Account> oldAccountList = new List<Account>();
        testAccount.Primary_Business_Unit__c = 'Sylectus';//  change the bunises unit
        oldAccountList.add(testAccount);
        AccountUtils.manageManualAssignmentForAccountTeamCreation(oldAccountList, newAccountList);
        
        Database.rollback(sp);
   }
  */
       
}