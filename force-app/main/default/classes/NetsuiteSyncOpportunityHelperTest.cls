@isTest(SeeAllData=true)
private class NetsuiteSyncOpportunityHelperTest {

    static testMethod void opportunityTest(){        
        
        //Set mock
        Test.setMock(HttpCalloutMock.class, new NetsuiteSyncMockHttpResponseGen());
        //
        Test.startTest();
        
        //Get Account Record Type ID 
        //Id oldCNRrecType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Old CNR Sales').getRecordTypeId();
        
        //Create an account
        Account a = new Account();
        a.RecordTypeId = SystemIds__c.getInstance().RecordTypeId_Account_TLSales__c; 
        a.QWBS_Market__c = 'Mexico Sales';       
        a.QWBS_Status__c = 'Active';
        a.Name = 'NS_Test1';
    //  a.Company_Short_Name__c = 'NS';
        a.Account_Classification__c ='Customer';
        a.BillingStreet = '1st Street';
        a.BillingCity = 'Future';
        a.BillingCountry = 'Mexico';
        a.BillingPostalCode='12345';
        a.BillingState = 'AR';
        a.Ranking__c = 'Regional';
        a.RFC_ID__c = 'RFC11111';
    //  a.District__c = 'Central';
        a.CurrencyIsoCode  = 'USD';
    //  a.Mailing_Street__c = '1st Street';
    //  a.Mailing_City__c = 'Future';
    //  a.Mailing_State_Province__c = 'AR';
    //  a.Mailing_Country__c = 'Mexico';
        a.Primary_Business_Unit__c = 'Omnitracs Mexico';
        insert a;  
        
        
        
        //Account acc= [SELECT Id, Business_Unit__c FROM Account WHERE Send_to_Netsuite__c=true LIMIT 1];
        system.debug('**** Business Unit:' + a.Business_Unit__c );
        
        //Get Opportunity Record Type ID 
        Id oldProdRecType = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Products, Services and Maintenance').getRecordTypeId();
        //Create Opportunity
        Opportunity o=new Opportunity();
        o.RecordTypeId = oldProdRecType; 
        o.Name= 'NS Test';
        o.AccountId = a.Id;
        o.Ranking__c = 'Hot';
        o.CloseDate = date.today();
        o.StageName = 'Sales Acceptance';
        o.Type= 'New Customer';
        o.Order_Type__c = 'New';
        o.CurrencyISOCode = 'USD';
        
        //o.Primary_Quote_Approval_Status__c = 'Approved';
        o.Primary_Quote_Effective_Date__c = date.today();
        o.Negotiation_Type__c = 'Sale';       
        insert o;
        System.debug('*** Opportunitys AccountId:' + o.AccountId);
        
        //Create Product 1
        Product2 p1 = TestUtils.getProduct('ut prod1', 'family');
        p1.Is_Assetizable__c = true; 
        p1.ProductCode = 'TECH-001';       
        insert p1;
        
        Pricebook2 standardPB = [select id from Pricebook2 where isStandard=true];
        PricebookEntry standardPBE = new PricebookEntry(Pricebook2Id = standardPB.Id, Product2Id = p1.Id, UnitPrice = 1000, IsActive = true);
        insert standardPBE;
        
        Pricebook2 stdPb = [select Id from Pricebook2 where NAME = 'Domestic PriceBook'];
        PricebookEntry spbe =  new PricebookEntry(pricebook2id = stdPb.id, product2id = p1.id, unitprice=100.0, isActive=true);
        insert spbe;
        
      
        OpportunityLineItem oli = new OpportunityLineItem(opportunityid=o.id, Line_Type__c = 'New', License_Metric_Quantity__c =3, UnitPrice=100, quantity=1, pricebookentryid=spbe.Id); 
        insert oli;
        
        /*//Create Product 2
        Product2 p2 = TestUtils.getProduct('ut prod2', 'family');
        p2.Is_Assetizable__c = false;
        p2.Family = 'Test';
        p2.ProductCode = 'TECH-001';
        insert p2;
        
        //Create Product 3 
        Product2 p3 = TestUtils.getProduct('ut prod3', 'family');
        p3.Is_Assetizable__c = false;
        p3.ProductCode = 'TECH-001';
        insert p3;
                
        //Create Opp Product 2
        OpportunityLineItem oli2 = TestUtils.getOLI(o, p2);
        oli2.Line_Type__c = 'New';
        oli2.License_Metric_Quantity__c =3;
       // oli1.pricebookentryid=p1.Id;
        insert oli2;*/
        
        System.debug('**** Opportunity:' + o.Primary_Quote_Approval_Status__c  );
        o.Primary_Quote_Approval_Status__c  = 'Approved';
        checkRecursiveAfter.resetRunOnceFlag();
        update o;
      
        test.stopTest();
    } 

}