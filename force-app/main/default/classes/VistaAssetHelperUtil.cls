@isTest
public class VistaAssetHelperUtil {
    public VistaAssetHelperUtil() {
    }

    public Id pricebookId = Test.getStandardPricebookId();

    public Account createAccount(String acctName) {
        System.debug(LoggingLevel.WARN, 'VistaAssetHelperUtil.createAccount');
        Account account = new Account();
        account.Name = acctName;
        account.Phone = '(555) 555-5555';
        account.BillingStreet = 'Harwood St';
        account.BillingCity = 'Dallas';
        account.BillingState = 'TX';
        account.BillingPostalCode = '75201';
        account.BillingCountry = 'USA';
        account.Primary_Business_Unit__c = 'Omnitracs Domestic';
        account.Segment__c = 'TL';
		account.Fleet_Size__c = 10;
        insert account;
        account = [select Id, Name from Account where Id = :account.Id];
        return account;
    }

    public Contract createContract(Opportunity opportunity, Account account, String contractType, Date startdate) {
        System.debug(LoggingLevel.WARN, 'VistaAssetHelperUtil.createContract');
        Id recTypeId = [select Id from RecordType where SobjectType = 'Contract' and Name = :contractType].Id;
        Contract contract = new Contract();
        contract.RecordTypeId = recTypeId;
        contract.AccountId = account.Id;
        contract.Status = 'Draft';
        contract.StartDate = startdate;
        contract.ContractTerm = 12;
        if (contractType != 'Master Agreement' && opportunity != null) {
            contract.SBQQ__Opportunity__c = opportunity.Id;
        }
        contract.Master_Term_Remaining__c = 12;
        insert contract;
        contract = [select Id, ContractNumber, RecordTypeId, AccountId, Status, StartDate, ContractTerm, SBQQ__Opportunity__c, Master_Term_Remaining__c from Contract where Id = :contract.Id];
        return contract;
    }

    public List<Product2> initProductSet(Integer numProducts, String productType, String productSubType, String subPricingType) {
        System.debug(LoggingLevel.WARN, 'VistaAssetHelperUtil.initProductSet');
        // subPricingType = 'Fixed Price' or 'Percent Of Total'
        List<Product2> productList = new List<Product2>();
        Integer p = 0;
        while (p < numProducts) {
            Product2 product = new Product2();
            product.Business_Unit__c = 'Omnitracs US';
            product.ProductCode = 'product-' + p + productType + productSubType + subPricingType;
            product.Name = productType + ' Product ' + p;
            product.Product_Type__c = productType;
            product.Product_Sub_Type__c = productSubType;
            product.Description = productType + ' Product ' + p + ' Description';
            product.Family = productType + 'Family';
            product.Generate_Asset__c = true;
            product.IsActive = true;
            if (subPricingType != null) {
                if (subPricingType == 'Percent Of Total') {
                    product.SBQQ__SubscriptionPricing__c = 'Percent Of Total';
                    product.SBQQ__SubscriptionPercent__c = 10;
                    product.SBQQ__SubscriptionBase__c = 'List';
                    product.Default_Billing_Frequency__c = 'Annual';
                } else if (subPricingType == 'One Time') {
                    product.SBQQ__SubscriptionPricing__c = 'Fixed Price';
                    product.SBQQ__SubscriptionType__c = 'One-time';
                    product.SBQQ__SubscriptionTerm__c = 12;
                    product.Default_Billing_Frequency__c = 'Once';
                } else {
                    product.SBQQ__SubscriptionPricing__c = subPricingType;
                    product.SBQQ__SubscriptionType__c = 'Renewable';
                    product.SBQQ__SubscriptionTerm__c = 12;
                    product.Default_Billing_Frequency__c = 'Monthly';
                }
            } else {
                product.SBQQ__SubscriptionType__c = null;
            }
            product.SBQQ__QuantityEditable__c = true;
            product.SBQQ__IncludeInMaintenance__c = true;
            if (productType == 'Hardware') {
                product.Default_Billing_Frequency__c = 'Quarterly';
                product.Shipment_Schedule_Required__c = true;
            }
            product.Revenue_Recognition_Frequency__c = 'Monthly';
            productList.add(product);
            p = p + 1;
        }
        insert productList;
        return productList;
    }

