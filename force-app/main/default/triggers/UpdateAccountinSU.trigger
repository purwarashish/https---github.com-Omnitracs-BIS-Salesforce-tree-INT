trigger UpdateAccountinSU on NMC_Account__c (after update) {
    Map<Id,id> NMCwithAccountupdated = new Map<Id,id>();
    //List<NMC_Account__c> lstNMC = new List<NMC_Account__c>();
    // Trigger.new is a list of the Accounts that will be updated
    // This loop iterates over the list, and adds any that have new
    
    //Id AccOld, AccNew; 
   for (Integer i = 0; i < Trigger.old.size(); i++) 
    {
        NMC_Account__c old = Trigger.old[i];
        NMC_Account__c nw = Trigger.new[i];
          if(old.Account__c!= nw.Account__c) 
          {
              NMCwithAccountupdated.put(Trigger.old[i].id, nw.Account__c);
          }         
    }
    //Calling the apex method for updation
    if(NMCwithAccountupdated.size()>0)
       UpdateAccountInSU.updateAccountInSU(NMCwithAccountupdated); 
  }