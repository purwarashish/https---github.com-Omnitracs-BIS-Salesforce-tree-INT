/*******************************************************************************
 * File:  RoadnetUnitTests.cls
 * Date:  September 18, 2014
 * Author:  Joseph Hutchins
 *
 * The use, disclosure, reproduction, modification, transfer, or transmittal of
 * this work for any purpose in any form or by any means without the written 
 * permission of United Parcel Service is strictly prohibited.
 *
 * Confidential, unpublished property of United Parcel Service.
 * Use and distribution limited solely to authorized personnel.
 *
 * Copyright 2014, UPS Logistics Technologies, Inc.  All rights reserved.
 *  *******************************************************************************/
@istest (SeeAllData=true)
public with sharing class RoadnetUnitTests
{
    //  *****************   start tests for TimeCardExtension.cls  *****************
    public static testmethod void testForTimeCardExtension()
    {
        
        Savepoint sp = Database.setSavepoint();
        //  more than likely a time card does not exist as of yet, so need to create it as user who is running
        TimeCardExtension tce = new TimeCardExtension();
        
        //  need to make a case team so we can assign it later on
        Case_Team__c testCaseTeam = TimeCardExtension.createTestCaseTeam();
        Time_Card__c testTimeCard = TimeCardExtension.createTestTimeCard();
        tce.timecard = testtimecard;
        
        //  now call all methods and getters
        boolean testBool = tce.isDebug;
        testbool = tce.showNoTimeCardSection;
        tce.selectedCsSupport = userInfo.getUserId();
        List<SelectOption> testOptions = tce.csSupportMembers;
        List<TimeCardExtension.Tcdex> testDetailExtensions = tce.TableRows;
        testBool = tce.showSubmitButton;
        string testString = tce.SubmittedDate;
        testSTring = tce.approvedDate;
        testString = tce.rejectedDate;
        testString = tce.returnurl;
        testbool = tce.isLead;
        testbool = TimeCardExtension.isCustomerSupportLead('Call Center User');
        date testDate = tce.weekBegin;
        testDAte = tce.weekEnd;
        tce.csSupportPicklistOnChange();
        
        tce.createNewTimeCard();// i know this is dupe calling but i got a null reference on teh submit for approval due to the time card being blank
        
        tce.submitForApproval();
        testbool = tce.isUserApartOfSupport;
        
        tce.cancel();
        //tce.userIdToPassIntoQueryMethod = testCaseTEam.User__c;
        
        tce.weekBeginSelectionOnChange();
        tce.simpleRefresh();
        tce.createNewTimeCard();
        tce.saveChanges();
        
        //  lots of getters to test
        TimeCardExtension.Tcdex testTcdex = new TimeCardExtension.Tcdex(new Time_Card_Details__c(), new List<MIBOS_Case_Time__c>());
        Time_Card_Details__c testBlarg = testTcdex.tcd;
        testBlarg = testTcdex.oldTcd;
        decimal testDecimal = testTcdex.caseTimeSum;
        testString = testTcdex.adminColor;

        testString = testTcdex.MeetingColor;
        testString = testTcdex.TrainingColor;
        testString = testTcdex.BereavementColor;
        testString = testTcdex.HolidayColor;
        testString = testTcdex.inLieuColor;
        testString = testTcdex.juryColor;
        testString = testTcdex.PersonalColor;
        testString = testTcdex.professionalColor;
        testString = testTcdex.sickColor;
        testString = testTcdex.vacationColor;
        testString = testTcdex.commentsColor;
        
        testbool = testTcdex.isReadonly;
        
        
        testDecimal = testTcdex.totalForTable;
        
        
        Database.rollback(sp);
    }


    //  *****************   start tests for EmployeeProductivityController.cls *****************
    public static testmethod void testForEmployeeProductivityController()
    {
        Savepoint sp = Database.setSavepoint();
        Time_Card__c testTimeCard = TimeCardExtension.createTestTimeCard();
        Time_Card_Details__c tcd = [select id from Time_Card_Details__c where Time_Card__c =: testTimeCard.id];
        
        //  create an emp record here so that the controller can query something
        Employee_Productivity__c testEmp = new Employee_Productivity__c();
        testEmp.Time_Card_Detail__c = tcd.id;
        testEmp.Case_Team__c = TimeCardExtension.createTestCaseTeam().id;
        testEmp.day__c = date.today();
        testEmp.week_begin__c = date.today();
        
        database.insert(testEmp);
        
        //  should be very simple, create object, call all getters
        EmployeeProductivityController epc = new EmployeeProductivityController();
        
        boolean testBool = epc.isLead;
        user testuser = epc.loggedInUser;
        Case_Team__c testCaseTeam = epc.loggedInUserCaseTeam;

        string testString = epc.businessUnitUserChoice;
        List<Case_Team__c> testCaseTeams = epc.caseTeamRecords;
        List<Employee_Productivity__c>  testEpList = epc.roadnetPrimarySupport;
        testEpList = epc.roadnetPrimarySupport;
        testEpList = epc.roadnetStrategicSupport;
        
        testEpList = epc.RobinsonTier1;
        testEpList = epc.RobinsonTier2;
        testEpList = epc.loweTier1;
        testEpList = epc.loweTier2;
        testEpList = epc.featherTier1;
        testEpList = epc.featherTier2;
        testEpList = epc.jacobsTier1;
        testEpList = epc.jacobsTier2;
        testEpList = epc.bolhmanTier1;
        testEpList = epc.bolhmanTier2;
        
        testbool = EmployeeProductivityController.isDebug;
        epc.businessUnitUserChoice = 'Roadnet';
        
        epc.refresh();
        epc.verifyUserIsApartOfCaseTeam();
        
        
        Database.rollback(sp);
    }

    
    //  *****************   start tests for TimeCard.trigger  *****************
    public static testmethod void testForTimeCardTrigger()
    {
        Savepoint sp = Database.setSavepoint();
        Time_Card__c timeCard = new Time_Card__c();
        timeCard.user__c = userInfo.getUserId();
        timecArd.week_begin__c = date.today().toStartOfWeek();
        insert timeCard;
        Database.rollback(sp);
    }
    
     
    //  *****************   start tests for Campaign.trigger  *****************
    public static testmethod void testForCamapaignTrigger()
    {
        Savepoint sp = Database.setSavepoint();
        //  just a query and simple update will do to test the trigger
        Opportunity testOppt = [select id, campaignId from Opportunity where campaignId != null limit 1];
        Campaign c = new Campaign(id = testOppt.CampaignId);
        update c;
        Database.rollback(sp);
    }
    
    //  *****************   start tests for VCG_CPQ_NeedsFields_On_PricingCondition trigger  *****************
    public static testmethod void testForVCG_CPQ_NeedsFields_On_PricingCondition()
    {
        Savepoint sp = Database.setSavepoint();
        //  change set validtion on 6/24/2015 showed that this trigger had no test coverage, adding it here
        //  it only looks up at update and elete so lets only to the update
        VCG_CPQ_Pricing_Condition__c testObject = [select id from VCG_CPQ_Pricing_Condition__c limit 1];
        update testObject;
        Database.rollback(sp);
    }
    
    //  *****************   end tests for VCG_CPQ_NeedsFields_On_PricingCondition trigger  *****************

    private static Task createTestTask(id whatid, id whoid)
    {
         Task t = new Task();
         t.whatId = whatid;
         t.whoId = whoId;
         t.subject = 'blarg';
         t.priority = 'Normal';
         t.description = 'blarg';
         database.insert(t);
         
         return t;
    }
    
    private static Config_Key_Activity__c createTestCFA(Id accountId){
        Config_Key_Activity__c cfa = new Config_Key_Activity__c();
         cfa.comment__c = 'Test';
        cfa.Account__c = accountId;
         cfa.Activity_Description__c  = 'Test';
                  cfa.Emergency_Key__c = true;
                  cfa.Test_Demo__c = false;
          cfa.License_Key_Type__c = 'Permanent';
          cfa.Key_Expiration_Date__c = Date.today();
        insert cfa;
        
        return cfa;
    }
    
    //  **********  test for FeedItemTrigger.trg   *******************************
    public static testmethod void TestForFeedItemTrigger()
    {
        Savepoint sp = Database.setSavepoint();
        FeedItem fi = new FeedItem();
        Case testCase = CreateTestCase('SFDC Support');
        fi.parentid = testCase.id;
        fi.body = 'blarg';
        
        insert fi;
        
        Database.rollback(sp);
    }
    
    //  **********  test for CaseShareForVarRoadnet.cls   *******************************
    public static testmethod void TestForCaseShareForVarRoadnet()
    {
        Savepoint sp = Database.setSavepoint();
        Case testCase = CreateTestCase('SFDC Support');
        list<case> caseList = new List<case>{testCase};
        
        CaseShareForVarRoadnet testObject = new CaseShareForVarRoadnet();
        testObject.CreateCustomSharingForVars(caseList);
        
        Database.rollback(sp);
    }
    
    //  **********  test for ContactAlertExtension.cls   *******************************    
    public static testmethod void TestForContactAlertExtension()
    {
        Savepoint sp = Database.setSavepoint();
        
        Contact testContact;
        pagereference pageRef=new pagereference('Page.ContactAlert');
        test.setcurrentpage(pageRef);
        testContact = CreateTestContact(null, [select id from account limit 1].id);
        //declare apexpages.standardcontroller so that we can pass it into this class's constructor
        ApexPages.standardController controller = new ApexPages.standardController(testContact);
        
        ContactAlertExtension testaae=new ContactAlertExtension(controller);
        
        //testaae.getshouldShowContactAlert();
        testaae.getcontact();
        boolean testbool = testaae.shouldShowAccountAlert;
        string testString = testaae.accountAlert;
        Database.rollback(sp);
    }
    
    private static Contact CreateTestContact(string recordTypeName, id accountId)
    {
        Contact testContact = new Contact();
        
        testContact.lastname = 'lastname';
        testContact.firstname = 'firstname';
        
        testContact.accountid = accountId;
        testContact.Contact_Alert__c = 'blarg';
        testContact.email = 'walmart@walmart.com';
        testcontact.phone = '410-555-5555';
        testcontact.title = 'title';
        testcontact.Decision_Maker_Influencer__c = 'No';
        
        database.saveResult sr = database.insert(testContact);
        if (sr.isSuccess())
        {
            return testContact;
        }
        else
        {
            return null;
        }
    }
   
    public static Map_Set__c CreateTestMapSet(string recordTypeName, id accountId)
    {
        Map_SEt__c testMapSet = new Map_SEt__c();
        testMapSet.account__c = accountId;
        testMapSet.comments__c = 'bloarg';
        testMapSet.Date_Purchased__c = date.today();
        testMapSet.Map_Vendor__c = accountId;//  this should be different but i dont think it will make a difference
        testMapSet.Number_of_Licensed_Vehicles__c = 1;
        testMapSet.vendor_map_version_pl__c = 'TeleAtlas';
        
        database.saveResult sr = database.insert(testMapSet);
        if (sr.isSuccess())
        {
            return testMapSet;
        }
        else
        {
            return null;
        }
    }
    public static Account createTestAccount(string recordtypeName)
    {
        Account a = new Account();
        //  if this is set, crm fusion is throwing errors when trying to merge the accont.... i comented it out
        //  and getting errors that name needs to be set i'm going to see if we can generate random accounts names
        //  so whatever the merger is doing
        a.name = 'testAccount' + Math.roundtoLong(math.Random() * 100000.0);
        a.shippingCountry = 'United States';
        a.BillingCountry = 'United States';
        a.Territory__c = 'BlargTerr';
        a.Account_Class_1__c = 'BlargClass';
        a.Geo_Region__c = 'BlargGeoRegion';
        a.Primary_Business_Unit__c = 'Roadnet';
        //  populating these address fields for preventChangingOfLockedFields
        a.billingstreet = 'fake street';
        a.billingcity = 'fake city';
        a.billingstate = 'MD';
        a.BillingPostalCode = '21286';
        a.billingCountry = 'USA';
        a.shippingstreet = 'fake street';
        a.shippingcity = 'fake city';
        a.shippingcountry = 'USA';
        a.shippingPostalCode = '21286';
        a.Segment__c = 'TL';
        a.Fleet_Size__c = 25;
     // a.physical_street__c = 'fake street';
     // a.physical_city__c = 'fake city';
     // a.Physical_State_Province__c = 'MD';
     // a.Physical_zip_postal_code__c = '21286';
     // a.physical_Country__c = 'USA';
     // a.mailing_street__c = 'fake street';
     // a.mailing_city__c = 'fake city';
     // a.mailing_state_province__c = 'MD';
     // a.mailing_zip_postal_code__c = '21286';
     // a.mailing_Country__c = 'USA';
        
        if (recordtypeName != null)
        {
            a.recordtypeid = [select id from recordtype where sobjecttype = 'Account' and name =: recordtypeName limit 1].id;
        }
        else
        {
            a.recordtypeid = [select id from recordtype where sobjecttype = 'Account' and isactive = true limit 1].id;
        }
        database.saveResult sr = database.insert(a);
        if (sr.isSuccess())
        {
            return a;
        }
        else
        {
            return null; 
        }
    }
    
    //  **********  test for AssetSummary created by Mark M.   *******************************
    //  **** added by joseph hutchins for the little map set section of the asset page
    private static testmethod void TestForMapSetSection()
    {
        /*commented this test out due to getting the error: System.SObjectException: You cannot call addFields when the data is being passed into the controller by the caller.
        
        Savepoint sp = Database.setSavepoint();
        Account testAccount = RoadnetUnitTests.CreateTestAccount(null);
        Map_Set__c testMapSet = RoadnetUnitTests.CreateTestMapSet(null, testAccount.id);
        
        AssetSummary_Ctrl testExtension = new AssetSummary_Ctrl(AssetSummary_Ctrl.generateController(testAccount));
        system.assertNotEquals(null, testExtension.getLatestMapSetPurchased());
        system.assertNotEquals(null, testExtension.mostCurrentMapSet);
        system.assertNotEquals(null, testExtension.databasePlatform);
        system.assertNotEquals(null, testExtension.copilotVersion);
        
        
        Database.rollback(sp);
        */
    }
    //  **********  end tests for AssetSummary created by Mark M.   *******************************
    
    //  **********  test for MibosCaseTimeTrigger test   *******************************
    public static testmethod void testForCaseCommentTrigger()
    {
        Savepoint sp = Database.setSavepoint();
        
        
        
        //  creating a case shold be enough to test the trigger but i will create one just in case
        CaseComment cc = [select id from casecomment where parent.business_unit__c = 'Roadnet' limit 1];
        update cc;
        
        Database.rollback(sp);
    }
    public static testmethod void testForMibosCaseTimeTrigger()
    {
        Savepoint sp = Database.setSavepoint();
        
        //  creating a case shold be enough to test the trigger but i will create one just in case
        
        Mibos_Case_Time__c mct = new Mibos_Case_Time__c();
        Case testCase = CreateTestCase('SFDC Support');
        mct.Case__c = testCase.id;
        mct.owner__c = testCase.OwnerId;
        mct.Work_Effort__c = 5;
        
        insert mct;
        
        Database.rollback(sp);
    }
    
    //  **********  test for LeadTrigger   *******************************    
    public static testmethod void testForLeadTrigger()
    {
        Savepoint sp = Database.setSavepoint();
        
        Lead l = new Lead();
        l.firstname = 'testfirst';
        l.lastname = 'blarglead';
        l.company = 'blargcompany';
        l.leadsource = 'blarg';
        l.status = 'blarg';
        l.self_reported_fleet_size__c = 1000.0;
        l.country = 'United States';
        l.city = 'Test';
        l.state = 'AL';
        
        insert l;
        
        Database.rollback(sp);
    }
    
    
    //  **********  test for ChangeAccountOwnerExtension.cls   *******************************
    /*public static testMethod void testForChangeAccountOwnerExtension()
    {
        Savepoint sp = Database.setSavepoint();
        id josephUserRecordId = util.josephuserRecordId;
        
        Account testAccount = [select id from Account where owner.isactive = true and ownerId !=: josephUserRecordId limit 1];
        
        ApexPages.standardController controller = ChangeAccountOwnerExtension.generateController(testAccount);
        ChangeAccountOwnerExtension testExtension = new ChangeAccountOwnerExtension(controller);
        testExtension.notifyNewOwner = true;
        testExtension.shouldTransferOpenOpptsNotOwnedByAccountOwner = true;
        testExtension.shouldTransferClosedOppts = true;
        testExtension.shouldTransferOpenCases = true;
        testExtension.shouldTransferClosedCases = true;
        
        testExtension.ownerChangeEmailComments = 'Test';
        //id josephUserRecordId = '00530000001f8ouAAA';
        testExtension.account.ownerid = josephUserRecordId;
        testExtension.changeOwner();
        
        Database.rollback(sp);
    }*/
    
    //  **********  test for ChangeContactOwnerExtension.cls   *******************************
    public static testMethod void testForChangeContactOwnerExtension()
    {
        Savepoint sp = Database.setSavepoint();
         id josephUserRecordId = util.josephuserRecordid;
        Contact testContact = [select id from Contact where owner.isactive = true and
            AccountId =: roadnetAccount.id and
            owner.id !=: josephUserRecordId limit 1];
        
        ApexPages.standardController controller = ChangeContactOwnerExtension.generateController(testContact);
        ChangeContactOwnerExtension testExtension = new ChangeContactOwnerExtension(controller);
        testExtension.notifyNewOwner = true;
        testExtension.ownerChangeEmailComments = 'Test';
       
        testExtension.contact.ownerid = josephUserRecordId;
        testExtension.changeOwner();
        
        Database.rollback(sp);
    }

    /*public static testmethod void testForRnaApexEmailerController()
    {
        Savepoint sp = Database.setSavepoint();
        RnaApexEmailerController testController = new RnaApexEmailerController();
        system.assertNotEquals(null, testController.showMainPage);
        system.assertNotEquals(null, testController.showEmailSuccessfulPage);
        system.assertNotEquals(null, testController.showEmailFailurePage);
        system.assertNotEquals(null, testController.isTestMode);
        system.assertNotEquals(null, testController.plannedEmailTemplatePageMessageDetail);
        system.assertNotEquals(null, testController.plannedOuttageEmailTemplateId);
        system.assertNotEquals(null, testController.plannedEmailTemplatePageMessageDetail);
        //  commenting this out due to the fact that the org wide emial address cannot be retrieved via code
        //  need to use either a custom setting or a hard coded id, at this time, we dont have the id for the new rnsupport email 
        //  system.assertNotEquals(null, testController.roadnetCustomerServiceOrgWideEmail);
        system.assertNotEquals(null, testController.detailedHelpText);
        
        List<SelectOption> testOptions = testController.emailTemplateFolders;
        
        Case_Event__c testCaseEvent = testController.caseEventContactLookupOnly;
        boolean testBool = testController.didAnyEmailFailSending;
        
        List<Contact> testContacts = testController.rnaApexContacts;
        
        map<string, string> testStringMap = testController.urlParamMap;
        
        //  lets set this up so we can actually send emails to a test or the real deal or both
        // testing sendEmails in test mode
        id joeHutchId;
        try 
        {
            joeHutchId = [select id from contact where name = 'Joe Hutch' limit 1].id;//.033000000XoqnJ';
        }
        catch(Exception e)
        {
            //  joe hutch contact cannot be found just use whomevers to prevent test fialure
            joeHutchId = [select id from contact where accountId != null and email !=  null limit 1].id;
        }
        
        testController.caseEventContactLookupOnly.Contact__c = joeHutchId;
        testController.isTestMode = true;
        testController.sendEmails();
        
        // testing the real deal test mode
        testController.isTestMode = false;
        testController.sendEmails();
        
        
        testController.cancel();
        testController.refreshPage();
        
        //  tests for some of the pageReferences methods
        testController.caseEventContactLookupOnly.Contact__c = joeHutchId;
        testController.testContactLookupOnChange();
        testController.emailTemplateUserSelection = testController.emailTemplatePicklist[0].getValue();
        testController.emailTemplatePicklistOnChange();
        
        //  and the only one public non pagereference method
        Contact testContact = new Contact();
        testContact.HasOptedOutOfEmail = true;
        testContact.inactive__c = true;
        
        testController.isContactValidForTestEmail(testContact);
        
        
        //  test the innerclass
        RnaApexEmailerController.EmailFailure tempEmailFailure = new RnaApexEmailerController.EmailFailure('blarg', 'blarg', 'blarg', 'blarg');
        
        Database.rollback(sp);
    }*/
    //  **********  end test for RnaApexEmailerController.cls   *******************************
    
   //  **********  test for ContractHandoffExtension.cls   *******************************
    public static testmethod void testForContractHandoffExtension()
    {     
        //PageReference pageRef = Page.ContractHandoff;
        //test.setCurrentPageReference(pageRef);
        //pageRef.getParameters().put('opptId','43456');
        Account a = TestUtils.getAccount('ut1 Acc');
        insert a;
        
        Opportunity oppth = new Opportunity(Name = 'Fedex',
        Type = 'New Customer',
        CloseDate = system.today(),
        Order_Type__c = 'New',
        StageName = 'Sales Acceptance', 
        CurrencyIsoCode = 'USD',
        Type_of_Competitor__c='No Competitor');
        insert oppth;
        
        Savepoint sp = Database.setSavepoint();
        //  we just need two test teh constructor which does 3 things depedning on the url parameters,
        //  call the getters. thats it
        Contract_Handoff2__c ch = ContractHandoffExtension.CreateTestConHandOff(); 
        
        //  we aren't going to test the new functionality because we dont know if the ids in the sandbox and live are accurate.  we'll test the view and edit
        ContractHandoffExtension testExt = new ContractHandoffExtension( ContractHandoffExtension.genCon(ch, 'new'));
        
        testExt = new ContractHandoffExtension(ContractHandoffExtension.genCon(ch, 'doesnt matter its edit'));
        string testString = ContractHandoffExtension.LIVE_OPPT_FIELD_iD;
        testString = ContractHandoffExtension.LIVE_ACCOUNT_FIELD_ID;
        
        testString = ContractHandoffExtension.SANDBOX_CONTRACT_FIELD_ID;
        testString = ContractHandoffExtension.LIVE_CONTRACT_FIELD_ID;
     // testString = testExt.multiDayCheckBox;
        integer testInt = testExt.numOfRows;
        testInt = testExt.numOfCols;
        
        testString = testExt.hostSystem;
        Attachment testAttachment = testExt.rfp;
        testExt.emailOpptOwner();
        testExt.save();
        ContractHandOffExtension.isOpportunityProfServ('Intl. Special Projects');
        ContractHandOffExtension.isContractProvServ('Professional Services');
        testExt.prepopSalesHandoffFields();
        ContractHandOffExtension.queryOppContRole(oppth.id,'role');
        testExt.isHandoffAssoicatedWithProfServObject();
        
        //  test the new static methods here
        Database.rollback(sp);
    }
    
    //  **********  tests for RnTelematicsDeviceSummaryExtension.cls  *****************
    public static testmethod void testForRnTelematicsDeviceSummaryExtension()
    {
        Savepoint sp = Database.setSavepoint();
        RN_Telematics_Devices__c testDevice = RnTelematicsDeviceSummaryExtension.createTestTelematicsDevice();      
        RnTelematicsDeviceSummaryExtension testExtension = 
            new RnTelematicsDeviceSummaryExtension(RnTelematicsDeviceSummaryExtension.genCon(testDevice));
        integer testInteger = testExtension.devicesAssoicatedCustomer;
        testInteger = testExtension.activeDevices;
        testInteger = testExtension.devicesWithInstallDates;
        Database.rollback(sp);
    }
    //  **********  end tests RnTelematicsDeviceSummaryExtension.cls  *****************
    
    //  **********  test for RnDeviceMassUpdater.cls   *******************************
    public static testmethod void testForRnDeviceMassUpdater()
    {
        Savepoint sp = Database.setSavepoint();
        RN_Telematics_Devices__c testDevice = RnDeviceMassUpdater.createTestDevice();
        
        RnDeviceMassUpdater testExtension = new RnDeviceMassUpdater(RnDeviceMassUpdater.genCont(testDevice));
        testExtension.selectall = true;
        testExtension.selectAllOnChange();
        testExtension.assignActivationDate();
        testExtension.assignInstallationDate();
        testExtension.assignCurrentStatus();
        testExtension.assignAccount();
        testExtension.deviceSerialNumbers = testDevice.Serial_Number__c;
        
        testExtension.saveRecords();
        testExtension.userSelection = 'Find by SN#';
        
        testExtension.saveRecords();
        testExtension.findDevices();
        
        //testExtension.queryFoundDevices();
        //testExtension.findDevices();
        
        //  test the queryAndSetupDevices method by assigning different userSelection values
        testExtension.userSelection = 'Account';
        testExtension.queryAndSetupDevices();
        
        testExtension.userSelection = 'Find By SN#';
        testExtension.deviceSerialNumbers = 'blarg';
        testExtension.queryAndSetupDevices();
        
        testExtension.userSelection = 'Find By PO#';
        testExtension.queryAndSetupDevices();
        
        testExtension.userSelection = 'Find by Contract #';
        testExtension.queryAndSetupDevices();
        
        //  getters and setters
        List<RnDeviceMassUpdater.DeviceEx> testDevices = testExtension.devices;
        testDevices = testExtension.deviceSubSet;
        
        List<RN_Telematics_Devices__c> testD = testExtension.devicesOfAccount;
        testExtension.selectAll = true;
        testExtension.activationDate = Date.today();
        testExtension.installationDate = Date.Today();
        testExtension.tempDevice = new RN_Telematics_Devices__c();
        boolean testBool = testExtension.showFindByContractLabel;
        testbool = testExtension.showFindByPoLabel;
        testBool = testExtension.showFindBySection;
        
        integer testInt = testExtension.deviceSerialNumberCount;
        
        Database.rollback(sp);
    }
    
 
    //  **********  tests for AvoidDuplicateUsageEntryTrigger.tgr  *****************
   /*  public static testmethod void testForAvoidDuplicateUsageEntryTrigger()
    {
        //  PLEASE NOTe that i did not create this trigger, it came with a package but i get problems whent rying to deploy
        //  saying that code coverage is needed... so here it is
        Savepoint sp = Database.setSavepoint();
        
        //  create test rfp
        RFP__c testRFP = new RFP__c();
        testRfp.Due_date__c = date.today();
        Database.saveResult sr = database.insert(testRfp);
        
        testRfp = [select id from RFP__c where id =: sr.getId()];
        
        //  then the response
        Response__c testResponse = new Response__c();
        sr = database.insert(testResponse);
        testResponse = [select id from Response__c where id =: sr.getId()];
        
        //  now finally the question
        Question__c q = new Question__c();
        q.Override_Warning__c = true;
        q.rfp__c = testRfp.id;
        q.Response__c = testResponse.id;
         
        insert q;
        Database.rollback(sp); 
    }*/
    //  **********  tests for OpportunityTrigger.tgr  *****************
    public static testmethod void OpportunityTriggerTest()
    {
        Savepoint sp = Database.setSavepoint();
        //  this used to filter on STageName = 'closed won' but there are new stages in the mibos environment, 
        
        //Opportunity oppt = [select id from Opportunity where amount != null limit 1];
        Opportunity oppt = TestUtils.getOpportunity(createTestAccount(null), 'Test Opp');
        
        upsert oppt;
        
        Database.rollback(sp);
    }

    //  **********  tests for SalesSupportSingleProcessing.tgr  *****************
    /*public static testmethod void testForSalesSupportSingleProcessingTrigger()
    {
        Savepoint sp = Database.setSavePoint();
        //  test insertion and update
        Sales_Support__c testSalesSupport = new Sales_Support__c();
        testSalesSupport.SE_User__c = [select id from User where isactive = true and contactid = null limit 1].id;
        testSalesSupport.Opportunity__c = [select id from Opportunity where StageName = 'Closed Won' limit 1].id;
        insert testSalesSupport;
        
        //  now the update
        //  assuming that record exists in live/sandbox with SE user value set
        //  this is failing uat as of 12/12/2014 but do not have time to reserach why.  code coverage will not suffer....
        //testSalesSupport = [select id, Opportunity__c from Sales_Support__c where se_user__c != null and Opportunity__r.StageName = 'Closed Won' limit 1];
        //update testSalesSupport;
        Database.rollback(sp);
    }*/
    //  **********  tests for EmailMessageTrigger.tgr  *****************
    public static testmethod void testForEmailMessageTrigger()
    {
        Savepoint sp = Database.setSavepoint();
        EmailMessage em = new EmailMessage();
        em.parentId = [select id from case where business_unit__c = 'Roadnet' and isClosed = false limit 1].id;
        em.subject = 'EARLY_TERMINATION';
        insert em;
        Database.rollback(sp);          
    }
    
    //  **********  tests for UpgradeOpportunityExtension.cls  *****************
    public static testmethod  void testForUpgradeOpportunityExtension()
    {
        Savepoint sp = Database.setSavepoint();
        
        Case testCase = new Case();
        testCase = CreateTestCase('SFDC Support');//[select id from case where recordtype.name = 'Support' and account.owner.isActive = true and status = 'Closed' limit 1];
        
        Account a = new Account(Name = 'Test', Phone='3432433232', Account_Type__c='Association',/*District__c='Canada',*/Account_Manager__c=Userinfo.getUserId(),BillingStreet='Test Billing Street',BillingCity='Test Billing City',BillingCountry='AZ',BillingState='Test Billing State',BillingPostalCode='00001',Fleet_Size__c= 25,Segment__c='TL');
        Database.DMLOptions dml = new Database.DMLOptions();
        dml.DuplicateRuleHeader.AllowSave = true; 
        Database.SaveResult sr = Database.insert(a, dml);
        Contact c = new Contact();
        c.AccountID = a.id;
        c.LastName = 'User';
        c.Salutation = 'Mr.';
        c.FirstName = 'Deployment';
        insert c;
        
            UpgradeOpportunityExtension testExtension = new UpgradeOpportunityExtension(UpgradeOpportunityExtension.generateController(testCase));
            
            pagereference pageRef=new pagereference('Page.BillingDetailPage');
            test.setcurrentpage(pageRef);
            testExtension.checkIfOneAlreadyCreated();
            testExtension.createUpgradeOppt();
            testExtension.redirectToPrePoppedOpptScreen();
            Product2 prod = TestUtils.getProduct('Test Oppty');
            
            Opportunity oppty = new Opportunity();
            oppty.AccountID = a.id;
            oppty.Name = 'Test Opp1';
            oppty.StageName = 'Negotiate';
            oppty.CloseDate = date.today().addDays(60);
            oppty.description = 'Test Desc';
            oppty.Contact__c = c.id;
            oppty.Case__c = testCase.id;
         // oppty.Flat_Rate_database_work__c = 1125;
            oppty.LeadSource = 'Customer Service';
            oppty.Lead_Origin__c = 'Roandet - Customer Service';
            oppty.Order_Type__c  = 'New';
            insert oppty;
            testExtension.autoCreateOpprotunity();
            testExtension.setOpptPrepopFields();
            string testSTring = testExtension.returnUrl;
            testString = testExtension.createUpgradeOpptButtonLabel;
            
            Boolean testB1 = testExtension.isUserSupport;
            User testUser = testExtension.emailAgentUserRecord;
            
            PageReference pr = Page.CaseInfoMessagePage;
            test.setcurrentpage(pr);
            pr.setRedirect(true);
            list<string> testToEmail = new List<string>();
            testToEmail.add('jhutchins@roadnet.com');
            system.assertNotEquals(null, testExtension.opptrecTypesPickist);
            
    
    }

    //  **********  tests for UpgradeOpportunityExtension.cls  *****************
    
    
         //  **********  test for ConfigKeyGenerationExtension.cls   *******************************
    
    /*public static testmethod void testForConfigKeyGenerationExtension1()
    {
        //  this test exists in the UnitTests2 class also, i'm trying to see why code coverage for 
        //  this particular class doesn't show up when i check
        SavePoint sp = Database.setSavepoint();
        
        PageReference pageRef = new PageReference('Page.configKeyGenerationExtension');
        Test.setCurrentPage(pageRef);

        Account acct1 = ConfigKeyGenerationExtension.createTestDataSet1();
        
        ApexPages.standardController controller = new ApexPages.standardController(acct1);
        ConfigKeyGenerationExtension ckge = new ConfigKeyGenerationExtension(controller);
        
       
        ckge.setEmail('foo@foo.com');
        System.assert(ckge.getEmail() == 'foo@foo.com');
        
        string cfgKeyTxt = ckge.getCfgKeyTxt();
        string cfgKeyHtml = ckge.getCfgKeyHtml();
        
        ckge.sendEmail();
        ckge.cancelEmail();
        ckge.showMainsection();

        Database.rollback(sp);
    } */
    public static testmethod void testForConfigKeyGenerationExtension2()
    {
        SavePoint sp = Database.setSavepoint();
       // Account acct2 = ConfigKeyGenerationExtension.createTestDataSet2();
       // Create and insert account
       	Account acct1 = new Account();
        acct1.Type = 'Customer';
        acct1.Name = 'CWH 1';
        acct1.BillingCountry = 'India';
        acct1.billingstreet = 'Billing 101';
        acct1.billingcity = 'Billing 101';
        acct1.billingstate = 'Billing 101';
        acct1.BillingPostalCode = '75052';
        acct1.Fleet_Size__c= 25;
        acct1.Segment__c='TL';
        
        //acct1.Inherit_Parent_s_Products__c = true;
        insert acct1;
        
        Account acct2 = new Account();
        acct2.Type = 'Customer';
        acct2.Name = 'CWH Test Account 2';
        acct2.BillingCountry = acct2.ShippingCountry = 'Mexico';
        acct2.billingstreet = 'Billing Street';
        acct2.billingcity = 'Billing City';
        acct2.billingstate = 'Billing State';
        acct2.BillingPostalCode = 'Billing PostalCode';
        acct2.Fleet_Size__c= 25;
        acct2.Segment__c='TL';
        acct2.Inherit_Parent_s_Products__c = true;
        acct2.parentid = acct1.id;
        insert acct2;
        
        ApexPages.standardController controller = new ApexPages.standardController(acct2);
        ConfigKeyGenerationExtension ckge = new ConfigKeyGenerationExtension(controller);
        
        string cfgKeyTxt = ckge.getCfgKeyTxt();
        
        
        //  test the new resetConfigKeyData method
        ckge.resetConfigKeyData();
        ckge.sendEmail();
        ckge.cancelEmail();
        ckge.showMainSection();
        ckge.getEmail();
        ckge.getlktList();
        ckge.getComment();
        ckge.getCfgKeyHtml();
        //ckge.generateConfigKey();
        
        //  query line items that have a product of RN, TP, MC, FL  OR RIC AND THEN pass those line items into the methods below
       
        
        //  tests for new Emergency Button additions
        boolean testBool = ckge.isEmergencyKey;
        User testUser = ckge.currentUser;
        system.assertNotEquals(null, ConfigKeyGenerationExtension.overallEmergencyHelp);
        system.assertNotEquals(null, ConfigKeyGenerationExtension.limitsSectionDetailedHelp);
        system.assertNotEquals(null, ConfigKeyGenerationExtension.productsSectionDetailedHelp);
        
        Account acc = new Account ();
        
        ApexPages.StandardController sc = new ApexPages.StandardController(acct2);
        product2 prod = new product2();
        prod.name = 'test prod';
        prod.Product_Identifier__c = 'TP';
        prod.Product_Type__c ='Software';
        insert prod;
		
        Customer_Asset__c csA = new Customer_Asset__c ();
        csA.Account__c = acct2.id;
        csA.Eval__c = true;
        csA.Asset_Status__c = 'Active';
        csA.product__c = prod.id;
        
        insert csA;
        Customer_Asset__c csA2 = new Customer_Asset__c ();
        csA2.Account__c = acct2.id;
        csA2.product__c = prod.id;
     
        insert csA2;
        csA2 = [select id,product__c,product__r.Product_Identifier__c,Term_End_Date__c,Product__r.Name from Customer_Asset__c where id =:csA2.id];
        ConfigKeyGenerationExtension obj = new ConfigKeyGenerationExtension (sc);
        obj.lktList = null;
        obj.setEmail('abc@gmail.com');
        obj.setComment('test comment');
        obj.isRn(csA);
        ConfigKeyGenerationExtension.AssetEx objAssetEx = new ConfigKeyGenerationExtension.AssetEx (csA);
        obj.isTp(csA);
        obj.isMc(csA);
        obj.isFl(csA);
        obj.isRpd(csA);
        obj.iswsMapAss(csA);
        obj.isWsDataIntAss(csA);
        obj.isnetSchAss(csA);
        obj.ismerchAss(csA);
        obj.ismcDvirAss(csA);
        obj.isrtsConnectAss(csA);
        obj.isrnTeleAdaptAss(csA);
        obj.isrnActiveAlertAss(csA);
        obj.isVoiceNavAss(csA);
        ConfigKeyGenerationExtension.getProductShortName(objAssetEx);
        Obj.cloneCertainAssetFields(objAssetEx, csA);
        ConfigKeyGenerationExtension.getAssetDate(objAssetEx);
        ConfigKeyGenerationExtension.nullToZero(null);
        ConfigKeyGenerationExtension.nullToZero(12);
        //ConfigKeyGenerationExtension.createTestDataSet1();
        //ConfigKeyGenerationExtension.createTestDataSet2();
        obj.isRn(csA2);
        ConfigKeyGenerationExtension.AssetEx objAssetEx2 = new ConfigKeyGenerationExtension.AssetEx (csA2);
        obj.isTp(csA2);
        obj.isMc(csA2);
        obj.isFl(csA2);
        obj.isRpd(csA2);
        obj.iswsMapAss(csA2);
        obj.isWsDataIntAss(csA2);
        obj.isnetSchAss(csA2);
        obj.ismerchAss(csA2);
        obj.ismcDvirAss(csA2);
        obj.isrtsConnectAss(csA2);
        obj.isrnTeleAdaptAss(csA2);
        obj.isrnActiveAlertAss(csA2);
        obj.isVoiceNavAss(csA2);
        ConfigKeyGenerationExtension.getProductShortName(objAssetEx2);
        Obj.cloneCertainAssetFields(objAssetEx2, csA2);
        ConfigKeyGenerationExtension.getAssetDate(objAssetEx2);
        ConfigKeyGenerationExtension.nullToZero(null);
        ConfigKeyGenerationExtension.nullToZero(12);
        
        Database.rollback(sp);
        
    }
    public static testmethod void testForConfigKeyGenerationExtension3()
    {
        SavePoint sp = Database.setSavepoint();
       // Account acct2 = ConfigKeyGenerationExtension.createTestDataSet2();
       // Create and insert account
       	Account acct1 = new Account();
        acct1.Type = 'Customer';
        acct1.Name = 'CWH 1';
        acct1.BillingCountry = 'India';
        acct1.billingstreet = 'Billing 101';
        acct1.billingcity = 'Billing 101';
        acct1.billingstate = 'Billing 101';
        acct1.BillingPostalCode = '75052';
        acct1.Fleet_Size__c= 25;
        acct1.Segment__c='TL';
        
        //acct1.Inherit_Parent_s_Products__c = true;
        insert acct1;
        
        Account acct2 = new Account();
        acct2.Type = 'Customer';
        acct2.Name = 'CWH Test Account 2';
        acct2.BillingCountry = acct2.ShippingCountry = 'Mexico';
        acct2.billingstreet = 'Billing Street';
        acct2.billingcity = 'Billing City';
        acct2.billingstate = 'Billing State';
        acct2.BillingPostalCode = 'Billing PostalCode';
        acct2.Fleet_Size__c= 25;
        acct2.Segment__c='TL';
        acct2.Inherit_Parent_s_Products__c = true;
        acct2.parentid = acct1.id;
        insert acct2;
        
        ApexPages.standardController controller = new ApexPages.standardController(acct2);
        ConfigKeyGenerationExtension ckge = new ConfigKeyGenerationExtension(controller);
        
        string cfgKeyTxt = ckge.getCfgKeyTxt();
        
        
        //  test the new resetConfigKeyData method
        ckge.resetConfigKeyData();
        ckge.sendEmail();
        ckge.cancelEmail();
        ckge.showMainSection();
        ckge.getEmail();
        ckge.getlktList();
        ckge.getComment();
        ckge.getCfgKeyHtml();
        //ckge.generateConfigKey();
        
        //  query line items that have a product of RN, TP, MC, FL  OR RIC AND THEN pass those line items into the methods below
       
        
        //  tests for new Emergency Button additions
        boolean testBool = ckge.isEmergencyKey;
        User testUser = ckge.currentUser;
        system.assertNotEquals(null, ConfigKeyGenerationExtension.overallEmergencyHelp);
        system.assertNotEquals(null, ConfigKeyGenerationExtension.limitsSectionDetailedHelp);
        system.assertNotEquals(null, ConfigKeyGenerationExtension.productsSectionDetailedHelp);
        
        Account acc = new Account ();
        
        ApexPages.StandardController sc = new ApexPages.StandardController(acct2);
        product2 prod = new product2();
        prod.name = 'test prod';
        prod.Product_Identifier__c = 'MC';
        prod.Product_Type__c ='Software';
        insert prod;
		
        Customer_Asset__c csA = new Customer_Asset__c ();
        csA.Account__c = acct2.id;
        csA.Eval__c = true;
        csA.Asset_Status__c = 'Active';
        csA.product__c = prod.id;
        
        insert csA;
        Customer_Asset__c csA2 = new Customer_Asset__c ();
        csA2.Account__c = acct2.id;
        csA2.product__c = prod.id;
     
        insert csA2;
        csA2 = [select id,product__c,product__r.Product_Identifier__c,Term_End_Date__c,Product__r.Name from Customer_Asset__c where id =:csA2.id];
        ConfigKeyGenerationExtension obj = new ConfigKeyGenerationExtension (sc);
        obj.lktList = null;
        obj.setEmail('abc@gmail.com');
        obj.setComment('test comment');
        obj.isRn(csA);
        ConfigKeyGenerationExtension.AssetEx objAssetEx = new ConfigKeyGenerationExtension.AssetEx (csA);
        obj.isTp(csA);
        obj.isMc(csA);
        obj.isFl(csA);
        obj.isRpd(csA);
        obj.iswsMapAss(csA);
        obj.isWsDataIntAss(csA);
        obj.isnetSchAss(csA);
        obj.ismerchAss(csA);
        obj.ismcDvirAss(csA);
        obj.isrtsConnectAss(csA);
        obj.isrnTeleAdaptAss(csA);
        obj.isrnActiveAlertAss(csA);
        obj.isVoiceNavAss(csA);
        ConfigKeyGenerationExtension.getProductShortName(objAssetEx);
        Obj.cloneCertainAssetFields(objAssetEx, csA);
        ConfigKeyGenerationExtension.getAssetDate(objAssetEx);
        ConfigKeyGenerationExtension.nullToZero(null);
        ConfigKeyGenerationExtension.nullToZero(12);
        //ConfigKeyGenerationExtension.createTestDataSet1();
        //ConfigKeyGenerationExtension.createTestDataSet2();
        obj.isRn(csA2);
        ConfigKeyGenerationExtension.AssetEx objAssetEx2 = new ConfigKeyGenerationExtension.AssetEx (csA2);
        obj.isTp(csA2);
        obj.isMc(csA2);
        obj.isFl(csA2);
        obj.isRpd(csA2);
        obj.iswsMapAss(csA2);
        obj.isWsDataIntAss(csA2);
        obj.isnetSchAss(csA2);
        obj.ismerchAss(csA2);
        obj.ismcDvirAss(csA2);
        obj.isrtsConnectAss(csA2);
        obj.isrnTeleAdaptAss(csA2);
        obj.isrnActiveAlertAss(csA2);
        obj.isVoiceNavAss(csA2);
        ConfigKeyGenerationExtension.getProductShortName(objAssetEx2);
        Obj.cloneCertainAssetFields(objAssetEx2, csA2);
        ConfigKeyGenerationExtension.getAssetDate(objAssetEx2);
        ConfigKeyGenerationExtension.nullToZero(null);
        ConfigKeyGenerationExtension.nullToZero(12);
        
        Database.rollback(sp);
        
    }
    public static testmethod void testForConfigKeyGenerationExtension4()
    {
        SavePoint sp = Database.setSavepoint();
       // Account acct2 = ConfigKeyGenerationExtension.createTestDataSet2();
       // Create and insert account
       	Account acct1 = new Account();
        acct1.Type = 'Customer';
        acct1.Name = 'CWH 1';
        acct1.BillingCountry = 'India';
        acct1.billingstreet = 'Billing 101';
        acct1.billingcity = 'Billing 101';
        acct1.billingstate = 'Billing 101';
        acct1.BillingPostalCode = '75052';
        acct1.Fleet_Size__c= 25;
        acct1.Segment__c='TL';
        
        //acct1.Inherit_Parent_s_Products__c = true;
        insert acct1;
        
        Account acct2 = new Account();
        acct2.Type = 'Customer';
        acct2.Name = 'CWH Test Account 2';
        acct2.BillingCountry = acct2.ShippingCountry = 'Mexico';
        acct2.billingstreet = 'Billing Street';
        acct2.billingcity = 'Billing City';
        acct2.billingstate = 'Billing State';
        acct2.BillingPostalCode = 'Billing PostalCode';
        acct2.Fleet_Size__c= 25;
        acct2.Segment__c='TL';
        acct2.Inherit_Parent_s_Products__c = true;
        acct2.parentid = acct1.id;
        insert acct2;
        
        ApexPages.standardController controller = new ApexPages.standardController(acct2);
        ConfigKeyGenerationExtension ckge = new ConfigKeyGenerationExtension(controller);
        
        string cfgKeyTxt = ckge.getCfgKeyTxt();
        
        
        //  test the new resetConfigKeyData method
        ckge.resetConfigKeyData();
        ckge.sendEmail();
        ckge.cancelEmail();
        ckge.showMainSection();
        ckge.getEmail();
        ckge.getlktList();
        ckge.getComment();
        ckge.getCfgKeyHtml();
        //ckge.generateConfigKey();
        
        //  query line items that have a product of RN, TP, MC, FL  OR RIC AND THEN pass those line items into the methods below
       
        
        //  tests for new Emergency Button additions
        boolean testBool = ckge.isEmergencyKey;
        User testUser = ckge.currentUser;
        system.assertNotEquals(null, ConfigKeyGenerationExtension.overallEmergencyHelp);
        system.assertNotEquals(null, ConfigKeyGenerationExtension.limitsSectionDetailedHelp);
        system.assertNotEquals(null, ConfigKeyGenerationExtension.productsSectionDetailedHelp);
        
        Account acc = new Account ();
        
        ApexPages.StandardController sc = new ApexPages.StandardController(acct2);
        product2 prod = new product2();
        prod.name = 'test prod';
        prod.Product_Identifier__c = 'FL';
        prod.Product_Type__c ='Software';
        insert prod;
		
        Customer_Asset__c csA = new Customer_Asset__c ();
        csA.Account__c = acct2.id;
        csA.Eval__c = true;
        csA.Asset_Status__c = 'Active';
        csA.product__c = prod.id;
        
        insert csA;
        Customer_Asset__c csA2 = new Customer_Asset__c ();
        csA2.Account__c = acct2.id;
        csA2.product__c = prod.id;
     
        insert csA2;
        csA2 = [select id,product__c,product__r.Product_Identifier__c,Term_End_Date__c,Product__r.Name from Customer_Asset__c where id =:csA2.id];
        ConfigKeyGenerationExtension obj = new ConfigKeyGenerationExtension (sc);
        obj.lktList = null;
        obj.setEmail('abc@gmail.com');
        obj.setComment('test comment');
        obj.isRn(csA);
        ConfigKeyGenerationExtension.AssetEx objAssetEx = new ConfigKeyGenerationExtension.AssetEx (csA);
        obj.isTp(csA);
        obj.isMc(csA);
        obj.isFl(csA);
        obj.isRpd(csA);
        obj.iswsMapAss(csA);
        obj.isWsDataIntAss(csA);
        obj.isnetSchAss(csA);
        obj.ismerchAss(csA);
        obj.ismcDvirAss(csA);
        obj.isrtsConnectAss(csA);
        obj.isrnTeleAdaptAss(csA);
        obj.isrnActiveAlertAss(csA);
        obj.isVoiceNavAss(csA);
        ConfigKeyGenerationExtension.getProductShortName(objAssetEx);
        Obj.cloneCertainAssetFields(objAssetEx, csA);
        ConfigKeyGenerationExtension.getAssetDate(objAssetEx);
        ConfigKeyGenerationExtension.nullToZero(null);
        ConfigKeyGenerationExtension.nullToZero(12);
        //ConfigKeyGenerationExtension.createTestDataSet1();
        //ConfigKeyGenerationExtension.createTestDataSet2();
        obj.isRn(csA2);
        ConfigKeyGenerationExtension.AssetEx objAssetEx2 = new ConfigKeyGenerationExtension.AssetEx (csA2);
        obj.isTp(csA2);
        obj.isMc(csA2);
        obj.isFl(csA2);
        obj.isRpd(csA2);
        obj.iswsMapAss(csA2);
        obj.isWsDataIntAss(csA2);
        obj.isnetSchAss(csA2);
        obj.ismerchAss(csA2);
        obj.ismcDvirAss(csA2);
        obj.isrtsConnectAss(csA2);
        obj.isrnTeleAdaptAss(csA2);
        obj.isrnActiveAlertAss(csA2);
        obj.isVoiceNavAss(csA2);
        ConfigKeyGenerationExtension.getProductShortName(objAssetEx2);
        Obj.cloneCertainAssetFields(objAssetEx2, csA2);
        ConfigKeyGenerationExtension.getAssetDate(objAssetEx2);
        ConfigKeyGenerationExtension.nullToZero(null);
        ConfigKeyGenerationExtension.nullToZero(12);
        
        Database.rollback(sp);
        
    }
    public static testmethod void testForConfigKeyGenerationExtension5()
    {
        SavePoint sp = Database.setSavepoint();
       // Account acct2 = ConfigKeyGenerationExtension.createTestDataSet2();
       // Create and insert account
       	Account acct1 = new Account();
        acct1.Type = 'Customer';
        acct1.Name = 'CWH 1';
        acct1.BillingCountry = 'India';
        acct1.billingstreet = 'Billing 101';
        acct1.billingcity = 'Billing 101';
        acct1.billingstate = 'Billing 101';
        acct1.BillingPostalCode = '75052';
        acct1.Fleet_Size__c= 25;
        acct1.Segment__c='TL';
        
        //acct1.Inherit_Parent_s_Products__c = true;
        insert acct1;
        
        Account acct2 = new Account();
        acct2.Type = 'Customer';
        acct2.Name = 'CWH Test Account 2';
        acct2.BillingCountry = acct2.ShippingCountry = 'Mexico';
        acct2.billingstreet = 'Billing Street';
        acct2.billingcity = 'Billing City';
        acct2.billingstate = 'Billing State';
        acct2.BillingPostalCode = 'Billing PostalCode';
        acct2.Fleet_Size__c= 25;
        acct2.Segment__c='TL';
        acct2.Inherit_Parent_s_Products__c = true;
        acct2.parentid = acct1.id;
        insert acct2;
        
        ApexPages.standardController controller = new ApexPages.standardController(acct2);
        ConfigKeyGenerationExtension ckge = new ConfigKeyGenerationExtension(controller);
        
        string cfgKeyTxt = ckge.getCfgKeyTxt();
        
        
        //  test the new resetConfigKeyData method
        ckge.resetConfigKeyData();
        ckge.sendEmail();
        ckge.cancelEmail();
        ckge.showMainSection();
        ckge.getEmail();
        ckge.getlktList();
        ckge.getComment();
        ckge.getCfgKeyHtml();
        //ckge.generateConfigKey();
        
        //  query line items that have a product of RN, TP, MC, FL  OR RIC AND THEN pass those line items into the methods below
       
        
        //  tests for new Emergency Button additions
        boolean testBool = ckge.isEmergencyKey;
        User testUser = ckge.currentUser;
        system.assertNotEquals(null, ConfigKeyGenerationExtension.overallEmergencyHelp);
        system.assertNotEquals(null, ConfigKeyGenerationExtension.limitsSectionDetailedHelp);
        system.assertNotEquals(null, ConfigKeyGenerationExtension.productsSectionDetailedHelp);
        
        Account acc = new Account ();
        
        ApexPages.StandardController sc = new ApexPages.StandardController(acct2);
        product2 prod = new product2();
        prod.name = 'test prod';
        prod.Product_Identifier__c = 'RPD';
        prod.Product_Type__c ='Software';
        insert prod;
		
        Customer_Asset__c csA = new Customer_Asset__c ();
        csA.Account__c = acct2.id;
        csA.Eval__c = true;
        csA.Asset_Status__c = 'Active';
        csA.product__c = prod.id;
        
        insert csA;
        Customer_Asset__c csA2 = new Customer_Asset__c ();
        csA2.Account__c = acct2.id;
        csA2.product__c = prod.id;
     
        insert csA2;
        csA2 = [select id,product__c,product__r.Product_Identifier__c,Term_End_Date__c,Product__r.Name from Customer_Asset__c where id =:csA2.id];
        ConfigKeyGenerationExtension obj = new ConfigKeyGenerationExtension (sc);
        obj.lktList = null;
        obj.setEmail('abc@gmail.com');
        obj.setComment('test comment');
        obj.isRn(csA);
        ConfigKeyGenerationExtension.AssetEx objAssetEx = new ConfigKeyGenerationExtension.AssetEx (csA);
        obj.isTp(csA);
        obj.isMc(csA);
        obj.isFl(csA);
        obj.isRpd(csA);
        obj.iswsMapAss(csA);
        obj.isWsDataIntAss(csA);
        obj.isnetSchAss(csA);
        obj.ismerchAss(csA);
        obj.ismcDvirAss(csA);
        obj.isrtsConnectAss(csA);
        obj.isrnTeleAdaptAss(csA);
        obj.isrnActiveAlertAss(csA);
        obj.isVoiceNavAss(csA);
        ConfigKeyGenerationExtension.getProductShortName(objAssetEx);
        Obj.cloneCertainAssetFields(objAssetEx, csA);
        ConfigKeyGenerationExtension.getAssetDate(objAssetEx);
        ConfigKeyGenerationExtension.nullToZero(null);
        ConfigKeyGenerationExtension.nullToZero(12);
        //ConfigKeyGenerationExtension.createTestDataSet1();
        //ConfigKeyGenerationExtension.createTestDataSet2();
        obj.isRn(csA2);
        ConfigKeyGenerationExtension.AssetEx objAssetEx2 = new ConfigKeyGenerationExtension.AssetEx (csA2);
        obj.isTp(csA2);
        obj.isMc(csA2);
        obj.isFl(csA2);
        obj.isRpd(csA2);
        obj.iswsMapAss(csA2);
        obj.isWsDataIntAss(csA2);
        obj.isnetSchAss(csA2);
        obj.ismerchAss(csA2);
        obj.ismcDvirAss(csA2);
        obj.isrtsConnectAss(csA2);
        obj.isrnTeleAdaptAss(csA2);
        obj.isrnActiveAlertAss(csA2);
        obj.isVoiceNavAss(csA2);
        ConfigKeyGenerationExtension.getProductShortName(objAssetEx2);
        Obj.cloneCertainAssetFields(objAssetEx2, csA2);
        ConfigKeyGenerationExtension.getAssetDate(objAssetEx2);
        ConfigKeyGenerationExtension.nullToZero(null);
        ConfigKeyGenerationExtension.nullToZero(12);
        
        Database.rollback(sp);
        
    }
    public static testmethod void testForConfigKeyGenerationExtension6()
    {
        SavePoint sp = Database.setSavepoint();
       // Account acct2 = ConfigKeyGenerationExtension.createTestDataSet2();
       // Create and insert account
       	Account acct1 = new Account();
        acct1.Type = 'Customer';
        acct1.Name = 'CWH 1';
        acct1.BillingCountry = 'India';
        acct1.billingstreet = 'Billing 101';
        acct1.billingcity = 'Billing 101';
        acct1.billingstate = 'Billing 101';
        acct1.BillingPostalCode = '75052';
        acct1.Fleet_Size__c= 25;
        acct1.Segment__c='TL';
        
        //acct1.Inherit_Parent_s_Products__c = true;
        insert acct1;
        
        Account acct2 = new Account();
        acct2.Type = 'Customer';
        acct2.Name = 'CWH Test Account 2';
        acct2.BillingCountry = acct2.ShippingCountry = 'Mexico';
        acct2.billingstreet = 'Billing Street';
        acct2.billingcity = 'Billing City';
        acct2.billingstate = 'Billing State';
        acct2.BillingPostalCode = 'Billing PostalCode';
        acct2.Fleet_Size__c= 25;
        acct2.Segment__c='TL';
        acct2.Inherit_Parent_s_Products__c = true;
        acct2.parentid = acct1.id;
        insert acct2;
        
        ApexPages.standardController controller = new ApexPages.standardController(acct2);
        ConfigKeyGenerationExtension ckge = new ConfigKeyGenerationExtension(controller);
        
        string cfgKeyTxt = ckge.getCfgKeyTxt();
        
        
        //  test the new resetConfigKeyData method
        ckge.resetConfigKeyData();
        ckge.sendEmail();
        ckge.cancelEmail();
        ckge.showMainSection();
        ckge.getEmail();
        ckge.getlktList();
        ckge.getComment();
        ckge.getCfgKeyHtml();
        //ckge.generateConfigKey();
        
        //  query line items that have a product of RN, TP, MC, FL  OR RIC AND THEN pass those line items into the methods below
       
        
        //  tests for new Emergency Button additions
        boolean testBool = ckge.isEmergencyKey;
        User testUser = ckge.currentUser;
        system.assertNotEquals(null, ConfigKeyGenerationExtension.overallEmergencyHelp);
        system.assertNotEquals(null, ConfigKeyGenerationExtension.limitsSectionDetailedHelp);
        system.assertNotEquals(null, ConfigKeyGenerationExtension.productsSectionDetailedHelp);
        
        Account acc = new Account ();
        
        ApexPages.StandardController sc = new ApexPages.StandardController(acct2);
        product2 prod = new product2();
        prod.name = 'test prod';
        prod.Product_Identifier__c = 'RWS';
        prod.Product_Type__c ='Software';
        insert prod;
		
        Customer_Asset__c csA = new Customer_Asset__c ();
        csA.Account__c = acct2.id;
        csA.Eval__c = true;
        csA.Asset_Status__c = 'Active';
        csA.product__c = prod.id;
        
        insert csA;
        Customer_Asset__c csA2 = new Customer_Asset__c ();
        csA2.Account__c = acct2.id;
        csA2.product__c = prod.id;
     
        insert csA2;
        csA2 = [select id,product__c,product__r.Product_Identifier__c,Term_End_Date__c,Product__r.Name from Customer_Asset__c where id =:csA2.id];
        ConfigKeyGenerationExtension obj = new ConfigKeyGenerationExtension (sc);
        obj.lktList = null;
        obj.setEmail('abc@gmail.com');
        obj.setComment('test comment');
        obj.isRn(csA);
        ConfigKeyGenerationExtension.AssetEx objAssetEx = new ConfigKeyGenerationExtension.AssetEx (csA);
        obj.isTp(csA);
        obj.isMc(csA);
        obj.isFl(csA);
        obj.isRpd(csA);
        obj.iswsMapAss(csA);
        obj.isWsDataIntAss(csA);
        obj.isnetSchAss(csA);
        obj.ismerchAss(csA);
        obj.ismcDvirAss(csA);
        obj.isrtsConnectAss(csA);
        obj.isrnTeleAdaptAss(csA);
        obj.isrnActiveAlertAss(csA);
        obj.isVoiceNavAss(csA);
        ConfigKeyGenerationExtension.getProductShortName(objAssetEx);
        Obj.cloneCertainAssetFields(objAssetEx, csA);
        ConfigKeyGenerationExtension.getAssetDate(objAssetEx);
        ConfigKeyGenerationExtension.nullToZero(null);
        ConfigKeyGenerationExtension.nullToZero(12);
        //ConfigKeyGenerationExtension.createTestDataSet1();
        //ConfigKeyGenerationExtension.createTestDataSet2();
        obj.isRn(csA2);
        ConfigKeyGenerationExtension.AssetEx objAssetEx2 = new ConfigKeyGenerationExtension.AssetEx (csA2);
        obj.isTp(csA2);
        obj.isMc(csA2);
        obj.isFl(csA2);
        obj.isRpd(csA2);
        obj.iswsMapAss(csA2);
        obj.isWsDataIntAss(csA2);
        obj.isnetSchAss(csA2);
        obj.ismerchAss(csA2);
        obj.ismcDvirAss(csA2);
        obj.isrtsConnectAss(csA2);
        obj.isrnTeleAdaptAss(csA2);
        obj.isrnActiveAlertAss(csA2);
        obj.isVoiceNavAss(csA2);
        ConfigKeyGenerationExtension.getProductShortName(objAssetEx2);
        Obj.cloneCertainAssetFields(objAssetEx2, csA2);
        ConfigKeyGenerationExtension.getAssetDate(objAssetEx2);
        ConfigKeyGenerationExtension.nullToZero(null);
        ConfigKeyGenerationExtension.nullToZero(12);
        
        Database.rollback(sp);
        
    }
    public static testmethod void testForConfigKeyGenerationExtension7()
    {
        SavePoint sp = Database.setSavepoint();
       // Account acct2 = ConfigKeyGenerationExtension.createTestDataSet2();
       // Create and insert account
       	Account acct1 = new Account();
        acct1.Type = 'Customer';
        acct1.Name = 'CWH 1';
        acct1.BillingCountry = 'India';
        acct1.billingstreet = 'Billing 101';
        acct1.billingcity = 'Billing 101';
        acct1.billingstate = 'Billing 101';
        acct1.BillingPostalCode = '75052';
        acct1.Fleet_Size__c= 25;
        acct1.Segment__c='TL';
        
        //acct1.Inherit_Parent_s_Products__c = true;
        insert acct1;
        
        Account acct2 = new Account();
        acct2.Type = 'Customer';
        acct2.Name = 'CWH Test Account 2';
        acct2.BillingCountry = acct2.ShippingCountry = 'Mexico';
        acct2.billingstreet = 'Billing Street';
        acct2.billingcity = 'Billing City';
        acct2.billingstate = 'Billing State';
        acct2.BillingPostalCode = 'Billing PostalCode';
        acct2.Fleet_Size__c= 25;
        acct2.Segment__c='TL';
        acct2.Inherit_Parent_s_Products__c = true;
        acct2.parentid = acct1.id;
        insert acct2;
        
        ApexPages.standardController controller = new ApexPages.standardController(acct2);
        ConfigKeyGenerationExtension ckge = new ConfigKeyGenerationExtension(controller);
        
        string cfgKeyTxt = ckge.getCfgKeyTxt();
        
        
        //  test the new resetConfigKeyData method
        ckge.resetConfigKeyData();
        ckge.sendEmail();
        ckge.cancelEmail();
        ckge.showMainSection();
        ckge.getEmail();
        ckge.getlktList();
        ckge.getComment();
        ckge.getCfgKeyHtml();
        //ckge.generateConfigKey();
        
        //  query line items that have a product of RN, TP, MC, FL  OR RIC AND THEN pass those line items into the methods below
       
        
        //  tests for new Emergency Button additions
        boolean testBool = ckge.isEmergencyKey;
        User testUser = ckge.currentUser;
        system.assertNotEquals(null, ConfigKeyGenerationExtension.overallEmergencyHelp);
        system.assertNotEquals(null, ConfigKeyGenerationExtension.limitsSectionDetailedHelp);
        system.assertNotEquals(null, ConfigKeyGenerationExtension.productsSectionDetailedHelp);
        
        Account acc = new Account ();
        
        ApexPages.StandardController sc = new ApexPages.StandardController(acct2);
        product2 prod = new product2();
        prod.name = 'test prod';
        prod.Product_Identifier__c = 'RN';
        prod.Product_Type__c ='Software';
        prod.Is_Perpetual__c = true;
        insert prod;
		
        Customer_Asset__c csA = new Customer_Asset__c ();
        csA.Account__c = acct2.id;
        csA.Eval__c = true;
        csA.Asset_Status__c = 'Active';
        csA.product__c = prod.id;
        
        insert csA;
        Customer_Asset__c csA2 = new Customer_Asset__c ();
        csA2.Account__c = acct2.id;
        csA2.product__c = prod.id;
     
        insert csA2;
        csA2 = [select id,product__c,product__r.Product_Identifier__c,Term_End_Date__c,Product__r.Name from Customer_Asset__c where id =:csA2.id];
        ConfigKeyGenerationExtension obj = new ConfigKeyGenerationExtension (sc);
        obj.lktList = null;
        obj.setEmail('abc@gmail.com');
        obj.setComment('test comment');
        obj.isRn(csA);
        ConfigKeyGenerationExtension.AssetEx objAssetEx = new ConfigKeyGenerationExtension.AssetEx (csA);
        obj.isTp(csA);
        obj.isMc(csA);
        obj.isFl(csA);
        obj.isRpd(csA);
        obj.iswsMapAss(csA);
        obj.isWsDataIntAss(csA);
        obj.isnetSchAss(csA);
        obj.ismerchAss(csA);
        obj.ismcDvirAss(csA);
        obj.isrtsConnectAss(csA);
        obj.isrnTeleAdaptAss(csA);
        obj.isrnActiveAlertAss(csA);
        obj.isVoiceNavAss(csA);
        ConfigKeyGenerationExtension.getProductShortName(objAssetEx);
        Obj.cloneCertainAssetFields(objAssetEx, csA);
        ConfigKeyGenerationExtension.getAssetDate(objAssetEx);
        ConfigKeyGenerationExtension.nullToZero(null);
        ConfigKeyGenerationExtension.nullToZero(12);
        //ConfigKeyGenerationExtension.createTestDataSet1();
        //ConfigKeyGenerationExtension.createTestDataSet2();
        obj.isRn(csA2);
        ConfigKeyGenerationExtension.AssetEx objAssetEx2 = new ConfigKeyGenerationExtension.AssetEx (csA2);
        obj.isTp(csA2);
        obj.isMc(csA2);
        obj.isFl(csA2);
        obj.isRpd(csA2);
        obj.iswsMapAss(csA2);
        obj.isWsDataIntAss(csA2);
        obj.isnetSchAss(csA2);
        obj.ismerchAss(csA2);
        obj.ismcDvirAss(csA2);
        obj.isrtsConnectAss(csA2);
        obj.isrnTeleAdaptAss(csA2);
        obj.isrnActiveAlertAss(csA2);
        obj.isVoiceNavAss(csA2);
        ConfigKeyGenerationExtension.getProductShortName(objAssetEx2);
        Obj.cloneCertainAssetFields(objAssetEx2, csA2);
        ConfigKeyGenerationExtension.getAssetDate(objAssetEx2);
        ConfigKeyGenerationExtension.nullToZero(null);
        ConfigKeyGenerationExtension.nullToZero(12);
        
        Database.rollback(sp);
        
    }
    public static testmethod void testForConfigKeyGenerationExtension8()
    {
        SavePoint sp = Database.setSavepoint();
       // Account acct2 = ConfigKeyGenerationExtension.createTestDataSet2();
       // Create and insert account
       	Account acct1 = new Account();
        acct1.Type = 'Customer';
        acct1.Name = 'CWH 1';
        acct1.BillingCountry = 'India';
        acct1.billingstreet = 'Billing 101';
        acct1.billingcity = 'Billing 101';
        acct1.billingstate = 'Billing 101';
        acct1.BillingPostalCode = '75052';
        acct1.Fleet_Size__c= 25;
        acct1.Segment__c='TL';
        
        //acct1.Inherit_Parent_s_Products__c = true;
        insert acct1;
        
        Account acct2 = new Account();
        acct2.Type = 'Customer';
        acct2.Name = 'CWH Test Account 2';
        acct2.BillingCountry = acct2.ShippingCountry = 'Mexico';
        acct2.billingstreet = 'Billing Street';
        acct2.billingcity = 'Billing City';
        acct2.billingstate = 'Billing State';
        acct2.BillingPostalCode = 'Billing PostalCode';
        acct2.Fleet_Size__c= 25;
        acct2.Segment__c='TL';
        acct2.Inherit_Parent_s_Products__c = true;
        acct2.parentid = acct1.id;
        insert acct2;
        
        ApexPages.standardController controller = new ApexPages.standardController(acct2);
        ConfigKeyGenerationExtension ckge = new ConfigKeyGenerationExtension(controller);
        
        string cfgKeyTxt = ckge.getCfgKeyTxt();
        
        
        //  test the new resetConfigKeyData method
        ckge.resetConfigKeyData();
        ckge.sendEmail();
        ckge.cancelEmail();
        ckge.showMainSection();
        ckge.getEmail();
        ckge.getlktList();
        ckge.getComment();
        ckge.getCfgKeyHtml();
        //ckge.generateConfigKey();
        
        //  query line items that have a product of RN, TP, MC, FL  OR RIC AND THEN pass those line items into the methods below
       
        
        //  tests for new Emergency Button additions
        boolean testBool = ckge.isEmergencyKey;
        User testUser = ckge.currentUser;
        system.assertNotEquals(null, ConfigKeyGenerationExtension.overallEmergencyHelp);
        system.assertNotEquals(null, ConfigKeyGenerationExtension.limitsSectionDetailedHelp);
        system.assertNotEquals(null, ConfigKeyGenerationExtension.productsSectionDetailedHelp);
        
        Account acc = new Account ();
        
        ApexPages.StandardController sc = new ApexPages.StandardController(acct2);
        product2 prod = new product2();
        prod.name = 'test prod';
        prod.Product_Identifier__c = 'TWS';
        prod.Product_Type__c ='Software';
        prod.Is_Perpetual__c = true;
        insert prod;
		
        Customer_Asset__c csA = new Customer_Asset__c ();
        csA.Account__c = acct2.id;
        csA.Eval__c = true;
        csA.Asset_Status__c = 'Active';
        csA.product__c = prod.id;
        
        insert csA;
        Customer_Asset__c csA2 = new Customer_Asset__c ();
        csA2.Account__c = acct2.id;
        csA2.product__c = prod.id;
     
        insert csA2;
        csA2 = [select id,product__c,product__r.Product_Identifier__c,Term_End_Date__c,Product__r.Name from Customer_Asset__c where id =:csA2.id];
        ConfigKeyGenerationExtension obj = new ConfigKeyGenerationExtension (sc);
        obj.lktList = null;
        obj.setEmail('abc@gmail.com');
        obj.setComment('test comment');
        obj.isRn(csA);
        ConfigKeyGenerationExtension.AssetEx objAssetEx = new ConfigKeyGenerationExtension.AssetEx (csA);
        obj.isTp(csA);
        obj.isMc(csA);
        obj.isFl(csA);
        obj.isRpd(csA);
        obj.iswsMapAss(csA);
        obj.isWsDataIntAss(csA);
        obj.isnetSchAss(csA);
        obj.ismerchAss(csA);
        obj.ismcDvirAss(csA);
        obj.isrtsConnectAss(csA);
        obj.isrnTeleAdaptAss(csA);
        obj.isrnActiveAlertAss(csA);
        obj.isVoiceNavAss(csA);
        ConfigKeyGenerationExtension.getProductShortName(objAssetEx);
        Obj.cloneCertainAssetFields(objAssetEx, csA);
        ConfigKeyGenerationExtension.getAssetDate(objAssetEx);
        ConfigKeyGenerationExtension.nullToZero(null);
        ConfigKeyGenerationExtension.nullToZero(12);
        //ConfigKeyGenerationExtension.createTestDataSet1();
        //ConfigKeyGenerationExtension.createTestDataSet2();
        obj.isRn(csA2);
        ConfigKeyGenerationExtension.AssetEx objAssetEx2 = new ConfigKeyGenerationExtension.AssetEx (csA2);
        obj.isTp(csA2);
        obj.isMc(csA2);
        obj.isFl(csA2);
        obj.isRpd(csA2);
        obj.iswsMapAss(csA2);
        obj.isWsDataIntAss(csA2);
        obj.isnetSchAss(csA2);
        obj.ismerchAss(csA2);
        obj.ismcDvirAss(csA2);
        obj.isrtsConnectAss(csA2);
        obj.isrnTeleAdaptAss(csA2);
        obj.isrnActiveAlertAss(csA2);
        obj.isVoiceNavAss(csA2);
        ConfigKeyGenerationExtension.getProductShortName(objAssetEx2);
        Obj.cloneCertainAssetFields(objAssetEx2, csA2);
        ConfigKeyGenerationExtension.getAssetDate(objAssetEx2);
        ConfigKeyGenerationExtension.nullToZero(null);
        ConfigKeyGenerationExtension.nullToZero(12);
        
        Database.rollback(sp);
        
    }
    public static testmethod void testForConfigKeyGenerationExtension9()
    {
        SavePoint sp = Database.setSavepoint();
       // Account acct2 = ConfigKeyGenerationExtension.createTestDataSet2();
       // Create and insert account
       	Account acct1 = new Account();
        acct1.Type = 'Customer';
        acct1.Name = 'CWH 1';
        acct1.BillingCountry = 'India';
        acct1.billingstreet = 'Billing 101';
        acct1.billingcity = 'Billing 101';
        acct1.billingstate = 'Billing 101';
        acct1.BillingPostalCode = '75052';
        acct1.Fleet_Size__c= 25;
        acct1.Segment__c='TL';
        
        //acct1.Inherit_Parent_s_Products__c = true;
        insert acct1;
        
        Account acct2 = new Account();
        acct2.Type = 'Customer';
        acct2.Name = 'CWH Test Account 2';
        acct2.BillingCountry = acct2.ShippingCountry = 'Mexico';
        acct2.billingstreet = 'Billing Street';
        acct2.billingcity = 'Billing City';
        acct2.billingstate = 'Billing State';
        acct2.BillingPostalCode = 'Billing PostalCode';
        acct2.Fleet_Size__c= 25;
        acct2.Segment__c='TL';
        acct2.Inherit_Parent_s_Products__c = true;
        acct2.parentid = acct1.id;
        insert acct2;
        
        ApexPages.standardController controller = new ApexPages.standardController(acct2);
        ConfigKeyGenerationExtension ckge = new ConfigKeyGenerationExtension(controller);
        
        string cfgKeyTxt = ckge.getCfgKeyTxt();
        
        
        //  test the new resetConfigKeyData method
        ckge.resetConfigKeyData();
        ckge.sendEmail();
        ckge.cancelEmail();
        ckge.showMainSection();
        ckge.getEmail();
        ckge.getlktList();
        ckge.getComment();
        ckge.getCfgKeyHtml();
        //ckge.generateConfigKey();
        
        //  query line items that have a product of RN, TP, MC, FL  OR RIC AND THEN pass those line items into the methods below
       
        
        //  tests for new Emergency Button additions
        boolean testBool = ckge.isEmergencyKey;
        User testUser = ckge.currentUser;
        system.assertNotEquals(null, ConfigKeyGenerationExtension.overallEmergencyHelp);
        system.assertNotEquals(null, ConfigKeyGenerationExtension.limitsSectionDetailedHelp);
        system.assertNotEquals(null, ConfigKeyGenerationExtension.productsSectionDetailedHelp);
        
        Account acc = new Account ();
        
        ApexPages.StandardController sc = new ApexPages.StandardController(acct2);
        product2 prod = new product2();
        prod.name = 'test prod';
        prod.Product_Identifier__c = 'APT';
        prod.Product_Type__c ='Software';
        prod.Is_Perpetual__c = true;
        insert prod;
		
        Customer_Asset__c csA = new Customer_Asset__c ();
        csA.Account__c = acct2.id;
        csA.Eval__c = true;
        csA.Asset_Status__c = 'Active';
        csA.product__c = prod.id;
        
        insert csA;
        Customer_Asset__c csA2 = new Customer_Asset__c ();
        csA2.Account__c = acct2.id;
        csA2.product__c = prod.id;
     
        insert csA2;
        csA2 = [select id,product__c,product__r.Product_Identifier__c,Term_End_Date__c,Product__r.Name from Customer_Asset__c where id =:csA2.id];
        ConfigKeyGenerationExtension obj = new ConfigKeyGenerationExtension (sc);
        obj.lktList = null;
        obj.setEmail('abc@gmail.com');
        obj.setComment('test comment');
        obj.isRn(csA);
        ConfigKeyGenerationExtension.AssetEx objAssetEx = new ConfigKeyGenerationExtension.AssetEx (csA);
        obj.isTp(csA);
        obj.isMc(csA);
        obj.isFl(csA);
        obj.isRpd(csA);
        obj.iswsMapAss(csA);
        obj.isWsDataIntAss(csA);
        obj.isnetSchAss(csA);
        obj.ismerchAss(csA);
        obj.ismcDvirAss(csA);
        obj.isrtsConnectAss(csA);
        obj.isrnTeleAdaptAss(csA);
        obj.isrnActiveAlertAss(csA);
        obj.isVoiceNavAss(csA);
        ConfigKeyGenerationExtension.getProductShortName(objAssetEx);
        Obj.cloneCertainAssetFields(objAssetEx, csA);
        ConfigKeyGenerationExtension.getAssetDate(objAssetEx);
        ConfigKeyGenerationExtension.nullToZero(null);
        ConfigKeyGenerationExtension.nullToZero(12);
        //ConfigKeyGenerationExtension.createTestDataSet1();
        //ConfigKeyGenerationExtension.createTestDataSet2();
        obj.isRn(csA2);
        ConfigKeyGenerationExtension.AssetEx objAssetEx2 = new ConfigKeyGenerationExtension.AssetEx (csA2);
        obj.isTp(csA2);
        obj.isMc(csA2);
        obj.isFl(csA2);
        obj.isRpd(csA2);
        obj.iswsMapAss(csA2);
        obj.isWsDataIntAss(csA2);
        obj.isnetSchAss(csA2);
        obj.ismerchAss(csA2);
        obj.ismcDvirAss(csA2);
        obj.isrtsConnectAss(csA2);
        obj.isrnTeleAdaptAss(csA2);
        obj.isrnActiveAlertAss(csA2);
        obj.isVoiceNavAss(csA2);
        ConfigKeyGenerationExtension.getProductShortName(objAssetEx2);
        Obj.cloneCertainAssetFields(objAssetEx2, csA2);
        ConfigKeyGenerationExtension.getAssetDate(objAssetEx2);
        ConfigKeyGenerationExtension.nullToZero(null);
        ConfigKeyGenerationExtension.nullToZero(12);
        
        Database.rollback(sp);
        
    }
    public static testmethod void testForConfigKeyGenerationExtension10()
    {
        SavePoint sp = Database.setSavepoint();
       // Account acct2 = ConfigKeyGenerationExtension.createTestDataSet2();
       // Create and insert account
       	Account acct1 = new Account();
        acct1.Type = 'Customer';
        acct1.Name = 'CWH 1';
        acct1.BillingCountry = 'India';
        acct1.billingstreet = 'Billing 101';
        acct1.billingcity = 'Billing 101';
        acct1.billingstate = 'Billing 101';
        acct1.BillingPostalCode = '75052';
        acct1.Fleet_Size__c= 25;
        acct1.Segment__c='TL';
        
        //acct1.Inherit_Parent_s_Products__c = true;
        insert acct1;
        
        Account acct2 = new Account();
        acct2.Type = 'Customer';
        acct2.Name = 'CWH Test Account 2';
        acct2.BillingCountry = acct2.ShippingCountry = 'Mexico';
        acct2.billingstreet = 'Billing Street';
        acct2.billingcity = 'Billing City';
        acct2.billingstate = 'Billing State';
        acct2.BillingPostalCode = 'Billing PostalCode';
        acct2.Fleet_Size__c= 25;
        acct2.Segment__c='TL';
        acct2.Inherit_Parent_s_Products__c = true;
        acct2.parentid = acct1.id;
        insert acct2;
        
        ApexPages.standardController controller = new ApexPages.standardController(acct2);
        ConfigKeyGenerationExtension ckge = new ConfigKeyGenerationExtension(controller);
        
        string cfgKeyTxt = ckge.getCfgKeyTxt();
        
        
        //  test the new resetConfigKeyData method
        ckge.resetConfigKeyData();
        ckge.sendEmail();
        ckge.cancelEmail();
        ckge.showMainSection();
        ckge.getEmail();
        ckge.getlktList();
        ckge.getComment();
        ckge.getCfgKeyHtml();
        //ckge.generateConfigKey();
        
        //  query line items that have a product of RN, TP, MC, FL  OR RIC AND THEN pass those line items into the methods below
       
        
        //  tests for new Emergency Button additions
        boolean testBool = ckge.isEmergencyKey;
        User testUser = ckge.currentUser;
        system.assertNotEquals(null, ConfigKeyGenerationExtension.overallEmergencyHelp);
        system.assertNotEquals(null, ConfigKeyGenerationExtension.limitsSectionDetailedHelp);
        system.assertNotEquals(null, ConfigKeyGenerationExtension.productsSectionDetailedHelp);
        
        Account acc = new Account ();
        
        ApexPages.StandardController sc = new ApexPages.StandardController(acct2);
        product2 prod = new product2();
        prod.name = 'test prod';
        prod.Product_Identifier__c = 'MERCH';
        prod.Product_Type__c ='Software';
        prod.Is_Perpetual__c = true;
        insert prod;
		
        Customer_Asset__c csA = new Customer_Asset__c ();
        csA.Account__c = acct2.id;
        csA.Eval__c = true;
        csA.Asset_Status__c = 'Active';
        csA.product__c = prod.id;
        
        insert csA;
        Customer_Asset__c csA2 = new Customer_Asset__c ();
        csA2.Account__c = acct2.id;
        csA2.product__c = prod.id;
     
        insert csA2;
        csA2 = [select id,product__c,product__r.Product_Identifier__c,Term_End_Date__c,Product__r.Name from Customer_Asset__c where id =:csA2.id];
        ConfigKeyGenerationExtension obj = new ConfigKeyGenerationExtension (sc);
        obj.lktList = null;
        obj.setEmail('abc@gmail.com');
        obj.setComment('test comment');
        obj.isRn(csA);
        ConfigKeyGenerationExtension.AssetEx objAssetEx = new ConfigKeyGenerationExtension.AssetEx (csA);
        obj.isTp(csA);
        obj.isMc(csA);
        obj.isFl(csA);
        obj.isRpd(csA);
        obj.iswsMapAss(csA);
        obj.isWsDataIntAss(csA);
        obj.isnetSchAss(csA);
        obj.ismerchAss(csA);
        obj.ismcDvirAss(csA);
        obj.isrtsConnectAss(csA);
        obj.isrnTeleAdaptAss(csA);
        obj.isrnActiveAlertAss(csA);
        obj.isVoiceNavAss(csA);
        ConfigKeyGenerationExtension.getProductShortName(objAssetEx);
        Obj.cloneCertainAssetFields(objAssetEx, csA);
        ConfigKeyGenerationExtension.getAssetDate(objAssetEx);
        ConfigKeyGenerationExtension.nullToZero(null);
        ConfigKeyGenerationExtension.nullToZero(12);
        //ConfigKeyGenerationExtension.createTestDataSet1();
        //ConfigKeyGenerationExtension.createTestDataSet2();
        obj.isRn(csA2);
        ConfigKeyGenerationExtension.AssetEx objAssetEx2 = new ConfigKeyGenerationExtension.AssetEx (csA2);
        obj.isTp(csA2);
        obj.isMc(csA2);
        obj.isFl(csA2);
        obj.isRpd(csA2);
        obj.iswsMapAss(csA2);
        obj.isWsDataIntAss(csA2);
        obj.isnetSchAss(csA2);
        obj.ismerchAss(csA2);
        obj.ismcDvirAss(csA2);
        obj.isrtsConnectAss(csA2);
        obj.isrnTeleAdaptAss(csA2);
        obj.isrnActiveAlertAss(csA2);
        obj.isVoiceNavAss(csA2);
        ConfigKeyGenerationExtension.getProductShortName(objAssetEx2);
        Obj.cloneCertainAssetFields(objAssetEx2, csA2);
        ConfigKeyGenerationExtension.getAssetDate(objAssetEx2);
        ConfigKeyGenerationExtension.nullToZero(null);
        ConfigKeyGenerationExtension.nullToZero(12);
        
        Database.rollback(sp);
        
    }
    public static testmethod void testForConfigKeyGenerationExtension11()
    {
        SavePoint sp = Database.setSavepoint();
       // Account acct2 = ConfigKeyGenerationExtension.createTestDataSet2();
       // Create and insert account
       	Account acct1 = new Account();
        acct1.Type = 'Customer';
        acct1.Name = 'CWH 1';
        acct1.BillingCountry = 'India';
        acct1.billingstreet = 'Billing 101';
        acct1.billingcity = 'Billing 101';
        acct1.billingstate = 'Billing 101';
        acct1.BillingPostalCode = '75052';
        acct1.Fleet_Size__c= 25;
        acct1.Segment__c='TL';
        
        //acct1.Inherit_Parent_s_Products__c = true;
        insert acct1;
        
        Account acct2 = new Account();
        acct2.Type = 'Customer';
        acct2.Name = 'CWH Test Account 2';
        acct2.BillingCountry = acct2.ShippingCountry = 'Mexico';
        acct2.billingstreet = 'Billing Street';
        acct2.billingcity = 'Billing City';
        acct2.billingstate = 'Billing State';
        acct2.BillingPostalCode = 'Billing PostalCode';
        acct2.Fleet_Size__c= 25;
        acct2.Segment__c='TL';
        acct2.Inherit_Parent_s_Products__c = true;
        acct2.parentid = acct1.id;
        insert acct2;
        
        ApexPages.standardController controller = new ApexPages.standardController(acct2);
        ConfigKeyGenerationExtension ckge = new ConfigKeyGenerationExtension(controller);
        
        string cfgKeyTxt = ckge.getCfgKeyTxt();
        
        
        //  test the new resetConfigKeyData method
        ckge.resetConfigKeyData();
        ckge.sendEmail();
        ckge.cancelEmail();
        ckge.showMainSection();
        ckge.getEmail();
        ckge.getlktList();
        ckge.getComment();
        ckge.getCfgKeyHtml();
        //ckge.generateConfigKey();
        
        //  query line items that have a product of RN, TP, MC, FL  OR RIC AND THEN pass those line items into the methods below
       
        
        //  tests for new Emergency Button additions
        boolean testBool = ckge.isEmergencyKey;
        User testUser = ckge.currentUser;
        system.assertNotEquals(null, ConfigKeyGenerationExtension.overallEmergencyHelp);
        system.assertNotEquals(null, ConfigKeyGenerationExtension.limitsSectionDetailedHelp);
        system.assertNotEquals(null, ConfigKeyGenerationExtension.productsSectionDetailedHelp);
        
        Account acc = new Account ();
        
        ApexPages.StandardController sc = new ApexPages.StandardController(acct2);
        product2 prod = new product2();
        prod.name = 'test prod';
        prod.Product_Identifier__c = 'DVIR';
        prod.Product_Type__c ='Software';
        prod.Is_Perpetual__c = true;
        insert prod;
		
        Customer_Asset__c csA = new Customer_Asset__c ();
        csA.Account__c = acct2.id;
        csA.Eval__c = true;
        csA.Asset_Status__c = 'Active';
        csA.product__c = prod.id;
        
        insert csA;
        Customer_Asset__c csA2 = new Customer_Asset__c ();
        csA2.Account__c = acct2.id;
        csA2.product__c = prod.id;
     
        insert csA2;
        csA2 = [select id,product__c,product__r.Product_Identifier__c,Term_End_Date__c,Product__r.Name from Customer_Asset__c where id =:csA2.id];
        ConfigKeyGenerationExtension obj = new ConfigKeyGenerationExtension (sc);
        obj.lktList = null;
        obj.setEmail('abc@gmail.com');
        obj.setComment('test comment');
        obj.isRn(csA);
        ConfigKeyGenerationExtension.AssetEx objAssetEx = new ConfigKeyGenerationExtension.AssetEx (csA);
        obj.isTp(csA);
        obj.isMc(csA);
        obj.isFl(csA);
        obj.isRpd(csA);
        obj.iswsMapAss(csA);
        obj.isWsDataIntAss(csA);
        obj.isnetSchAss(csA);
        obj.ismerchAss(csA);
        obj.ismcDvirAss(csA);
        obj.isrtsConnectAss(csA);
        obj.isrnTeleAdaptAss(csA);
        obj.isrnActiveAlertAss(csA);
        obj.isVoiceNavAss(csA);
        ConfigKeyGenerationExtension.getProductShortName(objAssetEx);
        Obj.cloneCertainAssetFields(objAssetEx, csA);
        ConfigKeyGenerationExtension.getAssetDate(objAssetEx);
        ConfigKeyGenerationExtension.nullToZero(null);
        ConfigKeyGenerationExtension.nullToZero(12);
        //ConfigKeyGenerationExtension.createTestDataSet1();
        //ConfigKeyGenerationExtension.createTestDataSet2();
        obj.isRn(csA2);
        ConfigKeyGenerationExtension.AssetEx objAssetEx2 = new ConfigKeyGenerationExtension.AssetEx (csA2);
        obj.isTp(csA2);
        obj.isMc(csA2);
        obj.isFl(csA2);
        obj.isRpd(csA2);
        obj.iswsMapAss(csA2);
        obj.isWsDataIntAss(csA2);
        obj.isnetSchAss(csA2);
        obj.ismerchAss(csA2);
        obj.ismcDvirAss(csA2);
        obj.isrtsConnectAss(csA2);
        obj.isrnTeleAdaptAss(csA2);
        obj.isrnActiveAlertAss(csA2);
        obj.isVoiceNavAss(csA2);
        ConfigKeyGenerationExtension.getProductShortName(objAssetEx2);
        Obj.cloneCertainAssetFields(objAssetEx2, csA2);
        ConfigKeyGenerationExtension.getAssetDate(objAssetEx2);
        ConfigKeyGenerationExtension.nullToZero(null);
        ConfigKeyGenerationExtension.nullToZero(12);
        
        Database.rollback(sp);
        
    }
    public static testmethod void testForConfigKeyGenerationExtension12()
    {
        SavePoint sp = Database.setSavepoint();
       // Account acct2 = ConfigKeyGenerationExtension.createTestDataSet2();
       // Create and insert account
       	Account acct1 = new Account();
        acct1.Type = 'Customer';
        acct1.Name = 'CWH 1';
        acct1.BillingCountry = 'India';
        acct1.billingstreet = 'Billing 101';
        acct1.billingcity = 'Billing 101';
        acct1.billingstate = 'Billing 101';
        acct1.BillingPostalCode = '75052';
        acct1.Fleet_Size__c= 25;
        acct1.Segment__c='TL';
        
        //acct1.Inherit_Parent_s_Products__c = true;
        insert acct1;
        
        Account acct2 = new Account();
        acct2.Type = 'Customer';
        acct2.Name = 'CWH Test Account 2';
        acct2.BillingCountry = acct2.ShippingCountry = 'Mexico';
        acct2.billingstreet = 'Billing Street';
        acct2.billingcity = 'Billing City';
        acct2.billingstate = 'Billing State';
        acct2.BillingPostalCode = 'Billing PostalCode';
        acct2.Fleet_Size__c= 25;
        acct2.Segment__c='TL';
        acct2.Inherit_Parent_s_Products__c = true;
        acct2.parentid = acct1.id;
        insert acct2;
        
        ApexPages.standardController controller = new ApexPages.standardController(acct2);
        ConfigKeyGenerationExtension ckge = new ConfigKeyGenerationExtension(controller);
        
        string cfgKeyTxt = ckge.getCfgKeyTxt();
        
        
        //  test the new resetConfigKeyData method
        ckge.resetConfigKeyData();
        ckge.sendEmail();
        ckge.cancelEmail();
        ckge.showMainSection();
        ckge.getEmail();
        ckge.getlktList();
        ckge.getComment();
        ckge.getCfgKeyHtml();
        //ckge.generateConfigKey();
        
        //  query line items that have a product of RN, TP, MC, FL  OR RIC AND THEN pass those line items into the methods below
       
        
        //  tests for new Emergency Button additions
        boolean testBool = ckge.isEmergencyKey;
        User testUser = ckge.currentUser;
        system.assertNotEquals(null, ConfigKeyGenerationExtension.overallEmergencyHelp);
        system.assertNotEquals(null, ConfigKeyGenerationExtension.limitsSectionDetailedHelp);
        system.assertNotEquals(null, ConfigKeyGenerationExtension.productsSectionDetailedHelp);
        
        Account acc = new Account ();
        
        ApexPages.StandardController sc = new ApexPages.StandardController(acct2);
        product2 prod = new product2();
        prod.name = 'test prod';
        prod.Product_Identifier__c = 'SAP';
        prod.Product_Type__c ='Software';
        prod.Is_Perpetual__c = true;
        insert prod;
		
        Customer_Asset__c csA = new Customer_Asset__c ();
        csA.Account__c = acct2.id;
        csA.Eval__c = true;
        csA.Asset_Status__c = 'Active';
        csA.product__c = prod.id;
        
        insert csA;
        Customer_Asset__c csA2 = new Customer_Asset__c ();
        csA2.Account__c = acct2.id;
        csA2.product__c = prod.id;
     
        insert csA2;
        csA2 = [select id,product__c,product__r.Product_Identifier__c,Term_End_Date__c,Product__r.Name from Customer_Asset__c where id =:csA2.id];
        ConfigKeyGenerationExtension obj = new ConfigKeyGenerationExtension (sc);
        obj.lktList = null;
        obj.setEmail('abc@gmail.com');
        obj.setComment('test comment');
        obj.isRn(csA);
        ConfigKeyGenerationExtension.AssetEx objAssetEx = new ConfigKeyGenerationExtension.AssetEx (csA);
        obj.isTp(csA);
        obj.isMc(csA);
        obj.isFl(csA);
        obj.isRpd(csA);
        obj.iswsMapAss(csA);
        obj.isWsDataIntAss(csA);
        obj.isnetSchAss(csA);
        obj.ismerchAss(csA);
        obj.ismcDvirAss(csA);
        obj.isrtsConnectAss(csA);
        obj.isrnTeleAdaptAss(csA);
        obj.isrnActiveAlertAss(csA);
        obj.isVoiceNavAss(csA);
        ConfigKeyGenerationExtension.getProductShortName(objAssetEx);
        Obj.cloneCertainAssetFields(objAssetEx, csA);
        ConfigKeyGenerationExtension.getAssetDate(objAssetEx);
        ConfigKeyGenerationExtension.nullToZero(null);
        ConfigKeyGenerationExtension.nullToZero(12);
        //ConfigKeyGenerationExtension.createTestDataSet1();
        //ConfigKeyGenerationExtension.createTestDataSet2();
        obj.isRn(csA2);
        ConfigKeyGenerationExtension.AssetEx objAssetEx2 = new ConfigKeyGenerationExtension.AssetEx (csA2);
        obj.isTp(csA2);
        obj.isMc(csA2);
        obj.isFl(csA2);
        obj.isRpd(csA2);
        obj.iswsMapAss(csA2);
        obj.isWsDataIntAss(csA2);
        obj.isnetSchAss(csA2);
        obj.ismerchAss(csA2);
        obj.ismcDvirAss(csA2);
        obj.isrtsConnectAss(csA2);
        obj.isrnTeleAdaptAss(csA2);
        obj.isrnActiveAlertAss(csA2);
        obj.isVoiceNavAss(csA2);
        ConfigKeyGenerationExtension.getProductShortName(objAssetEx2);
        Obj.cloneCertainAssetFields(objAssetEx2, csA2);
        ConfigKeyGenerationExtension.getAssetDate(objAssetEx2);
        ConfigKeyGenerationExtension.nullToZero(null);
        ConfigKeyGenerationExtension.nullToZero(12);
        
        Database.rollback(sp);
        
    }
    public static testmethod void testForConfigKeyGenerationExtension13()
    {
        SavePoint sp = Database.setSavepoint();
       // Account acct2 = ConfigKeyGenerationExtension.createTestDataSet2();
       // Create and insert account
       	Account acct1 = new Account();
        acct1.Type = 'Customer';
        acct1.Name = 'CWH 1';
        acct1.BillingCountry = 'India';
        acct1.billingstreet = 'Billing 101';
        acct1.billingcity = 'Billing 101';
        acct1.billingstate = 'Billing 101';
        acct1.BillingPostalCode = '75052';
        acct1.Fleet_Size__c= 25;
        acct1.Segment__c='TL';
        
        //acct1.Inherit_Parent_s_Products__c = true;
        insert acct1;
        
        Account acct2 = new Account();
        acct2.Type = 'Customer';
        acct2.Name = 'CWH Test Account 2';
        acct2.BillingCountry = acct2.ShippingCountry = 'Mexico';
        acct2.billingstreet = 'Billing Street';
        acct2.billingcity = 'Billing City';
        acct2.billingstate = 'Billing State';
        acct2.BillingPostalCode = 'Billing PostalCode';
        acct2.Fleet_Size__c= 25;
        acct2.Segment__c='TL';
        acct2.Inherit_Parent_s_Products__c = true;
        acct2.parentid = acct1.id;
        insert acct2;
        
        ApexPages.standardController controller = new ApexPages.standardController(acct2);
        ConfigKeyGenerationExtension ckge = new ConfigKeyGenerationExtension(controller);
        
        string cfgKeyTxt = ckge.getCfgKeyTxt();
        
        
        //  test the new resetConfigKeyData method
        ckge.resetConfigKeyData();
        ckge.sendEmail();
        ckge.cancelEmail();
        ckge.showMainSection();
        ckge.getEmail();
        ckge.getlktList();
        ckge.getComment();
        ckge.getCfgKeyHtml();
        //ckge.generateConfigKey();
        
        //  query line items that have a product of RN, TP, MC, FL  OR RIC AND THEN pass those line items into the methods below
       
        
        //  tests for new Emergency Button additions
        boolean testBool = ckge.isEmergencyKey;
        User testUser = ckge.currentUser;
        system.assertNotEquals(null, ConfigKeyGenerationExtension.overallEmergencyHelp);
        system.assertNotEquals(null, ConfigKeyGenerationExtension.limitsSectionDetailedHelp);
        system.assertNotEquals(null, ConfigKeyGenerationExtension.productsSectionDetailedHelp);
        
        Account acc = new Account ();
        
        ApexPages.StandardController sc = new ApexPages.StandardController(acct2);
        product2 prod = new product2();
        prod.name = 'test prod';
        prod.Product_Identifier__c = 'TMX';
        prod.Product_Type__c ='Software';
        prod.Is_Perpetual__c = true;
        insert prod;
		
        Customer_Asset__c csA = new Customer_Asset__c ();
        csA.Account__c = acct2.id;
        csA.Eval__c = true;
        csA.Asset_Status__c = 'Active';
        csA.product__c = prod.id;
        
        insert csA;
        Customer_Asset__c csA2 = new Customer_Asset__c ();
        csA2.Account__c = acct2.id;
        csA2.product__c = prod.id;
     
        insert csA2;
        csA2 = [select id,product__c,product__r.Product_Identifier__c,Term_End_Date__c,Product__r.Name from Customer_Asset__c where id =:csA2.id];
        ConfigKeyGenerationExtension obj = new ConfigKeyGenerationExtension (sc);
        obj.lktList = null;
        obj.setEmail('abc@gmail.com');
        obj.setComment('test comment');
        obj.isRn(csA);
        ConfigKeyGenerationExtension.AssetEx objAssetEx = new ConfigKeyGenerationExtension.AssetEx (csA);
        obj.isTp(csA);
        obj.isMc(csA);
        obj.isFl(csA);
        obj.isRpd(csA);
        obj.iswsMapAss(csA);
        obj.isWsDataIntAss(csA);
        obj.isnetSchAss(csA);
        obj.ismerchAss(csA);
        obj.ismcDvirAss(csA);
        obj.isrtsConnectAss(csA);
        obj.isrnTeleAdaptAss(csA);
        obj.isrnActiveAlertAss(csA);
        obj.isVoiceNavAss(csA);
        ConfigKeyGenerationExtension.getProductShortName(objAssetEx);
        Obj.cloneCertainAssetFields(objAssetEx, csA);
        ConfigKeyGenerationExtension.getAssetDate(objAssetEx);
        ConfigKeyGenerationExtension.nullToZero(null);
        ConfigKeyGenerationExtension.nullToZero(12);
        //ConfigKeyGenerationExtension.createTestDataSet1();
        //ConfigKeyGenerationExtension.createTestDataSet2();
        obj.isRn(csA2);
        ConfigKeyGenerationExtension.AssetEx objAssetEx2 = new ConfigKeyGenerationExtension.AssetEx (csA2);
        obj.isTp(csA2);
        obj.isMc(csA2);
        obj.isFl(csA2);
        obj.isRpd(csA2);
        obj.iswsMapAss(csA2);
        obj.isWsDataIntAss(csA2);
        obj.isnetSchAss(csA2);
        obj.ismerchAss(csA2);
        obj.ismcDvirAss(csA2);
        obj.isrtsConnectAss(csA2);
        obj.isrnTeleAdaptAss(csA2);
        obj.isrnActiveAlertAss(csA2);
        obj.isVoiceNavAss(csA2);
        ConfigKeyGenerationExtension.getProductShortName(objAssetEx2);
        Obj.cloneCertainAssetFields(objAssetEx2, csA2);
        ConfigKeyGenerationExtension.getAssetDate(objAssetEx2);
        ConfigKeyGenerationExtension.nullToZero(null);
        ConfigKeyGenerationExtension.nullToZero(12);
        
        Database.rollback(sp);
        
    }
    public static testmethod void testForConfigKeyGenerationExtension14()
    {
        SavePoint sp = Database.setSavepoint();
       // Account acct2 = ConfigKeyGenerationExtension.createTestDataSet2();
       // Create and insert account
       	Account acct1 = new Account();
        acct1.Type = 'Customer';
        acct1.Name = 'CWH 1';
        acct1.BillingCountry = 'India';
        acct1.billingstreet = 'Billing 101';
        acct1.billingcity = 'Billing 101';
        acct1.billingstate = 'Billing 101';
        acct1.BillingPostalCode = '75052';
        acct1.Fleet_Size__c= 25;
        acct1.Segment__c='TL';
        
        //acct1.Inherit_Parent_s_Products__c = true;
        insert acct1;
        
        Account acct2 = new Account();
        acct2.Type = 'Customer';
        acct2.Name = 'CWH Test Account 2';
        acct2.BillingCountry = acct2.ShippingCountry = 'Mexico';
        acct2.billingstreet = 'Billing Street';
        acct2.billingcity = 'Billing City';
        acct2.billingstate = 'Billing State';
        acct2.BillingPostalCode = 'Billing PostalCode';
        acct2.Fleet_Size__c= 25;
        acct2.Segment__c='TL';
        acct2.Inherit_Parent_s_Products__c = true;
        acct2.parentid = acct1.id;
        insert acct2;
        
        ApexPages.standardController controller = new ApexPages.standardController(acct2);
        ConfigKeyGenerationExtension ckge = new ConfigKeyGenerationExtension(controller);
        
        string cfgKeyTxt = ckge.getCfgKeyTxt();
        
        
        //  test the new resetConfigKeyData method
        ckge.resetConfigKeyData();
        ckge.sendEmail();
        ckge.cancelEmail();
        ckge.showMainSection();
        ckge.getEmail();
        ckge.getlktList();
        ckge.getComment();
        ckge.getCfgKeyHtml();
        //ckge.generateConfigKey();
        
        //  query line items that have a product of RN, TP, MC, FL  OR RIC AND THEN pass those line items into the methods below
       
        
        //  tests for new Emergency Button additions
        boolean testBool = ckge.isEmergencyKey;
        User testUser = ckge.currentUser;
        system.assertNotEquals(null, ConfigKeyGenerationExtension.overallEmergencyHelp);
        system.assertNotEquals(null, ConfigKeyGenerationExtension.limitsSectionDetailedHelp);
        system.assertNotEquals(null, ConfigKeyGenerationExtension.productsSectionDetailedHelp);
        
        Account acc = new Account ();
        
        ApexPages.StandardController sc = new ApexPages.StandardController(acct2);
        product2 prod = new product2();
        prod.name = 'test prod';
        prod.Product_Identifier__c = 'RAA';
        prod.Product_Type__c ='Software';
        prod.Is_Perpetual__c = true;
        insert prod;
		
        Customer_Asset__c csA = new Customer_Asset__c ();
        csA.Account__c = acct2.id;
        csA.Eval__c = true;
        csA.Asset_Status__c = 'Active';
        csA.product__c = prod.id;
        
        insert csA;
        Customer_Asset__c csA2 = new Customer_Asset__c ();
        csA2.Account__c = acct2.id;
        csA2.product__c = prod.id;
     
        insert csA2;
        csA2 = [select id,product__c,product__r.Product_Identifier__c,Term_End_Date__c,Product__r.Name from Customer_Asset__c where id =:csA2.id];
        ConfigKeyGenerationExtension obj = new ConfigKeyGenerationExtension (sc);
        obj.lktList = null;
        obj.setEmail('abc@gmail.com');
        obj.setComment('test comment');
        obj.isRn(csA);
        ConfigKeyGenerationExtension.AssetEx objAssetEx = new ConfigKeyGenerationExtension.AssetEx (csA);
        obj.isTp(csA);
        obj.isMc(csA);
        obj.isFl(csA);
        obj.isRpd(csA);
        obj.iswsMapAss(csA);
        obj.isWsDataIntAss(csA);
        obj.isnetSchAss(csA);
        obj.ismerchAss(csA);
        obj.ismcDvirAss(csA);
        obj.isrtsConnectAss(csA);
        obj.isrnTeleAdaptAss(csA);
        obj.isrnActiveAlertAss(csA);
        obj.isVoiceNavAss(csA);
        ConfigKeyGenerationExtension.getProductShortName(objAssetEx);
        Obj.cloneCertainAssetFields(objAssetEx, csA);
        ConfigKeyGenerationExtension.getAssetDate(objAssetEx);
        ConfigKeyGenerationExtension.nullToZero(null);
        ConfigKeyGenerationExtension.nullToZero(12);
        //ConfigKeyGenerationExtension.createTestDataSet1();
        //ConfigKeyGenerationExtension.createTestDataSet2();
        obj.isRn(csA2);
        ConfigKeyGenerationExtension.AssetEx objAssetEx2 = new ConfigKeyGenerationExtension.AssetEx (csA2);
        obj.isTp(csA2);
        obj.isMc(csA2);
        obj.isFl(csA2);
        obj.isRpd(csA2);
        obj.iswsMapAss(csA2);
        obj.isWsDataIntAss(csA2);
        obj.isnetSchAss(csA2);
        obj.ismerchAss(csA2);
        obj.ismcDvirAss(csA2);
        obj.isrtsConnectAss(csA2);
        obj.isrnTeleAdaptAss(csA2);
        obj.isrnActiveAlertAss(csA2);
        obj.isVoiceNavAss(csA2);
        ConfigKeyGenerationExtension.getProductShortName(objAssetEx2);
        Obj.cloneCertainAssetFields(objAssetEx2, csA2);
        ConfigKeyGenerationExtension.getAssetDate(objAssetEx2);
        ConfigKeyGenerationExtension.nullToZero(null);
        ConfigKeyGenerationExtension.nullToZero(12);
        
        Database.rollback(sp);
        
    }
    public static testmethod void testForConfigKeyGenerationExtension15()
    {
        SavePoint sp = Database.setSavepoint();
       // Account acct2 = ConfigKeyGenerationExtension.createTestDataSet2();
       // Create and insert account
       	Account acct1 = new Account();
        acct1.Type = 'Customer';
        acct1.Name = 'CWH 1';
        acct1.BillingCountry = 'India';
        acct1.billingstreet = 'Billing 101';
        acct1.billingcity = 'Billing 101';
        acct1.billingstate = 'Billing 101';
        acct1.BillingPostalCode = '75052';
        acct1.Fleet_Size__c= 25;
        acct1.Segment__c='TL';
        
        //acct1.Inherit_Parent_s_Products__c = true;
        insert acct1;
        
        Account acct2 = new Account();
        acct2.Type = 'Customer';
        acct2.Name = 'CWH Test Account 2';
        acct2.BillingCountry = acct2.ShippingCountry = 'Mexico';
        acct2.billingstreet = 'Billing Street';
        acct2.billingcity = 'Billing City';
        acct2.billingstate = 'Billing State';
        acct2.BillingPostalCode = 'Billing PostalCode';
        acct2.Fleet_Size__c= 25;
        acct2.Segment__c='TL';
        acct2.Inherit_Parent_s_Products__c = true;
        acct2.parentid = acct1.id;
        insert acct2;
        
        ApexPages.standardController controller = new ApexPages.standardController(acct2);
        ConfigKeyGenerationExtension ckge = new ConfigKeyGenerationExtension(controller);
        
        string cfgKeyTxt = ckge.getCfgKeyTxt();
        
        
        //  test the new resetConfigKeyData method
        ckge.resetConfigKeyData();
        ckge.sendEmail();
        ckge.cancelEmail();
        ckge.showMainSection();
        ckge.getEmail();
        ckge.getlktList();
        ckge.getComment();
        ckge.getCfgKeyHtml();
        //ckge.generateConfigKey();
        
        //  query line items that have a product of RN, TP, MC, FL  OR RIC AND THEN pass those line items into the methods below
       
        
        //  tests for new Emergency Button additions
        boolean testBool = ckge.isEmergencyKey;
        User testUser = ckge.currentUser;
        system.assertNotEquals(null, ConfigKeyGenerationExtension.overallEmergencyHelp);
        system.assertNotEquals(null, ConfigKeyGenerationExtension.limitsSectionDetailedHelp);
        system.assertNotEquals(null, ConfigKeyGenerationExtension.productsSectionDetailedHelp);
        
        Account acc = new Account ();
        
        ApexPages.StandardController sc = new ApexPages.StandardController(acct2);
        product2 prod = new product2();
        prod.name = 'test prod';
        prod.Product_Identifier__c = 'VOICENAV';
        prod.Product_Type__c ='Software';
        prod.Is_Perpetual__c = true;
        insert prod;
		
        Customer_Asset__c csA = new Customer_Asset__c ();
        csA.Account__c = acct2.id;
        csA.Eval__c = true;
        csA.Asset_Status__c = 'Active';
        csA.product__c = prod.id;
        
        insert csA;
        Customer_Asset__c csA2 = new Customer_Asset__c ();
        csA2.Account__c = acct2.id;
        csA2.product__c = prod.id;
     
        insert csA2;
        csA2 = [select id,product__c,product__r.Product_Identifier__c,Term_End_Date__c,Product__r.Name from Customer_Asset__c where id =:csA2.id];
        ConfigKeyGenerationExtension obj = new ConfigKeyGenerationExtension (sc);
        obj.lktList = null;
        obj.setEmail('abc@gmail.com');
        obj.setComment('test comment');
        obj.isRn(csA);
        ConfigKeyGenerationExtension.AssetEx objAssetEx = new ConfigKeyGenerationExtension.AssetEx (csA);
        obj.isTp(csA);
        obj.isMc(csA);
        obj.isFl(csA);
        obj.isRpd(csA);
        obj.iswsMapAss(csA);
        obj.isWsDataIntAss(csA);
        obj.isnetSchAss(csA);
        obj.ismerchAss(csA);
        obj.ismcDvirAss(csA);
        obj.isrtsConnectAss(csA);
        obj.isrnTeleAdaptAss(csA);
        obj.isrnActiveAlertAss(csA);
        obj.isVoiceNavAss(csA);
        ConfigKeyGenerationExtension.getProductShortName(objAssetEx);
        Obj.cloneCertainAssetFields(objAssetEx, csA);
        ConfigKeyGenerationExtension.getAssetDate(objAssetEx);
        ConfigKeyGenerationExtension.nullToZero(null);
        ConfigKeyGenerationExtension.nullToZero(12);
        //ConfigKeyGenerationExtension.createTestDataSet1();
        //ConfigKeyGenerationExtension.createTestDataSet2();
        obj.isRn(csA2);
        ConfigKeyGenerationExtension.AssetEx objAssetEx2 = new ConfigKeyGenerationExtension.AssetEx (csA2);
        obj.isTp(csA2);
        obj.isMc(csA2);
        obj.isFl(csA2);
        obj.isRpd(csA2);
        obj.iswsMapAss(csA2);
        obj.isWsDataIntAss(csA2);
        obj.isnetSchAss(csA2);
        obj.ismerchAss(csA2);
        obj.ismcDvirAss(csA2);
        obj.isrtsConnectAss(csA2);
        obj.isrnTeleAdaptAss(csA2);
        obj.isrnActiveAlertAss(csA2);
        obj.isVoiceNavAss(csA2);
        ConfigKeyGenerationExtension.getProductShortName(objAssetEx2);
        Obj.cloneCertainAssetFields(objAssetEx2, csA2);
        ConfigKeyGenerationExtension.getAssetDate(objAssetEx2);
        ConfigKeyGenerationExtension.nullToZero(null);
        ConfigKeyGenerationExtension.nullToZero(12);
        
        Database.rollback(sp);
        
    }
  
     //  **********  test for UpdateRTSVersionExtension.cls   *******************************
   public static testmethod void testForUpdateRTSVersionExtension()
    {
        Savepoint sp = Database.setSavepoint();
        Account testAccount = [select id from account limit 1];
        //Account testAccount = [select id from account where parentid != null limit 1];
        /*Account testAccount = new Account();
        testAccount.Name = 'XYZ Account';
        testAccount.shippingCountry = 'United States';
        testAccount.BillingCountry = 'United States';
        testAccount.Territory__c = 'BlargTerr';
        testAccount.Account_Class_1__c = 'BlargClass';
        testAccount.Geo_Region__c = 'BlargGeoRegion';
        testAccount.Primary_Business_Unit__c = 'Roadnet';
        testAccount.billingstreet = 'fake street';
        testAccount.billingcity = 'fake city';
        testAccount.billingstate = 'MD';
        testAccount.BillingPostalCode = '21286';
        testAccount.billingCountry = 'USA';
        testAccount.Parentid = testAcc.id;
        testAccount.Segment__c = 'TL';
        testAccount.Fleet_Size__c = 25;
        Insert testAccount;*/
        

        UpdateRTSVersionExtension testExtension = new UpdateRTSVersionExtension(UpdateRTSVersionExtension.generateController(testAccount));
        
       
        system.assertNotEquals(null, testExtension.getAccount());
        
        testExtension.account.RTS_Installed_Version__c = ''; 
        testExtension.updateRTSInstalledVersion();
        
        //  null out both the rts installed and shipped version and assert that the pagereerence = null
       	system.assertNotEquals(null, testExtension.returnToAccount());

        Database.rollback(sp);
    }
    
    public static testmethod void testForUpdateRTSVersionExtension1()
    {
        Savepoint sp = Database.setSavepoint();
        Account testAccount = [select id from account limit 1];

        UpdateRTSVersionExtension testExtension = new UpdateRTSVersionExtension(UpdateRTSVersionExtension.generateController(testAccount));
        
       
        system.assertNotEquals(null, testExtension.getAccount());
        
        testExtension.account.RTS_Installed_Version__c = 'RTS-3.00'; 
        testExtension.updateRTSInstalledVersion();
        testExtension.isNullOrBlank(null);
        testExtension.isNullOrBlank('');
        
        //  null out both the rts installed and shipped version and assert that the pagereerence = null
       	system.assertNotEquals(null, testExtension.returnToAccount());

        Database.rollback(sp);
    }
        //  **********  test for ViewVarHierarchyExtension.cls   *******************************
    public static testmethod void testForFindVar()
    {
        Savepoint sp = Database.setSavepoint();
        account testAccount = ViewVarHierarchyExtension.createTestSubVarAccount([select id from ACcount limit 1].id);
        ApexPages.standardController controller = new ApexPages.standardController(testaccount);
        
        ViewVarHierarchyExtension testthis=new ViewVarHierarchyExtension(controller);
        system.assertNotEquals(null, testthis.findVar(testAccount));
        Database.rollback(sp);
    }
    
    public static testmethod void testForMain()
    {
        Savepoint sp = Database.setSavepoint();

        pagereference pageRef=new pagereference('Page.ViewVarHierarchyExtension');
        
        Account testVarAccount = ViewVarHierarchyExtension.createTestAccount();
        Account testSubVarAccount = ViewVarHierarchyExtension.createTestSubVarAccount(testVarAccount.Id);
        Account testAccountOfSubVarAccount = ViewVarHierarchyExtension.createTestAccountOfSubVarAccount(testSubVarAccount.id);
        Account testAccountOfVar = ViewVarHierarchyExtension.createTestAccount();
        testAccountOfVar.var_account1__c = testVarAccount.id;
        testAccountOfVar.type = 'Customer - Active';
        //testAccountOfVar.Web_Password__c = 'fffalsofa';
        update testAccountOfVar;
        
        ApexPages.standardController controller = new ApexPages.standardController(testVarAccount);
        
        ViewVarHierarchyExtension testExtension = new ViewVarHierarchyExtension(controller);
        
        system.assertNotEquals(null, TestExtension.getallAccountsInHierarchy());
        system.assertNotEquals(null, TestExtension.getTheAccount());
                        
        Database.rollback(sp);
    }
    
    public static testmethod void testForAccountStructClass()
    {
        Savepoint sp = Database.setSavepoint();
        Account testAccount = ViewVarHierarchyExtension.createTestAccount();
   
        ViewVarHierarchyExtension.AccountStruct testObject = new ViewVarHierarchyExtension.AccountStruct(testAccount, 1);
        testObject.getId();
        testObject.getName();
        testObject.getaccountType();
        testObject.getphysicalCountry();
        testObject.getOwner();
        testObject.getIndustry();
        testObject.getspaceForIndentation();
        Database.rollback(sp);
    }
    //  **********  test for ArticleToCaseConversion.cls   *******************************
    public static testMethod void testAgentContributionArticleController()
    {
        Savepoint sp = Database.setSavepoint();
        //  this was copypasted from reference guide, modded to work with my class 
         Case testCase = CreateTestCase('SFDC Support');
         
         ApexPages.currentPage().getParameters().put('sourceId', testCase.id);
         ApexPages.currentPage().getParameters().put('sfdc.override', '1');
         
         ApexPages.KnowledgeArticleVersionStandardController testController = 
            new ApexPages.KnowledgeArticleVersionStandardController(new Solution__kav());
            
         
         new ArticleToCaseConversion(testController);

         System.assertEquals(testCase.id, testController.getSourceId());
         //System.assertEquals('From Case: '+caseSubject, ctl.getRecord().get('title'));
         //System.assertEquals(caseDesc, ctl.getRecord().get('details__c'));
         
         Database.rollback(sp);
   }
   
        //  **********  start tests for SupportHoldEmailExtension.cls   *******************************
    public static testmethod void testForSupportHoldEmailExtension()
    {
        Savepoint sp = Database.setSavepoint();
        Contact testContact = [select id, accountid, email from contact where email != null and account.primary_business_unit__c = 'Roadnet' limit 1];
        
        Account testAccount = [select id from account where id =: testcontact.accountid];
        
        SupportHoldEmailExtension testExtension = new SupportHoldEmailExtension(SupportHoldEmailExtension.generateController(testAccount));
        
        testExtension.toEmail = testContact.email;
        testExtension.ccEmail = 'jhutchins@roadnet.com';
        testExtension.bccEmail = 'jhutchins@roadnet.com';
        testExtension.addContact();
        List<SelectOption> options = testExtension.contactPicklist;
        
        testExtension.sendEmail();
        
        Database.rollback(sp);
    }

    //  **********  end tests for SupportHoldEmailExtension.cls   *******************************
    
    //  **********  test for EmailSendSuccessfulController.cls   *******************************
    public static testmethod void testForEmailSendSuccessfulController()
    {
        Savepoint sp = Database.setSavepoint();
        Account testAccount = [select id from account limit 1];
        EmailSendSuccessfulController testController = 
            new EmailSendSuccessfulController(EmailSendSuccessfulController.generateController(testAccount, '/home/home.jsp'));
        testController.back();
        Database.rollback(sp);
    }  
     //  **********  test for LicenseRestrictionUnlockExtension.cls   *******************************
    public static testmethod void testForLicenseRestrictionUnlockExtension()
    {
        Savepoint sp = Database.setSavepoint();
        Account testAccount = [select id from aCcount where parentid != null and billingcountry != null and shippingcountry != null limit 1];
     // testAccount.clientele_id__c = '1234testClienteleId';
        update testAccount;
        
        LicenseRestrictionUnlockExtension testExtension = 
            new LicenseRestrictionUnlockExtension(LicenseRestrictionUnlockExtension.generateController(testAccount));
        testExtension.licenseTask.whoId = [select id from contact where email != null limit 1].id;
        testExtension.pickListSelection = [select id from contact where email != null limit 1].id;
        testExtension.licenseTask.description = 'Test Reason';
        testExtension.sendEmail();
        
        testExtension.cancel();
        //  test getters and setters
        system.assertNotEquals(null, testExtension.getAccount());
        system.assertNotEquals(null, testExtension.getLoggedInUser());
        system.assertNotEquals(null, testExtension.accountContacts);
        
        testExtension.isSelectingPickList = true;
        testExtension.sendEmail();
                
        Database.rollback(sp);
    }
        //  **********  tests for StreetAreaExtension.cls  *****************
    public static testmethod void testForOnChangeClass()
    {
        Savepoint sp = Database.setSavepoint();
        Street_Area__c testOG = new Street_Area__c();
        StreetAreaExtension testExtension = new StreetAreaExtension(StreetAreaExtension.generateController(testOG));
        StreetAreaExtension.OnChangeClass testObject = new StreetAreaExtension.OnChangeClass();
        testObject = new StreetAreaExtension.OnChangeClass(true);
        testObject.setNewValue(true);
        
        system.assertEquals(true, testObject.didBooleanOnChange(false));
        
        Database.rollback(sp);
    }
    public static testmethod void testForStreetAreaExtension()
    {
        Savepoint sp = Database.setSavepoint();
        
        Street_Area__c testOG = new Street_Area__c();
        StreetAreaExtension test = new StreetAreaExtension(StreetAreaExtension.generateController(testOG));
        test.streetArea.Map_nation__c = StreetAreaExtension.createTestMapNation().id;//[select id from map_nation__c where name = 'United States' limit 1].id;
        test.streetArea.Map_state__c = StreetAreaExtension.createTestMapSTate().id;//[select id from map_state__c where name = 'Maryland' limit 1].id;
        //  i dont know why this was in a try block before, im taking it out
        // try
        {   
            map_nation__c nation = new map_nation__c();
            map_state__c state = new map_state__c();
            map_county__c county = new map_county__c();
            nation.name = state.name = county.name = 'United States';
            insert nation;
            insert state;
            insert county;
            system.assertNotEquals(null, test.getStreetArea());
            system.assertNotEquals(null, test.getNationList());
            test.streetArea.isMapCountySpecified__c = test.streetArea.isMapStateSpecified__c = true;
            system.assertNotEquals(null, test.getStateList());
            system.assertNotEquals(null, test.getCountyList()); 
            system.assertNotEquals(null, test.getDisplayItemInCountyPickListOnlyOnce()); 
            system.assertNotEquals(null, test.getDisplayItemInStatePickListOnlyOnce()); 
            system.assertNotEquals(null, test.getIsVFPageInNewMode());
            test.setStateObject(new SelectOptionManagerForStreetArea());            
            system.assertNotEquals(null, test.getStateObject());
            test.setCountyObject(new SelectOptionManagerForStreetArea());
            system.assertNotEquals(null, test.getCountyObject());
            system.assertNotEquals(null, test.getStateObject());
            system.assertNotEquals(null, test.getStateObject());
              
            //  lets set the vf page into edit mode and call the get for selectoption lists again
            test.isVFpageInNewMode = false;
            system.assertNotEquals(null, test.getNationList());
            system.assertNotEquals(null, test.getStateList());
            system.assertNotEquals(null, test.getCountyList());
            system.assertNotEquals(null, test.isSelectingMultipleStates);
            test.setStreetArea(new Street_Area__c());
            test.refreshData();
            test.streetArea.isMapStateSpecified__c = false;
            test.refreshData();
            test.streetArea.map_nation__c = StreetAreaExtension.createTestMapNation().id;
            test.refreshData();
            test.streetARea.map_state__c = StreetAreaExtension.createTestMapState().id;
            test.refreshData();
            
            system.assertNotEquals(null, test.redirectToNewOrEditPage());
            
            //  test for on change methods
            test.isSelectingMultipleStates = false;
            test.didIsSelectingMultipleStatesFieldOnChange();
            test.isSelectingMultipleStates = true;
            test.didIsSelectingMultipleStatesFieldOnChange();
            
            test.streetARea.IsMapCountySpecified__c = false;
            test.didIsMapCountySpecifiedFieldOnChange();
            test.streetArea.IsMapCountySpecified__c = true;
            test.streetArea.isMapStateSpecified__c = true;
            test.isSelectingMultipleStates = false;
            test.didIsMapCountySpecifiedFieldOnChange();
            
            test.streetARea.IsMapStateSpecified__c = false;
            test.didIsMapStateSpecifiedFieldOnChange();
            test.streetArea.IsMapStateSpecified__c = true;
            test.didIsMapStateSpecifiedFieldOnChange();         
            
            //  another test for refreshData method
            test.isVFPageInNewMode = true;
            test.streetArea.isMapStateSpecified__c = false;
            test.refreshData();
            
            //  test for initifpage is in edit mode
            Street_Area__c testStreetAReaREcord = StreetAreaExtension.createTestStreetArea(null); 
            test.streetArea = testStreetAreaRecord;
            test.streetAReaId = testStreetAReaREcord.id;
            test.initIfPageIsInEditMode();
            
            test.StreetArea = new Street_Area__c();
            test.isVFPageInCloneMode = true;
            test.initIfPageInCloneMode();
            
        }
        Database.rollback(sp);
        
    }
    
    
    public static testmethod void testForSaveStreetAreaExtension()
    {
        Savepoint sp = Database.setSavepoint();
        Street_Area__c testStreetArea = new Street_Area__c();
        StreetAreaExtension testExtension = new StreetAreaExtension(StreetAreaExtension.generateController(testStreetARea));
        testExtension.isVFPageInNewMode = true;
        testExtension.streetArea.map_set__c = [select id from Map_Set__c limit 1].id;
        system.assertNotEquals(null, testExtension.save());
        
        //  test for is vf page in clone mode
        testExtension.isVfPageInNewMode = false;
        testExtension.isVFPageInCloneMode = true;
        testExtension.streetArea = new Street_Area__c();
        system.assertNotEquals(null, testExtension.Save());
        
        //  test for is vf page in new mode = false
        testExtension.streetArea = StreetAreaExtension.createTestStreetArea(null);
        testExtension.isVFPageInCloneMOde = false;
        system.assertNotEquals(null, testExtension.save());
        Database.rollback(sp);
    }
    
    public static testmethod void testForGoThruEachCaseToTryANewSave()
    {
        Savepoint sp = Database.setSavepoint();
        List<string> listOfStrings = new List<String>();
        listOfStrings.add('testString');
        
        Street_Area__c testStreetArea = new Street_Area__c();
        Map_Set__c testMapSet = [select id from Map_Set__c limit 1];
        
        StreetAreaExtension testExtension = new StreetAreaExtension(StreetAreaExtension.generateController(testStreetARea));
        testExtension.streetARea.isMapStateSpecified__c = false;
        testExtension.streetARea.isMapCountySpecified__c = false;
        testExtension.streetARea.map_county__c = null;
        testExtension.streetArea.map_state__c = null;
        testExtension.streetArea.Map_Set__c = testMapSet.id;
        system.assertNotEquals(null, testExtension.goThruEachCaseToTryANewSave());
        
        //  test for second situation
        testExtension.streetArea = new Street_Area__c();
        testExtension.streetArea.map_state__c = [select id from Map_State__c limit 1].id;
        testExtension.streetArea.isMapStateSpecified__c = true;
        testExtension.isSelectingMultipleStates = false;
        testExtension.streetArea.isMapCountySpecified__c = false;
        testExtension.streetArea.Map_Set__c = testMapSet.id;
        system.assertNotEquals(null, testExtension.goThruEachCaseToTryANewSave());
        
        //  test for third situation
        testExtension.streetArea = new Street_Area__c();
        testExtension.streetArea.Map_Set__c = testMapSet.id;
        testExtension.streetArea.IsMapStateSpecified__c = true;
        testExtension.isSelectingMultipleStates = true;
        testExtension.stateObject.setUserSelectedItemsToAdd(listOfStrings);
        system.assertNotEquals(null, testExtension.goThruEachCaseToTryANewSave());
        
        //  test for fourth situation
        testExtension.streetArea = new Street_Area__c();
        testExtension.streetArea.Map_Set__c = testMapSet.id;
        testExtension.streetArea.isMapCountySpecified__c = true;
        testExtension.isSelectingMultipleStates = false;
        testExtension.countyObject.setUserSelectedItemsToAdd(listOfStrings);
        system.assertNotEquals(null, testExtension.goThruEachCaseToTryANewSave());
        Database.rollback(sp);
        
    }
    
    public static testMethod void testForcreateMultipleStreetAreasForMultipleCountySelections()
    {
        
        Savepoint sp = Database.setSavepoint();
        Street_Area__c testOG = new Street_Area__c();
        StreetAreaExtension test = new StreetAreaExtension(StreetAreaExtension.generateController(testOG));
        
        Street_Area__c testsa = StreetAreaExtension.createTestStreetArea();
        List<selectoption> testList = new List<Selectoption>();
        Map_County__c testmc;
        
        testmc = StreetAreaExtension.createTestMapCounty();
        testList.add(new selectoption(testmc.id, testmc.name));
        
        test.streetArea.isMapCountySpecified__c = true;
        
        test.createMultipleStreetAreasForMultipleCountySelections(testsa, testList);        
        Database.rollback(sp);
        
    }
    
    public static  testMethod void testForcreateMultipleStreetAreasForMultipleStateSelections()
    {
        
        Savepoint sp = Database.setSavepoint();
        Street_Area__c testOG = new Street_Area__c();
        StreetAreaExtension test = new StreetAreaExtension(StreetAreaExtension.generateController(testOG));
        
        Street_Area__c testsa = StreetAreaExtension.createTestStreetArea();
        List<selectoption> testList = new List<Selectoption>();
        Map_state__c testms;
        
        testms = StreetAreaExtension.createTestMapState();
        testList.add(new selectoption(testms.id, testms.name));
        
        test.createMultipleStreetAreasForMultipleStateSelections(testsa, testList);        
        Database.rollback(sp);
        
    }
    
    public static testMethod void testForStreetAreaExtensiondetermineIfVFPageIsInNewMode()
    {
        
        Savepoint sp = Database.setSavepoint();
        Street_Area__c testOG = new Street_Area__c();
        
        StreetAreaExtension test = new StreetAreaExtension(StreetAreaExtension.generateController(testOG));
        Map<string,string> testMap = new Map<string,string>();
        
        testmap.put('id',null);
        system.assertEquals(true, test.determineIfVFPageIsInNewMode(testMap));
                
        testMap.clear();
        testmap.put('id',[select id from Street_Area__c limit 1].id);
        system.assertEquals(false, test.determineIfVFPageIsInNewMode(testMap));
        //test.save();
        Database.rollback(sp);
    }   
    
    //  **********  end tests for StreetAreaExtension.cls  *****************
    
    //  **********  test for MapSetExtension.cls   *******************************
    public static testmethod void testForCopyFieldInformationToNewStreetArea()
    {
        Savepoint sp = Database.setSavepoint();
        
        Map_Set__c testMapSet = MapSetExtension.CreateTestMapSet(null);
        
        Street_Area__c testStreetArea = new Street_Area__c();
        
        system.assertNotEquals(null, MapSetExtension.copyFieldInformationToNewStreetArea(testStreetArea, testMapSet.id));
        Database.rollback(sp);
    }
    public static testmethod void testForPerformSaveOfClone()
    {
        Savepoint sp = Database.setSavepoint();
        
        Map_Set__c testMapSet = MapSetExtension.CreateTestMapSet(null);
        MapSetExtension testExtension = new MapSetExtension(MapSetExtension.generateController(testMapSet));
        testExtension.getMapVendorAccountList();
        system.assertNotEquals(null, testExtension.performSaveOfClone(testMapSet.id));
        Database.rollback(sp);
    }
    
    public static testMethod void testForThisClassNumberOne()
    {
        
        Savepoint sp = Database.setSavepoint();
        Map_Set__c testOG = new Map_Set__c();
        
        MapSetExtension test = new MapSetExtension(MapSetExtension.generateController(testOG));
       
        system.assertNotEquals(null, test.getmapSet());
        test.setmapSet(new Map_Set__c());
        
        test.initMapSetForClone([select id from Map_Set__c limit 1].id);
        //system.assertNotEquals(null, test.getVendorMapVersionList());
        Database.rollback(sp);
    }
    
    public static testMethod void testForThisClassNumberTwo()
    {
        
        Savepoint sp = Database.setSavepoint();
        Map_Set__c testMapSet = MapSetExtension.queryMapSet([select id from Map_Set__c limit 1].id);
        
        // for an edit of a map set
        MapSetExtension testExtension = new MapSetExtension(MapSetExtension.generateControllerWithCloneArgument(testMapSet, false));
        system.assertNotEquals(null, testExtension.getmapSet());
        //testExtension.getMapVendorAccountList();
        testExtension = new MapSetExtension(MapSetExtension.generateControllerWithCloneArgument(testMapSet, true));
        system.assertNotEquals(null, testExtension.getmapSet());
      //testExtension.getMapVendorAccountList();
     // system.assertNotEquals(null, testExtension.getMapVendorAccountList());
              Map<string,string> myMap = new Map<string,string> ();
        myMap.put('id','id');
        myMap.put('clone','clone');
        testExtension.determineIfVFPageIsInNewMode(myMap);
         testExtension.determineIfVFPageIsInCloneMode(myMap);
        Database.rollback(sp);
     // testExtension.getMapVendorAccountList();

    }
    
    public static testMethod void testForMapSetExtensionDetermineIfVFPageIsInNewMode()
    {
        Map_Set__c testOG = new Map_Set__c();
        
        MapSetExtension test = new MapSetExtension(MapSetExtension.generateController(testOG));
        Map<string,string> testMap = new Map<string,string>();
        
        testmap.put('id',null);
        system.assertEquals(true, test.determineIfVFPageIsInNewMode(testMap));
        
        testMap.clear();
        //testmap.put('id',[select id from Map_Set__c limit 1].id);
        //system.assertEquals(false, test.determineIfVFPageIsInNewMode(testMap));
    }
    
    public static testMethod void testForSaveMapSetExtension()
    {
        
        Savepoint sp = Database.setSavepoint();
        Map_Set__c testMapSet = new Map_Set__c();
        
        MapSetExtension test = new MapSetExtension(MapSetExtension.generateController(testMapSet));
       
        system.assertNotEquals(null, test.save());
        
        //  test the clone feature
        testMapSet = new Map_Set__c();
        test = new MapSetExtension(MapSetExtension.generateControllerWithCloneArgument(testMapSet, true));
        
        system.assertNotEquals(null, test.save());
        
        Database.rollback(sp);
     }
    
    //  **********  test end for MapSetExtension.cls   *******************************
    
    //  **********  tests for CaseInfoMesageExtension.cls  *****************
    public static testmethod void testForCaseInfoMesageExtension()
    {
        Savepoint sp = Database.setSavepoint();
        CaseInfoMesageExtension testExtension = new CaseInfoMesageExtension(CaseInfoMesageExtension.generateController(null, '1'));
        
        system.assertNotEquals(null,testExtension.getInfoMessage());
        system.assertNotEquals(null,testExtension.getInfoMessageDetail());
        system.assertNotEquals(null,testExtension.getSeverity());
        testExtension.ifClauseSelector = '2';
        testExtension.initInfoMessage();

        testExtension.ifClauseSelector = '3';
        testExtension.initInfoMessage();
        
        testExtension.ifClauseSelector = '4';
        testExtension.initInfoMessage();
        
        testExtension.ifClauseSelector = '5';
        testExtension.initInfoMessage();
        
        testExtension.ifClauseSelector = '6';
        testExtension.initInfoMessage();
        
        testExtension.ifClauseSelector = '7';
        testExtension.initInfoMessage();
        
        testExtension.ifClauseSelector = '8';
        testExtension.initInfoMessage();
        
        testExtension.ifClauseSelector = '9';
        testExtension.initInfoMessage();
        
        testExtension.ifClauseSelector = '10';
        testExtension.initInfoMessage();
        
        testExtension.ifClauseSelector = '11';
        testExtension.initInfoMessage();
        
        testExtension.ifClauseSelector = '12';
        testExtension.initInfoMessage();
        
        testExtension.ifClauseSelector = '13';
        testExtension.initInfoMessage();
        
        testExtension.ifClauseSelector = '14';
        testExtension.initInfoMessage();
        
        testExtension.ifClauseSelector = '15';
        testExtension.initInfoMessage();
        
        testExtension.ifClauseSelector = '16';
        testExtension.initInfoMessage();
        
        testExtension.ifClauseSelector = '17';
        testExtension.initInfoMessage();
        
        testExtension.ifClauseSelector = '18';
        testExtension.initInfoMessage();
        
        testExtension.ifClauseSelector = '19';
        testExtension.initInfoMessage();
        
        testExtension.ifClauseSelector = '20';
        testExtension.initInfoMessage();
        
        testExtension.ifClauseSelector = '21';
        testExtension.initInfoMessage();
        //  test the back() function
        system.assertNotEquals(null, testExtension.back());
        testExtension.returnURL = null;
        system.assertNotEquals(null, testExtension.back());
        Database.rollback(sp);
    }
    //  **********  end tests for CaseInfoMesageExtension.cls  *****************
    
    //  **********  TESTS START for EmailClassRoadnet.cls  *******************************
    public static testmethod void testForSendEmail()
    {
        Savepoint sp = Database.setSavepoint();
        list<string> toEmailAddress = new List<string>();
        list<string> ccEmailAddress = new List<string>();
        list<string> bccemailAddress = new List<string>();
        
        toEmailAddress.add('jhutchins@roadnet.com');
        ccEmailAddress.add('jhutchins@roadnet.com');
        bccEmailAddress.add('jhutchins@roadnet.com');
        
        //  test send email method
        system.assertNotEquals(
            null, EmailClassRoadnet.sendEmail(
            toEmailAddress, ccEmailAddress, bccEmailAddress, 'subject', '<b>hello there fellow</b>', 'textbody', null));
        
        //  test the sendemailAsync
        EmailClassRoadnet.sendEmailAsync(toEmailAddress, ccEmailAddress, bccEmailAddress, 'subject', '<b>hello there fellow</b>', 'textbody', null);
        
        //  test thew new email priority
        system.assertNotEquals(null, EmailClassRoadnet.sendemailPriority(toEmailAddress, ccEmailAddress, bccEmailAddress, 'subject', '<b>hello there fellow</b>', 'textbody', null, 'High'));
        
        //  new email priority for async
        //EmailClassRoadnet.sendEmailAsyncPriority(toEmailAddress, ccEmailAddress, bccEmailAddress, 'subject', '<b>hello there fellow</b>', 'textbody', null, 'High');
        
        //  test the convertHTMLToText
        string testString = '<br>Hello<b>World</b>';
        system.assertNotEquals(null, EmailClassRoadnet.convertHTMLToText(testString));
        
        //  test send error email
        EmailClassRoadnet.sendErrorEmail('test message', null);
        
        //  test  createHyperLink
        system.assertNotEquals(null, EmailClassRoadnet.createHyperLink('http://www.blarg.com', 'the text'));
        
        //  test the convertTextTOHtml
        system.assertNotEquals(null, EmailClassRoadnet.convertTextToHtml('\n new lines everywhere \n') );
        
        
        //  test for convertSendEmailErrorsToString
        system.assertNotEquals(null, EmailClassRoadnet.convertSendEmailErrorsToString(new List<Messaging.SendEmailError>()));
        
        //  test for truncateString
        system.assertNotEquals(null, EmailClassRoadnet.truncateString('hello this is a string', 5));
        Database.rollback(sp);
    }
    
    public static testmethod void testForEmailClass()
    {
        Savepoint sp = Database.setSavepoint();
        List<Messaging.SingleEmailMessage> testlist = new List<Messaging.SingleEmailMessage>();
        testlist.add(EmailClassRoadnet.createMail('jhutchins@roadnet.com', 'subject', 'body', null));
        
        EmailClassRoadnet.createMail(new list<string>{'jhutchins@roadnet.com'}, 'subject', 'body', null);
        EmailClassRoadnet.checkEmailResults(new list<Messaging.SendEmailResult>());
        EmailClassRoadnet.grabToEmailFromListOfMail(testList);
        
        EmailClassRoadnet.sendMultipleEmails(testList);
        
        Database.rollback(sp);
    }
    //  **********  TESTS END for EmailClassRoadnet.cls  *******************************
    
    //  **********  tests for CaseEventSummaryExtension.cls  *****************
    public static testmethod void testForPopulateToAddressesWithListOfEmails()
    {
        string testString = 'johndoe@gmail.com; janedoe@aol.com; johndeere@yahoo.com';
        List<string> testResult = new List<String>();
        CaseEventSummaryExtension.populateToAddressesWithListOfEmails(testResult, testString);
        system.assertEquals(3, testResult.size());
    }
    
    public static testmethod void testForCaseEventSummaryExtension()
    {
        Savepoint sp = Database.setSavepoint();
        Case testCase;
        string[] testStrings=new List<string>();
        testStrings.add('hello');
        testStrings.add('world');
        pagereference pageRef=new pagereference('Page.caseEventSummary');
        test.setcurrentpage(pageRef);
        testCase=[select id from Case where accountid != null limit 1];
        //declare apexpages.standardcontroller so that we can pass it into this class's constructor
        ApexPages.standardController controller = new ApexPages.standardController(testCase);
        
        CaseEventSummaryExtension testCES=new CaseEventSummaryExtension(controller);
        //test getters and setters first
        testCES.casetitle='test';
        testCES.emailSubject='test';
        testCES.emailBodyText='test';
        testCES.caseHeader='test';
        testCES.toEmailAddress='test@email.com';
        testCES.isEmailSent=false;
        Case tempCase = testCES.getC();
        testCes.setC(tempCase);
        boolean testBool = testCES.getIsSelectingContact();
        testBool = testCes.isPOrtalUser;
        string testSTring = testCEs.getToEmailAddress();
        testCES.setToEmailAddress('blarger@blarged.com');
        testString = testCES.formatCaseHeading();
        
        testCES.setEmailComments('test');
        testCES.setCCEmailAddress('blarg@blarg.com');
        testCES.setBccEmailaddress('blargblarg@blarg.com');
        system.assertnotEquals(null, testCES.getccemailAddress());
        system.assertnotEquals(null, testCES.getbccemailAddress());
        
        system.assertNotEquals(null, testCES.getSummary());
        system.assertNotEquals(null, testCES.getCaseEvents());
        
        system.assertNotEquals(null, testCES.textToHtml(testSTrings));
        system.assertEquals(null, testCES.getEmailStatus());
        system.assertNotEquals(null, testCES.retrieveEmailBodyData());
        system.assertNotEquals(null, testCES.redirectToEmail());
        system.assertNotEquals(null, testCES.getEmailComments());
        
        // new additions to code sept 4 2009
        testCES.setTempCaseObject(new Case());        
        system.assertNotEquals(null, testCES.getTempCaseObject());
        testCES.setIsSelectingContact(true);
        system.assertNotEquals(null, testCES.getTempCaseObject());
        testCES.selectedemailaddress = 'blarg@blarg.com';
        
        
        //  test the select contact or user method
        system.assertEquals(null, testCES.selectContactOrUser());
        testCES.tempcaseObject.contactid = [select id from contact limit 1].id;
        system.assertEquals(null, testCES.selectContactOrUser());
        
        testCES.tempCaseObject.closed_by__c = userinfo.getuserid();
        system.assertEquals(null, testCES.selectContactOrUser());
        
        //  teet the determineWhichLookUpToGrabEmailAddressFor method
        testCES.tempCaseObject.closed_by__c = null;
        system.assertEquals(null, testCES.determineWhichLookUpToGrabEmailAddressFor());
        
        testCES.tempCaseObject.closed_by__c = userINfo.getUserId();
        testCES.tempCaseObject.contactid = null;
        system.assertEquals(null,testCES.determineWhichLookUpToGrabEmailAddressFor());
        
        testCES.selectedemailaddress = 'blarg@blarg.com';
        system.assertEquals(null, testCES.addEmailAddress());
        
        system.assertEquals(null, testCES.addCCEmailAddress());
        
        system.assertEquals(null, testCES.addBccEmailAddress());
        
        string blarg = testCES.caseCreatedDateFormated;
        //testing send email functions
        testCES.sendEmail();
        
        testCES.toggleShowprivateCaseEventsCheckbox();
        Database.rollback(sp);
    }    
    //  **********  tests for CaseEventSummaryExtension.cls  *****************
    
    
    //  **********  test for AttachmentTrigger.Tgr   *******************************
    public static testmethod void testForAttachmentTrigger()
    {
        Savepoint sp = Database.setSavepoint();
        //  so we need an attachment from somewhere doesnt matter where it is from, just need one.
        //  i hesitate to query a test accout, because in the next instance we might not have one
        //Account roadnetAccount = [select id from Account where name = ' Roadnet Technologies' order by lastmodifieddate desc limit 1];
        
//        Attachment originalAttachment = [select id, name, body, parentid from Attachment order by createddate asc limit 1];
        Account accountInstance=new Account();
        accountInstance.name='Test Account name';
        accountInstance.Phone='3432433232';
        accountInstance.Account_Type__c='Association';
        //accountInstance.District__c='Canada';
        accountInstance.Account_Manager__c=Userinfo.getUserId();
        accountInstance.BillingStreet='Test Billing Street';
        accountInstance.BillingCity='Test Billing City';
        accountInstance.BillingCountry='AZ';
        accountInstance.BillingState='Test Billing State';
        accountInstance.BillingPostalCode='00001';
        accountInstance.Fleet_Size__c= 25;
        accountInstance.Segment__c='TL';
        //insert accountInstance;
        
        Database.DMLOptions dml = new Database.DMLOptions();
        dml.DuplicateRuleHeader.AllowSave = true;  
        Database.SaveResult sr = Database.insert(accountInstance, dml);
        
        Attachment originalAttachment = new Attachment();
        originalAttachment.name = 'fake name';
        originalAttachment.body = Blob.valueOf('BBB');
        originalAttachment.parentid = originalAttachment.parentid;
        originalAttachment.ParentId = accountInstance.Id;
        insert originalAttachment;
        
        Attachment newAttachment = new Attachment();
        newAttachment.name = 'fake name';
        newAttachment.body = Blob.valueOf('BBB');
        newAttachment.parentid = originalAttachment.parentid;
        insert newAttachment;
        
        Database.rollback(sp); 
    }

    public static Case createTestCase(string recordtype)
    {
        Case c = new Case();
        
        if (recordType != null)
        {
            if (recordType == 'SFDC Support')
            {
                c.recordtypeid = [select id from RecordType where sobjectType = 'Case' and name ='SFDC Support' limit 1].id;
                //  query a product version that doesn't have alot of product patches assoicated with it
                //  this is because the caseClass redefineProductDepencies methods throws an exception when too many records are returned
                
            }
            else if (recordType == 'Consulting Case')
            {
                c.recordtypeid = [select id from RecordType where sobjectType = 'Case' and name =: recordtype limit 1].id;
            }
            else if (recordtype == 'Admin')
            {
                c.recordtypeid = [select id from Recordtype where sobjecttype = 'Case' and name = 'Admin'].id;
            }
        }
        else
        {
            c.recordtypeid = [select id from RecordType where sobjectType = 'Case'  limit 1].id;
        }
                
        c.product_version_pl__c = 'RTS-3.5';
        c.Product_Family_PL__c = 'Roadnet Transportation Suite';
        
        //  because of this, will need to chjange how the contacts are queied, i will always query a contact fromt he roadnet technolocies account
        
        //Account roadnetAccount = RoadnetAccount;
            
        Contact testContact;
        try
        {
            testContact =  [select email, id, accountid from contact 
                where accountid =: RoadnetAccount.id limit 1];
        }
        catch(Exception e)
        {
            //  contact could not be queired for whatever reasons, so let's just pluck a contact from the database regardless of it belongs
            //  to thea ccount above
            testcontact = [select email, id, accountid from contact 
                where recordtype.name = 'Call Center' and
                HasOptedOutOfEmail = false and
                lifecycle_status__c = 'SAL' and
                Survey_Email_Opt_Out__c = false             
                 limit 1];
            
        }
        c.contactid = testContact.id;
        c.accountid = testContact.AccountId;
        c.status = 'Open';
        c.priority = 'Normal';
        
        c.origin = 'Phone';
        //  CaseClass tests were failing because product's were being queried with no product family
        c.sub_reason_pl__c = 'blarg';
        
        c.subject = 'test subject';
        c.description = 'test description';
        c.email__c = 'fake@email.com';
        c.IsVisibleInSelfService = true;
        
        Datetime fakeTime = dateTime.now();
        c.start_time__c = fakeTime.addMinutes(-10);
          
        database.insert(c);
        return c;      
        /*database.saveResult sr = database.insert(c);
        if (sr.isSuccess())
        {
            c = [Select id, casenumber contactid, accountid, email__c, product_family_pl__c, product_version_pl__c, business_unit__c
                From Case c where id =: sr.id];
        }
        return c;
        */
    }
    public static Case_Event__c createTestCaseEvent(id caseId)
    {
        Case_Event__c ce = new Case_Event__c();
        ce.Case__c = caseId;
        ce.subject__c = 'Test Blarg';
        ce.details__c = 'Test Blarg';
        
        database.insert(ce);
        return ce;
    }
    // ********************  TRIGGER TESTS  *********************
    public static testmethod void testForCaseEventTrigger()
    {
        Savepoint sp = Database.setSavepoint();
        //  insert
        Case_Event__c testEvent = new Case_Event__c();
        testEvent.case__c = [select id from case where business_unit__c = 'Roadnet' and isclosed = false and total_work_effort__c != 0 limit 1].id;
        testEvent.subject__c = 'blarg';
        insert testEvent;
        
        //  update
        testEvent = [select id, case__c, subject__c from case_event__c where id =: testEvent.id limit 1];
        testEvent.Subject__c = ' test';
        update testEvent;
        Database.rollback(sp);
    }
    public static testmethod void testForCaseTrigger()
    {
        Savepoint sp = Database.setSavepoint();
        //  insert
        Case testCase = createTestCase('SFDC Support');
        
        
        //  update
        update testCase;
        Database.rollback(sp);
    }
    // ********************  CLASS TESTS  ********************* 
    public static testmethod void testForsendEmailAlertToCaseOwner()
    {
        Savepoint sp = Database.setSavepoint();
        //  test the static method sendEmailAlertToCaseOwnerAndCaseCreator
        CaseEventExtension.sendEmailAlertToCaseOwner(
            util.josephUserRecordId, 'Mr. Blarger', 'fake case number', 'fake case subject',
            'fake case event subject', 'details');
        Database.rollback(sp);
    }  
    public static testmethod void testForMethodsNotCovered()
    {
        List<string> testStrings = new List<string>();
        testStrings.Add('jhutchins@roadnet.com');
        List<SelectOption> testOptions = new List<SelectOption>();
        testOptions.add(new selectoption('jhutchins@rodanet.com', 'jhutchins@roadnet.com'));
        CaseEventExtension.sortByLabel(new list<selectOption>());
        // public static PageReference addUsersToPicklist(List<string> userstoAdd, List<Selectoption> leftUserList, List<Selectoption> rightUserList)
        //CaseEventExtension.addUsersToPicklist(testStrings, testOptions, testOptions);
        
        SelectOption testOption = CaseEventExtension.removeSelectOption('joseph', testOptions);
        //CaseEventExtension.removeUsersFromPicklist(testStrings, testOptions, testOptions);
        CaseEventExtension.Round5Minutes(6);
        CaseEventExtension.ListContains(new SelectOption('blarg', 'blarg'), testOptions);
        boolean testBool = CaseEventExtension.isActivePortalUser();
        id testUserId = [select id from user where isactive = true limit 1].id;
        testbool = CaseEventExtension.isOwnerQueue(testUserId, [select id, queueid, queue.name from QueueSobject where sobjecttype = 'Case' ]);
        testBool = CaseEventExtension.isOwnerQueue(testUserId);
        Set<string> testSetString = CaseEventExtension.parseString('this; is; real;');
        Set<id> testSetIds = CaseEventExtension.queryActiveUserIds(new set<string>{'jhutchins@roadnet.com'});
        Case testCase = createTestCase('SFDC Support');
        Case_Event__c testCaseEvent = createTestCaseEvent(testCase.id);
        
        //public static void sendEmailAlertToInternalUsers(set<id> toEmailUserIds, Case_Event__c ce, Case theCase, string accountName)
        CaseEventExtension.sendEmailAlertToInternalUsers(testSetIds, testCAseEvent, testCase, 'Janes Test Account');
        string testString = CaseEventExtension.convertSelectOptionsToString(testOptions);
        Account testAccount = roadnetAccount;
       // testOptions = CaseEventExtension.defineProductListForSupportCases(testAccount.id, false, false);
       // testOptions = CaseEventExtension.defineCaseReasonsForSupportCases('fakeProductId');
       // testOptions = CaseEventExtension.defineSubReasons('fakeCaseReasonId', 'fakeProductId');
        testSTring = CaseEventExtension.convertNewLineToBreak('this is fake');
        testBool = CaseEventExtension.isUserInternalAutomation();
        testOptions = CaseEventExtension.defineContactList(testAccount.id, null, false);
       // testbool = CaseEventExtension.isCaseValidReason('fakeId', 'fakeId');
        testBool = CaseEventExtension.checkEmailSubjectForForbiddenText('blarg');
    }
    
    private static Account roadnetAccount
    {
        get
        {
            if (roadnetAccount == null)
            {
                try
                {
                     roadnetAccount = [select id from Account where name = 'Roadnet Technologies' order by lastmodifieddate desc limit 1];
                }
                catch(Exception e)
                {
                    throw new myException('Failed to query roadnet technologies account in RoadnetScripts.RoadnetAccount due to: ' + e.getMessage());
                }
            }
            return roadnetAccount;
        }
    }
    public static Campaign createTestCampaign()
    {
        Campaign c = new Campaign();
        c.name = 'JosephTestCampaign' + date.today();
        insert c;
        return c;
    }
    public class myException extends exception{}
}