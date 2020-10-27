public with sharing class GenericTestClass {
    public static Integer custID = 12101986;
    public static Integer NMCAccount = 12101986;
    // Insert Account Record        
        public static Account insertAccount()
        {
            Account newAccount = new Account();
            newAccount.Name = 'SFDC';
            newAccount.Type = 'Other';
            newAccount.BillingStreet = 'BillingStreet';
            newAccount.BillingCity = 'BillingCity';
            newAccount.BillingState = 'BillingState';
            newAccount.BillingPostalCode = '12345';
            newAccount.BillingCountry = 'BillingCountry';
            newAccount.Fleet_Size__c = 5;
            newAccount.Segment__c = 'TL';
            newAccount.QWBS_Cust_ID__c = String.valueOf(custID);
            custID++; 
            insert newAccount;
            return newAccount;
        }
    //Insert Contact Record
        public static Contact insertContact(Id AcctId)
        {
            Contact newCnt=new Contact();
            newCnt.FirstName='SFDC';
            newCnt.LastName='Salesforce';
            newCnt.AccountId = AcctId;
            newCnt.MailingState = 'CA';
system.debug('newCnt:'+newCnt);
            insert newCnt;
            return newCnt;
        }
    
    //Insert NMC Account Record
        public static NMC_Account__c insertNMCAccount(Id AcctId)
        {
            NMC_Account__c newNMCAcct  = new NMC_Account__c();
            newNMCAcct.Account__c = AcctId;
            newNMCAcct.NMC_Account_Name__c = 'Test NMC Acct';
            newNMCAcct.NMC_Account__c = String.valueOf(NMCAccount);
            NMCAccount++;
            insert newNMCAcct;
            return newNMCAcct;
        }
        
    //Insert Group Record   
        public static Group insertGroup()     
        {
            Group newGroup = new Group();
            newGroup.name = 'Test Queue';
            insert newGroup;
            return newGroup;
        }
        
    //Insert 'Support Alert' Record
        public static Support_Alert__c insertSupportAlert(ID accountid)
        {
            Support_Alert__c newSuppalert = new Support_Alert__c();
            newSuppalert.Account__c = accountid;
            newSuppalert.Description__c = 'Test Descritpion';
            newSuppalert.End_Date__c =  date.today()+4;
            insert newSuppalert;
            return newSuppalert;
        }      
    //Insert 'System Outage' Record
        public static System_Outage__c insertSystemOutage(ID caseid)
        {
          System_Outage__c newSysOut = new System_Outage__c();
          newSysOut.Case__c = caseid;
          newSysOut.Type__c = 'Degraded Service';
          newSysOut.System__c = 'NMC';
          newSysOut.SubSystems__c = 'BGW200';
          newSysOut.Start_Time__c = system.now();
          insert newSysOut;
          return newSysOut;
        }
    // Insert Serialized Unit Summary Record
        public static Serialized_Unit_Summary__c insertSerUnitSumm(Id AcctId)
        {
            Serialized_Unit_Summary__c newSerUnit = new Serialized_Unit_Summary__c();
            newSerUnit.Account__c = AcctId;
            insert newSerUnit;
            return newSerUnit;
        }
        
    // Insert Serialized Unit Summary Record
        public static Serialized_Units__c insertSerUnit(Id AcctId)
        {
            Serialized_Units__c newSerUnit = new Serialized_Units__c();
            newSerUnit.Account__c = AcctId;
            newSerUnit.NMC_Account__c = GenericTestClass.insertNMCAccount(AcctId).ID;
            insert newSerUnit;
            return newSerUnit; 
        }
        
    //Insert Connection Type Record
        public static Connection_Type__c insertConnType(Id NMCId)
        {
            Connection_Type__c newConnType = new Connection_Type__c();
            newConnType.NMC_Account__c = NMCId;
            insert newConnType;
            return newConnType;
        }
        
    //Insert Case Record
    public static Case insertCase(String AcctId, String ContId)
    {
        Case newCase = new Case();
        if(AcctId != null && AcctId != '')
            newCase.AccountID = AcctID;
        if(ContId != null && ContId != '')
            newCase.ContactId = ContId;
        insert newCase;
        return newCase;
    }
    
    // Insert User
    public static User insertUser(Profile userProf, UserRole role)
    {
        if(userProf == null)
            userProf = [Select p.Id From Profile p limit 1];
        if(role == null)
            role = [Select u.Id From UserRole u limit 1];
        User NewUser = new user();
        NewUser.ProfileId = userProf.Id;
        NewUser.UserRoleId = role.Id;
        NewUser.email = 'test@test.com';
        NewUser.Username = 'test@test.com.12101986';
        NewUser.IsActive = true;
        NewUser.TimeZoneSidKey = 'America/Los_Angeles';
        NewUser.LocaleSidKey = 'en_US';
        NewUser.LastName = '12101986';
        NewUser.LanguageLocaleKey = 'en_US';
        NewUser.EmailEncodingKey = 'ISO-8859-1';
        NewUser.Alias = '12101986';
        
        insert NewUser;
        return NewUser;
    } 
    
    public static Contract_Request__c insertContReq(String AcctId)
    {
        Contract_Request__c newConReq = new Contract_Request__c();
        newConReq.Account__c = AcctID;
        newConReq.No_Approvals_Required__c = true;
        insert newConReq;
        return newConReq;
    }
    
    /*public static SIGN_Agreement__c insertSignedAgree(String AcctID,String contId)
    {
        SIGN_Agreement__c newAgreement = new SIGN_Agreement__c();
        newAgreement.Account__c = AcctId;
        //newAgreement.Recipient__c = contId;
        insert newAgreement;
        return newAgreement;
    }*/
    
}