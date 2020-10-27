@isTest // By ARMAN: (SeeAllData=true)
public class TxnLogBatchSchedulerTest {
	
	public static VistaAssetHelperUtil util = new VistaAssetHelperUtil();

	@testSetup
	static void SetupData() {
		TestUtils.defineCustomSettings();
	}

    static testMethod void myUnitTest() {
		System.debug('TxnLogBatchSchedulerTest 1');
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
		sbQuote.SBQQ__Status__c = 'Signed';
		update sbQuote;
		contract.SBQQ__Quote__c = sbQuote.Id;
        update contract;
        List<SBQQ__Quoteline__c> sbQuoteLines = util.createSBQuoteLines(sbQuote, pricebookEntries, true, 0);
		/*Asset asset = util.createSFDCAsset(sbQuoteLines[0], account);
        asset.Contract__c = contract.Id;
        update asset;*/


        opportunity.SBQQ__PrimaryQuote__c = sbQuote.Id;
		opportunity.Contract__c = contract.Id;
		opportunity = util.closeWonOpportunity(opportunity);

		System.debug('TxnLogBatchSchedulerTest 2');
		Customer_Asset__c custAst = new Customer_Asset__c(Name = 'Test Asset', Account__c = account.Id, Product__c = productList[0].Id, CurrencyIsoCode = 'USD',
				/*Total_One_Time_Fee_s__c = 100.0,*/  Oracle_Id__c = 'MK-TEST-10', Contract__c = contract.Id, Quantity__c = 10.0, Consumed_Quantity__c = 10.0,
				Term_Start_Date__c = System.today());
		insert custAst;
		List<TXN_Log__c> txnLogList = new List<TXN_Log__c>();
		System.debug('TxnLogBatchSchedulerTest 3');
		txnLogList.add(new TXN_Log__c(Account_Cust_ID__c = account.QWBS_Cust_ID__c, Quantity__c = 10.0, Item_SKU_Product_Id__c = 'MK-TEST-10', Source_System__c = 'ERP', Event__c = 'ERP_SHIPMENT', Reference_Id__c = 'MANUAL_001', IsProcessed__c = false));
		txnLogList.add(new TXN_Log__c(Account_Cust_ID__c = account.QWBS_Cust_ID__c, Quantity__c = 10.0, Item_SKU_Product_Id__c = 'MK-TEST-10', Source_System__c = 'ERP', Event__c = 'BILLING_ES_PLANS', Reference_Id__c = 'MANUAL_003', IsProcessed__c = false));
		txnLogList.add(new TXN_Log__c(Account_Cust_ID__c = account.QWBS_Cust_ID__c, Quantity__c = 10.0, Item_SKU_Product_Id__c = 'MK-TEST-11', Source_System__c = 'ERP', Event__c = 'BILLING_ES_PLANS', Reference_Id__c = 'MANUAL_002', IsProcessed__c = false));
		txnLogList.add(new TXN_Log__c(Account_Cust_ID__c = account.QWBS_Cust_ID__c, Quantity__c = 10.0, Item_SKU_Product_Id__c = 'MK-TEST-10', Source_System__c = 'ERP', Event__c = 'BILLING_ES_APPS', Reference_Id__c = 'MANUAL_004', IsProcessed__c = false));
		insert txnLogList;
		
		Test.startTest();
		System.debug('TxnLogBatchSchedulerTest 4');
        TxnLogScheduler tls = new TxnLogScheduler();
		tls.execute(null);
		QuoteReader qr = new QuoteReader();
		QuoteModel quoteModel = qr.read(String.valueOf(sbQuote.Id));		
		QuoteSaverCallback qsb = new QuoteSaverCallback();
		qsb.callback(JSON.serialize(quoteModel));
		QuoteCalculator calculator = new QuoteCalculator();
		calculator.calculate(quoteModel, 'QuoteSaverCallback');
		QuoteSaver qs = new QuoteSaver();
		qs.save(quoteModel);
		ContractAmender amender = new ContractAmender();
		amender.load(String.valueOf(contract.Id), null);
        Test.stopTest();
    }
}