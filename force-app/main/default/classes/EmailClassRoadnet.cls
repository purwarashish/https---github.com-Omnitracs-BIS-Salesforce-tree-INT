/*******************************************************************************
 * File:  EmailClassRoadnet.cls
 * Date:  October 1, 2014
 * Author:  Joseph Hutchins
 * Sandbox: Mibos
 * The use, disclosure, reproduction, modification, transfer, or transmittal of
 * this work for any purpose in any form or by any means without the written 
 * permission of United Parcel Service is strictly prohibited.
 *
 * Confidential, unpublished property of United Parcel Service.
 * Use and distribution limited solely to authorized personnel.
 *
 * Copyright 2009, UPS Logistics Technologies, Inc.  All rights reserved.
 *  *******************************************************************************/
//  ********************************    THIS IS FOR THE MIBOS SANDBOX/ENVIRONMENT   **********************************************
public with sharing class EmailClassRoadnet
{
    public class myException extends Exception{}

  public static Messaging.sendemailResult[] sendEmailsWithTemplate(List<EmailTemplateEx> emailTemplateObjects)
    {
        List<Messaging.SingleEmailMessage> emailsToSend = new List<Messaging.SingleEmailMessage>();
        
        //  for each record passsed in, create an email record
        for (integer i = 0; i < emailTemplateObjects.size(); i++)
        {
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            EmailTemplateEx singleEmailTemplateObject = emailTemplateObjects[i];// dereference for easier code reading
            
           mail.setTargetObjectId(singleEmailTemplateObject.targetId);
                
            mail.setWhatId(singleEmailTemplateObject.whatId);
            if (EmailClassRoadnet.isUserInSandbox())
            {
                singleEmailTemplateObject.ccAddresses.add(userInfo.getUserEmail());
            }
                        
            //  add cc and bcc addresses if set
            if (singleEmailTemplateObject.ccAddresses != null && singleEmailTemplateObject.ccAddresses.Size() > 0)
            {
                mail.setCCAddresses(singleEmailTemplateObject.ccAddresses); 
            }
            if (singleEmailTemplateObject.bccAddresses != null && singleEmailTemplateObject.bccAddresses.Size() > 0)
            {
                mail.setBCCAddresses(singleEmailTemplateObject.bccAddresses); 
            }
            
            mail.setTemplateId(singleEmailTemplateObject.templateId);
            
            mail.setUseSignature(false);
            
            mail.setSaveAsActivity(singleEmailTemplateObject.saveAsActivity);
            if (singleEmailTemplateObject.orgWideEmailAddress != null)
            {
                mail.setOrgWideEmailAddressId(singleEmailTemplateObject.orgWideEmailAddress);
            }
            emailsToSend.add(mail);
                
        }
        //  mass send the emails,
        Messaging.sendemailResult[] sendEmailResults;
        try
        {
            sendEmailResults = Messaging.sendEmail(emailsToSend, false);//  second bool means all or nothing
        }
        catch(Exception e)
        {
            throw e;//  imposibble to know what will get thrown here without testing so we will throw the exception
        }
        
        //  so now that the emails have been sent out, when scroll thru the results and create
        //  apexemail records based on those results
        
        
        //  return results in case the callig method has its own processing it wants to do
        return sendEmailResults;
        

    }
    
    public class EmailTemplateEx
    {
        public EmailTemplateEx()
        {
            ccAddresses = new List<string>();
            bccAddresses = new List<string>();
        }
        public id whatId{get;set;}
        public id targetId{get;set;}
        public id templateId{get;set;}
        public string contactEmailAddress{get;set;}
        public string contactName{get;set;}
        public List<string> ccAddresses{get;set;}
        public list<string> bccAddresses{get;set;}
        public id orgWideEmailAddress{get;set;}
        public boolean saveAsActivity{get;set;}
    }   
    
    @future public static void sendEmailInternalUsersAsync(
        List<Id> userIds, string subject, string htmlBody, string textBody, Id organizationWideEmailAddressToUse)
    {
        Messaging.sendemailResult[] blarg = sendEmailInternalUsers(
           userids, subject, htmlbody, textbody, organizationWideEmailAddressToUse);
    }
    
    public static Messaging.sendemailResult[] sendEmailInternalUsers(
        List<Id> userIds, string subject, string htmlBody, string textBody, Id organizationWideEmailAddressToUse) 
    {
        system.assertNotEquals(null, userIds);
        system.assertNotEquals(null, subject);
        
        //  so this is how this is oging to work, for each user id passed into this class, we'll create mutiple mail records
        //  and send them all at the same time
        List<Messaging.SingleEmailMessage> mailsToSend = new LIst<Messaging.SingleEmailMessage>();
        
        for (Id singleUserId : userids)
        {
            boolean isSandbox = false;
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        
            //  if we are in the sandbox we want to send the email to myself only
            if(EmailClassRoadnet.isUserInSandbox())
            {
                mail.setTargetObjectId(userInfo.getUserId());
                isSandbox = true;
            }
            else
            {
                mail.setTargetObjectId(singleUserId);
            }
            system.debug('mail.setTargetObjectId'+mail.getTargetObjectId());        
            mail.setCharSet('UTF-8');//  ASCII--was Unicode and UTF-8
            mail.setSaveAsActivity(false);
            mail.setsubject(subject);            
            if (htmlBody != null)
                mail.setHtmlBody(htmlBody);           
            mail.setPlainTextBody(textBody);           
            mail.setUseSignature(false);           
            if (organizationWideEmailAddressToUse != null)
                mail.setOrgWideEmailAddressId(organizationWideEmailAddressToUse);
                           
            mailsToSend.add(mail);//putting together
            
            if(isSandbox == true)//no need to loop through users, as for sandbox we will send email only to running user
                break;
        } 
        
        Messaging.sendEmailResult[] sendEmailResults = null;       
        try
        {
            sendEmailResults = Messaging.sendEmail(mailsToSend, false);
        }
        catch(Exception e)
        {
            EmailClassRoadnet.sendErrorEmail('failed to send apex email due to ' + e.getMessage(), null);
            return null;
        }
        
        //  we are now sending mutlipe emails at one time we'll scroll thru each email results, see what its status was
        //  and create an apexemail recor for each one
        if(sendEmailResults != null)
        {
            for(integer i = 0; i < sendEmailResults.size(); i++)
            {
                string errorMessageIfAny = EmailClassRoadnet.convertSendEmailErrorsToString(sendEmailResults[i].getErrors());
            }
        }
        
        return sendEmailResults;
    }
    
    @future public static void sendEmailAsync(List<string> toEmailAddresses, 
        List<string> CCEmailAddresses, List<string> BCCEmailAddresses,
        string subject, string htmlBody, string textBody, Id organizationWideEmailAddressToUse)
    {
        System.debug('@1'+toEmailAddresses);
        System.debug('@2'+BCCEmailAddresses);
        Messaging.sendemailResult[] emailResults = 
           sendEmail(toEmailAddresses, CCEmailAddresses, BCCEmailAddresses, subject, htmlbody, textbody, organizationWideEmailAddressToUse);
        for (Messaging.sendemailResult ser : emailResults)
        {
            if (!ser.isSuccess())
            {
                throw new myException('email sending failed due to ' + convertSendEmailErrorsToString(ser.getErrors()));
            }
        }
    }
    public static Messaging.sendemailResult[] sendEmail(List<string> toEmailAddresses, 
        List<string> CCEmailAddresses, List<string> BCCEmailAddresses,
        string subject, string htmlBody, string textBody, Id organizationWideEmailAddressToUse) 
    {
        system.assertNotEquals(null, toEmailAddresses);
        system.assertNotEquals(null, subject);
        system.assertNotEquals(null, textBody);
        //system.assertEquals(true, (subject.length() < 256) );
        
        //  instead of asserting the subject is less than 255 chars, we will allow it to be greater
        //  and then shrink it down so the email can still be sent (this prevented and error email
        //  from being sent to me)
        if (subject.length() > 255)
        {
            subject = truncateString(subject, 255);
        } 
        Messaging.sendemailResult[] sendEmailResults = null;
        
        //  go thru the list of toEmailaddresses and make sure each one contains a value
        System.debug('@1'+toEmailAddresses);
        System.debug('@2'+BCCEmailAddresses);
        for (string str : toEmailAddresses)
        {
            if (str == null)
            {
               throw new myException('To Address in list of to email addresses was null');  
            }
        }
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new List<String>();
        String[] ccAddresses = new List<String>();
        String[] bccAddresses = new List<String>();
        
        //  if we are in the sandbox we want to send the email to myself only
        if (EmailClassRoadnet.isUserInSandbox())
        {
            toAddresses.add('jhutchins@roadnet.com');
            //  if jane or amy or charlie are testing in the sandbox then the email is sent to them also
            string currentUserEmail;
            try
            {
                currentUserEmail = [select email from user where id =: UserInfo.getUserId()].email;
                toAddresses.add(currentUserEmail);
            }
            catch(Exception e)
            {
                //  do nothing
            }
                
        }
        else
        {
            toAddresses.addAll(toEmailAddresses);
            
            if (CCEmailAddresses != null)
            {
               ccAddresses.addAll(ccEmailAddresses); 
            }
            
            if (BCCemailAddresses != null)
            {
                bccAddresses.addAll(bccEmailAddresses);
            }
        }
        
        mail.setToAddresses(toAddresses);
        mail.setCCAddresses(ccAddresses);
        mail.setBccAddresses(bccAddresses);
        
        mail.setCharSet('UTF-8');//  ASCII--was Unicode and UTF-8
        
        mail.setsubject(subject);
        
        if (htmlBody != null)
        {
            mail.setHtmlBody(htmlBody);
        }
        mail.setPlainTextBody(textBody);
        
        mail.setUseSignature(false);
        
        if (organizationWideEmailAddressToUse != null)
        {
            mail.setOrgWideEmailAddressId(organizationWideEmailAddressToUse);
        }
        
        //  ok what i assume this object should have is a toemailaddress, ccemailadddress, subject, body, and whether it succeded or not
        //  if not we need to capture the error message
        try
        {
            sendEmailResults = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail }, false);
        }
        catch(Exception e)
        {
            EmailClassRoadnet.sendErrorEmail('failed to send apex email due to ' + e.getMessage(), null);
            return null;
        }
        
        boolean isEmailSendSuccessful;
        string errorMessageIfAny;
        
        if (sendEmailResults != null)
        {
            for (Messaging.SendEmailResult ser : sendEmailResults)
            {
                if ( ser.isSuccess() )
                {
                   isEmailSendSuccessful = true;  
                }
                else if ( !ser.isSuccess())
                {
                    isEmailSendSuccessful = false;
                    errorMessageIfAny = EmailClassRoadnet.convertSendEmailErrorsToString(ser.getErrors());
                }
            }
        }
        
        return sendEmailResults;
    }
    public static string convertSendEmailErrorsToString(List<Messaging.SendEmailError> emailErrors)
    {
        //  i've updated this method from logic from the RnaApexEmailerController's convertErrorsToString which includes adding
        //  status code and fields to the string that is returned
        string stringToReturn = '';
        if (emailErrors == null || emailErrors.size() == 0)
        {
            return 'No Error';
        }
        else
        {
            //  there should only be one item in the email error list but ill will cursor thru and add counter info just in case there is more
            for (integer i = 0; i < emailErrors.size(); i++)
            {
                stringToReturn += '[' + i + '] Error: ' + emailErrors[i].getMessage() + 
                    ' StatusCode: ' + emailErrors[i].getStatusCode() + 
                    ' Fields: ' + convertListStringsToOneString(emailErrors[i].getFields()); 
            }
            
            return stringToReturn;
        }
    }
    public static string truncateString(string str, integer fieldMaxLength)
    {
        system.assert(str.length() > fieldMaxLength);
        string stringToReturn = str.substring(0, fieldMaxLength - 3);//  the last 3 chars on the end of the string will be ...
        stringToReturn += '...';
        return stringToReturn; 
    }
    public static boolean isUserInSandbox()
    {
        if(userinfo.getOrganizationId() == '00D500000006kZIEAY' || userinfo.getOrganizationId() == '00D500000006kZI')//production
            return false;
        else
            return true;          
    }
    public static void sendErrorEmail(string errorMessage, id firstId)
    {
        String[] toAddresses = new String[] {'jhutchins@roadnet.com'}; 
     
        string subject = 'Error: Id = ' + firstId + ' - ' + errorMessage;
        string textBody = 'Error: Id = ' + firstId + ' - ' + errorMessage;
        
        // Send the email you have created.
        sendEmailPriority(toAddresses, null, null, subject, null, textBody, null, 'High'); 
    }
    public static Messaging.sendemailResult[] sendEmailPriority(List<string> toEmailAddresses, 
        List<string> CCEmailAddresses, List<string> BCCEmailAddresses,
        string subject, string htmlBody, string textBody, Id organizationWideEmailAddressToUse, string emailPriority) 
    {
        system.assertNotEquals(null, toEmailAddresses);
        system.assertNotEquals(null, subject);
        system.assertNotEquals(null, textBody);
        //system.assertEquals(true, (subject.length() < 256) );
        
        //  instead of asserting the subject is less than 255 chars, we will allow it to be greater
        //  and then shrink it down so the email can still be sent (this prevented and error email
        //  from being sent to me)
        if (subject.length() > 255)
        {
            subject = truncateString(subject, 255);
        } 
        Messaging.sendemailResult[] sendEmailResults = null;
        
        //  go thru the list of toEmailaddresses and make sure each one contains a value
        for (string str : toEmailAddresses)
        {
            if (str == null)
            {
               throw new myException('To Address in list of to email addresses was null');  
            }
        }
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new List<String>();
        String[] ccAddresses = new List<String>();
        String[] bccAddresses = new List<String>();
        
        if (emailPriority == null)
        {
            mail.setEmailPriority('Medium');
        }
        else
        {
            mail.setEmailPriority(emailPriority);
        }
        
        //  if we are in the sandbox we want to send the email to myself only
        if (EmailClassRoadnet.isUserInSandbox())
        {
            toAddresses.add('jhutchins@roadnet.com');
            //  if jane or amy or charlie are testing in the sandbox then the email is sent to them also
            string currentUserEmail;
            try
            {
                currentUserEmail = [select email from user where id =: UserInfo.getUserId()].email;
                toAddresses.add(currentUserEmail);
            }
            catch(Exception e)
            {
                //  do nothing
            }
                
        }
        else
        {
            toAddresses.addAll(toEmailAddresses);
            
            if (CCEmailAddresses != null)
            {
               ccAddresses.addAll(ccEmailAddresses); 
            }
            
            if (BCCemailAddresses != null)
            {
                bccAddresses.addAll(bccEmailAddresses);
            }
        }
        
        mail.setToAddresses(toAddresses);
        mail.setCCAddresses(ccAddresses);
        mail.setBccAddresses(bccAddresses);
        
        mail.setCharSet('UTF-8');//  ASCII--was Unicode and UTF-8
        
        mail.setsubject(subject);
        
        if (htmlBody != null)
        {
            mail.setHtmlBody(htmlBody);
        }
        mail.setPlainTextBody(textBody);
        
        mail.setUseSignature(false);
        
        if (organizationWideEmailAddressToUse != null)
        {
            mail.setOrgWideEmailAddressId(organizationWideEmailAddressToUse);
        }
        
        //  ok what i assume this object should have is a toemailaddress, ccemailadddress, subject, body, and whether it succeded or not
        //  if not we need to capture the error message
        try
        {
            sendEmailResults = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail }, false);
        }
        catch(Exception e)
        {
            EmailClassRoadnet.sendErrorEmail('failed to send apex email due to ' + e.getMessage(), null);
            return null;
        }
        
        boolean isEmailSendSuccessful;
        string errorMessageIfAny;
        
        if (sendEmailResults != null)
        {
            for (Messaging.SendEmailResult ser : sendEmailResults)
            {
                if ( ser.isSuccess() )
                {
                   isEmailSendSuccessful = true;  
                }
                else if ( !ser.isSuccess())
                {
                    isEmailSendSuccessful = false;
                    errorMessageIfAny = EmailClassRoadnet.convertSendEmailErrorsToString(ser.getErrors());
                }
            }
        }
        
        return sendEmailResults;
    }
    
    public static void checkEmailResults(Messaging.sendemailResult[] emailResults)
    {
        //  i guess what we want to do is see if any of the emails were sent out.  if not
        //  we can either return a boolean or throw an exception.  the exception is probably easiest to deal with
        //  so we send the email results to a method that checks if it everything was sent ok and if not
        //  it displaies the error message to teh screen as to what happened
        //  we have to assume that multiple errors have occured so we want to
        //  catalog those errors in an list of strings or something liket atht
        for (Messaging.sendemailResult ser : emailResults)
        {
            if (!ser.isSuccess())
            {
                string exceptionErrorMessage;
                Messaging.SendEmailError emailError = ser.getErrors()[0];
                throw new myException(emailError.getMessage() + ' fields that caused error: ' + emailError.getFields());
            }
        }
    }
    public static string FromAddressForCases
    {
        get
        {
            //  WE need some org wide emaill addresses to be defined before we can use this in the MIBOS environment
            return null;
            /*util.debug('userinfo profile id = ' + userInfo.getProfileId() + ' and the boolean = ' + (userinfo.getProfileId() == '00e30000000h3p2'));
            //  if the user logged in is system admin, use the generaic email address
            if (userinfo.getName() == 'Joseph Hutchins' || userinfo.getName() == 'Amy Bowser')
            {
                return NOT_VALID_EMAIL;
            }
            else
            {
                return null;
            }
            */
        }
    }
    
    public static string NOT_VALID_EMAIL
    {
        get
        {
            return '0D230000000TN6P';
        }
    }
    public static string createHyperLink(string theUrl, string text)
    {
        return '<a href="' + theUrl + '">' + text + '</a>';
    }
    public static string convertHtmlToText(string htmlString)
    {
        string textString = htmlString.replace('<br>', '\n');
        textString = textString.replace('<br />', '\n');
        textString = textString.replace('<b>', ' ');
        textString = textString.replace('</b>', ' ');
        return textString;
    }
    public static void sendMultipleEmails(List<Messaging.SingleEmailMessage> emails)
    {
        
        Messaging.sendemailResult[] sendEmailResults;
        try
        {
            sendEmailResults = Messaging.sendEmail(emails, false);
        }
        catch(Exception e)
        {
            throw e;
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
                // since this doesnt return email results... i need a way to know if an error sending email occured so going to have a debug message show here
                string exceptionErrorMessage;
                Messaging.SendEmailError emailError = ser.getErrors()[0];
                util.debug('EMAIL SENDING FAILED: ' + emailError.getMessage() + ' fields that caused error: ' + emailError.getFields());
           }
        }
       
    }
    public static Messaging.SingleEmailMessage createMail(string toEmail, string subject, string htmlbody, string orgWideEmailAddress)
    {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new List<String>();
        
        /*if (EmailClassRoadnet.isuserInSandBox())//  emails are sent to myself and perseon logged in while in sandbox
        {
            //toAddresses.add([select email from user where id =: userInfo.getUserId() ].email);
            toAddresses.add('jhutchins@roadnet.com');   
        }
        else
        {*/
            toAddresses.add(toEmail);
        //}
        mail.setToAddresses(toAddresses);
        mail.setsubject(subject);
        mail.sethtmlbody(htmlBody);
        mail.setPlainTextBody(EmailClassRoadnet.convertHTMLToText(htmlbody));
        mail.setUseSignature(false);
        
        if (orgWideEmailAddress != null)
        {
            mail.setOrgWideEmailAddressId(orgWideEmailAddress);
        }
        
        return mail;
    }
    public static Messaging.SingleEmailMessage createMail(string[] toEmailAddresses, string subject, string htmlbody, string orgWideEmailAddress)
    {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new List<String>();
        /*
        
        if (EmailClassRoadnet.isuserInSandBox())//  emails are sent to myself and perseon logged in while in sandbox
        {
            //toAddresses.add([select email from user where id =: userInfo.getUserId() ].email);
            toAddresses.add('jhutchins@roadnet.com');   
        }
        else*/
        {
            toAddresses = toEmailAddresses;
        }
        mail.setToAddresses(toAddresses);
        mail.setsubject(subject);
        mail.sethtmlbody(htmlBody);
        mail.setPlainTextBody(EmailClassRoadnet.convertHTMLToText(htmlbody));
        mail.setUseSignature(false);
        
        if (orgWideEmailAddress != null)
        {
            mail.setOrgWideEmailAddressId(orgWideEmailAddress);
        }
        
        return mail;
    }
    

    public static Messaging.SingleEmailMessage createMailInternalUser(id userId, string subject, string htmlbody, string orgWideEmailAddress)
    {

        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
    
        //  if we are in the sandbox we want to send the email to myself only
        if (EmailClassRoadnet.isUserInSandbox())
        {
            //  if in the sandbox, the email should go to the person logged in to avoid accidenttial emails from going out
            mail.setTargetObjectId(userInfo.getUserId());
        }
        else
        {
            mail.setTargetObjectId(userId);
        }
    
        mail.setCharSet('UTF-8');//  ASCII--was Unicode and UTF-8
        mail.setSaveAsActivity(false);
        mail.setsubject(subject);
        
        if (htmlBody != null)
        {
            mail.setHtmlBody(htmlBody);
        }
        
        mail.setPlainTextBody(htmlbody);
        
        mail.setUseSignature(false);
        
        if (orgWideEmailAddress != null)
        {
            mail.setOrgWideEmailAddressId(orgWideEmailAddress);
        }
            
            
        if (orgWideEmailAddress != null)
        {
            mail.setOrgWideEmailAddressId(orgWideEmailAddress);
        }
        
        return mail;
    }

    public static List<string> grabToEmailFromListOfMail(List<Messaging.SingleEmailMessage> emails)
    {
        List<string> stringToReturn = new List<string>();
        
        for (Messaging.SingleEmailMessage singleMail : emails)
        {
            stringToReturn.addAll(singleMail.getToAddresses());
        }
        return stringToReturn;
    }
    public static string convertTextToHtml(string textString)
    {
        string htmlString = textString.replace('\n', '<br>');
        
        return htmlString;
    }
    public static string convertListStringsToOneString(string[] strings)
    {
        string theString='';
        for (integer i = 0; i <strings.size(); i++)
        {
            if (i + 1 > strings.size())//  don't append semi colon
            {
                theString += strings[i];
                break;  
            }
            else
            {
                theString += strings[i] + '; ';
                
            }
        }   
        return theString;
    }
}