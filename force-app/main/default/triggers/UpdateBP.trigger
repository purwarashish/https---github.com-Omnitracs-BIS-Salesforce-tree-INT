trigger UpdateBP on Business_Plan__c (after insert,after update) {
for(Business_Plan__c BP:Trigger.new)
{
if(BP.Strategic_Account_Profile__c != null)
    {
        Strategic_Account_Profile__c SAP = [Select Last_Modified_Business_Plan__c, Last_Modified_Date_Time__c from Strategic_Account_Profile__c where Id=:BP.Strategic_Account_Profile__c Limit 1];
       SAP.Last_Modified_Business_Plan__c  = Datetime.Valueof(System.now());
       If (SAP.Last_Modified_Date_Time__c !=null) 
       {
           if((SAP.Last_Modified_Date_Time__c < SAP.Last_Modified_Business_Plan__c))
           {
               SAP.Last_Modified_Date_Time__c = SAP.Last_Modified_Business_Plan__c;
           }
       }
       else
       {
           SAP.Last_Modified_Date_Time__c = SAP.Last_Modified_Business_Plan__c;
       }
       update SAP;
    
    }


}

}