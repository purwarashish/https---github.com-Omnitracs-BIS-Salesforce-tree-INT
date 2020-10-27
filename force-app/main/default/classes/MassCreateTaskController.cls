public Class MassCreateTaskController{

/***********************************************************************************
Author: Shruti Karn, Salesforce.com Developer
Tata Consultancy Services Limited
For CR# 19673

************************************************************************************/

//Variable Declarations

public Task TaskNew {get;set;} 
public String msg {get;set;}
public String comments {get;set;}
public String search_value {get;set;}
public Boolean displayMessage {get;set;}
public list<User> userList {get; set;}
public String[] selectedUsers = new String[]{};
Public List<SelectOption> options = new List<SelectOption>();
public String[] finallist = new String[]{};
public String current_Value {get;set;}
Public List<SelectOption> Users = new List<SelectOption>();
Public List<SelectOption> statusList = new List<SelectOption>();
Public List<SelectOption> priorityList = new List<SelectOption>();
Public String taskStatus {get;set;}
Public String taskPriority {get;set;}
Public String ObjectType {get;set;}
public String objectSel {get;set;}

Map<Id,SelectOption> LeftMap = new Map<Id,SelectOption>();
Map<Id,SelectOption> RightMap = new Map<Id,SelectOption>();

//Setters and getters

public String[] getfinallist()
{
    return finallist;
}
    
public void setfinallist (String[] finallist) 
{
    this.finallist= finallist;
}

public void setoptions  (List<SelectOption> options )
{
    for(integer i=0;i<options.size();i++)
    this.options.add(options[i]) ;
}

public List<SelectOption> getoptions  ()
{
    options.clear();
    options=RightMap.values();
    options = sortList(options);

    return options ;
}

public void setUsers  (List<SelectOption> Users )
{

    for(integer i=0;i<Users.size();i++)
    this.Users.add(Users[i]) ;

}

public List<SelectOption> getUsers  ()
{
    users.clear();
    users=LeftMap.values();
    users = sortList(users);
    system.debug('users.size():'+users.size());
    return users;
}

public String[] getSelectedUsers()
{
    return selectedUsers;
}
    
public void setSelectedUsers (String[] selectedUsers ) 
{
    this.selectedUsers = selectedUsers ;
}

public void setStatusList  (List<SelectOption> StatusList )
{

    this.StatusList = StatusList;
}

public List<SelectOption> getStatusList()
{
    return StatusList ;
}

public void setPriorityList  (List<SelectOption> priorityList )
{

    this.priorityList = priorityList;
}

public List<SelectOption> getPriorityList()
{
    return priorityList ;
}

//Constructor for the class in which default value for 'Account' is set

public MassCreateTaskController(ApexPages.StandardController controller)
{
    TaskNew = new Task();
    objectSel = '001';
      
    Schema.DescribeFieldResult fieldResult = Task.Status.getDescribe();
    List<Schema.PicklistEntry> picklistEntries = fieldResult.getPicklistValues();
    for (Schema.PicklistEntry entry : picklistEntries)
        statusList.add(new SelectOption(entry.getLabel(), entry.getValue()));
    
    Schema.DescribeFieldResult fieldResult2 = Task.Priority.getDescribe();
    List<Schema.PicklistEntry> picklistEntries2 = fieldResult2.getPicklistValues();
    for (Schema.PicklistEntry entry : picklistEntries2)
        priorityList.add(new SelectOption(entry.getLabel(), entry.getValue()));

    userList = [select Id, Name from User WHERE isActive = true order by name limit 1000];
    RetrieveUsers();
}

//To get the list of all active users and put it into LeftMap from which the Available Users list is displayed

Public PageReference RetrieveUsers()
{
    
       LeftMap.clear();
       system.debug('LeftMap:'+LeftMap);
       system.debug('list:'+userList);
       if(userList.size()>200)
       {
           displayMessage =true;
           msg = 'Your Search returned '+userList.size()+' users. Only 200 users are displayed.Please refine your search criteria';
           for (Integer i = 0 ; i< 200 ; i++)
           {
                system.debug('userlist[i]:'+userList[i]);
                LeftMap.put(userList[i].Id,new SelectOption(userList[i].Id,userList[i].name));
        
           }
       }
       else
       {
           displayMessage = false;
           for (Integer i = 0 ; i< userList.size() ; i++)
           {
                LeftMap.put(userList[i].Id,new SelectOption(userList[i].Id,userList[i].name));
            }
        }
    system.debug('LeftMap:'+LeftMap.values());
    return null;
}

//To add Users to the Selected Users List

public void AddUsers()
{
    for (Integer i = 0 ; i<selectedUsers.size() ; i++)
    {
        RightMap.put(selectedUsers[i],LeftMap.get(selectedUsers[i]));
        LeftMap.remove(selectedUsers[i]);
        
    }
    
}

//To remove users from Selected Users and adding it to Avalable Users List

public void RemoveUsers()
{
    system.debug('finallist:'+finallist);
for (Integer i = 0 ; i<  finallist.size() ; i++)
    {
        LeftMap.put(finallist[i],RightMap.get(finallist[i]));
        RightMap.remove(finallist[i]);
        system.debug('RightMap:'+RightMap);
        
    }
  

}

public PageReference Save()
{
    
    Set<Id> SelectedId = RightMap.keySet();
    
    if(RightMap.isEmpty())
    {
       ApexPages.Message msg1 = new ApexPages.Message(ApexPages.Severity.WARNING,'Please select at least one User');
       ApexPages.addmessage(msg1); 
       return null;
    }

    if(TaskNew.Subject == null)
    {
        ApexPages.Message msg1 = new ApexPages.Message(ApexPages.Severity.WARNING,'Please Select a Subject');
        ApexPages.addmessage(msg1); 
        return null;
    }

    if(TaskNew.ActivityDate == null)
    {
        ApexPages.Message msg1 = new ApexPages.Message(ApexPages.Severity.WARNING,'Please Select Due Date');
        ApexPages.addmessage(msg1); 
        return null;
    }
    
    /*if(current_Value == '')
    {
        ApexPages.Message msg1 = new ApexPages.Message(ApexPages.Severity.WARNING,'You must select a record for which task task will be created');
        ApexPages.addmessage(msg1); 
        return null;
    }*/

    List<task> taskList = new List<task>();
    for (Id theKey:RightMap.keySet() )
    {
        Task newTask = new Task();
        newTask.Subject = TaskNew.Subject;
        newTask.Status = taskStatus;
        newTask.Priority = taskPriority;
        newTask.OwnerId = theKey;
        if(current_value != '')
        newTask.WhatId = current_Value;
        newTask.Description = comments;
        newTask.ActivityDate = TaskNew.ActivityDate;
        taskList.add(newTask);
    }
    insert taskList;
    String ActivatedURL = '/home/home.jsp';
    PageReference PageRef = new PageReference(ActivatedURL);
    PageRef.setRedirect(true);
    return PageRef;
}

public PageReference Search()
{
    if(search_value.trim() != '')
    {
        String strsql = 'select id,name from User where isActive = true ';
        String subsql1 = 'and name like'+'\''+ search_value + '%\'';
        strsql = strsql + subsql1;
        system.debug('strsql:'+strsql);
        userList= database.query(strsql);
    }
    else
    {
        userList = [select Id, Name from User WHERE isActive = true order by name asc limit 1000];
    }
    RetrieveUsers();
    return null;
}

list<SelectOption> sortList(list<SelectOption> unsortedList)
{
    for(integer i=1;i<unsortedList.size();i++)
    {
        for(integer j=0;j<unsortedList.size()-i;j++)
        {
            if(unsortedList[j].getLabel()>unsortedList[j+1].getLabel())
            {
                SelectOption temp = unsortedList[j];
                unsortedList[j] = unsortedList[j+1];
                unsortedList[j+1] = temp;
            }
        }
    }
    return unsortedList;
}
}