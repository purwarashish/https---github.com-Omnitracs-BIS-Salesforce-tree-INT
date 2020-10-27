public with sharing class CaseContExt {
  
    /**
     * NOTE: This class is still in use by both the portal and staff-facing case wizards.
     *       Would suggest separating out since they are relatively different processes with different requirements.
     *       Once that has been done, review the following:
     *
     * @todo  Review the following and see if we can remove the item and all associated logic
     *           - isPortal
     *           - InstRec
     *           - isChangeAsset
     *           - Others?
     */
    public AccountModel am{get; private set;}
    private final Account a;
    private Contact con;
    private Case c;
    private User u;
//    public CaseModel cm{get; private set;}
    private final String caseID;
    private final String CaseRecordType;
    private final String parentCaseID;
    private final Id dummyConID;
    public String prodFamily {get; set;}
    public String prodLine {get; set;}
    public String conFirstName {get; set;}
    public String conLastName {get; set;}
    public String conEmail {get; set;}
    public List<Contact> dscList {get; private set;}
    
    public CaseComment caseComment {get; set;}
    
    public Boolean isPortal {get; private set;}
    public Boolean isInternalUser {get; private set;}
    //public Boolean isManager {get; private set;}
    public Boolean InstRec {get; private set;}
    public Boolean isChangeAsset {get; private set;}
    public Boolean useDefaultAssignmentRules {get; set;}
    public Boolean showSuggestedArticles {get; set;}
    private boolean showAllAssets{get;set;}
    
    private Boolean initialChangeAssetLoad {get; set;}
    
    private ApexPages.StandardController thisStd;
    
    /**
     * Constructor Class
     */
    public CaseContExt(ApexPages.StandardController std)
    {
        //String supportUserProfileId = SystemIds__c.getInstance().ProfileId_Customer_Service__c;
        //String supportMgrProfileId = SystemIds__c.getInstance().ProfileId_Customer_ServiceMgr__c;
        
/*X     isPortal = false;
        isChangeAsset = false;
        
        Case c = (Case)std.getRecord();
        c.AccountId = ApexPages.currentPage().getParameters().get('def_account_id');
        c.ContactId = ApexPages.currentPage().getParameters().get('def_contact_id');
*/
        showSuggestedArticles = false;
        InstRec = false;
        this.thisStd = std;
        
        u = new User();
        this.u = [Select Id, ProfileId, Profile.UserLicense.LicenseDefinitionKey, ContactID, Contact.AccountID, Business_Unit__c from User where id= :UserInfo.getUserId()];
        
        dummyConID = '003000000000000000';
        
        caseID = ApexPages.currentPage().getParameters().get('id'); // CONSTANTS.QRY_STRING_CASE_ID);
        //Grab RecordType from URL
        CaseRecordType = ApexPages.currentPage().getParameters().get('RecordType');
        
        System.debug('\n\ncaseId = '+caseID+'\n\n');
        System.debug('\n\nCaseRecordType = '+CaseRecordType+'\n\n');
        
        if(caseID == null)
        {
            /** @todo  Move all of this code into a 'CurrentUser' class that has the logic in one place to determine whether a user is a portal user or not.
                       PortalUser class could be an extension of CurrentUser. CurrentUser would also have logic for isInternalUser as well. */
            
            System.debug('xyzzy - License Key: ' + u.Profile.UserLicense.LicenseDefinitionKey);
            isPortal = (u.ContactId != null);
            //isManager = (u.ProfileId == SystemIds__c.getInstance().ProfileId_CustomerSupportMgr__c || u.ProfileId == SystemIds__c.getInstance().ProfileId_SysAdmin__c);
            
            this.c = (Case)std.getRecord(); 
            this.isChangeAsset = false;
            
            if (CaseRecordType != null && CaseRecordType != '') {
                c.RecordTypeId = CaseRecordType;
            }
            
            parentCaseID = ApexPages.currentPage().getParameters().get('def_parent_id');
          if (parentCaseID != null) {
            c.ParentId = parentCaseID;
            c.put('ParentId', parentCaseID);
          }
             
            if(isPortal)
            {
                isInternalUser = false;
                c.AccountID = u.Contact.AccountID;
                c.ContactID = u.ContactID;
                System.debug('\n\nc.AccountID = ' + c.AccountID + '\n\n');
//                c.Origin = Constants.DEFAULT_ORIGIN_PORTAL;
                useDefaultAssignmentRules = true;
            }
            else
            {
                // 'Internal User' means any staff that is not Customer Support
                //isInternalUser =    u.ProfileId != supportUserProfileId
                //                 && u.ProfileId != supportMgrProfileId;
                isInternalUser = true;
                
                c.AccountId = ApexPages.currentPage().getParameters().get('cas4_lkid'); // Constants.QRY_STRING_ACCOUNT_ID);
                c.ContactId = ApexPages.currentPage().getParameters().get('cas3_lkid'); // Constants.QRY_STRING_CONTACT_ID);
                
                if (c.AccountId == null) {
                    c.AccountId = ApexPages.currentPage().getParameters().get('def_account_id');
                }
                if (c.ContactId == null) {
                    c.ContactId = ApexPages.currentPage().getParameters().get('def_contact_id');
                }
//              c.Origin = Constants.DEFAULT_ORIGIN;

                useDefaultAssignmentRules = false;
            }   
            
            caseComment = new CaseComment();
            
            initialChangeAssetLoad = false;
        }
        else
        {
            this.c = (Case)std.getRecord(); 
            this.isChangeAsset = true;
            isPortal = false;
            initialChangeAssetLoad = false; // temp
//            initialChangeAssetLoad = GenericServices.isNullOrEmpty(this.c.Product_Family_Name__c)?false:true;
        }
        
        if(c.AccountID == null)
        {
            // AccountId is now allowed to be null, don't throw an error
//            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.FATAL, 'No account provided.')); // System.label.No_Account_provided));
//            return;
            if (isInternalUser) {
                productFamilyOptions = getDefaultProductFamilyOptions();
                if (productFamilyOptions.size() > 0) {
                    c.put('Product_Family_Name__c', productFamilyOptions[0].getValue());
                }
            }
            contactOptions = new List<SelectOption>();
            //contactOptions.add(new SelectOption(dummyConID, 'Create New'));
            //c.put('ContactId', dummyConID);
        }
        else {
            try
            {
                a = [SELECT ID, Name, RecordTypeId, ParentId, Inherit_Parent_s_Products__c FROM Account WHERE id = :c.AccountID];
            }
            catch(QueryException qexc)
            {
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.FATAL, 'Invalid Account Id in URL.')); // System.label.Invalid_Account_ID_URL_param));
                return ;
            }
            
    //      c.Severity__c = Constants.SEVERITY_ROUTINE;            
            
            am = new AccountModel(a, isPortal);
    //      cm = new CaseModel(c);
            loadData();
        }
        
        if (u.Business_Unit__c != null && c.Business_Unit__c == null) {
            c.Business_Unit__c = u.Business_Unit__c;
            c.put('Business_Unit__c', u.Business_Unit__c);
        }
        else if (c.Business_Unit__c == '') {
            c.put('Business_Unit__c', 'Omnitracs US');
            c.Business_Unit__c = 'Omnitracs US';
        }
        
        c.put('Send_email_notification_to_contact__c', true);
        c.Send_email_notification_to_contact__c = true;
    }
    
    /**
     *
     */
    private void loadData()
    { 
        showAllAssets = true;
        am.getAccounts();
        accountOptions = am.accountOptions;
        makeDependentPicklistSelections(c.AccountID, 'AccountID');
        
        makeDependentPicklistSelectionsForAccount();
        
        c.put('Product_Family_Name__c', productFamilyOptions[0].getValue());
         
    }  
    
    /**
     *
     */
    public void makeDependentPicklistSelectionsForAccount()
    {
        if(!isPortal)
        {
            if(c.ContactId != null && (String)c.ContactId != (String)dummyConID)
            {
                try
                {
                    Contact onlyContactAVailable = [Select ID, AccountID, LastName, FirstName 
                                                        from Contact where id=: c.ContactID ];
                    contactOptions = new List<SelectOption>();
                    contactOptions.add(new SelectOption(onlyContactAvailable.id, onlyContactAvailable.LastName+', '+onlyContactAvailable.FirstName));
                    makeDependentPicklistSelections(c.ContactID, 'ContactID');
                }
                catch(Exception exc)
                {
                    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.FATAL, 'Error: ')); // System.label.General_Error_On_Case+': '+exc));
                }
            }
            else
            {
                System.debug('Going to AccountModel for Acc ID: ' + c.AccountID);
                Account acc = [SELECT ID, Name, RecordTypeId, ParentId, Inherit_Parent_s_Products__c FROM Account WHERE id = :c.AccountID];
                
                if(c.Business_Unit__c == 'Roadnet'){
                    am = new AccountModel(acc, isPortal, true);
                }
                else{
                    am = new AccountModel(acc, isPortal);    
                }
                
                //contactOptions = am.getContactOptionsByAccount(c.AccountID, c.ContactId);
                //makeDependentPicklistSelections(contactOptions, 'ContactID');
            }
        }
        
        contactOptions = am.getContactOptionsByAccount(c.AccountID, c.ContactId);
        //contactOptions.add(new SelectOption(dummyConID, 'Create New'));
        if (contactOptions.size() > 1 && (String)c.ContactId == (String)dummyConID) {
            c.put('ContactId', null);
        }
        if (am.record.Inherit_Parent_s_Products__c) {
            productFamilyOptions = am.getProductFamilyOptionsByAccount(c.AccountID, am.record.parentId);
        }
        else {
            productFamilyOptions = am.getProductFamilyOptionsByAccount(c.AccountID, null);
        }
        System.debug('**************** size - '+productFamilyOptions.size());
        if (productFamilyOptions.size() > 0) {
            c.put('Product_Family_Name__c', productFamilyOptions[0].getValue());
        }
