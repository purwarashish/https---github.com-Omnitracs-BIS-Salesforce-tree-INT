@isTest 
private class QESPKBModelerTest
{
 public static testMethod void QESPKBModelerTest()
 {
    QES_Unity_Site_Setup_del__c testQUSiteSetUp = new QES_Unity_Site_Setup_del__c();
    testQUSiteSetUp.Site_Title__c = 'TestSite'; 
    testQUSiteSetUp.Site_Name__c = 'TestSite';
    testQUSiteSetUp.Page_size__c = 12;
    insert testQUSiteSetUp;
    QESPKBModeler testclass = new QESPKBModeler();
    
  /*  QES_Unity_PKB_Article_Type__c testQUPArticleType = new QES_Unity_PKB_Article_Type__c();
    testQUPArticleType.Ordinal__c = 1;
    testQUPArticleType.Article_Object_Name__c = 'Test';
    testQUPArticleType.Article_Type_Name__c ='Documentation';
    insert testQUPArticleType;
    */
    QES_Unity_Category_Group__c  testQUCategoryGrp = new  QES_Unity_Category_Group__c(); 
         
    testQUCategoryGrp.Root_Category__c = 'All';
    testQUCategoryGrp.Ordinal__c =1;
    testQUCategoryGrp.Level_or_Depth__c =1;
    testQUCategoryGrp.Category_Group_Name__c = 'Application';
    testQUCategoryGrp.Category_Group_Label__c ='Application';
    testQUCategoryGrp.Ancestors_Of__c ='All';
    testQUCategoryGrp.Show_On_Navbar__c = true;
    testQUCategoryGrp.QES_Unity_Site_Setup__c = testQUSiteSetUp.Id;
    insert testQUCategoryGrp;
     
   /*  QESUnityTopArticle testQESUPTopArticle = new QESUnityTopArticle();
    //testQESUPTopArticle.Ordinal__c = 110;
    //testQESUPTopArticle.Article_Type__c = 'Documentation';
    testQESUPTopArticle.Inactive__c = false;
    testQESUPTopArticle.Article_Name__c = 'test';
    testQESUPTopArticle.Article_Id__c = 'kA050000000GmtG';
    testQESUPTopArticle.Article_Summary__c = 'test';
    insert testQESUPTopArticle ; */
      
    QESPKBModeler testObj = new QESPKBModeler ();
    testObj.currentKeyword = 'Search Answer Center';
    testObj.doQESSearch();
    testObj.redirectToSearchUnity();    
    //testObj.addToCurrentCategoryFilter('Application');
    testObj.clearAllFilters();
    testObj.getFiltersFound();
    testObj.getQESSearchUrl();
    testObj.getQESListViewUrl(); 
                                       
    QESPKBModeler testObj1 = new QESPKBModeler ();
    testObj1.currentKeyword = 'Search Answer Center';
    testObj1.doQESSearch();
    testObj1.currentKeyword = null;
    testObj1.currentCategory = null;
    testObj1.getFiltersFound();
    
    ApexPages.StandardController sc;
    testObj1 = new QESPKBModeler();    
    testObj1.getQESCurrentCategory();  
    testObj1.getCategoryFilters(); 
    String noFilterLabel = testObj1.noFilterLabel;
    String noFilterValue = testObj1.noFilterValue;
    String articleBaseUrl = testObj1.articleBaseUrl;
    String siteUrl = testObj1.siteUrl;
    Integer QESCurrentPageNumber = testObj1.QESCurrentPageNumber;
    testObj1.searchPerformed = true;
    QESCurrentPageNumber = testObj1.QESCurrentPageNumber;
    testObj1.currentCategory = 'TestFilterValue';
    String getCategoryFilters = testObj1.getCategoryFilters();
    testObj1.setCategoryFilters('TestFilter');
    
  /*  QES_Unity_Portal_Notification__c testUnityPortal = new QES_Unity_Portal_Notification__c();
    testUnityPortal.Name = 'newTest';
    testUnityPortal.Notification_1__c = 'NewTestNotification1';
    testUnityPortal.Notification_2__c = 'NewTestNotification2';
    testUnityPortal.Notification_4__c = 'NewTestNotification4';
    insert testUnityPortal;
    testObj1 = new QESPKBModeler();
    testUnityPortal.Notification_3__c = 'test notification';
    testUnityPortal.Notification_5__c = 'test notification ';
    update testUnityPortal;
    testObj1 = new QESPKBModeler();
    testUnityPortal.Notification_3__c = ' ';
    testUnityPortal.Notification_5__c = ' ';
    update testUnityPortal;
    testObj1 = new QESPKBModeler(); */
    
    
    PageReference pageRef = Page.Support;
    Test.setCurrentPage(pageRef);
    QESPKBModeler testObj2 = new QESPKBModeler();
    String sortByClause = testObj2.sortByClause;
    testObj2.currentKeyword = 'TestingForNotNull';
    sortByClause = testObj2.sortByClause;
    testObj2.currentCategory = 'TestingForNotNull';
    Set<String> selectedCategoryNames = testObj2.selectedCategoryNames;
    //List<QESUnityTopArticle> listPKBTopArticles = QESPKBModeler.listPKBTopArticles;
    
    testObj2.searchCriteria = 'Test Search: Criteria:None';
    pageRef = testObj2.doQESSearch();
    testObj2.showTopArtciles = true;
    testObj2.searchCriteria = 'NONE:NONE';
    pageRef = testObj2.doQESSearch();
    testObj2.searchMap.put('NONE','NONE');
    pageRef = testObj2.doQESSearch();
    testObj2.searchkeyword = 'Search Answer Center';
    pageRef = testObj2.redirectToSearchUnity();
    
        
    PageReference pageRef1 = ApexPages.currentPage();
    pageRef1.getParameters().put('k', 'k');
    QESPKBModeler testObj3 = new QESPKBModeler();
    
    
    //nextPage = controller.save().getUrl();
  
    //Verify that the success page displays
    //System.assertEquals('/apex/success', nextPage);
    
 }
}