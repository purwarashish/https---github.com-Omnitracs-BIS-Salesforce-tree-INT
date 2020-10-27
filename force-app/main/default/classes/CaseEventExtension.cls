/////////////////////////////////////////    MIBOS EXTENSION BELOW  ///////////////////////////////////////
/*******************************************************************************
 * File:  CaseEventExtension.cls
 * Date:  October 14th, 2009
 * Author:  Joseph Hutchins
 * Sandbox:  Mibos
 * The use, disclosure, reproduction, modification, transfer, or transmittal of
 * this work for any purpose in any form or by any means without the written 
 * permission of United Parcel Service is strictly prohibited.
 *
 * Confidential, unpublished property of United Parcel Service.
 * Use and distribution limited solely to authorized personnel.
 *
 * Copyright 2009, UPS Logistics Technologies, Inc.  All rights reserved.
 *  ******************************************************************************/
public class CaseEventExtension 
{
    //  used for throwing custom exceptions
    public class myException extends Exception{}
    
    //  **********  Member Variables  **********
    public Case_Event__c caseEvent = new Case_Event__c();
    private Case theCase = new Case();
    private id theCaseId = null;
    private id caseEventId = null;
    public Boolean isVFPageInNewMode = false;
    public Boolean isVFPageInEditMode = false;
    public Boolean isVFPageInCloneMode = false;
    private Map<string, string> urlParameterMap = new Map<string, string>();
    public string returnURL;
    private Case originalCase;
    public String BuValue {get;set;}

    public Boolean IsCaL1 {get;set;}
    public string contactExtension
    {
        get
        {
            //  currently in the mibos system, they have an extension field at the contact but not at the case or or case event
            //  so the only thing this is able to do is display the contact's extension but no changes/savign can be done
            //  for the field
            if (theCase.ContactId != null)
            {
                if (!isBlank(theCase.Contact.Extension__c))
                {
                    return theCase.Contact.Extension__c;
                }
             /* if (!isBlank(theCase.Contact.Extension1__c))
                {
                    return theCase.Contact.Extension1__c;
                }*/
                return null;
            }
            return null;
        }
        set;
    }
    
    private final string MIBOS_CASE_FIELD_ID = 'CF' + SystemIds__c.getInstance().FieldId_CaseEvent_Case__c + '_lkid';
    //  **********  Constructor(s)  ***********
    public CaseEventExtension(apexpages.standardcontroller stdcontroller)
    {
        
        ApexPages.currentPage().getHeaders().put('X-UA-Compatible', 'IE=10');
        PageReference mypageref = apexpages.currentpage();
        urlParameterMap = mypageref.getparameters();
        
        assignCaseEventModeBoolens();//  determines if the case is new, edit, or clone mode
        
        //  we'll add additional logic if the user is a portal user, first question becomes,
        //  how do we identify the user is portal user?  we query the user record in this constructor
        //  and then verify there.  if the user is a portal user then we;ll deafult the communicatino method
        //  to customer portal (make it readonly) and set the hidden boolean flag to true
        //  as or right now we will not allow the editing of a case event
        //  found better way to set detemine if logged in user is poratl user, query their contact record for the contactid
        //  field, if it contains value,they are a portal user
        //string profileName = [select name from Profile where id =: userInfo.getProfileId()].name;
        isPortalUser = loggedInUser.ContactId != null;
        
        if (isVFPageInNewMode)
        {
           initIfCaseEventIsInNewMode();
        }
        else if (isVFPageInEditMode)
        {
            system.assertNotEquals(null, caseEventId);
            caseEvent = queryCaseEvent(caseEventId);
            system.assertNotEquals(null, caseEvent);
            
            initIfCaseEventIsInEditMode();
        }
        else if (isVFPageInCloneMode)
        {
            throw new myException('Clone functionaility not created yet');
        }
        
        
    }
    
    //  **********  Setters and Getters  **********
    public boolean showAccountField{get;set;}

    public boolean isCaseRecordTypeSupport
    {
        get
        {
            //  rn instance has 'Support' recordtype and mibos has the call ceneter, we need to check that the recordtype is either of those
            if (theCase == null || theCase.RecordTypeid == null)
            {
                return false;
            }
            else
            {
                return theCase.RecordType.Name == 'Support' ||
                    theCase.RecordType.Name == 'Call Center' ||
                    theCase.RecordType.Name == 'Engineering Case' ||
                    theCase.RecordType.Name == 'Professional Services' ||
                    thecase.Recordtype.name == 'Admin';
                     //  sylectus and other business units will have to input the level 1/level 2 fields;
            }
            
        }
    }
    
    public boolean showWorkEffortField
    {
        get
        {
            return !isPortalUser &&
                (isCaseRecordTypeSupport || theCase.Recordtype.name == 'Professional Services' || isEmailGenCaseCallCenterProfile);
        }
    }
    private boolean isEmailGenCaseCallCenterProfile
    {
        get
        {
            return CaseClassHelperClass.isCaseSupport(theCase.RecordType.Id);
            /*
           return theCase != null &&
               theCase.RecordType.name == 'Email Generated Cases' &&
               loggedInUser != null && 
               loggedInUser.Profileid != null &&
               loggedInUser.Profile.name != null &&
               (loggedInUser.Profile.Name == 'Call Center Manager' || loggedINUser.Profile.Name == 'Call Center User');
               */
        }
    }
    private User loggedInUser
    {
        get
        {
            if (loggedInuser == null)
            {
                loggedInUser = [select id, profileid, profile.name, contactid from User where id =: userINfo.getUserid()];
            }
            
            return loggediNuser;
            
        }
        set;
    }
    public Case_Event__c getcaseEvent(){return caseEvent;}
    public void setcaseEvent(Case_Event__c b){caseEvent = b;}
    public boolean getIsVfPageInEditMode(){return isVFPageInEditMode;}

    public string mibosCaseFieldId
    {
        get
        {
            util.debug('inside of mibosCaseFieldId');
            return urlParameterMap.get(MIBOS_CASE_FIELD_ID);
        }
    }
    private string orig_userChoiceAssistingTech{get; set;}
    public boolean isCaseReasonRequired
    {
        get
        {
            return isTimeSpentRequired && caseReasonPicklist.options.size() > 1;
        }
    }
    public boolean isSubReasonRequired
    {
        get
        {
            return isTimeSpentRequired && subReasonPicklist.options.size() > 1;
        }
    }
    public boolean isOldCaseReason{get;set;}

    public PL caseReasonPicklist
    {
        get 
        {
            if (caseReasonPicklist == null)
            {
                caseReasonPicklist = new PL();
            }
            return caseReasonPicklist;
        }
        set;
    
    }
    public PL subReasonPicklist
    {
        get 
        {
            if (subReasonPicklist == null)
            {
                subReasonPicklist = new PL();
            }
            return subReasonPicklist;
        }
        set;
    
    }
    public string userChoiceStatusField
    {
        get
        {
            if (userChoiceStatusField == PL.NONE)
            {
                return null;
            }
            else
            {
                return userChoiceStatusField;
            }
        }
        set;
    }
    /*
    public List<SelectOption> statusPicklist
    {
        get
        {
            return statusPicklist(false);
        }
    }
    */
    public integer caseEventMinutes
    {
        get
        {
            if (caseEvent.Start_Time__c == null || caseEvent.End_Time__c == null)
            {
               return 0;
            }
            else
            {
                integer minutes = integer.valueOf(timeBetweenInMinutes(caseEvent.Start_Time__c, caseEvent.End_Time__c)); 
                if (minutes < 1)
                {
                    return 1;
                }
                else
                {
                    return minutes;
                }
            }
        }
    }
    public string isVisibleInSelfServiceFieldLabel
    {
        get
        {
            return 'Contact Receives Case Emails';
        }
    }
    public string userChoiceContactField
    {
        get
        {
            if (userChoiceContactField == PL.NONE)
            {
                return null;
            }
            else
            {
                return userChoiceContactField;
            }
        }
        set;
    }
    public List<SelectOption> contactsOfCase
    {
        get
        {
            util.debug('inside of contactsOFCase method...');
            List<SelectOption> options;
            
            options = defineContactList(theCase.accountId, theCase.ContactId, false);
            
            return options;
        }
    }
    public boolean isTimeSpentRequired
    {
        get
        {
            //  domestic support case creaetd by internal user
            return !isPortalUser &&
                (isCaseRecordTypeSupport || isEmailGenCaseCallCenterProfile); 
        }
    }
    
    public boolean isPortalUser
    {
        get; private set;
    }
    public string contactName
    {
        get
        {
            if (theCase == null)
            {
                return null;
            }
            else
            {
                return theCase.Contact.Name;
            }
        }
    }
    public Id contactId
    {
        get
        {
            if (theCase == null)
            {
                return null;
            }
            else
            {
                return theCase.ContactId;
            }
        }
    }
    public Case gettheCase()
    {
        return thecase;
    }
    public string contactEmail{get;set;}
    public string contactPhone{get;set;}
    
    public List<SelectOption> assistingTechs
    {
        get
        {
            return assistingTechs;
        }
    
    }
    public List<SelectOption> leftUserList
    {
        get
        {
            if (leftUserList == null)
            {
                leftUserList = new List<selectoption>();
            }
            return leftUserList;
        }
        set;
    }
    public List<selectoption> rightuserList
    {
        get
        {
            if (rightuserList == null)
            {
                rightuserList = new List<selectoption>();
            }
            return rightuserList;
        }
        set;
    }
    public List<string> usersToRemove
    {
        get
        {
            if (usersToRemove == null)
            {
                usersToRemove = new List<string>();
            }
            return usersToRemove;
        }
        set;
    }
    
    public List<string> usersToAdd
    {
        get
        {
            if (usersToAdd == null)
            {
                usersToAdd = new List<string>();
            }
            return usersToAdd;
        }
        set;
    }
    
    //  **********  Public Instance Functions  ***********
    public PageReference contactPicklistOnChange()
    {
        assignContactFields();
        return null;
    }

