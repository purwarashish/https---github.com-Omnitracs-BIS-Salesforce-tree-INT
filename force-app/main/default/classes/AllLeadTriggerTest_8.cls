/***********************************************************************************
Author: Vignesh Nayak S, Salesforce.com Developer
Tata Consultancy Services Limited
Description : Test Class written for Lead Object for Trigger(AllLeadTrigger)
************************************************************************************/
@istest(SeeAllData= True)
public class AllLeadTriggerTest_8
{
   /* Static LeadTestData dataPreparation = new LeadTestData();
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
        Test.startTest();
        
        lstAccount = [Select id, name from Account where Primary_Business_Unit__c = 'RoadNet' and Account_Status__c='Active' limit 5];
        
        lsttestGroup = [Select id, name from Group where type='Queue' limit 1];
        
        prmAccntQueueCombinationInstance = dataPreparation.CustomSettingDataInsertion(lstAccount[4], lsttestGroup[0], 1);
        Insert prmAccntQueueCombinationInstance;
        
        
        lstContact = [Select id, name from Contact  limit 4];
        
        
        lstUser = [Select Id, name,ContactId, Usertype ,IsPortalEnabled from User where isActive = true limit 1 ];
        
        
        lstSic = [Select Id, name,Description_General__c,Description_Detailed__c, Reporting__c
                  from SIC__c limit 1];
        
        lstDataSharaPartner = [Select id, name from Data_Sharing_Partner__c limit 1];
        
        objCountry=[Select id, name from Country_And_Country_Code__c limit 1];
        
        userType = dataPreparation.UsersUserType();
        Test.stopTest();
    } 
    // Vaidation of Test data creation. 
    Public static TestMethod void  EnvDataValidation()
    {
        EnvDataCreation();
        
        
        PRMAcctQueueCombination__c insertedValue= PRMAcctQueueCombination__c.getInstance('TestData1');
        queueIdValue=insertedValue.QueueIds__c;
        accountIdValue = insertedValue.AccountId__c;
        System.assert(queueIdValue.length()>1);
        System.assertEquals(queueIdValue, lsttestGroup[0].Id,'Queue ID in custom setting');
        System.assertEquals(accountIdValue, lstAccount[4].Id,'Account ID in custom setting');
    }
    
    Public static TestMethod void GroupLeadInsertUpdation() //00QW0000003ReS4
    {   
        
        EnvDataValidation();
        System.runAs(new User(Id = Userinfo.getUserId()))
        {   
            
            //QueuesObject testQueue = dataPreparation.QueueCreation(lsttestGroup[0]); //lsttestGroup[0] = QueueIdValue
            QueuesObject testQueue = new QueueSObject(QueueID = lsttestGroup[0].id, SObjectType = 'Lead');
            Insert testQueue;
            QueuesObject queueInserted = [select id, SObjectType from QueuesObject limit 1];
            
            list<Lead> lstLeadInsert= [select id from lead where isConverted = false limit 1];
            GroupMember objGmInsert = dataPreparation.AddPRMMasterLeadQueueMember(lstUser[0].Id);
            Insert objGmInsert;
            for(Lead L :lstLeadInsert)
            {
                L.ownerId = lstUser[0].Id;
            }
            //Insert lstLeadInsert;
            for(Lead L :lstLeadInsert)
            {
                L.ownerId = QueueIdvalue;
            }
            Update lstLeadInsert;
            List<Lead> lstLeadInsert1 = [Select id, name, Assigned_From_VAR__c, Assigned_From_VAR_Date__c,
                                         Assigned_To_VAR_From_MPQ_QES__c ,Last_Assigned_From_MPQ_to_Partner_Date__c,
                                         Last_Assigned_From_MPQ_to_Partner__c from lead where id =:lstLeadInsert ];
            
           
            
         }
                
    }*/
    }