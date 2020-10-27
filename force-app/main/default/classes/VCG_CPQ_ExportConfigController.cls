/**
 * Controller for VCG_CPQ_ExportConfig VF Page - generates XML output of the CPQ configuration
 *
 * @author  Lawrence Coffin <lawrence.coffin@cloudsherpas.com>
 * @since   4.May.2015
 */
public class VCG_CPQ_ExportConfigController {
    public Boolean renderConfig {get;set;}
    public String configXML {get;set;}
    
    public VCG_CPQ_ExportConfigController()
    {
        renderConfig = false;
        configXML = '';
    }
    
    /**
     * This is the main action method that kicks off the XML generation
     *
     * @author  Lawrence Coffin <lawrence.coffin@cloudsherpas.com>
     * @since   4.May.2015
     */
    public void generateConfigXML()
    {
        configXML = DoGenerateConfigXML();
        renderConfig = true;
    }
    
    
    /**
     * Main XML generation method, calls the sub-area XML generation
     *
     * @author  Lawrence Coffin <lawrence.coffin@cloudsherpas.com>
     * @since   4.May.2015
     */
    private String DoGenerateConfigXML()
    {
        String xml = '<?xml version="1.0" encoding="UTF-8"?>\n';
        xml += '<VCG_CPQ_Config>\n';
        
        xml += DoGenProductConfigXML();
        xml += DoGenPricingXML();
        xml += DoGenProductFiltersXML();
        xml += DoGenFieldLayoutsXML();
        xml += DoGenOppQuoteMapsXML();
        xml += DoGenQuoteOppMapsXML();
        xml += DoGenQLIOLIMapsXML();
        
        xml += '</VCG_CPQ_Config>\n';
        
        return xml;
//        return '<?xml version="1.0" encoding="UTF-8"?>\n<body>\n    <items>Apple</items>\n    <items>Banana</items>\n    <items>Cranberry</items>\n</body>\n';
    }
    
    
    /***************************************************************************************
     * Product Config
     ***************************************************************************************/
    
    /**
     *
     * @author  Lawrence Coffin <lawrence.coffin@cloudsherpas.com>
     * @since   22.May.2015
     */
    private String DoGenProductConfigXML()
    {
        String xml = '';
        
        Map<String,Schema.SObjectField> prodFieldsDesc = Product2.getSObjectType().getDescribe().fields.getMap();
        
        xml += DoGenProdAddOnGroupingXML(prodFieldsDesc); // Product2.CPQ_Add_On_Grouping__c
        xml += DoGenProdDisplayTypeXML(prodFieldsDesc);   // Product2.CPQ_Display_Type__c
        xml += DoGenProdFilterKeyXML(prodFieldsDesc);     // Product2.Product_Filter_Key__c
        
        return xml;
    }
    
    /**
     *
     * @author  Lawrence Coffin <lawrence.coffin@cloudsherpas.com>
     * @since   22.May.2015
     */
    private String DoGenProdAddOnGroupingXML(Map<String,Schema.SObjectField> prodFieldsDesc)
    {
        String xml = '';
        
        String formula = prodFieldsDesc.get('CPQ_Add_On_Grouping__c').getDescribe().getCalculatedFormula();
        
        xml += '  <Product2.CPQ_Add_On_Grouping__c>\n';
        xml += '    <formula>' + String.valueOf(formula).escapeXml() + '</formula>\n';
        xml += '  </Product2.CPQ_Add_On_Grouping__c>\n';
        
        return xml;
    }
    
    /**
     *
     * @author  Lawrence Coffin <lawrence.coffin@cloudsherpas.com>
     * @since   22.May.2015
     */
    private String DoGenProdDisplayTypeXML(Map<String,Schema.SObjectField> prodFieldsDesc)
    {
        String xml = '';
        
        String formula = prodFieldsDesc.get('CPQ_Display_Type__c').getDescribe().getCalculatedFormula();
        
        xml += '  <Product2.CPQ_Display_Type__c>\n';
        xml += '    <formula>' + String.valueOf(formula).escapeXml() + '</formula>\n';
        xml += '  </Product2.CPQ_Display_Type__c>\n';
        
        return xml;
    }
    
