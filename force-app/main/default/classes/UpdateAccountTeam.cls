global class UpdateAccountTeam {

    private static boolean alreadyExecuted = false;
    public static boolean isExecuteAccountTeam = true;
    public static boolean hasAlreadyExecuted() 
    {
          return alreadyExecuted;
    }
        
    public static void setAlreadyExecuted() 
    {
          alreadyExecuted = true;
    }
      
    static final string ROWCAUSE = 'Manual';
    static final string APEXROLE = 'Apex Role';
    public static final String APEXROLE_OWNER = 'Account Owner APEX';
    public static final String APEXROLE_RECORDOWNER = 'Partner Owner APEX';
    public static final String APEXROLE_ACCTMGR = 'Account Manager APEX';
    public static final String APEXROLE_CSR = 'Customer Service Rep APEX';
    public static final String APEXROLE_PSREP = 'Professional Services Rep APEX';
    public static final String APEXROLE_SAE = 'Software Application Eng APEX';
    public static final String APEXROLE_CONTRACTADMIN = 'Contract Admin APEX';
    public static final String APEXROLE_INSIDESALESREP = 'Inside Sales Rep APEX';
    public static final String APEXROLE_ARREP = 'Accounts Receivable Rep APEX';
    public static final String APEXROLE_PAGENT = 'Partner Agent Rep APEX';
    //Added by Shruti Karn for CR# 19651    
    public static final String APEXROLE_INSIDECSR = 'Inside CSR APEX';
    //DAR - 17May2011 - CR 35708
    public static final String APEXROLE_FRAACCOUNTMANAGER  = 'FRA Account Manager APEX';
    public static final String APEXROLE_FRACUSTOMERSERVICEREP  = 'FRA Customer Service Rep APEX';
    public static final String APEXROLE_FRACONTRACTSADMINISTRATOR  = 'FRA Contracts Administrator APEX';
    public static final String APEXROLE_FRASOFTWAREAPPLICATIONENG  = 'FRA Software Application Eng APEX';
   
    static List<String> apexRoles = new List<String>();
   
      
    @future    
    public static void UpdateAccountTeam(String userName,list<id> lstAccountId)
    {
        list<Account> lstAccount = [select OwnerId,
                                        RecordOwner__c,
                                        Account_Manager__c,
                                        CSR__c,
                                        /*Professional_Services_Rep__c,
                                        Software_Application_Eng__c,*/
                                        Contracts_Administrator__c,
                                        Inside_Sales_Rep__c,
                                        AR_Representative__c,
                                        Partner_Agent__c,
                                        Inside_CSR__c,
                                        FRA_Account_Manager__c,
                                        FRA_Customer_Service_Rep__c,
                                        /*FRA_Contracts_Administrator__c,*/
                                        FRA_Software_Application_Eng__c  
                                        from account where id in :lstAccountId
                                        limit :lstAccountId.size() ];
     //if ((!UpdateAccountTeam.hasAlreadyExecuted()) || (isExecuteAccountTeam != true))
     //   {
     //       UpdateAccountTeam.setAlreadyExecuted();   
            for(Account account:lstAccount)
            {
                Map<String, String> userIDMap = new Map<String, String>();
                if (account.OwnerId!= null)
                {
                    userIDMap.put(account.OwnerId, UpdateAccountTeam.APEXROLE_OWNER);
                }
                if (account.RecordOwner__c!= null)
                {
                    userIDMap.put(account.RecordOwner__c, UpdateAccountTeam.APEXROLE_RECORDOWNER);
                }
                if (account.Account_Manager__c!= null)
                {
                    userIDMap.put(account.Account_Manager__c, UpdateAccountTeam.APEXROLE_ACCTMGR);
                }
                if (account.CSR__c != null)
                {
                    userIDMap.put(account.CSR__c, UpdateAccountTeam.APEXROLE_CSR);
                }
                /*if (account.Professional_Services_Rep__c != null)
                {
                    userIDMap.put(account.Professional_Services_Rep__c, UpdateAccountTeam.APEXROLE_PSREP);
                }
                if (account.Software_Application_Eng__c != null)
                 {
                     userIDMap.put(account.Software_Application_Eng__c, UpdateAccountTeam.APEXROLE_SAE);
                 }*/
                if (account.Contracts_Administrator__c != null)
                {
                     userIDMap.put(account.Contracts_Administrator__c, UpdateAccountTeam.APEXROLE_CONTRACTADMIN);
                }
                if (account.Inside_Sales_Rep__c != null)
                {
                     userIDMap.put(account.Inside_Sales_Rep__c,  UpdateAccountTeam.APEXROLE_INSIDESALESREP);
                }
                if (account.AR_Representative__c != null)
                {
                     userIDMap.put(account.AR_Representative__c, UpdateAccountTeam.APEXROLE_ARREP);
                }
                if (account.Partner_Agent__c!= null)
                {
                    system.debug('@@@@@@@@@@@@@@@@@@@Partner Agent'+account.Partner_Agent__c);
                    userIDMap.put(account.Partner_Agent__c, UpdateAccountTeam.APEXROLE_PAGENT);
                }
            
                //Added By Shruti Karn for CR#19651
                if (account.Inside_CSR__c!= null)        
                {                   
                    userIDMap.put(account.Inside_CSR__c, UpdateAccountTeam.APEXROLE_INSIDECSR);                    
                }
        
               //DAR - 17May2011 - CR 35708
                if (account.FRA_Account_Manager__c!= null)        
                {                     
                    userIDMap.put(account.FRA_Account_Manager__c, UpdateAccountTeam.APEXROLE_FRAACCOUNTMANAGER);                    
                }
                //DAR - 17May2011 - CR 35708
                if (account.FRA_Customer_Service_Rep__c!= null)        
                {                     
                    userIDMap.put(account.FRA_Customer_Service_Rep__c, UpdateAccountTeam.APEXROLE_FRACUSTOMERSERVICEREP);                    
                }
                //DAR - 17May2011 - CR 35708
                /*if (account.FRA_Contracts_Administrator__c!= null)        
                {                     
                    userIDMap.put(account.FRA_Contracts_Administrator__c, UpdateAccountTeam.APEXROLE_FRACONTRACTSADMINISTRATOR);                    
                }*/
                //DAR - 17May2011 - CR 35708
                if (account.FRA_Software_Application_Eng__c!= null)        
                {                     
                    userIDMap.put(account.FRA_Software_Application_Eng__c, UpdateAccountTeam.APEXROLE_FRASOFTWAREAPPLICATIONENG);                    
                }
                if(userIDMap.size()>0)
                {
                    UpdateAccountTeamRecord(userIDMap,account.id,account.ownerid);
                }    
            
            }// end forloop
        
      //  }//end if
    
    }

    public static void UpdateAccountTeamRecord(Map<String, String> userIDMap,String AccountId, string AccountOwnerID)
    {
      apexRoles.add(APEXROLE);
      apexRoles.add(APEXROLE_OWNER);
      apexRoles.add(APEXROLE_RECORDOWNER);
      apexRoles.add(APEXROLE_ACCTMGR);
      apexRoles.add(APEXROLE_CSR);
      apexRoles.add(APEXROLE_PSREP);
      apexRoles.add(APEXROLE_SAE);
      apexRoles.add(APEXROLE_CONTRACTADMIN);
      apexRoles.add(APEXROLE_INSIDESALESREP);
      apexRoles.add(APEXROLE_ARREP);
      //Added for Partner Agent
      apexRoles.add(APEXROLE_PAGENT);
      //Added by Shruti Karn for CR# 19651       
      apexRoles.add(APEXROLE_INSIDECSR);
      //DAR - 17May2011 - CR 35708
      apexRoles.add(APEXROLE_FRAACCOUNTMANAGER);
      apexRoles.add(APEXROLE_FRACUSTOMERSERVICEREP);
      apexRoles.add(APEXROLE_FRACONTRACTSADMINISTRATOR);
      apexRoles.add(APEXROLE_FRASOFTWAREAPPLICATIONENG);
             
      //Delete existing 'Apex' Account Team Members.  Note that this will cascade delete the Account Shares
     AccountTeamMember[] actDelTeamMember = [Select Id from AccountTeamMember where Account.ID = :AccountId AND TeamMemberRole in :apexRoles];
      if(!actDelTeamMember.isEmpty()) {
        delete actDelTeamMember;
      }

      //Create a Map of the AccountShare records that we want to programatically insert
    
      Map<Id, AccountShare> acctShareMap = new Map<Id, AccountShare>();
      AccountTeamMember[] actTeamMembers = new AccountTeamMember[0];
      /*
      for(Id userRecId: userIDMap.keySet())
      {
        AccountTeamMember actTeamMember = new AccountTeamMember();
        actTeamMember.AccountAccessLevel = 'Edit';
        actTeamMember.AccountID = AccountId;
        actTeamMember.TeamMemberRole = userIDMap.get(userRecId);
        actTeamMember.UserId = userRecId;
        actTeamMembers.Add(actTeamMember);

        //Adding owner to the Account Share causes DML violation

        if(AccountOwnerID != userRecId && actTeamMember.TeamMemberRole != 'Partner Agent Rep APEX') {
          AccountShare actShare = new AccountShare();
          actShare.AccountId = AccountId;
          actShare.AccountAccessLevel = 'Edit';
          actShare.CaseAccessLevel = 'Edit';
          actShare.OpportunityAccessLevel = 'Edit';
          actShare.ContactAccessLevel = 'Edit';  //adding Contacts KD 10/11/08.
        //actShare.RowCause = ROWCAUSE;  //non-editable as of Spring '08; T.Scott
          actShare.UserOrGroupId = userRecId;
          acctShareMap.put(userRecId, actShare);
        }
        //TeamMemberRole condition added for Partner Agent Rep
        else if(AccountOwnerID != userRecId && actTeamMember.TeamMemberRole == 'Partner Agent Rep APEX')
        {
          AccountShare actShare = new AccountShare();
          actShare.AccountId = AccountId;
          actShare.AccountAccessLevel = 'Edit';
          actShare.CaseAccessLevel = 'None';
          actShare.OpportunityAccessLevel = 'None';
          actShare.ContactAccessLevel = 'Edit';
          actShare.UserOrGroupId = userRecId;
          acctShareMap.put(userRecId, actShare);
        }
      }
      
      
      */   
      
      AccountShare partnerAgentAccShare;
      for(User userRec: [select id,name from User where id in :userIDMap.keySet() and IsActive = true limit 1000])
      {

        AccountTeamMember actTeamMember = new AccountTeamMember();
        actTeamMember.AccountAccessLevel = 'Edit';
        actTeamMember.AccountID = AccountId;
        actTeamMember.TeamMemberRole = userIDMap.get(userRec.Id);
        actTeamMember.UserId = userRec.Id;
        actTeamMembers.Add(actTeamMember);

        //Adding owner to the Account Share causes DML violation
        
        System.debug('********************** user id : ' + userRec.Id );
        System.debug('********************** user name : ' + userRec.name );
        System.debug('********************** AccountOwnerID : ' + AccountOwnerID );

        if(AccountOwnerID != userRec.Id && actTeamMember.TeamMemberRole != UpdateAccountTeam.APEXROLE_PAGENT) {
          AccountShare actShare = new AccountShare();
          actShare.AccountId = AccountId;
          actShare.AccountAccessLevel = 'Edit';
          actShare.CaseAccessLevel = 'Edit';
          actShare.OpportunityAccessLevel = 'Edit';
          actShare.ContactAccessLevel = 'Edit';  //adding Contacts KD 10/11/08.
        //actShare.RowCause = ROWCAUSE;  //non-editable as of Spring '08; T.Scott
          actShare.UserOrGroupId = userRec.Id;
          acctShareMap.put(userRec.Id, actShare);
        }
        //TeamMemberRole condition added for Partner Agent Rep
        else if(actTeamMember.TeamMemberRole == UpdateAccountTeam.APEXROLE_PAGENT)
        {
          partnerAgentAccShare = new AccountShare();
          partnerAgentAccShare.AccountId = AccountId;
          partnerAgentAccShare.AccountAccessLevel = 'Edit';
          partnerAgentAccShare.CaseAccessLevel = 'None';
          partnerAgentAccShare.OpportunityAccessLevel = 'Read';
          partnerAgentAccShare.ContactAccessLevel = 'Edit';
          partnerAgentAccShare.UserOrGroupId = userRec.Id;
          //acctShareMap.put(userRec.Id, actShare);
          
        }
      }
      

      //Insert 'Apex' Account Team Members
      if(!actTeamMembers.isEmpty()) {
        system.debug('@@@@@@@@@@actTeamMembers'+actTeamMembers);  
        Insert actTeamMembers;
      }

      //Insert AccountShare records for the 'Apex' Account Team Members
      if(!acctShareMap.isEmpty()) {
      	 system.debug('@@@@@@@@@@acctShareMap'+acctShareMap);  
        Insert acctShareMap.values();
      }
      if(partnerAgentAccShare != null)
      {
      	try{
          insert partnerAgentAccShare;
          }
          catch(exception e)
          {
          	System.debug('*************** Exception e : ' + e.getMessage());
          }
      }
  } 
}