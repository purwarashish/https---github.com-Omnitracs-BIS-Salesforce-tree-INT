/*
Author:Vignesh Nayak S
Date: 06/12/2015
Purpose: Test Class data preperation for lead Trigger test class.
Test Class : AllLeadTriggerTest
*/ 
public class LeadTestData
{   
    List<Account> lstAccount = new List<Account>();
    List<Contact> lstContact = new list<Contact>();
    List<User> lstUser = new List<User>(); 
    List<SIC__c> lstSic = new list<SIC__c>(); 
    List<Data_Sharing_Partner__c> lstDataSharaPartner = new List<Data_Sharing_Partner__c>();
    
    List<String> userType = new List<String>(); // User Type like FSR, MKTG, ISR, Partner
    list<SIC__c> lstSicInserted = new list<SIC__c>();
    QueueSObject testQueue; // Queue in Custom Setting
    PRMAcctQueueCombination__c prmAccntQueueCombinationInstance;
    PRMMasterLeadQueue__c PRMMasterLeadQueueInstance;
    PartnerMasterOwnerAccount__c PartnerMasterOwnerAccountInstance;
    AssignmentRule AR = new AssignmentRule();
    Integer RecordCount=10; // No: of Lead Records inserted
    String queueIdValue; // Queue id w.r.t Account from custom Setting
    ByPassTrigger__c UserProfile;
    Interface_Users__c InterfaceUsers;
    
    Public List<Account> AccountCreation()
    {          
        Account objAccount;
        for(Integer i=0; i<5; i++) // Keep i value more than 4
        {
            Database.DMLOptions dml = new Database.DMLOptions(); 
            dml.DuplicateRuleHeader.allowSave = true;
            dml.DuplicateRuleHeader.runAsCurrentUser = true;
            Account duplicateAccount = new Account(Name='dupe');
            Database.SaveResult sr = Database.insert(duplicateAccount, dml);
            if (sr.isSuccess()) {
                System.debug('Duplicate account has been inserted in Salesforce!');
            }
            objAccount = new Account();  // 4th Indexed account will have portal Users.
            objAccount.Name='TestAccount'+i;
            objAccount.Phone='(324)324-324'+i;
            /*objAccount.District__c='Strategic';*/
            objAccount.Segment__c='TL';
            objAccount.BillingStreet='Test Billing Street'+i;
            objAccount.BillingCity='Test Billing City'+i;
            objAccount.BillingCountry='Test Billing Country'+i;
            objAccount.BillingState='Test Billing State'+i;
            objAccount.BillingPostalCode='00001'+i;
            objAccount.Fleet_Size__c = 25;
            objAccount.Primary_Business_Unit__c='RoadNet';
        //  objAccount.Account_Status__c='Active';
            if(i==4)
            {  // This account has portal Enabled. 
                objAccount.Account_Classification__c='Prospect';
                objAccount.RecordTypeId=SearchRecordTypeID('T&L Sales Accounts','Account');
            }
            else if(i>=0 && i<2)
            {  
                objAccount.RecordTypeId=SearchRecordTypeID('Referral','Account');
                objAccount.Account_Classification__c='Sales Referral (SRP)';
                objAccount.Partner_Type__c ='Domestic';
                objAccount.Contract_Signed_Date__c = System.Today();
             // objAccount.Compensation_Type__c ='Paid';
             // objAccount.Primary_Contact_Name__c = 'TestReferal'+i;
             // objAccount.Primary_Contact_Email__c ='test@referral.com';
             // objAccount.Primary_Contact_Phone__c ='123123213'+i;
            }
            else if(i>=2 && i<4)
            {
                objAccount.RecordTypeId=SearchRecordTypeID('Partner','Account');
                objAccount.CurrencyIsoCode='USD';
                objAccount.Account_Status__c='Active';
                objAccount.QWBS_Market__c='Indirect';
                /*objAccount.District__c='Indirect';*/
                objAccount.Partner_Type__c ='Reseller';
            //  objAccount.Compensation_Type__c ='Paid';
                objAccount.Account_Manager__c= userInfo.getUserID();
            //  objAccount.Primary_Contact_Name__c = 'TestReferal'+i;
            //  objAccount.Primary_Contact_Email__c ='test@referral.com';
            //  objAccount.Primary_Contact_Phone__c ='123123213'+i;
            //  objAccount.Referral_Partner_ID__c = 'TestPartnerId'+i;
            } 
            lstAccount.add(objAccount);
        }
        return lstAccount;
    }
    
