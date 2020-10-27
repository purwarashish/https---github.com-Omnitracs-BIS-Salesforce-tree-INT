/*
Author : TCS Banglore offshore Team
Summary: Scheduler to fetch user/contact record from SumTotal system.
*/
global class UpdatePSAContactRecords implements Schedulable {

   global void execute(SchedulableContext SC) {

      callMethods();

   }
   @Future(callout=true)
   global static void callMethods(){
       SumTotalIntegrationCallout obj=new SumTotalIntegrationCallout('Contact');
   }
}