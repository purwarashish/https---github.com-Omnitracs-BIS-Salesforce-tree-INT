public with sharing class AssetSummary_Ctrl
{

    public List<AssetSummaryRow> assetList {get; private set;}
    
    public Map_Set__c mostCurrentMapSet{get;set;}
 
    public AssetSummary_Ctrl(ApexPages.StandardController stdController)
    {
        List<String> acctFields = new List<String>();
        acctFields.add('Inherit_Parent_s_Products__c');
        acctFields.add('ParentId');
        acctFields.add('Database_Platform__c');
     // acctFields.add('Co_Pilot_Version__c');
        
        if(!test.isRunningTest())
            stdController.addFields(acctFields);
        this.acct = (Account)stdController.getRecord();
        this.assetList = new List<AssetSummaryRow>();
        
        //  basically need to create asset summary rows
        accountAssets = queryAccountAssets(acct);
        
        //  and do the same 3 piecse of logic the old product page used to do
        
        //  once we have the assets of acccount and parent account (if applicalbe) we will scroll thru
        //  and create assetSummaryRecords and then pass them into the methods the sum/remove dupes
        for (Customer_Asset__c ass : accountAssets)
        {
            util.debug('adding ' + ass.id + ' - ' + ass.Name + ' - ' + ass.Product__r.Name + ' to assset list');
            assetList.add(new AssetSummaryRow(ass));
        } 

        util.debug('num of items in account asset list: ' + assetList.size());
        
        removeDuplicateRNASubscriptionLineItemsAndUpAllValues(assetList);
        //removeAddOnProductsFromListAndSumUpTheIntegerFieldsExceptForQuantity(assetList);
        removeDuplicateListEntriesAndSumUpTheQuantity(assetList);
        
        assignLatestMapSet();
    }
    
    private final Account acct;
    private List<Customer_Asset__c> accountAssets{get;set;}
    
    
    public class AssetSummaryRow {
        public String name {get; set;}
        public Id astId {get; set;}
        public String bundle {get; set;}
        public Decimal quantity {get; set;}
        public Decimal arr {get; set;}
        public Decimal numberOfDcs {get; set;}
        public Decimal numberOfUsers {get; set;}
        public Decimal NumberOfLicensedVehicles {get; set;}
        public Decimal ins {get; set;}
        public Decimal numberOfMobileAssets {get; set;}
        public Decimal numberOfMultiShiftVehicles {get; set;}
        public Decimal numberFulfilledLicenses {get;set;}
        public Boolean eval {get; set;}
        
        public Customer_Asset__c asset{get;set;}
        
        
        public AssetSummaryRow(Customer_Asset__c ass)
        {
            if (ass.Product__c != null && ass.Product__r.Name != null)
            {
                this.name = ass.Product__r.name;
            }
            else
            {
                this.Name = 'ProductNameNotFound';
            }
            this.astId = ass.id; 
            this.quantity = nullToZero(ass.quantity__c);
            //this.arr = nullToZero(ass.Arr__c); -- CLW
            this.numberOfDcs = nullToZero(ass.number_of_dcs__c);
            this.numberOfUsers = nullToZero(ass.Number_of_Users__c);
            //this.NumberOfLicensedVehicles = nullToZero(ass.number_of_vehicles__c); -- CLW
            this.ins = nullToZero(ass.number_of_Instances__c);
            this.numberOfMobileAssets = nullToZero(ass.number_of_mobile_assets__c);
            this.numberOfMultiShiftVehicles = nullToZero(ass.number_of_multi_shift_routes__c);
            //this.numberFulfilledLicenses = nullToZero(ass.Fulfilled_licenses__c); -- CLW
            this.eval = (boolean)ass.eval__c;
            
            this.asset = ass;//  not even sure this is needed by the old code had line item as a property of the SFLI class
        }
       
    }
    public string databasePlatform
    {
        get
        {
            // since the account is private, need to create accessor to get that databae platform field
            return acct.Database_Platform__c;
        }
    }
 /* public string copilotVersion
    {
        get
        {
            return acct.Co_Pilot_Version__c;
        }
    }*/
    public string getLatestMapSetPurchased()
    {
        if (mostCurrentMapSet != null )//  if there was one returned, return it formatted of course
        {
           return formatMapSetString(mostCurrentMapSet);  
        }
        else
        {
           return 'No Map Set Data.'; 
        }
    }
    
    
    private void assignLatestMapSet()
    {
        try
        {
            //  here we want to to do two things depending on whether or not he account has a parent account and if it is inheriting
            //  from the parent account
            if (acct.ParentId != null && acct.Inherit_Parent_s_Products__c)
            {
                mostCurrentMapSet = [SELECT 
                    Id, OwnerId, Name, CreatedDate, 
                    CreatedById, LastModifiedDate, LastModifiedById, 
                    
                    Map_Vendor__c, Map_Vendor__r.Name, Comments__c, Date_Purchased__c,
                    Vendor_Map_Version_pl__c,
                    Historical_Traffic_Data_Inrix__c, Number_of_Licensed_Vehicles__c    from Map_Set__c 
                    where account__c =: acct.ParentId and Date_Purchased__c <> null order by Date_Purchased__c desc, lastmodifieddate desc limit 1];                
            }
            else
            {
                mostCurrentMapSet = [SELECT 
                    Id, OwnerId, Name, CreatedDate, 
                    CreatedById, LastModifiedDate, LastModifiedById, 
                    Map_Vendor__c, Map_Vendor__r.Name, Comments__c, Date_Purchased__c, 
                    Vendor_Map_Version_pl__c,
                    Historical_Traffic_Data_Inrix__c, Number_of_Licensed_Vehicles__c from Map_Set__c 
                    where account__c =: acct.Id and Date_Purchased__c <> null order by Date_Purchased__c desc, lastmodifieddate desc limit 1];  
            }                  
        }
        catch(Exception e)
        {
            mostCurrentMapSet = null;
        }
    
    }
    
    public static ApexPages.StandardController generateController(Account a)
    {
        pagereference pageRef=new pagereference('Page.AssetSummary');
        test.setcurrentpage(pageRef);
        
        if (a.id != null)
        {
            ApexPages.currentPage().getParameters().put('id', a.id);
        }       
        return new ApexPages.standardController(a);
    }
    
    private static List<Customer_Asset__c> queryAccountAssets(account theAccount)
    {
        // query the accounts assets first and then we'll query the parent accounts assets if the account's inherit parents products = true
        List<Customer_Asset__c> allAssetsOfAccount = new List<Customer_Asset__c>();
        //REMOVED QUERIES::: Add_On_To__c, ARR__c, Number_of_Vehicles__c, Fulfilled_Licenses__c,
        List<Customer_Asset__c> accountAssets = 
           [select Id, name, product__c, license_type__c, Product__r.Name, Contracted_Licenses__c, Number_of_DCs__c, Number_of_Users__c, 
                Bundle_Name__c, Number_of_Instances__c, Number_of_Mobile_Assets__c, Number_of_Multi_Shift_Routes__c, 
               Eval__c,  Show_as_Separate_Line__c, account__c, account__r.name, quantity__c 
               from Customer_Asset__c where
                   Account__c =: theAccount.id AND
                   asset_status__c = 'Active' AND
                   Product__r.Show_on_Summary_Page__c = TRUE
               ORDER BY 
                Product__r.Name,
                LastModifiedDate DESC,
                Eval__c];
         
         allAssetsOfAccount.addAll(accountAssets);
         
         if (theAccount.Inherit_Parent_s_Products__c && theAccount.ParentId != null)
         {
            //REMOVED QUERIES::: Add_On_To__c, Add_On_To__c, Fulfilled_Licenses__c, Number_of_Vehicles__c, ARR__c,
            List<Customer_Asset__c> parentAccountAssets = [select Id, product__c, name, Product__r.Name, Contracted_Licenses__c,
                license_type__c, Number_of_DCs__c, Number_of_Users__c, 
                Bundle_Name__c, Number_of_Instances__c, Number_of_Mobile_Assets__c, Number_of_Multi_Shift_Routes__c, 
               Eval__c,  account__c, account__r.name, Show_as_Separate_Line__c, quantity__c 
               
               from Customer_Asset__c where
                   Account__c =: theAccount.parentId AND
                   asset_status__c = 'Active' AND
                   Product__r.Show_on_Summary_Page__c = TRUE
               ORDER BY 
                Product__r.Name,
                LastModifiedDate DESC,
                Eval__c];
             
             allAssetsOfAccount.addAll(parentAccountAssets);
         }
         return allAssetsOfAccount;
               
    }
    
    @testvisible private static void removeDuplicateRNASubscriptionLineItemsAndUpAllValues(List<AssetSummaryRow> items)
    {
        //  here is my first hold up on this, we no longer have 2 rna line items but three: dispatching, routing, tracking
        //  so im going to introduce ONE more list to this 
        
        List<AssetSummaryRow> rnaRoutings = new lIst<AssetSummaryRow>();//  = rnaPlans
        List<AssetSummaryRow> rnaDispatchs = new List<AssetSummaryRow>();
        List<AssetSummaryRow> rnaTrackings = new List<AssetSummaryRow>();
        
        for (integer i = 0; i < items.size(); i++)
        {
            if (isRnaRouting(items[i].Asset.Product__r.Name))
            {
                rnaRoutings.add(items.remove(i));
                i--;
            }
            else if (isRnaDispatch(items[i].Asset.Product__r.Name))
            {
                rnaDispatchs.add(items.remove(i));
                i--;
            }
            else if (isRnaTracking(items[i].Asset.Product__r.Name))
            {
                rnaTrackings.add(items.remove(i));
                i--;
            }
        }
        
        util.debug('total number of rnaRoutings: ' + (rnaRoutings == null ? 0 : rnaRoutings.size())  );
        removeDupesAndAddAllValues(rnaRoutings);
        removeDupesAndAddAllValues(rnaDispatchs);
        removeDupesAndAddAllValues(rnaTrackings);
        
        items.addAll(rnaRoutings);
        items.addAll(rnaDispatchs);
        items.addAll(rnaTrackings);
        
        
    }
    
    @testvisible private static boolean isRnaRouting(string productName)
    {
        if (productName != null && productName.contains('Anywhere Routing'))
        {
            return true;
        }
        else 
        {
            return false;
        }
    }
    @testvisible private static boolean isRnaDispatch(string productName)
    {
        if (productName != null && productName.contains('Anywhere Dispatching'))
        {
            return true;
        }
        else 
        {
            return false;
        }
    }
    @testvisible private static boolean isRnaTracking(string productName)
    {
        if (productName != null && productName.contains('Anywhere Tracking'))
        {
            return true;
        }
        else 
        {
            return false;
        }
    }
    @testvisible private static void removeDupesAndAddAllValues(AssetSummaryRow[] rnaAssets)
    {
        if (rnaAssets.size() == 0)//  no items in the list just return, do nothing to the list
        {
           return ; 
        }
        else
        {
            //  go thru the list of items, one by one
            for(integer originalElement = 0; originalElement < rnaAssets.size(); originalElement++)
            for(integer i = 0; i < rnaAssets.size(); i++)
            {
                //  make sure we aren't chekcing for dupes by looking at the same item in th list
                if (originalElement != i)
                {
                    boolean hasDupeBeenFound = false;
                    
                    //  compare the sfli in context to everything the list and look for dupes       
                    hasDupeBeenFound = checkForDupeUsingUnknownCriteria(rnaAssets[originalElement], rnaAssets[i]);
                    
                    if (hasDupeBeenFound)//  if dupe has been found
                    {
                        AssetSummaryRow tempAsset =  rnaAssets.remove(i);//  remove the dupe at location [i] and assign to temp variable
                        //  sum all the values to the sfli at location [originalElement]
                        rnaAssets[originalElement].quantity += tempAsset.quantity;
                        rnaAssets[originalElement].numberOfUsers += tempAsset.numberOfUsers;
                        
                        
                        //  this isnew logic that i added may 8th, 2015, not 100% it is correct hence the comment here
                        if (!isVehiclesUnlimited(rnaAssets[originalElement].NumberOfLicensedVehicles)  && 
                            !isVehiclesUnlimited( tempAsset.NumberOfLicensedVehicles))//  if num vehicles = 55555 or 9999 they are considered unlmited and theres no need to sum
                        {
                            rnaAssets[originalElement].NumberOfLicensedVehicles += tempAsset.NumberOfLicensedVehicles;
                        }
                        
                        
                        rnaAssets[originalElement].numberOfDcs += tempAsset.numberOfDcs;
                                                
                        //  *********** BEGIN OF FIELDS THAT WERE NOT PREVISIOULY SUMMED UP FOR LINE ITEMS IN OLD ROADNET INSTANCE  **************
                        //  be advised that these were not previosuly summed up int he old code but i decided to add it
                        //  if laura/roxanne says they shouldnt be then i can easily remove... however after checking
                        //  live dispatch/routing/tracking assets, i dont see any of them containing values for any of the other columns
                        //  except for arr, so I will sum that total up also since all of the other fields are summed
                        rnaAssets[originalElement].arr += tempAsset.Arr;
                        //  *********** END OF FIELDS THAT WERE NOT PREVISIOULY SUMMED UP FOR LINE ITEMS IN OLD ROADNET INSTANCE  **************
                        
                        
                        
                        i--;//  decrement i since the list size is now smaller due to the remove above
                    }
                }
            }
        }
    }
    
    @testvisible private static boolean checkForDupeUsingUnknownCriteria(AssetSummaryRow theOriginalObject, 
        AssetSummaryRow theObjectWeCheckForDupes)
    {
        system.assertNotEquals(null, theOriginalObject);
        system.assertNotEquals(null, theObjectWeCheckForDupes);
        
        boolean areBothShowSeperateLineFalse = false;
        boolean doTheProductsMatch = false;
        //boolean doTheAccountsMatch = false;
        boolean doTheEvaulationCheckBoxesMatch = false;
        boolean doTheDemoCheckBoxMatch = false;
        //boolean areBothLineItemsAddOnToExistingProductEqualFalse = false; -- CLW
        
        areBothShowSeperateLineFalse = !theOriginalObject.asset.Show_as_Separate_Line__c && !theObjectWeCheckForDupes.asset.Show_as_Separate_Line__c; 
        doTheProductsMatch = theOriginalObject.asset.product__c == theObjectWeCheckForDupes.asset.product__c;
        //doTheAccountsMatch = theOriginalObject.lineItem.account__c == theObjectWeCheckForDupes.lineItem.account__c;
        doTheEvaulationCheckBoxesMatch = theOriginalObject.asset.eval__c == theObjectWeCheckForDupes.asset.eval__c;
        //demo field does not exist on the assset object doTheDemoCheckBoxMatch = theOriginalObject.asset.Demo__c == theObjectWeCheckForDupes.asset.Demo__c;
       // areBothLineItemsAddOnToExistingProductEqualFalse = (theOriginalObject.asset.Add_On_To__c == null) &&
            //(theObjectWeCheckForDupes.asset.Add_On_To__c == null); -- CLW
        
        if (areBothShowSeperateLineFalse && 
            doTheProductsMatch &&
            doTheEvaulationCheckBoxesMatch) //&& 
            //areBothLineItemsAddOnToExistingProductEqualFalse) -- CLW
        {
            return true;
        }
        else
        {
            return false;
        }   
    }
    
    /*private static void removeAddOnProductsFromListAndSumUpTheIntegerFieldsExceptForQuantity(List<AssetSummaryRow> assetList)
    {
        //  go thru each sfli and see if any have the add on to exisint product flag set to true
        for(integer i = 0; i < assetList.size(); i++)
        {
            if (assetList[i].asset.Add_On_To__c != null  && !assetList[i].asset.Show_as_Separate_Line__c)
            {
                //  we should make this method return a boolean or even throw an exception, we'll go with boolean
                //  if it finds the line item then fine.  if it doesn't find the line item... what is the worst that can happen?
                //  to figure that out we need to see exactly what this method does. it bascailly looks for the line item in the 
                //  system, sums it up and then removes the add on line item.  i think it is safe to leave the line item in place.  the only
                //  caveat i see of that is if their si antoehr line item that has same stats as the add on.  it could then get summed up
                //  with that line item when it really shouldn't.  but since this add on removal is the last thing that is doen to the list
                //  it should be ok.  now that i think abuot it, i'm going to put this in a try blcok
                if (findTheLineItemThatTheAddOnProductIsPointingToAndPerformSummationAndRemoveTheAddOnFromTheList(assetList, assetList[i], i))
                {
                    i--;
                }
            }
        }
    }  -- cLW*/

  /*  private static boolean findTheLineItemThatTheAddOnProductIsPointingToAndPerformSummationAndRemoveTheAddOnFromTheList(
        List<AssetSummaryRow> theCompleteList, AssetSummaryRow theAddOnLineItem,  Integer locationOfTheAddOnLineItemInTheArray)
    {
        system.assertNotEquals(null,theCompleteList);
        system.assertNotEquals(null,theAddOnLineItem);
        system.assertNotEquals(null,locationOfTheAddOnLineItemInTheArray);
        
               
        boolean foundTheLineItemTheAddOnWasPointTo = false;
        
        integer locationOfTheLineItemTheAddOnIsPointingTo = 0;
        //  we have to go thru the complete list and look for the line item that add on line item is looking at
        for (integer i = 0; i < theCompleteList.size(); i++ )
        {
            //  make sure we don't look at the same item in the array in which we are doing teh search for
            if (i != locationOfTheAddOnLineItemInTheArray)
            {
                //  if we find the add on's line item in the list
                if (!theCompleteList[i].Asset.Show_as_Separate_Line__c &&
                    theCompleteList[i].asset.id == theAddOnLineItem.asset.Add_on_to__c)
                {
                    foundTheLineItemTheAddOnWasPointTo = true;
                    
                    locationOfTheLineItemTheAddOnIsPointingTo = i;
                    AssetSummaryRow tempHolderForTheAddOnLineItem = theCompleteList[locationOfTheAddOnLineItemInTheArray];
                    //  zero out any null fields
                    zeroOutNullFields(tempHolderForTheAddOnLineItem);
                    zeroOutNullFields(theCompleteList[locationOfTheLineItemTheAddOnIsPointingTo]);

                    //  add ONLY the number of users, vechiles, and sites up. 
                    //  the quantity should not be added to the line item in context
                    
                    //  no need to sum up the vehicles if they are unlimited
                    if (!isVehiclesUnlimited(theCompleteList[locationOfTheLineItemTheAddOnIsPointingTo].NumberOfLicensedVehicles) &&
                        !isVehiclesUnlimited(tempHolderForTheAddOnLineItem.NumberOfLicensedVehicles))
                    {
                        theCompleteList[locationOfTheLineItemTheAddOnIsPointingTo].NumberOfLicensedVehicles += 
                            tempHolderForTheAddOnLineItem.NumberOfLicensedVehicles;
                    }
                    theCompleteList[locationOfTheLineItemTheAddOnIsPointingTo].NumberOfUsers += 
                        tempHolderForTheAddOnLineItem.NumberOfUsers;
                    theCompleteList[locationOfTheLineItemTheAddOnIsPointingTo].numberOfDcs += 
                        tempHolderForTheAddOnLineItem.numberOfDcs;
                    theCompleteList[locationOfTheLineItemTheAddOnIsPointingTo].NumberOfMobileAssets += 
                        tempHolderForTheAddOnLineItem.NumberOfMobileAssets;
                    theCompleteList[locationOfTheLineItemTheAddOnIsPointingTo].numberOfMultiShiftVehicles += 
                        tempHolderForTheAddOnLineItem.numberOfMultiShiftVehicles;
                     
                   //  *********** BEGIN OF FIELDS THAT WERE NOT PREVISIOULY SUMMED UP FOR LINE ITEMS IN OLD ROADNET INSTANCE  **************
                   //  after checking live add ons, only arr and fulfilled licenses have values
                   theCompleteList[locationOfTheLineItemTheAddOnIsPointingTo].arr += 
                        tempHolderForTheAddOnLineItem.arr;
                   
                   //  so i was summing up the fulfilled licenses, but i believe fulfilled licenses is on the same level as contracted licenses
                   //  which is the same as quantity... which means if its add on, since we are not summing up quanitty or contracted licenses
                   //  we should not sum this up either...
                   /*theCompleteList[locationOfTheLineItemTheAddOnIsPointingTo].numberFulfilledLicenses += 
                        tempHolderForTheAddOnLineItem.numberFulfilledLicenses;     
                   */
                   //  *********** END OF FIELDS THAT WERE NOT PREVISIOULY SUMMED UP FOR LINE ITEMS IN OLD ROADNET INSTANCE  **************  

                    //  assign the license type of the add on line item to the line item it's pointing too
                    //  in the omnitracs instance, license type is a formula field so this assignement CANNOT be made
                    /* theCompleteList[locationOfTheLineItemTheAddOnIsPointingTo].asset.License_Type__c = 
                         tempHolderForTheAddonLineItem.asset.License_Type__c;
                         */
                    /*
                    //  remove the add on item from the list after done summaction
                    theCompleteList.Remove(locationOfTheAddOnLineItemInTheArray);
                }
            }
        }
        
        if (!foundTheLineItemTheAddOnWasPointTo)//  if the add on is not found, throw an exception
        {
            return false;
        }
        return true;
    }*/
    
    @testvisible private static void zeroOutNullFields(AssetSummaryRow theObject)
    {
        if (theObject.Quantity == null)
        {
            theObject.Quantity = 0;
        }
        if (theObject.Arr == null)
        {
            theObject.arr = 0;
        }
        if (theObject.NumberOfLicensedVehicles == null)
        {
            theObject.NumberOfLicensedVehicles = 0;
        }
        if (theObject.NumberOfUsers == null)
        {
            theObject.NumberOfUsers = 0;
        }
        if (theObject.numberOfDcs == null)
        {
            theObject.numberOfDcs = 0;
        }
        if (theObject.NumberOfMobileAssets == null)
        {
            theObject.NumberOfMobileAssets = 0;
        }
        if (theObject.NumberOfMultiShiftVehicles == null)
        {
            theObject.NumberOfMultiShiftVehicles = 0;
        }
       
        if (theObject.numberFulfilledLicenses == null)
        {
            theObject.numberFulfilledLicenses = 0;
        }
        if (theObject.ins == null)
        {
            theObject.ins = 0;
        }
    }
    @testvisible private static void removeDuplicateListEntriesAndSumUpTheQuantity(List<AssetSummaryRow> assetList)
    {
        //  go thru each sfli and see if there are dupelicates,
        for(integer originalElement = 0; originalElement < assetList.size(); originalElement++)
        for(integer i = 0; i < assetList.size(); i++)
        {
            //  make sure we aren't chekcing for dupes by looking at the same item in th list
            if (originalElement != i)
            {
                boolean hasDupeBeenFound = false;
                //  look for dupes in the list       
                hasDupeBeenFound = checkForDupeUsingTheQuantityAsCriteria(assetList[originalElement], assetList[i]);
               
                //  when we find a dupe, remove the dupes and at the same time add 
                //  the quanitiy of the removed dupe to the original value in the list
                if (hasDupeBeenFound)
                {
                    removeDupesAndAssignQuantityAndMoreToSFLI(assetList, originalElement, i);
                    i--;
                }
            }
        }
       
    }
    
    @testvisible private static boolean checkForDupeUsingTheQuantityAsCriteria(AssetSummaryRow theOriginalObject, AssetSummaryRow theObjectWeCheckForDupes)
    {
        boolean areBothShowAsSeperateLineFalse = false;
        boolean doTheProductsMatch = false;
        boolean doTheLicenseTypeMatch = false;
        //  after giving laura email on 8/21/2015 for case#01817328 showing these booleans she said this is not needed so removing it 
        //boolean doTheNumberOfVehiclesMatch = false;
        //boolean doTheNumberOfDCsMatch = false;
        //boolean doTheNumberOfUsersMatch = false;
        boolean doTheEvaulationCheckBoxesMatch = false;
        //boolean areBothLineItemsAddOnToExistingProductEqualFalse = false; -- CLW
        boolean areBothUnlimitedOrNotUnlimited = false;        
        
        //  null out the number fields for the line item
        zeroOutNullNumberFieldsOnLineItem(theOriginalObject.Asset);
        zeroOutNullNumberFieldsOnLineItem(theObjectWeCheckForDupes.Asset);
        
        areBothShowAsSeperateLineFalse = !theOriginalObject.Asset.Show_as_Separate_Line__c && !theObjectWeCheckForDupes.asset.Show_as_Separate_Line__c;
        doTheProductsMatch = theOriginalObject.asset.product__c == theObjectWeCheckForDupes.asset.product__c;
        //doTheAccountsMatch = theOriginalObject.asset.account__c == theObjectWeCheckForDupes.asset.account__c;
        doTheLicenseTypeMatch = theOriginalObject.asset.License_Type__c == theObjectWeCheckForDupes.asset.License_Type__c;
        //doTheNumberOfVehiclesMatch = theOriginalObject.asset.number_of_vehicles__c == 
        //    theObjectWeCheckForDupes.asset.number_of_vehicles__c;
        //doTheNumberOfDCsMatch = theOriginalObject.asset.Number_of_DCs__c == theObjectWeCheckForDupes.asset.Number_of_DCs__c;
        //doTheNumberOfUsersMatch = theOriginalObject.asset.Number_Of_Users__c == theObjectWeCheckForDupes.asset.Number_Of_Users__c;
        doTheEvaulationCheckBoxesMatch = theOriginalObject.asset.Eval__c == theObjectWeCheckForDupes.asset.Eval__c;
        
        //  we do not want to sum up an unlimited vehicle asset with one that does not have unlimted vehicles
        areBothUnlimitedOrNotUnlimited = 
            (isVehiclesUnlimited(theOriginalObject.NumberOfLicensedVehicles) && isVehiclesUnlimited(theObjectWeCheckForDupes.NumberOfLicensedVehicles)) ||
            (!isVehiclesUnlimited(theOriginalObject.NumberOfLicensedVehicles) && !isVehiclesUnlimited(theObjectWeCheckForDupes.NumberOfLicensedVehicles) );
        
        
        //areBothLineItemsAddOnToExistingProductEqualFalse = (theOriginalObject.asset.Add_On_To__c == null)  &&
            //(theObjectWeCheckForDupes.asset.Add_On_To__c == null); -- CLW
        
        if (areBothShowAsSeperateLineFalse && doTheProductsMatch && doTheLicenseTypeMatch && areBothUnlimitedOrNotUnlimited &&
            //doTheNumberOfVehiclesMatch && doTheNumberOfDCsMatch && doTheNumberOfUsersMatch &&
            doTheEvaulationCheckBoxesMatch) //&& areBothLineItemsAddOnToExistingProductEqualFalse) -- CLW
        {
            return true;
        }
        else
        {
            return false;
        }
    }
    
    @testvisible private static void removeDupesAndAssignQuantityAndMoreToSFLI(AssetSummaryRow[] theList, Integer locationOforiginalObject, Integer locationOfObjectToRemove)
    {
        //  assign the quanitty of the removed dupe to the item we were doing the check agaisnt.  this is
        //  where the suammation of the quanitites occurs.
        zeroOutNullFields(theList[locationOforiginalObject]);
        zeroOutNullFields(theList[locationOfObjectToRemove]);
                
        theList[locationOforiginalObject].quantity += theList[locationOfObjectToRemove].quantity;
        //theList[locationOforiginalObject].arr += theList[locationOfObjectToRemove].arr;
        //theList[locationOforiginalObject].numberFulfilledLicenses += theList[locationOfObjectToRemove].numberFulfilledLicenses;
        theList[locationOforiginalObject].ins += theList[locationOfObjectToRemove].ins;
        theList[locationOforiginalObject].numberOfDcs += theList[locationOfObjectToRemove].numberOfDcs;
        theList[locationOforiginalObject].NumberOfMultiShiftVehicles += theList[locationOfObjectToRemove].NumberOfMultiShiftVehicles;
        theList[locationOforiginalObject].NumberOfUsers += theList[locationOfObjectToRemove].NumberOfUsers;
        
        theList.Remove(locationOfObjectToRemove);
    }
    
    @testvisible private static void zeroOutNullNumberFieldsOnLineItem(Customer_Asset__c l)
    {
        system.assertNotEquals(null, l);
        if (l.Contracted_Licenses__c == null)
        {
            l.Contracted_Licenses__c = 0;
        }
        if (l.Number_of_DCs__c == null)
        {
            l.Number_of_DCs__c = 0;
        }
        if (l.number_of_users__c == null)
        {
            l.number_of_users__c = 0;
        }
    }  

    private static string formatMapSetString(Map_Set__c mapset)
    {
        system.assertNotEquals(null, mapSet);
        
        string theString = '';
        string mapVendorName = (mapSet.Map_Vendor__r.Name == null ? '' : mapSet.Map_Vendor__r.Name);
        string vendorMapVersionName = mapSet.Vendor_Map_Version_PL__c;
        
        theString +=  mapVendorName + ' - ';
        theString += nullToWhiteSpace(vendorMapVersionName) + ' - ';
        theString += formatDate(mapset.date_purchased__c);
        return theString;
    }
    
    private static string nullToWhiteSpace(string str)
    {
        if ((str == null)||(str == ''))
        {
            return '';  
        }   
        else
        {
            return str; 
        }
    }
    
    private static string formatDate(Date theDate)
    {
        if (thedate == null)
        {
           return 'No Date Specified';  
        }
        else
        {
           return theDate.month() + '/' + theDate.Day() + '/' + theDate.year();  
        }
    }
    
    private static boolean isVehiclesUnlimited(decimal d)
    {
        return d == 55555 || d == 9999;
    }
    
    private static decimal nullToZero(decimal d)
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
    

}