@isTest(SeeAllData=True)
public class TestSupportAlert {
    
    public static testMethod void testContactSupportAlerts(){
    
    Account newAccount = new Account();
    newAccount.Name = 'SFDC';
    newAccount.Type = 'Other';
    newAccount.BillingStreet = 'Test Address';
    newAccount.BillingCity = 'Test City';
    newAccount.BillingCountry = 'Test Country';
    insert newAccount;
    
    Support_Alert__c newSuppalert = new Support_Alert__c();
    newSuppalert.Account__c = newAccount.Id;
    newSuppalert.Description__c = 'Test Descritpion';
    newSuppalert.End_Date__c =  date.today()+4;
    insert newSuppalert;
    
    Contact newCnt=new Contact();
    newCnt.FirstName='SFDC';
    newCnt.LastName='Salesforce';
    newCnt.AccountId = newAccount.Id;
    insert newcnt;
    
    // create a new cotnact standard controller by passing the contact record
    ApexPages.StandardController contactController = new ApexPages.StandardController(newCnt);
    
    // now pass it to the extension
    SupportAlert alertController = new SupportAlert(contactController);
    
    //Test if the alertController is successfully created or not
    system.assert(alertController != null); 
    
    //Now test extension methods
    List<Support_Alert__c> alerts = alertController.getAlerts();
    
    system.assert(alerts != null);
    
    }
}