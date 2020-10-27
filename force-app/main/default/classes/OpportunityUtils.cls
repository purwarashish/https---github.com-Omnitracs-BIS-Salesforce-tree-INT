/*********************************************************************
Name    : OpportunityUtils
Author  : Shruti Karn
Date    : 19 July 2011

Usage   : This class is used by the 'AllOpporutnityTrigger' to:
1. Update all the associated Opportunity products.

Modified Date: 30/4/2015
Modified By: Rittu Roy
Reason: Added method revertStageReversal. Used to revert opportunity stage to previous value 
if Stage reversal is rejected. 

Modified Date: 11/12/2015
Modified By  : Rittu Roy
Reason       : Case# 01962968 - Added code to unlock opportunity on approval submission, so that legal 
               can update opportunity while it is in finance review  

Modified Date: 01/09/2016
Modified By  : Rittu Roy
Reason       : Case #02149361 - 1. Modified triggerFinanceApprovalBefore method. Added logic to unlock opportunities when
               they go from first to subsequent approval steps, specifically, for Sylectus opportunities.
               2. Changed the condition that triggers Finance status update to 'Needs Review'.
               
Modified Date: 03/28/2016
Modified By  : Ram Majji
Reason       : Case # 02246752 - 1. Change the time when contracted assets are created/updated to: Opportunity Stage = Sales Complete 
                and Opportunity Legal Review = Contract Data Entry Process and Finance Review = Approved. 
                In addition, there is a field called Asset (lookup to the Contracted Asset) on the Opportunity Product that is not being populated currently. 
                They would like this to be populated so that there is a link between the Opportunity Product and the Contracted Asset.
                2. When the opportunity goes to Closed Won, if the Opportunity Product’s Line Type = New, update the set fields 
                from the Opportunity Product to Contracted Asset.
*********************************************************************/

