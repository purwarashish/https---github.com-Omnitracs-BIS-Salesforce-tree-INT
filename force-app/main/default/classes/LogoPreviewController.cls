public with sharing class LogoPreviewController {
    public Partner_Support_Information__c masterRecord {get; set;}
    public LogoPreviewController(ApexPages.StandardController stdController) {
        Id recordId = stdController.getRecord().Id;
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
    }
}