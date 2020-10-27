/**********************************************************************************
Modified Date: 4/30/2015
Modified By: Rittu Roy
Reason: Added TestRevertStageReversal method to test revertStageReversal method in 
        OpportunityUtils class

***********************************************************************************/

@isTest
private class TestOpportunityClasses{   

    public static testmethod void TestCloneOpportunityProductController (){
        
        Account Acct = GenericTestClass.insertAccount();
        
        Product2 p = new product2(name='Test Product');
        insert p;

        Pricebook2 standardPB = [select id from Pricebook2 where isStandard=true];
		PricebookEntry standardPBE = new PricebookEntry(Pricebook2Id = standardPB.Id, Product2Id = p.Id, UnitPrice = 1000, IsActive = true);
    	insert standardPBE;
        
        Pricebook2 stdPb = [select Id from Pricebook2 where NAME = 'Domestic PriceBook'];
        PricebookEntry spbe =  new PricebookEntry(pricebook2id = stdPb.id, product2id = p.id, unitprice=100.0, isActive=true);
        insert spbe;
        
        Date currDate;
        
        DateTime currDateTime = system.now()+1;
        currDate = Date.newInstance(currDateTime.year(),currDateTime.month(),currDateTime.day());
                    
        Opportunity o = new Opportunity(name='test', pricebook2id=stdpb.id, stageName='Open', CloseDate=currDate ,AccountId= Acct.ID  );
        insert o;
        
        OpportunityLineItem oli = new OpportunityLineItem(opportunityid=o.id, UnitPrice=100, quantity=1, pricebookentryid=spbe.Id); 
        insert oli;
        Apexpages.currentPage().getParameters().put('Id',o.Id);
        CloneOpportunityProductController newObj = new CloneOpportunityProductController();
        newObj.strSelProdIDs = oli.ID;
        newObj.cloneObj();
        newObj.save();
        
        
    }   
    
   /* public static testmethod void TestOpportunityAllTrigger(){
        
        Account Acct = GenericTestClass.insertAccount();
        Product2 p = new product2(name='Test Product');
        insert p;

        Pricebook2 standardPB = [select id from Pricebook2 where isStandard=true];
		PricebookEntry standardPBE = new PricebookEntry(Pricebook2Id = standardPB.Id, Product2Id = p.Id, UnitPrice = 1000, IsActive = true);
    	insert standardPBE;
        
        Pricebook2 stdPb = [select Id from Pricebook2 where NAME = 'Domestic PriceBook'];
        PricebookEntry spbe =  new PricebookEntry(pricebook2id = stdPb.id, product2id = p.id, unitprice=100.0, isActive=true);
        insert spbe;
        Date currDate;
        
        DateTime currDateTime = system.now()+1;
        currDate = Date.newInstance(currDateTime.year(),currDateTime.month(),currDateTime.day());
                    
        Opportunity o = new Opportunity(name='test', pricebook2id=stdPb.Id, stageName='Open', CloseDate=currDate ,AccountId= Acct.ID  );
        insert o;
        
        OpportunityLineItem oli = new OpportunityLineItem(opportunityid=o.id, UnitPrice=100, quantity=1, pricebookentryid=spbe.Id); 
        insert oli;
         
        o.stageName = 'Closed Lost';
        o.Reason_Lost__c =  'Bankruptcy';
                    
        o.Reason_Lost_Comments__c = 'Bankruptcy';
        update o;
    }*/
     
    /*Tests revertStageReversal method in OpportunityUtils class*/ 
    public static testmethod void TestRevertStageReversal(){
        List<Id> lstOpptIds = new List<Id>();
        
        //Create test data
        Opportunity newOppty = new Opportunity(Name='Test Opportunity',Stage_Reversal_Approval_Status__c = 'Rejected',
                                               StageName='Sales Acceptance',CloseDate=System.today()) ;
        Insert newOppty;
        
        lstOpptIds.add(newOppty.Id);
        OpportunityUtils.revertStageReversal(lstOpptIds);
    }
}