/**********************************************************************************
Name    : TestTriggerCronSetExecuteFlag
Author  : David Ragsdale
Date    : 8 April 2011
Usage   : TestClass for CronSetExecuteFlag
*************************************************************************************/
@isTest(SeeAllData = true)
public class TestTriggerCronSetExecuteFlag {
    public static testMethod void testSuccess() {
        boolean expectedResult = true;
        Cron__c newCron = new Cron__c(Execute__c = false);

        try
        {
            insert newCron;
        } catch (DmlException e){
            //Assert Error
            System.assertEquals('FIELD_CUSTOM_VALIDATION_EXCEPTION' , 
                                 e.getDmlStatusCode(0) );
        }

        Test.startTest();
        Cron__c testCron = [select id from Cron__c WHERE Id = :newCron.Id limit 1];
        testCron.Execute__c = TRUE;
        update testCron; 
        Test.stopTest();
        
        system.assertEquals(testCron.Execute__c, expectedResult);
    }
}