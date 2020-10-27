/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest(seeAllData=true)
private class Overlay_Oppty_ExtensionTest {
     static List<Opportunity> insertOpptys(){
        
        Account accountInstance=new Account();
        accountInstance.name='Test Account name';
        accountInstance.Phone='3432433232';
        accountInstance.Account_Type__c='Association';
        //accountInstance.District__c='Canada';
        accountInstance.Account_Manager__c=Userinfo.getUserId();
        accountInstance.BillingStreet='Test Billing Street';
        accountInstance.BillingCity='Test Billing City';
        accountInstance.BillingCountry='AZ';
        insert accountInstance;
        
        List<Opportunity> listOpptys=new List<Opportunity>();
        
        Opportunity opptyInstance=new Opportunity();
        opptyInstance.Name='Test Oppty 123 Name';
        opptyInstance.AccountId=accountInstance.Id;
        opptyInstance.Ranking__c='Cold';
        opptyInstance.CloseDate=System.today()+ 10;
        opptyInstance.At_Risk__c='Yes';
        opptyInstance.StageName='No Opportunity';
        opptyInstance.Forecast_Demand__c='Omitted - 0% to 30%';
        opptyInstance.Contract_Type__c='Contract';
        opptyInstance.Product_Type__c='Applications';
        opptyInstance.Type='New Prospect';
        listOpptys.add(opptyInstance);
        
        opptyInstance=new Opportunity();
        opptyInstance.Name='Test Oppty 456 Name';
        opptyInstance.AccountId=accountInstance.Id;
        opptyInstance.CloseDate=System.today()+ 10;
        opptyInstance.Ranking__c='Hot';
        opptyInstance.At_Risk__c='Yes';
        opptyInstance.StageName='No Opportunity';
        opptyInstance.Forecast_Demand__c='Omitted - 0% to 30%';
        opptyInstance.Contract_Type__c='Contract';
        opptyInstance.Product_Type__c='Applications';
        opptyInstance.Type='New Prospect';
        listOpptys.add(opptyInstance);
        
        opptyInstance=new Opportunity();
        opptyInstance.Name='Test Oppty 789 Name';
        opptyInstance.AccountId=accountInstance.Id;
        opptyInstance.CloseDate=System.today()+ 10;
        opptyInstance.Ranking__c='Hot';
        opptyInstance.At_Risk__c='Yes';
        opptyInstance.StageName='No Opportunity';
        opptyInstance.Forecast_Demand__c='Omitted - 0% to 30%';
        opptyInstance.Contract_Type__c='Contract';
        opptyInstance.Product_Type__c='Applications';
        opptyInstance.Type='New Prospect';
        listOpptys.add(opptyInstance);
        
        insert listOpptys;
        
        //create a product
        Product2 productInstance=new Product2();
        productInstance.Name='Test product name 123';
        productInstance.IsActive=true;
        productInstance.ProductCode='45674';
        productInstance.Description='Test Product Description';
        insert productInstance;
        
        Pricebook2 standardPB = [select id from Pricebook2 where isStandard=true];
        PricebookEntry standardPBE = new PricebookEntry(Pricebook2Id = standardPB.Id, Product2Id = productInstance.Id, UnitPrice = 1000, IsActive = true);
        insert standardPBE;
        
        Pricebook2 stdPb = [select Id from Pricebook2 where NAME = 'Domestic PriceBook'];
        PricebookEntry spbe =  new PricebookEntry(pricebook2id = stdPb.id, product2id = productInstance.id, unitprice=100.0, isActive=true);
        insert spbe;
         
        /*PricebookEntry priceBookEntryInstance=new PricebookEntry();
        priceBookEntryInstance.IsActive=true;
        priceBookEntryInstance.Product2Id=productInstance.id;
        priceBookEntryInstance.Pricebook2Id=pricebookInstance.id;
        priceBookEntryInstance.UnitPrice=45;
        insert priceBookEntryInstance;*/
   
        //attach line items to the first opportunity
        OpportunityLineItem lineItemInstance=new OpportunityLineItem();
        lineItemInstance.PricebookEntryId=spbe.Id;
        lineItemInstance.OpportunityId=listOpptys.get(0).Id;
        lineItemInstance.Quantity=1;
        lineItemInstance.TotalPrice=67;
        insert lineItemInstance;
        
        //create a different product
        
       /* productInstance=new Product2();
        productInstance.Name='Test product name 456';
        productInstance.IsActive=true;
        productInstance.ProductCode='1234656';
        productInstance.Description='Test Product Description';
        insert productInstance;
        
        priceBookEntryInstance=new PricebookEntry();
        priceBookEntryInstance.IsActive=true;
        priceBookEntryInstance.Product2Id=productInstance.id;
        priceBookEntryInstance.Pricebook2Id=pricebookInstance.id;
        priceBookEntryInstance.UnitPrice=97;
        insert priceBookEntryInstance;
        
        lineItemInstance=new OpportunityLineItem();
        lineItemInstance.PricebookEntryId=priceBookEntryInstance.Id;
        lineItemInstance.OpportunityId=listOpptys.get(0).Id;
        lineItemInstance.Quantity=5;
        lineItemInstance.TotalPrice=67;
        insert lineItemInstance;*/
        
        
        return listOpptys;
        
    }
    
