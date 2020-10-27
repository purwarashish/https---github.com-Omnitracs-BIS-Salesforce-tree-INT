/*******************************************************************************
 * File:  CaseEventSummaryExtensions.cls
 * Date:  October 30th, 2008
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
public class CaseEventSummaryExtension
{
   
    private Case c;
    private Id caseId;
    public Case tempCaseObject = new Case(); //  this will be holder for the user/contact lookup
    public string caseTitle{get;set;}
    public string emailSubject{get;set;}
    public string emailbodytext{get;set;}
    public string caseHeader{get;set;}
    public string selectedEmailAddress{get;set;}
    private string ccEmailAddress;
    private string bccEmailAddress;
    private string emailComments = '';
    private boolean isSelectingContact = false;
    public string toEmailAddress=null;
    
    public boolean isEmailSent=false;
        
    //standard constructor
    public CaseEventSummaryExtension(ApexPages.StandardController stdController)
    {
        isSelectingContact = false;
        //  default to false, only a regular user can set this true to and only via the vf page
        showPrivateCaseEvents = true;
        caseId = stdController.getId();
        system.assertNotEquals(null, caseId);
        c = [select id, accountId, subject, casenumber, email__c, description, Solution_long__c, CreatedBy.Name, CreatedDate, Origin, Time_Spent__c
            from case where id =: caseId];
        caseTitle='Case Event Summary for Case #' + c.casenumber;
        caseHeader=formatCaseHeading();
        emailSubject=caseTitle;
        emailbodytext=retrieveEmailBodyData();
        initEmailFields();
    }
         
    private void initEmailFields()
    {
        //  per Mike C. the defaulting of the toemailaddreess with the contacts email is a hinderance.  it's possible to mistakenly
        //  send the email to contact
        //toEmailAddress = c.Email__c + '; ';
        try
        {
            ccEmailAddress = [select email from user where id =: userInfo.getUserId()].email + ';';
        }
        catch(Exception e)
        {
            //  if above query doesn't work, no biggie.
        }
        
    }

    //this setter/getter is only to display case information on the vf page
    public void setC(Case ca){c=ca;}
    public Case getC(){return c;}
    public string getCCEmailAddress(){return ccemailAddress;}
    public void setCCEmailAddress(string s){ccemailAddress = s;}
    public string getbCCEmailAddress(){return bccemailAddress;}
    public void setbCCEmailAddress(string s){bccemailAddress = s;}
    public string getEmailComments(){return emailComments;}
    public void setEmailComments(string s){emailComments = s;}
    public Case gettempCaseObject(){return tempCaseObject;}
    public void settempCaseObject(Case c){ tempCaseObject = c;}
    public boolean getIsSelectingContact(){return isSelectingContact;}
    public void setIsSelectingContact(boolean b){isSelectingContact = b;}
    
    public boolean showPrivateCaseEvents{get; set;}
    public string caseCreatedDateFormated
    {
        get
        {
            if (c != null)
            {
                return c.CreatedDate.format();
            }
            return null;
        }
    }
    public boolean isPortalUser
    {
        get
        {
            return CaseEventExtension.isActivePortalUser();
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
        if (isSelectingContact != null)
        {
            if (isSelectingContact)
            {
                tempCaseObject.closed_by__c = null;
            }
            else
            {
                tempCaseObject.contactid = null;
            }
        }
        else//  if its null, assume its false as it should be false by default anyway
        {
            tempCaseObject.contactid = null;
        }
        selectedEmailAddress = null;//  clear the selected email address
        
        return null;
    }
    
    public PageReference addEmailAddress()
    {
        //  this function would do soemthing to the effect of: if the on the fields is filled in, query the apprioate email address 
        //  if any and add it to the string of email addres,  or whatever was passed into this class (the string passed into the class
        //  should be the to email Address
        selectContactOrUser();//  force the selected string to be assigned when the add email address button is pressed
        
        system.debug('ctrlf ****************** addEmailAddress method called');
        string emailAddressToAdd = selectedEmailAddress;
        
        system.debug('ctrlf ****************** Selected email address = ' + selectedEmailAddress);
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
        selectContactOrUser();//  force the selected string to be assigned when the add email address button is pressed

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
    
    public PageReference addBccEmailAddress()
    {
        selectContactOrUser();//  force the selected string to be assigned when the add email address button is pressed

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
    
    public string[] getSummary()
    {
       // this function is the meatandbones for this class.  what it does is retrieves all case events from
       // the case.  then, for every case event, it uses HTML tags to format the string.  THIS IS CRUCIAL!!!
       // the reason being is that any type of getter function that an apex tag calls can only display a string WITH
       // NO STRING FORMATTING (\n \t \0)... to have the text display bold and in paragraph format we assign the string with the
       // data of the case event object but append html tags.  every caseevent is converted to a string, and stored in a string array
       // the function returns a list of strings which the apex page iterates over in a datalist
        List<string> str=new List<string>();
        //  need to put the frist case event (which is the case subject details) on the stop of the llist
        string caseSubjectDetail = '';
        
        Case_Event__c[] ce=getcaseEvents();  
        for (integer i=0; i<ce.size(); i++)
        {
            string tempString='';
            tempString+='<b>Date: ' +ce[i].CreatedDate.format()+' </b>';
            //tempString+='<p><b>Created by: </b>' + ce[i].Opened_By__c +'</p>';
            tempString+='<p><b>Communication Type: </b>'+ nullToBlank(ce[i].Communication_Type__c) +'</p>';
            tempString+='<p><b>Subject: </b>'+ nullToBlank(ce[i].Subject__c) +'</p>';
            tempString+='<p><b>Details: </b>' + nullToBlank((ce[i].details__c != null ? ce[i].Details__c.Replace('\n', '<br>') : '')) + '</p>';
            
            tempString+='<br></br><br></br>';
            str.add(tempString);
        }
        return str;
    }
        
    public Case_Event__c[] getcaseEvents()
    {
        //  if the user is a portal user, we only want to query case events that are marked
        //  for internal usage only
        if (CaseEventExtension.isActivePortalUser() || !showPrivateCaseEvents)// query only public case events
        {
            return [Select c.CreatedDate, C.Communication_Type__c, c.Time_Spent__c, 
                c.Subject__c, c.Name, c.Id, c.Details__c, c.Case__c
                from Case_Event__c c where c.Case__c=:c.id AND 
                Display_in_Customer_Portal__c = true order by createddate desc];
        }
        else//   query all case events
        {
            return [Select c.CreatedDate, C.Communication_Type__c, c.Time_Spent__c, 
                c.Subject__c, c.Name, c.Id, c.Details__c, c.Case__c
                from Case_Event__c c where c.Case__c=:c.id order by createddate desc];
        }
        
    }
    public void setToEmailAddress(string s){toEmailAddress=s;}
    public string getToEmailAddress(){return toEmailAddress;}
    public string formatCaseHeading()
    {
        //  this is just a standard case heading for the case summary
        string accountName;
        if (c.accountId != null)
        {
            accountName = [select name from account where id=:c.accountid].name;
        }
        else
        {
            accountName = 'None';
        }
        string theString;
        
        theString = 
            'Case Event Summary for Case #' + c.casenumber +
            '\nAccount Name: ' + accountName +  
            '\nCreated Date: ' + c.createddate.format() +
            '\nCase Origin: ' + c.origin +
            '\nCase Subject: ' + c.subject +
            '\nCase Description: ' + c.description;
                    
        return theString;
        
    }
    
    public PageReference toggleShowPrivateCaseEventsCheckbox()
    {
        showPrivateCaseEvents = !showPrivateCaseEvents;
        emailBodyText = retrieveEmailBodyData();//  reset the email body data
        
        return null;
        
    }
    
    public PageReference sendEmail()
    {   
        //  function that sends apexemail then creates an email task with the same info the apexemail
        //  contains (without the body however--not sure if the body is important in a taskemail)
        //  i believe the getToEmailAddress was returning an empty string instead of null so had to 
        //  check if the toemailaddress was == '' except for null
        //  it just prevents the emails from being created and sent if the user didnt specify a to address
        
        if (toEmailAddress != '' && toEmailAddress != null)
        {
            try
            {
                sendApexEmail();
            }
            catch(EmailException e)
            {
                c.addError(e.getMessage());
                return null;
            }
            catch(Exception e)
            {
                c.addError('unknown error occured: ' + e.getMessage());
                return null;
            }
            
            //used to print to screen whether or not the email was sent to user
            isEmailSent=true;
            createCaseEventStatingThatEmailWasSent();
            //createCaseTimeRecord();
            //updateCaseTimeSpent(c);
            
            PageReference pr = Page.CaseInfoMessagePage;
            pr.getParameters().put('enum', '12');
            pr.getParameters().put('retURL', '/' + c.id);
            
            pr.setRedirect(true);
            return pr;
        }
        
        c.addError('To Email address needs to be set.');
        
        return null;
    }
    private void createCaseTimeRecord()
    {
        Mibos_Case_Time__c ct = new Mibos_Case_Time__c();
        ct.Owner__c = userinfo.getUserId();
        ct.Start_Time__c = datetime.now();
        ct.End_time__c = dateTime.now().addMinutes(5);
        ct.Case__c = c.id;
        ct.Work_Effort__c = 5;
        insert ct;
        
    }
     private void createCaseEventStatingThatEmailWasSent()
    {
        //creates a case event stating email was sent after the email is sent
        Case_Event__c ce=new Case_Event__c();
        ce.case__c = c.id;
        ce.Communication_Type__c = 'Email';
        ce.subject__c='Case Event Summary Email Sent From Case No. ' + c.casenumber + ' to: '+ toEmailAddress;
        ce.details__c = emailComments + '\n\n' + EmailbodyText;//emailComments;
        ce.Time_Spent__c = 5;
        try 
        {
            insert ce;
        }
        catch(Exception e)
        {
            system.debug(e.getmessage());
        }
    }
    
    private void sendApexEmail()
    {
        String[] toAddresses = new List<string>();
        String[] ccAddressList = new List<String>();
        String[] bccAddressList = new List<String>();
        
        populateToAddressesWithListOfEmails(toAddresses, toEmailAddress);
        if (ccEmailAddress.length() != 0 )
        {
            if (ccEmailAddress != null)
            {
                CaseEventSummaryExtension.populateToAddressesWithListOfEmails(ccAddressList, ccEmailAddress);
            }
        }
        if (bccEmailAddress.length() != 0)
        {
            if (bccEmailAddress != null)
            {
                CaseEventSummaryExtension.populateToAddressesWithListOfEmails(bccAddressList, bccEmailAddress);
            }
        }
        
        string emailSubjectWithRef = emailSubject;
        
        string plainTextBody = emailComments + '\n\n' + EmailbodyText + '\n\n\n';
        string htmlBody = '';//EmailClass.convertTextToHtml(plainTextBody);
            
        Messaging.sendemailResult[] emailResults = EmailClassRoadnet.sendEmail(
           toAddresses, 
           ccAddressList, 
           bccAddressList,
           emailSubjectWithRef, 
           htmlBody, 
           plainTextBody, 
           EmailClassRoadnet.FromAddressForCases);
        
        EmailclassRoadnet.checkEmailResults(emailResults);   
        /*
        //  there seems to be multiple ways to send email using salesforce... this one appears to be strictly 
        //  behind the scences code so i choose this method.
        //  it is useful for sending single emails only however it does not update task history or 
        //  acitivity history in the system for the
        //  case so the shadowblahblah function was needed also.
        
        String[] toAddresses = new List<string>();
        String[] ccAddressList = new List<String>();
        String[] bccAddressList = new List<String>();
        boolean isUserApartOfInternationalProfile = CaseEventSummaryExtension.isUserApartOfInternationalProfile();
        final id INTERNATIONAL_EMAIL_ADDRESS_ID = '0D230000000008A';
        
        populateToAddressesWithListOfEmails(toAddresses, toEmailAddress);
        
        //  if the ccemailaddress field is filled in        
        if (ccEmailAddress.length() != 0 )
        {
            if (ccEmailAddress != null)
            {
                CaseEventSummaryExtension.populateToAddressesWithListOfEmails(ccAddressList, ccEmailAddress);
            }
        }
        
            
        if (bccEmailAddress.length() != 0)
        {
            if (bccEmailAddress != null)
            {
                CaseEventSummaryExtension.populateToAddressesWithListOfEmails(bccAddressList, bccEmailAddress);
            }
        }        
        
        string emailSubjectWithRef = emailSubject;
        
        string plainTextBody = emailComments + '\n\n' + EmailbodyText + '\n\n\n';
        string htmlBody = '';//EmailClass.convertTextToHtml(plainTextBody);
        
        //  if the user is apart of international profile, then set the the orgaationwide email adrees to be varsupport@roadnet.com
        if (isUserApartOfInternationalProfile)
        {
            system.assertNotEquals(null, INTERNATIONAL_EMAIL_ADDRESS_ID);
            //Messaging.sendemailResult[] emailREsults = EmailClass.sendEmail(toAddresses, ccAddressList, bccAddressList, emailSubjectWithRef, htmlBody, plainTextBody, 
            //    INTERNATIONAL_EMAIL_ADDRESS_ID);
            //Emailclass.checkEmailResults(emailResults);
            
        }
        else
        {
            //Messaging.sendemailResult[] emailREsults = EmailClass.sendEmail(toAddresses, ccAddressList, bccAddressList, emailSubjectWithRef, htmlBody, plainTextBody, Util.FromAddressForCases);
            //Emailclass.checkEmailResults(emailResults);
            
        }
        */
    }
     public static string[] parseString(string str)
    {
        //this function takes a string as argumetns and returns a list of strings.  it splits strings up by a semicolon.  for example, if the string passed in
        //was "this; is; a; string;"  then it would return 1-this 2-is 3-a 4-string
        string[] theStrings=new list<string>();
        if (str==null){}
        else
        {   
            theStrings=(str.split(';', 0));
            //lets make sure there isn't blank items in the list and try to clear in any leading trailign whitespaces
            for (integer i=0; i<theStrings.size();i++)
            {
                theStrings[i]=theStrings[i].trim();
                if (theStrings[i]=='') theStrings.remove(i);
            }
        }
        return theStrings;
    }
    
    public static void populateToAddressesWithListOfEmails(List<string> listOfEmailAddresses, string multipleEmailAddress )
    {
        List<string> emailAddressParsedIntoList = new List<string>();
        
        emailAddressParsedIntoList = parseString(multipleEmailAddress);
        listOfEmailAddresses.clear();
        if (emailAddressParsedIntoList != null && emailAddressParsedIntoList.size() > 0)
        {
           listOfEmailAddresses.addAll(emailAddressParsedIntoList);
        }
        
    }
    
    public static boolean isUserApartOfInternationalProfile()
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
    }


    public string getEmailStatus()
    {
        if (isEmailSent)
            return 'Email was Sent';
        else
            return null;
    }
    public string textToHtml(string[] s)
    {
        /*this was taken straight from caseWizardExtension class
        this is an "apex" workaround of how to get a string to look how you would expect it to in html.  there is a string method
        called split that will take a string as an argument, and split the string into mutiple strings where at a char value. so this function
        basically takes array of strings that are returned, assigns them to a single string and returns it.  works for what i need it to do*/
        string tempstr='';
        for (integer i=0; i<s.size(); i++)
        {
            tempstr+='<br>'+s[i]+'</br>';
        }   
        return tempstr;
    }
    
    public pageReference redirectToEmail()
    {   
        //when user presses the button "email this summary" this function is called and just directs user to the email page
        return Page.caseEventSummaryEmailPage;
    }
        
    public string retrieveEmailBodyData()
    {
        //this function formats all the case events and their data 
        //into a nice string that be displayed in an inputtext field on the vf page
        Case_Event__c[] ce=getcaseEvents();
        string tempString = formatCaseHeading()+'\n\n';
        
        for (integer i=0; i<ce.size(); i++)
        {
            //  this puts star-like seperator in between each case event.
            tempString += '***************************************************************************************\n';
            tempString+='\nDate: ' +ce[i].CreatedDate.format();
            tempString+='\n\nCase No:' + ce[i].Name;
            tempString+='\n\nCommunication Type:  '+ nullToBlank(ce[i].Communication_Type__c);
            tempString+='\n\nSubject:  '+ nullToBlank(ce[i].Subject__c);
            tempString+='\n\nDetails:  '+ nullToBlank(ce[i].Details__c);
            
            tempString+='\n\n';
        }
        return tempString;
     }
  
    private string nullToBlank(string str)
    {
        if (str == null)
        {
            return '';
        }
        else
        {
            return str;
        }
        
    }
    public class myException extends Exception{}
}