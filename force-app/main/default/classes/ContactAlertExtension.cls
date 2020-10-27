/*******************************************************************************
 * File:  ContactAlertExtension.cls
 * Date:  October 1st, 2009
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
public class ContactAlertExtension
{
    public ContactAlertExtension(ApexPages.StandardController stdController)
    {
        Id contactId  = stdController.getId();
        contact = [select id, name, Contact_Alert__c, accountid, account.alert_text__c, account.Support_Hold__c from contact where id =: contactId limit 1];
    }
    
    private Contact  contact;
    public Contact getContact(){return contact;}
        
    /*public boolean getShouldShowContactAlert()
    {
        if (contact.Contact_Alert__c != null)
        {
            return true;
        }
        else
        {
            return false;
        }
    }*/
    public boolean shouldShowAccountAlert
    {
        get
        {
            //  we show the account alert if 1. alert text has value 2. alert text has no value but support hold is set
           if (contact.AccountId != null)
           {
               if (!util.isBlank(contact.Account.Alert_Text__c) || contact.account.support_hold__c)
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
               return false;
           }
           
        }
    }
    public string accountAlert
    {
        get
        {
            //  if the account is support hold and/or it has value in the alert text
            if (shouldShowAccountAlert)
            {
                if (contact.Account.alert_text__c == null || contact.Account.alert_text__c.length() == 0)
                {
                    return AccountAlertExtension.CUST_ON_SUPPORT_HOLD;
                }
                else
                {
                    return AccountAlertExtension.createFormattedAlertText(contact.AccountId);
                }
            }
            return null;
        }
    }


}