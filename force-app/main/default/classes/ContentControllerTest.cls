/*********************************************************************************
Program:                Test Class for Content Controller
Programmer:             Rex David - CloudSherpas
Date:                   October 06, 2014
**********************************************************************************/    
@isTest(SeeAllData=True)
private class ContentControllerTest {
    public static Account accountInstance = new Account();
    public static Contract contractInstance = new Contract();
    public static Contract childContractInstance = new Contract();
    public static ContentVersion testContentInsert = new ContentVersion(); 
    static {
        Schema.DescribeSObjectResult acccfrSchema = Schema.SObjectType.Account; 
        Map<String,Schema.RecordTypeInfo> AccountRecordTypeInfo = acccfrSchema.getRecordTypeInfosByName();
        Id accountRtId = AccountRecordTypeInfo .get('T&L Sales Accounts').getRecordTypeId();
        
        Schema.DescribeSObjectResult concfrSchema = Schema.SObjectType.Contract; 
        Map<String,Schema.RecordTypeInfo> ContractRecordTypeInfo = concfrSchema.getRecordTypeInfosByName();
        Id contractRtId = ContractRecordTypeInfo .get('Customer Agreement').getRecordTypeId();
        
        
        accountInstance     =   new Account(Name    =   'testAccount',
                                            Phone   =   '12345',
                                            //Account_Classification__c   =   'Prospect',
                                            //Account_Status__c   =   'Active',
                                            //Account_Type__c =   'Association',
                                            recordtypeid    =   accountRtId   
                                            );
        insert accountInstance;         
        
        contractInstance    =   new Contract(Contract_Title__c   =   'testTitle',
                                             recordtypeid    =   contractRtId,
                                             AccountId  =   accountInstance.id,
                                             Status =   'Draft',
                                             StartDate  =   date.today(),
                                             ContractTerm   =   1,
                                             //CurrencyIsoCode    =   'USD'
                                             Term_type__c = 'Fixed',
                                             Agreement_type__c = 'Individual',
                                             Contract_Type__c = 'Customer',
                                             Affiliate_Language__c = 'Yes',                                                 
                                             Legal_Entity_Name__c ='Omnitracs, LLC'
                                             );
        insert contractInstance; 
        
        
        
        
    }
    @isTest(SeeAllData=False)
    private static void testContentController() {
        ApexPages.StandardController c = new ApexPages.StandardController(contractInstance);
        ContentController conCont = new ContentController(c);
        
        conCont.file = testContentInsert;
        RecordType ContentRT = [select Id FROM RecordType WHERE Name = 'Contract Document']; 
        
        conCont.file.Title = 'Test';
        conCont.file.ContentURL = 'http://www.google.com/'; 
        conCont.file.FirstPublishLocationId ='058W00000004IcW';
        conCont.go();
        PageReference pageRef = Page.uploadContent;
        pageRef.getParameters().put('id', String.valueOf(contractInstance.Id));
        Test.setCurrentPage(pageRef);
    }

}