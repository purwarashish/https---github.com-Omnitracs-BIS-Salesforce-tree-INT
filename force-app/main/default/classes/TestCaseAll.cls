/**
* This class contains unit tests for validating the behavior of Apex classes
* and triggers for Case Object
*
* See the Apex Language Reference for more information about Testing and Code Coverage.
*/
@isTest
private class TestCaseAll {
    
    /***************************Commnon Variables****************************************/
    
    static Template__c newTemplate = new Template__c();
    static Templatedetail__c newTempDetail1 = new Templatedetail__c();
    static List<Templatedetail__c> newLstTempDetail = new list<Templatedetail__c>();
    static Support_Alert__c newSuppalert = new Support_Alert__c();
    
    static List<System_Outage__c> newLstSysOutage = new List<System_Outage__c>();
    static List<Support_Alert__c> newLstSupportAlert = new List<Support_Alert__c>();
    
    
    
    
    /************************************** Common Data Initialization********************/
    static Account caseAccount = GenericTestClass.insertAccount();
    static Contact caseContact = GenericTestClass.insertContact(caseAccount.Id);
    static NMC_Account__c caseNMCAccount = GenericTestClass.insertNMCAccount(caseAccount.Id);
    static Case testCase = GenericTestClass.insertCase(caseAccount.ID, caseContact.ID); 
    static Group newGroup = GenericTestClass.insertGroup();  
    static Group newGroup1 = GenericTestClass.insertGroup();
    // Remove from Generic Classstatic Support_Alert__c newSuppalert = GenericTestClass.insertSupportAlert(caseAccount.Id);
    // Remove from Generic Class static System_Outage__c newSysout = GenericTestClass.insertSystemOutage(testcase.id);
    /************Method to insert all other required Records******************************/
    static testMethod void initializeData()
    {
        test.startTest();
        /*********************Insert Template Record **************************/
        newTemplate.Name = 'Test Template';
        newTemplate.IsActive__c = true;
        newTemplate.NumTotal__c = 2;
        insert newTemplate;
        
        /*********************Insert TemplateDetail Record **************************/
        newTempDetail1.TemplateID__c = newTemplate.Id;
        newTempDetail1.Name = 'RecordTypeId';
        newTempDetail1.Value__c = '01250000000DT5tAAG';
        insert newTempDetail1;
        
        /*********************Insert Support Alert Record*****************************/
        newSuppalert.Account__c = caseAccount.Id;
        newSuppalert.Description__c = 'Test Descritpion';
        newSuppalert.End_Date__c =  date.today()+4;
        insert newSuppalert;
        
        testCaseTemplateListController();
        testShowSupportAlert();
        test.stopTest();
    }
    /****************************************Clear All the List after every class************************/
    static void clearAllList()
    {
        newLstTempDetail.clear();
        newLstSysOutage.clear();
        newLstSupportAlert.clear();
    }
    
    
    /****************************************TestCaseOwner_Queue Classes*********************************/
    
    static testMethod void testCaseOwner_Queue() {
        
        list<String> lstAlphabet = new list<String>{'All','a'};
            list<Boolean> lstOrdering = new list<Boolean>{true,false};
                test.startTest();
        ApexPages.currentPage().getParameters().put('Id',testCase.Id);
        ApexPages.StandardController sdtCon;
        
        /****************Test for CaseOwnerAssignment********************************/
        
        CaseOwnerAssignmentController newOwnerObj = new CaseOwnerAssignmentController(sdtCon);
        /*********check for Alphabet Ordering***********************/
        for(integer i=0;i<lstAlphabet.size();i++)
        {
            newOwnerObj.alphabet = lstAlphabet[i];
            newOwnerObj.Alphabet_Ordering();
        }
        /*********************check for Sorting**********************/
        for(integer i=0;i<lstOrdering.size();i++)
        {
            newOwnerObj.asce = lstOrdering[i];
            newOwnerObj.ChangeOrder();
        }
        
        newOwnerObj.ShowAllUsers();
        newOwnerObj.SelectedOwnerId = newOwnerObj.userList[0].Id;
        newOwnerObj.ShowUsersInCurrentQueue();
        newOwnerObj.sendEmail = true;
        newOwnerObj.AssignUser();
        newOwnerObj.CaseId = null;
        newOwnerObj.AssignUser();
        newOwnerObj.ShowUsersInCurrentQueue();
        /****************End of Test for CaseOwnerAssignment********************************/
        
        /****************Test for CaseQueueAssignment********************************/
        
        CaseQueueAssignmentController newQueueObj = new CaseQueueAssignmentController(sdtCon);
        
        /*********************check for Sorting**********************/
        for(integer i=0;i<lstOrdering.size();i++)
        {
            newQueueObj.asce = lstOrdering[i];
            newQueueObj.ChangeOrder();
        }
        newQueueObj.SelectedOwnerId = '0';
        newQueueObj.AssignUser();
        newQueueObj.sendEmail = true;
        newQueueObj.AssignUser();
        /****************End of Test for CaseQueueAssignment********************************/ 
        test.stopTest();
        clearAllList();
        
    }
    