    Public List<Contact> ContactCreation(List<Account> lstAccount)
    {
        
        for(Integer i=0;i<3;i++)
        {
            Database.DMLOptions dml = new Database.DMLOptions(); 
            dml.DuplicateRuleHeader.allowSave = true;
            dml.DuplicateRuleHeader.runAsCurrentUser = true;
            Contact duplicateContact = new Contact(LastName='dupe');
            Database.SaveResult sr = Database.insert(duplicateContact, dml);
            if (sr.isSuccess()) {
            System.debug('Duplicate account has been inserted in Salesforce!');
            }
            Contact objContact= new Contact();
            objContact.AccountId=lstAccount[4].id;
            objContact.RecordTypeId=SearchRecordTypeID('Sales','Contact');
            objContact.LastName='TestContact'+i;
            objContact.Title='TestTitle'+i;
            objContact.Phone='(123)465-789'+i;
            objContact.Decision_Maker_Influencer__c='Yes';        
            objContact.LeadSource='800#';
            objContact.Lead_Origin__c='XRS';
            if(i==2)
            {
                objContact.AccountId=lstAccount[0].id;
            }
            lstContact.add(objContact);
        }
        return lstContact;
  }
    
    Public List<User> UserCreation(List<Contact> lstContact)
    {   
        String S;
        Map<String,id> mapProfileNameWithID=new Map<String,id>();
        List<Profile> lstprofile= ([select name,id from profile where name in
                                       ( 'Reseller Partner Profile (No MDF)','System Administrator')]);                
        for(Profile P : lstprofile)
        {
            mapProfileNameWithID.put(P.name,P.id);
        }
        for(Integer i=0;i<=3;i++)
        {  
            User U = new User();
            U.email = 'test'+i+'@testmail.com';
            U.emailencodingkey = 'UTF-8';
            U.lastname = 'TestLastName'+i;
            U.languagelocalekey = 'en_US';
            U.localesidkey='en_US';
            U.timezonesidkey = 'America/Denver';
            U.username = 'TestUserName'+i+'@omnitracs.com';
            if(i==0)
            {  
                S='Partner';
                U.ProfileId=mapProfileNameWithID.get('Reseller Partner Profile (No MDF)');
                userType.add(S);
                U.alias = userType[i];
                U.Lead_Reassignment_Role__c='Inside Sales Rep';
                U.ContactId=lstContact[0].Id;
            }
            else if(i==1)
            {  
                S='Mktg'; // As no lead assignment role is defined.
                userType.add(S);
                U.alias='SysAdmn'+i;
                U.ProfileId=mapProfileNameWithID.get('System Administrator');
            }
            else if(i==2)
            {
                S='FSR';
                userType.add(S);
                U.alias='SysAdmn'+i;
                u.Lead_Reassignment_Role__c='Field Sales Rep';
                U.ProfileId=mapProfileNameWithID.get('System Administrator');
            }
            else if(i==3)
            {
                S='ISR';
                userType.add(S);
                U.alias='SysAdmn'+i;
                u.Lead_Reassignment_Role__c='Inside Sales Rep';
                U.ProfileId=mapProfileNameWithID.get('System Administrator');
            }
            lstUser.add(U);
        }
        System.debug('User Length'+lstUser.size());
        return lstUser;
    }
    
