/*********************************************************************
Name    : PortalInviteExtension
Author  : David Ragsdale
Date    : 13 November 2011

Usage   : This class is used by the 'PortalInvite' page to:
          - update fonts and buttons on the page according to the status of the contact and unity invite
          - encrypt the SF contact ID (uses Crypto Class)

Dependencies:  CryptoUtils
    
*********************************************************************/
public with sharing class PortalInviteExtension {

//Variables
public string userProfileId = userinfo.getProfileId();
public boolean showStatusButton { get; set; } 
public boolean showInviteButton { get; set; }
public boolean showUnityStatus { get; set; }
public boolean showNoDiscountMessage {get; set;}
// Added by Pratyush
public String backendValidationMsg {get; set;}
public boolean showUnityBackendValidationMsg {get; set;}

//Added for Partner Messages
public string inviteWarningMsg {get; set;}
public boolean showinviteWarningMsg {get; set;}
public boolean warningMsgRequired {get; set;}

private Contact newContact {get; set;}{newContact = new Contact();} 
private boolean showGreenFont;
private List<Contact> lstNewContact;
private List<user> lstUser;
private string ContactId {get; set;}
private string decryptedID;
private string encryptedID;
private string newContactID;
private string newEncryptedID;
private string tempString;
public  string instanceURL;
   
    //Constructor
    public PortalInviteExtension(ApexPages.StandardController controller)
    {
        ContactId = Apexpages.currentPage().getParameters().get('Id');
        
        lstNewContact = [SELECT 
                            Id, 
                            FirstName, 
                            LastName, 
                            accountId,
                            Account.AGUID__c,
                            phone, 
                            mobilePhone, 
                            Unity_Contact_Status__c, 
                            UnityStatus__c 
                         FROM 
                            Contact 
                         WHERE 
                            Id = :ContactId 
                         LIMIT 1
                        ];

    }
    
    public string getFirstName(){
        return lstNewContact[0].FirstName;
    }
    
    public string getLastName(){
        return lstNewContact[0].LastName;
    }
    //Gayatri.K , 9/10/2020.
    public String getUUID(){
        String businessAccountId = lstNewContact[0].Account.AGUID__c;
        if(String.isBlank(businessAccountId)){
            return NULL;
        }
        businessAccountId = businessAccountId.trim().toLowerCase();
        return  businessAccountId.length() < 32 ? businessAccountId : (businessAccountId.subString(0, 8) + '-' +
                                                                       businessAccountId.subString(8, 12) + '-' +
                                                                       businessAccountId.subString(12, 16) + '-' +
                                                                       businessAccountId.subString(16, 20) + '-' +
                                                                       businessAccountId.subString(20, businessAccountId.length()));
    } 
  
    //Determines the font color for the Contact Status field
    public boolean getshowGreenFont()
    {
        if( (lstNewContact[0].Unity_Contact_Status__c =='OK') && (!showUnityBackendValidationMsg) )
        {
            showGreenFont = true;
        }else{
            showGreenFont = false;
        }
        
        return showGreenFont;
    }

//Returns full 18 character ID for contact
    public string getFullContactID()
    {
        newContactID = lstNewContact[0].Id;
        
        return newContactID;
    }       

    //Updates the Invitor information on the Contact record
    public void updateInvitor(){
        if(!(lstNewContact.isEmpty()))
        {
            lstUser = [SELECT Name, Email, Phone, Title 
                FROM User 
                WHERE Id = :UserInfo.getUserId() 
                LIMIT 1];

            lstNewContact[0].Unity_Invitor__c = UserInfo.getName();
            
            lstNewContact[0].Unity_Invitor_Email__c = lstUser[0].Email; 
            
            lstNewContact[0].Unity_Invitor_Title__c = lstUser[0].Title;
            
            lstNewContact[0].Unity_Invitor_Phone__c = lstUser[0].Phone;           
            
            update lstNewContact[0];
        }
    }

    //Determines if the fields and buttons should be shown on page
    //Note:  Only one button should be on the page at a time
    public pageReference toggleButton()
    {
        instanceURL = system.label.Instance_URL;
        //Get List of Custom Settings showing Profiles that are allowed to invite Users to UNITY
        List<UNITYInviteProfileID__c> lstProfileID = [SELECT profileID__c from UNITYInviteProfileID__c WHERE ProfileID__c = :userProfileID LIMIT 1];
        
        //Get List of Custom Settings showing Profiles that should get a warning above the invite button               
        List<UnityLoginReminder__c> lstWarningID = [SELECT profileID__c from UnityLoginReminder__c WHERE ProfileID__c = :userProfileID LIMIT 1];

        //check to see if current user should get warning message
        if (lstWarningID.size() > 0)
        {
          warningMsgRequired = true;
        }else{
          warningMsgRequired = false;
        }
               
        //if user is part of Duplicate Group - no check 
        if (lstProfileID.size() >  0)
        {
            // Added by Pratyush
            List<Account> lstAccounts = [SELECT 
                                            Id, 
                                            phone, 
                                            fax 
                                         FROM 
                                            Account 
                                         WHERE 
                                            Id = :lstNewContact[0].accountId 
                                         LIMIT 1
                                        ];        
                                        
            if (lstNewContact[0].Unity_Contact_Status__c == 'OK' 
                && (lstNewContact[0].UnityStatus__c == ''
                || lstNewContact[0].UnityStatus__c == 'STAGING' 
                || lstNewContact[0].UnityStatus__c == null))
            {
                inviteWarningMsg = 'Important: Please login to the <a href=" '+ instanceURL + ' target="_blank"> Omnitracs Customer Portal </a>before you initiate a customer invite.';
                backendValidationMsg = ' The following phone numbers are incorrectly formatted.  Please update the phone number(s) to the following format (XXX) XXX-XXXX. Extension (if any) should be entered in the separate field provided.'; 
                String regExString = '\\(\\d{3}\\)[\\s]\\d{3}-\\d{4}';
                Pattern regExPattern = Pattern.compile(regExString);
                Matcher tmpMatcher = null;
                
                if(null != lstAccounts[0].phone) {  
                    tmpMatcher = regExPattern.matcher(lstAccounts[0].phone);
                    if('' != tmpMatcher.replaceFirst('')) {                    
                        backendValidationMsg += '<br/> Account Phone: ' + lstAccounts[0].phone;
                        showUnityBackendValidationMsg = true;              
                    }
                }
                
                if(null != lstAccounts[0].fax) {   
                    tmpMatcher = regExPattern.matcher(lstAccounts[0].fax);
                    if('' != tmpMatcher.replaceFirst('')) {                    
                        backendValidationMsg += '<br/> Account Fax: ' + lstAccounts[0].fax;
                        showUnityBackendValidationMsg = true;              
                    }
                }
                
                if(null != lstNewContact[0].phone) {   
                    tmpMatcher = regExPattern.matcher(lstNewContact[0].phone);
                    if('' != tmpMatcher.replaceFirst('')) {                    
                        backendValidationMsg += '<br/> Contact Phone: ' + lstNewContact[0].phone;
                        showUnityBackendValidationMsg = true;              
                    }
                }
                
                if(null != lstNewContact[0].mobilePhone) { 
                    tmpMatcher = regExPattern.matcher(lstNewContact[0].mobilePhone);
                    if('' != tmpMatcher.replaceFirst('')) {                    
                        backendValidationMsg += '<br/> Contact Mobile: ' + lstNewContact[0].mobilePhone;
                        showUnityBackendValidationMsg = true;              
                    }
                }
                
                if(showUnityBackendValidationMsg == true) {
                    showInviteButton = false;    
                    showStatusButton = false;
                    showUnityStatus = false;        
                    showinviteWarningMsg = false;
                }else {                                                              
                    showInviteButton = true;    
                    showStatusButton = false;
                    showUnityStatus = true;   
                    showUnityBackendValidationMsg = false;
                    //Check to see if warning message above invite button is needed
                    if (warningMsgRequired)
                    {
                        showinviteWarningMsg = true;
                    }else{
                        showinviteWarningMsg = false;
                    }     
                }
            }else if (lstNewContact[0].UnityStatus__c == 'INVITED')
            {
                showInviteButton = false;    
                showStatusButton = true;            
                showUnityStatus = true;
                showUnityBackendValidationMsg = false;
                //Check to see if warning message above invite button is needed
                if (warningMsgRequired)
                {
                    showinviteWarningMsg = true;
                }else{
                  showinviteWarningMsg = false;
                }
            }else if (lstNewContact[0].UnityStatus__c == 'ON_BOARDING'){
                showInviteButton = false;
                showStatusButton = false;
                showUnityStatus = true;
                showUnityBackendValidationMsg = false;
                showinviteWarningMsg = false;
            }else if (lstNewContact[0].UnityStatus__c == 'USER'){
                showInviteButton = false;
                showStatusButton = false;
                showUnityStatus = true;
                showUnityBackendValidationMsg = false;
                showinviteWarningMsg = false;
            }else{
                showInviteButton = false;
                showStatusButton = false;
                showUnityStatus = false;
                showUnityBackendValidationMsg = false;
                showinviteWarningMsg = false;
            }
        }else{
            showInviteButton = false;
            showStatusButton = false;
            showUnityStatus = true;         
            showUnityBackendValidationMsg = false;
            showinviteWarningMsg = false;
        }
       
        return null;
    }

//**************************ENCRYPTION METHODS************************

    //encrypts the Contact ID
    public string getEncryptedID()  
    {           
        newContactID = lstNewContact[0].Id;
        
        encryptedID = CryptoUtils.encrypt(newContactId);

        tempString = EncodingUtil.urlEncode(encryptedID, 'UTF-8');

        return encryptedID;
    }
    
    //Decrypts contact ID
    public string getDecryptedID()
    {
        //newEncryptedID = lstNewContact[0].hdnContactIDEncrypted__c;
        
        decryptedID = CryptoUtils.decrypt(newEncryptedID);
        
        return decryptedID;
    }
}