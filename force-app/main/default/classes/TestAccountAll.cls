/**
 * This class contains unit tests for validating the behavior of all Account Apex classes
 * and triggers.
 *
 
 */
@isTest(SeeAllData= true)
public class TestAccountAll {
    
/************************************** Common Data Initialization********************/
    static Account testAccount = GenericTestClass.insertAccount();
  //static Account resellerAccount = GenericTestClass.insertAccount();
    static Contact acctContact = GenericTestClass.insertContact(testAccount.ID);
    static Case acctCase = GenericTestClass.insertCase(testAccount.Id, acctContact.Id);
    static User testUser;
    static User testUser2;

/***********************************Data Initialzation**********************************/
    static testmethod void UpdateAccount()
    {
           test.startTest();
            RecordType recType = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' and DeveloperName = 'TLSalesAccounts' limit 1];
           
           //Fetch all record types for Account object and create a map of id=>developername in accountRecTypes.
             Map<String,Id> accountRecTypes = new Map<String,Id>();
             for(RecordType r: [SELECT Id,DeveloperName FROM RecordType WHERE SObjectType = 'Account' order by DeveloperName])
             accountRecTypes.put(r.DeveloperName,r.Id); 
           
           testUser =[SELECT Id,Name,Oracle_Name__c FROM User where isactive = true limit 1];
           testUser2 = [SELECT Id,Name FROM User where isactive = true and id!= :testUser.Id limit 1];
           testAccount.QWBS_Market__c = 'Mexico Sales';
           testAccount.RecordTypeId = recType.Id;
           //testAccount.RecordTypeId = accountRecTypes.get('TLSalesAccounts');
           //testAccount.District__c = 'Metro';
           testAccount.Name = 'MexicoTest';
           testAccount.Fax='4567686754';
           
           //testAccount.Account_Manager__c=testUser.Id;
           //testAccount.CSR__c=testUser.Id;
        // testAccount.Software_Application_Eng__c=testUser.Id;
           //testAccount.Contracts_Administrator__c = testUser.Id;
           //testAccount.Inside_Sales_Rep__c = testUser.Id;
           //testAccount.AR_Representative__c = testUser2.Id;
           //testAccount.Partner_Agent__c = testUser2.Id;
           //testAccount.Inside_CSR__c = testUser.Id;
           //testAccount.FRA_Account_Manager__c = testUser.Id;
           //testAccount.FRA_Customer_Service_Rep__c = testUser.Id;
       //  testAccount.FRA_Contracts_Administrator__c = testUser.Id;
           //testAccount.FRA_Software_Application_Eng__c = testUser.Id;
                  
           
           testAccount.of_Locations__c= 7;
           testAccount.Computer_Platform__c= 'Mainframe';
           testAccount.Account_Type__c = 'Rail';
           testAccount.BillingStreet = '123 Main';
           testAccount.BillingCity = 'San Diego';
           testAccount.BillingState = 'CA';
           testAccount.BillingCountry = 'USA';
           testAccount.BillingPostalCode ='92128';
           testAccount.Fleet_Size__c = 6;
           testAccount.Segment__c = 'Services';
           testAccount.QWBS_Cust_ID__c='2345678';
        // testAccount.Dollies__c=5;
        // testAccount.Dry_Vans__c=6;
        // testAccount.Flatbeds__c=7;
           testAccount.Lead_Source__c='OneSource';
        // testAccount.OBC__c=7;
        // testAccount.OEM_Reefer_Trailer__c='2';
        // testAccount.OEM_Tractor__c='7';
        // testAccount.OTR_Vehicles__c=6;
        // testAccount.Fiscal_Year_End__c='May';
           testAccount.Phone='4561234567';
           testAccount.Primary_Business__c='Sand';
        // testAccount.Primary_Commodity__c='Concrete';
           testAccount.Ranking__c= 'General';
        // testAccount.Reefers__c= 7;
           testAccount.Regional_Vehicles__c= 6; 
           testAccount.RFC_ID__c = String.valueOf(Math.round(Math.random()*1000));
        // testAccount.Sensors__c=7;
           testAccount.ShippingCity='San Diego';
           testAccount.ShippingCountry='USA';
           testAccount.ShippingState='CA';
           testAccount.ShippingStreet='123 Main';
           testAccount.ShippingPostalCode='92128';
           testAccount.QWBS_Status__c='Contract Customer';
        // testAccount.Tankers__c=6;
        // testAccount.TrailerTRACS__c=7;

           update testAccount;

           TestDataScoreComputation();
           TestMyAccountsmethod();
           TestPopulateAccountTeam();
           testRelatedLists();
           testPopulateAR_Rep();
           //myUpdateAccountTeam();
           test.stopTest(); 
        
    }
/***********************************End of Data Initialzation**********************************/

/************************************TestDataScoreComputation*************************/
    static void TestDataScoreComputation() {
        
            Account newAccount = [Select Id, Data_Quality_Score_Apex__c, Data_Quality_Description_Apex__c from Account where Id = :testAccount.ID limit 1];
            //System.assertEquals(100, newAccount.Data_Quality_Score_Apex__c);
            //System.assertEquals('All Account Details Captured',newAccount.Data_Quality_Description_Apex__c);
            newAccount.RecordTypeId = '01250000000DQBA';//T & L Sales Account
            newAccount.QWBS_Status__c = 'Eval Customer';
            update newAccount;          
            
            newAccount.RecordTypeId = '01250000000DVwY';//GSS Account
            //newAccount.District__c = 'Test';
            update newAccount;
            
            newAccount.RecordTypeId = '01250000000DVwY';//GSS Account
            //newAccount.District__c = 'ORMM';
            update newAccount; 
            List<String> lstMissingfieldList = new  List<String>();
            lstMissingfieldList.add('Account_Manager__c');
            lstMissingfieldList.add('Inside_CSR__c');
            lstMissingfieldList.add('FRA_Software_Application_Eng__c');
            String incomingvalue;
            CalculateDataQualityScore.retrieveRecordTypes('Account');
            CalculateDataQualityScore.checkFieldValue('20','QWBS_Status__c',3,lstMissingfieldList);         
            CalculateDataQualityScore.checkFieldValue(incomingvalue,'QWBS_Status__c',3,lstMissingfieldList);
        //test.stopTest();
    }
    
/************************************End of TestDataScoreComputation*************************/

/************************************TestMyAccounts*********************************************/
    
