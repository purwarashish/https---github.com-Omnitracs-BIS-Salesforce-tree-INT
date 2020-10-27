@isTest(SeeAllData=True)
public class TestDataScoreComputation{
    //--------Market as CNR Sales (Market as Mexico)---------------------------//
    static testmethod void testCNR() {
           RecordType recType = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' and DeveloperName= 'TLSalesAccounts'];
           User user =[SELECT Id,Name FROM User limit 1];
      account acct5 = new account(
                                   QWBS_Market__c = 'Mexico Sales',
                                   RecordTypeId = recType.Id,
                                   /*District__c = 'Metro',*/
                                   Name = 'MexicoTest',
                                   Fax='4567686754',
                                   Account_Manager__c=user.Id,
                                   CSR__c=user.Id,
                                // Software_Application_Eng__c=user.Id,
                                   of_Locations__c= 7,
                                   Computer_Platform__c= 'Mainframe',
                                   Account_Type__c = 'Rail',
                                   BillingStreet = '123 Main',
                                   BillingCity = 'San Diego',
                                   BillingState = 'CA',
                                   BillingCountry = 'USA',
                                   BillingPostalCode ='92128',
                                   Fleet_Size__c = 5,
                                   Segment__c = 'TL',
                                   QWBS_Cust_ID__c='234987',
                                // Dollies__c=5,
                                // Dry_Vans__c=6,
                                // Flatbeds__c=7,
                                   Lead_Source__c='OneSource',
                                // OBC__c=7,
                                // OEM_Reefer_Trailer__c='2',
                                // OEM_Tractor__c='7',
                                // OTR_Vehicles__c=6,
                                // Fiscal_Year_End__c='May',
                                   Phone='4561234567',
                                   Primary_Business__c='Sand',
                                // Primary_Commodity__c='Concrete',
                                   Ranking__c= 'General',
                               //  Reefers__c= 7,
                                   Regional_Vehicles__c= 6,
                                   RFC_ID__c = String.valueOf(Math.round(Math.random()*1000)),
                                // Sensors__c=7,
                                   ShippingCity='San Diego',
                                   ShippingCountry='USA',
                                   ShippingState='CA',
                                   ShippingStreet='123 Main',
                                   ShippingPostalCode='92128',
                                   QWBS_Status__c='Contract Customer');
                                // ,Tankers__c=6
                                 //TrailerTRACS__c=7
      insert acct5;

      Account newAccount = [Select Id, QWBS_Market__c,Data_Quality_Score_Apex__c, Data_Quality_Description_Apex__c from Account where Id = :acct5.ID];

     //System.assertEquals(100, newAccount.Data_Quality_Score_Apex__c);
     //System.assertEquals('All Account Details Captured',newAccount.Data_Quality_Description_Apex__c);
    }
    // --------Market as GSS and district as ORMM---------------------------------------------------//
        static testmethod void testGSSORMM() {
           RecordType recType = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' and Name = 'GSS'];

      account acct4 = new account(
                                   QWBS_Market__c = 'GSS',
                                   RecordTypeId = recType.Id,
                                   /*District__c = 'ORMM West',*/
                                   Name = 'My Test1',
                                   Fax='4567686754',
                                   Ranking__c = 'A',
                                   Dealer_Type__c = 'Bobcat',
                                   Description = 'all hardware and messaging ',
                                   Account_Type__c = 'Rail',
                                   BillingStreet = '123 Main',
                                   BillingCity = 'San Diego',
                                   BillingState = 'CA',
                                   BillingCountry = 'USA',
                                   BillingPostalCode = '12223',
                                   Fleet_Size__c = 6,
                                   Segment__c = 'TL',
                                   Product_Interest__c='Bundled Solutions ',
                                // Feature_Interest__c='DSN',
                                   Phone = '888 888 8888');
                                // Asset_Value_Range__c= '$1,000 - $10,000',
                                // Device_Supplier__c = 'B',
                               //  Service_Model__c = 'Direct',
                               //  Number_of_Enabled_Devices__c = 2 );
      insert acct4;


      Account newAccount = [Select Id, Data_Quality_Score_Apex__c, Data_Quality_Description_Apex__c from Account where Id = :acct4.ID];

      //System.assertEquals(80, newAccount.Data_Quality_Score_Apex__c);
      //System.assertEquals('Missing: Dealer',newAccount.Data_Quality_Description_Apex__c);
    }

