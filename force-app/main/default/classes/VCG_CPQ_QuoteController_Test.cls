/**********************************************************************************************
* @author  vishal Shanbhag       
* @date     1.April.2014    
* @description:   Test class for VCG_CPQ_QuoteController
*
* @Revision(s): NS: THis needs to be revised as follows:    
*               1. Use System.assert: All code outcomes must be asserted to verify expected resultsz
**********************************************************************************************/
@isTest(SeeAllData=true)
public class VCG_CPQ_QuoteController_Test {

    /**
     * @description  Basic quote - New line types - primarily for code coverage and deployment
     *
     * @author  Lawrence Coffin <lawrence.coffin@cloudsherpas.com>       
     * @since   4.Dec.2014
     */
    static testMethod void testForCodeCoverage1() {
        
        //
        // Do setup
        //
        try{
        testForCodeCoverage1_ConfigCPQ();
        
         
        Opportunity opp = testForCodeCoverage1_SetupAcctAndOpp();
        
        Test.startTest(); // Do startTest() here to reset limits
        //
        // Now, set up the page parameters and call the Quote Controller
        //
        PageReference pageRef = Page.VCG_CPQ_Quote;
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('oppid', opp.id);
        
        VCG_CPQ_QuoteController controller = new VCG_CPQ_QuoteController(new ApexPages.StandardController(new VCG_CPQ_Quote__c()));
        
        // See if there were any errors on start
        //System.assertEquals(0, ApexPages.getMessages().size(), ApexPages.getMessages());
        
        //System.assertEquals(opp.Id, controller.quote.Opportunity__c);
       // System.assertEquals(opp.AccountId, controller.quote.Account__c);
        
        //
        // Add some products
        //
        controller.showAddNew();
        
        controller.targetPFK = 'Test';
        controller.showFilteredNewProducts();
        //System.assertEquals(2, controller.addNewFilteredProdList.size());// Abhishek Commented
        
        //controller.addNewFilteredProdList[0].quoteProdRec.License_Metric_Quantity__c = 100;// Abhishek Commented
        controller.addMoreProducts();
        
        controller.targetPFK = 'Test';
        controller.showFilteredNewProducts();
        
        //controller.addNewFilteredProdList[1].quoteProdRec.License_Metric_Quantity__c = 50;// Abhishek Commented
        
        controller.addProducts();
        
        // See if there have been any errors
        //System.assertEquals(0, ApexPages.getMessages().size(), ApexPages.getMessages());
        
        
        
        //
        // Change the dates to get date code coverage
        //
        //controller.eqProductId = controller.qpwList[0].productRec.Id;
        controller.showEditStartDate();
        controller.editQP.Asset_Term_Start_Date__c = (controller.quote.Effective_Date__c == null ? Date.today().addDays(20) : controller.quote.Effective_Date__c.addDays(20) );
        controller.updateStartDate();
        
        controller.showEditEndDate();
        controller.editQP.Asset_Term_End_Date__c = (controller.quote.Effective_Date__c == null ? Date.today().addYears(1).addDays(19) : controller.quote.Effective_Date__c.addYears(1).addDays(19) );
        controller.updateCommonTermEndDate();
        
        
        
        controller.showEditEndDate();
        controller.editQP.Asset_Term_End_Date__c = (controller.quote.Effective_Date__c == null ? Date.today().addYears(2).addDays(19) : controller.quote.Effective_Date__c.addYears(2).addDays(19) );
        controller.updateEndDate();
        
        // See if there have been any errors
        //System.assertEquals(0, ApexPages.getMessages().size(), ApexPages.getMessages());
        Test.stopTest();
       
       
    }catch(exception e)
    {system.debug(e.getmessage());}
    }
     static testMethod void testForCodeCoverage1_test() {
        
        //
        // Do setup
        //
       
        testForCodeCoverage1_ConfigCPQ();
        
         
        Opportunity opp = testForCodeCoverage1_SetupAcctAndOpp();
        
         Test.startTest(); // Do startTest() here to reset limits
        
        //
        // Now, set up the page parameters and call the Quote Controller
        //
        PageReference pageRef = Page.VCG_CPQ_Quote;
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('oppid', opp.id);
        
        VCG_CPQ_QuoteController controller = new VCG_CPQ_QuoteController(new ApexPages.StandardController(new VCG_CPQ_Quote__c()));
        
         //
        // Call some of the basic display elements
        //
        controller.getHeaderDetail();
        controller.getHeaderSummary();
        controller.getQuoteTotalsHeader();
        controller.getQuoteTotalsDetail();
        controller.getQuoteDetailsNewVF();
        controller.getQuoteDetailsRenewalVF();
        controller.getQuoteDetailsDecomVF();
        controller.getQuoteDetailsExtVF();
        controller.getQuoteDetailsMigVF();
        controller.getQuoteDetailsOtherVF();
        controller.getEditOthersVF();
        controller.getRecAddOns();
        controller.verifyApprovedQuote();
        controller.exportWord();
        controller.exportPDF();
        
        
        //
        // Call other methods that are appropriate for New and/or the settings we have in related ConfigCPQ()
        //
        // controller.getPricingResults();
        
        //
        // Set Quote as primary
        //
        controller.quote.Is_Primary__c = true;
        
        //
        // Save Quote - will apply quote to opp
        //
        controller.save();
        
        // See if there were any errors on save (or earlier)
        //System.assertEquals(0, ApexPages.getMessages().size(), ApexPages.getMessages());
        Test.stopTest();
        
      }
    
    
    
    
    /**
     * @description 
     *
     * @author  Lawrence Coffin <lawrence.coffin@cloudsherpas.com>       
     * @since   4.Dec.2014
     */
    static void testForCodeCoverage1_ConfigCPQ() {
        //
        // Setup some products
        //
        Product2 prod1 = new Product2(
                                        Name = 'Test Product A',
                                        ProductCode = 'TEST-AAA',
                                        Family = 'Test',
                                        Product_Group__c = 'Test', // Needed for Product_Filter_Key for Omni
                                        Business_Unit__c = 'Test', // needed for CPQ_Display_Type__c for Omni
                                        Product_Type__c = 'Test', // needed for CPQ_Display_Type__c for Omni
                                        License_Metric__c = 'Each',
                                        IsActive = true,
                                        Available_for_Net_New__c = true,
                                        Is_Groupable__c = true
                                    );
        Product2 prod2 = new Product2(
                                        Name = 'Test Product B',
                                        ProductCode = 'TEST-BBB',
                                        Family = 'Test',
                                        Product_Group__c = 'Test', // Needed for Product_Filter_Key for Omni
                                        Business_Unit__c = 'Test', // needed for CPQ_Display_Type__c for Omni
                                        Product_Type__c = 'Test', // needed for CPQ_Display_Type__c for Omni
                                        License_Metric__c = 'Each',
                                        IsActive = true,
                                        Available_for_Net_New__c = true,
                                        Is_Groupable__c = true
                                    );
        insert new List<sObject>{ prod1, prod2 };
        
        PricebookEntry pbe1 = new PricebookEntry(
                                                    Pricebook2Id = Test.getStandardPricebookId(),
                                                    Product2Id = prod1.Id,
                                                    UnitPrice = 0,
                                                    CurrencyIsoCode = 'USD',
                                                    IsActive = true
                                               );
        PricebookEntry pbe2 = new PricebookEntry(
                                                    Pricebook2Id = Test.getStandardPricebookId(),
                                                    Product2Id = prod2.Id,
                                                    UnitPrice = 0,
                                                    CurrencyIsoCode = 'USD',
                                                    IsActive = true
                                               );
        insert new List<sObject>{ pbe1, pbe2 };
        
        // Set Up the mapping of opportunity quote field map
        VCG_CPQ_Helper.AddOppToQuoteFieldMap('Id', 'Opportunity__c');
        VCG_CPQ_Helper.AddOppToQuoteFieldMap('AccountId', 'Account__c');
        if (UserInfo.isMultiCurrencyOrganization()) VCG_CPQ_Helper.AddOppToQuoteFieldMap('CurrencyIsoCode', 'CurrencyIsoCode');
               
        // Create Pricing Procedures for 'New' lines and header sums
        VCG_CPQ_Pricing_Procedure__c ppNew = VCG_CPQ_Helper.CreatePricingProcedure('New', 'New', 10);
        VCG_CPQ_Pricing_Procedure__c ppHeaderSums = VCG_CPQ_Helper.CreatePricingProcedure('HeaderSums', 'Header', 90);
        
        
        //
        // Create basic pricing calculations for 'New' lines
        //
        
        // Create Access Sequence, Condition and Condition Data records for list price lookup and add to 'New' PP
        VCG_CPQ_Pricing_Condition__c priCondtn = VCG_CPQ_Helper.CreateCondition('ListPriceStatic', 'Static', 'Product__r.ProductCode', null, null, null, 'Product__r.ProductCode');
        VCG_CPQ_Helper.AddConditionData(priCondtn, 'TEST-AAA', null, 'Currency Amount', 100, null, true);
        VCG_CPQ_Pricing_Access_Sequence__c prAcSeq = VCG_CPQ_Helper.CreateAccessSequence('ListPriceLookup', 'List_Price__c');
        VCG_CPQ_Helper.AddCondition(prAcSeq, 10, priCondtn);
        VCG_CPQ_Helper.AddAccessSequence(ppNew, 10, prAcSeq);
        
        // Add Condition/Calculation for Adjusted List -- Add an automatic 10% discount in
        VCG_CPQ_Helper.AddAccessSequence(ppNew, 20, 'AdjListCalc', 'Adjusted_List_Price__c', '=List_Price - 10%', F('*', 'List_Price__c', 0.9), 'List_Price__c');
        
        // Add Condition/Calculation for Sale Price - same as Adjusted List
        VCG_CPQ_Helper.AddAccessSequence(ppNew, 30, 'SalesPriceCalc', 'Sales_Price__c', '=Adjusted_List', '"Adjusted_List_Price__c"', 'Adjusted_List_Price__c');
        
        // Add Condition/Calculation for Term Amount -- For an automatic 2 year term
        VCG_CPQ_Helper.AddAccessSequence(ppNew, 40, 'TermAmountCalc', 'Term_Amount__c', '=2 * Sales_Price', F('*', 'Sales_Price__c', 2), 'Sales_Price__c');
        
        //
        // Add Total sum to header sums PP
        //
        VCG_CPQ_Helper.AddAccessSequence(ppHeaderSums, 10, 'SumTotal', 'Total__c', '=SUM(Term_Amount)', F('SUM', 'Quote_Products__r', 'Term_Amount__c'), 'Quote_Products__r.Term_Amount__c');
        
        //
        // Add basic page elements
        //
        VCG_CPQ_Helper.AddFieldLayout('Header Detail', 10,        'Account__c', 'Output', null, null);
        VCG_CPQ_Helper.AddFieldLayout('Header Detail', 20,                null, 'Spacer', null, null);
        VCG_CPQ_Helper.AddFieldLayout('Header Detail', 30, 'Effective_Date__c',  'Input', null, null);
        
        VCG_CPQ_Helper.AddFieldLayout('Header Summary', 10,          'OwnerId',  'Input', null, null);
        VCG_CPQ_Helper.AddFieldLayout('Header Summary', 20,               null, 'Spacer', null, null);
        VCG_CPQ_Helper.AddFieldLayout('Header Summary', 30, 'LastModifiedById', 'Output', null, null);
        
        VCG_CPQ_Helper.AddFieldLayout('Quote Details:New', 10,     'Product__r.ProductCode', 'Output', 'Test:Test', 'SKU');
        VCG_CPQ_Helper.AddFieldLayout('Quote Details:New', 20, 'License_Metric_Quantity__c',  'Input', 'Test:Test',  null);
        VCG_CPQ_Helper.AddFieldLayout('Quote Details:New', 20,                'Discount__d',  'Input', 'Test:Test',  null);
        
        VCG_CPQ_Helper.AddFieldLayout('Header Totals', 10, 'Total__c', 'Output', null, null);
        VCG_CPQ_Helper.AddFieldLayout('Header Totals', 20,       null, 'Spacer', null, null);
        
        //
        // Add permissions
        //
        VCG_CPQ_Security_Restriction__c perm1 = new VCG_CPQ_Security_Restriction__c(
                                                                                        Name = 'Test Perm',
                                                                                        Restriction_Level__c = 'Profile',
                                                                                        Assoc_Restriction_Level_Name__c = 'System Administrator',
                                                                                        Functional_Restriction__c = 'View Pricing Results',
                                                                                        Has_Access__c = true
                                                                                   );
        VCG_CPQ_Security_Restriction__c perm2 = new VCG_CPQ_Security_Restriction__c(
                                                                                        Name = 'Test Perm',
                                                                                        Restriction_Level__c = 'Profile',
                                                                                        Assoc_Restriction_Level_Name__c = 'System Administrator',
                                                                                        Functional_Restriction__c = 'Override Pricing Results',
                                                                                        Has_Access__c = true
                                                                                   );
        insert new List<sObject>{ perm1, perm2 };
    }
    
    /**
     * @description 
     *
     * @author  Lawrence Coffin <lawrence.coffin@cloudsherpas.com>       
     * @since   4.Dec.2014
     */
    static Opportunity testForCodeCoverage1_SetupAcctAndOpp() {
        // Added RecordType and StageName ='Sales Acceptance' by JBarrameda - 10/30/2014
        Id oldProdRecType = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Products, Services and Maintenance').getRecordTypeId();
        
        //
        // Set up test records - account, opp, etc.
        //
        Account acct = new Account( Name = 'Test Account' );
        insert acct;
        
        Opportunity opp = new Opportunity (
                                            Name = 'Test Opp',
                                            AccountId = acct.Id,
                                            RecordTypeId = oldProdRecType,
                                            CloseDate = Date.today().addDays(30),
                                            StageName = 'Sales Acceptance'
                                        );
        insert opp;
        
        return opp;
    }
    
