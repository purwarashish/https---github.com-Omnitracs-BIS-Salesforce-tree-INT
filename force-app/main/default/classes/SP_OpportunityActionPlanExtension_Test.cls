@isTest(SeeAllData=true)
public class SP_OpportunityActionPlanExtension_Test {
    public static testMethod void testOpportunityActionPlanController() {
        String testString;
        Test.startTest();
        Id PRODUCTSANDSERVRTYPE = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Products, Services and Maintenance').getRecordTypeId();
        List<Account> acctList = TestDataFactory.createAcctList(1, 'SP Opportunity ActionPlan Extension Account Test');
        Account acc = acctList[0];
        insert acc;
        
        List<Contact> conList = TestDataFactory.createConList(1, 'LastName');
        Contact con = conList[0];
        con.AccountId = acc.Id;
        insert con;
        
        Opportunity opp = new Opportunity(Name='asdasd',RecordTypeId=PRODUCTSANDSERVRTYPE,stagename='1 - Plan', closedate=Date.today(), AccountId=acc.Id);
        system.debug('@opp'+opp);
        insert opp;
        
        Stage_Objective__c testStageObject = new Stage_Objective__c(name='1 - Plan');
        testStageObject.Opportunity_Record_Type__c = 'Products, Services and Maintenance';
        insert testStageObject;
        
        Objective_Action__c testObjectiveAction = new Objective_Action__c();
        testObjectiveAction.Stage_Objective__c = testStageObject.Id;
        testObjectiveAction.Opportunity_Record_Type__c = 'Products, Services and Maintenance';
        testObjectiveAction.Name = 'Discover?';
        insert testObjectiveAction;
        
        SP_Exempt_Products__c testExmp = new SP_Exempt_Products__c();
        testExmp.Name = 'test1';
        insert testExmp;
        
        SP_Exempt_Products__c testExmp2 = new SP_Exempt_Products__c();
        testExmp2.Name = 'test2';
        insert testExmp2;
        
        
        Test.setCurrentPageReference(new PageReference('/apex/SP_OpportunityActionPlan'));
        System.currentPageReference().getHeaders().put('X-Salesforce-Forwarded-To','test.test');
        SP_OpportunityActionPlanExtension testAction = new SP_OpportunityActionPlanExtension();
        SP_OpportunityActionPlanExtension testExtension = new SP_OpportunityActionPlanExtension(new ApexPages.StandardController(opp));
        testString = testExtension.blockTitle;
        boolean testBool = testExtension.showTitle;
        Boolean prodExempt = testExtension.allProductsExempt;
        Boolean isMgr = true;
        String curOpp = testExtension.curOppStage;
        List<SelectOption> testOptions = testExtension.stages;
        testOptions = testExtension.viewOptions;
        List<SP_OpportunityActionManager.Objective> testObjectives = testExtension.stageObjectives;
        
        SP_OpportunityActionManager.Objective objective = testExtension.advancementCriteria;
        
        testExtension.saveActions();
        testExtension.queryOppActions(opp);
        testExtension.selectedObjId = testStageObject.Id;
        testExtension.mgrEmail = 'test@nomail.com';
        testExtension.cancelActions();
        testExtension.FSMapFunc();
        testExtension.closeMgrDialog();
        testExtension.showMgrDialog();
        testExtension.requestCoaching();
        testExtension.requestCoachingNoMgr();
        testExtension.coachingInfo();
        
        
       //testExtension.saveActions();
        SP_OpportunityActionPlanExtension.checkExemptProducts('test1;test2');
        testExtension.currentView = 'commit';
        test.stopTest();
        SP_OpportunityActionPlanExtension.createCoachingTask(opp.id,'1 - Plan', UserInfo.getUserId());
    }
}