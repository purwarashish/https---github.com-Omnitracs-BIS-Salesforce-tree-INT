/*********************************************************************
Name    : ApprovalProcessUtils
Author  : David Ragsdale
Date    : 11 August 2010

Usage   : Used to allow workflow to be run from Approval Process
    
Dependencies : Workflow "Contract Request Approval Reminders" sets fields

Modified By: Shruti Karn
Modified Date : 16 September 2011
Comment : Setting SystemIsApprovalProcess__c to true to fire the Wrokflow rule
            on Approval process.
            
Modified By  : Rittu Roy
Modified Date: 10/18/15
Purpose      : Fix for Case#02123528 - Added method submitProcessApprovalRequest
               to submit quotes for approval
*********************************************************************/
global class ApprovalProcessUtils 
{

/*******************************************************************************
Method  : updateSystemStatus
Overview: Updates fields on the Contract Request object
NOTE    :  Must be at future to allow Approval Process to update record and then 
            allow trigger / class to udpate record in same process
*******************************************************************************/
    public static Integer firstExecution;
    
    @future
    public static void updateSystemStatus(Set<Id> CRId)
    {
        firstExecution = 1;
        //List to store the Contract request to udpate
        List<Contract_Request__c> CRToUpdate = new List<Contract_Request__c>();
        
        //iterate through the list
        for (Contract_Request__c CR : [SELECT id, Request_Status__c, 
              System_Status__c, System_Is_Future__c, SystemIsApprovalProcess__c
              FROM Contract_Request__c WHERE Id IN :CRId])
        {

            //set the future context field to true
            CR.System_Is_Future__c = true;
            //Sets SystemIsApprovalProcess__c to true to fire the Wrokflow rule
            //on Approval process.
            CR.SystemIsApprovalProcess__c = true;
            
            //if the status fields are not equal, update
            if (CR.Request_Status__c != CR.System_Status__c)
            {
                CR.System_Status__c = CR.Request_Status__c; 
            } 
            //add the record to the list
            CRToUpdate.add(CR);            
        }
        
        try {
            //update the list
            update CRToUpdate;
        } catch (Exception e) {
            //nothing
        }
    }
    
    //Submits a record for approval process
    //Called from Submit for Approval button on Quote
    webService static Boolean submitProcessApprovalRequest(String objId) {
        Boolean errorThrown = false;
              
        Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
        req.setObjectId(Id.valueOf(objId));
        try {
           Approval.process(req);
        }
        catch (Exception e) {
            errorThrown = true;
            System.debug(e.getMessage());
        }
        
        return errorThrown;
     }
}