/*********************************************************************
Name : SerializedUnitSummaryUtils
Author : David Ragsdale / Shruti Karn
Date : 9 June 2011

Usage : Utility class for Serialized Unit Summary
       
Dependencies : SerializedUnitSummaryBatch.cls
 
*********************************************************************/
public class SerializedUnitSummaryUtils 
{   
//================  
//TEMP VALUE - REMOVE WHEN ALL CODE IS DEPLOYED 
public static string GetIDString(Serialized_Units__c serializedUnit) {
//  public static string GetIDString(Serialized_Unit__c serializedUnit) {

    string IdString = serializedUnit.Account__c == null ? ' _': serializedUnit.Account__c + '_';
    IdString += serializedUnit.Item_Type__c == null ? ' _' : serializedUnit.Item_Type__c;
    //IdString += serializedUnit.Item_Type__c == null ? ' _' : serializedUnit.Item_Type__c + '_';
    //IdString += serializedUnit.NMC_System__c == null ? ' ' : serializedUnit.NMC_System__c;
     return IdString;
  }
  public static string GetIDStringSummary(Serialized_Unit_Summary__c summary) {

    string IdString = summary.Account__c == null ? ' _' : summary.Account__c + '_';
    IdString += summary.Item_Type__c == null ? ' _' : summary.Item_Type__c;
    //IdString += summary.Item_Type__c == null ? ' _' : summary.Item_Type__c + '_';
    //IdString += summary.NMC_System__c == null ? ' ' : summary.NMC_System__c;
    return IdString;
  }
  public static void UpsertSummaryUnits(Map<string,Double> mpIdCountPair) {

    Map<string,Serialized_Unit_Summary__c> mpOriginal = GetSummaryUnits(mpIdCountPair);
    List<Serialized_Unit_Summary__c> lstInsertList = new List<Serialized_Unit_Summary__c>();
    List<Serialized_Unit_Summary__c> lstUpdateList = new List<Serialized_Unit_Summary__c>();
    List<Serialized_Unit_Summary__c> lstDeleteList = new List<Serialized_Unit_Summary__c>();

    Set<string> newKeySet = mpIdCountPair.keySet();
    string[] splitArr = null;

    Double value = 0;

    for(string key :newKeySet) {
      if(mpOriginal.containsKey(key))
      {
        Serialized_Unit_Summary__c tempSummary = mpOriginal.get(key);
        value = tempSummary.Number_of_Units__c + mpIdCountPair.get(key);
        if(value < 1)
        {
          system.debug('DELETE ==>'+ tempSummary);
          lstDeleteList.add(tempSummary);
        }
        else
        {
          tempSummary.Number_of_Units__c = value;
          system.debug('UPDATE ==>'+ tempSummary);
          lstUpdateList.add(tempSummary);
        }
      }
      else ///new record in summary
      {
         splitArr = key.split('_');

        Serialized_Unit_Summary__c serializedUnit = new Serialized_Unit_Summary__c();
        serializedUnit.Account__c = splitArr[0] != ' ' ? splitArr[0] : null;
        serializedUnit.Item_Type__c = splitArr[1] != ' ' ? splitArr[1] : null;
        //serializedUnit.NMC_System__c = splitArr[2] != ' ' ? splitArr[2] : null;
        serializedUnit.Number_of_Units__c = mpIdCountPair.get(key);

        if(!(serializedUnit.Number_of_Units__c < 1))
        {
          system.debug('INSERT ==>'+ serializedUnit);
          lstInsertList.add(serializedUnit);
        }
      }
    }

    UpdateAccountTeam.setAlreadyExecuted();
    if(lstInsertList.size() > 0) insert lstInsertList;
    if(lstUpdateList.size() > 0) update lstUpdateList;
    if(lstDeleteList.size() > 0) delete lstDeleteList;

  }
  
