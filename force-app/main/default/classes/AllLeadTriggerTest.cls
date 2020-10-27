/***********************************************************************************
Author: Vignesh Nayak S, Salesforce.com Developer
Tata Consultancy Services Limited
Description : Test Class written for Lead Object for Trigger(AllLeadTrigger)
************************************************************************************/
@istest(SeeAllData= True)
public class AllLeadTriggerTest 
{
    Static LeadTestData dataPreparation = new LeadTestData();
    Static List<Account> lstAccount = new List<Account>();
    Static List<Account> lstIPAccounts = new List<Account>();//
    Static List<Contact> lstContact = new list<Contact>();
    Static List<User> lstUser = new List<User>();
    Static List<lead> lstlead = new List<lead>();//
    Static List<lead> lstleadforIPA = new List<lead>();//
    Static List<SIC__c> lstSic = new list<SIC__c>();
    Static List<X3rd_Party_Contract_Service__c> lstX3rdPartyContractService = new list<X3rd_Party_Contract_Service__c>();//
    Static List<Competitive_Knowledge__c> lstCompetitiveKnowledge = new list<Competitive_Knowledge__c>();//
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
        Database.DMLOptions dml = new Database.DMLOptions();
        dml.DuplicateRuleHeader.AllowSave = true; 
        Database.insert(lstAccountToBeInserted, dml);
        //Insert lstAccountToBeInserted;
        lstAccount = [Select id, name from Account where id =: lstAccountToBeInserted];
        
        List<Account> lstIntegrationPartnerAccounts = dataPreparation.IntegrationPartnerAccountsCreation(lstLeadforIPA);
        Database.DMLOptions dml1 = new Database.DMLOptions(); 
        dml.DuplicateRuleHeader.allowSave = true;
        dml.DuplicateRuleHeader.runAsCurrentUser = true;
        Account testAccount1 = new Account(Name='dupe1');
        Database.SaveResult sr1 = Database.insert(testAccount1, dml);
        if (sr1.isSuccess()) {
            System.debug('Duplicate account has been inserted in Salesforce!');
        }
        Insert lstIntegrationPartnerAccounts;
        lstIPAccounts = [Select id, name from Account where id =: lstIntegrationPartnerAccounts];
        
        List<Group> lstGroupToBeInserted = dataPreparation.InsertGroup();
        Insert lstGroupToBeInserted;
        lsttestGroup = [Select id, name from Group where id =: lstGroupToBeInserted];
        
        prmAccntQueueCombinationInstance = dataPreparation.CustomSettingDataInsertion(lstAccount[4], lsttestGroup[0], 1);
        Insert prmAccntQueueCombinationInstance;
        
        List<Contact> lstContactToBeInserted = dataPreparation.ContactCreation(lstAccount);
        Insert lstContactToBeInserted;
        lstContact = [Select id, name from Contact where id =: lstContactToBeInserted];
        
        List<Competitive_Knowledge__c> lstCompetitiveKnowledgeToBeInserted = dataPreparation.CompetitiveKnowledgeCreation(lstLead);
        Insert lstCompetitiveKnowledgeToBeInserted;
        lstCompetitiveKnowledge = [Select id, name from Competitive_Knowledge__c where id =: lstCompetitiveKnowledgeToBeInserted];
        
        List<X3rd_Party_Contract_Service__c> lstX3rdPartyContractServiceToBeInserted = dataPreparation.X3rdPartyContractServiceCreation(lstLead, lstIPAccounts);
        Insert lstX3rdPartyContractServiceToBeInserted;
        lstX3rdPartyContractService = [Select id, name from X3rd_Party_Contract_Service__c where id =: lstX3rdPartyContractServiceToBeInserted];
        
        List<User> lstUserToBeInserted = dataPreparation.UserCreation(lstContact);
        Insert lstUserToBeInserted;
        lstUser = [Select Id, name,ContactId, Usertype ,IsPortalEnabled from User where id =: lstUserToBeInserted];
        
        List<SIC__c> lstSicToBeInserted = dataPreparation.SICCreation();
        Insert lstSicToBeInserted;
        lstSic = [Select Id, name,Description_General__c,Description_Detailed__c, Reporting__c
                  from SIC__c where id =: lstSicToBeInserted];
        
        List<Data_Sharing_Partner__c> lstDataSharaPartnerToBeInserted = dataPreparation.DataSharaPartnerInsert(lstAccount);
        Insert lstDataSharaPartnerToBeInserted;
        lstDataSharaPartner = [Select id, name from Data_Sharing_Partner__c where id =: lstDataSharaPartnerToBeInserted];
        
        Country_And_Country_Code__c objCountryToBeInserted = dataPreparation.InsertCountryAndCountryCode();
        Insert objCountryToBeInserted;
        objCountry=[Select id, name from Country_And_Country_Code__c where id = : objCountryToBeInserted.Id];
        
