/**
 * Utility methods for VCG_CPQ_Quotes
 * 
 * @author  Lawrence Coffin <lawrence.coffin@cloudsherpas.com>
 * @since   1.Dec.2014
 */
global without sharing class QuoteUtility {
    
    /**
     * Set Quote.MSA_Documents__c with the aggregated Product2.Output_MSA_Template__c values
     * of all products on the Quote. Call on before update.
     *
     * Note: This assumes that there is an update made to the quote after all Quote Product records
     *       have been saved. This should be done in the Quote Controller, or via a roll-up summary
     *       on the quote from the quote products.
     *
     * @author  Lawrence Coffin <lawrence.coffin@cloudsherpas.com>
     * @since   1.Dec.2014
     */
    //
    // Controls preventing Recursive Trigger Firing
    //
    public static boolean beforeInsertExecuted = false;
    public static boolean afterInsertExecuted = false;
    public static boolean beforeUpdateExecuted = false;
    public static boolean afterUpdateExecuted = false;
    
    public static void setMSADocIds(Map<Id,VCG_CPQ_Quote__c> newMap)
    {
        // Key is Quote Id, Value is set of MSA Template IDs
        Map<Id,Set<String>> quoteContractTemplateMap = new Map<Id,Set<String>>();
        
        list<VCG_CPQ_Quote_Product__c> quoteProducts = new list<VCG_CPQ_Quote_Product__c>();
        
        //create a map of document Ids to account contracts to determine if the correct contract exists
        map<string, string> accountContractMap = new  map<string, string>();
        set<Id> quoteAccountIds = new set<Id>();
        
        //retrieve the accounts Associated with the Quote
        for(VCG_CPQ_Quote__c q : newMap.values())
        {
            quoteAccountIds.add(q.Account__c);
        }
        
        //grab the Contracts that are associated with the Accounts
        for(Contract c : [Select Status
                               , Agreement_Type__c 
                               , Contract_Category_1__c 
                               , Contract_Category_2__c 
                               , AccountId
                            from Contract
                           where AccountId in :quoteAccountIds
                            and Status = 'Active'])
        {
            accountContractMap.put(c.AccountId
                                  +c.Agreement_Type__c
                                  +c.Contract_Category_1__c
                                  +c.Contract_Category_2__c, c.Id);
        }
        
        System.debug('::accountContractMap:::> '+ accountContractMap);
        
        //
        //collect a map of contract document Ids to contract attributes for verification against product Contract configuration
        //
        map<string, Product_Contract_Template__c> productIdTemplateMap = new map<string, Product_Contract_Template__c>();
        for(Product_Contract_Template__c c   : [Select p.Template_Type__c
                                                     , p.Status__c
                                                     , p.Name
                                                     , p.Description__c
                                                     , p.Contract_Template_Id__c
                                                     , p.Contract_Category_2__c
                                                     , p.Contract_Category_1__c
                                                     , p.Agreement_Type__c 
                                                  From Product_Contract_Template__c p
                                                 where Status__c = 'Active'])
        {
            productIdTemplateMap.put(c.Agreement_Type__c
                                    +c.Contract_Category_1__c
                                    +c.Contract_Category_2__c, c);
        }
        
        System.debug('::productIdTemplateMap:::> '+ productIdTemplateMap);
        
        //collect a mapping of ProductIds to Quotes
        map<Id,VCG_CPQ_Quote__c> productQuoteMap = new map<Id, VCG_CPQ_Quote__c>();
        for (VCG_CPQ_Quote_Product__c qp : [SELECT Id, Quote__r.Opportunity__r.Order_Sub_Type__c
                                                   , Quote__r.Account__c
                                                   , Quote__r.Opportunity__r.RecordType.Name
                                                   , Product__r.Business_Unit__c, Product__c 
                                                 from VCG_CPQ_Quote_Product__c
                                                WHERE Quote__c IN :newMap.keySet()])
         {
            productQuoteMap.put(qp.Product__c, qp.Quote__r );
         }
         
        //collect a map of quotes to a list Products, with Contracts, using VCG_CPQ_Bundle__c. Grab the Quote using the Parent, Product Id, 
        //then add the bundle products to the list
        map<VCG_CPQ_Quote__c, list<Product2>> quoteProductsWithBundles = new map<VCG_CPQ_Quote__c, list<Product2>>();
        
        for(VCG_CPQ_Bundle__c b : [select Product__r.Output_MSA_Document_Template__r.Agreement_Type__c
                                       , Product__r.Output_MSA_Document_Template__r.Contract_Category_1__c 
                                       , Product__r.Output_MSA_Document_Template__r.Contract_Category_2__c
                                       , Product__r.Output_MSA_Document_Template__r.Contract_Template_Id__c
                                       , Product__r.Output_MSA_Document_Template__r.Status__c
                                        
                                       , Product__r.Output_PSA_Document_Template__r.Agreement_Type__c
                                       , Product__r.Output_PSA_Document_Template__r.Contract_Category_1__c 
                                       , Product__r.Output_PSA_Document_Template__r.Contract_Category_2__c
                                       , Product__r.Output_PSA_Document_Template__r.Contract_Template_Id__c
                                       , Product__r.Output_PSA_Document_Template__r.Status__c
                                       
                                       , Product__r.Output_Standard_SOW_Document_Template__r.Agreement_Type__c
                                       , Product__r.Output_Standard_SOW_Document_Template__r.Contract_Category_1__c 
                                       , Product__r.Output_Standard_SOW_Document_Template__r.Contract_Category_2__c
                                       , Product__r.Output_Standard_SOW_Document_Template__r.Contract_Template_Id__c
                                       , Product__r.Output_Standard_SOW_Document_Template__r.Status__c
                                       
                                       , Product__r.Output_Schedule_Document_Template__r.Agreement_Type__c
                                       , Product__r.Output_Schedule_Document_Template__r.Contract_Category_1__c 
                                       , Product__r.Output_Schedule_Document_Template__r.Contract_Category_2__c
                                       , Product__r.Output_Schedule_Document_Template__r.Contract_Template_Id__c
                                       , Product__r.Output_Schedule_Document_Template__r.Status__c
                                       
                                       , Product__r.Business_Unit__c
                                       
                                       , Bundle_Product__c
                                From VCG_CPQ_Bundle__c
                               where Bundle_Product__c in :productQuoteMap.keySet() ])
         {
            VCG_CPQ_Quote__c q = productQuoteMap.get(b.Bundle_Product__c);
            
            if(quoteProductsWithBundles.containsKey(q))
                quoteProductsWithBundles.get(q).add(b.Product__r);
            else
                quoteProductsWithBundles.put(q,new list<Product2>{b.Product__r});
         }
         
         System.debug('::quoteProductsWithBundles:::> '+ quoteProductsWithBundles);
         
         for (VCG_CPQ_Quote_Product__c qpRec : [SELECT Id, Quote__c
                                                   , Product__r.Output_MSA_Document_Template__r.Agreement_Type__c
                                                   , Product__r.Output_MSA_Document_Template__r.Contract_Category_1__c 
                                                   , Product__r.Output_MSA_Document_Template__r.Contract_Category_2__c
                                                   , Product__r.Output_MSA_Document_Template__r.Contract_Template_Id__c
                                                   , Product__r.Output_MSA_Document_Template__r.Status__c
                                                    
                                                   , Product__r.Output_PSA_Document_Template__r.Agreement_Type__c
                                                   , Product__r.Output_PSA_Document_Template__r.Contract_Category_1__c 
                                                   , Product__r.Output_PSA_Document_Template__r.Contract_Category_2__c
                                                   , Product__r.Output_PSA_Document_Template__r.Contract_Template_Id__c
                                                   , Product__r.Output_PSA_Document_Template__r.Status__c
                                                   
                                                   , Product__r.Output_Standard_SOW_Document_Template__r.Agreement_Type__c
                                                   , Product__r.Output_Standard_SOW_Document_Template__r.Contract_Category_1__c 
                                                   , Product__r.Output_Standard_SOW_Document_Template__r.Contract_Category_2__c
                                                   , Product__r.Output_Standard_SOW_Document_Template__r.Contract_Template_Id__c
                                                   , Product__r.Output_Standard_SOW_Document_Template__r.Status__c
                                                   
                                                   , Product__r.Output_Schedule_Document_Template__r.Agreement_Type__c
                                                   , Product__r.Output_Schedule_Document_Template__r.Contract_Category_1__c 
                                                   , Product__r.Output_Schedule_Document_Template__r.Contract_Category_2__c
                                                   , Product__r.Output_Schedule_Document_Template__r.Contract_Template_Id__c
                                                   , Product__r.Output_Schedule_Document_Template__r.Status__c
                                                   , Quote__r.Opportunity__r.Order_Sub_Type__c 
                                                   
                                                   , Quote__r.Account__c
                                                   , Quote__r.Opportunity__r.RecordType.Name
                                                   , Product__r.Business_Unit__c
                                              FROM VCG_CPQ_Quote_Product__c
                                              WHERE Quote__c IN :newMap.keySet()
                                                and Line_Type__c != 'Decommission'
                                                ])
        {
            if(quoteProductsWithBundles.containsKey(qpRec.Quote__r))
                quoteProductsWithBundles.get(qpRec.Quote__r).add(qpRec.Product__r);
            else
                quoteProductsWithBundles.put(qpRec.Quote__r,new list<Product2>{qpRec.Product__r});
        }
        
        System.debug('::quoteProductsWithBundles:::> '+ quoteProductsWithBundles);
        //
        // Collect list of MSAs per quote
        //
        for(VCG_CPQ_QUOTE__c q : quoteProductsWithBundles.keySet())
        {  
            for(Product2 p : quoteProductsWithBundles.get(q))
            {   
                //
                //Does the Quote require a MSA?
                //
                System.debug('::Does the Quote require a MSA?:::> '+ p.Output_MSA_Document_Template__r.Agreement_Type__c
                                                        +p.Output_MSA_Document_Template__r.Contract_Category_1__c
                                                        +p.Output_MSA_Document_Template__r.Contract_Category_2__c
                                                        +':::'+p.Id);
                if (p.Output_MSA_Document_Template__r != null
                    && productIdTemplateMap.containsKey(p.Output_MSA_Document_Template__r.Agreement_Type__c
                                                        +p.Output_MSA_Document_Template__r.Contract_Category_1__c
                                                        +p.Output_MSA_Document_Template__r.Contract_Category_2__c))
                {
                    
                    //Does the customer already have an MSA?
                    
                    boolean accountHasMSA = false;
                    if(accountContractMap.containsKey(q.Account__c
                                                    +p.Output_MSA_Document_Template__r.Agreement_Type__c
                                                    +p.Output_MSA_Document_Template__r.Contract_Category_1__c
                                                    +p.Output_MSA_Document_Template__r.Contract_Category_2__c))
                    {
                      accountHasMSA = true;
                    }
                    
                    System.debug('::Does the customer already have an MSA?:::> '+ accountHasMSA);
                    
                    //Is this a Renewal? If so, always generate a new MSA
                    System.debug('::Is this a Renewal? If so, always generate a new MSA:::> '+ (q.Opportunity__r.RecordType.Name == 'Renewal Only' || accountHasMSA == false));
                    if(q.Opportunity__r.RecordType.Name == 'Renewal Only' || accountHasMSA == false)
                    {  
                        if (!quoteContractTemplateMap.containsKey(q.Id))
                        {
                            quoteContractTemplateMap.put(q.Id, new Set<String>());
                        }
                        
                        // Store the 15 character id only - in case users enter a mix of 15 and 18
                        quoteContractTemplateMap.get(q.Id).add(p.Output_MSA_Document_Template__r.Contract_Template_Id__c.substring(0,15));
                    }
                    
                    System.debug('::quoteContractTemplateMap:::> '+ quoteContractTemplateMap);
                }
                
                //
                //Does the Quote require a PSA?
                // *** THIS IS ALREADY COVERED BY THE MSA BLOCK SINCE A PSA IS ALSO A TYPE OF MSA ****
                //Master PRO SVCS Agreement_All (Doc ID: 01550000001Qbbo)
                // •    Agreement Type = Master
                // •    Contract Category 1 = Pro Svcs
                // •    Contract Category 2 = Master
                // •    Status = Active
                
                //
                /*
                if (p != null 
                    //Is the correct MSA tied to the Customer per Quote?
                    && p.Output_MSA_Document_Template__r != null
                    && productIdTemplateMap.containsKey( p.Output_MSA_Document_Template__r.Agreement_Type__c
                                                        +p.Output_MSA_Document_Template__r.Contract_Category_1__c
                                                        +p.Output_PSA_Document_Template__r.Contract_Category_2__c))
                {
                    
                    //Does the customer already have a PSA?
                    boolean accountHasPSA = false;
                    if(accountContractMap.containsKey(q.Account__c
                                                    +p.Output_PSA_Document_Template__r.Agreement_Type__c
                                                    +p.Output_PSA_Document_Template__r.Contract_Category_1__c
                                                    +p.Output_PSA_Document_Template__r.Contract_Category_2__c))
                    {
                      accountHasPSA = true;
                    }
                    
                    //Is this a Renewal? If so, always generate a new MSA
                    if(q.Opportunity__r.RecordType.Name == 'Renewal Only' || accountHasPSA == false)
                    {  
                        if (!quoteContractTemplateMap.containsKey(qpRec.Quote__c))
                        {
                            quoteContractTemplateMap.put(qpRec.Quote__c, new Set<String>());
                        }
                        
                        // Store the 15 character id only - in case users enter a mix of 15 and 18
                        quoteContractTemplateMap.get(qpRec.Quote__c).add(p.Output_PSA_Document_Template__r.Contract_Template_Id__c.substring(0,15));
                    }
                }
                */
                
                //
                // Is this a RN Quote? 
                /*********************************************************************************************************
                 ** Unnecessary as the relationship inside the product record will determine which template to retrieve **
                /*********************************************************************************************************/
                //
                //boolean addSOW = false;
                //if(p.Business_Unit__c == 'Roadnet')
                //
                //does the product require a SOW?
                System.debug('::does the product require a SOW?:::> '+ p);
                if (p != null 
                    && p.Output_Standard_SOW_Document_Template__r != null
                    && productIdTemplateMap.containsKey(p.Output_Standard_SOW_Document_Template__r.Agreement_Type__c
                                                        +p.Output_Standard_SOW_Document_Template__r.Contract_Category_1__c
                                                        +p.Output_Standard_SOW_Document_Template__r.Contract_Category_2__c))
                {
                    if (!quoteContractTemplateMap.containsKey(q.Id))
                    {
                        quoteContractTemplateMap.put(q.Id, new Set<String>());
                    }
                    
                    // Store the 15 character id only - in case users enter a mix of 15 and 18
                    quoteContractTemplateMap.get(q.Id).add(p.Output_Standard_SOW_Document_Template__r.Contract_Template_Id__c.substring(0,15));
                }
                System.debug('::quoteContractTemplateMap:::> '+ quoteContractTemplateMap);
                //
                //Does the Quote require a Schedule?
                //
                System.debug('::Does the Quote require a Schedule?:::> '+ p);
                if (p != null 
                    && p.Output_Schedule_Document_Template__r != null
                    && productIdTemplateMap.containsKey(p.Output_Schedule_Document_Template__r.Agreement_Type__c
                                                        +p.Output_Schedule_Document_Template__r.Contract_Category_1__c
                                                        +p.Output_Schedule_Document_Template__r.Contract_Category_2__c))
                {
                    
                    //Does the customer already have an schedule?
                    boolean accountHasSchedule = false;
                    //Is this a RN Quote? 
                    if(p.Business_Unit__c != 'Roadnet')
                    {
                        if(accountContractMap.containsKey(q.Account__c
                                                        +p.Output_Schedule_Document_Template__r.Agreement_Type__c
                                                        +p.Output_Schedule_Document_Template__r.Contract_Category_1__c
                                                        +p.Output_Schedule_Document_Template__r.Contract_Category_2__c))
                        {
                          accountHasSchedule = true;
                        }
                    }
                    
                    System.debug('::Does the customer already have an schedule?:::> '+ accountHasSchedule);
                    
                    //Is this a Renewal? If so, always generate a new Schedule
                    System.debug('::Is this a Renewal? If so, always generate a new Schedule:::> '+ (q.Opportunity__r.RecordType.Name == 'Renewal Only' || accountHasSchedule == false));
                    if(q.Opportunity__r.RecordType.Name == 'Renewal Only' || accountHasSchedule == false)
                    {  
                        if (!quoteContractTemplateMap.containsKey(q.Id))
                        {
                            quoteContractTemplateMap.put(q.Id, new Set<String>());
                        }
                        // Store the 15 character id only - in case users enter a mix of 15 and 18
                        quoteContractTemplateMap.get(q.Id).add(p.Output_Schedule_Document_Template__r.Contract_Template_Id__c.substring(0,15));
                    }
                    System.debug('::quoteContractTemplateMap:::> '+ quoteContractTemplateMap);
                }
            }
        }
        
        //
        // Now assign out the Document template ids to the quotes via the VCG_CPQ_Quote_Addendum__c object
        //
        
        //purge the existing records first
        System.debug('::DELETING ADDENDUMS::: ');
        list<VCG_CPQ_Quote_Addendum__c> quoteAddendums = new list<VCG_CPQ_Quote_Addendum__c>();
        for(VCG_CPQ_Quote_Addendum__c qa : [select Id from VCG_CPQ_Quote_Addendum__c where Quote__c in :newMap.keySet()])
            quoteAddendums.add(qa);
            
        if(quoteAddendums.size() > 0)
        {
            delete quoteAddendums;
            quoteAddendums.clear();
        }
        
        System.debug('::ADDING ADDENDUMS::: '+quoteContractTemplateMap.values());
        //add the document Ids for the contract templates to a seperate VCG_CPQ_Quote_Addendum__c record
        for (Id qId : newMap.keySet())
        {
            if (quoteContractTemplateMap.containsKey(qId))
            {
                //newMap.get(qId).MSA_Documents__c = String.join( new List<String>( quoteContractTemplateMap.get(qId) ), ',');
                for(string s : quoteContractTemplateMap.get(qId))
                    quoteAddendums.add(new VCG_CPQ_Quote_Addendum__c(Quote__c = qId, Contract_Document_Id__c = s));
            }
            /*else
            {
                // Clear it if we have no doc ids (can happen if we re-save a quote with only products that have no MSA id)
                newMap.get(qId).MSA_Documents__c = null;
            }*/
        }
        
        System.debug('::quoteAddendums:::> '+quoteAddendums);
        
        if(quoteAddendums.size() > 0)
        {
            insert quoteAddendums;
        }
        
        //if(quoteProducts.size() > 0)
        //  update quoteProducts;
    }
    
    webservice static string generateContractDocumentIds(String quoteId)
    {
        try{
            map<Id, VCG_CPQ_Quote__c> newMap = new map<Id, VCG_CPQ_Quote__c>([select Id, Account__c from VCG_CPQ_Quote__c where Id = :quoteId]);
            
            setMSADocIds(newMap);
        }
        catch(Exception e)
        {
            return ('ERROR: '+e.getMessage());
            
        }
        return 'SUCCESS';
        
    }
    /*
    public static void syncAssetDates()
    {
        list<Asset__c> assets = new list<Asset__c>();
        set<Id> ParentContractSet = new set<Id>();
        for(Asset__c a : [Select a.Contract__r.IsActive__c
                               , a.Contract__r.EndDate
                               , a.Contract__r.StartDate
                               , a.Contract__r.Contract_Category_1__c
                               , a.Account__r.Primary_Business_Unit__c
                               , a.Contract_Term_Start_Date__c
                               , a.Contract_Term_End_Date__c
                               , a.Business_Unit__c
                               , a.Asset_Term_Start_Date__c
                               , a.Asset_Term_End_Date__c 
                               , a.License_Type__c
                               , a.Contract__r.Parent_Contract__c
                            From Asset__c a
                           where Contract__c != null])
        {
            if(a.Contract_Term_Start_Date__c != a.Contract__r.StartDate
                || a.Contract_Term_End_Date__c != a.Contract__r.EndDate 
                || a.Asset_Term_Start_Date__c != a.Contract__r.StartDate
                || a.Asset_Term_End_Date__c != a.Contract__r.EndDate 
              )
            {
                boolean addAsset = false;
                
                ////////////////All///////////////////
                if(a.Contract_Term_Start_Date__c != a.Contract__r.StartDate)
                {
                    a.Contract_Term_Start_Date__c = a.Contract__r.StartDate;
                    addAsset = true;
                }
                
                /////////////////Roadnet////////////////////////////
                if(a.Account__r.Primary_Business_Unit__c == 'Roadnet'
                  && !(a.Contract__r.Contract_Category_1__c == 'Dom. Perpetual'
                       || a.Contract__r.Contract_Category_1__c == 'Int. Perpetual'
                       || a.License_Type__c == 'Perpetual'
                       || a.License_Type__c == 'Subscription')
                  && a.Contract_Term_End_Date__c != a.Contract__r.EndDate)
                {
                    a.Contract_Term_End_Date__c = a.Contract__r.EndDate;
                    addAsset = true;
                }
                
                /////////////////Omni Domestic////////////////////////////
                if(a.Account__r.Primary_Business_Unit__c == 'Omnitracs Domestic')
                {
                    
                    
                    //
                    //If not in sync, update all Asset Asset End Date 364 days from the Asset Start Date if on the provision record of
                    //the Contract’s Parent Contract where Provision record type = OMNI - Master Contract Provision has Price Increase = Yes. 
                    //If Price Increase = No then update the Asset End Date to the Contract End Date.
                    //
                    if(a.Asset_Term_End_Date__c != a.Contract__r.EndDate)
                    {
                        ParentContractSet.add(a.Contract__r.Parent_Contract__c);
                    }
                    
                    //If not in sync, update all Asset Asset Start Dates based on Contract Start Date
                    if(a.Asset_Term_Start_Date__c != a.Contract__r.StartDate)
                    {
                            a.Asset_Term_Start_Date__c = a.Contract__r.StartDate;
                            addAsset = true;
                    }
                    
                    if(a.Asset_Term_End_Date__c != a.Contract__r.EndDate)
                    {
                            a.Asset_Term_End_Date__c  = a.Contract__r.EndDate;
                            addAsset = true;
                    }
                    
                    if(a.Contract_Term_End_Date__c != a.Contract__r.EndDate)
                    {
                        a.Contract_Term_End_Date__c = a.Contract__r.EndDate;
                            addAsset = true;
                    }
                     
                }
                
                if(addAsset = true)
                    assets.add(a);
            }
        }
        
        // upate the assets
        if(assets.size() > 0)
            update assets;
            
        set<Id> assetContract364 = new set<Id>();
        set<Id> assetContractEndDate = new set<Id>();
        for(Provision__c p : [select Id, Price_Increases_Y_N__c, Contract__c 
                               from Provision__c 
                              where RecordType.Name = 'OMNI - Master Contract Provision' 
                                and Price_Increases_Y_N__c != null
                                and Contract__c in :ParentContractSet])
        {
            if(p.Price_Increases_Y_N__c == 'Yes')
                assetContract364.add(p.Contract__c);
            else
                assetContractEndDate.add(p.Contract__c);
                
        }
    
        //
        //process the asset term end dates
        //update all Asset Asset End Date 364 days from the Asset Start Date if on the provision record of
        //the Contract’s Parent Contract where Provision record type = OMNI - Master Contract Provision has Price Increase = Yes. 
        //If Price Increase = No then update the Asset End Date to the Contract End Date.
        //
        assets.clear();
        for(Asset__c a : [Select Id
                               , Asset_Term_End_Date__c
                               , Contract__r.Parent_Contract__c
                               , Asset_Term_Start_Date__c
                               , Contract__r.StartDate
                               , Contract__r.EndDate
                            from Asset__c 
                           where Contract__r.Parent_Contract__c in :assetContract364
                              OR Contract__r.Parent_Contract__c in :assetContractEndDate])
        {
            if(assetContract364.contains(a.Contract__r.Parent_Contract__c) && a.Asset_Term_Start_Date__c != null)
            {
                //if(a.Id == 'a6L50000000TXJh') a.addError('::::::::!!!!!:::::: '+a.Contract__r.Parent_Contract__c);
                if(a.Asset_Term_Start_Date__c.addDays(364) >= System.today())
                    a.Asset_Term_End_Date__c = a.Asset_Term_Start_Date__c.addDays(364);
                else
                {
                    //if(a.Asset_Term_End_Date__c < System.today())
                    //{
                    if(Date.newInstance(System.today().year(), a.Asset_Term_Start_Date__c.month(), a.Asset_Term_Start_Date__c.day()).addDays(-1) >= System.today())
                    {
                        a.Asset_Term_End_Date__c 
                            = date.newInstance(System.today().year(), a.Asset_Term_Start_Date__c.month(), a.Asset_Term_Start_Date__c.day()).addDays(-1);
                    }
                    else{
                        a.Asset_Term_End_Date__c 
                            = Date.newInstance(System.today().year()+1, a.Asset_Term_Start_Date__c.month(), a.Asset_Term_Start_Date__c.day()).addDays(-1);
                    }
                    //}
                }
            }
            else if(assetContractEndDate.contains(a.Contract__r.Parent_Contract__c))
                a.Asset_Term_End_Date__c = a.Contract__r.EndDate;
            
            //if(a.Id == 'a6L50000000TXJh') a.addError('::::::::!!!!!:::::: '+a.Contract__r.Parent_Contract__c);
            assets.add(a);
        }
        
        if(assets.size() > 0)
            update assets;
    }*/
    /* Update Product Template Lookups script
        map<string, Product_Contract_Template__c> productIdTemplateMap = new map<string, Product_Contract_Template__c>();
        for(Product_Contract_Template__c pct : [Select Id
                                                     , p.Contract_Template_Id__c
                                                  From Product_Contract_Template__c p
                                                 where Status__c = 'Active'])
       {
            productIdTemplateMap.put(pct.Contract_Template_Id__c, pct);
        }

        list<Product2> pList = new list<Product2>();
        for(Product2 p : [Select ID, Output_MSA_Document_Template__c,Output_MSA_Template__c
                                               ,  Output_Schedule_Document_Template__c,  Output_Schedule_Template__c
                                               ,  Output_Standard_SOW_Document_Template__c,  Output_SOW_Template__c
                           from Product2])
        {
            if(productIdTemplateMap.containsKey(p.Output_MSA_Template__c))
                p.Output_MSA_Document_Template__c = productIdTemplateMap.get(p.Output_MSA_Template__c).Id;
            
             if(productIdTemplateMap.containsKey(p.Output_Schedule_Template__c))
                p.Output_Schedule_Document_Template__c = productIdTemplateMap.get(p.Output_Schedule_Template__c).Id;
            
             if(productIdTemplateMap.containsKey(p.Output_SOW_Template__c))
                p.Output_Standard_SOW_Document_Template__c= productIdTemplateMap.get(p.Output_SOW_Template__c).Id;
            pList.Add(p);
        }
        
        update pList; 
     */
 
        
        /**********************JS BUTTON ***********************************************
        {!REQUIRESCRIPT("/soap/ajax/31.0/connection.js")} 
{!REQUIRESCRIPT("/soap/ajax/31.0/apex.js")} 

if ('{!VCG_CPQ_Quote__c.Status__c}' == 'Draft'
    ||'{!VCG_CPQ_Quote__c.Status__c}' == 'Pending Approval'
    ||'{!VCG_CPQ_Quote__c.Status__c}' == 'Approved')
{
   //set up the contract document Ids associated with the Quote Products
   try{ 
       var qtId ='{!VCG_CPQ_Quote__c.Id}';
       var result = sforce.apex.execute("QuoteUtility"
                                       , "generateContractDocumentIds"
                                       , {quoteId:qtId}); 
        if(result.indexOf('ERROR') > 0)
        {
             alert(result);
        }
        else
        {
           window.location = "{!$Site.Prefix}/apex/loop__looplus?sessionId=       {!$Api.Session_ID}&eid={!VCG_CPQ_Quote__c.Id}&contactId={!VCG_CPQ_Quote__c.ContactId__c}&accountId={!VCG_CPQ_Quote__c.AccountId__c}&instance=cs13&filter={!VCG_CPQ_Quote__c.Status__c}&retURL={!URLENCODE($Site.Prefix & '/' & VCG_CPQ_Quote__c.Id)}";
        }
    } 
    catch(err){ 
        txt="There was an error on this page.\n\n"; 
        txt+="Error description: " + err.description + "\n\n"; 
        alert(txt); 
    }

}
else
    alert('You cannot generate a quote unless the Opportunity Stage is Draft, Pending Approval or Closed Won.');
    *********************************************************************************/

     
}