@isTest(seeAllData = true)
private class GenericClass_Test
{   
    private static VistaAssetHelperUtil util = new VistaAssetHelperUtil();
    ///////////////////// test data preparation //////////////////////
    static Account createAccount(String acctName)
    {
        Account testAccount = util.createAccount(acctName);             
        return testAccount;
    }
    static Contact createContact(Account testAccount)
    {
        Contact testContact = new Contact();
        testContact.AccountID = testAccount.id;
        testContact.LastName = 'name';
        testContact.FirstName = 'test';
        testContact.email = 'test@test.com';
        testContact.Notification_Type__c = 'Price Increase';
        insert testContact;
        
        return testContact;
    }
    static Case createCase(Account testAccount, Contact testContact)
    {
        Case testcase = new Case();
        testcase.subject = 'Test Case Subject';
        testcase.status = 'Open';
        testcase.accountid = testAccount.id;
        testcase.contactid = testContact.id;
        insert testcase;
        
        return testcase;
    }
    Static Country_And_Country_Code__c createCountryAndCountryCode()
    {  
        Country_And_Country_Code__c tstCountryAndCountryCode = new Country_And_Country_Code__c();
        tstCountryAndCountryCode.Name = 'India';
        tstCountryAndCountryCode.CurrencyIsoCode = 'USD';
        insert tstCountryAndCountryCode;
        
        return tstCountryAndCountryCode;
    }
    ///////////////////// test data preparation end ///////////////////////
    @isTest(seeAllData=true)
    static void VCG_CPQ_ObjectManagement_Test()
    {
        VCG_CPQ_ObjectManagementController objVCG_CPQ_ObjectManagementController = new VCG_CPQ_ObjectManagementController();
        objVCG_CPQ_ObjectManagementController.getSecurityRestrictionUrl();
        objVCG_CPQ_ObjectManagementController.getPricingAccessSequenceUrl();
        objVCG_CPQ_ObjectManagementController.getPricingProcedureUrl();
        objVCG_CPQ_ObjectManagementController.getPricingConditionUrl();
        objVCG_CPQ_ObjectManagementController.getPricingConditionDataUrl();
        objVCG_CPQ_ObjectManagementController.getApprovalConditionsUrl();
        objVCG_CPQ_ObjectManagementController.getApprovalGroupMatricesUrl();
        objVCG_CPQ_ObjectManagementController.getApprovalGroupsUrl();
        objVCG_CPQ_ObjectManagementController.getBundlesUrl();
        objVCG_CPQ_ObjectManagementController.getOpportunityQuoteMapsUrl();
        objVCG_CPQ_ObjectManagementController.getQuoteToOppMapsUrl();
        objVCG_CPQ_ObjectManagementController.getQLItoOLIMapsUrl();
        objVCG_CPQ_ObjectManagementController.getPricingProcedureSequencesUrl();
        objVCG_CPQ_ObjectManagementController.getPricingSequenceConditionUrl();
        objVCG_CPQ_ObjectManagementController.getProductAddonsUrl();
        objVCG_CPQ_ObjectManagementController.getProductEquivalencyUrl();
        objVCG_CPQ_ObjectManagementController.getProductFilterUrl();
        objVCG_CPQ_ObjectManagementController.getProductIncompatibilitiesUrl();
        objVCG_CPQ_ObjectManagementController.getProductRulesUrl();
        objVCG_CPQ_ObjectManagementController.getQuoteProductPricingResultsUrl();
        objVCG_CPQ_ObjectManagementController.getUserHierarchyUrl();
        objVCG_CPQ_ObjectManagementController.getFieldLayoutsUrl();
        
    }
    
    @isTest(seeAllData=true)
    static void VCG_CPQ_Approval_Email_Controller_Test()
    {
        VCG_CPQ_Approval_Email_Controller objVCG_CPQ_Approval_Email_Controller = new VCG_CPQ_Approval_Email_Controller();
        objVCG_CPQ_Approval_Email_Controller.getQuoteApprovals();
    
    }
    
    @isTest(seeAllData=true)
    static void serviceAgreementAdjustmentNotification_Test()
    {
        Account a = util.createAccount('serviceAgreementAdjustmentNotification_Test');
        
        Contact c = new Contact();
        c.AccountID = a.id;
        c.LastName = 'testname';
        c.Salutation = 'Mr';
        c.FirstName = 'testFirstName';
        c.Notification_Type__c = 'Price Increase';
        insert c;
    
        Address__c address = new Address__c();
        address.Address_Line_1__c = 'scotland';
        address.Account__c = a.Id;
        address.Address_Line_2__c = 'Perth';
        address.City__c = 'Clifornia';
        address.State_Province__c = 'Arizona';
        address.Zip_Postal_Code__c = 'NH1 PQ';
        address.Location_Type__c = 'Corporate HQ';  
        insert address;
        
        
        Contract cntrct = new Contract();
        cntrct.AccountId = a.id;
        cntrct.StartDate = date.today();
        cntrct.Term_type__c = 'Fixed';
        cntrct.Agreement_type__c = 'Individual';
        cntrct.Contract_Type__c = 'Customer';
        cntrct.Affiliate_Language__c = 'Yes';                                                 
        cntrct.Legal_Entity_Name__c ='Omnitracs, LLC';
        insert cntrct;
    
        Service_Agreement_Adjustment__c s = new Service_Agreement_Adjustment__c();
        s.Reason__c = 'test';
        s.Contact__c = c.Id;
        s.Contract__c = cntrct.id;
        insert s;
        
        
        List<Service_Agreement_Adjustment__c> l = [select Contact_Address_1__c,account_Id__c from Service_Agreement_Adjustment__c Where id =: s.id];
        l[0].Contact_Address_1__c ='testing';
        update l;
        
        l =  [select Contact_Address_1__c,account_Id__c from Service_Agreement_Adjustment__c where id =: s.id];
        System.debug('size ***'+l.size());
        System.debug('accunt id  ***'+l[0].account_Id__c);
        
        ServiceAgreementAdjustmentNotification.sendEmail(l);
    
    }
    
    @isTest(seeAllData=true)
    static void serviceAgreementAdjustmentNotification_Test1()
    {
        Account a = util.createAccount('serviceAgreementAdjustmentNotification_Test1');
        
        Contact c = new Contact();
        c.AccountID = a.id;
        c.LastName = 'testname';
        c.Salutation = 'Mr';
        c.FirstName = 'testFirstName';
        c.Notification_Type__c = 'Price Increase';
        insert c;
    
        Address__c address = new Address__c();
        address.Address_Line_1__c = '';
        address.Account__c = a.Id;
        address.Address_Line_2__c = '';
        address.City__c = 'Clifornia';
        address.State_Province__c = 'Arizona';
        address.Zip_Postal_Code__c = 'NH1 PQ';
        address.Location_Type__c = 'Corporate HQ';  
        insert address;
    
    
        Contract cntrct = new Contract();
        cntrct.AccountId = a.id;
        cntrct.StartDate = date.today();
        cntrct.Term_type__c = 'Fixed';
        cntrct.Agreement_type__c = 'Individual';
        cntrct.Contract_Type__c = 'Customer';
        cntrct.Affiliate_Language__c = 'Yes';                                                 
        cntrct.Legal_Entity_Name__c ='Omnitracs, LLC';
        insert cntrct;
        
        Service_Agreement_Adjustment__c s = new Service_Agreement_Adjustment__c();
        s.Reason__c = 'test';
        s.Contact__c = c.Id;
        s.Contract__c = cntrct.id;
        insert s;
        
        List<Service_Agreement_Adjustment__c> l = [select Contact_Address_1__c,account_Id__c from Service_Agreement_Adjustment__c Where id =: s.id];
        l[0].Contact_Address_1__c ='testing';
        update l;
        
        l =  [select Contact_Address_1__c,account_Id__c from Service_Agreement_Adjustment__c where id =: s.id];
        System.debug('size ***'+l.size());
        System.debug('accunt id  ***'+l[0].account_Id__c);
        
        ServiceAgreementAdjustmentNotification.sendEmail(l);
    
    }
    
