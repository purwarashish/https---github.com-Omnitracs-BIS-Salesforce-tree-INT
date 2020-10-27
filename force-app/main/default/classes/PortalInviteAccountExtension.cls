/*********************************************************************
Name    : PortalInviteExtension
Author  : David Ragsdale
Date    : 13 November 2011

Usage   : This class is used by the 'PortalInviteAccount' page to:
          - update fonts and buttons on the page according to the status of the Unity invite

Dependencies:  None
    
*********************************************************************/
public with sharing class PortalInviteAccountExtension {

public string userProfileId = userinfo.getProfileId();
public string CompanyGuid;

public Boolean showStatusButton { get; set; } 

private Account newAccount {get; set;}{newAccount = new Account();} 
private boolean showGreenFont;
private boolean showInviteButton; 
private List<Account> lstNewAccount;
private string AccountId {get; set;}
private string newAccountID;

    //Constructor
    public PortalInviteAccountExtension(ApexPages.StandardController controller)
    {
        AccountId = Apexpages.currentPage().getParameters().get('Id');
        
        lstNewAccount = [SELECT Id, AGUID__c, UnityOnboardStatus__c FROM Account WHERE Id = :AccountId LIMIT 1];    
    }

    //Determines if the Status button should be shown on page
    //Note:  Only one button should be on the page at a time
    public pageReference toggleButton()
    {
        //Get List of Custom Settings showing Profiles that are allowed to invite Users to UNITY
        List<UNITYInviteProfileID__c> listProfileID = [SELECT profileID__c from UNITYInviteProfileID__c WHERE ProfileID__c = :userProfileID LIMIT 1];
               
        //if user is part of Duplicate Group - no check 
        if (listProfileID.size() >  0)
        {
            if (lstNewAccount[0].UnityOnboardStatus__c =='INVITED' 
            || lstNewAccount[0].UnityOnboardStatus__c =='ON_BOARDING')
            {
                showStatusButton = true;
            }else{
               showStatusButton= false;
            }
        }else{
            showStatusButton = false;
        }
        
        return null;
    }

    //Determines the font color for the Contact Status field
    public boolean getshowGreenFont()
    {
        if (lstNewAccount[0].UnityOnboardStatus__c =='' || lstNewAccount[0].UnityOnboardStatus__c =='CUSTOMER')
        {
            showGreenFont = true;
        }else{
            showGreenFont = false;
        }
        
        return showGreenFont;
    }
    
    //Returns full 18 character ID for contact
    public string getFullAccountID()
    {
        newAccountID = lstNewAccount[0].Id;
        
        return newAccountID;
    } 
    
    public string getCompanyGuid()
    {
        CompanyGuid = lstNewAccount[0].AGUID__c;
        
        return CompanyGuid;
    }
     
}