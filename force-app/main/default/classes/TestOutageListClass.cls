@isTest(SeeAllData = true)
public class TestOutageListClass{
/***************************************************************************************************************
Date: 30/03/2010
Author: Shruti Karn, Salesforce.com Developer
Tata Consultancy Services Limited

Purpose: Test Method to validate the functionality of Class "OutageListClass" on System Outage Object.
********************************************************************************************************************/
static testmethod void Testmethod1() 
{
account acct1 = new account(QWBS_Market__c = 'T&L Eastern Region', Name = 'My Test',            BillingStreet = '123 Main', BillingCity = 'San Diego', BillingState = 'CA', BillingCountry = 'USA',QWBS_Cust_ID__c='12101986',RFC_ID__c='29051986');            
insert acct1;
Case CaseNew = new Case();
CaseNew.Status = 'Open';
CaseNew.Substatus__c ='In Progress';
CaseNew.Resolution__c = 'test';
CaseNew.Description = 'test';
CaseNew.AccountID = acct1.Id;
insert CaseNew;

ApexPages.currentPage().getParameters().put('Id',CaseNew.Id);
ApexPages.StandardController sdtCon;
OutageListClass obj = new OutageListClass(sdtCon);
system.debug('caseid in 1:'+obj.caseid);
System_Outage__c outageHeaderObj = new System_Outage__c();
outageHeaderObj.Case__c = CaseNew.Id;
outageHeaderObj.Start_Time__c = system.Now();
insert outageHeaderObj;

Obj.asce = false;
Obj.current_value = 'Name';
Obj.ChangeOrder();

Obj.current_value = 'subsystem';
Obj.ChangeOrder();

Obj.current_value = 'system';
Obj.ChangeOrder();


Obj.asce = true;
Obj.current_value = 'Name';
Obj.ChangeOrder();

Obj.current_value = 'system';
Obj.ChangeOrder();

Obj.alphabet = 'All';
Obj.alphabet_Ordering();

}

static testmethod void Testmethod2() 
{
account acct1 = new account(QWBS_Market__c = 'T&L Eastern Region', Name = 'My Test',            BillingStreet = '123 Main', BillingCity = 'San Diego', BillingState = 'CA', BillingCountry = 'USA',QWBS_Cust_ID__c='12101986',RFC_ID__c='29051986');            
insert acct1;
Case CaseNew = new Case();
CaseNew.Status = 'Open';
CaseNew.Substatus__c ='In Progress';
CaseNew.Resolution__c = 'test';
CaseNew.Description = 'test';
CaseNew.AccountId = acct1.Id;
insert CaseNew;

System_Outage__c outageHeaderObj = new System_Outage__c();
outageHeaderObj.Case__c = CaseNew.Id;
outageHeaderObj.Start_Time__c = system.Now();
insert outageHeaderObj;

system.debug('CaseNewId:'+CaseNew.Id);
ApexPages.currentPage().getParameters().put('Id',CaseNew.Id);

ApexPages.StandardController sdtCon;
OutageListClass obj = new OutageListClass(sdtCon);
system.debug('CaseId:'+Obj.CaseId);
Obj.current_value = 'Name';
Obj.alphabet = 'A';
Obj.alphabet_Ordering();

Obj.current_value = 'Name';
Obj.alphabet = 'All';
Obj.alphabet_Ordering();



}
}