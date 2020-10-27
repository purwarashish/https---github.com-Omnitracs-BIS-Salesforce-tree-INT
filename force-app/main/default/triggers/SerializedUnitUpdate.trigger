/*********************************************************************
Name : SerializedUnitUpdate
Author : Tom Scott
Date : 2 May 2008

Usage : This class is used for updating the Serialized Units account and first message fields
       
Dependencies : None

Updates:  Shruti Karn/David Ragsdale (9 June 2011)
 
 - Modified process used to update Serialized Unit Summary.  Removed most code, leaving only Account update and First Message Implementation
 - Moved Method to SerializedUnitUtils.cls
*********************************************************************/
trigger SerializedUnitUpdate on Serialized_Units__c (after insert,before update, after update, after delete,after undelete) 
{ 
    
    
    if(trigger.isBefore && trigger.isUpdate)
    {
        
        for(Serialized_Units__c serializedUnit : Trigger.New) 
        {
            
            if(serializedUnit.NMC_Account__c != null && serializedUnit.Account__c != serializedUnit.NMC_Account_Id__c)
            {
                serializedUnit.Account__c = serializedUnit.NMC_Account_Id__c;
            }
        }
    }

    if((trigger.isInsert || trigger.isUpdate) && trigger.isAfter)
    {
        set<ID> lstTest = new set<ID>();
        list<Serialized_Units__c> lstSerUnit = new list<Serialized_Units__c>();
                
         for(Serialized_Units__c serializedUnit : Trigger.New) 
         {
             if(serializedUnit.UpdateFromNMC__c == false)
                 lstTest.add(serializedUnit.Id);
         }

         if(lstTest.size()>0 && SerializedUnitUtils.firstCall)
         {
             
             if(trigger.isUpdate && Trigger.Old[0].FirstRecord__c == true)
             {
                 lstSerUnit = [Select id from Serialized_Units__c where UpdateFromNMC__c = true and nmc_account__c = : trigger.old[0].nmc_account__c limit 9999];
                 for(Serialized_Units__c serializedUnit : lstSerUnit)
                 {
                     lstTest.add(serializedUnit.Id);
                     serializedUnit.UpdateFromNMC__c = false;
                 }
            
              
             }

            SerializedUnitUtils.updateNewCustomerImplementationFirstMessage(lstTest);
            SerializedUnitUtils.updateSUfromNMCAccount(lstSerUnit);
         }
            
        
    }
}