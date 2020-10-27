/* ============================================================
 * This code is part of the "apex-lang" open source project avaiable at:
 * 
 *      http://code.google.com/p/apex-lang/
 *
 * This code is licensed under the Apache License, Version 2.0.  You may obtain a 
 * copy of the License at:
 * 
 *      http://www.apache.org/licenses/LICENSE-2.0
 * ============================================================
 *
 */
 //   ARMAN SHAH - Additional tests - 9/24/2018
 //   NOTE:  Must add code from the legacy TestUtils_Test class and delete it.

@IsTest
private class TestUtilsTest {

    @TestSetup
    static void SetupData() {
        TestUtils.defineCustomSettings();
    }
    
    private static testMethod void testAssertConfirmMessagesExist(){
        //test: global static void assertConfirmMessagesExist()
        PageUtils.addConfirm('test');
        TestUtils.assertConfirmMessagesExist();
    }

    private static testMethod void testAssertInfoMessagesExist(){
        //test: global static void assertInfoMessagesExist()
        PageUtils.addInfo('test');
        TestUtils.assertInfoMessagesExist();
    }

    private static testMethod void testAssertWarningMessagesExist(){
        //test: global static void assertWarningMessagesExist()
        PageUtils.addWarning('test');
        TestUtils.assertWarningMessagesExist();
    }

    private static testMethod void testAssertErrorMessagesExist(){
        //test: global static void assertErrorMessagesExist()
        PageUtils.addError('test');
        TestUtils.assertErrorMessagesExist();
    }

    private static testMethod void testAssertFatalMessagesExist(){
        //test: global static void assertFatalMessagesExist()
        PageUtils.addFatal('test');
        TestUtils.assertFatalMessagesExist();
    }

    private static testMethod void testAssertNoConfirmMessagesExist(){
        //test: global static void assertNoConfirmMessagesExist()
        TestUtils.assertNoConfirmMessagesExist();
    }

    private static testMethod void testAssertNoInfoMessagesExist(){
        //test: global static void assertNoInfoMessagesExist(){ assertNoMessagesAtLevelExist(ApexPages.Severity.INFO); }
        TestUtils.assertNoInfoMessagesExist();
    }

    private static testMethod void testAssertNoWarningMessagesExist(){
        //test: global static void assertNoWarningMessagesExist(){ assertNoMessagesAtLevelExist(ApexPages.Severity.WARNING); }
        TestUtils.assertNoWarningMessagesExist();
    }

    private static testMethod void testAssertNoErrorMessagesExist(){
        //test: global static void assertNoErrorMessagesExist(){ assertNoMessagesAtLevelExist(ApexPages.Severity.ERROR); }
        TestUtils.assertNoErrorMessagesExist();
    }

    private static testMethod void testAssertNoFatalMessagesExist(){
        //test: global static void assertNoFatalMessagesExist(){ assertNoMessagesAtLevelExist(ApexPages.Severity.FATAL); }
        TestUtils.assertNoFatalMessagesExist();
    }
    
    private static testMethod void testGetObjectAcct(){
//        Map<String,String> values = new Map<String,String>();
//        values.put('name','Account xyz');
//        List<SObject> records = TestUtils.getObject(new Account(), 2, values);
//        System.assertEquals(2,records.size());
//        for(SObject record : records){
//            System.assertEquals('Account xyz',record.get('name'));
//        }
    }
    
    private static testMethod void testGetObjectContact(){
//        Map<String,String> values = new Map<String,String>();
//        values.put('LastName','Account xyz');
//        List<SObject> records = TestUtils.getObject(new Contact(), 2, values);
//        System.assertEquals(2,records.size());
//        for(SObject record : records){
//            System.assertEquals('Account xyz',record.get('LastName'));
//        }
    }
    
    private static testMethod void testGetObjectDoInsert(){
        //test doInsert == false
//        List<SObject> records = TestUtils.getObject(new Account(), 2);
//        System.assertEquals(2,records.size());
//        for(SObject record : records){
//            System.assertEquals(null,record.get('id'));
//        }

        //test doInsert == true
//        Map<String,String> values = new Map<String,String>();
//        values.put('name','Account xyz');
//        records = TestUtils.getObject(new Account(), 2, values, true);
//        Set<Id> idSet = new Set<Id>();
//        for(SObject record : records){
//            System.assertEquals('Account xyz',record.get('name'));
//            idSet.add((Id)record.get('id'));
//        }
//        records = [select id from Account where id in :idSet];
//        System.assertEquals(2,records.size());
    }
    
    private static testMethod void testGetObjectBadInput(){
        System.assertEquals(null,TestUtils.getObject(null, -1, null, true));
        System.assertEquals(null,TestUtils.getObject(null, 2, null, true));
        System.assert(TestUtils.getObject(new Account(), -1, null, true).isEmpty());
        System.assert(TestUtils.getObject(new Account(), 0, null, true).isEmpty());
    }
    
