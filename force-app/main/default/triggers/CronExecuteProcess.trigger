/*********************************************************************
Name    : CronExecuteProcess
Date    : 7 May 2009 
Description: Set the execute flag on the cron to true
             Runs the items controlled by the cron (via Case Utils.updateCaseFromCron method
             Creates a new Monitor record that starts this process all over again
History : 
*********************************************************************/
trigger CronExecuteProcess on Cron__c (before update) {

  //System.LoggingLevel level = LoggingLevel.ERROR;

  // Reset our flag for the next iteration 
  Trigger.new[0].Execute__c = false;

/*********************************************************************
  Add any call to a process here that you want to run every hour or so.
*********************************************************************/  
    //CaseUtils.closeCasesOlderThanSevenDays();
  
    //QLabUtils.checkForUnSubmittedRequests();
  
    //EmailUtils.send7DayCRReminderEmail();
    
    EmailUtilsINT.sendDailyCaseReminderEmail();
    
    //AkamaiCleanCaseComments.removeComments();
  
    //CustomerProjectUtils.updateCPFromCron();
  
/*********************************************************************/

  // Create a new monitor record for the next iteration
  Monitor__c newMonitor = new Monitor__c();

  newMonitor.Execute__c = false;

  insert newMonitor;

  // Finally, cleanup any expired monitor records
  DateTime twoDaysOld = System.now() - 2;

  List <Monitor__c> oldMonitorRecords = [Select Id From Monitor__c Where     LastModifiedDate < :twoDaysOld];

  if ( oldMonitorRecords.size() > 0 )
     delete oldMonitorRecords;
     
}