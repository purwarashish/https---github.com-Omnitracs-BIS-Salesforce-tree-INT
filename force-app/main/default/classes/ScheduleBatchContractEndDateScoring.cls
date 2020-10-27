global class ScheduleBatchContractEndDateScoring implements Schedulable{
    public static string SECONDS = '0';
    public static string MINUTES = '00';
    public static string HOURS = '3';
    public static string DAY_OF_MONTH = '?';
    public static string MONTH = '*';
    public static string DAY_OF_WEEK= '1#1';
    
    public static string TIME_TO_RUN = SECONDS + ', ' + MINUTES + ', ' + HOURS + ', ' + DAY_OF_MONTH + ', ' + MONTH + ', ' + DAY_OF_WEEK;
    public static string NAME_OF_JOB = 'Batch Contract End Date Scoring';
    
    global void execute(SchedulableContext SC)
    {
        
        BatchContractEndDateScoring BCEDS = new BatchContractEndDateScoring();
        database.executeBatch(BCEDS);
        
    }
}