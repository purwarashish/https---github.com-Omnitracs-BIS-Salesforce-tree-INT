@isTest(SeeAllData = true)
public class TestOrigNumUpdate {
    static testmethod void testOrigNumUpdateConnectionType() {
        
//Select c.Id, c.Last_Originating_Number_Change__c, c.NMC_Account__c from Connection_Type__c c WHERE c.Id = 'a06500000016ZInAAM'
//Select o.Connection_Type__c, o.Id, o.Name from Originating_Number__c o LIMIT 1
      Originating_Number__c origNum = new Originating_Number__c();
      Account Acct = GenericTestClass.insertAccount();
      NMC_Account__c NMC = GenericTestClass.insertNMCAccount(Acct.Id);
      Connection_Type__c connType = GenericTestClass.insertConnType(NMC.Id);
      origNum.Connection_Type__c = connType.Id;
      insert origNum;
      origNum = [Select o.Connection_Type__c, o.Id, o.Name,Originating_Number__c from Originating_Number__c o where id =:origNum.Id LIMIT 1];       
      origNum.Originating_Number__c  = '(555) 555-5555';
      
      update origNum;
      
      //Parent connection type should've been updated with Last_Originating_Number_Change__c timestamp
      Connection_Type__c updatedConnType = [Select c.Id, c.Last_Originating_Number_Change__c, c.NMC_Account__c from Connection_Type__c c WHERE c.Id = :origNum.Connection_Type__c];      
      Datetime yesterday = System.now() - 1; 
      System.assert(updatedConnType.Last_Originating_Number_Change__c > yesterday);
    }
} //end class TestOrigNumUpdate