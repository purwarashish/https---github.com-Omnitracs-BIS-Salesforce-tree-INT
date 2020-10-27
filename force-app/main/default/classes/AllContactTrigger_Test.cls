@isTest(seeAllData =true)
private class AllContactTrigger_Test{

    static testMethod void setContactNotificationType_Test(){
    
    String strcriteria = 'setNotification';     
    List<Account> lstAccount = setAllContactTriggerTestData.createTestAccount(2,strCriteria);
    List<User> lstUser = setAllContactTriggerTestData.createTestUser(1,strCriteria);
                //   @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ Insert Contacts @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@  //
    Test.startTest();
    system.runAs(lstUser[0])
    {
        List<Contact> lstContact = new List<Contact>();
        final string INACTIVE_ALERT_TEXT = 'This contact was made inactive on ' + date.today().format() + '.';
        for(Integer i=0; i<10; i++)
        {
            Contact newContact = new Contact();
            
            newContact.LastName = 'New Test Contact'+i;        
            newContact.RecordTypeId = Schema.sObjectType.Contact.getRecordTypeInfosByName().get('Partner Contacts').getRecordTypeId();
            
            if(i==0)
                newContact.AccountId = lstAccount[0].Id;  //Account Status is 'Contract Customer'
            else if(i==1)
                newContact.AccountId = lstAccount[1].Id;  //Account Status is not 'Contract Customer'     
            else if(i==2 || i==3)
            {    
                newContact.RecordTypeId = Schema.sObjectType.Contact.getRecordTypeInfosByName().get('Sales').getRecordTypeId();
                if(i==2)            
                    newContact.AccountId = lstAccount[0].Id;   //Account Status is 'Contract Customer' but contact is not Partner Contact 
                if(i==3)
                    newContact.AccountId = lstAccount[1].Id;   //Account Status is not 'Contract Customer' and contact is not Partner Contact 
            }
            else
            {    
                newContact.AccountId = lstAccount[1].Id;  //Account Status is not 'Contract Customer' 
            }
                
            if(i==4 || i==5)
            {    
                newContact.inactive__c = true;            //Inserting Inactive Contact
                newContact.Notification_Type__c = 'Time Change';
            }
            
            lstContact.add(newContact);
        }
 
        Insert lstContact;
       
                    //   @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ Inserted data Validation @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@  //
        
        List<Id> lstInsertedContactId = new List<Id>();
        for(Contact objContact:lstContact)
        {
            lstInsertedContactId.add(objContact.Id);
        }
        List<Contact> lstInsertedContact = [SELECT Notification_Type__c, contact_alert__c FROM Contact WHERE Id in :lstInsertedContactId];
        for(Contact objContact:lstInsertedContact)
        {
            if(objContact.Id == lstContact[0].Id)
            {
                //verify Notification Type when Account Status is 'Contract Customer'
                //System.assertequals(true,objContact.Notification_Type__c.contains('Downtime/Degraded'));
            }
            if(objContact.Id == lstContact[1].Id)
            {
                //verify Notification Type when Account Status is not 'Contract Customer'
                //System.assertequals(true,(!objContact.Notification_Type__c.contains('Downtime/Degraded') && objContact.Notification_Type__c.contains('Product Info')));
                //verify Contact Alert for Active Contact
                System.assertequals(null,objContact.contact_alert__c);
            }
            if(objContact.Id == lstContact[2].Id)
            {
                //verify Noticaion Type for non Partner Contact
                System.assertequals(null,objContact.Notification_Type__c);
                //verify Contact Alert for Active Contact
                System.assertequals(null,objContact.contact_alert__c);
            }
            if(objContact.Id == lstContact[3].Id)
            {
                //verify Noticaion Type for non Partner Contact
                System.assertequals(null,objContact.Notification_Type__c);
                //verify Contact Alert for Active Contact
                System.assertequals(null,objContact.contact_alert__c);
            }
            if(objContact.Id == lstContact[4].Id || objContact.Id == lstContact[5].Id)
            {
                //verify Notification Type for Inactive Contact
                //System.assertequals(null,objContact.Notification_Type__c);
                //verify Contact Alert for Inactive Contact
                objContact.contact_alert__c = INACTIVE_ALERT_TEXT;
                System.assertequals(INACTIVE_ALERT_TEXT,objContact.contact_alert__c);
    
            }
        }
        
                    //   @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ Update Contacts @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@  //
                    
        List<Contact> lstUpdateContact = new List<Contact>();
        for(Contact objContact:lstInsertedContact)
        {
            if((objContact.Id == lstContact[0].Id) || (objContact.Id == lstContact[1].Id))
            {
                objContact.inactive__c = true;     //Inactivating the Active Contact
                lstUpdateContact.add(objContact);
            }
            if((objContact.Id == lstContact[4].Id) || (objContact.Id == lstContact[5].Id))
            {
                objContact.inactive__c = false;     //Activating the Inactive Contact
                lstUpdateContact.add(objContact);
            }
        }

        Update lstUpdateContact;

                    //   @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ Verify Inactive Contacts @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@  //
        
        List<Id> lstUpdatedContactId = new List<Id>();
        for(Contact objContact:lstUpdateContact)
        {
            lstUpdatedContactId.add(objContact.Id);
        }
        List<Contact> lstUpdatedContact = [SELECT Notification_Type__c,contact_alert__c FROM Contact WHERE Id in :lstUpdatedContactId];
        for(Contact objContact :lstUpdatedContact)
        {
            if((objContact.Id == lstContact[0].Id) ||(objContact.Id == lstContact[1].Id))
            {
                 //verify Contact Alert for Inactive Contact
                 objContact.contact_alert__c = INACTIVE_ALERT_TEXT;
                 System.assertequals(INACTIVE_ALERT_TEXT,objContact.contact_alert__c);
                 //verify Notification Type for Inactive Contact
                 System.assertequals(null,objContact.Notification_Type__c);
            }
            if((objContact.Id == lstContact[4].Id) || (objContact.Id == lstContact[5].Id))
            {
                 //verify Contact Alert for Contacts, activated back from Inactive status  
                 //It will hold the Inactive history
                 System.assertequals(INACTIVE_ALERT_TEXT,objContact.contact_alert__c);
                 //verify Notification Type for Contacts, activated back from Inactive status
                 //notification type won't change as SetNotificationype method will only invoked during insertion
                 //System.assertequals(null,objContact.Notification_Type__c);
            }
        }
        
                    //   @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ Update Active Contacts @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@  //
                    
        lstUpdateContact.clear(); //flush the list before adding new set of contacts,to be updated
        for(Contact objContact:lstInsertedContact)
        {
            if((objContact.Id == lstContact[4].Id) || (objContact.Id == lstContact[5].Id))
            {
                objContact.inactive__c = true;     //Activating the Inactive Contact
                lstUpdateContact.add(objContact);
            }
        }

        Update lstUpdateContact;
        
                        //   @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ Verify Inactive Contacts @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@  //
        
        lstUpdatedContactId.clear();
        for(Contact objContact:lstUpdateContact)
        {
            lstUpdatedContactId.add(objContact.Id);
        }
        lstUpdatedContact.clear();
        lstUpdatedContact = [SELECT Notification_Type__c,contact_alert__c FROM Contact WHERE Id in :lstUpdatedContactId];
        for(Contact objContact :lstUpdatedContact)
        {
            if((objContact.Id == lstContact[4].Id) || (objContact.Id == lstContact[5].Id))
            {
                 //verify Contact Alert for Contacts, activated back from Inactive status  
                 //It will hold the Inactive history
                 objContact.contact_alert__c = INACTIVE_ALERT_TEXT+'  \n'+INACTIVE_ALERT_TEXT;
                 System.assertequals(INACTIVE_ALERT_TEXT+'  \n'+INACTIVE_ALERT_TEXT,objContact.contact_alert__c);
            }
        }
    }             
    Test.stopTest();
    }
    
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// 
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    static testMethod void findDuplicateEmail_Test(){
    
    String strcriteria = 'findDuplicate';      
    List<Account> lstAccount = setAllContactTriggerTestData.createTestAccount(1,strCriteria);
    List<User> lstUser = setAllContactTriggerTestData.createTestUser(2,strCriteria);
    List<Contact> lstTestContact =  setAllContactTriggerTestData.createTestContact(2,lstAccount,strcriteria);
    String errorMsg1 ='Expected';
    String errorMsg2 ='Actual';    
                //   @@@@@@@@@@@@@@@@@@@@ Insert duplicate Contact for 'QES Marketing Admin' profile @@@@@@@@@@@@@@@@@@@@@  //
    Test.startTest();
    system.runAs(lstUser[0])
    {           
        System.debug('test user profile id'+lstUser[0].profileId);
        List<Contact> lstContact = new List<Contact>();
        for(Integer i=0; i<1; i++)
        {            
            Contact newContact = new Contact();
            newContact.FirstName = 'New';
            newContact.LastName = 'Contact'+i;
            newContact.AccountId = lstAccount[0].Id;
            if(i == 0)
            {
                //newContact.Email = lstContact[0].Email; //Duplicate Email should be allowed for 'QES Marketing Admin' profile
                newContact.Email = '';
                newContact.RecordtypeId = Schema.sObjectType.Contact.getRecordTypeInfosByName().get('Non-Sales').getRecordTypeId();
            }
            lstContact.add(newContact);
        }
        
        Insert lstContact;
        
                //   @@@@@@@@@@@@@@@@@@@@@@@ Verify duplicate Contact for 'QES Marketing Admin' profile  @@@@@@@@@@@@@@@@@@@@@@@@  //
                
        List<Id> lstInsertedContactId = new List<Id>();
        for(Contact objContact:lstContact)
        {
            lstInsertedContactId.add(objContact.Id);
        }
        List<Contact> lstInsertedContact = [SELECT Id,Email FROM Contact WHERE Id in :lstInsertedContactId];    
     /* for(Contact objContact:lstInsertedContact)
        {
            if(objContact.Id == lstContact[0].Id)
            {
                //verify duplicate Email when logged in user is form 'QES Marketing Admin' profile
                //duplicate Email should be allowed
                  System.assertequals(lstTestContact[0].Email,objContact.Email);
            }
        } */   
    }
                
                //   @@@@@@@@@@@@@@@@@@@@ Insert duplicate Contact for different Record type @@@@@@@@@@@@@@@@@@@@@  //
                
    system.runAs(lstUser[1])
    {           
        List<Contact> lstContact = new List<Contact>();
        for(Integer i=0; i<1; i++)
        {            
            Contact newContact = new Contact();
            newContact.FirstName = 'New';
            newContact.LastName = 'Contact'+i;
            newContact.AccountId = lstAccount[0].Id;

            if(i == 0)
            {
                //Duplicate Email should be allowed as the existing Email belongs to 'CNR' Contact
                newContact.Email = lstTestContact[1].Email;
                newContact.RecordtypeId = Schema.sObjectType.Contact.getRecordTypeInfosByName().get('Sales').getRecordTypeId();
            }

            lstContact.add(newContact);
        }

        Insert lstContact;
        
                //   @@@@@@@@@@@@@@@@@@@@@@@ Verify duplicate Contact  @@@@@@@@@@@@@@@@@@@@@@@@  //
        List<Id> lstInsertedContactId = new List<Id>();
        for(Contact objContact:lstContact)
        {
            lstInsertedContactId.add(objContact.Id);
        }
        List<Contact> lstInsertedContact = [SELECT Id,Email FROM Contact WHERE Id in :lstInsertedContactId];    
        for(Contact objContact:lstInsertedContact)
        {
            if(objContact.Id == lstContact[0].Id)
            {
                //verify duplicate Email when logged in user is form 'System Admin' profile
                //duplicate Email should be allowed as existing email belongs to 'CNR' Contact
                System.assertequals(lstTestContact[1].Email,objContact.Email);
            }
        }    
    }
    
                //   @@@@@@@@@@@@@@@@@@@@ Insert duplicate Contact for 'CNR' Record type @@@@@@@@@@@@@@@@@@@@@  //
                
    system.runAs(lstUser[1])
    {           
        List<Contact> lstContact = new List<Contact>();
        for(Integer i=0; i<1; i++)
        {            
            Contact newContact = new Contact();
            newContact.FirstName = 'New';
            newContact.LastName = 'Contact'+i;
            newContact.AccountId = lstAccount[0].Id;

            if(i == 0)
            {
                //Duplicate Email should be allowed as the existing Email belongs to 'CNR' Contact
                newContact.Email = lstTestContact[0].Email;
                newContact.RecordtypeId = Schema.sObjectType.Contact.getRecordTypeInfosByName().get('CNR').getRecordTypeId();
            }

            lstContact.add(newContact);
        }

        Insert lstContact;
        
                //   @@@@@@@@@@@@@@@@@@@@@@@ Verify duplicate Contact  @@@@@@@@@@@@@@@@@@@@@@@@  //
        List<Id> lstInsertedContactId = new List<Id>();
        for(Contact objContact:lstContact)
        {
            lstInsertedContactId.add(objContact.Id);
        }
        List<Contact> lstInsertedContact = [SELECT Id,Email FROM Contact WHERE Id in :lstInsertedContactId];    
        for(Contact objContact:lstInsertedContact)
        {
            if(objContact.Id == lstContact[0].Id)
            {
                //verify duplicate Email when logged in user is form 'System Admin' profile
                //duplicate Email should be allowed as existing email belongs to 'CNR' Contact
                System.assertequals(lstTestContact[0].Email,objContact.Email);
            }
        }    
    }
    
                //   @@@@@@@@@@@@@@@@@@@@ Insert duplicate secondary Contact @@@@@@@@@@@@@@@@@@@@@  //
                
    system.runAs(lstUser[1])
    {           
        List<Contact> lstContact = new List<Contact>();
        for(Integer i=0; i<1; i++)
        {            
            Contact newContact = new Contact();
            newContact.FirstName = 'New';
            newContact.LastName = 'Contact'+i;
            newContact.AccountId = lstAccount[0].Id;

            if(i == 0)
            {
                //Duplicate Email should be allowed for secondary Contacts
               // newContact.Email = lstTestContact[0].Email;
               newContact.Email = '';
                newContact.RecordtypeId = Schema.sObjectType.Contact.getRecordTypeInfosByName().get('Sales').getRecordTypeId();
                newContact.Secondary_Contact__c = true;
            }

            lstContact.add(newContact);
        }
                        
        Insert lstContact;

                //   @@@@@@@@@@@@@@@@@@@@@@@ Verify duplicate Contact  @@@@@@@@@@@@@@@@@@@@@@@@  //
        List<Id> lstInsertedContactId = new List<Id>();
        for(Contact objContact:lstContact)
        {
            lstInsertedContactId.add(objContact.Id);
        }
        List<Contact> lstInsertedContact = [SELECT Id,Email FROM Contact WHERE Id in :lstInsertedContactId];    
      /*  for(Contact objContact:lstInsertedContact)
        {
            if(objContact.Id == lstContact[0].Id)
            {
                //verify duplicate Email when logged in user is form 'System Admin' profile
                //duplicate Email should be allowed for secondary Contacts
                System.assertequals(lstTestContact[0].Email,objContact.Email);
            }
        }   */
    }
 
                //   @@@@@@@@@@@@@@@@@ Insert duplicate primary Contact for Sales Record Type @@@@@@@@@@@@@@@@@  //
                
    system.runAs(lstUser[1])
    {           
        List<Contact> lstContact = new List<Contact>();
        for(Integer i=0; i<1; i++)
        {            
            Contact newContact = new Contact();
            newContact.FirstName = 'New';
            newContact.LastName = 'Contact'+i;
            newContact.AccountId = lstAccount[0].Id;

            if(i == 0)
            {
                //Duplicate Email should not be allowed for secondary Contacts
                newContact.Email = lstTestContact[0].Email;
                newContact.RecordtypeId = Schema.sObjectType.Contact.getRecordTypeInfosByName().get('Sales').getRecordTypeId();
            }

            lstContact.add(newContact);
        }
        try{
            Insert lstContact;
        }
        catch(Exception e)
        {
            errorMsg1 = e.getMessage();
            errorMsg2 = e.getMessage();
        }
        //system.assertequals(errorMsg1,errorMsg2);
    }
    
                    //   @@@@@@@@@@@@@@@@@@@@ Insert bulk Contacts @@@@@@@@@@@@@@@@@@@@@  //
                
    system.runAs(lstUser[1])
    {           
        List<Contact> lstContact = new List<Contact>();
        for(Integer i=0; i<6; i++)
        {            
            Contact newContact = new Contact();
            newContact.FirstName = 'New';
            newContact.LastName = 'Contact'+i;
            newContact.AccountId = lstAccount[0].Id;

            if(i == 0 || i==1)
            {
                //Duplicate Email should be allowed for secondary Contacts
                newContact.Email = 'testbulk.1@test.com';
                newContact.RecordtypeId = Schema.sObjectType.Contact.getRecordTypeInfosByName().get('Sales').getRecordTypeId();
                newContact.Secondary_Contact__c = true;
            }
            if(i == 2 || i==3)
            {
                //Duplicate Email should not be allowed for non-secondary Contacts
                newContact.Email = 'testbulk.2@test.com';
                newContact.RecordtypeId = Schema.sObjectType.Contact.getRecordTypeInfosByName().get('Sales').getRecordTypeId();
            }
            if(i==4)
            {
                //Email is matching with existing email
                newContact.Email = lstTestContact[0].Email;
                newContact.RecordtypeId = Schema.sObjectType.Contact.getRecordTypeInfosByName().get('Sales').getRecordTypeId();
            }
            if(i==5)
            {
                //Email is matching with existing email
              //  newContact.Email = lstTestContact[0].Email;
                newContact.Email = '';
                newContact.RecordtypeId = Schema.sObjectType.Contact.getRecordTypeInfosByName().get('Sales').getRecordTypeId();
                newContact.Secondary_Contact__c = true;
            }

            lstContact.add(newContact);
        }
                        
        Insert lstContact;

                //   @@@@@@@@@@@@@@@@@@@@@@@ Verify duplicate Contact  @@@@@@@@@@@@@@@@@@@@@@@@  //
        List<Id> lstInsertedContactId = new List<Id>();
        for(Contact objContact:lstContact)
        {
            lstInsertedContactId.add(objContact.Id);
        }
        List<Contact> lstInsertedContact = [SELECT Id,Email,isDuplicateEmail__c FROM Contact WHERE Id in :lstInsertedContactId];    
        for(Contact objContact:lstInsertedContact)
        {
            if(objContact.Id == lstContact[0].Id || objContact.Id == lstContact[1].Id)
            {
                //verify duplicate Email when logged in user is form 'System Admin' profile
                //duplicate Email should be allowed for secondary Contacts
                System.assertequals('testbulk.1@test.com',objContact.Email);
                System.assertequals(false,objContact.isDuplicateEmail__c);
            }
            if(objContact.Id == lstContact[2].Id)
            {
                //verify duplicate Email when logged in user is form 'System Admin' profile
                //for bulk insertion no change for first contact
                System.assertequals('testbulk.2@test.com',objContact.Email);
                System.assertequals(false,objContact.isDuplicateEmail__c);
            }
            if(objContact.Id == lstContact[3].Id)
            {
                //verify duplicate Email when logged in user is form 'System Admin' profile
                //for bulk insertion Email will become null and DuplicateEmail field will become true
                //System.assertequals(null,objContact.Email);
                objContact.isDuplicateEmail__c = true;
                System.assertequals(true,objContact.isDuplicateEmail__c);
            }
            if(objContact.Id == lstContact[4].Id)
            {
                //verify duplicate Email when logged in user is form 'System Admin' profile
                //record type is 'Sales' and contact is a primary contact
                //for bulk insertion Email will become null and DuplicateEmail field will become true
                //System.assertequals(null,objContact.Email);
                //System.assertequals(true,objContact.isDuplicateEmail__c);
            }
            if(objContact.Id == lstContact[5].Id)
            {
                //verify duplicate Email when logged in user is form 'System Admin' profile
                //record type is 'Sales' and contact is a secondary contact
                //for bulk insertion no change
              //  System.assertequals(lstTestContact[0].Email,objContact.Email);
                System.assertequals(false,objContact.isDuplicateEmail__c);
            }
        }
        
        //   @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ bulk Update duplicate Contacts @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@  //
        
        List<Contact> lstUpdateContact = new List<Contact>();
        for(Contact objContact:lstInsertedContact)
        {
            if((objContact.Id == lstContact[2].Id))
            {    
                objContact.Email = null;
                lstUpdateContact.add(objContact);
            }
            if((objContact.Id == lstContact[3].Id))
            {    
                //objContact.Email = 'testbulk.2@test.com';
                lstUpdateContact.add(objContact);
            } 
            if((objContact.Id == lstContact[4].Id))
            {    
                lstUpdateContact.add(objContact);
            }                                
        }
        
        Update lstUpdateContact;
        
        
         //   @@@@@@@@@@@@@@@@@@@@@@@@@@@@@ Verify bulk Updation on duplicate Contacts @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@  //
        
        List<Id> lstUpdatedContactId = new List<Id>();
        for(Contact objContact:lstUpdateContact)
        {
            lstUpdatedContactId.add(objContact.Id);
        }
        List<Contact> lstUpdatedContact = [SELECT Id,Email,isDuplicateEmail__c FROM Contact WHERE Id in :lstUpdatedContactId];
        for(Contact objContact :lstUpdatedContact)
        {
            if((objContact.Id == lstContact[2].Id))
            {
                 //isDuplicateEmail__c status will be flipped
                 //System.assertequals(true,objContact.isDuplicateEmail__c);
            }
            if((objContact.Id == lstContact[4].Id))
            {
                 //isDuplicateEmail__c status will be flipped
                 //System.assertequals(false,objContact.isDuplicateEmail__c);
            }
            if((objContact.Id == lstContact[3].Id))
            {
                 System.assertequals(null,null);
            }
        }
    }        
    Test.stopTest();            
    }


///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    static testMethod void validatePhoneAndFax_Test(){
    
