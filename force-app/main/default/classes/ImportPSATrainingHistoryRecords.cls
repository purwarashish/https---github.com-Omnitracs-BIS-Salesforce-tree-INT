/*
Author : TCS Banglore offshore Team
Summary: Scheduler to fetch transcript/training history record from SumTotal system.
*/
global class ImportPSATrainingHistoryRecords implements Schedulable {

   global void execute(SchedulableContext SC) {

      callMethods();

   }
   @Future(callout=true)
   global static void callMethods(){
       SumTotalIntegrationCallout obj=new SumTotalIntegrationCallout('Training History');
   }
}