    public PageReference save()
    {
        caseEvent.Contact__c = userChoiceContactField;
        theCase.ContactId = userChoiceContactField;
        
        //  this should always default be false even if the user set it on the case event
        if (caseEvent.Case__c != null && caseEvent.Case__r.RecordType.name == 'Professional Services')
        {
            caseEvent.Send_email_notification_to_contact__c =  caseEvent.Display_in_Customer_Portal__c = false;
        }
        else
        {
            caseEvent.Display_In_Customer_Portal__c = caseEvent.Send_email_notification_to_contact__c;
        }
    
        //  ok whats the logic here.  firstly, its for support cases only so that isTimeSpentRequired is needed
        //  now, there is a little something that is supposed to happen up above... let me fix that first... ok its fixed
        //  so now we get down to here.  there are several fields on the page that belong to the case, contactid, status, case reason, sub erason, product
        //  if any of them have changed, assign the various picklist.seleciton fields to the case fields and update the case
        if (isTimeSpentRequired)
        {
            assignPicklistValues();
        }
        
        //caseEvent.Assisting_Technician__c = userChoiceAssistingTech;
        
        //assignAssistantTechs();
        
        //  if the page is in new mode, we insert a new record
        if (checkRequriedFieldsForSave())
        {
            if (isVFPageInNewMode)
            {
                system.assert(caseEvent.Created_By_VF_Page__c);
                return insertCaseEvent();
            }
            else if (isVFPageInEditMode) //  the page is edit mode, just update the record.
            {
                return updateCaseEvent();
            }
        }
        
        return null;
    }
    public PageReference saveAndNew()
    {
        system.assertNotEquals(null, caseEvent);
        system.assertNotEquals(null, theCaseId);
        
        caseEvent.Contact__c = userChoiceContactField;
        theCase.ContactId = userChoiceContactField;
        
        //  this should always default be false even if the user set it on the case event
        if (caseEvent.Case__c != null && caseEvent.Case__r.RecordType.name == 'Professional Services')
        {
            caseEvent.Send_email_notification_to_contact__c  = caseEvent.Display_in_Customer_Portal__c = false;
        }
        else
        {
            caseEvent.Display_In_Customer_Portal__c = caseEvent.Send_email_notification_to_contact__c;
        }
        
        if (isTimeSpentRequired)
        {
            assignPicklistValues();
        }
        
        boolean didUpdateOrInsertCompleteSuccessfully = false;
        
        //assignAssistantTechs();
        
        if (checkRequriedFieldsForSave())
        {
            if (caseEvent.Start_Time__c != null && caseEvent.End_Time__c != null)
            {
                caseEvent.Time_Spent__c = 
                   round5Minutes(
                   Integer.valueof(timeBetweenInMinutes(caseEvent.Start_Time__c, caseEvent.End_Time__c)));
            }
            if (isVFPageInNewMode)
            {
                system.assertNotEquals(null, caseEvent);//  make sure caseevent is not null
                system.assertEquals(null, caseEvent.id);//  case event id should be null, since this is an insertion
                
                try
                {
                    database.saveResult sr = database.insert(caseEvent);
                    if (sr.isSuccess())
                    {
                        didUpdateOrInsertCompleteSuccessfully = true;
                        
                        //createCaseTimesForCaseEvent(caseEvent,theCase);      
                        //  we'll need to update the cases status and subject field if the user has changed them
                        if (didCaseFieldsChange)
                        {
                            theCase.isCaseEventUpdate__c = true;
                            //  the line up above i believe is what was used to prevent the csae trigger from creating case times for case event updates...  we could go hard
                            //  and 
                            update theCase;
                        }
                    }   
                    else
                    {
                        
                        caseEvent.addError('Failed to save record. Please check source code');
                        didUpdateOrInsertCompleteSuccessfully = false;
                    }
                }   
                catch(Exception e)
                {
                    
                    caseEvent.addError('failed to save the record due to ' + e.getMessage());
                    didUpdateOrInsertCompleteSuccessfully = false;//  if exception is thrown, then the update didn't happen   
                }
                if (!didUpdateOrInsertCompleteSuccessfully)
                {
                    return null;//  return null, the failures above will have recorded an addError msg
                }
            }
            else if (isVFPageInEditMode)
            {
                {
                    try
                    {
                        update caseEvent;
                        didUpdateOrInsertCompleteSuccessfully = true;
                        //createCaseTimesForCaseEvent(caseEvent, theCase);
                        //  we'll need to update the cases status and subject field if the user has changed them
                        if (didCaseFieldsChange)
                        {
                            theCase.isCaseEventUpdate__c = true;
                            update theCase;
                        }
                    }   
                    catch(Exception e)
                    {
                        caseEvent.addError('Failed to update the record due to ' + e.getMessage());
                        didUpdateOrInsertCompleteSuccessfully = false;
                        return null;
                    }
                }
            }
            if (didUpdateOrInsertCompleteSuccessfully)
            {
                
                //  if the case event saved successfully then we can construct our page reference and return it
                PageReference pr = new PageReference('/apex/CaseEventPage?retURL=' + returnURL + '&' + MIBOS_CASE_FIELD_ID + '=' + theCaseId);
                pr.setRedirect(true);
                return pr;
            }
        }
        return null;
        
    }
    public PageReference saveAndClose()
    {
        system.assertNotEquals(null, theCase);//  cant close a case if its not specified
        system.assertNotEquals(null, theCase.Id);//  this assertion is not really needed, i think a calling funciton needs it but w/e
        
        //  this should always default be false even if the user set it on the case event
        if (caseEvent.Case__c != null && caseEvent.Case__r.RecordType.name == 'Professional Services')
        {
            caseEvent.Send_email_notification_to_contact__c  = caseEvent.Display_in_Customer_Portal__c = false;
        }
        else
        {
            caseEvent.Display_In_Customer_Portal__c = caseEvent.Send_email_notification_to_contact__c;
        }
        if (isTimeSpentRequired)
        {
            assignPicklistValues();
        }
        theCase.Status = 'Closed';
        caseEvent.Contact__c = userChoiceContactField;
        theCase.ContactId = userChoiceContactField;
        //caseEvent.Assisting_Technician__c = userChoiceAssistingTech;
                
        
        //assignAssistantTechs();
        
        if (checkRequriedFieldsForSave())//  is the required fields filled in?
        {
            if (isVFPageInNewMode)
            {
                //  the insert case event returns null if anything is wrong, the error is added to the case event
                database.saveResult sr;
                try
                {
                    sr = database.insert(caseEvent);
                }
                catch(Exception e)
                {
                    caseEvent.addError('Failed to save record: ' + e.getMessage());
                    return null;
                }
                if (!sr.isSuccess())
                {
                    caseEvent.addError('Failed to save record. Please check source code');
                    return null;
                }
                
                //createCaseTimesForCaseEvent(caseEvent, theCase);
                //  we'll need to update the cases status and subject field if the user has changed them
                //  this is not needed as in the code below.... we are updating the case irregardless
                
            }
            else if (isVFPageInEditMode)
            {
                //  checks if the record has been modified since the page was openeed
                
                {
                    try
                    {
                        update caseEvent;
                    }   
                    catch(Exception e)
                    {
                        caseEvent.addError('Failed to update the record due to ' + e.getMessage());
                        return null;  
                    }
                   
                }
            }
            
            try
            {
                theCase.status = 'Closed';//  set the case status to closed and update it
                theCase.isCaseEventUpdate__c = true;
                update theCase;
            }
            catch(Exception e)
            {
                caseEvent.addError('Could not update the case due to ' + e.getMessage());
                return null;//  add error and return null so error is displayed on the page
            }
            
            //  this method contains the logic for where the user is redirectd when the case is closed 
            return redirectUserToApprioriateSaveAndClosePage(theCase);
            
        }
        
        return null;
    }
    public static PageReference redirectUserToApprioriateSaveAndClosePage(Case theCase)
    {
        system.assertNotEquals(null, theCase);
        system.assertNotEquals(null, theCase.Id);
        system.assertNotEquals(null, theCase.recordtypeId);

        
        Pagereference pr = new PageReference('/' + theCase.id);
        pr.setRedirect(true);
        return pr;
    }
    public PageReference cancel()
    {
        if (returnURL != null)//  return the user to what ever url the return url paramater is set too.
        {
            PageReference pr = new PageReference(returnURL);
            pr.setRedirect(true);
            return pr;          
        }   
        else
        {
            return null;
        }
    }
    public PageReference donothing()
    {
        return null;
    }
    
    private void initleftUserList()
    {
        //  so there two ways to initilziae this list.  new case or edit of case. new case is straightforward but
        //  edit of case is not so much.  the right pciklist may already have users selected... 
        leftUserList.clear();
        
        User[] techReps;
        if (isUserIntlSupport)
        {
            techReps = queryIntlTechReps();
        }
        else
        {
             techReps = queryTechReps();
        }
        for (User u : techReps )
        {
            leftuserList.add(new selectoption(u.lastname + ', ' + u.firstName, u.lastname + ', ' + u.firstName));
        }
    }
    private void initRightuserListForNewEvent()
    {
        if (rightUserList.size() == 0)
        {
            rightuserList.add(none);
        }
        
        sortByLabel(leftUserList);
        sortByLabel(rightUserList);
    }
 
    private void assignContactFields()
    {
        //  contact selected for the case event has changed, reup the readonly contact email/phone
        if (userChoiceContactField != null)
        {
            Contact tempContact = [select id, email, phone from Contact where id =: userChoiceContactField];
            contactPhone = tempContact.phone;
            contactEmail = tempContact.email;
        }
    }
    public boolean isRoadnetUser
    {
        get
        {
            return userInfo.getUserName().Contains('@roadnet');
        }
    }

