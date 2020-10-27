@isTest
public class OpportunityTestData 
{
    List<Account> lstAccount;   //List of Account being created as per the count.
    List<Opportunity> lstOppotunity;    //List of Oppotunities being created as per the count.
    List<Contact> lstContact; //List of Contacts being created as per the count.
    List<User> lstUser; // Users required for testing Purpose.Sele
    List<OpportunityContactRole> lstOppotunityContactRole;  
    List<OpportunityLineItem> lstOpportunityLineItem;
    List<Address__c> lstAccountAddress;
    List<VCG_CPQ_Quote_Product__c> lstQuoteProduct;
    List<Campaign> lstCampaign;
    List<VCG_CPQ_Quote__c> lstQuote;
    PriceBook2 objStandardPriceBook;
    List<Product2> productlist;
    List<PriceBookEntry> lstPriceBookEntry;
    List<Country_And_Country_Code__c> lsttestCountryAndCountryCode;
    
    //User Creation
    Public User CreateUser(String Criteria, id IdProfile, String UserName, id IdContact)
    {   
        User U = new User();
        U.email = UserName+'@testmail.com';
        U.emailencodingkey = 'UTF-8';
        U.lastname = UserName;
        U.languagelocalekey = 'en_US';
        U.localesidkey='en_US';
        U.timezonesidkey = 'America/Denver';
        U.username = UserName+'@test.com';
        U.alias=UserName;
        U.ProfileId=IdProfile;
        if(IdContact!=null)
        {
            U.ContactId = IdContact;
        }
        if(Criteria=='BURoadnet')
        {
            U.Business_Unit__c='Roadnet';
        }
        return U;
    }
    
    //Account Creation
    Public List<Account> CreateAcccount(String Criteria, Integer AccountCount)
    {   
        lstAccount = new List<Account>();
        Account objAccount;
        for(Integer i=0; i<AccountCount; i++) 
        {
            objAccount = new Account();
            /*  Sales_Plan_Req_Cannot_Move_to_Negotiate,           */
            objAccount.RecordTypeId=SearchRecordTypeID('Partner Account (Reseller)','Account');
            objAccount.Inside_CSR__c = '00550000000wv7f';
            objAccount.Name='TestAccount'+i;
            objAccount.Phone='324324324'+i;
            //objAccount.District__c='Strategic';
            objAccount.BillingStreet='Test Billing Street'+i;
            objAccount.BillingCity='Test Billing City'+i;
            objAccount.BillingState='TX';
            objAccount.BillingPostalCode='7506'+i;
            objAccount.BillingCountry='Test Billing Country'+i;
            objAccount.ShippingCountry='Test Shipping Country'+i;
            objAccount.Primary_Business_Unit__c='Omnitracs Domestic';
            objAccount.Account_Status__c='Active';
            objAccount.Segment__c='TL';
            objAccount.Fleet_Size__c = 100;
            objAccount.Account_Classification__c='Prospect';
            if(Criteria=='Roadnet')
            {
                objAccount.Primary_Business_Unit__c='Roadnet';
                objAccount.Roadnet_Market__c='Domestic';
            }
            if(Criteria == 'opportunityNetsuitesync')
            {
                objAccount.Primary_Business_Unit__c = 'Omnitracs Mexico';
                objAccount.RecordTypeId = SystemIds__c.getOrgDefaults().RecordTypeId_Account_TLSales__c;
                objAccount.Account_Classification__c = 'Prospect';
                objAccount.RFC_ID__c = '123456789';
                //objAccount.District__c = 'East District 1';
                objAccount.Ranking__c = 'Large';
            }
            
            lstAccount.add(objAccount);
        }
        return lstAccount;
    }
    
    //Contact Creation
    Public List<Contact> ContactCreation(String Criteria, Integer ContactCount, Id objAccountId)
    {
        Contact objContact;
        lstContact = new List<Contact>();
        for(Integer i=0;i<ContactCount;i++)
        {
            objContact= new Contact();
            objContact.AccountId=objAccountId;
            objContact.RecordTypeId=SearchRecordTypeID('Sales','Contact');
            objContact.FirstName='TestFname'+i;
            objContact.LastName='TestContact'+i;
            objContact.Title='TestTitle'+i;
            //objContact.Phone='123465789'+i;
            objContact.Decision_Maker_Influencer__c='Yes';        
            objContact.LeadSource='800#';
            objContact.Lead_Origin__c='XRS';
            lstContact.add(objContact);
        }
        return lstContact;
    }
    
