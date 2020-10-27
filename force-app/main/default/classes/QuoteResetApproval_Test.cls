@isTest(SeeAllData=true)
public without sharing class QuoteResetApproval_Test {
  
    static testMethod void allTestMethodTest(){
        Account a = TestUtils.getAccount('ut1 Acc');
        insert a;

        Contract ctrct = TestUtils.getContract(a);
        insert ctrct;
        
        Test.startTest();
        Opportunity oppty = TestUtils.getOpportunity(a, 'UT Oppty1');
        oppty.Contract__c = ctrct.id;
        oppty.Type = 'New Customer';
        oppty.Order_Type__c = 'New';
        oppty.StageName = 'Sales Acceptance';
        oppty.Legal_Review__c = '';
        oppty.Finance_Status__c = '';
        oppty.Type_of_Competitor__c='No Competitor';
        insert oppty;
        
        SBQQ__Quote__c Sq = new SBQQ__Quote__c();
        sq.SBQQ__Distributor__c=a.id;
        sq.SBQQ__Opportunity2__c=oppty.id;
        sq.SBQQ__Status__c='Draft';
        
        insert sq;
        
        ApexPages.StandardController sc = new ApexPages.StandardController(Sq);
        QuoteResetApproval testAccPlan = new QuoteResetApproval(sc);
        
        PageReference pageRef = Page.ResetApprovalStatus;
        pageRef.getParameters().put('id', String.valueOf(Sq.Id));
        Test.setCurrentPage(pageRef);
        testAccPlan.goBack();
        testAccPlan.ResetApproval();
        Test.stopTest(); 
    }
    
    
}