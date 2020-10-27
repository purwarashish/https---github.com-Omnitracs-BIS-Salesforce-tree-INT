@isTest
public class AvoidDuplicateUsageEntryTrigger_Test {
   /* public static testmethod void testForAvoidDuplicateUsageEntryTrigger()
    {
        //  PLEASE NOTe that i did not create this trigger, it came with a package but i get problems whent rying to deploy
        //  saying that code coverage is needed... so here it is
        Savepoint sp = Database.setSavepoint();
       
        //  create test rfp
        RFP__c testRFP = new RFP__c();
        testRfp.Due_date__c = date.today();
        Database.saveResult sr = database.insert(testRfp);
       
        testRfp = [select id from RFP__c where id =: sr.getId()];
       
        //  then the response
        Response__c testResponse = new Response__c();
        sr = database.insert(testResponse);
        testResponse = [select id from Response__c where id =: sr.getId()];
       
        //  now finally the question
        Question__c q = new Question__c();
        q.Override_Warning__c = true;
        q.rfp__c = testRfp.id;
        q.Response__c = testResponse.id;
        
        insert q;
        Database.rollback(sp);
    }*/
}