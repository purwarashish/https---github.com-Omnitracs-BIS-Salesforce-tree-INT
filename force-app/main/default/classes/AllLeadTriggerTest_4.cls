/***********************************************************************************
Author: Vignesh Nayak S, Salesforce.com Developer
Tata Consultancy Services Limited
Description : Test Class written for Lead Object for Trigger(AllLeadTrigger)
************************************************************************************/
@istest(SeeAllData= True)
public class AllLeadTriggerTest_4
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
Public static TestMethod void NormalUserLeadInsertUpdate()
    {   
        Integer j=0,k=0;
        EnvDataValidation();
        User TestUser = [Select id,name, Usertype ,IsPortalEnabled,Profile.Name,UserRoleId  from User where id =: lstUser[0].id ];
        InterfaceUsers = dataPreparation.InterfaceUsersInsertion(TestUser.id);
        Insert InterfaceUsers;
        
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
                for(Integer i=0;i<lstLeadFrmDB.size();i++)
                {  
                    j = math.mod(i,4);
                 
                    if(i>=2 && i<4)
                    { // Poplating Referral details on Lead
                        System.assert((lstLeadFrmDB[i].Primary_Contact_Name__c != null) , 'Referral Name');
                        System.assert((lstLeadFrmDB[i].Primary_Contact_Phone__c != null) , 'Referral Phone');
                        System.assert((lstLeadFrmDB[i].Primary_Contact_Email__c != null) , 'Referral email');
                    }
                    System.assertEquals(lstLeadFrmDB[i].Id, lstTISDetail[i].Lead__c ,'TIS_Lead');
                    System.assertEquals('owner', lstTISDetail[i].name ,'TIS_Name: Owner or Group');
                    System.assertEquals(TestUser.Name, lstTISDetail[i].State__c ,'TIS_Lead');
                }
                
                User newLeadOwner=[Select id,name, Usertype ,IsPortalEnabled,Profile.Name,UserRoleId  from User where id =: lstUser[3].id ];
                for(Integer i=0;i<lstLeadFrmDB.size() ;i++)
                { 
                    k=(3-math.mod(i,4));
                    lstLeadFrmDB[i].Status='MI';
                    lstLeadFrmDB[i].OwnerId = newLeadOwner.Id;
                    lstLeadFrmDB[i].Referral_Account__c=lstAccount[k].id;
                }
                Update lstLeadFrmDB;
                
                List<Lead> lstUpdatedLead= [Select id, name, PartnerAccount__c,OwnerId, IF_Current_Owner_Type__c, IF_Marketing_Cycle__c,
                                            IF_Original_Partner_Lead_source__c,IF_Last_Status_Update__c, Record_Owner__c, IF_Lead_Source_Type__c, 
                                            Lead_Source_Most_Recent__c, LeadSource, Company_Lead_Created_By__c, Partner_Disti__c, State,
                                            SIC_Description_General__c, SIC_Description_Detailed__c, SIC_Reporting_Description__c,IF_Partner_Queue_ID__c,
                                            Data_Share_Partner__c, Primary_Contact_Name__c,Primary_Contact_Phone__c,
                                            Primary_Contact_Email__c,Lead_Owner_Role__c,Status,Hidden_Original_Lead_Source__c,Hidden2_Original_Lead_Source__c,  
                                            Hidden3_Original_Lead_Source__c,Referral_Account__c from Lead where id = : lstLeadFrmDB];
                
                for(Integer i=0;i<lstUpdatedLead.size() ;i++)
                {
                    k=(3-math.mod(i,4)); 
                    System.assertEquals( 1 ,lstUpdatedLead[i].IF_Marketing_Cycle__c);
                    System.assertEquals( lstUpdatedLead[i].LeadSource,lstUpdatedLead[i].Hidden_Original_Lead_Source__c);
                    System.assertEquals( lstUpdatedLead[i].LeadSource,lstUpdatedLead[i].Hidden2_Original_Lead_Source__c);
                    System.assertEquals( lstUpdatedLead[i].LeadSource,lstUpdatedLead[i].Hidden3_Original_Lead_Source__c);
                    System.assertEquals( lstDataSharaPartner[k].Id, lstUpdatedLead[i].Data_Share_Partner__c,'Updated Data Share Partner');
                }
            }
        }
       
    }*/
 }