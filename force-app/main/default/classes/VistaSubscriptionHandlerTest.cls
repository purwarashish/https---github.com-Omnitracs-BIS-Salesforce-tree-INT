@isTest
private class VistaSubscriptionHandlerTest {
    public static VistaAssetHelperUtil util = new VistaAssetHelperUtil();


    @isTest static void subscriptionTriggerTest() {
        System.debug(LoggingLevel.INFO, 'VistaSubscriptionHandlerTest.subscriptionTriggerTest');
        
        List<Product2> productList = new List<Product2>();
        //subPricingType = 'Fixed Price' or 'Percent Of Total'
        productList.addAll(util.initProductSet(1, 'Hardware', '', 'Fixed Price', 'Monthly'));

        Test.startTest();
                SBQQ__Subscription__c sub = new SBQQ__Subscription__c();
                sub.SBQQ__Product__c = productList[0].Id;
                    sub.SBQQ__Quantity__c = 1;
                sub.SBQQ__NetPrice__c = 1.00;
                sub.Annual_Recurring_Revenue__c = 1.00;
                sub.SBQQ__SubscriptionStartDate__c = System.today();
        insert sub;
        
        System.assertEquals(1, sub.SBQQ__Quantity__c);
        
        Test.stopTest();
    }

    @isTest
    static void createNewSubscriptionTestServicePlan() {
        System.debug(LoggingLevel.INFO, 'VistaSubscriptionHandlerTest.createNewSubscriptionTest');
        
        insert new ByPassTrigger__c(SetupOwnerId=UserInfo.getOrganizationId(), isDisabled__c=true, Name='Testing Bypass');
        
        Account account = util.createAccount('ABC Test Account');
        Contract msa = util.createContract(null, account, 'Customer - MSA', Date.today());
        List<Product2> productList = new List<Product2>();
        //subPricingType = 'Fixed Price' or 'Percent Of Total'
        productList.addAll(util.initProductSet(5, 'Software', 'Service Plans', 'Fixed Price', 'Monthly'));
        Map<Id, PricebookEntry> pricebookEntries = new Map<Id, PricebookEntry>();
        pricebookEntries = util.initPricebook(productList);
        Opportunity opportunity = util.createNewOpportunity('Test Opportunity 1', account, 'Products, Services and Maintenance', 'New');
        SBQQ__Quote__c sbQuote = util.createSBQuote(opportunity, account, Date.today(), true);
        List<SBQQ__Quoteline__c> sbQuoteLines = util.createSBQuoteLines(sbQuote, pricebookEntries, false, 2);
        //List<OpportunityLineItem> opportunityLineItems = util.createOppLineItems(opportunity, sbQuoteLines, pricebookEntries);
        opportunity = util.closeWonOpportunity(opportunity);
        Contract contract = util.createContract(opportunity, account, 'SteelBrick CPQ Contract', Date.today());
        List<SBQQ__Subscription__c> subscriptionList = util.createSubscriptions(sbQuoteLines, contract, account, null, null);
        subscriptionList = [SELECT Id, SBQQ__Product__c, SBQQ__ProductName__c, SBQQ__Account__c
                            , SBQQ__Contract__c, SBQQ__Contract__r.EndDate, SBQQ__StartDate__c
                            , SBQQ__EndDate__c, SBQQ__Quantity__c
                            , Subscribed_Asset_Count__c
                            , SBQQ__Product__r.Name, SBQQ__Product__r.Description
                            , SBQQ__NetPrice__c, Annual_Recurring_Revenue__c
                            , SBQQ__RevisedSubscription__c, SBQQ__Contract__r.Master_Term__c
                            , SBQQ__Contract__r.Master_Term_Remaining__c
                            FROM SBQQ__Subscription__c WHERE Id in :subscriptionList];
        
        Test.startTest();
        
        VistaSubscriptionHandler.handleSBSubscriptions(subscriptionList);        
        List<Customer_Asset__c> vistaAssets = [SELECT Id, Name, Account__c, Product__c, Description__c, Contract__c
                                               , Term_Start_Date__c, Term_End_Date__c, Asset_Status__c, Quantity__c
                                               , Annual_Recurring_Revenue__c, Steelbrick_Subscription__c 
                                               FROM Customer_Asset__c WHERE Steelbrick_Subscription__c IN :subscriptionList];
        
        //System.assertEquals(5, vistaAssets.size());
        
        SBQQ__Subscription__c subscription1 = [SELECT Id, SBQQ__Product__c, SBQQ__Account__c, SBQQ__Contract__c, SBQQ__StartDate__c, SBQQ__EndDate__c
                      , SBQQ__NetPrice__c, SBQQ__Product__r.Name, SBQQ__Product__r.Description
                      , SBQQ__Product__r.Generate_Asset__c, Annual_Recurring_Revenue__c
                      , SBQQ__Quantity__c, SBQQ__QuoteLine__r.Id
                      , SBQQ__QuoteLine__r.SBQQ__Existing__c, SBQQ__QuoteLine__r.SBQQ__RenewedSubscription__c, CurrencyIsoCode
                      , SBQQ__QuoteLine__r.SBQQ__Quantity__c, SBQQ__RevisedSubscription__c, SBQQ__Contract__r.Master_Term__c, SBQQ__Contract__r.Master_Term_Remaining__c
                      , Final_Unit_Price__c, SBQQ__Product__r.Default_Billing_Frequency__c
                      FROM SBQQ__Subscription__c WHERE Id = :subscriptionList[0].Id limit 1];
        VistaSubscriptionHandler.createVistaAssetWithoutQuoteLines(subscription1);
        
        Test.stopTest();
    }

