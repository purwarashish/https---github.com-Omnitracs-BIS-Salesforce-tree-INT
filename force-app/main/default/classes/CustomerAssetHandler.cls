/**
 * Created by CrutchfieldJody on 11/30/2016.
 */

public with sharing class CustomerAssetHandler {

    /////// Added by ARMAN: 
    public static final String CLOSED_WON = 'Closed Won';

    // Following piece code is added by Abhishek to stop the recursive logic as per case- #01820444
   
    private static boolean runBefore = true;
    private static boolean runAfter = true;

    public static boolean runOnceBefore(){
        if(runBefore){
            runBefore = false;
            return true;
        }
        else{
            return runBefore ;
        }
    }
    
    public static boolean runOnceAfter(){
        if(runAfter){
            runAfter = false;
            return true;
        }
        else{
            return runAfter ;
        }
    }
    ////////////////// END of Arman's changes ////////


    public with sharing class DebugException extends Exception {

    }

    public static boolean debug = false;
    public static boolean bypassTrigger = false;

    private static String SYLECTUS_PRODUCT_SCHEDULE_KEY =
            'SylectusScheduleOmnitracs Canada, Inc.Active';

    private static Set<String> CONTRACT_FILTER_KEYS = new Set<String>{
            'MasterClick ThroughMasterOmnitracs, LLCActive',
            'MasterLegacyMasterOmnitracs, LLCActive',
            'MasterEULAMasterRoadnet Technologies, Inc.Active',
            'MasterLSAMasterRoadnet Technologies, Inc.Active',
            'MasterSAASMasterRoadnet Technologies, Inc.Active',
            'MasterTelematicsMasterRoadnet Technologies, Inc.Active',
            'MCP50ProductionEmbedded ClauseOmnitracs, LLCActive',
            'MCP50ProductionAttached AgreementOmnitracs, LLCActive',
            'MCP100SProductionEmbedded ClauseOmnitracs, LLCActive',
            'MCP100SProductionAttached AgreementOmnitracs, LLCActive',
            'MCP100TProductionEmbedded ClauseOmnitracs, LLCActive',
            'MCP100TProductionAttached AgreementOmnitracs, LLCActive',
            'MCP110ProductionEmbedded ClauseOmnitracs, LLCActive',
            'MCP110ProductionAttached AgreementOmnitracs, LLCActive',
            'MCP200ProductionEmbedded ClauseOmnitracs, LLCActive',
            'MCP200ProductionAttached AgreementOmnitracs, LLCActive',
            'IVGProductionEmbedded ClauseOmnitracs, LLCActive',
            'IVGProductionAttached AgreementOmnitracs, LLCActive',
            'Untethered Asset ManagementProductionAttached AgreementOmnitracs, LLCActive',
            'TT210ProductionAttached AgreementOmnitracs, LLCActive',
            'TT150ProductionAttached AgreementOmnitracs, LLCActive'
    };

    public static void relateToSpringCMContracts(List<Customer_Asset__c> assetList) {
        //++ [08/08/2017]: Enabled, approval from J granted.
        //+ [06/27/2017]: Disabling. Pending feedback from J Filio.
//        return;
        //- [06/27/2017]: Disabling. Pending feedback from J Filio.
        //-- [08/08/2017]: Enabled, approval from J granted.
        List<Id> filterAssetIdList = new List<Id>();
        List<Id> assetIdList = new List<Id>();

        //- Filter out Customer Assets that would otherwise be reassigned to other SpringCM Contract records.
        Integer i = 0;
        if (debug) System.debug('Started filtering Customer Assets based on criteria...');
        while (i < assetList.size())
        {
            boolean assetNotFiltered = true;
            Customer_Asset__c asset = assetList.get(i);
            if (String.isNotBlank(asset.Latest_Quote_Line__r.SBQQ__Product__r.Output_MSA_Document_Template__c)) {
                if (CONTRACT_FILTER_KEYS.contains(getQuoteLineProductContractTemplateKey(asset.Latest_Quote_Line__r.SBQQ__Product__r.Output_MSA_Document_Template__r, null))) {
                    assetList.remove(i);
                    assetNotFiltered = false;
                }
            }
            else if (String.isNotBlank(asset.Latest_Quote_Line__r.SBQQ__Product__r.Output_Schedule_Document_Template__c)) {
                if (CONTRACT_FILTER_KEYS.contains(getQuoteLineProductContractTemplateKey(asset.Latest_Quote_Line__r.SBQQ__Product__r.Output_Schedule_Document_Template__r, null))) {
                    assetList.remove(i);
                    assetNotFiltered = false;
                }
            }
            else if (String.isNotBlank(asset.Latest_Quote_Line__r.SBQQ__Product__r.Output_Eval_Document_Template__c)) {
                if (CONTRACT_FILTER_KEYS.contains(getQuoteLineProductContractTemplateKey(asset.Latest_Quote_Line__r.SBQQ__Product__r.Output_Eval_Document_Template__r, null))) {
                    assetList.remove(i);
                    assetNotFiltered = false;
                }
            }
            else if (String.isNotBlank(asset.Latest_Quote_Line__r.SBQQ__Product__r.Output_Eval2_Document_Template__c)) {
                if (CONTRACT_FILTER_KEYS.contains(getQuoteLineProductContractTemplateKey(asset.Latest_Quote_Line__r.SBQQ__Product__r.Output_Eval2_Document_Template__r, null))) {
                    assetList.remove(i);
                    assetNotFiltered = false;
                }
            }

            if (assetNotFiltered)
            {
                assetIdList.add(asset.Id);
                i++;
            }
        }
        if (debug) System.debug('Finished filtering.');
        //- Filter out Customer Assets that would otherwise be reassigned to other SpringCM Contract records.

        if (debug) System.debug('Querying Customer Assets...');
        List<Customer_Asset__c> extendedAssetList = [
                SELECT Id,
                        Account__c,
                        MSA_Document__c,
                        Product_Schedule_Document__c,
                        Product_Schedule_Document__r.CreatedDate,
                        Eval_Document__c,
                        Eval2_Document__c,
                        Latest_Opportunity__r.Order_Type__c,
                        Latest_Opportunity__r.Order_Sub_Type__c,
                        Latest_Quote_Line__r.Id,
                        Latest_Quote_Line__r.Product_Type__c,
                        Latest_Quote_Line__r.SBQQ__RequiredBy__c,
                        Latest_Quote_Line__r.SBQQ__RequiredBy__r.SBQQ__ProductCode__c,
                        Latest_Quote_Line__r.SBQQ__Product__r.Id,
                        Latest_Quote_Line__r.SBQQ__Product__r.Output_MSA_Document_Template__c,
                        Latest_Quote_Line__r.SBQQ__Product__r.Output_MSA_Document_Template__r.Contract_Category_1__c,
                        Latest_Quote_Line__r.SBQQ__Product__r.Output_MSA_Document_Template__r.Contract_Category_2__c,
                        Latest_Quote_Line__r.SBQQ__Product__r.Output_MSA_Document_Template__r.Agreement_Type__c,
                        Latest_Quote_Line__r.SBQQ__Product__r.Output_MSA_Document_Template__r.Legal_Entity_Name__c,
                        Latest_Quote_Line__r.SBQQ__Product__r.Output_MSA_Document_Template__r.Status__c,
                        Latest_Quote_Line__r.SBQQ__Product__r.Output_Schedule_Document_Template__c,
                        Latest_Quote_Line__r.SBQQ__Product__r.Output_Schedule_Document_Template__r.Contract_Category_1__c,
                        Latest_Quote_Line__r.SBQQ__Product__r.Output_Schedule_Document_Template__r.Contract_Category_2__c,
                        Latest_Quote_Line__r.SBQQ__Product__r.Output_Schedule_Document_Template__r.Agreement_Type__c,
                        Latest_Quote_Line__r.SBQQ__Product__r.Output_Schedule_Document_Template__r.Legal_Entity_Name__c,
                        Latest_Quote_Line__r.SBQQ__Product__r.Output_Schedule_Document_Template__r.Status__c,
                        Latest_Quote_Line__r.SBQQ__Product__r.Output_Eval_Document_Template__c,
                        Latest_Quote_Line__r.SBQQ__Product__r.Output_Eval_Document_Template__r.Contract_Category_1__c,
                        Latest_Quote_Line__r.SBQQ__Product__r.Output_Eval_Document_Template__r.Contract_Category_2__c,
                        Latest_Quote_Line__r.SBQQ__Product__r.Output_Eval_Document_Template__r.Agreement_Type__c,
                        Latest_Quote_Line__r.SBQQ__Product__r.Output_Eval_Document_Template__r.Legal_Entity_Name__c,
                        Latest_Quote_Line__r.SBQQ__Product__r.Output_Eval_Document_Template__r.Status__c,
                        Latest_Quote_Line__r.SBQQ__Product__r.Output_Eval2_Document_Template__c,
                        Latest_Quote_Line__r.SBQQ__Product__r.Output_Eval2_Document_Template__r.Contract_Category_1__c,
                        Latest_Quote_Line__r.SBQQ__Product__r.Output_Eval2_Document_Template__r.Contract_Category_2__c,
                        Latest_Quote_Line__r.SBQQ__Product__r.Output_Eval2_Document_Template__r.Agreement_Type__c,
                        Latest_Quote_Line__r.SBQQ__Product__r.Output_Eval2_Document_Template__r.Legal_Entity_Name__c,
                        Latest_Quote_Line__r.SBQQ__Product__r.Output_Eval2_Document_Template__r.Status__c,
                        Latest_Quote_Line__r.SBQQ__Quote__r.Id,
                        Latest_Quote_Line__r.SBQQ__Quote__r.SBQQ__Account__c
                FROM Customer_Asset__c
                WHERE Id IN :assetIdList
        ];
        if (debug) System.debug(extendedAssetList);
        if (debug) System.debug('Finished querying.');

        Map<Id,Map<String,List<Contract>>> assetsToTemplateContracts = new Map<Id,Map<String,List<Contract>>>();

        Set<Id> quoteIDs = new Set<Id>();
        Map<Id,Id> accountIDsToQuoteIDs = new Map<Id,Id>();
        Map<Id,Id> quoteIDsToAccountIDs = new Map<Id,Id>();
        for (Customer_Asset__c eAsset : extendedAssetList) {
            /*if (debug) System.debug('-- eAsset.Latest_Quote_Line__r.SBQQ__Quote__r.SBQQ__Account__c ='+
                    eAsset.Latest_Quote_Line__r.SBQQ__Quote__r.SBQQ__Account__c);
            if (debug) System.debug('-- eAsset.Latest_Quote_Line__r.SBQQ__Quote__r.Id ='+
                    eAsset.Latest_Quote_Line__r.SBQQ__Quote__r.Id); */
            accountIDsToQuoteIDs.put(eAsset.Latest_Quote_Line__r.SBQQ__Quote__r.SBQQ__Account__c, eAsset.Latest_Quote_Line__r.SBQQ__Quote__r.Id);
            quoteIDsToAccountIDs.put(eAsset.Latest_Quote_Line__r.SBQQ__Quote__r.Id, eAsset.Latest_Quote_Line__r.SBQQ__Quote__r.SBQQ__Account__c);
            quoteIDs.add(eAsset.Latest_Quote_Line__r.SBQQ__Quote__r.Id);
        }
        if (debug) System.debug('-- accountIDsToQuoteIDs = '+accountIDsToQuoteIDs);

        if (debug) System.debug('Retrieving getQuotesToProductIds...');
        Map<SBQQ__Quote__c,Set<Id>> QuotesToProductIds = getQuotesToProductIds(quoteIDs);
        if (debug) System.debug(QuotesToProductIds);
        if (debug) System.debug('Retrieved getQuotesToProductIds.');

        if (debug) System.debug('Retrieving getQuoteProductContracts...');
        Map<Id,List<Contract>> QuoteProductContracts = getQuoteProductContracts(accountIDsToQuoteIDs);
        if (debug) System.debug(QuoteProductContracts);
        if (debug) System.debug('Retrieved getQuoteProductContracts.');

        if (debug) System.debug('for (Customer_Asset__c eAsset : extendedAssetList) {');
        for (Customer_Asset__c eAsset : extendedAssetList) {
            if (assetsToTemplateContracts.get(eAsset.Id) == null) {
                assetsToTemplateContracts.put(eAsset.Id, new Map<String, List<Contract>>());
            }

            if (debug) System.debug('Retrieving QuoteLineProductContractTemplates...');
            if (eAsset.Latest_Quote_Line__r == null) { continue; }
            Map<String,Product_Contract_Template__c> QuoteLineProductContractTemplates = getQuoteLineProductContractTemplates(eAsset.Latest_Quote_Line__r);
            if (debug) System.debug(QuoteLineProductContractTemplates);
            if (debug) System.debug('Retrieved QuoteLineProductContractTemplates.');

            //+ Don't relate Customer Assets to contracts if none exist.
            if (!QuoteProductContracts.containsKey(eAsset.Latest_Quote_Line__r.SBQQ__Quote__r.Id)) {
                continue;
            }
            //- Don't relate Customer Assets to contracts if none exist.

            //+ Sylectus Product Schedule assignments.
            Product_Contract_Template__c outputSchedule = QuoteLineProductContractTemplates.get('Output_Schedule_Document_Template__r');
            //if (debug) System.debug('if (outputSchedule != null) {');
            if (outputSchedule != null) {
                if (debug) System.debug('Retrieving outputSchedule_key...');
                String outputSchedule_key = getQuoteLineProductContractTemplateKey(outputSchedule, new Set<String>{ 'Contract_Category_2__c' });
                if (debug) System.debug(outputSchedule_key);
                if (debug) System.debug('Retrieved outputSchedule_key.');

                if (debug) System.debug('outputSchedule_key == SYLECTUS_PRODUCT_SCHEDULE_KEY: '+(outputSchedule_key == SYLECTUS_PRODUCT_SCHEDULE_KEY));
                if (debug) System.debug(outputSchedule_key);
                if (debug) System.debug(SYLECTUS_PRODUCT_SCHEDULE_KEY);
                if (outputSchedule_key == SYLECTUS_PRODUCT_SCHEDULE_KEY) {
                    boolean isSylectusPSMapped = false;
                    for (SBQQ__Quote__c quote : QuotesToProductIds.keySet()) {
                        if (isSylectusPSMapped) {
                            break;
                        }

                        //+ Don't consider Quotes that are not owned by the same Account as the Customer Asset.
                        if (quoteIDsToAccountIDs.get(quote.Id) != eAsset.Account__c) {
                            continue;
                        }
                        //- Don't consider Quotes that are not owned by the same Account as the Customer Asset.

                        //+ Don't attempt to relate a Sylectus Customer Asset to a contract that's not related to a Quote.
                        if (!QuoteProductContracts.keySet().contains(quote.Id)) {
                            continue;
                        }
                        //- Don't attempt to relate a Sylectus Customer Asset to a contract that's not related to a Quote.

                        Set<Id> quoteProducts = QuotesToProductIds.get(quote);

                        //:: Check to see if eAsset.SylectusProductId in QuoteIdsToProductIds[QuoteId]
                        if (!quoteProducts.contains(eAsset.Latest_Quote_Line__r.SBQQ__Product__r.Id)) {
                            continue;
                        }
                        //::: ! -> continue

                        //:: Check to see if eAsset has been assigned a PS
                        if (String.isNotBlank(eAsset.Product_Schedule_Document__c)) {
                            //:: Check to see if eAsset.PS.CreatedDate < QuoteIdsToProductSchedule[QuoteId].CreatedDate
                            for (Contract quoteContract : QuoteProductContracts.get(quote.Id)) {
                                String QuoteProductContract_key = getQuoteProductContractKey(quoteContract, new Set<String>{ 'Contract_Category_2__c' });
                                if (QuoteProductContract_key == SYLECTUS_PRODUCT_SCHEDULE_KEY) {
                                    if (quoteContract.CreatedDate > eAsset.Product_Schedule_Document__r.CreatedDate) {
                                        eAsset.Product_Schedule_Document__c = quoteContract.Id;
                                        isSylectusPSMapped = true;
//                                        break;
                                    }
                                }
                            }
                        } else {
                            //::: ! -> eAsset.PS = QuoteIdsToProductSchedule[QuoteId];
                            for (Contract quoteContract : QuoteProductContracts.get(quote.Id)) {
                                String QuoteProductContract_key = getQuoteProductContractKey(quoteContract, new Set<String>{ 'Contract_Category_2__c' });
                                if (QuoteProductContract_key == SYLECTUS_PRODUCT_SCHEDULE_KEY) {
                                    eAsset.Product_Schedule_Document__c = quoteContract.Id;
                                    isSylectusPSMapped = true;
                                    break;
                                }
                            }
                        }
                    }
                }
            }
            //if (debug) System.debug('}');
            //- Sylectus Product Schedule assignments.

            for (String TemplateType : QuoteLineProductContractTemplates.keySet()) {
                if (assetsToTemplateContracts.get(eAsset.Id).get(TemplateType) == null) {
                    assetsToTemplateContracts.get(eAsset.Id).put(TemplateType, new List<Contract>());
                }

                Product_Contract_Template__c QuoteLineProductContractTemplate = QuoteLineProductContractTemplates.get(TemplateType);
                String QuoteLineProductContractTemplate_key = getQuoteLineProductContractTemplateKey(QuoteLineProductContractTemplate, null);

                for (Contract QuoteProductContract : QuoteProductContracts.get(eAsset.Latest_Quote_Line__r.SBQQ__Quote__r.Id)) {
                    String QuoteProductContract_key = getQuoteProductContractKey(QuoteProductContract, null);
                    if (QuoteLineProductContractTemplate_key == QuoteProductContract_key) {
                        //+ Keep track of the Contracts associated to an asset's template fields, and choose the newest one.
                        assetsToTemplateContracts.get(eAsset.Id).get(TemplateType).add(QuoteProductContract);
                        for (Contract oQuoteProductContract : assetsToTemplateContracts.get(eAsset.Id).get(TemplateType)) {
                            if (oQuoteProductContract.CreatedDate > QuoteProductContract.CreatedDate) {
                                QuoteProductContract = oQuoteProductContract;
                            }
                        }
                        //- Keep track of the Contracts associated to an asset's template fields, and choose the newest one.

                        if (TemplateType == 'Output_MSA_Document_Template__r') {
                            eAsset.MSA_Document__c = QuoteProductContract.Id;
                        }
                        else if (TemplateType == 'Output_Schedule_Document_Template__r') {
                            if (QuoteLineProductContractTemplate_key != SYLECTUS_PRODUCT_SCHEDULE_KEY) {
                                eAsset.Product_Schedule_Document__c = QuoteProductContract.Id;
                            }
                        }

                        if (eAsset.Latest_Opportunity__r.Order_Type__c == 'Eval') {
                            if ((eAsset.Latest_Opportunity__r.Order_Sub_Type__c == null) || (eAsset.Latest_Opportunity__r.Order_Sub_Type__c != 'XRS CMPP')) {
                                if (TemplateType == 'Output_Eval_Document_Template__r') {
                                    eAsset.Eval_Document__c = QuoteProductContract.Id;
                                }
                            }
                            else {
                                if (TemplateType == 'Output_Eval2_Document_Template__r') {
                                    eAsset.Eval2_Document__c = QuoteProductContract.Id;
                                }
                            }
                        }
                    }
                }
            }
        }
        //if (debug) System.debug('}');

        for (Customer_Asset__c tAsset : assetList) {
            boolean isBundledInMCP110 = (tAsset.Latest_Quote_Line__r.SBQQ__RequiredBy__r.SBQQ__ProductCode__c == 'MCP110-WR');
            boolean isBundledInMCP200 = (tAsset.Latest_Quote_Line__r.SBQQ__RequiredBy__r.SBQQ__ProductCode__c == 'MCP200-WR');
            boolean isHardwareProductType = (tAsset.Latest_Quote_Line__r.Product_Type__c == 'Hardware');

            //+ MCP110 and MCP200 hardware inherit the Product Schedule of their Service Plans.
            if ((isBundledInMCP110 || isBundledInMCP200) && (isHardwareProductType)) {
                System.debug('CONSIDERING an MCP bundled asset: '+tAsset);
                for (Customer_Asset__c eAsset : extendedAssetList) {
                    if (tAsset.Latest_Quote_Line__r.SBQQ__RequiredBy__c == eAsset.Latest_Quote_Line__r.SBQQ__RequiredBy__c) {
                        System.debug('Located co-bundled MCP asset: '+eAsset);
                        if (eAsset.Latest_Quote_Line__r.Product_Type__c == 'Software') {
                            System.debug('Inheriting from a co-bundled MCP Software asset; [Product_Schedule_Document__c]: '+eAsset.Product_Schedule_Document__c);
                            tAsset.Product_Schedule_Document__c = eAsset.Product_Schedule_Document__c;
                        }
                    }
                }
            }
            //- MCP110 and MCP200 hardware inherit the Product Schedule of their Service Plans.

            for (Customer_Asset__c eAsset : extendedAssetList) {
                if (tAsset.Id == eAsset.Id) {
                    tAsset.MSA_Document__c = eAsset.MSA_Document__c;

                    if (!((isBundledInMCP110 || isBundledInMCP200) && (isHardwareProductType))) {
                        tAsset.Product_Schedule_Document__c = eAsset.Product_Schedule_Document__c;
                    }

                    tAsset.Eval_Document__c = eAsset.Eval_Document__c;
                    tAsset.Eval2_Document__c = eAsset.Eval2_Document__c;
                }
            }
        }

        bypassTrigger = true;
        update assetList;
        bypassTrigger = false;
    }

    public static Map<SBQQ__Quote__c,Set<Id>> getQuotesToProductIds(Set<Id> quoteIDs) {

        List<SBQQ__Quote__c> quotes = [
                SELECT
                        Id,
                        (
                                SELECT
                                        Id,
                                        SBQQ__Product__r.Id
                                FROM SBQQ__LineItems__r
                        )
                FROM SBQQ__Quote__c
                WHERE Id IN :quoteIDs
        ];

        Map<SBQQ__Quote__c,Set<Id>> QuotesToProductIds = new Map<SBQQ__Quote__c,Set<Id>>();
        for (SBQQ__Quote__c quote : quotes) {
            if (!(QuotesToProductIds.containsKey(quote))) {
                QuotesToProductIds.put(quote, new Set<Id>());
            }
            for (List<SBQQ__QuoteLine__c> quoteLines : quote.SBQQ__LineItems__r) {
                for (SBQQ__QuoteLine__c quoteLine : quoteLines) {
                    QuotesToProductIds.get(quote).add(quoteLine.SBQQ__Product__r.Id);
                }
            }
        }

        return QuotesToProductIds;
    }

    public static String getQuoteLineProductContractTemplateKey(Product_Contract_Template__c QuoteLineProductContractTemplate, Set<String> omittedContractFields) {
        String QuoteLineProductContractTemplate_key = null;
        if (QuoteLineProductContractTemplate == null) { return QuoteLineProductContractTemplate_key; }

        if (omittedContractFields == null) {
            if (String.isNotBlank(QuoteLineProductContractTemplate.Contract_Category_1__c)){
                QuoteLineProductContractTemplate_key = QuoteLineProductContractTemplate.Contract_Category_1__c;
            }
            if (String.isNotBlank(QuoteLineProductContractTemplate.Contract_Category_2__c)){
                QuoteLineProductContractTemplate_key = QuoteLineProductContractTemplate_key + QuoteLineProductContractTemplate.Contract_Category_2__c;
            }
            if (String.isNotBlank(QuoteLineProductContractTemplate.Agreement_Type__c)){
                QuoteLineProductContractTemplate_key = QuoteLineProductContractTemplate_key + QuoteLineProductContractTemplate.Agreement_Type__c;
            }
            if (String.isNotBlank(QuoteLineProductContractTemplate.Legal_Entity_Name__c)){
                QuoteLineProductContractTemplate_key = QuoteLineProductContractTemplate_key + QuoteLineProductContractTemplate.Legal_Entity_Name__c;
            }
            if (String.isNotBlank(QuoteLineProductContractTemplate.Status__c)){
                QuoteLineProductContractTemplate_key = QuoteLineProductContractTemplate_key + QuoteLineProductContractTemplate.Status__c;
            }
        }
        else {
            if (!omittedContractFields.contains('Contract_Category_1__c')) {
                if (String.isNotBlank(QuoteLineProductContractTemplate.Contract_Category_1__c)) {
                    QuoteLineProductContractTemplate_key = QuoteLineProductContractTemplate.Contract_Category_1__c;
                }
            }
            if (!omittedContractFields.contains('Contract_Category_2__c')) {
                if (String.isNotBlank(QuoteLineProductContractTemplate.Contract_Category_2__c)){
                    QuoteLineProductContractTemplate_key = QuoteLineProductContractTemplate_key + QuoteLineProductContractTemplate.Contract_Category_2__c;
                }
            }
            if (!omittedContractFields.contains('Agreement_Type__c')) {
                if (String.isNotBlank(QuoteLineProductContractTemplate.Agreement_Type__c)){
                    QuoteLineProductContractTemplate_key = QuoteLineProductContractTemplate_key + QuoteLineProductContractTemplate.Agreement_Type__c;
                }
            }
            if (!omittedContractFields.contains('Legal_Entity_Name__c')) {
                if (String.isNotBlank(QuoteLineProductContractTemplate.Legal_Entity_Name__c)){
                    QuoteLineProductContractTemplate_key = QuoteLineProductContractTemplate_key + QuoteLineProductContractTemplate.Legal_Entity_Name__c;
                }
            }
            if (!omittedContractFields.contains('Status')) {
                if (String.isNotBlank(QuoteLineProductContractTemplate.Status__c)){
                    QuoteLineProductContractTemplate_key = QuoteLineProductContractTemplate_key + QuoteLineProductContractTemplate.Status__c;
                }
            }
        }

        return QuoteLineProductContractTemplate_key;
    }

    public static String getQuoteProductContractKey(Contract QuoteProductContract, Set<String> omittedContractFields) {
        String QuoteProductContract_key = null;
        if (QuoteProductContract == null) { return QuoteProductContract_key; }

        if (omittedContractFields == null) {
            if (String.isNotBlank(QuoteProductContract.Contract_Category_1__c)){
                QuoteProductContract_key = QuoteProductContract.Contract_Category_1__c;
            }
            if (String.isNotBlank(QuoteProductContract.Contract_Category_2__c)){
                QuoteProductContract_key = QuoteProductContract_key + QuoteProductContract.Contract_Category_2__c;
            }
            if (String.isNotBlank(QuoteProductContract.Agreement_Type__c)){
                QuoteProductContract_key = QuoteProductContract_key + QuoteProductContract.Agreement_Type__c;
            }
            if (String.isNotBlank(QuoteProductContract.Legal_Entity_Name__c)){
                QuoteProductContract_key = QuoteProductContract_key + QuoteProductContract.Legal_Entity_Name__c;
            }
            if (String.isNotBlank(QuoteProductContract.Status)){
                QuoteProductContract_key = QuoteProductContract_key + QuoteProductContract.Status;
            }
        }
        else {
            if (!omittedContractFields.contains('Contract_Category_1__c')) {
                if (String.isNotBlank(QuoteProductContract.Contract_Category_1__c)){
                    QuoteProductContract_key = QuoteProductContract.Contract_Category_1__c;
                }
            }
            if (!omittedContractFields.contains('Contract_Category_2__c')) {
                if (String.isNotBlank(QuoteProductContract.Contract_Category_2__c)){
                    QuoteProductContract_key = QuoteProductContract_key + QuoteProductContract.Contract_Category_2__c;
                }
            }
            if (!omittedContractFields.contains('Agreement_Type__c')) {
                if (String.isNotBlank(QuoteProductContract.Agreement_Type__c)){
                    QuoteProductContract_key = QuoteProductContract_key + QuoteProductContract.Agreement_Type__c;
                }
            }
            if (!omittedContractFields.contains('Legal_Entity_Name__c')) {
                if (String.isNotBlank(QuoteProductContract.Legal_Entity_Name__c)){
                    QuoteProductContract_key = QuoteProductContract_key + QuoteProductContract.Legal_Entity_Name__c;
                }
            }
            if (!omittedContractFields.contains('Status')) {
                if (String.isNotBlank(QuoteProductContract.Status)){
                    QuoteProductContract_key = QuoteProductContract_key + QuoteProductContract.Status;
                }
            }
        }

        return QuoteProductContract_key;
    }

    public static Map<String,Product_Contract_Template__c> getQuoteLineProductContractTemplates(SBQQ__QuoteLine__c qli) {
        Map<String,Product_Contract_Template__c> productContractTemplates = new Map<String,Product_Contract_Template__c>();

        Product2 product = qli.SBQQ__Product__r;

        if (product.Output_MSA_Document_Template__r != null) {
            productContractTemplates.put('Output_MSA_Document_Template__r', product.Output_MSA_Document_Template__r);
        }
        if (product.Output_Schedule_Document_Template__r != null) {
            productContractTemplates.put('Output_Schedule_Document_Template__r', product.Output_Schedule_Document_Template__r);
        }
        if (product.Output_Eval_Document_Template__r != null) {
            productContractTemplates.put('Output_Eval_Document_Template__r', product.Output_Eval_Document_Template__r);
        }
        if (product.Output_Eval2_Document_Template__r != null) {
            productContractTemplates.put('Output_Eval2_Document_Template__r', product.Output_Eval2_Document_Template__r);
        }

        return productContractTemplates;
    }

    public static Map<Id,List<Contract>> getQuoteProductContracts(Map<Id,Id> accountIDsToQuoteIDs) {
        System.debug('************************IN getQuoteProductContracts***********');
        Map<Id,List<Contract>> productContracts = new Map<Id,List<Contract>>();

        for (Account account : [SELECT Id, (SELECT Id, CreatedDate, Contract_Category_1__c, Contract_Category_2__c,
                Legal_Entity_Name__c, Status, Agreement_Type__c
            FROM Contracts WHERE Status = 'Active' ORDER BY CreatedDate DESC),
            (SELECT Id, CreatedDate, Contract__c, Contract__r.Contract_Category_1__c, Contract__r.Contract_Category_2__c,
                    Contract__r.CreatedDate,
                    Contract__r.Legal_Entity_Name__c,
                    Contract__r.Agreement_Type__c, Contract__r.Status
            FROM Contract_Additional_Parties__r WHERE Contract__c  != null AND Contract_Status__c = 'Active'
            AND Relationship_Status__c = 'Active')
            FROM Account WHERE Id IN :accountIDsToQuoteIDs.keySet()])
        {
            if (account.Contracts != null && account.Contracts.size() > 0) {
                for (Contract accountContract : account.Contracts) {
                    if (!productContracts.containsKey(accountIDsToQuoteIDs.get(account.Id))) {
                        productContracts.put(accountIDsToQuoteIDs.get(account.Id), new List<Contract>());
                        productContracts.get(accountIDsToQuoteIDs.get(account.Id)).add(accountContract);
                    } else {
                        productContracts.get(accountIDsToQuoteIDs.get(account.Id)).add(accountContract);
                    }
                }
            }

            if (account.Contract_Additional_Parties__r != null && account.Contract_Additional_Parties__r.size() > 0) {
                for (Contract_Additional_Parties__c cap : account.Contract_Additional_Parties__r) {
                    if (!productContracts.containsKey(accountIDsToQuoteIDs.get(account.Id))) {
                        productContracts.put(accountIDsToQuoteIDs.get(account.Id), new List<Contract>());
                        productContracts.get(accountIDsToQuoteIDs.get(account.Id)).add(cap.Contract__r);
                    } else {
                        productContracts.get(accountIDsToQuoteIDs.get(account.Id)).add(cap.Contract__r);
                    }
                }
            }
        }

        System.debug('************************EXIT getQuoteProductContracts***********'+productContracts.size());
        return productContracts;
    }

    public static void updateAssetContracts(List<Customer_Asset__c> customerAssetList) {
        /*
        //+ Steps
            INPUT: Customer Assets

            1. Get a list of QLG related to each Customer Asset.
            2. Get a list of Contracts related to those QLG.
            3. Update the Steelbrick Asset with a relationship to that Contract.
        //- Steps
        */

        if (debug) {
            if (customerAssetList.size() > 0) {
                System.debug('customerAssetList[0].Id: ' + customerAssetList[0].Id);
                System.debug('customerAssetList[0].Steelbrick_Asset__c: ' + customerAssetList[0].Steelbrick_Asset__c);
                System.debug('customerAssetList[0].Latest_Quote_Line__c: ' + customerAssetList[0].Latest_Quote_Line__c);
            }
        }

        if (CustomerAssetHandler.debug) {
            System.debug('customerAssetList to analyze: '+customerAssetList.size());
        }

        for (Customer_Asset__c customerAsset : customerAssetList) {
            if (customerAsset.Steelbrick_Asset__c != null && customerAsset.Contract__c != null) {
                customerAsset.Steelbrick_Asset__r.Contract__c = customerAsset.Contract__c;
            }
        }

        List<Id> assetIDs = new List<Id>();
        List<Id> quoteLineIDs = new List<Id>();

        for (Customer_Asset__c customerAsset : customerAssetList) {
            if ((customerAsset.Contract__c == null) && (customerAsset.Steelbrick_Asset__c != null) && (customerAsset.Latest_Quote_Line__c != null)) {
                assetIDs.add(customerAsset.Steelbrick_Asset__c);
                quoteLineIDs.add(customerAsset.Latest_Quote_Line__c);
            }
        }

        List<Asset> assets = [
                SELECT
                        Id,
                        Contract__c
                FROM Asset
                WHERE Id IN :assetIDs
        ];

        Map<Id,Customer_Asset__c> assetIDsToCustomerAssets = new Map<Id,Customer_Asset__c>();
        for (Asset asset : assets) {
            for (Customer_Asset__c customerAsset : customerAssetList) {
                if (customerAsset.Contract__c == null) { continue; }
                if (customerAsset.Steelbrick_Asset__c != asset.Id) { continue; }

                asset.Contract__c = customerAsset.Contract__c;

                break;
            }
        }

        update assets;
    }

    public static List<Customer_Asset__c> updateCustomerAssetContracts(List<Customer_Asset__c> customerAssetList) {
        /*
        //+ Steps
            INPUT: Customer Assets

            1. Get a list of QLG related to each Customer Asset.
            2. Get a list of Contracts related to those QLG.
            3. Update the Customer Asset with a relationship to that Contract.
        //- Steps
        */

        if (debug) {
            System.debug('# customerAssetList to analyze: '+customerAssetList.size());
            System.debug('customerAssetList to analyze: '+customerAssetList[0]);
        }

        List<Id> quoteLineIDs = new List<Id>();

        for (Customer_Asset__c customerAsset : customerAssetList) {
            if ((customerAsset.Contract__c == null) && (customerAsset.Steelbrick_Asset__c != null) && (customerAsset.Latest_Quote_Line__c != null)) {
                quoteLineIDs.add(customerAsset.Latest_Quote_Line__c);
            }
        }

        List<SBQQ__QuoteLine__c> quoteLines = [
                SELECT
                        Id,
                        SBQQ__Group__c
                FROM SBQQ__QuoteLine__c
                WHERE Id IN :quoteLineIDs
        ];

        if (debug) {
            System.debug('SBQQ__QuoteLine__c to analyze: '+quoteLines.size());
            if (quoteLines.size() > 0) {
                System.debug('Quote Line Group [0]: '+quoteLines[0].SBQQ__Group__c);
            }
        }

        Map<Id,Id> customerAssetIDsToQuoteLineGroupIDs = new Map<Id,Id>();
        List<Id> quoteLineGroupIDs = new List<Id>();
        for (SBQQ__QuoteLine__c quoteLine : quoteLines) {
            quoteLineGroupIDs.add(quoteLine.SBQQ__Group__c);

            for (Customer_Asset__c customerAsset : customerAssetList) {
                if (customerAsset.Latest_Quote_Line__c == quoteLine.Id) {
                    customerAssetIDsToQuoteLineGroupIDs.put(customerAsset.Id, quoteLine.SBQQ__Group__c);
                    break;
                }
            }
        }

        List<Contract> contracts = [
                SELECT
                    Id,
                    Quote_Line_Group__c
                FROM Contract
                WHERE Quote_Line_Group__c != ''
                AND   Quote_Line_Group__c in :quoteLineGroupIDs
        ];

        if (debug) {
            System.debug('Contracts to analyze: '+contracts.size());
        }

        for (Customer_Asset__c customerAsset : customerAssetList) {
            Id quoteLineGroupID = customerAssetIDsToQuoteLineGroupIDs.get(customerAsset.Id);

            if (customerAsset.Contract__c != null) { continue; }
            if (customerAsset.Steelbrick_Subscription__c != null) {
                customerAsset.Contract__c = customerAsset.Steelbrick_Subscription__r.SBQQ__Contract__c;
                continue;
            }

            for (Contract contract : contracts) {
                if (contract.Quote_Line_Group__c == quoteLineGroupID) {
                    customerAsset.Contract__c = contract.Id;
                    break;
                }
            }
        }

        //+ If the Contract has been amended, then the QLG -> Contract relationship is no longer valid.
        System.debug('Exploring the amended contract use-case');
        List<Customer_Asset__c> potentiallyAmendedCustomerAssets = new List<Customer_Asset__c>();
        List<Id> opportunityIDs = new List<Id>();
        for (Customer_Asset__c customerAsset : customerAssetList) {
            if (customerAsset.Contract__c != null) { continue; }
            if (customerAsset.Latest_Opportunity__c == null) { continue; }

            opportunityIDs.add(customerAsset.Latest_Opportunity__c);
            potentiallyAmendedCustomerAssets.add(customerAsset);
        }

        List<Opportunity> opportunities = [
                SELECT
                        Id,
                        SBQQ__AmendedContract__c,
                        StageName
                FROM Opportunity
                WHERE Id IN :opportunityIDs
                AND StageName='Closed Won'
                AND SBQQ__AmendedContract__c!=''
        ];

        Map<Id,Id> opportunityIDsToContractIDs = new Map<Id,Id>();
        for (Opportunity opportunity : opportunities) {
            opportunityIDsToContractIDs.put(opportunity.Id, opportunity.SBQQ__AmendedContract__c);
        }

        for (Customer_Asset__c customerAsset : potentiallyAmendedCustomerAssets) {
            customerAsset.Contract__c = opportunityIDsToContractIDs.get(customerAsset.Latest_Opportunity__c);
        }
        //- If the Contract has been amended, then the QLG -> Contract relationship is no longer valid.

        if (debug) {
            System.debug('# Customer assets to update: '+customerAssetList.size());
            System.debug('Customer assets to update: '+customerAssetList[0]);
        }

        bypassTrigger = true;
        update customerAssetList;
        bypassTrigger = false;

        return customerAssetList;
    }

    public static void createShippingSchedule(List<Customer_Asset__c> assetList) {
        System.debug('CustomerAssetHandler.createShippingSchedule');
        List<Customer_Asset__c> updatedAssetList = getUpdatedAssetData(assetList);

        // ARMAN: Map<Customer_Asset__c, List<Shipping_Estimate__c>> assetOppSEMap = getOppShipEstimates(updatedAssetList);
        // ARMAN: Map<Id, Customer_Asset_Shipping_Summary__c> assetShipSumMap = getAssetShipSummaries(updatedAssetList);
        // ARMAN: Map<Id, List<Customer_Asset_Shipping_Estimate__c>> assetShipEstMap = getAssetShipEstimates(updatedAssetList);

        System.debug('updatedAssetList: ' + updatedAssetList);
        // ARMAN: System.debug('assetOppSEMap: ' + assetOppSEMap);
        // ARMAN: System.debug('assetShipSumMap: ' + assetShipSumMap);
        // ARMAN: System.debug('assetShipEstMap: ' + assetShipEstMap);

        /* ARMAN: Map<Customer_Asset__c, List<Shipping_Estimate__c>> currAssetOppSEMap = assetOppSEMap;
        Map<Customer_Asset__c, List<Shipping_Estimate__c>> tobeAssetOppSEMap = new Map<Customer_Asset__c, List<Shipping_Estimate__c>>();
        Map<Id, Customer_Asset_Shipping_Summary__c> currAssetShipSumMap = assetShipSumMap;
        Map<Id, Customer_Asset_Shipping_Summary__c> tobeAssetShipSumMap = new Map<Id, Customer_Asset_Shipping_Summary__c>();
        Map<Id, Customer_Asset_Shipping_Summary__c> finalAssetShipSumMap = new Map<Id, Customer_Asset_Shipping_Summary__c>();
        Map<Id, List<Customer_Asset_Shipping_Estimate__c>> currAssetShipEstMap = assetShipEstMap;
        */
        for (Customer_Asset__c customerAsset : updatedAssetList) {
            System.debug('current customer asset: ' + customerAsset);
            /* ARMAN: List<Shipping_Estimate__c> seLoopList = currAssetOppSEMap.get(customerAsset);
            if (seLoopList != null && seLoopList.size() > 0) {
                for (Shipping_Estimate__c se : seLoopList) {
                    List<Shipping_Estimate__c> tobeAssetOppSEList = new List<Shipping_Estimate__c>();
                    Boolean customerAssetShippingEstimateExistsForShippingEstimate = false;
                    /* ARMAN: if(currAssetShipEstMap != null && currAssetShipEstMap.containsKey(customerAsset.Id)) {
                        for (Customer_Asset_Shipping_Estimate__c customerAssetShippingEstimate: currAssetShipEstMap.get(customerAsset.Id)) {
                            if (customerAssetShippingEstimate.Estimated_Shipping_Date__c == se.Estimated_Shipping_Date__c && customerAssetShippingEstimate.Estimated_Shipping_Quantity__c == se.Estimated_Shipping_Quantity__c) {
                                customerAssetShippingEstimateExistsForShippingEstimate = true;
                            }
                        }
                    }*/

                    //TODO Could be an issue size() > 0 originally
                    /*if (currAssetShipEstMap.size() > 0 && customerAsset.Latest_Quote_Line__r.SBQQ__RenewedSubscription__c == null) {
                        for (Customer_Asset_Shipping_Estimate__c ase : currAssetShipEstMap.get(customerAsset.Id)) {
                            if (tobeAssetOppSEMap.containsKey(customerAsset)) {
                                tobeAssetOppSEList = tobeAssetOppSEMap.get(customerAsset);
                            } else {
                                tobeAssetOppSEList = new List<Shipping_Estimate__c>();
                            }
                            tobeAssetOppSEList.add(se);
                            tobeAssetOppSEMap.put(customerAsset, tobeAssetOppSEList);
                        }
                    } else { */
                    // Don't add another shipping estimate if one already exists.
                    /* ARMAN: if(!customerAssetShippingEstimateExistsForShippingEstimate && customerAsset.Latest_Quote_Line__r.SBQQ__RenewedSubscription__c == null) {
                        if (tobeAssetOppSEMap.containsKey(customerAsset)) {
                            tobeAssetOppSEList = tobeAssetOppSEMap.get(customerAsset);
                        } else {
                            tobeAssetOppSEList = new List<Shipping_Estimate__c>();
                        }
                        tobeAssetOppSEList.add(se);
                        tobeAssetOppSEMap.put(customerAsset, tobeAssetOppSEList);
                    }
                    //}
                }
            }*/
            /* ARMAN: System.debug('currAssetShipSumMap before: ' + currAssetShipSumMap);
            if (!currAssetShipSumMap.containsKey(customerAsset.Id)) {
                System.debug('Current asset for summary: ' + customerAsset);
                Customer_Asset_Shipping_Summary__c newAssetShipSum = new Customer_Asset_Shipping_Summary__c();
                newAssetShipSum.Customer_Asset__c = customerAsset.Id;
                tobeAssetShipSumMap.put(customerAsset.Id, newAssetShipSum);
                System.debug('new ship sum: ' + newAssetShipSum);
            }*/
        }

        // ARMAN: System.debug('tobeAssetShipSumMap: ' + tobeAssetShipSumMap);
        // System.debug('tobeAssetOppSEMap: ' + tobeAssetOppSEMap);

        // create new asset ship summaries and get new list
        /* ARMAN: CustomerAssetHandler.bypassTrigger = true;
        if(tobeAssetShipSumMap.values().size() > 0){
            insert tobeAssetShipSumMap.values();
        }

        CustomerAssetHandler.bypassTrigger = false; */

        // ARMAN: finalAssetShipSumMap = getAssetShipSummaries(updatedAssetList);
        // ARMAN: System.debug('finalAssetShipSumMap: ' + finalAssetShipSumMap);

        //ARMAN: List<Customer_Asset_Shipping_Estimate__c> insertASEList = new List<Customer_Asset_Shipping_Estimate__c>();
        //ARMAN: List<Customer_Asset_Shipping_Estimate__c> updateASEList = new List<Customer_Asset_Shipping_Estimate__c>();
        for (Customer_Asset__c customerAsset : updatedAssetList) {
            System.debug('current asset: ' + customerAsset);
            /* ARMAN: if (tobeAssetOppSEMap != null && tobeAssetOppSEMap.size() > 0 && tobeAssetOppSEMap.get(customerAsset) != null) {
                Decimal groupQty = 0.0;
                if (customerAsset.Latest_Quote_Line__r.SBQQ__Group__r.Group_Service_Plan_Quantity_Rollup__c != null && customerAsset.Latest_Quote_Line__r.SBQQ__Group__r.Group_Service_Plan_Quantity_Rollup__c != 0) {
                    groupQty = customerAsset.Latest_Quote_Line__r.SBQQ__Group__r.Group_Service_Plan_Quantity_Rollup__c;
                } else if (customerAsset.Latest_Quote_Line__r.SBQQ__Group__r.Group_Hardware_Quantity_Rollup__c != null && customerAsset.Latest_Quote_Line__r.SBQQ__Group__r.Group_Hardware_Quantity_Rollup__c != 0) {
                    groupQty = customerAsset.Latest_Quote_Line__r.SBQQ__Group__r.Group_Hardware_Quantity_Rollup__c;
                } else if (customerAsset.Latest_Quote_Line__r.SBQQ__Group__r.Group_Application_Quantity_Rollup__c != null && customerAsset.Latest_Quote_Line__r.SBQQ__Group__r.Group_Application_Quantity_Rollup__c != 0) {
                    groupQty = customerAsset.Latest_Quote_Line__r.SBQQ__Group__r.Group_Application_Quantity_Rollup__c;
                } else if (customerAsset.Latest_Quote_Line__r.SBQQ__Group__r.Group_Software_Quantity_Rollup__c != null && customerAsset.Latest_Quote_Line__r.SBQQ__Group__r.Group_Software_Quantity_Rollup__c != 0) {
                    groupQty = customerAsset.Latest_Quote_Line__r.SBQQ__Group__r.Group_Software_Quantity_Rollup__c;
                }

                Decimal qtyPctOfGroup = 0.0;
                if(groupQty != null && groupQty != 0){
                    if (customerAsset.Latest_Quote_Line__r.Quote_Line_Type__c != 'New' ) {
                        qtyPctOfGroup = (Math.abs(customerAsset.Latest_Quote_Line__r.SBQQ__EffectiveQuantity__c) / Math.abs(groupQty));
                    } else {
                        qtyPctOfGroup = (Math.abs(customerAsset.Quantity__c) / Math.abs(groupQty));
                    }
                }
                System.debug('group quantity: ' + groupQty);
                System.debug('percent of group quantity: ' + qtyPctOfGroup);
                Map<Date, Integer> dateMap = new Map<Date, Integer>();
                Map<Integer, Customer_Asset_Shipping_Estimate__c> estimateMap = new Map<Integer, Customer_Asset_Shipping_Estimate__c>();
                Integer i = 0;
                for (Shipping_Estimate__c se : tobeAssetOppSEMap.get(customerAsset)) {
                    if (se.Estimated_Shipping_Date__c != null) {
                        if (!dateMap.containsKey(se.Estimated_Shipping_Date__c)) {
                            dateMap.put(se.Estimated_Shipping_Date__c, i);
                        }
                    }
                    i = i + 1;
                }
                i = 0;
                for (Shipping_Estimate__c se : tobeAssetOppSEMap.get(customerAsset)) {
                    Integer j = 9999;
                    try {
                        j = dateMap.get(se.Estimated_Shipping_Date__c);
                    } catch (Exception ex) {
                        j = 99999;
                    }
                    if (i == j) {
                        if (!estimateMap.containsKey(i)) {
                            System.debug('in new SE');
                            Customer_Asset_Shipping_Estimate__c insertASE = new Customer_Asset_Shipping_Estimate__c();
                            insertASE.Customer_Asset_Shipping_Summary__c = finalAssetShipSumMap.get(customerAsset.Id).Id;
                            insertASE.Estimated_Shipping_Date__c = se.Estimated_Shipping_Date__c;
                            if(se.Estimated_Shipping_Quantity__c != null) {
                                insertASE.Estimated_Shipping_Quantity__c = se.Estimated_Shipping_Quantity__c * qtyPctOfGroup;
                            } else {
                                insertASE.Estimated_Shipping_Quantity__c = 0;
                            }
                            System.debug('se quantity: ' + se.Estimated_Shipping_Quantity__c);
                            System.debug('se quantity percent: ' + se.Estimated_Shipping_Quantity__c * qtyPctOfGroup);
                            insertASE.Shipping_Notes__c = se.Shipping_Notes__c;

                            estimateMap.put(i, insertASE);
                        }
                    } else {
                        if (estimateMap.containsKey(i)) {
                            System.debug('in existing SE');
                            Customer_Asset_Shipping_Estimate__c parentEstimate = new Customer_Asset_Shipping_Estimate__c();
                            parentEstimate = estimateMap.get(dateMap.get(se.Estimated_Shipping_Date__c));
                            parentEstimate.Estimated_Shipping_Quantity__c = (parentEstimate.Estimated_Shipping_Quantity__c * qtyPctOfGroup) + se.Estimated_Shipping_Quantity__c;
                            System.debug('parent se quantity: ' + parentEstimate.Estimated_Shipping_Quantity__c);
                            System.debug('parent se quantity percent: ' + parentEstimate.Estimated_Shipping_Quantity__c * qtyPctOfGroup);
                            if (parentEstimate.Shipping_Notes__c != null) {
                                if (se.Shipping_Notes__c != null) {
                                    parentEstimate.Shipping_Notes__c = parentEstimate.Shipping_Notes__c + '\n' + se.Shipping_Notes__c;
                                }
                            } else {
                                if (se.Shipping_Notes__c != null) {
                                    parentEstimate.Shipping_Notes__c = se.Shipping_Notes__c;
                                }
                            }
                            parentEstimate.Customer_Asset_Shipping_Summary__c = finalAssetShipSumMap.get(customerAsset.Id).Id;
                            estimateMap.put(dateMap.get(se.Estimated_Shipping_Date__c), parentEstimate);
                        }
                    }
                    i = i + 1;
                }
                for (Customer_Asset_Shipping_Estimate__c estimate : estimateMap.values()) {
                    System.debug('current estimate: ' + estimate);
                    if (estimate.Id == null) {
                        estimate.Customer_Asset_Shipping_Summary__c = finalAssetShipSumMap.get(customerAsset.Id).Id;
                        insertASEList.add(estimate);
                    } else {
                        updateASEList.add(estimate);
                    }
                }
            } */
        }

        /* ARMAN: bypassTrigger = true;
        if (insertASEList.size() > 0) {
            insert insertASEList;
        }
        if (updateASEList.size() > 0) {
            update updateASEList;
        }
        bypassTrigger = false;
        */
    }

    private static List<Customer_Asset__c> getUpdatedAssetData(List<Customer_Asset__c> assetList) {
        System.debug('AssetHandler.getUpdatedAssetData');
        List<Customer_Asset__c> newAssetList = new List<Customer_Asset__c>();
        try {
            newAssetList = [
                    SELECT Id, Name, Account__c, Annual_Recurring_Revenue__c
                            , Asset_Status__c, Contract__c, Decommission_Effective_Date__c
                            , Description__c, Product__c, Product_Code__c, Product_Family__c
                            , Product_Group__c, Product_Line__c, Quantity__c, Steelbrick_Asset__c
                            , Steelbrick_Subscription__c, Term_Start_Date__c, Term_End_Date__c
                            /*, Total_One_Time_Fee_s__c,*/
                            , Latest_Opportunity__c, Latest_Quote_Line__c
                            , Steelbrick_Asset__r.SBQQ__LatestQuoteLine__r.SBQQ__Group__r.Id
                            , Steelbrick_Subscription__r.SBQQ__QuoteLine__r.SBQQ__Group__r.Id
                            , Latest_Quote_Line__r.SBQQ__Group__r.Id
                            , Latest_Quote_Line__r.SBQQ__Product__r.Shipment_Schedule_Required__c
                            , Latest_Quote_Line__r.SBQQ__Group__r.Group_Hardware_Quantity_Rollup__c
                            , Latest_Quote_Line__r.SBQQ__Product__r.Product_Type__c
                            , Latest_Quote_Line__r.SBQQ__Product__r.Product_Sub_Type__c
                            , Latest_Quote_Line__r.SBQQ__Group__r.Group_Service_Plan_Quantity_Rollup__c
                            , Latest_Quote_Line__r.SBQQ__Group__r.Group_Application_Quantity_Rollup__c
                            , Latest_Quote_Line__r.SBQQ__Group__r.Group_Software_Quantity_Rollup__c
                            , Latest_Quote_Line__r.SBQQ__RenewedSubscription__c
                            , Latest_Quote_Line__r.SBQQ__EffectiveQuantity__c
                            , Latest_Quote_Line__r.Quote_Line_Type__c
                    FROM Customer_Asset__c
                    WHERE Id IN :assetList
            ];
        } catch (QueryException qe) {
            System.debug(LoggingLevel.INFO, 'CustomerAssetHandler.getUpdatedAssetData() Error occurred during query for assets: ' + assetList + ' Message: ' + qe.getMessage());
        }
        return newAssetList;
    }

    /* ARMAN: private static Map<Customer_Asset__c, List<Shipping_Estimate__c>> getOppShipEstimates(List<Customer_Asset__c> assetList) {
        System.debug('AssetHandler.getOppShipEstimates');

        Map<Customer_Asset__c, List<Shipping_Estimate__c>> assetSEMap = new Map<Customer_Asset__c, List<Shipping_Estimate__c>>();
        Map<Customer_Asset__c, Id> qlIdMap = new Map<Customer_Asset__c, Id>();
        for (Customer_Asset__c a : assetList) {
            qlIdMap.put(a, a.Latest_Quote_Line__r.SBQQ__Group__r.Id);
        }
        List<Shipping_Estimate__c> shipEstList = [
                select Id, Name, Estimated_Shipping_Date__c
                        , Estimated_Shipping_Quantity__c, Shipping_Notes__c,
                        Shipping_Summary__r.Quote_Line_Group__r.Id
                from Shipping_Estimate__c
                where Shipping_Summary__r.Quote_Line_Group__r.Id in :qlIdMap.values()
        ];
        for (Shipping_Estimate__c se : shipEstList) {
            List<Shipping_Estimate__c> seList = new List<Shipping_Estimate__c>();
            for (Customer_Asset__c a : qlIdMap.keySet()) {
                if (assetSEMap.containsKey(a)) {
                    seList = assetSEMap.get(a);
                } else {
                    seList = new List<Shipping_Estimate__c>();
                }
                seList.add(se);
                assetSEMap.put(a, seList);
            }
        }
        return assetSEMap;
    }*/

    /* ARMAN: private static Map<Id, Customer_Asset_Shipping_Summary__c> getAssetShipSummaries(List<Customer_Asset__c> assetList) {
        System.debug('AssetHandler.getAssetShipSummaries');
        System.debug('assetList: ' + assetList);
        Map<Id, Customer_Asset_Shipping_Summary__c> assetSSMap = new Map<Id, Customer_Asset_Shipping_Summary__c>();
        List<Customer_Asset_Shipping_Summary__c> shipSumList = new List<Customer_Asset_Shipping_Summary__c>();
        List<Id> assetIdList = new List<Id>();
        for (Customer_Asset__c customerAsset : assetList) {
            assetIdList.add(customerAsset.Id);
        }
        try {
            shipSumList = [
                    SELECT Id, Name, Customer_Asset__c, Customer_Asset__r.Id, Actual_Shipped_Quantity__c, Estimated_Shipping_Quantity__c
                    FROM Customer_Asset_Shipping_Summary__c
                    WHERE Customer_Asset__r.Id IN :assetIdList
            ];
        } catch (QueryException qe) {
            System.debug(LoggingLevel.INFO, 'CustomerAssetHandler.getAssetShipSummaries() Error occurred during query for assets: ' + assetIdList + ' Message: ' + qe.getMessage());
        }
        System.debug('CustomerAssetHandler.getAssetShipSummaries() shipSumList: ' + shipSumList);
        for (Customer_Asset_Shipping_Summary__c ss : shipSumList) {
            //if (!assetSSMap.containsKey(ss.Customer_Asset__r.Id)) {
            assetSSMap.put(ss.Customer_Asset__r.Id, ss);
            //}
        }
        return assetSSMap;
    } */

    /**
     * Creates a map from the Customer Asset Id to a list of the existing Customer Asset Shipping Estimates for that Customer Asset.
     * Deletes customer asset shipping estimates if they are not related to a renewed subscription.
     */
    /*private static Map<Id, List<Customer_Asset_Shipping_Estimate__c>> getAssetShipEstimates(List<Customer_Asset__c> assetList) {
        System.debug('AssetHandler.getAssetShipEstimates');
        Map<Id,Id> caRenewMap = new Map<Id,Id>();
        for(Customer_Asset__c customerAsset : assetList){
            if(customerAsset.Latest_Quote_Line__r.SBQQ__RenewedSubscription__c != null){
                caRenewMap.put(customerAsset.Id, customerAsset.Id);
            }
        }
        List<Customer_Asset_Shipping_Estimate__c> seDelList = new List<Customer_Asset_Shipping_Estimate__c>();

        Map<Id, List<Customer_Asset_Shipping_Estimate__c>> assetSEMap = new Map<Id, List<Customer_Asset_Shipping_Estimate__c>>();
        List<Customer_Asset_Shipping_Estimate__c> shipEstList = new List<Customer_Asset_Shipping_Estimate__c>();
        try {
            shipEstList = [
                    SELECT Id, Name, Estimated_Shipping_Date__c
                            , Estimated_Shipping_Quantity__c, Shipping_Notes__c
                            , Customer_Asset_Shipping_Summary__c
                            , Customer_Asset_Shipping_Summary__r.Customer_Asset__c
                    FROM Customer_Asset_Shipping_Estimate__c
                    WHERE Customer_Asset_Shipping_Summary__r.Customer_Asset__c in :assetList
            ];
        } catch (QueryException e) {
            System.debug(LoggingLevel.INFO, 'CustomerAssetHandler.getAssetShipEstimates() Error occurred during query for assets: ' + assetList + ' Message: ' + e.getMessage());
        }

        for (Customer_Asset_Shipping_Estimate__c customerAssetShippingEstimate : shipEstList) {
            List<Customer_Asset_Shipping_Estimate__c> seList = new List<Customer_Asset_Shipping_Estimate__c>();
            if(caRenewMap.containsKey(customerAssetShippingEstimate.Customer_Asset_Shipping_Summary__r.Customer_Asset__c)){
                seDelList.add(customerAssetShippingEstimate);
            } else if (assetSEMap.containsKey(customerAssetShippingEstimate.Customer_Asset_Shipping_Summary__r.Customer_Asset__c)) {
                seList = assetSEMap.get(customerAssetShippingEstimate.Customer_Asset_Shipping_Summary__r.Customer_Asset__c);
                seList.add(customerAssetShippingEstimate);
            } else {
                seList = new List<Customer_Asset_Shipping_Estimate__c>();
                seList.add(customerAssetShippingEstimate);
            }
            assetSEMap.put(customerAssetShippingEstimate.Customer_Asset_Shipping_Summary__r.Customer_Asset__c, seList);
        }
        return assetSEMap;
    }*/


    /********************************************************************************************
      * After an Opportunity is set to ClosedWon and a SteelBrick CPQ Contract is created, 
      * set the Contract__c field on Asset and CustomerAsset objects.
      *
      * TEST SCENARIOS: When Contracts get created OR Contract is renewed OR Contract is ammended
      ********************************************************************************************/
    public static void setContractOnAssetAndCustomerAsset(List<Customer_Asset__c> newCustomerAssets) {
        System.debug('-- START setContractOnAssetAndCustomerAsset');
        try {
            Set<Id> caIdSet = new Set<Id>();
            for (Customer_Asset__c ca : newCustomerAssets) {
                caIdSet.add(ca.Id);
            }
            System.debug('-- caIdSet.size() ='+caIdSet.size());
            System.debug('-- caIdSet ='+caIdSet);

            // Get SB CPQ Contracts from newContracts (based on Trigger.new list and SBQQ__Opportunity__c)
            // We need to confirm that RecordType = SteelBrick CPQ Contract
            Map<Id, Customer_Asset__c> customerAssetsMap =
                new Map<Id, Customer_Asset__c>(
                    [SELECT Id, Latest_Opportunity__c, Steelbrick_Asset__c, Contract__c
                     FROM Customer_Asset__c 
                     WHERE Id IN : caIdSet]);

            Set<Id> oppIdSet = new Set<Id>();
            Map<Id,Id> caToOppMap = new Map<Id,Id>();
            for (Customer_Asset__c ca : customerAssetsMap.values()) {
                oppIdSet.add(ca.Latest_Opportunity__c);
                caToOppMap.put(ca.Id, ca.Latest_Opportunity__c);
            }
            System.debug('-- oppIdSet = '+oppIdSet);
            System.debug('-- caToOppMap = '+caToOppMap);

            Map<Id,Id> quoteToContractMap = new Map<Id,Id>();
            List<Opportunity> opps = 
                [SELECT Id, Contract__c, SBQQ__PrimaryQuote__c, 
                 SBQQ__AmendedContract__c, SBQQ__RenewedContract__c 
                 FROM Opportunity
                 WHERE Id IN: oppIdSet 
                 AND StageName =: CLOSED_WON];

            System.debug('-- opps size = '+opps.size());

            Set<Id> quoteIdSet = new Set<Id>();
            Map<Id,Id> oppToQuoteMap = new Map<Id,Id>();
            for (Opportunity opp : opps) {
                quoteIdSet.add(opp.SBQQ__PrimaryQuote__c);
                oppToQuoteMap.put(opp.Id, opp.SBQQ__PrimaryQuote__c);
                if (opp.SBQQ__AmendedContract__c != null) { // VIP step for Contract Amendment
                    System.debug('-- opp.SBQQ__AmendedContract__c = '+opp.SBQQ__AmendedContract__c);
                    quoteToContractMap.put(opp.SBQQ__PrimaryQuote__c, opp.SBQQ__AmendedContract__c);
                }
                else if (opp.SBQQ__RenewedContract__c != null) { // VIP step for Contract Renewal
                    System.debug('-- opp.SBQQ__RenewedContract__c = '+opp.SBQQ__RenewedContract__c);
                    // SKIP here, because it is taken care of in ContractTriggerHandler
                }
            }
            System.debug('-- quoteIdSet = '+quoteIdSet);
            System.debug('-- oppToQuoteMap = '+oppToQuoteMap);
            System.debug('-- 0: quoteToContractMap = '+quoteToContractMap);

            List<Contract> contracts = 
                [SELECT Id, SBQQ__Quote__c, SBQQ__ActiveContract__c
                 FROM Contract 
                 WHERE SBQQ__Quote__c IN: quoteIdSet];
            
            System.debug('-- contracts.size() = '+contracts.size());
            System.debug('-- contracts = '+contracts);
            for (Contract c : contracts) {
                quoteToContractMap.put(c.SBQQ__Quote__c, c.Id);
            }            
            System.debug('-- 1: quoteToContractMap = '+quoteToContractMap);

            // What Contract belongs to what CustomerAsset ?
            List<Customer_Asset__c> customerAssetsToUpdate = new List<Customer_Asset__c>();
            Map<Id, Id> assetToContractMap = new Map<Id, Id>();
            for (Customer_Asset__c ca : customerAssetsMap.values()) {
                Id oppId = caToOppMap.get(ca.Id);
                Id quoteId = oppToQuoteMap.get(oppId);
                Id contractId = quoteToContractMap.get(quoteId);
                ca.Contract__c = contractId;
                if (ca.Contract__c != null) {
                    //System.debug('-- CustomerAsset Contract__c= '+ca.Contract__c);
                    customerAssetsToUpdate.add(ca);
                    if (ca.Steelbrick_Asset__c != null) {
                        assetToContractMap.put(ca.Steelbrick_Asset__c, ca.Contract__c);
                    }
                    else {
                        System.debug('-- No Steelbrick_Asset__c for CustomerAsset = '+ca.Id);
                    }
                }
                else {
                    System.debug('-- No Contract__c for CustomerAsset = '+ca.Id);
                }
            }
            System.debug('-- assetToContractMap.size() ='+assetToContractMap.size());
            System.debug('-- assetToContractMap ='+assetToContractMap);

            try {
                update customerAssetsToUpdate;
                System.debug('-- UPDATED CustomerAssets.size() = '+customerAssetsToUpdate.size());
                //System.debug('-- UPDATED CustomerAssets = '+customerAssetsToUpdate);

                if (!assetToContractMap.isEmpty()) {
                    setContractOnAsset(assetToContractMap);
                }
            }
            catch(Exception e) {
                System.debug(e.getStackTraceString());
            }
        }
        catch(Exception e) {
            System.debug(e.getStackTraceString());
        }
        System.debug('-- END setContractOnAssetAndCustomerAsset');
    }

    private static void setContractOnAsset(Map<Id, Id> assetToContractMap) {
        System.debug('-- IN setContractOnAsset --');
        Set<Id> sbAssetIdSet = new Set<Id>();
        for (Id assetId : assetToContractMap.keySet()) {
            sbAssetIdSet.add(assetId);
        }
        System.debug('-- sbAssetIdSet.size() ='+sbAssetIdSet.size());
        System.debug('-- sbAssetIdSet ='+sbAssetIdSet);

        // Find the Assets for this set of Contracts
        Map<Id, Asset> sbAssetsMap = 
            new Map<Id, Asset>([SELECT Id, Contract__c
                FROM Asset
                WHERE Id IN : sbAssetIdSet]);

        System.debug('-- sbAssetsMap.size() ='+sbAssetsMap.size());
        System.debug('-- sbAssetsMap ='+sbAssetsMap);

        // Set the Contract__c for the related Asset
        List<Asset> assetsToUpdate = new List<Asset>();
        for (Asset a : sbAssetsMap.values()) {
            a.Contract__c = assetToContractMap.get(a.Id);
            assetsToUpdate.add(a);
        }

        try {
            update assetsToUpdate;
            System.debug('-- UPDATED Assets = '+assetsToUpdate);
        }
        catch(Exception e) {
            System.debug(e.getStackTraceString());
        }
    }
}