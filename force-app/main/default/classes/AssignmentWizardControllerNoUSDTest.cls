/*********************************************************************************
Program:    Test Class for AssignmentWizardController
Programmer:    Rex David - CloudSherpas
Date:      Oct 22, 2014
**********************************************************************************/ 
@isTest(SeeAllData=True)
private class AssignmentWizardControllerNoUSDTest {
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
                                                BillingState = 'CA',
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
                                                 //CurrencyIsoCode    =   'USD',
                                                 Bypass_Rules__c = true,
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
                                                 Term_type__c = 'Fixed',
                                                 ContractTerm   =   1,
                                                 //CurrencyIsoCode    =   'USD',
                                                 Bypass_Rules__c = true,
                                                 Agreement_type__c = 'Individual',
                                                 Contract_Type__c = 'Customer',
                                                 Affiliate_Language__c = 'Yes',                                                 
                                                 Legal_Entity_Name__c ='Omnitracs, LLC'
                                                 );
            insert childContractInstance;
    }
    
  private static testMethod void testAssignmentWizardController() {
      SpringCMApiManagerMock mock = new SpringCMApiManagerMock();
        Test.startTest();
        PageReference myVfPage = Page.AssignmentWizard;
        Test.setCurrentPage(myVfPage);
        ApexPAges.StandardController sc = new ApexPages.StandardController(contractInstance);
        Test.setMock(HttpCalloutMock.class, mock);
      AssignmentWizardController aswCont = new AssignmentWizardController(sc);
      AssignmentWizardController.ObjectStructureMap objStrct;
     // conStrCont.getContracts();
     // objStrct.selectd=true;
      AssignmentWizardController.AssignmentWrapper assWrap;
      //aswCont.setcurrentId(contractInstance.Id);
      aswCont.getObjectStructure();
      aswCont.asm[0].selectd=true;
      aswCont.cp.AccountId = accountInstance.Id;
      aswCont.Next();
      aswCont.getAcc();
      aswCont.getYesNo();
      aswCont.yes();
      aswCont.cont();
      aswCont.finish();
      
      aswCont.getContracts();
      //aswCont.Save();
      Test.stopTest();
  }
  
  private static testMethod void testAssignmentWizardController2() {
        Test.startTest();
        PageReference myVfPage = Page.AssignmentWizard;
        Test.setCurrentPage(myVfPage);
        ApexPAges.StandardController sc = new ApexPages.StandardController(contractInstance);
        
      AssignmentWizardController aswCont = new AssignmentWizardController(sc);
      AssignmentWizardController.ObjectStructureMap objStrct;
     // conStrCont.getContracts();
     // objStrct.selectd=true;
      AssignmentWizardController.AssignmentWrapper assWrap;
      //aswCont.setcurrentId(contractInstance.Id);
      aswCont.getObjectStructure();
      aswCont.asm[0].selectd=true;
      aswCont.cp.AccountId = accountInstance.Id;
      aswCont.Next();
      aswCont.back();
      aswCont.getAcc();
      aswCont.getYesNo();
      aswCont.yes();
      aswCont.cont();
      aswCont.back2();
      //aswCont.finish();
      
      aswCont.getContracts();
      //aswCont.Save();
      Test.stopTest();
  }
  private static testMethod void testAssignmentWizardController3() {
        Test.startTest();
        PageReference myVfPage = Page.AssignmentWizard;
        Test.setCurrentPage(myVfPage);
        ApexPAges.StandardController sc = new ApexPages.StandardController(contractInstance);
        
      AssignmentWizardController aswCont = new AssignmentWizardController(sc);
      AssignmentWizardController.ObjectStructureMap objStrct;
     // conStrCont.getContracts();
     // objStrct.selectd=true;
      AssignmentWizardController.AssignmentWrapper assWrap;
      //aswCont.setcurrentId(contractInstance.Id);
      aswCont.getObjectStructure();
      aswCont.asm[0].selectd=true;
      aswCont.cp.AccountId = accountInstance.Id;
      aswCont.Next();
      aswCont.back();
      aswCont.getAcc();
      aswCont.getYesNo();
      aswCont.no();
     // aswCont.cont();
     // aswCont.back2();
      //aswCont.finish();
      
      //aswCont.getContracts();
      //aswCont.Save();
      Test.stopTest();
  }
  private static testMethod void testAssignmentWizardController4() {
        Test.startTest();
        PageReference myVfPage = Page.AssignmentWizard;
        Test.setCurrentPage(myVfPage);
        ApexPAges.StandardController sc = new ApexPages.StandardController(contractInstance);
        
      AssignmentWizardController aswCont = new AssignmentWizardController(sc);
      AssignmentWizardController.ObjectStructureMap objStrct;
     // conStrCont.getContracts();
     // objStrct.selectd=true;
      AssignmentWizardController.AssignmentWrapper assWrap;
      //aswCont.setcurrentId(contractInstance.Id);
      aswCont.getObjectStructure();
      aswCont.asm[0].selectd=true;
      aswCont.Cancel();
      //aswCont.Save();
      Test.stopTest();
  }

}