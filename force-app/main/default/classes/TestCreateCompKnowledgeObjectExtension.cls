@isTest(SeeAllData = true)
private class TestCreateCompKnowledgeObjectExtension
{  
  static testmethod void methodCreateCompKnowledgeObjectExtensiontoCoverLead()
  {
  Lead testlead = new Lead(
       
             LastName = 'Test Last Name'
            ,FirstName = 'Test First Name'
            ,Company = 'Test Company' 
            ,LeadSource = 'Test Source'
            ,Market__c = 'Test Market'
            ,Status = 'Test Status' 
            ,Company_Type__c = 'Test Company'
            , Title = 'Test title'
            /*, District__c = 'Test District'*/
            , State = 'CA'
            , City = 'Sacramento'
            , Country = 'US');
            
            insert testlead;
  
  Competitive_Knowledge__c cko = new Competitive_Knowledge__c(Lead__c = testlead.Id );
 
  ApexPages.standardController apages = new ApexPages.standardController(cko);
  CreateCompKnowledgeObjectExtension ComKnwObj = new CreateCompKnowledgeObjectExtension(apages);
 
  ComKnwObj.saveCompKnowledge();
 
  }
  
  static testmethod void methodCreateCompKnowledgeObjectExtensionToCoverAccount()
  {
   Account a1 = new Account(
            Name = 'Test Referral Account'
            ,BillingStreet='Test Billing Street 123'
            ,BillingCity='Test Billing City 123'
            ,BillingCountry='Test Billing Country 123'
            ,QWBS_Status__c = 'Active'
            ,BillingState = 'Test Billing State'
        );
        insert a1;
  
  Competitive_Knowledge__c cko = new Competitive_Knowledge__c(Account__c = a1.Id );
 
  ApexPages.standardController apages = new ApexPages.standardController(cko);
  CreateCompKnowledgeObjectExtension ComKnwObj = new CreateCompKnowledgeObjectExtension(apages);
 
  ComKnwObj.saveCompKnowledge();
  
  }

}