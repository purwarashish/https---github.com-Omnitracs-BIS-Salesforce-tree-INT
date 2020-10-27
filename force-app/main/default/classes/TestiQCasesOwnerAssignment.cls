@isTest(SeeAllData =true)
private class TestiQCasesOwnerAssignment {
    static Account testAccount = GenericTestClass.insertAccount();
    static Account testAccount1 = GenericTestClass.insertAccount();
    Static contact testContact = GenericTestClass.insertContact(testAccount.id);
   // Static contact testContact1 = GenericTestClass.insertContact(testAccount1.id);
    static Case testCase = GenericTestClass.insertCase(testAccount.id,testContact.id);
    static Case testCase1 = GenericTestClass.insertCase(testAccount1.id,testContact.id);
    static Contact cont;
    static Case testCase3 = GenericTestClass.insertCase(testAccount1.id,null);
    private static testMethod void tiQCasesOwnerAssignment(){
        //iQCasesOwnerAssignment iQCaseOwnerAssign =new iQCasesOwnerAssignment();
        iQCasesOwnerAssignment.changeOwner(testCase.id,'1234',testAccount.id);
        iQCasesOwnerAssignment.changeOwner(testCase1.id,'12343',testAccount1.id);
        Profile p = [select id from profile where name = 'System Administrator'];
        User olduser = new User(alias = 'standt', email='standarduser@omnitracs.com',
                   emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',                
                   localesidkey='en_US',timezonesidkey='America/Los_Angeles',
                   username='standarduser111@omnitracs.com',ProfileId=p.Id);
        insert olduser;
        testAccount1.CSR__c = olduser.id;
        update testAccount1;
     }
     private static testMethod void tiQCasesOwnerAssignment1(){
        iQCasesOwnerAssignment.changeOwner(testCase3.id,'',testAccount1.id);
        
        
    }
}