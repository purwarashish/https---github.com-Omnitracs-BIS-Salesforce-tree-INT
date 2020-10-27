public class SendEmailLead
{
    public static Boolean isExecuted = false;
    public static void DMLLead(list<Lead> lstLead)
    {
       
        System.debug('@@@Email is sent');
        isExecuted = true;
        List<Id> leadIds = new List<Id>{};
        for (Lead theLead:lstLead) 
            leadIds.add(thelead.Id);
        List<lead> leads = new List<lead>{}; 
        List<lead> tempLead = [Select Id from lead where Id in :leadIds limit 1]; 
        for(lead c :tempLead )
        {
          System.debug('Email is sent');
          Database.DMLOptions dmo = new Database.DMLOptions();
          dmo.EmailHeader.triggerUserEmail = true;
          c.setOptions(dmo);
            
            leads.add(c);
        }
       System.debug('@@@leads.size' + lstLead.size()); 
       update leads;
}
}