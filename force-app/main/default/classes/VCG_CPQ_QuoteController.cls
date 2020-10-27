public without sharing class VCG_CPQ_QuoteController {
    //==========================================
    // Global Variables
    public boolean hasGroupedAssets{get;set;}
    public Boolean isAddNew {get;set;}
    public Boolean isEditEndDate {get;set;}
    public Boolean isEditStartDate {get;set;}
    public Boolean isEditOtherValues {get;set;}
    public Boolean showDetails{get;set;}
    public Boolean showPricingResults{get;set;}
    public Boolean showQuoteDetails {get;set;}
//    public List<ProductFamilyWrapper> pfWrapperList {get;set;}
    public List<Product2> filteredProducts {get;set;}
    transient public Map<Id,Product2> allActiveProductMap {get;set;}
    public List<QuoteProductWrapper> recAddOnsList {get;set;}
    public List<QuoteProductWrapper> addNewFilteredProdList {get;set;}
    public String newFilteredProductListSizeMsg {get;set;}
    /** @todo  What are the next three lists used for? Can we get rid of them? Can we just use qpwMap.values() for the list of QPWs? Are any of these used in the Quote VF page? */
    public List<QuoteProductWrapper> qpwList {get;set;}
//    public List<QuoteProductWrapper> existingQPWList {get;set;}
//    public List<QuoteProductWrapper> newQPWList {get;set;}
    public Map<String,QuoteProductWrapper> qpwMap {get;set;}
    public Map<String,List<QuoteProductWrapper>> groupedQpwMap {get;set;}
    public string activeGroup{get;set;}
    public VCG_CPQ_Quote__c quote {get;set;}
    public Opportunity opportunity {get;set;}
    public List<Asset__c> existingAssetList;
    public String eqProductId {get;set;}
    public String eqEndDate {get;set;}
    public VCG_CPQ_Quote_Product__c editQP {get;set;}
    public QuoteProductWrapper eqWrapper {get;set;}
    public List<VCG_CPQ_Quote_Product__c> newQuoteProductList {get;set;}
    public List<VCG_CPQ_Quote_Product__c> decomQuoteProductList {get;set;}
    public List<VCG_CPQ_Quote_Product__c> migrationQuoteProductList {get;set;}
    public List<VCG_CPQ_Quote_Product__c> otherQuoteProductList {get;set;}
    public List<VCG_CPQ_Quote_Product__c> extQuoteProductList {get;set;}
    public List<VCG_CPQ_Quote_Product__c> renewalQuoteProductList {get;set;}
    public List<VCG_CPQ_Quote_Product__c> allQuoteProductList {get;set;}
    List<VCG_CPQ_Quote_Product__c> quoteProductsToDelete = new List<VCG_CPQ_Quote_Product__c>();
    public Map<String,List<VCG_CPQ_Quote_Product_Pricing_Result__c>> pricingResultsMap{get;set;}
    public Map<String,BundleWrapper> availableBundles {get;set;}
    public Integer availableBundlesSize { get { return availableBundles.size(); } } // To access the map size in VF
    //public Integer availableBundlesSelectedSize { get { Integer count = 0; for (BundleWrapper bundle : availableBundles.values()) { if (bundle.isSelected) count++; } System.debug('====> Selected Available Bundles count: ' + count); return count; } }
    public List<BundleWrapper> selectedAvailableBundles {get { List<BundleWrapper> selAvailBunds = new List<BundleWrapper>(); for (BundleWrapper bundle : availableBundles.values()) { if (bundle.isSelected) selAvailBunds.add(bundle); } return selAvailBunds; } }
    public Map<String,BundleWrapper> configBundles {get; set;}
    public List<BundleWrapper> configBundlesList { get { return configBundles.values(); } }
    
    public Map<String,BundleWrapper> assetBundles {get; set;}
    
    public DateTime getNow() { return Datetime.now(); }
    public Boolean errorFlag{ get;set;}
    public Boolean isMultiCurrencyEnabled {get;set;}
    
    public Id migrateProdId {get;set;} // This is for input from the VF page - when the user clicks on a 'Migrate' button for a specific product, that product's code is passed back through this variable
    //
    //Required for Pricing Override functionality
    public Boolean isEditResultValue{get;set;}
    public VCG_CPQ_Quote_Product_Pricing_Result__c editPricingResult {get;set;}
    public String editPricingKey{get;set;}
    public String pricingProcSeqId{get;set;}
    public Map<String,VCG_CPQ_Pricing_Override__c> pricingOverrideMap = new Map<String,VCG_CPQ_Pricing_Override__c>();
    // to check if pricing result of related product is overriden
    public Boolean isPricingResultOverride {get;set;}
    public Integer overrideCount { get { return pricingOverrideMap.size(); } }
    
    // Data map for caching values on auto-added records. Primarily for persisting
    // user-entered discounts/uplifts across the delete/re-add cycle that happens to
    // auto-added records during a normal pricing run. Primary key is the product
    // identifier (product SKU should be sufficent as auto-added products can't be grouped).
    // Second level key is the field/item identifier being cached, 'Object' is the value being
    // cached. (Using a generic Object allows caching of strings, decimals, dates, sObjects, etc.)
    // This is intended to persist in the View State so if an error occurs in pricing before
    // the auto-added record is re-added, the values the user has entered will be persisted.
    // Internal management of the values stored in this will be critical if we really want to
    // detect times when the auto-added record is correctly removed so values will not persist
    // when they shouldn't. (But this may be a future @todo).
    // Values are set in this cache at the start of the pricing run.
    public Map<String,Map<String,Object>> autoAddedValueCache;
    
    //
    public Boolean isPricingOverrideQuery;
    
    //Security Restrictions Grid
    List<VCG_CPQ_Security_Restriction__c> UserAccessRestrictions;
    
    //product group directory
//    public Map<string, ProductFolder> productGroupDirectory{get;set;}
    
    public Map<String,Object> ProductFilterKeys {get;set;}
    public String targetPFK {get; set;}
    
    public static final List<String> onMaintenanceStatuses = new List<String>{ 'On Maintenance', 'Pending' };
    
    public String getProductFilterKeysJSON()
    {
        return (ProductFilterKeys == null ? '' : JSON.serialize(ProductFilterKeys));
    }
    
     /**
     * @description  Wrapper class used to filter Products that appear onclick of "Add New" Button on Quoting tool
     *
     * @author
     * @since
     */
/*    public class ProductFamilyWrapper{
        public Boolean isSelected {get;set;}
        public String productFamily {get;set;}
        
        public ProductFamilyWrapper(Boolean isSelected, String productFamily){
            this.isSelected = isSelected;
            this.productFamily = productFamily;
        }
    }
*/
    public class CoreProductWrapper
    {       
        public boolean isSelected{get;set;}         
        public QuoteProductWrapper product{get;set;}        
                
        public CoreProductWrapper(boolean is, QuoteProductWrapper p)        
        {       
            isSelected = is;        
            product = p;        
        }       
    }
    
    /**
    * @description Wrapper class used for custom sorting of product add ons
    
    */
    public class QuoteProductAddOnWrapper implements Comparable {
        public QuoteProductWrapper myQuoteProductWrapper;
        public QuoteProductAddOnWrapper(QuoteProductWrapper qpw){
            myQuoteProductWrapper = qpw;
        }
        
        public Integer compareTo(Object compareTo) {
            try{
            QuoteProductAddOnWrapper compareToObj = (QuoteProductAddOnWrapper) compareTo;
            if(myQuoteProductWrapper.addOnResultRec.required && ! compareToObj.myQuoteProductWrapper.addOnResultRec.required){
                return - 1;
            }
            else if(! myQuoteProductWrapper.addOnResultRec.required && compareToObj.myQuoteProductWrapper.addOnResultRec.required){
                return 1;
            }
            else{
                if(myQuoteProductWrapper.addOnResultRec.addonProduct.CPQ_Add_On_Grouping__c > compareToObj.myQuoteProductWrapper.addOnResultRec.addonProduct.CPQ_Add_On_Grouping__c){
                    return 1;
                }
                else if (myQuoteProductWrapper.addOnResultRec.addonProduct.CPQ_Add_On_Grouping__c < compareToObj.myQuoteProductWrapper.addOnResultRec.addonProduct.CPQ_Add_On_Grouping__c){
                    return -1;
                }
                else{
                    if(myQuoteProductWrapper.addOnResultRec.addonProduct.Name >= compareToObj.myQuoteProductWrapper.addOnResultRec.addonProduct.Name)
                        return 1;
                    else
                        return -1;
                }
            }
            }
            catch(Exception e){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Error Loading Quote: ' + e.getMessage() + ' [line: ' + e.getLineNumber() + ']'));
                return null;
            }
        
        }
    }
     /**
     * @description  Main Wrapper Class to Collect existing Asset records, Quote Product Records added, Renewal records
                     This wrapper is actually the records that are getting displayed on the Quote tool as Quote product line items.
     *
     * @author Lawrence Coffin <lawrence.coffin@cloudsherpas.com>
     * @since   1.Apr.2014
     */
    public class QuoteProductWrapper implements Comparable {
        public Product2 productRec {get;set;}
        public list<CoreProductWrapper> coreProductList{get;set;}
        public list<CoreProductWrapper> coreLegacyProductList{get;set;}
        public VCG_CPQ_Quote_Product__c quoteProdRec {get;set;}
        public VCG_CPQ_Quote_Product__c renewalQuoteProdRec {get;set;}
        public Asset__c assetRec {get;set;}
        public VCG_CPQ_Quote_Product__c mainMaintQPRec {get;set;}  // Holds the maintenance record for the main QP record (New or Extension)
        public VCG_CPQ_Quote_Product__c renewMaintQPRec {get;set;} // Holds the maintenance record for the renewal QP record
        public VCG_CPQ_Product_Addon_Wrapper addOnResultRec {get;set;}
        public String termEndTooltip {get;set;}        
        public VCG_UI__c salesPriceTotal {get;set;}
        public VCG_UI__c arrTotal {get;set;}
        public VCG_UI__c lineTotal {get;set;}
        
        public Boolean isExisting {get;set;}
        public Boolean isNew {get;set;}
        public Boolean isAddOn {get;set;}
        public Boolean isDecommission {get;set;}
        public Boolean isExtension {get;set;}
        public Boolean isRenewal {get;set;}
        public Boolean isUpgrade {get;set;}
        public Boolean isUpgraded {get;set;}
        public Boolean isMigration {get;set;}
        public Boolean isMigrated {get;set;}
        public Boolean isOther {get;set;}
        
        
        public Boolean hasEquivalency {get;set;} // If true, this is a legacy product that has an equivalency and is upgradeable/migrateable
        public List<Product2> equivalentProds {get;set;} // List of products this legacy product is equivalent to
        
        public QuoteProductWrapper(VCG_CPQ_Quote__c quote, Product2 productRec, VCG_CPQ_Quote_Product__c quoteProdRec, Asset__c assetRec){
            this.productRec = productRec;
            this.quoteProdRec = quoteProdRec;
            this.coreLegacyProductList = new list<CoreProductWrapper>(); 
            this.coreProductList = new list<CoreProductWrapper>();
            if (quoteProdRec == null)
            {
                // Create an empty Quote Product record if one wasn't set, so we can edit the
                // quantity/decom quantity for existing assets (to make a new/decommission quote product)
                this.quoteProdRec = new VCG_CPQ_Quote_Product__c();
                if (UserInfo.isMultiCurrencyOrganization()) this.quoteProdRec.put('CurrencyIsoCode', quote.get('CurrencyIsoCode'));
            }
            
            this.quoteProdRec.putSObject('Product__r',productRec);           
            this.assetRec = assetRec;
            
            this.isNew = false;
            this.isExisting = false;
            this.isRenewal = false;
            this.isExtension = false;
            this.isDecommission = false;
            this.isAddOn = false;
            this.isUpgrade = false;
            this.isUpgraded = false;
            this.isMigration = false;
            this.isMigrated = false;
            this.hasEquivalency = false;
            this.isOther = false;
            
            
            this.salesPriceTotal = new VCG_UI__c();
            this.arrTotal = new VCG_UI__c();
            this.lineTotal = new VCG_UI__c();
            if (UserInfo.isMultiCurrencyOrganization())
            {
                this.salesPriceTotal.put('CurrencyISOCode', quote.get('CurrencyISOCode'));
                this.arrTotal.put('CurrencyISOCode', quote.get('CurrencyISOCode'));
                this.lineTotal.put('CurrencyISOCode', quote.get('CurrencyISOCode'));
            }
            this.salesPriceTotal.aCurr2__c = this.getSalesPriceTotal();
            this.arrTotal.aCurr2__c = this.getARRTotal();
            this.lineTotal.aCurr2__c = this.getLineTotal();
        }
        
        public Decimal getSalesPriceTotal()
        {
            // Sales Price doesn't include maintenance Sales Price (that is ARR)
            return ( (this.quoteProdRec == null || this.quoteProdRec.Sales_Price__c == null) ? 0.00 : this.quoteProdRec.Sales_Price__c )
//                   +
//                   ( (this.mainMaintQPRec == null || this.mainMaintQPRec.Sales_Price__c == null) ? 0.00 : this.mainMaintQPRec.Sales_Price__c )
                   +
                   ( (this.renewalQuoteProdRec == null || this.renewalQuoteProdRec.Sales_Price__c == null) ? 0.00 : this.renewalQuoteProdRec.Sales_Price__c )
//                   +
//                   ( (this.renewMaintQPRec == null || this.renewMaintQPRec.Sales_Price__c == null) ? 0.00 : this.renewMaintQPRec.Sales_Price__c )
                   ;
        }
        
        public Decimal getARRTotal()
        {
            return ( (this.quoteProdRec == null || this.quoteProdRec.Annual_Recurring_Revenue__c == null) ? 0.00 : this.quoteProdRec.Annual_Recurring_Revenue__c )
                   +
                   ( (this.mainMaintQPRec == null || this.mainMaintQPRec.Annual_Recurring_Revenue__c == null) ? 0.00 : this.mainMaintQPRec.Annual_Recurring_Revenue__c )
                   +
                   ( (this.renewalQuoteProdRec == null || this.renewalQuoteProdRec.Annual_Recurring_Revenue__c == null) ? 0.00 : this.renewalQuoteProdRec.Annual_Recurring_Revenue__c )
                   +
                   ( (this.renewMaintQPRec == null || this.renewMaintQPRec.Annual_Recurring_Revenue__c == null) ? 0.00 : this.renewMaintQPRec.Annual_Recurring_Revenue__c )
                   ;
        }
        
        public Decimal getLineTotal()
        {
            return ( (this.quoteProdRec == null || this.quoteProdRec.Term_Amount__c == null) ? 0.00 : this.quoteProdRec.Term_Amount__c )
                   +
                   ( (this.mainMaintQPRec == null || this.mainMaintQPRec.Term_Amount__c == null) ? 0.00 : this.mainMaintQPRec.Term_Amount__c )
                   +
                   ( (this.renewalQuoteProdRec == null || this.renewalQuoteProdRec.Term_Amount__c == null) ? 0.00 : this.renewalQuoteProdRec.Term_Amount__c )
                   +
                   ( (this.renewMaintQPRec == null || this.renewMaintQPRec.Term_Amount__c == null) ? 0.00 : this.renewMaintQPRec.Term_Amount__c )
                   ;
        }
        
        public Integer compareTo(Object compareTo) {
            QuoteProductWrapper compareToQPW = (QuoteProductWrapper)compareTo;
            
            //
            // Compare Group ?
            //
            
            //
            // Compare New vs Existing (New first/less-than Existing)
            //
            if (isNew && compareToQPW.isExisting) return -1;
            if (isExisting && compareToQPW.isNew) return 1;
            
            //
            // Compare Product Name
            //
            if (productRec.Name < compareToQPW.productRec.Name) return -1;
            if (productRec.Name > compareToQPW.productRec.Name) return 1;
            
            // Else equal
            return 0;
        }
    }
    
    
    /**
     * @description  Wrapper for quote detail popup to display pricing detail result
     *
     * @author Lawrence Coffin <lawrence.coffin@cloudsherpas.com>
     * @since   1.Apr.2014
     */
    public class QuoteDetailWrapper {
        VCG_CPQ_Quote_Product__c quoProduct{get;set;}
        Boolean check{get;set;}
        
        public QuoteDetailWrapper() {
            quoProduct = new VCG_CPQ_Quote_Product__c();
        }
    }
   
    
    /**
     * @description   Wrapper class for bundles. Displayed in part of the UI as if it is a product
     *                but handled in the Quote as separate line items. Existing assets can also
     *                be from a bundle and will be handled by this class.
     * 
     * @author  Lawrence Coffin <lawrence.coffin@cloudsherpas.com>
     * @since   Apr.21.2014
     */
    public class BundleWrapper 
    {
        public String bundleName {get; set;}        // Key identifier
        public Decimal orderedQuantity {get; set;}  // 'New' quantity
        public Decimal existingQuantity {get; set;} // Existing quantity from the Asset record
        public Decimal decomQuantity {get; set;}    // Quantity to decommission
        public Boolean isSelected {get; set;}       // This is use for bundles listed in the the Add New popup - to indicate any that the user has selected
        public VCG_UI__c termStart {get; set;}      // termStart.aDate__c  - used for entering/displaying Term Start date, copied down to underlying Quote Product records
        public VCG_UI__c termEnd {get; set;}        // termEnd.aDate__c  - used for entering/displaying Term End date, copied down to underlying Quote Product records
        public VCG_UI__c totalValue {get; set;}     // totalValue.aCurr2__c - used for entering/displaying the total value of all Quote Product records
        
        public Boolean isNew {get; set;}            // general flag to indicate bundle is new
        public Boolean isExisting {get;set;}        // general flag to indicate bundle is existing (i.e. came from Assets)
        public Boolean isRenewal {get;set;}         // general flag to indicate quote product records represent a renewal
        public Boolean isExtension {get;set;}       // general flag to indicate quote product records represent an extension
        public Boolean isDecommission {get;set;}    // general flag to indicate quote product records represent a decommission
        
        public List<VCG_CPQ_Bundle__c> bundleRecs {get; set;}  // Holds all bundle-to-product records (bundle definition records)
        public List<Asset__c> bundledAssets {get; set;}        // Holds all bundle-related asset records (existing records)
        public List<VCG_CPQ_Quote_Product__c> bundledQuoteProds {get; set;}  // Holds all bundle-related quote product records (may need a way to distinguish between new, extension, renewal, etc. if more than one type (i.e. Extension + Renewal))
        
        public BundleWrapper(String bName) 
        {
            termStart = new VCG_UI__c();
            termEnd   = new VCG_UI__c();
            totalValue = new VCG_UI__c();
            
            bundleName = bName;
            bundleRecs = new List<VCG_CPQ_Bundle__c>();
            bundledAssets = new List<Asset__c>();
            bundledQuoteProds = new List<VCG_CPQ_Quote_Product__c>();
            isSelected = false;
        }
    }
    
    
     /**
     * @description  Constructor
     *
     * @author Lawrence Coffin <lawrence.coffin@cloudsherpas.com>
     * @since   1.Apr.2014
     */
    public VCG_CPQ_QuoteController(ApexPages.StandardController sc)
    {
        // Load the existing Quote
        recAddOnsList = new List<QuoteProductWrapper>();
        extQuoteProductList = new List<VCG_CPQ_Quote_Product__c>();
        newQuoteProductList = new List<VCG_CPQ_Quote_Product__c>();
        renewalQuoteProductList = new List<VCG_CPQ_Quote_Product__c>();
        decomQuoteProductList = new List<VCG_CPQ_Quote_Product__c>();
        otherQuoteProductList = new List<VCG_CPQ_Quote_Product__c>();
        allQuoteProductList = new List<VCG_CPQ_Quote_Product__c>();
        opportunity = new Opportunity();
        isAddNew = false;
        isEditEndDate = false;
        isEditStartDate = false;
        isEditOtherValues = false;
        showDetails = false;
        showPricingResults = false;
        showQuoteDetails = false;
        addNewFilteredProdList = new List<QuoteProductWrapper>();
        qpwMap = new Map<string, QuoteProductWrapper>();
        groupedQpwMap = new Map<string, list<QuoteProductWrapper>> ();
        qpwList = new List<QuoteProductWrapper>();
//        existingQPWList = new List<QuoteProductWrapper>();
//        newQPWList = new List<QuoteProductWrapper>();
        quote = new VCG_CPQ_Quote__c();
        quote.Groups_Active__c = false;
        pricingResultsMap = new Map<String,List<VCG_CPQ_Quote_Product_Pricing_Result__c>>();
        activeGroup = '';
        errorFlag = false;
        isEditResultValue = false;
        isPricingResultOverride = false;
//        overrideCount = 0;
        configBundles = new Map<String, BundleWrapper>();        
        isMultiCurrencyEnabled = UserInfo.isMultiCurrencyOrganization();
        isPricingOverrideQuery = true;
        
        //load the product directory
//        createProductDirectory();
        
        
        // If there is an existing Quote Id
        if (sc.getId() != null)
        {
            // Retrieve the Fields from the Layout as well as the Mapping
            Set<String> quoteFieldSet = new Set<String>();
            
//            quoteFieldSet.add('Id'.toLowerCase());
//            quoteFieldSet.add('Name'.toLowerCase());
//            quoteFieldSet.add('OwnerId'.toLowerCase());
//            if (UserInfo.isMultiCurrencyOrganization()) quoteFieldSet.add('CurrencyIsoCode'.toLowerCase());
            
            try
            {
                for (String fieldName : VCG_CPQ_PricingUtility.describeObjectFields('VCG_CPQ_Quote__c').keySet())
                {
                    quoteFieldSet.add(fieldName.toLowerCase());
                }
                // Query Quote Record
                string quoteQuery = 'SELECT ';
                quoteQuery += String.join(new List<String>( quoteFieldSet ), ',');
                quoteQuery += ' FROM VCG_CPQ_Quote__c WHERE Id = \'' + sc.getId() + '\'';
                
                quote = Database.query(quoteQuery);
                
                verifyApprovedQuote();
           
                // Query Opportunity Record related to the Quote
                for (Opportunity o : [SELECT Id, Name, AccountId, Account.Name, Opportunity.StageName, CloseDate, Order_Type__c
                                      FROM Opportunity 
                                      WHERE Id = :quote.Opportunity__c])//Need to configure this
                       opportunity = o;
            }
            catch(Exception e)
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Error Loading Quote: ' + e.getMessage() + ' [line: ' + e.getLineNumber() + ']'));
            }
        }
        else
        { 
            try
            {  
                Set<String> fieldNames = new Set<String>();
                
                // Set required fields here - cast to lower case - Sets are case sensitive!
                fieldNames.add('Id'.toLowerCase());
                fieldNames.add('AccountId'.toLowerCase());
                fieldNames.add('Order_Type__c'.toLowerCase());
                
                // Add in any fields needed from the Opp to Quote mappings
                for (VCG_CPQ_Opportunity_Quote_Map__c oqm : [SELECT Source__c, Quote_Field__c, Source_Type__c, Needs_Fields__c
                                                             FROM VCG_CPQ_Opportunity_Quote_Map__c
                                                             WHERE Active__c = true])
                {
                    System.debug('This is the queried data::'+oqm);
                    if (oqm.Source_Type__c == 'Opportunity Field')
                    {
                        fieldNames.add(oqm.Source__c.toLowerCase());
                    }
                    else if (oqm.Needs_Fields__c != null) {
                        // Formula with Needs_Field value set
                        for (String needsField : oqm.Needs_Fields__c.split(';')) {
                            // Note: Be sure to use lower case values - Sets are case sensitive!
                            fieldNames.add(needsField.toLowerCase());
                        }
                    }
                }
                
                // Retrieve Opportunity Id from URL
                String oppId = ApexPages.currentPage().getParameters().get('oppId');
                
                // Build Query String
                String queryString = 'SELECT ';
                queryString += String.join(new List<String>( fieldNames ), ', ');
                queryString += ' FROM Opportunity WHERE Id = :oppId';
                System.debug('====> Q: ' + queryString);
                opportunity = Database.query(queryString);
            
                // Call function to set default values on the Quote record
                VCG_CPQ_PricingUtility.setQuoteDefaults(opportunity, quote);
            }
            catch(Exception e)
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Error Loading Opportunity and Related Defaults: ' + e.getMessage() + ' [line: ' + e.getLineNumber() + ']'));
                System.debug('******controller exeption message'+ e.getMessage());
            }
        }
        
        // Retrieve Products
        try
        {       
            // Retrieve Existing Products/Assets
            getExistingAssetsAndQPs();
            
            if (quote.Id != null)
            {
                getExistingPricingOverride();
            }
            
            // Populate Lists displayed on Page
            populateListsAndPrice();
            
            // Flag any existing Assets that have equivalencies (for Migration)
            FlagEquivalencies(qpwMap);
        }
        catch(Exception e)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Error Loading Products: '+e.getMessage()+' [line: ' + e.getLineNumber() + ']'));
        }
        
        // Load Available Bundles
        try
        {
            // Bundles available for purchase
            availableBundles = getAvailableBundles();
            
                // Retrieve Existing Products/Assets
//            selectedBundles = getExistingBundles();
        }
        catch(Exception e)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Error Loading Bundles: ' + e.getMessage() + ' [line: ' + e.getLineNumber() + ']'));
        }
        System.debug('::::::::QUOTE PRODUCTS::::::'+ qpwList);
        
        //cache the user access restrictions on load
        UserAccessRestrictions = VCG_CPQ_Quote_Security_Utility.getUserRestrictions(UserInfo.getUserId());
            
        System.debug('====> groupedQpwMap: ' + groupedQpwMap);
    }

    /**
     * @description  Wrapper access method for allActiveProductMap
     *               allActiveProductMap is now transient, so we aren't guaranteed it will be loaded
     *               each time we need it. So we get products through here now and if it isn't loaded, we load it on the fly.
     *
     * @author Lawrence Coffin <lawrence.coffin@cloudsherpas.com>
     * @since   10.Sep.2014
     */
    public Product2 getProduct(Id prodId)
    {
        if (allActiveProductMap == null) allActiveProductMap = getActiveProducts();
        
        return allActiveProductMap.get(prodId);
    }

    /**
     * @description  Wrapper access method for allActiveProductMap - boolean check if product exists/is active
     *               allActiveProductMap is now transient, so we aren't guaranteed it will be loaded
     *               each time we need it. So we get products through here now and if it isn't loaded, we load it on the fly.
     *
     * @author Lawrence Coffin <lawrence.coffin@cloudsherpas.com>
     * @since   10.Sep.2014
     */
    public Boolean isActiveProduct(Id prodId)
    {
        if (allActiveProductMap == null) allActiveProductMap = getActiveProducts();
        
        return allActiveProductMap.containsKey(prodId);
    }

    /**
     * @description  Gets all active products (for use for existing Assets, etc.)
     *
     * @author Lawrence Coffin <lawrence.coffin@cloudsherpas.com>
     * @since   1.Apr.2014
     */
    public Map<Id,Product2> getActiveProducts()
    {
        String soql = 'SELECT '
                        +   String.join(VCG_CPQ_ProductUtility.GetProductFields(), ', ')
                        + ' FROM Product2 '
                        + ' WHERE IsActive = TRUE '
                        + ' ORDER BY Name';
        System.debug('====> Active Products query: ' + soql);
        
        List<Product2> products = Database.query(soql);
        return new Map<Id,Product2>( products );
    }
    
    /**
     * @description  Gets all products that are available for purchase (for the Add New popup)
     *
     * @author Lawrence Coffin <lawrence.coffin@cloudsherpas.com>
     * @since   1.Apr.2014
     */
    public Map<Id,Product2> getAvailableToPurchaseProducts()
    {
        String extraWhereClause = getProductFilter(quote);
        
        String soql = 'SELECT '
                        +   String.join(VCG_CPQ_ProductUtility.GetProductFields(), ', ')
                        + ' FROM Product2 '
                        + ' WHERE IsActive = TRUE '
                        + (extraWhereClause == null ? '' : ' AND (' + extraWhereClause + ')')
                        + ' ORDER BY Name';
        
//        System.debug(LoggingLevel.ERROR, '====> Purchasable Products query: ' + soql);
        
        List<Product2> products = Database.query(soql);
        return new Map<Id,Product2>( products );
    }
    
    /**
     * @description   Loads a list of available bundles. Uses the BundleWrapper class to represent
     *                the bundle as a single product, stores the component products in the
     *                bundleRecs member.
     * 
     * @author  Lawrence Coffin <lawrence.coffin@cloudsherpas.com>
     * @since   Apr.21.2014
     */
    public Map<String, BundleWrapper> getAvailableBundles()
    {
        Map<String, BundleWrapper> availableBundles = new Map<String,BundleWrapper>();
        
        List<VCG_CPQ_Bundle__c> bundleRecs = [SELECT Id,
                                                     Bundle_Name__c,
                                                     Product__c,
                                                     Product__r.Name,
                                                     Product__r.ProductCode,
                                                     Primary__c,
                                                     Primary_Quantity_Percent__c,
                                                     Bundle_Product__c,
                                                     Bundle_Product__r.Name,
                                                     Bundle_Product__r.ProductCode
                                              FROM VCG_CPQ_Bundle__c
                                              WHERE IsActive__c = TRUE
                                              ORDER BY Bundle_Name__c, Product__r.Name];
        
        for (VCG_CPQ_Bundle__c bundleRec : bundleRecs) {
            BundleWrapper bundle;
            
            if (!availableBundles.containsKey(bundleRec.Bundle_Name__c)) 
            {
                    bundle = new BundleWrapper(bundleRec.Bundle_Name__c);
                    availableBundles.put(bundleRec.Bundle_Name__c, bundle);
            }
            else 
            {
                    bundle = availableBundles.get(bundleRec.Bundle_Name__c);
            }
            
            bundle.bundleRecs.add(bundleRec); 
        }
        
        System.debug('====> Available Bundles: ' + availableBundles);
        return availableBundles;
    }
    
    /**
     * @description  Show and Hides Header Detail
     *
     * @author Lawrence Coffin <lawrence.coffin@cloudsherpas.com>
     * @since   1.Apr.2014
     */     
    public void showHideDetail()
    {
        if (showDetails)
           showDetails = false;
        else
            showDetails = true;
    }
    
    /**
     * @description  Show and Hides Pricing Results
     *
     * @author Lawrence Coffin <lawrence.coffin@cloudsherpas.com>
     * @since   1.Apr.2014
     */  
    public void showHidePricingResults()
    {
        if (showPricingResults)
           showPricingResults = false;
        else
            showPricingResults = true;
    }
    
    /**
     * @description  Shows Quote Details Popup
     *
     * @author Lawrence Coffin <lawrence.coffin@cloudsherpas.com>
     * @since   1.Apr.2014
     */
    public void showQuoteDetailsPopup()
    {
        showQuoteDetails = true;
    }
    
   /**
     * @description  Hides Quote Details Popup
     *
     * @author Lawrence Coffin <lawrence.coffin@cloudsherpas.com>
     * @since   1.Apr.2014
     */
    public void hideQuoteDetailsPopup()
    {
        showQuoteDetails = false;
        showPricingResults = false;
        isEditResultValue = false;
    }
            
   /**
     * @description  Show Update End Date Popup
     *
     * @author Lawrence Coffin <lawrence.coffin@cloudsherpas.com>
     * @since   1.Apr.2014
     */  
    public void showEditEndDate()
    {
        isEditEndDate = true;
        activeGroup = ApexPages.currentPage().getParameters().get('group');
        System.debug('activeGroup fo bundle in showeditEnddate' + activeGroup);
        // Retrieve Wrapper instance
        eqWrapper = qpwMap.get(getQPWMapKey(eqProductId, activeGroup));
        editQP = new VCG_CPQ_Quote_Product__c();
        if (UserInfo.isMultiCurrencyOrganization()) editQP.put('CurrencyIsoCode', quote.get('CurrencyIsoCode'));
        editQP.Product__c = eqProductId;
        
        if (eqWrapper.renewalQuoteProdRec != null)
        {
            // Renewal of subscription product
            editQP.Asset_Term_End_Date__c = eqWrapper.renewalQuoteProdRec.Asset_Term_End_Date__c;
        }
        else if (eqWrapper.renewMaintQPRec != null)
        {
            // Renewal of perpetual product - the maintenance for the perpetual product
            editQP.Asset_Term_End_Date__c = eqWrapper.renewMaintQPRec.Asset_Term_End_Date__c;
        }
        else if (eqWrapper.isNew)
        {
            editQP.Asset_Term_End_Date__c = eqWrapper.quoteProdRec.Asset_Term_End_Date__c;
        }
        else
        {
            editQP.Asset_Term_End_Date__c = eqWrapper.assetRec.Asset_Term_End_Date__c;
        }
    }
    
    /**
     * @description  Updates End Date from Popup
     *
     * @author Lawrence Coffin <lawrence.coffin@cloudsherpas.com>
     * @since   1.Apr.2014
     */
    public void updateEndDate()
    {
        if (eqWrapper.isNew)
        {
            // Extend the term end for new products (and maintenance if it exists)
            eqWrapper.quoteProdRec.Asset_Term_End_Date__c = editQP.Asset_Term_End_Date__c;
            if (eqWrapper.mainMaintQPRec != null) eqWrapper.mainMaintQPRec.Asset_Term_End_Date__c = editQP.Asset_Term_End_Date__c;
        }
        else 
        {
            // If the end date is later than the asset term end, it is a Renewal
            if (editQP.Asset_Term_End_Date__c > eqWrapper.assetRec.Asset_Term_End_Date__c)
            {
                // Include the Extension quantity if there is an extension -- Renewal + Extension
                // or Decommission quantity if a decomission -- Renewal + Decommission
                editQP.License_Metric_Quantity__c = eqWrapper.assetRec.License_Metric_Quantity__c;
                if (eqWrapper.quoteProdRec.Line_Type__c == 'Extension') editQP.License_Metric_Quantity__c += eqWrapper.quoteProdRec.License_Metric_Quantity__c;
                else if (eqWrapper.quoteProdRec.Line_Type__c == 'Decommission') editQP.License_Metric_Quantity__c -= eqWrapper.quoteProdRec.Decommission_Quantity__c;
                editQP.Asset_Term_Start_Date__c = eqWrapper.assetRec.Asset_Term_End_Date__c + 1;
                editQP.Line_Type__c = 'Renewal';
                editQP.Product_Group__c = eqWrapper.assetRec.Product_Group__c;
                editQP.Product__r = eqWrapper.productRec;
                editQP.Quote__r = this.quote;
                editQP.Asset__r = eqWrapper.assetRec;
                editQP.Asset__c = eqWrapper.assetRec.Id;
//                qpwMap.put(getQPWMapKey(eqProductId, eqWrapper.quoteProdRec.Product_Group__c), eqWrapper);
                
                // Add Maintenance if we need to
                // NOTE: We skip adding a renewal QP record for perpetual products here,
                // for perpetual, we are only renewing the maintenance!
                if (eqWrapper.productRec.Is_Perpetual__c)
                {
                    // We have a perpetual product and need to add Recurring Maintenance
                    // of the same quantity.
                    
                    // Actually, if we have a maintenance decom, that won't be caught above, so we need to adjust here as well
                    if (eqWrapper.mainMaintQPRec != null && eqWrapper.mainMaintQPRec.Line_Type__c == 'Decommission') editQP.License_Metric_Quantity__c -= eqWrapper.mainMaintQPRec.Decommission_Quantity__c;
                    
                    AddMaintenance(qpwMap, editQP);
                }
                else
                {
                    // Not perpetual, so renew the actual product
                    eqWrapper.renewalQuoteProdRec = editQP;
                    eqWrapper.isRenewal = true;
                }
            }
            else
            {
                if (eqWrapper.renewalQuoteProdRec != null) 
                {
                    // Remove renewal QP
                    eqWrapper.renewalQuoteProdRec = null;
                    eqWrapper.isRenewal = false;
                }
            }
        }
        
        // Re-populate lists
        populateListsAndPrice();
        
        // Close Update End Date popup window and update asset label
        isEditEndDate = false;
    }
    
    /**
     * @description
     *
     * @author
     * @since
     */
    public void updateCommonTermEndDate()
    {
        //
        // Set fromEndDate to:
        //   - eqWrapper's QP's Term End Date
        //   - eqWrapper's renewal QP's Term End Date
        //   - eqWrapper's asset's Term End Date
        // This is the date we are moving records from
        Date fromEndDate = eqWrapper.quoteProdRec.Asset_Term_End_Date__c;
        
        if (eqWrapper.renewalQuoteProdRec != null && eqWrapper.renewalQuoteProdRec.Asset_Term_End_Date__c != null)
            fromEndDate = eqWrapper.renewalQuoteProdRec.Asset_Term_End_Date__c;
        
        if (fromEndDate == null)
            fromEndDate = eqWrapper.assetRec.Asset_Term_End_Date__c;
        
        // Date we are moving records to
        Date toEndDate = editQP.Asset_Term_End_Date__c;
        
        // Loop through all QPW records and extend the date out for any that match the fromEndDate
        for (QuoteProductWrapper qpw : qpwMap.values()) 
        {
            
            if (qpw.isNew)
            {
                if (qpw.quoteProdRec.Asset_Term_End_Date__c == fromEndDate)
            {
                    qpw.quoteProdRec.Asset_Term_End_Date__c = toEndDate;
                    if (qpw.mainMaintQPRec != null) qpw.mainMaintQPRec.Asset_Term_End_Date__c = toEndDate;
                }
            }
            else
            {
                // If not new, then we have an existing asset. Check the asset end date, or a previously set renewal record end date.
                // We don't need to check for an Extension end date because that will always be == the asset end date
                if (
                       toEndDate > qpw.assetRec.Asset_Term_End_Date__c
                       && (
                                 (qpw.renewalQuoteProdRec != null && qpw.renewalQuoteProdRec.Asset_Term_End_Date__c == fromEndDate)
                              || (qpw.renewalQuoteProdRec == null && qpw.assetRec.Asset_Term_End_Date__c == fromEndDate)
                          )
                   )
               {
                    VCG_CPQ_Quote_Product__c qp = new VCG_CPQ_Quote_Product__c();
                    
                    if (UserInfo.isMultiCurrencyOrganization()) qp.put('CurrencyIsoCode', quote.get('CurrencyIsoCode'));
                    
                    // Include the Extension quantity if there is an extension -- Renewal + Extension
                    // or Decommission quantity if a decomission -- Renewal + Decommission
                    qp.License_Metric_Quantity__c = qpw.assetRec.License_Metric_Quantity__c;
                    if      (qpw.quoteProdRec.Line_Type__c == 'Extension'   ) qp.License_Metric_Quantity__c += qpw.quoteProdRec.License_Metric_Quantity__c;
                    else if (qpw.quoteProdRec.Line_Type__c == 'Decommission') qp.License_Metric_Quantity__c -= qpw.quoteProdRec.Decommission_Quantity__c;
                    
                    qp.Quantity__c = 1;
                    qp.Asset_Term_Start_Date__c = qpw.assetRec.Asset_Term_End_Date__c + 1;
                    qp.Line_Type__c = 'Renewal';
                    qp.Product__c = qpw.productRec.Id;
                    
                    qp.Product__r = qpw.productRec;
                    qp.Quote__r = this.quote;
                    qp.Asset__r = qpw.assetRec;
                    qp.Asset__c = qpw.assetRec.Id;
                    
                    qp.Asset_Term_End_Date__c = toEndDate;
                    qp.Product_Group__c = qpw.assetRec.Product_Group__c;
                    
                    // Add Maintenance if we need to
                    // NOTE: We skip adding a renewal QP record for perpetual products here,
                    // for perpetual, we are only renewing the maintenance!
                    if (qpw.productRec.Is_Perpetual__c)
                    {
                        // We have a perpetual product and need to add Recurring Maintenance
                        // of the same quantity.
                        AddMaintenance(qpwMap, qp);
                    }
                    else
                    {
                        // Not perpetual, so renew the actual product
                        qpw.renewalQuoteProdRec = qp;
                        qpw.isRenewal = true;
                    }
                }
                else if (toEndDate <= qpw.assetRec.Asset_Term_End_Date__c)
                {
                    if (qpw.renewalQuoteProdRec != null && qpw.renewalQuoteProdRec.Asset_Term_End_Date__c == fromEndDate)
                    {
                        // Remove renewal QP
                        qpw.renewalQuoteProdRec = null;
                        qpw.isRenewal = false;
                    }
                    if (qpw.renewMaintQPRec != null && qpw.renewMaintQPRec.Asset_Term_End_Date__c == fromEndDate)
                    {
                        qpw.renewMaintQPRec = null;
                    }
                }
            }
        }
        
        // Re-populate lists
        populateListsAndPrice();
        
        // Close Update End Date popup window and update asset label
        isEditEndDate = false;
    }
    
     /**
     * @description  Show Edit Pricing Result Value Popup
     *
     * @author Vishal Shanbhag
     * @since   6.June.2014
     */
    public void showEditResultValue()
    {
        editPricingResult = new VCG_CPQ_Quote_Product_Pricing_Result__c();
        for (VCG_CPQ_Quote_Product_Pricing_Result__c pricingResult : pricingResultsMap.get(editPricingKey))
        {
            if (pricingProcSeqId != '')
            {
                if (pricingResult.Pricing_Procedure_Sequence__c == pricingProcSeqId)
                {
                    editPricingResult = pricingResult;
                    System.debug('editPricingResult in showEditResult >>>' + editPricingResult);
                }
            }
             
        }
        
        isEditResultValue = true;
    }
    
     /**
     * @description  Update Pricing Result Value (i.e. set a pricing result override)
     *
     * @author Vishal Shanbhag
     * @since   9.June.2014
     */
    public void updatePricingResultValue()
    {
        System.debug('editPricingResult in updatePricingResultValue >>>' + editPricingResult.Quote_Product__r);
        System.debug('editPricingResult result value integer' + editPricingResult.Result_Value__c);
        
        /** @todo  Replace with call to methods from PricingUtility to hide and standardize the generation of these keys */
        String overrideKey = editPricingKey + '-' + pricingProcSeqId;
        
        if (!pricingOverrideMap.containsKey(overrideKey))
        {
                
            
            VCG_CPQ_Pricing_Override__c pricingOverride = new VCG_CPQ_Pricing_Override__c(
                                                                                                Quote__r = quote
                                                                                              , Product__c = editPricingResult.Quote_Product__r.Product__c
                                                                                              , Group_Name__c = editPricingResult.Quote_Product__r.Product_Group__c
                                                                                              , Line_Type__c = editPricingResult.Quote_Product__r.Line_Type__c
                                                                                              , Override_Value_Type__c = editPricingResult.Result_Type__c
                                                                                              , Override_Value__c = editPricingResult.Result_Value__c
                                                                                              , Override_Value_Str__c = editPricingResult.Result_Value_String__c
                                                                                              , Override_Value_Date__c = editPricingResult.Result_Value_Date__c
                                                                                          );
            
            pricingOverride.Pricing_Procedure_Sequence__c = pricingProcSeqId;
            
            // Link to the override record from the pricing result record and clear the calculation 
            




            editPricingResult.Pricing_Override__r = pricingOverride;
            editPricingResult.Calculation_Summary__c = '';
            
           pricingOverrideMap.put(overrideKey, pricingOverride);
        }
        else
        {
            pricingOverrideMap.get(overrideKey).Override_Value_Type__c = editPricingResult.Result_Type__c;
            pricingOverrideMap.get(overrideKey).Override_Value__c = editPricingResult.Result_Value__c;
            pricingOverrideMap.get(overrideKey).Override_Value_Str__c = editPricingResult.Result_Value_String__c;
            pricingOverrideMap.get(overrideKey).Override_Value_Date__c = editPricingResult.Result_Value_Date__c;
        }
        
        System.debug('::::Pricing override map in updatePricingResult'+ pricingOverrideMap);
        
        // Flag the Quote Line Item as having and override
        editPricingResult.Quote_Product__r.IsResultValueOverride__c = true;
        editPricingResult.Quote_Product__r.Override_Count__c = (editPricingResult.Quote_Product__r.Override_Count__c == null ? 1 : editPricingResult.Quote_Product__r.Override_Count__c + 1);
        
        isEditResultValue = false;
        isPricingResultOverride = true;
//        overrideCount++;
        
        // Re-populate lists
        populateListsAndPrice();
    }
    
     /**
     * @description  Cancel Pricing Result Value Popup
     *
     * @author Vishal Shanbhag
     * @since   9.June.2014
     */
     public void cancelPricingResultEdit()
     {
        System.debug('before value+++++++++++' + editPricingResult);
        editPricingResult = new VCG_CPQ_Quote_Product_Pricing_Result__c();
        System.debug('aftercancel value+++++++++++' + editPricingResult);
        isEditResultValue = false;
     }
    
    /**
     * @description  Code to handle removing a pricing result override value. Parameters passed in
     *               via the overrideProduct and overridePPS variables from the VF page.
     *
     * @author Lawrence Coffin <lawrence.coffin@cloudsherpas.com>
     * @since  2.July.2014
     */  
    public String overrideProduct {get;set;}
    public String overridePPS {get;set;}
    public void removeOverride()
    {
        System.debug('====> remove override for product: ' + overrideProduct + ' + ' + overridePPS);
        
        //
        // Does:
        //   - Clear/delete override record
        //   - Clear reference to override record from Result record
        //   - Decrement QLI's Override_Count__c field
        //   - Decrement global overrideCount
        //
        
        System.debug('====> pricingOverrideMap before removal: ' + pricingOverrideMap);
        
        if (overridePPS != null && overridePPS != '')
        {
            // User requested removing a single override value. Remove it
            if (pricingOverrideMap.containsKey(overrideProduct + '-' + overridePPS))
            {
                VCG_CPQ_Pricing_Override__c overrideRec = pricingOverrideMap.get(overrideProduct + '-' + overridePPS);
                overrideRec.Pricing_Result__r.Quote_Product__r.Override_Count__c--;
                overrideRec.Pricing_Result__r.Pricing_Override__r = null;
                
                pricingOverrideMap.remove(overrideProduct + '-' + overridePPS);
//                overrideCount--;
            }
            
        }
        else
        {
            // User requested removing all overrides for a specific product.
            // Loop through all overrides and it we find one for the specified product, we remove the override.
            for (String key : pricingOverrideMap.keySet())
            {
                if (key.startsWith(overrideProduct + '-'))
                {
                    VCG_CPQ_Pricing_Override__c overrideRec = pricingOverrideMap.get(key);
                    overrideRec.Pricing_Result__r.Quote_Product__r.Override_Count__c--;
                    overrideRec.Pricing_Result__r.Pricing_Override__r = null;
                
                    pricingOverrideMap.remove(key);
//                    overrideCount--;
                }
            }
        }
        
        System.debug('====> pricingOverrideMap after removal: ' + pricingOverrideMap);
        
        // Reprice
        populateListsAndPrice();
    }
    
    /**
     * @description  Show Edit Start Date Popup
     *
     * @author Lawrence Coffin <lawrence.coffin@cloudsherpas.com>
     * @since   1.Apr.2014
     */
    public void showEditStartDate()
    {
        isEditStartDate = true;
        // Retrieve Wrapper instance
        eqWrapper = qpwMap.get(getQPWMapKey(eqProductId, activeGroup));
        editQP = new VCG_CPQ_Quote_Product__c();
        if (UserInfo.isMultiCurrencyOrganization()) editQP.put('CurrencyIsoCode', quote.get('CurrencyIsoCode'));
        editQP.Product__c = eqProductId;
        editQP.Asset_Term_Start_Date__c = eqWrapper.quoteProdRec.Asset_Term_Start_Date__c;
    }
    
    /**
     * @description  Update Start Date from Popup
     *
     * @author Lawrence Coffin <lawrence.coffin@cloudsherpas.com>
     * @since   1.Apr.2014
     */ 
    public void updateStartDate()
    {
        // If the Term Begin Date is not equals to the Quote Start Date
        if (editQP.Asset_Term_Start_Date__c != quote.Effective_Date__c)
        {
            // Populate Term Begin and End dates
            eqWrapper.quoteProdRec.Asset_Term_Start_Date__c = editQP.Asset_Term_Start_Date__c;
                        // Disabled - don't automatically push out to 1 year. 1.Apr.2014 -LC
//            eqWrapper.quoteProdRec.Asset_Term_End_Date__c = eqWrapper.quoteProdRec.Asset_Term_Start_Date__c.addYears(1).addDays(-1);
            if (eqWrapper.mainMaintQPRec != null) eqWrapper.mainMaintQPRec.Asset_Term_Start_Date__c = editQP.Asset_Term_Start_Date__c;
        }
        if (eqProductId != null) 
            qpwMap.put(getQPWMapKey(eqProductId, eqWrapper.quoteProdRec.Product_Group__c), eqWrapper);
        
        // Re-populate lists on page
        populateListsAndPrice();
        
        // Hide popup window and update asset labels
        isEditStartDate = false;
    }
    
    /**
     * @description  
     *
     * @author  Lawrence Coffin <lawrence.coffin@cloudsherpas.com>
     * @since   12.Nov.2014
     */
    public void showEditOtherValues()
    {
        isEditOtherValues = true;
        
        // Retrieve Wrapper instance
        eqWrapper = qpwMap.get(getQPWMapKey(eqProductId, activeGroup));
        
        // Create a new QP record for editing the Other fields, copy the values from the Extension record or the original Asset record to this temp record
        editQP = new VCG_CPQ_Quote_Product__c();
        if (UserInfo.isMultiCurrencyOrganization()) editQP.put('CurrencyIsoCode', quote.get('CurrencyIsoCode'));
        editQP.Product__c = eqProductId;
        editQP.Product__r = eqWrapper.productRec;
        
        sObject copyFromObj = ( eqWrapper.quoteProdRec.Line_Type__c != null ? ((sObject)eqWrapper.quoteProdRec) : ((sObject)eqWrapper.assetRec) );
        CopyOtherValues(copyFromObj, editQP, eqWrapper.productRec.CPQ_Display_Type__c);
/*        
        for (VCG_CPQ_Page_Layout__c fieldDef : GetDisplayFields('Edit Other Values'))
        {
            if (!fieldDef.Field__c.contains('.') && fieldDef.Display_For_Product_Type__c != null && fieldDef.Display_For_Product_Type__c.contains(eqWrapper.productRec.CPQ_Display_Type__c))
            {
                // Get the value from the current quoteProdRec record if it is set to a non-blank line type (i.e. ext, decom, other)
                editQP.put(fieldDef.Field__c, ( eqWrapper.quoteProdRec.Line_Type__c != null ? eqWrapper.quoteProdRec.get(fieldDef.Field__c) : eqWrapper.assetRec.get(fieldDef.Field__c) ));
            }
        }
*/
    }
    
    /**
     * @description  
     *
     * @author  Lawrence Coffin <lawrence.coffin@cloudsherpas.com>
     * @since   13.Nov.2014
     */ 
    public void CopyOtherValues(sObject fromObj, sObject toObj, String productDisplayType)
    {
        for (VCG_CPQ_Page_Layout__c fieldDef : GetDisplayFields('Edit Other Values'))
        {
            if (!fieldDef.Field__c.contains('.')
                && fieldDef.Display_For_Product_Type__c != null
                && fieldDef.Display_For_Product_Type__c.contains(productDisplayType))
            {
                // Get the value from the current quoteProdRec record if it is set to a non-blank line type (i.e. ext, decom, other)
                toObj.put(fieldDef.Field__c, fromObj.get(fieldDef.Field__c));
            }
        }
    }
    
    /**
     * @description  
     *
     * @author  Lawrence Coffin <lawrence.coffin@cloudsherpas.com>
     * @since   13.Nov.2014
     */ 
    public Boolean OtherValuesDiffer(sObject obj1, sObject obj2, String productDisplayType)
    {
        for (VCG_CPQ_Page_Layout__c fieldDef : GetDisplayFields('Edit Other Values'))
        {
            if (!fieldDef.Field__c.contains('.')
                && fieldDef.Display_For_Product_Type__c != null
                && fieldDef.Display_For_Product_Type__c.contains(productDisplayType)
                && fieldDef.Display_Type__c == 'Input')
            {
                if (obj1.get(fieldDef.Field__c) != obj2.get(fieldDef.Field__c))
                {
                    return true;
                }
            }
        }
        
        return false;
    }
    
    /**
     * @description  
     *
     * @author  Lawrence Coffin <lawrence.coffin@cloudsherpas.com>
     * @since   12.Nov.2014
     */ 
    public void updateOtherValues()
    {
        //
        // Copy edited values back to the main QP for this record
        //
        CopyOtherValues(editQP, eqWrapper.quoteProdRec, eqWrapper.productRec.CPQ_Display_Type__c);
/*      
        Boolean hasAValueDiffFromAsset = false; // if true at the end of copying all values back, this means that at least one of the other values are different than the corresponding Asset value
        
        for (VCG_CPQ_Page_Layout__c fieldDef : GetDisplayFields('Edit Other Values'))
        {
            if (!fieldDef.Field__c.contains('.')
                && fieldDef.Display_For_Product_Type__c != null
                && fieldDef.Display_For_Product_Type__c.contains(eqWrapper.productRec.CPQ_Display_Type__c))
            {
                // Copy the value to the quoteProduct record in all cases
                eqWrapper.quoteProdRec.put(fieldDef.Field__c, editQP.get(fieldDef.Field__c));
                
                // See if the value is the same as the asset value
                if (eqWrapper.assetRec.get(fieldDef.Field__c) != editQP.get(fieldDef.Field__c))
                {
                    hasAValueDiffFromAsset = true;
                }
            }
        }
*/        
        //
        // Now, if there is at least one value that is different than the asset value, we want to make
        // sure the QP record is set as Other, Extension, or Decommission
        //
        if (OtherValuesDiffer(eqWrapper.assetRec, eqWrapper.quoteProdRec, eqWrapper.productRec.CPQ_Display_Type__c))
        {
            if (eqWrapper.quoteProdRec.Line_Type__c == null)
            {
                eqWrapper.quoteProdRec.Line_Type__c = 'Other';
                
                eqWrapper.isOther = true;
                
                // Set up links and values we need to copy over from the asset record
                eqWrapper.quoteProdRec.Quote__r = this.quote;
                eqWrapper.quoteProdRec.Asset__c = eqWrapper.assetRec.Id;
                eqWrapper.quoteProdRec.Asset__r = eqWrapper.assetRec;
                eqWrapper.quoteProdRec.Product__c = eqWrapper.assetRec.Product__c;
                eqWrapper.quoteProdRec.Product__r = eqWrapper.productRec;
                
                // Copy over product group, term end date from the asset
                // Set term start date to the quote effective date (or the asset start date if later)
                eqWrapper.quoteProdRec.Product_Group__c = eqWrapper.assetRec.Product_Group__c;
                eqWrapper.quoteProdRec.Asset_Term_Start_Date__c = (eqWrapper.assetRec.Asset_Term_Start_Date__c > quote.Effective_Date__c ? eqWrapper.assetRec.Asset_Term_Start_Date__c  : quote.Effective_Date__c );
                eqWrapper.quoteProdRec.Asset_Term_End_Date__c = eqWrapper.assetRec.Asset_Term_End_Date__c;
            }
        }
        else if (eqWrapper.quoteProdRec.Line_Type__c == 'Other')
        {
            // All 'other' fields have the same values as the corresponding asset fields (i.e. the user has changed them
            // back to the same values), and the Line_Type == 'Other', so we want to reset the QP record on the QPW
            // Wipe out old quoteProdRec with any calculated values (resets Line_Type, etc.)
            eqWrapper.quoteProdRec = new VCG_CPQ_Quote_Product__c();
            if (UserInfo.isMultiCurrencyOrganization()) eqWrapper.quoteProdRec.put('CurrencyIsoCode', quote.get('CurrencyIsoCode'));
            
            // Recalculate line Totals
            eqWrapper.salesPriceTotal.aCurr2__c = eqWrapper.getSalesPriceTotal();
            eqWrapper.arrTotal.aCurr2__c = eqWrapper.getARRTotal();
            eqWrapper.lineTotal.aCurr2__c = eqWrapper.getLineTotal();
        }
        else {
            // Otherwise, we have an extension or decommission QP and we want to leave those alone 
        }
        
                
        // Re-populate lists on page
        populateListsAndPrice();
        
        // Hide popup window and update asset labels
        isEditOtherValues = false;
    }
    
    /**
     * @description  Cancel Edit from Popupp
     *
     * @author Lawrence Coffin <lawrence.coffin@cloudsherpas.com>
     * @since   1.Apr.2014
     */ 
    public void cancelEdit()
    {
        editQP = new VCG_CPQ_Quote_Product__c();
        if (UserInfo.isMultiCurrencyOrganization()) editQP.put('CurrencyIsoCode', quote.get('CurrencyIsoCode'));
        isEditStartDate = false;
        isEditEndDate = false;
        isEditOtherValues = false;
    }
    
    public PageReference cancel()
    {
        return new PageReference('/'+ quote.Opportunity__c);
    }
    
    /**
     * @description  Surfaces the Product Selection Form
     *
     * @author Lawrence Coffin <lawrence.coffin@cloudsherpas.com>
     * @since   1.Apr.2014
     */  
    public void showAddNew()
    {
        //flag = false;
        recAddOnsList.clear();
        
        // Note: Do this each time we display the AddNew popup, in case
        // something has changed the available products (Product List Filter)
        BuildProductFilterKeys(); // retrieveProductFamilies();
        
        activeGroup = ApexPages.currentPage().getParameters().get('group') == null ? '' : ApexPages.currentPage().getParameters().get('group');
       
        isAddNew = true;
        for (BundleWrapper b : availableBundles.values())
            b.isSelected = false;//initialize at false
    }
    
    /**
     * @description  Hide Add New Popup Window
     *
     * @author Lawrence Coffin <lawrence.coffin@cloudsherpas.com>
     * @since   1.Apr.2014
     */ 
    public void hideAddNew()
    {
        // Clear used variables
        recAddOnsList.clear();
        addNewFilteredProdList = new List<QuoteProductWrapper>();
//        retrieveProductFamilies();
        isAddNew = false;
    }
    
     /**
     * @description  This method retrieves the picklist values from the Product Family field on Product2
     *
     * @author Lawrence Coffin <lawrence.coffin@cloudsherpas.com>
     * @since   1.Apr.2014
     */ 
