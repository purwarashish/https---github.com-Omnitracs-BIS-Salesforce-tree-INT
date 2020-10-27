/*********************************************************************************************************
Modified By  : Rittu Roy
Modified Date: 1/20/2016
Reason       : Case #02149022 - Added method call 'updateForecastDates', to update shipment forecast dates
               based on opportunity close date

**********************************************************************************************************/
trigger AllOpportunityTrigger on Opportunity (before Insert, After Insert, before update, 
                                              after update, before delete, after delete) {
    
    BypassTriggerUtility u = new BypassTriggerUtility();  
    if (u.isTriggerBypassed()) {
        return;
    }
    
    Integer checkVal = Integer.valueof(System.Label.RecursiveTriggerCount);
    
    if(Trigger.isBefore)
    {                        
        if(Trigger.isInsert)
        {
            //Following code is to stop multiple execution of trigger
            //if(!checkRecursive.runOnce()) return;
            if(Test.isrunningTest() || OpportunityUtils.beforeInsertExecuted <= checkVal)
            {
                OpportunityUtils.beforeInsertExecuted ++;
            
                //code unit for OpportunityAll
                OpportunityUtils.updateOpptAmountMc(Trigger.new);
                try{
                    OpportunityUtils.checkForPrimaryContactRolesIfStageNegotiateLost(Trigger.new, true);
                 // OpportunityUtils.assignGeoRegionAndOpptCountryIfNeeded(Trigger.new);
                }
                catch(Exception e){
                    EmailClassRoadnet.SendErrorEmail('checkForPrimaryContactRolesIfStageNegotiateLost failed due to: ' + e.getMessage(), null);
                }
             // OpportunityUtils.assignSalesTeamManagerAndDarManager(Trigger.new);
                OpportunityUtils.CloningValidation(Trigger.new);
                OpportunityUtils.updatePriceBookForSBQuote(Trigger.new, null);
                OpportunityUtils.updateNegotiationType(Trigger.new);
            }    
        }
        
        if(Trigger.isUpdate)
        {
            //Following code is to stop multiple execution of trigger
            //if(!checkRecursive.runOnce()) return;
            if(Test.isrunningTest() || OpportunityUtils.beforeUpdateExecuted <= checkVal)
            {
                OpportunityUtils.beforeUpdateExecuted ++;
                
                //code unit for Sp_Opportunitytrigger
                OpportunityUtils.SPValidation(Trigger.newMap, Trigger.oldMap,Trigger.Size);
                
                //code unit for Opportunitytrigger
                //OpportunityUtils.oppStageOnChange(Trigger.new, Trigger.oldMap);// Sripathi, don't need this anymore becuase of Steelbrick
                OpportunityUtils.updateSpProduct(Trigger.newMap);
                if (!OpportunityUtils.validateOppEditabilityRunOnce){
                    OpportunityUtils.validateOpptyEditability(Trigger.new, Trigger.OldMap);
                }
                OpportunityUtils.triggerFinanceApprovalBefore(Trigger.newMap, Trigger.oldMap);                        
                
                //code unit for OpportunityAll
                try
                {
                    OpportunityUtils.updateOpportunityContactRole(Trigger.newMap); 
                }
                catch(Exception e)
                {
                    system.debug('Exception occured:'+ e.getMessage());    
                }
                
                OpportunityUtils.updateOpptAmountMc(Trigger.new);
                try{
                    OpportunityUtils.checkForPrimaryContactRolesIfStageNegotiateLost(Trigger.new, false);
                 // OpportunityUtils.assignGeoRegionAndOpptCountryIfNeeded(Trigger.new);
                }
                catch(Exception e){
                    EmailClassRoadnet.SendErrorEmail('checkForPrimaryContactRolesIfStageNegotiateLost failed due to: ' + e.getMessage(), null);
                }
            //  OpportunityUtils.assignSalesTeamManagerAndDarManager(Trigger.new);
                OpportunityUtils.setDepositePending(Trigger.new, Trigger.oldMap); 
                OpportunityUtils.updatePriceBookForSBQuote(Trigger.new, Trigger.oldMap);
            }    
        }
        
        //if(Trigger.isDelete)
        //{
            //OpportunityUtils.DeleteOpportunityQuotes(Trigger.oldMap.keySet()); // SaiKrishna: VCG quotes are not used because of StealBrick
        //}
    }
    
    if(Trigger.isAfter) 
    {
        if(Trigger.isInsert || Trigger.isUpdate)
        {
            if(Trigger.isInsert)
            {
                //Following code is to stop multiple execution of trigger
                //if(!checkRecursive.runOnce()) return;
                if(Test.isrunningTest() || OpportunityUtils.afterInsertExecuted <= checkVal)
                {
                    OpportunityUtils.afterInsertExecuted ++;
                
                    try
                    {
                        OpportunityUtils.createPrimaryContactRole(Trigger.new);
                        OpportunityUtils.updateCampaignTvwoField(trigger.old, trigger.new, false);
                    }
                    catch(Exception e)
                    {
                        system.debug('Exception occured:'+ e.getMessage());    
                    }
                    
                    OpportunityUtils.createTIS(Trigger.new);
                }
            }
            
            if(Trigger.isUpdate)
            {
                OpportunityQuoteTriggerHandler.updateQuoteStartDate(Trigger.newMap, Trigger.oldMap);
                //Following code is to stop multiple execution of trigger
                //if(!checkRecursiveAfter.runOnce()) return;
                
                if(Test.isrunningTest() || OpportunityUtils.afterUpdateExecuted <= checkVal)
                {
                    
                    OpportunityUtils.afterUpdateExecuted ++;
               
                    try
                    { 
                    
                        OpportunityUtils.createPrimaryContactRole(Trigger.new);
                        OpportunityUtils.checkForLostStageAndUpdateOpptContacts(Trigger.Old, Trigger.new); 
                        OpportunityUtils.UpdateOppProduct(Trigger.new);    
                        OpportunityUtils.handleOpportunityClosure(Trigger.new,Trigger.old); 
                        OpportunityUtils.updateCampaignTvwoField(trigger.old, trigger.new, false);
                        OpportunityUtils.updateOLI(Trigger.newMap, trigger.new);

                        
                    }
                    catch(Exception e)
                    {
                        system.debug('Exception occured:'+ e.getMessage());    
                    }
                    
                    OpportunityUtils.triggerFinanceApprovalAfter(Trigger.newMap, Trigger.oldMap);
                    //OpportunityUtils.createUpdateAssets(Trigger.newMap, Trigger.oldMap);  // Sripathi, don't need this anymore because of Steelbrick
                    
                    OpportunityUtils.UpdateTIS(Trigger.new, Trigger.oldMap);
                    
                    // NetSuite callout for Omni-Mex - Approved Quotes
                    if(Trigger.size == 1 && !NetsuiteSyncOpportunityHelper.hasRun)
                    {
                        OpportunityUtils.opportunityNetsuitesync(Trigger.new, Trigger.oldMap);  
                    }
                }
                
                //Method to create contract record when stage is Negotiate and Primary Quote Approval status is Approved
                /*if (!QuoteContract.contractCreateRunOnce){// Sripathi, don't need this anymore becuase of Steelbrick
                    QuoteContract.createContract(Trigger.New,Trigger.oldMap);   
                }*/
                
                if (!OpportunityUtils2.updateForecastDatesRunOnce){
                    OpportunityUtils2.updateForecastDates(Trigger.newMap, Trigger.oldMap);
                }
                
                if (!OpportunityUtils2.checkDirectSalesOnboardingCall){
                    OpportunityUtils2.callUnityDirectSalesOnboardService(Trigger.new, Trigger.oldMap);
                }
                //OpportunityUtils.oppEndDateUpdate(Trigger.new, Trigger.oldMap);               
                
                /*********************
                 Roesler 6/3/2017
                 if we update an opportunity, we need to update the service plan quantity rollup quantities on any parent Opps
                ***********************/
                OpportunityUtils.rollupDecommissionFinancials(trigger.new);
            }
        }
        
        if(Trigger.isDelete)
        {
            //code for OpportunityAll. 
            try
            {
                OpportunityUtils.updateCampaignTvwoField(trigger.old, trigger.new, true); 
            }
            catch(Exception e)
            {
                system.debug('Exception occured:'+ e.getMessage());    
            }
            
            /*********************
             Roesler 6/3/2017
             if we delete an opportunity, we need to update the service plan quantity rollup quantities on any parent Opps
            ***********************/
            OpportunityUtils.rollupDecommissionFinancials(trigger.old);
        }
    }
    
}