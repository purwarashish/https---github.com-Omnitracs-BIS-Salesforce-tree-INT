/*********************************************************************************
Program:                Test Class for Utils
Programmer:             Rex David - CloudSherpas
Date:                   October 29, 2014
**********************************************************************************/  
@isTest(SeeAllData=True)
private class UtilsTest {
    public static Account accountInstance = new Account();
    static{
        Schema.DescribeSObjectResult acccfrSchema = Schema.SObjectType.Account; 
        Map<String,Schema.RecordTypeInfo> AccountRecordTypeInfo = acccfrSchema.getRecordTypeInfosByName();
        Id accountRtId = AccountRecordTypeInfo .get('T&L Sales Accounts').getRecordTypeId();
        
        accountInstance     =   new Account(Name    =   'testAccount',
                                            Phone   =   '12345',
                                            //Account_Classification__c   =   'Prospect',
                                            //Account_Status__c   =   'Active',
                                            //Account_Type__c =   'Association',
                                            recordtypeid    =   accountRtId   
                                            );
        insert accountInstance;  
    }
    private static testMethod void testUtils() {
        Id aId = accountInstance.Id;
        String whereClause = 'WHERE Id =\'aId\'';
        Test.startTest();
            Utils uti = new Utils();
            Utils.getCreatableFieldsSOQL('Account',whereClause);
        Test.stopTest();
    }

}