    //  **********  Private Instance Functions  **********
    public PageReference updateCaseEvent()
    {
        system.assertNotEquals(null, caseEvent);
        system.assertNotEquals(null, caseEvent.id);
       
        {
            if (caseEvent.Start_Time__c != null && caseEvent.End_Time__c != null)
            {
                caseEvent.Time_Spent__c = 
                   Round5Minutes(
                   Integer.valueof(timeBetweenInMinutes(caseEvent.Start_Time__c, caseEvent.End_Time__c)) );
            }
            try
            {
                update caseEvent;//  just try to update the case event
                //createCaseTimesForCaseEvent(caseEvent, theCase);
             
                //  we'll need to update the cases status and subject field if the user has changed them
                if (didCaseFieldsChange)
                {
                    update theCase;
                }
                if (theCase.id == null)//  return user to case event if for any reason the case doesnt have id (which it did when first testing)
                {
                    return new PageReference('/' + caseEvent.id);//  redirect the user to the case event's case
                }
                else
                {
                    return new PageReference('/' + theCase.id);
                }
            }   
            catch(Exception e)
            {
                //throw e;
                caseEvent.addError('failed to update the record due to ' + e.getMessage());
                return null;  
            }
        }
    }

    public PageReference insertCaseEvent()
    {
        util.debug('inside of insertCaseEvent.....');
        
        system.assertNotEquals(null, caseEvent);
        system.assertEquals(null, caseEvent.id);
        // case event is no longer a master detail relationship system.assertNotEquals(null, caseEvent.case__c);//  cant create case event without the case id
        
        if (caseEvent.Start_Time__c != null && caseEvent.End_Time__c != null)
        {
            caseEvent.Time_Spent__c = 
               round5Minutes(
               Integer.valueof(timeBetweenInMinutes(caseEvent.Start_Time__c, caseEvent.End_Time__c)));
        }
        
         try
        {
            
            database.saveResult sr = database.insert(caseEvent);
            if (sr.isSuccess())
            {
                //  we'll need to update the cases status and subject field if the user has changed them
                if (didCaseFieldsChange)
                {
                    //theCase.isCaseEventUpdate__c = true;
                    util.debug('case event CASE is being updated, the isCaseEventUpdate bool is set to true tho');
                    update theCase;
                }
                util.debug('case event should have been created and updated, the sr.getId = ' + sr.getId());
                if (theCase.id == null)//  return user to case event if for any reason the case doesnt have id (which it did when first testing)
                {
                    return new PageReference('/' + sr.getid());//  redirect the user to the case event's case
                }
                else
                {
                    return new PageReference('/' + theCase.id);
                }
            }   
            else
            {
                caseEvent.addError('Failed to save record. Please check source code');
                return null;
            }
        }   
        catch(Exception e)
        {
            caseEvent.addError('failed to save the record due to ' + e.getMessage());
            return null;    
        }        
    }
    public static void createCaseTimesForCaseEvent(Case_Event__c ce, Case caseOfCaseEvent)
    {
        //  i actually have to recreate the logic for this method as it existed beofre but not now,
        //  the idea here is to set a flag on the case that says "its case event update" menaing to NOT 
        //  we then create case times for the case event and any assistant techs of the case event
        //  first thing is to create case time for the case event itself
        
        //  if  0 < time spent < 1, set it to 1
        if (ce.Time_Spent__c < 1 && ce.Time_Spent__c > 0)
        {
            ce.Time_Spent__c = 1;
        }
        
        
        List<Mibos_Case_Time__c> caseTimesToCreate = new List<Mibos_Case_Time__c>();
        Mibos_Case_Time__c caseTimeForEvent = new Mibos_Case_Time__c();
        caseTimeForEvent.Case__c = caseOfCaseEvent.id;
        caseTimeForEvent.Case_Event__c = ce.id;
        caseTimeForEvent.Owner__c = userInfo.getUserId();
        caseTimeForEvent.Work_Effort__c = ce.Time_Spent__c;
        caseTimesToCreate.add(caseTimeForEvent);
        if (ce.Assisting_Technician__c != null)
        {
            //  that way all we have to do is cursor thru the ids and assign a different one to the owner field
            Mibos_Case_Time__c assistantTechCaseTime = new Mibos_Case_Time__c();
            assistantTechCaseTime.Case__c = caseOfCaseEvent.id;
            assistantTechCaseTime.Owner__c = ce.Assisting_Technician__c;
            assistantTechCaseTime.is_Assistant_Tech__c = true;
            
            assistantTechCaseTime.Work_Effort__c = ce.time_spent__c;
            caseTimesToCreate.add(assistantTechCaseTime);
        }
        insert caseTimesToCreate;
        
    }
    
    public static string nullToWhiteSpace(string str)
    {
        if (str == null)
        {
            return '';
        }
        else
        {
            return str;
        }
    }
    
    public static void sendExternalEmailAlertsForPortalCases(Case_Event__c ce, Case theCase)
    {
        //  if public portal and creator of case event is not portal user and the case contact is set
        if ((theCase.RecordType.Name == 'Customer Portal') &&
            !isActivePortalUser() && 
            ce.Display_In_Customer_Portal__c &&
            ce.Communication_Type__c != 'Internal' &&
            (theCase.ContactId != null) &&
            (theCase.Email__c != null))
        {
            boolean hasOptedOutOfEmail = [select hasOptedOutOfEmail from Contact where id =: theCase.ContactId ].hasOptedOutOfEmail;
            //  send email to Email__c field of case
            if (!hasOptedOutOfEmail)
            {
                //  we can use the same method as above
                sendEmailAlertToCaseOwner(
                   theCase.Email__c, 
                   [select name from User where id =: ce.createdByid].name,
                   theCase.CaseNumber,
                   theCase.subject,
                   ce.subject__c,
                   ce.details__c);
            }
        }
    }
    
    public static void sendEmailAlertCaseEventCreation(Case_Event__c caseEvent)
    {
        //  the emailmessagte trigger will be cretaing case events for Replied to emails,  this can lead to circular emails
        //  if we allow this to send an email to a customer that a case event was created without checking that the case event wasn't created by an 
        //  emailmessage trigger
        if (caseEvent.subject__c.Contains('Created Via EmailTrigger') || caseEvent.Subject__c.Contains('ref:_'))
        {
            return ;
        }
        //id custSatId = [select id from Case_Reason__c where name = 'Customer Satisfaction'].id;        
        
        //  since i copy pasted this from the old code, im keeping the structure the same, we requery the caseevent for the case fields
        Case_Event__c ce;
        try
        {
            ce = [select id, Case__r.Email__c, Communication_Type__c, Case__r.Contact.FirstName, Case__r.CaseNumber, subject__c, details__c, Case__r.isOkToSendAutoEmail__c, 
           Case__r.Subject, Case__r.Description, Assisting_Technician__c
           from Case_Event__c where id =: caseEvent.Id and 
           Case__r.IsVisibleInSelfService = true and 
           Display_in_customer_portal__c = true and 
           Communication_Type__c != 'Internal' and 
           //Case__r.Reason2__c !=: custSatId and
           Case__r.isOkToSendAutoEmail__c = 'True'];
        }
        catch(exception e)
        {
            //  its posible the case is not a support OkToSendEmail case and in that sense, we cont want to send the email aelrt out
            return ;
        }
        //  only send the case event if the commtype != internal
        if (ce.Case__r.Email__c != null && ce.Communication_Type__c != 'Internal')
        {
            //  so i just realized we cant use eamil templates here because the template used teh contact record for its id whereas the case could have
            //  a different email address definied, so we DO need to construct this manually
            string subject = 'Case Event created for Case#' + ce.Case__r.Casenumber; 
            string htmlbody = RT_EMAIL_HEADER_IMAGE +
              '<br />Dear ' + (ce.case__r.Contact.FirstName == null ? 'Customer' : ce.Case__r.Contact.FirstName) + ', <br /><br/>' + 
              '<br />Your Product Support Case#' + ce.Case__r.CaseNumber + ' ' + ce.Case__r.Subject + ' has the following recent case activity below: <br />' + 
              '<br /><b>Event Subject:  </b>' + nullToWhiteSpace(ce.Subject__c) + 
              '<br /><b>Event Details:  </b>' + nullToWhiteSpace(ce.Details__c) +
              '<br /><br /><b>Case Subject:  </b>' + nullToWhiteSpace(ce.Case__r.Subject) +
              '<br /><b>Case Details:  </b>'  + nullToWhiteSpace(ce.Case__r.Description) +
              '<br /><br />Thank you,' +
              '<br />Roadnet Technologies' +
              '<br /><br />For the most efficient service, please reply to this email if you have additional information or questions about this case.   ' +
              'If this item is urgent in nature, please call our 24 hour support line at 1.800.762.3638 option 1 and refer to the case number above.' +
              '<br /><br />';
              
            List<string> toEmail = new List<string>{ce.Case__r.Email__c};
            
            string htmlBodyFormatted = '<html><head><style>body {font-family:Arial; font-size:13px;}</style></head><body> ' + htmlBody +
               '</body></html>'; 
            
            final string upsltSupportOrgWideEmailAddress = '0D230000000007l';
            if (toEmail.size() > 0)
            {
             
            }
        }
    }
    public boolean checkRequriedFieldsForSave()
    {
        boolean isOkToSave = true;
        final string ERROR_MESSAGE = 'Required Field Missing';
        
        if ( ( caseEvent.subject__c == null ) || ( caseEvent.subject__c.length() == 0 ) )
        {
            isOkToSave = false;
            caseEvent.addError('Case Event Subject is missing');
        }       
        if (theCase.Subject == null || theCase.subject.length() == 0)
        {
            isOkToSave = false;
            theCase.addError('Case Subject is missing.');
        }
        if (theCase.Status == null || theCase.Status.length() == 0)
        {
            isOkToSave = false;
            theCase.addError('Case Status is missing');
        }
        if ((theCase.Category__c == null || theCase.CAtegory__c.length() == 0) && theCase.Business_Unit__c!='XRS')
        {
            isOkTosave = false;
            theCase.Category__c.addError(ERROR_MESSAGE);
        }     
        //  if the end time/start time is required (ie domestic support case)
        if (isTimeSpentRequired)
        {
            //  we've added two other fields to the case evet page: case subject, and case status
            //  those fields should only show AND shoulw only be required if the case is a domestic support case
            
            if (caseEvent.Time_Spent__c == null || caseEvent.Time_Spent__c == 0)
            {
                isOkTosave = false;
                caseEvent.Time_Spent__c.AddError(ERROR_MESSAGE);
            }
            
            if (caseEvent.Time_Spent__c < 0)
            {
                isOkToSave = false;
                caseEvent.Time_Spent__c.AddError('Please place value greater than 0');
            }

            //  the assignPIcklistValue should have set the theCase.contactid field if it was blank and the user had to set it
            //  so we'll check that the cases contact id is not set, and if so, we ding the user but we ding themon the contact name picklist
            if (theCase.contactid == null)
            {
                //theCase.contactid.addError(ERROR_MESSAGE);
                //isOkToSave = false;
            }
            
            //  actually there are tons of cases with no product set for them... there doesn't appear to be any pattern
            //  i was going to save that most of the vf page doesnt require a prduct if is it realted is false
            //  but that is not the case.  to make my life and everyone elses life, easier, the case event will no longer
            //  require a case product
            
            //  ive deicded that the other case fields exposed no longer need to be required.
            //  the reason is that their requirdeness was dependant on the vf page picklists having values 
            //  and if they did then a certain field would be rquired.  now that we no longer have picklists
            //  we cant measure if the fields should be required.
            
            
        }
        return isOktoSave;
    }
    
