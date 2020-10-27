public class AllCaseTriggerUtils
{
    Static User loggedInUser = CaseClassHelperClass.loggedInUser;
    public static list<Boolean> TISClosedList = new list<Boolean>();////determines whether the TIS record should be created with "Date time Out" as NOT NULL
    
/**************
               setLastModifiedDateTimeField Started
                                                    ********************/
    public static void setLastModifiedDateTimeField(List<Case> triggerCases)
    {
        // i was going to code this so that this requierd the cases in the before trigger to get the last modifiedby/last modeddate
        // but testing shows that values aren't set before the case is created so i have to do this back door like...
        // we will use the person logged in calling the trigger to be the last moded by and the current time as the time they made the change
        string loggedInUserName = userInfo.getFirstName() + ' ' + userInfo.getLastName();
        
        for(Case c : triggerCases)
        {
            c.Last_Modified_Date_Time__c = loggedInUserName + ', ' + adjustTimeToRoadnet(DateTime.Now()).format();
        }
    }    
    private static DateTime adjustTimeToRoadnet(Datetime caseLastModDAteTime)
    {
        if (userInfo.getName() == CaseTrigger_Global_Variable__c.getInstance('Email Agent').Value__c)
        {
            return caseLastModDateTime.addHours(3);
        }
        else
        {
            return caseLastModDateTime;
        }
    }
    
    
/**************
               prepopulateContactAndAccountIfEmail2Case Started
                                                                ********************/
    public static void prepopulateContactAndAccountIfEmail2Case(List<Case> newCases)
    {
        //  get a unique set of emails?  i dont know if there is any benefit on getting a unique set or just a list of them
        //  there is also the posiblity that more than one contact will be queried for one email 
        //  its ok if its a list i believe, i just tested this in a script and the same number of contacts were quereid without
        //  any excepion being thrown
        
        List<string> suppliedEmails = new List<string>();
        //Getting userId of 'Email Agent'(user)
        String emailAgentUserId = CaseTrigger_Global_Variable__c.getInstance('Email Agent UserId').Value__c;
        for(Case singleCase : newCases)
        {
            if(singleCase.SuppliedEmail != null && (singleCase.OwnerId == emailAgentUserId || UserInfo.getUserId() == emailAgentUserId))
            {
                suppliedEmails.Add(singleCase.SuppliedEmail);
            }
        }
        if (suppliedEmails.size() > 0)
        {
            List<Contact> contactsOfCases = [select id, name, email, phone, inactive__c, accountid, account.name from contact where 
                                             email in: suppliedEmails order by lastmodifieddate desc, accountid desc limit 10000];
            
            //  now scroll thru the cases, pulling out the (or mulitple) contacts and make the assignment
            if(contactsOfCases != null && contactsOfCases.size()>0)
            {
                for (Case singleCase : newCases)
                {
                    //  this will pull out the contact, if more than one contact, it will pull out the active and/or latest modified
                    Contact contactOfCase = findContactOfCase(contactsOfCases, singleCase.suppliedEmail);
                    
                    if (contactOfCase != null)
                    {
                        singleCase.ContactId = contactOfCase.id;
                        //  just did a quick test to see if the case email and phone (suppliedPHone) were set when assigning the account and contact
                        //  on my test email2case and it did not so i will those fields also, even though i feeel like suppliedphone should be system
                        //  populated, i feel like John might ask why that is not being populated also so lets just go ahead and do it
                        if (contactOfCase.email != null)
                        {
                            singleCase.Email__c = contactOfCase.email;
                        }
                        if (contactOfCase.Phone != null)
                        {
                            singleCase.SuppliedPhone = contactOfcase.phone;
                        }
                        if (contactOfCase.AccountId != null)
                        {
                            singleCase.AccountId = contactOfCase.AccountId;
                        }
                    }
                }
            }
        }
    }
    private static Contact findContactOfCase(List<Contact> contacts, string suppliedEmail)
    {       
        //  make a list because its possible we'll see more than one contact with the same email
        List<Contact> contactsToReturn = new List<Contact>();
        for (Contact singleContact : contacts)
        {
            if (singleContact.email == suppliedEmail)
            {
                contactsToReturn.Add(singleContact);
            }
        }
        if (contactsToReturn.size() == 0)
        {
            //  no matching contacts were found
            return null;
        }
        
        else if (contactsToReturn.size() == 1)
        {
            return contactsToReturn[0];
        }
        else
        {
            //  so if there are more than one contact, we need to check for activeness and which one was last modified
            //  the contact query above should have sorted these in lastmodified desc so that means the first on the list
            //  we be the latest modified, so we just need to find the first ont hat is active
            Contact latestActiveContact = findLatestActiveContact(contactsToReturn);
            
            if(latestActiveContact != null)
            {
                return latestActiveContact;
            }
            else//  couldnt find any active contact, so just returnt he latest modified
            {
                return contactsToReturn[0];
            }

        }
    }
    private static Contact findLatestActiveContact(List<Contact> contacts)
    {
        for (Contact singleContact : contacts )
        {
            if (!singleContact.inactive__c)
            {
                return singleContact;
            }
        }
        return null;
    }/******** prepopulateContactAndAccountIfEmail2Case End *********************/

    
/**************
               guessWorkEffort Started
                                       ********************/       
    public static void guessWorkEffort(List<Case> lstnewCases)
    {
        for(Case theCase:lstnewCases)
        {
            if (theCase.Assisting_techs__c != null)
            {
                List<User> assistantUsers = CaseEventExtension.parseUsersFromTextField(theCase.Assisting_techs__c);
                //  now we know ow many users we have that are assigend to assistant techs, we return the count * work effort in minutes
                if(assistantUsers == null || assistantUsers.size() == 0)
                {
                    theCase.total_work_effort__c = theCase.Work_Effort_In_Minutes__c;
                }
                else
                {
                    decimal workEffort = theCase.Work_Effort_In_Minutes__c == null ? 0 : theCase.Work_Effort_In_Minutes__c;
                    theCase.total_work_effort__c = workEffort * (assistantUsers.size() + 1);
                }
            }
            else
            {
                theCase.total_work_effort__c = theCase.Work_Effort_In_Minutes__c;
            }
            
            //Commented by Arindam, as the corresponding record type is not available now
            /*if(Schema.SObjectType.Case.getRecordTypeInfosByName().get('Rescue Pin Support') != null &&
               theCase.Recordtypeid == Schema.SObjectType.Case.getRecordTypeInfosByName().get('Rescue Pin Support').getRecordTypeId())
            {
                //  null this out so that when the user goes to edit the support case, they are forced to pick value
                theCase.Work_Effort_In_Minutes__c = null;
                
                if(Schema.SObjectType.Case.getRecordTypeInfosByName().get('Support') != null)
                    theCase.RecordtypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Support').getRecordTypeId();
            }*/           
            if(theCase.RecordtypeId == CaseTrigger_Global_Variable__c.getInstance('ProfessionalServices_RecordTypeId').Value__c)
            {
                //  the isvisibiliinselfservice portal flag should be false for all prof services cases
                theCase.IsVisibleInSelfService = false;
            }
        }
    }/******** guessWorkEffort End *********************/


/**************
               ChatterCaseToAccountFeed Started
                                               ********************/     
    public static void ChatterCaseToAccountFeed(List<Case> lstnewCases, Map<id,Case> mapoldCases)
    {
        List<FeedItem> posts = new List<FeedItem>();
        string bodyText;
        string userID = UserInfo.getUserId(); 
        string GVConnectionUser = CaseTrigger_Global_Variable__c.getInstance('GV ConnectionUser Id').Value__c;
        
        if(CaseUtils.chatterFeedUpdated == false && userID != GVConnectionUser)
        {
            for(Case newCase : lstnewCases) 
            {                                
                if((mapoldCases == null && newCase.AccountId != null) || 
                   (mapoldCases != null && newCase.AccountId != mapoldCases.get(newCase.id).AccountId))
                {
                    FeedItem AccountPost = new FeedItem ();
                    AccountPost.Body = 'Case Created: ' + newCase.CaseNumber + ' : '+newCase.Subject+'.';
                    AccountPost.ParentID = newCase.Accountid;
                    
                    posts.add(AccountPost);                  
                }        
            }
            
            try
            {
                if(posts.size() > 0)
                {
                    insert posts;
                    CaseUtils.chatterFeedUpdated = true;
                }
            } 
            catch(exception err)
            {
                err.getMessage();
            }
        }               
    }/********* ChatterCaseToAccountFeed End **********/

    
/**************
                 populateAccountTeam Started
                                              ********************/     
    public static void populateAccountTeam(List<Case> lsttriggerCases)
    {
        Set<id> setAccId = new Set<id>();
        for(Case singleCase :lsttriggerCases)
        {
            if(singleCase.AccountId != null)
                setAccId.add(singleCase.AccountId);
        }
        if(setAccId.size() > 0)
        {
            Map<id,Account> accountMap = new Map<id,Account>([Select Id, Name, CSR__c, Account_Manager__c, Inside_CSR__c from Account 
                                                              where id in :setAccId limit 50000]);
            
            for(Case objCase:lsttriggerCases)    
            {
                String strRecordType = CaseTrigger_Global_Variable__c.getInstance('EOX Return Record Type Name').Value__c;
                if(Schema.SObjectType.Case.getRecordTypeInfosById().get(objCase.RecordTypeId).getName()== strRecordType && objCase.AccountId!= null)   
                {
                    Account objAccount = accountMap.get(objCase.AccountId);
                    objCase.Customer_Service_Rep__c = objAccount.CSR__c;
                    objCase.Account_Manager__c = objAccount.Account_Manager__c;
                    objCase.Inside_CSR__c=objAccount.Inside_CSR__c;
                } 
            }
        }   
    }/********* populateAccountTeam End **********/    
    
    
/**************
               escalationCaseResponse Started
                                              ********************/      
    public static void escalationCaseResponse(Map<Id, Case> triggerOldMap, List<Case> newCases)
    {
        //  i want to modify this method just a bit so that it won't perform any queries below UNLESS it needs to operate
        //  on those cases, this means scrolling thru the cases passed in pulling out only those that have eng case attached to them,
        //  if that list of eng cases > 0 then the rest of the method will run        
        id engCaseRecordTypeid = SystemIds__c.getInstance().RecordTypeId_Case_Engineering__c;
        Map<Id,Case> caseMap = new Map<Id, Case>();
        
        for (Case c : newCases)
        {
            if (c.RecordTypeId == engCaseRecordTypeId)
            {
                caseMap.put(c.Id, c);
            }
        }
        
        //  this is here to save 4 queries if none of the cases passed into the trigger are eng cases
        if(caseMap.size() > 0)
        {                                                                                     
            Id strategicSupportQueueId = CaseTrigger_Global_Variable__c.getInstance('Strategic Support_QueueId').Value__c;                                      
            Id emailAgentUserId = CaseTrigger_Global_Variable__c.getInstance('Email Agent UserId').Value__c;
                                                                                                                                 
            //  lots of notes below, but i will summarize what this code below does,
            //  its job is to loop thru the support cases and change the case owner to either the case creator or the startegic support
            //  queue if the eng case jira status is closed/blocked/resolved.  guy had a bug where he was adding case comment to
            //  an eng case that was closed, and the associated call center case was also closed.  a validation rule prevents the case
            //  status from being = closed if the case owner is a queue... but the code below was changing the closed call center owner  to 
            //  stargetic support queue.  to remedy this, i passed into this method the trigger. oldmap so that the ownership change below occurs only
            //  AND ONLY IF the jira status is CHANGED to blocked/resolved/closed
            //  Change Owner of Engineering Case for certain Status updates
            
            for(Case engCase : caseMap.values())
            {
                if((String.valueOf(engCase.OwnerId).startsWith('00G')) && engCase.Business_Unit__c != CaseTrigger_Global_Variable__c.getInstance('Roadnet Business Unit').Value__c  && 
                   (engCase.JIRA_Status__c == CaseTrigger_Global_Variable__c.getInstance('Jira Status Resolved').Value__c || 
                    engCase.JIRA_Status__c == CaseTrigger_Global_Variable__c.getInstance('Jira Status Closed').Value__c || 
                    engCase.JIRA_Status__c == CaseTrigger_Global_Variable__c.getInstance('Jira Status Blocked').Value__c))
                {
                    engCase.OwnerId = engCase.CreatedById;
                }
            }
            
            Map<Id,Case> supportCaseMap;                                  
            supportCaseMap = new Map<Id,Case>([SELECT Id, OwnerId, CreatedById, Engineering_Case__c, Business_Unit__c, RecordType.name
                                               FROM Case WHERE Engineering_Case__c IN :caseMap.keyset()]); 
                                            
            for(Case loopCase : supportCaseMap.values())
            {
                loopCase.JIRA_Issue__c  = caseMap.get(loopCase.Engineering_Case__c).JIRA_Issue__c;
                loopCase.JIRA_Cloud_Issue__c = caseMap.get(loopCase.Engineering_Case__c).JIRA_Cloud_Issue__c;
                loopCase.JIRA_Status__c = caseMap.get(loopCase.Engineering_Case__c).JIRA_Status__c;
                loopCase.JIRA_Priority__c = caseMap.get(loopCase.Engineering_Case__c).JIRA_Priority__c;
                loopCase.JIRA_Severity__c = caseMap.get(loopCase.Engineering_Case__c).JIRA_Severity__c;
                
                if(loopcase.JIRA_Status__c == 'Open' || loopcase.JIRA_Status__c == 'In Progress' || loopcase.JIRA_Status__c == 'Ready For Testing' || loopcase.JIRA_Status__c == 'In Testing' || loopcase.JIRA_Status__c == 'Resolved' || loopcase.JIRA_Status__c == 'Closed')
                {
                loopCase.Fixed_in_version__c = caseMap.get(loopCase.Engineering_Case__c).Fixed_in_version__c;
                loopCase.Resolution_Notes__c = caseMap.get(loopCase.Engineering_Case__c).Resolution_Notes__c;
                }
                
                //  added by joseph hutchins
                //  when checking the eng case.jira_status__c, we need to check the case that is passed into the trigger and not the one required in this method
                //  this is because this method is called by the before update trigger and it wont contain the updated jira status unless this is called by the
                //  after update
                Case triggerCase = caseMap.get(loopCase.Engineering_case__c);
                Case triggerOldCase = triggerOldMap.get(loopCase.Engineering_case__c);
                
                //  this if block only changes the support case owner back to the oriinal if the eng case.jira_status is being changed to closed/resovled/blocked
                if(triggerCase != null && triggerOldCase != null && triggerCase.JIRA_Status__c != null)
                {
                    //  per case no 01758035, if eng caes tied to call center case is closed, we should reassign the case to the person who created
                    //  the case, unless it was email agent, then it is reassigned the ss queue
                    if((triggerOldCase.Jira_Status__c != triggerCase.Jira_status__c) &&
                       (triggerCase.Jira_Status__c.Contains(CaseTrigger_Global_Variable__c.getInstance('Jira Status Close').Value__c) || 
                        triggerCase.Jira_Status__c == CaseTrigger_Global_Variable__c.getInstance('Jira Status Resolved').Value__c || 
                        triggerCase.Jira_Status__c == CaseTrigger_Global_Variable__c.getInstance('Jira Status Blocked').Value__c))
                    {
                        if(loopCase.Business_Unit__c == CaseTrigger_Global_Variable__c.getInstance('Roadnet Business Unit').Value__c) 
                        {
                            string loopCaseCreatedById = loopCase.createdById;
                            //  eng case is blocked, reassign owner to the strategic support queue
                            if(//triggerCase.Jira_Status__c == CaseTrigger_Global_Variable__c.getInstance('Jira Status Blocked').Value__c && 
                               (loopCase.RecordType.name == CaseTrigger_Global_Variable__c.getInstance('Call Center Record Type Name').Value__c) || 
                               (loopCaseCreatedById.startsWith('00G') && loopCaseCreatedById != emailAgentUserId && loopCase.Status != 'Closed'))
                            {
                                loopCase.OwnerId = strategicSupportQueueId;
                            }
                           /* else
                            {
                                string loopCaseCreatedById = loopCase.createdById; // convert to string to use startswith method
                           
                                if(!loopCaseCreatedById.startsWith('00G') && loopCase.CreatedById != emailAgentUserId && loopCase.Status != 'Closed')
                                {
                                    //loopCase.OwnerId = loopCase.createdById;
                                    loopCase.Ownerid = strategicSupportQueueId;
                                }
                               else//  if its assigned to a queue or email agent, per john, will reassign to strategic support queue
                                {
                                    //  now, we still need to make sure the case status is NOT closed before we change the owner to a queue as this
                                    //  will fire off the validation rule if it is
                                    if(loopCase.Status != 'Closed')
                                    {
                                        loopCase.Ownerid = strategicSupportQueueId;
                                    }
                                }
                            }*/
                        }
                    }
                }                   
            }
            //  regardlesss what we did to the support case, we still need to update it 
            //  i (joseph hutchins) introduced a bug where it was only updating the case if the owner was changed but 
            //  all cases in this for loop are assigned the engcase.jira_status so we need to update all cases passed into the method
            if(supportCaseMap.size() > 0)
            {
                update supportCaseMap.values();
            }                      
        }
    }/******** escalationCaseResponse End *********************/

    
/**************
               populateJiraStatusFields Started
                                                ********************/      
    public static void populateJiraStatusFields(List<Case> lstnewCases)
    {       
        Set<id> engCaseIds = new Set<Id>();
        Id callCenterRecordTypeid = CaseTrigger_Global_Variable__c.getInstance('CallCenter_RecordTypeId').Value__c;
        
        for(Case c : lstnewCases)
        {
            if(c.Engineering_Case__c != null)
            {
                engCaseIds.add(c.Engineering_Case__c);              
            }
        }
        //  only perform the query if there are cases to actually query
        if(engCaseIds.size() > 0)
        {
            //  the way the engineering case stuff is setup, it is possible for an engineering case to have multiple call center cases pointing it
            Map<Id,Case> engCasesmap = new Map<Id,Case>([select id, jira_issue__c, jira_priority__c, jira_status__c, Status,
                                                         jira_tracking__c, jira_severity__c from Case where id in: engCaseIds]);

            for(Case c : lstnewCases)
            {
                if(c.Engineering_Case__c != null && engCasesmap.containsKey(c.Engineering_Case__c))
                {
                    c.Jira_Issue__c = engCasesmap.get(c.Engineering_Case__c).Jira_issue__c;
                    
                    if(engCasesmap.get(c.Engineering_Case__c).Status.contains('Close'))
                    {
                        c.Substatus__c = CaseTrigger_Global_Variable__c.getInstance('SubStatus Pending Customer').Value__c;
                    }
                    //  only for roadnet and call center cases with value in eng case field do we perform this for
                    if(c.Business_unit__c == CaseTrigger_Global_Variable__c.getInstance('Roadnet Business Unit').Value__c && c.RecordTypeId == callCenterRecordTypeid)
                    {
                        c.jira_priority__c = engCasesmap.get(c.Engineering_Case__c).Jira_Priority__c;
                        c.jira_status__c = engCasesmap.get(c.Engineering_Case__c).jira_status__c;
                        c.jira_tracking__c = engCasesmap.get(c.Engineering_Case__c).Jira_Tracking__c;
                        c.jira_severity__c = engCasesmap.get(c.Engineering_Case__c).Jira_Severity__c;
                    }
                }
            }
        }
    }/******** populateJiraStatusFields End *********************/
 
 
/**************
               validateWorkEffort Started
                                          ********************/      
    public static void validateWorkEffort(List<Case> lstnewCases, Map<Id, Case> mapoldCases)
    {
        //  so the idea is that case times will only be created on case updates, case event creation and close cases
        //  the logic here is the user edits a case and put a value in work effort field
        //  the caes before trigger creates a case time using the value set in the case's work effort field
        //  then the field is wiped
        for(Case newCase :lstnewCases)
        {   
            //Commented by arindam Laik, as the code is been replaced by validation rule
            if(!loggedInuser.Profile.Name.Contains('Customer Community') && CaseClassHelperClass.isCaseSupport(newCase.Recordtypeid))
            {
                /*if(mapoldCases.get(newCase.Id).Status != newCase.Status && newCase.Status == 'Closed' &&
                   isNullOrZero(newCase.Total_Work_Effort__c) &&     //  total work effort is blank
                   isNullOrZero(newCase.Work_Effort_In_Minutes__c))  //  the case close work effort in minutes is blank
                {
                    // replaced by 'Req_Work_effort_to_Close_Case' validation rule
                    //  the user is required to set the work effort on the case close screen before closing the case
                    newCase.Work_Effort_In_Minutes__c.addError('Cannot close case with 0 Total Work Effort.  Please place a non zero value in Work Effort In Minutes.');
                }*/
                
                // this is to prevent the work effort from being required when changing the case owner 
                if((newCase.Work_Effort_In_Minutes__c == 0) //  possible to create an event for a case whose work effort in minutes = 0
                    && mapoldCases.get(newCase.Id).OwnerId == newCase.OwnerId )
                {
                    // replaced by 'Work_Effort_can_not_be_zero' validation rule
                    //  since the work effort is now a NON Requeried field on the case object, we only do this check if the case
                    //  is not being closed...
                    if (newCase.Status != 'Closed')
                    {
                        newCase.Work_Effort_In_Minutes__c.addError('Please place a non zero value in Work Effort.');
                    } 
                }
                
                /*if(newCase.Work_Effort_in_minutes__c > 480)
                {
                    // replaced by 'Work_Effort_cant_be_more_than_480' validation rule
                    newCase.Work_Effort_in_minutes__c.addError('Work Effort value is too high.  Please specify a new value for work minutes.');
                }*/
            }
            
            if(CaseClassHelperClass.isCaseSupport(newCase.Recordtypeid) && newCase.Business_Unit__c == CaseTrigger_Global_Variable__c.getInstance('Roadnet Business Unit').Value__c)
            {
                //  so right now we have three RNA products. i have changed the ones in the sandbox and the live
                //  to be rna dispatching, rna routing, and rna tracking
                //  so what the code here will do is see if the selectd proudct is one of the three
                //  and if it is, it will change the cases product family to RNA
                if (newCase.Product_PL__c != null && newCase.Product_Pl__c.Contains('RNA'))
                {
                    newCase.Product_Family_PL__c = CaseTrigger_Global_Variable__c.getInstance('Roadnet Anywhere').Value__c;
                } 
            }
            
            if(newCase.RecordtypeId == CaseTrigger_Global_Variable__c.getInstance('ProfessionalServices_RecordTypeId').Value__c)
            {
                //  the isvisibiliinselfservice portal flag should be false for all prof services cases
                newCase.IsVisibleInSelfService = false;
            }
            
            //  if there is a differnce in case statuses (i.e. they have changed) and case is being closed
            if (mapoldCases.get(newCase.Id).status != newCase.status && newCase.status == 'Closed')
            {
                newcase.Closed_By__c = userInfo.getUserId();
            }
            
            assignCaseAge(newCase);
        }
    }
    private static boolean isNullOrZero(decimal d)
    {
        return (d == null || d == 0);
    }
    private static void assignCaseAge(Case c)
    {
        id bhId = SystemIds__c.getInstance().BusinessHoursId_Roadnet__c;       
        DateTime endDate;
        
        if (c.closedDate == null)
        {
            endDate = DateTime.now();
        }
        else
        {
            endDate = c.ClosedDate;
        }
        
        decimal ageInMilliSeconds = decimal.valueof(BusinessHours.diff(bhId, c.CreatedDate, enddate));         
        c.Case_Age__c = ageInMilliSeconds / 1000;      
    }/******** validateWorkEffort End *********************/
     
     
/**************
               ShareCaseVarRoadnet Started
                                          ********************/       
    public static void ShareCaseVarRoadnet(List<Case> lstnewCase)
    {
        if(!CaseShareForVarRoadnet.hasRunBefore)
        {
            try
            {
                CaseShareForVarRoadnet singleObject = new CaseShareForVarRoadnet();
                singleObject.CreateCustomSharingForVars(lstnewCase);
                
                CaseShareForVarRoadnet.hasRunBefore = true;
            }
            catch(Exception e)
            {
                util.debug('ERROR: ' + e.getMessage());
            }
        }
    }/******** ShareCaseVarRoadnet End *********************/
     

/**************
               SsupportCaseEmailAlerts Started
                                              ********************/      
    public static void supportCaseEmailAlerts(List<Case> lstnewCase, map<id,Case> mapOldCase)
    {
        boolean isSendingEmailsDisabled;
        Send_Trigger_Email_Alerts__c testObject = Send_Trigger_Email_Alerts__c.getInstance('Roadnet');
        
        if(testObject == null)
        {
            isSendingEmailsDisabled = true;
        } 
        else
        {    
            isSendingEmailsDisabled = testObject.isDisabled__c;
        }
         
        if(!isSendingEmailsDisabled)
        {
            handleCaseSubscriberEmailAlerts(lstnewCase, mapOldCase);
        }
        
        // customer community users don't have case times or work effort associated with them
        // piece of code has been moved to process builder(Case: Insert Case Time on Case creation)
        /*if(!loggedInuser.Profile.Name.Contains('Customer Community'))
        {
            List<Case> lstsupportCase = new List<Case>();
            for(Case singleCase :lstnewCase)
            {
                if(isCaseSupport(singleCase.recordtypeid)) 
                {
                    //  this needs to be in the insert after because the case id needs to be set for each case time that is created
                    //  unfortunately that means i cant swipe the field so i'll need to add logic to the case update
                    //  that checks if the field has changed, and if so, create the case items THEN it can swipe the data in the field
                    lstsupportCase.add(singleCase);
                }                
            }
            CaseEventExtension.createCaseTimeForCasesWorkEffort(lstsupportCase);
        }*/ 
    }
    private static void handleCaseSubscriberEmailAlerts(List<Case> lstnewCase, map<id,Case> mapOldCase)
    {
        //  this sends email alert to users in the case.email_alert_support field and the case's account.email_alert_support and the account owner
        //  if the case.account.email_alert_all_cases is set
        List<Case> roadnetSupportCasesBeingCreatedOrClosed = new List<Case>();
        
        for(Case singleCase :lstnewCase)
        {
            if((singleCase.Business_unit__c == CaseTrigger_Global_Variable__c.getInstance('Roadnet Business Unit').Value__c && isCaseSupport(singleCase.RecordtypeId)) &&
                (mapOldCase == null || 
                 (mapOldCase != null && (singleCase.status != mapOldCase.get(singleCase.id).status) && singleCase.status == 'Closed'))) 
            {
                //  case is getting created or closed, we are sending emails for that case
                roadnetSupportCasesBeingCreatedOrClosed.Add(singleCase);
            }
        }
        if(roadnetSupportCasesBeingCreatedOrClosed.size() > 0)
        {
            if(mapOldCase == null)
                CaseEventExtension.emailAlertSuppportCaseCreation(roadnetSupportCasesBeingCreatedOrClosed, 'Case Created');
            if(mapOldCase != null)
                CaseEventExtension.emailAlertSuppportCaseCreation(roadnetSupportCasesBeingCreatedOrClosed, 'Case Closure');
        }
    }
    private static boolean isCaseSupport(string recordtypeId)
    {   
        //  we so far have 4 different suppprt recordtypes, support, rescue pin support, call center, and engineering case
        return (recordTypeId == CaseTrigger_Global_Variable__c.getInstance('CallCenter_RecordTypeId').Value__c || 
                //recordTypeId == Schema.SObjectType.Case.getRecordTypeInfosByName().get('Rescue Pin Support').getRecordTypeId() ||   //record type do not exist
                //recordTypeId == Schema.SObjectType.Case.getRecordTypeInfosByName().get('Support').getRecordTypeId() ||              //record type do not exist
                recordTypeId == CaseTrigger_Global_Variable__c.getInstance('EngineeringCase_RecordTypeId').Value__c);
           
    }/******** supportCaseEmailAlerts End *********************/     
    

/**************
               autoJIRACallout Started
                                      ********************/
    public static void autoJIRACallout(Map<Id,Case> caseMap){//@description Automatically calls the Create/Update Jira button
        if(caseMap.size() == 1){
            for(Case loopCase : caseMap.values()){
                if((loopCase.JIRA_Issue__c != '' || loopCase.JIRA_Issue__c != null) && 
                   (loopCase.recordTypeId == SystemIds__c.getInstance().RecordTypeId_Case_Engineering__c)){
                    if (!Test.isRunningTest()) {
                        System.debug('Calling JIRA ----'+loopCase.JIRA_Issue__c);
                        JIRAConnectorWebserviceCallout.createIssue(loopCase.Id);
                    }
                }
            }
        }
    }/******** autoJIRACallout End *********************/  


/**************
               createCaseTimesAfterTrigger Started
                                                  ********************/ 
    //commented by Arindam Laik, we are achieving the same functionality in 'Case: Insert Case Time on Case updation' Process Builder   
    /*public static void createCaseTimesAfterTrigger(List<Case> lstnewCase)
    {
        List<Mibos_Case_Time__c> caseTimesToCreate = new List<Mibos_Case_Time__c>();
        
        Map<id,Case_Event__c> mapeventsOfCases=new Map<id,Case_Event__c>([select id, name, Assisting_Technician__c, case__c, time_spent__c 
                                                                         from case_event__c where case__c in: lstnewCase
                                                                         order by lastmodifieddate desc, case__c  limit 10000]);
                                             
        //  so... this should get called for two reasons: 1-case was edited/update 2-case event was inserted/updated
        //  the case event insertion/update updates the case.work_effort_in_minutes__c field and then this is supposed to create
        //  case times for that case event.
        for(Case singlecase :lstnewCase)
        {
            if(!isNullOrZero(singlecase.Work_Effort_In_Minutes__c))
            {
                boolean isCaseEventExist = false;
                boolean isAssistantTech = false;
                
                MIbos_Case_Time__c caseTimeForCaseEvent = new Mibos_Case_time__c();                   
                caseTimeForCaseEvent.Case__c = singlecase.id;
                caseTimeForCaseEvent.Owner__c = userInfo.getUserId();
                caseTimeForCaseEvent.work_effort__c = singlecase.work_effort_in_minutes__c;
                if(singlecase.Last_Case_Event__c != null && mapeventsOfCases.containsKey(singlecase.Last_Case_Event__c))
                {
                    caseTimeForCaseEvent.Case_Event__c = singlecase.Last_Case_Event__c;
                    isCaseEventExist = true;
                }
                if(singlecase.Last_Case_Event__c == null || isCaseEventExist == true)    
                {
                    caseTimesToCreate.add(caseTimeForCaseEvent);
                }
                
                MIbos_Case_Time__c caseTimeForCaseEventAssignTech = new Mibos_Case_time__c();                   
                caseTimeForCaseEventAssignTech.Case__c = singlecase.id;
                caseTimeForCaseEventAssignTech.work_effort__c = singlecase.work_effort_in_minutes__c;
                if(isCaseEventExist == true && mapeventsOfCases.get(singlecase.Last_Case_Event__c).Assisting_Technician__c != null)
                {
                    caseTimeForCaseEventAssignTech.Owner__c = mapeventsOfCases.get(singlecase.Last_Case_Event__c).Assisting_Technician__c;
                    caseTimeForCaseEventAssignTech.is_Assistant_Tech__c = true;
                    isAssistantTech = true;
                }
                else if(isCaseEventExist == false && singlecase.AssistingTech__c != null)
                {
                    caseTimeForCaseEventAssignTech.Owner__c = singlecase.AssistingTech__c;
                    caseTimeForCaseEventAssignTech.is_Assistant_Tech__c = true;
                    isAssistantTech = true;
                }               
                if(isAssistantTech == true)
                {
                    caseTimesToCreate.add(caseTimeForCaseEventAssignTech);
                }    
            }
        }
        if(caseTimesToCreate.size() > 0)
        {
            insert caseTimesToCreate;
        }                                      
    }*//******** createCaseTimesAfterTrigger End *********************/ 


/**************
               sendUpgradeCaseClosureEmail Started
                                                  ********************/   
    public static void sendUpgradeCaseClosureEmail(List<Case> lstnewCase, map<id,Case> mapoldCase)
    {
        //  we introduced a new fucntion for cases where you can convert a case to an upgrade opportunity
        //  those cases are autoclosed by the code... however we do not want the standard "case is closed" email to go out
        //  john has a template that is informtin the customer what's happening so we wnat to send that email instead 
        id orgWideEmail;
        if (Util.isRnEnvironment)
        {
            orgWideEmail = CaseTrigger_Global_Variable__c.getInstance('OrgWideEmail for Domestic Support').Value__c;//  pulled from the domestic support Survey Type  https://na1.salesforce.com/a0X30000001ao3m   i think its rts-support
        }
        else if (Util.isMibosEnvironment)
        {
            orgWideEmail = CaseTrigger_Global_Variable__c.getInstance('OrgWideEmail for Case Closure').Value__c;
        }
        
        List<EmailTemplate> et = [select id, name from EmailTemplate where name = 'Upgrade Request' ];
        
        if(et != null && et.get(0) != null)
        {   
            for(Case singleCase :lstnewCase)
            {        
                //  this code manages the domestic survey trigger:
                if((mapoldCase.get(singleCase.id).status != singleCase.status) && (singleCase.status == 'Closed') &&
                    singleCase.Is_Case_Being_Upgraded__c && 
                    singleCase.recordtypeid == CaseTrigger_Global_Variable__c.getInstance('CallCenter_RecordTypeId').Value__c)
                {
                    EmailClassRoadnet.EmailTemplateEx etx = new EmailClassRoadnet.EmailTemplateEx();
                    etx.whatId = singleCase.id;
                    etx.targetId = singleCase.contactId;
                    etx.templateId = et.get(0).id;
                    etx.orgwideEmailAddress = orgWideEmail;
                    etx.saveAsActivity = true;
                    EmailClassRoadnet.sendEmailsWithTemplate(new list<EmailClassRoadnet.EmailTemplateEx>{etx});
                }
            }
        }       
    }/******** sendUpgradeCaseClosureEmail End *********************/
    

/**************
               closeChildCases Started
                                      ********************/   
    public static void closeChildCases(List<Case> lstnewCase, map<id,Case> mapoldCase)
    {
        Map<id,Case> mapClosedCase = new Map<id,Case>();
        List<Case> lstchildCases;
        
        for(Case singleCase :lstnewCase)
        {        
            //  this code manages the domestic survey trigger:
            if((mapoldCase.get(singleCase.id).status != singleCase.status) && (singleCase.status == 'Closed') && 
                singleCase.recordtypeid == CaseTrigger_Global_Variable__c.getInstance('CallCenter_RecordTypeId').Value__c)
            {      
                mapClosedCase.put(singleCase.id, singleCase);   
            }
        }
                
        if(mapClosedCase.size()>0)
        { 
            //  only try to close call center cases
            lstchildCases = [select id, status, Substatus__c, parentid, parent.Substatus__c, ownerid from case where 
                             parentid in: mapClosedCase.keyset() and Status != 'Closed' and recordtype.name = :CaseTrigger_Global_Variable__c.getInstance('Call Center Record Type Name').Value__c];
        }
                   
        if(lstchildCases != null && lstchildCases.size() > 0)
        {
            //  also there is logic that prevents a case from being closed if it is in a queue... then we dont want to close it
            //  validatoin rule here: https://omnitracs.my.salesforce.com/03d500000008hJ9?setupid=CaseValidations
            
            List<Case> casesToUpdate = new List<Case>();
            
            for(Case singlecase :lstchildCases)
            {
                string caseOwnerId = singlecase.OwnerId;
                if(caseOwnerId != null && !caseOwnerId.startsWith('00G'))//  cannot close cases belonging to queue
                {
                    singlecase.Status = 'Closed';
                    singlecase.Substatus__c = singlecase.parent.Substatus__c;
                    
                    casesToUpdate.add(singlecase);
                }
            }
            
            if(casesToUpdate.size() > 0)
            {
                try
                {
                    update casesToUpdate;
                }
                catch(Exception e)
                {
                    system.debug('While attempting to closed child cases, error occured due to: ' + e.getMessage());
                }
            }
        }        
    }/******** closeChildCases End *********************/
    

    /**************
                   CaseValidationForNMCRequests Started
                                                       ********************/     
    public static void CaseValidationForNMCRequests(List<Case> lstnewCases)
    { 
        List<Case> lstNMCAccountIsUnique = new List<Case>();
        List<Case> lstNewAccUnitTypesIsUnique = new List<Case>();
        List<Case> lstUpdateAccUnitTypesIsUnique = new List<Case>();
        List<Case> lstTransferAccUnitTypesIsUnique = new List<Case>();
        Map<id, Account> mapparentAccount;
        
        for(Case singleCase :lstnewCases)
        {
            List<Id> lstAccountId = new List<Id>();
            if(singleCase.AccountId != null)
            {
                lstAccountId.add(singleCase.AccountId);   
            }
            
            if(lstAccountId.size() > 0)
                mapparentAccount = new Map<id, Account>([SELECT id, Contracts_Administrator__c FROM Account WHERE id IN :lstAccountId]);
        }
        for(Case singleCase :lstnewCases)
        {
            if(singleCase.RecordTypeId == CaseTrigger_Global_Variable__c.getInstance('NMCAccountRequest_RecordTypeId').Value__c || 
               singleCase.RecordTypeId == CaseTrigger_Global_Variable__c.getInstance('ClosedNMCAccountRequest_RecordTypeId').Value__c || 
               singleCase.RecordTypeId == CaseTrigger_Global_Variable__c.getInstance('SubmittedNMCAccountRequest_RecordType').Value__c)
            {     
                lstNMCAccountIsUnique.add(singleCase);
                CaseValidationUtils.validateDefaultUnitType(singleCase); 
                
                //Always validate Additional NMC Account info;  Previously only checked if this request was of a certain record type.
                //  If there is NO Add'l NMC Account info specified at all, then there will not be an error. 
                //  E.g. many of the layouts don't have Add'l NMC Account info, so there will be no errors from this method.
                CaseValidationUtils.validateAdditionalNMCAccount(singleCase); 
              
                //Copy the Contracts Administrator from the Account to this NMC Account Request (Case)
                if(singleCase.AccountId != null && mapparentAccount != null && mapparentAccount.size() >0 && 
                   mapparentAccount.containsKey(singleCase.AccountId))
                {                        
                    singleCase.Contracts_Administrator__c = mapparentAccount.get(singleCase.AccountId).Contracts_Administrator__c; 
                }
                 
                // 'Create' NMC Request Validations
                if(singleCase.Type_Level_2__c == QESConstants.CASE_TYPE_LEVEL2_NEW_NMC_ACCOUNT) 
                {
                    //CaseValidationUtils.validateDefaultNMCSetForInactive(singleCase);// commented by Arindam Laik, Code is replaced by two validation rule
                    CaseValidationUtils.validateNMCAndAddlNMCAccountUnit(singleCase);
                }
                //'Update' NMC Request Validations 
                //else if(singleCase.Type_Level_2__c == QESConstants.CASE_TYPE_LEVEL2_UPDATE_NMC_ACCOUNT)
                //{     
                    //CaseValidationUtils.checkIfNMCAccountNumberexists(singleCase);// commented by Arindam Laik, Code is replaced by 'Combination_of_Account_and_NMC_Account' validation rule
                    //CaseValidationUtils.validateDefaultNMCSetForInactive(singleCase);// commented by Arindam Laik, Code is replaced by two validation rule    
                //}
                 //'Transfer' NMC Request Validations 
                else if(singleCase.Type_Level_2__c == QESConstants.CASE_TYPE_LEVEL2_TRANSFER_NMC_ACCOUNT) 
                {
                    //CaseValidationUtils.validateDefaultNMCSetForInactive(singleCase);// commented by Arindam Laik, Code is replaced by two validation rule
                    //CaseValidationUtils.checkIfNMCAccountNumberexists(singleCase);// commented by Arindam Laik, Code is replaced by 'Combination_of_Account_and_NMC_Account' validation rule
                    // verify default unit type isn't already being used in the "transfer to" NMC accounts
                    CaseValidationUtils.validateNMCAndAddlNMCAccountUnit(singleCase);  
                }
             
                //'Completed' NMC Request Validations
                if((singleCase.Status == QESConstants.CASE_STATUS_CLOSED) && 
                   ((singleCase.Substatus__c == QESConstants.CASE_SUBSTATUS_COMPLETED) || 
                    (singleCase.Substatus__c == QESConstants.CASE_SUBSTATUS_RESOLVED))) 
                { 
                    //CaseValidationUtils.validateAddlNMCAccountIsDiffThanNMCAccount(singleCase);// commented by Arindam Laik, Code is replaced by 'Validate_NMC_Account_Number_Closed_Case' validation rule   
                    //CaseValidationUtils.validateDefaultNMCAcccountSelected(singleCase);// commented by Arindam Laik, Code is replaced by 'Default_NMC_Account_should_Not_Blank' validation rule            
    
                    if(singleCase.Type_Level_2__c == QESConstants.CASE_TYPE_LEVEL2_NEW_NMC_ACCOUNT)
                    {
                        //lstNMCAccountIsUnique.add(singleCase);
                        lstNewAccUnitTypesIsUnique.add(singleCase);
                        //CaseValidationUtils.checkIfNMCAccountIsUnique(singleCase);
                        //CaseValidationUtils.validateAddlNMCAccountIsUnique(singleCase);                     
                        //CaseValidationUtils.validateUnitTypesNotAlreadyExists(singleCase, singleCase.AccountId);
                    } 
                    else if(singleCase.Type_Level_2__c == QESConstants.CASE_TYPE_LEVEL2_UPDATE_NMC_ACCOUNT)
                    {  
                        lstUpdateAccUnitTypesIsUnique.add(singleCase);
                        //CaseValidationUtils.validateUnitTypesNotAlreadyExists(singleCase, singleCase.AccountId);
                    } 
                    else if(singleCase.Type_Level_2__c == QESConstants.CASE_TYPE_LEVEL2_TRANSFER_NMC_ACCOUNT)
                    {
                        lstTransferAccUnitTypesIsUnique.add(singleCase);
                        //CaseValidationUtils.validateUnitTypesNotAlreadyExists(singleCase, singleCase.Transfer_to_Account__c);
                    }
                }
            }        
        }
            
        if(lstNMCAccountIsUnique.size() > 0)
        {
            CaseValidationUtils.checkIfNMCAccountIsUnique(lstNMCAccountIsUnique);
            CaseValidationUtils.validateAddlNMCAccountIsUnique(lstNMCAccountIsUnique);
        }
        if(lstNewAccUnitTypesIsUnique.size() > 0)
            CaseValidationUtils.validateUnitTypesNotAlreadyExists(lstNewAccUnitTypesIsUnique, false);
        if(lstUpdateAccUnitTypesIsUnique.size() > 0)
            CaseValidationUtils.validateUnitTypesNotAlreadyExists(lstUpdateAccUnitTypesIsUnique, false);
        if(lstTransferAccUnitTypesIsUnique.size() > 0)
            CaseValidationUtils.validateUnitTypesNotAlreadyExists(lstTransferAccUnitTypesIsUnique, true);
                
    }/************ CaseValidationForNMCRequests End *********************/
    
    
/**************
               populateStatusAndQueueForTISAfterInsert Started
                                                              ********************/     
    public static void populateStatusAndQueueForTISAfterInsert(List<Case> lsttriggerCases)
    {
        String result;
        for (Case csnew :lsttriggerCases)
        {
            String OwnerName= '';
            if(csnew.status != null)
            {
                result = CreateTIS.CreateNewTISRecord('Case',csnew.Id, 'Status',csnew.status, null);
            }
            if(csnew.Queue__c != null)
            {
                result = CreateTIS.CreateNewTISRecord('Case',csnew.Id, 'Queue',csnew.Queue__c, null);
            }
        }
        CreateTIS.setInsertCounter();
    }/******** populateStatusAndQueueForTISAfterInsert End *********************/


/**************
               populateStatusAndQueueForTISAfterUpdate Started
                                                              ********************/     
    public static void populateStatusAndQueueForTISAfterUpdate(List<Case> lstOldTriggerCases,List<Case> lstNewTriggerCases)
    {
        
        list<String> CaseList = new list<String>();
        list<String> CaseOldStateList = new list<String>();
        list<String> CaseNewStateList = new list<String>();
        list<String> StateNameList = new list<String>();
        //list<Boolean> TISClosedList = new list<Boolean>();////determines whether the TIS record should be created with "Date time Out" as NOT NULL
        list<boolean> InsertNewRecordsList = new list<boolean>();    
        
        for(integer i = 0; i < lstNewTriggerCases.size(); ++i)
        {
            if (lstNewTriggerCases[i].status != lstOldTriggerCases[i].status)
            {
                CaseList.add(lstNewTriggerCases[i].Id);
                CaseOldStateList.add(lstOldTriggerCases[i].status);
                CaseNewStateList.add(lstNewTriggerCases[i].status);
                StateNameList.add('Status');
                
                if(lstNewTriggerCases[i].status == 'Closed')
                {
                        TISClosedList.add(true);
                }else
                {
                    TISClosedList.add(false);
                }
                if(CreateTIS.getInsertCounter() ==1)
                {
                    
                    InsertNewRecordsList.add(true);
                }
                else if(CreateTIS.getUpdateCounter() == 0)
                {
                    CreateTIS.CaseStatusMap.put(lstNewTriggerCases[i].Id,lstNewTriggerCases[i].status);
                    if(lstOldTriggerCases[i].status == 'Closed')
                    {
                        InsertNewRecordsList.add(true);
                    }else
                    {
                        InsertNewRecordsList.add(false);
                    }
                }
                if((CreateTIS.getUpdateCounter() == 1 && CreateTIS.CaseStatusMap.get(lstNewTriggerCases[i].Id) != lstNewTriggerCases[i].status))
                {
                    if(lstOldTriggerCases[i].status == 'Closed')
                    {
                        InsertNewRecordsList.add(true);
                    }else
                    {
                        InsertNewRecordsList.add(false);
                    }
                }
            }
            if ((lstNewTriggerCases[i].Queue__c != lstOldTriggerCases[i].Queue__c) || ((lstNewTriggerCases[i].status != lstOldTriggerCases[i].status) && lstOldTriggerCases[i].status == 'Closed' ))
            {
                //Boolean b1 = (lstNewTriggerCases[i].Queue__c != lstOldTriggerCases[i].Queue__c);
                CaseList.add(lstNewTriggerCases[i].Id);
                CaseOldStateList.add(lstOldTriggerCases[i].Queue__c);
                CaseNewStateList.add(lstNewTriggerCases[i].Queue__c);
                StateNameList.add('Queue');
                TISClosedList.add(false);
                if(CreateTIS.getInsertCounter() ==1)
                {
                    InsertNewRecordsList.add(true);
                }
                else if(CreateTIS.getUpdateCounter() == 0)
                {
                    CreateTIS.CaseCurrentMap.put(lstNewTriggerCases[i].Id,lstNewTriggerCases[i].Queue__c);
                    if(lstOldTriggerCases[i].status == 'Closed' || (lstOldTriggerCases[i].Queue__c == null && lstNewTriggerCases[i].Queue__c != null))
                    {
                        InsertNewRecordsList.add(true);
                    }
                    else
                    {
                        InsertNewRecordsList.add(false);
                    }
                }
                if(CreateTIS.getUpdateCounter() == 1 && (CreateTIS.CaseCurrentMap.get(lstNewTriggerCases[i].Id) != lstNewTriggerCases[i].Queue__c))
                {
                    if(lstOldTriggerCases[i].status == 'Closed')
                    {
                        InsertNewRecordsList.add(true);
                    }
                    else
                    {
                        InsertNewRecordsList.add(false);
                    }
                }
            }
        }///for loop
        if (!CaseList.isEmpty() && (CaseList.size()==InsertNewRecordsList.size()))
        {
           CreateTIS.UpdateTISRecords('Case',CaseList, CaseOldStateList, CaseNewStateList, null, StateNameList, InsertNewRecordsList, TISClosedList);
        }
        if(CreateTIS.getInsertCounter() ==1) 
            CreateTIS.setInsertCounter();
        CreateTIS.setUpdateCounter();
        
    }/******** populateStatusAndQueueForTISAfterUpdate End *********************/
    

/**************
               populateQueueiQCases Started
                                           ********************/     
    public static void populateQueueiQCases(List<Case> lstNewTriggerCases)
    {
         for (Case CaseObj :lstNewTriggerCases)
        {
            if((CaseObj.RecordTypeId == CaseTrigger_Global_Variable__c.getInstance('CallCenter_RecordTypeId').Value__c
              || CaseObj.RecordTypeId == CaseTrigger_Global_Variable__c.getInstance('EmailGeneratedCases_RecordTypeId').Value__c)
              //|| CaseObj.RecordTypeId == Schema.SObjectType.Case.getRecordTypeInfosByName().get('Email-iQ OV Requests').getRecordTypeId()//record type not exist
              && CaseObj.Origin == QESConstants.CASE_CASE_ORIGIN                
              && CaseUtils.checkIfIQCaseToBeAutoAssigned(CaseObj.Subject.toLowerCase().trim()))
               
            {
               CaseObj.Queue__c = CaseTrigger_Global_Variable__c.getInstance('Populate Queue Field CS').Value__c;
            }
        }
    }/******** populateQueueiQCases End *********************/


/**************
               populateOwneriQCases Started
                                           ********************/     
    public static void populateOwneriQCases(List<Case> lstNewTriggerCases)
    {
        try{
        map<Id, String> mapCaseCustId = new map<Id, String>();// to hold the value of CustID and the Case
        Boolean EvaluationNotificationCSR;

        for (Case CaseObj :lstNewTriggerCases)
        {   
            //CSR needs to be notified for Evaluation Notifications generated by iQ. The below IF block checks for Email Generated Cases related to Evaluation notfications
            EvaluationNotificationCSR = false;
            if(CaseObj.RecordTypeId == CaseTrigger_Global_Variable__c.getInstance('EmailGeneratedCases_RecordTypeId').Value__c
              &&(CaseObj.Subject.toLowerCase().trim()==CaseTrigger_Global_Variable__c.getInstance('evaluation expired').Value__c
                ||CaseObj.Subject.toLowerCase().trim()==CaseTrigger_Global_Variable__c.getInstance('evaluation expiring').Value__c
                ||CaseObj.Subject.toLowerCase().trim()==CaseTrigger_Global_Variable__c.getInstance('evaluation extended').Value__c)
              )
            {
                EvaluationNotificationCSR = true;  
            }
                       
            if((CaseObj.RecordTypeId == CaseTrigger_Global_Variable__c.getInstance('CallCenter_RecordTypeId').Value__c) 
              || (EvaluationNotificationCSR == true) && CaseObj.Origin == QESConstants.CASE_CASE_ORIGIN && 
                 CaseUtils.checkIfIQCaseToBeAutoAssigned(CaseObj.Subject.toLowerCase().trim())
              )
            {
                Boolean b =CaseUtils.checkIfIQCaseToBeAutoAssigned(CaseObj.Subject.toLowerCase().trim());

                if(TRUE != CaseObj.Auto_Assigned__c ) 
                {                    
                    if(CaseObj.Description != null)
                    {
                        String custId;              
                        String caseDescLC = CaseObj.Description.toLowerCase();
                        String caseDesc = CaseObj.Description;
                        if(CaseUtils.checkIfIQCaseToBeAssignedToCSR(CaseObj.Subject.toLowerCase().trim()))
                        {
                            if(caseDescLC.indexof('cust id') != -1)
                            {
                                Integer start_index = caseDescLC.indexof('cust id');
                                String subDesc = caseDesc.substring(start_index);
                                custid = subDesc.substring(subDesc.indexof(':')+1,subDesc.indexof(']')).trim();
                                mapCaseCustId.put(CaseObj.Id, custid);
                            }                            
                            if(caseDescLC.indexof('app') != -1)
                            {
                                Integer start_index = caseDescLC.indexof('app');
                                String subDesc = caseDesc.substring(start_index);
                                String app = subDesc.substring(subDesc.indexof(':')+1,subDesc.indexof(']')).trim();
                                caseObj.Eval_Application__c = app;
                                caseObj.Send_Eval_Notification__c = true;
                            }
                            if(caseDescLC.indexof('start date') != -1)
                            {
                                Integer start_index = caseDescLC.indexof('start date');
                                String subDesc = caseDesc.substring(start_index);
                                String startDate = subDesc.substring(subDesc.indexof(':')+1,subDesc.indexof(']')).trim();
                                caseObj.Eval_Start_Date__c = startDate;
                            }
                            if(caseDescLC.indexof('end date') != -1)
                            {
                                Integer start_index = caseDescLC.indexof('end date');
                                String subDesc = caseDesc.substring(start_index);
                                String endDate = subDesc.substring(subDesc.indexof(':')+1,subDesc.indexof(']')).trim();
                                caseObj.Eval_End_Date__c = endDate;
                            }
                            if(caseDescLC.indexof('user') != -1)
                            {
                                Integer start_index = caseDescLC.indexof('user');
                                String subDesc = caseDesc.substring(start_index);
                                String extendedBy = subDesc.substring(subDesc.indexof(':')+1,subDesc.indexof(']')).trim();
                                caseObj.Eval_Extended_By__c = extendedBy;
                            }
                        }
                        else if(CaseObj.Subject.toLowerCase().trim().contains('reporting services access requested'))
                        {
                            if(caseDesc.indexof('Customer ID') !=-1){
                                Integer start_index = caseDesc.indexof('Customer ID');
                                String subDesc = caseDesc.substring(start_index);
                                custid = (subDesc.substring(subDesc.indexof(':')+3,subDesc.indexof('\n'))).trim();
                                mapCaseCustId.put(CaseObj.Id, custid);
                            }   
                        }
                    }
                    
                    CaseObj.Auto_Assigned__c = TRUE;                    
                }  
            } 
        }
        
        Map<String, Account> mapOfAccounts = new Map<String, Account>();
        for(Account acc : [Select Id,Name,CSR__c, Inside_CSR__c  ,Account_Manager__c, QWBS_Cust_ID__c  from Account where QWBS_Cust_ID__c IN : mapCaseCustId.Values() limit 500])
        {
            mapOfAccounts.put(acc.QWBS_Cust_ID__c,acc);
        }
        for(Case CaseRecord : lstNewTriggerCases)
        {
            Account relAcc;
            if(mapCaseCustId.containsKey(CaseRecord.id))
            relAcc = mapOfAccounts.get(mapCaseCustId.get(CaseRecord.id));
            
            if(relAcc != null)
            {
                CaseRecord.Customer_Service_Rep__c = relAcc.CSR__c;
                CaseRecord.Account_Manager__c = relAcc.Account_Manager__c;
                CaseRecord.Inside_CSR__c= relAcc.Inside_CSR__c;
             // CaseRecord.ServiceSource_Rep__c = relAcc.ServiceSource_Rep__c;
            }
        }   
       
        // changeOwner() should be called only once 
        if(!QESConstants.inFutureContext)        
        {
            if(!(mapCaseCustId.isEmpty()))
            {
                CaseUtils.changeOwner(mapCaseCustId);
            }
        }
        }
        catch(exception e)
        {
            System.debug('Error:' + e.getMessage());
        }
    }/******** populateOwneriQCases End *********************/
    public static void removeHTMLMarkupFromSprint(List<Case> newTrig){
        for(Case c: newTrig){
            if(c.Sprint__c != null){
                List<Case> caseToUpdate = new List<Case>();
                //String htmlRemovalRegex = '.*?Name=(.*?),startDate.*?';
                String string1 = c.Sprint__c;
                String string2 = string1.replaceAll(',startDate.*?name=', ',');
                string2 = string2.replaceAll('.*name=', '');
                string2 = string2.replaceAll(',startDate.*', '');
                c.Sprint__c = string2;
                caseToUpdate.add(c);

            }
        }
    }
    
    /**** Assign case owner back to the Logged in user, if the "Assign to Me" check box is checked in Closed Case page*****/
    public static void AssignCaseToClosedCases(Map<Id, Case> triggerOldMap, List<Case> newCases)
    {
        for (Case newCase :newCases)
        {
            Case oldCase = triggerOldMap.get(newCase.Id);
            if(oldCase.Assign_To_Me__c != newCase.Assign_To_Me__c && newCase.Assign_To_Me__c && newCase.Business_Unit__c == 'Roadnet' && newCase.Status == 'Closed'){
                newCase.OwnerId = UserInfo.getUserId();
            }
        }
    }
}