    /**
     * 
     * @author  Lawrence Coffin <lawrence.coffin@cloudsherpas.com>
     * @since   22.May.2015
     */
    private String DoGenProdFilterKeyXML(Map<String,Schema.SObjectField> prodFieldsDesc)
    {
        String xml = '';
        
        String formula = prodFieldsDesc.get('Product_Filter_Key__c').getDescribe().getCalculatedFormula();
        
        xml += '  <Product2.Product_Filter_Key__c>\n';
        xml += '    <formula>' + String.valueOf(formula).escapeXml() + '</formula>\n';
        xml += '  </Product2.Product_Filter_Key__c>\n';
        
        return xml;
    }
    
    
    /***************************************************************************************
     * Pricing Config
     ***************************************************************************************/
    
    private String DoGenPricingXML()
    {
        String xml = '';
        
        xml += DoGenPricProcsXML();
        xml += DoGenAccessSeqsXML();
        xml += DoGenPricCondsXML();
        xml += DoGenProcSeqsXML();
        xml += DoGenSeqCondsXML();
        
        return xml;
    }
    
    private String DoGenPricProcsXML()
    {
        String xml = '';
        
        // Note: Don't need Needs Fields at this level - they will be included in the Pricing Condition records
        for (VCG_CPQ_Pricing_Procedure__c pp : [SELECT Name, Quote_Line_Type__c, Active__c, Description__c FROM VCG_CPQ_Pricing_Procedure__c ORDER BY Sequence__c, Name])
        {
            xml += DoGenPricProcXML(pp);
        }
        
        if (xml != '')
        {
            xml = '  <!-- Order of Pricing Procedures below defines their sequence -->\n' + xml;
        }
        
        return xml;
    }
    
    private String DoGenPricProcXML(VCG_CPQ_Pricing_Procedure__c pp)
    {
        String xml = '';
        
        xml += '  <VCG_CPQ_Pricing_Procedure__c>\n';
        xml += '    <Name>' + String.valueOf(pp.Name).escapeXml() + '</Name>\n';
        xml += '    <Quote_Line_Type__c>' + String.valueOf(pp.Quote_Line_Type__c).escapeXml() + '</Quote_Line_Type__c>\n';
        xml += '    <Active__c>' + String.valueOf(pp.Active__c).escapeXml() + '</Active__c>\n';
        xml += '    <Description__c>' + String.valueOf(pp.Description__c).escapeXml() + '</Description__c>\n';
        xml += '  </VCG_CPQ_Pricing_Procedure__c>\n';
        
        return xml;
    }
    
    private String DoGenAccessSeqsXML()
    {
        String xml = '';
        
        // Note: Don't need Needs Fields at this level - they will be included in the Pricing Condition records
        for (VCG_CPQ_Pricing_Access_Sequence__c aSeq : [SELECT Name, Description__c, Assign_To__c, Comments__c, Debug__c FROM VCG_CPQ_Pricing_Access_Sequence__c ORDER BY Name])
        {
            xml += DoGenAccessSeqXML(aSeq);
        }
        
        return xml;
    }
    
    private String DoGenAccessSeqXML(VCG_CPQ_Pricing_Access_Sequence__c aSeq)
    {
        String xml = '';
        
        xml += '  <VCG_CPQ_Pricing_Access_Sequence__c>\n';
        xml += '    <Name>' + String.valueOf(aSeq.Name).escapeXml() + '</Name>\n';
        xml += '    <Description__c>' + String.valueOf(aSeq.Description__c).escapeXml() + '</Description__c>\n';
        if (aSeq.Assign_To__c != null) xml += '    <Assign_To__c>' + String.valueOf(aSeq.Assign_To__c).escapeXml() + '</Assign_To__c>\n';
        if (aSeq.Comments__c != null) xml += '    <Comments__c>' + String.valueOf(aSeq.Comments__c).escapeXml() + '</Comments__c>\n';
        xml += '    <Debug__c>' + String.valueOf(aSeq.Debug__c).escapeXml() + '</Debug__c>\n';
        xml += '  </VCG_CPQ_Pricing_Access_Sequence__c>\n';
        
        return xml;
    }
    
