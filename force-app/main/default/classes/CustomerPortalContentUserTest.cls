@isTest
public class CustomerPortalContentUserTest {
     public static testMethod void runAllTests() {
         User NewUser = new user();
         NewUser.ProfileId = '00e500000018klJ';
         NewUser.UserRoleId = '00E50000000jbIf';
         NewUser.email = 'test@omnitracs.com';
         NewUser.Username = 'test@omnitracs.com.12101986';
         NewUser.IsActive = true;
         NewUser.TimeZoneSidKey = 'America/Los_Angeles';
         NewUser.LocaleSidKey = 'en_US';
         NewUser.LastName = '12101986';
         NewUser.LanguageLocaleKey = 'en_US';
         NewUser.EmailEncodingKey = 'ISO-8859-1';
         NewUser.Alias = '12101986';
         insert newUser;
         
         List<Id> lstId = new List<Id>();
         lstId.add(newUser.id);
         
         Test.startTest();
         CustomerPortalContentUser.addToPublicGroup(lstId);
         Test.stopTest();
     }
}