    @isTest
    static void updateExistingSubscriptionTest() {
        System.debug(LoggingLevel.INFO, 'VistaSubscriptionHandlerTest.updateExistingSubscriptionTest');
        
        insert new ByPassTrigger__c(SetupOwnerId=UserInfo.getOrganizationId(), isDisabled__c=true, Name='Testing Bypass');
        
        Account account = util.createAccount('ABC Test Account');
        Contract msa = util.createContract(null, account, 'Customer - MSA', Date.today());
        List<Product2> productList = new List<Product2>();
        //subPricingType = 'Fixed Price' or 'Percent Of Total'
        productList.addAll(util.initProductSet(1, 'Hardware', '', 'Fixed Price', 'Monthly'));
        Map<Id, PricebookEntry> pricebookEntries = new Map<Id, PricebookEntry>();
        pricebookEntries = util.initPricebook(productList);
        Opportunity opportunity = util.createNewOpportunity('Test Opportunity 1', account, 'Products, Services and Maintenance', 'New');
        SBQQ__Quote__c sbQuote = util.createSBQuote(opportunity, account, Date.today(), true);
        List<SBQQ__Quoteline__c> sbQuoteLines = util.createSBQuoteLines(sbQuote, pricebookEntries, false, 2);
        //List<OpportunityLineItem> opportunityLineItems = util.createOppLineItems(opportunity, sbQuoteLines, pricebookEntries);
        opportunity = util.closeWonOpportunity(opportunity);
        Contract contract = util.createContract(opportunity, account, 'SteelBrick CPQ Contract', Date.today());
        List<SBQQ__Subscription__c> subscriptionList = util.createSubscriptions(sbQuoteLines, contract, account, null, null);
        subscriptionList = [SELECT Id, SBQQ__Product__c, SBQQ__ProductName__c, SBQQ__Account__c
                            , SBQQ__Contract__c, SBQQ__Contract__r.EndDate, SBQQ__StartDate__c
                            , SBQQ__EndDate__c, SBQQ__Quantity__c
                            , Subscribed_Asset_Count__c
                            , SBQQ__Product__r.Name, SBQQ__Product__r.Description
                            , SBQQ__NetPrice__c, Annual_Recurring_Revenue__c
                            , SBQQ__RevisedSubscription__c
                            FROM SBQQ__Subscription__c WHERE Id in :subscriptionList];
        
        VistaSubscriptionHandler.handleSBSubscriptions(subscriptionList);        
        
        Test.startTest();
        
        List<Customer_Asset__c> vistaAssets = [SELECT Id, Name, Account__c, Product__c, Description__c, Contract__c
                                                    , Term_Start_Date__c, Term_End_Date__c, Asset_Status__c, Quantity__c
                                                    , Annual_Recurring_Revenue__c, Steelbrick_Subscription__c 
                                                    FROM Customer_Asset__c WHERE Steelbrick_Subscription__c IN :subscriptionList];
        //---Step 2--- Create addon subscription
        // subPricingType = 'Fixed Price' or 'Percent Of Total'
        List<Product2> productListAddon = new List<Product2>();
        //subPricingType = 'Fixed Price' or 'Percent Of Total'
        productListAddon.addAll(util.initProductSet(1, 'Hardware', '', 'Fixed Price', 'Monthly'));
        Map<Id, PricebookEntry> pricebookEntriesAddon = new Map<Id, PricebookEntry>();
        pricebookEntriesAddon = util.initPricebook(productListAddon);
        Opportunity opportunityAddon = util.createNewOpportunity('Test Opportunity 1 Addon', account, 'Products, Services and Maintenance', 'New');
        SBQQ__Quote__c sbQuoteAddon = util.createSBQuote(opportunityAddon, account, Date.today(), true);
        List<SBQQ__Quoteline__c> sbQuoteLinesAddon = util.createSBQuoteLines(sbQuoteAddon, pricebookEntriesAddon, true, 2);
        //List<OpportunityLineItem> opportunityLineItemsAddon = util.createOppLineItems(opportunityAddon, sbQuoteLinesAddon, pricebookEntriesAddon);
        opportunityAddon = util.closeWonOpportunity(opportunityAddon);
        Contract contractAddon = util.createContract(opportunityAddon, account, 'SteelBrick CPQ Contract', Date.today());
        List<SBQQ__Subscription__c> subscriptionListAddon = util.createSubscriptions(sbQuoteLinesAddon, contractAddon, account, null, null);
        subscriptionListAddon = [SELECT Id, SBQQ__Product__c, SBQQ__ProductName__c, SBQQ__Account__c
                            , SBQQ__Contract__c, SBQQ__Contract__r.EndDate, SBQQ__StartDate__c
                            , SBQQ__EndDate__c, SBQQ__Quantity__c
                            , Subscribed_Asset_Count__c
                            , SBQQ__Product__r.Name, SBQQ__Product__r.Description
                            , SBQQ__NetPrice__c, Annual_Recurring_Revenue__c
                            , SBQQ__RevisedSubscription__c
                            FROM SBQQ__Subscription__c WHERE Id in :subscriptionListAddon];

        VistaSubscriptionHandler.handleSBSubscriptions(subscriptionListAddon);        

        List<Customer_Asset__c> vistaAssetsAddon = [SELECT Id, Name, Account__c, Product__c, Description__c, Contract__c
                                                    , Term_Start_Date__c, Term_End_Date__c, Asset_Status__c, Quantity__c
                                                    , Annual_Recurring_Revenue__c, Steelbrick_Subscription__c 
                                                    FROM Customer_Asset__c WHERE Steelbrick_Subscription__c IN :subscriptionListAddon];
        
        // Check first record
        //System.assertEquals(1, vistaAssets.size());

        Customer_Asset__c vaUpdate = vistaAssets[0];
        vaUpdate.Steelbrick_Subscription__c = subscriptionList[0].Id;
        vaUpdate.Decommission_Effective_Date__c = System.today();
        update vaUpdate;

        vaUpdate = [SELECT Id, Name, Account__c, Product__c, Description__c, Contract__c
                   , Term_Start_Date__c, Term_End_Date__c, Asset_Status__c, Quantity__c
                   , Annual_Recurring_Revenue__c, Steelbrick_Subscription__c 
                   , Steelbrick_Subscription__r.SBQQ__Contract__c, Steelbrick_Subscription__r.SBQQ__StartDate__c
                   , Steelbrick_Subscription__r.SBQQ__EndDate__c, Steelbrick_Subscription__r.SBQQ__QuoteLine__r.SBQQ__Quantity__c
                   , Steelbrick_Subscription__r.SBQQ__NetPrice__c, Steelbrick_Subscription__r.Annual_Recurring_Revenue__c
                   , Steelbrick_Subscription__r.CurrencyIsoCode
                   FROM Customer_Asset__c WHERE Id = :vaUpdate.Id];
        
        //VistaSubscriptionHandler.updateVistaAssetForSubscription(vaUpdate);        

        Test.stopTest();
    }
    
