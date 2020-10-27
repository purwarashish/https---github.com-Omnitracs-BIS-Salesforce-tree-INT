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
private class ProvisionAfterTriggerHandlerTest {

    static testMethod void updateContactTest() {
        
        PSAEnhancementTestData tpsaTest = new PSAEnhancementTestData();                                
		
	    List<AccountRecordTypes__c> accntRTList = new List<AccountRecordTypes__c>();
        AccountRecordTypes__c accntRType = new AccountRecordTypes__c();
        accntRType.Name='TL_SALES_ACCOUNT_RECORD_TYPE_ID';
        accntRType.RecordTypeID__c = Schema.SObjectType.Account.getRecordTypeInfosByName().get('T&L Sales Accounts').getRecordTypeId();
        accntRTList.add(accntRType);
        AccountRecordTypes__c accntRType1 = new AccountRecordTypes__c();
        accntRType1.Name='COMPETITOR_RECORD_TYPE_ID';
        accntRType1.RecordTypeID__c = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Competitor').getRecordTypeId();
        accntRTList.add(accntRType1);
        insert accntRTList;
         
        List<AllAccountUtils__c> csaList = tpsaTest.customSettingsAccountUtils();
        insert csaList;
          
       	Account accnt = new Account();                                                             
        accnt.Name='Test Account';
        accnt.Primary_Business_Unit__c='Omnitracs Domestic';
        accnt.Account_Classification__c='Prospect';
        accnt.Account_Status__c='Active';
        accnt.phone='1234567890';
        accnt.QWBS_Status__c='Active';       
        accnt.RecordTypeId= accntRTList[0].RecordTypeID__c;         
        accnt.BillingStreet='Test St';
        accnt.BillingCity='Frisco';
        accnt.BillingState='TX';
        accnt.BillingCountry='USA';  
        insert accnt;
        
        Contract contract1 = new Contract(
            Contract_Category_1__c = 'Master',
            Contract_Category_2__c = 'Professional Services',
            Contract_Status__c = 'Activated',
            AccountId = accnt.Id,
            Term_type__c = 'Fixed',
            StartDate = date.today(),
            Agreement_type__c = 'Individual',
            Contract_Type__c = 'Customer',
            Affiliate_Language__c = 'Yes',                                                 
            Legal_Entity_Name__c ='Omnitracs, LLC'
        );
        insert contract1;
        
        Provision__c prov = new Provision__c(Contract__c = contract1.Id, Price_Increase_Cap__c='5%');
        insert prov;
        
        contract1 = [select Id, Cap_Percentage__c from Contract where Id = :contract1.Id];
        System.assertEquals('5%', contract1.Cap_Percentage__c);
    }
}