    /****************************************TestCaseTemplateListClass Methods*********************************/
    static void  testCaseTemplateListController()
    {
        
        list<String> lstName = new list<string>{'Description','Status','Reason','Origin','Subject','Type','Priority','Call_Back__c',
            'Queue__c','Product__c','Category__c','Type_Level_2__c','Area_Level_3__c',
            'Technical_Tip__c','Customer_Complaint__c','Human_Interest__c','Engineering_Tracking__c',
            'Substatus__c','System__c','RMA__c','Serial__c','Firmware__c','Siebel_ID__c','Resolution__c',
            'Equipment_ID__c','Created_by_Queue__c','Shift_Report__c','Add_Remove__c','Aux_Sensor__c',
            'Cargo_Sensor__c','Contract_Description__c','Contract_Product__c','Cross_Street_Location__c',
            'Customer_Hosted__c','Door_Sensor__c','End_of_Eval__c','Internal_Default_for_Status_Rpt_Interval__c',
            'Qualcomm_Hosted__c','Queued_Status_Report_Interval__c','Requested_Default_NMC_Acct_for_Unit_Type__c',
            'Requested_NMC_Account_Status__c','Requested_Retention_Period__c','Services__c','Telecom_For_Customer_Hosted__c',
            'Telecom_For_Third_Party_Hosted__c','Test_Account__c','Third_Party_Hosted__c','Unit_Type__c','CI__c','AccountId',
            'ContactId','NMC_Account__c','AccountId'};                                                    
                
                User CurrentUser = [select UserType, ContactId, email  from User where Id =:UserInfo.getUserId() Limit 1];
        system.RunAs(CurrentUser){
            ApexPages.StandardController sdtCon;
            CaseTemplateListController newObj = new CaseTemplateListController(sdtCon);
            CaseTemplateListController newObj1 = new CaseTemplateListController();
            newObj.templateID = ApexPages.currentPage().getParameters().put('tempID',newTemplate.Id);
            
            newObj.asce = true;
            newTemplate.Folder__c = 'AllFolders';
            update newTemplate;
            newObj.SelectedRecords();
            newTemplate.Folder__c = 'NaviGo';
            update newTemplate;
            newObj.SelectedRecords();
            newObj.asce = false;
            newObj.folder = 'AllFolders';
            newObj.SelectedRecords();
            newObj.folder = 'NaviGo';
            newObj.SelectedRecords();
            newObj.TemplateID = newTemplate.Id;
            
            newObj.createCase();
            newObj.asce = true;
            newObj.ChangeOrder();
            newObj.asce = false;
            newObj.ChangeOrder();
            List<SelectOption> sel = newObj.getoptions();
            newObj.setoptions(sel);
            
            ApexPages.currentPage().getParameters().put('AccountId',caseAccount.Id);
            //newObj.getCreateNewCase();
            
            ApexPages.currentPage().getParameters().put('ContactId',caseContact.Id);
            //newObj.getCreateNewCase();
            
            caseNMCAccount.account__c = caseAccount.id;
            update caseNMCAccount;
            
            ApexPages.currentPage().getParameters().put('NMCAcct',caseNMCAccount.Id);
            //newObj.getCreateNewCase();
            
            for(integer i=0;i<lstName.size();i++)
            {
                newLstTempDetail.add(new Templatedetail__c(TemplateId__c=newTemplate.Id,Name =lstName[i],Value__c='test'));
            }
            
            
            if(newLstTempDetail.size()>0)
            {
                insert newLstTempDetail;
            }
            
            //newObj.getCreateNewCase();
            newObj.SelectedRecords();
        }
        clearAllList();
        
    }
    
    
    /*****************************************TestCaseTISClass Methods*******************************************/
    
