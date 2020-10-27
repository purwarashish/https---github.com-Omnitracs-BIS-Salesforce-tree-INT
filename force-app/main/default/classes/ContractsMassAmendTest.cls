@isTest
public class ContractsMassAmendTest {
	
	public static VistaAssetHelperUtil util = new VistaAssetHelperUtil();
	
	@testSetup
	static void SetupData() {
		TestUtils.defineCustomSettings();
		insert new ByPassTrigger__c(SetupOwnerId = UserInfo.getOrganizationId(), isDisabled__c = true, Name = 'Bypass Trigger');
	}

    static testMethod void myUnitTest() {
		System.debug('ContractsMassAmendTest 1');
		Account account = util.createAccount('ABC Test Account');
		account.QWBS_Cust_ID__c = 'Test12345678';
		update account;
		OpportunityTestData opportunityTestData  = new OpportunityTestData();
		List<Contact> contactList =  opportunityTestData.ContactCreation('validateOpptyEditability', 1, account.Id);
        insert contactList;
		PriceBook2 stdPriceBook = TestUtils.getStandardPriceBook(); //opportunityTestData.createPriceBook();
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
		contract.EndDate = Date.today().adddays(365);
		contract.RecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('SteelBrick CPQ Contract').getRecordTypeId();
		contract.SBQQ__Quote__c = sbQuote.Id;
        update contract;
        List<SBQQ__Quoteline__c> sbQuoteLines = util.createSBQuoteLines(sbQuote, pricebookEntries, true, 1);
        opportunity.SBQQ__PrimaryQuote__c = sbQuote.Id;
		opportunity.Contract__c = contract.Id;
		opportunity = util.closeWonOpportunity(opportunity);
        //opportunity.StageName = 'Closed Won';
        //update opportunity;
		System.debug('ContractsMassAmendTest 2');
		
		Test.startTest();
		System.debug('ContractsMassAmendTest 4');
		MassAmendContractController controller = new MassAmendContractController();
		String csvStr = 'ContractNumber,ProductId,Quantity,QuantityType,IsNew,FinalUnitPrice,OptyRecordType,OptyOrderType,OptyOrderSubType,PriceBookId,CurrencyCode,AdditionalDiscount,DiscountType\n' + contract.ContractNumber + ',' + productList[0].Id + ',10,,TRUE,24,,Customer Portal,AddOn,' + stdPriceBook.Id + ',USD,,Final\n';
		Blob csvFileBody = Blob.valueOf(csvStr);
		controller.csvFileBody = csvFileBody;
		controller.readFromFile();
		controller.massAmend();
        Test.stopTest();
    }
}