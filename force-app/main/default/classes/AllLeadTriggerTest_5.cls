/***********************************************************************************
Author: Vignesh Nayak S, Salesforce.com Developer
Tata Consultancy Services Limited
Description : Test Class written for Lead Object for Trigger(AllLeadTrigger)
************************************************************************************/
@istest(SeeAllData= True)
public class AllLeadTriggerTest_5
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
        
        lsttestGroup = [Select id, name from Group limit 1];
        
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
    // Lead Creation and conversion of lead to account and Contact and 
    // transferring the respective Competitive Knowledge, X3rd Party Contract Service.
    Public static TestMethod void NormalUserLeadInsertConvert()
    {   
        Integer j=0,k=0;
        LeadOwnerAssignmentController.isSendEmail =true;
        List<Account> lstIntegrationPartnerAccounts = new List<Account>();
        EnvDataValidation();
        User TestUser=[Select id,name, Usertype ,IsPortalEnabled,Profile.Name,UserRoleId  from User where id =: lstUser[0].id ];
        
        System.runAs(TestUser)
        {
            list<Lead> lstLeadInsert= [select id from Lead limit 1];          
            
            if(lstLeadInsert.size() > 0)
            {
                List<Lead> lstLeadFrmDB=[Select id, name, PartnerAccount__c,OwnerId,  IF_Current_Owner_Type__c, IF_Marketing_Cycle__c,
                                         IF_Original_Partner_Lead_source__c,IF_Last_Status_Update__c, Record_Owner__c, IF_Lead_Source_Type__c, 
                                         Lead_Source_Most_Recent__c, LeadSource, Company_Lead_Created_By__c, Partner_Disti__c, State,
                                         SIC_Description_General__c, SIC_Description_Detailed__c, SIC_Reporting_Description__c,IF_Partner_Queue_ID__c,
                                         Data_Share_Partner__c, Primary_Contact_Name__c,Primary_Contact_Phone__c,
                                         Primary_Contact_Email__c,Lead_Owner_Role__c,Status  from Lead where id = : lstLeadInsert]; //PartnerAccount
                System.assertEquals(lstLeadInsert.size(),lstLeadFrmDB.size());
                List<TIS_Detail_Opp_Lead__c> lstTISDetail =[Select id, name,state__c,Lead__c from TIS_Detail_Opp_Lead__c 
                                                            where Lead__c=: lstLeadInsert];
                System.assertEquals(lstTISDetail.size(),lstLeadFrmDB.size());
               
                lstIntegrationPartnerAccounts = dataPreparation.IntegrationPartnerAccountsCreation(lstLeadFrmDB);
                Insert lstIntegrationPartnerAccounts;
                lstCompetitiveKnowledge = dataPreparation.CompetitiveKnowledgeCreation(lstLeadFrmDB);
                Insert lstCompetitiveKnowledge;
                lstX3rdPartyContractService = dataPreparation.X3rdPartyContractServiceCreation(lstLeadFrmDB,lstIntegrationPartnerAccounts);
                Insert lstX3rdPartyContractService;
                Database.LeadConvert lc;
                Database.LeadConvertResult lcr;
                Integer leadConvertCount = 5;   // 7 Max possible value. Hits too many future calls 51 error.
                set<Id> setConvertedLeadId = new set<Id>();
                for(Integer i=0;i<leadConvertCount ;i++)
                { 
                    setConvertedLeadId.add(lstLeadFrmDB[i].Id);
                    lc = new database.LeadConvert();
                    lc.setLeadId(lstLeadFrmDB[i].id);
                    lc.setDoNotCreateOpportunity(true);
                    lc.setOwnerId(TestUser.id);
                    lc.setConvertedStatus('SQL');
                    lcr = Database.convertLead(lc);
                    System.assert(lcr.isSuccess(),'Lead Conversion');
                }
                System.assertEquals( lstLeadFrmDB.size() , lstIntegrationPartnerAccounts.size(),'Integration Partner Account');
                System.assertEquals( lstLeadFrmDB.size() , lstCompetitiveKnowledge.size(), 'Competative Knowledge Insertion');
                System.assertEquals( lstLeadFrmDB.size() , lstX3rdPartyContractService.size(), 'X3rd Party Contract Service Insertion');
                List<X3rd_Party_Contract_Service__c> lstUpdatedX3rdPartyContractService = [Select id, lead__c, Account__c from X3rd_Party_Contract_Service__c
                                                                                           where id in :lstX3rdPartyContractService ];
                List<Competitive_Knowledge__c> lstUpdatedCompetitiveKnowledge = [Select id, lead__c, Account__c from Competitive_Knowledge__c
                                                                                 Where id in :lstCompetitiveKnowledge ];
                List<Lead> lstUpdatedLead= [Select id, name, isConverted, ConvertedAccountId, ConvertedContactId
                                            from Lead where id = : setConvertedLeadId];
                for(Integer i=0;i<leadConvertCount ;i++)
                { 
                    System.assertEquals( True ,lstUpdatedLead[i].isConverted,'Lead Conversion');
                    System.assert( lstUpdatedLead[i].ConvertedAccountId != null);
                    System.assert( lstUpdatedLead[i].ConvertedContactId != null);
                }
            }
        }
       
    }*/
    }