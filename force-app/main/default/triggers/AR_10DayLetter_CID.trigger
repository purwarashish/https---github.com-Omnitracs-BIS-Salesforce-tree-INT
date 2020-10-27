trigger AR_10DayLetter_CID on AR_10_Day_Demand_Letter__c (before insert, before update) {
  //These will never be loaded or updated in bulk, so we deal with index item [0] only for simplicity
  AR_10_Day_Demand_Letter__c[] new10DayRequests = Trigger.new;
  ID accountId = new10DayRequests[0].Account__c;
  
  //Copy the Customer_Id and Customer Service Rep from the Account to this AR_10_Day_Demand_Letter
  Account parentAccount = [SELECT  a.CSR__c, a.QWBS_Cust_ID__c FROM Account a WHERE Id = :accountId];
  new10DayRequests[0].CSR__c = parentAccount.CSR__c;
  new10DayRequests[0].Cust_ID__c = parentAccount.QWBS_Cust_ID__c;
}