/*    public void retrieveProductFamilies()
    {
        pfWrapperList = new List<ProductFamilyWrapper>();
        List<String> productFamily = new List<String>();
        Set<String> productFamilySet = new Set<String>();
        
        String extraWhereClause = getProductFilter(quote);
        
        String soql = 'SELECT Family FROM Product2 WHERE IsActive = TRUE '
                        + (extraWhereClause == null ? '' : ' AND (' + extraWhereClause + ') ')
                        + ' ORDER BY Name';
        System.debug('====> Product Families query: ' + soql);
        
        for (Product2 p : Database.query(soql)) {
            if (!productFamilySet.contains(p.Family)){
                productFamily.add(p.Family);
                productFamilySet.add(p.Family);
            }
        } 
        
        // Sort list alphabetically
        productFamily.sort();
        
        for (String s : productFamily){
             pfWrapperList.add(new ProductFamilyWrapper(false,s));  
        }
    }
*/    
    /**
     * @description  Load Product Filter Keys for the current product set 
     *
     * @author Lawrence Coffin <lawrence.coffin@cloudsherpas.com>
     * @since   1.Apr.2014
     */  
    public void BuildProductFilterKeys()
    {
        
        // Load up the Product Filter Key values
        String extraWhereClause = getProductFilter(quote);
        
        String soql = 'SELECT ProductCode, Product_Filter_Key__c FROM Product2 WHERE IsActive = TRUE '
                        + (extraWhereClause == null ? '' : ' AND (' + extraWhereClause + ') ');
        System.debug('====> Product Filter Key query: ' + soql);
        
        List<Product2> products = Database.query(soql);
        
        if (products.size() == 0)
        {
            // No current products, clear PFKs
            ProductFilterKeys = null;
        }
        else
        {
            ProductFilterKeys = new Map<String,Object>();
            
            for (Product2 prod : products)
            {
                String pfKey = prod.Product_Filter_Key__c;
                List<String> pfKeyParts = pfKey.split('\\|');
                System.debug('====> pfKeyParts for ' + prod.ProductCode + ' (' + prod.Id + '): ' + pfKeyParts);
                
                if (pfKeyParts.size() > 0)
                {
                    Integer idx = 0;
                    Map<String,Object> node = ProductFilterKeys;
                    
                    do {
                        String keyPart = pfKeyParts[idx];
                        
                        if (!node.containsKey(keyPart))
                        {
                            if (idx < pfKeyParts.size() - 1)
                            {
                                // This node has children nodes, so add a sub-map
                                node.put(keyPart, new Map<String,Object>());
                            }
                            else
                            {
                                node.put(keyPart, null);
                            }
                        }
                        else
                        {
                            // keyPart already exists at this level, see if we need to convert from a null to a sub-map
                            if (node.get(keyPart) == null && idx < pfKeyParts.size() - 1)
                            {
                                node.put(keyPart, new Map<String,Object>());
                            }
                        }
                        
                        // Increment node to this keyPart's value (either null, or a sub-map) so we can handle any sub-keyParts
                        node = (Map<String,Object>)node.get(keyPart);
                        
                        // Increment idx
                        idx++;
                    } while (idx < pfKeyParts.size());
                }
            }
        }
        
        System.debug('====> ProductFilterKeys: ' + ProductFilterKeys);
    }
    
    /**
     * @description  This method filters the Products based on the Product Family selected 
     *
     * @author Lawrence Coffin <lawrence.coffin@cloudsherpas.com>
     * @since   1.Apr.2014
     */  
    public void showFilteredNewProducts()
    {
        System.debug('====> targetPFK: ' + targetPFK);
        set<Id> productIdSet = new set<Id>();
        
        recAddOnsList.clear();
        addNewFilteredProdList.clear();
        
        // Moved from controller to here because this is the only place it is used
        // and if stored in the controller and not transient, it substantially adds
        // to the view state size.
        Map<Id,Product2> addNewProductMap = getAvailableToPurchaseProducts();
        
        if (targetPFK != null && targetPFK != '')
        {
            //get the core products for add-ons
            for (Product2 p : addNewProductMap.values())
            {
                // See if the product matches the target Product Filter Key
                if (p.Product_Filter_Key__c == targetPFK || p.Product_Filter_Key__c.startsWith(targetPFK + '|'))
                {
                    productIdSet.add(p.Id);
                }
            }
            
            // Loop Product List to find products that match the target Product Filter Key
            for (Product2 p : addNewProductMap.values())
            { 
                // See if the product matches the target Product Filter Key
                if (p.Product_Filter_Key__c == targetPFK || p.Product_Filter_Key__c.startsWith(targetPFK + '|'))
                {
                    // Add the product to the list of matching products to display to the user
                    VCG_CPQ_Quote_Product__c qp = new VCG_CPQ_Quote_Product__c(Product__c = p.Id, Quote__r = this.quote);
                    if (UserInfo.isMultiCurrencyOrganization()) qp.put('CurrencyIsoCode', quote.get('CurrencyIsoCode'));
                    QuoteProductWrapper qpw = new QuoteProductWrapper(quote, p, qp, null);
                    
                    
                    addNewFilteredProdList.add(qpw);
                }
            }
            
            addNewFilteredProdList.sort();
        }
        
        newFilteredProductListSizeMsg = null;
        
        // Limit filtered product list to 100 (currently, each Product Filter Key has a max of 30 products. -LC 2015-07-13)
        // (Note that 1000 items is a VF limit, so this should be at least that)
        Integer maxCount = 100;
        if (addNewFilteredProdList.size() > maxCount)
        {
            System.debug('====> addNewFilteredProdList - original size: ' + addNewFilteredProdList.size() + ', truncating to ' + maxCount + ' items');
            
            newFilteredProductListSizeMsg = 'First ' + maxCount + ' of ' + addNewFilteredProdList.size() + ' total products';
            // Guess what? SF doesn't have a slice() or truncate() function. So we get to waste cycles and code here
            // to implement our own.
            List<QuoteProductWrapper> tmp = new List<QuoteProductWrapper>();
            for (Integer i = 0; i < maxCount; i++)
            {
                tmp.add(addNewFilteredProdList.get(i));
            }
            addNewFilteredProdList = tmp;
        }
        System.debug('====> addNewFilteredProdList: ' + addNewFilteredProdList);
        
        // Deselect the bundles
        selectedBundle = '';
        for (BundleWrapper b : availableBundles.values())
        {
            b.isSelected = false;
        }
    }
