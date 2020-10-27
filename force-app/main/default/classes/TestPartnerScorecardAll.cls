/**
 *
 * @author Avinash Kaltari, SF Developer, TCS

 * @date Sep 19, 2011
 
 * @description :   This is a Test class that contains the test method for the Partner Scorecard Trigger (after insert, after update, after delete).

 */

@isTest(SeeAllData=true)
private class TestPartnerScorecardAll 
{
    
    static testMethod void validateTestPartnerScorecard() 
    {
        test.startTest();
        List<Partner_Scorecard__c> lstDraftPS = new List<Partner_Scorecard__c>();
        List<Account> lstNewAccount=new List<Account>();
        Account a=new Account(Name='test',BillingStreet='street',BillingCity='city',BillingCountry='india');
        insert a;
        Partner_Scorecard__c patnerScorecardDraft=new Partner_Scorecard__c(Account__c=a.id);
        lstDraftPS.add(patnerScorecardDraft);
        //insert lstDraftPS;
        insert patnerScorecardDraft;
        test.stopTest();
    }
    
    public static testMethod void TestPartnerScoreCard()
    {
        test.startTest();
        Boolean isInsert =true;
        Date myCurrentDate = date.newinstance(2011, 09, 20);
        Date myPrevDate = date.newinstance(2011, 09, 19);
        Date myFutureDate = date.newinstance(2011, 09, 21);
        RecordType rp=[select ID from RecordType where Name='Partner Account (Reseller)'];
        List<Partner_Scorecard__c> lstNewPartnerScorecard=new List<Partner_Scorecard__c>();
      
      
        User olduser=[select Id,ContactId from  User where IsPortalEnabled=true and isActive = true limit 1];
        List<Contact> lstUserContact=[select AccountId from Contact where Id= :olduser.ContactId limit 1];
        Contact UserContact = lstUserContact[0];
        Account contactAccount=[select RecordTypeId from Account where Id= :userContact.AccountID];
        contactAccount.RecordTypeId=rp.Id;
        Account testaccount=new Account(Name='test',BillingStreet='street',BillingCity='city',BillingCountry='india',OwnerId=olduser.Id);
        insert testaccount;
        
        Lead testlead=new Lead(FirstName='test',Lastname='testlast',Company='tcs',OwnerId=olduser.Id,street ='active st',city='san diego',state='CA',country='USA',postalcode='92126');
        insert testlead;
        Opportunity testOpp=new Opportunity(Name='test',StageName='Shipped',OwnerId=olduser.Id,CloseDate=Date.today(),amount=12345,AccountId=contactAccount.id);
        insert testOpp;
        Serialized_Units__c testSerializedUnit=new Serialized_Units__c(Unit_Activation_Date__c=myCurrentDate,OwnerId=olduser.Id,Account__c=contactAccount.id);
        insert testSerializedUnit;
        update contactAccount;
        update userContact;
        update olduser;
        
        Partner_Scorecard__c patnerScorecardDraft=new Partner_Scorecard__c(Account__c=contactAccount.id,Current_Scorecard__c=true,Scorecard_Start_Date__c=myPrevDate,Scorecard_End_Date__c=myFutureDate);
        Partner_Scorecard__c patnerScorecardDraft1=new Partner_Scorecard__c(Account__c=testaccount.id,Current_Scorecard__c=true);
        lstNewPartnerScorecard.add(patnerScorecardDraft);
        lstNewPartnerScorecard.add(patnerScorecardDraft1);
        insert patnerScorecardDraft1;
        
        Partner_Scorecard__c patnerScorecardDraft2=new Partner_Scorecard__c(Account__c=testaccount.id,Current_Scorecard__c=true);
        //insert patnerScorecardDraft2;
        //patnerScorecardDraft2.Scorecard_Start_Date__c=myPrevDate;
        //update patnerScorecardDraft2;
        
        test.stopTest();
        
    }
    
    public static testMethod void TestPartnerScoreCardController()
    {
        test.startTest();
        Account a=new Account(Name='test',BillingStreet='street',BillingCity='San Diego',BillingCountry='US');
        insert a;
        Partner_Scorecard__c patnerScorecardDraft=new Partner_Scorecard__c(Account__c=a.id,Current_Scorecard__c=true);
        insert patnerScorecardDraft;
        ApexPages.StandardController controller=new ApexPages.StandardController(a);
        PartnerScorecardController PSC=new PartnerScorecardController(controller);
       
        Account a1=new Account(Name='test',BillingStreet='street',BillingCity='city',BillingCountry='india');
        insert a1;
        Partner_Scorecard__c patnerScorecardDraft1=new Partner_Scorecard__c(Account__c=a.id,Current_Scorecard__c=false);
        insert patnerScorecardDraft1;
        Partner_Scorecard__c patnerScorecardDraft2=new Partner_Scorecard__c(Account__c=a.id,Current_Scorecard__c=true);
        insert patnerScorecardDraft2;
        ApexPages.StandardController controller1=new ApexPages.StandardController(a1);
        ApexPages.currentPage().getParameters().put('id',a.id);
        PartnerScorecardController PSC1=new PartnerScorecardController(controller1);
        PSC1.updatePartnerScoreCard();
        test.stopTest();
   
    }
    
}