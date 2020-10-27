@isTest(SeeAllData = true)
public class TestUpdateCSF
{
/***************************************************************************************************************
Date: 01/19/2009
Author: Divya Hegde, Salesforce.com Consultant
        Tata Consultancy Services Limited

Purpose: Test Method to validate the functionality of Trigger "UpdateCSF" on Critical Success Factor.
**************************************************************************************************************************************************************/
 static testMethod void testTriggerCSF()
  {
   Strategic_Account_Profile__c  NewSAP=  new  Strategic_Account_Profile__c();
   Account acc = GenericTestClass.insertAccount();
   
   NewSAP.Account__c =acc.id ;
   NewSAP.Last_Modified_Business_Plan__c =datetime.valueOf('2008-12-04 13:52:00');
   NewSAP.Last_Modified_CSF__c=datetime.valueOf('2008-12-05 13:52:00');
    NewSAP.Last_Modified_Date_Time__c=datetime.valueOf('2008-12-03 13:51:00');
   insert NewSAP;
   Critical_Success_Factor__c CSFnew =new Critical_Success_Factor__c();
   CSFnew .Strategic_Account_Profile__c = NewSAP.Id;
   CSFnew .CSF__c='test123';
   insert CSFnew ;
  }
  static testMethod void UpdateBP()
  {
   Strategic_Account_Profile__c  NewSAP=  new  Strategic_Account_Profile__c();
   Account acc = GenericTestClass.insertAccount();
   
   NewSAP.Account__c =acc.id ;
   insert NewSAP;
   Critical_Success_Factor__c CSFnew =new Critical_Success_Factor__c();
   CSFnew .Strategic_Account_Profile__c = NewSAP.Id;
    CSFnew .CSF__c='test123';
   insert CSFnew ;
   update NewSAP;
  }
}