    static testMethod void testCaseTISController ()
    {
        test.startTest();
        ApexPages.StandardController sdtCon = new ApexPages.StandardController(testCase);
        CaseTISControllerExtension Controller = new CaseTISControllerExtension(sdtCon);
        Controller.CalculateOptionsList();
        Controller.TrueToggleShowDetail();
        Controller.FalseToggleShowDetail();
        Controller.getTISSummary();
        Controller.getTISDetail();
        Controller.getItems();
        Controller.ReturntoCase();
        clearAllList();
        test.stopTest();
    }
    
    /*****************************************TestCaseTISTriggers****************************************************/
    static testMethod void testCaseTISTriggers ()
    {
        test.startTest();
        /**********************************Test Case-1***********************************************************/
        caseAccount.QWBS_Market__c='T&L Eastern Region';
        caseAccount.name='My Test';
        caseAccount.BillingStreet = '123 Main';
        caseAccount.BillingCity = 'San Diego';
        caseAccount.BillingState = 'CA';
        caseAccount.BillingCountry = 'USA';
        caseAccount.QWBS_Cust_ID__c='12101986';
        caseAccount.RFC_ID__c='29051986';
        update caseAccount;
        
        Case CaseNew = new Case();
        testCase.Status = 'Open';
        testCase.Substatus__c ='In Progress';
        update testCase;
        
        testCase.Status = 'Pending';
        update testCase;
        
        testCase.Status = 'Closed';
        testCase.Resolution__c = 'test';
        testCase.Description = 'test';
        update testCase;
        /**********************************Test Case-2***********************************************************/
        
        /*newGroup.name = 'Test Queue';
newGroup.type = 'Queue';
update newGroup ;*/
        
        /*newGroup1.name = 'Test Queue1';
newGroup1.type = 'Queue';
update newGroup1;*/
        
        testCase.Queue__c = newGroup.name;
        testCase.AccountId = caseAccount.Id;
        update testCase;
        
        testCase.Queue__c = newGroup1.name;
        update testCase;
        
        testCase.Status = 'Open';
        testCase.Substatus__c ='In Progress';
        update testCase;
        
        testCase.status = 'Closed';
        testCase.Resolution__c = 'test';
        testCase.description = 'test';
        update testCase;
        
        /**********************************Test Case-3***********************************************************/
        testCase.description = 'test';
        testCase.Status = 'Open';
        testCase.Substatus__c ='In Progress';
        testCase.AccountId = caseAccount.Id;
        update testCase;
        
        testCase.status = 'Pending';
        update testCase;
        
        CreateTIS.insertCounter = 0;
        
        testCase.Queue__c = newGroup1.name;
        update testCase;
        
        testCase.Queue__c = newGroup.name;
        update testCase;
        
        testCase.isEscalated = true;
        update testCase;
        
        testCase.isEscalated = false;
        update testCase;
        clearAllList();
        test.stopTest();
    }
    
    
    /****************************************TestiQOVCases Methods***********************************************/
    static testMethod void TestiQOVCases()
    {
        test.startTest();
        User currentUser = [select id ,Username from User where Username like 'emailagent@omnitracs.com%' limit 1];
        RecordType recordTypeName = [select id,name from RecordType where name='Email Generated Cases' limit 1];
        /************************************Test-case:1*********************************************************/
        
        caseAccount.QWBS_Market__c='T&L Eastern Region';
        caseAccount.name='My Test';
        caseAccount.BillingStreet = '123 Main';
        caseAccount.BillingCity = 'San Diego';
        caseAccount.BillingState = 'CA';
        caseAccount.BillingCountry = 'USA';
        caseAccount.QWBS_Cust_ID__c='12101986';
        caseAccount.RFC_ID__c='29051986';
        update caseAccount;
        system.runAs(currentUser) 
        {
            testCase.Origin = 'Email-iQ OV Requests';
            testCase.RecordTypeId =recordTypeName.Id;
            testCase.Subject='reporting services access requested';
            testCase.Status = 'Open'; 
            testCase.Substatus__c ='In Progress';
            testCase.description = 'Customer ID: 4567 Customer Name: Test Customer Unit Type: MCP200 UA: 0099988 Op Profile Name: Test123 Date/Time of WIB Downgrade Notification: 5/28/10 4:55 PM';
            testCase.AccountId = caseAccount.Id;
            update testCase;
        }
        testCase.description = 'Customer ID: Customer Name: Test Customer Unit Type: MCP200 UA: 0099988 Op Profile Name: Test123 Date/Time of WIB Downgrade Notification: 5/28/10 4:55 PM';
        update testCase;
        
        /************************************Test-case:2*********************************************************/
        caseAccount.Name = 'SFDC'; 
        caseAccount.Type = 'Other'; 
        caseAccount.BillingStreet = 'Test Address'; 
        caseAccount.BillingCity = 'Test City'; 
        caseAccount.BillingCountry = 'Test Country'; 
        caseAccount.CSR__c = currentUser.Id;
        caseAccount.QWBS_Cust_ID__c = '4567';
        update caseAccount;
        
        Account newAccount1 = new Account(); 
        newAccount1.Name = 'SFDC'; 
        newAccount1.Type = 'Other'; 
        newAccount1.BillingStreet = 'Test Address'; 
        newAccount1.BillingCity = 'Test City'; 
        newAccount1.BillingCountry = 'Test Country'; 
        newAccount1.CSR__c = null;
        insert newAccount1;
        
        
        caseContact.FirstName='SFDC';
        caseContact.LastName='Salesforce';
        caseContact.AccountId = caseAccount.Id;
        update caseContact;
        
        system.runAs(currentUser) 
        {
            testCase.Origin = 'Email-iQ OV Requests';
            testCase.RecordTypeId =recordTypeName.Id;
            testCase.Subject='reporting services access requested';
            testCase.Status = 'Open'; 
            testCase.Substatus__c ='In Progress';
            testCase.description = 'Customer ID: 4567 Customer Name: Test Customer Unit Type: MCP200 UA: 0099988 Op Profile Name: Test123 Date/Time of WIB Downgrade Notification: 5/28/10 4:55 PM';
            testCase.ContactId = caseContact.Id;
            testCase.AccountId = null;
            update testCase;
            
            Case newCase2 = new Case();
            newCase2.Origin = 'Email-iQ OV Requests';
            newCase2.RecordTypeId =recordTypeName.Id;
            newCase2.Subject='reporting services access requested';
            newCase2.description = 'Customer ID:1234 Customer Name: Test Customer Unit Type: MCP200 UA: 0099988 Op Profile Name: Test123 Date/Time of WIB Downgrade Notification: 5/28/10 4:55 PM';
            
            newCase2.AccountID = caseAccount.Id; 
            newCase2.ContactID = null;
            insert newCase2; 
            newCase2.description = 'Customer ID: Customer Name: Test Customer1 Unit Type: MCP200 UA: 0099988 Op Profile Name: Test123 Date/Time of WIB Downgrade Notification: 5/28/10 4:55 PM';
            update newCase2;
            
            
            Case newCase1 = new Case();
            newCase1.Origin = 'Email-iQ OV Requests';
            newCase1.RecordTypeId =recordTypeName.Id;
            newCase1.Subject='reporting services access requested';
            newCase1.description = 'Customer ID: Customer Name: Test Customer Unit Type: MCP200 UA: 0099988 Op Profile Name: Test123 Date/Time of WIB Downgrade Notification: 5/28/10 4:55 PM';
            newCase1.ContactId = caseContact.Id;
            
            newCase1.description = 'Customer ID: Customer Name: Test Customer Unit Type: MCP200 UA: 0099988 Op Profile Name: Test123 Date/Time of WIB Downgrade Notification: 5/28/10 4:55 PM';
            insert newCase1; 
            newCase1.AccountId = caseAccount.Id;
            update newCase1; 
            
            testCase.Status = ''; 
            testCase.Substatus__c ='';
            update testCase; 
        }
        test.stopTest();
        /*****************************************Test-Case:3*****************************************************/
        
        caseAccount.Name = 'SFDC'; 
        caseAccount.Type = 'Other'; 
        caseAccount.BillingStreet = 'Test Address'; 
        caseAccount.BillingCity = 'Test City'; 
        caseAccount.BillingCountry = 'Test Country'; 
        caseAccount.CSR__c = null;
        caseAccount.QWBS_Cust_ID__c = '4567';
        
        update caseAccount;
        //Case newCase = new Case();
        list<Case> lstCase = new list<case>();
        
        caseAccount.QWBS_Market__c='T&L Eastern Region';
        caseAccount.name='My Test';
        caseAccount.BillingStreet = '123 Main';
        caseAccount.BillingCity = 'San Diego';
        caseAccount.BillingState = 'CA';
        caseAccount.BillingCountry = 'USA';
        caseAccount.QWBS_Cust_ID__c='12101986';
        caseAccount.RFC_ID__c='29051986';
        update caseAccount;
        
        system.runAs(currentUser) 
        {
            testCase.Origin = 'Email-iQ OV Requests';
            testCase.RecordTypeId =recordTypeName.Id;
            testCase.Subject='reporting services access requested';
            testCase.Status = 'Open'; 
            testCase.Substatus__c ='In Progress';
            testCase.description = 'Customer ID:4567 Customer Name: Test Customer Unit Type: MCP200 UA: 0099988 Op Profile Name: Test123 Date/Time of WIB Downgrade Notification: 5/28/10 4:55 PM';
            testCase.AccountId = newAccount1.Id;
            update testCase;
        }
        clearAllList();
        
    }
    
