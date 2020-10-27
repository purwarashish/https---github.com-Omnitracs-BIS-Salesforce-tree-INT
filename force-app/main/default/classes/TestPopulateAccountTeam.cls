@isTest(SeeAllData = true)
public class TestPopulateAccountTeam {
    static testmethod void testPopulateAssignedTo() {

      RecordType recType = [SELECT Id FROM RecordType WHERE SObjectType = 'Case' and Name= 'EOX Return'];
      Account AcctId = GenericTestClass.insertAccount();
      Contact contID = GenericTestClass.insertContact(AcctId.Id);
      Account sampleCustomerAcct = [SELECT Id, Name FROM Account where id = : AcctId.Id limit 1];
      Contact sampleContact = [SELECT Id, Name,email FROM Contact where id = :contID.Id limit 1]; 
system.debug('sampleContact:'+sampleContact);
      
      Case case_rec = new Case(
                                  AccountId = sampleCustomerAcct.Id,
                                  ContactId = sampleContact.Id,
                                  RecordTypeId = recType.Id,
                                  Category__c = 'EOX Return',
                                  Type_Level_2__c = 'End of Agreement',
                                  Status = 'Open',
                                  Substatus__c = 'Not Submitted',
                                  Subject = 'Test',
                                  Description = 'Test',
                                  Origin = 'Phone',
                                  Sales_Order_Number__c = '123',
                                  Charge_15_Restocking_Fee__c = 'Yes',
                                  Unused_In_Original_Package__c = 'No',
                                  Original_Shipment_Date__c = System.Today(),
                                  Packslip_Number__c = '123',
                                  Invoice_Number__c = '123',
                                  Credit_Amount__c = 1.00
                                 );
      insert case_rec;
    }
}