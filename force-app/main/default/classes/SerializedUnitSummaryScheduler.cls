/*********************************************************************
Name : SerializedUnitSummaryScheduler
Author : David Ragsdale 
Date : 9 June 2011

Usage : This class is used to delete the current Serialized Unit Summary records
    and for starting the batch process to update the Serialized Unit Summaries
       
Dependencies : Schedule Apex Process (used to start batch)

*********************************************************************/
global class SerializedUnitSummaryScheduler implements Schedulable 
{
 
    global void execute(SchedulableContext sc)
    {
        //Gather list of all SUS records
        //list<Serialized_Unit_Summary__c> lstSerUnitSumm = new list<Serialized_Unit_Summary__c>();
        list<Serialized_Unit_Summary_Archive__c> lstSerUnitSumm = new list<Serialized_Unit_Summary_Archive__c>();
        
        //lstSerUnitSumm = [Select id from Serialized_Unit_Summary__c limit 50000];
        lstSerUnitSumm = [Select id from Serialized_Unit_Summary_Archive__c limit 50000];
        
        //Delete ALL Serialized Unit Summary Records in preparation of running batch to recalculate
        if(!(lstSerUnitSumm.isEmpty()))
        {
            delete lstSerUnitSumm;
        }
        
        //Call SUS batch update process
        SerializedUnitSummaryBatch sb = new SerializedUnitSummaryBatch();
         
        database.executebatch(sb);  
        
    } 
}