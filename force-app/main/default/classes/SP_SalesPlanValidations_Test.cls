@isTest(seeAllData = true)
public class SP_SalesPlanValidations_Test {

    public static testMethod void testAdvanceStage() {
        
        //Set up test data
        List<Account> acctList = TestDataFactory.createAcctList(1, 'SP SalesPlan Validations Account Test');
        Account acc = acctList[0];
        insert acc;
        
        Id productsAndServicesType = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Products, Services and Maintenance').getRecordTypeId();
        
        Opportunity opp = new Opportunity(Name = 'Test Oppty',recordTypeID = productsAndServicesType, AccountId = acc.id, StageName = '1 - Plan', Order_Type__c = 'New', CloseDate = Date.Today());
        insert opp;
        
        Schema.DescribeFieldResult F = Opportunity.Stagename.getDescribe();
        List<Schema.PicklistEntry> P = F.getPicklistValues();  

        map<integer,string> pMap = new map<integer,string>();

        list<string> pVal = new list<string>();
        for(Schema.PicklistEntry o: P){
            pVal.add(o.getValue());   
        }
        for(integer i = 0; i<pVal.size() ;i++){
               pMap.put(i+1,pVal[i]);            
        }
        List<Opportunity_Stage__c> stgList = new List<Opportunity_Stage__c>();
        for(Integer seq : pMap.keySet()) {
            Opportunity_Stage__c stg = new Opportunity_Stage__c(Name = pMap.get(seq), Stage_Number__c = seq);
            stgList.add(stg);
        }
        insert stgList;
        /*Opportunity_Stage__c stg1 = new Opportunity_Stage__c(Name = '1 - Plan', Stage_Number__c = 1);
        Opportunity_Stage__c stg2 = new Opportunity_Stage__c(Name = '2 - Create', Stage_Number__c = 2);
        Opportunity_Stage__c stg3 = new Opportunity_Stage__c(Name = '3 - Qualify', Stage_Number__c = 3);*/
        
        
        Stage_Objective__c obj1 = new Stage_Objective__c(Name = 'Objective 1', Opportunity_Stage__c = stgList[0].Id, Order__c = 1);
        Stage_Objective__c obj2 = new Stage_Objective__c(Name = 'Objective 2', Opportunity_Stage__c = stgList[1].Id, Order__c = 2);
        Stage_Objective__c obj3 = new Stage_Objective__c(Name = 'Objective 3', Opportunity_Stage__c = stgList[2].Id, Order__c = 3);
        List<Stage_Objective__c> objList = new List<Stage_Objective__c>();
        objList.add(obj1);
        objList.add(obj2);
        objList.add(obj3);
        insert objList;
        
        Objective_Action__c act1 = new Objective_Action__c(Name = 'Not Required Action', Order__c = 1, Stage_Objective__c = obj1.Id);
        Objective_Action__c act2 = new Objective_Action__c(Name = 'Required Action', Order__c = 2, Stage_Objective__c = obj2.Id, Action_Type__c = 'Required', Opportunity_Order_Type__c = 'New');
        act2.Opportunity_Record_Type__c = 'Products, Services and Maintenance';
        List<Objective_Action__c> actList = new List<Objective_Action__c>();
        actList.add(act1);
        actList.add(act2);
        insert actList;
        
        // Begin test
        Test.startTest();
        opp.StageName = pMap.get(2);
        update opp;
        
        System.assertEquals(pMap.get(2), opp.StageName);
        
        opp.StageName = pMap.get(3);
        try {
            update opp;
        }
        catch (Exception e) {
            System.debug('Caught exception');
        }
        
        Opportunity getOpp = [SELECT StageName FROM Opportunity WHERE Id = :opp.Id LIMIT 1];
        System.assertNotEquals(pMap.get(3), getOpp.StageName);
        
        Task tsk = new Task(WhatId = opp.Id, StageObjectiveId__c = obj2.Id, ObjectiveActionID__c = act2.Id);
        tsk.Status = 'Completed';
        insert tsk;
        
        update opp;
        
        getOpp = [SELECT StageName FROM Opportunity WHERE Id = :opp.Id LIMIT 1];
        System.assertEquals(pMap.get(3), getOpp.StageName);
        
        Test.stopTest();
    }

}