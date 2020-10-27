global class JIRAConnectorWebserviceCallout {
    @future (callout=true)
    WebService static void createIssue( Id caseId ) {
        JIRA_Credentials__c jiraCreds = JIRA_Credentials__c.getOrgDefaults();

        //Set username and password
        String username = jiraCreds.JIRA_Username__c;
        String password = jiraCreds.JIRA_Password__c;
        
        //Set URL endpoint
        String jiraURL = jiraCreds.JIRA_Hostname__c;
        if(jiraURL != null && EmailClassRoadnet.isUserInSandbox())//just to ensure, not to create JIRA issue in JIRA prod from sandbox 
            jiraURL = jiraURL.substring(0,jiraURL.indexof('.')) + '-test' + jiraURL.substring(jiraURL.indexof('.'));

        
        //Construct HTTP request and response
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        Http http = new Http();
 
        //Construct Endpoint
        String endpoint = ''+jiraURL+'/plugins/servlet/create-issue?jira_user=' + username + '&pwd=' + password + '&id=' + caseId;
        
        //Set HTTP request
        req.setEndpoint(endPoint);
        req.setMethod('GET');
        req.setTimeout(50000); 

        try {
            //Send endpoint to JIRA
            res = http.send(req);
            System.debug('\n\n\nResponse: ' + res);
         
        } catch(System.CalloutException e) {
            System.debug(res.toString());
        }
    }
}