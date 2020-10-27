@istest(seeAllData=true)
private class salesInfoXRSQuotes_Test{
static testmethod void salesInfoXRSQuotesTest()
{
salesInfoXRSQuotes item = new salesInfoXRSQuotes();

Opportunity oppty = new Opportunity();
List<VCG_CPQ_Quote__c> lstquot = [SELECT Id,Opportunity__c FROM VCG_CPQ_Quote__c WHERE Opportunity__c != null Limit 1];
for(VCG_CPQ_Quote__c objquot:lstquot)
{   
    item.OpportunityId = objquot.Opportunity__c;
    String baseURL = item.baseURL;
    VCG_CPQ_Quote__c newQuote = item.objQuote;
    opportunity newOppty = item.objOpportunity;
    List<opportunityLineItem> newlstOppty= item.lstOpportunityProduct;
}
}
}