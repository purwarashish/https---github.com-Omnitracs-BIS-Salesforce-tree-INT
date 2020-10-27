/**
 * This class contains unit tests for validating the behavior of all NMC Apex classes
 * and triggers.
 
 */
@isTest(SeeAllData=True)
private class TestNMCAll{

    static testMethod void TestAllNMCTriggers() {
        test.startTest();
        Account testAccount1 = GenericTestClass.insertAccount();
        NMC_Account__C testNMCAcct = GenericTestClass.insertNMCAccount(testAccount1.Id);
        testNMCAcct.Account__c = null;
        update testNMCAcct;
        
        Account testAccount2 = GenericTestClass.insertAccount();
        testNMCAcct.Account__c = testAccount2.Id;
        
        Case testCase = GenericTestClass.insertCase(testAccount2.Id, null);
        testCase.NMC_Account_Number__c = testNMCAcct.NMC_Account__c;
        
        testNMCAcct.Name = 'Test123';
        update testNMCAcct;
        
        testNMCAcct.Name = '';
        testNMCAcct.NMC_Account_Name__c  = '';
        
        try{
        update testNMCAcct;
        }
        
        catch(Exception e){
        System.assert( e.getMessage().contains('Update failed. First exception on row 0 with id '+testNMCAcct.Id+'; first error: FIELD_CUSTOM_VALIDATION_EXCEPTION, NMC Account Name / Number cannot be modified. Please press Cancel to cancel your changes.'),e.getMessage() );
        }
        
        Serialized_Units__c serUnit = GenericTestClass.insertSerUnit(testAccount1.Id);
        Serialized_Units__c unit1= [select Id,Account__c,NMC_Account__c from Serialized_Units__c where id =: serUnit.Id limit 1];
        unit1.NMC_Account__c = testNMCAcct.ID;
        update unit1;
        
        Account account = [select Id from Account where Id<>:unit1.Account__c limit 1];
    
        NMC_Account__c nmcAccount = [select Id,Account__c,name,NMC_Account__c from NMC_Account__c where id= :testNMCAcct.Id Limit 1];//a08500000016dOz
        nmcAccount.Account__c=account.Id;
        update nmcAccount;
        
        test.stopTest();
    }
}