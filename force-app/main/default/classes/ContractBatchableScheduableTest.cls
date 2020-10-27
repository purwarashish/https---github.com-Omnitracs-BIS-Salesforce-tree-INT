/**
 * Created by stevelohrenz on 5/14/17.
 */

@IsTest
private class ContractBatchableScheduableTest {
    private static VistaAssetHelperUtil util = new VistaAssetHelperUtil();

    static testMethod void testScheduledJob() {
        insert new ByPassTrigger__c(SetupOwnerId=UserInfo.getOrganizationId(), isDisabled__c=true, Name='Testing Bypass');

        Account account = util.createAccount('ABC Test Account');
        Contract contract = util.createContract(null, account, 'Customer - MSA', Date.today());
        List<Product2> productList = new List<Product2>();
        //subPricingType = 'Fixed Price' or 'Percent Of Total'
        productList.addAll(util.initProductSet(1, 'Hardware', '', 'Fixed Price', 'Monthly'));
        Map<Id, PricebookEntry> pricebookEntries = new Map<Id, PricebookEntry>();
        pricebookEntries = util.initPricebook(productList);
        Opportunity opportunity = util.createNewOpportunity('Test Opportunity 1 Decom', account, 'Products, Services and Maintenance', 'New');
        SBQQ__Quote__c sbQuote = util.createSBQuote(opportunity, account, Date.today(), true);
        List<SBQQ__Quoteline__c> sbQuoteLines = util.createSBQuoteLines(sbQuote, pricebookEntries, true, 0);
        //List<OpportunityLineItem> opportunityLineItems = util.createOppLineItems(opportunity, sbQuoteLines, pricebookEntries);
        opportunity = util.closeWonOpportunity(opportunity);
        List<SBQQ__Subscription__c> subscriptionList = util.createSubscriptions(sbQuoteLines, contract, account, null);

        Test.startTest();
        String jobId = System.schedule('testContractBatchableScheduable', '0 0 0 3 9 ? 2022', new ContractBatchableSchedulable());
        Test.stopTest();
    }
}