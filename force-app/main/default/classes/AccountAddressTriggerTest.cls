@isTest
public class AccountAddressTriggerTest {
    private static VistaAssetHelperUtil util = new VistaAssetHelperUtil();

    @isTest 
    static void testUpdateQuoteAddresses() {
   
		insert new ByPassTrigger__c(SetupOwnerId=UserInfo.getOrganizationId(), isDisabled__c=true, Name='Testing Bypass');
        
        Account account = util.createAccount('ABC Test Account');
        List<Address__c> addressList = new List<Address__c>();
        Address__c addr1 = new Address__c(Address_Line_1__c = 'Test Address',
                                                 City__c = 'Newark',State_Province__c = 'NJ',
                                                 Zip_Postal_Code__c = '07017', Account__c = account.id, Location_Type__c='Shipping Address');  
        
        Address__c addr2 = new Address__c(Address_Line_1__c = 'Test Address1',
                                                 City__c = 'Newark',State_Province__c = 'NJ',
                                                 Zip_Postal_Code__c = '07017', Account__c = account.id, Location_Type__c='Billing Address');  
        
        Address__c addr3 = new Address__c(Address_Line_1__c = 'Test Address2',
                                                 City__c = 'Newark',State_Province__c = 'NJ',
                                                 Zip_Postal_Code__c = '07017', Account__c = account.id, Location_Type__c='Corporate HQ');  
        addressList.add(addr1);
        addressList.add(addr2);
        addressList.add(addr3);
        insert addressList;
        
        List<Product2> productList = new List<Product2>();
        productList.addAll(util.initProductSet(2, 'Hardware', '', 'Fixed Price', 'Monthly'));
        Map<Id, PricebookEntry> pricebookEntries = new Map<Id, PricebookEntry>();
        pricebookEntries = util.initPricebook(productList);
        Opportunity opportunity = util.createNewOpportunity('Test Opportunity 1', account, 'Products, Services and Maintenance', 'New');
        SBQQ__Quote__c sbQuote = util.createSBQuote(opportunity, account, Date.today(), true);
        
        addressList.get(0).Address_Line_1__c = 'test1';
        addressList.get(1).Address_Line_1__c = 'test2';
        addressList.get(2).Address_Line_1__c = 'test3';
        update addressList;
        
    }    
}