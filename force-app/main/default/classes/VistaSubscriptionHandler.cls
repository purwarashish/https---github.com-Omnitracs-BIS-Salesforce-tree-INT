/* Change history
* 
* VistaSubscriptionHandler
* Created - August 2016 - Jody Crutchfield (ATG)
*
* Modified Sept. 11, 2018 by Arman Shah
* 
*/
public with sharing class VistaSubscriptionHandler {

    public static void handleSBSubscriptions(List<SBQQ__Subscription__c> subscriptionList) {
        System.debug(LoggingLevel.INFO, 'VistaSubscriptionHandler.handleSBSubscriptions');
        // Get Quote Lines for each subscription
        subscriptionList = getQuoteLineInfo(subscriptionList);
        System.debug('-- VIP: subscriptionList size = '+subscriptionList.size());

        // Separate subscription only records from subscriptions with subscribed assets
        List<SBQQ__Subscription__c> subscrNoQuoteLineList = new List<SBQQ__Subscription__c>();
        List<SBQQ__Subscription__c> newSubscrOnlyList = new List<SBQQ__Subscription__c>();
        List<SBQQ__Subscription__c> revisedSubscrOnlyList = new List<SBQQ__Subscription__c>();
        List<SBQQ__Subscription__c> renewedSubscrOnlyList = new List<SBQQ__Subscription__c>();
        List<SBQQ__Subscription__c> decomSubscrOnlyList = new List<SBQQ__Subscription__c>();

        // Check migration custom setting
        Id profId = [select Id from Profile where Name = 'System Administrator' Limit 1].Id;
        Subscription_Migration_TF__c migrationAllowed = Subscription_Migration_TF__c.getInstance(profId);
        Boolean migrateBool = migrationAllowed.Migration_Allowed__c;
        System.debug(LoggingLevel.WARN, 'migration flag: ' + migrateBool);
        for (SBQQ__Subscription__c subscr : subscriptionList) {
            if (migrateBool && subscr.SBQQ__QuoteLine__c == null && subscr.SBQQ__Product__r.Generate_Asset__c == true) {
                subscrNoQuoteLineList.add(subscr);
            }
            else {
                System.debug(' *** VistaSubscriptionHandler.handleSBSubscriptions GenAsset: [' + subscr.SBQQ__Product__r.Generate_Asset__c + ']');
                System.debug(' *** VistaSubscriptionHandler.handleSBSubscriptions Existing: [' + subscr.SBQQ__QuoteLine__r.SBQQ__Existing__c + ']');
                System.debug(' *** VistaSubscriptionHandler.handleSBSubscriptions Quantity: [' + subscr.SBQQ__QuoteLine__r.SBQQ__Quantity__c + ']');
                System.debug(' *** VistaSubscriptionHandler.handleSBSubscriptions Renewed: [' + subscr.SBQQ__QuoteLine__r.SBQQ__RenewedSubscription__c + ']');
                System.debug(' *** VistaSubscriptionHandler.handleSBSubscriptions Revised: [' + subscr.SBQQ__RevisedSubscription__c + ']');

                if (subscr.SBQQ__Product__r.Generate_Asset__c == true) {
                    if (subscr.SBQQ__QuoteLine__r.SBQQ__Existing__c == true) {
                        if (subscr.SBQQ__QuoteLine__r.SBQQ__Quantity__c > 0) {
                            if (subscr.SBQQ__RevisedSubscription__c != null) {
                                revisedSubscrOnlyList.add(subscr);
                            }
                            else if (subscr.SBQQ__QuoteLine__r.SBQQ__RenewedSubscription__c != null) {
                                renewedSubscrOnlyList.add(subscr);
                            }
                        }
                        else {
                            decomSubscrOnlyList.add(subscr);
                        }
                    } else {
                        if (subscr.SBQQ__QuoteLine__r.SBQQ__Quantity__c > 0) {
                            if (subscr.SBQQ__QuoteLine__r.SBQQ__RenewedSubscription__c == null) {
                                newSubscrOnlyList.add(subscr);
                            }
                            else {
                                renewedSubscrOnlyList.add(subscr);
                            }
                        }
                    }
                }
            }
        }

        /* process the subscription only records */
        List<Customer_Asset__c> insertAssetList = new List<Customer_Asset__c>();
        List<Customer_Asset__c> modifiedAssetList = new List<Customer_Asset__c>();
        // create new vista assets for subscriptions that do not have quote lines
        if (subscrNoQuoteLineList.size() > 0) {
            for (SBQQ__Subscription__c subscrNoQL : subscrNoQuoteLineList) {
                insertAssetList.add(createVistaAssetWithoutQuoteLines(subscrNoQL));
            }
        }
        // Create new vista assets for new subscriptions
        if (newSubscrOnlyList.size() > 0) {
            for (SBQQ__Subscription__c subscrOnly : newSubscrOnlyList) {
                insertAssetList.add(createVistaAssetForSubscription(subscrOnly));
            }
        }
        // Update vista assets for existing quote line records
        if (revisedSubscrOnlyList.size() > 0) {
            // get existing vista assets for subscrs
            Map<SBQQ__Subscription__c, Customer_Asset__c> revisedAssetSubscrMap = new Map<SBQQ__Subscription__c, Customer_Asset__c>();
            revisedAssetSubscrMap = getVistaAssetsForRevisedSubscriptions(revisedSubscrOnlyList);
            System.debug('-- revisedAssetSubscrMap.size = '+revisedAssetSubscrMap.size());
            modifiedAssetList.addAll(updateVistaAssetForSubscription(revisedAssetSubscrMap, 'modified'));
            System.debug('-- REVISED SUB modifiedAssetList.size = '+modifiedAssetList.size());
        }
        if (renewedSubscrOnlyList.size() > 0) {
            // get existing vista assets for subscrs
            Map<SBQQ__Subscription__c, Customer_Asset__c> renewedAssetSubscrMap = new Map<SBQQ__Subscription__c, Customer_Asset__c>();
            System.debug('-- renewedSubscrOnlyList.size = '+renewedSubscrOnlyList.size());
            renewedAssetSubscrMap = getVistaAssetsForRenewedSubscriptions(renewedSubscrOnlyList);
            System.debug('-- renewedAssetSubscrMap.size = '+renewedAssetSubscrMap.size());
            modifiedAssetList.addAll(updateVistaAssetForSubscription(renewedAssetSubscrMap, 'renewed'));
            System.debug('-- RENEWED SUB modifiedAssetList.size = '+modifiedAssetList.size());
        }
        // Decom vista assets for existing quote lines with new quantity of 0
        if (decomSubscrOnlyList.size() > 0) {
            // get existing vista assets for subscrs
            List<Customer_Asset__c> decomAssetSubscrList = new List<Customer_Asset__c>();
            decomAssetSubscrList.addAll(getVistaAssetsForDecomSubscriptions(decomSubscrOnlyList));
            for (Customer_Asset__c asset : decomAssetSubscrList) {
                modifiedAssetList.add(decomVistaAssetForSubscription(asset));
            }
            System.debug('-- DECOM SUB modifiedAssetList.size = '+modifiedAssetList.size());
        }

        insert insertAssetList;
        System.debug('-- FINAL insertAssetList.size = '+insertAssetList.size());
        update modifiedAssetList;
        System.debug('-- FINAL modifiedAssetList.size = '+modifiedAssetList.size());
    }

    private static List<SBQQ__Subscription__c> getQuoteLineInfo(List<SBQQ__Subscription__c> subscriptionList) {
        System.debug(LoggingLevel.INFO, 'VistaSubscriptionHandler.getQuoteLineInfo');
        // Get Quote Line info for each subscription
        List<SBQQ__Subscription__c> newSubList = new List<SBQQ__Subscription__c>();
        newSubList = [
                SELECT Id, SBQQ__Product__c, SBQQ__Account__c, SBQQ__Contract__c, SBQQ__StartDate__c, SBQQ__EndDate__c
                        , SBQQ__NetPrice__c, SBQQ__Product__r.Name, SBQQ__Product__r.Description, SBQQ__Product__r.Default_Billing_Frequency__c
                        , SBQQ__Product__r.Generate_Asset__c, Annual_Recurring_Revenue__c, ARR__c
                        , SBQQ__Quantity__c, SBQQ__QuoteLine__r.Id, SBQQ__QuoteLine__c, SBQQ__QuoteLine__r.Final_Unit_Price__c
                        , SBQQ__QuoteLine__r.SBQQ__Existing__c, SBQQ__QuoteLine__r.SBQQ__RenewedSubscription__c, CurrencyIsoCode
                        , SBQQ__QuoteLine__r.SBQQ__Quantity__c, SBQQ__RevisedSubscription__c, SBQQ__RevisedSubscription__r.Id
                        , SBQQ__QuoteLine__r.SBQQ__RenewedSubscription__r.Id
                        , SBQQ__Contract__r.Master_Term__c, SBQQ__Contract__r.Master_Term_Remaining__c, SBQQ__QuoteLine__r.Oracle_Id__c
                        , SBQQ__QuoteLine__r.SBQQ__Quote__r.SBQQ__Opportunity2__r.Id
                        , Final_Unit_Price__c, SBQQ__QuoteLine__r.SBQQ__RenewedSubscription__r.SBQQ__Contract__r.Master_Term_Remaining__c
                        , SBQQ__RenewalPrice__c
                FROM SBQQ__Subscription__c
                WHERE Id IN :subscriptionList
        ];
        return newSubList;
    }

    private static List<Customer_Asset__c> getVistaAssetsForDecomSubscriptions(List<SBQQ__Subscription__c> subscriptionList) {
        System.debug(LoggingLevel.INFO, 'VistaSubscriptionHandler.getVistaAssetsForDecomSubscriptions');
        System.debug(LoggingLevel.INFO, 'Getting assets for existing subscriptions: ' + subscriptionList);
        // Get vista asset for each subscription
        // Asset will be related to the previous asset in the SBQQ__RevisedSubscription__c field
        // Renewals will not have a revised subscription
        List<SBQQ__Subscription__c> revisedSubscrList = new List<SBQQ__Subscription__c>();
        List<Customer_Asset__c> existingAssetList = new List<Customer_Asset__c>();
        List<Customer_Asset__c> finalAssetList = new List<Customer_Asset__c>();
        List<Id> subscrIdList = new List<Id>();
        List<Id> revisedSubscrIdList = new List<Id>();
        for (SBQQ__Subscription__c subscr : subscriptionList) {
            subscrIdList.add(subscr.Id);
        }
        revisedSubscrList = [
                SELECT Id, SBQQ__RevisedSubscription__c, SBQQ__QuoteLine__r.SBQQ__RenewedSubscription__c
                FROM SBQQ__Subscription__c
                WHERE Id in :subscrIdList
        ];
        for (SBQQ__Subscription__c revsubscr : revisedSubscrList) {
            if (revsubscr.SBQQ__RevisedSubscription__c != null) {
                revisedSubscrIdList.add(revsubscr.SBQQ__RevisedSubscription__c);
            }
            else if (revsubscr.SBQQ__QuoteLine__r.SBQQ__RenewedSubscription__c != null) {
                revisedSubscrIdList.add(revsubscr.SBQQ__QuoteLine__r.SBQQ__RenewedSubscription__c);
            }
            else {
                revisedSubscrIdList.add(revsubscr.Id);
            }
        }
        existingAssetList = [
                SELECT Id, Name, Account__c, Product__c, Description__c, Contract__c, Term_Start_Date__c, Term_End_Date__c
                        , Asset_Status__c, Quantity__c, Annual_Recurring_Revenue__c, Steelbrick_Subscription__c
                        /*, Total_One_Time_Fee_s__c, ARR__c*/
                        , Steelbrick_Subscription__r.SBQQ__Contract__c
                        , Steelbrick_Subscription__r.SBQQ__StartDate__c, Steelbrick_Subscription__r.SBQQ__EndDate__c
                        , Steelbrick_Subscription__r.SBQQ__QuoteLine__r.SBQQ__Quantity__c
                        , Steelbrick_Subscription__r.SBQQ__QuoteLine__r.SBQQ__RenewedSubscription__c
                        , Steelbrick_Subscription__r.SBQQ__NetPrice__c, Steelbrick_Subscription__r.CurrencyIsoCode
                        , Steelbrick_Subscription__r.Annual_Recurring_Revenue__c
                        , Steelbrick_Subscription__r.SBQQ__RevisedSubscription__c
                        , Contract__r.Master_Term__c, Contract__r.Master_Term_Remaining__c, Latest_Opportunity__c, Latest_Quote_Line__c
                FROM Customer_Asset__c
                WHERE Steelbrick_Subscription__c IN :revisedSubscrIdList
        ];
        return existingAssetList;
    }

    @TestVisible
    private static Map<SBQQ__Subscription__c, Customer_Asset__c> getVistaAssetsForRevisedSubscriptions(List<SBQQ__Subscription__c> subscriptionList) {
        System.debug(LoggingLevel.INFO, 'VistaSubscriptionHandler.getVistaAssetsForRevisedSubscriptions');
        System.debug(LoggingLevel.INFO, 'Getting assets for existing subscriptions: ' + subscriptionList);
        // Get vista asset for each subscription
        // Asset will be related to the previous asset in the SBQQ__RevisedSubscription__c field
        // Renewals will not have a revised subscription
        List<Customer_Asset__c> existingAssetList = new List<Customer_Asset__c>();
        Map<Id, SBQQ__Subscription__c> revisedSubSubMap = new Map<Id, SBQQ__Subscription__c>();
        Map<SBQQ__Subscription__c, Customer_Asset__c> subCustAssetMap = new Map<SBQQ__Subscription__c, Customer_Asset__c>();

        for (SBQQ__Subscription__c subscr : subscriptionList) {
            revisedSubSubMap.put(subscr.SBQQ__RevisedSubscription__c, subscr);
        }
        System.debug(LoggingLevel.INFO, '-- revisedSubSubMap = '+revisedSubSubMap);

        existingAssetList = [
                SELECT Id, Name, Account__c, Product__c, Description__c, Contract__c, Term_Start_Date__c, Term_End_Date__c
                        , Asset_Status__c, Quantity__c, Annual_Recurring_Revenue__c, Steelbrick_Subscription__c
                        /*, Total_One_Time_Fee_s__c, ARR__c*/
                        , Steelbrick_Subscription__r.SBQQ__Contract__c
                        , Steelbrick_Subscription__r.SBQQ__StartDate__c, Steelbrick_Subscription__r.SBQQ__EndDate__c
                        , Steelbrick_Subscription__r.SBQQ__QuoteLine__r.SBQQ__Quantity__c
                        , Steelbrick_Subscription__r.SBQQ__QuoteLine__r.SBQQ__RenewedSubscription__c
                        , Steelbrick_Subscription__r.SBQQ__NetPrice__c, Steelbrick_Subscription__r.CurrencyIsoCode
                        , Steelbrick_Subscription__r.Annual_Recurring_Revenue__c
                        , Steelbrick_Subscription__r.SBQQ__RevisedSubscription__c
                        , Contract__r.Master_Term__c, Contract__r.Master_Term_Remaining__c, Latest_Opportunity__c, Latest_Quote_Line__c
                        , Steelbrick_Subscription__r.SBQQ__QuoteLine__r.SBQQ__Quote__r.SBQQ__Opportunity2__c
                        , Steelbrick_Asset__r.SBQQ__QuoteLine__c
                FROM Customer_Asset__c
                WHERE Steelbrick_Subscription__c IN :revisedSubSubMap.keySet()
        ];
        System.debug(LoggingLevel.INFO, '-- existingAssetList = '+existingAssetList);

        for (Customer_Asset__c custAsset : existingAssetList) {
            subCustAssetMap.put(revisedSubSubMap.get(custAsset.Steelbrick_Subscription__c), custAsset);
        }
        return subCustAssetMap;
    }

    @TestVisible
    private static Map<SBQQ__Subscription__c, Customer_Asset__c> getVistaAssetsForRenewedSubscriptions(List<SBQQ__Subscription__c> subscriptionList) {
        System.debug(LoggingLevel.INFO, 'VistaSubscriptionHandler.getVistaAssetsForRenewedSubscriptions');
        System.debug(LoggingLevel.INFO, 'Getting assets for existing subscriptions: ' + subscriptionList);
        // Get vista asset for each subscription
        // Asset will be related to the previous asset in the SBQQ__RevisedSubscription__c field
        // Renewals will not have a revised subscription
        List<Customer_Asset__c> existingAssetList = new List<Customer_Asset__c>();
        Map<Id, SBQQ__Subscription__c> renewedSubSubMap = new Map<Id, SBQQ__Subscription__c>();
        Map<SBQQ__Subscription__c, Customer_Asset__c> subCustAssetMap = new Map<SBQQ__Subscription__c, Customer_Asset__c>();

        for (SBQQ__Subscription__c subscr : subscriptionList) {
            renewedSubSubMap.put(subscr.SBQQ__QuoteLine__r.SBQQ__RenewedSubscription__c, subscr);
        }
        System.debug(LoggingLevel.INFO, '-- renewedSubSubMap = '+renewedSubSubMap);

        existingAssetList = [
                SELECT Id, Name, Account__c, Product__c, Description__c, Contract__c, Term_Start_Date__c, Term_End_Date__c
                        , Asset_Status__c, Quantity__c, Annual_Recurring_Revenue__c, Steelbrick_Subscription__c
                        /*, Total_One_Time_Fee_s__c, ARR__c*/
                        , Steelbrick_Subscription__r.SBQQ__Contract__c
                        , Steelbrick_Subscription__r.SBQQ__StartDate__c, Steelbrick_Subscription__r.SBQQ__EndDate__c
                        , Steelbrick_Subscription__r.SBQQ__QuoteLine__r.SBQQ__Quantity__c
                        , Steelbrick_Subscription__r.SBQQ__QuoteLine__r.SBQQ__RenewedSubscription__c
                        , Steelbrick_Subscription__r.SBQQ__NetPrice__c, Steelbrick_Subscription__r.CurrencyIsoCode
                        , Steelbrick_Subscription__r.Annual_Recurring_Revenue__c
                        , Steelbrick_Subscription__r.SBQQ__RevisedSubscription__c
                        , Contract__r.Master_Term__c, Contract__r.Master_Term_Remaining__c, Latest_Opportunity__c, Latest_Quote_Line__c
                        , Steelbrick_Subscription__r.SBQQ__QuoteLine__r.SBQQ__Quote__r.SBQQ__Opportunity2__c
                        , Steelbrick_Asset__r.SBQQ__QuoteLine__c
                FROM Customer_Asset__c
                WHERE Steelbrick_Subscription__c IN :renewedSubSubMap.keySet()
        ];
        System.debug(LoggingLevel.INFO, '-- existingAssetList = '+existingAssetList);

        for (Customer_Asset__c custAsset : existingAssetList) {
            subCustAssetMap.put(renewedSubSubMap.get(custAsset.Steelbrick_Subscription__c), custAsset);
        }
        return subCustAssetMap;
    }

    @TestVisible
    private static Customer_Asset__c createVistaAssetForSubscription(SBQQ__Subscription__c subscription) {
        System.debug(LoggingLevel.INFO, 'VistaSubscriptionHandler.createVistaAssetForSubscription');
        System.debug(LoggingLevel.INFO, '>>>>>DEBUG - Creating Asset for Subscription: ' + subscription);
        Customer_Asset__c vistaAsset = new Customer_Asset__c();
        vistaAsset.Product__c = subscription.SBQQ__Product__c;
        vistaAsset.Name = (subscription.SBQQ__Product__r.Name.length() > 79 ? subscription.SBQQ__Product__r.Name.substring(0, 79) : subscription.SBQQ__Product__r.Name);
        vistaAsset.Description__c = subscription.SBQQ__Product__r.Description;
        vistaAsset.Account__c = subscription.SBQQ__Account__c;
        vistaAsset.Contract__c = subscription.SBQQ__Contract__c;
        vistaAsset.Term_Start_Date__c = subscription.SBQQ__StartDate__c;
        if (subscription.SBQQ__Contract__r.Master_Term_Remaining__c > 0) {
            vistaAsset.Term_End_Date__c = subscription.SBQQ__EndDate__c.addMonths(Integer.valueOf(subscription.SBQQ__Contract__r.Master_Term_Remaining__c));
        }
        else {
            vistaAsset.Term_End_Date__c = subscription.SBQQ__EndDate__c;
        }
        vistaAsset.Asset_Status__c = 'Active';
        vistaAsset.Quantity__c = subscription.SBQQ__QuoteLine__r.SBQQ__Quantity__c;
        // vistaAsset.Total_One_Time_Fee_s__c = subscription.Final_Unit_Price__c;
        // vistaAsset.ARR__c = calculateTotalARR(subscription.SBQQ__Quantity__c, subscription.Final_Unit_Price__c, subscription.SBQQ__Product__r.Default_Billing_Frequency__c);

        vistaAsset.Annual_Recurring_Revenue__c = calculateTotalARR(subscription.SBQQ__Quantity__c, subscription.Final_Unit_Price__c, subscription.SBQQ__Product__r.Default_Billing_Frequency__c);
        vistaAsset.Steelbrick_Subscription__c = subscription.Id;
        vistaAsset.CurrencyIsoCode = subscription.CurrencyIsoCode;
        vistaAsset.Oracle_Id__c = subscription.SBQQ__QuoteLine__r.Oracle_Id__c;
        vistaAsset.Latest_Opportunity__c = subscription.SBQQ__QuoteLine__r.SBQQ__Quote__r.SBQQ__Opportunity2__c;
        vistaAsset.Latest_Quote_Line__c = subscription.SBQQ__QuoteLine__c;
        System.debug(LoggingLevel.INFO, '>>>>>DEBUG - Returning asset for create: ' + vistaAsset);
        return vistaAsset;
    }

    public static List<Customer_Asset__c> updateVistaAssetForSubscription(Map<SBQQ__Subscription__c, Customer_Asset__c> subAssetMap, String changeType) {
        System.debug(LoggingLevel.INFO, 'VistaSubscriptionHandler.updateVistaAssetForSubscription');
        System.debug('-- changeType = '+changeType);
        List<Customer_Asset__c> vistaAssetList = new List<Customer_Asset__c>();
        for (SBQQ__Subscription__c sub : subAssetMap.keySet()) {
            Customer_Asset__c vistaAsset = subAssetMap.get(sub);
            if (changeType == 'renewed') {
                System.debug('-- ************ RENEWED CONTRACT ************* --');
                System.debug(LoggingLevel.INFO, '-- sub.Final_Unit_Price__c = '+sub.Final_Unit_Price__c);
                System.debug(LoggingLevel.INFO, '-- sub.SBQQ__RenewalPrice__c = '+sub.SBQQ__RenewalPrice__c);

                vistaAsset.Steelbrick_Subscription__c = sub.Id;

                vistaAsset.Contract__c = sub.SBQQ__Contract__c;
                vistaAsset.Term_Start_Date__c = sub.SBQQ__StartDate__c;
                if (sub.SBQQ__Contract__r.Master_Term_Remaining__c > 0) {
                    vistaAsset.Term_End_Date__c = sub.SBQQ__EndDate__c.addMonths(Integer.valueOf(sub.SBQQ__Contract__r.Master_Term_Remaining__c));
                }
                else {
                    vistaAsset.Term_End_Date__c = sub.SBQQ__EndDate__c;
                }
                vistaAsset.Quantity__c = sub.SBQQ__Quantity__c;

                /* ARMAN: vistaAsset.Total_One_Time_Fee_s__c = sub.SBQQ__RenewalPrice__c;  // "Price" field, using value from latest Subscription
                System.debug(LoggingLevel.INFO, '-- vistaAsset.Total_One_Time_Fee_s__c = '+vistaAsset.Total_One_Time_Fee_s__c);
                */

                vistaAsset.Annual_Recurring_Revenue__c =
                        calculateTotalARR(sub.SBQQ__Quantity__c, sub.SBQQ__RenewalPrice__c,
                                sub.SBQQ__Product__r.Default_Billing_Frequency__c);
                /* ARMAN: vistaAsset.ARR__c = vistaAsset.Annual_Recurring_Revenue__c; // already calculated
                System.debug(LoggingLevel.INFO, '-- vistaAsset.ARR__c = '+vistaAsset.ARR__c); */
            }
            else {
                vistaAsset.Contract__c = vistaAsset.Steelbrick_Subscription__r.SBQQ__Contract__c;
                vistaAsset.Term_Start_Date__c = vistaAsset.Steelbrick_Subscription__r.SBQQ__StartDate__c;
                if (vistaAsset.Contract__r.Master_Term_Remaining__c > 0) {
                    vistaAsset.Term_End_Date__c = vistaAsset.Steelbrick_Subscription__r.SBQQ__EndDate__c.addMonths(Integer.valueOf(vistaAsset.Contract__r.Master_Term_Remaining__c));
                }
                else {
                    vistaAsset.Term_End_Date__c = vistaAsset.Steelbrick_Subscription__r.SBQQ__EndDate__c;
                }
                vistaAsset.Quantity__c = vistaAsset.Quantity__c + sub.SBQQ__Quantity__c;
                // vistaAsset.Total_One_Time_Fee_s__c = sub.Final_Unit_Price__c;
                if (sub.Annual_Recurring_Revenue__c != null && vistaAsset.Annual_Recurring_Revenue__c != null) {
                    vistaAsset.Annual_Recurring_Revenue__c = calculateTotalARR(vistaAsset.Quantity__c, sub.Final_Unit_Price__c, sub.SBQQ__Product__r.Default_Billing_Frequency__c);
                }
                /* ARMAN: if (sub.ARR__c != null && vistaAsset.ARR__c != null) {
                    vistaAsset.ARR__c = calculateTotalARR(vistaAsset.Quantity__c, sub.Final_Unit_Price__c, sub.SBQQ__Product__r.Default_Billing_Frequency__c);
                }*/
            }
            vistaAsset.CurrencyIsoCode = vistaAsset.Steelbrick_Subscription__r.CurrencyIsoCode;
            vistaAsset.Latest_Opportunity__c = sub.SBQQ__QuoteLine__r.SBQQ__Quote__r.SBQQ__Opportunity2__c;
            vistaAsset.Latest_Quote_Line__c = sub.SBQQ__QuoteLine__c;
            vistaAssetList.add(vistaAsset);
        }
        return vistaAssetList;
    }

    public static Customer_Asset__c decomVistaAssetForSubscription(Customer_Asset__c vistaAsset) {
        System.debug(LoggingLevel.INFO, 'VistaSubscriptionHandler.decomVistaAssetForSubscription');
        System.debug(LoggingLevel.INFO, '>>>>>DEBUG - Decommission Asset: ' + vistaAsset);
        vistaAsset.Contract__c = vistaAsset.Steelbrick_Subscription__r.SBQQ__Contract__c;
        vistaAsset.Decommission_Effective_Date__c = vistaAsset.Steelbrick_Subscription__r.SBQQ__StartDate__c;
        vistaAsset.Term_Start_Date__c = vistaAsset.Steelbrick_Subscription__r.SBQQ__StartDate__c;
        if (vistaAsset.Contract__r.Master_Term_Remaining__c > 0) {
            vistaAsset.Term_End_Date__c = vistaAsset.Steelbrick_Subscription__r.SBQQ__EndDate__c.addMonths(Integer.valueOf(vistaAsset.Contract__r.Master_Term_Remaining__c));
        }
        else {
            vistaAsset.Term_End_Date__c = vistaAsset.Steelbrick_Subscription__r.SBQQ__EndDate__c;
        }
        if (vistaAsset.Steelbrick_Subscription__r.SBQQ__StartDate__c <= Date.today()) {
            vistaAsset.Asset_Status__c = 'Decommissioned';
        }
        return vistaAsset;
    }

    public static Customer_Asset__c createVistaAssetWithoutQuoteLines(SBQQ__Subscription__c subscription) {
        System.debug(LoggingLevel.INFO, 'VistaSubscriptionHandler.createVistaAssetWithoutQuoteLines');
        System.debug(LoggingLevel.INFO, '>>>>>DEBUG - Creating Asset for Subscription: ' + subscription);
        Customer_Asset__c vistaAsset = new Customer_Asset__c();
        vistaAsset.Name = (subscription.SBQQ__Product__r.Name.length() > 79 ? subscription.SBQQ__Product__r.Name.substring(0, 79) : subscription.SBQQ__Product__r.Name);
        vistaAsset.Account__c = subscription.SBQQ__Account__c;
        vistaAsset.Account__c = subscription.SBQQ__Account__c;
        vistaAsset.Product__c = subscription.SBQQ__Product__c;
        vistaAsset.Description__c = subscription.SBQQ__Product__r.Description;
        vistaAsset.Contract__c = subscription.SBQQ__Contract__c;
        vistaAsset.Term_Start_Date__c = subscription.SBQQ__StartDate__c;
        if (subscription.SBQQ__Contract__r.Master_Term_Remaining__c != null) {
            vistaAsset.Term_End_Date__c = subscription.SBQQ__EndDate__c.addMonths(Integer.valueOf(subscription.SBQQ__Contract__r.Master_Term_Remaining__c));
        }
        else {
            vistaAsset.Term_End_Date__c = subscription.SBQQ__EndDate__c;
        }
        vistaAsset.Asset_Status__c = 'Active';
        vistaAsset.Quantity__c = subscription.SBQQ__Quantity__c;
        // vistaAsset.Total_One_Time_Fee_s__c = subscription.Final_Unit_Price__c;
        vistaAsset.Annual_Recurring_Revenue__c = calculateTotalARR(subscription.SBQQ__Quantity__c, subscription.Final_Unit_Price__c, subscription.SBQQ__Product__r.Default_Billing_Frequency__c);
        // vistaAsset.ARR__c = calculateTotalARR(subscription.SBQQ__Quantity__c, subscription.Final_Unit_Price__c, subscription.SBQQ__Product__r.Default_Billing_Frequency__c);
        vistaAsset.Steelbrick_Subscription__c = subscription.Id;
        vistaAsset.CurrencyIsoCode = subscription.CurrencyIsoCode;
        System.debug(LoggingLevel.INFO, '>>>>>DEBUG - Returning asset for create: ' + vistaAsset);
        return vistaAsset;
    }

    private static Decimal calculateTotalARR(Decimal quantity, Decimal unitPrice, String defaultBillFreq) {
        System.debug('VistaSubscriptionHandler.calculateTotalARR');
        Decimal retARR = 0.00;

        if (quantity == null || unitPrice == null || String.isBlank(defaultBillFreq)) {
            return 0;
        }
        else if (defaultBillFreq == 'Once') {
            retARR = quantity * unitPrice;
        }
        else if (defaultBillFreq == 'Monthly') {
            retARR = quantity * unitPrice * 12;
        }
        else if (defaultBillFreq == 'Quarterly') {
            retARR = quantity * unitPrice * 4;
        }
        else if (defaultBillFreq == 'Annual') {
            retARR = quantity * unitPrice;
        }

        return retArr;
    }
}