    /*************************************************TestShowSupportAlert methods*************************************/
    static void testShowSupportAlert()
    {
        // initializeData();
        /*******************************************Test-Method:1*****************************************/
        newSuppalert.Description__c = 'Test Descritpion';
        newSuppalert.End_Date__c =  date.today()+4;
        update newSuppalert;
        
        
        RecordType recTypeCallCenter = [Select Id from RecordType where name = 'Call Center' limit 1];
        RecordType recTypeOther = [Select Id from RecordType where name != 'Call Center' limit 1];
        
        testCase.Status = 'Open';
        testCase.Substatus__c ='In Progress';
        testCase.AccountId = caseAccount.Id;
        testCase.ContactID = caseContact.Id;
        update testCase;
        
        ApexPages.currentPage().getParameters().put('Id',testCase.Id);
        ApexPages.StandardController sdtCon = new ApexPages.StandardController(testCase);
        ShowSupportAlertController newObj = new ShowSupportAlertController(sdtCon);
        newObj.acctId  = caseAccount.Id;
        newObj.SaveandNew();
        newObj.redirectToNewCase();
        newObj.findSupportAlert();
        ApexPages.currentPage().getParameters().put('AccountId',caseAccount.Id);
        newObj.findRec();
        Apexpages.currentPage().getParameters().put('ContactId',caseContact.Id);
        newObj.findRec();
        Apexpages.currentPage().getParameters().put('NMCAccountId',caseNMCAccount.Id);
        newObj.findRec();
        newObj.redirectionOnEdit();
        Integer i = newObj.getTotalSuppAlert();
        newObj.setTotalSuppAlert(i);
        Apexpages.currentPage().getParameters().put('cas3_lkid',caseContact.Id);
        Apexpages.currentPage().getParameters().put('cas3',caseContact.Name);
        Apexpages.currentPage().getParameters().put('cas4',caseContact.Name);
        Apexpages.currentPage().getParameters().put('cas4_lkid',caseContact.AccountId);
        Apexpages.currentPage().getParameters().put('nmc',caseNMCAccount.ID); 
        newObj.redirectToNewCase();
        Apexpages.currentPage().getParameters().put('cas4',caseAccount.Name);
        Apexpages.currentPage().getParameters().put('cas4_lkid',caseAccount.Id);
        Apexpages.currentPage().getParameters().put('nmc',caseNMCAccount.ID); 
        newObj.redirectToNewCase();
        Apexpages.currentPage().getParameters().put('CF00N50000001cc33',caseNMCAccount.Name); 
        Apexpages.currentPage().getParameters().put('CF00N50000001cc33_lkid',caseNMCAccount.Id);
        Apexpages.currentPage().getParameters().put('cas4',caseAccount.Name);
        Apexpages.currentPage().getParameters().put('cas4_lkid',caseAccount.Id);
        Apexpages.currentPage().getParameters().put('nmc',caseNMCAccount.ID); 
        newObj.redirectToNewCase();
        
        for(Integer j=0; j<= 6;++j){
            Support_Alert__c newSupportAlert =  new Support_Alert__c();
            newSupportAlert.Account__c = caseAccount.Id;
            newSupportAlert.End_Date__c = NULL;
            newLstSupportAlert.add(newSupportAlert);
        }
        
        ShowSupportAlertController testController = new ShowSupportAlertController();
        testController.acctId = newLstSupportAlert.get(0).Account__c;
        testController.getLstSupportAlert();
        testController.getLstAllSupportAlert();
        testController.setLstSupportAlert(newLstSupportAlert);
        testController.setLstAllSupportAlert(newLstSupportAlert);
        
        Apexpages.currentPage().getParameters().put('CF00N50000001cc33',null);  
        Apexpages.currentPage().getParameters().put('CF00N50000001cc33_lkid',null);    
        
        newObj.redirectToNewCase();
        Apexpages.currentPage().getParameters().put('cas3_lkid',null);
        
        newObj.contId =  'testContId';
        newObj.findRelAccount();
        newObj.Save();
        //SK newObj.findAccount();
        Boolean shwSuppAlert = newObj.testTemplate(recTypeCallCenter.Id);
        Template__c newTemplate1 = new Template__c();
        Templatedetail__c newTempDetail2 = new Templatedetail__c();
        newTemplate1.Name = 'Test Template';
        newTemplate1.IsActive__c = true;
        newTemplate1.NumTotal__c = 2;
        insert newTemplate1;
        
        /*********************Insert TemplateDetail Record **************************/
        newTempDetail2.TemplateID__c = newTemplate1.Id;
        newTempDetail2.Name = 'RecordTypeId';
        newTempDetail2.Value__c = '01250000000DT5tAAG';
        insert newTempDetail2;
        newObj.findCase(newTemplate1.Id);
        clearAllList();
        
    }
    
