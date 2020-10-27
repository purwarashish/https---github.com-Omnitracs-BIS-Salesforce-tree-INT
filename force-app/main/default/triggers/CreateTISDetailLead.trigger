trigger CreateTISDetailLead on Lead (after insert,after update) {

   /*  BypassTriggerUtility u = new BypassTriggerUtility();  
     if (u.isTriggerBypassed()) {
         return;
     }

    Map<String, Lead> mapOfLead = new Map<String, Lead>();
    if(Trigger.isInsert && system.label.TIS_Trigger_For_Lead_And_Opp == 'true'){
        CreateTISLeadAndOpp.CreateNewTISRecord(null, 'Lead',Trigger.new);                
    } 
    if(Trigger.isUpdate && system.label.TIS_Trigger_For_Lead_And_Opp == 'true'){
        for(Lead l:Trigger.new){
            if(l.ownerId != trigger.oldmap.get(l.id).ownerId){
                mapOfLead.put(l.id,l);    
            }        
        }
        system.debug('CreateTISLeadAndOpp.UpdateOppCounter'+CreateTISLeadAndOpp.isExecute);
        if(!mapOfLead.isEmpty()&& CreateTISLeadAndOpp.isExecute == true){
            CreateTISLeadAndOpp.UpdateTISRecordsLead(mapOfLead, trigger.oldmap);
            CreateTISLeadAndOpp.isExecute=false;
        }
    }
    */
}