Global class OutageContactToolController {
//============================================================================
//====================== CONSTANTS ===========================================
//============================================================================
public static final String HARDWARE_VALUE = 'Hardware/Systems';
public static final String PORTAL_AND_SERVICES_VALUE = 'Portal/Services/Systems';
public static final String CONTACT_NOTIFICATION;
public static final String USER_SELECTION_ACCT_NAME = 'User Selections';
public static final String DELIM = ';';
//Constants for NMC system Page and Custom Search page
public static final String NMC_SYSTEM_VALUE = 'System Only';
public static final String CUSTOM_SEARCH = 'Custom Search';
public static final String NMC_ACCOUNT = 'NMC Account #';
public static final String CUST_ID = 'Cust ID';
public static final String AUX_ID = 'Aux ID';
public static final String COMPANY_ID = 'Company ID';
//============================================================================
//====================== SESSION VARIABLES ===================================
//============================================================================
public Campaign Newcampaign =new Campaign();
public String notification_topic;
public String[] selected_nmc_system = new List<String>();
public String portalservice = ApexPages.currentPage().getParameters().get('Portal');
public String selected_customSearch = NMC_ACCOUNT;
public String selected_Textarea;
public String selected_textString;
String[] selected_hardware = new List<String>();
String[] selected_portal_and_services = new List<String>();
String[] selected_contact_types = new List<String>();
String outageContactInfoName;
List<SelectOption> allNMCSystems;
List<SelectOption> allHardwareValues;
List<SelectOption> allConnectionTypes;
List<NMC_Account__c> selectALLNMC;
Map<String, String> districtToIgnoreMap = new Map<String, String>();
private String acctDistricts;
private Integer marketCounter = 0;
private Integer accountsFoundCounter = 0;
private Boolean accountProcessingComplete = true;
public Boolean portal ;
public String QueryParameter;
public String toggleValue;
//public String PortalService=ApexPages.currentPage().getParameters().get('Portal');
private String userMessage;

//============================================================================
//====================== CONSTRUCTOR =========================================
//============================================================================
public OutageContactToolController(){
notification_topic = HARDWARE_VALUE;
setDefaultSessionValues();
// Newcampaign =new Campaign();
//Gather the Report IDs from the Config Record
Outage_Contact_Tool_Config__c configRecord = [SELECT o.Name, o.Districts_to_Exclude__c
FROM Outage_Contact_Tool_Config__c o
LIMIT 1];
List<String> districtsToExcludeList = configRecord.Districts_to_Exclude__c.split(';');
for (String districtToIgnore : districtsToExcludeList){
districtToIgnoreMap.put(districtToIgnore,districtToIgnore);
}
//Gather the list of divisions from the Account object
Schema.DescribeFieldResult districtFieldResult = Account.District__c.getDescribe();
List<Schema.PicklistEntry> districtPickList = districtFieldResult.getPicklistValues();
for(Schema.PicklistEntry picklistEntry : districtPickList) {
if (!districtToIgnoreMap.containsKey(picklistEntry.getValue())){
if(acctDistricts == null || acctDistricts == ''){
acctDistricts = picklistEntry.getValue() + '~';
} else {
acctDistricts += picklistEntry.getValue() + '~';
}
}
}
//remove the last delimeter
acctDistricts = acctDistricts.substring(0,acctDistricts.length()-1);
}
//---------------------------------------------------------------------------
//---------------------- UTILITY Methods ------------------------------------
//---------------------------------------------------------------------------
public void debugSessionVariables(){
System.debug('OCT SESSION VARIABLE - notification_topic = ' + notification_topic);
System.debug('OCT SESSION VARIABLE - selected_hardware = ' + selected_hardware);
System.debug('OCT SESSION VARIABLE - selected_nmc_system = ' + selected_nmc_system);
System.debug('OCT SESSION VARIABLE - selected_portal_and_services = ' + selected_portal_and_services);
System.debug('OCT SESSION VARIABLE - selected_contact_types = ' + selected_contact_types);
}

//Generate a unique name for the contact outage records that will be included in the report
private void generateUniqueOCTName(){
outageContactInfoName = UserInfo.getUserName() + ' ' + System.now();
}

//generate a delimited string based on the List
private String genDelimStringFromList(List<String> listOfStrings){
String outputString;
for (String nextString : listOfStrings){
if(outputString == null || outputString == ''){
outputString = nextString + DELIM;
} else {
outputString += nextString + DELIM;
}
}
//no need to remove the extra DELIM because the String split works exactly as we would like with the trailing delim (doesn't create extra value)

return outputString;
}



//============================================================================
//================== To validate entered String for Custom Search ============
//============================================================================
webservice static String validateCustomSearchIds(String octUniqueId){
Outage_Contact_Info__c userSelectionContactInfoRecord = getOutageContactInfo(octUniqueId,USER_SELECTION_ACCT_NAME);
String userCustomSearchSelection = userSelectionContactInfoRecord.User_custom_search_selection__c;
String errorMessage = '';
if(userSelectionContactInfoRecord.User_custom_search_textarea__c !=null){
String[] userCustomSearchValues=userSelectionContactInfoRecord.User_custom_search_textarea__c.split(DELIM);
String singleQuotedCommaSeperatedValues = getSingleQuotedCommaSeperatedValue(userCustomSearchValues);
// singleQuotedCommaSeperatedValues.trim();

String commaSeperatedInValidIds = '';
if(userCustomSearchSelection == NMC_ACCOUNT){

List<NMC_Account__c> nmcAccountList = Database.query('SELECT NMC_Account__c FROM NMC_Account__c WHERE NMC_Account__c in ('+singleQuotedCommaSeperatedValues+')');

for(String userValue :userCustomSearchValues){
// check the user-entered value is in the valid list i.e., nmcAccountList
//If No, Append it to commaSeperatedInValidIds variable.
boolean found = false;
for(NMC_Account__c currentNMCAccount : nmcAccountList){
if(userValue.trim() == currentNMCAccount.NMC_Account__c){
found = true;
break;
}
}
if(!found){
commaSeperatedinValidIds += ((commaSeperatedinValidIds == '') ? userValue : ','+userValue);
}
}

if(commaSeperatedInValidIds != ''){
errorMessage = 'The following are the invalid NMC Accounts: '+commaSeperatedInValidIds;
}

}else if(userCustomSearchSelection == COMPANY_ID){

// Crappy case, oops company id is not a unique property of connection type.
// Inevitably iterate through the user list and hit the database to check for
// valid company ids :(
//Now spilt the singleQuotedCommaSeperatedValues string into an array.
String[] singleQuotedCompanyIds = singleQuotedCommaSeperatedValues.split(',');
for(String companyId :singleQuotedCompanyIds){
List<Connection_Type__c> nmcAccountList = DataBase.query('SELECT Company_ID__c FROM Connection_Type__c WHERE Company_ID__c = '+companyId+' limit 1');
if(nmcAccountList.isEmpty()){
commaSeperatedinValidIds += ((commaSeperatedinValidIds == '') ? companyId : ','+companyId);
}
}

if(commaSeperatedInValidIds != ''){
errorMessage = 'The following are the invalid Company Id\'s: '+commaSeperatedInValidIds;
}
}else if( userCustomSearchSelection == CUST_ID){
String[] singleQuotedCustIds = singleQuotedCommaSeperatedValues.split(',');
for(String custId :singleQuotedCustIds){
List<Account> accountList = DataBase.query('SELECT QWBS_Cust_ID__c FROM Account WHERE QWBS_Cust_ID__c = '+custId+' limit 1');
if(accountList.isEmpty()){
commaSeperatedinValidIds += ((commaSeperatedinValidIds == '') ? custId : ','+custId);
}
}
if(commaSeperatedInValidIds != ''){
errorMessage = 'The following are the invalid Cust Id\'s: '+commaSeperatedInValidIds;
}

}else if(userCustomSearchSelection== AUX_ID){
List<NMC_Account__c> nmcAccountList = DataBase.query('SELECT NMC_Aux_ID__c FROM NMC_Account__c WHERE NMC_Aux_ID__c in ('+singleQuotedCommaSeperatedValues+')');
for(String userValue :userCustomSearchValues){
// check the user-entered value is in the valid list i.e., nmcAccountList
//If No, Append it to commaSeperatedInValidIds variable.
boolean found = false;
for(NMC_Account__c currentNMCAccount : nmcAccountList){
if(userValue.trim() == currentNMCAccount.NMC_Aux_ID__c){
found = true;
break;
}
}
if(!found){
commaSeperatedinValidIds += ((commaSeperatedinValidIds == '') ? userValue : ','+userValue);
}
}
if(commaSeperatedInValidIds != ''){
errorMessage = 'The following are the invalid NMC Aux Id\'s: '+commaSeperatedInValidIds;
}
}else if(userCustomSearchSelection == COMPANY_ID){
// Crappy case, oops company id is not a unique property of connection type.
// Inevitably iterate through the user list and hit the database to check for
// valid company ids :(
//Now spilt the singleQuotedCommaSeperatedValues string into an array.
String[] singleQuotedCompanyIds = singleQuotedCommaSeperatedValues.split(',');
for(String companyId :singleQuotedCompanyIds){

List<Connection_Type__c> nmcAccountList = DataBase.query('SELECT Company_ID__c FROM Connection_Type__c WHERE Company_ID__c = '+companyId+' limit 1');
if(nmcAccountList.isEmpty()){
commaSeperatedinValidIds += ((commaSeperatedinValidIds == '') ? companyId : ','+companyId);
}
}

if(commaSeperatedInValidIds != ''){
errorMessage = 'The following are the invalid Company Id\'s: '+commaSeperatedInValidIds;
}
}
}
return errorMessage;
}


// This method will retrieve the Outage Contact Info for the given name and account Name.
// PARAMS:
// octUniqueId = the unique identifier for this report; this will be used to find user-selected values that we have stored in the db
// accountName = Apparently this value is always USER_SELECTION_ACCT_NAME
private static Outage_Contact_Info__c getOutageContactInfo(String name, String accountName){
return [SELECT Report_Type__c, User_Hardware_or_Services_Selections__c,
User_Contact_Type_Selections__c,NMC_System__c,
User_custom_search_selection__c,
User_custom_search_textarea__c
FROM Outage_Contact_Info__c
WHERE Name = :name AND Account_Name__c = :accountName limit 1];

}

//This method will retrieve the affected accounts along with the serialized unit
// or connection type information. Populate Map<ID, Outage_Contact_Info__c> acctOutageContactInfoMap with these values;
// PARAMS:
// octUniqueId = the unique identifier for this report; this will be used to find user-selected values that we have stored in the db
// districtToProcess = the district that we are processing in this batch
webservice static Integer retrieveAffectedAccountInfo(String octUniqueId, String districtToProcess,String PortalService){
String reportType;
String LastAutoNumber;
// String PortalService=ApexPages.currentPage().getParameters().get('Portal');
String[] userHardwareSelections = new List<String>();
String[] userContactTypeSelections = new List<String>();
String[] userPortalServicesSelections = new List<String>();
String[] userNMCSystemSelections = new List<String>();
String[] userCustomSearchValues =new List<String>();
String userCustomSearchSelection;
Set<string> accountSelections = new Set<string>();
List<string> accountSelections11 = new List<string>();
//Create Map of unique Account ID = Outage_Contact_Info_Record;
// reset for each batch to avoid governor limits; each batch should return unique Accounts, so there shouldn't be a need to
// consolidate information newly found accounts with accounts already processed
Map<ID, Outage_Contact_Info__c> acctOutageContactInfoMap = new Map<ID, Outage_Contact_Info__c>();
Outage_Contact_Info__c userSelectionContactInfoRecord = getOutageContactInfo(octUniqueId,USER_SELECTION_ACCT_NAME);
//Setting local variable from the outage contact info object.
reportType = userSelectionContactInfoRecord.Report_Type__c;
userCustomSearchSelection=userSelectionContactInfoRecord.User_custom_search_selection__c;
if(userSelectionContactInfoRecord.User_custom_search_textarea__c !=null){
userCustomSearchValues=userSelectionContactInfoRecord.User_custom_search_textarea__c.split(DELIM);
}
if(userSelectionContactInfoRecord.User_Hardware_or_Services_Selections__c!= null){
userHardwareSelections = userSelectionContactInfoRecord.User_Hardware_or_Services_Selections__c.split(DELIM);
System.debug('userHardwareSelections++++++++++++'+userHardwareSelections);
userPortalServicesSelections = userSelectionContactInfoRecord.User_Hardware_or_Services_Selections__c.split(DELIM);
}
//**************NMC Account queried for NMC system selected by User************************//
if(userSelectionContactInfoRecord.NMC_System__c != null ){
userNMCSystemSelections = userSelectionContactInfoRecord.NMC_System__c.split(DELIM);

}
if(userSelectionContactInfoRecord.User_Contact_Type_Selections__c != null){
userContactTypeSelections = userSelectionContactInfoRecord.User_Contact_Type_Selections__c.split(DELIM);
}
if(reportType == HARDWARE_VALUE && userContactTypeSelections != null && PortalService =='1'){
if(userSelectionContactInfoRecord.NMC_System__c != null){
System.debug('NMC System++++++++++++');
String lastAccountNumber = '0';
while(true){
accountSelections.clear();
for(NMC_Account__c accountInNMC :[Select n.Account__c,n.Auto_Number__c From NMC_Account__c n
WHERE n.NMC_System__c in:userNMCSystemSelections and Auto_Number__c > :LastAutoNumber
AND n.Account__r.District__c = :districtToProcess
and n.Account__r.QWBS_Status__c != 'Bankrupt'
AND n.Account__r.QWBS_Status__c != 'Out of Business'
AND n.Account__r.QWBS_Status__c != 'Inactive'
AND n.Account__r.QWBS_Status__c != 'Closed Bundled Customer'
AND n.Account__r.QWBS_Status__c != 'Closed Contract Customer'
AND n.Account__r.QWBS_Status__c != 'Closed MNS Customer'
AND n.Account__r.QWBS_Cust_ID__c != null
order by Auto_Number__c limit 1000]){
accountSelections.add(accountInNMC.Account__c);
lastAutoNumber = accountInNMC.Auto_Number__c;
}
if(accountSelections.size() == 0){
break;
}

for (List<Serialized_Unit_Summary__c> suSummaryList : [SELECT s.Number_of_Units__c, s.Item_Type__c,s.NMC_System__c, s.Account__r.QWBS_Status__c, s.Account__r.QWBS_Market__c, s.Account__c, s.Account__r.Name
FROM Serialized_Unit_Summary__c s
WHERE s.Account__c in:accountSelections
AND Item_Type__c in:userHardwareSelections]){
addSummaryInfoToAccountMap(octUniqueId, acctOutageContactInfoMap, suSummaryList);
}

}
}
else{
System.debug('NMC System not null++++++++++++');
for (List<Serialized_Unit_Summary__c> suSummaryList : [SELECT s.Number_of_Units__c, s.Item_Type__c,s.NMC_System__c, s.Account__r.QWBS_Status__c, s.Account__r.QWBS_Market__c, s.Account__c, s.Account__r.Name
FROM Serialized_Unit_Summary__c s
WHERE s.Account__r.District__c = :districtToProcess
AND s.Account__r.QWBS_Status__c != 'Bankrupt'
AND s.Account__r.QWBS_Status__c != 'Out of Business'
AND s.Account__r.QWBS_Status__c != 'Inactive'
AND s.Account__r.QWBS_Status__c != 'Closed Bundled Customer'
AND s.Account__r.QWBS_Status__c != 'Closed Contract Customer'
AND s.Account__r.QWBS_Status__c != 'Closed MNS Customer'
AND s.Account__r.QWBS_Cust_ID__c != null
AND Item_Type__c in:userHardwareSelections
]){

addSummaryInfoToAccountMap(octUniqueId, acctOutageContactInfoMap, suSummaryList);
}
}

} else if (reportType == PORTAL_AND_SERVICES_VALUE && userContactTypeSelections != null) {

if(userSelectionContactInfoRecord.NMC_System__c != null){
for (List<Connection_Type__c> connectionTypeList : [SELECT Name, Connection_Type__c, Id, NMC_Account__r.Account__c,NMC_Account__r.NMC_System__c ,NMC_Account__r.Account__r.Name,
NMC_Account__r.Account__r.QWBS_Market__c, NMC_Account__r.Account__r.QWBS_Status__c, NMC_Account__r.Account__r.QWBS_Cust_ID__c
FROM Connection_Type__c
WHERE NMC_Account__r.Account__r.District__c = :districtToProcess
AND NMC_Account__r.Account__r.QWBS_Status__c != 'Bankrupt'
AND NMC_Account__r.Account__r.QWBS_Status__c != 'Out of Business'
AND NMC_Account__r.Account__r.QWBS_Status__c != 'Inactive'
AND NMC_Account__r.Account__r.QWBS_Status__c != 'Closed Bundled Customer'
AND NMC_Account__r.Account__r.QWBS_Status__c != 'Closed Contract Customer'
AND NMC_Account__r.Account__r.QWBS_Status__c != 'Closed MNS Customer'
AND NMC_Account__r.Account__r.QWBS_Cust_ID__c != null
AND (Connection_Status__c != 'Disconnected' OR Connection_Status__c!='Inactive')
AND (Connection_Type__c in:userPortalServicesSelections
AND NMC_Account__r.NMC_System__c in:userNMCSystemSelections)])
{
addSummaryInfoToAccountMap(octUniqueId, acctOutageContactInfoMap, connectionTypeList);
}
}
else{
for (List<Connection_Type__c> connectionTypeList : [SELECT Name, Connection_Type__c, Id, NMC_Account__r.Account__c,NMC_Account__r.NMC_System__c ,NMC_Account__r.Account__r.Name,
NMC_Account__r.Account__r.QWBS_Market__c, NMC_Account__r.Account__r.QWBS_Status__c, NMC_Account__r.Account__r.QWBS_Cust_ID__c
FROM Connection_Type__c
WHERE NMC_Account__r.Account__r.District__c = :districtToProcess
AND NMC_Account__r.Account__r.QWBS_Status__c != 'Bankrupt'
AND NMC_Account__r.Account__r.QWBS_Status__c != 'Out of Business'
AND NMC_Account__r.Account__r.QWBS_Status__c != 'Inactive'
AND NMC_Account__r.Account__r.QWBS_Status__c != 'Closed Bundled Customer'
AND NMC_Account__r.Account__r.QWBS_Status__c != 'Closed Contract Customer'
AND NMC_Account__r.Account__r.QWBS_Status__c != 'Closed MNS Customer'
AND NMC_Account__r.Account__r.QWBS_Cust_ID__c != null AND
Connection_Type__c in:userPortalServicesSelections
])
{

addSummaryInfoToAccountMap(octUniqueId, acctOutageContactInfoMap, connectionTypeList);
}
}
}else if(reportType == NMC_SYSTEM_VALUE && userContactTypeSelections != null && PortalService =='3'){

if(userSelectionContactInfoRecord.NMC_System__c != null){

//If they have a cust id & the status doesn't contain the word closed, bankrupt, out of business or inactive.

for (List<NMC_Account__c> nmcAccount : [SELECT Id, s.Account__c,s.NMC_System__c ,s.Account__r.Name,
s.Account__r.QWBS_Market__c,s.Account__r.QWBS_Status__c,
s.Account__r.QWBS_Cust_ID__c FROM NMC_Account__c s
WHERE s.Account__r.District__c = :districtToProcess
AND s.Account__r.QWBS_Status__c != 'Bankrupt'
AND s.Account__r.QWBS_Status__c != 'Out of Business'
AND s.Account__r.QWBS_Status__c != 'Inactive'
AND s.Account__r.QWBS_Status__c != 'Closed Bundled Customer'
AND s.Account__r.QWBS_Status__c != 'Closed Contract Customer'
AND s.Account__r.QWBS_Status__c != 'Closed MNS Customer'
AND s.Account__r.QWBS_Cust_ID__c != null
AND s.NMC_System__c in:userNMCSystemSelections
]){

addSummaryInfoToAccountMapForNMCSystem(octUniqueId, acctOutageContactInfoMap, nmcAccount);
}
}else{
for (List<NMC_Account__c> nmcAccount : [SELECT Id, s.Account__c,s.NMC_System__c ,s.Account__r.Name,
s.Account__r.QWBS_Market__c,s.Account__r.QWBS_Status__c,
s.Account__r.QWBS_Cust_ID__c FROM NMC_Account__c s
WHERE s.Account__r.District__c = :districtToProcess
AND s.Account__r.QWBS_Status__c != 'Bankrupt'
AND s.Account__r.QWBS_Status__c != 'Out of Business'
AND s.Account__r.QWBS_Status__c != 'Inactive'
AND s.Account__r.QWBS_Status__c != 'Closed Bundled Customer'
AND s.Account__r.QWBS_Status__c != 'Closed Contract Customer'
AND s.Account__r.QWBS_Status__c != 'Closed MNS Customer'
AND s.Account__r.QWBS_Cust_ID__c != null limit 200
]){

addSummaryInfoToAccountMapForNMCSystem(octUniqueId, acctOutageContactInfoMap, nmcAccount);
}
}

}
else if(reportType == CUSTOM_SEARCH && userContactTypeSelections != null && PortalService =='4'){

if(userCustomSearchSelection == NMC_ACCOUNT){


String query = 'SELECT Id, a.Account__c,a.Account__r.Name,a.Account__r.QWBS_Market__c,';
query += 'a.Account__r.QWBS_Status__c,a.Account__r.QWBS_Cust_ID__c,a.NMC_Account__c FROM NMC_Account__c a ' ;
query += 'WHERE a.Account__r.District__c = \'';
query += districtToProcess;
query += '\'';
query +=' AND a.Account__r.QWBS_Status__c != \'Bankrupt\'';
query +=' AND a.Account__r.QWBS_Status__c != \'Out of Business\'';
query +=' AND a.Account__r.QWBS_Status__c != \'Inactive\'';
query +=' AND a.Account__r.QWBS_Status__c != \'Closed Bundled Customer\'';
query +=' AND a.Account__r.QWBS_Status__c != \'Closed Contract Customer\'';
query +=' AND a.Account__r.QWBS_Status__c != \'Closed MNS Customer\'';
query +=' AND a.Account__r.QWBS_Cust_ID__c != null';
if(userCustomSearchValues != null && userCustomSearchValues.size() > 0){
String nmcAccounts = getSingleQuotedCommaSeperatedValue(userCustomSearchValues);
query += ' AND a.NMC_Account__c in ('+nmcAccounts+')';
}

for (List<NMC_Account__c> nmcAccount : Database.query(query)){
addSummaryInfoToAccountMapForNMCAccount(octUniqueId, acctOutageContactInfoMap, nmcAccount);
}

}
else if(userCustomSearchSelection == CUST_ID){


String query = 'Select a.Id,a.Name,a.QWBS_Status__c, a.QWBS_Market__c,';
query += 'a.QWBS_Cust_ID__c From Account a ' ;
query += 'WHERE a.District__c = \'';
query += districtToProcess;
query += '\'';
query +=' AND a.QWBS_Status__c != \'Bankrupt\'';
query +=' AND a.QWBS_Status__c != \'Out of Business\'';
query +=' AND a.QWBS_Status__c != \'Inactive\'';
query +=' AND a.QWBS_Status__c != \'Closed Bundled Customer\'';
query +=' AND a.QWBS_Status__c != \'Closed Contract Customer\'';
query +=' AND a.QWBS_Status__c != \'Closed MNS Customer\'';
query +=' AND a.QWBS_Cust_ID__c != null';

if(userCustomSearchValues != null && userCustomSearchValues.size() > 0){
String customerIds = getSingleQuotedCommaSeperatedValue(userCustomSearchValues);
query += ' AND a.QWBS_Cust_ID__c in ('+customerIds+')';
}



for (List<Account> accountList :Database.query(query)){
System.debug('+++++++++++++++++++ Sending the following parameters to addSummaryInfoToAccountMap method +++++++++++');
addSummaryInfoToAccountMap(octUniqueId, acctOutageContactInfoMap, accountList);
}
}
else if(userCustomSearchSelection == AUX_ID){

String query = 'SELECT Id, a.Account__c,a.Account__r.Name,a.Account__r.QWBS_Market__c,';
query += 'a.Account__r.QWBS_Status__c,a.Account__r.QWBS_Cust_ID__c,a.NMC_Aux_ID__c FROM NMC_Account__c a ' ;
query += 'WHERE a.Account__r.District__c = \'';
query += districtToProcess;
query += '\'';
query +=' AND a.Account__r.QWBS_Status__c != \'Bankrupt\'';
query +=' AND a.Account__r.QWBS_Status__c != \'Out of Business\'';
query +=' AND a.Account__r.QWBS_Status__c != \'Inactive\'';
query +=' AND a.Account__r.QWBS_Status__c != \'Closed Bundled Customer\'';
query +=' AND a.Account__r.QWBS_Status__c != \'Closed Contract Customer\'';
query +=' AND a.Account__r.QWBS_Status__c != \'Closed MNS Customer\'';
query +=' AND a.Account__r.QWBS_Cust_ID__c != null';

if(userCustomSearchValues != null && userCustomSearchValues.size() > 0){
String nmcAuxIds = getSingleQuotedCommaSeperatedValue(userCustomSearchValues);
query += ' AND a.NMC_Aux_ID__c in ('+nmcAuxIds+')';
}


for (List<NMC_Account__c> nmcAccountAuxId : Database.query(query)){
addSummaryInfoToAccountMapForAuxId(octUniqueId, acctOutageContactInfoMap, nmcAccountAuxId);
}
}

else if(userCustomSearchSelection == COMPANY_ID){


String query = 'SELECT a.Name, a.Connection_Type__c,a.Id,a.Company_ID__c,a.NMC_Account__r.Account__c,';
query += 'a.NMC_Account__r.Account__r.Name,a.NMC_Account__r.Account__r.QWBS_Market__c,NMC_Account__r.Account__r.QWBS_Status__c,';
query += 'a.NMC_Account__r.Account__r.QWBS_Cust_ID__c FROM Connection_Type__c a' ;
query += ' WHERE a.NMC_Account__r.Account__r.District__c = \'';
query += districtToProcess;
query += '\'';
query +=' AND a.NMC_Account__r.Account__r.QWBS_Status__c != \'Bankrupt\'';
query +=' AND a.NMC_Account__r.Account__r.QWBS_Status__c != \'Out of Business\'';
query +=' AND a.NMC_Account__r.Account__r.QWBS_Status__c != \'Inactive\'';
query +=' AND a.NMC_Account__r.Account__r.QWBS_Status__c != \'Closed Bundled Customer\'';
query +=' AND a.NMC_Account__r.Account__r.QWBS_Status__c != \'Closed Contract Customer\'';
query +=' AND a.NMC_Account__r.Account__r.QWBS_Status__c != \'Closed MNS Customer\'';
query +=' AND a.NMC_Account__r.Account__r.QWBS_Cust_ID__c != null';
if(userCustomSearchValues != null && userCustomSearchValues.size() > 0){
String companyIds = getSingleQuotedCommaSeperatedValue(userCustomSearchValues);
query += ' AND a.Company_ID__c in ('+companyIds+')';
}



for (List<Connection_Type__c> connectionListCompanyId :Database.query(query)){

addSummaryInfoToAccountMapforCompanyId(octUniqueId, acctOutageContactInfoMap, connectionListCompanyId);
}
}
}

insertOutageContactRecords(userContactTypeSelections, acctOutageContactInfoMap);

return acctOutageContactInfoMap.size();
}

private static String getSingleQuotedCommaSeperatedValue(String[] listOfValues){
String result = '';

for(Integer i =0; i< listOfValues.size();i++){
result += '\''+listOfValues.get(i).trim()+'\'';
if(i < listOfValues.size() - 1){
result += ',';
}
}

return result;


}

//============================================================================
//==================== PAGE ACTIONS ==========================================
//============================================================================
private void setDefaultSessionValues(){
//clear session variables
notification_topic = HARDWARE_VALUE;
selected_hardware = new List<String>();
selected_portal_and_services = new List<String>();
selected_contact_types = new List<String>();
}

public PageReference cancelRequest() {

setDefaultSessionValues();
//return to the 1st page
return Page.OCT_Notification_Topic;
}

//====Method to redirect to different VF pages depending on notification topic passed


public PageReference submitNotificationTopicPage() {
if(notification_topic == HARDWARE_VALUE){
Newcampaign.clear();
retrieveHardwarePicklistValues();
retrieveNMCSystemValues();
toggleValue='1';
return redirectToHardwarePage();
}else if (notification_topic == PORTAL_AND_SERVICES_VALUE){
Newcampaign.clear();
retrieveConnectionTypePicklistValues();
retrieveNMCSystemValues();
toggleValue='2';
return redirectToServicesPortalPage();
}else if (notification_topic == NMC_SYSTEM_VALUE){
Newcampaign.clear();
retrieveNMCSystemValues();
toggleValue='3';
return redirectToNMCPage();
}else if(notification_topic == CUSTOM_SEARCH){
Newcampaign.clear();
toggleValue='4';
return redirectToCustomPage();
}else if(notification_topic == CONTACT_NOTIFICATION){


if(Newcampaign.Generate_Campaign__c == true && Newcampaign.Id ==null)
{
insert Newcampaign ;

}
else if(Newcampaign.Generate_Campaign__c == true && Newcampaign.Id !=null)
{
update Newcampaign;
}
getContactTypes();
return redirectToContactNotificationPage();
}else {
return redirectToNotificationTopicPage();
}
}

// ====================== Click on Finish in Contact Notification Page call this method===========
public PageReference submitHardwarePortalAndServicesPage() {
String PortalService=ApexPages.currentPage().getParameters().get('Portal');

if(PortalService =='1')
{
debugSessionVariables();
String userSelectedHardware = genDelimStringFromList(selected_hardware);
String userSelectedNMCSystem = genDelimStringFromList(selected_nmc_system);

String userSelectedContactTypes = genDelimStringFromList(selected_contact_types);
Outage_Contact_Info__c accountOutageContactInfo = new Outage_Contact_Info__c();
accountOutageContactInfo.Name = outageContactInfoName;
accountOutageContactInfo.Account_Name__c = USER_SELECTION_ACCT_NAME;
accountOutageContactInfo.User_Hardware_or_Services_Selections__c = userSelectedHardware;
accountOutageContactInfo.NMC_System__c = userSelectedNMCSystem;
accountOutageContactInfo.User_Contact_Type_Selections__c = userSelectedContactTypes;
accountOutageContactInfo.Report_Type__c = HARDWARE_VALUE;
insert accountOutageContactInfo;
return null;
}

// ====================== PORTAL/SERVICES =========================================
else if(PortalService =='2'){
//Retrieve the user selections and store them in a record in the Outage_Contact_Info__c object; then return null for the JavaScript Account Batch processing
debugSessionVariables();
String userSelectedServices = genDelimStringFromList(selected_portal_and_services);
String userSelectedNMCSystem = genDelimStringFromList(selected_nmc_system);
String userSelectedContactTypes = genDelimStringFromList(selected_contact_types);
Outage_Contact_Info__c accountOutageContactInfo = new Outage_Contact_Info__c();
accountOutageContactInfo.Name = outageContactInfoName;
accountOutageContactInfo.Account_Name__c = USER_SELECTION_ACCT_NAME;
accountOutageContactInfo.User_Hardware_or_Services_Selections__c = userSelectedServices;
accountOutageContactInfo.NMC_System__c = userSelectedNMCSystem;
accountOutageContactInfo.User_Contact_Type_Selections__c = userSelectedContactTypes;
accountOutageContactInfo.Report_Type__c = PORTAL_AND_SERVICES_VALUE;
insert accountOutageContactInfo;
return null;
}
else if(PortalService =='3'){

debugSessionVariables();
String userSelectedHardware = genDelimStringFromList(selected_nmc_system);
String userSelectedNMCSystem = genDelimStringFromList(selected_nmc_system);
String userSelectedContactTypes = genDelimStringFromList(selected_contact_types);
Outage_Contact_Info__c accountOutageContactInfo = new Outage_Contact_Info__c();
accountOutageContactInfo.Name = outageContactInfoName;
accountOutageContactInfo.Account_Name__c = USER_SELECTION_ACCT_NAME;
accountOutageContactInfo.User_Hardware_or_Services_Selections__c = userSelectedHardware;
accountOutageContactInfo.NMC_System__c = userSelectedNMCSystem;
accountOutageContactInfo.User_Contact_Type_Selections__c = userSelectedContactTypes;
accountOutageContactInfo.Report_Type__c = NMC_SYSTEM_VALUE;
insert accountOutageContactInfo;
return null;
}
else{

debugSessionVariables();
if(selected_Textarea.contains(','))
{
selected_textString=selected_Textarea.replace(',',';');
}
else{
selected_textString=selected_Textarea.replace('\r',';');
}
String userSelectedSearch = selected_customSearch;
String userSelectedTextString = selected_textString;
String userSelectedContactTypes = genDelimStringFromList(selected_contact_types);
Outage_Contact_Info__c accountOutageContactInfo = new Outage_Contact_Info__c();
accountOutageContactInfo.Name = outageContactInfoName;
accountOutageContactInfo.Account_Name__c = USER_SELECTION_ACCT_NAME;
accountOutageContactInfo.User_custom_search_selection__c =userSelectedSearch;
accountOutageContactInfo.User_custom_search_textarea__c =selected_textString;
accountOutageContactInfo.User_Contact_Type_Selections__c = userSelectedContactTypes;
accountOutageContactInfo.Report_Type__c = CUSTOM_SEARCH;
insert accountOutageContactInfo;
return null;


}
}

//========================Campaign created for enhancement=================================

//-----------------------------------------------------------------------
//----- Webservices to retrieve report URLS -----------------------------
//-----------------------------------------------------------------------



webservice static String retrieveConnectionTypeReportURL(String octReportId ,String portalValue) {
String REPORT_URL_CONNECTIONTYPE;
String REPORT_URL_HARDWARE;
String REPORT_URL_NMCSYSTEM;
String REPORT_URL_CUSTOMSEARCH;
Outage_Contact_Tool_Config__c configRecord = [SELECT o.Name, o.Services_Portal_Report_Id__c, o.Hardware_Report_Id__c,
o.NMC_System_Report_Id__c,o.Custom_Report_Id__c
FROM Outage_Contact_Tool_Config__c o
LIMIT 1];
if(portalValue =='1'){
if(configRecord.Hardware_Report_Id__c != null) {
REPORT_URL_HARDWARE = '/' + configRecord.Hardware_Report_Id__c;
}
String reportURL = REPORT_URL_HARDWARE + '?pc1=CUST_NAME&pn1=eq&pv1=' + octReportId;
return reportURL;
}
else if(portalValue == '2'){
//Gather the Report IDs from the Config Record
if(configRecord.Services_Portal_Report_Id__c != null) {
REPORT_URL_CONNECTIONTYPE = '/' + configRecord.Services_Portal_Report_Id__c;
}
String reportURL = REPORT_URL_CONNECTIONTYPE + '?pc1=CUST_NAME&pn1=eq&pv1=' + octReportId;
return reportURL;
}
else if(portalValue =='3'){
if(configRecord.NMC_System_Report_Id__c != null) {
REPORT_URL_NMCSYSTEM= '/' + configRecord.NMC_System_Report_Id__c ;
}
String reportURL = REPORT_URL_NMCSYSTEM + '?pc1=CUST_NAME&pn1=eq&pv1=' + octReportId;
return reportURL;
}
else{
System.debug('configRecord.NMC_System_Report_Id__c'+configRecord.Custom_Report_Id__c);
if(configRecord.Custom_Report_Id__c != null) {
REPORT_URL_CUSTOMSEARCH= '/' + configRecord.Custom_Report_Id__c ;
}
String reportURL = REPORT_URL_CUSTOMSEARCH + '?pc1=CUST_NAME&pn1=eq&pv1=' + octReportId;
return reportURL;
}
}



//-----------------------------------------------------------------------
//----- Insert the Outage_Contact_Info__c records into the db ----------------
//-----------------------------------------------------------------------
public static void insertOutageContactRecords(String[] userContactTypes, Map<ID, Outage_Contact_Info__c> acctOutageContactInfoMap ) {

//Make sure all three SOQL bind variables are filled for multi-value to multi-value compare (due to limitation with SOQL includes)
//TODO - set the size of this array dynamically based on a Describe call; use dynamic SOQL once it is available (Winter 09?)
//2008_10_25 update: dynamic SOQL runs, but we get an error when trying to pull data off of the Contact: http://community.salesforce.com/sforce/board/message?board.id=apex&thread.id=8671

System.debug('Account Outage Contact Info Map :'+ acctOutageContactInfoMap.keySet());

String DUMMY_VALUE = 'xxx'; // to avoid match in SOQL
for (Integer i = userContactTypes.size(); i < 10; i++){
userContactTypes.add(DUMMY_VALUE);
}
//Find all of the contacts for the affected accounts and insert the Outage_Contact_Info records
for (List<Contact> accountContactList : [SELECT Id, AccountId, Notification_Type__c
FROM Contact
WHERE AccountId in:acctOutageContactInfoMap.keySet()
AND Inactive__c = false
AND Notification_Type__c includes (:userContactTypes[0], :userContactTypes[1], :userContactTypes[2], :userContactTypes[3],:userContactTypes[4],:userContactTypes[5],:userContactTypes[6],:userContactTypes[7],:userContactTypes[8],:userContactTypes[9])]){
List<Outage_Contact_Info__c> outageContactInfoListToInsert = new List<Outage_Contact_Info__c>();
for(Contact nextContact : accountContactList){
Outage_Contact_Info__c newOutageContactInfo = acctOutageContactInfoMap.get(nextContact.AccountId);
Outage_Contact_Info__c recordToInsert = newOutageContactInfo.clone();
recordToInsert.Contact__c = nextContact.Id;
outageContactInfoListToInsert.add(recordToInsert);
}

insert outageContactInfoListToInsert;
}
}



private static void appendItemType(Outage_Contact_Info__c existingOutageContactInfoRecord, Serialized_Unit_Summary__c newSerializedUnitSummaryRecord){
if (newSerializedUnitSummaryRecord.Item_Type__c == null){
return; //nothing to append
}

//only add Item_Type if doesn't already exist
//TODO: split string instead of using "contains()" so that the item type correctly matches existing item types
if( existingOutageContactInfoRecord.Item_Type__c == null){
existingOutageContactInfoRecord.Item_Type__c = newSerializedUnitSummaryRecord.Item_Type__c;
} else if (!existingOutageContactInfoRecord.Item_Type__c.contains(newSerializedUnitSummaryRecord.Item_Type__c)) {
existingOutageContactInfoRecord.Item_Type__c += ', ' + newSerializedUnitSummaryRecord.Item_Type__c;
}

}

//-----------------------------------------------------------------------
//----- Add the Account's Outage Contact Info to the Map ----------------
//-----------------------------------------------------------------------
private static void addSummaryInfoToAccountMap(String outageContactInfoName, Map<ID, Outage_Contact_Info__c> accountOutageMap, List<Serialized_Unit_Summary__c> serializedUnitSummaryList){
for(Serialized_Unit_Summary__c suSummaryRecord : serializedUnitSummaryList){
if(accountOutageMap.containsKey(suSummaryRecord.Account__c)){
//update Account's Outage_Contact_Info__c information in the Map
// we will concatenate NMC_System and Hardware Info so we can keep only 1 entry for each Account
Outage_Contact_Info__c accountOutageContactInfo = accountOutageMap.get(suSummaryRecord.Account__c);
appendItemType(accountOutageContactInfo, suSummaryRecord);
accountOutageContactInfo.Number_of_Units__c += suSummaryRecord.Number_of_Units__c;
} else {
Outage_Contact_Info__c accountOutageContactInfo = new Outage_Contact_Info__c();
accountOutageContactInfo.Name = outageContactInfoName;
accountOutageContactInfo.Account_Name__c = suSummaryRecord.Account__r.Name;
accountOutageContactInfo.Item_Type__c = suSummaryRecord.Item_Type__c;

accountOutageContactInfo.Number_of_Units__c = suSummaryRecord.Number_of_Units__c;
accountOutageMap.put(suSummaryRecord.Account__c,accountOutageContactInfo);

}
}
}
//update Account's Outage_Contact_Info__c information in the Map
// we will concatenate NMC_System and Hardware Info so we can keep only 1 entry for each Account
private static void addSummaryInfoToAccountMap(String outageContactInfoName, Map<ID, Outage_Contact_Info__c> accountOutageMap, List<Account> accountList){
for(Account accountRecord : accountList){
if(accountOutageMap.containsKey(accountRecord.Id)){
Outage_Contact_Info__c accountOutageContactInfo = accountOutageMap.get(accountRecord.QWBS_Cust_ID__c);
if ( (accountRecord.QWBS_Cust_ID__c!= null) && (!accountOutageContactInfo.Cust_Id__c.contains(accountRecord.QWBS_Cust_ID__c)) )
{
accountOutageContactInfo.Cust_Id__c+= ', ' + accountRecord.QWBS_Cust_ID__c;
}else{
accountOutageContactInfo.Cust_Id__c= accountRecord.QWBS_Cust_ID__c;
}
accountOutageContactInfo.Number_of_Units__c++;
}else {
Outage_Contact_Info__c accountOutageContactInfo = new Outage_Contact_Info__c();
accountOutageContactInfo.Name = outageContactInfoName;
accountOutageContactInfo.Account_Name__c = accountRecord.Name;
accountOutageContactInfo.Cust_Id__c = accountRecord.QWBS_Cust_ID__c;
accountOutageContactInfo.Number_of_Units__c = 1;
accountOutageMap.put(accountRecord.Id,accountOutageContactInfo);

}
}
}
//Accounts are for NMC system page 3-------------------------------------------
private static void addSummaryInfoToAccountMapForNMCAccount(String outageContactInfoName, Map<ID, Outage_Contact_Info__c> accountOutageMap, List<NMC_Account__c> nmcAccountList){
for(NMC_Account__c nmcAccountRecord : nmcAccountList){
if(accountOutageMap.containsKey(nmcAccountRecord.Account__c)){
//update Account's Outage_Contact_Info__c information in the Map
// we will concatenate NMC_System and Hardware Info so we can keep only 1 entry for each Account
Outage_Contact_Info__c accountOutageContactInfo = accountOutageMap.get(nmcAccountRecord.Account__c);

if ( (nmcAccountRecord.NMC_Account__c!= null) && (!accountOutageContactInfo.NMC_Account_del__c.contains(nmcAccountRecord.NMC_Account__c)) )
{
accountOutageContactInfo.NMC_Account_del__c += ', ' + nmcAccountRecord.NMC_Account__c;
}else{
accountOutageContactInfo.NMC_Account_del__c = nmcAccountRecord.NMC_Account__c;
}

accountOutageContactInfo.Number_of_Units__c++;
}
else {
Outage_Contact_Info__c accountOutageContactInfo = new Outage_Contact_Info__c();
accountOutageContactInfo.Name = outageContactInfoName;
accountOutageContactInfo.Account_Name__c = nmcAccountRecord.Account__r.Name;
accountOutageContactInfo.Number_of_Units__c = 1;
if(nmcAccountRecord.NMC_Account__c !=null){
accountOutageContactInfo.NMC_Account_del__c = nmcAccountRecord.NMC_Account__c;
}
accountOutageMap.put(nmcAccountRecord.Account__c,accountOutageContactInfo);
}
}
}


private static void addSummaryInfoToAccountMapForAuxId(String outageContactInfoName, Map<ID, Outage_Contact_Info__c> accountOutageMap, List<NMC_Account__c> nmcAccountList){
System.debug('Account List :'+nmcAccountList);
for(NMC_Account__c nmcAccountRecord : nmcAccountList){
if(accountOutageMap.containsKey(nmcAccountRecord.Account__c)){
//update Account's Outage_Contact_Info__c information in the Map
// we will concatenate NMC_System and Hardware Info so we can keep only 1 entry for each Account
Outage_Contact_Info__c accountOutageContactInfo = accountOutageMap.get(nmcAccountRecord.Account__c);
if ( nmcAccountRecord.NMC_Aux_ID__c!= null)
{
if(accountOutageContactInfo.Aux_Id__c == null){
accountOutageContactInfo.Aux_Id__c = nmcAccountRecord.NMC_Aux_ID__c;
}else if(!accountOutageContactInfo.Aux_Id__c.contains(nmcAccountRecord.NMC_Aux_ID__c)){
accountOutageContactInfo.Aux_Id__c += ', ' + nmcAccountRecord.NMC_Aux_ID__c;
}
}

accountOutageContactInfo.Number_of_Units__c++;
}
else {
Outage_Contact_Info__c accountOutageContactInfo = new Outage_Contact_Info__c();
accountOutageContactInfo.Name = outageContactInfoName;
accountOutageContactInfo.Account_Name__c = nmcAccountRecord.Account__r.Name;
accountOutageContactInfo.Number_of_Units__c = 1; //first connection type
accountOutageContactInfo.Aux_Id__c = nmcAccountRecord.NMC_Aux_ID__c;
accountOutageMap.put(nmcAccountRecord.Account__c,accountOutageContactInfo);
}
}
}

private static void addSummaryInfoToAccountMapForNMCSystem(String outageContactInfoName, Map<ID, Outage_Contact_Info__c> accountOutageMap, List<NMC_Account__c> nmcAccountList){
for(NMC_Account__c nmcAccountRecord : nmcAccountList){
if(accountOutageMap.containsKey(nmcAccountRecord.Account__c)){
//update Account's Outage_Contact_Info__c information in the Map
// we will concatenate NMC_System and Hardware Info so we can keep only 1 entry for each Account
Outage_Contact_Info__c accountOutageContactInfo = accountOutageMap.get(nmcAccountRecord.Account__c);
if ( nmcAccountRecord != null && nmcAccountRecord.NMC_System__c!= null
&& accountOutageContactInfo.NMC_System__c != null && (
!accountOutageContactInfo.NMC_System__c.contains(nmcAccountRecord.NMC_System__c)) )
{
accountOutageContactInfo.NMC_System__c += ', ' + nmcAccountRecord.NMC_System__c;
}else{
accountOutageContactInfo.NMC_System__c = nmcAccountRecord.NMC_System__c;
}
accountOutageContactInfo.Number_of_Units__c++;
}
else{
Outage_Contact_Info__c accountOutageContactInfo = new Outage_Contact_Info__c();
accountOutageContactInfo.Name = outageContactInfoName;
accountOutageContactInfo.Account_Name__c = nmcAccountRecord.Account__r.Name;
accountOutageContactInfo.Number_of_Units__c = 1; //first connection type
if(nmcAccountRecord.NMC_System__c !=null){
accountOutageContactInfo.NMC_System__c = nmcAccountRecord.NMC_System__c;
}
accountOutageMap.put(nmcAccountRecord.Account__c,accountOutageContactInfo);

}
}
}

private static void addSummaryInfoToAccountMap(String outageContactInfoName, Map<ID, Outage_Contact_Info__c> accountOutageMap, List<Connection_Type__c> connTypeList){
for(Connection_Type__c connType : connTypeList){
if(accountOutageMap.containsKey(connType.NMC_Account__r.Account__c))
{
Outage_Contact_Info__c accountOutageContactInfo = accountOutageMap.get(connType.NMC_Account__r.Account__c);
//only add connection type if doesn't already exist and isn't blank in connType
//TODO: split string instead of using "contains()"
if ( (connType.Connection_Type__c != null) && (!accountOutageContactInfo.Connection_Type__c.contains(connType.Connection_Type__c)) )
{
accountOutageContactInfo.Connection_Type__c += ', ' + connType.Connection_Type__c;
}
else
accountOutageContactInfo.Connection_Type__c = connType.Connection_Type__c;
accountOutageContactInfo.NMC_System__c = connType.NMC_Account__r.NMC_System__c;
accountOutageContactInfo.Number_of_Units__c++;
}else {
Outage_Contact_Info__c accountOutageContactInfo = new Outage_Contact_Info__c();
accountOutageContactInfo.Name = outageContactInfoName;
accountOutageContactInfo.Account_Name__c = connType.NMC_Account__r.Account__r.Name;
accountOutageContactInfo.Connection_Type__c = connType.Connection_Type__c;
accountOutageContactInfo.Number_of_Units__c = 1; //first connection type
accountOutageContactInfo.NMC_System__c = connType.NMC_Account__r.NMC_System__c;
accountOutageMap.put(connType.NMC_Account__r.Account__c,accountOutageContactInfo);

}
}
}

//update Account's Outage_Contact_Info__c information in the Map
// we will concatenate NMC_System and Portal Info so we can keep only 1 entry for each Account
//only add Company Id type if doesn't already exist and isn't blank in connTypeforComId
//TODO: split string instead of using "contains()"
private static void addSummaryInfoToAccountMapforCompanyId(String outageContactInfoName, Map<ID, Outage_Contact_Info__c> accountOutageMap, List<Connection_Type__c> connTypeList){
for(Connection_Type__c connTypeforComId : connTypeList){
if(accountOutageMap.containsKey(connTypeforComId.NMC_Account__r.Account__c))
{
Outage_Contact_Info__c accountOutageContactInfo = accountOutageMap.get(connTypeforComId.NMC_Account__r.Account__c);

if ( connTypeforComId.Company_ID__c != null)
{
if(accountOutageContactInfo.Company_Id__c == null){
accountOutageContactInfo.Company_Id__c = connTypeforComId.Company_Id__c;
}else if(!accountOutageContactInfo.Company_Id__c.contains(connTypeforComId.Company_Id__c)){
accountOutageContactInfo.Company_Id__c += ', ' + connTypeforComId.Company_Id__c;
}
}
else
accountOutageContactInfo.Company_Id__c = connTypeforComId.Company_Id__c;
accountOutageContactInfo.Number_of_Units__c++;
}else {
Outage_Contact_Info__c accountOutageContactInfo = new Outage_Contact_Info__c();
accountOutageContactInfo.Name = outageContactInfoName;
accountOutageContactInfo.Account_Name__c = connTypeforComId.NMC_Account__r.Account__r.Name;
accountOutageContactInfo.Company_ID__c = connTypeforComId.Company_ID__c;
accountOutageContactInfo.Number_of_Units__c = 1; //first connection type
accountOutageMap.put(connTypeforComId.NMC_Account__r.Account__c,accountOutageContactInfo);
}
}
}
//===============================================================
//=========== PAGE REDIRECTS ===================================
//===============================================================
public PageReference redirectToNotificationTopicPage() {
PageReference homePage = Page.OCT_Notification_Topic;
homePage.setRedirect(true);
return homePage;
}

public PageReference redirectToHardwarePage() {
if(outageContactInfoName == null || outageContactInfoName == '') { generateUniqueOCTName();}
selected_nmc_system.clear();
notification_topic = CONTACT_NOTIFICATION;
return Page.OCT_Hardware;
}
//The redirection to respective pages on click of cancel button
public PageReference redirectToRespectivePageOnCancel() {
if(outageContactInfoName == null || outageContactInfoName == '') { generateUniqueOCTName();}
String PortalService=ApexPages.currentPage().getParameters().get('Portal');
if(PortalService == '2'){
notification_topic = CONTACT_NOTIFICATION;
return Page.OCT_Services_Portal;
}
else if(PortalService == '1'){
notification_topic = CONTACT_NOTIFICATION;
return Page.OCT_Hardware;
}
else if(PortalService == '3'){
notification_topic = CONTACT_NOTIFICATION;
return Page.oct_nmcsystem;
}
else{
notification_topic = CONTACT_NOTIFICATION;
return Page.oct_customSearch;
}
}
public PageReference redirectToServicesPortalPage() {
if(outageContactInfoName == null || outageContactInfoName == '') { generateUniqueOCTName();}
selected_nmc_system.clear();
notification_topic = CONTACT_NOTIFICATION;
return Page.OCT_Services_Portal;
}

public PageReference redirectToNMCPage() {
if(outageContactInfoName == null || outageContactInfoName == '') { generateUniqueOCTName();}
selected_nmc_system.clear();
notification_topic = CONTACT_NOTIFICATION;
return Page.OCT_nmcsystem;
}
public PageReference redirectToCustomPage(){
if(outageContactInfoName == null || outageContactInfoName == '') { generateUniqueOCTName();}
notification_topic = CONTACT_NOTIFICATION;
return Page.OCT_customSearch;
}

//====================Divya------Contact Notification============================//
public PageReference redirectToContactNotificationPage() {
if(outageContactInfoName == null || outageContactInfoName == '') { generateUniqueOCTName();}
debugSessionVariables();
PageReference pageRef = new PageReference('/apex/oct_Contact_Notification?Portal='+toggleValue);
pageRef.setRedirect(false);
return pageRef;
}


//======================change ends==========================================//

//===============================================================
//=========== Getters/Setters ==================================
//===============================================================
public Boolean getAccountProcessingComplete(){
return accountProcessingComplete;
}
public String getUserMessage(){
return userMessage;
}

public String getAcctDistricts(){
return acctDistricts;
}

public String getOutageContactInfoName(){
return outageContactInfoName;
}
public String getPORTAL_AND_SERVICES_VALUE(){
return PORTAL_AND_SERVICES_VALUE;
}
public String getNMC_SYSTEM_VALUE(){
return NMC_SYSTEM_VALUE;
}

public String getCustom_SEARCH(){
return CUSTOM_SEARCH;
}
public String getHARDWARE_VALUE(){
return HARDWARE_VALUE;
}
public String getNMC_ACCOUNT(){
return NMC_ACCOUNT;
}
public String getCUST_ID(){
return CUST_ID;
}
public String getAUX_ID(){
return AUX_ID;
}
public String getCOMPANY_ID(){
return COMPANY_ID;
}
public String getQueryParameter(){
return ApexPages.currentPage().getParameters().get('Portal');
}
public void setQueryParameter(String parameter){
QueryParameter =parameter;
}

public String getCONTACT_NOTIFICATION(){
return CONTACT_NOTIFICATION;
}

//=================================change ends================================//

//============================================================================
//====================== PICKLISTS ===========================================
//============================================================================
public List<SelectOption> getNMCSystems() {
return allNMCSystems;
}
public void setNMCSystems(List<SelectOption> newOptions) {
allNMCSystems = newOptions;
}

public List<SelectOption> getHardwareItemTypes() {
return allHardwareValues;
}
public void setHardwareItemTypes(List<SelectOption> newOptions) {
allHardwareValues = newOptions;
}

public List<SelectOption> getConnectionTypes() {
return allConnectionTypes;
}
public void setConnectionTypes(List<SelectOption> newOptions) {
allConnectionTypes = newOptions;
}
public String getNotification_topic(){
return notification_topic;
}
public void setNotification_topic(String selectedValue){
notification_topic = selectedValue;
}


//For Campaign to have default picklist and checkbox values in the VF Page
public Campaign getNewCampaign(){
Newcampaign.Type ='Email';
Newcampaign.Status ='Planned';
Newcampaign.IsActive =true;
return Newcampaign;
}

public void setSelected_hardware(String[] hardwareSelections){
selected_hardware = hardwareSelections;
}
public String[] getSelected_hardware(){
return selected_hardware;
}
public void setSelected_nmc_system(String[] systemSelections){
selected_nmc_system = systemSelections;
}
public String[] getSelected_nmc_system(){
return selected_nmc_system;
}
public void setSelected_customSearch(String customSelections){
selected_customSearch = customSelections;
}
public String getSelected_customSearch(){
return selected_customSearch;
}
public void setSelected_portal_and_services(String[] portalSrvcSelections){
selected_portal_and_services = portalSrvcSelections;
}
public String[] getSelected_portal_and_services(){
return selected_portal_and_services;
}

public void setSelected_contact_types(String[] contactTypeSelections){
selected_contact_types = contactTypeSelections;
}
public String[] getSelected_contact_types(){
return selected_contact_types;
}
public String getSelected_Textarea(){
return selected_Textarea;
}
public void setSelected_Textarea(String textSelections){
selected_Textarea = textSelections;
}

//------------------End of Getters/Setters---------------------------------

//----- Retrieve Picklist Values for Contact Types ------------------------
public List<SelectOption> getContactTypes() {
//Dymanically pull the picklist for Contact Types
List<SelectOption> options = new List<SelectOption>();
Schema.DescribeFieldResult dFieldResult = Contact.Notification_Type__c.getDescribe();
List<Schema.PicklistEntry> listPickList = dFieldResult.getPicklistValues();
for(Schema.PicklistEntry picklistEntry : listPickList) {
options.add(new SelectOption(picklistEntry.getValue(),picklistEntry.getLabel()));
}
return options;
}
//----- Retrieve Picklist Values for Hardware ---------------------------
public void retrieveHardwarePicklistValues(){
List<SelectOption> hardwareOptions = new List<SelectOption>();
Schema.DescribeFieldResult dFieldResult = Serialized_Units__c.Item_Type__c.getDescribe();
List<Schema.PicklistEntry> listPickList = dFieldResult.getPicklistValues();
for (Schema.PicklistEntry picklistEntry : listPickList) {
hardwareOptions.add(new SelectOption(picklistEntry.getValue(),picklistEntry.getLabel()));
}
setHardwareItemTypes(hardwareOptions);
}
//----- Retrieve Picklist Values for NMC System ---------------------------
public void retrieveNMCSystemValues(){
List<SelectOption> nmcSystem= new List<SelectOption>();
Schema.DescribeFieldResult dFieldResult = NMC_Account__c.NMC_System__c.getDescribe();
List<Schema.PicklistEntry> listPickList = dFieldResult.getPicklistValues();
for (Schema.PicklistEntry picklistEntry : listPickList) {
nmcSystem.add(new SelectOption(picklistEntry.getValue(),picklistEntry.getLabel()));
}
setNMCSystems(nmcSystem);
}

//------------ Retrieve Picklist Values for Connection Type -------------
public void retrieveConnectionTypePicklistValues(){
System.debug('connectionPicklist');
allConnectionTypes = new List<SelectOption>();
Schema.DescribeFieldResult dFieldResult = Connection_Type__c.Connection_Type__c.getDescribe();
List<Schema.PicklistEntry> listPickList = dFieldResult.getPicklistValues();
for(Schema.PicklistEntry picklistEntry : listPickList) {
allConnectionTypes.add(new SelectOption(picklistEntry.getValue(),picklistEntry.getLabel()));
}
}

//==== Test Methods for the methods above ========


public static testMethod void testOutageContactToolForHardware() {
// START on NOTIFICATION_TOPIC page1
PageReference page1 = new PageReference('Page.oct_notification_topic');
Test.setCurrentPage(page1);
OutageContactToolController octController = new OutageContactToolController();
octController.setNotification_topic(OutageContactToolController.HARDWARE_VALUE);
PageReference hardwarePage =octController.submitNotificationTopicPage();
//Setting the hardware type list to T2 test data
String[] user_selected_hardware = new List<String>();
user_selected_hardware.add('T2');
octController.setSelected_hardware(user_selected_hardware);
//Setting the NMC Systems multi-checkbox list to 1,2 test data
String[] user_selected_NMCSystem = new List<String>();
//user_selected_NMCSystem.add('1');
octController.setSelected_nmc_system(user_selected_NMCSystem);
setCampaignAndRedirectToContactNotificationPage(octController,'1');
}

public static testMethod void testOutageContactToolForPortalServices(){
// START on NOTIFICATION_TOPIC page1
PageReference page1 = new PageReference('Page.oct_notification_topic');
Test.setCurrentPage(page1);
OutageContactToolController octController = new OutageContactToolController();
octController.setNotification_topic(OutageContactToolController.PORTAL_AND_SERVICES_VALUE);
PageReference portalAndServicesPage =octController.submitNotificationTopicPage();
//Setting the Connection type list to test data
String[] user_selected_portal_and_services= new List<String>();
user_selected_portal_and_services.add('CDS');
user_selected_portal_and_services.add('CER');
octController.setSelected_portal_and_services(user_selected_portal_and_services);
//Setting the NMC Systems multi-checkbox list to 1,2 test data
String[] user_selected_NMCSystem = new List<String>();
// user_selected_NMCSystem.add('1');
//user_selected_NMCSystem.add('2');
octController.setSelected_nmc_system(user_selected_NMCSystem);
setCampaignAndRedirectToContactNotificationPage(octController,'2');
}

public static testMethod void testOutageContactToolForNmcSystems(){
// START on NOTIFICATION_TOPIC page1
PageReference page1 = new PageReference('Page.oct_notification_topic');
Test.setCurrentPage(page1);
OutageContactToolController octController = new OutageContactToolController();
octController.redirectToNotificationTopicPage();
octController.setNotification_topic(OutageContactToolController.NMC_SYSTEM_VALUE);
PageReference portalAndServicesPage =octController.submitNotificationTopicPage();
//Setting the NMC Systems multi-checkbox list to 1,2 test data
String[] user_selected_NMCSystem = new List<String>();
// user_selected_NMCSystem.add('1');
//user_selected_NMCSystem.add('2');
octController.setSelected_nmc_system(user_selected_NMCSystem);
setCampaignAndRedirectToContactNotificationPage(octController,'3');
}

public static testMethod void testOutageContactToolForCustomSearchWithCustID(){
// START on NOTIFICATION_TOPIC page1
PageReference page1 = new PageReference('Page.oct_notification_topic');
Test.setCurrentPage(page1);
OutageContactToolController octController = new OutageContactToolController();
octController.setNotification_topic(OutageContactToolController.CUSTOM_SEARCH);
PageReference portalAndServicesPage =octController.submitNotificationTopicPage();
//Set the Radio button
octController.setSelected_customSearch(CUST_ID);
//Set the text area
octController.setSelected_Textarea('1015230,1015188,1015148,1015028');
setCampaignAndRedirectToContactNotificationPage(octController,'4');

}

public static testMethod void testOutageContactToolForCustomSearchWithAuxId(){
// START on NOTIFICATION_TOPIC page1
PageReference page1 = new PageReference('Page.oct_notification_topic');
Test.setCurrentPage(page1);
OutageContactToolController octController = new OutageContactToolController();
octController.setNotification_topic(OutageContactToolController.CUSTOM_SEARCH);
PageReference portalAndServicesPage =octController.submitNotificationTopicPage();
//Set the Radio button
octController.setSelected_customSearch(AUX_ID);
//Set the text area
octController.setSelected_Textarea('13345,995025255,84772865,1793731831');
setCampaignAndRedirectToContactNotificationPage(octController,'4');

}

public static testMethod void testOutageContactToolForCustomSearchWithCompanyId(){
// START on NOTIFICATION_TOPIC page1
PageReference page1 = new PageReference('Page.oct_notification_topic');
Test.setCurrentPage(page1);
OutageContactToolController octController = new OutageContactToolController();
octController.setNotification_topic(OutageContactToolController.CUSTOM_SEARCH);
PageReference portalAndServicesPage =octController.submitNotificationTopicPage();
//Set the Radio button
octController.setSelected_customSearch(COMPANY_ID);
//Set the text area
octController.setSelected_Textarea('FLEETRSK,STONEVQS,ATA,ITERISVQS');
setCampaignAndRedirectToContactNotificationPage(octController,'4');

}

public static testMethod void testOutageContactToolForCustomSearchWithNmcAccount(){
// START on NOTIFICATION_TOPIC page1
PageReference page1 = new PageReference('Page.oct_notification_topic');
Test.setCurrentPage(page1);
OutageContactToolController octController = new OutageContactToolController();
octController.setNotification_topic(OutageContactToolController.CUSTOM_SEARCH);
PageReference portalAndServicesPage =octController.submitNotificationTopicPage();
//Set the Radio button
octController.setSelected_customSearch(NMC_ACCOUNT);
//Set the text area
octController.setSelected_Textarea('133456,2180096,54260736,25602048');
setCampaignAndRedirectToContactNotificationPage(octController,'4');

}

private static void setCampaignAndRedirectToContactNotificationPage(
OutageContactToolController octController, String portalValue){
//set the new campaign object with test data
octController.Newcampaign = getNewCampaignObject();
//Set the notification topic to contact information page
octController.setNotification_topic(CONTACT_NOTIFICATION);
octController.submitNotificationTopicPage();
// Set contact notification type:
String[] user_selected_contact_types = new List<String>();
user_selected_contact_types.add('Downtime/Degraded');
octController.setSelected_contact_types(user_selected_contact_types);

// Set the Portal Parameter
ApexPages.currentPage().getParameters().put('Portal',portalValue);

// simulate finish button
octController.submitHardwarePortalAndServicesPage();


//Get Account districts
String accountDistricts = octController.getAcctDistricts();

//Split the account Districts on '~'
String[] accountDistrictsList = accountDistricts.split('~');

String outageId = octController.getOutageContactInfoName();
//If portalValue == 4 i.e., Custom Search Call the validation on text area
if(portalValue == '4'){
OutageContactToolController.validateCustomSearchIds(outageId);
}
for(String accountDistrict : accountDistrictsList){
OutageContactToolController.retrieveAffectedAccountInfo(outageId, 'Strategic',portalValue);
break;
}
OutageContactToolController.retrieveConnectionTypeReportURL(outageId,portalValue);
}

public static testMethod void coverAllUncoveredMethods(){
OutageContactToolController octController = new OutageContactToolController();
octController.cancelRequest();
octController.redirectToNotificationTopicPage();
octController.getAccountProcessingComplete();
octController.getUserMessage();
octController.getPORTAL_AND_SERVICES_VALUE();
octController.getCONTACT_NOTIFICATION();
octController.getQueryParameter();
octController.setQueryParameter('1');


}


private static Campaign getNewCampaignObject(){
Campaign newCampaign = new Campaign();
newCampaign.Generate_Campaign__c = true;
newCampaign.Name = 'Test Campaign Name';
newCampaign.Market__c = 'Metro';
newCampaign.Type = 'Email';
newCampaign.Status= 'Planned';
newCampaign.StartDate = Date.valueOf('2008-12-03');
newCampaign.EndDate = Date.valueOf('2008-12-05');
newCampaign.IsActive = true;
return newCampaign;
}

public static testMethod void testOutageContactToolComponents() {
//SERIALIZED_UNIT_SUMMARY TEST ===========================================================
Account sampleAccount = [SELECT Id FROM Account LIMIT 1];
Serialized_Units__c newSU = new Serialized_Units__c();
newSU.Account__c = sampleAccount.Id;
newSU.Item_Type__c = 'GT';
newSU.NMC_System__c = '1';
newSU.Serial__c = '11111999999999999';
insert newSU;
newSU.Item_Type__c = 'OX';
update newSU;
delete newSU;



}

public static testMethod void testRedirectToServicesPortalPage(){
OutageContactToolController octController3 = new OutageContactToolController();
octController3.redirectToRespectivePageOnCancel();
String outageContactInfoName =null;
String PortalService = 'true';
String notification_topic = CONTACT_NOTIFICATION;

}

public static testMethod void testHardwarePortalAndServicesPage(){
String PortalService='true';
Outage_Contact_Info__c accountOutageContactInfo = new Outage_Contact_Info__c();
accountOutageContactInfo.Name='c_dhegde@qualcommqes.com.test 2009-05-21 22:57:41';
accountOutageContactInfo.Account_Name__c='Qualcomm';
accountOutageContactInfo.User_Hardware_or_Services_Selections__c='Bill Back Dial In';
accountOutageContactInfo.NMC_System__c='1';
accountOutageContactInfo.User_Contact_Type_Selections__c='Time Change';
accountOutageContactInfo.Report_Type__c='PORTAL_AND_SERVICES_VALUE';
insert accountOutageContactInfo;

Serialized_Unit_Summary__c unit1= new Serialized_Unit_Summary__c();
unit1.Account__c = [select Id from Account limit 1].Id;
unit1.Item_Type__c ='GT';
unit1.NMC_System__c = '1';
insert unit1;
//[select Id,Account__c,NMC_Account__c from Serialized_Units__c where NMC_Account__c<>'' limit 1];
appendItemType(accountOutageContactInfo,unit1);


}


    // Modified by Shruti Karn for CR# 22542
    public static testMethod void testMethod1(){
     OutageContactToolController octController = new OutageContactToolController();
     String testValue;
     testValue = octController.getNMC_SYSTEM_VALUE();
     testValue = octController.getCustom_SEARCH();
     testValue = octController.getHARDWARE_VALUE();
     testValue = octController.getNMC_ACCOUNT();
     testValue = octController.getCUST_ID();
     testValue = octController.getAUX_ID();
     testValue = octController.getCOMPANY_ID();
     testValue = octController.getNotification_topic();
     testValue = octController.getSelected_customSearch();
     testValue = octController.getSelected_Textarea();
     
     List<SelectOption> testList = new List<SelectOption> ();
     testList = octController.getNMCSystems();
     testList = octController.getHardwareItemTypes();
     testList = octController.getConnectionTypes();
     octController.setConnectionTypes(testList);
     Campaign newCampaign = new Campaign();
     newCampaign = octController.getNewCampaign();
     String[] testValues;
     testValues = octController.getSelected_hardware();
     testValues = octController.getSelected_nmc_system();
     testValues = octController.getSelected_portal_and_services();
     testValues = octController.getSelected_contact_types();
    }
    
     public static testMethod void testMethod2(){
     OutageContactToolController octController = new OutageContactToolController();
     
     Outage_Contact_Info__c newObj = new Outage_Contact_Info__c();
     newObj.Name = 'Test';
     newObj.NMC_System__c ='1';
     newObj.Number_of_Units__c = 41;
     newObj.Item_Type__c = 'MCP110';
     newObj.Report_Type__c = 'Hardware/Systems';
     newObj.User_Contact_Type_Selections__c = 'Downtime/Degraded;';
     newObj.Account_Name__c = 'User Selections';
     newObj.User_Hardware_or_Services_Selections__c = 'MPLS';
     newObj.User_custom_search_textarea__c ='12101986';
     newObj.NMC_Account_del__c = 'Test';
     insert newObj;
     
     Account newAccount = new Account();
     newAccount.Name = 'SFDC';
     newAccount.Type = 'Other';
     newAccount.BillingStreet = 'Test Address';
     newAccount.BillingCity = 'Test City';
     newAccount.BillingCountry = 'Test Country';
     newAccount.QWBS_Status__c = 'Active';
     newAccount.District__c = 'Strategic';
     newAccount.QWBS_Cust_ID__c = '1234';
     insert newAccount;
     
     Account newAccount1 = new Account();
     newAccount1.Name = 'SFDC1';
     newAccount1.Type = 'Other1';
     newAccount1.BillingStreet = 'Test Address1';
     newAccount1.BillingCity = 'Test City1';
     newAccount1.BillingCountry = 'Test Country1';
     newAccount1.QWBS_Status__c = 'Active1';
     newAccount1.District__c = 'Strategic1';
     newAccount1.QWBS_Cust_ID__c = '4567';
     insert newAccount1;
     List<Account> accountList = new  List<Account>();
     accountList.add(newAccount);
     accountList.add(newAccount1);
     
     NMC_Account__c newNMC = new NMC_Account__c();
     newNMC.Name = 'Test';
     newNMC.NMC_System__c = '1';
     newNMC.Account__c = newAccount.Id;
     newNMC.NMC_Account_Name__c ='Test';
     newNMC.NMC_Aux_ID__c = '13345';
     newNMC.NMC_Account__c = '12101986';
     insert newNMC;
     
     Connection_Type__c newConnectnObj = new Connection_Type__c();
     newConnectnObj.NMC_Account__c = newNMC.Id;
     newConnectnObj.Connection_Status__c ='Active';
     newConnectnObj.Connection_Type__c = 'MPLS';
     insert newConnectnObj;
     List<NMC_Account__c> nmcAccountList = new List<NMC_Account__c>();
     nmcAccountList.add(newNMC);
     Map<ID, Outage_Contact_Info__c> accountOutageMap = new Map<ID, Outage_Contact_Info__c>();
     accountOutageMap.put(newAccount.Id,newObj);
     test.startTest();
     OutageContactToolController.retrieveAffectedAccountInfo(newObj.Name,'Strategic','1');
     newObj.Report_Type__c = 'Custom Search';
     update newObj;
     OutageContactToolController.retrieveAffectedAccountInfo(newObj.Name,'Strategic','4');
     newObj.Report_Type__c = 'Portal/Services/Systems';
     update newObj;
     OutageContactToolController.retrieveAffectedAccountInfo(newObj.Name,'Strategic','4');
     newObj.Report_Type__c = 'System Only';
     update newObj;
     OutageContactToolController.retrieveAffectedAccountInfo(newObj.Name,'Strategic','3');
     ApexPages.currentPage().getParameters().put('Portal','1');
     octController.redirectToRespectivePageOnCancel();
     ApexPages.currentPage().getParameters().put('Portal','2');
     octController.redirectToRespectivePageOnCancel();
     ApexPages.currentPage().getParameters().put('Portal','3');
     octController.redirectToRespectivePageOnCancel();
     system.debug('newObj.Name:'+newObj.Name+'accountOutageMap:'+accountOutageMap+'nmcAccountList:'+nmcAccountList);
     OutageContactToolController.addSummaryInfoToAccountMapForNMCAccount(newObj.Name,accountOutageMap,nmcAccountList);
     newNMC.Account__c = newAccount1.Id;
     update newNMc;
     nmcAccountList.add(newNMC);
     OutageContactToolController.addSummaryInfoToAccountMapForNMCAccount(newObj.Name,accountOutageMap,nmcAccountList);
     accountOutageMap.clear();
     //accountOutageMap.put(newAccount.QWBS_Cust_ID__c,newObj);
     //accountOutageMap.put(newAccount1.QWBS_Cust_ID__c,newObj);
     OutageContactToolController.addSummaryInfoToAccountMap(newObj.Name,accountOutageMap,accountList);
     test.stopTest();
     }
}