    public void assignPicklistValues()
    {
       //  heres the issue that im runnig into, if the case _had_ an old case reason, but the user has changed it, the getter for isoldcasereason
        //  returns false now, and now the assignment done down here will never get called.  we basically need a boolean that is set
        //  in the inti methods that checkst eh case reason and sets it to false.  flipping that boolean can only occur in the save method 
        //  but i forgot, there is new logic, that logic is that the user can pick a new case reason/sub reason even if the case had a valid reason
        //  so either way, we need to make this assignment down here i
        //  the isOldCaseReason boolean is only lfor the warning mesasage at the top of the screen and for checkrequired fields validaiton thats it
        //  to be brutally honest, i dont even think we need to turn off the flag.  and if we do, we can attach the turning of it off to the case reasons
        //  onchange event
    
       //  if the contactid on the caes is blank, the user is required to set the contact name on the vf page.  if they did so
       //  the caseevnet.contactid is set but we need to update the case's contactid here
       if (theCase.Contactid == null)
       {
            theCase.contactid = userChoiceContactField;
       }
          
       //theCase.Product__c = productPicklist.selection;
       //theCase.Reason2__c = caseReasonPicklist.selection;            
       //theCase.Sub_Reason__c = subReasonPicklist.selection;
    }
    public void initIfCaseEventIsInEditMode()
    {
        system.assertNotEquals(null, caseEvent);
        system.assertNotEquals(null, caseEvent.Case__c);
        theCaseId = caseEvent.Case__c; 
        theCase = queryCase(theCaseId);
        //contactExtension = theCase.ContactId != null ? theCase.Contact.Extension1__c : '';
        
        showAccountField = theCase.Accountid == null;
        
        isCaseClosedAlready = theCase.Status == 'Closed';
        //  bug or open item exists where if you create a case without a rescue pin, the work effort is not wiped out
        //  because of this, when you create a case event for a caes like that, the case's work_effort already has a value
        //  to fix this, i'm swiping whatever is in the case's work effort so the user is forced to pick a new one
        theCase.Work_Effort_In_Minutes__c = null;
        
        originalCase = theCase.clone(false, true);
        
        userChoiceContactField = caseEvent.Contact__c;//  pre pop from the case
        assignContactFields();
        
        //userchoiceAssistingTech = caseEvent.Assisting_Technician__c;
        
        //  the case event page allows the user to set the cases status from the event, because of this, we want to swipe the case's status, the 
        //  user is required to change the staus of the case when creating a case event
        theCase.status = null;
        
        initLeftUserList();
        initRightuserListForNewEvent();
    }
    
    public void initIfCaseEventIsInNewMode()
    {
        util.debug('inside of initIfCaseEventisInNewMode...');
        //  see if we are in the mibos insatnce, if so, use that caes field id that it uses to get the case id
        if (mibosCaseFieldId != null)
        {
            theCaseId = mibosCaseFieldId;
        }
        
        theCase = queryCase(theCaseId);//  query almost all fields for the case
        
        isCaseClosedAlready = theCase.Status == 'Closed';
        
        showAccountField = theCase.Accountid == null;
                
        //  bug or open item exists where if you create a case without a rescue pin, the work effort is not wiped out
        //  because of this, when you create a case event for a caes like that, the case's work_effort already has a value
        //  to fix this, i'm swiping whatever is in the case's work effort so the user is forced to pick a new one
        theCase.Work_Effort_In_Minutes__c = null;
        
        originalCase = theCase.clone(false, true);
        //userChoiceAssistingTech = orig_userChoiceAssistingTech = null;
        //  the case event page allows the user to set the cases status from the event, because of this, we want to swipe the case's status, the 
        //  user is required to change the staus of the case when creating a case event
        util.debug('in init for new mode method, the case status = ' + theCase.status);
        /*
        no longer swipe the status
        if (theCase.status != 'Closed')//  the isCaseAlreadyClosed depends on the cases status being closed so dont wipe out the case status
        {
           theCase.status = null;
        }
        */
        
        caseEvent.case__c = theCaseId;
        userChoiceContactField = theCase.ContactId;//  pre pop from the case
        //contactExtension = theCase.ContactId != null ? theCase.Contact.Extension1__c : '';
        caseEvent.Send_email_notification_to_contact__c = theCase.Send_email_notification_to_contact__c;
        
        assignContactFields();
        
        //  default to true for portal user and false for regular users
        if (isPortalUser)
        {
           caseEvent.Send_email_notification_to_contact__c = caseEvent.Display_In_Customer_Portal__c = isPortalUser;
        }
        else//  default to what the parent case has
        {
            caseEvent.Send_email_notification_to_contact__c = caseEvent.Display_In_Customer_Portal__c = theCase.Send_email_notification_to_contact__c;
        }
        
        if (isPortalUser)
        {
            caseEvent.Communication_Type__c = 'Customer Portal';
            
        }
        else if (isTimeSpentRequired)
        {
            caseEvent.Communication_Type__c = null;//  john asked taht the contact method be emptied so that support has to set it
        }
        else
        {
            //  conlsutings currenly have the profile named: PSE - Management with CS
            //  in the omni prod
            if (loggedInUser != null && 
                loggedInUser.profileid != null && 
                loggedInUser.Profile.Name != null && 
                loggedInUser.profile.name == 'PSE - Management with CS')//  user is a consultant?
            
            {
                caseEvent.Communication_Type__c = 'Email';
            }
            else
            {
                caseEvent.Communication_Type__c = 'Phone';//  set this by default
            }
        }
    
        caseEvent.Created_By_VF_Page__c = true;
        caseEvent.Start_Time__c = DateTime.Now();//  pre pop start time for user
        if (isTimeSpentRequired)//  only for domestic support
        {
            //isOldCaseReason = !CaseClassHelperClass.isCaseValidReason(theCase.REason2__c, theCase.Product__c);
        }
        else
        {
            //isoldCaseReason = false;
        }
        initleftUserList();
        initRightUserListForNewEvent();
        
    }

    private void assignCaseEventModeBoolens()
    {
        system.assertNotEquals(null, urlParameterMap);
        caseEventId = urlParameterMap.get('id');
        returnURL = urlParameterMap.get('retURL');
        //  need to determine if we are in new or edit mode first 
        isVFPageInNewMode = (urlParameterMap.get(MIBOS_CASE_FIELD_ID) != null);
        isVFPageInEditMode = (caseEventId != null);
        isVFPageInCloneMode = (urlParameterMap.get('clone') != null);
    }
    private boolean isCaseClosedAlready
    {
        get
        {
            if (isCaseClosedAlready == null)
            {
                isCaseClosedAlready = false;//  false by default
            }
            return isCaseClosedAlready;
        }
        set;
    }
        

    private boolean didCaseFieldsChange
    {
        get
        {
            return  (originalCase.Status != theCase.Status) ||
                    (originalCase.Subject != theCase.Subject) ||
                    (originalCase.OwnerId != theCase.OwnerId) ||
                    (originalCase.ContactId != theCase.ContactId) || 
                    (originalCase.Vendor_Case_Code__c != theCase.Vendor_Case_Code__c) ||
                    //(originalCase.Case_Reason_PL__c != theCase.Case_Reason_PL__c) ||
                    (originalCase.Sub_Reason_PL__c != theCase.Sub_Reason_PL__c) ||
                    (originalCase.solution_long__c != theCase.solution_Long__c) ||
                    (originalCase.Work_Effort_In_Minutes__c != theCase.Work_Effort_In_Minutes__c) ||
                    (originalCase.Category__c != theCase.Category__c) ||
                    (originalCase.Business_Unit__c != theCase.Business_Unit__c) ||
                    (originalCase.Assisting_Techs__c != theCase.Assisting_Techs__c) ||
                    (originalCase.Type_Level_2__c != theCase.Type_Level_2__c);
        }           
        
    }
      
