@isTest(SeeAllData=True)
private class TestShowSupportAlert{
public static testmethod void TestShowSupportAlert(){
    
    Account newAccount = new Account();
    newAccount.Name = 'SFDC';
    newAccount.Type = 'Other';
    newAccount.BillingStreet = 'Test Address';
    newAccount.BillingCity = 'Test City';
    newAccount.BillingCountry = 'Test Country';
    insert newAccount;
       
    Support_Alert__c newSuppalert1 = new Support_Alert__c();
    newSuppalert1.Account__c = newAccount.Id;
    newSuppalert1.Description__c = 'Test Descritpion';
    newSuppalert1.End_Date__c =  date.today()+4;
    insert newSuppalert1;
    
    Support_Alert__c newSuppalert2 = new Support_Alert__c();
    newSuppalert2.Account__c = newAccount.Id;
    newSuppalert2.Description__c = 'Test Descritpion';
    newSuppalert2.Critical__c = true;
    newSuppalert2.End_Date__c =  date.today()+4;
    insert newSuppalert2;
    
    Contact newcnt=new Contact();
    newcnt.FirstName='SFDC';
    newcnt.LastName='Salesforce';
    newcnt.AccountId = newAccount.Id;
    insert newcnt;
       
    NMC_Account__c nmcacct = new NMC_Account__c(Name='Test NMC Acct', NMC_Account_Name__c = 'Test NMC Name',NMC_Account__c='123');
    nmcacct.account__c = newAccount.Id;
    try{
        insert nmcacct;
    }catch(Exception ex){}
    
    RecordType recTypeCallCenter = [Select Id from RecordType where name = 'Call Center' limit 1];
    RecordType recTypeOther = [Select Id from RecordType where name != 'Call Center' limit 1];
    
    Case CaseNew = new Case();
    CaseNew.Status = 'Open';
    CaseNew.Substatus__c ='In Progress';
    CaseNew.AccountId = newAccount.Id;
    CaseNew.ContactID = newcnt.Id;
    
    insert CaseNew;
    
    
    
    ApexPages.currentPage().getParameters().put('Id',CaseNew.Id);
    ApexPages.StandardController sdtCon = new ApexPages.StandardController(CaseNew);
    ShowSupportAlertController newObj = new ShowSupportAlertController(sdtCon);
    newObj.acctId  = newAccount.Id;
    newObj.SaveandNew();
    newObj.redirectToNewCase();
    newObj.findSupportAlert();
    ApexPages.currentPage().getParameters().put('AccountId',newAccount.Id);
    newObj.findRec();
    Apexpages.currentPage().getParameters().put('ContactId',newcnt.Id);
    newObj.findRec();
    Apexpages.currentPage().getParameters().put('NMCAccountId',nmcacct.Id);
    newObj.findRec();
    newObj.redirectionOnEdit();
    Integer i = newObj.getTotalSuppAlert();
    newObj.setTotalSuppAlert(i);
    Apexpages.currentPage().getParameters().put('cas3_lkid',newcnt.Id);
    Apexpages.currentPage().getParameters().put('cas3',newcnt.Name);
    Apexpages.currentPage().getParameters().put('cas4',newAccount.Name);
    Apexpages.currentPage().getParameters().put('cas4_lkid',newcnt.AccountId);
    newObj.redirectToNewCase();
    Apexpages.currentPage().getParameters().put('cas4',newAccount.Name);
    Apexpages.currentPage().getParameters().put('cas4_lkid',newAccount.Id);
    newObj.redirectToNewCase();
    Apexpages.currentPage().getParameters().put('CF00N50000001cc33',nmcacct.Name);
    Apexpages.currentPage().getParameters().put('CF00N50000001cc33_lkid',nmcacct.Id);
    Apexpages.currentPage().getParameters().put('cas4',newAccount.Name);
    Apexpages.currentPage().getParameters().put('cas4_lkid',newAccount.Id);
    newObj.redirectToNewCase();
    
    
    
    }
   
   public static testmethod void TestShowSupportAlert1(){ 
    
    Case CaseNew2 = new Case();
    CaseNew2.Status = 'Open';
    CaseNew2.Substatus__c ='In Progress';
    //CaseNew2.AccountId = newAccount.Id;
    //CaseNew2.ContactID = newcnt.Id;
    CaseNew2.recordTypeId = System.Label.Call_Center_RecordTypeId;
    insert CaseNew2;
    ApexPages.StandardController sdtCon1 = new ApexPages.StandardController(CaseNew2);
    ShowSupportAlertController newObj1 = new ShowSupportAlertController(sdtCon1);
    newObj1.redirectToNewCase();
    
   }
   
   public static testMethod void testRest(){
        Account newAccount = new Account();
        newAccount.Name = 'SFDC';
        newAccount.Type = 'Other';
        newAccount.BillingStreet = 'Test Address';
        newAccount.BillingCity = 'Test City';
        newAccount.BillingCountry = 'Test Country';
        insert newAccount;
    
        List<Support_Alert__c> testSupportAlertList = new List<Support_Alert__c>();
        
        for(Integer i=0; i<= 6;++i){
            Support_Alert__c testSupportAlert = new Support_Alert__c();
            testSupportAlert.Account__c = newAccount.Id;
            //testSupportAlert.End_Date__c = Date.today()+4;
            testSupportAlert.End_Date__c = NULL;
            testSupportAlertList.add(testSupportAlert);
        }
        
        insert testSupportAlertList;
        
        ShowSupportAlertController testController = new ShowSupportAlertController();
        testController.acctId = testSupportAlertList.get(0).Account__c;
        testController.getLstSupportAlert();
        testController.getLstAllSupportAlert();
        testController.setLstSupportAlert(testSupportAlertList) ;
        testController.setLstAllSupportAlert(testSupportAlertList);
        
        testController.caseRecType = System.Label.Call_Center_RecordTypeId;
        testController.showSupportAlerts();
        Case testCase = new Case();
        insert testCase;
        testController.currCase = testCase; 
        testController.Save();   
        
        Apexpages.currentPage().getParameters().put('CF00N50000001cc33',null);  
        Apexpages.currentPage().getParameters().put('CF00N50000001cc33_lkid',null);     
        testController.redirectToNewCase();
        Apexpages.currentPage().getParameters().put('cas3_lkid',null);
        
        testController.contId =  'testContId';
        testController.findRelAccount();
   }
}