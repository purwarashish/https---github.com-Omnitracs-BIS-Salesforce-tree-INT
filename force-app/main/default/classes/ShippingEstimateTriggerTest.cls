/**
 * Test for the ShippingEstimateTrigger.
 */

@IsTest
private class ShippingEstimateTriggerTest {
    static testMethod void testShippingEstimate() {
        Shipping_Estimate_Summary__c ses = new Shipping_Estimate_Summary__c();
        insert ses;

        Shipping_Estimate__c se = new Shipping_Estimate__c();
        se.Shipping_Summary__c = ses.Id;
        
        Test.startTest();
        insert se;
        Test.stopTest();
    }
}