/**
    * Asset Utility
    *
    * Various scripts used by Triggers
    *
    * bundlePostProcessing - creates Component Assets from Bundle Assets and deletes the Bundle Asset
    *
    * @author: Mark Malanowski
    * @company: Cloud Sherpas
    * @date: Oct 08 2014
    * 
*/

public without sharing class AssetUtility {
    
    public static void bundlePostProcessing(Map<Id, Asset__c> newAssetMap) {
        
        Map<Id, Asset__c> bundleAstMap = findBundleAssets(newAssetMap);
            
        createComponentAssets(bundleAstMap);
            
        updateComponentAssets(bundleAstMap, findComponentAssets(findAssetAccounts(newAssetMap)));
    }
    
    private static Map<Id, Asset__c> findBundleAssets(Map<Id, Asset__c> allAssetMap) {
        Map<Id, Asset__c> bundleAssetMap = new Map<Id, Asset__c>();
        
        for (Asset__c a : [SELECT Id,
                                  Name,
                                  Account__c,
                                  ARR__c,
                                  Product__c,
                                  Description__c,
                                  Map_Notes__c,
                                  Billing_Frequency__c,
                                  License_Metric_Quantity__c,
                                  Maintenance_Status__c,
                                  Term_Start_Date__c,
                                  Term_End_Date__c,
                                  Asset_Term_Start_Date__c,
                                  Asset_Term_End_Date__c,
                                  Contract__c,
                                  Product_Group__c,
                                  Unit_Sales_Price__c,
                                  Dollars_Per_Load__c,
                                  Dollars_Per_Truck__c,
                                  Number_of_DCs__c,
                                  Number_of_Users__c,
                                  Component_Allocation__c,
                                  OLI_Line_Type__c,
                                  Cancellation_Reason__c,
                                  Cancellation_Type__c,
                                  Cancellation_Date__c,
                                  Asset_ARR_at_Decommission__c
                                  FROM Asset__c
                                  WHERE Product__r.Is_Bundle__c = true
                                        AND Id IN :allAssetMap.keySet()]) {
            bundleAssetMap.put(a.Id, a);
        }
        
        return bundleAssetMap;
    }
    
    private static Map<Id, Asset__c> findComponentAssets(Set<Id> accountIds) {
        Map<Id, Asset__c> componentAssetMap = new Map<Id, Asset__c>();
        
        for (Asset__c a : [SELECT Id,
                                  Name,
                                  Account__c,
                                  ARR__c,
                                  Product__c,
                                  Description__c,
                                  Map_Notes__c,
                                  Billing_Frequency__c,
                                  License_Metric_Quantity__c,
                                  Maintenance_Status__c,
                                  Term_Start_Date__c,
                                  Term_End_Date__c,
                                  Asset_Term_Start_Date__c,
                                  Asset_Term_End_Date__c,
                                  Contract__c,
                                  Product_Group__c,
                                  Unit_Sales_Price__c,
                                  Dollars_Per_Load__c,
                                  Dollars_Per_Truck__c,
                                  Number_of_DCs__c,
                                  Number_of_Users__c,
                                  Component_Allocation__c,
                                  OLI_Line_Type__c,
                                  Bundle_Product__c,
                                  Bundle_Name__c,
                                  Cancellation_Reason__c,
                                  Cancellation_Type__c,
                                  Cancellation_Date__c,
                                  Asset_ARR_at_Decommission__c
                                  FROM Asset__c
                                  WHERE Bundle_Product__c != null
                                        AND Product__r.Is_Bundle__c = false
                                        AND Account__c IN :accountIds]) {
            componentAssetMap.put(a.Id, a);
        }
        
        return componentAssetMap;
    }
    
    private static void createComponentAssets(Map<Id, Asset__c> bundleAssetMap) {
        Set<Id> bundleProdIdSet = new Set<Id>();

        List<Asset__c> bundleAssetsToDelete = new List<Asset__c>();
        List<Asset__c> componentAssetsToInsert = new List<Asset__c>();
        
        for (Asset__c a : bundleAssetMap.values()) {
            bundleProdIdSet.add(a.Product__c);
        }
        
        List<VCG_CPQ_Bundle__c> componentList = [SELECT Bundle_Product__c, Bundle_Split__c, Bundle_Split_Type__c, Product__c, Product__r.Name, Product__r.Description FROM VCG_CPQ_Bundle__c WHERE Bundle_Product__c IN :bundleProdIdSet];

        for (Asset__c bundle : bundleAssetMap.values()) {
            if (bundle.OLI_Line_Type__c == 'New') {       
                for (VCG_CPQ_Bundle__c comp : componentList) {          
                    if (comp.Bundle_Product__c == bundle.Product__c) {
                    
                        Asset__c ast = new Asset__c();
                        ast.Account__c = bundle.Account__c;
                        ast.Name = comp.Product__r.Name;
                        ast.Name = ast.Name.subString(0, Math.min(79, ast.Name.length()));
                        ast.Bundle_Name__c = bundle.Name;
                        ast.Product__c = comp.Product__c;
                        ast.Bundle_Product__c = bundle.Product__c;
                        ast.Description__c = comp.Product__r.Description;
                        ast.Map_Notes__c = bundle.Map_Notes__c;
                        ast.Billing_Frequency__c = bundle.Billing_Frequency__c;
                        ast.License_Metric_Quantity__c = bundle.License_Metric_Quantity__c;
                        ast.Maintenance_Status__c = bundle.Maintenance_Status__c;
                        ast.Asset_Term_Start_Date__c = bundle.Asset_Term_Start_Date__c;
                        ast.Asset_Term_End_Date__c = bundle.Asset_Term_End_Date__c;
                        ast.Term_Start_Date__c = bundle.Term_Start_Date__c;
                        ast.Term_End_Date__c = bundle.Term_End_Date__c;
                        ast.Contract__c = bundle.Contract__c;
                        ast.Product_Group__c = bundle.Product_Group__c;
                        ast.Unit_Sales_Price__c = bundle.Unit_Sales_Price__c;
                        ast.Dollars_Per_Load__c = bundle.Dollars_Per_Load__c;
                        ast.Dollars_Per_Truck__c = bundle.Dollars_Per_Truck__c;
                        ast.Number_of_DCs__c = bundle.Number_of_DCs__c;
                        ast.Number_of_Users__c = bundle.Number_of_Users__c;
                    
                        if ((comp.Bundle_Split_Type__c == 'Percent' || comp.Bundle_Split_Type__c == 'Percentage') && comp.Bundle_Split__c != null && bundle.ARR__C != null) {
                            ast.Component_Allocation__c = bundle.ARR__c * (comp.Bundle_Split__c/100.0);
                            ast.ARR__c = bundle.ARR__c * (comp.Bundle_Split__c/100.0);
                        }
                        else if (comp.Bundle_Split_Type__c == 'Amount - Flat' && comp.Bundle_Split__c != null) {
                            ast.Component_Allocation__c = comp.Bundle_Split__c;
                            ast.ARR__c = comp.Bundle_Split__c;
                        }
                        else if (comp.Bundle_Split_Type__c == 'Amount - Per Unit' && comp.Bundle_Split__c != null && bundle.License_Metric_Qty__c != null) {
                            ast.Component_Allocation__c = comp.Bundle_Split__c * bundle.License_Metric_Qty__c;
                            ast.ARR__c = comp.Bundle_Split__c * bundle.License_Metric_Qty__c;
                        }
                        
                        componentAssetsToInsert.add(ast);
                    }
                }
                bundleAssetsToDelete.add(bundle);
            }       
        }
    
        // insert the Component Assets
        insert componentAssetsToInsert;
        
        // delete the Bundle Assets
        delete bundleAssetsToDelete;
    }
    
    private static void updateComponentAssets(Map<Id, Asset__c> bundleAssetMap, Map<Id, Asset__c> componentAssetMap) {
        Set<Id> bundleProdIdSet = new Set<Id>();

        List<Asset__c> componentAssetsToUpdate = new List<Asset__c>();
        List<Asset__c> bundleAssetsToDelete = new List<Asset__c>();
        
        for (Asset__c a : bundleAssetMap.values()) {
            bundleProdIdSet.add(a.Product__c);
        }
        
        List<VCG_CPQ_Bundle__c> componentList = [SELECT Bundle_Product__c, Bundle_Split__c, Bundle_Split_Type__c, Product__c, Product__r.Name, Product__r.Description FROM VCG_CPQ_Bundle__c WHERE Bundle_Product__c IN :bundleProdIdSet];
        
        for (Asset__c bundleAst : bundleAssetMap.values()) {
            System.debug('Asset Line Type: ' + bundleAst.OLI_Line_Type__c);
            if (bundleAst.OLI_Line_Type__c == 'Renewal') {       
                for (VCG_CPQ_Bundle__c comp : componentList) {  
                    for (Asset__c compAst : componentAssetMap.values()) {
                        if (compAst.Bundle_Product__c == bundleAst.Product__c && comp.Bundle_Product__c == bundleAst.Product__c && comp.Product__c == compAst.Product__c && compAst.Account__c == bundleAst.Account__c) {
                            compAst.Previous_Annual_Maintenance__c = compAst.ARR__c;
                            compAst.Previous_Metric_Qty__c = compAst.License_Metric_Qty__c;
                            compAst.Billing_Frequency__c = bundleAst.Billing_Frequency__c;
                            compAst.Term_Start_Date__c = bundleAst.Term_Start_Date__c;
                            compAst.Term_End_Date__c = bundleAst.Term_End_Date__c;
                            compast.Asset_Term_Start_Date__c = bundleast.Asset_Term_Start_Date__c;
                            compast.Asset_Term_End_Date__c = bundleast.Asset_Term_End_Date__c;
                            compAst.License_Metric_Quantity__c = bundleAst.License_Metric_Quantity__c;
                            compAst.Map_Notes__c = bundleAst.Map_Notes__c;
                            compAst.Contract__c = bundleAst.Contract__c;
                                
                            if ((comp.Bundle_Split_Type__c == 'Percent' || comp.Bundle_Split_Type__c == 'Percentage') && comp.Bundle_Split__c != null && bundleAst.ARR__C != null) {
                                compAst.Component_Allocation__c = bundleAst.ARR__c * (comp.Bundle_Split__c/100.0);
                                compAst.ARR__c = bundleAst.ARR__c * (comp.Bundle_Split__c/100.0);
                            }
                            else if (comp.Bundle_Split_Type__c == 'Amount - Flat' && comp.Bundle_Split__c != null) {
                                compAst.Component_Allocation__c = comp.Bundle_Split__c;
                                compAst.ARR__c = comp.Bundle_Split__c;
                            }
                            else if (comp.Bundle_Split_Type__c == 'Amount - Per Unit' && comp.Bundle_Split__c != null && bundleAst.License_Metric_Qty__c != null) {
                                compAst.Component_Allocation__c = comp.Bundle_Split__c * bundleAst.License_Metric_Qty__c;
                                compAst.ARR__c = comp.Bundle_Split__c * bundleAst.License_Metric_Qty__c;
                            }
                        
                            componentAssetsToUpdate.add(compAst);
                        }
                    }
                }
                bundleAssetsToDelete.add(bundleAst);
            }
            else if (bundleAst.OLI_Line_Type__c == 'Extension') {       
                for (VCG_CPQ_Bundle__c comp : componentList) {  
                    for (Asset__c compAst : componentAssetMap.values()) {
                        if (compAst.Bundle_Product__c == bundleAst.Product__c && comp.Bundle_Product__c == bundleAst.Product__c
                             && comp.Product__c == compAst.Product__c && compAst.Account__c == bundleAst.Account__c)
                        {
                            compAst.License_Metric_Quantity__c += bundleAst.License_Metric_Quantity__c;
                            compAst.Contract__c = bundleAst.Contract__c;
                                
                            if ((comp.Bundle_Split_Type__c == 'Percent' || comp.Bundle_Split_Type__c == 'Percentage') && comp.Bundle_Split__c != null && bundleAst.ARR__C != null) {
                                compAst.Component_Allocation__c += bundleAst.ARR__c * (comp.Bundle_Split__c/100.0);
                                compAst.ARR__c += bundleAst.ARR__c * (comp.Bundle_Split__c/100.0);
                            }
                            else if (comp.Bundle_Split_Type__c == 'Amount - Flat' && comp.Bundle_Split__c != null)
                            {
                                compAst.Component_Allocation__c += comp.Bundle_Split__c;
                                compAst.ARR__c += comp.Bundle_Split__c;
                            }
                            else if (comp.Bundle_Split_Type__c == 'Amount - Per Unit' && comp.Bundle_Split__c != null && bundleAst.License_Metric_Qty__c != null) {
                                compAst.Component_Allocation__c += comp.Bundle_Split__c * bundleAst.License_Metric_Qty__c;
                                compAst.ARR__c += comp.Bundle_Split__c * bundleAst.License_Metric_Qty__c;
                            }
                        
                            componentAssetsToUpdate.add(compAst);
                        }
                    }
                }
                bundleAssetsToDelete.add(bundleAst);
            }
            else if (bundleAst.OLI_Line_Type__c == 'Decommission') {       
                for (VCG_CPQ_Bundle__c comp : componentList) {  
                    for (Asset__c compAst : componentAssetMap.values())
                    {
                        if (compAst.Bundle_Product__c == bundleAst.Product__c
                           && comp.Bundle_Product__c == bundleAst.Product__c
                           && comp.Product__c == compAst.Product__c
                           && compAst.Account__c == bundleAst.Account__c)
                        {
                            compAst.Asset_ARR_at_Decommission__c = compAst.ARR__c;
                            compAst.License_Metric_Quantity__c -= bundleAst.License_Metric_Quantity__c;
                            compAst.Cancellation_Reason__c = bundleAst.Cancellation_Reason__c;
                            compAst.Cancellation_Type__c = bundleAst.Cancellation_Type__c;
                            compAst.Cancellation_Date__c = bundleAst.Cancellation_Date__c;
                            
                            // NOTE: ARR__c is negative for Decommissions!
                            if ((comp.Bundle_Split_Type__c == 'Percent' || comp.Bundle_Split_Type__c == 'Percentage') && comp.Bundle_Split__c != null && bundleAst.ARR__C != null) {
                                compAst.Component_Allocation__c += bundleAst.ARR__c * (comp.Bundle_Split__c/100.0);
                                compAst.ARR__c += bundleAst.ARR__c * (comp.Bundle_Split__c/100.0);
                            }
                            else if (comp.Bundle_Split_Type__c == 'Amount - Flat' && comp.Bundle_Split__c != null) {
                                compAst.Component_Allocation__c -= comp.Bundle_Split__c;
                                compAst.ARR__c -= comp.Bundle_Split__c;
                            }
                            else if (comp.Bundle_Split_Type__c == 'Amount - Per Unit' && comp.Bundle_Split__c != null && bundleAst.License_Metric_Qty__c != null) {
                                compAst.Component_Allocation__c -= comp.Bundle_Split__c * bundleAst.License_Metric_Qty__c;
                                compAst.ARR__c -= comp.Bundle_Split__c * bundleAst.License_Metric_Qty__c;
                            }
                        
                            componentAssetsToUpdate.add(compAst);
                        }
                    }
                }
                bundleAssetsToDelete.add(bundleAst);
            }
        }
        
        // update the Component Assets
        update componentAssetsToUpdate;
        
        // delete the Bundle Assets
        delete bundleAssetsToDelete;
        
    }

    private static Set<Id> findAssetAccounts(Map<Id, Asset__c> newAssetMap) {
        Set<Id> accountIds = new Set<Id>();
        for (Asset__c a : newAssetMap.values()) {
            if (!accountIds.contains(a.Account__c)) {
                accountIds.add(a.Account__c);
            }
        }
        return accountIds;
    }
    
}