@isTest(SeeAllData = true)
public class TestUpdateCYO 
{
/***************************************************************************************************************
Date: 01/19/2009
Author: Divya Hegde, Salesforce.com Consultant
        Tata Consultancy Services Limited

Purpose: Test Method to validate the functionality of Trigger "UpdateCYO" on Current Year Objective.
**************************************************************************************************************************************************************/
 static testMethod void testTriggerCYO()
  {
   Strategic_Account_Profile__c  NewSAP=  new  Strategic_Account_Profile__c();
   Account acc=[select id from account limit 1];
   NewSAP.Account__c =acc.id ;
  NewSAP.Last_Modified_Current_Year_Objective__c =datetime.valueOf('2008-12-03 13:52:00');
  NewSAP.Last_Modified_CSF__c=datetime.valueOf('2008-12-03 13:52:00');
  NewSAP.Last_Modified_Date_Time__c=datetime.valueOf('2008-12-03 13:51:00');
   insert NewSAP;
   Current_Year_Objective__c CYOnew =new Current_Year_Objective__c();
   CYOnew .Strategic_Account_Profile__c = NewSAP.Id;
   CYOnew .Objective__c='test1234';
   insert CYOnew ;
  }
  static testMethod void UpdateCYO()
  {
   Strategic_Account_Profile__c  NewSAP=  new  Strategic_Account_Profile__c();
   Account acc=[select id from account limit 1];
   NewSAP.Account__c =acc.id ;
   insert NewSAP;
  Current_Year_Objective__c CYOnew =new Current_Year_Objective__c();
   CYOnew .Strategic_Account_Profile__c = NewSAP.Id;
   CYOnew .Objective__c='test1234';
   insert CYOnew ;
   update NewSAP;
  }
}