    public List<Product2> initProductSet(Integer numProducts, String productType, String productSubType, String subPricingType, String billingFreq) {
        return initProductSet(numProducts, productType, productSubType, subPricingType, billingFreq, 'Monthly');
    }

    public List<Product2> initProductSet(Integer numProducts, String productType, String productSubType, String subPricingType, String billingFreq, String revenueFrequency) {
        System.debug(LoggingLevel.WARN, 'VistaAssetHelperUtil.initProductSet');
        // subPricingType = 'Fixed Price' or 'Percent Of Total'
        List<Product2> productList = new List<Product2>();
        Integer p = 0;
        while (p < numProducts) {
            Product2 product = new Product2();
            product.Business_Unit__c = 'Omnitracs US';
            product.ProductCode = 'product-' + p + productType + productSubType + subPricingType + billingFreq;
            product.Name = productType + ' Product ' + p;
            product.Product_Type__c = productType;
            product.Product_Sub_Type__c = productSubType;
            product.Description = productType + ' Product ' + p + ' Description';
            product.Family = productType + 'Family';
            product.Generate_Asset__c = true;
            product.IsActive = true;
            if (subPricingType != null) {
                if (subPricingType == 'Percent Of Total') {
                    product.SBQQ__SubscriptionPricing__c = 'Percent Of Total';
                    product.SBQQ__SubscriptionPercent__c = 10;
                    product.SBQQ__SubscriptionBase__c = 'List';
                } else if (subPricingType == 'One Time') {
                    product.SBQQ__SubscriptionPricing__c = 'Fixed Price';
                    product.SBQQ__SubscriptionType__c = 'One-time';
                    product.SBQQ__SubscriptionTerm__c = 12;
                } else {
                    product.SBQQ__SubscriptionPricing__c = subPricingType;
                    product.SBQQ__SubscriptionType__c = 'Renewable';
                    product.SBQQ__SubscriptionTerm__c = 12;
                }
            } else {
                product.SBQQ__SubscriptionPricing__c = null;
                product.SBQQ__SubscriptionType__c = null;
            }
            product.SBQQ__QuantityEditable__c = true;
            product.SBQQ__IncludeInMaintenance__c = true;
            product.Default_Billing_Frequency__c = billingFreq;
            product.Revenue_Recognition_Frequency__c = revenueFrequency;
            if (productType == 'Hardware') {
                //product.Default_Billing_Frequency__c = 'Quarterly';
                product.Shipment_Schedule_Required__c = true;
            } else {
                product.Shipment_Schedule_Required__c = false;
            }
            productList.add(product);
            p = p + 1;
        }
        insert productList;
        return productList;
    }

    public Map<Id, PricebookEntry> initPricebook(List<Product2> productList) {
        System.debug(LoggingLevel.WARN, 'VistaAssetHelperUtil.initPricebook');
        Map<Id, PricebookEntry> pricebookEntries = new Map<Id, PricebookEntry>();
        List<PricebookEntry> pbInsertList = new List<PricebookEntry>();
        Integer pb = 0;
        while (pb < productList.size()) {
            PricebookEntry pbEntry = new PricebookEntry();
            pbEntry.Pricebook2Id = pricebookId;
            pbEntry.Product2Id = productList[pb].Id;
            pbEntry.UnitPrice = 500 * pb + 1;
            pbEntry.IsActive = true;
            pbInsertList.add(pbEntry);
            pricebookEntries.put(pbEntry.Product2Id, pbEntry);
            pb = pb + 1;
        }
        insert pbInsertList;
        return pricebookEntries;
    }

