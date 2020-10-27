global class OppQuoteMigrationScheduler  implements Database.Batchable<sObject>{
    global final String Query;
    global final Boolean groupByGroup;
    global final Integer batch;
    
    global OppQuoteMigrationScheduler(String q, Boolean grpByGroup, Integer batchNuber){
        query = q;
        groupByGroup = grpByGroup;
        batch = batchNuber;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC,List<Account> scope){
       Set<Id> accountIdSet = new Set<Id>();
       Set<String> productCodeSet = new Set<String>();
       Map<String, List<Migrated_Asset_Data__c>> assetMap = new Map<String, List<Migrated_Asset_Data__c>>();
       Map<String, SBQQ__ProductOption__c> productOptionMap = new Map<String, SBQQ__ProductOption__c>();
       Set<Id> quoteSet = new Set<Id>();
       Set<String> wrapperSet = new Set<String>();
       Map < String, Integer > fieldNumberMap = new Map < String, Integer > ();
       Map<String, Product2> productCodeMap = new Map<String,Product2>();
       Map<Id,Account> accountMap = new Map<Id,Account>();
       Map<String, Opportunity> insertOppMap = new Map<String, Opportunity>();
       Map<String, SBQQ__Quote__c> insertQuoteMap = new Map<String, SBQQ__Quote__c>();
       List<Migrated_Quote_Line__c> insertQuoteLineList = new List<Migrated_Quote_Line__c>();
       List<Migrated_QLG__c> qlgList = new List<Migrated_QLG__c>();
       List<Migrated_Exceptions__c> migratedExceptionsList = new List<Migrated_Exceptions__c>();

       String domesticPBId = [select Id,Name from PriceBook2 where Name = 'Domestic PriceBook'].Id;
       String oppRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Data Migration').getRecordTypeId();
       String assetKey;
       
       //try{
       for(Account accnt : scope){
           if(accnt.Migrate_Asset_Data__r != null && accnt.Migrate_Asset_Data__r.size() > 0){
               for(Migrated_Asset_Data__c aData : accnt.Migrate_Asset_Data__r){
                    if(groupByGroup){
                        assetKey = aData.Account_ID__c+'-'+aData.group__c; 
                        if(!assetMap.containsKey(assetKey)){
                            assetMap.put(assetKey, new List<Migrated_Asset_Data__c>());
                        }
                        assetMap.get(assetKey).add(aData);
                    }
                    else if(aData.end_Date__c != null){
                        assetKey = aData.Account_ID__c+'-'+aData.end_Date__c; 
                        if(!assetMap.containsKey(assetKey)){
                            assetMap.put(assetKey, new List<Migrated_Asset_Data__c>());
                        }
                        assetMap.get(assetKey).add(aData);
                    }
                    accountIdSet.add(aData.Account_ID__c);
                    if(String.isNotBlank(aData.wrapper__c)){
                        productCodeSet.add(aData.wrapper__c);
                    }
                    if(String.isNotBlank(aData.sku__c)){
                        productCodeSet.add(aData.sku__c);
                    }
                    if(String.isNotBlank(aData.Maintenance_SKU__c)){
                        productCodeSet.add(aData.Maintenance_SKU__c);
                    }
               }
           }
       }
       
       if(assetMap.size() > 0){
           accountMap = new Map<Id, Account>([select Id, Name from Account where Id in :accountIdSet]);
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
                List<Migrated_Asset_Data__c> assetList = assetMap.get(aKey);
                if(assetList.size() > 0){
                    insertOppMap.put(aKey, createOpportunity(assetList.get(0), oppRecordTypeId, domesticPBId, accountMap));
                    SBQQ__Quote__c sbbq = createQuote(assetList.get(0));
                    insertQuoteMap.put(aKey, sbbq);
                }
                    
           }
      }
       
      if(insertOppMap.size() > 0){
           try{
                database.insert(insertOppMap.values());
           }catch(Exception e){
                Migrated_Exceptions__c me = new Migrated_Exceptions__c(List_ids__c=String.valueof(insertOppMap.keySet()), Exception_Message__c = e.getMessage(), Exception_StackTrace__c = e.getStackTraceString());
                migratedExceptionsList.add(me);
           }
           //System.debug('************************* Inserting Opportunities -- ');
           String rKey;
           String qlKey;
           for(String oppKey: insertOppMap.keySet()){
                Opportunity iOpp = insertOppMap.get(oppKey);
                if(iOpp != null){
                    insertQuoteMap.get(oppKey).SBQQ__Opportunity2__c = iopp.Id;
                    insertQuoteMap.get(oppKey).CurrencyIsoCode = iopp.CurrencyIsoCode;
                }
           }
           
           if(insertQuoteMap.size() > 0){
                System.debug('************************* insertQuoteMap after -- '+insertQuoteMap);
                qlgList = new List<Migrated_QLG__c>();
                try{
                    database.insert(insertQuoteMap.values());
                }catch(Exception e){
                       Migrated_Exceptions__c me = new Migrated_Exceptions__c(List_ids__c=String.valueOf(insertQuoteMap.keySet()), Exception_Message__c = e.getMessage(), Exception_StackTrace__c = e.getStackTraceString());
                       migratedExceptionsList.add(me);
                   }
                
                for(SBQQ__Quote__c  sbq : insertQuoteMap.values()){
                    Migrated_QLG__c sbqlg = new Migrated_QLG__c();
                    sbqlg.SBQQ_Account__c= sbq.SBQQ__Account__c;
                    sbqlg.SBQQ_Quote__c = sbq.Id;
                    sbqlg.SBQQ_Number__c = 1; 
                    sbqlg.From_Asset_Migration__c = true;
                    sbqlg.Batch__c = batch;
                    qlgList.add(sbqlg);
                }
               
               if(qlgList.size() > 0){
                   try{
                       database.insert(qlgList);
                   }catch(Exception e){
                       Migrated_Exceptions__c me = new Migrated_Exceptions__c(List_ids__c=String.valueOf(qlgList), Exception_Message__c = e.getMessage(), Exception_StackTrace__c = e.getStackTraceString());
                       migratedExceptionsList.add(me);
                   }
               }
           }
        }
        
        
        try {
               System.debug('***********assetMapSize -- '+assetMap.size());
               if(assetMap.size() > 0){
                   for(String aKey : assetMap.KeySet()){
                       List<Migrated_Asset_Data__c> assetList = assetMap.get(aKey);
                       if(assetList.size() > 0){
                           System.debug('********* aKey -- '+aKey);
                           System.debug('********* assetList -- '+assetList.size());
                           Opportunity iOpp = insertOppMap.get(aKey);
                           SBQQ__Quote__c iQuote = insertQuoteMap.get(aKey);
                           Set<String> wrapperQuoteSet = new Set<String>();
                           if(iQuote != null && String.isNotBlank(iQuote.Id)){
                               quoteSet.add(iQuote.Id);
                               for(Migrated_Asset_Data__c aData : assetList){
                                   Product2 wProd = productCodeMap.get(aData.wrapper__c);
                                   Product2 iProd = productCodeMap.get(aData.sku__c);
                                   Product2 mProd = productCodeMap.get(aData.Maintenance_SKU__c);
                                   if(!wrapperQuoteSet.contains(aData.wrapper__c)){
                                       System.debug('*********aData -- '+aData.wrapper__c);
                                       Migrated_Quote_Line__c wql = new Migrated_Quote_Line__c();
                                       wql.SBQQ_Quote__c = iQuote.Id;
                                       wql.SBQQ_Quantity__c = 1;
                                       if(wProd != null){
                                          wql.SBQQ_Product__c = wProd.Id;
                                       }
                                       wql.SBQQ_Number__c = 1;
                                       wql.From_Asset_Migration__c = true;
                                       wql.isWrapper__c = true;
                                       wql.Business_Unit__c = wProd.Business_Unit__c;
                                       wql.Business_Unit_Wrapper__c = wProd.Business_Unit_Wrapper__c;
                                       wql.Default_Billing_Frequency__c = wProd.Default_Billing_Frequency__c;
                                       wql.Product_Group__c = wProd.Product_Group__c;
                                       wql.Product_Line__c = wProd.Product_Line__c;
                                       wql.Product_Type__c = wProd.Product_Type__c;
                                       wql.License_Type__c = wProd.License_Type__c;
                                       wql.Batch__c = batch;
                                       wql.SBQQ_OptionLevel__c = '1';
                                       
                                       wrapperQuoteSet.add(aData.wrapper__c);
                                       insertQuoteLineList.add(wql);
                                   }
                                   if(iProd != null){
                                       Migrated_Quote_Line__c iql = new Migrated_Quote_Line__c();
                                       iql.SBQQ_Quote__c = iQuote.Id;
                                       iql.SBQQ_Quantity__c = aData.quantity__c;
                                       iql.SBQQ_Product__c = iProd.Id;
                                       iql.SBQQ_SubscriptionPricing__c = iProd.SBQQ__SubscriptionPricing__c;
                                       iql.SBQQ_OptionLevel__c = '1';
                                       //iql.SBQQ__Product__c = productCodeMap.get(aData.sku);
                                       iql.SBQQ_Number__c = 1;
                                       if(aData.arr__c == null && aData.unit_Price__c != null){
                                           iql.SBQQ_OriginalPrice__c = aData.unit_Price__c;
                                           iql.SBQQ_ListPrice__c = aData.unit_Price__c;
                                       }
                                       else{
                                           iql.Migrated_ARR__c = aData.arr__c;
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
                                           
                                           Decimal unitPrice;
                                           /*if(iql.Migrated_ARR__C == 0 && String.isNotBlank(aData.nonRecRevenue) && aData.nonRecRevenue != '0'){
                                               unitPrice = Decimal.valueOf(aData.nonRecRevenue);
                                               billingFrequency = 1;
                                           }
                                           else{*/
                                           
                                               unitPrice = iql.Migrated_ARR__c/iql.SBQQ_Quantity__c;
                                          // }
                                           iql.SBQQ_OriginalPrice__c = unitPrice/billingFrequency;
                                           iql.SBQQ_ListPrice__c = unitPrice/billingFrequency;
                                       }
                                       System.debug('****Migrated ARR-- '+iql.Migrated_ARR__c);
                                       iql.From_Asset_Migration__c = true;
                                       iql.Test_Quote_Line_Wrapper__c = aData.wrapper__c;
                                       iql.Migrate_Contracted_Asset__c = aData.Asset_Id__c;
                                       //String prKey = productCodeMap.get(aData.wrapper) +'-'+iql.SBQQ__Product__c;
                                       String prKey = wProd.Id +'-'+iql.SBQQ_Product__c;
                                       SBQQ__ProductOption__c ipo = productOptionMap.get(prKey);
                                       if(ipo != null){
                                           //iql.Migrated_Product_Option_ID__c = poId;
                                           iql.SBQQ_ProductOption__c = ipo.Id;
                                           iql.SBQQ_OptionType__c  = ipo.SBQQ__Type__c;
                                       }
                                       iql.SBQQ_ProrateMultiplier__c = 1;
                                       iql.Business_Unit__c = iProd.Business_Unit__c;
                                       iql.Business_Unit_Wrapper__c = iProd.Business_Unit_Wrapper__c;
                                       iql.Default_Billing_Frequency__c = iProd.Default_Billing_Frequency__c;
                                       iql.Product_Group__c = iProd.Product_Group__c;
                                       iql.Product_Line__c = iProd.Product_Line__c;
                                       iql.Product_Type__c = iProd.Product_Type__c;
                                       iql.License_Type__c = iProd.License_Type__c;
                                       iql.Batch__c = batch;
                                       insertQuoteLineList.add(iql);
                                   }    
                                   if(aData.isPerpetual__c && String.isNotBlank(aData.Maintenance_SKU__c) && aData.Maintenance_SKU__c!= 'null' && mProd != null){
                                        Migrated_Quote_Line__c pql = new Migrated_Quote_Line__c();
                                        pql.SBQQ_Quote__c = iQuote.Id;
                                        pql.SBQQ_Quantity__c = aData.quantity__c;
                                        pql.SBQQ_OptionLevel__C = '1';
                                        if(mProd != null){
                                            pql.SBQQ_Product__c = mProd.Id;
                                            pql.SBQQ_SubscriptionPricing__c = mProd.SBQQ__SubscriptionPricing__c;
                                        }
                                        pql.SBQQ_Number__c = 1;
                                        
                                        Decimal munitPrice = aData.Maintenance_Unit_Price__c;
                                        pql.SBQQ_OriginalPrice__c = munitPrice;
                                        pql.SBQQ_ListPrice__c = munitPrice;
                                        pql.From_Asset_Migration__c = true;
                                        pql.Test_Quote_Line_Wrapper__c = aData.wrapper__c;
                                        pql.Migrate_Contracted_Asset__c = aData.asset_Id__c;
                                        String mprKey = wProd.Id +'-'+pql.SBQQ_Product__c;
                                        SBQQ__ProductOption__c ppo = productOptionMap.get(mprKey);
                                        if(ppo != null){
                                            //pql.Migrated_Product_Option_ID__c = mpoId;
                                            pql.SBQQ_ProductOption__c = ppo.Id;
                                            pql.SBQQ_OptionType__c  = ppo.SBQQ__Type__c;
                                        }
                                        pql.SBQQ_ProrateMultiplier__c = 1;
                                        pql.Business_Unit__c = mProd.Business_Unit__c;
                                        pql.Business_Unit_Wrapper__c = mProd.Business_Unit_Wrapper__c;
                                        pql.Default_Billing_Frequency__c = mProd.Default_Billing_Frequency__c;
                                        pql.Product_Group__c = mProd.Product_Group__c;
                                        pql.Product_Line__c = mProd.Product_Line__c;
                                        pql.Product_Type__c = mProd.Product_Type__c;
                                        pql.License_Type__c = mProd.License_Type__c;
                                        pql.SBQQ_SpecialPriceType__c = 'Maintenance';
                                        pql.Batch__c = batch;
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
                  try{
                      database.insert(insertQuoteLineList);
                  }catch(Exception e){
                      Migrated_Exceptions__c me = new Migrated_Exceptions__c(List_ids__c=String.valueOf(insertQuoteLineList), Exception_Message__c = e.getMessage(), Exception_StackTrace__c = e.getStackTraceString());
                      migratedExceptionsList.add(me);
                   }
                 
               }
       }catch (Exception e) {
             Migrated_Exceptions__c me = new Migrated_Exceptions__c(Exception_Message__c = e.getMessage(), Exception_StackTrace__c = e.getStackTraceString());
             migratedExceptionsList.add(me);
        }
        
        if(migratedExceptionsList != null && migratedExceptionsList.size() > 0){
            insert migratedExceptionsList;
        }
    }
    
     
    private Opportunity createOpportunity(Migrated_Asset_Data__c cAsset, String oppRecordTypeId, String domesticPBId, Map<Id,Account> accountMap){
        Opportunity opp = new Opportunity();
        Account accnt = accountMap.get(cAsset.Account_ID__c);
     
        String oppName = 'Migration - '+accnt.name+' - '+cAsset.End_Date__c;
        oppName = (oppName.length() >= 99) ? oppName.subString(0,99):oppName;
        opp.Name = oppName;
        opp.AccountId = cAsset.Account_ID__c;
        opp.RecordTypeID = oppRecordTypeId;
        opp.Type = 'Existing Customer';
        opp.StageName = 'Sales Complete';
        opp.Order_Type__c = 'New';
        opp.Forecast_Category__c = 'Pipeline';
        opp.CurrencyIsoCode = cAsset.Currency__c; 
        opp.CloseDate = Date.Today(); 
        opp.Pricebook2Id = domesticPBId;
        if(String.isNotBlank(cAsset.Negotiation_Type__c)){
            opp.Negotiation_Type__c = cAsset.Negotiation_Type__c;  
        }
        //opp.MIBOS_Migration_Name__c= cAsset.endDate;
        return opp;
     }
     
     private SBQQ__Quote__c createQuote(Migrated_Asset_Data__c cAsset){
        SBQQ__Quote__c iQuote = new SBQQ__Quote__c();
        iQuote.CurrencyIsoCode = cAsset.Currency__c;
        iQuote.SBQQ__Account__c = cAsset.Account_ID__c;
        iQuote.SBQQ__Type__c = 'Quote';
        iQuote.SBQQ__PaymentTerms__c = 'Net 30';//Confirm with Rick
        iQuote.SBQQ__StartDate__c = cAsset.Start_Date__c;
        iQuote.SBQQ__EndDate__c = cAsset.End_Date__c;
        iQuote.SBQQ__SubscriptionTerm__c = cAsset.Term__c;
        iQuote.SBQQ__Status__c = 'Signed';
        iQuote.ApprovalStatus__c = 'Approved';
        iQuote.From_Asset_Migration__c = true;
        iQuote.SBQQ__Primary__c = true;
        iQuote.SBQQ__LineItemsGrouped__c = true;        
        return iQuote;
     }
     
    global void finish(Database.BatchableContext BC){}
      
}