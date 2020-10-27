@isTest(seeAllData = true)
public class TestPortalInviteAccountExtension
{
    static RecordType rt= [select id from RecordType where SobjectType =: 'Contact' and Name =: 'Sales' limit 1];
    static Profile p = [select
                         id
                     from
                         profile
                     where
                         name = 'UNITY Customer Portal User (SSO)'
                     limit 1];
    
    static testMethod void myUnitTest()
    {
       
        Account acct = new Account();
        user usr = [select name from user where isActive = true limit 1 ];
        Account currAcct = new Account(Name='New Account',ownerId=usr.Id ,BillingStreet='Acc Strt',BillingCity='Acc City'
                            ,BillingCountry='Acc Country',BillingState ='Acc State',BillingPostalCode ='75201',UnityOnboardStatus__c = 'INVITED' );
        
        insert currAcct;
        ApexPages.CurrentPage().getParameters().put('id',currAcct.id);
        ApexPages.StandardController obj = new ApexPages.StandardController(acct);
        PortalInviteAccountExtension portInv =  new PortalInviteAccountExtension(obj);
        portInv.toggleButton();
        portInv.getshowGreenFont();
        portInv.getCompanyGuid();
        portInv.getFullAccountID();
    }
    
    static testMethod void myUnitTest2()
    {
        Account acct = new Account();
        user usr = [select name from user where isActive = true limit 1 ];
        Account currAcct = new Account(Name='New Account',ownerId=usr.Id ,BillingStreet='Acc Strt',BillingCity='Acc City'
                            ,BillingCountry='Acc Country',BillingState ='Acc State',BillingPostalCode ='75201',UnityOnboardStatus__c = 'XYZ' );
        
        insert currAcct;
        ApexPages.CurrentPage().getParameters().put('id',currAcct.id);
        ApexPages.StandardController obj = new ApexPages.StandardController(acct);
        PortalInviteAccountExtension portInv =  new PortalInviteAccountExtension(obj);
        portInv.toggleButton();    
    }
}