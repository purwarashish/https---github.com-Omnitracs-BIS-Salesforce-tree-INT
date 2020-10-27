public class ShowAllActivitiesControllerr {
    
public Lead selectedLead {get;set;}
public Account selectedAcc {get;set;}
public  String id{get;set;}
public  String typeOfData{get;set;}
    
public ShowAllActivitiesControllerr()
{
 if(ApexPages.currentPage().getParameters().containsKey('id'))
 {
  id = ApexPages.currentPage().getParameters().get('id');
  typeOfData = ApexPages.currentPage().getParameters().get('type');
  //If the data to display is activity history
  if(typeOfData=='AH')
  {
   if(id.startsWith('001'))
   selectedAcc = [SELECT Name,QWBS_Cust_ID__c, QWBS_Status__c ,BillingCity, BillingState, OwnerId, 
                  (Select WhoId, Subject, Status, IsTask, ActivityDate, LastModifiedDate, OwnerId, WhatId From ActivityHistories order by LastModifiedDate desc limit 1000 )                                    
                  FROM Account where id = :id];
   if(id.startsWith('00Q'))
   selectedLead = [SELECT Name, Title, Status, Company, City, State, ownerId, 
                  (Select WhoId, Subject, Status, IsTask, ActivityDate, LastModifiedDate, OwnerId From ActivityHistories order by LastModifiedDate desc  limit 1000 )                  
                  FROM Lead where id = :id ];
  }
  
  //If the data to display is open activities
  if(typeOfData=='OA')
  {
   if(id.startsWith('001'))
   selectedAcc = [SELECT Name,QWBS_Cust_ID__c, QWBS_Status__c ,BillingCity, BillingState, OwnerId,                  
                  (Select WhoId, WhatId, IsTask, Subject, OwnerId, Status, Priority, ActivityDate From OpenActivities order by LastModifiedDate desc  limit 1000 )                   
                  FROM Account where id = :id];
   if(id.startsWith('00Q'))
   selectedLead = [SELECT Name, Title, Status, Company, City, State, ownerId, 
                  (Select WhoId, WhatId, IsTask, Subject, OwnerId, Status, Priority, ActivityDate From OpenActivities order by LastModifiedDate desc  limit 1000 ) 
                  FROM Lead where id = :id ];
  }
 }
 
}

}