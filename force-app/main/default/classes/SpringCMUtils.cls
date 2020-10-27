global class SpringCMUtils{

    WebService static String getContractDocs(String acctName, String contractNumber){
        SpringCMEos.RetrieveEnvironment environment = new SpringCMEos.RetrieveEnvironment();
        String environmentName = environment.getEnvironmentPrefix();
        String prefix;
        if(String.isNotBlank(environmentName)) 
            prefix = environmentName.substringBefore('.').toLowerCase();
        String endpoint = (prefix=='uatna11' || prefix=='uat') ? 'https://authuat.springcm.com/api/v201606/apiuser' : 'https://auth.springcm.com/api/v201606/apiuser';    
        String root = (prefix=='uatna11' || prefix=='uat') ? '/Omnitracs - UAT' : '/Omnitracs, LLC';
        String env = (prefix=='uatna11' || prefix=='uat') ? 'UAT' : 'PROD';
        Map<String, String> respMap = createSpringCMAuthRequest(env, endpoint);
        respMap.put('acctName', acctName);
        respMap.put('contractNumber', contractNumber);
        String contractDocsPath = root + '/Other Sources/Salesforce/Accounts/' + acctName + '/Contracts/'  + contractNumber + '/';           
        String pathURI = EncodingUtil.urlEncode(contractDocsPath, 'UTF-8');       
        String uriEndpoint = respMap.get('api_base_url') + '/v201411/folders?path=' + pathURI + '&expand=Documents';
        HttpRequest req =new HttpRequest();
        HttpResponse response;                                                     
        req.setEndpoint(uriEndpoint);
        req.setHeader('Authorization', 'Bearer ' + respMap.get('access_token'));
        req.setHeader('Content-Type' , 'application/json');
        req.setMethod('GET');           
    
        Http http = new Http();        
        try {
            response = http.send(req);
            System.debug(response.toString());
        }catch(System.CalloutException e) {
            System.debug('ERROR:' + e.getMessage());
        }
        
        return String.valueOf(response.getBody());
    }
    
    @TestVisible
    static Map<String, String> createSpringCMAuthRequest(String env, String endpoint) {
        SpringCMApiEnvironment__mdt mdt = [SELECT Client_Id__c, Client_Secret__c, AuthEndpoint__c FROM SpringCMApiEnvironment__mdt WHERE DeveloperName =: env];
        JsonAuthWrapper authWrapper = new JsonAuthWrapper();
        authWrapper.client_id = mdt.Client_Id__c;
        authWrapper.client_secret = mdt.Client_Secret__c;
        String jsonBody = JSON.serialize(authWrapper);                
        
        HttpRequest request = new HttpRequest();
        request.setEndpoint(endpoint);
        request.setBody(jsonBody);
        request.setHeader('Content-Type','application/json');
        request.setHeader('Accept','application/json');
        request.setMethod('POST');
        
        Http http = new Http();
        HttpResponse response;        
        try {
            response = http.send(request);
            System.debug(response.toString());
            System.debug('STATUS: ' + response.getStatus());
            System.debug('STATUS_CODE: '+ response.getStatusCode());                    
        }catch(System.CalloutException e) {
            System.debug('ERROR:' + e.getMessage());
        }               

        JSONParser parser = JSON.createParser(response.getBody());
        Map<String, String> respMap = new Map<String, String>();
        while (parser.nextToken() != null) {
            if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                String text = parser.getText();
                if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                    if (text == 'access_token') {
                        respMap.put('access_token', parser.getText());
                    }
                    if (text == 'api_base_url') {
                        respMap.put('api_base_url', parser.getText());
                    } 
                }
            }
        }
        return respMap;
    }
    
    public class JsonAuthWrapper {
        public String client_id {get; set;}
        public String client_secret {get; set;}
      
        public JsonAuthWrapper() {
            client_id = null;
            client_secret = null;
        }
      
    }
}