/*@
    
*/
trigger CreateTISDetail on Opportunity (after insert,after update) {

     /*BypassTriggerUtility u = new BypassTriggerUtility();  
     if (u.isTriggerBypassed()) {
         return;
     }

    Map<String, opportunity> mapOfOpp = new Map<String, opportunity>();
    if(Trigger.isInsert && system.label.TIS_Trigger_For_Lead_And_Opp == 'true'){
        CreateTISLeadAndOpp.CreateNewTISRecord(Trigger.new, 'Opportunity', null);                
    } 
    if(Trigger.isUpdate && system.label.TIS_Trigger_For_Lead_And_Opp == 'true'){
        for(Opportunity opp:Trigger.new){
            if(opp.ownerId != trigger.oldmap.get(opp.id).ownerId){
                system.debug('@@@@Inside if::::' +opp.id);
                mapOfOpp.put(opp.id,opp);    
            }        
        }
        if(!mapOfOpp.isEmpty()&& CreateTISLeadAndOpp.isExecute == true){
            CreateTISLeadAndOpp.UpdateTISRecords(mapOfOpp, trigger.oldmap);
            CreateTISLeadAndOpp.isExecute=false;
        }
    }*/
    
}