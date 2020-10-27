public with sharing class RnTelematicsDeviceSummaryExtension
{
    private List<RN_Telematics_Devices__c> rnTelematicsDevices{get; set;}
    private RN_Telematics_Devices__c device{get;set;}  
    public RnTelematicsDeviceSummaryExtension(apexpages.standardcontroller stdcont)
    {
        device = [select id, account__c from RN_Telematics_Devices__c where id =: stdCont.getId()];
        
        if (device.Account__c != null)
        {
            try
            {
                rnTelematicsDevices = [select id, Installation_Date__c, activation_date__c from RN_Telematics_Devices__c where Account__c =: device.Account__c];
            }
            catch(Exception e)
            {
                //  entirely possible for an account to have no devices
            }
        }
    }
    public integer devicesAssoicatedCustomer
    {
        get
        {
            if (rnTelematicsDevices == null)
            {
                return 0;
            }
            else
            {
                return rnTelematicsDevices.size();
            }
        }
    }
    public integer activeDevices
    {
        get
        {
            if (rnTelematicsDevices == null)
            {
                return 0;
            }
            else
            {
                integer numActivated = 0;
                for (RN_Telematics_Devices__c d : rnTelematicsDevices)
                {
                    if (d.Activation_Date__c != null)
                    {
                        numActivated++;
                    }
                }
                return numActivated;
            }
        }
    }
    public integer devicesWithInstallDates
    {
        get
        {
            if (rnTelematicsDevices == null)
            {
                return 0;
            }
            else
            {
                integer numInstalled = 0;
                for (RN_Telematics_Devices__c d : rnTelematicsDevices)
                {
                    if (d.Installation_Date__c != null)
                    {
                        numInstalled++;
                    }
                }
                
                return numInstalled;
            }
        }
    }
    public static RN_Telematics_Devices__c createTestTelematicsDevice()
    {
        RN_Telematics_Devices__c rn = new RN_Telematics_Devices__c();
        rn.Account__c = [select id from account limit 1].id;
        rn.Activation_Date__c = rn.Installation_Date__c = date.today();

        database.saveResult saveresult = database.insert(rn);
        if (saveresult.isSuccess())
        {
            rn = [Select id, account__c, Activation_Date__c, installation_date__c From RN_Telematics_Devices__c  where id =: saveresult.id];
        }
        return rn;      
         
    }
    public static ApexPages.StandardController genCon(RN_Telematics_Devices__c bd)
    {
        pagereference pageRef=new pagereference('Page.BillingDetailPage');
        test.setcurrentpage(pageRef);
        
        return new ApexPages.standardController(bd);
    }
}