    private String DoGenPricCondsXML()
    {
        String xml = '';
        
        // Note: Need Needs Fields!
        for (VCG_CPQ_Pricing_Condition__c pc : [SELECT Name,
                                                       Description__c,
                                                       Type__c,
                                                       Data_Key_Definition__c,
                                                       Data_Scale_Field_1__c,
                                                       Data_Scale_Field_2__c,
                                                       Data_Scale_Field_3__c,
                                                       Calculation__c,
                                                       Calculation_Compiled__c,
                                                       Needs_Fields__c
                                                FROM VCG_CPQ_Pricing_Condition__c
                                                ORDER BY Name])
        {
            xml += DoGenPricCondXML(pc);
        }
        
        
        return xml;
    }
    
    private String DoGenPricCondXML(VCG_CPQ_Pricing_Condition__c pc)
    {
        String xml = '';
        
        xml += '  <VCG_CPQ_Pricing_Condition__c>\n';
        xml += '    <Name>' + String.valueOf(pc.Name).escapeXml() + '</Name>\n';
        xml += '    <Description__c>' + String.valueOf(pc.Description__c).escapeXml() + '</Description__c>\n';
        if (pc.Type__c != null) xml += '    <Type__c>' + String.valueOf(pc.Type__c).escapeXml() + '</Type__c>\n';
        if (pc.Data_Key_Definition__c != null) xml += '    <Data_Key_Definition__c>' + String.valueOf(pc.Data_Key_Definition__c).escapeXml() + '</Data_Key_Definition__c>\n';
        if (pc.Data_Scale_Field_1__c != null) xml += '    <Data_Scale_Field_1__c>' + String.valueOf(pc.Data_Scale_Field_1__c).escapeXml() + '</Data_Scale_Field_1__c>\n';
        if (pc.Data_Scale_Field_2__c != null) xml += '    <Data_Scale_Field_2__c>' + String.valueOf(pc.Data_Scale_Field_2__c).escapeXml() + '</Data_Scale_Field_2__c>\n';
        if (pc.Data_Scale_Field_3__c != null) xml += '    <Data_Scale_Field_3__c>' + String.valueOf(pc.Data_Scale_Field_3__c).escapeXml() + '</Data_Scale_Field_3__c>\n';
        if (pc.Calculation__c != null) xml += '    <Calculation__c>' + String.valueOf(pc.Calculation__c).escapeXml() + '</Calculation__c>\n';
        if (pc.Calculation_Compiled__c != null) xml += '    <Calculation_Compiled__c>' + String.valueOf(pc.Calculation_Compiled__c).escapeXml() + '</Calculation_Compiled__c>\n';
        
        if (pc.Needs_Fields__c != null)
        {
            List<String> needsFields = pc.Needs_Fields__c.split(';\\s*');
            needsFields.sort();
            
            for (String needsField : needsFields)
            {
                xml += '    <Needs_Fields__c>' + needsField.escapeXml() + '</Needs_Fields__c>\n';
            }
        }
        
        xml += '  </VCG_CPQ_Pricing_Condition__c>\n';
        
        return xml;
    }
    
    private String DoGenProcSeqsXML()
    {
        String xml = '';
        
        for (VCG_CPQ_Pricing_Procedure_Sequence__c pSeq : [SELECT Pricing_Procedure__c, Pricing_Procedure__r.Name, Access_Sequence__c, Access_Sequence__r.Name FROM VCG_CPQ_Pricing_Procedure_Sequence__c ORDER BY Pricing_Procedure__r.Sequence__c, Pricing_Procedure__r.Name, Sequence__c, Access_Sequence__r.Name])
        {
            xml += DoGenProcSeqXML(pSeq);
        }
        
        if (xml != '')
        {
            xml = '  <!-- Order of Procedure Sequences below defines their sequence -->\n' + xml;
        }
        
        return xml;
    }
    
    private String DoGenProcSeqXML(VCG_CPQ_Pricing_Procedure_Sequence__c pSeq)
    {
        String xml = '';
        
        xml += '  <VCG_CPQ_Pricing_Procedure_Sequence__c>\n';
        xml += '    <Pricing_Procedure__c>' + String.valueOf(pSeq.Pricing_Procedure__r.Name).escapeXml() + '</Pricing_Procedure__c>\n';
        xml += '    <Access_Sequence__c>' + String.valueOf(pSeq.Access_Sequence__r.Name).escapeXml() + '</Access_Sequence__c>\n';
        xml += '  </VCG_CPQ_Pricing_Procedure_Sequence__c>\n';
        
        return xml;
    }
    
