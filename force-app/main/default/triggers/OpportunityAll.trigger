/*********************************************************************
Name    : OpportunityAll
Author  : Shruti Karn
Date    : 19 July 2011

Usage   : This trigger will :
          1. Update all the associated Opportunity products of closed Opportunity.
   
Modified By         : Avinash Kaltari
Modification Date   : 04 Nov, 2011
Modification        : Merged Trigger code on Opportunity for PartnerScorecard
                      functionality (after insert, after update, after delete)

*********************************************************************/

trigger OpportunityAll on Opportunity (after update, after insert, after delete,
                                       before insert, before update) 
{
     /*BypassTriggerUtility u = new BypassTriggerUtility();  
     if (u.isTriggerBypassed()) {
         return;
     }
    
    if(Trigger.isAfter && Trigger.isUpdate)
    {
        OpportunityUtils.updateOLI(Trigger.newMap, trigger.new);
         
    }
    if (Trigger.isAfter && Trigger.isDelete)
     {
        
        OpportunityUtils.updateCampaignTvwoField(trigger.old, trigger.new, true);  //  tvwo = total value win opportunities
     }
     
     
     if(Trigger.isBefore && !checkRecursive.runOnce())
     {
         System.debug('Recursion detected before. Exiting.');
         return;           
     }
     if(Trigger.isAfter && !checkRecursiveAfter.runOnce())
     {
         System.debug('Recursion detected after. Exiting.');
         return;           
     }
     
     if (Trigger.isAfter && Trigger.isUpdate)
     {
         //  BE ADVISED that this code snippet was in the above isAfter and isUpdate check where the updateOli is called, however noticed 
         //  that that emthod is called before the recusricion check is done,  i checked revision control and noticed that is how that method was always called
         //  i cannot confirm/deny that the method needs to be above the recursvsion check but i amd gong to leave it there and just place the oppt roadnet trigger
         //  method here
        try
        {
            OpportunityUtils.createPrimaryContactRole(Trigger.Old, Trigger.new);//  added by joseph hutchins 3/13/2015 from the opproutnityAfterTriggerRoadnet
        }
        catch(Exception e)
        {
            //  this is causing too many soql queries, but we still whatever to call this to finish its transcation
        }
        OpportunityUtils.checkForLostStageAndUpdateOpptContacts(Trigger.Old, Trigger.new);  //  added by joseph hutchins 3/13/2015 from the opproutnityAfterTriggerRoadnet
     
     }
     
    if(Trigger.isAfter && Trigger.isUpdate)
    {
    
/***  START - Trigger Code by Shruti Karn (after update) ***/
        /*list<Id> lstOppId = new list<Id>();
        for(Opportunity opp : Trigger.New)
        {
            if(opp.IsClosed)
                lstOppId.add(opp.Id);
        }
        OpportunityUtils.UpdateOppProduct(lstOppId);                        
/***  END - Trigger Code by Shruti Karn  ***/
        
/***  START - Trigger Code by Mark David De Chavez (after update) ***/
        //OpportunityUtils.updateOLI(Trigger.newMap, trigger.new);            
/***  END - Trigger Code by Mark David De Chavez  ***/
     
        
/*** START - Trigger Code by Avinash Kaltari for Partner Scorecard (after update) ***/
/** Commented out by Pratyush 
        List<Id> lstDraftAccountId = new List<Id>();
        List<Contact> lstContact = new list<Contact>();
        List<User> lstUser = new list<User>();
        List<Id> lstId = new List<Id>();
        
        for(Opportunity opp : Trigger.New)
        {
            if(opp.StageName == 'Shipped')
            {
                lstId.add(opp.OwnerId);
                
//Add Accounts, that were referenced by Opportunity earlier, to update their Partner Scorecards after a opportunity is updated
                if(Trigger.isUpdate && Trigger.OldMap.get(opp.id) != null && opp.OwnerId != Trigger.OldMap.get(opp.id).OwnerId)
                    lstId.add(Trigger.OldMap.get(opp.id).OwnerId);
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
     **/
/***  END - Trigger Code by Avinash Kaltari  (for after update) ***/
    /*}




/*** START - Trigger Code by Avinash Kaltari for Partner Scorecard (after insert, after delete) ***/
/** Commented out by Pratyush 
    if(Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate || Trigger.isDelete))
    {
        List<Id> lstDraftAccountId = new List<Id>();
        List<Contact> lstContact = new list<Contact>();
        List<User> lstUser = new list<User>();
        List<Id> lstId = new List<Id>();
        
        
        if(Trigger.isDelete)
        {
            for(Opportunity opp : Trigger.Old)
            {
                if(opp.StageName == 'Shipped')
                {
                    lstId.add(opp.OwnerId);
                }
            }
        }
        
        else
        {
            for(Opportunity opp : Trigger.New)
            {
                if(opp.StageName == 'Shipped')
                {
                    lstId.add(opp.OwnerId);
                    
//Add Accounts, that were referenced by Opportunity earlier, to update their Partner Scorecards after a opportunity is updated
                    if(Trigger.isUpdate && Trigger.OldMap.get(opp.id) != null && opp.OwnerId != Trigger.OldMap.get(opp.id).OwnerId)
                        lstId.add(Trigger.OldMap.get(opp.id).OwnerId);
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
 **/  
   
/***  END - Trigger Code by Avinash Kaltari  (for after insert and after delete) ***/

    /** Code Added by Pratyush to update the Lead_Owner_Role__c field **/ 
       /*if(Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)) {
        List<Id> lstOwnerId = new List<Id>();
        List<Id> lstAcctId = new List<Id>();
        
        OpportunityUtils.updateOpptAmountMc(Trigger.new);
        
        //  ***** moved from roadnet OpportunityTriggerRoadnet.Trigger
        //  this prevent an oppts stage name from boing to negoitate or a lost stage if a primary contact role is not assigned
        //  this can run on insert or update
        try
        {
            OpportunityUtils.checkForPrimaryContactRolesIfStageNegotiateLost(Trigger.new, Trigger.isInsert);
        }
        catch(Exception e)
        {
            EmailClassRoadnet.SendErrorEmail('checkForPrimaryContactRolesIfStageNegotiateLost failed due to: ' + e.getMessage(), null);
        }
        
        OpportunityUtils.assignSalesTeamManagerAndDarManager(Trigger.new);
                
        for(Integer i = 0; i < Trigger.new.size(); i++)
        {
            lstOwnerId.add(Trigger.new[i].ownerId); 
            lstAcctId.add(Trigger.new[i].AccountId); 
            //Changes for CR 01205363
            //if(trigger.new[i].Lead_Source_Most_Recent__c == null &&  trigger.new[i].LeadSource != null )
            //{
            //    trigger.new[i].Lead_Source_Most_Recent__c = trigger.new[i].LeadSource;
            //}
            //if(trigger.new[i].Lead_Source_Most_Recent__c != null &&  (trigger.new[i].LeadSource == null || trigger.new[i].Lead_Source_Update_Date__c < (System.TODAY()-365)) )
            //{
            //    trigger.new[i].LeadSource = trigger.new[i].Lead_Source_Most_Recent__c;
            //}
            
            //  so i have code that can run on insert and update and then code that only runs on either
            {//  this code can run on both insert and update, idented to make it easier to read
                //  method handles both updates and inserts
                //  placing in a try becuase alot cna go wrong in the method and dont want to stop oppt processing from continuing
                try
                {
                    OpportunityUtils.assignGeoRegionAndOpptCountryIfNeeded(Trigger.new[i]);
                }
                catch(Exception e)
                {
                    //  i can remove this evenutally, but if it fails, i need to know why to fix it in the future
                    EmailClassRoadnet.sendErrorEmail('Failed to assign oppt geo region due to ' + e.getMessage(), Trigger.new[i].id);
                }
                if (Trigger.new[i].Solution__c != null)
                {
                    OpportunityUtils.parseOpportunitySolutions(Trigger.new[i].Solution__c);
                }
            }
           
            //  OpportunityTriggerRoadnet code
            if (Trigger.isBefore && Trigger.isInsert)
            {
                //  check that if the user is cloning an oppt, the Terms_Requested_Status__c field is blank, we dont want it to clone over
                if (Trigger.new[i].Terms_Requested_Status__c != null)
                {
                    Trigger.new[i].Terms_Requested_Status__c.addError(OpportunityUtils.OPPT_CLONE_FIELD_ERROR);
                }
                if (Trigger.new[i].Terms_Requested__c)
                {
                    Trigger.new[i].Terms_Requested__c.addError(OpportunityUtils.OPPT_CLONE_FIELD_ERROR);
                }
                //  jane has asked on 3/6/2014 in regards to sf issue: https://na1.salesforce.com/a0W3000001H34kX 
                //  could be cleared out for new/cloned opts
                if (Trigger.new[i].Se_Approval__c == true)// checkbox field so it should false if cloning
                {
                    Trigger.new[i].Se_Approval__c = false;    
                }
                if (Trigger.new[i].current_se__c != null)
                {
                    Trigger.new[i].current_se__c = null;
                }
                
            }
            //  OpportunityTriggerRoadnet code
            if (Trigger.isBefore && Trigger.isUpdate)
            {
                
                //  here we can check if the stage name has changed and if so, ding the user that they cant change it
                if (Trigger.new[i].stagename != null &&
                    Trigger.old[i].StageName != Trigger.new[i].STageName && Trigger.new[i].Stagename == 'Closed - Won')
                {
                    //  check if the user is allowed to set the field
                  
                    //  if the oppt contains Project Change in its title, its a Project Change oppt and we want to set the dp to p date 
                    //  sf issue for info located here https://na1.salesforce.com/a0W3000000DtWAk
                    if (Trigger.new[i].Name != null && Trigger.new[i].Name.contains('Project Change') && Trigger.new[i].deposit_pending_to_pending_date__c == null)
                    {
                        Trigger.new[i].Deposit_Pending_To_Pending_Date__c = date.today();
                    }
                }
            }
           
        }                               
        
        
        Map<Id, User> mapUser = new Map<Id, User>([Select Id, UserRoleId,ProfileId from User 
                                      where id in :lstOwnerId limit :lstOwnerId.size()]);
      
        /*****************************************************
        *To update lead source most recent field*/   
        //Map<Id,Account> mapOfAccts = new Map<Id,Account> ([select id, Lead_Source_Most_Recent__c from Account where id IN:lstAcctId limit 100]);  
        //Set<String> listOfClosedStatusToBeConsidered =  new Set<String>(); 
        //try{                           
        //listOfClosedStatusToBeConsidered.addAll(Global_Variable__c.getInstance('Excluded_Closed_Opp_Status').value__c.split(';'));
        //
        //for(Opportunity o: Trigger.new) {
        //    User tmpUser = mapUser.get(o.ownerId);
        //    if(null != tmpUser) {
        //        o.Opportunity_Owner_Role__c = tmpUser.userRoleId;
        //        o.Opportunity_Owner_Profile__c= tmpUser.ProfileId;
        //    }
        //    else {
        //        o.Opportunity_Owner_Role__c = '';
        //        o.Opportunity_Owner_Profile__c= '';
        //    }
        //    if(o.IsClosed == false  || listOfClosedStatusToBeConsidered.contains(o.StageName))
        //    {
        //        if(mapOfAccts.containsKey(o.accountId))
        //        {
        //            if(mapOfAccts.get(o.accountId).Lead_Source_Most_Recent__c != null)
        //            o.Lead_Source_Most_Recent__c = mapOfAccts.get(o.accountId).Lead_Source_Most_Recent__c;
        //        }
        //    }
        //}   
        //}
        //catch(exception e)
        //{
        //    System.debug('*************** exception:' + e.getMessage());
        //}                                                            
    /*}
   
    /** END - Code by Pratyush to update Opportunity_Owner_Role__c field **/
    
    //  OpportunityTriggerRoadnet code added by joseph hutchins 3/13/2015
    /*if (Trigger.isInsert && Trigger.isAfter)
    {
        try
        {
            OpportunityUtils.createPrimaryContactRole(Trigger.new );
        }
        catch(Exception e )
        {
            //  cause too many soql queries on qutoe edits, so if it fails, let the calling transaction to continue
        }
    }
    
    /** Code added as a part of 19th April CR 84973  **/
    
    /*if(trigger.isAfter && trigger.isUpdate) {
    
    List<String> lstOpportunityId = new List<String>();
    List<OpportunityLineItem> lstOpportunityLineItem = new List<OpportunityLineItem>();
    Map<Id, Opportunity> mapOfClosedOpportunities =  new  Map<Id, Opportunity>();
    List<Id> lstAcctids =  new List<Id>();
    
    for(Integer i=0;i<trigger.new.size();i++){
        if(trigger.new[i].ownerId != trigger.old[i].ownerId || test.IsRunningTest()){
            lstOpportunityId.add(trigger.new[i].id);
        }
        
        //Change for CR 01205364
        if(trigger.new[i].stageName != trigger.old[i].stageName){
            if(OpportunityUtils.checkIfLostOpp(trigger.new[i]))
            {
            mapOfClosedOpportunities.put(trigger.new[i].id,trigger.new[i]);
            lstAcctids.add(trigger.new[i].accountId);             
            }
        }
    }
    //Change for CR 01205364
    if(!mapOfClosedOpportunities.isEmpty())
    OpportunityUtils.handleOpportunityClosure(mapOfClosedOpportunities,lstAcctids); 
    
    if(!lstOpportunityId.isEmpty()){
        Map<String, OpportunityLineItem> mapOpportunityLineItem = new Map<String, OpportunityLineItem>([Select 
                                                                                                              Opportunity_Owner__c,
                                                                                                              OpportunityId
                                                                                                        From 
                                                                                                              OpportunityLineItem
                                                                                                        where 
                                                                                                             OpportunityId in :lstOpportunityId
                                                                                                        Limit 50000]);
        for(String oppLineItemId:mapOpportunityLineItem.keySet()){
            mapOpportunityLineItem.get(oppLineItemId).Opportunity_Owner__c = trigger.newMap.get(mapOpportunityLineItem.get(oppLineItemId).OpportunityId).ownerId;        
            lstOpportunityLineItem.add(mapOpportunityLineItem.get(oppLineItemId));
        }
        try{
            if(!lstOpportunityLineItem.isEmpty()){
                update lstOpportunityLineItem;    
            }
        }
        catch(Exception e){
            system.debug('Exception occured:'+ e.getMessage());    
        }
    }
    
    //  this should be the last thing that is done since the logic is to move from the oppt after trigger to the campagin before update trigger
    if (Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate))//  all trigger actions will fire this
     {
        
        OpportunityUtils.updateCampaignTvwoField(trigger.old, trigger.new, false);  //  tvwo = total value win opportunities
     }
     
}*/
       
}