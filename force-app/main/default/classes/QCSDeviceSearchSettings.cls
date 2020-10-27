public class QCSDeviceSearchSettings {

    //==================================================
    // PROPERTIES
    //==================================================
    public static final String KEY_SUPPORT_EMAIL = 'DeviceSearch.SupportEmail';
    
    public static QcsDeviceSearchSettings instance;    
    public String  supportEmail                             {get; private set;}
    

    //==================================================
    // CONSTRUCTOR  
    //==================================================
    private QcsDeviceSearchSettings(){
        final Map<String,Global_Variable__c> all = Global_Variable__c.getAll();
        supportEmail = retrieveString(KEY_SUPPORT_EMAIL, all);
        
    }
   
    //==================================================
    // HELPER METHODS
    //==================================================    
    private static String retrieveString(String key, Map<String,Global_Variable__c> all){
        String returnValue = null;
        //SK_To replace managed package with unmanaged package
       // if(all != null && al.StringUtils.isNotBlank(key) && all.get(key) != null){
        if(all != null && StringUtils.isNotBlank(key) && all.get(key) != null){
            returnValue = all.get(key).value__c;
        }
        return returnValue;
    }
    
    public static QcsDeviceSearchSettings getInstance(){
        if(instance == null){
            instance = new QcsDeviceSearchSettings();
        }
        return instance;
    }    
}