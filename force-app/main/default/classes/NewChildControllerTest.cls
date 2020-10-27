@isTest(SeeAllData=True)
private class NewChildControllerTest {
    public static Account accountInstance = new Account();
    public static Contract contractInstance = new Contract();
    public static Contract_Address__c conAdd =  new Contract_Address__c();
    public static Contract_Additional_Parties__c conAddP = new Contract_Additional_Parties__c();
    static{
        Schema.DescribeSObjectResult acccfrSchema = Schema.SObjectType.Account; 
        Map<String,Schema.RecordTypeInfo> AccountRecordTypeInfo = acccfrSchema.getRecordTypeInfosByName();
        Id accountRtId = AccountRecordTypeInfo .get('Non-Sales').getRecordTypeId();
        
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
        
        conAdd = new Contract_Address__c(
                Address_Line_1__c = 'Test',
                Address_Line_2__c = 'Test',
                Attention__c = 'Test',
                City__c = 'Test',
                Country__c = 'United States',
                Email_Address__c = 'y@yahoo.com',
                Fax_Number__c = 'TEST',
                Location_Type__c = 'Billing Address',
                Phone_Number__c = 'TEST',
                State_Province__c = 'TEST',
                Zip_Postal_Code__c = 'TEST',
                Contract__c=contractInstance.id
                );
        insert conAdd;
        
        conAddP = new Contract_Additional_Parties__c(
                Additional_Company__c = accountInstance.Id,
                // Import_ID__c = c.Import_ID__c,
                Party_Effective_Date__c = date.today(),
                Party_Expiration_Date__c = date.today()+2,
                Party_Relation_Description__c = 'Test',
                Party_Relation_Type__c = 'Affiliate',
                Relationship_Status__c = 'Active',
                // Search_Term_2__c = c.Search_Term_2__c,
                Contract__c=contractInstance.id
                );
                
                
        insert conAddP;
        
    }
    private static testMethod void testNewChildController() {
        Test.startTest();
        PageReference myVfPage = Page.NewChildPage;
        Test.setCurrentPage(myVfPage);
        ApexPages.StandardController sc = new ApexPages.StandardController(contractInstance);
        // Id accId = [Select Id From Account where Name =: 'testAccount'].Id;
        // Contract c =[Select Id From Contract Where Contract_Title__c   =:   'testTitle'];
        NewChildController acqWCont = new NewChildController(sc);
        acqWCont.cId = contractInstance.Id;
        // AcquisitionWizardController.cContract assWrap;
        acqWCont.cloneContract();
        acqWCont.cloneContractAddress(contractInstance.Id);
        acqWCont.cloneContractAdditionalParties(contractInstance.Id);
        // acqWCont.contractList[0].selected=true;
        // acqWCont.selectedContracts = [Select Id From Contract Where Id =: contractInstance.Id];
        // acqWCont.processSelected();
        // acqWCont.conForAccLookup.AccountId=accId;
        // acqWCont.getYesNo();
        // acqWCont.nextbtn();
        // acqWCont.getContracts();
        // acqWCont.contractList[0].selected=true;
        // acqWCont.nextbtn2();
        // acqWCont.nextbtn3();
        // acqWCont.selectedYesNo='Yes';
        // acqWCont.nextbtn4();
        // acqWCont.myDate = date.today();
        // acqWCont.finish();
        Test.stopTest();
    }

}