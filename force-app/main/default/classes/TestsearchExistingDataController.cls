@isTest(seeAllData = true)
private Class TestsearchExistingDataController
{

public static testmethod void testSearchExtata()
{

   Profile p = [select id from profile where name = 'System Administrator'];
         
         User testuser3 = new User(
            alias = 'test'
            ,email = 'accounttestuser3@omnitracs.com'
            ,emailencodingkey = 'UTF-8'
            ,lastname = 'Tester1'
            ,languagelocalekey = 'en_US'
            ,localesidkey = 'en_US'
            ,profileid = p.Id
            ,timezonesidkey = 'America/Denver'
            ,username = 'accounttestuser3@omnitracs.com'
        ); 
        
        insert testuser3;

         Lead l2 = new Lead(
            FirstName = 'Test First Name'
            ,LastName = 'Test Last Name'
            ,Company = 'Test Company'
            ,OwnerId= testuser3.Id
            ,City = 'San Diego'
            ,State = 'CA'
            ,Country = 'US'
            
        );
        
        insert l2;
        
           
        
    
 Account newAccount = new Account();
        newAccount.Name = 'SFDC';
        newAccount.Type = 'Other';
        newAccount.BillingStreet = 'Test Address';
        newAccount.BillingCity = 'Test City';
        newAccount.BillingCountry = 'Test Country';
    	newAccount.BillingState = 'Test State';
    	newAccount.BillingPostalCode = '75052';
    	newAccount.Fleet_Size__c = 25;
    	newAccount.Segment__c = 'TL';
        newAccount.QWBS_Status__c = 'Contract Customer'; 
        newAccount.QWBS_Cust_ID__c = '4567'; 
        
        insert newAccount;
 Contact newCnt = new Contact();
        newCnt.FirstName = 'test';
        newCnt.LastName = 'Salestest';
        newCnt.email = 'abcxz@omnitracs.com';
        newCnt.MailingState = 'CA';
        newCnt.AccountId=newAccount.Id;
        
        
        insert newCnt;        
/*
 PageReference pageref1 = page.LimitedAccountOrLeadView;
 pageref1.getParameters().put('id','001R000000m1Yl9');
 test.setcurrentpage(pageref1);
 
// Apexpages.currentPage().getParameters().put('id',newAccount.Id);        
 */
 
  ApexPages.standardController setLead =  new ApexPages.StandardController(l2); 
   ApexPages.standardController setCont =  new ApexPages.StandardController(newCnt);
  
  
 // ApexPages.StandardSetController setLead = new ApexPages.StandardSetController(l2);
  
  
  Apexpages.currentPage().getParameters().put('searchString','test');
  Apexpages.currentPage().getParameters().put('AccountFlag','true');
  Apexpages.currentPage().getParameters().put('ContactFlag','true');
  Apexpages.currentPage().getParameters().put('LeadFlag','true');



  searchExistingDataController serchExtont = new searchExistingDataController();
  
  serchExtont.search();
 // serchExtont.nextLead();
 // serchExtont.previousLead();
  //serchExtont.nextCon();
  //serchExtont.previousCon();
  //serchExtont.nextAcc();
  //serchExtont.previousAcc();
  serchExtont.getAccounts();
  
  serchExtont.getLeads();
     


  serchExtont.getContacts();
//serchExtont.AccId = '0015000000MHDzcAAH';
serchExtont.AccId = newAccount.id;
serchExtont.LeadId = l2.id;

//System.debug('@@@@@@@'+AccId);
//System.debug('@@@@@@@'+LeadId);

 serchExtont.checkLeadOwner(); 
serchExtont.checkAccountOwner();

}

}