    @isTest
    static void decomExistingSubscriptionTest() {
        System.debug(LoggingLevel.INFO, 'VistaSubscriptionHandlerTest.updateExistingSubscriptionTest');
        
        insert new ByPassTrigger__c(SetupOwnerId=UserInfo.getOrganizationId(), isDisabled__c=true, Name='Testing Bypass');
        
        Account account = util.createAccount('ABC Test Account');
        Contract msa = util.createContract(null, account, 'Customer - MSA', Date.today());
        List<Product2> productList = new List<Product2>();
        //subPricingType = 'Fixed Price' or 'Percent Of Total'
        productList.addAll(util.initProductSet(1, 'Hardware', '', 'Fixed Price', 'Monthly'));
        Map<Id, PricebookEntry> pricebookEntries = new Map<Id, PricebookEntry>();
        pricebookEntries = util.initPricebook(productList);
        Opportunity opportunity = util.createNewOpportunity('Test Opportunity 1', account, 'Products, Services and Maintenance', 'New');
        SBQQ__Quote__c sbQuote = util.createSBQuote(opportunity, account, Date.today(), true);
        List<SBQQ__Quoteline__c> sbQuoteLines = util.createSBQuoteLines(sbQuote, pricebookEntries, false, 2);
        //List<OpportunityLineItem> opportunityLineItems = util.createOppLineItems(opportunity, sbQuoteLines, pricebookEntries);
        opportunity = util.closeWonOpportunity(opportunity);
        Contract contract = util.createContract(opportunity, account, 'SteelBrick CPQ Contract', Date.today());
        List<SBQQ__Subscription__c> subscriptionList = util.createSubscriptions(sbQuoteLines, contract, account, null, null);
        subscriptionList = [SELECT Id, SBQQ__Product__c, SBQQ__ProductName__c, SBQQ__Account__c
                            , SBQQ__Contract__c, SBQQ__Contract__r.EndDate, SBQQ__StartDate__c
                            , SBQQ__EndDate__c, SBQQ__Quantity__c
                            , Subscribed_Asset_Count__c
                            , SBQQ__Product__r.Name, SBQQ__Product__r.Description
                            , SBQQ__NetPrice__c, Annual_Recurring_Revenue__c
                            , SBQQ__RevisedSubscription__c
                            FROM SBQQ__Subscription__c WHERE Id in :subscriptionList];
        
        VistaSubscriptionHandler.handleSBSubscriptions(subscriptionList);        
        
        Test.startTest();
        
        List<Customer_Asset__c> vistaAssets = [SELECT Id, Name, Account__c, Product__c, Description__c, Contract__c
                                                    , Term_Start_Date__c, Term_End_Date__c, Asset_Status__c, Quantity__c
                                                    , Annual_Recurring_Revenue__c, Steelbrick_Subscription__c 
                                                    FROM Customer_Asset__c WHERE Steelbrick_Subscription__c IN :subscriptionList];
        //---Step 2--- Create decom subscription
        // subPricingType = 'Fixed Price' or 'Percent Of Total'
        Opportunity opportunityDecom = util.createNewOpportunity('Test Opportunity 1 Decom', account, 'Products, Services and Maintenance', 'New');
        SBQQ__Quote__c sbQuoteDecom = util.createSBQuote(opportunityDecom, account, Date.today(), true);
        List<SBQQ__Quoteline__c> sbQuoteLinesDecom = util.createSBQuoteLines(sbQuoteDecom, pricebookEntries, true, 0);
        //List<OpportunityLineItem> opportunityLineItemsDecom = util.createOppLineItems(opportunityDecom, sbQuoteLinesDecom, pricebookEntries);
        opportunityDecom = util.closeWonOpportunity(opportunityDecom);
        List<SBQQ__Subscription__c> subscriptionListDecom = util.createSubscriptions(sbQuoteLinesDecom, contract, account, null, null);
        subscriptionListDecom = [SELECT Id, SBQQ__Product__c, SBQQ__ProductName__c, SBQQ__Account__c
                            , SBQQ__Contract__c, SBQQ__Contract__r.EndDate, SBQQ__StartDate__c
                            , SBQQ__EndDate__c, SBQQ__Quantity__c
                            , Subscribed_Asset_Count__c
                            , SBQQ__Product__r.Name, SBQQ__Product__r.Description
                            , SBQQ__NetPrice__c, Annual_Recurring_Revenue__c
                            , SBQQ__RevisedSubscription__c
                            FROM SBQQ__Subscription__c WHERE Id in :subscriptionListDecom];

        VistaSubscriptionHandler.handleSBSubscriptions(subscriptionListDecom);        

        List<Customer_Asset__c> vistaAssetsDecom = [SELECT Id, Name, Account__c, Product__c, Description__c, Contract__c
                                                    , Term_Start_Date__c, Term_End_Date__c, Asset_Status__c, Quantity__c
                                                    , Annual_Recurring_Revenue__c, Steelbrick_Subscription__c 
                                                    FROM Customer_Asset__c WHERE Steelbrick_Subscription__c IN :subscriptionListDecom];
        
        
        
        // Check first record
        //System.assertEquals(1, vistaAssets.size());
        
        Customer_Asset__c vaDecom = vistaAssets[0];
        vaDecom.Steelbrick_Subscription__c = subscriptionList[0].Id;
        vaDecom.Decommission_Effective_Date__c = System.today();
        update vaDecom;

        vaDecom = [SELECT Id, Name, Account__c, Product__c, Description__c, Contract__c
                   , Term_Start_Date__c, Term_End_Date__c, Asset_Status__c, Quantity__c
                   , Annual_Recurring_Revenue__c, Steelbrick_Subscription__c 
                   , Steelbrick_Subscription__r.SBQQ__Contract__c, Steelbrick_Subscription__r.SBQQ__StartDate__c
                   , Steelbrick_Subscription__r.SBQQ__EndDate__c, Steelbrick_Subscription__r.SBQQ__QuoteLine__r.SBQQ__Quantity__c
                   , Steelbrick_Subscription__r.SBQQ__NetPrice__c, Steelbrick_Subscription__r.Annual_Recurring_Revenue__c
                   , Steelbrick_Subscription__r.CurrencyIsoCode
                   FROM Customer_Asset__c WHERE Id = :vaDecom.Id];
        
        VistaSubscriptionHandler.decomVistaAssetForSubscription(vaDecom);        
        
        Test.stopTest();
    }