    //  **********  Static Functions  **********
    public static Case queryCase(Id caseId)
    {
        Case theCase;
        if (caseId != null)
        {
           
                theCase = 
                    [Select CaseNumber, area_level_3__c, Recordtype.name, Account.Name, Account.Ownerid, description,
                    SuppliedPhone, SuppliedName, SuppliedEmail, Subject, Status,  
                    RecordTypeId, OwnerId, Owner.Name, Origin,  
                    LastModifiedDate, contact.firstname, contact.lastname, contact.email, 
                    LastModifiedById, LastModifiedBy.Name,  
                    owner.Email, IsVisibleInSelfService,
                    IsEscalated, IsClosed, Id,  Email__c, 
                    CreatedDate, CreatedById, Contact.Name, ContactId, 
                    ClosedDate, AccountId,  
                    Documentation_Rating__c, IsOkToSendAutoEmail__c,  
                    parentid, 
                    CreatedBy.name, 
                    Assisting_Techs__c,
                    Product_PL__c,
                    Category__c,
                    Type_Level_2__c, SubStatus__c,
                    Product_Family_PL__c, Sub_Reason_PL__c, 
                    Product_Version_PL__c, work_effort_in_minutes__c,
                    contact.Extension__c, Business_Unit__c, Send_email_notification_to_contact__c,
                    Solution_Long__c, Resolution__c
                    From Case where id =: caseId limit 1];
        }
        return theCase;
        
    } 
    public static ApexPages.StandardController generateController(Case_Event__c caseEvent, string theCaseId, string theId )
    {
        //system.assertNotEquals(null, theCaseId);
        system.assertNotEquals(null, caseEvent);
        
        pagereference pageRef=new pagereference('Page.CaseEventExtension');
        test.setcurrentpage(pageRef);
        
        if (theId != null)
        {
            ApexPages.currentPage().getParameters().put('id', theid);
        }
        
        //ApexPages.currentPage().getParameters().put(MIBOS_CASE_FIELD_ID, theCaseId);
        ApexPages.currentPage().getParameters().put('retURL', '%2fhome%2fhome.jsp');//  set return url to /home/home.jsp
        
        return new ApexPages.standardController(caseEvent);
    }
        
    public static Case_Event__c querycaseEvent(string theId)
    {
        if (theId != null)
        {
            return [Select details__c, case__c, name, subject__c, Assisting_Technician__c, Send_email_notification_to_contact__c,
                createdbyid, createdby.name, Time_Spent__c, lastmodifiedby.name, lastmodifieddate, 
                Contact__c, Case__r.Contact.Name, Case__r.AccountId, Case__r.Account.name, Case__r.Email__c, 
                Case__r.Recordtype.Name, Display_in_Customer_Portal__c, Communication_Type__c 
                From Case_Event__c where id =: theId];
        }
        else
        {
            return null;
        }
    }    

    public static Case createTestCase(string recordTypeName)
    {
        if (recordtypename == null)
        {
            recordTypename = 'Support';
        }   
        return [select id, contact.name, contactId, recordtype.name, IsVisibleInSelfService, status from Case where recordtype.name =: recordTypeName limit 1];
    }
    //  ******* CODE BELOW IS CASECLASSHELOPERCLASS CODE THAT IS PREPPED FOR MIBOS DEPLOYMENT ***********
    public static final string RT_EMAIL_HEADER_IMAGE = '<p><img src="http://fleet.omnitracs.com/rs/723-FSI-200/images/OmnitracsRoadnetEmailHeader092315.jpg" width="805" height="184"/></p>';
    //public static final string VERSION_STILL_OPEN = 'Dev version assoicated with this case is still open.  Cannot close case.';
    /*public static List<SelectOPtion> statusPicklist(boolean isNew)
    {
    
        List<selectOption> options = new List<SelectOption>();
        options.add(PL.noneOption);
    
        //  isEdit?  then only these options are avilalbe
        options.add(new SelectOption('Awaiting Customer', 'Awaiting Customer'));
        options.add(new SelectOption('Change Request', 'Change Request'));
        options.add(new SelectOption('Open', 'Open'));
        options.add(new SelectOption('No Response From Customer', 'No Response From Customer'));
        options.add(new SelectOption('Researching', 'Researching'));
        options.add(new SelectOption('Resolved', 'Resolved'));
        
        //options.add(new SelectOption('Resolved - Pending Confirmation', 'Resolved - Pending Confirmation'));    
        options.add(new SelectOption('Third Party', 'Third Party'));
        
        return options;
        
    }*/
    public static double timeBetweenInMinutes(DateTime startTime, DateTime endTime)
    {
        system.assert(startTime != null);
        system.assert(endTime != null);
        
        id bhid = '01m30000000LHOh';//  24 hours businesshour record
        double deltaTimeInMilliSeconds = businessHours.diff(bhid, startTime, endTime);
        
        double inMinutes = (deltaTimeInMilliSeconds / 1000) / 60;//  time in milliseconds / 1000 = time in seconds, time in seconds / 60 = time in minutes 
        return inMinutes.round(); //  minutes were being returned like 1.23 and 1.64.  from a time perspective, this makes no sense
    }
    public static double timeBetweenInMinutesWorkWeek(Date startDate, Date endDate)
    {
        system.assert(startDate != null);
        system.assert(endDate != null);
        
        id bhid = '01m30000000GpSa';// 9 to 5 monday through friday
        double deltaTimeInMilliSeconds = businessHours.diff(bhid, startDate, endDate);
        
        util.debug('the delta = ' + deltaTimeInMilliSeconds);
        double inMinutes = (deltaTimeInMilliSeconds / 1000) / 60;//  time in milliseconds / 1000 = time in seconds, time in seconds / 60 = time in minutes 
        return inMinutes.round(); //  minutes were being returned like 1.23 and 1.64.  from a time perspective, this makes no sense
    }
    public static boolean isUserIntlSupport
    {
        get
        {
            id salesIntlSupport = '00e30000000hxz3';
            id internationalSupportLead = '00e30000001LUiR';
            id salesIntlProjectmanager = '00e30000001KmV3';
            
            boolean areThey = userinfo.getProfileid().contains(salesIntlSupport) || 
              userinfo.getprofileId().contains(internationalSupportLead) ||
              userinfo.GetProfileId().contains(salesIntlProjectmanager); 
            
            util.debug('isUserIntlSupport = ' + isUserIntlSupport + ' profile id = ' + userInfo.getProfileId());
            
            return areThey;
        }
    }
    public static List<user> queryTechReps()
    {
        //  ok i'm thinking that this query is no longer valid, i think we should query agaisnt the case team table....
        //  the reason is that lisa g. trevor, brian and matt dean will no longer be with John's group but their profile reamins the same
        //  i need to use the case teams.. scratch that, i'm giong to users table.  the case team table is only managed by myself where
        //  as the user table is manaegd by myself, jane, and paranet
        return [select id, firstname, lastname, name from user where isactive = true and email like '%@roadnet.com' order by lastname limit 77];
     
              
    }
    public static List<User> queryIntlTechReps()
    {
        return [select id, firstname, lastname, name from user where isactive = true and email like '%@roadnet.com'  order by lastname limit 77];
        
    }
    public static SelectOption none
    {
        get
        {
            return new SelectOption(PL.NONE, PL.NONE);
        }
    }
        public static void sortByLabel(List<SelectOption> options)
    {
        //  assume we have park, jane; hutch, joe, bowser amy in the list
        
        //  going to use traditional bubble sort
        for (integer i = 0; i < options.size() - 1; i++)
        for (integer j = 0; j < options.size() - 1; j++)
        {
            //  the --none-- option exists for these picklists so if we encounter it (it should be the first on the list) ignore it...
            //  the check down below needs to make sure the 0th and 0th + 1 row is not = --None-- before deiciding to swap the items in the list
            
         
            //  compare 0 with 1, if its lower, swap positions
            if (options[j].getValue() != '--None--' &&  //  0th row not == --none--
                options[j + 1].getValue() != '--None--' && //  0th + 1 row != --none--
                options[j].getLabel() > options[j + 1].getLabel())//  the item is lesser
            {
                selectoption tempOption = options[j];
                options[j] = options[j + 1];
                options[j + 1] = tempOption;
            }
        }   
    }
    public static SelectOption removeSelectOption(string name, list<SelectOption> options)
    {
        for (integer i = 0; i < options.size(); i++)
        {
            if (name == (options[i].getValue()))
            {
                Selectoption tempOption = options.remove(i);
                return tempOption;
            }
        }
        return null;
    }
    
    /*
    public static PageReference addUsersToPicklist(List<string> userstoAdd, List<Selectoption> leftUserList, List<Selectoption> rightUserList)
    {
        //  only need to pass in the left user list so it can be sorted
        for (integer i = 0; i < usersToAdd.size(); i++)
        {
            SelectOption userNameRemoved = removeSelectOption(usersToAdd[i], leftUserList);
            system.assertNotEquals(null, userNameRemoved);
            
            if (userNameRemoved != null && !listcontains(userNameRemoved, rightUserList))//  also want to make sure the destination list doesn't already have the user in the list already
            {
                rightUserList.add(userNameREmoved);
            }
        }
        //  i guess the idea here is we dotn want to check and remoev the none option everytime do we add a name do we??
        //  i'm trying to figure out the easiet logic here, do we check each tiem the button is presed?  or how about when the list contains
        //  something... (the list will always contain soemthing)
        //  so after diong some thinking, if we are pressing the add button (unless the user hasnt selected anything, then the right user list)
        //  will always have a value in it so lets just look for an remove the none option each time the add button is pressed and when the remove button is pressed 
        if (rightuserList.size() > 0)
        {
            //  i think the appropiate logic here is to check if the list has something in it, and if so fidn and remove the none option?
            RemoveSelectOption('--None--', rightUserList);
        }
        
        
        //  we've added values to the picklists, resort them to that they are still alphabetical
        sortByLabel(leftUserList);
        sortByLabel(rightUserList);
        return null;
            
    }
    

    public static PageReference removeUsersFromPicklist(List<string> usersToRemove, List<Selectoption> leftUserList, List<Selectoption> rightUserList)
    {
        //  scroll thru all users selected for removal
        for (integer i = 0; i < usersToRemove.size(); i++)
        {
            //   make sure we aren't trying to mvoe the none option
            if (usersToRemove[i] != '--None--')
            {
                //  remove the selectoptoin from the source list
                SelectOption userNameRemoved = removeSelectOption(usersToRemove[i], rightUserList);
                
                //  the user was found in the source list  and its not the NONE selectoption
                if (userNameRemoved != null &&
                    !listContains(userNameRemoved, rightUserList) && //  item isnt in the list already 
                    userNameRemoved.getValue() != '--None--')
                {
                    //  check if the value is in the live already and if not add it
                    leftUserList.add(userNameREmoved);
                }
            }
        }
        //  if the user removed everything from the list, show the none option:
        if (rightUserList.size() == 0)
        {
            rightuserList.add(none);
        }
        
        //  we've added values to the picklists, resort them to that they are still alphabetical
        sortByLabel(leftUserList);
        sortByLabel(rightUserList);
        return null;
    }  
    */
    public static integer Round5Minutes(integer minutes)
    {
        if (minutes < 1)
        {
            return 5;
        }
        while (Math.Mod(minutes, 5) != 0)
        {
            minutes++;
        }
        return minutes;
    }
    
