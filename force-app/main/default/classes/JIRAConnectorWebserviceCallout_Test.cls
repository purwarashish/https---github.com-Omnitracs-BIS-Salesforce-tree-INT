@isTest(seeAllData=true)
public class JIRAConnectorWebserviceCallout_Test{
    public static testMethod void testJIRACallout(){
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorSuccess());
        Id escalateRecordType = SystemIds__c.getInstance().RecordTypeId_Case_Engineering__c;
        Case testCase = new Case(subject = 'testCase', JIRA_Issue__c = '1');
        insert testCase;
        testCase.recordTypeId = escalateRecordType;
        testCase.JIRA_Issue__c = '2';
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorSuccess());
        JIRAConnectorWebserviceCallout.createIssue(testCase.Id);
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorFail());
        JIRAConnectorWebserviceCallout.createIssue(testCase.Id);
    }
}