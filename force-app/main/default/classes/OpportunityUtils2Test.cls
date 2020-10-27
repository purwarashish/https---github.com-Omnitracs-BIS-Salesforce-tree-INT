@isTest
public class OpportunityUtils2Test {
    
    public static VistaAssetHelperUtil util = new VistaAssetHelperUtil();
    
    @testSetup
    static void SetupData(){
        TestUtils.defineCustomSettings();
    }
  
    static TestMethod void directSalesOnboardingTest(){
        Account account = util.createAccount('ABC Test Account');
        account.QWBS_Cust_ID__c = 'Test12345678';
        update account;
        OpportunityTestData opportunityTestData  = new OpportunityTestData();
        List<Contact> contactList =  opportunityTestData.ContactCreation('validateOppty', 1, account.Id);
        insert contactList;
        PriceBook2 stdPriceBook = TestUtils.getStandardPriceBook();  //opportunityTestData.createPriceBook();
        List<Opportunity> optyList = opportunityTestData.CreateOpportunity('validateOppty', account.Id, 'Products, Services and Maintenance', 1, contactList.get(0).Id, stdPriceBook, null, null, null);
        optyList[0].Type = 'New Customer';
        insert optyList;
        Opportunity opportunity = optyList.get(0);
        Contract contract = util.createContract(opportunity, account, 'Customer - MSA', Date.today());
        List<Product2> productList = new List<Product2>();
        productList.addAll(util.initProductSet(1, 'Hardware', '', 'Fixed Price', 'Once'));
        productList.addAll(util.initProductSet(1, 'Software', 'Service Plans', 'EOBR Fixed Price', 'Monthly'));
        productList.addAll(util.initProductSet(1, 'Software', 'Applications', 'EOBR Fixed Price', 'Monthly'));
        Map<Id, PricebookEntry> pricebookEntries = new Map<Id, PricebookEntry>();
        pricebookEntries = util.initPricebook(productList);
        SBQQ__Quote__c sbQuote = util.createSBQuote(opportunity, account, Date.today(), true);
        sbQuote.SBQQ__Status__c = 'Signed';
        update sbQuote;
        contract.SBQQ__Quote__c = sbQuote.Id;
        update contract;
        List<SBQQ__Quoteline__c> sbQuoteLines = util.createSBQuoteLines(sbQuote, pricebookEntries, true, 10);

        opportunity.SBQQ__PrimaryQuote__c = sbQuote.Id;
        opportunity.Contract__c = contract.Id;
   
        Test.startTest();
        opportunity = util.closeWonOpportunity(opportunity);
        Test.stopTest();
    }    
}