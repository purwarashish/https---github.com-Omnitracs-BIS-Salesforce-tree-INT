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
*
* @Revision(s): NS: This needs to be revised as follows:    
*               1. Use System.assert: All code outcomes must be asserted to verify expected results
 */
@isTest(SeeAllData=True)
private class VCG_CPQ_SetPrimarQuoteController_test {

    static testMethod void myUnitTest() {
        // TO DO: implement unit test
        //Setting the current page for test
        User depUser = [select Id from User where alias = 'Depuser'];
        System.runas(depUser){
            PageReference pageRef = Page.VCG_CPQ_SetPrimarQuote;
            Test.setCurrentPageReference(pageRef);
            List<VCG_CPQ_Quote__c > QuoteLst = new List<VCG_CPQ_Quote__c >();
            
            Opportunity opp =  VCG_CPQ_HelperTestClass.createOpportunityRecord();
            opp.Geo_Region__c='EMEA'; //Added new value for Opportunity Geo due to FIELD_CUSTOM_VALIDATION_EXCEPTION
            insert opp;
            
            for(integer i=0;i<=20;i++){
              VCG_CPQ_Quote__c newQuote =  VCG_CPQ_HelperTestClass.createQuoteRecord();
              newQuote.Opportunity__c = opp.id;
              QuoteLst.add(newQuote);
            }       
            insert QuoteLst;
            VCG_CPQ_Quote__c newQuote1 =  VCG_CPQ_HelperTestClass.createQuoteRecord();
            newQuote1.Opportunity__c = opp.id;
            insert newQuote1 ;
            
            test.StartTest();
            ApexPages.StandardSetController setcntr = new ApexPages.StandardSetController(QuoteLst);
            setcntr.setSelected(QuoteLst);
            VCG_CPQ_SetPrimarQuoteController cntr = new VCG_CPQ_SetPrimarQuoteController(setcntr );
            cntr.applyPrimaryQuote();
            
            List<VCG_CPQ_Quote__c > QuoteLst1 = new List<VCG_CPQ_Quote__c >();        
            QuoteLst1.add(newQuote1);
            pageRef.getParameters().put('retUrl', opp.id);
            ApexPages.StandardSetController setcntr1 = new ApexPages.StandardSetController(QuoteLst1);
            setcntr.setSelected(QuoteLst1);
            VCG_CPQ_SetPrimarQuoteController cntr1 = new VCG_CPQ_SetPrimarQuoteController(setcntr1 );
            cntr.applyPrimaryQuote();
            
            List<VCG_CPQ_Quote__c > QuoteLst2 = new List<VCG_CPQ_Quote__c >();
            ApexPages.StandardSetController setcntr2 = new ApexPages.StandardSetController(QuoteLst2);
            setcntr.setSelected(QuoteLst2);
            VCG_CPQ_SetPrimarQuoteController cntr2 = new VCG_CPQ_SetPrimarQuoteController(setcntr2 );
            cntr.applyPrimaryQuote();
            
            test.StopTest();
            }
            
    }
}