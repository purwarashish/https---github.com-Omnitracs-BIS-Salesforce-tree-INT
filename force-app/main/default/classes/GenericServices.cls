public with sharing class GenericServices
{

    //returns true if the input string is null or empty
    public static Boolean isNullOrEmpty(String rawInputString)
    {
        return (rawInputString == null || rawInputString.trim().length() == 0);
    }
/*    
    //returns the id of the engineering queue. 
    public static String developmentQueueID
    {
        get
        {
            try
            {
                return [Select ID from Group where Type =: Constants.QUEUE_TYPE 
                            and Name =: Constants.DEVELOPMENT_QUEUE_NAME limit 1].id;
            }
            catch(Exception e)
            {
                return '';
            }
        }
    }
    
    public static void sendEmail(String emailAddress, String subject)
    {
        boolean EmailEnabled;
       
        for(SendEmailEnabled__c se: [Select Enabled__c from SendEmailEnabled__c])
            EmailEnabled = se.Enabled__c;
        
        if(!isNullOrEmpty(emailAddress))
        {
            String[] toaddress = new String[]{};
            toaddress.add(emailAddress);
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(toaddress);
            mail.setsubject(subject);
            EmailTemplate et1 = [Select ID, Name, HTMLValue from EmailTemplate where id=: getGeneralSettingValueForKey('Rejected Email Text Template ID')];
            mail.setHtmlBody(et1.htmlValue);
            //mail.setPlainTextBody(getGeneralSettingValueForKey('Rejected Email Text'));
            
            if(EmailEnabled)
            {   
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
                SystemLogEmailCount.checkSystemLogEmailCount('GenericServices');
            }
        }
    }
*/    
    //returns the DMLOption of using the standard assignment rule when cases are inserted. These options are set
    //before a DML on Case record is performed
    public static Database.DMLOptions defaultAssignmentDBOptions
    {
        get
        {
            if(defaultAssignmentDBOptions == null)
            {
                defaultAssignmentDBOptions = new Database.DMLOptions();
                defaultAssignmentDBOptions.assignmentRuleHeader.useDefaultRule = true;
            }
            return defaultAssignmentDBOptions;
        }
        private set;
    }
/*    
    //converts a query string value to boolean. 
    public static Boolean getBooleanQueryStringValue(string qs)
    {
        if(!IsNullOrEmpty(qs))
        {
            String queryString = ApexPages.currentPage().getParameters().get(qs);
            if(!isNullOrEmpty(queryString))
            {
                try
                {
                    return Boolean.valueOf(queryString);
                }
                catch(Exception exc)
                {
                    return false;
                }
            }
        }
        return false;
    }
    
    public static Map<String, RecordType> getRecordTypesNameMapBySObject(String sObjectName)
    {
        Map<String, RecordType> recordTypesNameMap = new Map<String, RecordType>();
        if(!isNullOrEmpty(sObjectName))
        {
            for(RecordType rt: [Select Id, DeveloperName from RecordType where sObjectType =: sObjectName ])
                recordTypesNameMap.put(rt.DeveloperName, rt);
        }
        return recordTypesNameMap;
    }
    
    
    
    //returns the value of any key defined in the custom settings
    public static String getGeneralSettingValueForKey(String key)
    {
        String value = '';
        if(key != null && General_Settings__c.getAll().containsKey(key))
            value = General_Settings__c.getAll().get(key).Value__c;
        
        return value;
    }
    
    public static String getCSVFromList(List<String> strList)
    {
        String csvString = '';
        if(strList != null && strList.size() > 0)
        {
            integer x= 0;
            for(String s: strList)
            {
                if(x == 0)
                    csvString += s;
                else
                    csvString += ','+s;
                
                x++; 
            }
        }
        
        return csvString;
    }
    
    public static String getCSVFromSet(Set<String> strSet)
    {
        String csvString = '';
        if(strSet != null && strSet.size() > 0)
        {
            List<String> strList = new List<String>();
            strList.addAll(strSet);
            
            return getCSVFromList(strList);
        }
        
        return csvString;
    }
    
    public static Set<String> getPrimaryProductSKUs(String dependentProductSKU)
    {
        Set<String> primaryProductSKUs = new Set<String>();
        if(!isNullOrEmpty(dependentProductSKU))
        {
            for(Asset_Dependency_Matrix__c adm: Asset_Dependency_Matrix__c.getAll().values())
            {
                if(adm.Dependent_Product_ID__c == dependentProductSKU)
                    primaryProductSKUs.add(adm.Primary_Product_ID__c);
            }
        }
        
        return primaryProductSKUs;
    }
    
    public static String getPage2SKU(String page1SKU)
    {
        if(!isNullOrEmpty(page1SKU))
        {
            for(Page1_Page2_Mapping__c ppm: Page1_Page2_Mapping__c.getAll().values())
            {
                if(ppm.Page_1_SKU__c == page1SKU)
                    return ppm.Page_2_SKU__c;
            }
        }
        
        return null;
    }
    
    public static String getPage1SKU(String page2SKU)
    {
        if(!isNullOrEmpty(page2SKU))
        {
            for(Page1_Page2_Mapping__c ppm: Page1_Page2_Mapping__c.getAll().values())
            {
                if(ppm.Page_2_SKU__c == page2SKU)
                    return ppm.Page_1_SKU__c;
            }
        }
        
        return null;
    }
    
    public static Set<String> availableRegEventTypes
    {
        get
        {
            if(availableRegEventTypes == null)
            {
                availableRegEventTypes = new Set<String>();
                availableRegEventTypes.add(Constants.PRACTICE);
                availableRegEventTypes.add(Constants.PAYERS);
                availableRegEventTypes.add(Constants.SERVICES);
                availableRegEventTypes.add(Constants.PROVIDERS);
                //Added OPTIN to available Regiration Events
                availableRegEventTypes.add(Constants.OPTIN);
            }
            
            return availableRegEventTypes;
        }
        
        private set;
    }
    
    public static Map<String, List<String>> getParentToChildDateFieldsMap(String dateParent, String dateChild)
    {
        Map<String, List<String>> parentToChildFieldMap = new Map<String, List<String>>();
        List<String> providerAssetDateFields = new List<String>();
        providerAssetDateFields.add(dateChild);
        parentToChildFieldMap.put(dateParent, providerAssetDateFields);
        
        return parentToChildFieldMap;   
    }
    
    public static void addErrorFromDMLException(DMLException dmle, List<SObject> listOfDMLdSObjects,  String prependedErrorMessage)
    {
        if(prependedErrorMessage == null) prependedErrorMessage = '';
        
        if(dmle != null && listOfDMLdSObjects != null && listOfDMLdSObjects.size() > 0)
        {
            for(Integer x = 0; x<=dmle.getNumDML()-1; x++)
                listOfDMLdSObjects[x].addError(prependedErrorMessage+dmle.getDMLMessage(x));
        }
    }
/**/
}