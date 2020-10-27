@isTest
public class SpringCMApiManagerMock implements HttpCalloutMock {
    public Boolean ReturnError {get;set;}

    public SpringCMApiManagerMock() {
        ReturnError = false;
        }

    public HTTPResponse respond(HTTPRequest request) {
        HttpResponse response = new HttpResponse();
        SpringCMApiEnvironment__mdt environment = SpringCMApiEnvironment.getApiEnvironment();

        if (ReturnError) {
            response.setBody('{"Error":{"HttpStatusCode": 422,"UserMessage": "Validation Error","DeveloperMessage": "See the list of validation errors","ErrorCode": 101,"ReferenceId": "00000000-0000-0000-0000-000000000000"},"ValidationErrors":[{"PropertyName": "Name","UserMessage": "Names cannot contain the following characters:|","DeveloperMessage": "Names cannot contain the following characters: |","ErrorCode": 1001}]}');
            response.setStatusCode(422);
            response.setStatus('UnprocessableEntity');
            return response;
            }

        if (request.getEndpoint().equals('https://apiuploaduatna11.springcm.com/v201411/folders/00000000-0000-0000-0000-000000000000/documents')) {
            response.setBody('{"Name": "Testing.docx", "CreatedDate": "1900-01-01T00:00:00.000Z", "CreatedBy": "support@springcm.com", "UpdatedDate": "1900-01-01T00:00:00.000Z", "UpdatedBy": "support@springcm.com", "Description": "", "ParentFolder": {"Href": "https://apiuatna11.springcm.com/v201411/folders/00000000-0000-0000-0000-000000000000", "UpdatedDate": null, "UpdatedBy": null, "ShareLinks": null, "Path": null, "ParentFolder": null, "Name": null, "Folders": null, "EosParentInfo": null, "EosInfo": null, "Documents": null, "Description": null, "CreateDocumentHref": null, "CreatedDate": null, "CreatedBy": null, "BrowseDocumentsUrl": null, "AttributeGroups": null }, "PageCount": 0, "PreviewUrl": "https://uatna11.springcm.com/atlas/documents/preview.aspx?aid=0000&lduid=00000000-0000-0000-0000-000000000000", "Version": null, "ShareLinks": {"Total": null, "Limit": null, "Previous": null, "Offset": null, "Next": null, "Last": null, "Items": null, "Href": "https://apiuatna11.springcm.com/v201411/documents/00000000-0000-0000-0000-000000000000/sharelinks", "First": null }, "Path": null, "Href": "https://apiuatna11.springcm.com/v201411/documents/00000000-0000-0000-0000-000000000000", "EosParentInfo": null, "DownloadDocumentHref": "https://apidownloaduatna11.springcm.com/v201411/documents/00000000-0000-0000-0000-000000000000", "AttributeGroups": null }');
            response.setStatusCode(201);
            response.setStatus('Ok');
            return response;
            }

        if (request.getEndpoint().equals(environment.AuthEndpoint__c)) {
            response.setBody('{"AccessTokenValue":"accesstokenstub","ApiBaseUrl":"https://apiuatna11.springcm.com","ExpirationDateTime":"1900-01-01T00:00:00.000Z","Scope":"LoggedInUser"}');
            response.setStatusCode(200);
            response.setStatus('Ok');
            return response;
           }

        if (request.getEndpoint().startsWith('https://apidownloaduatna11.springcm.com/v201411/documents/00000000-0000-0000-0000-000000000000')) {
            response.setBodyAsBlob(Blob.valueOf('This is a blob'));
            response.setStatusCode(200);
            response.setStatus('Ok');
            return response;
            }

        if (request.getEndpoint().endsWith('/v201411/workflows')) {
            response.setBody('{"Name":"Test Workflow","StartDate":"1900-01-01T00:00:00.000Z","EndDate":"1900-01-01T00:00:00.000Z","Status":"","Info":"","Params":"","WorkflowDocuments":{"Href":"https://apiuatna11.springcm.com/v201411/workflows/00000000-0000-0000-0000-000000000000/documents"},"Href":"https://apiuatna11.springcm.com/v201411/folders/00000000-0000-0000-0000-000000000000"}');
            response.setStatus('Ok');
            response.setStatusCode(200);
            return response;
            }

        if (request.getEndpoint().contains('/v201411/folders')) {
            if (request.getMethod().equals('POST') && request.getBody().contains('EosInfo'))
                response.setBody('{"UpdatedDate": "1900-01-01T00:00:00.000Z", "UpdatedBy": "support@springcm.com", "ShareLinks": {"Total": null, "Limit": null, "Previous": null, "Offset": null, "Next": null, "Last": null, "Items": null, "Href": "https://apiuatna11.springcm.com/v201411/folders/00000000-0000-0000-0000-000000000000/sharelinks", "First": null }, "Path": null, "ParentFolder": {"UpdatedDate": null, "UpdatedBy": null, "ShareLinks": null, "Path": null, "ParentFolder": null, "Name": null, "Href": "https://apiuatna11.springcm.com/v201411/folders/00000000-0000-0000-0000-000000000000", "Folders": null, "EosParentInfo": null, "EosInfo": null, "Documents": null, "Description": null, "CreateDocumentHref": null, "CreatedDate": null, "CreatedBy": null, "BrowseDocumentsUrl": null, "AttributeGroups": null }, "Name": "Testing", "Href": "https://apiuatna11.springcm.com/v201411/folders/00000000-0000-0000-0000-000000000000", "Folders": {"Total": null, "Limit": null, "Previous": null, "Offset": null, "Next": null, "Last": null, "Items": null, "Href": "https://apiuatna11.springcm.com/v201411/folders/00000000-0000-0000-0000-000000000000/folders", "First": null }, "EosParentInfo": null, "EosInfo": {"Path": "SF", "ObjectType": "Salesforce.Account", "ObjectId": "000a00000000AaaAAA", "Name": "Account", "Folder": "https://apiuatna11.springcm.com/v201411/folders/00000000-0000-0000-0000-000000000000"}, "Documents": {"Total": null, "Limit": null, "Previous": null, "Offset": null, "Next": null, "Last": null, "Items": null, "Href": "https://apiuatna11.springcm.com/v201411/folders/00000000-0000-0000-0000-000000000000/documents", "First": null }, "Description": "", "CreateDocumentHref": "https://apiuploaduatna11.springcm.com/v201411/folders/00000000-0000-0000-0000-000000000000/documents{?name}", "CreatedDate": "1900-01-01T00:00:00.000Z", "CreatedBy": "support@springcm.com", "BrowseDocumentsUrl": "https://uatna11.springcm.com/atlas/Link/Folder/0000/00000000-0000-0000-0000-000000000000", "AttributeGroups": null }');
            else 
                response.setBody('{"UpdatedDate": "1900-01-01T00:00:00.000Z", "UpdatedBy": "support@springcm.com", "ShareLinks": {"Total": null, "Limit": null, "Previous": null, "Offset": null, "Next": null, "Last": null, "Items": null, "Href": "https://apiuatna11.springcm.com/v201411/folders/00000000-0000-0000-0000-000000000000/sharelinks", "First": null }, "Path": null, "ParentFolder": {"UpdatedDate": null, "UpdatedBy": null, "ShareLinks": null, "Path": null, "ParentFolder": null, "Name": null, "Href": "https://apiuatna11.springcm.com/v201411/folders/00000000-0000-0000-0000-000000000000", "Folders": null, "EosParentInfo": null, "EosInfo": null, "Documents": null, "Description": null, "CreateDocumentHref": null, "CreatedDate": null, "CreatedBy": null, "BrowseDocumentsUrl": null, "AttributeGroups": null }, "Name": "Testing", "Href": "https://apiuatna11.springcm.com/v201411/folders/00000000-0000-0000-0000-000000000000", "Folders": {"Total": null, "Limit": null, "Previous": null, "Offset": null, "Next": null, "Last": null, "Items": null, "Href": "https://apiuatna11.springcm.com/v201411/folders/00000000-0000-0000-0000-000000000000/folders", "First": null }, "EosParentInfo": null, "EosInfo": null, "Documents": {"Total": null, "Limit": null, "Previous": null, "Offset": null, "Next": null, "Last": null, "Items": null, "Href": "https://apiuatna11.springcm.com/v201411/folders/00000000-0000-0000-0000-000000000000/documents", "First": null }, "Description": "", "CreateDocumentHref": "https://apiuploaduatna11.springcm.com/v201411/folders/00000000-0000-0000-0000-000000000000/documents{?name}", "CreatedDate": "1900-01-01T00:00:00.000Z", "CreatedBy": "support@springcm.com", "BrowseDocumentsUrl": "https://uatna11.springcm.com/atlas/Link/Folder/0000/00000000-0000-0000-0000-000000000000", "AttributeGroups": null }');
            response.setStatusCode(200);
            response.setStatus('Ok');
            return response;
            }

        if (request.getEndpoint().contains('/v201411/documents')) {
            response.setBody('{"Version": null, "UpdatedDate": "1900-01-01T00:00:00.000Z", "UpdatedBy": "support@springcm.com", "ShareLinks": {"Total": null, "Limit": null, "Previous": null, "Offset": null, "Next": null, "Last": null, "Items": null, "Href": "https://apiuatna11.springcm.com/v201411/documents/00000000-0000-0000-0000-000000000000/sharelinks", "First": null }, "PreviewUrl": "https://uatna11.springcm.com/atlas/documents/preview.aspx?aid=0000&lduid=00000000-0000-0000-0000-000000000000", "Path": null, "ParentFolder": {"UpdatedDate": null, "UpdatedBy": null, "ShareLinks": null, "Path": null, "ParentFolder": null, "Name": null, "Href": "https://apiuatna11.springcm.com/v201411/folders/00000000-0000-0000-0000-000000000000", "Folders": null, "EosParentInfo": null, "EosInfo": null, "Documents": null, "Description": null, "CreateDocumentHref": null, "CreatedDate": null, "CreatedBy": null, "BrowseDocumentsUrl": null, "AttributeGroups": null }, "PageCount": 0, "Name": "Testing.docx", "Href": "https://apiuatna11.springcm.com/v201411/documents/00000000-0000-0000-0000-000000000000", "EosParentInfo": null, "DownloadDocumentHref": "https://apidownloaduatna11.springcm.com/v201411/documents/00000000-0000-0000-0000-000000000000", "Description": "", "CreatedDate": "1900-01-01T00:00:00.000Z", "CreatedBy": "support@springcm.com", "AttributeGroups": null }');
            response.setStatusCode(200);
            response.setStatus('Ok');
            return response;
            }

        return response;
        }
    }