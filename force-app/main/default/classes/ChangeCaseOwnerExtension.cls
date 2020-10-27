/*******************************************************************************
 * File:  ChangeCaseOwnerExtension.Page
 * Date:  July 29th, 2011
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
public class ChangeCaseOwnerExtension
{
    public ChangeCaseOwnerExtension(ApexPages.StandardController stdController)
    {
        theCase = [select id, ownerId, CaseNumber, Recordtype.name from Case where id =: stdController.getId()];
        originalCaseOwner = theCase.Ownerid;
        notifyOwner = true;
        isSelectingQueue = false;
        supportOrAll = 'Customer Support';
        queueOrUser = 'User';
        notifyNewOwner = true;//  set this to true by default
        businessUnit = [SELECT Business_Unit__c FROM User WHERE Id =: UserInfo.getUserId() LIMIT 1].Business_Unit__c;
        
    }
    
    public Case theCase{get;set;}
    public string ownerId{get;set;}
    public string queueId{get;set;}
    public boolean isSelectingQueue{get;set;}
    public string queueOrUser{get; set;}
    public boolean notifyOwner{get;set;}
    public string supportOrAll{get; set;}
    public boolean notifyNewOwner{get; set;}
    public string emailComments{get; set;}
    public string businessUnit {get; set;}
    public List<QueueSobject> caseQueues
    {
        get
        {
            
            if (caseQueues == null)
            {
                caseQueues = [select id, queueid, queue.name from QueueSobject where sobjecttype = 'Case' ];//  needed by isOwnerQueue method
            }
            return caseQueues;
        }
        set;
    }
    
    private string originalCaseOwner;
    
    
    /*private boolean isCaseSupport
    {
        get
        {
            if (theCase == null)
            {
                return false;
            }
            else
            {
                return (theCase.REcordtype.name == 'Support');
            }
        }
    }*/
        
    public List<SelectOption> userPickList
    {
        get
        {
            List<SelectOption> options = new List<SelectOption>();
            if (supportOrAll == 'Customer Support')
            {
                User[] supportUsers = 
                 [select id, email, name from User where (profile.name like '%Customer%' or profile.name like '%Support%' or profile.Name like '%CS%' or profile.Name = 'Sylectus Profile' or profile.Name = 'CNR Sales Profile') and isactive = true and ContactId = null and Business_Unit__c =: businessUnit order by lastname asc];
                for (User u : supportUsers)
                {
                    options.add(new selectoption(u.id, u.name));    
                }
                
            }
            else
            {
                User[] allUsers = [select id, email, name from User where isactive = true and ContactId = null and Business_Unit__c =: businessUnit order by lastname asc];
                for (User u : allUsers)
                {
                    options.add(new selectoption(u.id, u.name));
                }
            }
            return options;
        }
    }
    
    public List<SelectOption> queuePickList
    {
        get
        {
            //QueueSobject[] queues = [select queueid, queue.name from QueueSobject where sobjecttype = 'Case' and
            //  (queue.name = 'Enhancements' or queue.name = 'PD' or queue.name = 'Primary Support' or queue.name = 'RNA PD' or 
            //  queue.name = 'Strategic Support' or queue.name = 'INTL Maps' or queue.name = 'Professional Services' or queue.name = 'Telematics')
            //order by queue.name];
            QueueSobject[] queues;
            
            if (businessUnit == 'Roadnet') {
               // queues = [select queueid, queue.name from QueueSobject where sobjecttype = 'Case' AND Queue.Name LIKE 'Roadnet%' order by queue.name];
                  Set<String> Queuenamematches = new Set<String> { 'Roadnet%', 'RN%', 'OT1%' };
                  queues = [select queueid, queue.name from QueueSobject where sobjecttype = 'Case' AND Queue.Name LIKE :Queuenamematches order by queue.name];
            }
            else if (businessUnit == 'Sylectus') {
                queues = [select queueid, queue.name from QueueSobject where sobjecttype = 'Case' AND Queue.Name LIKE 'Sylectus%' order by queue.name];
            }
            else if (businessUnit == 'Omnitracs MX') {
                queues = [select queueid, queue.name from QueueSobject where sobjecttype = 'Case' AND Queue.Name LIKE 'CNR%' order by queue.name];
            }
            else {
                queues = [select queueid, queue.name from QueueSobject where sobjecttype = 'Case' AND Queue.Name LIKE 'FRA%' order by queue.name];
            }
            
            List<SelectOption> options = new List<SelectOption>();
            
            for (QueueSobject q : queues)
            {
              options.add(new selectoption(q.queueid, q.queue.name));
              //options.add(new selectoption('blarg', 'blarg'));    
            }
            
            return options;
        }
    }    
    public PageReference radioButtonOnchange()
    {
        if (queueOrUser == 'User')
        {
           isSelectingQueue = false;    
        }
        else
        {
            isSelectingQueue = true;
        }
        
        return null;    
    }
    
    public PageReference changeOwner()
    {
        Database.DMLOptions dmo = new Database.DMLOptions(); 
        
        if (isSelectingQueue)
        {
            theCase.ownerId = queueId;
        }
        else
        {
            theCase.Send_New_Owner_Email__c = notifyNewOwner;
            theCase.Send_New_Owner_Comments__c = emailComments;
            theCase.OwnerId = ownerId;
        }
        
        try {
            update theCase;
        }
        catch (Exception e) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Could not update the Case. Please return to the Case and ensure all required fields have been entered.'));
            return null;
        }
        
        //  zach has asked to create an internal case event when the case owner changes with comments from the screen
        if (!Util.isBlank(emailComments))
        {
            Case_Event__c ce = new Case_Event__c();
            ce.Case__c = theCase.id;
            ce.Display_in_Customer_Portal__c = false;
            ce.Communication_Type__c = 'Internal';
            //  the problem is that the new/old owner can be a user or a queue, and trying to get the name of the queue is different
            //  then trying to get the name of the user.  i'm wondering if it's even needed to know who the owner was changed from/to
            //  but i can see later down the line that feature being asked for so me let me figure this out now :-p
            string oldOwnerName = findNameOfCaseOwner(originalCaseOwner);
            string newOwnerName = findNameOfCaseOwner(theCase.OwnerId);
            
            ce.Subject__c = 'Case Owner Changed from ' + oldOwnerName + ' to ' + newOwnerName;
            ce.Details__c   = 'Owner Change Comments: ' + emailComments;
            insert ce;
            
        }
        
        PageReference pr = new PageReference('/' + theCase.id);
        pr.setRedirect(true);
        return pr;
    }
    
    /*public void sendEmailToOwner()
    {
        if (ownerid != null)
        {
            //string userEmail = [select email from user where id =: ownerId].email;
            //system.assert(userEmail != null);
            
            string subject = 'Case ' + theCase.casenumber + ' has been assigned to you.';
            //string htmlBody = 'Link to the case: ' + EmailClass.createHyperLink('https://na1.salesforce.com/' + theCase.id, theCase.CaseNumber) +
            //   '<br /><br />' + (emailComments == null ? '' : emailComments);
            
            //List<string> toEmail = new List<string>();
            //toEmail.add(userEmail);
            list<Id> oneElementList = new List<ID>();
            oneElementList.add(ownerId);
            //EmailClass.sendEmailInternalUsersAsync(
               // oneElementList, 
               // subject, 
               // emailclass.convertTextToHtml(htmlbody), 
               // emailclass.convertTextToHtml(htmlbody), 
               // Util.FromAddressForCases);
        
        //}
    }*/
    //  did not make this a staaic method as it needs the local caseQueues to avoid having nto query it each time this method is called
    public string findNameOfCaseOwner(id caseOwnerId)
    {
        
        //  so the id that is passed in here is going to be either a user id or a queue id.
        //  we can figure out which it is by scroolling thru all queues seeing if 
        //  there is match, if it is not, we assume its a user as it can be nothing else :-p
        if (isOwnerQueue(caseOwnerId, caseQueues))
        {
            //  so the owner is a queue, need to get the queue name formthe list of case queues
            string queueName = 'Unknown Queue';
            for (QueueSobject singleQueue : caseQueues)
            {
                if (singleQueue.queueid == caseOwnerId)
                {
                    queueName = singleQueue.Queue.Name;
                }
            }
            return queueName;//  in case a queue was not found, it will return Unkknown Queue
        }
        else //  its a user, query their name and return
        {
            User tempUser;
            try
            {
                tempUser = [select id, name from User where id =: caseOwnerId];
                return tempUser.Name;
            }
            catch(Exception e)
            {
                //  just in case something hjappens that im not aware of
                return 'Unknown UserName';
            }
        }
        
    }
    private static boolean isOwnerQueue(id userId, List<QueueSobject> queues)
    {
        for (QueueSobject q : queues)
        {
            //  the history table for cases, when an owner changes, creates two hisotry records.  one contains the name of the users/queue that was changed
            //  fornuately, the queues do not have a name to check agaisnt so i'll ahve to look at the queueid
            
            if (q.QueueId == userId)
            {
                return true;
            }
        }
        return false;
    }
    public static ApexPages.StandardController generateController(Case theCase )
    {
        pagereference pageRef=new pagereference('Page.CaseEventExtension');
        test.setcurrentpage(pageRef);
        
        return new ApexPages.standardController(theCase);
    }    

}