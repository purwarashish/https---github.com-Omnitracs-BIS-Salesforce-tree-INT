public with sharing class AssociateRequestFormController {
    
    public Request_Form__c requestForm {get; set;}
    public List<Request_Form_Contact__c> multiParties {get; set;}
    public List<Request_Form_Contact__c> associatedAccounts {get; set;}
    public List<Request_Form_Contact__c> associatedContacts {get; set;}
    public Boolean submitSuccessfull {get;set;}
    
    public AssociateRequestFormController(ApexPages.StandardController ctrl){
        this.requestForm = (Request_Form__c)ctrl.getRecord();
        associateMultiParties();
    }
    
    private void associateMultiParties(){
        Set<String> companyNames = new Set<String>();
        Map<String, Account> accountMap = new Map<String, Account>();
        Set<String> companySet = new Set<String>();
        associatedAccounts = new List<Request_Form_Contact__c>();
        associatedContacts = new List<Request_Form_Contact__c>();
        submitSuccessfull = false;
        getRFCLists();
        if(associatedAccounts == null || associatedAccounts.size() == 0){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, 'No Multiparties to associate with the entered company'));
        }
    }
    
    public Pagereference Cancel(){
        return new Pagereference('/'+requestForm.Id);
    }
    
    public Pagereference updateAccountRFC(){
        for(Request_Form_Contact__c rfc : associatedAccounts){
            rfc.To_Create__c = false;
        }
        update associatedAccounts;
        getRFCLists();
        ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.INFO, 'Account(s) has been updated.'));
        return null;
    }
    
    public Pagereference createAccountRFC(){
        Map<String,Schema.RecordTypeInfo> rtMapByName = Schema.SObjectType.Account.getRecordTypeInfosByName();
        List<Account> accountsToCreate = new List<Account>();
        List<Address__c> accountsAddressToCreate = new List<Address__c>();
        Map<String, Request_Form_Contact__c> rfcMap = new Map<String, Request_Form_Contact__c>();
        List<Request_Form_Contact__c> rfcToUpdate = new List<Request_Form_Contact__c>();
        //System.debug('********************* Associated Accounts -- '+associatedAccounts.size());
        for(Request_Form_Contact__c rfc : associatedAccounts){
            if(rfc.To_Create__c){
                //System.debug('********************* RFC NAME -- '+rfc.Name__C);
                accountsToCreate.add(new Account(name=rfc.company__c, Legal_Name__c=rfc.company__c, RecordTypeId=rtMapByName.get('Other').getRecordTypeId(), 
                                                 QWBS_Market__c = 'Other', Phone=rfc.Phone__c, BillingState = rfc.State_Province_PL__c, BillingCountry = 'USA',
                                                 Location_of_Entity_Formation__c = requestForm.Legal_Entity_State__c, Entity__c = requestForm.Legal_Entity_Type__c,
                                                 BillingStreet=rfc.Street_1__c, BillingCity=rfc.City__c, BillingPostalCode=rfc.Zipcode__c, Fax=rfc.Fax__c));
                
                rfcMap.put(rfc.company__c, rfc);
            }
        }
        //System.debug('********************* Associated Accounts -- '+accountsToCreate.size());
        
        if(accountsToCreate.size() > 0){
            try{
                insert accountsToCreate;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.INFO, 'Selected Accounts are created succesfully.'));
                
                for(Account accnt : accountsToCreate){
                    Request_Form_Contact__c rfc = rfcMap.get(accnt.Name);
                    if(rfc != null && String.isBlank(rfc.Account_Associated__c) && rfc.company__c == accnt.Name){
                        rfc.Account_Associated__c = accnt.Id;   
                        rfcToUpdate.add(rfc);           
                    }
                    
                    accountsAddressToCreate.add(new Address__c(Account__c=accnt.Id, Location_Type__c='Corporate HQ', Address_Line_1__c=accnt.BillingStreet, City__c = accnt.BillingCity, Zip_Postal_Code__c=accnt.BillingPostalCode,
                                                               State_Province__c=accnt.BillingState, Country__c='United States', Phone_Number__c=accnt.phone, Fax_Number__c=accnt.Fax));
                }
                
                if(rfcToUpdate.size() > 0){
                    update rfcToUpdate;
                }
                
                if(accountsAddressToCreate.size()>0){
                    insert accountsAddressToCreate;
                }
            }catch(Exception e){
                //ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, 'Exception occured while creating accounts -- '+e.getMessage()));
            }
        
        }
        getRFCLists();
        return null;
    }
    
    public Pagereference createContactRFC(){
        List<Contact> contactsToCreate = new List<Contact>();
        Map<String, Request_Form_Contact__c> rfcMap = new Map<String, Request_Form_Contact__c>();
        List<Request_Form_Contact__c> rfcToUpdate = new List<Request_Form_Contact__c>();
        for(Request_Form_Contact__c rfc : associatedContacts){
            if(rfc.To_Create__c){
                Contact cntct = createContact(rfc);
                contactsToCreate.add(cntct);
                rfcMap.put(cntct.Name, rfc);
            }
        }
        
        if(contactsToCreate.size() > 0){
            try{
                insert contactsToCreate;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.INFO, 'Selected Contacts are created succesfully.'));
                
                for(Contact cntct : contactsToCreate){
                    Request_Form_Contact__c rfc = rfcMap.get(cntct.Name);
                    if(rfc != null && String.isBlank(rfc.Contact_Associated__c)){
                        rfc.Contact_Associated__c = cntct.Id;   
                        rfcToUpdate.add(rfc);           
                    }
                }
                
                if(rfcToUpdate.size() > 0){
                    update rfcToUpdate;
                }
            }catch(Exception e){
            }
        }
        getRFCLists();
        return null;
    }
    
    public Pagereference updateContactRFC(){
        for(Request_Form_Contact__c rfc : associatedContacts){
            rfc.To_Create__c = false;
        }
        update associatedContacts;
        getRFCLists();
        ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.INFO, 'Contact(s) has been updated.'));
        return null;
    }
    
    
    
    private Contact createContact(Request_Form_Contact__c rfc){
        Contact cntct = new Contact();
        cntct.AccountId = rfc.Account_Associated__c;
        cntct.FirstName = rfc.First_Name__c;
        cntct.LastName = rfc.Name__c;
        cntct.MailingStreet = rfc.Street_1__c;
        cntct.MailingCity = rfc.City__c;
        cntct.MailingState = rfc.State_Province_PL__c;
        cntct.MailingPostalCode = rfc.Zipcode__c;
        cntct.MailingCountry = rfc.Country__c;
        cntct.Fax = rfc.Fax__c;
        cntct.Title = rfc.Title__c;
        cntct.Phone = rfc.Phone__c;
     // cntct.MIBOS_Migration_Name__c = rfc.company__c;
        return cntct;
    }
    
    private void getRFCLists(){
        associatedAccounts = [select Id,Name,First_Name__c, Name__c, Company__c,Title__c,Street_1__c, Street_2__c,City__c,
                                     State_Province_PL__c,Zipcode__c,Country__c,Department__c,Email__c,Fax__c,Phone__c,
                                     To_Create__c, Account_Associated__c, Contact_Associated__c, Type__c, Authorized_Signer__c
                                from Request_Form_Contact__c where Multiparty__c = :requestForm.Id and company__c != null];
        associatedContacts = [select Id,Name,First_Name__c, Name__c, Company__c,Title__c,Street_1__c, Street_2__c,City__c,
                                     State_Province_PL__c,Zipcode__c,Country__c,Department__c,Email__c,Fax__c,Phone__c,
                                     To_Create__c, Account_Associated__c, Contact_Associated__c, Type__c, Authorized_Signer__c
                                from Request_Form_Contact__c where Multiparty__c = :requestForm.Id and company__c != null];
    }
}