    static testMethod void validTestCase() {
        // TO DO: implement unit test
        List<Opportunity> insertedOpptys=insertOpptys();
        Test.startTest();
        ApexPages.StandardSetController standardOpptyController=new ApexPages.StandardSetController(insertedOpptys);
        
        standardOpptyController.setSelected(insertedOpptys);
        
        Overlay_Oppty_Extension opptyExtensionInstance=new Overlay_Oppty_Extension(standardOpptyController);
        
        //change lead values
        for(OpportunityWrapper opptyWrapperInstance:opptyExtensionInstance.selectedOpportunity){
            //we update only the first instance
            opptyWrapperInstance.opportunityInstance.Name='Test Oppty Name 123 Updated';
            opptyWrapperInstance.taskInstance.Description='Test Oppty 123 task creation';
            break;
        }
        
        opptyExtensionInstance.saveOpptys();
        
        //compare the saved values now
        List<Opportunity> savedOpptys=[select Id, Name from Opportunity where Id in :insertedOpptys and Ranking__c='Cold'];
        
        for(Opportunity opptyInstance: savedOpptys){
            System.assertEquals('Test Oppty Name 123 Updated',opptyInstance.Name);
        }
       
       //check for created tasks
        List<Task> savedTasks=[select Id, Description, WhatId, Subject from Task where WhatId in :insertedOpptys];
        
        //validate that only one task was created
        System.assertEquals(1,savedTasks.size());
        
        for(Task taskInstance:savedTasks){
            System.assertEquals('Test Oppty 123 task creation',taskInstance.Description);
            //make sure the task is associtated with the first lead
            System.assertEquals(insertedOpptys.get(0).Id,taskInstance.WhatId);
        }
        
        //test the oppty line items in the overlay
        OpptyLineItemsController lineItemsController=new OpptyLineItemsController();
        lineItemsController.pageController=opptyExtensionInstance;
        lineItemsController.setOpptyId(insertedOpptys.get(0).id);
        lineItemsController.setRowNumber(0);
        lineItemsController.setHideOverlay(false);
        lineItemsController.setOpptyName('Test Oppty 123 Name');
        
        //assert the get methods
        
        System.assertEquals(insertedOpptys.get(0).id,lineItemsController.getOpptyId());
        System.assertEquals(0,lineItemsController.getRowNumber());
        System.assertEquals(false,lineItemsController.getHideOverlay());
        System.assertEquals('Test Oppty 123 Name',lineItemsController.getOpptyName());
        
        
        //fetch the oppty line items to be displayed in overlay
        for(OpportunityLineItem opptyLineItemInstance: lineItemsController.opptyLineItems){
            //update the quantity to 55
            opptyLineItemInstance.Quantity=55;
        }
        
        lineItemsController.saveOpptyLineItems();
        
        //query oppty line items and check, if the values are updated
        
        for(OpportunityLineItem opptyLineItemInstance:[select Id, OpportunityId, Quantity from OpportunityLineItem where OpportunityId =:insertedOpptys.get(0).Id]){
           //System.assertEquals(55,opptyLineItemInstance.Quantity);  
        }
        
        System.assertEquals(null,lineItemsController.cancelRecord());
        Test.stopTest();
   }
   
    static testMethod void inValidTestCase() {
        // TO DO: implement unit test
        List<Opportunity> insertedOpptys=insertOpptys();
        
        Test.startTest();
        ApexPages.StandardSetController standardOpptyController=new ApexPages.StandardSetController(insertedOpptys);
        
        standardOpptyController.setSelected(insertedOpptys);
        
        Overlay_Oppty_Extension opptyExtensionInstance=new Overlay_Oppty_Extension(standardOpptyController);
        
        //change lead values
        for(OpportunityWrapper opptyWrapperInstance:opptyExtensionInstance.selectedOpportunity){
            //update the first name and close date to be blank
            opptyWrapperInstance.opportunityInstance.Name='Test Oppty Name 123 Updated';
            opptyWrapperInstance.opportunityInstance.CloseDate=null;
            opptyWrapperInstance.taskInstance.Description='Test Oppty 123 task creation';
            break;
        }
        
        PageReference ref= opptyExtensionInstance.saveOpptys();
        
        //validate that the page reference returned was null
        System.assertEquals(null,ref);
        
        //compare the saved values now
        List<Opportunity> savedOpptys=[select Id, Name from Opportunity where Id in :insertedOpptys and Ranking__c='Cold'];
        
        for(Opportunity opptyInstance: savedOpptys){
            System.assertNotEquals('Test Oppty Name 123 Updated',opptyInstance.Name);
            System.assertEquals('Test Oppty 123 Name',opptyInstance.Name);
        }
       
       //check for created tasks
        List<Task> savedTasks=[select Id, Description, Subject from Task where WhatId in :insertedOpptys];
        
        //validate that only no task was created
        System.assertEquals(0,savedTasks.size());
        Test.stopTest();
          
   }
}