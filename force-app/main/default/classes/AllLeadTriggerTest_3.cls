/***********************************************************************************
Author: Vignesh Nayak S, Salesforce.com Developer
Tata Consultancy Services Limited
Description : Test Class written for Lead Object for Trigger(AllLeadTrigger)
************************************************************************************/
@istest(SeeAllData= True)
public class AllLeadTriggerTest_3
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
Public static TestMethod void NormalUserLeadInsertOwnerUpdate()
    {   
        Integer j=0;
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
                GroupMember objGmInsert = dataPreparation.AddPRMMasterLeadQueueMember(TestUser.id);
                System.runAs(new User(Id = Userinfo.getUserId()))
                {
                Insert objGmInsert;
                }
                for(Integer i=0;i<lstLeadFrmDB.size() ;i++)
                {  
                    j = math.mod(i,4);
                    
                    if(i>=2 && i<4)
                    { // Poplating Referral details on Lead
                        System.assert((lstLeadFrmDB[i].Primary_Contact_Name__c != null) , 'Referral Name');
                        System.assert((lstLeadFrmDB[i].Primary_Contact_Phone__c != null) , 'Referral Phone');
                        System.assert((lstLeadFrmDB[i].Primary_Contact_Email__c != null) , 'Referral email');
                    }
                    
                    lstLeadFrmDB[i].OwnerId=lstUser[0].id;//testGroup.Id; //BDR
                }
                Update lstLeadFrmDB;
                List<Lead> lstUpdatedLead= [Select id, name, Last_Queue_Owner__c,OwnerId,Assigned_From_MPQ_QES_Date__c, 
                                            Assigned_From_MPQ_QES__c,Accepted_By_PANA_Disti_Date__c ,Accepted_By_PANA_Disti__c
                                            from Lead where id = : lstLeadFrmDB];
                System.assertEquals(lstLeadFrmDB.size(), lstUpdatedLead.size(),'Updated Lead');
                for(Integer i=0;i<lstUpdatedLead.size() ;i++)
                {
                    System.assertEquals('Master Partner Queue', lstUpdatedLead[i].Last_Queue_Owner__c, 'Queue Name'); 
                    System.assertEquals(True, lstUpdatedLead[i].Assigned_From_MPQ_QES__c , 'Assigned From MPQ QES');  
                    System.assert(lstUpdatedLead[i].Assigned_From_MPQ_QES_Date__c!=null, 'Assigned From MPQ QES Date'); 
                }
            }
        }
       
    }*/
}