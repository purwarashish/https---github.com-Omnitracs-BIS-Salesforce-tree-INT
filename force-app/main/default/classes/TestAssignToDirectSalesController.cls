@isTest(SeeAllData = true)
private class TestAssignToDirectSalesController {
    testMethod static void test_assignToDirectSales() {
    Profile p = [select id from profile where name = 'System Administrator'];
        User testUser = new User(
            alias = 'accttest'
            ,email = 'accounttest@omnitracs.com'
            ,emailencodingkey = 'UTF-8'
            ,lastname = 'Tester'
            ,languagelocalekey = 'en_US'
            ,localesidkey = 'en_US'
            ,profileid = p.Id
            ,timezonesidkey = 'America/Denver'
            ,username = 'accounttest@omnitracs.com'
            
        );   
        insert testUser;
        Account a1 = new Account(
            Name = 'Test Referral Account'
            ,BillingStreet='Test Billing Street 123'
            ,BillingCity='Test Billing City 123'
            ,BillingCountry='Test Billing Country 123'
            ,BillingPostalcode = '75052'
            ,BillingState = 'Test Billing State 123'
            ,fleet_size__c = 25
            ,segment__c = 'TL'
            ,QWBS_Status__c = 'Active'
            ,ownerId= testUser.id
            ,Account_Manager__c = testUser.Id
        );
        insert a1;
        
        Task activities = new Task(Subject='Acc Activity',whatId=a1.Id,OwnerId=a1.ownerId);
        insert activities;
        
        Event e2= new Event(whatId =a1.id ,subject='Test', ActivityDatetime= datetime.now(), DurationInMinutes=60);
        insert e2;
        
        
        Opportunity o= new Opportunity(Name='Brian Test',AccountId=a1.id, type='COA', stagename='S0-Suspect Pool', closedate=date.today());
        insert o;
        
        RecordType rtCont= [
                            select 
                                id,
                                name 
                            from
                                RecordType
                            where 
                                SobjectType =: 'contact'
                            and 
                                name = 'Sales' 
                        limit 1]; 
                        
        Contact cont2 = new Contact();
        cont2.FirstName='SFDC1';
        cont2.LastName='Salesforce1';
        cont2.Email = 'c_agang@qualcomm.com';
        cont2.RecordTypeId = rtCont.Id;
        cont2.AccountId = a1.id;
        insert cont2;
        AssignToDirectSalesController.assignToDirectSales(a1.id);
    }
}