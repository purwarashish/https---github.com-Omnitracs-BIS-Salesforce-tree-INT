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
@isTest(SeeAllData=True)
private class QES_NCIS_SendEmailTest {

    static testMethod void validTestCase() {
         
        
        //Query the partner portal record type
  List<RecordType> partnerRecordType=[select Id
                                           , Name
                                       from  RecordType
                                       where Name='Partner CIS'
                                       Limit 1
                                     ];
        Test.startTest();
                                     
        // TO DO: implement unit test
        Account accountInstance=new Account();
        accountInstance.name='Test Account Name';
        accountInstance.phone='5643442333';
        //accountInstance.District__c='Canada';
        accountInstance.BillingStreet='Test Street';
        accountInstance.BillingCity='Test City';
        accountInstance.BillingState='NC';
        accountInstance.BillingPostalCode='23233';
        accountInstance.Account_Type__c='Association';
        insert accountInstance;
        
         Contact contactInstance=new Contact(FirstName='Test Contact', LastName='Test Last Name');
         contactInstance.AccountId=accountInstance.id;
        insert contactInstance; 
        
        
        
        Customer_Information_Sheet__c cisSheet=new Customer_Information_Sheet__c();
        cisSheet.Account__c=accountInstance.Id;
        cisSheet.RecordTypeId=partnerRecordType.get(0).Id;
        cisSheet.No_6_pin_Units_Sold_PP804879__c=2;
        cisSheet.Installer_Contact__c=contactInstance.id;
        insert cisSheet;
        
        Apexpages.Standardcontroller ncisStdController=new Apexpages.Standardcontroller(cisSheet);
        
        QES_NCIS_SendEmail sendEmailController=new QES_NCIS_SendEmail(ncisStdController);
        sendEmailController.updateEmailFields();
        
        Customer_Information_Sheet__c cisSheetUpdated=[select Id, Email_Status__c,Trigger_Email__c, Name from Customer_Information_Sheet__c where Id=:cisSheet.Id Limit 1];
        
        Test.stopTest();
        
        System.assertEquals('Sent to PANA', cisSheetUpdated.Email_Status__c);
        //false updated by the workflow rule
        System.assertEquals(false, cisSheetUpdated.Trigger_Email__c);
        
        
    }
    
     static testMethod void inValidTestCase() {
              //Query the partner portal record type
  List<RecordType> partnerRecordType=[select Id
                                           , Name
                                       from  RecordType
                                       where Name='Partner CIS'
                                       Limit 1
                                     ];
        Test.startTest();
                                     
        // TO DO: implement unit test
        Account accountInstance=new Account();
        accountInstance.name='Test Account Name';
        accountInstance.phone='5643442333';
        //accountInstance.District__c='Canada';
        accountInstance.BillingStreet='Test Street';
        accountInstance.BillingCity='Test City';
        accountInstance.BillingState='NC';
        accountInstance.BillingPostalCode='23233';
        accountInstance.Account_Type__c='Association';
        insert accountInstance;
        
         Contact contactInstance=new Contact(FirstName='Test Contact', LastName='Test Last Name');
         contactInstance.AccountId=accountInstance.Id;
        insert contactInstance; 
        
        Customer_Information_Sheet__c cisSheet=new Customer_Information_Sheet__c();
        cisSheet.Account__c=accountInstance.Id;
        cisSheet.RecordTypeId=partnerRecordType.get(0).Id;
        cisSheet.No_6_pin_Units_Sold_PP804879__c=2;
        cisSheet.Installer_Contact__c=contactInstance.id;
        insert cisSheet;
        
        Apexpages.Standardcontroller ncisStdController=new Apexpages.Standardcontroller(cisSheet);
        
        QES_NCIS_SendEmail sendEmailController=new QES_NCIS_SendEmail(ncisStdController);
        sendEmailController.simualteDBError=true;
         sendEmailController.updateEmailFields();
        
        Customer_Information_Sheet__c cisSheetUpdated=[select Id, Email_Status__c,Trigger_Email__c, Name from Customer_Information_Sheet__c where Id=:cisSheet.Id Limit 1];
        
         //exception status updated
         System.assertEquals('Exception', cisSheetUpdated.Email_Status__c);
          
        
     }
}