/*
 *  @author:        Mark De Chavez | mark.dechavez@cloudsherpas.com
 *  @description:   A custom interface to create child Shipment_Forecast__c records from a single Quote_Product__c record
 *  @date-created:  September 09, 2014
 *  @revision: 
 */ 
public class EditShipmentScheduleExt {
    public VCG_CPQ_Quote__c quote {get; set;}
    public VCG_CPQ_Quote_Product__c quoteProd {get; set;}        
    public List<Shipment_Forecast__c> dispShipmentSched {get; set;}
    public Decimal remainingQty {get; set;}
    public List<Shipment_Forecast__c> OlddispShipmentSched; // Abhishek Added

    private List<Shipment_Forecast__c> deleteShipmentList{get; set;}    
    private Id passedQuoteId {get; set;}
    
    public static boolean verifyShipmentEdit = false;
    
    /*
     *  @author:        Mark De Chavez | mark.dechavez@cloudsherpas.com
     *  @description:   
     *  @date-created:  September 10, 2014
     *  @parameter:     none
     *  @revision: 
     */ 
    public EditShipmentScheduleExt( ApexPages.StandardController sc ) {
        passedQuoteId = ApexPages.currentPage().getParameters().get('passedQuoteId');

        deleteShipmentList = new List<Shipment_Forecast__c>();
        List<String> fieldList = new List<String>();
        
        //this is solved in vf page by calling VCG_CPQ_Quote_Product__c.Quote__c in the outputfield rendered false. For passing test class, so ww will not include !isTest.Running condition here. avoiding error: System.SObjectException: You cannot call addFields when the data is being passed into the controller by the caller.
        //fieldList.add('Quote__c');
        //sc.addFields(fieldList);
        
        quoteProd = (VCG_CPQ_Quote_Product__c) sc.getRecord();
        
        //get shipment sched
        dispShipmentSched = [SELECT Shipment_Date__c,Oracle_Sales_Order_ID__c, Shipment_Quantity__c, Notes__c, Shipped__c, Quote_Product__r.Quote__c, Delivery_Schedule__c 
                             FROM Shipment_Forecast__c 
                             WHERE Quote_Product__c =: quoteProd.Id ORDER BY Shipment_Date__c ASC];
                             
        // Keeping a placeholder for old Data
        OlddispShipmentSched = dispShipmentSched.deepClone(true,true,true);    // Abhishek Added                 
                             
        String q = '';
        q = 'SELECT Id, Is_Primary__c, Opportunity__c';
        for (VCG_CPQ_Quote_Opportunity_Map__c qo : [Select Opportunity_Field__c, Quote_Field__c 
                                                    from VCG_CPQ_Quote_Opportunity_Map__c 
                                                   where Active__c = true]) {
            q += ', ' + qo.Quote_Field__c;                                
        }
        q += ' FROM VCG_CPQ_Quote__c WHERE Id = \'' + quoteProd.Quote__c + '\' LIMIT 1';
                            
        quote = database.query(q);
        System.debug('xxxxQUote: ' + quote);
        //Add empty Shipment_Forecast__c if list has less than 5 size
        if (dispShipmentSched.size() == 0){
            dispShipmentSched.add(new Shipment_Forecast__c(Quote_Product__c = quoteProd.Id, Shipment_Quantity__c = quoteProd.License_Metric_Quantity__c));
        }

        updateRemainingQty();
    }
    

    /*
     *  @author:        Mark De Chavez | mark.dechavez@cloudsherpas.com
     *  @description:   updates the label whenever the  quantity is added to shipment
     *  @date-created:  September 10, 2014
     *  @parameter:     none
     *  @revision: 
     */ 
    public void updateRemainingQty(){
        Decimal ctr = 0;
        for (Integer i = 0; i < dispShipmentSched.size(); i++){
            if(dispShipmentSched[i].Shipment_Quantity__c != null){
                ctr = ctr + dispShipmentSched[i].Shipment_Quantity__c;
            }
        }
        remainingQty =  (quoteProd.License_Metric_Quantity__c != null ? quoteProd.License_Metric_Quantity__c - ctr : 0);
    }
    
