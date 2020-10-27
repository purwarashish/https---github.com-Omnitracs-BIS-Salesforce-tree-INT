/*
*    @Author:        Mark Malanowski (Cloud Sherpas)   
*    @Date:          20.OCT.2014
*    @Description:   Post the Primary Quote record whose QWBS_Status doesnt contain "Prospect" AND Business Unit=CNR to NETSUITE
*    
*/

public class NetsuiteSyncOpportunityHelper{
    public static boolean hasRun = false;
    
    @future (callout=true)
    public static void postDataToNetsuite(Set<Id> oppIdList){
        

        //Instantiate the custom settings for Netsuite Integration
        Netsuite_Integration__c ni = Netsuite_Integration__c.getOrgDefaults();
        
        //Construct HTTP request and response
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        Http http = new Http();
        req.setTimeout(120000);
        
        //Construct Authorization and Content header
        String authorizationHeader = 'NLAuth nlauth_account=' + ni.nlauth_account__c + ', nlauth_email=' + ni.nlauth_email__c + ', nlauth_signature=' + ni.nlauth_signature__c + ', nlauth_role=1061';
        req.setHeader('Authorization', authorizationHeader);
        req.setHeader('Content-Type','application/json');
        system.debug('**** Authorization Header:' + authorizationHeader);
        
        //Construct Endpoint
        String endpoint = ni.endpoint__c + '?' + ni.Contract_RESTlet_Params__c;
        System.debug('**** Endpoint:' + endpoint);
        
        String passString='';
        String responseBody='';
 
         try {
            //Set Method and Endpoint and Body
            req.setMethod('POST');
            req.setEndpoint(endpoint);
            
            passString = generateJSON(oppIdList);        
            System.debug('**** JSONserializePretty:' + passString);
            
            //Sets the contents of the body for this request. Limit: 3 MB
            req.setBody(passString);   
            
                        
        //try {
            //Send endpoint to Netsuite
            res = http.send(req);
            responseBody = res.getBody();
            
            System.debug('**** Response Message:' + responseBody);
         
            if (responseBody.contains('SUCCESS') == false){
                //Email the error if the creation or update is not successful   
                sendErrorToEmail(oppIdList,  'Netsuite Opportunity Integration error', passString,responseBody); 
            }
        }
        catch(System.CalloutException e){
            sendErrorToEmail(oppIdList, res.toString() , passString,responseBody);
            System.debug('*** Callout Exception:' + res.toString());
        }

    }
    
