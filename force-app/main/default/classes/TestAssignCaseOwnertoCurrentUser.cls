@isTest(SeeAllData = true)
private class TestAssignCaseOwnertoCurrentUser{
    private static testMethod void testAssigneCases()
    {
        Case caseRecord = new Case();
        CaseRecord.Origin = 'Email';
        insert CaseRecord;

        Profile p = [select id from profile where name = 'System Administrator'];
    
        User olduser = new User(alias = 'standt', email='standarduser@omnitracs.com',
                   emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',                
                   localesidkey='en_US',timezonesidkey='America/Los_Angeles',
                   username='standarduser111@omnitracs.com',ProfileId=p.Id);
        insert olduser;
        
        AssignOwnershiptoMe.AssignCaseOwnertoCurrentUser(CaseRecord.id,olduser.id,'');
        AssignOwnershiptoMe.AssignCaseOwnertoCurrentUser(CaseRecord.id,'','');
    
    }

}