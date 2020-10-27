@isTest(SeeAllData=True)
public class TestConnectionValidation {
    static testmethod void ContractSoftwareOnAccount() {
        Connection_Type__c conn = new Connection_Type__c ();
        NMC_Account__c NMCAcct = new NMC_Account__c (Name = 'Test', 
        NMC_Account_Name__c = 'Test NMC Name');
        account acct1 = new account(Name = 'My Test',
        BillingStreet = '123 Main', BillingCity = 'San Diego', BillingState = 'CA');

        acct1.BillingCountry = 'USA';
        insert Acct1;
        NMCAcct.Account__c = acct1.Id;
        insert NMCAcct;
        conn.NMC_Account__c = NMCAcct.Id;
        insert conn;
        system.debug(conn);
        try {update acct1;} catch (system.dmlexception e){
            system.assert(e.getmessage().contains('required'),e.getmessage());
        }
        
        conn.CI_Type__c = 'Persistant';
        conn.Connection_Status__c = 'Active';
        conn.CI_1__c = NULL;
        try {update conn;} catch (system.dmlexception e){
            system.assert(e.getmessage().contains('CI 1 is required'),e.getmessage());
        }
        conn.CI_1__c = 'abc';
        conn.CI_Type__c = 'Persistant';
        conn.Frame_LV_7507_IP__c = 123;
        conn.Frame_SD_Broadcast__c = 123;
        conn.Frame_LV_Broadcast__c = 123;
        conn.LV_T1_CKT__c = 'abc';
        conn.SD_T1_CKT__c = 'abc';
        conn.Port_on_LV_Router__c = 'abc';
        conn.Frame_LV_IP_Prefix__c = 'abc';
        conn.Frame_LV_Network__c = 123;
        conn.Frame_SD_Network__c = 123;
        conn.Cust_Local_Circuit_ID__c = 'abc';
        conn.LV_Ethernet__c = 'abc';
        conn.SD_Ethernet__c = 'abc';
        conn.Cust_S0_1_S2_0_to_LV_IP__c = 'abc';
        conn.Cust_S0_1_S2_0_to_SD_IP__c = 'abc';
        conn.Frame_SD_IP_Prefix__c = 'abc';
        conn.Frame_LV_IP_Prefix__c = 'abc';
        conn.Frame_SD_7507_IP__c = 123;
        conn.Frame_LV_7507_IP__c = 123;
        conn.Connection_Status__c.Startswith('Active');
        conn.Port_on_SD_Router__c = 'abc';
        conn.Port_on_LV_Router__c = 'abc';
        conn.Connection_Type__c = 'Frame Relay';

        conn.Frame_SD_7507_IP__c = NULL;
        try {update conn;} catch (system.dmlexception e){
            system.assert(e.getmessage().contains('required'),e.getmessage());
        }       
        conn.Frame_SD_7507_IP__c = 123; 

        conn.Frame_LV_7507_IP__c = NULL;
        try {update conn;} catch (system.dmlexception e){
            system.assert(e.getmessage().contains('required'),e.getmessage());
        }       
        conn.Frame_LV_7507_IP__c = 123;                 
        
        
        conn.DBU__c = 'DBU 800';
        conn.Cust_to_QC_DBU_SD__C = NULL;
        try {update conn;} catch (system.dmlexception e){
            system.assert(e.getmessage().contains('QC DBU'),e.getmessage());
        }
        conn.LV_Ethernet__c = NULL;
        try {update conn;} catch (system.dmlexception e){
            system.assert(e.getmessage().contains('required'),e.getmessage());
        }       
        conn.LV_Ethernet__c = 'abc';

        conn.SD_Ethernet__c = NULL;
        try {update conn;} catch (system.dmlexception e){
            system.assert(e.getmessage().contains('required'),e.getmessage());
        }       
        conn.SD_Ethernet__c = 'abc';        
        
        conn.DBU__c = 'DBU Local';
        conn.Cust_to_QC_DBU_SD__C = NULL;
        try {update conn;} catch (system.dmlexception e){
            system.assert(e.getmessage().contains('QC DBU'),e.getmessage());
        }
        conn.Cust_to_QC_DBU_LV__C = NULL;
        try {update conn;} catch (system.dmlexception e){
            system.assert(e.getmessage().contains('QC DBU'),e.getmessage());
        }                       
        conn.Connection_Type__c = 'VPN';
        conn.Connection_Status__c = 'Active';
        conn.Date_Activated__c = NULL;
        try {update conn;} catch (system.dmlexception e){
            system.assert(e.getmessage().contains('Date Activated'),e.getmessage());
        }
        conn.Connection_Type__c = 'Dial in Local';
        conn.Connection_Status__c = 'Active';
        conn.Comm_Protocol__c = 'Not Async';
        conn.Date_Activated__c = null;
        conn.NMC_Password__c = null;
       try {update conn;} catch (system.dmlexception e){
         system.assert(e.getmessage().contains('Date Activated'),e.getmessage());
      }
    }
}