    public static String generateJSON(Set<Id> oppIdList){
        
        JSONGenerator gen = JSON.createGenerator(true);        
        String jSerial='';        
        
        for(Opportunity o: [SELECT Id, AccountId, Account.NetSuite_Customer_ID__c, Owner.Name, Owner.Email, CurrencyISOCode, 
                            Primary_Quote_Approval_Status__c, Primary_Quote_Effective_Date__c, Primary_Quote_Contract_Term__c, Negotiation_Type__c,
                            RecordType.Name, (SELECT Id, discount, discount_amount__c, Quantity, Discount_Amount_MX_Output__c, UnitPrice, TotalPrice, Quote_Product__r.Lease_Term__c, 
                            License_Metric_Quantity__c, Product_Type__c, PricebookEntry.Product2.ProductCode, Unit_Price_MX_Output__c,Quote_Product__r.Contract_Term__c  
                            FROM OpportunityLineItems) FROM Opportunity WHERE ID IN: oppIdList]){
        
            gen.writeStartObject();
            
            //External Id (Opportunity ID)
            gen.writeIdField('externalid', o.Id);
            
            //Customer Id
            gen.writeStringField('customerid', o.AccountId);    //JBarrameda - Modified from writeIdField to writeStringField  
            
            //Negotiation Type
            if (o.Negotiation_Type__c != null)
                gen.writeStringField('negotiationtype',o.Negotiation_Type__c);
            else
                gen.writeNullField('negotiationtype');
                
            //Status
            if (o.Primary_Quote_Approval_Status__c != null)
                gen.writeStringField('status',o.Primary_Quote_Approval_Status__c);
            else
                gen.writeNullField('status');
                
            //Owner Name
            if (o.Owner.Email != null)
                gen.writeStringField('salesrep',o.Owner.Email);
            else
                gen.writeNullField('salesrep');
            
            //Effective date
            if (o.Primary_Quote_Effective_Date__c != null){
                DateTime dt = o.Primary_Quote_Effective_Date__c;
                String sDate = dt.format('MM/dd/yyyy');    
                gen.writeStringField('startdate', String.valueOf(sDate));
                //gen.writeDateField('startdate', o.Primary_Quote_Effective_Date__c);
            }
            else
                gen.writeNullField('startdate');
                
            //Contract Term
            if (o.Primary_Quote_Contract_Term__c != null) {
                gen.writeNumberField('leaseterm', o.Primary_Quote_Contract_Term__c);
                gen.writeNumberField('signalterm', o.Primary_Quote_Contract_Term__c);
            }
            else {
                gen.writeNullField('leaseterm');
                gen.writeNullField('signalterm');
            }
            
            //Eval Opportunities - Contract Term
            if (o.Primary_Quote_Contract_Term__c != null && o.RecordType.Name == 'Eval') {
                gen.writeNumberField('evaltimeperiod', o.Primary_Quote_Contract_Term__c);
            }
            else {
                gen.writeNullField('evaltimeperiod');
            }
            
            //CurrencyISOCode
            if (o.CurrencyISOCode != null)
                gen.writeStringField('currency',o.CurrencyISOCode);
            else
                gen.writeNullField('currency');
               
                        
            //Start looping over line items
            if (o.OpportunityLineItems.size() > 0) {
                gen.writeFieldName('items');
                gen.writeStartArray();
                for (OpportunityLineItem oli : o.OpportunityLineItems) {
                    gen.writeStartObject();
                
                    //Product SKU
                    gen.writeStringField('itemid', oli.PricebookEntry.Product2.ProductCode);
                
                    //Quantity
                    if (oli.License_Metric_Quantity__c != null)
                        gen.writeNumberField('itemquantity', oli.License_Metric_Quantity__c);
                    else
                        gen.writeNumberField('itemquantity', 0);
                    
                     //Discount
                    if (oli.discount != null){
                        //gen.writeNumberField('itemdiscount', oli.Discount_Amount_MX_Output__c*oli.Quantity);
                        gen.writeNumberField('itemdiscount', oli.discount*oli.Quantity);
                    }
                    else
                        gen.writeNumberField('itemdiscount', 0);

                    //Price
                    if (oli.TotalPrice != null){
                        //Modified by Joe Henry 2/2/2015
                        /*if ((oli.Product_Type__c =='Hardware' && o.Negotiation_Type__c == 'Lease') || (oli.Product_Type__c =='Software' && o.Negotiation_Type__c == 'Sale') ||
                                (oli.Product_Type__c =='Software' && o.Negotiation_Type__c == 'Lease'))
                             gen.writeNumberField('itemprice', oli.Unit_Price_MX_Output__c);
                        else 
                            gen.writeNumberField('itemprice', oli.UnitPrice);*/
                       gen.writeNumberField('itemprice', oli.UnitPrice); 
                    } 
                   	else
                        gen.writeNumberField('itemprice', 0);
                
                    //Contract term (Replace with Lease_Term__c)
                    /*if (oli.Quote_Product__r.Contract_Term__c != null)
                        gen.writeNumberField('term', oli.Quote_Product__r.Contract_Term__c);
                    */
                    /*if (oli.Quote_Product__r.Lease_Term__c != null)
                        gen.writeStringField('term', oli.Quote_Product__r.Lease_Term__c);
                    else
                        gen.writeNullField('term');*/
                    if(o.Primary_Quote_Contract_Term__c != null ){
                        //System.debug('*********** -- 1 - '+o.Primary_Quote_Contract_Term__c);
                    	gen.writeNumberField('term', o.Primary_Quote_Contract_Term__c);
                    }
                    
                    gen.writeEndObject();
                }
                gen.writeEndArray();
            }        
                                 
            gen.writeEndObject();
            
            jSerial += gen.getAsString(); 
            //gen.writeStringField('',);            
        }
        system.debug('************************************* JSON string for NetSuite: '+jSerial);
        return jSerial;    
    }
    
    public static void sendErrorToEmail(Set<Id> oppIdSet, String errorMsg, String requestJSON, String responseJSON){
        
        List<Messaging.SingleEmailMessage> emailList = new  List<Messaging.SingleEmailMessage>();
        
        //Instantiate the custom settings for Netsuite Integration
        Netsuite_Integration__c ni = Netsuite_Integration__c.getOrgDefaults();
        //Get Email Address from the Custom Settings
        String emailRecipientStr = ni.email_recipient__c;    
                        
        for(Opportunity o: [SELECT Id from Opportunity WHERE Id IN: oppIdSet]){
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();   
            mail.setSubject('Omnitracs: Netsuite - Opportunity Integration Error');            
            mail.setToAddresses(extractEmailAdd(emailRecipientStr));            
            
            //Compose email starts here
            String tempStr='';
            tempStr+='<b>Netsuite Error:</b>' + errorMsg + '<br>';
            tempStr+='<b>Opportunity Record:</b><a href="' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + o.Id + '">' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + o.Id + '</a><br><br>';
            tempStr+='<b>Request JSON:</b>' + requestJSON + '<br><br>';
            tempStr+='<b>Response JSON:</b>' + responseJSON + '<br>';
            
            mail.setHtmlBody(tempStr);
            emailList.add(mail);
        }
                    
        //Email 
        if (!emailList.isEmpty()){
            try{
                    Messaging.SendEmailResult [] r = Messaging.sendEmail(emailList);             
            }
            catch (System.EmailException e){
                System.debug('******* Error:' + e.getMessage());
            }           
        }
              
    }
    
    /*   Author:      JBarrameda (Cloudsherpas)
    *    Date:        10/22/2014
    *    Description: Extracts the email String then put it in a list of String 
    *                 Used in "setToAddresses()" method 
    */
    
    public static List<String> extractEmailAdd(String emailStr){
        String[] formattedEmail = new List<String>();
        String[] bits = emailStr.Split(','); 
        
        for(Integer i=0; i<bits.size(); i++){
            formattedEmail.add(bits[i]);    
        }
        return formattedEmail;
    }
           
}