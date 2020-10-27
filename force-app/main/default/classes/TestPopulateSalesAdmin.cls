@isTest(SeeAllData = true)
public class TestPopulateSalesAdmin {
    static testmethod void testPopulateSalesAdmin() {
        
      Account sampleCustomerAcct = GenericTestClass.insertAccount();
      Contact sampleContact = GenericTestClass.insertContact(sampleCustomerAcct.Id);
      
      Sales_Order_Request__c SOR = new Sales_Order_Request__c(
                                  Account__c = sampleCustomerAcct.Id,
                                  Order_Type__c = 'Eval', 
                                  Contact__c = sampleContact.Id,
                                  Requested_Ship_Date__c = System.Today()
                                 
                                                                   );
      insert SOR;      

    }
}