public class  PartnerMasterOwnerController
{
    /************ Public variable **********************/
    public boolean isTransferOpp {get; set;}
    public boolean isTransferCont {get; set;}
    public boolean isTransferOpenActivity {get; set;}
    public boolean isSendEmail {get; set;}
    public string selectedCustAcctId {get; set;}
    public String selectedPartAcctId {get; set;}
    public String SelectedOwnerId {get; set;}
    public boolean isSelectOption{get; set;}{isSelectOption = false;}
    public boolean isShowSelectOption{get; set;}{isShowSelectOption = false;}
    public static boolean updtPartnerAgent = false; //this variable is used to partnerAgent is changed only if owner is changed. 
    
    
    //Added by Anand : For CR 00094594
    public Boolean isError {get;set;}
  
    
    
    //Added by Anand : For Case 00081297 
    public Account acct {get;set;}
    //Taking this functionality out as part of the case 95098 - Leaving the function, in case we need tO
    //add limitations to the assing to partner link.   
    public boolean getisNotTrasnferrableToPartner()
    {
        /* Set<String> statuses = new Set<String>{
                'Inactive'
                ,'Inactive Prospect'
                ,'Closed Contract Customer'
                ,'Closed - End of Eval'
            };
            
         if(statuses.contains(acct.QWBS_Status__c))   
         {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Account cannot be assigned to a partner if status is any of the following: Inactive, Inactive Prospect,Closed Contract Customer and Closed - End of Eval '));
            return true; 
         }*/
         return false;
    }
    //Change for 00081297 ends
    public list<User> lstPartnerUsers {get; set;} {
        lstPartnerUsers = new list<User>();
    }
    public list<Account> lstActivePartnerAccounts {get; set;} {
        lstActivePartnerAccounts = new list<Account>();
    }
    public list<Account> lstPartnerAccounts {get; set;} {
        lstPartnerAccounts = new list<Account>();
    }
    
    public map<string,string> mapUsrIdnName{get; set;}{
        mapUsrIdnName = new map<string,string>();
    }
    public List<SelectOption> lstPartnerAccountSelectOptions{get; set;}{
        lstPartnerAccountSelectOptions = new List<SelectOption>();
    }
    
    public List<SelectOption> lstAccountSelectOptions{get; set;}{
        lstAccountSelectOptions = new List<SelectOption>();
    }
    
    /************ private variable **********************/
        
    private string masterPartnerOwner;
    private account currentAccount = new account();
    private string loggedInUsrAccount;
    private string loggedInUsrAccountName;
    private string loggedInUsrId;
    private string loggedInUsrType; 
    
    /**
      *@description: Constructor , contains logic for querying
      *loggedin users information and the selected customer accountId from url 
     **/ 
              
    public PartnerMasterOwnerController(ApexPages.StandardController controller)
    {    
        acct =  (Account)controller.getRecord();    
        loggedInUsrId = userInfo.getUserId();
        loggedInUsrType = userInfo.getUserType();
        list<user> lstloggedUsrAcct = new list<user>();
        lstloggedUsrAcct = [select
                                   AccountId
                              from 
                                  user
                              where
                                  id =:loggedInUsrId
                              limit 1 ];
        if(lstloggedUsrAcct != null && lstloggedUsrAcct.size() > 0)
        {
            loggedInUsrAccount = lstloggedUsrAcct[0].AccountId;    
        }
        selectedCustAcctId = Apexpages.currentPage().getParameters().get('Id');
        system.debug('%%%%%selectedCustAcctId'+selectedCustAcctId);
        populateSelectedPartnerId();
        populateListOfPartnersAccounts(); 
        populateListOfPartners();
        populateListOfUsers();
        
        
        
        
    }
    
