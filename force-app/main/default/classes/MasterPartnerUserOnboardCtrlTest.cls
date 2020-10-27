@isTest(SeeAllData=true)
private class MasterPartnerUserOnboardCtrlTest {
	
    static testMethod void myUnitTest() {
 	    
 	    Account Acct = GenericTestClass.insertAccount();
 	    Apexpages.currentPage().getParameters().put('Id',Acct.Id);
 	    User thisUser = [SELECT Id, ProfileID FROM User WHERE Id = :UserInfo.getUserId() AND ProfileID = '00e50000000mzNu' LIMIT 1];
 	    
 	    System.runAs(thisUser){
 	    Test.startTest();
            MasterPartnerUserOnboardCtrl mpuocontroller = new  MasterPartnerUserOnboardCtrl(new ApexPages.StandardController(Acct));
            mpuocontroller.save();
        Test.stopTest();
    	}
    }
}