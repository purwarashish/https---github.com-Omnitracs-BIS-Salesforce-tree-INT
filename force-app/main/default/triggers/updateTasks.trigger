trigger updateTasks on Task (after insert , after update , after delete)
{

     BypassTriggerUtility u = new BypassTriggerUtility();  
     if (u.isTriggerBypassed()) {
         return;
     }

    Integer taskOpen=0;
    Integer taskClose=0;
    if(Trigger.isInsert || Trigger.isUpdate)
    {
  
        list<string> lstId = new list<string>();
        list<string> lstTaskWhatId = new list<string>();
        map<string,string> mapOfTaskWhatIdnLL = new map<string,string>();
        List<Task> lstTask = new List<Task>();
        List<Lessons_Learned__c> LL = new List<Lessons_Learned__c> ();  
        for(Task new_task:trigger.new)
        {
            lstTaskWhatId.add(new_task.WhatId );
        }    
        if(lstTaskWhatId.size() > 0)
        {
   // taskClose=0;
             LL=[Select
                                             Id,
                                             closeTask__c,
                                             OpenTask__c
                                         From 
                                             Lessons_Learned__c
                                         where 
                                             Id IN :lstTaskWhatId
                                         limit 1];
            
            if(LL != null && LL.size() > 0)
            {
                for(Lessons_Learned__c lessons : LL)
                {
                    lstId.add(lessons.id);
                }
            }
        //For after insert condition
                lstTask =[Select 
                          WhatId,
                          Status
                   From 
                          Task
                   where 
                           WhatId IN :lstId 
                   limit 1000];
       
        }
        for(Task tsk: lstTask)
        {
            mapOfTaskWhatIdnLL.put(tsk.Whatid ,tsk.status);                                     
        }
        
        if(!LL.isEmpty())
        {
       
            for(Integer j=0;j<LL.size();j++)
            {
        
               
                
                list<Lessons_Learned__c> newLL = new list<Lessons_Learned__c>();
                if(mapOfTaskWhatIdnLL.containsKey(LL[j].id))
                {
                    string LLId = LL[j].id;
                    if(mapOfTaskWhatIdnLL.get(LLId) == 'Completed')
                    {
                        System.debug('Inside COMPLETED TASK. completed+++++++');
                        taskClose = taskClose + 1;
                        System.debug('Inside taskClose+++++++'+taskClose);
                    }
                    else
                    {

                      taskOpen=taskOpen+1;
                      System.debug('Inside taskOpen+++++++'+taskOpen);
                   }
                }
                LL[j].closeTask__c=taskClose;
                LL[j].OpenTask__c=taskOpen;
                newLL.add(LL[j]);
                
            }
            update LL;
        }
    }
    
    
    if(Trigger.isDelete)
    {
        list<string> lstId = new list<string>();
        list<string> lstTaskWhatId = new list<string>();
        map<string,string> mapOfTaskWhatIdnLL = new map<string,string>();
        List<Task> lstTask = new List<Task>();
        List<Lessons_Learned__c> LL = new List<Lessons_Learned__c> ();  
        for(Task new_task:trigger.old)
        {
            lstTaskWhatId.add(new_task.WhatId );
        }    
        if(lstTaskWhatId.size() > 0)
        {
   // taskClose=0;
             LL=[Select
                        Id,
                        closeTask__c,
                        OpenTask__c
                 From 
                        Lessons_Learned__c
                 where 
                        Id IN :lstTaskWhatId
                 limit 1];
            
            if(LL != null && LL.size() > 0)
            {
                for(Lessons_Learned__c lessons : LL)
                {
                    lstId.add(lessons.id);
                }
            }
        //For after insert condition
                lstTask =[Select 
                          WhatId,
                          Status
                   From 
                          Task
                   where 
                           WhatId IN :lstId 
                   limit 1000];
       
        }
        for(Task tsk: lstTask)
        {
            mapOfTaskWhatIdnLL.put(tsk.Whatid ,tsk.status);                                     
        }
        
        if(!LL.isEmpty())
        {
       
            for(Integer j=0;j<LL.size();j++)
            {
        
               
                
                list<Lessons_Learned__c> newLL = new list<Lessons_Learned__c>();
                if(mapOfTaskWhatIdnLL.containsKey(LL[j].id))
                {
                    string LLId = LL[j].id;
                    if(mapOfTaskWhatIdnLL.get(LLId) == 'Completed')
                    {
                        System.debug('Inside COMPLETED TASK. completed+++++++');
                        taskClose = taskClose + 1;
                        System.debug('Inside taskClose+++++++'+taskClose);
                    }
                    else
                    {

                      taskOpen=taskOpen+1;
                      System.debug('Inside taskOpen+++++++'+taskOpen);
                   }
                }
                LL[j].closeTask__c=taskClose;
                LL[j].OpenTask__c=taskOpen;
                newLL.add(LL[j]);
                
            }
            update LL;
        }
    }
}