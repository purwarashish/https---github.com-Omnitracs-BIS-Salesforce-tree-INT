/* Test Class for CreateXRSOpportunityEmailToCase Apex Class */

@isTest(SeeAllData=True)
Public Class CreateXRSOpportunityEmailToCase_Test
{
  public static VistaAssetHelperUtil util = new VistaAssetHelperUtil();
@isTest
Public Static void CreateXRSOpportunityEmailToCase1()
{
    List<Opportunity> lstnewOpportunity = new List<Opportunity>();
    List<VCG_CPQ_Quote__c> lstQuote = new List<VCG_CPQ_Quote__c>();         
    List<opportunityLineItem> lstOpportunityProduct = new List<opportunityLineItem>();
    
    // Creation of Account for Opportunity
    Account objAccount = new Account(); 
    objAccount.Name='TestAccount';
    objAccount.Phone='324324324';
    //objAccount.District__c='Strategic';
    objAccount.BillingStreet='Test Billing Street';
    objAccount.BillingCity='Test Billing City';
    objAccount.BillingCountry='Test Billing Country';
    objAccount.Primary_Business_Unit__c='RoadNet';
    objAccount.Account_Status__c='Active';
    Insert objAccount;
    System.assert(objAccount.id!=null,'Account Creation');
    
    // Creation of Contact
    Contact objContact= new Contact();
    objContact.LastName='TestContact';
    objContact.Title='TestTitle';
    objContact.Phone='123465789';
    objContact.Decision_Maker_Influencer__c='Yes';        
    objContact.LeadSource='800#';
    objContact.Lead_Origin__c='XRS';
    objContact.AccountId=objAccount.Id;
    Insert objContact;
            
    // Query Standard Pricebook required for the creation of Pricebook entry
    PriceBook2 objStandardPriceBook = [Select Id, Name from PriceBook2 where NAME = 'Domestic PriceBook'];
    Opportunity objOpportunity;
    //Creation of Opportunity
    for(Integer i=0;i<3; i++)
    {
        objOpportunity = new Opportunity();
        objOpportunity.name ='TestOpportunity'+i;
        objOpportunity.AccountId= objAccount.Id;
        objOpportunity.Contact__c= objContact.Id;
        objOpportunity.StageName='Negotiate'; //'Closed Won';
        objOpportunity.RecordTypeId='01250000000QjIT'; //RecordType Id of Partner Opportunity (Reseller)
        objOpportunity.Product_Type__c='Hardware';
        objOpportunity.Product_name__c='XRS';
        objOpportunity.Primary_Quote_Approval_Status__c='Approved';
        objOpportunity.Primary_Quote_Shipment_Address__c=True;
        objOpportunity.CloseDate = System.Today() + 30;
        objOpportunity.Pricebook2Id = objStandardPriceBook.Id;
        objOpportunity.Send_XRS_Shipment_Request__c=TRUE;
        objOpportunity.Freight_Method__c ='Air Freight (2nd Day)';
        objOpportunity.Email_Sent__c = True;
        lstnewOpportunity.add(objOpportunity);
    }
    Insert lstnewOpportunity;
    
      //Account Address for Quotes [Shipment Address]
    Address__c ObjAddress = new Address__c();
    ObjAddress.Account__c= objAccount.Id;
    ObjAddress.Address_Line_1__c = 'Test Address Line 1';
    ObjAddress.Address_Line_2__c = 'Test Address Line 2 ';
    ObjAddress.City__c ='Test City';
    ObjAddress.State_Province__c = 'State Province';
    ObjAddress.Zip_Postal_Code__c = '0123456';
    Insert ObjAddress;
    
    // Creation of Quotes for Opportunity
    VCG_CPQ_Quote__c ObjQuotes;
    for(Integer i=0;i<3; i++)
    {
        ObjQuotes = new VCG_CPQ_Quote__c();
        ObjQuotes.Is_Primary__c= True;
        ObjQuotes.Opportunity__c = lstnewOpportunity[i].Id;
        ObjQuotes.ShippingAddress__c = ObjAddress.Id; 
        ObjQuotes.Invoice_Address__c = ObjAddress.Id;
        lstQuote.add(ObjQuotes);        
    }
    
    Insert lstQuote;
    
    //Creation of Product2
    Product2 objProduct2= new Product2();
    objProduct2.Name = 'TestProduct2Name';
    objProduct2.Product_Type__c = 'Hardware';
    objProduct2.ProductCode ='TestProductCode';
    objProduct2.Product_Code__c='TestProductCode';
    objProduct2.IsActive = true;
    Insert objProduct2;
    Pricebook2 standardPB = [select id from Pricebook2 where isStandard=true];
  PricebookEntry standardPBE = new PricebookEntry(Pricebook2Id = standardPB.Id, Product2Id = objProduct2.Id, UnitPrice = 1000, IsActive = true);
     insert standardPBE;
        
    //Creation of Pricebook entry     
    PriceBookEntry objPriceBookEntry = new PriceBookEntry();
    objPriceBookEntry.PriceBook2ID = objStandardPriceBook.id;
    objPriceBookEntry.Product2Id = objProduct2.id;
    objPriceBookEntry.UnitPrice = 1;
    objPriceBookEntry.isActive = true;
    Insert objPriceBookEntry;
        
    //Creation of Opportunity Product
    opportunityLineItem objopportunityLineItem;
    for(Integer i=0;i<3; i++)
    {
        objopportunityLineItem = new opportunityLineItem();
        objopportunityLineItem.OpportunityId = lstnewOpportunity[i].Id;
        objopportunityLineItem.Quantity=5+i;
        objopportunityLineItem.TotalPrice = 1000+i;
        objopportunityLineItem.PricebookEntryId = objPriceBookEntry.id;
        objopportunityLineItem.Product_Type__c ='Hardware';
        lstOpportunityProduct.add(objopportunityLineItem);
    }
    
    Insert lstOpportunityProduct;
    
    List<Opportunity> lstOpportunity =[SELECT Id, AccountId, Name, StageName, Description, CloseDate,Primary_Quote_Approval_Status__c, 
                                            Primary_Quote_Shipment_Address__c, RecordType.Name, Pricebook2Id, Product_name__c, 
                                            Number_of_Hardware_Product__c,product_Type__c FROM Opportunity where id= :objOpportunity.Id];
     SBQQ__Quote__c sbQuote = util.createSBQuote(objOpportunity, objAccount, Date.today(), true);  
     Test.StartTest();                              
        for(Opportunity objTempOpportunity : lstOpportunity)  
        {
           objTempOpportunity.SBQQ__PrimaryQuote__c = sbQuote.Id;
           objTempOpportunity.StageName='Closed Won';
        }
        
        Update lstOpportunity;
        CreateXRSOpportunityEmailToCase.SendXRSOpportunityEmail(lstOpportunity);
   Test.stopTest();
}

}