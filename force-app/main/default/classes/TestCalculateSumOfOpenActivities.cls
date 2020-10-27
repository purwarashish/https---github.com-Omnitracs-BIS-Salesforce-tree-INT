@isTest(SeeAllData= true)
public Class TestCalculateSumOfOpenActivities {
    static testmethod void UpdateAccount(){
        Profile p = [select id from profile where Name='TL Sales Manager - Outlook'];         
        User u1 = new User(alias = 'test123', email='test123@omnitracs.com',            
        emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',            
        localesidkey='en_US', profileid = p.Id, country='United States',            
        timezonesidkey='America/Los_Angeles', username='test123@omnitracs.com');        
        insert u1;
        Account acc = new Account(Name='New Account',ownerId=u1.Id,BillingStreet='Acc Strt',BillingCity='Acc City'
                            ,BillingCountry='Acc Country' );
        insert acc;
        Task activities = new Task(Subject='Acc Activity',whatId=acc.Id,ownerId=u1.Id);
        insert activities;
        
        Event e2= new Event(whatId =acc.id ,subject='Test', ActivityDatetime= datetime.now(), DurationInMinutes=60);
        insert e2;
        
        List<Account> lstAct = new List<Account>();
        lstAct.add(acc);
        
         List<ID> accountRecordIds = new list<ID>();
                
                for(Account accData : lstAct)
                {
                    accountRecordIds.add(accData.id);
                }
                
                if(!accountRecordIds.isEmpty())
                {
                CalculateSumOfOpenActivities.calSumOfOpenActv(accountRecordIds);
                }
        
       
    }
}