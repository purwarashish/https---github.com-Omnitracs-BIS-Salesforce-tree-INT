/*******************************************************************************
 * File:  BatchAccountUpdate.cls
 * Date:  Dec 29, 2014
 * Author:  Joseph Hutchins
 *
 * The use, disclosure, reproduction, modification, transfer, or transmittal of
 * this work for any purpose in any form or by any means without the written 
 * permission of United Parcel Service is strictly prohibited.
 *
 * Confidential, unpublished property of United Parcel Service.
 * Use and distribution limited solely to authorized personnel.
 *
 * Copyright 2009, UPS Logistics Technologies, Inc.  All rights reserved.
 *  *******************************************************************************/
global class BatchAccountUpdate implements Database.Batchable<sObject>
{
    public string query;
    
    public BatchAccountUpdate()
    {
    	//  after testing this with all accounts not just roadnet, i have two validation rules that are causing update failures
    	//  i am going to exclude accounts that fail those validations
        query = 'select id, recordtypeid, Name, Major_Products__c, Roadnet_RTI_Products__c, billingstate, inherit_parent_s_products__c, Summation_of_SA_Revenue__c, ' + 
        	 'Primary_Business_Unit__c, account_classification__c, account_status__c, Summation_Of_Subscription_Revenue__c, parentId, LastAPISyncForDailylBatchProcess__c from Account where ' + 
           // '( LastAPISyncForDailylBatchProcess__c < Today OR LastAPISyncForDailylBatchProcess__c = NULL ) AND ' + //  dont think this is needed anymore since this runs once a day
            // i created a report where about 10,000 account_status accounts where active but didnt have a account clasficiation, they didnt have any assets but i am l
            //' Account_Classification__c = \'Customer\' AND ' + 
            ' Account_Status__c = \'Active\' AND ' +  
            ' BillingState != null  AND ' + // roadnet validtatoin rule
            ' Send_to_Netsuite__c = false ';// + // lastest test is showing that batches are failing due to calling the future method: NetsuiteSyncAccountHelper.postDataToNetsuite
           
        util.debug('BatchAccountUpdate called.  query for accounts to be used: ' + query);
    }

    global dataBase.queryLocator start(Database.BatchableContext BC)
    {
        return DataBase.getQueryLocator(query);//  returns the first query 
    }
    global void execute(DataBase.BatchableContext BC, List<sObject> scope)
    {
        util.debug('inside of execute method.  accounts should have been queried.  number passed into this method: ' + scope == null ? 0 : scope.size());
        
        Account[] accountsToUpdate = new List<Account>();
        for (sObject s : scope)//  for each sobject in the list of sobjects
        {
            Account a = (Account)s;//  cast sobject to account
            accountsToUpdate.add(a);//  add the account to list of accounts
        }
        updateMajorProductsField(accountsToUpdate);
       
        updateRoadnetRTiProductsField(accountsToUpdate);
        updateSummationFieldsUsingAccountAssets(accountsToUpdate);
        //  once the methods above have finished updating the account fields, we can perform the mass update on those accounts
        
        database.update(accountsToUpdate, false); // hoping that doing the update allOrNothing = false causes all accounts to update
        util.debug('account update should be complete');
        
    }
    
    
    
    //  ************************************* START OF MAJOR PRODUCT METHODS  ****************************************************************************
    public void updateMajorProductsField(List<Account> accounts)
    {
        util.debug('inside of updateMajorProductsFields method.  num accounts passed into method: ' + (accounts == null ? 0 : accounts.size()) );
        
        List<Asset__c> allActiveMajorProductAssetsOfAccount = queryAccountAssets(accounts, true);
        util.debug('query for all active major products returned:  ' + 
            (allActiveMajorProductAssetsOfAccount == null ? 0 : allActiveMajorProductAssetsOfAccount.size()) );
        
        for (Account singleAccount : accounts)
        {
            util.debug('working account with major products field: ' + singleAccount.Major_Products__c + ': ' + singleAccount);
            List<Asset__c> accountMajorProductAssets = new List<Asset__c>();
            //  for each account, pull out a unique list of major products asests
            
            accountMajorProductAssets  = findAssetsOfAccount(singleAccount, allActiveMajorProductAssetsOfAccount);
            util.debug('query for the accounts major assets retunred: ' + (accountMajorProductAssets == null ? 0 : accountMajorProductAssets.size() ) );
            //  using the custom setting mapping, concatenate a string of products to the accounts field
            singleAccount.Major_Products__c = createMajorProductsString(accountMajorProductAssets);
            util.debug('account.Major_Products__c is now: ' + singleAccount.Major_Products__c);
        }

    }
    
    private string createMajorProductsString(List<Asset__c> majorProductAssets)
    {
        
        util.debug('inside of createMajorProductsString method.  num assets passed in: ' + (majorProductAssets == null ?  0 : majorProductAssets.size() ) );
        string returnString = '';
        
        Set<string> uniqueMajorProductSet = new Set<string>();
        for (Asset__c ass : majorProductAssets)
        {
            ///  all should be major product but check to make sure
            if (ass.Product__c != null &&
               ass.Product__r.Is_Major_Product__c && 
               ass.Product__r.Major_Product_Text__c  != null && ass.Product__r.Major_Product_Text__c.length() > 0)
            {
                //  firs tthing is to dsplie out the porudcts in the major product text for roadnets bunlded products
                //  then we'll cusror thru them and add them to the set
                List<string> majorProductTextSplitOut = parseMajorProductText(ass.Product__r.Major_Product_text__c);
                for (string singleStr : majorProductTextSplitOut)
                {
                    if (!uniqueMajorProductSet.contains(singleStr))
                    {
                        uniqueMajorProductSet.add(singleStr);
                    }
                }
                
                // once we've gone thru all major products split out, we will convert to list so we can use the sort (assuming this works on strings)
                List<string> uniqueListMajorProducts = new List<string>();
                uniqueListMajorProducts.addAll(uniqueMajorProductSet);
                uniqueListMajorProducts.sort();
                
                returnString = convertListStringsToOneString(uniqueListMajorProducts);
               
            }
        }
        util.debug('returnString value = ' + returnString);
        return returnString;
    }
    
    
        private List<string> parseMajorProductText(string str)
        {
            List<string> theStrings = new List<string>();
            if (str == null)
            {
                return new List<string>();
            }
            else
            {
                List<string> stringArray = (str.split(',', 0));


                //lets make sure there isn't blank items in the list and try to clear in any leading trailign whitespaces
                for (integer i = 0; i < stringArray.size(); i++)
                {
                    string itemToAddToList = stringArray[i].Trim();

                    if (itemToAddToList != '')
                    {
                        theStrings.Add(itemToAddToList);
                    }
                }
            }
            return theStrings;
        }

    //  **************************************END OF MAJOR PRODUCT METHODS  ***************************************************************************
    
    global void updateRoadnetRTiProductsField(List<Account> accounts)
    {
        //  i see no reason why we cant have all of the RTI Products field update logic in this method, if we have to add
        // additional fucntions to this i can wrap the logic in a class...
        
        // the omnitracs instance does not have a concept of inherited line items so we only need to look at the child account's assetss
        // and the parent accounts if the inherit parnet products flag is set
        util.debug('querying allActiveAssetsOfAccount...');
        List<Asset__c> allActiveAssetsOfAccount = queryAccountAssets(accounts, true); 
        
        util.debug('query complete.  num of assets returned: ' + (allActiveAssetsOfAccount == null ? 0 : allActiveAssetsOfAccount.Size()) );
        //  now we can scroll thru each account, and summarieze all active show at product page assets of the account
        for (Account singleAccount : accounts)
        {
        	if (isRoadnetAccount(singleAccount))
        	{
	            util.debug('working on account with name: '  + singleAccount.name + ' and about to query assets for that account');
	            List<Asset__c> accountsAssets = new List<Asset__c>();
	            accountsAssets = findAssetsOfAccount(singleAccount, allActiveAssetsOfAccount);
	            util.debug(
	               'finished FINDING accountsAssets in the main list of assets.  num found: ' + (accountsAssets == null ? 0 : accountsAssets.size()) 
	               );
	            if (accountsAssets.size() > 0)
	            {
	                util.debug('account with name: ' + singleAccount.name + ' had assets');
	                string rtiProductString = createUniqueProductString(accountsAssets);
	                util.debug('after making the RTI PRODUCTS string.  the value is: ' +  rtiProductString);
	                singleAccount.Roadnet_RTI_Products__c = rtiProductString;
	            }
	            else
	            {
	                singleAccount.Roadnet_RTI_Products__c = 'None';
	            }
        	}
                
            
        }
        
        util.debug('finished updadting RTI Products field for accounts passed into Execute method.  will now update accounts...');
    }
    

    global void updateSummationFieldsUsingAccountAssets(List<Account> accounts)
    {
        util.debug('inside of updateSummationFieldsUsingAccountAssets method');
        Set<id> accountIds = getUniqueSetAccountIds(accounts);
        util.debug('num of unique account ids: ' + accountIds.size());
        
        //  query active billing detail service agreements in mass for all accounts passed into this method
        List<Asset__c> assetsOfAccount = [select id, ARR__c, account__c, Maintenance_Status__c, product__c, License_type__c from Asset__c where
           account__c in: accountIds AND
           Maintenance_Status__c = 'On Maintenance'];
        
        util.debug('finished querying all assets of accounts passed into method.  num returned: ' + (assetsOfAccount == null ? 0 : assetsOfAccount.size()) );
        
        //  for each account
        for (Account singleAccount : accounts)
        {
        	if (isRoadnetAccount(singleAccount))
        	{
	            util.debug('working account with name: ' + singleACcount.Name);
	            
	            //  first we will sum up the SA Revenue field
	            //  pull out the details that point to the account
	            List<Asset__c> accountsServiceAgreementAssets = findAssetsOfAccountUsingLicenseType(assetsOfAccount, singleAccount, false);
	            util.debug('found ' + (accountsServiceAgreementAssets == null ? 0 : accountsServiceAgreementAssets.size()) + ' Service agreement assets');
	            
	            decimal sumSaRevenue = 0.0;
	            
	            for (Asset__c ass : accountsServiceAgreementAssets)
	            {
	                //  perform a simple summation for all
	                sumSaRevenue += (ass.Arr__c == null ? 0 : ass.Arr__c);
	            }
	            util.debug('sum of sa revenue for: ' + singleAccount.name + ' is ' + sumSaRevenue);
	            
	            singleAccount.Summation_of_SA_Revenue__c = sumSaRevenue;
	            
	            //  now we do the subscription update
	            List<Asset__c> accountsSubscriptionAssets = findAssetsOfAccountUsingLicenseType(assetsOfAccount, singleAccount, true);
	            util.debug('num of subscription assets for the account: ' +  (accountsSubscriptionAssets == null ? 0 : accountsSubscriptionAssets.size()));
	            
	            decimal sumSubscriptionRevenue = 0.0;
	            for (Asset__c ass : accountsSubscriptionAssets)
	            {
	                sumSubscriptionRevenue += (ass.ARR__c == null ? 0 : ass.ARR__c);
	            }
	            util.debug('sum of subscription revenue for account ' + singleAccount.name + ': '  + sumSubscriptionRevenue);
	            singleAccount.Summation_Of_Subscription_Revenue__c = sumSubscriptionRevenue;
        	}
        }
         
    }
    global boolean isRoadnetAccount(Account a)
    {
    	return a.account_classification__c == 'Customer' &&
    		a.primary_business_unit__c == 'Roadnet' &&
    		a.account_status__c == 'Active' &&
    		a.billingSTate != null;
    	
    }
    global List<Asset__c> queryAccountAssets(List<Account> accounts, boolean queryMajorProductsOnly)
    {
        /*
         "select id, product__r.name, account__c, product__c,active_sa__c, Product__r.Is_Major_Product__c, Product__r.Product_Identifier__c, 
           Product__r.Sort_Order__c, Product__r.Show_At_Product_Page__c from line_Item__c " +
                " where inactive__c = false and active_sa__c = true and Product__c != null";//  added the Product__c != null on 4/4/2014 after this line item LI394987 causeed app to fail alot
        */
        util.debug('inside of queryAccountAssets...');
        //  first thing we need to do is get a unique list of account ids where we need to query the assets
        //  normally i would do a select * from asset where account__c in: accounts but if there are any accounts in the list
        //  that inherit parnets products, we need the parent acconts line items first
        Set<id> accountIds = getUniqueSetAccountIds(accounts);
        
        util.debug('after making a unique set of account ids, size of the set: ' + (accountIds == null ? 0 : accountIds.size()) );
        
        //  now with the uqnieu list of account itds, we can now mass query the assets
        List<Asset__c> assetsToReturn = new LIst<Asset__c>();
        try
        {
            util.debug('about to query account assets');
            if (queryMajorProductsOnly)
            {
            	assetsToReturn = [select id,  Maintenance_Status__c, Account__c, Product__c,
                Product__r.Is_Major_Product__c, Product__r.Product_Identifier__c, Product__r.Name, product__r.major_Product_text__c from Asset__c 
              where 
              account__c in: accountIds and 
              Maintenance_Status__c = 'On Maintenance' and 
              Product__c != null and
              Product__r.Is_Major_Product__c = true LIMIT 50000];
            util.debug('finished main asset query with a max LIMIT OF 50000... number returned: ' + (assetsToReturn == null ? 0 : assetsToReturn.size()) );
            
            return assetsToReturn;
            
            }
            else
            {
            	assetsToReturn = [select id,  Maintenance_Status__c, Account__c, Product__c,
                Product__r.Is_Major_Product__c, Product__r.Product_Identifier__c, Product__r.Name, product__r.major_Product_text__c from Asset__c 
              where 
              account__c in: accountIds and 
              Maintenance_Status__c = 'On Maintenance' and 
              Product__c != null LIMIT 50000];
              return assetsToReturn;
            }
        }
        catch(Exception e)
        {
            util.debug('error occured in asset retrival: ' + e.getMessage());
            return null;
        }
        
    }
    
    global Set<ID> getUniqueSetAccountIds(List<Account> accounts)
    {
        Set<id> accountIds = new Set<Id>();
        
        for (Account singleAccount : accounts)
        {
            if (!accountIds.Contains(singleAccount.id))
            {
                accountIds.add(singleAccount.id);
            }
            if (singleAccount.Inherit_Parent_s_Products__c && !accountIds.Contains(singleAccount.ParentId))
            {
                accountIds.Add(singleAccount.ParentId);
            }
        }
        return accountIds;
    } 
    
    global List<Asset__c> findAssetsOfAccount(Account theAccount, List<Asset__c> theAssets)
    {
        util.debug('finding assets for account with name: ' + theAccount.name + ' and id: ' + theAccount.id + ' and inherits parents products: ' + theAccount.Inherit_Parent_s_Products__c + ' with parent id: ' + theAccount.parentId);
        List<Asset__c> assetsToReturn = new List<Asset__c>();
        for (Asset__c singleAsset : theAssets)
        {
            if (theAccount.Inherit_Parent_s_Products__c)//  need to conmpare the account id of the child and the parent acount
            {
                if (singleAsset.Account__c == theAccount.Id || singleAsset.Account__c == theAccount.ParentId)
                {
                    assetsToReturn.add(singleAsset);
                }
            }
            else// doenst inherit parents products so does not need to check the account's parent id
            {
                if (singleAsset.Account__c == theAccount.id)
                {
                    assetsToReturn.add(singleAsset);
                }
            }
        }
        util.debug('finished looking for assets with account id: ' + theAccount.id + ' and name: ' + theAccount.name + '.  Number found: ' + (assetsToReturn == null ? 0 : assetsToReturn.size()) );
        return assetsToReturn;
    }
    
    global List<Asset__c> findAssetsOfAccountUsingLicenseType( List<Asset__c> theAssets, Account theAccount, boolean subscriptionOnly)
    {
        util.debug('about find assets of account with name: ' + theAccount.name);
        
        List<Asset__c> assetsOfAccount = getAccountAssets(theAssets, theAccount);
        
        List<Asset__c> assetsToReturn = new List<Asset__c>();
        
        //  now we scroll thru the assets, if subscription only look for them only
        if (subscriptionOnly)
        {
            for (Asset__c ass : assetsOFAccount)
            {
                //  we do not have to check the inerhtits parents products since the aboev method takes care of that for us
                if (ass.License_type__c != null && ass.License_type__c == 'Subscription')
                {
                    assetsToReturn.add(ass);
                }
            }
        }
        else
        {
            for (Asset__c ass1 : assetsOfAccount)
            {
                if (ass1.License_type__c != null && ass1.License_type__c != 'Subscription')
                {
                    assetsToReturn.add(ass1);
                }
            }
        }
        
        util.debug('finished FINDING assets for account ' + theAccount.name + ' number found: ' + assetsToreturn.size());
        return assetsToReturn;
        
    }
    global List<Asset__c> getAccountAssets(List<Asset__c> assets, Account theAccount)
    {
        List<Asset__c> assetsToTakeBack = new List<Asset__c>();
        util.debug('getting asstes for account with anme: ' + theAccount.name + ' inherits parent products: ' + theAccount.inherit_parent_s_products__c + ' account parentid: ' + theAccount.parentId);
        
        //  first we get all of the child account assets
        for (Asset__c ass : assets)
        {
            if (theAccount.id == ass.account__c)
            {
                assetsToTakeBack.add(ass);
            }
        }
        //  now well get the parent assets if and only if the inerhie parents prouct is set and the prent id is not set
        if (theACcount.inherit_parent_s_products__c && theAccount.ParentId != null)
        {
            for (Asset__c ass1 : assets)
            {
                if (theAccount.ParentId == ass1.Account__c)
                {
                    assetsToTakeBack.add(ass1);
                }
            }
        }
        util.debug('finished PULLING out the assets for account: ' + theAccount.name + ' num found: ' + assetstoTakeBack.size());
        return assetsToTakeBack;
        
    }
    
    global string createUniqueProductString(List<Asset__c> assets)
    {
        util.debug('inside of createUniqueProductString... num of assets passed in: ' + (assets == null ? 0 : assets.size()) );
        //  scroll thru the assets, will create a unqiue list of the assets' product identifier
        Set<string> uniqueProductNameSet = new Set<string>();
        for (Asset__c ass : assets)
        {
            if (ass.Maintenance_Status__c == 'On Maintenance' &&
              ass.Product__c != null &&
              ass.Product__r.Product_Identifier__c != null &&
              ass.Product__r.Is_Major_Product__c &&
              !uniqueProductNameSet.Contains(ass.Product__r.Product_Identifier__c))
            {
                uniqueProductNameSet.add(ass.Product__r.Product_Identifier__c);
            }
        }
        util.debug('finished making the unique product name set.  num in the set are: ' + (uniqueProductNameSet == null ? 0 : uniqueProductNameSet.size()) );
        //  return the list using a string using semicolons as seperateors
        if (uniqueProductNameSet != null && uniqueProductNameSet.size() > 0)
        {
            //  sort the unique list by alphabetical order
            List<string> uniqueProductNameList = new List<string>();
            uniqueProductNameList.addAll(uniqueProductNameSet);
            uniqueProductNameList.Sort();
            
            return convertListSTringsToOneString(uniqueProductNameList);
        }
        else
        {
           return 'None';
        }
    }
    
    global static string convertListStringsToOneString(string[] strings)
    {
        string theString='';
        
        //  only one item in the list, no need to add a semi colon for seperation
        if (strings.size() == 1)
        {
            theString = strings[0];
            return theString;
        }
        for (integer i = 0; i <strings.size(); i++)
        {
            if (i + 1 > strings.size())//  don't append semi colon
            {
                theString += strings[i];
                break;  
            }
            else
            {
                theString += strings[i];
                //  so we basdically want to say, if this is the last item in the list of strings, dont append the semicolon
                //  otherwise do so.  the last item in an array is always the size - 1? yep
                if (i != (strings.size() - 1))
                {
                    theString += '; ';
                }
                
            }
        }   
        return theString;
    }
    
    global List<Account> pullOutOnlyRoadnetAccounts(List<Account> accounts)
    {
        //  only business unit = roadnet, account status = active, billing state not blank, account classifcaition = customer
        //  last apisync < today or null
        List<Account> roadnetAccounts = new List<Account>();
        for (Account a : accounts)
        {
            if(
                  //( (a.LastAPISyncForDailylBatchProcess__c < Date.Today()) || (a.LastAPISyncForDailylBatchProcess__c == null) ) &&
                  ( (a.Account_Classification__c != null) && (a.Account_Classification__c == 'Customer')  ) &&
                  (a.Primary_Business_Unit__c == 'Roadnet') &&
                  ( (a.Account_Status__c != null) && (a.Account_Status__c == 'Active') ) &&
                  (a.BillingState != null)
                  
              )
            {
                roadnetAccounts.add(a);
            }
        }
        return roadnetAccounts;
    }
    global void finish(DataBase.BatchableContext BC)
    {
        system.debug('Batch Process Completed: BatchAccountUpdate');
    }

}