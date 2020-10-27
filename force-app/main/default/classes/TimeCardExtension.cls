/*******************************************************************************
 * File:  TimeCardExtension.cls
 * Date:  December 18, 2012
 * Author:  Joseph Hutchins
 *
 *  Modification By Abhishek Dey
 *    Date : 11/25/2015
 *    Details : Added 'Total Time' column in VF page to represent a summation of 'Total TimeCard Time' and 'Total Case Time'. Logic provided.
 *
 * The use, disclosure, reproduction, modification, transfer, or transmittal of
 * this work for any purpose in any form or by any means without the written 
 * permission of United Parcel Service is strictly prohibited.
 *
 * Confidential, unpublished property of United Parcel Service.
 * Use and distribution limited solely to authorized personnel.
 *
 * Copyright 2009, UPS Logistics Technologies, Inc.  All rights reserved.
 *  *******************************************************************************/
public with sharing class TimeCardExtension
{
    public TimeCardExtension()
    {
        timeCardForDateLookUponly = new Time_Card__c();
        timeCardDetailsForDateLookupOnly = new Time_Card_Details__c();
        
        //  default the weekbegin date to this sunday (this was defauling to friday for some reason but i checked the code and its supposed to be startofweek)
        timeCardForDateLookupOnly.Week_Begin__c = Date.Today().toStartOfWeek();//.addDays(5);
        //  the week begin selection should default to begining of todays week if the time card's week begin/url week begin is null
        //  otherwise it should default to the time cards 
       
       //  test url: https://omnitracs--dev.cs13.my.salesforce.com/apex/TimeCardPage?sfdc.tabName=01rW00000004b9b&timeCardId=a8gW00000008PJu
       map<string, string> urlParam = ApexPages.currentPage().getParameters();
       util.debug('urlParam size= ' + urlParam == null ? 0 : urlParam.size());
       id timeCardIdUrlParam = urlParam.get('timeCardId');
       if (timeCardIdUrlParam != null)
       {
            timeCard = queryTimeCard(timeCardIdUrlParam);
            if (timeCard != null)
            {
                selectedCSSupport = timeCard.User__c;// prepoulate this if a the user is a lead
                
            }
       }
       else
        {
               
           //  if the user that is logged in is a lead, they'll need to select a user first, however, we cannot use a classes
           //  getter in the class constructor so for now, we'll just query the time card of the lead which will probably not exists
           timeCard = queryTimeCard(userInfo.getUserId(), timeCardForDateLookUpOnly.Week_Begin__c);
        }
           
       //  query time card details of the time card, should be 7 rows
       if (timeCard != null)
       {
            //showNoTimeCardSection = false;
            //  so the idea here is that if we konw the week the user is looking at, actually scratch that
            //  assuming the time card always has 7 time card detail records, then we just query the time card details
            //  that point to the time card in context, in order of date
          oldTimeCard = timeCard.clone(false, false);//  used to see if changes were made before user changes cs support or week begin
          queryTimeCardDetails();
          timeCardForDateLookupOnly.Week_Begin__c = timeCard.Week_Begin__c;
          timeCardDetailsForDateLookUpOnly.Date__c = timeCard.week_Begin__c;
        
        }
        else
        {
            //  if user selects a week where a time card does not exist, we will give him option to create one
            //timeCard = new Time_Card__c();
          //  showNoTimeCardSection = true;
            oldTimeCard = new Time_Card__c();
            m_timeCardDetails = new List<Time_Card_Details__c>();
        }
        
        showDidTimeCardChangeDialog = false;
        
    }
    
    public boolean isUserApartOfSupport
    {
        get
        {
            return true;
        }
    }
    public boolean isDebug
    {
        get
        {
            return userinfo.getLastName() == 'Hutchins';
        }
    }
    public boolean showNoTimeCardSection
    {
        get
        {
            return TimeCard == null;
        }
    }
    public boolean showDidTimeCardChangeDialog{get;set;}
    

    
    public Time_Card__c timeCard{get;set;}
    private Time_Card__c oldTimeCard{get;set;}
    
    public Time_Card__c timeCardForDateLookUponly{get;set;}
    public Time_Card_Details__c timeCardDetailsForDateLookupOnly{get;set;}
    public string selectedCSSupport{get;set;}
    
    public boolean showRejectedReasonInputField
    {
        get
        {
            //  the rejection reason should only be a inputfield if the user is a lead and the changed the status to Rejected
            return isLead && timeCard.Submit_Status__c == 'Rejected';
        }
    }

    public List<SelectOption> csSupportMembers
    {
        get
        {
            if (csSupportMembers == null)
            {
                csSupportMembers = new List<SelectOption>();
                
                //  now that the case team exists, need to  query case teams
                //  get the bu of current logged in person (if they are a lead) and query the case teams of that business unit
                if (!isLead)
                {
                    csSupportMembers.add(new SelectOption('--None--', '--None--'));
                }
                else
                {
                     util.debug('logged In User business unit: ' + loggedInUser.business_unit__c);
                     //  i think we need two queries here, one is to see if logged in user is roadnet, reason being, john is mananger of all of support
                     //  but zach is a mananger and so is colleen so if the logged in user is a roadnet business unit user then we'll query for 
                     //  fornately, john, zach and colleen share the same profile so we can check that
                     
                     List<Case_Team__c> caseTeamsOfBu;
                     
                     if (loggedInUser.profileid != null &&
                        loggedInUser.Profile.name == 'CS Lead John')
                     {
                        caseTeamsOfBu = [select id, business_unit__c, group_name__c, user__r.name, user__c from Case_TEam__c 
                        where 
                         (Lead__c =: johnWajerId OR Lead__c =: zachEvansId OR Lead__c =: colleenWatsonId)
                         order by user__r.lastname ];
                        
                     }
                     else if (loggedInUser.profileid != null &&
                        loggedInUser.Profile.name == 'System Administrator')
                     {
                        //  query all
                        caseTeamsOfBu = [select id, business_unit__c, group_name__c, user__r.name, user__c from Case_TEam__c 
                         order by user__r.lastname ];
                     }
                     else//  query only the records that belong to that manager
                     {
                        caseTeamsOfBu = [select id, business_unit__c, group_name__c, user__r.name, user__c from Case_TEam__c 
                        where 
                         Lead__c =: loggedInUser.id
                         order by user__r.lastname ]; 
                     }
                     
                     csSupportMembers.add(new SelectOption('--None--', '--None--'));
                    caseTeamsOfBu.sort();
                    for (Case_Team__c ct : caseTeamsOfBu)
                    {
                        csSupportMembers.add(new SelectOption(ct.user__c, ct.user__r.name));
                    }
                }
            }
            return csSupportMembers;
            
        }
        set;
    }
    private List<Time_Card_Details__c> m_timeCardDetails;
    //private List<Time_Card_Details__c> m_oldTimeCardDetails;
    
    public List<Tcdex> tableRows{get;set;}
    

    public boolean showSubmitbutton 
    {
        get
        {
             return timeCard.Submit_Status__c == null || timeCard.Submit_Status__c == 'Not Submitted' || timeCard.Submit_Status__c == 'Rejected';
        }   
    }

    public string submittedDate
    {
        get
        {
            if (timeCard != null)
            {
                if (timeCard.Submit_Date__c != null)
                {
                  return timeCard.Submit_Date__c.format();
                }
            }
            return null;
        }
    }
    public string approvedDate
    {
        get
        {
            if (timeCard != null)
            {
                if (timeCard.Approval_Date__c != null)
                {
                  return timeCard.Approval_Date__c.format();
                }
            }
            return null;
        }
    }
    public string rejectedDate
    {
        get
        {
            if (timeCard != null)
            {
                if (timeCard.Reject_Date__c != null)
                {
                  return timeCard.Reject_Date__c.format();
                }
            }
            return null;
        }
    }

    public string returnUrl
    {
        get
        {
            return apexPages.currentPage().getParameters().get('retURL');
        }
    }

    private User loggedINUser
    {
        get
        {
            if (loggedInUser == null)
            {
                loggedInuser = [select id, name, profileid, profile.name, business_unit__c from user where id =: userInfo.getUserid()];
            }
            return loggedInuser;
        }
        set;
    } 
    public boolean isLead
    {
        get
        {
            //  was informed late that pablo and manuel are leads and they should be able to approve time cards
            //  i cant use the profile name as they have Call Center User which is the same as what non leads have so i need to hardocde they names for now
            return isCustomerSupportLead(loggedInUser.Profile.Name) ||
                loggedInUser.name == 'Pablo Morales' ||
                loggedInUser.name == 'Manuel Isaac Valencia Sotelo';
                
            
            
        }
    }
    public static boolean isCustomerSupportLead(string profileName)
    {
        //  the list of call center managers and members provided by joe ohr has showed that all omnitracs support manaers
        //  have profile of "Call Center Manager", that leaves our manaement team which would be:
        //   Zach, Colleen, and John (CS Lead John) of course
        if (profileName == null)
        {
            return false;
        }
        
        set<string> managementProfileNames  = Call_Center_Manager__c.getAll().keySet();
        
        for (string str : managementProfileNames)
        {
            if (profileName == str)
            {
                return true;
            }   
        }
        return false;
    }
    
    public Date weekBegin
    {
        get
        {
            //  begin date should be sunday, end date = saturday
            if (timeCardForDateLookupOnly.Week_Begin__c != null)
            {
                return timeCardForDateLookupOnly.Week_Begin__c.ToStartOfWeek();
            }
            return null;
        }
    } 
    public Date weekEnd
    {
        get
        {
            if (weekBegin == null)
            {
                return null;
            }
            else
            {
                return weekBegin.addDays(6);
            }
        }
    }

    public PageReference verifyUserIsApartOfCaseTeam()
    {
        //  security to the page will be set by the vf page security but just in case a non support user
        //  gets access to the page, we at the very min want to check that the user is on a case team before we allow viewing
        //  same goes for the time card page
        Case_Team__c tempCaseTeam;
        try
        {
            //  need to check if user has case team record OR is  alead on a case team recrod
           tempCaseTeam = [select id from Case_Team__c where
                (user__c =: userInfo.getUserId() OR lead__c =: userInfo.getUserId()) 
                limit 1];
        }
        catch(Exception e)
        {
            
        }
        if (tempCaseTeam != null)
        {
           return null;
        }
        else
        {
            return Page.InsufficientPrivileges;
        }
    }
    
    public PageReference csSupportPicklistOnChange()
    {
        manageshowDidTimeCardChangeDialog();
        
        util.debug('csSupportPicklistOnChange method called.  userIdToPassIntoQueryMethod:' + userIdToPassIntoQueryMethod + ' weekbegin: ' + weekBegin);
        //  so if the user is a lead, he has the ability to select WHOSE time card he views
        //  if the csSelectedSuport has  value, we are going to query the time card
        if (userIdToPassIntoQueryMethod == null)
        {
           //  so if the user has selected --none-- as the selected cs support membe,r we need to add error
           ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Please select a valid cs support member'));
           return null;
        }
        else
        {
            
            //  query the time card for the selected user and date
            timeCard = queryTimeCard(userIdToPassIntoQueryMethod, weekBegin);
            queryTimeCardDetails();
            if (timeCard != null)
            {
              //showNoTimeCardSection  = false;
            }
            else
            {
                //showNoTimeCardSection = true;
            }
            return null;
        }
        
    }
    private Id johnWajerId
    {
        //  will convert these into custom settings at later time >_<
        get
        {
            User u;
            try
            {
               u = [select id, name from User where name = 'John Wajer' limit 1];
               return u.id;
            }
            catch(Exception e)
            {
                return null;
            }
        }
    }
    private Id zachEvansId
    {
        //  will convert these into custom settings at later time >_<
        get
        {
            User u;
            try
            {
               u = [select id, name from User where name = 'Zach Evans' limit 1];
               return u.id;
            }
            catch(Exception e)
            {
                return null;
            }
        }
    }
    private Id colleenWatsonId
    {
        //  will convert these into custom settings at later time >_<
        get
        {
            User u;
            try
            {
               u = [select id, name from User where name = 'Colleen Watson' limit 1];
               return u.id;
            }
            catch(Exception e)
            {
                return null;
            }
        }
    }
    
    private PageReference createTimeCardDetails()
    {
        //  the idea behind this button is to create 7 time card details all prepopulated fields
        //  the user can edti the fields on the time card screen
        //  first confirm the time card in context doesnt already have records for them,
        //  if not, create the 7 records
        //  this is only now going to be called by CreateNewTimeCard so we need to clear or reset the list of time card details
        m_timeCardDetails = new List<Time_Card_Details__c>();
        
        if (m_timeCardDetails != null && m_timeCardDetails.size() > 0)
        {
            timeCard.AddError('Cannot create new week of time card detail records.  Records already exist for the time card.  Size of list: ' + m_timeCardDetails.size());
        }
        if (m_timeCardDetails == null || m_timeCardDetails.size() == 0)
        {
            //  here we will create the records....
            m_timeCardDetails = new List<Time_Card_Details__c>();
            m_timeCardDetails.add(createTimeCardDetail(timeCard, 'Sunday'));
            m_timeCardDetails.add(createTimeCardDetail(timeCard, 'Monday'));
            m_timeCardDetails.add(createTimeCardDetail(timeCard, 'Tuesday'));
            m_timeCardDetails.add(createTimeCardDetail(timeCard, 'Wednesday'));
            m_timeCardDetails.add(createTimeCardDetail(timeCard, 'Thursday'));
            m_timeCardDetails.add(createTimeCardDetail(timeCard, 'Friday'));
            m_timeCardDetails.add(createTimeCardDetail(timeCard, 'Saturday'));
            database.saveResult[] saveResults = database.insert(m_timeCardDetails);
            //  scroll thru confirming that all records were created
            for (Database.SaveResult sr : saveResults)
            {
                if (!sr.isSuccess())
                {
                    timeCard.addError('Failed to create time card detail record: ' + sr.getErrors());
                }
            }
    //      showNoTimeCardSection = false;
            queryTimeCardDetails();
            
        }
        return null;
    }

    public PageReference submitForApproval()
    {
        util.debug('inside of submitforapproval...');
        System.debug('************** -- '+timeCard.User__c+' -- '+UserInfo.getUserId());
        if(isLead || (timeCard.User__c == UserInfo.getUserId())){
            manageshowDidTimeCardChangeDialog();
     
            
            //  the question becomes, do we place the submit on the edit of the record... the answer is no so we arent changin the saves (backward)
            //  what this does is change the statsu of the timecard
            timeCard.Submit_Status__c = 'Submitted';
            timeCard.Submit_Date__c = datetime.now();
            timeCard.Submitted_By__c = userInfo.getUserId();
            
            update timeCard;
            
            //  we are going to use the lead on the case team record to send out the email for approval
            Case_Team__c caseTeam = [select id, user__c, user__r.name, user__r.email, lead__c, lead__r.email, lead__r.name from Case_Team__c where user__c =: timeCard.User__c limit 1];
            util.debug('case team of time card user queried: ' + caseTeam);
            if (caseTeam == null)
            {
                throw new myException('failed to find case team record for user with id: ' + timeCard.user__c);
            }
            /*User theTech = [select id, name, email, manager.email, manager.name, DelegatedApproverId from User where id =: timecard.User__c];
            
            if (theTech.managerid == null)
            {
                throw new myException('User is not assigned a manager.  Cannot submit for approval');
            }
            User delegated;
            if (theTech.DelegatedApproverId != null)
            {
                delegated = [select id, name, email from User where id =: theTech.DelegatedApproverId];
            }
            */
            
            string subject = 'Time Card for ' + caseTeam.User__r.name + ' for ' + weekBegin.format() + ' is waiting your approval';
            string htmlbody = EmailClassRoadnet.createHyperLink(util.base_url + 'apex/TimeCardPage?timeCardId=' + timeCard.id, 'Link to View Time Card Record');
            
            List<string> ccEmail = new List<string>();
            ccEmail.add(caseTeam.user__r.email);
            util.debug('ccEmail: ' + ccEmail);
            
            List<string> toEmail = new List<string>();
            toEmail.add(caseTeam.Lead__r.email);
            util.debug('toEmail: ' + toEmail);
            
            //  sends email to users manager
            EmailClassRoadnet.sendEmailAsync(toEmail, ccEmail, null, subject, htmlbody, htmlbody, null );
            //EmailClassRoadnet.sendEmailAsync(new List<string>{theTech.email}, ccEmail, null, 'Time Card Submitted to ' + theTech.manager.name + ' successfully.', '', '', null);
            util.debug('email should be sent');
            
            PageReference pr = Page.TimeCardPage;
            pr.getParameters().put('timeCardId', timeCard.Id);
            
            
            pr.setRedirect(true);
            return pr; 
        }
        else{
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'You dont have access to save time cards, either the CS Tech or the Lead can save the time card, please contact your Manager.'));
            return null;
        }
    }

    public PageReference createNewTimeCard()
    {
        
        //  basically just create a time card, create the time card details and insert into database, have the screen refhres
        //  to show the new time card
        //  there is a small problem here, support users have the smae logic but what happens if john sees this page or zach
        //  ie managers who dont need to create time cards but instead just need to approve?  for now i am going to give a static
        //  message that says they cannot create a new time card
        
        if (!isUserApartOfSupport)
        {
             ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'You are not a member of a case support team and cannot create a Time Card.'));
        }
        else
        {
            //  need to confirm that if user is lead, he has selected a user before creating the time card
            if (isLead && (selectedCSSupport == null || selectedCsSupport == '--None--'))
            {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Please select a member of the CS Support team to create Time Card.'));
                return null;
            }
            id timeCardsUserid;
            
           timeCard = new Time_Card__C();
           
           if (isLead)
           {
               timeCard.User__c  = selectedCsSupport;
           }
           else
           {
               timeCard.User__c = userInfo.getUserId();
           }
           
           //  used to preformat the name below
           User tempUserRecord = [select id, name from User where id =: timeCard.User__c];
           timeCard.name = 'TC - ' + tempUserRecord.Name + ' - ' + WeekBegin.Month() + weekBegin.Day() + WeekBegin.year();
           
           timeCard.Week_Begin__c = weekBegin;
           database.saveResult sr = database.insert(timeCard);
           if (sr.isSuccess())
           {
               timeCard = queryTimeCard(sr.getId());
         //        showNoTimeCardSection = false;
                oldTimeCard = timeCard.clone(false, false);
           }
           
           createTimeCardDetails();
        }
        
        return null;
    }
    public PageReference cancel()
    {
        //  return user to what ever is in the return url
        PageReference pr = new PageReference('/' + returnUrl);
        pr.setRedirect(true);
        return pr;
    }
   
    public PageReference weekBeginSelectionOnChange()
    {
        manageshowDidTimeCardChangeDialog();

        
        //  the new idea here is that we are going to have a tab that shows time card info
        //  so when the user picks a new week, we either are going to query for the time card and display that info
        //  or we will show a message saying that a time card doesn't exist for that date
        //  logic here is to see if a card exists for the new week begin for the user who has a time card now
        if (timeCardForDateLookUponly.WEek_Begin__c == null)
        {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Please select a week begin date.'));
            return null;
        }
        if (userIdToPassIntoQueryMethod == null)
        {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Please select a cs support member.'));
            return null;
        }
  
        timeCard = queryTimeCard(userIdToPassIntoQueryMethod, weekBegin);
        
        if (timeCard == null)
        {
    //      showNoTimeCardSection = true;
        }
        else
        {
      //    showNoTimeCardSection = false;
            queryTimeCardDetails();
        }
        return null;
    }

    public id userIdToPassIntoQueryMethod
    {
        get
        {
            if (isLead)
            {
                if (SelectedCsSupport == null || selectedCsSupport == '--None--')
                {
                    return null;
                }
                return selectedCsSupport;
            }
            else
            {
                return userInfo.getUserid();
            }
        }
    }

    public pageReference simpleRefresh()
    {
        return null;
    }
   
    public pagereference saveChanges()
    {
        System.debug('************** -- '+timeCard.User__c+' -- '+UserInfo.getUserId());
        if(isLead || (timeCard.User__c == UserInfo.getUserId())){
           if (timeCard.Submit_Status__c == 'Rejected' && timeCard.Rejection_Reason__c.Length() == 0)
            {
                timeCard.Submit_Status__c.AddError('Rejecetion reason required');
                return null;
            }
            
            timeCard.Week_Begin__c = weekBegin;
            
            // since we are managing sharing settings, make sure the owner of the card is the same as the user of the card (that way if zach creates a card for geavonna, geavonna can access it)
            timeCard.OwnerId = timeCard.User__c;
        
            //  so assuming that 99% of the time a user uses the vf page, the time card details are already created
            //  we'll just need to perform an update on them
            //  matter of fact, outside of a system admin creating the records backdoor, the record should only get created
            //  via the create week button
            //  so its an update
            if (m_timeCardDetails != null)
            {
                //  we added a total row to the time card details list, we need to remove that row before updating the
                //  the list so find that one, remove it and then update
                for (integer i = 0; i < m_timeCArdDetails.size(); i++)
                {
                    if (m_timeCardDetails[i].name == 'Total Week')
                    {
                        m_timeCardDetails.remove(i);
                    }
                }
                database.upsert(m_timeCardDetails);
            }
           //  the create new time card button shouldve already created the time card so just update
           try
            {
               update timeCard;
            }
            catch(Exception e)
            {
                timeCard.addError(e.getMessage());
                return null;
            }
            //  requery the time card
           timeCard = queryTimeCard(timeCard.id);
           oldTimeCard = timeCard.clone(false, false);
           
           //  requery the time card details
           queryTimeCardDetails();
           showDidTimeCardChangeDialog = false;
        }
        else{
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'You dont have access to save time cards, either the CS Tech or the Lead can save the time card, please contact youe Manager.'));
        }    
       //  keep the user on the vf page
       return null;
       
    }


    private static Time_Card__c queryTimeCard(id userId, Date weekBeginDate)
    {
        util.debug('inside queryTimeCard.  userId: ' + userId + ' weekBeginDate: ' + weekBeginDate);
        
        try
        {
        //  todo add prpoer query here
            List<Time_Card__c> tempTimeCardList = [Select t.Week_Begin__c, t.User__c,  t.Submitted_By__c, t.submitted_by__r.name, t.Submit_Status__c, t.Submit_Date__c, 
            t.Rejection_Reason__c, t.Rejected_By__c, t.rejected_by__r.name, t.Reject_Date__c, t.OwnerId, t.Name,  
            t.Id, t.CreatedDate, 
            t.Approved_By__c, t.approved_by__r.name, t.Approval_Date__c, t.createdby.name,
            t.LastModifiedBy.name, t.user__r.name, t.lastmodifiedDAte
            From Time_Card__c t
               where Week_Begin__c =: weekBeginDate and
               User__c =: userId];
            util.debug('tempTimeCard queried: ' + tempTimeCardList);
            
            if(tempTimeCardList.size() > 0){
                return tempTimeCardList.get(0);
            }
            return null;   
        }
        catch(Exception e)
        {
            return null;
        }
        
    }
    private static Time_Card__c queryTimeCard(id timeCardId)
    {
        
        try
        {
            //  todo add prpoer query here
            return [Select t.Week_Begin__c, t.User__c, t.Submitted_By__c, t.submitted_by__r.name, t.Submit_Status__c, t.Submit_Date__c, 
            t.Rejection_Reason__c, t.Rejected_By__c, t.rejected_by__r.name, t.Reject_Date__c, t.OwnerId, t.Name,  
            t.Id,  t.CreatedDate, t.lastmodifieddate, 
            t.Approved_By__c, t.approved_by__r.name, t.Approval_Date__c, t.createdby.name,
            t.LastModifiedBy.name, t.user__r.name
            From Time_Card__c t
               where id =: timeCardId];
               
        }
        catch(Exception e)
        {
            return null;
        }
        
    }
    
    private void queryTimeCardDetails()
    {
        
        
        if (timeCard != null)
        {
            m_timeCardDetails = [Select t.Type__c, t.Training_Time_Spent__c, t.Time_Spent__c, t.Time_Card__c, 
                   t.Name, t.Meeting_Time_Spent__c,
                   t.Id, t.Date__c, t.CreatedDate, 
                   t.Comments__c, t.Admin_Time_Spent__c, 
                   t.total_time_spent__c,  t.Bereavement_Time_Spent__c, t.Holiday_Time_Spent__c, t.In_Lieu_Days_Time_Spent__c, t.Jury_Duty_Time_Spent__c, 
                   t.Personal_Time_Spent__c, t.day_of_week_name__c,t.Hours_Worked__c,t.Project_Time_Spent__c,
                   t.Professional_Services_Work_Time_Spent__c, t.Sick_Time_Spent__c, t.Vacation_Time_Spent__c
                  From Time_Card_Details__c t where Time_Card__c =: timeCard.id order by date__c asc];
           
           tableRows = new List<tcdex>();
           
           //  query the timecard's/user's case times for that week
           DateTime startDate = Datetime.newInstance(
            timeCard.Week_Begin__c.year(), timeCard.Week_Begin__c.Month(), timeCard.Week_Begin__c.Day(), 0, 0, 0);
           DateTime endDate = startDate.addDays(7);
           
           Mibos_Case_Time__c[] caseTimes = [select id, createddate, work_effort__c from MIbos_Case_Time__c where 
            (Case__r.RecordType.Name = 'Call Center' OR Case__r.RecordType.Name = 'Engineering Case') AND
            Owner__c =: timeCard.User__c AND
            (CreatedDate >=: startDate OR CreatedDate <: endDate)];//Abhishek Modified
            
           
           for (Time_Card_Details__c tcd : m_timeCardDetails)
           {
               tableRows.add(new Tcdex(tcd, caseTimes));
           }
           
           // we need to add a toal row, luckliy my design allows this to happen very easily
           if (m_timeCardDetails != null && m_timeCardDetails.size() > 0)
           {
               Time_Card_Details__c totalRow = new Time_Card_Details__c();
               totalRow.Name = 'Total Week';
               totalRow.training_time_spent__c = 0.0;
               totalRow.Meeting_Time_Spent__c = 0.0;
               totalRow.Admin_Time_Spent__c = 0.0;
               totalRow.Bereavement_Time_Spent__c = 0.0;
               totalRow.Holiday_Time_Spent__c = 0.0;
               totalRow.In_Lieu_Days_Time_Spent__c = 0.0;
               totalRow.Jury_Duty_Time_Spent__c = 0.0;
               totalRow.Personal_Time_Spent__c = 0.0;
               totalRow.Professional_Services_Work_Time_Spent__c = 0.0;
               totalRow.Sick_Time_Spent__c = 0.0;
               totalRow.Vacation_Time_Spent__c = 0.0;
               totalRow.Hours_Worked__c = 0.0;
               totalRow.Project_Time_Spent__c = 0.0;
               
               decimal totalForTable = 0; 
               
                         
               for (Time_Card_Details__c tcd : m_timeCardDetails)
               {
                
                 totalRow.training_time_spent__c += nullToZero(tcd.training_time_spent__c);
                 totalRow.Meeting_Time_Spent__c += nullToZero(tcd.Meeting_Time_Spent__c);
                 totalRow.Admin_Time_Spent__c += nullToZero(tcd.Admin_Time_Spent__c);
                 totalRow.Bereavement_Time_Spent__c += nullToZero(tcd.Bereavement_Time_Spent__c);
                 totalRow.Holiday_Time_Spent__c += nullToZero(tcd.Holiday_Time_Spent__c);
                 totalRow.In_Lieu_Days_Time_Spent__c += nullToZero(tcd.In_Lieu_Days_Time_Spent__c);
                 totalRow.Jury_Duty_Time_Spent__c += nullToZero(tcd.Jury_Duty_Time_Spent__c);
                 totalRow.Personal_Time_Spent__c += nullToZero(tcd.Personal_Time_Spent__c);
                 totalRow.Professional_Services_Work_Time_Spent__c += nullToZero(tcd.Professional_Services_Work_Time_Spent__c);
                 totalRow.Sick_Time_Spent__c += nullToZero(tcd.Sick_Time_Spent__c);
                 totalRow.Vacation_Time_Spent__c += nullToZero(tcd.Vacation_Time_Spent__c);
                 totalRow.Hours_Worked__c += nullToZero(tcd.Hours_Worked__c);
                 totalRow.Project_Time_Spent__c += nullToZero(tcd.Project_Time_Spent__c);
                 totalForTable += nullToZero(tcd.total_time_spent__c);
                 
                
          
               }
               decimal caseTimeSumForTotalRow = 0;
               //  now scorll thru the tcdex records and sum up the case time for the total row record
               for (TcdEx singleItem : tableRows)
               {
                    caseTimeSumForTotalRow += singleItem.caseTimeSum;
                 
               }
               
              // Totals Calulation.. 
               
               Tcdex totalRowRecord = new Tcdex(totalRow, null);
               totalRowRecord.caseTimeSum = caseTimeSumForTotalRow;
               totalRowRecord.TotalFortable = totalForTable;
               totalRowRecord.caseTotalTime = caseTimeSumForTotalRow + totalForTable ;
               tableRows.add(totalRowRecord);
           }
           
        }
        else
        {
            m_timeCardDetails = new List<Time_Card_Details__c>();
            tableRows = new List<tcdex>();
        }
    }
    private void manageshowDidTimeCardChangeDialog()
    {
        //get
        {
            boolean didTimeCardChange = false;
            boolean didTcDetailsChange = false;
            //  first check if the time card changed then the details
            if (timeCard != null)
            {
                //  if time card not null assume, oldtimecard is not also
                didTimeCArdChange = 
                 oldTimeCard.rejection_reason__c != timeCard.rejection_Reason__c ||
                 oldTimeCard.Submit_Status__c != timeCard.Submit_Status__c;
            }
            if (tableRows != null)
            {
                //  scroll thru the table records, we know a table record has changed if the xxxxColor is lightblue
                //  so check fo that
                for (Tcdex tcdex : tableRows)
                {
                    if (tcdex.adminColor == 'lightblue' || tcdex.MeetingColor == 'lightblue' ||
                        tcdex.TrainingColor == 'lightblue' || tcdex.BereavementColor == 'lightblue' || tcdex.HolidayColor == 'lightblue' ||
                        tcdex.inLieuColor == 'lightblue' || tcdex.juryColor == 'lightblue' || tcdex.PersonalColor == 'lightblue' || tcdex.professionalColor == 'lightblue' ||tcdex.projectColor == 'lightblue' ||
                        tcdex.sickColor == 'lightblue' || tcdex.vacationColor == 'lightblue' || tcdex.hoursColor == 'lightblue'|| tcdex.commentsColor == 'lightblue')
                        
                    {
                        didTcDetailsChange = true;
                        break; // dont check any more, lets return our TRUE reslt
                    }
                }
                
            }
            showDidTimeCardChangeDialog = didTimeCardChange || didTcDetailsChange;
        }
    }
    private static Time_Card_Details__c createTimeCardDetail(Time_Card__c tc, string dayOfWeek)
    {
        Time_Card_Details__c tcd = new Time_Card_Details__c();
        tcd.time_card__c = tc.id;
        tcd.name = tc.name + ' - ' + dayOfWeek;//  format is name of time card - day
        tcd.day_of_week_name__c = DayofWEek;
        
        //  pulled this off the web, it returns Wednesday for 7/22/2015, do not think i need it tho
        /*Datetime dt = DateTime.newInstance(Date.today(), Time.newInstance(0, 0, 0, 0));
        String dayOfWeek=dt.format('EEEE');
        */
        //  timecard.Week_Begin is the begining of the week aka sunday, and assuming that timecard.week_begin is indeed the beign of the week
        //  then we just compare the text and add days to the weekbgeing to get the tcd.date
        if (dayOfWeek == 'Sunday')
        {
            tcd.Date__c = tc.Week_Begin__c;
        }
        if (dayOfWeek == 'Monday')
        {
            tcd.Date__c = tc.Week_Begin__c.addDays(1);
        }
        if (dayOfWeek == 'Tuesday')
        {
            tcd.Date__c = tc.Week_Begin__c.addDays(2);
        }
        if (dayOfWeek == 'Wednesday')
        {
            tcd.Date__c = tc.Week_Begin__c.addDays(3);
        }
        if (dayOfWeek == 'Thursday')
        {
            tcd.Date__c = tc.Week_Begin__c.addDays(4);
        }
        if (dayOfWeek == 'Friday')
        {
            tcd.Date__c = tc.Week_Begin__c.addDays(5);
        }
        if (dayOfWeek == 'Saturday')
        {
            tcd.Date__c = tc.Week_Begin__c.addDays(6);
        }
        
        return tcd;
        
    }

    private static decimal nullToZero(decimal d)
    {
        if (d == null)
        {
            return 0.0;
        }
        else
        {
            return d;
        }
    }
     
    public class Tcdex//  time card detail extension, used to control attribues of the table
    {
        public Tcdex(Time_Card_Details__c timeCardDetail, List<MIBOS_Case_Time__c> caseTimes)
        {
            tcd = timeCardDetail;
            oldTcd = timeCardDetail.clone(false, false);
            if (caseTimes != null)
            {
                caseTimeSum = 0;
                caseTotalTime = 0;  // Abhishek added as a part of CR- #02014490
                caseRowTotal = 0;   // Abhishek added as a part of CR- #02014490
                //System.debug();
                //  i know this is very inefficient, but this enhancemenat was added a month after this was built, maybe when i revisit
                // ill refactor
                for (Mibos_Case_Time__c ct : caseTimes)
                {
                    //  we need to sum case times that ONLY match up with that tcd detail's day.  problem is that
                    //  the tcd.date is a date, mibos case times are in datetime.... however i think there is datetime.date() method
                    if (ct.CreatedDate.date() == timeCardDetail.Date__c)
                    {
                      caseTimeSum += ct.work_effort__c;
                     
                    }
                }
                
                       if(caseTimeSum != null) 
                       caseRowTotal = caseTimeSum + nullToZero(timeCardDetail.total_time_spent__c);  // Abhishek added as a part of CR- #02014490
                       
                       if(caseTimeSum != null)
                       caseTotalTime = caseTimeSum; // Abhishek added as a part of CR- #02014490
                
                
                 
            }
            
            
            
           
        }
        public Time_Card_Details__c tcd{get;set;}
        public Time_Card_Details__c oldTcd{get;set;}
        public decimal totalForTable{get;set;}
        public decimal caseTimeSum{get;set;}
        public decimal caseTotalTime{get;set;}  // Abhishek added as a part of CR- #02014490 
        public decimal caseRowTotal{get;set;}  // Abhishek added as a part of CR- #02014490 
            
        public string adminColor
        {
            get
            {
                if (oldTcd.Admin_Time_Spent__c != tcd.Admin_Time_Spent__c)
                {
                    return 'lightblue';
                }
                else
                {
                    return 'white';
                }
                
            }
        }

        public string MeetingColor
        {
            get
            {
                if (oldTcd.Meeting_Time_Spent__c != tcd.Meeting_Time_Spent__c)
                {
                    return 'lightblue';
                }
                else
                {
                    return 'white';
                }
                
            }
        }
        public string TrainingColor
        {
            get
            {
                if (oldTcd.Training_Time_Spent__c != tcd.Training_Time_Spent__c)
                {
                    return 'lightblue';
                }
                else
                {
                    return 'white';
                }
                
            }
        }
        public string BereavementColor
        {
            get
            {
                if (oldTcd.Bereavement_Time_Spent__c != tcd.Bereavement_Time_Spent__c)
                {
                    return 'lightblue';
                }
                else
                {
                    return 'white';
                }
                
            }
        }
        public string HolidayColor
        {
            get
            {
                if (oldTcd.Holiday_Time_Spent__c != tcd.Holiday_Time_Spent__c)
                {
                    return 'lightblue';
                }
                else
                {
                    return 'white';
                }
                
            }
        }
        public string inLieuColor
        {
            get
            {
                if (oldTcd.In_Lieu_Days_Time_Spent__c != tcd.In_Lieu_Days_Time_Spent__c)
                {
                    return 'lightblue';
                }
                else
                {
                    return 'white';
                }
                
            }
        }
        public string juryColor
        {
            get
            {
                if (oldTcd.jury_duty_Time_Spent__c != tcd.jury_duty_Time_Spent__c)
                {
                    return 'lightblue';
                }
                else
                {
                    return 'white';
                }
                
            }
        }
        
        public string PersonalColor
        {
            get
            {
                if (oldTcd.Personal_Time_Spent__c != tcd.Personal_Time_Spent__c)
                {
                    return 'lightblue';
                }
                else
                {
                    return 'white';
                }
                
            }
        }
        public string professionalColor
        {
            get
            {
                if (oldTcd.Professional_Services_Work_Time_Spent__c != tcd.Professional_Services_Work_Time_Spent__c)
                {
                    return 'lightblue';
                }
                else
                {
                    return 'white';
                }
                
            }
        }  
        
        public string projectColor
        {
            get
            {
                if (oldTcd.Project_Time_Spent__c != tcd.Project_Time_Spent__c)
                {
                    return 'lightblue';
                }
                else
                {
                    return 'white';
                }
                
            }
        }     
              
        public string sickColor
        {
            get
            {
                if (oldTcd.Sick_Time_Spent__c != tcd.Sick_Time_Spent__c)
                {
                    return 'lightblue';
                }
                else
                {
                    return 'white';
                }
                
            }
        }        
        public string vacationColor
        {
            get
            {
                if (oldTcd.Vacation_Time_Spent__c != tcd.Vacation_Time_Spent__c)
                {
                    return 'lightblue';
                }
                else
                {
                    return 'white';
                }
            }
        }  
        
        public string hoursColor
        {
            get
            {
                if (oldTcd.Hours_Worked__c != tcd.Hours_Worked__c)
                {
                    return 'lightblue';
                }
                else
                {
                    return 'white';
                }
            }
        }       

        public string commentsColor
        {
            get
            {
                //  first check for nullness/length then we;ll check to see if the field has changed
                boolean isBlankOldTcdComments = oldTcd.Comments__c == null || oldTcd.Comments__c.length() == 0;
                boolean isBlankTcdComments = tcd.Comments__c == null || tcd.Comments__c.length() == 0;
                
                if ((isBlankOldTcdComments != isBlankTcdComments) &&  //  went to blank to not blank or vice versa
                    (oldTcd.comments__c != tcd.comments__c))
                {
                    return 'lightblue';
                }
                else
                {
                    return 'white';
                }
                
            }
        }        

        public boolean isReadOnly
        {
            get
            {
                //  only the total row should be read only, everything else reamins editable unless its a label
                return tcd.name == 'Total Week';
            }
        }
    }
    
    public static Time_Card__c createTestTimeCard()
    {
        Time_Card__c tc = new Time_Card__c();
        tc.name = 'Test Time Card';
        tc.week_begin__c = date.today().toStartOfWeek();
        tc.user__c = userInfo.getUserid();
        database.insert(tc);
        
        //  for purposes of being lazy, will create just one tcd
        Time_Card_Details__c tcd = new Time_Card_Details__c();
        tcd.Time_Card__c = tc.id;
        tcd.name = 'Test TimeCardDetails';
        tcd.date__c = tc.Week_Begin__c;
        
        database.insert(tcd);
        
        return tc;
    }
    
    public static Case_Team__c createTestCaseTeam(string userName)
    {
        Case_Team__c ct = new Case_TEam__c();
        User tempUser = [select id, name, managerid, business_unit__c from user where name =: userName order by lastmodifieddate limit 1 ];
        ct.user__c = tempUser.id;
        ct.lead__c = tempUser.managerid;
        ct.business_unit__c = tempUser.business_unit__c;
        database.insert(ct);
        return ct;
    }    
    public static Case_Team__c createTestCaseTeam()
    {
        Case_Team__c ct = new Case_Team__c();
        User loggedInuser = [select id, managerid from user where id =: userInfo.getUserid() limit 1];
        
        ct.business_unit__c = 'Roadnet';
        ct.Group_Name__c = 'Primary Support';
        ct.Lead__c = loggedInUser.managerid;
        ct.user__c = loggedInuser.id;
        
        database.insert(ct);
        return ct;
    }
    
    public class myException extends exception{}
}