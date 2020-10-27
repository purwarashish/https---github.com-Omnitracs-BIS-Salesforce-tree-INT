@isTest(SeeAllData=true)
public without sharing class OppDealDeskController_Test {
  
    static testMethod void postiveTestMethodTest(){
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
        oppty.Type_of_Competitor__c='No Competitor';
        insert oppty;
        
        
        ApexPages.StandardController sc = new ApexPages.StandardController(oppty);
        OppDealDeskController testAccPlan = new OppDealDeskController(sc);
        
        PageReference pageRef = Page.NewDealDesk;
        pageRef.getParameters().put('oppId', String.valueOf(oppty.Id));
        
        
        Test.setCurrentPage(pageRef);
        testAccPlan.PrePopulateData();
        
        Test.stopTest(); 
    }
    
    static testMethod void negativeTestMethodTest(){
        Account a = TestUtils.getAccount('ut1 Acc');
        insert a;

        Contract ctrct = TestUtils.getContract(a);
        insert ctrct;
        
        Competitor__c cmp = new Competitor__c ();
        cmp.Name = 'Test Competitor';
        insert cmp;
        
        
        Test.startTest();
        Opportunity oppty = TestUtils.getOpportunity(a, 'UT Oppty1');
        oppty.Contract__c = ctrct.id;
        oppty.accountid=a.id;
        oppty.Type = 'New Customer';
        oppty.Order_Type__c = 'New';
        oppty.StageName = 'Sales Acceptance';
        oppty.Legal_Review__c = '';
        oppty.Finance_Status__c = '';
        oppty.Type_of_Competitor__c='Competitive Takeaway';
        insert oppty;
        
        SBQQ__Quote__c sbQuote = new SBQQ__Quote__c();
        sbQuote.SBQQ__Opportunity2__c = oppty.id;
        sbQuote.SBQQ__Account__c = a.id;
        sbQuote.SBQQ__ExpirationDate__c = Date.today().addDays(11);
        sbQuote.SBQQ__StartDate__c = Date.today().addDays(-11);
        sbQuote.SBQQ__EndDate__c = Date.today().addDays(19);
        sbQuote.SBQQ__Status__c = 'Draft';
        sbQuote.SBQQ__Type__c = 'Quote';
        sbQuote.SBQQ__Primary__c = True;
        insert sbQuote;
        
        Deal_Desk__c dd = new Deal_Desk__c();
        dd.Name='test DD';
        dd.Opportunity_Name__c=oppty.id;
        insert dd;
        
        Revenue__c rr = new Revenue__c();
        rr.Account__c=a.id;
        rr.product_line__c='TT200';
        rr.Net_Revenue__c =12;
        rr.Fiscal_Year__c =2016;
        rr.Fiscal_Period__c=3 ;
        rr.Billed_Units__c=6;
        
        insert rr;
        
        Competitive_Threat__c cIS = new Competitive_Threat__c ();
        cIS.Competitor_Name__c = cmp.id;
        cIS.Account__c = a.id;
        cIS.Competitor_Status__c = 'Other';
        cIS.Product_Solution_Name__c = 'Competitor Product';
        cIS.of_units_At_Risk__c = 600;
        cIS.Competitor_units_Installed__c = 300;
        cIS.Satisfaction_Level__c = 'Satisfied';
        cIS.Expected_Competitor_Contract_Expiration__c = system.today();
        
        insert cIS;
        
        Competitive_Summary__c csm = new Competitive_Summary__c ();
        csm.Opportunity__c = oppty.id;
        csm.Competitive_Intelligence__c = cIS.Id;
        insert csm;
        
        ApexPages.StandardController sc = new ApexPages.StandardController(oppty);
        OppDealDeskController testAccPlan = new OppDealDeskController(sc);
        
        PageReference pageRef = Page.NewDealDesk;
        pageRef.getParameters().put('id', String.valueOf(dd.Id));
        //pageRef.getParameters().put('oppId', String.valueOf(oppty.Id));
        Test.setCurrentPage(pageRef);
        testAccPlan.PrePopulateData();
        testAccPlan.loadFinanceData ();
        testAccPlan.loadCompetitorData ();
        testAccPlan.mostRecentRev=system.today();
        Test.stopTest(); 
    }
    
    static testMethod void MixTestMethodTest(){
        Account a = TestUtils.getAccount('ut1 Acc');
        insert a;

        Contract ctrct = TestUtils.getContract(a);
        ctrct.Contract_Title__c='INTELLIGENT VEHICLE GATEWAY SERVICE SCHEDULE';
        ctrct.Contract_Category_1__c='IVG';
        ctrct.accountid=a.id;
        ctrct.Status='Active';
        ctrct.enddate=system.today();
        ctrct.Agreement_Type__c='Schedule';
        insert ctrct;
        
        Contract ctrct1 = TestUtils.getContract(a);
        ctrct1.Contract_Title__c='Untethered Asset Management Service Schedule';
        ctrct1.Contract_Category_1__c='T2';
        ctrct1.accountid=a.id;
        ctrct1.Status='Active';
        ctrct1.enddate=system.today();
        ctrct1.Agreement_Type__c='Schedule';
        insert ctrct1;
        
        Contract ctrct2 = TestUtils.getContract(a);
        ctrct2.Contract_Title__c='Relay Unit Schedule';
        ctrct2.Contract_Category_1__c='XRS';
        ctrct2.accountid=a.id;
        ctrct2.Status='Active';
        ctrct2.enddate=system.today();
        ctrct2.Agreement_Type__c='Schedule';
        insert ctrct2;
        
        Contract ctrct3 = TestUtils.getContract(a);
        ctrct3.Contract_Title__c='MOBILE COMPUTING PLATFORM 200 SERIES';
        ctrct3.Contract_Category_1__c='MCP200';
        ctrct3.accountid=a.id;
        ctrct3.Status='Active';
        ctrct3.enddate=system.today();
        ctrct3.Agreement_Type__c='Schedule';
        insert ctrct3;
        
        Contract ctrct4 = TestUtils.getContract(a);
        ctrct4.Contract_Title__c='Mobile Computing Platform 100 Series Satellite';
        ctrct4.Contract_Category_1__c='MCP100S';
        ctrct4.accountid=a.id;
        ctrct4.Status='Active';
        ctrct4.enddate=system.today();
        ctrct4.Agreement_Type__c='Schedule';
        insert ctrct4;
        
        
        Contract ctrct5 = TestUtils.getContract(a);
        ctrct5.Contract_Title__c='MOBILE COMPUTING PLATFORM 50 SERIES SERVICE SCHEDULE';
        ctrct5.Contract_Category_1__c='MCP50';
        ctrct5.accountid=a.id;
        ctrct5.Status='Active';
        ctrct5.enddate=system.today();
        ctrct5.Agreement_Type__c='Schedule';
        insert ctrct5;
    
    	Contract ctrct6 = TestUtils.getContract(a);
        ctrct6.Contract_Title__c='Mobile Computing Platform 110 Series Schedule';
        ctrct6.Contract_Category_1__c='MCP110';
        ctrct6.accountid=a.id;
        ctrct6.Status='Active';
        ctrct6.enddate=system.today();
        ctrct6.Agreement_Type__c='Schedule';
        insert ctrct6;
    
    	Contract ctrct7 = TestUtils.getContract(a);
        ctrct7.Contract_Title__c='TRAILER TRACKS 210 SERVICE SCHEDULE';
        ctrct7.Contract_Category_1__c='TT210';
        ctrct7.accountid=a.id;
        ctrct7.Status='Active';
        ctrct7.enddate=system.today();
        ctrct7.Agreement_Type__c='Schedule';
        insert ctrct7;
    
    	Contract ctrct8 = TestUtils.getContract(a);
        ctrct8.Contract_Title__c='OmniVision Terrestrial Service Schedule';
        ctrct8.Contract_Category_1__c='MCP100T';
        ctrct8.accountid=a.id;
        ctrct8.Status='Active';
        ctrct8.enddate=system.today();
        ctrct8.Agreement_Type__c='Schedule';
        insert ctrct8;
    
    	Contract ctrct9 = TestUtils.getContract(a);
        ctrct9.Contract_Title__c='TRAILER TRACKS 150 SERVICE SCHEDULE';
        ctrct9.Contract_Category_1__c='TT150';
        ctrct9.accountid=a.id;
        ctrct9.Status='Active';
        ctrct9.enddate=system.today();
        ctrct9.Agreement_Type__c='Schedule';
        insert ctrct9;
    
    	Contract ctrct10 = TestUtils.getContract(a);
        ctrct10.Contract_Title__c='Software License Schedule';
        ctrct10.Contract_Category_1__c='Dom. SAAS';
        ctrct10.accountid=a.id;
        ctrct10.Status='Active';
        ctrct10.enddate=system.today();
        ctrct10.Agreement_Type__c='Schedule';
        insert ctrct10;
    	
    	Contract ctrct11 = TestUtils.getContract(a);
        ctrct11.Contract_Title__c='Roadnet Telematics Device, Wireless Services, and Software As A Service Schedule (Bundled)';
        ctrct11.Contract_Category_1__c='RN Telematics/SaaS (Lease)';
        ctrct11.accountid=a.id;
        ctrct11.Status='Active';
        ctrct11.enddate=system.today();
        ctrct11.Agreement_Type__c='Schedule';
        insert ctrct11;
    
    	Contract ctrct12 = TestUtils.getContract(a);
        ctrct12.Contract_Title__c='SOFTWARE AS A SERVICE SCHEDULE';
        ctrct12.Contract_Category_1__c='RN SaaS';
        ctrct12.accountid=a.id;
        ctrct12.Status='Active';
        ctrct12.enddate=system.today();
        ctrct12.Agreement_Type__c='Schedule';
        insert ctrct12;
        
        Test.startTest();
        Opportunity oppty = TestUtils.getOpportunity(a, 'UT Oppty1');
        oppty.Contract__c = ctrct.id;
        oppty.accountid=a.id;
        oppty.Type = 'New Customer';
        oppty.Order_Type__c = 'New';
        oppty.StageName = 'Sales Acceptance';
        oppty.Legal_Review__c = '';
        oppty.Finance_Status__c = '';
        //oppty.Type_of_Competitor__c='No Competitor';
        insert oppty;
        
        SBQQ__Quote__c sbQuote = new SBQQ__Quote__c();
        sbQuote.SBQQ__Opportunity2__c = oppty.id;
        sbQuote.SBQQ__Account__c = a.id;
        sbQuote.SBQQ__ExpirationDate__c = Date.today().addDays(11);
        sbQuote.SBQQ__StartDate__c = Date.today().addDays(-11);
        sbQuote.SBQQ__EndDate__c = Date.today().addDays(19);
        sbQuote.SBQQ__Status__c = 'Draft';
        sbQuote.SBQQ__Type__c = 'Quote';
        sbQuote.SBQQ__Primary__c = True;
        insert sbQuote;
        
        Deal_Desk__c dd = new Deal_Desk__c();
        dd.Name='test DD';
        dd.Opportunity_Name__c=oppty.id;
        insert dd;
        
        Revenue__c rr = new Revenue__c();
        rr.Account__c=a.id;
        rr.product_line__c='TT200';
        rr.Net_Revenue__c =12;
        rr.Fiscal_Year__c =2016;
        rr.Fiscal_Period__c=3 ;
        rr.Billed_Units__c=6;
        
        insert rr;
        
        ApexPages.StandardController sc = new ApexPages.StandardController(oppty);
        OppDealDeskController testAccPlan = new OppDealDeskController(sc);
        
        PageReference pageRef = Page.NewDealDesk;
        pageRef.getParameters().put('id', String.valueOf(dd.Id));
        pageRef.getParameters().put('oppId', String.valueOf(oppty.Id));
        Test.setCurrentPage(pageRef);
        testAccPlan.PrePopulateData();
        testAccPlan.loadFinanceData ();
        testAccPlan.loadCompetitorData ();
        testAccPlan.mostRecentRev=system.today();
        Test.stopTest(); 
    }
}