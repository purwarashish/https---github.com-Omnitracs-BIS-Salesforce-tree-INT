public with sharing class Overlay_Oppty_Extension {
   
   public Overlay_Oppty_Extension extensionInstance{get;set;}
   
   ApexPages.StandardSetController opptySetController;
   
   Set<Task> taskList;
   
   List<Opportunity> opptyList;
   
   public List<OpportunityWrapper> selectedOpportunity{get;set;}
   
   public Map<String,List<OpportunityLineItem>> opptyLineItemMap{get;set;}
   
   public List<OpportunityStage> getOppStageList()
   {
    List <OpportunityStage> OppStageList = new List<OpportunityStage> ();
    OppStageList = [Select o.MasterLabel, o.IsActive, o.DefaultProbability From OpportunityStage o where  o.IsActive = true];
    
    return OppStageList;
   }
   
   
   
    public Overlay_Oppty_Extension(ApexPages.StandardSetController controller) {
        //initialize the task list
        taskList=new Set<Task>();
        //initialize the oppty list
        opptyList=new List<Opportunity>();
        
        this.opptySetController=controller;
        //initialize the opportunity line item map
        opptyLineItemMap=new Map<String,List<OpportunityLineItem>>();
        
        //initialize the opportunity wrapper map
        selectedOpportunity=new List<OpportunityWrapper>();
        
        //initialize wrapperIndex
        Integer wrapperIndex=0;
        
        for (Opportunity opptyInstance:[Select o.id
                                             , o.Oppty_Quantity__c
                                             , o.Owner.Name
                                             , o.Account.name
                                             , o.Name
                                             , o.TotalOpportunityQuantity
                                             , o.Forecast_Demand__c
                                             , o.StageName
                                             , o.CloseDate
                                             , o.Probability 
                                             , o.LastModifiedDate
                                        From Opportunity o 
                                        where o.Id in :opptySetController.getSelected()]){
                                            
              OpportunityWrapper oppWrapperInstance=new OpportunityWrapper();
              oppWrapperInstance.opportunityInstance=opptyInstance;
              opptyList.add(opptyInstance);
              
              Task taskInstance=new Task();
              taskInstance.whatId=opptyInstance.id;
              
              
              taskInstance.subject=Label.Task_Default_Subject;
              taskInstance.ActivityDate=System.today();
              taskInstance.Status=Label.Task_Status_Completed;
              
              oppWrapperInstance.taskInstance=taskInstance;
              
              oppWrapperInstance.wrapperIndex=wrapperIndex;
              
              oppWrapperInstance.computedTopIndex=((wrapperIndex+1)*15)+292;
              
              selectedOpportunity.add(oppWrapperInstance);
              
              //add the created task instance to the list
              taskList.add(taskInstance);
              
              //increment wrapperIndex
              wrapperIndex++;
       }
        
        for(OpportunityLineItem opptyLineItem:[Select o.Shipped__c
                                                           , o.ServiceDate
                                                           , o.Oppty_Quantity__c
                                                           , o.Quantity
                                                           , o.UnitPrice 
                                                           , o.PricebookEntry.Name
                                                           , o.OpportunityId
                                                      From OpportunityLineItem o
                                                      where OpportunityId in :opptySetController.getSelected()]){
               
               //already an entry for opportunity line item exist
               if(opptyLineItemMap.get(opptyLineItem.OpportunityId)!=null){
                  opptyLineItemMap.get(opptyLineItem.OpportunityId).add(opptyLineItem);
               }  
               else{
                 opptyLineItemMap.put(opptyLineItem.OpportunityId,new List<OpportunityLineItem>{opptyLineItem});
               }                                        
        }
       extensionInstance=this;
    }
    
    
    
    public PageReference saveOpptys(){
        try{
            
            update opptyList;
            //create list of tasks to be updated
            List<Task> updateTasks=new List<Task>();
            
            System.debug('====taskList before removing====' + taskList);
            
            for(Task taskInstance:taskList){
                if(taskInstance.Description!=null && taskInstance.Description.trim()!=''){
                  updateTasks.add(taskInstance);     
                }
                
            }
            
            System.debug('====taskList that is going to be updated====' + updateTasks);
            
            
            insert updateTasks;
            //initialize tasks after saving
            taskList=new Set<Task>();
            
            return opptySetController.cancel();
        }
        catch(Exception e){
            System.debug('====Exception occurred when saving leads====' + e);
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,Label.Error_Creating_Opptys_or_Tasks);
            ApexPages.addMessage(myMsg);
            
            return null;
        }
    }
    
    
     
}