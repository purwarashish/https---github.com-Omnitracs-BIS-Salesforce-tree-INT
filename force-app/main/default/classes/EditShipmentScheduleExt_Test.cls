/*
 *  @author:        Mark De Chavez | mark.dechavez@cloudsherpas.com
 *  @description:   Test class for EditShipmentScheduleExt.
 *  @date-created:  September 09, 2014
 *  @revision: 
 */

@isTest(SeeAllData=True)
public class EditShipmentScheduleExt_Test {
    
    static testMethod void dataDisplayTest(){
        Account acc = new Account(Name='TestAcc', Phone='838-77-03', 
                                  Account_Type__c='Association', /*District__c='Canada',*/ 
                                  QWBS_Market__c='T&L', QWBS_Status__c='Active Prospect');
        insert acc;
       
        Opportunity opp = new Opportunity(Name='TestOpp', AccountId = acc.Id, 
                                          CloseDate=date.today(), StageName='Sales Acceptance');
        insert opp;
        
        VCG_CPQ_Quote__c quote = new VCG_CPQ_Quote__c(Account__c=acc.Id, Opportunity__c = opp.Id, 
                                                      Effective_Date__c = date.today(), Contract_Term__c=5);
        insert quote;
        
        VCG_CPQ_Quote_Product__c quoteProd = new VCG_CPQ_Quote_Product__c(Quote__c=quote.Id, License_Metric_Quantity__c=1);
        insert quoteProd;
        
        Test.startTest();
            Test.setCurrentPage(Page.EditShipmentSchedule);
            EditShipmentScheduleExt controller = new EditShipmentScheduleExt(new ApexPages.StandardController(quoteProd));          
        Test.stopTest();
        
        System.assert(controller.quoteProd.Id == quoteProd.Id);
        System.assert(controller.quoteProd.Quantity__c == quoteProd.Quantity__c);        
    }
    
    static testMethod void addRowTest(){
        Account acc = new Account(Name='TestAcc', Phone='838-77-03', 
                                  Account_Type__c='Association', /*District__c='Canada',*/ 
                                  QWBS_Market__c='T&L', QWBS_Status__c='Active Prospect');
        insert acc;
       
        Opportunity opp = new Opportunity(Name='TestOpp', AccountId = acc.Id, 
                                          CloseDate=date.today(), StageName='Sales Acceptance');
        insert opp;
        
        VCG_CPQ_Quote__c quote = new VCG_CPQ_Quote__c(Account__c=acc.Id, Opportunity__c = opp.Id, 
                                                      Effective_Date__c = date.today(), Contract_Term__c=5);
        insert quote;
        
        VCG_CPQ_Quote_Product__c quoteProd = new VCG_CPQ_Quote_Product__c(Quote__c=quote.Id, License_Metric_Quantity__c=1);
        insert quoteProd;
        
        Test.startTest();
            Test.setCurrentPage(Page.EditShipmentSchedule);
            EditShipmentScheduleExt controller = new EditShipmentScheduleExt(new ApexPages.StandardController(quoteProd));
            controller.addRow();
            System.assertEquals(2, controller.dispShipmentSched.size());
            controller.addRow();
            System.assertEquals(3, controller.dispShipmentSched.size());
        Test.stopTest();                
    }
    
    static testMethod void deleteRowTest(){
        Account acc = new Account(Name='TestAcc', Phone='838-77-03', 
                                  Account_Type__c='Association', /*District__c='Canada',*/ 
                                  QWBS_Market__c='T&L', QWBS_Status__c='Active Prospect');
        insert acc;
       
        Opportunity opp = new Opportunity(Name='TestOpp', AccountId = acc.Id, 
                                          CloseDate=date.today(), StageName='Sales Acceptance');
        insert opp;
        
        VCG_CPQ_Quote__c quote = new VCG_CPQ_Quote__c(Account__c=acc.Id, Opportunity__c = opp.Id, 
                                                      Effective_Date__c = date.today(), Contract_Term__c=5);
        insert quote;
        
        VCG_CPQ_Quote_Product__c quoteProd = new VCG_CPQ_Quote_Product__c(Quote__c=quote.Id, License_Metric_Quantity__c=1);
        insert quoteProd;
        
        Test.startTest();
            Test.setCurrentPage(Page.EditShipmentSchedule);
            EditShipmentScheduleExt controller = new EditShipmentScheduleExt(new ApexPages.StandardController(quoteProd));
            controller.addRow();
            System.assert(controller.dispShipmentSched.size()==2);
            System.currentPageReference().getParameters().put('rowIndex', '1');
            controller.deleteShipmentSched();
            System.assert(controller.dispShipmentSched.size()==1);
        Test.stopTest();                
    }
    
