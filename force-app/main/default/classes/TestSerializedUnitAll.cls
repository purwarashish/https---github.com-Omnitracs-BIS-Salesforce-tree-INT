/**
 *
 * @author Avinash Kaltari, SF Developer, TCS

 * @date Sep 19, 2011
 
 * @description :   This is a Test class that contains the test method for the Serialized_Unit__c Trigger (after insert, after update, after delete).

 */

@isTest(SeeAllData=true)
private class TestSerializedUnitAll 
{
    static testMethod void validateTestSerializedUnitTrigger() 
    {
    
    
        User olduser=[select Id,ContactId from  User where IsPortalEnabled=true and IsActive = true limit 1];
        Contact userContact=[select AccountId from Contact where Id= :olduser.ContactId];
        Account contactAccount=[select RecordTypeId from Account where Id= :userContact.AccountID];
        RecordType rp=[select ID from RecordType where Name='Partner Account (Reseller)'];
        contactAccount.RecordTypeId=rp.Id;
        update contactAccount;
        update userContact;
        update olduser;
        Serialized_Units__c testSerializedUnit=new Serialized_Units__c();
        testSerializedUnit.OwnerId=olduser.Id;
        List<Serialized_Units__c> lstSerializedUnits = new List<Serialized_Units__c>();
        lstSerializedUnits.add(testSerializedUnit);
        insert lstSerializedUnits;
        
        Profile p = [select id from profile where name='Standard User'];
        User newuser = new User(alias = 'standt', email='standarduser@omnitracs.com',
                          emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                          localesidkey='en_US', profileid = p.Id,
                          timezonesidkey='America/Los_Angeles', username='standarduser123@omnitracs.com');
        insert newuser;
        testSerializedUnit.OwnerId=newuser.Id;
        
        NMC_Account__c nmc = new NMC_Account__c();
        
        nmc = [select name from NMC_Account__c limit 1];
        
        //nmc.Account__c = contactAccount.id;
        //nmc.NMC_Account_Name__c = 'ABCDE'; //contactAccount.name;
        //insert nmc;
        
        if(nmc.id != null || nmc.id != '')
            testSerializedUnit.NMC_Account__c = nmc.id;
        
        PartnerScorecardHelper.blnUpdateDateUnitMoved = true;
        update lstSerializedUnits;
        
        delete lstSerializedUnits;
    }
}