/*    public void showFilteredNewProducts_Orig()
    {
        Set<String> pf = new Set<String>();
        recAddOnsList.clear();
        addNewFilteredProdList = new List<QuoteProductWrapper>();
        
        // Collect which Product Family has been selected
        for (ProductFamilyWrapper pfw : pfWrapperList)
        {
            if (pfw.isSelected)
            {
                pf.add(pfw.productFamily);
            }
        }
        
        // If a Product Family has been selected
        if (addNewProductMap != null)
        {
            // Loop Product List
            for (Product2 p : addNewProductMap.values())
            {
                // Validate if Product Family of the current Product is selected
                if (pf.contains(p.Family))
                {
                    // Populate list to display the products
                    // Added Quote_r reference -- LC
                    VCG_CPQ_Quote_Product__c qp = new VCG_CPQ_Quote_Product__c(Product__c = p.Id, Quote__r = this.quote);
                    if (UserInfo.isMultiCurrencyOrganization()) qp.put('CurrencyIsoCode', quote.get('CurrencyIsoCode'));
                    addNewFilteredProdList.add(new QuoteProductWrapper(quote, p, qp, null));
                }
            }
            
            addNewFilteredProdList.sort();
        }
        
        //deselect the bundles
        selectedBundle = '';
        for (BundleWrapper b : availableBundles.values())
        {
            b.isSelected = false;
        }
    }
*/
        
    /**
     * @description  This method filters the Products based on the Product Family selected 
     *
     * @author Nathan Shinn
     * @since  25.June.2014
     */  
    public string selectedBundle{get;set;}
    public void showFilteredBundledNewProducts()
    {
        Set<Id> pf = new Set<Id>();
        selectedBundle = ApexPages.currentPage().getParameters().get('selectedBundle');
        recAddOnsList.clear();
        addNewFilteredProdList = new List<QuoteProductWrapper>();
        // Collect which Product Family has been selected
        for (BundleWrapper b : availableBundles.values())
        {
            if (b.isSelected && b.bundleName == selectedBundle)
            {
                //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info,''+b.bundleRecs));
                
                if (b.bundleRecs[0].Bundle_Product__c != null)
                {
                    // We have a SKU'd bundle, put the Bundle's product in the list, not the component products
                    // -- we want to quote using the bundle product, not the components
                    pf.add(b.bundleRecs[0].Bundle_Product__c);
                }
                else
                {
                    // Non-SKU'd bundle, show the component products
                    for(VCG_CPQ_Bundle__c p : b.bundleRecs)
                    {
                        pf.add(p.Product__c);
                    }
                }
                
            }
            else
            {
                //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info,''+selectedBundle));
                b.isSelected = false;
            }
        }
        
        // If a Product Family has been selected
        
        // Loop Product List
        String soql = 'SELECT '
                        +   String.join(VCG_CPQ_ProductUtility.GetProductFields(), ', ')
                        + ' FROM Product2 '
                        + ' WHERE Id IN :pf';
        for (Product2 p : Database.query(soql))
        {
                // Populate list to display the products
                VCG_CPQ_Quote_Product__c qp = new VCG_CPQ_Quote_Product__c(
                                                                              Product__c = p.Id,
                                                                              Quote__r = this.quote,
                                                                              Bundle_Name__c = selectedBundle
                                                                          );
                
                if (UserInfo.isMultiCurrencyOrganization()) qp.put('CurrencyIsoCode', quote.get('CurrencyIsoCode'));
                addNewFilteredProdList.add(new QuoteProductWrapper(quote, p, qp, null));
        }
            
        addNewFilteredProdList.sort();
        
        System.debug('====> addNewFilteredProdList: ' + addNewFilteredProdList);

/** @todo  Remove Product Family-related code (using Product Filter Keys now) */
// LC - no longer using Product Families
//        for (ProductFamilyWrapper pfw : pfWrapperList)
//        {
//            pfw.isSelected = false;
//        }
        
    }
    
    /**
     * @description  This method adds the Products to memory when the 'Add' button is clicked 
     *
     * @author  Vishal Shanbhag <vishal.shanbhag@cloudsherpas.com>
     * @since   29.May.2014
     */ 
     
     class ObjectIdPair
     {
        public string objectName{get;set;}
        public String objectId{get;set;}
        
        public ObjectIdPair(string name, string id)
        {
            objectName = name;
            objectId = id;
        }
     }
    public static String getProductFilter(VCG_CPQ_Quote__c quote)
    {

//
//piece of code to get map of all relationship fields of Quote object , relationship name and their object name
//
        //1. create a list of relationship fields
        Map<String, Schema.SObjectField> fieldMap = VCG_CPQ_Quote__c.sObjectType.getDescribe().fields.getMap();
        
        //2. create a map of related objects with Ids
        map<String,ObjectIdPair> relationshipObjects = new map<String, ObjectIdPair>();
        List<String> quoteFields;
        string quoteQuery = 'Select Id '; 
        for (String field : fieldMap.keySet())
        {
            List <Schema.sObjectType> relatedObject = fieldMap.get(field).getDescribe().getReferenceTo();
            if (relatedObject.size() > 0)
            {
                //System.debug(relatedObject);
                //System.Debug( fieldMap.get(field).getDescribe().getRelationshipName() );
                string relationshipName = fieldMap.get(field).getDescribe().getRelationshipName();
                string objectName = relatedObject[0].getDescribe().getName();
                
                try{//the field may not be present in the object instance...
                    if (quote.get(field) != null)
                    {
                        ObjectIdPair pair = new ObjectIdPair(objectName, (String)quote.get(field));
                        relationshipObjects.put(relationshipName, pair);
                    }
                }catch(Exception e){}
            }
        }
        System.debug('::::relationshipObjects::'+ relationshipObjects );
        
        //
        // Get the list of possible filters
        //
        List<VCG_CPQ_Product_Filter__c> ProductFilterResults = [SELECT Formula__c,
                                                                       Needs_Fields__c,
                                                                       Product_Where_Clause__c
                                                                FROM VCG_CPQ_Product_Filter__c
                                                                WHERE IsActive__c = TRUE
                                                                ORDER BY Sequence__c];
        
        //
        // Collect up fields that are needed for the filters
        //
        List<String> needsFieldsList = new List<String>();
        map<String, String> relatedObjectSelectListMap = new map<String, String>();
        for (VCG_CPQ_Product_Filter__c prodFil : ProductFilterResults)
        {
            if (prodFil.Needs_Fields__c == null || prodFil.Needs_Fields__c == '' )
            continue;
            quoteFields = new List<String>();
            for (String field : prodFil.Needs_Fields__c.split(';'))
            
            {
                System.debug(':::prodFil.Needs_Fields__c:::' + field);
                if (field.containsIgnoreCase('__r'))
                { 
                     System.debug(':::field.containsIgnoreCase::' + field);
                     String queryfield = field.substring(field.indexOf('.', 0)+1, field.length());
                     System.debug('::::queryField' + queryfield);
                     // if (field.indexOf('.', 0) >= 0)
                     // {
                         String keyField = field.substring(0,field.indexOf('.', 0));
                         System.debug(':::::keyField:::::'+keyField);
                         System.debug(':::::queryfield:::::'+queryfield);
                        if (relatedObjectSelectListMap.containsKey(keyField))
                            {
                                string slist = relatedObjectSelectListMap.get(keyField);
                                
                                if (!sList.containsIgnoreCase(queryfield) )
                                    slist += ', ' + queryfield;
                                
                                relatedObjectSelectListMap.put(keyField, slist);
                            }
                            else
                            {
                                relatedObjectSelectListMap.put(keyField,', '+queryfield);
                           }
                     // }
                }
                else
                {
                    quoteFields.add(field);
                    System.debug('::::adding fields in quotefields list'+ quoteFields );
                }
                
            }
          needsFieldsList.add(prodFil.Needs_fields__c);
        }
        
         for (string s : relationshipObjects.keySet())
        {
            ObjectIdPair pair = relationshipObjects.get(s);
            if (relatedObjectSelectListMap.containsKey(s))
            {
                string query = 'Select Id '+relatedObjectSelectListMap.get(s)+' from '+pair.objectName+' where Id = \''+pair.objectId+'\'';
                System.debug('====> populateFormulaData - Loading related Quote object: ' + query);
                quote.putSobject(s, Database.query(query));
            }
            else 
            {
                /*if (quoteFields.size() >0)
                {
                    for (String quoField : quoteFields)
                    {
                        if (quote.Id != null)
                        {
                            System.debug(':::quote needs fields::'+ quoField);
                            quoteQuery += ','+quoField +' from VCG_CPQ_Quote__c '+' where Id = \''+quote.Id+'\'';
                            System.debug('::::quoteQuery:::'+ quoteQuery);
                            quote.putSobject(quoField, Database.query(quoteQuery));
                        }
                        
                    }
                    
                }*/
            }
        }
        
        
        //
        // Load up all related objects/fields that are needed for the filters
        //
        /** @todo  Handle multiple fields in the 'Needs_Fields' list ... i.e. Account__r.Industry;Account__r.Region__c */
        /** @todo  Handle fields from *any* related object, not just Account__c ... can be *any* related object and go any number of levels deep -- i.e. Opportunity__r, Account__r, Partner__r, Opportunity__r.Deal_Registration_r... */
        /** @todo  Fields may also come directly from the Quote record as well, can't assume all fields are <Something>__r... */
 //    
        // Now, check each filter for the first matching filter and return the Product_Where_Clause
        // for the first one that matches.
        //
        for (VCG_CPQ_Product_Filter__c  FilterResult: ProductFilterResults)
        {
            VCG_CPQ_Formula.Result res =  VCG_CPQ_Formula.evaluate(quote, FilterResult.Formula__c);
            
            // If the formula evaluated as true, return the resulting Where Clause ... we only use the *first*
            // matching filter, we don't want to accumulate clauses and AND them together.
            if (res.value == 1)
            {
                return FilterResult.Product_Where_Clause__c;
            }
        }
        
        // If no filters matched, return null
        return null;
/**/
    }
    
    /**
     * @description  This method adds the Products to memory when the 'Add' button is clicked 
     *
     * @author Lawrence Coffin <lawrence.coffin@cloudsherpas.com>
     * @since   1.Apr.2014
     */ 
    public boolean hasAddonToSelect{get;set;}
    public void addProducts()
    {
        
        System.debug('====> addProducts() started');
        
        if(checkAddonCoreProducts() == true)
        {
            return;//need to select core products for the add-ons
        }
        
        
        addProductsCommon();
        
        if (!ApexPages.hasMessages(ApexPages.Severity.ERROR))
            hideAddNew();
    }
    
    
    /**
     * @description  This method adds the Products to memory when the 'Add & More' button is clicked 
     *
     * @author Lawrence Coffin <lawrence.coffin@cloudsherpas.com>
     * @since   1.Apr.2014
     */
    public void addMoreProducts()
    {    
        System.debug('====> addMoreProducts() started');
        
        if(checkAddonCoreProducts() == true)
        {
            return;//need to select core products for the add-ons
        }
        
        addProductsCommon();
        
        
        if (!ApexPages.hasMessages(ApexPages.Severity.ERROR))
        {
            recAddOnsList.clear();
//            retrieveProductFamilies();
        }
    }
    
    /**
     * @description  Used to select core products for add-ons thsat are orphaned
     * @author  Nathan Shinn
     * @since   08-22-2014
     
     //If the add-on is not groupable or any of its parents are not groupable, throw an error durring selection.
     
     //Websense user : security setting - "can skip upgrades"
        // - if they "can skip upgrades" allow them to choose the deprecated asset
        //    - allow them to skip pointing to the asset and save without a core
        // - if they can't. They have to select one of the upgrade products then run the upgrade (migration line type = "Upgrade") routine.
            
        //Stand-alone bug on line 1655
     */
    public set<Id> legacyProductsPrompted{get;set;}
    public Id selectedCoreProductId{get;set;}
    public string coreLegacyProductMessage{get;set;}
    public boolean checkAddonCoreProducts()
    {
        coreLegacyProductMessage = '';
        if(legacyProductsPrompted== null) legacyProductsPrompted = new set<Id>();
        map<Id, list<CoreProductWrapper>> coreProductMap = new map<Id, list<CoreProductWrapper>>();//used to identify products as add-ons and provide a list of ad-on parents
        set<Id> productIdSet = new set<Id>();
        list<QuoteProductWrapper> coreProductsToCreate = new list<QuoteProductWrapper>();
        for (QuoteProductWrapper qp : addNewFilteredProdList)
        {
            if (qp.quoteProdRec.License_Metric_Quantity__c != null 
                && qp.quoteProdRec.License_Metric_Quantity__c != 0
                && qp.quoteProdRec.Add_on_Source_Quote_Product__c == null)
            {
                productIdSet.add(qp.productRec.Id);
                for(CoreProductWrapper cpw : qp.coreProductList )
                {
                    
                    if( cpw.isSelected || selectedCoreProductId == cpw.product.productRec.Id) 
                    {
                        // raise an error if selected without a quantity
                        if(cpw.product.quoteProdRec.License_Metric_Quantity__c == null || cpw.product.quoteProdRec.License_Metric_Quantity__c < 1)
                        {
                            
                                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR
                                                                          ,'Please enter a quantity for the selected product: '+cpw.product.productRec.Name));
                                return true;
                        }
                        
                        // raise an error if this selection is not groupable
                        if(cpw.product.productRec.Is_Groupable__c && qp.productRec.Is_Groupable__c)
                        {
                            qp.quoteProdRec.Add_on_Source_Quote_Product__c =  cpw.product.quoteProdRec.Id;
                            qp.quoteProdRec.Add_on_Source_Quote_Product__r =  cpw.product.quoteProdRec;
                            // check to see whether its already selected as a product. 
                            // If not, create it in the current group (i.e. add it to the addNewFilteredProdList collection).
                            if(!qpwMap.containsKey(cpw.product.productRec.Id+activeGroup))
                            {
                                coreProductsToCreate.add(cpw.product);
                            }
                        }
                        else
                        {
                             // If the add-on is not groupable or any of its parents are not groupable, throw an error durring selection.
                            if(qp.productRec.Is_Groupable__c != true)
                                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,qp.productRec.Name + ' is not groupable.'));
                            else
                                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,cpw.product.productRec.Name + ' is not groupable.'));
                            return true;
                        }
                        
                    
                    }//end if
            }//end core product loop
            
            for(CoreProductWrapper cpw : qp.coreLegacyProductList )
            {
                if(selectedCoreProductId == cpw.product.productRec.Id)
                {       
                        /*** Look for a selected quote product that was generated as part of the migration using the Quote Product Map's 
                        //    equivalentProds list
                        // 1. prompt for quivilancy
                        // 2. run the equivilancy routine
                        // 3. associate the eauivilant product to the addOn
                        // 4. if this is the second time through this and the user can override this requirement, return and move on
                        //  
                        if( !(legacyProductsPrompted.contains(qp.ProductRec.Id) && getCanSkipUpgrades()) )
                        {
                            if(qpwMap.containsKey(qp.equivalentProds[0].Id+activeGroup))//already migrated. Choose the equivilant
                            {
                                qp.quoteProdRec.Add_on_Source_Quote_Product__c = qpwMap.get(qp.equivalentProds[0].Id+activeGroup).quoteProdRec.Id;
                                qp.quoteProdRec.Add_on_Source_Quote_Product__r = qpwMap.get(qp.equivalentProds[0].Id+activeGroup).quoteProdRec;
                            }
                            else
                            {
                                legacyProductsPrompted.add(qp.ProductRec.Id);//capture the fact that this was already prompted for
                                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,qp.productRec.Name + ' is a legacy product that needs to be migrated. Please migrate this product.'));
                            return true;
                        }
                    }
                        if(!(legacyProductsPrompted.contains(qp.ProductRec.Id) && getCanSkipUpgrades())) //user was prompted already for this product and is allowed to skip upgrades
                           
                        {
                            if(qpwMap.containsKey(cpw.product.equivalentProds[0].Id+activeGroup))//already migrated. Choose the quivilant
                            {
                                qp.quoteProdRec.Add_on_Source_Quote_Product__c = qpwMap.get(cpw.product.equivalentProds[0].Id+activeGroup).quoteProdRec.Id;
                                qp.quoteProdRec.Add_on_Source_Quote_Product__r = qpwMap.get(cpw.product.equivalentProds[0].Id+activeGroup).quoteProdRec;
                }
                            else
                            {
                                legacyProductsPrompted.add(qp.ProductRec.Id);//capture the fact that this was already prompted for
                                coreLegacyProductMessage = qp.productRec.Name + ' is a legacy product that needs to be migrated. Would you like to migrate this legacy product and associate the add-on to it?';
                                //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info,cpw.product.productRec.Name + ' is a legacy product that needs to be migrated.'));
                                return true;
                            }
                        }*/
                        if( selectedCoreProductId == cpw.product.productRec.Id)
                        {
                            //run the migration and retrieve the equivilant product to assign to the add-on
                            VCG_CPQ_Quote_Product__c vp = migrateProduct();
                            
                            qp.quoteProdRec.Add_on_Source_Quote_Product__c =  (vp.Id);
                            qp.quoteProdRec.Add_on_Source_Quote_Product__r =  vp;
                        }
            }
        } 
            }
        } 
        
        //Remove Legacy Product from the quote once migrated
        //set IsMigrated Flag on the quote Legacy Quote Product
        //Pull in all fields off of Quote_PRoduct and Asset Records Dynamicaly using describe.
        
        //add in the missing core products that were not selected originally.
        if(coreProductsToCreate.size() > 0)
        {
            addNewFilteredProdList.addAll(coreProductsToCreate);
        }
        // query for a map of products to core products (these are add-ons and their associated core products)
        /** @todo  Remove the Product__r fields from this query and instead populate Product__r from 
                   QuoteController.GetProduct() ?? That way we can ensure that we are loading all the proper 
                   product fields without having to make this query a dynamic SOQL query and convert the product fields 
                   from ProductUtility.GetProductFields() */
        for(VCG_CPQ_Product_Addon__c addon : [SELECT Product__r.Name
                                                   , Product_Addon__c
                                                   , Required__c
                                                   , Addon_Group__c
                                                   , Needs_Fields__c
                                                FROM VCG_CPQ_Product_Addon__c
                                                WHERE Product_Addon__c in :productIdSet])
        {
            addon.Product__r = GetProduct(addon.Product__c);
            QuoteProductWrapper qpw;
            if(qpwMap.containsKey(addon.Product__c+activeGroup))
            {
                qpw = qpwMap.get(addon.Product__c+activeGroup);
            }
            else
            {
                qpw = new QuoteProductWrapper(quote
                                            , addOn.Product__r
                                            , new VCG_CPQ_Quote_Product__c( Product__c = addon.Product__c
                                                                          , License_Metric_Quantity__c = 0
                                                                          , Quote__r = this.quote)
                                             , null);
            }
            
            // Only force users to select an add-on if the add-on rule is required
            /** @todo  Apply the Add-Ons needs fields to quote before trying to evaluate the formula! */
            if (VCG_CPQ_Formula.evaluate(quote, addon.Required__c).value == 1.0)
            {
                if(coreProductMap.containsKey(addon.Product_Addon__c))
                {
                    list<CoreProductWrapper> p2 = coreProductMap.get(addon.Product_Addon__c);
                    p2.add(new CoreProductWrapper(false, qpw));
                }
                else
                {
                    coreProductMap.put(addon.Product_Addon__c, new list<CoreProductWrapper>{new CoreProductWrapper(false, qpw)});
                }
            }
        }
        
        //load the existing quote products into a map for automatic selection as the source of an ad-on Product
        map<Id, Id> existingQuoteProductsMap = new map<Id, Id>();
        
        /*************Addon_To_Asset__r***********/
        hasAddonToSelect = false;
        //check to see if this is an add-on and if so, adjust the quote product wrapper accordingly
        for (QuoteProductWrapper qp : addNewFilteredProdList)
        {
            /** @todo  Convert this to getQPWMapKey() */
            if(qpwMap.containsKey(qp.productRec.Id + activeGroup))
            {
                if(qpwMap.get(qp.productRec.Id + activeGroup).quoteProdRec.Add_on_Source_Quote_Product__r != null 
                   || qpwMap.get(qp.productRec.Id + activeGroup).quoteProdRec.Add_on_Source_Quote_Product__c != null)
                    continue;//we already added the parent. This record will just reuslt in addi quantity to an existing addon
            }
            
            if(qp.quoteProdRec.License_Metric_Quantity__c != null && qp.quoteProdRec.License_Metric_Quantity__c != 0 
             && coreProductMap.containsKey(qp.productRec.Id) && (qp.quoteProdRec.Add_on_Source_Quote_Product__r == null && qp.quoteProdRec.Add_on_Source_Quote_Product__c == null))
            {
                qp.isAddon = true;
                
                qp.coreProductList = new list<CoreProductWrapper>();
                qp.coreLegacyProductList = new list<CoreProductWrapper>();
                
                //seperate legacy from new products
                for(CoreProductWrapper cpw : coreProductMap.get(qp.productRec.Id))
                {
                    if(cpw.product.hasEquivalency)
                        qp.coreLegacyProductList.add(cpw);
                    else
                        qp.coreProductList.add(cpw);
                }
                //see if an existing quote product satisfies the add-on and select one of them
                for(CoreProductWrapper cpw : qp.coreProductList)
                {
                    if(qpwMap.containsKey(cpw.product.quoteProdRec.Id + qp.quoteProdRec.Product_Group__c))
                    {
                        //qp.addOnResultRec = new VCG_CPQ_Product_Addon_Wrapper(qp.quoteProdRec, qp.productRec);
                        qp.quoteProdRec.Add_on_Source_Quote_Product__c =  qpwMap.get(cpw.product.quoteProdRec.Id + qp.quoteProdRec.Product_Group__c).quoteProdRec.Id;
                        qp.quoteProdRec.Add_on_Source_Quote_Product__r =  qpwMap.get(cpw.product.quoteProdRec.Id + qp.quoteProdRec.Product_Group__c).quoteProdRec;
                    }
                }
                
                if(qp.quoteProdRec.Add_on_Source_Quote_Product__r != null)
                    continue;//we found an existing product in the list of quote products. Process the next record.
                    
                if(qp.coreProductList.size() == 1 && qp.coreLegacyProductList.size() == 0 && qpwMap.containsKey(qp.productRec.Id  + activeGroup))
                {
                    qp.addOnResultRec = new VCG_CPQ_Product_Addon_Wrapper(qp.quoteProdRec, qp.productRec);
                    qp.quoteProdRec.Add_on_Source_Quote_Product__c =  qp.coreProductList[0].product.quoteProdRec.Id;
                    qp.quoteProdRec.Add_on_Source_Quote_Product__r =  qp.coreProductList[0].product.quoteProdRec;
                    qp.quoteProdRec.License_Metric_Quantity__c = 1; 
                }
                else if(qp.coreProductList.size() > 1 || qp.coreLegacyProductList.size() > 0)
                {
                    hasAddonToSelect = true;
                }
            }
        } 
        
        
        if(hasAddonToSelect == true)
        {
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info,'Some of the products you have selected are add-ons to other products. Below are the product selections available for association to the selected Add-on. If the Product is a Legacy Asset already associated to the account (indicated by the yellow alert), please migrate this product by clicking the yellow icon to the right of the product name.'));
            
        }
        fromCoreProductSelection = false;
        selectedCoreProductId = null;
        //hasAddonToSelect = true;
        return hasAddonToSelect;
        
    }
    
    /**
     * @description  Common method for Addproducts and addMoreProducts
     * @author  Vishal Shanbhag
     * @since   8.Apr.2014
     */
    public void addProductsCommon()
    {
        System.debug('====> addProductsCommon() started');
        
        // Loop Quote Product List
        //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info,'Active Group: ['+activeGroup+']'));
        List<QuoteProductWrapper> CumAddNewFilteredProdList = new List<QuoteProductWrapper>();
        List<VCG_CPQ_Quote_Product__c> newQuoteProducts = new List<VCG_CPQ_Quote_Product__c>();
        System.debug('>>>>>>>>addNewFilteredProdList>>>' + addNewFilteredProdList);
        System.debug('====> qpwMap keys: ' + qpwMap.keySet());
        
        for (QuoteProductWrapper qp : addNewFilteredProdList)
        {
            if (qp.quoteProdRec.License_Metric_Quantity__c != null && qp.quoteProdRec.License_Metric_Quantity__c != 0)
            {
                qp.quoteProdRec.Product_Group__c = '' + activeGroup;
                System.debug('====> Added QP to group: ' + qp.quoteProdRec.Product_Group__c);
                System.debug('====> Adding product ' + qp.productRec.Name + ' to CumAddNewFilteredProdList');
                CumAddNewFilteredProdList.add(qp);
                System.debug('====> Adding product ' + qp.productRec.Name + ' to newQuoteProducts');
                newQuoteProducts.add(qp.quoteProdRec);
             }  
         }
        
        for (QuoteProductWrapper rl : recAddOnsList)
        {
            rl.quoteProdRec.Product_Group__c = '' + activeGroup;
            System.debug('====> Added Add-On QP to group: ' + rl.quoteProdRec.Product_Group__c);
            if (rl.quoteProdRec.License_Metric_Quantity__c != null && rl.quoteProdRec.License_Metric_Quantity__c != 0)
            {
                System.debug('====> Adding product ' + rl.productRec.Name + ' to CumAddNewFilteredProdList');
                CumAddNewFilteredProdList.add(rl);
                System.debug('====> Adding product ' + rl.productRec.Name + ' to newQuoteProducts');
                newQuoteProducts.add(rl.quoteProdRec);
            }
        }
        
        //
        // Before modifying qpwMap, make a copy first, modify that, then do validation.
        // If validation passes, then replace/update qpwMap, otherwise we discard the changes
        //
        // NOTE: Do a shallow clone first, not sure if we need to do a deep clone instead
        //
        Map<String,QuoteProductWrapper> qpwMapCopy = qpwMap.clone();
        
        for (QuoteProductWrapper qp : CumAddNewFilteredProdList)
        {
            if (qp.productRec.Is_Groupable__c)
            {
                qp.quoteProdRec.Product_Group__c = '' + activeGroup;
            }
            else
            {
                // Note: Don't use dashes ('-') in the below group name until the key separator for pricing results has been changed!
                qp.quoteProdRec.Product_Group__c = (quote.Groups_Active__c ? 'Standalone' : '');
            }
            System.debug('====> Re-set QP "' + qp.productRec.Name + '" to group: ' + qp.quoteProdRec.Product_Group__c);
            
            // If the Quantity is not null or 0, it means the user wants the Product to be added
            if (qp.quoteProdRec.License_Metric_Quantity__c != null && qp.quoteProdRec.License_Metric_Quantity__c != 0)
            {
                
                // First, check to see if we already have this product in the qpwMap. If so, we don't want to add
                // duplicates, rather we want to add the specified quantity to the existing record. If it is
                // an existing asset, then the net result is an extension. If it is the same product previously
                // added to the quote (i.e. 'New'), then we simply want to increment the quantity.
                if (qpwMapCopy.containsKey(getQPWMapKey(qp.productRec.Id, qp.quoteProdRec.Product_Group__c)))
                {
                    System.debug('====> Adding more of product: ' + qp.productRec.Id + ' - ' + qp.productRec.ProductCode);
                    
                    QuoteProductWrapper qpw = qpwMapCopy.get(getQPWMapKey(qp.productRec.Id, qp.quoteProdRec.Product_Group__c));
                    System.debug('====> qpRec from Map: ' + qpw.quoteProdRec);
                    //this may be part of a new bundle. Add the current bundle name
                    qpw.quoteProdRec.Bundle_Name__c = qp.quoteProdRec.Bundle_Name__c;
                    
                    /** @todo  Review for various use cases -- Renewal + Add New, Extension + Add New, Decom + Add New, etc. */
                    if (qpw.quoteProdRec != null && qpw.quoteProdRec.License_Metric_Quantity__c != null && errorflag == false)
                    {
                        // If we have an existing QP record in the QPW, and it has a quantity already, then
                        // keep it and simply increment the quantity.
                        qpw.quoteProdRec.License_Metric_Quantity__c += qp.quoteProdRec.License_Metric_Quantity__c;
                        //if(qpw.quoteProdRec.Bundle_Name__c != qp.quoteProdRec.Bundle_Name__c)
                    }
                    else
                    {
                        // Otherwise, use the selected QP record as the QPW QP record
                        // NOTE: This is affecting the qpw record for existing/renewal/extension that there is additional code below for as well.
                        /** @todo  I don't think this is the correct behavior in all cases... say for example if you have an existing renewal quote product record */
                        qpw.quoteProdRec = qp.quoteProdRec;
                    }
                    
                    /** @todo  Why is this being set? Is this old code from back with "AddOn" meant either 'New' or 'Extension'? */
// Disabled. Don't think this is correct. -LC 23.Sep.2014
//                    qpw.isAddOn = true;
                    
                    if (qpw.assetRec != null)
                    {
                        qpw.isExisting = true;
                        qpw.isExtension = true;
                        // NOTE: This is the quoteProdRec set from above, so LMQ is set above - might want to break out the different scenarios better, so all code affecting existing assets in one block, etc. */
                        qpw.quoteProdRec.Asset__r = qpw.assetRec;
                        qpw.quoteProdRec.Asset__c = qpw.assetRec.Id;
                        qpw.quoteProdRec.Line_Type__c = 'Extension';
                        // Set term begin date for the extension to the later of the asset start date or the quote start date
                        qpw.quoteProdRec.Asset_Term_Start_Date__c = (qpw.assetRec.Asset_Term_Start_Date__c > quote.Effective_Date__c ? qpw.assetRec.Asset_Term_Start_Date__c  : quote.Effective_Date__c );
                        qpw.quoteProdRec.Asset_Term_End_Date__c = qpw.assetRec.Asset_Term_End_Date__c;
                        //qpw.quoteProdRec.Bundle_Name__c = qpw.assetRec.Bundle_Name__c;
                        //Update the asset record with the new bundle name for display
                        if (qpw.assetRec.Bundle_Name__c != qp.quoteProdRec.Bundle_Name__c)
                        {
                            qpw.assetRec.Bundle_Name__c = qp.quoteProdRec.Bundle_Name__c;
                        }
                        
                        if (qpw.renewalQuoteProdRec != null)
                        {
                            // Renewal + Extension
                            qpw.renewalQuoteProdRec.License_Metric_Quantity__c = qpw.assetRec.License_Metric_Quantity__c + qp.quoteProdRec.License_Metric_Quantity__c;
                        }
                    }
                    else
                    {
                        qpw.quoteProdRec.Line_Type__c = 'New';
                        qpw.isNew = true;
                        
                        // Set start and end term dates -- use quote Start_Date or TODAY() to start, use the common
                        // end date of previously configured products or one year from start date for the end date
                        qpw.quoteProdRec.Asset_Term_Start_Date__c = (quote.Effective_Date__c == null ? Date.today() : quote.Effective_Date__c);
                        System.debug('====> Asset_Term_Start_Date__c - 4: ' + qpw.quoteProdRec.Asset_Term_Start_Date__c);
//                      if (!qpw.productRec.Is_Perpetual__c)
//                      {
                            qpw.quoteProdRec.Asset_Term_End_Date__c = getCommonTermEndDate(qpwMapCopy, qpw.quoteProdRec.Asset_Term_Start_Date__c.addYears(1).addDays(-1));
//                      }
                    }
//                    if (qpw.renewalQuoteProdRec != null)
//                    {
//                        /** @todo  Resolve this! */
//                        /** Note: to test this scenario, start with an existing asset; renew it; then do Add New and add additional quantity to the same product */
//                        // Not sure what value this should be. Was the old combined quantity, but now should be ...? Asset quantity? -LC 2014-04-25
////                        qpw.renewalQuoteProdRec.License_Metric_Quantity__c = qpw.quantity;
//                        // Throw whatever exception we have on hand
//                        throw new VCG_CPQ_Formula.Formula_Exception('renewalQuoteProdRec error. Inform admin of steps that led to this exception. (Added additonal quantity to an existing asset that has already be marked for renewal?)');
//                    }
                    
                    if (qp.productRec.Id != null)
                    {
                        System.debug('====> qpRec assigned back to Map: ' + qpw.quoteProdRec);
                        qpwMapCopy.put(getQPWMapKey(qp.productRec.Id, qpw.quoteProdRec.Product_Group__c), qpw);
                    }
                    
                    // Add Maintenance if we need to
                    System.debug('====> Checking to see if we need maintenance (1)');
                    if (qpw.productRec.Is_Perpetual__c)
                    {
                        System.debug('====> Yep, perpetual product, adding maintenance (1)');
                        // we have a perpetual product
                        // here we are either doing an extension, or we are incrementing a net new product (or an extension)
                        // For perpetual products, either new or extension, we need to add First Year Maintenance of the same
                        // quantity.
                        AddMaintenance(qpwMapCopy, qpw.quoteProdRec);
                    }
                }
                // If a new product is added, add a new instance to the Quote Product wrapper
                else
                {
                    System.debug('====> Adding new product: ' + qp.productRec.Id + ' - ' + qp.productRec.ProductCode);
                    
                    // Added Quote_r reference -- LC
                    qp.quoteProdRec.Quote__r = this.quote;
                    
                    QuoteProductWrapper qpw = new QuoteProductWrapper(quote, qp.productRec, qp.quoteProdRec, null);
                    qpw.quoteProdRec.Product__c = qp.productRec.Id;
                    qpw.isNew = true;
                    qpw.isExisting = false;
                    qpw.quoteProdRec.Line_Type__c = 'New';
                    
                    
                    // Set start and end term dates -- use quote Start_Date or TODAY() to start, use the common
                    // end date of previously configured products or one year from start date for the end date
                    qpw.quoteProdRec.Asset_Term_Start_Date__c = (quote.Effective_Date__c == null ? Date.today() : quote.Effective_Date__c);
                    System.debug('====> Asset_Term_Start_Date__c - 4: ' + qpw.quoteProdRec.Asset_Term_Start_Date__c);
//                    if (!qpw.productRec.Is_Perpetual__c)
//                    {
                        qpw.quoteProdRec.Asset_Term_End_Date__c = getCommonTermEndDate(qpwMapCopy, qpw.quoteProdRec.Asset_Term_Start_Date__c.addYears(1).addDays(-1));
//                    }
                    
                    
                    if (qp.productRec.Id != null)
                    {
                        System.debug('====> Adding new Quote Product rec to qpwMapCopy: ' + qpw.quoteProdRec);
                       qpwMapCopy.put(getQPWMapKey(qp.productRec.Id, qpw.quoteProdRec.Product_Group__c), qpw);
                    }
                    
                    // Add Maintenance if we need to
                    System.debug('====> Checking to see if we need maintenance (2)');
                    if (qpw.productRec.Is_Perpetual__c)
                    {
                        System.debug('====> Yep, perpetual product, adding maintenance (2)');
                        // We have a perpetual product and need to add First Year Maintenance of the same
                        // quantity.
                        AddMaintenance(qpwMapCopy, qpw.quoteProdRec);
                        System.debug('====> qpwMapCopy after adding maintenance: ' + qpwMapCopy);
                    }
                }
            }
        }
        
        // Validate the products added
        System.debug('====> newQuoteProducts.size(): ' + newQuoteProducts.size());
        System.debug('====> newQuoteProducts: ' + newQuoteProducts);
        /** @todo  Update this to pass in a copy of the original products plus the new products ... 
                   *without* adding the new products to the *real* current products list */
        List<VCG_CPQ_Error> productErrors = validateProductSelection(qpwMapCopy);
        if (productErrors.size() > 0)
        {
            for (VCG_CPQ_Error e : productErrors)
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,e.errorType+': ['+e.errorMessage+']'));
                errorFlag = True;
            }
            return;
        }
        else
        {
            errorFlag = False;
        }
        
        //
        // Validation passed, so replace the qpwMap with the modified qpwMapCopy
        //
        qpwMap = qpwMapCopy;
        
        // Re-populate lists on page
        populateListsAndPrice();
     
        // Clear used variables
        if (! ApexPages.hasMessages(ApexPages.Severity.ERROR))
            addNewFilteredProdList = new List<QuoteProductWrapper>();
     }
     
    
    /**
     * @description  Adds (or increments) the specified Maintenance SKU
     *               Edited to return true if a maintenance line was added, false if not (due to no maintenance product specified)
     * 
     * @author  Lawrence Coffin <lawrence.coffin@cloudsherpas.com>
     * @since   23.Sep.2014
     */
    set<String>assetizedLineTypes = new set<String>{'Decommission','Extension'};
    public Boolean AddMaintenance(Map<String, QuoteProductWrapper> qpwMap, VCG_CPQ_Quote_Product__c parentQP)
    {
        System.debug(LoggingLevel.ERROR, '====> AddMaintenance() called');
        
        String groupName = parentQP.Product_Group__c;
        
        // maintenance is stored under the parent QPW record
        String qpwMapKey = getQPWMapKey(parentQP.Product__r.Id, groupName);
        
        QuoteProductWrapper parentQPW = qpwMap.get(qpwMapKey);
        
        
        if (parentQP.Line_Type__c == 'Renewal')
        {
            // first, return if no maintenance is specified for this product
            if (parentQP.Product__r.Recurring_Maintenance__c == null)
            {
                System.debug(LoggingLevel.ERROR, '====> AddMaintenance() returning, no maintenance product id');
                return false;
            }
        
            System.debug(LoggingLevel.ERROR, '====> AddMaintenance() maintProdId: ' + parentQP.Product__r.Recurring_Maintenance__c);
            System.debug(LoggingLevel.ERROR, '====> AddMaintenance() Line Type: ' + parentQP.Line_Type__c);
        
            Product2 maintProdRec = GetProduct(parentQP.Product__r.Recurring_Maintenance__c);
        
            VCG_CPQ_Quote_Product__c maintQP = new VCG_CPQ_Quote_Product__c (
                                                                                  Product__c = parentQP.Product__r.Recurring_Maintenance__c,
                                                                                  Product__r = maintProdRec,
                                                                                  Quote__r = quote,
                                                                                  Product_Group__c = groupName,
                                                                                  License_Metric_Quantity__c = parentQP.License_Metric_Quantity__c,
                                                                                  Asset_Term_Start_Date__c = parentQP.Asset_Term_Start_Date__c,
                                                                                  Asset_Term_End_Date__c = (parentQP.Asset_Term_End_Date__c == null ? parentQP.Asset_Term_Start_Date__c.addYears(1).addDays(-1) : parentQP.Asset_Term_End_Date__c),
                                                                                  Add_On_To_Asset__c = parentQP.Asset__c,
                                                                                  Add_On_To_Asset__r = parentQP.Asset__r,
                                                                                  Line_Type__c = 'Renewal',
                                                                                  Asset__c = parentQP.Asset__c,
                                                                                  Asset__r = parentQP.Asset__r
                                                                               );
            
            if (UserInfo.isMultiCurrencyOrganization())
            {
                maintQP.put('CurrencyIsoCode', quote.get('CurrencyIsoCode'));
            }
            
            System.debug(LoggingLevel.ERROR, '====> Maintenance rec: ' + maintQP);
            
            parentQPW.renewMaintQPRec = maintQP;
            parentQPW.isRenewal = true;
        }
        else
        {
            // first, return if no maintenance is specified for this product
            if (parentQP.Product__r.First_Year_Maintenance__c == null)
            {
                System.debug(LoggingLevel.ERROR, '====> AddMaintenance() returning, no maintenance product id');
                return false;
            }
            
            System.debug(LoggingLevel.ERROR, '====> AddMaintenance() maintProdId: ' + parentQP.Product__r.First_Year_Maintenance__c);
            System.debug(LoggingLevel.ERROR, '====> AddMaintenance() Line Type: ' + parentQP.Line_Type__c);
            
            Product2 maintProdRec = GetProduct(parentQP.Product__r.First_Year_Maintenance__c);
            
            System.debug(LoggingLevel.ERROR, '====> AddMaintenance() parentQP: ' + parentQP);
            
            VCG_CPQ_Quote_Product__c maintQP = new VCG_CPQ_Quote_Product__c (
                                                                                  Product__c = parentQP.Product__r.First_Year_Maintenance__c,
                                                                                  Product__r = maintProdRec,
                                                                                  Quote__r = quote,
                                                                                  Product_Group__c = groupName,
                                                                                  License_Metric_Quantity__c = parentQP.License_Metric_Quantity__c,
                                                                                  Asset_Term_Start_Date__c = parentQP.Asset_Term_Start_Date__c,
                                                                                  Asset_Term_End_Date__c = (parentQP.Asset_Term_End_Date__c == null ? parentQP.Asset_Term_Start_Date__c.addYears(1).addDays(-1) : parentQP.Asset_Term_End_Date__c),
                                                                                  Add_On_Source_Quote_Product__r = parentQP, // Should probably make this null for Decom, but that is causing errors elsewhere currently. Need to research more, for now, this isn't 100% correct, but shouldn't affect anything except possibly pricing for Decom, which shouldn't be based on Add_on_Source_QP anyway
                                                                                  Line_Type__c = parentQP.Line_Type__c,
                                                                                  Asset__c = parentQP.Asset__c,
                                                                                  Asset__r = parentQP.Asset__r,
                                                                                  
                                                                                  // Handle decoms here as well (these will be null if not decom)
                                                                                  Decommission_Quantity__c = parentQP.Decommission_Quantity__c,
                                                                                  Decommission_Reason__c = parentQP.Decommission_Reason__c,
                                                                                  Decommission_Type__c = parentQP.Decommission_Type__c,
                                                                                  Decommission_Effective_Date__c = parentQP.Decommission_Effective_Date__c,
                                                                                  Add_On_To_Asset__c = (assetizedLineTypes.contains(parentQP.Line_Type__c) ? parentQP.Asset__c : null),
                                                                                  Add_On_To_Asset__r = (assetizedLineTypes.contains(parentQP.Line_Type__c) ? parentQP.Asset__r : null)
                                                                               );
            
            if (UserInfo.isMultiCurrencyOrganization())
            {
                maintQP.put('CurrencyIsoCode', quote.get('CurrencyIsoCode'));
            }
            
            System.debug(LoggingLevel.ERROR, '====> Maintenance rec: ' + maintQP);
            
            parentQPW.mainMaintQPRec = maintQP;
        }
        
        // Returning true indicates that we successfully added a Maintenance line
        return true;
    }
     
    
    /**
     * @description  Returns the most frequently used Term End Date in the Quote Products Wrapper Map
     *               If there are no existing configured products or bundles, or none of them have end dates
     *               then return the defaultDate value
     * 
     * @author  Lawrence Coffin <lawrence.coffin@cloudsherpas.com>
     * @since   1.Apr.2014
     Map<String,BundleWrapper> configBundles,
     */
    public Date getCommonTermEndDate(Map<string, QuoteProductWrapper> qpwMap,  Date defaultDate)
    {
        Map<Date,Integer> dateCounts = new Map<Date,Integer>();
        Date commonDate;
        
        // Check for empty/null maps
        if ((qpwMap == null || qpwMap.size() == 0)
            && (configBundles == null || configBundles.size() == 0))
        {
                return defaultDate;
        }
        
        //
        // Count up end dates in QuoteProductWrapper records
        //
        for (QuoteProductWrapper qpw : qpwMap.values()) 
        {
            Date endDate;
            
            if (qpw.isNew) 
            {
                endDate = qpw.quoteProdRec.Asset_Term_End_Date__c;
            }
            else if (qpw.isRenewal && qpw.renewalQuoteProdRec != null)
            {
                endDate = qpw.renewalQuoteProdRec.Asset_Term_End_Date__c;
            }
            else if (qpw.isRenewal && qpw.renewMaintQPRec != null)
            {
                endDate = qpw.renewMaintQPRec.Asset_Term_End_Date__c;
           }
            else 
            {
                // existing asset only
                endDate = qpw.assetRec.Asset_Term_End_Date__c;
           }
           
            if (endDate != null) 
            {
                    if (!dateCounts.containsKey(endDate)) 
                    {
               dateCounts.put(endDate, 1);
           }
                    else 
                    {
               dateCounts.put(endDate, dateCounts.get(endDate) + 1);
           }
       }
        }
       
       //
        // Add in count from BundleWrapper records - once per bundle (not once per end product)
        //
        /*
        for (BundleWrapper bundle : configBundles.values()) 
        {
            Date endDate = bundle.termEnd.aDate__c;
            
            if (endDate != null) 
            {
                if (!dateCounts.containsKey(endDate)) 
                {
                    dateCounts.put(endDate, 1);
                }
                else 
                {
                    dateCounts.put(endDate, dateCounts.get(endDate) + 1);
                }
            }
        }
        */
        if (dateCounts.size() > 0) 
        {
            //
       // Get most frequent date
       //
            Integer maxCount = 0;
       
            for (Date endDate : dateCounts.keySet()) 
            {
                if (dateCounts.get(endDate) > maxCount) 
                {
               commonDate = endDate;
               maxCount = dateCounts.get(endDate);
           }
       }
       
       return commonDate;
    }
        else 
        {
            return defaultDate;
        }
    }
    
    /**
     * @description  This method retrieves the existing Products; need to add filter on the query
     *
     * @author Lawrence Coffin <lawrence.coffin@cloudsherpas.com>
     * @since   1.Apr.2014
     */
    public void getExistingAssetsAndQPs()
    {
        System.debug('>>>>> In Existing asset method');
        qpwList = new List<QuoteProductWrapper>();
        assetBundles = new Map<String,BundleWrapper>();
        
        //
        // Query existing Assets related to the Account
        //
        String accountId = opportunity.AccountId;
        String assetQuery = 'Select Id ';
        
        for (String q : VCG_CPQ_PricingUtility.describeObjectFields('Asset__c').keySet())
        {
            if (!q.equalsIgnoreCase('Id')) assetQuery += ','+q;
        }
        assetQuery += ' FROM Asset__c ';
        assetQuery += ' WHERE Account__c = :accountId ';
        assetQuery += '       AND Maintenance_Status__c IN :onMaintenanceStatuses ';
        assetQuery += '       AND Product__r.IsActive = TRUE';
       //  ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,assetQuery));   
        
        List<Asset__c> assetList = new List<Asset__c>();
        for(Asset__c a : Database.query(assetQuery))
        { assetList.add(a);}
        
        
        existingAssetList = assetList;
        
        Map<Id,Asset__c> assetMapById;
        
        if (assetList.size() > 0)
        {
            assetMapById = new Map<Id,Asset__c>(assetList);
            
            // Create instances of the QuoteProductWrapper class to be displayed on the page for existing assets
            for (Asset__c a : assetList)
            {
                a.Product__r = getProduct(a.Product__c);
                
                if(a.Product_Group__c != null)
                    quote.Groups_Active__c = true;
                else
                   a.Product_Group__c = '';
                
                if (a.Bundle_Product__c != null)
                {
                    // This is an asset for a component of a SKU'd bundle, we need to recombine these
                    // back into the bundle product.
                    if (qpwMap.containsKey(getQPWMapKey(a.Bundle_Product__c, a.Product_Group__c)))
                    {
                        // Existing asset for bundle product, add this's asset's values to the bundle asset's values
                        Asset__c bundleAsset = qpwMap.get(getQPWMapKey(a.Bundle_Product__c, a.Product_Group__c)).assetRec;
                        
                        bundleAsset.ARR__c += a.ARR__c;
                        // Don't add LMQ ... all components should have the same LMQ, which is the LMQ for the bundle itself
                    }
                    else
                    {
                        // Otherwise create a new record for the bundle asset with no Id
                        // Clone the component product's asset record so we have all the same term start/end and other fields
                        // just swap around the Product__c.
                        Asset__c bundleAsset = a.clone();
                        bundleAsset.Product__c = bundleAsset.Bundle_Product__c;
                        
                        QuoteProductWrapper qpw = new QuoteProductWrapper(quote, getProduct(bundleAsset.Product__c), null, bundleAsset);
                        qpw.quoteProdRec.Asset__c = a.Id; // we will need this for pricing
                        qpw.quoteProdRec.Asset__r = a;
                        qpw.isNew = false;
                        qpw.isRenewal = false;
                        qpw.isDecommission = false;
                        qpw.isExtension = false;
                        qpw.isExisting = true;
                        qpw.termEndTooltip = 'Double-click if you want to extend the term end date for this product/asset.';
                        
                        qpwMap.put(getQPWMapKey(bundleAsset.Product__c, bundleAsset.Product_Group__c), qpw);
                    }
                }
                else
                {
                    if (isActiveProduct(a.Product__c))
                    {
                        //if (a.Bundle_Name__c == null)
                        //{
                            QuoteProductWrapper qpw = new QuoteProductWrapper(quote, getProduct(a.Product__c), null, a);
                            qpw.isNew = false;
                            qpw.isRenewal = false;
                            qpw.isDecommission = false;
                            qpw.isExtension = false;
                            qpw.isExisting = true;
                            qpw.termEndTooltip = 'Double-click if you want to extend the term end date for this product/asset.';
                            qpw.quoteProdRec.Asset__r = a;
                            if (a.Product__c != null)
                            {
                               qpwMap.put(getQPWMapKey(a.Product__c, a.Product_Group__c), qpw);
                            }
                           
                        /*}
                        else
                        {
                            if (assetBundles.containsKey(a.Bundle_Name__c))
                            {
                                BundleWrapper bwrap = assetBundles.get(a.Bundle_Name__c);
                                bwrap.bundledAssets.add(a);
                            }
                            else
                            {
                                BundleWrapper bwrap = new BundleWrapper(a.Bundle_Name__c);
                                bwrap.bundledAssets.add(a);
                                bwrap.existingQuantity = a.Quantity__c;
                                bwrap.termEnd = new VCG_UI__c(aDate__c = a.Asset_Term_End_Date__c); 
                                bwrap.termStart = new VCG_UI__c(aDate__c = a.Asset_Term_Start_Date__c);
                                bwrap.isExisting = true;
                                assetBundles.put(a.Bundle_Name__c, bwrap);
                                
                            }
                        }*/
                    }
                }
            }
        }
        
        //
        // Query related Quote Product records for existing quotes
        //
        if (quote.Id != null) 
        {
            // Retrieve the Fields from the Layout as well as the Mapping
            set<string> quoteFieldSet = new set<string>();
            // Query Quote Record
            string quoteProductQuery = 'Select Id ';
            
            for (String q : VCG_CPQ_PricingUtility.describeObjectFields('VCG_CPQ_Quote_Product__c').keySet())
            {
                if (!q.equalsIgnoreCase('Id')) quoteProductQuery += ','+q;
            }
            quoteProductQuery += ' From VCG_CPQ_Quote_Product__c where Quote__c = \''+quote.Id+'\'';
                
            
            List<VCG_CPQ_Quote_Product__c> qpList = Database.query(quoteProductQuery);
            
        // If there are Quote Product records
            if (qpList.size() > 0)
            {
                //
                // First, store QPs by id so we can link up __r (primarily add on) relationships down below
                //
                Map<Id,VCG_CPQ_Quote_Product__c> qpMapById = new Map<Id,VCG_CPQ_Quote_Product__c>( qpList );
                
                //
                // Go through and link up the records
                //
                for (VCG_CPQ_Quote_Product__c qpRec : qpList)
                {
                    qpRec.Quote__r = this.quote;
                    qpRec.Product__r = GetProduct(qpRec.Product__c);
                    
                    if (qpRec.Product_Group__c == null) qpRec.Product_Group__c = '';
                    else quote.Groups_Active__c = true;
                    
                    if (qpRec.From_Product__c != null)
                    {
                        qpRec.From_Product__r = GetProduct(qpRec.From_Product__c);
                    }
                    
                    if (qpRec.Add_On_Source_Quote_Product__c != null)
                    {
                        if (!qpMapById.containsKey(qpRec.Add_On_Source_Quote_Product__c))
                        {
                            System.debug(LoggingLevel.ERROR, '====> qpMapByIds.keySet(): ' + qpMapById.keySet());
                            throw new VCG_CPQ_Formula.Formula_Exception('Core product not found for Add-On Quote Product line "' + qpRec.Product__r.Name + '" - no record loaded for: ' + qpRec.Add_On_Source_Quote_Product__c);
                        }
                        
                        qpRec.Add_On_Source_Quote_Product__r = qpMapById.get(qpRec.Add_On_Source_Quote_Product__c);
                    }
                    
                    if (qpRec.Asset__c != null)
                    {
                        if (!assetMapById.containsKey(qpRec.Asset__c))
                        {
                            throw new VCG_CPQ_Formula.Formula_Exception('Asset not found for Quote Product line "' + qpRec.Product__r.Name + '" - need Asset record Id: ' + qpRec.Asset__c);
                        }
                        
                        qpRec.Asset__r = assetMapById.get(qpRec.Asset__c);
                    }
                
                    if (qpRec.Add_On_To_Asset__c != null)
                    {
                        if (!assetMapById.containsKey(qpRec.Add_On_To_Asset__c))
                        {
                            throw new VCG_CPQ_Formula.Formula_Exception('Core Asset not found for Add-On Quote Product line "' + qpRec.Product__r.Name + '" - need Asset record Id: ' + qpRec.Add_On_To_Asset__c);
                        }
                        
                        qpRec.Add_On_To_Asset__r = assetMapById.get(qpRec.Add_On_To_Asset__c);
                    }
                
                    if (qpRec.From_Asset__c != null)
                    {
                        if (!assetMapById.containsKey(qpRec.From_Asset__c))
                        {
                            throw new VCG_CPQ_Formula.Formula_Exception('From Asset not found for Quote Product line "' + qpRec.Product__r.Name + '" - need Asset record Id: ' + qpRec.From_Asset__c);
                        }
                        
                        qpRec.From_Asset__r = assetMapById.get(qpRec.From_Asset__c);
                    }
                }
                
                //
                // Create instances of the QuoteProductWrapper class to be displayed on the page for existing assets
                //
                for (VCG_CPQ_Quote_Product__c qp : qpList)
                {
//                    System.debug(LoggingLevel.ERROR, '====> Got QP Rec: ' + qp);
//                    System.debug(LoggingLevel.ERROR, '====> Product: ' + qp.Product__r.Name);
//                    System.debug(LoggingLevel.ERROR, '====> SKU: ' + qp.Product__r.ProductCode);
                    System.debug(LoggingLevel.ERROR, '====> Line_Type: ' + qp.Line_Type__c);                    
                    System.debug(LoggingLevel.ERROR, '====> Is Maintenance: ' + qp.Product__r.Is_Maintenance__c);
                    
                    // If the qpwMap contains the product, there is an existing asset
                    String qpwMapKey = getQPWMapKey(qp, qp.Product_Group__c);
                    
                    System.debug(LoggingLevel.ERROR, '::====> qpwMapKey: ' + qpwMapKey);
                    
                    if (qpwMap.containsKey(qpwMapKey))
                    {
                        // NOTE: This branch is not just for products with an existing asset. It is also
                        // for any products with multiple QP records. Primarily this would be Renewal + Extension
                        // or Renewal + Decommission, but it can also be New Perpetual + New Maintenance
//                      System.debug('====> Got QP for existing QPW for product: ' + getProduct(qp.Product__c).Name);
                        
                        // Retrieve wrapper instance
                        QuoteProductWrapper qpw = qpwMap.get(qpwMapKey);
                        
                        System.debug(LoggingLevel.ERROR, '====> found existing qpwMap record: ' + qpw);
                    
                        // Link to asset, regardless of whether we are querying it above ... to make sure we get the full Asset record
//                        qp.Asset__r = qpw.assetRec;
                        
                        if (qp.Product__r.Is_Maintenance__c)
                        {
                            System.debug(LoggingLevel.ERROR, '====> Exist QPW:Maintenance');
                            if (qp.Line_Type__c == 'New')
                            {
                                System.debug(LoggingLevel.ERROR, '====> Exist QPW:Maintenance:New');
                                qpw.isNew = true;
                                qpw.mainMaintQPRec = qp;
                            }
                            else if (qp.Line_Type__c == 'Extension')
                            {
                                System.debug(LoggingLevel.ERROR, '====> Exist QPW:Maintenance:Ext');
                                qpw.isExtension = true;
                                qpw.mainMaintQPRec = qp;
                            }
                            else if (qp.Line_Type__c == 'Decommission')
                            {
                                System.debug(LoggingLevel.ERROR, '====> Exist QPW:Maintenance:Decom');
                                qpw.isDecommission = true;
                                qpw.mainMaintQPRec = qp;
                            }
                            else if (qp.Line_Type__c == 'Renewal')
                            {
                                System.debug(LoggingLevel.ERROR, '====> Exist QPW:Maintenance:Renewal');
                                qpw.isRenewal = true;
                                qpw.renewMaintQPRec = qp;
                                /** @todo  How to handle international dates? */
                                qpw.termEndTooltip = 'The original term for this product is from '+ qpw.assetRec.Asset_Term_Start_Date__c.month() +'/'+qpw.assetRec.Asset_Term_Start_Date__c.day()+'/'+qpw.assetRec.Asset_Term_Start_Date__c.year()+ ' to ' + qpw.assetRec.Asset_Term_End_Date__c.month() +'/'+qpw.assetRec.Asset_Term_End_Date__c.day()+'/'+qpw.assetRec.Asset_Term_End_Date__c.year()+'. Double click if you want to change the term end date.';
                            }
                        }
                        else
                        {
                            System.debug(LoggingLevel.ERROR, '====> Exist QPW:Non-Maint');
                            if (qp.Line_Type__c == 'New')
                            {
                                System.debug(LoggingLevel.ERROR, '====> Exist QPW:Non-Maint:New');
                                qpw.isNew = true;
                                qpw.quoteProdRec = qp;
                            }
                            else if (qp.Line_Type__c == 'Extension')
                            {
                                System.debug(LoggingLevel.ERROR, '====> Exist QPW:Non-Maint:Ext');
                                qpw.isExtension = true;
                                qpw.quoteProdRec = qp;
                            }
                            else if (qp.Line_Type__c == 'Decommission')
                            {
                                System.debug(LoggingLevel.ERROR, '====> Exist QPW:Non-Maint:Decom');
                                qpw.isDecommission = true;
                                qpw.quoteProdRec = qp;
                            }
                            else if (qp.Line_Type__c == 'Other')
                            {
                                System.debug(LoggingLevel.ERROR, '====> Exist QPW:Non-Maint:Other');
                                qpw.isOther = true;
                                qpw.quoteProdRec = qp;
                            }
                            else if (qp.Line_Type__c == 'Renewal')
                            {
                                System.debug(LoggingLevel.ERROR, '====> Exist QPW:Non-Maint:Renewal');
                                qpw.isRenewal = true;
                                qpw.renewalQuoteProdRec = qp;
                                /** @todo  How to handle international dates? */
                                qpw.termEndTooltip = 'The original term for this product is from '+ qpw.assetRec.Asset_Term_Start_Date__c.month() +'/'+qpw.assetRec.Asset_Term_Start_Date__c.day()+'/'+qpw.assetRec.Asset_Term_Start_Date__c.year()+ ' to ' + qpw.assetRec.Asset_Term_End_Date__c.month() +'/'+qpw.assetRec.Asset_Term_End_Date__c.day()+'/'+qpw.assetRec.Asset_Term_End_Date__c.year()+'. Double click if you want to change the term end date.';
                            }
                        }
                        
                        if (qp.Product__c != null)
                            qpwMap.put(qpwMapKey, qpw);
                    }
                    else
                    {
                        System.debug(LoggingLevel.ERROR, '====> No QPW');
//                        System.debug('====> Got QP for new product: ' + getProduct(qp.Product__c).Name);
                        
                        // No existing QPW record (so not an existing Asset), create a new QPW record here
                        
                        
                        QuoteProductWrapper qpw;
                        
                        if (qp.Product__r.Is_Maintenance__c)
                        {
                            System.debug(LoggingLevel.ERROR, '====> No QPW:Maintenance');
                            
                            // For maintenance the QPW record is under the *parent's* product
                            qpw = new QuoteProductWrapper(quote, getProduct(qp.Add_On_Source_Quote_Product__r.Product__c), null, null);
                            
                            qpw.mainMaintQPRec = qp;
                            
                            if (qp.Line_Type__c == 'New')
                            {
                                System.debug(LoggingLevel.ERROR, '====> No QPW:Maintenance:New');
                                qpw.isNew = true;
                            }
                            else
                            {
                                throw new VCG_CPQ_Formula.Formula_Exception('Found ' + qp.Line_Type__c + ' Maintenance Quote Product line without an existing Asset! ');
                            }
                        }
                        else
                        {
                            System.debug(LoggingLevel.ERROR, '====> No QPW:Non-Maint');
                            
                            qpw = new QuoteProductWrapper(quote, getProduct(qp.Product__c), qp, null);
                            
                            if (qp.Line_Type__c == 'New')
                            {
                                System.debug(LoggingLevel.ERROR, '====> No QPW:Non-Maint:New');
                                qpw.isNew = true;
                                qpw.quoteProdRec = qp;
                            }
                            else
                            {
                                throw new VCG_CPQ_Formula.Formula_Exception('Found ' + qp.Line_Type__c + ' Quote Product line without an existing Asset!');
                            }
//                            /** @todo  Can we ever have extension or decom QPs without an Asset? I.e. for extension/decom we will always have an existing qpw record */
//                            else if (qp.Line_Type__c == 'Extension')
//                            {
//                                qpw.isExtension = true;
//                                qpw.quoteProdRec = qp;
//                            }
//                            else if (qp.Line_Type__c == 'Decommission')
//                            {
//                                qpw.isDecommission = true;
//                                qpw.quoteProdRec = qp;
//                            }
                        }
                        
                        if (qp.Product__c != null)
                            qpwMap.put(qpwMapKey, qpw);    
                    }
                }
            }
        }
        
        System.debug(':::::qpwMap:::::' + qpwMap );
    }
        
    /**
     * @description  Flags any existing assets that have equivalencies (for Migrations & Upgrades)
     *
     * @author  Lawrence Coffin <lawrence.coffin@cloudsherpas.com>
     * @since   29.Apr.2014
     */
    public void FlagEquivalencies(Map<string,QuoteProductWrapper> qpwMap)
    {
        Map<Id,QuoteProductWrapper> assetQPWs = new Map<Id,QuoteProductWrapper>();
        
        for (QuoteProductWrapper qpw : qpwMap.values())
        {
            if (qpw.isExisting) {
                assetQPWs.put(qpw.productRec.Id, qpw);
            }
        }
        
        if (assetQPWs.size() > 0)
        {
            List<VCG_CPQ_Product_Equivalency__c> equivs = [SELECT Legacy_Product__c,
                                                                  Equivalent_Product__c,
                                                                  Equivalent_Product__r.Name,
                                                                  Is_Many_to_One__c
                                                           FROM VCG_CPQ_Product_Equivalency__c
                                                           WHERE Legacy_Product__c IN :assetQPWs.keySet()];
            
            Map<Id,VCG_CPQ_Product_Equivalency__c> manyToOnes = new Map<Id,VCG_CPQ_Product_Equivalency__c>();
            
            for (VCG_CPQ_Product_Equivalency__c equiv : equivs)
            {
                if (equiv.Is_Many_to_One__c)
                {
                    manyToOnes.put(equiv.Equivalent_Product__c, equiv);
                }
                else
                {
                    QuoteProductWrapper legacyQPW = assetQPWs.get(equiv.Legacy_Product__c);
                    
                    if (!isActiveProduct(equiv.Equivalent_Product__c))
                    {
                        throw new VCG_CPQ_Formula.Formula_Exception('Legacy product Equivalency - "' + legacyQPW.productRec.Name + ' -> ' + equiv.Equivalent_Product__r.Name + ' - maps to a non-active product');
                    }
                    
                    if (legacyQPW.equivalentProds == null)
                    {
                        legacyQPW.equivalentProds = new List<Product2>();
                    }
                    
                    legacyQPW.hasEquivalency = true;
                    legacyQPW.equivalentProds.add(getProduct(equiv.Equivalent_Product__c));
                }
            }
            
            if (manyToOnes.size() > 0)
            {
                /** @todo  Remove this exception and finish up the many-to-one mapping if this functionality is needed */
                throw new VCG_CPQ_Formula.Formula_Exception('Many-to-One equivalency mapping not currently supported');
                
                //
                // If we have Many-to-One mappings, we only flag Equivalency if we have *all* legacy products
                //
                equivs = [SELECT Legacy_Product__c,
                                 Equivalent_Product__c,
                                 Is_Many_to_One__c
                          FROM VCG_CPQ_Product_Equivalency__c
                          WHERE Equivalent_Product__c IN :manyToOnes.keySet()];
                for (VCG_CPQ_Product_Equivalency__c equiv : equivs)
                {
                    // ... collect many-to-ones here
                }
                
                // check for all legacy products for each of the many-to-ones
                // flag those that have all legacy products in their asset mix
            }
            
            //
            // This block is for debugging only
            //
            /** @todo  Remove this block */
            for (QuoteProductWrapper qpw : qpwMap.values())
            {
                if (qpw.hasEquivalency)
                {
                    String prods = '';
                    
                    for (Product2 prod : qpw.equivalentProds)
                    {
                        prods += prod.Name + ', ';
                    }
                    
                    System.debug('====> Equivalencies for: ' + qpw.productRec.Name + ' => ' + prods);
                }
            }
            // End debug block
        }
    }
    
    
     /**
     * @description  This method really handles arbitrary field updates on the CPQ page -- i.e. a change in a header field
     *               or a change in a quantity on the main page (asset/product list), or a change in a discount on the Quote Details
     *               page. It first applies any changes, then calls the populateListsAndPrice() method to do the actual pricing.
     *
     * @author Lawrence Coffin <lawrence.coffin@cloudsherpas.com>
     * @since   1.Apr.2014
     */
    public void pricing()
    {
            //
        // Go through all QPW records and look for changes that signify a change in QP records... I.e. addition of a new quantity to trigger an Extension,
        // removal of a quantity to delete an Extension, Other + Extension, Extension to Other, etc.
            //
        // Look for any existing assets (QuoteProductWrappers) with a non-typed Quote Product Rec
        // that has a quantity or decommission quantity that is non-zero. If we find one, then
        // it means the user has entered a new quantity/decom quantity and we need to
        // populate the Quote Product record into the extQuoteProductList of decomQuoteProductList.
        //
        // Also, check for records that have both Quantity and Decommission Quantity defined -- don't allow that
        for (QuoteProductWrapper qpw : qpwMap.values())
        {
            // Check for records with both quantity and Decommission quantity - generate an error
            if (qpw.quoteProdRec.License_Metric_Quantity__c != null && qpw.quoteProdRec.License_Metric_Quantity__c != 0
                && qpw.quoteProdRec.Decommission_Quantity__c != null && qpw.quoteProdRec.Decommission_Quantity__c != 0) 
            {
                qpw.quoteProdRec.License_Metric_Quantity__c.addError('Can\'t specify both a quantity and a Decommission quantity for the same product');
                qpw.quoteProdRec.Decommission_Quantity__c.addError('Can\'t specify both a quantity and a Decommission quantity for the same product');
            }
            
            // Look for null type'd or Other type'd QP lines - any quantity changes to these will flip them to Extension or Decommission
            if (qpw.quoteProdRec.Line_Type__c == null || qpw.quoteProdRec.Line_Type__c == 'Other') 
            {
                if (qpw.quoteProdRec.License_Metric_Quantity__c != null && qpw.quoteProdRec.License_Metric_Quantity__c >= 0) 
                {
                    qpw.quoteProdRec.Line_Type__c = 'Extension';
                    qpw.quoteProdRec.Product__c = qpw.productRec.Id;
                    qpw.quoteProdRec.Product__r = qpw.productRec;
                    qpw.quoteProdRec.Quote__c = quote.Id;
                    
                    qpw.quoteProdRec.Quote__r = quote;
                    qpw.quoteProdRec.Asset__c = qpw.assetRec.Id;
                    qpw.quoteProdRec.Asset__r = qpw.assetRec;
                    qpw.quoteProdRec.Asset_Term_Start_Date__c = (quote.Effective_Date__c == null ? Date.today() : quote.Effective_Date__c);
                    System.debug('====> Asset_Term_Start_Date__c - 1: ' + qpw.quoteProdRec.Asset_Term_Start_Date__c);
                    qpw.quoteProdRec.Asset_Term_End_Date__c = qpw.assetRec.Asset_Term_End_Date__c;
                    qpw.isExtension = true;
                    /** @todo  Is this needed? Or will the sorting done in populateListsAndPrice() automatically add this record to this list? (see related @todos below) -LC 2014-11-12 */
                    extQuoteProductList.add(qpw.quoteProdRec);
                    
                    // Add Maintenance if we need to
                    if (qpw.productRec.Is_Perpetual__c)
                    {
                        // We have a perpetual product and need to add First Year Maintenance of the same
                        // quantity.
                        AddMaintenance(qpwMap, qpw.quoteProdRec);
                    }
                    
                    // If we are doing an extension, if we have a renewal active as well, make sure the renewal includes
                    // the extension quanity - Renewal + Extension
                    if (qpw.renewalQuoteProdRec != null)
                    {
                        qpw.renewalQuoteProdRec.License_Metric_Quantity__c = qpw.assetRec.License_Metric_Quantity__c + qpw.quoteProdRec.License_Metric_Quantity__c;
                        qpw.renewalQuoteProdRec.Asset__r = qpw.assetRec;
                    }
                    if (qpw.renewMaintQPRec != null)
                    {
                        qpw.renewMaintQPRec.License_Metric_Quantity__c = qpw.assetRec.License_Metric_Quantity__c + (qpw.mainMaintQPRec == null ? 0 : qpw.mainMaintQPRec.License_Metric_Quantity__c);
                        qpw.renewMaintQPRec.Asset__r = qpw.assetRec;
                    }
                }
                else if (qpw.quoteProdRec.Decommission_Quantity__c != null && qpw.quoteProdRec.Decommission_Quantity__c >= 0) 
                {
                    // We have a QPW record for this product, but we don't have an existing/active QP record,
                    // therefore this must be an existing asset, possibly with a renewal in place.
                    // A value in the Decom Quantity field with no Line_Type means the user just added Decom quantity,
                    // so this is a Decommission (Asset + Decom quantity).
                    
                    // Make sure Decommission quantity is no greater than asset quantity
                    qpw.quoteProdRec.Decommission_Quantity__c = Math.min(qpw.quoteProdRec.Decommission_Quantity__c, qpw.assetRec.License_Metric_Quantity__c);
                    
                    qpw.quoteProdRec.Line_Type__c = 'Decommission';
                    qpw.quoteProdRec.Product__c = qpw.productRec.Id;
                    qpw.quoteProdRec.Product__r = qpw.productRec;
                    qpw.quoteProdRec.Quote__c = quote.Id;
                    qpw.quoteProdRec.Quote__r = quote;
                    qpw.quoteProdRec.Asset__c = qpw.assetRec.Id;
                    qpw.quoteProdRec.Asset__r = qpw.assetRec;
                    qpw.quoteProdRec.Asset_Term_Start_Date__c = (quote.Effective_Date__c == null ? Date.today() : quote.Effective_Date__c);
                    System.debug('====> Asset_Term_Start_Date__c - 2: ' + qpw.quoteProdRec.Asset_Term_Start_Date__c);
                    qpw.quoteProdRec.Asset_Term_End_Date__c = qpw.assetRec.Asset_Term_End_Date__c;
                    qpw.quoteProdRec.Decommission_Type__c = (qpw.quoteProdRec.Decommission_Quantity__c == qpw.assetRec.License_Metric_Quantity__c ? 'Cancellation' : 'Reduction');
                    qpw.isDecommission = true;
                    /** @todo  Is this needed? Or will the sorting done in populateListsAndPrice() automatically add this record to this list? (see related @todos above and below) -LC 2014-11-12 */
                    decomQuoteProductList.add(qpw.quoteProdRec);
                    
                    // Add Maintenance if we need to
                    if (qpw.productRec.Is_Perpetual__c)
                    {
                        // We have a perpetual product and need to add First Year Maintenance of the same
                        // quantity.
                        if (AddMaintenance(qpwMap, qpw.quoteProdRec))
                        {
                            // If we are decommissioning a perpetual product *AND* we have maintenance, we *don't* want to
                            // decom the perpetual product itself, but decom the maintenance instead, so we need to 'undo'
                            // the changes made above to the qpw.quoteProdRec so we end up with a null quoteProdRec
                            qpw.quoteProdRec = new VCG_CPQ_Quote_Product__c();
                            if (UserInfo.isMultiCurrencyOrganization()) qpw.quoteProdRec.put('CurrencyIsoCode', quote.get('CurrencyIsoCode'));
                        }
                        
                        // If we are doing an decommission, if we have a maintenance renewal active as well, make sure the renewal includes
                        // the decommission quanity - Renewal + Decommission
                        if (qpw.renewMaintQPRec != null)
                        {
                            if (qpw.mainMaintQPRec.Decommission_Quantity__c >= qpw.assetRec.License_Metric_Quantity__c)
                            {
                                // Full decom, remove renewal record
                                qpw.mainMaintQPRec = null;
                            }
                            else
                            {
                                // Partial decom + renewal, adjust the renewal quantity
                                qpw.renewMaintQPRec.License_Metric_Quantity__c = qpw.assetRec.License_Metric_Quantity__c - qpw.mainMaintQPRec.Decommission_Quantity__c;
                                qpw.renewMaintQPRec.Asset__r = qpw.assetRec;
                            }
                        }
                    }
                    else
                    {
                        // If we are doing an decommission, if we have a renewal active as well, make sure the renewal includes
                        // the decommission quanity - Renewal + Decommission
                        if (qpw.renewalQuoteProdRec != null)
                        {
                            if (qpw.quoteProdRec.Decommission_Quantity__c >= qpw.assetRec.License_Metric_Quantity__c)
                            {
                                // Full decom, remove renewal record
                                qpw.renewalQuoteProdRec = null;
                            }
                            else
                            {
                                // Partial decom + renewal, adjust the renewal quantity
                                qpw.renewalQuoteProdRec.License_Metric_Quantity__c = qpw.assetRec.License_Metric_Quantity__c - qpw.quoteProdRec.Decommission_Quantity__c;
                                qpw.renewalQuoteProdRec.Asset__r = qpw.assetRec;
                            }
                        }
                    }
                }
                
                if (qpw.isExtension || qpw.isDecommission)
                {
                    // QP record was just switched to Extension or Decommission. Need to handle Other values or the switch from Other to one of these types
                    if (!qpw.isOther)
                    {
                        // Not an 'Other' line type, but might be used for editing Other values, so need to copy over all Other values
                        // from the asset record
                        CopyOtherValues(qpw.assetRec, qpw.quoteProdRec, qpw.productRec.CPQ_Display_Type__c);
                    }
                    else
                    {
                        // if already an 'Other' type, the Other values are already copied over
                        // we just need to un-flag it as an Other record
                        qpw.isOther = false;
                        
                        /** @todo  Do we need to remove from otherQuoteProductList? Or will the sorting done in populateListsAndPrice() automatically remove it from list? (see related @todos above) -LC 2014-11-12 */
                    }
                }
            }
            else 
            {
                // Line Type not null and not Other (meaning it is a existing/active Quote Product and not just a dummy QP record and not an Other record)
                
                //
                // Check to see if the quantities entered make sense for the line type it is (i.e. did the user change it
                // from an Extension to a Decommission? Did they remove the quantity for a New product?)
                //
                if (!qpw.isRenewal) 
                {
                    System.debug('====> Product: ' + qpw.productRec.Name + ' Q: '
                                    + qpw.quoteProdRec.License_Metric_Quantity__c
                                    + ', DQ: ' + qpw.quoteProdRec.Decommission_Quantity__c);
                                    
                    if ((qpw.quoteProdRec.License_Metric_Quantity__c == null || qpw.quoteProdRec.License_Metric_Quantity__c <= 0)
                             && (qpw.quoteProdRec.Decommission_Quantity__c == null || qpw.quoteProdRec.Decommission_Quantity__c <= 0)) 
                    {
                        // Quantities changed to zero, need to remove the product from the quote
                        if (qpw.isNew) 
                        {
                            // Delete Quote Product Wrapper record altogether
                            // first, remove the add-on wrappers
                            /** @todo  Can we rename this to 'removeAddOnChildren()' or something similar? To indicate that we are removing this product's children? */
                            removeAddOnWrappers(qpw);
                            //qpwMap.get(getQPWMapKey(qpw.productRec.Id, qpw.quoteProdRec.Product_Group__c)) );
                            //System.Debug('[>]'+qpwMap);
                            
                            // then remove the parent wrapper
                            if (qpw.quoteProdRec.Id != null)
                            {
                                quoteProductsToDelete.add(new VCG_CPQ_Quote_Product__c( Id = qpw.quoteProdRec.Id ));
                            }
                            
                            qpwMap.remove(getQPWMapKey(qpw.productRec.Id,qpw.quoteProdRec.Product_Group__c));
                            
                            // Delete product from newQuoteProductList
                            for (Integer i = 0; i < newQuoteProductList.size(); i++)
                            {
                                if (newQuoteProductList[i].Product__c == qpw.productRec.Id)
                                {
                                    newQuoteProductList.remove(i);
                                    continue;
                                }
                            }
                        }
                        else 
                        {
                            // isExisting
                            
                            // Don't Delete Quote Product Wrapper, just switch it back to list the existing asset
                            // and remove Quote Product line type and remove from appropriate xxxQuoteProductList
                            
                            if (qpw.isExtension) 
                            {
                                System.debug('====> Checking for old Extension record for Quote Product');
                                
                                /** @todo  See if the Other values have been changed and convert the Extension to Other rather than deleting the extension */
                                
                                // Delete product from extQuoteProductList
                                for (Integer i = 0; i < extQuoteProductList.size(); i++) 
                                {
                                    if (extQuoteProductList[i].Product__c == qpw.productRec.Id) 
                                    {
                                        System.debug('====> Removing old Extension record from index: ' + i);
                                        extQuoteProductList.remove(i);
                                        
                                        continue;
                                    }
                                }
                            }
                            else if (qpw.isDecommission) 
                                                        {
                                // Delete product from decomQuoteProductList
                                
                                /** @todo  See if the Other values have been changed and convert the Decommission to Other rather than deleting the decommission */
                                
                                for (Integer i = 0; i < decomQuoteProductList.size(); i++) 
                                {
                                    if (decomQuoteProductList[i].Product__c == qpw.productRec.Id) 
                                    {
                                        decomQuoteProductList.remove(i);
                                        continue;
                                    }
                                }
                            }
                            
                            // Reset qpw type and amount
                            qpw.isExtension = false;
                            qpw.isDecommission = false;
                            
                            if (OtherValuesDiffer(qpw.quoteProdRec, qpw.assetRec, qpw.productRec.CPQ_Display_Type__c))
                            {
                                qpw.quoteProdRec.Line_Type__c = 'Other';
                                qpw.isOther = true;
                            }
                            else
                            {
                                // Wipe out old quoteProdRec with any calculated values (resets Line_Type, etc.)
                                qpw.quoteProdRec = new VCG_CPQ_Quote_Product__c();
                                if (UserInfo.isMultiCurrencyOrganization()) qpw.quoteProdRec.put('CurrencyIsoCode', quote.get('CurrencyIsoCode'));
                            }
                            
                            // Recalculate line Totals
                            qpw.salesPriceTotal.aCurr2__c = qpw.getSalesPriceTotal();
                            qpw.arrTotal.aCurr2__c = qpw.getARRTotal();
                            qpw.lineTotal.aCurr2__c = qpw.getLineTotal();
                            
                            // We know we aren't doing a renewal here (checked above) so no need to update
                            // a renewal quantity (Renewal + Extension and Renewal + Decommission)
                        }
                    }
                }
                /** @todo  HIGH PRIORITY  I think we are missing some key functionality here... At this point we have
                                          an QPW with an existing/active QP record *and* it has a renewal... But we aren't
                                          checking to see if the quantity on the QP record has been changed. If it is,
                                          we may need to delete the QP record if the quantity or decom quantity have gone
                                          to zero. And for any quantity/decom quantity change we need to update the 
                                          renewal quantity as well. Renewal + Extension; Renewal + Decommission */
            }            
        }
        
        //
        //process existing bundles
        //
        
        for (BundleWrapper bundle : assetBundles.values()) 
        {
            //purge the existing quoteProducts so they can be rebuilt
            bundle.bundledQuoteProds = new list<VCG_CPQ_Quote_Product__c>();
            
            //error when both decom and order quantities are set
            if (bundle.decomQuantity != null && bundle.decomQuantity > 0
                && bundle.orderedQuantity != null && bundle.orderedQuantity > 0 )
            {
                //qpw.quoteProdRec.License_Metric_Quantity__c.addError('Can\'t specify both a quantity and a Decommission quantity for the same product');
                //qpw.quoteProdRec.Decommission_Quantity__c.addError('Can\'t specify both a quantity and a Decommission quantity for the same product');
                //may need to replace the variable with a field reference so we can dd an error to it.
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Decomission Quantity: Can\'t specify both a quantity and a Decommission quantity for the same bundle.'));
        
                return;
            }
            
            //skip quote product creation if quantities have not been set
            if (!(bundle.decomQuantity != null && bundle.decomQuantity > 0
                 || bundle.orderedQuantity != null && bundle.orderedQuantity > 0 ))
            {
                continue;
            }
            
            //populate quote products from the asset data
            for (Asset__c a : bundle.bundledAssets)
            {
                VCG_CPQ_Quote_Product__c qp = new VCG_CPQ_Quote_Product__c(Product__c = a.Product__c
                                                                         , Bundle_Name__c = a.Bundle_Name__c
                                                                         , Line_Type__c = 'New'
                                                                         , License_Metric_Quantity__c = 0
                                                                         , Decommission_Quantity__c = 0
                                                                         , Asset_Term_Start_Date__c = bundle.termStart.aDate__c
                                                                         , Asset_Term_End_Date__c = bundle.termEnd.aDate__c
                                                                         , Asset__c = a.Id
                                                                         , Asset__r = a
                                                                         , Quote__c = quote.Id
                                                                         , Quote__r = quote);
                if (UserInfo.isMultiCurrencyOrganization()) qp.put('CurrencyIsoCode', quote.get('CurrencyIsoCode'));
                bundle.bundledQuoteProds.add(qp);
            }
            
            //if the quantity changes
            if ( bundle.orderedQuantity != null && bundle.orderedQuantity > 0 )
            {
                bundle.isExtension = true;
                bundle.isDecommission = false;
                
                // Increase Quote Product quantities as well
                for (VCG_CPQ_Quote_Product__c quoteProd : bundle.bundledQuoteProds) //add these if they are not already there
                {
                    quoteProd.License_Metric_Quantity__c += bundle.orderedQuantity;
                    quoteProd.Product__r = getProduct(quoteProd.Product__c);
                    quoteProd.Line_Type__c = 'Extension';
                }
                
            }
            if (bundle.decomQuantity != null && bundle.decomQuantity > 0)
            {
                bundle.isExtension = false;
                bundle.isDecommission = true;
                
                // Set up the quote product decommission attributes
                for (VCG_CPQ_Quote_Product__c quoteProd : bundle.bundledQuoteProds) 
                {
                    quoteProd.Decommission_Quantity__c += bundle.decomQuantity;
                    quoteProd.Line_Type__c = 'Decommission';
                    quoteProd.Decommission_Quantity__c = bundle.decomQuantity;
                    quoteProd.Decommission_Type__c = (quoteProd.Decommission_Quantity__c == bundle.existingQuantity ? 'Cancellation' : 'Reduction');
                    
                }
            }
                
        }
        
        // Re-populate lists on page
        /** @todo   Prevent duplicate pointers across product and bundled product. Likely need to exclude the bundle products from the qpwMap object. */
        populateListsAndPrice();
    }
    
    /**
     * @description  This method adds the Products to memory when the 'Add' button is clicked 
     *
     * @author Lawrence Coffin <lawrence.coffin@cloudsherpas.com>
     * @since   1.Apr.2014
     */ 
    public boolean fromCoreProductSelection{get;set;}
     
    public void migrateProductWeb()         
    {       
        migrateProduct();       
    }       
    public VCG_CPQ_Quote_Product__c migrateProduct()        
    {
        System.debug('====> Got migrate for product: ' + migrateProdId);
        System.debug('====> qpwMap: ' + qpwMap);
        
        // Get legacy product
        QuoteProductWrapper legacyQPW = qpwMap.get(getQPWMapKey(migrateProdId, activeGroup));
        
        //
        // Flag as "migrated"
        //
        legacyQPW.isMigrated = true;
        
        //
        // Generate migration quote product lines and QuoteProductWrappers
        //
        /** @todo  Nathan, why is this outside the loop? If we have multiple products in equivalentProds, the second, third and other loops will overwrite the first newQP record so each QPW will end up pointing to the same record, won't it? Or does the new QPW() call clone the original QP record now? */
        VCG_CPQ_Quote_Product__c newQP = new VCG_CPQ_Quote_Product__c();
        for (Product2 prod : legacyQPW.equivalentProds)
        {
            if (UserInfo.isMultiCurrencyOrganization()) newQP.put('CurrencyIsoCode', quote.get('CurrencyIsoCode'));
            newQP.Product__c = prod.Id;
            newQP.Product__r = prod;
            newQP.Line_Type__c = 'Migration';
            newQP.License_Metric_Quantity__c = legacyQPW.assetRec.License_Metric_Quantity__c;
            newQP.Asset_Term_Start_Date__c = (quote.Effective_Date__c == null ? Date.today() : quote.Effective_Date__c);
            System.debug('====> Asset_Term_Start_Date__c - 3: ' + newQP.Asset_Term_Start_Date__c);
            newQP.Asset_Term_End_Date__c = legacyQPW.assetRec.Asset_Term_End_Date__c;
            
            newQP.Quote__c = quote.Id;
            newQP.Quote__r = quote;
            
            newQP.From_Product__c = legacyQPW.productRec.Id;
            newQP.From_Product__r = legacyQPW.productRec;
            newQP.From_Asset__c = legacyQPW.assetRec.Id;
            newQP.From_Asset__r = legacyQPW.assetRec;
            newQP.Product_Group__c = activeGroup; 
            // Note, assetRec is null here because that is for the asset for the product we are converting to... which doesn't exist yet
            QuoteProductWrapper newQPW = new QuoteProductWrapper(quote, prod, newQP, null);
            newQPW.isMigration = true;
            
            qpwMap.put(getQPWMapKey(prod.Id, activeGroup), newQPW);
        }
        
        //
        // Reprice & Re-populate lists on page
        //
        populateListsAndPrice();
        
        return newQP;
    }
    
    /**
     * @description  Removes the add-on products associated with a parent product
     *
     * @author Nathan Shinn
     * @since   24.Apr.2014
     */
    public void removeAddOnWrappers(QuoteProductWrapper parentWrapper) //QuoteProductWrapper parentWrapper
    {
        // iterate over all of the current wrappers       
        for (QuoteProductWrapper qpw : qpwMap.values())
        {
            // if this is a child of the parent wrapper passed in, remove it
            /** @todo  Is there an easier way to say "is this an add on child of the given quote product"? 
                I.e. just check Add_on_Source_Quote_Product__c/__r? Are we sure that addOnResultRec is always populated? How about on save & re-edit of a quote? */
            if ((qpw.isAddOn && qpw.addOnResultRec != null && qpw.addOnResultRec.addOnTo.Product__c == parentWrapper.quoteProdRec.Product__c)
              || (qpw.quoteProdRec.Add_on_Source_Quote_Product__c == parentWrapper.quoteProdRec.Id && parentWrapper.quoteProdRec.Id != null))
            {
                if (qpw.quoteProdRec.Id != null)
                {
                    quoteProductsToDelete.add(new VCG_CPQ_Quote_Product__c( Id = qpw.quoteProdRec.Id ));
                }
                            
                qpwMap.remove(getQPWMapKey(qpw.productRec.Id, qpw.quoteProdRec.Product_Group__c));
            }
        }
    }
    
    /**
     * @description  Extra class used to store the relationship between an add-on record
     *               and the record it is an add-on to during the save process. Throughout
     *               the rest of the CPQ tool, we keep track of the relationship using the
     *               standard Add_on_Source_..__r relationship field, but if we try to
     *               insert/update/upsert the child record with that relationship populated
     *               Salesforce gets upset. So we copy the relationship out to this class
     *               while we save to the database, then we go back through these relationship
     *               records and use these to populate the Add_on_Source_..__c fields once
     *               we have an Id defined.
     *
     * @author  Lawrence Coffin <lawrence.coffin@cloudsherpas.com>
     * @since   23.Apr.2014
     */
    public class AddOnRelationship
    {
        VCG_CPQ_Quote_Product__c quoteProdRec;
        VCG_CPQ_Quote_Product__c addOnSourceQuoteProd;
        Asset__c addOnSourceAsset;
        
        public AddOnRelationship(VCG_CPQ_Quote_Product__c qpr, VCG_CPQ_Quote_Product__c source)
        {
                this.quoteProdRec = qpr;
                this.addOnSourceQuoteProd = source;
            }            
        
        public AddOnRelationship(VCG_CPQ_Quote_Product__c qpr, Asset__c source)
        {
            this.quoteProdRec = qpr;
            this.addOnSourceAsset = source;
        }
    }
    /**
     * @description  Error message will pop up if a non designated user tries to edit an approved Quote
     * @author  Abhishek Dey
     * @since   16.Jul.2015
     */
    public String verifyApprovedQuote()
    {
        Boolean userFound = false;
        Boolean userFound_PendingApproval = false;
        String ReturnData = 'NonNullValue';
        list<Group> lstQueue = new list<Group>();
        Map<String,CPQ_Allowed_Profiles__c>  mapAllowedProfile = CPQ_Allowed_Profiles__c.getAll();
                
                for(Id loggedInId : mapAllowedProfile.keyset())
                {
                   if(userinfo.getProfileId() == loggedInId)
                    {
                         userFound = true;
                         system.debug('matching profile found');
                         break;
                    }
                    
                }
                
              lstQueue = [Select Id from Group where type='Queue' and DeveloperName ='CPQ_ProServ' limit 1];  
                          
              for(GroupMember lstQueueMember : [Select UserOrGroupId From GroupMember where GroupId =:lstQueue[0].id limit 50000])
              {
                    if(lstQueueMember.UserOrGroupId == userinfo.getUserId())
                    {
                        userFound_PendingApproval = true;
                        system.debug('matching CPQPro found');
                        break;
                    }
              }
              
              if((userFound_PendingApproval == false)&&(quote.Approval_Status__c == 'Pending Approval'))
                {
                    ApexPages.getMessages().clear();
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Quote is locked for approval. Click Cancel to return to Opportunity ' ));
                    ReturnData = null;
                }
            
                if((userFound == false)&&(quote.Approval_Status__c == 'Approved'))
                {
                    ApexPages.getMessages().clear();
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Approved Quote Cannot be edited. Click Cancel to return to Opportunity ' ));
                    ReturnData = null;
                }
                
                return ReturnData;
    
    }
    
    
    
    
    /**
     * @description  Saves the quote and quote products
     *
     * @author Lawrence Coffin <lawrence.coffin@cloudsherpas.com>
     * @since   1.Apr.2014
     */
    public PageReference save()
    {
        Map<id,id> Product2toQProdtIDMap = new Map<Id,Id>();
        Map<string,List<VCG_CPQ_Quote_Product_Pricing_Result__c>> ModifiedPricingResultsMap = New Map<string,List<VCG_CPQ_Quote_Product_Pricing_Result__c>>();
        Map<string,List<VCG_CPQ_Quote_Product_Pricing_Result__c>> NewPricingResultsMap = new Map<string,List<VCG_CPQ_Quote_Product_Pricing_Result__c>>();
        List<VCG_CPQ_Quote_Product_Pricing_Result__c> QP_PricingResultsList = new List<VCG_CPQ_Quote_Product_Pricing_Result__c>();
        List<VCG_CPQ_Quote_Product_Pricing_Result__c> upsertPricingResult = new List<VCG_CPQ_Quote_Product_Pricing_Result__c>();
        Map<String,ID> ProductNameToIDMap = new Map<String,ID>();
        
        Set<ID> Product2IDLst = new Set<ID>();
        Set<VCG_CPQ_Quote_Product__c> upsertQPRecs = new Set<VCG_CPQ_Quote_Product__c>();
        List<AddOnRelationship> upsertedAddOns = new List<AddOnRelationship>();
        
        String returnVal = verifyApprovedQuote();
        if (returnVal == null)
        {
        return null;
        }
        
        //
        // for cloning functionality
        QuoteProductWrapper cloneQuoteProductWrapper; 
        QuoteProductWrapper clonedRenewalQuoteProd;
        BundleWrapper clonedConfigBundle;
        BundleWrapper clonedAssetBundle;
        Boolean saveCopy = ( ApexPages.currentPage().getParameters().get('clone') == null ? false : true );
        VCG_CPQ_Quote__c clonedQuote = new VCG_CPQ_Quote__c();
        //
               
        List<VCG_CPQ_Error> productErrors = validateProductSelection(qpwMap);
        if (productErrors.size() > 0)
        {
            for (VCG_CPQ_Error e : productErrors)
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,e.errorType+': ['+e.errorMessage+']'));
            }
            return null;
        }
        
        //
        // Set a savepoint so we can roll back to this on error
        //
        Savepoint sp = Database.setSavepoint();
        
        // First, clear the 'Check_Approvals__c' flag -- needs to be FALSE to start, until we have saved
        // all QP records (needed for calculating approvals). We set this to true down below after all other
        // records have been saved.
        quote.Check_Approvals__c = false;
        
        Id savedQuoteId;
        
        try
        {
            if (saveCopy)
            {
                clonedQuote = quote.clone(false,true,false,false);
                
                // Reset Approval fields for cloned quote
                clonedQuote.Status__c = 'Pending';
                clonedQuote.Approval_Status__c = 'NA';
                clonedQuote.Evaluated_Status__c = 'Pre Evaluation';
                clonedQuote.Ready_For_Approval__c = false;
                clonedQuote.Ran_Approvals__c = false;
                clonedQuote.Last_Approved_By__c = null;
                
                // Link cloned quote to original quote
                clonedQuote.Cloned_From__c = quote.Id;
                
                //System.debug(LoggingLevel.ERROR, 'clonedQuote : ' + clonedQuote);
                
                insert clonedQuote;
                
                savedQuoteId = clonedQuote.Id;
            }
            else
            {
                upsert quote;
                
                savedQuoteId = quote.Id;
            }
        }
        catch (Exception e)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Error Saving Quote: ' + e.getMessage() + ' [line: ' + e.getLineNumber() + ']'));
            Database.rollback(sp);
            return null;
        }
        
        //
        // Loop through product wrappers to get Quote Products to save
        //
        /** @todo  Why don't we just loop through allQuoteProductList ?? Do as part of code cleanup. */
        for (QuoteProductWrapper qpw : qpwList)
        {   
            // If there is an existing quote record
            if (qpw.quoteProdRec != null && qpw.quoteProdRec.Line_Type__c != null)
            {
                if (saveCopy)
                {
                    
                    VCG_CPQ_Quote_Product__c clonedQuoteProdRec = qpw.quoteProdRec.clone(false,true,false,false);
                    clonedQuoteProdRec.Quote__c = savedQuoteId;
                    if(clonedQuoteProdRec.Name == null)
                    { 
                        clonedQuoteProdRec.Name = qpw.productRec.ProductCode;
                    }
                    upsertQPRecs.add(clonedQuoteProdRec);
                    /** @todo  What is this doing? How is this helping us when saving a copy? */
/*
                    cloneQuoteProductWrapper = new QuoteProductWrapper(clonedQuote, qpw.productRec, qpw.quoteProdRec, qpw.assetRec);
                    cloneQuoteProductWrapper = qpw;
                    cloneQuoteProductWrapper.quoteProdRec.id = null;
                    cloneQuoteProductWrapper.quoteProdRec.Quote__c = clonedQuote.Id;
                    if (cloneQuoteProductWrapper.quoteProdRec.Name == null)
                    { 
                        cloneQuoteProductWrapper.quoteProdRec.Name = qpw.productRec.ProductCode;
                    }
                
                    // Assign Quote Record to Quote Product
                    // if (qpw.quoteProdRec.Quote__c == null && quote.Id != null)
                    // {
                    //    qpw.quoteProdRec.Quote__c = clonedQuote.Id; 
                    // }
                    
                    upsertQPRecs.add(cloneQuoteProductWrapper.quoteProdRec);
*/
                }
                else
                {
                    if (qpw.quoteProdRec.Name == null)
                    {
                        qpw.quoteProdRec.Name = qpw.productRec.ProductCode;
                    }
                    
                    // Assign Quote Record to Quote Product
                    if (qpw.quoteProdRec.Quote__c == null && quote.Id != null)
                    {
                        qpw.quoteProdRec.Quote__c = quote.Id;
                    }
                    upsertQPRecs.add(qpw.quoteProdRec);
                    
                }
            }
            
            
            // If there is an main maintenance quote record
            if (qpw.mainMaintQPRec != null)
            {
                VCG_CPQ_Quote_Product__c qpRec = qpw.mainMaintQPRec;
                
                String recName = ( qpRec.Product__r != null ? qpRec.Product__r.ProductCode : GetProduct(qpRec.Product__c).ProductCode )
                                 + ' - ' + qpRec.Line_Type__c;
                
                if (saveCopy)
                {
                    cloneQuoteProductWrapper = new QuoteProductWrapper(clonedQuote, qpw.productRec, qpRec, qpw.assetRec);
                    cloneQuoteProductWrapper = qpw;
                    cloneQuoteProductWrapper.quoteProdRec.id = null;
                    cloneQuoteProductWrapper.quoteProdRec.Quote__c = clonedQuote.Id;
                    if (cloneQuoteProductWrapper.quoteProdRec.Name == null)
                    { 
                        cloneQuoteProductWrapper.quoteProdRec.Name = recName;
                    }
                
                    // Assign Quote Record to Quote Product
                    // if (qpRec.Quote__c == null && quote.Id != null)
                    // {
                    //    qpRec.Quote__c = clonedQuote.Id; 
                    // }
                    
                    upsertQPRecs.add(cloneQuoteProductWrapper.quoteProdRec);
                }
                else
                {
                    if (qpRec.Name == null)
                    {
                        qpRec.Name = recName;
                    }
                    
                    // Assign Quote Record to Quote Product
                    if (qpRec.Quote__c == null && quote.Id != null)
                    {
                        qpRec.Quote__c = quote.Id;
                    }
                    upsertQPRecs.add(qpRec);
                    
                }
            }
            
            
            // If there is a Renewal Record
            if (qpw.renewalQuoteProdRec != null)
            {
                if (saveCopy)
                {
                    clonedRenewalQuoteProd = new QuoteProductWrapper(clonedQuote, qpw.productRec, qpw.quoteProdRec, qpw.assetRec);
                    clonedRenewalQuoteProd = qpw;
                    clonedRenewalQuoteProd.renewalQuoteProdRec.id = null;
                    clonedRenewalQuoteProd.renewalQuoteProdRec.Quote__c = clonedQuote.Id;
                    if (clonedRenewalQuoteProd.renewalQuoteProdRec.Name == null)
                    {
                       clonedRenewalQuoteProd.renewalQuoteProdRec.Name = qpw.productRec.ProductCode;
                    } 
                    
                    clonedRenewalQuoteProd.renewalQuoteProdRec.Line_Type__c = 'Renewal';
                    
                    upsertQPRecs.add(clonedRenewalQuoteProd.renewalQuoteProdRec);
                }
                else
                {
                    if (qpw.renewalQuoteProdRec.Name == null)
                    {
                        qpw.renewalQuoteProdRec.Name = qpw.productRec.ProductCode;
                    }
                    
                    // Assign Quote Id
                    if (qpw.renewalQuoteProdRec.Quote__c == null && quote.Id != null)
                    {
                        qpw.renewalQuoteProdRec.Quote__c = quote.Id;   
                    }
                    qpw.renewalQuoteProdRec.Line_Type__c = 'Renewal';
                    
                    upsertQPRecs.add(qpw.renewalQuoteProdRec);
                }
            }
            
            
            // If there is an main maintenance quote record
            if (qpw.renewMaintQPRec != null)
            {
                VCG_CPQ_Quote_Product__c qpRec = qpw.renewMaintQPRec;
                
                String recName = ( qpRec.Product__r != null ? qpRec.Product__r.ProductCode : GetProduct(qpRec.Product__c).ProductCode )
                                 + ' - ' + qpRec.Line_Type__c;
                
                if (saveCopy)
                {
                    cloneQuoteProductWrapper = new QuoteProductWrapper(clonedQuote, qpw.productRec, qpRec, qpw.assetRec);
                    cloneQuoteProductWrapper = qpw;
                    cloneQuoteProductWrapper.quoteProdRec.id = null;
                    cloneQuoteProductWrapper.quoteProdRec.Quote__c = clonedQuote.Id;
                    if (cloneQuoteProductWrapper.quoteProdRec.Name == null)
                    { 
                        cloneQuoteProductWrapper.quoteProdRec.Name = recName;
                    }
                
                    // Assign Quote Record to Quote Product
                    // if (qpRec.Quote__c == null && quote.Id != null)
                    // {
                    //    qpRec.Quote__c = clonedQuote.Id; 
                    // }
                    
                    upsertQPRecs.add(cloneQuoteProductWrapper.quoteProdRec);
                }
                else
                {
                    if (qpRec.Name == null)
                    {
                        qpRec.Name = recName;
                    }
                    
                    // Assign Quote Record to Quote Product
                    if (qpRec.Quote__c == null && quote.Id != null)
                    {
                        qpRec.Quote__c = quote.Id;
                    }
                    upsertQPRecs.add(qpRec);
                    
                }
            }
        }
        
        
        //
        // If the record is an addOn we need to remove the Add_on_Source_Quote_Product__r
        // relationship otherwise it causes an error during upsert.
        // However, if Add_on_Source_Quote_Product__c is not set, then we need to
        // remember the relationship and set Add_on_Source_Quote_Product__c after the parent
        // record has been added.
        //
        for (VCG_CPQ_Quote_Product__c quoteProd : upsertQPRecs) 
        {   
            Product2IDLst.add(quoteProd.product__c);
            
            if (quoteProd.Add_on_Source_Quote_Product__r != null) 
            {
                // Copy the reference if we need to set the Add_on_Source_Quote_Product__c value below
/** @todo  May need to uncomment this code down the line if we switch back to upsert rather than delete and insert of existing quote product records */
//                if (quoteProd.Add_on_Source_Quote_Product__c == null) 
//                {
                    upsertedAddOns.add(new AddOnRelationship(quoteProd, quoteProd.Add_on_Source_Quote_Product__r));
//                }
                
                // Clear the reference
                quoteProd.Add_on_Source_Quote_Product__r = null;
            }
            if(quoteProd.Asset__r != null)
            {
                if(quoteProd.Asset__c == null && quoteProd.Asset__r.Id != null)
                {
                    /** @todo  Do we really need the +'' at the end? Is that just forcing to a string? Shouldn't an Id be ok here? */
                    quoteProd.Asset__c = quoteProd.Asset__r.Id+'';
                }
                    
                quoteProd.Asset__r = null;
            }
            // Clear the id as well (in case this is an existing record that was edited .. since we are deleting and resaving the parent record, we need to clear and reset the id as well)
            quoteProd.Add_on_Source_Quote_Product__c = null;
            
            //if(quoteProd.Id != null)
            //    quoteProductsToDelete.add(new VCG_CPQ_Quote_Product__c(Id=quoteProd.Id));
            // clear the ID for insert
            //quoteProd.Id = null;
        }
        
        
        
         
        // Upsert the Quote Product Records
        List<VCG_CPQ_Quote_Product__c> insertQPRecs = new List<VCG_CPQ_Quote_Product__c>();
        try
        {
            System.debug('::::::::upsertQPRecs::::::' + upsertQPRecs);
            insertQPRecs.addAll(upsertQPRecs);
            if (upsertQPRecs.size() > 0) 
            {
                // Note: Doing an insert here, rather than an upsert, gets around SF wanting to link to records that are referenced in the __r field. 
                //SF will get upset if it finds more fields in that referenced object than just an external id
                upsert insertQPRecs;
            }
            System.Debug('Quote Product:::'+upsertQPRecs);
            
            
            // NS: Build the add-on association to Quote Products and Assets
            // iterate back over the quote product wrappers and retrieve the add-on's
            List<VCG_CPQ_Quote_Product__c> addOnUpdateList = new List<VCG_CPQ_Quote_Product__c>();
            
            for (AddOnRelationship addOnRel : upsertedAddOns)
            {
                // Create a simple record for updating the Add_on_Source field
                addOnUpdateList.add(new VCG_CPQ_Quote_Product__c(
                                                                    Id = addOnRel.quoteProdRec.Id,
                                                                    Add_on_Source_Quote_Product__c =  addOnRel.addOnSourceQuoteProd.Id
                                                                 ));
            }
            
            if (addOnUpdateList.size() > 0)
            {
                update addOnUpdateList;
            }
            
            // delete the quote Products that were removed by the user
            if (quoteProductsToDelete.size() > 0)
            {
                delete quoteProductsToDelete;
            }
            
        }
        catch(Exception e)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Error Saving Quote: ' + e.getMessage() + ' [line: ' + e.getLineNumber() + ']'));
            
            // Rollback the database
            Database.rollback(sp);
            
            return null;
        }
        
        //
        // Save Overrides
        //
        try
        {
            if (pricingOverrideMap.values().size() > 0)
            {
                for (Integer i = 0; i < pricingOverrideMap.values().size(); i++)
                {
                    pricingOverrideMap.values()[i].Quote__c = quote.Id;
                    /** @todo  Are we losing a reference here? Both of these are being set to null... */
                    //pricingOverrideMap.values()[i].Pricing_Result__c = null;
                    pricingOverrideMap.values()[i].Pricing_Result__r = null;    
                }
                upsert pricingOverrideMap.values();
            }
        }
        catch(Exception e)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Error saving Pricing Overrides: ' + e.getMessage() + ' [line: ' + e.getLineNumber() + ']'));
            
            // Rollback the database
            Database.rollback(sp);
            
            return null;
        }
        
        //
        // Save Pricing Results
        //
        try
        {
/* Disabling this... not sure why we are doing this like we are... may be a holdover. Should be able to just
   loop through the pricing results records and set Quote_Product__c
            Map<String,VCG_CPQ_Quote_Product__c> nameQuoteProdMap = new  map<String,VCG_CPQ_Quote_Product__c>();
            
            for (VCG_CPQ_Quote_Product__c quoteProd1: upsertQPRecs)
            {
                nameQuoteProdMap.put(VCG_CPQ_PricingUtility.getPricingResultsKey(quoteProd1), quoteProd1); // quoteProd1.Product_Group__c + '-' + quoteProd1.Line_Type__c + '-' + quoteProd1.Product__r.Name
            }
            System.debug('=====> nameQuoteProdMap keys: ' + nameQuoteProdMap.keySet());
            
            if (nameQuoteProdMap.size() > 0 && pricingResultsMap.size() > 0)
            {
                for (String pricingKey : pricingResultsMap.keyset())
                {
                    System.debug('====> Pricing key: ' + pricingKey);
                    if (nameQuoteProdMap.containskey(pricingKey))
                    {
                        for (Integer i=0;i< pricingResultsMap.get(pricingKey).size();i++)
                        {
                            pricingResultsMap.get(pricingKey)[i].Quote_Product__c = nameQuoteProdMap.get(pricingKey).Id;
                            pricingResultsMap.get(pricingKey)[i].Quote_Product__r = null;
                            System.debug('====> Set pricingResult.Quote_Product__c to: ' + pricingResultsMap.get(pricingKey)[i].Quote_Product__c);
                        }
                    }
                }
            }
*/
            for (List<VCG_CPQ_Quote_Product_Pricing_Result__c> pricingResultList : pricingResultsMap.values())
            {
                for (VCG_CPQ_Quote_Product_Pricing_Result__c pricingResult : pricingResultList)
                {
                    if (pricingResult.Quote_Product__c == null)
                        pricingResult.Quote_Product__c = pricingResult.Quote_Product__r.Id;
                    pricingResult.Quote_Product__r = null;
                    System.debug('====> Set pricingResult.Quote_Product__c to: ' + pricingResult.Quote_Product__c);
                }
            }
            
            if (pricingOverrideMap.size()>0 && pricingOverrideMap != null)
            {
                for (String overrideKey : pricingOverrideMap.keyset())
                {
                    String pricingResultsKey = VCG_CPQ_PricingUtility.OverrideKeyToPricingResultsKey(overrideKey); // pricingKeyList[0] + '-' + pricingKeyList[1] + '-' + pricingKeyList[2];
                    Id ppSequenceId = VCG_CPQ_PricingUtility.getPricingProcedureSequenceIdFromOverrideKey(overrideKey);
                    
                    if (pricingResultsMap.containsKey(pricingResultsKey))
                    {
                        for (Integer i = 0; i < pricingResultsMap.get(pricingResultsKey).size(); i++)
                        {
                            if (pricingResultsMap.get(pricingResultsKey)[i].Pricing_Procedure_Sequence__c == ppSequenceId)
                            {
                                pricingResultsMap.get(pricingResultsKey)[i].Pricing_Override__c = pricingOverrideMap.get(overrideKey).Id;
                                pricingResultsMap.get(pricingResultsKey)[i].Pricing_Override__r = null;
                            }
                        }
                    }
                }
            }
            
            List<VCG_CPQ_Quote_Product_Pricing_Result__c> pricingResultsList = getPricingResultsList(pricingResultsMap);
            if (pricingResultsList != null && !pricingResultsList.isEmpty())
            {
                for (VCG_CPQ_Quote_Product_Pricing_Result__c pRes : pricingResultsList)
                {
                    if (pRes.Quote_Product__r != null && pRes.Quote_Product__c == null)
                    {
                        System.debug('====> QP id not set for QP: ' 
                                            + String.valueOf(pRes.Quote_Product__r.Id) 
                                            + ' - Prod: ' 
                                            + ( pRes.Quote_Product__r.Product__r == null ? String.valueOf(pRes.Quote_Product__r.Product__c) : pRes.Quote_Product__r.Product__r.Name ) );
                    }
                    pRes.Quote_Product__r = null;
                    pRes.Pricing_Override__r = null;
                    pRes.Pricing_Procedure_Sequence__r = null;
                }
                
                System.debug('pricingResultsList: ' + pricingResultsList);
                upsert pricingResultsList;
            }
        }
        catch(Exception e)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Error saving Pricing Results: ' + e.getMessage() + ' [line: ' + e.getLineNumber() + ']'));
            
            // Rollback the database
            Database.rollback(sp);
            
            return null;
        }
    
        //
        // Done saving quote and all related records. Mark Quote as ready to check approvals
        //
        update new VCG_CPQ_Quote__c( Id = savedQuoteId, Check_Approvals__c = true);
        
        //
        // Sync the Opportunity and line items
        //
        try
        {
            VCG_CPQ_PricingUtility.syncPrimaryQuote(quote); 
        }
        catch(Exception e)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Error syncing quote to Opportunity: ' + e.getMessage() + ' [line: ' + e.getLineNumber() + ']'));
            
            // Rollback the database
            Database.rollback(sp);
            
            return null;
        }
        
        //
        // On valid save, go to VCG_CPQ_Options.On_Save_Redirect_To__c (if set) or to the saved Quote
        //
        if (VCG_CPQ_Options__c.getInstance() != null && VCG_CPQ_Options__c.getInstance().On_Save_Redirect_To__c != null)
        {
            return  new PageReference(VCG_CPQ_Options__c.getInstance().On_Save_Redirect_To__c.replace('{!Quote.Id}', savedQuoteId));
        }
        else
        {
            return new PageReference('/' + savedQuoteId);
        }
    }
     
    /**
     * @description  Wrapper class for VCG_CPQ_ProductUtility.validateProductSelection that takes a qpwMap
     *               (original or copy as needed) and pulls together a list of quoteProducts and Assets
     *               that represent the future state of the account once the quote is saved & applied
     *
     * @author Lawrence Coffin <lawrence.coffin@cloudsherpas.com>
     * @since  21.Jul.2014
     */
    public List<VCG_CPQ_Error> validateProductSelection(Map<String,QuoteProductWrapper> qpwMap) 
    {
        List<VCG_CPQ_Quote_Product__c> localAllQuoteProductList = new List<VCG_CPQ_Quote_Product__c>();
        List<Asset__c> localAssetList = new List<Asset__c>();
        
        for (QuoteProductWrapper qpw : qpwMap.values())
        {
            if (qpw.isExisting)
            {
                // Existing QPW records can be one of the following:
                //   - The original unchanged Asset
                //   - The asset with an extension/decommission
                //   - A renewal
                //   - An extended/decomissioned asset with renewal
                if ((qpw.quoteProdRec == null || qpw.quoteProdRec.Line_Type__c == null)
                      && (qpw.renewalQuoteProdRec == null || qpw.renewalQuoteProdRec.Line_Type__c == null))
                {
                    localAssetList.add(qpw.assetRec);
                }
                else
                {
                    // We have an extension and/or renewal, so we want to clone the asset
                    // and merge in the changes so the validation code has a single, consistent
                    // view of the asset's future state
                    Asset__c assetCopy = qpw.assetRec.clone();
                    
                    // Apply extension/decommission QP record
                    if (qpw.quoteProdRec != null && qpw.quoteProdRec.Line_Type__c != null)
                    {
                        // only change should be to LMQ... extension/decommission should have the same term end dates...
                        if (qpw.quoteProdRec.Line_Type__c == 'Decommission')
                        {
                            if (qpw.quoteProdRec.Decommission_Quantity__c == assetCopy.License_Metric_Quantity__c)
                            {
                                // We are decommissioning the whole asset, so skip saving the assetCopy,
                                // so it won't exist going forward
                                continue;
                            }
                            else
                            {
                                assetCopy.License_Metric_Quantity__c -= qpw.quoteProdRec.Decommission_Quantity__c;
                            }
                        }
                        else if (qpw.quoteProdRec.Line_Type__c == 'Extension')
                        {
                            //  for test result RES-1309:  fixed a null exception that was occuring when creating new quote and adding value of 10 for the first contract asset - joseph hutchins
                            if (assetCopy.License_Metric_Quantity__c == null)
                            {
                                assetCopy.License_Metric_Quantity__c = 0;
                            }
                            assetCopy.License_Metric_Quantity__c += 
                                qpw.quoteProdRec.License_Metric_Quantity__c == null ? 0 : qpw.quoteProdRec.License_Metric_Quantity__c;
                        }
                        else if (qpw.quoteProdRec.Line_Type__c == 'Other')
                        {
                            // Don't need to do anything for 'Other' because it doesn't change the quantity or
                            // term start/end dates for the asset (which is all we are validating)
                        }
                        else
                        {
                            throw new VCG_CPQ_Formula.Formula_Exception('Unknown line type "' + qpw.quoteProdRec.Line_Type__c + '"');
                        }
                    }
                    
                    // Apply any renewal QP record
                    if (qpw.renewalQuoteProdRec != null || qpw.renewalQuoteProdRec.Line_Type__c != null)
                    {
                        // Term End date should be changed for renewal
                        assetCopy.Asset_Term_End_Date__c = qpw.renewalQuoteProdRec.Asset_Term_End_Date__c;
                        
                        // LMQ *may* be changed without having an extension/decommission record (we think) ...
                        assetCopy.License_Metric_Quantity__c = qpw.renewalQuoteProdRec.License_Metric_Quantity__c;
                    }
                    
                    localAssetList.add(assetCopy);
                }
            }
            else if (qpw.quoteProdRec != null && qpw.quoteProdRec.Line_Type__c != null)
            {
                localAllQuoteProductList.add(qpw.quoteProdRec);
            }
        }
        
        return VCG_CPQ_ProductUtility.validateProductSelection(quote, localAllQuoteProductList, localAssetList);
    }
    
    /**
     * @description  Dynamic Page Components
     *
     * @author Lawrence Coffin <lawrence.coffin@cloudsherpas.com>
     * @since   1.Apr.2014
     */
    public Component.Apex.PageBlockSection getHeaderDetail() 
    {
        Component.Apex.PageBlockSection sectionHeader = new Component.Apex.PageBlockSection();
        sectionHeader.Id = 'headerDetail';
        sectionHeader.expressions.rendered = '{!showDetails}';
        sectionHeader.columns = 3;
        
        for (VCG_CPQ_Page_Layout__c fieldDef : [SELECT Display_Type__c,
                                                       Page_Section__c,
                                                       Field__c,
                                                       Required__c
                                                FROM VCG_CPQ_Page_Layout__c
                                                WHERE Page_Section__c = 'Header Detail'
                                                ORDER BY Order__c])
        {
            if (fieldDef.Field__c != null
                && fieldDef.Field__c.equalsIgnoreCase('CurrencyIsoCode')
                && !UserInfo.isMultiCurrencyOrganization())
        {
                continue;
            }
            
            try
            {
                if ( fieldDef.Display_Type__c == 'Input')
                {
                    Component.Apex.InputField inputField = new Component.Apex.InputField();
                    if (fieldDef.Required__c) inputField.required = true;
                    inputField.expressions.value = '{!quote.'+fieldDef.Field__c+'}';
                    Component.Apex.actionSupport actnSuport = new Component.Apex.ActionSupport(event='onchange');
                    actnSuport.expressions.action='{!pricing}';
                    actnSuport.expressions.rerender='{!$Component.quoteConfigPanel}';
                    actnSuport.status='waitForLoad';//mainBlock
                    inputField.childComponents.add(actnSuport);
                    //inputField.id = 'quote.'+fieldDef.Field__c;
                    sectionHeader.childComponents.add(inputField);
                }
                else if ( fieldDef.Display_Type__c == 'Output')
                {
                    Component.Apex.outputField outputField = new Component.Apex.outputField();
                    outputField.expressions.value = '{!quote.'+fieldDef.Field__c+'}';
                    //outputField.id = 'quote.'+fieldDef.Field__c;
                    sectionHeader.childComponents.add(outputField);
                }
                else if ( fieldDef.Display_Type__c == 'Spacer')
                {
                    Component.Apex.pageBlockSectionItem outputField = new Component.Apex.pageBlockSectionItem();
                    //outputField.expressions.value = ' ';
                    //outputField.id = 'quote.'+fieldDef.Field__c;
                    sectionHeader.childComponents.add(outputField);
                }
            }
            catch(Exception e)
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Page Layout Misconfiguration for field "' + fieldDef.Field__c + '": ' + e.getMessage() + ' [line: ' + e.getLineNumber() + ']'));
            }
        }
        
        return sectionHeader;
        
    }
    
     /**
     * @description  Dynamic Page Components
     *
     * @author  Nathan Shinn <nshinn@cloudsherpas.com>
     * @since   1.Apr.2014
     */
    public Component.Apex.PageBlockSection getHeaderSummary() 
    {
        
        Component.Apex.PageBlockSection sectionHeader = new Component.Apex.PageBlockSection();
        sectionHeader.Id = 'headerSummary';
        sectionHeader.columns = 3;
        
        for (VCG_CPQ_Page_Layout__c fieldDef : [SELECT Display_Type__c, Page_Section__c, Field__c, Required__c
                                                FROM VCG_CPQ_Page_Layout__c
                                                WHERE Page_Section__c = 'Header Summary'
                                                ORDER BY Order__c])
        {
            if (fieldDef.Field__c != null
                && fieldDef.Field__c.equalsIgnoreCase('CurrencyIsoCode')
                && !UserInfo.isMultiCurrencyOrganization())
        {
                continue;
            }
                
            try
            {
                if ( fieldDef.Display_Type__c == 'Input')
                {
                    Component.Apex.InputField inputField = new Component.Apex.InputField();
                    if (fieldDef.Required__c) inputField.required = true;
                    inputField.expressions.value = '{!quote.'+fieldDef.Field__c+'}';
                    Component.Apex.actionSupport actnSuport = new Component.Apex.ActionSupport(event='onchange');
                    actnSuport.expressions.action='{!pricing}';
                    actnSuport.expressions.rerender='{!$Component.quoteConfigPanel}';
                    actnSuport.status='waitForLoad';//mainBlock
                    inputField.childComponents.add(actnSuport);
                    //<apex:actionSupport event="onchange" action="{!getRecAddOns}" rerender="recommendationPanel" />
                    //inputField.id = 'quote.'+fieldDef.Field__c;
                    sectionHeader.childComponents.add(inputField);
                }
                else if ( fieldDef.Display_Type__c == 'Output')
                {
                    Component.Apex.outputField outputField = new Component.Apex.outputField();
                    outputField.expressions.value = '{!quote.'+fieldDef.Field__c+'}';
                    //outputField.id = 'quote.'+fieldDef.Field__c;
                    sectionHeader.childComponents.add(outputField);
                }
                else if ( fieldDef.Display_Type__c == 'Spacer')
                {
                    Component.Apex.pageBlockSectionItem outputField = new Component.Apex.pageBlockSectionItem();
                    //outputField.expressions.value = ' ';
                    //outputField.id = 'quote.'+fieldDef.Field__c;
                    sectionHeader.childComponents.add(outputField);
                }
            }
            catch(Exception e)
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Page Layout Misconfiguration for field "' + fieldDef.Field__c + '": ' + e.getMessage() + ' [line: ' + e.getLineNumber() + ']'));
            }
        }
        
        return sectionHeader;
    }
    
    /**
     * @description  Dynamic Page Components
     *
     * @author Tanvir Ansari <tanvir.ansari@cloudsherpas.com>
     * @since   17.Sep.2014
     */
    public Component.Apex.PageBlockSection getQuoteTotalsHeader() 
    {
        Component.Apex.PageBlockSection quoteHeader = new Component.Apex.PageBlockSection();
        quoteHeader.Id = 'quoteHeaderTotal';
        //sectionHeader.expressions.rendered = '{!allQuoteProductList.size != 0}';  // {!allQuoteProductList.size != 0}
        quoteHeader.columns = 2;       
        
        for (VCG_CPQ_Page_Layout__c fieldDef : [SELECT Display_Type__c,
                                                       Page_Section__c,
                                                       Field__c,
                                                       Required__c
                                                FROM VCG_CPQ_Page_Layout__c
                                                WHERE Page_Section__c = 'Header Totals'
                                                ORDER BY Order__c])
        {
            try
            {
                if ( fieldDef.Display_Type__c == 'Output')
                {
                    Component.Apex.outputField outputField = new Component.Apex.outputField();
                    outputField.expressions.value = '{!quote.'+fieldDef.Field__c+'}';
                    quoteHeader.childComponents.add(outputField);
                }
                else if ( fieldDef.Display_Type__c == 'Spacer')
                {
                    Component.Apex.pageBlockSectionItem outputField = new Component.Apex.pageBlockSectionItem();
                    quoteHeader.childComponents.add(outputField);
                }
            }
            catch(Exception e)
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Page Layout Misconfiguration for field "' + fieldDef.Field__c + '": ' + e.getMessage() + ' [line: ' + e.getLineNumber() + ']'));
            }
        }
        
        return quoteHeader;
        
    }
    
     public Component.Apex.PageBlockSection getQuoteTotalsDetail() 
    {
        Component.Apex.PageBlockSection quoteDetail = new Component.Apex.PageBlockSection();
         quoteDetail.Id = 'quoteDetailTotal';
        //sectionHeader.expressions.rendered = '{!allQuoteProductList.size != 0}';  // {!allQuoteProductList.size != 0}
         quoteDetail.columns = 2;       
        
        for (VCG_CPQ_Page_Layout__c fieldDef : [SELECT Display_Type__c,
                                                       Page_Section__c,
                                                       Field__c,
                                                       Required__c
                                                FROM VCG_CPQ_Page_Layout__c
                                                WHERE Page_Section__c = 'Header Totals'
                                                ORDER BY Order__c])
        {
            try
            {
                if ( fieldDef.Display_Type__c == 'Output')
                {
                    Component.Apex.outputField outputField = new Component.Apex.outputField();
                    outputField.expressions.value = '{!quote.'+fieldDef.Field__c+'}';
                    quoteDetail.childComponents.add(outputField);
                }
                else if ( fieldDef.Display_Type__c == 'Spacer')
                {
                    Component.Apex.pageBlockSectionItem outputField = new Component.Apex.pageBlockSectionItem();
                    quoteDetail.childComponents.add(outputField);
                }
            }
            catch(Exception e)
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Page Layout Misconfiguration for field "' + fieldDef.Field__c + '": ' + e.getMessage() + ' [line: ' + e.getLineNumber() + ']'));
            }
        }
        
        return  quoteDetail;
        
    }
    
    /**
     * @description  Dynamic Page Components/VisualForce for the Quote Details:New section
     *
     * Second try at this, will build our own table, rather than relying on PageBlockTable to get
     * around error message mentioned in _orig() copy of this method below.
     *
     * @author  Lawrence Coffin <lawrence.coffin@cloudsherpas.com>
     * @since   20.Aug.2014
     */
    public Component.Apex.PageBlock getQuoteDetailsNewVF() 
    {
        return getQuoteDetailsSectionVF(newQuoteProductList, 'newQuoteProductList','Quote Details:New');
    }
    
    /**
     * @description Dynamic Page Component/VisualForce for Quote Details:Renewal section
     * @author      Tanvir Ansari <tanvir.ansari@cloudsherpas.com>
     * @since       4.Sep.2014
    */ 
    public Component.Apex.PageBlock getQuoteDetailsRenewalVF() 
    {
        return getQuoteDetailsSectionVF(renewalQuoteProductList, 'renewalQuoteProductList', 'Quote Details:Renewal');
    }
    
    public Component.Apex.PageBlock getQuoteDetailsDecomVF() 
    {
        return getQuoteDetailsSectionVF(decomQuoteProductList, 'decomQuoteProductList', 'Quote Details:Decommission');
    }
    
    public Component.Apex.PageBlock getQuoteDetailsExtVF() 
    {
        return getQuoteDetailsSectionVF(extQuoteProductList, 'extQuoteProductList', 'Quote Details:Extension');
    }
    
    public Component.Apex.PageBlock getQuoteDetailsMigVF() 
    {
        return getQuoteDetailsSectionVF(migrationQuoteProductList, 'migrationQuoteProductList', 'Quote Details:Migration');
    }
    
    public Component.Apex.PageBlock getQuoteDetailsOtherVF() 
    {
        return getQuoteDetailsSectionVF(otherQuoteProductList, 'otherQuoteProductList', 'Quote Details:Other');
    }
    
    /**
     * @description  Generic Dynamic Page Components/VisualForce for the Quote Details sections
     *
     * @author  Lawrence Coffin <lawrence.coffin@cloudsherpas.com>
     * @since   2.Sep.2014
     */
    public Component.Apex.PageBlock getQuoteDetailsSectionVF(List<VCG_CPQ_Quote_Product__c> theQPList, String listName, String qString)
    {
        
        //
        // First, check to see if there are any Quote Products of this type
        //
        if (theQPList == null || theQPList.size() == 0)
        {
            return null;
        }
        
        //
        // Collect up the CPQ_Display_Type__c values -- we want only the columns needed for the types we have
        //
        Set<String> productDisplayTypes = new Set<String>();
        for (VCG_CPQ_Quote_Product__c qp : theQPList)
        {
            productDisplayTypes.add(qp.Product__r.CPQ_Display_Type__c);
        }
        List<String> productDisplayTypesList = new List<String>();
        productDisplayTypesList.addAll(productDisplayTypes);
        String productDisplayTypesStr = String.join(productDisplayTypesList, '\', \'');
        
        System.debug('====> productDisplayTypesStr: ' + productDisplayTypesStr);
        Component.Apex.PageBlock thePageBlock = new Component.Apex.PageBlock();
        if (listName == 'newQuoteProductList')
        {
         thePageBlock.Id = 'quoteDetailsNew';
         thePageBlock.title = 'New';
        }
        else if (listName == 'renewalQuoteProductList')
        {
         thePageBlock.Id = 'quoteDetailsRenewal';
         thePageBlock.title = 'Renewal';
        }
        else if (listName == 'extQuoteProductList')
        {
         thePageBlock.Id = 'quoteDetailsExt';
         thePageBlock.title = 'Extension';
        }
        else if (listName == 'decomQuoteProductList')
        {         
         thePageBlock.Id = 'quoteDetailsDecom';
         thePageBlock.title = 'Decommision';
        }
        else if (listName == 'migrationQuoteProductList')
        {         
         thePageBlock.Id = 'quoteDetailsMig';
         thePageBlock.title = 'Migration';
        }
        else if (listName == 'otherQuoteProductList')
        {         
         thePageBlock.Id = 'quoteDetailsOther';
         thePageBlock.title = 'Other';
        }
        
        //
        // Start our own custom table instead of a PageBlockTable
        //
        thePageBlock.childComponents.add(new Component.Apex.OutputText(escape = false, value = '<div style="overflow-y:auto; overflow-x:auto;">'));
        thePageBlock.childComponents.add(new Component.Apex.OutputText(escape = false, value = '<table class="list" cellspacing="0" cellpadding="0" border="0">'));
        
        // Note: We have to use a soql query string because INCLUDES doesn't support
        // variable interpolation for lists or strings with multiple values in it
        String soql = 'SELECT Field__c, '
                    + '       Display_Type__c, '
                    + '       Alt_Label__c, '
                    + '       Display_For_Product_Type__c, '
                    + '       AND_Display_If__c, '
                    + '       Required__c '
                    + ' FROM VCG_CPQ_Page_Layout__c '
           //         + ' WHERE Page_Section__c = \'Quote Details:New\' '
                    + ' WHERE Page_Section__c = \''+ qString + '\''
                    + '       AND Display_For_Product_Type__c INCLUDES (\'' + String.join(productDisplayTypesList, '\', \'') + '\') '
                    + ' ORDER BY Order__c ';
//                    + ' LIMIT 4';
        System.debug('====> Query: ' + soql);
        
        List<VCG_CPQ_Page_Layout__c> fieldList = Database.query(soql);
        
        if (fieldList == null || fieldList.size() == 0)
        {
            return null;
        }
        
        //
        // Generate the table header row
        //
        thePageBlock.childComponents.add(new Component.Apex.OutputText(escape = false, value = '<thead class="rich-table-thead">'));
        thePageBlock.childComponents.add(new Component.Apex.OutputText(escape = false, value = '<tr class="headerRow">'));
        thePageBlock.childComponents.add(new Component.Apex.OutputText(escape = false, value = '<th></th>')); // blank cell for the pricing override icon column (no header)
        for (VCG_CPQ_Page_Layout__c fieldDef : fieldList)
        {
            if (fieldDef.Field__c != null
                && fieldDef.Field__c.equalsIgnoreCase('CurrencyIsoCode')
                && !UserInfo.isMultiCurrencyOrganization())
            {
                // Skip CurrencyIsoCode if not multi-currency org
                continue;
            }
            
            String label;
            
            if (fieldDef.Alt_Label__c != null)
            {
                label = fieldDef.Alt_Label__c;
            }
            else if (fieldDef.Field__c.endsWith('__d'))
            {
                // Special 'dual' input field. See below where we render the fields.
                label = fieldDef.Field__c.replace('__d', '').replace('_', ' ');
            }
            else
            {
                label = VCG_CPQ_Formula.getFieldLabel('VCG_CPQ_Quote_Product__c', fieldDef.Field__c);
            }
            
            String hideCol = '';
            if (fieldDef.AND_Display_If__c != null && fieldDef.AND_Display_If__c != '')
            {
                // This field *may* not be shown on any of the records, so we set the column to be hidden for now and show it later
                // if the AND_Display_If__c formula evaluates true for any rows
                hideCol = '<style>.col_' + fieldDef.Id + ' { display: none; }</style>';
            }
            
            thePageBlock.childComponents.add(new Component.Apex.OutputText(escape = false, value = '<th class="headerRow col_' + fieldDef.Id + '">' + label + hideCol + '</th>'));
        }
        thePageBlock.childComponents.add(new Component.Apex.OutputText(escape = false, value = '</tr>'));
        thePageBlock.childComponents.add(new Component.Apex.OutputText(escape = false, value = '</thead>'));
        
        String fieldName;
        
        // Use this to track which AND_Display_If__c columns evaluate to true and need to be shown
        Set<Id> showColumns = new Set<Id>();
        
        try
        {
            for (Integer i = 0; i < theQPList.size(); i++) // VCG_CPQ_Quote_Product__c quoteProduct : theQPList)
            {
                VCG_CPQ_Quote_Product__c thisQP = theQPList[i];
                
                thePageBlock.childComponents.add(new Component.Apex.OutputText(escape = false, value = '<tr class="dataRow'
                                                                                                                    + (Math.mod(i, 2) == 1 ? ' odd' : ' even') 
                                                                                                                    + (i == 0 ? ' first' : '')
                                                                                                                    + (i == theQPList.size()-1 ? ' last' : '') 
                                                                                                                    + '">'));
                
                // Insert the Override alert / Remove Override column & icon
                // <apex:column >
                //     <apex:outputPanel rendered="{!new.Override_Count__c != null && new.Override_Count__c > 0}">
                //         <a href="javascript:void(0);" onclick="removeAllOverridesDialog('{!new.Product_Group__c}-{!new.Line_Type__c}-{!new.Product__r.Name}'); return false;">
                //             <apex:image value="{!URLFOR($Resource.VCG_CPQ_Icons,'edo_icons_btns/alert_icon.gif')}" title="One or more pricing values for this product has been overridden"/>
                //         </a>
                //     </apex:outputPanel>
                // </apex:column>
                thePageBlock.childComponents.add(new Component.Apex.OutputText(escape = false, value = '<td>'));
                if (thisQP.Override_Count__c != null && thisQP.Override_Count__c > 0)
                {
                    String pricingResultsKey = VCG_CPQ_PricingUtility.getPricingResultsKey(thisQP);
                    // Note: do our own little JSENCODE() here ...
                    thePageBlock.childComponents.add(new Component.Apex.OutputText(escape = false, value = '<a href="javascript:void(0);" onclick="removeAllOverridesDialog(\'' + pricingResultsKey.replace('\'', '\\\'').replace('"', '\\"') + '\'); return false;">'));
                    
//                    thePageBlock.childComponents.add(new Component.Apex.OutputText(escape = false, value = '<img src="' + URLFOR(Resource.vcg_cpq_alert_icon_gif) + '" title="One or more pricing values for this product has been overridden"/>'));
                    Component.Apex.Image img = new Component.Apex.Image();
                    img.expressions.value = '{!URLFOR($Resource.VCG_CPQ_Icons,\'edo_icons_btns/alert_icon.gif\')}';
                    img.title = 'One or more pricing values for this product has been overridden';
                    thePageBlock.childComponents.add(img);
                    
                    thePageBlock.childComponents.add(new Component.Apex.OutputText(escape = false, value = '</a>'));
                }
                thePageBlock.childComponents.add(new Component.Apex.OutputText(escape = false, value = '</td>'));
                
                
                for (VCG_CPQ_Page_Layout__c fieldDef : fieldList)
                {
                    fieldName = fieldDef.Field__c;
                    
                    if (fieldDef.Field__c != null
                        && fieldDef.Field__c.equalsIgnoreCase('CurrencyIsoCode')
                        && !UserInfo.isMultiCurrencyOrganization())
                    {
                        // Skip CurrencyIsoCode if not multi-currency org
                        continue;
                    }
                    
                    thePageBlock.childComponents.add(new Component.Apex.OutputText(escape = false, value = '<td class="col_' + fieldDef.Id + '">'));
                    
                    if (fieldDef.Display_For_Product_Type__c.contains(thisQP.Product__r.CPQ_Display_Type__c) && DisplayIf(thisQP, fieldDef.AND_Display_If__c))
                    {
                        // First, if AND_Display_If__c is set, record that we have a row that is displaying this field so we can show this column
                        if (fieldDef.AND_Display_If__c != null && fieldDef.AND_Display_If__c != '')
                        {
                           showColumns.add(fieldDef.Id);
                        }
                        
                        // Now, generate the field
                        if ( fieldDef.Field__c.endsWith('__d'))
                        {
                            //
                            // This is a special 'dual' field that allows entry as an amount or a percentage. The
                            // field should be specified using Something__d, and the code expects there to be
                            // three fields called Something_Percentage__c, Something_Amount__c and Something_Entered_As__c.
                            // The ..._Entered_As__c should be a picklist with the values of 'Amount' and 'Percentage'.
                            // In the UI, we will display one of the two fields depending on the value of the Entered_As__c
                            // field. The Entered_As__c field will be displayed in short format with the values of '%' and '$'
                            // (or the symbol appropriate for the Quote's currency)
                            //
                            String fieldBaseName = fieldDef.Field__c.replace('__d', '');
                            thePageBlock.childComponents.add(new Component.Apex.OutputText(escape = false, value = '<nobr>'));
                            
//                            thePageBlock.childComponents.add(new Component.Apex.OutputText(escape = false, value = '<b>Dual: ' + fieldBaseName + '</b>'));
                            
//                                <apex:inputField value="{!new.Uplift_Percentage__c}" style="width: 45px;" rendered="{!new.Uplift_Entered_As__c != 'Amount' && CanEditUpliftPercent}" Id="Uplift_Percentage">
//                                    <apex:actionSupport event="onchange" action="{!pricing}" reRender="quoteDetailsPopUp, quoteConfigPanel"/>
//                                </apex:inputField>
//                                <apex:outputField value="{!new.Uplift_Percentage__c}" rendered="{!new.Uplift_Entered_As__c != 'Amount' && !CanEditUpliftPercent}" Id="Uplift_PercentageLbl"/>
//                                
//                                <apex:inputField value="{!new.Uplift_Amount__c}" style="width: 45px;" rendered="{!new.Uplift_Entered_As__c == 'Amount' && CanEditUpliftPercent}" Id="Uplift_Amount">
//                                    <apex:actionSupport event="onchange" action="{!pricing}" reRender="quoteDetailsPopUp, quoteConfigPanel"/>
//                                </apex:inputField>
//                                <apex:outputField value="{!new.Uplift_Amount__c}" rendered="{! new.Uplift_Entered_As__c == 'Amount' &&!CanEditUpliftPercent}" Id="Uplift_AmountLbl"/>
//                                
//                                <apex:selectList value="{!new.Uplift_Entered_As__c}" multiselect="false" size="1" Id="Uplift_Entered_As" rendered="{!CanEditUpliftPercent}">
//                                    <apex:actionSupport event="onchange" action="{!pricing}" reRender="quoteDetailsPopUp, quoteConfigPanel"/>
//                                    <apex:selectOptions value="{!PercentAmountPicklist}"/>
//                                </apex:selectList>
//                                <apex:outputLabel value="{!new.Uplift_Entered_As__c}" Id="Uplift_Entered_AsLbl" rendered="{!!CanEditUpliftPercent}"/>
                            
                            if (CanEdit(fieldDef.Field__c)) // Check for edit permissions
                            {
                                // Can edit
                                if (thisQP.get(fieldBaseName + '_Entered_As__c') == 'Amount')
                                {
                                    // <apex:inputField value="{!new.Uplift_Amount__c}" style="width: 45px;" rendered="{!new.Uplift_Entered_As__c == 'Amount' && CanEditUpliftPercent}" Id="Uplift_Amount">
                                    //     <apex:actionSupport event="onchange" action="{!pricing}" reRender="quoteDetailsPopUp, quoteConfigPanel"/>
                                    // </apex:inputField>
                                    Component.Apex.InputField inputField = new Component.Apex.InputField();
                                    if (fieldDef.Required__c) inputField.required = true;
                                    inputField.expressions.value = '{!' + listName + '[' + i + '].' + fieldBaseName + '_Amount__c}';
                                    inputField.style = 'width: 45px;';
                                    Component.Apex.actionSupport actnSuport = new Component.Apex.ActionSupport(event='onchange');
                                    actnSuport.expressions.action='{!pricing}';
                                    // actnSuport.expressions.rerender='{!quoteDetailsPopUp}';
                                    actnSuport.expressions.rerender='{!$Component.quoteDetailsPopUp},{!$Component.quoteConfigPanel}';
                                    actnSuport.status='waitForLoad';//mainBlock
                                    inputField.childComponents.add(actnSuport);
                                    
                                    thePageBlock.childComponents.add(inputField);
                                }
                                else
                                {
                                    // <apex:inputField value="{!new.Uplift_Percentage__c}" style="width: 45px;" rendered="{!new.Uplift_Entered_As__c != 'Amount' && CanEditUpliftPercent}" Id="Uplift_Percentage">
                                    //     <apex:actionSupport event="onchange" action="{!pricing}" reRender="quoteDetailsPopUp, quoteConfigPanel"/>
                                    // </apex:inputField>
                                    Component.Apex.InputField inputField = new Component.Apex.InputField();
                                    if (fieldDef.Required__c) inputField.required = true;
                                    inputField.expressions.value = '{!' + listName + '[' + i + '].' + fieldBaseName + '_Percentage__c}';
                                    inputField.style = 'width: 45px;';
                                    Component.Apex.actionSupport actnSuport = new Component.Apex.ActionSupport(event='onchange');
                                    actnSuport.expressions.action='{!pricing}';
                                    // actnSuport.expressions.rerender='{!quoteDetailsPopUp}';
                                    actnSuport.expressions.rerender='{!$Component.quoteDetailsPopUp},{!$Component.quoteConfigPanel}';
                                    actnSuport.status='waitForLoad';//mainBlock
                                    inputField.childComponents.add(actnSuport);
                                    
                                    thePageBlock.childComponents.add(inputField);
                                }
                                
                                // <apex:selectList value="{!new.Uplift_Entered_As__c}" multiselect="false" size="1" Id="Uplift_Entered_As" rendered="{!CanEditUpliftPercent}">
                                //     <apex:actionSupport event="onchange" action="{!pricing}" reRender="quoteDetailsPopUp, quoteConfigPanel"/>
                                //     <apex:selectOptions value="{!PercentAmountPicklist}"/>
                                // </apex:selectList>
                                Component.Apex.SelectList selectList = new Component.Apex.SelectList();
                                selectList.expressions.value = '{!' + listName + '[' + i + '].' + fieldBaseName + '_Entered_As__c}';
                                selectList.size = 1;
                                for (SelectOption option : getPercentAmountPicklist())
                                {
                                    selectList.childComponents.add(new Component.Apex.SelectOption( itemValue = option.getValue(), itemLabel = option.getLabel() ));
                                }
                                Component.Apex.actionSupport actnSuport = new Component.Apex.ActionSupport(event='onchange');
                                actnSuport.expressions.action='{!pricing}';
                                // actnSuport.expressions.rerender='{!quoteDetailsPopUp}';
                                actnSuport.expressions.rerender='{!$Component.quoteDetailsPopUp},{!$Component.quoteConfigPanel}';
                                actnSuport.status='waitForLoad';//mainBlock
                                selectList.childComponents.add(actnSuport);
                                
                                thePageBlock.childComponents.add(selectList);
                            }
                            else
                            {
                                // No edit
                                if (thisQP.get(fieldBaseName + '_Entered_As__c') == 'Amount')
                                {
                                    // <apex:outputField value="{!new.Uplift_Amount__c}" rendered="{! new.Uplift_Entered_As__c == 'Amount' &&!CanEditUpliftPercent}" Id="Uplift_AmountLbl"/>
                                    Component.Apex.OutputField outputField = new Component.Apex.OutputField();
                                    outputField.expressions.value = '{!' + listName + '[' + i + '].' + fieldBaseName + '_Amount__c}';
                                    
                                    thePageBlock.childComponents.add(outputField);
                                }
                                else
                                {
                                    // <apex:outputField value="{!new.Uplift_Percentage__c}" rendered="{!new.Uplift_Entered_As__c != 'Amount' && !CanEditUpliftPercent}" Id="Uplift_PercentageLbl"/>
                                    Component.Apex.OutputField outputField = new Component.Apex.OutputField();
                                    outputField.expressions.value = '{!' + listName + '[' + i + '].' + fieldBaseName + '_Percentage__c}';
                                    
                                    thePageBlock.childComponents.add(outputField);
                                }
                                
                                // <apex:outputLabel value="{!new.Uplift_Entered_As__c}" Id="Uplift_Entered_AsLbl" rendered="{!!CanEditUpliftPercent}"/>
                                Component.Apex.OutputLabel outputLabel = new Component.Apex.OutputLabel();
                                outputLabel.expressions.value = '{!' + listName + '[' + i + '].' + fieldBaseName + '_Entered_As__c}';
                                
                                thePageBlock.childComponents.add(outputLabel);
                            }
                            
                            thePageBlock.childComponents.add(new Component.Apex.OutputText(escape = false, value = '</nobr>'));
                        } // End of __d field handling
                        else if ( fieldDef.Display_Type__c == 'Input')
                        {
                            // For list of field types, see: http://www.salesforce.com/us/developer/docs/apexcode/Content/apex_enum_Schema_DisplayType.htm
                            String fieldType = VCG_CPQ_Formula.GetFieldType(new VCG_CPQ_Quote_Product__c(), fieldDef.Field__c).name();
//                          System.debug('====> fieldType: ' + fieldType);
                            
                            Component.Apex.InputField inputField = new Component.Apex.InputField();
                            if (fieldDef.Required__c) inputField.required = true;
                            inputField.expressions.value = '{!' + listName + '[' + i + '].' + fieldDef.Field__c + '}';
                            if (    fieldType == 'CURRENCY'
                                 || fieldType == 'DOUBLE'
                                 || fieldType == 'INTEGER'
                                 || fieldType == 'PERCENT'
                                 || fieldType == 'STRING')
                            {
                            inputField.style = 'width: 45px;';
                            }
                            Component.Apex.actionSupport actnSuport = new Component.Apex.ActionSupport(event='onchange');
                            actnSuport.expressions.action='{!pricing}';
                            // actnSuport.expressions.rerender='{!quoteDetailsPopUp}';
                            actnSuport.expressions.rerender='{!$Component.quoteDetailsPopUp},{!$Component.quoteConfigPanel}';
                            actnSuport.status='waitForLoad';//mainBlock
                            inputField.childComponents.add(actnSuport);
                            
                            thePageBlock.childComponents.add(inputField);
                        }
                        else if ( fieldDef.Display_Type__c == 'Output')
                        {
                            Component.Apex.outputField outputField = new Component.Apex.outputField();
                            outputField.expressions.value = '{!' + listName + '[' + i + '].' + fieldDef.Field__c + '}';
                            
                            thePageBlock.childComponents.add(outputField);
                        }
                    }
                    thePageBlock.childComponents.add(new Component.Apex.OutputText(escape = false, value = '</td>'));
                }
                
                thePageBlock.childComponents.add(new Component.Apex.OutputText(escape = false, value = '</tr>'));
            }
        }
        catch(Exception e)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Page Layout Misconfiguration for field "' + fieldName + '": ' + e.getMessage() + ' [line: ' + e.getLineNumber() + ']'));
        }
        
        
        //
        // End our custom table
        //
        thePageBlock.childComponents.add(new Component.Apex.OutputText(escape = false, value = '</table>'));
        
        // Add css to show any AND_Display_If__c columns that evaluated to true for any rows
        if (showColumns.size() > 0)
        {
            String showColCSS = '<style>';
            
            for (Id fieldDefId : new List<Id>( showColumns ))
            {
                showColCSS += '.col_' + fieldDefId + ' { display: table-cell; } ';
            }
            
            showColCSS += '</style>';
            
            thePageBlock.childComponents.add(new Component.Apex.OutputText(escape = false, value = showColCSS));
        }
        thePageBlock.childComponents.add(new Component.Apex.OutputText(escape = false, value = '</div>'));
        
        System.debug('====> thePageBlock: ' + thePageBlock);
        return thePageBlock;
    }
    
     /**
     * @description  Evaluates the "AND Display If" field/formula on Field Layout records
     *
     * @author  Lawrence Coffin <lawrence.coffin@cloudsherpas.com>
     * @since   21.Sep.2015
     */
    public Boolean DisplayIf(VCG_CPQ_Quote_Product__c thisQP, String displayIfFormula)
    {
        if (displayIfFormula == null || displayIfFormula == '')
        {
            return true;
        }
        
//        System.debug(LoggingLevel.ERROR, '====> displayIfFormula: ' + displayIfFormula);
        
        VCG_CPQ_Formula.Result res;
        
        try {
            res =  VCG_CPQ_Formula.evaluate(thisQP, displayIfFormula);
        }
        catch (Exception e)
        {
            System.debug(LoggingLevel.ERROR, '====> formula exception: ' + e);
            
            return false;
        }
        
//        System.debug(LoggingLevel.ERROR, '====> res: ' + res);
        
        if (res.value == 1)
        {
            return true;
        }
        
        return false;
    }
    
     /**
     * @description  
     *
     * @author  Lawrence Coffin <lawrence.coffin@cloudsherpas.com>
     * @since   2.Sep.2014
     */
    public Component.Apex.PageBlock getEditOthersVF()
    {
        if (!isEditOtherValues)
        {
            return null;
        }
        
        //
        // Collect up the CPQ_Display_Type__c values -- we want only the columns needed for the types we have
        //
        String productDisplayType = editQP.Product__r.CPQ_Display_Type__c;
        
        List<VCG_CPQ_Page_Layout__c> fieldList = GetDisplayFields('Edit Other Values');
        
        if (fieldList == null || fieldList.size() == 0)
        {
            return null;
        }
        
        Component.Apex.PageBlock thePageBlock = new Component.Apex.PageBlock();
        
        //
        // Start our own custom table instead of a PageBlockTable
        //
        thePageBlock.childComponents.add(new Component.Apex.OutputText(escape = false, value = '<div style="overflow-y:auto; overflow-x:auto;">'));
        thePageBlock.childComponents.add(new Component.Apex.OutputText(escape = false, value = '<table class="list" cellspacing="0" cellpadding="0" border="0">'));
        
        //
        // Generate the table header row
        //
        thePageBlock.childComponents.add(new Component.Apex.OutputText(escape = false, value = '<thead class="rich-table-thead">'));
        thePageBlock.childComponents.add(new Component.Apex.OutputText(escape = false, value = '<tr class="headerRow">'));
        
        for (VCG_CPQ_Page_Layout__c fieldDef : fieldList)
        {
            if (fieldDef.Field__c != null
                && fieldDef.Field__c.equalsIgnoreCase('CurrencyIsoCode')
                && !UserInfo.isMultiCurrencyOrganization())
            {
                // Skip CurrencyIsoCode if not multi-currency org
                continue;
            }
            
            if (!(fieldDef.Display_For_Product_Type__c.contains(productDisplayType) && DisplayIf(editQP, fieldDef.AND_Display_If__c)))
            {
                // Skip fields not set to display for this product display type
                continue;
            }
            
            String label;
            
            if (fieldDef.Alt_Label__c != null)
            {
                label = fieldDef.Alt_Label__c;
            }
            else if (fieldDef.Field__c.endsWith('__d'))
            {
                // Special 'dual' input field. See below where we render the fields.
                label = fieldDef.Field__c.replace('__d', '').replace('_', ' ');
            }
            else
            {
                label = VCG_CPQ_Formula.getFieldLabel('VCG_CPQ_Quote_Product__c', fieldDef.Field__c);
            }
            
            thePageBlock.childComponents.add(new Component.Apex.OutputText(escape = false, value = '<th class="headerRow">' + label + '</th>'));
        }
        thePageBlock.childComponents.add(new Component.Apex.OutputText(escape = false, value = '</tr>'));
        thePageBlock.childComponents.add(new Component.Apex.OutputText(escape = false, value = '</thead>'));
        
        String fieldName;
        
        try
        {
//            for (Integer i = 0; i < theQPList.size(); i++) // VCG_CPQ_Quote_Product__c quoteProduct : theQPList)
//            {
                VCG_CPQ_Quote_Product__c thisQP = editQP;
                
                thePageBlock.childComponents.add(new Component.Apex.OutputText(escape = false, value = '<tr class="dataRow even first last">'));
                
                for (VCG_CPQ_Page_Layout__c fieldDef : fieldList)
                {
                    fieldName = fieldDef.Field__c;
                    
                    if (fieldDef.Field__c != null
                        && fieldDef.Field__c.equalsIgnoreCase('CurrencyIsoCode')
                        && !UserInfo.isMultiCurrencyOrganization())
                    {
                        // Skip CurrencyIsoCode if not multi-currency org
                        continue;
                    }
                    
                    if (!(fieldDef.Display_For_Product_Type__c.contains(productDisplayType) && DisplayIf(thisQP, fieldDef.AND_Display_If__c)))
                    {
                        // Skip fields not set to display for this product display type
                        continue;
                    }
                    
                    System.debug(LoggingLevel.ERROR, '====> Generating VF for field: ' + fieldDef.Field__c);
                    System.debug(LoggingLevel.ERROR, '====> Display Type: ' + fieldDef.Display_Type__c);
                    
                    thePageBlock.childComponents.add(new Component.Apex.OutputText(escape = false, value = '<td>'));
                    
//                    if (fieldDef.Display_For_Product_Type__c.contains(thisQP.Product__r.CPQ_Display_Type__c))
//                    {
                        if ( fieldDef.Field__c.endsWith('__d'))
                        {
                            //
                            // This is a special 'dual' field that allows entry as an amount or a percentage. The
                            // field should be specified using Something__d, and the code expects there to be
                            // three fields called Something_Percentage__c, Something_Amount__c and Something_Entered_As__c.
                            // The ..._Entered_As__c should be a picklist with the values of 'Amount' and 'Percentage'.
                            // In the UI, we will display one of the two fields depending on the value of the Entered_As__c
                            // field. The Entered_As__c field will be displayed in short format with the values of '%' and '$'
                            // (or the symbol appropriate for the Quote's currency)
                            //
                            String fieldBaseName = fieldDef.Field__c.replace('__d', '');
                            thePageBlock.childComponents.add(new Component.Apex.OutputText(escape = false, value = '<nobr>'));
                            
//                            thePageBlock.childComponents.add(new Component.Apex.OutputText(escape = false, value = '<b>Dual: ' + fieldBaseName + '</b>'));
                            
//                                <apex:inputField value="{!new.Uplift_Percentage__c}" style="width: 45px;" rendered="{!new.Uplift_Entered_As__c != 'Amount' && CanEditUpliftPercent}" Id="Uplift_Percentage">
//                                    <apex:actionSupport event="onchange" action="{!pricing}" reRender="quoteDetailsPopUp, quoteConfigPanel"/>
//                                </apex:inputField>
//                                <apex:outputField value="{!new.Uplift_Percentage__c}" rendered="{!new.Uplift_Entered_As__c != 'Amount' && !CanEditUpliftPercent}" Id="Uplift_PercentageLbl"/>
//                                
//                                <apex:inputField value="{!new.Uplift_Amount__c}" style="width: 45px;" rendered="{!new.Uplift_Entered_As__c == 'Amount' && CanEditUpliftPercent}" Id="Uplift_Amount">
//                                    <apex:actionSupport event="onchange" action="{!pricing}" reRender="quoteDetailsPopUp, quoteConfigPanel"/>
//                                </apex:inputField>
//                                <apex:outputField value="{!new.Uplift_Amount__c}" rendered="{! new.Uplift_Entered_As__c == 'Amount' &&!CanEditUpliftPercent}" Id="Uplift_AmountLbl"/>
//                                
//                                <apex:selectList value="{!new.Uplift_Entered_As__c}" multiselect="false" size="1" Id="Uplift_Entered_As" rendered="{!CanEditUpliftPercent}">
//                                    <apex:actionSupport event="onchange" action="{!pricing}" reRender="quoteDetailsPopUp, quoteConfigPanel"/>
//                                    <apex:selectOptions value="{!PercentAmountPicklist}"/>
//                                </apex:selectList>
//                                <apex:outputLabel value="{!new.Uplift_Entered_As__c}" Id="Uplift_Entered_AsLbl" rendered="{!!CanEditUpliftPercent}"/>
                            
                            if (CanEdit(fieldDef.Field__c)) // Check for edit permissions
                            {
                                // Can edit
                                if (thisQP.get(fieldBaseName + '_Entered_As__c') == 'Amount')
                                {
                                    // <apex:inputField value="{!new.Uplift_Amount__c}" style="width: 45px;" rendered="{!new.Uplift_Entered_As__c == 'Amount' && CanEditUpliftPercent}" Id="Uplift_Amount">
                                    //     <apex:actionSupport event="onchange" action="{!pricing}" reRender="quoteDetailsPopUp, quoteConfigPanel"/>
                                    // </apex:inputField>
                                    Component.Apex.InputField inputField = new Component.Apex.InputField();
                                    if (fieldDef.Required__c) inputField.required = true;
                                    inputField.expressions.value = '{!editQP.' + fieldBaseName + '_Amount__c}';
                                    inputField.style = 'width: 45px;';
//                                    Component.Apex.actionSupport actnSuport = new Component.Apex.ActionSupport(event='onchange');
//                                    actnSuport.expressions.action='{!pricing}';
//                                    // actnSuport.expressions.rerender='{!quoteDetailsPopUp}';
//                                    actnSuport.expressions.rerender='{!$Component.quoteDetailsPopUp},{!$Component.quoteConfigPanel}';
//                                    actnSuport.status='waitForLoad';//mainBlock
//                                    inputField.childComponents.add(actnSuport);
                                    
                                    thePageBlock.childComponents.add(inputField);
                                }
                                else
                                {
                                    // <apex:inputField value="{!new.Uplift_Percentage__c}" style="width: 45px;" rendered="{!new.Uplift_Entered_As__c != 'Amount' && CanEditUpliftPercent}" Id="Uplift_Percentage">
                                    //     <apex:actionSupport event="onchange" action="{!pricing}" reRender="quoteDetailsPopUp, quoteConfigPanel"/>
                                    // </apex:inputField>
                                    Component.Apex.InputField inputField = new Component.Apex.InputField();
                                    if (fieldDef.Required__c) inputField.required = true;
                                    inputField.expressions.value = '{!editQP.' + fieldBaseName + '_Percentage__c}';
                                    inputField.style = 'width: 45px;';
//                                    Component.Apex.actionSupport actnSuport = new Component.Apex.ActionSupport(event='onchange');
//                                    actnSuport.expressions.action='{!pricing}';
//                                    // actnSuport.expressions.rerender='{!quoteDetailsPopUp}';
//                                    actnSuport.expressions.rerender='{!$Component.quoteDetailsPopUp},{!$Component.quoteConfigPanel}';
//                                    actnSuport.status='waitForLoad';//mainBlock
//                                    inputField.childComponents.add(actnSuport);
                                    
                                    thePageBlock.childComponents.add(inputField);
                                }
                                
                                // <apex:selectList value="{!new.Uplift_Entered_As__c}" multiselect="false" size="1" Id="Uplift_Entered_As" rendered="{!CanEditUpliftPercent}">
                                //     <apex:actionSupport event="onchange" action="{!pricing}" reRender="quoteDetailsPopUp, quoteConfigPanel"/>
                                //     <apex:selectOptions value="{!PercentAmountPicklist}"/>
                                // </apex:selectList>
                                Component.Apex.SelectList selectList = new Component.Apex.SelectList();
                                selectList.expressions.value = '{!editQP.' + fieldBaseName + '_Entered_As__c}';
                                selectList.size = 1;
                                for (SelectOption option : getPercentAmountPicklist())
                                {
                                    selectList.childComponents.add(new Component.Apex.SelectOption( itemValue = option.getValue(), itemLabel = option.getLabel() ));
                                }
//                                Component.Apex.actionSupport actnSuport = new Component.Apex.ActionSupport(event='onchange');
//                                actnSuport.expressions.action='{!pricing}';
//                                // actnSuport.expressions.rerender='{!quoteDetailsPopUp}';
//                                actnSuport.expressions.rerender='{!$Component.quoteDetailsPopUp},{!$Component.quoteConfigPanel}';
//                                actnSuport.status='waitForLoad';//mainBlock
//                                selectList.childComponents.add(actnSuport);
                                
                                thePageBlock.childComponents.add(selectList);
                            }
                            else
                            {
                                // No edit
                                if (thisQP.get(fieldBaseName + '_Entered_As__c') == 'Amount')
                                {
                                    // <apex:outputField value="{!new.Uplift_Amount__c}" rendered="{! new.Uplift_Entered_As__c == 'Amount' &&!CanEditUpliftPercent}" Id="Uplift_AmountLbl"/>
                                    Component.Apex.OutputField outputField = new Component.Apex.OutputField();
                                    outputField.expressions.value = '{!editQP.' + fieldBaseName + '_Amount__c}';
                                    
                                    thePageBlock.childComponents.add(outputField);
                                }
                                else
                                {
                                    // <apex:outputField value="{!new.Uplift_Percentage__c}" rendered="{!new.Uplift_Entered_As__c != 'Amount' && !CanEditUpliftPercent}" Id="Uplift_PercentageLbl"/>
                                    Component.Apex.OutputField outputField = new Component.Apex.OutputField();
                                    outputField.expressions.value = '{!editQP.' + fieldBaseName + '_Percentage__c}';
                                    
                                    thePageBlock.childComponents.add(outputField);
                                }
                                
                                // <apex:outputLabel value="{!new.Uplift_Entered_As__c}" Id="Uplift_Entered_AsLbl" rendered="{!!CanEditUpliftPercent}"/>
                                Component.Apex.OutputLabel outputLabel = new Component.Apex.OutputLabel();
                                outputLabel.expressions.value = '{!editQP.' + fieldBaseName + '_Entered_As__c}';
                                
                                thePageBlock.childComponents.add(outputLabel);
                            }
                            
                            thePageBlock.childComponents.add(new Component.Apex.OutputText(escape = false, value = '</nobr>'));
                        } // End of __d field handling
                        else if ( fieldDef.Display_Type__c == 'Input')
                        {
                            System.debug(LoggingLevel.ERROR, '====> Generating VF code for field input');
                            // For list of field types, see: http://www.salesforce.com/us/developer/docs/apexcode/Content/apex_enum_Schema_DisplayType.htm
                            String fieldType = VCG_CPQ_Formula.GetFieldType(new VCG_CPQ_Quote_Product__c(), fieldDef.Field__c).name();
                            System.debug(LoggingLevel.ERROR, '====> fieldType: ' + fieldType);
                            
                            Component.Apex.InputField inputField = new Component.Apex.InputField();
                            if (fieldDef.Required__c) inputField.required = true;
                            inputField.expressions.value = '{!editQP.' + fieldDef.Field__c + '}';
                            if (    fieldType == 'CURRENCY'
                                 || fieldType == 'DOUBLE'
                                 || fieldType == 'INTEGER'
                                 || fieldType == 'PERCENT'
                                 || fieldType == 'STRING')
                            {
                                inputField.style = 'width: 45px;';
                            }
//                            Component.Apex.actionSupport actnSuport = new Component.Apex.ActionSupport(event='onchange');
//                            actnSuport.expressions.action='{!pricing}';
//                            // actnSuport.expressions.rerender='{!quoteDetailsPopUp}';
//                            actnSuport.expressions.rerender='{!$Component.quoteDetailsPopUp},{!$Component.quoteConfigPanel}';
//                            actnSuport.status='waitForLoad';//mainBlock
//                            inputField.childComponents.add(actnSuport);
                            
                            thePageBlock.childComponents.add(inputField);
                        }
                        else if ( fieldDef.Display_Type__c == 'Output')
                        {
                            Component.Apex.outputField outputField = new Component.Apex.outputField();
                            outputField.expressions.value = '{!editQP.' + fieldDef.Field__c + '}';
                            
                            thePageBlock.childComponents.add(outputField);
                        }
//                    }
                    thePageBlock.childComponents.add(new Component.Apex.OutputText(escape = false, value = '</td>'));
                }
                
                thePageBlock.childComponents.add(new Component.Apex.OutputText(escape = false, value = '</tr>'));
//            }
        }
        catch(Exception e)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Page Layout Misconfiguration for field "' + fieldName + '": ' + e.getMessage() + ' [line: ' + e.getLineNumber() + ']'));
        }
        
        
        //
        // End our custom table
        //
        thePageBlock.childComponents.add(new Component.Apex.OutputText(escape = false, value = '</table>'));
        thePageBlock.childComponents.add(new Component.Apex.OutputText(escape = false, value = '</div>'));
        
        System.debug('====> thePageBlock: ' + thePageBlock);
        return thePageBlock;
    }
    
     /**
     * @description 
     *
     * @author  Lawrence Coffin <lawrence.coffin@cloudsherpas.com>
     * @since   12.Nov.2014
     */
    public List<VCG_CPQ_Page_Layout__c> GetDisplayFields(String section) 
    {
        String soql = 'SELECT Field__c, '
                    + '       Display_Type__c, '
                    + '       Alt_Label__c, '
                    + '       Display_For_Product_Type__c, '
                    + '       AND_Display_If__c, '
                    + '       Required__c '
                    + ' FROM VCG_CPQ_Page_Layout__c '
                    + ' WHERE Page_Section__c = \''+ section + '\''
                    + ' ORDER BY Order__c ';
        System.debug(LoggingLevel.ERROR, '====> Query: ' + soql);
        
        List<VCG_CPQ_Page_Layout__c> fieldList = Database.query(soql);
        
        System.debug(LoggingLevel.ERROR, '====> ' + section + ' fields: ' + fieldList);
        
        return fieldList;
    }
    
     /**
     * @description  Dynamic Page Components/VisualForce for the Quote Details:New section
     *
     * NOTE: This original version attempts to replicate the existing VF code that uses a PageBlockTable
     *       to render the list. However, that throws the following error when the page is submitted:
     *
     *           Unknown property 'SObjectScriptRow.License_Metric_Quantity__c'
     *           Error is in expression '{!quoteProduct.License_Metric_Quantity__c}' in component <apex:page> in page vcg_cpq_quote
     *
     *        Currently checking with others/Salesforce to see if this is a SF bug or something we can fix.
     *
     * @author  Lawrence Coffin <lawrence.coffin@cloudsherpas.com>
     * @since   20.Aug.2014
     */
