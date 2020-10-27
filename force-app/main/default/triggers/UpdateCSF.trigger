trigger UpdateCSF on Critical_Success_Factor__c (after insert, after update) 
{
for(Critical_Success_Factor__c CSF :Trigger.new)
{
    if(CSF.Strategic_Account_Profile__c != null)
    {
       Strategic_Account_Profile__c SAP = [Select Last_Modified_CSF__c,Last_Modified_Date_Time__c from Strategic_Account_Profile__c where Id=:CSF.Strategic_Account_Profile__c Limit 1];
       SAP.Last_Modified_CSF__c  = Datetime.Valueof(System.now());
        If (SAP.Last_Modified_Date_Time__c !=null) 
       {
           if((SAP.Last_Modified_Date_Time__c < SAP.Last_Modified_CSF__c))
           {
               SAP.Last_Modified_Date_Time__c = SAP.Last_Modified_CSF__c;
           }
       }
       else
       {
           SAP.Last_Modified_Date_Time__c = SAP.Last_Modified_CSF__c;
       }

       update SAP;
    
    }

}


}