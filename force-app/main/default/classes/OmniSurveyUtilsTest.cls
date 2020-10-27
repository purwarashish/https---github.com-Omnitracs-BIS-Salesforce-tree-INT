@isTest
private class OmniSurveyUtilsTest {
	static testMethod void myUnitTest() { 
		
		User newUser = getTestUser('Test User','System Administrator');
		
		/*List<AccountRecordTypes__c> accntRTList = new List<AccountRecordTypes__c>();
        AccountRecordTypes__c accntRType = new AccountRecordTypes__c();
        accntRType.Name='TL_SALES_ACCOUNT_RECORD_TYPE_ID';
        accntRType.RecordTypeID__c = Schema.SObjectType.Account.getRecordTypeInfosByName().get('T&L Sales Accounts').getRecordTypeId();
        accntRTList.add(accntRType);
        AccountRecordTypes__c accntRType1 = new AccountRecordTypes__c();
        accntRType1.Name='COMPETITOR_RECORD_TYPE_ID';
        accntRType1.RecordTypeID__c = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Competitor').getRecordTypeId();
        accntRTList.add(accntRType1);
        insert accntRTList;
		
		Account accnt = new Account();                                                             
        accnt.Name='Test Account';
        accnt.Primary_Business_Unit__c='Omnitracs Domestic';
        accnt.Account_Classification__c='Prospect';
        accnt.Account_Status__c='Active';
        accnt.phone='1234567890';
        accnt.QWBS_Status__c='Active';       
        accnt.RecordTypeId= accntRTList[0].RecordTypeID__c;         
        accnt.BillingStreet='Test St';
        accnt.BillingCity='Frisco';
        accnt.BillingState='TX';
        accnt.BillingCountry='USA';  
        insert accnt;         */       
        
        Account accnt = TestUtils.getAccount('Test Account');
		
		Contact cntct = TestUtils.getContact(accnt, 'Test Contact');
        
		pse__Proj__c proj =new pse__Proj__c();
        Schema.DescribeSObjectResult cfrSchemaProject = Schema.SObjectType.pse__Proj__c; 
            Map<String,Schema.RecordTypeInfo> ProjectRecordTypeInfo = cfrSchemaProject.getRecordTypeInfosByName();                
            proj.RecordTypeId =ProjectRecordTypeInfo.get('Customer Project').getRecordTypeId(); 
            proj.CurrencyIsoCode ='USD'; 
            proj.pse__Account__c= accnt.Id;
            proj.pse__Billing_Type__c='Fixed Price'; 
            proj.Time_Approval_Method__c ='Direct Manager'; 
            proj.pse__Start_Date__c=Date.newInstance(2016 , 01 ,01);
            proj.pse__End_Date__c=Date.newInstance(2016 , 01 ,28);   
            proj.name ='testProject';
    	insert proj;
		
		Test.startTest();
        proj.pse__Project_Manager__c = cntct.Id;
		proj.Survey_Recipient__c = cntct.Id;
		proj.Survey_Subject_User__c = newUser.Id;
		proj.Survey_Initiated_By__c = newUser.Id;
		proj.Send_Survey_Now__c = true;
        update proj;
		Test.stopTest();
		
		
		// TO DO: implement unit test
	}
	
	static testMethod void myUnitTest2() {
		
		User newUser = getTestUser('Test User','System Administrator');
		
		/*List<AccountRecordTypes__c> accntRTList = new List<AccountRecordTypes__c>();
        AccountRecordTypes__c accntRType = new AccountRecordTypes__c();
        accntRType.Name='TL_SALES_ACCOUNT_RECORD_TYPE_ID';
        accntRType.RecordTypeID__c = Schema.SObjectType.Account.getRecordTypeInfosByName().get('T&L Sales Accounts').getRecordTypeId();
        accntRTList.add(accntRType);
        AccountRecordTypes__c accntRType1 = new AccountRecordTypes__c();
        accntRType1.Name='COMPETITOR_RECORD_TYPE_ID';
        accntRType1.RecordTypeID__c = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Competitor').getRecordTypeId();
        accntRTList.add(accntRType1);
        insert accntRTList;
		
		Account accnt = new Account();                                                             
        accnt.Name='Test Account';
        accnt.Primary_Business_Unit__c='Omnitracs Domestic';
        accnt.Account_Classification__c='Prospect';
        accnt.Account_Status__c='Active';
        accnt.phone='1234567890';
        accnt.QWBS_Status__c='Active';       
        accnt.RecordTypeId= accntRTList[0].RecordTypeID__c;         
        accnt.BillingStreet='Test St';
        accnt.BillingCity='Frisco';
        accnt.BillingState='TX';
        accnt.BillingCountry='USA';  
        insert accnt;         */       
        
        Account accnt = TestUtils.getAccount('Test Account');
		
		Contact cntct = TestUtils.getContact(accnt, 'Test Contact');
        
		insert cntct;
        
		Test.startTest();
        cntct.Survey_Email_Sent__c = true;
        update cntct;
		cntct.Survey_Initiated_By__c = newUser.Id;
		cntct.Survey_Email_Sent__c = false;
		update cntct;
		cntct.Survey_Email_Sent__c = true;
		update cntct;
		Test.stopTest();
		
		
		// TO DO: implement unit test
	}
	
	private static User getTestUser(String userName, String profileName)
    {
        String profileId;
        try
        {
            profileId = [SELECT Id FROM Profile WHERE Name like: '%'+profileName+'%' limit 1].Id;
        }
        catch(Exception ex)
        {
            System.debug(ex);
            System.assert(false, 'No profile exists with name '+ profileName);
        }
        User testUser = new User();
        testUser.LastName = 'test ' + UserName;
        testUser.Alias = UserName;  
        testUser.Email = UserName+'@example.com';
        testUser.Username = UserName+UserName+'@test.com';
        testUser.CommunityNickname = 'a'+UserName;
        testUser.TimeZoneSidKey = 'America/New_York';
        testUser.LocaleSidKey = 'en_US';
        testUser.EmailEncodingKey = 'ISO-8859-1';
        testUser.ProfileId = profileId;
        testUser.LanguageLocaleKey = 'en_US';
        testUser.IsActive = true;
        
        return testUser;    
    }
}