/*    public Component.Apex.PageBlock getQuoteDetailsNewVF_orig() 
    {
        List<VCG_CPQ_Quote_Product__c> theQPList = newQuoteProductList;
        
        //
        // First, check to see if there are any Quote Products of this type
        //
        if (theQPList == null || theQPList.size() == 0)
        {
            return null;
        }
        
        //
        // Collect up the CPQ_Display_Type__c values -- we want only the columns needed for the types we have
        //
        Set<String> productDisplayTypes = new Set<String>();
        for (VCG_CPQ_Quote_Product__c qp : theQPList)
        {
            productDisplayTypes.add(qp.Product__r.CPQ_Display_Type__c);
        }
        List<String> productDisplayTypesList = new List<String>();
        productDisplayTypesList.addAll(productDisplayTypes);
        String productDisplayTypesStr = String.join(productDisplayTypesList, '\', \'');
        
        System.debug('====> productDisplayTypesStr: ' + productDisplayTypesStr);
        
        Component.Apex.PageBlock thePageBlock = new Component.Apex.PageBlock();
        thePageBlock.Id = 'quoteDetailsNew';
        thePageBlock.title = 'New';
        
        Component.Apex.PageBlockTable thePageBlockTable = new Component.Apex.PageBlockTable();
        thePageBlock.childComponents.add(thePageBlockTable);
        thePageBlockTable.value = theQPList; // '{!newQuoteProductList}';
        thePageBlockTable.var = 'quoteProduct';
        
        // Note: We have to use a soql query string because INCLUDES doesn't support
        // variable interpolation for lists or strings with multiple values in it
        String soql = 'SELECT Field__c, '
                    + '       Display_Type__c, '
                    + '       Alt_Label__c, '
                    + '       Display_For_Product_Type__c '
                    + ' FROM VCG_CPQ_Page_Layout__c '
                    + ' WHERE Page_Section__c = \'Quote Details:New\' '
                    + '       AND Display_For_Product_Type__c INCLUDES (\'' + String.join(productDisplayTypesList, '\', \'') + '\') '
                    + ' ORDER BY Order__c ';
//                    + ' LIMIT 4';
        System.debug('====> Query: ' + soql);
        
        for (VCG_CPQ_Page_Layout__c fieldDef : Database.query(soql))
        {
            if (fieldDef.Field__c != null
                && fieldDef.Field__c.equalsIgnoreCase('CurrencyIsoCode')
                && !UserInfo.isMultiCurrencyOrganization())
            {
                continue;
            }
            
            try
            {
                if ( fieldDef.Display_Type__c == 'Input')
                {
                    Component.Apex.InputField inputField = new Component.Apex.InputField();
                    inputField.expressions.value = '{!quoteProduct.'+fieldDef.Field__c+'}';
                    Component.Apex.actionSupport actnSuport = new Component.Apex.ActionSupport(event='onchange');
                    actnSuport.expressions.action='{!pricing}';
                    // actnSuport.expressions.rerender='{!quoteDetailsPopUp}';
                    actnSuport.expressions.rerender='{!$Component.quoteDetailsPopUp},{!$Component.quoteConfigPanel}';
                    actnSuport.status='waitForLoad';//mainBlock
                    inputField.childComponents.add(actnSuport);
                    
                    Component.Apex.Column theColumn = new Component.Apex.column();
                    if (fieldDef.Alt_Label__c != null)
                    {
                        theColumn.headerValue = fieldDef.Alt_Label__c;
                    }
                    else
                    {
                        theColumn.headerValue = VCG_CPQ_Formula.getFieldLabel('VCG_CPQ_Quote_Product__c', fieldDef.Field__c);
                    }
                    
                    theColumn.childComponents.add(inputField);
                    
                    thePageBlockTable.childComponents.add(theColumn);
                }
                else 
                if ( fieldDef.Display_Type__c == 'Output')
                {
                    Component.Apex.column theColumn = new Component.Apex.column();
                    theColumn.expressions.value = '{!quoteProduct.' + fieldDef.Field__c + '}';
                    if (fieldDef.Alt_Label__c != null)
                    {
                        theColumn.headerValue = fieldDef.Alt_Label__c;
                    }
                    
                    thePageBlockTable.childComponents.add(theColumn);
                }
            }
            catch(Exception e)
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Page Layout Misconfiguration for field "' + fieldDef.Field__c + '": ' + e.getMessage() + ' [line: ' + e.getLineNumber() + ']'));
            }
        }
        
        System.debug('====> thePageBlock: ' + thePageBlock);
        return thePageBlock;
    }
*/    
     /**
     * @description  Populate lists displayed on the Pages
     *
     * @author Lawrence Coffin <lawrence.coffin@cloudsherpas.com>
     * @since   1.Apr.2014
     */
    public void populateListsAndPrice()
    {
        //clearing all three quoteProductWrapper lists
        qpwList.clear();
//        existingQPWList.clear();
//        newQPWList.clear();
        
        // Re-instantiate the existing product list
        qpwList = new List<QuoteProductWrapper>();
        System.debug('>>>>>>>>>>qpwMap>>>'+qpwMap);
        
        // Check if the qpwMap is not empty
        if (qpwMap != null && qpwMap.size() > 0)
        {
            // Re-instantate Lists of Quote Products
            newQuoteProductList = new List<VCG_CPQ_Quote_Product__c>();
            renewalQuoteProductList = new List<VCG_CPQ_Quote_Product__c>();
            allQuoteProductList = new List<VCG_CPQ_Quote_Product__c>();
            extQuoteProductList = new List<VCG_CPQ_Quote_Product__c>();
            decomQuoteProductList = new List<VCG_CPQ_Quote_Product__c>();
            migrationQuoteProductList = new List<VCG_CPQ_Quote_Product__c>();
            otherQuoteProductList = new List<VCG_CPQ_Quote_Product__c>();
            System.debug('>>>>>>>>>>qpwMap>>>'+qpwMap);
            System.debug('====> qpwMap keyset: ' + qpwMap.keySet());
            
            // Loop through all QPWs and collect all Quote Product records for pricing
            /** @todo  Loop through .values() instead since we really don't need the key here for any reason and we can save from having to do lookups all the time */
            for (String qpwMapKey : qpwMap.KeySet())
            {
                // If there is a quote product record
                if (qpwMap.get(qpwMapKey).quoteProdRec != null && qpwMap.get(qpwMapKey).quoteProdRec.Line_Type__c != null)
                {
                    allQuoteProductList.add(qpwMap.get(qpwMapKey).quoteProdRec);
                    if(qpwMap.get(qpwMapKey).assetRec != null)
                    {
                        qpwMap.get(qpwMapKey).quoteProdRec.Asset__r = qpwMap.get(qpwMapKey).assetRec; // Patch for missing asset in pricing
                    }
                }
                
                // If there is a main maintenance record
                if (qpwMap.get(qpwMapKey).mainMaintQPRec != null && qpwMap.get(qpwMapKey).mainMaintQPRec.Line_Type__c != null)
                {
                    allQuoteProductList.add(qpwMap.get(qpwMapKey).mainMaintQPRec);
                }
                
                // If there is a Renewal Record
                if (qpwMap.get(qpwMapKey).renewalQuoteProdRec != null)
                {
                    qpwMap.get(qpwMapKey).renewalQuoteProdRec.Asset__r = qpwMap.get(qpwMapKey).assetRec;
                    allQuoteProductList.add(qpwMap.get(qpwMapKey).renewalQuoteProdRec);
                }
                
                // If there is a renewal maintenance record
                if (qpwMap.get(qpwMapKey).renewMaintQPRec != null && qpwMap.get(qpwMapKey).renewMaintQPRec.Line_Type__c != null)
                {
                    qpwMap.get(qpwMapKey).renewMaintQPRec.Asset__r = qpwMap.get(qpwMapKey).assetRec;
                    allQuoteProductList.add(qpwMap.get(qpwMapKey).renewMaintQPRec);
                }
            }
            
            //
            // Add in bundle products
            //
            /*
            for (BundleWrapper bundle : configBundles.values()) 
            {
                for (VCG_CPQ_Quote_Product__c quoteProd : bundle.bundledQuoteProds) 
                {
                        allQuoteProductList.add(quoteProd);
                        
                        if (quoteProd.Line_Type__c == 'New') {
                            newQuoteProductList.add(quoteProd);
                        }
                }
            }
            
            //
            // Add in existing bundle products from the assets if they have been extended
            //
            for (BundleWrapper bundle : assetBundles.values()) 
            {
                for (VCG_CPQ_Quote_Product__c quoteProd : bundle.bundledQuoteProds) 
                {
                        allQuoteProductList.add(quoteProd);
                        
                        if (quoteProd.Line_Type__c == 'Extension') {
                            newQuoteProductList.add(quoteProd);
                        }
                }
            }
            */
            // Call Pricing Utility to run Quote Product
            try
            {
                System.debug('Quote Value : '+quote);
                VCG_CPQ_PricingUtility.populateFormulaData(quote);//get the data related to the quote for pricing formulas
            }
            catch(Exception e)
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Error Populating Formula Data: ' + e.getMessage() + ' [line: ' + e.getLineNumber() + ']'));
            }
            
            try
            {
                // validate products before pricing
                List<VCG_CPQ_Error> productErrors = validateProductSelection(qpwMap);
                if (productErrors.size() > 0)
                {
                    for (VCG_CPQ_Error e : productErrors)
                    {
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,e.errorType+': ['+e.errorMessage+']'));
                    }
                    return;
                }
            }
            catch(Exception e)
            {
                System.debug('====> Validation Error: ' + e.getMessage() + '\n' + e.getStackTraceString());
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Error validating products: ' + e.getMessage() + '\n' + e.getStackTraceString()));
            }
                
            try
            {
                // Calculate price if no errors
                VCG_CPQ_PricingUtility.priceQuoteProducts(quote, allQuoteProductList, existingAssetList, pricingOverrideMap, this);
            }
            catch(Exception e)
            {
                System.debug('====> Pricing Error: ' + e.getMessage() + '\n' + e.getStackTraceString());
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Error Pricing Quote Products: ' + e.getMessage() + '\n' + e.getStackTraceString()));
            }
            
            //
            // The pricing can add or delete product lines from the allQuoteProductList -- primarily just auto-added lines for Premium Support for Websense
            // so we need to align the Controller data with the allQuoteProductList data
            //
            Map<String,QuoteProductWrapper> keepQpwMap = new Map<String,QuoteProductWrapper>();
            for (VCG_CPQ_Quote_Product__c qp : allQuoteProductList)
            {
                String qpwMapKey = getQPWMapKey(qp, qp.Product_Group__c);
           
                QuoteProductWrapper qpw;
                if (keepQpwMap.containsKey(qpwMapKey))
                {
                    qpw = keepQpwMap.get(qpwMapKey);
                }
                else if (qpwMap.containsKey(qpwMapKey))
                {
                    qpw = qpwMap.get(qpwMapKey);
                    keepQpwMap.put(qpwMapKey, qpw);
                }
                else
                {
                    // Product does not have a QuoteProductWrapper record yet, must be an auto-added product, create a QPW!
                    qpw = new QuoteProductWrapper(quote, qp.Product__r, qp, null);
                    keepQpwMap.put(qpwMapKey, qpw);
                    qpw.isNew = true; // auto-added products are currently always 'New'
                }
                
                if (qp.Product__r.Is_Maintenance__c)
                {
                    if (qp.Line_Type__c == 'Renewal')
                    {
                        qpw.renewMaintQPRec = qp;
                    }
                    else
                    {
                        qpw.mainMaintQPRec = qp;
                    }
                }
                else
                {
                    if (qp.Line_Type__c == 'Renewal')
                    {
                        qpw.renewalQuoteProdRec = qp;
                    }
                    else
                    {
                        qpw.quoteProdRec = qp;
                    }
                }
            }
            
            //
            // Check to see if there were any QP records with an id that were deleted
            //
            for (Id deletedQPId : VCG_CPQ_PricingUtility.deletedQPIds)
            {
                quoteProductsToDelete.add(new VCG_CPQ_Quote_Product__c( Id = deletedQPId ));
            }
            
            // Make sure we keep any isExisting QPWs (i.e. QPWs for any existing assets that haven't been modified so they don't have a QP record)
            for (String qpwMapKey : qpwMap.keySet()) {
                QuoteProductWrapper qpw = qpwMap.get(qpwMapKey);
                
                if (qpw.isExisting && !keepQpwMap.containsKey(qpwMapKey))
                {
                    keepQpwMap.put(qpwMapKey, qpw);
                }
            }
            
            // Now, set qpwMap back to the products we are keeping
            qpwMap = keepQpwMap;
            System.debug('====> qpwMap keyset: ' + qpwMap.keySet());
            
            
            //
            // get the pricing results from the Pricing Utility class
            //
            pricingResultsMap = VCG_CPQ_PricingUtility.pricingResultsMap;
            