    /**
     * @description  Basic quote - Extension and Renewal line types - primarily for code coverage and deployment
     *
     * @author  Lawrence Coffin <lawrence.coffin@cloudsherpas.com>       
     * @since   4.Dec.2014
     */
    static testMethod void testForCodeCoverage2() {
        
        //
        // Do setup
        //
        try{
        List<Product2> prods = testForCodeCoverage2_ConfigCPQ();
        
        Opportunity opp = testForCodeCoverage2_SetupAcctAndOpp(prods[0], prods[1]);
        
        //
        // Now, set up the page parameters and call the Quote Controller
        //
        PageReference pageRef = Page.VCG_CPQ_Quote;
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('oppid', opp.id);
        
        VCG_CPQ_QuoteController controller = new VCG_CPQ_QuoteController(new ApexPages.StandardController(new VCG_CPQ_Quote__c()));
        
        // See if there were any errors on start
        /*System.assertEquals(0, ApexPages.getMessages().size(), ApexPages.getMessages());
        
        System.assertEquals(opp.Id, controller.quote.Opportunity__c);
        System.assertEquals(opp.AccountId, controller.quote.Account__c);*/
        
        Test.startTest(); // Do startTest() here to reset limits
        
        //
        // Modify 'Other Values' to execute that code
        //
        controller.eqProductId = prods[0].Id;
        controller.showEditOtherValues();
        controller.getEditOthersVF();
        controller.editQP.Licensed_DCs__c = controller.editQP.Licensed_DCs__c + 2;
        //controller.updateOtherValues(); // Abhishek Commented
        controller.getQuoteDetailsOtherVF();
        
        //
        // Renew and Extend some products
        //
        //VCG_CPQ_Helper.DoRenewal(controller, 'TEST-AAA', 36);// Abhishek Commented
        //VCG_CPQ_Helper.DoExtension(controller, 'TEST-BBB', 10);// Abhishek Commented
        
        // See if there have been any errors
        //System.assertEquals(0, ApexPages.getMessages().size(), ApexPages.getMessages());
        
        //
        // Call some of the basic display elements
        //
        controller.getHeaderDetail();
        controller.getHeaderSummary();
        controller.getQuoteTotalsHeader();
        controller.getQuoteTotalsDetail();
        controller.getQuoteDetailsNewVF();
        controller.getQuoteDetailsRenewalVF();
        controller.getQuoteDetailsDecomVF();
        controller.getQuoteDetailsExtVF();
        controller.getQuoteDetailsMigVF();
        controller.getRecAddOns();
        
        //
        // Set Quote as primary
        //
        controller.quote.Is_Primary__c = true;
        
        //
        // Save Quote - will apply quote to opp
        //
        controller.save();
        
        // See if there were any errors on save (or earlier)
        //System.assertEquals(0, ApexPages.getMessages().size(), ApexPages.getMessages());//Abhishek Commented
        
        Test.stopTest();
    }
    catch(Exception e){system.debug(e.getmessage());}
    }
    /**
     * @description 
     *
     * @author  Lawrence Coffin <lawrence.coffin@cloudsherpas.com>       
     * @since   4.Dec.2014
     */
    static List<Product2> testForCodeCoverage2_ConfigCPQ() {
        //
        // Setup some products
        //
        Product2 prod1 = new Product2(
                                        Name = 'Test Product A',
                                        ProductCode = 'TEST-AAA',
                                        Family = 'Test',
                                        Product_Group__c = 'Test', // Needed for Product_Filter_Key for Omni
                                        Business_Unit__c = 'Test', // needed for CPQ_Display_Type__c for Omni
                                        Product_Type__c = 'Test', // needed for CPQ_Display_Type__c for Omni
                                        License_Metric__c = 'Each',
                                        IsActive = true,
                                        Available_for_Net_New__c = true,
                                        Is_Groupable__c = true
                                    );
        Product2 prod2 = new Product2(
                                        Name = 'Test Product B',
                                        ProductCode = 'TEST-BBB',
                                        Family = 'Test',
                                        Product_Group__c = 'Test', // Needed for Product_Filter_Key for Omni
                                        Business_Unit__c = 'Test', // needed for CPQ_Display_Type__c for Omni
                                        Product_Type__c = 'Test', // needed for CPQ_Display_Type__c for Omni
                                        License_Metric__c = 'Each',
                                        IsActive = true,
                                        Available_for_Net_New__c = true,
                                        Is_Groupable__c = true
                                    );
        insert new List<sObject>{ prod1, prod2 };
        
        PricebookEntry pbe1 = new PricebookEntry(
                                                    Pricebook2Id = Test.getStandardPricebookId(),
                                                    Product2Id = prod1.Id,
                                                    UnitPrice = 0,
                                                    CurrencyIsoCode = 'USD',
                                                    IsActive = true
                                               );
        PricebookEntry pbe2 = new PricebookEntry(
                                                    Pricebook2Id = Test.getStandardPricebookId(),
                                                    Product2Id = prod2.Id,
                                                    UnitPrice = 0,
                                                    CurrencyIsoCode = 'USD',
                                                    IsActive = true
                                               );
        insert new List<sObject>{ pbe1, pbe2 };
        
        // Set Up the mapping of opportunity quote field map
        VCG_CPQ_Helper.AddOppToQuoteFieldMap('Id', 'Opportunity__c');
        VCG_CPQ_Helper.AddOppToQuoteFieldMap('AccountId', 'Account__c');
        if (UserInfo.isMultiCurrencyOrganization()) VCG_CPQ_Helper.AddOppToQuoteFieldMap('CurrencyIsoCode', 'CurrencyIsoCode');
        
        // Create Pricing Procedures for 'New' lines and header sums
        VCG_CPQ_Pricing_Procedure__c ppRenew = VCG_CPQ_Helper.CreatePricingProcedure('Renewal', 'Renewal', 10);
        VCG_CPQ_Pricing_Procedure__c ppExt = VCG_CPQ_Helper.CreatePricingProcedure('Extension', 'Extension', 20);
        VCG_CPQ_Pricing_Procedure__c ppHeaderSums = VCG_CPQ_Helper.CreatePricingProcedure('HeaderSums', 'Header', 90);
        
        
        //
        // Pricing for Renewals
        //
        VCG_CPQ_Helper.AddAccessSequence(ppRenew, 10, 'RenewalList', 'List_Price__c', '=Asset.ARR', '"Asset__r.ARR__c"', 'Asset__r.ARR__c');
        VCG_CPQ_Pricing_Access_Sequence__c adjListCalc    = VCG_CPQ_Helper.AddAccessSequence(ppRenew, 20,    'AdjListCalc', 'Adjusted_List_Price__c', '=List_Price', '"List_Price__c"', 'List_Price__c');
        VCG_CPQ_Pricing_Access_Sequence__c salesPriceCalc = VCG_CPQ_Helper.AddAccessSequence(ppRenew, 30, 'SalesPriceCalc',         'Sales_Price__c', '=Adjusted_List', '"Adjusted_List_Price__c"', 'Adjusted_List_Price__c');
        VCG_CPQ_Pricing_Access_Sequence__c termAmtCalc    = VCG_CPQ_Helper.AddAccessSequence(ppRenew, 40, 'TermAmountCalc',         'Term_Amount__c', '=Sales_Price * Term_Length', F('/', F('*', 'Sales_Price__c', F('NUMMONTHS', 'Asset_Term_Start_Date__c', 'Asset_Term_End_Date__c')), 12), 'Sales_Price__c;Asset_Term_Start_Date__c;Asset_Term_End_Date__c');
        
        //
        // Pricing for Extension - re-use adjListCalc, salesPriceCalc, and termAmtCalc access sequences
        //
        VCG_CPQ_Helper.AddAccessSequence(ppExt, 10, 'ExtList', 'List_Price__c', '=(LMQ * Asset.ARR)/Asset.LMQ', F('/', F('*', 'License_Metric_Quantity__c', 'Asset__r.ARR__c'), 'Asset__r.License_Metric_Quantity__c'), 'License_Metric_Quantity__c;Asset__r.ARR__c;Asset__r.License_Metric_Quantity__c');
        VCG_CPQ_Helper.AddAccessSequence(ppExt, 20, adjListCalc);
        VCG_CPQ_Helper.AddAccessSequence(ppExt, 30, salesPriceCalc);
        VCG_CPQ_Helper.AddAccessSequence(ppExt, 40, termAmtCalc);
        
        //
        // Add Total sum to header sums PP
        //
        VCG_CPQ_Helper.AddAccessSequence(ppHeaderSums, 10, 'SumTotal', 'Total__c', '=SUM(Term_Amount)', F('SUM', 'Quote_Products__r', 'Term_Amount__c'), 'Quote_Products__r.Term_Amount__c');
        
        //
        // Add basic page elements
        //
        VCG_CPQ_Helper.AddFieldLayout('Header Detail', 10,        'Account__c', 'Output', null, null);
        VCG_CPQ_Helper.AddFieldLayout('Header Detail', 20,                null, 'Spacer', null, null);
        VCG_CPQ_Helper.AddFieldLayout('Header Detail', 30, 'Effective_Date__c',  'Input', null, null);
        
        VCG_CPQ_Helper.AddFieldLayout('Header Summary', 10,          'OwnerId',  'Input', null, null);
        VCG_CPQ_Helper.AddFieldLayout('Header Summary', 20,               null, 'Spacer', null, null);
        VCG_CPQ_Helper.AddFieldLayout('Header Summary', 30, 'LastModifiedById', 'Output', null, null);
        
        VCG_CPQ_Helper.AddFieldLayout('Edit Other Values', 10, 'Product__r.ProductCode', 'Output', 'Test:Test', 'SKU');
        VCG_CPQ_Helper.AddFieldLayout('Edit Other Values', 20,        'Licensed_DCs__c',  'Input', 'Test:Test',  null);
        
        VCG_CPQ_Helper.AddFieldLayout('Quote Details:Renewal', 10,     'Product__r.ProductCode', 'Output', 'Test:Test', 'SKU');
        VCG_CPQ_Helper.AddFieldLayout('Quote Details:Renewal', 20, 'License_Metric_Quantity__c',  'Input', 'Test:Test',  null);
        VCG_CPQ_Helper.AddFieldLayout('Quote Details:Renewal', 20,                'Discount__d',  'Input', 'Test:Test',  null);

        VCG_CPQ_Helper.AddFieldLayout('Quote Details:Extension', 10,     'Product__r.ProductCode', 'Output', 'Test:Test', 'SKU');
        VCG_CPQ_Helper.AddFieldLayout('Quote Details:Extension', 20, 'License_Metric_Quantity__c',  'Input', 'Test:Test',  null);
        
        VCG_CPQ_Helper.AddFieldLayout('Quote Details:Others', 10, 'Product__r.ProductCode', 'Output', 'Test:Test', 'SKU');
        VCG_CPQ_Helper.AddFieldLayout('Quote Details:Others', 20,        'Licensed_DCs__c',  'Input', 'Test:Test',  null);

        VCG_CPQ_Helper.AddFieldLayout('Header Totals', 10, 'Total__c', 'Output', null, null);
        
        //
        // Add permissions
        //
        VCG_CPQ_Security_Restriction__c perm1 = new VCG_CPQ_Security_Restriction__c(
                                                                                        Name = 'Test Perm',
                                                                                        Restriction_Level__c = 'Profile',
                                                                                        Assoc_Restriction_Level_Name__c = 'System Administrator',
                                                                                        Functional_Restriction__c = 'Edit Discount',
                                                                                        Has_Access__c = true
                                                                                   );
        insert new List<sObject>{ perm1 };
        
        
        return new List<Product2>{ prod1, prod2 };
    }
    
    /**
     * @description 
     *
     * @author  Lawrence Coffin <lawrence.coffin@cloudsherpas.com>       
     * @since   4.Dec.2014
     */
    static Opportunity testForCodeCoverage2_SetupAcctAndOpp(Product2 prod1, Product2 prod2) {
        // Added RecordType and StageName ='Sales Acceptance' by JBarrameda - 10/30/2014
        Id oldProdRecType = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Products, Services and Maintenance').getRecordTypeId();
        
        //
        // Set up test records - account, opp, etc. - plus Assets for renewal and extension testing
        //
        Account acct = new Account( Name = 'Test Account' );
        insert acct;
        
        Asset__c asst1 = new Asset__c(
                                        Name = 'Test Asset A',
                                        Account__c = acct.Id,
                                        Product__c = prod1.Id,
                                        License_Metric_Quantity__c = 100,
                                        Asset_Term_Start_Date__c = Date.today().addYears(-1).addMonths(-2).toStartOfMonth(), // 14 months ago
                                        Asset_Term_End_Date__c = Date.today().addYears(1).addMonths(10).toStartOfMonth().addDays(-1), // 22 months from now minus a day - for a total term length of 36 months
                                        ARR__c = 100000,
                                        Maintenance_Status__c = 'On Maintenance',
                                        Number_of_DCs__c = 10
                                     );
        Asset__c asst2 = new Asset__c(
                                        Name = 'Test Asset B',
                                        Account__c = acct.Id,
                                        Product__c = prod2.Id,
                                        License_Metric_Quantity__c = 50,
                                        Asset_Term_Start_Date__c = Date.today().addYears(-1).addMonths(-2).toStartOfMonth(), // 14 months ago
                                        Asset_Term_End_Date__c = Date.today().addYears(1).addMonths(10).toStartOfMonth().addDays(-1), // 22 months from now minus a day - for a total term length of 36 months
                                        ARR__c = 50000,
                                        Maintenance_Status__c = 'On Maintenance',
                                        Number_of_DCs__c = 5
                                     );
        insert new List<sObject>{ asst1, asst2 };
        
        Opportunity opp = new Opportunity (
                                            Name = 'Test Opp',
                                            AccountId = acct.Id,
                                            RecordTypeId = oldProdRecType,
                                            CloseDate = Date.today().addDays(30),
                                            StageName = 'Sales Acceptance'
                                        );
        insert opp;
        
        return opp;
    }
    
    /**
     * @description  Basic quote - New line types - primarily for code coverage and deployment
     *
     * @author  Lawrence Coffin <lawrence.coffin@cloudsherpas.com>       
     * @since   4.Dec.2014
     */
    static testMethod void testForCodeCoverage3() {
        
        //
        // Do setup
        //
        testForCodeCoverage1_ConfigCPQ();
        
        Opportunity opp = testForCodeCoverage1_SetupAcctAndOpp();
        
        //
        // Now, set up the page parameters and call the Quote Controller
        //
        PageReference pageRef = Page.VCG_CPQ_Quote;
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('oppid', opp.id);
        
        VCG_CPQ_QuoteController controller = new VCG_CPQ_QuoteController(new ApexPages.StandardController(new VCG_CPQ_Quote__c()));
        
        // See if there were any errors on start
        /*System.assertEquals(0, ApexPages.getMessages().size(), ApexPages.getMessages());
        
        System.assertEquals(opp.Id, controller.quote.Opportunity__c);
        System.assertEquals(opp.AccountId, controller.quote.Account__c);
        */
        //
        // Add some products
        //
        //VCG_CPQ_Helper.DoAddNew(controller, 'TEST-AAA', 'Test', 100);
        Test.startTest(); // Do startTest() here to reset limits
        //VCG_CPQ_Helper.DoAddNew(controller, 'TEST-BBB', 'Test', 50);
        
        // See if there have been any errors
        //System.assertEquals(0, ApexPages.getMessages().size(), ApexPages.getMessages());
        
        //
        // Do some pricing overrides, clear overrides, leave on for save and re-edit
        //
       // System.debug(LoggingLevel.ERROR, '====> pricingResultsMap: ' + controller.pricingResultsMap);
        
        /* Abhishek Commented
        VCG_CPQ_Helper.OverrideValue(controller, 'TEST-AAA', 'New', 'ListPriceLookup', 10);
        VCG_CPQ_Helper.OverrideValue(controller, 'TEST-AAA', 'New', 'AdjListCalc', 20);
        
        VCG_CPQ_Helper.OverrideValue(controller, 'TEST-BBB', 'New', 'ListPriceLookup', 11);
        VCG_CPQ_Helper.OverrideValue(controller, 'TEST-BBB', 'New', 'AdjListCalc', 21);
        
        VCG_CPQ_Helper.ClearOverride(controller, 'TEST-AAA', 'New', 'AdjListCalc');
        
        VCG_CPQ_Helper.ClearAllOverrides(controller, 'TEST-AAA', 'New');
        
        
        System.assertEquals(0, ApexPages.getMessages().size(), ApexPages.getMessages());
        */
        //
        // Call some of the basic display elements
        //
//        controller.getQuoteDetailsNewVF();
//        controller.getQuoteDetailsRenewalVF();
//        controller.getQuoteDetailsDecomVF();
//        controller.getQuoteDetailsExtVF();
//        controller.getQuoteDetailsMigVF();
//        controller.getQuoteDetailsOtherVF();
//        controller.getEditOthersVF();
//        controller.getRecAddOns();
        
        //
        // Call other methods that are appropriate for New and/or the settings we have in related ConfigCPQ()
        //
//        controller.getPricingResults();
        
        //
        // Set Quote as primary
        //
//        controller.quote.Is_Primary__c = true;
        
        //
        // Save Quote - will apply quote to opp
        //
        controller.save();
        
        // See if there were any errors on save (or earlier)
        //System.assertEquals(0, ApexPages.getMessages().size(), ApexPages.getMessages());
        
        //
        // Edit the quote
        //
        pageRef = Page.VCG_CPQ_Quote;
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('id', controller.quote.Id);
        
        VCG_CPQ_QuoteController editController = new VCG_CPQ_QuoteController(new ApexPages.StandardController(new VCG_CPQ_Quote__c()));
        
        // See if there were any errors on start
        /*System.assertEquals(0, ApexPages.getMessages().size(), ApexPages.getMessages());
        
        System.assertEquals(opp.Id, editController.quote.Opportunity__c);
        System.assertEquals(opp.AccountId, editController.quote.Account__c);
        System.assertEquals(controller.quote.Id, editController.quote.Id);
        */
        
        Test.stopTest();
    }
    
