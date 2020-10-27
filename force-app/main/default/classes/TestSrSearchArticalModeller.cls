@isTest(SeeAllData = true)
private class TestSrSearchArticalModeller{
    private static testMethod void testArticlemodeller()
    {
        QES_Unity_Site_Setup_del__c testQUSiteSetUp = new QES_Unity_Site_Setup_del__c();
        testQUSiteSetUp.Site_Title__c = 'TestSite'; 
        testQUSiteSetUp.Site_Name__c = 'TestSite';
        testQUSiteSetUp.Page_size__c = 12;
        insert testQUSiteSetUp;
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
        
        SrSearchArticalModeller testObj = new SrSearchArticalModeller ();
        testObj.currentKeyword = 'Search Answer Center';
        testObj.doQESSearch();
        testObj.clearAllFilters();
        testObj.getFiltersFound();
       
       
       
       SrSearchArticalModeller testObj1 = new SrSearchArticalModeller();
        testObj1.currentKeyword = 'Type Questions or Keywords';
        testObj1.doQESSearch();
        testObj1.currentKeyword = null;
        testObj1.currentCategory = null;
        testObj1.getFiltersFound();
       
       
       SrSearchArticalModeller testObj2 = new SrSearchArticalModeller();
       
       testObj2.currentKeyword = 'TestingForNotNull';
      
       testObj2.currentCategory = 'TestingForNotNull';
       testObj2.setCategoryFilters('Application');
       testObj2.getCategoryFilters();
       Set<String> selectedCategoryNames = testObj2.selectedCategoryNames;
       testObj2.searchCriteria = 'Test Search: Criteria:None';
       testObj2.doQESSearch();
       testObj2.searchCriteria = 'NONE:NONE';
       testObj2.doQESSearch();
       testObj2.searchMap.put('NONE','NONE');
       testObj2.searchMap.put('application','all');
       testObj2.incrementPageNumber();
       testObj2.decrementPageNumber(); 
       
       PageReference pageRef1 = ApexPages.currentPage();
       pageRef1.getParameters().put('k', 'k');
       SrSearchArticalModeller testObj3 = new SrSearchArticalModeller(); 
        
        
    } 
}