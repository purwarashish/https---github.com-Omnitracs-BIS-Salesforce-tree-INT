/**
 * Created by arman_shah on 10/5/18.
 */

@IsTest
private class CustomerAssetShippingControllerTest {
    public static VistaAssetHelperUtil util = new VistaAssetHelperUtil();

    @TestSetup
    static void SetupData() {
        TestUtils.defineCustomSettings();
    }

    @IsTest
    static void testBehavior() {
        insert new ByPassTrigger__c(SetupOwnerId=UserInfo.getOrganizationId(), isDisabled__c=true, Name='Testing Bypass');

        Account account = util.createAccount('ABC Test Account');
        Contract contract = util.createContract(null, account, 'Customer - MSA', Date.today());
        List<Product2> productList = new List<Product2>();
        //subPricingType = 'Fixed Price' or 'Percent Of Total'
        productList.addAll(util.initProductSet(100, 'Hardware', '', 'Fixed Price', 'Monthly'));
        Map<Id, PricebookEntry> pricebookEntries = new Map<Id, PricebookEntry>();
        pricebookEntries = util.initPricebook(productList);
        Opportunity opportunity = util.createNewOpportunity('Test Opportunity 1 Decom', account, 'Products, Services and Maintenance', 'New');
        SBQQ__Quote__c sbQuote = util.createSBQuote(opportunity, account, Date.today(), true);
        List<SBQQ__Quoteline__c> sbQuoteLines = util.createSBQuoteLines(sbQuote, pricebookEntries, true, 0);
        //List<OpportunityLineItem> opportunityLineItems = util.createOppLineItems(opportunity, sbQuoteLines, pricebookEntries);
        opportunity = util.closeWonOpportunity(opportunity);
        List<SBQQ__Subscription__c> subscriptionList = util.createSubscriptions(sbQuoteLines, contract, account, null, null);

        List<Customer_Asset__c> customerAssetList = new List<Customer_Asset__c>();
        for (SBQQ__Subscription__c subscription : subscriptionList) {
            Customer_Asset__c customerAsset = new Customer_Asset__c();
            customerAsset.Account__c = subscription.SBQQ__Account__c;
            customerAsset.Steelbrick_Subscription__r = subscription;
            customerAsset.Latest_Quote_Line__r = subscription.SBQQ__QuoteLine__r;
            customerAsset.Latest_Quote_Line__c = subscription.SBQQ__QuoteLine__r.Id;
            customerAssetList.add(customerAsset);
        }

        CustomerAssetHandler.bypassTrigger = true;
        insert customerAssetList;
        CustomerAssetHandler.bypassTrigger = false;

        Customer_Asset_Shipping_Summary__c cass =
                new Customer_Asset_Shipping_Summary__c(Customer_Asset__c = customerAssetList[0].Id);
        insert cass;
        ApexPages.StandardController sc = new ApexPages.StandardController(cass);

        Test.startTest();
        CustomerAssetShippingController cls = new CustomerAssetShippingController(sc);
        Test.stopTest();
    }
}