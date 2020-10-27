/**
 * Test for the CustomerAssetShippingEstimateTrigger.
 */

@IsTest
private class CustomerAssetShippingEstimateTriggerTest {
    @testSetup
    static void SetupData() {
        TestUtils.defineCustomSettings();
    }

    static testMethod void test_Dummy() {
        VistaAssetHelperUtil utils = new VistaAssetHelperUtil();
        Account account = utils.createAccount('Test Account');
        Customer_Asset__c asset = new Customer_Asset__c(Account__c=account.Id, Term_Start_Date__c=Date.today());
        insert asset;

        Customer_Asset_Shipping_Summary__c summary = new Customer_Asset_Shipping_Summary__c(Customer_Asset__c=asset.Id);
        insert summary;
        Customer_Asset_Shipping_Estimate__c estimate = new Customer_Asset_Shipping_Estimate__c(Customer_Asset_Shipping_Summary__c=summary.Id);
        insert estimate;

        Test.startTest();
        update estimate;
        Test.stopTest();
    }

    /* ARMAN: static testMethod void createNewCustomerShippingEstimate() {
        ByPassTrigger__c byPassTrigger = new ByPassTrigger__c(SetupOwnerId=UserInfo.getOrganizationId(), isDisabled__c=true, Name='Testing Bypass');
        insert byPassTrigger;

        VistaAssetHelperUtil utils = new VistaAssetHelperUtil();
        Account account = utils.createAccount('Test Account');
        Customer_Asset__c asset = new Customer_Asset__c(Account__c=account.Id, Term_Start_Date__c=Date.today());
        insert asset;

        Customer_Asset_Shipping_Summary__c summary = new Customer_Asset_Shipping_Summary__c(Customer_Asset__c=asset.Id);
        insert summary;

        delete byPassTrigger;

        Customer_Asset_Shipping_Estimate__c estimate = new Customer_Asset_Shipping_Estimate__c(Customer_Asset_Shipping_Summary__c=summary.Id);
        insert estimate;


        Test.startTest();

        estimate.Estimated_Shipping_Date__c = Date.today();
        estimate.Estimated_Shipping_Quantity__c = 100;

        try {
            update estimate;
        } catch(Exception eek) {
            System.debug('Failed to update estimate: ' + eek.getMessage());
        }

        try {
            delete estimate;
        } catch(Exception eek) {
            System.debug('Failed to update estimate: ' + eek.getMessage());
        }
        Test.stopTest();
    }*/
}