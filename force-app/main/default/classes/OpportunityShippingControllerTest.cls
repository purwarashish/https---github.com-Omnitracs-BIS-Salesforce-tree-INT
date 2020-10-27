@isTest
public class OpportunityShippingControllerTest {

    public static VistaAssetHelperUtil util = new VistaAssetHelperUtil();

    @isTest
    public static void OpportunityShippingControllerTest_Dummy() {
        insert new ByPassTrigger__c(SetupOwnerId=UserInfo.getOrganizationId(), isDisabled__c=true, Name='Testing Bypass');

        Shipping_Estimate_Summary__c ses = new Shipping_Estimate_Summary__c();
        insert ses;

        ApexPages.StandardController sc = new ApexPages.StandardController(ses);

        Test.startTest();
        OpportunityShippingController osc = new OpportunityShippingController(sc);
        Test.stopTest();
    }

    /************ By  ARMAN ******************/
    /* public static void OpportunityShippingControllerTest() {

        insert new ByPassTrigger__c(SetupOwnerId=UserInfo.getOrganizationId(), isDisabled__c=true, Name='Testing Bypass');

        Account account = util.createAccount('ABC Test Account');
        List<Product2> productList = new List<Product2>();
        //subPricingType = 'Fixed Price' or 'Percent Of Total'
        productList.addAll(util.initProductSet(5, 'Hardware', '', 'Fixed Price'));
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

        Test.startTest();
        Shipping_Estimate_Summary__c ses = new Shipping_Estimate_Summary__c();
        ses.Quote_Line_Group__c = qlGroup.Id;
        insert ses;

        List<Shipping_Estimate__c> el = new List<Shipping_Estimate__c>();
        Shipping_Estimate__c se = new Shipping_Estimate__c();
        se.Shipping_Summary__c = ses.Id;
        se.Estimated_Shipping_Date__c = System.today();
        se.Estimated_Shipping_Quantity__c = 1;
        se.Shipping_Notes__c = 'Note 1';
        el.add(se);

        Shipping_Estimate__c se1 = new Shipping_Estimate__c();
        se1.Shipping_Summary__c = ses.Id;
        se1.Estimated_Shipping_Date__c = System.today();
        se1.Estimated_Shipping_Quantity__c = 1;
        se1.Shipping_Notes__c = 'Note 2';
        el.add(se1);

        insert el;

        ApexPages.StandardController sc = new ApexPages.StandardController(ses);
        OpportunityShippingController controller = new OpportunityShippingController(sc);
        PageReference pageRef = Page.OpportunityShippingMaintenance;
        pageRef.getParameters().put('qlGroupId',String.valueOf(qlGroup.Id));
        Test.setCurrentPage(pageRef);

        controller.passedQLGroupId = qlGroup.Id;

        //controller.quote = sbQuote;
        //controller.quoteLine = sbQuoteLines[0];
        //controller.quoteLineGroup = qlGroup.Name;
        controller.summary = ses;
        controller.setupBasics();
        //controller.getShippingEstimateSummary(qlGroup.Id);
        //controller.getShippingEstimates(ses);
        //controller.getQuoteLineGroupItems();
        controller.addRow();

        controller.shippingEstimateList = el;
        controller.deleteEstimateList = el;

        pageRef.getParameters().put('rowIndex',String.valueOf(1));
        try{
            String nextPage = controller.saveShippingSummary().getUrl();
        }catch (Exception ex){

        }

        try{
            //String nextPage = controller.saveShippingEstimates().getUrl();
            String nextPage = controller.saveShippingSummary().getUrl();
        }catch (Exception ex){

        }

        try{
            //String nextPage = controller.deleteShippingEstimate().getUrl();
            String nextPage = controller.saveShippingSummary().getUrl();
        }catch (Exception ex){

        }

        controller.closePage();

        Test.stopTest();
    } */


}