    private String DoGenSeqCondsXML()
    {
        String xml = '';
                
        for (VCG_CPQ_Pricing_Sequence_Condition__c sc : [SELECT Access_Sequence__c, Access_Sequence__r.Name, Condition__c, Condition__r.Name FROM VCG_CPQ_Pricing_Sequence_Condition__c ORDER BY Access_Sequence__r.Name, Sequence__c, Condition__r.Name])
        {
            xml += DoGenSeqCondXML(sc);
        }
        
        if (xml != '')
        {
            xml = '  <!-- Order of Sequence Conditions below defines their sequence -->\n' + xml;
        }
        
        return xml;
    }
    
    private String DoGenSeqCondXML(VCG_CPQ_Pricing_Sequence_Condition__c sc)
    {
        String xml = '';
        
        xml += '  <VCG_CPQ_Pricing_Sequence_Condition__c>\n';
        xml += '    <Access_Sequence__c>' + String.valueOf(sc.Access_Sequence__r.Name).escapeXml() + '</Access_Sequence__c>\n';
        xml += '    <Condition__c>' + String.valueOf(sc.Condition__r.Name).escapeXml() + '</Condition__c>\n';
        xml += '  </VCG_CPQ_Pricing_Sequence_Condition__c>\n';
        
        return xml;
    }
    
    
    /***************************************************************************************
     * Product Filter Config
     ***************************************************************************************/
    
    /**
     *
     * @author  Lawrence Coffin <lawrence.coffin@cloudsherpas.com>
     * @since   22.May.2015
     */
    private String DoGenProductFiltersXML()
    {
        String xml = '';
                
        for (VCG_CPQ_Product_Filter__c rec : [SELECT Name,
                                                     Sequence__c,
                                                     IsActive__c,
                                                     Formula__c,
                                                     Product_Where_Clause__c,
                                                     Needs_Fields__c
                                              FROM VCG_CPQ_Product_Filter__c
                                              ORDER BY Name])
        {
            xml += DoGenProductFilterXML(rec);
        }
        
        return xml;
    }
    
    /**
     *
     * @author  Lawrence Coffin <lawrence.coffin@cloudsherpas.com>
     * @since   22.May.2015
     */
    private String DoGenProductFilterXML(VCG_CPQ_Product_Filter__c rec)
    {
        String xml = '';
        
        xml += '  <VCG_CPQ_Product_Filter__c>\n';
        xml += '    <Name>' + String.valueOf(rec.Name).escapeXml() + '</Name>\n';
        xml += '    <Sequence__c>' + String.valueOf(rec.Sequence__c).escapeXml() + '</Sequence__c>\n';
        xml += '    <IsActive__c>' + String.valueOf(rec.IsActive__c).escapeXml() + '</IsActive__c>\n';
        xml += '    <Formula__c>' + String.valueOf(rec.Formula__c).escapeXml() + '</Formula__c>\n';
        xml += '    <Product_Where_Clause__c>' + String.valueOf(rec.Product_Where_Clause__c).escapeXml() + '</Product_Where_Clause__c>\n';
        if (rec.Needs_Fields__c != null) xml += '    <Needs_Fields__c>' + String.valueOf(rec.Needs_Fields__c).escapeXml() + '</Needs_Fields__c>\n';
        xml += '  </VCG_CPQ_Product_Filter__c>\n';
        
        return xml;
    }
    
    
    
    /***************************************************************************************
     * Field Layouts Config
     ***************************************************************************************/
    
    /**
     *
     * @author  Lawrence Coffin <lawrence.coffin@cloudsherpas.com>
     * @since   17.Aug.2015
     */
    private String DoGenFieldLayoutsXML()
    {
        String xml = '';
                
        for (VCG_CPQ_Page_Layout__c rec : [SELECT Page_Section__c,
                                                  Order__c,
                                                  Field__c,
                                                  Display_Type__c,
                                                  Required__c,
                                                  Alt_Label__c,
                                                  Display_For_Product_Type__c,
                                                  AND_Display_If__c,
                                                  Needs_Fields__c
                                           FROM VCG_CPQ_Page_Layout__c
                                           ORDER BY Page_Section__c, Order__c])
        {
            xml += DoGenFieldLayoutXML(rec);
        }
        
        if (xml != '')
        {
            xml = '  <!-- Order of Field Layouts (Page_Layout) below defines their sequence within a Page Section -->\n' + xml;
        }
        
        return xml;
    }
    
