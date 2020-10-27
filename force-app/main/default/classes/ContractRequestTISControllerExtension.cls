public class ContractRequestTISControllerExtension
{
/*******************************************************************************************************
Date: 6/12/2009
Author: Srilatha Gonuguntla, Salesforce.com Consultant
Tata Consultancy Services Limited

Overview: This Class is the controller for Visualforce Page "ViewTISContractRequest".

Revision History:
Modified on: 7/10/2009
Modified By: Rajkumari Nagarajan
Reason : Class modified to include "Request Status" option in "Display History For" picklist
and remove Owner and Status options from the picklist
*******************************************************************************************************/

// public String State {get; set;}
String State;
private Contract_Request__c ContractRequest;
public boolean ShowDetail {get; set;}

public String getState() {
return State;
}

public void setState(String State) {
this.State = State;
}

public ContractRequestTISControllerExtension(ApexPages.standardcontroller controller)
{
ContractRequest = (Contract_Request__c) controller.getRecord();
State = 'Request Status';
ShowDetail = true;
}

public PageReference TrueToggleShowDetail()
{
ShowDetail = true;
return null;
}

public PageReference FalseToggleShowDetail()
{
ShowDetail = false;
return null;
}

public List<SelectOption> getItems()
{
Set<String> FieldNameList = new Set<String>();
List<SelectOption> options = new List<SelectOption>();

//Adding "Test Status" as the first and default value in the picklist.
FieldNameList.add('Request Status');
options.add(new SelectOption('Request Status','Request Status'));

for (TIS_Detail__c TIS :[select name from TIS_Detail__c where Contract_Request__c =:
ContractRequest.Id and name !='Request Status' limit 1000])
{
//There are Field Names in TIS_Detail__c Object other than "Request Status"
if (!FieldNameList.contains(TIS.name))
{
System.debug('@@Add new record:"'+TIS.name+'" in the Display History For picklist');
FieldNameList.add(TIS.name);
options.add(new SelectOption(TIS.name,TIS.name));
}

}

return options;
}

public list<TIS_Summary__c> getTISSummary()
{
list<TIS_Summary__c> TISSum = new list<TIS_Summary__c>();
TISSum = [Select Duration__c, Last_Date_Time_Out__c, Name, State__c from TIS_Summary__c where Name =:State and Contract_Request__c =:ContractRequest.Id order by Last_Date_Time_Out__c ];
return TISSum ;
}

public list<TIS_Detail__c> getTISDetail()
{
list<TIS_Detail__c> TISDetail = new list<TIS_Detail__c>();
TISDetail = [Select Date_Time_In__c, Date_Time_Out__c, Duration__c, Owner__c, State__c, Who__c from TIS_Detail__c where Name =:State and Contract_Request__c =:ContractRequest.Id order by Date_Time_In__c ];
return TISDetail ;
}

public PageReference ReturntoContractRequest()
{
String returnurl = '/' + ContractRequest.Id;
PageReference pageRef = new PageReference(returnurl);
pageRef.setRedirect(true);
return pageRef;
}



}