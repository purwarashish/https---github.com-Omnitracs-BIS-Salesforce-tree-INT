@isTest
public class CaseTestData 
{
    List<User> lstUser; // Users required for testing Purpose.
    List<Account> lstAccount; //List of Account being created as per the count.
    List<Contact> lstContact; //List of Contacts being created as per the count.
    List<Case> lstCase; //List of Cases being created as per the count.
    List<NMC_Account__c> lstNMCAccount;
    
    //Search Rercord Type id based on its name
    Private ID SearchRecordTypeID(String RecordTypeLabel,String SObjName)
    {  
        if(SObjName == 'Account')
        {
            return Schema.Sobjecttype.Account.getRecordTypeInfosByName().get(RecordTypeLabel).getRecordTypeId();
        }
        else if(SObjName == 'Contact')
        {
            return Schema.Sobjecttype.Contact.getRecordTypeInfosByName().get(RecordTypeLabel).getRecordTypeId();
        }
        else if(SObjName == 'Case')
        {
            return Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(RecordTypeLabel).getRecordTypeId();
        }
        else
        {
            return null;
        }
    }
    
    //User Creation
    Public List<User> CreateUser(String Criteria, id IdProfile, String UserName, id IdContact, Integer userCount)
    {   
        lstuser = new List<User>();
        for(Integer i=0; i<userCount; i++)
        {
            User singleUser = new User();
            singleUser.email = UserName+i+'@testmail.com';
            singleUser.emailencodingkey = 'UTF-8';
            singleUser.lastname = UserName+i;
            singleUser.firstname = UserName+i;
            singleUser.languagelocalekey = 'en_US';
            singleUser.localesidkey='en_US';
            singleUser.timezonesidkey = 'America/Denver';
            singleUser.username = UserName+i+'@test.com';
            singleUser.alias=UserName.substring(7)+i;
            singleUser.ProfileId=IdProfile;
            if(criteria == 'guessWorkEffort')
            {
                if(i == 0)
                    singleUser.IsActive = true;//Active user
                if(i == 1)
                    singleUser.IsActive = false;//Inactive user
            }
            if(IdContact!=null)
            {
                singleUser.ContactId = IdContact;
            }
            if(Criteria=='BURoadnet')
            {
                singleUser.Business_Unit__c='Roadnet';
            }
            //if(Criteria=='ShareCase')
            //{
                //singleUser.ContactId=IdContact;
            //}
            lstuser.add(singleUser);
        }
        return lstuser;
    }
    
    //Account Creation
    Public List<Account> CreateAcccount(String Criteria, List<user> lstUser, Integer AccountCount,List<Account> accountList)
    {   
        lstAccount = new List<Account>();
        Account objAccount;
        for(Integer i=0; i<AccountCount; i++) 
        {
            objAccount = new Account();
            objAccount.RecordTypeId=SearchRecordTypeID('T&L Sales Accounts','Account');
            objAccount.Name='TestAccount'+i;
            objAccount.Phone='324324324'+i;
            //objAccount.District__c='Strategic';
            objAccount.BillingStreet='Test Billing Street'+i;
            objAccount.BillingCity='Test Billing City'+i;
            objAccount.BillingCountry='Test Billing Country'+i;
            objAccount.BillingPostalcode = '75060'+i;
            objAccount.BillingState = 'TX';
            objAccount.Fleet_Size__c = 250;
            objAccount.Segment__c =  'TL';
            objAccount.ShippingCountry='Test Shipping Country'+i;
            objAccount.Primary_Business_Unit__c='Omnitracs Domestic';
            objAccount.Account_Status__c='Active';
            objAccount.Account_Classification__c='Prospect';
            if(Criteria == 'ShareCase')
            {
                objAccount.VAR_Account1__c=accountList.get(0).id;    
            }
            if(Criteria == 'AssignmentOfCases')
            {
                objAccount.CSR__c=lstUser.get(0).id;
                objAccount.Inside_CSR__c=lstUser.get(0).id;
                objAccount.Account_Manager__c=lstUser.get(0).id;
             // objAccount.ServiceSource_Rep__c=lstUser.get(0).id;
                objAccount.QWBS_Cust_ID__c='4321';
                if(i==1)
                {
                    objAccount.CSR__c=null;
                    objAccount.Inside_CSR__c=lstUser.get(1).id;
                    objAccount.Account_Manager__c=lstUser.get(1).id;
              //    objAccount.ServiceSource_Rep__c=lstUser.get(1).id;
                    objAccount.QWBS_Cust_ID__c='432101';
                }
            }
            if(Criteria == 'SendEmail')
            {
                if(i == 0)
                    objAccount.Email_Alert_All_Cases__c=true;
                if(i == 1)
                    objAccount.Email_Alert_Support__c=lstUser.get(0).lastname+', '+lstUser.get(0).firstname;
            }        
            lstAccount.add(objAccount);
        }
        return lstAccount;
    }
    
    //Contact Creation
    Public List<Contact> CreateContact(String Criteria, Integer ContactCount, Id objAccountId)
    {
        Contact objContact;
        lstContact = new List<Contact>();
        for(Integer i=0;i<ContactCount;i++)
        {
            objContact= new Contact();
            objContact.AccountId=objAccountId;
            objContact.RecordTypeId=SearchRecordTypeID('Sales','Contact');
            objContact.FirstName='TestFname'+i;
            objContact.LastName='TestContact'+i;
            objContact.Title='TestTitle'+i;
            objContact.Decision_Maker_Influencer__c='Yes';        
            objContact.LeadSource='800#';
            objContact.Lead_Origin__c='XRS';
            objContact.Email = 'testemail@email.com';
            lstContact.add(objContact);
            if(Criteria == 'ShareCase')
            {
                objContact.inactive__c=false;
            }
        }
        return lstContact;
    }
    
