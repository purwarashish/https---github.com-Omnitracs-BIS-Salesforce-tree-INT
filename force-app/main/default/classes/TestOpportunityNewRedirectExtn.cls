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

@isTest(SeeAllData= true)
private class TestOpportunityNewRedirectExtn {

    static testmethod void testForInternalUser()
    {
        Account testAccount=new Account(Name='test12',BillingStreet='street',BillingCity='city',BillingState= 'CA', BillingCountry='USA',RecordTypeId='01250000000DQBA');
        insert testAccount;
        Opportunity testOpp=new Opportunity();  
        Map<String, Opportunity_RecType_To_Stage_Mapping__c> allRecTypes = Opportunity_RecType_To_Stage_Mapping__c.getAll();
        RecordType rt =[select id from RecordType where SobjectType='Opportunity' and isActive = true and id NOT IN: allRecTypes.keySet() limit 1 ];  
        Opportunity_RecType_To_Stage_Mapping__c oppStageMapping =  new Opportunity_RecType_To_Stage_Mapping__c();
        oppStageMapping.OpportunityStage__c = 'Sales Accepted (SAL)';
        oppStageMapping.Name =  rt.id;
        ApexPages.currentPage().getParameters().put('RecordType', rt.id);
        ApexPages.currentPage().getParameters().put('retURL', '/006');
        ApexPages.currentPage().getParameters().put('accid', testAccount.id);
        ApexPages.StandardController sc = new ApexPages.standardController(testOpp);
        OpportunityNewRedirectExtn ext = new OpportunityNewRedirectExtn(sc);

        ext.urlRedirect();
    }
    
    static testmethod void testForPartnerUser()
    {
        User u = [select id from User where isActive = true and profileId = '00e500000018kiz' limit 1];
        Opportunity testOpp=new Opportunity();      
        ApexPages.StandardController sc = new ApexPages.standardController(testOpp);
        OpportunityNewRedirectExtn ext = new OpportunityNewRedirectExtn(sc);
        System.runAs(u)
        {
            ext.urlRedirect();
        }   
    }
    
    
}