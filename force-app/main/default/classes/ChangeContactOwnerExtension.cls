/*******************************************************************************
 * File:  ChangeContactOwnerExtension.cls
 * Date:  June 21, 2013
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
public with sharing class ChangeContactOwnerExtension 
{
    public ChangeContactOwnerExtension(ApexPages.StandardController stdController)
    {
        notifyNewOwner = true;
        Contact = [select id, ownerid, name from Contact where id =: stdController.getId()];
        Contact.ownerId = null;//  swipe it out so the user has to pick a new owner
    }
    public Contact Contact{get;set;}
    public boolean notifyNewOwner{get;set;}
    public string ownerChangeEmailComments{get;set;}
    
    public PageReference changeOwner()
    {
        if (Contact.OwnerId == null)
        {
            Contact.OwnerId.AddError('You need to specify a new owner for this Contact.');
            return null;
        }
        //  so lets' go ahead and make the Contact update
        update Contact;
        
        if (notifyNewOwner)
        {
            User newOwnerOfContact = [select id, email from User where id =: Contact.ownerId];
            list<string> toEmail = new List<string>();
            toEmail.add(newOwnerOfContact.email);
            
            list<string> ccEmail = new List<string>();
            ccEmail.add(userinfo.getUserEmail());
            /*
            
            Contact Mr. Joe Hutch has been assigned to you. Please click on the link below to view the record.
            */
            string subject = 'Contact: ' + contact.name + ' has been transferred to you.';
            string htmlBody = 'Contact ' + contact.name + ' has been assigned to you.<br /><br />' +
                (ownerChangeEmailComments == null ? '' : ownerChangeEmailComments + '<br /><br />')  +
                'Please click on the link below to view the record.<br />' +
                EmailClassRoadnet.createHyperLink(Util.base_url + contact.Id, Util.Base_url + Contact.Id);
            
            EmailClassRoadnet.sendEmailAsync(toEmail, ccEmail, null, subject, htmlbody, htmlbody, null);

        }
        
        PageReference pr = new PageReference('/' + Contact.id);
        pr.setRedirect(true);
        return pr;
    }
    
    public static ApexPages.StandardController generateController(Contact l)
    {
        pagereference pageRef=new pagereference('Page.LineItemMasterExtension');
        test.setcurrentpage(pageRef);
        
        if (l.id != null)
        {
            ApexPages.currentPage().getParameters().put('id', l.id);
        }       
        return new ApexPages.standardController(l);
    }

}