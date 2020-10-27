/*
*    @Author:        Joseph Barrameda (Cloudsherpas)    
*    @Date:          25.SEP.2014
*    @Description:   Post the ACCOUNT record whose QWBS_Status doesnt contain "Prospect" AND Business Unit=CNR to NETSUITE
*    
*/

public class NetsuiteSyncAccountHelper{
    public static boolean hasRun = false;
    
    @future (callout=true)
    public static void postDataToNetsuite(Set<Id> accIdList){
        
        //Instantiate the custom settings for Netsuite Integration
        Netsuite_Integration__c ni = Netsuite_Integration__c.getOrgDefaults();
        
        //Construct HTTP request and response
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        Http http = new Http();
        req.setTimeout(120000);
        
        //Construct Authorization and Content header
        String authorizationHeader = 'NLAuth nlauth_account=' + ni.nlauth_account__c + ', nlauth_email=' + ni.nlauth_email__c + ', nlauth_signature=' + ni.nlauth_signature__c;
        req.setHeader('Authorization', authorizationHeader);
        req.setHeader('Content-Type','application/json');
        system.debug('**** Authorization Header:' + authorizationHeader);
        
        //Construct Endpoint
        String endpoint = ni.endpoint__c + '?' + ni.Account_RESTlet_Params__c;
 
        //Set Method and Endpoint and Body
        req.setMethod('POST');
        req.setEndpoint(endpoint);
        
        String passString = generateJSON(accIdList);        
        system.debug('**** JSONserializePretty:' + passString);
        
        //Sets the contents of the body for this request. Limit: 3 MB
        req.setBody(passString);   
        String responseBody='';
        
        try {
            //Send endpoint to Netsuite
            res = http.send(req);
            responseBody = res.getBody();
            
            System.debug('**** Response Message:' + responseBody);
            System.debug('*** Updated/Created:' +  responseBody.contains('nscustomerid'));
            
            if (!responseBody.contains('SUCCESS')){
                //Email the error if the creation or update is not successful   
                sendErrorToEmail(accIdList, 'Netsuite Integration error', passString,responseBody); 
            }
            else{
                System.debug('**** Response:' + responseBody);
                List<Account> accountListToUpdate = new List<Account>();
                for(Account a: [SELECT Id from Account WHERE ID IN: accIdList LIMIT 1]){
                    string nsResponseId = captureNSCustomerId(responseBody);
                    if(nsResponseId != ''){
                        a.NetSuite_Customer_ID__c = nsResponseId;
                        accountListToUpdate.add(a);
                    }
                }
                
                if(!accountListToUpdate.isEmpty()){
                    update accountListToUpdate;
                }            
            }
            
        }
        catch(System.CalloutException e){
            System.debug('*** Callout Exception:' + res.toString());
            //Email the error details 
            sendErrorToEmail(accIdList, res.toString(), passString,responseBody);             
        }
    
    }
    
    public static String generateJSON(Set<Id> accIdList){
        
        JSONGenerator gen = JSON.createGenerator(true);
        
        String jSerial='';
        
        //Put the ISO Code of Countries in a Map
        Map<String,String> countryISOMap = mapCountryISOCode2(accIdList);
        
        for(Account a: [SELECT Id, Name, BillingStreet, BillingCity, BillingPostalCode, BillingState, BillingCountry, 
                        CurrencyISOCode, RFC_Id__c, ShippingStreet, ShippingPostalCode, ShippingCity, ShippingCountry, ShippingState, 
                        Account_Classification__c,NetSuite_Customer_ID__c, Is_Individual__c, Phone, Fax, QWBS_Market__c, Segment__c, Territory__c  FROM Account WHERE ID IN: accIdList]){
            
            gen.writeStartObject();
                       
            //Customer Id
            gen.writeIdField('customerid', a.Id);
            
            //Company Name
            gen.writeStringField('companyname', a.Name);            
            
         /*   //Company Short Name
            if (a.Company_Short_Name__c != null)
                gen.writeStringField('companyshortname',a.Company_Short_Name__c);
            else
                gen.writeStringField('companyshortname', a.Name);
        */    
            //Classification
            if (a.Account_Classification__c != null)
                gen.writeStringField('classification',a.Account_Classification__c);
            else
                gen.writeNullField('classification');
            
            //Billing Street
            if (a.BillingStreet != null)
                gen.writeStringField('billlineaddress1',a.BillingStreet);
            else
                gen.writeNullField('billlineaddress1');
                
            //Billing Line Address 2        
            gen.writeNullField('billlineaddress2');
            
            //Billing City
            if (a.BillingCity != null)
                gen.writeStringField('billcity',a.BillingCity);
            else
                gen.writeNullField('billcity');
                
            //Billing Postal Code        
            if (a.BillingPostalCode != null)
                gen.writeStringField('billzip',a.BillingPostalCode);
            else
                gen.writeNullField('billzip');
                
            //Billing State
            if (a.BillingState != null)
                gen.writeStringField('billstate',a.BillingState);
            else
                gen.writeNullField('billstate');
                
            //Billing Country
            if (a.BillingCountry != null && countryISOMap.get(a.billingCountry) != null)
                gen.writeStringField('billcountry',countryISOMap.get(a.billingCountry));
            else
                gen.writeNullField('billcountry');
                
            //RFC ID
            if (a.RFC_ID__c != null)
                gen.writeStringField('rfcid', a.RFC_ID__c);
            else
                gen.writeNullField('rfcid');
                
            //Currency
            if (a.CurrencyIsoCode != null)
                gen.writeStringField('currency',a.CurrencyIsoCode );
            else
                gen.writeNullField('currency');
                
            //Mailing Street
            if (a.ShippingStreet != null)
                gen.writeStringField('shiplineaddress1',a.ShippingStreet);
            else
                gen.writeNullField('shiplineaddress1');
                
            //Mailing 
            gen.writeNullField('shiplineaddress2');
            
            //Mailing City
            if (a.ShippingCity != null)
                gen.writeStringField('shipcity',a.ShippingCity);
            else
                gen.writeNullField('shipcity');
            
            //Mailing State
            if (a.ShippingState != null)
                gen.writeStringField('shipstate',a.ShippingState);
            else
                gen.writeNullField('shipstate');
                
            //Mailing Country
            if (a.ShippingCountry != null && countryISOMap.get(a.ShippingCountry) != null)
                gen.writeStringField('shipcountry',countryISOMap.get(a.ShippingCountry));
            else
                gen.writeNullField('shipcountry');
                
            //Mailing Zip
            if (a.ShippingPostalCode != null)
                gen.writeStringField('shipzip',a.ShippingPostalCode);
            else
                gen.writeNullField('shipzip');   
            
            //Is Individual?
            if (a.Is_Individual__c) {
                gen.writeNumberField('isindividual', 1);
            }
            else {
                gen.writeNumberField('isindividual', 0);
            }
            
            //Customer Phone
            if (a.Phone != null) {
                gen.writeStringField('customerphone', a.Phone);
            }
            else {
                gen.writeNullField('customerphone');
            }
            
            //Customer Fax
            if (a.Fax != null) {
                gen.writeStringField('customerfax', a.Fax);
            }
            else {
                gen.writeNullField('customerfax');
            }
            
            //Market
            if (a.QWBS_Market__c != null) {
                gen.writeStringField('market', a.QWBS_Market__c);
            }
            else {
                gen.writeNullField('market');
            }
            
            //Segment
            if (a.Segment__c != null) {
                gen.writeStringField('segment', a.Segment__c);
            }
            else {
                gen.writeNullField('segment');
            }
            
            //Territory
            if (a.Territory__c != null) {
                gen.writeStringField('territory', a.Territory__c);
            }
            else {
                gen.writeNullField('territory');
            }
                        
            gen.writeEndObject();
            
            jSerial += gen.getAsString(); 
            //gen.writeStringField('',);            
        }
        
        return jSerial;    
    }
    