    //Search Rercord Type id based on its name
    Public ID SearchRecordTypeID(String RecordTypeLabel,String SObjName)
    {  
        if(SObjName == 'Account')
        {
            return Schema.Sobjecttype.Account.getRecordTypeInfosByName().get(RecordTypeLabel).getRecordTypeId();
        }
        else if(SObjName == 'Contact')
        {
            return Schema.Sobjecttype.Contact.getRecordTypeInfosByName().get(RecordTypeLabel).getRecordTypeId();
        }
        else //if(ObjName=='Lead')
        {
            return Schema.Sobjecttype.Lead.getRecordTypeInfosByName().get(RecordTypeLabel).getRecordTypeId();
        }
    }
  
    // Insert United States Record into Country_And_Country_Code__c Object
    // This is referred in classes as well.
    Public Country_And_Country_Code__c InsertCountryAndCountryCode()
    {
        Country_And_Country_Code__c objCountry = new Country_And_Country_Code__c();
        objCountry.Name='United States';
        objCountry.ISO_Code_2__c='TC';
        objCountry.ISO_Code_3__c='Tes';
        objCountry.Region__c='Test Region';
        objCountry.CurrencyIsoCode='USD';
        return objCountry;
    }
    
    // Insertion of SIC__c record which will be referred in the test class. 
    Public List<SIC__c> SICCreation()
    {  
        SIC__c objSic;
        for(Integer i=0; i<RecordCount ; i++)
        {
            objSic = new SIC__c();
            objSic.Name = 'TSIC'+i;
            objSic.Description_Detailed__c = 'Test Detailed Description '+i;
            objSic.Description_General__c = 'AGRICULTURAL SERVICES';
            objSic.Legacy_Source_Id__c = 'Test Legacy Source '+i;
            objSic.Reporting__c = 'Test Reporting '+i;
            lstSic.add(objSic);
        }
        return lstSic;
    }   
    
    Public List<Group> InsertGroup()
    {
        List<Group> lstGrp = new List<Group>();
        Group testGrp;
        for(Integer i=0;i<2;i++)
        {
            testGrp= new Group();
            testGrp.Name='TestGroup'+i;
            testGrp.Type='Queue';
            lstGrp.add(testGrp);
        }
        return lstGrp;
    }
     
    // Data Share Partner Object Insertion of record
    Public List<Data_Sharing_Partner__c> DataSharaPartnerInsert(List<Account> lstAccount)
    {
        Data_Sharing_Partner__c objDataSharePartner;
        for(Integer i=0;i<4;i++)
        {
            objDataSharePartner = new Data_Sharing_Partner__c();
            objDataSharePartner.Name ='Test Data Share'+i;
            objDataSharePartner.Related_Account__c = lstAccount[i].Id;
            objDataSharePartner.CurrencyIsoCode='USD';
            lstDataSharaPartner.add(objDataSharePartner);
        }
        return lstDataSharaPartner;
    }
    