    /*
     *  @author:        Mark De Chavez | mark.dechavez@cloudsherpas.com
     *  @description:   add empty Shipment_Forecast__c in the dispShipmentSched
     *  @date-created:  September 10, 2014
     *  @parameter:     none
     *  @revision: 
     */ 
    public void addRow(){
        //add row in the list dispShipmentSched
        dispShipmentSched.add(new Shipment_Forecast__c(Quote_Product__c=quoteProd.Id));
    }
    
    /*
     *  @author:        Mark De Chavez | mark.dechavez@cloudsherpas.com
     *  @description:   Saves all the update made and added shipment schedule
     *  @date-created:  September 10, 2014
     *  @parameter:     none
     *  @revision: 
     */ 
    public PageReference saveShipmentSched(){
        List<Shipment_Forecast__c> upsertList = new List<Shipment_Forecast__c>();
        Decimal sumShipmentQuantity = 0;
        
         // Abhishek Added..
         try{
             for(Integer i = 0;i < dispShipmentSched.size();i++){
                      
             if(dispShipmentSched[i].Shipped__c != olddispShipmentSched[i].Shipped__c )
               { 
               verifyShipmentEdit = true; 
               break;
               }
            }
        }
        catch(exception e)
        {
            System.debug(e.getMessage());
        }
        
        
        for (Integer i = 0; i < dispShipmentSched.size(); i++){
            
            if (dispShipmentSched[i].Shipment_Quantity__c > 0 && dispShipmentSched[i].Shipment_Date__c == null){                   
                dispShipmentSched[i].addError('Failed saving the changes in the record. Shipment Date is required in Shipment Number: '+(i+1) );
            }
            else if (dispShipmentSched[i].Shipment_Date__c != null && dispShipmentSched[i].Shipment_Quantity__c  == null){
                dispShipmentSched[i].addError('Failed saving the changes in the record. Shipment Quatity is required in Shipment Number: '+(i+1));
            }
            else {
                if (dispShipmentSched[i].Shipment_Date__c != null && dispShipmentSched[i].Shipment_Quantity__c != null){
                    upsertList.add(dispShipmentSched[i]);
                    sumShipmentQuantity = sumShipmentQuantity + (dispShipmentSched[i].Shipment_Quantity__c != null ? dispShipmentSched[i].Shipment_Quantity__c : 0);
                }                
            }                                     
            
        }
        
        if (sumShipmentQuantity != quoteProd.License_Metric_Quantity__c){
            ApexPages.addMessage( new ApexPages.message( ApexPages.severity.ERROR, 
                                                        'Failed saving the changes in the record. Sum of Shipment Quantity doesn\'t match Quote Product\'s Quantity.' ) );
            return null;
        }
        else{
            try{
                upsert upsertList;
                delete deleteShipmentList;
                update quoteProd;
                VCG_CPQ_PricingUtility.syncPrimaryQuote(quote);
            }
            catch(Exception ex){
                ApexPages.addMessage( new ApexPages.message( ApexPages.severity.ERROR, 
                                                            'Failed saving the changes in the record. Please contact your System Administrator.' ) );
                System.debug('@SaveError: ' + ex.getMessage());
            }
            
            if (passedQuoteId != null){
                PageReference pR = new PageReference ('/apex/QuoteEditShipmentSchedule');  
                pR.getParameters().put('id', passedQuoteId);
                pR.setRedirect(true);
                return pR;
            }
            else {
                return (new ApexPages.StandardController(quoteProd)).view();
            }
        }
    }
    
    /*
     *  @author:        Mark De Chavez | mark.dechavez@cloudsherpas.com
     *  @description:   Deletes row index in the list
     *  @date-created:  September 10, 2014
     *  @parameter:     none
     *  @revision: 
     */ 
    public void deleteShipmentSched(){
        Integer rowIndex = Integer.valueOf(ApexPages.currentPage().getParameters().get('rowIndex'));
        Shipment_Forecast__c shipmentForecast = dispShipmentSched.remove(rowIndex);
        deleteShipmentList.add(shipmentForecast);
        updateRemainingQty();
    }
    
}