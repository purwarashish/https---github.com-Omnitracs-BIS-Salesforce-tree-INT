global Class UpdatePSAScheduleScheduler implements Schedulable{

List<pse__Schedule__c> lstScheduleUpdate;

Public UpdatePSAScheduleScheduler(List<pse__Schedule__c> lstScheduleUpdate)
{
    this.lstScheduleUpdate = lstScheduleUpdate;
}

Public void execute(SchedulableContext sc)
{
     try{
         Update lstScheduleUpdate;
     }
     catch(Exception e)
     {
         system.debug('Scheduler Updation failed due to: '+e.getmessage());
     }
}

}