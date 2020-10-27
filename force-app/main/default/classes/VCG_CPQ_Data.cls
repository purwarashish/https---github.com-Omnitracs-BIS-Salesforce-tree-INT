/**
 * This class implements a way to handle Parent-to-Children references the same whether the children
 * are generated in-memory, or if they are loaded from the database.
 *
 * Background:  Salesforce provides a nice data model for storing relationships from child-to-parent
 *              and from parent-to-child, if loading the data from the database. The related object(s)
 *              are accessed through a relationship 'field' such as Contact.Account, Account.Contacts,
 *              VCG_CPQ_Quote_Product__c.Quote__r, and VCG_CPQ_Quote__c.Quote_Products__r.
 *              Once retrieved from the database using a SOQL query like the following:
 *                
 *                  SELECT FirstName, LastName, Account.Name FROM Contact
 *                  SELECT Name, (SELECT FirstName, LastName FROM Contacts) FROM Account
 *
 *              the related objects can be accessed through the relationship reference on the
 *              sObject ... I.e.:
 *
 *                  String accountName = c.Account.Name;
 *                  String contactName = a.Contacts[0].FirstName + ' ' + a.Contacts[0].LastName;
 *             
 *              When building data in-memory, child-to-parent relationship fields can be assigned
 *              to and then subsequently accessed in the same way:
 *             
 *                  Account a = new Account( Name = 'Test Account' );
 *                  Contact c = new Contact( FirstName = 'John', LastName = 'Doe', Account = a );
 *
 *                  String accountName = c.Account.Name;
 *
 *              However, Salesforce does not allow you to assign to parent-to-children relationship
 *              so you are not able to do the following:
 *
 *                  Account a = new Account( Name = 'Test Account' );
 *                  Contact c = new Contact( FirstName = 'John', LastName = 'Doe' );
 *
 *                  a.Contacts.add(c); // This *does* execute and does not generate an error, however ...
 *
 *                  System.assertEquals(1, a.Contacts.size()); // This fails ... size() is zero
 *             
 *              The reason for this is that a.Contacts (or a.get('Contacts')) returns a *clone*
 *              of the contact list, so the new contact is added to the cloned list, but the
 *              modified list is then silently (and not obviously) discarded, so the new contact
 *              is never added to the real Contacts list. Subsequent accesses to a.Contacts will
 *              continue to return the original, empty list.
 *
 *              To get around this limitation, and to be able to treat the data the same whether
 *              it comes from the database or from in-memory, we have developed this class.
 *
 *              All accesses to get the children is through the helper method:
 *       
 *                  VCG_CPQ_Data.getChildren()
 *
 *              This method can be used to get children selected through the subquery SOQL as
 *              shown above, or it can be used to get children generated in-memory, by using the
 *
 *                  VCG_CPQ_Data.addChild()
 *
 *              or
 *
 *                  VCG_CPQ_Data.addChildren()
 *
 *              methods.
 *
 *              Using these helper methods allows the code that needs to access the children
 *              records to use the same method, regardless of the source of the data.
 *
 *              To add data generated in-memory, use the addChild() method like:
 *
 *                  Account a = new Account( Name = 'Test Account' );
 *                  Contact c = new Contact( FirstName = 'John', LastName = 'Doe' );
 *
 *                  VCG_CPQ_Data.addChild(a, 'Contacts', c);
 *
 *                  System.assertEquals(1, VCG_CPQ_Data.getChildren(a, 'Contacts').size());
 *             
 *              or the addChildren() method like:
 *
 *                  Account a = new Account( Name = 'Test Account' );
 *                  List<Contact> contacts = new List<Contact>();
 *                  contacts.add(new Contact( FirstName = 'John', LastName = 'Doe' ));
 *                  contacts.add(new Contact( FirstName = 'Jane', LastName = 'Doe' ));
 *
 *                  VCG_CPQ_Data.addChildren(a, 'Contacts', contacts);
 *
 *                  System.assertEquals(2, VCG_CPQ_Data.getChildren(a, 'Contacts').size());
 *              
 *              NOTE: In order for this to work, the parent record *must* have a key definition
 *              defined in the getKey() method below. This should be a unique identifier for
 *              the parent record within the context of the application. It also should handle
 *              parent records that *are not yet saved to the database* -- this means that the
 *              standard Salesforce Id *can not* be used as the identifier. For some applications,
 *              the Name field may be unique enough, however, be aware that clones, or copies
 *              of the same object with the same Name field will cause collisions if the copy is
 *              used within the same application. In general, it is best to use only one
 *              parent record at a time with this, unless you are sure that the key will be
 *              a unique key for all records that may be handled.
 *
 * @author  Lawrence Coffin <lawrence.coffin@cloudsherpas.com>
 * @since   27.Mar.2014
 */
