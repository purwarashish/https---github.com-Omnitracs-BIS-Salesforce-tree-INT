@isTest(seeAllData = true)
public class TestPortalInviteExtension
    {
        static RecordType rt= [select id from RecordType where SobjectType =: 'Contact' and Name =: 'Sales' limit 1];
        static Contact cont=[select Id,email,AccountId,RecordTypeId from Contact where RecordTypeId =: rt.Id limit 1];
        static Account acct = [select name , phone,fax from account where phone != null and fax != null limit 1];
        
        static testMethod void myUnitTest()
        {
            
            
            Contact newcnt=new Contact();                  
            newcnt.FirstName='SFDC';          
            newcnt.LastName='Salesforce';          
            newcnt.Email = 'c_agang@qualcomm.com';                
           // newcnt.AccountId=ExistingUser.Contact.Accountid;                
            newcnt.RecordTypeId = rt.Id; 
            newcnt.phone = '(345)541-4321';
            newcnt.fax='(345)541-4321';
            newcnt.mobilephone='234567891';
            newcnt.UnityStatus__c  = 'INVITED';               
            newcnt.AccountId = acct.id;               
            insert newcnt;
            
            
            contact cnt = new Contact();
            ApexPages.CurrentPage().getParameters().put('id',newcnt.id);
            ApexPages.StandardController obj = new ApexPages.StandardController(cnt);
            PortalInviteExtension portInv =  new PortalInviteExtension(obj);
            portInv.getshowGreenFont();
            portInv.getFullContactID();
            portInv.updateInvitor();
            portInv.toggleButton();
            portInv.getEncryptedID();
            portInv.showUnityBackendValidationMsg =true;
            portInv.getshowGreenFont();
            portInv.getFullContactID();
            portInv.updateInvitor();
            portInv.toggleButton();
            portInv.getEncryptedID();
            portInv.showUnityBackendValidationMsg =true;
      }
      static testMethod void myUnitTest1()
      {      
            Contact newcnt1=new Contact();                 
            newcnt1.FirstName='SFDC';          
            newcnt1.LastName='Salesforce';          
            newcnt1.Email = 'c_agang@qualcomm.com';                
            newcnt1.RecordTypeId = rt.Id; 
            newcnt1.phone = '(345)541-4321';
            newcnt1.fax='(345)541-4321';
            newcnt1.mobilephone='234567891';
            newcnt1.UnityStatus__c  = 'ON_BOARDING';               
            newcnt1.AccountId = acct.id;               
            insert newcnt1;
            
            contact cnt1 = new Contact();
            ApexPages.CurrentPage().getParameters().put('id',newcnt1.id);
            ApexPages.StandardController obj1 = new ApexPages.StandardController(cnt1);
            PortalInviteExtension portInv1 =  new PortalInviteExtension(obj1);
            portInv1.toggleButton();
     }
     static testMethod void myUnitTest2()
     {
           
            Contact newcnt2=new Contact();                 
            newcnt2.FirstName='SFDC';          
            newcnt2.LastName='Salesforce';          
            newcnt2.Email = 'c_agang@qualcomm.com';                
            newcnt2.RecordTypeId = rt.Id; 
            newcnt2.phone = '(345)541-4321';
            newcnt2.fax='(345)541-4321';
            newcnt2.mobilephone='234567891';
            newcnt2.UnityStatus__c  = 'USER';               
            newcnt2.AccountId = acct.id;               
            insert newcnt2;
            contact cnt2 = new Contact();
            ApexPages.CurrentPage().getParameters().put('id',newcnt2.id);
            ApexPages.StandardController obj2 = new ApexPages.StandardController(cnt2);
            PortalInviteExtension portInv1 =  new PortalInviteExtension(obj2);
            portInv1.toggleButton();
         
     }
     static testMethod void myUnitTest3()
     {
         Contact newcnt2=new Contact();                 
            newcnt2.FirstName='SFDC';          
            newcnt2.LastName='Salesforce';          
            newcnt2.Email = 'c_agang@qualcomm.com';                
            newcnt2.RecordTypeId = rt.Id; 
            newcnt2.phone = '(345)541-4321';
            newcnt2.fax='(345)541-4321';
            newcnt2.mobilephone='234567891';
            newcnt2.UnityStatus__c  = 'XYZZZ';               
            newcnt2.AccountId = acct.id;               
            insert newcnt2;
            contact cnt2 = new Contact();
            ApexPages.CurrentPage().getParameters().put('id',newcnt2.id);
            ApexPages.StandardController obj2 = new ApexPages.StandardController(cnt2);
            PortalInviteExtension portInv1 =  new PortalInviteExtension(obj2);
            portInv1.toggleButton();     
         
     }
     static testMethod void myUnitTest4()
     {
         list<contact> lstcont = [select name ,phone,fax from contact where Unity_Contact_Status__c = 'OK' and phone != null and fax != null limit 1];
         system.debug('@@@lstcont'+lstcont);
         if(lstcont != null && lstcont.size() > 0)
         {
             contact c = lstcont[0];
             c.UnityStatus__c = '';
             update c;
             ApexPages.CurrentPage().getParameters().put('id',c.id);
             contact cnt2 = new Contact();
             ApexPages.StandardController obj2 = new ApexPages.StandardController(cnt2);
             PortalInviteExtension portInv1 =  new PortalInviteExtension(obj2);
             portInv1.toggleButton();  
         }
     }  
    }