public class BillingAuditItem implements Comparable {
    public Decimal billableAmount {get;set;}
	public Decimal unApprovedAmount {get;set;}
    public Decimal unbilledRevenue {get;set;}
    public Integer approvedTimecards {get;set;}
    public Integer unapprovedTimecards {get;set;}
    public String projectId {get;set;}
    public String projectName {get;set;}
    public String billingEvent {get;set;}
    public Boolean excludedFromBilling {get;set;}
    
    public BillingAuditItem() {}
	
	public Integer compareTo(Object compareTo) {
        BillingAuditItem compareToItem = (BillingAuditItem)compareTo;
        return projectName.compareTo(compareToItem.projectName);
    }
}