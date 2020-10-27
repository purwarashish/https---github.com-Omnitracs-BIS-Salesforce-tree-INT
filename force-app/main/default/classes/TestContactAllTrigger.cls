/*******************************************************************************************************
Date: 7 Jan 2011

Author: Shruti Karn

Overview: Test class for "ContactAll" trigger 

*******************************************************************************************************/
@isTest(SeeAllData=true)
private class TestContactAllTrigger { 

    static testMethod void testDupContactEmail() {
    
        
        list<Contact> lstContact = new list<contact>();
        Account newAccount = new Account();
        newAccount.Name = 'SFDC';
        newAccount.Type = 'Other';
        newAccount.BillingStreet = 'Test Address';
        newAccount.BillingCity = 'Test City';
        newAccount.BillingCountry = 'Test Country';
        newAccount.QWBS_Status__c = 'Contract Customer';
        newAccount.QWBS_Cust_ID__c = '4567';
        
        insert newAccount;
        Contact newcnt=new Contact();
        newcnt.FirstName='SFDC';
        newcnt.LastName='Salesforce';
        newcnt.Email = 'c_skarn@qualcomm.com';
        newcnt.MailingState = 'CA';
        newcnt.AccountId=newAccount.Id;
        
        Profile p = [select id from profile where id='00e50000000mzNu'];         
        User u1 = new User(alias = 'test123', email='test12@omnitracs.com',            
        emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',            
        localesidkey='en_US', profileid = p.Id, country='United States',            
        timezonesidkey='America/Los_Angeles', username='test123@omnitracs.com');        
        insert u1;
        
        try
        {
            system.runAs(u1)
            {
                insert newcnt;
                Contact newcnt1=new Contact();
                newcnt1.FirstName='SFDC';
                newcnt1.LastName='Salesforce';
                newcnt1.Email = 'test@test.com';
                newcnt1.AccountId=newAccount.Id;
                newcnt1.MailingState = 'CA';
                insert newcnt1;
                
                newcnt.Email='test123@test123.com';
                newcnt1.Email='test123@test123.com';
                lstcontact.add(newcnt);
                lstcontact.add(newcnt1);
                update lstcontact;
                
                newcnt1.Email='c_skarn@qualcomm.com';
                update newcnt;
                
                lstcontact.clear();
                
                Contact newcnt2=new Contact();
                newcnt2.FirstName='SFDC';
                newcnt2.LastName='Salesforce';
                newcnt2.Email = 'c_skarn@qualcomm.com';
                newcnt2.AccountId=newAccount.Id;
                newcnt2.MailingState = 'CA';
                newcnt2.AccountId=newAccount.Id;
                lstcontact.add(newcnt2);
                
                Contact newcnt3=new Contact();
                newcnt3.FirstName='SFDC';
                newcnt3.LastName='Salesforce';
                newcnt3.Email = 'test123@test123.com';
                newcnt3.MailingState = 'CA';
                newcnt3.AccountId=newAccount.Id;
                lstcontact.add(newcnt3);
                
                insert lstcontact;
                
                newcnt.Email = 'c_skarn@qualcomm.com';
                update newcnt;
            
            }
        }
        catch(Exception e)
        {
            system.debug('Exception:'+e);
        }

    }
    
     static testMethod void testDupContactEmail1() {
     list<Contact> lstContact = new list<contact>();
        Profile p = [select id from profile where id='00e50000000mzNu'];         
        
        User u1 = new User(alias = 'test123', email='test123@omnitracs.com',            
        emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',            
        localesidkey='en_US', profileid = p.Id, country='United States',            
        timezonesidkey='America/Los_Angeles', username='test123@omnitracs.com');        
        insert u1;
        
        final Account created = new Account(name='test 123', BillingStreet='123 somewhere', 
            BillingCity='San Diego', BillingState='CA', BillingCountry='USA',QWBS_Cust_ID__c = '4567');
        insert created;
        
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
        
        system.runAs(u1)
        {
            for(integer i=0;i<3;i++)
            {
            Contact newcnt2=new Contact();
            newcnt2.FirstName='SFDC';
            newcnt2.LastName='Salesforce';
            newcnt2.MailingState = 'CA';
            newcnt2.AccountId=created.id;
               
            newcnt2.Email = 'test@test.com';
            lstcontact.add(newcnt2);
            }
            Contact newcnt3=new Contact();
            newcnt3.FirstName='SFDC';
            newcnt3.LastName='Salesforce';
               
            newcnt3.Email = 'c_skarn@qualcomm.com';
            newcnt3.MailingState = 'CA';
            newcnt3.AccountId=created.id;
            lstcontact.add(newcnt3);
            insert lstcontact;
            
        }
        
     }
}