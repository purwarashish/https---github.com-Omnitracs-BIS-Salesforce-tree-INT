/**
 *
 * @author Avinash Kaltari, SF Developer, TCS

 * @date Sep 19, 2011
 
 * @description :   This is a Test class that contains the test method for the Lead Trigger (after insert, after update, after delete).

 */
/* Commented by Arindam Laik, Aug 26, 2015
   As we have a test class for Lead trigger
   this is done as part of trigger consolidation */ 
    
@isTest(SeeAllData=true)
private class TestLeadAll 
{
/*
    static testMethod void validateTestLeadTriggerForPartnerScorecard() 
    {
    
    
        PartnerScorecardHelper temp = new PartnerScorecardHelper();
        
        User olduser=[select Id,ContactId from  User where IsPortalEnabled=true and isActive = true limit 1];
        Contact userContact=[select AccountId from Contact where Id= :olduser.ContactId];
        Account contactAccount=[select RecordTypeId from Account where Id= :userContact.AccountID];
        RecordType rp=[select ID from RecordType where Name='Partner Account (Reseller)'];
        contactAccount.RecordTypeId=rp.Id;
        update contactAccount;
        update userContact;
        update olduser;
        Lead testlead=new Lead(FirstName='test',Lastname='testlast',Company='tcs',City='Sacramento', State='CA', Country='US');
        testlead.OwnerId=olduser.Id;
        List<Lead> lsttestleads = new List<Lead>();
        lsttestleads.add(testlead);
        insert lsttestleads;
        
        Profile p = [select id from profile where name='Standard User'];
        User newuser = new User(alias = 'standt', email='standarduser@omnitracs.com',
                          emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                          localesidkey='en_US', profileid = p.Id,
                          timezonesidkey='America/Los_Angeles', username='standarduser123@omnitracs.com');
        insert newuser;
        testlead.OwnerId=newuser.Id;
        
        PartnerScorecardHelper.blnUpdateAssignedDate = true;
        update testlead;
        
        //update lsttestleads;
        
        //delete testlead;
    
    }
    
    static testMethod void validateTestDataSharePartnerUpdate() 
    {
        
        Lead testlead=new Lead(FirstName='test',Lastname='testlast',Company='tcs',City='city',State= 'CA',Country='USA');
        Account refAcc=new Account(Name='FedEx Ground Test',BillingStreet='street',BillingCity='city',BillingState= 'CA',BillingCountry='United States',RecordTypeId='01250000000QuZt');
        insert testlead;
        insert refAcc;
        Data_Sharing_Partner__c dsp = new Data_Sharing_Partner__c();
        dsp.Name = 'FedEx Ground Test';
        dsp.Related_Account__c = refAcc.id;
        insert dsp;
        testlead.Referral_Account__c = refAcc.id;
        update testlead;
        
    }
    
    static testMethod void validateCheckIfNeedsToFireAssignmentRules()
    {
        User currentUser = [select id ,Username from User where id = '00550000001ZqiO' limit 1];
        Lead testlead=new Lead(FirstName='test',Lastname='testlast',Company='tcs',City='city',State= 'CA',Country='United States');
        insert testlead;
        //System.runAs(currentUser)
        {
            update testlead;
        }
    }
 */   
}