/*********************************************************************
Name : SerializedUnitSummaryBatch
Author : David Ragsdale / Shruti Karn
Date : 9 June 2011

Usage : This class is used for updating the Serialized Unit Summaries in a daily batch process
       
Dependencies : Schedule Apex Process (used to start batch)

*********************************************************************/
global class SerializedUnitSummaryBatch implements Database.Batchable<sObject> 
{
    public String query = 'SELECT Account__c, Item_Type__c, uniqueKey__c from Serialized_Units__c ';
    
    //Batch process used to gather Serialized Units       
    global database.querylocator start(Database.BatchableContext BC)
    {   
        list<Serialized_Unit_Summary__c> lstSerializedUnitSummary = new list<Serialized_Unit_Summary__c>();
        
        lstSerializedUnitSummary = [Select id from Serialized_Unit_Summary__c limit 50000];
        
        //Delete ALL Serialized Unit Summary Records in preparation of running batch to recalculate
        if(!(lstSerializedUnitSummary.isEmpty()))
        {
            delete lstSerializedUnitSummary;
        }        
                
        return Database.getQueryLocator(query); 
    }
  
    //Batch method used to process Serialized Unit records
    global void execute(Database.BatchableContext BC, List<Serialized_Units__c> scope)
    {           
        
        //Used to store Serialized Units
        map<String, list<Serialized_Units__c>> mapKeySerializedUnit = new map<String, list<Serialized_Units__c>>();
        
        //Used to store Serialized Unit Summaries
        map<String, Serialized_Unit_Summary_Archive__c> mapKeySerUnitSumm = new map<String, Serialized_Unit_Summary_Archive__c>();
        
        //List of Serialized Unit Summaries used to update table
        list<Serialized_Unit_Summary_Archive__c> lstSerialUnitSummary = new list<Serialized_Unit_Summary_Archive__c>();
                
        for(Serialized_Units__c SerializedUnit : scope)
        {             
            //Creates a map of Unique Accounts
            if(!(mapKeySerializedUnit.containsKey(SerializedUnit.uniqueKey__c)))
            { 
                mapKeySerializedUnit.put(SerializedUnit.uniqueKey__c , new list<Serialized_Units__c>{SerializedUnit});
            }else{
                mapKeySerializedUnit.get(SerializedUnit.uniqueKey__c).add(SerializedUnit);
            }
        }
 
        // Queries for all Serialized unit Summary record inserted in previous batches having same unique key 
        lstSerialUnitSummary = [Select uniqueKey__c, Number_of_Units__c from Serialized_Unit_Summary_Archive__c where uniqueKey__c in :mapKeySerializedUnit.keySet() limit 50000];
        
        //creates a map of Unique Key and Serialized Unit record
        if(!(lstSerialUnitSummary.isEmpty()))
        {
            for(Serialized_Unit_Summary_Archive__c SummObj : lstSerialUnitSummary)
            {
                mapKeySerUnitSumm.put(SummObj.uniqueKey__c , SummObj );       
            }
            
        }

               
        lstSerialUnitSummary.clear();  
        
        for(String uniqueKey : mapKeySerializedUnit.keySet())
        {
            //Check if the Serialized Unit Summary record exists,
            //i.e, Serialized Unit Summary record  was inserted in any of the previous batches and then update it.
            if(mapKeySerUnitSumm.containsKey(uniqueKey))
            {
                mapKeySerUnitSumm.get(uniqueKey).Number_of_Units__c += mapKeySerializedUnit.get(uniqueKey).size(); 
                lstSerialUnitSummary.add(mapKeySerUnitSumm.get(uniqueKey));
            }
            else
            {
                Serialized_Unit_Summary_Archive__c newSerializedUnitSummary = new Serialized_Unit_Summary_Archive__c();
                newSerializedUnitSummary.Number_of_Units__c = mapKeySerializedUnit.get(uniqueKey).size();
                newSerializedUnitSummary.Account__c = mapKeySerializedUnit.get(uniqueKey).get(0).Account__c;
                newSerializedUnitSummary.item_type__c = mapKeySerializedUnit.get(uniqueKey).get(0).item_type__c;
                
                if(mapKeySerializedUnit.get(uniqueKey).get(0).Account__c != null)
                {
                    lstSerialUnitSummary.add(newSerializedUnitSummary);
                }
            }
        }

        if (lstSerialUnitSummary.size() > 0)
        {        
            try{
                upsert lstSerialUnitSummary;
            }
            catch(Exception e)
            {
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
               String[] toAddresses = new String[] {'c_skarn@qualcomm.com'};
               mail.setToAddresses(toAddresses);
               mail.setSubject('Error in Batch Apex ');
               mail.setPlainTextBody ('Error in :'+ scope);
               Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            }
        }
    }
         
    global void finish(Database.BatchableContext BC)
    {
        SerializedUnitSummaryUtils.updateSerializedUnitSummary();
    }   
}