    public static String captureNSCustomerId(String msg){
       
        if(msg.contains('nscustomerid')){
            JSONParser parser = JSON.createParser(msg);
            
            while (parser.nextToken() != null) {
                if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'nscustomerid')) {
                    // Get the value.
                    parser.nextToken();
                    system.debug('**** nscustomerid:' + parser.getText());
                    return parser.getText();
                }
            }
        }
        return '';        
    }
    
    public static void sendErrorToEmail(Set<Id> accountId, String errorMsg, String requestJSON, String responseJSON){
        
        List<Messaging.SingleEmailMessage> emailList = new  List<Messaging.SingleEmailMessage>();    
        //Instantiate the custom settings for Netsuite Integration
        Netsuite_Integration__c ni = Netsuite_Integration__c.getOrgDefaults();         
        //Get Email Address from the Custom Settings
        String emailRecipientStr = ni.email_recipient__c;    

        for(Account a: [SELECT Id from Account WHERE Id IN: AccountId]){
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();   
            mail.setSubject('Omnitracs: Netsuite - Account Integration Error');            
            mail.setToAddresses(extractEmailAdd(emailRecipientStr));            
            
            //Compose email starts here
            String tempStr='';
            tempStr+='<b>Netsuite Error:</b>' + errorMsg + '<br>';
            tempStr+='<b>Account Record:</b><a href="' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + a.Id + '">' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + a.Id + '</a><br><br>';
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
    *    Description: Extracts the email on a String then put it in a list of String then pass the value in "setToAddresses()" method 
    */
    
    public static List<String> extractEmailAdd(String emailStr){
        String[] formattedEmail = new List<String>();
        String[] bits = emailStr.Split(','); 
        
        for(Integer i=0; i<bits.size(); i++){
            formattedEmail.add(bits[i]);    
        }
        return formattedEmail;
    }
    
    /*   Author:      JBarrameda (Cloudsherpas)
    *    Date:        10/27/2014
    *    Description: Query the countries 2-digit ISO Code from custom object then populate it in a map
    */
        
    public static Map<String,String> mapCountryISOCode2(Set<Id> accountIdList){
        
        Map<String,String> countryIsoCodeMap = new Map<String,String>();
        Set<String> countrySet  = new Set<String>();
        
        //Get all the Countries 
        for(Account a:[SELECT Id, BillingCountry, ShippingCountry FROM Account WHERE ID IN:accountIdList]){
            countrySet.add(a.BillingCountry);
            countrySet.add(a.ShippingCountry);
        }
        
        //Query the equivalent 2digit ISO Code of the countries specified
        for(Country_And_Country_Code__c cc: [SELECT Id, Name, ISO_Code_2__c FROM Country_And_Country_Code__c WHERE Name LIKE:countrySet]){
            countryIsoCodeMap.put(cc.Name , cc.ISO_Code_2__c );
        }
        
        System.debug('**** ISO - Countries:' + countryIsoCodeMap);
                
        return countryIsoCodeMap;
    }        
}