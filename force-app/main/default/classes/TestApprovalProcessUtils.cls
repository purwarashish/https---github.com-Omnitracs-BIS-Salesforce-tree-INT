/*******************************************************************************
Date    : 27 July 2010
Author  : David Ragsdale
Overview: Test Class for ApprovalProcess Utils...  
   Utils are fired from UpdateFieldsForApprovalWorkflow trigger

Modified By: Shruti Karn for adding 'GenericTestClass' methods.

Modified By  : Rittu Roy
Modified Date: 10/18/15
Purpose      : Added testmethod for submitProcessApprovalRequest method
*******************************************************************************/
@isTest(SeeAllData=True)
private class TestApprovalProcessUtils {

    static testmethod void TestApprovalProcessUtils() {

      Test.StartTest();        
      Account AcctId = GenericTestClass.insertAccount();
      Contact contID = GenericTestClass.insertContact(AcctId.Id);
      Account sampleCustomerAcct = [SELECT Id, Name FROM Account where id = : AcctId.Id limit 1];
      Contact sampleContact = [SELECT Id, Name FROM Contact where id = :contID.Id limit 1];  
      Contract_Request__c CR = new Contract_Request__c(
                                  Account__c = sampleCustomerAcct.Id,
                                  Description__c = 'Test', 
                                  Contact__c = sampleContact.Id,
                                  Contracts_Administrator_to_Send__c = 'No',
                                  No_Approvals_Required__c = true,
                                  Product_Reduced_Price__c = '5.00',
                                  Requested_Completion_Date__c = (System.Today()+30),
                                  Request_Status__c = 'Submitted', 
                                  System_Status__c = 'Submitted', 
                                  System_Is_Future__c = false
                                 );
      insert CR; 
   
      CR.Request_Status__c = 'Pending Approval';
      update CR;   
      Test.StopTest();
      
      List<Contract_Request__c> insertedCR = [SELECT Request_Status__c, System_Status__c, System_Is_Future__c 
        FROM Contract_Request__c WHERE Id = :CR.Id];
     
      for (Contract_Request__c ContReq : insertedCR)
      {
        System.assertEquals('Pending Approval', ContReq.System_Status__c);
        System.assertEquals(false, ContReq.System_Is_Future__c);
      }
      
    }
    
    static testmethod void testSubmitProcessApprovalRequest() {
        Opportunity testOppty = new Opportunity(Name='Test',StageName='Sales Complete',CloseDate=System.Today());
        insert testOppty;

        VCG_CPQ_Quote__C testQuote = new VCG_CPQ_Quote__C(Is_Primary__c = true,Opportunity__c = testOppty.Id);
        insert testQuote;
        
        ApprovalProcessUtils.submitProcessApprovalRequest(testQuote.Id);
    }
}