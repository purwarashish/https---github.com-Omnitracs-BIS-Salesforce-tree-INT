/***********************************************************************************
Author: Vignesh Nayak S, Salesforce.com Developer
Tata Consultancy Services Limited
Description : Test Class written for Lead Object for Trigger(AllLeadTrigger)
************************************************************************************/
@istest(SeeAllData= True)
public class AllLeadTriggerTest_7
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
      
    }    */
    }