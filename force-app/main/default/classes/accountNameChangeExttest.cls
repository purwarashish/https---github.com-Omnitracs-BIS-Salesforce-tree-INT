@isTest(seeAllData=true)
private class accountNameChangeExttest {
    public static Account accountInstance = new Account();
    static{
        Schema.DescribeSObjectResult acccfrSchema = Schema.SObjectType.Account; 
        Map<String,Schema.RecordTypeInfo> AccountRecordTypeInfo = acccfrSchema.getRecordTypeInfosByName();
        Id accountRtId = AccountRecordTypeInfo .get('Non-Sales').getRecordTypeId();
        system.debug('**** accountRtId'+accountRtId);
    
        accountInstance     =   new Account(Name    =   'testAccount',
                                        Phone   =   '12345',
                                        Account_Classification__c   =   'Prospect',
                                        Account_Status__c   =   'Active',
                                        Account_Type__c =   'Association',
                                        recordtypeid    =   accountRtId,
                                        Legal_Name__c   =   'testLEGALNAME'
                                        );
        system.debug('**** accountRtId'+accountInstance.recordtypeid);                               
        insert accountInstance;
    }
    private static testMethod void testaccountNameChangeExt() {
        ApexPages.StandardController stdController = new ApexPages.StandardController(accountInstance);
        accountNameChangeExt controller = new accountNameChangeExt(stdController);
        controller.getmyID();
        controller.getOID();
    }

}