    @isTest
    public static void testUpdateVistaAssetForSubscriptionRenewed() {
        insert new ByPassTrigger__c(SetupOwnerId=UserInfo.getOrganizationId(), isDisabled__c=true, Name='Testing Bypass');

        Account account = util.createAccount('ABC Test Account');
        Contract contract = util.createContract(null, account, 'Customer - MSA', Date.today());
        contract.Master_Term_Remaining__c = 12;
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
        List<SBQQ__Subscription__c> subscriptionList = util.createSubscriptions(sbQuoteLines, contract, account, null, null);

        Customer_Asset__c customerAsset = new Customer_Asset__c();

        Map<SBQQ__Subscription__c, Customer_Asset__c> subscriptionCustomerAssetMap = new Map<SBQQ__Subscription__c, Customer_Asset__c>();
        subscriptionCustomerAssetMap.put(subscriptionList.get(0), customerAsset);

        Test.startTest();
        VistaSubscriptionHandler.updateVistaAssetForSubscription(subscriptionCustomerAssetMap, 'renewed');
        Test.stopTest();
    }

    @isTest
    public static void testUpdateVistaAssetForSubscriptionRenewed2() {
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
        List<SBQQ__Subscription__c> subscriptionList = util.createSubscriptions(sbQuoteLines, contract, account, null, null);

        Customer_Asset__c customerAsset = new Customer_Asset__c();

        Map<SBQQ__Subscription__c, Customer_Asset__c> subscriptionCustomerAssetMap = new Map<SBQQ__Subscription__c, Customer_Asset__c>();
        subscriptionCustomerAssetMap.put(subscriptionList.get(0), customerAsset);

        Test.startTest();
        VistaSubscriptionHandler.updateVistaAssetForSubscription(subscriptionCustomerAssetMap, 'renewed');
        Test.stopTest();
    }

