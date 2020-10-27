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
@isTest
private class LeadConvertRedirectExtensionNewTest {

   static testmethod void testForNetsuite()
    {
        createTestCountryCode();
        Lead l = new Lead();
        l.firstName = 'test';
        l.lastName = 'test';
        //l.RecordTypeId = '01250000000DSzH'; 
        l.Street = 'street';
        l.City = 'San Diego';
        l.state = 'CA';
        l.PostalCode  = 'TestZip';
        l.Country = 'Canada';
        l.Company = 'Company';
        l.Lead_Origin__c ='Omnitracs Mexico';
        insert l;
        
            Lead testLead = new Lead(   
            firstname = 'testFirstName',
            LastName = 'TestLastName3'
            ,Company = 'Test Company3' 
            ,LeadSource = 'Test Source3'
            ,Market__c = 'Test Market3'
            ,Status = 'SQL' 
            ,RecordTypeId = '01250000000DSzH'
            ,Lead_Origin__c ='Omnitracs Mexico'
            ,Company_Type__c = 'Test Company3'
            , Title = 'Test title3'
            ,Phone = '(234)345-4532'
            /*, District__c = 'Test District3'*/
            , State = 'CA'
            , Country = 'Canada' );
            
        insert testLead;
        
        //ApexPages.StandardController sc = new ApexPages.standardController(l);
        LeadConvertRedirectExtensionNew ext = new LeadConvertRedirectExtensionNew();
        ext.newId = l.id;
        ext.Redirect();
    }
    
     private static void createTestCountryCode()
    {
        Country_And_Country_Code__c ccc = new Country_And_Country_Code__c();
        ccc.name = 'Canada';
        ccc.region__c = 'AMCAN';
        insert ccc;
    }
}