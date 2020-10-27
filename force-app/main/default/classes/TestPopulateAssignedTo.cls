@isTest(SeeAllData = true)
public class TestPopulateAssignedTo {
    static testmethod void testPopulateAssignedTo() {
        
        Account newAccount = new Account();         
            newAccount.Name = 'SFDC';         
            newAccount.Type = 'Other';         
            newAccount.BillingStreet = 'Test Address';         
            newAccount.BillingCity = 'Test City';         
            newAccount.BillingCountry = 'Test Country';
        	newAccount.BillingState = 'Test State';
        	newAccount.BillingPostalCode = 'Test ZipCode';
        	newAccount.Segment__c = 'TL';
        	newAccount.Fleet_Size__c = 25;
            newAccount.QWBS_Cust_ID__c = '4567';        
        
        insert newAccount;
        
        Contact newContact=new Contact();
        newContact.FirstName='SFDC';
        newContact.LastName='Salesforce';
        newContact.Email = 'c_skarn@qualcomm.com'; 
        newContact.AccountId = newAccount.Id;
        
        insert newContact;
      
        Contract_Request__c CR = new Contract_Request__c(
                                  Account__c = newAccount.Id,
                                  Description__c = 'Test', 
                                  Contact__c = newContact.Id,
                                  Contracts_Administrator_to_Send__c = 'No',
                                  No_Approvals_Required__c = true,
                                  Product_Reduced_Price__c = '5.00',
                                  Requested_Completion_Date__c = (System.Today()+30)
                                 );
        insert CR;      
    }
}