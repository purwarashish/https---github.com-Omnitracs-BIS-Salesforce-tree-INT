/**
 * Test class for the Revenue Forecast Handler
 */

@isTest
public class RevenueForecastHandlerTest {

    public static testMethod void testEmpty() {
        Test.startTest();
        RevenueForecastHandler rfh = new RevenueForecastHandler();
        Test.stopTest();
    }

    /* ARMAN: public static VistaAssetHelperUtil util = new VistaAssetHelperUtil();

    @isTest
    public static void testCalculateCustomerAssetFinancialsHardware() {

        insert new ByPassTrigger__c(SetupOwnerId = UserInfo.getOrganizationId(), isDisabled__c = true, Name = 'Testing Bypass');


        Account newAccount = new Account();
        newAccount.Name = 'Test Account';
        newAccount.BillingCountry = 'USA';
        insert newAccount;

        List<Product2> productList = new List<Product2>();
        //subPricingType = 'Fixed Price' or 'Percent Of Total'
        productList.addAll(util.initProductSet(1, 'Hardware', '', 'Once', 'Monthly'));
        Map<Id, PricebookEntry> pricebookEntries = new Map<Id, PricebookEntry>();
        pricebookEntries = util.initPricebook(productList);

        Customer_Asset__c newAsset = new Customer_Asset__c();
        newAsset.Name = 'Test Asset';
        newAsset.Quantity__c = 1;
        newAsset.Total_One_Time_Fee_s__c = 1.00;
        newAsset.Annual_Recurring_Revenue__c = 1.00;
        newAsset.Product__c = productList[0].Id;
        newAsset.Term_Start_Date__c = System.today();
        newAsset.Term_End_Date__c = System.today().addMonths(12);
        newAsset.Account__c = newAccount.Id;
        newAsset.Asset_Status__c = 'Active';
        insert newAsset;

        Customer_Asset_Shipping_Summary__c ss = new Customer_Asset_Shipping_Summary__c();
        ss.Customer_Asset__c = newAsset.Id;
        insert ss;

        List<Customer_Asset_Shipping_Actual__c> al = new List<Customer_Asset_Shipping_Actual__c>();
        Customer_Asset_Shipping_Actual__c sa = new Customer_Asset_Shipping_Actual__c();
        sa.Actual_Shipped_Date__c = System.today();
        sa.Actual_Shipped_Quantity__c = 1;
        sa.Customer_Asset_Shipping_Summary__c = ss.Id;
        al.add(sa);

        Customer_Asset_Shipping_Actual__c sa1 = new Customer_Asset_Shipping_Actual__c();
        sa1.Actual_Shipped_Date__c = System.today();
        sa1.Actual_Shipped_Quantity__c = 1;
        sa1.Customer_Asset_Shipping_Summary__c = ss.Id;
        al.add(sa1);

        insert al;

        List<Customer_Asset_Shipping_Estimate__c> el = new List<Customer_Asset_Shipping_Estimate__c>();
        Customer_Asset_Shipping_Estimate__c se = new Customer_Asset_Shipping_Estimate__c();
        se.Customer_Asset_Shipping_Summary__c = ss.Id;
        se.Estimated_Shipping_Date__c = System.today();
        se.Estimated_Shipping_Quantity__c = 1;
        el.add(se);

        Customer_Asset_Shipping_Estimate__c se1 = new Customer_Asset_Shipping_Estimate__c();
        se1.Customer_Asset_Shipping_Summary__c = ss.Id;
        se1.Estimated_Shipping_Date__c = System.today();
        se1.Estimated_Shipping_Quantity__c = 1;
        el.add(se1);

        insert el;

        Test.startTest();
        RevenueForecastHandler.calculateCustomerAssetFinancials(newAsset.Id);
        Test.stopTest();

    }

    @isTest
    public static void testCalculateCustomerAssetFinancialsSoftwareApplications() {

        insert new ByPassTrigger__c(SetupOwnerId = UserInfo.getOrganizationId(), isDisabled__c = true, Name = 'Testing Bypass');


        Account newAccount = new Account();
        newAccount.Name = 'Test Account';
        newAccount.BillingCountry = 'USA';
        insert newAccount;

        List<Product2> productList = new List<Product2>();
        //subPricingType = 'Fixed Price' or 'Percent Of Total'
        productList.addAll(util.initProductSet(1, 'Software', 'Applications', 'Fixed Price', 'Monthly'));
        Map<Id, PricebookEntry> pricebookEntries = new Map<Id, PricebookEntry>();
        pricebookEntries = util.initPricebook(productList);

        Customer_Asset__c newAsset = new Customer_Asset__c();
        newAsset.Name = 'Test Asset';
        newAsset.Quantity__c = 1;
        newAsset.Total_One_Time_Fee_s__c = 1.00;
        newAsset.Annual_Recurring_Revenue__c = 1.00;
        newAsset.Product__c = productList[0].Id;
        newAsset.Term_Start_Date__c = System.today();
        newAsset.Term_End_Date__c = System.today().addMonths(12);
        newAsset.Account__c = newAccount.Id;
        newAsset.Asset_Status__c = 'Active';
        insert newAsset;

        Customer_Asset_Shipping_Summary__c ss = new Customer_Asset_Shipping_Summary__c();
        ss.Customer_Asset__c = newAsset.Id;
        insert ss;

        List<Customer_Asset_Shipping_Actual__c> al = new List<Customer_Asset_Shipping_Actual__c>();
        Customer_Asset_Shipping_Actual__c sa = new Customer_Asset_Shipping_Actual__c();
        sa.Actual_Shipped_Date__c = System.today();
        sa.Actual_Shipped_Quantity__c = 1;
        sa.Customer_Asset_Shipping_Summary__c = ss.Id;
        al.add(sa);

        Customer_Asset_Shipping_Actual__c sa1 = new Customer_Asset_Shipping_Actual__c();
        sa1.Actual_Shipped_Date__c = System.today();
        sa1.Actual_Shipped_Quantity__c = 1;
        sa1.Customer_Asset_Shipping_Summary__c = ss.Id;
        al.add(sa1);

        insert al;

        List<Customer_Asset_Shipping_Estimate__c> el = new List<Customer_Asset_Shipping_Estimate__c>();
        Customer_Asset_Shipping_Estimate__c se = new Customer_Asset_Shipping_Estimate__c();
        se.Customer_Asset_Shipping_Summary__c = ss.Id;
        se.Estimated_Shipping_Date__c = System.today();
        se.Estimated_Shipping_Quantity__c = 1;
        el.add(se);

        Customer_Asset_Shipping_Estimate__c se1 = new Customer_Asset_Shipping_Estimate__c();
        se1.Customer_Asset_Shipping_Summary__c = ss.Id;
        se1.Estimated_Shipping_Date__c = System.today();
        se1.Estimated_Shipping_Quantity__c = 1;
        el.add(se1);

        insert el;

        Test.startTest();
        RevenueForecastHandler.calculateCustomerAssetFinancials(newAsset.Id);
        Test.stopTest();

    }

    @isTest
    public static void testCalculateCustomerAssetFinancialsSoftwareServicePlans() {

        insert new ByPassTrigger__c(SetupOwnerId = UserInfo.getOrganizationId(), isDisabled__c = true, Name = 'Testing Bypass');

        Account newAccount = new Account();
        newAccount.Name = 'Test Account';
        newAccount.BillingCountry = 'USA';
        insert newAccount;

        List<Product2> productList = new List<Product2>();
        //subPricingType = 'Fixed Price' or 'Percent Of Total'
        productList.addAll(util.initProductSet(1, 'Software', 'Service Plans', 'Fixed Price', 'Monthly'));
        Map<Id, PricebookEntry> pricebookEntries = new Map<Id, PricebookEntry>();
        pricebookEntries = util.initPricebook(productList);

        Customer_Asset__c newAsset = new Customer_Asset__c();
        newAsset.Name = 'Test Asset';
        newAsset.Quantity__c = 1;
        newAsset.Total_One_Time_Fee_s__c = 1.00;
        newAsset.Annual_Recurring_Revenue__c = 1.00;
        newAsset.Product__c = productList[0].Id;
        newAsset.Term_Start_Date__c = System.today();
        newAsset.Term_End_Date__c = System.today().addMonths(12);
        newAsset.Account__c = newAccount.Id;
        newAsset.Asset_Status__c = 'Active';
        insert newAsset;

        Customer_Asset_Shipping_Summary__c ss = new Customer_Asset_Shipping_Summary__c();
        ss.Customer_Asset__c = newAsset.Id;
        insert ss;

        List<Customer_Asset_Shipping_Actual__c> al = new List<Customer_Asset_Shipping_Actual__c>();
        Customer_Asset_Shipping_Actual__c sa = new Customer_Asset_Shipping_Actual__c();
        sa.Actual_Shipped_Date__c = System.today();
        sa.Actual_Shipped_Quantity__c = 1;
        sa.Customer_Asset_Shipping_Summary__c = ss.Id;
        al.add(sa);

        Customer_Asset_Shipping_Actual__c sa1 = new Customer_Asset_Shipping_Actual__c();
        sa1.Actual_Shipped_Date__c = System.today();
        sa1.Actual_Shipped_Quantity__c = 1;
        sa1.Customer_Asset_Shipping_Summary__c = ss.Id;
        al.add(sa1);

        insert al;

        List<Customer_Asset_Shipping_Estimate__c> el = new List<Customer_Asset_Shipping_Estimate__c>();
        Customer_Asset_Shipping_Estimate__c se = new Customer_Asset_Shipping_Estimate__c();
        se.Customer_Asset_Shipping_Summary__c = ss.Id;
        se.Estimated_Shipping_Date__c = System.today();
        se.Estimated_Shipping_Quantity__c = 1;
        el.add(se);

        Customer_Asset_Shipping_Estimate__c se1 = new Customer_Asset_Shipping_Estimate__c();
        se1.Customer_Asset_Shipping_Summary__c = ss.Id;
        se1.Estimated_Shipping_Date__c = System.today();
        se1.Estimated_Shipping_Quantity__c = 1;
        el.add(se1);

        insert el;

        Test.startTest();
        RevenueForecastHandler.calculateCustomerAssetFinancials(newAsset.Id);
        Test.stopTest();

    }

    @isTest
    public static void testCalculateCustomerAssetFinancialsSoftwareOther() {

        insert new ByPassTrigger__c(SetupOwnerId = UserInfo.getOrganizationId(), isDisabled__c = true, Name = 'Testing Bypass');

        Account newAccount = new Account();
        newAccount.Name = 'Test Account';
        newAccount.BillingCountry = 'USA';
        insert newAccount;

        List<Product2> productList = new List<Product2>();
        //subPricingType = 'Fixed Price' or 'Percent Of Total'
        productList.addAll(util.initProductSet(1, 'Software', 'Other', 'Fixed Price', 'Monthly'));
        Map<Id, PricebookEntry> pricebookEntries = new Map<Id, PricebookEntry>();
        pricebookEntries = util.initPricebook(productList);

        Customer_Asset__c newAsset = new Customer_Asset__c();
        newAsset.Name = 'Test Asset';
        newAsset.Quantity__c = 1;
        newAsset.Total_One_Time_Fee_s__c = 1.00;
        newAsset.Annual_Recurring_Revenue__c = 1.00;
        newAsset.Product__c = productList[0].Id;
        newAsset.Term_Start_Date__c = System.today();
        newAsset.Term_End_Date__c = System.today().addMonths(12);
        newAsset.Account__c = newAccount.Id;
        newAsset.Asset_Status__c = 'Active';
        insert newAsset;

        Customer_Asset_Shipping_Summary__c ss = new Customer_Asset_Shipping_Summary__c();
        ss.Customer_Asset__c = newAsset.Id;
        insert ss;

        List<Customer_Asset_Shipping_Actual__c> al = new List<Customer_Asset_Shipping_Actual__c>();
        Customer_Asset_Shipping_Actual__c sa = new Customer_Asset_Shipping_Actual__c();
        sa.Actual_Shipped_Date__c = System.today();
        sa.Actual_Shipped_Quantity__c = 1;
        sa.Customer_Asset_Shipping_Summary__c = ss.Id;
        al.add(sa);

        Customer_Asset_Shipping_Actual__c sa1 = new Customer_Asset_Shipping_Actual__c();
        sa1.Actual_Shipped_Date__c = System.today();
        sa1.Actual_Shipped_Quantity__c = 1;
        sa1.Customer_Asset_Shipping_Summary__c = ss.Id;
        al.add(sa1);

        insert al;

        List<Customer_Asset_Shipping_Estimate__c> el = new List<Customer_Asset_Shipping_Estimate__c>();
        Customer_Asset_Shipping_Estimate__c se = new Customer_Asset_Shipping_Estimate__c();
        se.Customer_Asset_Shipping_Summary__c = ss.Id;
        se.Estimated_Shipping_Date__c = System.today();
        se.Estimated_Shipping_Quantity__c = 1;
        el.add(se);

        Customer_Asset_Shipping_Estimate__c se1 = new Customer_Asset_Shipping_Estimate__c();
        se1.Customer_Asset_Shipping_Summary__c = ss.Id;
        se1.Estimated_Shipping_Date__c = System.today();
        se1.Estimated_Shipping_Quantity__c = 1;
        el.add(se1);

        insert el;

        Test.startTest();
        RevenueForecastHandler.calculateCustomerAssetFinancials(newAsset.Id);
        Test.stopTest();

    }

    @isTest
    public static void testCalculateCustomerAssetFinancialsHardwareOnce() {

        insert new ByPassTrigger__c(SetupOwnerId = UserInfo.getOrganizationId(), isDisabled__c = true, Name = 'Testing Bypass');


        Account newAccount = new Account();
        newAccount.Name = 'Test Account';
        newAccount.BillingCountry = 'USA';
        insert newAccount;

        List<Product2> productList = new List<Product2>();
        //subPricingType = 'Fixed Price' or 'Percent Of Total'
        productList.addAll(util.initProductSet(1, 'Hardware', '', 'Once', 'Monthly', 'Once'));
        Map<Id, PricebookEntry> pricebookEntries = new Map<Id, PricebookEntry>();
        pricebookEntries = util.initPricebook(productList);

        Customer_Asset__c newAsset = new Customer_Asset__c();
        newAsset.Name = 'Test Asset';
        newAsset.Quantity__c = 1;
        newAsset.Total_One_Time_Fee_s__c = 1.00;
        newAsset.Annual_Recurring_Revenue__c = 1.00;
        newAsset.Product__c = productList[0].Id;
        newAsset.Term_Start_Date__c = System.today();
        newAsset.Term_End_Date__c = System.today().addMonths(12);
        newAsset.Account__c = newAccount.Id;
        newAsset.Asset_Status__c = 'Active';
        insert newAsset;

        Customer_Asset_Shipping_Summary__c ss = new Customer_Asset_Shipping_Summary__c();
        ss.Customer_Asset__c = newAsset.Id;
        insert ss;

        List<Customer_Asset_Shipping_Actual__c> al = new List<Customer_Asset_Shipping_Actual__c>();
        Customer_Asset_Shipping_Actual__c sa = new Customer_Asset_Shipping_Actual__c();
        sa.Actual_Shipped_Date__c = System.today();
        sa.Actual_Shipped_Quantity__c = 1;
        sa.Customer_Asset_Shipping_Summary__c = ss.Id;
        al.add(sa);

        Customer_Asset_Shipping_Actual__c sa1 = new Customer_Asset_Shipping_Actual__c();
        sa1.Actual_Shipped_Date__c = System.today();
        sa1.Actual_Shipped_Quantity__c = 1;
        sa1.Customer_Asset_Shipping_Summary__c = ss.Id;
        al.add(sa1);

        insert al;

        List<Customer_Asset_Shipping_Estimate__c> el = new List<Customer_Asset_Shipping_Estimate__c>();
        Customer_Asset_Shipping_Estimate__c se = new Customer_Asset_Shipping_Estimate__c();
        se.Customer_Asset_Shipping_Summary__c = ss.Id;
        se.Estimated_Shipping_Date__c = System.today();
        se.Estimated_Shipping_Quantity__c = 1;
        el.add(se);

        Customer_Asset_Shipping_Estimate__c se1 = new Customer_Asset_Shipping_Estimate__c();
        se1.Customer_Asset_Shipping_Summary__c = ss.Id;
        se1.Estimated_Shipping_Date__c = System.today();
        se1.Estimated_Shipping_Quantity__c = 1;
        el.add(se1);

        insert el;

        Test.startTest();
        RevenueForecastHandler.calculateCustomerAssetFinancials(newAsset.Id);
        Test.stopTest();

    }

    @isTest
    public static void testCalculateCustomerAssetFinancialsSoftwareApplicationsOnce() {

        insert new ByPassTrigger__c(SetupOwnerId = UserInfo.getOrganizationId(), isDisabled__c = true, Name = 'Testing Bypass');


        Account newAccount = new Account();
        newAccount.Name = 'Test Account';
        newAccount.BillingCountry = 'USA';
        insert newAccount;

        List<Product2> productList = new List<Product2>();
        //subPricingType = 'Fixed Price' or 'Percent Of Total'
        productList.addAll(util.initProductSet(1, 'Software', 'Applications', 'Fixed Price', 'Monthly', 'Once'));
        Map<Id, PricebookEntry> pricebookEntries = new Map<Id, PricebookEntry>();
        pricebookEntries = util.initPricebook(productList);

        Customer_Asset__c newAsset = new Customer_Asset__c();
        newAsset.Name = 'Test Asset';
        newAsset.Quantity__c = 1;
        newAsset.Total_One_Time_Fee_s__c = 1.00;
        newAsset.Annual_Recurring_Revenue__c = 1.00;
        newAsset.Product__c = productList[0].Id;
        newAsset.Term_Start_Date__c = System.today();
        newAsset.Term_End_Date__c = System.today().addMonths(12);
        newAsset.Account__c = newAccount.Id;
        newAsset.Asset_Status__c = 'Active';
        insert newAsset;

        Customer_Asset_Shipping_Summary__c ss = new Customer_Asset_Shipping_Summary__c();
        ss.Customer_Asset__c = newAsset.Id;
        insert ss;

        List<Customer_Asset_Shipping_Actual__c> al = new List<Customer_Asset_Shipping_Actual__c>();
        Customer_Asset_Shipping_Actual__c sa = new Customer_Asset_Shipping_Actual__c();
        sa.Actual_Shipped_Date__c = System.today();
        sa.Actual_Shipped_Quantity__c = 1;
        sa.Customer_Asset_Shipping_Summary__c = ss.Id;
        al.add(sa);

        Customer_Asset_Shipping_Actual__c sa1 = new Customer_Asset_Shipping_Actual__c();
        sa1.Actual_Shipped_Date__c = System.today();
        sa1.Actual_Shipped_Quantity__c = 1;
        sa1.Customer_Asset_Shipping_Summary__c = ss.Id;
        al.add(sa1);

        insert al;

        List<Customer_Asset_Shipping_Estimate__c> el = new List<Customer_Asset_Shipping_Estimate__c>();
        Customer_Asset_Shipping_Estimate__c se = new Customer_Asset_Shipping_Estimate__c();
        se.Customer_Asset_Shipping_Summary__c = ss.Id;
        se.Estimated_Shipping_Date__c = System.today();
        se.Estimated_Shipping_Quantity__c = 1;
        el.add(se);

        Customer_Asset_Shipping_Estimate__c se1 = new Customer_Asset_Shipping_Estimate__c();
        se1.Customer_Asset_Shipping_Summary__c = ss.Id;
        se1.Estimated_Shipping_Date__c = System.today();
        se1.Estimated_Shipping_Quantity__c = 1;
        el.add(se1);

        insert el;

        Test.startTest();
        RevenueForecastHandler.calculateCustomerAssetFinancials(newAsset.Id);
        Test.stopTest();

    }

    @isTest
    public static void testCalculateCustomerAssetFinancialsSoftwareServicePlansOnce() {

        insert new ByPassTrigger__c(SetupOwnerId = UserInfo.getOrganizationId(), isDisabled__c = true, Name = 'Testing Bypass');

        Account newAccount = new Account();
        newAccount.Name = 'Test Account';
        newAccount.BillingCountry = 'USA';
        insert newAccount;

        List<Product2> productList = new List<Product2>();
        //subPricingType = 'Fixed Price' or 'Percent Of Total'
        productList.addAll(util.initProductSet(1, 'Software', 'Service Plans', 'Fixed Price', 'Monthly', 'Once'));
        Map<Id, PricebookEntry> pricebookEntries = new Map<Id, PricebookEntry>();
        pricebookEntries = util.initPricebook(productList);

        Customer_Asset__c newAsset = new Customer_Asset__c();
        newAsset.Name = 'Test Asset';
        newAsset.Quantity__c = 1;
        newAsset.Total_One_Time_Fee_s__c = 1.00;
        newAsset.Annual_Recurring_Revenue__c = 1.00;
        newAsset.Product__c = productList[0].Id;
        newAsset.Term_Start_Date__c = System.today();
        newAsset.Term_End_Date__c = System.today().addMonths(12);
        newAsset.Account__c = newAccount.Id;
        newAsset.Asset_Status__c = 'Active';
        insert newAsset;

        Customer_Asset_Shipping_Summary__c ss = new Customer_Asset_Shipping_Summary__c();
        ss.Customer_Asset__c = newAsset.Id;
        insert ss;

        List<Customer_Asset_Shipping_Actual__c> al = new List<Customer_Asset_Shipping_Actual__c>();
        Customer_Asset_Shipping_Actual__c sa = new Customer_Asset_Shipping_Actual__c();
        sa.Actual_Shipped_Date__c = System.today();
        sa.Actual_Shipped_Quantity__c = 1;
        sa.Customer_Asset_Shipping_Summary__c = ss.Id;
        al.add(sa);

        Customer_Asset_Shipping_Actual__c sa1 = new Customer_Asset_Shipping_Actual__c();
        sa1.Actual_Shipped_Date__c = System.today();
        sa1.Actual_Shipped_Quantity__c = 1;
        sa1.Customer_Asset_Shipping_Summary__c = ss.Id;
        al.add(sa1);

        insert al;

        List<Customer_Asset_Shipping_Estimate__c> el = new List<Customer_Asset_Shipping_Estimate__c>();
        Customer_Asset_Shipping_Estimate__c se = new Customer_Asset_Shipping_Estimate__c();
        se.Customer_Asset_Shipping_Summary__c = ss.Id;
        se.Estimated_Shipping_Date__c = System.today();
        se.Estimated_Shipping_Quantity__c = 1;
        el.add(se);

        Customer_Asset_Shipping_Estimate__c se1 = new Customer_Asset_Shipping_Estimate__c();
        se1.Customer_Asset_Shipping_Summary__c = ss.Id;
        se1.Estimated_Shipping_Date__c = System.today();
        se1.Estimated_Shipping_Quantity__c = 1;
        el.add(se1);

        insert el;

        Test.startTest();
        RevenueForecastHandler.calculateCustomerAssetFinancials(newAsset.Id);
        Test.stopTest();

    }

    @isTest
    public static void testCalculateCustomerAssetFinancialsSoftwareOtherOnce() {

        insert new ByPassTrigger__c(SetupOwnerId = UserInfo.getOrganizationId(), isDisabled__c = true, Name = 'Testing Bypass');

        Account newAccount = new Account();
        newAccount.Name = 'Test Account';
        newAccount.BillingCountry = 'USA';
        insert newAccount;

        List<Product2> productList = new List<Product2>();
        //subPricingType = 'Fixed Price' or 'Percent Of Total'
        productList.addAll(util.initProductSet(1, 'Software', 'Other', 'Fixed Price', 'Monthly', 'Once'));
        Map<Id, PricebookEntry> pricebookEntries = new Map<Id, PricebookEntry>();
        pricebookEntries = util.initPricebook(productList);

        Customer_Asset__c newAsset = new Customer_Asset__c();
        newAsset.Name = 'Test Asset';
        newAsset.Quantity__c = 1;
        newAsset.Total_One_Time_Fee_s__c = 1.00;
        newAsset.Annual_Recurring_Revenue__c = 1.00;
        newAsset.Product__c = productList[0].Id;
        newAsset.Term_Start_Date__c = System.today();
        newAsset.Term_End_Date__c = System.today().addMonths(12);
        newAsset.Account__c = newAccount.Id;
        newAsset.Asset_Status__c = 'Active';
        insert newAsset;

        Customer_Asset_Shipping_Summary__c ss = new Customer_Asset_Shipping_Summary__c();
        ss.Customer_Asset__c = newAsset.Id;
        insert ss;

        List<Customer_Asset_Shipping_Actual__c> al = new List<Customer_Asset_Shipping_Actual__c>();
        Customer_Asset_Shipping_Actual__c sa = new Customer_Asset_Shipping_Actual__c();
        sa.Actual_Shipped_Date__c = System.today();
        sa.Actual_Shipped_Quantity__c = 1;
        sa.Customer_Asset_Shipping_Summary__c = ss.Id;
        al.add(sa);

        Customer_Asset_Shipping_Actual__c sa1 = new Customer_Asset_Shipping_Actual__c();
        sa1.Actual_Shipped_Date__c = System.today();
        sa1.Actual_Shipped_Quantity__c = 1;
        sa1.Customer_Asset_Shipping_Summary__c = ss.Id;
        al.add(sa1);

        insert al;

        List<Customer_Asset_Shipping_Estimate__c> el = new List<Customer_Asset_Shipping_Estimate__c>();
        Customer_Asset_Shipping_Estimate__c se = new Customer_Asset_Shipping_Estimate__c();
        se.Customer_Asset_Shipping_Summary__c = ss.Id;
        se.Estimated_Shipping_Date__c = System.today();
        se.Estimated_Shipping_Quantity__c = 1;
        el.add(se);

        Customer_Asset_Shipping_Estimate__c se1 = new Customer_Asset_Shipping_Estimate__c();
        se1.Customer_Asset_Shipping_Summary__c = ss.Id;
        se1.Estimated_Shipping_Date__c = System.today();
        se1.Estimated_Shipping_Quantity__c = 1;
        el.add(se1);

        insert el;

        Test.startTest();
        RevenueForecastHandler.calculateCustomerAssetFinancials(newAsset.Id);
        Test.stopTest();

    }*/
}