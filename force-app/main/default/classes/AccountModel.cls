public with sharing class AccountModel
{
    
    private boolean ClientInstall = false;

    public AccountModel(Account a, Boolean isPortal)
    {
        record = a;
        if(isPortal == null) isPortal = false;
        
        this.isPortal = isPortal;
        this.isRoadnetOnly = false;
    }
    
    public AccountModel(Account a)
    {
        this(a, false);
    }
    
    //added by Mark David De Chavez
    public AccountModel(Account a, Boolean isPortal, Boolean isRoadnetOnly)
    {
        record = a;
        if(isPortal == null) isPortal = false;
        
        this.isPortal = isPortal;
        this.isRoadnetOnly = isRoadnetOnly;
    }
    
   
    public Account record {get; set;}
    public Boolean isCommitted{ get{return (record != null && record.Id != null);}}
    public Boolean isPortal{get; private set;}
    public Boolean isRoadnetOnly{get; set;}
    
    public List<SelectOption> accountOptions;
    
    public Map<String, List<SelectOption>> mapAccountToContacts {get; private set;}
    public Map<String, List<SelectOption>> mapAccountToSupportContacts {get; private set;}
    //public Map<String, List<SelectOption>> mapAccountToEntitlements {get; private set;}
    //public Map<String, List<SelectOption>> mapEntitlementToProductFamilies {get; set;}
    //public Map<String, List<SelectOption>> mapEntProductFamilyToAssets {get; set;}
    public Map<String, List<SelectOption>> mapAccountToProductFamilies {get; set;}
    public Map<String, List<SelectOption>> mapProductFamilyToProductLines {get; set;}
    public Map<String, List<SelectOption>> mapPfProductLineToAssets {get; set;}
    public List<Customer_Asset__c> accountAssets{get;set;}
    //public Map<String, List<SelectOption>> mapAssetToPractices {get; set;}
    //public Map<String, List<SelectOption>> mapAssetToVersions {get; private set;}
    //public Map<String, List<SelectOption>> mapVersionFamilyToVersions {get; private set;}   
    //public Map<String, List<SelectOption>> mapAssetToComponents {get; private set;}
    //public Map<String, List<SelectOption>> mapComponentToSubComponents {get; private set;}
    
    //Map<ID, Entitlement__c> entitlementMap = new Map<ID, Entitlement__c>();
    Map<ID, Customer_Asset__c> assetMap = new Map<ID, Customer_Asset__c>();
    Map<ID, Account> accountMap = new Map<ID, Account>();
    
    public void getAccounts()
    {
        accountOptions = new List<SelectOption>();
        accountMap.put(record.id, record);
        
        
        getContacts(accountMap.keySet(),  null);
        getSupportContacts(accountMap.keySet(),  null);
        getProductFamiliesProductLinesAndAssets(accountMap.keySet());
        
    }
    
    public void getContacts(Set<ID> accountIDs, String contactId)
    {
        mapAccountToContacts = new Map<String, List<SelectOption>>();
        //If a Contact is already selected, put it first in the list
        if (contactId != null) {
          List<Contact> selectedContacts = [SELECT ID, AccountID, LastName, FirstName
                         FROM Contact
                          WHERE Id = :contactId
                          AND AccountID IN :accountIDs];
            if (selectedContacts.size() > 0) {
              Contact selectedContact = selectedContacts[0];
              List<SelectOption> contactList;
              if(mapAccountToContacts.containsKey(selectedContact.AccountID))
                  contactList = mapAccountToContacts.get(selectedContact.AccountID);
              else
                  contactList = new List<SelectOption>();
            
            contactList.add(new SelectOption(selectedContact.id, selectedContact.LastName+', '+selectedContact.FirstName));
            mapAccountToContacts.put(selectedContact.AccountID, contactList);
            }
        }
        for(Contact cnt: [SELECT ID, AccountID, LastName, FirstName 
                          FROM Contact 
                          WHERE AccountID IN :accountIDs
                          ORDER BY LastName, FirstName
                          LIMIT 999])
/** @todo  Is there a 'Status' or 'Active' flag we should filter on?
                                AND Contact_Status__c = 'Active' */
        {
          if ((String)cnt.Id != contactId) {
              List<SelectOption> contactList;
              if(mapAccountToContacts.containsKey(cnt.AccountID))
                  contactList = mapAccountToContacts.get(cnt.AccountID);
              else
                  contactList = new List<SelectOption>();
            
              contactList.add(new SelectOption(cnt.id, cnt.LastName+', '+cnt.FirstName));
              mapAccountToContacts.put(cnt.AccountID, contactList);
          }
        }
    }
    
    public void getSupportContacts(Set<ID> accountIDs, String contactId)
    {
        mapAccountToSupportContacts = new Map<String, List<SelectOption>>();
        //If a Contact is already selected, put it first in the list
        if (contactId != null) {
            List<Contact> selectedContacts = [SELECT ID, AccountID, LastName, FirstName, Account.RecordTypeId
                                       FROM Contact
                                       WHERE Id = :contactId
                                       AND AccountID IN :accountIDs];
            if (selectedContacts.size() > 0) {
                Contact selectedContact = selectedContacts[0];
                List<SelectOption> contactList;
                if(mapAccountToSupportContacts.containsKey(selectedContact.AccountID))
                    contactList = mapAccountToSupportContacts.get(selectedContact.AccountID);
                else
                    contactList = new List<SelectOption>();
                
                contactList.add(new SelectOption(selectedContact.id, selectedContact.LastName+', '+selectedContact.FirstName));
                mapAccountToSupportContacts.put(selectedContact.AccountID, contactList);
            }
        }
        
        //
        // Select Designated Support Contact and Account Record Type as well. We filter on these below as appropriate
        //
        for(Contact cnt: [SELECT Id, LastName, FirstName,
                                 AccountId,
                                 Account.RecordTypeId
                          FROM Contact 
                          WHERE AccountID IN :accountIDs
                          ORDER BY LastName, FirstName
                          LIMIT 999])
/** @todo  Is there a 'Status' or 'Active' flag we should filter on?
                                AND Contact_Status__c = 'Active' */
        {
            if ((String)cnt.Id != contactId) {
                
                if (!mapAccountToSupportContacts.containsKey(cnt.AccountId)) {
                  // Create SelectOption list if it doesn't already exist
                  mapAccountToSupportContacts.put(cnt.AccountId, new List<SelectOption>());
                }
                
                mapAccountToSupportContacts.get(cnt.AccountID).add(new SelectOption(cnt.Id, cnt.LastName + ', ' + cnt.FirstName));
            }
        }
    }
    
    public List<Contact> getSupportContacts(Id accId) {
      return [SELECT Id, Name, Email, Phone FROM Contact WHERE AccountId = :accId];
    }
    
    
    private void getProductFamiliesProductLinesAndAssets(Set<ID> accountIDs)
    {
        if(accountIDs != null && accountIDs.size() > 0)
        {
            mapAccountToProductFamilies = new Map<String, List<SelectOption>>();
            Map<String, Set<String>> mapAccountToProductFamiliesSet = new Map<String, Set<String>>();
            Map<String, List<String>> mapAccountToProductFamiliesList = new Map<String, List<String>>();
            Map<String, Set<String>> mapProductFamilyToProductLineSet = new Map<String, Set<String>>();
            mapProductFamilyToProductLines = new Map<String, List<SelectOption>>();
            mapPfProductLineToAssets = new Map<String, List<SelectOption>>();
            assetMap = new Map<ID, Customer_Asset__c>();
            Set<String> assetProdList = new Set<String>();
            Map<ID, Set<ID>> mapProductToAssets = new Map<ID, Set<ID>>();
            //Map<ID, ID> mapProductToVersionFamily = new Map<ID, ID>();
            
            //Added by Mark David De Chavez
            List<Customer_Asset__c> aList = new List<Customer_Asset__c>();
            System.debug('****************1');
            if (isRoadnetOnly){
                System.debug('****************2');
                aList = [Select ID, Name, Product__c, Product__r.Name, Product__r.Family, Product__r.Product_Line__c, Product__r.ProductCode, Account__c, Product__r.Description, Product__r.Product_Identifier__c 
                                       from Customer_Asset__c where
                                       Account__c in: accountIDs and
                                       Asset_Status__c =: 'Active' and 
                                       Product__c != null and
                                       //Product__r.isActive =: true and  //  Roadnet legacy products are inactive by default, we need to be able to see these in asset picklist however
                                       Product__r.Support_Applicable__c =: true
                                       Order By Product__r.Family, Product__r.Name ASC
                                       limit 1000
                                       ];
            }
            else{
                System.debug('****************3 - '+accountIDs.size() +' -- ');
                aList = [Select ID, Name, Product__c, Product__r.Name, Product__r.Family, Product__r.Product_Line__c, Product__r.ProductCode, Account__c, Product__r.Description, Product__r.Product_Identifier__c 
                                       from Customer_Asset__c where
                                       Account__c in: accountIDs and
                                       Asset_Status__c =: 'Active' and 
                                       Product__c != null and
                                       //Product__r.isActive =: true and //  Roadnet legacy products are inactive by default, we need to be able to see these in asset picklist however
                                       Product__r.Support_Applicable__c =: true                                        
                                       Order By Product__r.Family, Product__r.Name ASC
                                       limit 1000
                                       ];  
            }
            
            //  we are only concerned with the account's assets, let's go ahead and make that assignment here
            accountAssets = new List<Customer_Asset__c>();
            accountAssets.AddAll(aList);
            
            for(Customer_Asset__c va: aList)
            {
                List<String> productFamiliesList;
                Set<String> productFamiliesSet;
                if(mapAccountToProductFamiliesList.containsKey(va.Account__c)) {
                    productFamiliesList = mapAccountToProductFamiliesList.get(va.Account__c);
                    productFamiliesSet = mapAccountToProductFamiliesSet.get(va.Account__c);
                }
                else {
                    productFamiliesList = new List<String>();
                    productFamiliesSet = new Set<String>();
                }
                if(!GenericServices.isNullOrEmpty(va.Product__r.Family) && !productFamiliesSet.contains(va.Product__r.Family))
                {   
                    productFamiliesList.add(va.Product__r.Family);
                    productFamiliesSet.add(va.Product__r.Family);
                    mapAccountToProductFamiliesSet.put(va.Account__c, productFamiliesSet);
                    mapAccountToProductFamiliesList.put(va.Account__c, productFamiliesList);
                }   
                
                Set<String> productLines;
                if(mapProductFamilyToProductLineSet.containsKey(va.Product__r.Family))
                    productLines = mapProductFamilyToProductLineSet.get(va.Product__r.Family);
                else
                    productLines = new Set<String>();
                if(!GenericServices.isNullOrEmpty(va.Product__r.Product_Line__c))
                {
                    productLines.add(va.Product__r.Product_Line__c);
                    mapProductFamilyToProductLineSet.put(va.Product__r.Family, productLines);
                }   
                
                
                String assetKey = va.Product__r.Family+va.Product__r.Product_Line__c;
                List<SelectOption> assetList;
                if(mapPfProductLineToAssets.containsKey(assetKey))
                    assetList = mapPfProductLineToAssets.get(assetKey);
                else
                    assetList = new List<SelectOption>();
                    
                if (!assetProdList.contains(va.Product__r.Name))
                {
                    assetList.add(new SelectOption(va.id, convertAssetName(va)));
                    assetProdList.add(va.Product__r.Name);
                }
               
                mapPfProductLineToAssets.put(assetKey, assetList);
                
                
                Set<ID> assetIDs;
                if(mapProductToAssets.containsKey(va.Product__c))
                    assetIDs = mapProductToAssets.get(va.Product__c);
                else
                    assetIDs = new Set<ID>();
                assetIDs.add(va.id); 
                mapProductToAssets.put(va.Product__c, assetIDs);
                
                assetMap.put(va.id, va);
                //if(!GenericServices.isNullOrEmpty(va.Product__r.Version_Family__c))
                //    mapProductToVersionFamily.put(va.Product__c, va.Product__r.Version_Family__c);
            }
            
            //now convert the Set of Product Families in the map to List<SelectOption>
            for(String actID: mapAccountToProductFamiliesList.keySet())
            {
                List<String> familyList = new List<String>();
                familyList.addAll(mapAccountToProductFamiliesList.get(actID));
                List<SelectOption> familySO = new List<SelectOption>();
                for(String family: familyList)
                    familySO.add(new SelectOption(family, family));
                
                mapAccountToProductFamilies.put(actID, familySO);
            }
            
            //now convert the Set of Product Lines in the map to List<SelectOption>
            for(String pf: mapProductFamilyToProductLineSet.keySet())
            {
                List<String> productLineList = new List<String>();
                productLineList.addAll(mapProductFamilyToProductLineSet.get(pf));
                List<SelectOption> productLineSO = new List<SelectOption>();
                for(String pl: productLineList)
                    productLineSO.add(new SelectOption(pl, pl));
                
                mapProductFamilyToProductLines.put(pf, productLineSO);
            }
            
            //getPractices(assetMap.keySet());
            //getVersions(mapProductToAssets, mapProductToVersionFamily);
            //getComponents(mapProductToAssets);
        }
    }    
  
    public List<SelectOption> getContactOptionsByAccount(String actID, String contactId)
    {
        System.debug('Getting Contact Options');
        Set<ID> acts = new Set<Id>();
        acts.add(actId);
        getContacts(acts, contactId);
        List<SelectOption> contactOptions = new List<SelectOption>();
        if (actId != null) {
          if(mapAccountToContacts != null && mapAccountToContacts.containsKey(actID))
              contactOptions = mapAccountToContacts.get(actID);
          else
              contactOptions.add(new SelectOption('', '-- no contacts available --')); // Constants.NO_CONTACTS_AVAILABLE));
        }
        // Else if actId == null, just return an empty list
        
        system.debug('\n\ncontactoptions size='+contactOptions.size()+'\n');
        
        return contactOptions;
    }
    
    public List<SelectOption> getSupportContactOptionsByAccount(String actID, String contactId)
    {
        System.debug('Getting Support Contact Options');
        Set<ID> acts = new Set<Id>();
        acts.add(actId);
        getSupportContacts(acts, contactId);
        List<SelectOption> contactOptions = new List<SelectOption>();
        if (actId != null) {
            if(mapAccountToSupportContacts != null && mapAccountToSupportContacts.containsKey(actID) && mapAccountToSupportContacts.get(actID).size() > 0) {
                contactOptions = mapAccountToSupportContacts.get(actID);
            }
            else
                contactOptions.add(new SelectOption('', '-- no contacts available --')); // Constants.NO_CONTACTS_AVAILABLE));
        }
        // Else if actId == null, just return an empty list
        
        system.debug('\n\nSupportContactOptions size=' + contactOptions.size() + '\n');
        
        return contactOptions;
    }
    
    public List<SelectOption> getProductFamilyOptionsByAccount(String actID, String parentId)
    {
        List<SelectOption> productFamilyOptions = new List<SelectOption>();
        Set<ID> acts = new Set<ID>();
        acts.add(actID);
        if (parentId != null) {
            acts.add(parentId);
        }
        getProductFamiliesProductLinesAndAssets(acts);
        if(mapAccountToProductFamilies != null && (mapAccountToProductFamilies.containsKey(actID) || (parentId != null && mapAccountToProductFamilies.containsKey(parentId))))
        {
            productFamilyOptions.add(new SelectOption('', 'Select One'));
            if (mapAccountToProductFamilies.get(actID) != null) {
                productFamilyOptions.addAll(mapAccountToProductFamilies.get(actID));
            }
            // Add any Product Families available to the Parent
            if (parentId != null) {
                for (SelectOption parSO : mapAccountToProductFamilies.get(parentId)) {
                    Boolean found = false;
                    for (SelectOption chiSO : productFamilyOptions) {
                        if (chiSO.getValue() == parSO.getValue()) {
                            found = true;
                        }
                    }
                    if (!found) {
                        productFamilyOptions.add(parSO);
                    }
                }
                //productFamilyOptions.addAll(mapAccountToProductFamilies.get(parentId));
            }
            productFamilyOptions.add(new SelectOption('Customer Community','Customer Community'));
        }
        else
            productFamilyOptions.add(new SelectOption('', 'No Product Families Available'));
        
        return productFamilyOptions;
        
    }
    
    public List<SelectOption> getProductLineOptionsByProductFamily(String family)
    {
        List<SelectOption> productLineOptions = new List<SelectOption>();
        if(mapProductFamilyToProductLines != null && mapProductFamilyToProductLines.containsKey(family))
        {
            //productLineOptions.add(new SelectOption('', Constants.NONE));
            productLineOptions.addAll(mapProductFamilyToProductLines.get(family));
        }
        else if (family == 'Customer Community') {
            productLineOptions.add(new SelectOption('Customer Community', 'Customer Community'));
        }
        else
            productLineOptions.add(new SelectOption('', 'No Product Lines Available'));
        
        return productLineOptions;
    }
    

    
    private static string convertAssetName(Customer_Asset__c ass)
    {
        string productName;
                
        if (!Util.isblank(ass.Product__r.Description))
        {
           productName = ass.Product__r.Description;
        }
        else
        {
            productName = ass.Product__r.Name;
        }
        return productName;
    }
    
    public List<SelectOption> getAssetOptionsByProductFamilyAndProductLine(String family, String productLine, boolean showAllAssets)
    {
        
        String key = family+productLine;
        List<SelectOption> assetOptions = new List<SelectOption>();
        //  now i am thinking what i have here works... but there is a better way to do it
        //  i want to say that essentially, if the product family has not been selectd, then we should display all assets
        
        //  so here i want to say if the family is blank, then show all of the assets, 
        if (Util.isBlank(family))
        {
            //  if this is set, we want to return all assetsw of the account without filtering on family or product line
            List<Customer_Asset__c> allAssets = assetMap.values();
            if (allAssets != null && allAssets.size() > 0)
            {
                //  then we should show all of the assets unless there are none then we'll show no assets available
                assetOptions.add(new selectoption('', 'Select One'));
            
                for (Customer_Asset__c ass : allAssets)
                {
                    assetOptions.add(new selectoption (ass.id, convertAssetName(ass)));
                }
            }
            else
            {
                assetOptions.add(new SelectOption('', 'No Assets Available'));
            }
            
        }
        else
        {
            if(mapPfProductLineToAssets != null && mapPfProductLineToAssets.containsKey(key))
            {
                //assetOptions.add(new SelectOption('', Constants.NONE));
                assetOptions.addAll(mapPfProductLineToAssets.get(key));
            }
            else if (family == 'Customer Community') {
                assetOptions.add(new SelectOption('', 'Customer Community'));
            }
            else
                assetOptions.add(new SelectOption('', 'No Assets Available'));
        }
        
        assetOptions = removeDupeOptions(assetOptions);
        return assetOptions;
    }
    
    private static List<SelectOption> removeDupeOptions(List<SelectOption> options)
    {
        List<SelectOption> optionsToReturn = new List<SelectOption>();
        for (SelectOption so : options)
        {
            if (!doesOptionExistCheckLabel(so, optionsToReturn))
            {
                optionsToReturn.add(so);
            }
        }
        return optionsToReturn;
         
    }
    private static boolean doesOptionExistCheckLabel(SelectOption theSelectOption, List<SelectOption> optionsToCheck)
    {
        
        for (SelectOption so : optionsToCheck)
        {
            if (so.getLabel() == theSElectOption.getLabel())
            {
                return true;
            }
        }
        return false;
    }
    
    public List<SelectOption> getAssetOptionsByProductFamily(String family)
    {
        List<SelectOption> assetOptions = new List<SelectOption>();
        if(mapPfProductLineToAssets != null && mapPfProductLineToAssets.containsKey(family))
        {
            //assetOptions.add(new SelectOption('', Constants.NONE));
            assetOptions.addAll(mapPfProductLineToAssets.get(family));
        }
        else
            assetOptions.add(new SelectOption('', 'No Assets Available'));
        
        return assetOptions;
    }
    
    /*public List<SelectOption> getPracticeOptionsByAsset(String assetID)
    {
        List<SelectOption> practiceOptions = new List<SelectOption>();
        if(mapAssetToPractices != null && mapAssetToPractices.containsKey(assetID))
        {
            practiceOptions.add(new SelectOption('', Constants.NONE));
            practiceOptions.addAll(mapAssetToPractices.get(assetID));
        }
        else
            practiceOptions.add(new SelectOption('', Constants.NO_PRACTICES_AVAILABLE));
        
        return practiceOptions;
    }
    
    public String getVersionOnAsset(String assetID)
    {
        if(!GenericServices.isNullOrEmpty(assetID) && assetMap != null && assetMap.containsKey(assetID))
            return assetMap.get(assetID).Version__c;
        
        
        return null;
    }
    
    public List<SelectOption> getVersionOptionsByAsset(String assetID)
    {
        List<SelectOption> versionOptions = new List<SelectOption>();
        ViteraAsset__c va;
        try
        {
            va = [Select ID, Product__c, Product__r.Version_Family__c from ViteraAsset__c where id=: assetID];
        }
        catch(QueryException qe)
        {
            versionOptions.add(new SelectOption('', Constants.NO_ASSET_VERSIONS_AVAILABLE)); 
            return versionOptions;
        }
        
        if(va != null && va.Product__r.Version_Family__c != null)
        {
            if(mapVersionFamilyToVersions != null && mapVersionFamilyToVersions.containsKey(va.Product__r.Version_Family__c))
            {
                versionOptions.add(new SelectOption('', Constants.NONE));
                versionOptions.addAll(mapVersionFamilyToVersions.get(va.Product__r.Version_Family__c));
            }
            else
                versionOptions.add(new SelectOption('', Constants.NO_ASSET_VERSIONS_AVAILABLE));
        }   
        else
            versionOptions.add(new SelectOption('', Constants.NO_ASSET_VERSIONS_AVAILABLE)); 
        
        return versionOptions;
    }
    
    public List<SelectOption> getComponentOptionsByAsset(String assetID)
    {
        List<SelectOption> componentOptions = new List<SelectOption>();
        if(mapAssetToComponents != null && mapAssetToComponents.containsKey(assetID))
        {
            componentOptions.add(new SelectOption('', 'None'));
            componentOptions.addAll(mapAssetToComponents.get(assetID));
        }
        else
            componentOptions.add(new SelectOption('', Constants.NO_COMPONENTS_AVAILABLE));
        
        return componentOptions;
    }
    
    public List<SelectOption> getSubComponentOptionsByComponent(String cmpID)
    {
        List<SelectOption> subComponentOptions = new List<SelectOption>();
        if(mapComponentToSubComponents != null && mapComponentToSubComponents.containsKey(cmpID))
        {
            subComponentOptions.add(new SelectOption('', 'None'));
            subComponentOptions.addAll(mapComponentToSubComponents.get(cmpID));
        }
        else
            subComponentOptions.add(new SelectOption('', Constants.NO_SUB_COMPONENTS_AVAILABLE));
        
        return subComponentOptions;
    }
*/    
//    public PageReference saveCase(CaseModel cm, CaseComment cc, string redirectType, Boolean useDefaultAssignmentRules, Boolean isChangeAsset, Boolean InstRec)
    public PageReference saveCase(Case c, CaseComment cc, string redirectType, Boolean useDefaultAssignmentRules, Boolean isChangeAsset, Boolean InstRec)
    {
        if(redirectType != null && c != null) // cm != null && cm.record != null)
        {
            //Added conditional to check if Case is Client Install - JM - 12/18/2012
            if(InstRec)
                ClientInstall = true;
            
            if(!validate(c)) // cm.record))
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.FATAL, 'Please fill in all required fields')); // System.Label.Please_fill_in_all_required_fields));
                return null;
            }
            
