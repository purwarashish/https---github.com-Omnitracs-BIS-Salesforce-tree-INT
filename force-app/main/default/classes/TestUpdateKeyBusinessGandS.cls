@isTest(SeeAllData = true)
public class TestUpdateKeyBusinessGandS 
{
/***************************************************************************************************************
Date: 01/19/2009
Author: Divya Hegde, Salesforce.com Consultant
        Tata Consultancy Services Limited

Purpose: Test Method to validate the functionality of Trigger "UpdateKeyBusinessGS" on Key Business Goals and Strategies.
*******************************************************************************************************************************************/
 static testMethod void testTrigger()
  {
   Strategic_Account_Profile__c  NewSAP=  new  Strategic_Account_Profile__c();
   Account acc = GenericTestClass.insertAccount();
   
   NewSAP.Account__c =acc.id ;
   NewSAP.Last_Mod_Key_Business_Goals_and_Strategy__c =datetime.valueOf('2008-12-02 13:52:00');
   NewSAP.Last_Modified_CSF__c=datetime.valueOf('2008-12-03 13:52:00');
   NewSAP.Last_Modified_Date_Time__c=datetime.valueOf('2008-12-03 13:51:00');
   insert NewSAP;
   Key_Business_Goal_and_Strategy__c KeyGSnew =new Key_Business_Goal_and_Strategy__c();
   KeyGSnew .Strategic_Account_Profile__c = NewSAP.Id;
   KeyGSnew .Goal__c='test1234';
   insert KeyGSnew ;
  }
  static testMethod void UpdateKeyBusinessGS()
  {
   Strategic_Account_Profile__c  NewSAP=  new  Strategic_Account_Profile__c();
   Account acc = GenericTestClass.insertAccount();
   
   NewSAP.Account__c =acc.id ;
   insert NewSAP;
   Key_Business_Goal_and_Strategy__c KeyGSnew =new Key_Business_Goal_and_Strategy__c();
   KeyGSnew .Strategic_Account_Profile__c = NewSAP.Id;
   KeyGSnew .Goal__c='test1234';
   insert KeyGSnew ;
   update NewSAP;
  }
}