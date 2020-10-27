/**
 * Created by CrutchfieldJody on 11/30/2016.
 */
@isTest
class CustomerAssetHandlerTest {

    static VistaAssetHelperUtil util = new VistaAssetHelperUtil();

    @testSetup
    static void SetupData() {
        TestUtils.defineCustomSettings();
    }

    static testMethod void updateAssetContractsTest_XRS() {
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
        opportunity.Product_name__c = 'XRS';  // Test ProcessBuilder: Eval Conversion Email Notification
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

        Test.startTest();
//        List<Customer_Asset__c> extendedAssetList = getExistingCustomerAssets(100);
        CustomerAssetHandler.updateAssetContracts(customerAssetList);
        Test.stopTest();
    }

    static testMethod void updateAssetContractsTest() {
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

        Test.startTest();
//        List<Customer_Asset__c> extendedAssetList = getExistingCustomerAssets(100);
        CustomerAssetHandler.updateAssetContracts(customerAssetList);
        Test.stopTest();
    }

    static testMethod void updateCustomerAssetContractsTest() {
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
        List<OpportunityLineItem> opportunityLineItems = util.createOppLineItems(opportunity, sbQuoteLines, pricebookEntries);
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

        Test.startTest();
        List<Customer_Asset__c> extendedAssetList = getExistingCustomerAssets(100);
        CustomerAssetHandler.updateCustomerAssetContracts(extendedAssetList);
        Test.stopTest();
    }
    
