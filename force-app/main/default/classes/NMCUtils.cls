/*********************************************************************
Name : NMCUtils
Author : Shruti Karn
Date : 25 October 2010

Usage : This class is used by the trigger "AllNMCTrigger" to update the NMC Case with NMC Number , 
        convert the NMC Account Name to UPPERCASE and append the NMC Account Name to the NMC Account Number on Save and New actions.

Modifications: David Ragsdale - renamed 
    
CR # 25074
Dependencies : none

*********************************************************************/

public class NMCUtils{

/********************************************************************************************************************
Update the NMC Request Case with NMC Number

********************************************************************************************************************/    
    public static String retrieveCaseNMCRequest(map<String, Id> mapNMCAccount , list<NMC_Account__c> lstNMCAccount){
        system.debug('inside method');
        list<Id> lstAcctId = new list<id>();
        list<String> lstNMCAcctId = new list<String>();
        String errorMsg='';
        if(!(lstNMCAccount.isEmpty())){
            for(integer i=0;i<lstNMCAccount.size();i++)
            {
                lstAcctId.add(lstNMCAccount[i].Account__c);
                lstNMCAcctId.add(lstNMCAccount[i].NMC_Account__c);
            }
            list<case> lstCaseNMCRequest = [SELECT Id , NMC_Account__c  FROM Case WHERE 
                                        AccountId  in :lstAcctId 
                                        AND NMC_Account_Number__c  in :lstNMCAcctId 
                                        AND NMC_Account__c = null Limit 1000];
            if(!(lstCaseNMCRequest .isEmpty()))
            {
                for(integer i=0;i<lstCaseNMCRequest.size();i++)
                {
                    lstCaseNMCRequest[i].NMC_Account__c = mapNMCAccount.get(lstCaseNMCRequest[i].NMC_Account__c);
                }
                //try
                //{
                    update lstCaseNMCRequest;
                    
                //}
               // catch(Exception e)
                //{
                    //system.debug('Error:'+e);
                    //errorMsg = 'Caught DML exception while trying to relate NMC Request to updated NMC Account';
                //}
            }
        }
        return errorMsg;
    }
    
/***********************************************************************************************

***********************************************************************************************/    
    public static void trackCompletedNMCSetup(Map<Id,NMC_Account__c> newAcctNMCAcctMap)
    {
        NewCustomerImplementation.trackCompletedNMCSetup(newAcctNMCAcctMap);
    }

/******************************************************************************************************************************

Convert the NMC Account Name to UPPERCASE and append the NMC Account Name to the NMC Account Number on Save and New actions.
Created by Mark Silber - 073007

*******************************************************************************************************************************/   
    public static void changeNMCAccountToUpperCase(list<NMC_Account__c> lstNMCAcct)
    {
        for (NMC_Account__c NMCAcct: lstNMCAcct) {
                If (NMCAcct.NMC_Account_Name__c != NULL) {
                    NMCAcct.NMC_Account_Name__c = NMCAcct.NMC_Account_Name__c.ToUpperCase();
                    if (NMCAcct.NMC_Account__c != NULL) {
                        NMCAcct.name = NMCAcct.NMC_Account__c + ' - ' + NMCAcct.NMC_Account_Name__c;
                    }
                    else 
                    { 
                        NMCAcct.name = NMCAcct.NMC_Account__c;
                    }
                }
                        
            }

    }
  
}