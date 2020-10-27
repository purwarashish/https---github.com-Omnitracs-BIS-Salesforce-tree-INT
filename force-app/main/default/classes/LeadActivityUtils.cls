/***
Author: Jeff Nelson, Salesforce.com developer
EDL Consulting
Purpose: Utilities to help tag information associated with leads.
***/
public class LeadActivityUtils {
    
    public static final String STRING_ID = 'Id';
    public static final String STRING_WHOID = 'WhoId';
    public static final String STRING_PARENTID = 'ParentId';
    public static final String STRING_DESCRIPTION = 'Description';
    //public static final String STRING_IN_PROGRESS='In Progess';
    //public static final String STRING_NOT_STARTED='Not Started';
    public static final String STRING_IN_COMPLETED = 'Completed';
    public static final string STRING_STATUS='Status';
    public static final String STRING_DATE= 'ActivityDate';
    public static final String STRING_LEAD_PREFIX = '00Q';
    public static final String STRING_TASK_PREFIX = '00T';
    public static final String STRING_EVENT_PREFIX = '00U';
    public static final String STRING_ATTACHMENT_PREFIX = '00P';
    public static final String STRING_NOTE_PREFIX = '002';
    public static Map<Id, Lead> leadsToUpdate;  

    public static void updatePartnerDrivenActivity(List<SObject> sourceObjects) {
        if(sourceObjects == null || sourceObjects.size() == 0) return;
        
        // The determination of 'Partner' is in a hierarchical custom setting.
        //if(!Partner_Activity__c.getInstance().isPartner__c) return;
        
        leadsToUpdate = new Map<Id, Lead>();
        Set<Id> leadIdsToUpdatePDFA  = new Set<Id>();
        //if not partner
        if(!Partner_Activity__c.getInstance().isPartner__c)
        {
            for(SObject sourceObject : sourceObjects) {
                String sourceID = (String)sourceObject.get(STRING_ID);
                if(sourceID == null) continue;
            
                String sourcePrefix = sourceID.substring(0, 3);
                String potentialLeadID = null;
            
                potentialLeadID = getPotentialLeadId (sourceObject, sourcePrefix);
                if(
                potentialLeadID != null
                && STRING_LEAD_PREFIX.equals(potentialLeadID.substring(0, 3))
                ) {
                    if(STRING_TASK_PREFIX.equals(sourcePrefix))
                    {
                    leadsToUpdate.put(potentialLeadID,
                    new Lead(
                        ID = potentialLeadID                                                                 
                        // If the source was a Task, we want to update Last_Task_Comment__c with the Task Description
                        ,Last_Task_Comment__c = (String)sourceObject.get(STRING_DESCRIPTION)
                    )
                    );
                    }
                }
            }
        }
        //if partner
        else{
        for(SObject sourceObject : sourceObjects) {
            if(sourceObject == null) continue;
            
            String sourceID = (String)sourceObject.get(STRING_ID);
            if(sourceID == null) continue;
            
            String sourcePrefix = sourceID.substring(0, 3);
            String potentialLeadID = null;
            
            potentialLeadID = getPotentialLeadId (sourceObject, sourcePrefix);
            
            // Did we collect a Lead?
            if(
                potentialLeadID != null
                && STRING_LEAD_PREFIX.equals(potentialLeadID.substring(0, 3))
            ) {
                
                if(STRING_TASK_PREFIX.equals(sourcePrefix))
                {
                    leadsToUpdate.put(potentialLeadID,
                    new Lead(
                        ID = potentialLeadID
                        ,Partner_Driven_Last_Activity__c = DateTime.now()                                             
                        // If the source was a Task, we want to update Last_Task_Comment__c with the Task Description
                        ,Last_Task_Comment__c = (String)sourceObject.get(STRING_DESCRIPTION)
                    )
                    );
                }
                
                else
                {
                    leadsToUpdate.put(potentialLeadID,
                    new Lead(
                        ID = potentialLeadID
                        ,Partner_Driven_Last_Activity__c = DateTime.now() 
                    )
                    );
                }
                
                
                //Collect leads ids in a list, if task or event
                if(STRING_TASK_PREFIX.equals(sourcePrefix) || STRING_EVENT_PREFIX.equals(sourcePrefix))
                leadIdsToUpdatePDFA.add(potentialLeadID);
                
                if(!leadIdsToUpdatePDFA.isEmpty())
                updatePDFADate(leadIdsToUpdatePDFA);
            }
        }
        }
        List <Lead> updateList = new List <Lead>();
        updateList.addAll(leadsToUpdate.values());
        if(updateList.size() > 0) update updateList;
    }
    