    static testMethod void relateToSpringCMContractsTest() {
        insert new ByPassTrigger__c(SetupOwnerId=UserInfo.getOrganizationId(), isDisabled__c=true, Name='Testing Bypass');

        CustomerAssetHandler.debug = true;

        Account account = util.createAccount('ABC Test Account');
        System.debug('-- account = '+account);

        Contract contract = util.createContract(null, account, 'Customer - MSA', Date.today());
        contract.Status = 'Active'; // Important
        update contract;
        System.debug('-- contract = '+contract);

        Contract_Additional_Parties__c conAddP = new Contract_Additional_Parties__c(
                Additional_Company__c = account.Id,
                Party_Effective_Date__c = date.today(),
                Party_Expiration_Date__c = date.today()+2,
                Party_Relation_Description__c = 'Test',
                Party_Relation_Type__c = 'Affiliate',
                Relationship_Status__c = 'Active',
                Contract__c = contract.id
        );
        insert conAddP;
        System.debug('-- conAddP = '+conAddP);

        List<Product2> productList = new List<Product2>();
        //subPricingType = 'Fixed Price' or 'Percent Of Total'
        productList.addAll(util.initProductSet(100, 'Hardware', '', 'Fixed Price', 'Monthly'));

        for (Integer i = 0; i < productList.size(); i++) {
            Product2 product = productList[i];
            if (i == 0) {
                product.ProductCode = 'MCP110-WR';
            }
            else if (i == 1) {
                product.ProductCode = '64-JB416-1051';

            }
            else if (i == 2) {
                product.ProductCode = 'MCP110-SUB-UVP';
                Product_Contract_Template__c pct = new Product_Contract_Template__c();
                pct.Name = 'MCP110 Schedule (UVP)';
                pct.Description__c = 'Schedule for the purchase of Mobile Computing Platform 110 Series hardware with UVP Service Plan.';
                pct.Agreement_Type__c = 'Schedule';
                pct.Contract_Category_1__c = 'MCP110 (UVP)';
                pct.Contract_Category_2__c = 'Production';
                pct.Status__c = 'Active';
                pct.Contract_Template_Id__c = '01550000001zESi';
                pct.Legal_Entity_Name__c = '';
                pct.Template_Type__c = 'Output Schedule Template';
                insert pct;

                product.Output_Schedule_Document_Template__r = pct;
                product.Output_Schedule_Document_Template__c = pct.Id;
            }
            else if (i == 3) {
                product.ProductCode = 'SYLECTUS-WR';
            }
            else if (i == 4) {
                product.ProductCode = '20090245';
                Product_Contract_Template__c pct = new Product_Contract_Template__c();
                pct.Name = 'Sylectus Subscription Schedule';
                pct.Description__c = 'Schedule for Sylectus Subscriptions';
                pct.Agreement_Type__c = 'Schedule';
                pct.Contract_Category_1__c = 'Sylectus';
                pct.Contract_Category_2__c = '';
                pct.Status__c = 'Active';
                pct.Contract_Template_Id__c = '0155B0000004qan';
                pct.Legal_Entity_Name__c = 'Omnitracs Canada, Inc.';
                pct.Template_Type__c = 'Output Schedule Template';
                insert pct;

                product.Output_Schedule_Document_Template__r = pct;
                product.Output_Schedule_Document_Template__c = pct.Id;
            }
        }

        update productList;

        Map<Id, PricebookEntry> pricebookEntries = new Map<Id, PricebookEntry>();
        pricebookEntries = util.initPricebook(productList);
        Opportunity opportunity = util.createNewOpportunity('Test Opportunity 1 Decom', account, 'Products, Services and Maintenance', 'New');
        SBQQ__Quote__c sbQuote = util.createSBQuote(opportunity, account, Date.today(), true);
        List<SBQQ__Quoteline__c> sbQuoteLines = util.createSBQuoteLines(sbQuote, pricebookEntries, true, 0);

        sbQuoteLines[1].SBQQ__RequiredBy__c = sbQuoteLines[0].Id;
        sbQuoteLines[1].Product_Type__c = 'Hardware';
        sbQuoteLines[2].SBQQ__RequiredBy__c = sbQuoteLines[0].Id;
        sbQuoteLines[2].Product_Type__c = 'Software';

        sbQuoteLines[4].SBQQ__RequiredBy__c = sbQuoteLines[3].Id;

        for (SBQQ__QuoteLine__c quoteLine : sbQuoteLines) {
            for (Product2 product : productList) {
                if (product.Id == quoteLine.SBQQ__Product__c) {
                    quoteLine.SBQQ__Product__r = product;
                    quoteLine.SBQQ__Product__c = product.Id;
                    break;
                }
            }
        }

        update sbQuoteLines;

        List<OpportunityLineItem> opportunityLineItems = util.createOppLineItems(opportunity, sbQuoteLines, pricebookEntries);
        opportunity = util.closeWonOpportunity(opportunity);
        List<SBQQ__Subscription__c> subscriptionList = util.createSubscriptions(sbQuoteLines, contract, account, null, null);

        Integer subCount = 0;
        for (SBQQ__Subscription__c subscription : subscriptionList) {
            for (SBQQ__QuoteLine__c quoteLine : sbQuoteLines) {
                if (quoteLine.SBQQ__Product__c == subscription.SBQQ__Product__c) {
                    subscription.SBQQ__QuoteLine__r = quoteLine;
                    break;
                }

                if (subCount == 0) {
                    quoteLine.SBQQ__Quote__r = sbQuote;
                    System.debug('-- subCount: QuoteLine = '+quoteLine);
                }
                subCount++;
            }
        }
        update subscriptionList;
        System.debug('-- subscriptionList = '+subscriptionList);

        List<Customer_Asset__c> customerAssetList = new List<Customer_Asset__c>();
        for (SBQQ__Subscription__c subscription : subscriptionList) {
            Customer_Asset__c customerAsset = new Customer_Asset__c();
            customerAsset.Account__c = subscription.SBQQ__Account__c;
            customerAsset.Steelbrick_Subscription__r = subscription;
            customerAsset.Steelbrick_Subscription__c = subscription.Id;
            customerAsset.Latest_Quote_Line__r = subscription.SBQQ__QuoteLine__r;
            customerAsset.Latest_Quote_Line__c = subscription.SBQQ__QuoteLine__r.Id;
            customerAssetList.add(customerAsset);
        }

        CustomerAssetHandler.bypassTrigger = true;
        insert customerAssetList;
        CustomerAssetHandler.bypassTrigger = false;

        Test.startTest();
//        List<Customer_Asset__c> extendedAssetList = getExistingCustomerAssets(100);
        System.debug('-- customerAssetList = '+customerAssetList);
        CustomerAssetHandler.relateToSpringCMContracts(customerAssetList);
        Test.stopTest();
    }
    