/*            if(isChangeAsset)
            {
                if(assetMap.containsKey(cm.record.Asset__c))
                    cm.record.Product_Name__c = assetMap.get(cm.record.Asset__c).Product__c;
                
                System.debug('\n\nc = '+cm.record+'\n\n');
                upsert cm.record;
            }
            else
            {
*/                if(useDefaultAssignmentRules)
                    c.setOptions(GenericServices.defaultAssignmentDBOptions);
//                    cm.record.setOptions(GenericServices.defaultAssignmentDBOptions);
                else
                    CaseServices.createdCaseTrackersAndHistories = true;
                                    
/*                if(cm.isEngineeringCase)
                {
                    cm.record.AccountID = null;
                    cm.record.ContactId = null;
                    if(cm.record.Subject == null) cm.record.Subject = '';
                    cm.record.Subject = '[Engineering] '+cm.record.Subject;
                    
                    cm.record.Account_Eng__c = record.id;
                    String ownerQueueID = GenericServices.developmentQueueID;
                    //Made conditional change if Owner is set in the L3 Create Wizard
                    if(cm.record.OwnerId == null)
                    {
                        if(ownerQueueID != '')
                            cm.record.OwnerID = ownerQueueID;
                    }
                }
 */               
                //cm.record.BusinessHoursID = entitlementMap.get(cm.record.Entitlement__c).Business_Hours__c;
