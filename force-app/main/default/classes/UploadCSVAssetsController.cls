public with sharing class UploadCSVAssetsController {
    public String documentName {get;set;}
    public Blob csvFileBody{get;set;}
    public String[] assetDataLines {get;set;}
    public List < AssetData > aDataList {get;set;}
    public List < AssetData > tempDataList {get;set;}
    public boolean readSuccess {get;set;}
    public boolean showOpps {get;set;}
    public boolean showQuotes {get;set;}
    public boolean showGroups {get;set;}
    public boolean showQuoteLines {get;set;}
    public boolean exportToExcel {get;set;}
    public boolean exportQLG {get;set;}
    public List<String> lstFieldNames{get;set;}
    public Map<Id,Account> accountMap {get;set;}
    public String domesticPBId {get;set;}
    public String oppRecordTypeId {get;set;}
    public Map<String, Opportunity> insertOppMap {get;set;}
    public Map<String, SBQQ__Quote__c> insertQuoteMap {get;set;}
    public List<SBQQ__QuoteLine__c> insertQuoteLineList {get;set;}
    public List<SBQQ__QuoteLineGroup__c> qlgList {get;set;}
    public String createByGroup {get;set;}
    
    AssetData aData;
    String assetDataAsString;
    String fieldValue;
    Integer fieldNumber;
    Map < String, Integer > fieldNumberMap = new Map < String, Integer > ();
    Map<String, Product2> productCodeMap = new Map<String,Product2>();
    Map<String, List<AssetData>> assetMap = new Map<String, List<AssetData>>();
    Map<String, SBQQ__ProductOption__c> productOptionMap = new Map<String, SBQQ__ProductOption__c>();
    Set<Id> quoteSet = new Set<Id>();
    Set<String> wrapperSet = new Set<String>();

    public UploadCSVAssetsController() {
        documentName = '';
        readSuccess = false;
        showOpps = false;
        showQuotes = false;
        showGroups = false;
        showQuoteLines = false;
        exportToExcel = false;
        exportQLG = false;
        assetDataLines = new String[] {};
        aDataList = new List < AssetData > ();
        lstFieldNames = new List<String>();
        accountMap = new Map<Id, Account>();
        insertOppMap = new Map<String, Opportunity>();
        insertQuoteMap = new Map<String,SBQQ__Quote__c>();
        insertQuoteLineList = new List<SBQQ__QuoteLine__c>();
        createByGroup = ApexPages.currentPage().getParameters().get('createByGroup');
    }
    
    public void readFromFile(){
        try{
            assetDataAsString = csvFileBody.toString();
            readCSVFile();
        }
        catch(exception e){
            readSuccess = false;
            showOpps = false;
            showQuotes = false;
            showGroups = false;
            showQuoteLines = false;
            exportToExcel = false;
            ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.Severity.ERROR,'Error reading CSV file');
            ApexPages.addMessage(errorMessage);
        }
    }    
    public void readCSVFile() {
        aDataList.clear();
            assetDataLines = assetDataAsString.split('\n');
            string[] csvFieldNames = assetDataLines[0].split(',');
            for (Integer i = 0; i < csvFieldNames.size(); i++) {
                fieldNumberMap.put(csvFieldNames[i], i);
                lstFieldNames.add(csvFieldNames[i].trim());
            }
            for (Integer i = 1; i < assetDataLines.size(); i++) {
                aData = new AssetData();
                string[] csvRecordData = assetDataLines[i].split(',');
                for (String fieldName: csvFieldNames) {
                    fieldNumber = fieldNumberMap.get(fieldName);
                    fieldValue = csvRecordData[fieldNumber];
                    System.debug('******* fieldName -- '+fieldName+ ' -- '+fieldValue);
                    if(fieldName == 'Account Id'){
                        aData.accountId = fieldValue;
                    }
                    if(fieldName == 'CurrencyCode'){
                        aData.assetCurrency = fieldValue;
                    }
                    if(fieldName == 'Start Date'){
                        aData.startDate = fieldValue;
                    }
                    if(fieldName == 'End Date'){
                        aData.endDate = fieldValue;
                    }
                    if(fieldName == 'Term'){
                        aData.term = fieldValue;
                    }
                    if(fieldName == 'Arr'){
                        aData.arr = fieldValue;
                    }
                    if(fieldName == 'Quantity'){
                        aData.quantity = fieldValue;
                    }
                    
                    if(fieldName == 'Asset Id'){
                        aData.assetId = fieldValue;
                    }
                    if(fieldName == 'sku'){
                        aData.sku = fieldValue;
                    }
                    if(fieldName == 'wrapper'){
                        aData.wrapper = fieldValue;
                        wrapperSet.add(aData.wrapper);
                    }
                    if(fieldName == 'isPerpetual'){
                        aData.isPerpetual = fieldValue;
                    }
                    if(fieldName == 'Maint SKU'){
                        aData.maintSku = fieldValue;
                    }
                    if(fieldName == 'Negotiation Type'){
                        aData.negotiationType = fieldValue;
                    }
                    if(fieldName == 'Maintenance Unit Price'){
                        aData.maintUnitPrice = fieldValue;
                    }
                    if(fieldName == 'Unit Price'){
                        aData.unitPrice = fieldValue;
                    }
                    if(fieldName == 'Group'){
                        aData.mxGroup = fieldValue;
                    }
                }
                aDataList.add(aData);                
            }
            
            if(aDataList.size() > 0){
                readSuccess = TRUE;
                
            } 
                       
      }
     
      public void createOpportunities() {
        try {
               groupAssets();
               System.debug('*********INSERT OPPMAP -- '+insertOppMap.size());
               if(insertOppMap.size() > 0){
                  //InsertQuoteLinesForAssetMigrationBatch  iqlBatch = new InsertQuoteLinesForAssetMigrationBatch(insertOppMap.values()) ;  
                  //database.executebatch(iqlBatch,5);
                  database.insert(insertOppMap.values());
               }
               readSuccess = false;
               showOpps = false;
               showQuotes = true;
               showGroups = false;
               showQuoteLines = false;
               exportToExcel = true;
               ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.severity.INFO, 'Opportunity records inserted successfully');
               ApexPages.addMessage(errorMessage);
        } catch (Exception e) {
               ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.severity.ERROR, e.getStackTraceString());
               ApexPages.addMessage(errorMessage);
        }
      }
    
    public void createQuotes(){
        System.debug('***********CREATEQUOTES');
        String qlKey;
        try{
            for(String oppKey: insertOppMap.keySet()){
                Opportunity iOpp = insertOppMap.get(oppKey);
                insertQuoteMap.get(oppKey).SBQQ__Opportunity2__c = iopp.Id;
                insertQuoteMap.get(oppKey).CurrencyIsoCode = iopp.CurrencyIsoCode;
            }
            System.debug('***********CREATEQUOTES');       
            if(insertQuoteMap.size() > 0){
                qlgList = new List<SBQQ__QuoteLineGroup__c>();
                database.insert(insertQuoteMap.values());
                for(SBQQ__Quote__c  sbq : insertQuoteMap.values()){
                    SBQQ__QuoteLineGroup__c sbqlg = new SBQQ__QuoteLineGroup__c();
                    System.debug('****QLG -- '+sbq.SBQQ__Account__c);
                    sbqlg.SBQQ__Account__c= sbq.SBQQ__Account__c;
                    System.debug('****QLG1 -- '+sbqlg.SBQQ__Account__c);
                    sbqlg.SBQQ__Quote__c = sbq.Id;
                    sbqlg.SBQQ__Number__c = 1; 
                    sbqlg.From_Asset_Migration__c = true;
                    qlgList.add(sbqlg);
                }
            }
            System.debug('***********CREATEQUOTES');  
            showQuotes = false;
            //showGroups = true;
            showQuoteLines = true;
            exportQLG = true;
            ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.severity.INFO, 'Quote records inserted successfully');
            ApexPages.addMessage(errorMessage);
        } catch (Exception e) {
            ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.severity.ERROR, e.getStackTraceString());
            ApexPages.addMessage(errorMessage);
        }
    }
    
    
      
      
      public void createQuoteLines() {
        try {
               System.debug('***********assetMapSize -- '+assetMap.size());
               if(assetMap.size() > 0){
                   for(String aKey : assetMap.KeySet()){
                       List<AssetData> assetList = assetMap.get(aKey);
                       if(assetList.size() > 0){
                           System.debug('********* aKey -- '+aKey);
                           System.debug('********* assetList -- '+assetList.size());
                           Opportunity iOpp = insertOppMap.get(aKey);
                           SBQQ__Quote__c iQuote = insertQuoteMap.get(aKey);
                           Set<String> wrapperQuoteSet = new Set<String>();
                           if(iQuote != null && String.isNotBlank(iQuote.Id)){
                               quoteSet.add(iQuote.Id);
                               for(AssetData aData : assetList){
                                   System.debug('*********aData -- '+aData.sku);
                                   Product2 wProd = productCodeMap.get(aData.wrapper);
                                   Product2 iProd = productCodeMap.get(aData.sku);
                                   Product2 mProd = productCodeMap.get(aData.maintSku);
                                   if(!wrapperQuoteSet.contains(aData.wrapper)){
                                       System.debug('*********aData -- '+aData.wrapper);
                                       SBQQ__QuoteLine__c wql = new SBQQ__QuoteLine__c();
                                       wql.SBQQ__Quote__c = iQuote.Id;
                                       wql.SBQQ__Quantity__c = 1;
                                       if(wProd != null){
                                          wql.SBQQ__Product__c = wProd.Id;
                                       }
                                       wql.SBQQ__Number__c = 1;
                                       wql.From_Asset_Migration__c = true;
                                       wql.isWrapper__c = true;
                                       wql.Business_Unit__c = wProd.Business_Unit__c;
                                       wql.Business_Unit_Wrapper__c = wProd.Business_Unit_Wrapper__c;
                                       wql.Default_Billing_Frequency__c = wProd.Default_Billing_Frequency__c;
                                       wql.Product_Group__c = wProd.Product_Group__c;
                                       wql.Product_Line__c = wProd.Product_Line__c;
                                       wql.Product_Type__c = wProd.Product_Type__c;
                                       wql.License_Type__c = wProd.License_Type__c;
                                       
                                       wrapperQuoteSet.add(aData.wrapper);
                                       insertQuoteLineList.add(wql);
                                   }
                                   if(iProd != null){
                                       SBQQ__QuoteLine__c iql = new SBQQ__QuoteLine__c();
                                       iql.SBQQ__Quote__c = iQuote.Id;
                                       iql.SBQQ__Quantity__c = String.isNotBlank(aData.quantity)?Decimal.valueOf(aData.quantity):0;
                                       iql.SBQQ__Product__c = iProd.Id;
                                       iql.SBQQ__SubscriptionPricing__c = iProd.SBQQ__SubscriptionPricing__c;
                                       
                                       //iql.SBQQ__Product__c = productCodeMap.get(aData.sku);
                                       iql.SBQQ__Number__c = 1;
                                       if(String.isBlank(aData.arr) && String.isNotBlank(aData.unitPrice)){
                                           iql.SBQQ__OriginalPrice__c = Decimal.valueOf(aData.unitPrice);
                                           iql.SBQQ__ListPrice__c = Decimal.valueOf(aData.unitPrice);
                                       }
                                       else{
                                           iql.Migrated_ARR__c = String.isNotBlank(aData.arr)?Decimal.valueOf(aData.arr):null;
                                           String billingFreq = iProd.Default_Billing_Frequency__c;
                                           Integer billingFrequency = 1;
                                           if(String.isNotBlank(billingFreq)){
                                                if(billingFreq == 'Annual' || billingFreq == 'Once' || billingFreq == 'On Demand'){
                                                    billingFrequency = 1;
                                                }
                                                else if(billingFreq == 'Monthly' ){
                                                    billingFrequency = 12;
                                                }
                                                else if(billingFreq == 'Quarterly' ){
                                                    billingFrequency = 4;
                                                }
                                           }
                                           
                                           Decimal munitPrice;
                                           if(iql.Migrated_ARR__C == null){
                                               munitPrice = null;
                                           }
                                           else{
                                               munitPrice = iql.Migrated_ARR__c/(iql.SBQQ__Quantity__c * billingFrequency);
                                           }
                                           iql.SBQQ__OriginalPrice__c = munitPrice;
                                           iql.SBQQ__ListPrice__c = munitPrice;
                                       }
                                       System.debug('****Migrated ARR-- '+iql.Migrated_ARR__c);
                                       iql.From_Asset_Migration__c = true;
                                       iql.Test_Quote_Line_Wrapper__c = aData.wrapper;
                                       iql.Migrate_Contracted_Asset__c = String.isNotBlank(aData.assetId) ? aData.assetId : null;
                                       //String prKey = productCodeMap.get(aData.wrapper) +'-'+iql.SBQQ__Product__c;
                                       String prKey = wProd.Id +'-'+iql.SBQQ__Product__c;
                                       SBQQ__ProductOption__c ipo = productOptionMap.get(prKey);
                                       if(ipo != null){
                                           //iql.Migrated_Product_Option_ID__c = poId;
                                           iql.SBQQ__ProductOption__c = ipo.Id;
                                           iql.SBQQ__OptionType__c  = ipo.SBQQ__Type__c;
                                       }
                                       iql.SBQQ__ProrateMultiplier__c = 1;
                                       iql.Business_Unit__c = iProd.Business_Unit__c;
                                       iql.Business_Unit_Wrapper__c = iProd.Business_Unit_Wrapper__c;
                                       iql.Default_Billing_Frequency__c = iProd.Default_Billing_Frequency__c;
                                       iql.Product_Group__c = iProd.Product_Group__c;
                                       iql.Product_Line__c = iProd.Product_Line__c;
                                       iql.Product_Type__c = iProd.Product_Type__c;
                                       iql.License_Type__c = iProd.License_Type__c;
                                       insertQuoteLineList.add(iql);
                                   }    
                                   if(String.isNotBlank(adata.isPerpetual) && aData.isPerpetual == '1' && 
                                                        String.isNotBlank(aData.maintSku) && aData.maintSku != 'null' && mProd != null){
                                        SBQQ__QuoteLine__c pql = new SBQQ__QuoteLine__c();
                                        pql.SBQQ__Quote__c = iQuote.Id;
                                        pql.SBQQ__Quantity__c = String.isNotBlank(aData.quantity)?Decimal.valueOf(aData.quantity):0;
                                        if(mProd != null){
                                            pql.SBQQ__Product__c = mProd.Id;
                                            pql.SBQQ__SubscriptionPricing__c = mProd.SBQQ__SubscriptionPricing__c;
                                        }
                                        pql.SBQQ__Number__c = 1;
                                        
                                        Decimal munitPrice = String.isNotBlank(aData.maintUnitPrice)?Decimal.ValueOf(aData.maintUnitPrice):null;
                                        pql.SBQQ__OriginalPrice__c = munitPrice;
                                        pql.SBQQ__ListPrice__c = munitPrice;
                                        pql.From_Asset_Migration__c = true;
                                        pql.Test_Quote_Line_Wrapper__c = aData.wrapper;
                                        pql.Migrate_Contracted_Asset__c = String.isNotBlank(aData.assetId) ? aData.assetId : null;
                                        String mprKey = wProd.Id +'-'+pql.SBQQ__Product__c;
                                        SBQQ__ProductOption__c ppo = productOptionMap.get(mprKey);
                                        if(ppo != null){
                                            //pql.Migrated_Product_Option_ID__c = mpoId;
                                            pql.SBQQ__ProductOption__c = ppo.Id;
                                            pql.SBQQ__OptionType__c  = ppo.SBQQ__Type__c;
                                        }
                                        pql.SBQQ__ProrateMultiplier__c = 1;
                                        pql.Business_Unit__c = mProd.Business_Unit__c;
                                        pql.Business_Unit_Wrapper__c = mProd.Business_Unit_Wrapper__c;
                                        pql.Default_Billing_Frequency__c = mProd.Default_Billing_Frequency__c;
                                        pql.Product_Group__c = mProd.Product_Group__c;
                                        pql.Product_Line__c = mProd.Product_Line__c;
                                        pql.Product_Type__c = mProd.Product_Type__c;
                                        pql.License_Type__c = mProd.License_Type__c;
                                        pql.SBQQ__SpecialPriceType__c = 'Maintenance';
                                        /*SBQQ__ProductOption__c mpo = productOptionPerpetualMap.get(iql.SBQQ__Product__c);
                                        pql.SBQQ__Product__c = mpo.SBQQ__OptionalSKU__c;
                                        pql.Migrated_Product_Option_ID__c = mpo.Id;*/
                                        insertQuoteLineList.add(pql);
                                   }
                                   
                               }
                           }
                       }
                   }
               }
               
               if(insertQuoteLineList.size() > 0){
                   ApexCreateCSV acc = new ApexCreateCSV();
                   acc.generate(insertQuoteLineList);
                  /*InsertQuoteLinesForAssetMigrationBatch  iqlBatch = new InsertQuoteLinesForAssetMigrationBatch(insertQuoteLineList) ;  
                  database.executebatch(iqlBatch); */
               }
               readSuccess = false;
               showQuotes = false;
               exportToExcel = true;
               ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.severity.INFO, 'Export Quote Lines and use Data loader to load them');
               ApexPages.addMessage(errorMessage);
        } catch (Exception e) {
               ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.severity.ERROR, e.getStackTraceString());
               ApexPages.addMessage(errorMessage);
        }
      }
            
      private void groupAssets(){
          Set<Id> accountIdSet = new Set<Id>();
          Set<String> productCodeSet = new Set<String>();
          String assetKey;
          //try {
              for(AssetData aData : aDataList){
                  if(aData != null){
                      if(String.isNotBlank(createByGroup) && createByGroup=='Yes' && String.isNotBlank(aData.mxGroup)){
                          assetKey = aData.accountId+'-'+aData.mxGroup; 
                           if(!assetMap.containsKey(assetKey)){
                               assetMap.put(assetKey, new List<AssetData>());
                           }
                           assetMap.get(assetKey).add(aData);
                      }
                      else if(String.isNotBlank(aData.endDate)){
                           assetKey = aData.accountId+'-'+aData.endDate; 
                           if(!assetMap.containsKey(assetKey)){
                               assetMap.put(assetKey, new List<AssetData>());
                           }
                           assetMap.get(assetKey).add(aData);
                      }
                      accountIdSet.add(aData.accountId);
                      if(String.isNotBlank(aData.wrapper)){
                          productCodeSet.add(aData.wrapper);
                      }
                      if(String.isNotBlank(aData.sku)){
                          productCodeSet.add(aData.sku);
                      }
                      if(String.isNotBlank(aData.maintSku) && aData.maintSku != 'null'){
                          productCodeSet.add(aData.maintSku);
                      }
                  }
              }
              if(assetMap.size() > 0){
                accountMap = new Map<Id, Account>([select Id, Name from Account where Id in :accountIdSet]);
                domesticPBId = [select Id,Name from PriceBook2 where Name = 'Domestic PriceBook'].Id;
                oppRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Data Migration').getRecordTypeId();
                Set<Id> productIds = new Set<Id>();
                for(Product2 prod : [select Id, ProductCode, SBQQ__SubscriptionPricing__c, Business_Unit__c, Business_Unit_Wrapper__c, 
                                            Default_Billing_Frequency__c, Product_Group__c, Product_Line__c, Product_Type__c, License_Type__c 
                                       from Product2 where ProductCode in :productCodeSet and isActive=true]){
                    productCodeMap.put(prod.ProductCode, prod);
                    productIds.add(prod.Id);
                }
                
                for(SBQQ__ProductOption__c po : [select Id,SBQQ__ConfiguredSKU__c,SBQQ__OptionalSKU__c,SBQQ__Type__c from SBQQ__ProductOption__c where SBQQ__ConfiguredSKU__c in :productIds]){
                     productOptionMap.put((po.SBQQ__ConfiguredSKU__c+'-'+po.SBQQ__OptionalSKU__c), po);
                     //productOptionPerpetualMap.put(po.SBQQ__ConfiguredSKU__c, po);
                }
                
                for(String aKey : assetMap.KeySet()){
                    List<AssetData> assetList = assetMap.get(aKey);
                    if(assetList.size() > 0){
                        insertOppMap.put(aKey, createOpportunity(assetList.get(0)));
                        SBQQ__Quote__c sbbq = createQuote(assetList.get(0));
                        insertQuoteMap.put(aKey, sbbq);
                    }
                    
                }
               }
               readSuccess = false;
               showOpps = true;
               /*ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.severity.INFO, 'Data has been grouped, continue with Opportunity creation -- '+insertOppMap.size());
               ApexPages.addMessage(errorMessage);
          }catch (Exception e) {
              ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.severity.ERROR, e.getStackTraceString());
              ApexPages.addMessage(errorMessage);
          }*/
             
      }
      
    
    
    
       private Opportunity createOpportunity(AssetData cAsset){
        Opportunity opp = new Opportunity();
        Account accnt = accountMap.get(cAsset.accountId);
     
        String oppName = 'Migration - '+accnt.name+' - '+cAsset.endDate;
        oppName = (oppName.length() >= 99) ? oppName.subString(0,99):oppName;
        opp.Name = oppName;
        opp.AccountId = cAsset.AccountId;
        opp.RecordTypeID = oppRecordTypeId;
        opp.Type = 'Existing Customer';
        opp.StageName = 'Sales Complete';
        opp.Order_Type__c = 'New';
        opp.Forecast_Category__c = 'Pipeline';
        opp.CurrencyIsoCode = cAsset.assetCurrency; 
        opp.CloseDate = Date.Today(); 
        opp.Pricebook2Id = domesticPBId;
        if(String.isNotBlank(cAsset.negotiationType)){
            opp.Negotiation_Type__c = cAsset.negotiationType;  
        }
        //opp.MIBOS_Migration_Name__c= cAsset.endDate;
        return opp;
     }
     
     private SBQQ__Quote__c createQuote(AssetData cAsset){
        SBQQ__Quote__c iQuote = new SBQQ__Quote__c();
        iQuote.CurrencyIsoCode = cAsset.assetCurrency;
        iQuote.SBQQ__Account__c = cAsset.AccountId;
        iQuote.SBQQ__Type__c = 'Quote';
        iQuote.SBQQ__PaymentTerms__c = 'Net 30';//Confirm with Rick
        iQuote.SBQQ__StartDate__c = Date.parse(cAsset.startDate);
        iQuote.SBQQ__EndDate__c = Date.parse(cAsset.endDate);
        iQuote.SBQQ__SubscriptionTerm__c = integer.valueof(cAsset.term);
        iQuote.SBQQ__Status__c = 'Signed';
        iQuote.ApprovalStatus__c = 'Approved';
        iQuote.From_Asset_Migration__c = true;
        iQuote.SBQQ__Primary__c = true;
        iQuote.SBQQ__LineItemsGrouped__c = true;        
        return iQuote;
     }
     
     
      public class AssetData{
          public AssetData(){
          }
          
          public String accountId {get;set;}
          public String assetcurrency {get;set;}
          public String startDate {get;set;}
          public String endDate {get;set;}
          public String term {get;set;}
          public String quantity {get;set;}
          public String arr {get;set;}
          public String assetId {get;set;}
          public String sku {get;set;}
          public String wrapper {get;set;}
          public String isPerpetual {get;set;}
          public String maintSku {get;set;}
          public String negotiationType {get;set;}
          public String maintUnitPrice {get;set;}
          public String unitPrice {get;set;}
          public String mxGroup {get;set;}
      } 
}