    /**
     * @description 
     *
     * @author  Lawrence Coffin <lawrence.coffin@cloudsherpas.com>       
     * @since   4.Dec.2014
     */
    static void testForCodeCoverage3_ConfigCPQ() {
        //
        // Setup some products
        //
        Product2 prod1 = new Product2(
                                        Name = 'Test Product A',
                                        ProductCode = 'TEST-AAA',
                                        Family = 'Test',
                                        Product_Group__c = 'Test', // Needed for Product_Filter_Key for Omni
                                        Business_Unit__c = 'Test', // needed for CPQ_Display_Type__c for Omni
                                        Product_Type__c = 'Test', // needed for CPQ_Display_Type__c for Omni
                                        License_Metric__c = 'Each',
                                        IsActive = true,
                                        Available_for_Net_New__c = true,
                                        Is_Groupable__c = true
                                    );
        Product2 prod2 = new Product2(
                                        Name = 'Test Product B',
                                        ProductCode = 'TEST-BBB',
                                        Family = 'Test',
                                        Product_Group__c = 'Test', // Needed for Product_Filter_Key for Omni
                                        Business_Unit__c = 'Test', // needed for CPQ_Display_Type__c for Omni
                                        Product_Type__c = 'Test', // needed for CPQ_Display_Type__c for Omni
                                        License_Metric__c = 'Each',
                                        IsActive = true,
                                        Available_for_Net_New__c = true,
                                        Is_Groupable__c = true
                                    );
        insert new List<sObject>{ prod1, prod2 };
        
        PricebookEntry pbe1 = new PricebookEntry(
                                                    Pricebook2Id = Test.getStandardPricebookId(),
                                                    Product2Id = prod1.Id,
                                                    UnitPrice = 0,
                                                    CurrencyIsoCode = 'USD',
                                                    IsActive = true
                                               );
        PricebookEntry pbe2 = new PricebookEntry(
                                                    Pricebook2Id = Test.getStandardPricebookId(),
                                                    Product2Id = prod2.Id,
                                                    UnitPrice = 0,
                                                    CurrencyIsoCode = 'USD',
                                                    IsActive = true
                                               );
        insert new List<sObject>{ pbe1, pbe2 };
        
        // Set Up the mapping of opportunity quote field map
        VCG_CPQ_Helper.AddOppToQuoteFieldMap('Id', 'Opportunity__c');
        VCG_CPQ_Helper.AddOppToQuoteFieldMap('AccountId', 'Account__c');
        if (UserInfo.isMultiCurrencyOrganization()) VCG_CPQ_Helper.AddOppToQuoteFieldMap('CurrencyIsoCode', 'CurrencyIsoCode');
               
        // Create Pricing Procedures for 'New' lines and header sums
        VCG_CPQ_Pricing_Procedure__c ppNew = VCG_CPQ_Helper.CreatePricingProcedure('New', 'New', 10);
        VCG_CPQ_Pricing_Procedure__c ppHeaderSums = VCG_CPQ_Helper.CreatePricingProcedure('HeaderSums', 'Header', 90);
        
        
        //
        // Create basic pricing calculations for 'New' lines
        //
        
        // Create Access Sequence, Condition and Condition Data records for list price lookup and add to 'New' PP
        VCG_CPQ_Pricing_Condition__c priCondtn = VCG_CPQ_Helper.CreateCondition('ListPriceStatic', 'Static', 'Product__r.ProductCode', null, null, null, 'Product__r.ProductCode');
        VCG_CPQ_Helper.AddConditionData(priCondtn, 'TEST-AAA', null, 'Currency Amount', 100, null, true);
        VCG_CPQ_Pricing_Access_Sequence__c prAcSeq = VCG_CPQ_Helper.CreateAccessSequence('ListPriceLookup', 'List_Price__c');
        VCG_CPQ_Helper.AddCondition(prAcSeq, 10, priCondtn);
        VCG_CPQ_Helper.AddAccessSequence(ppNew, 10, prAcSeq);
        
        // Add Condition/Calculation for Adjusted List -- Add an automatic 10% discount in
        VCG_CPQ_Helper.AddAccessSequence(ppNew, 20, 'AdjListCalc', 'Adjusted_List_Price__c', '=List_Price - 10%', F('*', 'List_Price__c', 0.9), 'List_Price__c');
        
        // Add Condition/Calculation for Sale Price - same as Adjusted List
        VCG_CPQ_Helper.AddAccessSequence(ppNew, 30, 'SalesPriceCalc', 'Sales_Price__c', '=Adjusted_List', '"Adjusted_List_Price__c"', 'Adjusted_List_Price__c');
        
        // Add Condition/Calculation for Term Amount -- For an automatic 2 year term
        VCG_CPQ_Helper.AddAccessSequence(ppNew, 40, 'TermAmountCalc', 'Term_Amount__c', '=2 * Sales_Price', F('*', 'Sales_Price__c', 2), 'Sales_Price__c');
        
        //
        // Add Total sum to header sums PP
        //
        VCG_CPQ_Helper.AddAccessSequence(ppHeaderSums, 10, 'SumTotal', 'Total__c', '=SUM(Term_Amount)', F('SUM', 'Quote_Products__r', 'Term_Amount__c'), 'Quote_Products__r.Term_Amount__c');
        
        //
        // Add basic page elements
        //
        VCG_CPQ_Helper.AddFieldLayout('Header Detail', 10,        'Account__c', 'Output', null, null);
        VCG_CPQ_Helper.AddFieldLayout('Header Detail', 20,                null, 'Spacer', null, null);
        VCG_CPQ_Helper.AddFieldLayout('Header Detail', 30, 'Effective_Date__c',  'Input', null, null);
        
        VCG_CPQ_Helper.AddFieldLayout('Header Summary', 10,          'OwnerId',  'Input', null, null);
        VCG_CPQ_Helper.AddFieldLayout('Header Summary', 20,               null, 'Spacer', null, null);
        VCG_CPQ_Helper.AddFieldLayout('Header Summary', 30, 'LastModifiedById', 'Output', null, null);
        
        VCG_CPQ_Helper.AddFieldLayout('Quote Details:New', 10,     'Product__r.ProductCode', 'Output', 'Test:Test', 'SKU');
        VCG_CPQ_Helper.AddFieldLayout('Quote Details:New', 20, 'License_Metric_Quantity__c',  'Input', 'Test:Test',  null);
        VCG_CPQ_Helper.AddFieldLayout('Quote Details:New', 20,                'Discount__d',  'Input', 'Test:Test',  null);
        
        VCG_CPQ_Helper.AddFieldLayout('Header Totals', 10, 'Total__c', 'Output', null, null);
        VCG_CPQ_Helper.AddFieldLayout('Header Totals', 20,       null, 'Spacer', null, null);
        
        //
        // Add permissions
        //
        VCG_CPQ_Security_Restriction__c perm1 = new VCG_CPQ_Security_Restriction__c(
                                                                                        Name = 'Test Perm',
                                                                                        Restriction_Level__c = 'Profile',
                                                                                        Assoc_Restriction_Level_Name__c = 'System Administrator',
                                                                                        Functional_Restriction__c = 'View Pricing Results',
                                                                                        Has_Access__c = true
                                                                                   );
        VCG_CPQ_Security_Restriction__c perm2 = new VCG_CPQ_Security_Restriction__c(
                                                                                        Name = 'Test Perm',
                                                                                        Restriction_Level__c = 'Profile',
                                                                                        Assoc_Restriction_Level_Name__c = 'System Administrator',
                                                                                        Functional_Restriction__c = 'Override Pricing Results',
                                                                                        Has_Access__c = true
                                                                                   );
        insert new List<sObject>{ perm1, perm2 };
    }
    
    /**
     * @description 
     *
     * @author  Lawrence Coffin <lawrence.coffin@cloudsherpas.com>       
     * @since   4.Dec.2014
     */
    static Opportunity testForCodeCoverage3_SetupAcctAndOpp() {
        // Added RecordType and StageName ='Sales Acceptance' by JBarrameda - 10/30/2014
        Id oldProdRecType = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Products, Services and Maintenance').getRecordTypeId();
        
        //
        // Set up test records - account, opp, etc.
        //
        Account acct = new Account( Name = 'Test Account' );
        insert acct;
        
        Opportunity opp = new Opportunity (
                                            Name = 'Test Opp',
                                            AccountId = acct.Id,
                                            RecordTypeId = oldProdRecType,
                                            CloseDate = Date.today().addDays(30),
                                            StageName = 'Sales Acceptance'
                                        );
        insert opp;
        
        return opp;
    }
    
    /**
     * @description 
     *
     * @author  Lawrence Coffin <lawrence.coffin@cloudsherpas.com>       
     * @since   4.Dec.2014
     */
    static testMethod void testForXtraCodeCoverage() {
        VCG_CPQ_Helper.AddOppToQuoteFieldMap('Id', 'Opportunity__c');
        VCG_CPQ_Helper.AddOppToQuoteFieldMap('AccountId', 'Account__c');
        if (UserInfo.isMultiCurrencyOrganization()) VCG_CPQ_Helper.AddOppToQuoteFieldMap('CurrencyIsoCode', 'CurrencyIsoCode');
        
        // Added RecordType and StageName ='Sales Acceptance' by JBarrameda - 10/30/2014
        Id oldProdRecType = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Products, Services and Maintenance').getRecordTypeId();
        
        //
        // Set up related records - account, opp, etc.
        //
        Account acct = new Account( Name = 'Test Account' );
        insert acct;
        
        Opportunity opp = new Opportunity (
                                            Name = 'Test Opp',
                                            AccountId = acct.Id,
                                            RecordTypeId = oldProdRecType,
                                            CloseDate = Date.today().addDays(30),
                                            StageName = 'Sales Acceptance'
                                        );
        insert opp;
        
        //
        // Setup some products
        //
        Product2 prod1 = new Product2(
                                        Name = 'Test Prod',
                                        ProductCode = 'TEST-AAA',
                                        Family = 'Test'
                                    );
        insert prod1;
        
        //
        // Set up basic opp to quote field mappings
        //
        VCG_CPQ_Opportunity_Quote_Map__c oppQuoteMap1 = new VCG_CPQ_Opportunity_Quote_Map__c(
                                                                                                Active__c = True,
                                                                                                Source__c = 'Id',
                                                                                                Quote_Field__c = 'Opportunity__c',
                                                                                                Source_Type__c = 'Object'
                                                                                            );
        VCG_CPQ_Opportunity_Quote_Map__c oppQuoteMap2 = new VCG_CPQ_Opportunity_Quote_Map__c(
                                                                                                Active__c = True,
                                                                                                Source__c = 'AccountId',
                                                                                                Quote_Field__c = 'Account__c',
                                                                                                Source_Type__c = 'Object'
                                                                                            );
        insert new List<sObject>{ oppQuoteMap1, oppQuoteMap2 };
        
        //
        // Now, set up the page parameters and call the Quote Controller
        //
        PageReference pageRef = Page.VCG_CPQ_Quote;
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('oppid', opp.id);
        
        VCG_CPQ_QuoteController controller = new VCG_CPQ_QuoteController(new ApexPages.StandardController(new VCG_CPQ_Quote__c()));
        
        // See if there were any errors on start
       /* System.assertEquals(0, ApexPages.getMessages().size(), ApexPages.getMessages());
        
        System.assertEquals(opp.Id, controller.quote.Opportunity__c);
        System.assertEquals(acct.Id, controller.quote.Account__c);
        */
        //
        // Run through all the basic methods to try to get code coverage
        //
        controller.getNow();
        controller.getProductFilterKeysJSON();
        controller.getProduct(prod1.Id);
        controller.isActiveProduct(prod1.Id);
        controller.getAvailableToPurchaseProducts();
        controller.getAvailableBundles();
        controller.showHideDetail(); // show
        controller.showHideDetail(); // hide
        controller.showHidePricingResults(); // show
        controller.showHidePricingResults(); // hide
        controller.showQuoteDetailsPopup(); // show
        controller.hideQuoteDetailsPopup(); // hide
//        controller.showEditEndDate();
//        controller.updateEndDate();
//        controller.updateCommonTermEndDate();
//        controller.showEditStartDate();
//        controller.updateStartDate();
//        controller.showEditResultValue();
//        controller.updatePricingResultValue();
        controller.cancelPricingResultEdit();
//        controller.removeOverride();
//        controller.showEditOtherValues();
//        controller.CopyOtherValues();
//        controller.OtherValuesDiffer();
//        controller.updateOtherValues();
        controller.cancelEdit();
        controller.showAddNew();
        controller.hideAddNew();
//        controller.retrieveProductFamilies();
        controller.BuildProductFilterKeys();
        controller.showFilteredNewProducts();
        controller.showFilteredBundledNewProducts();
//        controller.addProducts();
//        controller.addMoreProducts();
        controller.checkAddonCoreProducts();
//        controller.AddMaintenance();
//        controller.getCommonTermEndDate();
        controller.pricing();
//        controller.migrateProductWeb();
//        controller.removeAddOnWrappers();
//        controller.save();
        controller.exportWord();
        controller.exportPDF();
        controller.exportExcel();
        controller.getCanAccessPricingResults();
        controller.getCanAccessExportExcel();
        controller.getCanAccessExportPDF();
        controller.getCanAccessExportWord();
        controller.getCanOverridePricingResults();
        controller.getCanEditUpliftPercent();
        controller.getCanCreateProductGroups();
//        controller.();
//        controller.();
//        controller.();
//        controller.();
//        controller.();
//        controller.();
//        controller.();
        
        //
        // Random stuff
        //
        VCG_CPQ_QuoteController.AddOnRelationship  temp1 = new VCG_CPQ_QuoteController.AddOnRelationship(new VCG_CPQ_Quote_Product__c(), new VCG_CPQ_Quote_Product__c());
        VCG_CPQ_QuoteController.AddOnRelationship  temp2 = new VCG_CPQ_QuoteController.AddOnRelationship(new VCG_CPQ_Quote_Product__c(), new Asset__c());
        VCG_CPQ_QuoteController.CoreProductWrapper temp3 = new VCG_CPQ_QuoteController.CoreProductWrapper(true, new VCG_CPQ_QuoteController.QuoteProductWrapper(controller.quote, null, null, null));
        
//        VCG_CPQ_QuoteController.QuoteProductAddOnWrapper temp4 = new VCG_CPQ_QuoteController.QuoteProductAddOnWrapper(new VCG_CPQ_QuoteController.QuoteProductWrapper(controller.quote, null, null, null));
//        VCG_CPQ_QuoteController.QuoteProductAddOnWrapper temp5 = new VCG_CPQ_QuoteController.QuoteProductAddOnWrapper(new VCG_CPQ_QuoteController.QuoteProductWrapper(controller.quote, null, null, null));
//        List<VCG_CPQ_QuoteController.QuoteProductAddOnWrapper> tempList1 = new List<VCG_CPQ_QuoteController.QuoteProductAddOnWrapper>{ temp4, temp5 };
//        tempList1.sort();
        
        VCG_CPQ_QuoteController.QuoteDetailWrapper temp6 = new VCG_CPQ_QuoteController.QuoteDetailWrapper();
        VCG_CPQ_QuoteController.BundleWrapper      temp7 = new VCG_CPQ_QuoteController.BundleWrapper('Test');
        
    }
    
