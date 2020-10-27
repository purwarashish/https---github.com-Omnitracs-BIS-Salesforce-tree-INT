public class SupportAlert {

    private List<Support_Alert__c> alerts;
    private Contact cntact; 
    public SupportAlert(ApexPages.StandardController controller) {
        this.cntact= (Contact)controller.getRecord();
    }
    public List<Support_Alert__c> getAlerts()
    {
        Contact con = [Select id, Account.id FROM Contact where id = :cntact.id];
        
            if (con.Account == null)
             return null;
        
        alerts = [Select Name,Importance__c,Critical__c, Description__c,Summary__c,End_Date__c from Support_Alert__c where Account__c = :con.Account.id order by Name desc];
                
        return alerts;
    }

}