/***********************************************************************************************************************
* @description   
* @author  Scott Warren <swarren@vepcg.com>
* @since   24.Mar.2014


NOTES: 
Assumptions:
    1) There can only be 1 instance of each product inside the same product grouping
    2) Product Grouping names are unique and do not contain special characters

@todo Create logic to ensure that only 1 instance of an addon is returned to the suggested addon display

@todo Ceiling / Floor / Increment rules should only fire on rules with Depends On populated if Depends On exists within Package
************************************************************************************************************************/
public without sharing class VCG_CPQ_ProductUtility{

    //Wrapper class used to combine assets and quote products passed to the validation method.
    public class AssetProductWrapper{
        public String productId = null;
        public String productName = null;
        public Decimal quantity = null;
        public String originalType = null;
        public String productGroup = null;
        
        public assetProductWrapper(String prodId, String prodName, Decimal qty, String oType, String productGroup){
            this.productId = prodId;
            this.productName = prodName;
            this.quantity = qty;
            this.originalType = oType;
            this.productGroup = productGroup;
        }
        
        public assetProductWrapper(String prodId, String prodName, String oType, String productGroup){
            this.productId = prodId;
            this.productName = prodName;
            this.originalType = oType;
            this.quantity = 0;
            this.productGroup = productGroup;
        }
    }

    public class ProductPackage{
        public String scope = null;
        public String productGroup = null;
        public Map<String, AssetProductWrapper> id_product_map = null;
    
        public productPackage(String scope, String productGroup, Map<String, AssetProductWrapper> productMap){
            this.scope = scope;
            this.productGroup = productGroup;
            this.id_product_map = productMap;
        }
    }

    //Use Temporarily to not break existing sandbox functionality
    public static List<VCG_CPQ_Product_Addon_Wrapper> getAddonProducts(List<VCG_CPQ_Quote_Product__c> selectedProducts){
        
        return getAddonProducts(new VCG_CPQ_Quote__c(), selectedProducts);
    }
/***********************************************************************************************************************
* @description  Method used to retrieve a list of all addon products associated with a list of core products selected 
* @author  Scott Warren <swarren@vepcg.com>
* @since   24.Mar.2014
************************************************************************************************************************/   
    public static List<VCG_CPQ_Product_Addon_Wrapper> getAddonProducts(VCG_CPQ_Quote__c quote, List<VCG_CPQ_Quote_Product__c> selectedProducts){
        List<Product2> addonProducts = new List<Product2>();
        set<Id> addonProductIds = new set<Id>();
        set<Id> selectedProdIds = new set<Id>();
        
        List<VCG_CPQ_Product_Addon__c> prodAddons = new List<VCG_CPQ_Product_Addon__c>();
        List<VCG_CPQ_Product_Addon_Wrapper> addonWrappers = new List<VCG_CPQ_Product_Addon_Wrapper>();
        Map<String, VCG_CPQ_Quote_Product__c> selectedMap = new Map<String, VCG_CPQ_Quote_Product__c>(); 
        
        for(VCG_CPQ_Quote_Product__c selectedProd : selectedProducts){
            selectedMap.put(selectedProd.Product__c, selectedProd);
        }

        //Removed filter to include all possible addons due to the addition of the "Addon Group" field. 
        Map<Id, VCG_CPQ_Product_Addon__c> prodAddonMap = new Map<Id, VCG_CPQ_Product_Addon__c>([SELECT Product__c,
                                                                                                       Product_Addon__c,
                                                                                                       Required__c,
                                                                                                       Addon_Group__c,
                                                                                                       Needs_Fields__c
                                                                                                FROM VCG_CPQ_Product_Addon__c
                                                                                                WHERE Product__c IN :selectedMap.keySet()
                                                                                                      AND Product__r.IsActive = TRUE
                                                                                                      AND Product_Addon__r.IsActive = TRUE]);
        
/* I think this is implementing an AND condition... for a product to be recommended, Core A AND Core B AND Core C have to be on the quote...
   Don't think we'd ever want that, so can possibly switch this around to actually being OR in the other direction.... If Core A is being bought, then Add On A OR Add On B *must* be bought */
/*      Code Used to implement Addon Groups - OR Condition for Addons. Disabled 06/14

        Map<String, List<VCG_CPQ_Product_Addon__c>> group_addon_map = new Map<String, List<VCG_CPQ_Product_Addon__c>>();
            
        //Assign Addon Groups and related records to map 
        for(VCG_CPQ_Product_Addon__c prodAddon : prodAddonMap.values()){
            if(prodAddon.Addon_Group__c == null || prodAddon.Addon_Group__c == ''){
                if(group_addon_map.containsKey('Default')){
                    group_addon_map.get('Default').add(prodAddon);
                }
                else{
                    group_addon_map.put('Default', new List<VCG_CPQ_Product_Addon__c>{prodAddon});
                }               
            }
            else{
                if(group_addon_map.containsKey(prodAddon.Addon_Group__c)){
                    group_addon_map.get(prodAddon.Addon_Group__c).add(prodAddon);
                }
                else{
                    group_addon_map.put(prodAddon.Addon_Group__c, new List<VCG_CPQ_Product_Addon__c>{prodAddon});
                }               
            }
        } 

        
        Set<VCG_CPQ_Product_Addon__c> finalAddons = new Set<VCG_CPQ_Product_Addon__c>();

        //Check Addon Groups for all Primary products before adding to final addon list
        Boolean missingGroupItem;
        for(String groupName : group_addon_map.keySet()){
            if(groupName != 'Default'){
                missingGroupItem = false;
                for(VCG_CPQ_Product_Addon__c prodAdd : group_addon_map.get(groupName)){
                    if(!selectedMap.containsKey(prodAdd.Product__c)){
                        missingGroupItem = true;
                    }
                }
                if(missingGroupItem == false){
                    finalAddons.addAll(group_addon_map.get(groupName));
                }
            }
            else{
                for(VCG_CPQ_Product_Addon__c prodAdd : group_addon_map.get(groupName)){
                    if(selectedMap.containsKey(prodAdd.Product__c)){
                        finalAddons.add(prodAdd);
                    }
                }
            }
        }
        
        for(VCG_CPQ_Product_Addon__c finalAddon : finalAddons){
            addonProductIds.add(finalAddon.Product_Addon__c);   
        }
*/
        
        Map<Id, VCG_CPQ_Product_Addon__c> addonId_addon_map = new Map<Id, VCG_CPQ_Product_Addon__c>();
        String needsFields = '';
        for(VCG_CPQ_Product_Addon__c addon : prodAddonMap.values()){
            addonId_addon_map.put(addon.Product_Addon__c, addon);
            needsFields += addon.Needs_Fields__c;
            needsFields += ';';
        }

        //
        // Query relevant products
        //
        // (Set up temp variables for the Ids, because we can't interpolate 'variable.keySet()' into a query handled through Database.query()
        List<String> prodIds1 = new List<Id>();
        prodIds1.addAll(selectedMap.keySet());
        List<Id> prodIds2 = new List<Id>();
        prodIds2.addAll(addonId_addon_map.keySet());
        String soql = 'SELECT '
                        +   String.join(GetProductFields(), ', ')
                        + ' FROM Product2 '
                        + ' WHERE Id IN :prodIds1 '
                        + '       OR Id IN :prodIds2';
        System.debug('====> AddOn Products query: ' + soql);
        Map<Id, Product2> productMap = new Map<Id, Product2>((List<Product2>)Database.query(soql));
        
        //Query incompatibility records for relevant products
        Map<Id,VCG_CPQ_Product_Incompatibility__c> incompatibilityMap = new Map<Id, VCG_CPQ_Product_Incompatibility__c>([SELECT Id, Name, Product_1__c, Product_2__c, Scope__c
                                                                                                                            FROM VCG_CPQ_Product_Incompatibility__c
                                                                                                                            WHERE Product_1__c in :selectedMap.keySet()
                                                                                                                            OR Product_1__c in :addonId_addon_map.keySet()]);
        
        
        Map<Id, List<Id>> productIncompatMap = new Map<Id, List<Id>>();
        for(VCG_CPQ_Product_Incompatibility__c incompat : incompatibilityMap.values()){
            if(incompat.Scope__c == 'Grouping'){
                if(productIncompatMap.containsKey(incompat.Product_1__c)){
                    productIncompatMap.get(incompat.Product_1__c).add(incompat.Product_2__c);
                }
                else{
                    productIncompatMap.put(incompat.Product_1__c, new List<String>{incompat.Product_2__c});
                }
                if(productIncompatMap.containsKey(incompat.Product_2__c)){
                    productIncompatMap.get(incompat.Product_2__c).add(incompat.Product_1__c);
                }
                else{
                    productIncompatMap.put(incompat.Product_2__c, new List<String>{incompat.Product_1__c});
                }               
            }
        }

// Commenting out this next line ... not sure why we are checking for quote.Name to be set... -LC 29.Sep.2014
//      if(quote.Name != null){         
            List<VCG_CPQ_Quote__c> needsFieldsQuotes = new List<VCG_CPQ_Quote__c>();        
            needsFieldsQuotes = VCG_CPQ_NeedsFieldsUtility.getNeedsFields(new List<VCG_CPQ_Quote__c>{quote}, needsFields);
            
            VCG_CPQ_Quote__c needsFieldsQuote = needsFieldsQuotes[0];
            VCG_CPQ_Data.addChildren(needsFieldsQuote, 'Quote_Products__r', selectedProducts);
            

            
            for(VCG_CPQ_Quote_Product__c quoteProd : selectedProducts){
                for(VCG_CPQ_Product_Addon__c addon : addonId_addon_map.values()){
                    if(addon.Product__c == quoteProd.Product__c){
System.debug('evaluating addon: ' + addon);
System.debug('evaluating product: ' + quoteProd);                       
                        if(VCG_CPQ_Formula.evaluate(needsFieldsQuote, addon.Required__c).value == 1.0){
                            addonWrappers.add(new VCG_CPQ_Product_Addon_Wrapper(quoteProd, productMap.get(addon.Product_Addon__c), true, true));
                        }
                        else{
                            addonWrappers.add(new VCG_CPQ_Product_Addon_Wrapper(quoteProd, productMap.get(addon.Product_Addon__c), false, true));
                        }
                    }
                }           
            }           
//      }
        

/*
        Boolean addonCompat = true;
        for(VCG_CPQ_Quote_Product__c quoteProd : selectedProducts){
            for(VCG_CPQ_Product_Addon__c addon : addonId_addon_map.values()){
                if(addon.Product__c == quoteProd.Product__c){
                    if(addon.Required__c == true){
                        addonWrappers.add(new VCG_CPQ_Product_Addon_Wrapper(quoteProd, productMap.get(addon.Product_Addon__c), true, true));
                    }
                    else{
                        addonWrappers.add(new VCG_CPQ_Product_Addon_Wrapper(quoteProd, productMap.get(addon.Product_Addon__c), false, true));
                    }
                }
            }
        }
*/
        //Incompatibility Check
        for(VCG_CPQ_Product_Addon_Wrapper addonWrp : addonWrappers){
            if(productIncompatMap.containsKey(addonWrp.addonProduct.Id)){
                for(String selectedId : selectedMap.keySet()){
                    for(String incompat : productIncompatMap.get(addonWrp.addonProduct.Id)){
                        if(selectedId == incompat){
                            addonWrp.compatible = false;
                        }   
                    }
                }
            }
        }
        
        return addonWrappers;
    }


    /**
     * @description 
     *
     *               NOTE: Do not use this method for more than a few calls in one invocation...
     *                     otherwise you will hit limits pretty quick.
     *                
     * @author  Lawrence Coffin <lawrence.coffin@cloudsherpas.com>
     * @since   14.Sep.2014
     */   
    public static Product2 GetProductBySku(String sku)
    {
        String soql = 'SELECT '
                        +   String.join(VCG_CPQ_ProductUtility.GetProductFields(), ', ')
                        + ' FROM Product2 '
                        + ' WHERE IsActive = TRUE '
                        + '       AND ProductCode = :sku';
        List<Product2> prods = Database.query(soql);
        if (prods.size() > 0)
        {
            return prods[0];
        }
        /** @todo  Add check here for more than one match and throw an error or something */
        
        return null;
    }
    

    /**
     * @description 
     *                
     * @author  Lawrence Coffin <lawrence.coffin@cloudsherpas.com>
     * @since   10.Sep.2014
     */   
    public static List<String> GetProductFields()
    {
        //
        // Start with the Set of fields needed in the CPQ code (standard CPQ fields)
        // Note: A Set is used to ensure we don't have duplicates when merging in the
        //       Needs Fields list.
        //
        Set<String> productFields = new Set<String>{
                                                        'Id', 
                                                        'Family', 
                                                        'Name', 
                                                        'ProductCode', 
                                                        'Available_for_Net_New__c',
                                                        'CPQ_Display_Type__c',
                                                        'Is_Groupable__c',
                                                        'Is_Maintenance__c',
                                                        'Is_Perpetual__c', 
//                                                        'Product_Type__c',
                                                        'Product_Filter_Key__c',
                                                        'License_Metric__c',
                                                        'First_Year_Maintenance__c',
                                                        'Recurring_Maintenance__c',
                                                        'CPQ_Add_On_Grouping__c',
                                                        'Oracle_Part_Number__c'
                                                     };
        //
        // Add in additional fields needed for formulas and the like just for this org
        //
        productFields.addAll(VCG_CPQ_NeedsFieldsUtility.getNeedsFields('Product2'));
        System.debug('====> productFields: ' + productFields);
        
        // Convert set to list and return
        List<String> productFieldList = new List<String>();
        productFieldList.addAll(productFields);
        
        return productFieldList;
    }



/***********************************************************************************************************************
* @description - Validate the selected quote products and quantities against their associated dependency table records
*               Return collection of VCG_CPQ_Error objects - include every violation found during processing                
* @author  Scott Warren <swarren@vepcg.com>
* @since   24.Mar.2014
************************************************************************************************************************/   

    //Overloaded method for accounts without assets
    public static List<VCG_CPQ_Error> validateProductSelection(VCG_CPQ_Quote__c quote, List<VCG_CPQ_Quote_Product__c> selectedProducts){
        
        return validateProductSelection(quote, selectedProducts, new List<Asset__c>());
    }



    public static List<VCG_CPQ_Error> validateProductSelection(VCG_CPQ_Quote__c quote, List<VCG_CPQ_Quote_Product__c> selectedProducts, List<Asset__c> assets){
        System.debug('selected products: ' + selectedProducts);
        System.debug('selected assets: ' + assets);
        
        Set<Id> selectedProdIds = new Set<Id>(); 
        List<VCG_CPQ_Error> allErrors = new List<VCG_CPQ_Error>();
        
        List<VCG_CPQ_Error> productDependencyErrors = new List<VCG_CPQ_Error>();
        List<VCG_CPQ_Error> requiredAddonErrors = new List<VCG_CPQ_Error>();
        List<VCG_CPQ_Error> quantityGroupErrors = new List<VCG_CPQ_Error>();
        List<VCG_CPQ_Error> optionGroupErrors = new List<VCG_CPQ_Error>();
        List<VCG_CPQ_Error> productFloorErrors = new List<VCG_CPQ_Error>();
        List<VCG_CPQ_Error> productCeilingErrors = new List<VCG_CPQ_Error>();
        List<VCG_CPQ_Error> incrementErrors = new List<VCG_CPQ_Error>();
        List<VCG_CPQ_Error> incompatibilityErrors = new List<VCG_CPQ_Error>();
        
        selectedProdIds.addAll(getProductIds(selectedProducts));
        selectedProdIds.addAll(getProductIds(assets));
        
        Map<Id, Product2> selectedProductsMap = new Map<Id, Product2>([SELECT Id, Name from Product2 where Id in :selectedProdIds]);
        
        List<AssetProductWrapper> productWrps = new List<AssetProductWrapper>();
        Map<String, AssetProductWrapper> groupProdId_product_map = new Map<String, AssetProductWrapper>();
        for(VCG_CPQ_Quote_Product__c qp : selectedProducts){
            AssetProductWrapper apw = new AssetProductWrapper(qp.Product__c, selectedProductsMap.get(qp.Product__c).Name, qp.License_Metric_Quantity__c, String.valueOf(VCG_CPQ_Quote_Product__c.sObjectType), qp.Product_Group__c);
            productWrps.add(apw);
            groupProdId_product_map.put(apw.productGroup+'_'+apw.productId, apw);
        }
        
        for(Asset__c asset : assets){
            AssetProductWrapper apw = new AssetProductWrapper(asset.Product__c, selectedProductsMap.get(asset.Product__c).Name, asset.License_Metric_Quantity__c, String.valueOf(Asset__c.sObjectType), asset.Product_Group__c);
            productWrps.add(apw);
            groupProdId_product_map.put(apw.productGroup+'_'+apw.productId, apw);
        }

        //Populate Product Packages
        List<ProductPackage> productPackages = new List<ProductPackage>();
        AssetProductWrapper loopAPW;
        
        ProductPackage quotePkg = new ProductPackage('Quote', '', new Map<String, AssetProductWrapper>());
        for(AssetProductWrapper apw : productWrps){
            loopAPW = new AssetProductWrapper(apw.productId, apw.productName, apw.quantity, apw.originalType, apw.productGroup);
            if(quotePkg.id_product_map.containsKey(apw.productId) && quotePkg.id_product_map.get(apw.productId).quantity != null){             
                quotePkg.id_product_map.get(apw.productId).quantity += (apw.quantity == null ? 0 : apw.quantity);
            }
            else{
                quotePkg.id_product_map.put(apw.productId, loopAPW);
            }
        }
        
        productPackages.add(quotePkg);
        
        
        Boolean pkgExists = false;
        for(AssetProductWrapper apw : productWrps){     
            loopAPW = new AssetProductWrapper(apw.productId, apw.productName, apw.quantity, apw.originalType, apw.productGroup);    
            pkgExists = false;
            for(ProductPackage pkg : productPackages){
                //Populate all group level product packages             
                if(pkg.scope != 'Quote' && apw.productGroup == pkg.productGroup){
                    pkgExists = true;
                    pkg.id_product_map.put(apw.productId, loopAPW);                 
                }               
            }
            if(pkgExists == false){
                productPackages.add(new ProductPackage('Grouping', apw.productGroup, new Map<String, AssetProductWrapper>{apw.productId => loopAPW}));  
            }
        }
        
        

        System.debug('Product Packages: ' + productPackages);   

        //Product Rules Lists
        List<VCG_CPQ_Product_Rule__c> quantityGroupRules = new List<VCG_CPQ_Product_Rule__c>();
        List<VCG_CPQ_Product_Addon__c> requiredAddonRules = new List<VCG_CPQ_Product_Addon__c>();
        List<VCG_CPQ_Product_Rule__c> optionGroupRules = new List<VCG_CPQ_Product_Rule__c>();
        List<VCG_CPQ_Product_Rule__c> productDependencyRules = new List<VCG_CPQ_Product_Rule__c>();
        List<VCG_CPQ_Product_Rule__c> incrementRules = new List<VCG_CPQ_Product_Rule__c>();
        List<VCG_CPQ_Product_Rule__c> productFloorRules = new List<VCG_CPQ_Product_Rule__c>();
        List<VCG_CPQ_Product_Rule__c> productCeilingRules = new List<VCG_CPQ_Product_Rule__c>();
        
        List<VCG_CPQ_Product_Incompatibility__c> incompatibilities = new List<VCG_CPQ_Product_Incompatibility__c>();                                                                                            

        List<VCG_CPQ_Product_Rule__c> productRules = [SELECT Id, 
                                                             Name,
                                                             Product__c,
                                                             Product__r.Name,
                                                             Depends_On__c,
                                                             Depends_On__r.Name,
                                                             Ceiling__c,
                                                             Floor__c,
                                                             Increment__c,
                                                             Quantity_Group__c,
                                                             Option_Group__c,
                                                             Scope__c,
                                                             Condition__c,
                                                             Needs_Fields__c
                                                      FROM VCG_CPQ_Product_Rule__c
                                                      WHERE Product__r.Id in :selectedProdIds];
        
        String needsFields = '';
        for(VCG_CPQ_Product_Rule__c productRule : productRules){
            needsFields += productRule.Needs_Fields__c;
            needsFields += ';';
        }
        
        //Prepare quote for formula evaluation
        VCG_CPQ_Quote__c needsFieldsQuote = (VCG_CPQ_Quote__c)VCG_CPQ_NeedsFieldsUtility.getNeedsFields(new List<VCG_CPQ_Quote__c>{quote}, needsFields)[0];             
        VCG_CPQ_Data.addChildren(needsFieldsQuote, 'Quote_Products__r', selectedProducts);
        
        for(VCG_CPQ_Product_Rule__c activeRule : productRules){
            if(VCG_CPQ_Formula.evaluate(needsFieldsQuote, activeRule.Condition__c).value == 1.0){
                
                if(activeRule.Depends_On__c != null && activeRule.Option_Group__c == null /*&& productRule.Quantity_Group__c == null*/){
                    productDependencyRules.add(activeRule);
                }
                if(activeRule.Ceiling__c != null && activeRule.Ceiling__c != ''){
                    productCeilingRules.add(activeRule);
                }
                if(activeRule.Floor__c != null && activeRule.Floor__c != '' ){
                    productFloorRules.add(activeRule);
                }
                if(activeRule.Increment__c != null && activeRule.Increment__c != '' ){
                    incrementRules.add(activeRule);
                }           
                if(activeRule.Quantity_Group__c != null && activeRule.Quantity_Group__c != ''){
                    quantityGroupRules.add(activeRule);
                }           
                if(activeRule.Option_Group__c != null && activeRule.Option_Group__c != ''){
                    optionGroupRules.add(activeRule);
                }
            }
        }
        
        for(VCG_CPQ_Product_Addon__c addon : [SELECT Id,
                                                     Name,
                                                     Product__c,
                                                     Product__r.Name,
                                                     Product_Addon__c,
                                                     Product_Addon__r.Name,
                                                     Required__c,
                                                     Needs_Fields__c
                                                FROM VCG_CPQ_Product_Addon__c
                                              WHERE Product__c in :selectedProdIds
                                                    AND Product__r.IsActive = TRUE
                                                    AND Product_Addon__r.IsActive = TRUE]){
            
            if(addon.Required__c != null && addon.Required__c != '0'){
                requiredAddonRules.add(addon);
            }           
        }
        
        for(VCG_CPQ_Product_Incompatibility__c incompatibility : [SELECT Id, Name, Product_1__c, Product_2__c, Scope__c
                                                                    FROM VCG_CPQ_Product_Incompatibility__c
                                                                    WHERE Product_1__r.Id in :selectedProdIds
                                                                    OR Product_2__r.Id in :selectedProdIds]){
            incompatibilities.add(incompatibility);
        }

        //Relevant Product Rules for the Current Product Selection
        if(!requiredAddonRules.isEmpty()){
            requiredAddonErrors = checkRequiredAddons(quote, requiredAddonRules, selectedProducts, assets);
        }
        if(!productDependencyRules.isEmpty()){
            productDependencyErrors = checkDependentProducts(productDependencyRules, productPackages);
        }
        if(!quantityGroupRules.isEmpty()){
            quantityGroupErrors = checkQuantityGroup(quantityGroupRules, productPackages);
        }
        if(!optionGroupRules.isEmpty()){
            optionGroupErrors = checkOptionGroup(optionGroupRules, productPackages);
        }
        if(!productFloorRules.isEmpty()){
            productFloorErrors = checkProductFloor(productFloorRules, productPackages);
        }
        if(!productCeilingRules.isEmpty()){
            productCeilingErrors = checkProductCeiling(productCeilingRules, productPackages);
        }
        if(!incrementRules.isEmpty()){
            incrementErrors = checkProductIncrements(incrementRules, productPackages);
        }
        
        //Product Incompatibilities
        if(!incompatibilities.isEmpty()){
            incompatibilityErrors = checkIncompatibleProducts(incompatibilities, productPackages);
        }
        
        allErrors.addAll(productDependencyErrors);
        allErrors.addAll(requiredAddonErrors);
        allErrors.addAll(quantityGroupErrors);
        allErrors.addAll(optionGroupErrors);
        allErrors.addAll(productFloorErrors);
        allErrors.addAll(productCeilingErrors);
        allErrors.addAll(incrementErrors);
        allErrors.addAll(incompatibilityErrors);
        
        return allErrors;
    }



/***********************************************************************************************************************
* @description  -   Product Validation Sub-methods. Validates that distributed quantity dependencies are met. Considers validation scope.
* @author  Scott Warren <swarren@vepcg.com>
* @since   10.Jun.2014

Assumptions: 
    1. Product grouping names are unique across quotes
    2. Group names are unique within their scope (do not reuse group names for the same dependent product)
************************************************************************************************************************/
    private static List<VCG_CPQ_Error> checkQuantityGroup(List<VCG_CPQ_Product_Rule__c> activeProductRules, List<ProductPackage> productPackages){
        List<VCG_CPQ_Error> errors = new List<VCG_CPQ_Error>();
        Decimal primaryQty;
        Decimal dependentQty;
        String errorProducts;

        //<QuantityGroup, <PrimaryProduct, List<DependentProducts>>>
        Map <String, Map<AssetProductWrapper, Set<AssetProductWrapper>>> evaluationMap = new Map <String, Map<AssetProductWrapper, Set<AssetProductWrapper>>>();
        
        //Populate the evaluation map (maps quantity group products together across product scope groups)        
        for(ProductPackage pkg : productPackages){
            evaluationMap.clear();      

            for(VCG_CPQ_Product_Rule__c rule : activeProductRules){
                if(rule.Scope__c == pkg.scope){
                    if(pkg.id_product_map.containsKey(rule.Depends_On__c) && pkg.id_product_map.containsKey(rule.Product__c)){
                        if(evaluationMap.containsKey(rule.Quantity_Group__c)){
                            if(evaluationMap.get(rule.Quantity_Group__c).containsKey(pkg.id_product_map.get(rule.Depends_On__c))){
                                if(pkg.id_product_map.containsKey(rule.Product__c)){
                                    evaluationMap.get(rule.Quantity_Group__c).get(pkg.id_product_map.get(rule.Depends_On__c)).add(pkg.id_product_map.get(rule.Product__c)); 
                                }
                            }
                            else{
                                evaluationMap.get(rule.Quantity_Group__c).put(pkg.id_product_map.get(rule.Depends_On__c), new Set<AssetProductWrapper>{pkg.id_product_map.get(rule.Product__c)});           
                            }
                        }
                        else{
                            evaluationMap.put(rule.Quantity_Group__c, new Map<AssetProductWrapper, Set<AssetProductWrapper>>{pkg.id_product_map.get(rule.Depends_On__c) => new Set<AssetProductWrapper>{pkg.id_product_map.get(rule.Product__c)}});
                        }
                    }
                }
            }
            //Evaluate the quantities within each quantity group
            for(String groupName : evaluationMap.keySet()){
                primaryQty = 0;
                dependentQty = 0;
                for(AssetProductWrapper primary : evaluationMap.get(groupName).keySet()){
                    primaryQty = primary.quantity;
                    dependentQty = 0;
                    errorProducts = '';
                    for(AssetProductWrapper dependent : evaluationMap.get(groupName).get(primary)){
                        dependentQty += dependent.quantity;
                        errorProducts = errorProducts + ' ' + dependent.productName + ' ';
                    }
                    if(primaryQty != dependentQty){
                        //Add error + details to list
                        errors.add(new VCG_CPQ_Error('Quantity Error', 'Quantity of product ' + primary.productName + ' must equal quantity of dependent products: ' + errorProducts));
                        System.debug('Quantity Mismatch: ' + primaryQty + ' =/= ' + dependentQty);
                    }                   
                }
            }
        }

        return errors;
    }



/***********************************************************************************************************************
* @description  -   Product Validation Sub-method. Validates at least 1 of the primary products is present for each dependent product.
* @author  Scott Warren <swarren@vepcg.com>
* @since   09.Jun.2014
* 
************************************************************************************************************************/
    private static List<VCG_CPQ_Error> checkOptionGroup(List<VCG_CPQ_Product_Rule__c> activeRules, List<ProductPackage> productPackages){
        List<VCG_CPQ_Error> errors = new List<VCG_CPQ_Error>();
        Map<String, Boolean> evaluationMap = new Map<String, Boolean>();
        
        //Map<String, Map<AssetProductWrapper, List<AssetProductWrapper>>> evaluationMap = new Map<String, Map<AssetProductWrapper, List<AssetProductWrapper>>>();
        
        // Iterate over all the product packages - i.e. each product grouping or all products on the quote  
        for(ProductPackage pkg : productPackages){
            
            evaluationMap.clear();
            
            // Next, iterate over all the product rules
            for (VCG_CPQ_Product_Rule__c rule : activeRules){
                
                // If the rule's scope matches the product package's scope (i.e. 'Grouping' rules for group package, 'Quote' rules for quote package)
                if (rule.Scope__c == pkg.scope){
                    
                    // If the package contains the product this rule applies to (rule.Product__c)
                    if (pkg.id_product_map.containsKey(rule.Product__c)){
                        
                        // If we alredy have this product in the evaluationMap
                        if (evaluationMap.containsKey(rule.Product__c)){ 
                            
                            // Check to see if the product this product depends on is also in the package
                            if (pkg.id_product_map.containsKey(rule.Depends_On__c)){
                                // Found! Option Group dependency satisfied!
                                evaluationMap.put(rule.Product__c, true);
                            }
                            // Else, don't change the value of the evaluationMap for this product
                            // -- we want to preserve any 'true's that we've already found
                        }
                        else { // Otherwise, we haven't seen this product yet, so we need to add a true or false in the eval map
                            
                            // Check to see if the product this product depends on is also in the package
                            if (pkg.id_product_map.containsKey(rule.Depends_On__c)){
                                // Found! Option Group dependency satisfied!
                                evaluationMap.put(rule.Product__c, true);
                            }
                            else{
                                // Else, this product not satisfied by this Depends_On, flag this product as false as a default value
                                // -- will be switched to true if any of the other products it depends on are found.
                                evaluationMap.put(rule.Product__c, false);
                            }
                        }
                    }
                }
            }
                        
            for (String prodId : evaluationMap.keySet()){
                if (evaluationMap.get(prodId) == false){
                    // Missing required Products for dependent product
                    
                    // Go back through the list of rules and collect the product names this product depends on, so we can display
                    // to the user
                    List<String> dependsOnNames = new List<String>();
                    for (VCG_CPQ_Product_Rule__c rule : activeRules){
                        if (rule.Product__c == prodId) {
                            dependsOnNames.add(rule.Depends_On__r.Name);
                        }
                    }
                    
                    errors.add(new VCG_CPQ_Error('Missing Required Products', pkg.id_product_map.get(prodId).productName + ' must be bought with one of the following products: ' + String.join(dependsOnNames, ', ')));
                    System.debug('Required Dependent in Option Group not found.');
                }
            }
        }
        

        return errors;
    }
    
    
    
/***********************************************************************************************************************
* @description  -   Product Validation Sub-method. Validates required products are present for dependent products.
* @author  Scott Warren <swarren@vepcg.com>
* @since   24.Mar.2014
************************************************************************************************************************/
    private static List<VCG_CPQ_Error> checkDependentProducts(List<VCG_CPQ_Product_Rule__c> activeProductRules, List<ProductPackage> productPackages ){
        List<VCG_CPQ_Error> errors = new List<VCG_CPQ_Error>();

        for(ProductPackage pkg : productPackages){
            
            for(VCG_CPQ_Product_Rule__c rule : activeProductRules){
                if(rule.Scope__c == pkg.scope){
                    if(pkg.id_product_map.containsKey(rule.Product__c)){
                        if(pkg.id_product_map.containsKey(rule.Depends_On__c)){
                            continue;
                        }
                        else{
                            String dependsOnName = rule.Depends_On__r.Name;
                            errors.add(new VCG_CPQ_Error('Missing Required Products', pkg.id_product_map.get(rule.Product__c).productName + ' must be bought with ' + dependsOnName + '. Please add ' + dependsOnName));
                            System.debug('Missing required product dependencies');
                            System.debug('Error Fired at Rule: ' + rule);
                            System.debug('Error Fired for package: ' + pkg); 
                        }
                    }
                }
            }
        }
        
        
        return errors;
    }
        


/***********************************************************************************************************************
* @description  -   Product validation sub-method. Validates that required addons are present.
* @author  Scott Warren <swarren@vepcg.com>
* @since   12.Aug.2014
************************************************************************************************************************/

    private static List<VCG_CPQ_Error> checkRequiredAddons(VCG_CPQ_Quote__c quote, List<VCG_CPQ_Product_Addon__c> activeProductAddons, 
                                                           List<VCG_CPQ_Quote_Product__c> selectedProducts, list<Asset__c> assets )
    {
        
        List<VCG_CPQ_Error> errors = new List<VCG_CPQ_Error>();
        Map<Id, VCG_CPQ_Quote_Product__c> productMap = new Map<Id, VCG_CPQ_Quote_Product__c>();
        
        //Map doesn't work - multiple instances of the same product will overwrite one another 
        for(VCG_CPQ_Quote_Product__c prod : selectedProducts){
            productMap.put(prod.Product__c, prod);
        }
        
        String needsFields = '';
        for(VCG_CPQ_Product_Addon__c addon : activeProductAddons){
            needsFields += addon.Needs_Fields__c;
            needsFields += ';';         
        }
        
        List<VCG_CPQ_Quote__c> needsFieldsQuotes = new List<VCG_CPQ_Quote__c>();        
        needsFieldsQuotes = VCG_CPQ_NeedsFieldsUtility.getNeedsFields(new List<VCG_CPQ_Quote__c>{quote}, needsFields);

        VCG_CPQ_Quote__c needsFieldsQuote = needsFieldsQuotes[0];
        
        VCG_CPQ_Data.addChildren(needsFieldsQuote, 'Quote_Products__r', selectedProducts);

        Boolean foundRequired = false;
        for(VCG_CPQ_Product_Addon__c addonRule : activeProductAddons)
        {           
            
            if(VCG_CPQ_Formula.evaluate(needsFieldsQuote, addonRule.Required__c).value == 1.0)
            {
                
                for(VCG_CPQ_Quote_Product__c prod : selectedProducts)
                {
                    if(prod.Product__c == addonRule.Product__c)
                    {
                        foundRequired = false;
                        for(VCG_CPQ_Quote_Product__c addon : selectedProducts)
                        {
    
                            if(addon.Product__c == addonRule.Product_Addon__c && addon.Add_on_Source_Quote_Product__r.Product__c == addonRule.Product__c)
                            {
                                foundRequired = true;
                            }
                        }                   
                    }
                }   
                //evaluate if the required add-on is already an asset
                if(assets.size() > 0)
                {
                    
                    for(Asset__c a : assets)
                    {
                        if(a.Product__c == addonRule.Product__c)
                        {   
                            foundRequired = false;
                            for(Asset__c addOnAsset : assets)
                            {
                                if(addonRule.Product_Addon__c == addOnAsset.Product__c && addOnAsset.Add_on_To__c == a.Id)
                                {
                                    foundRequired = true;
                                }
                            }
                                
                        }
                    }   
                }
                
                if(foundRequired == false){
                    String addOnName = addonRule.Product_Addon__r.Name;
                    errors.add(new VCG_CPQ_Error('Missing Required Products', addonRule.Product__r.Name + ' requires add-on product: ' + addOnName));
                }
                
                foundRequired = false;
                    
            }
                                    
        }

        
        return errors;
    }




/***********************************************************************************************************************
* @description  -   Product validation sub-method. Validates that the quantity for products is above the designated floor.
* @author  Scott Warren <swarren@vepcg.com>
* @since   24.Mar.2014
************************************************************************************************************************/
    private static List<VCG_CPQ_Error> checkProductFloor(List<VCG_CPQ_Product_Rule__c> activeProductRules, List<ProductPackage> productPackages){

        List<VCG_CPQ_Error> errors = new List<VCG_CPQ_Error>();
        
        //$Primary is a reference to the primary product quantity   
        String floorFormula;
        Decimal floor;
        Decimal primaryQty;
        Decimal dependentQty;
        for(ProductPackage pkg : productPackages){
                
            for(VCG_CPQ_Product_Rule__c rule : activeProductRules){             
                floorFormula = rule.Floor__c;
                if(rule.Scope__c == pkg.scope){
                    if(pkg.id_product_map.containsKey(rule.Product__c) && (rule.Depends_On__c == null || pkg.id_product_map.containsKey(rule.Depends_On__c))){
                        dependentQty = pkg.id_product_map.get(rule.Product__c).quantity;
                        if(rule.Depends_On__c != null){                     
                            if(pkg.id_product_map.containsKey(rule.Depends_On__c)){
                                primaryQty = pkg.id_product_map.get(rule.Depends_On__c).quantity;
                            }
                            else{
                                primaryQty = 0;
                            }
                        }
                        if(floorFormula.contains('$Primary')){
                            floorFormula = floorFormula.replace('$Primary', String.valueOf(primaryQty));
                        }
                        
                        floor = VCG_CPQ_Formula.evaluate(floorFormula).value;
                        
                        if(dependentQty < floor){
                            errors.add(new VCG_CPQ_Error('Quantity Error', 'Quantity of product ' + pkg.id_product_map.get(rule.Product__c).productName + ' is below the designated floor of ' + floor));
                            System.debug('Quantity below floor');
                        }
                    }
                }
            }   
        }       
        
        return errors;
        
    }



/***********************************************************************************************************************
* @description  -   Product validation sub-method. Validates that the quantity for products is below the designated ceiling.
* @author  Scott Warren <swarren@vepcg.com>
* @since   09.Jun.2014
************************************************************************************************************************/
    private static List<VCG_CPQ_Error> checkProductCeiling(List<VCG_CPQ_Product_Rule__c> activeProductRules, List<ProductPackage> productPackages){
        List<VCG_CPQ_Error> errors = new List<VCG_CPQ_Error>();
        //$Primary is a reference to the primary product quantity   
        String ceilingFormula;
        Decimal ceiling;
        Decimal primaryQty;
        Decimal dependentQty;
        for(ProductPackage pkg : productPackages){
            
            for(VCG_CPQ_Product_Rule__c rule : activeProductRules){             
                ceilingFormula = rule.Ceiling__c;
                if(rule.Scope__c == pkg.scope){
                    if(pkg.id_product_map.containsKey(rule.Product__c) && (rule.Depends_On__c == null || pkg.id_product_map.containsKey(rule.Depends_On__c))){
                        dependentQty = pkg.id_product_map.get(rule.Product__c).quantity;
                        if(rule.Depends_On__c != null){                     
                            if(pkg.id_product_map.containsKey(rule.Depends_On__c)){
                                primaryQty = pkg.id_product_map.get(rule.Depends_On__c).quantity;
                            }
                            else{
                                primaryQty = 0;
                            }
                        }
                        if(ceilingFormula.contains('$Primary')){
                            ceilingFormula = ceilingFormula.replace('$Primary', String.valueOf(primaryQty));
                        }
                        
                        ceiling = VCG_CPQ_Formula.evaluate(ceilingFormula).value;

                        if(dependentQty > ceiling){
                            //Throw ceiling error
                            errors.add(new VCG_CPQ_Error('Quantity Error', 'Quantity of product ' + pkg.id_product_map.get(rule.Product__c).productName + 'is above the designated ceiling of ' + ceiling));
                            System.debug('Quantity above ceiling');
                        }
                    }
                }
            }   
        }       
        
        
        
        return errors;
        
    }



/***********************************************************************************************************************
* @description  -   Product validation sub-method. Validates that product is added in quantities of designated multiples. 
* @author  Scott Warren <swarren@vepcg.com>
* @since   24.Mar.2014
************************************************************************************************************************/
    private static List<VCG_CPQ_Error> checkProductIncrements(List<VCG_CPQ_Product_Rule__c> activeProductRules, List<ProductPackage> productPackages){
        List<VCG_CPQ_Error> errors = new List<VCG_CPQ_Error>();
        
        //$Primary is a reference to the primary product quantity   
        String incrementFormula;
        Decimal increment;
        Decimal primaryQty;
        Decimal dependentQty;
        Boolean modResult;
        for(ProductPackage pkg : productPackages){
            
            for(VCG_CPQ_Product_Rule__c rule : activeProductRules){
                modResult = false;
                incrementFormula = rule.Increment__c;
                if(rule.Scope__c == pkg.scope){
                    if(pkg.id_product_map.containsKey(rule.Product__c) && (rule.Depends_On__c == null || pkg.id_product_map.containsKey(rule.Depends_On__c))){
                        dependentQty = pkg.id_product_map.get(rule.Product__c).quantity;
                        if(rule.Depends_On__c != null){                     
                            if(pkg.id_product_map.containsKey(rule.Depends_On__c)){
                                primaryQty = pkg.id_product_map.get(rule.Depends_On__c).quantity;
                            }
                            else{
                                primaryQty = 0;
                            }
                        }
                        if(incrementFormula.contains('$Primary')){
                            incrementFormula = incrementFormula.replace('$Primary', String.valueOf(primaryQty));
                        }
                        increment = VCG_CPQ_Formula.evaluate(incrementFormula).value;                   
                        if(increment > 0){
                            if(Math.floor(dependentQty / increment) == (dependentQty / increment)){
                                modResult = true;
                            }                           
                        }
                        else{
                            //Throw divide by 0 error
                            errors.add(new VCG_CPQ_Error('Data Error', 'Data Table Error - Increment evaluated to 0'));
                            System.debug('Divide by 0 Error');
                        }
                        if(modResult == false){
                            //Throw increment error
                            errors.add(new VCG_CPQ_Error('Quantity Error', 'Product ' + pkg.id_product_map.get(rule.Product__c).productName + ' must be purchased in increments of ' + increment));
                            System.debug('Invalid increment');
                        }
                    }
                }
            }   
        }

        return errors;
    }
    


/***********************************************************************************************************************
* @description  -   Product validation sub-method. Validate that no incompatible products have been selected for the quote.
* @author  Scott Warren <swarren@vepcg.com>
* @since   24.Mar.2014
*
* Note: Only evaluates at the quote scope. Product groups are not considered.
************************************************************************************************************************/
    private static List<VCG_CPQ_Error> checkIncompatibleProducts(List<VCG_CPQ_Product_Incompatibility__c> incompatibilities, List<ProductPackage> productPackages){
        List<VCG_CPQ_Error> errors = new List<VCG_CPQ_Error>();
        
        for(ProductPackage pkg : productPackages){
            for(VCG_CPQ_Product_Incompatibility__c incompat : incompatibilities){
                if(pkg.scope == incompat.Scope__c){
                    if(pkg.id_product_map.containsKey(incompat.Product_1__c) && pkg.id_product_map.containsKey(incompat.Product_2__c)){
                        //throw error
                        errors.add(new VCG_CPQ_Error('Incompatible Products', 'Products ' + pkg.id_product_map.get(incompat.Product_1__c).productName + ' and ' + pkg.id_product_map.get(incompat.Product_2__c).productName + ' are incompatible.'));
                        System.debug('Incompatible products added to the quote');
                    }
                }               
            }
        }
        
        return errors;      
    }



/***********************************************************************************************************************
* @description  - Iterate over list of Quote Products and return Set of Ids
*       Use: validateProductSelection()
*            getAddonProducts()
* @author  Scott Warren <swarren@vepcg.com>
* @since   24.Mar.2014
************************************************************************************************************************/
    private static set<Id> getProductIds(List<SObject> sObjects){
        Set<Id>selectedProdIds = new Set<Id>();
        
        for(sObject so : sObjects){
            Schema.sObjectType sType = so.getSObjectType();
            if(sType == VCG_CPQ_Quote_Product__c.sObjectType){
                selectedProdIds.add(Id.valueOf(String.valueOf(so.get('Product__c'))));
            }
            if(sType == Asset__c.sObjectType){
                selectedProdIds.add(Id.valueOf(String.valueOf(so.get('Product__c'))));
            }
        }
        
        return selectedProdIds;
        
    }

    
    
    
    
    
    
    
    
}