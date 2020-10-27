trigger AllLeadTrigger on Lead (before Insert,after Insert,before Update,after update) {
     
    BypassTriggerUtility u = new BypassTriggerUtility(); 
    
    if (u.isTriggerBypassed()) {
        return;
    } 
     
    if (trigger.isBefore)
    {
        if (trigger.isInsert || trigger.isUpdate)
        {
            AllLeadTriggerClass.assignRankingCargoType(Trigger.new, Trigger.oldMap);
            AllLeadTriggerClass.assignRankingCargoTypeIndustry(Trigger.new, Trigger.oldMap);//  Ranking - Cargo Type requires logic that cannot be placed in field update  
            AllLeadTriggerClass.updatOwnerInfoMethod(trigger.new,trigger.oldmap);
          //  AllLeadTriggerClass.updateReferralPartnerIdFromAccountToLead(Trigger.new,Trigger.oldMap);
            AllLeadTriggerClass.allLeadMethod(trigger.new,trigger.oldmap);
            AllLeadTriggerClass.ChangeLeadOwnerRole(trigger.new,trigger.oldmap);
            AllLeadTriggerClass.updateLeadMetaData(Trigger.new,Trigger.oldMap);
            //Added by Anand to populate the Company Lead Created By field
            AllLeadTriggerClass.populateCreatedByReseller(Trigger.New,Trigger.oldMap);
            //  Added by joseph hutchins 10/22/2014, this assigns values to the sic fields from the sic table if the sic code is present on th elead
            AllLeadTriggerClass.updateSicFields(Trigger.New);
            

        }       
    }

 if (trigger.isAfter)        
    {
        if (trigger.isInsert){
           if(system.label.TIS_Trigger_For_Lead_And_Opp == 'true'){
             AllLeadTriggerClass.CreateNewTIS(trigger.new);
           }     
        }
        if (trigger.isUpdate){
        
            if(system.label.TIS_Trigger_For_Lead_And_Opp == 'true'){
               AllLeadTriggerClass.UpdateTIS(trigger.new,trigger.oldMap);
            }
            
            AllLeadTriggerClass.mapFieldMethod(trigger.new);
                   
            if(SendEmailLead.isExecuted == false && LeadOwnerAssignmentController.isSendEmail ==true)
            {
               SendEmailLead.DMLLead(trigger.new);  //Modified to send email to lead owner(case #46059)
            }
            
            AllLeadTriggerClass.transferCompetativeKnowledge(trigger.new,trigger.newmap,trigger.oldmap);
        }
    }   
}