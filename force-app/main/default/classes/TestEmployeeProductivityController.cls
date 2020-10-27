@isTest(SeeAllData = true)
public With Sharing class TestEmployeeProductivityController
{
    public static testmethod  void verifyMethods()
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
        
        EmployeeProductivityController testEmpProd = new EmployeeProductivityController();
        String BusinessUnit;
        
        Boolean isLead = testEmpProd.isLead;
        User loggedInUser = testEmpProd.loggedInUser;
        Case_Team__c loggedInCaseTeam = testEmpProd.loggedInUserCaseTeam;
        
        testEmpProd.businessUnitUserChoice = 'All';
        System.AssertEquals(testEmpProd.variablePageBlockSectionTitle,'Omnitracs / XRS');
        
        testEmpProd.businessUnitUserChoice =  'Omnitracs';
        System.AssertEquals(testEmpProd.variablePageBlockSectionTitle,'Omnitracs');
        
        testEmpProd.businessUnitUserChoice =  'XRS';
        System.AssertEquals(testEmpProd.variablePageBlockSectionTitle,'XRS');
        
        testEmpProd.businessUnitUserChoice =  'Others';
        System.AssertEquals(testEmpProd.variablePageBlockSectionTitle,'Omnitracs');
        
        isLead = true;
        testEmpProd.refresh();
        
        testEmpProd.businessUnitUserChoice = 'All';
        testEmpProd.refresh();
        
        List<Employee_Productivity__c> lstCumulativeData = new List<Employee_Productivity__c>();
        
        lstCumulativeData = testEmpProd.roadnetPrimarySupport;
        lstCumulativeData = testEmpProd.roadnetStrategicSupport;
        lstCumulativeData = testEmpProd.RobinsonTier1;
        lstCumulativeData = testEmpProd.RobinsonTier2;
        lstCumulativeData = testEmpProd.loweTier1;
        lstCumulativeData = testEmpProd.loweTier2;
        lstCumulativeData = testEmpProd.featherTier1;
        lstCumulativeData = testEmpProd.featherTier2;
        lstCumulativeData = testEmpProd.jacobsTier0;
        lstCumulativeData = testEmpProd.jacobsTier1;
        lstCumulativeData = testEmpProd.jacobsTier2;
        lstCumulativeData = testEmpProd.bolhmanTier1;
        lstCumulativeData = testEmpProd.bolhmanTier2;
        
        testEmpProd.verifyUserIsApartOfCaseTeam();
        
        Database.rollback(sp);
        
        
    }
}