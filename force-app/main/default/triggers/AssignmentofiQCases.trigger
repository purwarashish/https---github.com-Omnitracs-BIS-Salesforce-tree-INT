trigger AssignmentofiQCases on Case (before insert,before update) {

/***********************************************************************************
Date: 5/9/2010 
Author: Shruti Karn, Salesforce.com Developer
Tata Consultancy Services Limited

CR# 21051
MODIFICATIONS
 28 Mar 2011 - DAR - Added reference to Value Pack Evaluation Requested
************************************************************************************

     /*BypassTriggerUtility u = new BypassTriggerUtility();  
     if (u.isTriggerBypassed()) {
         return;
     }

    map<String, String> mapRecTypeIdName = new map<String,String>(); // Map of Case's RecordTypeId and Name
    //mapRecTypeIdName = CaseValidationUtils.getRecordTypesForCases();        
        
    if (Trigger.isInsert && Trigger.IsBefore)
    {
        for (Case CaseObj :Trigger.new)
        {
            if((CaseObj.RecordTypeId == CaseTrigger_Global_Variable__c.getInstance('CallCenter_RecordTypeId').Value__c
              || CaseObj.RecordTypeId == CaseTrigger_Global_Variable__c.getInstance('EmailGeneratedCases_RecordTypeId').Value__c)
                //|| mapRecTypeIdName.get(CaseObj.RecordTypeId) == 'Email-iQ OV Requests')
               && CaseObj.Origin == QESConstants.CASE_CASE_ORIGIN                
               && CaseUtils.checkIfIQCaseToBeAutoAssigned(CaseObj.Subject.toLowerCase().trim())
                )
               
            {
               CaseObj.Queue__c = 'Field CS';
            }
        }
    }
  
    if(Trigger.isUpdate)
    {  
        try{
        map<Id, String> mapCaseCustId = new map<Id, String>();// to hold the value of CustID and the Case
        Boolean EvaluationNotificationCSR;

        for (Case CaseObj :Trigger.new)
        {   
            //CSR needs to be notified for Evaluation Notifications generated by iQ. The below IF block checks for Email Generated Cases related to Evaluation notfications
            EvaluationNotificationCSR = false;
            if(mapRecTypeIdName.get(CaseObj.RecordTypeId) == QESConstants.REC_TYPE_CASE_EMAIL_GENERATED &&(CaseObj.Subject.toLowerCase().trim()=='evaluation expired'||CaseObj.Subject.toLowerCase().trim()=='evaluation expiring'||CaseObj.Subject.toLowerCase().trim()=='evaluation extended'))
                   EvaluationNotificationCSR = true;  
                         
            if((mapRecTypeIdName.get(CaseObj.RecordTypeId) == QESConstants.REC_TYPE_CASE_CALL_CENTER) || (EvaluationNotificationCSR == true) 
              && CaseObj.Origin == QESConstants.CASE_CASE_ORIGIN 
              && CaseUtils.checkIfIQCaseToBeAutoAssigned(CaseObj.Subject.toLowerCase().trim())
              )
            {
                
                if(TRUE != CaseObj.Auto_Assigned__c) {
                    
                    
                    String custId;              
                    String caseDescLC = CaseObj.Description.toLowerCase();
                    String caseDesc = CaseObj.Description;
                    if(CaseUtils.checkIfIQCaseToBeAssignedToCSR(CaseObj.Subject.toLowerCase().trim()))
                    {
                        if(caseDescLC.indexof('cust id') != -1)
                        {
                            Integer start_index = caseDescLC.indexof('cust id');
                            String subDesc = caseDesc.substring(start_index);
                            custid = subDesc.substring(subDesc.indexof(':')+1,subDesc.indexof(']')).trim();
                            mapCaseCustId.put(CaseObj.Id, custid);
                        }
                        
                        if(caseDescLC.indexof('app') != -1)
                        {
                            Integer start_index = caseDescLC.indexof('app');
                            String subDesc = caseDesc.substring(start_index);
                            String app = subDesc.substring(subDesc.indexof(':')+1,subDesc.indexof(']')).trim();
                            caseObj.Eval_Application__c = app;
                            caseObj.Send_Eval_Notification__c = true;
                        }
                        if(caseDescLC.indexof('start date') != -1)
                        {
                            Integer start_index = caseDescLC.indexof('start date');
                            String subDesc = caseDesc.substring(start_index);
                            String startDate = subDesc.substring(subDesc.indexof(':')+1,subDesc.indexof(']')).trim();
                            caseObj.Eval_Start_Date__c = startDate;
                        }
                        if(caseDescLC.indexof('end date') != -1)
                        {
                            Integer start_index = caseDescLC.indexof('end date');
                            String subDesc = caseDesc.substring(start_index);
                            String endDate = subDesc.substring(subDesc.indexof(':')+1,subDesc.indexof(']')).trim();
                            caseObj.Eval_End_Date__c = endDate;
                        }
                        if(caseDescLC.indexof('user') != -1)
                        {
                            Integer start_index = caseDescLC.indexof('user');
                            String subDesc = caseDesc.substring(start_index);
                            String extendedBy = subDesc.substring(subDesc.indexof(':')+1,subDesc.indexof(']')).trim();
                            caseObj.Eval_Extended_By__c = extendedBy;
                        }
                    }else if(CaseObj.Subject.toLowerCase().trim().contains('reporting services access requested'))
                    {
                        if(caseDesc.indexof('Customer ID') !=-1){
                            Integer start_index = caseDesc.indexof('Customer ID');
                            String subDesc = caseDesc.substring(start_index);
                            custid = (subDesc.substring(subDesc.indexof(':')+3,subDesc.indexof('/n'))).trim();
                             mapCaseCustId.put(CaseObj.Id, custid);
                        }

                    }
                    CaseObj.Auto_Assigned__c = TRUE;
                    
                }  
            } 
        }// end for
        
        Map<String, Account> mapOfAccounts = new Map<String, Account>();
        for(Account acc : [Select Id,Name,CSR__c, Inside_CSR__c  ,Account_Manager__c, QWBS_Cust_ID__c, ServiceSource_Rep__c  from Account where QWBS_Cust_ID__c IN : mapCaseCustId.Values() limit 500])
        {
            mapOfAccounts.put(acc.QWBS_Cust_ID__c,acc);
        }
        for(Case CaseRecord : trigger.new)
        {
            Account relAcc;
            if(mapCaseCustId.containsKey(CaseRecord.id))
            relAcc = mapOfAccounts.get(mapCaseCustId.get(CaseRecord.id));
            
            if(relAcc != null)
            {
                CaseRecord.Customer_Service_Rep__c = relAcc.CSR__c;
                CaseRecord.Account_Manager__c = relAcc.Account_Manager__c;
                CaseRecord.Inside_CSR__c= relAcc.Inside_CSR__c;
                CaseRecord.ServiceSource_Rep__c = relAcc.ServiceSource_Rep__c;
            }
        }   
       
        // changeOwner() should be called only once 
        if(!QESConstants.inFutureContext)        
        {
            if(!(mapCaseCustId.isEmpty()))
            {
                CaseUtils.changeOwner(mapCaseCustId);
            }
        }
        }
        catch(exception e)
        {
        System.debug('Error:' + e.getMessage());
        }
    }*/
}