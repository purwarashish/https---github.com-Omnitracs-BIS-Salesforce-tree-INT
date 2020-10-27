/*******************************************************************************
* @author  vishal shanbhag      
* @date      1.April.2014    
* @return         
* @description    Utility class which will create the test data for Test classes 
* @Revision(s)    NS: THis needs to be revised as follows:  
*               1. Naming convention: Class needs to use the previx VCG_CPQ
*******************************************************************************/
@isTest
public with sharing class VCG_CPQ_HelperTestClass {
    
/*******************************************************************************
* @author  vishal shanbhag      
* @date      1.April.2014           
* @param          

* @return         Product2 Object

* @description    This Method will called from the test class with the respective 
                  parameters it will instantiate the object and return it to the 
                  test class

* @Revision(s) 
*******************************************************************************/  

public static List<Product2> createProductRecords(){
     Product2 sobj = new Product2();
     List<Product2> prodList = new List<Product2>();
     
     sobj.Name = 'test prod';
     sobj.Family = 'TRITON';
     sobj.License_Metric__c = 'test unit';
     sobj.ProductCode = 'testProductcode';
     sobj.IsActive = true;
     sobj.Available_for_Net_New__c = true;
     sobj.Is_Groupable__c = false;
     prodList.add(sobj);
     Product2 sobj2 = new Product2();
     sobj2.Name = 'test prod2';
     sobj2.Family = 'Web';
     sobj2.License_Metric__c = 'test unit';
     sobj2.ProductCode = 'testProductcode';
     sobj2.IsActive = true;
     sobj2.Available_for_Net_New__c = true;
     sobj2.Is_Groupable__c = true;
     prodList.add(sobj2);
     Product2 sobj3 = new Product2();
     sobj3.Name = 'test prod3';
     sobj3.Family = 'Data Security';
     sobj3.License_Metric__c = 'test unit';
     sobj3.ProductCode = 'testProductcode';
     sobj3.IsActive = true;
     sobj3.Available_for_Net_New__c = true;
     sobj3.Is_Groupable__c = true;
     prodList.add(sobj3);
     Product2 sobj4 = new Product2();
     sobj4.Name = 'test prod4';
     sobj4.Family = 'Cloud Web Security';
     sobj4.License_Metric__c = 'test unit';
     sobj4.ProductCode = 'testProductcode';
     sobj4.IsActive = true;
     sobj4.Available_for_Net_New__c = true;
     sobj4.Is_Groupable__c = true;
     prodList.add(sobj4);
     return prodList;
}

/*******************************************************************************
* @author  vishal shanbhag      
* @date      1.April.2014           
* @param          

* @return         Opportunity Object

* @description    This Method will called from the test class with the respective 
                  parameters it will instantiate the object and return it to the 
                  test class

* @Revision(s) 
*******************************************************************************/ 
public static Opportunity createOpportunityRecord(){
    
    Opportunity sObj = new Opportunity();
    sObj.Name = 'test opportunity';
    Date tempDate = date.newInstance(2014, 4, 1);
    sObj.CloseDate = tempDate;
    sobj.StageName = 'Prospecting';
    
    return sObj;
    
}
/*******************************************************************************
* @author  vishal shanbhag      
* @date      1.April.2014           
* @param          

* @return         Account Object

* @description    This Method will called from the test class with the respective 
                  parameters it will instantiate the object and return it to the 
                  test class

* @Revision(s) 
*******************************************************************************/ 
public static Account createAccountRecord(){
    Account sobj = new Account();
    sobj.Name = 'test Account';
    return sobj;
    
}
/*******************************************************************************
* @author  vishal shanbhag      
* @date      1.April.2014           
* @param          

* @return         Asset__c Object

* @description    This Method will called from the test class with the respective 
                  parameters it will instantiate the object and return it to the 
                  test class

* @Revision(s) 
*******************************************************************************/ 
public static Asset__c createAssetRecord(){
    Asset__c sobj = new Asset__c();
     sobj.Term_Start_Date__c = date.parse('12/27/2013');
        sobj.Asset_Term_End_Date__c = Date.today().addMonths(2);
        sobj.ARR__c = 7500.0;
        sobj.License_Metric_Quantity__c = 112.0;
    
    return sobj;
}
/*******************************************************************************
* @author  vishal shanbhag      
* @date      1.April.2014           
* @param          

* @return         VCG_CPQ_Quote_Product__c Object

* @description    This Method will called from the test class with the respective 
                  parameters it will instantiate the object and return it to the 
                  test class

* @Revision(s) 
*******************************************************************************/
public static List<VCG_CPQ_Quote_Product__c> createQuoteAssetRecords(){
    List<VCG_CPQ_Quote_Product__c> quoteProdList = new list<VCG_CPQ_Quote_Product__c>();
     // creating quote product record
        VCG_CPQ_Quote_Product__c quoteProduct1 = new VCG_CPQ_Quote_Product__c();
        quoteProduct1.License_Metric_Quantity__c = 12.0;
        quoteProduct1.Line_Type__c = 'New';
        quoteProduct1.Asset_Term_Start_Date__c = date.today();
        quoteProduct1.Asset_Term_End_Date__c = date.today().addMonths(2);
        quoteProduct1.Product_Group__c = '';
        quoteProdList.add(quoteProduct1);
        // create renewal quote product record
        VCG_CPQ_Quote_Product__c renewalQuoteProd = new VCG_CPQ_Quote_Product__c();
        renewalQuoteProd.License_Metric_Quantity__c = 12.0;
        renewalQuoteProd.Asset_Term_Start_Date__c = date.today();
        renewalQuoteProd.Asset_Term_End_Date__c = date.today().addMonths(2);
        renewalQuoteProd.Line_Type__c = 'Renewal';
        renewalQuoteProd.Product_Group__c = 'Group 4';
        quoteProdList.add(renewalQuoteProd);
        // create Extensinon quote product record
        VCG_CPQ_Quote_Product__c ExtensionQuoteProd = new VCG_CPQ_Quote_Product__c();
        ExtensionQuoteProd.License_Metric_Quantity__c = 12.0;
        ExtensionQuoteProd.Asset_Term_Start_Date__c = date.today();
        ExtensionQuoteProd.Asset_Term_End_Date__c = date.today().addMonths(2);
        ExtensionQuoteProd.Line_Type__c = 'Extension';
        ExtensionQuoteProd.Product_Group__c = 'Group 3';
        quoteProdList.add(ExtensionQuoteProd);
         // create renewal quote product record
        VCG_CPQ_Quote_Product__c DecommisionQuoteProd = new VCG_CPQ_Quote_Product__c();
        DecommisionQuoteProd.License_Metric_Quantity__c = 12.0;
        DecommisionQuoteProd.Asset_Term_Start_Date__c = date.today();
        DecommisionQuoteProd.Asset_Term_End_Date__c = date.today().addMonths(2);
        DecommisionQuoteProd.Line_Type__c = 'Decommission';
        DecommisionQuoteProd.Product_Group__c = 'Group 2';
        quoteProdList.add(DecommisionQuoteProd);
        return quoteProdList;
  
  
}
/*******************************************************************************
* @author  vishal shanbhag      
* @date      1.April.2014           
* @param          

* @return         VCG_CPQ_Bundle__c Object

* @description    This Method will called from the test class with the respective 
                  parameters it will instantiate the object and return it to the 
                  test class

* @Revision(s) 
*******************************************************************************/
public static List<VCG_CPQ_Bundle__c> createBundleRecord(){
    List<VCG_CPQ_Bundle__c> bundleList = new List<VCG_CPQ_Bundle__c>();
    VCG_CPQ_Bundle__c bundle1 = new VCG_CPQ_Bundle__c();
    bundle1.Bundle_Name__c = 'Bundle A';
    bundle1.IsActive__c = true;
    bundle1.Primary_Quantity_Percent__c = 100.0;
    bundle1.Primary__c = 'No';
    bundleList.add(bundle1);
    VCG_CPQ_Bundle__c bundle2 = new VCG_CPQ_Bundle__c();
    bundle2.Bundle_Name__c = 'Bundle A';
    bundle2.IsActive__c = true;
    bundle2.Primary_Quantity_Percent__c = 100.0;
    bundle2.Primary__c = 'Yes';
    bundleList.add(bundle2);
    VCG_CPQ_Bundle__c bundle3 = new VCG_CPQ_Bundle__c();
    bundle3.Bundle_Name__c = 'Triton APX';
    bundle3.IsActive__c = true;
    bundle3.Primary_Quantity_Percent__c = 100.0;
    bundle3.Primary__c = 'Yes';
    bundleList.add(bundle3);
    VCG_CPQ_Bundle__c bundle4 = new VCG_CPQ_Bundle__c();
    bundle4.Bundle_Name__c = 'Triton APX';
    bundle4.IsActive__c = true;
    bundle4.Primary_Quantity_Percent__c = 100.0;
    bundle4.Primary__c = 'No';
    bundleList.add(bundle4);
    return bundleList;
    
}
/*******************************************************************************
* @author  vishal shanbhag      
* @date      1.April.2014           
* @param          

* @return         VCG_CPQ_Quote_Product_Pricing_Result__c Object

* @description    This Method will called from the test class with the respective 
                  parameters it will instantiate the object and return it to the 
                  test class

* @Revision(s) 
*******************************************************************************/
public static VCG_CPQ_Quote_Product_Pricing_Result__c createPricingResultRecord(){
    VCG_CPQ_Quote_Product_Pricing_Result__c sobj = new VCG_CPQ_Quote_Product_Pricing_Result__c();
    return sobj;
    
}
/*******************************************************************************
* @author  vishal shanbhag      
* @date      1.April.2014           
* @param          

* @return         VCG_CPQ_Opportunity_Quote_Map__c Object

* @description    This Method will called from the test class with the respective 
                  parameters it will instantiate the object and return it to the 
                  test class

* @Revision(s) 
*******************************************************************************/
public static VCG_CPQ_Opportunity_Quote_Map__c createOpptyQuoteMapRecord(){
    VCG_CPQ_Opportunity_Quote_Map__c sobj = new VCG_CPQ_Opportunity_Quote_Map__c();
    sobj.Active__c = true;
    return sobj;
    
}
/*******************************************************************************
* @author  vishal shanbhag      
* @date      1.April.2014           
* @param          

* @return         VCG_CPQ_Pricing_Procedure__c Object

* @description    This Method will called from the test class with the respective 
                  parameters it will instantiate the object and return it to the 
                  test class

* @Revision(s) 
*******************************************************************************/
public static VCG_CPQ_Pricing_Procedure__c createPricingProcedureRecord(){
    VCG_CPQ_Pricing_Procedure__c sobj = new VCG_CPQ_Pricing_Procedure__c();
    sobj.Description__c = 'New';
    sobj.Sequence__c = 10;
    sobj.Needs_Fields__c =  'Sales_Price__c;Asset_Term_Start_Date__c';
    sobj.Quote_Line_Type__c = 'New';
    return sobj;
}

/*******************************************************************************
* @author  Ataullah Khan      
* @date      1.April.2014           
* @param          

* @return         VCG_CPQ_Quote__c Object

* @description    This Method will called from the test class with the respective 
                  parameters it will instantiate the object and return it to the 
                  test class

* @Revision(s) 
*******************************************************************************/
public static VCG_CPQ_Quote__c createQuoteRecord(){
    VCG_CPQ_Quote__c sobj = new VCG_CPQ_Quote__c();
    //sobj.Amount__c = 1212;
    sobj.Distributor_Level__c = 'ABCD to Z';
    sobj.Expiration_Date__c = date.newInstance(2014, 10, 1);
    //sobj.Line_Items__c =0;
//    sobj.Name = 'testQuoteData';
    sobj.Total_Contract_Value__c=3434;
    sobj.Total__c=6757;
    //sobj.Total_Amount__c = 65757;
    sobj.Status__c='Pending';
    sobj.Start_Date__c=date.newInstance(2014, 4, 1);
    return sobj;
}

/*******************************************************************************
* @author  Ataullah Khan      
* @date      1.April.2014           
* @param          

* @return         VCG_CPQ_Pricing_Access_Sequence__c Object

* @description    This Method will called from the test class with the respective 
                  parameters it will instantiate the object and return it to the 
                  test class

* @Revision(s) 
*******************************************************************************/
public static VCG_CPQ_Pricing_Access_Sequence__c createPricingAccessSequenceRecord(){
    VCG_CPQ_Pricing_Access_Sequence__c sobj = new VCG_CPQ_Pricing_Access_Sequence__c();
    sobj.Assign_To__c ='License_Metric_Quantity__c';
    sobj.Description__c = 'Copy Asset Quantity to Product Quantity';
    sobj.Needs_Fields__c = 'Asset__r.field__c';
    return sobj;
    
}

/*******************************************************************************
* @author  Ataullah Khan      
* @date      1.April.2014           
* @param          

* @return         VCG_CPQ_Pricing_Procedure_Sequence__c Object

* @description    This Method will called from the test class with the respective 
                  parameters it will instantiate the object and return it to the 
                  test class

* @Revision(s) 
*******************************************************************************/
public static VCG_CPQ_Pricing_Procedure_Sequence__c createPricingProcedureSequenceRecord(){
    VCG_CPQ_Pricing_Procedure_Sequence__c sobj = new VCG_CPQ_Pricing_Procedure_Sequence__c();
    //sobj.Access_Sequence__c =
    //sobj.Pricing_Procedure__c =
    sobj.Sequence__c = 1.0;
    return sobj;
}

/*******************************************************************************
* @author  Ataullah Khan      
* @date      1.April.2014           
* @param          

* @return         VCG_CPQ_Pricing_Condition__c Object

* @description    This Method will called from the test class with the respective 
                  parameters it will instantiate the object and return it to the 
                  test class

* @Revision(s) 
*******************************************************************************/
public static VCG_CPQ_Pricing_Condition__c createPricingConditionRecord(){
    VCG_CPQ_Pricing_Condition__c sobj = new VCG_CPQ_Pricing_Condition__c();
     sobj.Calculation_Compiled__c = '"License_Metric_Quantity__c"';
        sobj.Calculation__c = '= Asset.LMQ';
        sobj.Data_Key_Definition__c = 'List_Price__c;Line_Type__c';
        sobj.Description__c = 'Set Product Quantity to Asset Quantity';
        sobj.Needs_Fields__c ='Asset__r.License_Metric_Quantity__c';
        sobj.Type__c ='Calculation';
    return sobj;
}
    /*******************************************************************************
* @author  Ataullah Khan      
* @date      1.April.2014           
* @param          

* @return         VCG_CPQ_Pricing_Condition_Data__c Object

* @description    This Method will called from the test class with the respective 
                  parameters it will instantiate the object and return it to the 
                  test class

* @Revision(s) 
*******************************************************************************/
public static List<VCG_CPQ_Pricing_Condition_Data__c> createPricingConditionDataRecord(){
    List<VCG_CPQ_Pricing_Condition_Data__c> pricingCondList = new List<VCG_CPQ_Pricing_Condition_Data__c>();
    
    VCG_CPQ_Pricing_Condition_Data__c sobj = new VCG_CPQ_Pricing_Condition_Data__c();
    sobj.Data_Key__c = 'Platinum';
    sobj.Data_Scale_1__c = 9999.0;
    sobj.Data_Scale_2__c = 10.0;
    sobj.Data_Scale_3__c = 90.0;
    sobj.Multiply_by_Quantity__c = false;
    sobj.Result_Type__c ='Percentage';
    sobj.Result_Value__c = 12; 
    pricingCondList.add(sobj);
    VCG_CPQ_Pricing_Condition_Data__c sobj1 = new VCG_CPQ_Pricing_Condition_Data__c();
     sobj1.Data_Key__c = 'PK-TN-CL-A-BSGB';
    sobj1.Data_Scale_1__c = 99999.0;
    sobj1.Data_Scale_2__c = 10.0;
    sobj1.Data_Scale_3__c = 90.0;
    sobj1.Multiply_by_Quantity__c = True;
    sobj1.Result_Type__c ='Currency Amount';
    sobj1.Result_Value__c =7000.0; 
    pricingCondList.add(sobj1);
    return pricingCondList;
}
/*******************************************************************************
* @author  Ataullah Khan      
* @date      1.April.2014           
* @param          

* @return         OpportunityLineItem Object

* @description    This Method will called from the test class with the respective 
                  parameters it will instantiate the object and return it to the 
                  test class

* @Revision(s) 
*******************************************************************************/
public static OpportunityLineItem createOpportunityLineItemRecord(){
   OpportunityLineItem sobj = new OpportunityLineItem();
//   sobj.Adjusted_List_Price__c = 12;
//   sobj.Allowance__c = 12.0;
//   sobj.Annual_Recurring_Revenue__c = 112;
//   sobj.Discount_Amount__c = 111;
//   sobj.Discount_Entered_As__c = 'Amount';
//   sobj.Extended_Term_Amount__c = 2232;
//   sobj.Line_Type__c = 'New';
   //sobj.ListPrice = 100;
//   sobj.Asset_Term_Start_Date__c = date.newInstance(2014, 10, 1);
   return sobj;
}
/*******************************************************************************
* @author  vishal shanbhag      
* @date      1.April.2014           
* @param          

* @return         VCG_CPQ_Page_Layout__c Object

* @description    This Method will called from the test class with the respective 
                  parameters it will instantiate the object and return it to the 
                  test class

* @Revision(s) 
*******************************************************************************/
public static VCG_CPQ_Page_Layout__c createVGCPageLayoutQuoteRecord(){
    
    VCG_CPQ_Page_Layout__c sobj = new VCG_CPQ_Page_Layout__c();
//  sobj.Controller_Object_Variable__c = 'quote';
    return sobj;
    
    
}
/*******************************************************************************
* @author  vishal shanbhag      
* @date      1.April.2014           
* @param          

* @return         map<String, Schema.DescribeFieldResult> 

* @description    This Method will called from the test class with the respective 
                  parameters it will instantiate the object and return it to the 
                  test class

* @Revision(s) 
*******************************************************************************/
public map<String, Schema.DescribeFieldResult> describeOjectfields (String objectName){
    
    map<String,Schema.Describefieldresult> results = new  map<String,Schema.Describefieldresult>();
    Schema.DescribeSObjectResult d;
    if(objectName == 'Opportunity')
            d = Opportunity.sObjectType.getDescribe();
        else if(objectName == 'VCG_CPQ_Quote__c')
            d = VCG_CPQ_Quote__c.sObjectType.getDescribe();
            else if(objectName == 'VCG_CPQ_Quote_Product__c')
            d = VCG_CPQ_Quote_Product__c.sObjectType.getDescribe();
            else if(objectName == 'OpportunityLineItem')
            d = OpportunityLineItem.sObjectType.getDescribe();
            
        
            
        Map<String, Schema.Sobjectfield> mapFieldList = d.fields.getMap();
        
        for(Schema.SObjectField field : mapFieldList.values())  
        {  
            Schema.DescribeFieldResult fieldResult = field.getDescribe();  
            if(fieldResult.isAccessible())  
            {  
                results.put(fieldResult.getName(), fieldResult);
            }  
        }
        
        return results;
}
 
  public  List<VCG_CPQ_Page_Layout__c> pageLayoutListMethod (){
    
    
    List<VCG_CPQ_Page_Layout__c> pageLayoutList = new List<VCG_CPQ_Page_Layout__c>();
  
  //creating VCG_CPQ_Page_Layout__c records 
        VCG_CPQ_Page_Layout__c layoutOrder6Spacer = VCG_CPQ_HelperTestClass.createVGCPageLayoutQuoteRecord();
//        layoutOrder6Spacer.Controller_Object_Variable__c = 'SPACER';
        layoutOrder6Spacer.Display_Type__c = 'Spacer';
        layoutOrder6Spacer.Page_Section__c = 'Header Detail';
        //layoutOrder6Spacer.Field__c = 'Name';
        layoutOrder6Spacer.Order__c = 6.0;
       pageLayoutList.add(layoutOrder6Spacer);
        //creating VCG_CPQ_Page_Layout__c records 
        VCG_CPQ_Page_Layout__c layoutOrder14 = VCG_CPQ_HelperTestClass.createVGCPageLayoutQuoteRecord();
        layoutOrder14.Display_Type__c = 'Input';
        layoutOrder14.Page_Section__c = 'Header Detail';
        layoutOrder14.Order__c = 14.0;
        layoutOrder14.Field__c = 'OwnerId';
        pageLayoutList.add(layoutOrder14);
        //creating VCG_CPQ_Page_Layout__c records 
        VCG_CPQ_Page_Layout__c layoutOrder112 = VCG_CPQ_HelperTestClass.createVGCPageLayoutQuoteRecord();
        layoutOrder112.Display_Type__c = 'Output';
        layoutOrder112.Page_Section__c = 'Header Detail';
        layoutOrder112.Order__c = 11.0;
        layoutOrder112.Field__c = 'Name';
        pageLayoutList.add(layoutOrder112);
        //creating VCG_CPQ_Page_Layout__c records 
        VCG_CPQ_Page_Layout__c layoutOrder11 = VCG_CPQ_HelperTestClass.createVGCPageLayoutQuoteRecord();
//        layoutOrder6Spacer.Controller_Object_Variable__c = 'quote';
        layoutOrder11.Display_Type__c = 'Output';
        layoutOrder11.Page_Section__c = 'Header Summary';
        layoutOrder11.Order__c = 1.0;
        layoutOrder11.Field__c = 'Name';
        pageLayoutList.add(layoutOrder11);
        //creating VCG_CPQ_Page_Layout__c records 
        VCG_CPQ_Page_Layout__c layoutOrder10Spacer = VCG_CPQ_HelperTestClass.createVGCPageLayoutQuoteRecord();
//        layoutOrder10Spacer.Controller_Object_Variable__c = 'quote';
        layoutOrder10Spacer.Display_Type__c = 'Spacer';
        layoutOrder10Spacer.Page_Section__c = 'Header Summary';
        layoutOrder10Spacer.Order__c = 6.0;
        pageLayoutList.add(layoutOrder10Spacer);
        //creating VCG_CPQ_Page_Layout__c records 
        VCG_CPQ_Page_Layout__c layoutOrder92 = VCG_CPQ_HelperTestClass.createVGCPageLayoutQuoteRecord();
        layoutOrder92.Display_Type__c = 'Input';
        layoutOrder92.Page_Section__c = 'Header Summary';
        layoutOrder92.Order__c = 9.0;
        layoutOrder92.Field__c = 'OwnerId';
        pageLayoutList.add(layoutOrder92);
        
    return pageLayoutList;
  }
/*******************************************************************************
* @author  vishal shanbhag      
* @date      5.May.2014           
* @param          

* @return         PricebookEntry Object

* @description    This Method will called from the test class with the respective 
                  parameters it will instantiate the object and return it to the 
                  test class

* @Revision(s) 
*******************************************************************************/   
public static  List<PricebookEntry> createPriceBookEntryRecord(){
    List<PricebookEntry> PBentryList = new List<PricebookEntry>();
    // creating pticebook entrty records
    PricebookEntry PBE1 = new PricebookEntry();
    PBE1.IsActive = true;
    PBE1.UnitPrice = 100.0;
    PBE1.UseStandardPrice = false;
    PBentryList.add(PBE1);
    //
    PricebookEntry PBE2 = new PricebookEntry();
    PBE2.IsActive = true;
    PBE2.UnitPrice = 100.0;
    PBE2.UseStandardPrice = false;
    PBentryList.add(PBE2);
    //
    PricebookEntry PBE3 = new PricebookEntry();
    PBE3.IsActive = true;
    PBE3.UnitPrice = 100.0;
    PBE3.UseStandardPrice = false;
    PBentryList.add(PBE3);
    //
    PricebookEntry PBE4 = new PricebookEntry();
    PBE4.IsActive = true;
    PBE4.UnitPrice = 100.0;
    PBE4.UseStandardPrice = false;
    PBentryList.add(PBE4);
    //
    return PBentryList;
}

}