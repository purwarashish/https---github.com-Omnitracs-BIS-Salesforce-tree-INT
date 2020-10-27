/*******************************************************************************
 * File:  GenerateTempExtensionCodeExtension.cls
 * Date:  Dec 2, 2015
 * Author:  Joseph Hutchins, Modified by Cody Worth
 *
 *  *******************************************************************************/
public class GenerateTempExtensionCodeExtension 
{
    //  used for throwing custom exceptions
    public class myException extends Exception{}
    
    //  **********  Member Variables  **********
    public Account account = new Account();
    public User loggedInUser = new User();
    
    //  **********  Constructor(s)  ***********
    public GenerateTempExtensionCodeExtension(apexpages.standardcontroller stdcontroller)
    {
        system.assertNotEquals(null, stdcontroller.getId());//  make sure an id is passed into controller
        account = [select id, name, /*Clientele_ID__c,*/ owner.email,  Alert_Text__c from Account where id = : stdcontroller.getId()];//  query account
        licenseTask = new Task();      
        licenseTask.whatId = account.id;//  assign account to lru record
        licenseTask.Description = 'Detail reason for the extension';//  default to this per john wajer's request
        
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
    public List<SelectOption> productTypes
    {
        get
        {
            List<SelectOption> productTypes = new List<SelectOption>();
            

                productTypes.add(new SelectOption('', '--None--'));
                ProductTypes.add(new SelectOption('RN', 'RN'));
                productTypes.add(new SelectOption('TP', 'TP'));
                productTypes.add(new SelectOption('MC', 'MC'));
                
                return productTypes;
                
          
        }
    }
    
    public String selectedProductType {get; set;}
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
     /* if (isBlank(selectedProductType))
        {
            licenseTask.Product_Type__c.addError('Need to specify a Product Type.');
            return null;
        } */
        
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
        licenseTask.license_activity__c = 'Product Term Extension';
        licenseTask.License_Key_date__c = date.today();
        licenseTask.Status = 'Completed';
        
        licenseTask.Subject = 'Product Term Extension code for ' + account.Name + 'for ' + selectedProductType + ' product provided on: ' + Date.Today().format()  + '.';
        
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
   
    
    @TestVisible private void updateAccountAlertText()
    {
        string lruReason = Util.isBlank(licenseTask.Description) ? 'No Reason Given' : licenseTask.Description;
        
        string textToPrepend = 
           'Product Term Extension code for ' + account.Name + ' provided on: ' + Date.Today().format() + ' with Reason: ' + lruReason;
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
    @TestVisible private Messaging.SendEmailResult createDigestAndSendEmail(Account a, User user)
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
        
        string subject = 'Product Term Extension Code for ' + a.name;//  subject of the email
        
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
        string input = formattedNowDate + orgId + selectedProductType;
                
        Blob binaryInput = EncodingUtil.base64Decode(input);//  convert the 'key' to binary
        Blob digestBlobFormat = Crypto.generateDigest('MD5', binaryInput);//  generate a digest using MD5 and the supplied binary data
        
        string digestStringFormat = EncodingUtil.convertToHex(digestBlobFormat);//  conver the binary data to a hexadecimal string 
        
        string htmlbody = 'Dear ' + contact.firstName + ', <br /><br />' +
            'The email below supplies an unlock code that will allow the product(s) that are locked out to utilize the Roadnet Transportation Suite.  ' + 
            'Please follow the steps below to apply this product extension code:<br /><br />' +
            '1. Highlight and copy this unlock code: <b> ' + digestSTringFormat + '</b> <br />' + 
            '2. Enter the <b>Administration module</b> of Roadnet Transportation Suite <br />' +
            '3. Go to <b>Tools – License</b> <br />' +
            '4. <b>Right-click on the product</b> that has expired and hit the Extend Term button<br />' +
            '5. <b>Paste</b> in the <b>Product Extension code provided</b> in this email and hit <b>Apply</b> <br />' +
            '6. You should now observe the new 30 day extension to that product’s expiration date. <br />' +
            '7. Repeat this same process for any additional products that have expired. Note: A new Product Extension Code is needed for each expired product.<br /><br />' +
            'This code will provide a one-time, 30 day grace period on the product expiration lock-out and allow your organization to use the system ' + 
            'while you work with your Omnitracs Roadnet Account manager to permanently address this concern. ' + 
            'Please call 800-762-3638 if you are experiencing any issues with applying this product extension code.';
        
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
            emailRecipients = PTE_Email_Recipients__c.getAll().keySet();
        }
        catch(Exception e)
        {
            util.debug('failed to get custom setting email recipients for PTE_Email_Recipients__c due to: ' + e.getMessage());
            
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
        
        string internalHtmlBody = '<b>Product Term Extension Reason:</b> <br />' + licenseTask.Description + '<br /><br />' + htmlBody;
        
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
    
    @TestVisible private static Messaging.sendemailResult[] sendMultipleEmails(List<Messaging.SingleEmailMessage> emails)
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
    @TestVisible private static ApexPages.StandardController generateController(Account account)
    {
        pagereference pageRef=new pagereference('Page.NameOfExtension');
        test.setcurrentpage(pageRef);
        ApexPages.currentPage().getParameters().put('Id', account.id);
             
        return new ApexPages.standardController(account);
    }

    @TestVisible private static boolean isBlank(string str)
    {
        if (str == null)
        {
            return true;
        }
        if (str.length() == 0)
        {
            return true;
        }
        if(str == ''){
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
        
    }
}