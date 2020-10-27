@isTest(seeAllData=true)
private class RoadnetGenericClass_Test{

    /*********** Test method for SelectOptionManagerForStreetArea.cls*********/ 
    public static testmethod void SelectOptionManagerForStreetArea_Test(){    
        list<String> lststring =  new list<String>();
        list<selectoption> lstselectoption =  new list<selectoption>();
        String str = 'test';
        lststring.add('test');
        lststring.add('test1');
    
        lstselectoption.add(new SelectOption('US','US'));
        lstselectoption.add(new SelectOption('test','test'));
        lstselectoption.add(new SelectOption('test1','test1'));
    
        SelectOptionManagerForStreetArea StreetArea = new SelectOptionManagerForStreetArea();
    
        StreetArea.getSourceList();
        StreetArea.getSelectedItemsList();
        StreetArea.getTheFinalProduct();
        StreetArea.setUserSelectedItemsToAdd(lststring);
        StreetArea.setNewSourceList(lstselectoption);
        StreetArea.getUserSelectedItemsToAdd();
        StreetArea.getuserSelectedItemsToRemove();
        StreetArea.setUserSelectedItemsToRemove(lststring);
        StreetArea.addItemsToList();
        StreetArea.removeItemsFromList();
        StreetArea.cancelSelections();
        StreetArea.isitDupe(str ,lstselectoption);
        SelectOptionManagerForStreetArea StreetArea1 = new SelectOptionManagerForStreetArea(lstselectoption ,str);
        SelectOptionManagerForStreetArea StreetArea2 = new SelectOptionManagerForStreetArea(lstselectoption);
        StreetArea.clearAll();    
    }
    
    /*********** Test method for RnaApexEmailerController.cls*********/ 
      public static testmethod void RnaApexEmailerController_Test ()
    {
        Savepoint sp = Database.setSavepoint();
        
        Account acc = new Account();
        acc.name = 'Test Account';
        acc.Account_Status__c = 'Active';
        insert acc;
        
        Contact con = new contact();
        con.email = 'test@test.com';
        con.hasOptedOutOfEmail = false;
        con.accountid = acc.id;
        con.inactive__c = false;
        con.Is_RNA_Apex_Contact__c = true ;
        con.LastName = 'Test Contact';
        insert con;
    
        EmailTemplate validEmailTemplate = new EmailTemplate();
       System.runAs(new User(Id = UserInfo.getUserId()))    
       {   

        validEmailTemplate.isActive = true;
        validEmailTemplate.Name = 'RNA Planned Outage';
        validEmailTemplate.DeveloperName = 'RNA_Planned_Outage_test';
        validEmailTemplate.TemplateType = 'text';
        validEmailTemplate.FolderId = UserInfo.getUserId();
    
        insert validEmailTemplate;
        }
       RnaApexEmailerController testController = new RnaApexEmailerController();
       List<Contact> testContacts = testController.rnaApexContacts;
       List<SelectOption> testOptions = testController.emailTemplateFolders;
       boolean testBool = testController.didAnyEmailFailSending;
       map<string, string> testStringMap = testController.urlParamMap;
       String str =  testController.detailedHelpText;
       Id idval = testController.roadnetCustomerServiceOrgWideEmail;
       String strval =  testController.plannedEmailTemplatePageMessageDetail;
       Id idvalue = testController.plannedOuttageEmailTemplateId;
       List<SelectOption> testpicklistOptions = testController.emailTemplatePicklist;
       testController.testContactLookupOnChange();
       testController.caseEventContactLookupOnly.Contact__c = con.id;
       testController.isTestMode = true;
       testController.isContactValidForTestEmail(con);
       testController.emailTemplatePicklistOnChange();
       testController.emailTemplateUserSelection = validEmailTemplate.name;
       testController.sendEmails();
       testController.refreshPage();
       testController.cancel();
       RnaApexEmailerController.EmailFailure tempEmailFailure = new RnaApexEmailerController.EmailFailure('blarg', 'blarg', 'blarg', 'blarg');
       testController.isTestMode = false;
       testController.sendEmails();
       Database.rollback(sp);
    }
    
