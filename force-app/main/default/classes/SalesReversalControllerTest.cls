@isTest(SeeAllData=true)
private class SalesReversalControllerTest {
    static testMethod void myUnitTest() {
       /*Account Acct = GenericTestClass.insertAccount();
        
        Product2 p = new product2(name='Test Product');
        insert p;

        Pricebook2 stdPb = [select Id from Pricebook2 where isStandard=true limit 1];
        insert new PricebookEntry(pricebook2id = stdPb.id, product2id = p.id, unitprice=100.0, isActive=true);
        
        Pricebook2 pb = new pricebook2(name='test pricebook');
        insert pb; 
        
        PricebookEntry pbe = new PricebookEntry(pricebook2id=pb.id, product2id=p.id, unitprice=100.0, isActive=true);
        insert pbe;
        Date currDate;
        
        DateTime currDateTime = system.now()+1;
        currDate = Date.newInstance(currDateTime.year(),currDateTime.month(),currDateTime.day());
                    
        Opportunity o = new Opportunity(name='test', pricebook2id=pb.id, stageName='Open', CloseDate=currDate ,AccountId= Acct.ID  );
        insert o;
        
        OpportunityLineItem oli = new OpportunityLineItem(non_recurring_revenue__c = 15, opportunityid=o.id, UnitPrice=100, quantity=1, 
                                                            software_to_omni__c = 50, total_amount__c = 15, cgm__c = 15, annual_recurring_revenue__c = 15,
                                                                    pricebookentryid=pbe.Id, sales_reverse__c = true); 

        insert oli;
        Apexpages.currentPage().getParameters().put('Id',o.Id);
  
        Test.startTest();
            SalesReversalController srcontroller = new SalesReversalController(new ApexPages.StandardController(o));
            srcontroller.save();
            srcontroller.cancel();
        Test.stopTest();*/

    }
}