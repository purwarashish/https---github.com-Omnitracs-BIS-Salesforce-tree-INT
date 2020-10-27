/*******************************************************************************
 * File:  LeadConversionExtension.cls
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
public with sharing class LeadConversionExtension
{
    
    public LeadConversionExtension(ApexPages.StandardController stdController)
    {
        theLead = queryLead(stdController.getId());
        init();
    }
    
    public string mergeContactUserChoice{get;set;}
    public boolean showMergeContactsSection{get;set;}
    public List<Contact> matchingContacts{get;set;}
    public Contact theContactForOwnerLookupOnly{get;set;}
    public boolean doNotCreateOppt{get;set;}
    public boolean isSendEmailToNewOwner{get;set;}
    public Lead theLead{get;set;}
    public Opportunity theOppt{get;set;}
    public Task theTask{get;set;}
    public Account[] matchingAccounts{get;set;}
    public Account accountToAttachLeadTo{get;set;}
    public boolean isCreatingNewAccount{get;set;}
    public string opptRecordtypeUserChoice{get;set;}
    public string convertedStatusUserChoice{get;set;}
    public string accountPicklistUserChoice{get;set;}
    public boolean taskShouldSendNotficationEmail{get;set;}
    public OpportunityContactRole contactRoleUsedForRolePicklistOnly{get;set;}
    public boolean showAccountLookup{get;set;}
    public List<SelectOption> accountPicklist{get;set;}
    public List<SelectOption> mergeContactPicklist{get;set;}
    public decimal opptAmountFieldUserchoice{get;set;}
    public boolean areTaskFieldsRequired{get;set;}
    public string[] productsToAdd{get;set;}
    public string[] productsToRemove{get;set;}
    
    public boolean isRoadnetBu
    {
        get
        {
            User loggedInuser = [select id, business_unit__c from User where id =: userInfo.getUserId()];
            return loggedInUser != null &&
              loggedInUser.business_unit__c == 'Roadnet';
        }
    }
    
    public string leadConvertHelpMessage
    {
        get
        {
            return '<br />' + 
              'Leads can be converted to accounts, contacts, opportunities, and followup tasks.<br />' + 
              'You should only convert a lead once you have identified it as qualified.<br />' +
              'After this lead has been converted, it can no longer be viewed or edited as a lead, but can be viewed in lead reports.';
        }
    }
    public string mergeHelpMessage
    {
        get
        {
            return '<br />' +
              'To avoid creating duplicate contacts, select from the options below. ' +
              'When an existing contact is selected, all open activities from the lead will be added to the contact and all new data will be added. ' + 
              'Lead data will not overwrite existing contact data.';
        }
    }
    
    public List<SelectOPtion> stageNamePicklist
    {
        get
        {
            //  per sf issue blarg, shannon stated that the isrs will need the other open stages, instead of hardcoding, i am going to query
            //  the stagename table and have only the non closed ones show in the picklist
            List<SelectOption> options = new LIst<SelectOption>();
          
            
            OpportunityStage[] nonClosedStages = grabOnlyNonclosedStages();//  have a private list of all stages, thithis method will scroll thru and return non closedone
            
            options.add(Pl.noneOption);
            
            for (OpportunityStage singleStage : nonClosedStages)
            {
                //  right now we only have one stage that an oppt can have set for it before we get validation rules to come in
                //  so we'll only have that one value there unless shannon states something different
                if (singleStage.masterLabel == 'Sales Acceptance')
                {
                    options.add(new selectoption(singleStage.MasterLabel, singleStage.MasterLabel));
                }
                
                if (singleStage.masterLabel == 'MQL')    //Added by Animesh(TCS) - Case#03826898
                {
                    options.add(new selectoption(singleStage.MasterLabel, singleStage.MasterLabel));
                }
                
            } 
            
            return options;
            
        }
    }
    public List<SelectOption> convertedStatusPicklist
    {
        get
        {
            List<selectoption> options = new List<SelectOption>();
            options.add(pl.noneOption);
            LeadStatus[] convertedStatus = [select id, masterlabel from LeadStatus where IsConverted  = true];
            for (LeadStatus ls : convertedStatus)
            {
                options.add(new SelectOption(ls.masterLabel, ls.masterLabel));
            }
                        
            return options;
        }       
    }
    public List<SelectOption> opptRecordTypePicklist
    {
        get
        {   
            
            List<SelectOPtion> options = new List<SelectOption>();
            options.add(pl.noneOption);
                      
            Recordtype[] opptRecordTypes = [select id, name from Recordtype where sobjecttype = 'Opportunity'];
            for (Recordtype rt : opptRecordTypes)
            {
                options.add(new selectoption(rt.Id, rt.name));
            }       
            
            return options;
        }
    }
    public boolean hasLeadBeenConvertedWhilePageWasOpen()
    {
        //  rquery the lead for the isconverted flag and return it
        if (theLead == null)
        {
            return false;
        }
        else
        {
            Lead tempLead = [select id, isConverted from Lead where id =: theLead.id];
            return tempLead.isConverted;
        }
    }
    
    public PageReference checkIfConvertedLead()
    {
        if (thelead.isConverted && theLead.ConvertedContactId != null)
        {
            PageReference pr = new PageReference('/p/lead/ViewConvertedLead/d?id=' + theLead.id);
            pr.setredirect(true);
            return pr;
        }
        else
        {
            return null;
        }
    }
    public PageReference taskReminderOnChange()
    {
        //  so we'll have a boolean that will deterinme if this is required or not
        areTaskFieldsRequired = theTask.isReminderSet;
        return null;
    }
    
    public PageReference doNotCreateOpptOnChange()
    {
        //  this really shouldnt do anything but refresh the page, i'll have rendered bools which will denote if the fields
        //  should be editable or not
        return null;
        
    }
    public PageReference simplePageRefresh()
    {
        return null;
    }
    public PageReference accountLookupOnBlur()
    {
        //  if the account field has a value, query its name, and add it to the account picklist
        //  seeing a bug where this is updating even if you pick the Attach to existing:
        if (theContactForOwnerLookupOnly.Accountid != null)
        {
            //  during uat testing, i am seeing that each time this onblur occurs (so clicking inthe field, then clicking out of it etc)
            //  causes the value in the account lookup to keep being addded (since i no longer blank the field out) so need t
            //  each time this is called, check to see if the account is already in the list, and if it is, dont add another picklsit entry
            if (!isAccountInPIcklistAlready(theContactForOwnerLookupOnly.Accountid, accountPicklist))
            {
                account tempAccount = [select id, name from account where id =: theContactForOwnerLookupOnly.AccountId];
                accountPicklist.add(
                    (accountPicklist.size() - 1),  //  size of list - 1
                    new selectoption(tempAccount.id, ATTACH_TO_EXISTING + tempAccount.Name) );
               
                //  we want to default the users choice to the account set in the lookup field          
                //accountPicklistUserChoice = accountPicklist[(accountPicklist.size() - 2)].getValue();
                accountPicklistUserChoice = tempAccount.id;
                //theContactForOwnerLookupOnly.Accountid = null;//  once the account has been added to the picklsit we can remove the value in the field
            }
            else
            {
                //  account is already in picklist, it SHOULD have value of Attach To Existing [accountname] 
                //  so just default the selected picklist value to be that account in the lookup field
                accountPicklistUserChoice = theContactForOwnerLookupOnly.Accountid;
            }
        }
        return null;
    }
    
    public PageReference accountPicklistOnchange()
    {
        if (accountPicklistUserChoice == LOOKUP_NEW_ACCOUNT_PICKLIST_VALUE)
        {
            showAccountLookup = true;
        }
        else
        {
            showAccountLookup = false;
        }
        return null;
    }
    public PageReference opptRecordTypePicklistOnChange()
    {
        //  it is possible that the user sets some of the oppt fields on the page, then changes the recordtype to something else
        //  this would in turn cause some fields to hide... but the values are never wiped out which would cause
        //  the assingment code in the Conversion method below to assign the hidden fields with values to the oppt even though the
        //  user didn't reallymean for those fields to have values, because of this, we need to wipe out the aomunt fields
        //  on each recortype change so that this issue does not occur
        
        //  so empty out all of the oppt fields on the page
        theOppt.Est_Hours_on_SOW__c =  null;
        theOppt.Hourly_Rate__c = null;
     // theOppt.Flat_Rate_database_work__c = null;
     // theOppt.RNU_Class_Cost_per_person__c = null;
     // theOppt.Number_of_Students_to_Attend_RNU__c = null;
        theOppt.number_of_Proserve_Days__c = null;
        theOppt.ProServe_Rate__c = null;
        theOppt.Software_dollars__c = null;
     // theOppt.Term_months__c = null;
     // theOppt.Number_of_Licensed_Vehicles__c = null;
     // theOppt.Monthly_Fee_Per_Vehicle__c = null;
     // theOppt.Monthly_RNT_Fee_34_99__c = null;
        theOppt.Additional_Monthly_Subscription_Fee_s__c = null;
        theOppt.UPS_of_Total_SW__c = null;
        
        return null;
    }
    
    public PageReference checkForFieldsAndForDupeContacts()
    {
        //  set fields from the vf page
        theLead.Status = convertedStatusUserChoice;
        //  i used to have the oppt.amount field on the page until i noticed that oppts i was converting had $0.00.
        //  this is due to a couple of field updatees that fire once the oppt is saved. basically the amount field
        //  althought it a freeform field, its treated as a formuala with these work flows so we cannot use the 
        //  amount field. instead im using a dummy text field as an entry amount and the 
        //  this code will need to use the correct amount field
                  
        if (!checkRequiredFields() && !Test.isRunningTest())
        { 
            return null;
        }
        //  i expect the account picklist to have these values:
        
        //    CreateNewAccount, create new account jane's test account
        //    RANDOMID0001, Attach To Existing Account: blarg
        //    RANDOMID0002, Attach to Existing Account:  blarg2
        //    LookupNewAccount, Lookup to new account
        
        //  so what i'll do is check specifcally for the 1st and 4th values, if the accountPicklistUserChoice
        //  does not = to either of them, i can assume its an id and i can try to query the account
        if (accountPicklistUserChoice != null &&
            accountPicklistUSerChoice != pl.none &&
            accountPicklistUserChoice != CREATE_ACCOUNT_PICKLIST_VALUE &&
            accountPicklistUserChoice != LOOKUP_NEW_ACCOUNT_PICKLIST_VALUE)
        {
            //  assume the selected picklsit is an id
            string accountId = accountPicklistUserChoice;
            system.assertEquals(true, (accountId.length() == 15 || accountId.Length() == 18));
            //  if the accountPicklistUserchoice is an id then this queyr will work
            accountToAttachLeadTo = [select id, name, primary_business_unit__c from Account where id =: accountId];
            
            //  there is a validation rule that prevents the oppt from being updated if the negotation_type is not set for account.primary buinessunit = omnitracs mexico
            //  so if user is attaching the converted lead to existing account, this should be set so that the oppt update int he convertLead method sets the negoationtype field
            if (!isOmnitracsDomesticAccount)//  if this has not been set yet, it will be here if user is attaching to a omnitracs account
            {
                isOmnitracsDomesticAccount  = accountToAttachLeadTo != null && accountToAttachLeadTo.Primary_Business_unit__c == 'Omnitracs Mexico';
            }
            
            
            List<Contact> contactsOfAccount =
               [select id, name, firstname, lastname, accountid from Contact where AccountId =: accountToAttachLeadTo.id];
            
            //  now that we have the contacts of the account, we can check to see if the lead's name
            //  match any of the contacts of the account already
            for (Contact c : contactsOfAccount){
                //  the regular conversion page matches on the first or last name
                if (c.FirstName == theLead.FirstName ||
                  c.LastName == theLead.LastName)
                  {
                    matchingContacts.add(c);
                  }
            }           
        }
        
        //  so now we'll see if the matchingcontacts list contains anything, it it does we need to show the merge page
        if (matchingContacts != null && matchingContacts.size() > 0)
        {
            // not sure if i should show a page or a section... i wnt it to be the same page so i can still use the
            //  methods defined here so i'll make a section
            showMergeContactsSection = true;
            defineMergeContactPicklist();
            return null;
        }
        
        //  so either the account has no matching contacts or it does, if it does, the user will see the merge contact page
        //  if not, we can convert the lead right away...
        return convertLead();
    }

    public void defineMergeContactPicklist()
    {
        mergeContactPicklist = new List<SelectOption>();
        //  so we just need to add the create new contact item and then the rest of the items will be the values in the 
        //  mergecontact list
        mergeContactPicklist.add(new selectoption(CREATE_NEW_CONTACT_VALUE, 'Create New Contact: ' + theLead.name));
        for (Contact c : matchingContacts)
        {
            mergeContactPicklist.add(new SelectOption(c.id, 'Attach to Existing: ' + c.Name));
        }
    }

    public PageReference convertLead()
    {
        
        //  i have received the error  cannot reference converted lead 4 times since this page went live
        //  i tested in the sandbox that if you press the convert led button to bring up the vf page, then convert hte lead whiele the page is still open
        //  when you try to convert the lead at the page,you get the  cannot reference converted lead error.
        //  there's nothing i can do to stop this from happening except for perform some tyhpe of check before this does anything
        //  so that the user knows what has happened gracefully
        
        if (hasLeadBeenConvertedWhilePageWasOpen())
        {
            //  luckily i have a method that alrady does the dirty work here so if after teh requery we notice the lead was converted
            // we can lazily just show this page:
            PageReference pr = new PageReference('/p/lead/ViewConvertedLead/d?id=' + theLead.id);
            pr.setredirect(true);
            return pr;
        }
        
        //  fields on the lead convert page should be lead fields... so if they changed or not, we need to update the lead
        //  then we can call the coonversion method
        //database.update(thelead);
    //  theLead.Identify_Converted_Opp__c = true;
        update theLead;
        
        //  alright time to plan, first need to check if we are doing the merge contact thing as that contains a ton of logic i need to ipmlement
            //   so the user is either going to merge or crate a new contact, if we are creaitng  anew contact, there really isnt anything extra that needs to be done
            //  if merging,     THE JOB IS ALREADY DONE FOR ME, the setContactId does the mergeing for me, so i'll just need to test it
        //  convert the lead
        //  then send out the email notifications if set
        //  then need to query the oppt and update it's fields once the oppt has been created
        //  lastly redirect the user to the contact page
        Database.LeadConvert theLeadConvert = new Database.LeadConvert();
        
        //  make sure the user has picked a contact
        if (showMergeContactsSection &&
           (mergeContactUserChoice == null || mergeContactUserChoice == pl.none))
        {
            theLead.addError('Please pick a valid value for the contact\'s picklist.');
            return null;
        }
        //  at this point in the code, the required fields should've alrady been checked
        //  so we just need to do the conversion
        if (matchingContacts != null && matchingContacts.size() > 0)
        {
           //  so the user etierh sleected a contact to merge or is creating a new one
            if (mergeContactUserChoice != CREATE_NEW_CONTACT_VALUE)
            {
                //  so the user has HOPEFULLY selected a new contact in the mergecontact picklist
                //  we need to assert that is the case
                system.assertEquals(true, (mergeContactUserChoice.length() == 15 || mergeContactUserChoice.Length() == 18));
                //  if merging to a contact, we need to set the contact id in the lead convert
                theLeadConvert.setContactId(mergeContactUserChoice);
            }
        }
        
        //  so some good news and maybe bad news... alot of the custom code i thought i would need... i do not.
        //  the LeadConvert class does alot of this for me so honestly i just need to know how to set the LeadConvert object up
        //  and go from there
        //  have note that i need to update the lead (user has to be a conerted lead status) but the lead record won't have the new value unless we update here
        update theLead;
        
        theLeadConvert.setLeadid(theLead.id);
        theLeadConvert.setOverwriteLeadSource(false);//  not sure if this needed but settting itt to false
        string accountid = findAccountId();//  putting the logic here in a method so i can at least get this method built
        if (accountId != null)
        {
            theLeadConvert.setAccountId(findAccountId());
        }
        theLeadConvert.setConvertedSTatus(thelead.Status);
        
        theLeadConvert.setDoNotCreateOpportunity(doNotCreateOppt);
        if (!doNotCreateOppt)//  creating an oppt on conversion
        {
            //  validtion rule defined: https://cs3.salesforce.com/03d3000000094Vb?setupid=OpportunityValidations
            //  requuires the oppt name to contain hyphen with two spaces, changed to just one hyphen with ok from amy
            //system.assert(theOppt.Name.contains(' -'));
            theLeadConvert.setOpportunityName(theOppt.Name);
        }
        theLeadConvert.setOwnerId(theContactForOwnerLookupOnly.ownerId);
        
        theLeadConvert.setSendNotificationEmail(isSendEmailToNewOwner);//  this sends the new contact owner email notificatoin
        
          
        //  convert the lead, once converted, need to update the oppt if user created one'
        Database.LeadConvertResult lcr;
        
        try
        {
            lcr = Database.convertLead(theLeadConvert);
        }
        catch(Exception e)
        {
            //  during testing for the omnitracs version of this page, i ran into this error mutiple times:
            //  DUPLICATE_VALUE, duplicate value found:  i want to see if i can catch this and have it show gracefully ont he screen
            //  the issue for me was that i was trying to create a new account where the rfc_id field was the same as jane's test accoun1
            //  there is not a ceratin TYPE of exception that is thrown, its just an error so i will check the message for DUPLICATE_VALUE
            //  and if found, will output the message onto the screen
            if (e.getMessage() != null && e.getMessage().contains('DUPLICATE_VALUE'))
            {
                thelead.AddError('Conversion of lead failed due to duplicate value being found.  ' + 
                   'This is normally caused by the lead\'s mapping to an account/contact field that is marked as "Unique" ' + 
                   'and a record exists with the value.  For example: Account.RFC_ID__c is unique.  If account exists with rfc_Id__c = "Dog" ' + 
                   'and the lead\'s RFC ID field is also "Dog", this error will be produced when trying to create a new account in the conversion process.');
            }
            else// a true unexpected error, show the error on the screen gracefully
            {
                
                //  not sure yet, but if the oppt name fails convention, it throws exception, i want to catch that 
                //  here to handle the error gracefully
                thelead.addError('Error occured while calling database.convertLead: ' + e.getMessage());
            }
            return null;
        }
        
        //  now that we have the lead convert result, we'll check for success/failures,
        //  then update the oppt if user asked to
        //  two things happen after the lead is converted and they both depend on whether or not the user wanted to create an oppt: 1- crate contact role and 2-update the custom fieds on the screen
        if (!lcr.isSuccess())
        {
            theLead.AddError('Lead conversion failed.  Please fix errors and restart the conversion process: ' + 
               lcr.getErrors()[0].getMessage());
            return null;
        }
        else
        {
            //  so we need to update oppt fields, and create a contact role for the oppt
            
            if (!doNotCreateOppt)
            {
                id newlyCreatedOpptId = lcr.getOpportunityId();
                 
                //    i've recieved this error about 4 times since i created this vf page:
                 //   caused by: System.DmlException: Update failed. First exception on row 0 with id 0063000000z2lYfAAI; first error: INSUFFICIENT_ACCESS_ON_CROSS_REFERENCE_ENTITY, insufficient access rights on cross-reference id: []
                    
                  //  the inscufficent access error is occuring here and i am unable to see why it is happening, i can only assume
                  //  the owner of the oppt probably differs from the owner of the account?  naw that doesn't make sense... actually it does
                   // if the user selected an existing account, and the account beglons to sales rep A but the lead and the oppt owner is belongs
                  //  to sale rep B, then there could be an owner confil issue, so here's what ill do, ill create a debugstring of the various values
                    //of the oppt/lead?controller then will ctry to catch and the exception and create an error eamil from it
                 
                 try
                 {
                     updateOpptWithCustomFieldsAndUpdateContactRole(newlyCreatedOpptId, lcr.getContactId(), contactRoleUsedForRolePicklistOnly.Role);
                 }
                 catch(System.DmlException dmlException)
                 {
                    //  be advised since i still dont know WHY this is caused, i cannot gracefully catch and handle the exception
                    //  instead, i will have the exception get rethrown with hopefully more identfyviable informaiton.  
                   string debugString = 'LoggedInUser: ' + UserInfo.getUserId() + 
                       ' LeadId: ' + (theLead != null ? theLead.id : 'LeadIdUnknown') +  
                       ' AccountId: ' + findAccountId() + 
                       ' OpptId: ' + lcr.getOpportunityId() + 
                       ' LeadOwnerId: ' + theContactForOwnerLookupOnly.OwnerId +
                       ' MatchingContacts.Size(): ' + matchingContacts.size() + 
                       ' MergeContactId: ' + mergeContactUserChoice + 
                       ' doNotCreateOppt: ' + doNotCreateOppt + 
                       ' isSendEmailToNewOwner: ' + isSendEmailToNewOwner + 
                       ' ExceptionMessage: ' + dmlException.getMessage();
                       
                    throw new myException('Problem occured when trying to update oppt.  Outputting debug info: ' + debugString); 
                 }
            }
            //  line below is incorrect, if the task reminder is not set, then we dont create the task
            //  the task is created irregardless of what bools are set on the page and the whatid is the contact id
            //  so i'll pass the logic to a method that will create the task AND send the notificaiotn email if set
            try
            {
                if (areTaskFieldsRequired)
                {
                   createTaskAndSendNotifcationIfSet(lcr.getContactid(), lcr.getOpportunityId(), userInfo.getUserId());
                }
            }
            catch(Exception e)
            {
                //  the method will throw exception if task could not be created, need to show error message why it couldnt be crated
                //  gracefullly
                theLead.AddError('Task insertion failed.  Please retry to convert lead.  Error message: ' + e.getMessage());
                return null;
            }
            
            //  whether the user created an oppt or not, the normal page redirects to the account page so thats what ill do here
            
            PageReference pr = new PageREference('/' + lcr.getAccountId());
            pr.setRedirect(true);
            return pr;
        }

        return null;
    }
    
    public List<OpportunityStage> grabOnlyNonclosedStages()
    {
        List<OpportunityStage> nonclosedStages = new List<OpportunityStage>();
        for (OpportunityStage singleStage : opptStages)
        {
            if (!singleSTage.isClosed && 
                singleStage.MasterLabel != 'Sales Complete')//  sales complete cannot be first stage set on oppt)
            {
                nonClosedStages.add(singleSTage);
            }
        }
        return nonclosedStages;
        
    }    
    private List<OpportunityStage> opptStages; //  populated in the init method

    private string findAccountId()
    {
        //  so the user is either creaitng a new account, or attaching to an exiting one
        //  to know which, we have to check the value of the accountPicklistUserChoice
        if (accountPicklistUserChoice == LOOKUP_NEW_ACCOUNT_PICKLIST_VALUE)
        {
            //  user has lookup picklist still selected, hopefully the checkrequired fields will catch this before this code does,
            //  either way, need to return null... 
            return null;
        }
        else if (accountPicklistUserChoice == CREATE_ACCOUNT_PICKLIST_VALUE)
        {
            //  creating a new account
            return null;
        }
        else
        {
            
            //  so if i coded this wrongly, it's possible still has the Lookup to new account selected. so let's make sure that is not the case
            string accountId = accountPicklistUserChoice;
            if (accountId.length() != 15 && accountId.Length() != 18)
            {
                throw new myException('Selected account is not an Id.  Please check source code.');
            }
            return accountPicklistUserChoice;
            
        }
    }
    
    public void updateOpptWithCustomFieldsAndUpdateContactRole(id opptId, id contactIdSlashPrimryContactRoleId, string selectedPrimaryContactRole)
    {
        util.debug('inside of updateOpptWithCustomFieldsAndUpdateContactRole method...');
        
        //  need to query the newly created oppt,
        Opportunity newlyCreatedOppt = [select id, description, type, amount, closedate, recordtypeid, 
            product_type__c, Tier__c,
            //  start of new fields for omnitracs version of this page
            budget__c, need__c, Authority__c, Timeframe_for_Purchasing__c, self_reported_fleet_size__c,
            TotalOpportunityQuantity, Editable_Opportunity_Qty__c, order_type__c, order_sub_type__c, primary_contact__c,
            //  start of fields needed for validation rules
            leadSource, Lead_Origin__c, 
            //  start of all fields used to calc the standard amount field
            Est_Hours_on_SOW__c, Hourly_rate__c, 
            number_of_Proserve_Days__c, ProServe_Rate__c, 
            Software_dollars__c,UPS_of_Total_SW__c,
            Additional_Monthly_Subscription_Fee_s__c,
            StageName, negotiation_type__c
              from Opportunity where id =: OpptId];
        
        util.debug('newly created oppt should have been created.  here is its value: ' + newlyCreatedOppt);
      
        //  set fields that the vf page has set
        newlyCreatedOppt.RecordtypeId = opptRecordtypeUserChoice;//  the oppt recordtype user choice should be an id
        newlyCreatedOppt.type = theOppt.type;
        newlyCreatedOppt.amount = theOppt.Amount;
        newlyCreatedOppt.closedate = theOppt.closedate;
    //  newlyCreatedOppt.number_of_licensed_vehicles__c = theOppt.number_of_Licensed_vehicles__c;
        newlyCreatedOppt.product_type__c = theOppt.product_type__c;
        newlyCreatedOppt.Competitor_1__c = theOppt.Competitor_1__c;
        newlyCreatedOppt.Competitor_2__c = theOppt.Competitor_2__c;
        newlyCreatedOppt.Competitor_3__c = theOppt.Competitor_3__c;
        newlyCreatedOppt.Competitor_4__c = theOppt.Competitor_4__c;
        
        //  start of assignment for omnitracs verison of this page
        newlyCreatedOppt.budget__c = theOppt.budget__c;
        newlyCreatedOppt.need__c = theOppt.need__c;
        newlyCreatedOppt.Authority__c = theOppt.Authority__c; 
        newlyCreatedOppt.Timeframe_for_Purchasing__c = theOppt.Timeframe_for_Purchasing__c;
        newlyCreatedOppt.Lead_Administrator_Lookup_to_User__c= theOppt.Lead_Administrator_Lookup_to_User__c;
        // field is not writeable: newlyCreatedOppt.self_reported_fleet_size__c = theOppt.self_reported_fleet_size__c;
        newlyCreatedOppt.LeadSource = theOppt.LeadSource;
        newlyCreatedOppt.TotalOpportunityQuantity = theOppt.TotalOpportunityQuantity;
        newlyCreatedOppt.Editable_Opportunity_Qty__c = theOppt.Editable_Opportunity_Qty__c;
        newlyCreatedOppt.order_type__c = theOppt.order_type__c;
        newlyCreatedOppt.order_sub_type__c = theOppt.order_sub_type__c;
        
        //  this is the start of the dependant amount field assignments
        newlyCreatedOppt.Est_Hours_on_SOW__c = theOppt.Est_Hours_on_SOW__c;
        newlyCreatedOppt.Hourly_Rate__c = theOppt.Hourly_Rate__c;
     // newlyCreatedOppt.Flat_Rate_database_work__c = theOppt.Flat_Rate_database_work__c;
     // newlyCreatedOppt.RNU_Class_Cost_per_person__c = theOppt.RNU_Class_Cost_per_person__c;
    //  newlyCreatedOppt.Number_of_Students_to_Attend_RNU__c = theOppt.Number_of_Students_to_Attend_RNU__c;
        newlyCreatedOppt.number_of_Proserve_Days__c = theOppt.number_of_Proserve_Days__c;
        newlyCreatedOppt.ProServe_Rate__c = theOppt.ProServe_Rate__c;
        newlyCreatedOppt.Software_dollars__c = theOppt.Software_dollars__c;
     // newlyCreatedOppt.Term_months__c = theOppt.Term_months__c;
     // newlyCreatedOppt.Monthly_Fee_Per_Vehicle__c = theOppt.Monthly_Fee_Per_Vehicle__c;
    //  newlyCreatedOppt.Monthly_RNT_Fee_34_99__c = theOppt.Monthly_RNT_Fee_34_99__c;
        newlyCreatedOppt.Additional_Monthly_Subscription_Fee_s__c = theOppt.Additional_Monthly_Subscription_Fee_s__c;
        newlyCreatedOppt.UPS_of_Total_SW__c = theOppt.UPS_of_Total_SW__c;
        newlyCreatedOppt.Tier__c = theOppt.Tier__c;
        
        
        if (isOmnitracsDomesticAccount)
        {
            //  need to defulat this as a validation rule would prevent the oppt from being updated in the method below
            newlyCreatedOppt.negotiation_type__c = 'Sale';
        }
        
        //  start of oppt validation rule fields
      /*  if (!util.isBlank(theOppt.Corporate_License__c ))
        {
            newlyCreatedOPpt.Corporate_License__c = theOppt.Corporate_License__c;
        } */
        /*
        if (!util.isBlank(theOppt.Lead_Administrator__c ))
        {
            newlyCreatedOPpt.Lead_Administrator__c = theOppt.Lead_Administrator__c;
        }
          if (!util.isBlank(theOppt.Lead_Origin__c ))
        {
            newlyCreatedOPpt.Lead_Origin__c = theOppt.Lead_Origin__c;
        }
        if (!util.isBlank(theOppt.Install_Type__c))
        {
            newlyCreatedOppt.Install_Type__c = theOppt.Install_Type__c;
        }
        */
        if (!util.isBlank(theOppt.LeadSource ))
        {
            newlyCreatedOPpt.LeadSource = theOppt.LeadSource;
        } 
      
    
        
        //  the oppt requires primary contact/role fields to be set
        //  so prepop with what the user selected on the lead conversion screen
        //  the problem is that the primary contact field on the oppournity is a contact lookup so
        //  do w have the contactId of the primary contact role at this point?
        newlyCreatedOppt.Primary_Contact__c = contactIdSlashPrimryContactRoleId;
        newlyCreatedOppt.role__c = selectedPrimaryContactRole;
        if (!Util.isBlank(theOppt.StageName) && theOppt.STageName != '--None--' )
        {
            newlyCreatedOppt.StageName = theOppt.StageName;
        }
        
        //  if task was created, updated the oppt's description
        if (!util.isBlank(theTask.Description))
        {
            newlyCreatedOppt.Description = theTask.Description;
        }
        util.debug('making update call on oppt now');
        
        
        //  update the oppt then we do the contact role
        //  INSUFFICIENT_ACCESS_ON_CROSS_REFERENCE_ENTITY exception has been occuring here
        update newlyCreatedOppt;
        
         
        util.debug('getting ready to query the contct roles....');
        //  finally check if a contact role was created (tesitng shows it was), change its role to end user or unknown
        OpportunityContactRole[] contactRoles = 
            [Select  o.Role, o.OpportunityId, o.IsPrimary, o.Id,  o.ContactId From OpportunityContactRole o where OpportunityId =: newlyCreatedOppt.id];
        
        util.debug('number of contactRoles returned = ' + (contactRoles == null ? 'its null' : string.valueOf(contactRoles.size()) )   );
        //  there should only be one contact role, since we created the oppt in this clas here. so just set it's role to End user then update it
        if (contactRoles != null &&
            contactRoles.size() > 0 && 
            contactRoles.size() == 1 &&
            !Util.isBlank(contactRoleUsedForRolePicklistOnly.Role) &&
            contactRoleUsedForRolePicklistOnly.role != pl.none) 
        {
            contactRoles[0].Role = contactRoleUsedForRolePicklistOnly.Role;
            update contactRoles;
        }
    }
    
    public void createTaskAndSendNotifcationIfSet(id contactId, Id opptId, Id userId)
    {
        //  be advised that during my testing, when i converetd a lead and created an oppt, the taskt hat was created for it
        //  pointed to the oppt, i just created a elad with no oppt and the realted to/whatId is blank
        theTask.whoId = contactId;
        theTask.WhatId = opptId;//  this can be blank if the oppt was not created.
        theTask.OwnerId = userId;
        
        Database.saveResult taskSaveResult = Database.insert(theTask);
        
        if (!taskSaveResult.isSuccess())
        {
            throw new myException('Task insertion failed due to: ' + taskSaveResult.getErrors()[0].getMessage());
        }
        
        //  need to insert the task, asssignign the appropiate id fields
        if (taskShouldSendNotficationEmail)
        {
            //  the lead convert doesn't have a bool to set the taks notificatoin, i'll have to send this email alert myself
            //  send email notfication that the lead conversin's task was created
            //  i'll use the same format as the default page
            sendTaskNotificationEmail(taskSaveResult.getId());
        }
    }
   
    private void defineAccountPicklist()
    {
        //  this is a weird picklist.  i want it to contain ids of accounts to make the 
        //  serach for merged/dupe contacts to be a simple as possible.
        //  the problem is that every selectopion in this list will not have IDs as a value
        //  the first and last option will actually be text taht says
        
        //  so want i want is a static string that represnets the first and last item in the list's getValue
        accountPicklist = new List<SelectOption>();
        
        accountPicklist.add(new selectoption(CREATE_ACCOUNT_PICKLIST_VALUE, 'Create New Account: ' + theLead.company));
        
        //  first thing onpageload, need to see if account exists matching the lead name and populate the account picklist
        matchingAccounts = new List<Account>();
        //  before the page loads, we need to perform a search for an existing account using the lead's company name
        if (thelead.company != null)
        {
            //  i was going to do a dynamic query using Like '%AccountName%' but i feel like having a dyanmic query be applied
            //  to a field in this constructor... it feels like a perfect sql injection entrypoint so instead i'm looking for exact match
            matchingAccounts = [select id, name from Account where name =: theLead.Company];
            for (Account singleAccount : matchingAccounts)
            {
                accountPicklist.add(new selectoption(singleAccount.Id, ATTACH_TO_EXISTING + singleAccount.name));
            }
            accountPicklist.add(new SelectOption(LOOKUP_NEW_ACCOUNT_PICKLIST_VALUE, LOOKUP_NEW_ACCOUNT_PICKLIST_LABEL));            
        }        
        
    }
    private boolean checkRequiredFields()
    {
        final string ERROR_MSG = 'You must enter a value';
        
        boolean isOkToConvert = true;
        //  so the user needs to have selected either create or add to existing, this ensures we either need to create account or query it
        if (accountPicklistUserChoice == LOOKUP_NEW_ACCOUNT_PICKLIST_VALUE)
        {
            //  this should never happen as the accountOnBlur is supposed to prepop the selected picklsit value
            //  with the newly added account
            ApexPages.addMessage(
                new ApexPages.Message(ApexPages.Severity.ERROR, 'Please Select "Create New Account" or "Attach To Existing Account"'));
            isOkToConvert = false;
        } 
        
        if (opptRecordtypeUserChoice == null || opptRecordtypeUserChoice == pl.none)
        {
            theOppt.RecordTypeId.addError(ERROR_MSG);
            isOkToConvert = false;
        }
        //  convert the lead to contact, make sure fields are set on the page?
        if (Util.isBlank(theContactForOwnerLookupOnly.OwnerId))
        {
            theContactForOwnerLookupOnly.OwnerId.AddError(ERROR_MSG);
            isOkToConvert = false;            
        }
        
        if (Util.isBlank(theLead.Status) || thelead.status == pl.none)
        {
            ApexPages.addMessage(
                new ApexPages.Message(ApexPages.Severity.ERROR, 'Lead Converted Status requires a value'));
            isOkToConvert = false;
        }
        
        if(Util.isBlank(theLead.Segment__c)){
            theLead.Segment__c.addError(ERROR_MSG);
            isOkToConvert = false;
        }
        
        if(theLead.Fleet_Size__c == null && theLead.Self_Reported_Fleet_Size__c == null){
            theLead.Fleet_Size__c.addError('You must enter value for either System Fleet Size or Self Reported Fleet Size');
            isOkToConvert = false;
        }
        //Added by Sooraj(TCS) - Case#04179930
                
        String uRoleId = UserInfo.getUserRoleId();        
        if(uRoleId =='00E50000000lr6sEAA' && theLead.Country == 'United States' && theLead.NAICS_Code__c == null){
            theLead.NAICS_Code__c.addError('Please enter NAICS Code value');
            isOkToConvert = false;
        }
      
        
        if (!doNotCreateOppt)//  user is creating oppt, check the name and the contact role assignment
        {
            //  lead fields--these only show up on the page if the do not create oppt is set to false
            //   so we only need to check them if that check is not set
         /* if (!doNotCreateOppt)
            {
                if (Util.isBlank(theLead.Lead_Admin__c))
                {
                    theLead.Lead_Admin__c.addError(ERROR_MSG);
                    isOkToConvert = false;
                }
            } */
            /*
            if (showConsultingTierField && util.isBlank(theOppt.Tier__c))
            {
                theOppt.Tier__c.AddError(ERROR_MSG);
                isOkToConvert = false;
            }
            if (showInstallTypeOpptField && util.isBlank(theOppt.Install_Type__c))
            {
                theOppt.Install_Type__c.AddError(ERROR_MSG);
                isOKToConvert = false;
            }
            */
            if ( util.isblank(theOppt.Name))
            {
                theOppt.Name.AddError(ERROR_MSG);
                isOkToConvert = false;
            }
            /*
            //  validtion rule requires oppt name have a hypen with two spaces
            if (!theOppt.Name.Contains(' -'))
            {
                theOppt.Name.AddError(NAME_CONVENTION_VIOLATION_ERROR_MESSAGE);
                isOkToConvert = false;
            }
            */
            if (Util.IsBlank(contactRoleUsedForRolePicklistOnly.Role) || contactRoleUsedForRolePicklistOnly.Role == pl.None)
            {
                theLead.AddError('Contact Role: ' + ERROR_MSG);
                isOkToConvert = false;
            }
            if (Util.isBlank(theOppt.StageName) || theOppt.stageName == '--None--')
            {
                theOppt.StageName.AddError(ERROR_MSG);
                isOkToConvert = false;
            }
            
            /* these fields were about off the old roadnet instance, no longer needed in omnitracs i think
            //  i have added new fields to the oppt section, these are fields that are required due to validation rules
            //  so if these "showBlah" fields are set, we need to make sure the user fields in the approiate oppt fields
            if (showCorporateLicenseOpptField && Util.isBlank(theOPpt.Corporate_License__c))
            {
                theOppt.Corporate_License__c.addError(ERROR_MSG);
                isOkToConvert = false;
            }
            
            if (showLeadSourceOpptField && Util.isBlank(theOppt.LeadSource))
            {
                theOppt.LeadSource.addError(ERROR_MSG);
                isOkToConvert = false;
            }
            if (showLeadOriginOpptField && Util.isBlank(theOppt.Lead_origin__c))
            {
                theOppt.Lead_origin__c.addError(ERROR_MSG);
                isOkToConvert = false;
            }
            */
        }
        //  shannon discovered that if the reminder box on the original lead convesion is unchecked, the task fields are not required
        //  so i need to have that smae logic here
        if (areTaskFieldsRequired)
        {
            //  four task fields are required by default on the orignal converesion screen: activty, subject status and prioirty
            if (util.isBlank(theTask.type) || theTask.type == pl.None)
            {
                //  task.type has field label of Activity so need to specify that in the error message
                theTask.addError('Task Activity: ' + ERROR_MSG);
                isOkToConvert = false;
            }
            if (util.isBlank(theTask.Subject))
            {
                theTask.Subject.AddError(ERROR_MSG);
                isOkToConvert = false;
            }
            if (util.isBlank(theTask.Status) || theTask.Status == pl.None)
            {
                theTask.Status.AddError(ERROR_MSG);
                isOkToConvert = false;
            }
            if (util.isBlank(theTask.Priority) || theTask.Priority == pl.None)
            {
                theTask.Priority.addError(ERROR_MSG);
                isOkToConvert = false;
            }
        }
        return isOkToConvert;
    }
    
    private void init()
    {
        
        defineAccountPicklist();
        
        taskShouldSendNotficationEmail = false;
        showMergeContactsSection = false;
        doNotCreateOppt = false;
        isSendEmailToNewOwner = false;
        convertedStatusUserChoice = null;
        opptRecordtypeUserChoice = pl.None;
        convertedStatusUserChoice = pl.none;
        theOppt = new Opportunity();
        accountToAttachLeadTo = new Account();
        matchingContacts = new List<Contact>();
        theContactForOwnerLookupOnly = new Contact();
        contactRoleUsedForRolePicklistOnly = new OpportunityContactRole();
        productsToAdd = new List<string>();
        productsToRemove = new List<string>();
        opptStages = [Select o.SortOrder, o.MasterLabel,  o.IsWon, o.IsClosed, o.IsActive, o.Id, o.Description, 
                o.DefaultProbability From OpportunityStage o where isactive = true order by sortOrder desc];
        
        
        //  so the omnitracs convert button is overriden by the LeadConvertRedirectExtension...  it looks like all it does is prepopulate
        //  the convertedstatus field.  it does this by setting the url parameter cstatus= whatever the custom setting returns for 
        //  lead recordypes direct and old something( too lazy tolook itup). the leadconvert.jsp knows what to do with the cstatus param as my testing shows
        //  that it will prepop the status using value of 21 but not 22... i don't know HOW it knows which status to use so i am going to piggyback off of the
        //  the custom setting to 1.  get the cstatus value, 2. see if custom setting exists for it and the 3. prepopulate the field with that status
        Lead_Convert_Status__c convertStat = Lead_Convert_Status__c.getInstance(theLead.RecordTypeId);
        
        
        
        util.debug(' recordtypeid: ' + theLead.RecordTypeId + ' HADUKEN: convertstat: ' + convertStat);
        if (convertStat != null)
        {
            convertedStatusUserChoice = convertStat.status_value__c;
        }
        
              
        if (isOwnerAQueue(theLead.OwnerId))
        {
            //  you get a "validation errors while saving" immeadately on page load if the
            //  contact owner id is assigned a lead queue id
            theContactForOwnerLookupOnly.Ownerid = userInfo.getUserId();
        }
        else
        {
            theContactForOwnerLookupOnly.Ownerid = theLead.OwnerId;//  needed by record owner field
        }
        theTask = new Task();
        if (!util.isBlank(theLead.Description))
        {
            theTask.description = theLead.Description;
        }
        //  purposfully setting this to false as it has been annoying for _me_ at least to have to uncheck the box everytime a lead is converted
        theTask.IsReminderSet = true;
        areTaskFieldsRequired = true;
        theTask.ReminderDateTime = defaultReminderDateTime();
        
        Schema.DescribeSObjectResult R = Opportunity.SObjectType.getDescribe();
        List<Schema.RecordTypeInfo> recordTypeInfos = R.getRecordTypeInfos();
        //  pre pop the oppt recordt type from the users' default oppt record type id
        for (Schema.RecordTypeInfo rt : recordTypeInfos)
        {
            if (rt.isDefaultRecordTypeMapping())
            {
                opptRecordtypeUserChoice = rt.getRecordTypeId();
            }
        }
        theOppt.Name = theLead.Company + ' - ' + (theLead.QWBS_Product_Interest__c == null ? ' ' : theLead.QWBS_Product_Interest__c);
        
        theOppt.CloseDate = Date.Today().AddMonths(6);
     // theOppt.Number_of_Licensed_Vehicles__c = theLead.Fleet_Size__c;
     /* theOppt.Competitor_1__c = theLead.Competitor_1__c;
        theOppt.Competitor_2__c = theLead.Competitor_2__c;
        theOppt.Competitor_3__c = theLead.Competitor_3__c;
        theOppt.Competitor_4__c = theLead.Competitor_4__c; */
        theOppt.ups_of_total_sw__c = theLead.Software_to_Omni__c;
     // theOppt.Lead_Administrator__c  =  theLead.Lead_Admin__c;
        theOppt.Lead_Origin__c = theLead.Lead_origin__c;
        theOppt.LeadSource = theLead.leadsource;
        
        //  new field mapping from shannon's omnitracs case no [put case num here]
        theOppt.Budget__c = theLead.Budget__c;
        theOppt.need__c = theLead.need__c;
        theOppt.Authority__c = theLead.Decision_Maker_Influencer__c;
        theOppt.Timeframe_for_Purchasing__c = theLead.timeframe_to_purchase__c;
        
        //  as of 6/9/2015, we only have one stage that will pass validation rules:  sales acceptance so we want to prepop with that value
        theOppt.StageName = 'MQL';    //Added by Animesh(TCS) - Case#03826898
        
        theOppt.Budget__c = theLead.Budget__c;
        
        isOmnitracsDomesticAccount = thelead != null && thelead.lead_origin__c == 'Omnitracs Mexico';
        
        contactRoleUsedForRolePicklistOnly.Role = null;
    }
    
    private boolean isOmnitracsDomesticAccount = false; //  used in the oppt update below
    
    private DateTime defaultReminderDateTime()
    {
        DateTime dateToReturn = DateTime.newInstance(
           dateTime.now().year(),
           datetime.now().month(),
           dateTime.now().Day(),
           8,
           0,
           0);
        return dateToReturn;
        
    }
    
    private static boolean isAccountInPIcklistAlready(string accountId, List<SelectOPtion> options)
    {
        //  scroll thru account picklist seeing if the account id is present
        for (Selectoption so : options)
        {
            if (so.getValue() == accountId)
            {
                return true;
            }
        }
        return false;
    }
    
    public static Lead createTestLead(string recordtype)
    {
        //  BE ADVISED THIS WAS ADDED 2/3/2014 and it is currently only used by the lead conversion page
        Lead testLead = new Lead();
        
        testlead.company = 'Joseph Test Lead Company';
        testLead.firstname = 'JoeFakeTestLead';
        testLead.lastName = 'HutchFakeTestLead';
        testLead.Country = 'USA';
        testLead.City = 'Baltimore';
        testLead.State = 'MD';
        testlead.ownerid = userInfo.getUserId();
        testLead.QWBS_Product_Interest__c = 'RN';
        testLead.RecordtypeId = [select id from recordtype where sobjecttype = 'Lead' limit 1].id;
        database.saveResult sr = database.insert(testLead);
        return queryLead(sr.getId());
    }

    public static void sendTaskNotificationEmail(id theTaskId)
    {
        //  query the task, populate the email and sent it
        Task taskRequired = 
            [select id, whatid, whoid, subject, priority, description, createdbyid, createdby.name, ownerid, owner.email, owner.name 
            from task where id =: theTaskId];
        
        if (taskRequired.ownerid != null && taskRequired.Owner.Email != null)
        {
            //  have to query the contact and oppotrunity as the whoId and whatId does not support referncing those tables directly
            Contact contactOfTask;
            Opportunity opptOfTask;//  it is possible that this is null, if so the email body will not have the oppt name in it
            try
            {
                contactOfTask = [select id, name from Contact where id =: taskREquired.whoId];
                if (taskRequired.Whatid != null)
                {
                  opptOfTask = [select id, name from Opportunity where id =: taskRequired.whatId];
                }
            }
            catch(Exception e)
            {
                EmailClassRoadnet.sendErrorEmail(
                  'when trying to query contact and oppt in the lead conversion, had exception: ' + e.getMessage(),
                  taskRequired.id);
            }
            
            system.assertNotEquals(null, contactofTask);//  assert the task points to contact
            if (taskRequired.WhatId != null)
            {
                //  if whatid is set, it SHOULD point to an oppt so lets confirm that an oppt was queried
                system.assertNotEquals(null, opptOfTask);
            }
            
            string subject = taskRequired.subject;
            string opptNameEntry = '';
            
            if (opptOfTask != null)
            {
                opptNameEntry = 'Opportunity: ' + opptOfTask.Name  + '<br />';
            }
            
            string linkToTask = EmailClassRoadnet.createHyperLink(Util.BASE_URL + taskRequired.id, Util.BASE_URL + taskRequired.id);
            
            string commentLine = Util.isBlank(taskRequired.Description) ? '' : 'Comments: ' + taskRequired.Description;
            
            string htmlbody = 'NEW TASK' + '<br /><br />' +
               taskRequired.CreatedBy.Name + ' has assigned you the following new task: <br /> <br />' +
               'Subject: ' + taskRequired.subject + '<br />' +
               'Contact: ' + contactOfTask.Name + '<br />' +
               opptNameEntry + 
               'Priority: ' + taskRequired.Priority + '<br />' +
               commentLine + '<br /><br />' + 
                
               'For more details, click the following link: <br /><br />' +
               linkToTask; 
            
            List<string> toEmail = new LIst<string>();
            toEmail.add(taskRequired.Owner.Email);
            
            EmailClassRoadnet.SendEmailAsync(
               toEmail, null, null,
               subject,
               htmlbody,
               htmlbody,
                null );
        }
    }

    public static boolean isOwnerAQueue(id ownerId)
    {
        integer count = [select count() from QueueSobject where queueid =: OwnerId];
        return (count != 0);
    }
    
    public static ApexPages.StandardController generateController(Lead theLead)
    {
        pagereference pageRef=new pagereference('Page.BillingDetailPage');
        test.setcurrentpage(pageRef);
        //declare apexpages.standardcontroller so that we can pass it into this class's constructor
        
        return new ApexPages.standardController(theLead);
    }
    
    public static final string CREATE_ACCOUNT_PICKLIST_VALUE = 'CreateNewAccount';
    private static final string LOOKUP_NEW_ACCOUNT_PICKLIST_VALUE = 'LookupNewAccount';
    private static final string LOOKUP_NEW_ACCOUNT_PICKLIST_LABEL = 'Lookup Existing Account';
    private static final string ATTACH_TO_EXISTING = 'Attach To Existing: ';
    private static final string CREATE_NEW_CONTACT_VALUE = 'CreateNewContact';
    //this validation rule no longer exists in the omni instance: private static final string NAME_CONVENTION_VIOLATION_ERROR_MESSAGE = 'Name violates RTI required Naming Convention for an Opportunity. Use ACCOUNT NAME - PRODUCT ABBREVIATION example: FEMSA Brasil - RN, TP';
    /* no longer needed per case no 01798376
    private static final Id domConsultingDaysRtId = '01230000000jXFz';
    private static final Id domPerpetualRtId = '0123000000092rJ';
    private static final Id domPhoneActivationsRtId = '01230000001Cczf';
    private static final Id domRnUniversityRtId = '01230000000japp';
    private static final Id domRnaRtId = '012300000009BUi';
    private static final Id domSpecialProjectsRtId = '01230000000jXsW';
    private static final Id domTelematicsRtId = '01230000000huxf';
    private static final Id domTermRtId = '01230000001DFG8';
    private static final Id domUpgradeRtId = '01230000001D9sQ';
    private static final id intlPerpRtId = '0123000000096f2';
    */
   
    private static Lead queryLead(id leadId)
    {
        return [select id, recordtypeid, name, status, firstname, lastname, ownerid, Segment__c, QWBS_Product_Interest__c, Fleet_Size__c, 
            budget__c, need__c, Decision_Maker_Influencer__c, timeframe_to_purchase__c, self_reported_fleet_size__c, rfc_id__c,
            Lead_Origin__c, LeadSource, Software_to_Omni__c, Company, isConverted, ConvertedContactId, description, NAICS_Code__c, Country  from Lead where id =: leadId];
    }
    
    public class myException extends Exception{}
    
}