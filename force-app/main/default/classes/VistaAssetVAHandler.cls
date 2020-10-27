/* Change history
* 
* VistaSubAssetHandler
* Created - August 2016 - Jody Crutchfield (ATG)
* 
* Date - Who - What
* 
* 
*/
public with sharing class VistaAssetVAHandler {
    public static Boolean firstRun = true;
    
    /**
* Entry point for triggers coming from the Asset Trigger Handlers. 
*/
    public static void handleAssetsVA(List<Asset> assetList) {
        System.debug(LoggingLevel.INFO, 'VistaAssetVAHandler.handleAssetsVA');

        // Get Quote Lines for each asset
        System.debug('starting assetList: ' + assetList);
        assetList = getQuoteLineInfo(assetList);
        System.debug('assetList: ' + assetList);

        // Separate subscribed assets into working groups
        List<Asset> newAssetOnlyList = new List<Asset>();
        List<Asset> upgradedAssetOnlyList = new List<Asset>();
        List<Asset> renewedAssetOnlyList = new List<Asset>();
        List<Asset> decomAssetOnlyList = new List<Asset>();
        Map<Id, String> assetProcessedMap = new Map<Id, String>();
        List<Asset> assetWVAssetsList = new List<Asset>();
        List<Customer_Asset__c> insertVistaAssetList = new List<Customer_Asset__c>();
        List<Customer_Asset__c> modifiedVistaAssetList = new List<Customer_Asset__c>();
        for (Asset asset : assetList) {
            if (asset.Product2.Generate_Asset__c == true) {
                System.debug('current asset: ' + asset);
                Boolean currentExist = asset.SBQQ__LatestQuoteLine__r.SBQQ__Existing__c;
                System.debug('currentExist: ' + currentExist);
                // separate existing assets from new assets
                if (asset.SBQQ__LatestQuoteLine__r.SBQQ__Quantity__c != null && asset.SBQQ__LatestQuoteLine__r.SBQQ__Quantity__c != 0) {
                    if (asset.SBQQ__LatestQuoteLine__r.SBQQ__RenewedAsset__c != null) {
                        renewedAssetOnlyList.add(asset);
                    } else if (asset.SBQQ__LatestQuoteLine__r.SBQQ__UpgradedAsset__c != null) {
                        upgradedAssetOnlyList.add(asset);
                    } else {
                        newAssetOnlyList.add(asset);
                    }
                } else {
                    decomAssetOnlyList.add(asset);
                }
            }
        }
        List<Customer_Asset__c> updateVistaAssetList = new List<Customer_Asset__c>();
        List<Customer_Asset__c> decomVistaAssetList = new List<Customer_Asset__c>();
// prep new assets for vista asset creation
//
        if (newAssetOnlyList.size() > 0) {
            for (Asset newAsset : newAssetOnlyList) {
                insertVistaAssetList.add(createVistaAssetForAsset(newAsset));
            }
        }
// prep existing vista assets for update
        if (renewedAssetOnlyList.size() > 0) {
// get vista assets to update
            Map<Asset, Customer_Asset__c> renewedAssetAssetMap = new Map<Asset, Customer_Asset__c>();
            renewedAssetAssetMap = getVistaAssetsForRenewedAssets(renewedAssetOnlyList);
            modifiedVistaAssetList.addAll(updateVistaAssetForAsset(renewedAssetAssetMap));
        }
        if (upgradedAssetOnlyList.size() > 0) {
// get vista assets to update
            Map<Asset, Customer_Asset__c> upgradedAssetAssetMap = new Map<Asset, Customer_Asset__c>();
            upgradedAssetAssetMap = getVistaAssetsForUpgradedAssets(upgradedAssetOnlyList);
            modifiedVistaAssetList.addAll(updateVistaAssetForAsset(upgradedAssetAssetMap));
        }
// prep existing vista assets for decom
        if (decomAssetOnlyList.size() > 0) {
// get vista assets to decom
            decomVistaAssetList.addAll(getVistaAssetsForAssets(decomAssetOnlyList));
// update vista assets
            for (Customer_Asset__c decomAsset : decomVistaAssetList) {
                modifiedVistaAssetList.add(decomVistaAssetForAsset(decomAsset));
            }
        }
        insert insertVistaAssetList;
        update modifiedVistaAssetList;
    }

    private static List<Asset> getQuoteLineInfo(List<Asset> assetList) {
        System.debug(LoggingLevel.INFO, 'VistaAssetVAHandler.getQuoteLineInfo');
// Get Quote Line info for each asset
        List<Asset> newAssetList = new List<Asset>();
        List<Id> assetIdList = new List<Id>();
        for (Asset asset : assetList) {
            assetIdList.add(asset.Id);
        }
        newAssetList = [
                SELECT Id
                        , AccountId, Name, Description, CurrencyIsoCode
                        , InstallDate, Price, Product2Id, Product2.Name
                        , Product2.Description, Product2.Generate_Asset__c, Quantity, Status, UsageEndDate
                        , Annual_Recurring_Revenue__c
                        , SBQQ__LatestQuoteLine__c, SBQQ__LatestQuoteLine__r.Id, SBQQ__LatestQuoteLine__r.SBQQ__Existing__c
                        , SBQQ__LatestQuoteLine__r.SBQQ__RenewedAsset__c, SBQQ__LatestQuoteLine__r.SBQQ__Quantity__c
                        , SBQQ__RevisedAsset__c, SBQQ__RevisedAsset__r.Quantity
                        , SBQQ__LatestQuoteLine__r.SBQQ__EffectiveStartDate__c, SBQQ__LatestQuoteLine__r.SBQQ__EffectiveEndDate__c
                        , SBQQ__LatestQuoteLine__r.SBQQ__UpgradedAsset__c
                        , SBQQ__LatestQuoteLine__r.Oracle_Id__c, SBQQ__LatestQuoteLine__r.SBQQ__Quote__r.SBQQ__Opportunity2__c
                        , SBQQ__LatestQuoteLine__r.SBQQ__UpgradedAsset__r.Id
                , SBQQ__LatestQuoteLine__r.Final_Unit_Price__c
                FROM Asset
                WHERE Id IN :assetIdList
        ];
        return newAssetList;
    }

    public static List<Customer_Asset__c> getVistaAssetsForAssets(List<Asset> assetList) {
        System.debug(LoggingLevel.INFO, 'VistaAssetVAHandler.getVistaAssetsForAssets');
// Get vista asset for each asset
        List<Asset> revisedAssetList = new List<Asset>();
        List<Customer_Asset__c> existingAssetList = new List<Customer_Asset__c>();
        List<Customer_Asset__c> finalAssetList = new List<Customer_Asset__c>();
        List<Id> assetIdList = new List<Id>();
        List<Id> revisedAssetIdList = new List<Id>();

        for (Asset asset : assetList) {
            if (asset.SBQQ__LatestQuoteLine__r.SBQQ__Existing__c == true) {
                assetIdList.add(asset.Id);
            }
        }
        revisedAssetList = [
                SELECT Id, SBQQ__RevisedAsset__c
                FROM Asset
                WHERE Id in :assetIdList
        ];

        for (Asset revasset : revisedAssetList) {
            if (revAsset.SBQQ__RevisedAsset__c != null) {
                revisedAssetIdList.add(revAsset.SBQQ__RevisedAsset__c);
            } else {
                revisedAssetIdList.add(revAsset.Id);
            }
        }
        existingAssetList = [
                SELECT
// vista asset fields
                        Id, Name, Account__c, Product__c, Description__c, Contract__c
                        , Term_Start_Date__c, Term_End_Date__c, Asset_Status__c, Quantity__c
                        , Annual_Recurring_Revenue__c, Steelbrick_Subscription__c, Steelbrick_Asset__c
                        /*, Total_One_Time_Fee_s__c*/
// subscribed asset fields
                        , Steelbrick_Asset__r.SBQQ__CurrentSubscription__c, Steelbrick_Asset__r.Price
// subscribed asset subscription fields
                        , Steelbrick_Asset__r.SBQQ__CurrentSubscription__r.SBQQ__QuoteLine__r.SBQQ__Quantity__c
                        , Steelbrick_Asset__r.SBQQ__CurrentSubscription__r.SBQQ__NetPrice__c
                        , Steelbrick_Asset__r.SBQQ__CurrentSubscription__r.CurrencyIsoCode
                        , Steelbrick_Asset__r.SBQQ__CurrentSubscription__r.Annual_Recurring_Revenue__c
                        , Steelbrick_Asset__r.Quantity, Steelbrick_Asset__r.Annual_Recurring_Revenue__c
                        , Steelbrick_Asset__r.CurrencyIsoCode
                        , Steelbrick_Asset__r.SBQQ__LatestQuoteLine__r.SBQQ__EffectiveStartDate__c
                        , Steelbrick_Asset__r.SBQQ__LatestQuoteLine__r.SBQQ__EffectiveEndDate__c
                        , Contract__r.Master_Term__c, Latest_Opportunity__c, Latest_Quote_Line__c
                        , Steelbrick_Asset__r.SBQQ__LatestQuoteLine__r.SBQQ__Quote__r.SBQQ__Opportunity2__c
                        , Steelbrick_Asset__r.SBQQ__LatestQuoteLine__c
                FROM Customer_Asset__c
                WHERE Steelbrick_Asset__c IN :revisedAssetIdList
        ];

        List<Customer_Asset__c> updateAssetList = new List<Customer_Asset__c>();
        for (Asset sbAsset : assetList) {
            Boolean foundExistingCA = false;
            for (Customer_Asset__c existCustAsset : existingAssetList) {
                if (existCustAsset.Steelbrick_Asset__c == sbAsset.SBQQ__RevisedAsset__c
                        || existCustAsset.Steelbrick_Asset__c == sbAsset.SBQQ__LatestQuoteLine__r.SBQQ__RenewedAsset__c) {
                    existCustAsset.Steelbrick_Asset__c = sbAsset.Id;
//existCustAsset.Quantity__c = existCustAsset.Quantity__c + sbAsset.SBQQ__LatestQuoteLine__r.SBQQ__Quantity__c;
//existCustAsset.Total_One_Time_Fee_s__c = existCustAsset.Total_One_Time_Fee_s__c + sbAsset.Price;
                    updateAssetList.add(existCustAsset);
                    foundExistingCA = true;
                    break;
                }
            }
            if (!foundExistingCA) {
                updateAssetList.add(createVistaAssetForAsset(sbAsset));
            }
        }

        upsert updateAssetList;

        finalAssetList = [
                SELECT
// vista asset fields
                        Id, Name, Account__c, Product__c, Description__c, Contract__c
                        , Term_Start_Date__c, Term_End_Date__c, Asset_Status__c, Quantity__c
                        , Annual_Recurring_Revenue__c, Steelbrick_Subscription__c, Steelbrick_Asset__c
// subscribed asset fields
                        , Steelbrick_Asset__r.SBQQ__CurrentSubscription__c, Steelbrick_Asset__r.Price
// subscribed asset subscription fields
                        , Steelbrick_Asset__r.SBQQ__CurrentSubscription__r.SBQQ__QuoteLine__r.SBQQ__Quantity__c
                        , Steelbrick_Asset__r.SBQQ__CurrentSubscription__r.SBQQ__NetPrice__c
                        , Steelbrick_Asset__r.SBQQ__CurrentSubscription__r.CurrencyIsoCode
                        , Steelbrick_Asset__r.SBQQ__CurrentSubscription__r.Annual_Recurring_Revenue__c
                        , Steelbrick_Asset__r.Quantity, Steelbrick_Asset__r.Annual_Recurring_Revenue__c
                        , Steelbrick_Asset__r.CurrencyIsoCode
                        , Steelbrick_Asset__r.SBQQ__LatestQuoteLine__r.SBQQ__EffectiveStartDate__c
                        , Steelbrick_Asset__r.SBQQ__LatestQuoteLine__r.SBQQ__EffectiveEndDate__c
                        , Contract__r.Master_Term__c, Latest_Opportunity__c, Latest_Quote_Line__c
                        , Steelbrick_Asset__r.SBQQ__LatestQuoteLine__r.SBQQ__Quote__r.SBQQ__Opportunity2__c
                        , Steelbrick_Asset__r.SBQQ__LatestQuoteLine__c
                FROM Customer_Asset__c
                WHERE Steelbrick_Asset__r.Id IN :assetIdList
        ];

        return finalAssetList;
    }

    public static Map<Asset, Customer_Asset__c> getVistaAssetsForRenewedAssets(List<Asset> assetList) {
        System.debug(LoggingLevel.INFO, 'VistaAssetVAHandler.getVistaAssetsForRenewedAssets');
// Get vista asset for each asset
        List<Customer_Asset__c> existingAssetList = new List<Customer_Asset__c>();
        Map<Id, Asset> renewedAssetAssetMap = new Map<Id, Asset>();
        Map<Asset, Customer_Asset__c> assetCustAssetMap = new Map<Asset, Customer_Asset__c>();

        for (Asset asset : assetList) {
            renewedAssetAssetMap.put(asset.SBQQ__LatestQuoteLine__r.SBQQ__RenewedAsset__c, asset);
        }
        existingAssetList = [
                SELECT
// vista asset fields
                        Id, Name, Account__c, Product__c, Description__c, Contract__c
                        , Term_Start_Date__c, Term_End_Date__c, Asset_Status__c, Quantity__c
                        , Annual_Recurring_Revenue__c, Steelbrick_Subscription__c, Steelbrick_Asset__c
                        /*, Total_One_Time_Fee_s__c*/
// subscribed asset fields
                        , Steelbrick_Asset__r.SBQQ__CurrentSubscription__c, Steelbrick_Asset__r.Price
// subscribed asset subscription fields
                        , Steelbrick_Asset__r.SBQQ__CurrentSubscription__r.SBQQ__QuoteLine__r.SBQQ__Quantity__c
                        , Steelbrick_Asset__r.SBQQ__CurrentSubscription__r.SBQQ__NetPrice__c
                        , Steelbrick_Asset__r.SBQQ__CurrentSubscription__r.CurrencyIsoCode
                        , Steelbrick_Asset__r.SBQQ__CurrentSubscription__r.Annual_Recurring_Revenue__c
                        , Steelbrick_Asset__r.Quantity, Steelbrick_Asset__r.Annual_Recurring_Revenue__c
                        , Steelbrick_Asset__r.CurrencyIsoCode
                        , Steelbrick_Asset__r.SBQQ__LatestQuoteLine__r.SBQQ__EffectiveStartDate__c
                        , Steelbrick_Asset__r.SBQQ__LatestQuoteLine__r.SBQQ__EffectiveEndDate__c
                        , Contract__r.Master_Term__c, Latest_Opportunity__c, Latest_Quote_Line__c
                        , Steelbrick_Asset__r.SBQQ__LatestQuoteLine__r.SBQQ__Quote__r.SBQQ__Opportunity2__c
                        , Steelbrick_Asset__r.SBQQ__LatestQuoteLine__c
                FROM Customer_Asset__c
                WHERE Steelbrick_Asset__c IN :renewedAssetAssetMap.keySet()
        ];

        for (Customer_Asset__c custAsset : existingAssetList) {
            assetCustAssetMap.put(renewedAssetAssetMap.get(custAsset.Steelbrick_Asset__c), custAsset);
        }
        return assetCustAssetMap;
    }

    public static Map<Asset, Customer_Asset__c> getVistaAssetsForUpgradedAssets(List<Asset> assetList) {
        System.debug(LoggingLevel.INFO, 'VistaAssetVAHandler.getVistaAssetsForUpgradedAssets');
// Get vista asset for each asset
        List<Customer_Asset__c> existingAssetList = new List<Customer_Asset__c>();
        Map<Id, Asset> upgradedAssetAssetMap = new Map<Id, Asset>();
        Map<Asset, Customer_Asset__c> assetCustAssetMap = new Map<Asset, Customer_Asset__c>();

        for (Asset asset : assetList) {
            upgradedAssetAssetMap.put(asset.SBQQ__LatestQuoteLine__r.SBQQ__UpgradedAsset__c, asset);
        }
        existingAssetList = [
                SELECT
// vista asset fields
                        Id, Name, Account__c, Product__c, Description__c, Contract__c
                        , Term_Start_Date__c, Term_End_Date__c, Asset_Status__c, Quantity__c
                        , Annual_Recurring_Revenue__c, Steelbrick_Subscription__c, Steelbrick_Asset__c
                        /*, Total_One_Time_Fee_s__c*/
// subscribed asset fields
                        , Steelbrick_Asset__r.SBQQ__CurrentSubscription__c, Steelbrick_Asset__r.Price
// subscribed asset subscription fields
                        , Steelbrick_Asset__r.SBQQ__CurrentSubscription__r.SBQQ__QuoteLine__r.SBQQ__Quantity__c
                        , Steelbrick_Asset__r.SBQQ__CurrentSubscription__r.SBQQ__NetPrice__c
                        , Steelbrick_Asset__r.SBQQ__CurrentSubscription__r.CurrencyIsoCode
                        , Steelbrick_Asset__r.SBQQ__CurrentSubscription__r.Annual_Recurring_Revenue__c
                        , Steelbrick_Asset__r.Quantity, Steelbrick_Asset__r.Annual_Recurring_Revenue__c
                        , Steelbrick_Asset__r.CurrencyIsoCode
                        , Steelbrick_Asset__r.SBQQ__LatestQuoteLine__r.SBQQ__EffectiveStartDate__c
                        , Steelbrick_Asset__r.SBQQ__LatestQuoteLine__r.SBQQ__EffectiveEndDate__c
                        , Contract__r.Master_Term__c, Latest_Opportunity__c, Latest_Quote_Line__c
                        , Steelbrick_Asset__r.SBQQ__LatestQuoteLine__r.SBQQ__Quote__r.SBQQ__Opportunity2__c
                        , Steelbrick_Asset__r.SBQQ__LatestQuoteLine__c
                FROM Customer_Asset__c
                WHERE Steelbrick_Asset__c IN :upgradedAssetAssetMap.keySet()
        ];

        for (Customer_Asset__c custAsset : existingAssetList) {
            assetCustAssetMap.put(upgradedAssetAssetMap.get(custAsset.Steelbrick_Asset__c), custAsset);
        }
        return assetCustAssetMap;
    }

    public static Customer_Asset__c createVistaAssetForAsset(Asset asset) {
        System.debug(LoggingLevel.INFO, 'VistaAssetVAHandler.createVistaAssetForAsset');
        Customer_Asset__c vistaAsset = new Customer_Asset__c();
        vistaAsset.Name = asset.Product2.Name;
        vistaAsset.Account__c = asset.AccountId;
        vistaAsset.Product__c = asset.Product2Id;
        vistaAsset.Description__c = asset.Product2.Description;
        //vistaAsset.Contract__c = null;
        vistaAsset.Term_Start_Date__c = asset.SBQQ__LatestQuoteLine__r.SBQQ__EffectiveStartDate__c;
        vistaAsset.Term_End_Date__c = asset.SBQQ__LatestQuoteLine__r.SBQQ__EffectiveEndDate__c;
        vistaAsset.Asset_Status__c = 'Active';
        if (asset.Quantity != null) {
            vistaAsset.Quantity__c = asset.Quantity;
        } else {
            vistaAsset.Quantity__c = 0;
        }
        /* ARMAN: if (asset.Price != null) {
            vistaAsset.Total_One_Time_Fee_s__c = asset.Price;
        } else {
            vistaAsset.Total_One_Time_Fee_s__c = 0;
        }
        vistaAsset.ARR__c = 0;
        */

        vistaAsset.Annual_Recurring_Revenue__c = 0;
        vistaAsset.CurrencyIsoCode = asset.CurrencyIsoCode;
        vistaAsset.Steelbrick_Asset__c = asset.Id;
        vistaAsset.Oracle_Id__c = asset.SBQQ__LatestQuoteLine__r.Oracle_Id__c;
        vistaAsset.Latest_Opportunity__c = asset.SBQQ__LatestQuoteLine__r.SBQQ__Quote__r.SBQQ__Opportunity2__c;
        vistaAsset.Latest_Quote_Line__c = asset.SBQQ__LatestQuoteLine__c;
        return vistaAsset;
    }

    public static List<Customer_Asset__c> updateVistaAssetForAsset(Map<Asset, Customer_Asset__c> assetAssetMap) {
        System.debug(LoggingLevel.INFO, 'VistaAssetVAHandler.updateVistaAssetForAsset');
        List<Customer_Asset__c> vistaAssetList = new List<Customer_Asset__c>();
        for (Asset asset : assetAssetMap.keySet()) {
            Customer_Asset__c vistaAsset = assetAssetMap.get(asset);
            vistaAsset.Term_Start_Date__c = asset.SBQQ__LatestQuoteLine__r.SBQQ__EffectiveStartDate__c;
            vistaAsset.Term_End_Date__c = asset.SBQQ__LatestQuoteLine__r.SBQQ__EffectiveEndDate__c;

            if (asset.SBQQ__LatestQuoteLine__r.SBQQ__Quantity__c != null) {
                vistaAsset.Quantity__c = asset.SBQQ__LatestQuoteLine__r.SBQQ__Quantity__c;
            } else {
                vistaAsset.Quantity__c = vistaAsset.Quantity__c;
            }

            /* ARMAN: if (asset.SBQQ__LatestQuoteLine__r.SBQQ__Quantity__c != null && asset.SBQQ__LatestQuoteLine__r.SBQQ__Quantity__c > 0) {
                vistaAsset.Total_One_Time_Fee_s__c = asset.SBQQ__LatestQuoteLine__r.Final_Unit_Price__c;
            } else {
                vistaAsset.Total_One_Time_Fee_s__c = vistaAsset.Total_One_Time_Fee_s__c;
            }
            vistaAsset.ARR__c = 0;
            */

            vistaAsset.Annual_Recurring_Revenue__c = 0;
            vistaAsset.CurrencyIsoCode = asset.CurrencyIsoCode;
            vistaAsset.Latest_Opportunity__c = asset.SBQQ__LatestQuoteLine__r.SBQQ__Quote__r.SBQQ__Opportunity2__c;
            vistaAsset.Latest_Quote_Line__c = asset.SBQQ__LatestQuoteLine__c;
            vistaAssetList.add(vistaAsset);
        }
        return vistaAssetList;
    }

    public static Customer_Asset__c decomVistaAssetForAsset(Customer_Asset__c vistaAsset) {
        System.debug(LoggingLevel.INFO, 'VistaAssetVAHandler.decomVistaAssetForAsset');
        vistaAsset.Contract__c = vistaAsset.Contract__c;
        vistaAsset.Decommission_Effective_Date__c = vistaAsset.Steelbrick_Asset__r.SBQQ__LatestQuoteLine__r.SBQQ__EffectiveStartDate__c;
        vistaAsset.Term_Start_Date__c = vistaAsset.Steelbrick_Asset__r.SBQQ__LatestQuoteLine__r.SBQQ__EffectiveStartDate__c;
        vistaAsset.Term_End_Date__c = vistaAsset.Steelbrick_Asset__r.SBQQ__LatestQuoteLine__r.SBQQ__EffectiveEndDate__c;
        if (vistaAsset.Steelbrick_Asset__r.SBQQ__LatestQuoteLine__r.SBQQ__EffectiveStartDate__c <= Date.today()) {
            vistaAsset.Asset_Status__c = 'Decommissioned';
        }
        return vistaAsset;
    }

}