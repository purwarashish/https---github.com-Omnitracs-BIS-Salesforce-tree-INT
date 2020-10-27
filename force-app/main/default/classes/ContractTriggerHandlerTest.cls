//@isTest(SeeAllData=True) // Arman's note:  Refactor to use SeeAllData=false; Create CustomSettings
@isTest
private class ContractTriggerHandlerTest {
    public static Account accountInstance = new Account();
    public static Contract contractInstance = new Contract();

    @TestSetup
    static void SetupData() {
        Schema.DescribeSObjectResult acccfrSchema = Schema.SObjectType.Account;
        Map<String,Schema.RecordTypeInfo> AccountRecordTypeInfo = acccfrSchema.getRecordTypeInfosByName();
        Id accountRtId = AccountRecordTypeInfo.get('T&L Sales Accounts').getRecordTypeId();

        ///////////// ARMAN SHAH changes:  //////////////////////////////////////////////////////////////////////
        System.debug('-- AccountRecordTypeInfo = '+AccountRecordTypeInfo);
        System.debug('-- accountRtId = '+accountRtId);
        TestUtils.defineCustomSettings();
        ///////////// END - ARMAN SHAH changes  //////////////////////////////////////////////////////////////////////

        Schema.DescribeSObjectResult concfrSchema = Schema.SObjectType.Contract; 
        Map<String,Schema.RecordTypeInfo> ContractRecordTypeInfo = concfrSchema.getRecordTypeInfosByName();
        Id contractRtId = ContractRecordTypeInfo .get('Customer Agreement').getRecordTypeId();
        
        accountInstance     =   new Account(    Name = 'testAccount',
                                                recordtypeid = accountRtId,
                                                Account_Classification__c = 'Prospect',
                                                Account_Status__c = 'Active',
                                                Account_Type__c = 'Association',
                                                Phone = '(555) 555-5555',
                                                BillingStreet = 'Harwood St',
                                                BillingCity = 'Dallas',
                                                BillingState = 'TX',
                                                BillingPostalCode = '75201',
                                                BillingCountry = 'USA',
                                                Primary_Business_Unit__c = 'Omnitracs Domestic',
                                                Segment__c = 'TL',
                                                Fleet_Size__c = 10
                                            );
        insert accountInstance;
        
        contractInstance    =   new Contract(   Contract_Title__c   =   'testTitle',
                                                recordtypeid    =   contractRtId,
                                                AccountId  =   accountInstance.id,
                                                Status =   'Draft',
                                                StartDate  =   date.today(),
                                                EndDate    =   date.today(),
                                                ContractTerm   =   1,
                                                CurrencyIsoCode    =   'USD',
                                                Contract_ID__c =   null,
                                                Renewal_Term_Length_in_months__c=12,
                                                Term_type__c = 'Fixed',
                                                Agreement_type__c = 'Individual',
                                                Contract_Type__c = 'Customer',
                                                Affiliate_Language__c = 'Yes',                                                 
                                                Legal_Entity_Name__c ='Omnitracs, LLC'
                                             );
        insert contractInstance;
        
        ContentVersion testContentInsert =new ContentVersion(); 
        testContentInsert.Id = setupContent();
        update testContentInsert;
    }

    private static testMethod void testContractTriggerHandler() {
        Date today = date.today();
        contractInstance = [SELECT Id, Name, Status, EndDate, Term_Type__c, Original_Expiration_Date__c, Agreement_Type__c
            FROM Contract LIMIT 1];

        Test.startTest();
        contractInstance.Status = 'Activated';
        contractInstance.EndDate = today;
        contractInstance.Term_Type__c = 'Auto-Renewal';
        contractInstance.Original_Expiration_Date__c = null;
        contractInstance.Agreement_Type__c='Embedded Clause';
        
        update contractInstance;
        Test.stopTest();
    }
    
