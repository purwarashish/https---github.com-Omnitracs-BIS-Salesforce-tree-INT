/*******************************************************************************
 * File:  AccountAlertExtension.cls
 * Date:  November 21st, 2009
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
public class AccountAlertExtension
{
    public static string CUST_ON_SUPPORT_HOLD = 'Customer is on Support Hold.';
    public AccountAlertExtension(ApexPages.StandardController stdController)
    {
        this.theAccount=(Account)stdController.getRecord();
        acct=[select id, name, support_hold__c, support_hold_date__c, alert_text__c, ParentId, inherit_parent_s_products__c 
            from account where id=:theAccount.id limit 1];
        
        //  only query the parent account if the parentId is set and the child account is inheriting parents products
        if (acct.ParentId != null && acct.Inherit_Parent_s_Products__c)
        {
            parentAccount = [select id, alert_text__c from Account where id =: acct.ParentId];
        }
        
    }
            
    public string formattedAlertText
    {
        get
        {
            //  the contact alert has logic to show the account's alert if the account has alert text in it, but it also has logic 
            //  to show a defauilt message if the account is on support hold, but the alert text is blank, as of 12/23/2013, this
            //  class did not have that logic... it does now
            string alertTextToReturn = createFormattedAlertText(acct.Id); 
            return alertTextToReturn;
            /*string alertText = '';
            
            
            if (acct.alert_text__c != null)//  if the account has an alert text use it
            {
                alertText += acct.alert_text__c;
            }
            
            //  if there is  parent account and the child account is inheritnig the parents products
            if (parentAccount != null && acct.Inherit_parent_s_Products__c)
            {
                if (parentAccount.alert_text__c != null)//  if the parent has alert text
                {
                    if (alertText.length() > 0)//  if the child account alert text is set, append the parent account alert text
                    {
                        alertText += '\n\n' + parentAccount.alert_text__c;
                    }
                    else//  assign just the parent account aler text
                    {
                        alertText += parentAccount.alert_text__c;
                    }
                }
            }
            
            system.debug('ctrlf *************** the alert text = ' + alertText);
            
            if (alertText != null && alertText.length() > 0)
            {
                alertText  =STRING.escapeSingleQuotes(alertText);
                alertText = alertText.replace('\n', '\\n');//  convert new lines to escaped new line character
                alertText = alertText.replace('\r', '\\n');//  convert new lines to escaped new line character
                alertText = alertText.replace('"', '\''); // replace quotation marks with apostrophe
                
                return alertText;
            }
            else
            {
                return null;
            }
            */
        }
    }
    
    
    public boolean shouldShowAlert
    {
        get
        {
            //util.breakpoint(formattedAlertText );
            return (!Util.isBlank(formattedAlertText));
        }  
    }
    
    private final Account theAccount;
    private Account parentAccount = new Account(); 
    private Account acct = new Account();
    
    public static string createFormattedAlertText(id accountId)
    {
        Account acct = [select id, parentid, Inherit_parent_s_Products__c, alert_text__c, Support_Hold__c from Account where id =: accountId];
        Account parentAccount;
        if (acct.parentId != null)
        {
            parentAccount = [select id, parentid, Inherit_parent_s_Products__c, alert_text__c from Account where id =: acct.ParentId];
        }
        
        string alertText = '';
        //  first thing we want to do is check to see if the account is on support hold.  if so , we want to add the genereic
        //  "account is on suport hold message"
        if (acct.Support_hold__c)
        {
            alertText += CUST_ON_SUPPORT_HOLD + '\n\n'; 
        }
        
        if (acct.alert_text__c != null)//  if the account has an alert text use it
        {
            alertText += acct.alert_text__c;
        }
        
        //  if there is  parent account and the child account is inheritnig the parents products
        if (parentAccount != null && acct.Inherit_parent_s_Products__c)
        {
            if (parentAccount.alert_text__c != null)//  if the parent has alert text
            {
                if (alertText.length() > 0)//  if the child account alert text is set, append the parent account alert text
                {
                    alertText += '\n\n' + parentAccount.alert_text__c;
                }
                else//  assign just the parent account aler text
                {
                    alertText += parentAccount.alert_text__c;
                }
            }
        }
        
        system.debug('ctrlf *************** the alert text = ' + alertText);
        
        if (alertText != null && alertText.length() > 0)
        {
            alertText  =STRING.escapeSingleQuotes(alertText);
            alertText = alertText.replace('\n', '\\n');//  convert new lines to escaped new line character
            alertText = alertText.replace('\r', '\\n');//  convert new lines to escaped new line character
            alertText = alertText.replace('"', '\''); // replace quotation marks with apostrophe
            
            return alertText;
        }
        else
        {
            return null;
        }
        
    }
    public class MyException extends Exception{}
}