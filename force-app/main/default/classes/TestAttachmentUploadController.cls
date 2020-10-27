@isTest(SeeAllData=true)
private class TestAttachmentUploadController{
    private static testMethod void testAttachUpload(){
        list<Account> lstAcct = [select id from Account where isPartner=true limit 1];
        system.debug('@@@@@lstAcct'+lstAcct);
        Partner_Support_Information__c partSuppInfo = new Partner_Support_Information__c ();
        partSuppInfo.Partner_Account__c = lstAcct[0].id;
        partSuppInfo.Logo_Orientation__c = 'Landscape';
        partSuppInfo.Support_Email__c = 'c_agang@qualcomm.com';
        insert partSuppInfo;
        
         Custom_Report__c customReport = new  Custom_Report__c();
         customReport.name = 'somename';
         customReport.Account__c = lstAcct[0].id;
         insert customReport;
        
        Attachment attch = new Attachment();
        attch.ParentId = partSuppInfo.id;
        Blob b = Blob.valueOf('Test Data');  
        attch.Name = 'Test Attachment for Parent';  
        attch.Body = b;  
        insert attch;
        
         Attachment attch1 = new Attachment();
        attch1.ParentId = customReport.id;
        Blob b1 = Blob.valueOf('Test Data');  
        attch1.Name = 'Test Attachment for Parent';  
        attch1.Body = b1;  
        insert attch1;
        
        
        partSuppInfo.logo__c = attch.id;
        
        update partSuppInfo;
        ApexPages.StandardController std = new ApexPages.StandardController(partSuppInfo);
        AttachmentUploadController  auc = new AttachmentUploadController(std);
        auc.initAll();
        auc.commitLogo();
        
        auc.upload();
        auc.editLogo();
        auc.saveEdit();
        auc.cancel();
        auc.cancelEdit();
        auc.newLogo();
        
        auc.getCurrentLogoExists();
        partSuppInfo.logo__c = '';
        
        update partSuppInfo;
        ApexPages.StandardController std1 = new ApexPages.StandardController(partSuppInfo);
        AttachmentUploadController  auc1 = new AttachmentUploadController(std1);
        auc1.initAll();
        auc1.upload();
        
        
        
    } 
}