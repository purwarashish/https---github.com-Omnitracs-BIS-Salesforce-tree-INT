@isTest
private class TestScheduledBatchAccountScoringCal {

    static testMethod void doSchedule() {
        Test.startTest();

        String jobId = System.schedule('TestScheduledBatchAccountScoringCalculation', '0 15 * * * ?', new ScheduledBatchAccountScoringCalculation());
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
        System.assertEquals('0 15 * * * ?',  ct.CronExpression);

        Test.stopTest();
    }
}