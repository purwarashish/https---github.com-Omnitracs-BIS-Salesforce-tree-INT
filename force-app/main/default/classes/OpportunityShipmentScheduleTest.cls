@istest//(SeeAllData=True) 
public class OpportunityShipmentScheduleTest {
    public static VistaAssetHelperUtil util = new VistaAssetHelperUtil();
    
    @testSetup
    static void setupData() {
        TestUtils.defineCustomSettings();
    }
    
    public static testMethod void TestOppShipmentSchedule() {
        
        Account account = util.createAccount('ABC Test Account');
        account.QWBS_Cust_ID__c = 'Test12345678';
        update account;
        OpportunityTestData opportunityTestData  = new OpportunityTestData();
        List<Contact> contactList =  opportunityTestData.ContactCreation('validateOpptyEditability', 1, account.Id);
        insert contactList;
        Opportunity opportunity = new Opportunity();
        opportunity.name = 'Shipment Schedule Test Opp';
        opportunity.StageName = 'Negotiate';
        opportunity.CloseDate = Date.today();
        insert opportunity;
        Contract contract = util.createContract(opportunity, account, 'Customer - MSA', Date.today());
        List<Product2> productList = new List<Product2>();
        productList.addAll(util.initProductSet(1, 'Hardware', '', 'Fixed Price', 'Monthly'));
        Product2 Prod1 = productList.get(0);
        Prod1.Productcode = 'T-123';
        update prod1;
        Map<Id, PricebookEntry> pricebookEntries = new Map<Id, PricebookEntry>();
        pricebookEntries = util.initPricebook(productList);
        SBQQ__Quote__c sbQuote = util.createSBQuote(opportunity, account, Date.today(), true);
        sbQuote.SBQQ__Status__c = 'Draft';
        sbQuote.SBQQ__Primary__c = true;
        sbquote.Delivery_Schedule__c = '3';
        sbQuote.Schedule_Type__c = 'Level Load'; 
        sbQuote.Expected_Shipment_Start__c = date.today()+31;
        update sbQuote;
        contract.SBQQ__Quote__c = sbQuote.Id;
        update contract;
        List<SBQQ__Quoteline__c> sbQuoteLines = util.createSBQuoteLines(sbQuote, pricebookEntries, true, 10);
        SBQQ__QuoteLine__c quoteline1 = sbQuoteLines.get(0);
        quoteline1.SBQQ__Quantity__c = 30;
        quoteline1.SBQQ__PriorQuantity__c = 0;
        quoteline1.SBQQ__Product__c = Prod1.id;
        Update quoteline1;

        opportunity.SBQQ__PrimaryQuote__c = sbQuote.Id;
        opportunity.Contract__c = contract.Id;
        update opportunity;
        
        Shipping_line__c SL1 = new Shipping_line__c(Opportunity__c = opportunity.id, Quote__c = sbQuote.id, Shipping_Date__c = Date.today()+31);
        insert SL1;
        Shipping_line__c SL2 = new Shipping_line__c(Opportunity__c = opportunity.id, Quote__c = sbQuote.id, Shipping_Date__c = Date.today()+61);
        insert SL2;
        Shipping_line__c SL3 = new Shipping_line__c(Opportunity__c = opportunity.id, Quote__c = sbQuote.id, Shipping_Date__c = Date.today()+91);
        insert SL3;
        
        Shipping_Line_Item__c SLI11 = new Shipping_Line_Item__c(Product__c = Prod1.id, ProductCode__c = Prod1.ProductCode, Quantity__c = 10, Quote_Line__c = quoteline1.id, Shipping_Line__c = SL1.id);
        insert SLI11;
        
        Shipping_Line_Item__c SLI21 = new Shipping_Line_Item__c(Product__c = Prod1.id, ProductCode__c = Prod1.ProductCode, Quantity__c = 10, Quote_Line__c = quoteline1.id, Shipping_Line__c = SL2.id);
        insert SLI21;
        
        Shipping_Line_Item__c SLI31 = new Shipping_Line_Item__c(Product__c = Prod1.id, ProductCode__c = Prod1.ProductCode, Quantity__c = 10, Quote_Line__c = quoteline1.id, Shipping_Line__c = SL3.id);
        insert SLI31;
        
        Test.startTest();
  
        ApexPages.StandardController OC = new ApexPages.StandardController(opportunity);
        OpportunityShipmentScheduleController controller = new OpportunityShipmentScheduleController(OC);
        PageReference pageRef = Page.Opportunity_ShipmentSchedule;
        pageRef.getParameters().put('id', String.valueOf(opportunity.Id));
        system.Test.setCurrentPage(pageRef);
        controller.AddShip();
        controller.BacktoOpportunity();
        controller.save();

        test.stoptest();
    }
        
}