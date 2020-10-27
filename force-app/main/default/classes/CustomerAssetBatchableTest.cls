/**
 * Created by OzerEvin on 04/07/2017.
 */
@isTest
public with sharing class CustomerAssetBatchableTest {
    public static VistaAssetHelperUtil util = new VistaAssetHelperUtil();

    @isTest
    public static void executeCustomerAssetBatchableTest() {
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
        List<SBQQ__Subscription__c> subscriptionList = util.createSubscriptions(sbQuoteLines, contract, account, null);

        Test.startTest();
        CustomerAssetBatchable customerAssetBatchable = new CustomerAssetBatchable(false);
        Database.executeBatch(customerAssetBatchable, 1000);
        Test.stopTest();
    }

    private static List<Customer_Asset__c> getExistingCustomerAssets() {
        List<Customer_Asset__c> extendedAssetList = [
                SELECT Id,
                        Account__c,
                        MSA_Document__c,
                        Product_Schedule_Document__c,
                        Eval_Document__c,
                        Eval2_Document__c,
                        Latest_Opportunity__r.Order_Type__c,
                        Latest_Opportunity__r.Order_Sub_Type__c,
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
                        Latest_Quote_Line__r.SBQQ__Quote__r.Id,
                        Latest_Quote_Line__r.SBQQ__Group__c,
                        Contract__c,
                        Steelbrick_Asset__c,
                        Steelbrick_Asset__r.Id
                FROM Customer_Asset__c
                LIMIT 1000
        ];

        return extendedAssetList;
    }
}