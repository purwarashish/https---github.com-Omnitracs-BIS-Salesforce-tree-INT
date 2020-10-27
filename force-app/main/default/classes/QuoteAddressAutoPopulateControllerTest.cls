@isTest(SeeAllData=true)
public with sharing class QuoteAddressAutoPopulateControllerTest {

    public static Account account;
    public static Opportunity opportunity;
    //public static List<AccountRecordTypes__c> accountRecordTypes = new List<AccountRecordTypes__c>();
    public static List<RecordType> recordTypesForAccount = new List<RecordType>();

    static void testSetup() {
        //accountRecordTypes = [SELECT Id, Name FROM AccountRecordTypes__c WHERE Name IN ('TL_SALES_ACCOUNT_RECORD_TYPE_ID', 'CNR_SALES_ACCOUNT_RECORD_TYPE_ID', 'GSS_ACCOUNT_RECORD_TYPE_ID', 'OTHER_ACCOUNT_RECORD_TYPE_ID', 'COMPETITOR_RECORD_TYPE_ID', 'PRTNR_ACNT_RESELLR_RCRD_TYPE_ID')];
        recordTypesForAccount = [SELECT Name, Id From RecordType where sObjectType='Account' and isActive=true];

        account = new Account(Name='Cooler Inc', RecordType=recordTypesForAccount[0], OwnerId = UserInfo.getUserId());
        insert account;
        account = [SELECT Id, Name FROM Account WHERE Id = :account.Id];

        opportunity = new Opportunity(Name='Acme Test Opportunity', AccountId=account.Id, StageName='Develop', CloseDate=Date.newInstance(2018, 8, 15));
        insert opportunity;
        opportunity = [SELECT Id, Name, AccountId, StageName, CloseDate, CurrencyIsoCode FROM Opportunity WHERE Id = :opportunity.Id];

        Test.setCurrentPageReference(new PageReference('QuoteAddressAutoPopulate.page'));
        System.currentPageReference().getParameters().put('oppId', opportunity.Id);
    }

    static testMethod void validateRunTest() {
        testSetup();
        QuoteAddressAutoPopulateController controller = new QuoteAddressAutoPopulateController(new ApexPages.StandardController(opportunity));
        test.startTest();

        PageReference ref = controller.test();

        test.stopTest();
        System.assertEquals(null, ref);
    }

    static testMethod void validatePopulateAddressesNoneOnAccount() {
        testSetup();

        QuoteAddressAutoPopulateController controller = new QuoteAddressAutoPopulateController(new ApexPages.StandardController(opportunity));
        test.startTest();

        PageReference ref = controller.populateAddresses();

        test.stopTest();

        List<SBQQ__Quote__c> quotes = [SELECT Id, Name, Ship_To_Account_Address__c, Bill_To_Account_Address2__c, Corporate_Account_Address__c FROM SBQQ__Quote__c WHERE SBQQ__Opportunity2__c = :opportunity.Id];

        System.debug('Number of quotes: ' + quotes.size());
        SBQQ__Quote__c quote = quotes.get(0);
        System.assertNotEquals(null, ref);
        //System.assertEquals(null, quote.Ship_To_Account_Address__c);
        //System.assertEquals(null, quote.Bill_To_Account_Address2__c);
        //System.assertEquals(null, quote.Corporate_Account_Address__c);
    }

    static testMethod void validatePopulateAddressesAllOnAccount() {
        testSetup();
        List<Address__c> addresses = new List<Address__c>();
        addresses.add(new Address__c(Location_Type__c='Shipping Address', Attention__c='Vanilla', Address_Line_1__c='S-A1A Beachfront Avenue', City__c='Malibu', State_Province__c='CA', Zip_Postal_Code__c='94583', Country__c='US',
                Account__c=account.Id));
        addresses.add(new Address__c(Location_Type__c='Billing Address', Attention__c='Vanilla', Address_Line_1__c='B-A1A Beachfront Avenue', City__c='Malibu', State_Province__c='CA', Zip_Postal_Code__c='94583', Country__c='US',
                Account__c=account.Id));
        addresses.add(new Address__c(Location_Type__c='Corporate HQ', Attention__c='Vanilla', Address_Line_1__c='C-A1A Beachfront Avenue', City__c='Malibu', State_Province__c='CA', Zip_Postal_Code__c='94583', Country__c='US',
                Account__c=account.Id));
        insert addresses;

        QuoteAddressAutoPopulateController controller = new QuoteAddressAutoPopulateController(new ApexPages.StandardController(opportunity));
        test.startTest();

        PageReference ref = controller.populateAddresses();

        test.stopTest();

        List<SBQQ__Quote__c> quotes = [SELECT Id, Name, Ship_To_Account_Address__c, Bill_To_Account_Address2__c, Corporate_Account_Address__c FROM SBQQ__Quote__c WHERE SBQQ__Opportunity2__c = :opportunity.Id];

        System.debug('Number of quotes: ' + quotes.size());
        SBQQ__Quote__c quote = quotes.get(0);
        System.assertNotEquals(null, ref);
        //System.assertEquals(addresses[0].Id, quote.Ship_To_Account_Address__c);
        //System.assertEquals(addresses[1].Id, quote.Bill_To_Account_Address2__c);
        //System.assertEquals(addresses[2].Id, quote.Corporate_Account_Address__c);
    }

    static testMethod void validateCleanupQuote() {
        testSetup();

        SBQQ__Quote__c quote = new SBQQ__Quote__c(SBQQ__Account__c=account.Id);
        quote.SBQQ__Opportunity2__c = opportunity.id;
        insert quote;

        List<SBQQ__Quote__c> returnQuotes = [SELECT Id, Name FROM SBQQ__Quote__c WHERE Id = :quote.Id];
        System.assertEquals(1, returnQuotes.size());

        Test.setCurrentPageReference(new PageReference('QuoteAddressCleanup.page'));
        System.currentPageReference().getParameters().put('oppId', opportunity.Id);
        System.currentPageReference().getParameters().put('quoteId', quote.Id);

        QuoteAddressAutoPopulateController controller = new QuoteAddressAutoPopulateController(new ApexPages.StandardController(opportunity));

        test.startTest();
        controller.cleanupQuote();
        test.stopTest();

        returnQuotes = [SELECT Id, Name FROM SBQQ__Quote__c WHERE Id = :quote.Id];

        System.assertEquals(0, returnQuotes.size());
    }
}