        userType = dataPreparation.UsersUserType();
        
    } 
    // Vaidation of Test data creation. 
    Public static void  EnvDataValidation()
    {
        EnvDataCreation();
        System.assert(lstAccount.size() == 5, 'Account Creation');
        System.assert(lstContact.size() == 3, 'Contact Creation');
        System.assert(lstUser.size() == 4, 'User Creation');
        System.assert(lstCompetitiveKnowledge.size() == lstLead.size(), 'Competitive Knowledge Creation');
        System.assert((lsttestGroup.size() ==2 ), 'Group Creation');
        System.assert(lstSic.size() >1 , 'SIC Creation');
        System.assert(lstDataSharaPartner.size()==4, 'Data Share Partner Creation');
        System.assert((objCountry.Id != null), 'Country Creation');
        System.assert((userType.size()>1), 'userType');
        
        PRMAcctQueueCombination__c insertedValue= PRMAcctQueueCombination__c.getInstance('TestData1');
        queueIdValue=insertedValue.QueueIds__c;
        accountIdValue = insertedValue.AccountId__c;
        System.assert(queueIdValue.length()>1);
        System.assertEquals(queueIdValue, lsttestGroup[0].Id,'Queue ID in custom setting');
        System.assertEquals(accountIdValue, lstAccount[4].Id,'Account ID in custom setting');
    }
    // Portal User Lead Creation. Hence IF_Lead_Source_Type__c field of Lead will be Portal
    // SIC, Lead Source Most Recent, Original Partner Lead Source fields are provided
    /*Public static TestMethod void PortalUserLeadInsert() //
    {   
        EnvDataValidation();
        User TestUser=[Select id,name, Usertype ,IsPortalEnabled,AccountId from User where id =: lstUser[0].id ];
        Test.startTest();
        List<Lead> lstLeadFrmDB;
        System.runAs(TestUser)
        {
            list<Lead> lstLeadInsert= dataPreparation.LeadDataToBeInserted('PortalUser',null);     
            Insert lstLeadInsert;
            if(lstLeadInsert.size() > 0)
            {
                lstLeadFrmDB=[Select id, name, PartnerAccount__c,OwnerId,  IF_Current_Owner_Type__c, IF_Marketing_Cycle__c,
                                         IF_Original_Partner_Lead_source__c,IF_Last_Status_Update__c, Record_Owner__c, IF_Lead_Source_Type__c, 
                                         Lead_Source_Most_Recent__c, LeadSource, Company_Lead_Created_By__c, Partner_Disti__c, State,
                                         SIC_Description_General__c, SIC_Description_Detailed__c, SIC_Reporting_Description__c,IF_Partner_Queue_ID__c,
                                         IsConverted,PartnerAccountId from Lead where id = : lstLeadInsert]; //PartnerAccount
                System.assertEquals(lstLeadInsert.size(),lstLeadFrmDB.size(),'Lead Query From DB');
                List<TIS_Detail_Opp_Lead__c> lstTISDetail =[Select id, name,state__c,Lead__c from TIS_Detail_Opp_Lead__c 
                                                            where Lead__c=: lstLeadInsert];
                System.assertEquals(lstTISDetail.size(),lstLeadFrmDB.size());
                for(Integer i=0;i<lstLeadFrmDB.size() ;i++)
                {  
                    System.assertEquals(userType[0],lstLeadFrmDB[i].IF_Lead_Source_Type__c, 'Lead Source Type (IF_Lead_Source_Type__c) = Partner');
                    System.assertEquals(userType[0],lstLeadFrmDB[i].IF_Current_Owner_Type__c,'Current Owner Type');
                    System.assertEquals(TestUser.Id , lstLeadFrmDB[i].OwnerId,'Lead Owner');
                    //System.assertEquals(lstLeadFrmDB[i].Lead_Source_Most_Recent__c, lstLeadFrmDB[i].LeadSource, 'Lead Source Updated');
                    System.assertEquals(lstAccount[4].name,lstLeadFrmDB[i].Partner_Disti__c,'Reseller/Distributor');
                    System.assertEquals(lstLeadFrmDB[i].Record_Owner__c , lstLeadFrmDB[i].OwnerId,'Record Owner');
                    System.assertEquals(lstAccount[4].Id , lstLeadFrmDB[i].PartnerAccount__c,'Partner Acct');
                    System.assertEquals( lstAccount[4].Id , lstLeadFrmDB[i].PartnerAccountId,'Partner Account');
                    System.assertEquals( 0 ,lstLeadFrmDB[i].IF_Marketing_Cycle__c); 
                    System.assertEquals('FL',lstLeadFrmDB[i].State, 'State'); 
                    System.assertEquals(queueIdValue,lstLeadFrmDB[i].IF_Partner_Queue_ID__c,'Partner Queue + Custom Setting');
                    System.assertEquals(TestUser.Id,lstLeadFrmDB[i].Record_Owner__c,'Record Owner');
                    System.assertEquals(lstSic[i].Description_General__c, lstLeadFrmDB[i].SIC_Description_General__c);
                    System.assertEquals(lstSic[i].Description_Detailed__c, lstLeadFrmDB[i].SIC_Description_Detailed__c);
                    System.assertEquals(lstSic[i].Reporting__c, lstLeadFrmDB[i].SIC_Reporting_Description__c);
                    System.assertEquals(lstLeadFrmDB[i].Id, lstTISDetail[i].Lead__c ,'TIS_Lead');
                    System.assertEquals('owner', lstTISDetail[i].name ,'TIS_Name: Owner or Group');
                    System.assertEquals(TestUser.Name, lstTISDetail[i].State__c ,'TIS_Lead');  
                }
            }
        }
        Test.stopTest();
    }
    // Lead Creation for Assignment rule.
    Public static TestMethod void GroupARLeadInsert()
    {   
        EnvDataValidation(); 
        User TestUser=[Select id,name, Usertype ,IsPortalEnabled from User where id =: lstUser[1].id ];
        Test.startTest();
        System.runAs(TestUser)
        {
            list<Lead> lstLeadInsert= dataPreparation.LeadDataToBeInserted('Group',null);
            Insert lstLeadInsert;
            //System.assertEquals(dataPreparation.AR.Name,'Master Lead Rules','Lead assignment Rule Name');
            if(lstLeadInsert.size() > 0)
            {
                List<Lead> lstLeadFrmDB=[Select id, name, PartnerAccount__c,OwnerId,  IF_Current_Owner_Type__c, IF_Marketing_Cycle__c,
                                         IF_Original_Partner_Lead_source__c,IF_Last_Status_Update__c, Record_Owner__c, IF_Lead_Source_Type__c, 
                                         Lead_Source_Most_Recent__c, LeadSource, Company_Lead_Created_By__c, Partner_Disti__c, State,
                                         SIC_Description_General__c, SIC_Description_Detailed__c, SIC_Reporting_Description__c,Lifecycle_Status__c,
                                         IF_Current_Queue_Name__c, Status,IF_Partner_Queue_ID__c from Lead where id = : lstLeadInsert 
                                         ORDER BY CreatedDate ASC];
                
                System.assertEquals(lstLeadInsert.size(),lstLeadFrmDB.size());
                
                List<TIS_Detail_Opp_Lead__c> lstTISDetail =[Select id, name,state__c,Lead__c from TIS_Detail_Opp_Lead__c 
                                                            where Lead__c=: lstLeadInsert ORDER BY CreatedDate ASC ];
                System.assertEquals(lstTISDetail.size(),(2 * lstLeadFrmDB.size()));
                for(Integer i=0;i<lstLeadFrmDB.size() ;i++)
                {  
                    System.assertEquals('MQL',lstLeadFrmDB[i].Lifecycle_Status__c);
                    System.assertEquals(lstLeadFrmDB[i].Lifecycle_Status__c,lstLeadFrmDB[i].Status,'Lead Status');
                    System.assertEquals( lstLeadFrmDB[i].Lead_Source_Most_Recent__c, lstLeadFrmDB[i].LeadSource, 'Lead Source Updated');
                    System.assertEquals(lstSic[i].Description_General__c, lstLeadFrmDB[i].SIC_Description_General__c);
                    System.assertEquals(lstSic[i].Description_Detailed__c, lstLeadFrmDB[i].SIC_Description_Detailed__c);
                    System.assertEquals(lstSic[i].Reporting__c, lstLeadFrmDB[i].SIC_Reporting_Description__c);
                    System.assertEquals('BDR',lstLeadFrmDB[i].IF_Current_Queue_Name__c,'Lead assignment to Queue');
                    System.assertEquals(userType[1],lstLeadFrmDB[i].IF_Lead_Source_Type__c,'Lead Source Type');
                    System.assertEquals('Queue',lstLeadFrmDB[i].IF_Current_Owner_Type__c);
                    System.assertEquals(System.label.Qualcomm_Account_Id,lstLeadFrmDB[i].Company_Lead_Created_By__c,'Company Lead Created By');
                    System.assertEquals(null, lstLeadFrmDB[i].Record_Owner__c,'Record Owner = Null');
                }
            }
        }
        Test.stopTest();     
    }
    
    Public static TestMethod void NormalUserLeadInsertOwnerUpdate()
    {   
        Integer j=0;
        EnvDataValidation();
        User TestUser=[Select id,name, Usertype ,IsPortalEnabled,Profile.Name,UserRoleId  from User where id =: lstUser[2].id ];
        Test.startTest();
        System.runAs(TestUser)
        {   
            list<Lead> lstLeadInsert= dataPreparation.LeadDataToBeInserted('NormalUser',null);          
            Insert lstLeadInsert;
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
                    System.debug('#Company Lead Created By'+lstLeadFrmDB[i].Company_Lead_Created_By__c);
                    System.assertEquals( null , lstLeadFrmDB[i].PartnerAccount__c,'Partner Acct');
                    System.assertEquals(TestUser.Id,lstLeadFrmDB[i].Record_Owner__c,'Record Owner');
                    System.assertEquals(TestUser.Id,lstLeadFrmDB[i].OwnerId,'Owner Id');
                    System.assertEquals( 0 ,lstLeadFrmDB[i].IF_Marketing_Cycle__c);
                    System.assertEquals(userType[2],lstLeadFrmDB[i].IF_Lead_Source_Type__c, 'Lead Source Type (IF_Lead_Source_Type__c) = Partner');
                    System.assertEquals( lstLeadFrmDB[i].Lead_Source_Most_Recent__c, lstLeadFrmDB[i].LeadSource, 'Lead Source Updated');
                    //System.assertEquals( System.label.Qualcomm_Account_Id , lstLeadFrmDB[i].Company_Lead_Created_By__c, 'Company Lead Created By');
                    System.assertEquals(null,lstLeadFrmDB[i].Partner_Disti__c,'Reseller/Distributor');
                    System.assertEquals(lstSic[i].Description_General__c, lstLeadFrmDB[i].SIC_Description_General__c);
                    System.assertEquals(lstSic[i].Description_Detailed__c, lstLeadFrmDB[i].SIC_Description_Detailed__c);
                    System.assertEquals(lstSic[i].Reporting__c, lstLeadFrmDB[i].SIC_Reporting_Description__c);
                    System.assertEquals( lstLeadFrmDB[i].Record_Owner__c , lstLeadFrmDB[i].OwnerId,'Record Owner');
                    System.assertEquals(userType[2],lstLeadFrmDB[i].IF_Current_Owner_Type__c,'Current Owner Type');
                    System.assertEquals( 'FL' ,lstLeadFrmDB[i].State, 'State'); 
                    System.assertEquals(lstDataSharaPartner[j].Id, lstLeadFrmDB[i].Data_Share_Partner__c , 'Data Share Partner');
                    System.assertEquals(TestUser.UserRoleId , lstLeadFrmDB[i].Lead_Owner_Role__c, 'Lead Owner Role');
                    if(i>=2 && i<4)
                    { // Poplating Referral details on Lead
                        System.assert((lstLeadFrmDB[i].Primary_Contact_Name__c != null) , 'Referral Name');
                        System.assert((lstLeadFrmDB[i].Primary_Contact_Phone__c != null) , 'Referral Phone');
                        System.assert((lstLeadFrmDB[i].Primary_Contact_Email__c != null) , 'Referral email');
                    }
                    System.assertEquals(lstLeadFrmDB[i].Id, lstTISDetail[i].Lead__c ,'TIS_Lead');
                    System.assertEquals('owner', lstTISDetail[i].name ,'TIS_Name: Owner or Group');
                    System.assertEquals(TestUser.Name, lstTISDetail[i].State__c ,'TIS_Lead');
                    lstLeadFrmDB[i].OwnerId=lstUser[0].id;//testGroup.Id; //BDR
                }
                Update lstLeadFrmDB;
                List<Lead> lstUpdatedLead= [Select id, name, Last_Queue_Owner__c,OwnerId,Assigned_From_MPQ_QES_Date__c, 
                                            Assigned_From_MPQ_QES__c,Accepted_By_PANA_Disti_Date__c ,
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
        Test.stopTest();
    }
    */
 /*   Public static TestMethod void NormalUserLeadInsertUpdate()
    {   
        Integer j=0,k=0;
        EnvDataValidation();
        User TestUser=[Select id,name, Usertype ,IsPortalEnabled,Profile.Name,UserRoleId  from User where id =: lstUser[3].id ];
        InterfaceUsers = dataPreparation.InterfaceUsersInsertion(TestUser.id);
        Insert InterfaceUsers;
        Test.startTest();
        System.runAs(TestUser)
        {   
            list<Lead> lstLeadInsert= dataPreparation.LeadDataToBeInserted('NormalUser',null);          
            Insert lstLeadInsert;
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
                    System.debug('#Company Lead Created By'+lstLeadFrmDB[i].Company_Lead_Created_By__c);
                    System.assertEquals( null , lstLeadFrmDB[i].PartnerAccount__c,'Partner Acct');
                    System.assertEquals(TestUser.Id,lstLeadFrmDB[i].Record_Owner__c,'Record Owner');
                    System.assertEquals(TestUser.Id,lstLeadFrmDB[i].OwnerId,'Owner Id');
                    System.assertEquals( 0 ,lstLeadFrmDB[i].IF_Marketing_Cycle__c);
                    System.assertEquals(userType[3],lstLeadFrmDB[i].IF_Lead_Source_Type__c, 'Lead Source Type (IF_Lead_Source_Type__c) = Partner');
                    System.assertEquals( lstLeadFrmDB[i].Lead_Source_Most_Recent__c, lstLeadFrmDB[i].LeadSource, 'Lead Source Updated');
                    //System.assertEquals( System.label.Qualcomm_Account_Id , lstLeadFrmDB[i].Company_Lead_Created_By__c, 'Company Lead Created By');
                    System.assertEquals(null,lstLeadFrmDB[i].Partner_Disti__c,'Reseller/Distributor');
                    System.assertEquals(lstSic[i].Description_General__c, lstLeadFrmDB[i].SIC_Description_General__c);
                    System.assertEquals(lstSic[i].Description_Detailed__c, lstLeadFrmDB[i].SIC_Description_Detailed__c);
                    System.assertEquals(lstSic[i].Reporting__c, lstLeadFrmDB[i].SIC_Reporting_Description__c);
                    System.assertEquals( lstLeadFrmDB[i].Record_Owner__c , lstLeadFrmDB[i].OwnerId,'Record Owner');
                    System.assertEquals(userType[3],lstLeadFrmDB[i].IF_Current_Owner_Type__c,'Current Owner Type');
                    System.assertEquals( 'FL' ,lstLeadFrmDB[i].State, 'State'); 
                    System.assertEquals(lstDataSharaPartner[j].Id, lstLeadFrmDB[i].Data_Share_Partner__c , 'Data Share Partner');
                    System.assertEquals(TestUser.UserRoleId , lstLeadFrmDB[i].Lead_Owner_Role__c, 'Lead Owner Role');
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
                /* Update the Lead Fields */
               /* User newLeadOwner=[Select id,name, Usertype ,IsPortalEnabled,Profile.Name,UserRoleId  from User where id =: lstUser[2].id ];
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
        Test.stopTest();
    }*/
    // Lead Creation and conversion of lead to account and Contact and 
    // transferring the respective Competitive Knowledge, X3rd Party Contract Service.
    /*Public static TestMethod void NormalUserLeadInsertConvert()
    {   
        Integer j=0,k=0;
        LeadOwnerAssignmentController.isSendEmail =true;
        List<Account> lstIntegrationPartnerAccounts = new List<Account>();
        EnvDataValidation();
        User TestUser=[Select id,name, Usertype ,IsPortalEnabled,Profile.Name,UserRoleId  from User where id =: lstUser[3].id ];
        Test.startTest();
        System.runAs(TestUser)
        {
            list<Lead> lstLeadInsert= dataPreparation.LeadDataToBeInserted('NormalUser',null);          
            Insert lstLeadInsert;
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
                for(Integer i=0;i<lstLeadFrmDB.size() ;i++)
                {  
                    j = math.mod(i,4);
                    System.debug('#Company Lead Created By'+lstLeadFrmDB[i].Company_Lead_Created_By__c);
                    System.assertEquals( null , lstLeadFrmDB[i].PartnerAccount__c,'Partner Acct');
                    System.assertEquals(TestUser.Id,lstLeadFrmDB[i].Record_Owner__c,'Record Owner');
                    System.assertEquals(TestUser.Id,lstLeadFrmDB[i].OwnerId,'Owner Id');
                    System.assertEquals( 0 ,lstLeadFrmDB[i].IF_Marketing_Cycle__c);
                    System.assertEquals(userType[3],lstLeadFrmDB[i].IF_Lead_Source_Type__c, 'Lead Source Type (IF_Lead_Source_Type__c) = Partner');
                    System.assertEquals( lstLeadFrmDB[i].Lead_Source_Most_Recent__c, lstLeadFrmDB[i].LeadSource, 'Lead Source Updated');
                    //System.assertEquals( System.label.Qualcomm_Account_Id , lstLeadFrmDB[i].Company_Lead_Created_By__c, 'Company Lead Created By');
                    System.assertEquals(null,lstLeadFrmDB[i].Partner_Disti__c,'Reseller/Distributor');
                    System.assertEquals(lstSic[i].Description_General__c, lstLeadFrmDB[i].SIC_Description_General__c);
                    System.assertEquals(lstSic[i].Description_Detailed__c, lstLeadFrmDB[i].SIC_Description_Detailed__c);
                    System.assertEquals(lstSic[i].Reporting__c, lstLeadFrmDB[i].SIC_Reporting_Description__c);
                    System.assertEquals( lstLeadFrmDB[i].Record_Owner__c , lstLeadFrmDB[i].OwnerId,'Record Owner');
                    System.assertEquals(userType[3],lstLeadFrmDB[i].IF_Current_Owner_Type__c,'Current Owner Type');
                    System.assertEquals( 'FL' ,lstLeadFrmDB[i].State, 'State'); 
                    System.assertEquals(lstDataSharaPartner[j].Id, lstLeadFrmDB[i].Data_Share_Partner__c , 'Data Share Partner');
                    System.assertEquals(TestUser.UserRoleId , lstLeadFrmDB[i].Lead_Owner_Role__c, 'Lead Owner Role');
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
        Test.stopTest();
    } */
    Public static TestMethod void StateValidation()
    {   
        String COUNTRY_VALIDATION = 'This country name does not match any of the valid countries stored in the Country Object';
        String STATE_CAPITALIZATION='State must be capitalized and use 2 letter abbreviation';
        String FIELD_VALIDATION='Required Field is Missing';
        String COUNTRY_BLANK='Country must be specified';
        String ExceptionMessage;
        EnvDataValidation();
        List<Data_Sharing_Partner__c> lstDataSharaPartner1 = [select id,Related_Account__c from Data_Sharing_Partner__c 
                                                              where id= : lstDataSharaPartner ];
        Lead objLead = dataPreparation.LeadInsertion();
        ObjLead.Referral_Account__c=lstAccount[0].Id;
        objLead.Country=null;
        Try
        {   
            Insert objLead;
        }
        Catch(Exception e)
        {
            ExceptionMessage= e.getMessage();
            System.debug('$$$$$Error0$$Blank Country = '+ExceptionMessage);
        }
        //System.assert((ExceptionMessage.contains(COUNTRY_BLANK)),'Country Blank' );
        
        ExceptionMessage=null;
        objLead.Country='InvalidState';
        Try
        {   
            Insert objLead;
        }
        Catch(Exception e)
        {
            ExceptionMessage= e.getMessage();
        }
        //System.assert((ExceptionMessage.contains(COUNTRY_VALIDATION)),'Country Validation' );
        
        ExceptionMessage=null;
        objLead.Country='u.s.a.';
        Try
        {   
            Insert objLead;
        }
        Catch(Exception e)
        {
            ExceptionMessage= e.getMessage();
        }
        //System.assert((ExceptionMessage.contains(FIELD_VALIDATION)),'City Validation' );
        
        
        ExceptionMessage=null;
        objLead.City='TestCity';
        Try
        {   
            Insert objLead;
        }
        Catch(Exception e)
        {
            ExceptionMessage= e.getMessage();
        }
        //System.assert((ExceptionMessage.contains(FIELD_VALIDATION)),'State Validation' );
        
        ExceptionMessage=null;
        objLead.State='TestState';
        Try
        {   
            Insert objLead;
        }
        Catch(Exception e)
        {
            ExceptionMessage= e.getMessage();
        }
        //System.assert((ExceptionMessage.contains(STATE_CAPITALIZATION)),'State Capitalization' );
        
        ExceptionMessage=null;
        objLead.State='AD';
        Try
        {   
            Insert objLead;
        }
        Catch(Exception e)
        {
            ExceptionMessage= e.getMessage();
        }
        //System.assert((ExceptionMessage.contains(STATE_CAPITALIZATION)),'State Capitalization' );
        
        ExceptionMessage=null;
        objLead.State='FL';
        Try
        {   
            Insert objLead;
        }
        Catch(Exception e)
        {
            ExceptionMessage= e.getMessage();
        }
        
        //System.assert((ExceptionMessage==null),'Lead Inserted');
        Lead ObjLeadInserted=[Select Id, Name, State, Country, City, Data_Share_Partner__c, Referral_Account__c from Lead 
                              where id =:objLead.Id ];
        //System.assert((ObjLeadInserted.Id != null),'Lead Inserted');
        //System.assert((ObjLeadInserted.Country=='United States'),'Lead Country');
        //System.assertEquals(lstDataSharaPartner[0].Id, ObjLeadInserted.Data_Share_Partner__c,'Data Share Partner');
    }    
    /*Public static TestMethod void GroupLeadInsertUpdation() //00QW0000003ReS4
    {   
        EnvDataValidation();
        
        System.runAs(new User(Id = Userinfo.getUserId()))
        {   
            Test.startTest();
            QueuesObject testQueue = dataPreparation.QueueCreation(lsttestGroup[0]); //lsttestGroup[0] = QueueIdValue
            Insert testQueue;
            QueuesObject queueInserted = [select id, SObjectType from QueuesObject where QueueId = : lsttestGroup[0].id];
            System.assert(queueInserted.id != null,'Test Queue Created'); 
        
            list<Lead> lstLeadInsert= dataPreparation.LeadDataToBeInserted('NormalUser',null);
            GroupMember objGmInsert = dataPreparation.AddPRMMasterLeadQueueMember(lstUser[0].Id);
            Insert objGmInsert;
            for(Lead L :lstLeadInsert)
            {
                L.ownerId = lstUser[0].Id;
            }
            Insert lstLeadInsert;
            for(Lead L :lstLeadInsert)
            {
                L.ownerId = QueueIdvalue;
            }
            Update lstLeadInsert;
            
            Test.stopTest();
         }
        
    }
    Public Static TestMethod void LeadUpdateMetaData()
    {
        EnvDataValidation();
        prmAccntQueueCombinationInstance = dataPreparation.CustomSettingDataInsertion(lstAccount[0], lsttestGroup[1], 2);
        Insert prmAccntQueueCombinationInstance;
        User TestUser=[Select id,name, Usertype ,IsPortalEnabled from User where id =: lstUser[0].id ];
        Test.startTest();
        System.runAs(new User(Id = Userinfo.getUserId()))
        {
            QueuesObject testQueue = dataPreparation.QueueCreation(lsttestGroup[0]); //lsttestGroup[0] = QueueIdValue
            GroupMember objGmInsert = dataPreparation.AddPRMMasterLeadQueueMember(TestUser.id);
            Insert testQueue;
            Insert objGmInsert;
            QueuesObject queueInserted = [select id, SObjectType from QueuesObject where QueueId = : lsttestGroup[0].id];
            System.assert(queueInserted.id != null,'Test Queue Created'); 
           
            GroupMember groupMemberInserted = [Select id,UserOrGroupId from GroupMember where UserOrGroupId= : TestUser.id 
                                               and GroupId=:PRMMasterLeadQueue__c.getInstance('Partner Queue').PRMMasterQueue__c];
            System.assert(groupMemberInserted.id != null,'Test Queue Member Added');
            
            // Disti Partner
            PartnerMasterOwnerAccountInstance = dataPreparation.PartnerMasterOwnerAccountInsertion(accountIdValue); 
            Insert PartnerMasterOwnerAccountInstance;
            // Master Partner Queue
            PRMMasterLeadQueueInstance = dataPreparation.PRMMasterLeadQueueInsertion(queueIdValue); 
            //Insert PRMMasterLeadQueueInstance;
            
            list<Lead> lstLeadInsert= dataPreparation.LeadDataToBeInserted('NormalUserGroup',queueIdValue);
            Insert lstLeadInsert;   
            List<Lead> lstLeadFrmDB=[Select id, name, PartnerAccount__c,OwnerId,  IF_Current_Owner_Type__c, IF_Marketing_Cycle__c,
                                     IF_Original_Partner_Lead_source__c,IF_Lead_Source_Type__c, Lead_Source_Most_Recent__c,
                                     LeadSource, SIC_Description_General__c, SIC_Description_Detailed__c, SIC_Reporting_Description__c,
                                     Lifecycle_Status__c, Status,Record_Owner__c,IF_Current_Queue_Name__c,Company_Lead_Created_By__c,
                                     Last_Queue_Owner__c from Lead where id = : lstLeadInsert];
            
            //System.assertEquals(lstLeadInsert.size(),lstLeadFrmDB.size());
            if(lstLeadInsert.size() > 0)
            {
                List<TIS_Detail_Opp_Lead__c> lstTISDetail =[Select id, name,state__c,Lead__c from TIS_Detail_Opp_Lead__c 
                                                            where Lead__c=: lstLeadInsert ORDER BY CreatedDate ASC ];
                //System.assertEquals(lstTISDetail.size(),lstLeadFrmDB.size());
                for(Integer i=0;i<lstLeadFrmDB.size() ;i++)
                {  
                    System.assertEquals(QueueIdValue,lstLeadFrmDB[i].OwnerId,'Lead Owner Id');
                    System.assertEquals(lstLeadFrmDB[i].Lifecycle_Status__c,lstLeadFrmDB[i].Status,'Lead Status');
                    System.assertEquals( lstLeadFrmDB[i].Lead_Source_Most_Recent__c, lstLeadFrmDB[i].LeadSource, 'Lead Source Updated');
                    System.assertEquals(lstSic[i].Description_General__c, lstLeadFrmDB[i].SIC_Description_General__c);
                    System.assertEquals(lstSic[i].Description_Detailed__c, lstLeadFrmDB[i].SIC_Description_Detailed__c);
                    System.assertEquals(lstSic[i].Reporting__c, lstLeadFrmDB[i].SIC_Reporting_Description__c);
                    System.assertEquals(userType[1],lstLeadFrmDB[i].IF_Lead_Source_Type__c,'Lead Source Type');
                    System.assertEquals('TestGroup0',lstLeadFrmDB[i].IF_Current_Queue_Name__c,'Lead assignment to Queue');
                    System.assertEquals('Queue',lstLeadFrmDB[i].IF_Current_Owner_Type__c);
                    System.assertEquals(null, lstLeadFrmDB[i].Record_Owner__c,'Record Owner = Null');
                    System.assertEquals(System.label.Qualcomm_Account_Id,lstLeadFrmDB[i].Company_Lead_Created_By__c,'Company Lead Created By');
                    System.assertEquals(null, lstLeadFrmDB[i].Last_Queue_Owner__c, 'Last Queue Owner');
                    lstLeadFrmDB[i].OwnerId = TestUser.id ;
                }
                //old lead owner is in PMR Queue or master partner queue AND new lead has a PartnerAccountID not owned by disti partner user
                Update lstLeadFrmDB;   
                List<Lead> lstUpdatedLead= [Select id, name, Last_Queue_Owner__c,OwnerId,Assigned_From_MPQ_QES_Date__c, 
                                            Assigned_From_MPQ_QES__c,Accepted_By_PANA_Disti_Date__c ,
                                            Accepted_By_VAR_Date__c,Assigned_From_VAR__c,Assigned_From_VAR_Date__c
                                            from Lead where id = : lstLeadFrmDB];
                //System.assertEquals(lstLeadFrmDB.size(), lstUpdatedLead.size(),'Updated Lead');
                for(Integer i=0;i<lstUpdatedLead.size() ;i++)
                {
                    System.assertEquals('TestGroup0', lstUpdatedLead[i].Last_Queue_Owner__c, 'Queue Name'); 
                    System.assertEquals(TestUser.Id , lstUpdatedLead[i].OwnerId, 'Owner updated to Portal User');
                    lstUpdatedLead[i].OwnerId = queueIdValue;
                }
                Update lstUpdatedLead;
                List<Lead> lstUpdatedLead1= [Select id, name, Last_Queue_Owner__c,OwnerId,Assigned_From_MPQ_QES_Date__c, 
                                            Assigned_From_MPQ_QES__c,Accepted_By_PANA_Disti_Date__c ,
                                             Assigned_From_PANA_Disti__c , Assigned_From_PANA_Disti_Date__c, First_assigned_VAR__c,
                                             Assigned_To_VAR_From_MPQ_QES__c,Last_Assigned_From_MPQ_to_Partner__c
                                            from Lead where id = : lstUpdatedLead];
                System.assertEquals(lstLeadFrmDB.size(), lstUpdatedLead1.size(),'Updated Lead');
                for(Integer i=0;i<lstUpdatedLead.size() ;i++)
                {
                    System.assertEquals('Master Partner Queue', lstUpdatedLead1[i].Last_Queue_Owner__c, 'Queue Name'); 
                    System.assertEquals(queueIdValue, lstUpdatedLead1[i].OwnerId, 'Owner updated to Queue');
                    System.assertEquals(True, lstUpdatedLead1[i].Assigned_From_PANA_Disti__c  , 'Assigned From PANA Disti');  
                    System.assert(lstUpdatedLead1[i].Assigned_From_PANA_Disti_Date__c !=null, 'Assigned From PANA Disti Date'); 
                    System.assertEquals(lstUpdatedLead1[i].First_assigned_VAR__c,accountIdValue,'First assigned VAR');
                } 
            } 
        }
        Test.stopTest();     
    }*/
    Public static TestMethod void ByPassTrigger()
    {   
        EnvDataValidation();
        Profile UserProfileToDisable =[Select id, name from profile where name ='Reseller Partner Profile (No MDF)'];
        ByPassTrigger__c UserProfile = dataPreparation.ByPassTriggerInsertion(UserProfileToDisable.Id);
        Interface_Users__c UserProfile1 = dataPreparation.InterfaceUsersInsertion(UserProfileToDisable.Id);
        Insert UserProfile;
        Insert UserProfile1;
        User TestUser=[Select id, name, Usertype ,IsPortalEnabled from User where id =: lstUser[0].id ];
        Test.startTest();
        System.runAs(TestUser)
        {
            Lead objLead = dataPreparation.LeadInsertion();
            objLead.Country='USA';
            objLead.State = 'CA'; 
            Insert objLead;
            System.assert(objLead.Id != null,'Lead Creation');
        }
    }
    
    Public Static TestMethod void LeadUpdateMetaData()
    {
        EnvDataValidation();
        prmAccntQueueCombinationInstance = dataPreparation.CustomSettingDataInsertion(lstAccount[0], lsttestGroup[1], 2);
        Insert prmAccntQueueCombinationInstance;
        User TestUser=[Select id,name, Usertype ,IsPortalEnabled from User where id =: lstUser[0].id ];
        Test.startTest();
        System.runAs(new User(Id = Userinfo.getUserId()))
        {
            QueuesObject testQueue = dataPreparation.QueueCreation(lsttestGroup[0]); //lsttestGroup[0] = QueueIdValue
            GroupMember objGmInsert = dataPreparation.AddPRMMasterLeadQueueMember(TestUser.id);
            Insert testQueue;
            Insert objGmInsert;
            QueuesObject queueInserted = [select id, SObjectType from QueuesObject where QueueId = : lsttestGroup[0].id];
            System.assert(queueInserted.id != null,'Test Queue Created'); 
           
            GroupMember groupMemberInserted = [Select id,UserOrGroupId from GroupMember where UserOrGroupId= : TestUser.id 
                                               and GroupId=:PRMMasterLeadQueue__c.getInstance('Partner Queue').PRMMasterQueue__c];
            System.assert(groupMemberInserted.id != null,'Test Queue Member Added');
            
            // Disti Partner
            PartnerMasterOwnerAccountInstance = dataPreparation.PartnerMasterOwnerAccountInsertion(accountIdValue); 
            Insert PartnerMasterOwnerAccountInstance;
            // Master Partner Queue
            PRMMasterLeadQueueInstance = dataPreparation.PRMMasterLeadQueueInsertion(queueIdValue); 
            //Insert PRMMasterLeadQueueInstance;
            
            list<Lead> lstLeadInsert= dataPreparation.LeadDataToBeInserted('NormalUserGroup',queueIdValue);
            Insert lstLeadInsert;   
            List<Lead> lstLeadFrmDB=[Select id, name, OwnerId,  IF_Current_Owner_Type__c, 
                                     IF_Lead_Source_Type__c, Lead_Source_Most_Recent__c,
                                     LeadSource, SIC_Description_General__c, SIC_Description_Detailed__c, SIC_Reporting_Description__c,
                                     Lifecycle_Status__c, Status,Record_Owner__c,Company_Lead_Created_By__c,
                                     Last_Queue_Owner__c from Lead where id = : lstLeadInsert];
            
            //System.assertEquals(lstLeadInsert.size(),lstLeadFrmDB.size());
            if(lstLeadInsert.size() > 0)
            {
                List<TIS_Detail_Opp_Lead__c> lstTISDetail =[Select id, name,state__c,Lead__c from TIS_Detail_Opp_Lead__c 
                                                            where Lead__c=: lstLeadInsert ORDER BY CreatedDate ASC ];
                //System.assertEquals(lstTISDetail.size(),lstLeadFrmDB.size());
                for(Integer i=0;i<lstLeadFrmDB.size() ;i++)
                {  
                    System.assertEquals(QueueIdValue,lstLeadFrmDB[i].OwnerId,'Lead Owner Id');
                    System.assertEquals(lstLeadFrmDB[i].Lifecycle_Status__c,lstLeadFrmDB[i].Status,'Lead Status');
                    System.assertEquals( lstLeadFrmDB[i].Lead_Source_Most_Recent__c, lstLeadFrmDB[i].LeadSource, 'Lead Source Updated');
                    System.assertEquals(lstSic[i].Description_General__c, lstLeadFrmDB[i].SIC_Description_General__c);
                    System.assertEquals(lstSic[i].Description_Detailed__c, lstLeadFrmDB[i].SIC_Description_Detailed__c);
                    System.assertEquals(lstSic[i].Reporting__c, lstLeadFrmDB[i].SIC_Reporting_Description__c);
                //  System.assertEquals(userType[1],lstLeadFrmDB[i].IF_Lead_Source_Type__c,'Lead Source Type');
                 // System.assertEquals('TestGroup0',lstLeadFrmDB[i].IF_Current_Queue_Name__c,'Lead assignment to Queue');
                    System.assertEquals('Queue',lstLeadFrmDB[i].IF_Current_Owner_Type__c);
                    System.assertEquals(null, lstLeadFrmDB[i].Record_Owner__c,'Record Owner = Null');
                    System.assertEquals(System.label.Qualcomm_Account_Id,lstLeadFrmDB[i].Company_Lead_Created_By__c,'Company Lead Created By');
                    System.assertEquals(null, lstLeadFrmDB[i].Last_Queue_Owner__c, 'Last Queue Owner');
                    lstLeadFrmDB[i].OwnerId = TestUser.id ;
                }
                //old lead owner is in PMR Queue or master partner queue AND new lead has a PartnerAccountID not owned by disti partner user
                Update lstLeadFrmDB;   
                List<Lead> lstUpdatedLead= [Select id, name, Last_Queue_Owner__c,OwnerId
                                            from Lead where id = : lstLeadFrmDB];
                //System.assertEquals(lstLeadFrmDB.size(), lstUpdatedLead.size(),'Updated Lead');
                for(Integer i=0;i<lstUpdatedLead.size() ;i++)
                {
                    System.assertEquals('TestGroup0', lstUpdatedLead[i].Last_Queue_Owner__c, 'Queue Name'); 
                    System.assertEquals(TestUser.Id , lstUpdatedLead[i].OwnerId, 'Owner updated to Portal User');
                    lstUpdatedLead[i].OwnerId = queueIdValue;
                }
                Update lstUpdatedLead;
                List<Lead> lstUpdatedLead1= [Select id, name, Last_Queue_Owner__c,OwnerId
                                            from Lead where id = : lstUpdatedLead];
                System.assertEquals(lstLeadFrmDB.size(), lstUpdatedLead1.size(),'Updated Lead');
                for(Integer i=0;i<lstUpdatedLead.size() ;i++)
                {
                    System.assertEquals('Master Partner Queue', lstUpdatedLead1[i].Last_Queue_Owner__c, 'Queue Name'); 
                    System.assertEquals(queueIdValue, lstUpdatedLead1[i].OwnerId, 'Owner updated to Queue');
                 // System.assertEquals(True, lstUpdatedLead1[i].Assigned_From_PANA_Disti__c  , 'Assigned From PANA Disti');  
                 // System.assert(lstUpdatedLead1[i].Assigned_From_PANA_Disti_Date__c !=null, 'Assigned From PANA Disti Date'); 
                 // System.assertEquals(lstUpdatedLead1[i].First_assigned_VAR__c,accountIdValue,'First assigned VAR');
                } 
            } 
        }
        Test.stopTest();     
    }
}