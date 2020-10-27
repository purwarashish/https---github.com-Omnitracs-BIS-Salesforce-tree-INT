/*******************************************************************************
 * File:  CaseEventEmailExtension
 * Date:  November  3, 2008
 * Author:  Charlie Heaps
 *
 * The use, disclosure, reproduction, modification, transfer, or transmittal of
 * this work for any purpose in any form or by any means without the written 
 * permission of United Parcel Service is strictly prohibited.
 *
 * Confidential, unpublished property of United Parcel Service.
 * Use and distribution limited solely to authorized personnel.
 *
 * Copyright 2009, UPS Logistics Technologies, Inc.  All rights reserved.
 *
 * Purpose: 
 *   Contains static helper methods pertaining to CR Version records.
 *******************************************************************************/
public class CaseEventEmailExtension
{
    private final Case_Event__c extensionCaseEvent;
    /*because this extension will be using fields from case event, its only natural that we have them avaialble
    however, this extension constructer only contains data for the id (no other fields... similar to doing a query 
    without specifying anyother fields in the query) to fix this i declared theCaseEvent and in the constructor of this extension
    i queryed all fields.  now anywhere in this constructor i need to refer to the caseevent__c, i have it and all of its fields
        */
    private Case tempCaseObject = new Case();
    public string selectedEmailAddress;
    private boolean isSelectingContact = false;    
    private string toEmailAddress;
    private string emailBodyHtml;
    private string emailBodyText;
    private string emailSubject;
    private boolean isEmailSent=false;
    private string emailStatus;
    private string ccEmailAddress;
    private string bccEmailAddress;
    public Case_Event__c theCaseEvent=new Case_Event__c();
    