    public static void updatePDFADate(Set<Id>leadIdsToUpdatePDFA)
    {       
        Map<Id, Date> mapOfLeadIdTofutureTaskDate = new Map<Id, Date>();
        Map<Id, Date> mapOfLeadIdTofutureEventDate = new Map<Id, Date>();
        
        for(Task t : [select id, ActivityDate, whoId, lastModifiedById from Task where whoId IN: leadIdsToUpdatePDFA and Status != :STRING_IN_COMPLETED order by ActivityDate desc ])
        {
            if(!mapOfLeadIdTofutureTaskDate.containsKey (t.whoId)
                &&  (Partner_Activity__c.getInstance(t.lastModifiedById).isPartner__c))
            {
                mapOfLeadIdTofutureTaskDate.put(t.whoId, t.ActivityDate );
            }
        }
System.debug('********** mapOfLeadIdTofutureTaskDate : ' + mapOfLeadIdTofutureTaskDate);
        
        for(Event e : [select id, ActivityDate, whoId, lastModifiedById from Event where whoId IN: leadIdsToUpdatePDFA order by ActivityDate desc ])
        {
            if(!mapOfLeadIdTofutureEventDate.containsKey (e.whoId)
                &&  (Partner_Activity__c.getInstance(e.lastModifiedById).isPartner__c))
            {
                mapOfLeadIdTofutureEventDate.put(e.whoId, e.ActivityDate );
            }
        }
System.debug('********** mapOfLeadIdTofutureEventDate : ' + mapOfLeadIdTofutureEventDate);  
    
        for(Id leadId : leadIdsToUpdatePDFA)
        {
            Date futureActivityDate = null;     
            Date futureTaskDate = null;
            Date futureEventDate = null;
            
            if(mapOfLeadIdTofutureTaskDate.containsKey(leadId))
            {
                futureTaskDate = mapOfLeadIdTofutureTaskDate.get(leadId);
            }
System.debug('********** futureTaskDate : ' + futureTaskDate);          
            if(mapOfLeadIdTofutureEventDate.containsKey(leadId))
            {
                futureEventDate = mapOfLeadIdTofutureEventDate.get(leadId);
            }
System.debug('********** futureEventDate : ' + futureEventDate);    
        
            if(futureTaskDate > futureEventDate || futureEventDate == null)
            futureActivityDate = futureTaskDate;
            else
            futureActivityDate = futureEventDate;
            
            if(futureActivityDate < System.today())         
            futureActivityDate = null;
            
System.debug('********** futureActivityDate : ' + futureActivityDate);                  
            
            if(leadsToUpdate.containsKey(leadId))
            {
                leadsToUpdate.get(leadId).Partner_Driven_Future_Activity__c = futureActivityDate;   
                
            }
        }    
                
    }
    
    public static String getPotentialLeadId (SObject sourceObject, String sourcePrefix)
    {
            String potentialLeadID = null;
            // Tasks and Events use 'WhoID'
            if(
                STRING_TASK_PREFIX.equals(sourcePrefix)
                || STRING_EVENT_PREFIX.equals(sourcePrefix)
            ) {
                potentialLeadID = (String)sourceObject.get(STRING_WHOID);
            }
            // EmailMessages and Attachements and Notes use 'ParentId'
            else if(
                STRING_ATTACHMENT_PREFIX.equals(sourcePrefix)
                || STRING_NOTE_PREFIX.equals(sourcePrefix)
            ) {
                potentialLeadID = (String)sourceObject.get(STRING_PARENTID);
            }
            
            return potentialLeadID;
    }

}