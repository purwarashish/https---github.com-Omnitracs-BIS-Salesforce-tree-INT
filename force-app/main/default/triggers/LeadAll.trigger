/**
Author : Avinash Kaltari, Salesforce.com Developer, TCS.

Description: Trigger on Lead, to Update the PartnerScorecard record associated with its Account.

Events : After insert, After update, After delete

*/

trigger LeadAll on Lead (after insert, after update, after delete,before insert,before update) 
{
/*
    BypassTriggerUtility u = new BypassTriggerUtility();  
     if (u.isTriggerBypassed()) {
         return;
     }
    
// Avinash's Code starts
    List<Id> lstDraftAccountId = new List<Id>();
    List<Contact> lstContact = new list<Contact>();
    List<User> lstUser = new list<User>();
    List<Id> lstId = new List<Id>();
    
    private User loggedInUser
    {
        get
        {
            if (loggedInUser == null)
            {
                util.debug('loggedInuser was null, querying now with id: ' + userInfo.getUserId());
                loggedInUser = [select id, name, username, Bypass_Workflows__c from user where id =: userinfo.getUserId()];
            }
            if (loggedInUser != null)
            {
                util.debug('logged in user queried.  here are the values: id: ' + loggedInUser.id + 
                    ' name: ' + loggedInuser.name + 
                    ' username: ' + loggedInuser.UserName);
            }
            else
            {
                util.debug('logged in user was null...');
            }
            return loggedInUser;
        }
    }
    private boolean isMarketoUser
    {
        get
        {
            util.debug('isMarketoUser getter called: ' + isMarketoUser);
            
           if (loggedInUser != null && loggedInUser.UserName != null)
           {
                util.debug('loggedInuser not null, and user name not null value of isMarketoUser: ' + loggedInUser.UserName.Contains('marketo'));
                return loggedInUser.UserName.Contains('marketo');
           }
           else
           {
               return false;
           }    
        }
    }
    private boolean isUserAutomationOrIntegration
    {
        get
        {
            if (loggedInuser != null && loggedInuser.Username != null)
            {
                boolean isAutoOrInternal = loggedInUser.UserName.contains('internalautomation') ||
                    loggedInUser.UserName.Contains('integrat');
                    
                util.debug('loggedInUser not null, isUserAutomationOrIntegration bool: ' + isAutoOrInternal);
                return isAutoOrInternal;
            }
            else
            {
                return false;
            }
        }
    }
    private List<Country_And_Country_Code__c> allCountries
    {
        get
        {
            if (allCountries == null)
            {
                allCountries = [select name, ISO_Code_2__c, Region__c from Country_And_Country_Code__c];       
            }
            return allCountries;
        }
    }
    List<Lead> lstUpdatedLeads;
    
    /** Code Added by Pratyush to update the Lead_Owner_Role__c field **/ /*
    
    if(Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)) {
        List<Id> lstOwnerId = new List<Id>();
        List<Lead> leadsToPopulateDataShare = new List<Lead>(); 
        for(Integer i = 0; i < Trigger.new.size(); i++) {
            
            //Changes for CR 01205363
            if(trigger.new[i].Lead_Source_Most_Recent__c == null &&  trigger.new[i].LeadSource != null )
            {
                trigger.new[i].Lead_Source_Most_Recent__c = trigger.new[i].LeadSource;
            }
           /* Commented as per Case - # 01978790
           if(trigger.new[i].Lead_Source_Most_Recent__c != null &&  (trigger.new[i].LeadSource == null || trigger.new[i].Lead_Source_Update_Date__c < (System.TODAY()-365)) )
            {
                trigger.new[i].LeadSource = trigger.new[i].Lead_Source_Most_Recent__c;
            }*/
            /*
            LeadUtils.MapStatusFromLifeCycleStatus(Trigger.new[i]);
            //  end code added by joseph hutchins 11/19/2014
            
            lstOwnerId.add(Trigger.new[i].ownerId);
            
            //Changes for CR 01205396
            if(Trigger.isUpdate)
            {
                util.debug('isUpdate lead trigger about to run...');
                if(trigger.new[i].Referral_Account__c != trigger.old[i].Referral_Account__c && trigger.new[i].Referral_Account__c != null)     
                {
                leadsToPopulateDataShare.add(trigger.new[i]);
                }
                //  code added by joseph hutchins 11/19/2014
                //  we only want this to fire if the country changed since this adds a query row to num of max queries that can be used by the trigger
                if (!isMarketoUser &&
                    !isUserAutomationOrIntegration &&
                    Trigger.old[i].Country != Trigger.new[i].Country &&
                    !Util.isBlank(Trigger.New[i].Country))
                {
                    util.debug('about to run checkLeadCityStateCountryAndAssignRegion.... ');
                    LeadUtils.checkLeadCityStateCountryAndAssignRegion(Trigger.new[i], allCountries);
                }    
                
                LeadUtils.MapStatusFromLifeCycleStatus(Trigger.new[i]);
                LeadUtils.updateHiddenLeadSourceFields(Trigger.new[i], loggedInUser.Bypass_Workflows__c);//  added by joseph hutchins 11/19/2014 after seeing that workflow was not firing in the correct order to populate the 3 hidden lead source fields
                //  end code added by joseph hutchins 11/19/2014
                
            }
            else if(Trigger.isInsert)
            {
                util.debug('isInsert lead triger about to run...');
                
                //  code added by joseph hutchins 11/19/2014
                if (!isMarketoUser && !isUserAutomationOrIntegration)//  we do not check country for marketo users on lead creations
                {
                    
                    if ( Util.isBlank(Trigger.new[i].Country))
                    {
                        util.debug('lead trigger is blank with value: ' + trigger.new[i].country);
                        Trigger.new[i].Country.addError('Country must be specified');
                    }
                    else
                    {
                        util.debug('lead country contains value: ' + trigger.new[i].country + ' about to call checkLeadCityStateCountryAndAssignRegion... ');
                        LeadUtils.checkLeadCityStateCountryAndAssignRegion(Trigger.new[i], allCountries);
                    }
                }
                //  end code added by joseph hutchins 11/19/2014

                if(trigger.new[i].Referral_Account__c != null)
                leadsToPopulateDataShare.add(trigger.new[i]);
            }        
        }
        //Changes for CR 01205396 
        if(!leadsToPopulateDataShare.isEmpty())
        {
            LeadUtils.populateDataSharePartners(leadsToPopulateDataShare);
        }                              
        
        Map<Id, User> mapUser = new Map<Id, User>([Select Id, UserRoleId from User 
                                      where id in :lstOwnerId limit :lstOwnerId.size()]);
        for(Integer i = 0; i < Trigger.new.size(); i++) {
            User tmpUser = mapUser.get(Trigger.new[i].ownerId);
            if(null != tmpUser) {
                Trigger.new[i].Lead_Owner_Role__c = tmpUser.userRoleId;
            }
            else {
                Trigger.new[i].Lead_Owner_Role__c = '';
            }
        }      
        
        LeadUtils.fetchAccountName(Trigger.New);
        LeadUtils.updateLeadMetaData(Trigger.new,Trigger.oldMap);
        LeadUtils.updateReferralPartnerIdFromAccountToLead(Trigger.new,Trigger.oldMap);
        //Added by Anand to populate the Company Lead Created By field
        LeadUtils.populateCreatedByReseller(Trigger.New);
        //  Added by joseph hutchins 10/22/2014, this assigns values to the sic fields from the sic table if the sic code is present on th elead
        LeadUtils.updateSicFields(Trigger.New);
        // Code added by Pintoo as per CR 105284 to validate State field on Lead
         LeadUtils.getStateCode(trigger.new);

    }
    /** END - Code by Pratyush to update Opportunity_Owner_Role__c field **/
    
    //Modified to send email to lead owner(case #46059)/*
      /*  if(trigger.isUpdate){
            if(SendEmailLead.isExecuted == false 
               && LeadOwnerAssignmentController.isSendEmail ==true)
               {
                system.debug('isExecuted '+SendEmailLead.isExecuted);
                SendEmailLead.DMLLead(trigger.new);
               }
        }
    List<lead> lstDraftLead = new List<Lead>();
    
    // Code Added By Pintoo as per CR 68311 to transfer Competitive Knowledge Object to Account on Lead Conversion
    if (trigger.isAfter && trigger.IsUpdate)
    {
        Map<String, String> mapLeadIdToConvertedAccountId = new  Map<String, String>();    
        for(Integer i=0; i < trigger.new.size(); i++){
            if(trigger.new[i].IsConverted == true && trigger.new[i].IsConverted != trigger.old[i].IsConverted)
            { 
            System.debug('--------------------------------------Inside If --------------------------');
            mapLeadIdToConvertedAccountId.put(trigger.new[i].id,trigger.new[i].ConvertedAccountId);
            }
        }
    
        List<Competitive_Knowledge__c> CompetitiveKnowObject = new List<Competitive_Knowledge__c>([Select
                                  id
                              from 
                                  Competitive_Knowledge__c
                              where
                                    Lead__c IN: trigger.newMap.keySet() limit 1]);
                                    
        List<X3rd_Party_Contract_Service__c> X3rdParty = new List<X3rd_Party_Contract_Service__c>([Select
                                  id
                              from 
                                  X3rd_Party_Contract_Service__c
                              where
                                    Lead__c IN: trigger.newMap.keySet() limit 1]);                                
                                    
        if(!mapLeadIdToConvertedAccountId.isEmpty() && (!CompetitiveKnowObject.isEmpty()|| !X3rdParty.isEmpty()))
        {
             LeadUtils.transferRecsOnLeadConvert(mapLeadIdToConvertedAccountId);
        }
    
        LeadUtils.checkIfNeedsToFireAssignmentRules(trigger.new);
    }

/** system.debug('#### bln update, ser :'+PartnerScorecardHelper.blnUpdateAssignedDate+';'+PartnerScorecardHelper.blnUpdateScorecard);
    if(PartnerScorecardHelper.blnUpdateAssignedDate && PartnerScorecardHelper.blnUpdateScorecard)
    {
        if(lstUpdatedLeads != null && lstUpdatedLeads.size() > 0)
        {
            if(trigger.isBefore)
            {
                    if(Trigger.isInsert)
                    {
                        for(Lead l : lstUpdatedLeads)
                        {
                            l.Assigned_Date__c = System.TODAY();
                            lstDraftLead.add(l);
                        }
                    }
                
                else if(Trigger.isUpdate)
                {
                    for(Lead l : lstUpdatedLeads)
                    {
                        if(l.isConverted == false && l.OwnerId != Trigger.OldMap.get(l.id).OwnerId)
                        {
                            l.Assigned_Date__c = System.TODAY();
                            lstDraftLead.add(l);
                        }
                    }
                }
            }
        }
        
        if(lstDraftLead.size() > 0)
        {
            PartnerScorecardHelper.blnUpdateAssignedDate = false;
    system.debug('#### before update stmt; bln update value :'+PartnerScorecardHelper.blnUpdateAssignedDate);
        // SK   update lstDraftLead;
        }
            
            
        
        if(Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate || Trigger.isDelete))
        {
system.debug('#### entered scorecard code');
            if(Trigger.isDelete)
            {
                for(Lead l : Trigger.Old)
                {
                    lstId.add(l.OwnerId);
                }
            }
            else
            {
                for(Lead l : Trigger.New)
                {
                    lstId.add(l.OwnerId);
                    
    //Add Accounts, that were referenced by Lead earlier, to update their Partner Scorecards after a lead is updated
                    if(Trigger.isUpdate && Trigger.OldMap.get(l.id) != null && (l.OwnerId != Trigger.OldMap.get(l.id).OwnerId || l.Assigned_Date__c != Trigger.OldMap.get(l.id).Assigned_Date__c))
                    {
                        lstId.add(Trigger.OldMap.get(l.id).OwnerId);
system.debug('#### added');
                    }
                }
            }
            
            lstUser = [select name, ContactId from user where id IN :lstId limit 50000];        
            lstId.clear();
            for (User u : lstUser)
            {
                lstId.add(u.ContactId);
            }
            
            lstContact = [select name, Account.RecordTypeId, AccountId from Contact where id IN :lstId limit 50000];
            
            for (Contact con : lstContact)
            {
                if(con.AccountId != null)
                    lstDraftAccountId.add(con.AccountId);
            }
            
            if(lstDraftAccountId.size() > 0)
            {
                List<Partner_Scorecard__c> lstDraftScorecard = [select name, Account__c, Account__r.Id from Partner_Scorecard__c where Account__r.Id IN :lstDraftAccountId AND Current_Scorecard__c = true limit 1];
                if (lstDraftScorecard != null && lstDraftScorecard.size() > 0)
                    update lstDraftScorecard;
            }
        }
    }
  */
// Avinash's Code Ends




}