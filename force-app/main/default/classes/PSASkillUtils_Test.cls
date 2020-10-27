@isTest
private class PSASkillUtils_Test {
	static testMethod void myUnitTest() {
		// TO DO: implement unit test
		Skill__c testSkill1 = new Skill__c();
		testSkill1.Training_Category__c = 'Test Category';
		testSkill1.Training_Skill__c = 'Test Skill';
		insert testSkill1;
		
		Test.startTest();
			Skill__c testSkill2 = new Skill__c();
			testSkill2.Training_Category__c = 'Test Category';
			testSkill2.Training_Skill__c = 'Test Skill';
			insert testSkill2;
		Test.stopTest();
		}
}