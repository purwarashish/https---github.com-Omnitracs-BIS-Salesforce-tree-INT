@isTest(SeeAllData=True)
private class AcquisitionWizardControllerTest {
    public static Account accountInstance = new Account();
    public static Account accountInstance2 = new Account();
    
    public static Contract contractInstance = new Contract();
    public static Contract childContractInstance = new Contract();
    
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
                                             Agreement_type__c = 'Individual',
                                             Contract_Type__c = 'Customer',
                                             Affiliate_Language__c = 'Yes',
                                             Term_Type__c = 'Fixed',
                                             Legal_Entity_Name__c ='Omnitracs, LLC'
                                             //CurrencyIsoCode    =   'USD'
                                             );
        insert contractInstance;
    }
    
    private static testMethod void testAcquisitionWizardController() {
        SpringCMApiManagerMock mock = new SpringCMApiManagerMock();
		Test.startTest();
        PageReference myVfPage = Page.AcquisitionWizard;
        Test.setCurrentPage(myVfPage);
        ApexPages.StandardController sc = new ApexPages.StandardController(accountInstance);
        Id accId = [Select Id From Account where Name =: 'testAccount'].Id;
        Contract c =[Select Id From Contract Where Contract_Title__c   =:   'testTitle'];
        AcquisitionWizardController acqWCont = new AcquisitionWizardController(sc);
		Test.setMock(HttpCalloutMock.class, mock);
        AcquisitionWizardController.cContract assWrap;
        acqWCont.getContracts();
        acqWCont.contractList[0].selected=true;
        acqWCont.selectedContracts = [Select Id From Contract Where Id =: contractInstance.Id];
        acqWCont.processSelected();
        acqWCont.conForAccLookup.AccountId=accId;
        acqWCont.getYesNo();
        acqWCont.nextbtn();
        acqWCont.getContracts();
        acqWCont.contractList[0].selected=true;
        acqWCont.nextbtn2();
        acqWCont.nextbtn3();
        acqWCont.selectedYesNo='Yes';
        acqWCont.nextbtn4();
        acqWCont.myDate = date.today();
        acqWCont.finish();
        Test.stopTest();
    }
    private static testMethod void testAcquisitionWizardController2() {
        SpringCMApiManagerMock mock = new SpringCMApiManagerMock();
        Test.startTest();
        PageReference myVfPage = Page.AcquisitionWizard;
        Test.setCurrentPage(myVfPage);
        ApexPages.StandardController sc = new ApexPages.StandardController(accountInstance);
        Id accId = [Select Id From Account where Name =: 'testAccount'].Id;
        Contract c =[Select Id From Contract Where Contract_Title__c   =:   'testTitle'];
        Test.setMock(HttpCalloutMock.class, mock);
        AcquisitionWizardController acqWCont = new AcquisitionWizardController(sc);

        AcquisitionWizardController.cContract assWrap;
        acqWCont.getContracts();
        acqWCont.contractList[0].selected=true;
        acqWCont.selectedContracts = [Select Id From Contract Where Id =: contractInstance.Id];
        acqWCont.processSelected();
        acqWCont.conForAccLookup.AccountId=accId;
        acqWCont.getYesNo();
        acqWCont.nextbtn();
        acqWCont.getContracts();
        acqWCont.contractList[0].selected=true;
        acqWCont.nextbtn2();
        acqWCont.nextbtn3();
        acqWCont.selectedYesNo='No';
        acqWCont.nextbtn4();
        acqWCont.myDate = date.today();
        acqWCont.finish();
        Test.stopTest();
    }
    private static testMethod void testAcquisitionWizardController3() {
        Test.startTest();
        PageReference myVfPage = Page.AcquisitionWizard;
        Test.setCurrentPage(myVfPage);
        ApexPages.StandardController sc = new ApexPages.StandardController(accountInstance);
        Id accId = [Select Id From Account where Name =: 'testAccount'].Id;
        Contract c =[Select Id From Contract Where Contract_Title__c   =:   'testTitle'];
        AcquisitionWizardController acqWCont = new AcquisitionWizardController(sc);

        AcquisitionWizardController.cContract assWrap;
        acqWCont.getContracts();
        acqWCont.contractList[0].selected=true;
        acqWCont.selectedContracts = [Select Id From Contract Where Id =: contractInstance.Id];
        acqWCont.processSelected();
        acqWCont.conForAccLookup.AccountId=accId;
        acqWCont.getYesNo();
        acqWCont.nextbtn();
        acqWCont.cancel();
        Test.stopTest();
    }
    private static testMethod void testAcquisitionWizardController4() {
        Test.startTest();
        PageReference myVfPage = Page.AcquisitionWizard;
        Test.setCurrentPage(myVfPage);
        ApexPages.StandardController sc = new ApexPages.StandardController(accountInstance);
        Id accId = [Select Id From Account where Name =: 'testAccount'].Id;
        Contract c =[Select Id From Contract Where Contract_Title__c   =:   'testTitle'];
        AcquisitionWizardController acqWCont = new AcquisitionWizardController(sc);

        AcquisitionWizardController.cContract assWrap;
        acqWCont.getContracts();
        acqWCont.contractList[0].selected=true;
        acqWCont.selectedContracts = [Select Id From Contract Where Id =: contractInstance.Id];
        acqWCont.processSelected();
        acqWCont.conForAccLookup.AccountId=accId;
        acqWCont.getYesNo();
        acqWCont.nextbtn();
        acqWCont.prevbtn();
        acqWCont.nextbtn();
        
        acqWCont.getContracts();
        acqWCont.contractList[0].selected=true;
        
        acqWCont.nextbtn2();
        acqWCont.prevbtn2();
        acqWCont.nextbtn2();
        
        acqWCont.nextbtn3();
        acqWCont.prevbtn3();
        acqWCont.nextbtn3();
        
        acqWCont.selectedYesNo='No';
        
        acqWCont.nextbtn4();
        acqWCont.prevbtn4();
        acqWCont.nextbtn4();
        Test.stopTest();
    }

}