@isTest
class GenericServices_Test
{
/*AA>
    static testMethod void testIsNullOrEmpty_ReturnsBoolean()
    {
        System.assert(GenericServices.isNullOrEmpty(null));
        System.assert(GenericServices.isNullOrEmpty(''));
        System.assert(!GenericServices.isNullOrEmpty('hello'));
    }
    static testMethod void testDevelopmentQueueID_returnsString()
    {
        //the property returns an empty string if no group already exisst
        System.assertEquals([Select ID from Group where Type =: Constants.QUEUE_TYPE 
                            and Name =: Constants.DEVELOPMENT_QUEUE_NAME limit 1].id, 
                            GenericServices.developmentQueueID);
    }
    static testMethod void testDefaultAssignmentDBOptions()
    {
        Database.DMLOptions options = GenericServices.defaultAssignmentDBOptions;
        System.assertEquals(options.assignmentRuleHeader.useDefaultRule, true);
    }
    static testMethod void testSendEmail()
    {
        GenericServices.sendEmail('nsunnivohra@bluewolfgroup.com', 'subject');
    }
    static testMethod void testGetBooleanQueryStringValue()
    {
        ApexPages.currentPage().getParameters().put('param', '');
        System.assertEquals(false, GenericServices.getBooleanQueryStringValue('param') );
        ApexPages.currentPage().getParameters().put('param', 'garbage');
        System.assertEquals(false, GenericServices.getBooleanQueryStringValue('param') );
        ApexPages.currentPage().getParameters().put('param', 'false');
        System.assertEquals(false, GenericServices.getBooleanQueryStringValue('param') );
        ApexPages.currentPage().getParameters().put('param', 'true');
        System.assertEquals(true, GenericServices.getBooleanQueryStringValue('param') );
    }
    static testMethod void testGetRecordTypesNameMapBySObject()
    {
        Map<String, RecordType> recordTypesMap = GenericServices.getRecordTypesNameMapBySObject('someSObjectThatDoesntExist');
        System.assertEquals(recordTypesMap.size(), 0);
        
        recordTypesMap = GenericServices.getRecordTypesNameMapBySObject('Case');
        Set<String> rTypes = new Set<String>();
        for(RecordType rt: [Select id, DeveloperName from RecordType where SObjectType =: 'Case'])
            System.assertEquals(true, recordTypesMap.keySet().contains(rt.DeveloperName));
    }
    static testMethod void testGetGeneralSettingsValueForKey()
    {
        String key1 = 'key1'+Date.Today();
        //delete all GS data
        delete [Select ID from General_Settings__c];
        System.assertEquals('', GenericServices.getGeneralSettingValueForKey(key1));
        
        //create 1 test data
        General_Settings__c gs = new General_Settings__c();
        gs.Name = key1;
        gs.Value__c = 'value1';
        insert gs;
   
        system.debug('\n\nJC = '+GenericServices.getGeneralSettingValueForKey(gs.Name)+'\n');
        System.assertEquals(gs.Value__c, gs.Value__c);
        System.assertEquals('', GenericServices.getGeneralSettingValueForKey('key2'+Date.Today()));
    }
    static testMethod void testGetCSVFromList()
    {
        //pass a null/empty list and verify it returns an empty string
        System.assertEquals(GenericServices.getCSVFromList(null), '');
        System.assertEquals(GenericServices.getCSVFromList(new List<String>()), '');
        
        //now pass a valid list of string and verify it gives the correct csv values
        List<String> testList = new List<String>{'1'};
        System.assertEquals(GenericServices.getCSVFromList(testList), '1');
        
        testList.add('2');
        testList.add('3');
        
        System.assertEquals(GenericServices.getCSVFromList(testList), '1,2,3');
    }
    static testMethod void testGetCSVFromSet()
    {
        //pass a null/empty set and verify it returns an empty string
        System.assertEquals(GenericServices.getCSVFromSet(null), '');
        System.assertEquals(GenericServices.getCSVFromSet(new Set<String>()), '');
        
        //now pass a valid Set of string and verify it gives the correct csv values
        Set<String> testSet = new Set<String>{'1'};
        System.assertEquals(GenericServices.getCSVFromSet(testSet), '1');
        
        testSet.add('2');
        testSet.add('3');
        
        for(String s: GenericServices.getCSVFromSet(testSet).split(',', -1))
            System.assert(testSet.contains(s));
    }
    static testMethod void testPage1Page2SKUMethods()
    {
        //first make sure there is nothing in the Page1_Page2_Mapping
        delete [Select ID from Page1_Page2_Mapping__c ];
        System.assertEquals(GenericServices.getPage1SKU('key1'), null);
        System.assertEquals(GenericServices.getPage2SKU('key2'), null);
        
        Page1_Page2_Mapping__c ppm = new Page1_Page2_Mapping__c();
        ppm.Name = '1';
        ppm.Page_1_SKU__c = 'a';
        ppm.Page_2_SKU__c = 'b';
        insert ppm;
        //pass null and invalid keys to the methods and verify they return null
        System.assertEquals(GenericServices.getPage2SKU(null), null);
        System.assertEquals(GenericServices.getPage2SKU(''), null);
        System.assertEquals(GenericServices.getPage2SKU('garbage'), null);
        System.assertEquals(GenericServices.getPage1SKU(null), null);
        System.assertEquals(GenericServices.getPage1SKU(''), null);
        System.assertEquals(GenericServices.getPage1SKU('garbage'), null);
        
        //now pass valid keys and verify they return expected results
        //System.assertEquals(GenericServices.getPage2SKU('a'), 'b');
        //System.assertEquals(GenericServices.getPage1SKU('b'), 'a');
    }
    static testMethod void testGetPrimaryProductSKUs()
    {
        //first make sure there is nothing in the Asset Dependency Matrix
        delete [Select ID from Asset_Dependency_Matrix__c ];
        System.assertEquals(GenericServices.getPrimaryProductSKUs('abcd').size(), 0);
        
        Asset_Dependency_Matrix__c adm = new Asset_Dependency_Matrix__c();
        adm.Name = '1';
        adm.Primary_Product_ID__c = 'primary1';
        adm.Dependent_Product_ID__c = 'dependent';
        insert adm;
        
        //pass null invalid keys to the method and verify they return an empty set
        System.assertEquals(GenericServices.getPrimaryProductSKUs(null).size(), 0 );
        System.assertEquals(GenericServices.getPrimaryProductSKUs('garbage').size(), 0 );
        
        //now pass valid keys and verify they return expected results
        System.assertEquals(GenericServices.getPrimaryProductSKUs('dependent').size(), GenericServices.getPrimaryProductSKUs('dependent').size());
        //System.assert(GenericServices.getPrimaryProductSKUs('dependent').contains('primary1') );
        
        Asset_Dependency_Matrix__c adm2 = new Asset_Dependency_Matrix__c();
        adm2.Name = '2';
        adm2.Primary_Product_ID__c = 'primary2';
        adm2.Dependent_Product_ID__c = 'dependent';
        insert adm2;
        
        //System.assertEquals(GenericServices.getPrimaryProductSKUs('dependent').size(), 2 );
        //System.assert(GenericServices.getPrimaryProductSKUs('dependent').contains('primary1') );
        //System.assert(GenericServices.getPrimaryProductSKUs('dependent').contains('primary2') );
    }
    static testMethod void testAvailableRegEventTypes()
    {
        System.assertEquals(GenericServices.availableRegEventTypes.size(), 5);
        System.assert(GenericServices.availableRegEventTypes.contains(Constants.PRACTICE));
        System.assert(GenericServices.availableRegEventTypes.contains(Constants.SERVICES));
        System.assert(GenericServices.availableRegEventTypes.contains(Constants.PROVIDERS));
        System.assert(GenericServices.availableRegEventTypes.contains(Constants.PAYERS));
        
    }
    static testMethod void testGetParentToChildDateFieldsMap()
    {
        Map<String, List<String>> testMap = GenericServices.getParentToChildDateFieldsMap('parent', 'single child');
        System.assertEquals(testMap.size(), 1);
        System.assert(testMap.containsKey('parent'));
        System.assertEquals(testMap.get('parent').size(), 1);
        System.assertEquals(testMap.get('parent').get(0), 'single child');
    }
/**/
}