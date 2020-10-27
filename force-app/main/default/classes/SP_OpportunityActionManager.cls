public with sharing class SP_OpportunityActionManager{
    
    private transient list<Objective> mstageObjectives;
    //private list<Objective> mCommitObjectives;
    public list<Objective> stageObjectives{
        get{
            if(mstageObjectives==null||commitObjectives==null){
                makeObjectivesAndAdvancementCriteria();
            }
            if (mstageObjectives != null) {
                mstageObjectives.sort();
            }
            if (commitObjectives != null) {
                commitObjectives.sort();
            }
            return commitOnly ? commitObjectives : mstageObjectives;
      //      return mStageObjectives;      
        }
    }

    private transient list<Objective> mcommitObjectives;
    public list<Objective> commitObjectives{
        get{
            if(mcommitObjectives==null){
                makeObjectivesAndAdvancementCriteria();
            }
            return mcommitObjectives;
        }
    }

    public boolean commitOnly{get;set;}

    private transient Objective madvancementCriteria;
    public Objective advancementCriteria{
        get{
            if(madvancementCriteria==null){
                makeObjectivesAndAdvancementCriteria();
            }
            return madvancementCriteria;
        }
    }

    private list<Task> moppActions;
    public list<Task> oppActions{
        get{
            if(moppActions==null){
                moppActions = new list<Task>();
                moppActions.addAll(getCommitActions(stageObjectives));
                moppActions.addAll(getCommitActions(new list<Objective>{advancementCriteria}));
            }
            return moppActions;
        }
    }

    private list<Task> getCommitActions(list<Objective> objs){
        list<Task> oppact = new list<Task>();
        for(Objective obj:objs){
            if (obj != null) {
                for(Action act:obj.actions){
                    if(act.committed){
                        oppact.add(act.action);
                    }
                }
            }
        }
        return oppact;
    }

    //private static Id taskRecordTypeId = SP_RecordTypeManager.getIdByName('Opportunity_Action','Task');
    //private static Translation trans = new Translation();
    private map<Id,sObject> objMap;
    private map<Id,list<sObject>> actionMap;
    private map<id,Objective_Action__c> objActions;
    private Id oppId;
    private Id conId;
    
    
    public SP_OpportunityActionManager(list<Stage_Objective__c> objs,list<Task> acts, map<Id,Objective_Action__c> objActions,Id oppId){
        this.commitOnly = false;
        this.objMap = objs!=null ? SP_sCollection.IdMap(objs,Stage_Objective__c.Id) : new map<Id,sObject>();
        this.actionMap = acts!=null ? SP_sCollection.IdListMap(acts,Task.StageObjectiveID__c) : new map<Id,list<sObject>>();
        this.objActions = objActions;
        this.oppId = oppId;
        //system.debug('@oppId'+oppId); 
        //system.debug('@acts'+acts); 
        //system.debug('@this.actionMap'+this.actionMap);     
        //system.debug('@ this.objActions'+ this.objActions);  
        //system.debug('@this.objMap '+this.objMap );
        this.conId = [Select Id,contact__c,Name,StageName,RecordTypeId from Opportunity where Id =: oppId].contact__c;
        
    }

    public void resetTasks(list<Task> tsk){
        this.actionMap= tsk!=null ? SP_sCollection.IdListMap(tsk,Task.StageObjectiveID__c) : new map<Id,list<sObject>>();
    }

    public void clear(){
        mStageObjectives = null;
        mCommitObjectives = null;
        madvancementCriteria = null;
    }
    
    private void makeObjectivesAndAdvancementCriteria(){
        mstageObjectives = new list<Objective>();
        mCommitObjectives = new list<Objective>();
        Objective obj;
        Objective comObj;
        Stage_Objective__c stageObj;
        integer order;
        Id objId;
        list<Task> actions;
        list<Objective> objectives = new list<Objective>();
        for(Id objKey:objMap.keySet()){
            stageObj = (Stage_Objective__c) objMap.get(objKey);
            comObj = new Objective(stageObj,oppId,conId,true);
            obj = new Objective(stageObj,oppId,conId);
            actions = actionMap.containsKey(objKey) ? (list<Task>) actionMap.get(objKey) : new list<Task>();
            for(Task action:actions){
                objId = action.ObjectiveActionID__c;
                order = objActions.containsKey(objId)&&objActions.get(objId).Order__c!=null ? objActions.get(objId).Order__c.intValue() : -1;
                obj.add(action,objActions.get(objId),order);
                comObj.add(action,objActions.get(objId),order);
            }
            if(stageObj.Advancement_Criteria__c){
                madvancementcriteria = obj;
            } else {
                mstageObjectives.add(obj);
                mcommitObjectives.add(comObj);
                //objectives.add(obj);
            }
        }
    }
    
    public class Objective implements Comparable{
        
        private list<Action> mactions;
        public String msg{get;set;}
        public list<Action> actions{
            get{
                
                if(mactions==null){
                    //list<integer> order = actionMap!=null&&actionMap.keyset().size()==0 ? new list<integer>(actionMap.keySet()) : new list<Integer>();
                    list<integer> order = actionMap!=null&&actionMap.keyset().size()>0 ? new list<integer>(actionMap.keySet()) : new list<Integer>();
                    order.sort();
                    mactions = new list<Action>();
                    if(unordered!=null){ mactions.addAll(unordered); }
                    for(integer place:order){
                        if(place!=null){ mactions.add(actionMap.get(place)); }
                    }
                }
                return mactions;
            }
        }
        public boolean isEmpty{
            get{return actions.isEmpty();}
        }

        public Id objId{get; private set;}
        public String name{get;private set;}
        private map<integer,Action> actionMap;
        private list<Action> unordered;
        private Stage_Objective__c obj;
        private Id oppId;
        private Id conId;
        public Decimal orderNumber{get;set;}
        public String description{get; private set;}
        public List<Schema.FieldSetMember> fs {get; private set;}
        
        public Integer compareTo(Object compareTo) {
            Objective compareToObj = (Objective)compareTo;
            if (this.orderNumber > compareToObj.orderNumber) {
                return 1;
            }
            else if (this.orderNumber < compareToObj.orderNumber) {
                return -1;
            }
            return 0;
        }
        
        public Objective(Stage_Objective__c obj,Id oppId,Id conId){
            this(obj,oppId,conId,false);
        }

        public Objective(Stage_Objective__c obj,Id oppId,Id conId, boolean committed){
            //name = trans.getTranslatedValue(obj.Id,obj.name);
            name = obj.name;
            this.orderNumber = obj.Order__c;
            this.obj = obj;
            this.objId = obj.Id;
            this.oppId = oppId;
            this.conId = conId;
            this.description = obj.Description__c;
            actionMap = new map<integer,Action>();
            unordered = new list<Action>();
            if(!committed){
                //system.debug('@obj.Objective_Action__r'+obj.Objective_Action__r);
                for(Objective_Action__c act:obj.Objective_Action__r){    
                    if(act.Order__c==null){
                        //system.debug('@act.Order__c==null');
                        unordered.add(new Action(act,oppId,conId));
                    } else {
                        //system.debug('@act.Order__c!=null');
                        actionMap.put(act.Order__c.intValue(),new Action(act,oppId,conId));
                    }                   
                }
            }
            // Get the field set for this objective
            if (this.obj.Field_Set__c != null) {
                Map<String, Schema.FieldSet> fsMap = Schema.SObjectType.Opportunity.fieldSets.getMap();
                if (fsMap.containsKey(this.obj.Field_Set__c)) {
                    this.fs = fsMap.get(this.obj.Field_Set__c).getFields();
                }
            }
        }

        public void add(Task tsk,Objective_Action__c act,integer order){
            if(order!=null&&order!=-1){
                actionMap.put(order,new Action(tsk,act));
            } else {
                unordered.add(new Action(tsk,act));
            }
        }
    }
    
    public class Action implements Comparable{
    
        public String subject{
            //get{return trans.getTranslatedValue(act.Id,act.name);}
            get{return act.name;}
        }

//        public boolean committed{get;set;}
        public boolean committed{
            get{return completed||action.ActivityDate!=null||action.Description!=null||action.Coaching_Status__c!=null;} 
        }
        public boolean completed{
            get{return action.isClosed||action.status=='Completed';}
            //set{action.Status = value ? 'Completed' : action.Status;}
            set {
                if (value == true) {
                    if (action.ActivityDate == null) {
                        action.ActivityDate = Date.today();
                    }
                    action.status = 'Completed';
                }
            }
        }
        public String id {
            get{return act.id;}
        }
        public Task action{get;set;}
        private Objective_Action__c act;
        private Decimal orderNumber;
        public Boolean requiredToAdvance{
            get{return act.Action_Type__c == 'Required';}
            set;
        }
        public String relatedStage{
            get{return act.Stage_Name__c;}
            set;
        }
        public String oppTypes {
            get{return act.Opportunity_Type__c;}
            set;
        }
        public String orderTypes {
            get{return act.Opportunity_Order_Type__c;}
            set;
        }
        public String orderSubTypes {
            get{return act.Opportunity_Order_SubType__c;}
            set;
        }
        public String actionType {
            get{return act.Action_Type__c;}
            set;
        }
        public Boolean exemptProds {
            get{return act.Exempt_Products__c;}
            set;
        }
        
         public String taskType {
      get{return act.Task_Type__c;}
      set;
  }
        public String ActionDescription {
          get{return act.Description__c;}
          set;
          }
        public String bgColor {
            get{
                if (act.Action_Type__c == 'Required') {
                    return '#BCF5A9';
                }
                else if (act.Action_Type__c == 'Highly Recommended') {
                    return '#F2F5A9';
                }
                else {
                    return '#FFFFFF';
                }
            }
            set;
        }
        
        public Integer compareTo(Object compareTo) {
            Action compareToObj = (Action)compareTo;
            if (this.orderNumber > compareToObj.orderNumber) {
                return 1;
            }
            else if (this.orderNumber < compareToObj.orderNumber) {
                return -1;
            }
            return 0;
        }
        
        public Action(Objective_Action__c act,Id oppId,Id conId){
            this();
            this.act=act;
            //this.committed = false;
            //action.subject = trans.getTranslatedValue(act.Id,act.name);         
            action.whoId= conId;
            action.subject = act.name;
            action.WhatId = oppId;
            action.ObjectiveActionID__c = act.Id;
            action.StageObjectiveID__c = act.Stage_Objective__c;
            action.Related_Stage__c = act.Stage_Objective__r.Opportunity_Stage__r.Name;
            action.Type = act.Task_Type__c;
            //action.RecordTypeId = taskRecordTypeId;
            action.Status = 'Not Started';
            action.Un_Translated_Action__c = act.Name;
           
        }

        public Action(Task tsk,Objective_Action__c act){
            this();
            //this.committed = true;           
            this.act = act;
            action = tsk;            
        }
        
        public Action(){
            action = new Task();
        }
        
        public PageReference linkToView(){
            return new ApexPages.PageReference('/'+action.Id);
        }
    }
}