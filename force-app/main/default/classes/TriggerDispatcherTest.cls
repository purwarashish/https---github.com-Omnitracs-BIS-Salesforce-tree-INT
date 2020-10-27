/**
 * Created by arman_shah on 10/17/18.
 */

@IsTest
private class TriggerDispatcherTest {
    @testSetup
    private static void setupTest() {
        pse__Proj__c proj = new pse__Proj__c(Name='Test SVR Project', Actual_start_date__c=Date.today());
        insert proj;

        Contact contactInstance=new Contact(FirstName='Test Contact', LastName='Test Last Name', Email='test@test.com');
        insert contactInstance;
    }

    @IsTest
    static void testBehavior() {
        pse__Proj__c proj = [SELECT Id FROM pse__Proj__c LIMIT 1];

        Attachment a = new Attachment(Name='Test Attachment 1', parentId = proj.Id,
                Body = EncodingUtil.base64Decode('Test Body'));
        List<Attachment> attachments = new List<Attachment>();
        attachments.add(a);

        Test.startTest();
        insert attachments;

        a.name = 'Test Update Attachment';
        update a;
        
        delete a;

        Test.stopTest();
    }
}