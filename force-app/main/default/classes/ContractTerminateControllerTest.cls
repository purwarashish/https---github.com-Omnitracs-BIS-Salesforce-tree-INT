/*********************************************************************************
Program:        Test Class for ContractTerminateController
Programmer:     Rex David - CloudSherpas
Date:           Oct 22, 2014
**********************************************************************************/ 
@isTest(SeeAllData=True)
private class ContractTerminateControllerTest {
    
    public static Account accountInstance = new Account();
    public static Contract contractInstance = new Contract();
    public static Contract childContractInstance = new Contract();
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
                                                BillingState = 'CA',
                                                Account_Type__c =   'Association'
                                                //recordtypeid    =   accountRtId   
                                                );
            insert accountInstance;         
            
            contractInstance    =   new Contract(Contract_Title__c   =   'testTitle',
                                                 recordtypeid    =   contractRtId,
                                                 AccountId  =   accountInstance.id,
                                                 Status =   'Draft',
                                                 StartDate  =   date.today(),
                                                 ContractTerm   =   1,
                                                 Term_type__c = 'Fixed',
                                                 Bypass_Rules__c = true,
                                                 Agreement_type__c = 'Individual',
                                                 Contract_Type__c = 'Customer',
                                                 Affiliate_Language__c = 'Yes',                                                 
                                                 Legal_Entity_Name__c ='Omnitracs, LLC'
                                                 //CurrencyIsoCode    =   'USD'
                                                 );
            insert contractInstance;
            
            childContractInstance    =   new Contract(Contract_Title__c   =   'childtestTitle',
                                                 Parent_Contract__c =   contractInstance.Id,
                                                 recordtypeid    =   contractRtId,
                                                 AccountId  =   accountInstance.id,
                                                 Status =   'Draft',
                                                 StartDate  =   date.today(),
                                                 Term_type__c = 'Fixed',
                                                 ContractTerm   =   1,
                                                 Bypass_Rules__c = true,
                                                 Agreement_type__c = 'Individual',
                                                 Contract_Type__c = 'Customer',
                                                 Affiliate_Language__c = 'Yes',                                                 
                                                 Legal_Entity_Name__c ='Omnitracs, LLC'
                                                 //CurrencyIsoCode    =   'USD'
                                                 );
            insert childContractInstance;
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
        
        ContractTerminateController conStrCont = new ContractTerminateController();
        ContractTerminateController.ObjectStructureMap objStrct;
       // conStrCont.getContracts();
       // objStrct.selectd=true;
        ContractTerminateController.TerminateWrapper termWrap;
        conStrCont.setcurrentId(contractInstance.Id);
        conStrCont.getObjectStructure();
        conStrCont.asm[0].selectd=true;
        conStrCont.Next();
        conStrCont.getContracts();
        conStrCont.Save();
        Test.stopTest();
        //objStrct.setnodeId('0');
        System.assertEquals(childContractInstance.Parent_Contract__c,contractInstance.Id,'ERROR:PARENT NOT EQUAL TO PARENTID');
    }
    private static testMethod void testContractStructureController2() {
        Date today = date.today();
        Test.startTest();
        contractInstance.Status = 'Activated';
        contractInstance.EndDate = today;
        contractInstance.Term_Type__c = 'Auto-Renewal';
        contractInstance.Original_Expiration_Date__c = null;
        contractInstance.Agreement_Type__c='Embedded Clause';
        
        update contractInstance;
        
        ContractTerminateController conStrCont = new ContractTerminateController();
        ContractTerminateController.ObjectStructureMap objStrct;
       // conStrCont.getContracts();
        
        ContractTerminateController.TerminateWrapper termWrap;
        conStrCont.setcurrentId(contractInstance.Id);
        conStrCont.getObjectStructure();
        conStrCont.asm[0].selectd=true;
        conStrCont.isTreeShow = true;
        conStrCont.Next();
        conStrCont.getContracts();
        conStrCont.Cancel();
        Test.stopTest();
        //objStrct.setnodeId('0');
        System.assertEquals(childContractInstance.Parent_Contract__c,contractInstance.Id,'ERROR:PARENT NOT EQUAL TO PARENTID');
    }
    
    public static ID setupContent() 
    { 
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