    public static ID setupContent() 
    { 
        RecordType ContentRT = [select Id FROM RecordType WHERE Name = 'Contract Document']; 
        
        ContentVersion testContentInsert = new ContentVersion(); 
        testContentInsert.ContentURL='http://www.google.com/'; 
        testContentInsert.Title = 'Google.com'; 
        testContentInsert.RecordTypeId = ContentRT.Id; 
        
        insert testContentInsert; 
        Try
        {
        ContentVersion testContent = [SELECT ContentDocumentId FROM ContentVersion where Id = :testContentInsert.Id]; 
        
        ContentWorkspace testWorkspace = [SELECT Id FROM ContentWorkspace WHERE Name = 'Contract Documents']; 
        
        ContentWorkspaceDoc newWorkspaceDoc = new ContentWorkspaceDoc(); 
        
        newWorkspaceDoc.ContentWorkspaceId = testWorkspace.Id; 
        newWorkspaceDoc.ContentDocumentId = testContent.ContentDocumentId; 
        
        insert newWorkspaceDoc; 
        
        testContent.Document_Category__c ='Executed Contract';
        testContent.Contract__c = contractInstance.Id;
        
        update testContent; 
        }
        Catch(Exception e)
        {
             System.debug('Exception in class ContractTriggerHandlerTest'+e.getmessage());
        }
        return testContentInsert.Id; 
    }
    
    private static testMethod void testOpportunityLegalApproval() {
        accountInstance = [SELECT Id FROM Account LIMIT 1];
        Opportunity testOpp = TestUtils.getOpportunity(accountInstance, 'Test');
        testOpp.StageName = 'Sales Acceptance';
        testOpp.Contract__c = contractInstance.Id;
        //testOpp.Type_of_Competitor__c = 'Competitive Takeaway';
        insert testOpp;
        
        Schema.DescribeSObjectResult acccfrSchema = Schema.SObjectType.Account; 
        Map<String,Schema.RecordTypeInfo> AccountRecordTypeInfo = acccfrSchema.getRecordTypeInfosByName();
        Id accountRtId = AccountRecordTypeInfo .get('T&L Sales Accounts').getRecordTypeId();
        
        Schema.DescribeSObjectResult concfrSchema = Schema.SObjectType.Contract; 
        Map<String,Schema.RecordTypeInfo> ContractRecordTypeInfo = concfrSchema.getRecordTypeInfosByName();
        Id contractRtId = ContractRecordTypeInfo .get('Customer Agreement').getRecordTypeId();
        
        Contract testContract1    =   new Contract(   Contract_Title__c   =   'testTitle',
                                                recordtypeid    =   contractRtId,
                                                AccountId  =   accountInstance.id,
                                                Status =   'Draft',
                                                StartDate  =   date.today(),
                                                EndDate    =   date.today(),
                                                ContractTerm   =   1,
                                                CurrencyIsoCode    =   'USD',
                                                Contract_ID__c =   null,
                                                Renewal_Term_Length_in_months__c=12,
                                                Term_type__c = 'Fixed',
                                                Agreement_type__c = 'Individual',
                                                Contract_Type__c = 'Customer',
                                                Affiliate_Language__c = 'Yes',                                                 
                                                Legal_Entity_Name__c ='Omnitracs, LLC'
                                             );
        
        insert testContract1;   
        Contract testContract2    =   new Contract(   Contract_Title__c   =   'testTitle2',
                                                recordtypeid    =   contractRtId,
                                                AccountId  =   accountInstance.id,
                                                Status =   'Draft',
                                                StartDate  =   date.today(),
                                                EndDate    =   date.today(),
                                                ContractTerm   =   1,
                                                CurrencyIsoCode    =   'USD',
                                                Contract_ID__c =   null,
                                                Renewal_Term_Length_in_months__c=12,
                                                Term_type__c = 'Fixed',
                                                Agreement_type__c = 'Individual',
                                                Contract_Type__c = 'Customer',
                                                Affiliate_Language__c = 'Yes',                                                 
                                                Legal_Entity_Name__c ='Omnitracs, LLC'
                                             );
        insert testContract2;
        
        Opportunity_Contract__c oc1 = new Opportunity_Contract__c(Opportunity__c = testOpp.Id, Contract__c = testContract1.Id); 
        insert oc1;
        Opportunity_Contract__c oc2 = new Opportunity_Contract__c(Opportunity__c = testOpp.Id, Contract__c = testContract2.Id); 
        insert oc2;                                   
        
        Test.startTest();
        testContract1.Status = 'Active';
        update testContract1;
        
        Opportunity testOppUpdate = [SELECT Id, Contract_Activated__c FROM Opportunity WHERE Id =: testOpp.Id LIMIT 1];
        System.assertEquals(false, testOppUpdate.Contract_Activated__c);
        Test.stopTest();
        testContract2.Status = 'Active';
        
        
        Opportunity testOppUpdate2 = [SELECT Id, Contract_Activated__c FROM Opportunity WHERE Id =: testOpp.Id LIMIT 1];
        //System.assertEquals(true, testOppUpdate2.Contract_Activated__c);
        System.debug('testOppUpdate2.Contract_Activated__c'+ testOppUpdate2.Contract_Activated__c);
        update testContract2;
    }