    private static void TestMyAccountsmethod()
    {
        //test.startTest();
        ApexPages.StandardController sdtCon;
        MyAccountsController newObj = new MyAccountsController(sdtCon);
        
        newObj.userList.add(testAccount);
        newObj.pagination();
        newObj.asce =true;
        newObj.ChangeOrder();
        newObj.tempList.add(newObj.userList);
        if(!(newObj.tempList.isEmpty()))
        {
        newObj.currentPage = 0;
        newObj.next();
        newObj.currentPage = 2; 
        newObj.previous(); 
        }
        // Modified By Shruti Karn for CR# 22542
        String [] curr = new String[]{'BillingCity',/*'District__c',*/'QWBS_Cust_ID__c','Phone','BillingState','QWBS_Market__c','QWBS_Status__c','name'};
        for(integer i=0;i<curr.size();i++)
        {
            newObj.setCurrent_value(curr[i]);
            newObj.ChangeOrder();
        }
        newObj.asce =false;
        for(integer i=0;i<curr.size();i++)
        {
            newObj.setCurrent_value(curr[i]);
            newObj.ChangeOrder();
        }
        curr[0] = newObj.getCurrent_Value();
        //test.stopTest();
         
    }
/************************************End ofTestMyAccounts*********************************************/

/************************************TestPopulateAccountTeam*********************************************/
    
    private static void TestPopulateAccountTeam()
    {
        RecordType recType = [SELECT Id FROM RecordType WHERE SObjectType = 'Case' and Name= 'EOX Return'];
        acctCase.RecordTypeId = recType.Id;
        update acctCase;
    }

/************************************End of TestPopulateAccountTeam*********************************************/

/************************************Test Account Related Lists**************************************************/

    private static void testRelatedLists()
    {
        /*******************************Test for Contact Related List******************************/
        
           ApexPages.currentPage().getParameters().put('AccountId',testAccount.Id);
           ApexPages.StandardController sdtCon;
           ViewSelectedContacts newObj  = new ViewSelectedContacts(sdtCon);
           newObj.AccountId = testAccount.Id;
           newObj.getContactsList();
           newObj.asce = true;
           newObj.getContactsList();
           newObj.pagination();
           newObj.next();
           newObj.previous();
        /*******************************End of Test for Contact Related List******************************/
        
        /*******************************Test for Cases Related List*************************************/
        
           ApexPages.currentPage().getParameters().put('AccountId',testAccount.Id);
           ApexPages.StandardController sdtContrl;
           ViewSelectedCases newObjCases  = new ViewSelectedCases(sdtContrl);
           newObjCases.AccountId = testAccount.Id;
           newObjCases.NewCase();
           newObjCases.getCaseList();
           newObjCases.asce = true;
           newObjCases.getCaseList();
           newObjCases.pagination();
           newObjCases.next();
           newObjCases.previous(); 
        /*******************************End of Test for Cases Related List******************************/
    }
/************************************End of Test Account Related Lists*********************************************/


/************************************Test Update Account Team*********************************************/

