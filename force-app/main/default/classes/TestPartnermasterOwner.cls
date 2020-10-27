/**
 *@Author: Amrita Ganguly
 *@Description: This class contain unit test cases for
 *              validating the behaviour of PartnerMasterOwnerController
 *@Date: 9th Apr,2012  
**/
@isTest(SeeAllData=true)
private class TestPartnermasterOwner
{
    static testMethod void myUnitTest()
    {
        RecordType rtAcct= [
                        select 
                            id,
                            name 
                        from
                            RecordType
                        where 
                            SobjectType =: 'Account'
                        and 
                            name = 'Partner Account (Reseller)' 
                        limit 1];
         
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
        Profile p = [select
                         id
                     from
                         profile
                     where
                         name = 'Reseller Partner Profile (No MDF)'
                     limit 1];
                     
        Account acct = [select 
                               id
                        from
                            account
                        where 
                            name = 'PANA-PACIFIC'
                        limit 1];                   
                                                    
        User mp = [select id from user where Name = 'Pana Pacific' or Name = 'Pana Pana-Pacific' limit 1];
        Contact newcnt=new Contact();  
        newcnt.FirstName='SFDC';
        newcnt.LastName='Salesforce';
        newcnt.Email = 'c_agang@qualcomm.com';
        newcnt.RecordTypeId = rtCont.Id;
        newcnt.AccountId = acct.id;
        insert newcnt;
        system.debug('@@@@newcnt'+ newcnt);                        
        
        user partnerUser = new user(
                                    alias = 'standt',
                                    email='standarduser@testorg1.com',
                                    emailencodingkey='UTF-8',
                                    lastname='Testing',
                                    
                                    languagelocalekey='en_US',
                                    localesidkey='en_US',timezonesidkey='America/Los_Angeles', 
                                    username='standarduser111@testorg1.com',ContactId = newcnt.id,ProfileId=p.Id,
                                    Master_Partner_User__c = mp.Id);

        insert partnerUser;
        
        user partneruser1 = [select id,name,accountId from user where usertype ='PowerPartner' and isActive = true limit 1 ];
        system.debug('^^^^partneruser1'+ partneruser1);
        Account acc = new Account(Name='New Account',ownerId=mp.Id,RecordOwner__c=partneruser1.Id,BillingStreet='Acc Strt',BillingCity='Acc City',
                            BillingCountry='Acc Country', Segment__c = 'TL', billingstate = 'MD', BillingPostalCode = '21286', Fleet_Size__c = 25);
        insert acc;
            
        Task activities = new Task(Subject='Acc Activity',whatId=acc.Id,OwnerId=acc.RecordOwner__c);
        insert activities;
        
        Event e2= new Event(whatId =acc.id ,subject='Test', ActivityDatetime= datetime.now(), DurationInMinutes=60);
        insert e2;
        
        
        Opportunity o= new Opportunity(Name='Brian Test',AccountId=acc.id, type='COA', stagename='S0-Suspect Pool', closedate=date.today());
        insert o;
        
        Contact cont2 = new Contact();
        cont2.FirstName='SFDC1';
        cont2.LastName='Salesforce1';
        cont2.Email = 'c_agang@qualcomm.com';
        cont2.RecordTypeId = rtCont.Id;
        cont2.AccountId = acc.id;
        insert cont2;
                
        ApexPages.currentPage().getParameters().put('Id',acc.id);
        ApexPages.StandardController cnt = new ApexPages.StandardController(acc);
        PartnerMasterOwnerController PMO = new PartnerMasterOwnerController(cnt);
        PMO.SelectedOwnerId = partnerUser.id;
        PMO.isSendEmail = true;
        PMO.isTransferOpenActivity = true;
        PMO.isTransferCont = true;
        PMO.isTransferOpp = true;
        PMO.AssignUserOrQueue(); 
        PMO.throwError('error_exception','abc_exception'); 
        PMO.getisNotTrasnferrableToPartner();
    } 

}