@isTest(SeeAllData=True)
private class TestPopulateQualcommCounterSigner {

    static testMethod void myUnitTest() 
    {
        Account newAccount = new Account();         
        newAccount.Name = 'SFDC';         
        newAccount.Type = 'Other';         
        newAccount.BillingStreet = 'Test Address';         
        newAccount.BillingCity = 'Test City'; 
        newAccount.BillingState = 'CA';         
        newAccount.BillingCountry = 'Test Country'; 
        newAccount.QWBS_Status__c = 'Contract Customer' ;       
        newAccount.QWBS_Cust_ID__c = '4567';        
        insert newAccount;

        Contact newContact = new Contact();
        newcontact.FirstName='SFDC';
        newcontact.LastName='Salesforce';
        newcontact.Email = 'c_skarn@qualcomm.com';
        newcontact.AccountId = newAccount.Id;
        newcontact.MailingState = 'CA';
        insert newContact;
        
        
        echosign_dev1__SIGN_Agreement__c newAgreement = new echosign_dev1__SIGN_Agreement__c();
        newAgreement.echosign_dev1__Recipient__c = newContact.Id;
        newAgreement.echosign_dev1__Account__c = newAccount.Id;
        newAgreement.name = 'TEST';
        insert newAgreement;
        
    }
}