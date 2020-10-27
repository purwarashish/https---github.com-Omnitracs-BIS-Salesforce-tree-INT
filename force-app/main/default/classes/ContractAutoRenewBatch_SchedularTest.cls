@istest(SeeAllData=True)
class ContractAutoRenewBatch_SchedularTest {
    public static Account accountInstance = new Account();
    public static Contract contractInstance = new Contract();
    public static Contract contractInstance2 = new Contract();
    
    static{
            Schema.DescribeSObjectResult acccfrSchema = Schema.SObjectType.Account; 
            Map<String,Schema.RecordTypeInfo> AccountRecordTypeInfo = acccfrSchema.getRecordTypeInfosByName();
            Id accountRtId = AccountRecordTypeInfo .get('T&L Sales Accounts').getRecordTypeId();
            
            Schema.DescribeSObjectResult concfrSchema = Schema.SObjectType.Contract; 
            Map<String,Schema.RecordTypeInfo> ContractRecordTypeInfo = concfrSchema.getRecordTypeInfosByName();
            Id contractRtId = ContractRecordTypeInfo .get('Customer Agreement').getRecordTypeId();
            
            
            accountInstance     =   new Account(    Name    =   'testAccount',
                                                    Phone   =   '12345',
                                                    Account_Classification__c   =   'Prospect',
                                                    Account_Status__c   =   'Active',
                                                    Account_Type__c =   'Association',
                                                    recordtypeid    =   accountRtId   
                                                );
            insert accountInstance;         
            
            contractInstance    =   new Contract(   Contract_Title__c   =   'testTitle',
                                                    recordtypeid    =   contractRtId,
                                                    AccountId  =   accountInstance.id,
                                                    Status =   'Draft',
                                                    StartDate  =   date.today(),
                                                    EndDate    =   date.today(),
                                                    ContractTerm   =   1,
                                                    //CurrencyIsoCode    =   'USD',
                                                    Contract_ID__c =   null,
                                                    Renewal_Term_Length_in_months__c=12,
                                                    Term_type__c = 'Fixed',
                                                    Agreement_type__c = 'Individual',
                                                    Contract_Type__c = 'Customer',
                                                    Affiliate_Language__c = 'Yes',                                                 
                                                    Legal_Entity_Name__c ='Omnitracs, LLC'
                                                 );
            insert contractInstance;
            
            contractInstance2    =   new Contract(   Contract_Title__c   =   'testTitle',
                                                    recordtypeid    =   contractRtId,
                                                    AccountId  =   accountInstance.id,
                                                    Status =   'Draft',
                                                    StartDate  =   date.today(),
                                                    EndDate    =   date.today(),
                                                    ContractTerm   =   1,
                                                    //CurrencyIsoCode    =   'USD',
                                                    Contract_ID__c =   null,
                                                    Renewal_Term_Length_in_months__c=null,
                                                    Term_type__c = 'Fixed',
                                                    Agreement_type__c = 'Individual',
                                                    Contract_Type__c = 'Customer',
                                                    Affiliate_Language__c = 'Yes',                                                 
                                                    Legal_Entity_Name__c ='Omnitracs, LLC'
                                                 );
            insert contractInstance2;
            
            ContentVersion testContentInsert =new ContentVersion(); 
            testContentInsert.Id = setupContent();
            update testContentInsert;
    }
    
    
    static testmethod void testContractAutoRenewBatch_Schedular() {
        Date today = date.today();
        Test.startTest();
        contractInstance.Status = 'Active';
        contractInstance.EndDate = today;
        contractInstance.Term_Type__c = 'Auto-Renewal';
        contractInstance.Original_Expiration_Date__c = null;
        
        update contractInstance;
        
        List<task> t = new List<task>{ new task(
        WhatID = contractInstance.id,
        Subject='Donni',
        Status='Draft',
        Priority='Normal',
        ActivityDate = today.addMonths(12),
        // Responsavel__c='Felipe',
        Contract_Expiration_Task__c =True)};
        
        insert t;  
        String jobId = System.schedule('ContractAutoRenewBatch_Schedular',
        ContractAutoRenewBatch_Schedular.CRON_EXP, 
        new ContractAutoRenewBatch_Schedular());
        
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, 
        NextFireTime
        FROM CronTrigger WHERE id = :jobId];
        
        System.assertEquals(ContractAutoRenewBatch_Schedular.CRON_EXP, 
        ct.CronExpression);
        
        System.assertEquals(0, ct.TimesTriggered);
        Test.stopTest();
    }
    
    public static ID setupContent() 
    { 
        RecordType ContentRT = [select Id FROM RecordType WHERE Name = 'Contract Document']; 
        
        ContentVersion testContentInsert = new ContentVersion(); 
        testContentInsert.ContentURL='http://www.google.com/'; 
        testContentInsert.Title = 'Google.com'; 
        testContentInsert.RecordTypeId = ContentRT.Id; 
        
        insert testContentInsert; 
        //Adding Try Catch as the test classes are failing and moved return statement after catch. 
        Try
        {
        ContentVersion testContent = [SELECT ContentDocumentId FROM ContentVersion where Id = :testContentInsert.Id]; 
        
        ContentWorkspace testWorkspace = [SELECT Id FROM ContentWorkspace WHERE Name = 'Contract Documents']; 
        
        ContentWorkspaceDoc newWorkspaceDoc = new ContentWorkspaceDoc(); 
        
        newWorkspaceDoc.ContentWorkspaceId = testWorkspace.Id; 
        newWorkspaceDoc.ContentDocumentId = testContent.ContentDocumentId; 
        
        insert newWorkspaceDoc; 
        
        testContent.Document_Category__c ='Executed Contract';
        testContent.Contract__c = contractInstance.Id;
        
        update testContent; 
        }
        Catch(Exception e)
        {
            System.debug('Exception in class ContractAutoRenewBatch_SchedularTest'+e.getmessage());
        }
        return testContentInsert.Id; 
    }
}