    @isTest
    public static void testUpdateVistaAssetForSubscriptionNotRenewed() {
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
        List<SBQQ__Subscription__c> subscriptionList = util.createSubscriptions(sbQuoteLines, contract, account, null, null);
        subscriptionList.get(0).ARR__c = 2234;

        Customer_Asset__c customerAsset = new Customer_Asset__c();
        customerAsset.Contract__r = contract;
        customerAsset.Steelbrick_Subscription__r = subscriptionList.get(0);
        customerAsset.Quantity__c = 50;
        customerAsset.Annual_Recurring_Revenue__c = 10000;
        //ARMAN: customerAsset.ARR__c = 4567;

        Map<SBQQ__Subscription__c, Customer_Asset__c> subscriptionCustomerAssetMap = new Map<SBQQ__Subscription__c, Customer_Asset__c>();
        subscriptionCustomerAssetMap.put(subscriptionList.get(0), customerAsset);

        Test.startTest();
        VistaSubscriptionHandler.updateVistaAssetForSubscription(subscriptionCustomerAssetMap, 'revisit');
        Test.stopTest();
    }

    @isTest
    public static void testGetVistaAssetsForRevisedSubscriptions() {
        insert new ByPassTrigger__c(SetupOwnerId=UserInfo.getOrganizationId(), isDisabled__c=true, Name='Testing Bypass');

        Account account = util.createAccount('ABC Test Account');
        Contract contract = util.createContract(null, account, 'Customer - MSA', Date.today());
        contract.Master_Term_Remaining__c = 12;

        List<Product2> productList = new List<Product2>();
        productList.addAll(util.initProductSet(1, 'Hardware', '', 'Fixed Price', 'Monthly'));
        System.debug('-- TEST productList = '+productList);

        Map<Id, PricebookEntry> pricebookEntries = new Map<Id, PricebookEntry>();
        pricebookEntries = util.initPricebook(productList);

        Opportunity opportunity = util.createNewOpportunity('Test Opportunity 1 Decom', account, 'Products, Services and Maintenance', 'New');
        SBQQ__Quote__c sbQuote = util.createSBQuote(opportunity, account, Date.today(), true);

        List<SBQQ__Quoteline__c> sbQuoteLines = util.createSBQuoteLines(sbQuote, pricebookEntries, true, 0);
        SBQQ__Quoteline__c qLine0 = sbQuoteLines[0];
        System.debug('-- qLine0 = '+qLine0);

        SBQQ__Subscription__c revisedSub = new SBQQ__Subscription__c();
        revisedSub.SBQQ__Quantity__c = 5;
        revisedSub.SBQQ__Product__c = productList[0].Id;
        revisedSub.SBQQ__Product__r = productList[0];
        revisedSub.SBQQ__NetPrice__c = qLine0.SBQQ__NetPrice__c;
        revisedSub.Final_Unit_Price__c = qLine0.SBQQ__NetPrice__c + 100;
        revisedSub.Annual_Recurring_Revenue__c = qLine0.Annual_Recurring_Revenue__c +100;
        revisedSub.SBQQ__SubscriptionStartDate__c = qLine0.SBQQ__StartDate__c;
        revisedSub.SBQQ__SubscriptionEndDate__c = qLine0.SBQQ__EndDate__c;
        revisedSub.SBQQ__Contract__c = contract.Id;
        revisedSub.SBQQ__Contract__r = contract;
        revisedSub.SBQQ__Contract__r.Master_Term_Remaining__c = 10;
        revisedSub.SBQQ__Account__c = account.Id;
        revisedSub.SBQQ__Account__r = account;
        revisedSub.SBQQ__QuoteLine__c = qLine0.Id;
        revisedSub.SBQQ__QuoteLine__r = qLine0;
        insert revisedSub;

        revisedSub = [SELECT Id, CurrencyIsoCode, SBQQ__Product__c, SBQQ__ProductName__c, SBQQ__Account__c
                , SBQQ__Contract__c, SBQQ__Contract__r.EndDate, SBQQ__StartDate__c
                , SBQQ__EndDate__c, SBQQ__Quantity__c, SBQQ__QuoteLine__c
                , Subscribed_Asset_Count__c
                , SBQQ__Product__r.Name, SBQQ__Product__r.Description
                , SBQQ__NetPrice__c, Annual_Recurring_Revenue__c
                , SBQQ__RevisedSubscription__c
                , SBQQ__QuoteLine__r.Id, SBQQ__QuoteLine__r.SBQQ__Existing__c
                , SBQQ__QuoteLine__r.SBQQ__RenewedSubscription__c, SBQQ__QuoteLine__r.SBQQ__Quantity__c
                , SBQQ__Contract__r.Master_Term_Remaining__c, Final_Unit_Price__c
                , SBQQ__Product__r.Default_Billing_Frequency__c
                , SBQQ__QuoteLine__r.Oracle_Id__c
                , SBQQ__QuoteLine__r.SBQQ__Quote__r.SBQQ__Opportunity2__c
                , SBQQ__RenewalPrice__c
                FROM SBQQ__Subscription__c WHERE Id = :revisedSub.Id LIMIT 1];
        System.debug('-- revisedSub = '+revisedSub);

        Customer_Asset__c revSubCustomerAsset = VistaSubscriptionHandler.createVistaAssetForSubscription(revisedSub);
        System.debug('-- revSubCustomerAsset = '+revSubCustomerAsset);
        insert revSubCustomerAsset;

        opportunity = util.closeWonOpportunity(opportunity);

        List<SBQQ__Subscription__c> subscriptionList = util.createSubscriptions(sbQuoteLines, contract, account, revisedSub.Id, null);
        System.debug('-- TEST subscriptionList = '+subscriptionList);

        subscriptionList = [SELECT Id, CurrencyIsoCode, SBQQ__Product__c, SBQQ__ProductName__c, SBQQ__Account__c
                , SBQQ__Contract__c, SBQQ__Contract__r.EndDate, SBQQ__StartDate__c
                , SBQQ__EndDate__c, SBQQ__Quantity__c, SBQQ__QuoteLine__c
                , Subscribed_Asset_Count__c
                , SBQQ__Product__r.Name, SBQQ__Product__r.Description
                , SBQQ__NetPrice__c, Annual_Recurring_Revenue__c
                , SBQQ__RevisedSubscription__c
                , SBQQ__QuoteLine__r.Id, SBQQ__QuoteLine__r.SBQQ__Existing__c
                , SBQQ__QuoteLine__r.SBQQ__RenewedSubscription__c, SBQQ__QuoteLine__r.SBQQ__Quantity__c
                , SBQQ__Contract__r.Master_Term_Remaining__c, Final_Unit_Price__c
                , SBQQ__Product__r.Default_Billing_Frequency__c
                , SBQQ__QuoteLine__r.Oracle_Id__c
                , SBQQ__QuoteLine__r.SBQQ__Quote__r.SBQQ__Opportunity2__c
                , SBQQ__RenewalPrice__c
                FROM SBQQ__Subscription__c WHERE Id in :subscriptionList];
        System.debug('-- TEST subscriptionList 2 = '+subscriptionList);

        Customer_Asset__c customerAsset = VistaSubscriptionHandler.createVistaAssetForSubscription(subscriptionList[0]);
        System.debug('-- customerAsset = '+customerAsset);
        insert customerAsset;

        List<Customer_Asset__c> vistaAssets = [SELECT Id, Name, Account__c, Product__c, Description__c, Contract__c
                , Term_Start_Date__c, Term_End_Date__c, Asset_Status__c, Quantity__c
                , Annual_Recurring_Revenue__c, Steelbrick_Subscription__c
                FROM Customer_Asset__c WHERE Steelbrick_Subscription__c IN :subscriptionList];
        System.debug('-- vistaAssets = '+vistaAssets);

        // Check first record
        System.assertEquals(1, vistaAssets.size());

        Customer_Asset__c vCustomerAsset = vistaAssets[0];
        System.debug('-- vCustomerAsset = '+vCustomerAsset);

        Test.startTest();
        Map<SBQQ__Subscription__c, Customer_Asset__c> subCustAssetMap =
            VistaSubscriptionHandler.getVistaAssetsForRevisedSubscriptions(subscriptionList);
        System.debug('-- TEST subCustAssetMap = '+subCustAssetMap);
        Test.stopTest();

        System.assert(subCustAssetMap.size() > 0);
    }

