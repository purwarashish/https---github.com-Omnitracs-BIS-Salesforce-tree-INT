public class SystemOutageController{ 

public DateTime downTime {get; set;} 
public list<selectOption> L0systemList {get; set;} 
public list<selectOption> L1systemList {get; set;} 
public System_Outage__c outageObj = new System_Outage__c(); 
public String level0system {get; set;} 
public String level1system {get; set;} 
public Datetime startDate {get; set;} 
public Datetime endDate {get; set;} 
public String strStartDate {get; set;} 
public String strEndDate {get; set;} 
public String strStartDateGMT {get; set;} 
public String strEndDateGMT {get; set;} 
public String totalOutageTime {get; set;} 
public string outageType {get; set;} 
public list<System_Master__c> L3systemList {get; set;} 
public list<System_Master__c> L2systemList {get; set;} 
public list<Outage_Type_Mapping__c> mappingList {get; set;} 
public Boolean requestDependency {get; set;}{requestDependency = false;} 
public Case parentCase {get; set;} 
public Id caseInURL {get; set;} 
public Id CaseId {get; set;} 
public list<System_Outage_Line__c> displayedList = new list<System_Outage_Line__c>(); 
public list<System_Outage_Summary__c> summaryList = new list<System_Outage_Summary__c>(); 
public Boolean isUpdate {get; set;} 
public Boolean displayError {get; set;}{displayError =false;} 
public Boolean displayDateError {get; set;} {displayDateError =false;} 
public Boolean disableSubsystem {get; set;} 
public Boolean noDependencies {get; set;} 
public Boolean invalidDates {get; set;}{invalidDates =false;} 
public String strLevel1System{get; set;} 
public String createdById{get; set;} 
public String clone {get; set;} 
public String outageID {get; set;} 
public String createdDate{get; set;} 
public String lastModifiedById{get; set;} 
public String lastModifiedDate{get; set;} 
public String calledFromDependacies{get; set;}{calledFromDependacies= 'N';} 

//System Outage History Change
public List<System_Outage__History> HistoryList{get;set;}
public boolean RENDER_BACK{get;set;}
public boolean LIST_LINK{get;set;}
public Integer LIST_SIZE{get;set;}
public Integer TOTAL_COUNT{get;set;}
public Integer INDEX{get;set;}
public String TEMP_ID{get;set;}
public Integer LIMIT_CONSTANT{get;set;}
//added for error message
public Boolean isError{get;set;}

public System_Outage__c getoutageObj() 
{ 
return outageObj; 
} 

public list<System_Outage_Line__c> getdisplayedList() 
{ 
return displayedList; 
} 
public void setdisplayedList(list<System_Outage_Line__c> dummyList) 
{ 
displayedList = dummyList; 
} 

public SystemOutageController(ApexPages.StandardController stdController){ 

System.debug('inside Construction--'); 
outageID = Apexpages.currentPage().getParameters().get('Id'); 
clone = Apexpages.currentPage().getParameters().get('clone'); 
system.debug('CLONE '+clone); 
CaseId = Apexpages.currentPage().getParameters().get('CF00N50000001caGA_lkid'); 
system.debug('outageId '+outageID);
isError = false;
if(outageID != null)
getInitialList();
if(outageID == null) //when the page is displayed for the first time. 
{ 
system.debug('inside');
parentCase = [Select Id,CaseNumber From Case Where Id =:CaseId Limit 1]; 
fetchSystems(); 
fetchL1Systems(); 
isUpdate = false; 
disableSubsystem=true; 
system.debug('HERE L3'+L3systemList); 
} 

else if(CaseId != null && outageID != null) //edit mode from edit button 
{ 
try{ 
outageObj = [Select s.Type__c, s.Start_Time__c, s.Id, s.End_Time__c,s.Subsystem_Lookup__c,s.System_Lookup__c, s.Case__c From System_Outage__c s Where s.Id =:outageID limit 1]; System.debug('in edit mode-- Constructor'); 
displayedList = [Select s.System_Outage_Header__c, s.System_Master__c, s.Outage_Type__c, s.Level__c, s.Id From System_Outage_Line__c s Where s.System_Outage_Header__c =:outageID limit 1]; 
system.debug('LOOKUPS PASSED '+outageObj.System_Lookup__c +' '+outageObj.subsystem_Lookup__c); 
fetchSystems(); 
fetchL1Systems(); 
outageType = outageObj.Type__c; 
level0system = outageObj.System_Lookup__c; 
strLevel1System = outageObj.Subsystem_Lookup__c; 
startDate = outageObj.Start_Time__c; 
endDate = outageObj.End_Time__c; 
parentCase = [Select Id,CaseNumber From Case Where Id =:outageObj.Case__c limit 1]; 
system.debug('CONSTRUCTOR 2 '+outageObj +' '+displayedList); 
isUpdate = true; 
if(clone != 'true') 
getDependencies(); 
System.debug('in edit mode-- Constructor6'); 

} 
catch(Exception e){ 
system.debug('ERROR :: '+e); 
} 

} 

else //read only mode 
{ 
outageObj = [Select s.Name,s.Type__c, s.Start_Time__c, s.Id, s.End_Time__c,Calculated_Downtime__c,s.Start_Time_GMT__c,s.End_Time_GMT__c, s.Subsystem_Lookup__c,s.System_Lookup__c, s.Case__c,s.LastModifiedDate, s.LastModifiedById, s.CreatedDate,s.CreatedById From System_Outage__c s Where s.Id =:outageID limit 1]; 
createdById = outageObj.CreatedById; 
createdDate= outageObj.CreatedDate.format('MM/dd/yyyy h:mm a', 'PST'); 
lastModifiedById= outageObj.LastModifiedById; 
lastModifiedDate= outageObj.LastModifiedDate.format('MM/dd/yyyy h:mm a', 'PST'); 
displayedList = [Select s.System_Outage_Header__c, s.System_Master__c, s.Outage_Type__c, s.Level__c, s.Id From System_Outage_Line__c s Where s.System_Outage_Header__c =:outageID ]; 
outageType = outageObj.Type__c; 
system.debug('SYSTEM PASSED '+outageObj.System_Lookup__c); 
if(outageObj.System_Lookup__c ==null) 
level0system = ''; 
else 
level0system = [SELECT Id,Name,Parent__c FROM System_Master__c WHERE Id =: outageObj.System_Lookup__c limit 1].Name; 
system.debug('SUBSYSTEM '+outageObj.Subsystem_Lookup__c ); 
if(outageObj.Subsystem_Lookup__c == null) level1system = ''; 
else level1system = [SELECT Id,Name,Parent__c FROM System_Master__c WHERE Id =: outageObj.Subsystem_Lookup__c limit 1].Name; 
if(outageObj.Start_Time__c != null) 
strStartDate = outageObj.Start_Time__c.format('MM/dd/yyyy h:mm a', 'PST'); 
else 
strStartDate = ''; 
if(outageObj.End_Time__c != null) 
strEndDate = outageObj.End_Time__c.format('MM/dd/yyyy h:mm a', 'PST'); 
else 
strEndDate = null; 

strStartDateGMT = outageObj.Start_Time_GMT__c; 
strEndDateGMT = outageObj.End_Time_GMT__c; 

totalOutageTime = outageObj.Calculated_Downtime__c; 
parentCase = [Select Id,CaseNumber From Case Where Id =:outageObj.Case__c limit 1]; 
if(parentCase != null) 
caseInURL = parentCase.Id; 
else 
caseInURL = ''; 
system.debug('CONSTRUCTOR 3 '+outageObj +' '+displayedList); 

} 

} 

public void fetchSystems(){ 

L0systemList = new list<selectOption>(); 
L0systemList.add(new selectOption('','--None--')); 
for(System_Master__c sysMasterObj :[Select ID,Name from System_Master__c where level__c = 'level - 0' and inactive__c = false order by Name limit 1000]) 
{ 
L0systemList.add(new selectOption(sysMasterObj.ID,sysMasterObj.Name)); 
} 

} 

public pageReference fetchL1Systems(){ 
try{ 
system.debug('FETCHMETHODL1SYSTEMMS!!! ' +outageObj.System_Lookup__c); 
L1systemList = new list<selectOption>(); 
L1systemList.add(new selectOption('','--None--')); 
if(level0System != '') 
{ 
for(System_Master__c L1SystemObj :[Select ID,Name from System_Master__c where Parent__c =:outageObj.System_Lookup__c and inactive__c = false order by Name limit 1000]) 
{ 
L1systemList.add(new selectOption(L1SystemObj.ID,L1SystemObj.Name)); 
} 

} 
disableSubsystem = false; 
system.debug('HERE ' +L1systemList); 
strLevel1System = outageObj.subSystem_Lookup__c; 
}catch(Exception e){ 
System.debug('EXCEPTION------->'+e); 
} 
return null; 
} 

public pageReference CancelProcess(){ 

String CaseId = Apexpages.currentPage().getParameters().get('CF00N50000001caGA_lkid'); 
String ActivatedURL = '/'+CaseId; 
System.debug('==>'+ ActivatedURL ); 
PageReference pageRef = new PageReference(ActivatedURL); 
pageRef.setRedirect(true); 
return pageRef; 

} 

//Redirects back to Parent Case 
public pageReference BackToCase(){ 

String outageID = Apexpages.currentPage().getParameters().get('Id'); 
String CaseId = [Select Id, Case__c from System_Outage__c Where Id =:outageID limit 1].Case__c; 
String ActivatedURL = '/'+CaseId; 
System.debug('==>'+ ActivatedURL ); 
PageReference pageRef = new PageReference(ActivatedURL); 
pageRef.setRedirect(true); 
return pageRef; 

} 

public pageReference RedirectToOutageList(){ 

String outageID = Apexpages.currentPage().getParameters().get('Id'); 
String CaseId = [Select Id, Case__c from System_Outage__c Where Id =:outageID limit 1].Case__c; 
//String ActivatedURL = '/a0Z?rlid=00N50000001caGA&id='+CaseId; 
String ActivatedURL = '/apex/OutageList?id='+CaseId;
System.debug('==>'+ ActivatedURL ); 
PageReference pageRef = new PageReference(ActivatedURL); 
pageRef.setRedirect(true); 
return pageRef; 

} 

public pageReference CancelUpdate(){ 

system.debug('REDIRECTING - CANCEL UPDATE'); 
String outageID = Apexpages.currentPage().getParameters().get('Id'); 
String ActivatedURL = '/apex/DisplaySystemOutage'+'?Id='+outageID; 
System.debug('==>'+ ActivatedURL ); 
PageReference pageRef = new PageReference(ActivatedURL); 
pageRef.setRedirect(true); 
return pageRef; 
} 

public pageReference deleteHeader(){ 

String outageID = Apexpages.currentPage().getParameters().get('Id'); 
System_Outage__c OutageObjToBeDeleted = [Select s.Id, s.Case__c From System_Outage__c s Where s.Id =:outageID limit 1 ]; 
String CaseId = OutageObjToBeDeleted.Case__c; 
delete OutageObjToBeDeleted; 

String ActivatedURL = '/'+CaseId; 
System.debug('==>'+ ActivatedURL ); 
PageReference pageRef = new PageReference(ActivatedURL); 
pageRef.setRedirect(true); 
return pageRef; 
} 

public pageReference getDependencies(){ 

system.debug('VALUES PASSED '+outageObj.System_Lookup__c +' '+strLevel1System); 
invalidDates =false; 
DisplayError =false; 
if(outageObj.Start_Time__c > outageObj.End_Time__c) 
{ 
invalidDates = true; 
ApexPages.Message msg0 = new ApexPages.Message(ApexPages.Severity.WARNING,'Start Date cannot be greater than End Date.');
ApexPages.addmessage(msg0);
} 
if(outageObj.System_Lookup__c == null || strLevel1System == '' || outageObj.Type__c == null || strLevel1System == null) 
{
DisplayError = true; 
ApexPages.Message msg1 = new ApexPages.Message(ApexPages.Severity.WARNING,'Values are required for System, Sub System and Outage Type fields.');
ApexPages.addmessage(msg1); 
}
if(outageObj.System_Lookup__c != null && strLevel1System != null && outageObj.Type__c != null) 
{ 
try{ 
displayError = false; 
system.debug('before in getdependencies ' + outageObj.Type__c); 
requestDependency = true; 


displayedList.clear(); 
system.debug('level 1 systems '+outageObj.Subsystem_Lookup__c); 
outageObj.Subsystem_Lookup__c = strLevel1System.subString(0,15); 
L2systemList = [SELECT Id,Name,Parent__c FROM System_Master__c WHERE Parent__c =: outageObj.SubSystem_Lookup__c AND level__c = 'Level - 2' and inactive__c = false order by Name limit 500 ]; 
L3systemList = [SELECT Id,Name,Parent__c FROM System_Master__c WHERE level__c = 'Level - 3' and inactive__c = false order by Name limit 200 ]; 
system.debug('LIST SIZE '+L2systemList.size()); 

if(!L2systemList.isEmpty()) 
{ 
system.debug('ENTERED IF '+L2systemList); 
Integer counter =0; 
String outageID = Apexpages.currentPage().getParameters().get('Id'); 
noDependencies = false; 
 
List<System_Outage_Line__c> tempLineObj = new List<System_Outage_Line__c>(); 
for(integer i=0; i<L2systemList.size(); i++ ) 
{ 
system.debug('inside for loop' ); 

if(isUpdate != true) 
displayedList.add(new System_Outage_Line__c(System_Master__c =L2systemList[i].Id,Outage_Type__c=getDefaultOutageType(L2systemList[i].Id,outageObj.Type__c),Level__c = 'Level - 2')); 

else 
{ 
displayedList.add(new System_Outage_Line__c(System_Master__c =L2systemList[i].Id,Outage_Type__c=getLineOutageType(outageID, L2systemList[i].Id,outageObj.Type__c),Level__c = 'Level - 2')); 

} 
if(!L3systemList.isEmpty()) 
{ 
for(integer j=0; j<L3systemList.size(); j++ ) 
{ 
if(L3systemList[j].Parent__c == L2systemList[i].Id) 
{ 
system.debug('Dependency method for loop---2---'); 

if(isUpdate != true) 
displayedList.add(new System_Outage_Line__c(System_Master__c =L3systemList[j].Id,Outage_Type__c=getDefaultOutageType(L3systemList[j].Id,outageObj.Type__c),Level__c = 'Level - 3')); 
else 
displayedList.add(new System_Outage_Line__c(System_Master__c =L3systemList[j].Id,Outage_Type__c=getLineOutageType(outageID, L3systemList[j].Id,outageObj.Type__c),Level__c = 'Level - 3')); 
} 
} 
} 
} 
} 


if(displayedList.size() < 1) 
{ 
system.debug('DISPLAYED LIST FINAL'+displayedList.size()); 
noDependencies = true; 
requestDependency = true; 
} 

getDefaultTypes(); 
system.debug('before getdependencies method ends ' + requestDependency); 
} 
catch(Exception e){ 
System.debug('ERROR IN DEPENDENCY :'+e); 
} 
calledFromDependacies='N'; 
return null; 
} 
else 
{ 
return null; 
} 
} 

public pageReference getDefaultTypes(){ 
System.debug('getDefaultTypes '+L2systemList); 
if(!L2systemList.isEmpty()) 
{ 
for(Integer i=0; i<L2systemList.size(); i++) 
mappingList = [Select o.System__c, o.Default_Outage_Type__c From Outage_Type_Mapping__c o where o.System__c IN :L2systemList limit 1000]; 
} 
System.debug('getDefaultTypes End'); 

return null; 
} 

public pageReference saveRecords() 
{ 
system.debug('DATES PASSED '+outageObj.Start_Time__c +' '+outageObj.End_Time__c); 

if(outageObj.Start_Time__c > outageObj.End_Time__c) 
{ 
invalidDates = true; 
ApexPages.Message msg0 = new ApexPages.Message(ApexPages.Severity.WARNING,'Start Date cannot be greater than End Date.');
ApexPages.addmessage(msg0);
return null; 
} 

if(outageObj.System_Lookup__c != null && strLevel1System != '' && strLevel1System != null && outageObj.Type__c != null) 
{ 
if(outageObj.Start_Time__c != null) 
{ 
Id tempId = saveHeader(); 
system.debug('REDIRECTING1'+tempId); 
if(isError == true)
{
ApexPages.Message msg1 = new ApexPages.Message(ApexPages.Severity.WARNING,'Event Summary and Root Cause,Customer Impact, High-Level Timeline must be filled in for the Case. Please enter the values in the above mentioned fields on Case.');
ApexPages.addmessage(msg1);
return null;
}
String ActivatedURL = '/apex/DisplaySystemOutage'+'?Id='+tempId; 
System.debug('==>'+ ActivatedURL ); 
PageReference pageRef = new PageReference(ActivatedURL); 
pageRef.setRedirect(true); 
return pageRef; 
} 

else 
{ 
displayDateError = true; 
ApexPages.Message msg1 = new ApexPages.Message(ApexPages.Severity.WARNING,'Value required for Start Date field.');
ApexPages.addmessage(msg1);

return null; 
} 
} 

else 
{ 
displayError = true;
ApexPages.Message msg1 = new ApexPages.Message(ApexPages.Severity.WARNING,'Values are required for System, Sub System and Outage Type fields.');
ApexPages.addmessage(msg1); 
return null; 
} 
} 

public ID saveHeader(){ 

System_Outage__c outageHeaderObj = new System_Outage__c(); 

if(isUpdate != true || clone == 'true') 
{ 
if(outageObj.System_Lookup__c != null) 
{ 
outageHeaderObj.System_Lookup__c = outageObj.System_Lookup__c; 
outageHeaderObj.System__c = [select Name From System_Master__c where Id =:outageObj.System_Lookup__c].Name; 
system.debug('WHY THE EXCEPTION? '+strLevel1System); 
} 
if(strLevel1System != '' ||strLevel1System != null) 
{ 
//outageHeaderObj.Subsystem_Lookup__c =strLevel1System; 
List<System_Master__c> l1SysForLookUp = [select Id, Name From System_Master__c where Id =:strLevel1System limit 1]; 
outageHeaderObj.Subsystem_Lookup__c = l1SysForLookUp[0].Id; 
outageHeaderObj.SubSystems__c = l1SysForLookUp[0].Name; 
} 
else outageHeaderObj.Subsystem_Lookup__c = ''; 
outageHeaderObj.Start_Time__c =outageObj.Start_Time__c; 
outageHeaderObj.End_Time__c = outageObj.End_Time__c; 
outageHeaderObj.Type__c = outageObj.Type__c; 
outageHeaderObj.Case__c = parentCase.Id; 
try{ 
insert outageHeaderObj; 
isError = false;
} 

catch(Exception e) 
{ 
system.debug('INSERTION EXCEPTION ********'+e); 

isError = true;

} 
} 

else 
{ 
system.debug('inside else');
String outageID = Apexpages.currentPage().getParameters().get('Id'); 
outageHeaderObj = [Select s.Type__c, s.System_Lookup__c, s.Subsystem_Lookup__c, s.Start_Time__c, s.Id, s.End_Time__c,Calculated_Downtime_Calc__c, s.Case__c From System_Outage__c s Where s.Id =:outageID limit 1]; 
if(outageObj.System_Lookup__c != null) 
{ 
outageHeaderObj.System_Lookup__c = outageObj.System_Lookup__c; 
outageHeaderObj.System__c = [select Name From System_Master__c where Id =:outageObj.System_Lookup__c].Name; 
system.debug('WHY THE EXCEPTION IN UPDATE? '+strLevel1System +'TYPE '+outageType); 
} 
system.debug('id found:'+strLevel1System);

if(strLevel1System != '' ) 
{ 
//outageHeaderObj.Subsystem_Lookup__c =strLevel1System; 
system.debug('till here no exception:');
List<System_Master__c> l1SysForLookUp = [select Id, Name From System_Master__c where Id =:strLevel1System limit 1]; 
system.debug('exception caused');
outageHeaderObj.Subsystem_Lookup__c = l1SysForLookUp[0].Id; 
outageHeaderObj.SubSystems__c = l1SysForLookUp[0].Name; 
} 
else outageHeaderObj.Subsystem_Lookup__c = null; 
outageHeaderObj.Start_Time__c =outageObj.Start_Time__c; 
outageHeaderObj.End_Time__c = outageObj.End_Time__c; 
outageHeaderObj.Type__c = outageObj.Type__c; 
try
{
update outageHeaderObj; 
isError = false;
}
catch(Exception e)
{
system.debug('Exception while update operation:'+e);
isError = true;
}
//System_Outage_Summary__c summaryObjToDelete = new System_Outage_Summary__c(); 
List<System_Outage_Summary__c> summaryObjToDelete = [Select ID From System_Outage_Summary__c Where System_Outage__c =:outageHeaderObj.Id]; 
system.debug('To be deleted=> '+summaryObjToDelete); 

if(summaryObjToDelete != null) 
delete summaryObjToDelete; 

} 

if(outageHeaderObj.End_Time__c != null) 
{ 
System_Outage_Summary__c summaryObj = new System_Outage_Summary__c(); 
summaryObj.System_Outage__c = outageHeaderObj.Id; 
summaryObj.Start_Time__c = outageHeaderObj.Start_Time__c; 
summaryObj.End_Time__c = outageHeaderObj.End_Time__c; 
summaryObj.System__c = outageHeaderObj.Subsystem_Lookup__c; 
summaryObj.Outage_Type__c = outageHeaderObj.Type__c; 
insert summaryObj; 
} 

saveDetail(outageHeaderObj.Id,outageHeaderObj.End_Time__c); 

return outageHeaderObj.Id; 

} 

public pageReference saveDetail(Id headerId, Datetime endTime){ 

if(isUpdate != true) 
{ 
for(integer i=0; i<displayedList.size(); i++) 
{ 
displayedList[i].System_Outage_Header__c = headerId; 
} 
} 

else 
{ 
list<System_Outage_Line__c> tempDisplayedList = [Select s.Id From System_Outage_Line__c s Where s.System_Outage_Header__c =:headerId]; 
system.debug('BEFORE DELETE '+tempDisplayedList); 
deleteSummary(tempDisplayedList); 
delete tempDisplayedList; 
system.debug('AFTER DELETE '+tempDisplayedList); 

for(integer i=0; i<displayedList.size(); i++) 
{ 
displayedList[i].System_Outage_Header__c = headerId; 
} 
} 

insert displayedList; 
system.debug('DISPLAYEDLIST IN DETAIL METHOD '+displayedList); 
//Datetime endTime = [select Id, End_Time__c From System_Outage__c Where Id =:headerId limit 1].End_Time__c; 
system.debug('END OF TIME '+endTime ); 
if(endTime != null) 
saveSummary(); 
return null; 
} 

public pageReference saveSummary() 
{ 

if(summaryList.size()>0) 
summaryList.clear(); 

for(integer i=0; i<displayedList.size(); i++) 
{ 
if(displayedList[i].Outage_Type__c != 'No Impact') 
{ 
System_Outage_Summary__c summaryObj = new System_Outage_Summary__c(); 
summaryObj.System_Outage_Line__c = displayedList[i].Id; 
summaryObj.System_Outage__c = displayedList[i].System_Outage_Header__c; 
summaryObj.Start_Time__c = outageObj.Start_Time__c; 
summaryObj.End_Time__c = outageObj.End_Time__c; 
summaryObj.System__c = displayedList[i].System_Master__c; 
summaryObj.Outage_Type__c = displayedList[i].Outage_Type__c; 

summaryList.add(summaryObj); 
} 
} 
system.debug('summaryList :'+summaryList); 
insert summaryList; 
return null; 
} 

public pageReference deleteSummary(List<System_Outage_Line__c> deleteDetailList) 
{ 

List<System_Outage_Summary__c> deleteSummaryList = new List<System_Outage_Summary__c>(); 
deleteSummaryList = [select id from System_Outage_Summary__c where System_Outage_Line__c IN:deleteDetailList limit 500]; 
system.debug('deleteSummaryList='+deleteSummaryList); 
if(deleteSummaryList.size()>0) 
delete deleteSummaryList; 
return null; 
} 

//Method to get default outage type for each subsystem in the dependency line 
// Arguments: subSystemId and headerOutageType 
// Returns default outage type for the subsystem and for the selected headerOutageType 
public String getDefaultOutageType(ID subSystemId, String headerOutageType) { 
system.debug('Shruti:'+'subSystemId:'+subSystemId+'headerOutageType:'+headerOutageType);
String defaultOutageType = ''; 
Integer recordCount = [Select count() from Outage_Type_Mapping__c where System__r.Id = :subSystemId AND Level0_Outage_Type__c =:headerOutageType]; 
// Mapping object has an entry for each subsystem with exceptional outage type 
if(recordCount > 0){ 
defaultOutageType = [Select o.Default_Outage_Type__c From Outage_Type_Mapping__c o where o.System__r.Id = :subSystemId limit 1].Default_Outage_Type__c; 
} 
else{ 
defaultOutageType = [Select o.Default_Outage_Type__c From Outage_Type_Mapping__c o where o.System__c = null AND Level0_Outage_Type__c = :headerOutageType limit 1].Default_Outage_Type__c; 
} 

return defaultOutageType; 
} 

public String getLineOutageType(ID outageId, ID subSystemId,String headerOutageType){ 

String lineOutageType = ''; 
try{ 
if(outageId != null && subSystemId != null && calledFromDependacies!='Y'){ 
lineOutageType = [Select s.Outage_Type__c From System_Outage_Line__c s Where s.System_Outage_Header__c =:outageId AND s.System_Master__c =:subSystemId limit 1].Outage_Type__c; 
} 
else{ 
lineOutageType = getDefaultOutageType(subSystemId, headerOutageType); 
} 
} 
catch(Exception e){ 
lineOutageType = getDefaultOutageType(subSystemId, headerOutageType); 
} 

return lineOutageType; 
} 


public pageReference editRecords() 
{ 
String outageID = Apexpages.currentPage().getParameters().get('Id'); 
String ActivatedURL = '/apex/SystemOutageDetails'+'?CF00N50000001caGA_lkid='+CaseInURL+'&Id='+outageID; 
System.debug('==>'+ ActivatedURL ); 
PageReference pageRef = new PageReference(ActivatedURL); 
pageRef.setRedirect(true); 
return pageRef; 

} 

public pageReference CloneObj(){ 


String outageID = Apexpages.currentPage().getParameters().get('Id'); 
System_Outage__c outageHeaderObj = new System_Outage__c(); 
System_Outage__c outageHeaderObjCloned = new System_Outage__c(); 
outageHeaderObj = [Select s.Type__c, s.System_Lookup__c, s.Subsystem_Lookup__c, s.Start_Time__c, s.Start_Time_GMT__c, s.End_Time__c, s.End_Time_GMT__c, s.Case__c, s.Calculated_Downtime__c, s.Calculated_Downtime_Calc__c From System_Outage__c s Where s.Id =:outageID limit 1]; 
outageHeaderObjCloned = outageHeaderObj.clone(); 
outageObj.Type__c = outageHeaderObj.Type__c; 
outageObj.Start_Time__c = outageHeaderObj.Start_Time__c; 
outageObj.System_Lookup__c = outageHeaderObj.System_Lookup__c; 
outageObj.End_Time__c = outageHeaderObj.End_Time__c; 
strLevel1System = outageHeaderObj.Subsystem_Lookup__c; 
//parentCase.Id = outageHeaderObj.Case__c; 
String ActivatedURL = '/apex/SystemOutageDetails'+'?CF00N50000001caGA_lkid='+outageHeaderObj.Case__c+'&Id='+outageID+'&clone=true'; 
System.debug('==>'+ ActivatedURL ); 
PageReference pageRef = new PageReference(ActivatedURL); 
pageRef.setRedirect(true); 
return pageRef; 

} 

//System Outage History Change
public void getInitialList(){

HistoryList=[Select s.Field,s.CreatedDate,s.CreatedBy.Name,s.OldValue,s.NewValue From System_Outage__History s where s.ParentId=:outageID and s.Field in ('Type__c','Start_Time__c','End_Time__c','SubSystems__c','System__c','created') order by s.CreatedDate desc limit 50];
Integer INDEXCOUNT=0;
LIMIT_CONSTANT=5;
String DATE_STRING;
List<Id> Idlist=new List<Id>();
for(Integer p=0;p<HistoryList.size();p++)
{
system.debug(HistoryList.get(p).Field+'<---->'+HistoryList.get(p).OldValue);
}
List<System_Master__c> syslist=new List<System_Master__c>();
syslist=[Select s.Id from System_Master__c s limit 400];
List<Integer> indexlist=new List<Integer>();

for(Integer i=0;i<syslist.size();i++)
{
Idlist.add(syslist.get(i).Id);
}

for(Integer x=0;x<HistoryList.size();x++)
{
for(Integer y=0;y<Idlist.size();y++)
{
TEMP_ID=Idlist.get(y);
if( TEMP_ID.trim()==HistoryList.get(x).OldValue || TEMP_ID.trim()==HistoryList.get(x).NewValue )
{
indexlist.add(x);
break;
}
}
}

for(Integer p=0;p<indexlist.size();p++)
{
HistoryList.remove(indexlist.get(p)-INDEXCOUNT);
INDEXCOUNT=INDEXCOUNT+1;
}
TOTAL_COUNT=HistoryList.size();
for(Integer m=LIMIT_CONSTANT;m<TOTAL_COUNT;m++)
{
HistoryList.remove(LIMIT_CONSTANT);
}
LIST_SIZE=HistoryList.size();

if(TOTAL_COUNT>LIMIT_CONSTANT)
{
LIST_LINK=true;
}
}

public PageReference getMoreList(){
if(outageID!=null)
{
HistoryList=[Select s.Field,s.CreatedDate,s.CreatedBy.Name,s.OldValue,s.NewValue From System_Outage__History s where s.ParentId=:outageID and s.Field in ('Type__c','Start_Time__c','End_Time__c','SubSystems__c','System__c','created') order by s.CreatedDate desc limit 200];
Integer INDEXCOUNT=0;
LIMIT_CONSTANT=50;
List<Id> Idlist=new List<Id>();
List<System_Master__c> syslist=[Select Id from System_Master__c limit 400];
List<Integer> indexlist=new List<Integer>();

for(Integer i=0;i<syslist.size();i++)
{
Idlist.add(syslist.get(i).Id);
}

for(Integer x=0;x<HistoryList.size();x++)
{
for(Integer y=0;y<Idlist.size();y++)
{
TEMP_ID=Idlist.get(y);
if( TEMP_ID.trim()==HistoryList.get(x).OldValue || TEMP_ID.trim()==HistoryList.get(x).NewValue )
{
indexlist.add(x);
break;
}
}
}

for(Integer p=0;p<indexlist.size();p++)
{
HistoryList.remove(indexlist.get(p)-INDEXCOUNT);
INDEXCOUNT=INDEXCOUNT+1;
}
TOTAL_COUNT=HistoryList.size();
if(TOTAL_COUNT>LIMIT_CONSTANT)
{
for(Integer m=LIMIT_CONSTANT;m<TOTAL_COUNT;m++)
{
HistoryList.remove(LIMIT_CONSTANT);
}
}
LIST_SIZE=HistoryList.size();
LIST_LINK=false;
}
return null;
}

}