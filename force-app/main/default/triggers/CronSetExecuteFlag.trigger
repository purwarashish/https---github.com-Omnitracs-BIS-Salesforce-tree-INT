trigger CronSetExecuteFlag on Monitor__c (after update) {
/*********************************************************************
Name    : CronSetExectuteFlag
Date    : 7 May 2009 
Description: Set the execute flag on the cron to true
History : David Ragsdale (Appirio) - created

*********************************************************************/
  List <Cron__c> cronJob = [Select id, Execute__c from Cron__c limit 1 for update];

  if ( cronJob.size() > 0 ) {
    cronJob[0].Execute__c = True;

    update cronJob;
  }
}