    static List<Customer_Asset__c> getExistingCustomerAssets(Integer queryLimit) {
        List<Customer_Asset__c> extendedAssetList = null;
        if (queryLimit == null) {
            extendedAssetList = [
                    SELECT Id,
                            Account__c,
                            MSA_Document__c,
                            Product_Schedule_Document__c,
                            Eval_Document__c,
                            Eval2_Document__c,
                            Latest_Opportunity__r.Order_Type__c,
                            Latest_Opportunity__r.Order_Sub_Type__c,
                            Contract__c,
                            Steelbrick_Asset__c,
                            Steelbrick_Subscription__c,
                            Latest_Quote_Line__c,
                            Latest_Quote_Line__r.Id,
                            Latest_Quote_Line__r.Product_Type__c,
                            Latest_Quote_Line__r.SBQQ__RequiredBy__c,
                            Latest_Quote_Line__r.SBQQ__RequiredBy__r.SBQQ__ProductCode__c,
                            Latest_Quote_Line__r.SBQQ__Product__r.Id,
                            Latest_Quote_Line__r.SBQQ__Product__r.Output_MSA_Document_Template__r.Contract_Category_1__c,
                            Latest_Quote_Line__r.SBQQ__Product__r.Output_MSA_Document_Template__r.Contract_Category_2__c,
                            Latest_Quote_Line__r.SBQQ__Product__r.Output_MSA_Document_Template__r.Agreement_Type__c,
                            Latest_Quote_Line__r.SBQQ__Product__r.Output_MSA_Document_Template__r.Legal_Entity_Name__c,
                            Latest_Quote_Line__r.SBQQ__Product__r.Output_MSA_Document_Template__r.Status__c,
                            Latest_Quote_Line__r.SBQQ__Product__r.Output_Schedule_Document_Template__r.Contract_Category_1__c,
                            Latest_Quote_Line__r.SBQQ__Product__r.Output_Schedule_Document_Template__r.Contract_Category_2__c,
                            Latest_Quote_Line__r.SBQQ__Product__r.Output_Schedule_Document_Template__r.Agreement_Type__c,
                            Latest_Quote_Line__r.SBQQ__Product__r.Output_Schedule_Document_Template__r.Legal_Entity_Name__c,
                            Latest_Quote_Line__r.SBQQ__Product__r.Output_Schedule_Document_Template__r.Status__c,
                            Latest_Quote_Line__r.SBQQ__Product__r.Output_Eval_Document_Template__r.Contract_Category_1__c,
                            Latest_Quote_Line__r.SBQQ__Product__r.Output_Eval_Document_Template__r.Contract_Category_2__c,
                            Latest_Quote_Line__r.SBQQ__Product__r.Output_Eval_Document_Template__r.Agreement_Type__c,
                            Latest_Quote_Line__r.SBQQ__Product__r.Output_Eval_Document_Template__r.Legal_Entity_Name__c,
                            Latest_Quote_Line__r.SBQQ__Product__r.Output_Eval_Document_Template__r.Status__c,
                            Latest_Quote_Line__r.SBQQ__Product__r.Output_Eval2_Document_Template__r.Contract_Category_1__c,
                            Latest_Quote_Line__r.SBQQ__Product__r.Output_Eval2_Document_Template__r.Contract_Category_2__c,
                            Latest_Quote_Line__r.SBQQ__Product__r.Output_Eval2_Document_Template__r.Agreement_Type__c,
                            Latest_Quote_Line__r.SBQQ__Product__r.Output_Eval2_Document_Template__r.Legal_Entity_Name__c,
                            Latest_Quote_Line__r.SBQQ__Product__r.Output_Eval2_Document_Template__r.Status__c,
                            Latest_Quote_Line__r.SBQQ__Quote__c,
                            Latest_Quote_Line__r.SBQQ__Quote__r.Id
                    FROM Customer_Asset__c
            ];
        }
        else {
            extendedAssetList = [
                    SELECT Id,
                            Account__c,
                            MSA_Document__c,
                            Product_Schedule_Document__c,
                            Eval_Document__c,
                            Eval2_Document__c,
                            Latest_Opportunity__r.Order_Type__c,
                            Latest_Opportunity__r.Order_Sub_Type__c,
                            Contract__c,
                            Steelbrick_Asset__c,
                            Steelbrick_Subscription__c,
                            Latest_Quote_Line__c,
                            Latest_Quote_Line__r.Id,
                            Latest_Quote_Line__r.Product_Type__c,
                            Latest_Quote_Line__r.SBQQ__RequiredBy__c,
                            Latest_Quote_Line__r.SBQQ__RequiredBy__r.SBQQ__ProductCode__c,
                            Latest_Quote_Line__r.SBQQ__Product__r.Id,
                            Latest_Quote_Line__r.SBQQ__Product__r.Output_MSA_Document_Template__r.Contract_Category_1__c,
                            Latest_Quote_Line__r.SBQQ__Product__r.Output_MSA_Document_Template__r.Contract_Category_2__c,
                            Latest_Quote_Line__r.SBQQ__Product__r.Output_MSA_Document_Template__r.Agreement_Type__c,
                            Latest_Quote_Line__r.SBQQ__Product__r.Output_MSA_Document_Template__r.Legal_Entity_Name__c,
                            Latest_Quote_Line__r.SBQQ__Product__r.Output_MSA_Document_Template__r.Status__c,
                            Latest_Quote_Line__r.SBQQ__Product__r.Output_Schedule_Document_Template__r.Contract_Category_1__c,
                            Latest_Quote_Line__r.SBQQ__Product__r.Output_Schedule_Document_Template__r.Contract_Category_2__c,
                            Latest_Quote_Line__r.SBQQ__Product__r.Output_Schedule_Document_Template__r.Agreement_Type__c,
                            Latest_Quote_Line__r.SBQQ__Product__r.Output_Schedule_Document_Template__r.Legal_Entity_Name__c,
                            Latest_Quote_Line__r.SBQQ__Product__r.Output_Schedule_Document_Template__r.Status__c,
                            Latest_Quote_Line__r.SBQQ__Product__r.Output_Eval_Document_Template__r.Contract_Category_1__c,
                            Latest_Quote_Line__r.SBQQ__Product__r.Output_Eval_Document_Template__r.Contract_Category_2__c,
                            Latest_Quote_Line__r.SBQQ__Product__r.Output_Eval_Document_Template__r.Agreement_Type__c,
                            Latest_Quote_Line__r.SBQQ__Product__r.Output_Eval_Document_Template__r.Legal_Entity_Name__c,
                            Latest_Quote_Line__r.SBQQ__Product__r.Output_Eval_Document_Template__r.Status__c,
                            Latest_Quote_Line__r.SBQQ__Product__r.Output_Eval2_Document_Template__r.Contract_Category_1__c,
                            Latest_Quote_Line__r.SBQQ__Product__r.Output_Eval2_Document_Template__r.Contract_Category_2__c,
                            Latest_Quote_Line__r.SBQQ__Product__r.Output_Eval2_Document_Template__r.Agreement_Type__c,
                            Latest_Quote_Line__r.SBQQ__Product__r.Output_Eval2_Document_Template__r.Legal_Entity_Name__c,
                            Latest_Quote_Line__r.SBQQ__Product__r.Output_Eval2_Document_Template__r.Status__c,
                            Latest_Quote_Line__r.SBQQ__Quote__c,
                            Latest_Quote_Line__r.SBQQ__Quote__r.Id
                    FROM Customer_Asset__c
                    LIMIT :queryLimit
            ];
        }

        return extendedAssetList;
    }
    
