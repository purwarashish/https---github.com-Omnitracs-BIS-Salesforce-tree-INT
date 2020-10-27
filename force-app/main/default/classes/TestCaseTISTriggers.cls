@isTest(SeeAllData=True)
private class TestCaseTISTriggers
{
/* commented by Arindam Laik, as we have consolidated all Case related test class into one
//--------Test Method to validate the trigger "CaseTISDetail" on Case
public static testmethod void TestByCreatingCase()
{
account acct1 = new account(QWBS_Market__c = 'T&L Eastern Region', Name = 'My Test',            BillingStreet = '123 Main', BillingCity = 'San Diego', BillingState = 'CA', BillingCountry = 'USA',QWBS_Cust_ID__c='12101986',RFC_ID__c='29051986');        
insert acct1;
Case CaseNew = new Case();
CaseNew.Status = 'Open';
CaseNew.Substatus__c ='In Progress';
CaseNew.AccountId = acct1.Id;
insert CaseNew;

System.debug('Case Created with SID :' + CaseNew.Id);

CaseNew.Status = 'Pending';
update CaseNew;

CaseNew.Status = 'Closed';
CaseNew.Resolution__c = 'test';
CaseNew.Description = 'test';
update CaseNew;
}

public static testmethod void Testmethod2()
{
Group newGroup = new Group();
newGroup.name = 'Test Queue';
newGroup.type = 'Queue';
insert newGroup;

Group newGroup1 = new Group();
newGroup1.name = 'Test Queue1';
newGroup1.type = 'Queue';
insert newGroup1;
account acct1 = new account(QWBS_Market__c = 'T&L Eastern Region', Name = 'My Test',            BillingStreet = '123 Main', BillingCity = 'San Diego', BillingState = 'CA', BillingCountry = 'USA',QWBS_Cust_ID__c='12101986',RFC_ID__c='29051986');        
insert acct1;

Case newCase2 = new Case();
newCase2.Queue__c = newGroup.name;
newCase2.AccountId = acct1.Id;
insert newCase2;

newCase2.Queue__c = newGroup1.name;
update newCase2;

newCase2.Status = 'Open';
newCase2.Substatus__c ='In Progress';
update newCase2;

newCase2.status = 'Closed';
newCase2.Resolution__c = 'test';
newCase2.description = 'test';
update newCase2;

}

public static testmethod void Testmethod3()
{
account acct1 = new account(QWBS_Market__c = 'T&L Eastern Region', Name = 'My Test',            BillingStreet = '123 Main', BillingCity = 'San Diego', BillingState = 'CA', BillingCountry = 'USA',QWBS_Cust_ID__c='12101986',RFC_ID__c='29051986');        
insert acct1;


Case newCase2 = new Case();
newCase2.description = 'test';
newCase2.Status = 'Open';
newCase2.Substatus__c ='In Progress';
newCase2.AccountId = acct1.Id;
insert newCase2;

newCase2.status = 'Pending';
update newCase2;

Group newGroup = new Group();
newGroup.name = 'Test Queue';
newGroup.type = 'Queue';
insert newGroup;

Group newGroup1 = new Group();
newGroup1.name = 'Test Queue1';
newGroup1.type = 'Queue';
insert newGroup1;

CreateTIS.insertCounter = 0;

newCase2.Queue__c = newGroup1.name;
update newCase2;
newCase2.Queue__c = newGroup.name;
update newCase2;

}

public static testmethod void Testmethod4()
{
account acct1 = new account(QWBS_Market__c = 'T&L Eastern Region', Name = 'My Test',            BillingStreet = '123 Main', BillingCity = 'San Diego', BillingState = 'CA', BillingCountry = 'USA',QWBS_Cust_ID__c='12101986',RFC_ID__c='29051986');        
insert acct1;

Case newCase = new Case();
newCase.status = 'Open';
newCase.substatus__c = 'In Progress';
newCase.AccountId = acct1.Id;
insert newCase;
CreateTIS.insertCounter = 0;
CreateTIS.updatecounter = 1;
newCase.status = 'Pending';
update newCase;
Group newGroup = new Group();
newGroup.name = 'Test Queue';
newGroup.type = 'Queue';
insert newGroup;
CreateTIS.insertCounter = 0;
CreateTIS.updatecounter = 1;
newCase.Queue__c = newGroup.name;
update newCase;

}*/

}