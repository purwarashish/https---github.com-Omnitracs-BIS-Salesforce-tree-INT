public with sharing class Overlay_Lead_Extension {
    
   ApexPages.StandardSetController leadSetController;
   
   Set<Task> taskList;
   
   List<Lead> leadList;
   
   public List<LeadWrapper> selectedLeads{get;set;}
    
    
    public Overlay_Lead_Extension(ApexPages.StandardSetController controller) {
        //initialize the task list
        taskList=new Set<Task>();
        
        //initialize the lead list
        leadList=new List<Lead>();
        
        this.leadSetController=controller;
        
        //initialize the lead wrapper list
        selectedLeads=new List<LeadWrapper>();
        
        for (Lead leadInstance:[Select leadObj.id
                                     , leadObj.Company
                                     , leadObj.Owner.Name
                                     , leadObj.FirstName
                                     , leadObj.LastName
                                     , leadObj.Email
                                     , leadObj.Phone
                                     , leadObj.Status
                                     , leadObj.Self_Reported_Fleet_Size__c
                                From Lead leadObj 
                                where leadObj.Id in :leadSetController.getSelected()]){
                                            
              LeadWrapper leadWrapperInstance=new LeadWrapper();
              leadWrapperInstance.leadInstance=leadInstance;
              
              leadList.add(leadInstance);
              
              Task taskInstance=new Task();
              taskInstance.whoId=leadInstance.id;
              
              taskInstance.subject=Label.Task_Default_Subject;
              taskInstance.ActivityDate=System.today();
              taskInstance.Status=Label.Task_Status_Completed;
              
              leadWrapperInstance.taskInstance=taskInstance;
              
              selectedLeads.add(leadWrapperInstance);
              
              //add the created task instance to the list
              taskList.add(taskInstance);
       }
    }
    
    
    
    public PageReference saveLeads(){
        try{
            
            update leadList;
            
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
            
            return leadSetController.cancel();
        }
        catch(Exception e){
            System.debug('====Exception occurred when saving leads====' + e);
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,Label.Error_Creating_Leads_or_Tasks);
            ApexPages.addMessage(myMsg);
            return null;
        }
    }
    
    
     
}