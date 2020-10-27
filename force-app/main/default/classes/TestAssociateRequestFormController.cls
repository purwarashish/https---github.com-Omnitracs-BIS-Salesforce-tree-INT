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
private class TestAssociateRequestFormController {

    static testMethod void associateAccountsContactsTest() {
        PSAEnhancementTestData objPSAEnhancementTestData= new PSAEnhancementTestData();   
        List<AccountRecordTypes__c> lstRecordType= objPSAEnhancementTestData.customSettingsAccountRecordTypes();
        List<AllAccountUtils__c> lstCustomSettingsAccountUtils= objPSAEnhancementTestData.customSettingsAccountUtils();
        insert lstRecordType;     
        insert lstCustomSettingsAccountUtils;    
        Account accnt=objPSAEnhancementTestData.createAccount(lstRecordType); //insertion of the account record 
        accnt.Segment__c = 'Services';                     
        insert accnt;                
                                    
        Contact cntct=objPSAEnhancementTestData.createContact(accnt.Id);   //insertion of the Contact record  
        insert cntct;  
         
        Map<String,Schema.RecordTypeInfo> rtMapByName = Schema.SObjectType.Request_Form_Contact__c.getRecordTypeInfosByName();
        
        Request_Form__c rf = new Request_Form__c();
        rf.Primary_reason__c = 'Technology Evaluation: Make v. Buy';
        rf.Request_For_Amendment__c = 'Yes';
        rf.Confidential_Information_Parties__c = 'Just Omnitracs';
        rf.Confidential_Information_Contractors__c = 'Yes';
        rf.Include_affiliates__c = 'Yes';
        insert rf;
        
        Request_Form_Contact__c rfc = new Request_Form_Contact__c();
        rfc.recordTypeId=rtMapByName.get('Multi Party').getRecordTypeId();
        rfc.Multiparty__c = rf.Id;
        rfc.company__c = accnt.Name;
        rfc.First_name__c = 'Test';
        rfc.name__c = 'RFC1';
        rfc.Request_Type__c = 'NDA';
        rfc.Street_1__c = 'Test Street 1';
        rfc.City__c = 'Frisco';
        rfc.State_Province_PL__c = 'TX';
        rfc.Zipcode__c = '75035';
        rfc.Type__c = 'First Party';
        rfc.Account_associated__c = accnt.Id;
        rfc.contact_associated__c = cntct.Id;
        
        Request_Form_Contact__c rfc1 = new Request_Form_Contact__c();
        rfc1.recordTypeId=rtMapByName.get('Multi Party').getRecordTypeId();
        rfc1.Multiparty__c = rf.Id;
        rfc1.company__c = accnt.Name;
        rfc1.First_name__c = 'Test';
        rfc1.name__c = 'RFC2';
        rfc1.Request_Type__c = 'NDA';
        rfc1.Street_1__c = 'Test Street 1';
        rfc1.City__c = 'Frisco';
        rfc1.State_Province_PL__c = 'TX';
        rfc1.Zipcode__c = '75035';
        rfc1.Type__c = 'First Party';
        rfc1.To_Create__c = true;
        
        Request_Form_Contact__c rfc2 = new Request_Form_Contact__c();
        rfc2.recordTypeId=rtMapByName.get('Multi Party').getRecordTypeId();
        rfc2.Multiparty__c = rf.Id;
        rfc2.company__c = accnt.Name;
        rfc2.First_name__c = 'Test';
        rfc2.name__c = 'RFC3';
        rfc2.Request_Type__c = 'NDA';
        rfc2.Street_1__c = 'Test Street 1';
        rfc2.City__c = 'Frisco';
        rfc2.State_Province_PL__c = 'TX';
        rfc2.Zipcode__c = '75035';
        rfc2.Type__c = 'First Party';
        rfc.Account_associated__c = accnt.Id;
        rfc2.To_Create__c = true;
        
        List<Request_Form_Contact__c> rfcList = new List<Request_Form_Contact__c> {rfc, rfc1, rfc2};
        insert rfcList;
        
        AssociateRequestFormController arfc = new AssociateRequestFormController(new Apexpages.StandardController(rf)); 
        List<Account> accntList = [select Id from Account];
        List<Contact> cntctList = [select Id from Contact];
        System.assertEquals(1, accntList.size());
        System.assertEquals(1, cntctList.size());
        arfc.createAccountRFC();
        accntList = [select Id from Account];
       // System.assertEquals(3, accntList.size());
        
        Request_Form_Contact__c rfcTemp = [select Id,Account_associated__c, Contact_associated__c from Request_Form_Contact__c where Id = :rfcList.get(0).Id];
        System.assert(rfcTemp.Account_associated__c != null);
        
        arfc.createContactRFC();
        cntctList = [select Id from Contact];
      //  System.assertEquals(3, accntList.size());
        
        arfc.updateAccountRFC();
        arfc.updateContactRFC();
        arfc.cancel();
        
    }
}