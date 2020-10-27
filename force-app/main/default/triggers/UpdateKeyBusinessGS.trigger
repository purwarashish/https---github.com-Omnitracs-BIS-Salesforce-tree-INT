trigger UpdateKeyBusinessGS on Key_Business_Goal_and_Strategy__c(after insert,after update) {
for(Key_Business_Goal_and_Strategy__c KBGS:trigger.new)
{
if(KBGS.Strategic_Account_Profile__c != null)
       {
        Strategic_Account_Profile__c SAP = [Select Last_Mod_Key_Business_Goals_and_Strategy__c,Last_Modified_Date_Time__c from Strategic_Account_Profile__c where Id=:KBGS.Strategic_Account_Profile__c Limit 1];
        SAP.Last_Mod_Key_Business_Goals_and_Strategy__c  = Datetime.Valueof(System.now());
        If (SAP.Last_Modified_Date_Time__c !=null) 
       {
           if((SAP.Last_Modified_Date_Time__c < SAP.Last_Mod_Key_Business_Goals_and_Strategy__c))
           {
               SAP.Last_Modified_Date_Time__c = SAP.Last_Mod_Key_Business_Goals_and_Strategy__c;
           }
       }
       else
       {
           SAP.Last_Modified_Date_Time__c = SAP.Last_Mod_Key_Business_Goals_and_Strategy__c;
       }

        update SAP;

       }

}
}