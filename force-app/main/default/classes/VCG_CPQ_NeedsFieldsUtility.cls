/***********************************************************************************************************************
* @description
* @author  Scott Warren <swarren@vepcg.com>
* @since   07.Jul.2014
***********************************************************************************************************************/
public without sharing class VCG_CPQ_NeedsFieldsUtility{

/***********************************************************************************************************************
* @description
* @author  Scott Warren <swarren@vepcg.com>
* @since   07.Jul.2014
*
* Assumptions:
*   1) Objects in map are all of the same type.
*   2) Object references exist in a field on the primary object as "ObjectName__c".
*   3) Assumes method arguments are custom objects and utilize custom relationship format
*
* Notes:
*   1)  This code performs a Database query within a for loop. The rationale is that each iteration of the loop is querying
*       a different sObject. The for loop (and therefore the query) should only run once for each referenced object
*       e.g.... Quote.Account__r.Name, Quote.Opportunity__r.Name would run 2 queries. One for each sObject reference.
*       To mitigate additional overhead, the queries have been limited to objects directly related to the argument objects
*
*   2)  This method does not pull Needs Fields values from fields on the primary object (non relationship fields). This would
*       require a query, which is impossible for records which have not yet been inserted (e.g. temporary approvals to display
*       before the quote is saved).
*       :: Edited to perform this function on 09.Jul.2014 --SW 
*
*       :: Code should be cleaned up for performance
*   
*   3) Bulkifed for use in the Quote Trigger
*
************************************************************************************************************************/
    public static List<sObject> getNeedsFields(Map<SObject, String> objMap){
        //return objects
        List<sObject> sObjs = new List<sObject>();
        
        //This map is used to combine all required fields per object across every object received. 
        //This eliminates the need for more than 1 query per related object
        //<ObjectName, Set<Field Names>>
        Map<String, Set<String>> object_fields_map = new Map<String, Set<String>>();
        List<String> objectFields = new List<String>();
        List<String> fieldSplit = new List<String>();       
        Set<String> localObjectFields = new Set<String>();
        
        //Iterate over Needs Fields values received in method argument for each object
        for(String fields : objMap.values()){
            // Iterate over individual fields after delimiter split
            for(String str : fields.split(';'))
            {
               objectFields = new List<String>();
               
                //Check the field for relationship parameters
                if(str.contains('.') && str.split('/.')[0].contains('__r')){
                    objectFields = str.split('__r', 2);      
                   
                    //Assign the related object and field to the object/field map
                   if(object_fields_map.containsKey(objectFields[0])){
                        object_fields_map.get(objectFields[0]).add(objectFields[1].substring(1));
                    }
                    else{
                        object_fields_map.put(objectFields[0], new Set<String>{objectFields[1].substring(1)});
                    }
                    
                    localObjectFields.add(objectFields[0] + '__c');
               }
               
                //If dot notation is used, but there is no custom relationship 
               else if(str.contains('.')){
                   //Split by the first object reference
                   objectFields = str.split('/.',2);
                   
                   //Assign the related object and field to the object/field map
                   if(object_fields_map.containsKey(objectFields[0])){
                       object_fields_map.get(objectFields[0]).add(objectFields[1].substring(1));
                   }
                   else{
                       object_fields_map.put(objectFields[0], new Set<String>{objectFields[1].substring(1)});
                   }
               }
                
               else{
                    localObjectFields.add(str);
                }
            }
        }

        //Handle non-relationship Needs Fields for parameter objects
        String paramObjectQuery;
        Set<String> paramObjectIds = new Set<String>();
        List<sObject> paramQueryObjects = new List<sObject>();
        List<sObject> paramObjects = new List<sObject>();
        
        paramObjects.addAll(objMap.keySet());
        for(sObject primaryObj : paramObjects){
            if(primaryObj.get('Id') != null){
                paramObjectIds.add(String.valueOf(primaryObj.get('Id')));
            }
        }
        if(!paramObjectIds.isEmpty()){
            paramObjectQuery = 'SELECT Id, ';
            for(String localObjectField : localObjectFields){
                paramObjectQuery += localObjectField + ', ';
            }
            
            paramObjectQuery = paramObjectQuery.substring(0, paramObjectQuery.length()-2);
            paramObjectQuery += ' FROM ';
            paramObjectQuery += paramObjects[0].getSObjectType().getDescribe().getName();
            paramObjectQuery += ' WHERE Id in : paramObjectIds';
            
System.debug('paramObjectQuery: ' + paramObjectQuery);
            paramQueryObjects = Database.query(paramObjectQuery);            
        }
        
        for(sObject paramObj : objMap.keySet()){
            for(sObject paramQueryObj : paramQueryObjects){
                for(String field : objMap.get(paramObj).split(';')){
                    try {
                        paramObj.put(field, paramQueryObj.get(field));
                    }
                    catch (Exception e) {
                        //Something went wrong
                        System.debug('Danger Will Robinson...');
                    }
                }
            }
System.debug('paramObj: ' + paramObj);            
        }
        
        
        
        //To avoid querying every record for each object, 
        //we loop through and assign only the relevant object IDs to this set for use in our query
        Set<String> idsToQuery = new Set<String>();
        String queryString;
        String getObjField;
        Object getObject;
        List<sObject> queryObjs = new List<sObject>();
        
        //Iterate over the objects which need to be queried
        for(String objectName : object_fields_map.keySet()){
            idsToQuery.clear();
            
            //Begin building query using map values
            queryString = 'SELECT Id, ';
            for(String field : object_fields_map.get(objectName)){
                queryString += field + ', ';
            }
            
            //Strip trailing space+comma from the query
            queryString = queryString.substring(0, queryString.length()-2);
            queryString += ' FROM ' + objectName + ' WHERE Id in: ';
            
            //Iterate over objects received in method call
            for(sObject sobj : objMap.keySet()){                
                //Assumes that the field reference is named "ObjectName__c" in all cases
                getObjField = objectName + '__c';
                //Attempt to get value from
                try{
                    idsToQuery.add(String.valueOf(sobj.get(getObjField)));
                }
                catch(Exception e){
                    //Could not find the field requested for the object
                }
            }
            
            //add id set to query filter
            queryString += 'idsToQuery';          
            
            //Run the query and add to generic object list
            queryObjs.add(Database.query(queryString));
        }

        
        String fieldName;
        String relationshipName;
        Schema.SObjectType stype;

        //Iterate over objects received from method call
        for(sObject sobj : objMap.keySet()){
            //Iterate over objects referenced in Needs Fields string
            for(String objectName : object_fields_map.keySet()){
                
                //Create reference to related object 
                if(!objectName.contains('__r')){
                    objectName += '__r';
                }
                //Iterate over list of objects returned from all queries
                for(sObject queryObj : queryObjs){
                    fieldName = queryObj.getSObjectType().getDescribe().getName();
                    
                    //Generate a field name reference for the main object
                    if(!fieldName.contains('__c')){
                        fieldName += '__c';
                        relationshipName = fieldName.replace('__c', '__r');
                    }
                    //If the lookup ID matches the object ID from the query
                    if(sobj.get(fieldName) == queryObj.Id){
                        
                        //No longer needed. Leaving until further testing is completed.
                        stype = queryObj.getsObjectType();
                        
                        //Associate the queried object + associated fields with the main object
                        sobj.putSObject(relationshipName, queryObj);
                    }
                }
            }
            //Add updated object to the return list
            sObjs.add(sobj);
        }
        
        return sObjs;
    }

    
    
    
    public static List<sObject> getNeedsFields(List<sObject> needsFieldsObjs, String needsFields){
        //return objects
        List<sObject> sObjs = new List<sObject>();
        
        //This map is used to combine all required fields per object across every object received. 
        //This eliminates the need for more than 1 query per related object
        //<ObjectName, Set<Field Names>>
        Map<String, Set<String>> object_fields_map = new Map<String, Set<String>>();
        List<String> objectFields = new List<String>();
        List<String> fieldSplit = new List<String>();       
        Set<String> localObjectFields = new Set<String>();
        
        //Iterate over individual fields after delimiter split
        for(String str : needsFields.split(';')){
               objectFields = new List<String>();
               
                //Check the field for relationship parameters
                if(str.contains('.') && str.split('/.')[0].contains('__r')){
                    objectFields = str.split('__r', 2);      
                   
                    //Assign the related object and field to the object/field map
                   if(object_fields_map.containsKey(objectFields[0])){
                        object_fields_map.get(objectFields[0]).add(objectFields[1].substring(1));
                    }
                    else{
                        object_fields_map.put(objectFields[0], new Set<String>{objectFields[1].substring(1)});
                    }
                    
                    localObjectFields.add(objectFields[0] + '__c');
               }
               
                //If dot notation is used, but there is no custom relationship 
               else if(str.contains('.')){
                   //Split by the first object reference
                   objectFields = str.split('\\.',2);
                   
                   //Assign the related object and field to the object/field map
                   if(object_fields_map.containsKey(objectFields[0])){
                       object_fields_map.get(objectFields[0]).add(objectFields[1]);
                   }
                   else{
                       object_fields_map.put(objectFields[0], new Set<String>{objectFields[1]});
                   }
               }
               
               //@todo: look into why a string value of 'null' is being sent through
               else{
                    if(String.isNotBlank(str) && str.trim() != 'null'){
                        localObjectFields.add(str);
                        System.debug('adding to field list: ' + str);                           
                    }
                }
        }
        

        //Handle non-relationship (local) Needs Fields for parameter objects
// Don't think we need this ... the primary object should already have all the fields it needs. The primary
// object should either have been built in memory (with all needed fields populated) or it is from a trigger
// in which case all fields are given. Disabled for now because this is causing problems where the saved
// values haven't been updated yet and are different than what is in memory (i.e. we are in a beforeUpdate)
// and a Needs_Field field has been updated -- if we allow this code to execute, it will overwrite the
// updated, in-memory value with the old value from the database. -LC 2014-10-08
/*
        String paramObjectQuery;
        Set<String> paramObjectIds = new Set<String>();
        List<sObject> paramQueryObjects = new List<sObject>();
        List<sObject> paramObjects = new List<sObject>();
        
        for(sObject primaryObj : needsFieldsObjs){
            if(primaryObj.get('Id') != null){
                paramObjectIds.add(String.valueOf(primaryObj.get('Id')));
            }
        }
        if(!paramObjectIds.isEmpty()){
            paramObjectQuery = 'SELECT Id, OwnerId, ';
            for(String localObjectField : localObjectFields){
                if(localObjectField != null && localObjectField != ''){
                    paramObjectQuery += localObjectField + ', ';
                }
            }
            
            paramObjectQuery = paramObjectQuery.substring(0, paramObjectQuery.length()-2);
            paramObjectQuery += ' FROM ';
            paramObjectQuery += needsFieldsObjs[0].getSObjectType().getDescribe().getName();
            paramObjectQuery += ' WHERE Id in : paramObjectIds';
            
            System.debug('paramObjectQuery: ' + paramObjectQuery);
            paramQueryObjects = Database.query(paramObjectQuery);            
        }
        
        for(sObject paramObj : needsFieldsObjs){
            for(sObject paramQueryObj : paramQueryObjects){
                for(String field : needsFields.split(';')){
                    try{
                        paramObj.put(field, paramQueryObj.get(field));
                    }
                    catch(Exception e){
                        //Something went wrong
                        System.debug('Danger Will Robinson...');
                    }
                }
            }
            System.debug('paramObj: ' + paramObj);            
        }
        
*/        
        
        //To avoid querying every record for each object, 
        //we loop through and assign only the relevant object IDs to this set for use in our query
        Set<String> idsToQuery = new Set<String>();
        String queryString;
        String getObjField;
        Object getObject;
        List<sObject> queryObjs = new List<sObject>();
        
        //Iterate over the objects which need to be queried
        for(String objectName : object_fields_map.keySet()){
            idsToQuery.clear();
            
            //Iterate over objects received in method call
            for(sObject sobj : needsFieldsObjs){                
                //Assumes that the field reference is named "ObjectName__c" in all cases
                if(objectName == 'Owner')
                    getObjField = 'OwnerId';
                else
                    getObjField = objectName + '__c';
                
                //Attempt to get value from
                try{
                    if (sobj.get(getObjField) != null)
                    {
                        idsToQuery.add(String.valueOf(sobj.get(getObjField)));
                    }
                }
                catch(Exception e){
                    //Could not find the field requested for the object
                }
            }
            
            if (idsToQuery.size() > 0)
            {
                //Begin building query using map values
                queryString = 'SELECT Id, ';
                for(String field : object_fields_map.get(objectName)){
                    queryString += field + ', ';
                }
                
                // Strip trailing space+comma from the query
                queryString = queryString.substring(0, queryString.length()-2);
                if(objectName == 'Owner')
                    queryString +=   ' FROM User WHERE Id IN :idsToQuery';
                else
                {
                    queryString +=   ' FROM ' 
                                       // We have to use the object name this field references!
                                   +   needsFieldsObjs[0].getSObjectType().getDescribe().fields.getMap().get(objectName + '__c').getDescribe().getReferenceTo()[0].getDescribe().getName() 
                                   + ' WHERE Id IN ';
                    queryString += ' :idsToQuery';
                }
                System.debug('====> query: ' + queryString + ' (idsToQuery: ' + idsToQuery + ')');
                
                //Run the query and add to generic object list
                queryObjs.add(Database.query(queryString));
            }
        }

        
        String fieldName;
        String relationshipName;
        Schema.SObjectType stype;

        //Iterate over objects received from method call
        for(sObject sobj : needsFieldsObjs){
            //Iterate over objects referenced in Needs Fields string
            for(String objectName : object_fields_map.keySet()){
                System.debug('====> objectName: ' + objectName);
                
                //Create reference to related object 
//                if(!objectName.contains('__r')){
//                    objectName += '__r';
//                }
                //Iterate over list of objects returned from all queries
                for(sObject queryObj : queryObjs){
                    fieldName = objectName; // queryObj.getSObjectType().getDescribe().getName();
                    if(fieldName == 'Owner') fieldName = 'OwnerId';
                    System.debug('====> fieldName: ' + fieldName);
                    
                    //Generate a field name reference for the main object
                    if(!fieldName.contains('__c') && fieldName != 'OwnerId'){
                        fieldName += '__c';
                        relationshipName = fieldName.replace('__c', '__r');
                    }
                    else if(fieldName == 'OwnerId')
                        relationshipName = 'Owner';
                        
                    System.debug('====> relationshipName: ' + relationshipName);
                    // If the lookup ID matches the object ID from the query
                    if (sobj.get(fieldName) == queryObj.Id){
                        
                        //No longer needed. Leaving until further testing is completed.
                        stype = queryObj.getsObjectType();
                        
                        //Associate the queried object + associated fields with the main object
                        System.debug('====> Assigning to ' + relationshipName + ': ' + queryObj);
                        sobj.putSObject(relationshipName, queryObj);
                    }
                }
            }
            //Add updated object to the return list
            sObjs.add(sobj);
        }
        
        return sObjs;
    }

    
    /**
     * @description  Gets all Needs fields throughout the various objects, sorts them by the primary
     *               object type - Quote, Quote_Product, Product, Asset, Opportunity
     *
     * @author  Lawrence Coffin <lawrence.coffin@cloudsherpas.com>
     * @since   20.Oct.2014
     */
    public static Map<String,List<String>> getAllNeedsFields()
    {
        // Start with the raw Pricing needs fields (from Condition records, propagated up to Pricing Procedures)
        Map<String,String> rawNeedsFields = getRawPricingNeedsFields();
        
        // Add in/append Approval Needs Fields
        rawNeedsFields.put('VCG_CPQ_Quote__c',
                            rawNeedsFields.get('VCG_CPQ_Quote__c')
                            + ';'
                            + getRawApprovalNeedsFields());
        
        return ProcessRawNeedsFields(rawNeedsFields);
    }
    
    
    /**
     * @description  Convert 'raw' needs fields strings into sorted, unique lists by primary object
     *                
     *               'Raw' means raw list (string) of fields for - not processed for sub-assignment, not unique
     *               i.e. ';Billing_Type__c;Quote_Products__r.License_Metric_Quantity__c;;Billing_Type__c'
     *               Note: the string may contain extra ';' values, in the middle, at the start, or at the end
     *
     * @author  Lawrence Coffin <lawrence.coffin@cloudsherpas.com>
     * @since   20.Oct.2014
     */
    public static Map<String,List<String>> ProcessRawNeedsFields(Map<String,String> rawNeedsFields)
    {
        List<String> assetNeedsFields = new List<String>();
        List<String> oppNeedsFields = new List<String>();
        List<String> prodNeedsFields = new List<String>();
        List<String> quoteNeedsFields = new List<String>();
        List<String> quoteProdNeedsFields = new List<String>();
        
        //
        // Process all raw needs fields for the Quote object. The Quote object references
        // the following related objects:
        //
        //    - Quote_Products__r -- the list of quote product children
        //    - Opportunity__r -- the Opportunity
        //    - Account__r -- the Account
        //    - Other custom fields
        //
        for (String field : rawNeedsFields.get('VCG_CPQ_Quote__c').split(';'))
        {
            if (field.startsWith('Quote_Products__r'))
            {
                // Strip off the 'Quote_Products__r.'
                quoteProdNeedsFields.add(field.substring(18));
            }
            else if (field.startsWith('Opportunity__r'))
            {
                // Strip off the 'Opportunity__r.'
                oppNeedsFields.add(field.substring(15));
            }
            else if (field != null && field != '')
            {
                quoteNeedsFields.add(field);
            }
        }
        
        //
        // Process all raw needs fields for the Quote Product object. The Quote Product object references
        // the following related objects:
        //
        //    - Quote__r.Opportunity__r -- the Opportunity
        //    - Quote__r.Account__r -- the Account
        //    - Quote__r -- the list of quote product children
        //    - Other custom fields
        //
        for (String field : rawNeedsFields.get('VCG_CPQ_Quote_Product__c').split(';'))
        {
            if (field.startsWith('Quote__r.Opportunity__r'))
            {
                // Strip off the 'Opportunity__r.'
                oppNeedsFields.add(field.substring('Quote__r.Opportunity__r.'.length()));
            }
            else if (field.startsWith('Quote__r'))
            {
                // Strip off the 'Quote_Products__r.'
                quoteNeedsFields.add(field.substring('Quote__r.'.length()));
            }
            else if (field != null && field != '')
            {
                quoteProdNeedsFields.add(field);
            }
        }
        
        //
        // Return all the primary objects (Asset__c, Opportunity, Product, Quote, Quote Products)
        // with the fields needed for each
        //
        return new Map<String,List<String>>{
                                                'Asset__c' => assetNeedsFields,
                                                'Opportunity' => oppNeedsFields,
                                                'Product2' => prodNeedsFields,
                                                'VCG_CPQ_Quote__c' => quoteNeedsFields,
                                                'VCG_CPQ_Quote_Product__c' => quoteProdNeedsFields
                                           };
    }

    
    /**
     * @description  
     *               
     *
     * @author  Lawrence Coffin <lawrence.coffin@cloudsherpas.com>
     * @since   20.Oct.2014
     */
    public static Map<String,String> getRawPricingNeedsFields()
    {
        List<String> rawQuoteNeedsFields = new List<String>();
        List<String> rawQuoteProdNeedsFields = new List<String>();
        
        for (VCG_CPQ_Pricing_Procedure__c pp : [SELECT Quote_Line_Type__c, Needs_Fields__c
                                                FROM VCG_CPQ_Pricing_Procedure__c
                                                WHERE Active__c = TRUE])
        {
            if (pp.Needs_Fields__c != null && pp.Needs_Fields__c != '')
            {
                if (pp.Quote_Line_Type__c == 'Header')
                {
                    rawQuoteNeedsFields.add(pp.Needs_Fields__c);
                }
                else // an actual line type
                {
                   rawQuoteProdNeedsFields.add(pp.Needs_Fields__c);
                }
            }
        }
        
        return new Map<String,String>{
                                      'VCG_CPQ_Quote__c' => String.join(rawQuoteNeedsFields,';'),
                                      'VCG_CPQ_Quote_Product__c' => String.join(rawQuoteProdNeedsFields,';')
                                     };
    }
    
    
    /**
     * @description  
     *               'Raw' means raw list (string) of fields for - not processed for sub-assignment, not unique
     *               i.e. 'Billing_Type__c;Quote_Products__r.License_Metric_Quantity__c;Billing_Type__c'
     *
     * @author  Lawrence Coffin <lawrence.coffin@cloudsherpas.com>
     * @since   20.Oct.2014
     */
    public static Map<String,String> getRawApprovalNeedsFields()
    {
        List<String> rawQuoteNeedsFields = new List<String>();
        
        /** @todo  Add in logic to only query IsDeployed__c approval condition records unless the user is testing non-deployed rules */
        for (VCG_CPQ_Approval_Condition__c pp : [SELECT Needs_Fields__c
                                                 FROM VCG_CPQ_Approval_Condition__c
                                                 WHERE IsActive__c = TRUE])
        {
            if (pp.Needs_Fields__c != null && pp.Needs_Fields__c != '')
            {
                rawQuoteNeedsFields.add(pp.Needs_Fields__c);
            }
        }
        
        return new Map<String,String>{
                                      'VCG_CPQ_Quote__c' => String.join(rawQuoteNeedsFields,';')
                                     };
    }
    
    
    /**
     * @description  Returns a Map of all Needs Fields (top level key), and a list of what objects define the field as a Needs Field.
     * 
     * @returns  Map<String,Map<String,List<sObject>>>
     *           = {
     *              'Product__r.Product_Type__c' => {
     *                                                  'Pricing Condition' => [
     *                                                                            {VCG_CPQ_Pricing_Condition__c:Id=>...,Name=>...},
     *                                                                            {VCG_CPQ_Pricing_Condition__c:Id=>...,Name=>...},
     *                                                                            {VCG_CPQ_Pricing_Condition__c:Id=>...,Name=>...}
     *                                                                         ],
     *                                                  'Approval Condition' => [
     *                                                                            {VCG_CPQ_Approval_Condition__c:Id=>...,Name=>...},
     *                                                                            {VCG_CPQ_Approval_Condition__c:Id=>...,Name=>...},
     *                                                                            {VCG_CPQ_Approval_Condition__c:Id=>...,Name=>...}
     *                                                                         ]
     *                                              },
     *              'Account__r.BillingCountry' => {
     *                                                  'Product Filter' => [
     *                                                                            {VCG_CPQ_Product_Filter__c:Id=>...,Name=>...},
     *                                                                            {VCG_CPQ_Product_Filter__c:Id=>...,Name=>...},
     *                                                                            {VCG_CPQ_Product_Filter__c:Id=>...,Name=>...}
     *                                                                         ]
     *                                              }
     *             }
     * 
     * @author  Lawrence Coffin <lawrence.coffin@cloudsherpas.com>
     * @since   14.Apr.2015
     */
    public static Map<String,Map<String,List<sObject>>> GetNeedsFieldsSources()
    {
        Map<String,Map<String,List<sObject>>> needsFieldsSourceMap = new Map<String,Map<String,List<sObject>>>();
        
        Map<String,String> objsToQuery = new Map<String,String>{
                                                                    'Pricing Condition' => 'VCG_CPQ_Pricing_Condition__c',
                                                                    'Approval Condition' => 'VCG_CPQ_Approval_Condition__c',
                                                                    'Product Filter' => 'VCG_CPQ_Product_Filter__c',
                                                                    'Product Rule' => 'VCG_CPQ_Product_Rule__c',
                                                                    'Product Add-On' => 'VCG_CPQ_Product_Addon__c',
                                                                    'Opp to Quote Map' => 'VCG_CPQ_Opportunity_Quote_Map__c',
                                                                    'Field Layouts' => 'VCG_CPQ_Page_Layout__c'
                                                               };
        
        for (String objType : objsToQuery.keySet())
        {
            String objName = objsToQuery.get(objType);
            
            String query = 'SELECT Name, Needs_Fields__c FROM ' + objName;
            
            for (sObject obj : Database.query(query))
            {
                if (obj.get('Needs_Fields__c') != null)
                {
                    for (String needsField : String.valueOf(obj.get('Needs_Fields__c')).split(';\\s*'))
                    {
                        if (!needsFieldsSourceMap.containsKey(needsField)) needsFieldsSourceMap.put(needsField, new Map<String,List<sObject>>());
                        if (!needsFieldsSourceMap.get(needsField).containsKey(objType)) needsFieldsSourceMap.get(needsField).put(objType, new List<sObject>());
                        
                        needsFieldsSourceMap.get(needsField).get(objType).add(obj);
                        needsFieldsSourceMap.get(needsField).get(objType).sort(); // Expensive to do this here after each add, but being lazy!
                    }
                }
            }
        }
        
        return needsFieldsSourceMap;
    }
    
    
    /**
     * @description  Method for returning a list of Needs Fields for a specific object type (i.e. 'Account', 'Product', etc.)
     *
     * @todo  Update this method to pull from actual Needs Fields throughout the config setup.
     *        Note: Not sure if this would be useful for anything other than Product2 records.
     *              Primarily this is needed for Product2 records because we are currently pre-loading
     *              them into memory and referring to that data in the Quote Product records, rather than
     *              loading them on the fly when doing pricing.
     *
     * @author  Lawrence Coffin <lawrence.coffin@cloudsherpas.com>
     * @since   8.Sep.2014
     */
    public static List<String> getNeedsFields(String sObjName) {
        if (sObjName == 'Product2')
        {
            // For now, just a hard-coded list so we don't have to keep changing our code
            // elsewhere as we deploy to different orgs.
            return new List<String>{
                                       'Business_Unit__c',
                                       'Is_Mobile_Cast__c',
                                       'Is_Named_TP_User__c',
                                       'Is_Territory_Planner__c',
                                       'Negotiation_Type__c',
                                       'Product_Group__c',
                                       'Product_Type__c',
                                       'First_Year_Maintenance__c',
                                       'Recurring_Maintenance__c',
                                       'License_Type__c',
                                       'Default_Billing_Frequency__c',
                                       'Is_RNA__c',
                                       'Product_Line__c',
                                       'Discountable__c',
                                       'Is_Custom_PS__c',
                                       'Price_Uplift_Allowed__c',
                                       'Product_Group__c',
                                       'Is_Recurring_Product__c',
                                       'Standard_Cost__c'
                                   };
        }
    
        return new List<String>();
    }
}