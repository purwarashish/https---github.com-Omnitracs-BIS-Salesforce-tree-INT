/*******************************************************************************
 * File:  CaseComment.Trigger
 * Date:  May 18th, 2015
 * Author:  Joseph Hutchins
 * The use, disclosure, reproduction, modification, transfer, or transmittal of
 * this work for any purpose in any form or by any means without the written 
 * permission of United Parcel Service is strictly prohibited.
 *
 * Confidential, unpublished property of United Parcel Service.
 * Use and distribution limited solely to authorized personnel.
 *
 * Copyright 2015 Roadnet Technologies,  All rights reserved.
 *
 *
 *******************************************************************************/
 trigger CaseComment on CaseComment (before insert, before update, after insert, after update)
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
            util.debug('Send_Trigger_Email_Alerts__c.isDisabled__c = ' + testObject.isDisabled__c);
            return testObject.isDisabled__c;
        }
    }
    if(Trigger.isBefore){
        if(Trigger.isInsert || Trigger.isUpdate){
            removeHTMLMarkup(trigger.new);
        }
    }
    if (Trigger.isAfter)
     {
            if (Trigger.isInsert)
            {
                
                if (!isSendingEmailsDisabled)
                {
                    sendPortalCaseEmailAlerts();
                }
            }
            
     }
     
     private void sendPortalCaseEmailAlerts()
     {
        //  need to requery the casecomment as there are no identifying fields on the casecomment object
        CaseComment[] commentsRequeired = [select id, createdbyid, commentbody, ispublished, createdby.name, parent.subject, 
            parent.casenumber, parent.contactid, parent.contact.email, 
            parent.business_unit__c, CreatedBy.Profile.Name, parent.ownerid, parent.owner.name, parent.accountid, parent.account.name,
            parent.contact.name from CAseComment where 
            id in: trigger.New AND
            parent.business_unit__c = 'Roadnet' AND
            parent.RecordType.Name = 'Call Center'
            ];
            
        util.debug('case comments required size: ' + (commentsRequeired == null ? 0 : commentsRequeired.size()));   
        
        if (commentsRequeired != null && commentsRequeired.Size() > 0)
        {
            //  so we'll have two email alerts, one when a portal user adds a casecomment to caes, and one when the 
            //  the case owner adds case comment to the case and it is supposed to go out to the contact
            
            emailAlertForPortalUserCreatingCaseComment(commentsRequeired);
            emailAlertForInternalUserCreatingCaseComment(commentsRequeired);
        }       
     }
     private void emailAlertForPortalUserCreatingCaseComment(CaseComment[] commentsRequeired)
     {
         //  the idea here is that we want case commments attached to roadnet CALL CENTER CASES
        //  and the created by profile.name.contains("Customer Community ")
        
        //List<CaseComment> roadnetCustomerPortalCreatedComments = new List<CaseComment>();
        List<Messaging.SingleEmailMessage> emailsToSend = new List<Messaging.SingleEmailMessage>();
        
        for (CaseComment cc : commentsRequeired)
        {
            string ownerIdToString = cc.parent.Ownerid;
            
            util.debug('checking if required case comment is created by portal user.  cc.parent.business_unit__c: ' + 
                cc.parent.business_unit__c + ' profile.name: ' + cc.createdby.profile.name);
            
                string subject = 'Case #' + cc.parent.casenumber + ' has case commented created by portal user: ' + cc.createdby.name;
                string htmlbody = CaseEventExtension.RT_EMAIL_HEADER_IMAGE +
                  '<br />You are being notified as the case owner for Case #' + EmailClassRoadnet.createHyperLink(Util.base_url + cc.parentid, cc.parent.caseNumber ) +
                  ' with subject: <br /><br />' + 
                  cc.parent.subject + ' <br /> <br />' + 
                  ' has had a case comment created for it by a portal user: ' + cc.createdby.name + '. <br /><br />' +
                   '<b>Case Comment:</b> ' + cc.commentBody +  
                    '<b>Case:</b>    ' + EmailClassRoadnet.createHyperLink(Util.base_url + cc.parentid, '#' + cc.parent.caseNumber ) + '<br /><br />' +
                    '<b>Account:</b>    ' + EmailClassRoadnet.createHyperLink(util.base_url + cc.parent.accountid, cc.parent.account.name) + '<br /><br />' +
                    '<b>Contact:</b>    ' + EmailClassRoadnet.createHyperLink(util.base_url + cc.parent.contactid, cc.parent.contact.name) + '<br /><br />' +
                    '<b>Case Subject:</b>    ' + cc.parent.Subject + '<br /><br />';
                if (cc.parent.Business_Unit__c == 'Roadnet' &&
                cc.CreatedBy.Profile.Name != null &&
                cc.CreatedBy.Profile.Name.Contains('Customer Community') &&
                !ownerIdToString.Contains('00G'))
            {
                
                emailsToSend.add(
                    EmailClassRoadnet.createMailInternalUser(cc.parent.ownerId, subject, htmlbody, null));
            }
             
        }
        
        util.debug('num of "portal user created case comments" emails to be sent out: ' + (emailsToSend == null ? 0 : emailsToSend.size()));
        if (emailsToSend != null && emailsToSend.Size() > 0)
        {
            EmailClassRoadnet.sendMultipleEmails(emailsToSend);
            util.debug('email sending should be complete');
        }
     }
     
     private void emailAlertForInternalUserCreatingCaseComment(CaseComment[] commentsRequeired)
     {
        util.debug('emailAlertForInternalUserCreatingCaseComment called');
        List<CaseComment> commentsCreatedByInternalUser = new List<CaseComment>();
        
        //  john has clarified that any internal user creating a case comment should send notice to the contact, not just the case owner
        // so need to modify how this works just a bit
        //  first thing we need to see is if any of the case comments are created by the case owner  AND are published (public viewable)  AND
        //  the contact wants to receive emails
        for (CaseComment cc : commentsRequeired)
        {
            util.debug('checking case comment: isPublished: ' + cc.isPublished + 
                
               ' cc createdby: ' + cc.createdById + ' case owner: ' + cc.parent.ownerid );
               
            //  i tried to do a createdby.contactid != null instead of the profile.name.contains but
            //  i got error that invalid field contactid for name... so i have to check it this way
            if (cc.isPublished && 
                cc.parent.business_unit__c == 'Roadnet' &&
                cc.createdby.profile.name != null &&
                !cc.createdby.profile.name.contains('Customer Community'))
            {
                
                commentsCreatedByInternalUser.add(cc);
            }
        }
        
        util.debug('num of comments created by internal users: ' + commentsCreatedByInternalUser.size());
        
        //  and if so, we then need to see if the case of those case comments is a portal user [USER QUERY HERE]

        if (commentsCreatedByInternalUser != null && commentsCreatedByInternalUser.size() > 0)
        {
            List<CaseComment> caseCommentsForEmailSending = new List<CaseComment>();
            
            List<User> roadnetPortalUsers = [select id, contactid, profile.name, isactive, business_unit__c from user where contactid != null and 
                profile.name like '%Customer Community%' and business_unit__c = 'Roadnet' and isactive = true ];
            //  user query happens here, see if the contact is a portal user by seeing if any portal user records point to the contact
            for (CaseComment cc : commentsCreatedByInternalUser)
            {
                if (isCaseContactPortaluser(cc.parent.contactid, roadnetPortalUsers))
                {
                    caseCommentsForEmailSending.add(cc);
                }
            }
            
            util.debug('num of caseCommentsForEmailSending: ' + caseCommentsForEmailSending.size());
            
            //  if so, we'll query the email template and send the emails out
            if (caseCommentsForEmailSending != null && caseCommentsForEmailSending.size() > 0)
            {
                
                List<Messaging.SingleEmailMessage> emailsToSend = new List<Messaging.SingleEmailMessage>();
                for (CaseComment cc : caseCommentsForEmailSending)
                {
                    string subject = 'Your case #' + cc.parent.casenumber + ' has had a case comment added.';
                    string htmlbody = CaseEventExtension.RT_EMAIL_HEADER_IMAGE +
                      '<br />A case comment has been added to your case #' + cc.parent.casenumber + ' by: ' + cc.createdby.name + '. <br /><br />' + 
                      '<b>Case Comment:</b> ' + cc.commentBody +  '<br /><br />' +
                    '<b>Case:</b>    ' + EmailClassRoadnet.createHyperLink(Util.base_url + cc.parentid, '#' + cc.parent.caseNumber ) + '<br /><br />' +
                    '<b>Account:</b>    ' + EmailClassRoadnet.createHyperLink(util.base_url + cc.parent.accountid, cc.parent.account.name) + '<br /><br />' +
                    '<b>Case Subject:</b>    ' + cc.parent.Subject + '<br /><br />';
                
                    emailsToSend.add(
                        EmailClassRoadnet.createMail(cc.parent.Contact.email, subject, htmlbody, null));
                }
                
                util.debug('emailsToSend: ' + (emailsToSend == null ? 0 : emailsToSend.size()));
                
                if (emailsToSend != null && emailsToSend.size() > 0)
                {
                    EmailClassRoadnet.sendMultipleEmails(emailsToSend);
                    util.debug('email sending should be complete');
                }
                /*
                EmailTemplate et = [select id, name from EmailTemplate where name = 'This dont exist yet'];
                EmailClassRoadnet.EmailTemplateEx[] emailTemplateRecords = new List<EmailClassRoadnet.EmailTemplateEx>();
                for (CaseComment cc : caseCommentsForEmailSending)
                {
                    EmailClassRoadnet.EmailTemplateEx tempEmail = new EmailClassRoadnet.EmailTemplateEx();
                    tempEmail.templateId = et.id;
                    tempEmail.whatId = cc.parentid;
                    tempEmail.targetId = cc.parent.contactid;
                    tempEmail.orgWideEmailAddress = rtsSupportOrgWideEmail;
                    emailTemplateRecords.add(tempEmail);
                    
                }
                if (emailTemplateRecords != null && emailTemplateRecords.size() > 0)
                {
                    EmailClassRoadnet.sendEmailsWithTemplate(emailTemplateRecords);
                }
                */
            }
        }
            
     }
    
     private static boolean isCaseContactPortaluser(id contactid, List<User> portalUsers)
     {
         for (User us : portalUsers)
         {
             if (us.contactId == contactId)
             {
                 return true;
             }
             
         }
         return false;
         
     }
     
     private void removeHTMLMarkup(List<CaseComment> comment){
        List<CaseComment> commentsToUpdate = new List<CaseComment>(); 
         
        for(CaseComment c : comment){
        String string1 = c.CommentBody;
        String string2 = string1.replaceAll('<[/a-zA-Z0-9;]*>','');
        /*string2 = string2.replaceAll('<a-z="a-z_a-z"','');
        string2 = string2.replaceAll('<a-z="a-z_a-z"','');*/
        string2 = string2.replaceAll('&nbsp;','');
        string2 = string2.replaceAll('<.*?>','');
        string2 = string2.replaceAll('&#39;','\'');
        string2 = string2.replaceAll('&lt;','<');
        string2 = string2.replaceAll('&gt;','>');
        //string2 = string2.replaceAll('&quot;','"');
        //string2 = string2.replaceAll('?:<style.+?>.+?</style>|<script.+?>.+?</script>|<(?:!|/?[a-zA-Z]+).*?/?>','');
        c.CommentBody = string2;
        commentsToUpdate.add(c);    
     }

     }
}