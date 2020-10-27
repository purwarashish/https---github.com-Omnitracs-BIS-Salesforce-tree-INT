/**
 * Helper/Utility class for VCG_CPQ Test classes -- tools for building pricing models, etc.
 *
 * @author  Lawrence Coffin <lawrence.coffin@cloudsherpas.com>
 * @since   13.Oct.2014
 */
@isTest
public class VCG_CPQ_Helper {
//  
//  /* Creates a condition record. Any param but Name is optional */
//  <VCG_CPQ_Condition> = CreateCondition(<Name>, <Data_Key_Def>, <Data_Scale_1_Def>, <Formula_Readable>, <Formula_Compiled>, <Needs_Fields>)
//  
//  /* Basic AccessSequence creation method - assign to can be null */
//  <VCG_CPQ_Access_Sequence> = CreateAccessSequence(<Name>, <Assign_To>)
//  
//  /* Add Condition to AS */
//  AddCondition(<Access_Seq>, <Sequence/Order>, <Condition>)
//  
//  /* Access Sequence + Condition Record */
//  <VCG_CPQ_Access_Sequence> CreateAccessSequence(<Name>, <Assign_To>, <Data_Key_Def>, <Data_Scale_1_Def>, <Formula_Readable>, <Formula_Compiled>, <Needs_Fields>)
//  {
//         aSeq = CreateAccessSequence(<Name>, <Assign_To>);
//         cond = CreateCondition(<Name>, <Data_Key_Def>, <Data_Scale_1_Def>, <Formula_Readable>, <Formula_Compiled>, <Needs_Fields>);
//        AddCondition(aSeq, 1, cond)
//  }
//  
//  /* Add Pricing Procedure */
//  <VCG_CPQ_Pricing_Procedure> CreatePricingProcedure(<Name>, <Line_Type/Header>, <Sequence>)
//  
//  /* Add AS to PP */
//  AddAccessSequence(<Pricing_Procedure>, <Sequence/Order>, <Access_Seq>)    
//      
    
