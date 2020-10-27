@isTest
public class MonitorTimeCardBatchAndNotifyTest
{

    static testMethod void runTest()
    {
            MonitorTimeCardBatchAndNotify m = new MonitorTimeCardBatchAndNotify();
            SchedulableContext SC;
            m.execute(SC);
    }
}