    public caseEventEmailExtension(ApexPages.StandardController stdController)
    {
        ApexPages.currentPage().getHeaders().put('X-UA-Compatible', 'IE=10');
        
        isSelectingContact = false;
        this.extensionCaseEvent=(Case_Event__c)stdController.getRecord();
        theCaseEvent=[Select c.Time_Spent__c, c.Subject__c, 
                        c.Name, c.LastModifiedDate, c.LastModifiedById, c.LastActivityDate, 
                        c.Id, c.Display_in_Customer_Portal__c, c.Details__c, c.CreatedDate, 
                        c.CreatedById, c.Communication_Type__c, 
                        c.Case__c, c.Case_Comment_ID__c From Case_Event__c c where c.id=:extensionCaseEvent.id limit 1];
        //grabbing the case assoiated with the caseevent for summary information we are going to put in the email
        Case theCase=[select id, accountid, caseNumber, status
            from case where id=:theCaseEvent.case__c limit 1];
        
        //put this in the constructor because we want this to be prepopulated when the user clicks on "Send Email"
        //        however, after this is prepopulated, the user has the ability to change this however they choose.
        setemailSubject('Case Event for Account ' + [select name from account where id=:thecase.accountid].name + '  Subject: ' + theCaseEvent.subject__c);
        setemailBodyText('Case No. ' + theCase.caseNumber + ' Case Status:' + theCase.status+ 
                            '\nCase Reason: ' + '\n\n\nCase Event Details: ' 
                            +theCaseEvent.details__c + '\nCommunication Type:  '
                            +theCaseEvent.Communication_Type__c +'\nDate:  '+theCaseEvent.CreatedDate.format()
                            + '\n');
        //this statement is needed because we need to make sure the emailbodyhtml is set during creation of the controller
        setemailBodyHtml(getemailbodyText());
    }

    
    public string getEmailStatus()
    {
        //this function just prints out to the scren if an email was sent or not, if the sendemail function
    //goes through without throwing an exception, the boolean isEmailSent is set to true which prints
    //email sent to screen.  this was the easiest/simplest way i knew of printing to the vf page that 
    //the email was sent
        if (isEmailSent)
            return 'Email Sent';
        else
            return ' ';
    }
    public Case gettempCaseObject(){return tempCaseObject;}
    public void settempCaseObject(Case c){ tempCaseObject = c;}
    public boolean getIsSelectingContact(){return isSelectingContact;}
    public void setIsSelectingContact(boolean b){isSelectingContact = b;}
    public void settoEmailAddress(string s){toEmailAddress=s;}
    public string gettoEmailAddress(){return toEmailAddress;}
    public void setemailBodyText(string s){emailBodyText=s;}
    public string getemailBodyText(){return emailBodyText;}
    public string getCCEmailAddress(){return ccemailAddress;}
    public void setCCEmailAddress(string s){ccemailAddress = s;}
    public string getbCCEmailAddress(){return bccemailAddress;}
    public void setbCCEmailAddress(string s){bccemailAddress = s;}
    public string getSelectedEmailAddress(){return selectedEmailAddress;}
    public void setemailBodyHtml(string s)
    {
        /*because this is a property and a controller i dont know what is getting called first, last, second whatever
        so... this only sets the variable if this assignement is made.  nothing else can be put in this function? not sure..
        anyway, it ensures the email body is formatted properly.  a problem i ran into is that if i allow the user the ability
        to change the email body, it would be of type string.  however strings can contain chars like \n\t and etc.  however,
        if you print out a string with those chars in html, it won't newline or tab.  you have to use html tags for that.  so i had
        create a function that parsed a text string to html string. */
        emailBodyHtml=textToHtml(s.split('\n',0));
        
    }
    public string getemailBodyHtml(){return emailBodyHtml;}
    public void setemailSubject(string s){emailSubject=s;}
    public string getemailSubject(){return emailSubject;}
    public string textToHtml(string[] s)
    {
        /*this is an "apex" workaround of how to get a string to look how you would expect it to in html.  there is a string method
        called split that will take a string as an argument, and split the string into mutiple strings where at a char value. so this function
        basically takes array of strings that are returned, assigns them to a single string and returns it.  works for what i need it to do*/
        string tempstr='';
        for (integer i=0; i<s.size(); i++)
        {
            tempstr+='<p>'+s[i]+'</p>';
        }   
        return tempstr;
    }
    private string FinalEmailSubject
    {
        get
        {
            return getEmailSubject();
        }
    }
    /*public static boolean isUserApartOfInternationalProfile()
    {
        Id internationalProfile1 = '00e30000000yHrE';
        Id internationalProfile2 = '00e30000000xxBA';
        Id internationalProfileForSandBox = '00e30000000yHrE';
        
        if (true)
        {
           if (( Userinfo.getProfileId() == internationalProfile1  )|| ( UserInfo.getProfileId() == internationalProfile2 ))
           {
               return true;
           }
           else
           {
               return false;
           }
        }
        else
        {
            if (Userinfo.getProfileId() == internationalProfileForSandBox)
            {
                return true;
            }
            else
            {
              return false;
            }
        } 
    }*/
    private string FinalHtmlBody 
    {
        get
        {
            return '<html>' + getemailBodyHtml() + ' <br /><br /><br />' +  '</html>';
        }
        
    }    
    
    public PageReference selectContactOrUser()
    {
        string tempString = null;
        if (tempCaseObject.closed_by__c != null)
        {
            try
            {
                tempString = [select email from User where id =: tempCaseObject.Closed_by__c].email;
            } 
            catch(Exception e)
            {
                // do nothing
            }
            
        }
        else if (tempCaseObject.contactid != null)
        {
            try
            {
                tempString = [select email from Contact where id =: tempCaseObject.contactid].email;
            } 
            catch(Exception e)
            {
                // do nothing
            }
        }
        selectedEmailAddress = tempString;
        
        return null;
    }
    
    public PageReference determineWhichLookUpToGrabEmailAddressFor()
    {
        if (isSelectingContact == null)
        {
            //  for some reason, i'm getting a null exception at this line:  caused by: System.NullPointerException: Attempt to de-reference a null object
            //Class.CaseEventEmailExtension.determineWhichLookUpToGrabEmailAddressFor: line 148, column 13 External entry point
            //  however, the boolean is being set in the constructor... so we have to make this check anyway.  i dont know whats wrong
            
            return null;
        }
        if (isSelectingContact)
        {
            tempCaseObject.closed_by__c = null;
        }
        else
        {
            tempCaseObject.contactid = null;
        }
        return null;
    }
    
