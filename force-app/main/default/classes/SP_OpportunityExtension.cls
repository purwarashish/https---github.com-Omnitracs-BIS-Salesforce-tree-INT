public with sharing class SP_OpportunityExtension{
    
    private Id pipelineRT = SP_RecordTypeManager.getIdByName('Products_and_Services', 'Opportunity');
    private Opportunity_Stage__c mOppStage;
    public Opportunity_Stage__c OppStage {
        get {
            if (mOppStage == null && opp.Opportunity_Stage__c!=null) {
                mOppStage = [select Next_Stage__r.Name, Next_Stage__r.advance_stage_visualforce_page__c from Opportunity_Stage__c where Id = :opp.Opportunity_Stage__c];
            }
            return mOppStage;
        }
    }
    private String mNextStage;
    public string nextStage {
        get{
            if(mNextStage==null){
                if (OppStage!=null && OppStage.Next_Stage__r != null) {
                    mNextStage = OppStage.Next_Stage__r.Name;
                }
            }
            return mNextStage;
        }
    }
    
    private list<Task> madvancementCriteria;
    public list<Task> advancementCriteria{
        get{
            if(madvancementCriteria==null){
                list<String> stageObjIds = new list<String>();
                for(Stage_Objective__c stageObj:[select Id
                                                    from Stage_Objective__c 
                                                    where Opportunity_Stage__c = :opp.Opportunity_Stage__c 
                                                    and advancement_Criteria__c = true]){
                    stageObjIds.add((String) stageObj.Id);
                }
                madvancementCriteria = [select Id, isClosed, subject from Task where StageObjectiveID__c in :stageObjIds and WhatId = :opp.Id];
            }
            return mAdvancementCriteria;
        }
    }
    
    private Opportunity opp;
    
    public SP_OpportunityExtension(ApexPages.StandardController std){
        opp = (Opportunity) std.getRecord();
    }
    
    public Boolean readyToAdvance {
        get {
            boolean rta = (nextStage!=null && nextStage!='');
            if (advancementCriteria!=null) {
                for (Task t : advancementCriteria) {
                    if (t.isClosed ==false) {
                        rta = false;
                        break;
                    }
                }
            }
            return rta;
            
        }
    }
    public PageReference advanceStage() {
        PageReference nextPage = null;
        opp.StageName= nextStage;
        if (opp.StageName=='Investigate') {
            opp.RecordTypeId = pipelineRT;
        }
        
        if (OppStage != null && OppStage.Next_Stage__r!=null&& OppStage.Next_Stage__r.advance_stage_visualforce_page__c!=null) {
            nextPage = new PageReference('/apex/' + OppStage.Next_Stage__r.advance_stage_visualforce_page__c);
            nextPage.getParameters().put('id', opp.Id);
        } else {
            nextPage = new ApexPages.StandardController(opp).save();
        }
        return nextPage;
    }
    
    /*
    static testmethod void testOpportunityExtension(){
        test.starttest();
        SP_OpportunityExtension ext = new SP_OpportunityExtension(
            new ApexPages.StandardController(
                TestData.getOpportunity()));
        
        Opportunity_Stage__c os = ext.oppStage;
        String nextStage = ext.nextStage;
        list<Task> advCrit = ext.advancementCriteria;
        ext.advanceStage();
        test.stoptest();
    }
    */
}