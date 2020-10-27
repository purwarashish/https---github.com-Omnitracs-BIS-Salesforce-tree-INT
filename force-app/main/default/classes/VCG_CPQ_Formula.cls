/**
 * 
 *
 * Requested items:
 *
 *   @todo   (none at the moment)
 * 
 * @author  Lawrence Coffin <lawrence.coffin@cloudsherpas.com>
 * @since   13.Mar.2014
 */
public without sharing class VCG_CPQ_Formula {
    
    public static User loggedInUserRec;
    public static Map<String, Schema.DescribeFieldResult> userFieldsDescribed;
    
    private static Map<String,Schema.DisplayType> fieldTypeCache = new Map<String,Schema.DisplayType>();
    private static Map<String,Integer> fieldScaleCache = new Map<String,Integer>();
    
    private static Integer showDebugOutput = 0;
    
    private static void debug(String msg)
    {
        if (showDebugOutput > 0)
        {
            System.debug(LoggingLevel.ERROR, msg);
        }
    }
    
    
    /**
     * @description  This is a representation of the data structure used to store a parsed formula
     *               Technically it is not actually used since the JSON library can't handle "Object" type,
     *               but we interpret the deserialized result as this type of structure (if it's not a primitive
     *               data type directly)
     * @author  Lawrence Coffin <lawrence.coffin@cloudsherpas.com>
     * @since   13.Mar.2014
     */
    public class Node {
        String op = null;
        Object p1 = null;
        Object p2 = null;
        Object p3 = null; // Third parameter, for IF() and any other trinary operators
    }
    
    /**
     * @description
     * @author  Lawrence Coffin <lawrence.coffin@cloudsherpas.com>
     * @since   13.Mar.2014
     */
    public class Result {
        public Object obj_val = null;
        public Decimal value = null;
        public String str_val = null;
        public String type = null;
        
        public Result(Decimal val) {
            this.value = val;
            type = null;
        }
        
        public Result(Decimal val, String typ) {
            this.value = val;
            type = typ;
        }
        
        public Result(String val, String typ) {
            this.str_val = val;
            type = typ;
        }
        
        public Result(Object val, String typ) {
            this.obj_val = val;
            type = typ;
            
            /** @todo  Note: We may need to add support for DateTime values
                      here and elsewhere as well. Perhaps we convert all Dates to 
                      DateTimes so we don't have to have code to handle both? Not sure 
                      if SF will like that if we start assigning DateTimes back to 
                      Date fields or vice versa. -LC 2014-11-04 */
            if(type.toLowerCase('en_US') == 'boolean')
                this.value = (val != null && (Boolean)val ? 1 : 0);
            if(type.toLowerCase('en_US') == 'string')
                this.str_val = (String)val;
            if(type.toLowerCase('en_US') == 'id')
            {
                this.str_val = (String)val;
                this.type = 'String';
            }
        }
    }
    
    public class Formula_Exception extends Exception {}
    
    /**
     * @description  Basic formula evaluation method. Call if no object or prior references are needed
     * @author  Lawrence Coffin <lawrence.coffin@cloudsherpas.com>
     * @since   13.Mar.2014
     */
    public static Result evaluate(String formula_json) {
        return evaluate(null, null, formula_json);
    }

    /**
     * @description  Object + formula evaluation method. Call if prior calculation
     *               references are not used (i.e. no $Results references) but object references are.
     * @author  Lawrence Coffin <lawrence.coffin@cloudsherpas.com>
     * @since   13.Mar.2014
     */
    public static Result evaluate(sObject obj, String formula_json) {
        return evaluate(obj, null, null, formula_json);
    }
    
    /**
     * @description  Object + formula evaluation method. Call if prior calculation
     *               references are not used (i.e. no $Results references) but object references are.
     * @author  Lawrence Coffin <lawrence.coffin@cloudsherpas.com>
     * @since   13.Mar.2014
     */
    public static Result evaluate(sObject obj, List<Asset__c> existingAssets, String formula_json) {
        return evaluate(obj, null, existingAssets, formula_json);
    }

    /**
     * @description  Formula evaluation method for use with formulas that may have references to $Results
     * @author  Lawrence Coffin <lawrence.coffin@cloudsherpas.com>
     * @since   13.Mar.2014
     */
    public static Result evaluate(sObject obj, Map<String,Map<String,Object>> Results, List<Asset__c> existingAssets, String formula_json) {
//        System.debug('====> Running evaluate()');
//        System.debug(LoggingLevel.ERROR, '====> Results: ' + Results);
//        System.debug(LoggingLevel.ERROR, '====> Serialized Formula: ' + formula_json);
        
        if (formula_json == null)
        {
            throw new Formula_Exception('No JSON formula specified (null value)');
        }
        
        Object formula = JSON.deserializeUntyped(formula_json);
        
//        System.debug('====> formula: ' + formula);
        
        Result res = evaluate_formula_tree(obj, Results, existingAssets, formula);
        
//        System.debug(LoggingLevel.ERROR, '====> evaluate() result: ' + res);
        return res;
    }

    /**
     * @description
     * @author  Lawrence Coffin <lawrence.coffin@cloudsherpas.com>
     * @since   13.Mar.2014
     */
    private static Result evaluate_formula_tree(sObject obj, Map<String,Map<String,Object>> Results, List<Asset__c> existingAssets, Object node) {
//        System.debug(LoggingLevel.ERROR, '====> Node: ' + node);
        Result res;
        
        if (node == null) {
            /** @todo  Throw error */
            debug('====> Formula node is null/empty i.e. missing "p1", "p2", or just a "p2": with no value');
            throw new Formula_Exception('Null formula!');
        }
        else if (node instanceOf Integer) {
            // Untyped
            res = new Result((Decimal)node);
        }
        else if (node instanceOf Decimal) {
            // Untyped
            res = new Result((Decimal)node);
        }
        else if (node instanceOf String) {
            Decimal value;
            
            if (((String)node).startsWith('$Results.')) {
                // Results reference
                debug('====> Looking up $Results for ' + node);
                debug('====> From Results: ' + Results);
                if (Results == null) {
                    throw new Formula_Exception('Invalid formula reference "' + node + '" - Results not defined!');
                    return null;
                }
                else {
                    res = do_results_lookup(Results, (String)node);
                    debug('====> Results value: ' + node + ' => ' + res);
                }
            }
            else if (((String)node).startsWith('$User.')) {
                // Current User reference
                res = do_user_lookup((String)node);
            }
            else if ((String)node == 'null') {
                // Null value in a formula
                res = new Result(null);
            }
            else if ((String)node == 'true') {
                // Null value in a formula
                res = new Result(1, 'Boolean');
            }
            else if ((String)node == 'false') {
                // Null value in a formula
                res = new Result(0, 'Boolean');
            }
            else if (((String)node).startsWith('\'') && ((String)node).endsWith('\'')) {
                // String literal, copy between single quotes
                Integer len = ((String)node).length();
                String str_val = ((String)node).substring(1, len-1);
                
                debug('====> String literal: ' + str_val);
                
                res = new Result(str_val, 'String');
            }
            else {
                // String means field ref, do field lookup
//                system.debug('########### : '+obj);
//                system.debug('########### : '+node);
                Object obj_val = do_field_lookup4(obj, (String)node);
                
                if (obj_val == null)
                {
                    // Handle nulls first, want to return a null. Otherwise will return the first type
                    // listed below (null is an instance of anything). Note that null string fields will
                    // be returned as '', and null numeric fields will be returned as 0, so will be
                    // handled below.
                    res = new Result(null);
                }
                else if (obj_val instanceOf String) {
                    res = new Result((String)obj_val, 'String');
                }
                else if (obj_val instanceOf Date) {
                    res = new Result(obj_val, 'Date');
                }
                else if (obj_val instanceOf Boolean)
                {
                    res = new Result((Boolean)obj_val ? 1 : 0);
                }
                else if (obj_val instanceOf sObject)
                {
                    res = new Result(obj_val, 'sObject');
                }
                else {
                    // Assume it is a decimal
                    res = new Result((Decimal)obj_val);
                }
            }
        }
        else if (node instanceOf Map<String,Object>) {
            //   This should be a formula Node-type of map, evaluate
            
            // Turn debug output on if "_debug":"true" is set in the node/block
            if (((Map<String,Object>)node).containsKey('_debug') && ((Map<String,Object>)node).get('_debug') == 'true')
            {
                showDebugOutput++;
                debug('====> Debugging started for node: ' + node);
            }
            
            // Evaluate the node
            res = do_node_math(obj, Results, existingAssets, (Map<String,Object>)node);
            
            // Turn debug output off if "_debug":"true" is set in the node/block
            if (((Map<String,Object>)node).containsKey('_debug') && ((Map<String,Object>)node).get('_debug') == 'true')
            {
                debug('====> Result for node: ' + node + ' => ' + res);
                debug('====> Debugging done for node: ' + node);
                showDebugOutput--;
            }
            
            return res;
        }
        
        debug('====> ' + node + ' => ' + res);
        
        return res;
    }
    
    /**
     * @description
     * @author  Lawrence Coffin <lawrence.coffin@cloudsherpas.com>
     * @since   13.Mar.2014
     */
    public static Decimal do_field_lookup(sObject obj, String field_ref) {
//        System.debug('====> field_ref: ' + field_ref);
        // Note, split() expects a regex, so we need to escape the '.' to mean a literal '.', otherwise this returns an empty list
        List<String> parts = field_ref.split('\\.');
//        System.debug('====> List size: ' + parts.size());
        
        // First, pull off the last part, this is the final field ref
        String last_part = parts.remove(parts.size()-1);
//        System.debug('====> last_part: ' + last_part);
        
        sObject ref_obj = obj;
        
        // If there are other parts left, then they are child object references
        // -- traverse through the tree to get to the leaf object
        for (String this_part : parts) {
            ref_obj = (sObject)ref_obj.getSObject(this_part);
            
            if (ref_obj == null) {
                /** @todo  Throw exception */
//                System.debug('====> Reference not found: ' + this_part);
                throw new Formula_Exception('Reference object "' + this_part + '" not found! (Wanted: <' + obj.getSObjectType() + '>.' + field_ref + ')');
                return null;
            }
        }
        
        // Finally, get the field value from the leaf object
        Decimal val = (Decimal)ref_obj.get(last_part);
        if (val == null) val = 0;
        
        return val;
    }
    
    /**
     * @description  Do field lookup for String values.
     *               Note: Function now returns a null value if any part of a reference contains a null value
     *               if that is an error, needs to be caught after the function returns.
     * 
     * @author  Lawrence Coffin <lawrence.coffin@cloudsherpas.com>
     * @since   13.Mar.2014
     */
    public static String do_field_lookup2(sObject obj, String field_ref) {
//        System.debug('====> field_ref: ' + field_ref);
        // Note, split() expects a regex, so we need to escape the '.' to mean a literal '.', otherwise this returns an empty list
        List<String> parts = field_ref.split('\\.');
//        System.debug('====> List size: ' + parts.size());
        
        // First, pull off the last part, this is the final field ref
        String last_part = parts.remove(parts.size()-1);
//        System.debug('====> last_part: ' + last_part);
        
        sObject ref_obj = obj;
        
        // If there are other parts left, then they are child object references
        // -- traverse through the tree to get to the leaf object
        for (String this_part : parts) {
            ref_obj = (sObject)ref_obj.getSObject(this_part);
            
            if (ref_obj == null) {
                /** @todo  Throw exception */
//                System.debug('====> Reference not found: ' + this_part);
//                throw new Formula_Exception('Reference object "' + this_part + '" not found! (Wanted: <' + obj.getSObjectType() + '>.' + field_ref + ')');
                return null;
            }
        }
        
        // Finally, get the field value from the leaf object
//        System.debug('====> value: ' + ref_obj.get(last_part));
        String val = String.valueOf(ref_obj.get(last_part));
        if (val == null) val = '';
        
        return val;
    }
    
    /**
     * @description   Handles arbitraty objects as return value
     * @author  Lawrence Coffin <lawrence.coffin@cloudsherpas.com>
     * @since   13.Mar.2014
     */
/* No longer in use - replaced by do_field_lookup4. Commenting out to increase code coverage. -LC 2014-12-03
    public static Object do_field_lookup3(sObject obj, String field_ref) {
//        System.debug('====> field_ref: ' + field_ref);
        // Note, split() expects a regex, so we need to escape the '.' to mean a literal '.', otherwise this returns an empty list
        List<String> parts = field_ref.split('\\.');
//        System.debug('====> List size: ' + parts.size());
        
        // First, pull off the last part, this is the final field ref
        String last_part = parts.remove(parts.size()-1);
//        System.debug('====> last_part: ' + last_part);
        
        sObject ref_obj = obj;
        
        // If there are other parts left, then they are child object references
        // -- traverse through the tree to get to the leaf object
        for (String this_part : parts) {
            ref_obj = (sObject)ref_obj.getSObject(this_part);
            
            if (ref_obj == null) {
                /** @todo  Throw exception */
//                System.debug('====> Reference not found: ' + this_part);
/*                throw new Formula_Exception('Reference object "' + this_part + '" not found! (Wanted: <' + obj.getSObjectType() + '>.' + field_ref + ')');
                return null;
            }
        }
        
//        System.debug('====> ref_obj: ' + ref_obj);
        
        // Finally, get the field value from the leaf object
        Object val = (Object)ref_obj.getSObjects(last_part);
        
//        System.debug('====> val: ' + val);
        
        return val;
    }
*/    
    /**
     * @description   Handles arbitraty object as return value
     * @author  Lawrence Coffin <lawrence.coffin@cloudsherpas.com>
     * @since   13.Mar.2014
     */
    public static Object do_field_lookup4(sObject obj, String field_ref) {
//        System.debug(LoggingLevel.ERROR, '====> field_ref: ' + field_ref);
        
        // Note, split() expects a regex, so we need to escape the '.' to mean a literal '.', otherwise this returns an empty list
        List<String> parts = field_ref.split('\\.');
//        System.debug('====> Parts: ' + parts);
//        System.debug('====> List size: ' + parts.size());
        
        // First, pull off the last part, this is the final field ref
        String last_part = parts.remove(parts.size()-1);
//        System.debug('====> last_part: ' + last_part);
        
        sObject ref_obj = obj;
        
        // If there are other parts left, then they are child object references
        // -- traverse through the tree to get to the leaf object
        for (String this_part : parts) {
//            System.debug(LoggingLevel.ERROR, '====> this_part value : ' + this_part);
//            System.debug(LoggingLevel.ERROR, '====> from obj: ' + ref_obj);
//            System.debug(LoggingLevel.ERROR, '====> getSObject(this_part): ' + ref_obj.getSObject(this_part));
            ref_obj = (sObject)ref_obj.getSObject(this_part);
//            System.debug(LoggingLevel.ERROR, '====> ref_obj found: ' + ref_obj);
            if (ref_obj == null) {
                /** @todo  Throw exception */
//                System.debug(LoggingLevel.ERROR, '====> Reference not found: ' + this_part);
//                throw new Formula_Exception('Reference object "' + this_part + '" not found! (Wanted: <' + obj.getSObjectType() + '>.' + field_ref + ')');
                debug('====> Null reference found for "' + this_part + '" for field reference "' + field_ref + '", returning null');
                debug('====> Null reference is with record: ' + obj);
                return null;
            }
        }
        
//        System.debug(LoggingLevel.ERROR, '====> ref_obj: ' + ref_obj);
        
        // Finally, get the field value from the leaf object
        Object val;
        if (last_part.endsWith('__r'))
        {
            debug('====> ' + field_ref + ' => ' + (Object)ref_obj.getSObject(last_part));
            return (Object)ref_obj.getSObject(last_part);
        }
        
        // Else get the val and see if we should set a default value
        val = (Object)ref_obj.get(last_part);
        
//        System.debug(LoggingLevel.ERROR, '====> field lookup val: ' + val);
        
        Schema.DisplayType fieldType = GetFieldType(ref_obj, last_part);
//        System.debug('====> field lookup val type: ' + fieldType);
        
        // Set a default value for nulls -- null == 0 or ''
        if (val == null) {
            if (       fieldType == Schema.DisplayType.Integer
                    || fieldType == Schema.DisplayType.Double
                    || fieldType == Schema.DisplayType.Percent
                    || fieldType == Schema.DisplayType.Currency) {
                debug('====> ' + field_ref + ' is null numeric, returning 0');
                val = 0;
            }
            else if (  fieldType == Schema.DisplayType.String
                    || fieldType == Schema.DisplayType.TextArea
                    || fieldType == Schema.DisplayType.Email
                    || fieldType == Schema.DisplayType.MultiPicklist
                    || fieldType == Schema.DisplayType.Picklist) {
                debug('====> ' + field_ref + ' is null string, returning empty string');
                val = '';
            }
            
//            System.debug('====> field lookup val was null, set to: ' + val);
        }
        
        debug('====> ' + field_ref + ' => ' + val);
        
        return val;
    }
    
    /**
     * @description  Get the field type. Uses getDescribe if it is a field it hasn't seen, but caches
     *               the result for subsequent lookups. (There is a limit of 100 getDescribe calls.)
     *
     * @todo  Cache the describe call results for the object and the fields. That will make this more efficient
     *        for multiple calls to the same object or field for this, getFieldLabel, and getFieldScale.
     *
     * @author  Lawrence Coffin <lawrence.coffin@cloudsherpas.com>
     * @since   22.Mar.2014
     */
    public static Schema.DisplayType GetFieldType(sObject ref_obj, String fieldName) {
        String key = ref_obj.getSObjectType().getDescribe().getName() + '.' + fieldName;
        
        if (!fieldTypeCache.containsKey(key)) {
            if (fieldName.endsWith('__r')
                   && ref_obj.getSObjectType().getDescribe().fields.getMap().get(fieldName.replace('__r', '__c')) != null)
            {
// No Schema.DisplayType for sObjects! Don't pass in __r fields to this method for now! -LC 2.Oct.2014
//                fieldTypeCache.put(key, 'sObject');
                return null;
            }
            else if (ref_obj.getSObjectType().getDescribe().fields.getMap().get(fieldName) == null)
            {
//              List<String> allFields = new List<String>();
//              allFields.addAll(ref_obj.getSObjectType().getDescribe().fields.getMap().keySet());
//              System.debug('====> all fields: ' + String.join(allFields, ', '));
                throw new Formula_Exception('Invalid field: ' + key);
            }
            else
            {
                fieldTypeCache.put(key, ref_obj.getSObjectType().getDescribe().fields.getMap().get(fieldName).getDescribe().getType());
            }
        }
        
        return fieldTypeCache.get(key);
    }
    
    /**
     * @description   Handles arbitraty object as return value
     * 
     * @todo  Cache the final label value as well as the describe call results for the object and the fields.
     *        That will make this more efficient for multiple calls to the same object or field for this,
     *        getFieldType, and getFieldScale.
     *
     * @author  Lawrence Coffin <lawrence.coffin@cloudsherpas.com>
     * @since   13.Mar.2014
     */
    public static String getFieldLabel(String ref_obj_name, String field_ref) {
//        System.debug('====> ref_obj_name: ' + ref_obj_name);
//        System.debug('====> field_ref: ' + field_ref);
        // Note, split() expects a regex, so we need to escape the '.' to mean a literal '.', otherwise this returns an empty list
        List<String> parts = field_ref.split('\\.');
//        System.debug('====> parts: ' + parts);
        
        // First, pull off the last part, this is the final field ref
        String last_part = parts.remove(parts.size()-1);
//        System.debug('====> last_part: ' + last_part);
        
        Schema.DescribeSObjectResult ref_describe = Schema.getGlobalDescribe().get(ref_obj_name).getDescribe();
        
        // If there are other parts left, then they are child object references
        // -- traverse through the tree to get to the leaf object
        for (String this_part : parts) {
            if (this_part.endsWith('__r'))
            {
                // For fields.getMap().get() to work, we need to convert __r to __c
                this_part = this_part.replace('__r', '__c');
            }
            ref_describe = ref_describe.fields.getMap().get(this_part).getDescribe().getReferenceTo()[0].getDescribe();
            if (ref_describe == null) {
                /** @todo  Throw exception */
//                System.debug('====> Reference not found: ' + this_part);
                throw new Formula_Exception('Reference object "' + this_part + '" not found! (Wanted: <' + ref_obj_name + '>.' + field_ref + ')');
                return null;
            }
        }
        
//        System.debug('====> getting label for: ' + last_part);
try{
        return ref_describe.fields.getMap().get(last_part).getDescribe().getLabel();
}
catch(exception e)
{
    throw new Formula_Exception('Reference Field "' + last_part + '" not found! ');
}
return null;
    }
    
    
    /**
     * @description  Get the field scale (number of decimal places). Uses getDescribe if it is a field it hasn't seen,
     *               but caches the result for subsequent lookups. (There is a limit of 100 getDescribe calls.)
     * 
     * @todo  Cache the describe call results for the object and the fields. That will make this more efficient
     *        for multiple calls to the same object or field for this, getFieldLabel, and getFieldType.
     *
     * @author  Lawrence Coffin <lawrence.coffin@cloudsherpas.com>
     * @since   22.Mar.2014
     */
    public static Integer getFieldScale(sObject ref_obj, String fieldName) {
        
        // First off, if the currency is JPY/YEN, then always enforce a scale of 0 - round to a whole YEN
        if (UserInfo.isMultiCurrencyOrganization() 
                && ref_obj.getSObjectType().getDescribe().fields.getMap().get(fieldName.replace('__r', '__c')).getDescribe().getType() == Schema.DisplayType.Currency
                && ref_obj.get('CurrencyIsoCode') == 'JPY')
        {
            return 0;
        }
        
        // Otherwise, get the scale of the field
        String key = ref_obj.getSObjectType().getDescribe().getName() + '.' + fieldName;
        
        if (!fieldScaleCache.containsKey(key)) {
            if (fieldName.endsWith('__r')
                   && ref_obj.getSObjectType().getDescribe().fields.getMap().get(fieldName.replace('__r', '__c')) != null)
            {
// No Schema.DisplayType for sObjects! Don't pass in __r fields to this method for now! -LC 2.Oct.2014
//                fieldScaleCache.put(key, 'sObject');
                return 0;
            }
            else if (ref_obj.getSObjectType().getDescribe().fields.getMap().get(fieldName) == null)
            {
//              List<String> allFields = new List<String>();
//              allFields.addAll(ref_obj.getSObjectType().getDescribe().fields.getMap().keySet());
//              System.debug('====> all fields: ' + String.join(allFields, ', '));
                throw new Formula_Exception('Invalid field: ' + key);
            }
            else
            {
                fieldScaleCache.put(key, ref_obj.getSObjectType().getDescribe().fields.getMap().get(fieldName).getDescribe().getScale());
            }
        }
        
        return fieldScaleCache.get(key);
    }
    
    /**
     * @description
     * @author  Lawrence Coffin <lawrence.coffin@cloudsherpas.com>
     * @since   13.Mar.2014
     */
    public static Result do_results_lookup(Map<String, Map<String,Object>> Results, String results_ref) {
//        System.debug('====> Results: ' + Results);
//        System.debug('====> results_ref: ' + results_ref);
        // Note, split() expects a regex, so we need to escape the '.' to mean a literal '.', otherwise this returns an empty list
        List<String> parts = results_ref.split('\\.');
//        System.debug('====> List size: ' + parts.size());
        
        String key = parts[1];
        String last_part = parts[2];
//        System.debug('====> key: ' + key);
//        System.debug('====> last_part: ' + last_part);
        
        // Finally, get the field value from the leaf object
        if(Results.containsKey(key))
        {
            if (last_part.toLowerCase('en_US') == 'resultvaluestring' || last_part.toLowerCase('en_US') == 'lookupresultvaluestring')
            {
                return new Result((String)Results.get(key).get(last_part), 'String');
            }
            else if (last_part.toLowerCase('en_US') == 'resultvaluedate' || last_part.toLowerCase('en_US') == 'lookupresultvaluedate')
            {
                return new Result((Object)Results.get(key).get(last_part), 'Date');
            }
            else if (last_part.toLowerCase('en_US') == 'lookupmultiplybyquantity')
            {
                return new Result((Object)Results.get(key).get(last_part), 'Boolean');
            }
            else
            {
                return new Result((Decimal)Results.get(key).get(last_part));
            }
        }
        else
        {
            return new Result(0);
        }
    }
    
    /**
     * @description
     * @author  Lawrence Coffin <lawrence.coffin@cloudsherpas.com>
     * @since   13.Mar.2014
     */
    public static Result do_user_lookup(String user_ref) {
//        System.debug('====> user_ref: ' + user_ref);
        // Note, split() expects a regex, so we need to escape the '.' to mean a literal '.', otherwise this returns an empty list
        List<String> parts = user_ref.split('\\.');
//        System.debug('====> List size: ' + parts.size());
        
        String what = parts[1];
        
        debug('====> Looking up $User value: ' + what);
        
        Result res;
        
        if (what == 'Id') {
            res = new Result(UserInfo.getUserId(), 'String');
        }
        else if (what == 'FirstName') {
            res = new Result(UserInfo.getFirstName(), 'String');
        }
        else if (what == 'LastName') {
            res = new Result(UserInfo.getLastName(), 'String');
        }
        else
        {
            // initialize the global user variables if they haven't already been
           if(loggedInUserRec == null)
           {
                setLoggedInUserRec();
           }
          
            // throw an error if the requested field doesn't exist
          if(!userFieldsDescribed.containsKey(what.toLowerCase()))
          {
                debug('====> "' + what + '" field not found in User object');
                debug('====> User fields: ' + userFieldsDescribed.keyset());
            throw new Formula_Exception('Unknown user reference "' + user_ref  +'"');
          }
            
            debug('====> Looking up $User value: ' + what);
            res = new Result(loggedInUserRec.get(what.toLowerCase()), String.valueOf(userFieldsDescribed.get(what.toLowerCase()).getSoapType()));
          
        }
        
        debug('====> $User.' + what + ' => ' + res);
        
        return res;
    }
        
    /**
     * @description : loads a local instance of the current Logged-in User's Record and a Field description of it.
     * @author  Nathan Shinn
     * @since   30.October.2014
     */
    public static void setLoggedInUserRec()
    {
        //
        //Load userFieldsDescribed
        //
        userFieldsDescribed = new Map<String, Schema.DescribeFieldResult>();
      
        // map of all fields in the object
        Map<String, Schema.SObjectField> objectFields = User.getSObjectType().getDescribe().fields.getMap();
        list<String> userFields = new list<String>();
        
        // iterate over the User fields and get the describe info for each one. 
        // add it to a map with field name as key
        for(String field : objectFields.keySet())
        {
            Schema.DescribeFieldResult dr = objectFields.get(field).getDescribe();
            // add the results to the map to be returned
            userFieldsDescribed.put(field, dr); 
            userFields.add(field);
        }
        
        //
        // Load the User loggedInUserRec using a dunamic query based on the described field results
        //
        for(User u : (list<User>)Database.query('SELECT '
                                                    +   String.join(userFields, ', ')
                                                    + ' from User where Id = \''+UserInfo.getUserId()+'\''))
        {
            loggedInUserRec = u;
        }
    }
    
    /**
     * @description
     * @author  Lawrence Coffin <lawrence.coffin@cloudsherpas.com>
     * @since   13.Mar.2014
     */
    private static Result do_node_math(sObject obj, Map<String, Map<String,Object>> Results, List<Asset__c> existingAssets, Map<String,Object> node) {
        debug('====> do_node_math - evaluating node: ' + node);
        Result res = internal_do_node_math(obj, Results, existingAssets, node);
        debug('====> do_node_math - done evaluating node: ' + node + ' -- result: ' + res);
        return res;
    }
    private static Result internal_do_node_math(sObject obj, Map<String, Map<String,Object>> Results, List<Asset__c> existingAssets, Map<String,Object> node) {
//        System.debug('====> do_node_math: ' + node);
        String op = (String)node.get('op');
        
        //
        // Zero-ary functions and functions that we don't evaluate the first parameter for (i.e. List functions)
        // Plus a couple special functions we want to keep early in the list (Add_Product, Remove_Product)
        //
        if (op == 'TODAY') {
            Date val = Date.today();
            return new Result((Object)val, 'Date');
        }
        else if (op == 'ADD_PRODUCT') {
            // ADD_PRODUCT( <SKU>, <Quantity>, <Term Amount> [, <Asset Term Start> [, <Asset Term End>]] )
//            System.debug('====> Doing ADD_PRODUCT()');
            
            Result p1_res = evaluate_formula_tree(obj, Results, existingAssets, node.get('p1'));
//            System.debug('====> p1: ' + p1_res.str_val);
            Result p2_res = evaluate_formula_tree(obj, Results, existingAssets, node.get('p2'));
//            System.debug('====> p2: ' + p2_res.value);
            Result p3_res = evaluate_formula_tree(obj, Results, existingAssets, node.get('p3'));
//            System.debug('====> p3: ' + p3_res.value);
            
            Result asset_term_start_res, asset_term_end_res;
            if (node.get('p4') != null)
            {
                // 'p4' is asset_term_start, 'p5' is asset_term_end but both are optional
                asset_term_start_res = evaluate_formula_tree(obj, Results, existingAssets, node.get('p4'));
                debug('====> asset_term_start_res: ' + asset_term_start_res);
                
                if (node.get('p5') != null)
                {
                    asset_term_end_res = evaluate_formula_tree(obj, Results, existingAssets, node.get('p5'));
                    debug('====> asset_term_end_res: ' + asset_term_end_res);
                }
                else
                {
                    asset_term_end_res = new Result(null);
                }
            }
            else
            {
                    asset_term_start_res = new Result(null);
                    asset_term_end_res = new Result(null);
            }
            
            String sku = p1_res.str_val;
            Decimal quantity = p2_res.value;
            Decimal term_amount = p3_res.value;
            
            Product2 prod = VCG_CPQ_ProductUtility.GetProductBySku(sku);
            if(prod.Is_Groupable__c)
            {
                throw new Formula_Exception('Attempt to auto-add Product, '+prod.Name+' failed. Groupable Products are not supported at this time');
            }
            
            String productGroup = '';
            if((boolean)obj.get('Groups_Active__c') == true)
                productGroup = 'Standalone';
            
            VCG_CPQ_Quote_Product__c qp = new VCG_CPQ_Quote_Product__c(
                                                                        Name = prod.Name,
                                                                        Product__c = prod.Id,
                                                                        Product__r = prod,
                                                                        License_Metric_Quantity__c = quantity,
                                                                        Term_Amount__c = term_amount,
                                                                        Line_Type__c = 'New',
                                                                        Product_Group__c = productGroup,
                                                                        Auto_Added_QP_Line__c = true,
                                                                        Asset_Term_Start_Date__c = (Date)asset_term_start_res.obj_val,
                                                                        Asset_Term_End_Date__c = (Date)asset_term_end_res.obj_val
                                                                      );
            debug('====> Add Product record: ' + qp);
            
            return new Result((Object)qp, 'Add Product');
        }
        else if (op == 'REMOVE_PRODUCT') {
            // REMOVE_PRODUCT( <SKU> )
//            System.debug('====> Doing REMOVE_PRODUCT()');
            
            Result p1_res = evaluate_formula_tree(obj, Results, existingAssets, node.get('p1'));
//            System.debug('====> p1: ' + p1_res.str_val);
            String sku = p1_res.str_val;
            
            return new Result(sku, 'Remove Product');
        }
        else if (op == 'ADD_UPDATES') {
            //
            // ADD_UPDATES( <List>, <Line Type>, <SKU>, <Filter> )
            //
            //   <List> is either $Assets or a list related to the calling object
            //   <SKU> and <Filter> are evaluated in the context of the children records (references should be made relative to the children record)
            //
            
            debug('====> Doing ADD_UPDATES()');
            
            List<Object> recs;
            if ((String)node.get('p1') == '$Assets')
            {
                recs = existingAssets;
            }
            else
            {
                recs = VCG_CPQ_Data.getChildren(obj, (String)node.get('p1'));
            }
            
            Result lineType_res = evaluate_formula_tree(obj, Results, existingAssets, node.get('p2'));
            Object sku_formula = node.get('p3');
            Object filter = node.get('p4');
            
            List<VCG_CPQ_Quote_Product__c> newQPs = new List<VCG_CPQ_Quote_Product__c>();
            
            for (Object rec : recs) {
                Boolean match;
                
                if (filter == null || filter == '') {
                    match = true;
                }
                else {
                    Result res = evaluate_formula_tree((sObject)rec, Results, null, filter);
                    match = (res.value == 1 ? true : false);
                }
                
                if (match) {
                    String sku = evaluate_formula_tree((sObject)rec, Results, null, sku_formula).str_val;
                    Product2 prod = VCG_CPQ_ProductUtility.GetProductBySKU(sku);
                    
                    VCG_CPQ_Quote_Product__c qp = new VCG_CPQ_Quote_Product__c(
                                                                                Name = (String)(((sObject)rec).getSObject('Product__r').get('Name')),
                                                                                Product__c = prod.Id,
                                                                                Product__r = prod,
                                                                                Line_Type__c = lineType_res.str_val,
                                                                                Product_Group__c = (String)(((sObject)rec).get('Product_Group__c')),
                                                                                Auto_Added_QP_Line__c = true
                                                                              );
                    // Link QP to asset if we are iterating over the assets
                    if ((String)node.get('p1') == '$Assets')
                    {
                        qp.Asset__c = (Id)(((sObject)rec).get('Id'));
                        qp.Asset__r = (Asset__c)rec;
                    }
                    
                    debug('====> Add update QP record: ' + qp);
                    
                    newQPs.add(qp);
                }
            }
            
            debug('====> Add Updates QP records: ' + newQPs);
            
            return new Result((Object)newQPs, 'Add Updates');
        }
        else if (op == 'CLEAR_AUTO_ADDED') {
            // CLEAR_AUTO_ADDED()
//            System.debug('====> Doing CLEAR_AUTO_ADDED()');
            
            return new Result(1, 'Clear Auto-Added');
        }
        else if (op == 'SUM' && (String.valueOf(node.get('p1')).endsWith('__r') || String.valueOf(node.get('p1')) == '$Assets')) {
            // This is a list SUM formula (SUM value across a list of records), SUM of two or more values formula is below
            
            // SUM( <List>, <Field-to-sum>, <Filter> )
//            System.debug('====> Doing SUM()');
            List<Object> recs;
            if ((String)node.get('p1') == '$Assets')
            {
                recs = existingAssets;
            }
            else
            {
                recs = VCG_CPQ_Data.getChildren(obj, (String)node.get('p1'));
            }
            //String field_to_sum = (String)node.get('p2');
            Object filter = node.get('p3');
            
//            System.debug('====> List: ' + recs);
//            System.debug('====> Field_to_Sum: ' + field_to_sum);
//            System.debug('====> Filter: ' + filter);
            
            Decimal sum = 0.0000;
            
            for (Object rec : recs) {
                Boolean match;
                
                if (filter == null || filter == '') {
                    match = true;
                }
                else {
                    Result res = evaluate_formula_tree((sObject)rec, Results, null, filter);
                    match = (res.value == 1 ? true : false);
                }
                
                if (match) {
                    Result forRes = evaluate_formula_tree((sObject)rec, Results, null, node.get('p2'));                    
                    sum += forRes.value;
                }
            }
            
            return new Result(sum);
        }
        else if (op.toUpperCase('en_US') == 'MIN' && (String.valueOf(node.get('p1')).endsWith('__r') || String.valueOf(node.get('p1')) == '$Assets')) {
            // This is a list MIN formula (MIN value across a list of records), MIN of two values formula is below
            
            // MIN( <List>, <Value-to-min>, <Filter> )
//            System.debug('====> Doing MIN(<List>)');
            List<Object> recs;
            if ((String)node.get('p1') == '$Assets')
            {
                recs = existingAssets;
            }
            else
            {
                recs = VCG_CPQ_Data.getChildren(obj, (String)node.get('p1'));
            }
            //String field_to_min = (String)node.get('p2');
            Object filter = node.get('p3');
            
//            System.debug('====> List: ' + recs);
//            System.debug('====> Field_to_Min: ' + field_to_min);
//            System.debug('====> Filter: ' + filter);
            
            Decimal min = null;
            Date min_date = null;
            
            for (Object rec : recs) {
                Boolean match;
                
                if (filter == null || filter == '') {
                    match = true;
                }
                else {
                    Result res = evaluate_formula_tree((sObject)rec, Results, null, filter);
                    match = (res.value == 1 ? true : false);
                }
                
                if (match) {
                    Result forRes = evaluate_formula_tree((sObject)rec, Results, null, node.get('p2'));     
                    
                    // if min is null, always set to the first value we find
                    if (forRes.type == 'Date')
                    {
                        if (min_date == null || (Date)forRes.obj_val < min_date)
                        {
                            min_date = (Date)forRes.obj_val;
                            debug('====> New MIN Date: ' + min_date);
                        }
                    }
                    else if (min == null || forRes.value < min)
                    {
                        min = forRes.value;
                    }
                }
            }
            
            if (min_date != null)
            {
                return new Result((Object)min_date, 'Date');
            }
            
            // If min is null (meaning we didn't find a value), set a value of zero
            if (min == null) min = 0.0000;
            
            return new Result(min);
        }
        else if (op == 'MAX' && (String.valueOf(node.get('p1')).endsWith('__r') || String.valueOf(node.get('p1')) == '$Assets')) {
            // This is a list MAX formula (MAX value across a list of records), MAX of two values formula is below
            
            // MAX( <List>, <Field-to-max>, <Filter> )
//            System.debug('====> Doing MAX(<List>)');
            List<Object> recs;
            if ((String)node.get('p1') == '$Assets')
            {
                recs = existingAssets;
            }
            else
            {
                recs = VCG_CPQ_Data.getChildren(obj, (String)node.get('p1'));
            }
            //String field_to_max = (String)node.get('p2');
            Object filter = node.get('p3');
            
//            System.debug('====> List: ' + recs);
//            System.debug('====> Field_to_Max: ' + field_to_max);
//            System.debug('====> Filter: ' + filter);
            
            Decimal max = null;
            Date max_date = null;
            
            for (Object rec : recs) {
                Boolean match;
                
                if (filter == null || filter == '') {
                    match = true;
                }
                else {
                    Result res = evaluate_formula_tree((sObject)rec, Results, null, filter);
                    match = (res.value == 1 ? true : false);
                }
                
                if (match) {
                    Result forRes = evaluate_formula_tree((sObject)rec, Results, null, node.get('p2'));    
                    
                    // if max is null, always set to the first value we find
                    if (forRes.type == 'Date')
                    {
                        if (max_date == null || (Date)forRes.obj_val > max_date) max_date = (Date)forRes.obj_val;
                    }
                    else if (max == null || forRes.value > max)
                    {
                        max = forRes.value;
                    }
                }
            }
            
            if (max_date != null)
            {
                return new Result((Object)max_date, 'Date');
            }
            
            // If max is null (meaning we didn't find a value), set a value of zero
            if (max == null) max = 0.0000;
            
            return new Result(max);
        }
        else if (op == 'COUNT') {
            // COUNT( <List> [, <Filter>] )
//            System.debug('====> Doing COUNT()');
            List<Object> recs;
            if ((String)node.get('p1') == '$Assets')
            {
                debug('====> COUNT()ing over Assets: ' + existingAssets);
                recs = existingAssets;
            }
            else
            {
                recs = VCG_CPQ_Data.getChildren(obj, (String)node.get('p1'));
                debug('====> COUNT()ing over ' + (String)node.get('p1') + ': ' + recs);
            }
            Object filter = node.get('p2');
            
//            System.debug('====> List: ' + recs);
            debug('====> COUNT() num recs: ' + recs.size());
            debug('====> COUNT() filter: ' + filter);
            
            Integer count = 0;
            
            for (Object rec : recs) {
                debug('====> Checking for COUNT(): ' + rec);
                Boolean match;
                
                if (filter == null || filter == '') {
                    count++;
                }
                else {
                    Result res = evaluate_formula_tree((sObject)rec, Results, null, filter);
                    if (res.value == 1) {
                        count++;
                    }
                }
            }
            
            return new Result((Decimal)count);
        }
        else {
            // Evaluate the first parameter here to save on having to repeat it for all functions below
            Result p1_res = evaluate_formula_tree(obj, Results, existingAssets, node.get('p1'));
            
            //
            // Unary, Tertiary, and Short-Circuit binary operators
            //
            if (op == '!' || op == 'NOT') {
                // Boolean NOT, Unary
                Decimal val = ( p1_res.value == 1 ? 0 : 1 );
                
//                System.debug('===> did boolean NOT: !' + p1_res.value + ' = ' + val);
                return new Result(val);
            }
            else if (op == 'TOTAL_OWNED') 
            {
                if(VCG_CPQ_Options__c.getInstance() == null || !VCG_CPQ_Options__c.getInstance().Count_Total_Owned__c)
                {
                     throw new Formula_Exception('Total Owned Function Called but Count Total Owned custom setting set to false.');
                }
                return new Result((VCG_CPQ_PricingUtility.TotalOwned.get(p1_res.str_val)==null ? 0 : VCG_CPQ_PricingUtility.TotalOwned.get(p1_res.str_val)), 'Decimal');
            }
            else if (op == '-' && node.get('p2') == null) {
                // Unary '-' (i.e. -1, -Decommission_Quantity__c, etc.)
                Decimal val = 0 - p1_res.value;
                
                return new Result(val);
            }
            else if(op == 'FLOOR'){
                // FLOOR(<Decimal>) function, Unary
                Decimal val = math.floor(p1_res.value);
                
//                System.debug('did math.floor():' + p1_res.value + '='+ val);
                
                return new Result(val);
            }
            else if(op=='CEIL'){
                // CEIL(<Decimal>) function, Unary
                Decimal val = math.ceil(p1_res.value);
                
//                System.debug('did math.ceil():' + p1_res.value + '='+ val);
                
                return new Result(val);
            }
            else if (op == 'IF') {
                // IF( <test>, <then>, <else> ), Tertiary
                // Short-Circuit - if <test> is true, the <else> formula will not be evaluated
                //               - if <test> is false, the <then> formula will not be evaluated
                Decimal val = ( p1_res.value == 1 ? 0 : 1 );
                
                if (p1_res.value == 1) {
//                    System.debug('===> IF condition evaluated true, evaluating p2');
                    Result p2_res = evaluate_formula_tree(obj, Results, existingAssets, node.get('p2'));
                    
//                    System.debug('===> did IF - <test> == 1, p2 val: ' + p2_res.value);
                    
                    return p2_res;
                }
                else {
//                    System.debug('===> IF condition evaluated false, evaluating p3');
                    Result p3_res = evaluate_formula_tree(obj, Results, existingAssets, node.get('p3'));
                    
//                    System.debug('===> did IF - <test> == 0, p3 val: ' + p3_res.value);
                    
                    return p3_res;
                }
            }
            else if (op == '&&' || op == 'AND') {
                // Boolean AND(<Test1>,<Test2>), Binary
                // Short-Circuit - will not evaluate the second parameter formula if first parameter is false
                Decimal val = ( p1_res.value == 1 && evaluate_formula_tree(obj, Results, existingAssets, node.get('p2')).value == 1 ? 1 : 0 );
                
//                System.debug('===> did boolean AND: ' + p1_res.value + ' && ' + p2_res.value + ' = ' + val);
                
                return new Result(val, 'Boolean');
            }
            else if (op == '||' || op == 'OR') {
                // Boolean OR(<Test1>,<Test2>), Binary
                // Short-Circuit - will not evaluate the second parameter formula if first parameter is true
                Decimal val = ( p1_res.value == 1 || evaluate_formula_tree(obj, Results, existingAssets, node.get('p2')).value == 1 ? 1 : 0 );
                
//                System.debug('===> did boolean OR: ' + p1_res.value + ' || ' + p2_res.value + ' = ' + val);
                
                return new Result(val, 'Boolean');
            }
            else if (op == 'IN') {
                //
                // IN function
                //
                // <Value1> IN (<Value2> [, <Value3>[, <Value4>[ ... ]]])
                //
                //     <Value1>, <Value2>, etc. can be complex sub-formulas (if needed)
                //
                //     Up to 100 Values (including Value1) can be specified.
                //
                // Handles:
                //
                //    - Decimal values
                //    - String values
                //    - Date values
                //
                // Note: This function short-circuits... so if Value1 matches Value2, then Value3 (and later values) won't be
                //       evaluated (all values can be sub-formulas). So you need to balance between putting values that are
                //       easier to calculate vs the most common value first in the list. (Sometimes easier to compute should
                //       be first, but not if they are almost never going to be the matching value.)
                //
                // Added 2.Jan.2015 - LC
                //
                
                debug('====> Doing "IN" - target value: ' + p1_res);
                
                if (p1_res.value == null && p1_res.str_val == null && p1_res.obj_val == null)
                {
                    debug('====> p1 is null, returning false');
                    return new Result(0, 'Boolean');
                }
                
                // Walk through the rest (max of 100 to ensure no endless loop)
                for (Integer i = 2; node.get('p' + i) != null && i < 100; i++) {
                    Result res = evaluate_formula_tree(obj, Results, existingAssets, node.get('p' + i));
                    
                    debug('====> comparing to: ' + res);
                    
                    if (p1_res.type == 'String')
                    {
                        if (p1_res.str_val == res.str_val)
                        {
                            debug('====> Match! (string)');
                            return new Result(1, 'Boolean');
                        }
                    }
                    else if (p1_res.type == 'Date')
                    {
                        if (((Date)p1_res.obj_val) == ((Date)res.obj_val))
                        {
                            debug('====> Match! (Date)');
                            return new Result(1, 'Boolean');
                        }
                    }
                    else // Assume decimal
                    {
                        if (p1_res.value == res.value)
                        {
                            debug('====> Match! (decimal)');
                            return new Result(1, 'Boolean');
                        }
                    }
                }
                
                debug('====> No match found for "IN", returning false');
                return new Result(0, 'Boolean');
            }
            else {
                //
                // Binary operators
                //
                
                // NOTE: This does not do short-circuit evaluations! Keep those above
                
                // Evaluate the second parameter here to save on having to repeat it for all functions below
                Result p2_res = evaluate_formula_tree(obj, Results, existingAssets, node.get('p2'));
                
                if (op == '+') {
//                    System.debug('====> Doing \'+\': ' + node);
                    
                    if (p1_res.type == 'Date' && (p2_res.type == 'Decimal' || p2_res.type == null)) {
                        if (p1_res.obj_val == null)
                        {
                            return new Result(null);
                        }
                        else
                        {
                            Date val = ((Date)p1_res.obj_val).addDays((Integer)p2_res.value);
                            
                            return new Result((Object)val, 'Date');
                        }
                    }
                    else if ((p1_res.type == 'Decimal' || p1_res.type == null) && p2_res.type == 'Date') {
                        if (p2_res.obj_val == null)
                        {
                            return new Result(null);
                        }
                        else
                        {
                            Date val = ((Date)p2_res.obj_val).addDays((Integer)p1_res.value);
                            
                            return new Result((Object)val, 'Date');
                        }
                    }
                    else {
//                        System.debug(LoggingLevel.ERROR, '====> Doing \'+\' - node: ' + node);
//                        System.debug(LoggingLevel.ERROR, '====> Doing \'+\' - p1 == ' + p1_res);
//                        System.debug(LoggingLevel.ERROR, '====> Doing \'+\' - p2 == ' + p2_res);
                        Decimal val = p1_res.value + p2_res.value;
//                        System.debug('===> did add: ' + p1_res.value + ' + ' + p2_res.value + ' = ' + val);
                        return new Result(val);
                    }
                }
                else if (op == '-') {
                    if (p1_res.type == 'Date' && (p2_res.type == 'Decimal' || p2_res.type == null)) {
                        if (p1_res.obj_val == null)
                        {
                            return new Result(null);
                        }
                        else
                        {
                            Date val = ((Date)p1_res.obj_val).addDays(0 - (Integer)p2_res.value);
                            
                            return new Result((Object)val, 'Date');
                        }
                    }
                    else if ((p1_res.type == 'Decimal' || p1_res.type == null) && p2_res.type == 'Date') {
                        if (p2_res.obj_val == null)
                        {
                            return new Result(null);
                        }
                        else
                        {
                            Date val = ((Date)p2_res.obj_val).addDays(0 - (Integer)p1_res.value);
                            
                            return new Result((Object)val, 'Date');
                        }
                    }
                    else {
                        Decimal val = p1_res.value - p2_res.value;
//                        System.debug('===> did subtract: ' + p1_res.value + ' - ' + p2_res.value + ' = ' + val);
                        return new Result(val);
                    }
                }
                else if (op == '*') {
//                  if (p1_res == null || p1_res.value == null || p1_res.value == 0 || p2_res == null || p2_res.value == null || p2_res.value == 0)
//                  {
//                        System.debug(LoggingLevel.ERROR, '====> Doing \'*\' - Results: ' + Results);
//                        System.debug(LoggingLevel.ERROR, '====> Doing \'*\' - node: ' + node);
//                        System.debug(LoggingLevel.ERROR, '====> Doing \'*\' - p1 == ' + p1_res);
//                        System.debug(LoggingLevel.ERROR, '====> Doing \'*\' - p2 == ' + p2_res);
//                  }
                    Decimal val = p1_res.value * p2_res.value;
//                    System.debug('===> did multiply: ' + p1_res.value + ' * ' + p2_res.value + ' = ' + val);
                    return new Result(val);
                }
                else if (op == '/') {
                    /** @todo  Need to handle divide by zero circumstance here */
                    if (p2_res.value == 0) {
                        System.debug('====> Divide by zero on node: ' + node);
                        return new Result(0);
//                        throw new Formula_Exception('Divide by zero!');
                    }
                    
                    Decimal val = p1_res.value / p2_res.value;
//                    System.debug('===> did divide: ' + p1_res.value + ' / ' + p2_res.value + ' = ' + val);
                    return new Result(val);
                }
                else if (op == 'POW' || op == '^') {
                    // POW operator (aka '^' as in "2^3")
                    
                    Decimal val = (Decimal)Math.pow((Double)p1_res.value, (Double)p2_res.value);
                    
//                    System.debug('===> did Math.pow(' + p1_res.value + ',' + p2_res.value +')' + ' = ' + val );
                    return new Result(val);
                }
                else if (op == 'ROUND') {
                    // ROUND operator rounds a number to a specified number of digits. 
                    
                    Decimal val = ((Decimal)p1_res.value).setScale((Integer)p2_res.value, RoundingMode.HALF_UP);
                    
//                  System.debug('===> did Math.round(' + p1_res.value + ',' + p2_res.value +')' + ' = ' + val );
                    return new Result(val);
                }
                else if (op == 'MOD' || op == '%') {
                    // MOD operator (aka '%' as in "13%10")
                    
//                    System.debug(LoggingLevel.ERROR, '===> doing Math.mod(' + p1_res.value + ',' + p2_res.value +')');
                    
                    Decimal val = (Decimal)Math.mod((Integer)Math.floor((Decimal)p1_res.value), (Integer)Math.floor((Decimal)p2_res.value));
                    
//                    System.debug(LoggingLevel.ERROR, '===> did Math.mod(' + p1_res.value + ',' + p2_res.value +')' + ' = ' + val );
                    return new Result(val);
                }
                else if (op == '==') {
                    // Equals comparison operator
                    Decimal val = null;
                    
//                    System.debug('===> doing equals comparison between types ' + p1_res.type + ' and ' + p2_res.type);
                    
                    if (p1_res.type == 'String' && p2_res.type == null) {
                        val = ( p1_res.str_val == null || p1_res.str_val == '' ? 1 : 0 );
                    }
                    else if (p1_res.type == null && p2_res.type == 'String') {
                        val = ( p2_res.str_val == null || p2_res.str_val == '' ? 1 : 0 );
                    }
                    else if (p1_res.type == 'String' && p2_res.type == 'String') {
                        // Do en_US case folding (to avoid issues with Turkish 'I's)
                        val = ( p1_res.str_val.toLowerCase('en_US') == p2_res.str_val.toLowerCase('en_US') ? 1 : 0 );
                        
//                        System.debug('===> did String equals comparison: ' + p1_res.str_val + ' == ' + p2_res.str_val + ' = ' + val);
                    }
                    else if (p1_res.type == 'Date' && p2_res.type == 'Date') {
                        val = ( (Date)p1_res.obj_val == (Date)p2_res.obj_val ? 1 : 0 );
                        
//                        System.debug('===> did Date equals comparison: ' + p1_res.str_val + ' == ' + p2_res.str_val + ' = ' + val);
                    }
                    else if (p1_res.type == 'Date' && p2_res.type == null && p2_res.value == null) {
                        val = ( p1_res.obj_val == null ? 1 : 0 );
                    }
                    else if (p2_res.type == 'Date' && p1_res.type == null && p1_res.value == null) {
                        val = ( p2_res.obj_val == null ? 1 : 0 );
                    }
                    else if (p1_res.type == 'sObject') {
                        // For sObjects we only allow comparison to null!
                        if (p2_res.type == null && p2_res.value == null && p1_res.obj_val == null)
                        {
                            val = 1;
                        }
                        else
                        {
                            val = 0;
                        }
//                        System.debug('====> Got sObject == null comparison: ' + val);
                    }
                    else if (p2_res.type == 'sObject') {
                        // For sObjects we only allow comparison to null!
                        if (p1_res.type == null && p1_res.value == null && p2_res.obj_val == null)
                        {
                            val = 1;
                        }
                        else
                        {
                            val = 0;
                        }
//                        System.debug('====> Got null == sObject comparison: ' + val);
                    }
                    else {
                        val = ( p1_res.value == p2_res.value ? 1 : 0 );
                        
//                        System.debug('===> did Decimal equals comparison: ' + p1_res.value + ' == ' + p2_res.value + ' = ' + val);
                    }
                    
                    return new Result(val, 'Boolean');
                }
                else if (op == '!=') {
                    // Not Equals comparison operator
                    Decimal val = null;
                    
//                    System.debug('===> doing not equals comparison between types ' + p1_res.type + ' and ' + p2_res.type);
                    
                    if (p1_res.type == 'String' && p2_res.type == 'String') {
                        // Do en_US case folding (to avoid issues with Turkish 'I's)
                        val = ( p1_res.str_val.toLowerCase('en_US') != p2_res.str_val.toLowerCase('en_US') ? 1 : 0 );
                        
//                        System.debug('===> did String not equals comparison: ' + p1_res.str_val + ' != ' + p2_res.str_val + ' = ' + val);
                    }
                    else if (p1_res.type == 'Date' && p2_res.type == 'Date') {
                        val = ( (Date)p1_res.obj_val != (Date)p2_res.obj_val ? 1 : 0 );
                        
//                        System.debug('===> did Date not equals comparison: ' + p1_res.str_val + ' != ' + p2_res.str_val + ' = ' + val);
                    }
                    else if (p1_res.type == 'Date' && p2_res.type == null && p2_res.value == null) {
                        val = ( p1_res.obj_val != null ? 1 : 0 );
                    }
                    else if (p2_res.type == 'Date' && p1_res.type == null && p1_res.value == null) {
                        val = ( p2_res.obj_val != null ? 1 : 0 );
                    }
                    else if (p1_res.type == 'sObject') {
                        // For sObjects we only allow comparison to null!
                        if (p2_res.type == null && p2_res.value == null && p1_res.obj_val == null)
                        {
                            val = 0;
                        }
                        else
                        {
                            val = 1;
                        }
//                        System.debug('====> Got sObject != null comparison: ' + val);
                    }
                    else if (p2_res.type == 'sObject') {
                        // For sObjects we only allow comparison to null!
                        if (p1_res.type == null && p1_res.value == null && p2_res.obj_val == null)
                        {
                            val = 0;
                        }
                        else
                        {
                            val = 1;
                        }
//                        System.debug('====> Got null != sObject comparison: ' + val);
                    }
                    else {
                        val = ( p1_res.value != p2_res.value ? 1 : 0 );
                        
//                        System.debug('===> did Decimal not equals comparison: ' + p1_res.value + ' != ' + p2_res.value + ' = ' + val);
                    }
                    
                    return new Result(val, 'Boolean');
                }
                else if (op == '>') {
                    // Greater Than comparison operator - numeric only!
                    Decimal val;
                    
                    if (p1_res.type == 'Date' && p2_res.type == 'Date') {
                        val = ( (Date)p1_res.obj_val > (Date)p2_res.obj_val ? 1 : 0 );
                        
//                        System.debug('===> did Date equals comparison: ' + p1_res.str_val + ' == ' + p2_res.str_val + ' = ' + val);
                    }
                    else
                    {
                        val = ( p1_res.value > p2_res.value ? 1 : 0 );
                    }
                    
//                    System.debug('===> did greater than comparison: ' + p1_res.value + ' > ' + p2_res.value + ' = ' + val);
                    
                    return new Result(val, 'Boolean');
                }
                else if (op == '<') {
                    // Less Than comparison operator - numeric only!
                    Decimal val;
                    
                    if (p1_res.type == 'Date' && p2_res.type == 'Date') {
                        val = ( (Date)p1_res.obj_val < (Date)p2_res.obj_val ? 1 : 0 );
                        
//                        System.debug('===> did Date equals comparison: ' + p1_res.str_val + ' == ' + p2_res.str_val + ' = ' + val);
                    }
                    else
                    {
                        val = ( p1_res.value < p2_res.value ? 1 : 0 );
                    }
                    
//                    System.debug('===> did less than comparison: ' + p1_res.value + ' < ' + p2_res.value + ' = ' + val);
                    
                    return new Result(val, 'Boolean');
                }
                else if (op == '>=') {
                    // Greater Than or Equals comparison operator - numeric only!
                    Decimal val;
                    
                    if (p1_res.type == 'Date' && p2_res.type == 'Date') {
                        val = ( (Date)p1_res.obj_val >= (Date)p2_res.obj_val ? 1 : 0 );
                        
//                        System.debug('===> did Date equals comparison: ' + p1_res.str_val + ' == ' + p2_res.str_val + ' = ' + val);
                    }
                    else
                    {
                        val = ( p1_res.value >= p2_res.value ? 1 : 0 );
                    }
                    
//                    System.debug('===> did greater thanor equals  comparison: ' + p1_res.value + ' >= ' + p2_res.value + ' = ' + val);
                    
                    return new Result(val, 'Boolean');
                }
                else if (op == '<=') {
                    // Less Than or Equals comparison operator - numeric only!
                    Decimal val;
                    
                    if (p1_res.type == 'Date' && p2_res.type == 'Date') {
                        val = ( (Date)p1_res.obj_val <= (Date)p2_res.obj_val ? 1 : 0 );
                        
//                        System.debug('===> did Date equals comparison: ' + p1_res.str_val + ' == ' + p2_res.str_val + ' = ' + val);
                    }
                    else
                    {
                        val = ( p1_res.value <= p2_res.value ? 1 : 0 );
                    }
                    
//                    System.debug('===> did less than or equals comparison: ' + p1_res.value + ' <= ' + p2_res.value + ' = ' + val);
                    
                    return new Result(val, 'Boolean');
                }
                else if(op=='MAX'){
                    //max comparison operator
                     Decimal val = Math.max(p1_res.value,p2_res.value);
                     
//                     System.debug('===> did Math.max(' + p1_res.value+',' + p2_res.value +')' + ' = ' + val );
                     
                     return new Result(val);
                }
                else if (op.toUpperCase('en_US') == 'MIN') {
                    // min comparison operator
                    if (p1_res.type == 'Date' || p2_res.type == 'Date')
                    {
                        if (p1_res.obj_val == null)
                        {
                            return p2_res;
                        }
                        else if (p2_res.obj_val == null || (Date)(p1_res.obj_val) < (Date)(p2_res.obj_val))
                        {
                            return p1_res;
                        }
                        else
                        {
                            return p2_res;                            
                        }
                    }
                    else
                    {
                        Decimal val = Math.min(p1_res.value,p2_res.value);
                        
//                        System.debug('===> did Math.min(' + p1_res.value+',' + p2_res.value +')' + ' = ' + val );
                        return new Result(val);
                    }
                }
                else if (op == '&') {
                    //String concatenation operator
                    String val =   ( p1_res.type == 'String' ? p1_res.str_val : String.valueOf(p1_res.value) )
                                 + ( p2_res.type == 'String' ? p2_res.str_val : String.valueOf(p2_res.value) );
//                    System.debug('===> did Text Concatenate: ' + p1_res.str_val + '&' + p2_res.str_val  + ' = ' + val );
                    
                    return new Result(val,'String');
                }
                else if (op == 'JOIN') {
                    // String JOIN operator, max of 100 parameters per below loop limit, takes decimal or string types
                    // NOW skips null values
                    List<String> parts = new List<String>();
                    
                    String sep = ( p1_res.type == 'String' ? p1_res.str_val : String.valueOf(p1_res.value) );
                    
                    // Start with the first item to join together
                    if (p2_res.str_val != null || p2_res.value != null)
                    {
                        parts.add( p2_res.type == 'String' ? p2_res.str_val : String.valueOf(p2_res.value) );
                    }
                    
                    // Walk through the rest (max of 100 to ensure no endless loop)
                    for (Integer i = 3; node.get('p' + i) != null && i < 100; i++) {
                        Result res = evaluate_formula_tree(obj, Results, existingAssets, node.get('p' + i));
                        if (res.str_val != null || res.value != null)
                        {
                            parts.add( res.type == 'String' ? res.str_val : String.valueOf(res.value) );
                        }
                    }
                    
//                    System.debug('===> did Text JOIN: ' + val );
                    
                    if (parts.size() > 0)
                    {
                        return new Result(String.join(parts, sep), 'String');
                    }
                    else
                    {
                        return new Result('', 'String');
                    }
                }
                else if (op == 'SUM') {
                    // Non-list SUM function -- SUM up two or more parameters (max of 100 parameters per below loop limit)
                    // Takes decimal types
                    
                    Decimal val = 0;
                    
                    // Add the first two parameters (which are required and will have been evaluated above)
                    val += p1_res.value;
                    val += p2_res.value;
                    
                    // Walk through the rest (max of 100 to ensure no endless loop)
                    for (Integer i = 3; node.get('p' + i) != null && i < 100; i++) {
                        Result res = evaluate_formula_tree(obj, Results, existingAssets, node.get('p' + i));
                        val += res.value;
                    }
                    
//                    System.debug('===> did non-list SUM: ' + val );
                    
                    return new Result(val);
                }
                else if (op == 'INCLUDES') {
                    // Multi-select Picklist (-like) formula (really works on any String input)
                    String val = null;
                    if (p1_res.type == 'String' && p1_res.str_val != null
                            && p2_res.type == 'String' && p2_res.str_val != null) {
                        List<String> parts = p1_res.str_val.split(';');
                        
                        for (String part : parts) {
                            if (part == p2_res.str_val) {
                                // Got a match
                                return new Result(1,'Boolean');
                            }
                        }
                    }
                    
                    // No match (or wrong types), return false
                    return new Result(0, 'Boolean');
                }
                else if (op == 'DAYSBETWEEN') {
                    // Days between two dates - earlier date should be first
                    // Note that this does not count the end date as part of the date... i.e. DAYSBETWEEN(Jan 1, Jan 31) means
                    // Midnight Jan 1st to Midnight Jan 31st ... or 30 days (in other words, Jan 1 inclusive to Jan 31st exclusive).
                    // Use NUMDAYS() to get number of days covered ... i.e. Midnight Jan 1st to Midnight Feb 1st.
                    Decimal val = 0.00;
                    
                    if (p1_res.obj_val != null && p2_res.obj_val != null
                            && p1_res.obj_val instanceOf Date && p2_res.obj_val instanceOf Date) {
                        // Note that <Date>daysBetween() expects the earlier date to be the caller and the later day to be
                        // the method parameter
                        val = (Decimal)((Date)p1_res.obj_val).daysBetween((Date)p2_res.obj_val);
//                        System.debug('===> did DAYSBETWEEN(' + p1_res.value + ', ' + p2_res.value  + ') = ' + val );
                    }
                    
                    return new Result(val, 'Decimal');
                }
                else if (op == 'NUMDAYS') {
                    // Number of days that two dates cover - earlier date should be first
                    // This is exactly the same as DAYSBETWEEN(D1, D2 + 1) -- the difference is that
                    // NUMDAYS(1-Jan-2000, 1-Jan-2000) == 1, whereas DAYSBETWEEN(1-Jan-2000, 1-Jan-2000) == 0)
                    // In other words NUMDAYS is *inclusive* of both days.
                    // This function is designed to give you the number of days covered, i.e. Jan 1 to Jan 31
                    // is 31 days, (daysbetween would == 30)
                    Decimal val = 0.00;
                    
                    if (p1_res.obj_val != null && p2_res.obj_val != null
                            && p1_res.obj_val instanceOf Date && p2_res.obj_val instanceOf Date) {
                        // Note that <Date>daysBetween() expects the earlier date to be the caller and the later day to be
                        // the method parameter
                        val = (Decimal)((Date)p1_res.obj_val).daysBetween((Date)p2_res.obj_val) + 1;
//                        System.debug('===> did NUMDAYS(' + p1_res.value + ', ' + p2_res.value  + ') = ' + val );
                    }
                    
                    return new Result(val, 'Decimal');
                }
                else if (op == 'NUMMONTHS') {
                    // Number of months that two dates cover - earlier date should be first
                    Decimal val = 0.00;
                    
                    if (p1_res.obj_val != null && p2_res.obj_val != null
                            && p1_res.obj_val instanceOf Date && p2_res.obj_val instanceOf Date) {
                        // Note that <Date>daysBetween() expects the earlier date to be the caller and the later day to be
                        // the method parameter.
                        // Do +1 so the last day is included in the calculation (i.e. Jan 1 to Jan 2 is 2 days, not 1)
                        Decimal numDays = (Decimal)((Date)p1_res.obj_val).daysBetween((Date)p2_res.obj_val) + 1;
//                        System.debug('====> numDays: ' + numDays);
                        
                        // Fractional months is numDays / (365/12), which is (numDays * 12) / 365 ... the latter handles imprecision better
                        // Use 365.25 to get better precision over several years (which is likely to include leap days)
                        Decimal fractionalMonths = (numDays * 12.0) / 365.25; // number of whole and partial months between the two days... I.e. 45 days is roughly 1.5 months)
//                        System.debug('====> fractionalMonths: ' + fractionalMonths);
                        
                        Decimal wholeMonths = Math.floor(fractionalMonths + 0.5); // Round to nearest whole month
//                        System.debug('====> wholeMonths: ' + wholeMonths);
                        
                        val = wholeMonths;
//                        System.debug('===> did NUMMONTHS(' + p1_res.value + ', ' + p2_res.value  + ') = ' + val );
                    }
                    
                    return new Result(val, 'Decimal');
                }
/*                else if (op == 'NUMMONTHS1') {
                    // Number of months that two dates cover - earlier date should be first
                    // In other words NUMMONTHS is *inclusive* of both start and end months.
                    // This function is designed to give you the number of months covered,
                    // i.e. Jan 1 to Dec 31 is 12 months
                    Decimal val = 0.00;
                    
                    if (p1_res.obj_val != null && p2_res.obj_val != null
                            && p1_res.obj_val instanceOf Date && p2_res.obj_val instanceOf Date) {
                        // Note that <Date>daysBetween() expects the earlier date to be the caller and the later day to be
                        // the method parameter
                        val = (Decimal)((Date)p1_res.obj_val).monthsBetween((Date)p2_res.obj_val) + 1;
//                        System.debug('===> did NUMMONTHS(' + p1_res.value + ', ' + p2_res.value  + ') = ' + val );
                    }
                    
                    return new Result(val, 'Decimal');
                }
*/
                else if (op == 'ADDMONTHS') {
//                    debug('====> Doing \'ADDMONTHS\': ' + node);
//                    debug('====> p1.type: ' + p1_res.type);
//                    debug('====> p2.type: ' + p2_res.type);
//                    System.debug('====> Date: ' + (Date)p1_res.obj_val);
//                    System.debug('====> Num Months: ' + (Integer)p2_res.value);
                    
                    // Newer version of null handling. Complains if first parameter is null. In Apex API 31.0 and lower 'null instanceOf ...' always returned true, so we do an explicit check for null here. (pre 2015-05-20)
                    if (p1_res.type != 'Date' && (p1_res.obj_val == null || !(p1_res.obj_val instanceOf Date)))
                    {
                        throw new Formula_Exception('ADDMONTHS first parameter should be of type Date!');
                    }
                    else if (p2_res.type != 'Decimal' && p2_res.type != null)
                    {
                        throw new Formula_Exception('ADDMONTHS second parameter should be of type Decimal!');
                    }
                    else
                    {
                        Date val = ((Date)p1_res.obj_val).addMonths((Integer)p2_res.value);
                        
                        return new Result((Object)val, 'Date');
                    }
                }
            }
        }
        
        /** @todo  Throw error if unknown operator */
//        System.debug('====> Unknown operator, returning null!');
        throw new Formula_Exception('Unknown operator "' + op + '"!');
        return null;
    }
    
    
    /**
     * @description  Unit Test helper class for building formula strings - One parameter
     *
     * @author  Lawrence Coffin <lawrence.coffin@cloudsherpas.com>
     * @since   13.Oct.2014
     */
     public static String F(String op, Object p1)
     {
         return '{'
                +   '"op":"' + op
                + '","p1":' + (p1 instanceOf String ? (((String)p1).startsWith('{') ? p1 : '"' + p1 + '"') : String.valueOf(p1))
                + '}';
     }
    
    
    /**
     * @description  Unit Test helper class for building formula strings - Two parameter
     *
     * @author  Lawrence Coffin <lawrence.coffin@cloudsherpas.com>
     * @since   13.Oct.2014
     */
     public static String F(String op, Object p1, Object p2)
     {
         return '{'
                +   '"op":"' + op
                + '","p1":' + (p1 instanceOf String ? (((String)p1).startsWith('{') ? p1 : '"' + p1 + '"') : String.valueOf(p1))
                +  ',"p2":' + (p2 instanceOf String ? (((String)p2).startsWith('{') ? p2 : '"' + p2 + '"') : String.valueOf(p2))
                + '}';
     }
    
    
    /**
     * @description  Unit Test helper class for building formula strings - Three parameter
     *
     * @author  Lawrence Coffin <lawrence.coffin@cloudsherpas.com>
     * @since   13.Oct.2014
     */
     public static String F(String op, Object p1, Object p2, Object p3)
     {
         return '{'
                +   '"op":"' + op 
                + '","p1":' + (p1 instanceOf String ? (((String)p1).startsWith('{') ? p1 : '"' + p1 + '"') : String.valueOf(p1))
                +  ',"p2":' + (p2 instanceOf String ? (((String)p2).startsWith('{') ? p2 : '"' + p2 + '"') : String.valueOf(p2))
                +  ',"p3":' + (p3 instanceOf String ? (((String)p3).startsWith('{') ? p3 : '"' + p3 + '"') : String.valueOf(p3))
                + '}';
     }
    
    
    /**
     * @description  Unit Test helper class for building formula strings - Four parameter
     *
     * @author  Lawrence Coffin <lawrence.coffin@cloudsherpas.com>
     * @since   13.Oct.2014
     */
     public static String F(String op, Object p1, Object p2, Object p3, Object p4)
     {
         return '{'
                +   '"op":"' + op 
                + '","p1":' + (p1 instanceOf String ? (((String)p1).startsWith('{') ? p1 : '"' + p1 + '"') : String.valueOf(p1))
                +  ',"p2":' + (p2 instanceOf String ? (((String)p2).startsWith('{') ? p2 : '"' + p2 + '"') : String.valueOf(p2))
                +  ',"p3":' + (p3 instanceOf String ? (((String)p3).startsWith('{') ? p3 : '"' + p3 + '"') : String.valueOf(p3))
                +  ',"p4":' + (p4 instanceOf String ? (((String)p4).startsWith('{') ? p4 : '"' + p4 + '"') : String.valueOf(p4))
                + '}';
     }
    
    
    /**
     * @description  Unit Test helper class for building formula strings - Five parameter
     *
     * @author  Lawrence Coffin <lawrence.coffin@cloudsherpas.com>
     * @since   13.Oct.2014
     */
     public static String F(String op, Object p1, Object p2, Object p3, Object p4, Object p5)
     {
         return '{'
                +   '"op":"' + op 
                + '","p1":' + (p1 instanceOf String ? (((String)p1).startsWith('{') ? p1 : '"' + p1 + '"') : String.valueOf(p1))
                +  ',"p2":' + (p2 instanceOf String ? (((String)p2).startsWith('{') ? p2 : '"' + p2 + '"') : String.valueOf(p2))
                +  ',"p3":' + (p3 instanceOf String ? (((String)p3).startsWith('{') ? p3 : '"' + p3 + '"') : String.valueOf(p3))
                +  ',"p4":' + (p4 instanceOf String ? (((String)p4).startsWith('{') ? p4 : '"' + p4 + '"') : String.valueOf(p4))
                +  ',"p5":' + (p5 instanceOf String ? (((String)p5).startsWith('{') ? p5 : '"' + p5 + '"') : String.valueOf(p5))
                + '}';
     }
    
    
}