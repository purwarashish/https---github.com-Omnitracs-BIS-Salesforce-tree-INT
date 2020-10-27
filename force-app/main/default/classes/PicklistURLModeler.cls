public with sharing class PicklistURLModeler
{
    public List<Platform__c> platform {get;set;}
    public List<Application__C> application{get;set;}
    public List<Selectoption> lstSOAppName {get;set;}
    public List<Selectoption> lstSOPlatformName{get;set;}
    public List<String> lstStrAppName {get;set;}
    public List<String> lstStrPlatformName {get;set;}
    public List<String> platformAsLink {get;set;}
    public List<String> applicationAsLink {get;set;}
    public String rUrl {get; set;}
    public integer i {get;set;}
    public String strSelectPlatfrom {get;set;}
    public String strSelectApp {get;set;}

    public PicklistURLModeler()
    {
        i = 100;
        refreshInitializationData();
    }
    
    /**
     * @description Method to refresh the initialization data for the PicklistURLModeler
     * whenever a page loads that makes use of the PicklistURLModeler.
     */
    public void refreshInitializationData()
    {
        platform = [Select Id,Name,Display_on_Left_Nav_Bar__c  from Platform__c Order By Ordinal__c limit 1000];
        application = [Select Id,Name,Display_on_Left_Rail_as_Link__c from Application__C Order By Ordinal__c limit 1000];
        lstStrPlatformName = new list<String> ();
        lstStrAppName = new list<String> ();
        lstSOPlatformName = new list<selectOption> ();
        lstSOAppName = new list<selectOption> ();
        platformAsLink = new list<String>();
        applicationAsLink = new list<String>();
        for(integer i=0;i<platform.size();i++)
        {
            if(platform[i].Display_on_Left_Nav_Bar__c)
                platformAsLink.add(Platform[i].Name);
                
            lstStrPlatformName.add(Platform[i].Name);
                
        }

        for(integer i=0;i<application.size();i++)
        {
            if(application[i].Display_on_Left_Rail_as_Link__c)
                applicationAsLink.add(Application[i].Name);
            
            lstStrAppName.add(Application[i].Name);
        }

       lstStrPlatformName.sort();
       lstStrAppName.sort();
       
       
       lstSOPlatformName.add(new SelectOption('All Platforms', 'All Platforms'));
       for(String platform:lstStrPlatformName)
       {
        lstSOPlatformName.add(new SelectOption(platform,platform)); 
       }
       lstSOAppName.add(new SelectOption('All Applications', 'All Applications'));       
       for(String application:lstStrAppName)
       {
        lstSOAppName.add(new SelectOption(application,application)); 
       }       
    }
    
    public PageReference redirectNow()
    {
        PageReference pg = new PageReference('/apex/supportanswers');
        pg.setRedirect(false);
        return pg;
    }
}