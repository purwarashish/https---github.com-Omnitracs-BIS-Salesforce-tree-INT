@isTest(SeeAllData=True)
private class TestiQOVCases{

public static testmethod void Testmethod1(){
User currentUser = [select id ,Username from User where Username like 'emailagent@omnitracs.com%' limit 1];
RecordType recordTypeName = [select id,name from RecordType where name='Email Generated Cases' limit 1];
account acct1 = new account(QWBS_Market__c = 'T&L Eastern Region', Name = 'My Test',            BillingStreet = '123 Main', BillingCity = 'San Diego', BillingState = 'CA', BillingCountry = 'USA',QWBS_Cust_ID__c='12101986',RFC_ID__c='29051986');        
insert acct1;

Case newCase = new Case();

system.runAs(currentUser) 
{
newCase.Origin = 'Email-iQ OV Requests';
newCase.RecordTypeId =recordTypeName.Id;
newCase.Subject='reporting services access requested';
newCase.Status = 'Open'; 
newCase.Substatus__c ='In Progress';
newCase.description = 'Customer ID: 4567 Customer Name: Test Customer Unit Type: MCP200 UA: 0099988 Op Profile Name: Test123 Date/Time of WIB Downgrade Notification: 5/28/10 4:55 PM';
newCase.AccountId = acct1.Id;
insert newCase;
}
newCase.description = 'Customer ID: Customer Name: Test Customer Unit Type: MCP200 UA: 0099988 Op Profile Name: Test123 Date/Time of WIB Downgrade Notification: 5/28/10 4:55 PM';
update newCase;


}

public static testmethod void Testmethod2A()
{
    User currentUser = [select id ,Username from User where Username like 'emailagent@omnitracs.com%' limit 1];
    RecordType recordTypeName = [select id,name from RecordType where name='Email Generated Cases' limit 1];

    Account newAccount = new Account(); 
    newAccount.Name = 'SFDC'; 
    newAccount.Type = 'Other'; 
    newAccount.BillingStreet = 'Test Address'; 
    newAccount.BillingCity = 'Test City'; 
    newAccount.BillingCountry = 'Test Country'; 
    newAccount.CSR__c = currentUser.Id;
    newAccount.QWBS_Cust_ID__c = '4567';
    insert newAccount;

    Account newAccount1 = new Account(); 
    newAccount1.Name = 'SFDC'; 
    newAccount1.Type = 'Other'; 
    newAccount1.BillingStreet = 'Test Address'; 
    newAccount1.BillingCity = 'Test City'; 
    newAccount1.BillingCountry = 'Test Country'; 
    newAccount1.CSR__c = null;
    insert newAccount1;

    Contact newcnt=new Contact();
    newcnt.FirstName='SFDC';
    newcnt.LastName='Salesforce';
    newcnt.AccountId = newAccount.Id;
    insert newcnt;
    system.runAs(currentUser) 
    {
        Test.startTest();
         
        Case newCase = new Case();
        newCase.Origin = 'Email-iQ OV Requests';
        newCase.RecordTypeId =recordTypeName.Id;
        newCase.Subject='reporting services access requested';
        newCase.Status = 'Open'; 
        newCase.Substatus__c ='In Progress';
        newCase.description = 'Customer ID: 4567 Customer Name: Test Customer Unit Type: MCP200 UA: 0099988 Op Profile Name: Test123 Date/Time of WIB Downgrade Notification: 5/28/10 4:55 PM';
        newCase.ContactId = newcnt.Id;
        newCase.AccountId = null;
        insert newCase;





        Case newCase2 = new Case();
        newCase2.Origin = 'Email-iQ OV Requests';
        newCase2.RecordTypeId =recordTypeName.Id;
        newCase2.Subject='reporting services access requested';
        newCase2.description = 'Customer ID:1234 Customer Name: Test Customer Unit Type: MCP200 UA: 0099988 Op Profile Name: Test123 Date/Time of WIB Downgrade Notification: 5/28/10 4:55 PM';

        newCase2.AccountID = newAccount1.Id; 
        newCase2.ContactID = null;
        insert newCase2; 
        newCase2.description = 'Customer ID: Customer Name: Test Customer1 Unit Type: MCP200 UA: 0099988 Op Profile Name: Test123 Date/Time of WIB Downgrade Notification: 5/28/10 4:55 PM';
        update newCase2;

        Test.stopTest(); 
        /*  LOGIC WAS MOVED TO test2B due to too many soql queries when deploying 1/8/2014
        Case newCase1 = new Case();
        newCase1.Origin = 'Email-iQ OV Requests';
        newCase1.RecordTypeId =recordTypeName.Id;
        newCase1.Subject='reporting services access requested';
        newCase1.description = 'Customer ID: Customer Name: Test Customer Unit Type: MCP200 UA: 0099988 Op Profile Name: Test123 Date/Time of WIB Downgrade Notification: 5/28/10 4:55 PM';
        newCase1.ContactId = newcnt.Id;

        //newCase1.Status = 'Open'; 
        //newCase1.Substatus__c ='In Progress';
        newCase1.description = 'Customer ID: Customer Name: Test Customer Unit Type: MCP200 UA: 0099988 Op Profile Name: Test123 Date/Time of WIB Downgrade Notification: 5/28/10 4:55 PM';
        insert newCase1; 
        newCase1.AccountId = newAccount1.Id;
        update newCase1; 
        //delete newAccount;
        newCase.Status = ''; 
        newCase.Substatus__c ='';
        update newCase; 
        */
    }

}
    
