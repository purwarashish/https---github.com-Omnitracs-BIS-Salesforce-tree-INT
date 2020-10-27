public class SpringCMApiManager {
    private String apiURL;
    private SpringCMApiEnvironment__mdt apiEnvironment;

    private String localAccessToken;
    private Datetime localTokenExpiration;
    private String localApiBaseUrl;
    private String session = null;

    private Boolean sessionauth = false;

    public string AccessToken {
        get {
            validateAccessToken();
            return localAccessToken;
        }
    }

    public string ApiBaseUrl {
        get {
            validateAccessToken();
            return localApiBaseUrl;
        }
    }

    private void validateAccessToken() {
        if (String.isBlank(localAccessToken) || localTokenExpiration < DateTime.now()) {
                System.debug('Refreshing access token');
                authenticate();
        }
    }

    public SpringCMApiManager() {
        apiURL = URL.getSalesforceBaseUrl().toExternalForm() + '/services/Soap/u/28.0/' + UserInfo.getOrganizationId();
        apiEnvironment = SpringCMApiEnvironment.getApiEnvironment();
    }

    public SpringCMApiManager(Boolean authflag, String session) {
        apiURL = URL.getSalesforceBaseUrl().toExternalForm() + '/services/Soap/u/28.0/' + UserInfo.getOrganizationId();
        apiEnvironment = SpringCMApiEnvironment.getApiEnvironment();
        sessionauth = authflag;
        this.session = session;
    }

    private void authenticate() {
        SpringCMAuthRequest springCMAuthRequest = createAuthRequest();
        String responseBody = post(springCMAuthRequest,apiEnvironment.AuthEndpoint__c);
        system.debug(responseBody);
        SpringCMAuthResponse springCMAuthResponse = (SpringCMAuthResponse)JSON.deserialize(responseBody, Type.forName('SpringCMAuthResponse'));
        saveAuthResponse(springCMAuthResponse);
    }

    private SpringCMAuthRequest createAuthRequest() {
        SpringCMAuthRequest springCMAuthRequest = new SpringCMAuthRequest();
        springCMAuthRequest.ClientId = apiEnvironment.Client_Id__c;
        springCMAuthRequest.ClientSecret = apiEnvironment.Client_Secret__c;
        if (sessionauth) {
            springCMAuthRequest.SFSessionId = session; // UserInfo.getSessionId();
            springCMAuthRequest.ApiUri = apiUrl;
        }
        return springCMAuthRequest;
    }

    private void saveAuthResponse(SpringCMAuthResponse authResponse) {
        localAccessToken = authResponse.AccessTokenValue;
        localApiBaseUrl = authResponse.ApiBaseUrl;
        localTokenExpiration = authResponse.ExpirationDateTime;
    }

    public String get(String endpoint) {
        HttpRequest request = new HttpRequest();
        request.setHeader('Content-Type', 'application/json');

        return doGet(request,endpoint).getBody();
    }

    public Blob getBlob(String endpoint, String acceptHeader) {
        HttpRequest request = new HttpRequest();
        request.setHeader('Content-Type', 'application/json');
        if (String.isNotBlank(acceptHeader)) request.setHeader('Accept', acceptHeader);

        return doGet(request,endpoint).getBodyAsBlob();
    }

    private HttpResponse doGet(HttpRequest request, String endpoint) {
        request.setMethod('GET');
        request.setEndpoint(endpoint);
        request.setTimeout(60000);

        //We will get in a loop if we try to add the access token to an auth call
        //since the access token is what we are trying to retrieve
        if (endpoint!=apiEnvironment.AuthEndpoint__c) {
            request.setHeader('Authorization','oauth '+AccessToken);
        }

        Http http = new Http();
        HttpResponse response = http.send(request);

        validateResponse(response);
        return response;
    }

    public String post(Object body, String endpoint) {
        HttpRequest request = new HttpRequest();
        String req = JSON.serialize(body);
        request.setBody(req);
        request.setHeader('Content-Type', 'application/json');

        return doPost(request,endpoint);
    }

    public String postBlob(Blob body, String endpoint, String contentType) {
        HttpRequest request = new HttpRequest();
        if (String.isNotEmpty(contentType)) request.setHeader('Content-Type', contentType);
        request.setBodyAsBlob(body);

        return doPost(request,endpoint);
    }

    private String doPost(HttpRequest request, String endpoint) {
        request.setMethod('POST');
        request.setEndpoint(endpoint);
        request.setTimeout(60000);

        //We will get in a loop if we try to add the access token to an auth call
        //since the access token is what we are trying to retrieve
        if (endpoint!=apiEnvironment.AuthEndpoint__c) {
            request.setHeader('Authorization','oauth '+AccessToken);
            }

        Http http = new Http();
        HttpResponse response = http.send(request);

        validateResponse(response);
        return response.getBody();
    }

    public HttpResponse del(String endpoint) {
        HttpRequest request = new HttpRequest();
        request.setHeader('Content-Type', 'application/json');

        return doDelete(request,endpoint);
    }

    private HttpResponse doDelete(HttpRequest request, String endpoint) {
        request.setMethod('DELETE');
        request.setEndpoint(endpoint);
        request.setTimeout(60000);

        //We will get in a loop if we try to add the access token to an auth call
        //since the access token is what we are trying to retrieve
        if (endpoint!=apiEnvironment.AuthEndpoint__c) {
            request.setHeader('Authorization','oauth '+AccessToken);
            }

        Http http = new Http();
        HttpResponse response = http.send(request);

        validateResponse(response);
        return response;
    }

    private void validateResponse(HttpResponse response) {
        if (response.getStatusCode() >= 400) {
            system.debug(response);
            SpringCMApiError error = (SpringCMApiError)JSON.deserialize(response.getBody(), Type.forName('SpringCMApiError'));

            String[] errorArguments = new String[]{ String.valueOf(error.Error.HttpStatusCode),
                                                    String.valueOf(error.Error.ErrorCode),
                                                    error.Error.ReferenceId,
                                                    error.Error.DeveloperMessage};
            String errorLog = String.format('SpringCM API Error - HttpStatusCode:{0}, ErrorCode:{1}, ReferenceId:{2}, DeveloperMessage:{3}',errorArguments);
            System.debug(LoggingLevel.ERROR, errorLog);

            String userMessage = error.Error.UserMessage;
            if(error.Error.HttpStatusCode == 422) {
                for(SpringCMApiError.SpringCMValidationError validationError : error.ValidationErrors) {
                    userMessage += ' : ' + validationError.UserMessage;
                }
            }

            System.debug(userMessage);
            throw new SpringCMException(userMessage.escapeHtml4());
        }
    }
}