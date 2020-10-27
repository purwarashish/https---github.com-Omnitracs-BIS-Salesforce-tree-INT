/*******************************************************************************
Date    : 27 July 2010
Author  : David Ragsdale
Overview: Update fields on the Contract Request object to allow for Aproval notifications
Note - rename to ContractRequestUpdateFieldsForApprovalWorkflow
*******************************************************************************/

trigger UpdateFieldsForApprovalWorkflow on Contract_Request__c (before insert, before update) 
{
    Set<Id> CRIds = new Set<Id>();
    
    for(Contract_Request__c CRObj : trigger.New)
    {
        if (CRObj.System_Is_Future__c == true)
        {    
            //set the future context value
            CRobj.System_Is_Future__c = false;

            //This is needed because of the Validation Rule
            //Approval Process sets to true..  reset so validation rule will fire
            //if(ApprovalProcessUtils.firstExecution != 1)
            //{
            //    CRobj.SystemIsApprovalProcess__c = false;
            //}
        } else {
            //Add id's
            CRIds.add(CRobj.Id);
        }
    }
    
    if (!CRIds.isEmpty())
    {
        //fire the @future method to update the status field
        if(ApprovalProcessUtils.firstExecution != 1)
            ApprovalProcessUtils.updateSystemStatus(CRIds);
    }
}