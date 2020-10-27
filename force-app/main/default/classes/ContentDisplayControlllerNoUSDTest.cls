/*********************************************************************************
Program:    Test Class for ContentDisplayControlller
Programmer:    Rex David - CloudSherpas
Date:      Oct 30, 2014
**********************************************************************************/ 
@isTest(SeeAllData=True)
private class ContentDisplayControlllerNoUSDTest {
    public static Account accountInstance = new Account();
    public static Contract contractInstance = new Contract();
    public static Contract_Project__c conPInstance = new Contract_Project__c();
    public static Non_Family_Linked_Contracts__c nfCInstance = new Non_Family_Linked_Contracts__c();
    static{
        Schema.DescribeSObjectResult acccfrSchema = Schema.SObjectType.Account; 
        Map<String,Schema.RecordTypeInfo> AccountRecordTypeInfo = acccfrSchema.getRecordTypeInfosByName();
        Id accountRtId = AccountRecordTypeInfo .get('T&L Sales Accounts').getRecordTypeId();
        
        Schema.DescribeSObjectResult concfrSchema = Schema.SObjectType.Contract; 
        Map<String,Schema.RecordTypeInfo> ContractRecordTypeInfo = concfrSchema.getRecordTypeInfosByName();
        Id contractRtId = ContractRecordTypeInfo .get('Customer Agreement').getRecordTypeId();
        
        
        accountInstance     =   new Account(Name    =   'testAccount',
                                            Phone   =   '12345',
                                            Account_Classification__c   =   'Prospect',
                                            Account_Status__c   =   'Active',
                                            Account_Type__c =   'Association',
                                            BillingState = 'CA',
                                            recordtypeid    =   accountRtId   
                                            );
        insert accountInstance;         
        
        contractInstance    =   new Contract(Contract_Title__c   =   'testTitle',
                                             recordtypeid    =   contractRtId,
                                             AccountId  =   accountInstance.id,
                                             Status =   'Draft',
                                             StartDate  =   date.today(),
                                             Term_type__c = 'Fixed',
                                             ContractTerm   =   1,
                                             //CurrencyIsoCode    =   'USD'
                                             Agreement_type__c = 'Individual',
                                             Contract_Type__c = 'Customer',
                                             Affiliate_Language__c = 'Yes',                                                 
                                             Legal_Entity_Name__c ='Omnitracs, LLC'
                                             );
        insert contractInstance;
        conPInstance    =   new Contract_Project__c(Name    =   'TestCP');
        insert conPInstance;
        
        nfCInstance    =   new Non_Family_Linked_Contracts__c   (Contract__c    =   contractInstance.Id,
                                                                Contract_Project__c =   conPInstance.Id);
        insert nfCInstance;
    }
  private static testMethod void testContentDisplayControlller() {
        
  }
  private static testMethod void testContractStructureController() {
      Date today = date.today();
      Test.startTest();
      contractInstance.Status = 'Activated';
        contractInstance.EndDate = today;
        contractInstance.Term_Type__c = 'Auto-Renewal';
        contractInstance.Original_Expiration_Date__c = null;
        contractInstance.Agreement_Type__c='Embedded Clause';
        
        update contractInstance;
        ContentDisplayControlller c =  new ContentDisplayControlller(new ApexPages.StandardController(conPInstance));
        c.getcontentList();
  }
  public static ID setupContent() { 
        RecordType ContentRT = [select Id FROM RecordType WHERE Name = 'Contract Document']; 
        
        ContentVersion testContentInsert = new ContentVersion(); 
        testContentInsert.ContentURL='http://www.google.com/'; 
        testContentInsert.Title = 'Google.com'; 
        testContentInsert.RecordTypeId = ContentRT.Id; 
        
        insert testContentInsert; 
        
        ContentVersion testContent = [SELECT ContentDocumentId FROM ContentVersion where Id = :testContentInsert.Id]; 
        
        ContentWorkspace testWorkspace = [SELECT Id FROM ContentWorkspace WHERE Name = 'Contract Documents']; 
        
        ContentWorkspaceDoc newWorkspaceDoc = new ContentWorkspaceDoc(); 
        
        newWorkspaceDoc.ContentWorkspaceId = testWorkspace.Id; 
        newWorkspaceDoc.ContentDocumentId = testContent.ContentDocumentId; 
        
        insert newWorkspaceDoc; 
        
        testContent.Document_Category__c ='Executed Contract';
        testContent.Contract__c = contractInstance.Id;
        
        update testContent; 
        
        return testContentInsert.Id; 
    }
}