    static testMethod void createShippingScheduleTest() {
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
        List<OpportunityLineItem> opportunityLineItems = util.createOppLineItems(opportunity, sbQuoteLines, pricebookEntries);
        opportunity = util.closeWonOpportunity(opportunity);
        List<SBQQ__Subscription__c> subscriptionList = util.createSubscriptions(sbQuoteLines, contract, account, null, null);

        Test.startTest();
//        List<Customer_Asset__c> custAssetList = setupCustomerAssets();
        List<Customer_Asset__c> custAssetList = getExistingCustomerAssets(25);
        System.debug('1218: custAssetList: ' + custAssetList);

        CustomerAssetHandler.createShippingSchedule(custAssetList);

        Test.stopTest();
    }
    
    static testMethod void createShippingScheduleTest_SetupCustomerAssets() { // ARMAN SHAH
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
        List<OpportunityLineItem> opportunityLineItems = util.createOppLineItems(opportunity, sbQuoteLines, pricebookEntries);
        opportunity = util.closeWonOpportunity(opportunity);
        List<SBQQ__Subscription__c> subscriptionList = util.createSubscriptions(sbQuoteLines, contract, account, null, null);

        List<Customer_Asset__c> custAssetList = setupCustomerAssets();
        System.debug('-- custAssetList: ' + custAssetList);

        Test.startTest();
        CustomerAssetHandler.createShippingSchedule(custAssetList);
        Test.stopTest();
    }
    
