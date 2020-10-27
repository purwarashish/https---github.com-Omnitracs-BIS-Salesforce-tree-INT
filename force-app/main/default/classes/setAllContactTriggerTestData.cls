@isTest(seeAllData=true)
public class setAllContactTriggerTestData{
    
  public static List<User> createTestUser(Integer count,String strCriteria)
  {
    List<User> lsttestUser = new List<User>();    
    for(Integer i=0; i<count; i++)
    {  
        User newUser = new User();
        newUser.Username= 'test.user'+i+'@omnitracs.com';
        newUser.Email = 'test.user@omnitracs.com';
        newUser.Lastname = 'User';
        newUser.Firstname = 'Test';
        newUser.Alias = 'tuser';        
        if(strCriteria == 'findDuplicate')
        {
            if(i == 0)
            {
                newUser.UserRole = [ select id from userrole where Name ='QES Executives' ];
                Profile testProfile=[ select id from profile where Name = 'Marketing - Sys Admin' ];
                newUser.ProfileId= testProfile.id;
            }
            if(i == 1)
            {
                newUser.UserRole = [ select id from userrole where Name ='QES Executives' ];
                Profile testProfile=[ select id from profile where Name = 'IT Case Admins' ];
                newUser.ProfileId= testProfile.id;
            }
        }
        else
        {
            newUser.UserRole = [ select id from userrole where Name ='QES Executives' ];
            Profile testProfile=[ select id from profile where Name = 'System Administrator' ];
            newUser.ProfileId= testProfile.id;
        }        
        newUser.TimeZoneSidKey = 'GMT';
        newUser.LocaleSidKey = 'en_US';
        newUser.EmailEncodingKey = 'ISO-8859-1';
        newUser.LanguageLocaleKey = 'en_US';
        
        lsttestUser.add(newUser);
    }
    try{
        insert lsttestUser;
    }
    catch(Exception e){
        System.debug('Problem during test user insertion \nin:: setAllContactTriggerTestData class \nfor:: '+strCriteria+'\ndue to::'+e.getmessage());
        return null;
    }
    return lsttestUser;
  }
    
  public static List<Account> createTestAccount(Integer count,String strCriteria)
  {
    List<Account> lsttestAccount = new List<Account>();    
    for(Integer i=0; i<count; i++)
    {
        Account newAccount = new Account();
        newAccount.Name = 'New Test Account'+i;
        newAccount.BillingCity = 'BillingCity';
        newAccount.BillingState = 'BillingState';
        newAccount.BillingPostalCode = 'BillingPostalCode';
        newAccount.BillingCountry = 'BillingCountry';
        newAccount.BillingStreet = 'BillingStreet';
        newAccount.Segment__c = 'Services';
		newAccount.Fleet_Size__c = 10;
        if(strCriteria.equals('setNotification'))            
        {   if(i==0)
            {
                newAccount.QWBS_Status__c = 'Contract Customer';
                newAccount.QWBS_Cust_ID__c = 'Customer Id'+i;
            }
        }
        if(strCriteria.equals('validatePhone&Fax'))            
        {
            if(i==0)
                newAccount.Primary_Business_Unit__c = 'Sylectus';
            if(i==1)
                newAccount.Primary_Business_Unit__c = 'Omnitracs Domestic';
                newAccount.Phone = '789-456-3214';
                newAccount.Fax = '789-456-3214';
        }
        lsttestAccount.add(newAccount);
    }
    try{
        Insert lsttestAccount;
    }
    catch(Exception e){
        system.debug('Problem during test Account insertion \nin:: setAllContactTriggerTestData class \nfor:: '+strCriteria+'\ndue to::'+e.getmessage());
    }
    return lsttestAccount;
  }
    
  public static List<Contact> createTestContact(Integer count,List<Account> lstAccount,String strCriteria)
  {
    List<Contact> lsttestContact = new List<Contact>();    
    for(Integer i=0; i<count; i++)
    {
        Contact newContact = new Contact();
        newContact.LastName = 'New Test Contact'+i;
        newContact.AccountId = lstAccount[0].Id;
        if(strCriteria == 'findDuplicate')
        {
            if(i == 0)
            {
                newContact.Email = 'sales.duplicate@test.com';
                newContact.RecordtypeId = Schema.sObjectType.Contact.getRecordTypeInfosByName().get('Sales').getRecordTypeId();
            }
            if(i == 1)
            {
                newContact.Email = 'cnr.duplicate@test.com';
                newContact.RecordtypeId = Schema.sObjectType.Contact.getRecordTypeInfosByName().get('CNR').getRecordTypeId();
            }
        }
        if(strCriteria == 'setInvitorAccount&User')
        {
            newContact.RecordtypeId = Schema.sObjectType.Contact.getRecordTypeInfosByName().get('Sales').getRecordTypeId();
            if(i == 0)
            {
                newContact.Email = 'nonomni.user@test.com';                
            }
            if(i == 1)
            {
                newContact.Email = 'omni.user@omnitracs.com';
            }
        }
        lsttestContact.add(newContact);
    }
    try{
        Insert lsttestContact;
    }
    catch(Exception e){
        system.debug('Problem during test Contact insertion \nin:: setAllContactTriggerTestData class \ndue to::'+e.getmessage());
    }
    return lsttestContact;
  }
  
  public static List<Opportunity> createTestOpportunity(Integer count,List<Account> lstAccount)
  {
    List<Opportunity> lsttestOpportunity = new List<Opportunity>();    
    for(Integer i=0; i<count; i++)
    {
        Opportunity newOpportunity = new Opportunity();
        newOpportunity.Name = 'New Test Opportunity'+i;
        newOpportunity.AccountId = lstAccount[0].Id;
        newOpportunity.StageName = 'Qualify';
        newOpportunity.CloseDate = System.today();
        newOpportunity.CurrencyIsoCode = 'USD';
        
        lsttestOpportunity.add(newOpportunity);
    }
    try{
        Insert lsttestOpportunity;
    }
    catch(Exception e){
        system.debug('Problem during test Opportunity insertion \nin:: setAllContactTriggerTestData class \ndue to::'+e.getmessage());
    }
    return lsttestOpportunity;
  }
}