    private void populateSelectedPartnerId() {
        // Get the ownerId
        List<Account> lstSelCustAccount = 
                        [
                            SELECT
                                id,
                                name,
                                ownerId,
                                RecordOwner__c 
                            FROM
                                ACCOUNT
                            WHERE
                                id = :selectedCustAcctId
                            LIMIT
                                1
                        ];                          
        if( (null == lstSelCustAccount) || (0 >= lstSelCustAccount.size()) ) {
            // Error condition
            System.debug(LoggingLevel.ERROR,
                         'No records found for the selected customer-account with id = ' + selectedCustAcctId);
            return;
        }
        
        // Get the owner's and record-owner's accountId
        Id ownerId = lstSelCustAccount[0].ownerId;
        if( null != lstSelCustAccount[0].RecordOwner__c )
        {
            ownerId = lstSelCustAccount[0].RecordOwner__c;
        } 
        List<User> lstOwner = 
                        [
                            SELECT
                                id,
                                accountId,
                                ProfileId                                
                            FROM
                                User
                            WHERE
                                 id = :ownerId  
                            LIMIT
                                 :1
                        ];                                                      
        if( (null == lstOwner) || (0 >= lstOwner.size()) ) {
            // Error condition
            System.debug(LoggingLevel.ERROR,
                         'No records found for the owners.');
            return;
        }           
        selectedPartAcctId = '' + loggedInUsrAccount;
        system.debug('%%%%%selectedPartAcctId'+selectedPartAcctId);
        
        
    }
    /**
      *@Description: This method contains the functionality to populate the dropdown
      *list in PartnerMasterOwnerExternal Vf page. 
    **/
    private void populateListOfPartnersAccounts()
    {
        if(null != lstPartnerAccounts && 0 < lstPartnerAccounts.size())
        {
            lstPartnerAccounts.clear();
            lstAccountSelectOptions.clear();
        }
        
        list<PartnerMasterOwnerAccount__c>lstPartnerMasterOwnerAccount = PartnerMasterOwnerAccount__c.getall().values();
        system.debug('@@@lstPartnerMasterOwnerAccount'+lstPartnerMasterOwnerAccount);
        List<string> lstStrOfAcctIds = new list<string>();
        list<Account> lstAccounts = new list<Account>();
        if(lstPartnerMasterOwnerAccount != null && lstPartnerMasterOwnerAccount.size()>0)
        {
             for(PartnerMasterOwnerAccount__c lst:lstPartnerMasterOwnerAccount)
             {
                 if(loggedInUsrAccount != null && loggedInUsrAccount != '')
                 if(lst.OwnerAccountId__c == loggedInUsrAccount.substring(0,15))
                 {
                         system.debug('%%%%%%%Amrita');
                         string eligibleAccountIds = lst.AccountIdCombination__c;
                         if(eligibleAccountIds != null)
                         {
                             if(eligibleAccountIds.contains(','))
                             {
                                 lstStrOfAcctIds = eligibleAccountIds.replace(' ', '').split(',',0);    
                             }
                             else
                             {
                                 lstStrOfAcctIds.add(lst.AccountIdCombination__c);    
                             } 
                         }
                         lstStrOfAcctIds.add(loggedInUsrAccount);
                 }    
             }    
        }
        if(lstStrOfAcctIds != null  && lstStrOfAcctIds.size() > 0)
        {
            system.debug('lstStrOfAcctIds');
            lstAccounts = [Select
                               name
                           From
                               Account
                           where
                                id IN :lstStrOfAcctIds
                           limit 50000
                           ];    
        }
        if(loggedInUsrAccount == null && loggedInUsrAccount == '') 
            lstAccountSelectOptions.add(new SelectOption('-- None --', '-- None --')); 
                                                 
        List<SelectOption> lstAccountSelectOptionstemp = new List<selectOption>();
        for(Account acct : lstAccounts)
        {
            if(acct.id == loggedInUsrAccount.substring(0,15))
            {
                lstAccountSelectOptions.add(new SelectOption(acct.id, acct.name));
            }
            else
            {
                lstAccountSelectOptionstemp.add(new SelectOption(acct.id, acct.name));    
            }
        }
        system.debug('@@@@@@lstAccountSelectOptionstemp'+lstAccountSelectOptionstemp);
        system.debug('@@@@@@lstAccountSelectOptions'+lstAccountSelectOptions); 
        if(lstAccountSelectOptions != null && lstAccountSelectOptions.size() > 0)
        {
           isSelectOption = true;
           if(lstAccountSelectOptionstemp != null && lstAccountSelectOptionstemp.size() > 0)
           {
               lstAccountSelectOptions.addAll(lstAccountSelectOptionstemp);    
               //isSelectOption = true;
           }
        }  
        
        system.debug('******************* lstAccountSelectOptions: ' + lstAccountSelectOptions);
    }
    
