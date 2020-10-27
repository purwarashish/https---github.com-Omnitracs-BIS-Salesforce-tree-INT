/**
 * @description
 * @author  Lawrence Coffin <lawrence.coffin@cloudsherpas.com>
 * @since   13.Mar.2014
 */
@isTest
public without sharing class VCG_CPQ_Formula_Test {
    
    /**
     * @description
     * @author  Lawrence Coffin <lawrence.coffin@cloudsherpas.com>
     * @since   13.Mar.2014
     */
    static testMethod void testBaseFormulas() {
        // Quote Product record to use for testing field references
        // Fill with arbitraty values
        VCG_CPQ_Quote_Product__c qli = new VCG_CPQ_Quote_Product__c( );
        qli.Quantity__c = 95;
        qli.License_Metric_Quantity__c = 27;
        qli.Sales_Price__c = 84.75;
        qli.Quote__r = new VCG_CPQ_Quote__c();
        qli.Quote__r.Total__c = 1234.56;
        qli.Quote__r.Account__r = new Account();
        qli.Quote__r.Account__r.AnnualRevenue = 875000;
        
        //
        // Start with simple numeric values first
        //
        System.assertEquals(100,    VCG_CPQ_Formula.evaluate(qli, '100').value);
        System.assertEquals(-20,    VCG_CPQ_Formula.evaluate(qli, '-20').value);
        System.assertEquals( 40.73, VCG_CPQ_Formula.evaluate(qli, '40.73').value);
        
        //
        // String literals
        //
        System.assertEquals( 'abc',     VCG_CPQ_Formula.evaluate(qli, '"\'abc\'"').str_val);
        
        //
        // Next, field references
        //
        System.assertEquals(    95,     VCG_CPQ_Formula.evaluate(qli, '"Quantity__c"').value);
        System.assertEquals(    84.75,  VCG_CPQ_Formula.evaluate(qli, '"Sales_Price__c"').value);
        System.assertEquals(  1234.56,  VCG_CPQ_Formula.evaluate(qli, '"Quote__r.Total__c"').value);
        System.assertEquals(875000,     VCG_CPQ_Formula.evaluate(qli, '"Quote__r.Account__r.AnnualRevenue"').value);
        
        //
        // Basic math
        //
        System.assertEquals(   50,    VCG_CPQ_Formula.evaluate(qli, '{"op":"+","p1":20,"p2":30}').value);
        System.assertEquals(   40,    VCG_CPQ_Formula.evaluate(qli, '{"op":"-","p1":70,"p2":30}').value);
        System.assertEquals(    6,    VCG_CPQ_Formula.evaluate(qli, '{"op":"*","p1":2,"p2":3}').value);
        System.assertEquals(    7,    VCG_CPQ_Formula.evaluate(qli, '{"op":"/","p1":14,"p2":2}').value);
        
        //
        // Negative values
        //
        System.assertEquals(   10,    VCG_CPQ_Formula.evaluate(qli, '{"op":"+","p1":-20,"p2":30}').value);
        System.assertEquals(  -10,    VCG_CPQ_Formula.evaluate(qli, '{"op":"+","p1":20,"p2":-30}').value);
        System.assertEquals(  100,    VCG_CPQ_Formula.evaluate(qli, '{"op":"-","p1":70,"p2":-30}').value);
        System.assertEquals(   -6,    VCG_CPQ_Formula.evaluate(qli, '{"op":"*","p1":-2,"p2":3}').value);
        System.assertEquals(   -7,    VCG_CPQ_Formula.evaluate(qli, '{"op":"/","p1":14,"p2":-2}').value);
        
        //
        // Decimal math
        //
        System.assertEquals( 7.34,    VCG_CPQ_Formula.evaluate(qli, '{"op":"+","p1":2.34,"p2":5}').value);
        System.assertEquals( 7.34,    VCG_CPQ_Formula.evaluate(qli, '{"op":"+","p1":2.34,"p2":5.00}').value);
        System.assertEquals( 9.37,    VCG_CPQ_Formula.evaluate(qli, '{"op":"-","p1":14.73,"p2":5.36}').value);
        System.assertEquals(44.876,   VCG_CPQ_Formula.evaluate(qli, '{"op":"*","p1":8.63,"p2":5.2}').value);
        System.assertEquals( 5.83,    VCG_CPQ_Formula.evaluate(qli, '{"op":"/","p1":20.988,"p2":3.6}').value);
        
        //
        // Decimal math methods
        //
        System.assertEquals( 5,    VCG_CPQ_Formula.evaluate(qli, '{"op":"MAX","p1":2.34,"p2":5}').value);
        System.assertEquals( 2.34,    VCG_CPQ_Formula.evaluate(qli, '{"op":"MIN","p1":2.34,"p2":5}').value);
        System.assertEquals( 32,    VCG_CPQ_Formula.evaluate(qli, '{"op":"POW","p1":2,"p2":5}').value);
        System.assertEquals( 32,    VCG_CPQ_Formula.evaluate(qli, '{"op":"^","p1":2,"p2":5}').value);
        System.assertEquals( Math.pow(Double.valueOf(1.5), Double.valueOf(3.4)),    VCG_CPQ_Formula.evaluate(qli, '{"op":"POW","p1":1.5,"p2":3.4}').value);
       
        //
        // Integer math methods
        //
        System.assertEquals( 3,    VCG_CPQ_Formula.evaluate(qli, '{"op":"MOD","p1":11,"p2":8}').value);
        System.assertEquals( 5,    VCG_CPQ_Formula.evaluate(qli, '{"op":"%","p1":12,"p2":7}').value);
        
        //
        // Decimal math methods (unary)
        //
        System.assertEquals( 2,    VCG_CPQ_Formula.evaluate(qli, '{"op":"FLOOR","p1":2.36}').value);
        System.assertEquals( 3,    VCG_CPQ_Formula.evaluate(qli, '{"op":"CEIL","p1":2.36}').value);
        System.assertEquals(-2.36, VCG_CPQ_Formula.evaluate(qli, '{"op":"-","p1":2.36}').value);
       
        //
        // Math with field references
        //
        System.assertEquals(    122,          VCG_CPQ_Formula.evaluate(qli, '{"op":"+","p1":"Quantity__c","p2":"License_Metric_Quantity__c"}').value);
        System.assertEquals(   1149.81,       VCG_CPQ_Formula.evaluate(qli, '{"op":"-","p1":"Quote__r.Total__c","p2":"Sales_Price__c"}').value);
        System.assertEquals(   8051.25,       VCG_CPQ_Formula.evaluate(qli, '{"op":"*","p1":"Sales_Price__c","p2":"Quantity__c"}').value);
        System.assertEquals( 1234.56 / 95,    VCG_CPQ_Formula.evaluate(qli, '{"op":"/","p1":"Quote__r.Total__c","p2":"Quantity__c"}').value);
        System.assertEquals(    -95,          VCG_CPQ_Formula.evaluate(qli, '{"op":"-","p1":"Quantity__c"}').value);
        
        //
        // Complex (nested) formulas
        //
        System.assertEquals(    9,     VCG_CPQ_Formula.evaluate(qli, '{"op":"-","p1":12,"p2":{"op":"/","p1":6,"p2":2}}').value);
        System.assertEquals( 9285.81,  VCG_CPQ_Formula.evaluate(qli, '{"op":"+","p1":"Quote__r.Total__c","p2":{"op":"*","p1":"Sales_Price__c","p2":"Quantity__c"}}').value);
        System.assertEquals(   19,     VCG_CPQ_Formula.evaluate(qli, '{"op":"MOD","p1":{"p1":"Quantity__c","op":"+","p2":5},"p2":"License_Metric_Quantity__c"}').value);
        
        //
        // Date methods
        //
        System.assertEquals( Date.today(),               VCG_CPQ_Formula.evaluate('{"op":"TODAY"}').obj_val);
        System.assertEquals( Date.today().addDays( 60),  VCG_CPQ_Formula.evaluate('{"op":"+","p1":{"op":"TODAY"},"p2":60}').obj_val);
        System.assertEquals( Date.today().addDays(-30),  VCG_CPQ_Formula.evaluate('{"op":"-","p1":{"op":"TODAY"},"p2":30}').obj_val);
        /** @todo  Should these next two be allowed? I.e. (30 - 12/24/2014) isn't really the same as (12/24/2014 - 30) ... -LC 2014-11-12 */
        System.assertEquals( Date.today().addDays( 60),  VCG_CPQ_Formula.evaluate('{"op":"+","p1":60,"p2":{"op":"TODAY"}}').obj_val);
        System.assertEquals( Date.today().addDays(-30),  VCG_CPQ_Formula.evaluate('{"op":"-","p1":30,"p2":{"op":"TODAY"}}').obj_val);
       
        //
        // String Concatenation (&) and JOIN (max of 100 items)
        //
        System.assertEquals(   'abcdef',   VCG_CPQ_Formula.evaluate(qli, '{"op":"&","p1":"\'abc\'","p2":"\'def\'"}').str_val);
        System.assertEquals( 'ab-cd-ef',   VCG_CPQ_Formula.evaluate(qli, '{"op":"JOIN","p1":"\'-\'","p2":"\'ab\'","p3":"\'cd\'","p4":"\'ef\'"}').str_val);
        
        //
        // Test JOIN with null values and empty strings (nulls are skipped)
        //
        System.assertEquals(  'A-C-D',   VCG_CPQ_Formula.evaluate(qli, '{"op":"JOIN","p1":"\'-\'","p2":"\'A\'","p3":"null","p4":"\'C\'","p5":"\'D\'"}').str_val);
        System.assertEquals( 'A--C-D',   VCG_CPQ_Formula.evaluate(qli, '{"op":"JOIN","p1":"\'-\'","p2":"\'A\'","p3":"\'\'","p4":"\'C\'","p5":"\'D\'"}').str_val);
        System.assertEquals(    'A-D',   VCG_CPQ_Formula.evaluate(qli, '{"op":"JOIN","p1":"\'-\'","p2":"\'A\'","p3":"null","p4":"null","p5":"\'D\'"}').str_val);
        System.assertEquals(  'A---D',   VCG_CPQ_Formula.evaluate(qli, '{"op":"JOIN","p1":"\'-\'","p2":"\'A\'","p3":"\'\'","p4":"\'\'","p5":"\'D\'"}').str_val);
        System.assertEquals(  'B-C-D',   VCG_CPQ_Formula.evaluate(qli, '{"op":"JOIN","p1":"\'-\'","p2":"null","p3":"\'B\'","p4":"\'C\'","p5":"\'D\'"}').str_val);
        System.assertEquals( '-B-C-D',   VCG_CPQ_Formula.evaluate(qli, '{"op":"JOIN","p1":"\'-\'","p2":"\'\'","p3":"\'B\'","p4":"\'C\'","p5":"\'D\'"}').str_val);
        System.assertEquals('A-B-C'  ,   VCG_CPQ_Formula.evaluate(qli, '{"op":"JOIN","p1":"\'-\'","p2":"\'A\'","p3":"\'B\'","p4":"\'C\'","p5":"null"}').str_val);
        System.assertEquals('A-B-C-' ,   VCG_CPQ_Formula.evaluate(qli, '{"op":"JOIN","p1":"\'-\'","p2":"\'A\'","p3":"\'B\'","p4":"\'C\'","p5":"\'\'"}').str_val);
        System.assertEquals(       '',   VCG_CPQ_Formula.evaluate(qli, '{"op":"JOIN","p1":"\'-\'","p2":"null","p3":"null","p4":"null","p5":"null"}').str_val);
        System.assertEquals(    '---',   VCG_CPQ_Formula.evaluate(qli, '{"op":"JOIN","p1":"\'-\'","p2":"\'\'","p3":"\'\'","p4":"\'\'","p5":"\'\'"}').str_val);
        
        //
        // Non-list SUM -- SUM of two or more parameters (max of 100 items)
        //
        System.assertEquals(   3  ,   VCG_CPQ_Formula.evaluate(qli, '{"op":"SUM","p1":1,"p2":2}').value);
        System.assertEquals(   6  ,   VCG_CPQ_Formula.evaluate(qli, '{"op":"SUM","p1":1,"p2":2,"p3":3}').value);
        System.assertEquals(  10  ,   VCG_CPQ_Formula.evaluate(qli, '{"op":"SUM","p1":1,"p2":2,"p3":3,"p4":4}').value);
        System.assertEquals(  15  ,   VCG_CPQ_Formula.evaluate(qli, '{"op":"SUM","p1":1,"p2":2,"p3":3,"p4":4,"p5":5}').value);
        System.assertEquals(  16.5,   VCG_CPQ_Formula.evaluate(qli, '{"op":"SUM","p1":1.1,"p2":2.2,"p3":3.3,"p4":4.4,"p5":5.5}').value);
        
        //
        // IN function
        //
        // <Value1> IN (<Value2> [, <Value3>[, <Value4>[ ... ]]])
        //
        //     <Value1>, <Value2>, etc. can be complex sub-formulas (if needed)
        //
        //     Up to 100 Values (including Value1) can be specified.
        //
        // Handles:
        //
        //    - Decimal values
        //    - String values
        //    - Date values
        //
        // Note: This function short-circuits... so if Value1 matches Value2, then Value3 (and later values) won't be
        //       evaluated (all values can be sub-formulas). So you need to balance between putting values that are
        //       easier to calculate vs the most common value first in the list. (Sometimes easier to compute should
        //       be first, but not if they are almost never going to be the matching value.)
        //
        System.assertEquals(   1,   VCG_CPQ_Formula.evaluate('{"p1":5,"op":"IN","p2":5,"p3":10,"p4":15}').value);
        System.assertEquals(   1,   VCG_CPQ_Formula.evaluate('{"p1":10,"op":"IN","p2":5,"p3":10,"p4":15}').value);
        System.assertEquals(   1,   VCG_CPQ_Formula.evaluate('{"p1":15,"op":"IN","p2":5,"p3":10,"p4":15}').value);
        System.assertEquals(   0,   VCG_CPQ_Formula.evaluate('{"_debug":"true","p1":20,"op":"IN","p2":5,"p3":10,"p4":15}').value);
        System.assertEquals(   1,   VCG_CPQ_Formula.evaluate('{"p1":"\'abc\'","op":"IN","p2":"\'abc\'","p3":"\'def\'","p4":"\'ghi\'"}').value);
        System.assertEquals(   1,   VCG_CPQ_Formula.evaluate('{"p1":"\'def\'","op":"IN","p2":"\'abc\'","p3":"\'def\'","p4":"\'ghi\'"}').value);
        System.assertEquals(   1,   VCG_CPQ_Formula.evaluate('{"p1":"\'ghi\'","op":"IN","p2":"\'abc\'","p3":"\'def\'","p4":"\'ghi\'"}').value);
        System.assertEquals(   0,   VCG_CPQ_Formula.evaluate('{"p1":"\'jkl\'","op":"IN","p2":"\'abc\'","p3":"\'def\'","p4":"\'ghi\'"}').value);
        
        // These date fields should all be available in all orgs
        VCG_CPQ_Quote__c quote = new VCG_CPQ_Quote__c();
        quote.Effective_Date__c = Date.today().addDays(5);
        quote.Expiration_Date__c = Date.today().addDays(5);
        quote.Start_Date__c = Date.today().addDays(5);
        System.assertEquals(   1,   VCG_CPQ_Formula.evaluate(quote, '{"p1":"Effective_Date__c","op":"IN","p2":"Effective_Date__c","p3":"Expiration_Date__c","p4":"Start_Date__c"}').value);
        System.assertEquals(   1,   VCG_CPQ_Formula.evaluate(quote, '{"p1":"Expiration_Date__c","op":"IN","p2":"Effective_Date__c","p3":"Expiration_Date__c","p4":"Start_Date__c"}').value);
        System.assertEquals(   1,   VCG_CPQ_Formula.evaluate(quote, '{"p1":"Start_Date__c","op":"IN","p2":"Effective_Date__c","p3":"Expiration_Date__c","p4":"Start_Date__c"}').value);
        System.assertEquals(   0,   VCG_CPQ_Formula.evaluate(quote, '{"p1":{"op":"TODAY"},"op":"IN","p2":"Effective_Date__c","p3":"Expiration_Date__c","p4":"Start_Date__c"}').value);
        
        //
        // NULL value
        //
        // Note: 'null' is interpreted as an actual null
        //       '"null"' is interpreted as a string with the value qq{null}
        //       '""\'null\'""' would be interpreted as a string with a value of qq{'null'} which we would interpret as a string literal
        //
        //       We choose the middle one as the way to specify a null value (return value) for a formula. Otherwise the first
        //       one would indicate a null formula, not a null value.
        //
        System.assertEquals( null,     VCG_CPQ_Formula.evaluate(qli, '"null"').value);
        System.assertEquals( null,     VCG_CPQ_Formula.evaluate(qli, '"null"').str_val);
        System.assertEquals( null,     VCG_CPQ_Formula.evaluate(qli, '"null"').obj_val);
        System.assertEquals( null,     VCG_CPQ_Formula.evaluate(qli, '{"op":"IF","p1":1,"p2":"null","p3":"\'No\'"}').value);
        System.assertEquals( null,     VCG_CPQ_Formula.evaluate(qli, '{"op":"IF","p1":1,"p2":"null","p3":"\'No\'"}').str_val);
        System.assertEquals( null,     VCG_CPQ_Formula.evaluate(qli, '{"op":"IF","p1":1,"p2":"null","p3":"\'No\'"}').obj_val);
        // Note: json_deserialize takes this and turns it into an actual null value for the entire formula.
        // For now we throw an error for it. Can't think of a reason we would need this.
        // See comments above.
//        System.assertEquals( null,     VCG_CPQ_Formula.evaluate(qli, 'null').value);
        
        //
        // Exceptions
        //
       // VCG_CPQ_Quote_Product__c tempObject  = new VCG_CPQ_Quote_Product__c();
        // System.assertEquals( null,  VCG_CPQ_Formula.evaluate(tempObject, '{"op":"+","p1":"","p2":""}').value);
    }
    
    /**
     * @description
     * @author  Lawrence Coffin <lawrence.coffin@cloudsherpas.com>
     * @since   16.Apr.2014
     */
    static testMethod void testMutliSelectFormulas() {
        // Idea is the a standard SF object with a multi-select picklit standard field
        Account acct = new Account();
        acct.Description = 'One;Two;Five;Twelve';
        
        //
        // Multi-Select Picklist INCLUDES function
        //
        System.assertEquals( 1, VCG_CPQ_Formula.evaluate('{"op":"INCLUDES","p1":"\'a;b;c\'","p2":"\'a\'"}').value);
        System.assertEquals( 1, VCG_CPQ_Formula.evaluate('{"op":"INCLUDES","p1":"\'a;b;c\'","p2":"\'b\'"}').value);
        System.assertEquals( 1, VCG_CPQ_Formula.evaluate('{"op":"INCLUDES","p1":"\'a;b;c\'","p2":"\'c\'"}').value);
        System.assertEquals( 0, VCG_CPQ_Formula.evaluate('{"op":"INCLUDES","p1":"\'a;b;c\'","p2":"\'d\'"}').value);
        
        System.assertEquals( 1, VCG_CPQ_Formula.evaluate(acct, '{"op":"INCLUDES","p1":"Description","p2":"\'Five\'"}').value);
        System.assertEquals( 0, VCG_CPQ_Formula.evaluate(acct, '{"op":"INCLUDES","p1":"Description","p2":"\'Seven\'"}').value);
    }
    
    /**
     * @description
     * @author  Lawrence Coffin <lawrence.coffin@cloudsherpas.com>
     * @since   13.Mar.2014
     */
    static testMethod void testPriorCalRefFormulas() {
        // Quote Product record to use for testing field references
        // Fill with arbitraty values
        VCG_CPQ_Quote_Product__c qli = new VCG_CPQ_Quote_Product__c( );
        qli.Quantity__c = 95;
        qli.License_Metric_Quantity__c = 27;
        qli.Sales_Price__c = 84.75;
        qli.Quote__r = new VCG_CPQ_Quote__c();
        qli.Quote__r.Total__c = 1234.56;
        qli.Quote__r.Account__r = new Account();
        qli.Quote__r.Account__r.AnnualRevenue = 875000;
        
        // Populate some prior calculation results
        Map<String,Map<String,Object>> Results = new Map<String,Map<String,Object>>();
        // Result for LP00 is 24.75 (a list price for example)
        Results.put('LP00', new Map<String,Object>{ 'ResultValue' => 24.75 });
        // Result for C00 is 750 (a discount for example)
        Results.put('C00', new Map<String,Object>{ 'ResultValue' => 750, 'ResultType' => 'Currency Amount' });
        
        //
        // Test prior calculation references
        //
        System.assertEquals(                   24.75,    VCG_CPQ_Formula.evaluate(qli, Results, null, '"$Results.LP00.ResultValue"').value);
        System.assertEquals( ((24.75 * 95) - 750)/95,    VCG_CPQ_Formula.evaluate(qli, Results, null, '{"op":"/","p1":{"op":"-","p1":{"op":"*","p1":"$Results.LP00.ResultValue","p2":"Quantity__c"},"p2":"$Results.C00.ResultValue"},"p2":"Quantity__c"}').value);
        
        //
        //Exceptions
        //
        
         //System.assertEquals(  24.75,    VCG_CPQ_Formula.evaluate(qli, Results, null, '' ).value);
    }
    
    
    /**
     * @description
     * @author  Lawrence Coffin <lawrence.coffin@cloudsherpas.com>
     * @since   13.Mar.2014
     */
    static testMethod void testSystemRefs() {
        // Select various standard fields that are and are not available through UserInfo
        // (so we can test formula values that come from both UserInfo and from querying the user record directly)
        // Note: we use standard fields in lieu of any custom fields, but custom fields should work as well.
        User u = [SELECT Id,
                         FirstName,
                         LastName,
                         Email,
                         CompanyName,
                         EmailEncodingKey,
                         LanguageLocaleKey,
                         LocaleSidKey,
                         TimeZoneSidKey,
                         CreatedDate,
                         IsActive // Anyone running these tests should be active
                   FROM User
                   WHERE Id = :UserInfo.getUserId()];
        //
        // Test Current User references
        //
        System.assertEquals( u.Id,                      VCG_CPQ_Formula.evaluate('"$User.Id"').str_val);
        System.assertEquals( u.FirstName,               VCG_CPQ_Formula.evaluate('"$User.FirstName"').str_val);
        System.assertEquals( u.LastName,                VCG_CPQ_Formula.evaluate('"$User.LastName"').str_val);
        System.assertEquals( u.Email,                   VCG_CPQ_Formula.evaluate('"$User.Email"').str_val);
        System.assertEquals( u.CompanyName,             VCG_CPQ_Formula.evaluate('"$User.CompanyName"').str_val);
        System.assertEquals( u.EmailEncodingKey,        VCG_CPQ_Formula.evaluate('"$User.EmailEncodingKey"').str_val);
        System.assertEquals( u.LanguageLocaleKey,       VCG_CPQ_Formula.evaluate('"$User.LanguageLocaleKey"').str_val);
        System.assertEquals( u.LocaleSidKey,            VCG_CPQ_Formula.evaluate('"$User.LocaleSidKey"').str_val);
        System.assertEquals( u.TimeZoneSidKey,          VCG_CPQ_Formula.evaluate('"$User.TimeZoneSidKey"').str_val);
        System.assertEquals( u.CreatedDate,   (DateTime)VCG_CPQ_Formula.evaluate('"$User.CreatedDate"').obj_val);
        System.assertEquals( 1,                         VCG_CPQ_Formula.evaluate('"$User.IsActive"').value);
    }
    
    
    /**
     * @description
     * @author  Lawrence Coffin <lawrence.coffin@cloudsherpas.com>
     * @since   13.Mar.2014
     */
    static testMethod void testBoolean() {
        // Quote Product record to use for testing field references
        // Fill with arbitraty values
        VCG_CPQ_Quote_Product__c qli = new VCG_CPQ_Quote_Product__c( );
        qli.Line_Type__c = 'New';
        qli.Quantity__c = 95;
        qli.License_Metric_Quantity__c = 27;
        qli.Sales_Price__c = 84.75;
        qli.Quote__r = new VCG_CPQ_Quote__c();
        qli.Quote__r.Total__c = 1234.56;
        qli.Quote__r.Account__r = new Account();
        qli.Quote__r.Account__r.AnnualRevenue = 875000;
        qli.Asset_Term_Start_Date__c = Date.today().addDays(30);
        
        //
        // Test literal 'true' and 'false' values
        //
        System.assertEquals( 1,    VCG_CPQ_Formula.evaluate('"true"').value);
        System.assertEquals( 0,    VCG_CPQ_Formula.evaluate('"false"').value);
        System.assertEquals( 1,    VCG_CPQ_Formula.evaluate('{"op":"==","p1":1,"p2":"true"}').value);
        System.assertEquals( 1,    VCG_CPQ_Formula.evaluate('{"op":"==","p1":"true","p2":1}').value);
        System.assertEquals( 1,    VCG_CPQ_Formula.evaluate('{"op":"==","p1":0,"p2":"false"}').value);
        System.assertEquals( 0,    VCG_CPQ_Formula.evaluate('{"op":"==","p1":0,"p2":"true"}').value);
        System.assertEquals( 0,    VCG_CPQ_Formula.evaluate('{"op":"==","p1":"true","p2":"false"}').value);
        
        //
        // Test '==' comparison operator
        //
        System.assertEquals( 1,    VCG_CPQ_Formula.evaluate(qli, '{"op":"==","p1":1,"p2":1.00}').value);
        System.assertEquals( 0,    VCG_CPQ_Formula.evaluate(qli, '{"op":"==","p1":0,"p2":1.00}').value);
        
        //
        // Test special use of '==' comparison operator -- comparing a reference to null
        //
        System.assertEquals( 1,    VCG_CPQ_Formula.evaluate(qli, '{"op":"==","p1":"Asset__r","p2":"null"}').value);
        System.assertEquals( 0,    VCG_CPQ_Formula.evaluate(qli, '{"op":"==","p1":"Quote__r","p2":"null"}').value);
        System.assertEquals( 0,    VCG_CPQ_Formula.evaluate(qli, '{"op":"==","p1":"Quote__r.Account__r","p2":"null"}').value);
        
        //
        // Test '!=' comparison operator
        //
        System.assertEquals( 0,    VCG_CPQ_Formula.evaluate(qli, '{"op":"!=","p1":1,"p2":1.00}').value);
        System.assertEquals( 1,    VCG_CPQ_Formula.evaluate(qli, '{"op":"!=","p1":0,"p2":1.00}').value);
        
        //
        // Test special use of '!=' comparison operator -- comparing a reference to null
        //
        System.assertEquals( 0,    VCG_CPQ_Formula.evaluate(qli, '{"op":"!=","p1":"Asset__r","p2":"null"}').value);
        System.assertEquals( 1,    VCG_CPQ_Formula.evaluate(qli, '{"op":"!=","p1":"Quote__r","p2":"null"}').value);
        System.assertEquals( 1,    VCG_CPQ_Formula.evaluate(qli, '{"op":"!=","p1":"Quote__r.Account__r","p2":"null"}').value);
        
        //
        // Test '>' comparison operator
        //
        System.assertEquals( 1,    VCG_CPQ_Formula.evaluate(qli, '{"op":">","p1":5,"p2":1.00}').value);
        System.assertEquals( 0,    VCG_CPQ_Formula.evaluate(qli, '{"op":">","p1":5,"p2":5.00}').value);
        System.assertEquals( 0,    VCG_CPQ_Formula.evaluate(qli, '{"op":">","p1":1,"p2":5.00}').value);
        
        //
        // Test '<' comparison operator
        //
        System.assertEquals( 0,    VCG_CPQ_Formula.evaluate(qli, '{"op":"<","p1":5,"p2":1.00}').value);
        System.assertEquals( 0,    VCG_CPQ_Formula.evaluate(qli, '{"op":"<","p1":5,"p2":5.00}').value);
        System.assertEquals( 1,    VCG_CPQ_Formula.evaluate(qli, '{"op":"<","p1":1,"p2":5.00}').value);
        
        //
        // Test '>=' comparison operator
        //
        System.assertEquals( 1,    VCG_CPQ_Formula.evaluate(qli, '{"op":">=","p1":5,"p2":1.00}').value);
        System.assertEquals( 1,    VCG_CPQ_Formula.evaluate(qli, '{"op":">=","p1":5,"p2":5.00}').value);
        System.assertEquals( 0,    VCG_CPQ_Formula.evaluate(qli, '{"op":">=","p1":1,"p2":5.00}').value);
        
        //
        // Test '<=' comparison operator
        //
        System.assertEquals( 0,    VCG_CPQ_Formula.evaluate(qli, '{"op":"<=","p1":5,"p2":1.00}').value);
        System.assertEquals( 1,    VCG_CPQ_Formula.evaluate(qli, '{"op":"<=","p1":5,"p2":5.00}').value);
        System.assertEquals( 1,    VCG_CPQ_Formula.evaluate(qli, '{"op":"<=","p1":1,"p2":5.00}').value);
        
        //
        // String literal '=='  -- literals are: qq{ 'xyz' } -- i.e. { IF(Quote__r.Status__c == 'Pending') } - comparison is case insensitve
        //
        System.assertEquals( 1,    VCG_CPQ_Formula.evaluate(qli, '{"op":"==","p1":"\'one\'","p2":"\'One\'"}').value);
        System.assertEquals( 0,    VCG_CPQ_Formula.evaluate(qli, '{"op":"==","p1":"\'fish\'","p2":"\'banana\'"}').value);
        System.assertEquals( 1,    VCG_CPQ_Formula.evaluate(qli, '{"op":"==","p1":"\'new\'","p2":"Line_Type__c"}').value);
        System.assertEquals( 1,    VCG_CPQ_Formula.evaluate(qli, '{"op":"==","p1":"Line_Type__c","p2":"\'New\'"}').value);
        System.assertEquals( 0,    VCG_CPQ_Formula.evaluate(qli, '{"op":"==","p1":"Line_Type__c","p2":"\'Extension\'"}').value);
        
        //
        // String literal '!='
        //
        System.assertEquals( 0,    VCG_CPQ_Formula.evaluate(qli, '{"op":"!=","p1":"\'one\'","p2":"\'One\'"}').value);
        System.assertEquals( 1,    VCG_CPQ_Formula.evaluate(qli, '{"op":"!=","p1":"\'fish\'","p2":"\'banana\'"}').value);
        
        //
        // Boolean AND ('&&')
        //
        System.assertEquals( 0,    VCG_CPQ_Formula.evaluate(qli, '{"op":"&&","p1":0,"p2":0}').value);
        System.assertEquals( 0,    VCG_CPQ_Formula.evaluate(qli, '{"op":"&&","p1":1,"p2":0}').value);
        System.assertEquals( 0,    VCG_CPQ_Formula.evaluate(qli, '{"op":"&&","p1":0,"p2":1}').value);
        System.assertEquals( 1,    VCG_CPQ_Formula.evaluate(qli, '{"op":"&&","p1":1,"p2":1}').value);
        
        //
        // Boolean AND ('AND')
        //
        System.assertEquals( 0,    VCG_CPQ_Formula.evaluate(qli, '{"op":"AND","p1":0,"p2":0}').value);
        System.assertEquals( 0,    VCG_CPQ_Formula.evaluate(qli, '{"op":"AND","p1":1,"p2":0}').value);
        System.assertEquals( 0,    VCG_CPQ_Formula.evaluate(qli, '{"op":"AND","p1":0,"p2":1}').value);
        System.assertEquals( 1,    VCG_CPQ_Formula.evaluate(qli, '{"op":"AND","p1":1,"p2":1}').value);
        
        //
        // Boolean OR ('||')
        //
        System.assertEquals( 0,    VCG_CPQ_Formula.evaluate(qli, '{"op":"||","p1":0,"p2":0}').value);
        System.assertEquals( 1,    VCG_CPQ_Formula.evaluate(qli, '{"op":"||","p1":1,"p2":0}').value);
        System.assertEquals( 1,    VCG_CPQ_Formula.evaluate(qli, '{"op":"||","p1":0,"p2":1}').value);
        System.assertEquals( 1,    VCG_CPQ_Formula.evaluate(qli, '{"op":"||","p1":1,"p2":1}').value);
        
        //
        // Boolean OR ('OR')
        //
        System.assertEquals( 0,    VCG_CPQ_Formula.evaluate(qli, '{"op":"OR","p1":0,"p2":0}').value);
        System.assertEquals( 1,    VCG_CPQ_Formula.evaluate(qli, '{"op":"OR","p1":1,"p2":0}').value);
        System.assertEquals( 1,    VCG_CPQ_Formula.evaluate(qli, '{"op":"OR","p1":0,"p2":1}').value);
        System.assertEquals( 1,    VCG_CPQ_Formula.evaluate(qli, '{"op":"OR","p1":1,"p2":1}').value);
        
        //
        // Boolean NOT (unary, '!')
        //
        System.assertEquals( 1,    VCG_CPQ_Formula.evaluate('{"op":"!","p1":0}').value);
        System.assertEquals( 0,    VCG_CPQ_Formula.evaluate('{"op":"!","p1":1}').value);
        
        //
        // Boolean NOT (unary, 'NOT')
        //
        System.assertEquals( 1,    VCG_CPQ_Formula.evaluate('{"op":"NOT","p1":0}').value);
        System.assertEquals( 0,    VCG_CPQ_Formula.evaluate('{"op":"NOT","p1":1}').value);
        
        
        //
        // IF( <test>, <then>, <else> )
        //
        System.assertEquals( 5.0,    VCG_CPQ_Formula.evaluate(qli, '{"op":"IF","p1":1,"p2":5,"p3":3}').value);
        System.assertEquals( 3.0,    VCG_CPQ_Formula.evaluate(qli, '{"op":"IF","p1":0,"p2":5,"p3":3}').value);
        
        
        //
        // Confirm that '&&', '||' and 'IF' all short-circuit -- if the first parameter of the '&&'
        // or the '||' are true then the second parameter should not get evaluated. If the 'IF'
        // test is TRUE, then the third parameter should not get evaluated. If the 'IF' test is
        // false then the second parameter should not get evaluated.
        //
        System.assertEquals( 0,      VCG_CPQ_Formula.evaluate(qli, '{"op":"&&","p1":0,"p2":"formula error here if evaluated"}').value);
        System.assertEquals( 1,      VCG_CPQ_Formula.evaluate(qli, '{"op":"OR","p1":1,"p2":"formula error here if evaluated"}').value);
        System.assertEquals( 5,    VCG_CPQ_Formula.evaluate(qli, '{"op":"IF","p1":1,"p2":5,"p3":"formula error here if evaluated"}').value);
        System.assertEquals( 3,    VCG_CPQ_Formula.evaluate(qli, '{"op":"IF","p1":0,"p2":"formula error here if evaluated","p3":3}').value);
        
        //
        // Test checkboxes as boolean values
        //
        qli.Quote__r.Is_Primary__c = true;
        System.assertEquals( 1,    VCG_CPQ_Formula.evaluate(qli, '"Quote__r.Is_Primary__c"').value);
        qli.Quote__r.Is_Primary__c = false;
        System.assertEquals( 0,    VCG_CPQ_Formula.evaluate(qli, '"Quote__r.Is_Primary__c"').value);
        
        //
        // Test boolean operators with dates
        //
        System.assertEquals( 0,    VCG_CPQ_Formula.evaluate(qli, '{"op":"==","p1":"Asset_Term_Start_Date__c","p2":{"op":"TODAY"}}').value);
        System.assertEquals( 1,    VCG_CPQ_Formula.evaluate(qli, '{"op":"!=","p1":"Asset_Term_Start_Date__c","p2":{"op":"TODAY"}}').value);
        System.assertEquals( 1,    VCG_CPQ_Formula.evaluate(qli, '{"op":">=","p1":"Asset_Term_Start_Date__c","p2":{"op":"TODAY"}}').value);
        System.assertEquals( 1,    VCG_CPQ_Formula.evaluate(qli, '{"op":">","p1":"Asset_Term_Start_Date__c","p2":{"op":"TODAY"}}').value);
        System.assertEquals( 0,    VCG_CPQ_Formula.evaluate(qli, '{"op":"<=","p1":"Asset_Term_Start_Date__c","p2":{"op":"TODAY"}}').value);
        System.assertEquals( 0,    VCG_CPQ_Formula.evaluate(qli, '{"op":"<","p1":"Asset_Term_Start_Date__c","p2":{"op":"TODAY"}}').value);
        System.assertEquals( 0,    VCG_CPQ_Formula.evaluate(qli, '{"op":"==","p1":"Asset_Term_Start_Date__c","p2":"null"}').value);
        System.assertEquals( 1,    VCG_CPQ_Formula.evaluate(qli, '{"op":"!=","p1":"Asset_Term_Start_Date__c","p2":"null"}').value);
        System.assertEquals( 1,    VCG_CPQ_Formula.evaluate(qli, '{"op":"==","p1":"Asset_Term_End_Date__c","p2":"null"}').value);
        System.assertEquals( 0,    VCG_CPQ_Formula.evaluate(qli, '{"op":"!=","p1":"Asset_Term_End_Date__c","p2":"null"}').value);
        System.assertEquals( 0,    VCG_CPQ_Formula.evaluate(qli, '{"op":"==","p1":"null","p2":"Asset_Term_Start_Date__c"}').value);
        System.assertEquals( 1,    VCG_CPQ_Formula.evaluate(qli, '{"op":"!=","p1":"null","p2":"Asset_Term_Start_Date__c"}').value);
        System.assertEquals( 1,    VCG_CPQ_Formula.evaluate(qli, '{"op":"==","p1":"null","p2":"Asset_Term_End_Date__c"}').value);
        System.assertEquals( 0,    VCG_CPQ_Formula.evaluate(qli, '{"op":"!=","p1":"null","p2":"Asset_Term_End_Date__c"}').value);
        System.assertEquals( 0,    VCG_CPQ_Formula.evaluate(qli, '{"op":"==","p1":"Asset_Term_Start_Date__c","p2":"Asset_Term_End_Date__c"}').value);
        System.assertEquals( 1,    VCG_CPQ_Formula.evaluate(qli, '{"op":"!=","p1":"Asset_Term_Start_Date__c","p2":"Asset_Term_End_Date__c"}').value);
        System.assertEquals( 0,    VCG_CPQ_Formula.evaluate(qli, '{"op":"==","p1":"Asset_Term_End_Date__c","p2":"Asset_Term_Start_Date__c"}').value);
        System.assertEquals( 1,    VCG_CPQ_Formula.evaluate(qli, '{"op":"!=","p1":"Asset_Term_End_Date__c","p2":"Asset_Term_Start_Date__c"}').value);
        
        //
        // Extended boolean logic
        //
        
        // Populate some prior calculation results
        Map<String,Map<String,Object>> Results = new Map<String,Map<String,Object>>();
        Results.put('LP00', new Map<String,Object>{ 'ResultValue' => 24.75 });
        
        System.assertEquals( 84.75 * 2,    VCG_CPQ_Formula.evaluate(qli, Results, null, '{"op":"IF","p1":{"op":">","p1":"Quote__r.Account__r.AnnualRevenue","p2":800000},"p2":{"op":"*","p1":"Sales_Price__c","p2":2},"p3":{"op":"/","p1":"$Results.LP00.ResultValue","p2":2}}').value);
        System.assertEquals( 24.75 / 2,    VCG_CPQ_Formula.evaluate(qli, Results, null, '{"op":"IF","p1":{"op":"<","p1":"Quote__r.Account__r.AnnualRevenue","p2":800000},"p2":{"op":"*","p1":"Sales_Price__c","p2":2},"p3":{"op":"/","p1":"$Results.LP00.ResultValue","p2":2}}').value);
    }
    
    
    /**
     * @description
     * @author  Lawrence Coffin <lawrence.coffin@cloudsherpas.com>
     * @since   13.Mar.2014
     */
    static testMethod void testListFunctions() {
        Product2 product1 = new Product2( Product_Type__c = 'Software' );
        Product2 product2 = new Product2( Product_Type__c = 'Software' );
        Product2 product3 = new Product2( Product_Type__c = 'Hardware' );
        
        // Quote record with Quote_Products
        VCG_CPQ_Quote__c quote = new VCG_CPQ_Quote__c( ); // Name = 'Test Quote 01' );
        VCG_CPQ_Quote_Product__c qli1 = new VCG_CPQ_Quote_Product__c(
                                                                      Quote__r = quote,
                                                                      License_Metric_Quantity__c = 25,
                                                                      Sales_Price__c = 8700,
                                                                      Product__r = product1
                                                                    );
        VCG_CPQ_Quote_Product__c qli2 = new VCG_CPQ_Quote_Product__c(
                                                                      Quote__r = quote,
                                                                      License_Metric_Quantity__c = 15,
                                                                      Sales_Price__c = 2400,
                                                                      Product__r = product2
                                                                    );
        VCG_CPQ_Quote_Product__c qli3 = new VCG_CPQ_Quote_Product__c(
                                                                      Quote__r = quote,
                                                                      License_Metric_Quantity__c = 60,
                                                                      Sales_Price__c = 33000,
                                                                      Product__r = product3
                                                                    );

        VCG_CPQ_Data.addChild(quote, 'Quote_Products__r', qli1);
        VCG_CPQ_Data.addChild(quote, 'Quote_Products__r', qli2);
        VCG_CPQ_Data.addChild(quote, 'Quote_Products__r', qli3);
        
        System.assertEquals(3, VCG_CPQ_Data.getChildren(quote, 'Quote_Products__r').size());
        
        //
        // Test SUM( <List>, <Field_to_Sum> [, <Optional_Filter>] ) function
        //
        // Sum all products:
        //    SUM(Quote_Products__r, Sales_Price__c)
        //
        // Sum all 'Software' products:
        //    SUM(Quote_Products__r, Sales_Price__c, Product__r.Product_Type__c == 'Software')
        //
        System.assertEquals( 44100,    VCG_CPQ_Formula.evaluate(quote, '{"op":"SUM","p1":"Quote_Products__r","p2":"Sales_Price__c"}').value);
        System.assertEquals( 11100,    VCG_CPQ_Formula.evaluate(quote, '{"op":"SUM","p1":"Quote_Products__r","p2":"Sales_Price__c","p3":{"op":"==","p1":"Product__r.Product_Type__c","p2":"\'Software\'"}}').value);
        
        System.assertEquals( 44100,    VCG_CPQ_Formula.evaluate(quote, '{"op":"SUM","p1":"Quote_Products__r","p2":{"op":"ROUND","p1":"Sales_Price__c","p2":2}}').value);
        
        //
        // Test COUNT( <List> [, <Optional_Filter>] ) function
        //
        // Count all products:
        //    COUNT(Quote_Products__r)
        //
        // Count all 'Software' products:
        //    COUNT(Quote_Products__r, Product__r.Product_Type__c == 'Software')
        //
        System.assertEquals( 3,    VCG_CPQ_Formula.evaluate(quote, '{"op":"COUNT","p1":"Quote_Products__r"}').value);
        System.assertEquals( 2,    VCG_CPQ_Formula.evaluate(quote, '{"op":"COUNT","p1":"Quote_Products__r","p2":{"op":"==","p1":"Product__r.Product_Type__c","p2":"\'Software\'"}}').value);
        
        //
        // Test MIN( <List>, <Field_to_Min> [, <Optional_Filter>] ) function
        //
        // Min all products:
        //    MIN(Quote_Products__r, Sales_Price__c)
        //
        // Min all 'Software' products:
        //    MIN(Quote_Products__r, Sales_Price__c, Product__r.Product_Type__c == 'Software')
        //
        System.assertEquals( 15,    VCG_CPQ_Formula.evaluate(quote, '{"op":"MIN","p1":"Quote_Products__r","p2":"License_Metric_Quantity__c"}').value);
        System.assertEquals( 25,    VCG_CPQ_Formula.evaluate(quote, '{"op":"MIN","p1":"Quote_Products__r","p2":"License_Metric_Quantity__c","p3":{"op":">","p1":"Sales_Price__c","p2":5000}}').value);
        System.assertEquals( 15,    VCG_CPQ_Formula.evaluate(quote, '{"op":"MIN","p1":"Quote_Products__r","p2":{"op":"ROUND","p1":"License_Metric_Quantity__c","p2":2}}').value);
        //
        // Test MAX( <List>, <Field_to_Max> [, <Optional_Filter>] ) function
        //
        // Max all products:
        //    MAX(Quote_Products__r, Sales_Price__c)
        //
        // Max all 'Software' products:
        //    MAX(Quote_Products__r, Sales_Price__c, Product__r.Product_Type__c == 'Software')
        //
        System.assertEquals( 60,    VCG_CPQ_Formula.evaluate(quote, '{"op":"MAX","p1":"Quote_Products__r","p2":"License_Metric_Quantity__c"}').value);
        System.assertEquals( 25,    VCG_CPQ_Formula.evaluate(quote, '{"op":"MAX","p1":"Quote_Products__r","p2":"License_Metric_Quantity__c","p3":{"op":"==","p1":"Product__r.Product_Type__c","p2":"\'Software\'"}}').value);
        System.assertEquals( 60,    VCG_CPQ_Formula.evaluate(quote, '{"op":"MAX","p1":"Quote_Products__r","p2":{"op":"ROUND","p1":"License_Metric_Quantity__c","p2":2}}').value);
    }
    
    
    /**
     * @description
     * @author  Lawrence Coffin <lawrence.coffin@cloudsherpas.com>
     * @since   13.Mar.2014
     */
    static testMethod void testDateFunctions() {
        // Quote Product record to use for testing field references
        // Fill with arbitraty values
        VCG_CPQ_Quote_Product__c qli = new VCG_CPQ_Quote_Product__c( );
        qli.Asset_Term_Start_Date__c = Date.newInstance(2012, 3, 17);
        qli.Asset_Term_End_Date__c = Date.newInstance(2014, 8, 5);
        
        //
        // Test 'DAYSBETWEEN' function
        //
        // DAYSBETWEEN is *exclusive* of the end day ... i.e. Jan 1 inclusive to Jan 31st exclusive == 30 days
        //
        // Note that <Date>daysBetween() expects the earlier date to be the caller and the later day to be
        // the method parameter
        System.assertEquals( qli.Asset_Term_Start_Date__c.daysBetween(qli.Asset_Term_End_Date__c),
            VCG_CPQ_Formula.evaluate(qli, '{"op":"DAYSBETWEEN","p1":"Asset_Term_Start_Date__c","p2":"Asset_Term_End_Date__c"}').value);
        
        //
        // Test 'NUMDAYS' function
        //
        // NUMDAYS is *inclusive* of both days ... i.e. Jan 1 inclusive to Jan 31st inclusive == 31 days
        //
        // Note that <Date>daysBetween() expects the earlier date to be the caller and the later day to be
        // the method parameter
        System.assertEquals( qli.Asset_Term_Start_Date__c.daysBetween(qli.Asset_Term_End_Date__c) + 1,
            VCG_CPQ_Formula.evaluate(qli, '{"op":"NUMDAYS","p1":"Asset_Term_Start_Date__c","p2":"Asset_Term_End_Date__c"}').value);
        
        //
        // Test 'ADDMONTHS' function
        //
        System.assertEquals( Date.today().addMonths( 10),  VCG_CPQ_Formula.evaluate('{"op":"ADDMONTHS","p1":{"op":"TODAY"},"p2":10}' ).obj_val);
        System.assertEquals( Date.today().addMonths( 12),  VCG_CPQ_Formula.evaluate('{"op":"ADDMONTHS","p1":{"op":"TODAY"},"p2":12}' ).obj_val);
        System.assertEquals( Date.today().addMonths( 14),  VCG_CPQ_Formula.evaluate('{"op":"ADDMONTHS","p1":{"op":"TODAY"},"p2":14}' ).obj_val);
        System.assertEquals( Date.today().addMonths( 24),  VCG_CPQ_Formula.evaluate('{"op":"ADDMONTHS","p1":{"op":"TODAY"},"p2":24}' ).obj_val);
        System.assertEquals( Date.today().addMonths( 36),  VCG_CPQ_Formula.evaluate('{"op":"ADDMONTHS","p1":{"op":"TODAY"},"p2":36}' ).obj_val);
        System.assertEquals( Date.today().addMonths( -2),  VCG_CPQ_Formula.evaluate('{"op":"ADDMONTHS","p1":{"op":"TODAY"},"p2":-2}' ).obj_val);
        System.assertEquals( Date.today().addMonths(-12),  VCG_CPQ_Formula.evaluate('{"op":"ADDMONTHS","p1":{"op":"TODAY"},"p2":-12}').obj_val);
        System.assertEquals( Date.today().addMonths( 24).addDays(-1),  VCG_CPQ_Formula.evaluate('{"p1":{"op":"ADDMONTHS","p1":{"op":"TODAY"},"p2":24},"op":"-","p2":1}').obj_val);
    }
        
    
        
    /**
     * @description
     * @author  Lawrence Coffin <lawrence.coffin@cloudsherpas.com>
     * @since   1.Oct.2014
     */
    static testMethod void testNumMonths() {
        // Quote Product record to use for testing field references
        // Fill with arbitraty values
        VCG_CPQ_Quote_Product__c qli = new VCG_CPQ_Quote_Product__c( );
        //
        // Test 'NUMMONTHS' function
        //
        // NUMMONTHS is *inclusive* of both start and end month ... i.e. Jan 1 inclusive to Dec 31st inclusive == 12 Months
        //
        // Note that <Date>monthsBetween() expects the earlier date to be the caller and the later day to be
        // the method parameter
        
        // Sequence of dates from 1 month to 5 years
        qli.Asset_Term_Start_Date__c = Date.newInstance(2012, 1, 1);
        qli.Asset_Term_End_Date__c = Date.newInstance(2012, 1, 31);
        System.assertEquals( 1, VCG_CPQ_Formula.evaluate(qli, '{"op":"NUMMONTHS","p1":"Asset_Term_Start_Date__c","p2":"Asset_Term_End_Date__c"}').value);
        
        qli.Asset_Term_End_Date__c = Date.newInstance(2012, 12, 31);
        System.assertEquals( 12, VCG_CPQ_Formula.evaluate(qli, '{"op":"NUMMONTHS","p1":"Asset_Term_Start_Date__c","p2":"Asset_Term_End_Date__c"}').value);
        
        qli.Asset_Term_End_Date__c = Date.newInstance(2013, 12, 31);
        System.assertEquals( 24, VCG_CPQ_Formula.evaluate(qli, '{"op":"NUMMONTHS","p1":"Asset_Term_Start_Date__c","p2":"Asset_Term_End_Date__c"}').value);
        
        qli.Asset_Term_End_Date__c = Date.newInstance(2014, 12, 31);
        System.assertEquals( 36, VCG_CPQ_Formula.evaluate(qli, '{"op":"NUMMONTHS","p1":"Asset_Term_Start_Date__c","p2":"Asset_Term_End_Date__c"}').value);
        
        qli.Asset_Term_End_Date__c = Date.newInstance(2015, 12, 31);
        System.assertEquals( 48, VCG_CPQ_Formula.evaluate(qli, '{"op":"NUMMONTHS","p1":"Asset_Term_Start_Date__c","p2":"Asset_Term_End_Date__c"}').value);
        
        qli.Asset_Term_End_Date__c = Date.newInstance(2016, 12, 31);
        System.assertEquals( 60, VCG_CPQ_Formula.evaluate(qli, '{"op":"NUMMONTHS","p1":"Asset_Term_Start_Date__c","p2":"Asset_Term_End_Date__c"}').value);
        
        
        // Sequence of 5 day increments over 9-10 months
        qli.Asset_Term_End_Date__c = Date.newInstance(2012, 9, 20);
        System.assertEquals( 9, VCG_CPQ_Formula.evaluate(qli, '{"op":"NUMMONTHS","p1":"Asset_Term_Start_Date__c","p2":"Asset_Term_End_Date__c"}').value);

        qli.Asset_Term_End_Date__c = Date.newInstance(2012, 9, 25);
        System.assertEquals( 9, VCG_CPQ_Formula.evaluate(qli, '{"op":"NUMMONTHS","p1":"Asset_Term_Start_Date__c","p2":"Asset_Term_End_Date__c"}').value);

        qli.Asset_Term_End_Date__c = Date.newInstance(2012, 9, 30);
        System.assertEquals( 9, VCG_CPQ_Formula.evaluate(qli, '{"op":"NUMMONTHS","p1":"Asset_Term_Start_Date__c","p2":"Asset_Term_End_Date__c"}').value);

        qli.Asset_Term_End_Date__c = Date.newInstance(2012, 10, 1);
        System.assertEquals( 9, VCG_CPQ_Formula.evaluate(qli, '{"op":"NUMMONTHS","p1":"Asset_Term_Start_Date__c","p2":"Asset_Term_End_Date__c"}').value);

        qli.Asset_Term_End_Date__c = Date.newInstance(2012, 10, 5);
        System.assertEquals( 9, VCG_CPQ_Formula.evaluate(qli, '{"op":"NUMMONTHS","p1":"Asset_Term_Start_Date__c","p2":"Asset_Term_End_Date__c"}').value);

        qli.Asset_Term_End_Date__c = Date.newInstance(2012, 10, 10);
        System.assertEquals( 9, VCG_CPQ_Formula.evaluate(qli, '{"op":"NUMMONTHS","p1":"Asset_Term_Start_Date__c","p2":"Asset_Term_End_Date__c"}').value);

        qli.Asset_Term_End_Date__c = Date.newInstance(2012, 10, 13);
        System.assertEquals( 9, VCG_CPQ_Formula.evaluate(qli, '{"op":"NUMMONTHS","p1":"Asset_Term_Start_Date__c","p2":"Asset_Term_End_Date__c"}').value);

        qli.Asset_Term_End_Date__c = Date.newInstance(2012, 10, 17);
        System.assertEquals( 10, VCG_CPQ_Formula.evaluate(qli, '{"op":"NUMMONTHS","p1":"Asset_Term_Start_Date__c","p2":"Asset_Term_End_Date__c"}').value);

        qli.Asset_Term_End_Date__c = Date.newInstance(2012, 10, 20);
        System.assertEquals( 10, VCG_CPQ_Formula.evaluate(qli, '{"op":"NUMMONTHS","p1":"Asset_Term_Start_Date__c","p2":"Asset_Term_End_Date__c"}').value);
        
        
        // Sequence of 5 day increments over 2 years + 9-10 months
        qli.Asset_Term_End_Date__c = Date.newInstance(2014, 9, 20);
        System.assertEquals( 33, VCG_CPQ_Formula.evaluate(qli, '{"op":"NUMMONTHS","p1":"Asset_Term_Start_Date__c","p2":"Asset_Term_End_Date__c"}').value);

        qli.Asset_Term_End_Date__c = Date.newInstance(2014, 9, 25);
        System.assertEquals( 33, VCG_CPQ_Formula.evaluate(qli, '{"op":"NUMMONTHS","p1":"Asset_Term_Start_Date__c","p2":"Asset_Term_End_Date__c"}').value);

        qli.Asset_Term_End_Date__c = Date.newInstance(2014, 9, 30);
        System.assertEquals( 33, VCG_CPQ_Formula.evaluate(qli, '{"op":"NUMMONTHS","p1":"Asset_Term_Start_Date__c","p2":"Asset_Term_End_Date__c"}').value);

        qli.Asset_Term_End_Date__c = Date.newInstance(2014, 10, 1);
        System.assertEquals( 33, VCG_CPQ_Formula.evaluate(qli, '{"op":"NUMMONTHS","p1":"Asset_Term_Start_Date__c","p2":"Asset_Term_End_Date__c"}').value);

        qli.Asset_Term_End_Date__c = Date.newInstance(2014, 10, 5);
        System.assertEquals( 33, VCG_CPQ_Formula.evaluate(qli, '{"op":"NUMMONTHS","p1":"Asset_Term_Start_Date__c","p2":"Asset_Term_End_Date__c"}').value);

        qli.Asset_Term_End_Date__c = Date.newInstance(2014, 10, 10);
        System.assertEquals( 33, VCG_CPQ_Formula.evaluate(qli, '{"op":"NUMMONTHS","p1":"Asset_Term_Start_Date__c","p2":"Asset_Term_End_Date__c"}').value);

        qli.Asset_Term_End_Date__c = Date.newInstance(2014, 10, 13);
        System.assertEquals( 33, VCG_CPQ_Formula.evaluate(qli, '{"op":"NUMMONTHS","p1":"Asset_Term_Start_Date__c","p2":"Asset_Term_End_Date__c"}').value);

        qli.Asset_Term_End_Date__c = Date.newInstance(2014, 10, 17);
        System.assertEquals( 34, VCG_CPQ_Formula.evaluate(qli, '{"op":"NUMMONTHS","p1":"Asset_Term_Start_Date__c","p2":"Asset_Term_End_Date__c"}').value);

        qli.Asset_Term_End_Date__c = Date.newInstance(2014, 10, 20);
        System.assertEquals( 34, VCG_CPQ_Formula.evaluate(qli, '{"op":"NUMMONTHS","p1":"Asset_Term_Start_Date__c","p2":"Asset_Term_End_Date__c"}').value);
    }
    
    
    /**
     * @description
     * @author  Lawrence Coffin <lawrence.coffin@cloudsherpas.com>
     * @since   20.Nov.2014
     */
    static testMethod void testRounding() {
        // Quote Product record to use for testing field references
        // Fill with arbitraty values
        VCG_CPQ_Quote_Product__c qli = new VCG_CPQ_Quote_Product__c( );
        qli.Term_Amount__c = 100.3456;
        
        //
        // Test ROUND(<Decimal>, <Precision>) function
        //
        System.assertEquals( 12.35, VCG_CPQ_Formula.evaluate('{"op":"ROUND","p1":12.345,"p2":2}').value);
        System.assertEquals( 12.3 , VCG_CPQ_Formula.evaluate('{"op":"ROUND","p1":12.345,"p2":1}').value);
        System.assertEquals( 12.0 , VCG_CPQ_Formula.evaluate('{"op":"ROUND","p1":12.345,"p2":0}').value);
        
        //
        // Confirm we are using half-up rounding
        //
        System.assertEquals( 1.00, VCG_CPQ_Formula.evaluate('{"op":"ROUND","p1":1.001,"p2":2}').value);
        System.assertEquals( 1.00, VCG_CPQ_Formula.evaluate('{"op":"ROUND","p1":1.002,"p2":2}').value);
        System.assertEquals( 1.00, VCG_CPQ_Formula.evaluate('{"op":"ROUND","p1":1.003,"p2":2}').value);
        System.assertEquals( 1.00, VCG_CPQ_Formula.evaluate('{"op":"ROUND","p1":1.004,"p2":2}').value);
        System.assertEquals( 1.01, VCG_CPQ_Formula.evaluate('{"op":"ROUND","p1":1.005,"p2":2}').value);
        System.assertEquals( 1.01, VCG_CPQ_Formula.evaluate('{"op":"ROUND","p1":1.006,"p2":2}').value);
        System.assertEquals( 1.01, VCG_CPQ_Formula.evaluate('{"op":"ROUND","p1":1.007,"p2":2}').value);
        System.assertEquals( 1.01, VCG_CPQ_Formula.evaluate('{"op":"ROUND","p1":1.008,"p2":2}').value);
        System.assertEquals( 1.01, VCG_CPQ_Formula.evaluate('{"op":"ROUND","p1":1.009,"p2":2}').value);
        System.assertEquals( 1.01, VCG_CPQ_Formula.evaluate('{"op":"ROUND","p1":1.010,"p2":2}').value);
        System.assertEquals( 1.01, VCG_CPQ_Formula.evaluate('{"op":"ROUND","p1":1.011,"p2":2}').value);
        System.assertEquals( 1.01, VCG_CPQ_Formula.evaluate('{"op":"ROUND","p1":1.012,"p2":2}').value);
        System.assertEquals( 1.01, VCG_CPQ_Formula.evaluate('{"op":"ROUND","p1":1.013,"p2":2}').value);
        System.assertEquals( 1.01, VCG_CPQ_Formula.evaluate('{"op":"ROUND","p1":1.014,"p2":2}').value);
        System.assertEquals( 1.02, VCG_CPQ_Formula.evaluate('{"op":"ROUND","p1":1.015,"p2":2}').value);
        System.assertEquals( 1.02, VCG_CPQ_Formula.evaluate('{"op":"ROUND","p1":1.016,"p2":2}').value);
        System.assertEquals( 1.02, VCG_CPQ_Formula.evaluate('{"op":"ROUND","p1":1.017,"p2":2}').value);
        System.assertEquals( 1.02, VCG_CPQ_Formula.evaluate('{"op":"ROUND","p1":1.018,"p2":2}').value);
        System.assertEquals( 1.02, VCG_CPQ_Formula.evaluate('{"op":"ROUND","p1":1.019,"p2":2}').value);
        System.assertEquals( 1.02, VCG_CPQ_Formula.evaluate('{"op":"ROUND","p1":1.020,"p2":2}').value);
        System.assertEquals( 1.02, VCG_CPQ_Formula.evaluate('{"op":"ROUND","p1":1.021,"p2":2}').value);
        System.assertEquals( 1.02, VCG_CPQ_Formula.evaluate('{"op":"ROUND","p1":1.022,"p2":2}').value);
        System.assertEquals( 1.02, VCG_CPQ_Formula.evaluate('{"op":"ROUND","p1":1.023,"p2":2}').value);
        System.assertEquals( 1.02, VCG_CPQ_Formula.evaluate('{"op":"ROUND","p1":1.024,"p2":2}').value);
        System.assertEquals( 1.03, VCG_CPQ_Formula.evaluate('{"op":"ROUND","p1":1.025,"p2":2}').value);
        System.assertEquals( 1.03, VCG_CPQ_Formula.evaluate('{"op":"ROUND","p1":1.026,"p2":2}').value);
        System.assertEquals( 1.03, VCG_CPQ_Formula.evaluate('{"op":"ROUND","p1":1.027,"p2":2}').value);
        System.assertEquals( 1.03, VCG_CPQ_Formula.evaluate('{"op":"ROUND","p1":1.028,"p2":2}').value);
        System.assertEquals( 1.03, VCG_CPQ_Formula.evaluate('{"op":"ROUND","p1":1.029,"p2":2}').value);
        System.assertEquals( 1.03, VCG_CPQ_Formula.evaluate('{"op":"ROUND","p1":1.030,"p2":2}').value);

        //
        // From a field
        //
        System.assertEquals( 100.346, VCG_CPQ_Formula.evaluate(qli, '{"op":"ROUND","p1":"Term_Amount__c","p2":3}').value);
        System.assertEquals( 100.35 , VCG_CPQ_Formula.evaluate(qli, '{"op":"ROUND","p1":"Term_Amount__c","p2":2}').value);
        System.assertEquals( 100.3  , VCG_CPQ_Formula.evaluate(qli, '{"op":"ROUND","p1":"Term_Amount__c","p2":1}').value);
        System.assertEquals( 100.0  , VCG_CPQ_Formula.evaluate(qli, '{"op":"ROUND","p1":"Term_Amount__c","p2":0}').value);

        System.assertEquals( 2.96,    VCG_CPQ_Formula.evaluate('{"op":"ROUND","p1":2.9632,"p2":2}').value);
        System.assertEquals( 2.964,    VCG_CPQ_Formula.evaluate('{"op":"ROUND","p1":2.9636,"p2":3}').value);
        System.assertEquals( 3,    VCG_CPQ_Formula.evaluate('{"op":"ROUND","p1":2.9636,"p2":0}').value);
        System.assertEquals( 2,    VCG_CPQ_Formula.evaluate('{"op":"ROUND","p1":2.4636,"p2":0}').value);
    }
    
    
    /**
     * @description  This tests the F() formula constructor methods used primarily in unit testing
     * 
     * @author  Lawrence Coffin <lawrence.coffin@cloudsherpas.com>
     * @since   13.Oct.2014
     */
    static testMethod void testFormulaConstructors()
    {
        
        //
        // NOTE: These strings are ordered in the way that it *seems* to generate them in
        //       This may break at any point, or change from org to org, or change depending on the
        //       phase of the moon! If so, then we may need to find alternative ways to generate and/or test these!
        //       But, hopefully this will only change if they change their hash algorithm, which hopefully won't
        //       change very often.
        //
        
        System.assertEquals('{"op":"NOT","p1":"true"}', F('NOT', 'true'));
        
        System.assertEquals('{"op":"+","p1":"List_Price__c","p2":"Uplift_Amount__c"}', F('+', 'List_Price__c', 'Uplift_Amount__c'));
        
        System.assertEquals('{"op":"IF","p1":"true","p2":"Uplift_Amount__c","p3":"Uplift_Percentage__c"}', F('IF', 'true', 'Uplift_Amount__c', 'Uplift_Percentage__c'));
        
        System.assertEquals('{"op":"JOIN","p1":"\'one\'","p2":"\'two\'","p3":"\'three\'","p4":"\'four\'"}', F('JOIN', '\'one\'', '\'two\'', '\'three\'', '\'four\''));
        
        System.assertEquals('{"op":"JOIN","p1":"\'one\'","p2":"\'two\'","p3":"\'three\'","p4":"\'four\'","p5":"\'five\'"}', F('JOIN', '\'one\'', '\'two\'', '\'three\'', '\'four\'', '\'five\''));
        
        // Test numeric
        System.assertEquals('{"op":"+","p1":1,"p2":2}', F('+', 1, 2));
        System.assertEquals('{"op":"+","p1":1.5,"p2":3.2}', F('+', 1.5, 3.2));
        
        // Test nested
        System.assertEquals('{"op":"IF","p1":{"op":">","p1":"Total_Discount__c","p2":20},"p2":{"op":"MAX","p1":0,"p2":{"op":"NUMMONTHS","p1":"Term_Start_Date__c","p2":"Term_End_Date__c"}},"p3":"Quote__r.Contract_Length__c"}',
                                F('IF',
                                    F('>', 'Total_Discount__c', 20),
                                    F('MAX', 
                                        0, 
                                        F('NUMMONTHS', 'Term_Start_Date__c', 'Term_End_Date__c')
                                     ),
                                    'Quote__r.Contract_Length__c'));
    }
    
    /**
     * @description  Unit test to get coverage in a few other areas that are currently missed by the above
     * 
     * @author  Lawrence Coffin <lawrence.coffin@cloudsherpas.com>
     * @since   13.Mar.2014
     */
    static testMethod void testForCodeCoverage()
    {
        // Execute Node class code
        VCG_CPQ_Formula.Node node = new VCG_CPQ_Formula.Node();
        
        // Execute null formula error line
        try {  VCG_CPQ_Formula.evaluate(null, null, null, null); System.assert(false, 'Shouldn\'t get here!'); }
        catch (Exception e) { System.assert(e.getMessage().contains('No JSON formula')); }
        
        // Execute null formula error line
        try {  VCG_CPQ_Formula.evaluate('{"op":"+","p1":20}'); System.assert(false, 'Shouldn\'t get here!'); } // no p2
        catch (Exception e) { System.assert(e.getMessage().contains('Null formula')); }
        
        // Execute null formula error line
        try {  VCG_CPQ_Formula.evaluate('{"op":"+","p1":20,"p2":"$Results.Something.ResultValue"}'); System.assert(false, 'Shouldn\'t get here!'); }
        catch (Exception e) { System.assert(e.getMessage().contains('Invalid formula reference')); }
        
        // Execute '_debug' code
        System.assertEquals(   50,    VCG_CPQ_Formula.evaluate('{"_debug":"true","op":"+","p1":20,"p2":30}').value);
        
        // Execute getFieldLabel()
        System.assertEquals(   'First Name',    VCG_CPQ_Formula.getFieldLabel('Contact','FirstName'));
        
        // Execute invalid op error line
        try {  VCG_CPQ_Formula.evaluate('{"op":"##X##","p1":20,"p2":30}'); System.assert(false, 'Shouldn\'t get here!'); }
        catch (Exception e) { System.assert(e.getMessage().contains('Unknown operator')); }
        
        // Execute ADDMONTHS error line
        try { VCG_CPQ_Formula.evaluate('{"_debug":"true","op":"ADDMONTHS","p1":20,"p2":10}' ); System.assert(false, 'Shouldn\'t get here!'); }
        catch (Exception e) { System.assert(e.getMessage().contains('first parameter should be of type Date'), 'Got: ' + e.getMessage()); }
        
        // Execute ADDMONTHS error line
        try { VCG_CPQ_Formula.evaluate('{"op":"ADDMONTHS","p1":{"op":"TODAY"},"p2":"\'fish\'"}' ); System.assert(false, 'Shouldn\'t get here!'); }
        catch (Exception e) { System.assert(e.getMessage().contains('second parameter should be of type Decimal'), 'Got: ' + e.getMessage()); }
        
    }
    
    
    // Localized F() methods to make it easier to call
    static String F(String op, Object p1) { return VCG_CPQ_Formula.F(op, p1); }
    static String F(String op, Object p1, Object p2) { return VCG_CPQ_Formula.F(op, p1, p2); }
    static String F(String op, Object p1, Object p2, Object p3) { return VCG_CPQ_Formula.F(op, p1, p2, p3); }
    static String F(String op, Object p1, Object p2, Object p3, Object p4) { return VCG_CPQ_Formula.F(op, p1, p2, p3, p4); }
    static String F(String op, Object p1, Object p2, Object p3, Object p4, Object p5) { return VCG_CPQ_Formula.F(op, p1, p2, p3, p4, p5); }
     
/**/    
}