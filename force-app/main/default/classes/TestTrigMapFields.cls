/* Commented by Arindam Laik, Aug 26, 2015
    this is done as part of test class consolidation */ 
@isTest(SeeAllData = true)
public class TestTrigMapFields{
/*
static testMethod void myTestTrigMapFields()
 {
     UserLicense userLicense=[Select Name, Id From UserLicense  where Name='Gold Partner' limit 1];
       List<Profile> profileList =[Select Id From Profile  where UserLicenseId=:userLicense.Id limit 10]; //,UserType,UserLicenseId
       List<UserRole> role = [Select Id From UserRole  where Name ='Rush Enterprises Partner User' limit 1];
        system.debug('Test!!!'+profileList);
       if( (!(role.isEmpty())) && (!(profileList.isEmpty())) )
       {
     //User userobj=[select Id,u.UserRole.Name, u.UserRoleId, u.Profile.Name, u.ProfileId From User u
       //where u.ProfileId in :profileList and u.UserRoleId=:role[0].Id and isActive=true limit 1];
    User userobj=[select Id,u.UserRole.Name, u.UserRoleId, u.Profile.Name, u.ProfileId From User u
        where isActive=true  limit 1];
    system.runAs(userobj)
          {
            Lead testLead = new Lead(
           Company='Test Lead',
          FirstName='John',LastName='Doe',
          Status='Open',
           Street = '123 Main',
          City = 'San Diego',
            State='AB',
            Country = 'Canada',
           Phone='555-123-4567');
          insert testLead;
            Database.LeadConvert lc = new database.LeadConvert();
            lc.setLeadId(testlead.id);
          lc.setConvertedStatus('Qualified');
          Database.LeadConvertResult lcr = Database.convertLead(lc);
           Account newAccount1 = new Account( Name = 'test acct',
                                         QWBS_Market__c = 'T&L',
                                    BillingStreet = '123 Main',
                                         BillingCity = 'San Diego',
                                       BillingState = 'CA',
                                        BillingCountry = 'UK'
                                      );
                                       insert newAccount1;
            newAccount1.Partner_Agent__c=userobj.Id;
            update newAccount1;
           }
        }
 }
*/
}