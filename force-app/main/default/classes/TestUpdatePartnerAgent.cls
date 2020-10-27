@isTest(SeeAllData = true)
public class TestUpdatePartnerAgent {
static testMethod void updatePartnerAgent ()
{
    UserLicense userLicense=[Select Name, Id From UserLicense  where Name='Gold Partner' limit 1];
//  System.debug('Length of userLicense'+userLicense.length);
    List<Profile> profile=[Select Id From Profile  where UserLicenseId=:userLicense.Id ];
    System.debug('Length of profile'+profile.size());
    List<UserRole> role=[Select Id From UserRole  where Name ='Rush Enterprises Partner User' limit 1];
    System.debug('Length of UserRole'+role.size());

    if(!role.isEmpty())
    {
    //User userobject=[select Id,u.UserRole.Name, u.UserRoleId, u.Profile.Name, u.ProfileId From User u
    //where u.ProfileId in :profile and u.UserRoleId=:role[0].Id and isActive=true limit 1];
    User userobject = [select Id,u.UserRole.Name, u.UserRoleId, u.Profile.Name, u.ProfileId From User u where isActive=true  limit 1]; 
    // User userobject  = [select Id,u.UserRole.Name, u.UserRoleId, u.Profile.Name, u.ProfileId From User u where u.IsActive = true limit 1];
    //if(!profile.isEmpty())
     //   userobject.ProfileId = profile[0].Id;
    //userobject.UserRoleId=role[0].Id;
     update userobject;
    system.runAs(userobject)
    {
    Account newAccount = new Account( Name = 'test acct',
                                     QWBS_Market__c = 'T&L Eastern Region',
                                     BillingStreet = '123 Main',
                                      BillingCity = 'San Diego',
                                      BillingState = 'CA',
                                      BillingCountry = 'USA');
    insert newAccount;
    newAccount.Partner_Agent__c=userobject.Id;
    update newAccount;
     }
}
}
}