public without sharing class VCG_CPQ_Data {
    private static Map<String,Map<String,List<sObject>>> childrenMap = new Map<String,Map<String,List<sObject>>>();
    
    public static void addChild(sObject parentObj, String childRef, sObject childObj) {
        String key = getKey(parentObj);
        
        if (!childrenMap.containsKey(key)) {
            // Not currently storing any children for this parent object, add a map for the parentObj
            childrenMap.put(key, new Map<String,List<sObject>>());
        }
        
        if (!childrenMap.get(key).containsKey(childRef)) {
            // Not currently storing any children for parentObj.childRef, add a list, initialize it
            // to parentObj.getSObjects(childRef) to handle the case where we have some from-database
            // children
            childrenMap.get(key).put(childRef, parentObj.getSObjects(childRef));
            
            if (childrenMap.get(key).get(childRef) == null) {
                 childrenMap.get(key).put(childRef, new List<sObject>());
            }
        }
        
        childrenMap.get(key).get(childRef).add(childObj);
    }
    
    public static void setChildren(sObject parentObj, String childRef, List<sObject> childrenObjs) {
        String key = getKey(parentObj);
        
        // Add or replace the map for the parentObj
        childrenMap.put(key, new Map<String,List<sObject>>());
        
        // Now just use addChildren
        addChildren(parentObj, childRef, childrenObjs);
    }
    
    public static void addChildren(sObject parentObj, String childRef, List<sObject> childrenObjs) {
        String key = getKey(parentObj);
        
        if (!childrenMap.containsKey(key)) {
            // Not currently storing any children for this parent object, add a map for the parentObj
            childrenMap.put(key, new Map<String,List<sObject>>());
        }
        
        if (!childrenMap.get(key).containsKey(childRef)) {
            // Not currently storing any children for parentObj.childRef, add a list, initialize it
            // to parentObj.getSObjects(childRef) to handle the case where we have some from-database
            // children
            /** @todo  Can we get rid of this try catch and have an actual test here to see if childRef exists?
                       This throws an error apparently when trying to add a product to an existing quote (edit quote)
                       that has no products on it. (i.e. saved with no products) */
            try { childrenMap.get(key).put(childRef, parentObj.getSObjects(childRef)); }
            catch(Exception e) { }
            
            if (childrenMap.get(key).get(childRef) == null) {
                 childrenMap.get(key).put(childRef, new List<sObject>());
            }
        }
        
        childrenMap.get(key).get(childRef).addAll(childrenObjs);
    }
    
    public static List<sObject> getChildren(sObject parentObj, String childRef) {
        String key = getKey(parentObj);
//        System.debug('====> key: ' + key);
        
        if (!childrenMap.containsKey(key) || !childrenMap.get(key).containsKey(childRef)) {
            // An in-memory child reference does not exist for this parentObj.childRef,
            // return the database sourced child ref if it exists
            if (parentObj.getSObjects(childRef) != null) {
//                System.debug('====> no in-memory children, returning database-sourced children: ' + key);
                
                return parentObj.getSObjects(childRef);
            }
            else {
//                System.debug('====> no in-memory children, no database-sourced children, returning empty list: ' + key);
                
                return new List<sObject>();
            }
        }
        else {
//            System.debug('====> returning in-memory children: ' + key);
            
            return childrenMap.get(key).get(childRef);
        }
    }
    
    public static String getKey(sObject obj) {
        if (obj instanceOf VCG_CPQ_Quote__c) {
            /** @todo  Use a better, more unique key. This is sufficient for the current tool that has only a single quote in memory, but won't be good if there are multiple quotes that may have the same name. */
            return 'VCG_CPQ_Quote__c|' + (String)(obj.get('Name'));
        }
        else if (obj instanceOf VCG_CPQ_Quote_Product__c) {
            /** @todo  This needs Group Name (Product_Group__c) in the key for any records stored under the Quote Product record. */
            return 'VCG_CPQ_Quote_Product__c|' + (String)(obj.getSObject('Product__r').get('ProductCode')) + '|' + (String)(obj.get('Line_Type__c'));
        }
        else {
            throw new VCG_CPQ_Formula.Formula_Exception('Unknown object type \"' + obj.getSObjectType() + '\"');
        }
    }
}