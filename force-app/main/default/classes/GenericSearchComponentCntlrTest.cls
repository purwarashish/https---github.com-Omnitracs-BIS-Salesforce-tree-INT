/*
Description : Test Class for ContractAdditionalPartyTrigger,ContractAdditionalPartyTriggerHandler 
*/
@isTest(SeeAllData=True)
private class GenericSearchComponentCntlrTest {
    
    public static Account accountInstance = new Account();
    public static Contract contractInstance = new Contract();
    public static Contract contractInstancechild = new Contract();
    public static Contract_Address__c conAdd =  new Contract_Address__c();
    public static Contract_Address__c conAddchild =  new Contract_Address__c();
    public static Contract_Additional_Parties__c conAddP = new Contract_Additional_Parties__c();
    public static Contract_Additional_Parties__c conAddPchild = new Contract_Additional_Parties__c();
    public static Address__c accAddress = new Address__c();
    public static Non_Family_Linked_Contracts__c nflCon = new Non_Family_Linked_Contracts__c();
    public static Contract_Project__c cProj = new Contract_Project__c();
    public static Contract_Project__c cProj2 = new Contract_Project__c();
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
        
        accAddress  =   new Address__c( Account__c = accountInstance.Id,
                                        Location_Type__c = 'testLoctype',
                                        Address_Line_1__c = 'testAddress1',
                                        Address_Line_2__c = 'testAddress2',
                                        City__c = 'testCity',
                                        State_Province__c = 'TX',
                                        Zip_Postal_Code__c = '1234',
                                        Country__c  =   'United States',
                                        Attention__c = 'testAttention',
                                        Phone_Number__c = '1234',
                                        Fax_Number__c = '1234',
                                        Email_Address__c = 'test@y.com');
        
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
        
        contractInstancechild    =   new Contract(Contract_Title__c   =   'testTitle',
                                         recordtypeid    =   contractRtId,
                                         AccountId  =   accountInstance.id,
                                         Status =   'Draft',
                                         StartDate  =   date.today(),
                                         ContractTerm   =   1,
                                         CurrencyIsoCode    =   'USD',
                                         Parent_Contract__c =   contractInstance.Id,
                                         Term_type__c = 'Fixed',
                                         Agreement_type__c = 'Individual',
                                         Contract_Type__c = 'Customer',
                                         Affiliate_Language__c = 'Yes',                                                 
                                         Legal_Entity_Name__c ='Omnitracs, LLC'
                                         );
        insert contractInstancechild;
        
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
                State_Province__c = 'TX',
                Zip_Postal_Code__c = 'TEST',
                Contract__c=contractInstance.id,
                Account_Address__c=accAddress.Id
                );
        insert conAdd;
        
        conAddchild = new Contract_Address__c(
                Address_Line_1__c = 'Test',
                Address_Line_2__c = 'Test',
                Attention__c = 'Test',
                City__c = 'Test',
                Country__c = 'United States',
                Email_Address__c = 'y@yahoo.com',
                Fax_Number__c = 'TEST',
                Location_Type__c = 'Billing Address',
                Phone_Number__c = 'TEST',
                State_Province__c = 'TX',
                Zip_Postal_Code__c = 'TEST',
                Contract__c=contractInstancechild.Id,
                Account_Address__c=accAddress.Id
                );
        insert conAddchild;
        
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
        
        conAddPchild = new Contract_Additional_Parties__c(
                Additional_Company__c = accountInstance.Id,
                // Import_ID__c = c.Import_ID__c,
                Party_Effective_Date__c = date.today(),
                Party_Expiration_Date__c = date.today()+2,
                Party_Relation_Description__c = 'Test',
                Party_Relation_Type__c = 'Affiliate',
                Relationship_Status__c = 'Active',
                // Search_Term_2__c = c.Search_Term_2__c,
                Contract__c=contractInstancechild.id
                );
                
                
        insert conAddPchild;
        cProj = new Contract_Project__c(Name = 'TestCOnProj',
                                        Project_Description__c = 'TestDescription');
        insert cProj;
        
        cProj2 = new Contract_Project__c(Name = 'TestCOnProj2',
                                        Project_Description__c = 'TestDescription2');
        insert cProj2;
        
        nflCon = new Non_Family_Linked_Contracts__c(
            Contract__c = contractInstance.id,
            Contract_Project__c = cProj.Id
            );
        insert nflCon;
    }

    private static testMethod void testContractAdditionalPartyTriggerHandler() {
        Test.startTest();
        PageReference pageRef = Page.MyContactSearchPopup;
        pageRef.getParameters().put('id', String.valueOf(contractInstance.Id));
        Test.setCurrentPage(pageRef);
        
        GenericSearchComponentCntlr controller = new GenericSearchComponentCntlr();
        controller.ContractID=contractInstance.Id;
        Test.stopTest();
    }
}