    /**
      *@Description: This method contains the functionality to populate the dropdown
      *list in PartnerMasterOwnerInternal Vf page. 
    **/
        
    private void populateListOfPartners()
    {
        if(null != lstActivePartnerAccounts && 0 < lstActivePartnerAccounts.size()) {
            lstActivePartnerAccounts.clear();
            lstPartnerAccountSelectOptions.clear();
        }
        
        lstActivePartnerAccounts = [
                                        select
                                            id,
                                            name,
                                            Active_Partner_Account__c,
                                            isPartner                                      
                                        from 
                                            Account
                                        where 
                                            Active_Partner_Account__c = TRUE
                                            AND isPartner = TRUE
                                        order by 
                                            name    
                                        limit 
                                            5000
                                 ];    

        lstPartnerAccountSelectOptions.add(new SelectOption('-- None --', '-- None --'));                                 
        for(Account acct : lstActivePartnerAccounts) {
            lstPartnerAccountSelectOptions.add(new SelectOption(acct.id, acct.name));
        }
        if(lstPartnerAccountSelectOptions != null && lstPartnerAccountSelectOptions.size() > 0)
        {
            isShowSelectOption = true;
        }   
        
        system.debug('******************* lstPartnerAccountSelectOptions : ' + lstPartnerAccountSelectOptions);
    }
    
    /**
      *@Description: This method contains the functionality to populate the 
      * list of user name on the page based on the account selected from the 
      * dropdown list. 
    **/

    public void populateListOfUsers() {
        if(0 < lstPartnerUsers.size()) {
            lstPartnerUsers.clear();
            mapUsrIdnName.clear();
        }
        system.debug('@@@@@@@selectedPartAcctId'+selectedPartAcctId);
        if(selectedPartAcctId != null && '' != selectedPartAcctId)
        {             
             if(loggedInUsrType == 'PowerPartner') 
             {
                 lstPartnerUsers = [
                           Select 
                                 Id,
                                 Name
                           from 
                                 User
                           Where
                                 accountId = :selectedPartAcctId
                           AND
                                 isActive = true
                           AND
                                 userType = 'PowerPartner' 
                           AND
                                 id <> :loggedInUsrId 
                           limit 
                                 50000
                       ];    
             }
             else
             {
                 lstPartnerUsers = [
                           Select 
                                 Id,
                                 Name
                           from 
                                 User
                           Where
                                 accountId = :selectedPartAcctId
                           AND
                                 isActive = true 
                           AND
                                 userType = 'PowerPartner'
                           AND
                                 id <> :loggedInUsrId  
                           limit 
                                 50000
                       ];
             }
             system.debug('@@@@lstPartnerUsers'+lstPartnerUsers);
             if(lstPartnerUsers != null && lstPartnerUsers.size() > 0)
             {
                 for(user usr : lstPartnerUsers)
                 {
                     mapUsrIdnName.put(usr.id, usr.name);                
                 }
             }
        }      
        
        system.debug('*******************  LIST OF USER : ' + lstPartnerUsers);
        system.debug('*******************  POP LIST OF USER : ' + mapUsrIdnName); 
    }

