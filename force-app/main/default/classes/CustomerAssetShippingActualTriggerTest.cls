/**
 * Test for the CustomerAssetShippingEstimateTrigger.
 */

@IsTest
private class CustomerAssetShippingActualTriggerTest {

    static testMethod void createNewCustomerShippingActual() {
        ByPassTrigger__c byPassTrigger = new ByPassTrigger__c(SetupOwnerId=UserInfo.getOrganizationId(), isDisabled__c=true, Name='Testing Bypass');
        insert byPassTrigger;

        VistaAssetHelperUtil utils = new VistaAssetHelperUtil();
        Account account = utils.createAccount('Test Account');
        Customer_Asset__c asset = new Customer_Asset__c(Account__c=account.Id, Term_Start_Date__c=Date.today());
        insert asset;

        Customer_Asset_Shipping_Summary__c summary = new Customer_Asset_Shipping_Summary__c(Customer_Asset__c=asset.Id);
        insert summary;

        delete byPassTrigger;

        Customer_Asset_Shipping_Actual__c actual = new Customer_Asset_Shipping_Actual__c(Customer_Asset_Shipping_Summary__c=summary.Id, Actual_Shipped_Date__c=Date.today(), Actual_Shipped_Quantity__c=50);
        insert actual;

        Test.startTest();

        actual.Actual_Shipped_Date__c = Date.today().addDays(5);
        actual.Actual_Shipped_Quantity__c = 100;

        try {
            update actual;
        } catch(Exception eek) {
            System.debug('Failed to update estimate: ' + eek.getMessage());
        }

        try {
            delete actual;
        } catch(Exception eek) {
            System.debug('Failed to update estimate: ' + eek.getMessage());
        }
        Test.stopTest();
    }
}