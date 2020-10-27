global class ShippingEstimateBatch implements Database.Batchable<SBQQ__Quote__c>, Database.Stateful, Schedulable{
    
    global String mailCsvContent = 'Quote,Shipping Lines Creation Status\n';
    
    global ShippingEstimateBatch(){}
    
    // Start Method
    global List<SBQQ__Quote__c> start(Database.BatchableContext BC){
        DateTime modifiedTime = DateTime.now().addHours(-24);
        List<SBQQ__QuoteLine__c> quoteLines = [Select Id, Name, SBQQ__Quote__c, SBQQ__Product__r.Product_Type__c from SBQQ__QuoteLine__c where 
        (LastModifiedDate >= :modifiedTime OR SBQQ__Quote__r.LastModifiedDate >= :modifiedTime) AND SBQQ__EffectiveQuantity__c > 0 AND 
        SBQQ__Quote__r.SBQQ__Opportunity2__r.StageName NOT IN ('Closed Won', 'Closed Lost') AND SBQQ__Quote__r.SBQQ__Primary__c = TRUE AND 
        Quote_Line_Type__c IN ('New', 'Add-On') AND SBQQ__Quote__r.SBQQ__Opportunity2__r.RecordType.Name NOT IN ('Data Migration', 'Services Only')];
        Set<Id> quoteIds = new Set<Id>();
        for(SBQQ__QuoteLine__c quoteLine: quoteLines){
            quoteIds.add(quoteLine.SBQQ__Quote__c);
        }
        List<SBQQ__Quote__c> quotes = [Select Id, Name, SBQQ__Account__c, SBQQ__Opportunity2__c, Delivery_Schedule__c, Schedule_Type__c, 
        Expected_Shipment_Start__c from SBQQ__Quote__c where Id in :quoteIds];
        return quotes;
    }
  
    // Execute Logic
    global void execute(Database.BatchableContext BC, List<SBQQ__Quote__c> quoteList){
        for(SBQQ__Quote__c quote : quoteList){
            String status = ShippingEstimateUtils.createHardwareShippingLines(quote);
            mailCsvContent += quote.Name + ',' + status + '\n';
        }
    }

    global void execute(SchedulableContext sc) {
        Database.executeBatch(this, 10);
    }
 
    global void finish(Database.BatchableContext BC){
        // Logic to be Executed at finish
        System.debug('Batch Execution of ShippingEstimate Completed');
        String sEmailBody = 'Please see the attached file for details of the Shipping Lines creation automated batch processing.';
        Blob csvBlob = Blob.valueOf(mailCsvContent);
        Messaging.EmailFileAttachment csvAttc = new Messaging.EmailFileAttachment();
        csvAttc.setFileName('ShippingLinesCreation_Result.csv');
        csvAttc.setContentType('text/csv');
        csvAttc.setBody(csvBlob);
        //Create Email      
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'omnitracs.sfdc.noreply@omnitracs.com'];
        if(owea.size() > 0){
            email.setOrgWideEmailAddressId(owea.get(0).Id);
        }else{
            email.setSenderDisplayName('Shipping Lines Creation Batch Job Status');
        }
        String[] toAddresses = new List<String> {UserInfo.getUserEmail()};
        String[] ccAddresses = new List<String> {'yarafat@omnitracs.com'};
        email.setSubject('Shipping Lines Creation Batch Job Status');       
        email.setToAddresses(toAddresses);
        email.setCcAddresses(ccAddresses);        
        email.setFileAttachments(new Messaging.EmailFileAttachment[]{csvAttc});
        email.setPlainTextBody(sEmailBody);
        Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
    }
}