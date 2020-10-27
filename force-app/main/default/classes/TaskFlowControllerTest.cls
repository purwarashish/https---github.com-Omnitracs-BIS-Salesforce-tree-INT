/*********************************************************************************
Program:                Test Class for TaskFlowController
Programmer:             Rex David - CloudSherpas
Date:                   October 29, 2014
**********************************************************************************/    
@isTest(SeeAllData=True)
private class TaskFlowControllerTest {
    public static Account accountInstance = new Account();
    public static Contract contractInstance = new Contract();
    public static Contract childContractInstance = new Contract();
    public static ContentVersion testContentInsert = new ContentVersion(); 
    static{
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
                                             Term_type__c = 'Fixed',
                                             Agreement_type__c = 'Individual',
                                             Contract_Type__c = 'Customer',
                                             Affiliate_Language__c = 'Yes',                                                 
                                             Legal_Entity_Name__c ='Omnitracs, LLC'
                                            //  CurrencyIsoCode    =   'USD'
                                             );
        insert contractInstance; 
    }
    private static testMethod void testTaskFlowController() {
        TaskFlowController tskflow = new TaskFlowController();
        tskflow.ContractId=contractInstance.Id;
        pageReference p = tskflow.getCreateTask();

    }

}