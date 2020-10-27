public with sharing class AttachmentUploadController {
    public Partner_Support_information__c masterRecord {get; set;}
    public Attachment logo {get; set;}
    public Attachment currentLogo {get; set;}   
    public String editableName {get; set;}       
    public String currentLogoOrientation {get; set;} 
    public Partner_Support_Information__c editablePSI {get; set;}
    public boolean renderBlock1 {get; set;}
    public boolean renderBlock2 {get; set;}
    public boolean renderBlock3 {get; set;}
    private Id recordId;

    public void initAll() {
        List<Partner_Support_Information__c> lstPSI = null;
        lstPSI = [
                     SELECT 
                        id, 
                        logo__c,
                        logo_orientation__c
                     FROM 
                        Partner_Support_Information__c 
                     WHERE 
                        id = :recordId
                     LIMIT
                         1
                  ];
        masterRecord = lstPSI[0];          
                          
        logo = new Attachment();
        
        List<Attachment> lstLogo = null;        
        List<Attachment> lstLogoDel = new List<Attachment>();
        lstLogo = [
                     SELECT 
                        id, 
                        name, 
                        parentId 
                     FROM 
                        ATTACHMENT 
                     WHERE 
                        parentId = :masterRecord.Id
                  ];
        currentLogo = null;
        currentLogoOrientation = '';
        for(Attachment a : lstLogo) {
            if(a.id == masterRecord.logo__c) {
                currentLogo = a;
                currentLogoOrientation = masterRecord.logo_orientation__c;
            }
            else {
                lstLogoDel.add(a);
            }
        }
        if(0 != lstLogoDel.size()) {
            try {
                delete lstLogoDel;
            }
            catch(DMLException e) {
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Error fetching logo data. Please try later.'));
            }
        }
        
        renderBlock1 = false;        
        renderBlock2 = true;
        renderBlock3 = false;
    }
    
    public AttachmentUploadController(ApexPages.StandardController stdController) {
        recordId = stdController.getRecord().Id;
    }

    public boolean getCurrentLogoExists() {
        return (null != currentLogo);
    }
    
    public PageReference upload() { 
        logo.OwnerId = UserInfo.getUserId();
        logo.ParentId = masterRecord.Id;
        logo.IsPrivate = false;
        
        List<Attachment> lstLogo = null;
        lstLogo = [
                     SELECT 
                        id, 
                        name, 
                        parentId 
                     FROM 
                        ATTACHMENT 
                     WHERE 
                        parentId = :masterRecord.Id
                     AND
                        id != :masterRecord.logo__c
                  ];
                           
        SavePoint sp = Database.setSavepoint();
        try {
            if( (null != lstLogo) && (0 < lstLogo.size()) ) {
                delete lstLogo;
            }
            insert logo;
        } 
        catch (DMLException e) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Error uploading logo'));
            Database.rollback(sp);
            return null;        
        } 

        lstLogo = null;
        lstLogo = [
                     SELECT 
                        id, 
                        name, 
                        parentId 
                     FROM 
                        ATTACHMENT 
                     WHERE 
                        parentId = :masterRecord.Id
                     AND
                        id != :masterRecord.logo__c
                     LIMIT
                        1                     
                  ];
        currentLogo = lstLogo[0];
        currentLogoOrientation = masterRecord.logo_orientation__c;
        logo = new Attachment();

        renderBlock1 = false;
        renderBlock2 = true;
        renderBlock3 = false;
        return null;
    } 
    
    public PageReference newLogo() {
        renderBlock1 = true;
        renderBlock2 = false;
        renderBlock3 = false;
        return null;
    }

    public PageReference editLogo() {
        editableName = currentLogo.name;
        editablePSI = new Partner_Support_Information__c();
        editablePSI.logo_orientation__c = currentLogoOrientation;
        
        renderBlock1 = false;
        renderBlock2 = false;
        renderBlock3 = true;
        return null;
    }
    
    public PageReference saveEdit() {        
        currentLogoOrientation = editablePSI.logo_orientation__c;
        currentLogo.name = editableName;
        try {            
            update currentLogo;
        } 
        catch (DMLException e) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Error committing logo'));
            return null;        
        }    
        renderBlock1 = false;
        renderBlock2 = true;
        renderBlock3 = false;
        return null;
    }    

    public PageReference cancelEdit() {
        renderBlock1 = false;
        renderBlock2 = true;
        renderBlock3 = false;
        return null;
    }
    
    public PageReference cancel() {
        renderBlock1 = false;
        renderBlock2 = true;
        renderBlock3 = false;
        return null;
    }
        
    public PageReference commitLogo() {
        if(null == currentLogo) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Logo does not exist.'));        
            return null;
        }
        masterRecord.logo__c = currentLogo.id;
        masterRecord.logo_orientation__c = currentLogoOrientation;
        
        try {            
            update masterRecord;
        } 
        catch (DMLException e) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Error committing logo'));
            return null;        
        }
        
        return null;
    }    
}