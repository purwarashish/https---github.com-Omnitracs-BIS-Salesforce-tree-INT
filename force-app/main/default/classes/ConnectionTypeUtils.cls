/*********************************************************************
Name    : ConnectionTypeUtils
Author  : David Ragsdale
Date    : 15 January 2012

Usage   : Provides various utility operations for the Connection Type object
    
Dependencies : 
- Custom Label - HUB_RECORDTYPE_ID
- Custom Lable - HUBADMIN_OWNER_ID
*********************************************************************/
Public with Sharing class ConnectionTypeUtils {
   
    public static string createCase(string NMCAccountId, string CompanyId)
    {
        try 
        { 
            list <NMC_Account__c> lstNMCAccount = new list <NMC_Account__c>();
            
            lstNMCAccount = [SELECT Account__c FROM NMC_Account__c WHERE Id = :NMCAccountId LIMIT 1];    
                 
            Case newCase = new Case();
        
            newCase.Queue__c ='HubAdmin';
            newCase.OwnerId = System.Label.HUBADMIN_OWNER_ID;
            newCase.Category__c = 'HubAdmin';
            newCase.Type_Level_2__c = 'Activate Service/Feature';
            newCase.Area_Level_3__c = 'VQS';
            newCase.Priority ='2-Medium';
            newCase.RecordTypeId = System.Label.HUB_RECORDTYPE_ID;
            newCase.NMC_Account__c = NMCAccountID;
            newCase.Subject = 'Request for Manual Application Setup - VQS';
            newCase.Description = 'Request for Manual Application Setup \n\n Please set up the following company for VQS - Create Company, User and PWD in VQS\n\n Company Id: ' + CompanyId;
            newCase.Status = 'New - Unassigned';
            newCase.Substatus__c = '';
                    
            if (lstNMCAccount.size() > 0)
            {
                newCase.AccountId = lstNMCAccount[0].Account__c;
            }
        
            insert newCase;

            return newCase.Id;      
        }catch (exception e)
        {
            System.debug('@@Error@@ ' + e.getMessage());
            return e.getMessage();
        }
    }
}