//                if(!isPortal && !ClientInstall && assetMap.containsKey(cm.record.Asset__c))
//                    cm.record.Product_Name__c = assetMap.get(cm.record.Asset__c).Product__c;
                
//                upsert cm.record;
                c.Work_Effort_in_Minutes__c = 0;
                upsert c;
                
                if(!useDefaultAssignmentRules)
                {
                    
                    Map<ID, Case> refCases = new Map<ID, Case>();
                    refCases.put(c.id, c);
//                    refCases.put(cm.record.id, cm.record);
                    
//                    List<Case_Tracker__c> caseTrackers = CaseServices.getCaseTrackers(refCases.values());
//                    insert caseTrackers;
                    
//                    update refCases.get(cm.record.id);
                    update refCases.get(c.id);
                    
                }
                    
                if(cc != null && cc.CommentBody != null && cc.CommentBody.length() > 0)
                {
//                    cc.ParentId = cm.record.Id;
                    cc.ParentId = c.Id;
                    cc.IsPublished = false;
                    insert cc;
                }
//            }
            String redirectURL =  '';
            
            
            if(redirectType == 'parent') // Constants.REDIRECT_PARENT)
                redirectURL = '/'+c.Id;
//                redirectURL = '/'+cm.record.Id;
            else if (redirectType == 'edit') 
                redirectURL = '/' + c.Id + '/e?retURL=%2F' + c.Id;
            else if(redirectType == 'attach') // Constants.REDIRECT_ATTACH)
                redirectURL = '/p/attach/NoteAttach?pid='+c.Id+'&parentname=&retURL=%2F'+c.Id;