    public static boolean ListContains(Selectoption theOption, List<SelectOption> options)
    {
        for (SelectOption so : options)
        {
            if (theOption.GetValue() == so.getValue())
            {
                return true;
            }
        }
        
        return false;
    }
 

    public static boolean isActivePortalUser()
    {
        User currentUser = [select id, isPortalEnabled, UserType from User where id =: UserInfo.getUserId()];
                
        // currentUser.UserType.contains('Portal') && 
        if (currentUser.IsPortalEnabled == true)
        {
            return true;
        }
        else
        {
            return false;
        }        
    }
        public static void sendEmailAlertToCaseOwner(
        string toEmailUserId, 
        string whoCreatedCaseEvent, 
        string caseNumber, 
        string caseSubject,
        string caseEventSubject, 
        string caseEventDetails)
    {
        system.assertNotEquals(null, toEmailUserId);
        
        string subject = 'Case Event created for Case Number ' + caseNumber;
        string htmlbody = 
            'A case event has been created by ' + whoCreatedCaseEvent + ' at '  + 
            DateTime.Now().format('hh:mm a MM/dd/yyyy') + 
            ' for case #' + caseNumber + ' with case subject: ' + caseSubject +
            '<br><br><b>Case Event subject:</b>  ' + caseEventSubject +
            '<br><br><b>Case Event details:</b>  ' + (caseEventDetails == null ? '' : caseEventDetails);
        string textBody = '';// EmailClass.convertHtmlToText(htmlBody);
        
        if (toEmailUserId != null)
        {
        
        }
        
    }
    public static boolean isOwnerQueue(Id userId, List<QueueSobject> queues)
    {
        for (QueueSobject q : queues)
        {
            if (q.QueueId == userId)
            {
                return true;
            }
        }
        return false;
    }
    public static boolean isOwnerQueue(id UserId)
    {
        for (QueueSobject queue : [select id, queueid from QueueSobject where sobjecttype = 'Case' ])
        {
            if (queue.QueueId == userId)
            {
                return true;
            }
        }
        return false;
        
    }
    public static Set<string> parseString(string str)
    {
        List<string> theStrings=new List<string>();
        
        if (str==null)
        {
            return new set<string>();
        }
        else
        {   
            theStrings=(str.split(';', 0));
            //lets make sure there isn't blank items in the list and try to clear in any leading trailign whitespaces
            for (integer i=0; i<theStrings.size();i++)
            {
                theStrings[i]=theStrings[i].trim();
                if (theStrings[i]=='') theStrings.remove(i);
            }
        }
        set<string> stringsToReturn = new set<string>();
        
        for (integer i = 0; i < theStrings.size(); i++)
        {
            if (!stringsToReturn.contains(theStrings[i]))
            {
                stringsToReturn.add(theStrings[i]);
            }
        }
        return stringsToReturn; 
    }
    
    public static Set<id> queryActiveUserIds(set<string> userNamesSet)
    {       
        //  parse out the last name and first name of eadch user name passed into here, but in lists
        //  perform query on the contacts
        List<string> firstNames = new List<string>();
        List<string> lastNames = new List<string>();        
        
        for (string userName : userNamesSet)
        {
            system.debug('attempting to parse: ' + userName);
            list<string> namesParsed = userName.split(',', 0);
            system.debug('after parsing: ' + namesParsed);
            
            if (namesParsed != null && namesParsed.size() == 2)
            {
               lastnames.add(namesParsed[0].trim());  // first elemante should be last named, second element should bew first name
               firstNames.add(namesParsed[1].trim());               
            }
        }
        if (firstNames.size() > 0 && lastNames.size() > 0 && firstNames.size() == lastNames.size())
        {
            //  now we should have a list of first names and a list of last names, now... be advised 
            //  we are not going to get exact user matches, we need to scroll thru the results nad make sure the first name and last name match
            //  what was passed in
            Map<String,User> mapusers = new Map<String,User>();
            set<id> useridSet = new SEt<Id>();
            
            /*list<User> allactiveUsers = new List<User>();
            for (List<User> Usera : [select id, firstname, lastname, contactId from user where isactive = true order by lastname])
        	{
        		allactiveusers.addall(usera);
    		}
        	UPDATE allactiveusers;*/
            
            for(User singleuser :allactiveUsers)
            {
                if(singleuser.contactid == null)// exclude partner user records like jane park's test one
                    mapusers.put(singleuser.lastName+' '+singleuser.firstName,singleuser);
            }            
                        
            //  now scroll thru the firstnames list and lastnames list looking for matches
            for(integer i = 0; i < lastNames.size(); i++)
            {
                String username = lastNames[i]+' '+firstNames[i];
                if(mapusers.containsKey(username))
                {
                    if(!userIdSet.Contains(mapusers.get(username).id))
                    {
                        userIdSet.add(mapusers.get(username).id);
                    }
                }
                /*for (User u : users)
                {
                    if (lastNames[i] == u.lastName &&
                        firstNames[i] == u.firstName)
                    {
                        if (!userIdSet.Contains(u.id))
                        {
                            userIdSet.add(u.id);
                        }
                    }
                }*/              
            }
            system.debug('num of users ids that will be  returned: ' + userIdSet.size());                
            return userIdSet;
        }
        else
        {           
            return null;
        }
    }
    
    public static void sendEmailAlertToInternalUsers(set<id> toEmailUserIds, Case_Event__c ce, Case theCase, string accountName)
    {
        //  want to change the argument passed into here to be a set, just so that dupe user ids are not in the list
        string subject = 'Case #' + theCase.CaseNumber + ' for Account ' + accountName + ' has recent case event activity.';
        string htmlbody = 
            'A case event has been created for case #<a href="https://na1.salesforce.com/' + theCase.id + '">' + theCase.CaseNumber +
            '</a>  This case is associated with ' + accountName + '.' + 
            ' <br><br><b>Subject of case:</b>  ' + theCase.subject + 
            '<br><br><b>Case Details:</b>  ' + theCase.Description +
            '<br><br><b>Case Event subject:</b>  ' + ce.subject__c +
            '<br><br><b>Case Event details:</b>  ' + ce.details__c;
        htmlBody = convertNewLineToBreak(htmlBody);
        string textBody = '';//EmailClass.convertHtmlToText(htmlBody);
        
        
        if (toEmailUserIds != null && toEmailUserIds.size() > 0)
        {
            //EmailClass.sendEmailInternalUsersAsync(idSetToList(toEmailUserIds), subject, htmlBody, textBody, Util.FromAddressForCases);
        }
    }
    public static string convertSelectOptionsToString(List<SelectOption> options)
    {
        //this function takes the list of selectedproducts in this class and makes passes them to the saveproductststring function
        //  Exception saveException;
        string[] tempList=new list<string>();
                
        for (integer i = 0; i < options.size(); i++)
        {
            if (options[i].getValue() != '--None--')
            {
                tempList.add(options[i].getValue());
            }
        }
        
        return ProductPickerClass.saveProductsToString(tempList);

    }
    public static string convertNewLineToBreak(string str)
    {
        return str.replace('\n', '<br />');
    }
    public static boolean isUserInternalAutomation()
    {
        //  the database maintence creator will be creatign mutliple cases at one tiem and doesn't need any of the case trigger logic,
        //  to avoid the too many sql errors error we need to ignore the triggers for this user
        return (userInfo.getUserId() == '00530000003L3TsAAK');
    }
    public static List<Id> idSetToList(set<id> idSet)
    {
        List<id> idListToReturn = new List<id>();
        if (idSet == null || idSet.size() == 0)
        {
            return idListToReturn;
        }
        idListToReturn.addAll(idSet);
        return idListToReturn;
    }
    public static List<SelectOption> defineContactList(Id accountId, id contactIdOfCaseAlready, boolean displayContactTitle)
    {
        
        util.debug('inside of definecontaclist, account id = ' + accountId);
        List<SelectOption> contactOptions = new List<SelectOption>();
        
        contactOptions.add(pl.noneOption);
        
        if (accountId == null)
        {
            return contactoptions;
        }
        //  we'll need to query teh contacts, this can be delegated to a function or been done inside of here
        //  once we have the contacts, we can populate the contactlist of selectoptions
        boolean foundContactOfCase = false;
        
        // Contact[] contactsAssoicatedWithAccount = ContactClass.queryAccountContacts(accountId);
        Contact[] contactsAssoicatedWithAccount;
        try
        {
             contactsAssoicatedWithAccount = [select id, name, title from Contact where 
                accountid =: accountId order by lastname limit 100];
        }
        catch(exception e)
        {
            return contactOPtions;
        }
        if (contactsAssoicatedWithAccount != null)
        {
            for (Contact cont : contactsAssoicatedWithAccount)   
            {
                if (cont.id == contactIdOfCaseAlready)
                {
                   foundContactOfCase = true;   
                }
                
                //  declare a new selectoption
                SelectOption so;
                if (displayContactTitle && cont.title != null)
                {
                    so = new selectoption(cont.id,cont.name + ', ' + cont.title);
                }
                else
                {
                    so = new selectoption(cont.id,cont.name);
                }
                //  if it isn't a dupelicate value
                // i commented this out to see if this would fix the too many script statements for upslt account case creation
                //if (!CaseClassHelperClass.isItDupeCheckValue(contactOptions, so))
                {
                    //  add it to the list
                    contactOptions.add(so);
                } 
            }
        }
        if (!foundContactOfCase && contactidofCaseAlready != null)
        {
            Contact tempContact = [select id, name from contact where id =: contactIdOfCaseAlready];
            //  case's contact is not in the list of contacts of account, add the contact to the list
            SelectOption tempSelectOption = new SelectOption(tempContact.id, tempContact.Name);
            if (contactOptions.size() > 0)
            {
                contactOptions.add(0, tempSelectOption);//  assume there are is at least one item in the list, the none option
            }
            else
            {
                contactOptions.add(tempSelectOption);
            }
        }
        
        return contactOptions;
    }
/*
    public static boolean isCaseValidReason(Id caseReasonId, Id productId)
    {
        return true;
    
    }
    */
    public static boolean checkEmailSubjectForForbiddenText(string subject)
    {
        return false;
      
    }
    