    //Opportunity Creation
    Public List<Opportunity> CreateOpportunity(String Criteria, Id objAccountId, String RecordTypeName, Integer OppotunityCount,
                                               Id objContactId, PriceBook2 stdPriceBook, id objCaseId, id objUserId,
                                               List<Country_And_Country_Code__c> lstCountryAndCountryCode)
    {   
        lstOppotunity = new List<Opportunity>();
        Opportunity objOpportunity;
        for(Integer i=0; i<OppotunityCount; i++) 
        {
            objOpportunity = new Opportunity();
            objOpportunity.Name='TestOpportunity Project Change '+i;
        //  objOpportunity.deposit_pending_to_pending_date__c=null;
            objOpportunity.RecordTypeId=SearchRecordTypeID(RecordTypeName,'Opportunity');
            objOpportunity.CurrencyIsoCode='USD';
            objOpportunity.CloseDate=Date.Today()+30;
            objOpportunity.Geo_Region__c='EMEA';
            objOpportunity.AccountId=objAccountId;                        
            objOpportunity.StageName='Sales Acceptance';
            objOpportunity.Type='Existing Customer';
            objOpportunity.Order_Type__c='New';
            objOpportunity.Primary_Contact__c = objContactId;
            objOpportunity.Role__c ='Sponsor';           
            objOpportunity.Order_Sub_Type__c = 'Prior Customer';
            objOpportunity.Pricebook2Id = stdPriceBook.Id;
            
            if(Criteria == 'createUpdateAssets')
            {
                objOpportunity.Legal_Review__c = 'Waiting for Finance Review';
                objOpportunity.Finance_Status__c = 'Approved';                
            }                                   
         /* if(Criteria=='User')
            {
                objOpportunity.Se_Approval__c=true;
                objOpportunity.current_se__c=objUserId;
            }*/                            
            if(Criteria == 'salesCompleteCriteria')
            {
                objOpportunity.Legal_Review__c = 'Initial Review';
                objOpportunity.Order_Sub_Type__c = 'Annual Increase';
                objOpportunity.Pricebook2Id = objStandardPriceBook.Id;
                objOpportunity.Contact__c= objContactId;
            }
            if(Criteria == 'salesacceptance')
            {
                objOpportunity.Order_Sub_Type__c = 'Annual Increase';
            }
            
            if(Criteria == 'opportunityNetsuitesync')
            {
                objOpportunity.Primary_Quote_Approval_Status__c = 'Approved';
                objOpportunity.Negotiation_Type__c = 'Sale';
            }
            if(Criteria == 'Closedlost')
            {
                objOpportunity.StageName = 'Closed lost';
                objOpportunity.Reason_Lost_Comments__c ='test lost';
            }
         /*   if(Criteria == 'assignGeoRegionAndOpptCountry')
            {
                if(i == 0){
                    objOpportunity.Opporunity_Country__c = lstCountryAndCountryCode.get(0).Name;
                 // objOpportunity.Hidden_Opportunity_Region__c = null;
                }    
                if(i == 1){
                    objOpportunity.Opporunity_Country__c = lstCountryAndCountryCode.get(1).Name;
                 // objOpportunity.Hidden_Opportunity_Region__c = 'APAC';
                }    
            }*/
            if(objCaseId!=null)
            {
                objOpportunity.case__c=objCaseId;
            }
            
            if((Criteria!=null) && (Criteria.contains('NoPrimary')))
            {
                objOpportunity.Primary_Contact__c = null;
                objOpportunity.Role__c = null;
                    
                if(Criteria.contains('NoPrimaryContactRole'))
                {
                    objOpportunity.Primary_Contact__c = objContactId;
                }   
                else if(Criteria.contains('NoPrimaryContact'))
                {
                    objOpportunity.Role__c ='Sponsor'; 
                }
            }
                                 
            lstOppotunity.add(objOpportunity);
        }
        return lstOppotunity;
    }
    //Search Rercord Type id based on its name
    Private ID SearchRecordTypeID(String RecordTypeLabel,String SObjName)
    {  
        if(SObjName == 'Account')
        {
            return Schema.Sobjecttype.Account.getRecordTypeInfosByName().get(RecordTypeLabel).getRecordTypeId();
        }
        else if(SObjName == 'Contact')
        {
            return Schema.Sobjecttype.Contact.getRecordTypeInfosByName().get(RecordTypeLabel).getRecordTypeId();
        }
        else if(SObjName == 'Opportunity')
        {
            return Schema.Sobjecttype.Opportunity.getRecordTypeInfosByName().get(RecordTypeLabel).getRecordTypeId();
        }
        else
        {
            return null;
        }
    }
    
