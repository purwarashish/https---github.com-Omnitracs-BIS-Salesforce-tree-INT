/*********************************************************************
Name : SerializedUnitUitls
Author : David Ragsdale 
Date : 15 June 2011

Usage : This class is used for updating the Serialized Unit First Message 
       
Dependencies : None

Notes:  Moved method from SerializedUnitSummaryUtils to this class for clarity

*********************************************************************/
public class SerializedUnitUtils 
{
    static set<Id> setSerializedUnit = new set<Id>();
    public static Boolean firstCall = true;
    /**********************************************************************
    This method is called to update all the Serialized Unit which have 
    UpdateFromNMC__c = true;
    ***********************************************************************/
    public static void updateSUfromNMCAccount(list<Serialized_Units__c> lstSerUnit)
    {
       firstCall = false;
       update lstSerUnit;
       
    }
  

    @future
    /*****************************************************************************************************
    Method to update the New Customer Implementation record having the same Serailized Unit and the Account 
    ********************************************************************************************************/
    public static void updateNewCustomerImplementationFirstMessage(set<ID> lstSerUnit)
    {
        
        list<Serialized_Units__c> sUnitRecords = new list<Serialized_Units__c>();
        Map<Id,Serialized_Units__c> newSerialedUnitMap = new Map<Id,Serialized_Units__c>();
        
        if(lstSerUnit != null && (!lstSerUnit.isEmpty()))
            sUnitRecords = [Select Last_Message_Date_Time__c,Account__c,Last_Position_Date_Time__c,UpdateFromNMC__c  from Serialized_Units__c where id in :lstSerUnit limit 10000];
            
        
        for (Integer i = 0; i < sUnitRecords.size(); i++) 
        {
            if((sUnitRecords[i].Last_Message_Date_Time__c != null && sUnitRecords[i].Last_Message_Date_Time__c.year() > 1971) || (sUnitRecords[i].Last_Position_Date_Time__c != null && sUnitRecords[i].Last_Position_Date_Time__c.year() > 1971 ))
                    newSerialedUnitMap.put(sUnitRecords[i].Account__c,sUnitRecords[i]);
           
        }
      
      if(newSerialedUnitMap.size() > 0)
        NewCustomerImplementation.trackFirstMessage(newSerialedUnitMap);
  
    }
}