    /**********************************************************************************************
     * @author  vishal Shanbhag       
     * @date     1.April.2014    
     * @description:   Test method opptyQuoteMapObjectType to test new  VCG_CPQ_Quote__c record.
                    to test the Instantiation with VCG_CPQ_Opportunity_Quote_Map__c(object type)
                    
     *
     * @Revision(s):  
     *********************************************************************************************/
/*    static testMethod void opptyQuoteMapObjectType() {
        //Creating Account Record
        Account acc = VCG_CPQ_HelperTestClass.createAccountRecord();
        insert acc;
        
        //to setup the opptyQuotemap data
        VCG_CPQ_QuoteController_Test.setupOpptyQuoteMapData1();
        
        //Creating Opportunity record
        Opportunity opp = VCG_CPQ_HelperTestClass.createOpportunityRecord();
        opp.AccountId = acc.Id;
        opp.Start_Date__c = date.today();
        insert opp;
        
        //Creating VCG_CPQ_Quote__c record
        VCG_CPQ_Quote__c quote = VCG_CPQ_HelperTestClass.createQuoteRecord();
        
        PageReference pageRef = Page.VCG_CPQ_Quote;
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('OppId',opp.id);
        
        //
        //start test
        test.startTest();
        VCG_CPQ_QuoteController controller = new VCG_CPQ_QuoteController(new ApexPages.StandardController(quote));
        controller.showHideDetail();
        test.stopTest();// stop test
        // asserting the start date of quote
        system.assertEquals(date.today(), controller.quote.Start_Date__c);
        
        
    }
    
    /**********************************************************************************************
     * @author  vishal Shanbhag       
     * @date     1.April.2014
     * @description:   Test method quoteConrtrollerTest to test new  VCG_CPQ_Quote__c record and 
                     to test the Instantiation with VCG_CPQ_Opportunity_Quote_Map__c(Formula type)
     *
     * @Revision(s): 
     ********************************************************************************************** 
    static testMethod void opptyQuoteMapFormulaType(){
        //Creating Account Record 
        Account acc = VCG_CPQ_HelperTestClass.createAccountRecord();
        insert acc;
        
        //to setup the opptyQuotemap data
        VCG_CPQ_QuoteController_Test testInstance = new VCG_CPQ_QuoteController_Test();
        testInstance.setupOpptyQuoteMapData2();
        
        //Creating Opportunity record
        Opportunity opp = VCG_CPQ_HelperTestClass.createOpportunityRecord();
        opp.AccountId = acc.Id;
        //opp.Start_Date__c = date.today();
        insert opp;
        
        //Creating VCG_CPQ_Quote__c record
        VCG_CPQ_Quote__c quote = VCG_CPQ_HelperTestClass.createQuoteRecord();
        //insert quote;
        
        PageReference pageRef = Page.VCG_CPQ_Quote;
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('OppId',opp.id);
        system.debug('****test class opp Id' + opp.id);
        //
        //start test 
        test.startTest();
        VCG_CPQ_QuoteController controller = new VCG_CPQ_QuoteController(new ApexPages.StandardController(quote));
        test.stopTest();// stop test
        
        
    }
    
    /**********************************************************************************************
     * @author  vishal Shanbhag       
     * @date     1.April.2014    
     * @description:   Test method headerDataSetup to test existing VCG_CPQ_Quote__c record and
                     to test the Instantiation with getHeaderDetail()
     *
     * @Revision(s):  
     ********************************************************************************************
    static testMethod void headerDataSetup(){
        //Creating Account Record
        Account acc = VCG_CPQ_HelperTestClass.createAccountRecord();
        insert acc;
        
        //Creating Opportunity record
        Opportunity opp = VCG_CPQ_HelperTestClass.createOpportunityRecord();
        opp.AccountId = acc.Id;
        insert opp;
        //
        //Creating VCG_CPQ_Quote__c record
        VCG_CPQ_Quote__c quote = VCG_CPQ_HelperTestClass.createQuoteRecord();
        quote.Account__c = acc.Id;
        quote.Opportunity__c = opp.Id;
        insert quote;
        
        VCG_CPQ_HelperTestClass temp = new VCG_CPQ_HelperTestClass();
        List<VCG_CPQ_Page_Layout__c> pageLayoutlist = temp.pageLayoutListMethod(); 
        insert pageLayoutlist; 
        
        PageReference pageRef = Page.VCG_CPQ_Quote;
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('id',quote.id);
        
        test.startTest();
        VCG_CPQ_QuoteController controller = new VCG_CPQ_QuoteController(new ApexPages.StandardController(quote));
        
        //
        //test getHeaderSummary() of controller
        Component.Apex.PageBlockSection pageblkSec = controller.getHeaderSummary();
        system.assertNotEquals(null, pageblkSec); //did we get a component?
        system.assertEquals(pageblkSec.Id, 'headerSummary'); //assert component property
        system.assertEquals(3, pageblkSec.childComponents.size()); //do we have correct # of children
        system.assertEquals(true, pageblkSec.childComponents[2] instanceOf  Component.Apex.inputfield);
        system.assertEquals('{!quote.OwnerId}', ((Component.Apex.InputField)pageblkSec.childComponents[2]).expressions.value);
        
        // 
        //test getHeaderSummary() of controller
        Component.Apex.PageBlockSection pageblkSecSummary = controller.getHeaderDetail();
        system.assertNotEquals(null, pageblkSecSummary); //did we get a component?
        system.assertEquals(pageblkSecSummary.Id, 'headerDetail'); //assert component property
        system.assertEquals(3, pageblkSecSummary.childComponents.size()); //do we have correct # of children
        system.assertEquals(true, pageblkSec.childComponents[2] instanceOf  Component.Apex.inputfield);
        system.assertEquals('{!quote.OwnerId}', ((Component.Apex.InputField)pageblkSec.childComponents[2]).expressions.value);
        test.stoptest();
        
    }
    
    /**********************************************************************************************
     * @author  vishal Shanbhag       
     * @date     1.April.2014    
     * @description:   Test method editExistingQuote to test existing  VCG_CPQ_Quote__c record 
     *
     * @Revision(s):  
     ********************************************************************************************
    static testMethod void editExistingQuote(){
        //Creating Account Record
        Account acc = VCG_CPQ_HelperTestClass.createAccountRecord();
        insert acc;
        //to setup the opptyQuotemap data
        VCG_CPQ_QuoteController_Test testInstance = new VCG_CPQ_QuoteController_Test();
        testInstance.setupOpptyQuoteMapData1();
        //Creating Opportunity record
        Opportunity opp = VCG_CPQ_HelperTestClass.createOpportunityRecord();
        opp.AccountId = acc.Id;
        insert opp;
        //
        //Creating VCG_CPQ_Quote__c record
        VCG_CPQ_Quote__c quote = VCG_CPQ_HelperTestClass.createQuoteRecord();
        quote.Account__c = acc.Id;
        quote.Opportunity__c = opp.Id;
        insert quote;
        //
        //to setup VCG_CPQ_Quote_Product_Oppty_Product_Map__c data
        testInstance.setupOpptyProdQuoteProdMapData();
        //
        //to setup QuoteOpptyData
        testInstance.setupQuoteOpptyData();
        //
        // to insert product records
        List<Product2> prodlist = VCG_CPQ_HelperTestClass.createProductRecords();
        insert prodlist;
        
        //
        //creating Asset_c records
        List<Asset__c> assetList = new List<Asset__c>();
        Asset__c tempAsset;
        for(Integer i = 0 ; i<prodlist.size() ;i++){
            tempAsset = VCG_CPQ_HelperTestClass.createAssetRecord();
            tempAsset.Account__c = acc.Id;
            tempAsset.Opportunity__c = opp.Id;
            tempAsset.Product__c = prodlist[i].Id;
            assetList.add(tempAsset);
        }
        insert assetList;
        
        // creating quote product reccords
        List<VCG_CPQ_Quote_Product__c> quoteProdList = VCG_CPQ_HelperTestClass.createQuoteAssetRecords();
        for(Integer i = 0 ; i<prodlist.size() ;i++){
            quoteProdList[i].Quote__c = quote.Id;
            quoteProdList[i].Product__c = prodlist[i].Id;
            quoteProdList[i].Asset__c = assetList[i].Id;
        }
        insert quoteProdList;
        
        PageReference pageRef = Page.VCG_CPQ_Quote;
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('Id',quote.id);
        
        test.startTest();
        VCG_CPQ_QuoteController controller = new VCG_CPQ_QuoteController(new ApexPages.StandardController(quote));
        //asserting the quote name of controller
        system.assertEquals('testQuoteData', controller.quote.name);
        test.stopTest();
        
    }
    
    /**********************************************************************************************
     * @author  vishal Shanbhag       
     * @date     1.April.2014    
     * @description:   Test method editExistingQuoteNoProd to test existing edit VCG_CPQ_Quote__c record 
     *                 with no Prod Id   
     * @Revision(s):  
     *************************************************************************************************
    static testMethod void editExistingQuoteNoProd(){
        //Creating Account Record
        Account acc = VCG_CPQ_HelperTestClass.createAccountRecord();
        insert acc;
        //to setup the opptyQuotemap data
        VCG_CPQ_QuoteController_Test testInstance = new VCG_CPQ_QuoteController_Test();
        testInstance.setupOpptyQuoteMapData1();
        //Creating Opportunity record
        Opportunity opp = VCG_CPQ_HelperTestClass.createOpportunityRecord();
        opp.AccountId = acc.Id;
        insert opp;
        //
        //Creating VCG_CPQ_Quote__c record
        VCG_CPQ_Quote__c quote = VCG_CPQ_HelperTestClass.createQuoteRecord();
        quote.Account__c = acc.Id;
        quote.Opportunity__c = opp.Id;
        insert quote;
        //
        //to setup VCG_CPQ_Quote_Product_Oppty_Product_Map__c data
        testInstance.setupOpptyProdQuoteProdMapData();
        //
        //to setup QuoteOpptyData
        testInstance.setupQuoteOpptyData();
        //
        // to insert product records
        List<Product2> prodlist = VCG_CPQ_HelperTestClass.createProductRecords();
        insert prodlist;
        
        //
        //creating Asset_c records
        List<Asset__c> assetList = new List<Asset__c>();
        Asset__c tempAsset;
        for(Integer i = 0 ; i<prodlist.size() ;i++){
            tempAsset = VCG_CPQ_HelperTestClass.createAssetRecord();
            tempAsset.Account__c = acc.Id;
            tempAsset.Opportunity__c = opp.Id;
            tempAsset.Product__c = prodlist[i].Id;
            assetList.add(tempAsset);
        }
        insert assetList;
        
        // creating quote product reccords
        List<VCG_CPQ_Quote_Product__c> quoteProdList = VCG_CPQ_HelperTestClass.createQuoteAssetRecords();
        for(Integer i = 0 ; i<quoteProdList.size() ;i++){
            quoteProdList[i].Quote__c = quote.Id;
            //quoteProdList[i].Product__c = prodlist[i].Id;
            quoteProdList[i].Asset__c = assetList[i].Id;
        }
        insert quoteProdList;
        
        PageReference pageRef = Page.VCG_CPQ_Quote;
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('Id',quote.id);
        
        test.startTest();
        VCG_CPQ_QuoteController controller = new VCG_CPQ_QuoteController(new ApexPages.StandardController(quote));
        test.stopTest();
        
    }
    
    /**********************************************************************************************
     * @author  vishal Shanbhag       
     * @date     1.April.2014    
     * @description:   Test method displayExistingAsset to test new  VCG_CPQ_Quote__c record.
                     and display existing asset
                     
     *
     * @Revision(s):  
     *********************************************************************************************
    static testMethod void displayExistingAsset() {
        // TO DO: implement unit test
        
        //Creating Account Record
        Account acc = VCG_CPQ_HelperTestClass.createAccountRecord();
        insert acc;
        //to setup the opptyQuotemap data
        VCG_CPQ_QuoteController_Test testInstance = new VCG_CPQ_QuoteController_Test();
        testInstance.setupOpptyQuoteMapData1();
        //Creating Opportunity record
        Opportunity opp = VCG_CPQ_HelperTestClass.createOpportunityRecord();
        opp.AccountId = acc.Id;
        opp.Start_Date__c = date.today();
        insert opp;
        //
        //to setup VCG_CPQ_Quote_Product_Oppty_Product_Map__c data
        testInstance.setupOpptyProdQuoteProdMapData();
        //
        //to setup QuoteOpptyData
        testInstance.setupQuoteOpptyData();
        //
        // to insert product records
        List<Product2> prodlist = VCG_CPQ_HelperTestClass.createProductRecords();
        insert prodlist;
        
        //
        //creating Asset_c records
        List<Asset__c> assetList = new List<Asset__c>();
        Asset__c tempAsset;
        for(Integer i = 0 ; i<prodlist.size() ;i++){
            tempAsset = VCG_CPQ_HelperTestClass.createAssetRecord();
            tempAsset.Account__c = acc.Id;
            tempAsset.Opportunity__c = opp.Id;
            tempAsset.Product__c = prodlist[i].Id;
            assetList.add(tempAsset);
        }
        insert assetList;
        
        
        //Creating VCG_CPQ_Quote__c record
        VCG_CPQ_Quote__c quote = VCG_CPQ_HelperTestClass.createQuoteRecord();
        
        //creating existing quote record
        
        
        PageReference pageRef = Page.VCG_CPQ_Quote;
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('OppId',opp.id);
        system.debug('****test class opp Id' + opp.id);
        
        test.startTest();
        VCG_CPQ_QuoteController controller = new VCG_CPQ_QuoteController(new ApexPages.StandardController(quote));
        system.assertEquals(true,controller.qpwList.size()>0);
        
        test.stopTest();
        system.debug('*************quopte***'+controller.quote);
        
    }
    
    /**********************************************************************************************
     * @author  vishal Shanbhag       
     * @date     1.April.2014    
     * @description:   Test method EditExistingAsset to test new  VCG_CPQ_Quote__c record.
                     and display existing asset
                    
     *
     * @Revision(s):  
     **********************************************************************************************
@isTest (SeeAllData = true)
    static void editExistingAsset(){
        // TO DO: implement unit test
        
        //Creating Account Record
        Account acc = VCG_CPQ_HelperTestClass.createAccountRecord();
        insert acc;
        //to setup the opptyQuotemap data
        VCG_CPQ_QuoteController_Test testInstance = new VCG_CPQ_QuoteController_Test();
        testInstance.setupOpptyQuoteMapData1();
        //Creating Opportunity record
        Opportunity opp = VCG_CPQ_HelperTestClass.createOpportunityRecord();
        opp.AccountId = acc.Id;
        opp.Start_Date__c = date.today();
        insert opp;
        //
        //to setup VCG_CPQ_Quote_Product_Oppty_Product_Map__c data
        testInstance.setupOpptyProdQuoteProdMapData();
        //
        //to setup QuoteOpptyData
        testInstance.setupQuoteOpptyData();
        //
        // querying standard pricebook Id
        Pricebook2 standardPB = [select id from Pricebook2 where isStandard=true];
        //
        // to insert product records
        List<Product2> prodlist = VCG_CPQ_HelperTestClass.createProductRecords();
        insert prodlist;
        
        // creating PriceBookEntry Records
        List<PricebookEntry> PBEList = VCG_CPQ_HelperTestClass.createPriceBookEntryRecord();
        for(integer i =0 ; i<prodlist.size(); i++){
            PBEList[i].Pricebook2Id = standardPB.Id;
            PBEList[i].Product2Id = prodlist[i].Id;
        }
        insert PBEList;
        //
        //creating Asset_c records
        List<Asset__c> assetList = new List<Asset__c>();
        Asset__c tempAsset;
        for(Integer i = 0 ; i<prodlist.size() ;i++){
            tempAsset = VCG_CPQ_HelperTestClass.createAssetRecord();
            tempAsset.Account__c = acc.Id;
            tempAsset.Opportunity__c = opp.Id;
            tempAsset.Product__c = prodlist[i].Id;
            tempAsset.Product_Group__c = 'Group 1';
            assetList.add(tempAsset);
        }
        insert assetList;
        
        
        //Creating VCG_CPQ_Quote__c record
        VCG_CPQ_Quote__c quote = VCG_CPQ_HelperTestClass.createQuoteRecord();
        
        PageReference pageRef = Page.VCG_CPQ_Quote;
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('OppId',opp.id);
        //
        //start test
        test.startTest();
        VCG_CPQ_QuoteController controller = new VCG_CPQ_QuoteController(new ApexPages.StandardController(quote));
        
        //
        //editing License_Metric_Quantity__c of existing assets
        controller.qpwList[0].quoteProdRec.License_Metric_Quantity__c = 23.0;
        controller.pricing();
        // asserting the linr type of the existing asset after pricing method
        system.assertEquals('Extension', controller.qpwList[0].quoteProdRec.Line_Type__c);
        //controller.groupedQpwMap.values()[0][0].quoteProdRec.License_Metric_Quantity__c = null;
        system.assertEquals(1, controller.groupedQpwMap.values().size());
        //system.assertEquals(true, controller.groupedQpwMap.keyset().contains('Stand-alone'));
        
        
        controller.pricing();
        //
        //put values in both License_Metric_Quantity__c and Decommission_Quantity__c
        //controller.activeGroup = ''
        controller.qpwList[0].quoteProdRec.License_Metric_Quantity__c = 52.0;
        controller.qpwList[0].quoteProdRec.Decommission_Quantity__c = 23.0;
        //controller.groupedQpwMap.values()
        controller.pricing();
        //making the License_Metric_Quantity__c of existing produxt null and caLL pricing method
        controller.qpwList[0].quoteProdRec.License_Metric_Quantity__c = null;
        controller.pricing();
        
        //
        //editing Decommission_Quantity__c of existing assets 
        controller.qpwList[1].quoteProdRec.Decommission_Quantity__c = 5.0;
        controller.pricing();
        // asserting the linr type of the existing asset after pricing method
        system.assertEquals('Decommission', controller.qpwList[1].quoteProdRec.Line_Type__c);
        //making the Decommission_Quantity__c of existing produxt null and call pricing method
        controller.qpwList[1].quoteProdRec.Decommission_Quantity__c = null;
        controller.pricing();
        system.assertEquals(false,controller.qpwList[1].isDecommission);
        //
        //
        controller.eqProductId= controller.qpwList[2].productRec.Id;
        pageRef.getParameters().put('group','Group 1');
        //controller.activeGroup = 'Group 1';
        controller.showEditEndDate();
        system.assertEquals(true,controller.isEditEndDate);
        controller.editQP.Asset_Term_End_Date__c  = controller.qpwList[2].assetRec.Asset_Term_End_Date__c.addMonths(4);
        controller.updateEndDate();
        system.assertEquals(Date.today().addMonths(2), controller.qpwList[2].assetRec.Asset_Term_End_Date__c);
        
        //
        ///testing cancelEdit method
        controller.eqProductId= controller.qpwList[1].productRec.Id;
        controller.activeGroup = 'Group 1';
        controller.showEditEndDate();
        system.assertEquals(true,controller.isEditEndDate);
        controller.editQP.Asset_Term_End_Date__c  = date.today().addMonths(4);
        controller.cancelEdit();
        system.assertEquals(false,controller.isEditEndDate);
        
        controller.addGroup();
        
        pageRef.getParameters().put('group','Group 2');
        controller.deleteGroup();
        
        //testing save method
        test.stopTest();
        controller.save();
        system.assertEquals(4,controller.qpwList.size());
        
    }
    
    //
    //
    //
    
    static testMethod void testupdateCommonTermEndDate(){
        // TO DO: implement unit test
        
        //Creating Account Record
        Account acc = VCG_CPQ_HelperTestClass.createAccountRecord();
        insert acc;
        //to setup the opptyQuotemap data
        VCG_CPQ_QuoteController_Test testInstance = new VCG_CPQ_QuoteController_Test();
        testInstance.setupOpptyQuoteMapData1();
        //Creating Opportunity record
        Opportunity opp = VCG_CPQ_HelperTestClass.createOpportunityRecord();
        opp.AccountId = acc.Id;
        opp.Start_Date__c = date.today();
        insert opp;
        //
        //to setup VCG_CPQ_Quote_Product_Oppty_Product_Map__c data
        testInstance.setupOpptyProdQuoteProdMapData();
        //
        //to setup QuoteOpptyData
        testInstance.setupQuoteOpptyData();
        //
        // to insert product records
        List<Product2> prodlist = VCG_CPQ_HelperTestClass.createProductRecords();
        insert prodlist;
        
        //
        //creating Asset_c records
        List<Asset__c> assetList = new List<Asset__c>();
        Asset__c tempAsset;
        for(Integer i = 0 ; i<prodlist.size() ;i++){
            tempAsset = VCG_CPQ_HelperTestClass.createAssetRecord();
            tempAsset.Account__c = acc.Id;
            tempAsset.Opportunity__c = opp.Id;
            tempAsset.Product__c = prodlist[i].Id;
            tempAsset.Product_Group__c = 'Group 1';
            assetList.add(tempAsset);
        }
        insert assetList;
        
        
        //Creating VCG_CPQ_Quote__c record
        VCG_CPQ_Quote__c quote = VCG_CPQ_HelperTestClass.createQuoteRecord();
        
        //creating existing quote record
        
        
        PageReference pageRef = Page.VCG_CPQ_Quote;
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('OppId',opp.id);
        system.debug('****test class opp Id' + opp.id);
        
        test.startTest();
        VCG_CPQ_QuoteController controller = new VCG_CPQ_QuoteController(new ApexPages.StandardController(quote));
        //
        //testing updateCommonTermEndDate method
        
        controller.eqProductId= controller.groupedQpwMap.get('Group 1')[0].productRec.Id;
        pageRef.getParameters().put('group','Group 1');
        controller.showEditEndDate();
        controller.editQP.Asset_Term_End_Date__c  = date.today().addYears(4);
        controller.updateCommonTermEndDate();
        test.stopTest();
        system.assertEquals(4,controller.qpwList.size());
        
    }
    
    /**********************************************************************************************
     * @author  vishal Shanbhag       
     * @date     1.April.2014    
     * @description:   Test method showTotalExtenAddNew to test new  VCG_CPQ_Quote__c record.
                     and total of existing and new quote products and recommendation functionality
                     
     *
     * @Revision(s):  
     **********************************************************************************************
    static testMethod void showTotalExtenAddNew(){
        //Creating Account Record
        Account acc = VCG_CPQ_HelperTestClass.createAccountRecord();
        insert acc;
        //to setup the opptyQuotemap data
        //VCG_CPQ_QuoteController_Test testInstance = new VCG_CPQ_QuoteController_Test();
        //testInstance.setupOpptyQuoteMapData1();
        //Creating Opportunity record
        Opportunity opp = VCG_CPQ_HelperTestClass.createOpportunityRecord();
        opp.AccountId = acc.Id;
        opp.Start_Date__c = date.today();
        insert opp;
        //
        //to setup VCG_CPQ_Quote_Product_Oppty_Product_Map__c data
        //testInstance.setupOpptyProdQuoteProdMapData();
        //
        //to setup QuoteOpptyData
        //testInstance.setupQuoteOpptyData();
        //
        // to insert product records
        List<Product2> prodlist = VCG_CPQ_HelperTestClass.createProductRecords();
        for(Product2 p : prodlist)
        {
//          p.Product_Filter_Key_Text__c = 'Test'; 
            p.Family = 'Test';
        }
        insert prodlist;
        
        //
        //creating Asset_c records
        List<Asset__c> assetList = new List<Asset__c>();
        Asset__c tempAsset;
        for(Integer i = 0 ; i<prodlist.size() ;i++){
            tempAsset = VCG_CPQ_HelperTestClass.createAssetRecord();
            tempAsset.Account__c = acc.Id;
            tempAsset.Opportunity__c = opp.Id;
            tempAsset.Product__c = prodlist[i].Id;
            assetList.add(tempAsset);
        }
        insert assetList;
        //Creating VCG_CPQ_Quote__c record
        //VCG_CPQ_Quote__c quote = VCG_CPQ_HelperTestClass.createQuoteRecord();
        
        //creating existing quote record
        PageReference pageRef = Page.VCG_CPQ_Quote;
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('OppId',opp.id);
        //
        test.startTest(); 
        
        
        VCG_CPQ_QuoteController controller = new VCG_CPQ_QuoteController(new ApexPages.StandardController(new VCG_CPQ_Quote__c()));
        
        //
        //editing License_Metric_Quantity__c of existinf assets
        controller.qpwList[0].quoteProdRec.License_Metric_Quantity__c = 23.0;
        //controller.pricing();
        //system.assertEquals(true, controller.qpwList[0].isExtension);
        
        //
        //testing add new funcitonality
        controller.showAddNew();
        system.assertEquals(true, controller.isAddNew);
        //controller.pfWrapperList[0].isSelected = true;
        controller.targetPFK = 'Test';
        controller.showFilteredNewProducts();
        //
        //asserting the size of addNewFilteredProdList
        system.assertEquals(prodlist.size(),controller.addNewFilteredProdList.size());
        
        //
        // filling up quantity for addnew prods
        controller.addNewFilteredProdList[0].quoteProdRec.License_Metric_Quantity__c = 12.0;
        VCG_CPQ_Product_Addon__c addOn = new VCG_CPQ_Product_Addon__c();
        addOn.Product__c = controller.addNewFilteredProdList[0].quoteProdRec.Product__c;
        addOn.Product_Addon__c = prodlist[0].Id;
        addOn.Required__c = '0';
        insert addOn;
        
        //
        VCG_CPQ_Product_Dependency__c prodDependency = new VCG_CPQ_Product_Dependency__c();
        prodDependency.Match_Quantity__c = false;
        prodDependency.Product__c = controller.addNewFilteredProdList[0].quoteProdRec.Product__c;
        prodDependency.Dependent_Product__c = prodlist[0].Id;
        insert prodDependency;
        
        //verify that we have add-ons according to the Product Utility
        System.Assert(VCG_CPQ_ProductUtility.getAddonProducts(controller.quote, new list<VCG_CPQ_Quote_Product__c>{controller.addNewFilteredProdList[0].quoteProdRec}).size() > 0);
        
        //chcecking the recommendation list 
        controller.getRecAddOns();
        
        // asserting the size of recAddOnsList to check the number of recommended products
        system.assertEquals(1, controller.recAddOnsList.size());
        controller.recAddOnsList[0].quoteProdRec.License_Metric_Quantity__c  = 25.0;
        // to find recommendation for recomended prods
        controller.getRecAddOns();
        controller.addProducts();
        // asserting the size of quote product list after add products
        
        //system.assertEquals(5,controller.qpwList.size());
        //
        //testing showQuoteDetailsPopup method
        controller.showQuoteDetailsPopup();
        system.assertEquals(true, controller.showQuoteDetails);
        //testing hideQuoteTotalWindow method 
        controller.hideQuoteDetailsPopup();
        system.assertEquals(false, controller.showQuoteDetails);
        test.stopTest();
    }
    
    /**********************************************************************************************
     * @author  vishal Shanbhag       
     * @date     25.April.2014    
     * @description:   Test method testAddBundles to test new  VCG_CPQ_Quote__c record.
                     and display and adding VCG_CPQ_Bundle__c records
                     
     *
     * @Revision(s):  
     **********************************************************************************************
    static testMethod void testAddBundles(){
        //Creating Account Record
        Account acc = VCG_CPQ_HelperTestClass.createAccountRecord();
        insert acc;
        //to setup the opptyQuotemap data
        VCG_CPQ_QuoteController_Test testInstance = new VCG_CPQ_QuoteController_Test();
        testInstance.setupOpptyQuoteMapData1();
        //Creating Opportunity record
        Opportunity opp = VCG_CPQ_HelperTestClass.createOpportunityRecord();
        opp.AccountId = acc.Id;
        opp.Start_Date__c = date.today();
        insert opp;
        //
        //to setup VCG_CPQ_Quote_Product_Oppty_Product_Map__c data
        testInstance.setupOpptyProdQuoteProdMapData();
        //
        //to setup QuoteOpptyData
        testInstance.setupQuoteOpptyData();
        //
        // to insert product records
        List<Product2> prodlist = VCG_CPQ_HelperTestClass.createProductRecords(); 
        for(Product2 p : prodlist)
        {
            p.Product_Filter_Key_Text__c = 'Asbestos'; 
            p.Is_Groupable__c = true;
            p.Family = 'Asbestos';
        }
        insert prodlist;
        
        //
        //creating Asset_c records
        /*
        List<Asset__c> assetList = new List<Asset__c>();
        Asset__c tempAsset;
        for(Integer i = 0 ; i<prodlist.size() ;i++){
            tempAsset = VCG_CPQ_HelperTestClass.createAssetRecord();
            tempAsset.Account__c = acc.Id;
            tempAsset.Opportunity__c = opp.Id;
            tempAsset.Product__c = prodlist[i].Id;
            assetList.add(tempAsset);
        }
        insert assetList;
        *
        //Creating bundle record
        List<VCG_CPQ_Bundle__c> bundleList = VCG_CPQ_HelperTestClass.createBundleRecord();
        for(Integer i = 0 ;i<bundleList.size();i++){
            bundleList[i].Product__c = prodlist[i].Id;
        }
        insert bundleList;
        
        //Creating VCG_CPQ_Quote__c record
        VCG_CPQ_Quote__c quote = VCG_CPQ_HelperTestClass.createQuoteRecord();
        
        //creating existing quote record
        PageReference pageRef = Page.VCG_CPQ_Quote;
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('OppId',opp.id);
        system.debug('****test class opp Id' + opp.id);
        
        test.startTest();
        //
        //instantiating pricingUitility class
        VCG_CPQ_QuoteController controller = new VCG_CPQ_QuoteController(new ApexPages.StandardController(quote));
        //system.assertEquals(4, controller.qpwList.size());

        //
        //testing add bundle funcitonality
        controller.showAddNew();
        System.assertEquals(true, controller.isAddNew);
        System.assertEquals(2, controller.availableBundles.size());

        //
        String bundleName = bundleList[0].Bundle_Name__c;
        controller.availableBundles.get(bundleName).isSelected = true;
        pageRef.getParameters().put('selectedBundle', bundleName);
        controller.showFilteredBundledNewProducts();
        System.assertEquals(2, controller.addNewFilteredProdList.size());
        
        //
        controller.addNewFilteredProdList[0].quoteProdRec.License_Metric_Quantity__c = 10.0;
        controller.addNewFilteredProdList[1].quoteProdRec.License_Metric_Quantity__c = 10.0;
        controller.addProducts();
        system.assertEquals(2, controller.qpwList.size());
        //saving records
        controller.save();
        test.stopTest();
    
    }
    
    /**********************************************************************************************
     * @author  vishal Shanbhag       
     * @date     6.May.2014    
     * @description:   Test method addExistingBundle to test new  VCG_CPQ_Quote__c record.
                     and adding the bundle which already exists
                     
     *
     * @Revision(s):  
     **********************************************************************************************
    static testMethod void addNewProductToABundle(){
        // TO DO: implement unit test
        
        //Creating Account Record
        Account acc = VCG_CPQ_HelperTestClass.createAccountRecord();
        insert acc;
        //to setup the opptyQuotemap data
        VCG_CPQ_QuoteController_Test testInstance = new VCG_CPQ_QuoteController_Test();
        testInstance.setupOpptyQuoteMapData1();
        //Creating Opportunity record
        Opportunity opp = VCG_CPQ_HelperTestClass.createOpportunityRecord();
        opp.AccountId = acc.Id;
        opp.Start_Date__c = date.today();
        insert opp;
        //
        //to setup VCG_CPQ_Quote_Product_Oppty_Product_Map__c data
        testInstance.setupOpptyProdQuoteProdMapData();
        //
        //to setup QuoteOpptyData
        testInstance.setupQuoteOpptyData();
        //
        // to insert product records
        List<Product2> prodlist = VCG_CPQ_HelperTestClass.createProductRecords();
        for(Product2 p : prodlist)
        {
            p.Product_Filter_Key_Text__c = 'Asbestos';
            p.Is_Groupable__c = true;
            p.Family = 'Asbestos';
        }
            
        insert prodlist;
        
        
        //
        //creating Asset_c records
        /*
        List<Asset__c> assetList = new List<Asset__c>();
        Asset__c tempAsset;
        for(Integer i = 0 ; i<prodlist.size() ;i++)
        {
            tempAsset                = VCG_CPQ_HelperTestClass.createAssetRecord();
            tempAsset.Name           = 'Triton APX';
            tempAsset.Account__c     = acc.Id;
            tempAsset.Opportunity__c = opp.Id;
            tempAsset.Product__c     = prodlist[1].Id;
            tempAsset.Bundle_Name__c = 'Triton APX';
            assetList.add(tempAsset);
        }
        insert assetList[0];
        
        //
        //inserting temporary asset not as bundle
        Asset__c ast = VCG_CPQ_HelperTestClass.createAssetRecord();
        ast.Account__c = acc.Id;
        ast.Opportunity__c = opp.Id;
        ast.Product__c = prodlist[0].Id;
        insert ast;
        *
        //Creating bundle record
        List<VCG_CPQ_Bundle__c> bundleList = VCG_CPQ_HelperTestClass.createBundleRecord();
        for(Integer i = 0 ;i<bundleList.size();i++){
            bundleList[i].Product__c = prodlist[i].Id;
        }
        insert bundleList;
        //Creating VCG_CPQ_Quote__c record
        VCG_CPQ_Quote__c quote = VCG_CPQ_HelperTestClass.createQuoteRecord();
        
        PageReference pageRef = Page.VCG_CPQ_Quote;
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('OppId',opp.id);
        test.startTest();
        
        VCG_CPQ_QuoteController controller = new VCG_CPQ_QuoteController(new ApexPages.StandardController(quote));
        controller.pricing();
        
        //add a Bundle
        controller.addGroup();
        
        //verify that we have a bundle map size
        System.assertEquals(1, controller.groupedQpwMap.size());
        
        //testing adding to a bundle
        list<String> groupList = new list<String>();
        groupList.addAll(controller.groupedQpwMap.keySet());
        
        ApexPages.currentPage().getParameters().put('group', groupList[0]);
        controller.showAddNew();
        
        System.assertEquals(controller.activeGroup, 'Group 1');
        
        //controller.availableBundles.get(bundleList[3].Bundle_Name__c).isSelected = true;
        System.assert(controller.addNewProductMap.size() > 0);
        controller.targetPFK = 'Asbestos';
        controller.showFilteredNewProducts();
        
        VCG_CPQ_Quote_Product__c qp = controller.addNewFilteredProdList[0].quoteProdRec;
        controller.addNewFilteredProdList[0].quoteProdRec.License_Metric_Quantity__c = 10;
        System.assertEquals(controller.activeGroup, 'Group 1');
        System.assertEquals(qp.Product_Group__c, null);
        controller.addProducts();
        
        //verify that the quote product is grouped
        System.assert(controller.qpwMap.size() > 0);
        System.assert(controller.getQPWMapKey(qp.Product__c, groupList[0]).endsWith('Group 1'));
        System.assertEquals(qp.Product_Group__c, groupList[0]);
        
        controller.save();
        test.stopTest();
        
        
    }   
    
    /**********************************************************************************************
     * @author  vishal Shanbhag       
     * @date     1.April.2014    
     * @description:   Test method testUpdateEndDateRenweProd to test new  Addnew and Add buttons on UI
                       also testing renewal of new products
                     
     *
     * @Revision(s):  
     **********************************************************************************************
    static testMethod void testAddProducts(){
        // TO DO: implement unit test
        
        //Creating Account Record
        Account acc = VCG_CPQ_HelperTestClass.createAccountRecord();
        insert acc;
        //to setup the opptyQuotemap data
        VCG_CPQ_QuoteController_Test testInstance = new VCG_CPQ_QuoteController_Test();
        testInstance.setupOpptyQuoteMapData1();
        //Creating Opportunity record
        Opportunity opp = VCG_CPQ_HelperTestClass.createOpportunityRecord();
        opp.AccountId = acc.Id;
        opp.Start_Date__c = date.today();
        insert opp;
        //
        //to setup VCG_CPQ_Quote_Product_Oppty_Product_Map__c data
        testInstance.setupOpptyProdQuoteProdMapData();
        //
        //to setup QuoteOpptyData
        testInstance.setupQuoteOpptyData();
        //
        // to insert product records
        List<Product2> prodlist = VCG_CPQ_HelperTestClass.createProductRecords();
        insert prodlist;
        
        //
        //creating Asset_c records
        List<Asset__c> assetList = new List<Asset__c>();
        Asset__c tempAsset;
        for(Integer i = 0 ; i<prodlist.size() ;i++){
            tempAsset = VCG_CPQ_HelperTestClass.createAssetRecord();
            tempAsset.Account__c = acc.Id;
            tempAsset.Opportunity__c = opp.Id;
            tempAsset.Product__c = prodlist[i].Id;
            tempAsset.Product_Group__c='Group 1';
            assetList.add(tempAsset);
        }
        insert assetList;
        
        
        //Creating VCG_CPQ_Quote__c record
        VCG_CPQ_Quote__c quote = VCG_CPQ_HelperTestClass.createQuoteRecord();
        
        //creating existing quote record
        PageReference pageRef = Page.VCG_CPQ_Quote;
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('OppId',opp.id);
        test.startTest();
        //
        //instantiating pricingUitility class
        VCG_CPQ_QuoteController controller = new VCG_CPQ_QuoteController(new ApexPages.StandardController(quote));
        system.assertEquals(4, controller.qpwList.size());
        //
        //testing add new funcitonality
        controller.showAddNew();
        system.assertEquals(true, controller.isAddNew);
        system.debug('****prod family wrapeer list' +controller.pfWrapperList);
        controller.pfWrapperList[0].isSelected = true;
        controller.showFilteredNewProducts();
        //
        // filling up quantity for addnew prods
        controller.addNewFilteredProdList[0].quoteProdRec.License_Metric_Quantity__c = 12.0;
        controller.addProducts();
        //chcecking the recommendation list 
        controller.showFilteredNewProducts();
        controller.addProducts();
        //testing showEditStartDate and updateStartDate
        
        controller.eqProductId= assetList[0].Product__c;
        system.assertNotEquals(null, controller.groupedQpwMap.values()[0][0].productRec.Id);
        //system.assertNotEquals(null, controller.qpwMap.get(controller.eqProductId + controller.activeGroup));
        //
        // temporarily commenting controller.showEditStartDate() to fix it in controller class
        pageRef.getParameters().put('group','Group 1');
        controller.activeGroup = 'Group 1';
        controller.showEditStartDate();
        controller.editQP.Asset_Term_Start_Date__c  = date.today().addDays(4);
        controller.updateStartDate();
        
        //
        //asserting quote product begins date to check term begin date 
        //system.assertEquals(date.today().addDays(4),controller.qpwList[0].quoteProdRec.Asset_Term_Start_Date__c);
        
        // testing cancelEdit()
        controller.cancelEdit();
        system.assertEquals(false, controller.isEditStartDate);
                
        controller.showHidePricingResults();
        system.assertEquals(true, controller.showPricingResults);
        //saving records
        controller.save();
        test.stopTest();
        
        
    }   

    /**********************************************************************************************
     * @author  vishal Shanbhag       
     * @date     1.April.2014    
     * @description:   Test method testAddMoreProducts to test new  Add&More button on UI
                     
     *
     * @Revision(s):  /
     **********************************************************************************************
    static testMethod void testAddMoreProducts(){
        // TO DO: implement unit test
        
        //Creating Account Record
        Account acc = VCG_CPQ_HelperTestClass.createAccountRecord();
        insert acc;
        //to setup the opptyQuotemap data
        VCG_CPQ_QuoteController_Test testInstance = new VCG_CPQ_QuoteController_Test();
        testInstance.setupOpptyQuoteMapData1();
        //Creating Opportunity record
        Opportunity opp = VCG_CPQ_HelperTestClass.createOpportunityRecord();
        opp.AccountId = acc.Id;
        opp.Start_Date__c = date.today();
        insert opp;
        //
        //to setup VCG_CPQ_Quote_Product_Oppty_Product_Map__c data
        testInstance.setupOpptyProdQuoteProdMapData();
        //
        //to setup QuoteOpptyData
        testInstance.setupQuoteOpptyData();
        //
        // to insert product records
        List<Product2> prodlist = VCG_CPQ_HelperTestClass.createProductRecords();
        insert prodlist;
        
        //
        //creating Asset_c records
        List<Asset__c> assetList = new List<Asset__c>();
        Asset__c tempAsset;
        for(Integer i = 0 ; i<prodlist.size() ;i++){
            tempAsset = VCG_CPQ_HelperTestClass.createAssetRecord();
            tempAsset.Account__c = acc.Id;
            tempAsset.Opportunity__c = opp.Id;
            tempAsset.Product__c = prodlist[i].Id;
            assetList.add(tempAsset);
        }
        insert assetList;
        
        
        //Creating VCG_CPQ_Quote__c record
        VCG_CPQ_Quote__c quote = VCG_CPQ_HelperTestClass.createQuoteRecord();
        
        //creating existing quote record
        PageReference pageRef = Page.VCG_CPQ_Quote;
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('OppId',opp.id);
        system.debug('****test class opp Id' + opp.id);
        
        test.startTest();
        //
        //instantiating pricingUitility class
        
        VCG_CPQ_QuoteController controller = new VCG_CPQ_QuoteController(new ApexPages.StandardController(quote));
        
        //
        //testing add new funcitonality
        controller.showAddNew();
        system.assertEquals(true, controller.isAddNew);
        system.debug('****prod family wrapeer list' +controller.pfWrapperList);
        controller.pfWrapperList[0].isSelected = true;
        controller.showFilteredNewProducts();
        
        //
        // filling up quantity for addnew prods
        controller.addNewFilteredProdList[0].quoteProdRec.License_Metric_Quantity__c = 12.0;
        //chcecking the recommendation list 
        controller.showFilteredNewProducts();
        system.assertEquals(true,controller.addNewFilteredProdList.size()>0);
        if(controller.recAddOnsList.size()>0){
            controller.recAddOnsList[0].quoteProdRec.License_Metric_Quantity__c  = 25.0;
        }
        controller.addMoreProducts();
        system.assertEquals(0,controller.recAddOnsList.size());
        //
        //testing cancel button
        controller.hideAddNew();
        system.assertEquals(false, controller.isAddNew);
        
        //saving records
        controller.save();
        
        test.stopTest();
        
    }
    
    /**********************************************************************************************
     * @author  vishal Shanbhag       
     * @date     1.April.2014    
     * @description:   Test method testNoExsting Assets and AddNew panel 
                     
     *
     * @Revision(s):  
     ***********************************************************************************************
    @isTest (seeAllData = true)
    static void testNoExistingAssets(){
        // TO DO: implement unit test 
        
        //Creating Account Record
        Account acc = VCG_CPQ_HelperTestClass.createAccountRecord();
        insert acc;
        //to setup the opptyQuotemap data
        VCG_CPQ_QuoteController_Test testInstance = new VCG_CPQ_QuoteController_Test();
        testInstance.setupOpptyQuoteMapData1();
        //Creating Opportunity record
        Opportunity opp = VCG_CPQ_HelperTestClass.createOpportunityRecord();
        opp.AccountId = acc.Id;
        opp.Start_Date__c = date.today();
        insert opp;
        //
        //to setup VCG_CPQ_Quote_Product_Oppty_Product_Map__c data
        testInstance.setupOpptyProdQuoteProdMapData();
        //
        //to setup QuoteOpptyData
        testInstance.setupQuoteOpptyData();
        //
        Pricebook2 standardPB = [select id from Pricebook2 where isStandard=true];
        //
        // to insert product records
        List<Product2> prodlist = VCG_CPQ_HelperTestClass.createProductRecords();
        insert prodlist;
        
        // creating PriceBookEntry Records
        List<PricebookEntry> PBEList = VCG_CPQ_HelperTestClass.createPriceBookEntryRecord();
        for(integer i =0 ; i<prodlist.size(); i++){
            PBEList[i].Pricebook2Id = standardPB.Id;
            PBEList[i].Product2Id = prodlist[i].Id;
        }
        insert PBEList;
        
        //Creating VCG_CPQ_Quote__c record
        VCG_CPQ_Quote__c quote = VCG_CPQ_HelperTestClass.createQuoteRecord();
        
        //creating existing quote record
        PageReference pageRef = Page.VCG_CPQ_Quote;
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('OppId',opp.id);
        test.startTest();
        VCG_CPQ_QuoteController controller = new VCG_CPQ_QuoteController(new ApexPages.StandardController(quote));
        
        //
        //testing add new funcitonality
        controller.showAddNew();
        system.assertEquals(true, controller.isAddNew);
        controller.pfWrapperList[0].isSelected = true;
        controller.showFilteredNewProducts();
        //
        // filling up quantity for addnew prods
        controller.addNewFilteredProdList[0].quoteProdRec.License_Metric_Quantity__c = 12.0;
        controller.addProducts();
        //asserting  the size of qpwList list to check if quote product is added
        system.assertequals(1,controller.qpwList.size());
        controller.qpwList[0].quoteProdRec.License_Metric_Quantity__c = 45.0;
        controller.pricing();
        
        controller.save();
        test.stopTest();
        
    }
    
    /**********************************************************************************************
     * @author  vishal Shanbhag       
     * @date     8.May.2014    
     * @description:   Test method testProdEquivalAndMigrating to test new  VCG_CPQ_Quote__c record.
                     and display existing asset and product equivalency and migrating
                     
     *
     * @Revision(s):  
    *********************************************************************************************
    static testMethod void testProdEquivalAndMigrating() {
        // TO DO: implement unit test
        
        //Creating Account Record
        Account acc = VCG_CPQ_HelperTestClass.createAccountRecord();
        insert acc; 
        //to setup the opptyQuotemap data
        VCG_CPQ_QuoteController_Test testInstance = new VCG_CPQ_QuoteController_Test();
        testInstance.setupOpptyQuoteMapData1();
        //Creating Opportunity record
        Opportunity opp = VCG_CPQ_HelperTestClass.createOpportunityRecord();
        opp.AccountId = acc.Id;
        opp.Start_Date__c = date.today();
        insert opp;
        //
        //to setup VCG_CPQ_Quote_Product_Oppty_Product_Map__c data
        testInstance.setupOpptyProdQuoteProdMapData();
        //
        //to setup QuoteOpptyData
        testInstance.setupQuoteOpptyData();
        //
        // to insert product records
        List<Product2> prodlist = VCG_CPQ_HelperTestClass.createProductRecords();
        for(integer i = 1 ; i<prodlist.size() ; i++){
            prodlist[i].Is_Groupable__c = true;
        }
        insert prodlist;
        
        //
        //creating product equivalency data
        VCG_CPQ_Product_Equivalency__c prodEquival = new VCG_CPQ_Product_Equivalency__c();
        prodEquival.Is_Many_to_One__c = false;
        prodEquival.Equivalent_Product__c = prodlist[0].Id;
        prodEquival.Legacy_Product__c = prodlist[1].Id;
        insert prodEquival;
        
        VCG_CPQ_Product_Equivalency__c prodEquival1 = new VCG_CPQ_Product_Equivalency__c();
        prodEquival1.Is_Many_to_One__c = false;
        prodEquival1.Equivalent_Product__c = prodlist[2].Id;
        prodEquival1.Legacy_Product__c = prodlist[3].Id;
        insert prodEquival1;
        
        //
        //creating Asset_c records
        List<Asset__c> assetList = new List<Asset__c>();
        Asset__c tempAsset;
        for(Integer i = 0 ; i<prodlist.size() ;i++){
            tempAsset = VCG_CPQ_HelperTestClass.createAssetRecord();
            tempAsset.Product_Group__c = 'Group 1';
            tempAsset.Account__c = acc.Id;
            tempAsset.Opportunity__c = opp.Id;
            tempAsset.Product__c = prodlist[i].Id;
            assetList.add(tempAsset);
        }
        insert assetList[3];
        insert assetList[1];
        
        
        //Creating VCG_CPQ_Quote__c record
        VCG_CPQ_Quote__c quote = VCG_CPQ_HelperTestClass.createQuoteRecord();
        
        PageReference pageRef = Page.VCG_CPQ_Quote;
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('OppId',opp.id);
        system.debug('****test class opp Id' + opp.id);
        
        test.startTest();
        VCG_CPQ_QuoteController controller = new VCG_CPQ_QuoteController(new ApexPages.StandardController(quote));
        system.assertEquals(true,controller.qpwList.size()>0);
        system.assert(true, controller.groupedQpwMap.size()>0);
        system.debug(':::::group keys::'+ controller.groupedQpwMap.keyset());
        controller.groupedQpwMap.get('Group 1')[1].hasEquivalency = true;
        system.assertEquals(false,controller.groupedQpwMap.get('Group 1')[1].isMigrated);
        controller.migrateProdId =  controller.groupedQpwMap.get('Group 1')[1].productRec.Id;
        controller.activeGroup = 'Group 1';
        controller.migrateProduct();
        test.stopTest();
    }
    
    /**********************************************************************************************
     * @author  vishal Shanbhag       
     * @date     22.May.2014    
     * @description:   Test method testCloneQuote to test cloning funtionality of VCG_CPQ_Quote__c record 
     *
     * @Revision(s):  
     ********************************************************************************************
    static testMethod void testCloneQuote(){ 
        //Creating Account Record
        Account acc = VCG_CPQ_HelperTestClass.createAccountRecord();
        insert acc;
        //to setup the opptyQuotemap data
        VCG_CPQ_QuoteController_Test testInstance = new VCG_CPQ_QuoteController_Test();
        testInstance.setupOpptyQuoteMapData1();
        //Creating Opportunity record
        Opportunity opp = VCG_CPQ_HelperTestClass.createOpportunityRecord();
        opp.AccountId = acc.Id;
        insert opp;
        //
        //Creating VCG_CPQ_Quote__c record
        VCG_CPQ_Quote__c quote = VCG_CPQ_HelperTestClass.createQuoteRecord();
        quote.Account__c = acc.Id;
        quote.Opportunity__c = opp.Id;
        insert quote;
        //
        //to setup VCG_CPQ_Quote_Product_Oppty_Product_Map__c data
        testInstance.setupOpptyProdQuoteProdMapData();
        //
        //to setup QuoteOpptyData
        testInstance.setupQuoteOpptyData();
        //
        // to insert product records
        List<Product2> prodlist = VCG_CPQ_HelperTestClass.createProductRecords();
        insert prodlist;
        
        //
        //creating Asset_c records
        
        List<Asset__c> assetList = new List<Asset__c>();
        Asset__c tempAsset;
        for(Integer i = 0 ; i<prodlist.size() ;i++){
            tempAsset = VCG_CPQ_HelperTestClass.createAssetRecord();
            tempAsset.Account__c = acc.Id;
            tempAsset.Opportunity__c = opp.Id;
            tempAsset.Product__c = prodlist[i].Id;
            tempAsset.Product_Group__c = 'Group 1';
            assetList.add(tempAsset);
        }
        insert assetList;
        
        // creating quote product reccords
        List<VCG_CPQ_Quote_Product__c> quoteProdList = VCG_CPQ_HelperTestClass.createQuoteAssetRecords();
        for(Integer i = 0 ; i<prodlist.size() ;i++){
            quoteProdList[i].Quote__c = quote.Id;
            quoteProdList[i].Product__c = prodlist[i].Id;
            quoteProdList[i].Product_Group__c = 'Group 3';
            //quoteProdList[i].Asset__c = assetList[i].Id;
        }
        insert quoteProdList;
        
        //Creating bundle record
        List<VCG_CPQ_Bundle__c> bundleList = VCG_CPQ_HelperTestClass.createBundleRecord();
        for(Integer i = 0 ;i<bundleList.size();i++){
            bundleList[i].Product__c = prodlist[i].Id;
        }
        
        PageReference pageRef = Page.VCG_CPQ_Quote;
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('Id',quote.id);
        pageRef.getParameters().put('clone', 'true');
        
        
        test.startTest();
        VCG_CPQ_QuoteController controller = new VCG_CPQ_QuoteController(new ApexPages.StandardController(quote));
        controller.eqProductId= controller.qpwList[0].productRec.Id;
        pageRef.getParameters().put('group','Group 1');
        controller.showEditEndDate();
        controller.editQP.Asset_Term_End_Date__c  = date.today().addYears(3);
        controller.updateEndDate();
        ///testing cancelEdit method
        system.assertEquals(1,controller.groupedQpwMap.get('Stand-alone').size());
        system.assertEquals(8, controller.qpwMap.values().size()); 
        
        controller.eqProductId= controller.qpwList[5].productRec.Id;
        pageRef.getParameters().put('group','Group 3');
        //ssystem.assertNotEquals(null, controller.qpwMap.get(controller.eqProductId + controller.activeGroup));
        controller.showEditEndDate();
        //system.assertEquals(true,controller.isEditEndDate);
        controller.editQP.Asset_Term_End_Date__c  = date.today().addYears(3);
        controller.updateEndDate();
        //system.assertEquals(Date.today().addMonths(2), controller.qpwList[2].assetRec.Asset_Term_End_Date__c);
        controller.save();
        //asserting the quote name of controller
        system.assertEquals('testQuoteData', controller.quote.name);
        test.stopTest();
        
    }
    
    /**********************************************************************************************
     * @author  vishal Shanbhag       
     * @date     1.April.2014    
     * @description:   Test method testPricingOverrideNewQuote to test the pricing override functoinality
                       with creating new quote
                     
     *
     * @Revision(s):  
     *********************************************************************************************
    static testMethod void testPricingOverrideExistingQuote() {
        // TO DO: implement unit test
        
        //Creating Account Record
        Account acc = VCG_CPQ_HelperTestClass.createAccountRecord();
        insert acc;
        //to setup the opptyQuotemap data
        VCG_CPQ_QuoteController_Test testInstance = new VCG_CPQ_QuoteController_Test();
        testInstance.setupOpptyQuoteMapData1();
        //Creating Opportunity record
        Opportunity opp = VCG_CPQ_HelperTestClass.createOpportunityRecord();
        opp.AccountId = acc.Id;
        opp.Start_Date__c = date.today();
        insert opp;
        //
        //to setup VCG_CPQ_Quote_Product_Oppty_Product_Map__c data
        testInstance.setupOpptyProdQuoteProdMapData();
        //
        //to setup QuoteOpptyData
        testInstance.setupQuoteOpptyData();
        //
        // to insert product records
        List<Product2> prodlist = VCG_CPQ_HelperTestClass.createProductRecords();
        insert prodlist;
        
        
        VCG_CPQ_Quote__c quote = VCG_CPQ_HelperTestClass.createQuoteRecord();
        insert quote;
        List<VCG_CPQ_Quote_Product__c> quoteProdList = VCG_CPQ_HelperTestClass.createQuoteAssetRecords();
        for(Integer i = 0 ; i<prodlist.size() ;i++){
            quoteProdList[i].Quote__c = quote.Id;
            quoteProdList[i].Product__c = prodlist[i].Id;
            quoteProdList[i].Product_Group__c = 'Group 3';
            //quoteProdList[i].Asset__c = assetList[i].Id;
        }
        insert quoteProdList[0];
        
        //Creating VCG_CPQ_Quote__c record
        
        VCG_CPQ_Pricing_Procedure__c pricingProc = new VCG_CPQ_Pricing_Procedure__c(Needs_Fields__c = 'Sales_Price__c;Quote__r.Reseller__r.Partner_Tier__c'
                                                                                    ,Quote_Line_Type__c = 'Extension'
                                                                                    ,Description__c = 'Extension'
                                                                                    );
        insert pricingProc;
        VCG_CPQ_Pricing_Access_Sequence__c pricingAccess = new VCG_CPQ_Pricing_Access_Sequence__c(Assign_To__c = 'Sales_Price__c',
                                                                                                  Needs_Fields__c='License_Metric_Quantity__c',
                                                                                                  Name = 'DistSKU',
                                                                                                  Description__c = 'DistSKU');
        insert pricingAccess;
        
        VCG_CPQ_Pricing_Procedure_Sequence__c pricingProcSeq = new VCG_CPQ_Pricing_Procedure_Sequence__c(Access_Sequence__c =pricingAccess.Id,
                                                                                                           Pricing_Procedure__c =pricingProc.Id,
                                                                                                           Sequence__c= 1);
        insert pricingProcSeq;
        
        VCG_CPQ_Quote_Product_Pricing_Result__c pricingResult = new VCG_CPQ_Quote_Product_Pricing_Result__c(
                                                                                                            Result_Type__c='String',
                                                                                                            Result_Value_String__c = 'A',
                                                                                                            Access_Sequence__c='DistSKU',
                                                                                                            Quote_Product__c= quoteProdList[0].Id);
        insert pricingResult;
        
        
        //creating pricing override record
        VCG_CPQ_Pricing_Override__c pricingOverride = new VCG_CPQ_Pricing_Override__c(Line_Type__c = quoteProdList[0].Line_Type__c,
                                                                                      Group_Name__c='Group 3',
                                                                                      Override_Value_Str__c ='C',
                                                                                      Pricing_Procedure_Sequence__c =pricingProcSeq.Id,
                                                                                      Product__c = prodlist[0].Id,
                                                                                      Quote__c = quote.Id);
        insert pricingOverride;
        
        
        
        PageReference pageRef = Page.VCG_CPQ_Quote;
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('Id',quote.id);
        test.startTest();
        VCG_CPQ_QuoteController controller = new VCG_CPQ_QuoteController(new ApexPages.StandardController(quote));
        system.assertEquals(true,controller.qpwList.size()>0);
        //editing License_Metric_Quantity__c of existing assets
        controller.qpwList[0].quoteProdRec.License_Metric_Quantity__c = 23.0;
        controller.pricing();

/* disabled - PricingResultWrap no longer exists. Need to re-write this block -LC 2014-07-09        
        VCG_CPQ_PricingUtility.PricingResultWrap pricingUtil = new VCG_CPQ_PricingUtility.PricingResultWrap(pricingResult,pricingProc.Id);
        list<VCG_CPQ_PricingUtility.PricingResultWrap> pricingwrap = new list<VCG_CPQ_PricingUtility.PricingResultWrap>();
        pricingwrap.add(pricingUtil);
        controller.pricingResultMap.put('New-'+prodlist[0].Name, pricingwrap);
        controller.isPricingOverrideQuery = true;
        controller.getExistingPricingOverride();
        
        controller.editPricingkey = 'New-'+prodlist[0].Name;
        controller.pricingAccessSeq = pricingAccess.Name;
        controller.showEditResultValue();
        controller.editPricingResult.Result_Value_String__c = 'D';
        controller.updatePricingResultValue();  
*   
        test.stopTest();
        
        
    }
    
    /**********************************************************************************************
     * @author  vishal Shanbhag       
     * @date     1.April.2014    
     * @description:   Uitility method to setup VCG_CPQ_Opportunity_Quote_Map__c data (Object type)
     *
     * @Revision(s):  
     **********************************************************************************************/
/*  public static void setupOpptyQuoteMapData1(){
        
        VCG_CPQ_HelperTestClass helperInstance = new VCG_CPQ_HelperTestClass();
        //
        //to get the describeFields of opportunity and quote
        map<String,Schema.Describefieldresult> opptyFieldResult =helperInstance.describeOjectfields('Opportunity');
        map<String,Schema.Describefieldresult> quoteFieldResult =helperInstance.describeOjectfields('VCG_CPQ_Quote__c');
        list<VCG_CPQ_Opportunity_Quote_Map__c> opptyquoteMapList = new list<VCG_CPQ_Opportunity_Quote_Map__c>();
        VCG_CPQ_Opportunity_Quote_Map__c tempOpptyquoteMap;
        //
        //list of writable fields of opportunity
        //
        list<Schema.Describefieldresult> opptyWriatableFields = new list<Schema.Describefieldresult>();
        
        //list of writable fields of quote
        list<Schema.Describefieldresult> quoteWriatableFields = new list<Schema.Describefieldresult>();
        
        //
        set<String> mappeOpptyFields = new set<String>();
        
        //
        set<String> mappedQuoteFields= new set<String>();
        //get all writable fileds of opportunity
        //
        for(Schema.Describefieldresult opptyfiled : opptyFieldResult.values()){
            if(opptyfiled.isCreateable() ||(opptyfiled.isCreateable() && opptyfiled.isNameField()))
            opptyWriatableFields.add(opptyfiled);
        }
        //
        //get all writable fileds of Quote
        //
        for(Schema.Describefieldresult quoteField: quoteFieldResult.values()){
            if(quoteField.isCreateable() ||(quoteField.isCreateable() && quoteField.isNameField()))
            quoteWriatableFields.add(quoteField);
        }
        
        opptyquoteMapList.add(new VCG_CPQ_Opportunity_Quote_Map__c(Active__c = True
                                                                  ,Source__c = 'Id'
                                                                  ,Quote_Field__c = 'Opportunity__c'
                                                                  ,Source_Type__c = 'Object'));
        opptyquoteMapList.add(new VCG_CPQ_Opportunity_Quote_Map__c(Active__c = True
                                                                  ,Source__c = 'AccountId'
                                                                  ,Quote_Field__c = 'Account__c'
                                                                  ,Source_Type__c = 'Object'));
                        
        for(Schema.Describefieldresult opptyfiled : opptyWriatableFields){
            tempOpptyquoteMap = new VCG_CPQ_Opportunity_Quote_Map__c();
            tempOpptyquoteMap.Active__c = true;
            String datatype = opptyfiled.getSoapType().name();
            for(Schema.Describefieldresult quoteField: quoteWriatableFields){
                
                if(datatype == quoteField.getSoapType().name() && !mappeOpptyFields.contains(opptyfiled.getName())
                        &&!mappedQuoteFields.contains(quoteField.getName()))
                {
                    if(datatype == 'Id' && opptyfiled.getSoapType().name() == 'Id' 
                            &&opptyfiled.getReferenceTo()[0] == quoteField.getReferenceTo()[0])
                    {
                        
                        tempOpptyquoteMap.Source__c = opptyfiled.getName();
                        tempOpptyquoteMap.Quote_Field__c = quoteField.getName();
                        tempOpptyquoteMap.Source_Type__c = 'Object';
                        system.debug('*****id matching' + tempOpptyquoteMap );
                        mappeOpptyFields.add(opptyfiled.getName());
                        mappedQuoteFields.add(quoteField.getName());
                        
                    }
                    else if(datatype != 'Id' && opptyfiled.getSoapType().name() != 'Id') {                                              
                        
                        tempOpptyquoteMap.Source__c = opptyfiled.getName();
                        tempOpptyquoteMap.Quote_Field__c = quoteField.getName();
                        tempOpptyquoteMap.Source_Type__c = 'Object';
                        system.debug('********tempoppty' + tempOpptyquoteMap );
                        mappeOpptyFields.add(opptyfiled.getName());
                        mappedQuoteFields.add(quoteField.getName());
                    }
                }
            }
            
            try{
                if(tempOpptyquoteMap.Source__c != ''&& tempOpptyquoteMap.Source__c != null
                        && tempOpptyquoteMap.Quote_Field__c != '' && tempOpptyquoteMap.Quote_Field__c != null)
                opptyquoteMapList.add(tempOpptyquoteMap);
                
            }
            catch(Exception e){
                system.debug('**exceptionmessage' + e.getMessage());
                
            }
        }
        if(opptyquoteMapList !=null && !opptyquoteMapList.isEmpty()){
            insert opptyquoteMapList;
        }
    }
    
    /**********************************************************************************************
     * @author  vishal Shanbhag       
     * @date     1.April.2014    
     * @description:   Uitility method to setup VCG_CPQ_Opportunity_Quote_Map__c data (Formula type)
     *
     * @Revision(s):  
     **********************************************************************************************/    
/*  public void setupOpptyQuoteMapData2(){
        
        VCG_CPQ_HelperTestClass helperInstance = new VCG_CPQ_HelperTestClass();
        //
        //to get the describeFields of opportunity and quote
        map<String,Schema.Describefieldresult> opptyFieldResult =helperInstance.describeOjectfields('Opportunity');
        map<String,Schema.Describefieldresult> quoteFieldResult =helperInstance.describeOjectfields('VCG_CPQ_Quote__c');
        list<VCG_CPQ_Opportunity_Quote_Map__c> opptyquoteMapList = new list<VCG_CPQ_Opportunity_Quote_Map__c>();
        VCG_CPQ_Opportunity_Quote_Map__c tempOpptyquoteMap;
        //
        //list of writable fields of opportunity
        list<Schema.Describefieldresult> opptyWriatableFields = new list<Schema.Describefieldresult>();
        //list of writable fields of quote
        list<Schema.Describefieldresult> quoteWriatableFields = new list<Schema.Describefieldresult>();
        //
        set<String> mappeOpptyFields = new set<String>();
        //
        set<String> mappedQuoteFields= new set<String>();
        //
        set<String> datatypeSet = new set<String>();
        //get all writable fileds of opportunity
        //
        for(Schema.Describefieldresult opptyfiled : opptyFieldResult.values()){
            if(opptyfiled.isCreateable() ||(opptyfiled.isCreateable() && opptyfiled.isNameField()))
            opptyWriatableFields.add(opptyfiled);
        }
        //
        //get all writable fileds of Quote
        //
        for(Schema.Describefieldresult quoteField: quoteFieldResult.values()){
            if(quoteField.isCreateable() ||(quoteField.isCreateable() && quoteField.isNameField()))
            quoteWriatableFields.add(quoteField);
        }
        
        for(Schema.Describefieldresult opptyfiled : opptyWriatableFields){
            tempOpptyquoteMap = new VCG_CPQ_Opportunity_Quote_Map__c();
            tempOpptyquoteMap.Active__c = true;
            String datatype = opptyfiled.getSoapType().name();
            for(Schema.Describefieldresult quoteField: quoteWriatableFields){
                
                if(!mappeOpptyFields.contains(opptyfiled.getName())&&!mappedQuoteFields.contains(quoteField.getName())){
                    if(datatype=='String' && quoteField.getSoapType().name() == 'String' && !datatypeSet.contains('String')){
                        tempOpptyquoteMap = new VCG_CPQ_Opportunity_Quote_Map__c();                                             
                        tempOpptyquoteMap.Source__c = '"\'Pending\'"';
                        tempOpptyquoteMap.Quote_Field__c = quoteField.getName();
                        tempOpptyquoteMap.Source_Type__c = 'Formula';
                        system.debug('********tempoppty' + tempOpptyquoteMap );
                        mappeOpptyFields.add(opptyfiled.getName());
                        mappedQuoteFields.add(quoteField.getName());
                        datatypeSet.add('String');
                    }
                    if(datatype=='Id' && quoteField.getSoapType().name() == 'Id' && !datatypeSet.contains('Id')){
                        tempOpptyquoteMap = new VCG_CPQ_Opportunity_Quote_Map__c();                                             
                        tempOpptyquoteMap.Source__c = '"$User.Id"';
                        tempOpptyquoteMap.Quote_Field__c = quoteField.getName();
                        tempOpptyquoteMap.Source_Type__c = 'Formula';
                        system.debug('********tempoppty' + tempOpptyquoteMap );
                        mappeOpptyFields.add(opptyfiled.getName());
                        mappedQuoteFields.add(quoteField.getName());
                        datatypeSet.add('Id');
                    }
                    if(datatype=='Date' && quoteField.getSoapType().name() == 'Date' && !datatypeSet.contains('Date') ){
                        tempOpptyquoteMap = new VCG_CPQ_Opportunity_Quote_Map__c();                                             
                        tempOpptyquoteMap.Source__c = '{"op":"TODAY"}';
                        tempOpptyquoteMap.Quote_Field__c = quoteField.getName();
                        tempOpptyquoteMap.Source_Type__c = 'Formula';
                        system.debug('********tempoppty formula type' + tempOpptyquoteMap );
                        mappeOpptyFields.add(opptyfiled.getName());
                        mappedQuoteFields.add(quoteField.getName());
                        datatypeSet.add('Date');
                    }
                }
            }
            
            try{
                if(tempOpptyquoteMap.Source__c != ''&& tempOpptyquoteMap.Source__c != null
                        && tempOpptyquoteMap.Quote_Field__c != '' && tempOpptyquoteMap.Quote_Field__c != null)
                opptyquoteMapList.add(tempOpptyquoteMap);
                system.debug('***********opptyquoteMapList formula type**'+opptyquoteMapList);
            }
            catch(Exception e){
                system.debug('**exceptionmessage' + e.getMessage());
                
            }
        }
        if(opptyquoteMapList !=null && !opptyquoteMapList.isEmpty()){
            insert opptyquoteMapList;
        }
    }
    
    /**********************************************************************************************
     * @author  vishal Shanbhag       
     * @date     1.April.2014    
     * @description:   Uitility method to setup VCG_CPQ_Quote_Product_Oppty_Product_Map__c data (Formula type)
     *
     * @Revision(s):  
     **********************************************************************************************/ 
/*    public void setupOpptyProdQuoteProdMapData(){
        VCG_CPQ_HelperTestClass helperInstance = new VCG_CPQ_HelperTestClass();
        //
        //to get all the fields of OLI and QuoteProd
        map<String,Schema.Describefieldresult> opptyLineFieldResult =helperInstance.describeOjectfields('OpportunityLineItem');
        map<String,Schema.Describefieldresult> quoteProductFieldResult =helperInstance.describeOjectfields('VCG_CPQ_Quote_Product__c');
        
        //get all the writable fields of opportunity line items
        list<Schema.Describefieldresult> opptyProdWritableFields = new list<Schema.Describefieldresult>();
        //get all the writable fields of quote product items
        list<Schema.Describefieldresult> quoteProdWritableFields = new list<Schema.Describefieldresult>();
        
        for(Schema.Describefieldresult opptyprod : opptyLineFieldResult.values()){
            if(opptyprod.isCreateable() ||(opptyprod.isCreateable() && opptyprod.isNameField()))
            opptyProdWritableFields.add(opptyprod);
        } 
        
        for(Schema.Describefieldresult quoteprod : quoteProductFieldResult.values()){
            if(quoteprod.isCreateable() ||(quoteprod.isCreateable() && quoteprod.isNameField()))
            quoteProdWritableFields.add(quoteprod);
        } 
        //
        set<String> mappeOpptyProdFields = new set<String>();
        //
        set<String> mappedQuoteProdFields= new set<String>();
        //temporary VCG_CPQ_Quote_Product_Oppty_Product_Map__c record
        VCG_CPQ_Quote_Product_Oppty_Product_Map__c tempQuoteProdOpptyProdMap;
        //
        list<VCG_CPQ_Quote_Product_Oppty_Product_Map__c> QuoteProdOpptyProdMapList = new list<VCG_CPQ_Quote_Product_Oppty_Product_Map__c>();
        
        for(Schema.Describefieldresult opptyprod :opptyProdWritableFields){
            tempQuoteProdOpptyProdMap = new VCG_CPQ_Quote_Product_Oppty_Product_Map__c();
            tempQuoteProdOpptyProdMap.Active__c = true;
            for(Schema.Describefieldresult quoteprod : quoteProdWritableFields){
                if(opptyprod.getSoapType().name() == quoteprod.getSoapType().name() 
                        && !mappeOpptyProdFields.contains(opptyprod.getName()) && !mappedQuoteProdFields.contains(quoteprod.getName())){
                    if(opptyprod.getSoapType().name() == 'Id' && quoteprod.getSoapType().name() == 'Id' 
                            && opptyprod.getReferenceTo()[0] == quoteprod.getReferenceTo()[0]){
                        
                        tempQuoteProdOpptyProdMap.Opportunity_Product_Field__c = opptyprod.getName();
                        tempQuoteProdOpptyProdMap.Quote_Product_Field__c = quoteprod.getName();
                        system.debug('*****id matching' + tempQuoteProdOpptyProdMap );
                        mappeOpptyProdFields.add(opptyprod.getName());
                        mappedQuoteProdFields.add(quoteprod.getName());
                        
                    }
                    else if(opptyprod.getSoapType().name() != 'Id' && quoteprod.getSoapType().name() != 'Id') {                                             
                        
                        tempQuoteProdOpptyProdMap.Opportunity_Product_Field__c = opptyprod.getName();
                        tempQuoteProdOpptyProdMap.Quote_Product_Field__c = quoteprod.getName();
                        
                        system.debug('********tempoppty' + tempQuoteProdOpptyProdMap );
                        mappeOpptyProdFields.add(opptyprod.getName());
                        mappedQuoteProdFields.add(quoteprod.getName());
                    }
                }
            }
            if(tempQuoteProdOpptyProdMap.Opportunity_Product_Field__c !=null && tempQuoteProdOpptyProdMap.Opportunity_Product_Field__c !=''
                    && tempQuoteProdOpptyProdMap.Quote_Product_Field__c !=null && tempQuoteProdOpptyProdMap.Quote_Product_Field__c != '')
            QuoteProdOpptyProdMapList.add(tempQuoteProdOpptyProdMap);
            system.debug('****test QuoteProdOpptyProdMapList* ' + QuoteProdOpptyProdMapList);
            
        }
        if(QuoteProdOpptyProdMapList.size() >0)
        insert QuoteProdOpptyProdMapList;
    }
    
    /**********************************************************************************************
     * @author  vishal Shanbhag       
     * @date     1.April.2014    
     * @description:   Uitility method to setup VCG_CPQ_Quote_Opportunity_Map__c data (Formula type)
     *
     * @Revision(s):  
     **********************************************************************************************/ 
/*    public void setupQuoteOpptyData(){
        VCG_CPQ_HelperTestClass helperInstance = new VCG_CPQ_HelperTestClass();
        //
        //to get the describeFields of opportunity and quote
        map<String,Schema.Describefieldresult> opptyFieldResult =helperInstance.describeOjectfields('Opportunity');
        map<String,Schema.Describefieldresult> quoteFieldResult =helperInstance.describeOjectfields('VCG_CPQ_Quote__c');
        list<VCG_CPQ_Quote_Opportunity_Map__c> opptyquoteMapList = new list<VCG_CPQ_Quote_Opportunity_Map__c>();
        VCG_CPQ_Quote_Opportunity_Map__c tempOpptyquoteMap;
        //
        //list of writable fields of opportunity
        list<Schema.Describefieldresult> opptyWriatableFields = new list<Schema.Describefieldresult>();
        //list of writable fields of quote
        list<Schema.Describefieldresult> quoteWriatableFields = new list<Schema.Describefieldresult>();
        //
        set<String> mappeOpptyFields = new set<String>();
        //
        set<String> mappedQuoteFields= new set<String>();
        //get all writable fileds of opportunity
        //
        for(Schema.Describefieldresult opptyfiled : opptyFieldResult.values()){
            if(opptyfiled.isCreateable() ||(opptyfiled.isCreateable() && opptyfiled.isNameField()))
            opptyWriatableFields.add(opptyfiled);
        }
        //
        //get all writable fileds of Quote
        //
        for(Schema.Describefieldresult quoteField: quoteFieldResult.values()){
            if(quoteField.isCreateable() ||(quoteField.isCreateable() && quoteField.isNameField()))
            quoteWriatableFields.add(quoteField);
        }
        
        for(Schema.Describefieldresult opptyfiled : opptyWriatableFields){
            tempOpptyquoteMap = new VCG_CPQ_Quote_Opportunity_Map__c();
            tempOpptyquoteMap.Active__c = true;
            
            String datatype = opptyfiled.getSoapType().name();
            for(Schema.Describefieldresult quoteField: quoteWriatableFields){
                
                if(datatype == quoteField.getSoapType().name() && !mappeOpptyFields.contains(opptyfiled.getName())
                        &&!mappedQuoteFields.contains(quoteField.getName())
                        && datatype !='Id' && quoteField.getSoapType().name() != 'Id'){
                    
                    if(datatype == 'Id' && opptyfiled.getSoapType().name() == 'Id' 
                            && opptyfiled.getReferenceTo()[0] == quoteField.getReferenceTo()[0]){
                        
                        tempOpptyquoteMap.Opportunity_Field__c = opptyfiled.getName();
                        tempOpptyquoteMap.Quote_Field__c = quoteField.getName();
                        mappeOpptyFields.add(opptyfiled.getName());
                        mappedQuoteFields.add(quoteField.getName());
                        
                    }
                    else if(datatype != 'Id' && opptyfiled.getSoapType().name() != 'Id') {                                              
                        
                        tempOpptyquoteMap.Opportunity_Field__c = opptyfiled.getName();
                        tempOpptyquoteMap.Quote_Field__c = quoteField.getName();
                        
                        system.debug('********tempoppty' + tempOpptyquoteMap );
                        mappeOpptyFields.add(opptyfiled.getName());
                        mappedQuoteFields.add(quoteField.getName());
                    }
                }
                
            }
            
            try{
                if(tempOpptyquoteMap.Opportunity_Field__c != ''&& tempOpptyquoteMap.Opportunity_Field__c != null
                        && tempOpptyquoteMap.Quote_Field__c != '' && tempOpptyquoteMap.Quote_Field__c != null)
                opptyquoteMapList.add(tempOpptyquoteMap);
                system.debug('***********opptyquoteMapList**'+opptyquoteMapList);
            }
            catch(Exception e){
                system.debug('**exceptionmessage' + e.getMessage());
                
            }
        }
        if(opptyquoteMapList !=null && !opptyquoteMapList.isEmpty()){
            insert opptyquoteMapList;
        }
        
    }
    
    
    /**
     * @description  Test getProductFilter()
     *
     * @author  Lawrence Coffin <lawrence.coffin@cloudsherpas.com>
     * @since   3.Jun.2014
     */
    static testMethod void testGetProductFilter(){
        //
        // Set up related records - account, opp, etc.
        //
        Account a = new Account( Name = 'Test Account' );
        a.BillingCountry = 'United Kingdom';
        insert a;
        //Added RecordType and StageName ='Sales Acceptance' by JBarrameda - 10/30/2014
        Id oldProdRecType = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Products, Services and Maintenance').getRecordTypeId();
        
        Opportunity o = new Opportunity (
                                            Name = 'Test Opp',
                                            AccountId = a.Id,
                                            //StageName = 'Quoting',
                                            CloseDate = Date.today().addDays(30),
                                            Description = 'United Kingdom',
                                            RecordTypeId = oldProdRecType,
                                            StageName = 'Sales Acceptance'
                                        );
        insert o;
        
        //
        // Add a base/default Product Filter rule
        //
        insert new VCG_CPQ_Product_Filter__c (
                                                IsActive__c = TRUE,
                                                Formula__c = '1', // Result is a boolean TRUE (decimal "1")
                                                Product_Where_Clause__c = 'FieldA__c = TRUE', // we won't be running the query, so just use a dummy where clause
                                                Sequence__c = 999 // A large sequence number so it is always evaluated last
                                             );
        //
        // Build quote (in memory only)
        //
        VCG_CPQ_Quote__c quote = new VCG_CPQ_Quote__c( Opportunity__c = o.Id, Account__c = a.Id );
        
        
        //
        // Confirm we get the default filter
        //
        //System.assertEquals('FieldA__c = TRUE', VCG_CPQ_QuoteController.getProductFilter(quote));//Abhishek Commented
        
        //
        // Add in a more specific rule -- BillingCountry == 'United Kingdom' -- tests references to related objects
        //
        insert new VCG_CPQ_Product_Filter__c (
                                                IsActive__c = TRUE,
                                                Formula__c = '{"p1":"Account__r.BillingCountry","op":"==","p2":"\'United Kingdom\'"}',
                                                Product_Where_Clause__c = 'FieldB__c = TRUE',
                                                Needs_Fields__c = 'Account__r.BillingCountry',
                                                Sequence__c = 800
                                             );
        // Confirm we get the new filter
        //System.assertEquals('FieldB__c = TRUE', VCG_CPQ_QuoteController.getProductFilter(quote));//Abhishek Commented
        
        
        //
        // Add in another more specific rule, tests multiple Needs_Fields
        //
        insert new VCG_CPQ_Product_Filter__c (
                                                IsActive__c = TRUE,
                                                Formula__c = '{"p1":"Account__r.BillingCountry","op":"==","p2":"Opportunity__r.Description"}',
                                                Product_Where_Clause__c = 'FieldC__c = TRUE',
                                                Needs_Fields__c = 'Account__r.BillingCountry;Opportunity__r.Description',
                                                Sequence__c = 700
                                             );
        // Confirm we get the new filter
        //System.assertEquals('FieldC__c = TRUE', VCG_CPQ_QuoteController.getProductFilter(quote));//Abhishek Commented
        
        //
        // Add in another rule, this one tests Needs_Fields with multiple levels (i.e. Opp.Account.BillingCountry)
        //
        insert new VCG_CPQ_Product_Filter__c (
                                                IsActive__c = TRUE,
                                                Formula__c = '{"p1":"Opportunity__r.Account.BillingCountry","op":"==","p2":"\'United Kingdom\'"}',
                                                Product_Where_Clause__c = 'FieldD__c = TRUE',
                                                Needs_Fields__c = 'Opportunity__r.Account.BillingCountry',
                                                Sequence__c = 600
                                             );
        // Confirm we get the new filter
        //System.assertEquals('FieldD__c = TRUE', VCG_CPQ_QuoteController.getProductFilter(quote));//Abhishek Commented
        
        //
        // Now, change the value that all the specific rules above are dependent on
        //
        a.BillingCountry = 'United States';
        update a;
        
        // Confirm that we get the default filter again
        //System.assertEquals('FieldA__c = TRUE', VCG_CPQ_QuoteController.getProductFilter(quote));//Abhishek Commented
    }
    
    
    // Localized VCG_CPQ_Formula.F() methods to make them easier to call
    static String F(String op, Object p1) { return VCG_CPQ_Formula.F(op, p1); }
    static String F(String op, Object p1, Object p2) { return VCG_CPQ_Formula.F(op, p1, p2); }
    static String F(String op, Object p1, Object p2, Object p3) { return VCG_CPQ_Formula.F(op, p1, p2, p3); }
    static String F(String op, Object p1, Object p2, Object p3, Object p4) { return VCG_CPQ_Formula.F(op, p1, p2, p3, p4); }
    static String F(String op, Object p1, Object p2, Object p3, Object p4, Object p5) { return VCG_CPQ_Formula.F(op, p1, p2, p3, p4, p5); }
}