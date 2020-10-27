trigger CaseTISDetail on Case (after insert, after update)
{
/***********************************************************************************
Date: 03/01/2010
Author: Shruti Karn, Salesforce.com Developer
Tata Consultancy Services Limited

Overview: When a Case is Created or Edited, the trigger tracks and captures the changes in the following Case fields:
1) Status
2) Queue


************************************************************************************/

   /* BypassTriggerUtility u = new BypassTriggerUtility();  
     if (u.isTriggerBypassed()) {
         return;
     }

String result;//contains the new record's SID/Error details of insert operation
list<String> CaseList = new list<String>();
list<String> CaseOldStateList = new list<String>();
list<String> CaseNewStateList = new list<String>();
list<String> StateNameList = new list<String>();
list<Boolean> TISClosedList = new list<Boolean>();////determines whether the TIS record should be created with "Date time Out" as NOT NULL
list<boolean> InsertNewRecordsList = new list<boolean>();

if (Trigger.isInsert && CreateTIS.getInsertCounter() ==0 )
{
    System.debug('----------------------- Insert Operation---------------------------');

    for (Case csnew :Trigger.new)
    {
        String OwnerName= '';
        if(csnew.status != null)
        {
System.debug('****CREATE RECORD for "Case Status"');
            result = CreateTIS.CreateNewTISRecord('Case',csnew.Id, 'Status',csnew.status, null);
System.debug('**New record created in TIS_Detail__c with SID: "'+ result +'" **');
        }

        if(csnew.Queue__c != null)
        {
            for (User UserRecord :[Select Name,UserType from User where Id=:csnew.OwnerId limit 1])
            {
                OwnerName = UserRecord.Name;
            }
System.debug('****CREATE RECORD for "Current Queue"');
system.debug('Queue:'+csnew.Queue__c);
            result = CreateTIS.CreateNewTISRecord('Case',csnew.Id, 'Queue',csnew.Queue__c, OwnerName);
System.debug('**New record created in TIS_Detail__c with SID: "'+ result +'" **');
        }

    }

    CreateTIS.setInsertCounter();
System.debug('-- End of Trigger "CaseTISDetail" on Case--');

}else if ((Trigger.isUpdate && CreateTIS.getInsertCounter() ==1 ) || (Trigger.isUpdate && CreateTIS.getUpdateCounter() < 2 ))
{
System.debug('------------------- Update Operation--------------------'+ CreateTIS.getUpdateCounter());

    CaseList.clear(); //Clearing the list
    CaseOldStateList.clear();
    CaseNewStateList.clear();
    StateNameList.clear();
    InsertNewRecordsList.clear();
system.debug('getInsertCounter():'+CreateTIS.getInsertCounter());
system.debug('CreateTIS.getUpdateCounter():'+CreateTIS.getUpdateCounter());

    for(integer i = 0; i < Trigger.new.size(); ++i)
    {
System.debug('#1# Creating list of Case Id with changed "Case Status"');
        if (Trigger.new[i].status != Trigger.old[i].status)
        {
System.debug('Case ID is ' + Trigger.new[i].Id);
            if(CreateTIS.getInsertCounter() ==1)
            {

                CaseList.add(Trigger.new[i].Id);
                CaseOldStateList.add(Trigger.old[i].status);
                CaseNewStateList.add(Trigger.new[i].status);
                InsertNewRecordsList.add(true);
                StateNameList.add('Status');
                if(Trigger.new[i].status == 'Closed')
                {
                    TISClosedList.add(true);
                }else
                {
                    TISClosedList.add(false);
                }

            }else if(CreateTIS.getUpdateCounter() == 0)
            {
System.debug('==>==>There are Cases with Changed Case Status');
                CreateTIS.CaseStatusMap.put(Trigger.new[i].Id,Trigger.new[i].status);
                CaseList.add(Trigger.new[i].Id);
system.debug('Old:'+Trigger.old[i].status);
system.debug('New:'+Trigger.new[i].status);

                CaseOldStateList.add(Trigger.old[i].status);
                CaseNewStateList.add(Trigger.new[i].status);
                if(Trigger.old[i].status == 'Closed')
                {
                    InsertNewRecordsList.add(true);
                }else
                {
                    InsertNewRecordsList.add(false);
                }
                StateNameList.add('Status');
                if(Trigger.new[i].status == 'Closed')
                {
                    TISClosedList.add(true);
                }else
                {
                    TISClosedList.add(false);
                }

            }
            if(CreateTIS.getUpdateCounter() == 1)
            {
                if(CreateTIS.CaseStatusMap.get(Trigger.new[i].Id) != Trigger.new[i].status)
                {
System.debug('==>==>There are Cases with Changed Case Status');
                    CaseList.add(Trigger.new[i].Id);
                    CaseOldStateList.add(Trigger.old[i].status);
                    CaseNewStateList.add(Trigger.new[i].status);
                    if(Trigger.old[i].status == 'Closed')
                    {
                        InsertNewRecordsList.add(true);
                    }else
                    {
                        InsertNewRecordsList.add(false);
                    }
                    StateNameList.add('Status');
                    if(Trigger.new[i].status == 'Closed')
                    {
                        TISClosedList.add(true);
                    }else
                    {
                        TISClosedList.add(false);
                    }
                }

            }
        }

System.debug('#2# Creating list of Case Id with changed "Current Queue"1');
        if ((Trigger.new[i].Queue__c != Trigger.old[i].Queue__c) || ((Trigger.new[i].status != Trigger.old[i].status) && Trigger.old[i].status == 'Closed' ))
        {
System.debug('Case ID is ' + Trigger.new[i].Id);
        if(CreateTIS.getInsertCounter() ==1)
        {
System.debug('==>==>There are Cases with Changed Case Current Queue');
            CaseList.add(Trigger.new[i].Id);
            CaseOldStateList.add(Trigger.old[i].Queue__c);
            CaseNewStateList.add(Trigger.new[i].Queue__c);
            InsertNewRecordsList.add(true);
            StateNameList.add('Queue');
            TISClosedList.add(false);
        }else if(CreateTIS.getUpdateCounter() == 0)
        {
system.debug('==>==>There are Cases with Changed Case ');
            CreateTIS.CaseCurrentMap.put(Trigger.new[i].Id,Trigger.new[i].Queue__c);
            CaseList.add(Trigger.new[i].Id);
            CaseOldStateList.add(Trigger.old[i].Queue__c);
            CaseNewStateList.add(Trigger.new[i].Queue__c);
            if(Trigger.old[i].status == 'Closed' || (Trigger.old[i].Queue__c == null && Trigger.new[i].Queue__c != null))
            {
                InsertNewRecordsList.add(true);
            }else
            {
                InsertNewRecordsList.add(false);
            }
                StateNameList.add('Queue');
                TISClosedList.add(false);
            }
            if(CreateTIS.getUpdateCounter() == 1)
            {
                if(CreateTIS.CaseCurrentMap.get(Trigger.new[i].Id) != Trigger.new[i].Queue__c)
                {
System.debug('==>==>There are Cases with Changed Case Current Queue');
                    CaseList.add(Trigger.new[i].Id);
                    CaseOldStateList.add(Trigger.old[i].Queue__c);
                    CaseNewStateList.add(Trigger.new[i].Queue__c);
                    if(Trigger.old[i].status == 'Closed')
                    {
                        InsertNewRecordsList.add(true);
                    }else
                    {
                        InsertNewRecordsList.add(false);
                    }
                    StateNameList.add('Queue');
                    TISClosedList.add(false);
                }

            }

        }


    }///for loop

    if (!CaseList.isEmpty())
    {
system.debug('InsertNewRecordsList in trigger:'+InsertNewRecordsList);
        CreateTIS.UpdateTISRecords('Case',CaseList, CaseOldStateList, CaseNewStateList, null, StateNameList, InsertNewRecordsList, TISClosedList);
    }


    if(CreateTIS.getInsertCounter() ==1) CreateTIS.setInsertCounter();
    CreateTIS.setUpdateCounter();
System.debug('-- End of Trigger "CaseTISDetail" on Case--');

}*/
}