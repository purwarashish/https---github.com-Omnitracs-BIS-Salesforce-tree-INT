@isTest
public class VistaAssetVAHandlerTest {
    private static VistaAssetHelperUtil util = new VistaAssetHelperUtil();
    
    @isTest 
    static void createNewAssetTest() {
        System.debug('VistaAssetVAHandlerTest.createNewAssetTest');
        
        insert new ByPassTrigger__c(SetupOwnerId=UserInfo.getOrganizationId(), isDisabled__c=true, Name='Testing Bypass');
        
        Account account = util.createAccount('ABC Test Account');
        Contract msa = util.createContract(null, account, 'Customer - MSA', Date.today());
        List<Product2> productList = new List<Product2>();
        // subPricingType = 'Fixed Price' or 'Percent Of Total'
        productList.addAll(util.initProductSet(2, 'Hardware', '', 'Fixed Price', 'Monthly'));
        Map<Id, PricebookEntry> pricebookEntries = new Map<Id, PricebookEntry>();
        pricebookEntries = util.initPricebook(productList);
        Opportunity opportunity = util.createNewOpportunity('Test Opportunity 1', account, 'Products, Services and Maintenance', 'New');
        SBQQ__Quote__c sbQuote = util.createSBQuote(opportunity, account, Date.today(), true);
        List<SBQQ__Quoteline__c> sbQuoteLines = util.createSBQuoteLines(sbQuote, pricebookEntries, false, 2);
        
        //List<OpportunityLineItem> opportunityLineItems = util.createOppLineItems(opportunity, sbQuoteLines, pricebookEntries);
        opportunity = util.closeWonOpportunity(opportunity);
        Contract contract = util.createContract(opportunity, account, 'SteelBrick CPQ Contract', Date.today());
        
        List<Asset> assetList = new List<Asset>(); 
            for (SBQQ__QuoteLine__c ql : sbQuoteLines){
                    Asset sfdcAsset = util.createSFDCAsset(ql, account);
                    assetList.add(sfdcAsset);
                }
    
        assetList = [
                SELECT Id
                        , AccountId, Name, Description, CurrencyIsoCode
                        , InstallDate, Price, Product2Id, Product2.Name
                        , Product2.Description, Product2.Generate_Asset__c, Quantity, Status, UsageEndDate
                        , Annual_Recurring_Revenue__c, Contract__c, SBQQ__CurrentSubscription__c
                        , SBQQ__LatestQuoteLine__c, SBQQ__LatestQuoteLine__r.Id, SBQQ__LatestQuoteLine__r.SBQQ__Existing__c
                        , SBQQ__LatestQuoteLine__r.SBQQ__RenewedAsset__c, SBQQ__LatestQuoteLine__r.SBQQ__Quantity__c
                        , SBQQ__QuoteLine__c, SBQQ__QuoteLine__r.Id, SBQQ__QuoteLine__r.SBQQ__Existing__c
                        , SBQQ__QuoteLine__r.SBQQ__RenewedAsset__c, SBQQ__QuoteLine__r.SBQQ__Quantity__c
                        , Contract__r.StartDate, Contract__r.EndDate, SBQQ__RevisedAsset__c, SBQQ__RevisedAsset__r.Quantity
                        , SBQQ__LatestQuoteLine__r.SBQQ__EffectiveStartDate__c, SBQQ__LatestQuoteLine__r.SBQQ__EffectiveEndDate__c
                        , SBQQ__LatestQuoteLine__r.Oracle_Id__c, SBQQ__LatestQuoteLine__r.SBQQ__Quote__r.SBQQ__Opportunity2__c
                        FROM Asset 
                        where Id in :assetList];

        Test.startTest();

        VistaAssetVAHandler.handleAssetsVA(assetList);
        
        List<Id> assetIdList = new List<Id>();
        for (Asset a : assetList){
            assetIdList.add(a.Id);
        }
        
        List<Customer_Asset__c> vistaVAAssets = [SELECT
                Id, Name, Account__c, Product__c, Description__c, Contract__c
                , Term_Start_Date__c, Term_End_Date__c, Asset_Status__c, Quantity__c
                , Annual_Recurring_Revenue__c, Steelbrick_Subscription__c, Steelbrick_Asset__c
                /*, Total_One_Time_Fee_s__c*/
// subscribed asset fields
                , Steelbrick_Asset__r.SBQQ__CurrentSubscription__c, Steelbrick_Asset__r.Price
// subscribed asset subscription fields
                , Steelbrick_Asset__r.SBQQ__CurrentSubscription__r.SBQQ__QuoteLine__r.SBQQ__Quantity__c
                , Steelbrick_Asset__r.SBQQ__CurrentSubscription__r.SBQQ__NetPrice__c
                , Steelbrick_Asset__r.SBQQ__CurrentSubscription__r.CurrencyIsoCode
                , Steelbrick_Asset__r.SBQQ__CurrentSubscription__r.Annual_Recurring_Revenue__c
                , Steelbrick_Asset__r.Quantity, Steelbrick_Asset__r.Annual_Recurring_Revenue__c
                , Steelbrick_Asset__r.CurrencyIsoCode
                , Steelbrick_Asset__r.SBQQ__LatestQuoteLine__r.SBQQ__EffectiveStartDate__c
                , Steelbrick_Asset__r.SBQQ__LatestQuoteLine__r.SBQQ__EffectiveEndDate__c
                                                  FROM Customer_Asset__c WHERE Steelbrick_Asset__r.Id IN :assetIdList];

        //System.assertEquals(2, vistaVAAssets.size());
        VistaAssetVAHandler.getVistaAssetsForAssets(assetList);
        System.debug('asset to update: ' + vistaVAAssets.get(0));
        //VistaAssetVAHandler.updateVistaAssetForAsset(vistaVAAssets.get(0));
        VistaAssetVAHandler.decomVistaAssetForAsset(vistaVAAssets.get(0));
        
        Test.stopTest();
    }