    // --------Market as GSS and district as Non ORMM---------------------------------------------------//
    static testmethod void testGSSNonORMM() {
    RecordType recType = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' and Name = 'GSS'];

      account acct1 = new account(
                                  QWBS_Market__c = 'GSS',
                                  RecordTypeId = recType.Id,
                                  /*District__c = 'Industrial',*/
                                  Fax='4567686754',
                                  BillingStreet = '123 Main',
                                  BillingCity = 'San Diego',
                                  BillingState = 'CA',
                                  BillingCountry = 'USA',
                                  BillingPostalCode = '3434',
                                  Fleet_Size__c = 6,
                                  Segment__c = 'TL',
                                  Phone = '888 888 8888',
                               // Asset_Value_Range__c= '$1,000 - $10,000',
                               // Device_Supplier__c = 'B',
                               // Service_Model__c = 'Direct',
                              //  Number_of_Enabled_Devices__c = 2,
                                  Name = 'My Test1',
                                  Ranking__c = 'A',
                                  Account_Type__c = 'Rail',
                                  Product_Interest__c='Bundled Solutions ');
                             //   Feature_Interest__c='DSN'
      insert acct1;

      Account newAccount = [Select Id, Data_Quality_Score_Apex__c, Data_Quality_Description_Apex__c from Account where Id = :acct1.ID];

     // System.assertEquals(100, newAccount.Data_Quality_Score_Apex__c);
     //System.assertEquals('All Account Details Captured',newAccount.Data_Quality_Description_Apex__c);
    }


    static testmethod void testTLDistrictSalesNonEval() {
           RecordType recType = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' and Name = 'T&L Sales Accounts'];

      account acct1 = new account(
                                  QWBS_Market__c = 'T&L Eastern Region',
                                  /*District__c = 'East District 1',*/
                                  RecordTypeId = recType.Id,
                                  QWBS_Status__c = 'Active Prospect',  //non-eval
                                  Lead_Source__c = '800#',
                                  Average_Length_of_Haul__c = '0-250',
                                  Primary_Business__c = 'Service',
                               // Primary_Commodity__c = 'Coal',
                                  Name = 'My Test',
                                  BillingStreet = '123 Main',
                                  BillingCity = 'San Diego',
                                  BillingState = 'CA',
                                  BillingCountry = 'USA',
                                  BillingPostalCode = '7898',
                                  Fleet_Size__c = 9,
                                  Segment__c = 'TL',
                                  Account_Type__c = 'Rail',
                                  Phone = '888 888 8888',
                                  Regional_Vehicles__c = 5);
                               // OTR_Vehicles__c = 5
      insert acct1;


      Account newAccount = [Select Id, Data_Quality_Score_Apex__c, Data_Quality_Description_Apex__c from Account where Id = :acct1.ID];

      //System.assertEquals(100, newAccount.Data_Quality_Score_Apex__c);
      //System.assertEquals('All Account Details Captured',newAccount.Data_Quality_Description_Apex__c);
    }

    static testmethod void testTLDistrictSalesEval() {
      RecordType recType = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' and Name = 'T&L Sales Accounts'];

      account acct1 = new account(
                                  QWBS_Market__c = 'T&L Eastern Region',
                                  /*District__c = 'East District 1',*/
                                  RecordTypeId = recType.Id,
                                  QWBS_Status__c = 'New Eval Customer',  //eval
                                  QWBS_Cust_ID__c = '111111111111',
                                  Lead_Source__c = '800#',
                                  Average_Length_of_Haul__c = '0-250',
                                  Primary_Business__c = 'Service',
                               // Primary_Commodity__c = 'Coal',
                                  Name = 'My Test',
                                  BillingStreet = '123 Main',
                                  BillingCity = 'San Diego',
                                  BillingState = 'CA',
                                  BillingCountry = 'USA',
                                  BillingPostalCode = '34567',
                                  Fleet_Size__c = 7,
                                  Segment__c = 'TL',
                                  Account_Type__c = 'Rail',
                                  Contract_Comments__c = 'test comments',
                                  Computer_Platform__c = 'Mainframe',
                                  Ranking__c = 'A',
                                  Phone = '888 888 8888',
                                  Regional_Vehicles__c = 5);
//                                  Contract_Expiration__c = System.today(),
//                                  QWBS_Annual_Revenues__c = 550000,
                                //  OTR_Vehicles__c = 5);
      insert acct1;


      Account newAccount = [Select Id, Data_Quality_Score_Apex__c, Data_Quality_Description_Apex__c from Account where Id = :acct1.ID];

      //System.assertEquals(80, newAccount.Data_Quality_Score_Apex__c);
      //System.assertEquals('Missing: Contract Expiration',newAccount.Data_Quality_Description_Apex__c);
    }

} //end class TestDataScoreComputation