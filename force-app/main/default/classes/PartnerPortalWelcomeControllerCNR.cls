public class PartnerPortalWelcomeControllerCNR {

// This controller has been modified for QES by msilber
// start channel manager welcome code provided by will moxley
// taken from master prm demo org
User PartnerUser; 

public User getPartnerUser() {
if(PartnerUser==null)
{
PartnerUser= [select u.Contact.AccountId,u.Contact.Account.Owner.Name,u.Contact.Account.Owner.Email from User u where u.id= :UserInfo.getUserId() limit 1];
}

return PartnerUser;
}
// end channel manager welcome code

public String UserId = UserInfo.getUserId();
public String UserName = UserInfo.getName();
User u = [Select id,contactId from User where id = :UserId];

// constructor initializes page and determines whether to show datatable or error message
public PartnerPortalWelcomeControllerCNR() {

// * start init functions for partner stats

initExpiringDealRegs();
initActiveLeads();
initActiveLeadsExp7Days();
initActiveDeals();
// * end init functions for partner stats

// comment out line below if you don't want to show lead inbox
initLeadInbox();

// comment out line below if you don't want to show approval requests
initApprovalRequests();

// comment out line below if you don't want to show popular solutions
// initTopSolutions();

// comment out line below if you don't want to show ideas
// initPopularIdeas();

}

// *** START APEX CODE TO RETRIEVE PARTNER STATS.
// comment out this section if you don't want to show partner stats


// * START CODE FOR EXPIRING DEAL REGS STAT

public Integer ExpiringRegs;
// Not used at this time
// public RecordType PartnerOpportunityRecordType;
// --> The next line is org specific
// You MUST configure the RecordTypeId and LeadSource in the SOQL query below to map to the proper Deal Registration RecordType Id and Lead Source in your org
public void initExpiringDealRegs() {
date dealExpDate = system.today() + 30;
// Not used at this time
//PartnerOpportunityRecordType = [Select Id From RecordType where Name like 'Indirect (Partner)'];

// if(PartnerOpportunityRecordType != null){
// ExpiringRegs = [Select count()from Opportunity where LeadSource='Deal Registration' AND RecordTypeId=:PartnerOpportunityRecordType.Id AND ownerid=:UserId AND IsClosed = False];
// ExpiringRegs = [Select count()from Opportunity where Deal_Expiration__c <=:dealExpDate AND ownerid=:UserId];

// ExpiringRegs = [Select count()from Opportunity where ownerid=:UserId];
}
//}

public Integer getExpiringDealRegs() {
return ExpiringRegs;
}

// * END CODE FOR ACTIVE DEAL REGS STAT

public Integer ActiveDeals;
public void initActiveDeals() {
date dealExpDate = system.today(); 
// ActiveDeals = [Select count()from Opportunity where Deal_Expiration__c >:dealExpDate AND ownerid=:UserId AND IsClosed = False];

}

public Integer getActiveDeals() {
return ActiveDeals;
}

// * END CODE FOR ACTIVE DEAL REGS STAT

// * START CODE FOR ACTIVE LEADS STAT

public Integer ActiveLeads;
public void initActiveLeads() {
ActiveLeads = [Select count()from Lead where IsConverted=FALSE AND Status <> 'Bad' AND ownerid=:UserId];
}

public Integer getActiveLeads() {
return ActiveLeads;
}

// * END CODE FOR ACTIVE LEADS STAT

// * START CODE FOR LEADS EXPIRING THIS WEEK STAT

public Integer ActiveLeadsExp7Days;

public void initActiveLeadsExp7Days() {
date leadExpDate7Days = system.today() + 7; 
ActiveLeadsExp7Days = [Select count()from Lead where IsConverted=FALSE AND Status <> 'Bad' AND Status <> 'Pending Approval' AND ownerid=:UserId];

}

public Integer getActiveLeadsExp7Days() {
return ActiveLeadsExp7Days;
} 
// * END CODE FOR LEADS EXPIRING THIS WEEK STAT 
// *** END APEX CODE TO RETRIEVE PARTNER STATS

// *** START APEX CODE TO RETRIEVE LEAD INBOX.
// comment out this section if you don't want to show lead inbox

ID LeadId;

public void setLeadId(ID value){
LeadId = value;
}
public ID getLeadId(){
return LeadId;
}


Boolean Redirect = false;

Public PageReference AcceptLead() {

LeadId = System.currentPageReference().getParameters().get('LeadId');

Lead l = [Select id from Lead where id = :LeadId limit 1];

l.OwnerId = UserId;
update l; 

Redirect = True;
// The PageReference below must match the name of the Visualforce page associated to this controller 
PageReference page = new PageReference('/apex/PartnerPortalWelcome');
page.getParameters().put('lead_id',l.Id);

page.setRedirect(true);
return page;
}

public void setRedirect(Boolean value) {
Redirect = value;
}

public Boolean getRedirect() {
return Redirect;
}


public List<Lead> LeadInbox; 

public Boolean ShowLeadInbox {
get { return ShowLeadInbox; }
set { ShowLeadInbox = value; } 
}

public String LeadInboxMessage {
get { return LeadInboxMessage; }
set { LeadInboxMessage = value; } 
}

public void initLeadInbox() {
// ms- modify owner.name to match requirements. Currently set to 'Partner Queue'
LeadInbox = [select Id, Name, Title, City, Company, toLabel(Industry), CreatedDate, IsConverted, IsUnreadByOwner, OwnerId, Owner.Type, LeadSource, ConvertedOpportunityId, ConvertedOpportunity.Name from Lead Where IsConverted=false and Owner.Type='Queue' and Owner.Name = 'Partner Queue' order by CreatedDate desc limit 5];

// return an error if no leads in queues.
if(LeadInbox.isEmpty()){
ShowLeadInbox = false;
LeadInboxMessage = 'No se encontró lista de candidatos.';
}
else{
ShowLeadInbox = true;
LeadInboxMessage = '';
}
}

public list<Lead> getLeadInbox() {
return LeadInbox;
}
// *** END APEX CODE TO RETRIEVE LEAD INBOX


// comment out this section if you don't want to show approval requests
// wrapper class to store Approval Requests in a generic SObject instead of an ProcessInstanceStep SObject so we can show it in the portal
public class ApprovalRequests {

public ProcessInstanceStep pi {
get { return pi; }
set { pi = value; }
}


public String TargetObjectName {
get { return TargetObjectName; }
set { TargetObjectName = value; }
}

public String TargetObjectType {
get { return TargetObjectType; }
set { TargetObjectType = value; }
}

public String SubmittedDate {
get { return SubmittedDate; }
set { SubmittedDate = value; }
}

// constructor for AccountTeam SObject
public ApprovalRequests(ProcessInstanceStep p){
pi = p;
TargetObjectName = pi.ProcessInstance.TargetObject.Name;
TargetObjectType = pi.ProcessInstance.TargetObject.Type;

// convert the Submitted Date to a more readable format
Datetime Temp = Datetime.newInstance(pi.CreatedDate.year(), pi.CreatedDate.month(), pi.CreatedDate.day());
SubmittedDate = Temp.format('MMMM dd, yyyy'); 

} 
}

List<ProcessInstanceStep> Requests = new List<ProcessInstanceStep>();
List<ApprovalRequests> ApprovalRequests = new List<ApprovalRequests>();

public Boolean ShowApprovalRequests {
get { return ShowApprovalRequests; }
set { ShowApprovalRequests = value; } 
}

public String ApprovalRequestsMessage {
get { return ApprovalRequestsMessage; }
set { ApprovalRequestsMessage = value; } 
}

public void initApprovalRequests() {

// get list of approval requests
requests = [SELECT Id, ProcessInstance.TargetObject.Name, ProcessInstance.TargetObject.Type, ProcessInstance.Status, CreatedDate, ProcessInstance.Id, ProcessInstance.TargetObjectId FROM ProcessInstanceStep WHERE (StepStatus = 'Started') AND (ActorId=:UserId) AND (ProcessInstance.TargetObject.Name != '') ORDER BY CreatedDate DESC LIMIT 5];


// assemble approval requests in generic sobject ApprovalRequests
for(ProcessInstanceStep Request : Requests){
ApprovalRequests ar = new ApprovalRequests(Request);
ApprovalRequests.add(ar); 
}

// return an error if no approval requests.
if(ApprovalRequests.isEmpty()){
ShowApprovalRequests = false;
ApprovalRequestsMessage = 'No se encontró lista de candidatos.';
}
else{
ShowApprovalRequests = true;
ApprovalRequestsMessage = '';
}
}

public list<ApprovalRequests> getApprovalRequests() {
return ApprovalRequests;
}
// *** END APEX CODE TO RETRIEVE APPROVAL REQUESTS


// *** START APEX CODE TO RETRIEVE TOP SOLUTIONS.
// comment out this section if you don't want to show top solutions
public List<Solution> TopSolutions; 

public Boolean ShowTopSolutions {
get { return ShowTopSolutions; }
set { ShowTopSolutions = value; } 
}

public String TopSolutionsMessage {
get { return TopSolutionsMessage; }
set { TopSolutionsMessage = value; } 
}

public void initTopSolutions() {

TopSolutions = [select id,SolutionName,TimesUsed,LastModifiedDate from Solution WHERE (TopSolutionPRM__c = true) order by TimesUsed desc limit 3];

// return an error if no solutions.
if(TopSolutions.isEmpty()){
ShowTopSolutions = false;
TopSolutionsMessage = 'No solutions found.';
}
else{
ShowTopSolutions = true;
TopSolutionsMessage = '';
}
}

public list<Solution> getTopSolutions() {
return TopSolutions;
}
// *** END APEX CODE TO RETRIEVE TOP SOLUTIONS


// *** START APEX CODE TO RETRIEVE IDEAS
// comment out this section if you don't want to show ideas
// public List<Idea> PopularIdeas; 

// public Boolean ShowPopularIdeas {
// get { return ShowPopularIdeas; }
// set { ShowPopularIdeas = value; } 
// }

// public String PopularIdeasMessage {
// get { return PopularIdeasMessage; }
// set { PopularIdeasMessage = value; } 
// }

// public void initPopularIdeas() {

// PopularIdeas = [select id,Title,Category,VoteTotal from Idea order by VoteTotal desc limit 3];

// return an error if no ideas.
// if(PopularIdeas.isEmpty()){
// ShowPopularIdeas = false;
// PopularIdeasMessage = 'No ideas found.';
// }
// else{
// ShowPopularIdeas = true;
// PopularIdeasMessage = '';
// }
// }

// public list<Idea> getPopularIdeas() {
// return PopularIdeas;
// }
// *** END APEX CODE TO RETRIEVE IDEAS

// Controller Tetsts

// Public class testPartnerPortalWelcome {

static testMethod void PartnerPortalWelcomeTest()
{

//Test converage for the visualforce page

PageReference pageRef = Page.PartnerPortalWelcome;
Test.setCurrentPageReference(pageRef);

// create an instance of the controller

PartnerPortalWelcomeControllerCNR myPageCon = new PartnerPortalWelcomeControllerCNR();

//try calling methods/properties of the controller in all possible scenarios
// to get the best coverage.

User PartnerUser = myPageCon.getPartnerUser();
List<Lead> LeadInbox = myPageCon.getLeadInbox();
List<Solution> TopSolution = myPageCon.getTopSolutions();
// List<Idea> PopularIdeas = myPageCon.getPopularIdeas();
List<ApprovalRequests> ApprovalRequests = myPageCon.getApprovalRequests();
Integer ActiveDeals = myPageCon.getActiveDeals();
Integer ActiveLeads = myPageCon.getActiveLeads();
Integer ActiveLeadsExp7Days = myPageCon.getActiveLeadsExp7Days();
Integer ExpiringDealRegs = myPageCon.getExpiringDealRegs();
Boolean ShowLeadInbox = myPageCon.ShowLeadInbox;
// Boolean ShowPopularIdeas = myPageCon.ShowPopularIdeas;
Boolean ShowApprovalRequests = myPageCon.ShowApprovalRequests;
Boolean ShowTopSolutions = myPageCon.ShowTopSolutions;

//Modified by Shruti Karn for CR# 22542
        
        Lead newLead  = new Lead();
        newLead.FirstName = 'Test';
        newLead.LastName = 'Test';
        newLead.Company = 'Test';
        newLead.IsConverted = false;
        newLead.Country = 'US';
        newLead.City = 'San Diego';
        newLead.State = 'CA';
        insert newLead;
        
        myPageCon.setLeadId(newLead.Id);
        Id id1 = myPageCon.getLeadId();
        System.currentPageReference().getParameters().put('LeadId',newLead.ID);
        myPageCon.AcceptLead(); 
        myPageCon.setRedirect(ShowLeadInbox);
        ShowLeadInbox = myPageCon.getRedirect();
           
         ProcessInstanceStep requests = [SELECT Id, ProcessInstance.TargetObject.Name, ProcessInstance.TargetObject.Type, ProcessInstance.Status, CreatedDate, ProcessInstance.Id, ProcessInstance.TargetObjectId FROM ProcessInstanceStep WHERE (StepStatus = 'Started')  AND (ProcessInstance.TargetObject.Name != '') ORDER BY CreatedDate DESC LIMIT 1];
         myPageCon.initTopSolutions();
        ApprovalRequests newObj = new ApprovalRequests(requests );
        Solution soln = new Solution();
        soln.SolutionName = 'Test';
        soln.TopSolutionPRM__c = true;
        insert soln;
        myPageCon.initTopSolutions();
        String strTest = myPageCon.ApprovalRequestsMessage;
        strTest = myPageCon.LeadInboxMessage;
        strTest = newObj.TargetObjectName;
        strTest = newObj.TargetObjectType;
        strTest = newObj.SubmittedDate;
// Lead pLeads = PartnerPortalWelcomeController.GetLeads();

//test when type == null
//myPageCon.viewAccounts();
//test when type = 'undefinedType'
//pAccount.Type = 'other';
//myPageCon.setAccount(pAccount);
//myPageCon.viewAccounts();
// test when having results
//pAccount.Type = 'Customer';
//myPageCon.setAccount(pAccount);
//myPageCon.viewAccounts();
//myPageCon.getAccounts();
// End Test Class
}
}