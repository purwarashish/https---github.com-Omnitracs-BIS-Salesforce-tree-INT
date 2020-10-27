@isTest
/* 
Test class for "ViewSelectedCases" and "ViewSelectedContacts" */
//For "ViewSelectedCases"
private class TestRelatedLists{/*
public static testmethod void TestViewAlCases(){
   
   list<Case> lstCase = new list<Case>();
   
    Account newAccount = new Account();
    newAccount.Name = 'SFDC';
    newAccount.Type = 'Other';
    newAccount.BillingStreet = 'Test Address';
    newAccount.BillingCity = 'Test City';
    newAccount.BillingCountry = 'Test Country';
    insert newAccount;

   for(integer i=0;i<10;i++)
   {
       Case CaseNew = new Case();    
       CaseNew.Status = 'Open';    
       CaseNew.Substatus__c ='In Progress';  
       CaseNew.AccountId = newAccount.Id; 
       lstCase.add(CaseNew);
   }
   insert lstCase;
   ApexPages.currentPage().getParameters().put('AccountId',newAccount.Id);
   ApexPages.StandardController sdtCon;
   ViewSelectedCases newObj  = new ViewSelectedCases(sdtCon);
   newObj.AccountId = newAccount.Id;
   newObj.NewCase();
   newObj.getCaseList();
   newObj.asce = true;
   newObj.getCaseList();
   newObj.pagination();
   newObj.next();
   newObj.previous();
}

//For "ViewSelectedContacts"
public static testmethod void TestViewAlContacts(){
   
   list<Contact> lstContact = new list<Contact>();
   
    Account newAccount = new Account();
    newAccount.Name = 'SFDC';
    newAccount.Type = 'Other';
    newAccount.BillingStreet = 'Test Address';
    newAccount.BillingCity = 'Test City';
    newAccount.BillingCountry = 'Test Country';
    insert newAccount;

   for(integer i=0;i<10;i++)
   {
        Contact newcnt=new Contact();
        newcnt.FirstName='SFDC';
        newcnt.LastName='Salesforce';
        newcnt.AccountId = newAccount.Id;
        lstContact.add(newcnt);
   }
   insert lstContact;
   ApexPages.currentPage().getParameters().put('AccountId',newAccount.Id);
   ApexPages.StandardController sdtCon;
   ViewSelectedContacts newObj  = new ViewSelectedContacts(sdtCon);
   newObj.AccountId = newAccount.Id;
   newObj.getContactsList();
   newObj.asce = true;
   newObj.getContactsList();
   newObj.pagination();
   newObj.next();
   newObj.previous();
}
 */
}