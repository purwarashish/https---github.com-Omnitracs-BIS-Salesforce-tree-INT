@isTest
public class TimeCardBatchScheduleTest{
    
    static testMethod void TimeCardBatchSchedule_Test()
    {
         String CRON_EXP = '0 0 0 3 9 ? 2032';
         String jobId = System.schedule('BasicScheduledApexTest',CRON_EXP,new TimeCardBatchSchedule(false,200));
            
         // Get the information from the CronTrigger API object
         CronTrigger ct = [SELECT id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
            
         // Verify the expressions are the same
         System.assertEquals(CRON_EXP,ct.CronExpression);
            
         // Verify the job has not run
         System.assertEquals(0, ct.TimesTriggered);
            
         // Verify the next time the job will run
         System.assertEquals('2032-09-03 00:00:00',String.valueOf(ct.NextFireTime));
     }       
    
}