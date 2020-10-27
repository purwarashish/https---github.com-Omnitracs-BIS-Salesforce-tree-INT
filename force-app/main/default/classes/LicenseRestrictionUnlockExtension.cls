/*******************************************************************************
 * File:  LicenseRestrictionUnlockExtension.cls
 * Date:  March 22nd, 2010
 * Author:  Joseph Hutchins
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
public class LicenseRestrictionUnlockExtension 
{
    //  used for throwing custom exceptions
    public class myException extends Exception{}
    
    //  **********  Member Variables  **********
    private Account account = new Account();
    private User loggedInUser = new User();
    
    //  **********  Constructor(s)  ***********
    public LicenseRestrictionUnlockExtension(apexpages.standardcontroller stdcontroller)
    {
        system.assertNotEquals(null, stdcontroller.getId());//  make sure an id is passed into controller
        account = [select id, name, /*Clientele_ID__c,*/ owner.email,  Alert_Text__c from Account where id = : stdcontroller.getId()];//  query account
        licenseTask = new Task();      
        licenseTask.whatId = account.id;//  assign account to lru record
        licenseTask.Description = 'Max # of routes needed:\nDetail any special reason for overage:';//  default to this per john wajer's request
        
        loggedInUser = [select id, email, profileId from User where id =: UserInfo.getUserId() ];//  query user id and email
        
        isSelectingPickList = true;//  default to true
    }
    
    //  **********  Setters and Getters  **********
    public Account getAccount(){return account;}
    public Task licenseTask{get;set;}
    
    public User getLoggedInUser(){return loggedInUser;}
    
    //  **********  Properties  **********
    public List<SelectOption> accountContacts
    {
        get
        {
            List<SelectOption> options = new List<SelectOption>();
            
            if (licenseTask.whatId == null)//  if account is not specified
            {
                options.add(pl.noneOption);
                return options;
            }
            else
            {
                Contact[] contacts = getContactsOfAccount(licenseTask.whatId, 100);
                for (Contact c : contacts)
                {
                    options.add(new SelectOption(c.id, c.name));
                }
                
                if (options.size() == 0)
                {
                    options.add(pl.noneOption);
                    return options;
                }
                else
                {
                    return options;
                }
            }
        }
    }
    public boolean isSelectingPickList{get; set;}
    public string pickListSelection
    {
        get
        {
            if (picklistSelection == pl.none)
            {
                picklistSelection = null;
            }
            return picklistSelection;
        }
        set;
    }
    
    //  **********  Public Instance Functions  ***********    
    
    public PageReference sendEmail()
    {
        if (isSelectingPickList)//  set the contact__c to null if the picklist was used and the option of none was selected
        {
            licenseTask.whoId = pickListSelection;
        }
        
        //  check that required fields are specfied
        if (isBlank(licenseTask.whoId))
        {
            licenseTask.whoId.addError('Need to specify a contact.');
            return null;
        }
        if (isBlank(licenseTask.Description))
        {
            licenseTask.description.addError('Need to specify a reason.');
            return null;
        }
        if (licenseTask.Description.length() > 255)//  reason can only be 255 chars in length
        {
            licenseTask.Description.addError('Reason length is too long.  Max is 255 chars.  Current length = ' + licenseTask.Description.length());
            return null;
        }
        licenseTask.whatid = account.id;
        licenseTask.license_activity__c = 'License Restriction Unlock';
        licenseTask.License_Key_date__c = date.today();
        licenseTask.Status = 'Completed';
        
        licenseTask.Subject = 'License Restriction Unlock code for ' + account.Name + ' provided on: ' + Date.Today().format() + '.';
        
        //  this method creates digest and sends email
        Messaging.SendEmailResult ser = createDigestAndSendEmail(account, loggedInUser);
        
        if (ser.isSuccess())//  if successful
        {
            try
            {
                database.saveResult sr = database.insert(licenseTask);
                if (sr.isSuccess())
                {
                    util.debug('task inserted id: ' + sr.getId());
                }
                else
                {
                    licenseTask.AddError('Failed to insert License Activity record.  However, the email was successfully sent.  Record insertion failed due to: ' + sr.getErrors()[0].getMessage());
                }
            }
            catch(Exception e)
            {
                licenseTask.AddError('Failed to insert License Activity record.  However, the email was successfully sent.  Record insertion failed due to: ' + e.getMessage());
                return null;
            }
            try
            {
                updateAccountAlertText();//  appends the account's alert text with LRU has been created message
            }
            catch(Exception e)
            {
                //  the account could fail update for any number of reasons, we still want the successful page to show 
            }
            
            string sfdcUrl = util.base_url;
            
            //  redirect user to email successful page
            PageReference pr = new PageReference('/apex/EmailSendSuccessful?retURL=' + sfdcUrl + account.id);
            
            pr.setRedirect(true);
            return pr;
        }
        else
        {
            licenseTask.addError(EmailClassRoadnet.convertSendEmailErrorsToString(ser.getErrors()));//  display error message on screen
            return null;
        }
    }
    
    public PageReference cancel()
    {
        PageReference pr = new PageReference('/' + account.id);
        pr.setRedirect(true);
        return pr;
    }
    /*  there is no bool on the user record that allows who can use the button so everyone or no one can use
    public PageReference verifyUserCanUseButton()
    {
        //  two checks need to be done here, firstly we need to see if the person is allow to create lru's at all
        //  if they are, then check to see if they can make multiple ones
        if (!loggedInUser.Can_Use_License_Restriction_Unlock__c)
        {
            return Page.Unauthorized;
        }       
        else
        {
            //  user is allowed to create at least one, check if they can create two
        }
        
        //  check by profile first (system admin)
        Id systemAdminProfileId = [select id from Profile where name = 'System Administrator'].id;
        if (loggedInUser.profileId == systemAdminProfileId)
        {
            return null;
        }
        
        //  now check to see if an lru record has already been created for the account
        integer recordCount = [select count() from License_Restriction_Unlock__c where Account__c =: account.Id];
        
        if (recordCount > 0 && !isUserSupportLead)
        {
            return LruNotAuthorizedPageRef;//  only john and zach and scott can create more than 1 lru unlock
        }
        
        
        if (loggedInUser.profileId == systemAdminProfileId)
        {
            return null;
        }
        else if (loggedInUser.Can_Use_License_Restriction_Unlock__c)
        {
            return null;
        }        
        else 
        {
            return Page.Unauthorized;
        }
    }
    */
    //  **********  Private Instance Functions  **********
    /*public PageReference LruNotAuthorizedPageRef
    {
        get
        {
            PageReference pr = Page.CaseInfoMessagePage;
            pr.getParameters().put('retURL', '/' + account.id);
            pr.getParameters().put('enum', '20');
            pr.setRedirect(true);
            return pr;
        }
    }
    */
   
    
    private void updateAccountAlertText()
    {
        string lruReason = Util.isBlank(licenseTask.Description) ? 'No Reason Given' : licenseTask.Description;
        
        string textToPrepend = 
           'License Restriction Unlock code for ' + account.Name + ' provided on: ' + Date.Today().format() + ' with Reason: ' + lruReason;
        if (account.Alert_Text__c == null || account.Alert_Text__c == '')
        {
            account.Alert_Text__c = textToPrepend;
        }
        else
        {
            account.Alert_Text__c = textToPrepend + '\n\n ' + account.Alert_Text__c;
        }
        update account;
    }
            
    //  **********  Static Functions  **********
    private Messaging.SendEmailResult createDigestAndSendEmail(Account a, User user)
    {
        system.assertNotEquals(null, a);
        system.assertNotEquals(null, user);
        system.assertEquals(false, isBlank(a.Id));
        
        string[] toEmailAddress = new List<string>();//  add the user email to email address
        //  we need to the contact that the email will be sent too
        //  to do that we need either the lookup field value or the picklist value
        Contact contact;
        if (isSelectingPicklist)
        {
            contact = [select id, firstname, email from contact where id =: picklistSelection];
        }
        else
        {
            contact = [select id, firstname,email from contact where id =: licenseTask.whoId];
        }
        toEmailAddress.add(contact.email);
        
        string subject = 'License Restriction Unlock for ' + a.name;//  subject of the email
        
        string orgId;//  use the clientele id if its specified, if not use the account Id.
        /*if (!isBlank(a.clientele_id__c))
        {
            orgId = a.Clientele_ID__c; 
        }
        else
        {*/
            orgId = a.id;
        //}
       
        
        //if (isBlank(a.Clientele_id__c))//  make sure if we are using the account id, that the length is 18 chars long
        //{
            system.assertEquals(18, orgId.length());
        //}
                
        DateTime now = DateTime.now();
                
        string formattedNowDate = now.formatGMT('yyyy/MM/dd'); 
        
        //  Jack requested that the date not contain slashes,
        formattedNowDate = formattedNowDate.replace('/', '');
                
        //  construct the digest, it is the date formatted in gmt using YYYY/MM/DD + OrgId
        string input = formattedNowDate + orgId;
                
        Blob binaryInput = EncodingUtil.base64Decode(input);//  convert the 'key' to binary
        Blob digestBlobFormat = Crypto.generateDigest('MD5', binaryInput);//  generate a digest using MD5 and the supplied binary data
        
        string digestStringFormat = EncodingUtil.convertToHex(digestBlobFormat);//  conver the binary data to a hexadecimal string 
        
        string htmlbody = 'Dear ' + contact.firstName + ', <br /><br />' +
            'The email below supplies an unlock code that will allow the region(s) that are locked out to utilize the Roadnet Transportation Suite.  ' + 
            'Please follow the steps below to apply this unlock code:<br /><br />' +
            '1. Highlight and copy this unlock code: <b> ' + digestSTringFormat + '</b> <br />' + 
            '2. Enter the <b>Administration module</b> of Roadnet Transportation Suite <br />' +
            '3. Go to <b>List- Regions - Regions</b> <br />' +
            '4. <b>Right-click on the region</b> that is experiencing the license lock out and select <b>Apply Restriction Unlock Code</b> <br />' +
            '5. <b>Paste</b> in the <b>unlock code provided</b> in this email and hit <b>Apply</b> <br />' +
            '6. Repeat this same process for any additional regions that are locked. Note: Locked regions will have red values in the RN Session Route Limit column.  <br /><br />' +
            'This code will provide a one-time, 28 day grace period on the license violation lock-out and allow your organization to use the system ' + 
            'while you work with your Roadnet Account manager to permanently address this concern. ' + 
            'You will still receive warning messages but will not be locked out during this 28 day period, ' + 
            'but it is imperative that you contact your Roadnet Account manager on this matter as no additional unlock codes can be provided. ' + 
            'Please call 800-ROADNET if you are experiencing any issues with applying this unlock code.';
        util.debug('digestStringFormat = ' + digestSTringFormat);
        util.debug('html body = ' + htmlBody);

        //  create a mail record, this will be sent to the customer only
        Messaging.SingleEmailMessage customerEmail = emailclassRoadnet.createMail(toEmailAddress, subject, htmlbody, null);

        //  now we construct the internal email which is the same as the customer's email except with the lru's reason text added to the end (or beginning of the email)
        List<string> internalToEmail = new List<string>();
        internalToEmail.add(user.email);
        internalToEmail.add(account.owner.email);
        /*internalToEmail.add('zevans@roadnet.com');
        internalToEmail.add('jwajer@roadnet.com');
        internalToEmail.add('rree@roadnet.com');
        //internalToEmail.add('shildebrand@roadnet.com');
        internalToEmail.add('dkalwani@omnitracs.com');
        */
        
        //  removed teh hardcoding of these recieipitnes and created a custom setting that has the email addresses
        set<string> emailRecipients;
        try
        {
        	emailRecipients = LRU_Email_Recipients__c.getAll().keySet();
        }
        catch(Exception e)
        {
        	util.debug('failed to get custom setting email recipients for LRU_Email_Recipients__c due to: ' + e.getMessage());
        	
        }
        if (emailRecipients != null && emailRecipients.size() > 0)
        {
            for (string email : emailRecipients)
            {
            	if (email != null && email.length() > 0)
            	{
            	   internalToEmail.add(email);
            	}
            }
        }
        
        string internalHtmlBody = '<b>License Restriction Unlock Reason:</b> <br />' + licenseTask.Description + '<br /><br />' + htmlBody;
        
        Messaging.SingleEmailMessage internalEmail = emailclassRoadnet.createMail(internalToEmail, subject + ' (Internal Email)', internalHtmlBody, null );
        
        List<Messaging.SingleEmailMessage> mailsToSend = new List<Messaging.SingleEmailMessage>();
        mailsToSend.add(customerEmail);
        mailsToSend.add(internalEmail);
        
        //  i would normally have a method that sends this email in the EmailClass.  however, any additions, changes to the emailclass requires me to bring
        //  down all of the scehdueled apex jobs when i deploy the code.  instead i copy pasted a method there and changed it here so that it
        //  returns a list of sendemailresults.  this was too maintain the signature of this method which returns an sendEmailresult
        Messaging.sendemailResult[] ser = sendMultipleEmails(mailstoSend);
        
        return ser[0];
    }
    
    private static Messaging.sendemailResult[] sendMultipleEmails(List<Messaging.SingleEmailMessage> emails)
    {
        
        Messaging.sendemailResult[] sendEmailResults;
        try
        {
            sendEmailResults = Messaging.sendEmail(emails, false);
        }
        catch(Exception e)
        {
            throw e;
            /*createApexEmailRecord(
               grabToEmailFromListOfMail(emails), null, null, 'multiple email', null, null, 
               'multiple emails used', false, e.getMessage(), null);
               */
        }
        
        boolean isEmailSendSuccessful;
        string errorMessageIfAny;
        
        for (integer i = 0; i < emails.size(); i++)
        {
           Messaging.sendemailResult ser = sendEmailResults[i];
           Messaging.SingleEmailMessage singleMail = emails[i];
           
           if (ser.issuccess())//  this email was sent successfully, create postive apex email record
           {

           }
           else// if failed so show the error
           {

           }
        }
        
        return sendEmailResults;
       
    }
    public static ApexPages.StandardController generateController(Account account)
    {
        pagereference pageRef=new pagereference('Page.NameOfExtension');
        test.setcurrentpage(pageRef);
        ApexPages.currentPage().getParameters().put('Id', account.id);
             
        return new ApexPages.standardController(account);
    }

    private static boolean isBlank(string str)
    {
        if (str == null)
        {
            return true;
        }
        if (str.length() == 0)
        {
            return true;
        }
        
        return false;
    }
 
    public static Contact[] getContactsOfAccount(Id accountId, integer limitOfContacts)
    {
        system.assertNotEquals(null,accountId);
        List<contact> listOfContacts = new List<contact>();
        
        return [select id, name 
                    from contact where accountid =: accountId and inactive__c = false order by lastname, firstname limit :limitOfContacts];
        
/*
        system.assertNotEquals(null, a.recordtype.name);
        
        //split up the function depending on the type of account we are dealing with
        if (a.recordtype.name.contains('Domestic'))
        {
            if (a.parentId == null)
            {
                return [select id, name 
                    from contact where accountid=:a.id and inactive__c = false order by lastname, firstname limit :limitOfContacts];
            }
            else//does it have a parent account? 
            {
                return [select id, name 
                     from contact where ( accountid =: a.parentid OR accountid =: a.id) and 
                     inactive__c = false order by account.parentid NULLS LAST, lastname, firstname limit :limitOfContacts];
            }
        }
        else if (a.recordtype.name.contains('International') || a.recordtype.name.contains('VAR'))
        {
            
            //  it would make more logical sense to create a whole bunch of queries to get all contacts of an account irregardless of its account composition
            //  but i set this up this way for two reasons 1-only one query is used. 2-this allows the sorting to be done by the query.  when i put the sort outside of
            //  the query ie in the code, it was running up script statments.  in this coding environment, (outside of using dynamic queries which i was NOT using when this was built)
            //  this is the most effecient way to accomplish this 
            if ( (a.Var_Account__c == null) && (a.Sub_Var_Account__c == null) )//  no var or sub var
            {
                return [select id, name
                    from contact where accountid=:a.id and inactive__c = false order by lastname, firstname limit :limitOfContacts];
            }
            else if ( (a.Var_Account__c != null) && (a.Sub_Var_Account__c == null) )//  theres a var but no sub var
            {
                return [select id, name
                    from contact where ( accountid =: a.id OR accountId =: a.Var_Account__c) and inactive__c = false 
                    order by lastname, firstname limit :limitOfContacts];
            }
            else if ( (a.Var_Account__c == null) && (a.Sub_Var_Account__c != null) ) //  theres a subvar but no var
            {
                return [select id, name
                    from contact where ( accountid =: a.id OR accountId =: a.Sub_VAR_Account__c )and inactive__c = false 
                    order by lastname, firstname limit :limitOfContacts];   
            }
            else //  both var and sub var are set (this was here before i put the supporting var check, this is the default)
            {
                return [select id, name
                    from contact where (accountid=:a.id or accountId =: a.Sub_Var_Account__c or accountId =: a.VAR_Account__c) and 
                    inactive__c = false order by lastname, firstname limit :limitOfContacts];
            }
        }
        else
        {   
            return [select id, name
                from contact where accountid=:a.id and inactive__c = false order by lastname, firstname limit :limitOfContacts];
        }   
        */
    }
}