    public static void emailAlertSuppportCaseCreation(List<Case> roadnetCasesOnly, string emailType)
    {        

        Case[] casesRequeried = [select id, accountid, email_alert_support__c, lastmodifiedby.name, casenumber, description, subject, Resolution__c, account.name, account.email_alert_all_cases__c, 
            account.email_alert_support__c, account.owner.lastname, account.owner.firstname, account.ownerid from Case where id in: roadnetCasesOnly ];
        
        for(Case theCase : casesRequeried)
        {
            //  then get the users that should get the email from the case
            Set<id> toEmailUserIds = retrieveEmailSubcribers(theCase);
            system.debug('retrieveEmailSubcribers called. num of ToEmailUserIds: ' + (ToEmailuserIds == null ? 0 : toEmailUserIds.size()) );

            if(toEmailUserIds != null && toEmailUserIds.size() > 0)
            {
                string accountName = theCase.accountid == null ? 'NoAccountFound' : theCase.Account.name;
                string subject;
                string body= CaseEventExtension.RT_EMAIL_HEADER_IMAGE + '<br /><br />';
                
                if (emailType == 'Case Created')
                {
                    subject = 'Case No.' + theCase.CaseNumber + ' has just been created for ' + accountName;
                }
                if(emailType == 'Case Closure')
                {
                    subject = 'Case No.' + theCase.CaseNumber + ' has just been closed by ' + theCase.LastModifiedBy.Name + ' for account ' + accountName;                 
                }
                
                body += constructEmailBody(theCase, accountName);
                body = convertNewLineToBreak(body);
                EmailClassRoadnet.sendEmailInternalUsersAsync(idSetToList(toEmailUserIds), subject, body, body, Util.FromAddressForCases);
            }
            
        }
    }   
    private static Set<Id> retrieveEmailSubcribers(Case thecase)
    {
        if (theCase == null)
        {
            return new Set<Id>();
        }
        else
        {
            List<string> listOfUserNames = new List<string>();//  will be used by parsing method
            if (theCase.Email_Alert_Support__c != null)
            {
                listOfUsernames.addAll(parseString(theCase.Email_Alert_support__c));
            }
            
            set<string> setOfUserNames = new set<string>();           
            setOfUserNames.addAll(listOfUserNames);//  the multi select picklist should be uqniuye so we can safely add all of the names to the set
            
            ///  grab the users that should get email alert from the account level
            if (theCase.AccountId != null)
            {
                system.debug('theCase.Account..Email_Alert_All_Cases__c: ' + theCase.Account.Email_Alert_All_Cases__c + ' theCase.Account.email_alert_support__c: ' + theCase.Account.Email_Alert_Support__c);
                if (theCase.Account.Email_Alert_All_Cases__c)
                {
                    //  keep this in the format lastname, first name as this is what the methods below is expecting the names to be in
                    string accountOwnerlastNameFirst = theCase.Account.owner.lastName + ', ' + theCase.Account.Owner.FirstName; 
                    setOfUserNames.add(accountOwnerlastNameFirst);
                }
                
                if (theCase.Account.email_alert_support__c != null)
                {
                    listOfUserNames.Clear();
                    listOfUserNames.addAll(parseString(theCase.Account.email_alert_support__c));                    
                    system.debug('theCase.Account.email_alert_support__c parsed: ' + listOfUserNames);                    
                    setOfUserNames.addall(listOfUserNames);                     
                }
            }
            system.debug('set of username'+setOfUserNames);
            if(setOfUserNames.size() > 0)
            {
                return queryActiveUserIds(setOfUserNames);
            }
            else
            {
                return new set<Id>();
            }
        }
    }
    private static String constructEmailBody(Case theCase, String accountName)
    {
        String body = EmailClassRoadnet.createHyperLink(util.base_url + theCase.id, thecase.caseNumber) + 
                                                        '<br><br><b>Subject:</b>  ' + theCase.subject + 
                                                        '<br><br><b>Details:</b>  ' + theCase.Description +
                                                        '<br><br><b>Resolution:</b>  ' + theCase.Resolution__c +
                                                        '<br><br><b>Account:</b> ' + accountName + '<br />';
        return body;                                                
    }
        
    public static void emailAlertSuppportCaseEventCreation(List<Case_Event__c> caseEvents)
    {
        
        util.debug('emailAlertSuppportCaseEventCreation has been callled.' );
        //  need to requery the case events for case and account fields
        List<Case_Event__c> caseEventsRequeried = [select id, subject__c, Details__c, name, createdBy.Name, Case__r.OwnerId,
            Case__r.accountid, Case__r.email_alert_support__c, Case__r.lastmodifiedby.name, Case__r.casenumber, Case__r.description, Case__r.subject, Case__r.account.name, Case__r.account.email_alert_all_cases__c, 
            Case__r.account.email_alert_support__c, Case__r.account.owner.lastname, Case__r.account.owner.firstname, Case__r.account.ownerid from Case_Event__c where id in: caseEvents];
            
        for (Case_Event__c theCaseEvent : caseEventsRequeried)
        {
            //  then get the users that should get the email from the case
            Set<id> toEmailUserIds = retrieveEmailSubcribersCaseEvent(theCaseEvent);
            
            util.debug('retrieveEmailSubcribers called. num of ToEmailUserIds: ' + (ToEmailuserIds == null ? 0 : toEmailUserIds.size()) );
            
            if (toEmailUserIds != null && toEmailUserIds.size() > 0)
            {
                string accountName = theCaseEvent.Case__r.accountid == null ? 'NoAccountFound' : theCaseEvent.Case__r.Account.name;
                string subject;
                string body = CaseEventExtension.RT_EMAIL_HEADER_IMAGE + '<br /><br />';
                
                subject = 'Case Event #' + theCaseEvent.Name + ' has just been created for Case #' + theCaseEvent.case__r.CaseNumber + ' for account ' + accountName;
                
                body += EmailClassRoadnet.createHyperLink(util.base_url + theCaseEvent.id, theCaseEvent.Name) + '<br /><br />' +
                '<b>Case Event Subject:</b> ' + theCaseEvent.Subject__c + '<br />' +
                '<b>Case Event Details:</b> ' + theCaseEvent.Details__c + '<br />' +
                '<b>Case Event Created By:</b> ' + theCaseEvent.CreatedBy.Name + '<br /><br />' + 
                '<b>Case Subject:</b>  ' + theCaseEvent.Case__r.subject + '<br />' + 
                '<b>Case Details:</b>  ' + theCaseEvent.Case__r.Description + '<br />' + 
                '<b>Account:</b>  ' + accountName;
                
                body = convertNewLineToBreak(body);
                
                EmailClassRoadnet.sendEmailInternalUsersAsync(idSetToList(toEmailUserIds), subject, body, body, Util.FromAddressForCases);
                
            }
            
        }
    }

    /*public static void createCaseTimeForCasesWorkEffort(List<Case> cases)
    {
        List<Mibos_Case_Time__c> caseTimesToCreate = new List<Mibos_Case_Time__c>();
        
        for (Case c : cases)
        {
            if (c.Work_Effort_In_Minutes__c == null || c.work_effort_in_minutes__c == 0)
            {
                continue; // because of a bug that is happening for save and close, do not create a case time if the value is 0
            }
            //  very simplliefed logic here, we create case time for case owner
            //  and if the assitant tech field is set, we create case times for them also
            Mibos_Case_Time__c ct = new Mibos_Case_Time__c();
            ct.Case__c = c.id;
            ct.Owner__c = userinfo.getUserid();
            ct.Work_Effort__c = c.Work_Effort_In_Minutes__c;
            
            caseTimesToCreate.add(ct);
            
            //  this should only create case  times if the code that called this, was not due to a case event update
            if (c.AssistingTech__c != null)
            {
                //  that way all we have to do is cursor thru the ids and assign a different one to the owner field
                Mibos_Case_Time__c assistantTechCaseTime = new Mibos_Case_Time__c();
                assistantTechCaseTime.Case__c = c.id;
                assistantTechCaseTime.Owner__c = c.AssistingTech__c;
                assistantTechCaseTime.is_Assistant_Tech__c = true;                
                assistantTechCaseTime.Work_Effort__c = c.work_effort_in_minutes__c;
                
                caseTimesToCreate.add(assistantTechCaseTime);
            }
            
        }
        if (caseTimesToCreate.size() > 0)
        {
            insert caseTimesToCreate;
        }        
    }*/
    
