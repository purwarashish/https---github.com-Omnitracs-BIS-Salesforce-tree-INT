/*******************************************************************************
 * File:  ChangeAccountOwnerExtension.cls
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
public with sharing class ChangeAccountOwnerExtension 
{
    public ChangeAccountOwnerExtension(ApexPages.StandardController stdController)
    {
        notifyNewOwner = true;
        shouldTransferOpenOpptsNotOwnedByAccountOwner = false;
        shouldTransferClosedOppts = false;
        shouldTransferOpenCases = false;
        shouldTransferClosedCases = false;
        
        Account = [select id, ownerid, name from Account where id =: stdController.getId()];
        previousOwnerId = account.ownerId;
        Account.ownerId = null;//  swipe it out so the user has to pick a new owner
    }
    public Account Account{get;set;}
    public boolean notifyNewOwner{get;set;}
    public string ownerChangeEmailComments{get;set;}
    public boolean shouldTransferOpenOpptsNotOwnedByAccountOwner{get;set;}
    public boolean shouldTransferClosedOppts{get;set;}
    public boolean shouldTransferOpenCases{get;set;}
    public boolean shouldTransferClosedCases{get;set;}
    
    private id previousOwnerId;
    public PageReference changeOwner()
    {
        if (Account.OwnerId == null)
        {
            Account.OwnerId.AddError('You need to specify a new owner for this Account.');
            return null;
        }
        //  so lets' go ahead and make the Account update
        update Account;
        
        //  ok so here is the extra logic comes into play, if the other checkbox are set on the page, we need to perfrom those actions
        //  we'll wrap it in a try so that if it doesnt work we throw exception
        try
        {
            if (shouldTransferOpenOpptsNotOwnedByAccountOwner)
            {
                transferOpenOpptsNotOwnedByAccountOwner();
            }
            if (shouldTransferClosedOppts)
            {
                transferClosedOppts();
            }
            if (shouldTransferOpenCases)
            {
                transferOpenCases();
            }
            if(shouldTransferClosedCases)
            {
                transferClosedCases();
            }
        }
        catch(Exception e)
        {
            account.addError(e.getMessage());
            return null;
        }
        if (notifyNewOwner)
        {
            User newOwnerOfAccount = [select id, email from User where id =: Account.ownerId];
            list<string> toEmail = new List<string>();
            toEmail.add(newOwnerOfAccount.email);
            
            list<string> ccEmail = new List<string>();
            ccEmail.add(userinfo.getUserEmail());
            /*
            
            Account Mr. Joe Hutch has been assigned to you. Please click on the link below to view the record.
            */
            string subject = 'Account: ' + Account.name + ' has been transferred to you.';
            string htmlBody = 'Account ' + Account.name + ' has been assigned to you.<br /><br />' +
                (ownerChangeEmailComments == null ? '' : ownerChangeEmailComments + '<br /><br />')  +
                'Please click on the link below to view the record.<br />' +
                EmailClassRoadnet.createHyperLink(Util.base_url + Account.Id, Util.Base_url + Account.Id);
            
            EmailClassRoadnet.sendEmailAsync(toEmail, ccEmail, null, subject, htmlbody, htmlbody, null);

        }
        
        PageReference pr = new PageReference('/' + Account.id);
        pr.setRedirect(true);
        return pr;
    }
    private void transferOpenOpptsNotOwnedByAccountOwner()
    {
        //  so the logic here is to query all opportunies that point to the account AND are open AND not owned by the existing owner
        //  and change the owner to the new owner
        List<OpportunityStage> openStages = 
            [Select o.MasterLabel, o.IsWon, o.IsClosed, o.IsActive, o.Id, o.Description, o.DefaultProbability From OpportunityStage o where 
            isActive = true and isClosed = false];
        
        string queryString = 'select id, ownerid, stagename from opportunity where AccountId = \'' + account.id + 
            '\' and OwnerId != \'' + previousOwnerId + '\' and ';
        if (openStages.size() == 1)
        {
            queryString += ' StageName = \'' + openStages[0].MasterLabel + '\'';
        }
        else
        {
            queryString += ' (';
            for (integer i = 0; i < openStages.size(); i++)
            {
                if (i == 0)
                {
                    queryString += ' StageName = \'' + openStages[i].MasterLabel + '\'';
                }
                else
                {
                    queryString += ' OR StageName = \'' + openStages[i].MasterLabel + '\'';
                }
            }
            queryString += ')';
        }
    
        List<Opportunity> openOpptsNotOwnedByCurrentOwner = dataBase.query(queryString);
        
        //util.breakpoint('num of oppts queried  ' + openOpptsNotOwnedByCurrentOwner.size() + 
        //' and the owner id that will be assigned to the opppts = ' + account.ownerId);
        
        //  now assign the new account owner to the oppts
        for (Opportunity singleOppt : openOpptsNotOwnedByCurrentOwner)
        {
            singleOppt.OwnerId = account.ownerId;
        }
        
        update openOpptsNotOwnedByCurrentOwner;
    }
    
    private void transferClosedOppts()
    {
        //  should be easier logic than the method up above,
        //  query all the oppts stagenames which are closed (or iswon)
        //  and then dynamic query the oppts
        //  and assign the owner id
        List<OpportunityStage> closedStages = 
            [Select o.MasterLabel, o.IsWon, o.IsClosed, o.IsActive, o.Id, o.Description, o.DefaultProbability From OpportunityStage o where 
            isActive = true and isClosed = true];
        
        //  dont need to query oppts that the new owner already owns
        string queryString = 'select id, ownerid, stagename from opportunity where AccountId = \'' + account.id + 
            '\' and OwnerId != \'' + previousOwnerId + '\' AND ';
        
        if (closedStages.size() == 1)
        {
            queryString += ' StageName = \'' + closedStages[0].MasterLabel + '\'';
        }
        else
        {
            queryString += ' (';
            for (integer i = 0; i < closedStages.size(); i++)
            {
                if (i == 0)
                {
                    queryString += ' StageName = \'' + closedStages[i].MasterLabel + '\'';
                }
                else
                {
                    queryString += ' OR StageName = \'' + closedStages[i].MasterLabel + '\'';
                }
            }
            queryString += ')';
        }
        
        
        
        List<Opportunity> closedOpptsOfAccount = database.query(queryString);
        
        for (opportunity singleOppt : closedOpptsOfAccount)
        {
            singleOppt.ownerid = account.ownerid;
        }
        update closedOpptsOfAccount;
    }
    
    private void transferOpenCases()
    {
        //  simple query here dont need to dynamic it
        //  get all cases that point to the account, owned by the previous owner and status != closed
        Case[] openCases;
        try
        {
            openCases = [select id, ownerid, status from Case where accountid =: account.id and ownerid =: previousOwnerId and status != 'Closed'];
        }
        catch(QueryException qe)
        {
            return;//  no cases matched criteria    
        }
        
        //util.breakpoint('num cases returned = ' + openCases.size());
        for (Case c : openCases)
        {
            c.ownerid = account.ownerid;
        }
        update openCases;
        
    }
    
    private void transferClosedCases()
    {
        //  so the logic here is a little bit more difficult then i would like to admit,
        //  currently the csae trigger contains logic to prevent closed csaes from having their ownership change
        //  i can have the trigger ignore this if i have checkbox named "Is Account Owner Changing".  only this code
        //  will be able to set it.  if the account owner changing checkbox is being set, then the case woener logic on the csae trigger sould be ignored
        
        //  get all cases that point to the account, owned by the previous owner and status != closed
        Case[] closedCases;
        try
        {
            closedCases = [select id, ownerid, status from Case where 
                accountid =: account.id and ownerid =: previousOwnerId and status = 'Closed'];
            
        }
        catch(QueryException qe)
        {
            return;//  no cases matched criteria    
        }
        
        //util.breakpoint('num queried = ' + closedCases.size());
        for (Case c : closedCases)
        {
            c.ownerid = account.ownerid;
            //c.Is_Account_Owner_Changing__c = true;
        }
        update closedCases;
        
        //  now once we change the owner of the closed cases, we need to back and turn the bool "is account owner changing" off
        //  so that future owner changes are still blocked
        for (Case c : closedCases)
        {
            //c.Is_Account_Owner_Changing__c = false;
        }
        
        update closedCases;
    }
    public static ApexPages.StandardController generateController(Account l)
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