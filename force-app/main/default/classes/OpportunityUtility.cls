/**
 * Opportunity Utility
 *
 * Various scripts used by Triggers
 *
 * isOpportunityTriggerRunning - This boolean helps to ensure the update to Opportunity from the trigger doesn't reinitiate it. 
 * createUpdateAssets - Creates or Updates Assets from OLI's 
 *
 * @author: Mark Malanowski
 * @company: Cloud Sherpas
 * @date: Jun 25 2013
 * @history: 2015 Jan 9 | Mark David De Chavez | replaced isOpportunityTrigger = true inside validateAssetCreation()
 * 
 *           2015 Jan 23 | Lawrence Coffin <lawrence.coffin@cloudsherpas.com>
 *           Updated validateAssetCreation() to return a list of OLIs rather than a map and createUpdateAssets() and getOLIAssets() to take lists
 *           so we can keep the order of the OLIs as sorted by the query in validateAssetCreation. We need to do this so all Extension & Decommission lines
 *           get processed *before* any renewal lines for the same product. Otherwise the ARR and Quantity deltas from the Extension/Decom will be applied to the
 *           renewal ARR/LMQ which already has those values applied.
 *
 * Modified By   : Rittu Roy
 * Modified Date : 9/26/2015
 * Objective     : Added validateOpptyEditability method to prevent Sales users from editing closed opportunities
 * 
 */

