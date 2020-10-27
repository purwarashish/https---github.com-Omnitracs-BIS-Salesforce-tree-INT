@isTest(SeeAllData = true)
private class TestGenericTestClass{
    private static testMethod void testGenericTest(){
    //User NewUser = GenericTestClass.insertUser(null,null);
        Account acct=GenericTestClass.insertAccount();
        Contact newCnt = GenericTestClass.insertContact(acct.Id); 
        NMC_Account__c newNMCAcct  =  GenericTestClass.insertNMCAccount(acct.Id);
        Group newGroup = GenericTestClass.insertGroup();
        Support_Alert__c newSuppalert = GenericTestClass.insertSupportAlert(acct.Id);
        Serialized_Unit_Summary__c newSerUnit = GenericTestClass.insertSerUnitSumm(acct.Id);
        Serialized_Units__c newSerUnit1 = GenericTestClass.insertSerUnit(acct.Id);
        Connection_Type__c newConnType = GenericTestClass.insertConnType(newNMCAcct.Id);
        //SIGN_Agreement__c newAgreement= GenericTestClass.insertSignedAgree(acct.Id,newCnt.id);
        Contract_Request__c newConReq = GenericTestClass.insertContReq(acct.Id);
        
        Case newCase = GenericTestClass.insertCase(acct.Id,newCnt.id);
        System_Outage__c newSysOut = GenericTestClass.insertSystemOutage(newCase.id);
    }   
}