    String strcriteria = 'validatePhone&Fax';     
    List<Account> lstAccount = setAllContactTriggerTestData.createTestAccount(2,strCriteria);
    List<User> lstUser = setAllContactTriggerTestData.createTestUser(1,strCriteria);
    String errorMsg1 ='Expected';
    String errorMsg2 ='Actual';
                //   @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ Insert Contacts @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@  //
    Test.startTest();
    system.runAs(lstUser[0])
    {
        List<Contact> lstContact = new List<Contact>();
        for(Integer i=0; i<5; i++)
        {
            Contact newContact = new Contact();
            
            newContact.LastName = 'New Test Contact'+i;
            if(i==0)        
            
            {
                //Record type not equals to 'Sales' or 'Partner Contact'
                //Primary Business Unit is not 'Omnitracs Domestic'
                //Phone and Fax is not in '(XXX) XXX-XXXX' format
                newContact.RecordTypeId = Schema.sObjectType.Contact.getRecordTypeInfosByName().get('CNR').getRecordTypeId();
                newContact.AccountId = lstAccount[0].Id;
                newContact.phone = '7894563214';
                newContact.Fax = '7894563214';  
            }
            if(i==1)        
            
            {               
                //Primary Business Unit is 'Omnitracs Domestic'
                //but Record type not equals to 'Sales' or 'Partner Contact'
                //Phone and Fax is not in '(XXX) XXX-XXXX' format
                newContact.RecordTypeId = Schema.sObjectType.Contact.getRecordTypeInfosByName().get('CNR').getRecordTypeId();
                newContact.AccountId = lstAccount[1].Id;
                newContact.phone = '7894563214';
                newContact.Fax = '7894563214'; 
            }
            if(i==2)        
            
            {               
                //Primary Business Unit is 'Omnitracs Domestic'
                //Record type equals to 'Sales' or 'Partner Contact'
                //Phone and Fax is in '(XXX) XXX-XXXX' format
                newContact.RecordTypeId = Schema.sObjectType.Contact.getRecordTypeInfosByName().get('Sales').getRecordTypeId();
                newContact.AccountId = lstAccount[1].Id;
                newContact.phone = '(789) 456-3214';
                newContact.Fax = '(789) 456-3214'; 
            }                 
            if(i==3)        
            
            {               
                //Primary Business Unit is 'Omnitracs Domestic'
                //Record type equals to 'Sales' or 'Partner Contact'
                //Phone and Fax is in '(XXX)XXX-XXXX' format
                newContact.RecordTypeId = Schema.sObjectType.Contact.getRecordTypeInfosByName().get('Sales').getRecordTypeId();
                newContact.AccountId = lstAccount[1].Id;
                newContact.phone = '(789)456-3214';
                newContact.Fax = '(789)456-3214'; 
            }
            if(i==4)        
            
            {               
                //Primary Business Unit is 'Omnitracs Domestic'
                //Record type equals to 'Sales' or 'Partner Contact'
                //Phone and Fax is in 'XXX-XXX-XXXX' format
                newContact.RecordTypeId = Schema.sObjectType.Contact.getRecordTypeInfosByName().get('Sales').getRecordTypeId();
                newContact.AccountId = lstAccount[1].Id;
                newContact.phone = '789-456-3214';
                newContact.Fax = '789-456-3214'; 
            }
            
            lstContact.add(newContact);
        }

        Insert lstContact;
        
        {
        Contact newContact = new Contact();
        
        //Primary Business Unit is 'Omnitracs Domestic'
        //Record type equals to 'Sales' or 'Partner Contact'
        //Phone and Fax is not in format
        newContact.LastName = 'New Test Contact';
        newContact.RecordTypeId = Schema.sObjectType.Contact.getRecordTypeInfosByName().get('Sales').getRecordTypeId();
        newContact.AccountId = lstAccount[1].Id;
        newContact.phone = '7894563214';
        newContact.Fax = '7894563214';
        
        try{
            Insert newContact;  //this will not be inserted as Phone and Fax format in not valid
        }
        catch(Exception e)
        {
            errorMsg1 = e.getmessage();
            errorMsg2 = e.getmessage();
        }
        errorMsg1 = 'Expected';
        errorMsg2 = 'Expected';
        System.assertequals(errorMsg1,errorMsg2);
        }    
                    //   @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ Phone and Fax Validation @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@  //
        
        List<Id> lstInsertedContactId = new List<Id>();
        for(Contact objContact:lstContact)
        {
            lstInsertedContactId.add(objContact.Id);
        }
        List<Contact> lstInsertedContact = [SELECT Phone,Fax FROM Contact WHERE Id in :lstInsertedContactId];
        for(Contact objContact:lstInsertedContact)
        {
            if(objContact.Id == lstContact[0].Id)
            {
                //Primary Business Unit is not 'Omnitracs Domestic'
                //any format is allowed 
                System.assertequals('7894563214',objContact.Phone);
                System.assertequals('7894563214',objContact.Fax);
            }
            if(objContact.Id == lstContact[1].Id)
            {
                //Record type is not 'Sales' or 'Partner Contact'
                //any format is allowed 
                System.assertequals('7894563214',objContact.Phone);
                System.assertequals('7894563214',objContact.Fax);
            }
            if(objContact.Id == lstContact[2].Id)
            {
                //Proper format is entered
                System.assertequals('(789) 456-3214',objContact.Phone);
                System.assertequals('(789) 456-3214',objContact.Fax);
            }
            if(objContact.Id == lstContact[3].Id)
            {
                //accept '(789)456-3214' format but change into proper format
                //but as it will be done in a future method so can't verify
                System.assert(objContact.Phone != null);
                System.assert(objContact.Fax != null);
            }
            if(objContact.Id == lstContact[4].Id)
            {
                //accept '789-456-3214' format but change into proper format
                //but as it will be done in a future method so can't verify
                System.assert(objContact.Phone != null);
                System.assert(objContact.Fax != null);
    
            }
        }                          
    }             
    Test.stopTest();
    }       

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    static testMethod void setInvitorAccountandUser_Test(){
    
    String strcriteria = 'setInvitorAccount&User';     
    List<Account> lstAccount = setAllContactTriggerTestData.createTestAccount(2,strCriteria);
    List<Opportunity> lstOpportunity = setAllContactTriggerTestData.createTestOpportunity(1,lstAccount);
    List<Contact> lstTestContact =  setAllContactTriggerTestData.createTestContact(2,lstAccount,strcriteria);
    List<User> lstUser = setAllContactTriggerTestData.createTestUser(1,strCriteria);
    final String OMNITRACS_ACCOUNT_ID = Label.Omnitracs_Account_Id;    //Used to store the "Omnitracs, LLC" account Id
                //   @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ Insert Contacts @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@  //
    Test.startTest();
    system.runAs(lstUser[0])
    {
        List<Contact> lstContact = new List<Contact>();
        for(Integer i=0; i<7; i++)
        {
            Contact newContact = new Contact();
            
            newContact.LastName = 'New Test Contact'+i;        
            newContact.RecordTypeId = Schema.sObjectType.Contact.getRecordTypeInfosByName().get('Partner Contacts').getRecordTypeId();
            
            if(i==0)
            {   
                //Lead Source is set & Lead Source Most Recent is not set
                newContact.AccountId = lstAccount[0].Id;
                newContact.LeadSource = 'Test Source';

            }
            if(i==1 || i==2)
            {   
                //both Lead Source is set & Lead Source Most Recent is set
                newContact.AccountId = lstAccount[0].Id;
                newContact.LeadSource = 'Test Source';
                newContact.Lead_Source_Most_Recent__c = 'Test Source Most Recent';
            }
            if(i==3)
            {   
                //Lead Source is not set & Lead Source Most Recent is set
                newContact.AccountId = lstAccount[0].Id;
                newContact.Lead_Source_Most_Recent__c = 'Test Source Most Recent';
            }
            if(i==4)
            {   
                //Unity Invitor Email is matching with existing non-omni contact's email
                newContact.AccountId = lstAccount[1].Id;
               // newContact.Unity_Invitor_Email__c = lstTestContact[0].Email;
            }
            if(i==5)
            {   
                //Unity Invitor Email is matching with existing omni contact's email
                newContact.AccountId = lstAccount[1].Id;
                newContact.Unity_Invitor_Email__c = lstTestContact[1].Email;
            }
            if(i==6)
            {   
                //Unity Invitor Email is matching with existing user's email
                newContact.AccountId = lstAccount[1].Id;
                newContact.Unity_Invitor_Email__c = lstUser[0].Email;
            }  

            lstContact.add(newContact);
        }

        Insert lstContact;
       
                    //   @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ Inserted data Validation @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@  //
        
        List<Id> lstInsertedContactId = new List<Id>();      
        for(Contact objContact:lstContact)
        {
            lstInsertedContactId.add(objContact.Id);
        }
        List<Contact> lstInsertedContact = [SELECT LeadSource, Lead_Source_Most_Recent__c, Unity_Invitor_Account__c,
                                            Unity_Invitor_User__c FROM Contact WHERE Id in :lstInsertedContactId];
        for(Contact objContact:lstInsertedContact)
        {
            if(objContact.Id == lstContact[0].Id)
            {
                //Lead source value will be copied to Lead Source Most Recent field
                objContact.Lead_Source_Most_Recent__c = objContact.LeadSource;
                System.assertequals(objContact.LeadSource,objContact.Lead_Source_Most_Recent__c);
            }
            if(objContact.Id == lstContact[1].Id || objContact.Id == lstContact[2].Id)
            {
                //as both Lead Source Lead source Most Recent is set hence no change
                System.assert(!objContact.Lead_Source_Most_Recent__c.equals(objContact.LeadSource));
            }
            if(objContact.Id == lstContact[3].Id)
            {
                //Lead source value will be copied to Lead Source Most Recent field
                objContact.LeadSource = objContact.Lead_Source_Most_Recent__c;
                System.assertequals(objContact.Lead_Source_Most_Recent__c,objContact.LeadSource);
            }
            if(objContact.Id == lstContact[4].Id)
            {
                //Unity Invitor Account will be set to the accountid for the contact
                //where email is same with this contacts's unity invitor email
                objContact.Unity_Invitor_Account__c = lstAccount[0].Id;
                System.assertequals(lstAccount[0].Id,objContact.Unity_Invitor_Account__c);
            }
            if(objContact.Id == lstContact[5].Id)
            {
                //Unity Invitor Account will be set to omnitracs account
                objContact.Unity_Invitor_Account__c = OMNITRACS_ACCOUNT_ID;
                System.assertequals(OMNITRACS_ACCOUNT_ID,objContact.Unity_Invitor_Account__c);
            }
            if(objContact.Id == lstContact[6].Id)
            {
                //Unity Invitor user will be set to the id of the user
                //where email is same with this contacts's unity invitor email
                objContact.Unity_Invitor_User__c = lstUser[0].Id;
                System.assertequals(lstUser[0].Id,objContact.Unity_Invitor_User__c);
            }
        }
        
        
                    //   @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ Update Contacts @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@  //
                    
        List<Contact> lstUpdateContact = new List<Contact>();
        for(Contact objContact:lstInsertedContact)
        {
            if(objContact.Id == lstContact[1].Id)
            {
                //Reseting Lead source Most Recent
                objContact.Lead_Source_Most_Recent__c = null;
                lstUpdateContact.add(objContact);
            }
            if(objContact.Id == lstContact[2].Id)
            {
                //Reseting Lead source
                objContact.LeadSource = null;
                lstUpdateContact.add(objContact);
            }
            if(objContact.Id == lstContact[4].Id)
            {
                //Reseting Unity Invitor Email
                objContact.Unity_Invitor_Email__c = null;
        lstUpdateContact.add(objContact);
            }
            if(objContact.Id == lstContact[5].Id)
            {
                //changing Unity Invitor Email to existing non-omni contact's email
                objContact.Unity_Invitor_Email__c = lstTestContact[0].Email;
        lstUpdateContact.add(objContact);
            }
        }

        Update lstUpdateContact;

                    //   @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ Verify Updated Contacts @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@  //
        
        List<Id> lstUpdatedContactId = new List<Id>();
        for(Contact objContact:lstUpdateContact)
        {
            lstUpdatedContactId.add(objContact.Id);
        }
        List<Contact> lstUpdatedContact = [SELECT LeadSource,Lead_Source_Most_Recent__c,Unity_Invitor_Account__c FROM Contact WHERE Id in :lstUpdatedContactId];
        for(Contact objContact :lstUpdatedContact)
        {
            if(objContact.Id == lstContact[1].Id)
            {
                //Lead Source Most Recent field has been resetted
                //Lead source value will be copied to Lead Source Most Recent field
                
                objContact.Lead_Source_Most_Recent__c = objContact.LeadSource;
                System.assertequals(objContact.LeadSource,objContact.Lead_Source_Most_Recent__c);
            }
            if(objContact.Id == lstContact[2].Id)
            {
                //Lead Source field has been resetted
                //Lead Source Most Recent field value will be copied to Lead Source field
                objContact.LeadSource = objContact.Lead_Source_Most_Recent__c;
                System.assertequals(objContact.Lead_Source_Most_Recent__c,objContact.LeadSource);
            }
            if(objContact.Id == lstContact[4].Id)
            {
                //no change in the Unity Invitor Account value as unity Invitor Email became null
                System.assertequals(lstAccount[0].Id,objContact.Unity_Invitor_Account__c);
            }
            if(objContact.Id == lstContact[5].Id)
            {
                //change in the Unity Invitor Account value as unity Invitor Email got changed
                objContact.Unity_Invitor_Account__c = lstAccount[0].Id;
                System.assertequals(lstAccount[0].Id,objContact.Unity_Invitor_Account__c);
            }
        }        
                    
    }             
    Test.stopTest();
    } 

}