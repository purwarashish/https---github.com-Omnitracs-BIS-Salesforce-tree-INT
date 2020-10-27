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
private class TestRequestFormController {

    static testMethod void testRequestForm() {
        
        PSAEnhancementTestData objPSAEnhancementTestData= new PSAEnhancementTestData();   
        List<AccountRecordTypes__c> lstRecordType= objPSAEnhancementTestData.customSettingsAccountRecordTypes();
        List<AllAccountUtils__c> lstCustomSettingsAccountUtils= objPSAEnhancementTestData.customSettingsAccountUtils();
        insert lstRecordType;     
        insert lstCustomSettingsAccountUtils;    
        Account accnt=objPSAEnhancementTestData.createAccount(lstRecordType); //insertion of the account record                      
        insert accnt;                
                                    
        Contact cntct=objPSAEnhancementTestData.createContact(accnt.Id);   //insertion of the Contact record  
        insert cntct;  
         
        RequestFormController rfc = new RequestFormController();
        rfc.init();
        
        List<Request_form__c> rfList = [select Id from Request_form__c];
        System.assertEquals(0, rfList.size());
        List<Request_form_Contact__c> rfcList = [select Id from Request_form_Contact__c];
        System.assertEquals(0, rfcList.size());
        
        rfc.requestForm.Primary_reason__c = 'Technology Evaluation: Make v. Buy';
        rfc.requestForm.Request_For_Amendment__c = 'Yes';
        rfc.requestForm.Confidential_Information_Parties__c = 'Just Omnitracs';
        rfc.requestForm.Confidential_Information_Contractors__c = 'Yes';
        rfc.requestForm.Include_affiliates__c = 'Yes';
        
        rfc.requestor.name__c = 'test1';
        rfc.addAdditionalEmployees();
        rfc.additionalEmployees.get(0).name__c = 'test2';
       
        rfc.firstparty.name__c = 'test3';
        rfc.numberOfOtherContacts = 2;
        rfc.addOtherPartyContacts();
        rfc.otherPartyContacts.get(0).first_name__c = cntct.FirstName;
        rfc.otherPartyContacts.get(0).name__c = cntct.LastName;
        rfc.otherPartyContacts.get(0).company__c = accnt.name;
        
        rfc.submit();
        
        rfList = [select Id from Request_form__c];
        System.assertEquals(1, rfList.size());
        rfcList = [select Id from Request_form_Contact__c];
        System.assertEquals(4, rfcList.size());
    }
}