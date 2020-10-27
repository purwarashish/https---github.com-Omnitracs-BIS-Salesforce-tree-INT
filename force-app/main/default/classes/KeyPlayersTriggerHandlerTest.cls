/**********************************************************
* @Author       Heidi Tang 
* @Date         2016-04-25
* @Description  Test class for KeyPlayersTriggerHandler
* @Requirement  REQ-0482 Auto-populate Contact Roles with Key Players/Influencers value.
**********************************************************/
@isTest(seeAllData = true)
public with sharing class KeyPlayersTriggerHandlerTest {
    /*@testSetup static void testDataBuilder() {
        
        User internalUser = TestDataFactory.createInternalSysAdminUser('usertest@companytest.com','Testing','usertest@companytest.com','test123');
        insert internalUser;
        
                            
        System.runAs(internalUser){

            List<Account> acctList = TestDataFactory.createAcctList(4,'Test Account');
            insert acctList; 

            List<Contact> conList = TestDataFactory.createConList(4,'testCon');
            conList[0].AccountId = acctList[0].Id;
            conList[1].AccountId = acctList[1].Id;
            conList[0].AccountId = acctList[2].Id;
            conList[1].AccountId = acctList[3].Id;
            insert conList;
            
            Opportunity newOpp = new Opportunity(AccountId = acctList[0].Id,Name='Test Opportunity',StageName= '1 - Plan', CloseDate=Date.today());
            insert newOpp;
        }
    }*/
    
    public static testMethod void testInsert(){  
		Opportunity newOpp = [SELECT Id FROM Opportunity LIMIT 1];
        List<Contact> contactList = new List<Contact>([SELECT Id FROM Contact LIMIT 5]);
        
		OpportunityContactRole contactRole = new OpportunityContactRole(ContactId = contactList[1].Id,OpportunityId=newOpp.Id,Role='Legal');
		insert contactRole;
		
		List<Key_Players_Influencers__c> keyPlayerList = new List<Key_Players_Influencers__c>();
		keyPlayerList.addAll(TestDataFactory.createKeyInfluencer(4,'Legal',newOpp.Id));
		keyPlayerList[0].Name__c = contactList[0].Id;
		keyPlayerList[1].Name__c = contactList[1].Id;
		keyPlayerList[2].Name__c = contactList[2].Id;
		keyPlayerList[3].Name__c = contactList[3].Id;

		Test.startTest();
			insert keyPlayerList;

			List<OpportunityContactRole> contactRoleList = new List<OpportunityContactRole>([SELECT Id FROM OpportunityContactRole WHERE Role = 'Legal']);
			System.assert(contactRoleList.size()>0);

			Boolean isError = false;
			
			keyPlayerList.addAll(TestDataFactory.createKeyInfluencer(4,'Legal',newOpp.Id));
			keyPlayerList[4].Name__c = contactList[0].Id;

			try{
				insert keyPlayerList;
			} catch(DmlException dmle){
				isError = true;
			}
			
			System.assert(isError);
		Test.stopTest();
    }
    
    public static testMethod void testUpdate(){   
        Opportunity newOpp = [SELECT Id FROM Opportunity LIMIT 1];
        List<Contact> contactList = new List<Contact>([SELECT Id FROM Contact LIMIT 5]);
        
        OpportunityContactRole contactRole = new OpportunityContactRole(ContactId = contactList[1].Id,OpportunityId=newOpp.Id,Role='Legal');
		insert contactRole;
		
		List<Key_Players_Influencers__c> keyPlayerList = TestDataFactory.createKeyInfluencer(4,'Legal',newOpp.Id);
		keyPlayerList[0].Name__c = contactList[0].Id;
		keyPlayerList[1].Name__c = contactList[1].Id;
		keyPlayerList[2].Name__c = contactList[2].Id;
		keyPlayerList[3].Name__c = contactList[3].Id;
		insert keyPlayerList;

		Test.startTest();
			keyPlayerList[0].Formal_Role__c = 'Business User';
			keyPlayerList[1].Formal_Role__c = 'Decision Maker';
			keyPlayerList[2].Formal_Role__c = 'Legal';
			keyPlayerList[3].Formal_Role__c = 'Decision Maker';
			
			update keyPlayerList;

			List<OpportunityContactRole> contactRoleList = new List<OpportunityContactRole>([SELECT Id FROM OpportunityContactRole WHERE Role = 'Department']);
			
			System.assert(contactRoleList.size()==0);

			keyPlayerList[1].Formal_Role__c = 'Decision Maker';
			update keyPlayerList;

			
			Boolean isError = false;
			
			try{
				keyPlayerList[2].Name__c = contactList[0].Id;
				update keyPlayerList;
			} catch(DmlException dmle){
				isError = true;
			}
			
			System.assert(isError);
		Test.stopTest();
    }
    
    public static testMethod void testDelete(){   
        Opportunity newOpp = [SELECT Id FROM Opportunity LIMIT 1];
        List<Contact> contactList = new List<Contact>([SELECT Id FROM Contact LIMIT 5]);
        
		OpportunityContactRole contactRole = new OpportunityContactRole(ContactId = contactList[1].Id,OpportunityId=newOpp.Id,Role=null);
		insert contactRole;
		
		List<Key_Players_Influencers__c> keyPlayerList = TestDataFactory.createKeyInfluencer(4,'Legal',newOpp.Id);
		keyPlayerList[0].Name__c = contactList[0].Id;
		keyPlayerList[1].Name__c = contactList[1].Id;
		keyPlayerList[2].Name__c = contactList[2].Id;
		keyPlayerList[3].Name__c = contactList[3].Id;
		insert keyPlayerList;

		Test.startTest();
			delete keyPlayerList;
			List<OpportunityContactRole> contactRoleList = new List<OpportunityContactRole>([SELECT Id FROM OpportunityContactRole WHERE Role = 'Legal']);
			//System.assert(contactRoleList.size()==0);
		Test.stopTest();
    }
}