/*            if (pricingResultsMap != null && pricingResultsMap.size() > 0)
            {
                System.debug('====> pricingResultsMap keys before call to getPricingResults(): ' + pricingResultsMap.keySet());
                System.debug('====> pricingResultsMap before call to getPricingResults(): ' + pricingResultsMap);
                
                /** @todo  What is this call doing?? */
                // LC 7/20/2014 - testing with this commented out. Think it is just for populating Quote_Product__r on pricing result. Something that is happening (recently) in pricing utility.
                // LC 7/20/2014 - seems to work fine with it commented out.
//                getPricingResults();
/*                
                System.debug('====> pricingResultsMap keys after call to getPricingResults(): ' + pricingResultsMap.keySet());
                System.debug('====> pricingResultsMap after call to getPricingResults(): ' + pricingResultsMap);
            }
*/            
            // Update lineTotal amount in wrapper record
            for (QuoteProductWrapper qpw : qpwMap.values()) 
            {
                qpw.salesPriceTotal.aCurr2__c = qpw.getSalesPriceTotal();
                qpw.arrTotal.aCurr2__c = qpw.getARRTotal();
                qpw.lineTotal.aCurr2__c = qpw.getLineTotal();
            }
            
            /*
            // Update total amounts for bundles
            for (BundleWrapper bundle : configBundles.values())
            {
                bundle.totalValue.aCurr2__c = 0.00;
                
                for (VCG_CPQ_Quote_Product__c quoteProd : bundle.bundledQuoteProds) 
                {
                    bundle.totalValue.aCurr2__c += ( quoteProd.Term_Amount__c == null ? 0.00 : quoteProd.Term_Amount__c );
                }
            }
            
            // Update total amounts for extension bundles
            for (BundleWrapper bundle : assetBundles.values())
            {
                bundle.totalValue.aCurr2__c = 0.00;
                
                for (VCG_CPQ_Quote_Product__c quoteProd : bundle.bundledQuoteProds) 
                {
                    bundle.totalValue.aCurr2__c += ( quoteProd.Term_Amount__c == null ? 0.00 : quoteProd.Term_Amount__c );
                }
            }
            */
            
            //
            // Go back throuygh through all QPWs and re-populate the various lists needed for the controller
            //
            for (String qpwMapKey : qpwMap.KeySet())
            {
/*                // Add new products to the new list
                if (qpwMap.get(qpwMapKey).isNew)
                {
                    newQPWList.add(qpwMap.get(qpwMapKey));
                }
                
                // Add existing Products to the existing Quote Product List
                // But skip migrated assets
                if (qpwMap.get(qpwMapKey).isExisting
                    && !qpwMap.get(qpwMapKey).isMigrated)
                {
                    existingQPWList.add(qpwMap.get(qpwMapKey));
                }
*/                
                // Add all QPWs to the qpwList
                // But skip migrated assets
                if (!qpwMap.get(qpwMapKey).isMigrated)
                {
                    qpwList.add(qpwMap.get(qpwMapKey));
                }
                
                // Check if there is an new/extension/decommission/migration quote product record
                if (qpwMap.get(qpwMapKey).quoteProdRec != null && qpwMap.get(qpwMapKey).quoteProdRec.Line_Type__c != null)
                {
                    // Add Quote Product to appropriate List
                    if (qpwMap.get(qpwMapKey).quoteProdRec.Line_Type__c == 'New')
                    {
                        newQuoteProductList.add(qpwMap.get(qpwMapKey).quoteProdRec);
                        if (qpwMap.get(qpwMapKey).mainMaintQPRec != null) newQuoteProductList.add(qpwMap.get(qpwMapKey).mainMaintQPRec);
                    }
                    else if (qpwMap.get(qpwMapKey).quoteProdRec.Line_Type__c == 'Extension')
                    {
                        extQuoteProductList.add(qpwMap.get(qpwMapKey).quoteProdRec);
                        if (qpwMap.get(qpwMapKey).mainMaintQPRec != null) extQuoteProductList.add(qpwMap.get(qpwMapKey).mainMaintQPRec);
                    }
                    else if (qpwMap.get(qpwMapKey).quoteProdRec.Line_Type__c == 'Decommission')
                    {
                        decomQuoteProductList.add(qpwMap.get(qpwMapKey).quoteProdRec);
                        if (qpwMap.get(qpwMapKey).mainMaintQPRec != null) decomQuoteProductList.add(qpwMap.get(qpwMapKey).mainMaintQPRec);
                    }
                    else if (qpwMap.get(qpwMapKey).quoteProdRec.Line_Type__c == 'Migration')
                    {
                        migrationQuoteProductList.add(qpwMap.get(qpwMapKey).quoteProdRec);
                        if (qpwMap.get(qpwMapKey).mainMaintQPRec != null) migrationQuoteProductList.add(qpwMap.get(qpwMapKey).mainMaintQPRec);
                    }
                    else if (qpwMap.get(qpwMapKey).quoteProdRec.Line_Type__c == 'Other')
                    {
                        otherQuoteProductList.add(qpwMap.get(qpwMapKey).quoteProdRec);
                    }
                }
                
                // If there is a Renewal Record
                if (qpwMap.get(qpwMapKey).renewalQuoteProdRec != null)
                {
                    // Add Quote Product to appropriate List
                    renewalQuoteProductList.add(qpwMap.get(qpwMapKey).renewalQuoteProdRec);
                }
                // And if there is a renewal maintenance record (outside the check for renewal record, because perpetual renews just the maintenance, not the product itself, so there will be no renewal QP record)
                if (qpwMap.get(qpwMapKey).renewMaintQPRec != null)
                {
                    renewalQuoteProductList.add(qpwMap.get(qpwMapKey).renewMaintQPRec);
                }
                // And if there is a decom maintenance record (outside the check for regular decom record, because perpetual decoms just the maintenance, not the product itself, so there will be no decom QP record)
                // Have to check to make sure the main QP rec doesn't exist AND the maintenance line is a Decom. Otherwise new maintenance lines are showing up in Decom list
                if ((qpwMap.get(qpwMapKey).quoteProdRec == null || qpwMap.get(qpwMapKey).quoteProdRec.Line_Type__c == null)
                    && qpwMap.get(qpwMapKey).mainMaintQPRec != null && qpwMap.get(qpwMapKey).mainMaintQPRec.Line_Type__c == 'Decommission')
                {
                    decomQuoteProductList.add(qpwMap.get(qpwMapKey).mainMaintQPRec);
                }
            }
            
            // adding existingQPWList and newQPWList to qpwList