    static void testPopulateAR_Rep () 
    {
        testUser.Oracle_Name__c = 'Test';
        update testUser;
        testAccount.Collector_Name__c = 'Test';
        update testAccount;
    }
         

/************************************End of Test Update Account Team*********************************************/

/*** Test code for PartnerScorecard Functionality ***/
    static testMethod void validateTestAccountTriggerForPartnerScorecard() 
    {
        User olduser=[select Id,ContactId from  User where IsPortalEnabled=true and isActive = true limit 1];
        list<Contact> lstuserContact=[select AccountId from Contact where Id= :olduser.ContactId];
        Contact userContact = lstuserContact[0];
        Account contactAccount=[select RecordTypeId from Account where Id= :userContact.AccountID];
        
        RecordType rp=[select ID from RecordType where Name='Partner Account (Reseller)'];
        Account testAccount1=new Account(Name='test12',BillingStreet='street',BillingCity='city',BillingCountry='india',BillingState = 'Test State',BillingPostalCode = '3456', Fleet_Size__c = 1, Segment__c = 'Services', RecordTypeId=rp.Id,ownerid=olduser.Id);
       
        //insert testAccount1;
        Database.DMLOptions dml = new Database.DMLOptions(); 
        dml.DuplicateRuleHeader.allowSave = true;
        dml.DuplicateRuleHeader.runAsCurrentUser = true;
        Database.SaveResult sr1 = Database.insert(testAccount1, dml);
        update olduser;
       
        Partner_Scorecard__c patnerScorecardDraft=new Partner_Scorecard__c(Account__c=contactAccount.id,Current_Scorecard__c=true);
        insert patnerScorecardDraft;
        
       // insert testAccount1;
       
    }
/*** End Test code for PartnerScorecard Functionality ***/

  static testMethod void validateTestDataSharePartnerUpdate() 
    {
      
      Account testAccount1=new Account(Name='test12',BillingStreet='street',BillingCity='city',BillingState= 'CA', BillingCountry='USA', BillingPostalCode = '1331', Fleet_Size__c = 8, Segment__c = 'Services',RecordTypeId='01250000000DQBA');
      Account refAcc=new Account(Name='FedEx Ground Test',BillingStreet='street',BillingCity='city',BillingState= 'CA',BillingCountry='USA',BillingPostalCode = '7865',Fleet_Size__c = 8, Segment__c = 'Services',RecordTypeId='01250000000E5L8');
      //insert testAccount1;
      Database.DMLOptions dml = new Database.DMLOptions(); 
      dml.DuplicateRuleHeader.allowSave = true;
      dml.DuplicateRuleHeader.runAsCurrentUser = true;
      Database.SaveResult sr1 = Database.insert(testAccount1, dml);
      Database.DMLOptions dml1 = new Database.DMLOptions(); 
      dml1.DuplicateRuleHeader.allowSave = true;
      dml1.DuplicateRuleHeader.runAsCurrentUser = true;
      Database.SaveResult sr2 = Database.insert(refAcc, dml);
    //insert refAcc;
      Data_Sharing_Partner__c dsp = new Data_Sharing_Partner__c();
      dsp.Name = 'FedEx Ground Test';
      dsp.Related_Account__c = refAcc.id;
      insert dsp;
      testAccount1.Referral_Account__c = refAcc.id;
      update testAccount1;
      
    }
    
    static testMethod void validateAccountClosure() 
    {
      Account testAccount1=new Account(Name='test12',BillingStreet='street',BillingCity='city',BillingState= 'CA', BillingCountry='USA', BillingPostalCode = '1256', Fleet_Size__c = 3,Segment__c = 'Services', RecordTypeId='01250000000DQBA');
      //insert testAccount1;
      Database.DMLOptions dml = new Database.DMLOptions(); 
      dml.DuplicateRuleHeader.allowSave = true;
      dml.DuplicateRuleHeader.runAsCurrentUser = true;
      Database.SaveResult sr1 = Database.insert(testAccount1, dml);
      Opportunity opp=  new Opportunity();
      opp.name = 'test';
      opp.StageName = 'Sales Accepted (SAL)';
      opp.CloseDate = System.today() + 10;
      insert opp;
      testAccount1.QWBS_Status__c = 'Inactive Prospect';
      update testAccount1;
    }
    
    static testMethod void validateRecTypeChangePrevention() 
    {
      User currentUser = [select id ,Username from User where id= '00550000000vfNu' limit 1];
      Account testAccount1=new Account(Name='test12',BillingStreet='street',BillingCity='city',BillingState= 'CA', BillingCountry='USA',BillingPostalCode = '1256', Fleet_Size__c = 2,Segment__c = 'Services', RecordTypeId=System.Label.Account_Other_RecType);
      //insert testAccount1;
      Database.DMLOptions dml = new Database.DMLOptions(); 
      dml.DuplicateRuleHeader.allowSave = true;
      dml.DuplicateRuleHeader.runAsCurrentUser = true;
      Database.SaveResult sr1 = Database.insert(testAccount1, dml);
      
      System.runAs(currentUser)
      {
        testAccount1.RecordTypeId = '01250000000DQBA';
        update testAccount1;
      }
    }
    
}