    static List<Customer_Asset__c> setupCustomerAssets() {
        Account account = util.createAccount('ABC Test Account');
        Contract msa = util.createContract(null, account, 'Customer - MSA', Date.today());
        List<Product2> productList = new List<Product2>();
        //subPricingType = 'Fixed Price' or 'Percent Of Total'
        productList.addAll(util.initProductSet(1, 'Hardware', null, null));
        Map<Id, PricebookEntry> pricebookEntries = new Map<Id, PricebookEntry>();
        pricebookEntries = util.initPricebook(productList);
        Opportunity opportunity = util.createNewOpportunity('Test Opportunity 1', account, 'Products, Services and Maintenance', 'New');
        SBQQ__Quote__c sbQuote = util.createSBQuote(opportunity, account, Date.today(), true);
        List<SBQQ__Quoteline__c> sbQuoteLines = util.createSBQuoteLines(sbQuote, pricebookEntries, false, 2);
        SBQQ__Quoteline__c sbQuoteLine = sbQuoteLines.get(0);
        SBQQ__QuoteLineGroup__c qlg = new SBQQ__QuoteLineGroup__c();
        qlg.Name = 'Group 1';
        qlg.SBQQ__Number__c = 1;
        qlg.SBQQ__Account__c = account.Id;
        qlg.SBQQ__Quote__c = sbQuote.Id;
        insert qlg;

        sbQuoteLine.SBQQ__Group__c = qlg.Id;
        update sbQuoteLine;

        /* ARMAN: Shipping_Estimate_Summary__c ses = new Shipping_Estimate_Summary__c();
        ses.Quote_Line_Group__c = qlg.Id;
        insert ses;

        List<Shipping_Estimate__c> seList = new List<Shipping_Estimate__c>();
        Shipping_Estimate__c se1 = new Shipping_Estimate__c();
        se1.Estimated_Shipping_Date__c = System.today().addDays(3);
        se1.Estimated_Shipping_Quantity__c = 10;
        se1.Shipping_Summary__c = ses.Id;
        seList.add(se1);

        Shipping_Estimate__c se2 = new Shipping_Estimate__c();
        se2.Estimated_Shipping_Date__c = System.today().addDays(3);
        se2.Estimated_Shipping_Quantity__c = 10;
        se2.Shipping_Summary__c = ses.Id;
        seList.add(se2);

        Shipping_Estimate__c se3 = new Shipping_Estimate__c();
        se3.Estimated_Shipping_Date__c = System.today().addDays(5);
        se3.Estimated_Shipping_Quantity__c = 10;
        se3.Shipping_Summary__c = ses.Id;
        seList.add(se3);

        insert seList; */

        Asset newAsset = util.createSFDCAsset(sbQuoteLine, account);
        List<Asset> assetList = new List<Asset>();
        assetList.add(newAsset);
        System.debug('1218: assetList: ' + assetList);

        VistaAssetVAHandler.handleAssetsVA(assetList);

        List<Customer_Asset__c> custAssetList = new List<Customer_Asset__c>();

        custAssetList = [SELECT
        // vista asset fields
                Id, Name, Account__c, Product__c, Description__c, Contract__c
                , Term_Start_Date__c, Term_End_Date__c, Asset_Status__c, Quantity__c
                , Annual_Recurring_Revenue__c, Steelbrick_Subscription__c, Steelbrick_Asset__c
                // subscribed asset fields
                , Steelbrick_Asset__r.SBQQ__CurrentSubscription__c, Steelbrick_Asset__r.Price
                // subscribed asset subscription fields
                , Steelbrick_Asset__r.SBQQ__CurrentSubscription__r.SBQQ__QuoteLine__r.SBQQ__Quantity__c
                , Steelbrick_Asset__r.SBQQ__CurrentSubscription__r.SBQQ__NetPrice__c
                , Steelbrick_Asset__r.SBQQ__CurrentSubscription__r.CurrencyIsoCode
                , Steelbrick_Asset__r.SBQQ__CurrentSubscription__r.Annual_Recurring_Revenue__c
                , Steelbrick_Asset__r.Quantity, Steelbrick_Asset__r.Annual_Recurring_Revenue__c
                , Steelbrick_Asset__r.CurrencyIsoCode,
                MSA_Document__c,
                Product_Schedule_Document__c,
                Eval_Document__c,
                Eval2_Document__c,
                Latest_Opportunity__r.Order_Type__c,
                Latest_Opportunity__r.Order_Sub_Type__c,
                Latest_Quote_Line__r.Id,
                Latest_Quote_Line__r.Product_Type__c,
                Latest_Quote_Line__r.SBQQ__RequiredBy__c,
                Latest_Quote_Line__r.SBQQ__RequiredBy__r.SBQQ__ProductCode__c,
                Latest_Quote_Line__r.SBQQ__Product__r.Id,
                Latest_Quote_Line__r.SBQQ__Product__r.Output_MSA_Document_Template__r.Contract_Category_1__c,
                Latest_Quote_Line__r.SBQQ__Product__r.Output_MSA_Document_Template__r.Contract_Category_2__c,
                Latest_Quote_Line__r.SBQQ__Product__r.Output_MSA_Document_Template__r.Agreement_Type__c,
                Latest_Quote_Line__r.SBQQ__Product__r.Output_MSA_Document_Template__r.Legal_Entity_Name__c,
                Latest_Quote_Line__r.SBQQ__Product__r.Output_MSA_Document_Template__r.Status__c,
                Latest_Quote_Line__r.SBQQ__Product__r.Output_Schedule_Document_Template__r.Contract_Category_1__c,
                Latest_Quote_Line__r.SBQQ__Product__r.Output_Schedule_Document_Template__r.Contract_Category_2__c,
                Latest_Quote_Line__r.SBQQ__Product__r.Output_Schedule_Document_Template__r.Agreement_Type__c,
                Latest_Quote_Line__r.SBQQ__Product__r.Output_Schedule_Document_Template__r.Legal_Entity_Name__c,
                Latest_Quote_Line__r.SBQQ__Product__r.Output_Schedule_Document_Template__r.Status__c,
                Latest_Quote_Line__r.SBQQ__Product__r.Output_Eval_Document_Template__r.Contract_Category_1__c,
                Latest_Quote_Line__r.SBQQ__Product__r.Output_Eval_Document_Template__r.Contract_Category_2__c,
                Latest_Quote_Line__r.SBQQ__Product__r.Output_Eval_Document_Template__r.Agreement_Type__c,
                Latest_Quote_Line__r.SBQQ__Product__r.Output_Eval_Document_Template__r.Legal_Entity_Name__c,
                Latest_Quote_Line__r.SBQQ__Product__r.Output_Eval_Document_Template__r.Status__c,
                Latest_Quote_Line__r.SBQQ__Product__r.Output_Eval2_Document_Template__r.Contract_Category_1__c,
                Latest_Quote_Line__r.SBQQ__Product__r.Output_Eval2_Document_Template__r.Contract_Category_2__c,
                Latest_Quote_Line__r.SBQQ__Product__r.Output_Eval2_Document_Template__r.Agreement_Type__c,
                Latest_Quote_Line__r.SBQQ__Product__r.Output_Eval2_Document_Template__r.Legal_Entity_Name__c,
                Latest_Quote_Line__r.SBQQ__Product__r.Output_Eval2_Document_Template__r.Status__c,
                Latest_Quote_Line__r.SBQQ__Quote__r.Id,
                Latest_Quote_Line__r.SBQQ__Quote__r.SBQQ__Account__c
        FROM Customer_Asset__c WHERE Steelbrick_Asset__c IN :assetList];

        return custAssetList;
    }