    /**
     * Create a Pricing Procedure record
     *
     * @author  Lawrence Coffin <lawrence.coffin@cloudsherpas.com>
     * @since   13.Oct.2014
     */
    public static VCG_CPQ_Pricing_Procedure__c CreatePricingProcedure(String name, String lineType, Integer seq)
    {
        VCG_CPQ_Pricing_Procedure__c rec = new VCG_CPQ_Pricing_Procedure__c(
                                                                               Name = name,
                                                                               Description__c = name,
                                                                               Quote_Line_Type__c = lineType,
                                                                               Sequence__c = seq,
                                                                               Active__c = true
                                                                           );
        insert rec;
        
        return rec;
    }
    
    
    /**
     * Create an Access Sequence record
     *
     * @author  Lawrence Coffin <lawrence.coffin@cloudsherpas.com>
     * @since   13.Oct.2014
     */
    public static VCG_CPQ_Pricing_Access_Sequence__c CreateAccessSequence(String name, String assignTo)
    {
        VCG_CPQ_Pricing_Access_Sequence__c rec = new VCG_CPQ_Pricing_Access_Sequence__c(
                                                                                           Name = name,
                                                                                           Description__c = name,
                                                                                           Assign_To__c = assignTo
                                                                                       );
        insert rec;
        
        return rec;
    }
    
    
    /**
     * Create a Pricing Condition record
     *
     * @author  Lawrence Coffin <lawrence.coffin@cloudsherpas.com>
     * @since   13.Oct.2014
     */
    public static VCG_CPQ_Pricing_Condition__c CreateCondition(String name, String type, String dataKeyDef, String dataScale1Def, String calcReadable, String calcCompiled, String needsFields)
    {
        VCG_CPQ_Pricing_Condition__c rec = new VCG_CPQ_Pricing_Condition__c(
                                                                                Name = name,
                                                                                Description__c = name,
                                                                                Type__c = type,
                                                                                Data_Key_Definition__c = dataKeyDef,
                                                                                Data_Scale_Field_1__c = dataScale1Def,
                                                                                Calculation__c = calcReadable,
                                                                                Calculation_Compiled__c = calcCompiled,
                                                                                Needs_Fields__c = needsFields
                                                                           );
        insert rec;
        
        return rec;
    }
    
    
    /**
     * Adds a Pricing Condition Data record (under a Condition record)
     *
     * @author  Lawrence Coffin <lawrence.coffin@cloudsherpas.com>
     * @since   13.Oct.2014
     */
    public static VCG_CPQ_Pricing_Condition_Data__c AddConditionData(VCG_CPQ_Pricing_Condition__c cond, String dataKey, Decimal dataScale1, String resultType, Decimal resultValue, String resultValueStr, Boolean multiplyByQuantity)
    {
        VCG_CPQ_Pricing_Condition_Data__c rec = new VCG_CPQ_Pricing_Condition_Data__c(
                                                                                         Condition__c = cond.Id,
                                                                                         Data_Key__c = dataKey,
                                                                                         Data_Scale_1__c = dataScale1,
                                                                                         Result_Type__c = resultType,
                                                                                         Result_Value__c = resultValue,
                                                                                         Result_Value_String__c = resultValueStr,
                                                                                         Multiply_By_Quantity__c = multiplyByQuantity
                                                                                     );
        insert rec;
        
        return rec;
    }
    
    
    /**
     * Adds an Access Sequence to a Pricing Procedure record
     *
     * @author  Lawrence Coffin <lawrence.coffin@cloudsherpas.com>
     * @since   13.Oct.2014
     */
    public static VCG_CPQ_Pricing_Procedure_Sequence__c AddAccessSequence(VCG_CPQ_Pricing_Procedure__c proc, Integer seq, VCG_CPQ_Pricing_Access_Sequence__c accSeq)
    {
        VCG_CPQ_Pricing_Procedure_Sequence__c rec = new VCG_CPQ_Pricing_Procedure_Sequence__c(
                                                                                                  Name = Proc.Name + '-' + accSeq.Name,
                                                                                                  Pricing_Procedure__c = proc.Id,
                                                                                                  Access_Sequence__c = accSeq.Id,
                                                                                                  Sequence__c = seq
                                                                                              );
        insert rec;
        
        return rec;
    }
    
    
    /**
     * Adds *new* Access Sequence and Condition records to a Pricing Procedure record (i.e. a single step in the pricing model that only requires a single AS and a formula-based Condition)
     *
     * @author  Lawrence Coffin <lawrence.coffin@cloudsherpas.com>
     * @since   13.Oct.2014
     */
    public static VCG_CPQ_Pricing_Access_Sequence__c AddAccessSequence(VCG_CPQ_Pricing_Procedure__c proc,
                                                                                             Integer seq,
                                                                                             String name,
                                                                                             String assignTo,
                                                                                             String calcReadable,
                                                                                             String calcCompiled,
                                                                                             String needsFields)
    {
        VCG_CPQ_Pricing_Condition__c cond = CreateCondition(name, 'Calculation', null, null, calcReadable, calcCompiled, needsFields);
        
        VCG_CPQ_Pricing_Access_Sequence__c accSeq = VCG_CPQ_Helper.CreateAccessSequence(name, assignTo);
        
        AddCondition(accSeq, 10, cond);
        
        AddAccessSequence(proc, seq, accSeq);
        
        return accSeq;
    }
    
    
    /**
     * Adds a Condition to a Sequence record
     *
     * @author  Lawrence Coffin <lawrence.coffin@cloudsherpas.com>
     * @since   13.Oct.2014
     */
    public static VCG_CPQ_Pricing_Sequence_Condition__c AddCondition(VCG_CPQ_Pricing_Access_Sequence__c accSeq, Integer seq, VCG_CPQ_Pricing_Condition__c cond)
    {
        VCG_CPQ_Pricing_Sequence_Condition__c rec = new VCG_CPQ_Pricing_Sequence_Condition__c(
                                                                                                 Name = cond.Name,
                                                                                                 Access_Sequence__c = accSeq.Id,
                                                                                                 Condition__c = cond.Id,
                                                                                                 Sequence__c = seq
                                                                                             );
        insert rec;
        
        return rec;
    }
    
    
    
