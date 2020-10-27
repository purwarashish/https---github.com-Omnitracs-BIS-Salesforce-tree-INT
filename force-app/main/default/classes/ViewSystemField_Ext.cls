public class ViewSystemField_Ext {

    private System_Field__c f;
    
    public List<Source_Field__c> unassignedFields {get; set;}
    private List<Source_Field__c> assignedFields;
    
    public List<SelectOption> unassignedFieldsList {get; set;}
    public List<SelectOption> assignedFieldsList {get; set;}
    
    public List<SelectOption> filterOptions {get; set;}
    public List<SelectOption> filterOptions2 {get; set;}
    public String selectedFilter {get; set;}
    public String selectedFilter2 {get; set;}
    
    public Boolean canAccess {get; private set;}

    public ViewSystemField_Ext(ApexPages.StandardController std) {
        this.f = (System_Field__c)std.getRecord();
        
        //TODO: Store this ID in a Custom Setting or admin config
        List<PermissionSetAssignment> permSets = [SELECT Id FROM PermissionSetAssignment WHERE AssigneeId =: UserInfo.getUserId() AND PermissionSetId = '0PSR0000000CkJW'];
        if (permsets.size() == 1) {
            this.canAccess = true;
        }
        else {
            this.canAccess = false;
        }
        
        List<Schema.PicklistEntry> sourceValues = Source_Field__c.Source_System__c.getDescribe().getPicklistValues();
        filterOptions = new List<SelectOption>();
        //filterOptions.add(new SelectOption('All Sources', 'All Sources'));
        for (Schema.PicklistEntry pe : sourceValues) {
            filterOptions.add(new SelectOption(pe.getValue(), pe.getLabel()));
        }
        if (filterOptions.size() > 0) {
            selectedFilter = filterOptions[0].getValue();
        }
        else {
            selectedFilter = 'All Sources';
        }
        
        List<Schema.PicklistEntry> sourceValues2 = Source_Field__c.Source_Object__c.getDescribe().getPicklistValues();
        filterOptions2 = new List<SelectOption>();
        //filterOptions2.add(new SelectOption('All Objects', 'All Objects'));
        for (Schema.PicklistEntry pe : sourceValues2) {
            filterOptions2.add(new SelectOption(pe.getValue(), pe.getLabel()));
        }
        if (filterOptions2.size() > 0) {
            selectedFilter2 = filterOptions2[0].getValue();
        }
        else {
            selectedFilter2 = 'All Objects';
        }
        
        unassignedFields = new List<Source_Field__c>();
        assignedFields = new List<Source_Field__c>();
        unassignedFieldsList = new List<SelectOption>();
        assignedFieldsList = new List<SelectOption>();
        
        //unassignedFields = [SELECT Id, Field_Name__c, Source_System__c FROM Source_Field__c WHERE System_Field__c = null ORDER BY Field_Name__c];
        
        if (selectedFilter != 'All Sources' && selectedFilter2 != 'All Objects') {
            unassignedFields = [SELECT Id, Field_Name__c, Source_System__c FROM Source_Field__c WHERE System_Field__c = null AND Source_System__c =: selectedFilter AND Source_Object__c =: selectedFilter2];
        }
        else if (selectedFilter != 'All Sources' && selectedFilter2 == 'All Objects') {
            unassignedFields = [SELECT Id, Field_Name__c, Source_System__c FROM Source_Field__c WHERE System_Field__c = null AND Source_System__c =: selectedFilter];
        }
        else if (selectedFilter == 'All Sources' && selectedFilter2 != 'All Objects') {
            unassignedFields = [SELECT Id, Field_Name__c, Source_System__c FROM Source_Field__c WHERE System_Field__c = null AND Source_Object__c =: selectedFilter2];
        }
        else {
            unassignedFields = [SELECT Id, Field_Name__c, Source_System__c FROM Source_Field__c WHERE System_Field__c = null];
        }

        assignedFields = [SELECT Id, Field_Name__c, Source_System__c FROM Source_Field__c WHERE System_Field__c =: this.f.id ORDER BY Field_Name__c];
    
        for (Source_Field__c sf : unassignedFields) {
            unassignedFieldsList.add(new SelectOption(sf.Id, sf.Field_Name__c));
        }
        
        for (Source_Field__c sf : assignedFields) {
            assignedFieldsList.add(new SelectOption(sf.Id, sf.Field_Name__c));
        }
        
        
    }

    public PageReference doSave() {
        Map<Id, Source_Field__c> fieldsToUpdateMap = new Map<Id, Source_Field__c>();
        
        // Determine Source Fields that have been assigned
        for (SelectOption sf : assignedFieldsList) {
            fieldsToUpdateMap.put(sf.getValue(), new Source_Field__c(Id = sf.getValue(), System_Field__c = this.f.Id));
        }
        
        // Determine if any Source Fields have been de-assigned
        for (Source_Field__c sf : [SELECT Id FROM Source_Field__c WHERE System_Field__c =: this.f.Id AND Id NOT IN :fieldsToUpdateMap.keySet()]) {
            fieldsToUpdateMap.put(sf.Id, new Source_Field__c(Id = sf.Id, System_Field__c = null));
        }
        
        if (fieldsToUpdateMap.values().size() > 0) {
            update fieldsToUpdateMap.values();
        }
        
        PageReference p = new PageReference('/apex/ViewSystemField?id=' + f.Id);
        p.setRedirect(true);
        
        return p;
    }

    public PageReference refreshFilter() {
        if (selectedFilter != 'All Sources' && selectedFilter2 != 'All Objects') {
            unassignedFields = [SELECT Id, Field_Name__c, Source_System__c FROM Source_Field__c WHERE System_Field__c = null AND Source_System__c =: selectedFilter AND Source_Object__c =: selectedFilter2];
        }
        else if (selectedFilter != 'All Sources' && selectedFilter2 == 'All Objects') {
            unassignedFields = [SELECT Id, Field_Name__c, Source_System__c FROM Source_Field__c WHERE System_Field__c = null AND Source_System__c =: selectedFilter];
        }
        else if (selectedFilter == 'All Sources' && selectedFilter2 != 'All Objects') {
            unassignedFields = [SELECT Id, Field_Name__c, Source_System__c FROM Source_Field__c WHERE System_Field__c = null AND Source_Object__c =: selectedFilter2];
        }
        else {
            unassignedFields = [SELECT Id, Field_Name__c, Source_System__c FROM Source_Field__c WHERE System_Field__c = null];
        }
        
        this.unassignedFieldsList = new List<SelectOption>();
        for (Source_Field__c sf : unassignedFields) {
            Boolean found = false;
            for (SelectOption sf2 : assignedFieldsList) {
                if (sf2.getValue() == sf.Id) {
                    found = true;
                }
            }
            if (!found) {
                this.unassignedFieldsList.add(new SelectOption(sf.Id, sf.Field_Name__c));
            }
        }
        
        return null;
    }

}