/*
*    @Author:        Joseph Barrameda (Cloudsherpas)    
*    @Date:          15.OCT.2014
*    @Description:   Post the Contact record whose QWBS_Status doesnt contain "Prospect" AND Business Unit=CNR to NETSUITE
*    
*/


public class NetsuiteSyncContactHelper{
    public static boolean hasRun = false;
    
    @future (callout=true)
    public static void postDataToNetsuite(Set<Id> conIdList){
        
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
        
        String passString = generateJSON(conIdList);        
        System.debug('**** JSONserializePretty:' + passString);
        
        //Sets the contents of the body for this request. Limit: 3 MB
        req.setBody(passString);   
        String responseBody='';
        
        try {
            //Send endpoint to Netsuite
            res = http.send(req);
            responseBody = res.getBody();            
            System.debug('**** Response Message:' + responseBody);
            
            if (responseBody.containsNone('SUCCESS')){
                //Email the error if the creation or update is not successful   
                sendErrorToEmail(conIdList, 'Netsuite Contact Integration error', passString,responseBody); 
            }
        }
        catch(System.CalloutException e){
            sendErrorToEmail(conIdList, res.toString(), passString,responseBody);             
            System.debug('*** Callout Exception:' + res.toString());
        }    

    }
    
    public static String generateJSON(Set<Id> conIdList){
        
        JSONGenerator gen = JSON.createGenerator(true);        
        String jSerial='';        
        for(Contact c: [SELECT Id, AccountId, FirstName, LastName, Email, Phone FROM Contact WHERE ID IN: conIdList]){
        
            gen.writeStartObject();
            //Customer Id
            gen.writeIdField('customerid', c.AccountId);
            
            //Contact First Name
            if (c.FirstName != null)
                gen.writeStringField('contactfname',c.FirstName);
            else
                gen.writeNullField('contactfname');

            //Contact Last Name
            if (c.LastName != null)
                gen.writeStringField('contactlname',c.LastName);
            else
                gen.writeNullField('contactlname');
            
            //Contact Email
            if (c.Email != null)
                gen.writeStringField('contactemail',c.Email);
            else
                gen.writeNullField('contactemail');
            
            //Contact Phone
            if (c.Phone != null)
                gen.writeStringField('contactphone',c.Phone);
            else
                gen.writeNullField('contactphone');
                        
            gen.writeEndObject();
            
            jSerial += gen.getAsString(); 
            //gen.writeStringField('',);            
        }
        
        return jSerial;    
    }
    
    public static void sendErrorToEmail(Set<Id> contactIdSet, String errorMsg, String requestJSON, String responseJSON){
        
        List<Messaging.SingleEmailMessage> emailList = new  List<Messaging.SingleEmailMessage>();
        
        //Instantiate the custom settings for Netsuite Integration
        Netsuite_Integration__c ni = Netsuite_Integration__c.getOrgDefaults();
        //Get Email Address from the Custom Settings
        String emailRecipientStr = ni.email_recipient__c;    
                        
        for(Contact  c: [SELECT Id from Contact WHERE Id IN: contactIdSet]){
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();   
            mail.setSubject('Omnitracs: Netsuite - Contact Integration Error');
            
            mail.setToAddresses(extractEmailAdd(emailRecipientStr));            
            
            //Compose email starts here
            String tempStr='';
            tempStr+='<b>Netsuite Error:</b>' + errorMsg + '<br>';
            tempStr+='<b>Contact Record:</b><a href="' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + c.Id + '">' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + c.Id + '</a><br><br>';
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