    public Opportunity createNewOpportunity(String opportunityName, Account account, String recordType, String orderType) {
        System.debug(LoggingLevel.WARN, 'VistaAssetHelperUtil.createNewOpportunity');
        Id recTypeId = [select Id from RecordType where SobjectType = 'Opportunity' and Name = :recordType].Id;
        Opportunity opportunity = new Opportunity();
        opportunity.Name = opportunityName;
        opportunity.StageName = '1 - Plan';
        opportunity.CloseDate = System.today();
        opportunity.Pricebook2Id = pricebookId;
        opportunity.AccountId = account.Id;
        opportunity.RecordTypeId = recTypeId;
        opportunity.Order_Type__c = orderType;
        opportunity.LeadSource = 'SEO';
        opportunity.Description = 'Opp Desc';
        //opportunity.Type_of_Competitor__c = 'Competitive Takeaway';
        insert opportunity;
        opportunity = [
                select Id, Name, StageName, CloseDate, AccountId, RecordTypeId, Order_Type__c
                        , LeadSource, Description
                from Opportunity
                where Id = :opportunity.Id
        ];
        return opportunity;
    }

    public SBQQ__Quote__c createSBQuote(Opportunity opportunity, Account account, Date startDate, Boolean isPrimary) {
        System.debug(LoggingLevel.WARN, 'VistaAssetHelperUtil.createSBQuote');
        SBQQ__Quote__c quote = new SBQQ__Quote__c();
        quote.SBQQ__Account__c = account.Id;
        quote.SBQQ__Opportunity2__c = opportunity.Id;
        quote.SBQQ__Primary__c = isPrimary;
        quote.SBQQ__StartDate__c = startDate;
        quote.SBQQ__SubscriptionTerm__c = 12;
        quote.ApprovalStatus__c = 'Approved';
        quote.SBQQ__Status__c = 'Accepted';
        quote.Delivery_Schedule__c = '3';
        quote.Schedule_Type__c = 'Front load';
        quote.Expected_Shipment_Start__c = Date.today() + 60;
        insert quote;
        quote = [
                select Id, SBQQ__Account__c, SBQQ__Opportunity2__c, SBQQ__Primary__c, SBQQ__StartDate__c
                        , SBQQ__SubscriptionTerm__c, ApprovalStatus__c, SBQQ__Account__r.Name
                from SBQQ__Quote__c
                where Id = :quote.Id
        ];
        return quote;
    }

    public List<SBQQ__QuoteLine__c> createSBQuoteLines(SBQQ__Quote__c sbQuote
            , Map<Id, PricebookEntry> pricebookEntries
            , boolean existing
            , Integer quantityMultiplier) {
        System.debug(LoggingLevel.WARN, 'VistaAssetHelperUtil.createSBQuoteLines');
        List<SBQQ__QuoteLine__c> sbQuoteLines = new List<SBQQ__QuoteLine__c>();
        Integer q = 1;
        for (PricebookEntry pbEntry : pricebookEntries.values()) {
            SBQQ__QuoteLine__c quoteLine = new SBQQ__QuoteLine__c();
            quoteLine.SBQQ__Quote__c = sbQuote.Id;
            quoteLine.SBQQ__Product__c = pbEntry.Product2Id;
            quoteLine.SBQQ__Quantity__c = q * quantityMultiplier;
            quoteLine.SBQQ__Existing__c = existing;
            quoteLine.SBQQ__NetPrice__c = pbEntry.UnitPrice;
            quoteline.SBQQ__RenewedAsset__c = null;
            quoteLine.SBQQ__StartDate__c = Date.today();
            quoteLine.SBQQ__EndDate__c = Date.today() +180;
            sbQuoteLines.add(quoteLine);
            q = q + 1;
        }
        insert sbQuoteLines;
        sbQuoteLines = [
                select Id, SBQQ__Quote__c, SBQQ__Product__c, SBQQ__Quantity__c, SBQQ__Existing__c, SBQQ__NetPrice__c
                        , SBQQ__Product__r.SBQQ__SubscriptionPricing__c, SBQQ__Product__r.SBQQ__SubscriptionType__c
                        , SBQQ__Product__r.Product_Type__c, SBQQ__RenewedAsset__c
                        , Annual_Recurring_Revenue__c, SBQQ__StartDate__c, SBQQ__EndDate__c, Final_Unit_Price__c
                        , SBQQ__EffectiveStartDate__c, SBQQ__EffectiveEndDate__c
                from SBQQ__QuoteLine__c
                where Id in :sbQuoteLines
        ];
        sbQuote.SBQQ__Primary__c = true;
        update sbQuote;
        return sbQuoteLines;
    }

