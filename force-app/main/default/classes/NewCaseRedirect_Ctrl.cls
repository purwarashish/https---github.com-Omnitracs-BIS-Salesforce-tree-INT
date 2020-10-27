public class NewCaseRedirect_Ctrl {

    public String commCaseRT;
    private ApexPages.StandardController controller;
    public String retURL {get; set;}
    public String saveNewURL {get; set;}
    public String rType {get; set;}
    public String cancelURL {get; set;}
    public String ent {get; set;}
    public String confirmationToken {get; set;}
    public String accountID {get; set;}
    public String contactID {get; set;}
    public String accountID2 {get; set;}
    public String contactID2 {get; set;}
    public String accountName {get; set;}
    public String contactName {get; set;}
    public Boolean isPortal {get; set;}
    public String busUnit {get; set;}
    public String def_parent_id {get; set;}
    public Id caseId {get; set;}
    
    
    public NewCaseRedirect_Ctrl(ApexPages.StandardController std) {
      // Make sure we are using only the first 15 characters - for proper matching, test checks, etc.
        commCaseRT = SystemIds__c.getInstance().RecordTypeId_Case_CustomerCommunity__c.substring(0,15);
        
        this.controller = std;
        
        caseId = ApexPages.currentPage().getParameters().get('Id');
        retURL = ApexPages.currentPage().getParameters().get('retURL');
        def_parent_id = ApexPages.currentPage().getParameters().get('def_parent_id');
        cancelURL = ApexPages.currentPage().getParameters().get('cancelURL');
        ent = ApexPages.currentPage().getParameters().get('ent');
        confirmationToken = ApexPages.currentPage().getParameters().get('_CONFIRMATIONTOKEN');
        saveNewURL = ApexPages.currentPage().getParameters().get('save_new_url');
        accountID2 = ApexPages.currentPage().getParameters().get('def_account_id');
        contactID2 = ApexPages.currentPage().getParameters().get('def_contact_id');
        accountName = ApexPages.currentPage().getParameters().get('cas4');
        contactName = ApexPages.currentPage().getParameters().get('cas3');
        accountID = ApexPages.currentPage().getParameters().get('cas4_lkid');
        contactID = ApexPages.currentPage().getParameters().get('cas3_lkid');
        
        //
        // Get the selected (or default) record type id
        //
        rType = ApexPages.currentPage().getParameters().get('RecordType');
        
        if (rType == null) {
            // This user did not go through the record type selection page, so they must
            // have just a single default record type. Look that up.
            Schema.DescribeSObjectResult R = Case.SObjectType.getDescribe();
            List<Schema.RecordTypeInfo> RTs = R.getRecordTypeInfos();
            for (Schema.RecordTypeInfo rt : RTs) {
              if (rt.isDefaultRecordTypeMapping()) {
//                System.debug('Using default record type id: ' + rt.getRecordTypeId());
                // Only use the first 15 characters - for proper matching, test checks, etc.
                rType = String.valueOf(rt.getRecordTypeId()).substring(0,15);
              }
            }
        }
        
//        System.debug('RECORD TYPE ID: ' + rType);
        
        /** @todo  Move all of this code into a 'CurrentUser' class that has the logic in one place to determine whether a user is a portal user or not. PortalUser class could be an extension of CurrentUser */
        User u = [Select Id, Profile.UserLicense.LicenseDefinitionKey, ContactID, Contact.AccountID, Business_Unit__c from User where id= :UserInfo.getUserId()];
//        isPortal =    u.Profile.UserLicense.LicenseDefinitionKey == 'PID_Customer_Portal_Standard'
//                   || u.Profile.UserLicense.LicenseDefinitionKey == 'PID_Customer_Portal_Basic';
        isPortal = (u.ContactId != null);
        busUnit = u.Business_Unit__c;
    }
    
    public PageReference doRedirect() {
        PageReference returnURL;
        
        if (isPortal) {
            returnURL = new PageReference('/apex/Case');
        }
        else if (rType.contains(SystemIds__c.getInstance().RecordTypeId_Case_CallCenter__c) && (busUnit != 'Omnitracs US' && busUnit != 'Roadnet' && busUnit != 'Omnitracs Canada')) {
            returnURL = new PageReference('/apex/Case');
        }
        else {
            returnURL = new PageReference('/500/e');
        }
        
        if (def_parent_id != null) {
          returnURL.getParameters().put('def_parent_id', def_parent_id);
        }
        if (accountID != null){
            returnURL.getParameters().put('cas4', accountName);
            returnURL.getParameters().put('cas4_lkid', accountID);
        }
        if (contactID != null){
            returnURL.getParameters().put('cas3', contactName);
            returnURL.getParameters().put('cas3_lkid', contactID);
        }
        if (accountID2 != null){
            //returnURL.getParameters().put('def_account_id', accountName);
            returnURL.getParameters().put('def_account_id', accountID2);
        }
        if (contactID2 != null){
            //returnURL.getParameters().put('def_contact_id', contactName);
            returnURL.getParameters().put('def_contact_id', contactID2);
        }
        if (caseId != null) {
            returnURL.getParameters().put('id', caseId);
        }
        if (busUnit != null) {
            returnURL.getParameters().put(SystemIds__c.getInstance().FieldId_Case_BusinessUnit__c, busUnit);
        }
        
        returnURL.getParameters().put('retURL', retURL);
        returnURL.getParameters().put('RecordType', rType);
        returnURL.getParameters().put('cancelURL', cancelURL);
        returnURL.getParameters().put('ent', ent);
        returnURL.getParameters().put('_CONFIRMATIONTOKEN', confirmationToken);
        returnURL.getParameters().put('save_new_url', saveNewURL);
        returnURL.getParameters().put('nooverride', '1');
        
        returnURL.setRedirect(true);
        return returnURL;
    }

}