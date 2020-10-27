@isTest
public class OpportunityFinancialsHandlerTest {
    
    public static VistaAssetHelperUtil util = new VistaAssetHelperUtil();

    @testSetup
    static void SetupData() {
        TestUtils.defineCustomSettings();
    }
    
    @isTest
    public static void calculateOpportunityFinancialsTest(){
        System.debug(LoggingLevel.WARN, 'OpportunityFinancialsHandlerTest.calculateOpportunityFinancialsTest');
        
        insert new ByPassTrigger__c(SetupOwnerId=UserInfo.getOrganizationId(), isDisabled__c=true, Name='Testing Bypass');

        Test.startTest();

        Account account = util.createAccount('ABC Test Account');
        Contract msa = util.createContract(null, account, 'Customer - MSA', Date.today());
        List<Product2> productList = new List<Product2>();
        //subPricingType = 'Fixed Price' or 'Percent Of Total'
        productList.addAll(util.initProductSet(1, 'Hardware', 'Hardware', 'Fixed Price', 'Once'));
        productList.addAll(util.initProductSet(1, 'Hardware', 'Hardware', 'Fixed Price', 'Monthly'));
        productList.addAll(util.initProductSet(1, 'Hardware', 'Hardware', 'Fixed Price', 'Quarterly'));
        productList.addAll(util.initProductSet(1, 'Hardware', 'Hardware', 'Fixed Price', 'Annual'));
        productList.addAll(util.initProductSet(1, 'Hardware', 'Hardware', 'Fixed Price', 'Once', 'Once'));
        productList.addAll(util.initProductSet(1, 'Hardware', 'Hardware', 'Fixed Price', 'Annual', 'Quarterly'));

        //productList.addAll(util.initProductSet(1, 'Software', 'Applications', null, 'Once'));
        productList.addAll(util.initProductSet(1, 'Software', 'Applications', 'Fixed Price', 'Monthly'));
        productList.addAll(util.initProductSet(1, 'Software', 'Applications', 'Fixed Price', 'Annual'));
        productList.addAll(util.initProductSet(1, 'Software', 'Applications', 'Fixed Price', 'Once'));
        //productList.addAll(util.initProductSet(1, 'Software', 'Applications', null, 'Quarterly'));
        //productList.addAll(util.initProductSet(1, 'Software', 'Applications', null, 'Annual'));

        //productList.addAll(util.initProductSet(1, 'Software', 'Service Plans', 'Fixed Price', 'Once'));
        productList.addAll(util.initProductSet(1, 'Software', 'Service Plans', 'Fixed Price', 'Monthly'));
        productList.addAll(util.initProductSet(1, 'Software', 'Service Plans', 'Fixed Price', 'Once'));
        //productList.addAll(util.initProductSet(1, 'Software', 'Service Plans', 'Fixed Price', 'Quarterly'));
        //productList.addAll(util.initProductSet(1, 'Software', 'Service Plans', 'Fixed Price', 'Annual'));
        //productList.addAll(util.initProductSet(1, 'Software', 'Service Plans', 'One Time', 'Once'));
        //productList.addAll(util.initProductSet(1, 'Software', 'Service Plans', 'Fixed Price', 'Monthly'));
        //productList.addAll(util.initProductSet(1, 'Software', 'Service Plans', 'One Time', 'Quarterly'));
        //productList.addAll(util.initProductSet(1, 'Software', 'Service Plans', 'One Time', 'Annual'));
        productList.addAll(util.initProductSet(1, 'Software', 'Service Plans', 'Fixed Price', 'Annual', 'Monthly'));
        productList.addAll(util.initProductSet(1, 'Software', 'Service Plans', 'Fixed Price', 'Monthly', 'Annual'));

        //productList.addAll(util.initProductSet(1, 'Professional Services', 'Percent Of Total', 'Once'));

        productList.addAll(util.initProductSet(1, 'Software', 'Not Service Plans', 'Fixed Price', 'Monthly'));
        productList.addAll(util.initProductSet(1, 'Software', 'Not Service Plans', 'Fixed Price', 'Once'));
        productList.addAll(util.initProductSet(1, 'Professional Services', 'Percent Of Total', 'Monthly'));
        //productList.addAll(util.initProductSet(1, 'Professional Services', 'Percent Of Total', 'Quarterly'));
        //productList.addAll(util.initProductSet(1, 'Professional Services', 'Percent Of Total', 'Annual'));

        Map<Id, PricebookEntry> pricebookEntries = new Map<Id, PricebookEntry>();
        pricebookEntries = util.initPricebook(productList);
        Opportunity opportunity = util.createNewOpportunity('Test Opportunity 1', account, 'Products, Services and Maintenance', 'New');
        SBQQ__Quote__c sbQuote = util.createSBQuote(opportunity, account, Date.today(), false);

        SBQQ__QuoteLineGroup__c qlGroup = new SBQQ__QuoteLineGroup__c();
        qlGroup.Name = 'Group1';
        qlGroup.SBQQ__Quote__c = sbQuote.Id;
        insert qlGroup;

        List<SBQQ__Quoteline__c> sbQuoteLines = util.createSBQuoteLines(sbQuote, pricebookEntries, false, 2);

        List<SBQQ__QuoteLineGroup__c> qlGroupLines = [SELECT Id, Name, SBQQ__Quote__c FROM SBQQ__QuoteLineGroup__c WHERE SBQQ__Quote__c = :sbQuote.Id];
        qlGroup = qlGroupLines.get(0);

        List<SBQQ__Quoteline__c> qlUpdates = new List<SBQQ__Quoteline__c>();
        for(SBQQ__Quoteline__c ql : sbQuoteLines){
            ql.SBQQ__Group__c = qlGroup.Id;
            qlUpdates.add(ql);
        }
        if(qlUpdates.size() > 0){
            update qlUpdates;
        }

        /* ARMAN: Shipping_Estimate_Summary__c ses = new Shipping_Estimate_Summary__c();
        ses.Quote_Line_Group__c = qlGroup.Id;
        insert ses;

        List<Shipping_Estimate_Summary__c> shippingEstimateSummaries = [SELECT Id, Name, Quote_Line_Group__c FROM Shipping_Estimate_Summary__c WHERE Quote_Line_Group__c = :qlGroup.Id];
        ses = shippingEstimateSummaries.get(0);

        List<Shipping_Estimate__c> el = new List<Shipping_Estimate__c>();
        Shipping_Estimate__c se = new Shipping_Estimate__c();
        se.Shipping_Summary__c = ses.Id;
        se.Estimated_Shipping_Date__c = System.today().addMonths(1);
        se.Estimated_Shipping_Quantity__c = 1;
        se.Shipping_Notes__c = 'Note 1';
        el.add(se);

        Shipping_Estimate__c se1 = new Shipping_Estimate__c();
        se1.Shipping_Summary__c = ses.Id;
        se1.Estimated_Shipping_Date__c = System.today().addMonths(2);
        se1.Estimated_Shipping_Quantity__c = 2;
        se1.Shipping_Notes__c = 'Note 2';
        el.add(se1);

        Shipping_Estimate__c se2 = new Shipping_Estimate__c();
        se2.Shipping_Summary__c = ses.Id;
        se2.Estimated_Shipping_Date__c = System.today().addMonths(3);
        se2.Estimated_Shipping_Quantity__c = 3;
        se2.Shipping_Notes__c = 'Note 3';
        el.add(se2);

        Shipping_Estimate__c se3 = new Shipping_Estimate__c();
        se3.Shipping_Summary__c = ses.Id;
        se3.Estimated_Shipping_Date__c = System.today().addMonths(4);
        se3.Estimated_Shipping_Quantity__c = 4;
        se3.Shipping_Notes__c = 'Note 4';
        el.add(se3);

        Shipping_Estimate__c se4 = new Shipping_Estimate__c();
        se4.Shipping_Summary__c = ses.Id;
        se4.Estimated_Shipping_Date__c = System.today().addMonths(5);
        se4.Estimated_Shipping_Quantity__c = 5;
        se4.Shipping_Notes__c = 'Note 5';
        el.add(se4);

        Shipping_Estimate__c se5 = new Shipping_Estimate__c();
        se5.Shipping_Summary__c = ses.Id;
        se5.Estimated_Shipping_Date__c = System.today().addMonths(6);
        se5.Estimated_Shipping_Quantity__c = 6;
        se5.Shipping_Notes__c = 'Note 6';
        el.add(se5);

        Shipping_Estimate__c se6 = new Shipping_Estimate__c();
        se6.Shipping_Summary__c = ses.Id;
        se6.Estimated_Shipping_Date__c = System.today().addMonths(10);
        se6.Estimated_Shipping_Quantity__c = 7;
        se6.Shipping_Notes__c = 'Note 7';
        el.add(se6);

        insert el;
        el = [SELECT Id, Shipping_Summary__c, Estimated_Shipping_Date__c, Estimated_Shipping_Quantity__c,
            Shipping_Notes__c FROM Shipping_Estimate__c WHERE Shipping_Summary__c = :ses.Id]; */

        List<Id> gIdList = new List<Id>();
        gIdList.add(qlGroup.Id);
        QuoteLineGroupHandler.rollupQLGQuantities(gIdList);
        /* ARMAN: List<Id> seIdList = new List<Id>();
        for (Shipping_Estimate__c est : el){
            seIdList.add(est.Id);
        }
        // TODO What is this?
        QuoteLineGroupHandler.calculateMaxShippingDate(seIdList);
        OpportunityFinancialsHandler.calculateMaxShippingDate(seIdList); */

        sbQuote.SBQQ__Primary__c = true;
		update sbQuote;
		List<OpportunityLineItem> opportunityLineItems = util.createOppLineItems(opportunity, sbQuoteLines, pricebookEntries);
        System.debug(LoggingLevel.WARN, 'OpportunityFinancialsHandlerTest: ' + opportunityLineItems.size());
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


        List<Opportunity> closedOppList = new List<Opportunity>();
        closedOppList.add(opportunity);

        OpportunityFinancialsHandler.calculateOpportunityFinancials(closedOppList);

        Test.stopTest();
    }

    // By Arman:
    @isTest
    public static void testCalculateOpportunityFinancials_oppId() {
        Account account = util.createAccount('ABC Test Account');
        Opportunity opp = util.createNewOpportunity('Test Opportunity 1', account,
                'Products, Services and Maintenance', 'New');
        SBQQ__Quote__c sbQuote = util.createSBQuote(opp, account, Date.today(), false);

        Test.startTest();
        OpportunityFinancialsHandler.calculateOpportunityFinancials(opp.Id);
        Test.stopTest();
    }
}