@isTest(SeeAllData= true)
public class TestTaskAll
{
  Static testmethod void test_TaskAll()
  {
    Profile p = [select id from profile where name = 'System Administrator'];
        User testUser = new User(
            alias = 'acnttest'
            ,email = 'test@omnitracs.com'
            ,emailencodingkey = 'UTF-8'
            ,lastname = 'Tester'
            ,languagelocalekey = 'en_US'
            ,localesidkey = 'en_US'
            ,profileid = p.Id
            ,timezonesidkey = 'America/Denver'
            ,username = 'test@omnitracs.com'
        );   
        insert testUser;
        
         Account a1 = new Account(
            Name = 'Test Referral Account'
            ,BillingStreet='Test Billing Street 123'
            ,BillingCity='Test City 123'
            ,BillingState='CA'
            ,BillingCountry='Test Billing Country 123'
            ,QWBS_Status__c = 'Active'
        );
        insert a1;
        
         Task newTask = new Task(Description = 'Teast Comment',
                                        Priority = 'High', 
                                        Subject = 'Case Subject', 
                                        OwnerId = testUser.Id,
                                        WhatId = a1.Id);
             
             insert newTask;                           
      
  
  }
}