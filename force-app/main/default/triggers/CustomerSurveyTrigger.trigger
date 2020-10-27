/**
	* CustomerSurveyTrigger - <description>
	* Created by BrainEngine Cloud Studio
	* @author: Cody Worth
	* @version: 1.0
*/

trigger CustomerSurveyTrigger on Customer_Survey__c bulk (before insert, after insert, before update, after update, after delete) {
	
	if(Trigger.isBefore){
    	if(Trigger.isInsert){
			CustomerSurveyUtils.surveyToTracking(Trigger.new);
			CustomerSurveyUtils.NPSSurveyCompleted(Trigger.new);
			CustomerSurveyUtils.detectDuplicateSurveys(Trigger.new);
    	}
		if(Trigger.isUpdate){
			CustomerSurveyUtils.NPSSurveyCompleted(Trigger.new);
		}
	}
	
	if(Trigger.isAfter){
		if(Trigger.isInsert){
			CustomerSurveyUtils.calculateAverageOfAverages(Trigger.new);
			CustomerSurveyUtils.createSurveyLog(Trigger.new);
		}
	}
	
	if(Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate || Trigger.isDelete)){
		String triggerAction = (Trigger.isInsert ? 'insert' : (Trigger.isUpdate ? 'update' : 'delete'));
		List<Customer_Survey__c> objList = Trigger.isInsert || Trigger.isUpdate ? Trigger.new : Trigger.old;
		NPSSurveyUtils.updateAvgNPSScore(objList, triggerAction);
	}
}