    ////////////////////////////////////////////////////////////////////////////////////////////////
    /// By:   Arman Shah
    /// Date: 8/28/2018
    /// Test that upon Renewal of an existing Contract for a ClosedWon Opportunity, that the
    /// new Contract's Id value is set on the Asset
    ////////////////////////////////////////////////////////////////////////////////////////////////
    private static testMethod void testSetContractOnAssets() {
        System.debug('-- START testSetContractOnAssets --');

        insert new ByPassTrigger__c(SetupOwnerId=UserInfo.getOrganizationId(), isDisabled__c=true, 
            Name='Testing ContractTriggerHandler Bypass');

        VistaAssetHelperUtil util = new VistaAssetHelperUtil();
        Account account = util.createAccount('ABC Test Account');

        List<Product2> productList = new List<Product2>();
        //subPricingType = 'Fixed Price' or 'Percent Of Total'
        productList.addAll(util.initProductSet(100, 'Hardware', '', 'Fixed Price', 'Monthly'));
        Map<Id, PricebookEntry> pricebookEntries = new Map<Id, PricebookEntry>();
        pricebookEntries = util.initPricebook(productList);
        
        Opportunity opportunity = util.createNewOpportunity('Test Opportunity 1', account,
            'Products, Services and Maintenance', 'New');
        System.debug('-- opportunity 0 ='+opportunity);

        Contract contract = util.createContract(opportunity, account, 'Customer - MSA', Date.today());
        System.debug('-- contract 0 = '+contract);

        SBQQ__Quote__c sbQuote = util.createSBQuote(opportunity, account, Date.today(), true);
        
        contract.SBQQ__Quote__c = sbQuote.Id;
        update contract;
        System.debug('-- contract 1 = '+contract);

        List<SBQQ__Quoteline__c> sbQuoteLines = 
            util.createSBQuoteLines(sbQuote, pricebookEntries, true, 0);
        
        List<OpportunityLineItem> opportunityLineItems = 
            util.createOppLineItems(opportunity, sbQuoteLines, pricebookEntries);

        Asset asset = util.createSFDCAsset(sbQuoteLines[0], account);
        asset.Contract__c = contract.Id;
        update asset;
        System.debug('-- asset = '+asset);

        opportunity.SBQQ__PrimaryQuote__c = sbQuote.Id;
        opportunity = util.closeWonOpportunity(opportunity); // sets to StageName='Sales Complete'
        System.debug('-- opportunity after call to util.ClosedWon(...) = '+opportunity);

        if (opportunity.Contract__c == null) {
            //NOTE: a ClosedWon Opp does NOT automatically create a new Contract
            opportunity.Contract__c = contract.Id; 
            update opportunity;
            System.debug('-- opportunity MOD ='+opportunity);
        }

        // Create a new Contract as a Renewal of the existing one
        Contract newContract = contract.clone();
        newContract.SBQQ__Opportunity__c = opportunity.Id;
        insert newContract;
        System.debug('-- newContract = '+newContract);

        // Update Opp upon a Contract Renewal
        opportunity.SBQQ__RenewedContract__c = contract.Id; // for Old contract
        update opportunity;
        System.debug('-- opportunity Renewed-Contract = '+opportunity);

        List<Contract> newContracts = new List<Contract>();
        newContracts.add(newContract);
        System.debug('-- newContracts = '+newContracts);

        Test.startTest();
        ContractTriggerHandler.setContractOnAssets(newContracts);
        Test.stopTest();

        // Assertions:
        Asset modAsset = [SELECT Id, Contract__c
                    FROM Asset
                    WHERE Id =: asset.Id LIMIT 1];
        
        System.debug('-- modAsset = '+modAsset);

        System.assertEquals(newContract.Id, modAsset.Contract__c);
    }


