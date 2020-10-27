trigger ContractRequestTISDetail on Contract_Request__c (after insert, after update){
String result;//contains the new record's SID/Error details of insert operation
    list<String> ContractRequestIDList = new list<String>();
    list<String> ContractRequestOldStateList = new list<String>();
    list<String> ContractRequestNewStateList = new list<String>();
    list<String> StateNameList = new list<String>();
    list<boolean> InsertNewRecordsList = new list<boolean>();
    list<Boolean> TISClosedList = new list<Boolean>();////determines whether the TIS record should be created with "Date time Out" as NOT NULL
    
    if (Trigger.isInsert && CreateTIS.getInsertCounterContractRequest() ==0 )
    {
        System.debug('----------------------- Insert Operation---------------------------');    

        for (Contract_Request__c ContractRequestNew :Trigger.new)
        {
            if(ContractRequestNew.Request_Status__c != null)
            {
                System.debug('****CREATE RECORD for "Request Status"');
                result = CreateTIS.CreateNewTISRecord('Contract_Request__c',ContractRequestNew.Id, 'Request Status',ContractRequestNew.Request_Status__c, null);
                System.debug('**New record created in TIS_Detail__c with SID: "'+ result +'" **');
            }            
        }

        CreateTIS.setInsertCounterContractRequest();
        System.debug('-- End of Trigger "ContractRequestTISDetail" on Contract Request--');

}else if ((Trigger.isUpdate && CreateTIS.getInsertCounterContractRequest() ==1 ) || (Trigger.isUpdate && CreateTIS.getUpdateCounterContractRequest() < 2 ))
    {
        System.debug('------------------- Update Operation--------------------'+ CreateTIS.getUpdateCounterContractRequest());
        
        //Clearing the lists 
        ContractRequestIDList.clear(); 
        ContractRequestOldStateList.clear();
        ContractRequestNewStateList.clear();        
        StateNameList.clear();
        InsertNewRecordsList.clear();
        
        for(integer i = 0; i < Trigger.new.size(); ++i) 
        {
                System.debug('#1# Creating list of Contract Request Id with changed "Request Status"');
                if (Trigger.new[i].Request_Status__c!= Trigger.old[i].Request_Status__c)
                {
                    System.debug('Contract Request ID is ' + Trigger.new[i].Id);
                    if(CreateTIS.getInsertCounterContractRequest() ==1)
                    {
                        System.debug('==>==>There are Contract Requests with Changed Request Status');
                        ContractRequestIDList.add(Trigger.new[i].Id);
                        ContractRequestOldStateList.add(Trigger.old[i].Request_Status__c);
                        ContractRequestNewStateList.add(Trigger.new[i].Request_Status__c);
                        InsertNewRecordsList.add(true);
                        StateNameList.add('Request Status');
                        TISClosedList.add(false);
                    }else if(CreateTIS.getUpdateCounterContractRequest() == 0)
                    {
                        System.debug('==>==>There are Contract Requests with Changed Request Status');
                        CreateTIS.ContractRequestTestStatusMap.put(Trigger.new[i].Id,Trigger.new[i].Request_Status__c);
                        ContractRequestIDList.add(Trigger.new[i].Id);
                        ContractRequestOldStateList.add(Trigger.old[i].Request_Status__c);
                        ContractRequestNewStateList.add(Trigger.new[i].Request_Status__c);
                        InsertNewRecordsList.add(false);
                        StateNameList.add('Request Status');
                        TISClosedList.add(false);
                    }
                    if(CreateTIS.getUpdateCounterContractRequest() == 1)
                    {
                        if(CreateTIS.ContractRequestTestStatusMap.get(Trigger.new[i].Id) != Trigger.new[i].Request_Status__c)
                        {
                            System.debug('==>==>There are Contract Request with Changed Request Status');
                            ContractRequestIDList.add(Trigger.new[i].Id);
                            ContractRequestOldStateList.add(Trigger.old[i].Request_Status__c);
                            ContractRequestNewStateList.add(Trigger.new[i].Request_Status__c);
                            InsertNewRecordsList.add(false);
                            StateNameList.add('Request Status');
                            TISClosedList.add(false);
                        }
                        
                    }
                }                 
      }///for loop
   
   if (!ContractRequestIDList.isEmpty())
   { 
        
                CreateTIS.UpdateTISRecords('Contract_Request__c',ContractRequestIDList, ContractRequestOldStateList, ContractRequestNewStateList, null, StateNameList, InsertNewRecordsList, TISClosedList);
   }
       
       
    if(CreateTIS.getInsertCounterContractRequest() ==1) CreateTIS.setInsertCounterContractRequest();
    CreateTIS.setUpdateCounterContractRequest();
    System.debug('-- End of Trigger "ContractRequestTISDetail" on Contract Request--');
    
  }//if
    
   
}