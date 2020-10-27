/**
 * Class: QES_NCIS_SendEmail
 *
 * Copyright (C) 2012 EDL Consulting
 *
 * Purpose: 
 * This apex class updates the email timestamp on the record. 
 *
 *
 * Change History:
 *
 * Developer                     Date        Flag    Description
 * -----------------------------------------------------------------------
 * Prakash Ramaswamy          08/02/2012   <ID>   Initial development
 *
 */
public with sharing class QES_NCIS_SendEmail {
   
   private Customer_Information_Sheet__c cisInstance;
   
   public boolean simualteDBError;
   
   public QES_NCIS_SendEmail(Apexpages.standardcontroller cisCtrl){
      cisInstance=(Customer_Information_Sheet__c)cisCtrl.getRecord();
   }
   
   public PageReference updateEmailFields(){
     try{
         cisInstance.Trigger_Email__c=true;
         if(Test.isRunningTest()&& simualteDBError!=null && simualteDBError){
              String nullStr=null;
              Boolean test=nullStr.contains('Test');
         }
         update cisInstance;
         return new PageReference('/' + cisInstance.Id);
     }
     
     catch(Exception e){
        cisInstance.Trigger_Email__c=false;
        cisInstance.Email_Status__c='Exception';
        update cisInstance;
        return new PageReference('/' + cisInstance.Id);
     }
   }
   
}