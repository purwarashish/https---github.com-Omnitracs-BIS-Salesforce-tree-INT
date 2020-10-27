public with sharing class OpportunityActivityUtils {

    public static final String STRING_ID = 'Id';
    public static final String STRING_WHATID = 'WhatID';
    public static final String STRING_PARENTID = 'ParentId';
    public static final String STRING_DESCRIPTION = 'Description';
    public static final String STRING_MODIFIEDBYID = 'lastModifiedById';
    public static final String STRING_LASTMODDATE = 'lastModifiedDate';
    public static final String STRING_CREATEDDATE = 'createdDate';
    public static final String STRING_OPPORTUNITY_PREFIX = '006';
    public static final String STRING_TASK_PREFIX = '00T';
    public static final String STRING_EVENT_PREFIX = '00U';
    public static final String STRING_ATTACHMENT_PREFIX = '00P';
    public static final String STRING_IN_COMPLETED = 'Completed';
    public static final String STRING_NOTE_PREFIX = '002';
    public static Map<ID,Opportunity> opportunitiesToUpdate ;
    
    public static void updatePartnerDrivenActivity(List<SObject> sourceObjects) {
        if(sourceObjects == null || sourceObjects.size() == 0) return;
        
        // The determination of 'Partner' is in a hierarchical custom setting.
        //if(!Partner_Activity__c.getInstance().isPartner__c) return;
        
        List<SObject> listOfObjectsReltdToOpp = new  List<SObject>();
        Set<Id> setOfOppIds = new  Set<Id>();
        Set<Id> OppIdsToUpdatePDFA  = new Set<Id>();
        
            
        for(SObject sourceObject : sourceObjects) {
            if(sourceObject == null) continue;            
                     
            String sourceID = (String)sourceObject.get(STRING_ID);
            if(sourceID == null) continue;
            
            /*
            // Continue only if created by a partner
            if(!Partner_Activity__c.getInstance((String)sourceObject.get(STRING_MODIFIEDBYID)).isPartner__c)
            continue;*/
            
            String sourcePrefix = sourceID.substring(0, 3);
            String potentialOpportunityID = getOppId(sourceObject, sourcePrefix) ;
           
                       
            
            // Did we collect a Lead?
            if(
                potentialOpportunityID != null
                && STRING_OPPORTUNITY_PREFIX.equals(potentialOpportunityID.substring(0, 3)
               )
            ) {
               listOfObjectsReltdToOpp.add(sourceObject);
               setOfOppIds.add(potentialOpportunityID);
            }
        }
        //  this method was updating the oppts that came into here even if their Partner_Driven_Last_Activity__c was not being updated
        //  i have created another maps of oppts, that will be used to determine if the oppt needs to be updated
        Map<Id, Opportunity> opptsToCheck = new Map<Id, Opportunity>();
        opportunitiesToUpdate = new Map<Id, Opportunity>();
        if(setOfOppIds.size()>0)
        {
            opptsToCheck = new Map<Id,Opportunity>([select id, Last_Task_Comment__c, converted_opportunity__c, createdDate, Partner_Driven_Last_Activity__c from Opportunity where id IN: setOfOppIds]);
        }
        
        for(SObject sourceObject : listOfObjectsReltdToOpp)
        {
            
            String sourceID = (String)sourceObject.get(STRING_ID);
            String sourcePrefix = sourceID.substring(0, 3);
            String oppId = getOppId(sourceObject, sourcePrefix);
            
            
            if(opptsToCheck.containsKey(oppId))
            {
                System.debug('** enter');
                DateTime lastActivityDate;
                if(opptsToCheck.get(oppId).converted_opportunity__c && (System.now().addSeconds(-10) <= opptsToCheck.get(oppId).createdDate))
                 continue;
                else
                 lastActivityDate = (DateTime)sourceObject.get(STRING_LASTMODDATE);
                System.debug('** enter 2 : ' + lastActivityDate);
                System.debug('** enter 3 : ' + opptsToCheck.get(oppId).Partner_Driven_Last_Activity__c);
                
                if(lastActivityDate > opptsToCheck.get(oppId).Partner_Driven_Last_Activity__c)
                {
                    if(Partner_Activity__c.getInstance((String)sourceObject.get(STRING_MODIFIEDBYID)).isPartner__c)
                    {
                        opptsToCheck.get(oppId).Partner_Driven_Last_Activity__c = lastActivityDate;
                        opportunitiesToUpdate.put(oppId, opptsToCheck.get(oppId));
                    }   
                    
                }
                
                System.debug('** Last_Task_Comment__c : ' + opptsToCheck.get(oppId).Last_Task_Comment__c);
                System.debug('** STRING_TASK_PREFIX.equals(sourcePrefix) : ' + STRING_TASK_PREFIX.equals(sourcePrefix));
                    
                if(STRING_TASK_PREFIX.equals(sourcePrefix))
                    opptsToCheck.get(oppId).Last_Task_Comment__c = (String)sourceObject.get(STRING_DESCRIPTION);
                System.debug('** enter 4 : ' + opptsToCheck.get(oppId).Last_Task_Comment__c);
            }
            /*Changes to update PDFA*/
            
                //Collect Opp ids in a list, if task or event
                if(STRING_TASK_PREFIX.equals(sourcePrefix) || STRING_EVENT_PREFIX.equals(sourcePrefix))
                {
                    if(Partner_Activity__c.getInstance((String)sourceObject.get(STRING_MODIFIEDBYID)).isPartner__c)
                    {
                    OppIdsToUpdatePDFA.add(oppId);
                    }
                }
                
                System.debug('*********************** OppIdsToUpdatePDFA: ' + OppIdsToUpdatePDFA);
                if(!OppIdsToUpdatePDFA.isEmpty())
                updatePDFADate(OppIdsToUpdatePDFA);
            /*Changes to update PDFA End*/
        }
        
        if(opportunitiesToUpdate.size() > 0)
        {
            update opportunitiesToUpdate.values();
        }
    }
    
    public static String getOppId(SObject sourceObject, String sourcePrefix)
    {
           if(
                STRING_TASK_PREFIX.equals(sourcePrefix)
                || STRING_EVENT_PREFIX.equals(sourcePrefix)
            ) {
                return (String)sourceObject.get(STRING_WHATID);
            }
            // EmailMessages and Attachements and Notes use 'ParentId'
            else if(
                STRING_ATTACHMENT_PREFIX.equals(sourcePrefix)
                || STRING_NOTE_PREFIX.equals(sourcePrefix)
            ) {
                return (String)sourceObject.get(STRING_PARENTID);
            }
            else
            return null;
    }
    public static void updatePDFADate(Set<Id>OppIdsToUpdatePDFA)
    {       
        Map<Id, Date> mapOfOppIdTofutureTaskDate = new Map<Id, Date>();
        Map<Id, Date> mapOfOppIdTofutureEventDate = new Map<Id, Date>();
        
        for(Task t : [select id, ActivityDate, whatId, lastModifiedById from Task where whatId IN: OppIdsToUpdatePDFA and Status != :STRING_IN_COMPLETED order by ActivityDate desc ])
        {
            if(!mapOfOppIdTofutureTaskDate.containsKey (t.whatId)
                &&  (Partner_Activity__c.getInstance(t.lastModifiedById).isPartner__c))
            {
                mapOfOppIdTofutureTaskDate.put(t.whatId, t.ActivityDate );
            }
        }
System.debug('********** mapOfOppIdTofutureTaskDate : ' + mapOfOppIdTofutureTaskDate);
        
        for(Event e : [select id, ActivityDate, whatId, lastModifiedById from Event where whatId IN: OppIdsToUpdatePDFA order by ActivityDate desc ])
        {
            if(!mapOfOppIdTofutureEventDate.containsKey (e.whatId)
                &&  (Partner_Activity__c.getInstance(e.lastModifiedById).isPartner__c))
            {
                mapOfOppIdTofutureEventDate.put(e.whatId, e.ActivityDate );
            }
        }
System.debug('********** mapOfOppIdTofutureEventDate : ' + mapOfOppIdTofutureEventDate);  
    
        for(Id OppId : OppIdsToUpdatePDFA)
        {
            Date futureActivityDate = null;     
            Date futureTaskDate = null;
            Date futureEventDate = null;
            
            if(mapOfOppIdTofutureTaskDate.containsKey(OppId))
            {
                futureTaskDate = mapOfOppIdTofutureTaskDate.get(OppId);
            }
System.debug('********** futureTaskDate : ' + futureTaskDate);          
            if(mapOfOppIdTofutureEventDate.containsKey(OppId))
            {
                futureEventDate = mapOfOppIdTofutureEventDate.get(OppId);
            }
System.debug('********** futureEventDate : ' + futureEventDate);    
        
            if(futureTaskDate > futureEventDate || futureEventDate == null)
            futureActivityDate = futureTaskDate;
            else
            futureActivityDate = futureEventDate;
            
            if(futureActivityDate < System.today())         
            futureActivityDate = null;
            
System.debug('********** futureActivityDate : ' + futureActivityDate);                  
            
            if(opportunitiesToUpdate.containsKey(OppId))
            {
                opportunitiesToUpdate.get(OppId).Partner_Driven_Future_Activity__c = futureActivityDate;    
                
            }
        }    
                
    }
}