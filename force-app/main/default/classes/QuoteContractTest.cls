/*********************************************************************************
Program:        Test Class for QuoteContract Class
Programmer:     Rex David - CloudSherpas
Date:           Oct 02, 2014
**********************************************************************************/ 
@isTest (seeAllData = true)
//create 
//product
//contracted asset 
//quote
private class QuoteContractTest {
    public static List<Account> accountInstance = new List<Account>();
    public static List<Opportunity> lOpportunityInstance = new List<Opportunity>();
    public static List<Product2> lProductInstance   =   new List<Product2>();
    public static List<Asset__c> lContractedAssetInstance   =   new List<Asset__c>();
    public static List<VCG_CPQ_Quote__c> lVCGCPQQuoteInstance   =   new List<VCG_CPQ_Quote__c>();
    public static List<Address__c> lAddressInstance  =   new List<Address__c>();
    
    static{
        Schema.DescribeSObjectResult acccfrSchema = Schema.SObjectType.Account; 
        Map<String,Schema.RecordTypeInfo> AccountRecordTypeInfo = acccfrSchema.getRecordTypeInfosByName();
        Map<String,Schema.RecordTypeInfo> opptyRecTypeInfo = Schema.SObjectType.Opportunity.getRecordTypeInfosByName();
        Id accountRtId = AccountRecordTypeInfo .get('T&L Sales Accounts').getRecordTypeId();
        
        Schema.DescribeSObjectResult oppcfrSchema = Schema.SObjectType.Opportunity; 
        Map<String,Schema.RecordTypeInfo> OpportunityRecordTypeInfo = oppcfrSchema.getRecordTypeInfosByName();
        Id opportunityRtId = OpportunityRecordTypeInfo .get('Products, Services and Maintenance').getRecordTypeId();
        
        for(Integer i=0; i<2; i++){
            Account tempaccountInstance     =   new Account(    Name    =   'testAccount'+i,
                                                    Phone   =   '12345',
                                                    Account_Classification__c   =   'Prospect',
                                                    Account_Status__c   =   'Active',
                                                    Account_Type__c =   'Association',
                                                    recordtypeid    =   accountRtId   
                                            );
            accountInstance.add(tempaccountInstance);
        }
        //try{
            insert accountInstance;         
        /*}
        catch(Exception e){
            System.debug('ERROR '+e);
        }*/
        for(Integer i=0; i<2; i++){
            Address__c add  =   new Address__c();
            add.Account__c  =   accountInstance[i].Id;
            add.Address_Line_1__c   =   'TestAddLine1'+i;
            add.Address_Line_2__c   =   'TestAddLine2'+i;
            add.City__c =   'TestAdd'+i;
            lAddressInstance.add(add);
        }
        //try{
            insert lAddressInstance;
        /*}
        catch(Exception e){
            System.debug('ERROR '+e);
        }*/
                
        for(Integer i=0; i<2; i++){
            Opportunity opp =   new Opportunity();
            opp.Name    =   'testOpp'+i;
            opp.AccountId   =   accountInstance[i].Id;
            opp.CloseDate   =   date.today();
            opp.StageName   =   'Sales Acceptance';
            opp.CurrencyIsoCode =   'USD';
            opp.Type    =   'Existing Customer';
            opp.Sponsor_Letter_Attached__c = true;
            //opp.Sponsor__c = testContact.Id;
            opp.Order_Type__c   =   'Transfer';
            
            if (opptyRecTypeInfo.containsKey('Partner Opportunity (Reseller)')){
                opp.recordtypeid = opptyRecTypeInfo.get('Partner Opportunity (Reseller)').getRecordtypeid();
            }
            lOpportunityInstance.add(opp);
        }
       // try{
            insert lOpportunityInstance;
        /*}
        catch(Exception e){
            System.debug('ERROR '+e);
        }*/
        system.debug('***TESTlOpportunityInstance'+lOpportunityInstance.size());
        for(Integer i=0; i<lOpportunityInstance.size(); i++){
            System.debug('***TESTIteratelOpportunityInstance '+lOpportunityInstance[i].Name);
        }
        
        for(Integer i=0; i<2; i++){
            Product2 prod    =   new Product2();
            prod.Name   =   'testProd'+i;
            prod.CurrencyIsoCode    =   'USD';
            lProductInstance.add(prod);
        }
        //try{
            insert lProductInstance;
        /*}
        catch(Exception e){
            System.debug('ERROR '+e);
        }*/
        for(Integer i=0; i<2; i++){
            Asset__c ass    =   new Asset__c();
            ass.Name    =   'testAss'+i;
            ass.Account__c  =   accountInstance[i].Id;
            ass.CurrencyIsoCode =   'USD';
            ass.License_Metric_Quantity__c  =   1;
            ass.Product__c  =   lProductInstance[i].Id;
            lContractedAssetInstance.add(ass);
        }
        //try{
            insert lContractedAssetInstance;
       /* }
        catch(Exception e){
            System.debug('ERROR '+e);
        }*/
        for(Integer i=0; i<2; i++){
            VCG_CPQ_Quote__c quo    =   new VCG_CPQ_Quote__c();
            quo.Status__c   =   'Draft';
            quo.Account__c  =   accountInstance[i].Id;
            quo.Opportunity__c    =   lOpportunityInstance[i].Id;
            quo.CurrencyIsoCode =   'USD';
            quo.Price_List__c   =   '2014';
            quo.Start_Date__c   =   date.today();
            quo.Expiration_Date__c  =   date.today();
            quo.Effective_Date__c   =   date.today();
            quo.Contract_Term__c    =   36;
            lVCGCPQQuoteInstance.add(quo);
        }
        //try{
            insert lVCGCPQQuoteInstance;
        /*}
        catch(Exception e){
            System.debug('ERROR '+e);
        }*/
        
    }
    private static testMethod void testQuoteContract() {
        system.debug('entered method');
        List<VCG_CPQ_Quote__c> lVCGCPQQuoteInstanceTemp   = new List<VCG_CPQ_Quote__c>();
        for(VCG_CPQ_Quote__c quo : lVCGCPQQuoteInstance){
            VCG_CPQ_Quote__c vquo = new VCG_CPQ_Quote__c();
            vquo.Id  =  quo.Id;
            vquo.Status__c   =   'Approved';
            lVCGCPQQuoteInstanceTemp.add(vquo);
        }
    
        //try{
            update lVCGCPQQuoteInstanceTemp;
            
            //Update opportunity stage to Negotiate
            for(Opportunity oppty : lOpportunityInstance){
                oppty.StageName = 'Negotiate';
            }
            update lOpportunityInstance;
            Opportunity testOpp = [select id, StageName, Primary_Quote_Approval_Status__c from Opportunity where id IN :lOpportunityInstance limit 1];
            system.debug('testOpp: ' + testOpp);
            
            
        /*}
        catch(Exception e){
            System.debug('ERROR '+e);
        }*/
    }
}