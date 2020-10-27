@isTest(SeeAllData = true)
public without sharing class AssetUtility_Test {

    static testMethod void testComponentAssetCreation_NetNewProducts(){
        Account a = TestUtils.getAccount('ut1 Acc');
        insert a;

        Contract ctrct = TestUtils.getContract(a);
        insert ctrct;
        
        Product2 p0 = TestUtils.getProduct('ut prod0', 'family');
        p0.Is_Assetizable__c = true;
        p0.Is_Bundle__c = true;
        p0.isActive = true;
        insert p0;
        
        Pricebook2 standardPB = [select id from Pricebook2 where isStandard=true];
		PricebookEntry standardPBE = new PricebookEntry(Pricebook2Id = standardPB.Id, Product2Id = p0.Id, UnitPrice = 1000, IsActive = true);
    	insert standardPBE;
        
        Pricebook2 stdPb = [select Id from Pricebook2 where NAME = 'Domestic PriceBook'];
        update stdPb;
        
        PricebookEntry spbe =  new PricebookEntry(pricebook2id = stdPb.id, product2id = p0.id, unitprice=100.0, isActive=true);
        insert spbe;
        
        Opportunity oppty = TestUtils.getOpportunity(a, 'UT Oppty1');
        oppty.Contract__c = ctrct.id;
        oppty.Type = 'New Customer';
        oppty.Order_Type__c = 'New';
        oppty.StageName = 'Sales Acceptance';
        oppty.pricebook2id=stdPb.id;
        insert oppty;
        
        Product2 p1 = TestUtils.getProduct('ut prod1', 'family');
        p1.Is_Assetizable__c = true;
        p1.Is_Bundle__c = true;
        insert p1;
        
        OpportunityLineItem oli1 = TestUtils.getOLI(oppty, p1);
        oli1.Line_Type__c = 'New';
        oli1.Annual_Recurring_Revenue__c = 100;
        oli1.pricebookentryid=spbe.Id;
        insert oli1;
        
        Product2 p2 = TestUtils.getProduct('ut prod2', 'family');
        p2.Is_Assetizable__c = false;
        p2.Is_Bundle__c = false;
        p2.Family = 'Test';
        insert p2;
        
        Product2 p3 = TestUtils.getProduct('ut prod3', 'family');
        p3.Is_Assetizable__c = false;
        p2.Is_Bundle__c = false;
        p3.ProductCode = 'TECH-001';
        insert p3;
        
        VCG_CPQ_Bundle__c comp1 = new VCG_CPQ_Bundle__c();
        comp1.Bundle_Product__c = p1.Id;
        comp1.Bundle_Name__c = 'test bundle';
        comp1.Product__c = p2.Id;
        comp1.Bundle_Split_Type__c = 'Percent';
        comp1.Bundle_Split__c = 25.0;
        insert comp1;
        
        VCG_CPQ_Bundle__c comp2 = new VCG_CPQ_Bundle__c();
        comp2.Bundle_Product__c = p1.Id;
        comp2.Bundle_Name__c = 'test bundle';
        comp2.Product__c = p3.Id;
        comp2.Bundle_Split_Type__c = 'Percent';
        comp2.Bundle_Split__c = 75.0;
        insert comp2;
        
        //oppty.StageName = 'Closed Won';
        //update oppty;
        
        Test.startTest();
        opportunityUtils.isOpportunityTriggerRunning = false;
        oppty.Primary_Quote_Approval_Status__c = 'Approved';
        oppty.Legal_Review__c = 'Approved';
        oppty.Finance_Status__c = 'Approved';
        update oppty;
        
        List<Asset__c> createdAssets = [Select ID, Product__c, ARR__c, Bundle_Product__c from Asset__c where Account__c =: a.id];
        //// System.assertEquals(2, createdAssets.size());
        
        for (Asset__c ast : createdAssets) {
            if (ast.Product__c == p2.id) {
                //// System.assertEquals(25.0, ast.ARR__c);
                //// System.assertEquals(p1.Id, ast.Bundle_Product__c);
            }
            else if (ast.Product__c == p3.id) {
                //// System.assertEquals(75.0, ast.ARR__c);
                //// System.assertEquals(p1.Id, ast.Bundle_Product__c);
            }
        }
        Test.stopTest();
    }

    static testMethod void testComponentAssetUpdate_Renewal(){
        Account a = TestUtils.getAccount('ut1 Acc');
        insert a;

        Contract ctrct = TestUtils.getContract(a);
        insert ctrct;
        
		Product2 p = new product2(name='Test Product');
        insert p;        
        
        Pricebook2 standardPB = [select id from Pricebook2 where isStandard=true];
		PricebookEntry standardPBE = new PricebookEntry(Pricebook2Id = standardPB.Id, Product2Id = p.Id, UnitPrice = 1000, IsActive = true);
    	insert standardPBE;
        
        Pricebook2 stdPb = [select Id from Pricebook2 where NAME = 'Domestic PriceBook'];
        update stdPb;
        
        PricebookEntry spbe =  new PricebookEntry(pricebook2id = stdPb.id, product2id = p.id, unitprice=100.0, isActive=true);
        insert spbe;
        
        Opportunity oppty = TestUtils.getOpportunity(a, 'UT Oppty1');
        oppty.Contract__c = ctrct.id;
        oppty.Type = 'Existing Customer';
        oppty.Order_Type__c = 'Renewal';
        oppty.StageName = 'Sales Acceptance';
        oppty.pricebook2id=stdPb.id;
        insert oppty;
       
        Product2 p0 = TestUtils.getProduct('ut prod0', 'family');
        p0.Is_Assetizable__c = true;
        p0.Is_Bundle__c = true;
        p0.isActive = true;
        insert p0;
        
        OpportunityLineItem oli1 = TestUtils.getOLI(oppty, p0);
        oli1.Line_Type__c = 'Renewal';
        oli1.Annual_Recurring_Revenue__c = 200;
        oli1.pricebookentryid=spbe.Id;
        insert oli1;
        
        Product2 p1 = TestUtils.getProduct('ut prod1', 'family');
        p1.Is_Assetizable__c = false;
        p1.Is_Bundle__c = false;
        p1.Family = 'Test';
        insert p1;
        
        Product2 p2 = TestUtils.getProduct('ut prod2', 'family');
        p2.Is_Assetizable__c = false;
        p2.Is_Bundle__c = false;
        p2.ProductCode = 'TECH-001';
        insert p2;
        
        VCG_CPQ_Bundle__c comp1 = new VCG_CPQ_Bundle__c();
        comp1.Bundle_Product__c = p0.Id;
        comp1.Bundle_Name__c = 'test bundle';
        comp1.Product__c = p1.Id;
        comp1.Bundle_Split_Type__c = 'Percent';
        comp1.Bundle_Split__c = 25.0;
        insert comp1;
        
        VCG_CPQ_Bundle__c comp2 = new VCG_CPQ_Bundle__c();
        comp2.Bundle_Product__c = p0.Id;
        comp2.Bundle_Name__c = 'test bundle';
        comp2.Product__c = p2.Id;
        comp2.Bundle_Split_Type__c = 'Percent';
        comp2.Bundle_Split__c = 75.0;
        insert comp2;
        
        Asset__c ast1 = new Asset__c();
        ast1.Account__c = a.Id;
        ast1.Product__c = p1.Id;
        ast1.ARR__c = 25;
        ast1.Contract__c = ctrct.Id;
        ast1.Bundle_Product__c = p0.Id;
        insert ast1;
        
        Asset__c ast2 = new Asset__c();
        ast2.Account__c = a.Id;
        ast2.Product__c = p2.Id;
        ast2.ARR__c = 75;
        ast2.Contract__c = ctrct.Id;
        ast2.Bundle_Product__c = p0.Id;
        insert ast2;
        
        //oppty.StageName = 'Closed Won';
        //update oppty;
        
        Test.startTest();
        opportunityUtils.isOpportunityTriggerRunning = false;
        oppty.Primary_Quote_Approval_Status__c = 'Approved';
        oppty.Legal_Review__c = 'Approved';
        oppty.Finance_Status__c = 'Approved';
        update oppty;
        
        List<Asset__c> createdAssets = [Select ID, Product__c, Product__r.Name, Product__r.Is_Bundle__c, ARR__c, Bundle_Product__c, OLI_Line_Type__c from Asset__c where Account__c =: a.id];
        
        // System.assertEquals(2, createdAssets.size());
        for (Asset__c ast : createdAssets) {
            if (ast.Product__c == p1.id) {
                // System.assertEquals(50.0, ast.ARR__c);
                // System.assertEquals(p0.Id, ast.Bundle_Product__c);
            }
            else if (ast.Product__c == p2.id) {
                // System.assertEquals(150.0, ast.ARR__c);
                // System.assertEquals(p0.Id, ast.Bundle_Product__c);
            }
        }
        Test.stopTest();
    }
    
    static testMethod void testComponentAssetUpdate_Extension(){
        Account a = TestUtils.getAccount('ut1 Acc');
        insert a;

        Contract ctrct = TestUtils.getContract(a);
        insert ctrct;
       
        
        Product2 p = new product2(name='Test Product');
        insert p;        
        
        Pricebook2 standardPB = [select id from Pricebook2 where isStandard=true];
		PricebookEntry standardPBE = new PricebookEntry(Pricebook2Id = standardPB.Id, Product2Id = p.Id, UnitPrice = 1000, IsActive = true);
    	insert standardPBE;
        
        Pricebook2 stdPb = [select Id from Pricebook2 where NAME = 'Domestic PriceBook'];
        update stdPb;
        
        PricebookEntry spbe =  new PricebookEntry(pricebook2id = stdPb.id, product2id = p.id, unitprice=100.0, isActive=true);
        insert spbe;
        
        
        Opportunity oppty = TestUtils.getOpportunity(a, 'UT Oppty1');
        oppty.Contract__c = ctrct.id;
        oppty.Type = 'Existing Customer';
        oppty.Order_Type__c = 'AddOn';
        oppty.StageName = 'Sales Acceptance';
        oppty.pricebook2id=stdPb.id;
        insert oppty;
        
         
        Product2 p0 = TestUtils.getProduct('ut prod0', 'family');
        p0.Is_Assetizable__c = true;
        p0.Is_Bundle__c = true;
        p0.isActive = true;
        insert p0;
        
        OpportunityLineItem oli1 = TestUtils.getOLI(oppty, p0);
        oli1.Line_Type__c = 'Extension';
        oli1.Annual_Recurring_Revenue__c = 100;
        oli1.License_Metric_Quantity__c = 1;
        oli1.pricebookentryid=spbe.Id;
        insert oli1;
        
        Product2 p1 = TestUtils.getProduct('ut prod1', 'family');
        p1.Is_Assetizable__c = false;
        p1.Is_Bundle__c = false;
        p1.Family = 'Test';
        insert p1;
        
        Product2 p2 = TestUtils.getProduct('ut prod2', 'family');
        p2.Is_Assetizable__c = false;
        p2.Is_Bundle__c = false;
        p2.ProductCode = 'TECH-001';
        insert p2;
        
        VCG_CPQ_Bundle__c comp1 = new VCG_CPQ_Bundle__c();
        comp1.Bundle_Product__c = p0.Id;
        comp1.Bundle_Name__c = 'test bundle';
        comp1.Product__c = p1.Id;
        comp1.Bundle_Split_Type__c = 'Percent';
        comp1.Bundle_Split__c = 25.0;
        insert comp1;
        
        VCG_CPQ_Bundle__c comp2 = new VCG_CPQ_Bundle__c();
        comp2.Bundle_Product__c = p0.Id;
        comp2.Bundle_Name__c = 'test bundle';
        comp2.Product__c = p2.Id;
        comp2.Bundle_Split_Type__c = 'Percent';
        comp2.Bundle_Split__c = 75.0;
        insert comp2;
        
        Asset__c ast1 = new Asset__c();
        ast1.Account__c = a.Id;
        ast1.Product__c = p1.Id;
        ast1.ARR__c = 25;
        ast1.Component_Allocation__c = 25;
        ast1.Contract__c = ctrct.Id;
        ast1.Bundle_Product__c = p0.Id;
        ast1.License_Metric_Quantity__c = 1;
        insert ast1;
        
        Asset__c ast2 = new Asset__c();
        ast2.Account__c = a.Id;
        ast2.Product__c = p2.Id;
        ast2.ARR__c = 75;
        ast2.Component_Allocation__c = 75;
        ast2.Contract__c = ctrct.Id;
        ast2.Bundle_Product__c = p0.Id;
        ast2.License_Metric_Quantity__c = 1;
        insert ast2;
        
        //oppty.StageName = 'Closed Won';
        //update oppty;
        
        Test.startTest();
        opportunityUtils.isOpportunityTriggerRunning = false;
        oppty.Primary_Quote_Approval_Status__c = 'Approved';
        oppty.Legal_Review__c = 'Approved';
        oppty.Finance_Status__c = 'Approved';
        update oppty;
        
        List<Asset__c> createdAssets = [Select ID, Product__c, Product__r.Name, Product__r.Is_Bundle__c, ARR__c, Bundle_Product__c, OLI_Line_Type__c, License_Metric_Quantity__c from Asset__c where Account__c =: a.id];
        
        // System.assertEquals(2, createdAssets.size());
        for (Asset__c ast : createdAssets) {
            if (ast.Product__c == p1.id) {
                // System.assertEquals(50, ast.ARR__c);
                // System.assertEquals(2, ast.License_Metric_Quantity__c);
                // System.assertEquals(p0.Id, ast.Bundle_Product__c);
            }
            else if (ast.Product__c == p2.id) {
                // System.assertEquals(150, ast.ARR__c);
                // System.assertEquals(2, ast.License_Metric_Quantity__c);
                // System.assertEquals(p0.Id, ast.Bundle_Product__c);
            }
        }
        Test.stopTest();
    }
    
    static testMethod void testComponentAssetUpdate_Decommission(){
        Account a = TestUtils.getAccount('ut1 Acc');
        insert a;

        Contract ctrct = TestUtils.getContract(a);
        insert ctrct;
        Product2 p = new product2(name='Test Product');
        insert p;        
        
        Pricebook2 standardPB = [select id from Pricebook2 where isStandard=true];
		PricebookEntry standardPBE = new PricebookEntry(Pricebook2Id = standardPB.Id, Product2Id = p.Id, UnitPrice = 1000, IsActive = true);
    	insert standardPBE;
        
        Pricebook2 stdPb = [select Id from Pricebook2 where NAME = 'Domestic PriceBook'];
        update stdPb;
        
        PricebookEntry spbe =  new PricebookEntry(pricebook2id = stdPb.id, product2id = p.id, unitprice=100.0, isActive=true);
        insert spbe;
        
        Opportunity oppty = TestUtils.getOpportunity(a, 'UT Oppty1');
        oppty.Contract__c = ctrct.id;
        oppty.Type = 'Existing Customer';
        oppty.Order_Type__c = 'Term License';
        oppty.StageName = 'Sales Acceptance';
        oppty.pricebook2id=stdPb.id;
        insert oppty;
        
        Product2 p0 = TestUtils.getProduct('ut prod0', 'family');
        p0.Is_Assetizable__c = true;
        p0.Is_Bundle__c = true;
        p0.isActive = true;
        insert p0;
        
        OpportunityLineItem oli1 = TestUtils.getOLI(oppty, p0);
        oli1.Line_Type__c = 'Decommission';
        oli1.Annual_Recurring_Revenue__c = -100;
        oli1.Decommission_Quantity__c = 1;
        oli1.pricebookentryid=spbe.Id;
        insert oli1;
        
        Product2 p1 = TestUtils.getProduct('ut prod1', 'family');
        p1.Is_Assetizable__c = false;
        p1.Is_Bundle__c = false;
        p1.Family = 'Test';
        insert p1;
        
        Product2 p2 = TestUtils.getProduct('ut prod2', 'family');
        p2.Is_Assetizable__c = false;
        p2.Is_Bundle__c = false;
        p2.ProductCode = 'TECH-001';
        insert p2;
        
        VCG_CPQ_Bundle__c comp1 = new VCG_CPQ_Bundle__c();
        comp1.Bundle_Product__c = p0.Id;
        comp1.Bundle_Name__c = 'test bundle';
        comp1.Product__c = p1.Id;
        comp1.Bundle_Split_Type__c = 'Percent';
        comp1.Bundle_Split__c = 25.0;
        insert comp1;
        
        VCG_CPQ_Bundle__c comp2 = new VCG_CPQ_Bundle__c();
        comp2.Bundle_Product__c = p0.Id;
        comp2.Bundle_Name__c = 'test bundle';
        comp2.Product__c = p2.Id;
        comp2.Bundle_Split_Type__c = 'Percent';
        comp2.Bundle_Split__c = 75.0;
        insert comp2;
        
        Asset__c ast1 = new Asset__c();
        ast1.Account__c = a.Id;
        ast1.Product__c = p1.Id;
        ast1.ARR__c = 25;
        ast1.Component_Allocation__c = 25;
        ast1.Contract__c = ctrct.Id;
        ast1.Bundle_Product__c = p0.Id;
        ast1.License_Metric_Quantity__c = 1;
        insert ast1;
        
        Asset__c ast2 = new Asset__c();
        ast2.Account__c = a.Id;
        ast2.Product__c = p2.Id;
        ast2.ARR__c = 75;
        ast2.Component_Allocation__c = 75;
        ast2.Contract__c = ctrct.Id;
        ast2.Bundle_Product__c = p0.Id;
        ast2.License_Metric_Quantity__c = 1;
        insert ast2;
        
        //oppty.StageName = 'Closed Won';
        //update oppty;
        
        Test.startTest();
        opportunityUtils.isOpportunityTriggerRunning = false;
        oppty.Primary_Quote_Approval_Status__c = 'Approved';
        oppty.Legal_Review__c = 'Approved';
        oppty.Finance_Status__c = 'Approved';
        update oppty;
        
        List<Asset__c> createdAssets = [Select ID, Product__c, Product__r.Name, Product__r.Is_Bundle__c, ARR__c, Bundle_Product__c, OLI_Line_Type__c, License_Metric_Quantity__c, Asset_ARR_at_Decommission__c from Asset__c where Account__c =: a.id];
        
        // System.assertEquals(2, createdAssets.size());
        for (Asset__c ast : createdAssets) {
            if (ast.Product__c == p1.id) {
                // System.assertEquals(25, ast.Asset_ARR_at_Decommission__c);
                // System.assertEquals(0, ast.ARR__c);
                // System.assertEquals(0, ast.License_Metric_Quantity__c);
                // System.assertEquals(p0.Id, ast.Bundle_Product__c);
            }
            else if (ast.Product__c == p2.id) {
                // System.assertEquals(75, ast.Asset_ARR_at_Decommission__c);
                // System.assertEquals(0, ast.ARR__c);
                // System.assertEquals(0, ast.License_Metric_Quantity__c);
                // System.assertEquals(p0.Id, ast.Bundle_Product__c);
            }
        }
        Test.stopTest();
    }

}