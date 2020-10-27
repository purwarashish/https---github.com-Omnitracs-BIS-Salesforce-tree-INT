@isTest(SeeAllData=True)
private class VCG_CPQ_QuoteAddressTest {
    
    static testmethod void runTest() {
        
        //
        // Set up test records - account, opp, etc.
        //
        Account acct = new Account( Name = 'Test Account' );
        insert acct;
        
        // Added RecordType and StageName ='Sales Acceptance'
        Id oldProdRecType = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Products, Services and Maintenance').getRecordTypeId();
        
        Opportunity opp = new Opportunity (
                                            Name = 'Test Opp',
                                            AccountId = acct.Id,
                                            RecordTypeId = oldProdRecType,
                                            CloseDate = Date.today().addDays(30),
                                            StageName = 'Sales Acceptance'
                                        );
        insert opp;
        
        
        Test.startTest(); // Do startTest() here to reset limits
        //
        // Now, set up the page parameters and call the QuoteAddress Controller
        //
        PageReference pageRef = Page.VCG_CPQ_QuoteAddress;
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('oppid', opp.id);
        
        
        VCG_CPQ_QuoteAddress qa = new VCG_CPQ_QuoteAddress(new ApexPages.StandardController(opp));
        qa.bypassValidation = false;
        qa.next();
        
        Address__c invoice_addr = new Address__c(Account__c = opp.AccountId
                                               , Address_Line_1__c = 'x'
                                               , City__c = 'LA'
                                               , State_Province__c = 'CA'
                                               , Country__c = 'United States'
                                               , Zip_Postal_Code__c = '90210'
                                               , Location_Type__c = 'Invoice Address');
        insert invoice_addr;
        
        Address__c corporate_addr = new Address__c(Account__c = opp.AccountId
                                                 , Address_Line_1__c = 'x'
                                                 , City__c = 'LA'
                                                 , State_Province__c = 'CA'
                                                 , Country__c = 'United States'
                                                 , Zip_Postal_Code__c = '90210'
                                                 , Location_Type__c = 'Corporate HQ');
        insert corporate_addr;
        
        qa.opp.Corporate_Account_Address__c = corporate_addr.Id;
        qa.opp.Invoice_Account_Address__c = invoice_addr.Id;
        
        //  call the new roadnet parnter code
        system.assertNotEquals(null, qa.loggedInuser);
        qa.verifyUserIsRoadnetPartnerVar();
        qa.prepopOpptAddressFields();
        
        VCG_CPQ_QuoteAddress.testMethodTestForPrivateStatics();
        //  end tests for new roadnet aprtner code
        qa.next();
        
        Test.stopTest();
        
    }
    
}