    public PageReference addEmailAddress()
    {
        //  this function would do soemthing to the effect of: if the on the fields is filled in, query the apprioate email address 
        //  if any and add it to the string of email addres,  or whatever was passed into this class (the string passed into the class
        //  should be the to email Address
        string emailAddressToAdd = selectedEmailAddress;
        
        if (emailAddressToAdd != null)
        {
            if (toEmailAddress == null || toEmailAddress.length() < 1)
            {
                toEmailAddress = '' + emailAddressToAdd + '; ';
            }
            else
            {
                toEmailAddress += ' ' + emailAddressToAdd + '; ';
            }
        }
        
        return null;
    }
    
    public PageReference addCCEmailAddress()
    {
        string emailAddressToAdd = selectedEmailAddress;
        
        if (emailAddressToAdd != null)
        {
            if (ccEmailAddress == null || ccEmailAddress.length() < 1)
            {
                ccEmailAddress = '' + emailAddressToAdd + '; ';
            }
            else
            {
                ccEmailAddress += ' ' + emailAddressToAdd + '; ';
            }
        }
        return null;
    }
    
    public PageReference addBCCEmailAddress()
    {
        string emailAddressToAdd = selectedEmailAddress;
        
        if (emailAddressToAdd != null)
        {
            if (bccEmailAddress == null || bccEmailAddress.length() < 1)
            {
                bccEmailAddress = '' + emailAddressToAdd + '; ';
            }
            else
            {
                bccEmailAddress += ' ' + emailAddressToAdd + '; ';
            }
        }
        return null;
    }
    
    public void updateScreen()
    {
        //there is an ajax link on the vf page when clicked calls this function. 
        //this function also makes sure the email body html is set for the update and for sending the email
        setemailbodyHtml(getemailbodytext());
    }
    
    public id createCaseEvent()
    {
        //creates a case event stating email was sent after the email is sent
        Case_Event__c ce=new Case_Event__c();
        ce.case__c=theCaseEvent.case__c;
        ce.subject__c='Email Sent From Case Event No. ' + theCaseEvent.name + ' to: '+ toEmailAddress;
        ce.Communication_Type__c = 'Email';
        ce.details__c = 'Email subject: ' + FinalEmailSubject + '\n\n' +
            'Email body: ' + FinalHtmlBody;//  we want _this_ event to contain the body subject of the email sent from the other event
        //  the case time record created after this will use now as start time , and end time = now + 5 minutes
        
        ce.Time_Spent__c = 5;//  the below probably doesnt need to be set, but this is justa  test
        ce.Start_Time__c = dateTime.now();
        ce.End_Time__c = dateTime.now().addMinutes(5);    
        
        dataBase.saveResult sr = database.insert(ce);
        if (sr.isSuccess())
        {
            return sr.getId();
        }
        else
        {
            throw new myException('Failed to create shadow case event when sending email'); 
        }
        
    }
    
