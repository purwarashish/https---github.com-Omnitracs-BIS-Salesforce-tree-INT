/***********************************************************************************
Author: Vignesh Nayak S, Salesforce.com Developer
Tata Consultancy Services Limited
Description : Test Class written for Lead Object for Trigger(AllLeadTrigger)
************************************************************************************/
 
@istest(SeeAllData = true)
public class AllLeadTriggerTest_6
{
    /*Static LeadTestData dataPreparation = new LeadTestData();
    Static List<Account> lstAccount = new List<Account>();
    Static List<Contact> lstContact = new list<Contact>();
    Static List<User> lstUser = new List<User>(); 
    Static List<SIC__c> lstSic = new list<SIC__c>();
    Static List<X3rd_Party_Contract_Service__c> lstX3rdPartyContractService = new list<X3rd_Party_Contract_Service__c>();
    Static List<Competitive_Knowledge__c> lstCompetitiveKnowledge = new list<Competitive_Knowledge__c>();
    Static List<Data_Sharing_Partner__c> lstDataSharaPartner = new List<Data_Sharing_Partner__c>();
    Static Country_And_Country_Code__c objCountry; // United States country Insertion
    Static List<Group> lsttestGroup; // Group for Custom Setting
    Static List<String> userType = new List<String>(); // User Type like FSR, MKTG, ISR, Partner
    Static PRMAcctQueueCombination__c prmAccntQueueCombinationInstance; // Custom Setting of Account and Queue
    Static PRMMasterLeadQueue__c PRMMasterLeadQueueInstance; // Custom Setting of PRMMasterLeadQueue
    Static PartnerMasterOwnerAccount__c PartnerMasterOwnerAccountInstance; // Custom Setting of PartnerMasterOwnerAccount
    Static String queueIdValue; // Queue id w.r.t Account from custom Setting
    Static String accountIdValue;
    Static Interface_Users__c InterfaceUsers= new Interface_Users__c();
    
    Public static void EnvDataCreation()
    {
        List<Account> lstAccountToBeInserted = dataPreparation.AccountCreation();
        Insert lstAccountToBeInserted;
        lstAccount = [Select id, name from Account where id =: lstAccountToBeInserted];
        
        List<Group> lstGroupToBeInserted = dataPreparation.InsertGroup();
        Insert lstGroupToBeInserted;
        lsttestGroup = [Select id, name from Group where id =: lstGroupToBeInserted];
        
        prmAccntQueueCombinationInstance = dataPreparation.CustomSettingDataInsertion(lstAccount[4], lsttestGroup[0], 1);
        Insert prmAccntQueueCombinationInstance;
        Test.startTest();
        List<Contact> lstContactToBeInserted = dataPreparation.ContactCreation(lstAccount);
        Insert lstContactToBeInserted;
        
        lstContact = [Select id, name from Contact where id =: lstContactToBeInserted];
        
        List<User> lstUserToBeInserted = dataPreparation.UserCreation(lstContact);
        Insert lstUserToBeInserted;
        lstUser = [Select Id, name,ContactId, Usertype ,IsPortalEnabled from User where id =: lstUserToBeInserted];
        Test.stopTest();        
        List<SIC__c> lstSicToBeInserted = dataPreparation.SICCreation();
        Insert lstSicToBeInserted;
        lstSic = [Select Id, name,Description_General__c,Description_Detailed__c, Reporting__c
                  from SIC__c where id =: lstSicToBeInserted];
        
        List<Data_Sharing_Partner__c> lstDataSharaPartnerToBeInserted = dataPreparation.DataSharaPartnerInsert(lstAccount);
        Insert lstDataSharaPartnerToBeInserted;
        lstDataSharaPartner = [Select id, name from Data_Sharing_Partner__c where id =: lstDataSharaPartnerToBeInserted];
        Test.startTest();
        Country_And_Country_Code__c objCountryToBeInserted = dataPreparation.InsertCountryAndCountryCode();
        Insert objCountryToBeInserted;
        objCountry=[Select id, name from Country_And_Country_Code__c where id = : objCountryToBeInserted.Id];
        
        userType = dataPreparation.UsersUserType();
        
    }*/
 }