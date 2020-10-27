/*******************************************************************************************************
Date: 7 Jan 2011

Author: Shruti Karn

Overview: Test class for "ContactAll" trigger 

Modified by : Avinash Kaltari
Date : 04 Noc, 2011
Comment : Added test code for ContactAll Trigger

*******************************************************************************************************/
@isTest(seeAllData=true)
private class TestContactAll { 

    static testMethod void testDupContactEmail() {
        final Account created = new Account(name='test 123', BillingStreet='123 somewhere', 
            BillingCity='San Diego', BillingState='CA', BillingCountry='USA',QWBS_Cust_ID__c = '4567',QWBS_Status__c='Contract Customer');
        insert created;
    
        
        list<Contact> lstContact = new list<contact>();
        Contact newcnt=new Contact();
        newcnt.FirstName='SFDC';
        newcnt.LastName='Salesforce';
        newcnt.Email = 'c_skarn@qualcomm.com';
        newcnt.MailingState = 'CA';
        newcnt.AccountId=created.Id;
        insert newcnt;
        Contact newcnt1=new Contact();
        newcnt1.FirstName='SFDC';
        newcnt1.LastName='Salesforce';
        newcnt1.Email = 'test@test.com';
        newcnt1.MailingState = 'CA';
        newcnt1.AccountId=created.Id;
        insert newcnt1;
        newcnt1.Email='example@test.com';
        update newcnt1;                

        
        Profile p = [select id from profile where id='00e500000017Cfl'];         
        User u1 = new User(alias = 'test123', email='test123@omnitracs.com',            
        emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',            
        localesidkey='en_US', profileid = p.Id, country='United States',            
        timezonesidkey='America/Los_Angeles', username='test123@omnitracs.com');        
        insert u1;
        
        try
        {
            system.runAs(u1)
            {
/*
                insert newcnt;
                Contact newcnt1=new Contact();
                newcnt1.FirstName='SFDC';
                newcnt1.LastName='Salesforce';
                newcnt1.Email = 'test@test.com';
                insert newcnt1;
                newcnt1.Email='c_skarn@qualcomm.com';
                update newcnt1;                

                newcnt.Email='test123@test123.com';
                newcnt1.Email='test123@test123.com';
                lstcontact.add(newcnt);
                lstcontact.add(newcnt1);
                update lstcontact;
               
*/
                
                lstcontact.clear();
                
                Contact newcnt2=new Contact();
                newcnt2.FirstName='SFDC';
                newcnt2.LastName='Salesforce';
                newcnt2.Email = 'example1@test.com';
                newcnt2.MailingState = 'CA';
                newcnt2.AccountId=created.Id;
                lstcontact.add(newcnt2);
                
                Contact newcnt3=new Contact();
                newcnt3.FirstName='SFDC';
                newcnt3.LastName='Salesforce';
                newcnt3.Email = 'test123@test123.com';
                newcnt3.MailingState = 'CA';
                newcnt3.AccountId=created.Id;
                lstcontact.add(newcnt3);
                
                insert lstcontact;
                
                newcnt3.Email = 'example2@test.com';
                update newcnt3;
            
            }
        }
        catch(Exception e)
        {
            system.debug('Exception:'+e);
        }

    }
    
     static testMethod void testDupContactEmail1() {
     list<Contact> lstContact = new list<contact>();
     Profile p = [select id from profile where id='00e50000000owzT'];         
        User u1 = new User(alias = 'test123', email='test123@omnitracs.com',            
        emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',            
        localesidkey='en_US', profileid = p.Id, country='United States',            
        timezonesidkey='America/Los_Angeles', username='test123@omnitracs.com');        
        insert u1;
        
        final Account created = new Account(name='test 123', BillingStreet='123 somewhere', 
            BillingCity='San Diego', BillingState='CA', BillingCountry='USA',QWBS_Cust_ID__c = '4567',QWBS_Status__c='Contract Customer');
        insert created;
        
        Contact newcnt=new Contact();
        newcnt.FirstName='SFDC';
        newcnt.LastName='Salesforce';
        newcnt.Email = 'c_skarn@qualcomm.com';
        newcnt.MailingState = 'CA';
        newcnt.AccountId=created.Id;
        insert newCnt;
        
        Contact newcnt1=new Contact();
        newcnt1.FirstName='SFDC';
        newcnt1.LastName='Salesforce';
        newcnt1.Email = 'test@test.com';
        newcnt1.MailingState = 'CA';
        newcnt1.AccountId=created.Id;
        insert newCnt1;
        system.runAs(u1)
        {
            for(integer i=0;i<3;i++)
            {
            Contact newcnt2=new Contact();
            newcnt2.FirstName='SFDC';
            newcnt2.LastName='Salesforce';
            newcnt2.MailingState = 'CA';   
            newcnt2.Email = 'test@test.com';
            newcnt2.AccountId=created.Id;
            
            lstcontact.add(newcnt2);
            }
            Contact newcnt3=new Contact();
            newcnt3.FirstName='SFDC';
            newcnt3.LastName='Salesforce';
               
            newcnt3.Email = 'test@test.com';
            newcnt3.MailingState = 'CA';
            newcnt3.AccountId=created.Id;
            lstcontact.add(newcnt3);
            insert lstcontact;
            
            newcnt.Email='test123@test123.com';
            newcnt1.Email='test123@test123.com';
            lstcontact.add(newcnt);
            lstcontact.add(newcnt1);
           update lstcontact;
            
            
            
            
        }
        
     }
     
/*** Test code for ContactAll Trigger ***/
    static testMethod void validateTestContactTriggerForPartnerScorecard() 
    {
    
    
        RecordType rp=[select ID from RecordType where Name='Partner Account (Reseller)'];
        Account oldAccount=new Account(Name='test',BillingStreet='street',BillingCity='city',BillingCountry='india',QWBS_Status__c = 'Contract Customer',QWBS_Cust_ID__c='234233');
        insert oldAccount;
        
        Contact testcontact=new Contact(FirstName='test',Lastname='testlast',AccountId=oldAccount.Id,MailingState = 'CA');
      
        List<Contact> lsttestcontacts = new List<Contact>();
        lsttestcontacts.add(testcontact);
        insert lsttestcontacts;
        Account newAccount=new Account(Name='test3',BillingStreet='street',BillingCity='city',BillingCountry='india',RecordTypeId=rp.Id,QWBS_Status__c = 'Contract Customer',QWBS_Cust_ID__c='234243');
        insert newAccount;
        
        testcontact.AccountId=newAccount.Id;
        update lsttestcontacts;
        
        //delete testcontact;
    
    }
/*** END Test code for ContactAll Trigger ***/
}