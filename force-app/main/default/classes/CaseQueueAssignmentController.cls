public class CaseQueueAssignmentController{

/***********************************************************************************
Author: Shruti Karn, Salesforce.com Developer
Tata Consultancy Services Limited
For CR# 19673

************************************************************************************/

//Variable declaration

public list<QueueSobject> QueueList {get; set;}
public String CaseId {get; set;}
public Boolean sendEmail{get; set;}
public String SelectedOwnerId {get; set;}
public Case currentCase {get;set;}
public Boolean asce {get;set;}


public CaseQueueAssignmentController(ApexPages.StandardController controller)
{
    CaseId = Apexpages.currentPage().getParameters().get('Id');
    asce = true;
    ShowQueues();
}


//For getting the QueueList for cases
public void ShowQueues()
{
    QueueList = [Select Id, QueueId, SobjectType, Queue.Id, Queue.Name, Queue.Type From QueueSobject where SobjectType = 'Case' AND Queue.Type = 'Queue' order by Queue.Name asc limit 1000];
}

// for assigning the selected queue to the case
public void AssignUser()
{
    system.debug('inside queue');
    try
    {
        
        
        Integer indx = integer.valueof(SelectedOwnerId.trim());
        currentCase = [select id, Queue__c,OwnerId from Case where id =: CaseId limit 1];
        String OwnerId = QueueList[indx].QueueId;
        OwnerId = OwnerId.substring(0,15);
        currentCase.OwnerId = OwnerId;
        currentCase.Queue__c = QueueList[indx].Queue.Name;
        if(sendEmail == true)
        {
           
            Database.DMLOptions dlo = new Database.DMLOptions();
            dlo.EmailHeader.triggerUserEmail = true;
            currentCase.setOptions(dlo);
           
        }

        update currentCase;
        
        
        
    } 
    catch(Exception e)
    {
        
        system.debug('Exception querying User'+e);
        
        
        
    }
    
}

//For arranging the list in asecnding or descending order
public PageReference ChangeOrder()
{
    list<QueueSobject> sortedList = new list<QueueSobject>();
    integer size = QueueList.size();
    integer j=0;
    for(integer i=size-1;i>=0;i--)
     {
            sortedList.add(QueueList[i]);
     }
            
    QueueList = sortedList;
    if(asce == true)
        asce = false;
    else
        asce = true;
    return null;
}

}