    public pageReference AssignUserOrQueue()
    {
        // We need to set appropriate record types for Account, Contact and Opportunity.
        // Running one SOQL to save on limits.
        isError = false;
        SavePoint sp  = Database.setSavepoint();
        String accountRecordTypeId = null;
        String contactRecordTypeId = null;
        String opportunityRecordTypeId = null;
        List<RecordType> recordTypes = new List<RecordType>([
           select  Id
                   ,Name
                   ,SobjectType
           from    RecordType
           where   Name in ('Partner Account (Reseller)','Partner Contacts','Partner Opportunity (Reseller)')
        ]);
        
system.debug('*************************** recordTypes : ' + recordTypes);
        for(RecordType rt : recordTypes) {
            if     ('Account'.equals(rt.SobjectType)) accountRecordTypeId = rt.Id;
            else if('Contact'.equals(rt.SobjectType)) contactRecordTypeId = rt.Id;
            else if('Opportunity'.equals(rt.SobjectType)) opportunityRecordTypeId = rt.Id;
        }
        
system.debug('@@@@@@SelectedOwnerId'+ SelectedOwnerId);
        List<Account> lstAcct = [
            select  id
                    ,name
                    ,ownerId
                    ,RecordOwner__c
                    ,RecordTypeId
                    ,Manual_Assignment__c,
                    QWBS_Status__c
                    ,(Select Id,Subject,ownerId,IsTask,whatid From OpenActivities) 
            from    Account
            where   id = :selectedCustAcctId
            limit 1
        ];
system.debug('*************************** lstAcct : ' + lstAcct);                                 
        List<User> lstUser = [
            select  id,name,email,UserType,AccountId,Master_Partner_User__c
            from    User
            where   id = :SelectedOwnerId
            limit   1
        ];
system.debug('*************************** lstUser : ' + lstUser);                                    
        string newOwnerAccountId = '';
        string newAcctRecId = '';
        if(lstUser != null && lstUser.size() >0)
        {
            newOwnerAccountId = lstUser[0].AccountId;    
        }                          
system.debug('*************************** newOwnerAccountId : ' + newOwnerAccountId);        
        /*******Query custom setting to set the recordType of the account *****/
        // list<PartnerMasterOwnerRecordType__c> lstPartnerMasterOwnerRecordType = PartnerMasterOwnerRecordType__c.getAll().values();
        set<string> setOpenActivityOwnerId = new set<string>();
        if(lstAcct != null && lstAcct.size() >0)
        {
            currentAccount = lstAcct[0];
           // string currRecordType = currentAccount.RecordTypeId;
           /* if(lstPartnerMasterOwnerRecordType != null && lstPartnerMasterOwnerRecordType.size()>0)
            {
                for(PartnerMasterOwnerRecordType__c lst:lstPartnerMasterOwnerRecordType)
                {
                    if(lst.CurrentRecordType__c == currRecordType.substring(0,15)
                     && lst.OwnersAccountId__c == newOwnerAccountId.substring(0,15))
                    {
                        newAcctRecId = lst.ChangedRecordType__c;         
                    }
                }   
                
            }
            if(newAcctRecId != null && newAcctRecId !='')
            {
                currentAccount.recordTypeId = newAcctRecId;     
            }
            */
            if(lstAcct[0].OpenActivities !=null && lstAcct[0].OpenActivities.size() > 0)
            {
                for(integer i=0;i<lstAcct[0].OpenActivities.size();i++)
                {
                   setOpenActivityOwnerId.add(lstAcct[0].OpenActivities[i].ownerId);
                } 
             }
         } 
         
system.debug('*************************** isTransferOpp : ' + isTransferOpp);        
        
        if(lstUser != null && lstUser.size() > 0)
        {
             masterPartnerOwner = lstUser[0].Master_Partner_User__c;
             if(masterPartnerOwner != null && masterPartnerOwner != '')
                 currentAccount.ownerId =  masterPartnerOwner; 
             currentAccount.RecordOwner__c = lstUser[0].id;
             //Added by Anand for Case: 00081297
             currentAccount.Manual_Assignment__c = false;
             
             /*** transfer of open opportunities ***/
             // Code modified for CR 105286
             
             List<Opportunity> lstOpportunity = new List<Opportunity>();
             List<String> listOfClosedStatusToBeConsidered =  new List<String>();
             listOfClosedStatusToBeConsidered = Global_Variable__c.getInstance('Excluded_Closed_Opp_Status').value__c.split(';');
             
             /*if( isTransferOpp 
                || isTransferCont 
                || isTransferOpenActivity )
            {
                    currentAccount.Mass_Transfer_Of_Related_Records__c = true;                  
            }*/
            try{
            update currentAccount;
            }
            catch(exception e)
            {
                throwError('Error: ' , e.getMessage());
                return null;
            } 
             
             
             if(isTransferOpp == true)
             {
                 
                 lstOpportunity = [
                                 Select 
                                     AccountId,
                                     ownerId,
                                     name 
                                 From 
                                     Opportunity
                                  where 
                                      AccountId = :selectedCustAcctId
                                  And
                                      (isClosed = False OR StageName IN: listOfClosedStatusToBeConsidered)
                                  limit 50000
                               ];
system.debug('*************************** lstOpportunity : ' + lstOpportunity);                               
                 if(0 < lstOpportunity.size())
                 {
                     for(Opportunity opp:lstOpportunity)
                     {
                         opp.ownerId = SelectedOwnerId;
system.debug('*************************** opp.ownerId  : ' + opp.ownerId );                         
                         opp.RecordTypeId = opportunityRecordTypeId;
system.debug('*************************** opp.RecordTypeId   : ' + opp.RecordTypeId  );                         
                     }
                     try{
                 update lstOpportunity;
                     }
                     catch(exception e)
                     {
                        Database.rollback(sp);
                        throwError('Error in transferring opportunities: ' , e.getMessage());
                     } 
                 }
          }   
system.debug('*************************** isTransferOpp : ' + isTransferOpp);
             /**** trasfer Contact owner ******/
            List<Contact> lstContact = new List<Contact>();
            if(isTransferCont == true)
            {
             
                 lstContact = [
                                 Select 
                                     AccountId,
                                     ownerId,
                                     id,
                                     name 
                                 From 
                                     contact
                                  where 
                                      AccountId = :selectedCustAcctId
                                  limit 50000
                               ];
system.debug('*************************** lstContact : ' + lstContact);                               
                 if(0 < lstContact.size())
                 {
                     for(contact cont:lstContact)
                     {
                         cont.ownerId = SelectedOwnerId;
system.debug('*************************** cont.ownerId : ' + cont.ownerId);                         
                         cont.RecordTypeId = contactRecordTypeId;
system.debug('***************************  cont.RecordTypeId  : ' +  cont.RecordTypeId );                            
                     }
                 try{    
                 update lstContact;
                 }
                 catch(exception e)
                 {
                    Database.rollback(sp);
                    throwError('Error in transferring contacts: ' , e.getMessage());
                 } 
                 }   
                    
            }  
            /**** transfer open Activity *******/
            list<string> lstTaskIds = new list<string>();
            list<Task> lstTask = new list<Task>();
            list<string> lstEventIds = new list<string>();
            list<Event> lstEvent = new list<Event>();  
            if(isTransferOpenActivity == true )
            {
                if(currentAccount.openActivities != null && currentAccount.openActivities.size() > 0 )
                {
                    
                    for(integer i=0;i<currentAccount.openActivities.size();i++)
                    {     
                        // Added as per Case # 01732379
                        if((currentAccount.openActivities[i].whatid.getSObjectType().getDescribe().getName() != 'Contract'))
                        {
                            if(currentAccount.openActivities[i].isTask == true)
                            {
                                lstTaskIds.add(currentAccount.openActivities[i].id);     
                            }
                            else
                            {
                                lstEventIds.add(currentAccount.openActivities[i].id);
                            }
                        }
                    }
                    if(lstTaskIds != null && lstTaskIds.size() >0)
                    {
                        lstTask = [select 
                                                    id,
                                                    ownerId,
                                                    subject
                                                    from
                                                    Task
                                                where 
                                                     IsRecurrence = false AND // Added as per Case # 01732379
                                                     id IN :lstTaskIds
                                                    ];
                                                    
                        if(lstTask !=null && lstTask.size() > 0)
                        {
                            for(task records:lstTask)
                            {
                                records.ownerId = SelectedOwnerId;   
                            }
                                       
                            try
                            {
                                update lstTask;
                            }
                            catch(Exception e)
                            {
                                Database.rollback(sp);
                                throwError('Error in transferring tasks: ' , e.getMessage());
                            }    
                        }   
                    }
                    if(lstEventIds!= null && lstEventIds.size() >0)
                    {
                        lstEvent = [select 
                                                      id,
                                                      ownerId,
                                                      subject
                                                from
                                                      Event
                                                where 
                                                       IsRecurrence = false AND // Added as per Case # 01732379
                                                       id IN :lstEventIds];
                        if(lstEvent !=null && lstEvent.size() > 0)
                        {
                            for(Event records:lstEvent)
                            {
                                records.ownerId = SelectedOwnerId;   
                            }
                            try
                            {
                                update lstEvent;
                            }
                            catch(Exception e)
                            {
                                Database.rollback(sp);
                                throwError('Error in transferring events: ' , e.getMessage());
                            }    
                        }   
                    }
                }
            }
            /******* Sending email notification********************/
               
        }
        
        if(isSendEmail == true)
        {
        try
        {
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setUseSignature(false);
            if(SelectedOwnerId !=null && SelectedCustAcctId != null)
            {
                 if(lstUser != null && lstUser.size() > 0)
                 {
                     List<String> lstMailIds = new List<String>();
                     lstMailIds.add(lstUser[0].email);
                     mail.setToAddresses(lstMailIds);
                     mail.setSubject('[Action] '+ currentAccount.name+ ' has been assigned to you.');
                     String mailContent = '';
                     If(currentAccount != null)
                     {
                         
                         mailContent = mailContent + '<br/>';
                         mailContent = mailContent + 'Account '+ currentAccount.name  + ' has been assigned to you. To view the full details of this contact in Salesforce click on the following link: ';
                         system.debug('lstUser[0].userType'+ lstUser[0].userType);
                         if(lstUser[0].userType == 'PowerPartner')
                         {
                             string url =System.Label.Partner_login_URL;
                             mailContent = mailContent + '<br/><a href="'+url+'&retURL='+System.Label.Email+ currentAccount.id + '">'+  url + '</a>';
                         }                                             
                         else
                         {
                             String url = System.Label.Email + currentAccount.id;
                             mailContent = mailContent + '<br/><a href="'+url+currentAccount.id+'">'+url+'</a>';
                         }                                           
                     }
                     mail.setHtmlBody(mailContent);
                     mail.setWhatId(currentAccount.id);
                     mail.setSaveAsActivity(true);
                     Messaging.sendEmail(new Messaging.SingleEmailMessage[]
                     {
                          mail
                     }
                   );   
                 }
            }
        }
        catch(Exception e)
        {
            Database.rollback(sp);
            throwError('Error in sending notification mail: ' , e.getMessage());
        }
                
        }
        try{ 
            updtPartnerAgent = true;
            currentAccount.RecordTypeId = accountRecordTypeId;
            currentAccount.QWBS_Market__c = 'Channel';
            currentAccount.Sales_Channel__c = 'Indirect';
            currentAccount.FRA_Account_Manager__c = null;
            currentAccount.FRA_Customer_Service_Rep__c = null;
            //currentAccount.FRA_Contracts_Administrator__c = null;
            currentAccount.FRA_Software_Application_Eng__c = null;
            System.debug('********************************* QWBS_Status__c ' + currentAccount.QWBS_Status__c);
            if(currentAccount.QWBS_Status__c == 'Inactive Prospect')
            {
                currentAccount.QWBS_Status__c = 'Active Prospect';
                System.debug('********************************* QWBS_Status__c 2' + currentAccount.QWBS_Status__c);
            }
            
            /*if( currentAccount.Mass_Transfer_Of_Related_Records__c )
            {
                    currentAccount.Mass_Transfer_Of_Related_Records__c = false;                 
            }*/
            
            update currentAccount;
            
        }
        catch(Exception e)
        {
             Database.rollback(sp);
             throwError('Error in transferring account: ' , e.getMessage());
        }     
        return null;
    }    
    
    //Added by Anand : For CR 00094594
    public pageReference throwError (String objError, String Error)
    {
         if(Error.contains('_EXCEPTION,'))
         Error = Error.subString(Error.indexOf('_EXCEPTION,') + 11, Error.length());
         ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,objError + Error));
         
         System.debug('error ******* ');
         isError = true;
         return null;
    }
    
}