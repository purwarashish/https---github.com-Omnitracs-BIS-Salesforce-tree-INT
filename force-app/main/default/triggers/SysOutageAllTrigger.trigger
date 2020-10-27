/*********************************************************************************
Date: 08 June 2011 
Author: Shruti Karm

Description: This trigger will have all the operation that required for System Outage
             object on any DML operation.
************************************************************************************/

trigger SysOutageAllTrigger on System_Outage__c (after insert, after update) {

/*******************************************************************************************
    The updateCase() will update the Severity of Case related to the System Outage
             with '1-Critical'
********************************************************************************************/   
   SystemOutageUtils.updateCase(Trigger.new);
    //if(strError != null && strError.trim() != '')
        //Trigger.new[0].addError(strError);
}