    ////////////////////////////////////////////////////////////////////////////
    // Created by: Arman Shah
    // CreateDate: 8/27/2018
    ////////////////////////////////////////////////////////////////////////////
    
    static testMethod void setContractOnAssetAndCustomerAssetTest() {
        System.debug('-- START setContractOnAssetAndCustomerAssetTest --');

        insert new ByPassTrigger__c(SetupOwnerId=UserInfo.getOrganizationId(), isDisabled__c=true, 
            Name='Testing CustomerAssetTrigger Bypass');

        Account account = util.createAccount('ABC Test Account');
        //Contract contract = util.createContract(null, account, 'Customer - MSA', Date.today());
        
        List<Product2> productList = new List<Product2>();
        //subPricingType = 'Fixed Price' or 'Percent Of Total'
        productList.addAll(util.initProductSet(100, 'Hardware', '', 'Fixed Price', 'Monthly'));
        Map<Id, PricebookEntry> pricebookEntries = new Map<Id, PricebookEntry>();
        pricebookEntries = util.initPricebook(productList);
        
        Opportunity opportunity = util.createNewOpportunity('Test Opportunity 1 Decom', account, 
            'Products, Services and Maintenance', 'New');
        System.debug('-- opportunity INIT ='+opportunity);

        Contract contract = util.createContract(opportunity, account, 'Customer - MSA', Date.today());
        System.debug('-- contract = '+contract);

        SBQQ__Quote__c sbQuote = util.createSBQuote(opportunity, account, Date.today(), true);
        opportunity.SBQQ__PrimaryQuote__c = sbQuote.Id;

        List<SBQQ__Quoteline__c> sbQuoteLines = 
            util.createSBQuoteLines(sbQuote, pricebookEntries, true, 0);
        
        List<OpportunityLineItem> opportunityLineItems = 
            util.createOppLineItems(opportunity, sbQuoteLines, pricebookEntries);

        contract.SBQQ__Quote__c = sbQuote.Id;
        update contract;

        opportunity.Contract__c = contract.Id; //NOTE: a ClosedWon Opp does NOT automatically create a new Contract
        opportunity = util.closeWonOpportunity(opportunity);
        System.debug('-- opportunity Upon util.ClosedWon = '+opportunity);
    
        Opportunity oppClosedWon = 
            [SELECT Id, StageName, SBQQ__PrimaryQuote__c, Contract__c 
             FROM Opportunity 
             WHERE Id =: opportunity.Id];
        System.debug('-- opp AFTER ClosedWon = '+oppClosedWon);
        
        List<SBQQ__Subscription__c> subscriptionList = 
            util.createSubscriptions(sbQuoteLines, contract, account, null, null);
        System.debug('-- subscriptionList = '+subscriptionList);

        List<Customer_Asset__c> customerAssetList = new List<Customer_Asset__c>();
        for (SBQQ__Subscription__c subscription : subscriptionList) {
            Customer_Asset__c customerAsset = new Customer_Asset__c();
            customerAsset.Account__c = subscription.SBQQ__Account__c;
            customerAsset.Steelbrick_Subscription__r = subscription;
            //customerAsset.Latest_Quote_Line__r = subscription.SBQQ__QuoteLine__r;
            //customerAsset.Latest_Quote_Line__c = subscription.SBQQ__QuoteLine__r.Id;
            customerAsset.Latest_Opportunity__c = opportunity.Id;
            customerAsset.Term_Start_Date__c = System.Today();
            customerAssetList.add(customerAsset);
        }

        Asset newAsset = util.createSFDCAsset(sbQuoteLines[0], account);
        List<Asset> assetList = new List<Asset>();
        assetList.add(newAsset);
        System.debug('-- assetList = ' + assetList);

        customerAssetList[0].Steelbrick_Asset__c = assetList[0].Id;
        System.debug('-- customerAssetList = ' + customerAssetList);

        Test.startTest();
        System.debug('-- START TEST - Create Contract --');
        CustomerAssetHandler.bypassTrigger = true;
        insert customerAssetList;
        List<Customer_Asset__c> cAssetsAfterInsert = [SELECT Id, Contract__c 
            FROM Customer_Asset__c
            WHERE Latest_Opportunity__c =: opportunity.Id LIMIT 1];

        System.debug('-- cAssetsAfterInsert = '+cAssetsAfterInsert);
        //System.assert(cAssetsAfterInsert[0].Contract__c == null);
        //CustomerAssetHandler.bypassTrigger = false;

        List<Customer_Asset__c> extendedAssetList = getExistingCustomerAssets(5);
        System.debug('-- extendedAssetList = '+extendedAssetList);
        CustomerAssetHandler.setContractOnAssetAndCustomerAsset(extendedAssetList);
        CustomerAssetHandler.bypassTrigger = false;

        Test.stopTest();

        // TEST 1 Assertion: Check for a Contract upon Opp ClosedWon for a Quote
        List<Customer_Asset__c> newCustomerAssets = [SELECT Id, Contract__c 
            FROM Customer_Asset__c
            WHERE Latest_Opportunity__c =: opportunity.Id LIMIT 1];
        System.debug('-- newCustomerAssets = '+newCustomerAssets);
        
        List<Opportunity> modOpps = [SELECT Id, Contract__c FROM Opportunity
            WHERE Id =: opportunity.Id LIMIT 1];
        System.debug('-- modOpps = '+modOpps);
        
        System.assertEquals(newCustomerAssets[0].Contract__c, modOpps[0].Contract__c);

        // Check for an AmmendedContract, where Subscription quantities are changed,
        // upon Opp ClosedWon for a Quote
        System.debug('-- START TEST - Amended Contract --');
        opportunity.SBQQ__AmendedContract__c = contract.Id;
        update opportunity;
        System.debug('-- opportunity 1 = '+opportunity);

        CustomerAssetHandler.setContractOnAssetAndCustomerAsset(extendedAssetList);

        // TEST 2 Assertion: Check for a Contract upon Opp ClosedWon for a Quote
        List<Customer_Asset__c> ammendedCustomerAssets = [SELECT Id, Contract__c
            FROM Customer_Asset__c
            WHERE Latest_Opportunity__c =: opportunity.Id];
        System.debug('-- ammendedCustomerAssets = '+ammendedCustomerAssets);
        
        List<Opportunity> amendedOpps = [SELECT Id, Contract__c FROM Opportunity
            WHERE Id =: opportunity.Id Order By Contract__c DESC];
        System.debug('-- amendedOpps = '+amendedOpps);
        
        System.assertNotEquals(ammendedCustomerAssets[0].Contract__c, amendedOpps[0].Contract__c); // CA will have newer Contract

        System.debug('-- END setContractOnAssetAndCustomerAssetTest --');
    }
    
