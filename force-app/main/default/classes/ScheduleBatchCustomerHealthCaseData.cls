global class ScheduleBatchCustomerHealthCaseData implements Schedulable{
    public static string SECONDS = '0';
    public static string MINUTES = '00';
    public static string HOURS = '2';
    public static string DAY_OF_MONTH = '?';
    public static string MONTH = '*';
    public static string DAY_OF_WEEK= '1#1';
    
    public static string TIME_TO_RUN = SECONDS + ', ' + MINUTES + ', ' + HOURS + ', ' + DAY_OF_MONTH + ', ' + MONTH + ', ' + DAY_OF_WEEK;
    public static string NAME_OF_JOB = 'Batch Customer Health Case Data';
    
    global void execute(SchedulableContext SC)
    {
        
        BatchCustomerHealthCaseEscalations BCHCE = new BatchCustomerHealthCaseEscalations();
        database.executeBatch(BCHCE);
        
    }
}