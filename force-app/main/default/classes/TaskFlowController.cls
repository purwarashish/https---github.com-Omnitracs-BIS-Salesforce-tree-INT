public  class TaskFlowController  {

     public Flow.Interview.New_Alert_or_Notice_for_Contracts_v2 Taskflow { get; set; }

     public string varID {get; set;}
     public string WhatID;
     public string AcctID;
     public string TaskID;
     public string ContractId {get; set;}
     
     Public Task t {get; set;}
    Task task;

    public TaskFlowController() {
         ContractID = apexpages.currentpage().getparameters().get('What_id');
    } 

       
     public pageReference getCreateTask() {
        /*
        //ShowTask = true;
        string ExtSubj;
        string ExpDate;
        boolean Contract_Expiration_Task; 
        string ActivityDate;
        string TaskId;
        string Description ;
        //ShowTask = false; 
         if(Taskflow != null)  WhatID = string.valueOf(Taskflow.getVariableValue('varID')); 
         if(Taskflow != null)  AcctId = string.valueOf(Taskflow.getVariableValue('vAccountID'));
         */
         if(Taskflow != null)  TaskID = string.valueOf(Taskflow.getVariableValue('ExpTaskID'));
         /*
         getTask();
         if(Taskflow != null) {
               if(Taskflow.NewExpTask != null){ 
                      task = Taskflow.CreateExpirationTask;
                 }else if (Taskflow.Notice_Task != null){
                     task = Taskflow.Notice_Task;
                 }
                
                    
         }*/
          system.debug('----------task '+task);
          system.debug('----------taskId '+taskId);
         /*
         system.debug('----------AcctID '+AcctID +' ---------- WhatID '+WhatID+' ------ TaskID '+TaskId +'------- ExtSubj  '+ ExtSubj +'------- Expdate'+Expdate);
         system.debug('---------------------NewExpTask '+NewTask );
        //return null; 
          */
        return new  PageReference('/'+taskid+'/e?retURL=%2F'+ContractID);
        //Page.ContractTask;
        
    }
    
      
}