    static testMethod void testGetQuoteProductContractKey_OmittedContractFields() {
        Account account = util.createAccount('ABC Test Account');
        Contract contract = util.createContract(null, account, 'Customer - MSA', Date.today());
        contract.Agreement_Type__c = 'Schedule';
        contract.Contract_Category_1__c = 'MCP110 (UVP)';
        contract.Contract_Category_2__c = 'Production';
        contract.Status = 'Active';
        contract.Legal_Entity_Name__c = 'Test Legal_Entity';
        update contract;

        Test.startTest();
        String qpcKey = CustomerAssetHandler.getQuoteProductContractKey(contract, null);
        Test.stopTest();

        System.debug('-- qpcKey = '+qpcKey);
        System.assert(qpcKey != '');
    }

    static testMethod void testGetQuoteProductContractKey_ContractFields() {
        Account account = util.createAccount('ABC Test Account');
        Contract contract = util.createContract(null, account, 'Customer - MSA', Date.today());
        contract.Agreement_Type__c = 'Schedule';
        contract.Contract_Category_1__c = 'MCP110 (UVP)';
        contract.Contract_Category_2__c = 'Production';
        contract.Status = 'Active';
        contract.Legal_Entity_Name__c = 'Test Legal_Entity';
        update contract;

        Set<String> omittedContractFields = new Set<String>();

        Test.startTest();
        String qpcKey =
                CustomerAssetHandler.getQuoteProductContractKey(contract, omittedContractFields);
        Test.stopTest();
        System.debug('-- qpcKey = '+qpcKey);
        System.assert(qpcKey != '');
    }

    static testMethod void testGetQuoteLineProductContractTemplateKey() {
        // getQuoteLineProductContractTemplateKey(Product_Contract_Template__c QuoteLineProductContractTemplate,
        // Set<String> omittedContractFields)

        Product_Contract_Template__c pct = new Product_Contract_Template__c();
        pct.Name = 'MCP110 Schedule (UVP)';
        pct.Description__c = 'Schedule for the purchase of Mobile Computing Platform 110 Series hardware with UVP Service Plan.';
        pct.Agreement_Type__c = 'Schedule';
        pct.Contract_Category_1__c = 'MCP110 (UVP)';
        pct.Contract_Category_2__c = 'Production';
        pct.Status__c = 'Active';
        pct.Legal_Entity_Name__c = '';
        pct.Template_Type__c = 'Output Schedule Template';
        insert pct;

        Set<String> omittedContractFields = new Set<String>();

        Test.startTest();
        String qlpctKey =
                CustomerAssetHandler.getQuoteLineProductContractTemplateKey(pct,
                        omittedContractFields);
        Test.stopTest();
        System.debug('-- qlpctKey = '+qlpctKey);
        System.assert(qlpctKey != '');
    }
}