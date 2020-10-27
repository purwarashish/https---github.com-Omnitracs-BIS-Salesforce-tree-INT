/*
*    Author:            JBarrameda (Cloudsherpas)
*    Date Created:      07-OCT-2014
*    Description:       NetsuiteSyncHelper MockHTTPResponseGenerator
*/

@isTest
                        
global class NetsuiteSyncMockHttpResponseGen implements HttpCalloutMock {
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {
        // Optionally, only send a mock response for a specific endpoint
        // and method.
 
        //Instantiate the custom settings for Netsuite Integration
        Netsuite_Integration__c ni = Netsuite_Integration__c.getOrgDefaults();
        
        System.assertEquals('POST', req.getMethod());
        
        String reqBody = req.getBody();
        System.debug('*** Req Body:' + reqBody);
        
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        
        if(reqBody.countMatches('null') <=3){
            res.setBody('{"message":"SUCCESS","nscustomerid":"44444444"}');
            res.setStatusCode(200);
        }
        else{
            res.setBody('{"message":"Incomplete details"}');
            res.setStatusCode(400);
        }            
        
        return res;
    }
}