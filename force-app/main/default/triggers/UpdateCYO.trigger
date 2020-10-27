trigger UpdateCYO on Current_Year_Objective__c (after insert,after update) {
for(Current_Year_Objective__c CYO:Trigger.new)
{
  if(CYO.Strategic_Account_Profile__c != null)
    {
      Strategic_Account_Profile__c SAP = [Select Last_Modified_Current_Year_Objective__c,Last_Modified_Date_Time__c from Strategic_Account_Profile__c where Id=:CYO.Strategic_Account_Profile__c Limit 1];
      SAP.Last_Modified_Current_Year_Objective__c  = Datetime.Valueof(System.now());
      If (SAP.Last_Modified_Date_Time__c !=null) 
       {
           if((SAP.Last_Modified_Date_Time__c < SAP.Last_Modified_Current_Year_Objective__c))
           {
               SAP.Last_Modified_Date_Time__c = SAP.Last_Modified_Current_Year_Objective__c;
           }
       }
       else
       {
           SAP.Last_Modified_Date_Time__c = SAP.Last_Modified_Current_Year_Objective__c;
       }

        update SAP;
    
    }
}
}