/**
 *
 * @author Avinash Kaltari, SF Developer, TCS

 * @date Sep 19, 2011
 
 * @description :   This is a Test class that contains the test method for the Opportunity Trigger (after insert, after update, after delete).

 */

@isTest(SeeAllData = true)
private class TestOpportunityAll 
{
    static testMethod void validateTestOppTriggerForPartnerScorecard() 
    {
        User olduser=[select Id,ContactId from User where IsPortalEnabled=true and isActive = true limit 1];
        
        Contact userContact=[select AccountId from Contact where Id= :olduser.ContactId];
        
        Account contactAccount=[select RecordTypeId from Account where Id= :userContact.AccountID];
        RecordType rp=[select ID from RecordType where Name='Partner Account (Reseller)'];
        
        contactAccount.RecordTypeId=rp.Id;
        update contactAccount;
        
        update userContact;
        update olduser;
        
        Opportunity testOpp=new Opportunity(Name='test',StageName='Shipped',CloseDate=Date.today(), CurrencyIsoCode='USD');
        
        //testOpp.OwnerId=olduser.Id;
		testOpp.OwnerId = UserInfo.getUserId();
        List<Opportunity> lsttestOpps = new List<Opportunity>();
        lsttestOpps.add(testOpp);
        insert lsttestOpps;
        
        Profile p = [select id from profile where name='Standard User'];
        User newuser = new User(alias = 'standt', email='standarduser1@omnitracs.com',
                          emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                          localesidkey='en_US', profileid = p.Id,
                          timezonesidkey='America/Los_Angeles', username='standarduser1237@omnitracs.com');
        insert newuser;
        testopp.OwnerId=newuser.Id;
        //lsttestOpps.add(testopp);
        update testopp;
        OpportunityLineItem o = new OpportunityLineItem(OpportunityId=testOpp.Id);
        o.Quantity = 5;
        o.PricebookEntryId = [Select p.IsActive, p.Id From PricebookEntry p where p.IsActive = true AND CurrencyIsoCode = 'USD' limit 1].id;
        o.TotalPrice = 5; 
        insert o;
        delete testOpp;
     }
     
    static testMethod void testOpportunityLostLogic() 
    {
       
       Account testAccount=new Account(Name='Opportunity Lost Logic Test',BillingStreet='street 345',BillingCity='city 345',BillingState= 'CA', BillingCountry='USA',BillingPostalCode='34512',Fleet_Size__c = 2,Segment__c='LTL',RecordTypeId='01250000000DQBA');
       insert testAccount;
       
       Opportunity testOpp=new Opportunity(Name='test',StageName='Shipped',CloseDate=Date.today());
       testOpp.AccountId = testAccount.id;
       insert testOpp;
       
       testOpp.StageName = 'Closed Lost';
       testOpp.Reason_Lost__c = 'Bankruptcy';
       testOpp.Reason_Lost_Comments__c = 'test comments';
       update testOpp;
       
       OpportunityUtils.checkIfClosedOpp(testOpp);
     }
}