    @isTest
    public static void testUpdateVistaAssetForAssetPath1() {
        insert new ByPassTrigger__c(SetupOwnerId=UserInfo.getOrganizationId(), isDisabled__c=true, Name='Testing Bypass');

        Account account = util.createAccount('ABC Test Account');
        Contract msa = util.createContract(null, account, 'Customer - MSA', Date.today());
        List<Product2> productList = new List<Product2>();
        // subPricingType = 'Fixed Price' or 'Percent Of Total'
        productList.addAll(util.initProductSet(1, 'Hardware', '', 'Fixed Price', 'Monthly'));
        Map<Id, PricebookEntry> pricebookEntries = new Map<Id, PricebookEntry>();
        pricebookEntries = util.initPricebook(productList);
        Opportunity opportunity = util.createNewOpportunity('Test Opportunity 1', account, 'Products, Services and Maintenance', 'New');
        SBQQ__Quote__c sbQuote = util.createSBQuote(opportunity, account, Date.today(), true);
        List<SBQQ__Quoteline__c> sbQuoteLines = util.createSBQuoteLines(sbQuote, pricebookEntries, false, 2);

        Asset asset = util.createSFDCAsset(sbQuoteLines.get(0), account);

        SBQQ__QuoteLine__c quoteLine = new SBQQ__QuoteLine__c(SBQQ__StartDate__c = Date.today(), SBQQ__EndDate__c = Date.today().addMonths(6));
        quoteLine.SBQQ__Quantity__c = 100;
        asset.SBQQ__LatestQuoteLine__r = quoteLine;
        Customer_Asset__c customerAsset = new Customer_Asset__c(Account__c=account.Id);
        //insert customerAsset;

        Map<Asset, Customer_Asset__c> customerAssetMap = new Map<Asset, Customer_Asset__c>();
        customerAssetMap.put(asset, customerAsset);

        Test.startTest();
        VistaAssetVAHandler.updateVistaAssetForAsset(customerAssetMap);
        Test.stopTest();
    }

