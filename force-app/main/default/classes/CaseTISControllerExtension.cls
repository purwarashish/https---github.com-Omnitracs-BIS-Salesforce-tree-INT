public class CaseTISControllerExtension
{
/*******************************************************************************************************
Date: 03/01/2010
Author: Shruti Karn, Salesforce.com Developer
Tata Consultancy Services Limited

Overview: This Class is the controller for Visualforce Page "ViewTISCases".
*******************************************************************************************************/

public String State {get; set;}
private Case CSCase;
Public boolean ShowDetail {get; set;}
List<SelectOption> OptionsList;

public CaseTISControllerExtension(ApexPages.standardcontroller controller)
{
CSCase = (Case) controller.getRecord();
ShowDetail = true;
OptionsList = new List<SelectOption>();
CalculateOptionsList();
}

public void CalculateOptionsList()
{
Set<String> FieldNameList = new Set<String>();

System.debug('Adding "Status" as the first and default value in the picklist.');
FieldNameList.add('Status');
State = 'Status';
OptionsList.add(new SelectOption('Status','Status'));

for (TIS_Detail__c TIS :[select name from TIS_Detail__c where Case__c =:CSCase.Id and name !='Status' limit 1000])
{
System.debug('There are Field Names in TIS_Detail__c table other than "Status"');
if (!FieldNameList.contains(TIS.name))
{
System.debug('@@Add new record:"'+TIS.name+'" in the list');
FieldNameList.add(TIS.name);
OptionsList.add(new SelectOption(TIS.name,TIS.name));
}

}

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
return OptionsList;
}

public list<TIS_Summary__c> getTISSummary()
{
System.debug('State====>'+ State);
list<TIS_Summary__c> TISSum = [Select Duration_for_Cases__c, Last_Date_Time_Out__c, Name, State__c from TIS_Summary__c where Name =:State and Case__c =:CSCase.Id order by Last_Date_Time_Out__c ];
return TISSum ;
}

public list<TIS_Detail__c> getTISDetail()
{
System.debug('State====>'+ State);
system.debug('Case Number:'+CSCase.Id);
list<TIS_Detail__c> TISDetail = [Select Date_Time_In__c, Date_Time_Out__c,Duration_for_Cases__c, Owner__c, State__c, Who__c from TIS_Detail__c where Name =:State and Case__c =:CSCase.Id order by Date_Time_In__c ];
system.debug('TISDetail List:'+TISDetail);
return TISDetail;
}

public PageReference ReturntoCase()
{
String returnurl = '/' + CSCase.Id;
PageReference pageRef = new PageReference(returnurl);
pageRef.setRedirect(true);
return pageRef;
}



}