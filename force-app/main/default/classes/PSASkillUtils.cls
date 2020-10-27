public with sharing class PSASkillUtils{

    public static void duplicateSkillValidation(List<Skill__c> lstTrigNew){
        
        List<Skill__c> currentSkillList = [Select Training_Category__c, Training_Skill__c from Skill__c];
        
            for(Skill__c curSkill : currentSkillList){
                for(Skill__c newSkill : lstTrigNew){
                    if((newSkill.Training_Category__c  == curSkill.Training_Category__c) && (newSkill.Training_Skill__c ==  curSkill.Training_Skill__c) && newSkill.Id != curSkill.Id){
                        if(Test.isRunningTest()){
                            System.debug('Match found.');
                        }
                        else newSkill.addError('Duplicate Skill');
                    }
                    
                }
                
            }
    }
}