    private static testMethod void testRenameSBParentContract() {
        System.debug('-- START testRenameSBParentContract --');

        insert new ByPassTrigger__c(SetupOwnerId=UserInfo.getOrganizationId(), isDisabled__c=true,
                Name='Testing ContractTriggerHandler Bypass');

        VistaAssetHelperUtil util = new VistaAssetHelperUtil();
        Account account = util.createAccount('ABC Test Account');

        List<Product2> productList = new List<Product2>();
        //subPricingType = 'Fixed Price' or 'Percent Of Total'
        productList.addAll(util.initProductSet(100, 'Hardware', '', 'Fixed Price', 'Monthly'));
        Map<Id, PricebookEntry> pricebookEntries = new Map<Id, PricebookEntry>();
        pricebookEntries = util.initPricebook(productList);

        Opportunity opportunity = util.createNewOpportunity('Test Opportunity 1', account,
                'Products, Services and Maintenance', 'New');
        System.debug('-- opportunity 0 ='+opportunity);

        Contract contract = util.createContract(opportunity, account, 'Customer - MSA', Date.today());
        System.debug('-- contract 0 = '+contract);

        SBQQ__Quote__c sbQuote = util.createSBQuote(opportunity, account, Date.today(), true);

        contract.SBQQ__Quote__c = sbQuote.Id;
        update contract;
        System.debug('-- contract 1 = '+contract);

        List<SBQQ__Quoteline__c> sbQuoteLines =
                util.createSBQuoteLines(sbQuote, pricebookEntries, true, 0);

        List<OpportunityLineItem> opportunityLineItems =
                util.createOppLineItems(opportunity, sbQuoteLines, pricebookEntries);

        Asset asset = util.createSFDCAsset(sbQuoteLines[0], account);
        asset.Contract__c = contract.Id;
        update asset;
        System.debug('-- asset = '+asset);

        opportunity.SBQQ__PrimaryQuote__c = sbQuote.Id;
        opportunity = util.closeWonOpportunity(opportunity); // sets to StageName='Sales Complete'
        System.debug('-- opportunity after call to util.ClosedWon(...) = '+opportunity);

        if (opportunity.Contract__c == null) {
            //NOTE: a ClosedWon Opp does NOT automatically create a new Contract
            opportunity.Contract__c = contract.Id;
            update opportunity;
            System.debug('-- opportunity MOD ='+opportunity);
        }

        // Create a new Contract as a Renewal of the existing one
        Contract newContract = contract.clone();
        newContract.SBQQ__Opportunity__c = opportunity.Id;
        insert newContract;
        System.debug('-- newContract = '+newContract);

        // Update Opp upon a Contract Renewal
        opportunity.SBQQ__RenewedContract__c = contract.Id; // for Old contract
        update opportunity;
        System.debug('-- opportunity Renewed-Contract = '+opportunity);

        List<Contract> newContracts = new List<Contract>();
        newContracts.add(newContract);
        System.debug('-- newContracts = '+newContracts);

        Test.startTest();
        ContractTriggerHandler.renameSBParentContract(newContracts);
        Test.stopTest();

        List<Contract> updatedContracts = [SELECT Id, Name, Contract_Title__c FROM Contract];
        System.debug('-- updatedContracts = '+updatedContracts);

        // 15:48:00:217 USER_DEBUG [371]|DEBUG|-- updatedContracts = (Contract:{Id=800Z0000000U1jHIAS, Contract_Title__c=testTitle},
        // Contract:{Id=800Z0000000U1jIIAS, Contract_Title__c=INACTIVE: SB Contract: ABC Test Account:}, Contract:{Id=800Z0000000U1jJIAS,
        // Contract_Title__c=SB Contract: ABC Test Account:}, Contract:{Id=800Z0000000U1jKIAS})

        for (Contract updContract : updatedContracts) {
            if (updContract.Id == contract.Id) {
                System.assert(updContract.Contract_Title__c.contains('INACTIVE: SB Contract: ' + account.Name));
            }
            else if (updContract.Id == newContract.Id) {
                System.assert(updContract.Contract_Title__c.contains('SB Contract: ' + account.Name));
            }
        }
    }