    private static testMethod void test_assertUrlsAreEqual(){
        //test: global static void assertUrlsAreEqual(String expected, String actual){
        TestUtils.assertUrlsAreEqual('http://google.com','http://google.com');
        TestUtils.assertUrlsAreEqual('http://google.com?x=1&y=2','http://google.com?y=2&x=1');
    }

    /******************************************************/
    //       ARMAN SHAH - Additional tests - 9/24/2018
    /******************************************************/

    private static testMethod void testGetAccount() {
        Account a = TestUtils.getAccount('acct1');
        System.assertEquals('acct1', a.Name);
    }

    private static testMethod void testGetContact() {
        Account a = TestUtils.getAccount('acct1');
        insert a;
        Contact con = TestUtils.getContact(a);
        insert con;
        Contact con2 = [SELECT Id, AccountId FROM Contact];
        System.assertEquals(a.Id, con2.AccountId);
    }

    private static testMethod void testGetContract() {
        Account a = TestUtils.getAccount('acct1');
        Contract c = TestUtils.getContract(a);
        System.assertEquals('Omnitracs, LLC', c.Legal_Entity_Name__c);
    }

    private static testMethod void testGetProduct() {
        Product2 p = TestUtils.getProduct('Test 1');
        System.assertEquals(true, p.isActive);
    }

    private static testMethod  void testGetProductFamilyName() {
        Product2 p = TestUtils.getProduct('Prod 1', 'ProdFamily 1');
        System.assertEquals('ProdFamily 1', p.family);
    }

    private static testMethod void testGetOpportunity() {
        Account a = TestUtils.getAccount('acct1');
        insert a;
        Opportunity opp = TestUtils.getOpportunity(a, 'Opp 1');
        insert opp;
        System.assertEquals('Opp 1', opp.Name);
    }

    private static testMethod void testGetStandardPricebook() {
        Pricebook2 pb = TestUtils.getStandardPriceBook();
        System.assert(pb != null);
    }

    private static testMethod void testGetPricebookEntry() {
        Product2 p = TestUtils.getProduct('Prod 1', 'ProdFamily 1');
        insert p;
        Pricebook2 pb = TestUtils.getStandardPriceBook();
        PricebookEntry pbe = TestUtils.getPriceBookEntry(p, pb);
        System.assertEquals(true, pbe.isActive);
    }

    private static testMethod void testGetOLI() {
        Account a = TestUtils.getAccount('acct1');
        insert a;
        Opportunity opp = TestUtils.getOpportunity(a, 'Opp 1');
        insert opp;
        OpportunityLineItem oli = TestUtils.getOLI(opp);
        System.assert(oli != null);
    }

    private static testMethod void testGetOLI_OppProduct() {
        Account a = TestUtils.getAccount('acct1');
        insert a;
        Opportunity opp = TestUtils.getOpportunity(a, 'Opp 1');
        insert opp;
        Product2 p = TestUtils.getProduct('Test 1');
        insert p;
        OpportunityLineItem oli = TestUtils.getOLI(opp, p);
        System.assert(oli != null);
    }

    private static testMethod void testGetCase() {
        Case case1 = TestUtils.getCase();
        System.assert(case1 != null);
    }

    private static testMethod void testGetCase_AcctContact() {
        Account a = TestUtils.getAccount('acct1');
        insert a;
        Contact con = TestUtils.getContact(a);
        insert con;
        Case case1 = TestUtils.getCase(a, con);
        System.assert(case1 != null);
    }

    private static testMethod void testGetAsset_AcctProduct() {
        Account a = TestUtils.getAccount('acct1');
        insert a;
        Product2 p = TestUtils.getProduct('Test 1');
        insert p;
        Asset__c asset = TestUtils.getAsset(a, p);
        System.assert(asset != null);
    }

    private static testMethod void testGetAsset_AcctProductContract() {
        Account a = TestUtils.getAccount('acct1');
        insert a;
        Product2 p = TestUtils.getProduct('Test 1');
        insert p;
        Contract con = TestUtils.getContract(a);
        insert con;
        Asset__c asset = TestUtils.getAsset(a, p, con);
        System.assert(asset != null);
    }

    private static testMethod void testGetAsset_AcctProductQty() {
        Account a = TestUtils.getAccount('acct1');
        insert a;
        Product2 p = TestUtils.getProduct('Test 1');
        insert p;
        Asset__c asset = TestUtils.getAsset(a, p, 10.5);
        System.assert(asset != null);
    }

    private static testMethod void testGetAsset_AcctProductContractQty() {
        Account a = TestUtils.getAccount('acct1');
        insert a;
        Product2 p = TestUtils.getProduct('Test 1');
        insert p;
        Contract con = TestUtils.getContract(a);
        insert con;
        Asset__c asset = TestUtils.getAsset(a, p, con, 1.23);
        System.assert(asset != null);
    }

    private static testMethod void testCreateContact() {
        Account acc = testutils.getaccount('Test Acc');
        insert Acc;
        List<Contact> contacts = TestUtils.createContact(5,Acc.id);
        System.assertEquals(5, contacts.size());
    }
}