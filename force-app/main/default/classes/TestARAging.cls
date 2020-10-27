@isTest(SeeAllData=True)
private class TestARAging {
    static testmethod void testARAgingMostRecent() {
        
      Account acct = GenericTestClass.insertAccount();
      Account sampleCustomerAcct = [SELECT Id, Name FROM Account WHERE id = : acct.Id limit 1];
      
        
      //===== TEST most recent flag ================
      AR_Aging__c arAgingRecord = new AR_Aging__c(
                                  Account__c = sampleCustomerAcct.Id,
                                  Past_Due_1_30_Days__c = 44999, 
                                  Past_Due_31_60_Days__c = 88000,
                                  Past_Due_61_90_Days__c = 88000
                                  );
      insert arAgingRecord;      
      
      AR_Aging__c newAgingRecord = [Select Id, Most_Recent__c from AR_Aging__c where Id = :arAgingRecord.ID];    
      System.assertEquals(true, newAgingRecord.Most_Recent__c);
    }
} //end class TestARAging