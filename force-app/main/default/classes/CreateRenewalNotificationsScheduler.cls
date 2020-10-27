global class CreateRenewalNotificationsScheduler  implements Schedulable{
	
    public static string snQuery;
	public CreateRenewalNotificationsScheduler(){
    }
    
    global void execute(SchedulableContext SC)
    {
        
        /*
         CreateRenewalNotificationsScheduler crns = new CreateRenewalNotificationsScheduler();
	     String rnSch = '0 0 * * * ?';
		 system.schedule('Renewal Notifications Batch', rnSch, crns);
		 */
        String snQuery = 'select Id, Account__c from Renewal_Notifications__c where Email_Schedule_Send_Date__c = :todayDate and '+
				  'Fee_Increase_Contact__c != null and Uplift_Effective_Date__c != null and Uplift_Percent__c != null and '+
				  'Email_Actual_Sent_Date__c = null';
        CreateRenewalNotificationsBatch crcs = new CreateRenewalNotificationsBatch(snQuery);
        database.executeBatch(crcs);
    }
    
}