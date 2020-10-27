/***********************************************************************************
Author: Vignesh Nayak S, Salesforce.com Developer
Tata Consultancy Services Limited
Description : Test Class written for Lead Object for Trigger(AllLeadTrigger)
************************************************************************************/
@istest(SeeAllData= True)
public class AllLeadTriggerTest_9
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
    
    Public Static TestMethod void LeadUpdateMetaData()
    {
        
        EnvDataValidation();
        //prmAccntQueueCombinationInstance = dataPreparation.CustomSettingDataInsertion(lstAccount[0], lsttestGroup[1], 2);
        
        //Insert prmAccntQueueCombinationInstance;
        
        User TestUser=[Select id,name, Usertype ,IsPortalEnabled from User where id =: lstUser[0].id ];
        
        System.runAs(new User(Id = Userinfo.getUserId()))
        {
            QueuesObject testQueue = dataPreparation.QueueCreation(lsttestGroup[0]); //lsttestGroup[0] = QueueIdValue
            GroupMember objGmInsert = dataPreparation.AddPRMMasterLeadQueueMember(TestUser.id);
            //Insert testQueue;
            //Insert objGmInsert;
            QueuesObject queueInserted = [select id, SObjectType from QueuesObject limit 1];
            System.assert(queueInserted.id != null,'Test Queue Created'); 
           
            GroupMember groupMemberInserted = [Select id,UserOrGroupId from GroupMember where UserOrGroupId= : TestUser.id 
                                                limit 1];
            System.assert(groupMemberInserted.id != null,'Test Queue Member Added');
            
            // Disti Partner
            PartnerMasterOwnerAccountInstance = dataPreparation.PartnerMasterOwnerAccountInsertion(accountIdValue); 
            Insert PartnerMasterOwnerAccountInstance;
            // Master Partner Queue
            PRMMasterLeadQueueInstance = dataPreparation.PRMMasterLeadQueueInsertion(queueIdValue); 
            //Insert PRMMasterLeadQueueInstance;
            
            list<Lead> lstLeadInsert= [select id from lead limit 1];
              
            List<Lead> lstLeadFrmDB=[Select id, name, PartnerAccount__c,OwnerId,  IF_Current_Owner_Type__c, IF_Marketing_Cycle__c,
                                     IF_Original_Partner_Lead_source__c,IF_Lead_Source_Type__c, Lead_Source_Most_Recent__c,
                                     LeadSource, SIC_Description_General__c, SIC_Description_Detailed__c, SIC_Reporting_Description__c,
                                     Lifecycle_Status__c, Status,Record_Owner__c,IF_Current_Queue_Name__c,Company_Lead_Created_By__c,
                                     Last_Queue_Owner__c from Lead where id = : lstLeadInsert];
            
            System.assertEquals(lstLeadInsert.size(),lstLeadFrmDB.size());
            if(lstLeadInsert.size() > 0)
            {
                List<TIS_Detail_Opp_Lead__c> lstTISDetail =[Select id, name,state__c,Lead__c from TIS_Detail_Opp_Lead__c 
                                                            where Lead__c=: lstLeadInsert ORDER BY CreatedDate ASC ];
                for(Integer i=0;i<lstLeadFrmDB.size() ;i++)
                {  
                    lstLeadFrmDB[i].OwnerId = TestUser.id ;
                }
                //old lead owner is in PMR Queue or master partner queue AND new lead has a PartnerAccountID not owned by disti partner user
                //Update lstLeadFrmDB;   
                List<Lead> lstUpdatedLead= [Select id, name, Last_Queue_Owner__c,OwnerId,Assigned_From_MPQ_QES_Date__c, 
                                            Assigned_From_MPQ_QES__c,Accepted_By_PANA_Disti_Date__c ,Accepted_By_PANA_Disti__c,
                                            Accepted_By_VAR_Date__c,Accepted_By_VAR__c,Assigned_From_VAR__c,Assigned_From_VAR_Date__c
                                            from Lead where id = : lstLeadFrmDB];
                System.assertEquals(lstLeadFrmDB.size(), lstUpdatedLead.size(),'Updated Lead');
                for(Integer i=0;i<lstUpdatedLead.size() ;i++)
                {
                    lstUpdatedLead[i].OwnerId = queueIdValue;
                }
                //Update lstUpdatedLead;
                List<Lead> lstUpdatedLead1= [Select id, name, Last_Queue_Owner__c,OwnerId,Assigned_From_MPQ_QES_Date__c, 
                                            Assigned_From_MPQ_QES__c,Accepted_By_PANA_Disti_Date__c ,Accepted_By_PANA_Disti__c,
                                             Assigned_From_PANA_Disti__c , Assigned_From_PANA_Disti_Date__c, First_assigned_VAR__c,
                                             Assigned_To_VAR_From_MPQ_QES__c, Last_Assigned_From_MPQ_to_Partner_Date__c,Last_Assigned_From_MPQ_to_Partner__c
                                            from Lead where id = : lstUpdatedLead];
                
            } 
        }
            
    }*/
    }