    // Lead Data preperation for bulk insertion
    Public List<Lead> LeadDataToBeInserted(String UserOrGroup, String QueueId)
    {
        list<Lead> lstLead= new list<Lead>();
        Lead objLead;
        Integer j;
        //Fetching the assignment rules on Lead
    /*    AR = [select id, Name from AssignmentRule where SobjectType = 'Lead' and Active = true limit 1];
        //Creating the DMLOptions for "Assign using active assignment rules" checkbox
        Database.DMLOptions dmlOpts = new Database.DMLOptions();
        dmlOpts.assignmentRuleHeader.assignmentRuleId= AR.id;*/
        
        lstSicInserted = [Select id, name ,Description_Detailed__c, Description_General__c, Legacy_Source_Id__c,
                          Reporting__c from SIC__c where id = :lstSic];
        for(Integer i=0;i<RecordCount;i++)
        {
            objLead = new Lead();
            j = math.mod(i,4);
            ObjLead.FirstName='Fname'+i;
            objLead.LastName ='Lname'+i;
            objLead.CurrencyIsoCode='USD';
            objLead.Phone='(080) 112-213'+i;
            objLead.Company='TestCompany'+i;
            objLead.Country='United States';
            objLead.City='TestCity'+i;
            objLead.QWBS_Product_Interest__c='OD - Positions and Messaging';
            objLead.SIC_Code__c=lstSicInserted[i].name;
            objLead.State='FL';
            if(UserOrGroup == 'PortalUser') 
            {  
                objLead.RecordTypeId= SearchRecordTypeID('Indirect','Lead');
                objLead.Status='Prequalified';
                objLead.Lead_Source_Most_Recent__c='800#';
             // objLead.IF_Original_Partner_Lead_Source__c = 'J&H Radio';
            }
            else if(UserOrGroup =='NormalUserGroup')
            {
                objLead.RecordTypeId= SearchRecordTypeID('Direct','Lead');
                objLead.Status='Prequalified';
             // objLead.Account_Status__c='Active';
             // objLead.Assigned_From_MPQ_QES_Date__c = null;
            //  objLead.Lead_Classification__c='Prospect';
                objLead.Lifecycle_Status__c='MQL'; // Condition for the Lead Assignment Rule.
                objLead.Lead_Origin__c='Omnitracs Domestic';
                objLead.LeadSource='800#';
                objLead.OwnerId=QueueId;
            }
            else if(UserOrGroup == 'Group')
            {  
                objLead.RecordTypeId= SearchRecordTypeID('Direct','Lead');
              //  objLead.setOptions(dmlOpts);
                objLead.Status='Prequalified';
             // objLead.Account_Status__c='Active';
             // objLead.Lead_Classification__c='Prospect';
                objLead.Lifecycle_Status__c='MQL'; // Condition for the Lead Assignment Rule.
                objLead.Lead_Origin__c='Omnitracs Domestic';
                objLead.LeadSource='800#';
            }
            else if(UserOrGroup =='NormalUser') // System Adminstrator
            {  
                objLead.Lifecycle_Status__c='MQL';
                if(i>=2 && i<4)
                { // Poplating Referral details on Lead
                //  objLead.Referral_Partner_ID__c='TestPartnerId'+i;
                    objLead.Lifecycle_Status__c='Rejected';
                }
                objLead.RecordTypeId= SearchRecordTypeID('Direct','Lead');
                objLead.Referral_Account__c = lstAccount[j].Id;
                objLead.Lead_Origin__c='Omnitracs Domestic';
                objLead.LeadSource='800#';
                objLead.Status='Prequalified';
             // objLead.Account_Status__c='Active';
             // objLead.Lead_Classification__c='Prospect';
            }
            lstLead.add(objLead);
        }
        Return lstLead;
    }   
    
    Public Lead LeadInsertion()
    {
        Lead ObjLead = new Lead();
        ObjLead.FirstName='Fname';
        objLead.LastName ='Lname';
        objLead.CurrencyIsoCode='USD';
        objLead.Phone='12123121723';
        objLead.Company='TestCompany';
        objLead.LeadSource='800#';
        objLead.Lifecycle_Status__c='MQL';
        objLead.Primary_Contact_Name__c = null;
        return objLead;
    }
    
    Public List<String> UsersUserType()
    {
        return userType;
    } 
    
    Public List<Competitive_Knowledge__c> CompetitiveKnowledgeCreation(List<Lead> lstLead)
    {   
        List<Competitive_Knowledge__c> lstCompetitiveKnowledge = new List<Competitive_Knowledge__c>();
        Competitive_Knowledge__c ObjCompetitiveKnowledge;
        for(Integer i=0;i<lstLead.size();i++)
        {
            ObjCompetitiveKnowledge = new Competitive_Knowledge__c();
            ObjCompetitiveKnowledge.Lead__c = lstLead[i].Id;
            lstCompetitiveKnowledge.add(ObjCompetitiveKnowledge);
        }
        return lstCompetitiveKnowledge;
    }
    