    public List<OpportunityLineItem> createOppLineItems(Opportunity opportunity
            , List<SBQQ__Quoteline__c> quoteLines
            , Map<Id, PricebookEntry> pbEntries) {
        System.debug(LoggingLevel.WARN, 'VistaAssetHelperUtil.createOppLineItems');
        List<OpportunityLineItem> opportunityLineItems = new List<OpportunityLineItem>();
        for (SBQQ__Quoteline__c quoteLine : quoteLines) {
            OpportunityLineItem oli = new OpportunityLineItem();
            oli.SBQQ__QuoteLine__c = quoteLine.Id;
            oli.OpportunityId = opportunity.Id;
            if (quoteLine.SBQQ__Quantity__c == 0) {
                oli.Quantity = 1;
            } else {
                oli.Quantity = quoteLine.SBQQ__Quantity__c;
            }
            oli.TotalPrice = quoteLine.SBQQ__NetPrice__c;
            PricebookEntry pbe = pbEntries.get(quoteLine.SBQQ__Product__c);
            oli.PricebookEntryId = pbe.Id;
            opportunityLineItems.add(oli);
        }
        insert opportunityLineItems;
        opportunityLineItems = [
                select Id, OpportunityId, ProductCode, SBQQ__QuoteLine__c, PricebookEntryId
                        , SBQQ__QuoteLine__r.SBQQ__Group__c
                        , SBQQ__QuoteLine__r.SBQQ__Group__r.Shipping_Estimate_Summary_Exists__c
                        , SBQQ__QuoteLine__r.SBQQ__Group__r.SBQQ__Number__c, TotalPrice, Quantity
                        , SBQQ__QuoteLine__r.SBQQ__Group__r.Id, UnitPrice, ListPrice
                        , SBQQ__QuoteLine__r.SBQQ__Product__r.Default_Billing_Frequency__c
                        , SBQQ__QuoteLine__r.SBQQ__Product__r.Product_Type__c
                        , SBQQ__QuoteLine__r.SBQQ__Product__r.Forecast_Offset__c
                        , SBQQ__QuoteLine__r.SBQQ__Product__r.SBQQ__SubscriptionPricing__c
                        , SBQQ__QuoteLine__r.SBQQ__Product__r.SBQQ__SubscriptionType__c
                from OpportunityLineItem
                where Id in :opportunityLineItems
        ];
        return opportunityLineItems;
    }

    public Opportunity closeWonOpportunity(Opportunity opportunity) {
        System.debug(LoggingLevel.WARN, 'VistaAssetHelperUtil.closeWonOpportunity');
        opportunity.StageName = 'Closed Won';
        opportunity.Primary_Quote_Approval_Status__c = 'Approved';
        opportunity.Legal_Review__c = 'Approved';
        opportunity.Finance_Status__c = 'Approved';
        //opportunity.SBQQ__Contracted__c = true;
        opportunity.Closed_Won_Flag__c = true; // Used in ProcessBuilder
        update opportunity;
        return opportunity;
    }

