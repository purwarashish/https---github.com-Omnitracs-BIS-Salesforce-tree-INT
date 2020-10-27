/*******************************************************************************************************
Date: 12 October 2010

Author: Shruti Karn
Overview: This trigger updates the NMC Request Case with NMC Number and
          converts the NMC Account Name to UPPERCASE and append the NMC Account Name to the NMC Account Number 

Modifications: David Ragsdale - Renamed trigger

CR # 25074
*******************************************************************************************************/


trigger NMCInsertUpdate on NMC_Account__c (before update, before insert, after update , after insert) {
 /*
    if (Trigger.isInsert){
        if (Trigger.isBefore){
            //NMCUtils.changeNMCAccountToUpperCase(Trigger.new);
            /*for (NMC_Account__c NMCAcct: Trigger.new) {
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
        }*/
        //calls the function to update the NMC Request Case with NMC Number
      /*  if(Trigger.isAfter)
        {
            list<NMC_Account__c> lstNMCAccount = Trigger.New;
            Map<String,Id> mapNMCAccount = new Map<String,Id>();
            Map<Id,NMC_Account__c> newAcctNMCAcctMap = new Map<Id,NMC_Account__c>();
            for(integer i=0;i<Trigger.new.size();i++)
            {
                mapNMCAccount.put(Trigger.new[i].NMC_Account__c,Trigger.new[i].Id);
                newAcctNMCAcctMap.put(Trigger.new[i].Account__c,Trigger.new[i]);
            }
            String errorMsg = NMCUtils.retrieveCaseNMCRequest(mapNMCAccount , lstNMCAccount);
            //Trigger.new[0].addError(errorMsg);
            if (newAcctNMCAcctMap.size() > 0){
                NMCUtils.trackCompletedNMCSetup(newAcctNMCAcctMap);
            }
       }  
    }
    //Trigger "UpdateAccountinSU"
    if(Trigger.isUpdate)
    {
        if(Trigger.IsAfter)
        {
            Map<Id,id> NMCwithAccountupdated = new Map<Id,id>();
            for (Integer i = 0; i < Trigger.old.size(); i++) {
                NMC_Account__c old = Trigger.old[i];
                NMC_Account__c nw = Trigger.new[i];
                if(old.Account__c!= nw.Account__c) 
                {
                    NMCwithAccountupdated.put(Trigger.old[i].id, nw.Account__c);
                } 
            }
            //Calling the apex method for updation
            UpdateAccountInSU.ConstructorInSU(NMCwithAccountupdated); 
        }
        //for trigger "updateCaseNMCRequest"
        if(Trigger.IsBefore)
        {
            list<NMC_Account__c> lstNMCAccount = Trigger.New;
            Map<String,Id> mapNMCAccount = new Map<String,Id>();
            for(integer i=0;i<Trigger.new.size();i++)
            {
                mapNMCAccount.put(Trigger.new[i].NMC_Account__c,Trigger.new[i].Id);
            }
            String errorMsg = NMCUtils.retrieveCaseNMCRequest(mapNMCAccount , lstNMCAccount);            
            //if(errorMsg.trim() == '' || errorMsg.trim() == null)
                //Trigger.new[0].addError(errorMsg);
        }
    }
  */  
    
}