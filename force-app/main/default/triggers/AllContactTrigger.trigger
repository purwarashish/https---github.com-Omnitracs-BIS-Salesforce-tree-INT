trigger AllContactTrigger on Contact ( before Insert,after Insert,before Update,after update)  {
 
 	system.debug('new contact values:'+trigger.new);
     BypassTriggerUtility u = new BypassTriggerUtility();  
     if (u.isTriggerBypassed())
     {
         return;
     }
    	system.debug('contact details:'+trigger.new);
     if(Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate))
     {
        Boolean isSingle;
        if (trigger.isInsert)
        {
            NewContactUtils.SetNotificationType(Trigger.new);
            //Determine if single insert or bulk
            isSingle=NewContactUtils.findDuplicate(Trigger.new);
            //NewContactUtils.populateAccountInviterOnInsert(Trigger.new);
        }
        if(Trigger.isUpdate)
        {
            isSingle=NewContactUtils.findDuplicate(Trigger.new,Trigger.oldmap);
			OmniSurveyTrackingUtils.createContactSurveyTrackingObj(Trigger.OldMap, Trigger.new);
            //NewContactUtils.populateAccountInviterOnUpdate(Trigger.oldmap, Trigger.new);
        }
                   
        if(isSingle && Trigger.new.size() == 1)
            Trigger.new[0].addError('Duplicate Email was found. Please give a unique Email address or leave the field blank');
        NewContactUtils.autoPopulateInvitorAccountandUser(Trigger.new,Trigger.oldmap);    
        NewContactUtils.updateNotification(Trigger.new);
        NewContactUtils.updateContactAlertForInactiveContacts(Trigger.new, Trigger.old, Trigger.oldmap);
        
    }
    
    if((Trigger.isAfter)&& (trigger.isInsert || trigger.isUpdate))
    {
        if(Trigger.isInsert)
        {
            NewContactUtils.PhoneAndFaxFormatCheck(Trigger.new);
            //NewContactUtils.AccandOppLeadSrcMostRecOnInsert(Trigger.new);
        }
        //if(Trigger.isUpdate)
        //{        
            NewContactUtils.AccandOppLeadSrcMostRecOnUpdate(Trigger.new, Trigger.oldmap);
        //}
        if(Trigger.size == 1 && !System.isFuture())
        {
            if (!NetsuiteSyncContactHelper.hasRun)
            {
                NewContactUtils.contactNetsuitesync(Trigger.new);
            }
        }
    }  
}