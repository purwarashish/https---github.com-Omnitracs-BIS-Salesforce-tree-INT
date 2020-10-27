@isTest(SeeAllData=true) 
private class  ApexUserInfoTest{  
 
private static testMethod void testSearch() {   

    ApexUserInfo.validateUserForOpptyLock(UserInfo.getUserId(),UserInfo.getProfileId());
    
    Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='testingopptylock@testorg.com');
        insert u;
    system.runAs(u){
        Global_Variable__c objVariable = Global_Variable__c.getInstance('OpptyLock_BlockedUsers');
        objVariable.value__c = u.Id;    
        ApexUserInfo.validateUserForOpptyLock(UserInfo.getUserId(),UserInfo.getProfileId());
    }
}
}