    @isTest
    public static void testGetVistaAssetsForRenewedSubscriptions() {
        insert new ByPassTrigger__c(SetupOwnerId=UserInfo.getOrganizationId(), isDisabled__c=true, Name='Testing Bypass');

        Account account = util.createAccount('ABC Test Account');
        Contract contract = util.createContract(null, account, 'Customer - MSA', Date.today());
        contract.Master_Term_Remaining__c = 12;

        List<Product2> productList = new List<Product2>();
        productList.addAll(util.initProductSet(1, 'Hardware', '', 'Fixed Price', 'Monthly'));
        System.debug('-- TEST productList = '+productList);

        Map<Id, PricebookEntry> pricebookEntries = new Map<Id, PricebookEntry>();
        pricebookEntries = util.initPricebook(productList);

        Opportunity opportunity = util.createNewOpportunity('Test Opportunity 1 Decom', account, 'Products, Services and Maintenance', 'New');
        SBQQ__Quote__c sbQuote = util.createSBQuote(opportunity, account, Date.today(), true);

        List<SBQQ__Quoteline__c> sbQuoteLines = util.createSBQuoteLines(sbQuote, pricebookEntries, true, 0);
        SBQQ__Quoteline__c qLine0 = sbQuoteLines[0];
        System.debug('-- qLine0 = '+qLine0);

        SBQQ__Subscription__c renewedSub = new SBQQ__Subscription__c();
        renewedSub.SBQQ__Quantity__c = 5;
        renewedSub.SBQQ__Product__c = productList[0].Id;
        renewedSub.SBQQ__Product__r = productList[0];
        renewedSub.SBQQ__NetPrice__c = qLine0.SBQQ__NetPrice__c;
        renewedSub.Final_Unit_Price__c = qLine0.SBQQ__NetPrice__c + 100;
        renewedSub.Annual_Recurring_Revenue__c = qLine0.Annual_Recurring_Revenue__c +100;
        renewedSub.SBQQ__SubscriptionStartDate__c = qLine0.SBQQ__StartDate__c;
        renewedSub.SBQQ__SubscriptionEndDate__c = qLine0.SBQQ__EndDate__c;
        renewedSub.SBQQ__Contract__c = contract.Id;
        renewedSub.SBQQ__Contract__r = contract;
        renewedSub.SBQQ__Contract__r.Master_Term_Remaining__c = 10;
        renewedSub.SBQQ__Account__c = account.Id;
        renewedSub.SBQQ__Account__r = account;
        renewedSub.SBQQ__QuoteLine__c = qLine0.Id;
        renewedSub.SBQQ__QuoteLine__r = qLine0;
        insert renewedSub;

        qLine0.SBQQ__RenewedSubscription__c = renewedSub.Id; // VIP
        update qLine0;
        System.debug('-- qLine0 = '+qLine0);

        renewedSub = [SELECT Id, CurrencyIsoCode, SBQQ__Product__c, SBQQ__ProductName__c, SBQQ__Account__c
                , SBQQ__Contract__c, SBQQ__Contract__r.EndDate, SBQQ__StartDate__c
                , SBQQ__EndDate__c, SBQQ__Quantity__c, SBQQ__QuoteLine__c
                , Subscribed_Asset_Count__c
                , SBQQ__Product__r.Name, SBQQ__Product__r.Description
                , SBQQ__NetPrice__c, Annual_Recurring_Revenue__c
                , SBQQ__RevisedSubscription__c
                , SBQQ__QuoteLine__r.Id, SBQQ__QuoteLine__r.SBQQ__Existing__c
                , SBQQ__QuoteLine__r.SBQQ__RenewedSubscription__c, SBQQ__QuoteLine__r.SBQQ__Quantity__c
                , SBQQ__Contract__r.Master_Term_Remaining__c, Final_Unit_Price__c
                , SBQQ__Product__r.Default_Billing_Frequency__c
                , SBQQ__QuoteLine__r.Oracle_Id__c
                , SBQQ__QuoteLine__r.SBQQ__Quote__r.SBQQ__Opportunity2__c
                , SBQQ__RenewalPrice__c
        FROM SBQQ__Subscription__c WHERE Id = :renewedSub.Id LIMIT 1];
        System.debug('-- renewedSub = '+renewedSub);

        Customer_Asset__c renewedSubCustomerAsset = VistaSubscriptionHandler.createVistaAssetForSubscription(renewedSub);
        System.debug('-- renewedSubCustomerAsset = '+renewedSubCustomerAsset);
        insert renewedSubCustomerAsset;

        opportunity = util.closeWonOpportunity(opportunity);

        List<SBQQ__Subscription__c> subscriptionList = util.createSubscriptions(sbQuoteLines, contract, account, null, renewedSub.Id);
        System.debug('-- TEST subscriptionList = '+subscriptionList);

        subscriptionList = [SELECT Id, CurrencyIsoCode, SBQQ__Product__c, SBQQ__ProductName__c, SBQQ__Account__c
                , SBQQ__Contract__c, SBQQ__Contract__r.EndDate, SBQQ__StartDate__c
                , SBQQ__EndDate__c, SBQQ__Quantity__c, SBQQ__QuoteLine__c
                , Subscribed_Asset_Count__c
                , SBQQ__Product__r.Name, SBQQ__Product__r.Description
                , SBQQ__NetPrice__c, Annual_Recurring_Revenue__c
                , SBQQ__RevisedSubscription__c
                , SBQQ__QuoteLine__r.Id, SBQQ__QuoteLine__r.SBQQ__Existing__c
                , SBQQ__QuoteLine__r.SBQQ__RenewedSubscription__c, SBQQ__QuoteLine__r.SBQQ__Quantity__c
                , SBQQ__Contract__r.Master_Term_Remaining__c, Final_Unit_Price__c
                , SBQQ__Product__r.Default_Billing_Frequency__c
                , SBQQ__QuoteLine__r.Oracle_Id__c
                , SBQQ__QuoteLine__r.SBQQ__Quote__r.SBQQ__Opportunity2__c
                , SBQQ__RenewalPrice__c
        FROM SBQQ__Subscription__c WHERE Id in :subscriptionList];
        System.debug('-- TEST subscriptionList 2 = '+subscriptionList);

        Customer_Asset__c customerAsset = VistaSubscriptionHandler.createVistaAssetForSubscription(subscriptionList[0]);
        System.debug('-- customerAsset = '+customerAsset);
        insert customerAsset;

        List<Customer_Asset__c> vistaAssets = [SELECT Id, Name, Account__c, Product__c, Description__c, Contract__c
                , Term_Start_Date__c, Term_End_Date__c, Asset_Status__c, Quantity__c
                , Annual_Recurring_Revenue__c, Steelbrick_Subscription__c
        FROM Customer_Asset__c WHERE Steelbrick_Subscription__c IN :subscriptionList];
        System.debug('-- vistaAssets = '+vistaAssets);

        // Check first record
        System.assertEquals(1, vistaAssets.size());

        Customer_Asset__c vCustomerAsset = vistaAssets[0];
        System.debug('-- vCustomerAsset = '+vCustomerAsset);

        Test.startTest();
        Map<SBQQ__Subscription__c, Customer_Asset__c> subCustAssetMap =
                VistaSubscriptionHandler.getVistaAssetsForRenewedSubscriptions(subscriptionList);
        System.debug('-- TEST subCustAssetMap = '+subCustAssetMap);
        Test.stopTest();

        System.assert(subCustAssetMap.size() > 0);
    }
}