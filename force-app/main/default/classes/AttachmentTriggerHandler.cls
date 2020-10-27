/**
 * Created by Arman_Shah on 10/11/18.
 */

public class AttachmentTriggerHandler
implements ITriggerHandler
{
    /*********** OLD CODE:
    if(Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate))
    {
        LeadActivityUtils.updatePartnerDrivenActivity(Trigger.new);
        OpportunityActivityUtils.updatePartnerDrivenActivity(Trigger.new);
    }

    //  be advised, this is pulled from Roadnet's AttachmentTrigger to consolidate the triggers we have
    //  logic has changed to handle bulk attachment creation --joseph hutchins
    if (Trigger.isAfter && Trigger.isInsert)
    {
        updateCustomReportNames();
        if (!isSendingEmailsDisabled)
        {
            try//  i do not want to be responisble for having anyone being able to attach files to any records
            {
                emailAlertForFilesAttachedToCases();
            }
            catch(Exception e)
            {
                util.debug('sending email alerts for attached files failed due to: ' + e.getMessage());
            }
        }
    }
    **************/

    // Allows unit tests (or other code) to disable this trigger for the transaction
    public static Boolean TriggerDisabled = false;

    public static final String SVR_FILE = 'SVR';
    public static final String SVR_EMAIL_TEMPLATE = 'Project has SVR attachment';
    public static final String SVR_EMAIL_LABEL_PROD = 'PROD';

    public Boolean IsDisabled()
    {
        BypassTriggerUtility u = new BypassTriggerUtility();
        if (u.isTriggerBypassed()) {
            TriggerDisabled = true;
        }
        return TriggerDisabled;
    }

    ///////////////////////////  Class private Variables  ////////////////////////////////////////////////////////////////////////////////////////

    /* OLD: private Id portalContactEmailTemplateId
    {
        get
        {
            if (portalContactEmailTemplateId == null)
            {
                portalContactEmailTemplateId = [select id from EmailTemplate where name = 'Roadnet Portal Case File Attachment'].id;
            }

            if (portalContactEmailTemplateId == null)
            {
                return null;
            }
            else
            {
                return portalContactEmailTemplateId;
            }
        }

        private set;
    }*/

    private boolean isSendingEmailsDisabled
    {
        get
        {
            Send_Trigger_Email_Alerts__c testObject = Send_Trigger_Email_Alerts__c.getInstance('Roadnet');
            if (testObject == null)
            {
                return true;
            }
            util.debug('Send_Trigger_Email_Alerts__c.isDisabled__c: ' + testObject.isDisabled__c);
            return testObject.isDisabled__c;
        }
    }

    private Id rtsSupportOrgWideEmailId
    {
        get
        {
            OrgWideEmailAddress rtsSupport = [select id from  OrgWideEmailAddress where displayname = 'Roadnet Support' order by lastmodifieddate desc limit 1];
            if (rtssupport != null)
            {
                return rtsSupport.id;
            }
            else
            {
                return null;
            }
        }
    }

    ////////////////////////////  TRIGGER OPERATIONS  ////////////////////////////////////////////////////////////////////////////////

    public void BeforeInsert(List<SObject> newItems) {}

    public void BeforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {}

    public void BeforeDelete(Map<Id, SObject> oldItems) {}

    public void AfterInsert(Map<Id, SObject> newItems) {
        LeadActivityUtils.updatePartnerDrivenActivity(newItems.values());
        OpportunityActivityUtils.updatePartnerDrivenActivity(newItems.values());

        //  be advised, this is pulled from Roadnet's AttachmentTrigger to consolidate the triggers we have
        //  logic has changed to handle bulk attachment creation --joseph hutchins
        updateCustomReportNames();
        if (!isSendingEmailsDisabled) {
            try
            {
                emailAlertForFilesAttachedToCases();
            }
            catch (Exception e) {
                util.debug('-- Sending email alerts for attached files failed due to: ' + e.getMessage());
            }
        }

        // Added by Arman Shah: For files attached to FF Projects of type "SVR":
        try {
            emailAlertForFilesAttachedToProjects(newItems.values());
        }
        catch(Exception e)
        {
            util.debug('-- Sending email alerts for SVR files attached to Projects failed due to: ' + e.getMessage());
        }
    }

    public void AfterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
        LeadActivityUtils.updatePartnerDrivenActivity(newItems.values());
        OpportunityActivityUtils.updatePartnerDrivenActivity(newItems.values());
    }

    public void AfterDelete(Map<Id, SObject> oldItems) {}

    public void AfterUndelete(Map<Id, SObject> oldItems) {}

    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    private void updateCustomReportNames()
    {
        System.debug('-- START: updateCustomReportNames');
        System.debug('-- Trigger.New ='+Trigger.new);
        Set<Id> parentIdsOfAttachments = retrieveParentIds(Trigger.new);
        try
        {
            //  put this in a try block, because we are blindly querying for attachments pointing to custom reports,
            //  if none of them do, this becomes a exception and will cause all attachments to not be inserted
            List<Custom_Report__c> customReportsOfAttachments =
                [select id, name from Custom_Report__c where id in: parentIdsOfAttachments];

            if (customReportsOfAttachments != null && customReportsOfAttachments.size() > 0)
            {
                for (Custom_Report__c cr : customReportsOfAttachments)
                {
                    Attachment attachmentOfCustomReport = findAttachment(cr.id, Trigger.new);
                    if (attachmentOfCustomReport != null)
                    {
                        cr.name = attachmentOfCustomReport.name;
                    }
                }
                update customReportsOfAttachments;
            }
        }
        catch(Exception e)
        {
            //  do nothing... or should it throw exception due to the update on custom reports causing a failure?
        }
        System.debug('-- END: updateCustomReportNames');
    }

    private void emailAlertForFilesAttachedToCases()
    {
        System.debug('-- START: emailAlertForFilesAttachedToCases');
        System.debug('-- Trigger.New ='+Trigger.new);
        Set<Id> attachmentParentIds = retrieveParentIds(Trigger.new);
        List<Case> casesOfAttachments;

        //  need to see if any of the attachments point to a case, if so we have some other queries to make
        try
        {
            util.debug('trying to query cases of attachments if they point to cases');
            casesOfAttachments = [select id, ownerid, business_unit__c, recordtypeid, recordtype.name, casenumber, accountid, account.name,
                    contactid, contact.name, subject, contact.email
            from case where id in: attachmentParentIds and
            Business_unit__c = 'Roadnet' and
            RecordType.name = 'Call Center'];
            util.debug('cases of attachments query finished.  num returned; ' + (casesOfAttachments == null ? 0 : casesOfAttachments.size()));
        }
        catch(Exception e)
        {
            util.debug('low priority exception occured while trying to query for the cases of attachments: ' + e.getMessage());
            //  none of the attachments point to cases...
        }

        if (casesOfAttachments != null || casesOfAttachments.size() > 0)
        {
            //  so there are two types of alerts that this can send off
            //  1-an alert for a internal user adding a file to a portal case
            //  2-alert for when portal user adds file to portal case
            //  either way we need to requery the attachmetns to get the createdby.profile.name
            Attachment[] attachmentsRequeried =
            [select id, name, parentid, createdbyid, createdby.name, createdby.profile.name from Attachment where id in: Trigger.new];

            List<Attachment> portalUserCreatedAttachments = new List<Attachment>();
            util.debug('beginnning check for portal user created attachments...');
            //  ------------------------------BEGIN THE CHECK FOR PORTAL USER CREATED FIELDS---------------------------------
            for (Attachment a : attachmentsRequeried)
            {
                if (a.createdby.profile.name != null && a.createdby.profile.name.contains('Customer Community'))
                {
                    //  these can include attachments from non roadnet partner users so be careful... the case business unit check will take care of that
                    portalUserCreatedAttachments.add(a);
                }
            }
            util.debug('num of portal user created attachments found: ' +
                    (portalUserCreatedAttachments == null ? 0 : portalUserCreatedAttachments.size()));

            if (portalUserCreatedAttachments != null && portalUserCreatedAttachments.size() > 0)
            {
                List<Messaging.SingleEmailMessage> portalUserCreatedAttachmentEmailsToSend = new List<Messaging.SingleEmailMessage>();
                for (Attachment a : portalUserCreatedAttachments)
                {
                    //  find the cvase the attahcment is pointing too
                    //  generate email and then send it
                    Case caseOfAttachment = findCase(a.parentId, casesOfAttachments);
                    util.debug('case of attachment found: ' + caseOfAttachment);
                    if (caseOfAttachment != null)
                    {
                        Case c = caseOfAttachment;//  lazy and dont want to find and replace on a 'c' char

                        string ownerIdToSTring = c.ownerId;
                        if (c.Business_Unit__c == 'Roadnet' && c.recordtype.name == 'Call Center' && !ownerIdToString.contains('00G'))
                        {
                            string subject = 'Case #' + c.CaseNumber + ' has had a file attched: '  + a.name;
                            string htmlbody = CaseEventExtension.RT_EMAIL_HEADER_IMAGE + '<br /><br />' +
                                    'Portal User, <b>' + a.CreatedBy.Name + '</b>, has attached <b>"' + a.name + '"</b> file to Case ' +
                                    EmailClassRoadnet.createHyperLink(Util.base_url + c.id, '#' + c.caseNumber ) +'<br /><br />' +
                                    generateEmailBodyForFileAttachment(a, c);

                            portalUserCreatedAttachmentEmailsToSend.add(
                                    EmailClassRoadnet.createMailInternalUser(c.ownerId, subject, htmlbody, null));
                        }
                    }
                }
                util.debug('finished looking for attachments created by portal users.  num of emails to get sent out: ' +
                        (portalUserCreatedAttachmentEmailsToSend == null ?  0 : portalUserCreatedAttachmentEmailsToSend.size())  ) ;

                if (portalUserCreatedAttachmentEmailsToSend != null &&
                        portalUserCreatedAttachmentEmailsToSend.size() > 0)
                {
                    EmailClassRoadnet.sendMultipleEmails(portalUserCreatedAttachmentEmailsToSend);
                    util.debug('portal user created attachments email should have been sent out');
                }
            }

            //  next we will check for attachments created by internal users for portal cases, but want to test the up above first
            //  testing for the up above was good, now need to code the internal user creating the attahcment piece
            //  for this we need to know if the case's owner is portal user... easier way to do this is not easy
            //  we have to see if the contact of the case has an portaluser record... there is no other way, i have checked that the contact
            //  table and am not finding any bool/picklist on there to state that, so we'll need to query all roadnet customer users... at the least

            List<Messaging.SingleEmailMessage> interalUserCreatedEmailsToSend = new List<Messaging.SingleEmailMessage>();
            util.debug('about to begin check for interal user created attachments for portal cases...');

            List<User> roadnetPortalUsers = [select id, contactid, profile.name, isactive, business_unit__c from user where contactid != null and
            profile.name like '%Customer Community%' and business_unit__c = 'Roadnet' and isactive = true ];
            util.debug('num of roadnet portall users returned: ' + (roadnetPortalUsers == null ? 0 : roadnetPortalUsers.size()));

            //  now scroll thru the cases seeing if any of the contact.contactid mataaches a portaluers.contactid
            for (Attachment a : attachmentsRequeried)
            {

                Case tempCase = findCase(a.parentid, casesOfAttachments);
                util.debug('found case of attachment: ' +
                        ' tempCase.Business_Unit__c: ' + tempCase.Business_Unit__c +
                        ' tempCase.recordtype.name:' + tempCase.RecordType.Name +
                        ' tempCase.contact.email: ' + tempCase.contact.email +
                        ' a.createdby.profile.name: ' + a.createdby.profile.name +
                        ' isCaseContactPortaluser(tempCase.contactid, roadnetPortalUsers): ' + CaseEventExtension.isCaseContactPortaluser(tempCase.contactid, roadnetPortalUsers));


                if (tempCase != null &&
                        tempCase.Business_Unit__c == 'Roadnet' &&
                        tempCase.recordtype.name == 'Call Center' &&
                        tempCase.contact.email != null &&
                        a.createdby.profile.name != null &&
                        !a.createdby.profile.name.Contains('Customer Community') &&  //  user creating attachment is not a portal user
                        CaseEventExtension.isCaseContactPortaluser(tempCase.contactid, roadnetPortalUsers))
                {
                    //  found the reason i couldnt use an email template with this... the attachment is not available
                    //  for the email temapte so i cant reference it in the body the email. so this is another hard coded email
                    string subject = 'Your case #' + tempCase.CaseNumber + ' has had a file attached to it by: ' + a.createdby.name;
                    string htmlbody = CaseEventExtension.RT_EMAIL_HEADER_IMAGE + '<br /><br />' +
                            'A file has been attached to your case by ' + a.createdBy.name + '.<br /> <br/>' +
                            generateEmailBodyForFileAttachment(a, tempCase);
                    interalUserCreatedEmailsToSend.add(
                            EmailClassRoadnet.createMail(tempCase.contact.email, subject, htmlbody, rtsSupportOrgWideEmailId));
                }
            }
            util.debug('num of emails to be sent out to portal contacts: ' + interalUserCreatedEmailsToSend.size());
            if (interalUserCreatedEmailsToSend.size() > 0)
            {
                EmailClassRoadnet.sendMultipleEmails(interalUserCreatedEmailsToSend);
            }
        }
        System.debug('-- END: emailAlertForFilesAttachedToCases');
    }

    private string generateEmailBodyForFileAttachment(Attachment a, Case c)
    {
        return '<b>Attachment:</b>    ' + EmailClassRoadnet.createHyperLink(util.base_url + a.id, a.name) + '<br /><br />' +
                '<b>Case:</b>    ' + EmailClassRoadnet.createHyperLink(Util.base_url + c.id, '#' + c.caseNumber ) + '<br /><br />' +
                '<b>Account:</b>    ' + EmailClassRoadnet.createHyperLink(util.base_url + c.accountid, c.account.name) + '<br /><br />' +
                '<b>Contact:</b>    ' + EmailClassRoadnet.createHyperLink(util.base_url + c.contactid, c.contact.name) + '<br /><br />' +
                '<b>Case Subject:</b>    ' + c.Subject + '<br /><br />';
    }

    private static Case findCase(id recordId, List<Case> cases)
    {
        for (Case c : cases)
        {
            if (c.id == recordId)
            {
                return c;
            }
        }
        return null;
    }

    @TestVisible private static Attachment findAttachment(id recordId, List<Attachment> attachments)
    {
        for (Attachment a : attachments)
        {
            if (a.parentId == recordId)
            {
                return a;
            }
        }
        return null;
    }

    private static Set<Id> retrieveParentIds(List<Attachment> attachments)
    {
        Set<Id> parentIds = new Set<id>();
        for (Attachment a : attachments)
        {
            if (!parentIds.contains(a.parentid))
            {
                parentIds.add(a.parentId);
            }
        }
        return parentIds;
    }

    /****************************************************************************************************************
      Author:   Arman Shah
      Date:     10/11/2018
      Function:
            - Find Attachments created for pse__Proj__c
            - Check if Attachment filename contains "SVR"; if yes, then fill out Email template values,
            then send email to SVR Group in Production, else email the User
    ****************************************************************************************************************/
    public static Messaging.SendEmailResult[] emailAlertForFilesAttachedToProjects(List<Attachment> attachments)
    {
        // Find parent Project for Assessment and check if it contains "SVR" in filename.
        List<Attachment> svrAttachments = new List<Attachment>();
        for (SObject so : attachments) {
            Attachment a = (Attachment) so;
            Id projId = a.parentId;
            System.debug('-- Schema.pse__Proj__c.sObjectType = '+Schema.pse__Proj__c.sObjectType);
            System.debug('-- projId.getSobjectType() = '+projId.getSobjectType());

            if (Schema.pse__Proj__c.sObjectType == projId.getSobjectType()) {
                if (!String.isBlank(a.Name) && a.Name.contains(SVR_FILE)) {
                    svrAttachments.add(a);
                }
            }
        }
        System.debug('-- svrAttachments size ='+svrAttachments.size());

        if (svrAttachments.isEmpty()) {
            return null;
        }
        else {
            return sendSvrAttachmentsEmail(svrAttachments);
        }
    }

    public static Messaging.SendEmailResult[] sendSvrAttachmentsEmail(List<Attachment> attachments)
    {
        Messaging.SendEmailResult[] sendEmailResults;

        List<EmailTemplate> et = [SELECT Id FROM EmailTemplate WHERE Name =: SVR_EMAIL_TEMPLATE];

        List<Messaging.SingleEmailMessage> mailList;
        Messaging.SingleEmailMessage mail;

        if (attachments != null && !attachments.isEmpty() && et != null && !et.isEmpty()) {
            // Send email to SVR group (Use Custom Metadata type)
            List<String> svrEmailAddress = new List<String>();

            if (EmailClassRoadnet.isUserInSandbox()) {
                svrEmailAddress.add(UserInfo.getUserEmail());
            }
            else {
                SVR_Email_Setting__mdt prodEmailMdt =
                    [SELECT EmailAddress__c FROM SVR_Email_Setting__mdt WHERE Label =: SVR_EMAIL_LABEL_PROD];
                svrEmailAddress.add(prodEmailMdt.EmailAddress__c);
            }
            System.debug('-- svrEmailAddress: ' + svrEmailAddress);

            Contact con = [SELECT Id FROM Contact LIMIT 1]; // Dummy Contact, for UnitTest also

            if (String.isBlank(svrEmailAddress[0])) {
                System.debug('-- There is NO email address supplied for SVR Attachment emails. --');
            }
            else {
                mailList = new List<Messaging.SingleEmailMessage>();
                for (Attachment a : attachments) {
                    // Fill EmailTemplate values
                    mail = new Messaging.SingleEmailMessage();
                    mail.templateId = et.get(0).Id;
                    mail.setTreatTargetObjectAsRecipient(false);
                    if (con == null) {
                        mail.targetObjectId = UserInfo.getUserId(); // Unused
                    }
                    else {
                        mail.targetObjectId = con.Id; // Unused; dummy contact
                    }
                    mail.whatId = a.parentId; // FF Project Id
                    mail.setToAddresses(svrEmailAddress);
                    mailList.add(mail);
                }

                if ( ! mailList.isEmpty()) {
                    System.debug('-- mailList = ' + mailList);
                    sendEmailResults = Messaging.sendEmail(mailList);
                    System.debug('-- sendEmailResults = ' + sendEmailResults);
                }
            }
        }
        return sendEmailResults;
    }
}