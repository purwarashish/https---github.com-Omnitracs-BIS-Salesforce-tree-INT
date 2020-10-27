public class TestScoringUtility {
    
   /*  public static void allAccountUtilCS() { 
         
         AllAccountUtils__c a1 = new AllAccountUtils__c();
         a1.Name = 'BILLING_ADDRESS';
         insert a1;
         
         AllAccountUtils__c a2 = new AllAccountUtils__c();
         a2.Name = 'PHONE';
         insert a2;
         
         AllAccountUtils__c a3 = new AllAccountUtils__c();
         a3.Name = 'ACCOUNT_TYPE';
         insert a3;
         
         AllAccountUtils__c a4 = new AllAccountUtils__c();
         a4.Name = 'MARKET';
         insert a4;
         
         AllAccountUtils__c a5 = new AllAccountUtils__c();
         a5.Name = 'DISTRICT';
         insert a5;
         
         AllAccountUtils__c a6 = new AllAccountUtils__c();
         a6.Name = 'STATUS';
         insert a6;
         
         AllAccountUtils__c a7 = new AllAccountUtils__c();
         a7.Name = 'LEAD_SOURCE';
         insert a7;
         
         AllAccountUtils__c a8 = new AllAccountUtils__c();
         a8.Name = 'AVG_LEN_HAUL';
         insert a8;
         
         AllAccountUtils__c a9 = new AllAccountUtils__c();
         a9.Name = 'REG_VEHICLES';
         insert a9;
         
         AllAccountUtils__c a10 = new AllAccountUtils__c();
         a10.Name = 'OTR_VEHICLES';
         insert a10;
         
         AllAccountUtils__c a11 = new AllAccountUtils__c();
         a11.Name = 'PRIMARY_BUSINESS';
         insert a11;
         
         AllAccountUtils__c a12 = new AllAccountUtils__c();
         a12.Name = 'PRIMARY_COMMODITY';
         insert a12;
         
         AllAccountUtils__c a13 = new AllAccountUtils__c();
         a13.Name = 'EVAL_CUSTOMERS';
         insert a13;
         
         AllAccountUtils__c a14 = new AllAccountUtils__c();
         a14.Name = 'CONTRACT_CUSTOMER';
         insert a14;
         
         
     } */
    
  /*  public static void allAccountRecordTypesCS() {
        
         RecordType rp=[select ID from RecordType where Name='T&L Sales Partner Account'];
         
         RecordType rpb =[select ID from RecordType where Name='Competitor' limit 1];
         
         AccountRecordTypes__c a = new AccountRecordTypes__c();
         a.RecordTypeID__c = rp.Id;
         a.Name = 'TL_SALES_ACCOUNT_RECORD_TYPE_ID';
         insert a;
         
         AccountRecordTypes__c b = new AccountRecordTypes__c();
         b.Name = 'COMPETITOR_RECORD_TYPE_ID';
         b.RecordTypeID__c = rpb.Id;
         insert b;
        
    }   */
    
    //Creating Account object
    public static Account createAccount() {
        
         RecordType rp=[select ID from RecordType where Name='T&L Sales Accounts'];
         
         Account acct = new Account();
         acct.Name = 'Test';
         acct.Primary_Business_Unit__c = 'Omnitracs Domestic';
         acct.Phone = '123456789';
         acct.Account_Classification__c = 'VAR';
         acct.Account_Status__c = 'Active';
         acct.RecordTypeId = rp.Id;
         acct.BillingStreet = 'Test';
         acct.BillingCity = 'Test';
         acct.BillingCountry = 'Test';
         acct.BillingPostalCode = 'Test';
         acct.BillingState = 'Test';
         acct.fleet_size__c = 25;
         acct.Segment__c = 'TL';
         acct.Account_Type__c = 'Rental';
         acct.QWBS_Market__c = 'T&L';
         acct.District__c = 'West District 1';
         acct.QWBS_Status__c = 'Closed Contract Customer';
         acct.Lead_Source__c = 'Cap Database';
         acct.Average_Length_of_Haul__c = 'Regional (100-500 miles)';
         acct.Regional_Vehicles__c = 10;
      // acct.OTR_Vehicles__c = 10;
      // acct.Primary_Commodity__c = 'Unknown';
         insert acct;
        
         return acct;
        
    }
    
    //Creating Account_Scoring__c object
    public static Account_Scoring__c createAccountScoring() {
        
         Account_Scoring__c obj = new Account_Scoring__c();
         obj.Scoring_Model__c = 'Test';
         obj.Date_Manual_Scoring__c = system.today().addDays(-1);
         obj.Is_Manual_Scoring__c = true;
         obj.Manual_Score__c = 10;
         obj.Manual_Scoring_Reason__c = 'Reason1';
         obj.Manual_Scoring_Comments__c = 'Test';
         obj.Date__c = system.today();
         obj.Display_Type__c = 'Yellow';
         obj.History__c = False;
         
        return obj;
        
    }
    
    //Creating Scoring_Model__c object
    public static Scoring_Model__c createScoringModel() {
        
        Scoring_Model__c sm = new Scoring_Model__c();
        sm.Name = 'TestSM';
        sm.Green_Overall_Score_From__c =  100;
        sm.Red_Overall_Score_From__c =  0;
        sm.Green_Overall_Score_To__c = 1000; 
        sm.Yellow_Overall_Score_To__c =  99;
        sm.Red_Overall_Score_To__c =  9;
        sm.Yellow_Overall_Score_From__c = 10;
        insert sm;
        
        return sm;
        
    }
    
    //Creating Scoring_Item__c object
    public static Scoring_Item__c createScoringItem() {
        
        Scoring_Item__c s = new Scoring_Item__c();
        s.Name = 'Test';
        s.Green_Score_From__c = 100;
        s.Red_Score_From__c =  0;
        s.Scoring_Weight__c = 5;
        s.Green_Score_To__c =  1000;
        s.Yellow_Score_To__c =  99;
        s.Red_Score_To__c =  9;
        s.Yellow_Score_From__c = 10;
         
        return s;
        
    }

}