    @isTest(seeAllData=true)
    static void ShowAllActivitiesControllerr_Test()
    {        
        Pagereference ref = Page.ShowAllActivities;
        Test.setCurrentPageReference(ref);
        Account testAccount = util.createAccount('ShowAllActivitiesControllerr_Test');
        testAccount.recordTypeId = AccountRecordTypes__c.getInstance('TL_SALES_ACCOUNT_RECORD_TYPE_ID').RecordTypeID__c;
        update testAccount;
    
        System.currentPageReference().getParameters().put('id', testAccount.Id); 
        System.currentPageReference().getParameters().put('type', 'AH'); 
        ShowAllActivitiesControllerr showAllActivitiesControllerr = new ShowAllActivitiesControllerr();
        
        System.currentPageReference().getParameters().put('id', testAccount.Id);
        System.currentPageReference().getParameters().put('type', 'OA'); 
        ShowAllActivitiesControllerr showAllActivitiesControllerr1 = new ShowAllActivitiesControllerr();
        
        Country_And_Country_Code__c tstCountryCode = createCountryAndCountryCode();
        Lead objLead = new Lead();
        objLead.FirstName='Fname';
        objLead.LastName ='Lname';
        objLead.Phone='(080) 112-213';
        objLead.Company='TestCompany';
        objLead.Country=tstCountryCode.Name;
        
        insert objLead;
    
        System.currentPageReference().getParameters().put('id', objLead.Id);         
        System.currentPageReference().getParameters().put('type', 'AH'); 
        ShowAllActivitiesControllerr showAllActivitiesControllerr2 = new ShowAllActivitiesControllerr();        
        showAllActivitiesControllerr2.selectedLead = objLead;
        
        System.currentPageReference().getParameters().put('id', objLead.Id);
        System.currentPageReference().getParameters().put('type', 'OA'); 
        ShowAllActivitiesControllerr showAllActivitiesControllerr3 = new ShowAllActivitiesControllerr();
        showAllActivitiesControllerr3.selectedLead = objLead;
    
    }
    
    static testMethod void ScheduleCaseMetricCreate_Test()
    {
        String CRON_EXP = '0 0 0 3 9 ? 2032';
        String jobId = System.schedule('BasicScheduledApexTest',CRON_EXP,new ScheduleCaseMetricCreate());
    }
    
    static testMethod void ScheduleBatchAccountUpdate_Test()
    {
        String CRON_EXP = '0 0 0 3 9 ? 2032';
        String jobId = System.schedule('BasicScheduledApexTest',CRON_EXP,new ScheduleBatchAccountUpdate());
    }
    
   /* @isTest(seeAllData=true)
    static void RFP_AJAXInterface_Test()
    {     
        PorterStemmer.testPorterStemmer();
        RFP_AJAXInterface i = new RFP_AJAXInterface();
        
        RFP__c rfpObj = new RFP__c();
        rfpObj.Name ='testRFP';
        rfpObj.Due_Date__c=Date.today();
        insert rfpObj;
        
        Response__c resObj = new Response__c();
        resObj.Response_Text__c ='testresp';
        resObj.Name ='TestResponse1';
        resObj.Status__c ='Draft';
        insert resObj;
        
        Response__c resObj1 = new Response__c();
        resObj1.Response_Text__c ='testresp';
        resObj1.Name ='TestResponse1';
        resObj1.Status__c ='Draft';
        insert resObj1;
    
        ApexPages.currentPage().getParameters().put('id', resObj.Id);    
        i.getResponseText();
        
        RFP_AJAXInterface.Response responseObj = new RFP_AJAXInterface.Response();  
        responseObj.Id ='123';
        responseObj.Hits= 10;
        responseObj.Status ='Active';
        responseObj.Summary ='testing';
        
        RFP_AJAXInterface.RFP_Document rfpDocument =  new RFP_AJAXInterface.RFP_Document();
        
        rfpDocument.Id ='345';
        rfpDocument.Name ='test';
        
        i.SelectedRFP = 'sampleselection';
        i.Question ='sampleQuestion';
        i.deleteStopWords();
    
        PageReference pg = Page.RFP_GetResponses; 
        Test.setCurrentPage(pg); 
        
        Question__c u = new Question__c();
        u.Question__c = 'Test Question';
        u.Original_Response__c = false;
        u.Response__c = resObj.Id;
        u.RFP__c = rfpObj.id;
        
        insert u;
    
        String[] fixedSearchResults = new String[]{u.Id, u.Id};
        Test.setFixedSearchResults(fixedSearchResults);
        
        ApexPages.currentPage().getParameters().put('question', 'What are your competitive differentiators?');    
        RFP_AJAXInterface.Response[]  r = i.getResponses();
        
        fixedSearchResults = new String[]{resObj1.id, resObj.Id };
        Test.setFixedSearchResults(fixedSearchResults);
        
        ApexPages.currentPage().getParameters().put('search', 'responses');    
        r = i.getResponses();  
        
        RFP_AJAXInterface i1 = new RFP_AJAXInterface();
        
        fixedSearchResults = new String[]{u.Id, u.Id };
        Test.setFixedSearchResults(fixedSearchResults);
        
        ApexPages.currentPage().getParameters().put('question', 'What are your competitive differentiators?');    
        RFP_AJAXInterface.Response[]  r1 = i1.getResponses();
        
        fixedSearchResults = new String[]{resObj1.id, resObj.Id };
        Test.setFixedSearchResults(fixedSearchResults);
        
        ApexPages.currentPage().getParameters().put('search', 'Questions');    
        r1 = i1.getResponses();  
        
        Integer result = RFP_AJAXInterface.getStopWordCount();
    
    }*/
    
    @isTest(seeAllData=true)
    static void RemainingCharactersComponentController_Test()
    {
        RemainingCharactersComponentController tstRemainingCharactersComponentController = new RemainingCharactersComponentController();
        String inputTextArea = tstRemainingCharactersComponentController.inputTextAreaField;
        Integer inputmaxLength = tstRemainingCharactersComponentController.maxLength;
        Integer inputsizeOfCharRemaingBox = tstRemainingCharactersComponentController.sizeOfCharRemaingBox;
        Integer inputnumOfCols = tstRemainingCharactersComponentController.numOfCols;
        Integer inputnumOfRows = tstRemainingCharactersComponentController.numOfRows;
    }
    
    @isTest(seeAllData=true)
    static void ReOpenCaseExtension_Test()
    {
        Case newcase = new Case();
        newcase.subject = 'Test Subject';
        newcase.status = 'Closed';
        newcase.resolution__c = 'test';
        insert newcase;
        ReOpenCaseExtension tstReOpenCaseExtension1 = new ReOpenCaseExtension(ReOpenCaseExtension.generateController(newcase));
        tstReOpenCaseExtension1.reason = '';
        tstReOpenCaseExtension1.reOpenCase();
        ReOpenCaseExtension tstReOpenCaseExtension2 = new ReOpenCaseExtension(ReOpenCaseExtension.generateController(newcase));
        tstReOpenCaseExtension2.reason = '1';
        tstReOpenCaseExtension2.reOpenCase();
        ReOpenCaseExtension tstReOpenCaseExtension3 = new ReOpenCaseExtension(ReOpenCaseExtension.generateController(newcase));
        tstReOpenCaseExtension3.reason = 'Test Coverage';
        tstReOpenCaseExtension3.reOpenCase();
        
    }
    
