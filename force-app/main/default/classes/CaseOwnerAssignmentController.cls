Public class CaseOwnerAssignmentController{
/***********************************************************************************
Author: Shruti Karn, Salesforce.com Developer
Tata Consultancy Services Limited
For CR# 19673

************************************************************************************/

//Variable declaration
public String alphabet{get; set;}
public list<User> userList{get; set;}
//Created for holding the actual list of users while sorting alphbetically
public list<User> masterUserList{get; set;}
public String CaseId {get; set;}
public Boolean sendEmail{get; set;}
public String SelectedOwnerId {get; set;}
public Case currentCase {get;set;}
public Boolean asce {get;set;}

public CaseOwnerAssignmentController(ApexPages.StandardController controller)
{
    CaseId = Apexpages.currentPage().getParameters().get('Id');
    alphabet = 'All';
    asce = true;
    ShowUsersInQueues();
}

//Show all users on the click on "Show All Users Button
public PageReference ShowAllUsers()
{
    try
    {
        userList = [Select Id, Name, IsActive, Queue__c from User where IsActive !=null order by name asc limit 1000];
        masterUserList = userList;
        system.debug('User List:'+userList);
    } 
    catch(Exception e)
    {
        system.debug('Exception querying User');
    }
    return null;
}

//Shows users which belongs to a Queue 
public PageReference ShowUsersInQueues()
{
    try
    {
        userList = [Select Id, Name, IsActive, Queue__c from User where IsActive !=null AND Queue__c != null order by name asc limit 1000];
        system.debug('User List:'+userList);
        masterUserList = userList;
    } 
    catch(Exception e)
    {
        system.debug('Exception querying User');
    }
    return null;
}

//Show all users which belongs to a Queue
public PageReference ShowUsersInCurrentQueue()
{
    try
    {
        system.debug('CaseId:'+caseId);
        currentCase = [select id, ownerId, Queue__c from Case where id =: CaseId limit 1];
        userList = [Select Id, Name, IsActive, Queue__c from User where IsActive !=null AND Queue__c =: currentCase.Queue__c order  by name asc limit 1000];
        masterUserList = userList;
        system.debug('User List:'+userList);
    } 
    catch(Exception e)
    {
        system.debug('Exception querying User');
    }
    return null;
}

// for assigning the selected user to the case
public void AssignUser()
{
    try
    {
        userList = [Select Id, Name, IsActive, Queue__c from User where id =:SelectedOwnerId limit 1];
        currentCase = [select id, Queue__c,OwnerId from Case where id =: CaseId limit 1];
        currentCase.OwnerId = userList[0].Id;
        system.debug('Queue:'+userList[0].Queue__c);
        if(userList[0].Queue__c != null)
        currentCase.Queue__c = userList[0].Queue__c;
        else
        currentCase.Queue__c = 'null';
        //For Sending email through Email Header Method
        if(sendEmail == true)
        {
           
            Database.DMLOptions dlo = new Database.DMLOptions();
            dlo.EmailHeader.triggerUserEmail = true;
            currentCase.setOptions(dlo);
           
        }

        update currentCase;
        system.debug('User List:'+userList);
        
    } 
    catch(Exception e)
    {
        system.debug('Exception querying User');
    }
}

// For displaying the sorted list
public PageReference Alphabet_Ordering()
{
 system.debug('Alphabet Selected:'+alphabet);
 userList = masterUserList;
 if(userList.size()>0)
 {
     //If 'All' is selected full list should be displayed
     if(alphabet == 'All')
     {
         return null;
     }
     else
     {
         list<User> sortedList = new list<User>();
         for(integer i=0;i<userList.size();i++)
         {
             String name = userList[i].name;
             if(name.indexof(alphabet) == 0)
             {
                 sortedList.add(userList[i]);
                              
             }
         }
         system.debug('Sorted List:'+sortedList);
         userList = sortedList;
     }
 }
 return null;
}

public PageReference ChangeOrder()
{
    system.debug('inside change order');
    list<User> sortedList = new list<User>();
    integer size = userList.size();
    integer j=0;
    for(integer i=size-1;i>=0;i--)
     {
            sortedList.add(userList[i]);
     }
     userList = sortedList;
     if(asce == true)
         asce = false;
     else
         asce = true;
    system.debug('final asce value:'+asce);
     return null;
}

}