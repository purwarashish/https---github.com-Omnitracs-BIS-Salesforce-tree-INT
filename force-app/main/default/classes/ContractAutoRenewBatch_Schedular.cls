global class ContractAutoRenewBatch_Schedular implements Schedulable{
    public static String CRON_EXP = '0 0 2 * * ?';
    global void execute(SchedulableContext sc) {
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime
        FROM CronTrigger WHERE Id = :sc.getTriggerId()];
        
        ContractAutoRenewBatch  carb = new ContractAutoRenewBatch (); 
        database.executebatch(carb);
    }
}