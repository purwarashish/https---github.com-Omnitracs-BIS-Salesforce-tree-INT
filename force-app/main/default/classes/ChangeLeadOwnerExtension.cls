/*******************************************************************************
 * File:  ChangeLeadOwnerExtension.cls
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
public with sharing class ChangeLeadOwnerExtension 
{
    public Lead lead{get;set;}
    public boolean notifyNewOwner{get;set;}
    public string emailComments{get;set;}
    private List<ID> lstUserID = new list<ID>();
    
    public ChangeLeadOwnerExtension(ApexPages.StandardController stdController)
    {
        notifyNewOwner = true;
        lead = [select id, ownerid, name, company from Lead where id =: stdController.getId()];
        System.debug('lead details::'+lead);
        lead.ownerId = null;//  swipe it out so the user has to pick a new owner
        //  swipe this too, otherwise if the owner was changed already this would be prepooped with the old comment
        emailcomments = '';
    }
    
    
    public PageReference changeOwner()
    {
        
        if (lead.OwnerId == null)
        {
            lead.OwnerId.AddError('You need to specify a new owner for this lead.');
            return null;           
        }
        try{
            //  so lets' go ahead and make the lead update
            System.debug('lead.OwnerId::'+lead.OwnerId);
            update lead;
        }catch(Exception e){
            System.debug('Unable to Update Lead Owner, Error occured in ChangeLeadOwnerExtension class due to :: '+e.getMessage());
            lead.OwnerId.AddError('Insufficient privilage.');
        }
       
        if (notifyNewOwner)
        {   
            List<User> newOwnerOfLead ;
            List<Id> allUsersId = new List<Id>();
            list<string> toEmail = new List<string>();
            list<string> ccEmail = new List<string>();
            
            String s = String.valueOf(lead.ownerId).substring(0,3);
            System.debug('@@st'+s);
            System.debug('@@lead.ownerId'+lead.ownerId);
            if(s.equals('005'))
            {
                 allUsersId.add(lead.ownerId);                           
            } 
            else if(s.equals('00G'))
            {
                 allUsersId = getAllQueueMembers(lead.ownerId);
            }
            
            if(allUsersId.size() == 0)
            {
                return null;
            }
            
            newOwnerOfLead = [select id, email from User where id in: allUsersId];
                                
            for(User lstUser : newOwnerOfLead )
            {
                toEmail.add(lstUser.email);
            }
           
            System.debug('@@toEmail'+toEmail.size());
                        System.debug('@@toEmail'+toEmail);
            ccEmail.add(userinfo.getUserEmail());
            
            string subject = 'Lead: ' + lead.name + ' has been assigned to you.';
            string htmlBody = 'Lead: ' + lead.name + ', ' + lead.company +  ' has been assigned to you.<br /><br />' +
                (emailComments == null ? '' : emailComments + '<br /><br />') +
                'To view the details of this lead in salesforce.com click on the following link: <br />' +
                EmailClassRoadnet.createHyperLink(Util.base_url + lead.Id, Util.Base_url + lead.Id);
            
            EmailClassRoadnet.sendEmailAsync(toEmail, ccEmail, null, subject, htmlbody, htmlbody, null);

       
         }
        PageReference pr = new PageReference('/' + lead.id);
        pr.setRedirect(true);
        return pr;
    }
    
    private List<Id> getAllQueueMembers(Id grpId)
    {
        List<GroupMember> newOwnerGroupMember =  [Select UserOrGroupId  From GroupMember where GroupId =: grpId];
        System.debug('@@newOwnerGroupMember '+newOwnerGroupMember);
                     
        for(GroupMember gm : newOwnerGroupMember)
        {
            String st = String.valueOf(gm.UserOrGroupId).substring(0,3);
            if(st.equals('005'))
            {
                lstUserID.add(gm.UserOrGroupId);
            }
            else
            {
                getAllQueueMembers(gm.UserOrGroupId);
            }
        }
        return lstUserID;
    }
    
    public static ApexPages.StandardController generateController(Lead l)
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