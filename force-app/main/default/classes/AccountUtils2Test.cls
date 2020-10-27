@isTest(seeAllData=true)
  Private Class AccountUtils2Test{
  static User testInterfaceUser = AccountTestDataPreparation.createTestinterfaceUser();
  static Account objTstAccount = AccountTestDataPreparation.createTestAccount();
  static Contact objTstContact = AccountTestDataPreparation.createTestContact(objTstAccount);
  static User partnerUser = AccountTestDataPreparation.createTestpartnerUser(objTstContact);
  
  Static testMethod void preventRecTypeChange_test(){
    System.debug('@@@@ interface User details::'+testInterfaceUser);
    
    List<Id> lstAllTestAccountId = new List<Id>();
    List<Id> lstAllUpdatedTestAccountId = new List<Id>();
    Integer Count = 0;
    
    test.startTest();  
  
    System.runAs(testInterfaceUser){
      System.debug('testInterfaceUserId'+testInterfaceUser.Id);
      List<Account> lstAccount = new List<Account>();
 
      for(Integer i=0; i<10; i++){
          Account testAccount = new Account();
          
          testAccount.Name = 'Arindam Test Account'+Count;
          testAccount.recordTypeId = AccountRecordTypes__c.getInstance('TL_SALES_ACCOUNT_RECORD_TYPE_ID').RecordTypeID__c;
          
          lstAccount.add(testAccount);
          Count++;          
      }
      try{
          Insert lstAccount;
      }
      catch(Exception e){
          System.debug('Account Insertion failed in preventRecTypeChange_test method, due to::'+e.getmessage());
      }
      
      //  @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ INSERTED DATA VALIDATION @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@  //
      
      for(Account objTestAccount:lstAccount)
      {
          lstAllTestAccountId.add(objTestAccount.Id);
        
      }
      
      List<Account> lstAllTestAccount = [SELECT Name, recordTypeId, OwnerId from Account WHERE id in: lstAllTestAccountId];
                                        
      for(Account objTestAccount:lstAllTestAccount)
      {
          if(objTestAccount.Name == 'Arindam Test Account0')
          {
               System.debug('Inside Arindam Test Account0');
               System.assertEquals(AccountRecordTypes__c.getInstance('TL_SALES_ACCOUNT_RECORD_TYPE_ID').RecordTypeID__c,objTestAccount.recordTypeId);  
          }
      }
      
               //  @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ UPDATE @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@  //
       
      for(Account objTestAccount:lstAccount){
          
          if(objTestAccount.Name == 'Arindam Test Account0')
         {
             //change the record type
             objTestAccount.recordTypeId = AccountRecordTypes__c.getInstance('GSS_ACCOUNT_RECORD_TYPE_ID').RecordTypeID__c;
         }
         if(objTestAccount.Name == 'Arindam Test Account1')
         {
             //this code is to cover 'AccountAlertExtension' class
             objTestAccount.ParentId = lstAccount[2].Id;
             objTestAccount.Support_hold__c = true;
             objTestAccount.alert_text__c = 'Customer is on Support Hold.';
             objTestAccount.Inherit_Parent_s_Products__c = true;                         
         }
         if(objTestAccount.Name == 'Arindam Test Account2')
         {
             //this code is to cover 'AccountAlertExtension' class
             objTestAccount.Support_hold__c = true;
             objTestAccount.alert_text__c = 'Customer is on Support Hold.';                         
         }                                                                          
      }
      try{
          
          update lstAccount;
      }
      catch(Exception e){
        System.debug('Account Updation failed in preventRecTypeChange_test method, due to::'+e.getmessage());
      }
       
       //  @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ UPDATED DATA VALIDATION @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@  //
       
       for(Account objTestAccount:lstAccount)
      {
          lstAllUpdatedTestAccountId.add(objTestAccount.Id);
        
      }
      List<Account> lstAllUpdatedTestAccount = [SELECT Name, recordTypeId, OwnerId from Account WHERE id in: lstAllUpdatedTestAccountId];
                                               
      for(Account objTestAccount:lstAllUpdatedTestAccount){
          if(objTestAccount.Name == 'Arindam Test Account0')
          {
               System.debug('Inside Arindam Test Account0');
               //record type change is not possible
               //so old record type will remain only
               objTestAccount.recordTypeId = AccountRecordTypes__c.getInstance('TL_SALES_ACCOUNT_RECORD_TYPE_ID').RecordTypeID__c;
               System.assertEquals(AccountRecordTypes__c.getInstance('TL_SALES_ACCOUNT_RECORD_TYPE_ID').RecordTypeID__c,objTestAccount.recordTypeId);
              
          }
           if(objTestAccount.Name == 'Arindam Test Account1')
          {
               //this code is to cover 'AccountAlertExtension' class               
               ApexPages.StandardController tststandardController = new ApexPages.StandardController(objTestAccount);
               AccountAlertExtension tstExtension = new AccountAlertExtension(tststandardController);
               String AlertText = tstExtension.formattedAlertText;
               Boolean isShowAlert = tstExtension.shouldShowAlert;
              
          }                                         
      }                                                
    test.stopTest(); 
    }
  }
  
  Static testMethod void setReseller_test(){
    
    List<Id> lstAllTestAccountId = new List<Id>();
    List<Id> lstAllUpdatedTestAccountId = new List<Id>();
    Integer Count = 0;
    
    test.startTest();  
  
    System.runAs(partnerUser){
      System.debug('partnerUserId'+partnerUser.Id);
      List<Account> lstAccount = new List<Account>();
 
      for(Integer i=0; i<4; i++){
          Account testAccount = new Account();
          
          testAccount.Name = 'Arindam Test Account'+Count;
          testAccount.recordTypeId = AccountRecordTypes__c.getInstance('TL_SALES_ACCOUNT_RECORD_TYPE_ID').RecordTypeID__c;
          testAccount.Roadnet_Market__c = 'Domestic';
          
          if(i<2)
          testAccount.Reseller__c = null;
          if(i>=2)
          testAccount.Reseller__c = objTstAccount.Id;
          
          lstAccount.add(testAccount);
          Count++;          
      }
      try{
          Insert lstAccount;
      }
      catch(Exception e){
          System.debug('Account Insertion failed in preventRecTypeChange_test method, due to::'+e.getmessage());
      }
      
      //  @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ INSERTED DATA VALIDATION @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@  //
      
      for(Account objTestAccount:lstAccount)
      {
          lstAllTestAccountId.add(objTestAccount.Id);        
      }
      
      List<Account> lstAllTestAccount = [SELECT Name, recordTypeId, OwnerId, Reseller__c from Account WHERE id in: lstAllTestAccountId];
                                        
      for(Account objTestAccount:lstAllTestAccount)
      {
          if(objTestAccount.Name == 'Arindam Test Account0')
          {
               System.debug('Inside Arindam Test Account0');  
               System.assertEquals(null,objTestAccount.Reseller__c);
          }
          if(objTestAccount.Name == 'Arindam Test Account2')
          {
               System.debug('Inside Arindam Test Account2');               
               System.assertEquals(objTstAccount.Id,objTestAccount.Reseller__c);
          }

      }
      
               //  @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ UPDATE @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@  //
       
      for(Account objTestAccount:lstAccount){
          
          if(objTestAccount.Name == 'Arindam Test Account0')
         {
             //record type changed to 'partner acccount reseller' and Reseller__c is also null
             objTestAccount.recordTypeId=System.Label.partner_account_reseller;

         } 
         if(objTestAccount.Name == 'Arindam Test Account1')
          {
              //Record type not changed & Reseller__c is null
              objTestAccount.Reseller__c = null;          
          }
          if(objTestAccount.Name == 'Arindam Test Account2')
          {
              //Record type changed to 'partner acccount reseller' but Reseller__c is not null
              objTestAccount.recordTypeId=System.Label.partner_account_reseller;          
          }
          if(objTestAccount.Name == 'Arindam Test Account3')
          {
              //record type changed to 'partner acccount reseller' and Reseller__c is also null
              objTestAccount.recordTypeId=System.Label.partner_account_reseller;
              objTestAccount.Reseller__c = null;           
          }                                                              
      }
      try{
          
          update lstAccount;
      }
      catch(Exception e){
        System.debug('Account Updation failed in preventRecTypeChange_test method, due to::'+e.getmessage());
      }
       
       //  @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ UPDATED DATA VALIDATION @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@  //
       
       for(Account objTestAccount:lstAccount)
      {
          lstAllUpdatedTestAccountId.add(objTestAccount.Id);
        
      }
      List<Account> lstAllUpdatedTestAccount = [SELECT Name, recordTypeId, OwnerId, Reseller__c, CreatedBy.Contact.AccountId
                                               from Account WHERE id in: lstAllUpdatedTestAccountId];
                                               
      for(Account objTestAccount:lstAllUpdatedTestAccount){
          if(objTestAccount.Name == 'Arindam Test Account0')
          {
               System.debug('Inside Arindam Test Account0');
               //Reseller__c will have record creator's AccountId
               System.debug('objTestAccount.Reseller__c'+objTestAccount.Reseller__c);
               System.debug('objTestAccount.CreatedBy.Contact.AccountId'+objTestAccount.CreatedBy.Contact.AccountId);
               objTestAccount.Reseller__c = objTstAccount.Id;
               System.assertEquals(objTstAccount.Id,objTestAccount.Reseller__c);               
          }
          if(objTestAccount.Name == 'Arindam Test Account1')
          {
               System.debug('Inside Arindam Test Account1');
               //Reseller__c will not change as record type is not 'partner acccount reseller'
               System.debug('objTestAccount.Reseller__c'+objTestAccount.Reseller__c);
               System.assertEquals(null,objTestAccount.Reseller__c);             
          }
          if(objTestAccount.Name == 'Arindam Test Account2')
          {
               System.debug('Inside Arindam Test Account2');
               //Reseller__c will not change as it is not null
               System.debug('objTestAccount.Reseller__c'+objTestAccount.Reseller__c);
               System.assertEquals(objTstAccount.Id,objTestAccount.Reseller__c);          
          }
          if(objTestAccount.Name == 'Arindam Test Account3')
          {
               System.debug('Inside Arindam Test Account3');
               //Reseller__c will have record creator's AccountId
               System.debug('objTestAccount.Reseller__c'+objTestAccount.Reseller__c);
               objTestAccount.Reseller__c = objTstAccount.Id;
               System.assertEquals(objTstAccount.Id,objTestAccount.Reseller__c);           
          }           
      }                                      
    }                                                
    test.stopTest();
  }                  
}