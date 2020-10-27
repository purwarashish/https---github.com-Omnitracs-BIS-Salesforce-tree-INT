global class ScheduleTimeCardCreate implements Schedulable
{
    
    global void execute (SchedulableContext SC){
        try{
               BatchTimeCardEntry newTimeCardCreation = new BatchTimeCardEntry(system.today());
               Database.ExecuteBatch(newTimeCardCreation);
           }
        catch(Exception e)
        {
            System.debug(e.getMessage());
        }
    }
}