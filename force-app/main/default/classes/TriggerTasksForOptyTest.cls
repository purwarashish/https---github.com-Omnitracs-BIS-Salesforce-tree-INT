@isTest(SeeAllData=true) 
public class TriggerTasksForOptyTest {
    public static VistaAssetHelperUtil util = new VistaAssetHelperUtil();
    static testMethod void myUnitTest() {
        Test.startTest();
        String[] productCodes = new String[]{'DISA-IFTA','HOS - AUTO','GROVE-F-HOS','OCAN-3RDSU','CDN SETUP-BRZ','OV VEHICLE PERFORMANCE','OV CER BASIC','OCAN-WSDW-FEE',
                                             'CDN SETUP-2_5H','IVG-SUB-COMP-B','IVG-SUB-CORE-B','IVG-SUB-EOBR-B','IVG-SUB-PERF-B','IVG-SUB-PREM-B','PS300021','PS300025',
                                             'OV CER BASIC','OV CEV IVG','OV OTNAV','OV COPILOT','OV COPILOT ROUTE'};      
        
        Account acct = new Account(Name = 'Task Test Account 456', Primary_Business_Unit__c = 'Canada', Segment__c = 'TL', Fleet_Size__c = 10, Phone = '(999) 999-9999', BillingStreet = 'Spring Valley', BillingCity = 'Richardson', BillingState = 'TX', BillingPostalCode = '75801', BillingCountry = 'USA');
        insert acct;
        List<Product2> productList = new List<Product2>();
        for(String productCode : productCodes){
            productList.add(new Product2(Name = 'testName', ProductCode = productCode, IsActive = true));
        }
        insert productList;
        
        Id priceBookId = Test.getStandardPricebookId();
        
        List<PricebookEntry> pbeList = new List<PricebookEntry>();
        for(Product2 product : productList){
            pbeList.add(new PricebookEntry(UseStandardPrice = false, Pricebook2Id = priceBookId, UnitPrice = 1.0, IsActive = true, Product2Id = product.Id));
        }
        insert pbeList;
        
        Id ownerId = Id.valueOf(SystemIds__c.getInstance().UserId_Opportunity_Task_Creation__c);
        Opportunity oppty = new Opportunity(Name = 'TestOpp', OwnerId = ownerId, StageName = 'Negotiate',  CloseDate = System.Today(), Pricebook2Id = priceBookId);
        insert oppty;
        Contract contract = util.createContract(oppty, acct, 'Customer - MSA', Date.today());
        SBQQ__Quote__c sbQuote = util.createSBQuote(oppty, acct, Date.today(), true);
        sbQuote.SBQQ__Status__c = 'Signed';
        update sbQuote;
        contract.SBQQ__Quote__c = sbQuote.Id;
        update contract;
            
        List<OpportunityLineItem> testOppLineItemsList = new List<OpportunityLineItem>();
        for(PricebookEntry pbe : pbeList){
            testOppLineItemsList.add(new OpportunityLineItem(OpportunityId = oppty.Id, Quantity = 1.0, TotalPrice = 1.0, PricebookEntryId = pbe.Id));
        }
        insert testOppLineItemsList;
        oppty.SBQQ__PrimaryQuote__c = sbQuote.Id;
        oppty.Contract__c = contract.Id;
        oppty = util.closeWonOpportunity(oppty);
        
        TriggerTasksForOpty.createTasks(new Id[]{oppty.Id});
        
        List<Task> taskList = [select Id from Task where WhatId = :oppty.Id];
        System.assertNotEquals(null, taskList, 'Success');
        Test.stopTest();
    }
    static testMethod void myUnitTest1() {
        Test.startTest();
        String[] productCodes1 = new String[]{'AAD','OV DRIVER WORKFLOW','MIPR 5 TERR','OV QHOS MOBILE','OV ICS','OV EH ICS','OV MMS',
                                             'OV EF','OV TPM','OV ABS','OV VIR','OV DWPC','OV DWA','OV DWPC-ONADD','OV DWPC-ON','WSB-ABC','HOS-AUTO','C-TPAT','GROVE-DVIR','GROVE-F-HOS',
                                             'GROVE-PAY','OV-SDM','OV-SDM-ME','GROVE-SCORE','ELM','DISA-IFTA','OT1-FT'};      
        
        Account acct1 = new Account(Name = 'Task Test Account 4567', Primary_Business_Unit__c = 'Canada', Segment__c = 'TL', Fleet_Size__c = 10, Phone = '(999) 999-9999', BillingStreet = 'Spring Valley', BillingCity = 'Richardson', BillingState = 'TX', BillingPostalCode = '75801', BillingCountry = 'USA');
        insert acct1;
        List<Product2> productList1 = new List<Product2>();
        for(String productCode1 : productCodes1){
            productList1.add(new Product2(Name = 'testName1', ProductCode = productCode1, IsActive = true));
        }
        insert productList1;
        
        Id priceBookId1 = Test.getStandardPricebookId();
        
        List<PricebookEntry> pbeList1 = new List<PricebookEntry>();
        for(Product2 product1 : productList1){
            pbeList1.add(new PricebookEntry(UseStandardPrice = false, Pricebook2Id = priceBookId1, UnitPrice = 1.0, IsActive = true, Product2Id = product1.Id));
        }
        insert pbeList1;
        
        Id ownerId = Id.valueOf(SystemIds__c.getInstance().UserId_Opportunity_Task_Creation__c);
        Opportunity oppty1 = new Opportunity(Name = 'TestOpp1', OwnerId = ownerId, StageName = 'Negotiate',  CloseDate = System.Today(), Pricebook2Id = priceBookId1);
        insert oppty1;
        Contract contract1 = util.createContract(oppty1, acct1, 'Customer - MSA', Date.today());
        SBQQ__Quote__c sbQuote1 = util.createSBQuote(oppty1, acct1, Date.today(), true);
        sbQuote1.SBQQ__Status__c = 'Signed';
        update sbQuote1;
        contract1.SBQQ__Quote__c = sbQuote1.Id;
        update contract1;
            
        List<OpportunityLineItem> testOppLineItemsList1 = new List<OpportunityLineItem>();
        for(PricebookEntry pbe1 : pbeList1){
            testOppLineItemsList1.add(new OpportunityLineItem(OpportunityId = oppty1.Id, Quantity = 1.0, TotalPrice = 1.0, PricebookEntryId = pbe1.Id));
        }
        insert testOppLineItemsList1;
        oppty1.SBQQ__PrimaryQuote__c = sbQuote1.Id;
        oppty1.Contract__c = contract1.Id;
        oppty1 = util.closeWonOpportunity(oppty1);
        
        TriggerTasksForOpty.createTasks(new Id[]{oppty1.Id});
        
        List<Task> taskList1 = [select Id from Task where WhatId = :oppty1.Id];
        System.assertNotEquals(null, taskList1, 'Success');
        Test.stopTest();
    }
}