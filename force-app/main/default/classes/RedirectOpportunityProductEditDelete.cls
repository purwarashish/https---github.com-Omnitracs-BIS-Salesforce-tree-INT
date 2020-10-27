public with sharing class RedirectOpportunityProductEditDelete {

	public RedirectOpportunityProductEditDelete(ApexPages.StandardController ctl)
	{
		
	}
	
	public PageReference redirectOli()
	{
		//check the user's Profile against the Custom Setting
		//if they can't edit or delete then return null and display the error message
		for(Profile p : [Select Id from Profile where Name in :Restricted_OLI_Profiles__c.getAll().keySet() and Id = :userInfo.getProfileId()])
		{
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'You do not have the level of access required to perform this operation'));
			return null;
		}
		
		//If they can edit, or delete send them to the standard page
		
		if(ApexPages.currentPage().getParameters().get('common.udd.actions.ActionsUtilORIG_DELETE_URI')!=null)
		{
			delete new OpportunityLineItem(Id=ApexPages.currentPage().getParameters().get('id'));
			return new PageReference(ApexPages.currentPage().getParameters().get('retURL'));
		}
		else
			return new PageReference('/'+ApexPages.currentPage().getParameters().get('id')+'/e?retURL='+ApexPages.currentPage().getParameters().get('retURL')+'&nooverride=1');
		//https://omnitracs--dev.cs51.my.salesforce.com/apex/RedirectOpportunityProductEditDelete?id=00k5000000TBCDy&retURL=%2F0065000000XAI75&sfdc.override=1
		
	}
}