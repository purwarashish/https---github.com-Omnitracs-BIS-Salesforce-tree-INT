public with sharing class PartnerActivityUtils {
	public static final String OPP_ID_PREFIX = '006';
    public static final String LEAD_ID_PREFIX = '00Q';
    public static final String CONTACT_ID_PREFIX = '003';
    
    public static void updatePartnerDrivenActivity(List<Task> newTaskList){
    	
    	
    	
    	Set<ID> userIDSet = new Set<ID>();
    	Set<ID> oppIDSet = new Set<ID>();
    	
    	Map<ID, DateTime> oppAndFuture = new Map<ID, DateTime>();
    	Map<ID, String> oppAndTaskComment = new Map<ID, String>();
    	Map<ID, DateTime> leadAndFuture = new Map<ID, DateTime>();
    	Map<ID, String> leadAndTaskComment = new Map<ID, String>();
    	
    	List<Opportunity> updateOpps = new List<Opportunity>();
    	List<Lead> updateLeads = new List<Lead>();
    	String idPrefix = '';
    	
    	
    	for(Task t : newTaskList){
    		//userIDSet.add(t.CreatedByID);	
    		system.debug('Task detected:');
    		if(Partner_Activity__c.getInstance((String)UserInfo.getUserID()).isPartner__c || Partner_Activity__c.getInstance((String)UserInfo.getProfileID()).isPartner__c){  			
    			system.debug('If User or ProfileID is in custom setting, add opp to set.');
    			//system.debug('ID Prefix is: ' + String.valueOf(t.whatId).substring(0,3));
    			if(t.WhatId != null){
    				idPrefix = String.valueOf(t.whatId).substring(0,3);
    			}
    			
    			if(t.WhoID != null && String.valueOf(t.whoID).substring(0,3) != CONTACT_ID_PREFIX){
    				idPrefix = String.valueOf(t.whoId).substring(0,3);
    			}
    			
    			if(t.WhatID != null){
    				system.debug('ID Prefixes are: ' + string.valueOf(t.WhatID));
    			}
    			
    			if(t.WhoID != null){
    				system.debug('ID Prefixes are: ' + string.valueOf(t.WhoId));
    			}
    			
    			if(idPrefix == OPP_ID_PREFIX){
    				system.debug('Opp Id Prefix matched.');
 					oppAndFuture.put(t.WhatID, t.ActivityDate);
 					if(t.Description != null){
 						oppAndTaskComment.put(t.WhatID, t.Description);
 					}
    			}
 				else if (idPrefix == LEAD_ID_PREFIX){
 					system.debug('Lead Id Prefix matched.');
 					leadAndFuture.put(t.WhatID, t.ActivityDate);
 					if(t.Description != null){
 						leadAndTaskComment.put(t.WhatID, t.Description);
 					}
 				}
 				else
 					continue;
    		}
    	}
    	
    	if(oppAndFuture.isEmpty() == false){			
	    	List<Opportunity> oppsToUpdate = [SELECT ID, Partner_Driven_Last_Activity__c, Partner_Driven_Future_Activity__c, Last_Task_Comment__c FROM Opportunity where ID in: oppAndFuture.keySet()];
	    	
	    	for(Opportunity o : oppsToUpdate){
	    		system.debug('Opportunity for loop accessed. Updating PDLA: ');
	    		//oppAndFuture map has a DateTime value component - thus isSameDay is being used from the 
	    		if(oppAndFuture.get(o.ID).date() >= Date.Today()){
		    		o.Partner_Driven_Last_Activity__c = DateTime.Now();
		    		o.Partner_Driven_Future_Activity__c = oppAndFuture.get(o.ID).Date().AddDays(1);
		    		if(oppAndTaskComment.get(o.ID) != null){
		    			o.Last_Task_Comment__c = oppAndTaskComment.get(o.ID);
		    		}
		    		updateOpps.add(o);
	    		}
	    		else{
	    			o.Partner_Driven_Last_Activity__c = DateTime.Now();
	    			if(oppAndTaskComment.get(o.ID) != null){
		    			o.Last_Task_Comment__c = oppAndTaskComment.get(o.ID);
		    		}
	    		    updateOpps.add(o);
	    			
	    		}
	    	}
	    		system.debug('oppToUpdate size: ' + oppsToUpdate.size());
	    		update updateOpps;
    	}
    	
    	if(leadAndFuture.isEmpty() == false){			
	    	List<Lead> leadsToUpdate = [SELECT ID, Partner_Driven_Last_Activity__c, Partner_Driven_Future_Activity__c, Last_Task_Comment__c FROM Lead where ID in: leadAndFuture.keySet()];
	    	
	    	for(Lead l : leadsToUpdate){
	    			system.debug('Opportunity for loop accessed. Updating PDLA: ');
	    		if(leadAndFuture.get(l.ID).date() >= Date.Today()){
		    		l.Partner_Driven_Last_Activity__c = DateTime.Now();
		    		l.Partner_Driven_Future_Activity__c = leadAndFuture.get(l.ID).Date().addDays(1);
		    		if(leadAndTaskComment.get(l.ID) != null){
		    			l.Last_Task_Comment__c = leadAndTaskComment.get(l.ID);
		    		}
		    		updateLeads.add(l);
	    		}
	    		else{
	    			l.Partner_Driven_Last_Activity__c = DateTime.Now();
	    			if(leadAndTaskComment.get(l.ID) != null){
		    			l.Last_Task_Comment__c = leadAndTaskComment.get(l.ID);
		    		}
	    		    updateLeads.add(l);
	    			
	    		}
	    		
	    	}
	    		system.debug('oppToUpdate size: ' + leadsToUpdate.size());
	    		update updateLeads;
    	}	
    }    
    
    public static void updatePartnerDrivenActivityEvent(List<Event> newEventList){
    	
    	
    	
    	Set<ID> userIDSet = new Set<ID>();
    	Set<ID> oppIDSet = new Set<ID>();
    	
    	Map<ID, DateTime> oppAndFuture = new Map<ID, DateTime>();
    	Map<ID, DateTime> leadAndFuture = new Map<ID, DateTime>();
    	
    	List<Opportunity> updateOpps = new List<Opportunity>();
    	List<Lead> updateLeads = new List<Lead>();
    	String idPrefix = '';
    	
    	
    	for(Event e : newEventList){
    		//userIDSet.add(t.CreatedByID);	
    		system.debug('Event detected:');
    		if(Partner_Activity__c.getInstance((String)UserInfo.getUserID()).isPartner__c || Partner_Activity__c.getInstance((String)UserInfo.getProfileID()).isPartner__c){  			
    			system.debug('If User or ProfileID is in custom setting, add opp to set.');
    			//system.debug('ID Prefix is: ' + String.valueOf(t.whatId).substring(0,3));
    			if(e.WhatId != null){
    				idPrefix = String.valueOf(e.whatId).substring(0,3);
    			}
    			
    			if(e.WhoID != null && String.valueOf(e.whoID).substring(0,3) != CONTACT_ID_PREFIX){
    				idPrefix = String.valueOf(e.whoId).substring(0,3);
    			}
    			
    			if(e.WhatID != null){
    				system.debug('ID Prefixes are: ' + string.valueOf(e.WhatID));
    			}
    			
    			if(e.WhoID != null){
    				system.debug('ID Prefixes are: ' + string.valueOf(e.WhoId));
    			}
    			
    			if(idPrefix == OPP_ID_PREFIX){
    				system.debug('Opp Id Prefix matched.');
 					oppAndFuture.put(e.WhatID, e.StartDateTime);
    			}
 				else if (idPrefix == LEAD_ID_PREFIX){
 					system.debug('Lead Id Prefix matched.');
 					leadAndFuture.put(e.WhatID, e.StartDateTime);
 				}
 				else
 					continue;
    		}
    	}
    	
    	if(oppAndFuture.isEmpty() == false){			
	    	List<Opportunity> oppsToUpdate = [SELECT ID, Partner_Driven_Last_Activity__c, Partner_Driven_Future_Activity__c FROM Opportunity where ID in: oppAndFuture.keySet()];
	    	
	    	for(Opportunity o : oppsToUpdate){
	    		system.debug('Opportunity for loop accessed. Updating PDLA: ');
	    		//oppAndFuture map has a DateTime value component - thus isSameDay is being used from the 
	    		if(oppAndFuture.get(o.ID).date() >= Date.Today()){
		    		o.Partner_Driven_Last_Activity__c = DateTime.Now();
		    		o.Partner_Driven_Future_Activity__c = oppAndFuture.get(o.ID).Date().AddDays(1);
		    		updateOpps.add(o);
	    		}
	    		else{
	    			o.Partner_Driven_Last_Activity__c = DateTime.Now();
	    		    updateOpps.add(o);
	    			
	    		}
	    	}
	    		system.debug('oppToUpdate size: ' + oppsToUpdate.size());
	    		update updateOpps;
    	}
    	
    	if(leadAndFuture.isEmpty() == false){			
	    	List<Lead> leadsToUpdate = [SELECT ID, Partner_Driven_Last_Activity__c, Partner_Driven_Future_Activity__c FROM Lead where ID in: leadAndFuture.keySet()];
	    	
	    	for(Lead l : leadsToUpdate){
	    			system.debug('Opportunity for loop accessed. Updating PDLA: ');
	    		if(leadAndFuture.get(l.ID).date() >= Date.Today()){
		    		l.Partner_Driven_Last_Activity__c = DateTime.Now();
		    		l.Partner_Driven_Future_Activity__c = leadAndFuture.get(l.ID).Date().addDays(1);
		    		updateLeads.add(l);
	    		}
	    		else{
	    			l.Partner_Driven_Last_Activity__c = DateTime.Now();
	    		    updateLeads.add(l);
	    			
	    		}
	    		
	    	}
	    		system.debug('oppToUpdate size: ' + leadsToUpdate.size());
	    		update updateLeads;
    	}	
    } 
    
}