//        makeDependentPicklistSelections(productFamilyOptions, 'Product_Family_Name__c');
        makeDependentPicklistSelectionsForProductFamily();
        
    }    
    
    /**
     *
     */
    public List<SelectOption> getDefaultProductFamilyOptions()
    {
        List<SelectOption> options = new List<SelectOption>();
        
        Schema.DescribeFieldResult F = Case.Product_Family_Name__c.getDescribe();
        for (Schema.PicklistEntry p : F.getPicklistValues()) {
            options.add(new SelectOption(p.getValue(), p.getLabel()));
        }
        
        return options;
    }    
    

    /**
     *
     */
    public void makeDependentPicklistSelectionsForProductFamily()
    {
        productLineOptions = am.getProductLineOptionsByProductFamily(c.Product_Family_Name__c);
        makeDependentPicklistSelections(productLineOptions, 'Product_Line_Name__c');
        
        makeDependentPicklistSelectionsForProductLine();
        
        //c.put('Product_Family_Name__c', this.prodFamily);
        
        //assetOptions = am.getAssetOptionsByProductFamily(c.Product_Family_Name__c);
        makeDependentPicklistSelections(assetOptions, 'Customer_Asset__c');
        
        makeDependentPicklistSelectionsForAsset();
    }
    
    /**
     *
     */
    public void makeDependentPicklistSelectionsForProductLine()
    {   
        assetOptions = am.getAssetOptionsByProductFamilyAndProductLine(c.Product_Family_Name__c, c.Product_Line_Name__c, showAllAssets);
        System.debug('PL ASTS: ' + assetOptions);
        
        showAllAssets = false;//  only on the first page load should we show all assets, after that, we should only see the assets filtered by
        //  product family/line
        
        makeDependentPicklistSelections(assetOptions, 'Customer_Asset__c');
        
        makeDependentPicklistSelectionsForAsset();
        
        //c.put('Product_Line_Name__c', this.prodLine);
    }
    
    
    /**
     *
     */
    public void makeDependentPicklistSelectionsForAsset()
    {
        //  so here is the logic here as a recap, this is called when the asset picklist changes
        //  when that happens, we need to auto select the selected assets' product family and product line
        //  the product family picklist always contains all product families so that's just making sure the cases's product family
        //  field is set from the selected asset.  the product line picklist is a little tricker as it is depednat on product family
        //  we need to have the product line picklist show all product lines so that we can make sure the selected proudct line
        //  that comes from the asset is there...
        //  just need to make sure that if the user changes the product family that the product line picklist is popualted as it would
        //  with the normal dependency in place, which i am sure it will be. my only concern now is what happens when the 
        //  product line is changed after the asset is changed, im hopping that the onchane method tied to that picklist
        //  will bring back the old depencendies
        util.debug('makeDependentPicklistSelectionsForAsset method called.  c.customer_asset__c value = ' + c.customer_asset__c);
        if (!util.isBlank(c.Customer_Asset__c))
        {
            List<Customer_Asset__c> aList = [select id, Product_Family__c, Product_line__c from Customer_Asset__c where id =: c.Customer_Asset__c];
            Customer_Asset__c tempAsset;
            if (aList != null && aList.size()>0)
            {
            	tempAsset = aList.get(0);
                c.Put('Product_family_name__c', tempAsset.Product_Family__c);
                c.Put('product_line_name__c', tempAsset.Product_Line__c);
            }
            //  since the product family was set from the asset, the product line piclist will be filled with only
            //  product lines of that product family
            productLineOptions = am.getProductLineOptionsByProductFamily(c.Product_Family_Name__c);
            
        }
        else
        {
            
        }
        //practiceOptions = am.getPracticeOptionsByAsset(c.Asset__c);
        //makeDependentPicklistSelections(practiceOptions, 'Practice__c');
        
        //versionOptions = am.getVersionOptionsByAsset(c.Asset__c);
        //makeDependentPicklistSelections(versionOptions, 'Version__c');
        
        //String versionID = am.getVersionOnAsset(c.Asset__c);
        //if(!GenericServices.isNullOrEmpty(versionID))
            //c.Version__c = versionID;
        
        // Are we using components? If so, set up A<->C relationship and add this logic back in.   
        //componentOptions = am.getComponentOptionsByAsset(c.Asset__c);
        //makeDependentPicklistSelections(componentOptions, 'Component__c');
        
        //makeDependentPicklistSelectionsForComponent();
    }
    
    
    /**
     *
     */
    /*public void makeDependentPicklistSelectionsForComponent()
    {
        subComponentOptions = am.getSubComponentOptionsByComponent(c.Component__c);
        makeDependentPicklistSelections(subComponentOptions, 'Sub_Component__c');
        
        initialChangeAssetLoad = false;
    }
*/    
    
    /**
     *
     */
    private void makeDependentPicklistSelections(List<SelectOption> options, String fieldName)
    {
      System.debug('ENTERING DP PICKLIST');
        if(options != null  && !initialChangeAssetLoad && options.size() != 0)
        {
            c.put(fieldName, options[0].getValue());
        }
    }
    
    /**
     *
     */
    private void makeDependentPicklistSelections(String value, String fieldName)
    {
        if(value != null  && !initialChangeAssetLoad)
        {
            c.put(fieldName, value);
        }
    }
    
    /**
     * Move up to top with other attribute declarations?
     */
    public List<SelectOption> accountOptions {get; private set;}
    public List<SelectOption> contactOptions {get; private set;}
    //public List<SelectOption> entitlementOptions {get; private set;}
    public List<SelectOption> productFamilyOptions {get; private set;}
    public List<SelectOption> productLineOptions {get; private set;}
    public List<SelectOption> assetOptions{get; private set;}
    //public List<SelectOption> versionOptions{get; private set;}
    //public List<SelectOption> componentOptions {get; private set;}
    //public List<SelectOption> subComponentOptions {get; private set;}
   
   
    /**
     *
     */
    public PageReference saveOnly()
    {
        SavePoint sp = Database.setSavePoint();
        
        try
        {
            if (am == null) {
                if (isInternalUser) {
                    // Internal Users allowed to save cases without an account or contact
                    Database.DMLOptions dmo = new Database.DMLOptions();
                    dmo.assignmentRuleHeader.useDefaultRule = true;
                    c.setOptions(dmo);
                    upsert c;
                    
                    // Do we need to do anything else here? Apply default assignment rules, etc?
                    
                    // Redirect user to view ticket
                    //PageReference pr = new PageReference('/' + c.Id);
                    
                    //Redirect user to edit page
                    PageReference pr = new PageReference('/' + c.Id + '/e');
                    
                    return pr;
                }
                else {
                    // Account is required for Non-Internal Users (Support staff)
                    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Account is required'));
                    return null;
                }
            }
            else {
               // Are we creating a new Contact?
               System.debug('MM Selected:' + (String)c.ContactId);
               System.debug('MM Dummy:' + (String)dummyConID);
               if ((String)c.ContactId == (String)dummyConID) {
                     Contact con = new Contact(FirstName = conFirstName, LastName = conLastName, Email = conEmail, AccountId = c.AccountId);
                     insert con;
                     
                     c.ContactId = con.Id;
               }
               PageReference pr;
               if (!isPortal) {
                    pr = am.saveCase(c, caseComment, 'edit', useDefaultAssignmentRules, isChangeAsset, InstRec);
               }
               else {
                    pr = am.saveCase(c, caseComment, 'parent', useDefaultAssignmentRules, isChangeAsset, InstRec);
               }
               
               if (!isPortal && !isInternalUser && pr != null) {
                    // Support users - redirect to the edit page
                    // and return back to the ticket from there
                    String editPageRetURL = '/' + c.Id;
                    pr = new PageReference('/' + c.Id + '/e?retURL=' + editPageRetURL);
               }
               
               return pr;
            }
        }
        catch(DMLException dmle)
        {
            string dml = string.valueof(dmle);
            
            if(dml.contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'))
            {
                dml = dml.substringafter('FIELD_CUSTOM_VALIDATION_EXCEPTION, ');
                dml = dml.substringbefore(': []');
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.FATAL, 'Error: ' + dml)); // System.label.General_Error_On_Case+': '+dml));
                return null;
            
            }
            else
            {
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.FATAL, 'Error: ' + dmle)); // System.label.General_Error_On_Case+': '+dmle));
                Database.rollBack(sp);
                return null;
            }
        }
        catch(Exception exc)
        {
            string ex = string.valueOf(exc);
            
            if(ex.contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'))
            {
                ex = ex.substringafter('FIELD_CUSTOM_VALIDATION_EXCEPTION, ');
                ex = ex.substringbefore(': []');
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.FATAL, 'Error: ' + ex)); // System.label.General_Error_On_Case+': '+ex));
                Database.rollBack(sp);
                return null;
                
            }
            else
            {
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.FATAL, 'Error: ' + exc)); // System.label.General_Error_On_Case+': '+exc));
                Database.rollBack(sp);
                return null;
            }
        }
    }
    
    
    /**
     *
     */
    public Pagereference saveAndAttach()
    {
        SavePoint sp = Database.setSavePoint();
        
        try
        {
            if (am == null) {
                if (isInternalUser) {
                    // Internal Users allowed to save cases without an account or contact
                    upsert c;
                    
                    // Do we need to do anything else here? Apply default assignment rules, etc?
                    
                    // Redirect user to view ticket
                    //PageReference pr = new PageReference('/' + c.Id);
                    
                    //Redirect user to edit page
                    PageReference pr = new PageReference('/' + c.Id + '/e');
                    
                    return pr;
                }
                else {
                    // Account is required for Non-Internal Users (Support staff)
                    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Account is required'));
                    return null;
                }
            }
            else {
              // Are we creating a new Contact?
                if ((String)c.ContactId == (String)dummyConID) {
                     Contact con = new Contact(FirstName = conFirstName, LastName = conLastName, Email = conEmail, AccountId = c.AccountId);
                     insert con;
                     
                     c.ContactId = con.Id;
                }
                PageReference pr = am.saveCase(c, caseComment, 'attach', useDefaultAssignmentRules, false, InstRec);
               
                if (!isPortal && !isInternalUser && pr != null) {
                    // Support users - redirect to the attach page
                    // then the case edit page after that
                    // and return back to the ticket from the edit page
                    // Have to make sure the urls are properly encoded and double-encoded to properly be unencoded at each step
                    String editPageRetURL = '/' + c.Id;
                    String attachPageRetURL = '/' + c.Id + '/e?retURL=' + EncodingUtil.urlEncode(editPageRetURL, 'UTF-8');
                    String redirectURL = '/p/attach/NoteAttach?pid='+c.Id+'&parentname=&retURL=' + EncodingUtil.urlEncode(attachPageRetURL, 'UTF-8');
                    pr = new PageReference(redirectURL);
                }
                else if (isPortal && pr != null) {
                    // For portal users, redirect them to a custom VF page that allows them to
                    // save an attachment to a ticket (which they can't do using oob functionality because
                    // they don't have edit permission on tickets)
                    String redirectURL = '/apex/AttachmentUpload?pid='+c.Id;
                    pr = new PageReference(redirectURL);
                }
                
                return pr;
            }
        }
        catch(DMLException dmle)
        {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.FATAL, 'Error: '+dmle)); // System.label.General_Error_On_Case+': '+dmle));
            Database.rollBack(sp);
            return null;
        }
        catch(Exception exc)
        {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.FATAL, 'Error: '+exc)); // System.label.General_Error_On_Case+': '+exc));
            Database.rollBack(sp);
            return null;
        }
    }
    
    public PageReference saveAsset() {
        update c;
                    
        PageReference pr = new PageReference('/' + c.Id);
                    
        return pr;
    }
    
    public PageReference doCancel() {
        return this.thisStd.cancel();
    }
    
    /**
     * Stub method that can be called just to have the page reloaded
     *
     * @author  Lawrence Coffin <lawrence.coffin@cloudsherpas.com>
     * @since   May 5, 2013
     */
    public void refreshPage() {}
    
    public void showArticles() {
        this.showSuggestedArticles = true;
    }
    
/*
    public void refreshAccount()
    {
        if( !GenericServices.isNullOrEmpty(c.AccountID))
        {
            am = new AccountModel(new Account(id = c.AccountID));
            c.ContactID = null;
            loadData();
        }
        else
        {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.FATAL, System.label.No_Account_provided_Please_choose_an_Account_before_clicking_Go));
        }
    }
/**/
}