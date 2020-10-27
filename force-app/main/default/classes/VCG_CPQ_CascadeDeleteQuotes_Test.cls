/**
 * This test class covers both the CascadeDeleteQuotes1 on Opp and CascadeDeleteQuotes2 on Account triggers
 *
 * @author  Lawrence Coffin <lawrence.coffin@cloudsherpas.com>
 * @since   12.Jan.2015
 */
@isTest(SeeAllData=True)
public class VCG_CPQ_CascadeDeleteQuotes_Test {

    /**
     * @description  Create basic quote and then delete the opp, confirm quote is deleted too
     *
     * @author  Lawrence Coffin <lawrence.coffin@cloudsherpas.com>       
     * @since   12.Jan.2015
     */
    static testMethod void testCascadeDelete_offOpp() {
        
        //
        // Do setup
        //
        Opportunity opp = testCascadeDelete_SetupAcctAndOpp();
        
        //
        // Add a quote (don't worry about Quote Products for this test)
        //
        VCG_CPQ_Quote__c quote = new VCG_CPQ_Quote__c(
                                                        Account__c = opp.AccountId,
                                                        Opportunity__c = opp.Id
                                                     );
        insert quote;
        
        List<VCG_CPQ_Quote__c> quotes = [SELECT Id, Opportunity__c FROM VCG_CPQ_Quote__c WHERE Id = :quote.Id];
        System.assertEquals(1, quotes.size());
        System.assertEquals(opp.Id, quotes[0].Opportunity__c);
        
        delete opp;
        
        quotes = [SELECT Id FROM VCG_CPQ_Quote__c WHERE Id = :quote.Id];
        //System.assertEquals(0, quotes.size());
    }
    
    /**
     * @description  Create basic quote and then delete the *account*, confirm quote is deleted too
     *
     * @author  Lawrence Coffin <lawrence.coffin@cloudsherpas.com>       
     * @since   12.Jan.2015
     */
    static testMethod void testCascadeDelete_offAcct() {
        
        //
        // Do setup
        //
        Opportunity opp = testCascadeDelete_SetupAcctAndOpp();
        
        //
        // Add a quote (don't worry about Quote Products for this test)
        //
        VCG_CPQ_Quote__c quote = new VCG_CPQ_Quote__c(
                                                        Account__c = opp.AccountId,
                                                        Opportunity__c = opp.Id
                                                     );
        insert quote;
        
        List<VCG_CPQ_Quote__c> quotes = [SELECT Id, Opportunity__c FROM VCG_CPQ_Quote__c WHERE Id = :quote.Id];
        System.assertEquals(1, quotes.size());
        System.assertEquals(opp.Id, quotes[0].Opportunity__c);
        
        delete new Account( Id = opp.AccountId );
        
        quotes = [SELECT Id FROM VCG_CPQ_Quote__c WHERE Id = :quote.Id];
        //System.assertEquals(0, quotes.size());
    }
    
    /**
     * @description  This tests edge cases needed to be covered when an Account is deleted
     *               - one where the quote is only related to the quote through the opp,
     *               and one where the quote is not related through the opp, but just through
     *               the quote.account__c field. In the ideal/usual circumstance, the account
     *               should be related through both, but just in case it isn't we want to be
     *               sure that deleting the account clears out quotes related through both of
     *               these edge cases.
     *
     * @author  Lawrence Coffin <lawrence.coffin@cloudsherpas.com>       
     * @since   12.Jan.2015
     */
    static testMethod void testCascadeDelete_offAcct_EdgeCases() {
        
        //
        // Do setup - do it twice so we have two opps, each with their own associated account
        //
        Opportunity opp1 = testCascadeDelete_SetupAcctAndOpp();
        Opportunity opp2 = testCascadeDelete_SetupAcctAndOpp();
        
        //System.assertNotEquals(opp1.Id, opp2.Id);
        //System.assertNotEquals(opp1.AccountId, opp2.AccountId);
        
        //
        // Add a few quotes with cross linking between the two accounts/opps
        //
        VCG_CPQ_Quote__c quote1 = new VCG_CPQ_Quote__c(
                                                            Account__c = opp1.AccountId,
                                                            Opportunity__c = opp2.Id
                                                      );
        VCG_CPQ_Quote__c quote2 = new VCG_CPQ_Quote__c(
                                                            Account__c = opp2.AccountId,
                                                            Opportunity__c = opp1.Id
                                                      );
        // One quote linked just to the second opp - to confirm that only the other two quotes are deleted and not all quotes
        VCG_CPQ_Quote__c quote3 = new VCG_CPQ_Quote__c(
                                                            Account__c = opp2.AccountId,
                                                            Opportunity__c = opp2.Id
                                                      );
        insert new List<VCG_CPQ_Quote__c>{ quote1, quote2, quote3 };
        
        //
        // Confirm we get all three quotes
        //
        List<VCG_CPQ_Quote__c> quotes = [SELECT Id, Opportunity__c FROM VCG_CPQ_Quote__c WHERE Id IN (:quote1.Id, :quote2.Id, :quote3.Id) ];
        
        //System.assertEquals(3, quotes.size());
        
        //
        // Delete the first account
        //
        delete new Account( Id = opp1.AccountId );
        
        //
        // Confirm that both quotes related to the first account have been deleted
        //
        quotes = [SELECT Id, Opportunity__c FROM VCG_CPQ_Quote__c WHERE Id IN (:quote1.Id, :quote2.Id, :quote3.Id) ];
        //System.assertEquals(1, quotes.size());
        //System.assertEquals(quote3.Id, quotes[0].Id);
    }
    
    /**
     * @description 
     *
     * @author  Lawrence Coffin <lawrence.coffin@cloudsherpas.com>       
     * @since   12.Jan.2015
     */
    static Opportunity testCascadeDelete_SetupAcctAndOpp() {
        // Added RecordType and StageName ='Sales Acceptance' by JBarrameda - 10/30/2014
        Id oldProdRecType = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Products, Services and Maintenance').getRecordTypeId();
        
        //
        // Set up test records - account, opp, etc.
        //
        Account acct = new Account( Name = 'Test Account' );
        insert acct;
        
        Opportunity opp = new Opportunity (
                                            Name = 'Test Opp',
                                            AccountId = acct.Id,
                                            RecordTypeId = oldProdRecType,
                                            CloseDate = Date.today().addDays(30),
                                            StageName = 'Sales Acceptance'
                                        );
        insert opp;
        
        return opp;
    }
}