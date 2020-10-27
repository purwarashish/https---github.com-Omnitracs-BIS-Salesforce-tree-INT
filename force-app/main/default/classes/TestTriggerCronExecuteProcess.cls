/**********************************************************************************
Name    : TestTriggerCronExecuteProcess
Author  : David Ragsdale
Date    : 8 April 2011
Usage   : TestClass for Execute Cron Process
*************************************************************************************/
@isTest(SeeAllData = true)
public class TestTriggerCronExecuteProcess {
    public static testMethod void testSuccess() 
    {
        boolean expectedResult = true;
        Monitor__c newMonitor = new Monitor__c(Execute__c = false);

        try
        {
            insert newMonitor;
        } catch (DmlException e){
            //Assert Error
            System.assertEquals('FIELD_CUSTOM_VALIDATION_EXCEPTION' , 
                                 e.getDmlStatusCode(0) );
        }
        
        Test.startTest();
        Monitor__c testMonitor = [select id from Monitor__c limit 1];
        testMonitor.Execute__c = TRUE;
        update testMonitor;       
        Test.stopTest();
        
        system.assertEquals(testMonitor.Execute__c, expectedResult);
    }
}