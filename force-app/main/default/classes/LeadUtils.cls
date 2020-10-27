/***********************************************************************************
Author: Prakash Ramasway, Salesforce.com Developer
EDL Consulting
Description: Functionality to assign account name based on load owner
************************************************************************************/

public with sharing class LeadUtils {
    /*
    public static final String STRING_GROUP_PREFIX = '00G';
    public static final String STRING_PARTNER_QUEUE = 'Partner Queue';
    public static final String STRING_MASTER_PARTNER_QUEUE = 'Master Partner Queue';
    public static Map<String,String> groupAccountIdMap; 
    
    
    public static void fetchAccountName(List<Lead> leadList){
        updateGroupAccountMapping();
    
        //make sure there are leads to process
        if(leadList!=null && leadList.size()>0){
        //fetch  
       
            for(Lead leadInstance:leadList){
                //the owner is a group
                if(leadInstance!=null && leadInstance.OwnerId!=null){
                    
                    String leadOwnerId=leadInstance.OwnerId;
                    
                    if(leadOwnerId.startsWith(STRING_GROUP_PREFIX)){
                        if(groupAccountIdMap!=null && groupAccountIdMap.get(leadOwnerId)!=null){
                            leadInstance.PartnerAccount__c=groupAccountIdMap.get(leadOwnerId);
                        }
                        //check if we have 15 digit ids in custom setting.
                        else if(groupAccountIdMap!=null && groupAccountIdMap.get(leadOwnerId.substring(0,15))!=null){
                            leadInstance.PartnerAccount__c=groupAccountIdMap.get(leadOwnerId.substring(0,15));
                        }
                        else{
                            leadInstance.PartnerAccount__c=null;
                        }
                    }
                    //partner account id is not null meaning the lead
                    //is owned by a partner user
                    else if(leadInstance.PartnerAccountId!=null){
                        leadInstance.PartnerAccount__c=leadInstance.PartnerAccountId;
                    }
                    else{
                        leadInstance.PartnerAccount__c=null;
                    }
                }
            }
        }
    }   
    //  code added by joseph hutchins uat 3 11/19/2014
    public static void MapStatusFromLifeCycleStatus(Lead theLead)
    {
        //  tried to do this as a workflow/field update but the field update only allows you update the status field
        //  with another value in the status picklist
        if (!util.isblank(theLead.Lifecycle_status__c))
        {
            //  theLead.Status is s required field and cannot be moved from the page layout so we need to make sure
            //  the life cycle status is not null before bmaking this assignment
            theLead.Status = theLead.Lifecycle_Status__c;
        }
    }
    public static void checkLeadCityStateCountryAndAssignRegion(Lead leadToCheck, List<Country_And_Country_Code__c> allCountries)
    {
        util.debug('inside of checkLeadCityStateCountryAndAssignRegion method in LeadUtils');
        
               
        system.assertNotEquals(null, leadToCheck);
        
        util.debug('various lead values: lead.country: ' + lead.country + ' lead.city: ' + lead.city + ' lead.State: ' + lead.State);
        
        string defaultErrorMessage = 'This country name does not match any of the valid ' + 
                                   'countries stored in the Country Object.';
        string errorMessage = 'Required Field is Missing';
        
        //  we'll check country first, this will let us know if the lead is domestic or not,
        //  then if it's domestic we'll check the state and city are set
        
        leadToCheck.Country = checkForUnitedStatesAbbreviations(leadToCheck.Country);
        
        util.debug('after checking lead country for us abbreviations, its value is: ' + leadtocheck.country);
                                   
        if (!doesCountryNameExistOrIsSpelledCorrectly(leadToCheck.Country, allCountries))
        {
            util.debug('after checking country agaisnt country code table, found that country was not spelled correctly.');
            leadtoCheck.Country.addError('Country: ' + defaultErrorMessage);
        }
        else
        {
            //  if the country is set correctly, then we'll get the country and country code and grab the region from the record
            Country_And_Country_Code__c tempCCC = findCountryCodeUsingCountryName(leadToCheck.Country, allCountries);
            if (tempCCC != null)
            {
                leadTocheck.Region__c = tempCCC.Region__c;
            }
            
        }
        
        //  lets check the state and city if domestic lead
        if (leadToCheck.Country == 'United States')
        {
            util.debug('lead country is United States. begiinning to check city and state...');
            
            if (Util.isblank(leadTocheck.City))
            {
                util.debug('city is blank');
                leadToCheck.City.AddError('City: ' + errorMessage);
            }
            if (util.isBlank(leadToCheck.State))
            {
                util.debug('state is blank');
                leadToCheck.state.addError('State: ' + errorMessage);
            }
            else if (leadToCheck.State.length() > 2 || !isLeadStateValid(leadToCheck.State))//  state should be abbrievated
            {
                leadToCheck.State.addError('State must be capitalized and use 2 letter abbreviation');
            }
        }
            
    }
    
    private static boolean isleadStateValid(string state)
    { 
        return state == 'AL' ||
            state == 'AR' ||
            state == 'AZ' ||
            state == 'AK' ||
            state == 'CA' ||
            state == 'CO' ||
            state == 'CT' ||
            state == 'DE' ||
            state == 'DC' ||
            state == 'FL' ||
            state == 'GA' ||
            state == 'HI' ||
            state == 'ID' ||
            state == 'IL' ||
            state == 'IN' ||
            state == 'IA' ||
            state == 'KS' ||
            state == 'KY' ||
            state == 'LA' ||
            state == 'ME' ||
            state == 'MD' ||
            state == 'MA' ||
            state == 'MI' ||
            state == 'MN' ||
            state == 'MS' ||
            state == 'MO' ||
            state == 'MT' ||
            state == 'NE' ||
            state == 'NV' ||
            state == 'NH' ||
            state == 'NJ' ||
            state == 'NM' ||
            state == 'NY' ||
            state == 'NC' ||
            state == 'ND' ||
            state == 'OH' ||
            state == 'OK' ||
            state == 'OR' ||
            state == 'PA' ||
            state == 'RI' ||
            state == 'SC' ||
            state == 'SD' ||
            state == 'TN' ||
            state == 'TX' ||
            state == 'UT' ||
            state == 'VT' ||
            state == 'VA' ||
            state == 'WA' ||
            state == 'WV' ||
            state == 'WI' ||
            state == 'WY' ||
            state == 'PR';
    }
    public static void updateHiddenLeadSourceFields(Lead l, boolean canBypassWorkFlows)
    {
        //  there was a workflow that was perfomring this job but the workflow has been deactived
        //  as it was appearing as though the 4 rules were not firing in the proper order
        if (!canByPassWorkFlows)
        {
            // this should only fire on insert, so these fields should already be blank, but check for blankness just in case
            if (!Util.isBlank(l.LeadSource) ) 
            {
                if (Util.isBlank(l.Hidden_Original_Lead_Source__c))
                {
                    l.hidden_original_lead_source__c = l.LeadSource;
                }
                if (util.isBlank(l.Hidden2_Original_Lead_Source__c))
                {
                    l.Hidden2_Original_Lead_Source__c = l.LeadSource;
                }
                if (util.isBlank(l.Hidden3_Original_Lead_Source__c))
                {
                    l.Hidden3_Original_Lead_Source__c = l.LeadSource;
                }
            }
            
        }
        
    }
    public static boolean doesCountryNameExistOrIsSpelledCorrectly(string countryName, List<Country_And_Country_Code__c> countryCodeRecords)
    {
        util.debug('inside of doesCountryNameExistOrIsSpelledCorrectly, countryName = ' + countryName + 
            ' num of country codes passed in: ' + countryCodeRecords.size());
        string countryNameLowerCase = countryName == null ? null : countryName.toLowerCase();
        
        if (countryNameLowerCase != null)
        {
            for (Country_And_Country_Code__c ccc : countryCodeRecords)
            {
                
                if (ccc.Name != null && 
                    ccc.Name.toLowerCase().equals(countryNameLowerCase))
                {
                    return true;
                }                       
            }
            return false;
        }
        else
        {
            return false;
        }
    }
    
    private static string checkForUnitedStatesAbbreviations(string countryName)
    {
        
        if (countryName == null)
        {
            return null;
        }
        else
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
    private static decimal nullToZero(decimal d)
    {
        return (d == null ? 0 : d);
    }
    //  end code added by joseph hutchins uat 3 11/19/2014
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
    
    public static void updateLeadMetaData(List<Lead> leadsnew, Map<ID, Lead> leadsold) {
        
        try{
            
        
        if(leadsnew == null || leadsnew.size() < 1 || leadsold == null) return;
        
        // Find the queues we're interested in, they will be the keys of the groupAccountIdMap
        updateGroupAccountMapping();

        // groupAccountIdMap will contain the all the Distis and VARs, we also need the master queue.
        String masterqueueid = '';
        for(PRMMasterLeadQueue__c p : PRMMasterLeadQueue__c.getAll().values()) {
            if(STRING_PARTNER_QUEUE.equals(p.name)) masterqueueid = StringUtils.substring(p.PRMMasterQueue__c, 0, 15);
        }
        
        // These are the account ids defined as distributors (PANA).
        Set<String> distiids = new Set<String>();
        for(PartnerMasterOwnerAccount__c pmoa : PartnerMasterOwnerAccount__c.getAll().values()) {
            distiids.add(StringUtils.substring(pmoa.OwnerAccountId__c, 0, 15));
        }
        
        // Query for all the proper queue names.
        Map<ID, Group> groupIDtoName = new Map<ID, Group>([
            select Name
            from Group
            where ID in :groupAccountIdMap.keySet()
                  or ID = :masterqueueid
        ]);
        
        List<GroupMember> mpqMemebers = new List<GroupMember>();
        mpqMemebers = [Select UserOrGroupId from GroupMember where GroupId =:masterqueueid limit 50000];
        Set<String> setOfmpqMemebersId = new Set<String>();
        
        //create the list of id of member Master Partner Queue 
        if(!mpqMemebers.isEmpty()){
            for(GroupMember grpMem:mpqMemebers){
                String str = grpMem.UserOrGroupId;
                str = str.subString(0,15);
                setOfmpqMemebersId.add(str);   
            }       
        }
        
        system.debug('@@@@@setOfmpqMemebersId:::::'+setOfmpqMemebersId);
        
        for(Lead l : leadsnew) {
            if(l == null) continue;
            
            String ownerid = StringUtils.substring(l.ownerid, 0, 15);
            String oldownerid = StringUtils.substring(leadsold.get(l.id).OwnerId, 0, 15);
            String partneraccountid = StringUtils.substring(l.PartnerAccountId, 0, 15);
            String oldpartneraccountid = StringUtils.substring(leadsold.get(l.id).PartnerAccountId, 0, 15);
            
            // We're not interested if the owner didn't change
            if(oldownerid == null || ownerid.equals(oldownerid)) 
                continue;
            
            // Was the prior owner a queue?
            if(
                groupIDtoName.containsKey(oldownerid)   // Use groupIDtoName where since we want all the queues, including master.
            ) {
                l.Last_Queue_Owner__c = groupIDtoName.get(oldownerid).Name;
            }
            //If the lead was owned my members of master partner queue then the last Queue owner will be MPQ [Added for the CR 01218523] 
            // Assigned from master queue.
            system.debug('@@@@oldownerid::::'+ oldownerid);
            if(!setOfmpqMemebersId.isEmpty() && setOfmpqMemebersId.contains(oldownerid)){
                system.debug('@@@@@@Last_Queue_Owner__c::::'+l.Last_Queue_Owner__c);
                l.Last_Queue_Owner__c = STRING_MASTER_PARTNER_QUEUE;        
            }
            
            system.debug('@@@@@l.Assigned_From_MPQ_QES_Date__c::::'+l.Assigned_From_MPQ_QES_Date__c);
            system.debug('masterqueueid.equals(oldownerid)'+masterqueueid.equals(oldownerid));
            system.debug('setOfmpqMemebersId.contains(oldownerid)'+setOfmpqMemebersId.contains(oldownerid));
            if(
                (masterqueueid.equals(oldownerid)||
                    (!setOfmpqMemebersId.isEmpty() 
                    && setOfmpqMemebersId.contains(oldownerid)) )            // Old owner was the master queue OR old owner was member of MPQ.                
                && l.Assigned_From_MPQ_QES_Date__c == null  // Not previously set.
            ) {
                l.Assigned_From_MPQ_QES__c = true;
                system.debug('@@@@@@Last_Queue_Owner__c::::'+l.Last_Queue_Owner__c);
                system.debug('@@@@Assigned_From_MPQ_QES__c'+l.Assigned_From_MPQ_QES__c);
                
                    l.Assigned_From_MPQ_QES_Date__c = Datetime.now();
                    system.debug('@@@@Assigned_From_MPQ_QES__c:::::1111'+l.Assigned_From_MPQ_QES_Date__c);
                
            }
            
            // Was the lead accepted by a distributor (PANA)?
            if(
                groupAccountIdMap.containsKey(oldownerid)   // The old ownerid is defined as a PRM queue.
                && distiids.contains(partneraccountid)      // The new lead has a PartnerAccountID => owned by a disti partner user.
            ) {
                l.Accepted_By_PANA_Disti__c = true;
                l.Accepted_By_PANA_Disti_Date__c = Datetime.now();
            }
            
            // Did the lead get assigned from a distributor (PANA)?
            if(
                distiids.contains(oldpartneraccountid)          // The old lead has PartnerAccountID defined as a disti.
                && groupAccountIdMap.containsKey(ownerid)       // The new owner is a PRM queue.
                && l.Assigned_From_PANA_Disti_Date__c == null   // Not previously set.
            ) {
                l.Assigned_From_PANA_Disti__c = true;
                l.Assigned_From_PANA_Disti_Date__c = Datetime.now();
                l.First_assigned_VAR__c = groupAccountIdMap.get(ownerid);
            }
            
            // Was the lead accepted by a VAR?
            if(
                groupAccountIdMap.containsKey(oldownerid)   // The old ownerid was a PRM queue.
                && partneraccountid != null                 // The lead is now owned by a partner user.
                && !distiids.contains(partneraccountid)     // Cannot be a disti at this point.
            ) {
                l.Accepted_By_VAR__c = true;
                l.Accepted_By_VAR_Date__c = Datetime.now();
            }
            
            // Was the lead assigned from a VAR?
            if(
                groupIDtoName.containsKey(ownerid)
                
                         // The owner id is a PRM queue or master queue.
                && oldpartneraccountid != null              // The old owner was a partner user.
                && !distiids.contains(oldpartneraccountid)  // The old partner owner wasn't a disti.
                && l.Assigned_From_VAR_Date__c == null      // Not previously set.
            ) {
                system.debug('inside the loop i want');
                l.Assigned_From_VAR__c = true;
                l.Assigned_From_VAR_Date__c = Datetime.now();
            }
            system.debug('Old owner set:'+oldownerid);
            system.debug('Old owner set setOfmpqMemebersId:'+setOfmpqMemebersId);
            system.debug('Old owner set setOfmpqMemebersId.contains(oldownerid):'+setOfmpqMemebersId.contains(oldownerid));
            system.debug('Old owner set groupAccountIdMap.containsKey(ownerid):'+groupAccountIdMap.containsKey(ownerid));
            // Was the lead assigned to a Partner from the master queue?
            if(
                (masterqueueid.equals(oldownerid) || (!setOfmpqMemebersId.isEmpty() && setOfmpqMemebersId.contains(oldownerid)))                   // The previous owner is the master queue.       
                && groupAccountIdMap.containsKey(ownerid)           // The owner is a PRM queue.
                //&& l.Assigned_To_VAR_From_MPQ_QES_Date__c == null   // Not previously set. //Commented for CR 89323
            ) {
                system.debug('inside assigne lead from mpq to partner');
                l.Assigned_To_VAR_From_MPQ_QES__c = true;
                l.Last_Assigned_From_MPQ_to_Partner_Date__c = Datetime.now();
                l.Last_Assigned_From_MPQ_to_Partner__c = groupAccountIdMap.get(ownerid);
                
            }
        }
        }
        catch(exception e)
        {
            
        }
    }
    
    public static void updateReferralPartnerIdFromAccountToLead(List<Lead> leadsnew,Map<ID, Lead> leadsold) {
        if(leadsnew == null || leadsnew.size() < 1) return;
        
        // Collect all the Referral Partner IDs that were inserted.
        Set<Lead> insertedReferralPartnerIds = new Set<Lead>();
        for(Lead l : leadsnew) {
            if(l.Referral_Partner_ID__c != null
                && (
                    l.Primary_Contact_Name__c == null
                    || l.Primary_Contact_Phone__c == null
                    || l.Primary_Contact_Email__c == null
                )
            ) {
                insertedReferralPartnerIds.add(l);
            }
        }
        
        // If we don't find any, we're done.
        if(insertedReferralPartnerIds.size() < 1) return;
        
        // Pluck all the Referral Partner IDs that were inserted.
        Set<String> referralPartnerIds = new Set<String>();
        for(Lead l : insertedReferralPartnerIds) referralPartnerIds.add(l.Referral_Partner_ID__c);
        
        // Grab all the accounts that reference all the Referral Partner IDs that were inserted.
        List<Account> accounts = new List<Account>([
            select  id
                    ,Primary_Contact_Name__c
                    ,Primary_Contact_Phone__c
                    ,Primary_Contact_Email__c
                    ,Referral_Partner_ID__c
            from    Account
            where   RecordType.Name = 'Partner Referral'
                    and Referral_Partner_ID__c in :referralPartnerIds
        ]);
        
        // If find dupes, throw them away.
        Map<String, Account> referralId_account = new Map<String,Account>();
        Set<String> toRemove = new Set<String>();
        for(Account a : accounts) {
            if(!referralId_account.containsKey(a.Referral_Partner_ID__c)) {
                referralId_account.put(a.Referral_Partner_ID__c,a);
            }
            else {
                toRemove.add(a.Referral_Partner_ID__c);
            }
        }
        if(toRemove.size() > 0) {
            for(String s : toRemove)
               referralId_account.remove(s);
        }
        
        // Update the appropriate Leads.
        for(Lead l : insertedReferralPartnerIds) {
            if(referralId_account.containsKey(l.Referral_Partner_ID__c)) {
                Account a = referralId_account.get(l.Referral_Partner_ID__c);
                l.Referral_Account__c = a.id;
                l.Primary_Contact_Name__c = a.Primary_Contact_Name__c;
                l.Primary_Contact_Phone__c = a.Primary_Contact_Phone__c;
                l.Primary_Contact_Email__c = a.Primary_Contact_Email__c;
            }
        }
        
        if(!insertedReferralPartnerIds.isEmpty())
        {
            List<Lead> leadsToPopulateDataShare = new List<Lead>();
            leadsToPopulateDataShare.addAll(insertedReferralPartnerIds);
            populateDataSharePartners(leadsToPopulateDataShare);
        }
    }
    /*
    Populates the Reseller/Distributor Lead Created By field with the account of the user who is creating the lead.
    */
    /*
    public static void populateCreatedByReseller(List<Lead> listOfLeads)
    {
        String QualcommAccountId = Label.Qualcomm_Account_Id;
        List<Id> listOfCreatedByUserId = new List<Id>();
        for(Lead l : listOfLeads)
        {
            if(l.Company_Lead_Created_By__c == null && ((l.RecordTypeId+'').contains(label.Partner_Reseller_Lead) ||  (l.RecordTypeId+'').contains(label.T_L_Lead)))
            listOfCreatedByUserId.add(l.createdById);
        }
        
        if(!listOfCreatedByUserId.isEmpty())
        {
            Map<Id, User> mapOfIdToUser = new Map<Id, User>([select id, contactId, contact.AccountId from User where id IN: listOfCreatedByUserId]) ;
        
            for(Lead l : listOfLeads)
            {
                if(mapOfIdToUser.containsKey(l.createdById)) 
                {   
                    if(mapOfIdToUser.get(l.createdById).contactId != null)
                    l.Company_Lead_Created_By__c = mapOfIdToUser.get(l.createdById).contact.AccountId;
                    else
                    l.Company_Lead_Created_By__c = QualcommAccountId;
                }   
            }
        }
    }
    
   //Code Added by Pintoo as per CR 105284 
   // CR 105284 implemented with Custom settings method
    
    public static void getStateCode(List<Lead> lstleads)
    { 
        try{
          State__c sCode;
          String stateCodeValue;
          Map<String,State__c> mapCodes = State__c.getAll();
         
          List<State__c> listOfCodes = State__c.getAll().values();
          Set<String> setofStateCode = new Set<String>();
          
              for(State__c cd : listOfCodes)
              {
                  setOfStateCode.add(cd.StateCode__c);
              }              
                    
              for(Lead ld: lstleads){                 
              if(ld.Country == 'US' || ld.Country == 'USA' || ld.Country == '' || ld.Country == null)
              {                   
                if(ld.State != null && mapCodes.containsKey(ld.State))
                {
                 sCode = State__c.getInstance(ld.State);
                 stateCodeValue = sCode.StateCode__c;
                 if(stateCodeValue != null && stateCodeValue != '')
                  {
                     ld.State = stateCodeValue;
                  }
                  else
                  {   
                     ld.State = ld.State;          
                  }
                } 
                else if(setOfStateCode.contains(ld.State) && ld.State != null && ld.State != '')
                { 
                 ld.State = ld.State;
                }
                else
                {                 
                 ld.State = ld.State;
                }                  
              }
            
            }
        }
        catch(exception e)
        {
            
        }
    }

// Code Added By Pintoo as per CR 68311 to transfer Competitive Knowledge Object to Account on Lead Conversion
// updated for CR 00109032
 @future
 public Static void transferRecsOnLeadConvert(Map<String,String> mapLeadIdToConvertedAccountId){
         
          System.debug('*******************Inside Method************');       
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
    
      System.debug('*****************map of CompeKnow Object************'+mapCompetitiveKnowObject );
      System.debug('*****************map of map3rdParty************'+map3rdParty ); 
        if(!mapCompetitiveKnowObject.isEmpty()){
       
            for(string key: mapCompetitiveKnowObject.keySet()){
                mapCompetitiveKnowObject.get(key).Account__c = mapLeadIdToConvertedAccountId.get(mapCompetitiveKnowObject.get(key).Lead__c);    
                mapCompetitiveKnowObject.get(key).Lead__c = null;     
                lstCompetitiveKnowObject.add(mapCompetitiveKnowObject.get(key));
            }
        }
        if(!lstCompetitiveKnowObject.isEmpty()){
            try{
                System.debug('*****************lstCompetitiveKnowObject************'+lstCompetitiveKnowObject ); 
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
                System.debug('*****************lst3rdParty************'+lst3rdParty ); 
                update lst3rdParty;
                
            }
            catch(Exception e){
                system.debug('Exception::::::::'+e.getmessage());
            }
        }
    }
    //Check to see if lead assignment rules needs to be fired
    //CR 01205345
    public static void checkIfNeedsToFireAssignmentRules(List<Lead> listOfLeads)
    {
        if(!Interface_Users__c.getInstance().Is_Interface__c)
        return;
        
        Set<Id> leadIds = new Set<Id> ();
        //Trigger lead reassignment if lead is assigned to Marketing Queue  or Suspicious lead Queue or Marketing Admin user.AboutMe
        for(Lead l : listOfLeads)
        {       
            System.debug('************ owner: '  + l.ownerId);
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
    //CR 01205345
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
    
    //Changes for CR 01205396
    //To populate Data share partner field based on the referral partner entered
    public static void populateDataSharePartners (List<Lead> leadsToPopulateDataShare)
    {
        Set<Id> SetOfReferralPartnerIds = new Set<Id>();
        
        for(Lead l : leadsToPopulateDataShare)
        {
            SetOfReferralPartnerIds.add(l.Referral_Account__c);
        }
        
        Map< Id, Data_Sharing_Partner__c>  dspMap = new Map< Id, Data_Sharing_Partner__c> ();
                
        for(Data_Sharing_Partner__c dsp: [select id,Related_Account__c from Data_Sharing_Partner__c where Related_Account__c IN:SetOfReferralPartnerIds  ])
        {
            dspMap.put(dsp.Related_Account__c, dsp);
        }       
        for(Lead l : leadsToPopulateDataShare)
        {
            if(dspMap.containsKey(l.Referral_Account__c))
            {
            l.Data_Share_Partner__c = dspMap.get(l.Referral_Account__c).id;
            }
            
        }       
        
    }
    
    //  added by joseph hutchins 10/22/2014
    public static void updateSicFields(List<Lead> leads)
    {
        //  mass query the sic table for mulitple account procesing
        Sic__c[] allSics = [select id, name, description_general__c, description_detailed__c, reporting__c from SIC__c];
        for (Lead singleLead : leads)
        {
            if (singleLead.sic_code__c != null)
            {
                Sic__c tempSicRecord = findSicRecord(allSics, singleLead.sic_code__c);
                if (tempSicRecord != null)
                {
                    singleLead.SIC_Description_General__c = tempSicRecord.description_general__c;
                    singleLead.SIC_Description_Detailed__c = tempSicrecord.description_detailed__c;
                    singleLead.SIC_Reporting_Description__c = tempSicRecord.reporting__c;
                }
            }
        }
    }
     private static Sic__c findSicRecord(List<Sic__c> sics, string sicCode)
       {
            for (Sic__c singleSic : sics)
            {
                if (singleSic.name == siccode)
                {
                    return singleSic;
                }
            }
            return null;
       }
   */
 }