@isTest(SeeAllData=True)//(SeeAllData=false)
public class TestOmnitracsCreateCaseController{

   public static testMethod void unitTestMethod(){
        
        Case CaseNew = new Case();
        CaseNew.Status = 'Open';
        CaseNew.Substatus__c ='In Progress';
        insert CaseNew;
        
        ApexPages.StandardController cnt = new ApexPages.StandardController(CaseNew);
        OmnitracsCreateCaseController  PMO = new OmnitracsCreateCaseController(cnt);
        PMO.createCase();
        PMO.clear();
        
           
        
        PMO = new OmnitracsCreateCaseController(cnt);
        PMO.newCase.subject ='Unit Test';
        PMO.newCase.Description = 'Unit Test Description';
        
        Account newAccount = new Account();
        newAccount.Name = 'SFDC';
        newAccount.Type = 'Other';
        newAccount.BillingStreet = 'Test Address';
        newAccount.BillingCity = 'Test City';
        newAccount.BillingCountry = 'Test Country';
        insert newAccount;         
    
        Contact newCnt1 = new Contact();
        newCnt1.FirstName = 'SFDC';
        newCnt1.LastName = 'Salesforce';
        newCnt1.email = 'xyz@gmail.com';
        newCnt1.AccountId = newAccount.Id;
        insert newCnt1;  
        PMO.requestorEmail =  'xyz@gmail.com';  

        //PMO.createCase();
        PMO = new OmnitracsCreateCaseController(cnt);
        
        PMO.reqestType ='Project Request';
        PMO.createCase();
        
        PMO.newCase.What_is_the_business_need__c = 'yes';
        PMO.createCase();
        PMO.newcase.What_are_the_expected_specific_benefits__c = 'yes';
        PMO.createCase();
        PMO.newcase.What_do_you_want_it_to_do__c = 'yes';
        PMO.createCase();
        PMO.newcase.Who_is_impacted_by_this_request_when_imp__c = 'internal';
        PMO.createCase();
        
    }
}