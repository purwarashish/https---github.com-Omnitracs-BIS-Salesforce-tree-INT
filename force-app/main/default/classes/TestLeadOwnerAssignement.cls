/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
*/
@isTest(SeeAllData=true)
private class TestLeadOwnerAssignement {

    static testMethod void myUnitTest() 
    {
        RecordType rt= [select id from RecordType where SobjectType =: 'contact' and Name =: 'sales' limit 1];
        Profile p = [select id from profile where name = 'Reseller Partner Profile (MDF)'];
        Account acct = [select id from account where name = 'PANA-PACIFIC' limit 1];
        
        Contact newcnt=new Contact();  
        newcnt.FirstName='SFDC';
        newcnt.LastName='Salesforce';
        newcnt.Email = 'c_skarn@qualcomm.com';
        newcnt.RecordTypeId = rt.Id;
        newcnt.AccountId = acct.id;
        insert newcnt;
        
        User olduser = new User(alias = 'standt', email='standarduser@testorg.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US',timezonesidkey='America/Los_Angeles', 
                username='standarduser111@testorg.com',ContactId = newcnt.id,ProfileId=p.Id);  
                insert olduser;
        
        
        Contact newcnt1=new Contact();  
        newcnt1.FirstName='SFDC1';
        newcnt1.LastName='Salesforce';
        newcnt1.Email = 'c_skarn1@qualcomm.com';
        newcnt1.RecordTypeId = rt.Id;
        newcnt1.AccountId = acct.id;
        insert newcnt1;
        
        User user2 = new User(alias = 'standt1', email='standarduser1@testorg.com',
                emailencodingkey='UTF-8', lastname='Testing1', languagelocalekey='en_US',
                localesidkey='en_US',timezonesidkey='America/Los_Angeles', 
                username='standarduser1111@testorg.com',ContactId = newcnt1.id,ProfileId=p.Id);  
                insert user2 ;
        system.runAs(olduser)
        {        
        Group grp1 = new Group(name = 'testQueue', type = 'Queue');
        insert grp1;
        Groupmember grpmem = new Groupmember(GroupId = grp1.id,UserOrGroupId = olduser.id);   
        Groupmember grpmem1 = new Groupmember(GroupId = grp1.id,UserOrGroupId = user2.id);   
        insert grpmem;
        insert grpmem1;
        
        String grpId = grp1.id;
        //Date myCurrentDate = date.newinstance(2011, 12, 14);
        Lead testlead=new Lead(FirstName='test',Lastname='testlast',Company='tcs',OwnerId=olduser.Id,street ='street',city='city',state='CA',country='US',postalcode='1234567');
        insert testlead;
        list<String> lstAlphabet = new list<String>{'All','a'};
        update olduser;
        update user2;
        
            
            ApexPages.currentPage().getParameters().put('Id',testlead.Id);
            LeadOwnerAssignmentController prm = new LeadOwnerAssignmentController( new ApexPages.StandardController(new lead())); 
            LeadOwnerAssignmentController.isSendEmail = false;
            prm.ShowAllUsers();
            system.debug('%%%%%%lstOfIdsOfUsernQueue'+prm.lstOfIdsOfUsernQueue.size());
            for(integer i=0;i<lstAlphabet.size();i++)
            {
                system.debug('alphabet'+prm.alphabet);
                prm.alphabet = lstAlphabet[i];
                prm.Alphabet_Ordering();
            }
            string id ='';
            if(prm.lstOfIdsOfUsernQueue != null && prm.lstOfIdsOfUsernQueue.size()>0)
                id = prm.lstOfIdsOfUsernQueue[0];
            prm.SelectedOwnerId = id;
            LeadOwnerAssignmentController.isSendEmail = true;
            system.debug('prm.leadId'+prm.leadId);
            prm.AssignUserOrQueue();
            prm.SelectedOwnerId = grpId;
            prm.AssignUserOrQueue();
        }
    }
}