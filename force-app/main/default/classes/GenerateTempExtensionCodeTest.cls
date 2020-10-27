@isTest
(SeeAllData = true)Global class GenerateTempExtensionCodeTest {
	
	public static User createUser(){
		Profile p = [select id from profile where name = 'System Administrator'];
        User testUser = new User(alias = 'standt', email='standarduser@omnitracs.com',
                   emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',                
                   localesidkey='en_US',timezonesidkey='America/Los_Angeles',
                   username='standarduser111@omnitracs.com',ProfileId=p.Id);
        insert testUser;
		return testUser;
	}
	
	public static testmethod void testPopulated()
	{
		Account acct = GenericTestClass.insertAccount();
		Contact objcontact = GenericTestClass.insertContact(acct .Id);
		User testUser = createUser();
		
		
		ApexPages.StandardController stdTemp = new ApexPages.StandardController(acct);
		PageReference pageref = Page.GenerateTempExtensionCodePage;
		//************************************
		Test.startTest();
		//************************************
			acct.Alert_Text__c = 'Test Text';
			GenerateTempExtensionCodeExtension gtec = new GenerateTempExtensionCodeExtension(stdTemp);
			List <SelectOption>prodTypeTest = gtec.productTypes;
			gtec.licenseTask.whatId = objcontact.Id;
			List <SelectOption>acctContactTest = gtec .accountContacts;
			User testLoggedInUser = gtec.getLoggedInUser();
		
			gtec.loggedInUser = testUser;
			Account testGetAcct = gtec .getAccount();
			String pickListTest = gtec .pickListSelection;
			system.Test.setCurrentPageReference(pageref);
			GenerateTempExtensionCodeExtension.generateController(acct);
			gtec.isSelectingPicklist = true;
			gtec.pickListSelection = objcontact.Id;
			gtec.account = acct;
			gtec.account.alert_text__c = 'Test text';
			gtec.selectedProductType = 'RN';
		    gtec.cancel();
			gtec.sendEmail();
			gtec.updateAccountAlertText();
			gtec.createDigestAndSendEmail(acct, testUser);
		//************************************
		Test.stopTest();
		//************************************


		}
		public static testmethod void testNulls()
		{
			//Test converage for the myPage visualforce page
			//User objuser = GenericTestClass.insertUser(null, null);
			Account acct = GenericTestClass.insertAccount();
			Contact objcontact = GenericTestClass.insertContact(acct .Id);
			User testUser = createUser();
			
			
			ApexPages.StandardController stdTemp = new ApexPages.StandardController(acct);
			PageReference pageref = Page.GenerateTempExtensionCodePage;
			//************************************
			Test.startTest();
			//************************************
				GenerateTempExtensionCodeExtension gtec = new GenerateTempExtensionCodeExtension(stdTemp);
				List <SelectOption >prodTypeTest = gtec .productTypes;
				List <SelectOption >acctContactTest = gtec .accountContacts;
			
				gtec.pickListSelection = PL.none;
				gtec .account = acct;
				gtec .selectedProductType = '';
				gtec .licenseTask .Description = '';
				gtec .sendEmail();
			
				Account testGetAcct = gtec .getAccount();
				//acct.Clientele_ID__c = acct.Id;
				gtec.loggedInUser = testUser;
				gtec.licenseTask.whoId = objcontact.Id;
				gtec.isSelectingPicklist = false;
				String pickListTest = gtec .pickListSelection;
				system.Test.setCurrentPageReference(pageref);
				GenerateTempExtensionCodeExtension.generateController(acct);
				gtec .updateAccountAlertText();
				gtec.createDigestAndSendEmail(acct, testUser);
			//************************************
			Test.stopTest();
			//************************************


			}
		
			public static testmethod void testNullWhatId()
		{
			//Test converage for the myPage visualforce page
			//User objuser = GenericTestClass.insertUser(null, null);
			Account acct = GenericTestClass.insertAccount();
			Contact objcontact = GenericTestClass.insertContact(acct .Id);
			User testUser = createUser();
			String nullString = '';
			
			ApexPages.StandardController stdTemp = new ApexPages.StandardController(acct);
			PageReference pageref = Page.GenerateTempExtensionCodePage;
			//************************************
			Test.startTest();
			//************************************
				GenerateTempExtensionCodeExtension gtec = new GenerateTempExtensionCodeExtension(stdTemp);
				gtec.licenseTask.whatId = null;
				List <SelectOption >prodTypeTest = gtec .productTypes;
				List <SelectOption >acctContactTest = gtec .accountContacts;
				gtec.pickListSelection = PL.none;
				gtec.account.Alert_Text__c = 'Test Text';
				GenerateTempExtensionCodeExtension.isBlank(nullString);
				
				gtec.isSelectingPicklist = false;
				Account testGetAcct = gtec .getAccount();
				//acct.Clientele_ID__c = acct.Id;
				gtec.loggedInUser = testUser;
				system.Test.setCurrentPageReference(pageref);
				GenerateTempExtensionCodeExtension.generateController(acct);
				gtec .account = acct;
				gtec .selectedProductType = '';
				gtec .licenseTask .Description = '';
				gtec .sendEmail();
				gtec .updateAccountAlertText();
			//************************************
			Test.stopTest();
			//************************************


			}
		
	
		
			
		}