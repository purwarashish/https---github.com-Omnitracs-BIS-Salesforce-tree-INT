@isTest(SeeAllData=true)
private class TestUtils_Test {

    static testMethod void testOLIs() {
        Account a = TestUtils.getAccount('Test');
        insert a;
        
        //Added by JBarrameda - 10/30/2014
        Id oldProdRecType = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Products, Services and Maintenance').getRecordTypeId();
        Opportunity o = TestUtils.getOpportunity(a, 'Test');
        o.StageName='Sales Acceptance';                    //Added by JBarrameda - 10/30/2014
        insert o;
        
        OpportunityLineItem oli = TestUtils.getOLI(o);
        
        Product2 p = TestUtils.getProduct('Test Prod');
        insert p;
        
        OpportunityLineItem oli2 = TestUtils.getOLI(o, p);
    }
    
    
    static testMethod void testGetCase() {
        Case c = TestUtils.getCase();
    }
}