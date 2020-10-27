@isTest(seeAllData=true)
Public Class AccountTestDataPreparation{
    
  public Static Account objAccount = new Account();
  public Static Contact objContact = new Contact();
  public Static User partnerUser = new User();
  public Static User testUser = new User();
  public Static User testmasterpartnerUser = new User();
  public Static User interfaceTestUser = new User();
  public Static List<SIC__c> lsttestSIC = new List<SIC__c>();
  public Static List<Country_And_Country_Code__c> lsttestCountryAndCountryCode = new List<Country_And_Country_Code__c>();
  public Static List<Data_Sharing_Partner__c> lstDataSharingPartner = new List<Data_Sharing_Partner__c>();
  public Static PMOMarketRecordTypePair__c PMOMarketRecordTypePairInstance = new PMOMarketRecordTypePair__c();
  public Static Task testTaskOnAcccount = new Task();
  
  public static User createTestUser()
  {
    testUser.Username= 'test.user@omnitracs.com';
    testUser.Email = 'test.user@omnitracs.com';
    testUser.Lastname = 'User';
    testUser.Firstname = 'Test';
    testUser.Alias = 'tuser';
    testUser.UserRole = [ select id from userrole where Name ='QES Executives' ];
    Profile testProfile=[ select id from profile where Name = 'System Administrator' ];
    testUser.ProfileId= testProfile.id;
    testUser.TimeZoneSidKey = 'GMT';
    testUser.LocaleSidKey = 'en_US';
    testUser.EmailEncodingKey = 'ISO-8859-1';
    testUser.LanguageLocaleKey = 'en_US';
    
    try{
        insert testUser;
    }
    catch(Exception e){
        System.debug('test_user Insertion failed in createTestUser method, due to::'+e.getmessage());
        return null;
    }
    return testUser;
  }  
  
  public static User createTestmasterpartnerUser()
  {
    testmasterpartnerUser.Username= 'masterpartner.user@omnitracs.com';
    testmasterpartnerUser.Email = 'masterpartner.user@omnitracs.com';
    testmasterpartnerUser.Lastname = 'User';
    testmasterpartnerUser.Firstname = 'Test';
    testmasterpartnerUser.Alias = 'tuser';
    testmasterpartnerUser.UserRole = [ select id from userrole where Name ='QES Executives' ];
    Profile testProfile=[ select id from profile where Name = 'System Administrator' ];
    testmasterpartnerUser.ProfileId= testProfile.id;
    testmasterpartnerUser.TimeZoneSidKey = 'GMT';
    testmasterpartnerUser.LocaleSidKey = 'en_US';
    testmasterpartnerUser.EmailEncodingKey = 'ISO-8859-1';
    testmasterpartnerUser.LanguageLocaleKey = 'en_US';
    testmasterpartnerUser.Master_Partner_User__c = testUser.id;
    
    try{
        insert testmasterpartnerUser;
    }
    catch(Exception e){
        System.debug('test_masterpartnerUser Insertion failed in createTestmasterpartnerUser method, due to::'+e.getmessage());
        return null;
    }
    return testmasterpartnerUser;
  }  
  
  public static List<SIC__c> createTestSIC()
  {
    for(Integer i=0; i<2; i++)
    {
        SIC__c testSIC = new SIC__c();
        
        testSIC.Name = 'Test SIC'+i;
        testSIC.CurrencyIsoCode = 'USD';
        // test the scenario when Description General, Description Detailed and Reporting fields are blank
        if(i==0){
            testSIC.Description_Detailed__c = null;
            testSIC.Description_General__c = null;
            testSIC.Reporting__c = null;
        }
        // test the scenario when Description General, Description Detailed and Reporting fields are having values
        if(i==1){
            testSIC.Description_Detailed__c = 'Test SIC Detailed Description';
            testSIC.Description_General__c = 'Test SIC General Description';
            testSIC.Reporting__c = 'Test SIC Report';
        }        
        lsttestSIC.add(testSIC);        
    }
    try{
        insert lsttestSIC;
    }
    catch(Exception e){
        System.debug('test_SIC resord Insertion failed in createTestSIC method, due to::'+e.getmessage());
        return null;
    }
    return lsttestSIC; 
  }
  
  public Static List<Country_And_Country_Code__c> createCountryAndCountryCode(){  
      for(Integer i=0; i<2; i++){
          Country_And_Country_Code__c tstCountryAndCountryCode = new Country_And_Country_Code__c();
          if(i == 0)
              tstCountryAndCountryCode.Name = 'India';
          else{
              tstCountryAndCountryCode.Name = 'USA';
          }
          tstCountryAndCountryCode.CurrencyIsoCode = 'USD';
          
          lsttestCountryAndCountryCode.add(tstCountryAndCountryCode);
      }
      try{
            insert lsttestCountryAndCountryCode;
      }
      catch(Exception e){
            System.debug('test_CountryAndCountryCode resord Insertion failed in createCountryAndCountryCode method, due to::'+e.getmessage());
            return null;
        }
        return lsttestCountryAndCountryCode;
   }
  
    Public static Account createTestAccount()
    {   
        objAccount.Name='Test AccountName';
        objAccount.Phone='324324324';
        //objAccount.District__c='Strategic';
        objAccount.BillingStreet='Test Billing Street';
        objAccount.BillingCity='Test Billing City';
        objAccount.BillingCountry='Test Billing Country';
        objAccount.BillingState = 'Test Billing State';
        objAccount.BillingpostalCode = '75035';
        objAccount.fleet_size__c = 75;
        objAccount.Segment__c = 'TL';
        objAccount.Primary_Business_Unit__c='RoadNet';
        objAccount.Account_Classification__c='Prospect';
        objAccount.Account_Status__c='Active';
        objAccount.Roadnet_Market__c = 'Test';
        objAccount.RecordTypeId=Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Partner').getRecordTypeId();
        objAccount.AGUID__c = 'Test AGUID';
        
        try{
            insert objAccount;
        }
        catch(Exception e){
            System.debug('test_Account creation failed in createTestAccount method, due to::'+e.getmessage());
            return null;
        }
        return objAccount;
    }
    
    Public static Contact createTestContact(Account tstAcc)
    {
        //Contact objContact = new Contact();
            
        objContact.AccountId=tstAcc.id;
        objContact.RecordTypeId=Schema.Sobjecttype.Contact.getRecordTypeInfosByName().get('Sales').getRecordTypeId();
        objContact.LastName='Test Contact';
        objContact.Title='Test Title';
        objContact.Phone='(123)465-7890';
        objContact.Decision_Maker_Influencer__c='Yes';        
        objContact.LeadSource='800#';
        objContact.Lead_Origin__c='XRS';
        objContact.Notification_Type__c='SSO Portal Administrator';

        try{
            insert objContact;
        }
        catch(Exception e){
            System.debug('test_Contact creation failed in createTestContact method, due to::'+e.getmessage());
            return null;
        }
        return objContact;
    }
    
    Public static User createTestpartnerUser(Contact tstCntc)
    {   
        //User partnerUser = new User(); 
        
        partnerUser.Username = 'partner.user@omnitracs.com';
        partnerUser.Email = 'partner.user@omnitracs.com';
        partnerUser.Lastname = 'User';
        partnerUser.Firstname = 'Partner';
        partnerUser.Alias = 'puser';
        partnerUser.UserRole = [ select id from userrole where Name ='QES Executives' ];
        Profile testProfile = [ select id from profile where Name = 'Reseller Partner Profile (No MDF)' ];
        partnerUser.ProfileId = testProfile.id;
        partnerUser.TimeZoneSidKey = 'GMT';
        partnerUser.LocaleSidKey = 'en_US';
        partnerUser.EmailEncodingKey = 'ISO-8859-1';
        partnerUser.LanguageLocaleKey = 'en_US';
        partnerUser.Lead_Reassignment_Role__c = 'Inside Sales Rep';
        partnerUser.ContactId = tstCntc.id;
    
        try{
            insert partnerUser;
        }
        catch(Exception e){
            System.debug('test_partneruser creation failed in createTestpartnerUser method, due to::'+e.getmessage());
            return null;
        }
        return partnerUser;
     }
   public static User createTestinterfaceUser()
  {
    interfaceTestUser.Username= 'testinterface.user@omnitracs.com';
    interfaceTestUser.Email = 'testinterface.user@omnitracs.com';
    interfaceTestUser.Lastname = 'User';
    interfaceTestUser.Firstname = 'interface';
    interfaceTestUser.Alias = 'iuser';
    interfaceTestUser.UserRole = [ select id from userrole where Name ='QES Executives' ];
    Profile testProfile=[ select id from profile where Name = 'Interface User' ];
    interfaceTestUser.ProfileId= testProfile.id;
    interfaceTestUser.TimeZoneSidKey = 'GMT';
    interfaceTestUser.LocaleSidKey = 'en_US';
    interfaceTestUser.EmailEncodingKey = 'ISO-8859-1';
    interfaceTestUser.LanguageLocaleKey = 'en_US';
    
    try{
        insert interfaceTestUser;
    }
    catch(Exception e){
        System.debug('testinterface_user Insertion failed in createTestUser method, due to::'+e.getmessage());
        return null;
    }
    return interfaceTestUser;
  }  

    Public Static List<Data_Sharing_Partner__c> createDataSharingPartners(Account objTstAccount)
    { 
        for(Integer i=0;i<2 ;i++)
        { 
            Data_Sharing_Partner__c objDataSharePartner = new Data_Sharing_Partner__c();
            
            objDataSharePartner.Name ='Test Data Share Partner'+i;     
            objDataSharePartner.CurrencyIsoCode = 'USD';
            
            if(i==1)
            objDataSharePartner.Related_Account__c = objTstAccount.id;
            
            lstDataSharingPartner.add(objDataSharePartner);
        }
        Try
        {
            Insert lstDataSharingPartner; 
        }
        Catch(Exception e)
        {
            System.debug('test_DataSharingPartner Insertion failed in createDataSharingPartners method, due to::'+e.getmessage());
            return null;
        }
        return lstDataSharingPartner;
    }
    
    Public Static void CustomSettingDataInsertion(String QWBSMarket)
    {          
        PMOMarketRecordTypePairInstance.Name ='Test PMOMarketRecordTypePair';
        PMOMarketRecordTypePairInstance.Market_Name__c = QWBSMarket;
        PMOMarketRecordTypePairInstance.Record_Type_Id__c = AccountRecordTypes__c.getInstance('TL_SALES_ACCOUNT_RECORD_TYPE_ID').RecordTypeID__c;

        Try
        {
            Insert PMOMarketRecordTypePairInstance; 
        }
        Catch(Exception e)
        {
            System.debug('test_PMOMarketRecordTypePair Insertion failed in CustomSettingDataInsertion method, due to::'+e.getmessage());
        }

    }

    Public Static void CreateTaskonTestAccount(Account testAcc)
    {          
        testTaskOnAcccount.Type = 'Other';
        testTaskOnAcccount.Description = 'Task on Test Account'; 
        testTaskOnAcccount.OwnerId = userinfo.getuserId();
        testTaskOnAcccount.WhatId = testAcc.id;
        testTaskOnAcccount.Status = 'In Progress';
        testTaskOnAcccount.Subject = 'Test Subject';
        
        Try
        {
            Insert testTaskOnAcccount; 
        }
        Catch(Exception e)
        {
            System.debug('test_PMOMarketRecordTypePair Insertion failed in CustomSettingDataInsertion method, due to::'+e.getmessage());
        }

    }
}