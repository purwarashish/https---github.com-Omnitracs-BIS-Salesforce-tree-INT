/***********************************************************************************************************
Developer                Date           Description
Sripathi Gullapalli      3/8/2016       Trigger to send a notification when the Project completion is > 50%
************************************************************************************************************/
trigger ProjectTrigger on pse__Proj__c bulk (before insert, before update, after insert,after update) {
    if(Trigger.isBefore){
        if(Trigger.isUpdate){
            OmniSurveyTrackingUtils.createProjectSurveyTrackingObj(Trigger.OldMap, Trigger.New);
        }
    }
    if(Trigger.isAfter){
        ProjectTriggerHandler pth = new ProjectTriggerHandler(Trigger.New, Trigger.OldMap);
        pth.sendProjectNotification();
    }
}