/*********************************************************************************
Program:        Test Class for Contract Clone Class
Programmer:     Rex David - CloudSherpas
Date:           Oct 02, 2014
**********************************************************************************/ 
@isTest(SeeAllData=True)
private class ContractCloneTest {
    public static Account accountInstance = new Account();
    public static Contract contractInstance = new Contract();
    public static Contract contractInstance2 = new Contract();
    //public static Asset__c assetInstance = new Asset__c();
    public static Product2 productInstance = new Product2();
    public static string feedEve = 'Yes';
    public static decimal feedNot = 12;
    public static string feedRen = 'Yes';
    public static string feedExt = 'Yes';
    static{
            Schema.DescribeSObjectResult acccfrSchema = Schema.SObjectType.Account; 
            Map<String,Schema.RecordTypeInfo> AccountRecordTypeInfo = acccfrSchema.getRecordTypeInfosByName();
            Id accountRtId = AccountRecordTypeInfo.get('T&L Sales Accounts').getRecordTypeId();
            
            Schema.DescribeSObjectResult concfrSchema = Schema.SObjectType.Contract; 
            Map<String,Schema.RecordTypeInfo> ContractRecordTypeInfo = concfrSchema.getRecordTypeInfosByName();
            Id contractRtId = ContractRecordTypeInfo .get('Customer Agreement').getRecordTypeId();
            
            
            accountInstance     =   new Account(    Name    =   'testAccount',
                                                    Phone   =   '12345',
                                                    Account_Classification__c   =   'Prospect',
                                                    Account_Status__c   =   'Active',
                                                    Account_Type__c =   'Association',
                                                    BillingState = 'CA',
                                                    recordtypeid    =   accountRtId   
                                                );
            insert accountInstance;         
            
            contractInstance    =   new Contract(   Contract_Title__c   =   'testTitle',
                                                    recordtypeid    =   contractRtId,
                                                    AccountId  =   accountInstance.id,
                                                    Status =   'Draft',
                                                    StartDate  =   date.today(),
                                                    EndDate    =   date.today(),
                                                    Term_type__c = 'Fixed',
                                                    ContractTerm   =   1,
                                                    //CurrencyIsoCode    =   'USD',
                                                    Contract_ID__c =   null,
                                                    Agreement_type__c = 'Individual',
                                                    Contract_Type__c = 'Customer',
                                                    Affiliate_Language__c = 'Yes',                                                 
                                                    Legal_Entity_Name__c ='Omnitracs, LLC'
                                                 );
            insert contractInstance;
            
            contractInstance2    =   new Contract(  Contract_Title__c   =   'childtestTitle',
                                                    Parent_Contract__c =   contractInstance.Id,
                                                    recordtypeid    =   contractRtId,
                                                    AccountId  =   accountInstance.id,
                                                    Status =   'Draft',
                                                    StartDate  =   date.today(),
                                                    Term_type__c = 'Fixed',
                                                    EndDate    =   null,
                                                    ContractTerm   =   1,
                                                    //CurrencyIsoCode    =   'USD'
                                                    Agreement_type__c = 'Individual',
                                                    Contract_Type__c = 'Customer',
                                                    Affiliate_Language__c = 'Yes',                                                 
                                                    Legal_Entity_Name__c ='Omnitracs, LLC'
                                                 );
            insert contractInstance2;
            
            productInstance =   new Product2(   Name    =   'TestProduct',
                                                isActive    =   True
                                            );
                                            
            insert productInstance;
            /*
            assetInstance   = new Asset__c( Name =   'testAssetName',
                                            Account__c  =   accountInstance.Id,
                                            CurrencyIsoCode =   'USD',
                                            Product__c  =   productInstance.Id,
                                            Contract__c =   contractInstance.Id);
            
            insert assetInstance; */
    }
    private static testMethod void testContractClone() {
        
        Contract con = [SELECT Id, ContractNumber,AccountId,StartDate,EndDate FROM Contract WHERE Id =: contractInstance.Id LIMIT 1];
        ContractClone conClone = new ContractClone();
        conClone.CurrentContract    =   contractInstance;
        conClone.NewContractID  =   con.Id;
        
        conClone.CloneContract(con.Id,con.AccountId,con.EndDate);
        
        Map<String,Object> inputParams = new Map<String,Object>();
        string feedContractID = con.Id;
        string feedAccountId = con.AccountId;
        string feedEvents = 'Yes';
        Decimal feedNotice = 12;
        string feedRenewal = 'Yes';
        string feedExtension = 'Yes';
        System.assertEquals(con.AccountId,accountInstance.Id);
        System.assertEquals(con.Id,contractInstance.Id);
        datetime feedstartDate = con.StartDate;
        datetime feedEndDate = con.EndDate;
        conClone.CloneContract(con.Id,con.AccountId,con.EndDate);
        
        inputParams.put('vID', feedContractID);
        System.assertEquals(feedContractID,con.Id);
        
        inputParams.put('vAccountId', feedAccountId);
        System.assertEquals(feedAccountId,con.AccountId);
        
        inputParams.put('vStartDate', feedstartDate);
        inputParams.put('vEndDate', feedEndDate);
        
        inputParams.put('vEndDate', feedEndDate);
        
        inputParams.put('vEvents', feedEvents);
        inputParams.put('vNotice', feedNotice);
        inputParams.put('vRenewal', feedRenewal);
        inputParams.put('vExtension', feedExtension);
        
        Process.PluginRequest request = new Process.PluginRequest(inputParams);       
        conClone.invoke(request);
    }
    
    static testMethod void describeTest() {

        ContractClone conClone = new ContractClone();
        Process.PluginDescribeResult result = 
            conClone.describe();
        
        System.AssertEquals(
            result.inputParameters.size(), 7);
        System.AssertEquals(
            result.OutputParameters.size(), 1);
        
    }
    
    private static testMethod void testContractClone2() {
        ContractClone conClone = new ContractClone();
        conClone.CloneContract(contractInstance2.Id,accountInstance.Id,contractInstance2.EndDate);
        //conClone.UpdateTask(feedEve,contractInstance.Id,contractInstance.EndDate,feedNot,accountInstance.Id,feedExt,contractInstance2.Id);
    }
    private static testMethod void testContractClone3() {
        Date today = date.today();
        List<task> t = new List<task>{ new task(
        WhatID = contractInstance.id,
        Subject='Donni',
        Status='Draft',
        Priority='Normal',
        ActivityDate = today.addMonths(12),
        // Responsavel__c='Felipe',
        Contract_Expiration_Task__c =True)};
        
        insert t;  
        ContractClone conClone = new ContractClone();
        //conClone.CloneContract(contractInstance2.Id,accountInstance.Id,contractInstance2.EndDate);
        conClone.UpdateTask(feedEve,contractInstance.Id,contractInstance.EndDate,feedNot,accountInstance.Id,feedExt,contractInstance2.Id);
    }

}