   /**********  Test method for StreetAreaExtension.cls*****************/
    public static testmethod void StreetAreaExtension_Test()
    {
        Savepoint sp = Database.setSavepoint();
                
         Map_nation__c  nation =  new  Map_nation__c();
         nation.name  ='United States';
         insert nation;                      

         Account a = new Account();
         a.name = 'testAcc';
         insert a;
         
         map_set__c mpset = new map_set__c();         
         mpset.Account__c = a.id;
         mpset.Comments__c = 'test';
         insert mpset; 
                            
         Map_State__c mstate =  new Map_State__c();
         mstate.name = 'testmap';
         mstate.nation__c = nation.id;
         insert mstate;

         Map_County__c mpcountry = new Map_County__c();
         mpcountry.name  = 'testcountry';
         mpcountry.state__c = mstate.id;     
         insert mpcountry;
         
         Street_Area__c obj = new Street_Area__c();
         obj.isMapStateSpecified__c = true;
         obj.isMapCountySpecified__c =true;
         obj.Map_Nation__c = nation.id;
         obj.map_state__c = mstate.id;
         obj.map_set__c = mpset.id;
         insert obj;
         
        list<selectoption> lstselectoption =  new list<selectoption>();
        lstselectoption.add(new SelectOption('CA','CA'));
               
              
        ApexPages.StandardController sc = new ApexPages.StandardController(obj);
        StreetAreaExtension testExtension = new StreetAreaExtension(sc);
        SelectOptionManagerForStreetArea optionmanager = new SelectOptionManagerForStreetArea();
        testExtension.getStateObject();
        testExtension.setStateObject(optionmanager);
        testExtension.setCountyObject(optionmanager);
        testExtension.getCountyObject();
        Street_Area__c street = testExtension.getStreetArea();        
        testExtension.setStreetArea(obj);
        testExtension.isVFPageInCloneMode = true; 
        testExtension.isSelectingMultipleStates = true;   
        Boolean val = testExtension.getdisplayItemInStatePickListOnlyOnce();
        Boolean val1 = testExtension.getdisplayItemInCountyPickListOnlyOnce();
        Boolean val2 = testExtension.getIsVFPageInNewMode();
        testExtension.redirectToNewOrEditPage();
        testExtension.didIsMapStateSpecifiedFieldOnChange();
        testExtension.didIsSelectingMultipleStatesFieldOnChange();
        testExtension.didIsMapCountySpecifiedFieldOnChange();
        List<selectOption> lstopt = testExtension.getNationList();
        List<selectOption> lstopt1 = testExtension.getStateList();
        List<selectOption> lstopt2 = testExtension.getCountyList();
        testExtension.save();
        testExtension.goThruEachCaseToTryANewSave();
        testExtension.initIfPageIsInEditMode();
        testExtension.initIfPageInCloneMode();
        StreetAreaExtension.OnChangeClass innercls= new StreetAreaExtension.OnChangeClass();
        StreetAreaExtension.OnChangeClass innercls1= new StreetAreaExtension.OnChangeClass(true);
        innercls.setNewValue(true);       
        Map_State__c mps =  StreetAreaExtension.createTestMapState();
        Map_county__c mpc =  StreetAreaExtension.createTestMapCounty();
        Map_Nation__c mpn =  StreetAreaExtension.createTestMapNation();
        Street_Area__c mpas = StreetAreaExtension.createTestStreetArea() ;
        StreetAreaExtension.generateController(obj);
        Street_Area__c sta= StreetAreaExtension.createTestStreetArea('test');

        Database.rollback(sp);
    }        
     
   /**********  Test method for PL.cls*****************/
    public static testmethod void PL_Test()
    {    
    PL plobj = new PL();
    string st = plobj.selection;
    List<string> lststr = plobj.selections;
    List<SelectOption> lstop = plobj.options;
    plobj.addNoneOption();
    String s = plobj.firstOptionValue;
    plobj.defaultSelection();
    plobj.defaultNonNoneValue();
    plobj.addNoneOption();
    plobj.defaultNonNoneValue();
    SelectOption ss = PL.noneOption;
    }
    
    public static testmethod void PLNull_Test()
    {    
    PL plobj = new PL();
    string st = plobj.selection;
    String s = plobj.firstOptionValue;
    plobj.defaultSelection();
    plobj.defaultNonNoneValue();
    }
     /**********  Test method for NewCaseRedirect_Ctrl.cls*****************/
    public static testmethod void NewCaseRedirect_Ctrl_Test()
    {  
    Case c = new case();
    insert c ;
    Account a = new Account();
    a.Name = 'testname';
    insert a;
    PageReference pg = Page.case; 
    Test.setCurrentPage(pg);        
    ApexPages.currentPage().getParameters().put('id', c.Id); 
    ApexPages.currentPage().getParameters().put('retURL', 'testretURL');
    ApexPages.currentPage().getParameters().put('def_parent_id', 'testid');
    ApexPages.currentPage().getParameters().put('cas4_lkid', a.id);
    ApexPages.currentPage().getParameters().put('cas3_lkid', c.id);
    ApexPages.currentPage().getParameters().put('def_account_id',a.id);
    ApexPages.currentPage().getParameters().put('def_contact_id', 'testid');
    ApexPages.StandardController sc = new ApexPages.StandardController(c);
    NewCaseRedirect_Ctrl ctrl = new NewCaseRedirect_Ctrl(sc);
    ctrl.isPortal = true;
    ctrl.doRedirect();
    }
    