    static testMethod void savedTest(){
        Account acc = new Account(Name='TestAcc', Phone='838-77-03', 
                                  Account_Type__c='Association', /*District__c='Canada',*/ 
                                  QWBS_Market__c='T&L', QWBS_Status__c='Active Prospect');
        insert acc;
       
        Opportunity opp = new Opportunity(Name='TestOpp', AccountId = acc.Id, 
                                          CloseDate=date.today(), StageName='Sales Acceptance');
        insert opp;
        
        VCG_CPQ_Quote__c quote = new VCG_CPQ_Quote__c(Account__c=acc.Id, Opportunity__c = opp.Id, 
                                                      Effective_Date__c = date.today(), Contract_Term__c=5);
        insert quote;
        
        VCG_CPQ_Quote_Product__c quoteProd = new VCG_CPQ_Quote_Product__c(Quote__c=quote.Id, License_Metric_Quantity__c=15);
        insert quoteProd;
        
        Test.startTest();
            Test.setCurrentPage(Page.EditShipmentSchedule);
            EditShipmentScheduleExt controller = new EditShipmentScheduleExt(new ApexPages.StandardController(quoteProd));
            controller.addRow();
            controller.dispShipmentSched[0].Shipment_Date__c = Date.today();
            controller.dispShipmentSched[0].Shipment_Quantity__c = 5;
            controller.dispShipmentSched[0].Notes__c = 'test shipment sched';
            controller.dispShipmentSched[1].Shipment_Date__c = Date.today();
            controller.dispShipmentSched[1].Shipment_Quantity__c = 10;
            controller.dispShipmentSched[1].Notes__c = 'test shipment sched2';
            controller.saveShipmentSched();
        Test.stopTest();                
        
        List<Shipment_Forecast__c> addedSchedList = [SELECT Shipment_Date__c, Shipment_Quantity__c, Notes__c 
                                                 FROM Shipment_Forecast__c 
                                                 WHERE Quote_Product__c =: quoteProd.Id ORDER BY Shipment_Date__c];
        System.assertEquals(2, addedSchedList.size());
        System.assert(addedSchedList[0].Shipment_Quantity__c == 5);
    }
    
    static testMethod void failedSavedTest(){
        Account acc = new Account(Name='TestAcc', Phone='838-77-03', 
                                  Account_Type__c='Association', /*District__c='Canada',*/ 
                                  QWBS_Market__c='T&L', QWBS_Status__c='Active Prospect');
        insert acc;
       
        Opportunity opp = new Opportunity(Name='TestOpp', AccountId = acc.Id, 
                                          CloseDate=date.today(), StageName='Sales Acceptance');
        insert opp;
        
        VCG_CPQ_Quote__c quote = new VCG_CPQ_Quote__c(Account__c=acc.Id, Opportunity__c = opp.Id, 
                                                      Effective_Date__c = date.today(), Contract_Term__c=5);
        insert quote;
        
        VCG_CPQ_Quote_Product__c quoteProd = new VCG_CPQ_Quote_Product__c(Quote__c=quote.Id, License_Metric_Quantity__c=10);
        insert quoteProd;
        
        Test.startTest();
            Test.setCurrentPage(Page.EditShipmentSchedule);
            EditShipmentScheduleExt controller = new EditShipmentScheduleExt(new ApexPages.StandardController(quoteProd));
            controller.addRow();
            controller.dispShipmentSched[0].Shipment_Date__c = Date.today();
            controller.dispShipmentSched[0].Shipment_Quantity__c = 10;
            controller.dispShipmentSched[0].Notes__c = 'test shipment sched';
            controller.dispShipmentSched[1].Shipment_Date__c = Date.today();
            controller.dispShipmentSched[1].Shipment_Quantity__c = 5;
            controller.dispShipmentSched[1].Notes__c = 'test shipment sched2';
            controller.saveShipmentSched();
        Test.stopTest();
        
        List<Shipment_Forecast__c> addedSchedList = [SELECT Shipment_Date__c, Shipment_Quantity__c, Notes__c 
                                                 FROM Shipment_Forecast__c 
                                                 WHERE Quote_Product__c =: quoteProd.Id ORDER BY Shipment_Date__c];
        System.assertEquals(0, addedSchedList.size());
        
    }
}