    @isTest
    public static void testUpdateVistaAssetForAssetPath2() {
        insert new ByPassTrigger__c(SetupOwnerId=UserInfo.getOrganizationId(), isDisabled__c=true, Name='Testing Bypass');

        Account account = util.createAccount('ABC Test Account');
        Contract msa = util.createContract(null, account, 'Customer - MSA', Date.today());
        List<Product2> productList = new List<Product2>();
        // subPricingType = 'Fixed Price' or 'Percent Of Total'
        productList.addAll(util.initProductSet(1, 'Hardware', '', 'Fixed Price', 'Monthly'));
        Map<Id, PricebookEntry> pricebookEntries = new Map<Id, PricebookEntry>();
        pricebookEntries = util.initPricebook(productList);
        Opportunity opportunity = util.createNewOpportunity('Test Opportunity 1', account, 'Products, Services and Maintenance', 'New');
        SBQQ__Quote__c sbQuote = util.createSBQuote(opportunity, account, Date.today(), true);
        List<SBQQ__Quoteline__c> sbQuoteLines = util.createSBQuoteLines(sbQuote, pricebookEntries, false, 2);

        Asset asset = util.createSFDCAsset(sbQuoteLines.get(0), account);

        SBQQ__QuoteLine__c quoteLine = new SBQQ__QuoteLine__c(SBQQ__StartDate__c = Date.today(), SBQQ__EndDate__c = Date.today().addMonths(6));
        quoteLine.SBQQ__Quantity__c = 0;
        asset.SBQQ__LatestQuoteLine__r = quoteLine;

        Customer_Asset__c customerAsset = new Customer_Asset__c(Account__c=account.Id);

        Map<Asset, Customer_Asset__c> customerAssetMap = new Map<Asset, Customer_Asset__c>();
        customerAssetMap.put(asset, customerAsset);

        Test.startTest();
        VistaAssetVAHandler.updateVistaAssetForAsset(customerAssetMap);
        Test.stopTest();
    }

    // By Arman Shah
    @isTest
    public static void testGetVistaAssetsForRenewedAssets() {
        insert new ByPassTrigger__c(SetupOwnerId=UserInfo.getOrganizationId(), isDisabled__c=true, Name='Testing Bypass');

        Account account = util.createAccount('ABC Test Account');

        List<Product2> productList = new List<Product2>();
        // subPricingType = 'Fixed Price' or 'Percent Of Total'
        productList.addAll(util.initProductSet(2, 'Hardware', '', 'Fixed Price', 'Monthly')); // TWO Products

        Map<Id, PricebookEntry> pricebookEntries = new Map<Id, PricebookEntry>();
        pricebookEntries = util.initPricebook(productList);
        Opportunity opportunity = util.createNewOpportunity('Test Opportunity 1', account, 'Products, Services and Maintenance', 'New');
        SBQQ__Quote__c sbQuote = util.createSBQuote(opportunity, account, Date.today(), true);
        List<SBQQ__Quoteline__c> sbQuoteLines = util.createSBQuoteLines(sbQuote, pricebookEntries, false, 1);

        Asset asset = util.createSFDCAsset(sbQuoteLines.get(0), account);
        Asset renewedAsset = util.createSFDCAsset(sbQuoteLines.get(1), account);
        sbQuoteLines[0].SBQQ__RenewedAsset__r = renewedAsset;
        update sbQuoteLines[0];
        asset.SBQQ__LatestQuoteLine__c = sbQuoteLines[0].Id;
        update asset;

        List<Asset> assetList = new List<Asset>();
        Asset updtAsset = [
                select Id, AccountId, Name, Product2Id, Price, Quantity
                        , SBQQ__QuoteLine__c, SBQQ__QuoteLine__r.SBQQ__Quantity__c
                        , SBQQ__LatestQuoteLine__r.SBQQ__RenewedAsset__c
                        , SBQQ__LatestQuoteLine__r.SBQQ__EffectiveStartDate__c
                        , SBQQ__LatestQuoteLine__r.SBQQ__EffectiveEndDate__c
                        , SBQQ__LatestQuoteLine__r.SBQQ__Quantity__c
                        , SBQQ__LatestQuoteLine__r.SBQQ__Quote__r.SBQQ__Opportunity2__c
                        , CurrencyIsoCode
                from Asset
                where Id = :asset.Id
        ];
        System.debug('--- updtAsset = '+updtAsset);
        assetList.add(updtAsset);

        Customer_Asset__c customerAsset = new Customer_Asset__c(Account__c=account.Id);
        Map<Asset, Customer_Asset__c> customerAssetMap = new Map<Asset, Customer_Asset__c>();
        customerAssetMap.put(updtAsset, customerAsset);

        List<Customer_Asset__c> updtCustomerAssets = VistaAssetVAHandler.updateVistaAssetForAsset(customerAssetMap);
        insert updtCustomerAssets;

        Test.startTest();
        Map<Asset, Customer_Asset__c> renewedAsset_AssetMap = VistaAssetVAHandler.getVistaAssetsForRenewedAssets(assetList);
        Test.stopTest();

        System.assertEquals(renewedAsset_AssetMap.isEmpty(), false);
    }

