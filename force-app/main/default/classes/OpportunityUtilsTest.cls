// Arman Shah - October 2018
@isTest
public without sharing class OpportunityUtilsTest {

    @testSetup
    static void SetupData() {
        TestUtils.defineCustomSettings();

        Pricebook2 domesticPricebook = new Pricebook2(
                NAME = 'Domestic PriceBook', IsActive = true
        );
        insert domesticPricebook;
    }

    static testMethod void testApproveOpptyForAssetCreation_NetNewProducts(){
        Account a = TestUtils.getAccount('ut1 Acc');
        insert a;

        Contract ctrct = TestUtils.getContract(a);
        insert ctrct;

        Test.startTest();
        Opportunity oppty = TestUtils.getOpportunity(a, 'UT Oppty1');
        oppty.Contract__c = ctrct.id;
        oppty.Type = 'New Customer';
        oppty.Order_Type__c = 'New';
        oppty.StageName = 'Sales Acceptance';
        oppty.Legal_Review__c = '';
        oppty.Finance_Status__c = '';
        insert oppty;

        Product2 p1 = TestUtils.getProduct('ut prod1', 'family');
        p1.Is_Assetizable__c = true;
        insert p1;

        Pricebook2 standardPB = TestUtils.getStandardPriceBook(); //[select id from Pricebook2 where isStandard=true];
        PricebookEntry standardPBE = new PricebookEntry(Pricebook2Id = standardPB.Id, Product2Id = p1.Id, UnitPrice = 1000, IsActive = true);
        insert standardPBE;

        Pricebook2 stdPb = [select Id from Pricebook2 where NAME = 'Domestic PriceBook'];
        PricebookEntry spbe =  new PricebookEntry(pricebook2id = stdPb.id, product2id = p1.id, unitprice=100.0, isActive=true);
        insert spbe;

        OpportunityLineItem oli1 = new OpportunityLineItem(opportunityid=oppty.id, Line_Type__c = 'New', License_Metric_Quantity__c =3, UnitPrice=100, quantity=1, pricebookentryid=spbe.Id);
        insert oli1;

        /*
        Product2 p2 = TestUtils.getProduct('ut prod2', 'family');
        p2.Is_Assetizable__c = false;
        p2.Family = 'Test';
        insert p2;
        
        Product2 p3 = TestUtils.getProduct('ut prod3', 'family');
        p3.Is_Assetizable__c = false;
        p3.ProductCode = 'TECH-001';
        insert p3;
        
        OpportunityLineItem oli2 = TestUtils.getOLI(oppty, p2);
        //oli2.Product_Type__c = 'Software';
        //oli2.License_Metric_Quantity__c = 2.0;
        oli2.Line_Type__c = 'New';
        insert oli2;
        
        OpportunityLineItem oli3 = TestUtils.getOLI(oppty, p3);
        //oli3.Product_Type__c = 'Prof Serv';
        //oli3.License_Metric_Quantity__c = 2.0;
        oli3.Line_Type__c = 'New';
        insert oli3; */

        //oppty.StageName = 'Closed Won';
        //update oppty;
        Test.stopTest();

        opportunityUtils.isOpportunityTriggerRunning = false;
        oppty.Legal_Review__c = 'Approved';
        oppty.Finance_Status__c = 'Approved';
        update oppty;


        List<Asset__c> createdAssets = [Select ID, Product__c from Asset__c where Account__c =: a.id];
        // System.assertEquals(1, createdAssets.size());
        // System.assertEquals(p1.id, createdAssets[0].Product__c);
    }

    static testMethod void testApproveOpptyForAssetCreation_UpdateAssets_AddOn(){
        Account a = TestUtils.getAccount('ut1 Acc');
        a.Type = 'Customer';
        insert a;

        Contract ctrct = TestUtils.getContract(a);
        insert ctrct;

        Opportunity oppty = TestUtils.getOpportunity(a, 'ut Opp');
        oppty.Contract__c = ctrct.id;
        oppty.Order_Type__c = 'AddOn';
        oppty.Type = 'Existing Customer';
        oppty.StageName = 'Sales Acceptance';
        oppty.Legal_Review__c = '';
        oppty.Finance_Status__c = '';
        oppty.Order_Sub_Type__c = 'Annual Increase';
        insert oppty;

        Product2 p1 = TestUtils.getProduct('ut prod1', 'family');
        p1.Is_Assetizable__c = true;
        insert p1;

        Pricebook2 standardPB = TestUtils.getStandardPriceBook(); //[select id from Pricebook2 where isStandard=true];
        PricebookEntry standardPBE = new PricebookEntry(Pricebook2Id = standardPB.Id, Product2Id = p1.Id, UnitPrice = 1000, IsActive = true);
        insert standardPBE;

        Pricebook2 stdPb = [select Id from Pricebook2 where NAME = 'Domestic PriceBook'];
        PricebookEntry spbe =  new PricebookEntry(pricebook2id = stdPb.id, product2id = p1.id, unitprice=100.0, isActive=true);
        insert spbe;

        Asset__c ast = TestUtils.getAsset(a, p1);
        ast.ARR__c = 200;
        //ast.Purchase_Date__c = Date.Today();
        //ast.Quantity__c = 1;
        ast.License_Metric_Quantity__c = 50;
        ast.Term_Start_Date__c = Date.Today();
        ast.Term_End_Date__c = Date.Today()+364;
        ast.Contract__c = ctrct.id;
        ast.Non_Recurring_Revenue__c = 10;
        insert ast;

        OpportunityLineItem oli1 = new OpportunityLineItem(opportunityid=oppty.id, Line_Type__c = 'New', License_Metric_Quantity__c =3,
                UnitPrice=100, quantity=1, pricebookentryid=spbe.Id);

        oli1.Annual_Recurring_Revenue__c = 50;
        oli1.License_Metric_Quantity__c = 10;
        oli1.Asset__c = ast.id;
        //oli1.Product_Type__c = 'Software';
        oli1.Line_Type__c = 'Extension';
        oli1.Non_Recurring_Revenue__c = 10;
        insert oli1;

        //oppty.StageName = 'Closed Won';
        //update oppty;

        Test.startTest();
        opportunityUtils.isOpportunityTriggerRunning = false;
        oppty.Primary_Quote_Approval_Status__c = 'Approved';
        oppty.Legal_Review__c = 'Approved';
    //  oppty.Status__c = 'Approved';
        oppty.StageName = 'Sales Complete';
        oppty.Finance_Status__c = 'Approved';
        oppty.Order_Sub_Type__c = 'Annual Increase';
        update oppty;

        Test.stopTest();

        //Asset__c updatedAsset = [Select ID, Product__c, ARR__c, Previous_Annual_Maintenance__c, License_Metric_Quantity__c
        //  from Asset__c where Account__c =: a.id];
        // System.assertEquals(p1.id, updatedAsset.Product__c);
        // System.assertEquals(250, updatedAsset.ARR__c);
        // System.assertEquals(60, updatedAsset.License_Metric_Quantity__c);
    }

    static testMethod void testApproveOpptyForAssetCreation_UpdateAssets_Migration(){
        Account a = TestUtils.getAccount('ut1 Acc');
        a.Type = 'Customer';
        insert a;

        Contract ctrct = TestUtils.getContract(a);
        insert ctrct;

        Opportunity oppty = TestUtils.getOpportunity(a, 'ut Opp');
        oppty.Contract__c = ctrct.id;
        oppty.Order_Type__c = 'AddOn';
        oppty.Type = 'Existing Customer';
        oppty.StageName = 'Sales Acceptance';
        oppty.Legal_Review__c = '';
        oppty.Finance_Status__c = '';
        oppty.Order_Sub_Type__c = 'Annual Increase';
        insert oppty;

        Product2 p1 = TestUtils.getProduct('ut prod1', 'family');
        p1.Is_Assetizable__c = true;
        insert p1;

        Pricebook2 standardPB = TestUtils.getStandardPriceBook();  //[select id from Pricebook2 where isStandard=true];
        PricebookEntry standardPBE = new PricebookEntry(Pricebook2Id = standardPB.Id, Product2Id = p1.Id, UnitPrice = 1000, IsActive = true);
        insert standardPBE;

        Pricebook2 stdPb = [select Id from Pricebook2 where NAME = 'Domestic PriceBook'];
        PricebookEntry spbe =  new PricebookEntry(pricebook2id = stdPb.id, product2id = p1.id, unitprice=100.0, isActive=true);
        insert spbe;

        Asset__c ast = TestUtils.getAsset(a, p1);
        ast.ARR__c = 200;
        //ast.Purchase_Date__c = Date.Today();
        //ast.Quantity__c = 1;
        ast.License_Metric_Quantity__c = 50;
        ast.Term_Start_Date__c = Date.Today();
        ast.Term_End_Date__c = Date.Today()+364;
        ast.Contract__c = ctrct.id;
        ast.Non_Recurring_Revenue__c = 10;
        insert ast;

        OpportunityLineItem oli1 = new OpportunityLineItem(opportunityid=oppty.id, Line_Type__c = 'New', License_Metric_Quantity__c =3, UnitPrice=100, quantity=1, pricebookentryid=spbe.Id);
        oli1.Annual_Recurring_Revenue__c = 50;
        oli1.License_Metric_Quantity__c = 10;
        oli1.Asset__c = ast.id;
        //oli1.Product_Type__c = 'Software';
        oli1.Line_Type__c = 'Migration';
        oli1.Non_Recurring_Revenue__c = 10;
        insert oli1;

        //oppty.StageName = 'Closed Won';
        //update oppty;

        Test.startTest();
        opportunityUtils.isOpportunityTriggerRunning = false;
        oppty.Primary_Quote_Approval_Status__c = 'Approved';
        oppty.Legal_Review__c = 'Approved';
     // oppty.Status__c = 'Approved';
        oppty.StageName = 'Sales Complete';
        oppty.Finance_Status__c = 'Approved';
        update oppty;

        Test.stopTest();

        Asset__c updatedAsset = [Select ID, Product__c, ARR__c, Previous_Annual_Maintenance__c, License_Metric_Quantity__c from Asset__c where Account__c =: a.id];
        // System.assertEquals(p1.id, updatedAsset.Product__c);
        // System.assertEquals(250, updatedAsset.ARR__c);
        // System.assertEquals(60, updatedAsset.License_Metric_Quantity__c);
    }

    static testMethod void testApproveOpptyForAssetCreation_UpdateProducts_Maintenance_Renewal_Oppty(){
        Account a = TestUtils.getAccount('ut1 Acc');
        a.Type = 'Customer';
        insert a;

        Contract ctrct = TestUtils.getContract(a);
        insert ctrct;

        Opportunity oppty = TestUtils.getOpportunity(a, 'ut Opp');
        oppty.Contract__c = ctrct.id;
        oppty.Order_Type__c = 'Renewal';
        oppty.Type = 'Existing Customer';
        oppty.StageName = 'Sales Acceptance';
        oppty.Legal_Review__c = '';
        oppty.Finance_Status__c = '';
        oppty.Order_Sub_Type__c = 'Annual Increase';
        insert oppty;

        Product2 p1 = TestUtils.getProduct('ut prod1', 'family');
        p1.Is_Assetizable__c = true;
        insert p1;

        Pricebook2 standardPB = TestUtils.getStandardPriceBook(); //[select id from Pricebook2 where isStandard=true];
        PricebookEntry standardPBE = new PricebookEntry(Pricebook2Id = standardPB.Id, Product2Id = p1.Id, UnitPrice = 1000, IsActive = true);
        insert standardPBE;

        Pricebook2 stdPb = [select Id from Pricebook2 where NAME = 'Domestic PriceBook'];
        PricebookEntry spbe =  new PricebookEntry(pricebook2id = stdPb.id, product2id = p1.id, unitprice=100.0, isActive=true);
        insert spbe;


        Asset__c ast = TestUtils.getAsset(a, p1);
        ast.ARR__c = 10;
        //ast.Purchase_Date__c = Date.Today();
        //ast.Quantity__c = 1;
        ast.License_Metric_Quantity__c = 50;
        ast.Term_Start_Date__c = Date.Today();
        ast.Term_End_Date__c = Date.Today()+364;
        ast.Contract__c = ctrct.id;
        insert ast;

        OpportunityLineItem oli1 = new OpportunityLineItem(opportunityid=oppty.id, Line_Type__c = 'New', License_Metric_Quantity__c =3, UnitPrice=100, quantity=1, pricebookentryid=spbe.Id);
        oli1.ARR_Term_Begin_Date__c = Date.Today();
        oli1.ARR_Term_End_Date__c = Date.Today().addYears(2);
        oli1.Annual_Recurring_Revenue__c = 20;
        oli1.Asset__c = ast.id;
        oli1.License_Metric_Quantity__c = 10;
        oli1.Line_Type__c = 'Renewal';
        insert oli1;

        //oppty.StageName = 'Closed Won';
        //update oppty;

        Test.startTest();
        oppty.Primary_Quote_Approval_Status__c = 'Approved';
        oppty.Legal_Review__c = 'Approved';
        update oppty;

        opportunityUtils.isOpportunityTriggerRunning = false;
        oppty.Finance_Status__c = 'Approved';
        update oppty;
        Test.stopTest();

        Asset__c updatedAsset = [Select ID, Product__c, Asset_Term_Start_Date__c, Asset_Term_End_Date__c, Maintenance_Status__c,
                ARR__c, Previous_Annual_Maintenance__c, License_Metric_Quantity__c
        from Asset__c where Account__c =: a.id];

        // System.assertEquals(p1.id, updatedAsset.Product__c);
        // System.assertEquals(oli1.ARR_Term_Begin_Date__c, updatedAsset.Asset_Term_Start_Date__c);
        // System.assertEquals(oli1.ARR_Term_End_Date__c, updatedAsset.Asset_Term_End_Date__c);
        // System.assertEquals('On Maintenance', updatedAsset.Maintenance_Status__c);
        // System.assertEquals(20, updatedAsset.ARR__c);
        // System.assertEquals(10, updatedAsset.Previous_Annual_Maintenance__c);
        // System.assertEquals(10, updatedAsset.License_Metric_Quantity__c);
    }

    static testMethod void testApproveOpptyForAssetCreation_UpdateProducts_Maintenance_Renewal_Decommissioned_Oppty(){
        Account a = TestUtils.getAccount('ut1 Acc');
        a.Type = 'Customer';
        insert a;

        Contract ctrct = TestUtils.getContract(a);
        insert ctrct;

        Opportunity oppty = TestUtils.getOpportunity(a, 'ut Opp');
        oppty.Contract__c = ctrct.id;
        oppty.Order_Type__c = 'Decommission';
        oppty.Type = 'Existing Customer';
        oppty.StageName = 'Sales Acceptance';
        oppty.Legal_Review__c = '';
        oppty.Finance_Status__c = '';
        oppty.Order_Sub_Type__c = 'Annual Increase';
        insert oppty;

        Product2 p1 = TestUtils.getProduct('ut prod1', 'family');
        p1.Is_Assetizable__c = true;
        insert p1;

        Pricebook2 standardPB = TestUtils.getStandardPriceBook(); //[select id from Pricebook2 where isStandard=true];
        PricebookEntry standardPBE = new PricebookEntry(Pricebook2Id = standardPB.Id, Product2Id = p1.Id, UnitPrice = 1000, IsActive = true);
        insert standardPBE;

        Pricebook2 stdPb = [select Id from Pricebook2 where NAME = 'Domestic PriceBook'];
        PricebookEntry spbe =  new PricebookEntry(pricebook2id = stdPb.id, product2id = p1.id, unitprice=100.0, isActive=true);
        insert spbe;

        Asset__c ast = TestUtils.getAsset(a, p1);
        ast.ARR__c = 200;
        //ast.Purchase_Date__c = Date.Today();
        //ast.Quantity__c = 1;
        ast.License_Metric_Quantity__c = 50;
        ast.Term_Start_Date__c = Date.Today();
        ast.Term_End_Date__c = Date.Today()+364;
        ast.Contract__c = ctrct.id;
        ast.Non_Recurring_Revenue__c = 10;
        insert ast;

        OpportunityLineItem oli1 = new OpportunityLineItem(opportunityid=oppty.id, Line_Type__c = 'New', License_Metric_Quantity__c =3, UnitPrice=100, quantity=1, pricebookentryid=spbe.Id);
        oli1.Annual_Recurring_Revenue__c = -200;
        oli1.License_Metric_Quantity__c = 50;
        oli1.Decommission_Quantity__c = 50;
        oli1.Asset__c = ast.id;
        //oli1.Product_Type__c = 'Software';
        oli1.Line_Type__c = 'Decommission';
        oli1.Non_Recurring_Revenue__c = 10;
        oli1.Cancellation_Type__c = 'Cancellation';
        insert oli1;

        //oppty.StageName = 'Closed Won';
        //update oppty;

        Test.startTest();
        opportunityUtils.isOpportunityTriggerRunning = false;
        oppty.Primary_Quote_Approval_Status__c = 'Approved';
        oppty.Legal_Review__c = 'Approved';
     // oppty.Status__c = 'Approved';
        oppty.StageName = 'Sales Complete';
        oppty.Finance_Status__c = 'Approved';
        update oppty;

        Test.stopTest();

        Asset__c updatedAsset = [Select ID, Product__c, ARR__c, Previous_Annual_Maintenance__c, License_Metric_Quantity__c from Asset__c where Account__c =: a.id];
        // System.assertEquals(p1.id, updatedAsset.Product__c);
        // System.assertEquals(200, updatedAsset.Previous_Annual_Maintenance__c);
        // System.assertEquals(0, updatedAsset.ARR__c);
        // System.assertEquals(0, updatedAsset.License_Metric_Quantity__c);
    }

    /*
     *  @author:        Mark De Chavez 
     *  @description:   this tests the updating of the field SP_Products
     *  @date-created:  September 16, 2014
     */
    static testMethod void updateSpProductTest(){
        Account a = TestUtils.getAccount('ut1 Acc');
        a.Type = 'Customer';
        insert a;

        Opportunity oppty = new Opportunity();
        oppty.AccountID = a.id;
        oppty.Name = 'ut Opp';
        oppty.StageName = 'Sales Acceptance';
        oppty.CloseDate = Date.Today().addMonths(2);
        oppty.Finance_Status__c = 'Not Approved';
        oppty.Order_Type__c = 'Renewal';
        oppty.Type = 'Existing Customer';
        oppty.Order_Sub_Type__c = 'Annual Increase';

        Contact c = TestUtils.getContact(a);
        insert c;

        oppty.Contact__c = c.id;
        oppty.Primary_Contact__c = c.id;
        oppty.Role__c = 'Sponsor';

        Contract cntrct = TestUtils.getContract(a);
        insert cntrct;
        oppty.Contract__c = cntrct.id;

        insert oppty;

        Product2 p2 = TestUtils.getProduct('ut prod2', 'Omnitracs');
        p2.Standard_Cost__c = 1;
        p2.ProductCode = 'OMNI';
        insert p2;

        Product2 p1 = TestUtils.getProduct('ut prod1', 'Sylectus');
        p1.Standard_Cost__c = 1;
        p1.ProductCode = 'SYL';
        insert p1;

        Pricebook2 standardPB = TestUtils.getStandardPriceBook(); //[select id from Pricebook2 where isStandard=true];
        PricebookEntry standardPBE = new PricebookEntry(Pricebook2Id = standardPB.Id, Product2Id = p1.Id, UnitPrice = 1000, IsActive = true);
        insert standardPBE;

        Pricebook2 stdPb = [select Id from Pricebook2 where NAME = 'Domestic PriceBook'];
        PricebookEntry spbe =  new PricebookEntry(pricebook2id = stdPb.id, product2id = p1.id, unitprice=100.0, isActive=true);
        insert spbe;


        OpportunityLineItem oli1 = new OpportunityLineItem(opportunityid=oppty.id, Line_Type__c = 'New', License_Metric_Quantity__c =3, UnitPrice=100, quantity=1, pricebookentryid=spbe.Id);
        insert oli1;

        //OpportunityLineItem oli2 = TestUtils.getOLI(oppty, p2);
        //insert oli2; 

      //  Opportunity oppCheck = [SELECT Id, SP_Products__c FROM Opportunity WHERE Id =: oppty.Id];
        // System.assertNotEquals(oppCheck.Id, null);
        // System.assertEquals('OMNI;SYL', oppCheck.SP_Products__c);


    }
    private static testMethod void testForupdateOpptAmountMcAndupdateCampaignTvwoField()
    {
        Savepoint sp = Database.setSavepoint();
        Account testAccount = RoadnetUnitTests.createTestAccount(null);
        Opportunity testOppt = TestUtils.getOpportunity(testAccount, 'josephtestaccount' + date.today());
        testOppt.CampaignId = RoadnetUnitTests.createTestCampaign().id;
        insert testOppt;

        List<Opportunity> oppts = new List<Opportunity>();
        oppts.add(testOppt);
        OpportunityUtils.updateOpptAmountMc(oppts);
        OpportunityUtils.updateCampaignTvwoField(oppts, oppts, false);
        OpportunityUtils.updateCampaignTvwoField(oppts, oppts, true);
        OpportunityUtils.updateCampaignTvwoField(null, oppts, false);

        Database.rollback(sp);

    }

    private static testMethod void testRollupDecommissionFinancials() {
        Account a = TestUtils.getAccount('ut1 Acc');
        a.Type = 'Customer';
        insert a;

        Contract ctrct = TestUtils.getContract(a);
        insert ctrct;

        Opportunity oppty = TestUtils.getOpportunity(a, 'Parent Opp');
        oppty.Contract__c = ctrct.id;
        oppty.Order_Type__c = 'AddOn';
        oppty.Type = 'Existing Customer';
        oppty.StageName = 'Sales Acceptance';
        oppty.Legal_Review__c = '';
        oppty.Finance_Status__c = '';
        oppty.Order_Sub_Type__c = 'Annual Increase';
        insert oppty;

        Opportunity oppty2 = TestUtils.getOpportunity(a, 'Child Opp');
        oppty2.Contract__c = ctrct.id;
        oppty2.Order_Type__c = 'AddOn';
        oppty2.Type = 'Existing Customer';
        oppty2.StageName = 'Sales Acceptance';
        oppty2.Legal_Review__c = '';
        oppty2.Finance_Status__c = '';
        oppty2.Order_Sub_Type__c = 'Annual Increase';
        oppty2.related_parent_opportunity__c = oppty.Id;
        insert oppty2;

        List<Opportunity> decomOpps = new List<Opportunity>();
        decomOpps.add(oppty);

        Test.startTest();
        Boolean isTriggerRunning = OpportunityUtils.isOpportunityTriggerRunning;
        OpportunityUtils.rollupDecommissionFinancials(decomOpps);
        Test.stopTest();

        System.assertEquals(false, isTriggerRunning);
    }

    private static testMethod void testCheckForPrimaryContactRolesIfStageNegotiateLost() {
        String accountShippingCountry = 'Canada';
        String accountBillingCountry = 'Canada';
        Account a = TestUtils.getAccount('ut1 Acc');
        a.Type = 'Customer';
        a.Primary_Business_Unit__c = 'Roadnet';
        a.ShippingCountry = accountShippingCountry;
        a.BillingCountry = accountBillingCountry;
        insert a;

        Contract ctrct = TestUtils.getContract(a);
        insert ctrct;

        User cUser = [SELECT Id, Business_Unit__c FROM User WHERE Id =: UserInfo.getUserId() LIMIT 1];
        cUser.Business_Unit__c = 'Roadnet';
        update cUser;
        cUser = [SELECT Id, Business_Unit__c FROM User WHERE Id =: UserInfo.getUserId() LIMIT 1]; // Re-query

        Opportunity oppty = TestUtils.getOpportunity(a, 'Parent Opp');
        oppty.Contract__c = ctrct.id;
        oppty.Order_Type__c = 'AddOn';
        oppty.Order_Sub_Type__c = 'Annual Increase';
        oppty.Type = 'Existing Customer';
        oppty.StageName = 'Sales Acceptance';
        oppty.Legal_Review__c = '';
        oppty.Finance_Status__c = '';
        oppty.Primary_Contact__c = null;
        oppty.Role__c = null;
        oppty.Owner = cUser;
        //oppty.Owner_Business_Unit__c = 'Roadnet';
        insert oppty;
        System.debug('-- oppty = '+oppty);

        List<Opportunity> newOpps = new List<Opportunity>();
        newOpps.add(oppty);

        Test.startTest();
        OpportunityUtils.checkForPrimaryContactRolesIfStageNegotiateLost(newOpps, true);
        Test.stopTest();
    }

    private static testMethod void testIsOpptDomestic() {
        String accountShippingCountry = 'Canada';
        String accountBillingCountry = 'Canada';

        Test.startTest();

        Boolean isDomestic = OpportunityUtils.isOpptDomestic(null, null);
        System.assertEquals(false, isDomestic);

        isDomestic = OpportunityUtils.isOpptDomestic(accountShippingCountry, null);
        System.assertEquals(false, isDomestic);

        isDomestic = OpportunityUtils.isOpptDomestic(null, accountBillingCountry);
        System.assertEquals(false, isDomestic);

        Test.stopTest();
    }

    private static testMethod void testIsAnyContactRolePrimary() {
        Account a = TestUtils.getAccount('ut1 Acc');
        a.Type = 'Customer';
        insert a;

        Contact con = TestUtils.getContact(a);
        insert con;

        Contract ctrct = TestUtils.getContract(a);
        insert ctrct;

        Opportunity oppty = TestUtils.getOpportunity(a, 'Parent Opp');
        oppty.Contract__c = ctrct.id;
        insert oppty;

        OpportunityContactRole ocr =
                new OpportunityContactRole(OpportunityId=oppty.Id, ContactId=con.Id, isPrimary=true);
        insert ocr;
        List<OpportunityContactRole> ocRoles = new List<OpportunityContactRole>();
        ocRoles.add(ocr);

        Test.startTest();
        Boolean isCRPrimary = OpportunityUtils.isAnyContactRolePrimary(oppty.Id, ocRoles);
        Test.stopTest();

        System.assertEquals(true, isCRPrimary);
    }

    private static testMethod void testCloningValidation() {
        Account a = TestUtils.getAccount('ut1 Acc');
        a.Type = 'Customer';
        insert a;

        Opportunity oppty = TestUtils.getOpportunity(a, 'Parent Opp');
     // oppty.Terms_Requested_Status__c = '';
     // oppty.Se_Approval__c = true;
        oppty.current_se__c = UserInfo.getUserId();
        insert oppty;

        List<Opportunity> opps = new List<Opportunity>();
        opps.add(oppty);

        Test.startTest();
        OpportunityUtils.CloningValidation(opps);
        Test.stopTest();
    }

    private static testMethod void testUpdateContactsUsingSaveResultAndSendErrorEmailIfNeeded() {
        Account a = TestUtils.getAccount('ut1 Acc');
        a.Type = 'Customer';
        insert a;

        Contact con = TestUtils.getContact(a);
        con.Email = 'test123@abc.com';

        List<Contact> contacts = new List<Contact>();
        contacts.add(con);

        Test.startTest();
        OpportunityUtils.updateContactsUsingSaveResultAndSendErrorEmailIfNeeded(contacts);
        Test.stopTest();
    }

   /* private static testMethod void testAssignGeoRegionAndOpptCountryIfNeeded() {
        Account a = TestUtils.getAccount('ut1 Acc');
        a.Type = 'Customer';
        insert a;

        Opportunity oppty = TestUtils.getOpportunity(a, 'Parent Opp');
        oppty.Opporunity_Country__c = 'Canada';
        insert oppty;

        List<Opportunity> opps = new List<Opportunity>();
        opps.add(oppty);

        Test.startTest();
        OpportunityUtils.assignGeoRegionAndOpptCountryIfNeeded(opps);
        Test.stopTest();
    }*/

    private static testMethod void testIsOpptStageLost() {
        Test.startTest();
        Boolean val = OpportunityUtils.isOpptStageLost('Closed Lost');
        Test.stopTest();

        System.assertEquals(true, val);
    }

    private static testMethod void testCheckIfClosedOppheckIfClosedOpp() {
        Account a = TestUtils.getAccount('ut1 Acc');
        a.Type = 'Customer';
        insert a;

        Opportunity oppty = TestUtils.getOpportunity(a, 'Parent Opp');
     // oppty.Opporunity_Country__c = 'Canada';
        insert oppty;

        //listOfClosedStage.addAll(Global_Variable__c.getInstance('Closed Opportunity Stage').value__c.split(';'));
        Global_Variable__c gv = new Global_Variable__c();
        gv.Name = 'Closed Opportunity Stage';
        gv.Value__c = 'Closed Lost';
        insert gv;

        Test.startTest();
        Boolean val = OpportunityUtils.checkIfClosedOpp(oppty);
        Test.stopTest();

        System.assertEquals(false, val);
    }

    // areAllOpptsOfAccountLost
    private static testMethod void testAreAllOpptsOfAccountLost() {
        Account a = TestUtils.getAccount('ut1 Acc');
        a.Type = 'Customer';
        insert a;

        Opportunity oppty = TestUtils.getOpportunity(a, 'Parent Opp');
     // oppty.Opporunity_Country__c = 'Canada';
        oppty.stageName = 'Closed Lost';
        oppty.lost_to_competition__c = 'no';
        oppty.Reason_Lost_Comments__c = 'Not good';
        insert oppty;

        Test.startTest();
        Boolean val = OpportunityUtils.areAllOpptsOfAccountLost(a.Id);
        Test.stopTest();

        System.assertEquals(true, val);
    }

    // revertStageReversal
    private static testMethod void testRevertStageReversal() {
        Account a = TestUtils.getAccount('ut1 Acc');
        a.Type = 'Customer';
        insert a;
               
        
        Opportunity oppty = TestUtils.getOpportunity(a, 'Parent Opp');
     // oppty.Opporunity_Country__c = 'Canada';
        oppty.stageName = 'Closed Lost';
        oppty.Reason_Lost_Comments__c = 'Not good';
        oppty.lost_to_competition__c = 'no';
        oppty.Stage_Before_Reversal__c = 'Sales Acceptance';
        insert oppty;       
        
        
        List<Id> oppIds = new List<Id>();
        oppIds.add(oppty.Id);
        
     // oppty.Opporunity_Country__c = 'US';
        update oppty;
        
        Map<Id,Opportunity> oldMap = new Map<Id,Opportunity>();
        oldMap.put(oppty.id, oppty);
        
        Map<Id,Opportunity> newMap = new Map<Id,Opportunity>();
        newMap.put(oppty.id, oppty);

        Test.startTest();
        OpportunityUtils.revertStageReversal(oppIds);
        OpportunityUtils.UnlockOpportunities(oppIds);
        OpportunityUtils.SPValidation(newMap, oldMap,1);
        Boolean objProfile = OpportunityUtils.isUserProfileSalesSysAdminOrSalesDomManager;
        Test.stopTest();
    }


}