//                redirectURL = '/p/attach/NoteAttach?pid='+cm.record.Id+'&parentname=&retURL=%2F'+cm.record.Id;
            
            PageReference pr = new PageReference(redirectURL);
            pr.setRedirect(true);
                
            system.debug('\n\nIsPortal = '+isPortal+'\n');
            return pr;
        }
        return null;
    }
    
    private Boolean validate(Case c)
    {
        if
        (
            isPortal &&
            (
                GenericServices.isNullOrEmpty(c.AccountId)|| 
                GenericServices.isNullOrEmpty(c.ContactId)
//||
//                GenericServices.isNullOrEmpty(c.Product_Family_Name__c) ||
//                GenericServices.isNullOrEmpty(c.Product_Line_Name__c)
            )
        )
            return false;
        else if
        (
            !isPortal && !ClientInstall &&
            (
                GenericServices.isNullOrEmpty(c.AccountId)|| 
                GenericServices.isNullOrEmpty(c.ContactId)
//||
//                GenericServices.isNullOrEmpty(c.Asset__c)
            )   
        )
            return false;
        else if
        (
            !isPortal && ClientInstall &&
            (
                GenericServices.isNullOrEmpty(c.AccountId)|| 
                GenericServices.isNullOrEmpty(c.ContactId)
            )
            
        )
            return false;
        
        return true;
    }

}