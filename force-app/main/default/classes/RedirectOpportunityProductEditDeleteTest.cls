@isTest(SeeAllData=True)
private class RedirectOpportunityProductEditDeleteTest {
	static testMethod void myUnitTest() {

		Profile p1 = [Select Id from Profile where NOT(Name in :Restricted_OLI_Profiles__c.getAll().keySet() and Id = :userInfo.getProfileId()) limit 1];

		ApexPages.currentPage().getParameters().put('common.udd.actions.ActionsUtilORIG_DELETE_URI', ApexPages.currentPage().getParameters().get('id'));
		
			Test.startTest();
			RedirectOpportunityProductEditDelete roped = new RedirectOpportunityProductEditDelete(new ApexPages.StandardController(p1));
			roped.redirectOli();
			Test.stopTest();
		
		
		
		
	}
	
	static testMethod void myUnitTest1() {
			ApexPages.currentPage().getParameters().put('common.udd.actions.ActionsUtilORIG_DELETE_URI', ApexPages.currentPage().getParameters().get('id'));
			Profile p1 = [Select Id from Profile where NOT(Name in :Restricted_OLI_Profiles__c.getAll().keySet() and Id = :userInfo.getProfileId()) limit 1];
			Profile p0 = [Select Id, Name from profile where id != :p1.id and Name in :Restricted_OLI_Profiles__c.getAll().keySet() limit 1];
			UserRole r = new UserRole(name = 'TEST ROLE');
			User testUser = GenericTestClass.insertUser(p0, r);
			
		System.runAs(testUser){
			
			Profile p2 = [Select Id from Profile where Name in :Restricted_OLI_Profiles__c.getAll().keySet() and Id = :userInfo.getProfileId()limit 1];
			//ApexPages.currentPage().getParameters().put('common.udd.actions.ActionsUtilORIG_DELETE_URI');
			Test.startTest();
			Test.setCurrentPage(Page.RedirectOpportunityProductEditDelete);
			RedirectOpportunityProductEditDelete roped1 = new RedirectOpportunityProductEditDelete(new ApexPages.StandardController(p2));
			roped1.redirectOli();
			Test.stopTest();
		}
		}

}