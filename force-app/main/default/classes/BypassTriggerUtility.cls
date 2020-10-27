public with sharing class BypassTriggerUtility {
/* BypassTriggerUtility class

  Check custom setting for disable trigger flag for user 'System Admin - Data'.  
  If the isDisabled flag is checked,  the trigger logic will be 
  bypass.  (The trigger modules will reference this utiliity to optain the flag).  
  The flag is to be turn on when the Data Admin user needs to do mass upload and wants    
  to bypass the trigger.

*/
    public Boolean isDisabled;
    
    public BypassTriggerUtility () {

        ByPassTrigger__c bt = ByPassTrigger__c.getInstance();
        Boolean result = bt.isDisabled__c; 
        this.isDisabled = result;

    }
  
    public Boolean isTriggerBypassed() { 

        System.debug ('--> UserName is: ' + UserInfo.getName());
        System.debug ('--> UserId is: ' + UserInfo.getUserId());
        System.debug ('--> bt.isDisabled__c is : ' + isDisabled);
        if (this.isDisabled || UserInfo.getUserId() == label.S2S_User_Id)
            return true;
        else
            return false;
    }
}