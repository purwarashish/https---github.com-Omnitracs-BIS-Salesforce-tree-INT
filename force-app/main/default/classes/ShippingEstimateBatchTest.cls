@isTest //(SeeAllData=true)
public class ShippingEstimateBatchTest {
    
    public static VistaAssetHelperUtil util = new VistaAssetHelperUtil();

    @testSetup
    static void setupData() {
        TestUtils.defineCustomSettings();
    }

    static testMethod void myUnitTest() {
        Account account = util.createAccount('ABC Test Account');
        account.QWBS_Cust_ID__c = 'Test12345678';
        update account;
        OpportunityTestData opportunityTestData  = new OpportunityTestData();
        List<Contact> contactList =  opportunityTestData.ContactCreation('validateOpptyEditability', 1, account.Id);
        insert contactList;
        PriceBook2 stdPriceBook = TestUtils.getStandardPriceBook();  //opportunityTestData.createPriceBook();
        List<Opportunity> optyList = opportunityTestData.CreateOpportunity('validateOpptyEditability', account.Id, 'Products, Services and Maintenance', 1, contactList.get(0).Id, stdPriceBook, null, null, null);
        insert optyList;
        Opportunity opportunity = optyList.get(0);
        Contract contract = util.createContract(opportunity, account, 'Customer - MSA', Date.today());
        List<Product2> productList = new List<Product2>();
        productList.addAll(util.initProductSet(1, 'Hardware', '', 'Fixed Price', 'Monthly'));
        Map<Id, PricebookEntry> pricebookEntries = new Map<Id, PricebookEntry>();
        pricebookEntries = util.initPricebook(productList);
        //Opportunity opportunity = util.createNewOpportunity('Test Opportunity 1', account, 'Products, Services and Maintenance', 'New');
        SBQQ__Quote__c sbQuote = util.createSBQuote(opportunity, account, Date.today(), true);
        sbQuote.SBQQ__Status__c = 'Draft';
        update sbQuote;
        contract.SBQQ__Quote__c = sbQuote.Id;
        update contract;
        List<SBQQ__Quoteline__c> sbQuoteLines = util.createSBQuoteLines(sbQuote, pricebookEntries, true, 10);

        opportunity.SBQQ__PrimaryQuote__c = sbQuote.Id;
        opportunity.Contract__c = contract.Id;
        
        Test.startTest();
        Database.executeBatch(new ShippingEstimateBatch());
        Test.stopTest();
    }
}