//            qpwList.addAll(existingQPWList);
//            qpwList.addAll(newQPWList);
        }
        
        alignItemGroups();
        
        // Determine if the quote has groups defined
        setQuoteGroupActive();
    }
    
    /**
     * @description  Loads an array of parent/core product seletions for add-on products when the user selects a product that is an Add-on.
     *
     * @author Nathan Shinn
     * @since  15.August.2014
     */
/*    public void getRecAddOCoreProducts()
    {
        try{
            //
            // Collect products from the filtered product list that have a non-zero quantity and have not been assigned a source
            //
            if (addNewFilteredProdList.size() > 0)
            {
                for (QuoteProductWrapper q : addNewFilteredProdList) 
                {
                    if (q.quoteProdRec.License_Metric_Quantity__c != null 
                        && q.quoteProdRec.License_Metric_Quantity__c > 0 
                        && q.quoteProdRec.Add_on_Source_Quote_Product__r == null)
                    {
                        // If this product has a quantity, and a core product hasn't already been assigned
                        //allSelectedQuoteProducts.add(q.quoteProdRec);
                    }
               }
           }
        }
        catch(Exception e)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Error Assigning Add-on: ' + e.getMessage() + ' [line: ' + e.getLineNumber() + ']'));
       }
        
    }
*/    
     /**
     * @description  Returns a recommended list of products based on users selection of any product in a particular product category.
     *
     * @author Ataullah Khan
     * @since  20.Apr.2014
     */
    public void getRecAddOns()
    {
        System.debug('====> getRecAddOns() called' );
        try
        {
            // Local variables to hold temporary data
            List<VCG_CPQ_Quote_Product__c> allSelectedQuoteProducts = new  List<VCG_CPQ_Quote_Product__c>();  
            Map<string,QuoteProductWrapper> existingAddOns = new  Map<string,QuoteProductWrapper>();
            Set<ID> nonSelectedQuoteProducts = new Set<ID>();
      
            //
            // Collect products from the filtered product list that have a non-zero quantity
            //
            if (addNewFilteredProdList.size() > 0)
            {
                for (QuoteProductWrapper q : addNewFilteredProdList) 
                {
                    if (q.quoteProdRec.License_Metric_Quantity__c != null && q.quoteProdRec.License_Metric_Quantity__c > 0)
                    {
                        // If this product has a quantity, add it to the list of selected quote products
                        allSelectedQuoteProducts.add(q.quoteProdRec);
                    }
                    else {
                        // If the product has a zero quantity, then add it to the nonSelectedQuoteProducts list
                        // -- we want to remove any add-ons that may be related to these products
                        nonSelectedQuoteProducts.add(q.quoteProdRec.product__c);
                    }
               }
           }
            System.debug('====> allSelectedQuoteProducts: ' + allSelectedQuoteProducts);
            //
            // Collect products from the recommended add-ons list that have a non-zero quantity
            //
            if (recAddOnsList.size() > 0)
            {           
                for (QuoteProductWrapper q1 : recAddOnsList)
                {
                    // Collect all existing addons in a map so we can refer to them below
                    existingAddOns.put(q1.quoteProdRec.product__c, q1);
                    
                    if (q1.quoteProdRec.License_Metric_Quantity__c != null && q1.quoteProdRec.License_Metric_Quantity__c > 0)
                       {
                        // If this product has a quantity, add it to the list of selected quote products
                        allSelectedQuoteProducts.add(q1.quoteProdRec);
                        
                        // In case this product is also non-selected in the main list, we want to remove it from the list
                        // of non-selected products because it is selected here.
                        nonSelectedQuoteProducts.remove(q1.quoteProdRec.Product__c);
                    }
                    else {
                        // If the add-on product has a zero quantity, then add it to the nonSelectedQuoteProducts list
                        // -- we want to remove any add-ons that may be related to these add-ons
                        nonSelectedQuoteProducts.add(q1.quoteProdRec.Product__c);
                    } 
                }
            }
                  
            //
            // Get recommended add-ons for all products that have a non-zero quantity
            //
            if (allSelectedQuoteProducts.size() > 0)
            {
                List<VCG_CPQ_Product_Addon_Wrapper> recmdPdtList = VCG_CPQ_ProductUtility.getAddonProducts(quote, allSelectedQuoteProducts);
                System.debug('====> recmdPdtList.size: ' + recmdPdtList.size());
                System.debug('====> recmdPdtList: ' + recmdPdtList);
                
                for (VCG_CPQ_Product_Addon_Wrapper addOnRes : recmdPdtList)
                {
                   if (!existingAddOns.containsKey(addOnRes.addonProduct.Id))
                    {
                        System.debug('====> Creating new addon record for recommendedList: ' + addOnRes.addonProduct.Name);
                        
                        // Determine the Term End date. If this product is perpetual, then leave Term End date blank,
                        // otherwise set to the product it is being added on to unless *that* product is perpetual
                        // (null Term End date), in which case we set it to the common end date of the other quote products,
                        // or one year from the quote effective date (or Today)
                        Date termEndDate;
//                        if (addOnRes.addonProduct.Is_Perpetual__c)
//                        {
//                          termEndDate = null; // Already has this value, but add to be explicit
//                        }
//                        else 
                        if (addOnRes.addOnTo.Asset_Term_End_Date__c != null)
                        {
                            termEndDate = addOnRes.addOnTo.Asset_Term_End_Date__c;
                        }
                        else
                        {
                            Date effectiveDate = ( quote.Effective_Date__c == null ? Date.today() : quote.Effective_Date__c );
                            
                            termEndDate = getCommonTermEndDate(qpwMap, effectiveDate.addYears(1).addDays(-1));
                        }
                        
                        VCG_CPQ_Quote_Product__c qp = new VCG_CPQ_Quote_Product__c(
                                                                                     Product__c = addOnRes.addonProduct.Id,
                                                                                     Quote__r = this.quote,
                                                                                     // Set LMQ to the recommended min. If min == 0, set it to null so it displays with a blank quantity field
                                                                                     License_Metric_Quantity__c = ( addOnRes.min == 0 ? null : addOnRes.min ),
                                                                                     Asset_Term_End_Date__c = termEndDate,
                                                                                     Add_on_Source_Quote_Product__r = addOnRes.addOnTo
                                                                                  );
                        if (UserInfo.isMultiCurrencyOrganization()) qp.put('CurrencyIsoCode', quote.get('CurrencyIsoCode'));
                        
                        QuoteProductWrapper qpWrap = new QuoteProductWrapper(quote,
                                                                             addOnRes.addonProduct,
                                                                             qp,
                                                                             null);
                        qpWrap.addOnResultRec = addOnRes;
                        qpWrap.isAddOn = true;                                                         
                        recAddOnsList.add(qpWrap);
                } 
                    else
                    {
                        System.debug('====> Existing addon record in recommendedList: ' + addOnRes.addonProduct.Name);
                
                        //
                        // Existing Add On record for this product, apply the new add-on result - changing the
                        // entered quantity to match the new addOn.min/max if needed.
                        //
                        QuoteProductWrapper qpWrap = existingAddOns.get(addOnRes.addonProduct.Id);
                 
                        if ((qpWrap.quoteProdRec.License_Metric_Quantity__c == null && addOnRes.min > 0)
                                || (qpWrap.quoteProdRec.License_Metric_Quantity__c < addOnRes.min))
                        {
                                qpWrap.quoteProdRec.License_Metric_Quantity__c = addOnRes.min;
                        }
                        else if (qpWrap.quoteProdRec.License_Metric_Quantity__c != null
                                    && qpWrap.quoteProdRec.License_Metric_Quantity__c > addOnRes.max)
                        {
                            qpWrap.quoteProdRec.License_Metric_Quantity__c = (addOnRes.max == 0 ? null : addOnRes.max);
                        }
                        System.debug('====> New LMQ: ' + qpWrap.quoteProdRec.License_Metric_Quantity__c);
            
                        /** @todo  Are there any instances where the addOnTo value is changed? */
                    
                        // Always update the addOnResultRec reference to the new result record
                        qpWrap.addOnResultRec = addOnRes;
                    }
                }
                 
                // Copy the recommendation list and see if any of the add-ons are related to products that have
                // been removed from the user's selection, if so we want to skip them and not have them show
                // up in the recommendation list.
                List<QuoteProductWrapper> QuotePDtWrapperTemp = new List<QuoteProductWrapper>();
                QuotePDtWrapperTemp.addall(recAddOnsList); 
                recAddOnsList.clear();
                for (QuoteProductWrapper qp: QuotePDtWrapperTemp)
                {
                    if (!nonSelectedQuoteProducts.contains(qp.addOnResultRec.addOnTo.Product__c))
                    {
                       recAddOnsList.add(qp);
                    }
                }
            }
            
            // Prepare new list of QuoteProductAddOnWrapper to sort product add ons
            list<QuoteProductAddOnWrapper> addOnWrapperTemp = new list<QuoteProductAddOnWrapper>();
            for(QuoteProductWrapper qpw:recAddOnsList){
                addOnWrapperTemp.add(new QuoteProductAddOnWrapper(qpw));
            }
            addOnWrapperTemp.sort();
            //empty the recAddOnsList then add products after sorting
            recAddOnsList.clear();
            for(QuoteProductAddOnWrapper ao:addOnWrapperTemp){
                recAddOnsList.add(ao.myQuoteProductWrapper);
            }
        }
        catch(Exception e)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Error Getting Add-on: ' + e.getMessage() + ' [line: ' + e.getLineNumber() + ']'));
       }
    }              
    
    public list<SelectOption> getPercentAmountPicklist()
    {
        list<SelectOption> pcListOptions = new list<SelectOption>();
        
        pcListOptions.add(new SelectOption('Percentage', '%'));
        
        if (UserInfo.isMultiCurrencyOrganization())
            pcListOptions.add(new SelectOption('Amount', VCG_CPQ_PricingUtility.getCurrencySymbol((String)quote.get('CurrencyISOCode'))));
        else
            pcListOptions.add(new SelectOption('Amount', VCG_CPQ_PricingUtility.getCurrencySymbol(UserInfo.getDefaultCurrency())));
        
        return pcListOptions;
    }
    
    ///////////////////////
    // Group Functions
    /**
     * @description  map of groups to product list. The list is a sub-groping of the map of product wrappers
     *              iterate through the group mapping then print the pageblock sections. Dynamicaly add the group Id param to the addNew button
     *              see the end Date as an example for the parameter
     *
     * @author Nathan Shinn
     * @since  28.Apr.2014
     */
    public Integer groupedProductSize{get{return groupedProductSize == null ? 0 : groupedProductSize;}set;}
    public PageReference addGroup()
    {
        Integer groupCnt = groupedQpwMap.size();
        groupedProductSize = groupCnt + 1;
        //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'groupCnt: '+groupCnt));
        
        
        
        //if this is the very first group and there are products that are ungrouped, add those products to group 1
        if (groupCnt == 1 && groupedQpwMap.keySet().contains('') )
        {
            list<QuoteProductWrapper> wrap = groupedQpwMap.get('');
            list<QuoteProductWrapper> group1 = new list<QuoteProductWrapper>();
            list<QuoteProductWrapper> standalone = new list<QuoteProductWrapper>();
            Integer cnt = 0;
            set<Integer> standaloneProductsToRemove = new set<Integer>();
            for (QuoteProductWrapper qpw : wrap)
            {
                if (qpw.productRec.Is_Groupable__c)
                {
                    qpw.quoteProdRec.Product_Group__c = 'Group 1';
                    qpwMap.remove(getQPWMapKey(qpw.productRec.Id, ''));
                    qpwMap.put(getQPWMapKey(qpw.productRec.Id, qpw.quoteProdRec.Product_Group__c), qpw);
                    standaloneProductsToRemove.add(cnt);
                    group1.add(qpw);
                }
                else
                {
                    qpw.quoteProdRec.Product_Group__c = 'Standalone';
                    qpwMap.remove(getQPWMapKey(qpw.productRec.Id, ''));
                    qpwMap.put(getQPWMapKey(qpw.productRec.Id, 'Standalone'), qpw);
                    standaloneProductsToRemove.add(cnt);
                    standalone.add(qpw);
                }
                cnt++;
            }
            //remove the newly grouped products from the blank group
            groupedQpwMap.put('',new list<QuoteProductWrapper>());
            groupedQpwMap.remove('');
            
            groupedQpwMap.put('Group 1', group1);
            
            if(standalone.size() > 0)
                groupedQpwMap.put('Standalone', standalone);
            
            if(group1.size() > 0)
                groupedQpwMap.put('Group 2',  new list<QuoteProductWrapper>());
        }
        else
        {
            for (String s : groupedQpwMap.keySet())
            { 
                
                if (s.contains('Group '+groupCnt))//determining whether the group already exists so we don't overwrite it
                    groupCnt++;
                if (s == '')
                    groupCnt--;
            }
            groupedQpwMap.put('Group '+(groupCnt==0?1:groupCnt), new list<QuoteProductWrapper>());
            //populateListsAndPrice();
        }
        
        return null;
    }
    
    /**
     * @description  Sets the Groups_Active__c if there are any groups defined on the quote prodcts or assets
     *
     * @author Nathan Shinn
     * @since  11/12/2014
     */
    public void setQuoteGroupActive()
    {
        quote.Groups_Active__c = false;
        for(string key : groupedQpwMap.keySet())
        {
            if(key != '' && key != 'Standalone')
            {
                quote.Groups_Active__c = true;
                //System.debug(LoggingLevel.ERROR, '====> Reset Groups_Active__c: true');
                return;
            }
        }
        //System.debug(LoggingLevel.ERROR, '====> Reset Groups_Active__c: false');
    }
    
    /**
     * @description  Wrapper method for Product Group Key generation from QP record
     *               -- for Maintenance items, uses the parent product, not the maintenance product.
     *               Note: All maintenance QP records should come through here, not through the
     *               direct method below!
     *
     * @author Lawrence Coffin
     * @since  24.Sep.2014
     */
    public String getQPWMapKey(VCG_CPQ_Quote_Product__c qp, String groupName)
    {
        if (qp.Product__r.Is_Maintenance__c)
        {
            System.debug(LoggingLevel.ERROR, '::=== Line Type: > '+qp.Line_Type__c);
            if (qp.Line_Type__c == 'Renewal' || qp.Line_Type__c == 'Decommission')
            {
                // Want the QPW Map Key of the *primary* product this is maintenance for
                // For maintenance renewals, there is no primary QP, so we refer back to the
                // Asset record for the 'parent' product
                return getQPWMapKey(qp.Asset__r.Product__c, groupName);
            }
            else
            {
                // Want the QPW Map Key of the *primary* product this is maintenance for
                return getQPWMapKey(qp.Add_On_Source_Quote_Product__r.Product__c, groupName);
            }
        }
        else
        {
            // Want the QPW Map Key of this product
            return getQPWMapKey(qp.Product__c, groupName);
        }
    }
    
    /**
     * @description  centralized function for generating Product Group Key
     *
     * @author Nathan Shinn
     * @since  28.July.2014
     */
    // Renamed from getGroupMapKey() -LC 2014-08-04
    public String getQPWMapKey(String productId, String groupName)
    {
        return (productId + (groupName == null ? '' : groupName));
    }
    
    /**
     * @description  Used to map products to their respective groups using the product group
     *
     * @author Nathan Shinn
     * @since  28.Apr.2014
     */
    public void alignItemGroups()
    {
        /** @todo  Change Group code to handle no group scenario with non-groupable products -- i.e.
                   all products are put into an un-named group - both groupable and non-groupable products. If the
                   user then clicks 'Add Group', the tool should: 1) Move all groupable products into 'Group 1',
                   2) Move any non-groupable products into 'Standalone', 3) Create an empty 'Group 2' for users
                   to add new products to. */
         
        Integer groupSize = groupedQpwMap.size();
        groupedQpwMap.clear();
        
        set<Id> migratedProducts = new set<Id>();
        set<Id> migratedAssets = new set<Id>();
        for (QuoteProductWrapper qpw : qpwMap.values())//catalog migrated products for exclusion
        {
            if(qpw.quoteProdRec.From_Asset__c != null)
            {
                migratedAssets.add(qpw.quoteProdRec.From_Asset__c );
            }
            if(qpw.quoteProdRec.From_Product__c != null )
            {
                migratedProducts.add(qpw.quoteProdRec.From_Product__c);
            }
        }
        
        for (QuoteProductWrapper qpw : qpwMap.values())
        {
            String groupKey = '';
            if((qpw.productRec != null && migratedProducts.contains(qpw.productRec.Id)) || (qpw.assetRec != null && migratedAssets.contains(qpw.assetRec.Id)) )
            {
                qpw.isMigrated = true;
                continue;// don't display these
            }
            
            if(qpw.quoteProdRec.Line_Type__c == 'Decommission' 
                   && (qpw.quoteProdRec.Decommission_Quantity__c == null || qpw.quoteProdRec.Decommission_Quantity__c == 0 || qpw.isExisting == false) )
              continue;
            
            System.debug('====> Aligning Product: ' + qpw.productRec.Name);
            System.debug('====> Current group: ' + qpw.quoteProdRec.Product_Group__c);
            System.debug('====> Is Groupable: ' + qpw.productRec.Is_Groupable__c);
            System.debug('====> Asset Rec is Null? ' + ( qpw.assetRec == null ? 'true' : 'false' ));
            
            if (qpw.productRec.Is_Groupable__c || qpw.assetRec != null)
            {
                if (qpw.assetRec != null) // && qpw.assetRec.Id != null) // this is an asset
                {
                    groupKey = (qpw.assetRec.Product_Group__c == null ? '' : qpw.assetRec.Product_Group__c);
                }
                else
                {
// LC 4/22/2014 - testing null value group name - use '' rather than 'Group 1' to get around edit existing quote bug (products load with 'Group 1', not blank)
//                    groupKey = (qpw.quoteProdRec.Product_Group__c == null ? 'Group 1' : qpw.quoteProdRec.Product_Group__c);
                    groupKey = (qpw.quoteProdRec.Product_Group__c == null ? '' : qpw.quoteProdRec.Product_Group__c);
                }
                //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'DEBUG ::: qpw.assetRec.Id: '+qpw.assetRec.Id + ':: '+qpw.assetRec.Product_Group__c));
            }
            else
            {
                if (groupSize == 1  || groupSize == 0)
                {
                    // No existing groups (single, un-named group), add non-groupable products to this group as well
                    groupKey = '';
                }
                else
                {
                    // Existing, named groups. Add non-groupable products to 'Standalone' group
                    // Note: Don't use dashes ('-') in the below group name until the key separator for pricing results has been changed!
                    groupKey = 'Standalone';
                }
            }
            
            System.debug('====> groupKey: ' + groupKey);
            
            if (groupedQpwMap.containsKey(groupKey))
            {
                List<QuoteProductWrapper> wrap = groupedQpwMap.get(groupKey);
                qpw.quoteProdRec.Product_Group__c = groupKey;
                wrap.add(qpw);
                wrap.sort();
            }
            else
            {
                qpw.quoteProdRec.Product_Group__c = groupKey;
                List<QuoteProductWrapper> wrapMap = new List<QuoteProductWrapper>{qpw};
                 
                groupedQpwMap.put(groupKey, wrapMap);
            }
        }
        System.debug('::::groupedMap keyset' + groupedQpwMap.keySet());
        
        if (groupedQpwMap.size() == 0)
            groupedQpwMap.put('', new List<QuoteProductWrapper>());
    }
    
    /**
     * @description  Renames a group and all of its associated products' group names
     *
     * @author Nathan Shinn
     * @since  26.July.2014
     */
    public PageReference renameGroup()
    {
        activeGroup = ApexPages.currentPage().getParameters().get('oldGroupName');
        string newGroupName = ApexPages.currentPage().getParameters().get('newGroupName');
        if(activeGroup == newGroupName)
            return null;
            
        if(groupedQpwMap.containsKey(newGroupName)) 
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'The Group Name, "'+newGroupName+'" is already in use.'));
            return null;
        }
        list<QuoteProductWrapper> wrappers = groupedQpwMap.get(activeGroup);
        list<QuoteProductWrapper> qpToRename = new list<QuoteProductWrapper>();
        
        for (QuoteProductWrapper qpw : wrappers)
        {
            if (qpw.assetRec == null || qpw.assetRec.Id == null )
            {
                
                
                //rename the quote product's group
                qpw.quoteProdRec.Product_Group__c = newGroupName;
                
                //collect the newly named products to be added to the new group
                qpToRename.add(qpw);
                
                //remove the old quote product map
                qpwMap.remove(getQPWMapKey(qpw.quoteProdRec.Product__c, activeGroup));
                
                //add the newly named product instance to the map with a new key
                qpwMap.put(getQPWMapKey(qpw.quoteProdRec.Product__c, newGroupName),qpw);

                
            }
            else
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'This Group contains existing assets and cannot be renamed.'));
                return null;
            }
        }
        populateListsAndPrice();
        return null;
    }
    
    /**
     * @description  Deletes a group and all of its associated products
     *
     * @author Nathan Shinn
     * @since  26.April.2014
     */
    public PageReference deleteGroup()
    {
        activeGroup = ApexPages.currentPage().getParameters().get('group');
        list<QuoteProductWrapper> wrappers = groupedQpwMap.get(activeGroup);
        list<VCG_CPQ_Quote_Product__c> qpToDelete = new list<VCG_CPQ_Quote_Product__c>();
        set<String> qpMapKeysToRemove = new set<String>();
        for (QuoteProductWrapper qpw : wrappers)
        {
            if (qpw.assetRec == null || qpw.assetRec.Id == null )
            {
                //collect the existing quote product records to remove from the database
                if (qpw.quoteProdRec.Id != null)
                    qpToDelete.add(new VCG_CPQ_Quote_Product__c(Id = qpw.quoteProdRec.Id));
                //collect the map keys used to remove quote products from the qpMap
                qpMapKeysToRemove.add(qpw.quoteProdRec.Product__c+activeGroup);
                
            }
            else
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'This Group contains existing assets and cannot be deleted.'));
                return null;
            }
        }
        
        //remove the quote products from the map
        for (String key : qpMapKeysToRemove)
        {
            for (Integer i = 0; i < newQuoteProductList.size(); i++)
            {
                if (newQuoteProductList[i] == qpwMap.get(key).quoteProdRec)
                    newQuoteProductList.remove(i);
            }
            
            for (Integer i = 0; i < qpwList.size(); i++)
            {
                if (qpwList[i] == qpwMap.get(key))
                    qpwList.remove(i);
            }
            
            qpwMap.remove(key);
        }
        
        //delete the persisted quote products
        if (qpToDelete.size() > 0)
            delete qpToDelete;
        
        //remove the group
        groupedQpwMap.remove(activeGroup);
        
        populateListsAndPrice();
        return null;
        
    }
    
    
    
    /**
     * @description  getPricingResults method to associate Quote Product record 
                     with appropriate pricing result in memory 
     *
     * @author Vishal Shanbhag
     * @since   6.June.2014
     */
