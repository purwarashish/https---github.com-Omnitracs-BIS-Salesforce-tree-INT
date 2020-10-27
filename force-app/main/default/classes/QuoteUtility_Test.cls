/**
 * Unit tests for QuoteUtility class
 *
 * @author  Lawrence Coffin <lawrence.coffin@cloudsherpas.com>
 * @since   1.Dec.2014
 */
@isTest(SeeAllData=True)
private class QuoteUtility_Test {
    
    /**
     * Test QuoteUtility.setMSADocIds() basic functionality
     *
     * @author  Lawrence Coffin <lawrence.coffin@cloudsherpas.com>
     * @since   1.Dec.2014
     */
    static testMethod void testSetMSADocIds() {
        //
        // create the Product Contract Template Objects
        //
        list<Product_Contract_Template__c> pdt 
           = new list<Product_Contract_Template__c>{
             new Product_Contract_Template__c ( Template_Type__c = 'Output MSA Template'
                                               ,Status__c        = 'Active'
                                               ,Name             = 'Omnitracs Master Contract for Equipment Software and Service'
                                               ,Description__c   = 'Test'
                                               ,Contract_Template_Id__c = '01550000001Qbby'
                                               ,Contract_Category_2__c  = 'Production'
                                               ,Contract_Category_1__c  = 'Master'
                                               ,Agreement_Type__c       = 'Master'),
             new Product_Contract_Template__c ( Template_Type__c = 'Output Schedule Template'
                                               ,Status__c        = 'Active'
                                               ,Name             = 'Omnitracs PSA Contract for Equipment Software and Service'
                                               ,Description__c   = 'Test'
                                               ,Contract_Template_Id__c = '01550000001QbgT'
                                               ,Contract_Category_2__c  = 'Advanced Mapping Interface'
                                               ,Contract_Category_1__c  = 'Global Application Terms'
                                               ,Agreement_Type__c       = 'Attached Agreement'),
             new Product_Contract_Template__c ( Template_Type__c = 'Output Schedule Template'
                                               ,Status__c        = 'Active'
                                               ,Name             = 'MCP100S Schedule'
                                               ,Description__c   = 'Test'
                                               ,Contract_Template_Id__c = '01550000001jJJy'
                                               ,Contract_Category_2__c  = 'Production'
                                               ,Contract_Category_1__c  = 'MCP100S'
                                               ,Agreement_Type__c       = 'Schedule'),
             new Product_Contract_Template__c ( Template_Type__c = 'Output Standard SOW Template'
                                               ,Status__c        = 'Active'
                                               ,Name             = 'Media Manager Service Application'
                                               ,Description__c   = 'Test'
                                               ,Contract_Template_Id__c = '01550000001QbgR'
                                               ,Contract_Category_2__c  = 'Media Manager'
                                               ,Contract_Category_1__c  = 'Global Application Terms'
                                               ,Agreement_Type__c       = 'Attached Agreement')};
        
        insert pdt;
        
        //
        // Add some products with various MSA template ids (use dummy Ids for now)
        //
        Product2 prod1 = new Product2( Name = 'Test Product A', ProductCode = 'TEST-AAA', Output_MSA_Template__c = '0x0100000000001'
                                      ,Output_MSA_Document_Template__c =pdt.get(0).Id
                                      ,Output_PSA_Document_Template__c =pdt.get(1).Id
                                      ,Output_Standard_SOW_Document_Template__c =pdt.get(3).Id
                                      ,Output_Schedule_Document_Template__c     =pdt.get(2).Id);
        Product2 prod2 = new Product2( Name = 'Test Product B', ProductCode = 'TEST-BBB', Output_MSA_Template__c = '0x0100000000002');
        Product2 prod3 = new Product2( Name = 'Test Product C', ProductCode = 'TEST-CCC', Output_MSA_Template__c = '0x0100000000003AAB');
        Product2 prod4 = new Product2( Name = 'Test Product D', ProductCode = 'TEST-DDD', Output_MSA_Template__c = '0x0100000000004');
        // use a product with a null value to confirm no blanks/empty values show up in the id list
        Product2 prod5 = new Product2( Name = 'Test Product E', ProductCode = 'TEST-EEE', Output_MSA_Template__c = null);
        
        insert new List<Product2>{ prod1, prod2, prod3, prod4, prod5 };
        
        System.assert(prod1.Id!=null,'prod1 Insertion Failed');
        System.assert(prod2.Id!=null,'prod2 Insertion Failed');
        System.assert(prod3.Id!=null,'prod4 Insertion Failed');
        System.assert(prod5.Id!=null,'prod5 Insertion Failed');
        
        
        
        List<Product2> lstProd1 = new List<Product2>();
        lstProd1.add(prod1);
        lstProd1.add(prod2);
        lstProd1.add(prod3);
        List<Product2> lstProd = [Select id,Output_MSA_Template__c from Product2 where id In : lstProd1];
        for(Product2 P: lstProd )
        {
            System.assert(P.Output_MSA_Template__c!=null,'Output_MSA_Template__c ');
        }
        //
        // Add an Account
        //
        Account acct = new Account( Name = 'Test Account' );
        insert acct;
       
        // Add an Opp
        //
        Opportunity opp = new Opportunity( Name = 'Test Opp', AccountId = acct.Id, StageName = 'Sales Acceptance', CloseDate = Date.today().addDays(7),Geo_Region__c='LATAM' );
        insert opp;
        System.assert(opp.Id!=null,'Quote Insertion Failed');
        //
        // Add a Quote
        //
        VCG_CPQ_Quote__c quote = new VCG_CPQ_Quote__c( Opportunity__c = opp.Id, Account__c = acct.Id );
        insert quote;
        System.assert(quote.Id!=null,'Quote Insertion Failed');
        //
        // Add Quote Product records for the above products - skip prod4 to confirm that not all products are being included
        //
        VCG_CPQ_Quote_Product__c qpRec1 = new VCG_CPQ_Quote_Product__c( Quote__c = quote.Id, Product__c = prod1.Id );
        VCG_CPQ_Quote_Product__c qpRec2 = new VCG_CPQ_Quote_Product__c( Quote__c = quote.Id, Product__c = prod2.Id );
        VCG_CPQ_Quote_Product__c qpRec3 = new VCG_CPQ_Quote_Product__c( Quote__c = quote.Id, Product__c = prod3.Id );
        VCG_CPQ_Quote_Product__c qpRec5 = new VCG_CPQ_Quote_Product__c( Quote__c = quote.Id, Product__c = prod5.Id );
        insert new List<VCG_CPQ_Quote_Product__c>{ qpRec1, qpRec2, qpRec3, qpRec5 };
        
        QuoteUtility.generateContractDocumentIds(quote.Id);
        
        //
        // Confirm that the Quote MSA IDs field is set to the correct value
        //
        VCG_CPQ_Quote__c quoteCopy = [SELECT MSA_Documents__c FROM VCG_CPQ_Quote__c WHERE Id = :quote.Id][0];
        //System.assertNotEquals(null, quoteCopy.MSA_Documents__c);
        
        // Need to sort the list to make it easier to test (trigger code doesn't guarantee sort order)
        //List<String> quoteMSAsList = quoteCopy.MSA_Documents__c.split(',');
        //quoteMSAsList.sort();
        //System.assertEquals('0x0100000000001,0x0100000000002,0x0100000000003', String.join(quoteMSAsList, ','));
    }
}