/*********************************************************************
Name    : OpportunityUtils2
Author  : Rittu Roy
Date    : 1/19/2016
Usage   : Utility class for all opportunity related code

*********************************************************************/

public without sharing class OpportunityUtils2{    
    public static boolean updateForecastDatesRunOnce = false;//To prevent recursive run of method updateForecastDates
    public static boolean checkDirectSalesOnboardingCall = false;//To prevent recursive run of method updateForecastDates
    
    /*When close date is changed on any open Opportunity, then the Shipment Dates of the Shipment Forecast 
    records associated with the Primary Quote (via the Quote Product) would be updated by the same number of days*/
    public static void updateForecastDates(Map<Id, Opportunity> newMap, Map<Id, Opportunity> oldMap) {
        /*List<Shipment_Forecast__c> shipmentsToUpdate = new List<Shipment_Forecast__c> ();
        List<Id> changedOppIds = new List<Id> ();
        List<Shipment_Forecast__c> shipmentForecasts = new List<Shipment_Forecast__c>();
        updateForecastDatesRunOnce = true;
            
        //Get all Opportunity Id's whose close Dates Changed
        for (Opportunity newOpp : newMap.values()){
            Opportunity oldOpp = oldMap.get(newOpp.Id);
        
            //compare the old and new Close Dates
            if (newOpp.CloseDate != oldOpp.CloseDate){
                changedOppIds.add(newOpp.Id);
            }
        }
            
        // Gets shipment forecast records which are related to opportunities whose close date is changed
        if (!changedOppIds.isEmpty()){
            shipmentForecasts = [SELECT ID, Quote_Product__r.Quote__r.Opportunity__c,Shipment_Date__c
                                 FROM Shipment_Forecast__c 
                                 WHERE (Quote_Product__r.Quote__r.Opportunity__c IN:changedOppIds
                                        AND Quote_Product__r.Quote__r.Is_Primary__c=TRUE
                                        AND Shipped__c=FALSE) LIMIT 50000];
        }
        
        for (Shipment_Forecast__c sf : shipmentForecasts) {
            Integer dateChange; //Number of days between new close date and old close date
            Opportunity oldOpp = oldMap.get(sf.Quote_Product__r.Quote__r.Opportunity__c);
            Opportunity newOpp = newMap.get(sf.Quote_Product__r.Quote__r.Opportunity__c);
   
            //Gets the number of days that the Close Date has changed. Adds it to shipment forecast date
            if (oldOpp.CloseDate != null && newOpp.CloseDate !=null && sf.Shipment_Date__c != null){
                dateChange = oldOpp.CloseDate.daysBetween(newOpp.CloseDate);
                sf.Shipment_Date__c = sf.Shipment_Date__c + dateChange; //new shipment date
                shipmentsToUpdate.add(sf);                   
            }
        }
            
        //update the shipment records
        if (!shipmentsToUpdate.isEmpty()){
            try{
                update shipmentstoUpdate;
            }Catch(Exception e){System.debug(e.getMessage());}
        }*/
    }
    
    //Calling Unity Direct sales onboarding service when the Opportunity is Closed Won
    public static void callUnityDirectSalesOnboardService(List<Opportunity> newOppList, Map<Id, Opportunity> oldOppMap){
        Set<Id> quoteIds = new Set<Id>();
        Set<Id> quoteLineIds = new Set<Id>();
        Set<Id> accountIds = new Set<Id>();
        
        for (Opportunity newOpp : newOppList) 
        {
            Opportunity oldOpp = oldOppMap.get(newOpp.Id);
            if(newOpp.stageName == 'Closed Won' && newOpp.stageName != oldOpp.stageName && 
                String.isNotBlank(newOpp.Type) && String.isNotBlank(newOpp.SBQQ__PrimaryQuote__c)){
                    quoteIds.add(newOpp.SBQQ__PrimaryQuote__c);
                    accountIds.add(newOpp.accountId);
            }
        }
        
        if(quoteIds.size() > 0){
            checkDirectSalesOnboardingCall = true;
            Map<Id, Account> accountMap = new Map<Id, Account> ([select Id, (select Id from contacts) from Account where Id in :accountIds]);
            List<String> allowedSoftwareSubTypes = new List<String> { 'Service Plans', 'Bundle', 'Applications' };
            for(SBQQ__Quote__c qte : ([select Id, SBQQ__Account__c, SBQQ__Account__r.AGUID__c, SBQQ__Opportunity2__r.Type, SBQQ__PrimaryContact__c, 
                                              (select Id, Name, SBQQ__RequiredBy__c, Product_Sub_Type__c, Product_Line__c, SBQQ__ProductCode__c, Is_OT1__c from SBQQ__LineItems__r where  
                                                      (Business_Unit__c = 'Omnitracs US' OR Business_Unit__c = 'XRS Corporation') and Product_Type__c = 'Software' and SBQQ__EffectiveQuantity__c > 0) 
                                         from SBQQ__Quote__c where Id in :quoteIds and SBQQ__Account__r.Primary_Business_Unit__c = 'Omnitracs Domestic'])){
                quoteLineIds = new Set<Id>();
                Boolean callUnityApi = false;
                if(qte.SBQQ__Opportunity2__r.Type == 'New Customer' && String.isBlank(qte.SBQQ__Account__r.AGUID__c)){
                    callUnityApi = true;
                }else if(qte.SBQQ__Opportunity2__r.Type == 'Existing Customer'){
                    for(SBQQ__QuoteLine__c ql : qte.SBQQ__LineItems__r){
                        if(ql.Is_OT1__c)
                            callUnityApi = true;
                    }
                }
                Boolean hasAllowedSoftwareSubTypes = false;
                Boolean hasMultiplePL = false;
                String qlPL = '';
                String eobrSP = '';
                if(callUnityApi && qte.SBQQ__LineItems__r != null && qte.SBQQ__LineItems__r.size() > 0){
                    for(SBQQ__QuoteLine__c ql : qte.SBQQ__LineItems__r){
                        if(String.isNotBlank(ql.SBQQ__RequiredBy__c) || Test.isRunningTest()){
                            if(allowedSoftwareSubTypes.contains(ql.Product_Sub_Type__c)){
                                hasAllowedSoftwareSubTypes = true;
                                if(String.isNotBlank(ql.SBQQ__ProductCode__c) && ql.SBQQ__ProductCode__c.contains('EOBR')){
                                    eobrSP = ql.Id;
                                    System.debug('**************IS EOBR service plan ***************');
                                }
                                System.debug('**************has Allowed Software SubTypes ***************');
                            }
                            
                        }
                        else{
                            qlPL = String.isBlank(qlPL)?ql.Product_Line__c:qlPL;
                            if(qlPL != ql.Product_Line__c){
                                hasMultiplePL = true;
                                System.debug('**************has multiple product lines ***************');
                            }
                        }
                    }
                }
                
                System.debug('**************has multiple product lines -- '+hasMultiplePL+' -- has Allowed Software SubTypes -- '+hasAllowedSoftwareSubTypes+' -- is EOBR plan -- '+eobrSP);
                if(hasAllowedSoftwareSubTypes && !hasMultiplePL){
                    if(String.isNotBlank(eobrSP)){
                        quoteLineIds.add(eobrSP);
                    }   
                    else{
                        for(SBQQ__QuoteLine__c ql : qte.SBQQ__LineItems__r){
                            if(String.isNotBlank(ql.SBQQ__RequiredBy__c)){
                                quoteLineIds.add(ql.Id);
                            }
                        }
                    }
                }
                
                if(quoteLineIds.size() > 0){
                    System.debug('********Calling unity direct sales service -- '+quoteLineIds);
                    String contactId;
                    if(String.isNotBlank(qte.SBQQ__PrimaryContact__c)){
                        contactId = qte.SBQQ__PrimaryContact__c;
                    }
                    else if(accountMap != null && accountMap.size() > 0){
                        Account qAccount = accountMap.get(qte.SBQQ__Account__c);
                        if(qAccount != null && qAccount.contacts != null && qAccount.contacts.size() > 0){
                            contactId = qAccount.contacts.get(0).Id;
                        }
                    }
                    OpportunityUtils2.onboardingUnityDirectSales(quoteLineIds, qte.SBQQ__Account__c, contactId, qte.Id);
                }
            }
        }
    }
    
    @future(callout=true)
    public static void onboardingUnityDirectSales(Set<ID> quoteLineIds, Id accountId, Id contactId, Id quoteId) { 
        List<UnityDirectSalesAPI__mdt> udsList = [SELECT Endpoint__c, Value__c FROM UnityDirectSalesAPI__mdt WHERE DeveloperName = 'DirectSales'];
        if(udsList.size() > 0 && quoteLineIds != null && quoteLineIds.size() > 0){
            UnityDirectSalesAPI__mdt uds = udsList.get(0);
            //Service_Logs__c slog = new Service_Logs__c();
            try{
                HttpRequest req = new HttpRequest();   
                system.debug ( '**********Direct Sales Service Endpoint -- ' +uds.Endpoint__c );
                req.setEndpoint(uds.Endpoint__c);
                req.setMethod('POST');
                req.setHeader('Authorization', uds.Value__c);
                req.setHeader('Accept', 'application/vnd.onboardingService-v1+json');
                req.setHeader('Content-Type', 'application/vnd.onboardingService-v1+json');
                
                JSONGenerator gen = JSON.createGenerator(true);
                gen.writeStartObject();      
                gen.writeStringField('accountId', accountId);
                gen.writeStringField('contactId', contactId);
                gen.writeObjectField('contractIds',quoteLineIds);
                gen.writeEndObject();
                //req.setTimeout(100000);
                req.setBody(gen.getAsString());
                system.debug ( '**********Direct Sales Service Authorization Header -- ' +req.getHeader('Authorization'));
                system.debug ( '**********Direct Sales Service Request -- ' +req.getBody());
                //slog.Request_Payload__c = req.getBody();
                //slog.Service_Name__c = uds.Endpoint__c;
                //slog.Related_Quote__c = quoteId;
                
                Http http = new Http();
                HttpResponse response = http.send(req);  
                system.debug ( '**********Direct Sales Service Response -- ' +response.getBody());
               
                
                //slog.Result__c = response.getStatus();
                //slog.Response__c = response.getBody();
            } catch(Exception e) {
                system.debug ( '**********Direct Sales Service Exception*************' +e.getMessage());
                //slog.Result__c = 'Failure';
                //slog.Response__c = e.getMessage();
            }  
            
            //insert sLog;
        }
    }
}