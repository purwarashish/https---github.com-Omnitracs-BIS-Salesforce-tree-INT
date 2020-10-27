global class MonitorTimeCardBatchAndNotify implements Schedulable {
   global void execute(SchedulableContext SC) {
      //check to see if the Timecard Job ran in the last two hours
      Integer jobs = 0;
      for(AsyncApexJob j : [Select Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CompletedDate
                              from AsyncApexJob
                             where ApexClass.Name = 'TimeCardBatch'
                               and CompletedDate > :System.today() - 1] )
      {
          jobs ++;
      }
                                  
      //
      // Send an email Alert if the Job hasn't run in over 120 minutes
      //
      if(jobs < 1 || Test.isRunningTest())
      {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            
        String[] toAddresses = new String[] {Label.Error_Email_Address}; 
        //String[] ccAddresses = new String[] {Label.Error_Email_Address};
          
        
        // Assign the addresses for the To and CC lists to the mail object.
        mail.setToAddresses(toAddresses);
        //mail.setCcAddresses(ccAddresses);
        
        // Specify the address used when the recipients reply to the email. 
        mail.setReplyTo('support@omnitracs.com');
        
        // Specify the name used as the display name.
        mail.setSenderDisplayName('Omnitracs Support');
        
        mail.setSubject('TimeCardBatch Job Aborted');
        mail.setSaveAsActivity(false); 
        String ErrorBody = 'TimeCardBatch Process has not run in over 2 hours.';
        
        mail.setHtmlBody(ErrorBody);
        
        //send the email
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        
      }
   }
}