/*
 *  @author:        Mark De Chavez | mark.dechavez@cloudsherpas.com
 *  @description:   Test class for QuoteEditShipmentScheduleController.
 *  @date-created:  September 23, 2014
 *  @revision: 
 */

@isTest(SeeAllData=True)
public class QuoteEditShipmentScheduleController_Test {

    static testMethod void testRedirectToEditShipmentSched(){
        Account acc = new Account(Name='TestAcc', Phone='838-77-03', 
                                  Account_Type__c='Association', /*District__c='Canada',*/ 
                                  QWBS_Market__c='T&L', QWBS_Status__c='Active Prospect', BillingCountry='USA');
        insert acc;
       
        Opportunity opp = new Opportunity(Name='TestOpp', AccountId = acc.Id, 
                                          CloseDate=date.today(), StageName='Sales Acceptance');
        insert opp;
        
        VCG_CPQ_Quote__c quote = new VCG_CPQ_Quote__c(Account__c=acc.Id, Opportunity__c = opp.Id, 
                                                      Effective_Date__c = date.today(), Contract_Term__c=5);
        insert quote;
        
        Product2 p2 = TestUtils.getProduct('ut prod2', 'Omnitracs');
        p2.Shipment_Schedule_Required__c = TRUE;
        p2.ProductCode = 'OMNI';
        insert p2;
        
        VCG_CPQ_Quote_Product__c quoteProd = new VCG_CPQ_Quote_Product__c(Quote__c=quote.Id, License_Metric_Quantity__c=1, Product__c=p2.Id);
        insert quoteProd;
        
        Test.startTest();
            PageReference currentPage = page.QuoteEditShipmentSchedule;
            Test.setCurrentPage(currentPage);
            //Set the URL parameter
            System.currentPageReference().getParameters().put('id', quote.Id);
        
            QuoteEditShipmentScheduleController controller = new QuoteEditShipmentScheduleController();
        
            //Verify the parameters
            System.assertEquals('/apex/EditShipmentSchedule?id='+quoteProd.id+'&passedQuoteId='+quote.id, controller.redirectToEditShipmentSched().getURL());
        Test.stopTest();
    }
    
    static testMethod void testredirectToRecordsView(){
        Account acc = new Account(Name='TestAcc', Phone='838-77-03', 
                                  Account_Type__c='Association', /*District__c='Canada',*/ 
                                  QWBS_Market__c='T&L', QWBS_Status__c='Active Prospect', BillingCountry='US');
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
            PageReference currentPage = page.QuoteEditShipmentSchedule;
            Test.setCurrentPage(currentPage);
            //Set the URL parameter
            System.currentPageReference().getParameters().put('id', quote.Id);
        
            QuoteEditShipmentScheduleController controller = new QuoteEditShipmentScheduleController();
            System.assertEquals('/'+String.valueOf(quote.Id).substring(0, 15), controller.redirectToEditShipmentSched().getURL());
        Test.stopTest();
    }
    
}