    Public List<OpportunityContactRole> CreateOpportunityContactRole(String Criteria, Id opportunityId ,Integer opportunityContactRoleCount,Id contactId)
    {   
        
        lstOppotunityContactRole = new List<OpportunityContactRole>();
        OpportunityContactRole objOpportunityContactRole;
        for(Integer i=0; i<opportunityContactRoleCount; i++) 
        {           
            objOpportunityContactRole = new OpportunityContactRole();            
            objOpportunityContactRole.OpportunityId = opportunityId;          
            objOpportunityContactRole.IsPrimary= FALSE;
            objOpportunityContactRole.ContactId = contactId;
            
            lstOppotunityContactRole.add(objOpportunityContactRole);
        }
        return lstOppotunityContactRole;
    }
    
    public PriceBook2 createPriceBook()
    {
        // Query Standard Pricebook required for the creation of Pricebook entry
        objStandardPriceBook = [Select Id, Name from PriceBook2 where isStandard = true];
        return objStandardPriceBook;
    }
    
    Public List<Product2> createProduct(String Criteria, Integer productCount)
    {
        productlist = new List<Product2>();
        Product2  product;
        for(Integer i=0; i<productCount; i++) 
        {
            product = new Product2();
            product.Name = 'Product X'+i;
            product.ProductCode = 'Pro-X'+i;
            product.isActive = true;
            product.Shipment_Schedule_Required__c  =false;
            
            if(Criteria == 'createUpdateAssets')
            {
                if(i == 0)
                    product.Is_Assetizable__c = true;
                if(i == 1)
                    product.Is_Maintenance__c = true;
            }
            
            if(Criteria == 'salesCompleteCriteria')
            {
                product.Product_Type__c = 'Hardware';
                product.Product_Code__c='TestProductCode';
                product.Shipment_Schedule_Required__c  =true;
            }
            productlist.add(product);
        }
        return productlist;
    }
    
    Public List<PriceBookEntry> createPriceBookEntry(String Criteria, Integer Count, PriceBook2 stdPriceBook, List<Product2> productlist)
    {
        //Creation of Pricebook entry
        lstPriceBookEntry = new List<PriceBookEntry>();     
        PriceBookEntry objPriceBookEntry;
        for(Integer i=0; i<Count; i++)
        {
            objPriceBookEntry = new PriceBookEntry();
            objPriceBookEntry.PriceBook2ID = stdPriceBook.id;
            objPriceBookEntry.Product2Id = productlist.get(i).id;
            objPriceBookEntry.UnitPrice = 1;
            objPriceBookEntry.isActive = true;
            lstPriceBookEntry.add(objPriceBookEntry);
        }        
        return lstPriceBookEntry;
    }
    
    Public List<opportunityLineItem> createopportunityLineItem(String Criteria, Integer Count, List<Opportunity> lstOpportunity,
                                                               List<PriceBookEntry> lstPriceBookEntry)
    {
        lstopportunityLineItem = new List<opportunityLineItem>();
        opportunityLineItem objopportunityLineItem;
        for(Integer i=0; i<Count; i++)
        {
            objopportunityLineItem = new opportunityLineItem();
            objopportunityLineItem.OpportunityId = lstOpportunity.get(0).Id;  //multiple product associated with one opportunity
            objopportunityLineItem.Quantity=5;
            objopportunityLineItem.TotalPrice = 1000;
            objopportunityLineItem.PricebookEntryId = lstPriceBookEntry.get(i).id;
            objopportunityLineItem.Product_Type__c ='Hardware';
            if(Criteria == 'createUpdateAssets' && i==0)
            {
                objopportunityLineItem.Line_Type__c = 'Decommission';
                objopportunityLineItem.Decommission_Quantity__c = 1;
                objopportunityLineItem.License_Metric_Quantity__c = 5;
            }
            lstopportunityLineItem.add(objopportunityLineItem);
        }
        return lstopportunityLineItem;
    }
            
    Public List<Campaign> CreateCampaign(String Criteria, Integer campaignCount)
    {   
        
        lstCampaign = new List<Campaign>();
        Campaign campaign;
        for(Integer i=0; i<campaignCount; i++) 
        {
            
            campaign = new Campaign();
            
            campaign.Name = 'TestCampaign';
            
            lstCampaign.add(campaign);
        }
        return lstCampaign;
    }
    
