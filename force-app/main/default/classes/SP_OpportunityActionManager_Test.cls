@isTest(seeAllData = true)
public class SP_OpportunityActionManager_Test{
    public static testMethod void testOpportunityActionManagerClass(){
    	List<Account> acctList = TestDataFactory.createAcctList(1, 'SP Account Manager Account Test');
		Account acc = acctList[0];
		insert acc;
    	List<Contact> conList = TestDataFactory.createConList(1, 'LastName');
		Contact con = conList[0];
		con.AccountId = acc.Id;
        insert con;
        Id PRODUCTSANDSERVRTYPE = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Products, Services and Maintenance').getRecordTypeId();
        Opportunity opp = new Opportunity(Name='asdasd',RecordTypeId=PRODUCTSANDSERVRTYPE,stagename='Prospecting', closedate=Date.today(), Contact__c=con.Id, AccountId=acc.Id);
        system.debug('@opp'+opp);
        insert opp;
        
        Stage_Objective__c testStageObject = new Stage_Objective__c(name='Prospecting');
        testStageObject.Opportunity_Record_Type__c = 'Products, Services and Maintenance';
        insert testStageObject;
        
        Objective_Action__c testObjectiveAction = new Objective_Action__c();
        testObjectiveAction.Stage_Objective__c = testStageObject.Id;
        testObjectiveAction.Opportunity_Record_Type__c = 'Products, Services and Maintenance';
        insert testObjectiveAction;
        
        List<Stage_Objective__c> testListStageObjective = new List<Stage_Objective__c>(); 
        testListStageObjective.add(testStageObject);
        List<Task> testListTask = new list<Task>();
        Task testTask = new Task();
  
        //insert testTask;
        
        Map<Id,Objective_Action__c> testMap = new Map<Id,Objective_Action__c>();
        Id testId;
        //OpportunityActionManager main class
        SP_OpportunityActionManager testOpportunityActionManager = new SP_OpportunityActionManager(testListStageObjective, testListTask, testMap, opp.Id);
        list<Task> opActs = testOpportunityActionManager.oppActions;
        if(testOpportunityActionManager.stageObjectives == null){}
        testOpportunityActionManager.clear();
        if(testOpportunityActionManager.commitObjectives == null){}
        if(testOpportunityActionManager.advancementCriteria == null){}
        testOpportunityActionManager.resetTasks(testListTask);
        //Objective inner class
        //system.debug('@Select Id,contact__c,Name,StageName,RecordTypeId from Opportunity'+[Select Id,contact__c,Name,StageName,RecordTypeId from Opportunity]);
        Id conId = [Select Id,contact__c,Name,StageName,RecordTypeId from Opportunity where Id =: opp.Id].contact__c;
        
        SP_OpportunityActionManager.Objective testObjective = new SP_OpportunityActionManager.Objective(testStageObject, opp.Id,conId);
        if(testObjective.actions == null){}
        if(testObjective.isEmpty){}
        testObjective.add(testTask,testObjectiveAction,0);
        //Action inner class
        SP_OpportunityActionManager.Action testAction = new SP_OpportunityActionManager.Action(testObjectiveAction, opp.Id,conId);
        if(testAction.subject == null){}
        if(testAction.committed == null){}
        testAction.linkToView();
        String testVal = '';
        Boolean testBol = testAction.requiredToAdvance;
        testVal = testAction.relatedStage;
        testVal = testAction.oppTypes;
        testVal = testAction.orderTypes;
        testVal = testAction.orderSubTypes;
        testVal = testAction.actionType;
        testBol = testAction.exemptProds;
        testVal = testAction.bgColor;
        
    }
}