/**
 * Created by CrutchfieldJody on 11/23/2016.
 */
@isTest
public with sharing class QuoteLineGroupHandlerTest {

    public static VistaAssetHelperUtil util = new VistaAssetHelperUtil();

    @isTest
    public static void testRollupQLGQuantities_AfterInsert(){

        insert new ByPassTrigger__c(SetupOwnerId=UserInfo.getOrganizationId(), isDisabled__c=true, Name='Testing Bypass');

        Account account = util.createAccount('ABC Test Account');
        List<Product2> productList = new List<Product2>();
        //subPricingType = 'Fixed Price' or 'Percent Of Total'
        productList.addAll(util.initProductSet(1, 'Hardware', '', 'Fixed Price', 'Once'));
        productList.addAll(util.initProductSet(1, 'Software', 'Service Plans', 'Fixed Price', 'Monthly'));
        productList.addAll(util.initProductSet(1, 'Software', 'Applications', 'Fixed Price', 'Monthly'));
        productList.addAll(util.initProductSet(1, 'Software', 'Other', 'Fixed Price', 'Monthly'));
        Map<Id, PricebookEntry> pricebookEntries = new Map<Id, PricebookEntry>();
        pricebookEntries = util.initPricebook(productList);
        Opportunity opportunity = util.createNewOpportunity('Test Opportunity 1', account, 'Products, Services and Maintenance', 'New');
        SBQQ__Quote__c sbQuote = util.createSBQuote(opportunity, account, Date.today(), true);
        List<SBQQ__Quoteline__c> sbQuoteLines = util.createSBQuoteLines(sbQuote, pricebookEntries, false, 2);
        SBQQ__QuoteLineGroup__c qlGroup = new SBQQ__QuoteLineGroup__c();
        qlGroup.Name = 'Group1';
        qlGroup.SBQQ__Quote__c = sbQuote.Id;
        insert qlGroup;

        Test.startTest();

        List<SBQQ__Quoteline__c> qlUpdates = new List<SBQQ__Quoteline__c>();
        for(SBQQ__Quoteline__c ql : sbQuoteLines){
            ql.SBQQ__Group__c = qlGroup.Id;
            qlUpdates.add(ql);
        }
        if(qlUpdates.size() > 0){
            update qlUpdates;
        }

        List<Id> qlgIdList = new List<Id>();
        qlgIdList.add(qlGroup.Id);

        QuoteLineGroupHandler.rollupQLGQuantities(qlgIdList);

        Test.stopTest();
    }

    @isTest
    public static void testRollupQLGQuantities_AfterUpdate(){

        insert new ByPassTrigger__c(SetupOwnerId=UserInfo.getOrganizationId(), isDisabled__c=true, Name='Testing Bypass');

        Account account = util.createAccount('ABC Test Account');
        List<Product2> productList = new List<Product2>();
        //subPricingType = 'Fixed Price' or 'Percent Of Total'
        productList.addAll(util.initProductSet(1, 'Hardware', '', 'Fixed Price', 'Once'));
        productList.addAll(util.initProductSet(1, 'Software', 'Service Plans', 'Fixed Price', 'Monthly'));
        productList.addAll(util.initProductSet(1, 'Software', 'Applications', 'Fixed Price', 'Monthly'));
        productList.addAll(util.initProductSet(1, 'Software', 'Other', 'Fixed Price', 'Monthly'));
        Map<Id, PricebookEntry> pricebookEntries = new Map<Id, PricebookEntry>();
        pricebookEntries = util.initPricebook(productList);
        Opportunity opportunity = util.createNewOpportunity('Test Opportunity 1', account, 'Products, Services and Maintenance', 'New');
        SBQQ__Quote__c sbQuote = util.createSBQuote(opportunity, account, Date.today(), true);
        List<SBQQ__Quoteline__c> sbQuoteLines = util.createSBQuoteLines(sbQuote, pricebookEntries, false, 2);
        SBQQ__QuoteLineGroup__c qlGroup = new SBQQ__QuoteLineGroup__c();
        qlGroup.Name = 'Group1';
        qlGroup.SBQQ__Quote__c = sbQuote.Id;
        insert qlGroup;

        List<SBQQ__Quoteline__c> qlUpdates = new List<SBQQ__Quoteline__c>();
        for(SBQQ__Quoteline__c ql : sbQuoteLines){
            ql.SBQQ__Group__c = qlGroup.Id;
            qlUpdates.add(ql);
        }
        if(qlUpdates.size() > 0){
            update qlUpdates;
        }

        QuoteLineGroupRecursiveTriggerHandler.isFirstTime = true; //RESET

        Test.startTest();
        qlGroup.SBQQ__Account__c = account.Id;
        update qlGroup;
        Test.stopTest();
    }

    @isTest
    public static void testRollupQLGQuantities_AfterUpdate_AffiliateAcct(){

        insert new ByPassTrigger__c(SetupOwnerId=UserInfo.getOrganizationId(), isDisabled__c=true, Name='Testing Bypass');

        Account account = util.createAccount('ABC Test Account');
        Account childAcct = util.createAccount('XYZ Child Account');

        Related_Accounts__c relAccount = new Related_Accounts__c  (   Parent_Account__c = account.Id,
                Child_Account__c = childAcct.Id,
                Description__c = childAcct.Name+' was acquired by '+account.Name+ ' on '+ Date.today(),
                Relationship_Type__c = 'Purchaser',
                Child_Relationship_Type__c = 'Acquired'
        );
        insert relAccount;

        List<Product2> productList = new List<Product2>();
        //subPricingType = 'Fixed Price' or 'Percent Of Total'
        productList.addAll(util.initProductSet(1, 'Hardware', '', 'Fixed Price', 'Once'));
        productList.addAll(util.initProductSet(1, 'Software', 'Service Plans', 'Fixed Price', 'Monthly'));
        productList.addAll(util.initProductSet(1, 'Software', 'Applications', 'Fixed Price', 'Monthly'));
        productList.addAll(util.initProductSet(1, 'Software', 'Other', 'Fixed Price', 'Monthly'));
        Map<Id, PricebookEntry> pricebookEntries = new Map<Id, PricebookEntry>();
        pricebookEntries = util.initPricebook(productList);
        Opportunity opportunity = util.createNewOpportunity('Test Opportunity 1', account, 'Products, Services and Maintenance', 'New');
        SBQQ__Quote__c sbQuote = util.createSBQuote(opportunity, account, Date.today(), true);
        List<SBQQ__Quoteline__c> sbQuoteLines = util.createSBQuoteLines(sbQuote, pricebookEntries, false, 2);
        SBQQ__QuoteLineGroup__c qlGroup = new SBQQ__QuoteLineGroup__c();
        qlGroup.Name = 'Group1';
        qlGroup.SBQQ__Quote__c = sbQuote.Id;
        qlGroup.SBQQ__Account__c = account.Id;
        insert qlGroup;

        List<SBQQ__Quoteline__c> qlUpdates = new List<SBQQ__Quoteline__c>();
        for(SBQQ__Quoteline__c ql : sbQuoteLines){
            ql.SBQQ__Group__c = qlGroup.Id;
            qlUpdates.add(ql);
        }
        if(qlUpdates.size() > 0){
            update qlUpdates;
        }
        QuoteLineGroupRecursiveTriggerHandler.isFirstTime = true; //RESET

        Test.startTest();
        qlGroup.SBQQ__Description__c = 'TEST AfterUpdate new AffiliateAccount';
        qlGroup.Affiliate_Account2__c = relAccount.Id;
        update qlGroup;
        Test.stopTest();
    }

        /* ARMAN: @isTest
        public static void QuoteLineGroupHandlerBuildDefaultEstimatesTest(){

            insert new ByPassTrigger__c(SetupOwnerId=UserInfo.getOrganizationId(), isDisabled__c=true, Name='Testing Bypass');

            Account account = util.createAccount('ABC Test Account');
            List<Product2> productList = new List<Product2>();
            //subPricingType = 'Fixed Price' or 'Percent Of Total'
            productList.addAll(util.initProductSet(1, 'Hardware', '', 'Fixed Price', 'Monthly'));
            productList.addAll(util.initProductSet(1, 'Software', 'Service Plans', 'Fixed Price', 'Monthly'));
            productList.addAll(util.initProductSet(1, 'Software', 'Applications', 'Fixed Price', 'Monthly'));
            productList.addAll(util.initProductSet(1, 'Software', 'Other', 'Fixed Price', 'Monthly'));
            Map<Id, PricebookEntry> pricebookEntries = new Map<Id, PricebookEntry>();
            pricebookEntries = util.initPricebook(productList);
            Opportunity opportunity = util.createNewOpportunity('Test Opportunity 1', account, 'Products, Services and Maintenance', 'New');
            SBQQ__Quote__c sbQuote = util.createSBQuote(opportunity, account, Date.today(), true);
            List<SBQQ__Quoteline__c> sbQuoteLines = util.createSBQuoteLines(sbQuote, pricebookEntries, false, 2);
            SBQQ__QuoteLineGroup__c qlGroup = new SBQQ__QuoteLineGroup__c();
            qlGroup.Name = 'Group1';
            qlGroup.SBQQ__Quote__c = sbQuote.Id;
            insert qlGroup;

            SBQQ__QuoteLineGroup__c qlGroup2 = new SBQQ__QuoteLineGroup__c();
            qlGroup2.Name = 'Group2';
            qlGroup2.SBQQ__Quote__c = sbQuote.Id;
            insert qlGroup2;

            Shipping_Estimate_Summary__c sum = new Shipping_Estimate_Summary__c();
            sum.Quote_Line_Group__c = qlGroup2.Id;
            insert sum;

            Shipping_Estimate__c shippingEstimate = new Shipping_Estimate__c();
            shippingEstimate.Shipping_Summary__c = sum.Id;
            shippingEstimate.Default_Estimate__c = true;
            insert shippingEstimate;

            Test.startTest();

            List<SBQQ__Quoteline__c> qlUpdates = new List<SBQQ__Quoteline__c>();
            for(SBQQ__Quoteline__c ql : sbQuoteLines){
                ql.SBQQ__Group__c = qlGroup.Id;
                qlUpdates.add(ql);
            }
            if(qlUpdates.size() > 0){
                update qlUpdates;
            }

            List<SBQQ__QuoteLineGroup__c> qlgList = new List<SBQQ__QuoteLineGroup__c>();
            qlgList.add(qlGroup);
            qlgList.add(qlGroup2);

            QuoteLineGroupHandler.buildDefaultEstimates(qlgList);

            Test.stopTest();
        } */
}