    /*******************************************TestSysOutageAll Methods*******************************************/
    static testMethod void TestSysOutageAll()
    {
        
        test.startTest();
        testCase.Priority = '2-Medium';
        update testCase;
        
        for(integer i=0;i<200;i++)
        {
            System_Outage__c newSysOut = new System_Outage__c();
            newSysOut.Case__c = testCase.Id;
            newSysOut.Type__c = 'Degraded Service';
            newSysOut.System__c = 'NMC';
            newSysOut.SubSystems__c = 'BGW200';
            newSysOut.Start_Time__c = system.now()+i;
            newlstSysOutage.add(newSysOut);
        }
        insert newlstSysOutage;
        clearAllList();
        test.stopTest();
    }
    
    
    /*******************************************End of TestSysOutageAll Methods*******************************************/
    
    /*******************************************CaseValidation Utils Test*******************************************/
    static testmethod void TestCaseValidationUtils()
    {
        test.startTest();
        //CaseValidationUtils newObj = new CaseValidationUtils();
        //CaseValidationUtils.checkIfNMCAccountNumberexists(testCase);
        //CaseValidationUtils.validateDefaultNMCSetForInactive(testCase);
        CaseValidationUtils.validateNMCAndAddlNMCAccountUnit(testCase);
        //CaseValidationUtils.validateDefaultUnitType(testCase);
        //CaseValidationUtils.validateAddlNMCAccountIsDiffThanNMCAccount(testCase);
        CaseValidationUtils.checkIfNMCAccountIsUnique(new List<Case>{testCase});
        CaseValidationUtils.validateAddlNMCAccountIsUnique(new List<Case>{testCase});
        //CaseValidationUtils.validateUnitTypesNotAlreadyExists(testCase,caseAccount.Id,true);
        //CaseValidationUtils.validateDefaultNMCAcccountSelected(testCase);
        
        testCase.NMC_Account__c = caseNMCAccount.Id;
        testCase.NMC_Account_Status__c = QESConstants.INACTIVE;
        testCase.Addl_NMC_Account_Status__c = QESConstants.INACTIVE;
        testCase.Addl_Default_NMC_Account_for_Unit_Type__c = 'OmniExpress';
        testCase.Default_NMC_Account_for_Unit_Type__c = 'OmniExpress';
        testCase.Addl_NMC_Account_Number__c = '123456';
        testCase.NMC_Account_Number__c = '123456';
        update testCase;
        CaseValidationUtils.validateNMCAndAddlNMCAccountUnit(testCase);
        //CaseValidationUtils.validateDefaultNMCSetForInactive(testCase);
        CaseValidationUtils.validateAdditionalNMCAccount(testCase);
        CaseValidationUtils.validateDefaultUnitType(testCase);
        //CaseValidationUtils.validateAddlNMCAccountIsDiffThanNMCAccount(testCase);
        CaseValidationUtils.validateAddlNMCAccountIsUnique(new List<Case>{testCase});
        CaseValidationUtils.validateUnitTypesNotAlreadyExists(new List<Case>{testCase},true);
        CaseValidationUtils.validateUnitTypesNotAlreadyExists(new List<Case>{testCase},true);
        CaseValidationUtils.validateAddlNMCAccountIsUnique(new List<Case>{testCase});
        
        testCase.NMC_Account_Status__c = '';
        update testCase;
        
        //CaseValidationUtils.validateDefaultNMCSetForInactive(testCase);
        test.stopTest();
    }
    
