global without sharing class VCG_CPQ_PricingUtility {
    
    private static Integer showDebugOutput = 0;
    
    private static void debug(String msg)
    {
        if (showDebugOutput > 0)
    {
            System.debug(LoggingLevel.ERROR, msg);
        }
    }
    
    // map pricingResultsMap to capture Pricing result records
    public static Map<String,List<VCG_CPQ_Quote_Product_Pricing_Result__c>> pricingResultsMap;
    public static List<Id> deletedQPIds = new List<Id>();
    
    //used to stor the number of assets for an account
    public static Map<String, Decimal> TotalOwned = new Map<String, Decimal>();
    
    /*
     * Second pass at a sorting function. This function sorts products so core products are priced first,
     * then add-ons, then add-ons to add-ons, etc. That way if there are any %ofCore or other dependencies,
     * the parent product should be priced already. (Note that only the pricing up through the current
     * pricing procedure will be completed, not future pricing procedures.)
     * 
     * @author  Lawrence Coffin <lawrence.coffin@cloudsherpas.com>
     * @since   Pre-Nov.2014
     */
    public static void SortQPRecordsForPricing(List<VCG_CPQ_Quote_Product__c> quoteProducts)
    {
        Integer qpLen = quoteProducts.size();
        Integer unsortedHead = 0; // This points to the first un-sorted element in the list
        
        Set<VCG_CPQ_Quote_Product__c> seenQPs = new Set<VCG_CPQ_Quote_Product__c>();
        
        Integer iterCount = 0; // we keep a count of the total number of iterations so we can put a max count on the number of total iterations (so we don't have a runaway loop)
        
//      { // start debug block
//          List<String> prodNames = new List<String>();
//          for (VCG_CPQ_Quote_Product__c qp : quoteProducts)
//          {
//              prodNames.add(qp.Product__r.Name);
//          }
//          System.debug(LoggingLevel.ERROR, '====> QPs before sorting: ' + prodNames);
//      } // end debug block
        for (Integer loopIdx = unsortedHead; loopIdx < qpLen && unsortedHead < qpLen && iterCount++ < 200; loopIdx++)
        {
//            System.debug(LoggingLevel.ERROR, '====> Loop: ' + iterCount + ' - unsortedHead: ' + unsortedHead + ', loopIdx: ' + loopIdx);
            
            // Core products and add-ons to Assets are fine - move them to the front
            if (quoteProducts[loopIdx].Add_on_Source_Quote_Product__r == null
                  || seenQPs.contains(quoteProducts[loopIdx].Add_on_Source_Quote_Product__r))
            {
                //
                // Found an element that can be moved to the sorted side of the list
                //
//                System.debug(LoggingLevel.ERROR, '====> Found sortable: ' + quoteProducts[loopIdx].Product__r.Name);
                if (loopIdx == unsortedHead)
                {
                    // No unsorted products yet, so no need to move core product, just increment both unsortedHead and loopIdx
//                    System.debug(LoggingLevel.ERROR, '====> At start of unsortable, just increment unsortableHead');
                }
                else
                {
//                    System.debug(LoggingLevel.ERROR, '====> Sortable product after non-sortable, swap with ' + quoteProducts[unsortedHead].Product__r.Name);
                    // Found a sortable product after an unsortable product, swap sortable
                    // product with first unsortable product, then increment both counters
                    VCG_CPQ_Quote_Product__c tempQP = quoteProducts[loopIdx];
                    quoteProducts[loopIdx] = quoteProducts[unsortedHead];
                    quoteProducts[unsortedHead] = tempQP;
                
//                  { // start debug block
//                      List<String> prodNames = new List<String>();
//                      for (VCG_CPQ_Quote_Product__c qp : quoteProducts)
//                      {
//                          prodNames.add(qp.Product__r.Name);
//                      }
//                      System.debug(LoggingLevel.ERROR, '====> QPs after sorting: (1) - ' + prodNames);
//                  } // end debug block
                }
                
                // Keep track of the QP records we have seen/sorted, so we know when we find a child record
                // that refers to it, we can sort that child record
                seenQPs.add(quoteProducts[unsortedHead]);
                
                // Increment unsortedHead to the next unsorted element
//                loopIdx++;
                unsortedHead++;
            }
            else
            {
//                System.debug(LoggingLevel.ERROR, '====> Found non-sortable: ' + quoteProducts[loopIdx].Product__r.Name);
                
                // Got an unsortable product (an add-on for a product we haven't sorted yet), don't sort item 
                // ... i.e. don't increment unsortedHead - we want that to remain pointing at the first unsorted product
                // Increment the loopIdx to keep looking for sortable products
//              loopIdx++;
            }
            
            if (loopIdx == qpLen - 1)
            {
//                System.debug(LoggingLevel.ERROR, '====> loopIdx at end of list, reset to unsortedHead');
                // loopIdx has reached the end of the list, that means we want to start over again at the start of any unsorted elements
                // so set it to unsortedHead - 1, so it will start at the start of the unsorted elements at the start of the next loop (after the loopIdx++)
                loopIdx = unsortedHead - 1;
            }
        }
//        { // start debug block
//          System.debug(LoggingLevel.ERROR, '====> iterCount at end: ' + iterCount);
//          
//            List<String> prodNames = new List<String>();
//            for (VCG_CPQ_Quote_Product__c qp : quoteProducts)
//            {
//                prodNames.add(qp.Product__r.Name);
//            }
//            System.debug(LoggingLevel.ERROR, '====> QPs after sorting: (1) - ' + prodNames);
//        } // end debug block
    }
    
    
    /*
     * Price Quote Product lines (and the Quote itself)
     */
    public static void priceQuoteProducts(VCG_CPQ_Quote__c quote, List<VCG_CPQ_Quote_Product__c> quoteProducts, List<Asset__c> existingAssets, Map<String,VCG_CPQ_Pricing_Override__c> pricingOverrideMap, VCG_CPQ_QuoteController currController)
    {
        // Turn off pricing for Lawrence - so I can debug some other code and not have truncated debug logs
//      if (UserInfo.getUserId().left(15) == '005i0000001xxT5') return;
        
//        debug('====> quoteProducts: ' + quoteProducts);
//        debug('====> pricingOverrideMap: ' + pricingOverrideMap);
        
        // clear the deletedQPIds list
        deletedQPIds.clear();
        
        // Skip empty quotes
        if (quoteProducts == null || quoteProducts.size() == 0) {
            return;
        }
        
        SortQPRecordsForPricing(quoteProducts);
        
//        { // start debug block
//            List<String> prodNames = new List<String>();
//            for (VCG_CPQ_Quote_Product__c qp : quoteProducts)
//            {
//                prodNames.add(qp.Product__r.Name);
//            }
//            System.debug(LoggingLevel.ERROR, '====> QPs after sorting: (2) - ' + prodNames);
//        } // end debug block
        
        // Map to store VCG_CPQ_Quote_Product_Pricing_Result__c records
        if (pricingResultsMap == null) 
            pricingResultsMap = new Map<String,List<VCG_CPQ_Quote_Product_Pricing_Result__c>>();
        
        //Map to store Pricing procedure sequence records according to their 
       
        Map<String, Schema.DescribeFieldResult> quoteDescribe = describeObjectFields('VCG_CPQ_Quote__c');
        Map<String, Schema.DescribeFieldResult> lineDescribe = describeObjectFields('VCG_CPQ_Quote_Product__c');
        boolean isMultiCurrencyEnabled = UserInfo.isMultiCurrencyOrganization();
        
        // Header conditions expect the Quote Products to be available through the quote.Quote_Products__r relationship
        // (or the in-memory equivalent of that), so we check to see if they have been added to that yet.
        VCG_CPQ_Data.setChildren(quote, 'Quote_Products__r', quoteProducts);
        
        // count total owned Assets
        
        
        if (VCG_CPQ_Options__c.getInstance().Count_Total_Owned__c)
        {
            CountTotalOwned(quote, quoteProducts, existingAssets);
        }
        
        //
        // Determine Pricing Procedure
        //
        
        // Note: this map is really only used to ensure that each PP is only added to the list once.
        /** @todo  Remove this map, find another way to only add one PP to the list */
        Map<Id,VCG_CPQ_Pricing_Procedure__c> pricingProceduresMap = new Map<Id,VCG_CPQ_Pricing_Procedure__c>();
        List<VCG_CPQ_Pricing_Procedure__c> pricingProceduresList = new List<VCG_CPQ_Pricing_Procedure__c>();
        
        Map<Id,List<VCG_CPQ_Pricing_Procedure_Sequence__c>> ppSequenceListMap = new Map<Id,List<VCG_CPQ_Pricing_Procedure_Sequence__c>>();
        
        Set<Id> accessSequenceIdSet = new Set<Id>();
        
        // List of fields we want to cache for any auto-added QP lines. See VCG_CPQ_QuoteController.autoAddedValueCache
        List<String> cacheAutoAddedFields = new List<String>{
													           'Discount_Amount__c',
													           'Discount_Percentage__c',
													           'Discount_Entered_As__c',
                                                               'Uplift_Amount__c',
                                                               'Uplift_Percentage__c',
                                                               'Uplift_Entered_As__c'
													        };
		
        // Collect the line types in the quote, no need to pull Pricing Procedures for lines types we don't have.
        Set<String> types = new Set<String>();
        
        // Process the QP lines -- capturing line types as well as caching values for auto-added lines
        for (VCG_CPQ_Quote_Product__c qp : quoteProducts)
        {
            // store line type
            types.add(qp.Line_Type__c);
            
            // cache auto-added line values
            if (qp.Auto_Added_QP_Line__c)
            {
            	String sku = qp.Product__r.ProductCode;
            	
            	// Initialize the cache, if needed
                if (currController.autoAddedValueCache == null)
                    currController.autoAddedValueCache = new Map<String,Map<String,Object>>();
                
                // Initialize the cache's product map, if needed
                if (!currController.autoAddedValueCache.containsKey(sku))
                    currController.autoAddedValueCache.put(sku, new Map<String,Object>());
                
                // Cache the values
                for (String fieldName : cacheAutoAddedFields)
                {
                    currController.autoAddedValueCache.get(sku).put(fieldName, (Object)(qp.get(fieldName)));
                }
            }
        }
        
        // Include 'All' and 'Header' pricing procedures as well
        types.add('All');
        types.add('Header');
        
        // Pull in the combined Pricing Procedure and Access Sequence records for the header and line type calculations
        for (VCG_CPQ_Pricing_Procedure_Sequence__c pps : [SELECT v.Id,
                                                                 v.Sequence__c,
                                                                 v.Pricing_Procedure__r.Name,
                                                                 v.Pricing_Procedure__r.Quote_Line_Type__c,
                                                                 v.Pricing_Procedure__c,
                                                                 v.Access_Sequence__c,
                                                                 v.Access_Sequence__r.Name,
                                                                 v.Access_Sequence__r.Assign_To__c,
                                                                 v.Access_Sequence__r.Debug__c
                                                         FROM VCG_CPQ_Pricing_Procedure_Sequence__c v
                                                         WHERE Pricing_Procedure__r.Quote_Line_Type__c = :types
                                                               AND Pricing_Procedure__r.Active__c = TRUE
                                                         ORDER BY Pricing_Procedure__r.Sequence__c,
                                                                  Pricing_Procedure__r.Quote_Line_Type__c,
                                                                  Sequence__c])
        {
            if (!pricingProceduresMap.containsKey(pps.Pricing_Procedure__c)) {
                // Add to PP list - this will be in the sequence we want to execute them
                pricingProceduresList.add(pps.Pricing_Procedure__r);
                
                pricingProceduresMap.put(pps.Pricing_Procedure__c, pps.Pricing_Procedure__r);
            }
             
            if (!ppSequenceListMap.containsKey(pps.Pricing_Procedure__c)) {
                ppSequenceListMap.put(pps.Pricing_Procedure__c, new List<VCG_CPQ_Pricing_Procedure_Sequence__c>());
            }
             
            // Add the Pricing Procedure Sequence record (which also contains the access sequence record) to the PP Sequence List
            ppSequenceListMap.get(pps.Pricing_Procedure__c).add(pps);
             
            // Collect the Access Sequence Ids so we can pull in all Pricing Condition records
            accessSequenceIdSet.add(pps.Access_Sequence__c);
        }
        
        // Pull in associated Access Sequence records
        // Loop through Access Sequence records in the order specified in the Procedure Sequence records
        // Pull in Sequence Condition records for the given Access Sequence
        Map<Id, List<VCG_CPQ_Pricing_Condition__c>> asConditionListMap = new Map<Id, List<VCG_CPQ_Pricing_Condition__c>>();
        Set<Id> conditionIdSet = new Set<Id>();
        for (VCG_CPQ_Pricing_Sequence_Condition__c psc : [SELECT v.Condition__r.Calculation_Compiled__c,
                                                                 v.Condition__r.Calculation__c,
                                                                 v.Condition__r.Data_Scale_Field_1__c,
                                                                 v.Condition__r.Data_Scale_Field_2__c,
                                                                 v.Condition__r.Data_Scale_Field_3__c,
                                                                 v.Condition__r.Data_Key_Definition__c,
                                                                 v.Condition__r.Type__c,
                                                                 v.Condition__r.Name,
                                                                 v.Condition__r.Id,
                                                                 v.Condition__c,
                                                                 v.Access_Sequence__c,
                                                                 v.Access_Sequence__r.Name,
                                                                 v.Access_Sequence__r.Assign_To__c,
                                                                 v.Sequence__c
                                                          FROM VCG_CPQ_Pricing_Sequence_Condition__c v
                                                          WHERE Access_Sequence__c IN :accessSequenceIdSet
                                                          ORDER BY Sequence__c])
        {
            // Store Condition Ids so we can query Condition Data below
            conditionIdSet.add(psc.Condition__r.Id);
            
            if (!asConditionListMap.containsKey(psc.Access_Sequence__c))
            {
                asConditionListMap.put(psc.Access_Sequence__c, new List<VCG_CPQ_Pricing_Condition__c>());
            }
            
            // Store the Pricing Conditions in the order in which they need to be executed for each access sequence
            asConditionListMap.get(psc.Access_Sequence__c).add(psc.Condition__r);
        }
        
        Map<Id, List<VCG_CPQ_Pricing_Condition_Data__c>> conditionDataMap = new Map<Id, List<VCG_CPQ_Pricing_Condition_Data__c>>();
        
        String query = 'SELECT Result_Value__c,'
                                 + ' Result_Value_String__c,'
                                 + ' Result_Type__c,'
                                 + ' Multiply_by_Quantity__c,'
                                 + ' Data_Scale_1__c,'
                                 + ' Data_Scale_2__c,'
                                 + ' Data_Scale_3__c,'
                                 + ' Data_Key__c,'
                                 + ' Condition__c'
                                 + (UserInfo.isMultiCurrencyOrganization() ? ', CurrencyIsoCode' : '')
                          + ' FROM VCG_CPQ_Pricing_Condition_Data__c'
                          + ' WHERE Condition__c in :conditionIdSet'
                          + ' ORDER BY Data_Key__c,'
                                 + ' Data_Scale_1__c,'
                                 + ' Data_Scale_2__c,'
                                 + ' Data_Scale_3__c';
        
        // collect the pricing condition data
        for (VCG_CPQ_Pricing_Condition_Data__c pcd : Database.query(query))
        {
            if (!conditionDataMap.containsKey(pcd.Condition__c))
            {
                conditionDataMap.put(pcd.Condition__c, new List<VCG_CPQ_Pricing_Condition_Data__c>());
            }
            
            conditionDataMap.get(pcd.Condition__c).add(pcd);
        }
        
        //
        // Loop through Pricing Procedures in the order of the Sequence field
        // Then loop through the Access Sequences in the order of the Sequence field in Pricing_Sequence record
        // Then loop through the conditions in the Sequence_Condition Sequence field
        //
        for (VCG_CPQ_Pricing_Procedure__c pp : pricingProceduresList)
        {
            debug('====> Looping through Pricing Procedure: ' + pp.Name);
            
            List<VCG_CPQ_Pricing_Procedure_Sequence__c> ppSequenceList = ppSequenceListMap.get(pp.Id);
            
            if (pp.Quote_Line_Type__c == 'Header')
            {
                // Do header pricing here
                
                Map<String,Map<String,Object>> Results = new Map<String,Map<String,Object>>();
                
                // Loop through all header access sequences
                for (VCG_CPQ_Pricing_Procedure_Sequence__c ppSequence : ppSequenceList)
                {
                    VCG_CPQ_Pricing_Access_Sequence__c accessSequence = ppSequence.Access_Sequence__r;
                    
                    // Turn debug output on if accessSequence.Debug__c is true
                    if (accessSequence.Debug__c)
                    {
                        showDebugOutput++;
                        debug('====> Debugging started for access sequence: ' + accessSequence);
                    }
                    
                    VCG_CPQ_Formula.Result res = null;
                     
                    // Loop through condtions for the Access Sequence
                    
                    for (VCG_CPQ_Pricing_Condition__c condition : asConditionListMap.get(ppSequence.Access_Sequence__r.Id))
                    {
                        // Evaluate the Condition, if we have a result, exit the loop
                        if (condition.Calculation_Compiled__c == null)
                        {
                            throw new VCG_CPQ_Formula.Formula_Exception('Null header pricing condition formula!');
                        }
                        else
                        {
                            try {
                                res = VCG_CPQ_Formula.evaluate(quote, Results, existingAssets, condition.Calculation_Compiled__c);
                            }
                            catch (Exception e) {
                                throw new VCG_CPQ_Formula.Formula_Exception('Error evaluating Header Pricing Condition "' + condition.Name + '": ' + e.getMessage() + '\n' + e.getStackTraceString());
                            }
                            
                            if (res != null && (res.value != null || res.str_val != null || res.obj_val != null))
                            {
                                if (res.type == 'Add Product')
                                {
                                    VCG_CPQ_Quote_Product__c qp = (VCG_CPQ_Quote_Product__c)res.obj_val;
                                    qp.Quote__r = quote;
                                    System.debug('====> Adding product: ' + qp.Product__r.ProductCode);
                                    
                                    // Re-set any cached values for the record (i.e. set user-entered discounts, uplifts, etc.)
                                    String sku = qp.Product__r.ProductCode;
                                    
                                    if (currController.autoAddedValueCache != null && currController.autoAddedValueCache.containsKey(sku))
                                    {
                                        for (String fieldName : cacheAutoAddedFields)
                                        {
                                            qp.put(fieldName, currController.autoAddedValueCache.get(sku).get(fieldName));
                                        }
                                    }
                                    
                                    // Add to quoteProducts list
                                    // NOTE NOTE NOTE ... this *will* change the list in the calling method!
                                    quoteProducts.add(qp);
                                    
                                    // Add to quote products children
                                    VCG_CPQ_Data.addChild(quote, 'Quote_Products__r', qp);
                                }
                                else if (res.type == 'Remove Product')
                                {
                                    String sku = res.str_val;
                                    System.debug('====> Got sku to remove: ' + sku);
                                    
                                    // Remove from quoteProducts list
                                    // Note: We can't remove directly from the quoteProducts list while iterating over the
                                    //       list, so we have to add all the products we want to keep to a separate list
                                    //       then clear the original list and re-add them back to the original list.
                                    // Note 2: We have to *re-add* them back to the original list, we can't simply re-point
                                    //         the list to the 'qpsToKeep' list, because we need the changes to apply back
                                    //         to the original list object that was passed in to us.
                                    // NOTE NOTE NOTE ... this *will* change the list in the calling method!
                                    List<VCG_CPQ_Quote_Product__c> qpsToKeep = new List<VCG_CPQ_Quote_Product__c>();
                                    for (VCG_CPQ_Quote_Product__c qp : quoteProducts) {
                                        if (qp.Product__r.ProductCode != sku)
                                        {
                                            qpsToKeep.add(qp);
                                        }
                                        else
                                        {
                                            System.debug('====> Removing product: ' + qp.Product__r.ProductCode);
                                            if (qp.Id != null)
                                            {
                                                deletedQPIds.add(qp.Id);
                                            }
                                        }
                                    }
                                    quoteProducts.clear();
                                    quoteProducts.addAll(qpsToKeep);
                                    

                                    // Add to quote products children
                                    VCG_CPQ_Data.setChildren(quote, 'Quote_Products__r', quoteProducts);
                                }
                                else
                                {
                                    if (ppSequence.Access_Sequence__r.Assign_To__c != null)
                                    {
                                        if (VCG_CPQ_Formula.GetFieldType(quote, ppSequence.Access_Sequence__r.Assign_To__c).name() == 'Boolean')
                                        {
                                            quote.put(ppSequence.Access_Sequence__r.Assign_To__c, (res.value == 1 ? true : false));
                                        }
                                        else if (res.str_val != null)
                                        {
                                            quote.put(ppSequence.Access_Sequence__r.Assign_To__c, res.str_val);
                                        }
                                        else if (res.obj_val != null)
                                        {
                                            // Is Date the only object type we support?
                                            quote.put(ppSequence.Access_Sequence__r.Assign_To__c, (Date)res.obj_val);
                                        }
                                        else
                                        {
                                            // Automatically round the result value to the field's scale
                                            Decimal val = ((Decimal)res.value);
                                            Integer scale = VCG_CPQ_Formula.getFieldScale(quote, ppSequence.Access_Sequence__r.Assign_To__c);
                                            if (scale != null)
                                            {
                                                val = ((Decimal)res.value).setScale(scale, RoundingMode.HALF_UP);
                                            }
                                            
                                            // Assign the value to the field
                                            quote.put(ppSequence.Access_Sequence__r.Assign_To__c, val);
                                        }
                                    }
                                }
                                
                                // For Action Item ACT-0142 Start
                                if (!Results.containsKey(accessSequence.Name))
                                {
                                    Results.put(accessSequence.Name, new Map<String,Object>());
                                }
                                
                                Decimal as_resultValue = null;
                                String as_resultValueStr = null;
                                Date as_resultValueDate = null;
                                if (res.type == null
                                    || res.type == 'Decimal'
                                    || res.type == 'Boolean'
                                    || res.type == 'String'
                                    || res.type == 'Date')
                                {
                                    as_resultValue = res.value;
                                    as_resultValueStr = res.str_val;
                                    as_resultValueDate = (Date)res.obj_val;
                                }
                                
                                debug(':::::Setting Results::: accessSequence.Name = '+accessSequence.Name);
                                debug(':::::ResultValue = '+as_resultValue);
                                debug(':::::ResultValueStr = '+as_resultValueStr);
                                debug(':::::ResultValueDate = '+as_resultValueDate);
                                
                                Results.get(accessSequence.Name).put('ResultValue', as_resultValue);
                                Results.get(accessSequence.Name).put('ResultValueString', as_resultValueStr);
                                Results.get(accessSequence.Name).put('ResultValueDate', as_resultValueDate);
                                // For Action Item ACT-0142 End
                                
                                // Break out of condition loop to next Access Sequence
                                continue;
                            }
                        }
                    } // End header pricing condition loop
                    
                    //
                    // If we get here, that means we've looped through all the conditions but didin't get 
                    // a result value. If that's the case, and the Access Sequence has an Assign_To__c field
                    // then we need to *clear* the Assign_To__c field in case it was previously set to a value
                    // that shouldn't remain. This can happen if the user changes some input that causes
                    // conditions that resulted in a value before, to no longer generate a value.
                    //
                    if (res == null && ppSequence.Access_Sequence__r.Assign_To__c != null)
                    {
                        if (VCG_CPQ_Formula.GetFieldType(quote, ppSequence.Access_Sequence__r.Assign_To__c).name() == 'Boolean')
                        {
                            quote.put(ppSequence.Access_Sequence__r.Assign_To__c, false);
                        }
                        else
                        {
                            quote.put(ppSequence.Access_Sequence__r.Assign_To__c, null);
                        }
                    }
                    
                    // Turn debug output off if accessSequence.Debug__c is true
                    if (accessSequence.Debug__c)
                    {
                        debug('====> Debugging done for access sequence: ' + accessSequence);
                        showDebugOutput--;
                    }
                } // end of access sequence loop
            }
            else
            {
                String lineType = pp.Quote_Line_Type__c;
            
                // price all of the products in the list based on type
                for ( VCG_CPQ_Quote_Product__c quoteProduct : quoteProducts)
                {
                    // Skip product lines that don't match the Pricing Procedure line type
                    // if the PP line type isn't 'All'
                    if (lineType != 'All' && quoteProduct.Line_Type__c != lineType)
                      continue;
                    
                    // Stores Access Sequence calculation results *for this Quote Product record*
                    // (will need to be extended for all lines and the entire quote)
                    Map<String,Map<String,Object>> Results = new Map<String,Map<String,Object>>();
                    
                    debug('====> Pricing Procedure Sequences for type ' + lineType + ': ' + ppSequenceList);
                    
                    // Skip any records if we don't have any access sequence records
                    /** @todo  Review code, this should never happen now that we have switched to loop over
                               Pricing Procedures & Access Sequences, rather than looping over line types */
                    if (ppSequenceList == null || ppSequenceList.size() == 0)
                    {
                        debug('====> No Pricing Procedure Sequences for type ' + lineType + ' ... skipping');
                        continue;
                    }
                    
                    List<VCG_CPQ_Pricing_Condition__c> pricingConditions = new List<VCG_CPQ_Pricing_Condition__c>();
                    
                    // iterate through the access sequences (Pricing Procedure Sequences)
                    for (VCG_CPQ_Pricing_Procedure_Sequence__c ppSequence : ppSequenceList)
                    {
                        VCG_CPQ_Pricing_Access_Sequence__c accessSequence = ppSequence.Access_Sequence__r;
                        
                        // Turn debug output on if accessSequence.Debug__c is true
                        if (accessSequence.Debug__c)
                        {
                            showDebugOutput++;
                            debug('====> Debugging started for access sequence: ' + accessSequence);
                        }
                        
                        String as_lookupResultType = null;
                        Decimal as_lookupResultValue = null;
                        String as_lookupResultValueStr = null;
                        String as_resultType = null;
                        Decimal as_resultValue = null;
                        String as_resultValueStr = null;
                        Date as_resultValueDate = null;
                        
                        String overrideKey = getOverrideKey(quoteProduct, ppSequence); // quoteProduct.Product_Group__c + '-' + quoteProduct.Line_Type__c + '-' + quoteProduct.Product__r.Name + '-' + ppSequence.Id;
                        
                        debug('====> overrideKey: ' + overrideKey);
                        
                        //
                        // Pricing Override checked first
                        //
                        if (pricingOverrideMap.containsKey(overrideKey))
                        {
                            //
                            // Get pricing override value
                            //
                            VCG_CPQ_Pricing_Override__c overrideRec = pricingOverrideMap.get(overrideKey);
                            
                            debug('====> overrideRec: ' + overrideRec);
                            
                            as_resultType = overrideRec.Override_Value_Type__c;
                            as_resultValue = overrideRec.Override_Value__c;
                            as_resultValueStr = overrideRec.Override_Value_Str__c;
                            as_resultValueDate = overrideRec.Override_Value_Date__c;
                            
                            
                            //
                            // Assign to $Results
                            //
                            if (!Results.containsKey(accessSequence.Name)) {
                                Results.put(accessSequence.Name, new Map<String,Object>());
                            }
                            
                            debug(':::::Setting Results::: accessSequence.Name = ' + accessSequence.Name);
                            debug(':::::ResultValue = ' + as_resultValue);
                            debug(':::::ResultValueStr = ' + as_resultValueStr);
                            debug(':::::ResultValueDate = ' + as_resultValueDate);
                            
                            Results.get(accessSequence.Name).put('ResultValue', as_resultValue);
                            Results.get(accessSequence.Name).put('ResultValueString', as_resultValueStr);
                            Results.get(accessSequence.Name).put('ResultValueDate', as_resultValueDate);
                            
                            //
                            // Generate Pricing Results record
                            //
                            VCG_CPQ_Quote_Product_Pricing_Result__c pricingResult = new VCG_CPQ_Quote_Product_Pricing_Result__c(
                                                                                                                                        Quote_Product__r = quoteProduct,
                                                                                                                                        Sequence__c = ppSequence.Sequence__c,
                                                                                                                                        Access_Sequence__c = accessSequence.Name,
                                                                                                                                        Result_Type__c = as_resultType,
                                                                                                                                        Result_Value__c = as_resultValue,
                                                                                                                                        Result_Value_String__c = as_resultValueStr,
                                                                                                                                        Result_Value_Date__c = as_resultValueDate,
                                                                                                                                        Assign_To__c = accessSequence.Assign_To__c,
                                                                                                                                        Pricing_Procedure_Sequence__c = ppSequence.Id
                                                                                                                                    );
                            pricingResult.Condition__c = '-- Override --';
                            pricingResult.Pricing_Override__r = overrideRec;
                            // Link back to result record as well
                            overrideRec.Pricing_Result__r = pricingResult;
                            
                            String pricingResultsKey = getPricingResultsKey(quoteProduct);
                            
                            if (!pricingResultsMap.containsKey(pricingResultsKey))
                            {
                                pricingResultsMap.put(pricingResultsKey, new List<VCG_CPQ_Quote_Product_Pricing_Result__c>());
                            }
                            
                            pricingResultsMap.get(pricingResultsKey).add(pricingResult);
                        }
                        else
                        {
                            //
                            // Regular Line-Item Pricing (if not overridden)
                            //
                            
                            VCG_CPQ_Pricing_Condition__c matchingPricingCondition; // this will be set to the Pricing Condition that sets the result value for this access sequence
                            
                            // Throw an error if we have an access sequence with no Pricing Conditions under it
                            if (asConditionListMap == null
                                  || !asConditionListMap.containsKey(accessSequence.Id)
                                  || asConditionListMap.get(accessSequence.Id) == null
                                  || asConditionListMap.get(accessSequence.Id).size() == 0)
                            {
                                throw new VCG_CPQ_Formula.Formula_Exception('No Condition records defined for Access Sequence "' + accessSequence.Name + '"');
                            }
                            
                            // As soon as a Condition record returns a result value, stop. This is the value of the associated Access Sequence
                            debug(':::::Starting ACCESS SEQUENCE:::: AccessSequence Name - '+accessSequence.Name);
                            for (VCG_CPQ_Pricing_Condition__c pricingCondition : asConditionListMap.get(accessSequence.Id) )
                            {
                                debug(':::::Starting Pricing Conditions Loop :::: Pricing Condition Name - '+pricingCondition.Name);
                                //
                                // Start data lookup part
                                //
                                // Do data lookup if there is a data key defined, or a scale field (which allows tiering 
                                // for all records on just a scale field, no key) - i.e. to determine a band that is 
                                // dependent on LMQ only and not any other factor
                                if (pricingCondition.Data_Key_Definition__c != null || pricingCondition.Data_Scale_Field_1__c != null)
                                {
                                    
                                    //
                                    // Data Lookup part
                                    //
                                    
                                    Decimal price = null;
                                    String key = '';
                                    if (pricingCondition.Data_Key_Definition__c != null)
                                    {
                                        // In the Condition record, use the Data Key Definition field value
                                        // Split it on the delimiter (';' for now)
                                        for (String keyDefItem : pricingCondition.Data_Key_Definition__c.split(';'))
                                        {
                                            // Starting at the Quote Line Item record, walk through the fields and related objects to get the 
                                            // Final value referenced by the values in the previous line
                                            // Concatinate all resulting values together to form key (separated by ... let's use '|' for now)
                                            debug('====> Adding ' + keyDefItem + ' to key: ' + key);
                                            if (keyDefItem.startsWith('$Results'))
                                            {
                                                // Use previously calculated/generated value as a key component
                                                List<String> parts = keyDefItem.split('\\.');
                                                String seqName = parts[1];
                                                String what = parts[2];
                                                if (Results.containsKey(seqName)) {
                                                    key += (key == '' ? '' : '|') + String.valueOf(Results.get(seqName).get(what));
                                                }
                                                else {
                                                    key += (key == '' ? '' : '|')+ '';
                                                }
                                            }
                                            else if (keyDefItem == 'CurrencyISOCode' && !isMultiCurrencyEnabled)
                                            {
                                                key += (key == '' ? '' : '|') + UserInfo.getDefaultCurrency();
                                            }
                                            else
                                            {
                                                // Note: do_field_lookup2 can return a null value, which will be converted to the string 'null'
                                                String s = VCG_CPQ_Formula.do_field_lookup2(quoteProduct, keyDefItem);
                                                key += (key == '' ? '' : '|') + (s == null ? '' : s);
                                            }
                                            debug('====> Added ' + keyDefItem + ' to key: ' + key);
                                        }
                                    }
                                    debug('====> Data key definition: ' + pricingCondition.Data_Key_Definition__c);
                                    debug('====> Final data lookup key: ' + key);
                                    
                                    // Get matching data recs if the key is defined, or if we have a data scale field 
                                    // (with no Data_Key_Definition -- i.e. tier dependent on just the tier value)
// LC 10/1: try allowing null keys... there are instances where we have default values that require a null value as the data lookup key
//                                    if (key != '' || (pricingCondition.Data_Key_Definition__c == null && pricingCondition.Data_Scale_Field_1__c != null))
                                    if (pricingCondition.Data_Key_Definition__c != null || pricingCondition.Data_Scale_Field_1__c != null)
                                    {                        
                                        List<VCG_CPQ_Pricing_Condition_Data__c> matches = GetMatchingDataRecs(key, conditionDataMap.get(pricingCondition.Id));
                                        
                                        debug(':::::DATA MATCHES:::: ' + matches);
                                        
                                        if (matches.size() > 0)
                                        {
                                            //
                                            // Handle Scaled Cumulative first -- Scaled Cumulative results in multiple 'match' lines that must be applied
                                            // in sequence
                                            //
                                            if (pricingCondition.Type__c == 'Scaled Cumulative')
                                            {
                                                //
                                                // For scaled cumulative, if we have multiple Scale fields, only the last Scale field is considered "cumulative"
                                                // all other scale fields are applied as standard tiering
                                                //
                                                if (pricingCondition.Data_Scale_Field_2__c == null) // See if we have a 2nd level scale field
                                                {
                                                    // No, just a scale field 1, do scaled cumulative on data scale 1
                                                    Decimal scaleVal = get_scale_field_value(quoteProduct, pricingCondition.Data_Scale_Field_1__c, Results);
                                                    
                                                    //
                                                    // Walk through the tier levels and apply each tier to the specified quantity
                                                    //
                                                    as_lookupResultValue = 0; // start at zero
                                                    Decimal prevDataScaleValue = 0;
                                                    for (VCG_CPQ_Pricing_Condition_Data__c match : matches)
                                                    {
                                                        if (match.Data_Scale_1__c < scaleVal)
                                                        {
                                                            as_lookupResultValue += ConvertCurrencyIfNeeded(quote, match, match.Multiply_by_Quantity__c ? match.Result_Value__c * (match.Data_Scale_1__c - prevDataScaleValue) : match.Result_Value__c );
                                                            prevDataScaleValue = match.Data_Scale_1__c;
                                                        }
                                                        else
                                                        {
                                                            // Found the tier level above the scaleVal value we have - break after this
                                                            as_lookupResultValue += ConvertCurrencyIfNeeded(quote, match, match.Multiply_by_Quantity__c ? match.Result_Value__c * (scaleVal - prevDataScaleValue) : match.Result_Value__c );
                                                            break;
                                                        }
                                                    }
                                                }
                                                else
                                                {
                                                    // Yes, we have a Data Scale Field 2, so filter down the matches by Data Scale Field 1
                                                    Decimal scaleVal = get_scale_field_value(quoteProduct, pricingCondition.Data_Scale_Field_1__c, Results);
                                                    
                                                    matches = GetScale1DataMatch(scaleVal, matches);
                                                    
                                                    // Now, process the matches for Data Scale Field 2
                                                    if (pricingCondition.Data_Scale_Field_3__c == null) // See if we have a 3rd level scale field
                                                    {
                                                        // No, only scale field 2, do scaled cumulative on data scale 2
                                                        scaleVal = get_scale_field_value(quoteProduct, pricingCondition.Data_Scale_Field_2__c, Results);
                                                        
                                                        //
                                                        // Walk through the tier levels and apply each tier to the specified quantity
                                                        //
                                                        as_lookupResultValue = 0; // start at zero
                                                        Decimal prevDataScaleValue = 0;
                                                        for (VCG_CPQ_Pricing_Condition_Data__c match : matches)
                                                        {
                                                            if (match.Data_Scale_2__c < scaleVal)
                                                            {
                                                                as_lookupResultValue += ConvertCurrencyIfNeeded(quote, match, match.Multiply_by_Quantity__c ? match.Result_Value__c * (match.Data_Scale_2__c - prevDataScaleValue) : match.Result_Value__c );
                                                                prevDataScaleValue = match.Data_Scale_2__c;
                                                            }
                                                            else
                                                            {
                                                                // Found the tier level above the scaleVal value we have - break after this
                                                                as_lookupResultValue += ConvertCurrencyIfNeeded(quote, match, match.Multiply_by_Quantity__c ? match.Result_Value__c * (scaleVal - prevDataScaleValue) : match.Result_Value__c );
                                                                break;
                                                            }
                                                        }
                                                    }
                                                    else
                                                    {
                                                        // Yes, we have a Data Scale Field 3, so filter down the matches by Data Scale Field 2
                                                        scaleVal = get_scale_field_value(quoteProduct, pricingCondition.Data_Scale_Field_2__c, Results);
                                                        
                                                        matches = GetScale2DataMatch(scaleVal, matches);
                                                        
                                                        // Now, process the matches for Data Scale Field 3
                                                        scaleVal = get_scale_field_value(quoteProduct, pricingCondition.Data_Scale_Field_3__c, Results);
                                                        
                                                        //
                                                        // Walk through the tier levels and apply each tier to the specified quantity
                                                        //
                                                        as_lookupResultValue = 0; // start at zero
                                                        Decimal prevDataScaleValue = 0;
                                                        for (VCG_CPQ_Pricing_Condition_Data__c match : matches)
                                                        {
                                                            if (match.Data_Scale_3__c < scaleVal)
                                                            {
                                                                as_lookupResultValue += ConvertCurrencyIfNeeded(quote, match, match.Multiply_by_Quantity__c ? match.Result_Value__c * (match.Data_Scale_3__c - prevDataScaleValue) : match.Result_Value__c );
                                                                prevDataScaleValue = match.Data_Scale_3__c;
                                                            }
                                                            else
                                                            {
                                                                // Found the tier level above the scaleVal value we have - break after this
                                                                as_lookupResultValue += ConvertCurrencyIfNeeded(quote, match, match.Multiply_by_Quantity__c ? match.Result_Value__c * (scaleVal - prevDataScaleValue) : match.Result_Value__c );
                                                                break;
                                                            }
                                                        }
                                                    }
                                                }
                                                
                                                if (as_lookupResultValue != null)
                                                    as_lookupResultType = matches[0].Result_Type__c;
                                                
                                            } // End of Scaled Cumulative Pricing
                                            else
                                            { // Start of single or Scaled pricing -- both result in a single matching record that determines price.
                                                /** @todo  Can we make this cleaner? */
                                                if (pricingCondition.Data_Scale_Field_1__c != null)
                                                {
                                                    Decimal scaleVal = get_scale_field_value(quoteProduct, pricingCondition.Data_Scale_Field_1__c, Results);
                                                    
                                                    matches = GetScale1DataMatch(scaleVal, matches);
                                                    
                                                    if (pricingCondition.Data_Scale_Field_2__c != null)
                                                    {
                                                        scaleVal = get_scale_field_value(quoteProduct, pricingCondition.Data_Scale_Field_2__c, Results);
                                                        
                                                        matches = GetScale2DataMatch(scaleVal, matches);
                                                        
                                                        if (pricingCondition.Data_Scale_Field_3__c != null)
                                                        {
                                                            scaleVal = get_scale_field_value(quoteProduct, pricingCondition.Data_Scale_Field_3__c, Results);
                                                            
                                                            matches = GetScale3DataMatch(scaleVal, matches);
                                                        }
                                                    }
                                                }
                                                
                                                if (matches.size() > 1)
                                                {
                                                    /** @todo  Throw error, should not end up with multiple records here */
                                                }
                                                else if (matches.size() == 0)
                                                {
                                                    // No data match from this condition, skip to next condition
                                                }
                                                else
                                                {
                                                    // Got a match from the data, assign it as the Access Sequence's lookup result value
                                                    if (matches[0].Result_Type__c == 'String')
                                                    {
                                                        as_lookupResultValueStr = matches[0].Result_Value_String__c;
                                                    }
                                                    else
                                                    {
                                                        if (matches[0].Multiply_by_Quantity__c == false)
                                                        {
                                                            // If Multiply_by_Quantity__c is false, then the Result_Value__c is the total
                                                            // value for the line, so we use the actual value as the total value
                                                            as_lookupResultValue = ConvertCurrencyIfNeeded(quote, matches[0], matches[0].Result_Value__c);
                                                        }
                                                        else
                                                        {
                                                            // Otherwise, we need to multiply the result value times the quantity to get the total value
                                                            as_lookupResultValue = ConvertCurrencyIfNeeded(quote, matches[0], matches[0].Result_Value__c) * quoteProduct.License_Metric_Quantity__c;
                                                        }
                                                    }
                                                    
                                                    as_lookupResultType = matches[0].Result_Type__c;
                                                    
                                                    // Now, we have a result value for the Access Sequence, so we need to stop
                                                    // processing Pricing Conditions (see below)
                                                }
                                            }
                                        }
                                    }
                                    
                                    // We are now at the end of the data lookup block, if we are here and we
                                    // *don't* have a lookup result, then we need to jump back and process
                                    // the next Pricing Condition and skip the below code for this loop
                                    
                                    if (as_lookupResultValue == null && as_lookupResultValueStr == null)
                                    {
                                        continue;
                                    }
                                } /* End data lookup part */
                                
                                // NOTE NOTE NOTE: The following code should only be executed if there is no data lookup part,
                                //                 or if the data lookup part has found a value, or if we've looped through
                                //                 all possible conditions and *didn't* find a value.
                                
                                //
                                // Store the lookup result in a "Results" map for this access sequence
                                // so it can be referred to by future calculations
                                //
                                if (as_lookupResultValue != null || as_lookupResultValueStr != null)
                                {
                                    if (!Results.containsKey(accessSequence.Name))
                                    {
                                        Results.put(accessSequence.Name, new Map<String,Object>());
                                    }
                                    debug(':::::Setting LookUp Results::: accessSequence.Name = '+accessSequence.Name);
                                    debug(':::::LookupResultValue = '+as_lookupResultValue);
                                    debug(':::::LookupResultValueString = '+as_lookupResultValueStr);
                                    Results.get(accessSequence.Name).put('LookupResultValue', as_lookupResultValue);
                                    Results.get(accessSequence.Name).put('LookupResultValueString', as_lookupResultValueStr);
                                    
                                }
                                
                                // If we are here, then we have either found a lookup result, or we weren't looking for
                                // a lookup value, in either case we need to see if there is a calculation and do the
                                // calculation
                                
                                if (pricingCondition.Calculation_Compiled__c != null)
                                {
//                                  System.debug('====> Evaluating formula: ' + pricingCondition.Calculation_Compiled__c);
                                    VCG_CPQ_Formula.Result res;
                                    try {
                                        res = VCG_CPQ_Formula.evaluate(quoteProduct, Results, existingAssets, pricingCondition.Calculation_Compiled__c);
                                    }
                                    catch (Exception e) {
                                        throw new VCG_CPQ_Formula.Formula_Exception('Error evaluating Pricing Condition "' + pricingCondition.Name + '": ' + e.getMessage() + '\n' + e.getStackTraceString());
                                    }
                                    if (res == null)
                                    {
                                        throw new VCG_CPQ_Formula.Formula_Exception('Error evaluating Pricing Condition - No result returned for "' + pricingCondition.Name + '"');
                                    }
                                    if (res.type == null
                                        || res.type == 'Decimal'
                                        || res.type == 'Boolean'
                                        || res.type == 'String'
                                        || res.type == 'Date')
                                    {
                                    as_resultType = res.type;
                                    as_resultValue = res.value;
                                    as_resultValueStr = res.str_val;
                                        as_resultValueDate = (Date)res.obj_val;
                                    }
                                    else
                                    {
                                        throw new VCG_CPQ_Formula.Formula_Exception('Unsupported formula result type: "' + res.type + '"');
                                    }
                                }
                                else if (as_lookupResultValue != null || as_lookupResultValueStr != null)
                                {
                                    // No calculation but we have a lookup result, copy that over to the Access Sequence result
                                    as_resultType = as_lookupResultType;
                                    as_resultValue = as_lookupResultValue;
                                    as_resultValueStr = as_lookupResultValueStr;
                                }
                                
                                debug('====> Result Value: ' + as_resultValue);
                                debug('====> Result Value (String): ' + as_resultValueStr);
                                debug('====> Result Value (Date): ' + as_resultValueDate);
                                
                                
                                //
                                // Store the result in a "Results" map for this access sequence
                                // so it can be referred to by future calculations
                                //
                                if (as_resultValue != null || as_resultValueStr != null || as_resultValueDate != null)
                                {
                                    if (!Results.containsKey(accessSequence.Name))
                                    {
                                        Results.put(accessSequence.Name, new Map<String,Object>());
                                    }
                                    
                                    debug(':::::Setting Results::: accessSequence.Name = '+accessSequence.Name);
                                    debug(':::::ResultValue = '+as_resultValue);
                                    debug(':::::ResultValueStr = '+as_resultValueStr);
                                    debug(':::::ResultValueDate = '+as_resultValueDate);
                                    
                                    Results.get(accessSequence.Name).put('ResultValue', as_resultValue);
                                    Results.get(accessSequence.Name).put('ResultValueString', as_resultValueStr);
                                    Results.get(accessSequence.Name).put('ResultValueDate', as_resultValueDate);
                                    
                                    // Capture condition as the one that generated the result
                                    matchingPricingCondition = pricingCondition;
                                    
                                }
                                
                                
                            
                                //
                                // Finally, if we have a result value, we need to break out of the Pricing Calculations loop
                                //
                                if (as_resultValue != null || as_resultValueStr != null || as_resultValueDate != null)
                                {
                                    break;
                                }
                                
                            } /* End Pricing Conditions loop */
                            
                            
                            //
                            // Done processing conditions for this Access Sequence, we've either determined a value
                            // or it is an error
                            //
                            /** @todo  Handle 'no result' errors - note: there are instances - like Deal Reg Discount where a condition lookup with no match is ok. Need to figure out a way to allow/handle that. */
        //                    if (as_resultValue == null) {
        //                        throw new VCG_CPQ_Formula.Formula_Exception('No pricing calculation found for Access Sequence: ' + accessSequence.Name);
        //                    }
                            
                            //
                            // Capture Pricing Calculation Results
                            //
                            VCG_CPQ_Quote_Product_Pricing_Result__c pricingResult = new VCG_CPQ_Quote_Product_Pricing_Result__c(
                                                                                                                                        Quote_Product__r = quoteProduct,
                                                                                                                                        Sequence__c = ppSequence.Sequence__c,
                                                                                                                                        Access_Sequence__c = accessSequence.Name,
                                                                                                                                        Lookup_Result_Type__c  = as_lookupResultType,
                                                                                                                                        Lookup_Result_Value__c = as_lookupResultValue,
                                                                                                                                        Lookup_Result_Value_String__c = as_lookupResultValueStr,
                                                                                                                                        Result_Type__c = as_resultType,
                                                                                                                                        Result_Value__c = as_resultValue,
                                                                                                                                        Result_Value_String__c = as_resultValueStr,
                                                                                                                                        Result_Value_Date__c = as_resultValueDate,
                                                                                                                                        Assign_To__c = accessSequence.Assign_To__c,
                                                                                                                                        Pricing_Procedure_Sequence__c = ppSequence.Id
                                                                                                                                    );
                            if (matchingPricingCondition != null) {
                                pricingResult.Condition__c = matchingPricingCondition.Name;
                                pricingResult.Calculation_Summary__c = matchingPricingCondition.Calculation__c;
                            }
                            
                            String pricingResultsKey = getPricingResultsKey(quoteProduct);
                            
                            if (ppSequence.Id != null){
                                if (!pricingResultsMap.containsKey(pricingResultsKey))
                                {
                                    pricingResultsMap.put(pricingResultsKey, new List<VCG_CPQ_Quote_Product_Pricing_Result__c>());
                                }
                            
                                pricingResultsMap.get(pricingResultsKey).add(pricingResult);
                            }
                        
                            
                            //
                            // End regular Line-Item pricing
                            //
                        }
                        
                        // If the Access Sequence has an "Assign To" field designated, assign
                        // the result value to that field.
                        if (accessSequence.Assign_To__c != null)
                        {
                            if (as_resultValue != null)
                            {
                                if (VCG_CPQ_Formula.GetFieldType(quoteProduct, accessSequence.Assign_To__c).name() == 'Boolean')
                                {
                                    quoteProduct.put(accessSequence.Assign_To__c, (as_resultValue == 1 ? true : false));
                                }
                                else
                                {
                                    // Automatically round the result value to the field's scale
                                    Decimal val = as_resultValue;
                                    Integer scale = VCG_CPQ_Formula.getFieldScale(quoteProduct, accessSequence.Assign_To__c);
                                    if (scale != null)
                                    {
                                        val = as_resultValue.setScale(scale, RoundingMode.HALF_UP);
                                    }
                                    
                                    // Assign the value
                                    quoteProduct.put(accessSequence.Assign_To__c, val);
                                }
                            }
                            else if (as_resultValueStr != null)
                            {
                                quoteProduct.put(accessSequence.Assign_To__c, as_resultValueStr);
                            }
                            else if (as_resultValueDate != null)
                            {
                                quoteProduct.put(accessSequence.Assign_To__c, as_resultValueDate);
                            }
                            else
                            {
                                // We have a null result, we still want to assign that to the Assign_To__c field
                                // because that value may have been set the last time we priced the record
                                // but now needs to be cleared.
                                if (VCG_CPQ_Formula.GetFieldType(quoteProduct, accessSequence.Assign_To__c).name() == 'Boolean')
                                {
                                    quoteProduct.put(accessSequence.Assign_To__c, false);
                                }
                                else
                                {
                                    quoteProduct.put(accessSequence.Assign_To__c, null);
                                }
                            }
                        }
                        debug(':::::ENDING ACCESS SEQUENCE:::: AccessSequence Name - '+accessSequence.Name);
                        
                        // Turn debug output off if accessSequence.Debug__c is true
                        if (accessSequence.Debug__c)
                        {
                            debug('====> Debugging done for access sequence: ' + accessSequence);
                            showDebugOutput--;
                        }
                    } // end ppSequenceList (Access Sequence) loop
                    
                } //end quoteProduct loop
            
            } // end if (Header) else if (Line-Type) blocks
        
        } // end PP loop
        
        //
        // If we reached here, then we have successfully priced the quote. For auto-added
        // lines, we can clear the autoAddedValueCache -- it doesn't need to persist
        // to the next round of pricing. This will clear the values in the situation
        // where the auto-added QP record wasn't actually added this round of pricing, so
        // if it gets added back next round, we want all values to be reset to empty values
        // (or to the values passed in from the UI)
        //
        currController.autoAddedValueCache = null;
     }
    
    /**
     * @description  Generate the Pricing Results Key from the quote product record
     *
     *               This is expected to be a unique identifier for each Quote Product record.
     * 
     * @todo  Switch to using:
     *          - pipes instead of dashes
     *          - product SKU or Id instead of product name
     *
     * @author  Lawrence Coffin <lawrence.coffin@cloudsherpas.com>
     * @since   2.Sep.2014
     */
    public static String getPricingResultsKey(VCG_CPQ_Quote_Product__c quoteProduct)
    {
        return quoteProduct.Product_Group__c + '-' + quoteProduct.Line_Type__c + '-' + quoteProduct.Product__r.Name;
    }
    
    /**
     * @description  Generate the overrideKey from the Quote Product and Pricing Procedure Sequence records
     * 
     *               This is expected to be a unique identifier for each Override record (which is unique 
     *               Quote Product records + the pricing procedure sequence id for the pricing results).
     * 
     * @todo  Switch to using:
     *          - pipes instead of dashes
     *          - product SKU or Id instead of product name
     *
     * @author  Lawrence Coffin <lawrence.coffin@cloudsherpas.com>
     * @since   2.Sep.2014
     */
    public static String getOverrideKey(VCG_CPQ_Quote_Product__c quoteProduct, VCG_CPQ_Pricing_Procedure_Sequence__c ppSequence)
    {
        /** @todo Update code to handle Product_Group__c == null properly (should be '') */
        return quoteProduct.Product_Group__c 
                + '-' + quoteProduct.Line_Type__c 
                + '-' + quoteProduct.Product__r.Name 
                + '-' + ppSequence.Id;
    }
    
    /**
     * @description  Get the Pricing Results Key from the Override Key
     *
     * @author  Lawrence Coffin <lawrence.coffin@cloudsherpas.com>
     * @since   2.Sep.2014
     */
    public static String OverrideKeyToPricingResultsKey(String overrideKey)
    {
        List<String> keyParts = overrideKey.split('-');
        System.debug('====> keyParts: ' + keyParts);
        
        String productGroup = keyParts[0];
        String lineType = keyParts[1];
        String productName = keyParts[2];
        
        return productGroup + '-' + lineType + '-' + productName;
    }
    
    
    /**
     * @description  Get the Pricing Procedure Sequence Id from the Override Key
     *
     * @author  Lawrence Coffin <lawrence.coffin@cloudsherpas.com>
     * @since   2.Sep.2014
     */
    public static Id getPricingProcedureSequenceIdFromOverrideKey(String overrideKey)
    {
        List<String> keyParts = overrideKey.split('-');
        System.debug('====> keyParts: ' + keyParts);
        
        Id ppSequenceId = keyParts[3];
        
        return ppSequenceId;
    }
    
    /**
     * @description  Returns all rows matching on key == Data_Key__c, if key == null (or ''), then return
     *               all records with a null Data_Key__c - this allows for tiering based on just a scale 
     *               value -- i.e. look up seat band based only on LMQ
     */
    public static Decimal get_scale_field_value(sObject obj, String scaleFieldRef, Map<String,Map<String,Object>> Results)
    {
        if (scaleFieldRef.startsWith('$Results'))
        {
            // Use previously calculated/generated value as a key component
            List<String> parts = scaleFieldRef.split('\\.');
            String seqName = parts[1];
            String what = parts[2];
            
            if (!Results.containsKey(seqName))
            {
                throw new VCG_CPQ_Formula.Formula_Exception('Access Sequence "' + seqName + '" not found in $Results list');
            }
            else
            {
                return (Decimal)(Results.get(seqName).get(what));
            }
        }
        else
        {
            // Regular field lookup
            return VCG_CPQ_Formula.do_field_lookup(obj, scaleFieldRef);
        }
    }
    
    /**
     * @description  Returns all rows matching on key == Data_Key__c, if key == null (or ''), then return
     *               all records with a null Data_Key__c - this allows for tiering based on just a scale 
     *               value -- i.e. look up seat band based only on LMQ
     */
    public static List<VCG_CPQ_Pricing_Condition_Data__c> GetMatchingDataRecs(String key, List<VCG_CPQ_Pricing_Condition_Data__c> recs) {
        debug('====> Called with Recs: ' + recs);
        List<VCG_CPQ_Pricing_Condition_Data__c> matches = new List<VCG_CPQ_Pricing_Condition_Data__c>();
        
        if (recs != null) {
            for ( VCG_CPQ_Pricing_Condition_Data__c pcd : recs ) {
                if ((key == null || key == '') && pcd.Data_Key__c == null) {
                    matches.add(pcd);
                }
                else if (key == pcd.Data_Key__c) {
                    matches.add(pcd);
                }
            }
        }
        
        debug('====> Returning matches: ' + matches);
        
        return matches;
    }
    
    /**
     * @description  Returns all rows where scaleVal >= Data_Scale_1__c (all rows with the next highest Data_Scale_1__c value)
     */
    public static List<VCG_CPQ_Pricing_Condition_Data__c> GetScale1DataMatch(Decimal scaleVal, List<VCG_CPQ_Pricing_Condition_Data__c> recs) {
        List<VCG_CPQ_Pricing_Condition_Data__c> matches = new List<VCG_CPQ_Pricing_Condition_Data__c>();
        
        // Note, this assumes the records are sorted by Data_Scale_x records in ascending order
        
        // Skip over records with values less than the scaleVal
        while (recs.size() > 0 && recs[0].Data_Scale_1__c < scaleVal) recs.remove(0);
        
        // Next Data_Scale_x value should be the matching tier we want
        Decimal targetScaleVal = 0;
        if (recs.size() > 0) targetScaleVal = recs[0].Data_Scale_1__c;
        
        while (recs.size() > 0 && recs[0].Data_Scale_1__c == targetScaleVal) matches.add(recs.remove(0));
        
        
        return matches;
    }
    
    /**
     * @description  Returns all rows where scaleVal >= Data_Scale_2__c (all rows with the next highest Data_Scale_2__c value)
     */
    public static List<VCG_CPQ_Pricing_Condition_Data__c> GetScale2DataMatch(Decimal scaleVal, List<VCG_CPQ_Pricing_Condition_Data__c> recs) {
        List<VCG_CPQ_Pricing_Condition_Data__c> matches = new List<VCG_CPQ_Pricing_Condition_Data__c>();
        
        // Note, this assumes the records are sorted by Data_Scale_x records in ascending order
        
        // Skip over records with values less than the scaleVal
        while (recs.size() > 0 && recs[0].Data_Scale_2__c < scaleVal) recs.remove(0);
        
        // Next Data_Scale_x value should be the matching tier we want
        Decimal targetScaleVal = 0;
        if (recs.size() > 0) targetScaleVal = recs[0].Data_Scale_2__c;
        
        while (recs.size() > 0 && recs[0].Data_Scale_2__c == targetScaleVal) matches.add(recs.remove(0));
        
        
        return matches;
    }
    
    /**
     * @description  Returns all rows where scaleVal >= Data_Scale_3__c (all rows with the next highest Data_Scale_3__c value)
     */
    public static List<VCG_CPQ_Pricing_Condition_Data__c> GetScale3DataMatch(Decimal scaleVal, List<VCG_CPQ_Pricing_Condition_Data__c> recs) {
        List<VCG_CPQ_Pricing_Condition_Data__c> matches = new List<VCG_CPQ_Pricing_Condition_Data__c>();
        
        // Note, this assumes the records are sorted by Data_Scale_x records in ascending order
        
        // Skip over records with values less than the scaleVal
        while (recs.size() > 0 && recs[0].Data_Scale_3__c < scaleVal) recs.remove(0);
        
        // Next Data_Scale_x value should be the matching tier we want
        Decimal targetScaleVal = 0;
        if (recs.size() > 0) targetScaleVal = recs[0].Data_Scale_3__c;
        
        while (recs.size() > 0 && recs[0].Data_Scale_3__c == targetScaleVal) matches.add(recs.remove(0));
        
        
        return matches;
    }
    
    
    public static Map<String, Schema.DescribeFieldResult> describeObjectFields(String objectName)
    {
        Map<String, Schema.DescribeFieldResult> results = new Map<String, Schema.DescribeFieldResult>();
        Schema.DescribeSObjectResult d;
        
        if (objectName == 'VCG_CPQ_Quote__c')
            d = VCG_CPQ_Quote__c.sObjectType.getDescribe();
        else if (objectName == 'VCG_CPQ_Quote_Product__c')
            d = VCG_CPQ_Quote_Product__c.sObjectType.getDescribe();
        if (objectName == 'Opportunity')
            d = Opportunity.sObjectType.getDescribe();
        if (objectName == 'OpportunityLineItem')
            d = OpportunityLineItem.sObjectType.getDescribe();
        if (objectName == 'Asset__c')
            d = Asset__c.sObjectType.getDescribe();
            
        Map<String, Schema.Sobjectfield> mapFieldList = d.fields.getMap();
        
        for (Schema.SObjectField field : mapFieldList.values())  
        {  
            Schema.DescribeFieldResult fieldResult = field.getDescribe();  
//            if (fieldResult.isAccessible())  
//            {  
                results.put(fieldResult.getName(), fieldResult);
//            }  
        }
        
        return results;
    }
    
    public static Boolean checkMCEnabled()
    {
        return UserInfo.isMultiCurrencyOrganization();
    }
    
    /**
     * Method to retrieve the default values for a new quote
     *
     * @author  Nathan Shinn <nshinn@cloudsherps.com>
     */
    public static void setQuoteDefaults(Opportunity opp, VCG_CPQ_Quote__c quote)
    {
        //Map<String, Schema.DescribeFieldResult> opptyFieldsDescribed = describeObjectFields('Opportunity');
        Map<String, Schema.DescribeFieldResult> quoteFieldsDescribed = describeObjectFields('VCG_CPQ_Quote__c');
        
        for (VCG_CPQ_Opportunity_Quote_Map__c oqm : [Select Source__c, Quote_Field__c, Source_Type__c 
                                                      from VCG_CPQ_Opportunity_Quote_Map__c
                                                     where Active__c = true]) 
        {
            string thisField = oqm.Quote_Field__c;
            string dataType = '';
            
            if (thisField == 'CurrencyISOCode')
            {
                dataType = 'String';
            }
            else if (quoteFieldsDescribed.containsKey(thisField))
            {
                dataType = quoteFieldsDescribed.get(thisField).getSOAPType().name();
                if (dataType == null || dataType == '')
                {
                    dataType = quoteFieldsDescribed.get(thisField).getSOAPType().name();
                }
            }
            
            Object val;
            
            if (oqm.Source_Type__c == 'Formula')
            {
                VCG_CPQ_Formula.Result res = VCG_CPQ_Formula.evaluate(opp, oqm.Source__c);
                if (res.type == 'String') {
                    val = res.str_val;
                }
                else if (res.type == 'Boolean') {
                    val = (res.value == 1 ? true : false);
                }
                else if (res.type == 'Date') {
                    val = res.obj_val;
                }
                else {
                    val = res.value;
                }
            }
            else if (oqm.Source__c == 'CurrencyIsoCode')
            {
                val = GetCurrencyIsoCode(opp);
            }
            else {
                val = opp.get(oqm.Source__c);
            }
            
            //Cast the source data to the destination data type
            if (thisField == 'CurrencyIsoCode')
            {
                if (UserInfo.isMultiCurrencyOrganization())
                {
                    quote.put(thisField, String.valueOf(val));
                }
                // else, If not multi-currency org, skip and don't try to set CurrencyIsoCode
            }
            else if (dataType == 'Boolean')
                quote.put(thisField, Boolean.valueOf(val));
            else if (dataType == 'Date' )
                quote.put(thisField, Date.valueOf(val));
            else if (dataType == 'DateTime')
                quote.put(thisField, DateTime.valueOf(val));
            else if (dataType == 'Double')
                quote.put(thisField, Double.valueOf(val));
            else if (dataType == 'Integer')
                quote.put(thisField, Integer.valueOf(val));
            else if (dataType == 'String')
                quote.put(thisField, String.valueOf(val));
            else if (dataType == 'Id')
                quote.put(thisField, (Id)val);
            else {
                debug('====> Unsupported field type: ' + dataType);
                throw new VCG_CPQ_Formula.Formula_Exception('Unsupported field type: ' + dataType + ' for Field ' + thisField);
            }
             
        }
    }
    
    /**
     * Method to retrieve the related object data for pricing formula calculations
     *
     * @author  Nathan Shinn <nshinn@cloudsherps.com>
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
    public static void populateFormulaData(VCG_CPQ_Quote__c quote)
    {
//        showDebugOutput++;
        debug('====> starting populateFormulaData()');
        //
        //look at the quote to determine which referenced fields have an Id. 
        //This should have been populated via the Default mapping on load or in the UI by the user
        //
        //1. create a list of relationship fields
        Map<String, Schema.SObjectField> fieldMap = VCG_CPQ_Quote__c.sObjectType.getDescribe().fields.getMap();
        
        //2. create a map of related objects with Ids
        Map<String,ObjectIdPair> relationshipObjects = new Map<String, ObjectIdPair>();
        for (String field : fieldMap.keySet())
        {
            List <Schema.sObjectType> relatedObject = fieldMap.get(field).getDescribe().getReferenceTo();
            if (relatedObject.size() > 0)
            {
                //debug(relatedObject);
                //debug( fieldMap.get(field).getDescribe().getRelationshipName() );
                string relationshipName = fieldMap.get(field).getDescribe().getRelationshipName();
                string objectName = relatedObject[0].getDescribe().getName();
                
                try //the field may not be present in the object instance...
                {
                    if (quote.get(field) != null)
                    {
                        ObjectIdPair pair = new ObjectIdPair(objectName, (String)quote.get(field));
                        relationshipObjects.put(relationshipName.toLowerCase(), pair);
                    }
                }
                catch(Exception e){}
            }
        }
        debug('====> relationshipObjects: ' + relationshipObjects);
        
        
        
        //iterate through the formula field data
        
        // Load up Needs Fields from pricing procedures and field layouts
        Set<String> needsFields = new Set<String>();
        for (VCG_CPQ_Pricing_Procedure__c pp : [SELECT Needs_Fields__c FROM VCG_CPQ_Pricing_Procedure__c])
        {
            if (pp.Needs_Fields__c != null)
                needsFields.add(pp.Needs_Fields__c.toLowerCase());
        }
        for (VCG_CPQ_Page_Layout__c fieldDef : [SELECT Needs_Fields__c FROM VCG_CPQ_Page_Layout__c])
        {
            if (fieldDef.Needs_Fields__c != null)
                needsFields.add(fieldDef.Needs_Fields__c.toLowerCase());
        }
        
        //find the lookup and map objects related to the quote
        Map<String, String> relatedObjectSelectListMap = new Map<String, String>();
        for (String needsFieldStr : new List<String>( needsFields ))
        {
            if (needsFieldStr == null || !needsFieldStr.containsIgnoreCase('Quote__r'))
                continue;//can't filter for this against Needs_Fields__c in SOQL
                
            //create SOQL Select clause to populate the data in the related objects
            for (String field : needsFieldStr.split(';'))
            {
                
                debug('====> populateFormulaData - Checking field: ' + field);
                
                if (field.startsWithIgnoreCase('Quote__r'))
                {
                    String queryfield = field.substring(field.indexOf('.', 0)+1, field.length());
                    
                    // Don't want to fail on Quote fields themselves -- i.e. Quote__r.Temp_Seat_Band__c
                    if (queryfield.indexOf('.', 0) >= 0)
                    {
                        String keyField = queryfield.substring(0,queryfield.indexOf('.', 0));
                        queryfield = queryfield.substring(queryfield.indexOf('.', 0)+1, queryfield.length());
                        
                        debug('====> keyField: ' + keyField);
                        debug('====> queryfield: ' + queryfield);
                        if (keyField.containsIgnoreCase('__r'))
                        {
                            debug('====> populateFormulaData - want field: ' + field);
                            
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
                        }
                        else {
                            debug('====> populateFormulaData - don\'t want field: ' + field);
                        }
                    }
                }
            }
        }
        debug('====> relatedObjectSelectListMap: ' + relatedObjectSelectListMap);
        //set the related data
        for (string s : relationshipObjects.keySet())
        {
            ObjectIdPair pair = relationshipObjects.get(s);
            if (relatedObjectSelectListMap.containsKey(s))
            {
                string query = 'SELECT Id '+relatedObjectSelectListMap.get(s)+' FROM '+pair.objectName+' WHERE Id = \''+pair.objectId+'\'';
                debug('====> populateFormulaData - Loading related Quote object: ' + query);
                quote.putSobject(s, Database.query(query));
            }
        }
        
//        showDebugOutput--;
    }
    
    /**
     * Method to sync the Primary Quote with the opportunity and its quote products with the Opportunity Products
     *
     * @author  Nathan Shinn <nshinn@cloudsherps.com>
     */
    public static void syncPrimaryQuote(VCG_CPQ_Quote__c quote)
    {
        if (!quote.Is_Primary__c)//not the primary quote. return
            return;
        
        util.debug('inside of syncPrimaryQuote');
        
        //
        //set all other quotes' Is_Primary__c to false
        //
        List<VCG_CPQ_Quote__c> otherQuotes = new List<VCG_CPQ_Quote__c>();
        for (VCG_CPQ_Quote__c q : [SELECT Id FROM VCG_CPQ_Quote__c WHERE Opportunity__c = :quote.Opportunity__c AND Id != :quote.Id AND Is_Primary__c = TRUE])
        {
            otherQuotes.add(q);
        }
        
        for (VCG_CPQ_Quote__c q : otherQuotes)
        {
            q.Is_Primary__c = false;
        }
                
        if (otherQuotes.size() > 0)
        {
            update otherQuotes;
        }
        
        //
        // Delete the existing, synced Opportunity Line Items
        //  
        List<OpportunityLineItem> optyLineItems = new list <OpportunityLineItem>();
        for (OpportunityLineItem o : [Select Id from OpportunityLineItem where OpportunityId = :quote.Opportunity__c])
            optyLineItems.add(o);
        
        if (optyLineItems.size() > 0)
            delete optyLineItems;
            
        //
        //sync the opportunity and quote fields
        //
        Opportunity oppty = [Select Id from Opportunity where Id = :quote.Opportunity__c];
        Map<String, Schema.DescribeFieldResult> opptyFieldsDescribed = describeObjectFields('Opportunity');
        for (VCG_CPQ_Quote_Opportunity_Map__c qo : [Select Opportunity_Field__c, Quote_Field__c 
                                                    from VCG_CPQ_Quote_Opportunity_Map__c 
                                                   where Active__c = true])
        {
            string dataType = 'String';//'UNDEFINED';
            if (opptyFieldsDescribed.containsKey(qo.Opportunity_Field__c) )
                dataType = opptyFieldsDescribed.get(qo.Opportunity_Field__c).getSOAPType().name();
             
            Object val = quote.get(qo.Quote_Field__c);
//            System.debug(LoggingLevel.ERROR, '====> Quote.' + qo.Quote_Field__c + ' -> Opp.' + qo.Opportunity_Field__c + ': ' + (val == null ? 'null' : val));
            //Cast the source data to the destination data type
            if (dataType == 'Boolean')
                oppty.put(qo.Opportunity_Field__c, ( val == null ? false : Boolean.valueOf(val) ));
            else if (dataType == 'Date' )
                oppty.put(qo.Opportunity_Field__c, ( val == null ? null : Date.valueOf(val) ));
            else if (dataType == 'DateTime')
                oppty.put(qo.Opportunity_Field__c, ( val == null ? null : DateTime.valueOf(val) ));
            else if (dataType == 'Double')
                oppty.put(qo.Opportunity_Field__c, ( val == null ? null : Double.valueOf(val) ));
            else if (dataType == 'Integer')
                oppty.put(qo.Opportunity_Field__c, ( val == null ? null : Integer.valueOf(val) ));
            else if (dataType == 'String')
                oppty.put(qo.Opportunity_Field__c, ( val == null ? null : String.valueOf(val) ));
            else if (dataType == 'Id')
                oppty.put(qo.Opportunity_Field__c, (Id)val);
            /*else {
                debug('====> Unsupported field type: ' + dataType);
                throw new VCG_CPQ_Formula.Formula_Exception('Unsupported field type: ' + dataType + ' for Field '+qo.Source__c);
            }*/
        }
        //  joseph hutchins - for case no 01930168, we need to update the Oppt.Quote_Products__c field with the list of the primary quote's Quote_product.Product__r.name 
        //  i tried to put that logic in the oppt trigger/quote product trigger/quote trigger but kept getting too many soql queries so after reviewing this
        //  class, i see that an oppt i being updated here AND quote products are being queried.  i am going to move the oppt update to below the 
        //  quote product query so i can add the logic to assign quote products tot he oppt.quote_products__c fiel
        //update oppty;
        util.debug('original oppt update wouldve occured here');
        
        //
        // sync the Opportunity line items with the quote
        //
        
        //
        // retrieve the syncing fields from the mapping object for selection
        //
        Map<string, string> fieldMap = new Map<string, string>();
        
        // Standard fields we need
        fieldMap.put('Id'.toLowerCase(), 'x');
        fieldMap.put('Product__c'.toLowerCase(), 'x');
        fieldMap.put('Product__r.Name'.toLowerCase(), 'x');
        
        /** @todo  Fix this query to be all records, and store to a list, then use that list below rather than re-querying the mappings for each line below! Don't need to filter out Product__c refs anymore. */
        List<VCG_CPQ_Quote_Product_Oppty_Product_Map__c> qliToOliMaps = [SELECT Opportunity_Product_Field__c, Quote_Product_Field__c 
                                                                         FROM VCG_CPQ_Quote_Product_Oppty_Product_Map__c
                                                                         WHERE Active__c = TRUE];
        for (VCG_CPQ_Quote_Product_Oppty_Product_Map__c qo : qliToOliMaps)
        {
            fieldMap.put(qo.Quote_Product_Field__c.toLowerCase('en_US'), 'x');
        }
        
        string quoteProductSoql = 'SELECT ';
        quoteProductSOQL += String.join(new List<String>(fieldMap.keySet()), ',');
        quoteProductSoql += ' FROM VCG_CPQ_Quote_Product__c WHERE Quote__c = \''+quote.Id+'\'';
        System.debug(LoggingLevel.ERROR, '====> Field mapping query: ' + quoteProductSoql);
        
        optyLineItems.clear();
        Map<String, Schema.DescribeFieldResult> oliFieldsDescribed = describeObjectFields('OpportunityLineItem');
        Set<Id> productSet = new Set<Id>();
        Map<Id, Id> productPriceBookmap = new Map<Id, Id>();
         
        List<VCG_CPQ_Quote_Product__c> quoteProducts = new List<VCG_CPQ_Quote_Product__c>();
        
        util.debug('query used to query primary quotes quoteProducts: ' + quoteProductSOQL);
        
        quoteProducts = (List<VCG_CPQ_Quote_Product__c>)database.query(quoteProductSoql) ;
        
        util.debug('quote products queried: ' + (quoteProducts == null ? 0 : quoteProducts.size()));
        
        //  per case no 01930168 - assuming that the quote products of the primary quote was queried successfully here, 
        //  we can assign the oppt.quote_products and then update the oppt that was used to occur before the quote products query
        string quoteProductsToString = createStringOfQuoteProducts(quoteProducts);
        util.debug(quoteProductstoSTring);
        
        if (quoteProducts != null && quoteProducts.size() > 0)
        {
            oppty.put('Quote_Products__c',quoteProductsToString);
        }
        
        util.debug('oppt update about to occur');
        update oppty;
        util.debug('oppt update should have finished');
        
        for (VCG_CPQ_Quote_Product__c qp : quoteProducts)
        {
            productSet.add(qp.Product__c);
        }
        
        // Get standard Pricebook Entry Id
        Id stdPricebookId;
        if (Test.isRunningTest())
        {
            stdPricebookId = Test.getStandardPricebookId();
        }
        else
        {
            stdPricebookId = [SELECT Id FROM Pricebook2 WHERE IsStandard = TRUE][0].Id;
        }
        
        ///////////////////////////////////////////////////////////////////////////////////// 
        // Not sure how we should handle this. Opportunity Line Items need Pricebook Entries
        String soql = 'SELECT Id, Product2Id, ProductCode FROM PricebookEntry '
                      + ' WHERE Product2Id IN :productSet '
                      +       ' AND Pricebook2Id = :stdPricebookId'
                      + (UserInfo.isMultiCurrencyOrganization() ? ' AND CurrencyIsoCode = \'' + quote.get('CurrencyIsoCode') + '\'' : '');
        
        for (PricebookEntry pe : Database.query(soql))
        {
            productPriceBookmap.put(pe.Product2Id, pe.Id);
        }
            
        /*************************************************/
        for (VCG_CPQ_Quote_Product__c qp : quoteProducts)
        {
            OpportunityLineItem oli = new OpportunityLineItem(); 
            for (VCG_CPQ_Quote_Product_Oppty_Product_Map__c qo : qliToOliMaps)
            {
                String dataType = 'String';//'UNDEFINED';
                if (oliFieldsDescribed.containsKey(qo.Opportunity_Product_Field__c) )
                {
                    dataType = oliFieldsDescribed.get(qo.Opportunity_Product_Field__c).getSOAPType().name();
                    
                    if (dataType == null || dataType == '')
                    {
                        dataType = oliFieldsDescribed.get(qo.Opportunity_Product_Field__c).getType().name();
                    }
                }
                
                Object val = qp.get(qo.Quote_Product_Field__c);
                    
                //Cast the source data to the destination data type
                if (dataType == 'Boolean')
                    oli.put(qo.Opportunity_Product_Field__c, Boolean.valueOf(val));
                else if (dataType == 'Date' )
                    oli.put(qo.Opportunity_Product_Field__c, Date.valueOf(val));
                else if (dataType == 'DateTime')
                    oli.put(qo.Opportunity_Product_Field__c, DateTime.valueOf(val));
                else if (dataType == 'Double')
                    oli.put(qo.Opportunity_Product_Field__c, Double.valueOf(val));
                else if (dataType == 'Integer')
                    oli.put(qo.Opportunity_Product_Field__c, Integer.valueOf(val));
                else if (dataType == 'String')
                    oli.put(qo.Opportunity_Product_Field__c, String.valueOf(val));
                else if (dataType == 'Id')
                    oli.put(qo.Opportunity_Product_Field__c, (Id)val);
                else {
                    debug('====> Unsupported field type: ' + dataType);
                    throw new VCG_CPQ_Formula.Formula_Exception('Unsupported field type: ' + dataType + ' for Field ' + qo.Opportunity_Product_Field__c);
                }
            }
            oli.PricebookEntryId = productPriceBookmap.get(qp.Product__c);
            if (oli.Quantity == null)oli.Quantity = 1;
            if (oli.TotalPrice == null)oli.TotalPrice = 0;
            oli.OpportunityId = oppty.Id;
            if (oli.PricebookEntryId != null)
            {
                optyLineItems.add(oli);
            }
            else
            {
                debug('====> No pricebook entry for product "' + qp.Product__r.Name + '"' + (UserInfo.isMultiCurrencyOrganization() ? ' and Currency = \'' + quote.get('CurrencyIsoCode') + '\'' : ''));
                throw new VCG_CPQ_Formula.Formula_Exception('No pricebook entry for product "' + qp.Product__r.Name + '"' + (UserInfo.isMultiCurrencyOrganization() ? ' and Currency = \'' + quote.get('CurrencyIsoCode') + '\'' : ''));
            }
        }
        
        debug('====> optyLineItems: ' + optyLineItems);
        
        if (optyLineItems.size() > 0)
            insert optyLineItems;
    }
    public static string createStringOfQuoteProducts(List<VCG_CPQ_Quote_Product__c> quoteProducts)
    {
        string stringToReturn = '';
        for (integer i = 0; i < quoteProducts.size(); i++)
        {
            if (quoteProducts[i].Product__c != null && 
               quoteProducts[i].product__r.name != null)
           {
               stringToreturn += quoteProducts[i].Product__r.name;
           }
           //  adds a semicolon as a name sperator UNLESS we are on the last product
           if (i != quoteProducts.size() -1)
           {
               stringToReturn += '; ';
           }
        }
        //  field was long text area but changed to text area prior to uat deployments, so need to truncate to 255 if
        //  there are more than 255 chars in string
        if (stringToReturn != null && stringToReturn.length() > 255)
        {
            stringToReturn = truncateString(stringToReturn, 255);
        }
        return stringToReturn;
    }
    private static string truncateString(string str, integer fieldMaxLength)
    {
        system.assert(str.length() > fieldMaxLength);
        string stringToReturn = str.substring(0, fieldMaxLength - 3);//  the last 3 chars on the end of the string will be ...
        stringToReturn += '...';
        return stringToReturn; 
    }
    /**
     * Method get the currency symbol in context
     *
     * @author  Nathan Shinn <nshinn@cloudsherps.com>
     */
    public static String getCurrencySymbol(String iso) { 
            
        String symbol = '$';  

        if      (iso=='ALL') { symbol='Lek'; } 
        else if (iso=='ANG') { symbol='ƒ'; } 
        else if (iso=='ARS') { symbol='$'; } 
        else if (iso=='AUD') { symbol='$'; } 
        else if (iso=='AWG') { symbol='ƒ'; } 
        else if (iso=='BAM') { symbol='KM'; } 
        else if (iso=='BBD') { symbol='$'; } 
        else if (iso=='BMD') { symbol='$'; } 
        else if (iso=='BND') { symbol='$'; } 
        else if (iso=='BOB') { symbol='$b'; } 
        else if (iso=='BRL') { symbol='R$'; } 
        else if (iso=='BSD') { symbol='$'; } 
        else if (iso=='BWP') { symbol='P'; } 
        else if (iso=='BYR') { symbol='p.'; } 
        else if (iso=='BZD') { symbol='BZ$'; } 
        else if (iso=='CAD') { symbol='$'; } 
        else if (iso=='CHF') { symbol='CHF'; } 
        else if (iso=='CLP') { symbol='$'; } 
        else if (iso=='CNY') { symbol='¥'; } 
        else if (iso=='COP') { symbol='$'; } 
        else if (iso=='CRC') { symbol='¢'; } 
        else if (iso=='CZK') { symbol='Kc'; } 
        else if (iso=='DKK') { symbol='kr'; } 
        else if (iso=='DOP') { symbol='RD$'; } 
        else if (iso=='EEK') { symbol='kr'; } 
        else if (iso=='EGP') { symbol='£'; } 
        else if (iso=='EUR') { symbol='€'; } 
        else if (iso=='FJD') { symbol='$'; } 
        else if (iso=='FKP') { symbol='£'; } 
        else if (iso=='GBP') { symbol='£'; } 
        else if (iso=='GGP') { symbol='£'; } 
        else if (iso=='GHC') { symbol='¢'; } 
        else if (iso=='GIP') { symbol='£'; } 
        else if (iso=='GTQ') { symbol='Q'; } 
        else if (iso=='GYD') { symbol='$'; } 
        else if (iso=='HKD') { symbol='$'; } 
        else if (iso=='HNL') { symbol='L'; } 
        else if (iso=='HRK') { symbol='kn'; } 
        else if (iso=='HUF') { symbol='Ft'; } 
        else if (iso=='IDR') { symbol='Rp'; } 
        else if (iso=='IMP') { symbol='£'; } 
        else if (iso=='ISK') { symbol='kr'; } 
        else if (iso=='JEP') { symbol='£'; } 
        else if (iso=='JMD') { symbol='J$'; } 
        else if (iso=='JPY') { symbol='¥'; } 
        else if (iso=='KYD') { symbol='$'; } 
        else if (iso=='LBP') { symbol='£'; } 
        else if (iso=='LRD') { symbol='$'; } 
        else if (iso=='LTL') { symbol='Lt'; } 
        else if (iso=='LVL') { symbol='Ls'; }
        else if (iso=='MXN') { symbol='$'; } 
        else if (iso=='MYR') { symbol='RM'; } 
        else if (iso=='MZN') { symbol='MT'; } 
        else if (iso=='NAD') { symbol='$'; } 
        else if (iso=='NIO') { symbol='C$'; } 
        else if (iso=='NOK') { symbol='kr'; } 
        else if (iso=='NZD') { symbol='$'; } 
        else if (iso=='PAB') { symbol='B/.'; } 
        else if (iso=='PEN') { symbol='S/.'; } 
        else if (iso=='PHP') { symbol='Php'; } 
        else if (iso=='PLN') { symbol='zl'; }
        else if (iso=='PYG') { symbol='Gs'; } 
        else if (iso=='RON') { symbol='lei'; } 
        else if (iso=='SBD') { symbol='$'; } 
        else if (iso=='SEK') { symbol='kr'; } 
        else if (iso=='SGD') { symbol='$'; } 
        else if (iso=='SHP') { symbol='£'; } 
        else if (iso=='SOS') { symbol='S'; } 
        else if (iso=='SRD') { symbol='$'; } 
        else if (iso=='SVC') { symbol='$'; } 
        else if (iso=='SYP') { symbol='£'; } 
        else if (iso=='TRL') { symbol='£'; } 
        else if (iso=='TRY') { symbol='TL'; } 
        else if (iso=='TTD') { symbol='TT$'; } 
        else if (iso=='TVD') { symbol='$'; } 
        else if (iso=='TWD') { symbol='NT$'; } 
        else if (iso=='USD') { symbol='$'; } 
        else if (iso=='UYU') { symbol='$U'; } 
        else if (iso=='VEF') { symbol='Bs'; } 
        else if (iso=='XCD') { symbol='$'; } 
        else if (iso=='ZAR') { symbol='R'; } 
        else if (iso=='ZWD') { symbol='Z$'; } 
        return symbol; 
    }
    
    
    /**
     * Gets the CurrencyISOCode from a record (if multi-currency org), otherwise the user's default currency
     *
     * @author  Lawrence Coffin <lawrence.coffin@cloudsheraps.com>
     * @since   7.May.2014
     */
    public static String getCurrencyISOCode(sObject obj)
    {
        if (UserInfo.isMultiCurrencyOrganization())
        {
            return (String)obj.get('CurrencyISOCode');
        }
        else
        {
            return UserInfo.getDefaultCurrency();
        }
    }
    
    
    
    /**
     * @description  Cache for storing exchange rates for ConvertCurrencyIfNeeded(), so we don't
     *               have to query the database more than once per code execution
     * 
     * @author  Lawrence Coffin <lawrence.coffin@cloudsherpas.com>
     * @author  Tanvir Ansari <tanvir.ansari@cloudsherpas.com>
     * @since   12.Oct.2014
     */
    private static Map<String,Decimal> exchangeRates;
    
    /**
     * @description Converts Currency Amounts from the DataRec currency to the Quote currency, but only
     *              under the following circumstances:
     *
     *                - Is Multi-Currency Org (otherwise DataRec and Quote are in the same currency already)
     *                - dataRec.Result_Type is 'Currency Amount' (other result types - percentage, numeric - are not converted)
     *                - Quote Currency != DataRec Currency
     *
     *              In all other circumstances, it returns the original value unchanged.
     * 
     * @author  Lawrence Coffin <lawrence.coffin@cloudsherpas.com>
     * @author  Tanvir Ansari <tanvir.ansari@cloudsherpas.com>
     * @since   12.Oct.2014
     */
    public static Decimal ConvertCurrencyIfNeeded(VCG_CPQ_Quote__c quote, VCG_CPQ_Pricing_Condition_Data__c dataRec, Decimal value)
    {
        Boolean isMultiCurrencyOrg = UserInfo.isMultiCurrencyOrganization();        
        
        if (isMultiCurrencyOrg && dataRec.Result_Type__c == 'Currency Amount' && quote.get('CurrencyIsoCode') != dataRec.get('CurrencyIsoCode'))
        {
            String QuoteISO = (String) quote.get('CurrencyIsoCode');
            String DataRecISO = (String) dataRec.get('CurrencyIsoCode');
            
            if (exchangeRates == null)
            {
                exchangeRates = new map<String,decimal>();
                for ( sObject c : Database.query('SELECT ISOCode,ConversionRate FROM CurrencyType'))
                {
                     exchangeRates.put((String)c.get('isoCode'), (Decimal)c.get('ConversionRate'));
                }
            }
            
            //
            // If value is in units of CUR1 and we need to convert to units of CUR2 (the quote Currency),
            // exchange rates are in units of CURX/CORP_CUR ... so we want to multiply
            //
            //    value * QuoteExchRate / DataRecExchRate
            //
            // because that give us units of:
            //
            //       CUR1 * (CUR2/CORP_CUR) / (CUR1/CORP_CUR)
            //    == CUR1 * (CUR2/CORP_CUR) * (CORP_CUR/CUR1)
            //    == CUR1 * (CUR2 * CORP_CUR) / (CORP_CUR * CUR1)
            //    == CUR1 * CUR2 / CUR1
            //    == CUR2
            //
            return value * exchangeRates.get(QuoteISO) / exchangeRates.get(DataRecISO);
        }
        else
        {
            // For single-currency orgs, non-Currency Amount result types (i.e. Percentages, Numeric), or if the currency in the dataRec and quote are the same
            return value;
        }
    }
    
    
    
    /**
     * Helper function for spreading the sequence values for Pricing Procedure Sequence records
     * to make it easier to add new procedures in the middle without having to manually change
     * the values for all. This spaces all records out by 3 so new records can be added between.
     * 3 was chosen as a spacer because it allows for a couple items between, but doesn't grow
     * as fast as 5. Start at 3, not zero, so there is space at the start of the list as well.
     * 
     * Call this manually via Developer Console/Execute Anonymous. Could be added in to a trigger-based
     * auto-sequencing if desired.
     * 
     * @author  Lawrence Coffin <lawrence.coffin@cloudsherpas.com>
     * @since   5.May.2014
     */
    public static void SpreadConditionSeqs()
    {
        String lastPPName = '';
        Integer seq = 0;
        
        for (List<VCG_CPQ_Pricing_Procedure_Sequence__c> ppss : [SELECT Id, Pricing_Procedure__r.Name
                                                                 FROM VCG_CPQ_Pricing_Procedure_Sequence__c
                                                                 ORDER BY Pricing_Procedure__r.Name, Sequence__c])
        {
            for (VCG_CPQ_Pricing_Procedure_Sequence__c pps : ppss)
            {
                if (lastPPName != pps.Pricing_Procedure__r.Name) {
                    seq = 0;
                    lastPPName = pps.Pricing_Procedure__r.Name;
                }
                
                seq += 3;
                
                pps.Sequence__c = seq;
            }
            
            update ppss;
        }
    }
    
    
    /**
     * Helper function for spreading the sequence values for Pricing Procedure Sequence records
     * to make it easier to add new procedures in the middle without having to manually change
     * the values for all. This spaces all records out by 3 so new records can be added between.
     * 3 was chosen as a spacer because it allows for a couple items between, but doesn't grow
     * as fast as 5. Start at 3, not zero, so there is space at the start of the list as well.
     * 
     * Call via JS button
     * 
     * @author  Lawrence Coffin <lawrence.coffin@cloudsherpas.com>
     * @since   1.Oct.2014
     */
    webService static String SpreadConditionSeqsFor(Id ppId)
    {
//      return 'Got id: ' + ppId;

        if (ppId == null)
        {
            return 'Error: Pricing Procedure Id is null';
        }
        
        String lastPPName = '';
        Integer seq = 0;
        
        for (List<VCG_CPQ_Pricing_Procedure_Sequence__c> ppss : [SELECT Id, Pricing_Procedure__r.Name
                                                                 FROM VCG_CPQ_Pricing_Procedure_Sequence__c
                                                                 WHERE Pricing_Procedure__c = :ppId
                                                                 ORDER BY Pricing_Procedure__r.Name, Sequence__c])
        {
            for (VCG_CPQ_Pricing_Procedure_Sequence__c pps : ppss)
            {
                if (lastPPName != pps.Pricing_Procedure__r.Name) {
                    seq = 0;
                    lastPPName = pps.Pricing_Procedure__r.Name;
                }
                
                seq += 3;
                
                pps.Sequence__c = seq;
            }
            
            update ppss;
        }
        
        return 'success';
    }
    
    /**
    *
    */
    public static void CountTotalOwned(VCG_CPQ_Quote__c quote, List<VCG_CPQ_Quote_Product__c> quoteProducts, List<Asset__c> existingAssets)
    {
         TotalOwned = new Map<String, Decimal>(); // Clear the total owned
    
        // Sum up the quantity owned for all existing assets
        for (Asset__c asst : existingAssets)
        {
            String productCode = asst.Product__r.ProductCode;
            if(TotalOwned.containsKey(productCode))
            {
                TotalOwned.put(productCode, (TotalOwned.get(productCode) == null ? 0 : TotalOwned.get(productCode)) + (asst.License_Metric_Quantity__c == null ? 0 : asst.License_Metric_Quantity__c));
            }
            else
            {
                TotalOwned.put(productCode, asst.License_Metric_Quantity__c ==  null ? 0 : asst.License_Metric_Quantity__c);
            }
        }
        
        // Apply the QP records to the total owned
        for (VCG_CPQ_Quote_Product__c qp : quoteProducts)
        {
            String productCode = qp.Product__r.ProductCode;
        
            if (qp.Line_Type__c == 'New' || qp.Line_Type__c == 'Extension')
            {
                if(TotalOwned.containsKey(productCode))
                {
                    TotalOwned.put(productCode, (TotalOwned.get(productCode) == null ? 0 : TotalOwned.get(productCode)) + (qp.License_Metric_Quantity__c == null ? 0 : qp.License_Metric_Quantity__c));
                }
                else
                {
                    TotalOwned.put(productCode, qp.License_Metric_Quantity__c ==  null ? 0 : qp.License_Metric_Quantity__c);
                }
            }
            else if (qp.Line_Type__c == 'Decommission')
            {
                // Subtract decom quantity
                TotalOwned.put(productCode, (TotalOwned.get(productCode) == null ? 0 : TotalOwned.get(productCode)) - (qp.Decommission_Quantity__c == null ? 0 : qp.Decommission_Quantity__c));
                if(TotalOwned.containsKey(productCode))
                {
                    TotalOwned.put(productCode, (TotalOwned.get(productCode) == null ? 0 : TotalOwned.get(productCode)) - (qp.Decommission_Quantity__c == null ? 0 : qp.Decommission_Quantity__c));
                }
                else
                {
                    TotalOwned.put(productCode, (-1 * (qp.Decommission_Quantity__c ==  null ? 0 : qp.Decommission_Quantity__c)) );
                }
            }
            // Else for renewal or migration, quantity should not be changing so no need to do anything
        }
        
        System.debug(LoggingLevel.ERROR,'::TOTAL OWNED::'+TotalOwned);
        
    }
}