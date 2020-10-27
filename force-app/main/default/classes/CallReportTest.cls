@istest(SeeAllData=True) 
public class CallReportTest {
    public static testmethod void init () {
        Account a = TestUtils.getAccount('ut1 Acc');
        insert a;
        Call_Report__c cr = new Call_Report__c ();
        cr.Account__c = a.id;
        cr.Type_of_Competitor__c = 'Competitive Takeaway';
        cr.status__c ='Draft';
        insert cr;
        Competitor__c cmp = new Competitor__c ();
        cmp.Name = 'Test Competitor';
        insert cmp;
        Competitive_Threat__c cIS = new Competitive_Threat__c ();
        cIS.Competitor_Name__c = cmp.id;
        cIS.Account__c = a.id;
        insert cIS;
        Competitive_Summary__c csm = new Competitive_Summary__c ();
        csm.Call_Report__c = cr.id;
        csm.Competitive_Intelligence__c = cIS.Id;
       // insert csm;
        Test.starttest();
        cr.Meeting_Objective_Agenda__c = 'test';
        cr.status__c='Completed';
        
        cr.Meeting_Summary__c = 'Test';
        cr.Next_Objective_Strategy__c= 'Test';
        cr.Operations_IT_Maintenance__c= 'Test';
        update cr;
        Test.stoptest();
    }
    
    public static testmethod void initWithCS () {
        Account a = TestUtils.getAccount('ut1 Acc');
        insert a;
        Call_Report__c cr = new Call_Report__c ();
        cr.Account__c = a.id;
        cr.Type_of_Competitor__c = 'Competitive Takeaway';
        cr.status__c ='Draft';
        insert cr;
        Competitor__c cmp = new Competitor__c ();
        cmp.Name = 'Test Competitor';
        insert cmp;
        Competitive_Threat__c cIS = new Competitive_Threat__c ();
        cIS.Competitor_Name__c = cmp.id;
        cIS.Account__c = a.id;
        insert cIS;
        Competitive_Summary__c csm = new Competitive_Summary__c ();
        csm.Call_Report__c = cr.id;
        csm.Competitive_Intelligence__c = cIS.Id;
        insert csm;
        Test.starttest();
        cr.Meeting_Objective_Agenda__c = 'test';
        cr.status__c='Completed';
        
        cr.Meeting_Summary__c = 'Test';
        cr.Next_Objective_Strategy__c= 'Test';
        cr.Operations_IT_Maintenance__c= 'Test';
        update cr;
        Test.stoptest();
    }
}