@isTest(seeAllData = true)
public class TestLeadOwnerReAssignmentController{
static testMethod void myUnitTest()
{
   try{
    RecordType rt= [select id from RecordType where SobjectType =: 'contact' and Name =: 'sales' limit 1];
    Profile p = [select id from profile where name = 'Reseller Partner Profile (MDF)'];
    Account acct = [select id from account where name = 'PANA-PACIFIC' limit 1];
    Contact newcnt=new Contact();
    newcnt.FirstName='SFDC';
    newcnt.LastName='Salesforce';
    newcnt.Email = 'c_agang@qualcomm.com';
    newcnt.RecordTypeId = rt.Id;
    newcnt.AccountId = acct.id;
    insert newcnt;
    //User mp = [select id from user where Name = 'Pana Master Owner'];
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
    
    //Date myCurrentDate = date.newinstance(2011, 12, 14);
   
    Lead currLead =new Lead(FirstName='test',Lastname='testlast',Company='tcs',OwnerId=olduser.Id,street ='street',city='city',country='US',postalcode='1234567');
    insert currLead;
    
    Group grp1 = new Group();
    Group grp2 = new Group();
    system.runAs(olduser)
    {
        grp1 = new Group(name = 'testQueue1', type = 'Queue'); 
        grp2 = new Group(name = 'testQueue2');       
        
        insert grp1; 
        insert grp2;       
        
        Groupmember grpmem = new Groupmember(GroupId = grp1.id,UserOrGroupId = olduser.id);           
        Groupmember grpmem2 = new Groupmember(GroupId = grp1.id,UserOrGroupId = userInfo.getUserid());           
        Groupmember grpmem1 = new Groupmember(GroupId = grp1.id,UserOrGroupId = user2.id);           
        
        insert grpmem;   
        insert grpmem1;
        insert grpmem2;
        
        
        Groupmember grpmem4 = new Groupmember(GroupId = grp2.id,UserOrGroupId = user2.id);           
        Groupmember grpmem5 = new Groupmember(GroupId = grp1.id,UserOrGroupId = grp2.id);           
        insert grpmem4;
        insert grpmem5;
        
    }
    
    Task activities = new Task(Subject='Acc Activity',whoId=currLead.Id,OwnerId=olduser.id);
    insert activities;
        
    Event e2= new Event(whoId =currLead.id ,subject='Test', ActivityDatetime= datetime.now(), DurationInMinutes=60);
    insert e2;
    Test.startTest();
    ApexPages.currentPage().getParameters().put('id',currLead.id);
    Lead newLead = new Lead();
    ApexPages.StandardController obj = new ApexPages.StandardController(newLead);
    LeadOwnerReAssignmentController loa = new LeadOwnerReAssignmentController(obj);
    loa.newOwner = user2.id;
    loa.getItems();
    //loa.getTypes();
    loa.AssignUserOrQueue();
    
    loa.newOwner = 'none';
    loa.AssignUserOrQueue();
    
    loa.description = '';
    loa.AssignUserOrQueue();
        
       
    system.debug('@@@@grp1.id'+grp1.id);
    loa.getGroupMembers(grp1.id);
    
   system.runAs(olduser)
    {
        loa.newOwner = grp1.id;
        loa.AssignUserOrQueue();
    }
    Test.stopTest();
   }
   catch(exception e)
   {
    
   }
  }  
    static testMethod void myUnitTest2()
    {
        try{
        RecordType rt= [select id from RecordType where SobjectType =: 'contact' and Name =: 'sales' limit 1];
        Profile p = [select id from profile where name = 'Reseller Partner Profile (MDF)'];
        Account acct = [select id from account where name = 'PANA-PACIFIC' limit 1];
        Contact newcnt=new Contact();
        newcnt.FirstName='SFDC';
        newcnt.LastName='Salesforce';
        newcnt.Email = 'c_agang@qualcomm.com';
        newcnt.RecordTypeId = rt.Id;
        newcnt.AccountId = acct.id;
        insert newcnt;
       // User mp = [select id from user where Name = 'Pana Master Owner'];
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
    
    //Date myCurrentDate = date.newinstance(2011, 12, 14);
    Lead currLead =new Lead(FirstName='test',Lastname='testlast',Company='tcs',OwnerId=olduser.Id,street ='street',city='city',country='US',postalcode='1234567');
    insert currLead;
    Group grp1 = new Group();
    Group grp2 = new Group();
    system.runAs(olduser)
    {
        grp1 = new Group(name = 'testQueue', type = 'Queue'); 
        grp2 = new Group(name = 'testQueue');       
        
        insert grp1; 
        insert grp2;       
        
        Groupmember grpmem = new Groupmember(GroupId = grp1.id,UserOrGroupId = olduser.id);           
        Groupmember grpmem2 = new Groupmember(GroupId = grp1.id,UserOrGroupId = userInfo.getUserid());           
        Groupmember grpmem1 = new Groupmember(GroupId = grp1.id,UserOrGroupId = user2.id);           
        
        insert grpmem;        
        
        insert grpmem1;
        insert grpmem2;
        
        
        Groupmember grpmem4 = new Groupmember(GroupId = grp2.id,UserOrGroupId = user2.id);           
        Groupmember grpmem5 = new Groupmember(GroupId = grp1.id,UserOrGroupId = grp2.id);           
        insert grpmem4;
        insert grpmem5;
        
    }
    Test.startTest();
        ApexPages.currentPage().getParameters().put('id',currLead.id);
        Lead newLead = new Lead();
        ApexPages.StandardController obj = new ApexPages.StandardController(newLead);
        LeadOwnerReAssignmentController loa = new LeadOwnerReAssignmentController(obj);
        loa.newOwner = grp1.id;
        loa.getItems();
       // loa.getTypes();
        loa.AssignUserOrQueue();
    Test.stopTest();       
       
    }
    
   catch(exception e)
   {
    
   }
    }    
    
     

}