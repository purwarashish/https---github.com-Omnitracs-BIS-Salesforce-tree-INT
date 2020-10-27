/**
  *@Description:This trigger is fired whenever a Note(Attachment)gets inserted.
  *Every time a lead gets re-assigned a note gets inserted stating the 
  *reason for re-assignment. This gets populated in note's body. This trigger updates
  *'Body from Notes' field on Lead, with the information stored in body of the note
  *@Author:Amrita Ganguly
  *@Date: 07/11/2012
**/
trigger PopulateNoteBodyOnLead on Note (after insert) 
{
    Set<Id> leadIds = new Set<id>();
    Map<String,Note> mapOfLeadIdNNote = new Map<String,Note>();
    List<Lead> lstLeadToUpdt = new List<Lead>();
    //need to add a condition so that we collect notes that have Title equals to Lead re-assignment
    for (Note nt: Trigger.new){
        if(nt.title==system.Label.Lead_Title_Name){
            leadIds.add(nt.parentId);
            mapOfLeadIdNNote.put(nt.parentId,nt);
        }
    }
    Map<String,Lead> mapOfLeadIdNLead = new Map<String,Lead>([Select Body_from_Notes__c from Lead Where Id in :leadIds]); 
    for(String mapKey:mapOfLeadIdNLead.keySet())
    {
        if(mapOfLeadIdNNote.containsKey(mapKey)){
            mapOfLeadIdNLead.get(mapKey).Body_from_Notes__c = mapOfLeadIdNNote.get(mapKey).body;
            lstLeadToUpdt.add(mapOfLeadIdNLead.get(mapKey));
            system.debug('@@@@lstLeadToUpdt'+lstLeadToUpdt);    
        }    
    }
    update lstLeadToUpdt;     
}