Public without sharing Class AllLeadTriggerClass{

/*
Author:Arindam Laik, TCS
Date:03/18/2015
Purpose:Separate business logic from trigger, Code Cleanup/OPtimization and follow saleforce best practices
Item Description:
@ Separate business logic from 'updatOwnerInfo', 'TrigLeadOwnerId' trigger and consolidated togather in a single method
@ Used Map instead of List where ever possible
@ Removed nested 'for' loop
*/ 
  private static final String STRING_LEAD_REASSIGNMENT_ROLE_INSIDE_SALES_REP = 'Inside Sales Rep';
  private static final String STRING_LEAD_REASSIGNMENT_ROLE_FIELD_SALES_REP = 'Field Sales Rep'; 
  private static final String STRING_GROUP_PREFIX = '00G';
  private static final String STRING_PARTNER_QUEUE = 'Partner Queue';
  private static final String STRING_MASTER_PARTNER_QUEUE = 'Master Partner Queue';
  public static Map<String,String> groupAccountIdMap;
    
  public static void  assignRankingCargoType(List<Lead> leads,Map<id,Lead> mapTriggerOld)
    {
      // cargo type is a multi select picklist meaning it can contain no or all values
      // we need to split out the cargo type selections that are selected, compare them and 
      // pick out the cargo type with the highest value
      //Get CargoType and its ranking value from custom setting.
        List<AccountRankingCargoType__c> lstRankingCargoType = AccountRankingCargoType__c.getall().values();
        map<String,Decimal> mapCargoNameAndRanking = new map<String,Decimal>();
        for(AccountRankingCargoType__c ObjAccRankingValue : lstRankingCargoType)
        {
            mapCargoNameAndRanking.put(ObjAccRankingValue.name,ObjAccRankingValue.Ranking__c);
        }
        for (Lead l : leads)
        {
            List<string> cargoTypesSplitOut = Util.parseString(l.Cargo_Type__c);
            if (cargoTypesSplitOUt != null && cargoTypesSplitOut.size() > 0)
            {
              //  assume the first cargo type has highest value, and compare to the others int he list
              string highestValueCargoType = cargoTypesSplitOut[0];
              
              //  if other has highest value, assign that as highest value
              for (integer i = 0; i < cargoTypesSplitOut.size(); i++)
              {
                if(mapCargoNameAndRanking.get(cargoTypesSplitOut[i]) > mapCargoNameAndRanking.get(highestValueCargoType))
                {
                  highestValueCargoType = cargoTypesSplitOut[i];
                }
              }
           /* if (!util.isblank(highestValueCargoType))
              {
                  l.Ranking_Cargo_Type__c = mapCargoNameAndRanking.get(highestValueCargoType);
              }
              else
              {
                l.Ranking_Cargo_Type__c = 0;//  by default it is 0
              } */
            }
        /*  else
            {
              l.Ranking_Cargo_Type__c = 0;//  by default it is 0
            } */
          }
    }
    
  public static void  assignRankingCargoTypeIndustry(List<Lead> leads,Map<id,Lead> mapTriggerOld)
    {
      // cargo type is a multi select picklist meaning it can contain no or all values
      // we need to split out the cargo type selections that are selected, compare them and 
      // pick out the cargo type with the highest value
      //Get CargoType and its ranking value from custom setting.
        List<AccountRankingCargoTypeIndustry__c> lstRankingCargoType = AccountRankingCargoTypeIndustry__c.getall().values();
        map<String,Decimal> mapCargoNameAndRanking = new map<String,Decimal>();
        for(AccountRankingCargoTypeIndustry__c ObjAccRankingValue : lstRankingCargoType)
        {
            mapCargoNameAndRanking.put(ObjAccRankingValue.name,ObjAccRankingValue.Ranking__c);
        }
        for (Lead l : leads)
        {
            List<string> cargoTypesSplitOut = Util.parseString(l.Cargo_Type_industry__c);
            if (cargoTypesSplitOUt != null && cargoTypesSplitOut.size() > 0)
            {
              //  assume the first cargo type has highest value, and compare to the others int he list
              string highestValueCargoType = cargoTypesSplitOut[0];
              
              //  if other has highest value, assign that as highest value
              for (integer i = 0; i < cargoTypesSplitOut.size(); i++)
              {
                if(mapCargoNameAndRanking.get(cargoTypesSplitOut[i]) > mapCargoNameAndRanking.get(highestValueCargoType))
                {
                  highestValueCargoType = cargoTypesSplitOut[i];
                }
              }
           /* if (!util.isblank(highestValueCargoType))
              {
                  l.Ranking_Cargo_Type_industry__c = mapCargoNameAndRanking.get(highestValueCargoType);
              }
              else
              {
                l.Ranking_Cargo_Type_industry__c = 0;//  by default it is 0
              } */
            }
         /* else
            {
              l.Ranking_Cargo_Type_industry__c = 0;//  by default it is 0
            } */
          }
    }
    
  public static void updatOwnerInfoMethod(List<Lead> listofLead, Map<id,Lead> oldMapofLead) 
  {
  try{
    string userType;
    Set<Id> groupdIds = new Set<Id>();
    Map<Id,Group> mapOfGroups = new Map<Id,Group>();
    List<PRMAcctQueueCombination__c> partnerQueues = PRMAcctQueueCombination__c.getall().values(); // get list of partner queues(custom setting).
    Map<Id,User> userMap =new Map<Id,User>( [SELECT u.id ,u.Title , u.Lead_Reassignment_Role__c, u.userType ,u.accountID FROM User u WHERE (u.Lead_Reassignment_Role__c in ('Inside Sales Rep' ,'Field Sales Rep')
                                             OR u.userType Like'%Partner%') AND IsActive = true Limit 50000]);
                                       
    Map<String,PRMAcctQueueCombination__c> partnerQueuesMap = new Map<String,PRMAcctQueueCombination__c>(); //Key will be AccountId
    Map<String,PRMAcctQueueCombination__c> CurrentQueuesMap = new Map<String,PRMAcctQueueCombination__c>(); //key will be groupId
    
    if(partnerQueues != null && !partnerQueues.isEmpty())
    {    
        for(PRMAcctQueueCombination__c objPartnerQueue:partnerQueues)
        { 
           if(objPartnerQueue.AccountID__c != null)
               partnerQueuesMap.put(objPartnerQueue.AccountID__c,objPartnerQueue);
           //split the queue id based on comma seperator
           if(objPartnerQueue.QueueIds__c != null) 
           {
               String[] queueIds=objPartnerQueue.QueueIds__c.split(',');
               //if there is no comma, then the string defined is just returned
               CurrentQueuesMap.put(queueIds[0],objPartnerQueue);
           }
        }
    }                                                                                          
    // get and classify the running user
    if(Trigger.isInsert)  //filter criteria added as 'UserType' is being used only during insertion
    {      
        if(userInfo.getUserType().containsIgnoreCase('Partner') )
        {
           userType = 'Partner';
        }
        else
        {
           User cu = [select u.Lead_Reassignment_Role__c from User u where u.ID =: userInfo.getUserID()];
            
           if (cu.Lead_Reassignment_Role__c == STRING_LEAD_REASSIGNMENT_ROLE_INSIDE_SALES_REP)
           {
               userType = 'ISR';
           }
           else if (cu.Lead_Reassignment_Role__c == STRING_LEAD_REASSIGNMENT_ROLE_FIELD_SALES_REP)
           {
               userType = 'FSR';
           }
           else
           {
               userType = 'Mktg';
           }
        }   
    }
    Set<Id> setLeadownerId = new Set<Id>();
    Map<Id, User> mapOwnerAccount = new Map<Id, User>();
    //Updated by Anand, 4/11/2013 to avoid a query inside the for loop.          
    for (Lead newLead:listofLead)
    {
        String OwnerId = newLead.ownerId;

            if(OwnerID.startsWith('00G'))
            {
              newLead.Record_Owner__c = null;      //Change record Owner As per 'TrigLeadOwnerId' Trigger
              //added filter as we no need to fetch group name if lead owner has not changed 
              if(Trigger.isInsert || (Trigger.isupdate && (newLead.ownerId != oldMapofLead.get(newLead.id).ownerId)))
                  groupdIds.add(OwnerId);
            }
            else  
            {
              newLead.Record_Owner__c = ownerId ;  //Change record Owner As per 'TrigLeadOwnerId' Trigger
            
              if(Trigger.isInsert || (Trigger.isupdate && (newLead.ownerId != oldMapofLead.get(newLead.id).ownerId)))
                  setLeadownerId.add(newLead.ownerId);
            }    
    }      
    if(!groupdIds.isEmpty())    
        mapOfGroups = new Map<Id,Group>([select grp.Name from Group grp where grp.ID IN: groupdIds LIMIT 1000]); //Get the Group Name of corresponding groups
    if(!setLeadownerId.isEmpty())
        mapOwnerAccount = new Map<Id, User>([select id, contactId, contact.AccountId from User where id IN: setLeadOwnerId limit 50000]) ;
    for (lead newLead:listofLead)
    {
        Boolean ownerChange = false;
       
        if(trigger.isUpdate)
        {
          lead oldLead = oldMapofLead.get(newLead.id);
          if (oldLead.ownerID != newLead.OwnerID)
          {
            ownerChange = true;
            // get the prior owner information.      
         // newLead.IF_prior_owner_type__c = oldlead.IF_current_Owner_Type__c;
         // newlead.IF_prior_queue_name__c = oldLead.IF_current_queue_name__c;
         // newLead.IF_Prior_Queue_ISPartner__c = oldLead.IF_current_Queue_ISPartner__c;
            // clear out the current owner information
            newlead.IF_current_owner_type__c = null;
         // newLead.IF_Current_Queue_Name__c = null;
         // newLead.IF_Current_Queue_ISPartner__c = false;
  
          }
          // check to determine if need to reset the marketing cycle.
          // will restart the marketing cycle under the following condition.
          // 1. record goes from nurture / rejected to MI, or MQL
          // 2. record goes from MQL to MI
        
     /*   if(newLead.IF_Marketing_Cycle__c == null)
          {
            newLead.IF_Marketing_Cycle__c = 0;
          }           
          if(oldLead.Status == LeadStatus__c.getInstance('MQL').Status__c && newLead.Status == LeadStatus__c.getInstance('MI').Status__c)
          {
            newLead.IF_Marketing_Cycle__c = newLead.IF_Marketing_Cycle__c + 1;
          }
          if (oldLead.status.endsWith(LeadStatus__c.getInstance('Rejected').Status__c) && (newLead.Status == LeadStatus__c.getInstance('MI').Status__c || newLead.Status == LeadStatus__c.getInstance('MQL').Status__c))
          {
            newLead.IF_Marketing_Cycle__c = newLead.IF_Marketing_Cycle__c + 1;
          }  */   
          if(oldLead.Status != newLead.status)
          {
            newLead.IF_Last_Status_Update__c = system.now();
          }           
        } // end of Trigger is update
        if (trigger.isInsert)
        {
            newLead.IF_Last_Status_Update__c = System.now();

         /* if (newLead.IF_Lead_Source_Type__c == null) // fill in lead source type if not already done.
            {
                if(newlead.IF_Original_Partner_Lead_source__c != null)
                {
                    newLead.IF_Lead_Source_Type__c = 'Partner';
                }
                else
                {
                    newLead.IF_Lead_Source_Type__c = userType;
                }
            } */
         }// end of Trigger is Insert

         // next we need to go through and get the information for the update.
         // if the new owner id starts with 00G then the owner is a queue
         // else the owner is and individual.            
         if (trigger.isInsert || ownerChange == true)
         {
            string ownerID = newlead.OwnerID;
    
            if (OwnerID.startsWith('00G')) //Record is owned by a queue 
            {
                newLead.IF_Current_Owner_Type__c = 'Queue';
                
                // determine if the owner is a partner             
             /* if(CurrentQueuesMap != null && !CurrentQueuesMap.isEmpty())   // Used Map instead of list to remove nested for loop
                {
                  if(CurrentQueuesMap.containsKey(OwnerID.Left(15)))    // Owner presents in PRMAcctQueueCombination__c custom setting
                  { 
                     newLead.IF_current_Queue_ISPartner__c = true;
                     //code unit to achieve same functionality as of 'fetchAccountName' method in 'LeadUtils' class
                     newLead.PartnerAccount__c = CurrentQueuesMap.get(OwnerID.Left(15)).AccountID__c;                      
                  } 
                  else{
                       newLead.PartnerAccount__c = null;
                  }
                }   */   
                //code Unit End
                //Copy Group name of Owner to 'IF_current_Queue_name__c' field  
             /* if(mapOfGroups.containsKey(newLead.OwnerId))
                {
                    newLead.IF_current_Queue_name__c = mapOfGroups.get(newLead.OwnerId).Name; 
                } */
                                     
            }// End of code for Owner is Queue
            else if (OwnerID.startsWith('005'))// record is owned by a user
            {
                                        
                    if(userMap != null)
                    {
                     if(userMap.containsKey(newLead.OwnerId)) // Used Map instead of list to remove nested for loop
                     {
                      if(userMap.get(newLead.OwnerId).userType.containsIgnoreCase('Partner'))
                      {
                           newlead.IF_Current_Owner_type__c = 'Partner';

                           if(partnerQueuesMap != null && !partnerQueuesMap.isEmpty())
                           {
                               string aid = StringUtils.substring(userMap.get(newLead.OwnerId).accountID,0,15);
                               //Owner presents in PRMAcctQueueCombination__c custom setting
                               // Used Map instead of list to remove nested for loop
                            /* if(partnerQueuesMap.containsKey(aid)) //if(partnerQueuesMap.containsKey(aid))  
                               {
                                   newLead.IF_Partner_queue_id__c = StringUtils.substring(partnerQueuesMap.get(aid).queueIDs__c,0,15);
                               } */  
                           }
                      }
        
                      else if (userMap.get(newLead.OwnerId).Lead_Reassignment_Role__c == STRING_LEAD_REASSIGNMENT_ROLE_INSIDE_SALES_REP)
                      {
                          newlead.IF_Current_Owner_Type__c = 'ISR';
                      }
                      else if (userMap.get(newLead.OwnerId).Lead_Reassignment_Role__c == STRING_LEAD_REASSIGNMENT_ROLE_FIELD_SALES_REP)
                      {
                          newLead.IF_current_Owner_Type__c = 'FSR';
                      }                     
                     }
                     else{
                         newLead.IF_current_owner_Type__c = 'Other';
                     }
                    }
                    else{
                        newLead.IF_current_owner_Type__c = 'Other';
                    }
            }// End of code for Owner is Queue
         }// end of Trigger is Insert or is Update(when owner Changed)
         //code unit to achieve same functionality as of 'fetchAccountName' method
         //Copy 'PartnerAccountId' field to 'PartnerAccount__c' field
         //Run for both insert and update
      /*  if(Trigger.isInsert || trigger.isUpdate){
              if(!(newlead.OwnerID+'').startsWith('00G')){      //Not owned by a queue          
                    if(mapOwnerAccount.get(newlead.OwnerID) != null){
                        //newLead.PartnerAccount__c = newLead.PartnerAccountId;
                        if(mapOwnerAccount.get(newlead.OwnerID).contact != null)
                            newLead.PartnerAccount__c = mapOwnerAccount.get(newlead.OwnerID).contact.AccountId;                        
                        else
                            newLead.PartnerAccount__c = null;
                        }                         
              }       
         }//Code unit End */
    }//End of For loop
   }//End of try block
   catch(exception e){  
        System.debug('************ exception :' + e.getMessage());
   }//End of catch block
  }//End of UpdateOwner Method  
  

/*--------------------------------------------------------------------------------------------------------------------------
Author:Arindam Laik, TCS
Date:03/19/2015
Purpose:Separate business logic from trigger, Code Cleanup/OPtimization and follow saleforce best practices
Item Description:
Collect all the Referral Partner IDs that were inserted.
If corresponding Referral Partner IDs presentes in Account
then copy coresponding Account id,Primary_Contact_Name__c,Primary_Contact_Phone__c,Primary_Contact_Email__c
into Referral_Account__c,Primary_Contact_Name__c,Primary_Contact_Phone__c,Primary_Contact_Email__c field
---------------------------------------------------------------------------------------------------------------------------*/  
/*  public static void updateReferralPartnerIdFromAccountToLead(List<Lead> leadsnew,Map<ID, Lead> leadsold) {
        if(leadsnew == null || leadsnew.size() < 1) return;
        
        
        Set<Lead> insertedReferralPartnerIds = new Set<Lead>();
        
      for(Lead objLead : leadsnew) {
            if(objLead.Referral_Partner_ID__c != null &&
              (objLead.Primary_Contact_Name__c == null || objLead.Primary_Contact_Phone__c == null || objLead.Primary_Contact_Email__c == null)
              ) {
                    insertedReferralPartnerIds.add(objLead);                   
                }
        } 
        // If we don't find any, we're done.
        if(insertedReferralPartnerIds.size() < 1) return;
        
        // Pluck all the Referral Partner IDs that were inserted.
        Set<String> referralPartnerIds = new Set<String>();
        for(Lead objLead : insertedReferralPartnerIds){ 
            referralPartnerIds.add(objLead.Referral_Partner_ID__c);
        }
        // Grab all the accounts that reference all the Referral Partner IDs that were inserted.
        List<Account> accounts = new List<Account>([
            select  id,Primary_Contact_Name__c,Primary_Contact_Phone__c,Primary_Contact_Email__c
            from    Account
            where   RecordType.Name =: Label.Account_Record_Type_Partner_Referral Limit 50000
         // where   RecordType.Name =: Label.Account_Record_Type_Partner_Referral AND Referral_Partner_ID__c in :referralPartnerIds Limit 50000
        ]);
        
        if(Accounts.size() > 0)
        {
            // If find dupes, throw everything of them away.
            Map<String, Account> referralId_account = new Map<String,Account>();
            Set<String> toRemove = new Set<String>();
                    
            for(Account a : accounts){
                if(!referralId_account.containsKey(a.Referral_Partner_ID__c)) {
                    referralId_account.put(a.Referral_Partner_ID__c,a);
                }
                else {
                    toRemove.add(a.Referral_Partner_ID__c);
                }
            }
            if(toRemove.size() > 0){
                for(String s : toRemove)
                {   
                    referralId_account.remove(s);
                }
            }
           if(referralId_account.size() > 0)
            {
                // Update the appropriate Leads.
                for(Lead objLead : insertedReferralPartnerIds) {
                    if(referralId_account.containsKey(objLead.Referral_Partner_ID__c)) {
                        Account a = referralId_account.get(objLead.Referral_Partner_ID__c);
                        objLead.Referral_Account__c = a.id;
                        objLead.Primary_Contact_Name__c = a.Primary_Contact_Name__c;
                        objLead.Primary_Contact_Phone__c = a.Primary_Contact_Phone__c;
                        objLead.Primary_Contact_Email__c = a.Primary_Contact_Email__c;
                    }
                }
            } 
        }
    } */


/*--------------------------------------------------------------------------------------------------------------------------
Author:Arindam Laik, TCS
Date:03/19/2015
Purpose:Separate business logic from trigger, Code Cleanup/OPtimization and follow saleforce best practices
Item Description:
@ Created the method and Seperate business logic from 'LeadAll' trigger
@ Remove Commented Codes
@ Remove System Debug Statements
---------------------------------------------------------------------------------------------------------------------------*/   
  private Static User loggedInUser;
  private Static List<Country_And_Country_Code__c> allCountries;
  Public Static Void allLeadMethod (List<Lead> listofLead, Map<id,Lead> oldMapofLead) 
  {
    // Instance Variable declaration Started    
    final String INTERNALAUTOMATION = 'internalautomation';
    final String INTEGRAT = 'integrat';
    final String MARKETO = 'marketo';
    
    boolean isMarketoUser;
    boolean isUserAutomationOrIntegration;
    
    List<Lead> leadsToPopulateDataShare = new List<Lead>();
    
            if (loggedInUser == null || Test.isRunningTest())
            {
                util.debug('loggedInuser was null, querying now with id: ' + userInfo.getUserId());
                loggedInUser = [select id, name, username, Bypass_Workflows__c from user where id =: userinfo.getUserId()];
            }
        
            if (loggedInuser != null && loggedInUser.UserName != null)
            {   
                isUserAutomationOrIntegration = (loggedInUser.UserName.Contains(INTERNALAUTOMATION) || loggedInUser.UserName.Contains(INTEGRAT));                   
                isMarketoUser = loggedInUser.UserName.Contains(MARKETO);                
            }

            if (allCountries == null || Test.isRunningTest())
            {
                allCountries = [select name, ISO_Code_2__c, Region__c from Country_And_Country_Code__c Limit 50000];       
            }


   
    // Instance Variable declaration ended
    
    /** Code Added by Pratyush to update the Lead_Owner_Role__c field **/ 
        
        for(Lead ObjLead:listofLead)
        { 
            
            if(ObjLead.Lead_Source_Most_Recent__c == null &&  ObjLead.LeadSource != null )
            {
                ObjLead.Lead_Source_Most_Recent__c = ObjLead.LeadSource;
            }
            /* Commented as per Case - # 01978790 
            if(ObjLead.Lead_Source_Most_Recent__c != null &&  (ObjLead.LeadSource == null || ObjLead.Lead_Source_Update_Date__c < (System.TODAY()-365)) )
            {
                ObjLead.LeadSource = ObjLead.Lead_Source_Most_Recent__c;
            }
            */
            //  code added by joseph hutchins 11/19/2014
            MapStatusFromLifeCycleStatus(ObjLead);
            //  end code added by joseph hutchins 11/19/2014
            
            //Changes for CR 01205396
            if(Trigger.isUpdate)
            {                  
                if(ObjLead.Referral_Account__c != oldMapofLead.get(ObjLead.Id).Referral_Account__c && ObjLead.Referral_Account__c != null)     
                {
                    leadsToPopulateDataShare.add(ObjLead);
                }
                if(!isMarketoUser && !isUserAutomationOrIntegration)
                {
                    //not accepted if country field is blank
                    if(String.isBlank(ObjLead.Country))
                    {
                         ObjLead.Country.addError('Country must be specified');
                    }
                    //  code added by joseph hutchins 11/19/2014
                    //  we only want this to fire if the country changed since this adds a query row to num of max queries that can be used by the trigger
                    if(oldMapofLead.get(ObjLead.Id).Country != ObjLead.Country)
                    {
                        util.debug('about to run checkLeadCityStateCountryAndAssignRegion.... ');
                        checkLeadCityStateCountryAndAssignRegion(ObjLead, allCountries);
                    }    
                }
                
              // updateHiddenLeadSourceFields(ObjLead, loggedInUser.Bypass_Workflows__c);//  added by joseph hutchins 11/19/2014 after seeing that workflow was not firing in the correct order to populate the 3 hidden lead source fields
                //  end code added by joseph hutchins 11/19/2014
                
            }
            else if(Trigger.isInsert)
            {                
                //  code added by joseph hutchins 11/19/2014
                if (!isMarketoUser && !isUserAutomationOrIntegration)//  we do not check country for marketo users on lead creations
                {
                    //not accepted if country field is blank
                    if (String.isBlank(ObjLead.Country))
                    {
                        ObjLead.Country.addError('Country must be specified');
                    }
                    else
                    {
                        checkLeadCityStateCountryAndAssignRegion(ObjLead, allCountries);
                    }
                }
                //  end code added by joseph hutchins 11/19/2014

                if(ObjLead.Referral_Account__c != null)
                leadsToPopulateDataShare.add(ObjLead);
            }        
        }
        //Changes for CR 01205396 
        if(!leadsToPopulateDataShare.isEmpty())
        {
            populateDataSharePartners(leadsToPopulateDataShare);
        }                                          
        
    /** END - Code by Pratyush to update Opportunity_Owner_Role__c field **/
  } 
  
/*--------------------------------------------------------------------------------------------------------------------------
Author:joseph hutchins
Modified by: Arindam Laik
Date:29/5/2015
Purpose:Separate business logic from trigger, Code Cleanup/OPtimization and follow saleforce best practices
Item Description:
tried to do this as a workflow/field update but the field update only allows you update the status field
with another value in the status picklist
---------------------------------------------------------------------------------------------------------------------------*/ 
    public static void MapStatusFromLifeCycleStatus(Lead theLead)
    {        
        if (!String.isblank(theLead.Lifecycle_status__c))
        {
            //  theLead.Status is s required field and cannot be moved from the page layout so we need to make sure
            //  the life cycle status is not null before making this assignment
            theLead.Status = theLead.Lifecycle_Status__c;
        }
    }

    
/*--------------------------------------------------------------------------------------------------------------------------
Author:joseph hutchins
Modified by: Arindam Laik
Date:29/5/2015
Purpose:Separate business logic from trigger, Code Cleanup/OPtimization and follow saleforce best practices
Item Description:
this code will check country first, this will let us know if the lead is domestic or not,
then if it's domestic we'll check the state and city are set
---------------------------------------------------------------------------------------------------------------------------*/     
    public static void checkLeadCityStateCountryAndAssignRegion(Lead leadToCheck, List<Country_And_Country_Code__c> allCountris)
    {
        system.assertNotEquals(null, leadToCheck);
        
        string defaultErrorMessage = 'This country name does not match any of the valid ' + 'countries stored in the Country Object.';
        string errorMessage = 'Required Field is Missing';

        //  If country is 'us' OR 'usa' OR 'u.s' OR 'u.s.a' then this method will return 'United States'
        leadToCheck.Country = checkForUnitedStatesAbbreviations(leadToCheck.Country);        
        
        // if Country entered by user is not present within 'Country_And_Country_Code__c' obj then not accepted                         
        if (!doesCountryNameExistOrIsSpelledCorrectly(leadToCheck.Country, allCountris))
        {
            leadtoCheck.Country.addError('Country: ' + defaultErrorMessage);
        }
        else
        {
            //if the country is set correctly, then we'll get the country and country code and grab the region from the record
            Country_And_Country_Code__c tempCCC = findCountryCodeUsingCountryName(leadToCheck.Country, allCountris);
            if (tempCCC != null)
            {
                leadTocheck.Region__c = tempCCC.Region__c;
                
            }
        }
        
        //  lets check the state and city if domestic lead
        if (leadToCheck.Country == 'United States')
        {         
            if (Util.isblank(leadTocheck.City))
            {
                leadToCheck.City.AddError('City: ' + errorMessage);
            }
            if (Util.isBlank(leadToCheck.State))
            {
                leadToCheck.state.addError('State: ' + errorMessage);
            }
            else
            {
                getStateCode(leadToCheck);
                //Not accepted if statecode does not present in 'State__c' custom setting
                if(leadToCheck.State.length() > 2 || !isLeadStateValid(leadToCheck.State))//  state should be abbrievated
                {
                    leadToCheck.State.addError('State must be capitalized and use 2 letter abbreviation');
                }
            }
        }
            
    }
    
    private static string checkForUnitedStatesAbbreviations(string countryName)
    {        
            string countryNameLowerCase = countryName.toLowerCase();
            if (countryNameLowerCase == 'us' ||
                countryNameLowerCase == 'usa' ||
                countryNameLowerCase == 'u.s.' || 
                countryNameLowerCase == 'u.s.a.')
            {
                return 'United States';
            }
            else
            {
                return countryName;
            }
    }
    
    public static boolean doesCountryNameExistOrIsSpelledCorrectly(string countryName, List<Country_And_Country_Code__c> countryCodeRecords)
    {                   
        string countryNameLowerCase = countryName == null ? null : countryName.toLowerCase();
        
        if (countryNameLowerCase != null)
        {
            for (Country_And_Country_Code__c ccc : countryCodeRecords)
            {
                
                if (ccc.Name != null && ccc.Name.toLowerCase().equals(countryNameLowerCase))
                {
                    return true;
                }                       
            }
            
        }
            return false;
    }
    
    private static Country_And_Country_Code__c findCountryCodeUsingCountryName(string countryName, List<Country_And_Country_Code__c> countryREcords)
    {
        for (Country_And_Country_Code__c ccc : countryRecords)
        {
            if (ccc.Name == countryName)
            {
                return ccc;
            }
        }
        return null;
    }
    
    public static void getStateCode(Lead objLead)
    { 
          State__c sCode;
          String stateCodeValue;
          Set<String> setofStateCode = new Set<String>();
          //get all records from the custom setting
          Map<String,State__c> mapCodes = State__c.getAll();         
          List<State__c> listOfCodes = State__c.getAll().values();
                             
          for(State__c cd : listOfCodes)
          {
              setOfStateCode.add(cd.StateCode__c);
          }              
                                                   
          if(mapCodes.containsKey(objLead.State))
          {
              sCode = State__c.getInstance(objLead.State);
              stateCodeValue = sCode.StateCode__c;
              if(stateCodeValue != null && stateCodeValue != '')
              {
                  objLead.State = stateCodeValue;
              }
              else
              {   
                  objLead.State = objLead.State;          
              }
          } 
          else if(setOfStateCode.contains(objLead.State))
          { 
              objLead.State = objLead.State;
          }
          else
          {                 
              objLead.State = objLead.State;
          }                                          
   }
   private static boolean isleadStateValid(string state)
   { 
        //Get all state code from custom setting
        List<State__c> lstofState = State__c.getall().values();
        for(State__c objState:lstofState)
        { 
            if(state.equals(objState.StateCode__c) && state !='null')
            return true;
        }
        return false;       
   }

   
/*--------------------------------------------------------------------------------------------------------------------------
Modified by:Arindam Laik, TCS
Date:29/05/2015
Purpose:Separate business logic from trigger, Code Cleanup/OPtimization and follow saleforce best practices
Item Description:
@ populate Data share partner field based on the referral partner entered
---------------------------------------------------------------------------------------------------------------------------*/     
    public static void populateDataSharePartners (List<Lead> leadsToPopulateDataShare)
    {
        Set<Id> SetOfReferralPartnerIds = new Set<Id>();
        Map<Id, Data_Sharing_Partner__c>  dspMap = new Map< Id, Data_Sharing_Partner__c> ();
        
        for(Lead objLead : leadsToPopulateDataShare)
        {
            SetOfReferralPartnerIds.add(objLead.Referral_Account__c);
        }
        if (!SetOfReferralPartnerIds.isEmpty())
        {                      
            for(Data_Sharing_Partner__c dsp: [select id,Related_Account__c from Data_Sharing_Partner__c where Related_Account__c IN:SetOfReferralPartnerIds Limit 50000])
            {
                dspMap.put(dsp.Related_Account__c, dsp);
            }       
            for(Lead objLead : leadsToPopulateDataShare)
            {
                if(dspMap.containsKey(objLead.Referral_Account__c))
                {
                    objLead.Data_Share_Partner__c = dspMap.get(objLead.Referral_Account__c).id;
                }
            } 
        }      
        
    }

 
/*--------------------------------------------------------------------------------------------------------------------------
Modified by: Arindam Laik, TCS
Date:29/05/2015
Purpose:Separate business logic from trigger, Code Cleanup/Optimization and follow saleforce best practices
Item Description:
there was a workflow that was performing this job but the workflow has been deactivated
as it was appearing as though the 4 rules were not firing in the proper order
---------------------------------------------------------------------------------------------------------------------------*/     
/*  public static void updateHiddenLeadSourceFields(Lead objLead, boolean canBypassWorkFlows)
    {        
        if (!canByPassWorkFlows)
        {
            // this should only fire on insert, so these fields should already be blank, but check for blankness just in case
            if (!String.isBlank(objLead.LeadSource)) 
            {
                if (String.isBlank(objLead.Hidden_Original_Lead_Source__c))
                {
                    objLead.hidden_original_lead_source__c = objLead.LeadSource;
                }
                if (String.isBlank(objLead.Hidden2_Original_Lead_Source__c))
                {
                    objLead.Hidden2_Original_Lead_Source__c = objLead.LeadSource;
                }
                if (String.isBlank(objLead.Hidden3_Original_Lead_Source__c))
                {
                    objLead.Hidden3_Original_Lead_Source__c = objLead.LeadSource;
                }
            }
        }
        
    } */


/*--------------------------------------------------------------------------------------------------------------------------
Author:Arindam Laik, TCS
Date:03/19/2015
Purpose:Separate business logic from trigger, Code Cleanup/OPtimization and follow saleforce best practices
Item Description:
@ Assign Lead Owner's RoleId into 'Lead_Owner_Role__c' field
@ Created the method and Seperate business logic from 'LeadAll' trigger
@ Remove Commented Codes
@ Remove System Debug Statements
---------------------------------------------------------------------------------------------------------------------------*/  
  Public Static void ChangeLeadOwnerRole(List<Lead> listofLead,Map<Id,Lead> oldMapofLead)
  {
                   
       Set<Id> setOwnerId = new Set<Id>();

       for(Lead objLead:listofLead)
       {
               if ((objLead.ownerId+'').startsWith('005')){
                   setOwnerId.add(objLead.ownerId);
               }    
               else if ((objLead.ownerId+'').startsWith('00G')){
                   objLead.Lead_Owner_Role__c = '';
               }

       }

       if(!setOwnerId.isEmpty())
       {     
           Map<Id, User> mapUser = new Map<Id, User>([Select Id, UserRoleId from User where id in :setOwnerId]);
                
           if(!mapUser.isEmpty()){ 
           for(Lead objLead:listofLead) {               
               User tmpUser = mapUser.get(objLead.ownerId);
               if(null != tmpUser){
                  objLead.Lead_Owner_Role__c = mapUser.get(objLead.ownerId).userRoleId;
               }
               else{
                    objLead.Lead_Owner_Role__c = '';
               }
           }
           }
       }
  }      

       
/*--------------------------------------------------------------------------------------------------------------------------
Modified by: Arindam Laik, TCS
Date:29/05/2015
Purpose:Separate business logic from trigger, Code Cleanup/Optimization and follow saleforce best practices
---------------------------------------------------------------------------------------------------------------------------*/  
   static String masterqueueid = '';
   static Set<String> distiids = new Set<String>();
   static Set<String> setOfmpqMemebersId = new Set<String>();
   static List<GroupMember> mpqMemebers = new List<GroupMember>();
   static Map<ID, Group> groupIDtoName;
   static boolean isGroupNameandGroupMember = false;
        
   public static void updateLeadMetaData(List<Lead> leadsnew, Map<ID, Lead> leadsold) {
        
    try{            
        boolean isReturn = false;
        if(leadsnew == null || leadsnew.size() < 1 || leadsold == null) return;
        // We're not interested if the owner didn't change
        for(Lead objLead:leadsnew)
        {
          if(leadsold.get(objLead.Id).ownerId !=null && (objLead.ownerId != leadsold.get(objLead.Id).ownerId))
             isReturn = true;
        }
        if(isReturn == false)
        return;
        
        // Find the queues we're interested in, they will be the keys of the groupAccountIdMap
        updateGroupAccountMapping();
        // groupAccountIdMap will contain the all the Distis and VARs, we also need the master queue.
        if(!isGroupNameandGroupMember)         // Run only once for a single triger context
        {
        isGroupNameandGroupMember = true; 
        if(PRMMasterLeadQueue__c.getAll().values()!=null && !PRMMasterLeadQueue__c.getAll().values().isEmpty())
        {
            for(PRMMasterLeadQueue__c p : PRMMasterLeadQueue__c.getAll().values()) {
                if(STRING_PARTNER_QUEUE.equals(p.name)){ 
                    masterqueueid = StringUtils.substring(p.PRMMasterQueue__c,0,15);
                }
            }
        }
        
        if(PartnerMasterOwnerAccount__c.getAll().values()!=null && !PartnerMasterOwnerAccount__c.getAll().values().isEmpty())
        {
            for(PartnerMasterOwnerAccount__c pmoa : PartnerMasterOwnerAccount__c.getAll().values()) {
                distiids.add(StringUtils.substring(pmoa.OwnerAccountId__c, 0, 15));
            }
        }
        // Query for all the proper queue names.
        if((masterqueueid != null && masterqueueid !='') || !groupAccountIdMap.isEmpty())
        {
                       
            groupIDtoName = new Map<ID, Group>([select Name from Group where ID in :groupAccountIdMap.keySet() or 
                                                ID = :masterqueueid limit 50000]);
            if(masterqueueid != null && masterqueueid !='')
                mpqMemebers = [Select UserOrGroupId from GroupMember where GroupId =: masterqueueid limit 50000];                                                  
                                                                      
        }              
        //create the list of id of member Master Partner Queue 
        if(!mpqMemebers.isEmpty()){
            for(GroupMember grpMem:mpqMemebers){
                String str = grpMem.UserOrGroupId;
                str = str.subString(0,15);
                setOfmpqMemebersId.add(str);   
            }       
        }
        }         
        Set<id> setLeadOwnerId = new Set<id>();
        Map<Id, User> mapOwnerAccount = new Map<Id, User>();
        for(Lead objLeadnew : leadsnew)
        {
            if((objLeadnew.OwnerID+'').startsWith('005'))
            setLeadOwnerId.add(objLeadnew.OwnerId);
        }
        if(setLeadOwnerId.size() > 0)
        {
            mapOwnerAccount = new Map<Id, User>([select id, contactId, contact.AccountId from User where id IN: setLeadOwnerId limit 50000]) ;   
        }
                
        for(Lead l : leadsnew) {
            if(l == null) 
            continue;
            
            String ownerid = StringUtils.substring(l.ownerid, 0, 15);
            String oldownerid = StringUtils.substring(leadsold.get(l.id).OwnerId, 0, 15);
            //String partneraccountid = StringUtils.substring(l.PartnerAccountId, 0, 15);
            String partneraccountid = null;
            if(mapOwnerAccount.get(l.ownerId) != null && mapOwnerAccount.get(l.ownerId).contactId != null)
            {
                partneraccountid = StringUtils.substring(mapOwnerAccount.get(l.ownerId).contact.AccountId, 0, 15);
            }
            String oldpartneraccountid = StringUtils.substring(leadsold.get(l.id).PartnerAccountId, 0, 15);
            // We're not interested if the owner didn't change
            if(oldownerid == null || ownerid.equals(oldownerid)) 
            continue;
            
            // Was the prior owner a queue?
            if(groupIDtoName != null && groupIDtoName.containsKey(oldownerid))   // Use groupIDtoName where since we want all the queues, including master.
            {
                l.Last_Queue_Owner__c = groupIDtoName.get(oldownerid).Name;
            }
            //If the lead was owned my members of master partner queue then the last Queue owner will be MPQ [Added for the CR 01218523] 
            // Assigned from master queue.

            if(!setOfmpqMemebersId.isEmpty() && setOfmpqMemebersId.contains(oldownerid)){
                l.Last_Queue_Owner__c = STRING_MASTER_PARTNER_QUEUE;        
            }
            
         /*  if(
                ((masterqueueid != null && masterqueueid.equals(oldownerid))||
                (!setOfmpqMemebersId.isEmpty() && 
                setOfmpqMemebersId.contains(oldownerid))) &&          // Old owner was the master queue OR old owner was member of MPQ.                 
                l.Assigned_From_MPQ_QES_Date__c == null               // Not previously set.
              ){
                    l.Assigned_From_MPQ_QES__c = true;                
                    l.Assigned_From_MPQ_QES_Date__c = Datetime.now();
                
               }*/
            
            // Was the lead accepted by a distributor (PANA)?
          /*  if(
                groupAccountIdMap.containsKey(oldownerid)   // The old ownerid is defined as a PRM queue.
                && distiids.contains(partneraccountid)      // The new lead has a PartnerAccountID => owned by a disti partner user.
              ) {
                 // l.Accepted_By_PANA_Disti__c = true;
                    l.Accepted_By_PANA_Disti_Date__c = Datetime.now();
                } */
            
            // Did the lead get assigned from a distributor (PANA)?
         /*   if(
                distiids.contains(oldpartneraccountid)          // The old lead has PartnerAccountID defined as a disti.
                && groupAccountIdMap.containsKey(ownerid)       // The new owner is a PRM queue.
                && l.Assigned_From_PANA_Disti_Date__c == null   // Not previously set.
              ) {
                    l.Assigned_From_PANA_Disti__c = true;
                    l.Assigned_From_PANA_Disti_Date__c = Datetime.now();
                    l.First_assigned_VAR__c = groupAccountIdMap.get(ownerid);
                } */
            
            // Was the lead accepted by a VAR?
         /*    if(
                groupAccountIdMap.containsKey(oldownerid)   // The old ownerid was a PRM queue.
                && partneraccountid != null                 // The lead is now owned by a partner user.
                && !distiids.contains(partneraccountid)     // Cannot be a disti at this point.
              ) {
                  //l.Accepted_By_VAR__c = true;
                    l.Accepted_By_VAR_Date__c = Datetime.now();
                } */
            
            // Was the lead assigned from a VAR?
          /*  if(
                (groupIDtoName != null && groupIDtoName.containsKey(ownerid))          // The owner id is a PRM queue or master queue.
                && oldpartneraccountid != null              // The old owner was a partner user.
                && !distiids.contains(oldpartneraccountid)  // The old partner owner wasn't a disti.
                && l.Assigned_From_VAR_Date__c == null      // Not previously set.
              ) {
                  //l.Assigned_From_VAR__c = true;
                    l.Assigned_From_VAR_Date__c = Datetime.now();
                } */
            // Was the lead assigned to a Partner from the master queue?
            if(
                ((masterqueueid != null && masterqueueid.equals(oldownerid)) || (!setOfmpqMemebersId.isEmpty() && setOfmpqMemebersId.contains(oldownerid)))                   // The previous owner is the master queue.       
                && groupAccountIdMap.containsKey(ownerid)           // The owner is a PRM queue.
                //&& l.Assigned_To_VAR_From_MPQ_QES_Date__c == null   // Not previously set. //Commented for CR 89323
              ) {
                  //l.Assigned_To_VAR_From_MPQ_QES__c = true;
                  //l.Last_Assigned_From_MPQ_to_Partner_Date__c = Datetime.now();
                 // l.Last_Assigned_From_MPQ_to_Partner__c = groupAccountIdMap.get(ownerid);
                
                }
        }
        }
        catch(exception e)
        {
            System.debug('updateLeadMetaData()::unable to update the Lead metadata'+e.getmessage());
        }
    }
    
    private static void updateGroupAccountMapping(){
        if(groupAccountIdMap==null){
            List<PRMAcctQueueCombination__c> accountQueueCombinationList=PRMAcctQueueCombination__c.getAll().values();
            groupAccountIdMap=new Map<String,String>();
            for(PRMAcctQueueCombination__c accntQueueCombination:accountQueueCombinationList){
                //split the queue id based on comma seperator
                if(accntQueueCombination.QueueIds__c!=null){
                    String[] queueIds=accntQueueCombination.QueueIds__c.split(',');
                    //if there is no comma, then the string defined is just returned
                    groupAccountIdMap.put(queueIds[0],accntQueueCombination.AccountId__c);
                }
            }
        }  
    }

    
/*--------------------------------------------------------------------------------------------------------------------------
Modified by: Arindam Laik, TCS
Date:29/05/2015
Purpose:Separate business logic from trigger, Code Cleanup/Optimization and follow saleforce best practices
Item Description:
Populates the Reseller/Distributor Lead Created By field with the account of the user who is creating the lead.r
---------------------------------------------------------------------------------------------------------------------------*/     
    public static void populateCreatedByReseller(List<Lead> listOfLeads, Map<Id,Lead> OldMapOfLeads)
    {
        String QualcommAccountId = Label.Qualcomm_Account_Id;
        List<Id> listOfCreatedByUserId = new List<Id>();
        
        for(Lead objLead : listOfLeads)
        {
            if(objLead.Company_Lead_Created_By__c == null && ((objLead.RecordTypeId+'').contains(label.Partner_Reseller_Lead) ||  (objLead.RecordTypeId+'').contains(label.T_L_Lead)))
            {       
                    if(objLead.createdById != null) //added filter condition to stop execution of SOQL during Insertion
                    listOfCreatedByUserId.add(objLead.createdById);
            }        
        } 
        // If Lead created by portal user then corresponding Account Id will be Populated in 'Company_Lead_Created_By__c'
        // Else some default value(i.e Label.Qualcomm_Account_Id)
        if(listOfCreatedByUserId.size() > 0)
        {
            Map<Id, User> mapOfIdToUser = new Map<Id, User>([select id, contactId, contact.AccountId from User where id IN: listOfCreatedByUserId limit 50000]) ;
        
            for(Lead objLead : listOfLeads)
            {
                if(mapOfIdToUser.containsKey(objLead.createdById)) 
                {   
                    if(mapOfIdToUser.get(objLead.createdById).contactId != null)
                        objLead.Company_Lead_Created_By__c = mapOfIdToUser.get(objLead.createdById).contact.AccountId;
                    else
                        objLead.Company_Lead_Created_By__c = QualcommAccountId;
                } 
            }
        }
    }


/*--------------------------------------------------------------------------------------------------------------------------
Author:Arindam Laik, TCS
Date:03/19/2015
Purpose:Separate business logic from trigger, Code Cleanup/OPtimization and follow saleforce best practices
Item Description:
If Lead 'sic_code__c' presents in 'SIC__c' object then
copy values of description_general__c,description_detailed__c,reporting__c of 'SIC__c' object
into SIC_Description_General__c,SIC_Description_Detailed__c,SIC_Reporting_Description__c fields of Lead
mass query the sic table for multiple account processing
---------------------------------------------------------------------------------------------------------------------------*/         
    private static List<Sic__c>  allSics;
    private static Map<String,Sic__c> MapSic;
    public static void updateSicFields(List<Lead> lstofleads)
    {
        boolean isSICCodePresent = false;    
          for (Lead singleLead : lstofleads)
          {
                if (singleLead.sic_code__c != null)
                {
                 isSICCodePresent = true;
                 break;
                }
          }
          if((allSics == null && isSICCodePresent == true) || Test.isRunningTest()){           
               allSics = [select id, name, description_general__c, description_detailed__c, reporting__c from SIC__c Limit 50000];
               MapSic = new Map<String,Sic__c>();
               for(Sic__c objSic: allSics)
               {
                 MapSic.put(objSic.Name,objSic);
               }
          }
          // If Lead 'sic_code__c' presents in 'SIC__c' object then
          // copy values of description_general__c,description_detailed__c,reporting__c of 'SIC__c' object
          // into SIC_Description_General__c,SIC_Description_Detailed__c,SIC_Reporting_Description__c fields of Lead
          // mass query the sic table for multitple account processing
                         
          for (Lead singleLead : lstofleads)
          {
                if (singleLead.sic_code__c != null)
                {
                    if(MapSic.containsKey(singleLead.sic_code__c))
                    {                                       
                        singleLead.SIC_Description_General__c = MapSic.get(singleLead.sic_code__c).description_general__c;
                        singleLead.SIC_Description_Detailed__c = MapSic.get(singleLead.sic_code__c).description_detailed__c;
                        singleLead.SIC_Reporting_Description__c = MapSic.get(singleLead.sic_code__c).reporting__c;
                    }
                }
          }
    }

    
/*--------------------------------------------------------------------------------------------------------------------------
Author:Arindam Laik, TCS
Date:03/17/2015
Purpose:Separate business logic from trigger, Code Cleanup/OPtimization and follow saleforce best practices
Item Description:
@ Created the method and Separate business logic from 'CreateTISDetailLead' trigger
@ Remove Commented Codes
@ Remove System Debug Statements
---------------------------------------------------------------------------------------------------------------------------*/  
public Static void CreateNewTIS(List<Lead> lstofLead)
{
        CreateTISLeadAndOpp.CreateNewTISRecord(null, 'Lead',lstofLead);   
}
public Static void UpdateTIS(List<Lead> lstofLead, Map<id,Lead> OldMapofLead)
{
    Map<String, Lead> mapOfLead = new Map<String, Lead>();
    for(Lead ObjLead:lstofLead){
            //Interested on those leads where owner has changed
            if(ObjLead.ownerId != OldMapofLead.get(ObjLead.id).ownerId){
               mapOfLead.put(ObjLead.id,ObjLead);    
            }        
    }
    if(!mapOfLead.isEmpty() && CreateTISLeadAndOpp.isExecute == true){
            CreateTISLeadAndOpp.UpdateTISRecordsLead(mapOfLead, OldMapofLead);
            //to run the above method only once in a complete trigger context
            CreateTISLeadAndOpp.isExecute=false;
    }
}


/*--------------------------------------------------------------------------------------------------------------------------
Author:Arindam Laik, TCS
Date:03/17/2015
Item Description:
@ If Lead got converted by any Gold partner user then
@ Upon Lead convertion the corresponding Acccount's 'Partner Agent' field with populated with the user,
@ who has converted the Lead to Account
Purpose:Separate business logic from trigger, Code Cleanup/OPtimization and follow saleforce best practices 
Description:
@ Created the method and Seperate business logic from 'TrigMapField' trigger
@ Add filter logic to reduce the no. of soql query being executed
@ Remove Commented Codes
@ Remove System Debug Statements
---------------------------------------------------------------------------------------------------------------------------*/  
public Static void mapFieldMethod(List<Lead> lstofLead)
{

 String profileId= userInfo.getProfileId();
 String UserId= userInfo.getUserId();
 Set<Id> setConvertedAccountId = new Set<Id>();
 List<Lead> lstTempLead = new List<Lead>();

 // we will proceed only if Lead has converted
 // else not interested
 for(Lead ObjLead:lstofLead){
     if(ObjLead.IsConverted == true && ObjLead.ConvertedAccountId != null)
        lstTempLead.add(ObjLead);
  }

  if(lstTempLead.size() == 0 || lstTempLead.isEmpty()) return;
  
  Profile profile=[Select UserLicense.Name,Id From Profile where Id=:profileId];
  
  // we will proceed only if the lead got converted by any Gold partner user
  if(profile.UserLicense.Name == 'Gold Partner')
  {
      for(Lead ObjLead:lstTempLead)
      { 
          setConvertedAccountId.add(ObjLead.ConvertedAccountId);    
      }
  }
  
  if(setConvertedAccountId.size()>0 && !setConvertedAccountId.isEmpty())
  {          
    List<Account> lstAccount=[SELECT Id,Name FROM Account WHERE Id In :setConvertedAccountId];
  
    if(lstAccount != null && !lstAccount.isEmpty())
    {
      for(Account acc:lstAccount)
      {                        
        acc.Partner_Agent__c =  UserId; 
      }

    try
    { 
       update lstAccount;
    }
     catch(Exception e)
    {
      System.debug('Error in Updating Account from mapFieldMethod method in AllLeadTriggerClass class'+e.getMessage());
    }
    }
  }   
}
  
/*--------------------------------------------------------------------------------------------------------------------------
Author:Arindam Laik, TCS
Date:03/19/2015
Purpose:Separate business logic from trigger, Code Cleanup/OPtimization and follow saleforce best practices
Item Description:
transfer Competitive Knowledge Object to Account on Lead Conversion
---------------------------------------------------------------------------------------------------------------------------*/   
  Public Static Void transferCompetativeKnowledge(List<Lead> listofLead, Map<id,Lead> newMapofLead ,Map<id,Lead> oldMapofLead)
  {
        Map<String, String> mapLeadIdToConvertedAccountId = new  Map<String, String>();
            
        for(Lead ObjLead:listofLead){
            if(ObjLead.IsConverted == true && ObjLead.IsConverted != oldMapofLead.get(ObjLead.Id).IsConverted)
            { 
                mapLeadIdToConvertedAccountId.put(ObjLead.id,ObjLead.ConvertedAccountId);
            }
        }
    
        if(!mapLeadIdToConvertedAccountId.isEmpty())
        {
            transferRecsOnLeadConvert(mapLeadIdToConvertedAccountId);
        }
    
        checkIfNeedsToFireAssignmentRules(listofLead);
  }
    
  @future
  public Static void transferRecsOnLeadConvert(Map<String,String> mapLeadIdToConvertedAccountId){
            
        List<Competitive_Knowledge__c> lstCompetitiveKnowObject = new List<Competitive_Knowledge__c>();
        List<X3rd_Party_Contract_Service__c> lst3rdParty = new List<X3rd_Party_Contract_Service__c>();
        Map<string, Competitive_Knowledge__c> mapCompetitiveKnowObject = new Map<String,Competitive_Knowledge__c>([Select
                                   Account__c,
                                   Lead__c 
                              from 
                                  Competitive_Knowledge__c
                              where
                                    Lead__c =:mapLeadIdToConvertedAccountId.keySet()
                              
                              order by LastModifiedDate desc
                              
                              Limit 50000]);
        Map<string, X3rd_Party_Contract_Service__c> map3rdParty = new Map<String,X3rd_Party_Contract_Service__c>([Select
                                   Account__c,
                                   Lead__c 
                              from 
                                  X3rd_Party_Contract_Service__c
                              where
                                    Lead__c =:mapLeadIdToConvertedAccountId.keySet()
                              
                              order by LastModifiedDate desc
                              
                              Limit 50000]);                              

        if(!mapCompetitiveKnowObject.isEmpty()){       
            for(string key: mapCompetitiveKnowObject.keySet()){
                mapCompetitiveKnowObject.get(key).Account__c = mapLeadIdToConvertedAccountId.get(mapCompetitiveKnowObject.get(key).Lead__c);    
                mapCompetitiveKnowObject.get(key).Lead__c = null;     
                lstCompetitiveKnowObject.add(mapCompetitiveKnowObject.get(key));
            }
        }
        if(!lstCompetitiveKnowObject.isEmpty()){
            try{
                update lstCompetitiveKnowObject;
                
            }
            catch(Exception e){
                system.debug('Exception::::::::'+e.getmessage());
            }
        }
        
        
        if(!map3rdParty.isEmpty()){
       
            for(string key: map3rdParty.keySet()){
                map3rdParty.get(key).Account__c = mapLeadIdToConvertedAccountId.get(map3rdParty.get(key).Lead__c);    
                map3rdParty.get(key).Lead__c = null;     
                lst3rdParty.add(map3rdParty.get(key));
            }
        }
        if(!lst3rdParty.isEmpty()){
            try{
                update lst3rdParty;
                
            }
            catch(Exception e){
                system.debug('Exception::::::::'+e.getmessage());
            }
        }
    }
    //Check to see if lead assignment rules needs to be fired
    public static void checkIfNeedsToFireAssignmentRules(List<Lead> listOfLeads)
    {
        if(!Interface_Users__c.getInstance().Is_Interface__c)
        return;

        Set<Id> leadIds = new Set<Id> ();
        //Trigger lead reassignment if lead is assigned to Marketing Queue  or Suspicious lead Queue or Marketing Admin user.AboutMe
        for(Lead l : listOfLeads)
        {       
            if((Trigger_Lead_Assignment_On_Update__c.getAll().containsKey(l.ownerId) && l.Assign_to_sales__c == true) || Test.isRunningTest())
            {
                leadIds.add(l.id);
            }   
        }
        
        if(!leadIds.isEmpty() && !System.isFuture())
        {
            triggerAssignmentRules(leadIds);
        }
    }
    
    //Trigger lead assignment rules for a set of leads
    @future
    public static void triggerAssignmentRules(Set<Id> leadIds)
    {
        List<Lead> ls = new List<Lead>();

        for (Id leadId : leadIds) {
        ls.add(new Lead(id = leadId));
        }

        Database.DMLOptions dmo = new Database.DMLOptions();
        dmo.assignmentRuleHeader.useDefaultRule = true;
        Database.update(ls, dmo);
    }
}