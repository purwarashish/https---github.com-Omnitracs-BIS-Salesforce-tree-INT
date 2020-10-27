@isTest(SeeAllData=True)
private class TestConvertNMCNametoUpper {
    static testmethod void myContractTest() {
        Account Acct = GenericTestClass.insertAccount();
        NMC_Account__c NMC = GenericTestClass.insertNMCAccount(Acct.Id);       
        //NMC_Account__c nmcacct = new NMC_Account__c(Name='Test NMC Acct', NMC_Account_Name__c = 'Test NMC Name23',NMC_Account__c='123');
        /*account acct1 = new account(QWBS_Market__c = 'T&L Eastern Region', Name = 'My Test',
            BillingStreet = '123 Main', BillingCity = 'San Diego', BillingState = 'CA', BillingCountry = 'USA');
        insert acct1;*/
       
        NMC_Account__c nmcacct = [Select id,account__c,Name,NMC_Account_Name__c,NMC_Account__c from NMC_Account__c where id = :NMC.Id limit 1 ];
     
        
        
        //Modified By Shruti Karn for CR# 22542
        Case newCase = new Case();
        newCase.AccountId = nmcacct.account__c;
        newCase.NMC_Account_Number__c = nmcacct.NMC_Account__c;
        insert newCase;
        
        nmcacct.Name = 'Test123';
        
        update nmcacct;
        nmcacct.Name = '';
        nmcacct.NMC_Account_Name__c  = '';
        try{
        update nmcacct;
        }
        
        catch(Exception e){
        System.assert( e.getMessage().contains('Update failed. First exception on row 0 with id '+nmcacct.Id+'; first error: FIELD_CUSTOM_VALIDATION_EXCEPTION, NMC Account Name / Number cannot be modified. Please press Cancel to cancel your changes.'),e.getMessage() );
                }

    }
}