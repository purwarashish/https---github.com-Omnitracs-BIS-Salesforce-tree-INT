@isTest(SeeAllData = true)
public class TestUpdateBP 
{
/***************************************************************************************************************
Date: 01/19/2009
Author: Divya Hegde, Salesforce.com Consultant
        Tata Consultancy Services Limited

Purpose: Test Method to validate the functionality of Trigger "UpdateBP" on Strategic Account Profile.
**************************************************************************************************************************************************************/
static testMethod void testTrigger()
{
    Strategic_Account_Profile__c  NewSAP=  new  Strategic_Account_Profile__c();
    Account newAccount = new Account();         
        newAccount.Name = 'SFDC';         
        newAccount.Type = 'Other';         
        newAccount.BillingStreet = 'Test Address';         
        newAccount.BillingCity = 'Test City';         
        newAccount.BillingCountry = 'Test Country';         
        newAccount.QWBS_Cust_ID__c = '4567';        
        
    insert newAccount;
    NewSAP.Account__c =newAccount.id ;
    NewSAP.Last_Modified_Business_Plan__c =datetime.valueOf('2008-12-02 13:52:00');
    NewSAP.Last_Modified_CSF__c=datetime.valueOf('2008-12-03 13:52:00');
    NewSAP.Last_Modified_Date_Time__c=datetime.valueOf('2008-12-03 13:51:00');
    
    insert NewSAP;
   
    Business_Plan__c BPnew =new Business_Plan__c();
    BPnew.Strategic_Account_Profile__c = NewSAP.Id;
    BPnew.Goal__c='test1234';
   
    insert BPnew ;
}
  static testMethod void UpdateBP()
  {
   Strategic_Account_Profile__c  NewSAP=  new  Strategic_Account_Profile__c();
    Account newAccount = new Account();         
        newAccount.Name = 'SFDC';         
        newAccount.Type = 'Other';         
        newAccount.BillingStreet = 'Test Address';         
        newAccount.BillingCity = 'Test City';         
        newAccount.BillingCountry = 'Test Country';         
        newAccount.QWBS_Cust_ID__c = '4567'; 
   
   insert newAccount;
   
   NewSAP.Account__c =newAccount.id ;
   insert NewSAP;
   Business_Plan__c BPnew =new Business_Plan__c();
   BPnew.Strategic_Account_Profile__c = NewSAP.Id;
   BPnew.Goal__c='test1234';
   insert BPnew;
   update NewSAP;
  }
}