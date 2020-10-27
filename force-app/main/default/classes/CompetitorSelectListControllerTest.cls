/*******************************************************************************
 * File:  		CompetitorSelectListControllerTest.cls
 * Date:  		September 20th, 2018
 * Author:  	Sai Krishna Kakani
 * Description: test class for apex class CompetitorSelectListController
 * *******************************************************************************/
@istest(SeeAllData=True) 
public class CompetitorSelectListControllerTest {
	public static testMethod void TestOppCompetitor() {
		Account a = TestUtils.getAccount('ut1 Acc');
        insert a;

        Contract ctrct = TestUtils.getContract(a);
        insert ctrct;
        
        Competitor__c cmp = new Competitor__c ();
        cmp.Name = 'Test Competitor';
        insert cmp;
        
       
       
        Opportunity oppth = new Opportunity(Name = 'CompTestSept20-1',
        Contract__c = ctrct.id,
        Type = 'New Customer',
        CloseDate = system.today(),
        Order_Type__c = 'New',
        StageName = 'Sales Acceptance',
        Type_of_Competitor__c='Competitive Threat');
        insert oppth;
        
        
        Opportunity opptn = new Opportunity(Name = 'CompTestSept2-2',
        Contract__c = ctrct.id,
        Type = 'New Customer',
        CloseDate = system.today(),
        Order_Type__c = 'New',
        StageName = 'Sales Acceptance',
        Type_of_Competitor__c='No Competitor');
        insert opptn;
        
        Opportunity oppty = new Opportunity(Name = 'CompTestSept20',
        Contract__c = ctrct.id,
        Type = 'New Customer',
        CloseDate = system.today(),
        Order_Type__c = 'New',
        StageName = 'Sales Acceptance',
        Type_of_Competitor__c='Competitive Takeaway');
        insert oppty;
        
        Competitive_Threat__c cIS = new Competitive_Threat__c ();
        cIS.Competitor_Name__c = cmp.id;
        cIS.Account__c = a.id;
        insert cIS;
        
         Competitive_Summary__c csm = new Competitive_Summary__c ();
        csm.Opportunity__c = oppty.id;
        csm.Competitive_Intelligence__c = cIS.Id;
        insert csm;
        
        Test.startTest();
        ApexPages.StandardController SC = new ApexPages.StandardController(oppty);
        ApexPages.StandardController SCh = new ApexPages.StandardController(oppth);
        ApexPages.StandardController SCn = new ApexPages.StandardController(opptn);
        CompetitorSelectListController controller = new CompetitorSelectListController(SC);
        CompetitorSelectListController controllerh = new CompetitorSelectListController(SCh);
        CompetitorSelectListController controllern = new CompetitorSelectListController(SCn);
        CompetitorSelectListController controllerT = new CompetitorSelectListController ();
        PageReference pageRef = Page.CompetitorSelectListController;
        pageRef.getParameters().put('id', String.valueOf(oppty.Id));
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
        
        controller.competitorLink();
        test.stoptest();
    }
}