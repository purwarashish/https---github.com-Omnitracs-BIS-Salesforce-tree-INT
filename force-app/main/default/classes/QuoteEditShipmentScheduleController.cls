/*
 *  @author:        Mark De Chavez | mark.dechavez@cloudsherpas.com
 *  @description:   Starting from quote - A custom interface to create child Shipment_Forecast__c records from a single Quote_Product__c record
 *  @date-created:  September 23, 2014
 *  @revision: 
 */ 
public class QuoteEditShipmentScheduleController {
    private Id passedQuoteId ;

    /*
     *  @author:        Mark De Chavez | mark.dechavez@cloudsherpas.com
     *  @description:   get the url parameter quote id
     *  @date-created:  September 23, 2014
     *  @parameter:     none
     *  @revision: 
     */ 
    public QuoteEditShipmentScheduleController(){
        passedQuoteId = ApexPages.currentPage().getParameters().get('id');
    }

    /*
     *  @author:        Mark De Chavez | mark.dechavez@cloudsherpas.com
     *  @description:   Redirect the user to the EditShipmentSchedule page, passing in the ID of the first VCG_CPQ_Quote_Product__c record returned in the query.
     *  @date-created:  September 23, 2014
     *  @parameter:     none
     *  @revision: 
     */ 
    public PageReference redirectToEditShipmentSched(){
        List<VCG_CPQ_Quote_Product__c> vcgCpqQuoteProdList = new List<VCG_CPQ_Quote_Product__c>();
        for (VCG_CPQ_Quote_Product__c quoteProd :[SELECT Id, Sum_of_Shipment_Quantity__c, License_Metric_Quantity__c , Number_of_Shipment_Forecasts__c, Line_Type__c 
                                                 FROM VCG_CPQ_Quote_Product__c 
                                                 WHERE Product__r.Shipment_Schedule_Required__c = TRUE
                                                 AND Quote__c = : passedQuoteId ]){
            if ((quoteProd.Number_of_Shipment_Forecasts__c == 0 || quoteProd.Sum_of_Shipment_Quantity__c != quoteProd.License_Metric_Quantity__c) && quoteProd.Line_Type__c  != 'Decommission'  && (quoteProd.License_Metric_Quantity__c != null && quoteProd.License_Metric_Quantity__c != 0) ){
                vcgCpqQuoteProdList.add(quoteProd);
            }
        }
        System.debug('test***: '+ vcgCpqQuoteProdList);
        if (vcgCpqQuoteProdList.size() > 0){
            PageReference pR = new PageReference ('/apex/EditShipmentSchedule');  
            pR.getParameters().put('id', vcgCpqQuoteProdList[0].Id);
            pR.getParameters().put('passedQuoteId', passedQuoteId);
            pR.setRedirect(true);
            return pR;
        }   
        else {          
            VCG_CPQ_Quote__c vcgCpqQuote = [SELECT Id FROM VCG_CPQ_Quote__c WHERE Id = : passedQuoteId];

            //Redirects the user to quote's record view
            return (new ApexPages.StandardController(vcgCpqQuote)).view();
        }
    }
}