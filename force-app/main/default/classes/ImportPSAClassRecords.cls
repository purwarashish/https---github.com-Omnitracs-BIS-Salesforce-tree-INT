/*
Author : TCS Banglore offshore Team
Summary: Scheduler to fetch Class record from SumTotal system.
*/
global class ImportPSAClassRecords implements Schedulable {

   global void execute(SchedulableContext SC) {

      callMethods();

   }
   @Future(callout=true)
   global static void callMethods(){
       SumTotalIntegrationCallout obj=new SumTotalIntegrationCallout('Class');
   }
}