    @isTest(seeAllData=true)
    static void ProductPickerclass_Test()
    {
        productPickerClass tstproductPickerClass = new productPickerClass('Test String');
        
        string[] teststr;
        list<selectoption> testList;
        testList = tstproductPickerClass.getfilterOptions();
        testList = tstproductPickerClass.getProducts();
        testList = tstproductPickerClass.getselectedProductsList();
        teststr = tstproductPickerClass.getuserChoiceProduct();
        string tsestr = tstproductPickerClass.getAddOrRemoveSelector();
        
        string[] str = new string[]{'test','test1'};
        tstproductPickerClass.setuserChoiceProduct(str);
        tstproductPickerClass.selectedProducts = str;
        
        list<selectoption> theList = new list<selectoption>();
        theList.add(new selectoption('test','test'));
        tstproductPickerClass.defineProducts(theList,'All');
        tstproductPickerClass.defineProducts(theList,'Hardware');
        tstproductPickerClass.defineProducts(theList,'Other');
        
        tstproductPickerClass.changeSelectorToAdd();
        tstproductPickerClass.changeSelectorToRemove();
        tstproductPickerClass.assignProductsToString();
        
    }
    
    @isTest(seeAllData=true)
    static void PopulateNoteBodyOnLead_Test()
    {
        Country_And_Country_Code__c tstCountryCode = createCountryAndCountryCode();
        
        Lead objLead = new Lead();
        objLead.FirstName='Fname';
        objLead.LastName ='Lname';
        objLead.Phone='(080) 112-213';
        objLead.Company='TestCompany';
        objLead.Country=tstCountryCode.Name;        
        insert objLead;
        
        Note testNote = new Note();
        testNote.title = system.Label.Lead_Title_Name;
        testNote.body = 'Test Note';
        testNote.ParentId = objLead.Id;
        insert testNote;
    }
    
    @isTest(seeAllData=true)
    static void testMapCoverageKeyGenerationExtension()
    {
        
        Account acct = util.createAccount('CWH Test Account 1');
        acct.Type = 'Customer';
        update acct;
        Map_Set__c mapSet;
        Street_Area__c streetArea;
        List<Street_Area__c> streetAreas;
        
        
        mapSet = new Map_Set__c();
        mapSet.Account__c = acct.Id;
        mapSet.Postal_Areas_Purchased__c = false;
        mapSet.account__c = acct.Id;
        mapSet.Historical_Traffic_Data_Inrix__c = true;
        mapSet.Map_Vendor__c = acct.Id;
        mapSet.Number_of_Licensed_Vehicles__c = 1;
        mapSet.vendor_map_version_pl__c = 'TeleAtlas';
        insert mapSet;
        
        Map_Nation__c mapnation = new Map_Nation__c();
        mapnation.Name ='United States';
        insert mapnation;
        
        streetAreas = new List<Street_Area__c>();
        streetArea = new Street_Area__c();
        streetArea.Map_Set__c = mapSet.Id;
        streetArea.Map_Nation__c = [select Id from Map_Nation__c where Name = 'United States' and id =:
                                    mapnation.Id].Id;
        streetArea.IsMapStateSpecified__c = false;
        streetArea.IsMapCountySpecified__c = false;
        
        streetAreas.add(streetArea);
        
        Database.insert(streetAreas);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(mapSet);
        MapCoverageKeyGenerationExtension mapCoverageExt = new MapCoverageKeyGenerationExtension(sc);
        
        mapCoverageExt.setEmail('arindam.laik@tcs.com');
        mapCoverageExt.getEmail();
        
        mapCoverageExt.setComment('testComment');
        mapCoverageExt.getComment();
        mapCoverageExt.setDefaultKeyFilename('sampleFile');
        mapCoverageExt.getDefaultKeyFilename();
        
        mapCoverageExt.getCoverageKeyText();
        mapCoverageExt.getCoverageKeyHtml();
        
        mapCoverageExt.sendEmail();
        mapCoverageExt.cancelEmail();
        MapCoverageKeyGenerationExtension.createTestData();
        MapCoverageKeyGenerationExtension.retrieveOnlyCanadaStreetAreasFromList(streetAreas);
        
        MapCoverageKeyGenerationExtension mapCoverageExt1 = new MapCoverageKeyGenerationExtension(sc);
        
    }
    @isTest(seeAllData=true)
    static void testMapCoverageKeyGenerationExtension1()
    {
        Account acct = util.createAccount('testMapCoverageKeyGenerationExtension1');
        acct.Type = 'Customer';
        update acct;
        Map_Set__c mapSet;
        Street_Area__c streetArea;
        List<Street_Area__c> streetAreas;
        
        mapSet = new Map_Set__c();
        mapSet.Account__c = acct.Id;
        mapSet.Postal_Areas_Purchased__c = false;
        mapSet.account__c = acct.Id;
        mapSet.Historical_Traffic_Data_Inrix__c = true;
        mapSet.Map_Vendor__c = acct.Id;
        mapSet.Number_of_Licensed_Vehicles__c = 1;
        mapSet.vendor_map_version_pl__c = null;
        
        insert mapSet;
        
        Map_Nation__c mapnation = new Map_Nation__c();
        mapnation.Name ='United States';
        mapnation.ISO3__c ='Y';
        insert mapnation;
        Map_Nation__c mapnation1 = new Map_Nation__c();
        mapnation1.Name ='Canada';
        mapnation1.ISO3__c ='Y';
        insert mapnation1;
        
        Map_County__c mapCountry =  new Map_County__c();
        mapCountry.name ='US';
        insert mapCountry;
        
        map_state__c mapState = new Map_State__c();
        mapState.name = 'US';
        insert mapState;
        
        streetAreas = new List<Street_Area__c>();
        streetArea = new Street_Area__c();
        streetArea.Map_Set__c = mapSet.Id;
        streetArea.Map_Nation__c = mapnation1.Id;
        streetArea.IsMapStateSpecified__c = True;
        streetArea.IsMapCountySpecified__c = true;
        streetArea.Map_County__c = mapCountry.Id;
        streetArea.Map_State__c = mapState.Id;
        
        streetAreas.add(streetArea);
        
        Database.insert(streetAreas);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(mapSet);
        MapCoverageKeyGenerationExtension mapCoverageExt = new MapCoverageKeyGenerationExtension(sc);
        
        mapCoverageExt.setEmail('');
        mapCoverageExt.getEmail();
        
        mapCoverageExt.setDefaultKeyFilename('');
        mapCoverageExt.getDefaultKeyFilename();
        
        
        mapCoverageExt.setComment('testComment');
        mapCoverageExt.getComment();
        
        mapCoverageExt.getCoverageKeyText();
        mapCoverageExt.getCoverageKeyHtml();
        
        mapCoverageExt.sendEmail();
        mapCoverageExt.cancelEmail();
        MapCoverageKeyGenerationExtension.createTestData();
        MapCoverageKeyGenerationExtension.retrieveOnlyCanadaStreetAreasFromList(streetAreas);
    }
    
