/**
 * Test the VCG_CPQ_Data class
 *
 * @author  Lawrence Coffin <lawrence.coffin@cloudsherpas.com>
 * @since   5.Aug.2014
 */
@isTest
private class VCG_CPQ_Data_Test {

    static testMethod void testInMemoryChildren() {
        VCG_CPQ_Quote__c quote = new VCG_CPQ_Quote__c( );
        
        Product2 prod1 = new Product2( Name = 'Test Product 1', ProductCode = 'Test-111' );
        Product2 prod2 = new Product2( Name = 'Test Product 2', ProductCode = 'Test-222' );
        Product2 prod3 = new Product2( Name = 'Test Product 3', ProductCode = 'Test-333' );
        
        VCG_CPQ_Quote_Product__c qp1 = new VCG_CPQ_Quote_Product__c( Name = 'QP 1', Quote__r = quote, Product__r = prod1 );
        VCG_CPQ_Quote_Product__c qp2 = new VCG_CPQ_Quote_Product__c( Name = 'QP 2', Quote__r = quote, Product__r = prod2 );
        VCG_CPQ_Quote_Product__c qp3 = new VCG_CPQ_Quote_Product__c( Name = 'QP 3', Quote__r = quote, Product__r = prod3 );
        
        // Test adding a single child
        VCG_CPQ_Data.addChild(quote, 'Quote_Products__r', qp1);
        
        // Test adding multiple children
        VCG_CPQ_Data.addChildren(quote, 'Quote_Products__r', new List<VCG_CPQ_Quote_Product__c>{ qp2, qp3 });
        
        // Now test retriving the children
        List<VCG_CPQ_Quote_Product__c> qps = VCG_CPQ_Data.getChildren(quote, 'Quote_Products__r');
        System.assertEquals(3, qps.size());
        System.assertEquals('QP 1', qps[0].Name);
        System.assertEquals('QP 2', qps[1].Name);
        System.assertEquals('QP 3', qps[2].Name);
    }
    
    static testMethod void testFromDatabaseChildren() {
        VCG_CPQ_Quote__c quote = new VCG_CPQ_Quote__c();
        insert quote;
        
        Product2 prod1 = new Product2( Name = 'Test Product 1', ProductCode = 'Test-111' );
        Product2 prod2 = new Product2( Name = 'Test Product 2', ProductCode = 'Test-222' );
        Product2 prod3 = new Product2( Name = 'Test Product 3', ProductCode = 'Test-333' );
        insert new List<Product2>{ prod1, prod2, prod3 };
        
        VCG_CPQ_Quote_Product__c qp1 = new VCG_CPQ_Quote_Product__c( Name = 'QP 1', Quote__c = quote.Id, Product__c = prod1.Id );
        VCG_CPQ_Quote_Product__c qp2 = new VCG_CPQ_Quote_Product__c( Name = 'QP 2', Quote__c = quote.Id, Product__c = prod2.Id );
        VCG_CPQ_Quote_Product__c qp3 = new VCG_CPQ_Quote_Product__c( Name = 'QP 3', Quote__c = quote.Id, Product__c = prod3.Id );
        insert new List<VCG_CPQ_Quote_Product__c>{ qp1, qp2, qp3 };
        
        VCG_CPQ_Quote__c quoteCopy = [
                                        SELECT Id,
                                               Name,
                                               (
                                                    SELECT Id,
                                                           Name,
                                                           Product__c,
                                                           Product__r.Name,
                                                           Product__r.ProductCode
                                                    FROM Quote_Products__r
                                                    ORDER BY Name
                                               )
                                        FROM VCG_CPQ_Quote__c
                                        WHERE Id = :quote.Id
                                     ][0];
        
        // Now test retriving the children
        List<VCG_CPQ_Quote_Product__c> qps = VCG_CPQ_Data.getChildren(quoteCopy, 'Quote_Products__r');
        System.assertEquals(3, qps.size());
        System.assertEquals('QP 1', qps[0].Name);
        System.assertEquals('QP 2', qps[1].Name);
        System.assertEquals('QP 3', qps[2].Name);
    }
    
    /**
     * This tests that the code handles different Quote Product records that have the
     * same Product, but are in different Product Groups.
     *
     * @author  Lawrence Coffin <lawrence.coffin@cloudsherpas.com>
     * @since   5.Aug.2014
     */
    static testMethod void testGroupedProducts() {
        VCG_CPQ_Quote__c quote = new VCG_CPQ_Quote__c( );
        
        Product2 prod = new Product2( Name = 'Test Product', ProductCode = 'Test-123' );
        
        VCG_CPQ_Quote_Product__c qp1 = new VCG_CPQ_Quote_Product__c( Name = 'QP 1', Quote__r = quote, Product__r = prod, Product_Group__c = 'Group 1' );
        VCG_CPQ_Quote_Product__c qp2 = new VCG_CPQ_Quote_Product__c( Name = 'QP 1', Quote__r = quote, Product__r = prod, Product_Group__c = 'Group 2' );
        
        // Test adding multiple children
        VCG_CPQ_Data.addChildren(quote, 'Quote_Products__r', new List<VCG_CPQ_Quote_Product__c>{ qp1, qp2 });
        
        // Now test retriving the children
        List<VCG_CPQ_Quote_Product__c> qps = VCG_CPQ_Data.getChildren(quote, 'Quote_Products__r');
        System.assertEquals(2, qps.size());
        System.assertEquals('QP 1',    qps[0].Name);
        System.assertEquals('Group 1', qps[0].Product_Group__c);
        System.assertEquals('QP 1',    qps[1].Name);
        System.assertEquals('Group 2', qps[1].Product_Group__c);
    }
}