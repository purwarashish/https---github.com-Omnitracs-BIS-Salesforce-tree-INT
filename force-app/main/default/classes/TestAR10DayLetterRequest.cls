@isTest(SeeAllData=true)
public class TestAR10DayLetterRequest {
    
    static testmethod void testAR10DayDemandLetter() {
        
      Account sampleCustomerAcct = [SELECT Id, Name FROM Account LIMIT 1];  
      AR_10_Day_Demand_Letter__c newAR10DayRecord = new AR_10_Day_Demand_Letter__c();
      newAR10DayRecord.Account__c = sampleCustomerAcct.Id;                                  
      insert newAR10DayRecord;      
      
      AR_10_Day_Demand_Letter__c savedRecord = [Select Id, CSR__c from AR_10_Day_Demand_Letter__c where Id = :newAR10DayRecord.ID];    
      //System.assertNotEquals(null, savedRecord.CSR__c);
    }
}