    /**
     *
     * @author  Lawrence Coffin <lawrence.coffin@cloudsherpas.com>
     * @since   17.Aug.2015
     */
    private String DoGenFieldLayoutXML(VCG_CPQ_Page_Layout__c rec)
    {
        String xml = '';
        
        xml += '  <VCG_CPQ_Page_Layout__c>\n';
        if (rec.Page_Section__c != null) xml += '    <Page_Section__c>' + String.valueOf(rec.Page_Section__c).escapeXml() + '</Page_Section__c>\n';
//        if (rec.Order__c != null)        xml += '    <Order__c>' + String.valueOf(rec.Order__c).escapeXml() + '</Order__c>\n';
        if (rec.Field__c != null)        xml += '    <Field__c>' + String.valueOf(rec.Field__c).escapeXml() + '</Field__c>\n';
        if (rec.Display_Type__c != null) xml += '    <Display_Type__c>' + String.valueOf(rec.Display_Type__c).escapeXml() + '</Display_Type__c>\n';
        xml += '    <Required__c>' + String.valueOf(rec.Required__c).escapeXml() + '</Required__c>\n';
        if (rec.Alt_Label__c != null)    xml += '    <Alt_Label__c>' + String.valueOf(rec.Alt_Label__c).escapeXml() + '</Alt_Label__c>\n';
        
        // Display_For_Product_Type__c
        if (rec.Display_For_Product_Type__c != null)
        {
            List<String> displayForTypes = rec.Display_For_Product_Type__c.split(';\\s*');
            displayForTypes.sort();
            
            for (String s : displayForTypes)
            {
                xml += '    <Display_For_Product_Type__c>' + s.escapeXml() + '</Display_For_Product_Type__c>\n';
            }
        }
        
        // AND_Display_If__c
        if (rec.AND_Display_If__c != null)    xml += '    <AND_Display_If__c>' + String.valueOf(rec.AND_Display_If__c).escapeXml() + '</AND_Display_If__c>\n';
        
        // Needs Fields
        if (rec.Needs_Fields__c != null)
        {
            List<String> needsFields = rec.Needs_Fields__c.split(';\\s*');
            needsFields.sort();
            
            for (String needsField : needsFields)
            {
                xml += '    <Needs_Fields__c>' + needsField.escapeXml() + '</Needs_Fields__c>\n';
            }
        }
        
        xml += '  </VCG_CPQ_Page_Layout__c>\n';
        
        return xml;
    }
    
    /***************************************************************************************
     * Opp to Quote Mappings Config
     ***************************************************************************************/
    
    /**
     *
     * @author  Lawrence Coffin <lawrence.coffin@cloudsherpas.com>
     * @since   30.Aug.2015
     */
    private String DoGenOppQuoteMapsXML()
    {
        String xml = '';
        
        for (VCG_CPQ_Opportunity_Quote_Map__c rec : [SELECT Quote_Field__c,
                                                            Source__c,
		                                                    Source_Type__c,
		                                                    Needs_Fields__c,
		                                                    Active__c
                                                     FROM VCG_CPQ_Opportunity_Quote_Map__c
	                                                 ORDER BY Quote_Field__c])
        {
            xml += DoGenOppQuoteMapXML(rec);
        }
        
        return xml;
    }
    
