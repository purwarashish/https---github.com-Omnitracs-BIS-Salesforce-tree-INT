/*******************************************************************************
 * File:  RnaApexEmailerController.cls
 * Date:  December 27, 2013
 * Author:  Joseph Hutchins
 * The use, disclosure, reproduction, modification, transfer, or transmittal of
 * this work for any purpose in any form or by any means without the written 
 * permission of United Parcel Service is strictly prohibited.
 *
 * Confidential, unpublished property of United Parcel Service.
 * Use and distribution limited solely to authorized personnel.
 *
 * Copyright 2009, UPS Logistics Technologies, Inc.  All rights reserved.
 *  *******************************************************************************/
public with sharing class RnaApexEmailerController
{
    public RnaApexEmailerController()
    {
        showMainPage = true;
        showEmailSuccessfulPage = false;
        showEmailFailurePage = false;
        isTestMode = true;
        showPlannedEmailTemplatePageMessage = false;
        testContactEmailAddress ='';
        
        //  hard coding two reasons, 1-need something so email template picklist has values 2- we dont know what the folders are until after the
        //  constructor has run.
        setRnaProductAlertFolderId();
        
        folderUserSelection = RNA_PRODUCT_ALERT_FOLDER_ID;
        folderPicklistOnChange();//  call this to populate the emailTemplatePicklist
        emailTemplateUserSelection = pl.none;
        
        /* no prepoupluation, user must select a template
        if (emailTemplatePicklist != null && emailTemplatePicklist.size() > 0)
        {
            emailTemplateUserSelection = emailTemplatePicklist[0].getvalue();
        }*/
        /*
        if (!Util.isBlank(emailTemplateUserSelection) &&  emailTemplateUserSelection != pl.none)
        {
           selectedEmailTemplate = queryEmailTemplate(emailTemplateUserSelection);//  pre query the template so that is shows on the screen
        }
        else
        {
            selectedEmailTemplate = new EmailTemplate();
        }
        */
        
        caseEventContactLookupOnly = new Case_Event__c();
        m_rnaApexContacts = [select id, name, email, hasOptedOutOfEmail, accountid, account.name, inactive__c, account.account_status__c from 
           Contact where inactive__c = false AND
              HasOptedOutOfEmail = false and
              accountId != null and
              Account.Account_Status__c != 'Inactive' and 
              Is_RNA_Apex_Contact__c = true AND
              email != null ];
        
        rnaApexContactsEmailsToString = '';
        //  this is used to show all of the emails of the rna apex customer's emails in a string seperated by semicolons that could be placed
        //   in a to: box in any email system
        for (Contact singleApexContact : m_rnaApexContacts) 
        {
            if (singleApexContact.Email != null)
            {
               rnaApexContactsEmailsToString +=  singleApexcontact.Email + '; ';
            }
        }
        
    }

    
    public boolean showMainPage
    {
        //  let me explain why this is here and why the bools are needed.  once a user sends the emails we need to know at least 1 thing
        //  1. did the emails get sent and if not, which ones and why didn't they get sent.  my original design was to have two seperate pages
        //  that handled the logic for when the emails failed/succded..  i was going to use this same controller as this knows
        //  whether or not he emails were sent in the SendEmailResults.... tesing shows that the other vf pages did not have access to the
        //  sendemailresults the way i thought they would so using seprerate pages wont work.  instead i'm going to use the same page
        //  and manage what shows by using these three bools: showMainPage, showEmailSuccessfulPage, showEmailFailurePage
        //  basicallly once the sendEmails button is pressed, the three bools will be set depending on the result of the email sending
        get;set;
    }
    public id COMPANY_PROFILE_ID
    {
        get
        {
            //  a little background on this, this is used to get the "Unfiled Public Reports" folder in salesforce as its id matches the org
            //  there doens't appear to be a global static variable for getting the org id, you can get one via the userInfo.getOrgId
            //  but that is going to change dependong on sandbox/live, so this has to continue being a hardcoded id
            if (util.isRnEnvironment)
            {
                  return '00DQ000000GJZpq';
            }
            else if (util.isMibosEnvironment)
            {
                return '00DR0000001yEID';
            }
            else
            {
                return userInfo.getOrganizationId();//  hopefully this works *gulp*
            }
             
        }
    }
    public boolean showEmailSuccessfulPage{get;set;}
    public boolean showEmailFailurePage{get;set;}
    public string folderUserSelection{get;set;}
    public string emailTemplateUserSelection{get;set;}
    public boolean isTestMode{get;set;}
    public Case_Event__c caseEventContactLookupOnly{get;set;}
    public transient List<Messaging.sendemailResult> sendEmailResults;
    public EmailTemplate selectedEmailTemplate{get;set;}
    public boolean showPlannedEmailTemplatePageMessage{get;set;}
    public string testContactEmailAddress{get;set;}
    public string rnaApexContactsEmailsToString{get;set;}
    public string detailedHelpText    
    {
        get
        {
            return 'Select whether the email will be sent to all RNA Apex Contacts in the system or to a test contact.  ' +
              'Please select the appropriate template for Planned or Unplanned Outage or Service Restoration.  ' +
              'If \'Send Test Email\' is set, an email is sent to a contact of your choosing.';
        }
        
    }
    public Id roadnetCustomerServiceOrgWideEmail
    {
        get
        {
            if (util.isRnEnvironment)
            {
                return '0D230000000007l';
            }
            else
            {
                return null;
            }
        }
    }
    
    public string plannedEmailTemplatePageMessageDetail 
    {
        get
        {
            return 'The email template selected has body text that needs to be updated.  ' +
              'Please make sure the planned outage DATE and VERSION have been updated.';
        }
    }
    
    public id plannedOuttageEmailTemplateId
    {
        get
        {
            EmailTemplate et;
            try
            {
                et = [select id, name from EmailTemplate where name = 'RNA Planned Outage' and IsActive = true order by name];
                return et.id;
            }
            catch(Exception e)
            {
                return null;
            }
            
            
            /*
            if (EmailClassRoadnet.IsUserInSandbox())
            {
                return '00XQ0000000EFqW';
            }
            else
            {
                return '00X30000001PoOQ';
            }
            */
            
        }
    }
    
    public id RNA_PRODUCT_ALERT_FOLDER_ID{get;set;}
   
    private void setRnaProductAlertFolderId()
    {
        if (util.isRnEnvironment)
        {
           // RNA_PRODUCT_ALERT_FOLDER_ID = '00l30000003Jtp8AAC';
           try
            {
                RNA_PRODUCT_ALERT_FOLDER_ID = [select id from Folder where type = 'Email' and name = 'Roadnet Anywhere Product Alerts' LIMIT 1].id;
            }
            catch(Exception e)
            {
                RNA_PRODUCT_ALERT_FOLDER_ID = null;
            }
        }
        else
        {
            try
            {
                RNA_PRODUCT_ALERT_FOLDER_ID = [select id from Folder where type = 'Email' and name = 'Roadnet Anywhere Product Alerts' LIMIT 1].id;
            }
            catch(Exception e)
            {
                RNA_PRODUCT_ALERT_FOLDER_ID = null;
            }
        }
    }
    
    public List<SelectOption> emailTemplateFolders
    {
        get
        {
            //  so need to query all folders whose type = email template
            Folder[] emailTemplateFolders = [select id, type, name from Folder where Type = 'Email' order by name];
            List<SelectOption> options = new List<SelectOPtion>();
            for (Folder singleFolder : emailTemplateFolders)
            {
                options.add(new selectoption(singleFolder.id, singleFolder.name));
            }
            string unfiledPublicEmailTemplates = 'Unfiled Public Email Templates';
            options.add(new selectoption(COMPANY_PROFILE_ID, unfiledPublicEmailTemplates));
            return options;
        }
    }
    private List<SelectOption> m_emailTemplates;
    
    public List<selectoption> emailTemplatePicklist
    {
        get
        {
            //  so we want to give the users ability to pick email template, but templates are stored in folders and such, so we'll need
            //  folder picklist also
            return m_emailTemplates;
        }
        set
        {
            m_emailTemplates = value;
        }
    }
    
    public boolean didAnyEmailFailSending
    {
        get
        {
            if (sendEmailResults != null)
            {
                for (Messaging.sendemailResult ser : sendEmailResults)
                {
                    if (!ser.isSuccess())
                    {
                        return true;
                    }
                }
                return false;
            }
            else
            {
                return true;
            }
        }
    }

    public map<string,string> urlParamMap
    {
        get
        {
            return apexpages.currentpage().getParameters();
        }
    }
  
    private List<Contact> m_rnaApexContacts;
    
    public List<Contact> rnaApexContacts
    {
        get
        {
            return m_rnaApexContacts;
        }
        set
        {
            m_rnaApexContacts = value;
        }
    }

    public List<EmailFailure> sendEmailFailures{get;set;}
    
    public PageReference refreshPage()
    {
        return null;
    }
    public PageReference testContactLookupOnChange()
    {
        Contact tempContact;
        if (caseEventContactLookupOnly.Contact__c != null)
        {
            tempContact = [select id, email from contact where id =: caseEventContactLookupOnly.Contact__c];
            testContactEmailAddress = tempContact.Email;
        }
        else
        {
            testContactEmailAddress = null;
        }
        return null;
        
    }
    public PageReference emailTemplatePicklistOnChange()
    {
        //  just need to query the selected email template so we show preview on the page
        if (!Util.isBlank(emailTemplateUserSelection) && emailTemplateUserSelection != pl.none)
        {
            selectedEmailTemplate = queryEmailTemplate(emailTemplateUserSelection);
            if (plannedOuttageEmailTemplateId != null &&
              selectedEmailTemplate.id == plannedOuttageEmailTemplateId)
            
            {
                showPlannedEmailTemplatePageMessage = true;
            }
            else
            {
                showPlannedEmailTemplatePageMessage = false;
            }
        }
        else
        {
            selectedEmailTemplate = new EmailTemplate();
            showPlannedEmailTemplatePageMessage = false;
        }
        return null;
        
    }
    public PageReference folderPicklistOnChange()
    {
        //  i needed to find to find out what the name of the folder was that stores email templates in the folder called "Unfiled Public Email Templates"
        //  i quereid two email templatest that are in the that "folder" and the folderId returne for that email template is: 00DQ000000GJZpqMAH
        //  when put into salesfsorce url, i get the company profile page for us.... so i'm going to assume that any emial template whose folderid = our org id
        //  is in the unfiled public email template folder
        //   testing shows that this is assumption is correct
        //  so if the user has picked Unfiled Public Email Templtes, we'll popualte that list with email templates whose folder id = our org id
        EmailTemplate[] templates;
        
        if (folderUserSelection == COMPANY_PROFILE_ID)
        {
            //  query unfiled email templates
            templates = [select id, name from EmailTemplate where folderid =: COMPANY_PROFILE_ID and IsActive = true order by name];
            
        }
        else
        {
            if (!util.isblank(folderUserSelection))
            {
                //  this will query templates based on folder seledction
                templates = [select id, name from EmailTemplate where folderid =: folderUserSelection and IsActive = true order by name];
            }
        }
        
        m_emailTemplates = new List<SelectOption>();
        m_emailTemplates.Add(pl.noneOption);
        
        if (templates != null)
        {
            for (EmailTemplate et : templates)
            {
                m_emailTemplates.add(new selectOption(et.id, et.name));
            }
        }
      
        return null;
    }

    public PageReference sendEmails()
    {
 
        //  need to confirm that the emails user has selected an email template
        if (util.isBlank(emailTemplateUserSelection)  || emailTemplateUserSelection == pl.none || selectedEmailTemplate == null)
        {
            ApexPages.addMessage(
                            new ApexPages.Message(ApexPages.Severity.WARNING, 'Please select an email template.'));
            return null;
        }
        EmailClassRoadnet.EmailTemplateEx[] emailsToSend = new List<EmailClassRoadnet.EmailTemplateEx>();
            
        //  if in test mode, we send the selected email to the logged in user only
        if (isTestMode)
        {
            util.debug('isTestMode is set. value of cae event contact field: ' + caseEventContactLookupOnly.Contact__c);
            
            if (util.isBlank(caseEventContactLookupOnly.Contact__c))
            {
                caseEventContactLookupOnly.Contact__c.AddError('Please select a contact to send test emails to.');
                return null;
            }
            Contact tempContact = 
                [select id, accountid, HasOptedOutOfEmail, inactive__c, is_rna_apex_contact__c, account.Account_Status__c from contact where id =: caseEventContactLookupOnly.Contact__c];
            
            util.debug('temp contact should have been queried here is its id: ' + tempContact.id);
            
            if (!isContactValidForTestEmail(tempContact))
            {
                return null;//  the method will add the apprioate errors to the page
            }
            
            //  if the contact is valid, we'll send the email out to them and their account
            

            //  ive created a new object and method both living in the emailClass for this
            //  the reason for this was becuase the other methods do not have the fucntiantly that is needed here
            //  i need to be able to send email templates in mass, have apex records created for each one
            //  so we have a new object called EmailTemplateEx, it will hold the data for the email sending
            //  ill pass in a list of thsee emailtemplateex to a method that will send the emails, create the apexemail records
            //  and reutnr then sendresults so i can either show a successfull for failure page
            EmailClassRoadnet.EmailTemplateEx tempMail = new EmailClassRoadnet.EmailTemplateEx();
            tempMail.targetId = tempContact.Id;
            
            
            tempMail.whatId = tempContact.AccountId; //  when testing with whatid = jane's test account, i got error that whatid cannot be used for userids. so this will be null
            util.debug('tempMail.targetId is ' + tempMail.TargetId + ' tempMail.WhatId = ' + tempMail.WhatId);
            
            tempMail.saveAsActivity = false;//  as above, got error that it must false if sending to users
            tempMail.ccAddresses.add(userInfo.getUserEmail());//  its ok if the current user is still cc'd on the email mesage
            
            system.assertNotEquals(null, selectedEmailTemplate);
            tempMail.templateId = selectedEmailTemplate.id;
            
            emailsToSend.Add(tempMail);
        }
        else
        {
            //  i moved all of the logic in here to a method to make this easier to read
            //  what this does is checks if we are sending emails to all contacts or just an accounts contacts
            //  it then creates emailtemplateex records and returns them for this method to send the email
            EmailClassRoadnet.EmailTemplateEx[] realContactMailRecords = createRealContactEmails();
            if (realContactMailRecords != null)
            {
                emailsToSend = realContactMailRecords;
            }
        
        }
        
        //  so the part up above has created the email template objects so all we have to do is passed them into the emailclass
        //  snedEmailwithTemplate method and check the results for any failures
        sendEmailResults = EmailClassRoadnet.sendEmailsWithTemplate(emailsToSend);
            
        if (didAnyEmailFailSending)
        {
            //  we want to show the failure page which will contain detailed informaion about the email sending failures
            showEmailSuccessfulPage = false;
            showMainPage = false;
            showEmailFailurePage = true;
            sendEmailFailures = new List<EmailFailure>();
            
            system.assertEquals(sendEmailResults.size(), emailsToSend.size());//  read note below to see why the assertion is here
            
            for (integer i = 0; i < sendEmailResults.size(); i++)
            {
                //  so here's my current problem... the emailsend result doesn't have the toEmail address so i'll need to scroll thru both the 
                //  mails that were sent and the email results to get the toEmail and the error message, i've never did this before so I HOPE
                //  that the sendEmailResults list contains the same amount of items in the createMail list... i also have to HOPE
                //  that list of results are in the same order as the createdEmail list....
                if (!sendEmailResults[i].isSuccess())
                {
                    EmailFailure ef = new EmailFailure(
                        string.valueof(emailsToSend[i].targetId),
                        convertErrorsToString(sendEmailResults[i].getErrors()),
                        emailsToSend[i].contactName,
                        emailsToSend[i].contactEmailAddress
                        );
                    sendEmailFailures.add(ef);
                }
            }
            
        }
        else
        {
            //  we want to show the failure page which will contain detailed informaion about the email sending failures
            showEmailSuccessfulPage = true;
            showMainPage = false;
            showEmailFailurePage = false;
        }
        
        return null;
        
    }
    public PageReference cancel()
    {
        string returnUrl = urlParamMap.get('retURL');
        
        PageReference pr;
        if (returnURl != null)
        {
            pr = new PageREference(returnUrl);
        }
        else
        {
            pr = new PageREference('/home/home.jsp');
        }
        pr.setRedirect(true);
        return pr;
    }
    
    public boolean isContactValidForTestEmail(Contact tempContact)
    {
        boolean isOkToSend = true;
        
        //  confirm that that the contact is not active and can receive emails
        if (tempContact.HasOptedOutOfEmail)
        {
            caseEventContactLookupOnly.Contact__c.AddError('The selected contact has opted out of emails.  Please select a different contact.');
            isOkToSend = false;
        } 
        if (tempContact.inactive__c)
        {
            caseEventContactLookupOnly.Contact__c.AddError('The selected contact has is Inactive.  Please select an Active contact.');
            isOkToSend = false;
        }
        if (tempContact.AccountId == null)
        {
            caseEventContactLookupOnly.Contact__c.AddError('The selected contact has is not associated with an account.  Please select a contact assoicated with an account.');
            isOkToSend = false;
        }
        /*
        if (!tempcontact.is_rna_apex_contact__c)
        {
            caseEventContactLookupOnly.contact__c.AddError('The selected contact is not an RNA Apex Contact.  Please select an RNA Apex Contact.');
            isOkToSend = false;
        }*/
    
        if (tempContact.AccountId != null &&
           tempContact.Account.Account_Status__c != null &&
           isAccountInactive(tempContact.Account.Account_Status__c))
        {
            caseEventContactLookupOnly.Contact__c.AddError(
              'The selected contact belongs to an account that is inactive.  Please select a contact that is assoicated with an active account.');
            isOkToSend = false;
        }
        return isOkToSend;
    }
    private List<EmailClassRoadnet.EmailTemplateEx> createRealContactEmails()
    {
        system.assertNotEquals(null, selectedEmailTemplate);
        
        List<EmailClassRoadnet.EmailTemplateEx> emailsToReturn = new List<EmailClassRoadnet.EmailTemplateEx>();
        
        //  this is the real deal holyfield.  
        //  i think we give the user two choices, to email ALL rna contacts or just one account's contacts
        //  at the end of the day, i just need a list of contacts where the emailopt is false
        //  so we have two contact lists, m_rnaApexContacts and singleAccountContacts
        Contact[] contactsThatWillBeEmailed = m_rnaApexContacts;          
        
       for (Contact singleContact : contactsThatWillBeEmailed)
       {
            //  confirm that the contact emailoptOut is false, i thought the email template
            //  would verify this but testing shows does it does not
            system.assertNotEquals(true, singleContact.HasOptedOutOfEmail);
            system.assertNotEquals(true, singleContact.inactive__c);
            system.assertNotEquals(true, isAccountInactive(singlecontact.Account.Account_Status__c));
            
            EmailClassRoadnet.EmailTemplateEx tempMail = new EmailClassRoadnet.EmailTemplateEx();
            tempMail.targetId = singleContact.Id;
            tempMail.whatId = singleContact.AccountId;
            tempMail.templateId = selectedEmailTemplate.id;
            tempMail.saveAsActivity = false;
            tempMail.contactName = singleContact.Name;
            tempMail.contactEmailAddress = singleContact.Email;
            emailsToReturn.Add(tempMail);  
       }
       
        return emailsToReturn;
    }


    private static EmailTemplate queryEmailTemplate(string templateId)
    {
        return [select id, htmlvalue, subject, name, body from EmailTemplate where id =: templateId];
    }
    private static boolean isAccountInactive(string accountStatus)
    {
        if (accountStatus == null)
        {
            return true;//  account has no type set?  its inactive by default
        }
        else
        {
           return accountStatus == 'Inactive';
        }
    }
 
    private static string convertErrorsToString(List<Messaging.SendEmailError> emailErrors)
    {
        //  first time bulding osmething like this so bear with me
        //  the sendEmailError has 4 getters, i only need and care about 3
        string stringToReturn = '';
        if (emailErrors == null || emailErrors.size() == 0)
        {
            return 'No Error';
        }
        else
        {
            //  there should only be one item in the email error list but ill will cursor thru and add counter info
            for (integer i = 0; i < emailErrors.size(); i++)
            {
                stringToReturn += '[' + i + '] Error: ' + emailErrors[i].getMessage() + 
                    ' StatusCode: ' + emailErrors[i].getStatusCode() + 
                    ' Fields: ' + EmailClassRoadnet.convertListStringsToOneString(emailErrors[i].getFields()); 
            }
            
            return stringToReturn;
        }
    }
    public class EmailFailure
    {
        public EmailFailure(string targId, string errMessage, string name, string email)
        {
            targetId = targId;
            errorMessage = errMessage;
            contactName = name;
            contactEmailAddress = email;
        }
        public string contactEmailAddress{get;set;}
        public string contactName{get;set;}
        public string targetId{get;set;}
        public string errorMessage{get;set;}
        
        
    }
    
    public class myException extends Exception{}
}