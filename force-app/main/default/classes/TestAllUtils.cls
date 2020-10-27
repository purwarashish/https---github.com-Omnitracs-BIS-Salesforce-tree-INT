@isTest

Public class TestAllUtils{

    public static void createTAndLSalesAccounts(){
        Id acctRT = [select Id from RecordType where SobjectType = 'Account' and DeveloperName = 'TLSalesAccounts'].Id;
        
        Id acctCompRT = [select Id from RecordType where SobjectType = 'Account' and DeveloperName = 'Competitor'].Id;
        
       
        
        AccountRecordTypes__c actCustomSetting = new AccountRecordTypes__c();
        actCustomSetting.Name = 'TL_SALES_ACCOUNT_RECORD_TYPE_ID';
        actCustomSetting.RecordTypeID__c = acctRT;
        insert actCustomSetting;
        
        AccountRecordTypes__c actCustomSetting1 = new AccountRecordTypes__c();
        actCustomSetting1.Name = 'COMPETITOR_RECORD_TYPE_ID';
        actCustomSetting1.RecordTypeID__c = acctCompRT;
        insert actCustomSetting1;
        
        List<AllAccountUtils__c> lstActUtils = new List<AllAccountUtils__c>();
        
        
        AllAccountUtils__c actUtils = new AllAccountUtils__c();
        actUtils.Name = 'BILLING_ADDRESS';
        actUtils.Value__c = '109 DIXON RD';
        lstActUtils.add(actUtils);
        
        AllAccountUtils__c actUtils1 = new AllAccountUtils__c();
        actUtils1.Name = 'PHONE';
        actUtils1.Value__c = '9999999996';
        lstActUtils.add(actUtils1);
        
        AllAccountUtils__c actUtils2 = new AllAccountUtils__c();
        actUtils2.Name = 'ACCOUNT_TYPE';
        actUtils2.Value__c = 'Developer';
        lstActUtils.add(actUtils2);
        
        AllAccountUtils__c actUtils3 = new AllAccountUtils__c();
        actUtils3.Name = 'MARKET';
        actUtils3.Value__c = 'T&L';
        lstActUtils.add(actUtils3);
        
        AllAccountUtils__c actUtils4 = new AllAccountUtils__c();
        actUtils4.Name = 'DISTRICT';
        actUtils4.Value__c = 'West District 4';
        lstActUtils.add(actUtils4);
        
        AllAccountUtils__c actUtils5 = new AllAccountUtils__c();
        actUtils5.Name = 'STATUS';
        actUtils5.Value__c = 'Active Prospect';
        lstActUtils.add(actUtils5);
        
        AllAccountUtils__c actUtils6 = new AllAccountUtils__c();
        actUtils6.Name = 'LEAD_SOURCE';
        actUtils6.Value__c = 'Database Marketing';
        lstActUtils.add(actUtils6);
        
        AllAccountUtils__c actUtils7 = new AllAccountUtils__c();
        actUtils7.Name = 'AVG_LEN_HAUL';
        actUtils7.Value__c = 'Local';
        lstActUtils.add(actUtils7);
        
        AllAccountUtils__c actUtils8 = new AllAccountUtils__c();
        actUtils8.Name = 'REG_VEHICLES';
        actUtils8.Value__c = 'Test Vehicle';
        lstActUtils.add(actUtils8);
        
        AllAccountUtils__c actUtils9 = new AllAccountUtils__c();
        actUtils9.Name = 'OTR_VEHICLES';
        actUtils9.Value__c = 'Test OTR Vehicle';
        lstActUtils.add(actUtils9);
        
        AllAccountUtils__c actUtils10 = new AllAccountUtils__c();
        actUtils10.Name = 'PRIMARY_BUSINESS';
        actUtils10.Value__c = 'Federal';
        lstActUtils.add(actUtils10);
        
        AllAccountUtils__c actUtils11 = new AllAccountUtils__c();
        actUtils11.Name = 'PRIMARY_COMMODITY';
        actUtils11.Value__c = 'Acid';
        lstActUtils.add(actUtils11);
        
        AllAccountUtils__c actUtils12 = new AllAccountUtils__c();
        actUtils12.Name = 'EVAL_CUSTOMERS';
        actUtils12.Value__c = 'Test Eval Customer';
        lstActUtils.add(actUtils12);
        
        AllAccountUtils__c actUtils13 = new AllAccountUtils__c();
        actUtils13.Name = 'CONTRACT_CUSTOMER';
        actUtils13.Value__c = 'Test Contract Customer';
        lstActUtils.add(actUtils13);
        
        AllAccountUtils__c actUtils14 = new AllAccountUtils__c();
        actUtils14.Name = 'CONTACT_COMMENT';
        actUtils14.Value__c = 'Testing Comments';
        lstActUtils.add(actUtils14);
        
        AllAccountUtils__c actUtils15 = new AllAccountUtils__c();
        actUtils15.Name = 'CONTRACT_EXPIRATION';
        actUtils15.Value__c = 'Testing Comments';
        lstActUtils.add(actUtils15);
        
        AllAccountUtils__c actUtils16 = new AllAccountUtils__c();
        actUtils16.Name = 'COMP_PLATFORM';
        actUtils16.Value__c = 'Mainframe';
        lstActUtils.add(actUtils16);
        
        AllAccountUtils__c actUtils17 = new AllAccountUtils__c();
        actUtils17.Name = 'RANKING';
        actUtils17.Value__c = 'Large';
        lstActUtils.add(actUtils17);
        insert lstActUtils;
    }
    public static void createCaseTriggerSettings(){
        CaseTrigger_Global_Variable__c objCaseTrigger = new CaseTrigger_Global_Variable__c();
        objCaseTrigger.Name = 'EOX Return Record Type Name';
        objCaseTrigger.Value__c = 'EOX Return';
        insert objCaseTrigger;
        
        Id caseRT = [select Id from RecordType where SobjectType = 'Case' and DeveloperName = 'CallCenter'].Id;
        
        CaseTrigger_Global_Variable__c objCaseTrigger1 = new CaseTrigger_Global_Variable__c();
        objCaseTrigger1.Name = 'CallCenter_RecordTypeId';
        objCaseTrigger1.Value__c = caseRT;
        insert objCaseTrigger1;
        
        Id caseNMCRT = [select Id from RecordType where SobjectType = 'Case' and DeveloperName = 'NMCAccountRequest'].Id;
        
        CaseTrigger_Global_Variable__c objCaseTrigger2 = new CaseTrigger_Global_Variable__c();
        objCaseTrigger2.Name = 'NMCAccountRequest_RecordTypeId';
        objCaseTrigger2.Value__c = caseNMCRT;
        insert objCaseTrigger2;
        
        Id caseClosedNMCRT = [select Id from RecordType where SobjectType = 'Case' and DeveloperName = 'ClosedNMCAccountRequest'].Id;
        
        CaseTrigger_Global_Variable__c objCaseTrigger3 = new CaseTrigger_Global_Variable__c();
        objCaseTrigger3.Name = 'ClosedNMCAccountRequest_RecordTypeId';
        objCaseTrigger3.Value__c = caseClosedNMCRT;
        insert objCaseTrigger3;
        
        Id caseSubmittedNMCRT = [select Id from RecordType where SobjectType = 'Case' and DeveloperName = 'SubmittedNMCAccountRequest'].Id;
        
        CaseTrigger_Global_Variable__c objCaseTrigger4 = new CaseTrigger_Global_Variable__c();
        objCaseTrigger4.Name = 'SubmittedNMCAccountRequest_RecordType';
        objCaseTrigger4.Value__c = caseSubmittedNMCRT;
        insert objCaseTrigger4;
        
        CaseTrigger_Global_Variable__c objCaseTrigger5 = new CaseTrigger_Global_Variable__c();
        objCaseTrigger5.Name = 'GV ConnectionUser Id';
        objCaseTrigger5.Value__c = '00550000001b4gPAAQ';
        insert objCaseTrigger5;
        
        CaseTrigger_Global_Variable__c objCaseTrigger6 = new CaseTrigger_Global_Variable__c();
        objCaseTrigger6.Name = 'Email Agent';
        objCaseTrigger6.Value__c = 'Email Agent';
        insert objCaseTrigger6;
        
        CaseTrigger_Global_Variable__c objCaseTrigger7 = new CaseTrigger_Global_Variable__c();
        objCaseTrigger7.Name = 'Roadnet Business Unit';
        objCaseTrigger7.Value__c = 'Roadnet';
        insert objCaseTrigger7;
        
        CaseTrigger_Global_Variable__c objCaseTrigger8 = new CaseTrigger_Global_Variable__c();
        objCaseTrigger8.Name = 'Roadnet Anywhere';
        objCaseTrigger8.Value__c = 'Roadnet Anywhere';
        insert objCaseTrigger8;
        
        Id caseProfessionalRT = [select Id from RecordType where SobjectType = 'Case' and DeveloperName = 'Professional_Services'].Id;
        
        CaseTrigger_Global_Variable__c objCaseTrigger9 = new CaseTrigger_Global_Variable__c();
        objCaseTrigger9.Name = 'ProfessionalServices_RecordTypeId';
        objCaseTrigger9.Value__c = caseProfessionalRT;
        insert objCaseTrigger9;
        
        CaseTrigger_Global_Variable__c objCaseTrigger10 = new CaseTrigger_Global_Variable__c();
        objCaseTrigger10.Name = 'Email Agent';
        objCaseTrigger10.Value__c = 'Email Agent';
        insert objCaseTrigger10;
        
        Id userEmailAgent = [select Id,Name from User where Name = 'Email Agent'].Id;
        
        CaseTrigger_Global_Variable__c objCaseTrigger11 = new CaseTrigger_Global_Variable__c();
        objCaseTrigger11.Name = 'Email Agent UserId';
        objCaseTrigger11.Value__c = userEmailAgent;
        insert objCaseTrigger11;
        
        BusinessHours bhs=[select id,Name from BusinessHours where Name='Roadnet Domestic Support'];
        
        SystemIds__c objSys = new SystemIds__c();
        objSys.BusinessHoursId_Roadnet__c = bhs.Id;
        insert objSys;
    }
    public static void createOpportunityUtils(){
        OpportunityLegalReviewStatus__c objOpptyLegal = new OpportunityLegalReviewStatus__c();
        objOpptyLegal.Name = 'ContractDataEntryProcess';
        objOpptyLegal.value__c = 'Contract Data Entry Process';
        insert objOpptyLegal;
        
        OpportunityLegalReviewStatus__c objOpptyWaiting = new OpportunityLegalReviewStatus__c();
        objOpptyWaiting.Name = 'Waiting for Counter-Signature';
        objOpptyWaiting.Value__c = 'Waiting for Counter-Signature';
        insert objOpptyWaiting;
        
        OpportunityLegalReviewStatus__c objOpptyReview = new OpportunityLegalReviewStatus__c();
        objOpptyReview.Name = 'InitialReview';
        objOpptyReview.Value__c = 'Initial Review';
        insert objOpptyReview;
        
        OpportunityLegalReviewStatus__c objOpptyApproved = new OpportunityLegalReviewStatus__c();
        objOpptyApproved.Name = 'Approved';
        objOpptyApproved.Value__c = 'Approved';
        insert objOpptyApproved;
    }
}