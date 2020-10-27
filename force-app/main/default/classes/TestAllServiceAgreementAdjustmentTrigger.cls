@isTest(SeeAllData=True)
private class TestAllServiceAgreementAdjustmentTrigger {
    static testmethod void testSendUpliftNotification() {

        //Test data preparation
        Account testAcct = TestUtils.getAccount('Test Account');
        insert testAcct;
        
        Contact testContact = TestUtils.getContact(testAcct);
        testContact.Email = 'test@test.com';
        testContact.Title = 'Dev';
        insert testContact;
        
        Contract testContract = TestUtils.getContract(testAcct);
        insert testContract;
    
        Test.StartTest();
        Service_Agreement_Adjustment__c SAA = new Service_Agreement_Adjustment__c();
        SAA.SAA_Status__c = 'New';
        SAA.Email_Sent__c = true;
        SAA.Contact_Address_1__c = 'Addr1';
        SAA.Contact_Address_2__c = 'Addr1';
        SAA.Contract__c = testContract.Id;
        SAA.Contact__c = testContact.Id;
        
        insert SAA;
        Test.StopTest();
    }
    
}