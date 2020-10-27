/*******************************************************************************
 * File:  CaseEventTrigger.Trigger
 * Date:  July 19th, 2010
 * Author:  Charlie Heaps
 * Sandbox: MIBOS
 * The use, disclosure, reproduction, modification, transfer, or transmittal of
 * this work for any purpose in any form or by any means without the written 
 * permission of United Parcel Service is strictly prohibited.
 *
 * Confidential, unpublished property of United Parcel Service.
 * Use and distribution limited solely to authorized personnel.
 *
 * Copyright 2009, UPS Logistics Technologies, Inc.  All rights reserved.
 *
 * Purpose: 
 *   Trigger fired on Case Event.
 *******************************************************************************/
trigger CaseEventTrigger on Case_Event__c (before insert, after insert, after update) 
{
     BypassTriggerUtility u = new BypassTriggerUtility();  
     if (u.isTriggerBypassed()) {
         return;
     }
    private boolean isSendingEmailsDisabled
    {
        get
        {
            Send_Trigger_Email_Alerts__c testObject = Send_Trigger_Email_Alerts__c.getInstance('Roadnet');
            if (testObject == null)
            {
                return true;
            }
            return testObject.isDisabled__c;
        }
    }
    
    Case_Event__c[] caseEvents=Trigger.New;
    
    if (!CaseEventExtension.isUserInternalAutomation())
    {
        if (Trigger.isBefore && Trigger.isInsert)
        {
            checkForProfServEventsAndSetPrivate(Trigger.new);
            
            for (integer i = 0; i < caseEvents.size(); i++)
            {
                if (!caseEvents[i].Created_By_VF_Page__c)
                {
                    //  the task trigger will set the case event's communication type to Email
                    //  the task was "Send An Email".  we don't want to assign the communication type
                    //  (as in the siutation where outlook creates the case and case event) unless
                    //  the comm type is blank
                    if (caseEvents[i].Communication_Type__c == null)
                    {
                        caseEvents[i].Communication_Type__c = 
                            [select origin from Case where id =: caseEvents[i].Case__c].origin;
                    }
                }
            }            
        }
        if (Trigger.isBefore && Trigger.isUpdate)
        {
            checkForProfServEventsAndSetPrivate(Trigger.new);
        }
        
        if (Trigger.isAfter && Trigger.isInsert)
        {
            if (!isSendingEmailsDisabled)
            {
                handleCaseSubscriberEmailAlerts();
            }
        }
        if (Trigger.isAfter && (Trigger.isinsert || Trigger.isUpdate))
        {
            //  to fix issue with email message trigger not creating case times for emails coming: 01802837 
            //  case times are now going to be created by the event after trigger
            //createCaseTimesForCaseEvents(Trigger.new);
            updateCaseWorkEffortFields(Trigger.new);
            
        }
    }
  
    private void updateCaseWorkEffortFields(LIst<Case_Event__c> triggerRecords)
    {
        Set<id> caseIds = new SEt<Id>();
        
        //  lets do it for all cases to make this easy, changes can be made after testing in the uat
        for (Case_Event__c ce : triggerRecords)
        {
            if (!caseIds.contains(ce.Case__c))
            {
              caseIds.add(ce.Case__c);
            }
        }
        
        List<Case> casesOfCaseEvents = [select id, work_effort_in_minutes__c, AssistingTech__c from case where id in: caseIds];
        List<Case> casesToUpdate = new List<Case>();// only want to update cases that had their field updated
        for (Case_Event__c ce : caseEvents)
        {
            Case caseOfCaseEvent = findCase(ce.case__c, casesOfCaseEvents);
            if (caseOfCaseEvent != null && !Util.ZeroOrNull(ce.Time_Spent__c))
            {
                caseOfCaseEvent.Work_Effort_in_minutes__c = ce.Time_spent__c;
                caseofCaseEvent.Last_Case_Event__c = ce.id;
                casesToUpdate.add(caseOFCaseEvent);
            }
        }
        
        update casesToUpdate;
    }  

    private static Case findCase(id caseId, List<CAse> casesToCheck)
    {
        for (Case c : casesToCheck)
        {
            if (c.id == caseId)
            {
                return c;
            }
        }
        return null;
    }
    /*private void createCaseTimesForCaseEvents(List<Case_Event__c> triggerRecords)
    {
        util.debug('in createCaseTimesForCaseEvents in case event trigger');
        //  i actually have to recreate the logic for this method as it existed beofre but not now,
        //  the idea here is to set a flag on the case that says "its case event update" menaing to NOT 
        //  we then create case times for the case event and any assistant techs of the case event
        //  first thing is to create case time for the case event itself
        //  need to requery the case events for the case recortype id/name
        List<Case_Event__c> requriedCaseEvents = [select id, subject__c, case__c, time_spent__c, Assisting_Technician__c, case__r.recordtypeid, case__r.recordtype.name from Case_Event__c where id in: triggerRecords];
        
        List<Mibos_Case_Time__c> caseTimesToCreate = new List<Mibos_Case_Time__c>();
        for (Case_Event__c ce : requriedCaseEvents)
        {
            //  we used to only exclude email generated cases for case event creatio but now we will include them if
            //  the user of the case is a call center or omnitracs support profile
            if (ce.Subject__c != null && 
                !ce.Subject__c.contains('has been closed') && 
                ce.Case__c != null && 
                CaseClassHelperClass.isCaseSupport(ce.Case__r.RecordTypeId))
            {
                Mibos_Case_Time__c caseTimeForEvent = new Mibos_Case_Time__c();
                caseTimeForEvent.Case__c = ce.Case__c;
                caseTimeForEvent.Case_Event__c = ce.id;
                caseTimeForEvent.Owner__c = userInfo.getUserId();
                caseTimeForEvent.Work_Effort__c = ce.Time_Spent__c;
                caseTimesToCreate.add(caseTimeForEvent);
                
                if (ce.Assisting_Technician__c != null)
                {
                    //  that way all we have to do is cursor thru the ids and assign a different one to the owner field
                    Mibos_Case_Time__c assistantTechCaseTime = new Mibos_Case_Time__c();
                    assistantTechCaseTime.Case__c = ce.case__c;
                    assistantTechCaseTime.Owner__c = ce.Assisting_Technician__c;
                    assistantTechCaseTime.is_Assistant_Tech__c = true;
                    assistantTechCaseTime.Work_Effort__c = ce.time_spent__c;
                    caseTimesToCreate.add(assistantTechCaseTime);
                }
            }
        }
        util.debug(' caseTimesToCreate = ' + (caseTimesToCreate == null ? 0 : caseTimesToCreate.size()));
        insert caseTimesToCreate;
        
    }*/

    
    private void checkForProfServEventsAndSetPrivate(List<Case_Event__c> theEvents)
    {
        for (integer i = 0; i < theEvents.size(); i++)
        {
            //  if case event belongs to profesaionsl service case, turn the isprivate flag to true
            if (theEvents[i].Case_Recordtype_Name__c == 'Professional Services')
            {
                theEvents[i].Display_in_Customer_Portal__c = false;
            }
        }
    }
    
    private void handleCaseSubscriberEmailAlerts()
    {
        //  this sends email alert to users in the case.email_alert_support field and the case's account.email_alert_support and the account owner
        //  if the case.account.email_alert_all_cases is set
        List<Case_Event__c> roadnetCallCenterCaseEventsBeingCreated = new List<Case_Event__c>();
        
        for (integer i = 0; i < Trigger.new.size(); i++)
        {
            if (Trigger.new[i].Business_unit__c == 'Roadnet' && isCaseSupport(Trigger.new[i].Case_Recordtype_Name__c))
            {
               //  case is being closed, we are sending emails for that case
               roadnetCallCenterCaseEventsBeingCreated.Add(Trigger.new[i]);
            }
        }
        
        if (roadnetCallCenterCaseEventsBeingCreated.size() > 0)
        {
            CaseEventExtension.emailAlertSuppportCaseEventCreation(roadnetCallCenterCaseEventsBeingCreated);
        }
    }
    
    private boolean isCaseSupport(string recordTypeName)
    {
        //  we so far have 4 different suppprt recordtypes, support, rescue pin support, call center, and engineering case
        return recordTypeName == ('Call Center') || 
           recordTypeName == ('Rescue Pin Support') || 
           recordTypeName == ('Support') ||
           recordTypeName == ('Engineering Case');
           
    }

    public class myException extends Exception{}
}