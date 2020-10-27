/*********************************************************************************
Program:                Test Class for Content Controller Delivery
Programmer:             Joe Henry - CloudSherpas
Date:                   December 04, 2014
**********************************************************************************/  
@isTest(SeeAllData=True)
private class ContentDeliveryControllerTest {
    public static Account accountInstance = new Account();
    public static Contract contractInstance = new Contract();
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
                                            recordtypeid    =   accountRtId   
                                            );
        insert accountInstance;         
        
        contractInstance    =   new Contract(Contract_Title__c   =   'testTitle',
                                             recordtypeid    =   contractRtId,
                                             AccountId  =   accountInstance.id,
                                             Status =   'Draft',
                                             StartDate  =   date.today(),
                                             ContractTerm   =   1,
                                             CurrencyIsoCode    =   'USD',
                                             Term_type__c = 'Fixed',
                                             Agreement_type__c = 'Individual',
                                             Contract_Type__c = 'Customer',
                                             Affiliate_Language__c = 'Yes',                                                 
                                             Legal_Entity_Name__c ='Omnitracs, LLC'
                                             );
        insert contractInstance;
    }
    
    @isTest(SeeAllData=False)
    static void ContentDeliveryControllerTest() {
        RecordType ContentRT = [select Id FROM RecordType WHERE Name = 'Contract Document']; 
        list<ContentWorkspace>  ws = [Select c.Name, c.Id From ContentWorkspace c where name like '%Contract%' limit 1];
        
        ContentVersion testContentInsert = new ContentVersion(); 
        testContentInsert.ContentURL='http://www.google.com/'; 
        testContentInsert.Title = 'Google.com'; 
        testContentInsert.RecordTypeId = ContentRT.Id; 
        testContentInsert.Contract__c = contractInstance.Id;
        testContentInsert.FirstPublishLocationId = ws[0].Id;
        insert testContentInsert; 
        testContentInsert.Orderable__c = true;
        Test.startTest();   
        ContentDeliveryController cdc =  new ContentDeliveryController(new ApexPages.StandardController(contractInstance));
        cdc.contNum = contractInstance.ContractNumber;
        cdc.getworkspaceOptions();
        cdc.getContentDistribution();
        cdc.getContentDistributionView();
        cdc.getContentDocument();
        //cdc.getconDocL();
        //cdc.Search();
        //cdc.step1();
        //cdc.step2();
        //cdc.step3();
        //cdc.Preview();
        //cdc.step4();

       

    }
}