    /**
     * Adds a single Opportunity to Quote field mapping. Assumes Source is an Opp Field, not a formula
     *
     * @author  Lawrence Coffin <lawrence.coffin@cloudsherpas.com>
     * @since   13.Oct.2014
     */
    public static Id AddOppToQuoteFieldMap(String oppField, String quoteField)
    {
        VCG_CPQ_Opportunity_Quote_Map__c rec = new VCG_CPQ_Opportunity_Quote_Map__c(
                                                                                        Active__c = True,
                                                                                        Source__c = oppField,
                                                                                        Quote_Field__c = quoteField,
                                                                                        Source_Type__c = 'Opportunity Field'
                                                                                   );
        insert rec;
        
        return rec.Id;
    }
    
    
    /**
     * Adds a single Field Layout record
     *
     * @author  Lawrence Coffin <lawrence.coffin@cloudsherpas.com>
     * @since   4.Dec.2014
     */
    public static Id AddFieldLayout(String section, Integer seq, String field, String displayType, String displayForProductType, String altLabel)
    {
        VCG_CPQ_Page_Layout__c rec = new VCG_CPQ_Page_Layout__c(
                                                                                        Page_Section__c = section,
                                                                                        Order__c = seq,
                                                                                        Field__c = field,
                                                                                        Display_Type__c = displayType,
                                                                                        Display_For_Product_Type__c = displayForProductType,
                                                                                        Alt_Label__c = altLabel
                                                                                   );
        insert rec;
        
        return rec.Id;
    }
    
    
    /**
     * @description  Does a basic extension on an existing asset
     *
     * @author  Lawrence Coffin <lawrence.coffin@cloudsherpas.com>
     * @since   15.Oct.2014
     */
    public static void DoExtension(VCG_CPQ_QuoteController controller, String productCode, Decimal quantity)
    {
        Boolean foundProduct = false;
        
        // Set the 'Quantity' on the existing asset
        for (Integer i = 0; i < controller.qpwList.size(); i++)
        {
            if (controller.qpwList[i].productRec.ProductCode == productCode && controller.qpwList[i].assetRec != null)
            {
                controller.qpwList[i].quoteProdRec.License_Metric_Quantity__c = quantity;
                
                foundProduct = true;
                
                break;
            }
        }
        
        System.assertEquals(true, foundProduct, 'Product "' + productCode + '" not found in existing assets');
        
        // Call the pricing() method to trigger the extension
        controller.pricing();
    }
    
    /**
     * @description  Does a basic renewal on an existing asset
     *
     * @author  Nathan Shinn
     * @since   15.Oct.2014
     */
    public static void DoRenewal(VCG_CPQ_QuoteController controller, String productCode, Integer extensionMonths)
    {
        // Get the id of the product we are editing
        Id prodId;
        
        for (Integer i = 0; i < controller.qpwList.size(); i++)
        {
            if (controller.qpwList[i].productRec.ProductCode == productCode && controller.qpwList[i].assetRec != null)
            {
                prodId = controller.qpwList[i].productRec.Id;
                break;
            }
        }
        
        System.assertNotEquals(null, prodId, 'Product "' + productCode + '" not found in existing assets');
        
        // Set edit product id and show the Edit End Date dialog (creates the eqWrapper with the date being edited)
        controller.eqProductId = prodId;
        controller.showEditEndDate();
        
        // Update the date in the eqWrapper
        controller.editQP.Asset_Term_End_Date__c = controller.editQP.Asset_Term_End_Date__c.addMonths(extensionMonths);
        
        // Save the edited end date
        controller.updateEndDate();
    }
    
    public static void DoAddNew(VCG_CPQ_QuoteController controller, String productCode, String productFilter, Decimal quantity)
    {
        // simulate adding new product to the quote using the controller functions
        controller.showAddNew();
        System.assertEquals(true, controller.isAddNew);
        
        controller.targetPFK = productFilter;
        controller.showFilteredNewProducts();
        
        // Check that we have our product in the list of available/filtered products
        //System.assertEquals(1, controller.addNewFilteredProdList.size()); 
        //System.assertNotEquals(null, controller.addNewFilteredProdList); 
        //System.assertNotEquals(0, controller.addNewFilteredProdList.size()); 
        
        Boolean foundProduct = false;
        
        //
        // Select (set a quantity value for) the specified product in the product list and add to the quote
        //
        for (Integer i = 0; i < controller.addNewFilteredProdList.size(); i++)
        {
            if (controller.addNewFilteredProdList[i].productRec.ProductCode == productCode)
            {
                controller.addNewFilteredProdList[i].quoteProdRec.License_Metric_Quantity__c = quantity;
                
                foundProduct = true;
                
                break;
            }
        }
        
        System.assertEquals(true, foundProduct, 'Product "' + productCode + '" not found using product filter "' + productFilter + '"');
        
        controller.addProducts();
    }
    
