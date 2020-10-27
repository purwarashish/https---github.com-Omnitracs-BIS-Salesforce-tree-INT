/**
 * 
 */
@isTest(SeeAllData=True)
private class VCG_CPQ_PricingUtility_Test {

    static void myUnitTest() {
        // TO DO: implement unit test
        Account acc = VCG_CPQ_HelperTestClass.createAccountRecord();
        insert acc;
        
        //Added RecordType and StageName ='Sales Acceptance' by JBarrameda - 10/30/2014
        Id oldProdRecType = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Products, Services and Maintenance').getRecordTypeId();
        
        Opportunity opp = VCG_CPQ_HelperTestClass.createOpportunityRecord();
        opp.AccountId = acc.id;
        opp.RecordTypeId = oldProdRecType;
        opp.StageName = 'Sales Acceptance';
        insert opp;
        
        Contact cnt = new Contact();
        cnt.Lastname = 'ABC';
        cnt.AccountId = acc.id;
        insert cnt;
        
        VCG_CPQ_Quote__c Cquote = VCG_CPQ_HelperTestClass.createQuoteRecord();
        Cquote.Is_Primary__c = True;
        Cquote.opportunity__c = opp.id;
        Cquote.CurrencyIsoCode = 'USD';
        insert Cquote;
        
        product2 pdt = VCG_CPQ_HelperTestClass.createProductRecords()[0];
        insert pdt; 
        
        PricebookEntry pbe = new PricebookEntry(
                                                    Pricebook2Id = Test.getStandardPricebookId(),
                                                    Product2Id = pdt.Id,
                                                    UnitPrice = 0,
                                                    CurrencyIsoCode = 'USD',
                                                    IsActive = true
                                               );
        insert pbe;
        
        Asset asst = new Asset();
        asst.AccountId = acc.Id;
        asst.ContactId = cnt.Id;
        asst.InstallDate = Date.Today();
        asst.IsCompetitorProduct = false;
        asst.Name= 'Cyber Security';
        asst.Product2Id = pdt.id;
        asst.PurchaseDate = Date.Today();
        asst.Status = 'Installed';
        insert asst;
        
        Asset__c casst = VCG_CPQ_HelperTestClass.createAssetRecord();
        casst.Account__c = acc.Id;
//        casst.Opportunity__c = opp.Id;
        casst.Product__c = pdt.Id;
//        casst.Original_Asset__c = asst.Id;
        insert casst;
       
        List<VCG_CPQ_Quote_Product__c> QPdtLst = new List<VCG_CPQ_Quote_Product__c>();
       
       for(integer i=0; i< = 20 ; i++){
        VCG_CPQ_Quote_Product__c Qpdt = VCG_CPQ_HelperTestClass.createQuoteAssetRecords()[0];
        Qpdt.Quote__c = Cquote.id;
        Qpdt.Product__c = pdt.Id;
        Qpdt.CurrencyIsoCode = 'USD';
        Qpdt.Asset_Term_End_Date__c = Date.today().addMonths(2);
       if(i<=5)
        Qpdt.Line_Type__c = 'New';
       if(i>5 && i<=10) 
        Qpdt.Line_Type__c = 'Extension';
       if(i > 10 && i<= 15)
         Qpdt.Line_Type__c = 'Renewal';
       if(i > 15 && 1<= 20)
         Qpdt.Line_Type__c = 'Migration';  
        Qpdt.Additional_Discounts__c = 12.5;
        Qpdt.Adjusted_List_Price__c = 1213;
        Qpdt.Allowance__c = 123;
        Qpdt.Annual_Recurring_Revenue__c = 43232;
        Qpdt.Discount_Entered_As__c = 'Amount';
        Qpdt.Deal_Reg_Discount__c = 12;
        Qpdt.Total_Price__c = 6576;
        Qpdt.Asset__c = casst.id;
        QpdtLst.add(Qpdt);
       }
        
      insert QpdtLst; 
      
      VCG_CPQ_Pricing_Access_Sequence__c prAcSeq = new VCG_CPQ_Pricing_Access_Sequence__c();
      prAcSeq.Assign_To__c = 'License_Metric_Quantity__c';
      prAcSeq.Description__c = 'This is the Description part';
      prAcSeq.Needs_Fields__c = 'Asset__r.License_Metric_Quantity__c';
      insert prAcSeq;
      
      VCG_CPQ_Opportunity_Quote_Map__c oppQtMAp = new VCG_CPQ_Opportunity_Quote_Map__c();
      oppQtMAp.Active__c = True;
      oppQtMAp.Source__c = 'AccountId';
      oppQtMAp.Quote_Field__c = 'Account__c';
      oppQtMAp.Source_Type__c = 'Opportunity Field';
      insert oppQtMAp;
      
      
      
      VCG_CPQ_Pricing_Condition__c PriCondtn = new VCG_CPQ_Pricing_Condition__c();
      PriCondtn.Calculation_Compiled__c = '"License_Metric_Quantity__c"';
      PriCondtn.Calculation__c = '= Asset.LMQ';
      PriCondtn.Data_Key_Definition__c = 'List_Price__c;Line_Type__c';
      PriCondtn.Description__c = 'Set Product Quantity to Asset Quantity';
      PriCondtn.Needs_Fields__c ='Asset__r.License_Metric_Quantity__c';
      PriCondtn.Type__c ='Calculation';
      insert PriCondtn;
      
      List<VCG_CPQ_Pricing_Condition_Data__c > PricCondLst = new List<VCG_CPQ_Pricing_Condition_Data__c>();

      VCG_CPQ_Pricing_Condition_Data__c PrcCondData = new VCG_CPQ_Pricing_Condition_Data__c();
      PrcCondData.Condition__c = PriCondtn.id;
      PrcCondData.Data_Key__c = 'Platinum';
      PrcCondData.Data_Scale_1__c = 50;
      PrcCondData.Multiply_by_Quantity__c = True;
      PrcCondData.Result_Type__c ='Percentage';
      PrcCondData.Result_Value__c = 12;
      PricCondLst.add(PrcCondData);
      
      VCG_CPQ_Pricing_Condition_Data__c PrcCondData1 = new VCG_CPQ_Pricing_Condition_Data__c();
      PrcCondData1.Condition__c = PriCondtn.id;
      PrcCondData1.Data_Key__c = 'Platinum';
      PrcCondData1.Data_Scale_1__c = 9999.0;
      PrcCondData1.Data_Scale_2__c = 10.0;
      PrcCondData1.Data_Scale_3__c = 90.0;
      PrcCondData1.Multiply_by_Quantity__c = True;
      PrcCondData1.Result_Type__c ='Percentage';
      PrcCondData1.Result_Value__c = 12; 
      PricCondLst.add(PrcCondData1);
      
      VCG_CPQ_Pricing_Condition_Data__c PrcCondData2 = new VCG_CPQ_Pricing_Condition_Data__c();
      PrcCondData2.Condition__c = PriCondtn.id;
      PrcCondData2.Data_Key__c = 'Silver';
      PrcCondData2.Data_Scale_1__c = 9999.0;
      PrcCondData2.Data_Scale_2__c = 10.0;
      PrcCondData2.Data_Scale_3__c = 90.0;
      PrcCondData2.Multiply_by_Quantity__c = True;
      PrcCondData2.Result_Type__c ='Currency Amount';
      PrcCondData2.Result_Value__c = 50.0;
      PricCondLst.add(PrcCondData2);
      
      VCG_CPQ_Pricing_Condition_Data__c PrcCondData3 = new VCG_CPQ_Pricing_Condition_Data__c();
      PrcCondData3.Condition__c = PriCondtn.id;
      PrcCondData3.Data_Key__c = 'Yes|Gold';
      PrcCondData3.Data_Scale_1__c = 9999.0;
      PrcCondData3.Data_Scale_2__c = 10.0;
      PrcCondData3.Data_Scale_3__c = 90.0;
      PrcCondData3.Multiply_by_Quantity__c = True;
      PrcCondData3.Result_Type__c ='Currency Amount';
      PrcCondData3.Result_Value__c = 50.0;
      PricCondLst.add(PrcCondData3);
      
      insert PricCondLst;
      
      
      //insert more rows
     
     
      VCG_CPQ_Pricing_Sequence_Condition__c PriSeqCon = new VCG_CPQ_Pricing_Sequence_Condition__c();
      PriSeqCon.Access_Sequence__c = prAcSeq.id;
      PriSeqCon.Condition__c = PriCondtn.id;
      PriSeqCon.Sequence__c = 1;
      insert PriSeqCon;
      
      VCG_CPQ_Pricing_Procedure__c PricgProc = new VCG_CPQ_Pricing_Procedure__c();
      PricgProc.Description__c = 'New';
      PricgProc.Sequence__c = 10;
      PricgProc.Needs_Fields__c =  'Sales_Price__c;Asset_Term_Start_Date__c;Asset_Term_End_Date__c;Discount_Percentage__c;Product__r.ProductCode;License_Metric_Quantity__c;Quote__r.Reseller__r.Partner_Tier__c;Quote__r.Distributor__r.Partner_Tier__c'; //Removed by JBarrameda 10/30/2014
      PricgProc.Quote_Line_Type__c = 'New';
      insert PricgProc;
      
      VCG_CPQ_Pricing_Procedure_Sequence__c PriProSeq = new VCG_CPQ_Pricing_Procedure_Sequence__c();
      PriProSeq.Access_Sequence__c = prAcSeq.id;
      PriProSeq.Pricing_Procedure__c = PricgProc.id;
      PriProSeq.Sequence__c = 1;
      insert PriProSeq;
      
      VCG_CPQ_Quote_Product_Oppty_Product_Map__c pdtmap= new VCG_CPQ_Quote_Product_Oppty_Product_Map__c();
      pdtmap.Quote_Product_Field__c =  'License_Metric_Quantity__c';    
      pdtmap.Opportunity_Product_Field__c   = 'License_Metric_Quantity__c';
      pdtmap.Active__c = True;
      insert pdtmap;
      
      VCG_CPQ_Quote_Opportunity_Map__c oppMap = new VCG_CPQ_Quote_Opportunity_Map__c();
      oppMap.Active__c = True;
      oppMap.Quote_Field__c = 'Effective_Date__c';
      oppMap.Opportunity_Field__c = 'Primary_Quote_Effective_Date__c';
      insert oppMap;
      
      Test.startTest();
      
      
      VCG_CPQ_PricingUtility.populateFormulaData(Cquote);
      VCG_CPQ_PricingUtility.priceQuoteProducts(Cquote, QpdtLst, null, new Map<String,VCG_CPQ_Pricing_Override__c>(), new VCG_CPQ_QuoteController(new ApexPages.StandardController(new VCG_CPQ_Quote__c())) ); 
      VCG_CPQ_PricingUtility.setQuoteDefaults(opp, Cquote);
//      VCG_CPQ_PricingUtility.getAddOns(QpdtLst);
      VCG_CPQ_PricingUtility.syncPrimaryQuote(Cquote);
      
      Test.stopTest();  
    }
    
    
    /**
     * @description  Tests ConvertCurrencyIfNeeded()
     * 
     * @author  Lawrence Coffin <lawrence.coffin@cloudsherpas.com>
     * @author  Tanvir Ansari <tanvir.ansari@cloudsherpas.com>
     * @since   12.Oct.2014
     */
    static testMethod void testConvertCurrencyIfNeeded()
    {
        VCG_CPQ_Quote__c quote = new VCG_CPQ_Quote__c();
        VCG_CPQ_Pricing_Condition_Data__c dataRec = new VCG_CPQ_Pricing_Condition_Data__c( Result_Type__c = 'Currency Amount' );
        
        if (UserInfo.isMultiCurrencyOrganization())
        {
            Map<String,Decimal> exchangeRates = new Map<String,Decimal>();
            List<String> isoCodes = new List<String>();
            
            for ( sObject c : Database.query('SELECT ISOCode,ConversionRate FROM CurrencyType'))
            {
                 exchangeRates.put((String)c.get('isoCode'), (Decimal)c.get('ConversionRate'));
                 isoCodes.add((String)c.get('IsoCode'));
            }
            
            //
            // Select first two iso codes to convert between
            //
            if (exchangeRates.size() > 1)
            {
                String QuoteISO = isoCodes[0];
                String DataRecISO = isoCodes[1];
                
                quote.put('CurrencyIsoCode', QuoteISO);
                dataRec.put('CurrencyIsoCode', DataRecISO);
                
                System.assertEquals(23.45 * exchangeRates.get(QuoteISO) / exchangeRates.get(DataRecISO) , VCG_CPQ_PricingUtility.ConvertCurrencyIfNeeded(quote, dataRec, 23.45));
            }
            
            //
            // Select first two iso codes to convert between - but in the opposite direction
            //
            if (exchangeRates.size() > 1)
            {
                // Reverse of the above
                String QuoteISO = isoCodes[1];
                String DataRecISO = isoCodes[0];
                
                quote.put('CurrencyIsoCode', QuoteISO);
                dataRec.put('CurrencyIsoCode', DataRecISO);
                
                System.assertEquals(23.45 * exchangeRates.get(QuoteISO) / exchangeRates.get(DataRecISO) , VCG_CPQ_PricingUtility.ConvertCurrencyIfNeeded(quote, dataRec, 23.45));
            }
            
            //
            // Select second and third iso codes to convert between
            //
            if (exchangeRates.size() > 2)
            {
                String QuoteISO = isoCodes[1];
                String DataRecISO = isoCodes[2];
                
                quote.put('CurrencyIsoCode', QuoteISO);
                dataRec.put('CurrencyIsoCode', DataRecISO);
                
                System.assertEquals(23.45 * exchangeRates.get(QuoteISO) / exchangeRates.get(DataRecISO) , VCG_CPQ_PricingUtility.ConvertCurrencyIfNeeded(quote, dataRec, 23.45));
            }
            
            //
            // Select first and third iso codes to convert between
            //
            if (exchangeRates.size() > 2)
            {
                String QuoteISO = isoCodes[0];
                String DataRecISO = isoCodes[2];
                
                quote.put('CurrencyIsoCode', QuoteISO);
                dataRec.put('CurrencyIsoCode', DataRecISO);
                
                System.assertEquals(23.45 * exchangeRates.get(QuoteISO) / exchangeRates.get(DataRecISO) , VCG_CPQ_PricingUtility.ConvertCurrencyIfNeeded(quote, dataRec, 23.45));
            }
            
            //
            // Confirm that non-'Currency Amount' values - Numeric - come through unchanged
            //
            if (exchangeRates.size() > 1)
            {
                String QuoteISO = isoCodes[0];
                String DataRecISO = isoCodes[1];
                
                quote.put('CurrencyIsoCode', QuoteISO);
                dataRec.put('CurrencyIsoCode', DataRecISO);
                
                dataRec.Result_Type__c = 'Numeric';
                
                System.assertEquals(23.45, VCG_CPQ_PricingUtility.ConvertCurrencyIfNeeded(quote, dataRec, 23.45));
            }
            
            //
            // Confirm that non-'Currency Amount' values - Percentage - come through unchanged
            //
            if (exchangeRates.size() > 1)
            {
                String QuoteISO = isoCodes[0];
                String DataRecISO = isoCodes[1];
                
                quote.put('CurrencyIsoCode', QuoteISO);
                dataRec.put('CurrencyIsoCode', DataRecISO);
                
                dataRec.Result_Type__c = 'Percentage';
                
                System.assertEquals(23.45, VCG_CPQ_PricingUtility.ConvertCurrencyIfNeeded(quote, dataRec, 23.45));
            }
        }
        else
        {
            //
            // Single-Currency org, test that value comes through un-changed
            //
            System.assertEquals(23.45, VCG_CPQ_PricingUtility.ConvertCurrencyIfNeeded(quote, dataRec, 23.45));
        }
    }
    
    
    /**
     * Test the SortQPRecordsForPricing() method used to sort products for
     * pricing by their add-on level.
     *
     * @author  Lawrence Coffin <lawrence.coffin@cloudsherpas.com>
     * @since   3.Nov.2014
     */
    static testMethod void testSortQPRecordsForPricing() {
        //
        // Create five Quote Product records
        //
        VCG_CPQ_Quote_Product__c qp1 = new VCG_CPQ_Quote_Product__c(
                                                                       Name = 'QP-AAA',
                                                                       Product__r = new Product2( Name = 'Prod-AAA' )
                                                                   );
        VCG_CPQ_Quote_Product__c qp2 = new VCG_CPQ_Quote_Product__c(
                                                                       Name = 'QP-BBB',
                                                                       Product__r = new Product2( Name = 'Prod-BBB' ),
                                                                       Add_On_Source_Quote_Product__r = qp1
                                                                   );
        VCG_CPQ_Quote_Product__c qp3 = new VCG_CPQ_Quote_Product__c(
                                                                       Name = 'QP-CCC',
                                                                       Product__r = new Product2( Name = 'Prod-CCC' ),
                                                                       Add_On_Source_Quote_Product__r = qp2
                                                                   );
        VCG_CPQ_Quote_Product__c qp4 = new VCG_CPQ_Quote_Product__c(
                                                                       Name = 'QP-DDD',
                                                                       Product__r = new Product2( Name = 'Prod-DDD' ),
                                                                       Add_On_Source_Quote_Product__r = qp3
                                                                   );
        VCG_CPQ_Quote_Product__c qp5 = new VCG_CPQ_Quote_Product__c(
                                                                       Name = 'QP-EEE',
                                                                       Product__r = new Product2( Name = 'Prod-EEE' ),
                                                                       Add_On_Source_Quote_Product__r = qp4
                                                                   );
        // Add them to a list in a semi-random order
        List<VCG_CPQ_Quote_Product__c> qpList = new List<VCG_CPQ_Quote_Product__c>{ qp3, qp2, qp4, qp1, qp5  };
        
        // Send them in to VCG_CPQ_PricingUtility.SortQPRecordsForPricing()
        VCG_CPQ_PricingUtility.SortQPRecordsForPricing(qpList);
        
        //
        // Confirm they have been sorted by add-on level/depth
        //
        System.assertEquals('QP-AAA', qpList[0].Name);
        System.assertEquals('QP-BBB', qpList[1].Name);
        System.assertEquals('QP-CCC', qpList[2].Name);
        System.assertEquals('QP-DDD', qpList[3].Name);
        System.assertEquals('QP-EEE', qpList[4].Name);
        
        //
        // Add them to the list in another semi-random order
        //
        qpList = new List<VCG_CPQ_Quote_Product__c>{ qp2, qp1, qp3, qp5, qp4  };
        
        // Send them in to VCG_CPQ_PricingUtility.SortQPRecordsForPricing()
        VCG_CPQ_PricingUtility.SortQPRecordsForPricing(qpList);
        
        //
        // Confirm they have been sorted by add-on level/depth
        //
        System.assertEquals('QP-AAA', qpList[0].Name);
        System.assertEquals('QP-BBB', qpList[1].Name);
        System.assertEquals('QP-CCC', qpList[2].Name);
        System.assertEquals('QP-DDD', qpList[3].Name);
        System.assertEquals('QP-EEE', qpList[4].Name);
        
        //
        // Add them to the list in reverse order
        //
        qpList = new List<VCG_CPQ_Quote_Product__c>{ qp5, qp4, qp3, qp2, qp1  };
        
        // Send them in to VCG_CPQ_PricingUtility.SortQPRecordsForPricing()
        VCG_CPQ_PricingUtility.SortQPRecordsForPricing(qpList);
        
        //
        // Confirm they have been sorted by add-on level/depth
        //
        System.assertEquals('QP-AAA', qpList[0].Name);
        System.assertEquals('QP-BBB', qpList[1].Name);
        System.assertEquals('QP-CCC', qpList[2].Name);
        System.assertEquals('QP-DDD', qpList[3].Name);
        System.assertEquals('QP-EEE', qpList[4].Name);
    }
}