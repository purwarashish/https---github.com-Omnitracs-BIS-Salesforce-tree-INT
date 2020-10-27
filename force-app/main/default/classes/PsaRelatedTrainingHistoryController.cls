/*
Author : TCS Banglore offshore Team
Summary:This page act as a controller for the PsaRelatedTrainingHistory vf page,which displays the related training history records of a particular contact  
*/

public class PsaRelatedTrainingHistoryController
{
    public id historyRecordId {get;set;}
    public List<Training_History__c> lstTrainingHistory{get;set;}
    public List<tableWrapper> lstTrainingHistoryWrapper{get;set;}
    
    public final Contact objContact{get;set;}  
    public boolean headrDisplay{get;set;}
        
    public PsaRelatedTrainingHistoryController(ApexPages.StandardController stdController)
    {       
        this.objContact = (Contact)stdController.getRecord();
        headrDisplay=true;
        ExceuteQuery();
        
    }       
    
    public pageReference deleteRecord()
    {
         historyRecordId = ApexPages.currentPage().getParameters().get('TrainingHistoryId');  
         
         if(historyRecordId!=null)
         {   
            Training_History__c objTrainingHistory=[Select Id from Training_History__c where Id=:historyRecordId Limit 1];       
            delete objTrainingHistory; 
        }      
        return null;     
    }       
    public void ExceuteQuery()
    {     
        lstTrainingHistory=[select Id,Name,Class_Name__c,Class_Name__r.Name,Class_Name__r.Course__c,Class_Name__r.Class_Name__c,Contact__r.Id, 
                   Class_Name__r.Course__r.Course_Type__c,Class_Name__r.Instructor__r.FirstName,Class_Name__r.Instructor__r.LastName,
                   Completion_Status__c,Completion_Date__c,Registration_Date__c,Registration_Status__c from Training_History__c where Contact__r.Id=:objContact.Id  ORDER BY Completion_Date__c DESC 
                    NULLS LAST];
       
       if(lstTrainingHistory.size()==0)
       {
            headrDisplay=false;
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Info,'No record found');
            ApexPages.addMessage(myMsg);
       }
       if(lstTrainingHistory.size()>0){
           tableWrapper objWrap;
           lstTrainingHistoryWrapper=new List<tableWrapper>();
           for(Training_History__c obj:lstTrainingHistory){
               objWrap=new tableWrapper();
               objWrap.Idcode=obj.Id;
               objWrap.className=obj.Class_Name__r.Class_Name__c;
               objWrap.classId=obj.Class_Name__c;
               objWrap.courseType=obj.Class_Name__r.Course__r.Course_Type__c;
               objWrap.trainer=obj.Class_Name__r.Instructor__r.FirstName + ' ' + obj.Class_Name__r.Instructor__r.LastName;
               objWrap.registration=convertDate(obj.Registration_Date__c);
               objWrap.completion=convertDate(obj.Completion_Date__c);
               lstTrainingHistoryWrapper.add(objWrap);
           }
       }
    } 
    
     public pageReference trainingHistoryHelp()
     {
       return new PageReference('https://help.salesforce.com/htviewhelpdoc?id=co_relatedlist.htm&siteLang=en_US');
     }
     
     public string convertDate(Date dt){
         if(dt==null){
             return null;
         }
         string strDt;
         string strFinalDate;
         strDt=string.valueOf(dt.month());
         
         if(strDt.length()==1){
             strFinalDate='0'+strDt;
         }
         else{
             strFinalDate=strDt;
         }
         strDt=string.valueOf(dt.day());
         if(strDt.length()==1){
             strFinalDate=strFinalDate+'/0'+strDt;
         }
         else{
             strFinalDate=strFinalDate+'/'+strDt;
         }
         strDt=string.valueOf(dt.year());
         strFinalDate=strFinalDate+'/'+strDt;
         return strFinalDate;

     }
     
     public class tableWrapper{
         public Id Idcode{get;set;}
         public string className{get;set;}
         public string courseType{get;set;}
         public string trainer{get;set;}
         public string registration{get;set;}
         public string completion{get;set;}
         public Id classId{get;set;}
         public tableWrapper(){
             
         }
         
     }       
}