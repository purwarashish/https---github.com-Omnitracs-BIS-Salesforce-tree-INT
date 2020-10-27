@istest (SeeAllData=true)
public with sharing class ContactAlertExtensionTest
{
    //  **********  test for ContactAlertExtension.cls   *******************************    
    public static testmethod void TestForContactAlertExtension()
    {
        Savepoint sp = Database.setSavepoint();
        
        Contact testContact;
        pagereference pageRef=new pagereference('Page.ContactAlert');
        test.setcurrentpage(pageRef);
        testContact = CreateTestContact(null, [select id from account limit 1].id);
        //declare apexpages.standardcontroller so that we can pass it into this class's constructor
        //Alert_Text__c field is having a Null value now
        ApexPages.standardController controller = new ApexPages.standardController(testContact);
        ContactAlertExtension testaae=new ContactAlertExtension(controller);
        
        //testaae.getshouldShowContactAlert();
        testaae.getcontact();
        boolean testbool = testaae.shouldShowAccountAlert;
        string testString = testaae.accountAlert;
        
        //Update any valid value for Alert_Text__c field
        Account acc = [select id, Alert_Text__c, Segment__c from account where id =: testContact.accountid];
        acc.Alert_Text__c = 'Account Updated';
        acc.Segment__c = 'LTL';
        update acc;
        //declare apexpages.standardcontroller so that we can pass it into this class's constructor
        ApexPages.standardController controller2 = new ApexPages.standardController(testContact);
        ContactAlertExtension testaae2=new ContactAlertExtension(controller2);
        
        //testaae.getshouldShowContactAlert();
        //testaae2.getcontact();
        boolean testbool2 = testaae2.shouldShowAccountAlert;
        string testString2 = testaae2.accountAlert;
        
        Database.rollback(sp);
    }
    
    private static Contact CreateTestContact(string recordTypeName, id accountId)
    {
        Contact testContact = new Contact();
        
        testContact.lastname = 'lastname';
        testContact.firstname = 'firstname';
        
        testContact.accountid = accountId;
        testContact.Contact_Alert__c = 'blarg';
        testContact.email = 'walmart@walmart.com';
        testcontact.phone = '410-555-5555';
        testcontact.title = 'title';
        testcontact.Decision_Maker_Influencer__c = 'No';
        
        database.saveResult sr = database.insert(testContact);
        if (sr.isSuccess())
        {
            return testContact;
        }
        else
        {
            return null;
        }
    }
}