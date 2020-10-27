@isTest
global class MockHttpResponseGeneratorFail implements HttpCalloutMock {
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {        
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setStatusCode(400);
        return res;
    }
}