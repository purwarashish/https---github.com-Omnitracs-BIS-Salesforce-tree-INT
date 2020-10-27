/**************************************************************************************************************************
Developer                Date           Description
Sripathi Gullapalli      3/8/2016       Trigger handler class to send a notification when the Project completion is > 50%
****************************************************************************************************************************/
public with sharing class ProjectTriggerHandler{
    
    List<pse__Proj__c> newProjList;
    Map<Id, pse__Proj__c> oldProjMap;
    public ProjectTriggerHandler(List<pse__Proj__c> newList, Map<Id, pse__Proj__c> oldMap){
        this.newProjList = newList;
        this.oldProjMap = oldMap;
    }
    
    //Method to send a notification when the Project completion is > 50%
    public void sendProjectNotification(){
        List<pse__Proj__c> notificationList = new List<pse__Proj__c>();
        Set<Id> managerSet = new Set<Id>();
        pse__Proj__c oldProj;
        for(pse__Proj__c newProj : newProjList){
            if(oldProjMap != null && oldProjMap.size() > 0){
                oldProj = oldProjMap.get(newProj.Id);
                if(oldProj.project_percent_complete__c != newProj.project_percent_complete__c && newProj.project_percent_complete__c >= 50.0){
                    notificationList.add(newProj);  
                }
            }
            else if(newProj.project_percent_complete__c >= 50.0){
                notificationList.add(newProj);  
            }
            
            if(String.isNotBlank(newProj.pse__Project_Manager__c)){
                managerSet.add(newProj.pse__Project_Manager__c);
            }
        }
        
        if(notificationList.size() > 0){
            EmailUtils.sendNotificationEmails(notificationList, managerSet);
        }
    }
   
}