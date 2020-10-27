public class ViewRequirement_Ext {

    private Requirements__c r;
    
    public List<System_Field__c> unassignedFields {get; set;}
    private List<System_Field__c> assignedFields;
    
    private List<Requirement_System_Field_Relationship__c> junctions;
    
    public List<SelectOption> unassignedFieldsList {get; set;}
    public List<SelectOption> assignedFieldsList {get; set;}
    
    public Boolean canAccess{get; private set;}
    
    public List<SelectOption> filterOptions {get; set;}
    public String selectedFilter {get; set;}

    public ViewRequirement_Ext(ApexPages.StandardController std) {
        this.r = (Requirements__c)std.getRecord();
        
        //TODO: Store this ID in a Custom Setting or admin config
        List<PermissionSetAssignment> permSets = [SELECT Id FROM PermissionSetAssignment WHERE AssigneeId =: UserInfo.getUserId() AND PermissionSetId = '0PSW000000009Xo'];
        if (permsets.size() == 1) {
            this.canAccess = true;
        }
        else {
            this.canAccess = false;
        }
        
        List<Schema.PicklistEntry> trackValues = System_Field__c.Object__c.getDescribe().getPicklistValues();
        filterOptions = new List<SelectOption>();
        //filterOptions.add(new SelectOption('All Tracks', 'All Tracks'));
        for (Schema.PicklistEntry pe : trackValues) {
            filterOptions.add(new SelectOption(pe.getValue(), pe.getLabel()));
        }
        if (filterOptions.size() > 0) {
            selectedFilter = filterOptions[0].getValue();
        }
        else {
            selectedFilter = 'All Objects';
        }
        
        unassignedFields = new List<System_Field__c>();
        assignedFields = new List<System_Field__c>();
        unassignedFieldsList = new List<SelectOption>();
        assignedFieldsList = new List<SelectOption>();
        if (selectedFilter != 'All Objects') {
            unassignedFields = [SELECT Id, Name FROM System_Field__c WHERE Id NOT IN (SELECT System_Field__c FROM Requirement_System_Field_Relationship__c WHERE Requirements__c =: this.r.Id) AND Object__c =: selectedFilter ORDER BY Name];
        }
        else {
            unassignedFields = [SELECT Id, Name FROM System_Field__c WHERE Id NOT IN (SELECT System_Field__c FROM Requirement_System_Field_Relationship__c WHERE Requirements__c =: this.r.Id) ORDER BY Name];
        }
        assignedFields = [SELECT Id, Name FROM System_Field__c WHERE Id IN (SELECT System_Field__c FROM Requirement_System_Field_Relationship__c WHERE Requirements__c =: this.r.Id) ORDER BY Name];
    
        for (System_Field__c f : unassignedFields) {
            unassignedFieldsList.add(new SelectOption(f.Id, f.Name));
        }
        
        for (System_Field__c f : assignedFields) {
            assignedFieldsList.add(new SelectOption(f.Id, f.Name));
        }
        
        junctions = new List<Requirement_System_Field_Relationship__c>();
        junctions = [SELECT Id, System_Field__c FROM Requirement_System_Field_Relationship__c WHERE Requirements__c = :this.r.Id];
    }

    public PageReference doSave() {
        List<Requirement_System_Field_Relationship__c> junctionsToInsert = new List<Requirement_System_Field_Relationship__c>();
        List<Requirement_System_Field_Relationship__c> junctionsToDelete = new List<Requirement_System_Field_Relationship__c>();
        
        if (junctions.size() > 0) {
            delete junctions;
            junctions.clear();
        }
        
        // Determine Requirements that have been assigned
        for (SelectOption f : assignedFieldsList) {
            junctionsToInsert.add(new Requirement_System_Field_Relationship__c(System_Field__c = f.getValue(), Requirements__c = this.r.Id));
        }
        
        if (junctionsToInsert.size() > 0) {
            insert junctionsToInsert;
        }
        
        PageReference p = new PageReference('/apex/ViewRequirement?id=' + r.Id);
        p.setRedirect(true);
        
        return p;
    }

    public PageReference refreshFilter() {
        if (selectedFilter != 'All Objects') {
            unassignedFields = [SELECT Id, Name FROM System_Field__c WHERE Id NOT IN (SELECT System_Field__c FROM Requirement_System_Field_Relationship__c WHERE Requirements__c =: this.r.Id) AND Object__c =: selectedFilter ORDER BY Name];
        }
        else {
            unassignedFields = [SELECT Id, Name FROM System_Field__c WHERE Id NOT IN (SELECT System_Field__c FROM Requirement_System_Field_Relationship__c WHERE Requirements__c =: this.r.Id) ORDER BY Name];
        }
        
        this.unassignedFieldsList = new List<SelectOption>();
        for (System_Field__c f : unassignedFields) {
            Boolean found = false;
            for (SelectOption f2 : assignedFieldsList) {
                if (f2.getValue() == f.Id) {
                    found = true;
                }
            }
            if (!found) {
                this.unassignedFieldsList.add(new SelectOption(f.Id, f.Name));
            }
        }
        
        return null;
    }

}