public without sharing class OpportunityUtils
{    
    public static integer beforeInsertExecuted = 0;
    public static integer afterInsertExecuted = 0;
    public static integer beforeUpdateExecuted = 0;
    public static integer afterUpdateExecuted = 0;
    private static List<OpportunityStage> allOpptStages;
    static Map<Id,Asset__c> cachedAssets = new Map<Id,Asset__c>();
    public static Set<Id> setClosedOppty = new Set<Id>();
    public static List<Id> lstOpptyToUnlock = new List<Id>();
    public static boolean validateOppEditabilityRunOnce = false;//To prevent recursive run of method validateOpptyEditability
    // ARMAN: public static boolean hasApprovalProcessRun = false;
    private static List<Country_And_Country_Code__c> countryRecords;

    public static Boolean isOpportunityTriggerRunning
    {
        get
        {
            if (isOpportunityTriggerRunning == null)
                isOpportunityTriggerRunning = false;
            
            return isOpportunityTriggerRunning;
        }
        
        set;
    }
    
    //Opportunity stage Objective action [i.e., Task w.r.t that opportunity] should be completed to change that stage to higher stage where the probablity increases.
    public static void SPValidation(Map<Id,Opportunity> mapTriggerNew, Map<Id,Opportunity> mapTriggerOld, Integer triggerSize){
        System.debug('This validation has been taken care in SalesPlanValidation Class from VVS package.');
    }
    
    
    /*
    *  @author:        Mark De Chavez
    *  @description:   checks the VCG_CPQ_Quote_Product__c if there are missing shipment schedules and prevent it from updating if there is any
    *  @parameters:    newOppList - trigger.new
    *                  oldOppMap  - trigger.oldMap
    */
    /* ARMAN & SAI(Commented out in AllOpportunityTrigger ): 
        public static void oppStageOnChange(List<Opportunity> newOppList, Map<Id, Opportunity> oldOppMap){
        map<Id, boolean> OppsWithApprovedQuote = new map<Id, boolean>();
        map<Id, list<VCG_CPQ_Quote_Product__c>> SalesCompleteOpps = new map<Id, list<VCG_CPQ_Quote_Product__c>>();
        
        for (Opportunity newOpp : newOppList) 
        {
            Opportunity oldOpp = oldOppMap.get(newOpp.Id);           
            if (oldOpp.StageName != newOpp.StageName && newOpp.StageName == 'Sales Complete') 
            {
                SalesCompleteOpps.put(newOpp.Id, new list<VCG_CPQ_Quote_Product__c>());
                OppsWithApprovedQuote.put(newOpp.Id, false);
            }
        }
        
        for (VCG_CPQ_Quote_Product__c p : [SELECT Id, Quote__r.Opportunity__c
                                          FROM VCG_CPQ_Quote_Product__c 
                                          WHERE Product__r.Shipment_Schedule_Required__c = TRUE 
                                          AND Quote__r.Is_Primary__c = TRUE 
                                          AND Number_of_Shipment_Forecasts__c = 0 
                                          AND Quote__r.Opportunity__c in : SalesCompleteOpps.keySet()
                                          AND Line_Type__c != 'Decommission'
                                          AND License_Metric_Quantity__c != null
                                          AND License_Metric_Quantity__c > 0])
        {
            list<VCG_CPQ_Quote_Product__c> l = SalesCompleteOpps.get(p.Quote__r.Opportunity__c);
            l.add(p);            
        }
        
        //look across all other Quotes
        for (VCG_CPQ_Quote__c q : [Select Id, Is_Primary__c, Opportunity__c 
                                  FROM VCG_CPQ_Quote__c 
                                  WHERE Opportunity__c in :SalesCompleteOpps.keySet()
                                  AND Is_Primary__c = true])
        {
            OppsWithApprovedQuote.put(q.Opportunity__c, q.Is_Primary__c);
        }
        
        for (Opportunity newOpp : newOppList)
        {
            if (SalesCompleteOpps.containsKey(newOpp.Id))
            {
                if (SalesCompleteOpps.get(newOpp.Id).size() > 0)
                {
                    newOpp.addError('Cannot change Opportunity Stage. There are missing Shipment Schedules for Products that require them.');
                }
                if (OppsWithApprovedQuote.get(newOpp.Id) == false && !(newOpp.Order_Sub_Type__c == 'Annual Increase'))
                {
                    newOpp.addError('An Opportunity must have at least one primary Quote before setting the stage to "Sales Complete"');
                }
            }
        }                
    } */
    
    /*
    *  @author:        Mark De Chavez
    *  @description:   assigns value to sp_products__c whenever a product is added to an opportunity
    *  @parameters:    newOppList - trigger.new
    *  @Modified by:   Arindam Laik
    *  @purpose:       consolidate the triggers and Clean-up the code
    */
    public static void updateSpProduct(Map<id,Opportunity> newOppMap){
        
        Map<Id, Set<String>> oppSPMap = new Map<Id, Set<String>>();
        
        for (OpportunityLineItem oppLineItm : [SELECT pricebookentry.Product2.ProductCode, opportunityId FROM OpportunityLineItem WHERE OpportunityId =: newOppMap.keyset()])
        {
            if (newOppMap.containsKey(OppLineItm.OpportunityId))
            {
                if (oppSPMap.containsKey(OppLineItm.OpportunityId))
                {                     
                    oppSPMap.get(OppLineItm.OpportunityId).add(oppLineItm.pricebookentry.Product2.ProductCode); 
                                  
                }
                else 
                {                     
                    oppSPMap.put(OppLineItm.OpportunityId, new Set<String>{oppLineItm.pricebookentry.Product2.ProductCode});
                }
            }
        }
        
        for (Id oppId : newOppMap.keySet())
        {
            String spProd = '';
            if (oppSPMap.containskey(oppId))
            {
                for (String prodCode : oppSPMap.get(oppId))
                {   
                    spProd = spProd + ';' + prodCode ;
                }
                if (spProd.length() > 0)
                {
                    spProd = spProd.subString(1, spProd.length());
                }
            }
         /*  if (spProd != '' || newOppMap.get(oppId).SP_Products__c != null)
                newOppMap.get(oppId).SP_Products__c = spProd;   */          
        }       
    }
    
    /*Prevents sales users from editing closed opportunities*/
    public static void validateOpptyEditability(List<Opportunity> lstOpps, Map<Id,Opportunity> oldMap)
    {
        Set<String> setAllowedFields = new Set<String>();
        Set<String> setOpptyFields = new Set<String>();
        validateOppEditabilityRunOnce = true;
        //Gets list of fields that can be edited, from custom settings.
        if (Global_Variable__c.getInstance('OpptyLock_AllowedFields') != null && String.isNotBlank(Global_Variable__c.getInstance('OpptyLock_AllowedFields').value__c)){
            setAllowedFields.addAll(Global_Variable__c.getInstance('OpptyLock_AllowedFields').value__c.split(',',0));
        }
        
        //Get list of fields on Opportunity from object schema
        Map<String, Schema.SObjectField> mapOpptyFields = Schema.SObjectType.Opportunity.fields.getMap();
        for (String strField : mapOpptyFields.keyset()){
            setOpptyFields.add(String.valueOf(mapOpptyFields.get(strField)));
        }
        
        if (ApexUserInfo.validateUserForOpptyLock(userInfo.getUserId(),UserInfo.getProfileId())){
            for (Opportunity oppty : lstOpps){
                if (oldMap.get(oppty.Id).StageName == 'Closed Won' || oldMap.get(oppty.Id).StageName == 'Closed Lost'){
                    for (String field : setOpptyFields){
                        if (!setAllowedFields.contains(field) && oppty.get(field) != oldMap.get(oppty.id).get(field)){
                            if (EditShipmentScheduleExt.verifyShipmentEdit != true)// Edited only by Shipped Checkbox in Shipment Forecast Object..
                            {
                                oppty.AddError('Closed Opportunity cannot be edited');
                            }
                        }
                        
                    }
                }
                
                //Case #02133107 - To allow opportunity product edit when opportunity is closed within same context 
                if (oppty.isClosed && oldMap.get(oppty.Id).isClosed != true){
                    setClosedOppty.add(oppty.Id);
                }
            }
        }
    }
    
    /*
    *  @author:        Mark Malanowski
    *  @description:   Sets Finance Status to Needs Review
    *  @parameters:    newMap - trigger.newmap, oldMap - trigger.oldmap
    *  @Modified by:   Arindam Laik
    *  @purpose:       consolidate the triggers and Clean-up the code
    */
    public static void triggerFinanceApprovalBefore(Map<Id, Opportunity> newMap, Map<Id, Opportunity> oldMap) 
    {
        for (Opportunity o : newMap.values()) 
        {
            if ((o.Legal_Review__c ==  OpportunityLegalReviewStatus__c.getInstance('ContractDataEntryProcess').value__c && (oldMap.get(o.Id).Legal_Review__c ==  OpportunityLegalReviewStatus__c.getInstance('Waiting for Counter-Signature').value__c || oldMap.get(o.Id).Legal_Review__c ==  OpportunityLegalReviewStatus__c.getInstance('InitialReview').value__c)) 
            || o.Legal_Review__c == OpportunityLegalReviewStatus__c.getInstance('Approved').value__c && oldMap.get(o.Id).Legal_Review__c == OpportunityLegalReviewStatus__c.getInstance('InitialReview').value__c) 
            {
                o.Finance_Status__c = OpportunityFinanceStatus__c.getInstance('NeedsReview').value__c;
            }
            
            //Case #02149361 - Unlock any opportunities in approval process. Specifically for Sylectus opportunities, which get locked when 
            //record goes to second level approver
            if (o.Unlock_Opportunity__c == true && oldMap.get(o.Id).Unlock_Opportunity__c == false){
                o.Unlock_Opportunity__c = false;
                lstOpptyToUnlock.add(o.Id);
            }
        }
        
        if (!lstOpptyToUnlock.isEmpty()){
            UnlockOpportunities(lstOpptyToUnlock);
        }
    }
    
    //Case #02149361 - Unlock any opportunities in approval process. Specifically for Sylectus opportunities, which get locked when 
    //record goes to second level approver
    @future
    public static void UnlockOpportunities(List<Id> lstOpptyIds){
        Approval.UnlockResult[] unlockRecs = Approval.unlock(lstOpptyIds,false);
    }
    
    /*
    *  @author:        Mark Malanowski
    *  @description:   triggers approval process
    *  @parameters:    newMap - trigger.newmap, oldMap - trigger.oldmap
    *  @Modified by:   Arindam Laik
    *  @purpose:       consolidate the triggers and Clean-up the code
    */
    public static void triggerFinanceApprovalAfter(Map<Id, Opportunity> newMap, Map<Id, Opportunity> oldMap) 
    {
        for (Opportunity o : newMap.values()) 
        {
            //if ((o.Legal_Review__c ==  OpportunityLegalReviewStatus__c.getInstance('ContractDataEntryProcess').value__c && (oldMap.get(o.Id).Legal_Review__c ==  OpportunityLegalReviewStatus__c.getInstance('Waiting for Counter-Signature').value__c || oldMap.get(o.Id).Legal_Review__c ==  OpportunityLegalReviewStatus__c.getInstance('InitialReview').value__c)) 
            //|| o.Legal_Review__c == OpportunityLegalReviewStatus__c.getInstance('Approved').value__c && oldMap.get(o.Id).Legal_Review__c == OpportunityLegalReviewStatus__c.getInstance('InitialReview').value__c) 
            //System.debug('**************triggerFinanceApprovalAfter Legal review-- '+o.Legal_Review__c+' -- '+oldMap.get(o.Id).Legal_Review__c+' -- Finance Status '+o.Finance_Status__c+ ' - '+oldMap.get(o.Id).Finance_Status__c+' -- StageName '+o.StageName+ ' - '+oldMap.get(o.Id).StageName);
                
            if (o.Finance_Status__c ==  'Needs Review' && o.Finance_Status__c != oldMap.get(o.Id).Finance_Status__c)
            {
                //System.debug('**************triggerFinanceApprovalAfter Legal review-- '+o.Legal_Review__c+' -- '+oldMap.get(o.Id).Legal_Review__c+' -- Finance Status '+o.Finance_Status__c+ ' - '+oldMap.get(o.Id).Finance_Status__c+' -- StageName '+o.StageName+ ' - '+oldMap.get(o.Id).StageName);
                System.debug('**************triggerFinanceApprovalAfter Legal review-- '+o.Legal_Review__c+' -- '+oldMap.get(o.Id).Legal_Review__c+' -- Finance Status '+o.Finance_Status__c+ ' - '+oldMap.get(o.Id).Finance_Status__c+' -- StageName '+o.StageName+ ' - '+oldMap.get(o.Id).StageName);
                
                Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
                req.setComments('Automatically submitted for Finance Approval by Legal.');
                req.setObjectId(o.Id);
                try {
                    Approval.process(req);
                    
                    //Added as part of Case# 01962968, so that legal can update oppty while it is in finance review
                    Approval.UnlockResult unlockRec = Approval.unlock(o.Id,false);
                    //hasApprovalProcessRun = true;
                }
                catch (Exception e) {
                    System.debug('No applicable approval process found. Error: ' + e.getMessage());
                }
            }
        }
    }

    /*
    *  @description:   Send data to Netsuite system
    *  @parameters:    newMap - trigger.newList, oldMap - trigger.oldmap
    *  @Modified by:   Arindam Laik
    *  @purpose:       consolidate the triggers and Clean-up the code
    */
    public static void opportunityNetsuitesync(List<Opportunity> lstNewOpp, Map<id, Opportunity> mapoldOpp)
    {               
        Set<Id> oppIdList = new Set<Id>();
        Set<Id> accountIdSet = new Set<Id>();
        Map<Id,Id> oppAccountIdMap = new Map<Id,Id>();
        boolean isSendToNetsuite = false;
        
        for (Opportunity o : lstNewOpp)
        {           
            if ((o.Primary_Quote_Approval_Status__c == 'Approved' && mapoldOpp.get(o.Id).Primary_Quote_Approval_Status__c != 'Approved')
               || (o.Primary_Quote_Approval_Status__c == 'Recalled' && mapoldOpp.get(o.Id).Primary_Quote_Approval_Status__c == 'Approved'))
            {
                isSendToNetsuite = true;
                accountIdSet.add(o.AccountId);
            } 
        }
        //proceed only if Primary_Quote_Approval_Status__c is getting changed to 'Approved' or 'Recalled' 
        if (isSendToNetsuite)
        {        
            for (Account a:[SELECT Id, Send_to_NetSuite__c FROM Account WHERE Id IN: accountIdSet])
            {
                if (a.Send_to_NetSuite__c == true)
                {
                    oppAccountIdMap.put(a.Id,a.Id);
                }
            }
            
            for (Opportunity o : lstNewOpp)
            {
                // We send newly approved Quotes and previously approved recalled Quotes
                if (oppAccountIdMap.get(o.AccountId) != null)
                {
                    oppIdList.add(o.Id);
                }            
            }  
            
            if (oppIdList.size()>0)
            {
                NetsuiteSyncOpportunityHelper.postDataToNetsuite(oppIdList);        
            }
            
            //Set hasRun boolean to false to prevent recursion
            NetsuiteSyncOpportunityHelper.hasRun = true;
        }
    }      
    
    /*
    *  @description: Updates the Opporunity Amount (Mc) field
    *  @Modified by: Arindam Laik
    *  @purpose:     consolidate the triggers and Clean-up the code
    */
    public static void updateOpptAmountMc(List<Opportunity> oppts)
    {
        for (Opportunity o : oppts)
        {
            //  use janes field update definition
            if (o.recordtypeid == Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Partner Opportunity (Reseller)').getRecordTypeId())
            {
                o.Opportunity_Amount_MC__c = (nullToZero(o.Editable_Opportunity_Qty__c));     
              //o.Opportunity_Amount_MC__c = (nullToZero(o.Editable_Opportunity_Qty__c) *  ((nullToZero(o.Subscription_arpu__c) * 12) + nullToZero(o.Hardware_Unit_Price__c)));               
            }
            else
            {
                o.Opportunity_Amount_MC__c = nullToZero(o.tcv__c);
            }
        }
    }

    private static decimal nullToZero(decimal d)
    {
        return (d == null ? 0 : d);
    }
    
    /*
    this prevent an oppts stage name from boing to negoitate or a lost stage if a primary contact role is not assigned
    only oppts we need to display the error message for are
    1a - oppts that are upgrades   OR
    1b -domestic oppts AND; oppts whose business unit = roadnet  OR  is being inserted
    2 - have no priamry contact roles set for them
    3 - primary contact field and/or role field are not set
    */
    public static void checkForPrimaryContactRolesIfStageNegotiateLost(List<Opportunity> newOppts, boolean isTriggerInsert)
    {        
        //  this method is a redesign to how the original method worked, modifying this so that it only performs queries IFF the method needs queried recods
        //  first thing we need to check ist ot see if the primary contact/role are missing on in any of the oppts being passed in,
        //  if so, we know we are going to have add an error  the oppt so we need to query/check for other things
        List<Opportunity> opptsToDisplayErrorFor = new List<Opportunity>();
        Set<id> setofAccountId = new Set<id>();
        Set<id> setofCaseId = new Set<id>();
        Map<id, Account> mapofDomesticAccount;
        Map<id, Case> mapofUpgradeOppGenCase;
        List<OpportunityContactRole> opptPrimaryContactRoles;
        Schema.RecordTypeInfo renewRTName = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Renewal Only');
        Id renewRId = (renewRTName != null && String.isNotBlank(renewRTName.getRecordTypeId()))?renewRTName.getRecordTypeId():null;
        
        for (Opportunity singleOppt : newOppts)
        {
            if ( (singleOppt.Primary_Contact__c == null || singleOppt.Role__c == null) &&
                singleOppt.Owner_Business_Unit__c == 'Roadnet')
            {
                opptsToDisplayErrorFor.add(singleOppt);           
                if (singleOppt.AccountId != null)
                    setofAccountId.add(singleOppt.AccountId);
                if (singleOppt.Case__c != null)
                    setofCaseId.add(singleOppt.Case__c);
            }    
        }
        
        if (opptsToDisplayErrorFor != null && opptsToDisplayErrorFor.size() > 0)
        {
            //  now we need to query other records to determine if the error needs to be shown
            //  requery the oppts for account fields
            if (setofAccountId != null && setofAccountId.size()>0)
            {
                mapofDomesticAccount = new map<id, Account>([Select id, primary_business_unit__c, shippingCountry, billingCountry from Account 
                                                             where id in :setofAccountId]);
            }                            
            if (setofCaseId != null && setofCaseId.size()>0)
            {
                mapofUpgradeOppGenCase = new map<id, Case>([Select id, is_case_being_upgraded__c from Case where id in :setofCaseId]);
            }                   
            
            if (!isTriggerInsert)
            {
                opptPrimaryContactRoles = [Select o.Role, o.OpportunityId, o.IsPrimary, o.Id, o.CreatedDate, 
                                           o.CreatedById, o.ContactId From OpportunityContactRole o 
                                           where OpportunityId in: opptsToDisplayErrorFor  AND IsPrimary = true];
            }
            
            for (Opportunity singleOppt : opptsToDisplayErrorFor)
            {
                boolean isUpgradeOppt = false;
                boolean isOpptDomestic = false;
                boolean isOpptRoadnet = false;
                boolean isPrimaryContactRoleFound = true;
                
                if (singleOppt.Case__c != null && mapofUpgradeOppGenCase.containsKey(singleOppt.Case__c))
                    isUpgradeOppt = mapofUpgradeOppGenCase.get(singleOppt.Case__c).is_Case_Being_Upgraded__c;
                if (singleOppt.AccountId != null && mapofDomesticAccount.containsKey(singleOppt.AccountId))
                {
                    isOpptDomestic = isOpptDomestic(mapofDomesticAccount.get(singleOppt.AccountId).ShippingCountry, 
                                                    mapofDomesticAccount.get(singleOppt.AccountId).BillingCountry);                   
                    isOpptRoadnet = (mapofDomesticAccount.get(singleOppt.AccountId).Primary_Business_Unit__c == 'Roadnet');
                }
                if (!isTriggerInsert && opptPrimaryContactRoles != null && opptPrimaryContactRoles.size() >0)
                    isPrimaryContactRoleFound = !isAnyContactRolePrimary(singleOppt.id, opptPrimaryContactRoles);
              
                if (isPrimaryContactRoleFound && //  oppt has no primary contact roles set for it
                   (isUpgradeOppt || //  is an upgrade oppt OR
                    (isOpptDomestic && //  oppt is domestic 
                     IsTriggerInsert || isOpptRoadnet))//  oppt is being inserted for first time OR oppt belongs to Roadnet
                  )
                {
                    //  we have to place the error oon the trigger record itself, i was going to change this method so that
                    //  the trigger.newMap is passed in but i think this works but is less effcient
                    Opportunity triggerOppt = findTriggerRecord(singleOppt.id, newOppts);
                    
                    if ( triggerOppt.Primary_Contact__c == null)
                    {
                        //triggerOppt.Primary_Contact__c.AddError('You must specify a primary contact role for this opportunity.');
                    }
                    if (util.isBlank(triggerOppt.Role__c) && String.isNotBlank(renewRId) && singleOppt.RecordTypeId != renewRId)
                    {
                        //triggerOppt.Role__c.AddError('You must specify a role');
                    }
                }
            }
        }
    }

    @TestVisible
    private static boolean isOpptDomestic(String accountShippingCountry, String accountBillingCountry)
    {
        String countryNameLowerCase;
        if (accountShippingCountry != null)
        {
            countryNameLowerCase = accountShippingCountry.toLowerCase();
        }
        else if (accountBillingCountry != null)
        {
            countryNameLowerCase = accountBillingCountry.toLowerCase();
        }
        
        if (Util.isblank(countryNameLowerCase))
        {
            return false;
        }
        else
        {
            return countryNameLowerCase == 'united states'; //|| countryNameLowerCase == 'canada';// || countryNameLowerCase == 'mexico';
        }
    }

    @TestVisible
    private static boolean isAnyContactRolePrimary(Id opptId, List<OpportunityContactRole> contactRoles)
    {
        for (OpportunityContactRole cr : contactRoles)
        {
            if (cr.OpportunityId == opptId)
            {
                if (cr.isPrimary)
                {
                    return true;
                }
            }
        }
        return false;
    }

    @TestVisible
    private static Opportunity findTriggerRecord(Id opptId, List<Opportunity> triggerOppts)
    {
        for (Opportunity o : triggerOppts)
        {
            if (o.Id == opptId)
            {
                return o;
            }
        }
        return null;
    }
    
 /* public static void assignSalesTeamManagerAndDarManager(List<Opportunity> opptsToCheck)
    {       
        //  getting too many soql errors when quotes are saved so modding this so that it queries the user
        //  ids only if we actually need to modify the oppts sales team manager field
        //  this should only fire for roadnet oppts also
        List<Opportunity> roadnetOnlyOppts = new List<Opportunity>();
        for (Opportunity o : opptsToCheck)
        {
            if (o.Owner_Business_Unit__c == 'Roadnet')
            {
                roadnetOnlyOppts.add(o);
            }
        }
        
        if (roadnetOnlyOppts != null && roadnetOnlyOppts.size() > 0)
        {
            // ther is an issue with requreying the oppts, since this is in the before trigger, the ownerid (if the user is chaning the owner
            //  wil not have the updated owner so the users old onwer is being assigned as the manager
            //  so i have to back with querying the owners of the oppts without requerying the opportunities
            
            List<User> ownersOfOppts = retrieveOwnersOfOppts(roadnetOnlyOppts);
            
            for (Opportunity singleOppt : roadnetOnlyOppts)
            {
                //  need to make sure we get the trigger oppt record, as we are setting a field on there and setting it on a copy of the object is not going
                //  to ensure the field is updated by the before trigger
                User ownerOfOppt = findOwnerOfOppt(singleOppt.ownerId, ownersOfOppts);
                
                //check the owner profile
                if (ownerOfOppt != null && 
                    ownerOfOppt.Profile != null && 
                    ownerOfOppt.Profile.Name != null && 
                    (ownerOfOppt.Profile.Name.Contains('Sales') || ownerOfOppt.Profile.Name.Contains('Roadnet Partner')) ) //  is the owner of the oppt a Sales Rep or Var
                {
                    //  now we need to check if the new oppt owner is already a sales team manager
                    //  if the owner of the oppt is already  a sales team manager then use the owner's name
                    //  (this is to avoid having an oppt owned by Tim Keffer and having Michael Farleas be his sales team manager
                    if ( singleOppt.OwnerId == RoadnetSalesManager__c.getInstance('Brian Callahan').UserId__c || singleOppt.ownerId == RoadnetSalesManager__c.getInstance('Ken Krucenski').UserId__c)
                    {
                        singleOppt.Sales_Team_Manager__c = ownerOfOppt.name;
                        //  per email from jane dated 3/0/2014, the dar manager needs to be the sales team manager's id
                        //newOppt.Dar_Manager__c = ownerOfOppt.Id;
                    }
                    else
                    {
                        if (ownerOfOppt.Manager != null)
                            singleOppt.Sales_Team_Manager__c = ownerOfOppt.Manager.Name;
                        //  per email from jane dated 3/0/2014, the dar manager needs to be the sales team manager's id
                        //newOppt.Dar_manager__c = ownerOfOppt.managerid;                        
                    }
                }
            }
        }
    }*/

    private static User findOwnerOfOppt(id ownerid, List<user> users)
    {
        for (User u : users)
        {
            if (u.id == ownerId)
            {
                return u;
            }
        }
        return null;
    }

    private static List<user> retrieveOwnersOfOppts(List<Opportunity> oppts)
    {
        Set<Id> ownerIds = new Set<Id>();
        for (opportunity o : oppts)
        {
            if (!ownerIds.contains(o.ownerId))
            {
                ownerIds.add(o.ownerId);
            }    
        }
        
        if (ownerIds.size() > 0)
        {
            return [select id, name, isactive, profileid, profile.name, managerid, 
                    manager.profile.name, manager.name from User where id in: ownerIds and isactive = true];
        }   
        return null;    
    }
    
    public static void CloningValidation(List<Opportunity> lstNewOpportunity)
    {
        for (Opportunity objOpportunity : lstNewOpportunity)
        {
            //  check that if the user is cloning an oppt, the Terms_Requested_Status__c field is blank, we don't want it to clone over
         /* if (objOpportunity.Terms_Requested_Status__c != null)
            {
                objOpportunity.Terms_Requested_Status__c.addError('This field needs to be blank if cloning an opportunity');
            } /*
         /* if (objOpportunity.Terms_Requested__c)
            {
                objOpportunity.Terms_Requested__c.addError('This field needs to be blank if cloning an opportunity');
            }*/
            //  jane has asked on 3/6/2014 in regards to sf issue: https://na1.salesforce.com/a0W3000001H34kX 
            //  could be cleared out for new/cloned opts
         /* if (objOpportunity.Se_Approval__c == true)// checkbox field so it should false if cloning
            {
                objOpportunity.Se_Approval__c = false;    
            }*/
            if (objOpportunity.current_se__c != null)
            {
                objOpportunity.current_se__c = null;
            }
        }
    }
    
    public static void setDepositePending(List<Opportunity> lstNewOpportunity, Map<id,opportunity> mapOldOpportunity)
    {
        // here we can check if the stage name has changed and if so, ding the user that they cant change it
        for (Opportunity objOpportunity : lstNewOpportunity)
        {
            if (objOpportunity.stagename != null && mapOldOpportunity.get(objOpportunity.Id).StageName != objOpportunity.StageName 
               && objOpportunity.Stagename == 'Closed - Won')
            {
                //  check if the user is allowed to set the field           
                //  if the oppt contains Project Change in its title, its a Project Change oppt and we want to set the dp to p date 
                //  sf issue for info located here https://na1.salesforce.com/a0W3000000DtWAk
              /*if (objOpportunity.Name != null && objOpportunity.Name.contains('Project Change') && objOpportunity.deposit_pending_to_pending_date__c == null)
                {
                    objOpportunity.Deposit_Pending_To_Pending_Date__c = date.today();
                }*/
            }
        }
    }

   /* public static void assignGeoRegionAndOpptCountryIfNeeded(List<Opportunity> lstNewOpportunity)
    {
        //  moved the country and country code query to the findCountryCodeUsingCountryName method        
        //  alright here is my hesitation with using this, the oppt does have a country field but when i check all of the oppts
        //  the country is not set on 2000+, so i'm wondering if i could use the oppt country field first
        //   and if it is blank, lookup the account and get the shipping country from there
        for (Opportunity objOportunity :lstNewOpportunity)
        {
            if (objOportunity.Opporunity_Country__c != null)
            {
                // be advised that the country picklist is MULTI-SELECT, meaning it can have many countries selected
                // because of this, the findCountryCodeUsingCountryName will do a contains so that it matches on the first country
                // it can find
                Country_And_Country_Code__c tempCCC = findCountryCodeUsingCountryName(objOportunity.Opporunity_Country__c);
              if (tempCCC != null)
                {
                    objOportunity.Hidden_Opportunity_Region__c = tempCCC.Region__c;
                }
            }
          else
            {
                //  so if the oppt country was blank, we'll blank out the region also
                {
                    objOportunity.Hidden_Opportunity_Region__c = null;
                }
            }
        }
    } 
 */
    @TestVisible
    private static Country_And_Country_Code__c findCountryCodeUsingCountryName(String countryName)
    {
        if (countryRecords == null)
        {
            countryRecords = [select name, ISO_Code_2__c, Region__c from Country_And_Country_Code__c Limit 50000];
        }
        for (Country_And_Country_Code__c ccc : countryRecords)
        {
            if (countryName != null)//  check because we going to do a contains
            {
                //  country picklist for ooppts can be multi select, so we might see someting like:
                //  Columbia; Mexico, so what this will do is once it finds one of the countries it will return that as the country code
                if (countryName.contains(ccc.Name))
                {
                    return ccc;
                }
            }
        }
        return null;
    }



    /* Does a 'cascade delete' of all quotes related to an opp when the opp is deleted 
    SAI KRISHNA :Commented out in All Opportunity Trigger also as Organization no longer ises VCG Quotes
    public Static void DeleteOpportunityQuotes(Set<id> setOpportunityIds)
    {    
        // Since we are using a Lookup relationship from Quote to Opp (for specific reasons), we don't get
        // the standard Master-Detail functionality of cascade deletes. And while we could utilize the
        // Salesforce functionality to do cascade deletes for Lookup fields in the field config, this is
        // a feature that must be explicitly turned on for an org and would make that feature available
        // for the entire org. Since we can't be sure this is something that can/will be done for every
        // org that installs CPQ, we handle this functionality in a trigger - which can be ported to
        // any Salesforce org. 
        
        // Note, we do this *before* delete because *after* delete the Opp__c field has already been cleared
        // so no child quotes will be found.
        if (!setOpportunityIds.isEmpty())
        {
            for (List<VCG_CPQ_Quote__c> quotes :[SELECT Id FROM VCG_CPQ_Quote__c WHERE Opportunity__c = :setOpportunityIds])
            {
                delete quotes;
            }
        }
    }*/
   


    
    /** This method updates the count of OpportunityContactRole records as well as IsPrimary information in to the 
        Opportunity Number_of_Contacts_Roles_Assigned__c ,Primary_Contact_Assigned__c field
    **/
    public static void updateOpportunityContactRole(Map<id,Opportunity> mapnewOpportunity)
    {
        Integer numberOfContacts = 0 ;                     
        Map<Id, Integer> opportunityContactRoleTotalCountMap = new Map<Id, Integer>();            
        Map<Id, Boolean> opportunityContactRoleisPrimaryMap = new Map<Id, Boolean>();
        
        List<OpportunityContactRole> opportunitycontactRolelist =  [select OpportunityId,Opportunity.Primary_Contact_Assigned__c,IsPrimary
            from OpportunityContactRole where  OpportunityId in :mapnewOpportunity.keySet()];
        
        for (OpportunityContactRole opportunityContactRole: opportunitycontactRolelist) 
        {
            if (opportunityContactRoleTotalCountMap.containsKey(opportunityContactRole.OpportunityId) &&
               opportunityContactRoleisPrimaryMap.containsKey(opportunityContactRole.OpportunityId))
            {                                
                numberOfContacts = opportunityContactRoleTotalCountMap.get(opportunityContactRole.OpportunityId) + 1;
                opportunityContactRoleTotalCountMap.put(opportunityContactRole.OpportunityId, numberOfContacts);
                
                if (opportunityContactRoleisPrimaryMap.get(opportunityContactRole.OpportunityId) == false)
                    opportunityContactRoleisPrimaryMap.put(opportunityContactRole.OpportunityId,opportunityContactRole.IsPrimary);
            }
            else
            {     
                opportunityContactRoleTotalCountMap.put(opportunityContactRole.OpportunityId, 1);
                opportunityContactRoleisPrimaryMap.put(opportunityContactRole.OpportunityId,opportunityContactRole.IsPrimary);
            }                                           
        }
        
        for (Opportunity objOpportunity :mapnewOpportunity.values())
        {
            if (opportunityContactRoleisPrimaryMap.containsKey(objOpportunity.Id))
                objOpportunity.Primary_Contact_Assigned__c = opportunityContactRoleisPrimaryMap.get(objOpportunity.Id);
            else    
            {    
                objOpportunity.Primary_Contact_Assigned__c = false;
            }     
         /* if (opportunityContactRoleTotalCountMap.containsKey(objOpportunity.Id))
                objOpportunity.Number_of_Contacts_Roles_Assigned__c = opportunityContactRoleTotalCountMap.get(objOpportunity.Id);
            else
            {
                objOpportunity.Number_of_Contacts_Roles_Assigned__c = null;
            }   */     
        }                                             
    }
    
    /** 
    When ever we are updating Opportunity it can fetch Software % to Omni field value of associated OpportunityLineItems
    and update it by taking Opportunity Software % to Omni field value.
    **/
    public static void updateOLI(Map<Id, Opportunity> oppMap, List<Opportunity> oppList)
    {        
        Map<String, OpportunityLineItem> oliMap = new Map<String, OpportunityLineItem>();
        for (OpportunityLineItem oli : [SELECT Id, OpportunityId from OpportunityLineItem WHERE OpportunityId IN : oppMap.keySet()]) 
        {
            oliMap.put(oli.OpportunityId + '|' + oli.Id, oli);
        }
        
        for (String oliMapId : oliMap.keySet())
        {
            String[] splitOliMapId = oliMapId.split('\\|');
            if (oppMap.containsKey(splitOliMapId[0]))
            {
                oliMap.get(oliMapId).Software_to_Omni__c = oppMap.get(splitOliMapId[0]).ups_of_total_sw__c;
            } 
        }
        
        try
        {
            update oliMap.values();
        }
        catch(Exception ex)
        {
            if (oppList.size() > 0)
            {
                oppList[0].ups_of_total_sw__c.addError('An error occured after updating Software % to OMNI field. Please contact your System Administrator. Error: ' + ex.getMessage());
            }
        }
        
    }

    /** 
    When ever we are updating Opportunity If Primary Contact and Role fields  value are not null then we have to fetch
    associated opportunity Contact Roles and check Is Primary filed value is TRUE or FALSE.
    1. If not TRUE then create Opportunity Contact Role record and make it that filed is TRUE for that inserted record
    2. If TRUE nothing to do.
    **/
    public static void createPrimaryContactRole(List<Opportunity> newOpportunityList)
    {       
        util.debug('createPrimaryContactRole has been called');
        List<Opportunity> opptsToCreatePrimaryContactRoles = new List<Opportunity>();        
        for (integer i = 0; i < newOpportunityList.size(); i++)
        {
            //Checking here whether Primary_Contact__c and Role__c is NULL or not then if not null then can add it in to list.
            if (!Util.isBlank(newOpportunityList[i].Primary_Contact__c) && !Util.isBlank(newOpportunityList[i].Role__c))
            {
                opptsToCreatePrimaryContactRoles.add(newOpportunityList[i]);
            }
        }
        
        List<OpportunityContactRole> contactRolesToCreate = new List<OpportunityContactRole>();        
        if (opptsToCreatePrimaryContactRoles.size() > 0)
        {            
            OpportunityContactRole[] currentContactRolesOfOppts = 
                [select id, OpportunityId, ContactId, Role, isPrimary from OpportunityContactRole where OpportunityId in: opptsToCreatePrimaryContactRoles];
            
            for (Opportunity singleOppt : opptsToCreatePrimaryContactRoles)
            {               
                //checking whether OpportunityContactRole Is Primary field value is TRUE or FALSE.
                if (doesPrimaryContactRoleExistAlready(singleOppt.id, currentContactRolesOfOppts))
                {
                    // if Is Primary field value is TRUE nothing to do
                }
                else
                {
                    //If false create one OpportunityContactRole record and make it Is Primary TRUE.
                    OpportunityContactRole ocr = new OpportunityContactRole();
                    ocr.OpportunityId = singleOppt.id;
                    ocr.ContactId = singleOppt.Primary_Contact__c;                  
                    ocr.Role = singleOppt.Role__c;
                    ocr.isPrimary = true;
                    contactRolesToCreate.add(ocr);
                }
            }            
            if (contactRolesToCreate.size() > 0)
            {
                insert contactRolesToCreate;
            }
        }
    }
    
    public static boolean doesPrimaryContactRoleExistAlready(Id opptId, List<OpportunityContactRole> primaryContactRoles)
    {       
        for (OpportunityContactRole singleContactRole : primaryContactRoles)
        {
            if (singleContactRole.OpportunityId == opptId && singleContactRole.IsPrimary)
            {
                return true;
            }
        }
        return false;
    }
    
    
    /**
    Updates the Opportunity.Campaign.Total_Value_Won_Opportunities_MC__c and Opportunity.Campaign.Total_Value_Opportunities_MC__c
    field with summation of the campaign's closed won oppts
    **/
    public static void updateCampaignTvwoField(List<Opportunity> oldTriggerRecords, List<Opportunity> newTriggerRecords, boolean isDelete)
    {        
        Set<Id> campaignIds;        
        if (isDelete)
        {
            campaignIds = retrieveCampaignIds(oldTriggerRecords);
            util.debug('size of campaign ids in isDelete if clause: ' + campaignIds);
            if (campaignIds != null && campaignIds.size() > 0)
            {
                updateCampaigns(campaignIds);
            }
        }
        else if (oldTriggerRecords == null)//  isInsert
        {
            campaignIds = retrieveCampaignIds(newTriggerRecords);
            util.debug('size of campaign ids in isInsert if clause: ' + campaignIds);
            if (campaignIds != null && campaignIds.size() > 0)
            {
                updateCampaigns(campaignIds);
            }
        }
        else if (oldTriggerRecords != null)
        {           
            List<Opportunity> opptsNoCampaign = new List<Opportunity>();
            for (integer i = 0; i < newTriggerRecords.size(); i++)
            {
                //  oppts campaign being removed
                if (oldTriggerRecords[i].campaignId != newTriggerRecords[i].campaignId &&
                    newTriggerRecords[i].CampaignId == null)
                {
                    opptsNoCampaign.add(oldTriggerRecords[i]);
                }
            }
            set<id> noLongerHasCampaignIdSet; 
            if (opptsNoCampaign != null && opptsNoCampaign.size() > 0)
            {
                noLongerHasCampaignIdSet = retrieveCampaignIds(opptsNoCampaign);
            }
            
            //  add the rest of the updated oppts, to the set
            campaignIds = retrieveCampaignIds(newTriggerRecords);            
            if (noLongerHasCampaignIdSet != null && noLongerHasCampaignIdSet.size() > 0)
            {
                //  then add the campaignids that were removed from oppts to the parent set
                for (id cid : noLongerHasCampaignIdSet)
                {
                    if (!campaignIds.Contains(cid))
                    {
                        campaignIds.add(cid);
                    }
                }
            }
            util.debug('size of campaign ids in isUpdate if clause: ' + campaignIds);            
            if (campaignIds != null && campaignIds.size() > 0)
            {
                updateCampaigns(campaignIds);
            }
        }        
    }

    private static set<Id> retrieveCampaignIds(List<Opportunity> oppts)
    {
        Set<Id> setToReturn = new Set<Id>();
        for (Opportunity o : oppts)
        {
            if (o.campaignId != null && !setToReturn.contains(o.campaignId))
            {
                setToREturn.add(o.CampaignId);
            }
        }
        return setToREturn;
    }

    private static void updateCampaigns(Set<Id> campaignids)
    {
        Campaign[] campaignsToUpdate = new List<Campaign>();
        for (id cid : campaignIds)
        {
            Campaign c = new Campaign();
            c.id = cid;
            campaignsToUpdate.add(c);
        }
        try
        {
            update campaignsToUpdate;//  this forces the before update campaign trigger to run to update the tcv fields
        }
        catch(Exception e)
        {
            util.debug('failed to update campaigns due to: ' + e.getMessage());
        }
    }    
    
    public static void UpdateOppProduct(List<Opportunity> opportunityList)
    {        
        Set<Id> OpportunityIdSet = new Set<Id>();
        for (Opportunity opportunity : opportunityList)
        {
            if (opportunity.IsClosed)
            {
                OpportunityIdSet.add(opportunity.Id);
            }
            
        }
        
        List<OpportunityLineItem> opportunityProductList = new List<OpportunityLineItem>();
        opportunityProductList = [SELECT Id from OpportunityLineItem WHERE 
                                  OpportunityId IN : OpportunityIdSet AND 
                                  Shipped__c = false LIMIT 10000];
        
        update opportunityProductList;              
    }
    
    
    /**
    At the time of updating opportunity we have to check whether  Owner Business Unit filed Is Roadnet ,
    stage name is Lost and its corresponding account Id related all Opportunity's stage name is also Lost then
    1.It can query all account related Contact records and update those contact records
    by making Nurture Newsletter filed value is TRUE.
    **/
    public static void checkForLostStageAndUpdateOpptContacts(List<Opportunity> olderOppts, List<Opportunity> newOppts)
    {        
        try
        {
            Set<Id> accountIdSet = new Set<Id>();
            List<Contact> accountContacts = new List<Contact>();
            for (integer i = 0; i < newOppts.size(); i++)
            {
                if (newOppts[i].Owner_Business_Unit__c == 'Roadnet' &&
                    olderOppts[i].StageName != newOppts[i].StageName && 
                    newOppts[i].StageName != null) 
                {
                    
                    
                    if (isOpptStageLost(newOppts[i].StageName) && areAllOpptsOfAccountLost(newoppts[i].AccountId))
                    {
                        accountIdSet.add(newoppts[i].AccountId);
                    }
                }
            }
            
            if (!accountIdSet.isEmpty())
            {
                accountContacts = [select id, name, nurture_newsletter__c from Contact where accountid IN: accountIdSet LIMIT 50000];
                queryAndMarkContactsNurtureNewletter(accountContacts);                            
            }
            
        }
        catch(Exception e)
        {
            EmailClassRoadnet.sendErrorEmail('queryAndMarkContactsNurtureNewletter failed due to: ' + e.getMessage(),null);
        }
    }

    private static void queryAndMarkContactsNurtureNewletter(List<Contact> accountContacts)
    {        
        //List<Contact> accountContacts = [select id, name, nurture_newsletter__c from Contact where accountid =: accountId];
        for (Contact singleContact : accountContacts)
        {
            singleContact.Nurture_Newsletter__c = true;         
        }
        updateContactsUsingSaveResultAndSendErrorEmailIfNeeded(accountContacts);               
    }

    @TestVisible
    private static void updateContactsUsingSaveResultAndSendErrorEmailIfNeeded(List<Contact> contacts)
    {        
        Database.saveResult[] saveResults = database.update(contacts, false);       
        integer numContactsFailedUpdate = 0;
        String failedContactString = '';
        for (integer i = 0; i < contacts.size(); i++)
        {
            if (!saveResults[i].isSuccess())
            {
                failedContactString += ' ContactId: ' + contacts[i].Id + '; ';
                numContactsFailedUpdate++;
            }
        }
        if (numContactsFailedUpdate > 0)
        {
            if (contacts.size() > 0)
            {
                EmailClassRoadnet.sendErrorEmail('Contacts failed updating when setting nuture newsletter checkbox: ' + failedContactString , contacts[0].Id);
            }   
            else
            {
                EmailClassRoadnet.sendErrorEmail('Contacts failed updating when setting nuture newsletter checkbox: ' + failedContactString , null);
            }
        }
    }

    @TestVisible
    private static boolean isOpptStageLost(String stageName)
    {
        if (stageName == null || stageName.length() == 0)
        {
            return false;
        }
        if (allOpptStages == null)
        {
            allOpptStages = [select id,MasterLabel, DefaultProbability from OpportunityStage where isactive = true];
        }
        for (OpportunityStage os : allOpptStages)
        {
            if (os.MasterLabel != null && os.MasterLabel == stageName)
            {
                String stageNameToLower = os.MasterLabel.toLowerCase();
                return stageNameToLower.contains('lost');
            }
        }
        
        return false;
    }    
    
    public static boolean checkIfClosedOpp(Opportunity opp)
    {       
        if (getlistOfClosedStagesForOpp().contains(opp.StageName))
            return true;
        else
            return false;
    }

    @TestVisible
    private static boolean areAllOpptsOfAccountLost(Id accountId)
    {        
        List<Opportunity> allOpptsOfAccount = [select id, stagename from Opportunity where accountId =: accountId ];
        for (Opportunity singleOppt : allOpptsOfAccount)
        {
            if (!isOpptStageLost(singleOppt.stagename))
            {
                return false;
            }
        }
        return true;
    }
    
    /**
    At the time of updating Opportunity it can get the list of accounts whose Opportunity Stage Name is Closed Lost.
    1.On Account update to the Status filed value as Inactive Prospect if this Status value is NOT EQUAL TO Contract Customer
    2.On Account update Closed Reason filed value by taking from Opportunity Reason Lost filed value.
    **/
    public static void handleOpportunityClosure(List<Opportunity> listOfnewOpportunities, List<Opportunity> listClosedOpportunities) {
        List<String> listOpportunityId = new List<String>();
        List<OpportunityLineItem> listOpportunityLineItem = new List<OpportunityLineItem>();
        Map<Id, Opportunity> mapOfClosedOpportunities = new Map<Id, Opportunity>();
        List<Id> listAcctids = new List<Id>();

        for (Integer i = 0; i < listOfnewOpportunities.size(); i++) {
            if (listOfnewOpportunities[i].ownerId != listClosedOpportunities[i].ownerId) {
                listOpportunityId.add(trigger.new[i].id);
            }

            if (listOfnewOpportunities[i].stageName != listClosedOpportunities[i].stageName) {
                if (checkIfLostOpp(listOfnewOpportunities[i])) {
                    mapOfClosedOpportunities.put(listOfnewOpportunities[i].id, listOfnewOpportunities[i]);
                    listAcctids.add(listOfnewOpportunities[i].accountId);
                }
            }
        }

        Map<ID, Account> mapOfAccounts;
        if (!mapOfClosedOpportunities.isEmpty()) {
            mapOfAccounts = new Map<Id, Account>([
                    select id, QWBS_Status__c, QWBS_Cust_ID__c, (
                            select id, stageName
                            from Opportunities
                            where
                            (stageName NOT IN:getlistOfClosedStagesForOpp()) and
                            id NOT IN:mapOfClosedOpportunities.keySet()
                    )
                    from Account
                    where ID IN:listAcctids
            ]);
        }

        List<Account> listOfAccsToBeClosed = new List<Account>();

        for (Opportunity o : mapOfClosedOpportunities.values()) {
            if (mapOfAccounts.containsKey(o.AccountId)) {
                //Does not have another opportunity which is not closed
                if (mapOfAccounts.get(o.AccountId).opportunities.isEmpty()) {
                    //If not a contract customer
                    if (mapOfAccounts.get(o.AccountId).QWBS_Status__c != 'Contract Customer') {
                        mapOfAccounts.get(o.AccountId).QWBS_Status__c = 'Inactive Prospect';
                        mapOfAccounts.get(o.AccountId).Closed_Reason__c = o.Reason_Lost__c;
                        listOfAccsToBeClosed.add(mapOfAccounts.get(o.AccountId));
                    }
                }
            }
        }
        try {
            update listOfAccsToBeClosed;
        } catch (exception e) {
            System.debug('Exception in updating accounts: ' + e.getMessage());
        }

        if (!listOpportunityId.isEmpty()) {
            Map<String, OpportunityLineItem> mapOpportunityLineItem = new Map<String, OpportunityLineItem>([
                    Select
                            Opportunity_Owner__c,
                            OpportunityId
                    From
                            OpportunityLineItem
                    where
                            OpportunityId in :listOpportunityId
                    Limit 50000
            ]);
            for (String oppLineItemId : mapOpportunityLineItem.keySet()) {
                mapOpportunityLineItem.get(oppLineItemId).Opportunity_Owner__c = mapOfClosedOpportunities.get(mapOpportunityLineItem.get(oppLineItemId).OpportunityId).ownerId;
                listOpportunityLineItem.add(mapOpportunityLineItem.get(oppLineItemId));
            }
            try {
                if (!listOpportunityLineItem.isEmpty()) {
                    update listOpportunityLineItem;
                }
            } catch (Exception e) {
                system.debug('Exception occured:' + e.getMessage());
            }
        }
    }

    public static Set<String> getlistOfClosedStagesForOpp()
    {       
        Set<String> listOfClosedStage =  new Set<String>();
        if (listOfClosedStage.isEmpty())                                   
            listOfClosedStage.addAll(Global_Variable__c.getInstance('Closed Opportunity Stage').value__c.split(';'));
        
        return listOfClosedStage;
    }
    
    public static boolean checkIfLostOpp(Opportunity opp)
    {       
        
        if (opp.IsClosed && opp.StageName == 'Closed Lost')
            return true;
        
        else
            return false;
    }

    /*** Code Added by Vignesh --- Start***/
    private static boolean m_isUserProfileSalesSysAdminOrSalesDomManager;
  @testVisible  private static boolean isUserProfileSalesSysAdminOrSalesDomManager
    {
        get
        {
            //  change made by joseph hutchins
            //  per SFDC case 01778579, we do not want users with profile Sales-Sys admin to have to fill in the bant sections
            //  i think it's easier to have a bool here to check the user's profile before validateing the required actions.
            if (m_isUserProfileSalesSysAdminOrSalesDomManager == null)
            {
                if (isSysAdminOrSalesDomManager__c.getInstance().isUsrProfilSalesSysAdminOrSalesDomManagr__c)
                {
                    m_isUserProfileSalesSysAdminOrSalesDomManager=True;
                }
                else
                {
                    //  should never evaulate but i dont like using contains on a String without checking it
                    m_isUserProfileSalesSysAdminOrSalesDomManager = false;
                }
                
            }
            return m_isUserProfileSalesSysAdminOrSalesDomManager;
        }
    }

    /**********  Sai Krishna: Method Commented out as its Not used any more in All opportunity Trigger  ***************************/
     /*Create/Update Asset out of Opportunity Product, when opportunity got approved by Finance as well as Legal team
    Ram Majji case # 02246752  on 3/28/2016
    Change the time when contracted assets are created/updated to: Opportunity Stage = Sales Complete and Opportunity Legal Review = Contract Data Entry Process 
    and Finance Review = Approved.   In addition, there is a field called Asset (lookup to the Contracted Asset) on the Opportunity Product that is not being populated currently.  
    They would like this to be populated so that there is a link between the Opportunity Product and the Contracted Asset.*/       
    /*public static void createUpdateAssets(Map<ID, Opportunity> newMap, Map<ID, Opportunity> oldMap) 
    {        
        Set<ID> qualifiedOpptyIDs = new Set<ID>();
        Set<Id> qualifiedClosedWonOpptyIds = new Set<Id>();
        List<OpportunityLineItem> qualifiedOLIsLst = new List<OpportunityLineItem>();
        List<OpportunityLineItem> qualifiedClosedWonOLIsLst = new List<OpportunityLineItem>();
        map<Id, Opportunity> assetizedOpps = new map<Id, Opportunity>();
        set<Id> setaccountId = new set<Id>(); 
        
        /*for (Opportunity oppty : newMap.values())
        {
            Boolean oldTrigger = false;
            Boolean newTrigger = false;
            oldTrigger = (oldMap.get(oppty.id).StageName == 'Sales Complete' && oldMap.get(oppty.id).Legal_Review__c == 'Contract Data Entry Process' && oldMap.get(oppty.id).Finance_Status__c == 'Approved');
            newTrigger = (oppty.StageName == 'Sales Complete' && oppty.Legal_Review__c == 'Contract Data Entry Process' && oppty.Finance_Status__c == 'Approved');
            if (!isOpportunityTriggerRunning && !oldTrigger && newTrigger)
            {
                qualifiedOpptyIDs.add(oppty.id);
                assetizedOpps.put(oppty.Id, new Opportunity(Id=oppty.Id, Has_Converted_Assets__c = true));
                setaccountId.add(oppty.AccountId); //New set for collecting account ids
            }
            
            if (!isOpportunityTriggerRunning && oppty.StageName == 'Closed Won' && oldMap.get(oppty.id).StageName != 'Closed Won') {
                qualifiedClosedWonOpptyIds.add(oppty.id);
            }
        }
        if (qualifiedOpptyIDs.size() > 0)
        {    
            qualifiedOLIsLst = validateAssetCreation(qualifiedOpptyIDs);
            if (qualifiedOLIsLst.size() > 0)
                isOpportunityTriggerRunning = true;
        }
        if (qualifiedOpptyIDs.size() > 0 || setaccountId.size() > 0)
        {    
            CreateUpdateAssetQueueable queblejob = new CreateUpdateAssetQueueable(qualifiedOLIsLst, assetizedOpps, setaccountId, false);
            String jobID = System.enqueueJob(queblejob);
            if (jobID == null || jobID =='')
                System.debug('Error in Asset Creation'); 
        }
        
        if (qualifiedClosedWonOpptyIds.size() > 0) {
            qualifiedClosedWonOLIsLst = validOliLineType(qualifiedClosedWonOpptyIds);
            CreateUpdateAssetQueueable queblejob = new CreateUpdateAssetQueueable(qualifiedOLIsLst, null, null, true);
            String jobID = System.enqueueJob(queblejob);
            if (jobID == null || jobID =='')
                System.debug('Error in Asset Creation'); 
        }*/
        
        /*for (Opportunity oppty : newMap.values())
        {
            Boolean oldTrigger = false;
            Boolean newTrigger = false;
            oldTrigger = (oldMap.get(oppty.id).Finance_Status__c == 'Approved' && oldMap.get(oppty.id).Legal_Review__c == 'Approved');
            newTrigger = (oppty.Finance_Status__c == 'Approved' && oppty.Legal_Review__c == 'Approved');
            
            if (!isOpportunityTriggerRunning && !oldTrigger && newTrigger)
            {
                qualifiedOpptyIDs.add(oppty.id);
                assetizedOpps.put(oppty.Id, new Opportunity(Id=oppty.Id, Has_Converted_Assets__c = true));
            }
            
            if (oppty.IsClosed && oppty.IsWon && oppty.IsWon != oldMap.get(oppty.Id).isWon)
                setaccountId.add(oppty.AccountId);
        }
        
        if (qualifiedOpptyIDs.size() > 0)
        {    
            qualifiedOLIsLst = validateAssetCreation(qualifiedOpptyIDs);
            if (qualifiedOLIsLst.size() > 0)
                isOpportunityTriggerRunning = true;
        }
        
        if (qualifiedOpptyIDs.size() > 0 || setaccountId.size() > 0)
        {    
            CreateUpdateAssetQueueable queblejob = new CreateUpdateAssetQueueable(qualifiedOLIsLst, assetizedOpps, setaccountId);
            String jobID = System.enqueueJob(queblejob);
            if (jobID == null || jobID =='')
                System.debug('Error in Asset Creation'); 
        }
    }*/
    
    /* ARMAN & SAI: public static void oliAssetSync(List<OpportunityLineItem> lstqualifiedOLI) {
        Set<Id> assetIds = new Set<Id>();
        for (OpportunityLineItem oli : lstqualifiedOLI) {
            if (oli.Asset__c != null) assetIds.add(oli.Asset__c);
        }
        Map<Id, Asset__c> assetMap = new Map<Id, Asset__c>([Select Id, Asset_Term_Start_Date__c, Asset_Term_End_Date__c, 
                                                        Contract__c, Contract_Term_Start_Date__c, Contract_Term_End_Date__c 
                                                    From Asset__c Where Id IN :assetIds]);

        for (OpportunityLineItem oli : lstqualifiedOLI) {
            if (oli.Asset__c != null) {
                Asset__c ast = assetMap.get(oli.Asset__c);
                ast.Asset_Term_Start_Date__c = oli.ARR_Term_Begin_Date__c;
                ast.Asset_Term_End_Date__c = oli.ARR_Term_End_Date__c;
                ast.Contract__c = oli.Contract__c;
                ast.Contract_Term_Start_Date__c = oli.Contract_Term_Start_Date__c;
                ast.Contract_Term_End_Date__c = oli.Contract_Term_End_Date__c;
                assetMap.put(ast.Id, ast);
            }
        }
        
        update assetMap.values();
    }*/
    
    /*Sai Krishna: Commented As Asset__c is not being used anymore 
     public static void CreateUpdateAssetsAsync(List<OpportunityLineItem> lstqualifiedOLI, map<Id, Opportunity> assetizedOpps, set<Id> setaccountId)
    {       
        if (lstqualifiedOLI != null && lstqualifiedOLI.size() > 0)
        {
            isOpportunityTriggerRunning = true;
            createUpdateAssets(lstqualifiedOLI);
        }
        
        if (assetizedOpps != null && assetizedOpps.size() > 0)
            update assetizedOpps.values();
        
        // Additional processing for DC and User Totals on the Account    
        if (setaccountId != null && setaccountId.size() > 0)
            syncAccountUserAndDcTotals(setaccountId);    
    }*/
    
    /* ARMAN & SAI KRISHNA: private static List<OpportunityLineItem> validOliLineType(Set<ID> qualifiedOpptyIDs) {
        List<OpportunityLineItem> olisList = new List<OpportunityLineItem>();
        if (qualifiedOpptyIDs.size() > 0)
        {
            olisList = [Select Id, OpportunityId,
                                          Opportunity.AccountID, 
                                          Opportunity.Account.Name,
                                          Opportunity.Order_Type__c, 
                                          Opportunity.CloseDate, 
                                          Opportunity.Type, 
                                          Opportunity.RecordType.Name,
                                          PriceBookEntry.Product2.Name, 
                                          PriceBookEntry.Product2ID,
                                          PriceBookEntry.Product2.Is_Assetizable__c,
                                          PriceBookEntry.Product2.License_Type__c, 
                                          PriceBookEntry.Product2.ProductCode, 
                                          PriceBookEntry.Product2.Product_Type__c,
                                          PriceBookEntry.Product2.Family, 
                                          PriceBookEntry.Product2.Description,
                                          PriceBookEntry.Product2.Is_Bundle__c,
                                          PriceBookEntry.Product2.Is_Maintenance__c,
                                          Quantity, 
                                          Description,
                                          Annual_Recurring_Revenue__c,                                       
                                          License_Metric_Quantity__c,
                                          ARR_Term_Begin_Date__c, 
                                          ARR_Term_End_Date__c,
                                          Contract_Term_Start_Date__c,
                                          Contract_Term_End_Date__c,
                                          Add_On_To_Asset__c,
                                          Add_On_Source_Quote_Product__c,
                                          Unit_Sales_Price__c,
                                          Dollars_Per_Load__c,
                                          Dollars_Per_Truck__c,
                                          Licensed_DCs__c,
                                          Licensed_Users__c,
                                          Map_Notes__c,
                                          Decommission_Quantity__c,
                                          Cancellation_Type__c,
                                          Cancellation_Reason__c,
                                          Cancellation_Date__c,
                                          Line_Type__c,
                                          Product_Group__c,
                                          Quote_Product__c,
                                          Non_Recurring_Revenue__c,
                                          Billing_Frequency__c,
                                          Contract__c
                                          Asset__c,
                                          Asset__r.Maintenance_Status__c, 
                                          Asset__r.Asset_Term_Start_Date__c, 
                                          Asset__r.Asset_Term_End_Date__c,
                                          Asset__r.ARR__c, 
                                          Asset__r.Previous_Annual_Maintenance__c,
                                          Asset__r.License_Metric__c,
                                          Asset__r.License_Metric_Quantity__c,
                                          Asset__r.Non_Recurring_Revenue__c
                                          from OpportunityLineItem 
                                          where OpportunityID in: qualifiedOpptyIDs and Line_Type__c = 'New'];
        }        
        return olisList;
    }*/
    
    /* ARMAN & SAIKRISHNA: private static List<OpportunityLineItem> validateAssetCreation(Set<ID> qualifiedOpptyIDs)
    {
        List<OpportunityLineItem> olisList = new List<OpportunityLineItem>();
        if (qualifiedOpptyIDs.size() > 0)
        {
            for (OpportunityLineItem oli: [Select Id, OpportunityId,
                                          Opportunity.AccountID, 
                                          Opportunity.Account.Name,
                                          Opportunity.Order_Type__c, 
                                          Opportunity.CloseDate, 
                                          Opportunity.Type, 
                                          Opportunity.RecordType.Name,
                                          PriceBookEntry.Product2.Name, 
                                          PriceBookEntry.Product2ID,
                                          PriceBookEntry.Product2.Is_Assetizable__c,
                                          PriceBookEntry.Product2.License_Type__c, 
                                          PriceBookEntry.Product2.ProductCode, 
                                          PriceBookEntry.Product2.Product_Type__c,
                                          PriceBookEntry.Product2.Family, 
                                          PriceBookEntry.Product2.Description,
                                          PriceBookEntry.Product2.Is_Bundle__c,
                                          PriceBookEntry.Product2.Is_Maintenance__c,
                                          Quantity, 
                                          Description,
                                          Annual_Recurring_Revenue__c,                                       
                                          License_Metric_Quantity__c,
                                          ARR_Term_Begin_Date__c, 
                                          ARR_Term_End_Date__c,
                                          Contract_Term_Start_Date__c,
                                          Contract_Term_End_Date__c,
                                          Add_On_To_Asset__c,
                                          Add_On_Source_Quote_Product__c,
                                          Unit_Sales_Price__c,
                                          Dollars_Per_Load__c,
                                          Dollars_Per_Truck__c,
                                          Licensed_DCs__c,
                                          Licensed_Users__c,
                                          Map_Notes__c,
                                          Decommission_Quantity__c,
                                          Cancellation_Type__c,
                                          Cancellation_Reason__c,
                                          Cancellation_Date__c,
                                          Line_Type__c,
                                          Product_Group__c,
                                          Quote_Product__c,
                                          Non_Recurring_Revenue__c,
                                          Billing_Frequency__c,
                                          Contract__c
                                          Asset__c,
                                          Asset__r.Maintenance_Status__c, 
                                          Asset__r.Asset_Term_Start_Date__c, 
                                          Asset__r.Asset_Term_End_Date__c,
                                          Asset__r.ARR__c, 
                                          Asset__r.Previous_Annual_Maintenance__c,
                                          Asset__r.License_Metric__c,
                                          Asset__r.License_Metric_Quantity__c,
                                          Asset__r.Non_Recurring_Revenue__c
                                          from OpportunityLineItem 
                                          where OpportunityID in: qualifiedOpptyIDs
                                          ORDER BY Line_Type__c DESC])
            {
                //Modified conditional for asset validation
                if (oli.PriceBookEntry.Product2.Is_Assetizable__c || oli.PricebookEntry.Product2.Is_Maintenance__c)
                    olisList.add(oli);
                else if (oli.Opportunity.Order_Type__c == 'Maintenance' || oli.Opportunity.Order_Type__c == 'Term License' || oli.Opportunity.Order_Type__c == 'Customer Portal'){
                    olisList.add(oli);
                }
            }           
        }        
        return olisList;
    } */


    /*Sai Krishna: Method Commented as Organization doesnt use ASSET__C anymore
     private static void createUpdateAssets(List<OpportunityLineItem> qualifiedOLIsList)
    {
        if (qualifiedOLIsList.size() > 0)
        {
            // Get all OLI to Asset Mappings - Assets will be upserted, OLIs will be updated, and Opps will be 'touched'
            List<OLIAssetWrapper> allOLIAssets = getOLIAssets(qualifiedOLIsList);
            list<Fulfillment_Event__c> fulfillmentRecs = createDecomissionFulfillmentRecs(qualifiedOLIsList);
            
            // Save all assets
            List<Asset__c> allAssetsToInsert = new List<Asset__c>();
            for (OLIAssetWrapper oliAst: allOLIAssets) 
            {
                allAssetsToInsert.add(oliAst.ast);
            }
            
            upsert allAssetsToInsert;   
            if (fulfillmentRecs.size() > 0)
            {
                insert fulfillmentRecs;
            } 
            
            // Update all OLIs
            // Create Map with all OLI & ASSETID
            // Create Map with all OLI with OLI for all add-on
            Map<Id, Id> OLIAssetMap = new Map<Id, Id>();
            Map<Id, Id> OLIAddonMap = new Map<Id, Id>();
            
            List<OpportunityLineItem> allOLIsToUpdate = new List<OpportunityLineItem>();
            Set<ID> opptyIDs = new Set<ID>();
            for (OLIAssetWrapper oliAst: allOLIAssets)
            {
                if (oliAst.oli != null && !oliAst.oli.PriceBookEntry.Product2.Is_Bundle__c)
                {
                    OpportunityLineItem oli = oliAst.oli;
                    oli.Asset__c = oliAst.ast.id;
                    
                    allOLIsToUpdate.add(oli);
                    
                    opptyIDs.add(oli.OpportunityID);
                    
                    oliAssetMap.put(oli.Quote_Product__c,oli.Asset__c);  //Tanvir   
                    if (oli.add_on_Source_Quote_Product__c != null) // Tanvir
                        oliAddonMap.put(oli.Asset__c,oli.add_on_Source_Quote_Product__c); //Tanvir 
                }
                
                if (oliAst.maintOLI != null && !oliAst.maintOLI.PriceBookEntry.Product2.Is_Bundle__c)
                {
                    OpportunityLineItem oli = oliAst.maintOLI;
                    oli.Asset__c = oliAst.ast.id;
                    
                    allOLIsToUpdate.add(oli);
                    
                    opptyIDs.add(oli.OpportunityID);
                }
                
            }
            if (!allOLIsToUpdate.isEmpty())
            {    
                update allOLIsToUpdate;
            }
            
            List<Asset__c> allAddonAssetsToUpdate = new List<Asset__c>();
            Map<ID,Asset__c> mapAssets = new Map<ID,Asset__c>([ Select Id, Name From Asset__c Where Id in :OliAddOnMap.Keyset()]);
            
            for (Asset__c ast :MapAssets.values()){
                ast.add_on_to__c = OliAssetMap.get(OliAddOnMap.get(ast.ID));
                allAddonAssetsToUpdate.add(ast);
            } 
            try{
            if (!allAddonAssetsToUpdate.isEmpty())
            {    
                update allAddonAssetsToUpdate;
            }
            }
            Catch(Exception e )
            {
            System.debug('Error Log'+ e.getMessage());
            }
            
            // 'Touch' all Opps (i.e. only the Id is set in the update record) currently
            // commented as we are updating opportunity in 'CreateUpdateAssetsAsync' method
            /*List<Opportunity> allOpptysToUpdate = new List<Opportunity>();
for (ID opptyid : opptyIDs)
{
Opportunity oppty = new Opportunity(id = opptyid);
allOpptysToUpdate.add(oppty);
}
if (!allOpptysToUpdate.isEmpty())
{    
update allOpptysToUpdate;
}*/          
        /*}
    }*/

    /////////////////////////



    /*Sai krishna: Method Commented as the Organization doesnot use ASSET__c any more
     private static List<OLIAssetWrapper> getOLIAssets(List<OpportunityLineItem> oliList)
    {
        // NOTE: The ids used as the key will be *either* the asset id or the QP id!
        // This is to allow lookup of the core product from an add-on product's 
        // Add_on_Source_Quote_Product__c or Add_On_Source_Asset__c field.
        Map<Id,OLIAssetWrapper> oliAssets = new Map<Id,OLIAssetWrapper>();
        
        // Sort maintenance OLIs out for processing after non-maintenance OLIs
        List<OpportunityLineItem> maintOLIs = new List<OpportunityLineItem>();
        
        if (oliList != null )
        {
            for (OpportunityLineItem oli: oliList)
            {
               
                if (oli.PricebookEntry.Product2.Is_Maintenance__c)
                {
                    maintOLIs.add(oli);
                }
                else
                {
                    Asset__c ast;
                    if (oli.Asset__c == null) 
                        ast = createAssetFromOLI(oli);
                    else
                    {
                        ast = updateAssetFromOLI(oli);                       
                    }
                    
                    OLIAssetWrapper oliAst = new OLIAssetWrapper();
                    oliAst.oli = oli;
                    oliAst.ast = ast;
                    if (ast.Id != null)
                    {
                        oliAssets.put(ast.Id, oliAst);
                    }
                    else
                    {
                        oliAssets.put(oli.Quote_Product__c, oliAst);
                    }
                }
            }
            
            if (maintOLIs.size() > 0)
            {
                for (OpportunityLineItem oli: maintOLIs)
                {
                    
                    OLIAssetWrapper oliAst;
                    if (oli.Add_On_To_Asset__c != null)
                    {
                        if (oliAssets.containsKey(oli.Add_On_To_Asset__c))
                        {
                            oliAst = oliAssets.get(oli.Add_On_To_Asset__c);
                        }
                        else
                        {
                            // Asset not loaded already (Maintenance Renewal most likely), get the asset
                            Asset__c ast = getAssetRec(oli.Add_On_To_Asset__c); 
                            oliAst = new OLIAssetWrapper();
                            oliAst.ast = ast;                            
                            oliAssets.put(ast.Id, oliAst);
                        }
                    }                    
                    else if (oli.Add_On_Source_Quote_Product__c != null)
                    {
                        if (oliAssets.containsKey(oli.Add_On_Source_Quote_Product__c))
                        {
                            oliAst = oliAssets.get(oli.Add_On_Source_Quote_Product__c);
                        }
                        else
                        {
                            // Throw error if Asset not created under the Core QP record?
                        }
                    }
                    else
                    {
                        // Throw error if neither Add_On_Source/To fields are set?
                    }
                    
                    if (oliAst != null)
                    {
                        applyMaintenanceOLI(oli, oliAst);                        
                        // Set the maintenance OLI reference
                        oliAst.maintOLI = oli;
                    }
                }
            }
        }                
        return oliAssets.values();
    }*/

    /*Sai krishna: Method Commented as the Organization doesnot use ASSET__c any more
    private static Asset__c createAssetFromOLI(OpportunityLineItem oli)
    {
        Asset__c ast = new Asset__c();
        
        ast.Account__c = oli.Opportunity.AccountID;
        ast.Name = oli.PriceBookEntry.Product2.Name;
        ast.Name = ast.Name.subString(0, Math.min(79, ast.Name.length()));
        ast.Product__c = oli.PriceBookEntry.Product2ID;
        ast.ARR__c = oli.Annual_Recurring_Revenue__c;
        ast.Non_Recurring_Revenue__c = oli.Non_Recurring_Revenue__c;
        ast.Description__c = oli.PricebookEntry.Product2.Description;
        ast.Map_Notes__c = oli.Map_Notes__c;
        ast.Billing_Frequency__c = oli.Billing_Frequency__c;        
        if (oli.Line_Type__c == 'Decommission') // Decommission of bundle products
            ast.License_Metric_Quantity__c = oli.Decommission_Quantity__c;
        else
            ast.License_Metric_Quantity__c = oli.License_Metric_Quantity__c;        
        ast.Maintenance_Status__c = 'On Maintenance';
        ast.Asset_Term_Start_Date__c = oli.ARR_Term_Begin_Date__c;
        ast.Asset_Term_End_Date__c = oli.ARR_Term_End_Date__c;
        ast.Contract_Term_Start_Date__c = oli.Contract_Term_Start_Date__c;
        ast.Contract_Term_End_Date__c = oli.Contract_Term_End_Date__c;
        ast.Product_Group__c = oli.Product_Group__c;
        ast.Unit_Sales_Price__c = oli.Unit_Sales_Price__c;
        ast.Dollars_Per_Load__c = oli.Dollars_Per_Load__c;
        ast.Dollars_Per_Truck__c = oli.Dollars_Per_Truck__c;
        ast.Number_of_DCs__c = oli.Licensed_DCs__c;
        ast.Number_of_Users__c = oli.Licensed_Users__c;
        ast.OLI_Line_Type__c = oli.Line_Type__c;
        ast.Add_On_To__c = oli.Add_On_To_Asset__c;
        ast.Contract__c = oli.Contract__c;
        if (oli.Opportunity.RecordType.Name == 'Eval') {
            ast.Eval__c = true;
        }
        return ast;
    }*/

    /*Sai krishna: Method Commented as the Organization doesnot use ASSET__c any more
    private static Asset__c updateAssetFromOLI(OpportunityLineItem oli)
    {
        OpportunityLineItem thisOppLineItem = oli;
        Asset__c ast = oli.Asset__r;       
        if (oli.Line_Type__c == 'Renewal')
        {
            ast.Previous_Annual_Maintenance__c = ast.ARR__c;
            ast.Previous_Metric_Qty__c = ast.License_Metric_Quantity__c;
            ast.ARR__c = oli.Annual_Recurring_Revenue__c;
            ast.Non_Recurring_Revenue__c = oli.Non_Recurring_Revenue__c;
            ast.Billing_Frequency__c = oli.Billing_Frequency__c;
            ast.Asset_Term_Start_Date__c = oli.ARR_Term_Begin_Date__c;
            ast.Asset_Term_End_Date__c = oli.ARR_Term_End_Date__c;
            ast.License_Metric_Quantity__c = oli.License_Metric_Quantity__c;
            ast.Map_Notes__c = oli.Map_Notes__c;
            ast.Contract_Term_Start_Date__c = oli.Contract_Term_Start_Date__c;
            ast.Contract_Term_End_Date__c = oli.Contract_Term_End_Date__c;
            if (oli.Contract__c != null)
                ast.Contract__c = oli.Contract__c;
        }
        else if (oli.Line_Type__c == 'Decommission')
        {         
            ast.Previous_Annual_Maintenance__c = ast.ARR__c;
            ast.Previous_Metric_Qty__c = ast.License_Metric_Quantity__c;
            ast.Asset_ARR_at_Decommission__c = ast.ARR__c;
            //ast.License_Metric_Quantity__c -= oli.Decommission_Quantity__c;
            ast.License_Metric_Quantity__c = NullSafeAdd(ast.License_Metric_Quantity__c, -oli.Decommission_Quantity__c);
            ast.ARR__c = NullSafeAdd(ast.ARR__c, oli.Annual_Recurring_Revenue__c);
            ast.Non_Recurring_Revenue__c = NullSafeAdd(ast.Non_Recurring_Revenue__c, oli.Non_Recurring_Revenue__c);
            ast.Cancellation_Reason__c = oli.Cancellation_Reason__c;
            ast.Cancellation_Type__c = oli.Cancellation_Type__c;
            ast.Cancellation_Date__c = oli.Cancellation_Date__c;
            if (oli.Cancellation_Type__c == 'Cancellation') {
                ast.Maintenance_Status__c = 'Decommissioned';
            }
        }
        else if (oli.Line_Type__c == 'Extension')
        {
            ast.Previous_Annual_Maintenance__c = ast.ARR__c;
            ast.Previous_Metric_Qty__c = ast.License_Metric_Quantity__c;
            ast.ARR__c = NullSafeAdd(ast.ARR__c, oli.Annual_Recurring_Revenue__c);
            ast.Non_Recurring_Revenue__c = NullSafeAdd(ast.Non_Recurring_Revenue__c, oli.Non_Recurring_Revenue__c);
            ast.License_Metric_Quantity__c = NullSafeAdd(ast.License_Metric_Quantity__c, oli.License_Metric_Quantity__c);
            ast.Contract_Term_Start_Date__c = oli.Contract_Term_Start_Date__c;
            ast.Contract_Term_End_Date__c = oli.Contract_Term_End_Date__c;
            if (oli.Contract__c != null)
                ast.Contract__c = oli.Contract__c;
        }
        else if (oli.Line_Type__c == 'Migration')
        {
            ast.ARR__c = NullSafeAdd(ast.ARR__c, oli.Annual_Recurring_Revenue__c);
            ast.Non_Recurring_Revenue__c = NullSafeAdd(ast.Non_Recurring_Revenue__c, oli.Non_Recurring_Revenue__c);
            ast.License_Metric_Quantity__c = NullSafeAdd(ast.License_Metric_Quantity__c, oli.License_Metric_Quantity__c);
            ast.Product__c = oli.PriceBookEntry.Product2ID;
            if (oli.Contract__c != null)
                ast.Contract__c = oli.Contract__c;
        }            
        return ast;
    }*/



/********** TBD: Sai Krishna  ***************************/
    /*Sai krishna: Method Commented as the Organization doesnot use ASSET__c any more
    private static Asset__c getAssetRec(Id assetId)
    {             
        if (!cachedAssets.containsKey(assetId))
        {
            Asset__c ast = [SELECT Id,
                            ARR__c,
                            Asset_ARR_at_Decommission__c,
                            Asset_Term_End_Date__c,
                            Asset_Term_Start_Date__c,
                            License_Metric__c,
                            License_Metric_Quantity__c,
                            Maintenance_Status__c,
                            Previous_Metric_Qty__c,
                            Previous_Annual_Maintenance__c,
                            Product__r.Is_Maintenance__c,
                            Sold_Price__c,
                            Unit_Sales_Price__c
                            FROM Asset__c
                            WHERE Id = :assetId][0];
            
            cachedAssets.put(assetId, ast);
        }        
        return cachedAssets.get(assetId);       
    }*/
////////////////////////////////////////////////////////////////


/*Sai krishna: Method Commented as the Organization doesnot use ASSET__c any more
    public static list<Fulfillment_Event__c> createDecomissionFulfillmentRecs(List<OpportunityLineItem> oliList)
    {
        list<Fulfillment_Event__c> fList = new list<Fulfillment_Event__c>();        
        for (OpportunityLineItem oli :oliList)
        {        
            if (oli.Asset__c != null && oli.Line_Type__c == 'Decommission' && oli.Decommission_Quantity__c != null && oli.Decommission_Quantity__c > 0)
            {
                fList.add( new Fulfillment_Event__c( Asset__c = oli.Asset__c
                                                    ,Event_Date__c = System.today()
                                                    ,License_Metric_Quantity__c = (-1*oli.Decommission_Quantity__c)
                                                    ,Event_Type__c = 'Decommission'));
            }
        }
        return fList;
    }*/
    
/*Sai krishna: Method Commented as the Organization doesnot use ASSET__c any more
    private static void applyMaintenanceOLI(OpportunityLineItem oli, OLIAssetWrapper oliAst)
    {
        
        if (oli.Line_Type__c == 'New')
        {
            oliAst.ast.Asset_Term_Start_Date__c = oli.ARR_Term_Begin_Date__c;
            oliAst.ast.Asset_Term_End_Date__c = oli.ARR_Term_End_Date__c;
            oliAst.ast.ARR__c = oli.Annual_Recurring_Revenue__c;
        }
        else if (oli.Line_Type__c == 'Renewal')
        {
            oliAst.ast.Asset_Term_Start_Date__c = oli.ARR_Term_Begin_Date__c;
            oliAst.ast.Asset_Term_End_Date__c = oli.ARR_Term_End_Date__c;
            oliAst.ast.ARR__c = oli.Annual_Recurring_Revenue__c;
        }
        else if (oli.Line_Type__c == 'Extension')
        {
            oliAst.ast.ARR__c = NullSafeAdd(oliAst.ast.ARR__c, oli.Annual_Recurring_Revenue__c);
        }
        else if (oli.Line_Type__c == 'Decommission')
        {
            oliAst.ast.Previous_Annual_Maintenance__c = oliAst.ast.ARR__c;
            oliAst.ast.Previous_Metric_Qty__c = oliAst.ast.License_Metric_Quantity__c;
            oliAst.ast.Asset_ARR_at_Decommission__c = oliAst.ast.ARR__c;
            
            // NOTE: All amounts are being *added* to the existing values, so a decrease
            //        in an amount value needs to be negative.
            oliAst.ast.ARR__c = NullSafeAdd(oliAst.ast.ARR__c, oli.Annual_Recurring_Revenue__c);
            // Need to reduce the LMQ as well, although now the total sold price doesn't match the LMQ anymore
            //oliAst.ast.License_Metric_Quantity__c  = NullSafeAdd(oliAst.ast.License_Metric_Quantity__c, -oli.Decommission_Quantity__c);
            //Case #02251943 Sripathi Gullapalli, Fixed null pointer exception
            oliAst.ast.License_Metric_Quantity__c  = NullSafeAdd(oliAst.ast.License_Metric_Quantity__c, ((oli.Decommission_Quantity__c != null) ? -oli.Decommission_Quantity__c:null));

            oliAst.ast.Cancellation_Reason__c = oli.Cancellation_Reason__c;
            oliAst.ast.Cancellation_Type__c = oli.Cancellation_Type__c;
            oliAst.ast.Cancellation_Date__c = oli.Cancellation_Date__c;
            if (oli.Cancellation_Type__c == 'Cancellation')
            {
                oliAst.ast.Maintenance_Status__c = 'Decommissioned';
            }
        }
    }*/

    //NullSafeAdd -- returns null if both parameters are null, otherwise adds the two, converting either parameter to 0 if it is null
    /*public static Decimal NullSafeAdd(Decimal x, Decimal y) { return (x == null && y == null ? null : (x == null ? 0 : x) + (y == null ? 0 : y)); }
    // ARMAN: public static Integer NullSafeAdd(Integer x, Integer y) { return (x == null && y == null ? null : (x == null ? 0 : x) + (y == null ? 0 : y)); }
    */

    /* ARMAN: class OLIAssetWrapper
    {
        public OpportunityLineItem oli{get; set;}
        public OpportunityLineItem maintOLI {get; set;} // for tracking the maintenance OLI so we can update it as having been processed
        public Asset__c ast {get; set;}
    } */

/*Sai krishna: Method Commented as the Organization doesnot use ASSET__c any more
    public static void syncAccountUserAndDcTotals(Set<Id> accountIds)
    {
        if (accountIds.size() == 0)
        {
            return; 
        }
        
        List<Account> accountList = new List<Account>();       
        map<Id, Decimal> maxDCMap  = new map<Id, Decimal>();
        map<Id, Decimal> maxUserMap  = new map<Id, Decimal>();
        map<Id, Decimal> sumExtraDCMap  = new map<Id, Decimal>();
        map<Id, Decimal> sumExtraUserMap  = new map<Id, Decimal>();
        
        // Initialize the maps so our code is simpler below
        for (Id acctId : accountIds)
        {
            maxDCMap.put(acctId, 0);
            maxUserMap.put(acctId, 0);
            sumExtraDCMap.put(acctId, 0);
            sumExtraUserMap.put(acctId, 0);
        }
        
        /*
=== On the Account, we do: ===
MAX(SUM of IncludedDCs Grouping by Product) + SUM(Extra DCs)
*/
        /*for (AggregateResult ap : [SELECT sum(Included_DCs__c) sumIncludedDCsForProd
                                  , sum(Included_Users__c) sumIncludedUsersForProd
                                  , sum(Extra_DCs__c) extraDCsForProd
                                  , sum(Extra_Users__c) extraUsersForProd
                                  , Account__c acctId
                                  , Product__c
                                  FROM Asset__c
                                  WHERE Account__c in :accountIds
                                  AND Maintenance_Status__c IN :VCG_CPQ_QuoteController.onMaintenanceStatuses
                                  GROUP BY Account__c, Product__c])
        {
            Id accId = (Id)ap.get('acctId');
            Decimal sumIncludedDCsForProd = (Decimal)ap.get('sumIncludedDCsForProd') != null ? (Decimal)ap.get('sumIncludedDCsForProd') : 0 ;
            Decimal sumIncludedUsersForProd = (Decimal)ap.get('sumIncludedUsersForProd') != null ? (Decimal)ap.get('sumIncludedUsersForProd') : 0;
            Decimal extraDCsForProd = (Decimal)ap.get('extraDCsForProd') != null ? (Decimal)ap.get('extraDCsForProd') : 0;
            Decimal extraUsersForProd = (Decimal)ap.get('extraUsersForProd') != null ? (Decimal)ap.get('extraUsersForProd') : 0;
            
            
            // collect max included DCs & Users across all products
            if (sumIncludedDCsForProd > maxDCMap.get(accId))
                maxDCMap.put(accId, sumIncludedDCsForProd);
            
            if (sumIncludedUsersForProd > maxUserMap.get(accId))
                maxUserMap.put(accId, sumIncludedUsersForProd);
            
            // sum up extra DCs & Users across all products
            sumExtraDCMap.put(accId, sumExtraDCMap.get(accId) + extraDCsForProd);
            sumExtraUserMap.put(accId, sumExtraUserMap.get(accId) + extraUsersForProd);
            
        }
        
        // Calculate the total allowed users and assign back to the account
        for (Id accId : accountIds)
        {
            Account a = new Account(Id = accId);
            
            // calculate the total allowed DC and User Values
            a.Total_DCs__c   = (maxDCMap.get(accId) + sumExtraDCMap.get(accId) == 0 ? null : maxDCMap.get(accId) + sumExtraDCMap.get(accId));
            a.Total_Users__c = (maxUserMap.get(accId) + sumExtraUserMap.get(accId) == 0 ? null : maxUserMap.get(accId) + sumExtraUserMap.get(accId));
            
            
            accountList.add(a);
        }
        
        // Update the Accounts
        update accountList;
    }*/
    
    /* Code unit to create as well as update 'Time and State details' of opportunity */
    public static void createTIS(List<Opportunity> lstNewTrigger)
    {          
        if (system.label.TIS_Trigger_For_Lead_And_Opp == 'true')
        {
            CreateTISLeadAndOpp.CreateNewTISRecord(lstNewTrigger, 'Opportunity', null);                
        } 
    }

    public static void UpdateTIS(List<Opportunity> lstNewTrigger, Map<Id,Opportunity> mapOldTrigger)
    {  
        Map<String, opportunity> mapOfOpp = new Map<String, opportunity>();        
        if (system.label.TIS_Trigger_For_Lead_And_Opp == 'true')
        {
            for (Opportunity opp:lstNewTrigger)
            {
                if (opp.ownerId != mapOldTrigger.get(opp.id).ownerId)
                {
                    mapOfOpp.put(opp.id,opp);    
                }        
            }
            if (!mapOfOpp.isEmpty() && CreateTISLeadAndOpp.isExecute == true)
            {
                CreateTISLeadAndOpp.UpdateTISRecords(mapOfOpp, mapOldTrigger);
                CreateTISLeadAndOpp.isExecute=false;
            }
        }
    }
    
    /*//Sripathi Gullapalli, Method to update the Quote "Start Date" when the Opportunity "Close Date" is changed.
    public static void oppEndDateUpdate(List<Opportunity> newOppList, Map<Id, Opportunity> oldOppMap){
        Set<Id> oppIds = new Set<Id>();
        for (Opportunity newOpp : newOppList) 
        {
            Opportunity oldOpp = oldOppMap.get(newOpp.Id);           
            if (oldOpp.CloseDate != newOpp.CloseDate && newOpp.CloseDate != null) 
            {
                oppIds.add(newOpp.Id);
            }
        }
        
        if (oppIds.size() > 0){
            Map<Id, SBQQ__Quote__c> quoteMap = new Map<Id, SBQQ__Quote__c>();
            for (Opportunity opp : [select Id, closeDate, (select Id,SBQQ__StartDate__c from SBQQ__Quotes2__r) from Opportunity where Id in :oppIds]){
                if (opp.SBQQ__Quotes2__r != null && opp.SBQQ__Quotes2__r.size() > 0){
                    for (SBQQ__Quote__c quote  : opp.SBQQ__Quotes2__r){
                        if (opp.closeDate != quote.SBQQ__StartDate__c){
                            quote.SBQQ__StartDate__c = opp.closeDate;
                            quoteMap.put(quote.Id, quote);
                        }
                    }
                }
            }
            
            if (quoteMap.size() > 0){
                update quoteMap.values();
            }
        }
    }*/
    
    public static void updatePriceBookForSBQuote(List<Opportunity> newOppList, Map<Id, Opportunity> oldOppMap){
        Set<Id> accountIds = new Set<Id>();
        List<Opportunity> updateOppList = new List<Opportunity>();
        Boolean isInsert = (oldOppMap == null);
        Set<Id> userIdSet = new Set<Id>();
        
        for (Opportunity newOpp : newOppList) 
        {
            userIdSet.add(newOpp.OwnerId);
        }
        
        Map<Id, User> userMap = new Map<Id, User>([select Id, isPortalEnabled,UserRole.Name, Profile.Name from user where id IN :userIdSet]);
       
       
        for (Opportunity newOpp : newOppList) 
        {
            if ((!isInsert && (newOpp.OwnerId != oldOppMap.get(newOpp.Id).OwnerId) && userMap.get(newOpp.OwnerId).isPortalEnabled) || isInsert){
                accountIds.add(newOpp.AccountId);
                updateOppList.add(newOpp);
            }
        }
        
        if (accountIds.size() > 0){
            Map<Id, Account> accountMap = new Map<Id, Account>([select Id, Roadnet_Market__c from Account where Id in :accountIds]);
            Map<String, PriceBook2> priceBookMap = new Map<String, PriceBook2>();
            
            /*String profileName;
            if (String.isNotBlank(UserInfo.getProfileId())){
                profileName = ([select Id, name from profile where Id = :UserInfo.getProfileId()]).name;
            }
            
            String roleName;
            if (String.isNotBlank(UserInfo.getUserRoleId())){
                list<UserRole> uRole = [Select Name, Id From UserRole where Id=:UserInfo.getUserRoleId()];
                if (uRole != null && uRole.size()>0){
                    roleName = uRole.get(0).Name;
                }
            }*/
            
            
            for (PriceBook2 priceBook : [select Id,Name from PriceBook2 where IsActive = true]){
                priceBookMap.put(priceBook.Name, priceBook);
            }
            String priceBookName = 'Domestic PriceBook';
            String profileName;
            String roleName;
            for (Opportunity opp : updateOppList){
                Account accnt = accountMap.get(opp.AccountId);
                User oUser = userMap.get(opp.OwnerId);
                
                if (accnt != null){
                    priceBookName = 'Domestic PriceBook';
                    if (oUser != null){
                        profileName = oUser.Profile.Name;
                        roleName = oUser.UserRole.Name;
                    }
                    System.debug('*************** priceBookName0 -- '+accnt.Roadnet_Market__c +' - '+profileName+' - '+roleName);
                    if (accnt.Roadnet_Market__c == 'Developed'){
                        priceBookName = 'Developed Price Book';
                    }
                    else if (accnt.Roadnet_Market__c == 'Emerging'){
                        priceBookName = 'Emerging Price Book';
                    }
                    else if (accnt.Roadnet_Market__c == 'Domestic' && String.isNotBlank(profileName) && profileName == 'QES Reseller Partner Profile (No MDF)'){
                        if (String.isNotBlank(roleName)){
                            if (roleName == 'PANA Account Partner User' || roleName == 'PANA Account Manager User' || roleName == 'PANA Account Executive User'){
                                priceBookName = 'PANA Price Book';
                            }
                            else if (roleName != 'PANA Account Partner User' && roleName != 'PANA Account Manager User' && roleName != 'PANA Account Executive User'){
                                priceBookName = 'OD VAR Price Book';
                            }
                        }
                    }
                    System.debug('*************** priceBookName -- '+priceBookName);
                    PriceBook2 pBook = priceBookMap.get(priceBookName);
                    if (pBook != null){
                    System.debug('*************** priceBookName1 -- '+priceBookName);
                       opp.Pricebook2Id = pBook.Id;
                        //opp.SBQQ__QuotePricebookId__c = pBook.Id;
                    }
                }
            }
        }
    }
    
    //Sripathi Gullapalli, update Negotiation Type for mexico Renewal Opportunities
    public static void updateNegotiationType(List<Opportunity> newOppList){
        Set<Id> accountIds = new Set<Id>();
        Set<Id> contractIds = new Set<Id>();
        List<Opportunity> updateOppList = new List<Opportunity>();
        System.debug('******************UPDATE Negotiation Type');
        for (Opportunity newOpp : newOppList) 
        {
            if (String.isBlank(newOpp.negotiation_type__c) && String.isNotBlank(newOpp.SBQQ__RenewedContract__c)){
                accountIds.add(newOpp.AccountId);
                contractIds.add(newOpp.SBQQ__RenewedContract__c);
                updateOppList.add(newOpp);
            }
        }
        
        if (accountIds.size() > 0 && contractIds.size() > 0 && updateOppList.size() > 0){
            Map<Id, Account> accountMap = new Map<Id, Account>([select Id, Primary_Business_Unit__c from Account where Id in :accountIds]);
            Map<Id, Contract> contractMap = new Map<Id, Contract>([select Id, SBQQ__Quote__c,SBQQ__Quote__r.SBQQ__Opportunity2__c,SBQQ__Quote__r.SBQQ__Opportunity2__r.negotiation_type__c 
                                                                    from Contract where Id in :contractIds and SBQQ__Quote__c != null]);
            if (accountMap!= null && accountMap.size() > 0 && contractMap != null && contractMap.size() > 0){
                for (Opportunity opp : updateOppList){
                    Account accnt = accountMap.get(opp.AccountId);
                    if (accnt != null && accnt.Primary_Business_Unit__c == 'Omnitracs Mexico'){
                        Contract rCntrct = contractMap.get(opp.SBQQ__RenewedContract__c);
                        if (rCntrct != null && rCntrct.SBQQ__Quote__c != null && rCntrct.SBQQ__Quote__r.SBQQ__Opportunity2__c != null && 
                                                                                rCntrct.SBQQ__Quote__r.SBQQ__Opportunity2__r.negotiation_type__c != null){
                            opp.negotiation_type__c = rCntrct.SBQQ__Quote__r.SBQQ__Opportunity2__r.negotiation_type__c;
                        }
                    }
                }
            }
        }
    }
    
    @InvocableMethod
    public static void revertStageReversal(List<id> lstOpptyIds){
        List<Opportunity> lstOppts = new List<Opportunity>();
        lstOppts = [select id,StageName,Stage_Before_Reversal__c from Opportunity where Stage_Reversal_Approval_Status__c = 'Rejected' and Id IN :lstOpptyIds limit 1000 ];
        
        for (Opportunity oppty: lstOppts){
            oppty.StageName = oppty.Stage_Before_Reversal__c;
        }
        
        try{
            update lstOppts;
        }Catch(Exception e){
            System.debug('Exception in revertStageReversal method, OpportunityUtils: '+ e.getMessage());
        }       
    }
        
    public class myException extends Exception{}

    /***************************
    Roesler - added 6/3/2017
    
    The problem we're trying to solve: With Steelbrick, migrations and contract renewals have to be split into multiple opportunities; each 
    decommission has to be done by amending an individual SB Contract, and this has to be done in a unique opportunity. In order to have a
    complete financial view of the entire deal/transaction, we need to roll the financials from all the decommissions up to the parent. 
    This method, invoked from an Opportunity update or delete trigger,
    1. identifies all the parent opportunities that would be affected
    2. identifies all the children (decommission) opportunities that belong to those parents
    3. recomputes the net financials by rolling the related financial field up from the children to the parent
    
    We're assuming that the list of opportunities passed in are all potential decommissions. We'll check them all to see if they have parents. 
    If they do, then we need to do some work. If they don't have parents, then we're done.
    ********************************************************************************************************************/
  
    public static void rollupDecommissionFinancials(List<Opportunity> decommissionOpps) {
        
        // parentId is the set of unique parent opportunity IDs that are associated with the list of decommission opportunities
        Set<Id> parentId = new Set<Id>();
        
        for (Opportunity d: decommissionOpps){
            if (String.isNotBlank(d.related_parent_opportunity__c)) {
               parentId.add(d.related_parent_opportunity__c);
            }
        }
        
        if (parentId.size() > 0) {
            // parentMap is a map of the parent opp IDs to the corresponding Opportunity object
            Map<Id,Opportunity> parentMap = new Map<Id,Opportunity>([SELECT id,
                                                                            related_service_plan_quantity__c,
                                                                            related_Legacy_service_plans_quantity__c,
                                                                     		related_ARR__c,
                                                                            related_TCV__c,
                                                                            related_TCV_Maintenance__c,
                                                                            related_TCV_Maps__c,
                                                                            related_TCV_Hardware__c,
                                                                            related_TCV_ProServe__c,
                                                                            related_TCV_SaaS__c,
                                                                         // related_TCV_Software_License__c,
                                                                         // related_TCV_Subscription__c,
                                                                         // related_TCV_Term__c,
                                                                            related_Forecast_TCV__c,
                                                                            related_Gross_Margin__c 
                                                                     FROM Opportunity 
                                                                     WHERE id in :parentId]);
            
            // re-initialize the related opportunity financial net quantities on the parent
            for (Opportunity p: parentMap.values()) {
                p.related_service_plan_quantity__c = 0;
                p.related_Legacy_service_plans_quantity__c = 0;
                p.related_ARR__c = 0;
                p.related_TCV__c=0;
                p.related_TCV_Maintenance__c=0;
                p.related_TCV_Maps__c=0;
                p.related_TCV_Hardware__c=0;
                p.related_TCV_ProServe__c=0;
                p.related_TCV_SaaS__c=0;
            //  p.related_TCV_Software_License__c=0;
            //  p.related_TCV_Subscription__c=0;
            //  p.related_TCV_Term__c=0;
                p.related_Forecast_TCV__c=0;
                p.related_Gross_Margin__c=0;
            }
            
           
            // reconstruct the net financials by summing up all the related (decommission) opp financials
            for (Opportunity d: [SELECT id,
                                        related_parent_opportunity__c,
                                        service_plan_quantity__c,
                                 		this_opp_legacy_service_plans__c,
                                        ARR__c,
                                        TCV__c,
                                        TCV_Maintenance__c,
                                        TCV_Maps__c,
                                        TCV_Hardware__c,
                                        TCV_ProServe__c,
                                     // TCV_SaaS__c,
                                        TCV_Software_License__c,
                                     // TCV_Subscription__c,
                                     // TCV_Term__c,
                                        /* ARMAN: Forecast_TCV__c, */
                                        Gross_Margin__c 
                                 FROM Opportunity 
                                 WHERE related_parent_opportunity__c in :parentId]) {
                                 
                parentMap.get(d.related_parent_opportunity__c).related_service_plan_quantity__c += d.service_plan_quantity__c;
                parentMap.get(d.related_parent_opportunity__c).related_Legacy_service_plans_quantity__c += d.this_opp_legacy_service_plans__c;                     
                parentMap.get(d.related_parent_opportunity__c).related_ARR__c += d.ARR__c;
                parentMap.get(d.related_parent_opportunity__c).related_TCV__c += d.TCV__c;
                parentMap.get(d.related_parent_opportunity__c).related_TCV_Maintenance__c += d.TCV_Maintenance__c;
                parentMap.get(d.related_parent_opportunity__c).related_TCV_Maps__c += d.TCV_Maps__c;
                parentMap.get(d.related_parent_opportunity__c).related_TCV_Hardware__c += d.TCV_Hardware__c;
                parentMap.get(d.related_parent_opportunity__c).related_TCV_ProServe__c += d.TCV_ProServe__c;
             // parentMap.get(d.related_parent_opportunity__c).related_TCV_SaaS__c += d.TCV_Saas__c;
             // parentMap.get(d.related_parent_opportunity__c).related_TCV_Software_License__c += d.TCV_Software_License__c;
             // parentMap.get(d.related_parent_opportunity__c).related_TCV_Subscription__c += d.TCV_Subscription__c;
             // parentMap.get(d.related_parent_opportunity__c).related_TCV_Term__c += d.TCV_Term__c;
                // ARMAN: parentMap.get(d.related_parent_opportunity__c).related_Forecast_TCV__c += d.Forecast_TCV__c;
                parentMap.get(d.related_parent_opportunity__c).related_Gross_Margin__c += d.Gross_Margin__c;
            }
            update parentMap.values();
        }
    }
}