    // By Arman Shah
    @isTest
    public static void testGetVistaAssetsForUpgradedAssets() {
        insert new ByPassTrigger__c(SetupOwnerId=UserInfo.getOrganizationId(), isDisabled__c=true, Name='Testing Bypass');

        Account account = util.createAccount('ABC Test Account');

        List<Product2> productList = new List<Product2>();
        // subPricingType = 'Fixed Price' or 'Percent Of Total'
        productList.addAll(util.initProductSet(2, 'Hardware', '', 'Fixed Price', 'Monthly')); // TWO Products

        Map<Id, PricebookEntry> pricebookEntries = new Map<Id, PricebookEntry>();
        pricebookEntries = util.initPricebook(productList);
        Opportunity opportunity = util.createNewOpportunity('Test Opportunity 1', account, 'Products, Services and Maintenance', 'New');
        SBQQ__Quote__c sbQuote = util.createSBQuote(opportunity, account, Date.today(), true);
        List<SBQQ__Quoteline__c> sbQuoteLines = util.createSBQuoteLines(sbQuote, pricebookEntries, false, 1);

        Asset asset = util.createSFDCAsset(sbQuoteLines.get(0), account);
        Asset upgradedAsset = util.createSFDCAsset(sbQuoteLines.get(1), account);
        sbQuoteLines[0].SBQQ__UpgradedAsset__r = upgradedAsset;
        update sbQuoteLines[0];
        asset.SBQQ__LatestQuoteLine__c = sbQuoteLines[0].Id;
        update asset;

        List<Asset> assetList = new List<Asset>();
        Asset updtAsset = [
                select Id, AccountId, Name, Product2Id, Price, Quantity
                        , SBQQ__QuoteLine__c, SBQQ__QuoteLine__r.SBQQ__Quantity__c
                        , SBQQ__LatestQuoteLine__r.SBQQ__RenewedAsset__c
                        , SBQQ__LatestQuoteLine__r.SBQQ__UpgradedAsset__c
                        , SBQQ__LatestQuoteLine__r.SBQQ__EffectiveStartDate__c
                        , SBQQ__LatestQuoteLine__r.SBQQ__EffectiveEndDate__c
                        , SBQQ__LatestQuoteLine__r.SBQQ__Quantity__c
                        , SBQQ__LatestQuoteLine__r.SBQQ__Quote__r.SBQQ__Opportunity2__c
                        , CurrencyIsoCode
                from Asset
                where Id = :asset.Id
        ];
        System.debug('--- updtAsset = '+updtAsset);
        assetList.add(updtAsset);

        Customer_Asset__c customerAsset = new Customer_Asset__c(Account__c=account.Id);
        Map<Asset, Customer_Asset__c> customerAssetMap = new Map<Asset, Customer_Asset__c>();
        customerAssetMap.put(updtAsset, customerAsset);

        List<Customer_Asset__c> updtCustomerAssets = VistaAssetVAHandler.updateVistaAssetForAsset(customerAssetMap);
        insert updtCustomerAssets;

        Test.startTest();
        Map<Asset, Customer_Asset__c> upgradedAsset_AssetMap = VistaAssetVAHandler.getVistaAssetsForUpgradedAssets(assetList);
        Test.stopTest();

        System.assertEquals(upgradedAsset_AssetMap.isEmpty(), false);
    }
}