    /*******************************************CaseUtils Test*******************************************/
    static testmethod void testCaseUtils()
    {
        /****************************test for changeOwner() as the trigger calling this method is inactive**********/
        map<Id,String> mapCaseCustId = new map<Id,String>();
        String subject ='caseTest';
        mapCaseCustId.put(testCase.Id,caseAccount.QWBS_Cust_ID__c);
        CaseUtils.changeOwner(mapCaseCustId);
        caseAccount.QWBS_Cust_ID__c ='ased12345';

        update caseAccount;
        mapCaseCustId.clear();
        mapCaseCustId.put(testCase.Id,caseAccount.QWBS_Cust_ID__c);
        CaseUtils.changeOwner(mapCaseCustId);
        CaseUtils.checkIfIQCaseToBeAssignedToCSR(subject);
        Set<Id> CaseIds = new Set<Id>();
        CaseIds.add(testCase.Id);
        
        test.startTest();
        //CaseUtils.updateS2SAccountId(CaseIds);
        test.stopTest();
        /****************************End of test for changeOwner() as the trigger calling this method is inactive**********/
        
        /*********************************For Catch Statements**************************************************/
        /*Exception e = new exception();
throw e;*/
        
    }
    /*******************************************End ofCaseUtils Test*******************************************/
    
    /*******************************************Populate Account Team Test*******************************************/
    static testmethod void testPopulateAccountTeam()
    {
        testCase.recordtypeid = '01250000000DkBT';//EOX Return Case
        update testCase;
    }
    /*******************************************End of Populate Account Team Test*******************************************/
}