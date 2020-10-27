@isTest(SeeAllData = true)
public class TestUpdateSWOT 
{
/***************************************************************************************************************
Date: 01/19/2009
Author: Divya Hegde, Salesforce.com Consultant
        Tata Consultancy Services Limited

Purpose: Test Method to validate the functionality of Trigger "UpdateSWOT" on SWOT Analysis.
**************************************************************************************************************************************************************/
 static testMethod void testTriggerSWOT()
  {
   Strategic_Account_Profile__c  NewSAP=  new  Strategic_Account_Profile__c();
   Account acc = GenericTestClass.insertAccount();
   
   NewSAP.Account__c =acc.id ;
   NewSAP.Last_Modified_SWOT__c =datetime.valueOf('2008-12-02 13:52:00');
   NewSAP.Last_Modified_CSF__c=datetime.valueOf('2008-12-03 13:52:00');
   NewSAP.Last_Modified_Date_Time__c=datetime.valueOf('2008-12-03 13:51:00');
   insert NewSAP;
   SWOT_Analysis__c SWOTnew =new SWOT_Analysis__c();
   SWOTnew .Strategic_Account_Profile__c = NewSAP.Id;
   SWOTnew .Comments__c='test1234';
   insert SWOTnew ;
  }
  static testMethod void UpdateSWOT()
  {
   Strategic_Account_Profile__c  NewSAP=  new  Strategic_Account_Profile__c();
   Account acc = GenericTestClass.insertAccount();
   
   NewSAP.Account__c =acc.id ;
   insert NewSAP;
   SWOT_Analysis__c SWOTnew =new SWOT_Analysis__c();
   SWOTnew .Strategic_Account_Profile__c = NewSAP.Id;
   SWOTnew .Comments__c='test1234';
   insert SWOTnew ;
   update NewSAP;
  }
}