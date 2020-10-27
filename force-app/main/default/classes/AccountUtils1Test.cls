@isTest(seeAllData=true)
Private Class AccountUtils1Test{
  static User testUser = AccountTestDataPreparation.createTestUser();
  static List<SIC__c> lsttestSIC = AccountTestDataPreparation.createTestSIC();
  static List<Country_And_Country_Code__c> lsttestCountryAndCountryCode = AccountTestDataPreparation.createCountryAndCountryCode();
  static Account objTstAccount = AccountTestDataPreparation.createTestAccount();
  static Contact objTstContact = AccountTestDataPreparation.createTestContact(objTstAccount);
  static User partnerUser = AccountTestDataPreparation.createTestpartnerUser(objTstContact);
  static List<Data_Sharing_Partner__c> lsttestDataSharingPartner = AccountTestDataPreparation.createDataSharingPartners(objTstAccount);

  Static testMethod void calDataQultyScorAndChngCntcStasAndChngRcdTypAndCalSumOpnActvt_test(){
    
    Integer Count = 0;
    
    
                /*  @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ INSERT @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@   */
                
    test.startTest();       
    System.runAs(testUser)
    {  
      System.debug('@@@@ test user details::'+testUser);
      List<Account> lstAccount = new List<Account>();
      List<Contact> lstContact = new List<contact>();
      List<Opportunity> lstOpportunity = new List<Opportunity>();
      //Code unit for calculateDataQualityScore STARTED
      for(Integer i=0; i<3; i++){
          Account testAccount = new Account();
          
          testAccount.Name = 'Arindam Test Account'+Count;
          testAccount.recordTypeId = AccountRecordTypes__c.getInstance('TL_SALES_ACCOUNT_RECORD_TYPE_ID').RecordTypeID__c;
          testAccount.BillingStreet = 'Test Billing Street';
          testAccount.phone = '(888) 888-8888';
          testAccount.Account_Type__c = null;
          testAccount.QWBS_Market__c = 'T&L';
          //testAccount.District__c = null;
          testAccount.QWBS_Status__c = null;
          testAccount.Lead_Source__c = null;
          testAccount.Average_Length_of_Haul__c = null;
          testAccount.Regional_Vehicles__c = 12345;
       // testAccount.OTR_Vehicles__c = 12345;
          testAccount.Primary_Business__c = null;
       // testAccount.Primary_Commodity__c = null;
          testAccount.Contract_Comments__c = 'Test Comment';
          testAccount.Contract_Expiration__c = Date.today();
          testAccount.Computer_Platform__c = null;   
          testAccount.Primary_Business_Unit__c = null;
          testAccount.Account_Classification__c = 'Customer';
          testAccount.Account_Status__c = 'Active';
          testAccount.Closed_Reason__c = null;
          testAccount.cargo_Type__c = 'BEVERAGES';
          testAccount.segment__c = 'TL';
          
          if(i>=1 && i<2){
              //testAccount.QWBS_Status__c = AccountsDataQualityScoreAndDescription__c.getInstance('AccountUtils').EVAL_CUSTOMERS__c;
              testAccount.QWBS_Status__c = AllAccountUtils__c.getInstance('EVAL_CUSTOMERS').Value__c;
              testAccount.QWBS_Cust_ID__c = '0123456789'+Count;
              testAccount.cargo_Type__c = 'MEAT';
          }
          if(i>=2){
              //testAccount.QWBS_Status__c = AccountsDataQualityScoreAndDescription__c.getInstance('AccountUtils').CONTRACT_CUSTOMER__c;
              testAccount.QWBS_Status__c = AllAccountUtils__c.getInstance('CONTRACT_CUSTOMER').Value__c;
              testAccount.QWBS_Cust_ID__c = '0123456789'+Count;
              testAccount.cargo_Type__c = 'HOUSEHOLD';
          }
          lstAccount.add(testAccount);
          Count++;
      }           
      for(Integer i=0; i<1; i++){
          Account testAccount = new Account();
          
          testAccount.Name = 'Arindam Test Account'+Count;
          //AccountRecordTypes__c.getInstance('TL_SALES_ACCOUNT_RECORD_TYPE_ID').RecordTypeID__c = '01250000000DQBA';
          //AllAccountUtils__c.getInstance('QWBS_MARKET').Value__c = 'T&L';
          testAccount.recordTypeId = AccountRecordTypes__c.getInstance('TL_SALES_ACCOUNT_RECORD_TYPE_ID').RecordTypeID__c;      
          //testAccount.QWBS_Market__c = AccountsDataQualityScoreAndDescription__c.getInstance('AccountUtils').QWBS_MARKET__C;
          testAccount.QWBS_Market__c = AllAccountUtils__c.getInstance('QWBS_MARKET').Value__c;
          testAccount.QWBS_Status__c = null;
          testAccount.of_Locations__c = 12345;
          testAccount.Account_Manager__c = testUser.Id;
          testAccount.Account_Type__c = null;
          testAccount.BillingStreet = 'Test Billing Street';
          testAccount.BillingCity = 'Test Billing City';
          testAccount.BillingState = 'Test Billing State';
          testAccount.BillingCountry = lsttestCountryAndCountryCode[0].Name;
          testAccount.BillingPostalCode = '123456';
          testAccount.ShippingStreet = 'Test Shipping Street';
          testAccount.ShippingCity = 'Test Shipping City';
          testAccount.ShippingState = 'Test Shipping State';
          testAccount.ShippingCountry = 'India';
          testAccount.ShippingPostalCode = '123456';
          testAccount.Computer_Platform__c = null;
          testAccount.QWBS_Cust_ID__c = null;
          testAccount.CSR__c = testUser.Id;
          //testAccount.District__c = null;
       // testAccount.Dollies__c = 12345;
       // testAccount.Dry_Vans__c = 12345;
          testAccount.Fax = null;
       // testAccount.Flatbeds__c = 12345;
          testAccount.Lead_Source__c = null;
          testAccount.phone = '(888) 888-8888';
          testAccount.Primary_Business__c = null;
      //  testAccount.Primary_Commodity__c = null;
          testAccount.Ranking__c = null;         
       // testAccount.OBC__c = 12345;
       // testAccount.OEM_Tractor__c = null;
       // testAccount.OEM_Reefer_Trailer__c = null;
       // testAccount.OTR_Vehicles__c = 12345;
       // testAccount.Reefers__c = 12345;
          testAccount.Regional_Vehicles__c = 12345;
          testAccount.RFC_ID__c = null;
       // testAccount.Tankers__c = 12345;
      	  //testAccount.TrailerTRACS__c = 12345;         
          testAccount.Account_Classification__c = 'Customer';
          lstAccount.add(testAccount);
          Count++;
          AllAccountUtils.getStateCode('teststate');
      }      
      for(Integer i=0; i<3; i++){
          Account testAccount = new Account();
          
          testAccount.Name = 'Arindam Test Account'+Count;
          testAccount.recordTypeId = AccountRecordTypes__c.getInstance('GSS_ACCOUNT_RECORD_TYPE_ID').RecordTypeID__c;
          testAccount.Account_Type__c = null;         
          testAccount.Fax = null;
          testAccount.BillingCountry = lsttestCountryAndCountryCode[0].Name;
          testAccount.Ranking__c = null;
          testAccount.Product_Interest__c = null;
      //  testAccount.Feature_Interest__c = null;          
          testAccount.BillingStreet = 'Test Billing Street';
          testAccount.phone = '(888) 888-8888';
      //  testAccount.Device_Supplier__c = null;
      //  testAccount.Asset_Value_Range__c = null;
      //  testAccount.Service_Model__c = null;
      //  testAccount.Number_of_Enabled_Devices__c = 12345;
      //  testAccount.Dealer__c = null;
      //  testAccount.Account_Classification__c = 'Customer';
          
          //if(i>=1 && i<2)
          //    testAccount.District__c = 'ORMM OEM';
          //if(i>=2)
          //    testAccount.District__c = 'North';
              
          lstAccount.add(testAccount);
          Count++;
      }
      //following records are being inserted to verify 'ChangeContactStatus' functionality
      for(Integer i=0; i<4; i++){
          Account testAccount = new Account();
          
          testAccount.Name = 'Arindam Test Account'+Count;
          testAccount.recordTypeId = AccountRecordTypes__c.getInstance('TL_SALES_ACCOUNT_RECORD_TYPE_ID').RecordTypeID__c;
          testAccount.Phone = '(888) 888-8888';
          testAccount.QWBS_Status__c = 'Active';
          testAccount.QWBS_Cust_ID__c = '0123456789'+Count;
          testAccount.Account_Status__c = 'Active';
          testAccount.Primary_Business_Unit__c = null;
          testAccount.Closed_Reason__c = null;
          testAccount.Account_Classification__c = 'Prospect';
          
          lstAccount.add(testAccount);
          Count++;
      }
        Allaccountutils.populateDataSharePartners(lstAccount);
        
          
      try{
          insert lstAccount;
      }
      catch(Exception e){
          System.debug('Account Insertion failed in calculateDataQualityScore_test method, due to::'+e.getmessage());
      }
      
            /*  @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ Create Contact&Opportunity @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@   */
      //Following records are being created to verify 'ChangeContactStatus' functionality      
      List<Contact> lstAccContact = new List<Contact>();
      for(Integer i=7;i<10;i++)
      {
        Contact objContact = new Contact();
        Opportunity objOpportunity = new Opportunity();
        
        objContact.AccountId=lstAccount[i].id;
        objContact.RecordTypeId=Schema.Sobjecttype.Contact.getRecordTypeInfosByName().get('Sales').getRecordTypeId();
        objContact.LastName='Test Contact'+i;
        objContact.Title='Test Title'+1;
        objContact.Phone='(123) 465-7890';
        objContact.Decision_Maker_Influencer__c='Yes';        
        objContact.LeadSource='800#';
        objContact.Lead_Origin__c='XRS';
        objContact.Notification_Type__c='test';
        
        lstContact.add(objContact);
        if(i==8)
        {      
            objOpportunity.Name = 'Test Opportunity'+i;
            objOpportunity.AccountId = lstAccount[i].id;
            objOpportunity.RecordTypeId = Schema.Sobjecttype.Opportunity.getRecordTypeInfosByName().get('Products, Services and Maintenance').getRecordTypeId();
            objOpportunity.Reason_Lost__c = null;
            objOpportunity.Reason_Lost_Comments__c = null;
            objOpportunity.StageName = 'test';
            Date myDate = date.valueOf('2016-04-29');
            objOpportunity.CloseDate = myDate;
                    
            lstOpportunity.add(objOpportunity);
        }
      }
      try{
            insert lstContact;
            insert lstOpportunity;
        }
        catch(Exception e){
            System.debug('Contact or Opportunity Insertion failed in calculateDataQualityScore_test method, due to::'+e.getmessage());
        }
        
         /* @@@@@@@@@@@@@@@@@@@@@@@@@@@@@ Inserted Data Validation @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@   */ 
          
       List<Id> lstAllTestAccountId = new List<Id>();  
       for(Account objTestAccount:lstAccount)
       {
           lstAllTestAccountId.add(objTestAccount.Id);
       }
       
       List<Account> lstAllTestAccount = [SELECT Name, recordTypeId,Data_Quality_Description_Apex__c, Data_Quality_Score_Apex__c,  
                                          Sum_of_Open_Activities__c from Account WHERE id in: lstAllTestAccountId];  
                                                       
       for(Account objTestAccount:lstAllTestAccount)
       {   

           if(objTestAccount.Name == 'Arindam Test Account3'){
                System.assertEquals(0, objTestAccount.Sum_of_Open_Activities__c);
                
           }
           if(objTestAccount.Name == 'Arindam Test Account4'){
                System.assertEquals(null, objTestAccount.Data_Quality_Description_Apex__c);
           }

       } 
             
            /*  @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ UPDATE @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@   */
            
        for(Account objAccount:lstAccount){
        
           if(objAccount.Name == 'Arindam Test Account3')
           {
               //create task to calculate Sum_of_Open_Activities__c
                CalculateSumOfOpenActivities.firstRun = true;                                                 
                AccountTestDataPreparation.CreateTaskonTestAccount(objAccount);
               //inserting record into 'PMOMarketRecordTypePair__c' custom setting to verify the record change
               AccountTestDataPreparation.CustomSettingDataInsertion(objAccount.QWBS_Market__c);
           }
           if(objAccount.Name == 'Arindam Test Account7')
           {
                //if status is closed then 
                //Respective Contacts' Owner and 'Notification_Type__c' will change
                objAccount.QWBS_Status__c = 'Inactive Prospect';
           }
           if(objAccount.Name == 'Arindam Test Account8')
           {
               //if status is closed and recordType is TL or Partner
               //Corresponding Account's 'Closed_Reason__c' will be coppied to
               //Respective Opportunity's 'Reason_Lost__c' & 'Reason_Lost_Comments__c' field
               objAccount.recordTypeId = AccountRecordTypes__c.getInstance('PRTNR_ACNT_RESELLR_RCRD_TYPE_ID').RecordTypeID__c;
               objAccount.QWBS_Status__c = 'Inactive Prospect';
               objAccount.Closed_Reason__c = 'Price';
           }
           if(objAccount.Name == 'Arindam Test Account9')
           {
               objAccount.QWBS_Status__c = 'Active';
               //if Account 'Closed_Reason__c' is Out of Business
               //Respective Contacts will be inactivated
               //objAccount.Closed_Reason__c = AccountsDataQualityScoreAndDescription__c.getInstance('AccountUtils').CLSD_RSN_OUT_OF_BUS__c;
               objAccount.Closed_Reason__c = AllAccountUtils__c.getInstance('CLSD_RSN_OUT_OF_BUS').Value__c;

           }
           if(objAccount.Name == 'Arindam Test Account10')
           {
               //if Account Recordtype is Out of Business
               //Status is 'Inactive', District__c is 'Service Center',QWBS_Market__c is 'Service Center'
               //Respective Contacts will be inactivated
               objAccount.QWBS_Status__c = 'InActive';
               objAccount.QWBS_Market__c = 'Service Center';
               //objAccount.District__c = 'Service Center';
               objAccount.recordTypeId = AccountRecordTypes__c.getInstance('OTHER_ACCOUNT_RECORD_TYPE_ID').RecordTypeID__c;
               objAccount.Closed_Reason__c = 'Price';
           }
           
          //update data score to 100 %
           /*if(objAccount.District__c == 'North'){
              System.debug('@@@@Name of Account:'+objAccount.Name);
              objAccount.District__c = 'ORMM OEM';
              objAccount.Account_Type__c = 'OEM';      
              objAccount.Fax = '12345';
              objAccount.BillingCountry = lsttestCountryAndCountryCode[0].Name;
              objAccount.Ranking__c = 'SAM';
              objAccount.Product_Interest__c = 'OM - Spy';
           // objAccount.Feature_Interest__c = 'Integration';       
              objAccount.BillingStreet = 'Test Billing Street';
              objAccount.phone = '0123456789';
          //  objAccount.Dealer__c = lstAccount[0].Id;
          }*/
       } 
       try{
           update lstAccount;
       }
       catch(Exception e){
        System.debug('Account Updation failed in calculateDataQualityScore_test method, due to::'+e.getmessage());
       }
       test.stopTest();
          /* @@@@@@@@@@@@@@@@@@@@@@@@@@@@@ Updated Data Validation @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@   */
       //Account data Validation Starts 
       List<Id> lstAllUpdatedTestAccountId = new List<Id>();   
       for(Account objTestAccount:lstAccount)
       {
           lstAllUpdatedTestAccountId.add(objTestAccount.Id);
       }
       
       List<Account> lstAllUpdatedTestAccount = [SELECT Name, recordTypeId,Data_Quality_Description_Apex__c, Data_Quality_Score_Apex__c,  
                                                 Sum_of_Open_Activities__c from Account WHERE id in: lstAllUpdatedTestAccountId];  
                                                       
       for(Account objTestAccount:lstAllUpdatedTestAccount)
       {   
           if(objTestAccount.Name == 'Arindam Test Account3'){
                //Record type will be changed as per 'changeRecordType' functionality
                //Record type will change based on 'QWBS_Market__c' field
                objTestAccount.recordTypeId = AccountRecordTypes__c.getInstance('TL_SALES_ACCOUNT_RECORD_TYPE_ID').RecordTypeID__c;
                System.assertEquals(AccountRecordTypes__c.getInstance('TL_SALES_ACCOUNT_RECORD_TYPE_ID').RecordTypeID__c, objTestAccount.recordTypeId);
                //Sum_of_Open_Activities__c will increase from 0 to 1
                //as an open task had created on this account 
                //System.assertEquals(0, objTestAccount.Sum_of_Open_Activities__c);
           }
           
       }//Account data Validation Ends
       //Contact data Validation Starts
       List<Id> lstAllUpdatedTestContactId = new List<Id>();       
       for(Contact objTestContact:lstContact)
       {
           lstAllUpdatedTestContactId.add(objTestContact.Id);
       }
       List<Contact> lstAllUpdatedTestContact = [SELECT LastName, Notification_Type__c, OwnerId, Inactive__c
                                                 from Contact WHERE id in: lstAllUpdatedTestContactId];
                                                 
       for(Contact objTestContact:lstAllUpdatedTestContact)
       {
           if(objTestContact.LastName == 'Test Contact7')
           {   
               //OwnerId and Notification_Type__c have change
               //System.assertEquals(MarketingAdmin__c.getInstance().Marketing_Admin_User__c,objTestContact.OwnerID);
               System.assertEquals('test',objTestContact.Notification_Type__c);
           }
           if(objTestContact.LastName == 'Test Contact9')
           {
               //Contact has been inactivated
               objTestContact.Inactive__c = true;
               System.assertEquals(true,objTestContact.Inactive__c);
           }
           if(objTestContact.LastName == 'Test Contact10')
           {
               //Contact has been inactivated
               System.assertEquals(true,objTestContact.Inactive__c);
           }
       }//Contact data Validation Ends
       //Opportunity data Validation Starts
       List<Id> lstAllUpdatedTestOpportunityId = new List<Id>();       
       for(Opportunity objTestOpportunity:lstOpportunity)
       {
           lstAllUpdatedTestOpportunityId.add(objTestOpportunity.Id);
       }
       List<Opportunity> lstAllUpdatedTestOpportunity = [SELECT Name, Reason_Lost__c, Reason_Lost_Comments__c
                                                         from Opportunity WHERE id in: lstAllUpdatedTestOpportunityId];
                                                 
       for(Opportunity objTestOpportunity:lstAllUpdatedTestOpportunity)
       {
           if(objTestOpportunity.Name == 'Test Opportunity8')
           {   
               //OwnerId and Notification_Type__c have change
               objTestOpportunity.Reason_Lost__c = 'Price';
               System.assertEquals('Price',objTestOpportunity.Reason_Lost__c);
               objTestOpportunity.Reason_Lost_Comments__c = 'Price';
               System.assertEquals('Price',objTestOpportunity.Reason_Lost_Comments__c);
           }
       }//Opportunity data Validation Ends    
   
     }
  }	  	  
  
  Static testMethod void updateSICCodeAndManualAssigmnetAndDatashare_test(){    
    Integer Count = 0;
    List<Id> lstAllTestAccountId = new List<Id>();
    List<Id> lstAllUpdatedTestAccountId = new List<Id>();
    
    test.startTest();       
    System.runAs(testUser)
    {
      System.debug('@@@@ test user details::'+testUser);
      System.debug('@@@@ test account details::'+objTstAccount.Id);
      List<Account> lstAccount = new List<Account>();

      for(Integer i=0; i<4; i++){
          Account testAccount = new Account();
          
          testAccount.Name = 'Arindam Test Account'+Count;
          testAccount.recordTypeId = AccountRecordTypes__c.getInstance('TL_SALES_ACCOUNT_RECORD_TYPE_ID').RecordTypeID__c;
          testAccount.phone = '(888) 888-8888';
          testAccount.Account_Classification__c = 'Customer';
          testAccount.Account_Status__c = 'Active';
          testAccount.Ranking__c = 'Test Rank';
          testAccount.RFC_ID__c = 'Test RFC'+Count;
          //testAccount.District__c = 'ORMM OEM';
          
          // test scenario: if sic_code__c presentes in SIC__c object
          if(i==0){
              testAccount.sic_code__c = lsttestSIC[1].Name;
              testAccount.Primary_Business_Unit__c = 'Omnitracs Mexico';            
          }
          // test scenario: if sic_code__c does not presentes in SIC__c object
          else if(i==1){
              testAccount.sic_code__c = 'ArindamSIC';
              testAccount.Primary_Business_Unit__c = 'Sylectus';
          }
          // test scenario: if sic_code__c is null
          else if(i==2){
              testAccount.sic_code__c = null;
              testAccount.Primary_Business_Unit__c = 'Roadnet';
          }
          /* test scenario: if sic_code__c presentes in SIC__c object
                            Details fields of Account in not null
                            Detail fields of SIC__c object is null 
          */                            
          else{
              testAccount.sic_code__c = lsttestSIC[0].Name;
              testAccount.SIC_Description_General__c = 'Test SIC_Description_General';
              testAccount.SIC_Description_Detailed__c = 'Test SIC_Description_Detailed';
              testAccount.SIC_Reporting_Description__c = 'Test SIC_Reporting_Description';
              testAccount.Primary_Business_Unit__c = 'Omnitracs Domestic';

          }
          lstAccount.add(testAccount);
          Count++;
      }
      try{
        insert lstAccount;
      }
      catch(Exception e){
        System.debug('Account Insertion failed in updateSICCodeAndDatashare_test method, due to::'+e.getmessage());
      }
              /* @@@@@@@@@@@@@@@@@@@@@@@@@@@@@ Inserted Data Validation @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@   */
              
      for(Account objTestAccount:lstAccount)
      {
          lstAllTestAccountId.add(objTestAccount.Id);
        
      }
      
      List<Account> lstAllTestAccount = [SELECT Name, recordTypeId,sic_code__c, SIC_Description_General__c,
                                         Data_Share_Partner__c, SIC_Description_Detailed__c, SIC_Reporting_Description__c, Manual_Assignment__c
                                         from Account WHERE id in: lstAllTestAccountId];
                                        
      for(Account objTestAccount:lstAllTestAccount)
      {                                  
        if(objTestAccount.Name == 'Arindam Test Account0'){
           System.debug('Inside Arindam Test Account0');
           objTestAccount.SIC_Description_General__c = 'Test SIC General Description';
           System.assertEquals('Test SIC General Description', objTestAccount.SIC_Description_General__c);
           objTestAccount.SIC_Description_Detailed__c = 'Test SIC Detailed Description';
           System.assertEquals('Test SIC Detailed Description', objTestAccount.SIC_Description_Detailed__c);
           objTestAccount.SIC_Reporting_Description__c = 'Test SIC Report';
           System.assertEquals('Test SIC Report', objTestAccount.SIC_Reporting_Description__c);
           System.assertEquals(true, objTestAccount.Manual_Assignment__c);
        }
        if(objTestAccount.Name == 'Arindam Test Account1'){
           System.debug('Inside Arindam Test Account1');
           System.assertEquals(null, objTestAccount.SIC_Description_General__c);
        }
        if(objTestAccount.Name == 'Arindam Test Account3'){
           System.debug('Inside Arindam Test Account3'); 
           objTestAccount.SIC_Description_General__c = null;
           System.assertEquals(null, objTestAccount.SIC_Description_General__c);
           System.assertEquals(false, objTestAccount.Manual_Assignment__c);
        }
      }  
               /*  @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ UPDATE @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@   */
               
          for(Account objAccount:lstAccount){
          //Update Description General, Description Detailed and Reporting fields
          if(objAccount.sic_code__c == lsttestSIC[0].Name)
             objAccount.sic_code__c = lsttestSIC[1].Name; 
                       
          //Update'Manual_Assignment__c' check box   
          if(objAccount.Primary_Business_Unit__c == 'Omnitracs Domestic')
              objAccount.Primary_Business_Unit__c = 'Omnitracs Mexico';         //check the 'Manual_Assignment__c' check box              
          if(objAccount.Primary_Business_Unit__c == 'Sylectus')
              objAccount.Primary_Business_Unit__c = 'Omnitracs Domestic';       //Uncheck the 'Manual_Assignment__c' check box               
          if(objAccount.Primary_Business_Unit__c == 'Roadnet') 
              objAccount.Primary_Business_Unit__c = 'Omnitracs Mexico';         // no change in 'Manual_Assignment__c' checkbox              
          if(objAccount.Primary_Business_Unit__c == 'Omnitracs Mexico') 
              objAccount.Primary_Business_Unit__c = 'Omnitracs Mexico';         // no change in 'Manual_Assignment__c' checkbox                     
            
          // Referral_Account__c field is blank 
          if(objAccount.Name == 'Arindam Test Account0'){
              objAccount.Referral_Account__c = null;
              objAccount.Data_Share_Partner__c = null;
              objAccount.Lead_Source_Most_Recent__c = 'Other';
              objAccount.Lead_Source__c = null;              
          }
          // Referral_Account__c field is containing Test Account   
          if(objAccount.Name == 'Arindam Test Account1'){
              objAccount.Referral_Account__c = objTstAccount.Id;
              objAccount.Data_Share_Partner__c = null;
              objAccount.Lead_Source_Most_Recent__c = 'Test Lead source';
              objAccount.Lead_Source__c = 'Other';
              objAccount.Lead_Source_Update_Date__c = null;
          }
          // Referral_Account__c field is null
          // but Data_Share_Partner__c field is containing Test Data Sharing Partner
          if(objAccount.Name == 'Arindam Test Account2'){
              objAccount.Referral_Account__c = null;
              objAccount.Data_Share_Partner__c = lsttestDataSharingPartner[1].id;
              objAccount.Lead_Source_Most_Recent__c = null;
              objAccount.Lead_Source__c = 'Other';
          }
          /* test scenario: Referral_Account__c field is containing Test Account
                            Data_Share_Partner__c field is also containing Test Data Sharing Partner */                            
          if(objAccount.Name == 'Arindam Test Account3'){
              objAccount.Referral_Account__c = objTstAccount.Id;
              objAccount.Data_Share_Partner__c = lsttestDataSharingPartner[0].id;
              objAccount.Lead_Source_Most_Recent__c = null;
              objAccount.Lead_Source__c = null;
          }  
          
      }
      try{
          update lstAccount;
      }
      catch(Exception e){
        System.debug('Account Updation failed in updateSICCodeAndDatashare_test method, due to::'+e.getmessage());
      }
      
             /* @@@@@@@@@@@@@@@@@@@@@@@@@@@@@ Updated Data Validation @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@   */
              
      for(Account objTestAccount:lstAccount)
      {
          lstAllUpdatedTestAccountId.add(objTestAccount.Id);
        
      }
      
      List<Account> lstAllUpdatedTestAccount = [SELECT Name, recordTypeId,sic_code__c, SIC_Description_General__c,
                                                Data_Share_Partner__c, Lead_Source__c, Lead_Source_Most_Recent__c,  
                                                SIC_Description_Detailed__c, SIC_Reporting_Description__c, Manual_Assignment__c, 
                                                Primary_Business_Unit__c from Account WHERE id in: lstAllUpdatedTestAccountId];
                                        
      for(Account objTestAccount:lstAllUpdatedTestAccount)
      { 
       
        if(objTestAccount.Name == 'Arindam Test Account0'){
            System.debug('Inside Arindam Test Account0');
            System.assertEquals(null, objTestAccount.Data_Share_Partner__c);
            System.debug('objTestAccount.Lead_Source_Most_Recent__c'+objTestAccount.Lead_Source_Most_Recent__c);
            System.debug('objTestAccount.Lead_Source__c'+objTestAccount.Lead_Source__c);
            System.assertEquals('Other', objTestAccount.Lead_Source_Most_Recent__c);
            objTestAccount.Lead_Source__c = 'Other';
            System.assertEquals('Other', objTestAccount.Lead_Source__c);            
          }
                                      
        if(objTestAccount.Name == 'Arindam Test Account1'){
           System.debug('Inside Arindam Test Account1');
           objTestAccount.Manual_Assignment__c = false;
           System.assertEquals(false, objTestAccount.Manual_Assignment__c);
           objTestAccount.Data_Share_Partner__c = lsttestDataSharingPartner[1].Id;
           System.assertEquals(lsttestDataSharingPartner[1].Id, objTestAccount.Data_Share_Partner__c);
           System.assertEquals('Test Lead source', objTestAccount.Lead_Source_Most_Recent__c);
           System.assertEquals('Other', objTestAccount.Lead_Source__c);
        }
        if(objTestAccount.Name == 'Arindam Test Account2'){
           System.debug('Inside Arindam Test Account2'); 
           System.assertEquals(true, objTestAccount.Manual_Assignment__c);
           System.assertEquals(lsttestDataSharingPartner[1].Id, objTestAccount.Data_Share_Partner__c);
           objTestAccount.Lead_Source_Most_Recent__c = 'Other';
           System.assertEquals('Other', objTestAccount.Lead_Source_Most_Recent__c);
           System.assertEquals('Other', objTestAccount.Lead_Source__c);
        }
        if(objTestAccount.Name == 'Arindam Test Account3'){
           System.debug('Inside Arindam Test Account3');
           objTestAccount.SIC_Description_General__c = 'Test SIC General Description';
           System.assertEquals('Test SIC General Description',objTestAccount.SIC_Description_General__c);
           objTestAccount.SIC_Description_Detailed__c = 'Test SIC Detailed Description';
           System.assertEquals('Test SIC Detailed Description',objTestAccount.SIC_Description_Detailed__c);
           objTestAccount.SIC_Reporting_Description__c = 'Test SIC Report';
           System.assertEquals('Test SIC Report',objTestAccount.SIC_Reporting_Description__c);
           System.assertEquals(true, objTestAccount.Manual_Assignment__c);
           objTestAccount.Data_Share_Partner__c = lsttestDataSharingPartner[1].Id;
           System.assertEquals(lsttestDataSharingPartner[1].Id, objTestAccount.Data_Share_Partner__c);
           System.assertEquals(null, objTestAccount.Lead_Source_Most_Recent__c);
           System.assertEquals(null, objTestAccount.Lead_Source__c);
           
        }
      }
    }
    test.stopTest();       
  }
   
  Static testMethod void UpdatePartnerSupportAndpartnerAgentAndRecordOwnerChange_test(){
    System.debug('@@@@ test user details::'+testUser);
    System.debug('@@@@ partner User details::'+partnerUser);
    
    List<Id> lstAllTestAccountId = new List<Id>();
    List<Id> lstAllUpdatedTestAccountId = new List<Id>();
    Integer Count = 0;
    
    test.startTest();  
  
    System.runAs(testUser){
      List<Account> lstAccount = new List<Account>();
 
      for(Integer i=0; i<5; i++){
          Account testAccount = new Account();
          
          testAccount.Name = 'Arindam Test Account'+Count;         
          testAccount.recordTypeId = AccountRecordTypes__c.getInstance('TL_SALES_ACCOUNT_RECORD_TYPE_ID').RecordTypeID__c;
          
          if(i==0){
              testAccount.OwnerId = partnerUser.Id;                              //record owner is partner user
              testAccount.RecordOwner__c = null;                                 //RecordOwner__c is set to null
          }
          if(i==1)
          {
              testAccount.OwnerId = partnerUser.Id;                              //Record owner is partner user
              testAccount.RecordOwner__c = partnerUser.Id;                       //RecordOwner__c is set to parnetner user
          }
          if(i==2){
              testAccount.RecordOwner__c = null;                                 //Record owner is non-partner(System Admin) user
          }
          if(i==3)
          {
              testAccount.RecordOwner__c = testUser.Id;                          //Record owner is non-partner(System Admin) user 
          }
          if(i==4)
          {
              //testAccount.OwnerId = TestmasterpartnerUser.Id;                    //Record owner is masterpartner user 
          }
          
          lstAccount.add(testAccount);
          Count++;
      }
      try{
          Insert lstAccount;
      }
      catch(Exception e){
          System.debug('Account Insertion failed in ValidateCountryAndState_test method, due to::'+e.getmessage());
      }
      
      //  @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ INSERTED DATA VALIDATION @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@  //
      
      for(Account objTestAccount:lstAccount)
      {
          lstAllTestAccountId.add(objTestAccount.Id);
        
      }
      
      List<Account> lstAllTestAccount = [SELECT Name, recordTypeId, OwnerId, RecordOwner__c, Support_Account__c, Partner_Agent__c
                                        from Account WHERE id in: lstAllTestAccountId];
                                        
      for(Account objTestAccount:lstAllTestAccount)
      {
          if(objTestAccount.Name == 'Arindam Test Account0')
          {
               System.debug('Inside Arindam Test Account0');
               System.debug('@@@@System.Label.Omnitracs_Account_Id'+System.Label.Omnitracs_Account_Id);
               System.debug('@@@@objTestAccount.ownerId'+objTestAccount.ownerId);
               System.debug('@@@@objTestAccount.RecordOwner__c'+objTestAccount.RecordOwner__c);
               System.debug('@@@@objTstAccount.Id'+objTstAccount.Id);
               System.debug('@@@@objTestAccount.Support_Account__c'+objTestAccount.Support_Account__c);
               //when RecordOwner__c is null, Support_Account__c will become default omnitracs account
               //and Partner_Agent__c will become RecordOwner__c 
               System.assertEquals(null,objTestAccount.RecordOwner__c);
               objTestAccount.Support_Account__c = System.Label.Omnitracs_Account_Id;
               System.assertEquals(System.Label.Omnitracs_Account_Id,objTestAccount.Support_Account__c);
               System.assertEquals(null,objTestAccount.Partner_Agent__c);  
               
          } 
          if(objTestAccount.Name == 'Arindam Test Account1')
          {
               System.debug('Inside Arindam Test Account1');
               System.debug('@@@@System.Label.Omnitracs_Account_Id'+System.Label.Omnitracs_Account_Id);
               System.debug('@@@@objTestAccount.ownerId'+objTestAccount.ownerId);
               System.debug('@@@@objTestAccount.RecordOwner__c'+objTestAccount.RecordOwner__c);
               System.debug('@@@@objTstAccount.Id'+objTstAccount.Id);
               System.debug('@@@@objTestAccount.Support_Account__c'+objTestAccount.Support_Account__c);
               //when RecordOwner__c is partner user, Support_Account__c will become corresponding users's Account Id
               //and Partner_Agent__c will become RecordOwner__c
               System.assertEquals(partnerUser.Id,objTestAccount.RecordOwner__c);
               objTestAccount.Support_Account__c = objTstAccount.Id;
               System.assertEquals(objTstAccount.Id,objTestAccount.Support_Account__c);
               objTestAccount.Partner_Agent__c = objTestAccount.RecordOwner__c;
               System.assertEquals(objTestAccount.RecordOwner__c,objTestAccount.Partner_Agent__c);  
               
          }
          if(objTestAccount.Name == 'Arindam Test Account2')
          {
               System.debug('Inside Arindam Test Account2');
               System.debug('@@@@System.Label.Omnitracs_Account_Id'+System.Label.Omnitracs_Account_Id);
               System.debug('@@@@objTestAccount.ownerId'+objTestAccount.ownerId);
               System.debug('@@@@objTestAccount.RecordOwner__c'+objTestAccount.RecordOwner__c);
               System.debug('@@@@objTstAccount.Id'+objTstAccount.Id);
               System.debug('@@@@objTestAccount.Support_Account__c'+objTestAccount.Support_Account__c);
               //when RecordOwner__c is null, Support_Account__c will become default omnitracs account
               System.assertEquals(null,objTestAccount.RecordOwner__c);
               objTestAccount.Support_Account__c = System.Label.Omnitracs_Account_Id;
               System.assertEquals(System.Label.Omnitracs_Account_Id,objTestAccount.Support_Account__c);
               System.assertEquals(null,objTestAccount.Partner_Agent__c);  
               
          }
          if(objTestAccount.Name == 'Arindam Test Account3')
          {
               System.debug('Inside Arindam Test Account3');
               System.debug('@@@@System.Label.Omnitracs_Account_Id'+System.Label.Omnitracs_Account_Id);
               System.debug('@@@@objTestAccount.ownerId'+objTestAccount.ownerId);
               System.debug('@@@@objTestAccount.RecordOwner__c'+objTestAccount.RecordOwner__c);
               System.debug('@@@@objTstAccount.Id'+objTstAccount.Id);
               System.debug('@@@@objTestAccount.Support_Account__c'+objTestAccount.Support_Account__c);
               //when RecordOwner__c is non-partner user, Support_Account__c will become null
               //as corresponding user does not have any related contact/Account
               System.assertEquals(testUser.Id,objTestAccount.RecordOwner__c); 
               System.assertEquals(null,objTestAccount.Support_Account__c);
               objTestAccount.Partner_Agent__c = objTestAccount.RecordOwner__c;
               System.assertEquals(objTestAccount.RecordOwner__c,objTestAccount.Partner_Agent__c);  
               
          }
          if(objTestAccount.Name == 'Arindam Test Account4')
          {
               System.debug('Inside Arindam Test Account4');
               System.debug('@@@@objTestAccount.RecordOwner__c'+objTestAccount.RecordOwner__c);
               System.debug('@@@@objTestAccount.Partner_Agent__c'+objTestAccount.Partner_Agent__c);
               System.debug('@@@@objTestAccount.ownerId'+objTestAccount.ownerId);
               //System.assertEquals(TestmasterpartnerUser.Id,objTestAccount.RecordOwner__c);
               //System.assertEquals(TestmasterpartnerUser.Id,objTestAccount.Partner_Agent__c);
               //System.assertEquals(TestmasterpartnerUser.Master_Partner_User__c,objTestAccount.ownerId);  
               
          }
      }
      
               //  @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ UPDATE @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@  //
               
      for(Account objTestAccount:lstAccount){
          if(objTestAccount.Name == 'Arindam Test Account0')
         {
             objTestAccount.OwnerId = partnerUser.Id;                 //as owner id not changed so 'Support_Account__c' will also not changed
         }                                                            //and as 'RecordOwner__c' not changed so 'Partner_Agent__c' will also not changed
         if(objTestAccount.Name == 'Arindam Test Account1')
         {
             objTestAccount.RecordOwner__c = testUser.Id;             //Change 'RecordOwner__c' will nulify 'RecordOwner__c' and 'Partner_Agent__c'
         }                                                            //as per 'RecordOwnerChange' functionality
          if(objTestAccount.Name == 'Arindam Test Account2')
         {
             objTestAccount.OwnerId = partnerUser.Id;                //Change record Owner will nulify 'RecordOwner__c' and 'Partner_Agent__c'
         }                                                           //as per 'RecordOwnerChange' functionality 
         if(objTestAccount.Name == 'Arindam Test Account3')
         {
             objTestAccount.RecordOwner__c = testUser.Id;            //as 'RecordOwner__c' not changed so 'Support_Account__c' will also not changed
         }                                                           //and 'Partner_Agent__c' will also not changed                                                                 
    }
    try{
          AllAccountUtils.isExecuted = false;
          update lstAccount;
      }
      catch(Exception e){
        System.debug('Account Updation failed in UpdatePartnerSupport_test method, due to::'+e.getmessage());
      }
       
       //  @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ UPDATED DATA VALIDATION @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@  //
       
       for(Account objTestAccount:lstAccount)
      {
          lstAllUpdatedTestAccountId.add(objTestAccount.Id);
        
      }
      List<Account> lstAllUpdatedTestAccount = [SELECT Name, recordTypeId, OwnerId, RecordOwner__c, Support_Account__c, Partner_Agent__c
                                               from Account WHERE id in: lstAllUpdatedTestAccountId];
                                               
      for(Account objTestAccount:lstAllUpdatedTestAccount){
          if(objTestAccount.Name == 'Arindam Test Account0')
          {
               
               System.assertEquals(null,objTestAccount.RecordOwner__c);
               objTestAccount.Support_Account__c = System.Label.Omnitracs_Account_Id;
               System.assertEquals(System.Label.Omnitracs_Account_Id,objTestAccount.Support_Account__c);
               System.assertEquals(null,objTestAccount.Partner_Agent__c);               
          } 
          if(objTestAccount.Name == 'Arindam Test Account1')
          {
               objTestAccount.Support_Account__c = System.Label.Omnitracs_Account_Id;
               System.assertEquals(System.Label.Omnitracs_Account_Id,objTestAccount.Support_Account__c);
               System.assertEquals(null,objTestAccount.Partner_Agent__c);  
               
          }
          if(objTestAccount.Name == 'Arindam Test Account2')
          {
               objTestAccount.Support_Account__c = System.Label.Omnitracs_Account_Id;
               System.assertEquals(System.Label.Omnitracs_Account_Id,objTestAccount.Support_Account__c);
               System.assertEquals(null,objTestAccount.Partner_Agent__c);   
               
          }
          if(objTestAccount.Name == 'Arindam Test Account3')
          {
               
               System.assertEquals(testUser.Id,objTestAccount.RecordOwner__c); 
               System.assertEquals(null,objTestAccount.Support_Account__c);
               objTestAccount.Partner_Agent__c = objTestAccount.RecordOwner__c;
               System.assertEquals(objTestAccount.RecordOwner__c,objTestAccount.Partner_Agent__c); 
               
          }    
      }                                         
    }                                                
    test.stopTest();     
  } 
       
  Static testMethod void DataPrepPlusupdatePartnerSupportDetails_test(){
    System.debug('@@@@ test user details::'+testUser);
    
    List<Id> lstAllTestAccountId = new List<Id>();
    List<Id> lstAllUpdatedTestAccountId = new List<Id>();
    Id tempAccountId;
    //Contact testContact = new Contact();
    //User testpartner = new User();
    
    Integer Count = 0;
    
    test.startTest();    
    System.runAs(testUser){
      List<Account> lstAccount = new List<Account>();

      for(Integer i=0; i<4; i++){
          Account testAccount = new Account();
          
          testAccount.Name = 'Arindam Test Account'+Count;         
          testAccount.recordTypeId = AccountRecordTypes__c.getInstance('TL_SALES_ACCOUNT_RECORD_TYPE_ID').RecordTypeID__c; 
          testAccount.AGUID__c = 'test AUGID'+Count;
          testAccount.Segment__c = 'TL';

          if(i==0)
          {
              testAccount.UnityOnboardStatus__c = 'test onboard';
              testAccount.OwnerId = partnerUser.Id;
              testAccount.RecordOwner__c = partnerUser.Id; 
              testAccount.CSR__c = null;
              
          }
          if(i==1)
          {
              testAccount.UnityOnboardStatus__c = null;
              testAccount.RecordOwner__c = testUser.Id; 
              testAccount.CSR__c = testUser.Id;
          }
          if(i==2)
          {
              testAccount.UnityOnboardStatus__c = null;
              testAccount.RecordOwner__c = testUser.Id; 
              testAccount.CSR__c = testUser.Id;           
          }
          if(i==3)
          {
              testAccount.UnityOnboardStatus__c = 'test onboard';
              testAccount.OwnerId = partnerUser.Id;
              testAccount.RecordOwner__c = partnerUser.Id; 
              testAccount.CSR__c = null;          
          }

          lstAccount.add(testAccount);
          Count++;
      }
      try{
          Insert lstAccount;
      }
      catch(Exception e){
          System.debug('Account Insertion failed in DataPrepPlusupdatePartnerSupportDetails_test method, due to::'+e.getmessage());
      }
      
                 //  @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ UPDATE @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@  //
       
       for(Account objTestAccount:lstAccount){
           if(objTestAccount.Name == 'Arindam Test Account1')
           {
             tempAccountId = objTestAccount.id; 
           }
       }        
       for(Account objTestAccount:lstAccount){
         if(objTestAccount.Name == 'Arindam Test Account0')
         {
             objTestAccount.CSR__c = testUser.Id;             
             //objTestAccount.District__c ='East District 1';
             objTestAccount.Support_Account__c = tempAccountId;

         }
         if(objTestAccount.Name == 'Arindam Test Account1')
         {
             objTestAccount.UnityOnboardStatus__c = 'test onboard';
             objTestAccount.OwnerId = partnerUser.Id;
             objTestAccount.RecordOwner__c = partnerUser.Id; 
         }
         if(objTestAccount.Name == 'Arindam Test Account2')
         {
             objTestAccount.UnityOnboardStatus__c = 'test onboard';
             objTestAccount.OwnerId = partnerUser.Id;
             objTestAccount.RecordOwner__c = partnerUser.Id; 
         } 
         if(objTestAccount.Name == 'Arindam Test Account3')
         {
             objTestAccount.CSR__c = testUser.Id;             
             //objTestAccount.District__c ='Strategic';
             objTestAccount.Support_Account__c = tempAccountId; 
         }                                                                         
      }
      
      try{
          update lstAccount;
      }
      catch(Exception e){
        System.debug('Account Updation failed in DataPrepPlusupdatePartnerSupportDetails_test method, due to::'+e.getmessage());
      }
     }                                                     
    test.stopTest();
  }
  
  Static testMethod void ValidateCountryAndState_test(){
    Integer Count = 0;
      PartnerMasterOwnerController.updtPartnerAgent = true;
    
    test.startTest();       
    System.runAs(testUser)
    {
      System.debug('@@@@ test user details::'+testUser);
      List<Account> lstAccount = new List<Account>();
 
      //Same code will run for both insertion and updation
      //As there is no SOQL query being executed so we are covering scenario only for Insertion 
      for(Integer i=0; i<10; i++){
          Account testAccount = new Account();
          
          testAccount.Name = 'Arindam Test Account'+Count;
          if(i==0){
              testAccount.recordTypeId = AccountRecordTypes__c.getInstance('TL_SALES_ACCOUNT_RECORD_TYPE_ID').RecordTypeID__c;
              testAccount.BillingCountry = null;                                 //Accepted because of record type
          }
          else if(i==1){
              testAccount.recordTypeId = AccountRecordTypes__c.getInstance('TL_SALES_ACCOUNT_RECORD_TYPE_ID').RecordTypeID__c;
              testAccount.BillingCountry = lsttestCountryAndCountryCode[1].Name;   
              testAccount.BillingState = null;                                   //Accepted because of record type
          }
          else if(i==2){
              testAccount.recordTypeId = AccountRecordTypes__c.getInstance('GSS_ACCOUNT_RECORD_TYPE_ID').RecordTypeID__c;
              testAccount.BillingCountry = lsttestCountryAndCountryCode[0].Name;
              testAccount.BillingState = 'Test State';                           //Accepted as country in Non-US
          }
          else if(i==3){
              testAccount.recordTypeId = AccountRecordTypes__c.getInstance('GSS_ACCOUNT_RECORD_TYPE_ID').RecordTypeID__c;
              testAccount.BillingCountry = null;
              testAccount.BillingState = 'Test State';                            //Not Accepted as sate is not valid
          }
          else if(i==4){
              testAccount.recordTypeId = AccountRecordTypes__c.getInstance('GSS_ACCOUNT_RECORD_TYPE_ID').RecordTypeID__c;
              testAccount.BillingCountry = null;
              testAccount.BillingState = 'CA';                                   //Accepted as Sate is valid
          }
          else if(i==5){
              testAccount.recordTypeId = AccountRecordTypes__c.getInstance('GSS_ACCOUNT_RECORD_TYPE_ID').RecordTypeID__c;
              testAccount.BillingCountry = null;
              testAccount.BillingState = null;                                   //Not Accepted as state is not valid
          }
          else if(i==6){
              testAccount.recordTypeId = AccountRecordTypes__c.getInstance('GSS_ACCOUNT_RECORD_TYPE_ID').RecordTypeID__c;
              testAccount.BillingCountry = lsttestCountryAndCountryCode[1].Name;
              testAccount.BillingState = 'Test State';                           //Not Accepted as state does not present in Sate__C
              
          }
          else if(i==7){
              testAccount.recordTypeId = AccountRecordTypes__c.getInstance('GSS_ACCOUNT_RECORD_TYPE_ID').RecordTypeID__c;
              testAccount.BillingCountry = lsttestCountryAndCountryCode[1].Name; //state does present in Sate__C
              testAccount.BillingState = 'Abc';                                  //Not Accepted as state code contains more than 2 char
              
          }
          else if(i==8){
              testAccount.recordTypeId = AccountRecordTypes__c.getInstance('GSS_ACCOUNT_RECORD_TYPE_ID').RecordTypeID__c;
              testAccount.BillingCountry = lsttestCountryAndCountryCode[1].Name; //state does present in Sate__C
              testAccount.BillingState = 'Alabama';                              //Accepted as state is valid
              
          }
          else{
              testAccount.recordTypeId = AccountRecordTypes__c.getInstance('GSS_ACCOUNT_RECORD_TYPE_ID').RecordTypeID__c;
              testAccount.BillingCountry = lsttestCountryAndCountryCode[1].Name; //state does present in Sate__C
              testAccount.BillingState = 'CA';                                   //Accepted as state is valid
          }
          lstAccount.add(testAccount);
          count++;
      }
      try{
          Insert lstAccount;
      }
      catch(Exception e){
          System.debug('Account Insertion failed in ValidateCountryAndState_test method, due to::'+e.getmessage());
      }
    }
    test.stopTest(); 
  }
Static testMethod void ValidateCountryAndState_test1(){
    Integer Count = 0;
      PartnerMasterOwnerController.updtPartnerAgent = true;
    
    test.startTest();       
    System.runAs(testUser)
    {
      System.debug('@@@@ test user details::'+testUser);
      List<Account> lstAccount = new List<Account>();
 
      //Same code will run for both insertion and updation
      //As there is no SOQL query being executed so we are covering scenario only for Insertion 
      for(Integer i=0; i<10; i++){
          Account testAccount = new Account();
          
          testAccount.Name = 'Arindam Test Account'+Count;
          if(i==0){
              testAccount.recordTypeId = AccountRecordTypes__c.getInstance('TL_SALES_ACCOUNT_RECORD_TYPE_ID').RecordTypeID__c;
              testAccount.BillingCountry = null;                                 //Accepted because of record type
          }
          else if(i==1){
              testAccount.recordTypeId = AccountRecordTypes__c.getInstance('TL_SALES_ACCOUNT_RECORD_TYPE_ID').RecordTypeID__c;
              testAccount.BillingCountry = lsttestCountryAndCountryCode[1].Name;   
              testAccount.BillingState = null;                                   //Accepted because of record type
          }
          else if(i==2){
              testAccount.recordTypeId = AccountRecordTypes__c.getInstance('GSS_ACCOUNT_RECORD_TYPE_ID').RecordTypeID__c;
              testAccount.BillingCountry = lsttestCountryAndCountryCode[0].Name;
              testAccount.BillingState = 'Test State';                           //Accepted as country in Non-US
          }
          else if(i==3){
              testAccount.recordTypeId = AccountRecordTypes__c.getInstance('GSS_ACCOUNT_RECORD_TYPE_ID').RecordTypeID__c;
              testAccount.BillingCountry = null;
              testAccount.BillingState = 'Test State';                            //Not Accepted as sate is not valid
          }
          else if(i==4){
              testAccount.recordTypeId = AccountRecordTypes__c.getInstance('GSS_ACCOUNT_RECORD_TYPE_ID').RecordTypeID__c;
              testAccount.BillingCountry = null;
              testAccount.BillingState = 'CA';                                   //Accepted as Sate is valid
          }
          else if(i==5){
              testAccount.recordTypeId = AccountRecordTypes__c.getInstance('GSS_ACCOUNT_RECORD_TYPE_ID').RecordTypeID__c;
              testAccount.BillingCountry = null;
              testAccount.BillingState = null;                                   //Not Accepted as state is not valid
          }
          else if(i==6){
              testAccount.recordTypeId = AccountRecordTypes__c.getInstance('GSS_ACCOUNT_RECORD_TYPE_ID').RecordTypeID__c;
              testAccount.BillingCountry = lsttestCountryAndCountryCode[1].Name;
              testAccount.BillingState = 'Test State';                           //Not Accepted as state does not present in Sate__C
              
          }
          else if(i==7){
              testAccount.recordTypeId = AccountRecordTypes__c.getInstance('GSS_ACCOUNT_RECORD_TYPE_ID').RecordTypeID__c;
              testAccount.BillingCountry = lsttestCountryAndCountryCode[1].Name; //state does present in Sate__C
              testAccount.BillingState = 'Abc';                                  //Not Accepted as state code contains more than 2 char
              
          }
          else if(i==8){
              testAccount.recordTypeId = AccountRecordTypes__c.getInstance('GSS_ACCOUNT_RECORD_TYPE_ID').RecordTypeID__c;
              testAccount.BillingCountry = lsttestCountryAndCountryCode[1].Name; //state does present in Sate__C
              testAccount.BillingState = 'Alabama';                              //Accepted as state is valid
              
          }
          else{
              testAccount.recordTypeId = AccountRecordTypes__c.getInstance('GSS_ACCOUNT_RECORD_TYPE_ID').RecordTypeID__c;
              testAccount.BillingCountry = lsttestCountryAndCountryCode[1].Name; //state does present in Sate__C
              testAccount.BillingState = 'CA';                                   //Accepted as state is valid
          }
          lstAccount.add(testAccount);
          count++;
      }
      //try{
        for(account acc: lstAccount){
            acc.segment__c = 'TL';
            acc.billingstreet = '1600 tx dr';
            acc.BillingCity = 'Dallas';
            acc.BillingCountry = 'US';
            acc.BillingPostalCode = '75035';
            acc.Billingstate = 'TX';
            acc.Fleet_Size__c = 8;
        }
          Insert lstAccount;
          list<string> listofownerID = new list<string> ();
          listofownerId.add(testuser.id);
          Allaccountutils.RecordOwnerChange(listofownerId,lstAccount,lstAccount);
        Allaccountutils.updateSpringCMAccountName(lstAccount,new Map<id,Account>(lstAccount),false);
        Allaccountutils.getStateCode('Florida');
          list<id> accidlist = new list<id> ();
          accidlist.add(lstaccount[0].id);
          Allaccountutils.inactivateContactsFromDormantAccounts(accidlist);
     // }
     // catch(Exception e){
      //    System.debug('Account Insertion failed in ValidateCountryAndState_test method, due to::'+e.getmessage());
     // }
    }
    test.stopTest(); 
  }
    public static testmethod void  AccountTriggerExecuted () {
        AllAccountUtils.AccountTriggerExecuted ();
    }  
}