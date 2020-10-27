global class ScheduleBatchCustomerHealthOnAirDelta implements Schedulable{
	
	public static string SECONDS = '0';
    public static string MINUTES = '30';
    public static string HOURS = '1';
    public static string DAY_OF_MONTH = '?';
    public static string MONTH = '*';
    public static string DAY_OF_WEEK= '7#1';
    
    public static string TIME_TO_RUN = SECONDS + ', ' + MINUTES + ', ' + HOURS + ', ' + DAY_OF_MONTH + ', ' + MONTH + ', ' + DAY_OF_WEEK;
    public static string NAME_OF_JOB = 'Batch Customer Health On Air Delta';
    
    global void execute(SchedulableContext SC)
    {
        
        BatchCustomerHealthOnAirDelta BCHOAD = new BatchCustomerHealthOnAirDelta();
        database.executeBatch(BCHOAD);
        
    }
    
}