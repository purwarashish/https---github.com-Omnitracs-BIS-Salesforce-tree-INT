@isTest(SeeAllData=True)
Private class TestSetNotificationTypeTrigger{
    static testMethod void testBulk(){
        List<Contact> contacts= new List<Contact>();
        profile p = [select id from profile where name='Marketing Admin'];
        User u = new User(alias = 'test123', email='test1234@omnitracs.com',
            emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
            localesidkey='en_US', profileid = p.Id, country='United States',
            timezonesidkey='America/Los_Angeles', username='test1234@omnitracs.com');
        
        insert u;   
        
        Account a= new Account(
            Name = 'Test Indirect Account'
            ,BillingStreet='Test Billing Street 123'
            ,BillingCity='Test Billing City 123'
            ,BillingCountry='Test Billing Country 123'
            ,QWBS_Status__c = 'Contract Customer'
            ,QWBS_Cust_Id__c='12312'
            ,BillingState = 'CA'
        ); 
        insert a;
         
        
        
            for (Integer i=0;i<205;i++){
              
                Contact c=  new contact(
                     AccountId = a.Id
                    ,OwnerId=u.Id 
                    ,FirstName = 'Test First'
                    ,LastName = 'Test Last'
                    ,MailingState = 'CA'
                );      
                contacts.add(c);  
              
                       
            }
            
            insert contacts;
            
            
            for(Contact cont:[SELECT NOtification_Type__C FROM Contact WHERE OwnerId =:u.Id ]){
                System.assertNotEquals(cont.Notification_Type__c,'');
            }  
        
    }

}