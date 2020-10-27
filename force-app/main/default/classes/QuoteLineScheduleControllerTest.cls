/**
 * Created by Yasir Arafat
 */

@IsTest
private class QuoteLineScheduleControllerTest {
    private static VistaAssetHelperUtil util = new VistaAssetHelperUtil();
    
    @testSetup
    static void SetupData() {
        TestUtils.defineCustomSettings();
    }

    @IsTest
    static void testQuoteLineScheduleManager() {
        Account account = util.createAccount('ABC Test Account');
        List<Product2> productList = new List<Product2>();
        //subPricingType = 'Fixed Price' or 'Percent Of Total'
        productList.addAll(util.initProductSet(1, 'Hardware', '', 'Fixed Price', 'Monthly'));
        productList[0].Shipment_Schedule_Required__c = TRUE;
        update productList;
        Map<Id, PricebookEntry> pricebookEntries = new Map<Id, PricebookEntry>();
        pricebookEntries = util.initPricebook(productList);
        Opportunity opportunity = util.createNewOpportunity('Test Opportunity 1', account, 'Products, Services and Maintenance', 'New');
        SBQQ__Quote__c sbQuote = util.createSBQuote(opportunity, account, Date.today(), true);
        List<SBQQ__Quoteline__c> sbQuoteLines = util.createSBQuoteLines(sbQuote, pricebookEntries, true, 5);

        Test.startTest();
        PageReference pageRef = Page.QuoteLineSchedules; // Specify VF page Name here
        pageRef.getParameters().put('id', String.valueOf(sbQuote.Id));
        Test.setCurrentPage(pageRef);
        ManageQuoteLineScheduleController schedulerController = new ManageQuoteLineScheduleController();
        schedulerController.initialize();
        schedulerController.addRevision();
        schedulerController.submit();
        Revision_Schedule__c revSched = [Select Id, Status__c from Revision_Schedule__c where Quote__c = :sbQuote.Id LIMIT 1];
        revSched.Status__c = 'Approved';
        update revSched;
        Test.stopTest();
    }
}