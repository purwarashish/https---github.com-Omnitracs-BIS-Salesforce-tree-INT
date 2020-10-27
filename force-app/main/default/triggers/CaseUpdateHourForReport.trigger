/*******************************************************************************************************
Date: 7 Sept 2010
 
Author: David Ragsdale

Overview: This Trigger will update the 
*******************************************************************************************************/
trigger CaseUpdateHourForReport on Case (after insert) {

     /*BypassTriggerUtility u = new BypassTriggerUtility();  
     if (u.isTriggerBypassed()) {
         return;
     }

    Set<Id> CaseIds = new Set<Id>();
    
    for (Case CaseObj : Trigger.new) {
                
        //Add id's
        CaseIds.add(Caseobj.Id);
    } // end for 

    if (!CaseIds.isEmpty())
    {
        //fire the @future method to update the status field
        CaseUtils.updateReportHours(CaseIds);
    }*/

}