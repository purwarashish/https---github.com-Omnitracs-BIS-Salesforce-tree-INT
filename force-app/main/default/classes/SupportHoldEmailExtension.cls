/*******************************************************************************
 * File:  SupportHoldEmailExtension.cls
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
public class SupportHoldEmailExtension 
{
    //  used for throwing custom exceptions
    public class myException extends Exception{}
    
    //  **********  Member Variables  **********
    public Account account{get;set;}
    public string toEmail{get;set;}
    public string ccEmail{get;set;}
    public string bccEmail{get;set;}
    public string userChoiceContact{get;set;}
    
    //  **********  Constructor(s)  ***********
    public SupportHoldEmailExtension(apexpages.standardcontroller stdcontroller)
    {
        account = [select id, name, parentid, Alert_text__c from Account where id = : stdcontroller.getId()];//  query account
        m_contacts = getContactsOfAccount(account.id, 100);
 
        //  query this from the jump
        theEmailTemplate = [select id, name from EmailTemplate where name = 'Roadnet Support Hold Set To Customer'];
        
    }
    
    //  **********  Setters and Getters  **********
    private List<Contact> m_contacts{get;set;}
    
    public List<SelectOption> contactPicklist
    {
        get
        {
            List<SelectOption> options = new List<SelectOption>();
            
            if (m_contacts != null)
            {
                for (Contact c : m_contacts)
                {
                    string contactTitle = c.title == null ? 'No Title' : c.title;
                    options.add( new selectoption(c.id, c.firstname + ' ' + c.lastname + ' - ' + contactTitle ) );
                }
            }
            else
            {
                options.add(pl.noneoption);
            }
            
            return options;
        }
    }
    
    //  **********  Properties  **********
    private string accountReceiveOrgWidEmailAddress
    {
        get
        {
            if (Util.isRnEnvironment)
            {
                return '0D230000000TOox';//  this is in the live environment, the org wide does not existg in the sandbox,
            }
            else
            {
                return null;
            } 
        }
    }
    private EmailTemplate theEmailTemplate;
    //  **********  Public Instance Functions  ***********    
    public PageReference sendEmail()
    {
        util.debug('sendEmail called');
        
        if (util.isBlank(toEmail))
        {
            account.addError('You must set an email.');
            return null;
        }
        
        // set the support hold account
        account.Support_hold__c = true;
        account.support_hold_date__c = date.today();
     
        update account;
        //  the logic of this has changed, and since i am up agaisnt the wall, i need to do this the way i didnt want to
        //  the toemail is going to contain contact email addresses, i need to parse out the emails
        //  find the contacts, and then we'll send the email tempate out to the selected ontacts, if the user changes the email, 
        //  then that contact is just not going to get an email (this is the lazy/up agiasnt the wall part, realistcally we want to have th page
        //  make usre they cannot alter the email, but i want this to get pushed TODAY
        system.assertNotEquals(theEmailTemplate, null);
        
        //List<string> toEmailAddress = ProductPickerClass.parseString(toEmail);
        List<string> ccEmailAddress = ProductPickerClass.parseString(ccEmail);
        List<string> bccEmailAddress = ProductPickerClass.parseString(bccEmail);
        
        util.debug('before parsing the toEmail: ' + toEmail);
        
        List<Contact> contactsToGetEmail = findContactsUsingToEmail(toEmail);
        
        util.debug('num of contacts found that email will get sent to:' + (contactsToGetEmail == null ? 0 : contactsToGetEmail.size()));
        
        if (contactsToGetEmail != null && ContactsToGetEmail.size() > 0)
        {
            List<EmailClassRoadnet.EmailTemplateEx> emailsToSend = new List<EmailClassRoadnet.EmailTemplateEx>();
            for (Contact c : contactsToGetEmail)
            {
                EmailClassRoadnet.EmailTemplateEx tempEmail = new EmailClassRoadnet.EmailTemplateEx();
                tempEmail.targetId = c.id;
                tempEmail.templateId = theEmailTemplate.id;
                tempEmail.whatId = account.id;
                tempEmail.ccAddresses = ccEmailAddress;
                tempEmail.bccAddresses = bccEmailAddress;
                tempEmail.saveAsActivity = true;
                
                emailsToSend.add(tempEmail);
            }
            
            util.debug('num of emails to send: ' + (emailsToSend == null ? 0 : emailsToSend.size()));
            
            boolean allSentSuccessful = true;
            if (emailsToSend != null && emailsToSend.size() > 0)
            {
                Messaging.sendemailResult[] sendEmailResults = EmailClassRoadnet.sendEmailsWithTemplate(emailsToSend);
                
                for (Messaging.sendemailResult ser : sendEmailResults)
                {
                    if (!ser.Success)
                    {
                        allSentSuccessful = false;
                    }
                    
                }
            }
            
            util.debug('allSentSuccessul email boolean: ' + allSentSuccessful);
            
            if (allSentSuccessful)
            {
                PageReference pr = Page.EmailSendSuccessful;
                pr.getParameters().put('Returl', Util.BASE_URL + account.id);
                pr.setRedirect(true);
                
                return pr;
            }
            else
            {
                account.AddError('1 or more email sending failed.  Please check source code');
                return null;
            }
        }
        else
        {
            account.addError('Please specify at least one contact in the To Email field.  The contact should come from the picklist below');
            return null;
        }
        
        /*try
        {
            EmailClassRoadnet.sendEmailAsync(
                toEmailAddress,
                (ccEmailAddress == null ? null : ccEmailAddress),
                (bccEmailAddress == null ? null : bccEmailAddress), // a what id isn't needed, unless we want to assoicate with the account
                subject,
                htmlBody,
                htmlBody,
                accountReceiveOrgWidEmailAddress);
        }
        catch(Exception e)
        {
            account.AddError('Failed to send email: ' + e.getMessage());
            return null;
        }
        */
        
    }
    public Pagereference addContact()
    {
        util.debug('addContact method called.  userChoiceContact: ' + userChoiceContact );
        if (!util.isBlank(userChoiceContact))
        {
            Contact selectedContact = findContactInPicklist(userChoiceContact);
            util.debug('selectedContact value: ' + selectedContact);
            
            //  if the email is blank, dont add anything
            if (selectedContact.email != null)
            {
                toEmail += selectedContact.email + '; ';
            }
            
        }
        return null;
    }
    //  **********  Private Instance Functions  **********
    private Contact findContactInPicklist(string contactId)
    {
        if (contactId == '--None--' || contactId == null)
        {
            return null;
        }
        else
        {
            for (Contact c : m_contacts)
            {
                if (c.id == contactId)
                {
                    return c;
                }
            }
            return null;
        }
    }
    private List<Contact> findContactsUsingToEmail(string toEmail)
    {
        //  this is very simple, 
        //  parse the toEmail field, scroll thryu looking for contacts in the private list of conatcts
        list<string> emailAddressParsed = ProductPickerClass.parseString(toEmail);
        
        if (emailAddressParsed != null && emailAddressParsed.size() > 0)
        {
            List<Contact> contactsToReturn = new List<Contact>();
            for (string singleEmail : emailAddressParsed)
            {
                for (Contact c : m_contacts)
                {
                    if (c.email == singleEmail)
                    {
                        contactsToReturn.add(c);
                    }
                }
            }
            return contactsToReturn;
        }
        
        return new List<Contact>();
        
    }
    private static List<Contact> getContactsOfAccount(id accountid, integer maxNumOfContacts)
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
                childAccountContacts = [select id, name, firstname, lastname, email, title, inactive__c 
                    from contact where accountId =: tempAccount.id and inactive__c = false];
                if (tempAccount.ParentId != null)
                {
                    parentAccountContacts = [select id, name, firstname, lastname, email, title, inactive__c 
                        from contact where accountId =: tempAccount.ParentId and inactive__c = false];
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
    //  **********  Static Functions  **********
    public static ApexPages.StandardController generateController(Account a)
    {
        pagereference pageRef=new pagereference('Page.SupportHoldEmail');
        test.setcurrentpage(pageRef);
        
        return new ApexPages.standardController(a);
    }
    //  **********  Test Methods  **********

}