/*      public void getPricingResults(){
        
        Map<id,VCG_CPQ_Quote_Product__c> Product2toQProdtMap = new Map<Id,VCG_CPQ_Quote_Product__c>();
        Map<String,List<VCG_CPQ_Quote_Product_Pricing_Result__c>> ModifiedPricingResultsMap = new Map<String,List<VCG_CPQ_Quote_Product_Pricing_Result__c>>();
        Map<String,ID> ProductNameToIDMap = new Map<String,ID>();
        Set<VCG_CPQ_Quote_Product__c> QPRecSet = new Set<VCG_CPQ_Quote_Product__c>();
       
        for (QuoteProductWrapper qpw : qpwList) 
        {   
            // If there is an existing quote record
            if (qpw.quoteProdRec != null && qpw.quoteProdRec.Line_Type__c != null)
            { 
                QPRecSet.add(qpw.quoteProdRec);
            }
            // If there is a Renewal Record
            if (qpw.renewalQuoteProdRec != null)
            {
                qpw.renewalQuoteProdRec.Name = qpw.productRec.ProductCode;
                qpw.renewalQuoteProdRec.Line_Type__c = 'Renewal';
                
                QPRecSet.add(qpw.renewalQuoteProdRec);
            }
        }
    /*
        for (BundleWrapper bundle : configBundles.values())
        {
            if (bundle.bundledQuoteProds != null)
            {
                for (VCG_CPQ_Quote_Product__c quoteProd : bundle.bundledQuoteProds) 
                {
                    
                        QPRecSet.add(quoteProd);                          
                      
               }
            }
        }
        for (BundleWrapper bundle : assetBundles.values())
        {
            if (bundle.bundledQuoteProds != null)
            {
                for (VCG_CPQ_Quote_Product__c quoteProd : bundle.bundledQuoteProds) 
                { 
                    QPRecSet.add(quoteProd);                         
                        
                }
            }
        }
    */
