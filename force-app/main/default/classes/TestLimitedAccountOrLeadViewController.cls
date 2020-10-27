@isTest(seeAllData = true)
private Class TestLimitedAccountOrLeadViewController
{
public static testmethod void testLimAccOrLead()
{

Account newAccount = new Account();
        newAccount.Name = 'SFDC';
        newAccount.Type = 'Other';
        newAccount.BillingStreet = 'Test Address';
        newAccount.BillingCity = 'Test City';
        newAccount.BillingCountry = 'Test Country';
        newAccount.QWBS_Status__c = 'Contract Customer';
        newAccount.QWBS_Cust_ID__c = '4567';
        
        insert newAccount;
 
 

 
// Apexpages.currentPage().getParameters().put('id',newAccount.Id);

        Contact newCnt = new Contact();
        newCnt.FirstName = 'test';
        newCnt.LastName = 'Salestest';
        newCnt.email = 'abcxz@gmail.com';
        newCnt.MailingState = 'CA';
        newCnt.AccountId=newAccount.Id;
        
        insert newCnt;   
        

ApexPages.standardController setCont =  new ApexPages.StandardController(newCnt);

 PageReference pageref1 = page.LimitedAccountOrLeadView;
// pageref1.getParameters().put('id','001R000000m1Yl9');
pageref1.getParameters().put('id',newAccount.id);
 test.setcurrentpage(pageref1);
       
LimitedAccountOrLeadViewController limAccntAndLead = new LimitedAccountOrLeadViewController();
ApexPages.StandardSetController stdCtrlr = limAccntAndLead.setConCont;
limAccntAndLead.getContacts();
}
public static testmethod void testLimAccOrLead1()
{
     Lead l2 = new Lead(
            LastName = 'Test Last Name'
            ,Company = 'Test Company'
            ,FirstName = 'Test First Name'
            ,City = 'San Diego'
            ,State = 'CA'
            ,Country = 'US'
            
        );
        
        insert l2;
 
 PageReference pageref = page.LimitedAccountOrLeadView;
 //pageref.getParameters().put('id',l2.id);
pageref.getParameters().put('id','00Q5000000fKAfn');
 test.setcurrentpage(pageref);
 /*
Contact newCnt = new Contact();
        newCnt.FirstName = 'test';
        newCnt.LastName = 'Salestest';
        newCnt.email = 'abcxz@gmail.com';
        newCnt.MailingState = 'CA';
        
        insert newCnt;   
 Apexpages.currentPage().getParameters().put('id',l2.id);


ApexPages.standardController setCont =  new ApexPages.StandardController(newCnt);
*/

 LimitedAccountOrLeadViewController limAccntAndLead = new LimitedAccountOrLeadViewController();

}

}