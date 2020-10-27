/**************************************************************************************************************************
Developer                Date           Description
Sripathi Gullapalli      3/12/2016      Test Trigger handler class to send a notification when the Project completion is > 50%
****************************************************************************************************************************/

@isTest
private class TestProjectTriggerHandler {
    static testMethod void testProjectNotification() {
        
        PSAEnhancementTestData tpsaTest = new PSAEnhancementTestData();                                
        
        List<AccountRecordTypes__c> accntRTList = new List<AccountRecordTypes__c>();
        AccountRecordTypes__c accntRType = new AccountRecordTypes__c();
        accntRType.Name='TL_SALES_ACCOUNT_RECORD_TYPE_ID';
        accntRType.RecordTypeID__c = Schema.SObjectType.Account.getRecordTypeInfosByName().get('T&L Sales Accounts').getRecordTypeId();
        accntRTList.add(accntRType);
        AccountRecordTypes__c accntRType1 = new AccountRecordTypes__c();
        accntRType1.Name='COMPETITOR_RECORD_TYPE_ID';
        accntRType1.RecordTypeID__c = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Competitor').getRecordTypeId();
        accntRTList.add(accntRType1);
        insert accntRTList;
         
        List<AllAccountUtils__c> csaList = tpsaTest.customSettingsAccountUtils();
        insert csaList;
          
        Account accnt = new Account();                                                             
        accnt.Name='Test Account';
        accnt.Primary_Business_Unit__c='Omnitracs Domestic';
        accnt.Account_Classification__c='Prospect';
        accnt.Account_Status__c='Active';
        accnt.phone='1234567890';
        accnt.QWBS_Status__c='Active';       
        accnt.RecordTypeId= accntRTList[0].RecordTypeID__c;         
        accnt.BillingStreet='Test St';
        accnt.BillingCity='Frisco';
        accnt.BillingState='TX';
        accnt.BillingCountry='USA';  
        insert accnt;                
        
        Contact cntct=tpsaTest.createContact(accnt.Id);      
        insert cntct;         
        
        PSA_Settings__c psa = new PSA_Settings__c(Name='PSA', Notification_OWD__c='Omnitracs Support (No-Reply)', Project_Notification_Template__c='PSA_Project_more_than_fifty_percent_complete');   
        insert psa;           
        List<pse__Proj__c> projectList = tpsaTest.createProject(accnt.Id);     
        insert projectList;  
        
        pse__Proj__c proj = projectList.get(0);
        proj.pse__Billable_External_Hours__c = 10;
        proj.pse__Billable_Internal_Hours__c = 0;
        proj.pse__Planned_Hours__c = 10;
        proj.pse__Project_Manager__c = cntct.Id;
        update proj;
             
    }
}