    @isTest(seeAllData = true)
    static void CaseEventEmailExtension_Test()
    {        
        Account testAccount = createAccount('CaseEventEmailExtension_Test');
        Contact testContact = createContact(testAccount);
        Case testcase = createCase(testAccount, testContact);
        
        Case_Event__c testCaseEvent = new Case_Event__c();
        testCaseEvent.Case__c = testcase.Id;
        testCaseEvent.subject__c = 'Test Case Event Subject';
        testCaseEvent.details__c = 'Test Case Event Details';
        testCaseEvent.Communication_Type__c = 'Email';
        insert testCaseEvent;
        
        ApexPages.StandardController sc = new ApexPages.StandardController(testCaseEvent);
        CaseEventEmailExtension tstCaseEventEmailExtension = new CaseEventEmailExtension(sc);
        tstCaseEventEmailExtension.settempCaseObject(testcase);
        tstCaseEventEmailExtension.settoEmailAddress('test@test.com');
        tstCaseEventEmailExtension.setCCEmailAddress('test@test.com');
        tstCaseEventEmailExtension.setbCCEmailAddress('test@test.com');
        PageReference pr = tstCaseEventEmailExtension.selectContactOrUser();
        pr = tstCaseEventEmailExtension.addEmailAddress();
        pr = tstCaseEventEmailExtension.addCCEmailAddress();
        pr = tstCaseEventEmailExtension.addBCCEmailAddress();
        pr = tstCaseEventEmailExtension.sendEmail();
                
        
        tstCaseEventEmailExtension.setIsSelectingContact(true);
        pr = tstCaseEventEmailExtension.determineWhichLookUpToGrabEmailAddressFor();
        tstCaseEventEmailExtension.setIsSelectingContact(false);
        pr = tstCaseEventEmailExtension.determineWhichLookUpToGrabEmailAddressFor();
        testCaseEvent = CaseEventEmailExtension.queryCaseEvent(testCaseEvent.Id);
        String testEmailStats = tstCaseEventEmailExtension.getEmailStatus();
        Case testcas = tstCaseEventEmailExtension.gettempCaseObject();
        Boolean isselcntc = tstCaseEventEmailExtension.getIsSelectingContact();
        String testEmailAdd = tstCaseEventEmailExtension.gettoEmailAddress();
        String testccEmailAdd = tstCaseEventEmailExtension.getCCEmailAddress();
        String testbccEmailAdd = tstCaseEventEmailExtension.getbCCEmailAddress();
        String testselectedEmailAdd = tstCaseEventEmailExtension.getSelectedEmailAddress();
        
    }
    
    @isTest(seeAllData = true)
    static void ChangeCaseOwnerExtension_Test()
    {
        Account testAccount = createAccount('ChangeCaseOwnerExtension_Test');
        Contact testContact = createContact(testAccount);
        Case testcase = createCase(testAccount, testContact);
        
        ApexPages.StandardController sc = ChangeCaseOwnerExtension.generateController(testcase);
        ChangeCaseOwnerExtension testChangeCaseOwnerExtension = new ChangeCaseOwnerExtension(sc);
        List<SelectOption> tstSelectOption = testChangeCaseOwnerExtension.userPickList;
        testChangeCaseOwnerExtension.supportOrAll = 'Test Support';
        tstSelectOption = testChangeCaseOwnerExtension.userPickList;
        tstSelectOption = testChangeCaseOwnerExtension.queuePickList;
        testChangeCaseOwnerExtension.businessUnit = 'Roadnet';
        tstSelectOption = testChangeCaseOwnerExtension.queuePickList;
        testChangeCaseOwnerExtension.businessUnit = 'Sylectus';
        tstSelectOption = testChangeCaseOwnerExtension.queuePickList;
        testChangeCaseOwnerExtension.businessUnit = 'Omnitracs MX';
        tstSelectOption = testChangeCaseOwnerExtension.queuePickList;
        testChangeCaseOwnerExtension.emailComments = 'Test Comment';
        PageReference pr = testChangeCaseOwnerExtension.radioButtonOnchange();
        pr = testChangeCaseOwnerExtension.changeOwner();
        String testcaseownername = testChangeCaseOwnerExtension.findNameOfCaseOwner(testcase.ownerId);
        testChangeCaseOwnerExtension.queueOrUser = 'queue';
        pr = testChangeCaseOwnerExtension.radioButtonOnchange();
        pr = testChangeCaseOwnerExtension.changeOwner();
        QueueSobject[] queues = [select queueid from QueueSobject where sobjecttype = 'Case' Limit 1]; 
        testcaseownername = testChangeCaseOwnerExtension.findNameOfCaseOwner(queues[0].queueid);
    }
    
    @isTest(seeAllData = true)
    static void CloseCaseExtension_Test()
    {
        Account testAccount = createAccount('CloseCaseExtension_Test');
        Contact testContact = createContact(testAccount);

        Case testcase = new Case();
        testcase.recordtypeid = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get('Professional Services').getRecordTypeId();
        testcase.subject = 'Test Case Subject';
        testcase.status = 'Open';
        testcase.accountid = testAccount.id;
        testcase.contactid = testContact.id;
        testcase.Sub_Reason_pl__c = 'test';
        insert testcase;
       
        Case_Event__c testCaseEvent = new Case_Event__c();
        testCaseEvent.Case__c = testcase.Id;
        testCaseEvent.subject__c = 'Test Case Event Subject';
        testCaseEvent.details__c = 'Test Case Event Details';
        testCaseEvent.Communication_Type__c = 'Email';
        insert testCaseEvent;
        
        ApexPages.StandardController sc = CloseCaseExtension.generateController(testcase,testcase.id);
        CloseCaseExtension testCloseCaseExtension = new CloseCaseExtension(sc);
        String srtvisible = CloseCaseExtension.isVisibleInSelfServiceFieldLabel;
        srtvisible = testCloseCaseExtension.isVisibleInSelfServiceFieldLabel;        
        testCloseCaseExtension.finalCaseEvent = testCaseEvent;
        Case_Event__c tstCaseEvent = testCloseCaseExtension.finalCaseEvent;
        PL tstPL = testCloseCaseExtension.productPicklist;
        tstPL = testCloseCaseExtension.caseReasonPicklist;
        tstPL = testCloseCaseExtension.subReasonPicklist;
        Case thecase1 = testCloseCaseExtension.gettheCase();
        boolean isoldcasersn = testCloseCaseExtension.isOldCaseReason;
        boolean isTimeSpent = testCloseCaseExtension.isTimeSpentRequired;       
        String strAccAlert = testCloseCaseExtension.standardAccountAlertDetail;
        String strAccTitle = testCloseCaseExtension.spotlightAccountTitle;
        String strStatustitle = testCloseCaseExtension.accountIsEvalStatusTitle;
        boolean isproductexist =  CloseCaseExtension.doesProductExistInPicklist(testcase.id,new List<selectOption>{new SelectOption(testcase.id,'test')});
        boolean isCaseSupp = testCloseCaseExtension.isCaseSupport;
        Integer casemin = testCloseCaseExtension.caseMinutes;   
        PageReference pf = testCloseCaseExtension.now();
        pf = testCloseCaseExtension.back();
        pf = testCloseCaseExtension.save();
        pf = testCloseCaseExtension.updateCaseEventExternalVisibleCheckbox();
        pf = testCloseCaseExtension.redefineCaseReasonPicklist();
        pf = testCloseCaseExtension.redefineSubReasonPicklist(); 
        CloseCaseExtension.redirectUserToApprioriateSaveAndClosePage(testcase);
    }
    
