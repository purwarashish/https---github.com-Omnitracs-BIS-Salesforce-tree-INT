/*******************************************************************************
 * File:  UpgradeOpportunityExtension.cls
 * Date:  March 15th, 2013
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
public class UpgradeOpportunityExtension
{
    
    private string roadnet_product_field_id;
    private string tier_product_field_id;
    private string case_field_Id;
    private string case_name_Id;
    private string opportunity_location_field_Id;
     
    private string ORDER_TYPE_FIELD_ID;
    private string OPPT_TYPE_FIELD_ID;
    private string OPPT_NAME_FIELD_ID;
    private string OPPT_CLOSED_DATE_FIELD_ID;
    private string OPPT_STAGE_FIELD_ID;
    private string COMPETITOR_1_FIELD_ID;
    private string COMPETITOR_1_NAME_ID;
    private string PRIMARY_CONTACT_ROLE_FIELD_ID;
    private string PRIMARY_CONTACT_ROLE_NAME_ID;
    private string ROLE_FIELD_ID;
    
    public UpgradeOpportunityExtension(apexpages.standardcontroller stdcontroller)
    {
        //  BE ADVISED THAT THIS HAS THE SAME LOGIC AS CONVERT OPPT TO CASE, ACTUALLY THE BUTTON WILL BE NAMED CONVERT CASE TO OPPT
        theCase = [select id,lastmodifiedby.name, ownerid, casenumber, status, subject, description, recordtype.name,
          contactId, contact.name,
            accountid, product_pl__c, account.name, account.ownerid, account.owner.email, tier__c, 
            account.recordtypeid, account.recordtype.name,  Asset__r.Product__c, Asset__r.Product__r.name,  Asset__c, 
            createdbyid, createdby.name, createdby.email
            
           
            from case where id =: stdController.getId()];
        //  so we got the intro page, do we need the checkIfoneAlready there?  yes the check can remain, the only thing that needs to change
        //  here is if the person is pro serv, they should be redirected to an oppt new page, if they are support
        //  the oppt is auto created for them
        setOpptPrepopFields();
        try
        {
            opptRecTypeSelection = [select id  from RecordType where sobjecttype = 'Opportunity' and name = 'Services Only'].id;
        }
        catch(Exception e)
        {
        }
        //util.breakpoint(opptRecTypeSelection);
                
    }
    public case thecase{get;set;}
    public string returnURl
    {
        get
        {
            return util.BASE_URL + theCase.id;
        }
        
    }
    public boolean isUserSupport
    {
        get
        {
            //  not sure how to figure this out, 
            //  so just going to hard code it for now
            
            Profile userProfile  = [select id, name from Profile where id =: userInfo.getProfileId()];
            return userProfile.name.contains('CS') || userProfile.name.contains('Support');
        }
    }
    public string createUpgradeOpptButtonLabel
    {
        get
        {
            if (theCase.RecordType.Name != null)
            {
                if (theCase.RecordType.Name == 'Professional Services')
                {
                    return 'Create Opportunity';
                }
                else
                {
                    return 'Create Upgrade Opportunity';
                }
            }
            else
            {
                return 'Create Upgrade Opportunity';
            }
        }
    }
    public PageReference checkIfOneAlreadyCreated()
    {
        //   query for any upgrade oppts that already point to this case
        integer num = [select count() from Opportunity where Case__c =: theCase.id ];
        if (num > 0)
        {
            PageReference pr = Page.CaseInfoMessagePage;
            pr.setRedirect(true);
            pr.getparameters().put('enum', '21');
            pr.getParameters().put('retURL' , returnUrl);
            return pr;
            //throw new myException('A upgrade opportunity has already been created for this case.  Press back to re');
        }
        return null;
    }
    public PageReference createUpgradeOppt()
    {
        //  so the new logic here is if the person is a support rep, the oppt is auto created
        //  and if not the oppt is prepopulated
        if (isUserSupport && 
            (opptRecTypeSelection == null || opptRecTypeSelection.length() == 0 || opptRecTypeSelection == pl.none))
        {
            theCase.AddError('You must select a oppt recordtype');
            return null;
        }
        //  we only close the case if it is a support/non pro serve case
        if (theCase.RecordType.Name != 'Professional Services')
        {
            
            //  per case no.02052960- kufre has asked if the case is no longer auto closed
            //thecase.Status = 'Closed';
        }
        theCase.Is_Case_Being_Upgraded__c = true;//  this checkbox tells the survey code in the case trigger to not send surveys to this case
        theCase.Work_Effort_IN_minutes__c = 5;
        
        /*  
        //  create case time of just 5 minutes if the case owner is not a queue
        if (!CaseEventExtension.isOwnerQueue(theCase.OwnerId))
        {
            Mibos_Case_Time__c caseTimeForUpgrade = new Mibos_Case_Time__c();
            caseTimeForUpgrade.Case__c = theCase.id;
            caseTimeForUpgrade.Work_Effort__c = 5;
            caseTimeForUpgrade.Owner__c = theCase.OwnerId;
            insert caseTimeForUpgrade;
        } 
        */      
        //  there is an issue where with upgrade cases there are not edited after they are created and this causees the 
        //  total work effort to not be calcuatled (since the first case time is created after the case is created)
        //  to fix this, we'll perform a query of all case times that would belong to teh case and update the work effort
        //theCase.Total_Work_Effort__c = CaseClassHelperClass.findCaseTimeTotal(theCase.Id);
        database.saveResult ur = database.update(theCase);
        
        if (!ur.isSuccess())
        {
            throw new myException('failed to update case status to closed: ' + ur.getErrors()[0]);
        }
        
        if (isUserSupport)
        {
            return autoCreateOpprotunity();
        }
        else
        {
            return redirectToPrePoppedOpptScreen();
        }
        
    }
    
    public PageReference autoCreateOpprotunity()
    {
        User tinaUserRecord = getTinaUserRecord;
        User brianUserRecord = getBrianCallahanUserRecord;
        
        //  so after we confirm the user wants to create an oppt, just create the oppt, map fields, close case, redirect to the oppt or the case
        Opportunity o = new Opportunity();
        //  we DO NOT HAVE oppt recordtypes set yet, so this is just going to grap whatever recordtype first comes up
        o.recordtypeid = opptRecTypeSelection;
        
        //  per case no.02052960, kufre states that brian is the owner of the oppt, sent email to brian, he doesnt know why
        //  he is being assigned the owner.  i believe the reason this is happening is due to case.account.ownerid is brian and he is inadverdnetaly being
        //  set as the owner of the oppt, going to comment this line out (and will ask john if this is ok) so that the oppt owner is the case creator/owner
        if (theCase.Account.OwnerId != null)
        {
            if (brianUserRecord != null && theCase.Account.OwnerId == brianUserRecord.id)
            {
                o.ownerId = theCase.OwnerId;// if brian is the account owner, which 9/10 times he will be, the case owner will be the owner of the oppt 
            }
            else
            {   
                o.ownerid = theCase.Account.Ownerid;
            }
        }
        else 
        {        
            o.ownerid = theCase.Account.Ownerid;
        }           
        o.accountid = theCase.accountid;
        o.name = createOpptName();
        if (Util.isRnEnvironment)
        {
            o.Name += ' - ';            
        }
        o.Case__c = theCase.id;
     // o.Flat_Rate_database_work__c = 1125;
        o.stagename = 'Negotiate';
        o.closeDate = date.today().addDays(60);//  oppt create date + 60 days
        o.description = theCase.description;
        o.tier__c = theCase.Tier__c;
     // o.Solution__c = queryProductDescription(theCase.Asset__r.Product__c);
    //  o.Lead_Administrator__c = 'Customer Service';
        o.LeadSource = 'Customer Service';
        o.Lead_Origin__c = 'Roandet - Customer Service';
        o.Order_Type__c  = 'New';
     // o.opportunity_loc__c = 'Domestic';  //  i think its safe to set this as domestic for support calls
        o.Type = 'Existing Customer';
        o.Competitor_1__c = retrieveNoneComeptitorRecord.id;
        o.Primary_Contact__c = theCase.ContactId;
        o.Role__c = 'Sponsor';//  not sure what to default this to so it will be end user
        Database.saveResult sr = database.insert(o);
        
        
        if (!sr.isSuccess())
        {
            throw new myException('Could not create opportunity: ' + sr.getErrors()[0]);
        }
        //  for some reason, the oppt after trigger is not being fired here, i was hoping it would create the primary contact
        // for the oppt but that is not happening soe  whave to manually create the contact role here
        createContactRoleAutoCreatedOppt(o);
        
        //  now we need to close the case (any validation to occur here?) i know the vf page checks for sub reason/case reason and make sure an old
        //  case reason is being used.  i'm thinking that if the case was saved already, the validation has succeded alrady, so just let the case trigger code run if needed
        //  there is the qustion of what happens with the surveys (ive asked john about this)

        //  send email to the account owner, the case creator and Tina Duncan per case #01746896
        
         List<string> toEmail = new List<string>();
         if (thecase.Account.Owner.email != null)
         {
            toEmail.add(theCase.Account.Owner.Email);
         }
         
        
        List<string> ccEmail = new List<String>();
        
        if (theCase.CreatedBy.Email != null)
        {
            ccEmail.add(theCase.CreatedBy.Email);
        }
        if (tinaUserRecord != null)
        {
            ccEmail.add(tinaUserRecord.Email);
        }
            
        if (toEmail.size() > 0)
        {
           
            string subject = 'A new Software Upgrade Opportunity has been created by  ' + theCase.LastMOdifiedby.name  + ' for case# ' + theCase.CaseNumber;
            string linkToOppt = EmailClassRoadnet.createHyperLink(util.LIVE_URL + sr.getid(), o.name);
            string linkToCase = EmailClassRoadnet.createHyperLink(util.LIVE_URL + thecase.id, theCase.CaseNUmber);
            string body = 'A new Software Upgrade Opportunity has been created by ' + theCase.LastMOdifiedby.name + ' for case # '+ linkToCase + '<br /><br />'  +
                linkToOppt + '<br />' +
                'Account: ' + theCase.Account.name + '<br />' +
                'Subject: ' + theCase.subject + '<br />' +
                'Description: ' + theCase.Description;
            
            emailClassRoadnet.sendEmailAsync(toEmail, ccEmail, null, subject, body, body, null);
        }
        util.debug('case recordtype name = ' + theCase.RecordType.name);
        
        if (theCase.RecordType.Name == 'Call Center')
        {
            //  per case no.02052960- kufre has asked if the case is no longer auto closed
            //theCase.Status = 'Closed';
            //update thecase;           
            //  per case no 01796594, this behvaior is no longer needed and we want the call center case just be closed
            //  have to check if the case owner is a queue or the case cannot be set to closd
            /*
            id roadnetProServeQueueId = findProServeQueueId();
            util.debug('roadnetProServeQueueId = ' + roadnetProServeQueueId);
            if (roadnetProServeQueueId != null)
            {
                //  if the case is call center, the case should be assigned to the pro serve case queue
                theCase.OwnerId = roadnetProServeQueueId;
                update theCase;
            }
*/
        
        }
        
        PageReference pr = new PageReference('/' + theCase.id);
        if ( pr != null) {
            pr.setredirect(true);
            return pr;
        } 
        
        return null;
        
    }

    public PageReference redirectToPrePoppedOpptScreen()
    {
        //  this was copy pasted from the OpptFromCase
        string opptLocation = 'Domestic';//  be default, since the oppt's oppt locaiton is required
        
        if (theCase.AccountId != null && theCase.account.recordtypeid != null && theCase.account.recordtype.name != null)
        {
            if (theCase.Account.Recordtype.name.Contains('Intl') || theCase.Account.Recordtype.name.Contains('International'))
            {
                opptLocation = 'International';
            }
        }
           
        string productDescription;
        if (Util.isRnEnvironment)
        {
            id tempProdId;
            try 
            {
                tempProdId = [select id from Product2 where name =: theCase.Product_Pl__c].id;
                productDescription = queryProductDescription(tempProdId);
                
            }
            catch(Exception e)
            {
                productDescription = null;
            }
        }
        else
        {
            productDescription = queryProductDescription(theCase.Asset__r.Product__c);
        }
        
           
        //opptRecTypeSelection = [select id from RecordType where sobjecttype = 'Opportunity' and name = 'Products, Services and Maintenance'].id;
        string caseNUmber = theCase.CaseNumber;     
        
        
        string url = 
           '/setup/ui/recordtypeselect.jsp?ent=Opportunity&retURL=%2F006%2Fo&' + 
           'save_new_url=%2F006%2Fe%3FretURL%3D%252F006%252Fo&accid=' + theCase.accountid +
           '&' + ROADNET_PRODUCT_FIELD_ID + '=' + productDescription +
           '&' + TIER_PRODUCT_FIELD_ID + '=' + theCase.Tier__c +
           '&' + CASE_FIELD_ID + '=' + theCase.id +
           '&' + OPPORTUNITY_LOCATION_FIELD_ID + '=' + opptLocation +
           '&' + ORDER_TYPE_FIELD_ID + '=' + 'New Services' +
           '&' + OPPT_TYPE_FIELD_ID + '=' + 'Existing Business' +
           '&' + OPPT_NAME_FIELD_ID + '=' + createOpptName() +
           //'&' + OPPT_CLOSED_DATE_FIELD_ID + '=' + DATE.TODAY().ADDDAYS(60) +
           '&' + OPPT_STAGE_FIELD_ID + '=' + 'Sales Acceptance' + 
           '&' + CASE_NAME_ID + '=' + caseNUmber +
           '&' + PRIMARY_CONTACT_ROLE_FIELD_ID + '=' + theCase.ContactId +
           '&' +  PRIMARY_CONTACT_ROLE_NAME_ID + '=' + theCase.Contact.Name +
           '&' + ROLE_FIELD_ID + '=' + 'Sponsor';//  it will always default to Sponsor
           
        //  this will add the compoetitror argument to the url   
        Competitor__c noneCompetitor = retrieveNoneComeptitorRecord;
        if (noneCompetitor != null)
        {
            
            url += '&' + COMPETITOR_1_FIELD_ID + '=' + noneCompetitor.id +
                '&' + COMPETITOR_1_NAME_ID + '=' + noneCompetitor.name;
        }   
         
        util.debug('url user is being redirected to: ' + url);  
        PageReference pr = new PageReference(url);
        pr.setredirect(true);
        return pr;
    }
    
    public string opptRecTypeSelection{get;set;}
    
    public List<SelectOption> opptrecTypesPickist
    {
        get
        {
            list<selectoptiON> options = new List<SelectOption>();
            List<Recordtype> opptRecTypes = [select id, name from RecordType where sobjecttype = 'Opportunity'];
            for (Recordtype rt : opptRecTypes)
            {
                options.Add(new SelectOption(rt.id, rt.name));
            }
            return options;
        }
    }
    

    @TestVisible private void setOpptPrepopFields()
    {
        util.debug('util.isRnEvnrioment: ' + util.isRnEnvironment);
        //  so we have two envirnoments, mibos, roadnet
        //  we already know the fields for the rn produciton/sandbox, we justneed them for the mibos environment
        if (Util.isRnEnvironment)
        {
            //  ids grabbed by going to the custom fields page listing and getting id from url
            roadnet_product_field_id = '00N3000000159ud';
            tier_product_field_id = '00N30000008vG1R';
            case_field_Id = 'CF00N30000008vJO6_lkid';//  case field id and case name have an id, but you have to wrap them around a 'CF' and '_lkid'
            case_name_Id = 'CF00N30000008vJO6';
            opportunity_location_field_Id = '00N300000018Hfg';
            ORDER_TYPE_FIELD_ID = '00NQ0000001Os3a';
            OPPT_TYPE_FIELD_ID = 'opp5';
            OPPT_NAME_FIELD_ID  ='opp3';
            OPPT_CLOSED_DATE_FIELD_ID  = 'opp9';
            OPPT_STAGE_FIELD_ID ='opp11';
            COMPETITOR_1_FIELD_ID = 'CF00N30000001mvZN_lkid';
            COMPETITOR_1_NAME_ID = 'CF00N30000001mvZN';
            PRIMARY_CONTACT_ROLE_FIELD_ID = 'CF00N3000000Bjmzb_lkid';
            PRIMARY_CONTACT_ROLE_NAME_ID = 'CF00N3000000Bjmzb';
            ROLE_FIELD_ID = '00N3000000Bjmzg';
        }
        else//  this should be the MIBOS sandbox, will have to update once we hav eproduction id
        {
            //private final string MIBOS_CASE_FIELD_ID = 'CF' + SystemIds__c.getInstance().FieldId_CaseEvent_Case__c + '_lkid';
            //  taking a page out of Mark Marlonwski book, using the custom settings systemIds to get these values
            
            roadnet_product_field_id = 'CF' + SystemIds__c.getInstance().FieldId_Opportunity_Roadnet_Product__c;// ''00NW0000000YwNV';
            tier_product_field_id = 'CF' + SystemIds__c.getInstance().FieldId_Opportunity_Tier__c;//'00NW0000000YwMh';
            case_field_Id = 'CF' + SystemIds__c.getInstance().FieldId_Opportunity_Case__c + '_lkid';     //'CF00NW0000000YwPl_lkid';
            case_name_Id = 'CF' + SystemIds__c.getInstance().FieldId_Opportunity_Case__c;//'CF00NW0000000YwPl';
            opportunity_location_field_Id = SystemIds__c.getInstance().FieldId_Opportunity_Oppt_Loc__c;//'00NW0000000YwPg';
            ORDER_TYPE_FIELD_ID = SystemIds__c.getInstance().FieldId_Opportunity_Order_Type__c;//'00NW0000000Yiom';
            OPPT_TYPE_FIELD_ID = 'opp5';
            OPPT_NAME_FIELD_ID  ='opp3';
            OPPT_CLOSED_DATE_FIELD_ID  = 'opp9';
            OPPT_STAGE_FIELD_ID ='opp11';
            COMPETITOR_1_FIELD_ID  = 'CF' + SystemIds__c.getInstance().FieldId_Opportunity_Comp1__c + '_lkid';//'CF00NW0000000YwQ5_lkid';
            COMPETITOR_1_NAME_ID = 'CF' + SystemIds__c.getInstance().FieldId_Opportunity_Comp1__c;//'CF00NW0000000YwQ5';
            
            PRIMARY_CONTACT_ROLE_FIELD_ID = 'CF' + SystemIds__c.getInstance().FieldId_Opportunity_Primary_Contact__c + '_lkid';//'CF00NW0000000YwOt_lkid';
            PRIMARY_CONTACT_ROLE_NAME_ID = 'CF' + SystemIds__c.getInstance().FieldId_Opportunity_Primary_Contact__c;//'CF00NW0000000YwOt';
            
            ROLE_FIELD_ID = SystemIds__c.getInstance().FieldId_Opportunity_Role__c; //'00NW0000000YwOJ';
            //util.debug('value of custom setting: ' + SystemIds__c.FieldId_Opportunity_Primary_Contact__c + ' value of variable holding it: ' + primaryContactFieldId + ' value of the url param: ' + PRIMARY_CONTACT_ROLE_FIELD_ID);
        } 
    }
    
    
    @TestVisible private string createOpptName()
    {
        //  to that person, 2 need to figure out how to supress the case is closed stuff
        if (theCase.AccountId != null && 
           theCase.Account.Name != null)
        {
            string accountNameNoAmpersand = theCase.Account.Name.Replace('&', '%26');
            if (theCase.RecordType.name == 'Professional Services')
            {
                    return accountNameNoAmpersand + ' - ';
            }
            else
            {

                return accountNameNoAmpersand + ' - Upgrade ' + date.Today().Format();
            }
        }
        else
        {
            //  if the account name is not set, or the case doesnt have a name use a default oppt name
            return 'Opportunity from Case #' + theCase.CaseNumber;
        }
    }
    
    @TestVisible private Competitor__c retrieveNoneComeptitorRecord
    {
        get
        {
            try
            {
                Competitor__c noneComp = [select id, name from Competitor__c where name = 'None' LIMIT 1];
                return noneComp;
            }
            catch(Exception e)
            {
                
                return null;
            }
        }
    }
    /*
    private static id findProServeQueueId()
    {
        QueueSobject roadnetProServeQueue;
        try
        {
            roadnetProServeQueue = [select id, queueid, queue.name from queuesobject where sobjecttype = 'Case' and queue.name = 'Roadnet Professional Services' limit 1];
            if (roadnetProServeQueue != null)
            {
                return roadnetProServeQueue.queueId;
            }
            return null;
        }
        catch(Exception e)
        {
            //  cant find the queue, just return null
            return null;
        }
    }
    */
    @TestVisible private static void createContactRoleAutoCreatedOppt(Opportunity theOppt)
    {
        OpportunityContactRole ocr = new OpportunityContactRole();
        ocr.OpportunityId = theOppt.id;
        ocr.ContactId = theOppt.Primary_Contact__c;
        ocr.Role = theOppt.Role__c;
        ocr.isPrimary = true;
        insert ocr;
    
    }
    @TestVisible private static string queryProductDescription(Id productId)
    {
        //  the case points to a product, what we need to do is query the product descritption of that product, and return the product description
        //  that's the "product" we want to be selected on the opporutinty
        if (productId == null)
        {
            return null;
        }
        else
        {
            Product2 p;
            try
            {
                p = [select id, description from Product2 where id =: productId];
                return p.description;
            }
            catch(Exception e)
            {
                util.debug('product query with id ' + productId + ' failed due to ' + e.getMessage());
                return null;
            }           
        }
    }
    
    @TestVisible private static User getTinaUserRecord
    {
        get
        {
            User tina;
            try
            {
                tina = [select id, name, email from user where name = 'Tina Duncan' and isactive = true];
                return tina;
            }
            catch(Exception e)
            {
                return null;
            }
            return null;
        }
    }
    @TestVisible private static User getBrianCallahanUserRecord
    {
        get
        {
            User brian;
            try
            {
                brian = [select id, name, email from user where name = 'Brian Callahan' and isactive = true];
                return brian;
            }
            catch(Exception e)
            {
                return null;
            }
            return null;
        }
    }
    @TestVisible private User emailAgentUserRecord
    {
        get
        {
            if (emailAgentUserRecord == null)
            {
                emailAgentUserRecord = [select id, name from user where name = 'Email Agent' limit 1];
            }
            return emailAgentUserRecord;
        }
        set;
    }
    /* commented this out on 12/9/2013 as i was getting a sendEmail not activated for your org.  i think i built this
    to send emails out with attachments, but i never could get it to work
    @future public static void sendEmailWithDocsAsync(List<string> toEmailAddresses, 
        List<string> CCEmailAddresses, List<string> BCCEmailAddresses,
        string subject, string htmlBody, string textBody, List<Id> documentIds, Id organizationWideEmailAddressToUse) 
    {
        util.debug('inside of sendEmailWithDocsAsync called. num of ids in doc id list = ' + documentIds.size());
        
        system.assertNotEquals(null, toEmailAddresses);
        system.assertNotEquals(null, subject);
        system.assertNotEquals(null, textBody);
        //system.assertEquals(true, (subject.length() < 256) );
        
        //  instead of asserting the subject is less than 255 chars, we will allow it to be greater
        //  and then shrink it down so the email can still be sent (this prevented and error email
        //  from being sent to me)
        if (subject.length() > 255)
        {
            subject = Emailclass.truncateString(subject, 255);
        } 
        Messaging.sendemailResult[] sendEmailResults = null;
        
        //  go thru the list of toEmailaddresses and make sure each one contains a value
        for (string str : toEmailAddresses)
        {
            if (str == null)
            {
               throw new myException('To Address in list of to email addresses was null');  
            }
        }
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new List<String>();
        String[] ccAddresses = new List<String>();
        String[] bccAddresses = new List<String>();
        
        //  if we are in the sandbox we want to send the email to myself only
        if (EmailClass.isUserInSandbox())
        {
            toAddresses.add('jhutchins@roadnet.com');
            //  if jane or amy or charlie are testing in the sandbox then the email is sent to them also
            string currentUserEmail;
            try
            {
                currentUserEmail = [select email from user where id =: UserInfo.getUserId()].email;
                toAddresses.add(currentUserEmail);
            }
            catch(Exception e)
            {
                //  do nothing
            }
                
        }
        else
        {
            toAddresses.addAll(toEmailAddresses);
            
            if (CCEmailAddresses != null)
            {
               ccAddresses.addAll(ccEmailAddresses); 
            }
            
            if (BCCemailAddresses != null)
            {
                bccAddresses.addAll(bccEmailAddresses);
            }
        }
        
        mail.setToAddresses(toAddresses);
        mail.setCCAddresses(ccAddresses);
        mail.setBccAddresses(bccAddresses);
        
        mail.setCharSet('UTF-8');//  ASCII--was Unicode and UTF-8
        
        mail.setsubject(subject);
        
        if (htmlBody != null)
        {
            mail.setHtmlBody(htmlBody);
        }
        mail.setPlainTextBody(textBody);
        
        mail.setUseSignature(false);
        
        if (organizationWideEmailAddressToUse != null)
        {
            mail.setOrgWideEmailAddressId(organizationWideEmailAddressToUse);
        }
        
        
        //  here we add the document ids to the email
        
        mail.setDocumentAttachments(documentIds);
        
        //  ok what i assume this object should have is a toemailaddress, ccemailadddress, subject, body, and whether it succeded or not
        //  if not we need to capture the error message
        try
        {
            util.debug('attempting to send the emails now...');
            sendEmailResults = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail }, false);
        }
        catch(Exception e)
        {
            util.debug('sending of the emails failed due to ' + e.getMessage());
            
            EmailClass.createApexEmailRecord(
               toAddresses, ccAddresses, bccAddresses, subject, textBody, htmlBody, 
               organizationWideEmailAddressToUse, false, e.getMessage(), null);
            EmailClass.sendErrorEmail('failed to send apex email due to ' + e.getMessage(), null);
        }
        
        boolean isEmailSendSuccessful;
        string errorMessageIfAny;
        
        if (sendEmailResults != null)
        {
            for (Messaging.SendEmailResult ser : sendEmailResults)
            {
                if ( ser.isSuccess() )
                {
                   isEmailSendSuccessful = true;  
                }
                else if ( !ser.isSuccess())
                {
                    isEmailSendSuccessful = false;
                    errorMessageIfAny = EmailClass.convertSendEmailErrorsToString(ser.getErrors());
                }
            }
        }
        
        Emailclass.createApexEmailRecord(
               toAddresses, ccAddresses, bccAddresses, subject, textBody, htmlBody, 
               organizationWideEmailAddressToUse, isEmailSendSuccessful, errorMessageIfAny, null);
        
        //  i copy pasted this from the original sendEmailAsync which i guess is supposed to go thru
        //  each result and throws exception if any failed.... however i dont know how good this works as there really is no way to tset
        util.debug('now going thru the whole list of email results to see if any failed');
        
        for (Messaging.sendemailResult ser : sendEmailResults)
        {
            if (!ser.isSuccess())
            {
                util.debug('found a failure due to: '  +emailclass.convertSendEmailErrorsToString(ser.getErrors())); 
                throw new myException('email sending failed due to ' + emailclass.convertSendEmailErrorsToString(ser.getErrors()));
            }
        }
    }
    */
    public static ApexPages.StandardController generateController(Case bd)
    {
        pagereference pageRef=new pagereference('Page.BillingDetailPage');
        test.setcurrentpage(pageRef);
        //declare apexpages.standardcontroller so that we can pass it into this class's constructor
     
        
        return new ApexPages.standardController(bd);
    }

    public class myException extends exception{}
    
}