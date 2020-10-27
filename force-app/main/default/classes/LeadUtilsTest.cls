/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest(SeeAllData = true)
private class LeadUtilsTest {
    /* 


 
    enum PortalType { CSPLiteUser, PowerPartner, PowerCustomerSuccess, CustomerSuccess }
 
    static String setupPRMAcctQueueCombination(String setupOption){
        List<Account> testAccountsList=insertTestAccounts();
        List<Group> testGroupList=insertPartnerQueues();
        
        System.debug('=====testGroupList=======' + testGroupList);
        
        System.debug('=====testAccountsList=======' + testAccountsList);
        
        
        PRMAcctQueueCombination__c prmAccntQueueCombinationInstance=new PRMAcctQueueCombination__c();
        prmAccntQueueCombinationInstance.Name='Test Account Name 123';
        prmAccntQueueCombinationInstance.AccountId__c=processId(testAccountsList.get(0).Id,setupOption);
        prmAccntQueueCombinationInstance.QueueIds__c=processId(testGroupList.get(0).Id,setupOption) + ',' + processId(testGroupList.get(1).Id,setupOption);
        insert prmAccntQueueCombinationInstance;
        
        prmAccntQueueCombinationInstance=new PRMAcctQueueCombination__c();
        prmAccntQueueCombinationInstance.Name='Test Account Name 456';
        prmAccntQueueCombinationInstance.AccountId__c=processId(testAccountsList.get(1).Id,setupOption);
        prmAccntQueueCombinationInstance.QueueIds__c=processId(testGroupList.get(2).id,setupOption);
        insert prmAccntQueueCombinationInstance;
        
        System.debug('=====testGroupList.get(0).Id=======' + testGroupList.get(0).Id);
        
        if('NON_PARTNER'.equalsIgnoreCase(setupOption)){
            return setupLeads(testGroupList.get(3).Id);
        }
        else{
          return setupLeads(testGroupList.get(0).Id);
        }
    }
    
    static string processId(String Id, String setupOption){
        if('TRIM_ID'.equalsIgnoreCase(setupOption)){
            return Id.subString(0,15);
        }
        else{
            return Id;
        }
    }
    
    static String setupLeads(String groupId){
        
        QueueSobject mappingObject = new QueueSobject(QueueId = groupId, SobjectType = 'Lead');
        System.runAs(new User(Id = UserInfo.getUserId()))
        {
           insert mappingObject;
        }
        createTestCountryCode();   
        Lead lead = new Lead(firstname = 'testFirstName', LastName = 'testLastName TEST CLASS',company='test', OwnerId = groupId, country = 'Canada');
        insert lead;
        
        return lead.id;
    }
    
    static List<Account> insertTestAccounts(){
       List<Account> insertAccountsList=new List<Account>();
       
       Account accountInstance=new Account();
       accountInstance.Name='Test Account Name 123';
       accountInstance.Phone='324324324';
       accountInstance.District__c='Strategic';
       accountInstance.Account_Type__c='Association';
       accountInstance.BillingStreet='Test Billing Street 123';
       accountInstance.BillingCity='Test Billing City 123';
       accountInstance.BillingCountry='Test Billing Country 123';
       
       insertAccountsList.add(accountInstance);
       
       accountInstance=new Account();
       accountInstance.Name='Test Account Name 345';
       accountInstance.Phone='3245643241';
       accountInstance.District__c='Canada';
       accountInstance.Account_Type__c='Beverages';
       accountInstance.BillingCity='Test Billing City 345';
       accountInstance.BillingStreet='Test Billing Street 345';
       accountInstance.BillingCountry='Test Billing Country 345';
       
       insertAccountsList.add(accountInstance);
       
       insert insertAccountsList;
       
       return insertAccountsList;
    }
    
     
    static List<Group> insertPartnerQueues(){
        List<Group> partnerQueues=new List<Group>();
        Group grp = new Group(Name='Partner Queue 1',Type='Queue');
        partnerQueues.add(grp);
        
        grp = new Group(Name='Partner Queue 2',Type='Queue');
        partnerQueues.add(grp);
        
        grp = new Group(Name='Partner Queue 3',Type='Queue');
        partnerQueues.add(grp);
        
        
        grp = new Group(Name='Partner Queue 4',Type='Queue');
        partnerQueues.add(grp);
        
        grp = new Group(Name='Partner Queue 5',Type='Queue');
        partnerQueues.add(grp);
        
        
        grp = new Group(Name='Partner Queue 6',Type='Queue');
        partnerQueues.add(grp);
        
        grp = new Group(Name='Partner Queue 7',Type='Queue');
        partnerQueues.add(grp);
        
        insert partnerQueues;
        
        return partnerQueues;
    }
    
    
    static testMethod void fullIdTest() {
        String leadId=setupPRMAcctQueueCombination('FULL_ID');
        Lead leadInstance=[select Id, Name, PartnerAccount__c,Partner_Disti__c from Lead where id=:leadId limit 1];
        
        //System.assertEquals('Test Account Name 123', leadInstance.Partner_Disti__c);
    }
    
    static testMethod void trimIDTest() {
        String leadId=setupPRMAcctQueueCombination('TRIM_ID');
        Lead leadInstance=[select Id, Name, PartnerAccount__c,Partner_Disti__c from Lead where id=:leadId limit 1];
        
        //System.assertEquals('Test Account Name 123', leadInstance.Partner_Disti__c);
    }
    
    static testMethod void nonPartnerQueueTest(){
        String leadId=setupPRMAcctQueueCombination('NON_PARTNER');
        Lead leadInstance=[select Id, Name, PartnerAccount__c,Partner_Disti__c from Lead where id=:leadId limit 1];
        
        System.assertEquals(null, leadInstance.Partner_Disti__c);
    }
    /*static testMethod void partnerUserTest(){
        Test.starttest();
        createTestCountryCode();
        User pu = getPortalUser(PortalType.PowerPartner, null, true);
        System.assert([select isPortalEnabled 
                         from user 
                        where id =:pu.id].isPortalEnabled,
                      'User was not flagged as portal enabled.');       
        
        System.RunAs(pu) {
            System.assert([select isPortalEnabled 
                             from user 
                            where id =:UserInfo.getUserId()].isPortalEnabled, 
                          'User wasnt portal enabled within the runas block. ');
                          
           //create a lead as a portal user
           Lead lead = new Lead(firstname = 'testFirstName', LastName = 'testLastName TEST CLASS',company='test', country = 'Canada');
           insert lead;
           
           Lead leadInstance=[select Id, Name, PartnerAccount__c,Partner_Disti__c from Lead where id=:lead.id limit 1];
        Test.stoptest();
           System.assertEquals('TEST ACCOUNT', leadInstance.Partner_Disti__c);
                          
        }
        
    }*/
    /*
    public static User getPortalUser(PortalType portalType, User userWithRole, Boolean doInsert) {
        
        // Make sure the running user has a role otherwise an exception will be thrown.
        if(userWithRole == null) {   
            
            if(UserInfo.getUserRoleId() == null) {

                UserRole r = new UserRole(name = 'TEST ROLE');
                Database.insert(r);
                
                userWithRole = new User(alias = 'hasrole', email='userwithrole@roletest1.com', userroleid = r.id,
                                    emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US', 
                                    localesidkey='en_US', profileid = UserInfo.getProfileId(), 
                                    timezonesidkey='America/Los_Angeles', username='userwithrole@testorg.com');
            } else {
                userWithRole = new User(Id = UserInfo.getUserId(), UserRoleId = UserInfo.getUserRoleId());
            }
            
            System.assert(userWithRole.userRoleId!= null, 
                          'This test requires the target org to have at least one UserRole created. Please create a user role in this organization and try again.');
        }

        Account a;
        Contact c;
        System.runAs(userWithRole) {

            a = new Account(name = 'TEST ACCOUNT',BillingStreet='Test BILLING STREET 56332', BillingCity='test city', BillingCountry='test country');
            Database.insert(a);
            
            c = new Contact(AccountId = a.id, lastname = 'lastname', firstname='test first name',MailingState = 'CA');
            Database.insert(c);

        }
        
        // Get any profile for the given type.
        Profile p = [select id 
                      from profile 
                     where usertype =:portalType.name() 
                     limit 1];   
        
        String testemail = 'puser000@amamama.com';
        User pu = new User(profileId = p.id, username = testemail, email = testemail, 
                           emailencodingkey = 'UTF-8', localesidkey = 'en_US', 
                           languagelocalekey = 'en_US', timezonesidkey = 'America/Los_Angeles', 
                           alias='cspu', lastname='lastname', contactId = c.id);
        
        if(doInsert) {
            Database.insert(pu);
        }
       
        return pu;
    }
    
   /* static testmethod void test_updateLeadMetaData() {
        Test.startTest();
        User pu = getPortalUser(PortalType.PowerPartner, null, true);
        System.assert(
           [select isPortalEnabled from user where id =:pu.id].isPortalEnabled
           ,'User was not flagged as portal enabled.'
        );  
        Lead l1 = new Lead(OwnerID = UserInfo.getUserId());
        Lead l2 = new Lead(OwnerID = pu.Id);
        LeadUtils.updateLeadMetaData(
           new List<Lead>{l1}
           ,new Map<ID,Lead>{l1.id => l2}
        );
        Test.stopTest();
        System.assert(l1.OwnerId != l2.OwnerId);
    }*/
    /*
    static testmethod void test_insertReferralPartnerID_noAccountFound() {
        createTestCountryCode();
        Account a = new Account(
            RecordTypeID = [select id from RecordType where SobjectType = 'Account' and Name = 'Partner Referral'].Id
            ,Primary_Contact_Name__c = 'Test Contact Name'
            ,Primary_Contact_Phone__c = '1234567890'
            ,Primary_Contact_Email__c = 'test@referral.com'
            ,Name = 'Test Referral Account'
            ,BillingStreet='Test Billing Street 123'
            ,BillingCity='Test Billing City 123'
            ,BillingCountry='Test Billing Country 123'
        );
        insert a;
        
        Lead l1 = new Lead(
        firstname = 'testFirstName',
            LastName = 'Test Last Name'
            ,Company = 'Test Company',
            country = 'Canada'
        );
        LeadUtils.updateReferralPartnerIdFromAccountToLead(
            new List<Lead>{l1}
            ,null
        );
        System.assert(l1.Primary_Contact_Name__c == null);
        System.assert(l1.Primary_Contact_Phone__c == null);
        System.assert(l1.Primary_Contact_Email__c == null);
    }
  
    static testmethod void test_insertReferralPartnerID_AccountFound() {
        createTestCountryCode();
        Account a = new Account(
            RecordTypeID = [select id from RecordType where SobjectType = 'Account' and Name = 'Partner Referral'].Id
            ,Referral_Partner_ID__c = 'Test123ReferralID'
            ,Primary_Contact_Name__c = 'Test Contact Name'
            ,Primary_Contact_Phone__c = '1234567890'
            ,Primary_Contact_Email__c = 'test@referral.com'
            ,Name = 'Test Referral Account'
            ,BillingStreet='Test Billing Street 123'
            ,BillingCity='Test Billing City 123'
            ,BillingCountry='Test Billing Country 123'
        );
        insert a;
        
        Lead l1 = new Lead(
        firstname = 'testFirstName',
            LastName = 'Test Last Name'
            ,Company = 'Test Company',
            Country = 'Canada'
            ,Referral_Partner_ID__c = a.Referral_Partner_ID__c
        );
        LeadUtils.updateReferralPartnerIdFromAccountToLead(
            new List<Lead>{l1}
            ,null
        );
        System.assertEquals(a.Primary_Contact_Name__c,l1.Primary_Contact_Name__c);
        System.assertEquals(a.Primary_Contact_Phone__c,l1.Primary_Contact_Phone__c);
        System.assertEquals(a.Primary_Contact_Email__c,l1.Primary_Contact_Email__c);
    }
   
    static testmethod void test_insertReferralPartnerID_multipleAccountFound() {
        createTestCountryCode();
        Account a1 = new Account(
            RecordTypeID = [select id from RecordType where SobjectType = 'Account' and Name = 'Partner Referral'].Id
            ,Referral_Partner_ID__c = 'Test123ReferralID'
            ,Primary_Contact_Name__c = 'Test Contact Name'
            ,Primary_Contact_Phone__c = '1234567890'
            ,Primary_Contact_Email__c = 'test@referral.com'
            ,Name = 'Test Referral Account'
            ,BillingStreet='Test Billing Street 123'
            ,BillingCity='Test Billing City 123'
            ,BillingCountry='Test Billing Country 123'
        );
        insert a1;
        
        Account a2 = new Account(
            RecordTypeID = [select id from RecordType where SobjectType = 'Account' and Name = 'Partner Referral'].Id
            ,Referral_Partner_ID__c = 'Test123ReferralID'
            ,Primary_Contact_Name__c = 'Test Contact Name'
            ,Primary_Contact_Phone__c = '1234567890'
            ,Primary_Contact_Email__c = 'test@referral.com'
            ,Name = 'Test Referral Account 2'
            ,BillingStreet='Test Billing Street 123'
            ,BillingCity='Test Billing City 123'
            ,BillingCountry='Test Billing Country 123'
        );
        insert a2;
        
        Lead l1 = new Lead(
            firstname = 'testFirstName',
            LastName = 'Test Last Name'
            ,Company = 'Test Company',
            country = 'Canada'
            ,Referral_Partner_ID__c = a1.Referral_Partner_ID__c
        );
        LeadUtils.updateReferralPartnerIdFromAccountToLead(
            new List<Lead>{l1}
            ,null
        );
        System.assert(l1.Primary_Contact_Name__c == null);
        System.assert(l1.Primary_Contact_Phone__c == null);
        System.assert(l1.Primary_Contact_Email__c == null);
    }
    
   static void test_validateStatecode()
    {
        createTestCountryCode();
       Lead testlead = new Lead(
            firstname = 'testFirstName',
             LastName = 'Test Last Name'
            ,Company = 'Test Company' 
            ,LeadSource = 'Test Source'
            ,Market__c = 'Test Market'
            ,Status = 'Test Status' 
            ,Company_Type__c = 'Test Company'
            , Title = 'Test title'
            , District__c = 'Test District'
            , State = 'California'
            ,country = 'Canada');
            
            insert testlead;
            
         Lead testlead2 = new Lead(
            firstname = 'testFirstName',
             LastName = 'Test Last Name2'
            ,Company = 'Test Company2' 
            ,LeadSource = 'Test Source2'
            ,Market__c = 'Test Market2'
            ,Status = 'Test Status2' 
            ,Company_Type__c = 'Test Company2'
            , Title = 'Test title2'
            , District__c = 'Test District2'
            , State = 'CA'
            ,country = 'Canada');

            
             insert testlead2;
             
            Lead testlead3 = new Lead(
            firstname = 'testFirstName',
             LastName = 'TestLastName3'
            ,Company = 'Test Company3' 
            ,LeadSource = 'Test Source3'
            ,Market__c = 'Test Market3'
            ,Status = 'Test Status3' 
            ,Company_Type__c = 'Test Company3'
            , Title = 'Test title3'
            , District__c = 'Test District3'
            , State = 'Karnatka'
            ,country = 'Canada');

            
             insert testlead3;
 
       
       List<Lead> lstlead = new List<Lead>(); 
              
       lstlead.add(testlead); 
       lstlead.add(testlead2);
       lstlead.add(testlead3);
       LeadUtils.getStateCode(lstlead);            
                   
    } 
  
  
    static testmethod void test_transferCompKnowObjectOnLeadConvertCase1()
    {
   
        createTestCountryCode();
    Lead leadtest1 = new Lead(
                firstname = 'testFirstName',
             LastName = 'TestLastName3'
            ,Company = 'Test Company3' 
            ,LeadSource = 'Test Source3'
            ,Market__c = 'Test Market3'
            ,Status = 'SQL' 
            ,Company_Type__c = 'Test Company3'
            , Title = 'Test title3'
            ,Phone = '(234)345-4532'
            , District__c = 'Test District3'
            , State = 'Alabama'
            ,country = 'Canada');

            
             insert leadtest1;
             
             Account Comp = [select id from Account where recordTypeId = :SystemIds__c.getInstance().RecordTypeId_Account_Competitor__c limit 1];
             Competitive_Knowledge__c compKnw = new Competitive_Knowledge__c(             
                  Competitor_Company_Name__c = Comp.id                
                 
                 ,Lead__c = leadtest1.Id
             );
             
             insert compKnw;
             
           /*
           List<Lead> lstoflead = new List<Lead>();   
           lstoflead.add(leadtest1);
           update lstoflead;
           
Database.LeadConvert lc = new database.LeadConvert();
lc.setLeadId(leadtest1.id);

LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1];
lc.setConvertedStatus(convertStatus.MasterLabel);

Database.LeadConvertResult lcr = Database.convertLead(lc);
System.assert(lcr.isSuccess());

*/
/*
Database.LeadConvert lc = new Database.LeadConvert();
system.debug('*******Lead Id'+leadtest1.Id);
lc.setLeadId(leadtest1.Id);
lc.setDoNotCreateOpportunity(true);

LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true AND MasterLabel = 'SQL' LIMIT 1];
lc.setConvertedStatus(convertStatus.MasterLabel);

Database.LeadConvertResult lcr = Database.convertLead(lc);
System.assert(lcr.isSuccess());

}

static testmethod void test_transferCompKnowObjectOnLeadConvertCase2()
    {
   
        createTestCountryCode();
    Lead leadtest1 = new Lead(
            firstname = 'testFirstName',
             LastName = 'TestLastName3'
            ,Company = 'Test Company3' 
            ,LeadSource = 'Test Source3'
            ,Market__c = 'Test Market3'
            ,Status = 'SQL' 
            ,Company_Type__c = 'Test Company3'
            , Title = 'Test title3'
            ,Phone = '(234)345-4532'
            , District__c = 'Test District3'
            , State = 'CA'
            , Country = 'Canada');

            
             insert leadtest1;
             Account Comp = [select id from Account where recordTypeId = :SystemIds__c.getInstance().RecordTypeId_Account_Competitor__c limit 1];
             Competitive_Knowledge__c compKnw = new Competitive_Knowledge__c(
             
                  Competitor_Company_Name__c = Comp.id                 
                 
                 ,Lead__c = leadtest1.Id
             );
             
             insert compKnw;
             
           /*
           List<Lead> lstoflead = new List<Lead>();   
           lstoflead.add(leadtest1);
           update lstoflead;
           
Database.LeadConvert lc = new database.LeadConvert();
lc.setLeadId(leadtest1.id);

LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1];
lc.setConvertedStatus(convertStatus.MasterLabel);

Database.LeadConvertResult lcr = Database.convertLead(lc);
System.assert(lcr.isSuccess());

*/
/*
Database.LeadConvert lc = new Database.LeadConvert();
system.debug('*******Lead Id'+leadtest1.Id);
lc.setLeadId(leadtest1.Id);
lc.setDoNotCreateOpportunity(true);

LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true AND MasterLabel = 'SQL' LIMIT 1];
lc.setConvertedStatus(convertStatus.MasterLabel);

Database.LeadConvertResult lcr = Database.convertLead(lc);
System.assert(lcr.isSuccess());

}
    static testmethod void test_forupdateSicFields()
    {
        Savepoint sp = Database.setSavepoint();
        createTestCountryCode();
     Sic__c testSic = new Sic__c( 
        name = '1234',
        Description_Detailed__c = 'DescriptionDetailed',
        Description_General__c = 'DescriptionGeneral',
        Reporting__c = 'Reporting');
     
     database.saveResult sr = database.insert(testSic);
     
     Lead testLead = new Lead(   
            firstname = 'testFirstName',
            LastName = 'TestLastName3'
            ,Company = 'Test Company3' 
            ,LeadSource = 'Test Source3'
            ,Market__c = 'Test Market3'
            ,Status = 'SQL' 
            ,Company_Type__c = 'Test Company3'
            , Title = 'Test title3'
            ,Phone = '(234)345-4532'
            , District__c = 'Test District3'
            , State = 'CA'
            , Country = 'Canada' );
            
        sr = database.insert(testLead);
        
        LeadUtils.updateSicFields(new list<Lead>{testLead});
        Database.rollback(sp);
         
    }
    private static void createTestCountryCode()
    {
        Country_And_Country_Code__c ccc = new Country_And_Country_Code__c();
        ccc.name = 'Canada';
        ccc.region__c = 'AMCAN';
        insert ccc;
    }
*/
}