    /**
     *
     * @author  Lawrence Coffin <lawrence.coffin@cloudsherpas.com>
     * @since   30.Aug.2015
     */
    private String DoGenOppQuoteMapXML(VCG_CPQ_Opportunity_Quote_Map__c rec)
    {
        String xml = '';
        
        xml += '  <VCG_CPQ_Opportunity_Quote_Map__c>\n';
        xml += '    <Quote_Field__c>' + String.valueOf(rec.Quote_Field__c).escapeXml() + '</Quote_Field__c>\n';
        xml += '    <Source__c>' + String.valueOf(rec.Source__c).escapeXml() + '</Source__c>\n';
        xml += '    <Source_Type__c>' + String.valueOf(rec.Source_Type__c).escapeXml() + '</Source_Type__c>\n';
        xml += '    <Active__c>' + String.valueOf(rec.Active__c).escapeXml() + '</Active__c>\n';
        
        // Needs Fields
        if (rec.Needs_Fields__c != null)
        {
            List<String> needsFields = rec.Needs_Fields__c.split(';\\s*');
            needsFields.sort();
            
            for (String needsField : needsFields)
            {
                xml += '    <Needs_Fields__c>' + needsField.escapeXml() + '</Needs_Fields__c>\n';
            }
        }
        
        xml += '  </VCG_CPQ_Opportunity_Quote_Map__c>\n';
        
        return xml;
    }
    
    /***************************************************************************************
     * Quote to Opp Mappings Config
     ***************************************************************************************/
    
    /**
     *
     * @author  Lawrence Coffin <lawrence.coffin@cloudsherpas.com>
     * @since   30.Aug.2015
     */
    private String DoGenQuoteOppMapsXML()
    {
        String xml = '';
        
        for (VCG_CPQ_Quote_Opportunity_Map__c rec : [SELECT Opportunity_Field__c,
                                                            Quote_Field__c,
                                                            Active__c
                                                     FROM VCG_CPQ_Quote_Opportunity_Map__c
                                                     ORDER BY Opportunity_Field__c])
        {
            xml += DoGenQuoteOppMapXML(rec);
        }
        
        return xml;
    }
    
    /**
     *
     * @author  Lawrence Coffin <lawrence.coffin@cloudsherpas.com>
     * @since   30.Aug.2015
     */
    private String DoGenQuoteOppMapXML(VCG_CPQ_Quote_Opportunity_Map__c rec)
    {
        String xml = '';
        
        xml += '  <VCG_CPQ_Quote_Opportunity_Map__c>\n';
        xml += '    <Opportunity_Field__c>' + String.valueOf(rec.Opportunity_Field__c).escapeXml() + '</Opportunity_Field__c>\n';
        xml += '    <Quote_Field__c>' + String.valueOf(rec.Quote_Field__c).escapeXml() + '</Quote_Field__c>\n';
        xml += '    <Active__c>' + String.valueOf(rec.Active__c).escapeXml() + '</Active__c>\n';
        xml += '  </VCG_CPQ_Quote_Opportunity_Map__c>\n';
        
        return xml;
    }
    
    /***************************************************************************************
     * QLI to OLI Mappings Config
     ***************************************************************************************/
    
    /**
     *
     * @author  Lawrence Coffin <lawrence.coffin@cloudsherpas.com>
     * @since   30.Aug.2015
     */
    private String DoGenQLIOLIMapsXML()
    {
        String xml = '';
        
        for (VCG_CPQ_Quote_Product_Oppty_Product_Map__c rec : [SELECT Opportunity_Product_Field__c,
                                                                      Quote_Product_Field__c,
                                                                      Active__c
                                                               FROM VCG_CPQ_Quote_Product_Oppty_Product_Map__c
                                                               ORDER BY Opportunity_Product_Field__c])
        {
            xml += DoGenQLIOLIMapXML(rec);
        }
        
        return xml;
    }
    
    /**
     *
     * @author  Lawrence Coffin <lawrence.coffin@cloudsherpas.com>
     * @since   30.Aug.2015
     */
    private String DoGenQLIOLIMapXML(VCG_CPQ_Quote_Product_Oppty_Product_Map__c rec)
    {
        String xml = '';
        
        xml += '  <VCG_CPQ_Quote_Product_Oppty_Product_Map__c>\n';
        xml += '    <Opportunity_Product_Field__c>' + String.valueOf(rec.Opportunity_Product_Field__c).escapeXml() + '</Opportunity_Product_Field__c>\n';
        xml += '    <Quote_Product_Field__c>' + String.valueOf(rec.Quote_Product_Field__c).escapeXml() + '</Quote_Product_Field__c>\n';
        xml += '    <Active__c>' + String.valueOf(rec.Active__c).escapeXml() + '</Active__c>\n';
        xml += '  </VCG_CPQ_Quote_Product_Oppty_Product_Map__c>\n';
        
        return xml;
    }
    
}