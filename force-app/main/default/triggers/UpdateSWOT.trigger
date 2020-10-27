trigger UpdateSWOT on SWOT_Analysis__c (after insert,after update) {
for(SWOT_Analysis__c SWA:trigger.new)
{
  if(SWA.Strategic_Account_Profile__c != null)
    {
      Strategic_Account_Profile__c SAP = [Select Last_Modified_SWOT__c,Last_Modified_Date_Time__c from Strategic_Account_Profile__c where Id=:SWA.Strategic_Account_Profile__c Limit 1];
       SAP.Last_Modified_SWOT__c  = Datetime.Valueof(System.now());
       If (SAP.Last_Modified_Date_Time__c !=null) 
       {
           if((SAP.Last_Modified_Date_Time__c < SAP.Last_Modified_SWOT__c))
           {
               SAP.Last_Modified_Date_Time__c = SAP.Last_Modified_SWOT__c;
           }
       }
       else
       {
           SAP.Last_Modified_Date_Time__c = SAP.Last_Modified_SWOT__c;
       }

      update SAP;
    
    }
}
}