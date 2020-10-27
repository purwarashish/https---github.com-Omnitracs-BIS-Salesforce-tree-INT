@isTest(seealldata=true)
public class DocumentGenerationSelectionConTest {
    public static VistaAssetHelperUtil util = new VistaAssetHelperUtil();

    @isTest 
    static void positiveTest() {
        
        test.starttest();
        
            Account account = util.createAccount('ABC Test Account');
            Contract ctrct = TestUtils.getContract(account);
            ctrct.Contract_Type__c='Asset Acquisition';
            ctrct.Contract_Category_1__c='Acquired Legacy';
            ctrct.Contract_Category_2__c='Data Sharing';
            ctrct.status='Active';
            insert ctrct;
            List<Product2> productList = new List<Product2>();
            //subPricingType = 'Fixed Price' or 'Percent Of Total'
            productList.addAll(util.initProductSet(1, 'Hardware', '', 'Fixed Price', 'Once'));
            productList.addAll(util.initProductSet(1, 'Software', 'Service Plans', 'Fixed Price', 'Monthly'));
            productList.addAll(util.initProductSet(1, 'Software', 'Applications', 'Fixed Price', 'Monthly'));
            productList.addAll(util.initProductSet(1, 'Software', 'Other', 'Fixed Price', 'Monthly'));
            Map<Id, PricebookEntry> pricebookEntries = new Map<Id, PricebookEntry>();
            pricebookEntries = util.initPricebook(productList);
            Opportunity opportunity = util.createNewOpportunity('Test Opportunity 1', account, 'Products, Services and Maintenance', 'New');
            SBQQ__Quote__c qu = util.createSBQuote(opportunity, account, Date.today(), true);
            List<SBQQ__Quoteline__c> ql = util.createSBQuoteLines(qu, pricebookEntries, false, 2);
        test.stoptest();
        
        PageReference pageRef = Page.DocumentGenerationSelection;
        pageRef.getParameters().put('quoteid', qu.id);
        Test.setCurrentPage(pageRef);
        DocumentGenerationSelectionController ssa = new DocumentGenerationSelectionController();
        ssa.generateOptions='j';
        ssa.test();
        ssa.runDocumentationGeneration();
        Set<String> docSet = new Set<String>{'Hi','Hello'};
        List<String> listAttachments = new List<String>{'Hi','Hello'};
        ssa.buildWorkflowXML(docSet,listAttachments);
        ssa.buildWorkflowXML('SBQQ__Quote__c',docSet,listAttachments);
        ssa.doCancel();
        ssa.refreshForm();
        ssa.getAttachmentItems();
        ssa.getFolderOptions('/Salesforce/Accounts/{!SBQQ__Account__r.Name}/Opportunities/{!SBQQ__Opportunity2__r.Name}/Quotes');
        ssa.getDeliveryMethodItems();
        ssa.getGenerateOptionItems();
        ssa.getLanguages();
        ssa.getEOSObject('SBQQ__Quote__c');
        ssa.getActiveContracts();
        //SBQQ__QuoteLine__c ql = [select id from SBQQ__QuoteLine__c limit 1 ];
        Product_Contract_Template__c pct = new Product_Contract_Template__c(Agreement_Type__c='Master',
            Status__c='Active', Description__c='khkk', Contract_Category_1__c='IVG'
        );
        
        insert pct;
        ssa.getDocumentTemplateName(ql[0],pct);
    
    }   
    @isTest
    static void negativeTest() {
        Test.startTest();
		Account account = util.createAccount('ABC Test Account');
		Contract ctrct = TestUtils.getContract(account);
		ctrct.Contract_Type__c='Asset Acquisition';
		ctrct.Contract_Category_1__c='Acquired Legacy';
		ctrct.Contract_Category_2__c='Data Sharing';
		ctrct.status='Active';
		insert ctrct;
		List<Product2> productList = new List<Product2>();
		//subPricingType = 'Fixed Price' or 'Percent Of Total'
		productList.addAll(util.initProductSet(1, 'Hardware', '', 'Fixed Price', 'Once'));
		productList.addAll(util.initProductSet(1, 'Software', 'Service Plans', 'Fixed Price', 'Monthly'));
		productList.addAll(util.initProductSet(1, 'Software', 'Applications', 'Fixed Price', 'Monthly'));
		productList.addAll(util.initProductSet(1, 'Software', 'Other', 'Fixed Price', 'Monthly'));
		Map<Id, PricebookEntry> pricebookEntries = new Map<Id, PricebookEntry>();
		pricebookEntries = util.initPricebook(productList);
		Opportunity opportunity = util.createNewOpportunity('Test Opportunity 1', account, 'Products, Services and Maintenance', 'New');
		SBQQ__Quote__c qu = util.createSBQuote(opportunity, account, Date.today(), true);
		List<SBQQ__Quoteline__c> ql = util.createSBQuoteLines(qu, pricebookEntries, false, 2);
		contact co = new contact(lastname='dasd',accountid=account.id,email='test@adsa.com');
		insert co;
        Test.stopTest();
        PageReference pageRef = Page.DocumentGenerationSelection;
        pageRef.getParameters().put('quoteid', qu.id);
        Test.setCurrentPage(pageRef);
        DocumentGenerationSelectionController ssa = new DocumentGenerationSelectionController();
        ssa.generateOptions='j';
        ssa.test();
        
        ssa.runDocumentationGeneration();
        Set<String> docSet = new Set<String>{'Hi','Hello'};
        List<String> listAttachments = new List<String>{'Hi','Hello'};
        
        ssa.deliveryMethods=new List<string>{'hjhj'};
        
        ssa.getFolderOptions('/Salesforce/Accounts/{!SBQQ__Account__r.Name}/Opportunities/{!SBQQ__Opportunity2__r.Name}/Quotes');
        ssa.getDeliveryMethodItems();
        ssa.getGenerateOptionItems();
        ssa.getLanguages();
        ssa.getEOSObject('SBQQ__Quote__c');
        ssa.getActiveContracts();
        Product_Contract_Template__c pct = new Product_Contract_Template__c(Agreement_Type__c='Master',
            Status__c = 'Active', Description__c='khkk', Contract_Category_1__c='IVG'
        );
        
        insert pct;
        ssa.getDocumentTemplateName(ql[0],pct);
        
        contact cc = co;
        ssa.contactMap.put(cc.id, cc);
        ssa.selectedLanguage = 'French';
        ssa.getActiveContracts();
    
    }     
}