    public static testmethod void Testmethod2b()
    {
       User currentUser = [select id ,Username from User where Username like 'emailagent@omnitracs.com%' limit 1];
       RecordType recordTypeName = [select id,name from RecordType where name='Email Generated Cases' limit 1]; 
        Account newAccount = new Account(); 
        newAccount.Name = 'SFDC'; 
        newAccount.Type = 'Other'; 
        newAccount.BillingStreet = 'Test Address'; 
        newAccount.BillingCity = 'Test City'; 
        newAccount.BillingCountry = 'Test Country'; 
        newAccount.CSR__c = currentUser.Id;
        newAccount.QWBS_Cust_ID__c = '4567';
        insert newAccount;
    
        Account newAccount1 = new Account(); 
        newAccount1.Name = 'SFDC'; 
        newAccount1.Type = 'Other'; 
        newAccount1.BillingStreet = 'Test Address'; 
        newAccount1.BillingCity = 'Test City'; 
        newAccount1.BillingCountry = 'Test Country'; 
        newAccount1.CSR__c = null;
        insert newAccount1;
    
        Contact newcnt=new Contact();
        newcnt.FirstName='SFDC';
        newcnt.LastName='Salesforce';
        newcnt.AccountId = newAccount.Id;
        insert newcnt;
        
        Case newCase = new Case();
        newCase.Origin = 'Email-iQ OV Requests';
        newCase.RecordTypeId =recordTypeName.Id;
        newCase.Subject='reporting services access requested';
        newCase.Status = 'Open'; 
        newCase.Substatus__c ='In Progress';
        newCase.description = 'Customer ID: 4567 Customer Name: Test Customer Unit Type: MCP200 UA: 0099988 Op Profile Name: Test123 Date/Time of WIB Downgrade Notification: 5/28/10 4:55 PM';
        newCase.ContactId = newcnt.Id;
        newCase.AccountId = null;
        insert newCase;
        
        system.runAs(currentUser) 
        {
            Test.startTest();//  BE VERY ADVISED THAT THE 2A method did not have this code in startTest/StopTest, i am putting it here
            //  as i think it makes sense...
            Case newCase1 = new Case();
            newCase1.Origin = 'Email-iQ OV Requests';
            newCase1.RecordTypeId =recordTypeName.Id;
            newCase1.Subject='reporting services access requested';
            newCase1.description = 'Customer ID: Customer Name: Test Customer Unit Type: MCP200 UA: 0099988 Op Profile Name: Test123 Date/Time of WIB Downgrade Notification: 5/28/10 4:55 PM';
            newCase1.ContactId = newcnt.Id;
    
            //newCase1.Status = 'Open'; 
            //newCase1.Substatus__c ='In Progress';
            newCase1.description = 'Customer ID: Customer Name: Test Customer Unit Type: MCP200 UA: 0099988 Op Profile Name: Test123 Date/Time of WIB Downgrade Notification: 5/28/10 4:55 PM';
            insert newCase1; 
            newCase1.AccountId = newAccount1.Id;
            update newCase1; 
            //delete newAccount;
            newCase.Status = ''; 
            newCase.Substatus__c ='';
            update newCase; 
            Test.stopTest(); 
        }
        
    }
public static testmethod void Testmethod3(){

User currentUser = [select id ,Username from User where Username like 'emailagent@omnitracs.com%' limit 1];
RecordType recordTypeName = [select id,name from RecordType where name='Email Generated Cases' limit 1];
Account newAccount1 = new Account(); 
newAccount1.Name = 'SFDC'; 
newAccount1.Type = 'Other'; 
newAccount1.BillingStreet = 'Test Address'; 
newAccount1.BillingCity = 'Test City'; 
newAccount1.BillingCountry = 'Test Country'; 
newAccount1.CSR__c = null;
newAccount1.QWBS_Cust_ID__c = '4567';

insert newAccount1;
//Case newCase = new Case();
list<Case> lstCase = new list<case>();
account acct1 = new account(QWBS_Market__c = 'T&L Eastern Region', Name = 'My Test',            BillingStreet = '123 Main', BillingCity = 'San Diego', BillingState = 'CA', BillingCountry = 'USA',QWBS_Cust_ID__c='12101986',RFC_ID__c='29051986');            
insert acct1;
system.runAs(currentUser) 
{
//for(integer i=0;i<200;i++)
//{
Case newCase = new Case();

newCase.Origin = 'Email-iQ OV Requests';
newCase.RecordTypeId =recordTypeName.Id;
newCase.Subject='reporting services access requested';
newCase.Status = 'Open'; 
newCase.Substatus__c ='In Progress';
newCase.description = 'Customer ID:4567 Customer Name: Test Customer Unit Type: MCP200 UA: 0099988 Op Profile Name: Test123 Date/Time of WIB Downgrade Notification: 5/28/10 4:55 PM';
newCase.AccountId = newAccount1.Id;
insert newCase;

//lstCase.add(newCase);
//}
//insert lstCase;
}
/*newCase.Substatus__c ='Assigned';
update newCase;
newCase.ContactId = null;
update newCase;*/
}

}