/*******************************************************************************
 * File:  FeedItemTrigger
 * Date:  May 21, 2015  
 * Author:  Joseph Hutchins
 * The use, disclosure, reproduction, modification, transfer, or transmittal of
 * this work for any purpose in any form or by any means without the written 
 * permission of United Parcel Service is strictly prohibited.
 *
 * Confidential, unpublished property of United Parcel Service.
 * Use and distribution limited solely to authorized personnel.
 *
 * Copyright 2015, Roadnet Technologies  All rights reserved.
 *
 *******************************************************************************/
trigger FeedItemTrigger on FeedItem (after insert, after update) 
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
    if (Trigger.isAfter && Trigger.isInsert)
    {
        //  we'll need to requery the feed items UNLESS we want to use a custom setting to store the profile
        //  name, but once we do that, we see if we have any that are created by portal user
        //  if so, we'll see if any of the feeds point to call center roadnet cases, if so
        //  we'll send email alert out
        try
        {
            //  we dont want my awesome code to prevent ANY chatter feed from being added, so just subtley
            //  output the error to debug and move on
            if (!isSendingEmailsDisabled)
            {
                sendEmailAlertsForPortalCases();
            }
        }
        catch(Exception e)
        {
            util.debug('ERROR OCCURED IN FeedItemTrigger: ' + e.getMessage());
        }
    }
    
    private void sendEmailAlertsForPortalCases()
    {
        
        List<FeedItem> feedItemsRequeried = [select id, Visibility, body, parentid, createdbyid, createdby.name, createdby.profileId, 
          createdBy.Profile.name from FeedItem where id in: Trigger.new];
        //  logic for this has changed a lil bit, we want to send two email alerts, 1-chatter feeds created by portal users 2-chatter feeds created by internal users for 
        //  portal contact cases.  #1 is already in place, #2 needs to be added
        //  i think we HAVE to query the cases here, becuase we 99% of the time a feed will be created by a user
        Set<id> parentIds = new SEt<id>();
        for (FeedItem fi : feedItemsRequeried)
        {
            if (!parentIds.Contains(fi.parentid))
            {
                parentIds.add(fi.parentid);
            }
        }
        
        Case[] casesOfFeedItems;
        try
        {
            casesOfFeedItems = [select id, casenumber, subject,account.name, accountid, contactid, contact.name, contact.email,
                owner.name, ownerid, business_unit__c, recordtypeid, recordtype.name, createdby.name from Case where 
                id in: parentIds AND
                Business_Unit__c = 'Roadnet' AND
                RecordType.Name = 'Call Center'];
            util.debug('num of casesOfFeedItems: ' + (casesOfFeedItems == null ? 0 : casesOfFeedItems.size()));
        }
        catch(Exception e)
        {
            //  possible that none of the feeds passed into here point to cases
            util.debug('ERROR.  when trying to query cases of feed items: ' + e.getMessage());
        }
        //  now that we have athe cases, we can check for internal user created feeds and portal user crated
        //  create emails and then send them out
        if (casesOfFeedItems == null || casesOfFeedItems.size() == 0)
        {
            return;
        }
        List<User> roadnetPortalUsers = [select id, contactid, profile.name, isactive, business_unit__c from user where contactid != null and 
            profile.name like '%Customer Community%' and business_unit__c = 'Roadnet' and isactive = true ];
    
        List<Messaging.SingleEmailMessage> portalUserCreatedFeedEmailsToSend = new List<Messaging.SingleEmailMessage>();
        List<Messaging.SingleEmailMessage> internalUserCreatedFeedEmailsToSEnd = new List<Messaging.SingleEmailMessage>();
        for (FeedItem fi : feedItemsRequeried)
        {
            Case caseOfFeedItem = findCase(fi.parentid, casesOfFeedItems);
            util.debug('case of feed has been found: ' + caseofFeedItem);
            
            if (caseOfFeedItem != null)
            {
                //  for portal user created feeds
                if (wasFeedCreatedByPortalUser(fi, caseOfFeedItem))
                {
                    string subject = 'Case #' + caseOfFeedItem.CaseNumber + ' has had a chatter post added by "' + caseOfFeedItem.CreatedBy.name;
                    string htmlbody = CaseEventExtension.RT_EMAIL_HEADER_IMAGE + '<br /><br />' + 
                        'Portal User, <b>' + fi.CreatedBy.Name + '</b>, has added a chatter post to Case ' + 
                        EmailClassRoadnet.createHyperLink(Util.base_url + caseofFeedItem.id, '#' + caseOfFeedItem.caseNumber ) +' with comment: <br /><br />' +
                        '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;' + fi.Body + ' <br /><br />' +
                        '<b>Case:</b>    ' + EmailClassRoadnet.createHyperLink(Util.base_url + caseOfFeedItem.id, '#' + caseOfFeedItem.caseNumber ) + '<br /><br />' +
                        '<b>Account:</b>    ' + EmailClassRoadnet.createHyperLink(util.base_url + caseOfFeedItem.accountid, caseOfFeedItem.account.name) + '<br /><br />' +
                        '<b>Contact:</b>    ' + EmailClassRoadnet.createHyperLink(util.base_url + caseOfFeedItem.contactid, caseOfFeedItem.contact.name) + '<br /><br />' +
                        '<b>Case Subject:</b>    ' + caseOfFeedItem.Subject + '<br /><br />';
                        
                    portalUserCreatedFeedEmailsToSend.add(
                                EmailClassRoadnet.createMailInternalUser(caseOfFeedITem.ownerId, subject, htmlbody, null));
                }
            }
            //  for internal user created feeds to portal contact
            if (wasFeedCreatedByInternalUserForPortalContactCase(fi, caseOfFeedItem, roadnetPortalUsers))
            {
                util.debug('found feeed that was created by internal user...');
                //  so if the feed was cretead by interanl users, we want to send out the email alert if the feed's visilibyt is set
                if (fi.Visibility != null && fi.Visibility == 'AllUsers')
                {
                    string subject = 'Your Case #' + caseOfFeedItem.CaseNumber + ' has had a chatter post added by "' + caseOfFeedItem.CreatedBy.name;
                    string htmlbody = CaseEventExtension.RT_EMAIL_HEADER_IMAGE + '<br /><br />' + 
                        fi.CreatedBy.Name + ' has added a chatter post to Case your case ' + EmailClassRoadnet.createHyperLink(Util.base_url + caseofFeedItem.id, '#' + caseOfFeedItem.caseNumber ) + ' with comment: <br /><br />' +
                        '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;' + fi.Body + ' <br /><br />' +
                        '<b>Case:</b>    ' + EmailClassRoadnet.createHyperLink(Util.base_url + caseOfFeedItem.id, '#' + caseOfFeedItem.caseNumber ) + '<br /><br />' +
                        '<b>Account:</b>    ' + EmailClassRoadnet.createHyperLink(util.base_url + caseOfFeedItem.accountid, caseOfFeedItem.account.name) + '<br /><br />' +
                        '<b>Case Subject:</b>    ' + caseOfFeedItem.Subject + '<br /><br />';
                        
                    internalUserCreatedFeedEmailsToSEnd.add(
                                EmailClassRoadnet.createMail(caseOfFeedITem.contact.email, subject, htmlbody, null));
                }
            }
            
        }
        
        //  soooo, its very hard to check if the email alerts WORK if i dont actually send the got damn emails...
        if (portalUserCreatedFeedEmailsToSend != null && portalUserCreatedFeedEmailsToSend.size() > 0)
        {
          EmailClassRoadnet.sendmultipleEmails(portalUserCreatedFeedEmailsToSend);
        }
        util.debug('num of internalUserCreatedFeedEmailsToSEnd to send: ' + (internalUserCreatedFeedEmailsToSEnd == null ? 0 : internalUserCreatedFeedEmailsToSEnd.size()) );
        if (internalUserCreatedFeedEmailsToSEnd != null && internalUserCreatedFeedEmailsToSEnd.size() > 0)
        {
            EmailClassRoadnet.sendmultipleEmails(internalUserCreatedFeedEmailsToSEnd);
        }
        
    }
    
    private static boolean wasFeedCreatedByPortalUser(FeedItem fi, Case caseOfFeedIteM)
    {
        string caseOwnerIdToSTring = string.valueOf(caseOfFeedItem.ownerid);
                
        return fi.CreatedBy.Profile.Name != null  && 
                    fi.CreatedBy.Profile.Name.Contains('Customer Community') &&
                    caseOfFeedItem != null &&
                    caseOfFeedItem.Business_unit__c == 'Roadnet' &&
                    caseoffeedItem.recordtype.name == 'Call Center' &&
                    !caseOwnerIdToSTring.contains('00G');
    }
    
    private static boolean wasFeedCreatedByInternalUserForPortalContactCase(FeedItem fi, Case caseOfFeedItem, List<User> roadnetPortalUsers)
    {
        return fi.CreatedBy.Profile.Name != null  && 
            !fi.CreatedBy.Profile.Name.Contains('Customer Community') &&
            caseOfFeedItem != null &&
            caseOfFeedItem.Contact.Email != null &&
            caseOfFeedItem.Business_unit__c == 'Roadnet' &&
            caseoffeedItem.recordtype.name == 'Call Center' &&
            CaseEventExtension.isCaseContactPortalUser(caseOfFeedItem.contactid, roadnetPortalUsers);
                    
    }
    
    private Case findCase(Id caseid, List<Case> cases)
    {
        for (Case c : cases)
        {
            if (c.id == caseId)
            {
                return c;
            }
        }
        return null;
    }
    
    private FeedItem findFeedItem(id recordId, List<FeedItem> feedItems)
    {
        for (FeedItem fi : feedItems)
        {
            if (fi.parentId == recordId)
            {
                return fi;
            }
        }
        return null;
    }
    
}