    private static Set<id> retrieveEmailSubcribersCaseEvent(Case_Event__c ce)
    {
        if (ce == null)
        {
            return new Set<Id>();
        }
        else
        {
            List<string> listOfUserNames = new List<string>();//  will be used by parsing method
            if (ce.Case__r.Email_Alert_Support__c != null)
            {
                listOfUsernames.addAll(parseString(ce.Case__r.Email_Alert_support__c));
            }
            
            set<string> setOfUserNames = new set<string>();
            
            setOfUserNames.addAll(listOfUserNames);//  the multi select picklist should be uqniuye so we can safely add all of the names to the set
            
            ///  grab the users that should get email alert from the account level
            if (ce.Case__r.AccountId != null)
            {
                util.debug('ce.Case__r.Account..Email_Alert_All_Cases__c: ' + ce.Case__r.Account.Email_Alert_All_Cases__c + ' ce.Case__r.Account.email_alert_support__c: ' + ce.Case__r.Account.Email_Alert_Support__c);
                if (ce.Case__r.Account.Email_Alert_All_Cases__c)
                {
                    //  keep this in the format lastname, first name as this is what the methods below is expecting the names to be in
                    string accountOwnerlastNameFirst = ce.Case__r.Account.owner.lastName + ', ' + ce.Case__r.Account.Owner.FirstName; 
                    if (!setOfUserNames.contains(accountOwnerlastNameFirst))
                    {
                        setOfUserNames.add(accountOwnerlastNameFirst);
                    }
                }
                
                if (ce.Case__r.Account.email_alert_support__c != null)
                {
                    listOfUserNames.Clear();
                    listOfUserNames.addAll(parseString(ce.Case__r.Account.email_alert_support__c));
                    
                    util.debug('ce.Case__r.Account.email_alert_support__c parsed: ' + listOfUserNames);
                    
                    for (string singleUserName : listOfUserNames)
                    {
                        if (!setOfUserNames.Contains(singleUserName))
                        {
                           setOfUserNames.add(singleUserName);  
                        }
                    }
                    
                }
            }
            
            util.debug('finished parsing usernames from the case and account email_alert_support field.  num of users to get emails: ' + setOfUserNames.size());
            if (setOfUserNames.size() > 0)
            {
                //  so there is an issue that would arise here, if the case owner is signed up to the case, he could get two emails as we have a standard email alert that goes
                //  out to the case owner and not those that are signed up to the case.  so before we return the list of ids that are supposed to receive the email alert
                //  lets make sure the case owner's id is NOT in that list
                Set<Id> userIdsToReturn = queryActiveUserIds(setOfUserNames);
                if (ce.Case__r.Ownerid != null &&
                    userIdsToReturn != null &&
                    userIdsToReturn.size() > 0 &&
                    userIdsToReturn.Contains(ce.Case__r.OwnerId))
                {
                    userIdsToReturn.Remove(ce.Case__r.OwnerId);
                }
                return userIdsToReturn;
            }
            else
            {
                return new set<Id>();
            }
        }
    }

    public static void sendEmailAlertNotfyingFieldsHaveChanged(boolean didOwnerChange, Case oldCase, Case newCase)
    {
        util.debug('inside of sendEmailAlertNotfyingFieldsHaveChanged...');
        
        if (newCase.Email_Alert_Support__c != null)
        {
            Set<string> usersAssignedToCase = parseString(newCase.Email_Alert_Support__c);
                        
            set<id> toEmailUserIds = queryActiveUserIds(usersAssignedToCase);
            util.debug('after querying toEmailUserIds, num returned: ' + toEmailUserIds.size());
            string subject;
                        
            string htmlBody;
            if (didOwnerChange)
            {
                string oldOwner;
                string newOwner;
                try
                {
                    oldOwner = [select name from User where id =: oldCase.OwnerId].name;
                }
                catch(Exception e)
                {
                   oldOwner = 'Queue';  
                }
                try
                {
                    newOwner = [select name from User where id =: newCase.OwnerId].name;
                }
                catch(Exception e)
                {
                    newOwner = 'Queue';
                }
                
                subject = 'The owner of the Case #' + newCase.caseNumber + ' has changed from: ' + oldOwner + ' to: ' + newOwner;
                htmlBody = 'The owner of the Case #' + EmailClassRoadnet.createHyperLink(Util.LIVE_URL + newCase.Id, newCase.caseNumber) + 
                    ' has changed from: ' + oldOwner + ' to: ' + newOwner + '<br /><br /> Case Details:<br /> ' + newCase.description;
                
            }
            else
            {
                subject = 'The subject of the Case #' + newCase.caseNumber + ' has changed.';
                htmlBody = 'The subject of the Case #' + EmailClassRoadnet.createHyperLink(Util.LIVE_URL + newCase.Id, newCase.caseNumber) + 
                    ' has changed from: \"' + oldCase.Subject + '\" to: \"' + newCase.subject + '\"<br /><br /> Case Details:<br /> ' + newCase.description;
            }
            if (toEmailUserIds != null)
            {
                util.debug('num of toEmailUserids = ' + toEmailUserIds.size());
            }
            if (toEmailUserIds != null && toEmailUserIds.size() > 0)
            {
                EmailClassRoadnet.sendEmailInternalUsersAsync(
                    idSetToList(toEmailUserIds), subject, htmlbody, EmailClassRoadnet.convertHtmlToText(htmlbody), Util.FromAddressForCases);
            }
        }
    }
    /*
    public static boolean isCaseOwnerUser(Id ownerId)
    {
        integer userCount = [select count() from User where id =: ownerId];
        return (userCount > 0);
    }
    */
    public static decimal roundNearest5Minutes(decimal d)
    {
        //util.debug('Datetime passed into method = ' + theDate.format());
        if (d == null || d == 0)
        {
            return 0;
        }
        long minutes = (long)d; //theDate.Minute();
        
        while (Math.Mod(minutes, 5) != 0)
        {
            minutes++;
        }
         
        return minutes;
        
        //theDate = DateTime.NewInstance(theDate.year(), theDate.month(), theDate.day(), theDate.Hour(), Integer.valueOf(minutes), theDate.Second());
                
        //return theDate;
    }
    
    //private static User[] allactiveUsers = [select id, firstname, lastname, contactId from user where isactive = true order by lastname];
    Private static list<User> allactiveUsers = new List<User>();
    {
        for (List<User> Usera : [select id, firstname, lastname, contactId from user where isactive = true order by lastname])
        {
        	allactiveusers.addall(usera);
    	}
        //UPDATE allactiveusers;
        system.debug('### all Users count: '+ allactiveusers.size());
    }

    public static List<user> parseUsersFromTextField(string assistingTechs)
    {
        if (!isblank(assistingTechs))
        {
            //  so we have a string of users seperated by semicolons, Burk, Darrell; Carroll, Geavonna;
            List<string> userNames = ParseStringList(assistingTechs);//  parse teh name of the devices,  
            //User[] users = [select id, firstname, lastname from user where isactive = true order by lastname];
            List<user> usersToreturn = new list<user>();
            /*list<User> allactiveUsers = new List<User>();
        	for (List<User> Usera : [select id, firstname, lastname, contactId from user where isactive = true order by lastname])
        	{
        		allactiveusers.addall(usera);
    		}
        	UPDATE allactiveusers;*/
    
            for(string username : userNames)
            {                
                for(user u : allactiveUsers)
                {
                    string fullName = u.lastname + ', ' + u.firstname;
                    if (userName.contains(fullname))
                    {
                        usersToReturn.add(u);
                    }
                }
            }
            
            return usersToReturn;
           
        }
        return new list<user>();
    }
    
    public static List<string> parseStringList(string str)
    {
        list<string> theStrings=new List<string>();
        
        if (str==null)
        {
            return new list<string>();
        }
        else
        {   
            theStrings=(str.split(';', 0));
            //lets make sure there isn't blank items in the list and try to clear in any leading trailign whitespaces
            for (integer i=0; i<theStrings.size();i++)
            {
                theStrings[i]=theStrings[i].trim();
                if (theStrings[i]=='') theStrings.remove(i);
            }
        }
        set<string> stringsToReturn = new set<string>();
        
        for (integer i = 0; i < theStrings.size(); i++)
        {
            if (!stringsToReturn.contains(theStrings[i]))
            {
                stringsToReturn.add(theStrings[i]);
            }
        }
        list<string> listStrings = new list<string>();
        listStrings.addAll(stringsToReturn);
        return listStrings; 
    }
    public static string truncateString(string str, integer fieldMaxLength)
    {
        system.assert(str.length() > fieldMaxLength);
        string stringToReturn = str.substring(0, fieldMaxLength - 3);//  the last 3 chars on the end of the string will be ...
        stringToReturn += '...';
        return stringToReturn; 
    }
    public static List<Contact> getContactsOfAccount(id accountid, integer maxNumOfContacts)
    {
        //  requeyr the account looking for parent id
        Account tempAccount = [select id, parentid from account where id =: accountId];
        
        if (tempAccount != null)
        {
            List<Contact> childAccountContacts;
            List<contact> parentAccountContacts;
            List<Contact> contactsToReturn = new List<Contact>();
            
            try
            {
                childAccountContacts = [select id, name, firstname, lastname, title, inactive__c from contact where accountId =: tempAccount.id and inactive__c = false];
                if (tempAccount.ParentId != null)
                {
                    parentAccountContacts = [select id, name, firstname, lastname, title, inactive__c from contact where accountId =: tempAccount.ParentId and inactive__c = false];
                }
                if (childAccountContacts != null)
                {
                     contactsToReturn.addAll(childAccountContacts); 
                }
                if (parentAccountContacts != null && parentAccountContacts.size() > 0)
                {
                    contactsToReturn.addAll(parentAccountContacts);
                }
                return contactsToReturn;
            }
            catch(Exception e)
            {
                return new list<contact>();
            }
        }
        return new list<Contact>();
    }

    private static boolean isBlank(string str)
    {
        if (str == null)
        {
            return true;
        }
        else if (str.length() == 0)
        {
            return true;
        }
        return false;
        
    }
    
    public static boolean isCaseContactPortaluser(id contactid, List<User> portalUsers)
     {
        util.debug('checking if contact id ' + contactId + ' is poral user...');
         for (User us : portalUsers)
         {
             if (us.contactId == contactId)
             {
                 return true;
             }
             
         }
         return false;
         
     }
     
     
    //  **********  Test Methods  **********
   
}