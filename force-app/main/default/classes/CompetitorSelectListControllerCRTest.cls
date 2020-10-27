/*******************************************************************************
 * File:  		CompetitorSelectListControllerCRTest.cls
 * Date:  		September 20th, 2018
 * Author:  	Sai Krishna Kakani
 * Description: test class for apex class CompetitorSelectListControllerCR
 * *******************************************************************************/
@istest(SeeAllData=True) 
public class CompetitorSelectListControllerCRTest {
    public static testMethod void TestCRCompetitor() {
       
        Account a = TestUtils.getAccount('ut1 Acc');
        insert a;
        
        Competitor__c cmp = new Competitor__c ();
        cmp.Name = 'Test Competitor';
        insert cmp;
        
        
        
        Call_Report__c CallReport = new Call_Report__c(
        	Account__c= a.Id,
        	Status__C = 'Draft',
            Date__c = system.today(),
            QWBS_Attendees__c = 'TEST Attendees',
          	Customer_Attendees__c = 'Customer Attendees Test',
            Purpose__c = 'Business Development',
            Method__c = 'Phone',
        	Type_of_Competitor__c='Competitive Takeaway');
        insert CallReport;
        
        Call_Report__c CallReportN = new Call_Report__c(
        	Account__c= a.Id,
        	Status__C = 'Draft',
            Date__c = system.today(),
            QWBS_Attendees__c = 'TEST Attendees1',
          	Customer_Attendees__c = 'Customer Attendees1 Test',
            Purpose__c = 'Business Development',
            Method__c = 'Phone',
        	Type_of_Competitor__c='No Competitor');
        insert CallReportN;
        
        Competitive_Threat__c cIS = new Competitive_Threat__c ();
        cIS.Competitor_Name__c = cmp.id;
        cIS.Account__c = a.id;
        insert cIS;
        
        Competitive_Summary__c csm = new Competitive_Summary__c ();
        csm.Call_Report__c = CallReport.id;
        csm.Competitive_Intelligence__c = cIS.Id;
        insert csm;
     
        Test.startTest();
        ApexPages.StandardController SC = new ApexPages.StandardController(CallReport);
        ApexPages.StandardController SCN = new ApexPages.StandardController(CallReportN);
        CompetitorSelectListControllerCR controller = new CompetitorSelectListControllerCR(SC);
        CompetitorSelectListControllerCR controllerN = new CompetitorSelectListControllerCR(SCN);
        PageReference pageRef = Page.CompetitorSelectListControllerCR;
        pageRef.getParameters().put('id', String.valueOf(CallReport.Id));
        system.Test.setCurrentPage(pageRef);
        controller.save(); 
                list<string> stringlist  =  new list<string> ();
        stringlist.add('test');
        controller.rightselectedlist = stringlist;
		controller.removeMembers();
		controller.addMembers();
		controller.getSelectedOptionValues();
        controller.input = 'Test';
		controller.find();
		controller.getUnSelectedValues();
		controller.getCurrentCompetitors();
		//controller.queryOpportunity();
		controller.cancel();
		controller.competitorLink();
                controller.disabledType = true;
        controller.competitorLink();
    }
           
}