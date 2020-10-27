/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest(SeeAllData=true)
private class TestLogInviteEmailAsTask {

    static testMethod void myUnitTest() {
        
        // TO DO: implement unit test
        Account a = new Account();
        a.name='test';
        a.BillingCity = 'San Diego';
        a.BillingCountry = 'USA';
        a.BillingState = 'CA';
        a.BillingStreet = 'test';
        a.BillingPostalCode = '92126';
        insert a;
        Contact c = new Contact ();
        c.FirstName = 'test';
        c.LastName = 'test';
        c.accountid= a.id;
        c.UnityInviteToken__c = '123';
        c.Unity_Invitor__c = 'test invitor';
        c.Unity_Invitor_Email__c = 'test@test.com';
        c.Unity_Invitor_Title__c = 'test title';        
        insert c;
        
        task t1 = new task();
        t1.subject = LogInviteEmailsAsTask.SALES_INVITE;
        t1.WhoId = c.id;
        t1.Status='Completed';
        insert t1;
        
        task t2 = new task();
        t2.subject = LogInviteEmailsAsTask.COLLEAGUE_INVITE;
        t2.WhoId = c.id;
        t2.Status='Completed';
        insert t2;
        
        
    }
}