    public PageReference sendEmail()
    {
        //makes sure the emailbodyhtml is set properly
        if (!checkRequiredfields())
        {
            return null;
        }
        else
        {
            updateScreen();
            
            Messaging.SingleEmailMessage mail= new Messaging.SingleEmailMessage();
            //the setToaddressess accessor function expects a list of strings so need to declare a list of strings even if its only one To: address
            String[] toAddresses = new List<string>();
            String[] ccAddressList = new List<String>();
            String[] bccAddressList = new List<String>();
            //boolean isUserApartOfInternationalProfile = isUserApartOfInternationalProfile();
            final id INTERNATIONAL_EMAIL_ADDRESS_ID = '0D230000000008A';//  varsupport@roadnet.com email address
                    
            //retrieves teh address entered in by the user
            CaseEventSummaryExtension.populateToAddressesWithListOfEmails(toAddresses, toEmailAddress);
            
            //  if the ccemailaddress field is filled in        
            if (ccEmailAddress.length() != 0 )
            {
                if (ccEmailAddress != null)
                {
                    CaseEventSummaryExtension.populateToAddressesWithListOfEmails(ccAddressList, ccEmailAddress);
                }
            }
            /*  to fix colleen's issue with her getting cases created for salesforce automated emails, i'm turnign this off because 
                it can start a looping email notification
                
            //  if the user is international, add the varsupport@roadnet.com to teh cc email address.
            if (isUserApartOfInternationalProfile)
            {
                ccAddressList.Add('varsupport@roadnet.com');
            }
            */
            if (bccEmailAddress.length() != 0)
            {
                if (bccEmailAddress != null)
                {
                    CaseEventSummaryExtension.populateToAddressesWithListOfEmails(bccAddressList,bccEmailAddress);
                    mail.setBccAddresses(bccAddressList);
                }
            }
            //  add the ref numbers
            //  these have been moved to getters
            
            try
            {
                //  if the user is apart of international profile, then set the the orgaationwide email adrees to be varsupport@roadnet.com
                //if (isUserApartOfInternationalProfile)
                //{
                    //system.assertNotEquals(null, INTERNATIONAL_EMAIL_ADDRESS_ID);
                    /*
                    Messaging.sendemailResult[] emailREsults = 
                        EmailClass.sendEmail(toAddresses, ccAddressList, bccAddressList, FinalEmailSubject, FinalHtmlBody, emailBodyText,
                        INTERNATIONAL_EMAIL_ADDRESS_ID);
                    EmailClass.checkEmailResults(emailResults);                        
                    */
                //}
               // else
                //{
                   /* Messaging.sendemailResult[] emailResults = 
                        EmailClass.sendEmail(toAddresses, ccAddressList, bccAddressList, FinalEmailSubject, FinalHtmlBody, emailBodyText, Util.FromAddressForCases);
                    EmailClass.checkEmailResults(emailResults);
                    */
               // }
                            
                isEmailSent=true;
                //added Nov 10th, 2008 clarified that when this email was sent, we wanted it to be tracked
                //in case event
                Id newlyCreatedCaseEventId = createCaseEvent();
                //createCaseTimeRecord(newlyCreatedCaseEventId);
                //updateCaseTimeSpent();
            }
            catch(Exception e)
            {
               /* EmailClass.sendErrorEmail('failed to send case event email due to ' + e.getMessage(), theCaseEvent.id);
                */
                theCaseEvent.addError('Failed to send email due to ' + e.getMessage());
                
                return null;
            }   
            
            PageReference pr = new PageReference('/apex/CaseInfoMessagePage?retURL=%2f' + theCaseEvent.id + '&enum=12');
            pr.setRedirect(true);
            return pr;
        }
    }
    
    /*private void createCaseTimeRecord(Id caseEventId)
    {
        Mibos_Case_Time__c ct = new Mibos_Case_Time__c();
        ct.Owner__c = userinfo.getUserId();
        ct.Start_Time__c = datetime.now();
        ct.End_time__c = dateTime.now().addMinutes(5);
        ct.Case__c = theCaseEvent.Case__c;
        ct.Case_Event__c = caseEventId;
        ct.Work_Effort__c = 5;
        insert ct;
        
    }*/
    
    private boolean checkRequiredFields()
    {
        boolean isOkToSave = true;
        
        if ((toEmailAddress == null) || (toEmailAddress.length() == 0))
        {
            theCaseEvent.addError('To address needs to be specifed.  Please enter in one (or multiple) to email addresses.');
            isOkToSave = false;
        }
        if (emailSubject.length() > 255)
        {
            theCaseEvent.AddError(
              'The Email subject is too long.  It must be less than 255 characters.  It is currently: ' + emailSubject.length());
            isOkToSave = false;           
        }
        
        return isOkToSave;
    }
    
    public static Case_Event__c queryCaseEvent(id caseeventId)
    {
        if (caseeventId != null)
        {
            return [SELECT Id,Name, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, 
              Details__c, Communication_Type__c, 
              Subject__c, Case__c, Display_in_Customer_Portal__c, Time_Spent__c, ShadowId__c
               from case_event__c where id =: caseEventId limit 1];
        }
        else
        {
            return null;
        }
    }
    
    /*public static Case_Event__c createTestCaseEvent(Id recordtypeid)
    {
        Case_Event__c ce = new Case_Event__c();
        ce.case__c = [select id from case where accountid != null limit 1].id;
        ce.case_comment_id__c = 'test case comment';
        ce.Communication_Type__c = 'Phone';
        ce.details__c = 'test details';
        ce.subject__c = 'test subject';
        ce.Time_Spent__c = 123.45;
        
        database.saveResult sr = database.insert(ce);
        if (sr.isSuccess())
        {
            ce = queryCaseEvent(sr.id);
        }
        return ce;
    }*/
    

    public class myException extends exception{}
}