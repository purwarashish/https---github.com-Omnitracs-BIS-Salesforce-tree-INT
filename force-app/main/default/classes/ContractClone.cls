global with sharing class  ContractClone implements Process.Plugin {
/*********************************************************************************
Program:        Used to clone the contract record via flow for renewal
Programmer:     Joe Henry - CloudSherpas
Date:           September 30, 2014
**********************************************************************************/ 
    // The main method to be implemented. The Flow calls this at runtime.   
    @TestVisible private Contract CurrentContract {get;set;}  
    public string NewContractID {get;set;}
    public string NewContractNumber {get;set;}
    
    global Process.PluginResult invoke(Process.PluginRequest request)   
   {   
      String ContractId = (String) request.inputParameters.get('vID');  
      String AccountId = (String) request.inputParameters.get('vAccountId'); 
      String Events = (String) request.inputParameters.get('vEvents'); 
      datetime EndDate = (datetime) request.inputParameters.get('vEndDate');  
      Decimal Notice = (Decimal) request.inputParameters.get('vNotice'); 
      string Renewal = (String) request.inputParameters.get('vRenewal'); 
      string Extension = (String) request.inputParameters.get('vExtension'); 
      system.debug('-------------------------------vID '+ContractId +'------- vAccountId '+AccountId +'------ vEvents '+Events +'------ vEndDate '+EndDate +'------ vNotice '+Notice+'------ vRenewal '+Renewal);
     
        
     // return to Flow 
     Map<String,string> result = new Map<String,string>();   
     if(Renewal =='Yes'){
           result = CloneContract(ContractId, AccountId, EndDate ); 
           UpdateTask(Events,ContractId, EndDate, Notice, AccountId, Extension, NewContractId); 
           system.debug('-------------------------------Results back to Flow '+result);
     }else if (Extension == 'Yes')
          UpdateTask(Events, ContractId, EndDate, Notice, AccountId, Extension,''); 
            
      return new Process.PluginResult(result);   
    }   
    
    // Returns the describe information for the interface   
    global Process.PluginDescribeResult describe()   
    {   
      Process.PluginDescribeResult result = new Process.PluginDescribeResult();  
      result.Name = 'CloneContract';  
      result.Tag = 'ContractClone';  
      
      //InputParams  
      result.inputParameters =new List<Process.PluginDescribeResult.InputParameter>();  
        
      result.inputParameters.add(  
        new Process.PluginDescribeResult.InputParameter('vID',  
          Process.PluginDescribeResult.ParameterType.STRING, true));             
      result.inputParameters.add(  
        new Process.PluginDescribeResult.InputParameter('vAccountId',  
          Process.PluginDescribeResult.ParameterType.STRING, true));  
       result.inputParameters.add(  
        new Process.PluginDescribeResult.InputParameter('vEvents',  
          Process.PluginDescribeResult.ParameterType.STRING, true));  
       result.inputParameters.add(  
        new Process.PluginDescribeResult.InputParameter('vEndDate',  
          Process.PluginDescribeResult.ParameterType.STRING, true));  
       result.inputParameters.add(  
        new Process.PluginDescribeResult.InputParameter('vNotice',  
          Process.PluginDescribeResult.ParameterType.integer, true));
       result.inputParameters.add(  
        new Process.PluginDescribeResult.InputParameter('vRenewal',  
          Process.PluginDescribeResult.ParameterType.STRING, true));       
       result.inputParameters.add(  
        new Process.PluginDescribeResult.InputParameter('vExtension',  
          Process.PluginDescribeResult.ParameterType.STRING, true));                           
      
      // Create a list that stores output parameters sent 
        // to the flow.
        result.outputParameters = new List<
            Process.PluginDescribeResult.OutputParameter>{
           // Contact ID of the New record
            new Process.PluginDescribeResult.OutputParameter('NewContractId', Process.PluginDescribeResult.ParameterType.STRING)
        };

      return result;  
    }  
    //Close out Tasks and create new ones for the new contract
    public void UpdateTask(string Events, String CId, datetime EndDate, Decimal notice, string AccId, string Ext, string NewId){
        // setup the save point for rollback
         Savepoint sp = Database.setSavepoint();
        list<Task> NewTask = new list<Task>();
        list<Task> OldTask = new list<Task>();
        Contract oldContract = [Select id, EndDate from contract where id =:CId limit 1];
        integer Days = 0; 

        If(Events == 'Yes'){
            for(Task T : [Select t.WhoId, t.WhatId, t.Was_Emergency_Key__c, t.Type,  Subject,
                            t.StageObjectiveId__c, t.ReminderDateTime, 
                            t.RecurrenceType, t.RecurrenceTimeZoneSidKey, t.RecurrenceStartDateOnly, t.RecurrenceMonthOfYear, IsRecurrence,
                            t.RecurrenceInterval, t.RecurrenceInstance, t.RecurrenceEndDateOnly, t.RecurrenceDayOfWeekMask, t.RecurrenceDayOfMonth, 
                            t.RecurrenceActivityId, t.RecordTypeId, t.Priority, t.OwnerId, t.ObjectiveActionID__c, 
                            t.License_Type__c, t.License_Key_Date__c, t.License_Activity__c, 
                            t.Key_Action__c, t.Is_Test_Demo_Config_Key__c, t.IsClosed, t.Id, t.Description,
                            t.Contract_Expiration_Task__c, 
                            t.Coaching_Status__c, t.CallType, t.CallObject, 
                            t.CallDurationInSeconds, t.CallDisposition, t.CTI_ANI__c, t.ActivityDate, t.AccountId 
                            From Task t where Contract_Expiration_Task__c = true and WhatId = :CId and status <> 'Completed']){
                task NT; //= new task();
                NT = T.clone(false,true, false, false);         
                
                system.debug('-------------------------Ext for New Task '+Ext +'------NewContract '+NewId);
                system.debug('-------------------------OldContract.Enddate '+OldContract.Enddate +'------T.ActivityDate '+T.ActivityDate  +'------ NT.ReminderDateTime '+NT.ReminderDateTime);
                if(Ext != 'Yes')
                    NT.WhatId = NewId;
                    NT.Subject = T.Subject;
                //NT.AccountId = AccId;
                if(T.IsRecurrence  == false){
                    if(NT.ActivityDate != null){
                        Days = T.ActivityDate.daysBetween(OldContract.Enddate); 
                        //NT.ActivityDate = Date.valueof(EndDate).addDays(-integer.valueOf(notice));
                        NT.ActivityDate = Date.valueof(EndDate).addDays(-Days);
                        if(NT.ReminderDateTime != null)
                            NT.ReminderDateTime = DateTime.valueOf(NT.ReminderDateTime).addDays(-Days);
                        NewTask.add(NT);   
                     }
                } 
                /*
                  else If(T.RecurrenceEndDateOnly != null && T.RecurrenceStartDateOnly == NULL) { 
                    Days = T.ActivityDate.daysBetween(OldContract.Enddate);   
                    // NT.RecurrenceEndDateOnly = Date.valueof(EndDate);
                    // NT.RecurrenceStartDateOnly = Date.valueof(EndDate).addDays(-integer.valueOf(notice));
                    NT.ActivityDate = Date.valueof(EndDate).addDays(-Days);
                    NewTask.add(NT);              
                } */
                //Update the status of the old task
                if(T.IsRecurrence  == false){
                    T.status ='Completed';
                    OldTask.add(T);
                }
            }
            
            try {
                Update OldTask;
                Insert NewTask; 
            } catch (Exception e){
                 // roll everything back in case of error
                system.debug('-------------------------------Task ErrorMessage '+e);
                Database.rollback(sp);
                
            }   
        }  
    }
      
    public map<string, string> CloneContract(String vId, String vAccountId, datetime EndDate)  
    {  
        // setup the save point for rollback
         Savepoint sp = Database.setSavepoint();
        //list<Asset__c> CAssets = new list<Asset__c>(); 
       // list<Asset__c> CASList = new list<Asset__c>(); 
        
        Map<String,String> result = new Map<String,String>();
        Contract NewContract;
        //Asset__c NewCAs;
        String SOQL;
        SOQL  = Utils.getCreatableFieldsSOQL('Contract','id=\''+ vId +'\'');
        CurrentContract = (Contract)Database.query(SOQL);
        system.debug('-------------------------------soql '+SOQL);
        //SOQL  = Utils.getCreatableFieldsSOQL('Asset__c','Contract__c =\''+vId+'\'');
        //CAssets = Database.query(SOQL);
        
        

        try {
            NewContract = CurrentContract.clone(false,true, false, false);
            NewContract.StartDate = date.valueOf(EndDate).addYears(-1);
            NewContract.EndDate = date.valueOf(EndDate);
            NewContract.Contract_ID__c = null;
            NewContract.Status = 'Draft';
            
            insert NewContract;
            system.debug('-------------------------------NewContract '+NewContract);
            system.debug('-------------------------------NewContract '+NewContract.id);
            /*
            for(Asset__c ass : CAssets){
                ass.contract__c = NewContract.Id;
                CASList.add(ass);
            }   
            insert CASList;
            */
            NewContractId = NewContract.Id;
            NewContractNumber = NewContract.Contract_Title__c;
            result.put('NewContractId', NewContractId);
            
        } catch (Exception e){
             // roll everything back in case of error
            system.debug('-------------------------------ErrorMessage '+e);
            Database.rollback(sp);
            ApexPages.addMessages(e);
        }
        
        return result;
  
     
    }  

}