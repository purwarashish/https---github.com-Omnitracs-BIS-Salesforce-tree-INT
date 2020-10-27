/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class VCG_CPQ_ProductUtility_Test { 

    static testMethod void testGetAddonProducts() {

        /*************************************************
        *   Test General Use Case
        **************************************************/
        List<Product2> prodList = new List<Product2>();
        prodList.add(new Product2(Name = 'Product0', Family = 'Web', License_Metric__c = 'Seat', IsActive = true));
        prodList.add(new Product2(Name = 'Product1', Family = 'Web', License_Metric__c = 'Seat', IsActive = true));
        prodList.add(new Product2(Name = 'Product2', Family = 'Web', License_Metric__c = 'Seat', IsActive = true));
        prodList.add(new Product2(Name = 'Product3', Family = 'Web', License_Metric__c = 'Seat', IsActive = true));
        prodList.add(new Product2(Name = 'Product4', Family = 'Web', License_Metric__c = 'Seat', IsActive = true));
        prodList.add(new Product2(Name = 'Product5', Family = 'Web', License_Metric__c = 'Seat', IsActive = true));
        insert prodList;
        
        List<VCG_CPQ_Product_Addon__c> addons = new List<VCG_CPQ_Product_Addon__c>();
        addons.add(new VCG_CPQ_Product_Addon__c(Product__c = prodList[0].Id, Product_Addon__c = prodList[1].Id, Required__c = '1'));
        addons.add(new VCG_CPQ_Product_Addon__c(Product__c = prodList[0].Id, Product_Addon__c = prodList[2].Id, Required__c = '0'));
        insert addons;        
        
        VCG_CPQ_Quote__c testQuote = new VCG_CPQ_Quote__c(); // Name = 'Test Quote');
        insert testQuote;
        
        VCG_CPQ_Product_Incompatibility__c incompat = new VCG_CPQ_Product_Incompatibility__c(Product_1__c = prodList[1].Id, Product_2__c = prodList[2].Id, Scope__c='Grouping');
        insert incompat;
        
        

        VCG_CPQ_Quote_Product__c quoteProduct = new VCG_CPQ_Quote_Product__c(Name='quoteProd1', License_Metric_Quantity__c=5, Quote__c = testQuote.Id, Product__c = prodList[0].Id, Product_Group__c = 'G1');
        
        List<VCG_CPQ_Quote_Product__c> selectedCoreProds = new List<VCG_CPQ_Quote_Product__c>();        
        selectedCoreProds.add(quoteProduct);
        
        List<VCG_CPQ_Product_Addon_Wrapper> addonsAvailable = VCG_CPQ_ProductUtility.getAddonProducts(selectedCoreProds);

        System.debug('Addon Returned: ' + addonsAvailable);
        
        System.assert(!addonsAvailable.isEmpty());
        System.assertEquals(addonsAvailable.size(), 2);
        for(VCG_CPQ_Product_Addon_Wrapper addon : addonsAvailable){
            if(addon.addonProduct.Name == 'Product1'){
                System.assertEquals(addon.required, true);
            }
        }       
        
        /*************************************************
        *   Test Incompatibility Product Addon Use Cases
        *************************************************/
        selectedCoreProds.add(new VCG_CPQ_Quote_Product__c(Name='quoteProd2', License_Metric_Quantity__c=5, Quote__c = testQuote.Id, Product__c = prodList[1].Id, Product_Group__c = 'G1'));
        
        addonsAvailable.clear();
        addonsAvailable = VCG_CPQ_ProductUtility.getAddonProducts(selectedCoreProds);
        
        System.debug('Addon Returned: ' + addonsAvailable);
        System.assertEquals(addonsAvailable.size(), 2);     
        for(VCG_CPQ_Product_Addon_Wrapper addon : addonsAvailable){
            if(addon.addonProduct.Name == 'Product2'){
                System.assertEquals(addon.compatible, false);
            }
        }       
        
        
        
        /*************************************************
        *   Test Product Addon Group Use Cases
        *************************************************/
        //Use case: only 1 primary from a group of 2 has been added :: the associated addon should not be available
        selectedCoreProds.add(new VCG_CPQ_Quote_Product__c(Name='quoteProd3', License_Metric_Quantity__c=5, Quote__c = testQuote.Id, Product__c = prodList[3].Id, Product_Group__c = 'G1'));
        addonsAvailable.clear();
        addonsAvailable = VCG_CPQ_ProductUtility.getAddonProducts(selectedCoreProds);
        System.debug('addons available: ' + addonsAvailable);
        System.assertEquals(addonsAvailable.size(), 2);
        
/** @todo  Re-enable this test if it is needed. I'm not sure why it is expecting 4 records when only 2 add-on records are defined. -LC 2014-12-05       
        //Use case: all primaries from a group of 2 have been added :: the associated addon should be available
        selectedCoreProds.add(new VCG_CPQ_Quote_Product__c(Name='quoteProd4', License_Metric_Quantity__c=5, Quote__c = testQuote.Id, Product__c = prodList[4].Id, Product_Group__c = 'G1'));
        addonsAvailable.clear();
        addonsAvailable = VCG_CPQ_ProductUtility.getAddonProducts(selectedCoreProds);
        System.debug('addons available: ' + addonsAvailable);
        System.assertEquals(addonsAvailable.size(), 4);
*/
    }



        /*************************************************
        *   Test Product Dependency Use Cases
        *************************************************/
    static testMethod void testProductDependencyValidation() {
        
        Product2 product = new Product2();
        Product2 dependsOnProduct = new Product2();

        product.Name = 'Product';
        product.Family = 'Web';
        product.License_Metric__c = 'Seat';
        product.IsActive = true;
        
        dependsOnProduct.Name = 'Depends On Product';
        dependsOnProduct.Family = 'Web';
        dependsOnProduct.License_Metric__c = 'Seat';
        dependsOnProduct.IsActive = true;
        
        List<Product2> prodList = new List<Product2>();
        prodList.add(product);
        prodList.add(dependsOnProduct);
        insert prodList;
        
        System.debug('Prod ID: ' + prodList[0].Id);
        System.debug('Depends On Prod ID: ' + prodList[1].Id);          
        
        
        //QUOTE LEVEL TEST
        
        VCG_CPQ_Product_Rule__c productRule = new VCG_CPQ_Product_Rule__c();
        productRule.Product__c = prodList[0].Id;
        productRule.Depends_On__c = prodList[1].Id;
        productRule.Scope__c = 'Quote';
        productRule.Condition__c = '1';
        insert productRule;
        
        List<VCG_CPQ_Quote_Product__c> selectedCoreProds = new List<VCG_CPQ_Quote_Product__c>();
        VCG_CPQ_Quote__c testQuote = new VCG_CPQ_Quote__c();
//        testQuote.Name = 'Test Quote';
        insert testQuote;
        
        //Missing required primary product
        List<VCG_CPQ_Quote_Product__c> selectedProds = new List<VCG_CPQ_Quote_Product__c>();
        VCG_CPQ_Quote_Product__c quoteProduct = new VCG_CPQ_Quote_Product__c(Name='quoteProd1', License_Metric_Quantity__c=5, Product_Group__c='Group1', Quote__c = testQuote.Id, Product__c = prodList[0].Id);
        insert quoteProduct;
        
        selectedProds.add(quoteProduct);
        
        List<VCG_CPQ_Error> errors = new List<VCG_CPQ_Error>();
        errors = VCG_CPQ_ProductUtility.validateProductSelection(testQuote, selectedProds);
        
        //Assert error thrown for missing primary product
        System.assert(!errors.isEmpty());
        System.debug('\n\n' + errors + '\n');
        
        //Add required primary product
        VCG_CPQ_Quote_Product__c quoteProduct2 = new VCG_CPQ_Quote_Product__c(Name='quoteProd2', License_Metric_Quantity__c=5, Product_Group__c='Group2', Quote__c = testQuote.Id, Product__c = prodList[1].Id);
        selectedProds.add(quoteProduct2);
        
        errors.clear();
        errors  = VCG_CPQ_ProductUtility.validateProductSelection(testQuote, selectedProds);

        //Assert no errors are thrown
        System.debug('\n\n' + errors + '\n');
        System.assert(errors.isEmpty());
        
        
        
        //GROUP LEVEL TEST
        
        VCG_CPQ_Product_Rule__c productRule2 = new VCG_CPQ_Product_Rule__c();
        productRule2.Product__c = prodList[0].Id;
        productRule2.Depends_On__c = prodList[1].Id;
        productRule2.Scope__c = 'Grouping';
        productRule2.Condition__c = '1';
        insert productRule2;
        
        errors.clear();
        errors  = VCG_CPQ_ProductUtility.validateProductSelection(testQuote, selectedProds);        

        //Assert error thrown for missing primary product
        System.assert(!errors.isEmpty());
        System.debug('\n\n' + errors + '\n');
        
                
        //Add required primary product in group
        VCG_CPQ_Quote_Product__c quoteProduct3 = new VCG_CPQ_Quote_Product__c(Name='quoteProd3', License_Metric_Quantity__c=5, Product_Group__c='Group1', Quote__c = testQuote.Id, Product__c = prodList[1].Id);
        selectedProds.add(quoteProduct3);

        errors.clear();
        errors  = VCG_CPQ_ProductUtility.validateProductSelection(testQuote, selectedProds);
        
        //Assert no error
        System.debug('\n\n' + errors + '\n');
        System.assert(errors.isEmpty());
    }




    /*************************************************
    *   Test Quantity Group Use Cases
    **************************************************/
    static testMethod void testProductQuantityGroupValidation() {
        
        Product2 product = new Product2(Name = 'Product0', Family = 'Web', License_Metric__c = 'Seat', IsActive = true);
        Product2 product1 = new Product2(Name = 'Product1', Family = 'Web', License_Metric__c = 'Seat', IsActive = true);
        Product2 product2 = new Product2(Name = 'Product2', Family = 'Web', License_Metric__c = 'Seat', IsActive = true);
        Product2 product3 = new Product2(Name = 'Product3', Family = 'Web', License_Metric__c = 'Seat', IsActive = true);
        Product2 product4 = new Product2(Name = 'Product4', Family = 'Web', License_Metric__c = 'Seat', IsActive = true);
        Product2 product5 = new Product2(Name = 'Product5', Family = 'Web', License_Metric__c = 'Seat', IsActive = true);
        
        List<Product2> prodList = new List<Product2>();
        prodList.add(product);
        prodList.add(product1);
        prodList.add(product2);
        prodList.add(product3);
        prodList.add(product4);
        insert prodList;
        
        List<VCG_CPQ_Product_Rule__c> productRules = new List<VCG_CPQ_Product_Rule__c>(); 
        productRules.add(new VCG_CPQ_Product_Rule__c(Product__c = prodList[0].Id, Depends_On__c = prodList[2].Id, Scope__c = 'Grouping', Quantity_Group__c = 'Group1', Condition__c = '1'));
        productRules.add(new VCG_CPQ_Product_Rule__c(Product__c = prodList[1].Id, Depends_On__c = prodList[2].Id, Scope__c = 'Grouping', Quantity_Group__c = 'Group1', Condition__c = '1'));
        productRules.add(new VCG_CPQ_Product_Rule__c(Product__c = prodList[4].Id, Depends_On__c = prodList[3].Id, Scope__c = 'Quote', Quantity_Group__c = 'Group2', Condition__c = '1'));
        
        insert productRules;
        
        VCG_CPQ_Quote__c testQuote = new VCG_CPQ_Quote__c();
//        testQuote.Name = 'Test Quote';
        insert testQuote;
        
        //Missing required primary product
        List<VCG_CPQ_Quote_Product__c> selectedProds = new List<VCG_CPQ_Quote_Product__c>();
        selectedProds.add(new VCG_CPQ_Quote_Product__c(Name='quoteProd1', License_Metric_Quantity__c=3, Quote__c = testQuote.Id, Product__c = prodList[0].Id, Product_Group__c = 'G1'));
        selectedProds.add(new VCG_CPQ_Quote_Product__c(Name='quoteProd3', License_Metric_Quantity__c=5, Quote__c = testQuote.Id, Product__c = prodList[2].Id, Product_Group__c = 'G1'));        

        List<VCG_CPQ_Error> errors = new List<VCG_CPQ_Error>();
        errors = VCG_CPQ_ProductUtility.validateProductSelection(testQuote, selectedProds);
        
        //Assert error thrown for invalid quantity
        System.debug('\n\n' + errors + '\n');
        System.assert(!errors.isEmpty());
        
        selectedProds.add(new VCG_CPQ_Quote_Product__c(Name='quoteProd2', License_Metric_Quantity__c=2, Quote__c = testQuote.Id, Product__c = prodList[1].Id, Product_Group__c = 'G1'));
        
        errors.clear();
        errors = VCG_CPQ_ProductUtility.validateProductSelection(testQuote, selectedProds);
        
        //Errors resolved
        System.debug('\n\n' + errors + '\n');
        System.assert(errors.isEmpty());        



        //QUOTE SCOPE//
        selectedProds.add(new VCG_CPQ_Quote_Product__c(Name='quoteProd4', License_Metric_Quantity__c=5, Quote__c = testQuote.Id, Product__c = prodList[4].Id, Product_Group__c = 'G3'));
                
        errors.clear();
        errors = VCG_CPQ_ProductUtility.validateProductSelection(testQuote, selectedProds);
        
        //Assert error thrown for invalid quantity
        System.debug('\n\n' + errors + '\n');
        System.assert(!errors.isEmpty());


        selectedProds.add(new VCG_CPQ_Quote_Product__c(Name='quoteProd5', License_Metric_Quantity__c=5, Quote__c = testQuote.Id, Product__c = prodList[3].Id, Product_Group__c = 'G4'));

        errors.clear();
        errors = VCG_CPQ_ProductUtility.validateProductSelection(testQuote, selectedProds);
        
        //Assert errors resolved
        System.debug('\n\n' + errors + '\n');
        System.assert(errors.isEmpty());

    }
    
    
    /*************************************************
    *   Test Option Group Use Cases
    **************************************************/
    static testMethod void testProductOptionGroupValidation() {
        
        Product2 product = new Product2(Name = 'Product0', Family = 'Web', License_Metric__c = 'Seat', IsActive = true);
        Product2 product1 = new Product2(Name = 'Product1', Family = 'Web', License_Metric__c = 'Seat', IsActive = true);
        Product2 product2 = new Product2(Name = 'Product2', Family = 'Web', License_Metric__c = 'Seat', IsActive = true);
        Product2 product3 = new Product2(Name = 'Product3', Family = 'Web', License_Metric__c = 'Seat', IsActive = true);
        Product2 product4 = new Product2(Name = 'Product4', Family = 'Web', License_Metric__c = 'Seat', IsActive = true);
        Product2 product5 = new Product2(Name = 'Product5', Family = 'Web', License_Metric__c = 'Seat', IsActive = true);
        
        List<Product2> prodList = new List<Product2>();
        prodList.add(product);
        prodList.add(product1);
        prodList.add(product2);
        prodList.add(product3);
        prodList.add(product4);
        prodList.add(product5);
        insert prodList;
        
        List<VCG_CPQ_Product_Rule__c> productRules = new List<VCG_CPQ_Product_Rule__c>(); 
        productRules.add(new VCG_CPQ_Product_Rule__c(Product__c = prodList[0].Id, Depends_On__c = prodList[1].Id, Scope__c = 'Grouping', Option_Group__c = 'Group1', Condition__c = '1'));
        productRules.add(new VCG_CPQ_Product_Rule__c(Product__c = prodList[0].Id, Depends_On__c = prodList[2].Id, Scope__c = 'Grouping', Option_Group__c = 'Group1', Condition__c = '1'));
        
        productRules.add(new VCG_CPQ_Product_Rule__c(Product__c = prodList[3].Id, Depends_On__c = prodList[4].Id, Scope__c = 'Quote', Option_Group__c = 'Group2', Condition__c = '1'));
        productRules.add(new VCG_CPQ_Product_Rule__c(Product__c = prodList[3].Id, Depends_On__c = prodList[5].Id, Scope__c = 'Quote', Option_Group__c = 'Group2', Condition__c = '1'));
        
        insert productRules;
        
        VCG_CPQ_Quote__c testQuote = new VCG_CPQ_Quote__c();
//        testQuote.Name = 'Test Quote';
        insert testQuote;
        
        
        //Missing required primary product
        List<VCG_CPQ_Quote_Product__c> selectedProds = new List<VCG_CPQ_Quote_Product__c>();
        selectedProds.add(new VCG_CPQ_Quote_Product__c(Name='quoteProd1', License_Metric_Quantity__c=3, Quote__c = testQuote.Id, Product__c = prodList[0].Id, Product_Group__c = 'G1'));
        selectedProds.add(new VCG_CPQ_Quote_Product__c(Name='quoteProd2', License_Metric_Quantity__c=3, Quote__c = testQuote.Id, Product__c = prodList[1].Id, Product_Group__c = 'G2'));
        selectedProds.add(new VCG_CPQ_Quote_Product__c(Name='quoteProd3', License_Metric_Quantity__c=3, Quote__c = testQuote.Id, Product__c = prodList[2].Id, Product_Group__c = 'G3'));
        
        List<VCG_CPQ_Error> errors = new List<VCG_CPQ_Error>();
        errors = VCG_CPQ_ProductUtility.validateProductSelection(testQuote, selectedProds);
        
        //Assert error thrown for missing primary products
        System.debug('\n\n' + errors + '\n');
        System.assert(!errors.isEmpty());


        selectedProds.add(new VCG_CPQ_Quote_Product__c(Name='quoteProd4', License_Metric_Quantity__c=3, Quote__c = testQuote.Id, Product__c = prodList[1].Id, Product_Group__c = 'G1'));

        errors.clear();
        errors = VCG_CPQ_ProductUtility.validateProductSelection(testQuote, selectedProds);
        
        //Errors resolved.
        System.debug('\n\n' + errors + '\n');
        System.assert(errors.isEmpty());        
        
        
        
        
        //QUOTE SCOPE//
        selectedProds.add(new VCG_CPQ_Quote_Product__c(Name='quoteProd5', License_Metric_Quantity__c=3, Quote__c = testQuote.Id, Product__c = prodList[3].Id, Product_Group__c = 'G4'));        
         
        errors.clear();
        errors = VCG_CPQ_ProductUtility.validateProductSelection(testQuote, selectedProds);
                
        //Assert error thrown for missing primary products
        System.debug('\n\n' + errors + '\n');
        System.assert(!errors.isEmpty());
        
        selectedProds.add(new VCG_CPQ_Quote_Product__c(Name='quoteProd6', License_Metric_Quantity__c=3, Quote__c = testQuote.Id, Product__c = prodList[4].Id, Product_Group__c = 'G1'));
        
        errors.clear();
        errors = VCG_CPQ_ProductUtility.validateProductSelection(testQuote, selectedProds);
                
        //Errors Resolved
        System.debug('\n\n' + errors + '\n');
        System.assert(errors.isEmpty());        
        
    }   
    
    
    static testMethod void testQuantityValidation() {
        
        Product2 product = new Product2(Name = 'Product0', Family = 'Web', License_Metric__c = 'Seat', IsActive = true);
        Product2 product1 = new Product2(Name = 'Product1', Family = 'Web', License_Metric__c = 'Seat', IsActive = true);
        Product2 product2 = new Product2(Name = 'Product2', Family = 'Web', License_Metric__c = 'Seat', IsActive = true);
        Product2 product3 = new Product2(Name = 'Product3', Family = 'Web', License_Metric__c = 'Seat', IsActive = true);
        Product2 product4 = new Product2(Name = 'Product4', Family = 'Web', License_Metric__c = 'Seat', IsActive = true);
        Product2 product5 = new Product2(Name = 'Product5', Family = 'Web', License_Metric__c = 'Seat', IsActive = true);
        
        List<Product2> prodList = new List<Product2>();
        prodList.add(product);
        prodList.add(product1);
        prodList.add(product2);
        prodList.add(product3);
        prodList.add(product4);
        prodList.add(product5);
        insert prodList;
        
        List<VCG_CPQ_Product_Rule__c> productRules = new List<VCG_CPQ_Product_Rule__c>(); 
        productRules.add(new VCG_CPQ_Product_Rule__c(Product__c = prodList[1].Id, Depends_On__c = prodList[0].Id, Floor__c = '{"op":"*","p1":$Primary,"p2":2}', Scope__c = 'Grouping', Condition__c = '1'));
        productRules.add(new VCG_CPQ_Product_Rule__c(Product__c = prodList[2].Id, Depends_On__c = prodList[3].Id, Ceiling__c = '{"op":"/","p1":$Primary,"p2":2}', Scope__c = 'Grouping', Condition__c = '1'));
        productRules.add(new VCG_CPQ_Product_Rule__c(Product__c = prodList[4].Id, Depends_On__c = prodList[5].Id, Increment__c = '{"op":"if","p1":{"op":">","p1":$Primary,"p2":10},"p2":10, "p3":2}', Scope__c = 'Grouping', Condition__c = '1'));
        
        insert productRules;
        
        VCG_CPQ_Quote__c testQuote = new VCG_CPQ_Quote__c();
//        testQuote.Name = 'Test Quote';
        insert testQuote;
        
        
        //Quantity below floor
        List<VCG_CPQ_Quote_Product__c> selectedProds = new List<VCG_CPQ_Quote_Product__c>();
        selectedProds.add(new VCG_CPQ_Quote_Product__c(Name='quoteProd1', License_Metric_Quantity__c=3, Quote__c = testQuote.Id, Product__c = prodList[0].Id, Product_Group__c = 'G1'));
        selectedProds.add(new VCG_CPQ_Quote_Product__c(Name='quoteProd2', License_Metric_Quantity__c=5, Quote__c = testQuote.Id, Product__c = prodList[1].Id, Product_Group__c = 'G1'));
        
        List<VCG_CPQ_Error> errors = new List<VCG_CPQ_Error>();
        errors = VCG_CPQ_ProductUtility.validateProductSelection(testQuote, selectedProds);
        
        //Assert quantity error
        System.debug('\n\n' + errors + '\n');
        System.assert(!errors.isEmpty());
        
        selectedProds.clear();
        selectedProds.add(new VCG_CPQ_Quote_Product__c(Name='quoteProd1', License_Metric_Quantity__c=3, Quote__c = testQuote.Id, Product__c = prodList[0].Id, Product_Group__c = 'G1'));
        selectedProds.add(new VCG_CPQ_Quote_Product__c(Name='quoteProd2', License_Metric_Quantity__c=6, Quote__c = testQuote.Id, Product__c = prodList[1].Id, Product_Group__c = 'G1'));        
        
        errors.clear();
        errors = VCG_CPQ_ProductUtility.validateProductSelection(testQuote, selectedProds);
        
        //Assert error cleared
        System.debug('\n\n' + errors + '\n');
        System.assert(errors.isEmpty());
        
        
        
        // Ceiling //
        selectedProds.clear();
        errors.clear();
        
        selectedProds.add(new VCG_CPQ_Quote_Product__c(Name='quoteProd2', License_Metric_Quantity__c=6, Quote__c = testQuote.Id, Product__c = prodList[2].Id, Product_Group__c = 'G1'));
        selectedProds.add(new VCG_CPQ_Quote_Product__c(Name='quoteProd3', License_Metric_Quantity__c=6, Quote__c = testQuote.Id, Product__c = prodList[3].Id, Product_Group__c = 'G1'));
        
        errors = VCG_CPQ_ProductUtility.validateProductSelection(testQuote, selectedProds);
        
        //Assert quantity error
        System.debug('\n\n' + errors + '\n');
        System.assert(!errors.isEmpty());
        


        selectedProds.clear();
        errors.clear();
        
        selectedProds.add(new VCG_CPQ_Quote_Product__c(Name='quoteProd2', License_Metric_Quantity__c=3, Quote__c = testQuote.Id, Product__c = prodList[2].Id, Product_Group__c = 'G1'));
        selectedProds.add(new VCG_CPQ_Quote_Product__c(Name='quoteProd3', License_Metric_Quantity__c=6, Quote__c = testQuote.Id, Product__c = prodList[3].Id, Product_Group__c = 'G1'));
        
        errors = VCG_CPQ_ProductUtility.validateProductSelection(testQuote, selectedProds);
        
        //Assert error cleared
        System.debug('\n\n' + errors + '\n');
        System.assert(errors.isEmpty());        




        // Increment //
        selectedProds.clear();
        errors.clear();
        
        selectedProds.add(new VCG_CPQ_Quote_Product__c(Name='quoteProd2', License_Metric_Quantity__c=4, Quote__c = testQuote.Id, Product__c = prodList[4].Id, Product_Group__c = 'G1'));
        selectedProds.add(new VCG_CPQ_Quote_Product__c(Name='quoteProd3', License_Metric_Quantity__c=50, Quote__c = testQuote.Id, Product__c = prodList[5].Id, Product_Group__c = 'G1'));
        
        errors = VCG_CPQ_ProductUtility.validateProductSelection(testQuote, selectedProds);
        
        //Assert quantity error
        System.debug('\n\n' + errors + '\n');
        System.assert(!errors.isEmpty());
        


        selectedProds.clear();
        errors.clear();
        
        selectedProds.add(new VCG_CPQ_Quote_Product__c(Name='quoteProd2', License_Metric_Quantity__c=110, Quote__c = testQuote.Id, Product__c = prodList[4].Id, Product_Group__c = 'G1'));
        selectedProds.add(new VCG_CPQ_Quote_Product__c(Name='quoteProd3', License_Metric_Quantity__c=50, Quote__c = testQuote.Id, Product__c = prodList[5].Id, Product_Group__c = 'G1'));
        
        errors = VCG_CPQ_ProductUtility.validateProductSelection(testQuote, selectedProds);
        
        //Assert error cleared
        System.debug('\n\n' + errors + '\n');
        System.assert(errors.isEmpty());        
        
    }   



    static testMethod void clearAdditionalTestingLines() {
        
        Product2 product = new Product2(Name = 'Product0', Family = 'Web', License_Metric__c = 'Seat', IsActive = true);
        Product2 product1 = new Product2(Name = 'Product1', Family = 'Web', License_Metric__c = 'Seat', IsActive = true);
        Product2 product2 = new Product2(Name = 'Product2', Family = 'Web', License_Metric__c = 'Seat', IsActive = true);
        Product2 product3 = new Product2(Name = 'Product3', Family = 'Web', License_Metric__c = 'Seat', IsActive = true);
        Product2 product4 = new Product2(Name = 'Product4', Family = 'Web', License_Metric__c = 'Seat', IsActive = true);
        Product2 product5 = new Product2(Name = 'Product5', Family = 'Web', License_Metric__c = 'Seat', IsActive = true);
        
        List<Product2> prodList = new List<Product2>();
        prodList.add(product);
        prodList.add(product1);
        prodList.add(product2);
        prodList.add(product3);
        prodList.add(product4);
        prodList.add(product5);
        insert prodList;
        
        VCG_CPQ_Quote__c testQuote = new VCG_CPQ_Quote__c();
//        testQuote.Name = 'Test Quote';
        insert testQuote;
                
        
//--    
        
        VCG_CPQ_ProductUtility.AssetProductWrapper apw = new VCG_CPQ_ProductUtility.AssetProductWrapper('Id','Name','Type','Group');
        
//--    
        
        List<VCG_CPQ_Quote_Product__c> selectedProds = new List<VCG_CPQ_Quote_Product__c>();
        selectedProds.add(new VCG_CPQ_Quote_Product__c(Name='quoteProd1', License_Metric_Quantity__c=3, Quote__c = testQuote.Id, Product__c = prodList[0].Id, Product_Group__c = 'G1'));
        
        List<Asset__c> assets = new List<Asset__c>();       
        assets.add(new Asset__c(Name='quoteAsset1', License_Metric_Quantity__c=3, Product__c = prodList[0].Id, Product_Group__c = 'G1'));
        
        List<VCG_CPQ_Error> errors = new List<VCG_CPQ_Error>();
        errors = VCG_CPQ_ProductUtility.validateProductSelection(testQuote, selectedProds, assets);
                
//--
    }



    static testMethod void testCombinedOptionDependency() {
        
        List<Product2> prodList = new List<Product2>();
        prodList.add(new Product2(Name = 'Product0', Family = 'Web', License_Metric__c = 'Seat', IsActive = true));
        prodList.add(new Product2(Name = 'Product1', Family = 'Web', License_Metric__c = 'Seat', IsActive = true));
        prodList.add(new Product2(Name = 'Product2', Family = 'Web', License_Metric__c = 'Seat', IsActive = true));
        prodList.add(new Product2(Name = 'Product3', Family = 'Web', License_Metric__c = 'Seat', IsActive = true));
        prodList.add(new Product2(Name = 'Product4', Family = 'Web', License_Metric__c = 'Seat', IsActive = true));
        prodList.add(new Product2(Name = 'Product5', Family = 'Web', License_Metric__c = 'Seat', IsActive = true));
        insert prodList;
        
        //0 = Triton AP Web
        //1 = Triton AP Web Cloud Config
        //2 = i500
        //3 = Triton AP Data
        
        List<VCG_CPQ_Product_Addon__c> addons = new List<VCG_CPQ_Product_Addon__c>();
        addons.add(new VCG_CPQ_Product_Addon__c(Product__c = prodList[0].Id, Product_Addon__c = prodList[1].Id, Required__c = '1'));
        addons.add(new VCG_CPQ_Product_Addon__c(Product__c = prodList[1].Id, Product_Addon__c = prodList[2].Id, Required__c = '0'));
        insert addons;        
        
        VCG_CPQ_Quote__c testQuote = new VCG_CPQ_Quote__c(); // Name = 'Test Quote');
        insert testQuote;
        
        //VCG_CPQ_Product_Incompatibility__c incompat = new VCG_CPQ_Product_Incompatibility__c(Product_1__c = prodList[1].Id, Product_2__c = prodList[2].Id, Scope__c='Grouping');
        //insert incompat;
        
        List<VCG_CPQ_Product_Rule__c> productRules = new List<VCG_CPQ_Product_Rule__c>(); 
        productRules.add(new VCG_CPQ_Product_Rule__c(Product__c = prodList[1].Id, Depends_On__c = prodList[0].Id, Scope__c = 'Grouping', Condition__c = '1'));
        productRules.add(new VCG_CPQ_Product_Rule__c(Product__c = prodList[1].Id, Ceiling__c = '1', Scope__c = 'Grouping', Condition__c = '1'));
        productRules.add(new VCG_CPQ_Product_Rule__c(Product__c = prodList[2].Id, Depends_On__c = prodList[0].Id, Option_Group__c = 'O1', Quantity_Group__c = 'Q1', Scope__c = 'Grouping', Condition__c = '1'));
        productRules.add(new VCG_CPQ_Product_Rule__c(Product__c = prodList[2].Id, Depends_On__c = prodList[3].Id, Option_Group__c = 'O1', Quantity_Group__c = 'Q1', Scope__c = 'Grouping', Condition__c = '1'));        
        insert productRules;
        
        
        List<VCG_CPQ_Quote_Product__c> selectedProds = new List<VCG_CPQ_Quote_Product__c>();      
        selectedProds.add(new VCG_CPQ_Quote_Product__c(Name='quoteProd0', License_Metric_Quantity__c=5, Quote__c = testQuote.Id, Product__c = prodList[0].Id, Product_Group__c = 'G1'));
        selectedProds.add(new VCG_CPQ_Quote_Product__c(Name='quoteProd1', License_Metric_Quantity__c=1, Quote__c = testQuote.Id, Product__c = prodList[1].Id, Product_Group__c = 'G1'));
        selectedProds.add(new VCG_CPQ_Quote_Product__c(Name='quoteProd2', License_Metric_Quantity__c=5, Quote__c = testQuote.Id, Product__c = prodList[2].Id, Product_Group__c = 'G1'));
                
        //List<VCG_CPQ_Product_Addon_Wrapper> addonsAvailable = VCG_CPQ_ProductUtility.getAddonProducts(selectedProds); 

        //System.debug('Addon Returned: ' + addonsAvailable);
        
        List<VCG_CPQ_Error> errors = new List<VCG_CPQ_Error>();
        errors = VCG_CPQ_ProductUtility.validateProductSelection(testQuote, selectedProds);
        System.debug('WS Errors: ' + errors);


        /*************************************************
        *   Test Quantity Use Cases
        **************************************************/
        /* >=0 /
        dependencyRec.Quantity__c = '>=0';
        update dependencyRec;
        
        addonsAvailable = VCG_CPQ_ProductUtility.getAddonProducts(selectedCoreProds);
        //System.assertEquals(addonsAvailable[0].Id, prodList[1].Id);


        /* >0 /
        dependencyRec.Quantity__c = '>0';
        update dependencyRec;
        
        addonsAvailable = VCG_CPQ_ProductUtility.getAddonProducts(selectedCoreProds);
        //System.assertEquals(addonsAvailable[0].Id, prodList[1].Id);
        
        /*************************************************
        *   Test Negative Path
        **************************************************  
        Product2 negativeProd = new Product2();
        negativeProd.Name = 'NegProduct';
        negativeProd.Family = 'Web';
        negativeProd.License_Metric__c = 'Seat';
        negativeProd.IsActive = true;
        insert negativeProd;
        
        VCG_CPQ_Quote__c negativeQuote = new VCG_CPQ_Quote__c(); // Name = 'Negative Quote');
        insert negativeQuote;
        
        VCG_CPQ_Quote_Product__c negativeQuoteProd = new VCG_CPQ_Quote_Product__c(Name='NegativeQuoteProd', License_Metric_Quantity__c=10, Quote__c=negativeQuote.Id, Product__c = negativeProd.Id);
                
        List<VCG_CPQ_Quote_Product__c>negativeQuoteProds = new List<VCG_CPQ_Quote_Product__c>();
        negativeQuoteProds.add(negativeQuoteProd);
        
        addonsAvailable = VCG_CPQ_ProductUtility.getAddonProducts(negativeQuoteProds);
    
        System.assert(addonsAvailable.isEmpty());
        
        /*************************************************
        *   Test SOQL Exception
        **************************************************/

    }      


/* No longer using VCG_CPQ_Product_Dependency__c object -LC 2014-12-05
    static testMethod void testQuantityMatchValidation() {
        System.debug('\n\nStarting Quantity Match Validation \n\n');
        
        List<Product2> qtyMatchProds = new List<Product2>();
        qtyMatchProds.add(new Product2(Name = 'qtyMatchProd0', Family = 'Web', License_Metric__c = 'Seat', IsActive = true));
        qtyMatchProds.add(new Product2(Name = 'qtyMatchProd1', Family = 'Web', License_Metric__c = 'Seat', IsActive = true));
        qtyMatchProds.add(new Product2(Name = 'qtyMatchProd2', Family = 'Web', License_Metric__c = 'Seat', IsActive = true));
        insert qtyMatchProds;
    
        List<VCG_CPQ_Quote__c> quotes = new List<VCG_CPQ_Quote__c>();
        quotes.add(new VCG_CPQ_Quote__c()); // Name = 'Qty Match Quote'));
        insert quotes;
        
        List<VCG_CPQ_Product_Dependency__c> matchQtyDeps = new List<VCG_CPQ_Product_Dependency__c>();
        matchQtyDeps.add(new VCG_CPQ_Product_Dependency__c(Product__c = qtyMatchProds[0].Id, Dependent_Product__c = qtyMatchProds[1].Id, Match_Quantity__c = true));
        matchQtyDeps.add(new VCG_CPQ_Product_Dependency__c(Product__c = qtyMatchProds[1].Id, Dependent_Product__c = qtyMatchProds[2].Id, Match_Quantity__c = true));
        insert matchQtyDeps;

        
        /*************************************************
        *   Negative Path
        **************************************************  
        List<VCG_CPQ_Quote_Product__c> quoteProds = new List<VCG_CPQ_Quote_Product__c>();
        quoteProds.add(new VCG_CPQ_Quote_Product__c(Product__c = qtyMatchProds[0].Id, Quote__c = quotes[0].Id, License_Metric_Quantity__c = 1));
        quoteProds.add(new VCG_CPQ_Quote_Product__c(Product__c = qtyMatchProds[1].Id, Quote__c = quotes[0].Id, License_Metric_Quantity__c = 2));
        quoteProds.add(new VCG_CPQ_Quote_Product__c(Product__c = qtyMatchProds[2].Id, Quote__c = quotes[0].Id, License_Metric_Quantity__c = 3));

        List<VCG_CPQ_Error> qtyMatchErrs = VCG_CPQ_ProductUtility.validateProductSelection(quotes[0], quoteProds);
        System.debug('\n\nqtyMatchErrs: ' + qtyMatchErrs + '\n\n');
        System.assert(!qtyMatchErrs.isEmpty()); 


        /*************************************************
        *   Positive Path
        **************************************************
        qtyMatchProds.add(new Product2(Name = 'qtyMatchProd4', Family = 'Web', License_Metric__c = 'Seat', IsActive = true));
        qtyMatchProds.add(new Product2(Name = 'qtyMatchProd5', Family = 'Web', License_Metric__c = 'Seat', IsActive = true));
        upsert qtyMatchProds;

        matchQtyDeps.add(new VCG_CPQ_Product_Dependency__c(Product__c = qtyMatchProds[3].Id, Dependent_Product__c = qtyMatchProds[4].Id, Match_Quantity__c = true));
        upsert matchQtyDeps;

        List<VCG_CPQ_Quote_Product__c> noErrorQuoteProds = new List<VCG_CPQ_Quote_Product__c>();
        noErrorQuoteProds.add(new VCG_CPQ_Quote_Product__c(Product__c = qtyMatchProds[3].Id, Quote__c = quotes[0].Id, License_Metric_Quantity__c = 1));
        noErrorQuoteProds.add(new VCG_CPQ_Quote_Product__c(Product__c = qtyMatchProds[4].Id, Quote__c = quotes[0].Id, License_Metric_Quantity__c = 1));

        List<VCG_CPQ_Error> noQtyMatchErrs = VCG_CPQ_ProductUtility.validateProductSelection(quotes[0], noErrorQuoteProds);
        System.debug('\n\nnoQtyMatchErrs: ' + noQtyMatchErrs + '\n\n');
        System.assert(noQtyMatchErrs.isEmpty());        
        
    }
*/


/* No longer using VCG_CPQ_Product_Dependency__c object -LC 2014-12-05
    static testMethod void testGroupQtyValidation() {
        System.debug('\n\nStarting Group Product Validation \n\n');
        
        List<Product2> groupMatchProds = new List<Product2>();
        groupMatchProds.add(new Product2(Name = 'groupMatchProd0', Family = 'Web', License_Metric__c = 'Seat', IsActive = true));
        groupMatchProds.add(new Product2(Name = 'groupMatchProd1', Family = 'Web', License_Metric__c = 'Seat', IsActive = true));
        groupMatchProds.add(new Product2(Name = 'groupMatchProd2', Family = 'Web', License_Metric__c = 'Seat', IsActive = true));
        groupMatchProds.add(new Product2(Name = 'groupMatchProd3', Family = 'Web', License_Metric__c = 'Seat', IsActive = true));
        groupMatchProds.add(new Product2(Name = 'groupMatchProd4', Family = 'Web', License_Metric__c = 'Seat', IsActive = true));
        insert groupMatchProds;
        
        List<VCG_CPQ_Product_Dependency__c> groupQtyDeps = new List<VCG_CPQ_Product_Dependency__c>();
        groupQtyDeps.add(new VCG_CPQ_Product_Dependency__c(Product__c = groupMatchProds[0].Id, Dependent_Product__c = groupMatchProds[1].Id, Group__c = 'Group1'));
        groupQtyDeps.add(new VCG_CPQ_Product_Dependency__c(Product__c = groupMatchProds[0].Id, Dependent_Product__c = groupMatchProds[2].Id, Group__c = 'Group1'));
        groupQtyDeps.add(new VCG_CPQ_Product_Dependency__c(Product__c = groupMatchProds[1].Id, Dependent_Product__c = groupMatchProds[3].Id, Group__c = 'Group2'));
        groupQtyDeps.add(new VCG_CPQ_Product_Dependency__c(Product__c = groupMatchProds[1].Id, Dependent_Product__c = groupMatchProds[4].Id, Group__c = 'Group2'));
        insert groupQtyDeps;        

        List<VCG_CPQ_Quote__c> quotes = new List<VCG_CPQ_Quote__c>();
        quotes.add(new VCG_CPQ_Quote__c()); // Name = 'Group Qty Quote'));
        insert quotes;

        /*************************************************
        *   Negative Path
        **************************************************
        List<VCG_CPQ_Quote_Product__c> groupQuoteProds = new List<VCG_CPQ_Quote_Product__c>();
        groupQuoteProds.add(new VCG_CPQ_Quote_Product__c(Product__c = groupMatchProds[0].Id, Quote__c = quotes[0].Id, License_Metric_Quantity__c = 2));
        groupQuoteProds.add(new VCG_CPQ_Quote_Product__c(Product__c = groupMatchProds[1].Id, Quote__c = quotes[0].Id, License_Metric_Quantity__c = 1));
        
        List<VCG_CPQ_Error> groupMatchErrs = VCG_CPQ_ProductUtility.validateProductSelection(quotes[0], groupQuoteProds);
        System.debug('\n\ngroupMatchErrs: ' + groupMatchErrs + '\n\n');
        System.assert(!groupMatchErrs.isEmpty());       


        /*************************************************
        *   Positive Path
        **************************************************
        List<VCG_CPQ_Quote_Product__c> noErrorGroupQuoteProds = new List<VCG_CPQ_Quote_Product__c>();
        noErrorGroupQuoteProds.add(new VCG_CPQ_Quote_Product__c(Product__c = groupMatchProds[1].Id, Quote__c = quotes[0].Id, License_Metric_Quantity__c = 2));
        noErrorGroupQuoteProds.add(new VCG_CPQ_Quote_Product__c(Product__c = groupMatchProds[3].Id, Quote__c = quotes[0].Id, License_Metric_Quantity__c = 1));
        noErrorGroupQuoteProds.add(new VCG_CPQ_Quote_Product__c(Product__c = groupMatchProds[4].Id, Quote__c = quotes[0].Id, License_Metric_Quantity__c = 1));

        List<VCG_CPQ_Error> noGroupMatchErrs = VCG_CPQ_ProductUtility.validateProductSelection(quotes[0], noErrorGroupQuoteProds);
        System.debug('\n\nnogroupMatchErrs: ' + noGroupMatchErrs + '\n\n');
        System.assert(noGroupMatchErrs.isEmpty());      
    }
*/


/* No longer using VCG_CPQ_Product_Dependency__c object -LC 2014-12-05
    static testMethod void testRequiredProductValidation() {
        System.debug('\n\nStarting Required Product Validation \n\n');
        
        List<Product2> requiredProds = new List<Product2>();
        requiredProds.add(new Product2(Name = 'requiredProd0', Family = 'Web', License_Metric__c = 'Seat', IsActive = true));
        requiredProds.add(new Product2(Name = 'requiredProd1', Family = 'Web', License_Metric__c = 'Seat', IsActive = true));
        requiredProds.add(new Product2(Name = 'requiredProd2', Family = 'Web', License_Metric__c = 'Seat', IsActive = true));
        insert requiredProds;

        List<VCG_CPQ_Product_Dependency__c> requiredProdDeps = new List<VCG_CPQ_Product_Dependency__c>();
        requiredProdDeps.add(new VCG_CPQ_Product_Dependency__c(Product__c = requiredProds[0].Id, Dependent_Product__c = requiredProds[1].Id, Required__c = true));
        requiredProdDeps.add(new VCG_CPQ_Product_Dependency__c(Product__c = requiredProds[1].Id, Dependent_Product__c = requiredProds[2].Id, Required__c = false));
        insert requiredProdDeps;    
        
        List<VCG_CPQ_Quote__c> quotes = new List<VCG_CPQ_Quote__c>();
        quotes.add(new VCG_CPQ_Quote__c()); // Name = 'Required Product Quote'));
        insert quotes;
                
        /*************************************************
        *   Negative Path
        **************************************************
        List<VCG_CPQ_Quote_Product__c> requiredQuoteProds = new List<VCG_CPQ_Quote_Product__c>();
        requiredQuoteProds.add(new VCG_CPQ_Quote_Product__c(Product__c = requiredProds[1].Id, Quote__c = quotes[0].Id, License_Metric_Quantity__c = 1));
        
        List<VCG_CPQ_Error> requiredProdErrs = VCG_CPQ_ProductUtility.validateProductSelection(quotes[0], requiredQuoteProds);
        System.debug('\n\nrequiredProdErrs: ' + requiredProdErrs + '\n\n');
        System.assert(!requiredProdErrs.isEmpty());         


        /*************************************************
        *   Positive Path
        **************************************************
        List<VCG_CPQ_Quote_Product__c> noErrRequiredQuoteProds = new List<VCG_CPQ_Quote_Product__c>();
        noErrRequiredQuoteProds.add(new VCG_CPQ_Quote_Product__c(Product__c = requiredProds[2].Id, Quote__c = quotes[0].Id, License_Metric_Quantity__c = 1));
        
        List<VCG_CPQ_Error> noErrRequiredProdErrs = VCG_CPQ_ProductUtility.validateProductSelection(quotes[0], noErrRequiredQuoteProds);
        System.debug('\n\nnoErrRequiredProdErrs: ' + noErrRequiredProdErrs + '\n\n');
        System.assert(noErrRequiredProdErrs.isEmpty());             
    }
*/

        
/* No longer using VCG_CPQ_Product_Dependency__c object -LC 2014-12-05
    static testMethod void testQuantityFloorValidation() {
        System.debug('\n\nStarting Product Floor Validation \n\n');
        
        List<Product2> floorProds = new List<Product2>();
        floorProds.add(new Product2(Name = 'floorProd0', Family = 'Web', License_Metric__c = 'Seat', IsActive = true));
        floorProds.add(new Product2(Name = 'floorProd1', Family = 'Web', License_Metric__c = 'Seat', IsActive = true));
        insert floorProds;

        List<VCG_CPQ_Product_Dependency__c> floorProdDeps = new List<VCG_CPQ_Product_Dependency__c>();
        floorProdDeps.add(new VCG_CPQ_Product_Dependency__c(Product__c = floorProds[0].Id, Floor__c = 5));
        floorProdDeps.add(new VCG_CPQ_Product_Dependency__c(Product__c = floorProds[1].Id));
        insert floorProdDeps;   
        
        List<VCG_CPQ_Quote__c> quotes = new List<VCG_CPQ_Quote__c>();
        quotes.add(new VCG_CPQ_Quote__c()); // Name = 'Floor Quote'));
        insert quotes;
        /*************************************************
        *   Negative Path
        **************************************************
        List<VCG_CPQ_Quote_Product__c> floorQuoteProds = new List<VCG_CPQ_Quote_Product__c>();
        floorQuoteProds.add(new VCG_CPQ_Quote_Product__c(Product__c = floorProds[0].Id, Quote__c = quotes[0].Id, License_Metric_Quantity__c = 1));     

        List<VCG_CPQ_Error> floorProdErrs = VCG_CPQ_ProductUtility.validateProductSelection(quotes[0], floorQuoteProds);
        System.debug('\n\nfloorProdErrs: ' + floorProdErrs + '\n\n');
        System.assert(!floorProdErrs.isEmpty()); 

        
        /*************************************************
        *   Positive Path
        **************************************************
        List<VCG_CPQ_Quote_Product__c> noErrFloorQuoteProds = new List<VCG_CPQ_Quote_Product__c>();
        noErrFloorQuoteProds.add(new VCG_CPQ_Quote_Product__c(Product__c = floorProds[1].Id, Quote__c = quotes[0].Id, License_Metric_Quantity__c = 1));        

        List<VCG_CPQ_Error> nofloorProdErrs = VCG_CPQ_ProductUtility.validateProductSelection(quotes[0], noErrFloorQuoteProds);
        System.debug('\n\nnofloorProdErrs: ' + nofloorProdErrs + '\n\n');
        System.assert(nofloorProdErrs.isEmpty());       
    }   
*/

    
/* No longer using VCG_CPQ_Product_Dependency__c object -LC 2014-12-05
    static testMethod void testProductQtyMultiplesValidation() {
        System.debug('\n\nStarting Quantity Multiples Validation \n\n');
        
        List<Product2> multiplesProds = new List<Product2>();
        multiplesProds.add(new Product2(Name = 'multiplesProd0', Family = 'Web', License_Metric__c = 'Seat', IsActive = true));
        multiplesProds.add(new Product2(Name = 'multiplesProd1', Family = 'Web', License_Metric__c = 'Seat', IsActive = true));
        insert multiplesProds;

        List<VCG_CPQ_Product_Dependency__c> multiplesProdDeps = new List<VCG_CPQ_Product_Dependency__c>();
        multiplesProdDeps.add(new VCG_CPQ_Product_Dependency__c(Product__c = multiplesProds[0].Id, Multiples__c = 5));
        multiplesProdDeps.add(new VCG_CPQ_Product_Dependency__c(Product__c = multiplesProds[1].Id, Multiples__c = 2));
        insert multiplesProdDeps;
        
        List<VCG_CPQ_Quote__c> quotes = new List<VCG_CPQ_Quote__c>();
        quotes.add(new VCG_CPQ_Quote__c()); // Name = 'Multiples Quote'));
        insert quotes;
                    
        /*************************************************
        *   Negative Path
        **************************************************
        List<VCG_CPQ_Quote_Product__c> multiplesQuoteProds = new List<VCG_CPQ_Quote_Product__c>();
        multiplesQuoteProds.add(new VCG_CPQ_Quote_Product__c(Product__c = multiplesProds[0].Id, Quote__c = quotes[0].Id, License_Metric_Quantity__c = 3));     

        List<VCG_CPQ_Error> multiplesProdErrs = VCG_CPQ_ProductUtility.validateProductSelection(quotes[0], multiplesQuoteProds);
        System.debug('\n\nmultiplesProdErrs: ' + multiplesProdErrs + '\n\n');
        System.assert(!multiplesProdErrs.isEmpty());        
        
        
        /*************************************************
        *   Positive Path
        **************************************************          
        List<VCG_CPQ_Quote_Product__c> noErrMultiplesQuoteProds = new List<VCG_CPQ_Quote_Product__c>();
        noErrMultiplesQuoteProds.add(new VCG_CPQ_Quote_Product__c(Product__c = multiplesProds[1].Id, Quote__c = quotes[0].Id, License_Metric_Quantity__c = 4));        

        List<VCG_CPQ_Error> noMultiplesProdErrs = VCG_CPQ_ProductUtility.validateProductSelection(quotes[0], noErrMultiplesQuoteProds);
        System.debug('\n\nnoMultiplesProdErrs: ' + noMultiplesProdErrs + '\n\n');
        System.assert(noMultiplesProdErrs.isEmpty());       
    }
*/    
    

    static testMethod void testProductIncompatibilityValidation() {
        System.debug('\n\nStarting Product Incompatibility Validation \n\n');
        
        List<Product2> incompatProds = new List<Product2>();
        incompatProds.add(new Product2(Name = 'incompatProd0', Family = 'Web', License_Metric__c = 'Seat', IsActive = true));
        incompatProds.add(new Product2(Name = 'incompatProd1', Family = 'Web', License_Metric__c = 'Seat', IsActive = true));
        incompatProds.add(new Product2(Name = 'incompatProd2', Family = 'Web', License_Metric__c = 'Seat', IsActive = true));
        insert incompatProds;       
        
        List<VCG_CPQ_Product_Incompatibility__c> prodIncompats = new List<VCG_CPQ_Product_Incompatibility__c>();
        prodIncompats.add(new VCG_CPQ_Product_Incompatibility__c(Product_1__c = incompatProds[0].Id, Product_2__c = incompatProds[1].Id, Scope__c = 'Grouping'));
        insert prodIncompats;       
        
        List<VCG_CPQ_Quote__c> quotes = new List<VCG_CPQ_Quote__c>();
        quotes.add(new VCG_CPQ_Quote__c()); // Name = 'Incompatibility Quote'));
        insert quotes;      
        
        /*************************************************
        *   Negative Path
        **************************************************/
        List<VCG_CPQ_Quote_Product__c> incompatQuoteProds = new List<VCG_CPQ_Quote_Product__c>();
        incompatQuoteProds.add(new VCG_CPQ_Quote_Product__c(Product__c = incompatProds[0].Id, Quote__c = quotes[0].Id, License_Metric_Quantity__c = 2));       
        incompatQuoteProds.add(new VCG_CPQ_Quote_Product__c(Product__c = incompatProds[1].Id, Quote__c = quotes[0].Id, License_Metric_Quantity__c = 2));
            
        List<VCG_CPQ_Error> incompatProdErrs = VCG_CPQ_ProductUtility.validateProductSelection(quotes[0], incompatQuoteProds);
        System.debug('\n\nincompatProdErrs: ' + incompatProdErrs + '\n\n');
        System.assert(!incompatProdErrs.isEmpty());


        /*************************************************
        *   Positive Path
        **************************************************/
        List<VCG_CPQ_Quote_Product__c> noErrIncompatQuoteProds = new List<VCG_CPQ_Quote_Product__c>();
        noErrIncompatQuoteProds.add(new VCG_CPQ_Quote_Product__c(Product__c = incompatProds[2].Id, Quote__c = quotes[0].Id, License_Metric_Quantity__c = 2));
        
        List<VCG_CPQ_Error> noIncompatProdErrs = VCG_CPQ_ProductUtility.validateProductSelection(quotes[0], noErrIncompatQuoteProds);
        System.debug('\n\nnoIncompatProdErrs: ' + noIncompatProdErrs + '\n\n');
        System.assert(noIncompatProdErrs.isEmpty());        
    }
    
    static testMethod void testAddonWrapper(){
        List<VCG_CPQ_Quote__c> quotes = new List<VCG_CPQ_Quote__c>();
        quotes.add(new VCG_CPQ_Quote__c()); // Name = 'Test Quote'));
        insert quotes;  
        
        List<Product2> prods = new List<Product2>();
        prods.add(new Product2(Name = 'test prod', Family = 'Web', License_Metric__c = 'Seat', IsActive = true));
        insert prods;
        
        List<VCG_CPQ_Quote_Product__c> quoteProds = new List<VCG_CPQ_Quote_Product__c>();
        quoteProds.add(new VCG_CPQ_Quote_Product__c(Product__c = prods[0].Id, Quote__c = quotes[0].Id, License_Metric_Quantity__c = 2));
        
        VCG_CPQ_Product_Addon_Wrapper wrap = new VCG_CPQ_Product_Addon_Wrapper(quoteProds[0], prods[0]);
        
        VCG_CPQ_Product_Addon_Wrapper wrap2 = new VCG_CPQ_Product_Addon_Wrapper(quoteProds[0], prods[0], 1, 1);

    }
    
    static testMethod void testErrorClass(){
        VCG_CPQ_Error err1 = new VCG_CPQ_Error('Test', 'Test');
        VCG_CPQ_Error err2 = new VCG_CPQ_Error('Test');
    }
    
}