@isTest(SeeAllData=true)
private class TestUpdateAccountinSU {
  static testMethod void testUpdateAccountInSU()
    { 
        
        Account acct = GenericTestClass.insertAccount(); 
        Serialized_Units__c serUnit = GenericTestClass.insertSerUnit(acct.Id);
        NMC_Account__c nmcAcctId = GenericTestClass.insertNMCAccount(Acct.Id);
        Serialized_Units__c unit1= [select Id,Account__c,NMC_Account__c from Serialized_Units__c where id =: serUnit.Id limit 1];
        unit1.NMC_Account__c = nmcAcctId.ID;
        update unit1;

         
        Account account = [select Id from Account where Id<>:unit1.Account__c limit 1];
    
        NMC_Account__c nmcAccount = [select Id,Account__c,name,NMC_Account__c from NMC_Account__c where id= :nmcAcctId.Id Limit 1];//a08500000016dOz
        nmcAccount.Account__c=account.Id;
        //update nmcAccount;

    }
}