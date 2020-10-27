public with sharing class FFProjectBillingController {
    public List<pse__Proj__c> lstProject {get;set;}
    public List<pse__Budget__c> lstBudget {get;set;}
    public List<BillingAuditItem> lstBillableProjects{get;set;}
    public List<BillingAuditItem> lstInsufficientBudget{get;set;}
    public List<BillingAuditItem> lstInsufficientHours{get;set;}
    public List<BillingAuditItem> lstExcludedFromBilling{get;set;}
	public String mode {get;set;}
	public static Date billingFromDate {get;set;}
	public static Date billingToDate {get;set;}
    public FFProjectBillingController() {}
    
    public void getAllProjects() {
        mode = 'Preview';
		lstProject = [SELECT Id, Name, pse__Exclude_From_Billing__c, (SELECT Id,Name, pse__Total_Billable_Amount__c, pse__Approved__c, pse__Status__c, pse__Project__c from pse__Timecards__r WHERE pse__Billable__c = true AND pse__Invoiced__c = false AND pse__Billed__c = false AND pse__End_Date__c >= :billingFromDate AND pse__End_Date__c <= :billingToDate AND pse__Total_Billable_Amount__c > 0) FROM pse__Proj__c WHERE pse__Billing_Type__c = 'Time and Materials' AND pse__Stage__c = 'In Progress' AND RecordTypeId IN (SELECT Id FROM RecordType WHERE SobjectType = 'pse__Proj__c' AND Name = 'Customer Project')];
		lstBudget = [select Id,Name,Unbilled_Revenue__c,pse__Project__c from pse__Budget__c where pse__Project__c IN :lstProject];
		Decimal billableAmount = 0;
		Decimal unApprovedAmount = 0;
		Decimal unbilledRevenue = 0;
		Integer approvedTimecards = 0;
		Integer unapprovedTimecards = 0;
		lstBillableProjects = new List<BillingAuditItem>();
		lstInsufficientBudget = new List<BillingAuditItem>();
		lstInsufficientHours = new List<BillingAuditItem>();
		lstExcludedFromBilling = new List<BillingAuditItem>();
		List<Id> timecardIds = new List<Id>();
		for(pse__Proj__c proj : lstProject){
			List<pse__Timecard_Header__c> lstTimeCards = proj.pse__Timecards__r;
			for(pse__Timecard_Header__c timecard : lstTimecards){
				timecardIds.add(timecard.Id);
			}
		}
		List<ProcessInstance> approvals = [Select Id, TargetObjectId, Status from ProcessInstance where TargetObjectId IN :timecardIds Order By CreatedDate ASC];
		Map<Id, String> approvalMap = new Map<Id, String>();
		for(ProcessInstance approval : approvals){
			approvalMap.put(approval.TargetObjectId, approval.Status);
		}
		for(pse__Proj__c proj : lstProject){
			List<pse__Timecard_Header__c> lstTimeCards = proj.pse__Timecards__r;
			if(lstTimeCards.size() > 0){
				for(pse__Timecard_Header__c timecard : lstTimecards){
					if(timecard.pse__Approved__c && timecard.pse__Status__c == 'Approved' && approvalMap.get(timecard.Id) == 'Approved'){
						billableAmount = billableAmount + timecard.pse__Total_Billable_Amount__c;
						approvedTimecards += 1;
					}else if(timecard.pse__Status__c == 'Saved' || timecard.pse__Status__c == 'Submitted' || approvalMap.get(timecard.Id) != 'Approved'){
						unApprovedAmount = unApprovedAmount + timecard.pse__Total_Billable_Amount__c;
						unapprovedTimecards += 1;
					}
				}

				for(pse__Budget__c budget : lstBudget){
					if(budget.pse__Project__c == proj.Id){
						unbilledRevenue = budget.Unbilled_Revenue__c;
					}
				}
				BillingAuditItem auditItem = new BillingAuditItem();
				auditItem.projectName = proj.Name;
				auditItem.projectId = String.valueOf(proj.Id);
				auditItem.billableAmount = billableAmount;
				auditItem.unApprovedAmount = unApprovedAmount;
				auditItem.approvedTimecards = approvedTimecards;
				auditItem.unapprovedTimecards = unapprovedTimecards;
				auditItem.unbilledRevenue = unbilledRevenue;
				auditItem.excludedFromBilling = proj.pse__Exclude_From_Billing__c;
				if(auditItem.excludedFromBilling){
					lstExcludedFromBilling.add(auditItem);    
				}else if(billableAmount < 300){
					lstInsufficientHours.add(auditItem);
				}else if(billableAmount >= 300 && billableAmount > unbilledRevenue){
					lstInsufficientBudget.add(auditItem);
				}else{
					lstBillableProjects.add(auditItem);
				}
				billableAmount = 0;
				unApprovedAmount = 0;
				approvedTimecards = 0;
				unapprovedTimecards = 0;
			}
		}
		lstBillableProjects.sort();
		lstInsufficientBudget.sort();
		lstInsufficientHours.sort();
		lstExcludedFromBilling.sort();
    }
	
	public void updateBillableProjects() {
		mode = 'Update';
		List<pse__Proj__c> projectList = [SELECT Id, Name, pse__Account__c, pse__Exclude_From_Billing__c, (SELECT Id,Name, pse__Total_Billable_Amount__c, pse__Approved__c, pse__Status__c, pse__Project__c from pse__Timecards__r WHERE pse__Billable__c = true AND pse__Invoiced__c = false AND pse__Billed__c = false AND pse__End_Date__c >= :billingFromDate AND pse__End_Date__c <= :billingToDate AND pse__Total_Billable_Amount__c > 0) FROM pse__Proj__c WHERE pse__Billing_Type__c = 'Time and Materials' AND pse__Stage__c = 'In Progress' AND RecordTypeId IN (SELECT Id FROM RecordType WHERE SobjectType = 'pse__Proj__c' AND Name = 'Customer Project')];
		List<pse__Budget__c> budgetList = [select Id,Name,Unbilled_Revenue__c,pse__Project__c  from pse__Budget__c where pse__Project__c IN :projectList];
		Decimal billableAmount = 0;
		Decimal unbilledRevenue = 0;
		List<Id> timecardIds = new List<Id>();
		for(pse__Proj__c proj : projectList){
			List<pse__Timecard_Header__c> lstTimeCards = proj.pse__Timecards__r;
			for(pse__Timecard_Header__c timecard : lstTimecards){
				timecardIds.add(timecard.Id);
			}
		}
		List<ProcessInstance> approvals = [Select Id, TargetObjectId, Status from ProcessInstance where TargetObjectId IN :timecardIds Order By CreatedDate ASC];
		Map<Id, String> approvalMap = new Map<Id, String>();
		for(ProcessInstance approval : approvals){
			approvalMap.put(approval.TargetObjectId, approval.Status);
		}
		List<pse__Proj__c> billableProjects = new List<pse__Proj__c>();
		for(pse__Proj__c proj : projectList){
			List<pse__Timecard_Header__c> lstTimeCards = proj.pse__Timecards__r;
			if(lstTimeCards.size() > 0){
				for(pse__Timecard_Header__c timecard : lstTimecards){
					if(timecard.pse__Approved__c && timecard.pse__Status__c == 'Approved' && approvalMap.get(timecard.Id) == 'Approved'){
						billableAmount = billableAmount + timecard.pse__Total_Billable_Amount__c;
					}
				}

				for(pse__Budget__c budget : budgetList){
					if(budget.pse__Project__c == proj.Id){
						unbilledRevenue = budget.Unbilled_Revenue__c;
					}
				}
				if(!proj.pse__Exclude_From_Billing__c && billableAmount >= 300 && billableAmount <= unbilledRevenue){
					System.debug('Billable Project Name: ' + proj.Name);
					billableProjects.add(proj);
				}
				billableAmount = 0;
			}
		}
		System.debug('Billable Projects Size: ' + billableProjects.size());
		Database.executeBatch(new FFUpdateModeBillingGenerateBatch(billableProjects, billingFromDate, billingToDate), 200);
		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, billableProjects.size() + ' Project(s) have been submitted for billing generation, you will be notified as and when process passes through different stages of billing generation events.'));
	}
    
    public PageReference exportToExcel(){
        getAllProjects();
        PageReference pg = new PageReference('/apex/FFProjectBillingExport');
        return pg;
    }

}