@isTest(seeAllData=true)
private class RecentCasesTest
{
    public static testMethod void RecentCasesTest()
    {
        
        CaseTestData caseTestData  = new CaseTestData();
        
        //insert Account
        List<Account> accountList = caseTestData.CreateAcccount('RecentCasesTest', null, 1, null);
        insert accountList;
        //Insert Contact
        List<Contact> contactList =  caseTestData.CreateContact('RecentCasesTest', 1, accountList.get(0).id);
        insert contactList;
        //insert test user
        Profile testProfile=[select id from profile where Name = 'Customer Portal Community User'];
        List<User> TestUserList = caseTestData.CreateUser('RecentCasesTest', testProfile.id, 'TestCaseUser', contactList.get(0).id, 1);
        Insert TestUserList;
        
        List <User> lstUser1 = [SELECT Id, ContactId FROM User where Id = :UserInfo.getUserId() LIMIT 1];
        //Test.startTest();   
        //System.runAs(TestUserList.get(0))
        {
        List<Case> testCaseList = new List<Case>();
        Case testCase_1 = new Case();
        testCase_1.status = 'Working';
        testCaseList.add(testCase_1);
        Case testCase_2 = new Case();
        testCase_2.status = 'Working';
        testCaseList.add(testCase_2);
        insert testCaseList;
        testCaseList.clear();
        
        Case testCase_3 = new Case();
        testCase_3.status = 'Open';
        testCase_3.ContactId =lstUser1[0].ContactId;
        //testCase_3.ContactId = TestUserList.get(0).ContactId;
        testCase_3.Subject ='ccc1';
        testCase_3.Origin = 'Customer Portal';
        testCaseList.add(testCase_3);
        Case testCase_4 = new Case();
        testCase_4.status = 'Open';
        testCaseList.add(testCase_4);
        Case testCase_5 = new Case();
        testCase_5.status = 'Open';
        testCase_5.ContactId =lstUser1[0].ContactId;
        //testCase_5.ContactId =TestUserList.get(0).ContactId;
        testCase_5.Subject ='ccc1';
        testCase_5.Origin = 'Customer Portal';
        testCaseList.add(testCase_5);        
        insert testCaseList;
        testCase_5.status = 'Closed';
        testCase_5.Resolution__c = 'Test Resolution Sample Data1';
        testCase_5.Description = 'Test Description Sample Data1';
        
        update testCase_5;
        
        Test.startTest();
        Test.setMock(WebServiceMock.class, new QESUnitySuperLinkWebServicesMock());
        RecentCasesModeler testRC_1 = new RecentCasesModeler();
        List<SelectOption> testListSelectOption_1 = testRC_1.getCaseViews();
        PageReference testPageRef = Page.supportcases;
        testRC_1.AllOpenCases.clear();
        testRC_1.setCaseCache(new CaseCacheManager());
        
        testPageRef = testRC_1.displayrecentCase();
        testRC_1.abc = 'All Open Cases'; 
        // testRC_1.Id = '500P0000002De58';
        testPageRef = testRC_1.displayrecentCase();
        testRC_1.redirectToCaseDetail();
        testRC_1.redirectToArticles();
        testRC_1.refreshInitializationData();
        
        
        
        testRC_1.abc = 'All Open Cases';
        // testRC_1.Id = '500P0000002De58';
        testPageRef = testRC_1.displayrecentCase();
        
        testRC_1.abc = 'All Closed Cases';
        testPageRef = testRC_1.displayrecentCase();
        
        
        
        testRC_1.abc = 'All Closed Cases';
        testPageRef = testRC_1.displayrecentCase();
        testRC_1.getTopArticlesList();
        
        RecentCasesModeler testRC_2 = new RecentCasesModeler(new CaseCacheManager());
		testRC_2.getSuggestedSolutionsList();
        testRC_2.displayrecentCase();
        
        //ApexPages.StandardController testStdCtrlr;
        // testRC_1 = new RecentCasesModeler(testStdCtrlr);
        
        //CaseCacheManager testStdCtrlr= new ApexPages.StandardController(testCase_1 ); 
        //RecentCasesModeler PMO = new RecentCasesModeler(testStdCtrlr);
        
        }
        Test.stopTest();
        
    }
    
}