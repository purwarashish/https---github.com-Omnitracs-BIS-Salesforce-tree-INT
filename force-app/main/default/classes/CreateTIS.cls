public class CreateTIS {
/*******************************************************************************************************
Date: 7/09/2009
Author: Rajkumari Nagarajan, Salesforce.com Developer
        Tata Consultancy Services Limited
When a Contract Request record is Created or Edited, the trigger tracks and captures the change in the following field:
1) Request Status

//Updated by Shruti Karn for adding TIS for Cases CR#15180
*******************************************************************************************************/
//---------------Contract Request Static variables-----------------
private static Integer InsertCounterContractRequest =0;
private static Integer UpdateCounterContractRequest = 0;
public static map<id,String> ContractRequestTestStatusMap = new map<id,String>();


public static Integer getInsertCounterContractRequest()
{
    return InsertCounterContractRequest;
}

public static void setInsertCounterContractRequest()
{   
    InsertCounterContractRequest = InsertCounterContractRequest + 1; System.debug('InsertCounterContractRequest ==>'+ InsertCounterContractRequest );
}

public static Integer getUpdateCounterContractRequest()
{
    return UpdateCounterContractRequest;
}

public static void setUpdateCounterContractRequest()
{   
    UpdateCounterContractRequest = UpdateCounterContractRequest + 1;System.debug('UpdateCounterContractRequest ==>'+UpdateCounterContractRequest);
}

//----------------------Case static Variables---------------- 
public static Integer InsertCounter =0; 
public static Integer UpdateCounter = 0; 
public static map<id,String> CaseStatusMap = new map<id,String>(); 
public static map<id,String> CaseCurrentMap = new map<id,String>(); 
public static Integer getInsertCounter() 
{ 
    return InsertCounter; 
} 

public static void setInsertCounter() 
{ 
    InsertCounter = InsertCounter + 1; System.debug('InsertCounter==>'+ InsertCounter); 
} 

public static Integer getUpdateCounter() 
{ 
    return UpdateCounter; 
} 

public static void setUpdateCounter() 
{ 
    UpdateCounter = UpdateCounter + 1;System.debug('UpdateCounter==>'+UpdateCounter); 
} 


public static String CreateTISRecord(String ObjectName, String ObjectId, String FieldName,String State, String OwnerId, Boolean TISClosed)
{
 try
    {
        TIS_Detail__c NewTIS = new  TIS_Detail__c();
        if(ObjectName== 'Contract_Request__c')
            NewTIS.Contract_Request__c = ObjectId;
        if(ObjectName == 'Case')             
            NewTIS.Case__c = ObjectId; 
        NewTIS.name = FieldName;
        NewTIS.State__c = State;
        system.debug('State: ' + State);
        NewTIS.Date_Time_In__c = System.now();
        NewTIS.Who__c = UserInfo.getUserId();//Current User
        if(TISClosed)
        {
            System.debug('---------Close the TIS------');
            NewTIS.Date_Time_Out__c = System.now();
            if(ObjectName== 'Contract_Request__c')
            {
            for (TIS_Detail__c ContractRequestTIS :[select Id,Contract_Request__c,Date_Time_Out__c from TIS_Detail__c where Contract_Request__c =:ObjectId and Date_Time_Out__c = null limit 1000]) 
            {
                    if(State != 'Set-up Complete')
                    ContractRequestTIS.Date_Time_Out__c = System.now();
                    System.debug('Update the "Date_Time_Out__c" in TIS_Detail__c for record Id: "'+ ContractRequestTIS.Id + '"');
                    update ContractRequestTIS;
            }
            }
            if(ObjectName == 'Case') 
            {
            for (TIS_Detail__c CaseTIS :[select Id,Case__c,Date_Time_Out__c from TIS_Detail__c where Case__c =:ObjectId and Date_Time_Out__c = null limit 1000]) 
                { 
                CaseTIS.Date_Time_Out__c = System.now(); 
                System.debug('Update the "Date_Time_Out__c" in TIS_Detail__c for record Id: "'+ CaseTIS.Id + '"'); 
                update CaseTIS; 
                } 
            }
        }
        if(State == 'Set-up Complete')
        {
            NewTIS.Date_Time_Out__c=NewTIS.Date_Time_In__c;
            System.debug('Date/Time Out in create tis'+ NewTIS.Date_Time_Out__c);   
        }
        if(State == 'Closed')
        {
            NewTIS.Date_Time_Out__c=null;
            System.debug('Date/Time Out in create tis'+ NewTIS.Date_Time_Out__c);   
        }
        insert NewTIS;

        return NewTIS.Id;
    }catch (exception e)
    {
        System.debug('@@Error@@ ' + e.getMessage());
        return e.getMessage();
    }

}


public static String CreateNewTISRecord(String ObjectName, String ObjectId, String FieldName,String State, String OwnerName)
{
 try
    {
        TIS_Detail__c NewTIS = new  TIS_Detail__c();
        if(ObjectName == 'Contract_Request__c')
            NewTIS.Contract_Request__c = ObjectId;
            if(ObjectName == 'Case')             
            NewTIS.Case__c = ObjectId; 
                NewTIS.name = FieldName;
        NewTIS.State__c = State;
        NewTIS.Date_Time_In__c = System.now();
        NewTIS.Who__c = UserInfo.getUserId();//Current User
                
        insert NewTIS;

        return NewTIS.Id;
    }catch (exception e)
    {
        System.debug('@@Error@@ ' + e.getMessage());
        return e.getMessage();
    }

}
@future
public static void UpdateTISRecords(String ObjectName, list<String> ObjectIDList,list<String> InOldStateList,list<String> InNewStateList,list<String> RecordOwnerList, list<string> StateNamelist,list<boolean> InsertNewRecordsList, list<boolean> TISClosedList)
{
   System.debug('-------------------UpdateTISRecords-------------------');
   system.debug('Object Name:'+ObjectName);
   
    
   for(integer i = 0; i < ObjectIDList.size(); i++) 
   {
      System.debug('Inside for1');
      String OldStateValue; String NewStateValue;
      OldStateValue = InOldStateList[i];
      NewStateValue = InNewStateList[i];
   
      Boolean UpdateOldCaseTIS = false;  
      Boolean UpdateOldContractRequestTIS = false;
system.debug('before contract req');
      if(ObjectName == 'Contract_Request__c')
      {
        
        for (TIS_Detail__c ContractRequestTIS :[select Id,Contract_Request__c,Date_Time_Out__c from TIS_Detail__c where name =:StateNamelist[i] and State__c = :OldStateValue and Contract_Request__c =:ObjectIDList[i] and Date_Time_Out__c = null limit 1000]) 
        {    
                if(InOldStateList[i] != 'Set-up Complete')
                    ContractRequestTIS.Date_Time_Out__c = System.now();
                    UpdateOldContractRequestTIS = true;
System.debug('Update the "Date_Time_Out__c" in TIS_Detail__c for record Id: "'+ ContractRequestTIS.Id + '"');
                    update ContractRequestTIS;
        }
        
        if(UpdateOldContractRequestTIS || InsertNewRecordsList[i] == true)
        {
System.debug('****CREATE New RECORD for Contract Request TIS ****');
          String result = CreateTIS.CreateTISRecord('Contract_Request__c',ObjectIDList[i], StateNamelist[i] ,NewStateValue, null, TISClosedList[i]);
System.debug('**New record for Contract RequestTIS created in TIS_Detail__c with SID: "'+ result +'" **');
        }
    }
system.debug('before case');    
    if(ObjectName == 'Case') 
    { 
system.debug('inside case');
        for (TIS_Detail__c CaseTIS :[select Id,Case__c,Date_Time_Out__c from TIS_Detail__c where name =:StateNamelist[i] and Case__c =:ObjectIDList[i] and Date_Time_Out__c = null limit 1000]) /////and State__c = :OldStateValue 
        { 
            CaseTIS.Date_Time_Out__c = System.now(); 
            UpdateOldCaseTIS = true; 
System.debug('Update the "Date_Time_Out__c" in TIS_Detail__c for record Id: "'+ CaseTIS.Id + '"'); 
            update CaseTIS; 
        } 
        try{
            if(UpdateOldCaseTIS || InsertNewRecordsList[i] == true)
            { 
    
    System.debug('****CREATE New RECORD for Case TIS****'); 
                String result = CreateTIS.CreateTISRecord('Case',ObjectIDList[i], StateNamelist[i] ,NewStateValue, null, TISClosedList[i]); 
    System.debug('**New record created for Case TIS in TIS_Detail__c with SID: "'+ result +'" **'); 
    
            } 
        }
        catch(Exception e)
        {
            System.debug('Error while creating'+e.getmessage());
        }
    } 

  }


}
}