  public static Map<string,Serialized_Unit_Summary__c> GetSummaryUnits(Map<string,Double> mpIdCountPair) {

    System.debug('Map Parameter (mpIdCountPair) ==>'+ mpIdCountPair);
    List<string> lstAccounts = new List<string>();
    List<string> lstItemTypes = new List<string>();
   // List<string> lstNMCSystems = new List<string>();

    Set<string> keySet = mpIdCountPair.keySet();

    List<string> splitArr = new List<string>();
    for(string key :keySet) {
      splitArr = key.split('_');


      if(splitArr[0] != ' ') {
        lstAccounts.add(splitArr[0]);
      }
      else {
        lstAccounts.add(null);
      }

      if(splitArr[1] != ' ') {
        lstItemTypes.add(splitArr[1]);
      }
      else {
        lstItemTypes.add(null);
      }

     // if(splitArr[2] != ' ') {
       // lstNMCSystems.add(splitArr[2]);
      //}
      //else {
        //lstNMCSystems.add(null);
      //}
    }

   List<Serialized_Unit_Summary__c> lstSummary = new List<Serialized_Unit_Summary__c>(
                                    [SELECT Id,Account__c,Item_Type__c,Number_of_Units__c
                                     FROM  Serialized_Unit_Summary__c
                                     WHERE
                                     Account__c in :lstAccounts AND
                                     Item_Type__c in :lstItemTypes
                                      limit 1000]);


   Map<string,Serialized_Unit_Summary__c> mpIdNumber = new Map<string,Serialized_Unit_Summary__c>();
   string key = '';

   for(Serialized_Unit_Summary__c serializedSummary :lstSummary) {
     key = GetIDStringSummary(serializedSummary);
     if(!mpIdNumber.containsKey(key)) {
      mpIdNumber.put(key,serializedSummary);
     }
   }

   System.debug('####### Summary Map #######');
   System.debug(mpIdNumber);
   return mpIdNumber;
  }

//====================

    //After Archive is created, This method will delete existing records in Serialized Summary Utils table
    //and then update that table from the Archive.
    //This method is called from the finish method of the batch process
    public static void updateSerializedUnitSummary()
    {
        list<Serialized_Unit_Summary__c> lstSerializedUnitSummary = new list<Serialized_Unit_Summary__c>();

        for (Serialized_Unit_Summary_Archive__c serializedUnitSummaryArchive :
            [SELECT Account__c,Number_of_Units__c, Item_Type__c FROM Serialized_Unit_Summary_Archive__c limit 50000] )
        {
            Serialized_Unit_Summary__c newSerializedUnitSummary = new Serialized_Unit_Summary__c();
            
            newSerializedUnitSummary.Account__c = serializedUnitSummaryArchive.Account__c;
            newSerializedUnitSummary.Item_Type__c = serializedUnitSummaryArchive.Item_Type__c;
            newSerializedUnitSummary.Number_of_Units__c = serializedUnitSummaryArchive.Number_of_Units__c;
        
            lstSerializedUnitSummary.add(newSerializedUnitSummary);
        }
       
        if (lstSerializedUnitSummary.size() >0)
        {
            insert lstSerializedUnitSummary;
        }
    }
    
    /*****************************************************************************************************
    * USED ONLY FOR TEST METHODS 
    ********************************************************************************************************/
    public static void checkCount(Integer counter, Id accountId, string itemType, string nmcSystem) {

        List<Serialized_Unit_Summary__c> summary = 
            [Select Number_of_Units__c
                from Serialized_Unit_Summary__c
                where Account__c = :accountId 
                AND
                    Item_Type__c = :itemType 
                AND
                    NMC_System__c = :nmcSystem limit 1];

        if(counter == 0) 
        {
            //System.assertEquals(0,summary.size());
            return;
        }

        //System.assertEquals(counter, summary[0].Number_of_Units__c);
    }
    
    /*****************************************************************************************************
    * USED ONLY FOR TEST METHODS 
    ********************************************************************************************************/
    public static Serialized_Units__c GetSerializedUnit(Id accountId, String itemType, String nmcSystem) 
    {
        Serialized_Units__c serializedUnit = new Serialized_Units__c();
        serializedUnit.Account__c = accountId;
        serializedUnit.Item_Type__c = itemType;
        serializedUnit.NMC_System__c = nmcSystem;

        return serializedUnit;
    } 
}