trigger AllAccount on Account (before insert, before update, after insert, after update) 
{/* Commented Line numbers : 2, 27, 52, 82, 394, 420 and clocsing comment - 440
    //  joseph uncommented the bypass trigger as Sri did not want this change in the live as ravi data loading records
     // Code removed by Abhishek Dey as per Case - #01754979
     
     BypassTriggerUtility u = new BypassTriggerUtility();  
     if (u.isTriggerBypassed()) {
         return;
     }
     
    /*
     if(Trigger.isBefore && !checkRecursive.runOnce())
     {
         System.debug('Recursion detected before. Exiting.');
         return;           
     }
     if(Trigger.isAfter && !checkRecursiveAfter.runOnce())
     {
         System.debug('Recursion detected after. Exiting.');
         return;           
     }*/
     
     /**
     * Code added by Pratyush to avoid the trigger from executing if it is
     * an update on the Roll-up summary fields from Serialized-Unit-Summary.
     */
     /*if(Trigger.isUpdate) {
        Map<Id, Account> oldMap = Trigger.oldMap;
        List<Account> newList = Trigger.new;
        
        for(Account acct : newList) {
            Account oldAcct = oldMap.get(acct.id);
            if( (acct.Total_TT210_Units__c != oldAcct.Total_TT210_Units__c) ||
                (acct.Total_TT210_3G_Units__c != oldAcct.Total_TT210_3G_Units__c) ||
                (acct.Total_T2_Units__c != oldAcct.Total_T2_Units__c) ||
                (acct.Total_OX_Units__c != oldAcct.Total_OX_Units__c) ||
                (acct.Total_OX2_Units__c != oldAcct.Total_OX2_Units__c) ||
                (acct.Total_OT_Units__c != oldAcct.Total_OT_Units__c) ||
                (acct.Total_MRM100_Units__c != oldAcct.Total_MRM100_Units__c) ||
                (acct.Total_MCP50_Units__c != oldAcct.Total_MCP50_Units__c) ||
                (acct.Total_TT210_Units__c != oldAcct.Total_TT210_Units__c) ||
                (acct.Total_MCP110_Units__c != oldAcct.Total_MCP110_Units__c) ||
                (acct.Total_MCP100T_Units__c != oldAcct.Total_MCP100T_Units__c) ||
                (acct.Total_MCP100S_Units__c != oldAcct.Total_MCP100S_Units__c) ||
                (acct.Total_GT_Units__c != oldAcct.Total_GT_Units__c) ) {
                return;
            }   
        }
    }
    /** END - Code by Pratyush **/
 
    /*List<Account> lstAccount = new List<Account>();
    List<Id> lstId = new List<Id>(); //contains list of owner ids
    if(trigger.isBefore)
    {
        if(trigger.isUpdate||trigger.isInsert)
        {  
           AccountUtils.assignRankingCargoType(Trigger.new);//  Ranking - Cargo Type requires logic that cannot be placed in field update   
           AccountUtils.calDataQualScr(trigger.new);
           //if(!AccountUtils.hasUpdtedPartnerAgent)
           //    AccountUtils.updatePartnerAgt(trigger.new);
           //AccountUtils.populateAR_Rep(trigger.new); // Commented By Abhishek Dey 01/29/2015
           
           AccountUtils.updateSicFields(trigger.old, trigger.new);//  added by joseph hutchins 10/22/2014, populates account sic fields is sic_code__c is present on the account 
           AccountUtils.manageManualAssignmentForAccountTeamCreation(Trigger.old, Trigger.new);//  added by joseph hutchins 10/30/2014
           if(trigger.isUpdate)
           {
                list<string> lstOwnerId = new list<string>();
                Map<string,Account> mapAcctIdnAcctRec = new Map<string,Account>();
                
                for(Id acctId : trigger.newMap.keySet())
                {
                    if(trigger.newMap.get(acctId).ownerId != trigger.oldMap.get(acctId).ownerId) {
                        lstOwnerId.add(trigger.newMap.get(acctId).ownerId);
                    }
                }
                
                /*for(Account acct : trigger.new) {
                    lstOwnerId.add(acct.ownerId);
                }*/
                
                /*List<Account> acctsToPopulateDataShare = new List<Account>();  
                for(Integer i=0;i<trigger.new.size();i++)
                {
                        //Check if the fields in account has been modified. 
                        if(trigger.new[i].Account_Manager__c != trigger.old[i].Account_Manager__c
                           ||trigger.new[i].CSR__c != trigger.old[i].CSR__c
                           ||trigger.new[i].Inside_CSR__c != trigger.old[i].Inside_CSR__c
                           ||trigger.new[i].Sales_Director__c != trigger.old[i].Sales_Director__c
                           ||trigger.new[i].ownerId != trigger.old[i].ownerId
                           ||trigger.new[i].QWBS_Cust_ID__c != trigger.old[i].QWBS_Cust_ID__c)
                           {
                                //lstAcctIds.add(trigger.new[i].id);
                                //system.debug('@@@@lstAcctIds'+lstAcctIds);
                                mapAcctIdnAcctRec.put(trigger.new[i].id,trigger.new[i]);
                                system.debug('@@@@mapAcctIdnAcctRec'+mapAcctIdnAcctRec);
                           }
                          
                         //Changes for CR 01205396
                         if(trigger.new[i].Referral_Account__c != trigger.old[i].Referral_Account__c && trigger.new[i].Referral_Account__c != null)     
                         {
                            acctsToPopulateDataShare.add(trigger.new[i]);
                         }  
                        
                        //Changes for CR 01205363   
                        if(trigger.new[i].Lead_Source_Most_Recent__c == null &&  trigger.new[i].Lead_Source__c != null )
                        {
                            trigger.new[i].Lead_Source_Most_Recent__c = trigger.new[i].Lead_Source__c;
                        }
                        if(trigger.new[i].Lead_Source_Most_Recent__c != null &&  (trigger.new[i].Lead_Source__c == null || trigger.new[i].Lead_Source_Update_Date__c < (System.TODAY()-365)) )
                        {
                            trigger.new[i].Lead_Source__c = trigger.new[i].Lead_Source_Most_Recent__c;
                        }   
                }
                AccountUtils.changeRecordType(trigger.new);
                AccountUtils.RecordOwnerChange(lstOwnerId , trigger.new, trigger.old);
                AccountUtils.preventRecTypeChange(trigger.new, trigger.oldMap);
                AccountUtils.setReseller(trigger.new);
                //Changes for CR 01205396
                if(!acctsToPopulateDataShare.isEmpty())
                {
                    AccountUtils.populateDataSharePartners(acctsToPopulateDataShare);
                }
                
            }               
        }         

        //Update Partner Support Info Details to Unity             
        if(trigger.isUpdate || trigger.isInsert) {
            Set<Id> setRecordOwner = new Set<Id>();
            Map<Id, User> mapUser = null;
            
            for(Account a : Trigger.new) {
                if(null != a.RecordOwner__c) {
                    setRecordOwner.add(a.RecordOwner__c);
                }                        
            }
            
            if(0 != setRecordOwner.size()) {
                mapUser = new Map<Id, User>([
                            SELECT
                                id,
                                AccountId,
                                FederationIdentifier
                            FROM
                                User
                            WHERE
                                id in :setRecordOwner
                            LIMIT
                                :setRecordOwner.size()
                          ]);                
            }
            if(trigger.isInsert) {
                List<Id> lstAcctIds = new List<Id>();
                for(Account a : trigger.new) {
                    lstAcctIds.add(a.id);
                    if(null != a.RecordOwner__c) {
                        a.Support_Account__c = mapUser.get(a.RecordOwner__c).AccountId;
                    }
                    else {
                        a.Support_Account__c = System.Label.Omnitracs_Account_Id;
                    }                                                                       
                }               
            }
            else {
                for(Integer i = 0; i < Trigger.new.size(); i++) {
                    // Check if it is an owner-update. If yes, we need to update the Support-Account
                    if(Trigger.new[i].RecordOwner__c != Trigger.old[i].RecordOwner__c || Trigger.new[i].Support_Account__c == null) {
                        if(null == Trigger.new[i].RecordOwner__c) {
                            // Support Account has to be Omnitracs
                            // Exception: This is not valid for Omnitracs account
                            if(!(Trigger.new[i].id+'').contains(System.Label.Omnitracs_Account_Id))
                            Trigger.new[i].Support_Account__c = System.Label.Omnitracs_Account_Id;
                        }
                        else {
                            // Support account has to be the account Id of the record-owner
                            Trigger.new[i].Support_Account__c = mapUser.get(Trigger.new[i].RecordOwner__c).AccountId;
                        }
                       
                    }
                                        
                } // End for           
            } // End else            
        } // End - if (trigger.isUpdate/isInsert)        
    }
    
    
    if(trigger.isAfter)
    {
       if(trigger.isInsert || trigger.isUpdate)
       {            
            AccountUtils.acctUpdateAcctTerritories(trigger.old,trigger.new, trigger.isUpdate);
            //AccountUtils.createAccountTeams(Trigger.old, Trigger.new);// created by joseph hutchins 10/30/2014
            
            list<string> lstAcctIds = new list<string>();
            for(Account acct:Trigger.new)
            {
                lstAcctIds.add(acct.id);
            }

            if(AccountUtils.isExecuted == false) {
                if( (1 < trigger.new.size()) || // Bulk-update 
                    (PartnerMasterOwnerController.updtPartnerAgent == true)) { // Owner assignment
                    AccountUtils.partnerAgentUpdate(lstAcctIds);
                }                                           
            }
           
            if(trigger.isInsert && !System.isFuture())
            {
                AccountUtils.UpdateAccountForPRMUser(lstAcctIds,trigger.isInsert);                  
            } 
            
            // Update Partner Support Info Details to Unity .
            //  Execute this code only if it is not a bulk-update.
                         
            if( trigger.isUpdate || trigger.isInsert ) {                
                List<Id> lstAccountIds = new List<Id>();
                List<Id> lstSupportAccountIds = new List<Id>();
                List<Id> lstCSRId = new List<Id>();                
                                
                if(trigger.isInsert) {
                    for(Account a : trigger.new) {
                        lstAccountIds.add(a.id);
                        if(null != a.Support_Account__c) {
                            lstSupportAccountIds.add(a.Support_Account__c);
                        }                       
                        if(null != a.CSR__c) {
                            lstCSRId.add(a.CSR__c);
                        }                        
                    }
                }
                else {
                   boolean isOnboardingStatusChanged = false;
                    for(Integer i = 0; i < Trigger.new.size(); i++) {
                        
                        if((Trigger.old[i].UnityOnboardStatus__c!= Trigger.new[i].UnityOnboardStatus__c))
                        {
                            isOnboardingStatusChanged = true;
                        }
                        else
                        {
                            isOnboardingStatusChanged = false;
                        }
                        
                        if(   (Trigger.old[i].District__c != Trigger.new[i].District__c)
                           || (Trigger.old[i].Support_Account__c != Trigger.new[i].Support_Account__c)
                           || (Trigger.old[i].RecordOwner__c != Trigger.new[i].RecordOwner__c)
                           || (Trigger.old[i].CSR__c != Trigger.new[i].CSR__c)
                           || isOnboardingStatusChanged ) {
                            
                            if(Trigger.new[i].AGUID__c != null)
                            lstAccountIds.add(Trigger.new[i].id);
                            
                            if(null != Trigger.new[i].Support_Account__c) {
                                lstSupportAccountIds.add(Trigger.new[i].Support_Account__c);
                            }                       
                            if(null != Trigger.new[i].CSR__c) {
                                lstCSRId.add(Trigger.new[i].CSR__c);
                            }   
                        }                                
                    }                
                } // End else
                
                if((0 < lstAccountIds.size()) && !System.isFuture()) {
                    AccountUtils.updatePartnerSupportDetails(lstAccountIds, lstSupportAccountIds, lstCSRId);
                }
            } // End - if (trigger.isUpdate/isInsert)        
       }
   }
   
   if(Trigger.isAfter && Trigger.isUpdate) {
   
    if(!System.isFuture())
    {
        map<Id,String> MapAccountIdLegalName = new map<Id,String>();
        
        for(Account objAccount:trigger.new)
        {
            if(objAccount.Legal_Name__c != trigger.oldMap.get(objAccount.Id).Legal_Name__c)
            {
               MapAccountIdLegalName.put(objAccount.Id,objAccount.Legal_Name__c);
            }
        }
        
        if(!MapAccountIdLegalName.isEmpty())
            AccountUtils.Update_Quotes_AccountLegalName(MapAccountIdLegalName);
    }
    
    if(!System.isFuture() && !AccountUtils.HasAccountTriggerExecuted())
    {
    List<Id>listClosedStatusAccountId = new List<Id>();
    List<Id>listDormantAccountsWhoseContactsToBeDeactivated = new List<Id>();
    List<Id>listClosedStatusAccountIdTLorPartner = new List<Id>();
        for(Account a : trigger.new)
        {
            //Check if status has changed
            if(a.QWBS_Status__c != trigger.oldMap.get(a.id).QWBS_Status__c)
            { 
                //Check if new status is a closed status
                if(AccountUtils.checkIfClosedStatus(a.QWBS_Status__c)) 
                {
System.debug('******************* Status changed to a closed status');                  
                    listClosedStatusAccountId.add(a.id);
                    
                    //Check if recordType is TL or Partner (for CR 103555)
                    if(AccountUtils.checkIfTLOrPartnerAcc(a.recordTypeId))
                    listClosedStatusAccountIdTLorPartner.add(a.id);
                    
                }   
                
                
                if((a.Closed_Reason__c != trigger.oldMap.get(a.id).Closed_Reason__c)&&((a.Closed_Reason__c == AccountUtils.CLSD_RSN_OUT_OF_BUS || a.Closed_Reason__c ==  AccountUtils.CLSD_RSN_NON_PAY )  
                            || (
                                a.recordTypeId == AccountUtils.OTHER_ACCOUNT_RECORD_TYPE_ID
                                && a.QWBS_Market__c == 'Service Center'
                                && a.District__c == 'Service Center'
                                && a.QWBS_Status__c == 'Inactive' 
                            )))
                    {
System.debug('******************* Dormant account, contact needs to be deactivated');  
                        listDormantAccountsWhoseContactsToBeDeactivated.add(a.id);
                    } 
                
            }
        }
        if(!listDormantAccountsWhoseContactsToBeDeactivated.isEmpty())
        AccountUtils.inactivateContactsFromDormantAccounts(listDormantAccountsWhoseContactsToBeDeactivated); 
        if(!listClosedStatusAccountId.isEmpty())
        AccountUtils.remNotTypesAndChangeOwnerFromDormantAcc(listClosedStatusAccountId);
        //for CR 103555
        if(!listClosedStatusAccountIdTLorPartner.isEmpty())
        AccountUtils.changeOpprStageToClosedLost(listClosedStatusAccountIdTLorPartner);    
        }
        AccountUtils.AccountTriggerExecuted();
    }
    
  // Code added by Pintoo as per CR 105284  to valide State field during Lead Conversion     
     
     if((Trigger.isAfter && Trigger.isInsert) || (Trigger.isBefore && Trigger.isUpdate))
     {  
         List<Account> acctoUpdate = new List<Account>();
         Map<id,String> mapOfAccntIdToBillState = new Map<id,String>();
          for(Account acc: trigger.new)
          {
            if(!(acc.RecordTypeId + '').contains('01250000000Qxbn'))  
            {
             
              if(acc.BillingCountry == 'US' || acc.BillingCountry == 'USA' || acc.BillingCountry == null || acc.BillingCountry == '')
              {
    
                 if(acc.BillingState != null )
                  {
                       String validCode = AccountUtils.getStateCode(acc.BillingState);
                       
                          if(validCode == null || validCode.length() < 2)
                          {
                                if(!Test.isRunningTest())    
                                {
                                    acc.addError('A state is required for US addresses and must be capitalized two letter state code(i.e., CA, AZ).');
                                }
                          }
                          else 
                          {
                            if(acc.BillingState != validCode && (Trigger.isAfter && Trigger.isInsert))
                            mapOfAccntIdToBillState.put(acc.id,validCode);
                            if(acc.BillingState != validCode && (Trigger.isBefore))
                            acc.BillingState = validCode;
                          } 
                                                                             
                  }
                  else
                  {
                  if(!Test.isRunningTest()) 
                  {
                    acc.addError('A state is required for US addresses and must be capitalized two letter state code(i.e., CA, AZ).');
                }
                  }
               
                 
               }
            }  
           }
           if(!mapOfAccntIdToBillState.isEmpty() && (Trigger.isAfter && Trigger.isInsert))
           {
            AccountUtils.updateStateCode(mapOfAccntIdToBillState);
           }
      }
  
      /**Code added as a part of CR 01205420
        *@Amrita G
        *Calculates sum of open activities on account and update field Sum of Open Activities 
        *it's the number of Activities (Tasks) whose Status is not Completed. 
        **/
         /*if(Trigger.isAfter 
            && system.label.Activate_Summation_of_Open_Activity == 'true'
            && CalculateSumOfOpenActivities.firstRun){
                system.debug('@@@@CalculateSumOfOpenActivities.firstRun in trigger before method'+ CalculateSumOfOpenActivities.firstRun);
                CalculateSumOfOpenActivities.firstRun = false;
               
                //Abhishek made  'calSumOfOpenActv' method as future method to avoid SOQL error.
                List<ID> accountRecordIds = new list<ID>();
                
                for(Account accData : trigger.new)
                {
                    accountRecordIds.add(accData.id);
                }
                
                if(!accountRecordIds.isEmpty() && !System.isFuture())
                {
                CalculateSumOfOpenActivities.calSumOfOpenActv(accountRecordIds);
                }
                system.debug('@@@@CalculateSumOfOpenActivities.firstRun in trigger after method'+ CalculateSumOfOpenActivities.firstRun);
    }
    
    /*   @Author: JBarrameda
    *    @Date: 09/25/2014
    *    @Description: For Netsuite-Account integration
    */
    
    /*if (((trigger.isAfter && trigger.isInsert) || (trigger.isAfter && trigger.isUpdate)) && Trigger.size == 1 && !System.isFuture()){
        
        if (!NetsuiteSyncAccountHelper.hasRun && !NetsuiteSyncContactHelper.hasRun){
            Set<Id> accIdList = new Set<Id>();
            for(Account a:trigger.new){
            
                if(a.Send_to_Netsuite__c == true ){
                    System.debug('**** BEGIN CODE for Netsuite Integration:' + a.Id);
                    accIdList.add(a.Id);
                }
            
            }  
            
            if(accIdList.size()>0){
                NetsuiteSyncAccountHelper.postDataToNetsuite(accIdList);        
            }
            
            //Set hasRun boolean to true to prevent recursion
            NetsuiteSyncAccountHelper.hasRun = true;
        }
    }*/
         

}