    //Case Creation
    Public List<Case> CreateCase(String criteria,  String recordTypeName, List<Account> lstAccount, List<Contact> lstContact, 
                                 List<user> lstUser, Integer caseCount)
    {
        Case objCase;
        lstCase = new List<Case>();
        for(Integer i=0;i<caseCount;i++)
        {
            objCase= new Case();
            objCase.RecordTypeId = SearchRecordTypeID(recordTypeName,'Case');
            objCase.AccountId = lstAccount.get(0).id;
            objCase.ContactId = lstContact.get(0).id;
            objCase.Work_Effort_In_Minutes__c = 10;
            objCase.Business_Unit__c = 'Roadnet';
            objCase.Origin = 'Email';
            objCase.Status = 'Open';
            objCase.Substatus__c = 'In Progress';
            objCase.Priority = '3-Low';
            objCase.Subject = 'Test Case Subject';
            objCase.Resolution__c = 'Test';
            objCase.Queue__c = 'Field CS';
            if(criteria == 'TIS')
            {
                
                objCase.Functional_Group__c='Channel Support';
                objCase.Description='Test';
                objCase.OwnerId=lstuser.get(0).id;
            }
             if(criteria == 'TISClosed')
            {
                objCase.Status = 'Closed';
                objCase.Functional_Group__c='Channel Support';
                objCase.Description='Test';
                objCase.OwnerId=lstuser.get(0).id;
            }
            if(criteria == 'AssignmentOfCases')
            {
                
                objCase.AccountId = lstAccount.get(0).id;
                objCase.Origin='Email-iQ OV Requests';
                objCase.subject= 'evaluation expired';
                objCase.Customer_Service_Rep__c = lstuser.get(0).id;
                objCase.Inside_CSR__c = lstuser.get(0).id;
            }
            if(criteria == 'AssignmentOfCases1')
            {
                objCase.AccountId = lstAccount.get(1).id;
                objCase.Origin='Email-iQ OV Requests';
                objCase.Sprint__c=',startDate.*?name=';
                objCase.subject= 'evaluation expired';
            }
            if(criteria == 'guessWorkEffort')
            {                             
                if(i == 0)
                    objCase.Last_Modified_Date_Time__c = 'Modified Date time';//setting 'Last Modified Date Time' with some junk data
                if(i == 1)
                    objCase.Assisting_techs__c = lstUser.get(0).lastname+', '+lstUser.get(0).firstname;//Active user
                if(i == 2)
                    objCase.Assisting_techs__c = lstUser.get(1).lastname+', '+lstUser.get(1).firstname;//Inactive user
                if(i == 3)
                    objCase.Assisting_techs__c = lstUser.get(0).lastname+', '+lstUser.get(0).firstname+';'+lstUser.get(1).lastname+', '+lstUser.get(1).firstname;//both Active & Inactive user
                if(i == 4)
                {
                    // the isvisibiliinselfservice portal flag should be false for all prof services cases
                    objCase.RecordTypeId = SearchRecordTypeID('Professional Services','Case');
                    objCase.IsVisibleInSelfService = true;
                }    
            }
            if(criteria == 'SendEmail')
            {
                if(i == 1)
                {
                    objCase.AccountId = null;
                    objCase.ContactId = null;
                    objCase.email_alert_support__c = lstUser.get(0).lastname+', '+lstUser.get(0).firstname;
                }
                if(i == 2)
                {
                    objCase.AccountId = lstAccount.get(1).id;
                    objCase.ContactId = null;
                    objCase.email_alert_support__c = lstUser.get(0).lastname+', '+lstUser.get(0).firstname;
                }
            }
            if(criteria == 'setOwnerEngCase')
            {
                if(i == 1 || i == 3 || i ==5)
                {
                    objCase.RecordTypeId = SearchRecordTypeID('Call Center','Case');//Call Center record type
                }    

            }
            if(criteria == 'populateJiraFields')
            {
                if(i == 0)
                {
                    objCase.JIRA_Status__c = 'Closed';
                    objCase.JIRA_Issue__c = '012345678912345';
                    objCase.Jira_Tracking__c = '012345678912345';
                    objCase.Jira_Priority__c = 'Low';
                    objCase.status = 'Closed';
                    objCase.Self_Close_Reason__c = 'Unit Testing';
                }
                if(i == 2)
                {
                    objCase.RecordTypeId = SearchRecordTypeID('Call Center','Case');//Call Center record type
                }    
            }
                
            lstCase.add(objCase);
        }
        return lstCase;
    }
    
    //Set value in Send Trigger Email Alerts  custom setting
    Public Send_Trigger_Email_Alerts__c sendTriggerEmailAlert()
    {       
        Send_Trigger_Email_Alerts__c sendEmailAlert = Send_Trigger_Email_Alerts__c.getinstance('Roadnet');
        sendEmailAlert.isDisabled__c = false;
        return sendEmailAlert;
    }
    
    public List<NMC_Account__c> createNMCAccount(List<Account> lstAccount, Integer count)
    {
        lstNMCAccount = new List<NMC_Account__c>();
        for(integer i=0; i<count; i++)
        {
            NMC_Account__c NMCAccount = new NMC_Account__c();
            NMCAccount.Account__c = lstAccount.get(i).id;
            NMCAccount.NMC_Account__c = '12345'+i;
            NMCAccount.NMC_Account_Name__c = 'Unit Test';
            NMCAccount.NMC_Aux_ID__c = '12345'+i;
            NMCAccount.Default_NMC_Account_for_Unit_Type__c = 'MCP50';
            NMCAccount.Retention_Period__c = '2 days';
            lstNMCAccount.add(NMCAccount);
        }
        return lstNMCAccount;
    }       
}