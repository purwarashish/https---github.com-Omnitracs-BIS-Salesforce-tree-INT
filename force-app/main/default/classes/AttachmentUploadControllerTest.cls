@isTest
public class AttachmentUploadControllerTest {
/*
    public static testMethod void runAllTestsWithoutLogo() {
        Partner_Support_Information__c psi = new Partner_Support_Information__c();
        psi.Partner_Account__c = '0015000000LGKdn';
        psi.Support_Email__c = 'xyz@gmail.com';
        psi.Support_Phone__c = '8586039700';
        psi.Support_Name__c = 'Test Partner Display Name';
        psi.Hours_Of_Service__c = '08:00 - 20:00 PST';
        psi.Logo__c = 'xxxxyyyyyzzzz';
        psi.Logo_Orientation__c = 'Portrait';
        
        insert psi;
        
        ApexPages.StandardController stdController = new ApexPages.StandardController(psi); 
        AttachmentUploadController auc = new AttachmentUploadController(stdController);   
        auc.initAll();
        auc.newLogo();
        auc.getCurrentLogoExists();

        try {
            auc.upload();
        }
        catch(Exception e) {
        }
                
        try {
            auc.editLogo();
        }
        catch(Exception e) {
        }
        
        auc.cancelEdit();
        auc.cancel();
        
        try {
            auc.commitLogo();
        }
        catch(Exception e) {
        }                
    }
*/
    public static testMethod void runAllTestsWithLogo() {
        Partner_Support_Information__c psi = new Partner_Support_Information__c();
        psi.Partner_Account__c = '0015000000LGKdn';
        psi.Support_Email__c = 'xyz@gmail.com';
        psi.Support_Phone__c = '8586039700';
        psi.Support_Name__c = 'Test Partner Display Name';
        psi.Hours_Of_Service__c = '08:00 - 20:00 PST';        
        psi.Logo_Orientation__c = 'Portrait';
        
        insert psi;
        
        Attachment a = new Attachment();
        a.parentId = psi.id;
        a.name = 'AAA';
        a.body = Blob.valueOf('BBB');
        insert a;
        
        psi.Logo__c = a.id;
        update psi;
        
        ApexPages.StandardController stdController = new ApexPages.StandardController(psi); 
        AttachmentUploadController auc = new AttachmentUploadController(stdController);   
        auc.initAll();
        auc.newLogo();

        try {
            auc.upload();
        }
        catch(Exception e) {
        }
                
        try {
            auc.editLogo();
        }
        catch(Exception e) {
        }
        
        auc.cancelEdit();
        auc.cancel();
        
        try {
            auc.commitLogo();
        }
        catch(Exception e) {
        }                
    }
}