public without sharing class OpportunityUtility {
    /*
    public static integer beforeInsertExecuted = 0;
    public static integer afterInsertExecuted = 0;
    public static integer beforeUpdateExecuted = 0;
    public static integer afterUpdateExecuted = 0;
    
    static Map<Id,Asset__c> cachedAssets = new Map<Id,Asset__c>();
    
    public static Boolean isOpportunityTriggerRunning
    {
        get
        {
            if(isOpportunityTriggerRunning == null)
                isOpportunityTriggerRunning = false;
            
            return isOpportunityTriggerRunning;
        }
        
        set;
    }
    private class TestException extends Exception{}
    
    public static void createUpdateAssets(Map<ID, Opportunity> newMap, Map<ID, Opportunity> oldMap) {
        
        List<OpportunityLineItem> qualifiedOLIsList = validateAssetCreation(newMap, oldMap);
        
            
        //create a list of assetized opptys
        map<Id, Opportunity> assetizedOpps = new map<Id, Opportunity>();
        
        for(Opportunity o : newMap.values())
        {
            Boolean oldTrigger = false;
            Boolean newTrigger = false;
            oldTrigger = (oldMap.get(o.id).Finance_Status__c == 'Approved' &&
                          oldMap.get(o.id).Legal_Review__c == 'Approved');
            newTrigger = (o.Finance_Status__c == 'Approved' &&
                          o.Legal_Review__c == 'Approved');
            
            if(!isOpportunityTriggerRunning && !oldTrigger && newTrigger)
               assetizedOpps.put(o.Id, new Opportunity(Id=o.Id, Has_Converted_Assets__c = true));
                
        }
        
        System.debug(LoggingLevel.ERROR, '====> qualifiedOLIsList: ' + qualifiedOLIsList);
        
        if(!isOpportunityTriggerRunning && qualifiedOLIsList.size() > 0){
            isOpportunityTriggerRunning = true;
            createUpdateAssets(qualifiedOLIsList);
        }
        
        if(assetizedOpps.size() > 0)
            update assetizedOpps.values();
        
        //
        // Additional processing for DC and User Totals on the Account
        //
        set<Id> accountIdList = new set<Id>();
        for(Opportunity o : newMap.values())
        {
            if(o.IsClosed && o.IsWon && o.IsWon != oldMap.get(o.Id).isWon)
                accountIdList.add(o.AccountId);
        }
        
        if(accountIdList.size() > 0)
            syncAccountUserAndDcTotals(accountIdList); //call the future method to calculate the User and DC totals for the account
    }
    
    // Deprecated 10/26 for P+M - MM
    /*
    private static void createUpdateAssets(Map<ID, OpportunityLineItem> qualifiedOLIsMap)
    {
        if(qualifiedOLIsMap.size() > 0)
        {
            List<OLIAssetWrapper> allOLIAssets = getOLIAssets(qualifiedOLIsMap);
            
            List<Asset__c> allAssetsToInsert = new List<Asset__c>();
            for(OLIAssetWrapper oliAst: allOLIAssets) 
            {
                Boolean found = false;
                for (Asset__c a : allAssetsToInsert) {
                    if (a.Id <> null && oliAst.ast.Id <> null && a.Id == oliAst.ast.Id) {
                        found = true;
                    }
                }
                if (!found) {
                    allAssetsToInsert.add(oliAst.ast);
                }
            }
            
            upsert allAssetsToInsert;    
            
            List<OpportunityLineItem> allOLIsToUpdate = new List<OpportunityLineItem>();
            Set<ID> opptyIDs = new Set<ID>();
            for(OLIAssetWrapper oliAst: allOLIAssets)
            {
                if (!oliAst.oli.PriceBookEntry.Product2.Is_Bundle__c) {
                    OpportunityLineItem oli = oliAst.oli;
                    oli.Asset__c = oliAst.ast.id;
                    
                    allOLIsToUpdate.add(oli);
                    
                    opptyIDs.add(oli.OpportunityID);
                }
            }
            
            update allOLIsToUpdate;
            
            List<Opportunity> allOpptysToUpdate = new List<Opportunity>();
            for(ID opptyid : opptyIDs)
            {
                Opportunity oppty = new Opportunity(id = opptyid);
                allOpptysToUpdate.add(oppty);
            }
            
            update allOpptysToUpdate;
        }
    }*/
    /*
    private static void createUpdateAssets(List<OpportunityLineItem> qualifiedOLIsList)
    {
        if(qualifiedOLIsList.size() > 0)
        {
            //
            // Get all OLI to Asset Mappings - Assets will be upserted, OLIs will be updated, and Opps will be 'touched'
            //
            List<OLIAssetWrapper> allOLIAssets = getOLIAssets(qualifiedOLIsList);
            list<Fulfillment_Event__c> fulfillmentRecs = createDecomissionFulfillmentRecs(qualifiedOLIsList);
            
            //
            // Save all assets
            //
            List<Asset__c> allAssetsToInsert = new List<Asset__c>();
            for(OLIAssetWrapper oliAst: allOLIAssets) 
            {
                allAssetsToInsert.add(oliAst.ast);
            }
            
            upsert allAssetsToInsert;   
            if(fulfillmentRecs.size() > 0)
            {
                insert fulfillmentRecs;
            } 
            
            //
            // Update all OLIs
            //
            // Create Map with all OLI & ASSETID
            // Create Map with all OLI with OLI for all add-on
            Map<Id, Id> OLIAssetMap = new Map<Id, Id>();
            Map<Id, Id> OLIAddonMap = new Map<Id, Id>();
            
            List<OpportunityLineItem> allOLIsToUpdate = new List<OpportunityLineItem>();
            Set<ID> opptyIDs = new Set<ID>();
            for(OLIAssetWrapper oliAst: allOLIAssets)
            {
                if (oliAst.oli != null && !oliAst.oli.PriceBookEntry.Product2.Is_Bundle__c)
                {
                    OpportunityLineItem oli = oliAst.oli;
                    oli.Asset__c = oliAst.ast.id;
                    
                    allOLIsToUpdate.add(oli);
                    
                    opptyIDs.add(oli.OpportunityID);
                    
                    oliAssetMap.put(oli.Quote_Product__c,oli.Asset__c);  //Tanvir   
                    if (oli.add_on_Source_Quote_Product__c != null) // Tanvir
                        oliAddonMap.put(oli.Asset__c,oli.add_on_Source_Quote_Product__c); //Tanvir 
                }
                
                if (oliAst.maintOLI != null && !oliAst.maintOLI.PriceBookEntry.Product2.Is_Bundle__c)
                {
                    OpportunityLineItem oli = oliAst.maintOLI;
                    oli.Asset__c = oliAst.ast.id;
                    
                    allOLIsToUpdate.add(oli);
                    
                    opptyIDs.add(oli.OpportunityID);
                }
                
            }
            
            update allOLIsToUpdate;
            
            List<Asset__c> allAddonAssetsToUpdate = new List<Asset__c>();
            Map<ID,Asset__c> mapAssets = new Map<ID,Asset__c>([ Select Id, Name From Asset__c Where Id in :OliAddOnMap.Keyset()]);
            
            for(Asset__c ast :MapAssets.values()){
                ast.add_on_to__c = OliAssetMap.get(OliAddOnMap.get(ast.ID));
                allAddonAssetsToUpdate.add(ast);
            } 
            update allAddonAssetsToUpdate;
            
            //
            // 'Touch' all Opps (i.e. only the Id is set in the update record) currently
            //
            List<Opportunity> allOpptysToUpdate = new List<Opportunity>();
            for(ID opptyid : opptyIDs)
            {
                Opportunity oppty = new Opportunity(id = opptyid);
                allOpptysToUpdate.add(oppty);
            }
            
            update allOpptysToUpdate;
        }
    }
    
    private static List<OpportunityLineItem> validateAssetCreation(Map<ID, Opportunity> newMap, Map<ID, Opportunity> oldMap)
    {
        Set<ID> qualifiedOpptyIDs = new Set<ID>();
        List<OpportunityLineItem> olisList = new List<OpportunityLineItem>();
        
        for(Opportunity oppty: newMap.values())
        {
            //if(oppty.Finance_Status__c == 'Approved' &&
            //   oldMap.get(oppty.id).Finance_Status__c != 'Approved'
            //  )
            Boolean oldTrigger = false;
            Boolean newTrigger = false;
            oldTrigger = (oldMap.get(oppty.id).Finance_Status__c == 'Approved' &&
                          oldMap.get(oppty.id).Legal_Review__c == 'Approved');
            newTrigger = (oppty.Finance_Status__c == 'Approved' &&
                          oppty.Legal_Review__c == 'Approved');
            
            if(!oldTrigger && newTrigger)
            {
                //isOpportunityTriggerRunning = true;
                System.debug(LoggingLevel.ERROR, 'Adding Opportunity1');
                qualifiedOpptyIDs.add(oppty.id);
            }
        }
        
        if(qualifiedOpptyIDs.size() > 0)
        {
            System.debug(LoggingLevel.ERROR, '====> Querying for OLIs...');
            
            for(OpportunityLineItem oli: [Select Id, OpportunityId,
                                          Opportunity.AccountID, 
                                          Opportunity.Account.Name,
                                          Opportunity.Order_Type__c, 
                                          Opportunity.CloseDate, 
                                          Opportunity.Type, 
                                          Opportunity.RecordType.Name,
                                          PriceBookEntry.Product2.Name, 
                                          PriceBookEntry.Product2ID,
                                          PriceBookEntry.Product2.Is_Assetizable__c,
                                          PriceBookEntry.Product2.License_Type__c, 
                                          PriceBookEntry.Product2.ProductCode, 
                                          PriceBookEntry.Product2.Product_Type__c,
                                          PriceBookEntry.Product2.Family, 
                                          PriceBookEntry.Product2.Description,
                                          PriceBookEntry.Product2.Is_Bundle__c,
                                          PriceBookEntry.Product2.Is_Maintenance__c,
                                          Quantity, 
                                          Description,
                                          Annual_Recurring_Revenue__c,                                       
                                          License_Metric_Quantity__c,
                                          ARR_Term_Begin_Date__c, 
                                          ARR_Term_End_Date__c,
                                          Contract_Term_Start_Date__c,
                                          Contract_Term_End_Date__c,
                                          Add_On_To_Asset__c,
                                          Add_On_Source_Quote_Product__c,
                                          Unit_Sales_Price__c,
                                          Dollars_Per_Load__c,
                                          Dollars_Per_Truck__c,
                                          Licensed_DCs__c,
                                          Licensed_Users__c,
                                          Included_DCs__c,
                                          Included_Users__c,
                                          Extra_DCs__c,
                                          Extra_Users__c,
                                          Map_Notes__c,
                                          Decommission_Quantity__c,
                                          Cancellation_Type__c,
                                          Cancellation_Reason__c,
                                          Cancellation_Date__c,
                                          Line_Type__c,
                                          Product_Group__c,
                                          Quote_Product__c,
                                          Non_Recurring_Revenue__c,
                                          Billing_Frequency__c,
                                          Contract__c,
                                          Asset__c, 
                                          Asset__r.Maintenance_Status__c, 
                                          Asset__r.Asset_Term_Start_Date__c, 
                                          Asset__r.Asset_Term_End_Date__c,
                                          Asset__r.ARR__c, 
                                          Asset__r.Previous_Annual_Maintenance__c,
                                          Asset__r.License_Metric__c,
                                          Asset__r.License_Metric_Quantity__c,
                                          Asset__r.Non_Recurring_Revenue__c
                                          from OpportunityLineItem 
                                          where OpportunityID in: qualifiedOpptyIDs
                                          ORDER BY Line_Type__c DESC
                                          //and ( Asset__c =: null  or //new asset needs to be created
                                          //        ( Asset__c !=: null and //existing assets needs to be updated for certain opty order types only
                                          //          Opportunity.Order_Type__c in: validAssetUpdateOpptyOrderTypes
                                          //        )
                                          //    )
                                         ])
            {
                System.debug(LoggingLevel.ERROR, '====> got raw OLI: ' + oli);
                System.debug(LoggingLevel.ERROR, '====> Is_Assetizable: ' + oli.PriceBookEntry.Product2.Is_Assetizable__c);
                System.debug(LoggingLevel.ERROR, '====> Opp.Order_Type: ' + oli.Opportunity.Order_Type__c);
                
                //Modified conditional for asset validation
                if(oli.PriceBookEntry.Product2.Is_Assetizable__c || oli.PricebookEntry.Product2.Is_Maintenance__c)
                    olisList.add(oli);
                else if(oli.Opportunity.Order_Type__c == 'Maintenance' || oli.Opportunity.Order_Type__c == 'Term License' || oli.Opportunity.Order_Type__c == 'Customer Portal'){
                    olisList.add(oli);
                }
                
                // MM - Unclear at this point whether Migrations need to trigger updates to Assets
                /*else if(oli.Opportunity.Order_Type__c == ORDER_TYPE_MIGRATION && oli.PriceBookEntry.Product2.Is_Assetizable__c) 
                olisList.put(oli);
                */
            /*}           
        }
        
        return olisList;
    }
    
    // Deprecated 10/26 for P+M - MM
    /*
    private static List<OLIAssetWrapper> getOLIAssets(Map<ID, OpportunityLineItem> oliMap)
        {
        List<OLIAssetWrapper> oliAssets = new List<OLIAssetWrapper>();
        
        // Sort maintenance OLIs out for processing after non-maintenance OLIs
        List<OpportunityLineItem> maintOLIs = new List<OpportunityLineItem>();
        
        if(oliMap != null )
        {
            for(OpportunityLineItem oli: oliMap.values())
            {
                Asset__c ast;
                if(oli.Asset__c == null || oli.PriceBookEntry.Product2.Is_Bundle__c) 
                ast = createAssetFromOLI(oli);
                else
                ast = updateAssetFromOLI(oli);
                
                OLIAssetWrapper oliAst = new OLIAssetWrapper();
                oliAst.oli = oli;
                oliAst.ast = ast;
                oliAssets.add(oliAst);
            }
        }
        
        return oliAssets;
    }*/
    /*
    private static List<OLIAssetWrapper> getOLIAssets(List<OpportunityLineItem> oliList)
    {
        // NOTE: The ids used as the key will be *either* the asset id or the QP id!
        // This is to allow lookup of the core product from an add-on product's 
        // Add_on_Source_Quote_Product__c or Add_On_Source_Asset__c field.
        Map<Id,OLIAssetWrapper> oliAssets = new Map<Id,OLIAssetWrapper>();
        
        // Sort maintenance OLIs out for processing after non-maintenance OLIs
        List<OpportunityLineItem> maintOLIs = new List<OpportunityLineItem>();
       
        if (oliList != null )
        {
            for (OpportunityLineItem oli: oliList)
            {
                System.debug(LoggingLevel.ERROR, '====> processing OLI for product "' + oli.PricebookEntry.Product2.ProductCode + '" - "' + oli.PricebookEntry.Product2.Name + '"');
                
                if (oli.PricebookEntry.Product2.Is_Maintenance__c)
                {
                    maintOLIs.add(oli);
                }
                else
                {
                    Asset__c ast;
                    if(oli.Asset__c == null) 
                        ast = createAssetFromOLI(oli);
                    else
                    {
                        ast = updateAssetFromOLI(oli);
                        
                    }
                    
                    OLIAssetWrapper oliAst = new OLIAssetWrapper();
                    oliAst.oli = oli;
                    oliAst.ast = ast;
                    if (ast.Id != null)
                    {
                        oliAssets.put(ast.Id, oliAst);
                    }
                    else
                    {
                        oliAssets.put(oli.Quote_Product__c, oliAst);
                    }
                }
            }
            
            //if (UserInfo.getUserId().left(15) == '005g0000001gCV5') { // Start Restrict to user
            
            if (maintOLIs.size() > 0)
            {
                for (OpportunityLineItem oli: maintOLIs)
                {
                    System.debug(LoggingLevel.ERROR, '====> processing Maintenance OLI for product "' + oli.PricebookEntry.Product2.ProductCode + '" - "' + oli.PricebookEntry.Product2.Name + '"');
                    
                    OLIAssetWrapper oliAst;
                    if (oli.Add_On_To_Asset__c != null)
                    {
                        if (oliAssets.containsKey(oli.Add_On_To_Asset__c))
                        {
                            oliAst = oliAssets.get(oli.Add_On_To_Asset__c);
                        }
                        else
                        {
                            // Asset not loaded already (Maintenance Renewal most likely), get the asset
                            Asset__c ast = getAssetRec(oli.Add_On_To_Asset__c);
                            
                            oliAst = new OLIAssetWrapper();
                            oliAst.ast = ast;
                            
                            oliAssets.put(ast.Id, oliAst);
                        }
                    }
                    
                    else if (oli.Add_On_Source_Quote_Product__c != null)
                    {
                        System.debug('MM: Looking for oli ' + oli.Add_On_Source_Quote_Product__c);
                        if (oliAssets.containsKey(oli.Add_On_Source_Quote_Product__c))
                        {
                            System.debug('MM: Found oli ' + oliAssets.get(oli.Add_On_Source_Quote_Product__c));
                            oliAst = oliAssets.get(oli.Add_On_Source_Quote_Product__c);
                        }
                        else
                        {
                            // Throw error if Asset not created under the Core QP record?
                        }
                    }
                    else
                    {
                        // Throw error if neither Add_On_Source/To fields are set?
                    }
                    
                    if (oliAst != null)
                    {
                        applyMaintenanceOLI(oli, oliAst);
                        
                        // Set the maintenance OLI reference
                        oliAst.maintOLI = oli;
                    }
                }
            }
            //} // End Restrict to user
        }
        
        
        return oliAssets.values();
    }
    
    private static Asset__c getAssetRec(Id assetId)
    {     
        
        if (!cachedAssets.containsKey(assetId))
        {
            Asset__c ast = [SELECT Id,
                            ARR__c,
                            Asset_ARR_at_Decommission__c,
                            Asset_Term_End_Date__c,
                            Asset_Term_Start_Date__c,
                            License_Metric__c,
                            License_Metric_Quantity__c,
                            Maintenance_Status__c,
                            Previous_Metric_Qty__c,
                            Previous_Annual_Maintenance__c,
                            Product__r.Is_Maintenance__c,
                            Sold_Price__c,
                            Unit_Sales_Price__c
                            FROM Asset__c
                            WHERE Id = :assetId][0];
            
            cachedAssets.put(assetId, ast);
        }
        
        return cachedAssets.get(assetId);
        
    }
    
    private static void applyMaintenanceOLI(OpportunityLineItem oli, OLIAssetWrapper oliAst)
    {
        System.debug(LoggingLevel.ERROR, '====> applyMaintenanceOLI called for: ' + oli.Line_Type__c + ' -> ' + oli.PriceBookEntry.Product2.Name);
        
        if (oli.Line_Type__c == 'New')
        {
            System.debug('MM: Applying Maintenance for ' + oliAst.oli.id);
            oliAst.ast.Asset_Term_Start_Date__c        = oli.ARR_Term_Begin_Date__c;
            oliAst.ast.Asset_Term_End_Date__c          = oli.ARR_Term_End_Date__c;
            oliAst.ast.ARR__c                          = oli.Annual_Recurring_Revenue__c;
        }
        else if (oli.Line_Type__c == 'Renewal')
        {
            oliAst.ast.Asset_Term_Start_Date__c        = oli.ARR_Term_Begin_Date__c;
            oliAst.ast.Asset_Term_End_Date__c          = oli.ARR_Term_End_Date__c;
            oliAst.ast.ARR__c                          = oli.Annual_Recurring_Revenue__c;
        }
        else if (oli.Line_Type__c == 'Extension')
        {
            oliAst.ast.ARR__c           = NullSafeAdd(oliAst.ast.ARR__c, oli.Annual_Recurring_Revenue__c);
        }
        else if (oli.Line_Type__c == 'Decommission')
        {
            oliAst.ast.Previous_Annual_Maintenance__c = oliAst.ast.ARR__c;
            oliAst.ast.Previous_Metric_Qty__c = oliAst.ast.License_Metric_Quantity__c;
            oliAst.ast.Asset_ARR_at_Decommission__c = oliAst.ast.ARR__c;
            
            // NOTE: All amounts are being *added* to the existing values, so a decrease
            //        in an amount value needs to be negative.
            oliAst.ast.ARR__c           = NullSafeAdd(oliAst.ast.ARR__c, oli.Annual_Recurring_Revenue__c);
            // Need to reduce the LMQ as well, although now the total sold price doesn't match the LMQ anymore
            System.debug('====> LMQ before: ' + oliAst.ast.License_Metric_Quantity__c);
            oliAst.ast.License_Metric_Quantity__c  = NullSafeAdd(oliAst.ast.License_Metric_Quantity__c, -oli.Decommission_Quantity__c);
            System.debug('====> LMQ after: ' + oliAst.ast.License_Metric_Quantity__c);
            
            oliAst.ast.Cancellation_Reason__c = oli.Cancellation_Reason__c;
            oliAst.ast.Cancellation_Type__c = oli.Cancellation_Type__c;
            oliAst.ast.Cancellation_Date__c = oli.Cancellation_Date__c;
            if (oli.Cancellation_Type__c == 'Cancellation')
            {
                oliAst.ast.Maintenance_Status__c = 'Decommissioned';
            }
        }
    }
    
    private static Asset__c createAssetFromOLI(OpportunityLineItem oli)
    {
        Asset__c ast = new Asset__c();
        
        ast.Account__c = oli.Opportunity.AccountID;
        ast.Name = oli.PriceBookEntry.Product2.Name;
        ast.Name = ast.Name.subString(0, Math.min(79, ast.Name.length()));
        ast.Product__c = oli.PriceBookEntry.Product2ID;
        ast.ARR__c = oli.Annual_Recurring_Revenue__c;
        ast.Non_Recurring_Revenue__c = oli.Non_Recurring_Revenue__c;
        ast.Description__c = oli.PricebookEntry.Product2.Description;
        ast.Map_Notes__c = oli.Map_Notes__c;
        ast.Billing_Frequency__c = oli.Billing_Frequency__c;
        
        if(oli.Line_Type__c == 'Decommission') // Decommission of bundle products
            ast.License_Metric_Quantity__c = oli.Decommission_Quantity__c;
        else
            ast.License_Metric_Quantity__c = oli.License_Metric_Quantity__c;
        
        ast.Maintenance_Status__c = 'On Maintenance';
        ast.Asset_Term_Start_Date__c = oli.ARR_Term_Begin_Date__c;
        ast.Asset_Term_End_Date__c = oli.ARR_Term_End_Date__c;
        ast.Contract_Term_Start_Date__c = oli.Contract_Term_Start_Date__c;
        ast.Contract_Term_End_Date__c = oli.Contract_Term_End_Date__c;
        ast.Product_Group__c = oli.Product_Group__c;
        ast.Unit_Sales_Price__c = oli.Unit_Sales_Price__c;
        ast.Dollars_Per_Load__c = oli.Dollars_Per_Load__c;
        ast.Dollars_Per_Truck__c = oli.Dollars_Per_Truck__c;
        ast.Number_of_DCs__c = oli.Licensed_DCs__c;
        ast.Number_of_Users__c = oli.Licensed_Users__c;
        ast.Included_DCs__c = oli.Included_DCs__c;
        ast.Included_Users__c = oli.Included_Users__c;
        ast.Extra_DCs__c = oli.Extra_DCs__c;
        ast.Extra_Users__c = oli.Extra_Users__c;
        ast.OLI_Line_Type__c = oli.Line_Type__c;
        ast.Add_On_To__c = oli.Add_On_To_Asset__c;
        ast.Contract__c = oli.Contract__c;
        if (oli.Opportunity.RecordType.Name == 'Eval') {
            ast.Eval__c = true;
        }
        return ast;
    }
    
    
    private static Asset__c updateAssetFromOLI(OpportunityLineItem oli)
    {
        OpportunityLineItem thisOppLineItem = oli;
        // Old
        Asset__c ast = oli.Asset__r;
        // New
        //Asset__c ast = getAssetRec(thisOppLineItem.Asset__c);
        
        if(oli.Line_Type__c == 'Renewal')
        {
            ast.Previous_Annual_Maintenance__c = ast.ARR__c;
            ast.Previous_Metric_Qty__c = ast.License_Metric_Quantity__c;
            ast.ARR__c = oli.Annual_Recurring_Revenue__c;
            ast.Non_Recurring_Revenue__c = oli.Non_Recurring_Revenue__c;
            ast.Billing_Frequency__c = oli.Billing_Frequency__c;
            ast.Asset_Term_Start_Date__c = oli.ARR_Term_Begin_Date__c;
            ast.Asset_Term_End_Date__c = oli.ARR_Term_End_Date__c;
            ast.License_Metric_Quantity__c = oli.License_Metric_Quantity__c;
            ast.Map_Notes__c = oli.Map_Notes__c;
            ast.Contract_Term_Start_Date__c = oli.Contract_Term_Start_Date__c;
            ast.Contract_Term_End_Date__c = oli.Contract_Term_End_Date__c;
            ast.Number_of_DCs__c = oli.Licensed_DCs__c;
            ast.Number_of_Users__c = oli.Licensed_Users__c;
            ast.Included_DCs__c = oli.Included_DCs__c;
            ast.Included_Users__c = oli.Included_Users__c;
            ast.Extra_DCs__c = oli.Extra_DCs__c;
            ast.Extra_Users__c = oli.Extra_Users__c;
            if (oli.Contract__c != null)
                ast.Contract__c = oli.Contract__c;
        }
        else if(oli.Line_Type__c == 'Decommission')
        {         
            ast.Previous_Annual_Maintenance__c = ast.ARR__c;
            ast.Previous_Metric_Qty__c = ast.License_Metric_Quantity__c;
            ast.Asset_ARR_at_Decommission__c = ast.ARR__c;
            ast.License_Metric_Quantity__c -= oli.Decommission_Quantity__c;
            ast.ARR__c = NullSafeAdd(ast.ARR__c, oli.Annual_Recurring_Revenue__c);
            ast.Non_Recurring_Revenue__c = NullSafeAdd(ast.Non_Recurring_Revenue__c, oli.Non_Recurring_Revenue__c);
            ast.Cancellation_Reason__c = oli.Cancellation_Reason__c;
            ast.Cancellation_Type__c = oli.Cancellation_Type__c;
            ast.Cancellation_Date__c = oli.Cancellation_Date__c;
            if (oli.Cancellation_Type__c == 'Cancellation') {
                ast.Maintenance_Status__c = 'Decommissioned';
            }
        }
        else if (oli.Line_Type__c == 'Extension')
        {
            ast.Previous_Annual_Maintenance__c = ast.ARR__c;
            ast.Previous_Metric_Qty__c = ast.License_Metric_Quantity__c;
            ast.ARR__c = NullSafeAdd(ast.ARR__c, oli.Annual_Recurring_Revenue__c);
            ast.Non_Recurring_Revenue__c = NullSafeAdd(ast.Non_Recurring_Revenue__c, oli.Non_Recurring_Revenue__c);
            ast.License_Metric_Quantity__c = NullSafeAdd(ast.License_Metric_Quantity__c, oli.License_Metric_Quantity__c);
            ast.Contract_Term_Start_Date__c = oli.Contract_Term_Start_Date__c;
            ast.Contract_Term_End_Date__c = oli.Contract_Term_End_Date__c;
            ast.Number_of_DCs__c = oli.Licensed_DCs__c;
            ast.Number_of_Users__c = oli.Licensed_Users__c;
            ast.Included_DCs__c = oli.Included_DCs__c;
            ast.Included_Users__c = oli.Included_Users__c;
            ast.Extra_DCs__c = oli.Extra_DCs__c;
            ast.Extra_Users__c = oli.Extra_Users__c;
            if (oli.Contract__c != null)
                ast.Contract__c = oli.Contract__c;
        }
        else if (oli.Line_Type__c == 'Migration')
        {
            ast.ARR__c = NullSafeAdd(ast.ARR__c, oli.Annual_Recurring_Revenue__c);
            ast.Non_Recurring_Revenue__c = NullSafeAdd(ast.Non_Recurring_Revenue__c, oli.Non_Recurring_Revenue__c);
            ast.License_Metric_Quantity__c = NullSafeAdd(ast.License_Metric_Quantity__c, oli.License_Metric_Quantity__c);
            ast.Product__c = oli.PriceBookEntry.Product2ID;
            if (oli.Contract__c != null)
                ast.Contract__c = oli.Contract__c;
        }    
        
        return ast;
    }
    
    public static list<Fulfillment_Event__c> createDecomissionFulfillmentRecs(List<OpportunityLineItem> oliList)
    {
        list<Fulfillment_Event__c> fList = new list<Fulfillment_Event__c>();
        
        for(OpportunityLineItem oli :oliList)
        {
        
            if(oli.Asset__c != null && oli.Line_Type__c == 'Decommission' && oli.Decommission_Quantity__c != null && oli.Decommission_Quantity__c > 0)
            {
                fList.add( new Fulfillment_Event__c( Asset__c = oli.Asset__c
                                                 ,Event_Date__c = System.today()
                                                 ,License_Metric_Quantity__c = (-1*oli.Decommission_Quantity__c)
                                                 ,Event_Type__c = 'Decommission'));
            }
        }
        return fList;
    }
    
    //used by the opportunity trigger to determine which opptys will go through the asset update process
    /*public static Set<String> validAssetUpdateOpptyOrderTypes
    {
        get
        {
            if(validAssetUpdateOpptyOrderTypes == null)
            {
                validAssetUpdateOpptyOrderTypes = new Set<String>();
                validAssetUpdateOpptyOrderTypes.add('AddOn');
                validAssetUpdateOpptyOrderTypes.add('Maintenance');
                validAssetUpdateOpptyOrderTypes.add('New');
                validAssetUpdateOpptyOrderTypes.add('Term License');
                validAssetUpdateOpptyOrderTypes.add('Change Order');
                validAssetUpdateOpptyOrderTypes.add('Migration');
            }
        return validAssetUpdateOpptyOrderTypes;
        }
        private set;
    }*/
    /*
    class OLIAssetWrapper
    {
        public OpportunityLineItem oli{get; set;}
        public OpportunityLineItem maintOLI {get; set;} // for tracking the maintenance OLI so we can update it as having been processed
        public Asset__c ast {get; set;}
    }
    
    /*
    *  @author:        Mark De Chavez
    *  @description:   checks the VCG_CPQ_Quote_Product__c if there are missing shipment schedules and prevent it from updating if there is any
    *  @parameters:    newOppList - trigger.new 
    *                  oldOppMap  - trigger.oldMap
    */
    /*public static void oppStageOnChange(List<Opportunity> newOppList, Map<Id, Opportunity> oldOppMap){
        map<Id, boolean> OppsWithApprovedQuote = new map<Id, boolean>();
        map<Id, list<VCG_CPQ_Quote_Product__c>> SalesCompleteOpps = new map<Id, list<VCG_CPQ_Quote_Product__c>>();
        
        for (Opportunity newOpp : newOppList) {
            Opportunity oldOpp = oldOppMap.get(newOpp.Id);
            
            
            if (oldOpp.StageName != newOpp.StageName && newOpp.StageName == 'Sales Complete') 
            {
                SalesCompleteOpps.put(newOpp.Id, new list<VCG_CPQ_Quote_Product__c>());
                OppsWithApprovedQuote.put(newOpp.Id, false);
            }
        }
        
        for(VCG_CPQ_Quote_Product__c p : [SELECT Id, Quote__r.Opportunity__c
                                            FROM VCG_CPQ_Quote_Product__c 
                                           WHERE Product__r.Shipment_Schedule_Required__c = TRUE 
                                             AND Quote__r.Is_Primary__c = TRUE 
                                             AND Number_of_Shipment_Forecasts__c = 0 
                                             AND Quote__r.Opportunity__c in : SalesCompleteOpps.keySet()
                                             AND Line_Type__c != 'Decommission'
                                             AND License_Metric_Quantity__c != null
                                             AND License_Metric_Quantity__c > 0])
        {
            list<VCG_CPQ_Quote_Product__c> l = SalesCompleteOpps.get(p.Quote__r.Opportunity__c);
            l.add(p);
            
        }
        
        //look across all other Quotes
        for(VCG_CPQ_Quote__c q : [Select Id, Is_Primary__c, Opportunity__c 
                                     from VCG_CPQ_Quote__c 
                                   where Opportunity__c in :SalesCompleteOpps.keySet()
                                     and Is_Primary__c = true])
        {
            OppsWithApprovedQuote.put(q.Opportunity__c, q.Is_Primary__c);
        }
        
        for (Opportunity newOpp : newOppList)
        {
            if(SalesCompleteOpps.containsKey(newOpp.Id))
            {
               if(SalesCompleteOpps.get(newOpp.Id).size() > 0)
               {
                   newOpp.addError('Cannot change Opportunity Stage. There are missing Shipment Schedules for Products that require them.');
               }
               if(OppsWithApprovedQuote.get(newOpp.Id) == false && !(newOpp.Order_Sub_Type__c == 'Annual Increase'))
               {
                   newOpp.addError('An Opportunity must have at least one primary Quote before setting the stage to "Sales Complete"');
               }
             }
        }
        
        
        
    }
    
    /*
    *  @author:        Mark De Chavez
    *  @description:   assigns value to sp_products__c whenever a product is added to an opportunity
    *  @parameters:    newOppList - trigger.new 
    */
    /*public static void updateSpProduct(List<Opportunity> newOpplist){
        Set<Id> oppIdSet = new Set<Id>();
        Map<Id, Opportunity> oppIdMap = new Map<Id, Opportunity>();
        for (Opportunity opp : newOppList){
            oppIdSet.add(opp.Id);
            oppIdMap.put(opp.Id, opp);
        }
        
        Map<Id, Set<String>> oppSPMap = new Map<Id, Set<String>>();
        for (OpportunityLineItem oppLineItm : [SELECT pricebookentry.Product2.ProductCode, opportunityId FROM OpportunityLineItem WHERE OpportunityId =: oppIdSet]){
            if (oppIdSet.contains(OppLineItm.OpportunityId)){
                if (oppSPMap.containsKey(OppLineItm.OpportunityId)){                     
                    oppSPMap.get(OppLineItm.OpportunityId).add(oppLineItm.pricebookentry.Product2.ProductCode); 
                    System.debug('*** pcode1: ' + oppLineItm.pricebookentry.Product2.ProductCode);                
                }
                else {                     
                    oppSPMap.put(OppLineItm.OpportunityId, new Set<String>{oppLineItm.pricebookentry.Product2.ProductCode});
                    System.debug('*** pcode2: ' + oppLineItm.pricebookentry.Product2.ProductCode);
                }
            }
        }
        
        for (Id oppId : oppSPMap.keySet()){
            Opportunity opp = new Opportunity();
            String spProd = '';
            for (String prodCode : oppSPMap.get(oppId)){   
                System.debug('****prodCode: '+prodCode);              
                spProd = spProd + ';' + prodCode ;
            }
            if (spProd.length() > 0) {
                spProd = spProd.substring(1, spProd.length());
            }
            opp = oppIdMap.get(oppId);
            System.debug('****SPPROD: '+spProd);
            opp.SP_Products__c = spProd;             
        }       
    }
    
    /*
    *  @author:        Mark Malanowski
    *  @description:   Sets Finance Status to Needs Review
    *  @parameters:    newMap - trigger.newmap, oldMap - trigger.oldmap
    */
    /*public static void triggerFinanceApprovalBefore(Map<Id, Opportunity> newMap, Map<Id, Opportunity> oldMap) {
        for (Opportunity o : newMap.values()) {
            if ((o.Legal_Review__c == 'Waiting for Finance Review' && oldMap.get(o.Id).Legal_Review__c == 'In Review') 
                || o.Legal_Review__c == 'Approved' && oldMap.get(o.Id).Legal_Review__c == 'In Review') {
                    o.Finance_Status__c = 'Needs Review';
                }
        }
    }
    
    /*
    *  @author:        Mark Malanowski
    *  @description:   triggers approval process
    *  @parameters:    newMap - trigger.newmap, oldMap - trigger.oldmap
    */
    /*public static void triggerFinanceApprovalAfter(Map<Id, Opportunity> newMap, Map<Id, Opportunity> oldMap) {
        for (Opportunity o : newMap.values()) {
            if ((o.Legal_Review__c == 'Waiting for Finance Review' && oldMap.get(o.Id).Legal_Review__c == 'In Review') 
                || o.Legal_Review__c == 'Approved' && oldMap.get(o.Id).Legal_Review__c == 'In Review') {
                    Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
                    req.setComments('Automatically submitted for Finance Approval by Legal.');
                    req.setObjectId(o.Id);
                    try {
                        Approval.process(req);
                    }
                    catch (Exception e) {
                        System.debug('No applicable approval process found.');
                    }
                }
        }
    }
    
    
    @future
    public static void syncAccountUserAndDcTotals(Set<Id> accountIds)
    {
        if(accountIds.size() == 0)
        {
           return; 
        }
        
        List<Account> accountList = new List<Account>();
        
//        map<Id, Account> accountMap = new map<Id, Account>([Select Total_Allowed_DCs__c, Total_Allowed_Users__c 
//                                                                from Account
//                                                               where Id in :accountIds]);
        
        map<Id, Decimal> maxDCMap  = new map<Id, Decimal>();
        map<Id, Decimal> maxUserMap  = new map<Id, Decimal>();
        map<Id, Decimal> sumExtraDCMap  = new map<Id, Decimal>();
        map<Id, Decimal> sumExtraUserMap  = new map<Id, Decimal>();
        
        // Initialize the maps so our code is simpler below
        for (Id acctId : accountIds)
        {
            maxDCMap.put(acctId, 0);
            maxUserMap.put(acctId, 0);
            sumExtraDCMap.put(acctId, 0);
            sumExtraUserMap.put(acctId, 0);
        }
        
        
        //=== On the Account, we do: ===
        //MAX(SUM of IncludedDCs Grouping by Product) + SUM(Extra DCs)
        for(AggregateResult ap : [SELECT sum(Included_DCs__c) sumIncludedDCsForProd
                                       , sum(Included_Users__c) sumIncludedUsersForProd
                                       , sum(Extra_DCs__c) extraDCsForProd
                                       , sum(Extra_Users__c) extraUsersForProd
                                       , Account__c acctId
                                       , Product__c
                                    FROM Asset__c
                                   WHERE Account__c in :accountIds
                                         AND Maintenance_Status__c IN :VCG_CPQ_QuoteController.onMaintenanceStatuses
                                GROUP BY Account__c, Product__c])
        {
            Id accId = (Id)ap.get('acctId');
            Decimal  sumIncludedDCsForProd = (Decimal)ap.get('sumIncludedDCsForProd');
            Decimal  sumIncludedUsersForProd = (Decimal)ap.get('sumIncludedUsersForProd');
            Decimal  extraDCsForProd = (Decimal)ap.get('extraDCsForProd');
            Decimal  extraUsersForProd = (Decimal)ap.get('extraUsersForProd');
            
            System.debug(LoggingLevel.ERROR, '====> Included DCs: ' + sumIncludedDCsForProd + ', Extra DCs: ' + extraDCsForProd + ', Included Users: ' + sumIncludedUsersForProd + ', Extra Users: ' + extraUsersForProd);
            
            // collect max included DCs & Users across all products
            if (sumIncludedDCsForProd > maxDCMap.get(accId))
                maxDCMap.put(accId, sumIncludedDCsForProd);
            
            if (sumIncludedUsersForProd > maxUserMap.get(accId))
                maxUserMap.put(accId, sumIncludedUsersForProd);
            
            // sum up extra DCs & Users across all products
            sumExtraDCMap.put(accId, sumExtraDCMap.get(accId) + extraDCsForProd);
            sumExtraUserMap.put(accId, sumExtraUserMap.get(accId) + extraUsersForProd);
            
            System.debug(LoggingLevel.ERROR, '====> Max Included DCs: ' + maxDCMap.get(accId) + ', Sum Extra DCs: ' + sumExtraDCMap.get(accId) + ', Max Included Users: ' + maxUserMap.get(accId) + ', Sum Extra Users: ' + sumExtraUserMap.get(accId));
        }
        
        // Calculate the total allowed users and assign back to the account
        for (Id accId : accountIds)
        {
            Account a = new Account(Id = accId);
            
            // calculate the total allowed DC and User Values
            a.Total_DCs__c   = maxDCMap.get(accId)   + sumExtraDCMap.get(accId);
            a.Total_Users__c = maxUserMap.get(accId) + sumExtraUserMap.get(accId);
            
            System.debug(LoggingLevel.ERROR, '====> Total DCs: ' + a.Total_DCs__c + ', Total Users: ' + a.Total_Users__c);
            
            accountList.add(a);
        }
        
        // Update the Accounts
        update accountList;
    }
    
    /*Prevents sales users from editing closed opportunities*/
    /*public static void validateOpptyEditability(List<Opportunity> lstOpps, Map<Id,Opportunity> oldMap){
        Set<String> setAllowedFields = new Set<String>();
        Set<String> setOpptyFields = new Set<String>();
        
        //Gets list of fields that can be edited, from custom settings.
        if (Global_Variable__c.getInstance('OpptyLock_AllowedFields') != null && String.isNotBlank(Global_Variable__c.getInstance('OpptyLock_AllowedFields').value__c)){
            setAllowedFields.addAll(Global_Variable__c.getInstance('OpptyLock_AllowedFields').value__c.split(',',0));
        }
        
        //Get list of fields on Opportunity from object schema
        Map<String, Schema.SObjectField> mapOpptyFields = Schema.SObjectType.Opportunity.fields.getMap();
        for (String strField : mapOpptyFields.keyset()){
            setOpptyFields.add(String.valueOf(mapOpptyFields.get(strField)));
        }
        
        if (Apex_UserInfo.validateUserForOpptyLock(userInfo.getUserId(),UserInfo.getProfileId())){
            for (Opportunity oppty : lstOpps){
                if (oldMap.get(oppty.Id).StageName == 'Closed Won' || oldMap.get(oppty.Id).StageName == 'Closed Lost'){
                    for (String field : setOpptyFields){
                        if(!setAllowedFields.contains(field) && oppty.get(field) != oldMap.get(oppty.id).get(field)){
                            Oppty.AddError('Closed Opportunity cannot be edited');
                        }
                    
                    }
                }
            }
        }
    }
    
    
    /**
    * Zero if null / Blank if null methods
    *
    * NullSafeAdd -- returns null if both parameters are null, otherwise adds the two, converting either parameter to 0 if it is null
    *
    * @author  Lawrence Coffin <lawrence.coffin@cloudsherpas.com>
    * @since   26.Dec.2014
    */
    /*public static Decimal ZiN(Decimal x) { return (x == null ? 0.0 : x); }
    public static Integer ZiN(Integer x) { return (x == null ? 0 : x); }
    public static String  BiN(String  x) { return (x == null ? '' : x); }
    public static Decimal NullSafeAdd(Decimal x, Decimal y) { return (x == null && y == null ? null : (x == null ? 0 : x) + (y == null ? 0 : y)); }
    public static Integer NullSafeAdd(Integer x, Integer y) { return (x == null && y == null ? null : (x == null ? 0 : x) + (y == null ? 0 : y)); }
    */
}