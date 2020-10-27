@isTest(seeAllData = true)
private class TestPartnerScoreAll
{
    static testMethod void validate()
    {
         
         Date myCurrentDate = date.newinstance(2012, 05, 31);
         Date myPrevDate = date.newinstance(2011, 09, 19);        
         Date myFutureDate = date.newinstance(2012, 09, 21);
         
         Account a = new Account(Name='test',
                                 BillingStreet='street',
                                 BillingCity='city',
                                 BillingCountry='india');
         insert a;        
         Partner_Scorecard__c patnerScorecardDraft = new Partner_Scorecard__c(Account__c=a.id,
                                                                              Current_Scorecard__c=true,
                                                                              Scorecard_Start_Date__c=myPrevDate,
                                                                              Scorecard_End_Date__c=myFutureDate);
         insert patnerScorecardDraft;
         
         Partner_Scorecard__c patnerScorecardDraft1 = new Partner_Scorecard__c(Account__c=a.id,
                                                                              Current_Scorecard__c=true,
                                                                              Scorecard_Start_Date__c=myPrevDate,
                                                                              Scorecard_End_Date__c=myFutureDate);
         insert patnerScorecardDraft1;

         
         UpdateScoreCard.updatePartnerScoreCard(a.id);
         //PartnerScoreCardUtils.intClassVisitCount = 1;
         UpdateScoreCard.updatePartnerScoreCard(a.id);
         
         RecordType rp=[select 
                             ID 
                        from 
                            RecordType
                        where
                            Name='Partner Account (Reseller)' 
                        limit 1];
                        
         User olduser=[select 
                             Id,
                             ContactId
                       from  
                             User
                       where 
                             IsPortalEnabled=true
                         and 
                             isActive = true 
                       limit 1];
         system.debug(olduser);                      
         Contact userContact=[select 
                                 AccountId
                              from 
                                  Contact
                              where 
                                  Id= :olduser.ContactId
                              limit 1];
                  
          Account contactAccount=[select 
                                      RecordTypeId 
                                  from 
                                      Account 
                                  where 
                                      Id= :userContact.AccountID];        
          contactAccount.RecordTypeId=rp.Id;
          update contactAccount;
          
          Partner_Scorecard__c patnerScorecardDraft2 = new Partner_Scorecard__c(Account__c=contactAccount.id,
                                                                              Current_Scorecard__c=true,
                                                                              Scorecard_Start_Date__c=myPrevDate,
                                                                              Scorecard_End_Date__c=myFutureDate);
         insert patnerScorecardDraft2;
         
         a.ownerId = olduser.id;
         a.QWBS_Cust_ID__c = '67890';
         update a;

         Lead testlead=new Lead(FirstName='test',
                                Lastname='testlast',
                                Company='tcs',
                                OwnerId=olduser.Id,
                            //  Assigned_Date__c=Date.today(),
                                LeadSource = 'web',
                                isConverted=false,
                                City='San Diego',
                                State='CA',
                                Country='US');        
         insert testlead; 
         system.debug('testlead'+testlead); 
         
         Lead testlead2=new Lead(FirstName='test',
                                Lastname='testlast',
                                Company='tcs',
                                OwnerId=olduser.Id,
                                City='San Diego',
                                State='CA',
                                Country='US'
                                );
      
         insert testlead2; 

         Opportunity testOpp=new Opportunity(Name='test',
                                             StageName='Shipped',
                                             OwnerId=olduser.Id,
                                             CloseDate=Date.today(),
                                             amount=12345,
                                             AccountId=contactAccount.id);        
         insert testOpp; 
         system.debug('testOpp'+testOpp);
              
         Serialized_Units__c testSerUnit=new Serialized_Units__c(Unit_Activation_Date__c=myCurrentDate,
                                                                 OwnerId=olduser.Id,
                                                                 Account__c=a.id,
                                                                 NMC_state__c='Activated',
                                                                 Date_Unit_Moved__c=Date.today());        
         insert testSerUnit;
         
         
         system.debug('testSerializedUnit'+testSerUnit);
         
         Partner_Scorecard__c patnerScorecardDraft3 = new Partner_Scorecard__c(Account__c=contactAccount.id,
                                                                              Current_Scorecard__c=true,
                                                                              Scorecard_Start_Date__c=myPrevDate,
                                                                              Scorecard_End_Date__c=myFutureDate);
         insert patnerScorecardDraft3;

 
         
    }
}