    public List<SBQQ__Subscription__c> createSubscriptions(List<SBQQ__Quoteline__c> quoteLines, Contract contract, Account account, Id revisedSubId) {
        return createSubscriptions(quoteLines, contract, account, revisedSubId, null);
    }

    public List<SBQQ__Subscription__c> createSubscriptions(List<SBQQ__Quoteline__c> quoteLines
            , Contract contract
            , Account account
            , Id revisedSubId
            , Id renewedSubId) {
        System.debug(LoggingLevel.WARN, 'VistaAssetHelperUtil.createSubscriptions');
        List<SBQQ__Subscription__c> subscriptionList = new List<SBQQ__Subscription__c>();
        for (SBQQ__Quoteline__c quoteLine : quoteLines) {
            if (quoteLine.SBQQ__Product__r.SBQQ__SubscriptionPricing__c != null) {
                SBQQ__Subscription__c sub = new SBQQ__Subscription__c();
                sub.SBQQ__QuoteLine__c = quoteLine.Id;
                sub.SBQQ__QuoteLine__r = quoteLine;
                sub.SBQQ__Product__c = quoteLine.SBQQ__Product__r.Id;
                sub.SBQQ__Product__r = quoteLine.SBQQ__Product__r;

                if (quoteLine.SBQQ__Quantity__c == 0) {
                    sub.SBQQ__Quantity__c = 1;
                }
                else {
                    sub.SBQQ__Quantity__c = quoteLine.SBQQ__Quantity__c;
                }

                if (revisedSubId != null) {
                    sub.SBQQ__RevisedSubscription__c = revisedSubId;
                    sub.SBQQ__QuoteLine__r.SBQQ__Quantity__c = 1;
                    sub.SBQQ__QuoteLine__r.SBQQ__Existing__c = true;
                    sub.SBQQ__Product__r.Generate_Asset__c = true;
                }

                if (renewedSubId != null) {
                    sub.SBQQ__QuoteLine__r.SBQQ__RenewedSubscription__c = renewedSubId;
                    sub.SBQQ__QuoteLine__r.SBQQ__Quantity__c = 1;
                    sub.SBQQ__QuoteLine__r.SBQQ__Existing__c = true;
                    sub.SBQQ__Product__r.Generate_Asset__c = true;
                }

                sub.SBQQ__NetPrice__c = quoteLine.SBQQ__NetPrice__c;
                sub.Final_Unit_Price__c = quoteLine.SBQQ__NetPrice__c;
                sub.Annual_Recurring_Revenue__c = quoteLine.Annual_Recurring_Revenue__c;
                sub.SBQQ__SubscriptionStartDate__c = quoteLine.SBQQ__StartDate__c;
                sub.SBQQ__SubscriptionEndDate__c = quoteLine.SBQQ__EndDate__c;
                sub.SBQQ__Contract__c = contract.Id;
                sub.SBQQ__Contract__r = contract;
                sub.SBQQ__Account__c = account.Id;
                sub.SBQQ__Account__r = account;

                subscriptionList.add(sub);
            }
        }
        insert subscriptionList;
        subscriptionList = [
                SELECT Id, SBQQ__Product__c, SBQQ__ProductName__c, SBQQ__Account__c
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
                        , SBQQ__QuoteLine__r.SBQQ__Quote__r.SBQQ__Opportunity2__c
                        , SBQQ__RenewalPrice__c
                FROM SBQQ__Subscription__c
                WHERE Id IN :subscriptionList
        ];
        System.debug(LoggingLevel.WARN, 'subscriptionList1: ' + subscriptionList);
        return subscriptionList;
    }