    /**
     * @description  Does a Pricing Result Override
     *
     * @author  Lawrence Coffin <lawrence.coffin@cloudsherpas.com>
     * @since   5.Dec.2014
     */
    public static void OverrideValue(VCG_CPQ_QuoteController controller, String productCode, String lineType, String accessSequenceName, Decimal newVal)
    {
        String productGroup = '';
        String productName;
        
        // Look up product name for the product matching productCode
        for (Integer i = 0; i < controller.qpwList.size(); i++)
        {
            if (controller.qpwList[i].productRec.ProductCode == productCode)
            {
                productName = controller.qpwList[i].productRec.Name;
                break;
            }
        }
        
        System.assertNotEquals(null, productName, 'Product "' + productCode + '" not found on quote');
        
        String editPricingKey = productGroup + '-' + lineType + '-' + productName;
        
        System.assertEquals(true, controller.pricingResultsMap.containsKey(editPricingKey), 'No Pricing Results for product "' + productCode + '" (1)');
        System.assertNotEquals(0, controller.pricingResultsMap.get(editPricingKey).size(), 'No Pricing Results for product "' + productCode + '" (2)');
        
        String ppSeqId;
        
        // Look up ppSeqId for the access sequence matching accessSequenceName
        for (Integer i = 0; i < controller.pricingResultsMap.get(editPricingKey).size(); i++)
        {
            if (controller.pricingResultsMap.get(editPricingKey)[i].Access_Sequence__c == accessSequenceName)
            {
                ppSeqId = controller.pricingResultsMap.get(editPricingKey)[i].Pricing_Procedure_Sequence__c;
                break;
            }
        }
        
        System.assertNotEquals(null, ppSeqId, 'Pricing result for access sequence "' + accessSequenceName + '" not found for pricing key "' + editPricingKey + '"');
        
        //
        // Trigger the Pricing Override
        //
        controller.editPricingKey = editPricingKey;
        controller.pricingProcSeqId = ppSeqId;
        
        controller.showEditResultValue();
        System.debug(LoggingLevel.ERROR, '====> editPricingResult: ' + controller.editPricingResult);
        System.assertEquals(ppSeqId, controller.editPricingResult.Pricing_Procedure_Sequence__c, 'Pricing Result not found for pricing key "' + editPricingKey + '" and ppSeqId "' + ppSeqId + '"');
        System.debug(LoggingLevel.ERROR, '====> editPricingResult.Quote_Product__r: ' + controller.editPricingResult.Quote_Product__r);
        
        controller.editPricingResult.Result_Value__c = newVal;
        controller.updatePricingResultValue();
    }
    
    /**
     * @description  Clears a single Pricing Result Override
     *
     * @author  Lawrence Coffin <lawrence.coffin@cloudsherpas.com>
     * @since   5.Dec.2014
     */
    public static void ClearOverride(VCG_CPQ_QuoteController controller, String productCode, String lineType, String accessSequenceName)
    {
        String productGroup = '';
        String productName;
        
        // Look up product name for the product matching productCode
        for (Integer i = 0; i < controller.qpwList.size(); i++)
        {
            if (controller.qpwList[i].productRec.ProductCode == productCode)
            {
                productName = controller.qpwList[i].productRec.Name;
                break;
            }
        }
        
        System.assertNotEquals(null, productName, 'Product "' + productCode + '" not found on quote');
        
        String editPricingKey = productGroup + '-' + lineType + '-' + productName;
        
        System.assertEquals(true, controller.pricingResultsMap.containsKey(editPricingKey), 'No Pricing Results for product "' + productCode + '" (1)');
        System.assertNotEquals(0, controller.pricingResultsMap.get(editPricingKey).size(), 'No Pricing Results for product "' + productCode + '" (2)');
        
        String ppSeqId;
        
        // Look up ppSeqId for the access sequence matching accessSequenceName
        for (Integer i = 0; i < controller.pricingResultsMap.get(editPricingKey).size(); i++)
        {
            if (controller.pricingResultsMap.get(editPricingKey)[i].Access_Sequence__c == accessSequenceName)
            {
                ppSeqId = controller.pricingResultsMap.get(editPricingKey)[i].Pricing_Procedure_Sequence__c;
                break;
            }
        }
        
        System.assertNotEquals(null, productName, 'Product "' + productCode + '" not found on quote');
        
        
        //
        // Call the removeOverride() method with the product and ppSeq identifiers
        //
        controller.overrideProduct = editPricingKey;
        controller.overridePPS = ppSeqId;
        
        controller.removeOverride();
    }
    
    /**
     * @description  Clears all Pricing Result Overrides for a single product
     *
     * @author  Lawrence Coffin <lawrence.coffin@cloudsherpas.com>
     * @since   5.Dec.2014
     */
    public static void ClearAllOverrides(VCG_CPQ_QuoteController controller, String productCode, String lineType)
    {
        String productGroup = '';
        String productName;
        
        // Look up product name for the product matching productCode
        for (Integer i = 0; i < controller.qpwList.size(); i++)
        {
            if (controller.qpwList[i].productRec.ProductCode == productCode)
            {
                productName = controller.qpwList[i].productRec.Name;
                break;
            }
        }
        
        System.assertNotEquals(null, productName, 'Product "' + productCode + '" not found on quote');
        
        String editPricingKey = productGroup + '-' + lineType + '-' + productName;
        
        //
        // Call the removeOverride() method with just the Product identifier
        //
        controller.overrideProduct = editPricingKey;
        controller.overridePPS = null;
        
        controller.removeOverride();
    }
    
}