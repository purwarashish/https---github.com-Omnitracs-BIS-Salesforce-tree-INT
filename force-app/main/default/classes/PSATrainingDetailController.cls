/*
Author : TCS Banglore offshore Team
Summary:This page act as a controller for the PSATrainingDetail vf page,which displays the training information and training history of a particular contact 
*/

public with sharing class PSATrainingDetailController 
{

      public Contact contactDetail {get;set;} 
      
      public List<Training_Information__c> webinarList{get; set;}
  
      public List<Training_Information__c> learninglabList{get; set;}
    
      public List<Training_History__c> trainingHistoryList{get; set;}
      
      public Boolean webinarFlag{get; set;}
      public Boolean learninglabFlag{get; set;}
      public Boolean trainingHistoryFlag{get; set;}
      
      public Boolean webinarMsgFlag{get; set;}
      public Boolean learninglabMsgFlag{get; set;}
      public Boolean trainingHistoryMsgFlag{get; set;}      
          
  public PSATrainingDetailController(ApexPages.StandardController stdController) 
  {
     
      webinarFlag=True;
      learninglabFlag=True;
      trainingHistoryFlag=True;
      
      webinarMsgFlag=False;
      learninglabMsgFlag=False;
      trainingHistoryMsgFlag=False;            
      
     this.contactDetail= (Contact)stdController.getRecord();
      Id cid= contactDetail.Id;                 
      contactDetail = [SELECT Id, LastName,User_Status__c, FirstName, AccountId, Email, MobilePhone, Phone, Department, Fax, ReportsTo.Name, 
                       OtherPhone, Description, CreatedById, LastModifiedById FROM Contact WHERE Id =: cid];
        
         If(cid!=null)
        {
         detail(cid);
        }

     }
     
    public void detail(Id cid)
    {
               
      webinarList=[SELECT Id, Name, Start_Date__c, End_Date__c, Status__c FROM Training_Information__c Where (Training_Information__c.Contact__r.Id =: cid)AND(RecordType.Name='Webinar')];

      learninglabList=[SELECT Id, Name, Start_Date__c, End_Date__c, Status__c FROM Training_Information__c Where (Training_Information__c.Contact__r.Id =: cid)AND(RecordType.Name='Learning Lab')];

      trainingHistoryList =[Select Id, Name, Registration_Date__c, Completion_Date__c, Trainer__c, Training_History__c.Class_Name__r.Class_Name__c, Training_History__c.Class_Name__r.Id, 
                            Training_History__c.Class_Name__r.Course__r.Course_Type__c From Training_History__c 
                            where Training_History__c.Contact__r.Id =:cid ORDER BY Completion_Date__c DESC NULLS LAST] ;
                                               
        If(webinarList.size()==0)
        {
          webinarFlag=False;
          webinarMsgFlag=True;
   
           ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Info,'No record found.');
           ApexPages.addMessage(myMsg);
        }
        
        If(learninglabList.size()==0)
        {
           learninglabFlag=False;
           learninglabMsgFlag=True;
           ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Info,'No record found.');
           ApexPages.addMessage(myMsg);
        }
        
        If(trainingHistoryList.size()==0)
        {
           trainingHistoryFlag=False;
           trainingHistoryMsgFlag=True;
           ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Info,'No record found.');
           ApexPages.addMessage(myMsg);
        }

    }  
}