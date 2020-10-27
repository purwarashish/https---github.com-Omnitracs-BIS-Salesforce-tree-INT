public class ViewUserStory_Ext {

    private User_Story__c s;
    
    public List<Requirements__c> unassignedReqs {get; set;}
    private List<Requirements__c> assignedReqs;
    
    private List<User_Story_Requirement__c> junctions;
    
    public List<SelectOption> unassignedReqsList {get; set;}
    public List<SelectOption> assignedReqsList {get; set;}
    
    public List<SelectOption> filterOptions {get; set;}
    public String selectedFilter {get; set;}
    
    public Boolean canAccess {get; private set;}

    public ViewUserStory_Ext(ApexPages.StandardController std) {
        this.s = (User_Story__c)std.getRecord();
        
        //TODO: Store this ID in a Custom Setting or admin config
        List<PermissionSetAssignment> permSets = [SELECT Id FROM PermissionSetAssignment WHERE AssigneeId =: UserInfo.getUserId() AND PermissionSetId = '0PSW000000009Xo'];
        if (permsets.size() == 1) {
            this.canAccess = true;
        }
        else {
            this.canAccess = false;
        }
        
        unassignedReqs = new List<Requirements__c>();
        assignedReqs = new List<Requirements__c>();
        unassignedReqsList = new List<SelectOption>();
        assignedReqsList = new List<SelectOption>();
        
        unassignedReqs = [SELECT Id, Title__c FROM Requirements__c WHERE Id NOT IN (SELECT Requirement__c FROM User_Story_Requirement__c WHERE User_Story__c =: this.s.Id)];

        assignedReqs = [SELECT Id, Title__c FROM Requirements__c WHERE Id IN (SELECT Requirement__c FROM User_Story_Requirement__c WHERE User_Story__c =: this.s.Id)];
    
        for (Requirements__c r : unassignedReqs) {
            unassignedReqsList.add(new SelectOption(r.Id, r.Title__c));
        }
        
        for (Requirements__c r : assignedReqs) {
            assignedReqsList.add(new SelectOption(r.Id, r.Title__c));
        }
        
        junctions = new List<User_Story_Requirement__c>();
        junctions = [SELECT Id, Requirement__c FROM User_Story_Requirement__c WHERE User_Story__c = :this.s.Id];
        
        List<Schema.PicklistEntry> trackValues = Requirements__c.Track__c.getDescribe().getPicklistValues();
        filterOptions = new List<SelectOption>();
        filterOptions.add(new SelectOption('All Tracks', 'All Tracks'));
        for (Schema.PicklistEntry pe : trackValues) {
            filterOptions.add(new SelectOption(pe.getValue(), pe.getLabel()));
        }
        selectedFilter = 'All Tracks';
    }

    public PageReference doSave() {
        List<User_Story_Requirement__c> junctionsToInsert = new List<User_Story_Requirement__c>();
        List<User_Story_Requirement__c> junctionsToDelete = new List<User_Story_Requirement__c>();
        
        if (junctions.size() > 0) {
            delete junctions;
            junctions.clear();
        }
        
        // Determine Requirements that have been assigned
        for (SelectOption req : assignedReqsList) {
            junctionsToInsert.add(new User_Story_Requirement__c(Requirement__c = req.getValue(), User_Story__c = this.s.Id));
        }
        
        if (junctionsToInsert.size() > 0) {
            insert junctionsToInsert;
        }
        
        PageReference p = new PageReference('/apex/ViewUserStory?id=' + s.Id);
        p.setRedirect(true);
        
        return p;
    }

    public PageReference refreshFilter() {
        if (selectedFilter != 'All Tracks') {
            unassignedReqs = [SELECT Id, Title__c FROM Requirements__c WHERE Id NOT IN (SELECT Requirement__c FROM User_Story_Requirement__c WHERE User_Story__c =: this.s.Id) AND Track__c =: selectedFilter];
        }
        else {
            unassignedReqs = [SELECT Id, Title__c FROM Requirements__c WHERE Id NOT IN (SELECT Requirement__c FROM User_Story_Requirement__c WHERE User_Story__c =: this.s.Id)];
        }
        
        this.unassignedReqsList = new List<SelectOption>();
        for (Requirements__c r : unassignedReqs) {
            Boolean found = false;
            for (SelectOption r2 : assignedReqsList) {
                if (r2.getValue() == r.Id) {
                    found = true;
                }
            }
            if (!found) {
                this.unassignedReqsList.add(new SelectOption(r.Id, r.Title__c));
            }
        }
        
        return null;
    }

}