    //Creation of Account Address
    Public List<Address__c> CreateAccountAddress(String Criteria, Integer quoteCount, Id accId)
    {   
        
        lstAccountAddress = new List<Address__c>();
        Address__c ObjAddress;
        for(Integer i=0; i<quoteCount; i++) 
        {
            ObjAddress= new Address__c();
            ObjAddress.Account__c= accId;
            ObjAddress.Address_Line_1__c = 'Test Address Line 1';
            ObjAddress.Address_Line_2__c = 'Test Address Line 2 ';
            ObjAddress.City__c ='Test City';
            ObjAddress.State_Province__c = 'State Province';
            ObjAddress.Zip_Postal_Code__c = '0123456';
            lstAccountAddress.add(ObjAddress);
        }
        return lstAccountAddress;
    }

    //Creation of junction object VCG_CPQ_Quote_Product__c
    Public List<VCG_CPQ_Quote_Product__c> CreateQuoteProduct(String Criteria, Integer quoteCount, Id prodId,List<VCG_CPQ_Quote__c> lstQuote)
    {
        lstQuoteProduct = new List<VCG_CPQ_Quote_Product__c>();
        VCG_CPQ_Quote_Product__c objQuoteProduct;
        for(Integer i=0;i<quoteCount; i++)
        {
            objQuoteProduct = new VCG_CPQ_Quote_Product__c ();
            objQuoteProduct.Quote__c = lstQuote[i].id;
            objQuoteProduct.Product__c = prodId;
            //objQuoteProduct.Number_of_Shipment_Forecasts__c = 0;
            objQuoteProduct.Line_Type__c = 'New';
            objQuoteProduct.License_Metric_Quantity__c =1;
            lstQuoteProduct.add(objQuoteProduct);
        }
        return lstQuoteProduct;
    }
    
   Public List<VCG_CPQ_Quote__c> CreateQuote(String Criteria, Integer quoteCount, Id oppId,Id objAddressID)
   {   
        
        lstQuote = new List<VCG_CPQ_Quote__c>();
        VCG_CPQ_Quote__c quote;
        for(Integer i=0; i<quoteCount; i++) 
        {
            
            quote = new VCG_CPQ_Quote__c();
            quote.Opportunity__c= oppId;
            quote.ShippingAddress__c = objAddressID; 
            quote.Invoice_Address__c = objAddressID;
            quote.Is_Primary__c= false;
            if(Criteria == 'salesCompleteCriteria')
            {
                quote.Is_Primary__c= True;
            }
            lstQuote.add(quote);
        }
        return lstQuote;
    }
    
    Public List<Case> CreateCase(String Criteria, Integer caseCount)
    {
        List<Case> lstCase = new List<Case>();
        Case objCase;
        for(Integer i=0;i<caseCount;i++)
        {
            objCase = new case();
            objCase.is_case_being_upgraded__c=False;
            lstCase.add(objCase);
            
        }
        return lstCase;
    }
    
    Public Global_Variable__c blockedUserInsertion(Id blockedUserId)
    {       
        Global_Variable__c OpptyLockBlockedUser = Global_Variable__c.getinstance('OpptyLock_BlockedUsers');
        OpptyLockBlockedUser.value__c = blockedUserId;
        return OpptyLockBlockedUser;
    }
    Public Global_Variable__c allowedFieldInsertion(String AllowedFields)
    {       
        Global_Variable__c OpptyLockAllowedFields = Global_Variable__c.getinstance('OpptyLock_AllowedFields');
        OpptyLockAllowedFields.value__c = AllowedFields;
        return OpptyLockAllowedFields;
    }
    Public Global_Variable__c allowedUserInsertion(String AllowedUserId)
    {       
        Global_Variable__c OpptyLockAllowedUser = Global_Variable__c.getinstance('OpptyLock_AllowedUsers');
        OpptyLockAllowedUser.value__c = AllowedUserId;
        return OpptyLockAllowedUser;
    }
    
    public List<Country_And_Country_Code__c> createCountryAndCountryCode(String criteria, Integer count)
    {  
        lsttestCountryAndCountryCode = new List<Country_And_Country_Code__c>();
        for(Integer i=0; i<count; i++){
              Country_And_Country_Code__c tstCountryAndCountryCode = new Country_And_Country_Code__c();
              if(i==0){
                  tstCountryAndCountryCode.Name = 'Test Country'+system.today();
                  tstCountryAndCountryCode.Region__c = 'APAC';
              }
              if(i==1){
                  tstCountryAndCountryCode.Name = 'Test Country'+system.today()+1;
                  tstCountryAndCountryCode.Region__c = 'LATAM';
              }
              tstCountryAndCountryCode.CurrencyIsoCode = 'USD';
              
              lsttestCountryAndCountryCode.add(tstCountryAndCountryCode);
        }
        return lsttestCountryAndCountryCode;
   }
}