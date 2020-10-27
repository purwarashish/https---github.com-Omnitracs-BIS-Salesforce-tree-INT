/**
	* PSASkillTrigger - <description>
	* Created by BrainEngine Cloud Studio
	* @author: Cody Worth
	* @version: 1.0
*/

trigger PSASkillTrigger on Skill__c (before insert,before update) {
	if(Trigger.isBefore){
		if(Trigger.isUpdate || Trigger.isInsert){
			PSASkillUtils.duplicateSkillValidation(trigger.new);
		}
	}

}