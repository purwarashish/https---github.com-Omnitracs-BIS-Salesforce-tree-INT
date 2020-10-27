@isTest
private class TestReportCustomReportsNavigation {

    static testMethod void ReportNavigationUnitTest() {
 
        //Test Page Reference
        PageReference pageRef = Page.ReportCustomReportNavigation;
        Test.setCurrentPage(pageRef);  
        
        //Test Controller methods
        ReportCustomReportsNavigation testController = new ReportCustomReportsNavigation();
           
        testController.gotoOptyReport();
        
    }
}