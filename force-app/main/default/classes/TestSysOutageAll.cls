/**
 * This class contains unit tests for validating the behavior of Apex classe - SystemOutageUtils
 * and trigger - SysOutageAllTrigger.
 
 */
@isTest(seeAllData=true)
private class TestSysOutageAll {

    static testMethod void myUnitTest() {
        
        Case newCase = new Case();
        newCase.Priority = '2-Medium';
        insert newCase;
        
        list<System_Outage__c> lstSysOutage = new list<System_Outage__c>();
        for(integer i=0;i<200;i++)
        {
            System_Outage__c newSysOut = new System_Outage__c();
            newSysOut.Case__c = newCase.Id;
            newSysOut.Type__c = 'Degraded Service';
            newSysOut.System__c = 'NMC';
            newSysOut.SubSystems__c = 'BGW200';
            newSysOut.Start_Time__c = system.now();
            lstSysOutage.add(newSysOut);
        }
        insert lstSysOutage;
    }
}