    //  **********  test data for SalesSupportSingleProcessing.tgr  *****************
    private static User createTestUser()
    {
        User testUser = new User();
        testUser.Username= 'test.user@roadnet.com';
        testUser.Email = 'test.user@roadnet.com';
        testUser.Lastname = 'User';
        testUser.Firstname = 'Test';
        testUser.Alias = 'tuser';
        testUser.UserRole = [ select id from userrole where Name ='QES Executives' ];
        Profile testProfile=[ select id from profile where Name = 'System Administrator' ];
        testUser.ProfileId= testProfile.id;
        testUser.TimeZoneSidKey = 'GMT';
        testUser.LocaleSidKey = 'en_US';
        testUser.EmailEncodingKey = 'ISO-8859-1';
        testUser.LanguageLocaleKey = 'en_US';
        insert testUser;
        
        return testUser;
    }
    //  **********  test data for SalesSupportSingleProcessing.tgr  *****************
    private static Account createTestAccount()
    {
        Account testAccount = new Account();         
        testAccount.Name = 'Arindam Test Account';
        //testAccount.recordTypeId = AccountRecordTypes__c.getInstance('CNR_SALES_ACCOUNT_RECORD_TYPE_ID').RecordTypeID__c;
        testAccount.Phone = '0123456789';
        testAccount.Account_Status__c = 'Active';
        testAccount.Primary_Business_Unit__c = 'Omnitracs Domestic';
        testAccount.BillingCountry = 'India';
        testAccount.Account_Classification__c = 'Prospect';          
        insert testAccount;
        
        return testAccount;
    }
    //  **********  test data for SalesSupportSingleProcessing.tgr  *****************
    private static Contact createTestContact(Account testAccount)
    {
        Contact objContact = new Contact();
        objContact.AccountId=testAccount.id;
        //objContact.RecordTypeId=Schema.Sobjecttype.Contact.getRecordTypeInfosByName().get('Sales').getRecordTypeId();
        objContact.LastName='User';
        objContact.FirstName='Test';
        objContact.Title='Test Title';
        objContact.Phone='(123) 465-1789';
        objContact.email='test.contact@roadnet.com';
        insert objContact;
        
        return objContact;
    }
    //  **********  test data for SalesSupportSingleProcessing.tgr  *****************
    private static Opportunity createTestOpportunity(Account testAccount)
    {
        Opportunity objOpportunity = new Opportunity();        
        objOpportunity.Name = 'Test Opportunity';
        objOpportunity.AccountId = testAccount.id;
        //objOpportunity.RecordTypeId = Schema.Sobjecttype.Opportunity.getRecordTypeInfosByName().get('Products, Services and Maintenance').getRecordTypeId();
        objOpportunity.StageName = 'Closed Won';
        Date myDate = date.valueOf('2016-04-29');
        objOpportunity.CloseDate = myDate;
        insert objOpportunity;
        
        return objOpportunity;
    }        
    //  **********  tests for SalesSupportSingleProcessing.tgr  *****************
    @isTest(seeAllData=true)
    private static void testForSalesSupportSingleProcessingTrigger()
    {
        Savepoint sp = Database.setSavePoint();
        
        User testUser = createTestUser(); 
        Account testAccount = createTestAccount();
        Contact objContact = createTestContact(testAccount);
        Opportunity objOpportunity = createTestOpportunity(testAccount);
              
        //  test insertion and update
        Sales_Support__c testSalesSupport = new Sales_Support__c();
        testSalesSupport.RecordTypeId = Schema.Sobjecttype.Sales_Support__c.getRecordTypeInfosByName().get('Demo').getRecordTypeId();
        testSalesSupport.SE_User__c = testUser.id;       
        testSalesSupport.Opportunity__c = objOpportunity.id;
        testSalesSupport.PS_Resources__c = 'test, user1';
        insert testSalesSupport;
        
        testSalesSupport.SE_User__c = null;
        update testSalesSupport;
        Database.rollback(sp);
    }         
}