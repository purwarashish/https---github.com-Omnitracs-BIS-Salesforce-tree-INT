/**
 * This class contains unit tests for validating the behavior of Apex classes - 
 * SerializedUnitSummaryBatch and SerializedUnitSummaryScheduler
 */
@isTest
private class TestSerialzedUnitSummaryClasses {
    @isTest(seeAllData=true)
    static void myUnitTest() {

        test.startTest();
        list<Account> lstAccount = new list<Account>();
        list<Serialized_Units__c> lstSumm = new list<Serialized_Units__c>();
        list<Serialized_Unit_Summary_Archive__c> lstSumArc = new list<Serialized_Unit_Summary_Archive__c>();
        list<Serialized_Unit_Summary__c> lstUnitSum = new list<Serialized_Unit_Summary__c>();
        
        for(integer i=0;i<2;i++)
        {
            Account newAccount = new Account();
            newAccount.Name = 'SFDC';
            newAccount.Type = 'Other';
            newAccount.BillingStreet = 'Test Address';
            newAccount.BillingCity = 'Test City';
            newAccount.BillingCountry = 'Test Country';
            
            lstAccount.add(newAccount);
        }
        insert lstAccount;
        
        for(integer i=0;i<5;i++)
        {
            Serialized_Units__c newObj = new Serialized_Units__c();
            newObj.Account__c = lstAccount[0].Id;
            newObj.Item_Type__c = 'OVT';
            newObj.Serial__c = 'test'+i;
            lstSumm.add(newObj);
            
            Serialized_Unit_Summary_Archive__c newObj2 = new Serialized_Unit_Summary_Archive__c();
            newObj2.Account__c = lstAccount[0].Id;
            newObj2.Item_Type__c = 'OVT';
            newObj2.Name = 'test'+i;
            lstSumArc.add(newObj2);
            
            Serialized_Unit_Summary__c newObj3 = new Serialized_Unit_Summary__c();
            newObj3.Account__c = lstAccount[0].Id;
            newObj3.Item_Type__c = 'OVT';
            newObj3.Name = 'test'+i;
            newObj3.NMC_System__c = '1';
            lstUnitSum.add(newObj3);
        }
        insert lstSumm;
        insert lstSumArc;
        insert lstUnitSum;        
        
        NMC_Account__c newNMCAcct  = new NMC_Account__c();
        newNMCAcct.Account__c = lstAccount[1].Id;
        newNMCAcct.NMC_Account_Name__c = 'Test NMC Acct';
        insert newNMCAcct;
        
        for(integer i=0;i<lstSumm.size();i++)
        {
            lstSumm[i].NMC_Account__c = newNMCAcct.Id;
        }
        update lstSumm;
        
        SerializedUnitSummaryUtils newObj = new SerializedUnitSummaryUtils();
        string IdString = SerializedUnitSummaryUtils.GetIDString(lstSumm[0]);
        string GetIDStringSummary = SerializedUnitSummaryUtils.GetIDStringSummary(lstUnitSum[0]);
        Map<String,Double> mpId = new Map<String,Double>();
        mpId.put(IdString,1);
        SerializedUnitSummaryUtils.UpsertSummaryUnits(mpId);
        //SerializedUnitSummaryUtils.updateSerializedUnitSummary();        //taking lot of time to run
        SerializedUnitSummaryUtils.checkCount(1,lstAccount[1].Id,'OV','test');
        SerializedUnitSummaryUtils.GetSerializedUnit(lstAccount[1].Id,'OV','test');
        
        test.stopTest();

    }
    
     static testMethod void myUnitTest2() {

        test.startTest();
            //Account newAccount;
            list<Serialized_Units__c> lstSumm = new list<Serialized_Units__c>();
               
            for(integer i=0;i<200;i++)
            {
                Serialized_Units__c newObj1 = new Serialized_Units__c();
                //if(newAccount != null)
                    //newObj1.Account__c = newAccount.Id;
                newObj1.Item_Type__c = 'OVT';
                newObj1.Serial__c = 'test'+i;
                lstSumm.add(newObj1);                               
            }
            insert lstSumm;
            //insert lstSumArc; 
            
            String CRON_EXP = '0 0 0 3 9 ? 2022';
            String jobId = System.schedule('BasicScheduledApexTest',CRON_EXP,new SerializedUnitSummaryScheduler());
            
            // Get the information from the CronTrigger API object
            CronTrigger ct = [SELECT id, CronExpression, TimesTriggered, NextFireTime
                             FROM CronTrigger WHERE id = :jobId];
            
            // Verify the expressions are the same
            System.assertEquals(CRON_EXP,
            ct.CronExpression);
            
            // Verify the job has not run
            System.assertEquals(0, ct.TimesTriggered);
            
            // Verify the next time the job will run
            System.assertEquals('2022-09-03 00:00:00',
            String.valueOf(ct.NextFireTime));
            
        test.stopTest();

    }

}