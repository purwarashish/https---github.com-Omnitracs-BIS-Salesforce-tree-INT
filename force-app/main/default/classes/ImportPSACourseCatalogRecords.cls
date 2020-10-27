/*
Author : TCS Banglore offshore Team
Summary: Scheduler to fetch Course record from SumTotal system.
*/
global class ImportPSACourseCatalogRecords implements Schedulable {

   global void execute(SchedulableContext SC) {

      callMethods();

   }
   @Future(callout=true)
   global static void callMethods(){
       SumTotalIntegrationCallout obj=new SumTotalIntegrationCallout('Course Catalog');
   }
}