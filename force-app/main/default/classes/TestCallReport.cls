@isTest(seeAllData=true)
private class TestCallReport{    
    public static testmethod void Testmethod1(){
        
        Account newAccount = new Account();         
        newAccount.Name = 'SFDC';         
        newAccount.Type = 'Other';         
        newAccount.BillingStreet = 'Test Address';         
        newAccount.BillingCity = 'Test City';         
        newAccount.BillingCountry = 'Test Country';         
        newAccount.QWBS_Cust_ID__c = '4567';        
        insert newAccount;
        
        Product2 p = new product2(name='Test Product');
        insert p;
        
        Pricebook2 standardPB = [select id from Pricebook2 where isStandard=true];
        PricebookEntry standardPBE = new PricebookEntry(Pricebook2Id = standardPB.Id, Product2Id = p.Id, UnitPrice = 1000, IsActive = true);
        insert standardPBE;
        
        Pricebook2 stdPb = [select Id from Pricebook2 where NAME = 'Domestic PriceBook'];
        PricebookEntry spbe =  new PricebookEntry(pricebook2id = stdPb.id, product2id = p.id, unitprice=100.0, isActive=true);
        insert spbe;
        
        /*Pricebook2 pb = new pricebook2(name='test pricebook');
        insert pb; 
        
        PricebookEntry pbe = new PricebookEntry(pricebook2id=pb.id, product2id=p.id, unitprice=100.0, isActive=true);
        insert pbe;*/
        Date currDate;
        
        DateTime currDateTime = system.now()+1;
        currDate = Date.newInstance(currDateTime.year(),currDateTime.month(),currDateTime.day());
                    
        Opportunity o = new Opportunity(name='test', pricebook2id=stdPb.id, stageName='Open', CloseDate=currDate ,AccountId= newAccount.Id );
        insert o;
        
        OpportunityLineItem oli = new OpportunityLineItem(opportunityid=o.id, UnitPrice=100, quantity=1, pricebookentryid=spbe.Id); 
        insert oli;

        
        Call_Report__c callReport = new Call_Report__c();
        callReport.Type_of_Competitor__c = 'No Competitor';
        callReport.Advance_Achieved__c = 'Yes';
        callReport.Advance_Comments__c = 'test';
        callReport.Account__c = newAccount.Id;
        insert callReport ;
        
        ApexPages.currentPage().getParameters().put('Id',callReport.Id);
        ApexPages.StandardController sdtCon;
        CallReportController newObj = new CallReportController(sdtCon);
        
        callReport.Comments__c = 'test';
        try{
            update callReport;
        }
        catch(exception e)
        {
            System.debug(e.getMessage());
        }
        
        Call_Report__c callReport1 = new Call_Report__c();
        callReport1.Advance_Achieved__c = 'Yes';
        callReport1.Advance_Comments__c = 'test';
        callReport1.Account__c = newAccount.Id;
        //callReport1.Competitor_Company_Name__c = callReport.Competitor_Company_Name__c;
         try{
            insert callReport1;
        }
        catch(exception e)
        {
            System.debug(e.getMessage());
        }
    }
}