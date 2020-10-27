global class UpdateAccountInSU {
/************************************************************
Modifications done:
1. Removed the recursive call for finding all the Serialized Units
as the governor limits are increased. 
2. Removed @future call as it was throwing Exception because of 
Serialized Unit's @future method.
**************************************************************/

 @future

public static void updateAccountInSU(Map<Id, id> mapNmcAccountsToAccountIds)
{

    List<Serialized_Units__c> updatedAccount = new List<Serialized_Units__c>();
    updatedAccount = [SELECT id, Account__c,NMC_Account__c,Auto_Number__c,FirstRecord__c,UpdateFromNMC__c FROM Serialized_Units__c WHERE  NMC_Account__c in :mapNmcAccountsToAccountIds.keySet() limit 10000];
    if(!(updatedAccount.isEmpty()))
    {
        for(integer i=0;i<updatedAccount.size();i++)
        {
              if(i==0)
                  updatedAccount[i].FirstRecord__c = true;
              ID parentAccount = mapNmcAccountsToAccountIds.get(updatedAccount[i].NMC_Account__c);
              updatedAccount[i].Account__c = parentAccount;
              updatedAccount[i].UpdateFromNMC__c = true;
              //updatedAccount.add(Units);
        }//End of for condition
    }

    if(!updatedAccount.isEmpty())
    {
            QESConstants.CALLED_FROM_NMC= true;
            QESConstants.SERIALIZEDUNIT_SIZE = updatedAccount.size();
system.debug('QESConstants.SERIALIZEDUNIT_SIZE:'+QESConstants.SERIALIZEDUNIT_SIZE+'updatedAccount.size():'+updatedAccount.size());
            update updatedAccount;
            
    }
     
    
}

  }