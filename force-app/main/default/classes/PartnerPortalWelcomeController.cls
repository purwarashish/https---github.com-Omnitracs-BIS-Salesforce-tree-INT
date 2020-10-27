/*********************************************************************

Author  : Mark Silber
Date    : 13 Mar, 2009

Usage   : Used to retrieve Leads, Ideas, Solutions etc that are to be displayed
          on QES Partner Portal pages
    
Dependencies : <other classes that this class will call> - example: Dependencies on CaseWebService,Utils

Modified by : Avinash Kaltari, TCS
Modified Date : 03 Nov, 2011
Comment : Added code to retrieve the QES Partner Portal Home Page links 
        (used in VF Pages)
        
Modified by : Avinash Kaltari, TCS
Modified Date : 10 Nov, 2011
Comment : Modified code to display only the un-Approved requests in the Approval Requests section
        (used in VF Pages)

*********************************************************************/


public class PartnerPortalWelcomeController {

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
public PartnerPortalWelcomeController() {

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

getPortalLinks();
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
//LeadInbox = [select Id, Name, Title, City, Company, toLabel(Industry), CreatedDate, IsConverted, IsUnreadByOwner, OwnerId, Owner.Type, LeadSource, ConvertedOpportunityId, ConvertedOpportunity.Name from Lead Where IsConverted=false and Owner.Type='Queue' and Owner.Name = 'Partner Queue' order by CreatedDate desc limit 5];
//DAR - 30 Sept - Modified code to show only leads that have the current user ID instead of a queue
LeadInbox = [select Id, Name, Title, City, Company, toLabel(Industry), CreatedDate, IsConverted, IsUnreadByOwner, OwnerId, Owner.Type, LeadSource, ConvertedOpportunityId, ConvertedOpportunity.Name from Lead Where IsConverted=false and ownerid=:UserId order by CreatedDate desc limit 5];

// return an error if no leads in queues.
if(LeadInbox.isEmpty()){
ShowLeadInbox = false;
LeadInboxMessage = 'No leads in queues found.';
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

public String Label{
get { return Label; }
set { Label= value; }
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

Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
Schema.SObjectType test = gd.get(TargetObjectType);
if (test != null)
{
     Schema.DescribeSObjectResult ObjResult =  test.getDescribe();
     Label = ObjResult.label;
}

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
for(ProcessInstanceStep Request : Requests)
{
//IF Condition added by Avinash Kaltari to display only un-approved Requests
    if(Request.ProcessInstance.Status == 'Pending' || Request.ProcessInstance.Status == 'Hold')
    {
        ApprovalRequests ar = new ApprovalRequests(Request);
        ApprovalRequests.add(ar); 
    }
}

// return an error if no approval requests.
if(ApprovalRequests.isEmpty()){
ShowApprovalRequests = false;
ApprovalRequestsMessage = 'No approval requests found.';
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


// ** Code to retrieve URLs for Home Page Links from Partner_Portal_Home_Page_Link__c ** 
public Partner_Portal_Home_Page_Announcement__c message{get;set;}
public List<Partner_Portal_Home_Page_Link__c> lstTrainingLinks {get;set;}
public List<Partner_Portal_Home_Page_Link__c> lstMarketingLinks {get;set;}
public List<Partner_Portal_Home_Page_Link__c> lstSupportLinks {get;set;}
public List<Partner_Portal_Home_Page_Link__c> lstPartnerWelcomeLinks {get;set;}
public List<Partner_Portal_Home_Page_Link__c> lstMDFQuicklinks {get;set;} {lstMDFQuicklinks = new List<Partner_Portal_Home_Page_Link__c>();}
public List<Partner_Portal_Home_Page_Link__c> lstSupportQuicklinks {get;set;} {lstSupportQuicklinks = new List<Partner_Portal_Home_Page_Link__c>();}
public List<Partner_Portal_Home_Page_Link__c> lstLeadQuicklinks {get;set;} {lstLeadQuicklinks = new List<Partner_Portal_Home_Page_Link__c>();}
public List<Partner_Portal_Home_Page_Link__C> lstPPLinks = [select URL__c, name, Link_Section__c, Show_on_Home_Page__c, Link_Sub_Section__c, Available_to_Public_Groups__c from Partner_Portal_Home_Page_Link__c where Show_on_Home_Page__c = true order by order__c limit 1000];
public List<Partner_Portal_Home_Page_Link__C> lstDynamicUrl {get; set;}{lstDynamicUrl = new List<Partner_Portal_Home_Page_Link__c>();}
public boolean showSection{get;set;}{showSection = false ;}
public boolean isShowMDF{get;set;}{isShowMDF = false;}
public boolean isShowSupport{get;set;}{isShowSupport = false;}
public boolean isShowLeads{get;set;}{isShowLeads = false;}

public void getPortalLinks()
{
    Set<Id> setLoggedInUserGroupIds = new Set<Id>();
    
    /*
    *Added to have messages/announcement on the PRM home page.
    **/
    List<Partner_Portal_Home_Page_Announcement__c> tempMsgList = [select id, message__c from Partner_Portal_Home_Page_Announcement__c where active__c = true order by lastModifiedDate desc limit 1];
    if(!tempMsgList.isEmpty())
    {
        message = tempMsgList[0];
    }
    /** 
     * Prepare a list of all GroupIds present in the records that
     * we fetched from the Partner_Portal_Home_Page_Link__c object.
     */
    List<String> lstGroupIds = new List<String>();
    for(Partner_Portal_Home_Page_Link__c link : lstPPLinks) {
        if(null != link.Available_to_Public_Groups__c) {
            lstGroupIds.addAll(link.Available_to_Public_Groups__c.replace(' ', '').split(',', 0));
        }
    }
    
    if(!lstGroupIds.isEmpty()) {
        /**
         * Fetch the details of the user and the public-groups that he is associated to.
         * We would be interested in only those public-groups whose Ids have been 
         * mentioned in the Partner_Portal_Home_Page_Link__c records.
         */
        List<GroupMember> lstGroupMembers = [
                                                SELECT
                                                    UserOrGroupId,
                                                    GroupId
                                                FROM
                                                    GroupMember
                                                WHERE
                                                    UserOrGroupId = :userInfo.getUserId()
                                                AND
                                                    GroupId IN :lstGroupIds
                                                LIMIT
                                                    :lstGroupIds.size()
                                            ];
        if(null != lstGroupMembers) {
            for(GroupMember gm : lstGroupMembers) {
                // Prepare a set of groupIds of which the user is really a part.
                setLoggedInUserGroupIds.add(gm.GroupId);
            }       
        } 
    }
    
    if (lstPPLinks != null && lstPPLinks.size() > 0)
    {       
        for(Partner_Portal_Home_Page_Link__c link : lstPPLinks )
        {
            Boolean availableForUser = true;
            
            /**
             * Check if the user is part of any of the public-groups mentioned
             * in this field.
             */
            if(null != link.Available_to_Public_Groups__c) {
                String[] groupIds = link.Available_to_Public_Groups__c.replace(' ', '').split(',', 0);
                availableForUser = false;           
                for(String groupId : groupIds) {
                    if(setLoggedInUserGroupIds.contains(groupId)) {
                        availableForUser = true;
                        break;
                    }
                }
            } // ENd - if

            if(!availableForUser) {
                continue;
            }
            
            if(link.Link_Section__c.contains('Training'))
            {
                if(lstTrainingLinks != null)
                {    
                    lstTrainingLinks.add(link);
                }
                else
                {
                    lstTrainingLinks = new List<Partner_Portal_Home_Page_Link__c>();
                    lstTrainingLinks.add(link);
                }
            }
            
            else if(link.Link_Section__c.contains('Marketing'))
            {
                if(lstMarketingLinks != null)
                    lstMarketingLinks.add(link);
                else
                {
                    lstMarketingLinks = new List<Partner_Portal_Home_Page_Link__c>();
                    lstMarketingLinks.add(link);
                    
                }
            }
            
            else if(link.Link_Section__c.contains('Support'))
            {
                if(lstSupportLinks != null)
                    lstSupportLinks.add(link);
                else
                {
                    lstSupportLinks = new List<Partner_Portal_Home_Page_Link__c>();
                    lstSupportLinks.add(link);
                }
            }
            else if(link.Link_Section__c.contains('Bottom - Partner Welcome'))
            {
                showSection = true;
                if(lstDynamicUrl != null)
                    lstDynamicUrl.add(link);
                else
                {
                    lstDynamicUrl = new List<Partner_Portal_Home_Page_Link__c>();
                    lstDynamicUrl.add(link);
                }
            }
            
            else if (link.Link_Section__c.contains('Sidebar'))
            {
                if(link.Link_Section__c.contains('Partner Welcome'))
                {
                    if(lstPartnerWelcomeLinks != null)
                        lstPartnerWelcomeLinks.add(link);
                    else
                    {
                        lstPartnerWelcomeLinks = new List<Partner_Portal_Home_Page_Link__c>();
                        lstPartnerWelcomeLinks.add(link);
                    }
                }
                else if(link.Link_Section__c.contains('Partner Quicklink'))
                {
                    if (link.Link_Sub_Section__c.contains('MDF')) {
                        lstMDFQuicklinks.add(link);
                        isShowMDF = true;
                    }
                    else if(link.Link_Sub_Section__c.contains('My Leads')) {
                        lstLeadQuicklinks.add(link);
                        isShowLeads = true;
                    }
                    else if(link.Link_Sub_Section__c.contains('Support')) {
                        lstSupportQuicklinks.add(link);
                        isShowSupport = true;
                    }
                }
            }
        }
    }
}
// ** Code END to retrieve URLs for Home Page Links from Partner_Portal_Home_Page_Links__c **


// Controller Tests

// Public class testPartnerPortalWelcome {

static testMethod void PartnerPortalWelcomeTest()
{

//Test converage for the visualforce page

PageReference pageRef = Page.PartnerPortalWelcome;
Test.setCurrentPageReference(pageRef);

// create an instance of the controller

PartnerPortalWelcomeController myPageCon = new PartnerPortalWelcomeController();

// try calling methods/properties of the controller in all possible scenarios
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
        newLead.City = 'San Diego';
        newLead.State = 'CA';
        newLead.Country = 'US';
        insert newLead;
        
        myPageCon.setLeadId(newLead.Id);
        Id id1 = myPageCon.getLeadId();
        System.currentPageReference().getParameters().put('LeadId',newLead.ID);
        myPageCon.AcceptLead(); 
        myPageCon.setRedirect(ShowLeadInbox);
        ShowLeadInbox = myPageCon.getRedirect();
        //commented by Arindam Laik   
        //ProcessInstanceStep requests = [SELECT Id, ProcessInstance.TargetObject.Name, ProcessInstance.TargetObject.Type, ProcessInstance.Status, CreatedDate, ProcessInstance.Id, ProcessInstance.TargetObjectId FROM ProcessInstanceStep WHERE (StepStatus = 'Started')  AND (ProcessInstance.TargetObject.Name !='') ORDER BY CreatedDate DESC LIMIT 1];
        myPageCon.initTopSolutions();
        //ApprovalRequests newObj = new ApprovalRequests(requests );
        Solution soln = new Solution();
        soln.SolutionName = 'Test';
        soln.TopSolutionPRM__c = true;
        insert soln;
        myPageCon.initTopSolutions();
        String strTest = myPageCon.ApprovalRequestsMessage;
        //strTest = myPageCon.LeadInboxMessage;
        //strTest = newObj.TargetObjectName;
        //strTest = newObj.TargetObjectType;
        //strTest = newObj.SubmittedDate;
        
        ProcessInstanceStep requests = [SELECT Id, ProcessInstance.TargetObject.Name, ProcessInstance.TargetObject.Type, ProcessInstance.Status, CreatedDate, ProcessInstance.Id, ProcessInstance.TargetObjectId FROM ProcessInstanceStep WHERE (StepStatus = 'Started')  AND (ProcessInstance.TargetObject.Name != '') ORDER BY CreatedDate DESC LIMIT 1];
         myPageCon.initTopSolutions();
        ApprovalRequests newObj = new ApprovalRequests(requests );
        Solution soln1 = new Solution();
        soln1.SolutionName = 'Test';
        soln1.TopSolutionPRM__c = true;
        insert soln1;
        myPageCon.initTopSolutions();
        String strTest1 = myPageCon.ApprovalRequestsMessage;
        strTest1 = myPageCon.LeadInboxMessage;
        strTest1 = newObj.TargetObjectName;
        strTest1 = newObj.TargetObjectType;
        strTest1 = newObj.SubmittedDate;
        
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