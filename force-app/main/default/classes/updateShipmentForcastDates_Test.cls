@isTest(SeeAllData=True)
 private class updateShipmentForcastDates_Test{
     static testMethod void testupdateshipmentForecastDates(){
         Account a = TestUtils.getAccount('u1 Acc');
         Insert a;
         
         Contract ctrct=TestUtils.getContract(a);
         insert ctrct;
         
         test.startTest();
         Opportunity o = TestUtils.getOpportunity(a,'UT oppty1');
         o.Contract__c=ctrct.id;
         o.type='New Customer';
         o.Order_Type__c='New';
         o.StageName='Sales Acceptance';
         o.legal_Review__c='';
         o.Finance_Status__c='';
         o.CloseDate=date.today().addMonths(2);
         insert o;
         VCG_CPQ_Quote__c q = new VCG_CPQ_Quote__c ( Opportunity__c = o.id, is_Primary__c=true );
            insert q ;
        
        VCG_CPQ_Quote_Product__c qp= new VCG_CPQ_Quote_Product__c(Name='AB1234', Quote__c=q.id);
        insert qp;
        
        shipment_forecast__c sf = new shipment_forecast__c(Quote_Product__c=qp.id,shipped__c=false,Shipment_Quantity__c=4000);
        sf.Shipment_Date__c=date.today();        insert sf;
        
         o.closeDate=date.today().addMonths(3);
         update o;
         test.stopTest();
     }
 
 }