    Public List<X3rd_Party_Contract_Service__c> X3rdPartyContractServiceCreation(List<Lead> lstLead, List<Account> lstIPAccounts)
    {   
        List<X3rd_Party_Contract_Service__c> lstX3rdPartyContractService = new List<X3rd_Party_Contract_Service__c>();
        X3rd_Party_Contract_Service__c ObjX3rdPartyContractService;
        for(Integer i=0;i<lstLead.size();i++)
        {
            ObjX3rdPartyContractService = new X3rd_Party_Contract_Service__c();
            ObjX3rdPartyContractService.Lead__c = lstLead[i].Id;
            ObjX3rdPartyContractService.Integration_Partner_Account__c  = lstIPAccounts[i].id;
            lstX3rdPartyContractService.add(ObjX3rdPartyContractService);
        }
        return lstX3rdPartyContractService;
    }
    
    Public List<Account> IntegrationPartnerAccountsCreation(List<Lead> lstLeadforIPA)
    {  
        List<Account> lstIntegrationPartnerAccounts= new List<Account>();
        Account objAccount;
        for(Integer i=0; i<lstLeadforIPA.size(); i++) // Keep i value more than 4
        {
            objAccount = new Account();
            objAccount.RecordTypeId=SearchRecordTypeID('Integration Partner Accounts','Account');
            objAccount.Name = 'Integration Partner Accounts'+i;
            lstIntegrationPartnerAccounts.add(objAccount);
        }
       return lstIntegrationPartnerAccounts;
    }
    
    Public QueuesObject QueueCreation(Group testGroup)
    {
        QueuesObject testQueue = new QueueSObject(QueueID = testGroup.id, SObjectType = 'Lead');
        Return testQueue;
    }
    
    Public GroupMember AddPRMMasterLeadQueueMember(id grpOrUserId)
    {
        GroupMember ObjGM = new GroupMember();
        PRMMasterLeadQueue__c PRMMasterLeadQueue = PRMMasterLeadQueue__c.getInstance('Partner Queue');
        id grpId = PRMMasterLeadQueue.PRMMasterQueue__c;
        ObjGM.GroupId=grpId;
        ObjGM.UserOrGroupId = grpOrUserId;
        return ObjGM;
    }
    
    // Insertion of PRMAcctQueueCombination__c Custom Setting so that
    // New account is matched with new Queue Id created in Test Class
    Public PRMAcctQueueCombination__c CustomSettingDataInsertion(Account ObjAccount, Group ObjGrp,Integer i)
    {   
        String accountIdof18Dig = ObjAccount.id;
        String queueIdof18Dig = ObjGrp.Id;
        prmAccntQueueCombinationInstance=new PRMAcctQueueCombination__c();
        prmAccntQueueCombinationInstance.Name='TestData'+i;
        prmAccntQueueCombinationInstance.AccountId__c=accountIdof18Dig.left(15);
        prmAccntQueueCombinationInstance.QueueIds__c=queueIdof18Dig.left(15);
        return prmAccntQueueCombinationInstance;
    }
    
    Public PRMMasterLeadQueue__c PRMMasterLeadQueueInsertion(id testGrp)
    {   
        PRMMasterLeadQueueInstance=new PRMMasterLeadQueue__c();
        PRMMasterLeadQueueInstance.Name='TestData2';
        PRMMasterLeadQueueInstance.PRMMasterQueue__c= testGrp;
        return PRMMasterLeadQueueInstance;
    }
    
    Public PartnerMasterOwnerAccount__c PartnerMasterOwnerAccountInsertion(id testAct)
    {
        PartnerMasterOwnerAccountInstance = new PartnerMasterOwnerAccount__c();
        PartnerMasterOwnerAccountInstance.Name='TestData3';
        PartnerMasterOwnerAccountInstance.OwnerAccountId__c=testAct;
        return PartnerMasterOwnerAccountInstance;
    }
    
    Public ByPassTrigger__c ByPassTriggerInsertion(id idProfile)
    {
        UserProfile = new ByPassTrigger__c();
        UserProfile.SetupOwnerId =idProfile;
        UserProfile.isDisabled__c =True;
        return UserProfile;
    }
    
    Public Interface_Users__c InterfaceUsersInsertion(id idProfile)
    {
        InterfaceUsers = new Interface_Users__c();
        InterfaceUsers.SetupOwnerId =idProfile;
        InterfaceUsers.Is_Interface__c =True;
        return InterfaceUsers;
    }
}