    @isTest(seeAllData=true)
    static void CRDateBasedLineChartController_Test()
    {
        CRDateBasedLineChartController testCRDateBasedLineChart = new CRDateBasedLineChartController();
        testCRDateBasedLineChart.yData = new Integer[]{100,200,300,400,500,600};
        testCRDateBasedLineChart.yDataDecimal = new Decimal[]{100.0,200.0,300.0,400.0,500.0,600.0};
        testCRDateBasedLineChart.yDataMin = 100;
        Integer intyDataMax = testCRDateBasedLineChart.yDataMax;
        testCRDateBasedLineChart.width = 500;
        testCRDateBasedLineChart.height = 300;
        testCRDateBasedLineChart.numSeries = 1;
        testCRDateBasedLineChart.dataColors = new String[]{'test color1','test color2','test color3','test color4','test color5'};
        testCRDateBasedLineChart.dataLabels = new String[]{'test label1','test label2','test label3','test label4','test label5'};
        testCRDateBasedLineChart.beginDate = System.TODAY()-5;
        testCRDateBasedLineChart.endDate = System.TODAY();        
        String strGoogleChartURL = testCRDateBasedLineChart.createGoogleChartURL();
        testCRDateBasedLineChart.shouldUseDecimalvalues = true;
        strGoogleChartURL = testCRDateBasedLineChart.createGoogleChartURL();
    }
    //test method for QESUnitySuperLinkWebServices and QESUnityAdminLinkWebServices classes
    @isTest(seeAllData=true)
    static void QESUnityAdminLinkWebServices_Test()
    {
        Test.startTest();
        Test.setMock(WebServiceMock.class, new QESUnitySuperLinkWebServicesMock());
        QESUnityAdminLinkWebServices qesAdminobj = new QESUnityAdminLinkWebServices(); 
        QESUnitySuperLinkWebServices qesSuperobj = new QESUnitySuperLinkWebServices();
        QESUnitySuperLinkWebServices.LinkServiceSoapImplPort linkserviceSOAPobj = new QESUnitySuperLinkWebServices.LinkServiceSoapImplPort();
        QESUnitySuperLinkWebServices.userCapability superUserCapability = new QESUnitySuperLinkWebServices.userCapability();
        QESUnitySuperLinkWebServices.abstractList superAbstractList = new QESUnitySuperLinkWebServices.abstractList();
        QESUnitySuperLinkWebServices.extendedInfo SuperExtendedInfo = new QESUnitySuperLinkWebServices.extendedInfo();
        QESUnitySuperLinkWebServices.getMyMessageListResponse supergetMyMessageListResponse = new QESUnitySuperLinkWebServices.getMyMessageListResponse();
        QESUnitySuperLinkWebServices.roleList superroleList = new QESUnitySuperLinkWebServices.roleList();
        QESUnitySuperLinkWebServices.applicationList SuperapplicationList = new QESUnitySuperLinkWebServices.applicationList();
        QESUnitySuperLinkWebServices.userCapabilityGroupList superuserCapabilityGroupList = new QESUnitySuperLinkWebServices.userCapabilityGroupList();
        QESUnitySuperLinkWebServices.phoneNumber superphoneNumber = new QESUnitySuperLinkWebServices.phoneNumber();
        QESUnitySuperLinkWebServices.countryList SupercountryList = new QESUnitySuperLinkWebServices.countryList();
        QESUnitySuperLinkWebServices.companyGroupList supercompanyGroupList = new QESUnitySuperLinkWebServices.companyGroupList();
        QESUnitySuperLinkWebServices.companyUserSettings supercompanyUserSettings = new QESUnitySuperLinkWebServices.companyUserSettings();
        QESUnitySuperLinkWebServices.linkList SuperlinkList = new QESUnitySuperLinkWebServices.linkList();
        QESUnitySuperLinkWebServices.MyMessageListInput superMyMessageListInput = new QESUnitySuperLinkWebServices.MyMessageListInput();
        QESUnitySuperLinkWebServices.usersList superusersList = new QESUnitySuperLinkWebServices.usersList();
        QESUnitySuperLinkWebServices.unityError SuperunityError = new QESUnitySuperLinkWebServices.unityError();
        QESUnitySuperLinkWebServices.LinkedCompanyAccountList_element superLinkedCompanyAccountList_element = new QESUnitySuperLinkWebServices.LinkedCompanyAccountList_element();
        QESUnitySuperLinkWebServices.userProfile superuserProfile = new QESUnitySuperLinkWebServices.userProfile();
        QESUnitySuperLinkWebServices.paymentCard SuperpaymentCard = new QESUnitySuperLinkWebServices.paymentCard();
        QESUnitySuperLinkWebServices.userCapabilityList superuserCapabilityList = new QESUnitySuperLinkWebServices.userCapabilityList();
        QESUnitySuperLinkWebServices.configAttribute superconfigAttribute = new QESUnitySuperLinkWebServices.configAttribute();
        QESUnitySuperLinkWebServices.country Supercountry = new QESUnitySuperLinkWebServices.country();
        QESUnitySuperLinkWebServices.companyList supercompanyList = new QESUnitySuperLinkWebServices.companyList();
        QESUnitySuperLinkWebServices.PostalAddressList_element superPostalAddressList_element = new QESUnitySuperLinkWebServices.PostalAddressList_element();
        QESUnitySuperLinkWebServices.company Supercompany = new QESUnitySuperLinkWebServices.company();
        QESUnitySuperLinkWebServices.role superrole = new QESUnitySuperLinkWebServices.role();
        QESUnitySuperLinkWebServices.arrayList superarrayList = new QESUnitySuperLinkWebServices.arrayList();
        QESUnitySuperLinkWebServices.MessageList_element SuperMessageList_element = new QESUnitySuperLinkWebServices.MessageList_element();
        QESUnitySuperLinkWebServices.logEntryList superlogEntryList = new QESUnitySuperLinkWebServices.logEntryList();
        QESUnitySuperLinkWebServices.paymentCardList superpaymentCardList = new QESUnitySuperLinkWebServices.paymentCardList();
        QESUnitySuperLinkWebServices.LinkedUserAccountList_element SuperLinkedUserAccountList_element = new QESUnitySuperLinkWebServices.LinkedUserAccountList_element();
        QESUnitySuperLinkWebServices.logEntry superlogEntry = new QESUnitySuperLinkWebServices.logEntry();
        QESUnitySuperLinkWebServices.getHomePageHeaderLinksByGroupResponse supergetHomePageHeaderLinksByGroupResponse = new QESUnitySuperLinkWebServices.getHomePageHeaderLinksByGroupResponse();
        QESUnitySuperLinkWebServices.CompanyAttributeList_element SuperCompanyAttributeList_element = new QESUnitySuperLinkWebServices.CompanyAttributeList_element();
        QESUnitySuperLinkWebServices.responseElement superresponseElement = new QESUnitySuperLinkWebServices.responseElement();
        QESUnitySuperLinkWebServices.stateList superstateList = new QESUnitySuperLinkWebServices.stateList();
        QESUnitySuperLinkWebServices.UserGuid SuperUserGuid = new QESUnitySuperLinkWebServices.UserGuid();
        QESUnitySuperLinkWebServices.link superlink = new QESUnitySuperLinkWebServices.link();
        QESUnitySuperLinkWebServices.MemberCompanies_element superMemberCompanies_element = new QESUnitySuperLinkWebServices.MemberCompanies_element();
        QESUnitySuperLinkWebServices.state Superstate = new QESUnitySuperLinkWebServices.state();
        QESUnitySuperLinkWebServices.LinkList_element superLinkList_element = new QESUnitySuperLinkWebServices.LinkList_element();
        QESUnitySuperLinkWebServices.SystemConfigList_element superSystemConfigList_element = new QESUnitySuperLinkWebServices.SystemConfigList_element();
        QESUnitySuperLinkWebServices.linkedCompanyAccountList SuperlinkedCompanyAccountList = new QESUnitySuperLinkWebServices.linkedCompanyAccountList();
        QESUnitySuperLinkWebServices.userCapabilityGroup superuserCapabilityGroup = new QESUnitySuperLinkWebServices.userCapabilityGroup();
        QESUnitySuperLinkWebServices.PhoneNumberList_element superPhoneNumberList_element = new QESUnitySuperLinkWebServices.PhoneNumberList_element();
        QESUnitySuperLinkWebServices.token Supertoken = new QESUnitySuperLinkWebServices.token();
        QESUnitySuperLinkWebServices.LinksByGroupInput superLinksByGroupInput = new QESUnitySuperLinkWebServices.LinksByGroupInput();
        QESUnitySuperLinkWebServices.MyLinksByGroupInput superMyLinksByGroupInput = new QESUnitySuperLinkWebServices.MyLinksByGroupInput();
        QESUnitySuperLinkWebServices.CapabilityGroupList_element SuperCapabilityGroupList_element = new QESUnitySuperLinkWebServices.CapabilityGroupList_element();
        QESUnitySuperLinkWebServices.application superapplication = new QESUnitySuperLinkWebServices.application();
        QESUnitySuperLinkWebServices.linkedUserAccount superlinkedUserAccount = new QESUnitySuperLinkWebServices.linkedUserAccount();
        QESUnitySuperLinkWebServices.configAttributeList SuperconfigAttributeList = new QESUnitySuperLinkWebServices.configAttributeList();
        QESUnitySuperLinkWebServices.UserAttributeList_element superUserAttributeList_element = new QESUnitySuperLinkWebServices.UserAttributeList_element();
        QESUnitySuperLinkWebServices.getMySupportContactListResponse supergetMySupportContactListResponse = new QESUnitySuperLinkWebServices.getMySupportContactListResponse();
        QESUnitySuperLinkWebServices.linkGroupList SuperlinkGroupList = new QESUnitySuperLinkWebServices.linkGroupList();
        QESUnitySuperLinkWebServices.companyAttribute supercompanyAttribute = new QESUnitySuperLinkWebServices.companyAttribute();
        QESUnitySuperLinkWebServices.linkedCompanyAccount superlinkedCompanyAccount = new QESUnitySuperLinkWebServices.linkedCompanyAccount();
        QESUnitySuperLinkWebServices.LinkGroupList_element SuperLinkGroupList_element = new QESUnitySuperLinkWebServices.LinkGroupList_element();
        QESUnitySuperLinkWebServices.getMyLinksByGroupResponse supergetMyLinksByGroupResponse = new QESUnitySuperLinkWebServices.getMyLinksByGroupResponse();
        QESUnitySuperLinkWebServices.systemConfig supersystemConfig = new QESUnitySuperLinkWebServices.systemConfig();
        QESUnitySuperLinkWebServices.message Supermessage = new QESUnitySuperLinkWebServices.message();
        QESUnitySuperLinkWebServices.userAttribute superuserAttribute = new QESUnitySuperLinkWebServices.userAttribute();
        QESUnitySuperLinkWebServices.standardResponse superstandardResponse = new QESUnitySuperLinkWebServices.standardResponse();
        QESUnitySuperLinkWebServices.companyGroup SupercompanyGroup = new QESUnitySuperLinkWebServices.companyGroup();
        QESUnitySuperLinkWebServices.linkedUserAccountGroup superlinkedUserAccountGroup = new QESUnitySuperLinkWebServices.linkedUserAccountGroup();
        QESUnitySuperLinkWebServices.abstractCollection SuperabstractCollection = new QESUnitySuperLinkWebServices.abstractCollection();
        QESUnitySuperLinkWebServices.messageGroup supermessageGroup = new QESUnitySuperLinkWebServices.messageGroup();
        QESUnitySuperLinkWebServices.postalAddress superpostalAddress = new QESUnitySuperLinkWebServices.postalAddress();
        QESUnitySuperLinkWebServices.getLinksByGroupResponse SupergetLinksByGroupResponse = new QESUnitySuperLinkWebServices.getLinksByGroupResponse();
        QESUnitySuperLinkWebServices.CapabilityList_element superCapabilityList_element = new QESUnitySuperLinkWebServices.CapabilityList_element();
        QESUnitySuperLinkWebServices.linkGroup superlinkGroup = new QESUnitySuperLinkWebServices.linkGroup();
        QESUnitySuperLinkWebServices.HomePageHeaderLinksByGroupInput SuperHomePageHeaderLinksByGroupInput = new QESUnitySuperLinkWebServices.HomePageHeaderLinksByGroupInput();
     
        QESUnityAdminLinkWebServices.company qesCompany = new QESUnityAdminLinkWebServices.company(); 
        QESUnityAdminLinkWebServices.UpdateCompanyInput updateCompanyInputobj = new QESUnityAdminLinkWebServices.UpdateCompanyInput();
        QESUnityAdminLinkWebServices.companyAttribute companyAttr = new QESUnityAdminLinkWebServices.companyAttribute();
        QESUnityAdminLinkWebServices.CompanyAttributeList_element companyAttrElement= new  QESUnityAdminLinkWebServices.CompanyAttributeList_element();
        List<QESUnityAdminLinkWebServices.companyAttribute> compAttrList =new List<QESUnityAdminLinkWebServices.companyAttribute>();
        QESUnityAdminLinkWebServices.extendedCompany extendedComp = new QESUnityAdminLinkWebServices.extendedCompany();
        QESUnityAdminLinkWebServices.userProfile adminUserProfile = new  QESUnityAdminLinkWebServices.userProfile();
        QESUnityAdminLinkWebServices.company adminCompany = new  QESUnityAdminLinkWebServices.company();
        QESUnityAdminLinkWebServices.companyList adminCompanyList = new QESUnityAdminLinkWebServices.companyList();
        QESUnityAdminLinkWebServices.linkedUserAccount adminLinkedUserAccount = new QESUnityAdminLinkWebServices.linkedUserAccount();
        QESUnityAdminLinkWebServices.linkedUserAccountGroup adminLinkedUserAccountGroup = new QESUnityAdminLinkWebServices.linkedUserAccountGroup();
        QESUnityAdminLinkWebServices.linkGroup adminLinkGroup = new  QESUnityAdminLinkWebServices.linkGroup();
        QESUnityAdminLinkWebServices.link adminLink =  new QESUnityAdminLinkWebServices.link ();
        QESUnityAdminLinkWebServices.messageGroup adminMessageGroup = new QESUnityAdminLinkWebServices.messageGroup();
        QESUnityAdminLinkWebServices.message adminMessage = new  QESUnityAdminLinkWebServices.message();
        QESUnityAdminLinkWebServices.unityError adminError = new   QESUnityAdminLinkWebServices.unityError();
        QESUnityAdminLinkWebServices.usersList adminUsersList = new   QESUnityAdminLinkWebServices.usersList();
        QESUnityAdminLinkWebServices.linkedCompanyAccount adminLinkedCompanyAccount = new QESUnityAdminLinkWebServices.linkedCompanyAccount();
        QESUnityAdminLinkWebServices.linkedCompanyAccountList adminLinkedCompanyAccountList = new  QESUnityAdminLinkWebServices.linkedCompanyAccountList();
        QESUnityAdminLinkWebServices.token adminToken = new  QESUnityAdminLinkWebServices.token();
        QESUnityAdminLinkWebServices.phoneNumber adminPhoneNumber = new  QESUnityAdminLinkWebServices.phoneNumber();
        QESUnityAdminLinkWebServices.postalAddress adminPostalAddress = new  QESUnityAdminLinkWebServices.postalAddress();
        QESUnityAdminLinkWebServices.userCapability adminUserCapability = new  QESUnityAdminLinkWebServices.userCapability();
        QESUnityAdminLinkWebServices.userCapabilityList adminUserCapabilityList = new  QESUnityAdminLinkWebServices.userCapabilityList();
        QESUnityAdminLinkWebServices.companyAttribute adminCompanyAttribute = new  QESUnityAdminLinkWebServices.companyAttribute();
        QESUnityAdminLinkWebServices.companyUserSettings adminCompanyUserSettings = new  QESUnityAdminLinkWebServices.companyUserSettings();
        QESUnityAdminLinkWebServices.userAttribute adminUserAttribute = new  QESUnityAdminLinkWebServices.userAttribute();
        QESUnityAdminLinkWebServices.linkList adminLinkList = new  QESUnityAdminLinkWebServices.linkList();
        QESUnityAdminLinkWebServices.extendedInfo adminExtendedInfo = new  QESUnityAdminLinkWebServices.extendedInfo();
        QESUnityAdminLinkWebServices.logEntry adminLogEntry = new  QESUnityAdminLinkWebServices.logEntry();
        QESUnityAdminLinkWebServices.logEntryList adminLogEntryList = new  QESUnityAdminLinkWebServices.logEntryList();
        QESUnityAdminLinkWebServices.state adminState = new  QESUnityAdminLinkWebServices.state();
        QESUnityAdminLinkWebServices.stateList adminStateList = new  QESUnityAdminLinkWebServices.stateList();
        QESUnityAdminLinkWebServices.country adminCountry = new  QESUnityAdminLinkWebServices.country();
        QESUnityAdminLinkWebServices.countryList adminCountryList = new QESUnityAdminLinkWebServices.countryList();
        QESUnityAdminLinkWebServices.role adminRole = new  QESUnityAdminLinkWebServices.Role();
        QESUnityAdminLinkWebServices.roleList adminRoleList = new  QESUnityAdminLinkWebServices.roleList();
        QESUnityAdminLinkWebServices.application adminApplication = new  QESUnityAdminLinkWebServices.application();
        QESUnityAdminLinkWebServices.linkGroupList adminLinkGroupList = new  QESUnityAdminLinkWebServices.linkGroupList();
        QESUnityAdminLinkWebServices.applicationList adminApplicationList = new  QESUnityAdminLinkWebServices.applicationList();
        QESUnityAdminLinkWebServices.systemConfig adminSystemConfig = new  QESUnityAdminLinkWebServices.systemConfig();
        QESUnityAdminLinkWebServices.paymentCard adminPaymentCard = new  QESUnityAdminLinkWebServices.paymentCard();
        QESUnityAdminLinkWebServices.paymentCardList adminPaymentCardList = new  QESUnityAdminLinkWebServices.paymentCardList();
        QESUnityAdminLinkWebServices.configAttribute adminConfigAttribute = new  QESUnityAdminLinkWebServices.configAttribute();
        QESUnityAdminLinkWebServices.userCapabilityGroup adminUserCapabilityGroup = new   QESUnityAdminLinkWebServices.userCapabilityGroup();
        QESUnityAdminLinkWebServices.companyGroup adminCompanyGroup = new  QESUnityAdminLinkWebServices.companyGroup();
        QESUnityAdminLinkWebServices.companyGroupList adminCompanyGroupList = new  QESUnityAdminLinkWebServices.companyGroupList();
        QESUnityAdminLinkWebServices.userCapabilityGroupList adminUserCapabilityGroupList = new QESUnityAdminLinkWebServices.userCapabilityGroupList();
        QESUnityAdminLinkWebServices.arrayList adminArrayList = new  QESUnityAdminLinkWebServices.arrayList();
        QESUnityAdminLinkWebServices.configAttributeList adminConfigAttributeList = new  QESUnityAdminLinkWebServices.configAttributeList();
        QESUnityAdminLinkWebServices.migrationPlan adminMigrationPlan = new  QESUnityAdminLinkWebServices.migrationPlan();
        QESUnityAdminLinkWebServices.migrationPlanUserDetails adminMigrationPlanUserDetails = new  QESUnityAdminLinkWebServices.migrationPlanUserDetails();
        QESUnityAdminLinkWebServices.migrationPlanQspUserDetails adminMigrationPlanQspUserDetails = new  QESUnityAdminLinkWebServices.migrationPlanQspUserDetails();
        QESUnityAdminLinkWebServices.migrationPlanList adminMigrationPlanList = new  QESUnityAdminLinkWebServices.migrationPlanList();
        QESUnityAdminLinkWebServices.migrationPlanLicense adminMigrationPlanLicense = new   QESUnityAdminLinkWebServices.migrationPlanLicense();
        QESUnityAdminLinkWebServices.companyProvStatus adminCompanyProvStatus = new  QESUnityAdminLinkWebServices.companyProvStatus();
        QESUnityAdminLinkWebServices.companyProvStatusList adminCompanyProvStatusList = new  QESUnityAdminLinkWebServices.companyProvStatusList();
        QESUnityAdminLinkWebServices.LinkGroupList_element  adminlinkGroupList_element = new  QESUnityAdminLinkWebServices.LinkGroupList_element();
        QESUnityAdminLinkWebServices.MigrationPlanLicenseList_element adminMigrationPlanLicenseList_element = new QESUnityAdminLinkWebServices.MigrationPlanLicenseList_element();
        QESUnityAdminLinkWebServices.abstractCollection     adminAbstractCollection  = new  QESUnityAdminLinkWebServices.abstractCollection();
        QESUnityAdminLinkWebServices.MigrationPlanUserDetailList_element    adminMigrationPlanUserDetailList_element     = new QESUnityAdminLinkWebServices.MigrationPlanUserDetailList_element();
        QESUnityAdminLinkWebServices.CapabilityList_element adminCapabilityList_element  = new QESUnityAdminLinkWebServices.CapabilityList_element();
        QESUnityAdminLinkWebServices.abstractList   adminAbstractList    = new QESUnityAdminLinkWebServices.abstractList();
        QESUnityAdminLinkWebServices.CriteriaList_element   adminCriteriaList_element    = new QESUnityAdminLinkWebServices.CriteriaList_element();
        QESUnityAdminLinkWebServices.MessageList_element    adminMessageList_element     = new QESUnityAdminLinkWebServices.MessageList_element();
        QESUnityAdminLinkWebServices.LinkedUserAccountList_element  adminLinkedUserAccountList_element   = new QESUnityAdminLinkWebServices.LinkedUserAccountList_element();
        QESUnityAdminLinkWebServices.PhoneNumberList_element    adminPhoneNumberList_element     = new QESUnityAdminLinkWebServices.PhoneNumberList_element();
        QESUnityAdminLinkWebServices.UserAttributeList_element  adminUserAttributeList_element   = new QESUnityAdminLinkWebServices.UserAttributeList_element();
        QESUnityAdminLinkWebServices.Exception_x    adminException_x     = new QESUnityAdminLinkWebServices.Exception_x();
        QESUnityAdminLinkWebServices.responseElement adminrespElement = new QESUnityAdminLinkWebServices.responseElement();
        QESUnityAdminLinkWebServices.LinkList_element adminLinkList_element = new QESUnityAdminLinkWebServices.LinkList_element();
        QESUnityAdminLinkWebServices.CapabilityGroupList_element adminCapabilityGroupList_element  = new QESUnityAdminLinkWebServices.CapabilityGroupList_element();
        QESUnityAdminLinkWebServices.MemberCompanies_element adminMemberCompanies_element = new QESUnityAdminLinkWebServices.MemberCompanies_element();
        QESUnityAdminLinkWebServices.PostalAddressList_element adminPostalAddressList_element  = new QESUnityAdminLinkWebServices.PostalAddressList_element();
        QESUnityAdminLinkWebServices.searchCriteriaAndValue adminsearchCriteriaAndValue = new QESUnityAdminLinkWebServices.searchCriteriaAndValue();
        QESUnityAdminLinkWebServices.MigrationPlanQspUserDetailList_element  adminMigrationPlanQspUserDetailList_element = new QESUnityAdminLinkWebServices.MigrationPlanQspUserDetailList_element();
        QESUnityAdminLinkWebServices.LinkedCompanyAccountList_element adminLinkedCompanyAccountList_element = new QESUnityAdminLinkWebServices.LinkedCompanyAccountList_element();
        QESUnityAdminLinkWebServices.SystemConfigList_element adminSystemConfigList_element = new QESUnityAdminLinkWebServices.SystemConfigList_element();
        QESUnityAdminLinkWebServices.standardResponse standardResp = new QESUnityAdminLinkWebServices.standardResponse();
        QESUnityAdminLinkWebServices.searchInput serachInputobj = new QESUnityAdminLinkWebServices.searchInput(); 
        QESUnityAdminLinkWebServices.AdminServiceSoapImplPort adminServiceSoapImplPorObj = new  QESUnityAdminLinkWebServices.AdminServiceSoapImplPort ();
        adminServiceSoapImplPorObj.getRoleListForUser(UserInfo.getUserId(),'testRole');
        adminServiceSoapImplPorObj.setAuthorization();
        adminServiceSoapImplPorObj.getMigrationPlansBySearch(serachInputobj);
        adminServiceSoapImplPorObj.getCompany('test');
        adminServiceSoapImplPorObj.migrateSalesforceContactId();
        adminServiceSoapImplPorObj.setAlertEmailAddress('test','rama.i@tcs.com','test');
        adminServiceSoapImplPorObj.grantCapabilityToLinkedUser('test','rama.i@tcs.com','test');
        adminServiceSoapImplPorObj.revokeCapabilityFromLinkedUser('test','rama.i@tcs.com','test');
        adminServiceSoapImplPorObj.createCompany(qesCompany,'test');
        adminServiceSoapImplPorObj.createLinkedUserAccount(adminLinkedUserAccount,'test');
        adminServiceSoapImplPorObj.getCompanyByERP('test');
        adminServiceSoapImplPorObj.updateCompany(adminCompany,'test');
        adminServiceSoapImplPorObj.generateMigrationPlanDetails(10,'Rishi');
        adminServiceSoapImplPorObj.setEmailAddress('test','rama.i@tcs.com','test') ;
        adminServiceSoapImplPorObj.processMigrationPlan(10,'test');
        adminServiceSoapImplPorObj.updateLinkedUserAccount(adminLinkedUserAccount,'test');
        adminServiceSoapImplPorObj.updateCompanyModelDetails(extendedComp,'test') ;
        adminServiceSoapImplPorObj.migrateSalesforceCompanyId() ;
        adminServiceSoapImplPorObj.deleteLinkedCompanyAccount('test','test');
        adminServiceSoapImplPorObj.createLinkedCompanyAccount(adminLinkedCompanyAccount,'test');
        adminServiceSoapImplPorObj.createUser(adminUserProfile,'test');
        adminServiceSoapImplPorObj.startChangeEmailAddress('test','test','test','test');
        adminServiceSoapImplPorObj.changeCompanyProvMode('test','test','test');
        adminServiceSoapImplPorObj.getSysConfig('test','test');
        adminServiceSoapImplPorObj.updateUser(adminUserProfile,'test');
        adminServiceSoapImplPorObj.createMigrationPlan(adminMigrationPlan,'test');
        adminServiceSoapImplPorObj.getAffiliatesForUser('test','test');
        adminServiceSoapImplPorObj.getCompanyByQSP('test');
        adminServiceSoapImplPorObj.getMigrationPlan(10) ;
        adminServiceSoapImplPorObj.updateLinkedCompanyAccount(adminLinkedCompanyAccount,'test');
        adminServiceSoapImplPorObj.deleteMigrationPlan(10,'test');
        adminServiceSoapImplPorObj.setUserPassword('test','test','test');
        adminServiceSoapImplPorObj.changeUserProvMode('test','test','test');
        adminServiceSoapImplPorObj.getUser('test');
        adminServiceSoapImplPorObj.getApplicationListForCompany('test');
        adminServiceSoapImplPorObj.deleteLinkedUserAccount('test','test');
        adminServiceSoapImplPorObj.updateMigrationPlan(adminMigrationPlan,'test');
        adminServiceSoapImplPorObj.migrateCompanyAdminsAndUser('test','test','test');
        adminServiceSoapImplPorObj.updateSupportContactDetails(extendedComp,'test');
        linkserviceSOAPobj.getMyActiveLinksByGroup('test','test','test');
        linkserviceSOAPobj.getActiveLinksByGroup('test','test');
        QESUnityAdminLinkWebServices.UpdateUserInput  updateuserInput= new QESUnityAdminLinkWebServices.UpdateUserInput();
        QESUnityAdminLinkWebServices.CreateUserAccountInput createUserAccountInput = new  QESUnityAdminLinkWebServices.CreateUserAccountInput(); 
        QESUnityAdminLinkWebServices.MigrateSalesforceContactIdOutput  migrateSalesforceContactIdOutput = new QESUnityAdminLinkWebServices.MigrateSalesforceContactIdOutput();
        QESUnityAdminLinkWebServices.updateLinkedCompanyAccountResponse updateLinkedCompanyAccResponse = new  QESUnityAdminLinkWebServices.updateLinkedCompanyAccountResponse();
        QESUnityAdminLinkWebServices.GenerateMigrationPlanDetailsInput generateMigrationPlanDetailsInput = new  QESUnityAdminLinkWebServices.GenerateMigrationPlanDetailsInput();
        QESUnityAdminLinkWebServices.ApplicationListInput  applicationListInput = new   QESUnityAdminLinkWebServices.ApplicationListInput();
        QESUnityAdminLinkWebServices.AffiliateListForUserInput affiliateListForUserInput = new QESUnityAdminLinkWebServices.AffiliateListForUserInput();
        QESUnityAdminLinkWebServices.CompanyInput   companyInput = new QESUnityAdminLinkWebServices.CompanyInput();
        QESUnityAdminLinkWebServices.AlertEmailAddressOutput alertEmailAddressOutput = new QESUnityAdminLinkWebServices.AlertEmailAddressOutput();
        Test.stopTest();
    }
}