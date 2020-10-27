global without sharing class TestUtils
{
    // Begin Omnitracs existing TestUtils Class
    global static void assertConfirmMessagesExist(){ assertMessagesAtLevelExist(ApexPages.Severity.CONFIRM,true); }
    global static void assertInfoMessagesExist(){ assertMessagesAtLevelExist(ApexPages.Severity.INFO,true); }
    global static void assertWarningMessagesExist(){ assertMessagesAtLevelExist(ApexPages.Severity.WARNING,true); }
    global static void assertErrorMessagesExist(){ assertMessagesAtLevelExist(ApexPages.Severity.ERROR,true); }
    global static void assertFatalMessagesExist(){ assertMessagesAtLevelExist(ApexPages.Severity.FATAL,true); }

    global static void assertNoConfirmMessagesExist(){ assertNoMessagesAtLevelExist(ApexPages.Severity.CONFIRM,true); }
    global static void assertNoInfoMessagesExist(){ assertNoMessagesAtLevelExist(ApexPages.Severity.INFO,true); }
    global static void assertNoWarningMessagesExist(){ assertNoMessagesAtLevelExist(ApexPages.Severity.WARNING,true); }
    global static void assertNoErrorMessagesExist(){ assertNoMessagesAtLevelExist(ApexPages.Severity.ERROR,true); }
    global static void assertNoFatalMessagesExist(){ assertNoMessagesAtLevelExist(ApexPages.Severity.FATAL,true); }

    public static void defineCustomSettings() { // NOTE: Shared amongst several classes for Testing
        List<sObject> sObjCSList = new List<sObject>();
        sObjCSList.add(new AccountRecordTypes__c(Name = 'TL_SALES_ACCOUNT_RECORD_TYPE_ID', RecordTypeID__c = '01250000000DQBAAA4'));
        sObjCSList.add(new AccountRecordTypes__c(Name = 'COMPETITOR_RECORD_TYPE_ID', RecordTypeID__c = '01250000000Qxbn'));
		sObjCSList.add(new AccountRecordTypes__c(Name = 'GSS_ACCOUNT_RECORD_TYPE_ID', RecordTypeID__c = '01250000000DVwYAAW'));
		sObjCSList.add(new AccountRecordTypes__c(Name = 'CNR_SALES_ACCOUNT_RECORD_TYPE_ID', RecordTypeID__c = '01250000000DVm9AAG'));
        sObjCSList.add(new AccountRecordTypes__c(Name = 'OTHER_ACCOUNT_RECORD_TYPE_ID', RecordTypeID__c = '01250000000DTCpAAO'));
		sObjCSList.add(new AccountRecordTypes__c(Name = 'PRTNR_ACNT_RESELLR_RCRD_TYPE_ID', RecordTypeID__c = '01250000000QjAKAA0'));
		sObjCSList.add(new AccountRecordTypes__c(Name = 'Referral', RecordTypeID__c = '01250000000E5L8AAK'));
		sObjCSList.add(new AllAccountUtils__c(Name = 'ACCOUNT_NAME', Value__c = 'Account Name'));
		sObjCSList.add(new AllAccountUtils__c(Name = 'ACCOUNT_TYPE', Value__c = 'Account Type'));
		sObjCSList.add(new AllAccountUtils__c(Name = 'ACCT_MANAGER', Value__c = 'Account Manager'));
		sObjCSList.add(new AllAccountUtils__c(Name = 'ASSET_VAL_RANGE', Value__c = 'Asset Value Range'));
		sObjCSList.add(new AllAccountUtils__c(Name = 'AVG_LEN_HAUL', Value__c = 'Average Length of Haul'));
		sObjCSList.add(new AllAccountUtils__c(Name = 'BILLING_ADDRESS', Value__c = 'Billing Address'));
		sObjCSList.add(new AllAccountUtils__c(Name = 'BILLING_CITY', Value__c = 'Billing City'));
		sObjCSList.add(new AllAccountUtils__c(Name = 'BILLING_COUNTRY', Value__c = 'Billing Country'));
		sObjCSList.add(new AllAccountUtils__c(Name = 'BILLING_POSTAL_CODE', Value__c = 'Billing Zip/Postal'));
		sObjCSList.add(new AllAccountUtils__c(Name = 'BILLING_STATE', Value__c = 'Billing State'));
		sObjCSList.add(new AllAccountUtils__c(Name = 'BILLING_STR', Value__c = 'Billing Street'));
		sObjCSList.add(new AllAccountUtils__c(Name = 'CLSD_RSN_NON_PAY', Value__c = 'Non-Payment'));
		sObjCSList.add(new AllAccountUtils__c(Name = 'CLSD_RSN_OUT_OF_BUS', Value__c = 'Out of Business'));
		sObjCSList.add(new AllAccountUtils__c(Name = 'COMP_PLATFORM', Value__c = 'Computer Platform'));
		sObjCSList.add(new AllAccountUtils__c(Name = 'CONTACT_COMMENT', Value__c = 'Contract Comments'));
		sObjCSList.add(new AllAccountUtils__c(Name = 'CONTRACT_CUSTOMER', Value__c = 'Contract Customer'));
		sObjCSList.add(new AllAccountUtils__c(Name = 'CONTRACT_EXPIRATION', Value__c = 'Contract Expiration'));
		sObjCSList.add(new AllAccountUtils__c(Name = 'CUST_ID', Value__c = 'Cust ID'));
		sObjCSList.add(new AllAccountUtils__c(Name = 'CUST_SERVICE_REP', Value__c = 'Customer Service Rep'));
		sObjCSList.add(new AllAccountUtils__c(Name = 'DEALER', Value__c = 'Dealer'));
		sObjCSList.add(new AllAccountUtils__c(Name = 'DEVICE_SUPP', Value__c = 'Device Supplier'));
		sObjCSList.add(new AllAccountUtils__c(Name = 'DISTRICT', Value__c = 'District'));
		sObjCSList.add(new AllAccountUtils__c(Name = 'DOLLIES', Value__c = 'Dollies'));
		sObjCSList.add(new AllAccountUtils__c(Name = 'DRY_VANS', Value__c = 'Dry Vans'));
		sObjCSList.add(new AllAccountUtils__c(Name = 'ENABLED_DEVICE', Value__c = 'Number of Enabled Devices'));
		sObjCSList.add(new AllAccountUtils__c(Name = 'EVAL_CUSTOMERS', Value__c = 'New Eval Customer'));
		sObjCSList.add(new AllAccountUtils__c(Name = 'FAX', Value__c = 'Fax'));
		sObjCSList.add(new AllAccountUtils__c(Name = 'FEATURE_INTEREST', Value__c = 'Feature Interest'));
		sObjCSList.add(new AllAccountUtils__c(Name = 'FLATBEDS', Value__c = 'Flatbeds'));
		sObjCSList.add(new AllAccountUtils__c(Name = 'LEAD_SOURCE', Value__c = 'Lead Source'));
		sObjCSList.add(new AllAccountUtils__c(Name = 'LOCATION', Value__c = '# of Locations'));
		sObjCSList.add(new AllAccountUtils__c(Name = 'MARKET', Value__c = 'Market'));
		sObjCSList.add(new AllAccountUtils__c(Name = 'OBC', Value__c = 'OBC'));
		sObjCSList.add(new AllAccountUtils__c(Name = 'OEM_TRACTOR', Value__c = 'OEM Tractor'));
		sObjCSList.add(new AllAccountUtils__c(Name = 'ORMM', Value__c = 'ORMM'));
		sObjCSList.add(new AllAccountUtils__c(Name = 'OTR_VEHICLES', Value__c = 'OTR Vehicles'));
		sObjCSList.add(new AllAccountUtils__c(Name = 'PDT_INTEREST', Value__c = 'Product Interest'));
		sObjCSList.add(new AllAccountUtils__c(Name = 'PHONE', Value__c = 'Phone'));
		sObjCSList.add(new AllAccountUtils__c(Name = 'PRIMARY_BUSINESS', Value__c = 'Primary Business'));
		sObjCSList.add(new AllAccountUtils__c(Name = 'PRIMARY_COMMODITY', Value__c = 'Primary Commodity'));
		sObjCSList.add(new AllAccountUtils__c(Name = 'QWBS_MARKET', Value__c = 'Mexico Sales'));
		sObjCSList.add(new AllAccountUtils__c(Name = 'RANKING', Value__c = 'Ranking'));
		sObjCSList.add(new AllAccountUtils__c(Name = 'REEFERS', Value__c = 'Reefers'));
		sObjCSList.add(new AllAccountUtils__c(Name = 'REEFER_TRAILER', Value__c = 'OEM Reefer Trailer'));
		sObjCSList.add(new AllAccountUtils__c(Name = 'REG_VEHICLES', Value__c = 'Regional Vehicles'));
		sObjCSList.add(new AllAccountUtils__c(Name = 'RFC_ID', Value__c = 'RFC ID'));
		sObjCSList.add(new AllAccountUtils__c(Name = 'SERVICE_MODEL', Value__c = 'Service Model'));
		sObjCSList.add(new AllAccountUtils__c(Name = 'SHIPPING_CITY', Value__c = 'Shipping City'));
		sObjCSList.add(new AllAccountUtils__c(Name = 'SHIPPING_COUNTRY', Value__c = 'Shipping Country'));
		sObjCSList.add(new AllAccountUtils__c(Name = 'SHIPPING_POSTAL_CODE', Value__c = 'Shipping Zip/Postal Code'));
		sObjCSList.add(new AllAccountUtils__c(Name = 'SHIPPING_PROV', Value__c = 'Shipping State/Province'));
		sObjCSList.add(new AllAccountUtils__c(Name = 'SHIPPING_STR', Value__c = 'Shipping Street'));
		sObjCSList.add(new AllAccountUtils__c(Name = 'STATUS', Value__c = 'Status'));
		sObjCSList.add(new AllAccountUtils__c(Name = 'TANKERS', Value__c = 'Tankers'));
		sObjCSList.add(new AllAccountUtils__c(Name = 'TRAILERTRACS', Value__c = 'TrailerTRACS'));
		sObjCSList.add(new SystemIds__c(SetupOwnerId = UserInfo.getOrganizationId(), BusinessHoursId_Roadnet__c = '01m500000004I8c'));
		sObjCSList.add(new CaseTrigger_Global_Variable__c(Name = 'Call Center Record Type Name', Value__c = 'Call Center'));
		sObjCSList.add(new CaseTrigger_Global_Variable__c(Name = 'CallCenter_RecordTypeId', Value__c = '01250000000DT5tAAG'));
		sObjCSList.add(new CaseTrigger_Global_Variable__c(Name = 'ClosedNMCAccountRequest_RecordTypeId', Value__c = '01250000000DaMkAAK'));
		sObjCSList.add(new CaseTrigger_Global_Variable__c(Name = 'Email Agent', Value__c = 'Email Agent'));
		sObjCSList.add(new CaseTrigger_Global_Variable__c(Name = 'Email Agent UserId', Value__c = '00550000000x4rqAAA'));
		sObjCSList.add(new CaseTrigger_Global_Variable__c(Name = 'EmailGeneratedCases_RecordTypeId', Value__c = '01250000000DTGNAA4'));
		sObjCSList.add(new CaseTrigger_Global_Variable__c(Name = 'EngineeringCase_RecordTypeId', Value__c = '01250000000E5M9AAK'));
		sObjCSList.add(new CaseTrigger_Global_Variable__c(Name = 'EOX Return Record Type Name', Value__c = 'EOX Return'));
		sObjCSList.add(new CaseTrigger_Global_Variable__c(Name = 'evaluation expired', Value__c = 'evaluation expired'));
		sObjCSList.add(new CaseTrigger_Global_Variable__c(Name = 'evaluation expiring', Value__c = 'evaluation expiring'));
		sObjCSList.add(new CaseTrigger_Global_Variable__c(Name = 'evaluation extended', Value__c = 'evaluation extended'));
		sObjCSList.add(new CaseTrigger_Global_Variable__c(Name = 'GV ConnectionUser Id', Value__c = '00550000001b4gPAAQ'));
		sObjCSList.add(new CaseTrigger_Global_Variable__c(Name = 'Jira Status Blocked', Value__c = 'Blocked'));
		sObjCSList.add(new CaseTrigger_Global_Variable__c(Name = 'Jira Status Close', Value__c = 'Close'));
		sObjCSList.add(new CaseTrigger_Global_Variable__c(Name = 'Jira Status Closed', Value__c = 'Closed'));
		sObjCSList.add(new CaseTrigger_Global_Variable__c(Name = 'Jira Status Resolved', Value__c = 'Resolved'));
		sObjCSList.add(new CaseTrigger_Global_Variable__c(Name = 'mcp wib configuration change', Value__c = 'mcp wib configuration change'));
		sObjCSList.add(new CaseTrigger_Global_Variable__c(Name = 'NMCAccountRequest_RecordTypeId', Value__c = '01250000000DaMSAA0'));
		sObjCSList.add(new CaseTrigger_Global_Variable__c(Name = 'OrgWideEmail for Case Closure', Value__c = '0D2W0000000CbVi'));
		sObjCSList.add(new CaseTrigger_Global_Variable__c(Name = 'OrgWideEmail for Domestic Support', Value__c = '0D230000000007l'));
		sObjCSList.add(new CaseTrigger_Global_Variable__c(Name = 'Populate Queue Field CS', Value__c = 'Field CS'));
		sObjCSList.add(new CaseTrigger_Global_Variable__c(Name = 'ProfessionalServices_RecordTypeId', Value__c = '01250000000E5MBAA0'));
		sObjCSList.add(new CaseTrigger_Global_Variable__c(Name = 'REC_TYPE_CASE_NMC_ACCT_REQ', Value__c = 'NMC Account Request'));
		sObjCSList.add(new CaseTrigger_Global_Variable__c(Name = 'REC_TYPE_CASE_NMC_ACCT_REQ_CLOSED', Value__c = 'Closed NMC Account Request'));
		sObjCSList.add(new CaseTrigger_Global_Variable__c(Name = 'REC_TYPE_CASE_NMC_ACCT_REQ_SUBMITTED', Value__c = 'Submitted NMC Account Request'));
		sObjCSList.add(new CaseTrigger_Global_Variable__c(Name = 'reporting services access requested', Value__c = 'reporting services access requested'));
		sObjCSList.add(new CaseTrigger_Global_Variable__c(Name = 'Roadnet Anywhere', Value__c = 'Roadnet Anywhere'));
		sObjCSList.add(new CaseTrigger_Global_Variable__c(Name = 'Roadnet Business Unit', Value__c = 'Roadnet'));
		sObjCSList.add(new CaseTrigger_Global_Variable__c(Name = 'Strategic Support_QueueId', Value__c = '00G5000000254tNEAQ'));
		sObjCSList.add(new CaseTrigger_Global_Variable__c(Name = 'SubmittedNMCAccountRequest_RecordType', Value__c = '01250000000DaMjAAK'));
		sObjCSList.add(new CaseTrigger_Global_Variable__c(Name = 'SubStatus Pending Customer', Value__c = 'Pending Customer'));
        sObjCSList.add(new OpportunityLegalReviewStatus__c(Name = 'ContractDataEntryProcess', Value__c = 'Contract Data Entry Process'));
        sObjCSList.add(new OpportunityLegalReviewStatus__c(Name = 'Waiting for Counter-Signature', Value__c = 'Waiting for Counter-Signature'));
        sObjCSList.add(new OpportunityLegalReviewStatus__c(Name = 'InitialReview', Value__c = 'Initial Review'));
        sObjCSList.add(new OpportunityLegalReviewStatus__c(Name = 'Approved', Value__c = 'Approved'));
        sObjCSList.add(new OpportunityFinanceStatus__c(Name = 'NeedsReview', Value__c = 'Needs Review'));
        sObjCSList.add(new EventsQuantityAction__c(Name = 'BILLING_ES_APPS', Action__c = 'CALCULATE_ON_EXISTING'));
        sObjCSList.add(new EventsQuantityAction__c(Name = 'BILLING_ES_PLANS', Action__c = 'CALCULATE_ON_EXISTING'));
        sObjCSList.add(new EventsQuantityAction__c(Name = 'ERP_SHIPMENT', Action__c = 'CALCULATE_ON_EXISTING'));
        sObjCSList.add(new EventsQuantityAction__c(Name = 'AUTO_FLEET_REDUCTION', Action__c = 'DECREASE_CONTRACTED'));
        sObjCSList.add(new EventsQuantityAction__c(Name = 'AUTO_REACTIVATION', Action__c = 'INCREASE_CONTRACTED'));
        sObjCSList.add(new EventsQuantityAction__c(Name = 'ERP_RECEIPT', Action__c = 'INCREASE_CONSUMED'));
        sObjCSList.add(new EventsQuantityAction__c(Name = 'ERP_RN_BILLING', Action__c = 'CALCULATE_ON_EXISTING'));
        insert sObjCSList;
    }
    
    global static void assertMessagesAtLevelExist(ApexPages.Severity level, Boolean includeHigher){
        final ApexPages.Message[] messages = PageUtils.getMessagesAtLevel(level,includeHigher);
        System.assert(messages != null && messages.size() > 0,'No errors exist');
    }
    
    global static void assertNoMessagesAtLevelExist(ApexPages.Severity level, Boolean includeHigher){
        final ApexPages.Message[] messages = PageUtils.getMessagesAtLevel(level,includeHigher);
        System.assert(messages == null || messages.size() <= 0,PageUtils.messagesToString(messages));
    }

    global static List<SObject> getObject(SObject prototype, Integer count, Map<String,String> mString, Boolean doInsert){
        final Integer MAX_COUNT = 100;
        if(prototype == null){
            return null;
        }
        //the following will for sure work; however, it requires a describe
        //String objectName = prototype.getSObjectType().getDescribe().getName();
        
        //the following will work using observed string representations of SObjects
        String objectName = StringUtils.split(''+prototype,':')[0];
        
        List<SObject> objects = Database.query(
            'select Id from ' 
            + objectName 
            + ' where Id = \'0015000000Mrr40\' LIMIT 0'); // use dummy Id to ensure no return
        if(count <= 0){
            return objects;
        }
        Schema.sObjectType prototypeToken = prototype.getSObjectType();
        for(Integer i = 0; i < count && i < MAX_COUNT; i++){
            objects.add((SObject)prototypeToken.newSObject());
        }

        if(mString != null && !mString.isEmpty()){
            for(SObject anObject : objects){
                for(String key : mString.keySet()){
                    anObject.put(key,mString.get(key));
                }            
            }
        }
        if(doInsert){
            insert objects;
        }    
        return objects;
    }
    
    global static void assertUrlsAreEqual(String expected, String actual){
        final PageReference expectedRealPageReference = new PageReference(StringUtils.defaultString(expected));
        final PageReference actualRealPageReference = new PageReference(StringUtils.defaultString(actual));
        final String actualBasePath = StringUtils.substringBefore(actual,'?');
        final String expectedBasePath = StringUtils.substringBefore(expected,'?');
        System.assertEquals(    
             expectedBasePath
            ,actualBasePath
            ,'Base paths don\'t match, expected: ' + expectedBasePath + ', actual: ' + actualBasePath
        );
        System.assert(
            MapUtils.equals(expectedRealPageReference.getParameters(),actualRealPageReference.getParameters())
            ,'HTTP Parameters don\'t match, expected: ' + expectedRealPageReference.getParameters() + ', actual: ' + actualRealPageReference.getParameters()    
        );
    }
    // End Omnitracs existing TestUtils Class

    public static Account getAccount(String name)
    {
        Account a = new Account();
        a.Name = name;
        a.BillingCountry = 'United States';
        a.BillingStreet = 'BillingStreet';
        a.BillingCity = 'BillingCity';
        a.BillingPostalCode = 'BillingPostalCode';
        a.BillingState = 'BillingState';        
        a.ShippingCountry = 'United States'; 
        a.Segment__c = 'TL';
        a.Fleet_Size__c = 25;
        return a;
    }

    public static Contact getContact(Account a)
    {
        return getContact(a, 'ut Contact 1');
    }
   
    public static Contact getContact(Account a, String name)
    {
        Contact c = new Contact();
        c.AccountID = a.id;
        c.LastName = name;
        c.Salutation = 'Mr.';
        c.FirstName = name;
        //c.Email = 'dummy84729371@gmail.com';
        return c;
    }
    
    public static Contract getContract(Account a)
    {
        Contract cntrct = new Contract();
        cntrct.AccountId = a.id;
        cntrct.StartDate = date.today();
        cntrct.Agreement_type__c = 'Individual';
        cntrct.Contract_Type__c = 'Customer';
        cntrct.Affiliate_Language__c = 'Yes';
        cntrct.Term_Type__c = 'Fixed';
        cntrct.Legal_Entity_Name__c ='Omnitracs, LLC';
        
        return cntrct;
    }
    
    public static Product2 getProduct(String name)
    {
        Product2 p = new Product2();
        p.Name = name;
        p.IsActive = true;
        return p;
    }
    
    public static Product2 getProduct(String name, String familyName)
    {
        Product2 p = getProduct(name);
        p.Family = familyName;
        return p;
    }

    public static Opportunity getOpportunity(Account a, String name)
    {
        System.debug('-- Account = '+a);

        Opportunity oppty = new Opportunity();
        oppty.AccountID = a.id;
        oppty.Name = name;
        oppty.StageName = 'Qualify'; //'Closed Won';
        oppty.CloseDate = Date.Today().addMonths(2);
        oppty.Role__c = 'Sponsor';
        //oppty.Legal_Review__c = 'Approved';
        //oppty.Status__c = 'Approved';
        //oppty.Order_Type__c = 'New';
        //oppty.Finance_Checklist_Complete__c = true;
        Contact c = getContact(a);
        insert c;
        
        oppty.Contact__c = c.id;
        oppty.Primary_Contact__c = c.id;
        
        Contract cntrct = getContract(a);
        System.debug('-- cntrct = '+cntrct);
        insert cntrct;
        oppty.Contract__c = cntrct.id;
        
        Contact impContact = getContact(a);
        insert impContact;
        
        return oppty;
    }

    public static PriceBook2 getStandardPriceBook()
    {
        //PriceBook2 pb = [Select Id, Name from PriceBook2 where isStandard = true];
        Pricebook2 standardPricebook = new Pricebook2(
                Id = Test.getStandardPricebookId(),
                IsActive = true
        );
        update standardPricebook;
        return standardPricebook;
    }
    
    public static PriceBookEntry getPriceBookEntry(Product2 p, PriceBook2 pb)
    {
        PriceBookEntry pbe = new PriceBookEntry();
        pbe.PriceBook2ID = pb.id;
        pbe.Product2Id = p.id;
        pbe.UnitPrice = 1;
        pbe.isActive = true;
        return pbe;
    }
    
    public static OpportunityLineItem getOLI(Opportunity oppty)
    {
        Product2 p = getProduct('ut prod1', 'ut family');
        insert p;
        PriceBook2 pb = getStandardPriceBook();
        PriceBookEntry pbe = getPriceBookEntry(p, pb);
        insert pbe;
        OpportunityLineItem oli = new OpportunityLineItem();
        oli.OpportunityID = oppty.id;
        oli.PriceBookEntryID = pbe.id;
        oli.Quantity = 1;
        oli.TotalPrice = 1;
        //oli.List_Price__c = 1;
        //oli.Extended_Term_Amount__c = 1;
        //oli.Term_Begin_Date__c = Date.Today();
        //oli.Term_End_Date__c = Date.Today().adddays(364);
        //oli.Product_Type__c = 'Product Type';
        //oli.License_Metric_Quantity__c = 1;
        return oli;
    }
    
    public static OpportunityLineItem getOLI(Opportunity oppty, Product2 p)
    {
        PriceBook2 pb = getStandardPriceBook();
        PriceBookEntry pbe = getPriceBookEntry(p, pb);
        insert pbe;
        OpportunityLineItem oli = new OpportunityLineItem();
        oli.OpportunityID = oppty.id;
        oli.PriceBookEntryID = pbe.id;
        oli.Quantity = 1;
        oli.TotalPrice = 1;
        //oli.List_Price__c = 1;
        //oli.Extended_Term_Amount__c = 1;
        //oli.Term_Begin_Date__c = Date.Today();
        //oli.Term_End_Date__c = Date.Today().adddays(364);
        //oli.Product_Type__c = 'Product Type';
        //oli.License_Metric_Quantity__c = 1;
        return oli;
    }

    public static Case getCase(Account a, Contact c)
    {
        Case cs = new Case();
        cs.AccountId = a.id;
        cs.ContactId = c.id;
        
        return cs;
    }
    
    public static Asset__c getAsset(Account a, Product2 p)
    {
        return getAsset(a, p, 1);
    }
    
    public static Asset__c getAsset(Account a, Product2 p, Contract c)
    {
        return getAsset(a, p, c, 1);
    }
    
    public static Asset__c getAsset(Account a, Product2 p, Decimal quantity)
    {
        Asset__c ast = new Asset__c();
        ast.Product__c = p.id;
        ast.Account__c = a.id;
        ast.Maintenance_Status__c = 'On Maintenance';
        ast.Billing_Frequency__c = 'Monthly';
        //ast.Contracted_Quantity__c = quantity;
        ast.License_Metric_Quantity__c = quantity;
        //ast.Purchase_Date__c = Date.Today();
        ast.Term_Start_Date__c = Date.Today();
        ast.Term_End_Date__c = Date.Today()+364;
        ast.ARR__c = 1000;
        return ast;
    }
    
    public static Asset__c getAsset(Account a, Product2 p, Contract c, Decimal quantity)
    {
        Asset__c ast = new Asset__c();
        ast.Product__c = p.id;
        ast.Account__c = a.id;
        ast.Contract__c = c.id;
        ast.Maintenance_Status__c = 'On Maintenance';
        ast.Billing_Frequency__c = 'Monthly';
        //ast.Contracted_Quantity__c = quantity;
        ast.License_Metric_Quantity__c = quantity;
        //ast.Purchase_Date__c = Date.Today();
        ast.Term_Start_Date__c = Date.Today();
        ast.Term_End_Date__c = Date.Today()+364;
        ast.ARR__c = 1000;
        return ast;
    }

    public static Case getCase()
    {
        Case c = new Case();
        return c;
    }
    
    public static List<Contact> createContact(Integer size, String accountID){
        List<Contact> Contacts = new List<Contact>();
        for(Integer i=0; i<size; i++){
            Contact k = new Contact(firstname='test name'+i, lastname = 'test lastname'+1,email='jjayoma@cloudsherpas.com', AccountID = AccountID);
            Contacts.add(k);
        }
        
        if(Contacts.size()>0){
            insert Contacts;
        }
        return Contacts;
    }
}