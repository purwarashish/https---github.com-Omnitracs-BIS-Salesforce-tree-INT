/*******************************************************************************
 * File:  OpportunityTriggerRoadnet.Trigger
 * Date:  Ocotober 28, 2014
 * Author:  Joseph Hutchins
 * Sandbox: Mibos
 * The use, disclosure, reproduction, modification, transfer, or transmittal of
 * this work for any purpose in any form or by any means without the written 
 * permission of United Parcel Service is strictly prohibited.
 *
 * Confidential, unpublished property of United Parcel Service.
 * Use and distribution limited solely to authorized personnel.
 *
 * Copyright 2009, UPS Logistics Technologies, Inc.  All rights reserved.
 *  Purpose:  This is a semi clone of the OpporutnityTrigger that exists in Roadnet,
 *  I had to create a different triger as there already exists a trigger in the Mibos called OpportunityTrigger.
 *  *******************************************************************************/
trigger OpportunityTriggerRoadnet on Opportunity (before insert, after insert, before update, after delete)
{
/*  all logic moved to the opportunityall trigger
     BypassTriggerUtility u = new BypassTriggerUtility();  
     if (u.isTriggerBypassed()) {
         return;
    }
         
    if ( MigrationUser.isMigrationUser())
    {
        //  migruatin user can bypass trigger for import if and only if their manage locked opportunites is true.  this is to allow
        //  mass updates by me, jane, or amy but to prevent someone else who has access to muser to inadverdently upload
        return ;
    }

    private final string OPPT_CLONE_FIELD_ERROR = 'This field needs to be blank if cloning an opportunity';
    
    Opportunity[] oppts = Trigger.new;
    Opportunity[] oldOppts = Trigger.old;
    List<Opportunity> opptsToCheckForBuyingGroup = new List<Opportunity>();
    List<Opportunity> opptsToPopulateBuyingGroupFields = new List<Opportunity>();
    OpportunityStage[] allOpptStages;
    
    private List<RecordType> m_opptRecordTypes;
    private List<RecordType> opptRecordTypes
    {
        get
        {
            if (m_opptRecordTypes == null)
            {
                m_opptRecordTypes = [select id, name from Recordtype where sobjecttype = 'Opportunity'];
            }
            return m_opptRecordTypes;
        }
    }
    private List<Country_And_Country_Code__c> m_allCountries;
    private List<Country_And_Country_Code__c> allCountries
    {
        get
        {
            if (m_allCountries == null)
            {
                m_allCountries = [select name, ISO_Code_2__c, Region__c from Country_And_Country_Code__c];
            }       
            return m_allCountries;
        }
    }

        
    private List<Product2> allActiveMajorProducts
    {
        get
        {
            if (allActiveMajorProducts == null)
            {
                allActiveMajorProducts = [select id, name, description, Product_Identifier__c from Product2 where isActive = true and Is_Major_Product__c  = true ];
            }
            return allActiveMajorProducts;          
        }
    }
    

    private static boolean isSystemAdmin
    {
        get
        {
            string profileName = [select id, name from Profile where id =: userinfo.getProfileId()].name;
            return profileName == 'System Administrator';
        }
    }
    private static boolean isUserSalesSysAdmin
    {
        get
        {
            string profileName = [select id, name from Profile where id =: userinfo.getProfileId()].name;
            return profileName == 'Sales - Sys Admin' || profileName == 'Sales - VP Sales' || profileName == 'System Administrator';
        }
    }
    
    //if (CheckRecursive.runOnce())
    {
        util.debug('OpportunityTriggerRoadnet called');
        //  this need to be in a for loop
        if (Trigger.isBefore && Trigger.isInsert)//  before insert
        {
            //  this prevent an oppts stage name from boing to negoitate or a lost stage if a primary contact role is not assigned
            checkForPrimaryContactRolesIfStageNegotiateLost(null, Trigger.New, Trigger.isInsert);
            assignSalesTeamManagerAndDarManager(Trigger.new);
            
            for (integer i = 0; i < oppts.size(); i++)
            {
                //  method handles both updates and inserts
                //  placing in a try becuase alot cna go wrong in the method and dont want to stop oppt processing from continuing
                try
                {
                    assignGeoRegionAndOpptCountryIfNeeded(oppts[i], allCountries);
                }
                catch(Exception e)
                {
                    //  i can remove this evenutally, but if it fails, i need to know why to fix it in the future
                    EmailClassRoadnet.sendErrorEmail('Failed to assign oppt geo region due to ' + e.getMessage(), oppts[i].id);
                }
              
                if (oppts[i].Lead_Origin__c != null)
                {
                    // commented out as the logic was not asked to be in the mibos enviormnet  populateSalesRefferalFields(oppts[i]);
                }

                //  check if the opportunities accounts value chain is a buying group account
                if (oppts[i].accountId != null)
                {
                  opptsToCheckForBuyingGroup.add(oppts[i]);
                }
                //  check that if the user is cloning an oppt, the Terms_Requested_Status__c field is blank, we dont want it to clone over
                if (oppts[i].Terms_Requested_Status__c != null)
                {
                    oppts[i].Terms_Requested_Status__c.addError(OPPT_CLONE_FIELD_ERROR);
                }
                if (oppts[i].Terms_Requested__c)
                {
                    oppts[i].Terms_Requested__c.addError(OPPT_CLONE_FIELD_ERROR);
                }
                
                //  jane has asked on 3/6/2014 in regards to sf issue: https://na1.salesforce.com/a0W3000001H34kX 
                //  could be cleared out for new/cloned opts
                if (oppts[i].Se_Approval__c == true)// checkbox field so it should false if cloning
                {
                    oppts[i].Se_Approval__c = false;    
                }
                if (oppts[i].current_se__c != null)
                {
                    oppts[i].current_se__c = null;
                }
          
                if (oppts[i].Solution__c != null)
                {
                    oppts[i].Major_Products__c = parseOpportunitySolutions(oppts[i].Solution__c);
                }
                
            }
            if (opptsToCheckForBuyingGroup.size() > 0)
            {
                //checkForBuyingGroup(opptsToCheckForBuyingGroup);
            }
            
            if (opptsToPopulateBuyingGroupFields.size() > 0)
            {
                //populateBuyingGroupFields(opptsToPopulateBuyingGroupFields);
            }
        }       
        //  this needs to be in a for loop    
        if (Trigger.isBefore && Trigger.isUpdate)//  before update
        {
            //  this prevent an oppts stage name from boing to negoitate or a lost stage if a primary contact role is not assigned
            checkForPrimaryContactRolesIfStageNegotiateLost(oldOppts, Trigger.New, Trigger.isInsert);
            assignSalesTeamManagerAndDarManager(Trigger.new);
            
            for (integer i = 0; i < oppts.size(); i++)
            {
                
                
                try
                {
                    assignGeoRegionAndOpptCountryIfNeeded(oppts[i], allCountries);
                }
                catch(Exception e)
                {
                    //  i can remove this evenutally, but if it fails, i need to know why to fix it in the future
                    EmailClassRoadnet.sendErrorEmail('Failed to assign oppt geo region due to ' + e.getMessage(), oppts[i].id);
                }
                
                //  here we can check if the stage name has changed and if so, ding the user that they cant change it
                if (oppts[i].stagename != null &&
                    oldOppts[i].StageName != oppts[i].STageName && oppts[i].Stagename == 'Closed - Won')
                {
                    //  check if the user is allowed to set the field
                  
                    //  if the oppt contains Project Change in its title, its a Project Change oppt and we want to set the dp to p date 
                    //  sf issue for info located here https://na1.salesforce.com/a0W3000000DtWAk
                    if (oppts[i].Name != null && oppts[i].Name.contains('Project Change') && oppts[i].deposit_pending_to_pending_date__c == null)
                    {
                        oppts[i].Deposit_Pending_To_Pending_Date__c = date.today();
                    }
                }
                
                //  sets the sales referal field if the  lead origin field changes
                if (oldOppts[i].Lead_Origin__c != oppts[i].Lead_Origin__c)
                {
                    //  we only want to populate the sales referral fields if the opportunity is unlocked.   the reason
                    //  is becuase the sales reffereal fields cannot be changed once the oppt is locked
                    if (!oppts[i].Record_Locked_By_UPSLT__c)
                    {
                        //populateSalesRefferalFields(oppts[i]);
                    }
                }

                //  check if the opportunities accounts value chain is a buying group account           
                if (oppts[i].accountId != null)
                {
                  opptsToCheckForBuyingGroup.add(oppts[i]);
                }
                
                //  so when the buying group paid to field changes, we need to query the account it points to
                //  grab the % of softaew and flat fee and assign it to the oppt.            
                if (oldOppts[i].Buying_Group_Rebate_paid_to__c != oppts[i].Buying_Group_Rebate_paid_to__c)
                {
                    if (oppts[i].Buying_Group_Rebate_paid_to__c != null)
                    {
                        //  add the oppt to a list of oppts to query for their buying group accounts
                        //opptsToPopulateBuyingGroupFields.add(oppts[i]);
                    }
                }
                
                // found oppts where field is no populated but can find no reason why not, so having this update each time the oppt is edtied regardles if the field has changed 
                //if (oldOppts[i].Solution__c != oppts[i].solution__c)
                {
                    oppts[i].Major_Products__c = parseOpportunitySolutions(oppts[i].solution__c);
                }
            }
            if (opptsToCheckForBuyingGroup.size() > 0)
            {
                //checkForBuyingGroup(opptsToCheckForBuyingGroup);
            }
            
            if (opptsToPopulateBuyingGroupFields.size() > 0)
            {
                //populateBuyingGroupFields(opptsToPopulateBuyingGroupFields);
            }
        
        }
            
        if (Trigger.isInsert && Trigger.isAfter)// after insert
        {
         
            //updateAccountOpenOpptsCount(Trigger.new, false);//  do we need differnet methods for insert and delete?
            createPrimaryContactRole(Trigger.new );
        }
        
        if (Trigger.isDelete && Trigger.isAfter)
        {
            //  since we are in the delete after, there is no trigger.new
            //updateAccountOpenOpptsCount(Trigger.old, true);//  do we need differnet methods for insert and delete?
        }    

    }
   
   
    private decimal nullToZero(decimal d)
    {
        if (d == null)
        {
            return 0;
        }   
        else
        {
            return d;
        }
    }
    
    private void assignGeoRegionAndOpptCountryIfNeeded(Opportunity theOppt, List<Country_And_Country_Code__c> countryRecords)
    {
        //  alright here is my hestaion with using this, the oppt does have a country field but when i check all of the oppts
        //  the country is not set on 2000+, so im wondering if i could use the oppt coutnry field first
        //   and if it si blank, lookup the account and get the shipping coutnry from there
        if (theOppt.Opporunity_Country__c != null)
        {
            //  be advised that the country picklist is MULTI-SELECT, meaning it can have many countries selected
            //  because of this, the findCountryCodeUsingCountryName will do a contains so that it matches on the first country
            // it can find
            Country_And_Country_Code__c tempCCC = findCountryCodeUsingCountryName(theOppt.Opporunity_Country__c, countryREcords);
            if (tempCCC != null)
            {
              theOppt.Hidden_Opportunity_Region__c = tempCCC.REgion__c;
            }
        }
        else
        {
            //  so if the oppt country was blank, we'll blank out the region also
            {
                theOppt.Hidden_Opportunity_Region__c = null;
            }
        }
        
    }
    public static Country_And_Country_Code__c findCountryCodeUsingCountryName(string countryName, List<Country_And_Country_Code__c> countryREcords)
    {
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
    private void checkLostStageRequiredFields(Opportunity oppt)
    {
       
        //  logic changed somewhat... if both fields are blank, we want to inform user has to choose one
        if (Util.isBlank(oppt.Loss_Bus_Reason__c) && Util.isBlank(oppt.Loss_Funct_Gap_s__c))
        {
            if (Util.isBlank(oppt.Loss_Bus_Reason__c))
            {
                oppt.Loss_Bus_Reason__c.AddError('Loss- Business Reason(s) OR Loss - Functionality Gap(s) must to be set if stage is Lost');
            }
            if (Util.isBlank(oppt.Loss_Funct_Gap_s__c))
            {
                oppt.Loss_Funct_Gap_s__c.AddError('Loss- Business Reason(s) OR Loss - Functionality Gap(s) must to be set if stage is Lost');
            }
        }
         
    }
    
    private boolean isOpptDomesticServices(Id recordtypeId)
    {
        //  scroll thru each rec type, see if its a dom services
        for (Recordtype rt : opptRecordTypes)
        {
            if (rt.Name == 'Dom. Consulting Days' || 
              rt.Name == 'Dom. Consulting Days (Split)' ||
              rt.Name == 'Dom. Special Projects' ||
              rt.Name == 'Dom. Projects' ||
              rt.Name == 'Dom. RN University')
              {
                  if (rt.id == recordTypeid)
                  {
                    return true;
                  }
              }
        }
        return false;
    }
    
    private boolean isOpptProfServ(id recordtypeid)
    {
        for (Recordtype rt : opptRecordTypes)
        {
            if (rt.Name == 'Dom. Consulting Days' ||
              rt.Name == 'Dom. RN University' ||
              rt.Name == 'Dom. Special Projects' ||
              rt.Name == 'Intl. Consulting Days' ||
              rt.Name == 'Intl. Special Projects')
              {
                if (rt.id == recordtypeid)
                {
                    return true;
                }
              }
        }
        return false;
    }
    private boolean isStageNonZeroProb(string stageName)
    {
        if (allOpptStages == null)
        {
            allOpptStages = [select id,MasterLabel, DefaultProbability, iswon, isclosed from OpportunityStage where isactive = true];
        }
        
        for (OpportunityStage os : allOpptStages)
        {
            if (os.masterLabel == stageName)
            {
                return (os.DefaultProbability > 0);
            }
        }
        return false;
    }
   
    private string parseOpportunitySolutions(string opptSolution)
    {
        if (util.isblank(opptSolution))
        {
            return '';
        }
        //  parse out the products in the oppt's solution field
        List<string> productsParsed = parseString(opptSolution);
        
        List<Product2> tempProductList = allActiveMajorProducts;
        
                
        //  the oppt's solution field was parsed, but now we need to get the true name of the product using the major product list
        //  this will grab the true product name and will check if its a major product and if so it gets added
        List<string> productsParsedWithTrueNames = new List<string>();
        for (integer i = 0; i< productsParsed.size(); i++)
        {
            string trueNameOfProduct = findTrueNameOfProduct(productsParsed[i], tempProductList);
            if (trueNameOfProduct != null)
            {
                productsParsedWithTrueNames.Add(trueNameOfProduct); 
            }
        }
        //  the method above has gone thru and replaced all of the seelected oppt products with the product names
        //  but the products are still not parsed.... for example this product here after its true name has been found is stilll made up of 
        //  several prodcuts: https://na1.salesforce.com/01t30000001x9kU, it has name MC Server, TP but product descrtipon of TP, MC Server Bundle
        //  when you parse that out you are going to get MC Server; TP, but nothing else so once we get the true name of the products
        //  we'll need to parse out THAT list of products even furhter
        List<string> majorProductsOfOpptCompletelyParsed = furtherParseOpptProducts(productsParsedWithTrueNames);
         
        //  per request from shannon, remove dupe items in the list
        removeDupeProducts(majorProductsOfOpptCompletelyParsed);
        //  per request from shannon have these sort by alphabetically order
        sortProductsByName(majorProductsOfOpptCompletelyParsed);
        
        string opptMajorProducts = '';
        
        for (integer i = 0; i < majorProductsOfOpptCompletelyParsed.size(); i++)
        {
            //  see if the solution product is an active product, and major product and if so this will return the product.name field
            if (opptMajorProducts.length() == 0)//  first item in the list, no need to prepend with semicolon
            {
                opptMajorProducts += majorProductsOfOpptCompletelyParsed[i];
            }
            else//  at least one product name has already been added to the list, prepend with semicolon for seperation
            {
                opptMajorProducts += '; ' + majorProductsOfOpptCompletelyParsed[i];
            }
        }
        return opptMajorProducts;
    
    }
    public static string[] parseString(string str)
    {
        string[] theStrings=new list<string>();
        if (str==null){}
        else
        {   
            theStrings=(str.split(';', 0));
            //lets make sure there isn't blank items in the list and try to clear in any leading trailign whitespaces
            for (integer i=0; i<theStrings.size();i++)
            {
                theStrings[i]=theStrings[i].trim();
                if (theStrings[i]=='') theStrings.remove(i);
            }
        }
        return theStrings;
    }
    private list<string> furtherParseOpptProducts(List<string> products)
    {
        //  the idea of this method is parse out a list of products
        //  for example if the list has 1.  RN; MC Server and 2. MC Server, the final list returned should be "RN; MC Server; MC Server"
        list<string> productListToReturn = new List<string>();
        for (string singleProduct : products)
        {
            list<string> singleProductEntryParse = parseString(singleProduct);  
            productListToReturn.AddAll(singleProductEntryParse);
        }
        return productListToReturn;
    }
    
    
   private void  removeDupeProducts(List<string> products)
    {
        //  go thru the list, if a dupe is found remove it from the list
        for (integer i = 0; i < products.size(); i++)
        {
            for (integer j = 0; j < products.size(); j++)
            {
                if ( i != j)
                {
                    if (products[i] == products[j])
                    {
                        products.Remove(j);
                        j--;
                    }
                }
            }
        }
    }

    private void sortProductsByName(List<string> productsToSort)
    {
        //  going to use traditional bubble sort
        for (integer i = 0; i < productsToSort.size() - 1; i++)
        for (integer j = 0; j < productsToSort.size() - 1; j++)
        {
            
            //  compare 0 with 1, if its lower, swap positions
            if (productsToSort[j] > productsToSort[j + 1])//  the item is lesser
            {
                string tempProduct = productsToSort[j];
                productsToSort[j] = productsToSort[j + 1];
                productsToSort[j + 1] = tempProduct;
            }
        }   
    }

    private string findTrueNameOfProduct(string opptProductName, List<Product2> activeMajorProducts)
    {
        //  there are some opportunties where the name of the selected product is not the product's description, so this will now
        //  check the products name and descrioption (it'll first check the description)
        
        //  be advised for sf issue: 0003836, i noticed the account batch updater which updates the account's Major Products field is using the
        // product Identfier field instead of the name, to keep it consistent, this will also use the product indentifier field
        for (Product2 singleProduct : activeMajorProducts)
        {
            if (opptProductName == singleProduct.description)
            {
                return singleProduct.Product_Identifier__c;
            }
            else if (opptProductName == singleProduct.Name)
            {
                return singleProduct.Product_Identifier__c;
            }
            
        }
        return null;
    }
    
    private void checkForPrimaryContactRolesIfStageNegotiateLost(List<Opportunity> olderOppts, List<Opportunity> newoppts, boolean isTriggerInsert)
    {
        //  im wondering if this should fire each time the stage name is negoatie or lost or only when it gets chaned to that
        //  there is a small possbility that for example we have a sales rep that creates the oppt and has a primary contact created
        //  when he changed the stage to negotiate/lost.  then lets say sryi comes along and marks the primary contact as not primary.... 
        //  i think it's best for this to occur only when the stage changes.... to much complexitiy as it is
        
        //  ****update after shannons testing and her remarks, i think it is best this firees each time the stage is neogiate or lost
        //  with that said, we dont need the older oppts any longer, but i'll the method signature the way it is just in case shannon says
        //  this should fire only when the stage name changes.
        
        //  firslty i want this method to be used on insert and update
        //  so if the olderOppts list is null, we know its insert
        List<Opportunity> opptsToCheck = new List<Opportunity>();
        
        //  need to mass query the oppts accounts so we can check the country fields to see if the oppt is domestic or not
        List<Account> accountsOfOppts = retrieveAccountOppts(newOppts);
        List<Case> upgradeCasesOfOppts = retrieveUpgradeCases(newOppts);
        
        for (Opportunity o : newOppts)
        {
            boolean isUpgradeOppt = isUpgradeOppt(o, upgradeCasesOfOppts);
            util.debug('isUpgradeOppt = ' + isUpgradeOppt);
            
            Account accountOfOppt = findAccountInList(o.AccountId, accountsOfOppts);
            if (
                isUpgradeOppt || //  upgrade oppts should always get their contact role checked and created
                ( isOpptDomestic(accountOfOppt) &&
                    ( ( isTriggerInsert || isOpptRoadnetBusinessUnit(accountOfOppt)) ) 
                )//  oppt is domestic AND oppt is being inserted OR oppt is roadnet oppt (update on roadnet oppts should require)
                //isStageNegotiateOrLost(o.StageName) && 
                ) 
            {
                opptsToCheck.add(o);
            }
        }
        if (opptsToCheck != null && opptsTocheck.size() > 0)
        {
            //  so whats the most efficeint way to do this??  
            //  mass query all contact roles that point to the oppts
            //  then check if any are set to primary, if not, add error on that oppt
            OpportunityContactRole[] contactRoles = [Select o.Role, o.OpportunityId, o.IsPrimary, o.Id, o.CreatedDate, o.CreatedById, o.ContactId 
               From OpportunityContactRole o where OpportunityId in: opptsTocheck];
            //  scroll thru each opporutnity, pull out the contact roles that point to it, see if any primary 
            for (Opportunity o : opptsToCheck)
            {
                if (!isAnyContactRolePrimary(o.id, contactRoles))
                {
                    if ( o.Primary_Contact__c == null)
                    {
                        o.Primary_Contact__c.AddError('You must specify a primary contact role for this opportunity.');
                    }
                    if (util.isBlank(o.Role__c))
                    {
                        o.Role__c.AddError('You must specify a role');
                    }
                }   
            
            }
        }
    }
    private static boolean isUpgradeOppt(Opportunity theOppt, LIst<case> upgradeCasesOfOppt)
    {
        //util.debug('inside of isUpgardeOppt.  theOppt.Case__c = ' + theOppt.Case__c + ' num of upgrade cases passed in: ' + upgradeCasesOfOppt.size());
        
        if (upgradeCasesOfOppt == null || upgradeCasesOfOppt.size() == 0)
        {
            return false;
        }
        else
        {
            //  so the idea here is that if any oppts have a case poiting to it whose "case is being upgraded" bool is set,
            //  then we need to make sure the primary contact role and role are set. so this will loop thru the cases that point
            //  to the oppts in the trigger
            for (Case c : upgradeCasesOfOppt)
            {
                if (theOppt.Case__c == c.id && c.Is_Case_Being_Upgraded__c)//  the oppt points to an upgrade case
                {
                    return true;
                }
                
            }
            return false;
        }
    }
    private static List<Case> retrieveUpgradeCases(LIst<Opportunity> theoppts)
    {
        Set<id> caseIds = new Set<id>();
        for (Opportunity o : theOppts)
        {
            if (o.Case__c != null &&
              !caseIds.contains(o.case__c))
            {
                caseIds.add(o.case__c);
            }
        }
        if (caseIds.size() > 0)
        {
            return [select id, Is_Case_Being_Upgraded__c from Case where id in: caseIds and Is_Case_Being_Upgraded__c = true];
        }
        return new List<Case>();
    }
    private static List<Account> retrieveAccountOppts(List<Opportunity> opts)
    {
        Set<Id> accountIds = new Set<Id>();
        for (Opportunity oppt : opts)
        {
            if (oppt.AccountId != null)
            {
                if (!accountIds.Contains(oppt.AccountId))
                {
                    accountIds.add(oppt.AccountId);
                }
            }
        }
        if (accountIds.size() > 0)
        {
            return [select id, shippingcountry, billingCountry, primary_business_unit__c from Account where id in: accountIds ];
        }
        return new List<Account>();
    }
    
    private List<OpportunityStage> retrieveLostAndNegoitateStages()
    {
        if (allOpptStages == null)
        {
            allOpptStages = [select id,MasterLabel, DefaultProbability, isClosed, isWon from OpportunityStage where isactive = true];
        }
        List<OpportunityStage> stagesToReturn = new List<OpportunityStage>();
        for (OPportunityStage os : allOpptStages)
        {
            if (os.MasterLabel.Contains('Lost') ||
               os.MasterLabel.Contains('Negotiate') || 
               os.MasterLabel.Contains('Negotiation')) 
               
            {
                stagesToReturn.add(os);
            }
        }
        return stagesToReturn;
        
    }
    private boolean isOpptRoadnetBusinessUnit(Account theAccount)
    {
        return theAccount != null &&
            theAccount.Primary_Business_Unit__c != null &&
            theAccount.Primary_Business_Unit__c == 'Roadnet';
    }
    private boolean isStageNegotiateOrLost(string stageName)
    {
        if (util.isBlank(stageName))
        {
            return false;
        }
        else
        {
            List<OpportunityStage> lostAndNegotiateStages = retrieveLostAndNegoitateStages(); 
            
            for (OpportunityStage os : lostAndNegotiateStages)
            {
                if (stageName == os.MasterLabel)
                {
                  return true;  
                }
            }
            
            return false;
        }
    }
    private boolean isAnyContactRolePrimary(Id opptId, List<OpportunityContactRole> contactRoles)
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
    
    private static boolean isUserJoseph
    {
        get
        {
            return userInfo.getLastName() == 'Hutchins';
        }
    }

    private static Account findAccountInList(Id accountId, List<Account> accounts)
    {
        //system.assertNotEQuals(null, accountId);
        system.assertNotEquals(null, accounts);
        
        for (Account a : accounts)
        {
            if (a.id == accountId)
            {
                return a;
            }
        }
        
        return null;
    }
   
    private static void updateAccountOpenOpptsCount(List<Opportunity> opportunities, boolean isDelete)
    {
        //  this method will not work for deleting opportunities, we'll need a seperate but simialr method
        //  the lgoci basically remains the same except for  this line: 
        //  account.Num_Of_Open_Opportunities__c = (isStageOpen(oppt.stageName) ? 1 : 0) + openOppts.size();
        //  since the opportunity is being deleted, it should say num of open oppts = openOppts.size()
        //  now, i think we could still use this method, if that's the only change, we'll need to push a bool that says
        //  is delete
        
        util.debug('updateAccountOpenOpptsCount method called.  num of oppts passed into method = ' + opportunities.size());
        
        //  alright i think the deign here is wrong.... all oppprotunies are passed into this method regardless if the oppt is open stage or not
        //  even if an edit is never made to the oppt, we still need to query and update the oppt's number of open oppts.
        //  so right now this will only update teh account if the oppt stage anme is open but what if we edit the oppt and its no longer
        
        //  very simple logic here, if the oppt is one of the open stagenames, query all open opts that point to the account,
        for (Opportunity oppt : opportunities)
        {
            
            if (oppt.AccountId != null)
            {
                Account account = [select id, Num_Of_Open_Opportunities__c  from Account where id =: oppt.AccountId];
                
                //  get count of oppts that are open
                //  since this is called in the after trigger, the oppt in context stage name is already set so if we query it...
                Opportunity[] openOppts = [select id, name, stagename from Opportunity where accountid =: oppt.accountid and 
                        (StageName = 'SUSPECT' or StageName = 'NEGOTIATE' or StageName = 'QUALIFY' or StageName = 'DEVELOP' or StageName = 'PROVE')];
                
                util.debug('Finished querying open oppts.  Num returned ' + openOppts.size());
                for (Opportunity o : openOppts)
                {
                    util.debug('name = ' + o.name + ' id = ' + o.id + ' stagename = ' + o.stageName);
                }
                
                if (!isDelete)//  the oppt is being inserted updated, so include it in the count if the stage is open
                {
                    //  if the oppt in context is open, add it to the already count of open oppts
                    account.Num_Of_Open_Opportunities__c = openOppts.size();//(isStageOpen(oppt.stageName) ? 1 : 0) + openOppts.size();
                }
                else//  oppts is being deleted, only count the oppts queried up above
                {
                    account.Num_Of_Open_Opportunities__c = openOppts.size();
                }
                
                util.debug('account num of open oppts being assigned = ' + account.Num_Of_Open_Opportunities__c);               
                update account;                     
            }
        }   
    }
    private static boolean isOpptDomestic(Account accountOfOppt)
    {
        if (accountOfOppt == null)
        {
            return false;
        }
        else
        {
            util.debug('inside of isOpptDomestic, account of oppt = '  + accountOfOppt + ' billingcountry = ' + account.billingCountry + ' shippingcountry = ' + account.shippingcountry);
            
            string countryNameLowerCase;
            if (accountOfOPpt.ShippingCountry != null)
            {
                countryNameLowerCase = accountOfOppt.ShippingCountry.toLowerCase();
            }
            else if (accountOfOppt.BillingCountry != null)
            {
                countryNameLowerCase = accountOfOppt.BillingCountry.toLowerCase();
            }
            
            if (Util.isblank(countryNameLowerCase))
            {
                return false;
            }
            else
            {
                util.debug('countryNameLowerCase = ' + countryNameLowerCase);
                return countryNameLowerCase == 'united states'; //|| countryNameLowerCase == 'canada';// || countryNameLowerCase == 'mexico';
            }
        }
    }
    
    private static void createPrimaryContactRole(List<Opportunity> newOppts)
    {
        util.debug('createPrimaryContactRole has been called');
        
        //  the logic is as followed.  this should only get called one time for an opporutnity and never again
        //  we need to know if the user set a value in the primary contact lookup
        //  if not, the before trigger would catch that
        //  this should only process the oppt if the primary contact and the role are set on the opportuinty
        //  what we'll do is create the contact role for the opporunity, then... crap i cannot swipe out the contact role in the 
        //  after trigger.... i wanted to wipe the field but i think it is ok if the field continues to have a vlaue
        ///  what that menas is that this needs to be smart enough to only create the contact role
        //  if the primaryh contact role was not set and is being set (once this is in the live and been used for awhile
        //  every oppt wll have a value in primary contact even though it is used only to create the primary contact role here)
        
        List<Opportunity> opptsToCreatePrimaryContactRoles = new List<Opportunity>();
         
        //  need to mass query the oppts accounts so we can check the country fields to see if the oppt is domestic or not
        List<Account> accountsOfOppts = retrieveAccountOppts(newOppts);
        
        
        for (integer i = 0; i < newOppts.size(); i++)
        {
            boolean isPrimaryContactSet = !Util.isBlank(newOppts[i].Primary_Contact__c);
            boolean doesRoleContainValue = !Util.isBlank(newOppts[i].Role__c);
             
            //  so we want to see if we need to create a contact role if the primary contact was set and that the role has a value
            if (isPrimaryContactSet && 
                doesRoleContainValue)//  this used to filter on only domestic accuonts
            {
                opptsToCreatePrimaryContactRoles.Add(newOppts[i]);
            }
        }
        
        List<OpportunityContactRole> contactRolesToCreate = new List<OpportunityContactRole>();
        List<OpportunityContactRole> contactRolesToUpdate = new List<OpportunityContactRole>();
        if (opptsToCreatePrimaryContactRoles.size() > 0)
        {
            //  change of logic here due to this scnerio.  say for example my contact joe hutch was a contact role with role "unknown"
            //  now if a sales rep comes along and sets joe hutch as the primary contact on the oppt with role "End User"
            //  then the current code below breaks badly. 
            
            //  so we need a list of ALL contact roles regardless if they are primary or not
            OpportunityContactRole[] currentContactRolesOfOppts = 
               [select id, OpportunityId, ContactId, Role, isPrimary from OpportunityContactRole where OpportunityId in: opptsToCreatePrimaryContactRoles];
            
            for (Opportunity singleOppt : opptsToCreatePrimaryContactRoles)
            {
                //  so this needs to check two things actually, 1. does ANY primary contact role exist already for the oppt
                //  if so, do nothing.  WE DO NOT WANT THE Primary Contact field to be the way sales rep assign primary contact roles
                //  2. the second check is to see if the primary contact that is on the oppt, we need to see if any contact role exists
                //  for that user already... and if it does, we'll update that contact role with the values from the oppt
                if (doesPrimaryContactRoleExistAlready(singleOppt.id, currentContactRolesOfOppts ))
                {
                    //  now i'm wondering if the code should even show an error or if it should just ignore creating a contact role for that oppt?
                    //  past experience makes me lean towards to not creating it.... sales will be very upset if ANOTHER validtion rule prevents them from doing their work
                }
                else
                {
                    //  now we'll see if the primary contact set on the oppt, does the oppt already have a non primary contact role for the contact
                    //OpportunityContactRole tempOcr = findContactRole(singleOppt.id, currentContactRolesOfOppts);
                    
                    //if (tempOcr == null)//  contact role did not exist so create a new one and mark that dude primary
                    {
                        OpportunityContactRole ocr = new OpportunityContactRole();
                        ocr.OpportunityId = singleOppt.id;
                        system.assertNotEquals(null, singleOppt.Primary_Contact__c);
                        ocr.ContactId = singleOppt.Primary_Contact__c;
                        system.assertNotEquals(null, singleOppt.Role__c);
                        
                        ocr.Role = singleOppt.Role__c;
                        ocr.isPrimary = true;
                        contactRolesToCreate.add(ocr);
                    }
                }
            }
            //  since this is batch processing, we will update/insert the contact roles once all of the opportnities that needed to be checkeed were checked
            if (contactRolesToCreate.size() > 0)
            {
                insert contactRolesToCreate;
            }
           
        }
        
    }
    public static boolean doesPrimaryContactRoleExistAlready(Id opptId, List<OpportunityContactRole> primaryContactRoles)
    {
        //  so the list of contact roles passed into here are ones that are marked primary and belonignt to a subset of 
        //  opproutnities.  we'll scroll thru each of the primary contact roles looking for one that points to the optt
        for (OpportunityContactRole singleContactRole : primaryContactRoles)
        {
            //  only primary contacts shouldve been queried but we'll make the check here
            if (singleContactRole.OpportunityId == opptId && singleContactRole.IsPrimary)
            {
                return true;
            }
        }
        return false;
    }
    
    private static void assignSalesTeamManagerAndDarManager(List<Opportunity> opptsToCheck)
    {
        //  remove hardcoded user ids
        id brianCallahanUserId;
        id kenKrucenskiUserId;
        List<User> specificUsers = [select id, name from User where 
           (Name = 'Brian Callahan' or
           Name = 'Ken Krucenski')];
        for (User singleUser : specificUsers)
        {
            if (singleUser.name == 'Brian Callahan')
            {
                brianCallahanUserId = singleUser.id;
            }
            if (singleUser.name == 'Ken Krucenski')
            {
                kenKrucenskiUserId = singleUser.id;
            }
        }
        
        //  mass query the owner of the opptsToCheck
        Set<Id> ownerIds = new SEt<id>();
        for (Opportunity o : opptsToCheck)
        {
            if (o.ownerid != null && !ownerIds.Contains(o.ownerid))
            {
                ownerIds.add(o.ownerid);
            }
        }
        
        List<User> ownersOfopptsToCheck = [select id, name, profileid, profile.name, manager.name, managerId, manager.isactive from User where id in: ownerIds and isactive = true];
        
        //  then scroll thru each opppt making the update
        for (Opportunity singleOppt : opptsToCheck)
        {
            //  now we need to query the user's profile name to see if it contains Roadnet User Partner or SALES
            User ownerOfOppt = getOwnerOfOppt(singleOppt.ownerid, ownersOfopptsToCheck);
            
            if (ownerOfOppt != null)
            {
                if (ownerOfOppt.ProfileId != null && !util.isblank(ownerOfOppt.profile.Name))
                {
                    if (ownerOfOppt.Profile.Name.Contains('Sales') || ownerOfOppt.Profile.Name.Contains('Roadnet Partner') )//  is the owner of the oppt a Sales Rep or Var
                    {
                        //  now we need to check if the new oppt owner is already a sales team manager
                        //  if the owner of the oppt is already  a sales team manager then use the owner's name
                        //  (this is to avoid having an oppt owned by Tim Keffer and having Michael Farleas be his sales team manager
                        if ( ownerOfOppt.Id == kenKrucenskiUserId || ownerOfOppt.Id == brianCallahanUserId)
                        {
                            singleOppt.Sales_Team_Manager__c = ownerOfOppt.Name;
                            //  per email from jane dated 3/0/2014, the dar manager needs to be the sales team manager's id
                            //newOppt.Dar_Manager__c = ownerOfOppt.Id;
                        }
                        else
                        {
                            singleOppt.Sales_Team_Manager__c = ownerOfOppt.Manager.Name;
                            //  per email from jane dated 3/0/2014, the dar manager needs to be the sales team manager's id
                            //newOppt.Dar_manager__c = ownerOfOppt.managerid;                        
                        }
                    }
                }
            }
        } 
    
    }
    
    private static User getOwnerOfOppt(id opptOwnerId, List<User> users)
    {
        for (User singleUser : users)
        {
           if (singleUser.Id == opptOwnerId)
           {
               return singleUser;
           }
        }
        return null;
    }
    */
}