/*********************************************************************************
Program:        Test Class for ContractStructureController
Programmer:     Rex David - CloudSherpas
Date:           Oct 02, 2014
**********************************************************************************/ 
@isTest(SeeAllData=True)
private class ContractStructureControllerTest {
    
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
                                                 //CurrencyIsoCode    =   'USD'
                                                 Term_type__c = 'Fixed',
                                                 Agreement_type__c = 'Individual',
                                                 Contract_Type__c = 'Customer',
                                                 Affiliate_Language__c = 'Yes',                                                 
                                                 Legal_Entity_Name__c ='Omnitracs, LLC'
                                                 );
            insert contractInstance;
            
            childContractInstance    =   new Contract(Contract_Title__c   =   'childtestTitle',
                                                 Parent_Contract__c =   contractInstance.Id,
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
            insert childContractInstance;
    }
    private static testMethod void testContractStructureController() {
        ContractStructureController conStrCont = new ContractStructureController();
        ContractStructureController.ObjectStructureMap objStrct;
        conStrCont.setcurrentId(contractInstance.Id);
        conStrCont.getObjectStructure();
        //objStrct.setnodeId('0');
        System.assertEquals(childContractInstance.Parent_Contract__c,contractInstance.Id,'ERROR:PARENT NOT EQUAL TO PARENTID');
    }

}