@isTest(SeeAllData=true)
public class SpringCMUtilsTest {
    
    public static VistaAssetHelperUtil util = new VistaAssetHelperUtil();
    
    private static void setWebservice() {
        final String jsonBody = '[{"client_id": "f7e6a07a-aa6d-45b8-93c1-4812ea314057", "client_secret": "1dbb257cee5844eaa4d99d5b51840f22dZcb3xNU63rt9esErhtKR5ZaYHOOxOIysi3SjYd1H7nbILPau6rZ3rZi9BCwi9hrv2BbkZfSD2DUS8SN2yd0gs5AIVSiVrTI"}]'; 
        final String endpoint = 'https://authuat.springcm.com/api/v201606/apiuser';
        HttpRequest request = new HttpRequest();
        request.setEndpoint(endpoint);
        request.setBody(jsonBody);
        request.setHeader('Content-Type','application/json');
        request.setHeader('Accept','application/json');
        request.setMethod('POST');
        
        Map<String, String> responseHeaders = new Map<String, String>();
        responseHeaders.put('Content-Type', 'application/json');
           
        SpringCMQuoteContractMockGenerator fakeResponse = new SpringCMQuoteContractMockGenerator(200, 'OK',
                                                                    '[{"user": "Username", "passwd": "user_password"}]', responseHeaders);
        Test.setMock(HttpCalloutMock.class, fakeResponse);
        HTTPResponse res = fakeResponse.respond(request);
        System.assertNotEquals(null, res); 
        
    }
    
    static testMethod void myUnitTest() {
        //call setMock HttpCallout requires for apex callout testing.
        setWebservice();
        Account account = util.createAccount('Test Account 123');
        OpportunityTestData opportunityTestData  = new OpportunityTestData();
        List<Contact> contactList =  opportunityTestData.ContactCreation('validateOpptyEditability', 1, account.Id);
        insert contactList;
        PriceBook2 stdPriceBook = opportunityTestData.createPriceBook();
        List<Opportunity> optyList = opportunityTestData.CreateOpportunity('validateOpptyEditability', account.Id, 'Products, Services and Maintenance', 1, contactList.get(0).Id, stdPriceBook, null, null, null);
        insert optyList;
        Opportunity opportunity = optyList.get(0);
        Contract contract = util.createContract(opportunity, account, 'Customer - MSA', Date.today());
        
        Test.startTest();
        SpringCMUtils.getContractDocs(account.Name, contract.ContractNumber);
        Test.stopTest();
    }
}