/*        
        if (pricingResultsMap.size()> 0 && pricingResultsMap !=null)
        {
            System.debug('QPRecSet in after filling up records' + QPRecSet);
            if (QPRecSet.size()>0 && QPRecSet != null)
            {
                for (VCG_CPQ_Quote_Product__c quoteProd1: QPRecSet)
                {
                    Product2toQProdtMap.put(quoteProd1.product__c,quoteProd1);
                }
            }
             
            if (Product2toQProdtMap.size()>0 && Product2toQProdtMap != null)
            {  
                for (Product2 SelectedPdtLst : [SELECT ID, Name FROM Product2 WHERE ID IN :Product2toQProdtMap.keyset()])
                {
                  ProductNameToIDMap.put(SelectedPdtLst.Name,SelectedPdtLst.ID);
                }
            }
             
            if (!ProductNameToIDMap.isEmpty())
            {               
                System.debug('m here in the if condition');         
                for (String PdtName : pricingResultsMap.keySet())
                {   
                    String ProdName = PdtName.split('-')[2];
                    if (ProductNameToIDMap.containsKey(ProdName))
                    {
                        for (VCG_CPQ_Quote_Product_Pricing_Result__c pricingResult : pricingResultsMap.get(PdtName) )
                        {
                            pricingResult.Quote_Product__r = Product2toQProdtMap.get(ProductNameToIDMap.get(ProdName));
                            System.debug('temporary rwsult wrapper '+ pricingResult.Quote_Product__r);
                            if (!ModifiedPricingResultsMap.containsKey(PdtName))
                            {
                                ModifiedPricingResultsMap.put(PdtName, new List<VCG_CPQ_Quote_Product_Pricing_Result__c>());
                                
                            }
                            ModifiedPricingResultsMap.get(PdtName).add(pricingResult); 
                        }
                        
                    }  
                }
                pricingResultsMap = (ModifiedPricingResultsMap).clone();      
                System.debug('>>>pricing result map keys after associating quote product record: ' + pricingResultsMap.keySet());
                System.debug('>>>pricing result map after associating quote product record: ' + pricingResultsMap);
//                if (pricingResultsMap.size()>0)
//                    getExistingPricingOverride();
            }
        }
    }
*/    
    /**
     * @description  getPricingResultsList method to get the pricing result list from the prising result            
                     wrapper map 
     *
     * @author Vishal Shanbhag
     * @since   10.June.2014
     */
    public List<VCG_CPQ_Quote_Product_Pricing_Result__c> getPricingResultsList( Map<String,List<VCG_CPQ_Quote_Product_Pricing_Result__c>> pricingResultsMap)
    {
        List<VCG_CPQ_Quote_Product_Pricing_Result__c> pricingResultsList = new List<VCG_CPQ_Quote_Product_Pricing_Result__c>();
        
        if (pricingResultsMap.size() > 0)
        {
            for (String strKey : pricingResultsMap.keyset())
            {
                pricingResultsList.addAll(pricingResultsMap.get(strKey));
                
//              for (VCG_CPQ_Quote_Product_Pricing_Result__c pricingResult : pricingResult.get(strKey))
//              {
//                  pricingResultsList.add(pricingResult);
//              }
            }
            
            return pricingResultsList;
        }
        else return null;
     }
     
     /**
     * @description  getExistingPricingOverride Method to get the existing pricing override records and associate them with 
                     pricing results
     *               Call on edit existing quote only
     *
     * @author Vishal Shanbhag
     * @since   11.June.2014
     */
     public void getExistingPricingOverride()
     {
//      if (quote.Id !=null && isPricingOverrideQuery)
//      {
            for (VCG_CPQ_Pricing_Override__c pricingOverride : [SELECT Group_Name__c
                                                                  ,Line_Type__c
                                                                  ,Override_Value_Type__c
                                                                  ,Override_Value__c
                                                                  ,Override_Value_Str__c
                                                                  ,Override_Value_Date__c
                                                                  ,Pricing_Procedure_Sequence__c
                                                                  ,Pricing_Procedure_Sequence__r.Access_Sequence__r.Name
                                                                  ,Product__c
                                                                  ,Product__r.Name
                                                                  ,Quote__c
                                                                  FROM VCG_CPQ_Pricing_Override__c WHERE Quote__c = :quote.Id])
            {
                /** @todo Use PricingUtility.getOverrideKey() to generate the key (or a similar function if needed) .. so we can hide and standardize the key generation code. */
                //String overrideKey = getOverrideKey(quoteProduct, ppSequence); // quoteProduct.Product_Group__c + '-' + quoteProduct.Line_Type__c + '-' + quoteProduct.Product__r.Name + '-' + ppSequence.Id;
                
                String key = (pricingOverride.Group_Name__c == null ? '' : pricingOverride.Group_Name__c)
                              + '-' + pricingOverride.Line_Type__c 
                              + '-' + pricingOverride.Product__r.Name
                              + '-' + pricingOverride.Pricing_Procedure_Sequence__c;
                if (!pricingOverrideMap.containsKey(key))
                {
                    pricingOverrideMap.put(key, pricingOverride);
                }
            }
/*          if (pricingOverrideMap.size()>0)
            {
                for (String overrideKey : pricingOverrideMap.keySet())
                {
                    String pricingResultsKey = VCG_CPQ_PricingUtility.OverrideKeyToPricingResultsKey(overrideKey);// keyParts[0] + '-' + keyParts[1] + '-' + keyParts[2];
                    System.debug('====> pricingResultsKey: ' + pricingResultsKey);
                    Id ppSequenceId = VCG_CPQ_PricingUtility.getPricingProcedureSequenceIdFromOverrideKey(overrideKey);
                    
                    for (Integer i = 0; i < pricingResultsMap.get(pricingResultsKey).size(); i++)
                    {
                        if (pricingResultsMap.get(pricingResultsKey)[i].Pricing_Procedure_Sequence__c == ppSequenceId)
                        {
//                          pricingResultsMap.get(pricingResultsKey)[i].Result_Value__c = pricingOverrideMap.get(overrideKey).Override_Value__c;
//                          pricingResultsMap.get(pricingResultsKey)[i].Result_Value__c = pricingOverrideMap.get(overrideKey).Override_Value__c;
//                          pricingResultsMap.get(pricingResultsKey)[i].Pricing_Override__c = pricingOverrideMap.get(overrideKey).Id;
//                          pricingResultsMap.get(pricingResultsKey)[i].Pricing_Override__r = pricingOverrideMap.get(overrideKey);
                            System.debug('queried pricing override ' + pricingResultsMap.get(pricingResultsKey)[i]);
                            
//                          pricingOverrideMap.get(overrideKey).Pricing_Result__r = pricingResultsMap.get(pricingResultsKey)[i];
                            
                            isPricingResultOverride = true;
                            overrideCount++;
                        }
                    }
                }
            }
            isPricingOverrideQuery = false; 
*/          
//      }
        
     }
        
    
    //////////////////////////////////////////////////////////////////////////////
    // Script to be used in a batch job to update Quote__c records post deployment
    //////////////////////////////////////////////////////////////////////////////
/*    public static void groupAssets()
    {
        map<Id, list<Asset__c>> accountAssetMap = new map<Id, list<Asset__c>>();
        
        //pull the assets into their respective accounts
        // NOTE: This query will pull all asset records in across the whole org!
        for (Asset__c a : [Select Id, Account__c, Product__c, Product__r.Is_Groupable__c, Product_Group__c from Asset__c])
        {
            if (accountAssetMap.containsKey(a.Account__c))
            {
                list<Asset__c> aList= accountAssetMap.get(a.Account__c);
                aList.add(a);
            }
            else
            {
                accountAssetMap.put(a.Account__c, new list<Asset__c>{a});
            }
        }
        
        list<Asset__c> assetUpdateList = new list<Asset__c>();
        for (Id i : accountAssetMap.keySet())
        {
            map<Id, list<Asset__c>> productAssetMap = new map<Id, list<Asset__c>>();
            for (Asset__c a : accountAssetMap.get(i))
            {
                if (productAssetMap.containsKey(a.Product__c))
                {
                    list<Asset__c> aList= productAssetMap.get(a.Product__c);
                    aList.add(a);
                }
                else
                {
                    productAssetMap.put(a.Product__c, new list<Asset__c>{a});
                }
            }
            
            for (Id ii : productAssetMap.keySet())
            {
                Integer x = 1;
                for (Asset__c asset : productAssetMap.get(ii))
                {
                    string groupName = '';
                    if (asset.Product__r.Is_Groupable__c)
                    {
                        groupName = 'Group '+x;
                        x++;
                    }
                    else
                    {
                        // Note: Don't use dashes ('-') in the below group name until the key separator for pricing results has been changed!
                        groupName = 'Standalone';
                    }
                
                    
                    asset.Product_Group__c = groupName;
                    assetUpdateList.add(asset);
                }
            }
        }
        
        if (assetUpdateList.size() > 0)
            update assetUpdateList;
        
    }
*/    
    
    ///////////////////
    // Output Methods
    
    /**
     * @description  Export quote to Word ... save quote then pass to Drawloop
     *
     * @author  Lawrence Coffin <lawrence.coffin@cloudsherpas.com>
     * @since   22.Jul.2014
     */
    public PageReference exportWord()
    {
        if (getCanAccessExportWord())
        {
            // First save the Quote
            PageReference pRef = save();
            
            if (pRef != null)
            {
                // Now, send them to the Word Doc generation page
                // For OMNI, we want: window.location = "{!$Site.Prefix}/apex/loop__looplus?sessionId={!$Api.Session_ID}&eid={!Object.Id}&contactId={!Object.ContactId}&accountId={!Object.AccountId}&retURL={!URLENCODE($Site.Prefix & '/â€˜ & Object.Id)}";
                return new PageReference('/apex/loop__looplus?'
                                            + 'sessionId=' + UserInfo.getSessionId()
                                            + '&eid=' + quote.Id
                                            + '&accountId=' + quote.Account__c
                                            + '&contactid=' + quote.Contact__c
                                            + '&retURL=/' + quote.Id);
            }
        }
        
        return null;
    }
    
    /**
     * @description  Export quote to PDF ... save quote then pass to Drawloop
     *
     * @author  Lawrence Coffin <lawrence.coffin@cloudsherpas.com>
     * @since   22.Jul.2014
     */
    public PageReference exportPDF()
    {
        if (getCanAccessExportPDF())
        {
            // First save the Quote
            PageReference pRef = save();
            
            if (pRef != null)
            {
                // Now, send them to the PDF generation page
                // For OMNI, we want: /apex/loop__looplus?sessionId={!$Api.Session_ID}&eid={!VCG_CPQ_Quote__c.Id}&accountId={!VCG_CPQ_Quote__c.AccountId__c}&contactid={!VCG_CPQ_Quote__c.ContactId__c}
                return new PageReference('/apex/loop__looplus?'
                                            + 'sessionId=' + UserInfo.getSessionId()
                                            + '&eid=' + quote.Id
                                            + '&accountId=' + quote.Account__c
                                            + '&contactid=' + quote.Contact__c
//                                            + '&autorun=true' // &header=false&sidebar=false
//                                            + '&ddpIds=a0gf0000002oiii'
                                            );
            }
        }
        
        return null;
    }
    
    /**
     * @description  Export quote to Excel ... save quote then pass to Drawloop
     *
     * @author  Lawrence Coffin <lawrence.coffin@cloudsherpas.com>
     * @since   22.Jul.2014
     */
    public PageReference exportExcel()
    {
        if (getCanAccessExportExcel())
        {
            // First save the Quote
            PageReference pRef = save();
            
            if (pRef != null)
            {
                // Now, send them to the Excel generation page
                return new PageReference('/apex/loop__looplus?'
                                            + 'sessionId=' + UserInfo.getSessionId()
                                            + '&eid=' + quote.Id
                                            + '&accountId=' + quote.Account__c
                                            + '&autorun=true' // &header=false&sidebar=false
                                            + '&ddpIds=a0gf0000002oiiJ');
            }
        }
        
        return null;
    }
    
    ///////////////////
    // Security Methods
    public boolean getCanAccessPricingResults()
    {
        return VCG_CPQ_Quote_Security_Utility.getUserAccess(UserAccessRestrictions,'View Pricing Results');
    }
    
    public boolean getCanAccessExportExcel()
    {
        return VCG_CPQ_Quote_Security_Utility.getUserAccess(UserAccessRestrictions,'Export to Excel');
    }
    
    public boolean getCanAccessExportPDF()
    {
        return VCG_CPQ_Quote_Security_Utility.getUserAccess(UserAccessRestrictions,'Export to PDF');
    }
    
    public boolean getCanAccessExportWord()
    {
        return VCG_CPQ_Quote_Security_Utility.getUserAccess(UserAccessRestrictions,'Export to Word');
    }
    
    /** @todo Remove this. Should have been OverridePricingResults. Editing fields handled by FLS (except for __d fields) */
/*    public boolean getCanEditPricingValue()
    {
        return true;
    }
*/    
    public boolean getCanOverridePricingResults()
    {
        return VCG_CPQ_Quote_Security_Utility.getUserAccess(UserAccessRestrictions,'Override Pricing Results');
    }
    
    public boolean getCanEditUpliftPercent()
    {
        return VCG_CPQ_Quote_Security_Utility.getUserAccess(UserAccessRestrictions,'Edit Uplift');
    }
    
    
    public boolean CanEdit(String fieldName)
    {
        if (fieldName.endsWith('__d'))
        {
            String fieldBaseName = fieldName.replace('__d', '').replace('_', ' ');
            return VCG_CPQ_Quote_Security_Utility.getUserAccess(UserAccessRestrictions,'Edit ' + fieldBaseName);
        }
        
        return false;
    }
    
    
    public boolean getCanCreateProductGroups()
    {
        return VCG_CPQ_Quote_Security_Utility.getUserAccess(UserAccessRestrictions,'Create Product Groups');
    }
    
    /////////////////////////////////////
    // Product Group Directory Function
/*    public class ProductFolder
    {
        public boolean          isExpanded{get;set;}
        public string           folder{get;set;}
        public Integer          margin{get;set;}
        public list<ProductFamilyWrapper>   products{get;set;}
    }
//    public void createProductDirectory()
//    {
/*      productGroupDirectory = new map<string, ProductFolder>();
        for(AggregateResult p : [select max(Family) Family
                                       , Group_Directory__c
                                    from Product2
                                   where isActive = true
                                     and Group_Directory__c != null
                                   group by Group_Directory__c ]) 
         {
            String groupDirectory = (String)p.get('Group_Directory__c');
            string family = (String)p.get('Family');
            if(productGroupDirectory.containsKey(groupDirectory))
            {
                ProductFolder pf = productGroupDirectory.get(groupDirectory);
                pf.products.add(new ProductFamilyWrapper(false,family));
            }
            else
            {
                list<string> dierctoryStructure = groupDirectory.split('|');
                ProductFolder pf = new ProductFolder();
                //generate the folder name with indentation
                string indentation = '';
                /*for(Integer i = 0; i<dierctoryStructure.size(); i++)
                {
                    indentation += '&nbsp;&nbsp;';
                }*/
/*              pf.margin = dierctoryStructure.size()*4;
                pf.folder = indentation + dierctoryStructure[dierctoryStructure.size()-1];//last element in the structure
                pf.isExpanded = false;
                pf.products = new list<ProductFamilyWrapper>{new ProductFamilyWrapper(false,family)};
                productGroupDirectory.put(groupDirectory, pf);
            }
         }
*/ 
//    }
/*    
    public PageReference expandProductFolder()
    {
        string directoryKey = ApexPages.currentPage().getParameters().get('directory');
        productFolder pf = productGroupDirectory.get(directoryKey);
        if(pf.isExpanded == false)
            pf.isExpanded = true;
        else
            pf.isExpanded = false;
            
        return null;
    }
    
    public PageReference collapseProductFolder()
    {
        string directoryKey = ApexPages.currentPage().getParameters().get('directory');
        productFolder pf = productGroupDirectory.get(directoryKey);
        pf.isExpanded = false;
        return null;
    }
*/  
}