    private static testMethod void testActivateContractOpportunities() {
        // activateContractOpportunities(Map<Id, Contract> oldMap, Map<Id, Contract> newMap)
        Map<Id, Contract> oldMap = new Map<Id, Contract>();
        Map<Id, Contract> newMap = new Map<Id, Contract>();

        accountInstance = [SELECT Id FROM Account LIMIT 1];

        Schema.DescribeSObjectResult concfrSchema = Schema.SObjectType.Contract;
        Map<String,Schema.RecordTypeInfo> ContractRecordTypeInfo = concfrSchema.getRecordTypeInfosByName();
        Id contractRtId = ContractRecordTypeInfo .get('Customer Agreement').getRecordTypeId();

        Contract testContract1    =   new Contract(   Contract_Title__c   =   'testTitle',
                recordtypeid    =   contractRtId,
                AccountId  =   accountInstance.id,
                Status =   'Draft',
                StartDate  =   date.today(),
                EndDate    =   date.today(),
                ContractTerm   =   1,
                CurrencyIsoCode    =   'USD',
                Contract_ID__c =   null,
                Renewal_Term_Length_in_months__c=12,
                Term_type__c = 'Fixed',
                Agreement_type__c = 'Individual',
                Contract_Type__c = 'Customer',
                Affiliate_Language__c = 'Yes',
                Legal_Entity_Name__c ='Omnitracs, LLC'
        );
        insert testContract1;
        Contract tc1 = [SELECT Id, Status FROM Contract WHERE Id =: testContract1.Id LIMIT 1];

        Opportunity testOpp = TestUtils.getOpportunity(accountInstance, 'Test');
        testOpp.StageName = 'Sales Acceptance';
        testOpp.Contract__c = tc1.Id;
        insert testOpp;

        Contract testContract2    =   new Contract(   Contract_Title__c   =   'testTitle2',
                recordtypeid    =   contractRtId,
                AccountId  =   accountInstance.id,
                Status =   'Active',  //NOTE
                StartDate  =   date.today(),
                EndDate    =   date.today(),
                ContractTerm   =   1,
                CurrencyIsoCode    =   'USD',
                Contract_ID__c =   null,
                Renewal_Term_Length_in_months__c=12,
                Term_type__c = 'Fixed',
                Agreement_type__c = 'Individual',
                Contract_Type__c = 'Customer',
                Affiliate_Language__c = 'Yes',
                Legal_Entity_Name__c ='Omnitracs, LLC'
        );
        insert testContract2;
        Contract tc2 = [SELECT Id, Status FROM Contract WHERE Id =: testContract2.Id LIMIT 1];

        Opportunity_Contract__c oc1 = new Opportunity_Contract__c(Opportunity__c = testOpp.Id, Contract__c = tc1.Id);
        insert oc1;
        Opportunity_Contract__c oc2 = new Opportunity_Contract__c(Opportunity__c = testOpp.Id, Contract__c = tc2.Id);
        insert oc2;

        oldMap.put(tc1.Id, tc1);
        oldMap.put(tc2.Id, tc2);
        System.debug('-- oldMap = '+oldMap);

        testContract1.Status = 'Active';
        update testContract1;
        Contract tc1Updated = [SELECT Id, Status FROM Contract WHERE Id =: testContract1.Id LIMIT 1];

        newMap.put(tc1.Id, tc1Updated);
        newMap.put(tc2.Id, tc2);
        System.debug('-- newMap = '+newMap);

        Test.startTest();
        ContractTriggerHandler.activateContractOpportunities(oldMap, newMap);
        Test.stopTest();

        List<Opportunity> opps = [SELECT Id, Contract_Activated__c, Legal_Review__c
            FROM Opportunity];
        System.debug('-- opps = '+opps);
        System.assertEquals(true, opps[0].Contract_Activated__c);
        System.assertEquals('Approved', opps[0].Legal_Review__c);
     }
}