    public Asset createSFDCAsset(SBQQ__Quoteline__c quoteLine, Account account) {
        System.debug(LoggingLevel.WARN, 'VistaAssetHelperUtil.createSFDCAsset');
        Product2 product = [select Id, Name, Description from Product2 where Id = :quoteLine.SBQQ__Product__c];
        Asset newAsset = new Asset();
        newAsset.AccountId = account.Id;
        newAsset.Name = product.Name;
        newAsset.Product2Id = quoteLine.SBQQ__Product__c;
        newAsset.Price = quoteLine.SBQQ__NetPrice__c;
        newAsset.Quantity = quoteLine.SBQQ__Quantity__c;
        newAsset.SBQQ__QuoteLine__c = quoteLine.Id;
        newAsset.SBQQ__LatestQuoteLine__c = quoteLine.Id;

        insert newAsset;
        newAsset = [
                select Id, AccountId, Name, Product2Id, Price, Quantity
                        , SBQQ__QuoteLine__c, SBQQ__QuoteLine__r.SBQQ__Quantity__c
                        , SBQQ__LatestQuoteLine__r.SBQQ__RenewedAsset__c
                        , SBQQ__LatestQuoteLine__r.SBQQ__EffectiveStartDate__c
                        , SBQQ__LatestQuoteLine__r.SBQQ__EffectiveEndDate__c
                        , SBQQ__LatestQuoteLine__r.SBQQ__Quantity__c
                from Asset
                where Id = :newAsset.Id
        ];
        return newAsset;
    }

    public SBQQ__SubscribedAsset__c createSubscribedAsset(Boolean active, Asset sfdcAsset, SBQQ__Subscription__c subscription) {
        System.debug(LoggingLevel.WARN, 'VistaAssetHelperUtil.createSubscribedAsset');
        SBQQ__SubscribedAsset__c sbSubAsset = new SBQQ__SubscribedAsset__c();
        sbSubAsset.SBQQ__Active__c = active;
        sbSubAsset.SBQQ__Asset__c = sfdcAsset.Id;
        sbSubAsset.SBQQ__Subscription__c = subscription.Id;
        //System.assert(false, 'sub during create: ' + subscription.SBQQ__QuoteLine__r.SBQQ__Quantity__c);
        insert sbSubAsset;
        sbSubAsset = [
                SELECT Id
                        , SBQQ__Active__c, SBQQ__Asset__c, SBQQ__ContractId__c, SBQQ__Subscription__c
                        , SBQQ__Asset__r.AccountId, SBQQ__Asset__r.Contract__c
                        , SBQQ__Asset__r.SBQQ__RevisedAsset__c
                        , SBQQ__Asset__r.Price, SBQQ__Asset__r.Annual_Recurring_Revenue__c
                        , SBQQ__Asset__r.Product2Id, SBQQ__Asset__r.Product2.Name
                        , SBQQ__Asset__r.Product2.Description, SBQQ__Asset__r.Product2.Generate_Asset__c
                        , SBQQ__Subscription__r.SBQQ__RevisedSubscription__c, SBQQ__Subscription__r.CurrencyIsoCode
                        , SBQQ__Subscription__r.Subscribed_Asset_Count__c
                        , SBQQ__Subscription__r.SBQQ__NetPrice__c
                        , SBQQ__Subscription__r.SBQQ__StartDate__c, SBQQ__Subscription__r.SBQQ__EndDate__c
                        , SBQQ__Asset__r.SBQQ__QuoteLine__c
                        , SBQQ__Asset__r.SBQQ__QuoteLine__r.Id, SBQQ__Asset__r.SBQQ__QuoteLine__r.SBQQ__Existing__c
                        , SBQQ__Asset__r.SBQQ__QuoteLine__r.SBQQ__RenewedSubscription__c, SBQQ__Asset__r.SBQQ__QuoteLine__r.SBQQ__Quantity__c
                        , SBQQ__Asset__r.Contract__r.StartDate, SBQQ__Asset__r.Contract__r.EndDate
                from SBQQ__SubscribedAsset__c
                where Id = :sbSubAsset.Id
        ];
        //System.assert(false, 'sub during create: ' + subscription.SBQQ__QuoteLine__r.SBQQ__Quantity__c);
        return sbSubAsset;
    }

}