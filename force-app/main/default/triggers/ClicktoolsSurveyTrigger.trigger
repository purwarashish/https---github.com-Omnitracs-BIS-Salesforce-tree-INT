trigger ClicktoolsSurveyTrigger on Survey__c (before insert, before update, after insert, after update, after delete) {
    if(Trigger.isInsert){
        if(Trigger.isAfter){
            ScoringDataUtils.clicktoolsSurveyTrigger(Trigger.new);
        }
		if(Trigger.isBefore){
			CSATSurveyUtils.updateCSATSurveyAccount(Trigger.new);
		}
    }
	if(Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate || Trigger.isDelete)){
		CSATSurveyUtils.updateAvgCSATScore(Trigger.isInsert || Trigger.isUpdate ? Trigger.new : Trigger.old);
	}
}