/***
Purpose: To update the Last Task Comment field on Account with the Comment/Description field value on Task/Event..
***/
public class AccountActivityUtils {
public static final String CONTACT_SALES_RT = System.label.Contact_Record_Type_Sales;
public static final String CONTACT_PARTNER_RT = System.label.Contact_Record_Type_Partner;
public static final String STRING_ID = 'Id';
public static final String STRING_WHOID = 'WhoId';
public static final String STRING_DESCRIPTION = 'Description';
public static final String STRING_ACCOUNT_PREFIX = '001';
public static final String STRING_OPPORTUNITY_PREFIX = '006';
public static final String STRING_CONTACT_PREFIX = '003';
public static final String STRING_TASK_PREFIX = '00T';
public static final String STRING_EVENT_PREFIX = '00U';
public static final String STRING_WHATID = 'WhatId';
public static Map<Id,Account> accountsToUpdate;
public static Map<Id,Contact> contactsToUpdate;
public static Map<Id,Opportunity> MapOfOpps;
public static Map<Id,Contact> MapOfContacts;

    public static void updateActivity(List<SObject> sourceObjects) {    
        
        if(sourceObjects == null || sourceObjects.size() == 0) return;
        
        accountsToUpdate = new Map<Id, Account>();
        contactsToUpdate = new Map<Id, Contact>();
        Set<Id> accountIdsToUpdatePDFA  = new Set<Id>();
        List<Account> listofAccountToUpdate = new List<Account>();
        List<Contact> listofContactsToUpdate = new List<Contact>();
        
        /* If dealing with contacts and opportunities query for the related account and form a map*/
        List<Id> ListContactIds = new List<Id>();
        List<Id> ListOppIds = new List<Id>();
        for(SObject sourceObject : sourceObjects) {
            String prefix = '';
            String tempId = '';
            
            if((String)sourceObject.get(STRING_WHATID) != null)
            {
                tempId = (String)sourceObject.get(STRING_WHATID);
                prefix = tempId.substring(0, 3);
                if(STRING_OPPORTUNITY_PREFIX.equals(prefix))
                {
                    ID parentId = (ID)sourceObject.get(STRING_WHATID);
                    ListOppIds.add(parentId);
                }
            }
            if((String)sourceObject.get(STRING_WHOID) != null)
            {
                tempId = (String)sourceObject.get(STRING_WHOID);
                prefix = tempId.substring(0, 3);
                if(STRING_CONTACT_PREFIX.equals(prefix))
                {
                    ID parentId = (ID)sourceObject.get(STRING_WHOID);
                    ListContactIds.add(parentId);
                }
            }           
        }
        
        system.debug('RT IDS:::::CONTACT_SALES_RT'+ CONTACT_SALES_RT +'//////////'+Contact_Partner_RT);
        if(!ListContactIds.isEmpty())     
        {
            MapOfContacts =  new Map<Id,Contact>([select id, accountid from Contact where id IN: ListContactIds and (recordTypeId =:CONTACT_SALES_RT OR recordTypeId = :Contact_Partner_RT)]);
        }
        if(!ListOppIds.isEmpty())     
        {
            MapOfOpps =  new Map<Id,Opportunity>([select id, accountid from Opportunity where id IN: ListOppIds]);
        }
        /*Mapping contacts and opps to corresponding account ends here*/
          
        for(SObject sourceObject : sourceObjects) {
        
            if(sourceObject == null) continue;
            
            String sourceID = (String)sourceObject.get(STRING_ID);
            if(sourceID == null) continue;
            
            String sourcePrefix = sourceID.substring(0, 3);
            String potentialAccountID = null;
            String potentialContactID = null;
            
            potentialAccountID = getPotentialAccountId (sourceObject, sourcePrefix);
            potentialContactID = getPotentialContactId (sourceObject, sourcePrefix);
            System.debug('######## Potential Account Id####'+potentialAccountID);
            System.debug('######## Potential Contact Id####'+potentialContactID);
            
            if(
                potentialAccountID != null
                && STRING_ACCOUNT_PREFIX.equals(potentialAccountID.substring(0, 3))
            ) {
                System.debug(STRING_ACCOUNT_PREFIX.equals(potentialAccountID.substring(0, 3)));
                if(STRING_TASK_PREFIX.equals(sourcePrefix) || STRING_EVENT_PREFIX.equals(sourcePrefix))
                {
                    accountsToUpdate.put(potentialAccountID,
                    new Account(
                        ID = potentialAccountID                                                                   
                        // If the source was a Task, we want to update Last_Task_Comment__c with the Task Description
                        ,Last_Task_Comment__c = (String)sourceObject.get(STRING_DESCRIPTION)
                    )
                    );
                }
             }
             
             system.debug('@@@potentialContactID'+potentialContactID);
             system.debug('@@@&& MapOfContacts.containsKey(potentialContactID)'+ MapOfContacts);
             
             if(
                potentialContactID != null
                && STRING_CONTACT_PREFIX.equals(potentialContactID.substring(0, 3))
                && MapOfContacts != null
                && MapOfContacts.containsKey(potentialContactID)
            ) {
                System.debug(STRING_CONTACT_PREFIX.equals(potentialContactID.substring(0, 3)));
                if(STRING_TASK_PREFIX.equals(sourcePrefix) || STRING_EVENT_PREFIX.equals(sourcePrefix))
                {
                    contactsToUpdate.put(potentialContactID,
                    new Contact(
                        ID = potentialContactID                                                                   
                        // If the source was a Task, we want to update Last_Task_Comment__c with the Task Description
                        ,Last_Task_Comment__c = (String)sourceObject.get(STRING_DESCRIPTION)
                    )
                    );
                }
             }
        }
        
        
        
          listofAccountToUpdate.addAll(accountsToUpdate.values());
          listofContactsToUpdate.addAll(contactsToUpdate.values());
          System.debug('*****Before Update enter****'+contactsToUpdate);
          System.debug('*****Before Update enter****'+listofAccountToUpdate);
          
          if(!listofContactsToUpdate.isEmpty())
          {
            try{
                 update listofContactsToUpdate;
            }
            catch(DmlException e)
            {
                 System.debug('Contacts not updated.');
            }
          }
          
          if(!listofAccountToUpdate.isEmpty())
          {
            System.debug('*****Before Update****');
            try{
                 update listofAccountToUpdate;
            }
            catch(DmlException e)
            {
                 System.debug('Accounts not updated.');
            }
            System.debug('*****After Update****');                
          }
   }
    
    //Source Object: Task/Event [As of now this is used only for task]
    //Source Prefix: First 3 chars of the id ['00T' for Task]
    public static String getPotentialAccountId (SObject sourceObject, String sourcePrefix)
    {      
     System.debug('*****Source Object****'+sourceObject);
     System.debug('*****Source Prefix****'+sourcePrefix);
          try{
            String parentId =  null;            
            if(
                STRING_TASK_PREFIX.equals(sourcePrefix)
                || STRING_EVENT_PREFIX.equals(sourcePrefix)
            ) {
                //If added to account/opp
                if((String)sourceObject.get(STRING_WHATID) != null)
                parentId = (String)sourceObject.get(STRING_WHATID);
                //if added to contact
                if((String)sourceObject.get(STRING_WHOID) != null)
                parentId = (String)sourceObject.get(STRING_WHOID);
            }
            
            String prefix = parentId.substring(0, 3);
            
            //If task added to account
            if(STRING_ACCOUNT_PREFIX.equals(prefix))         
            return parentId;
            
            //If task added to contact
            if(STRING_CONTACT_PREFIX.equals(prefix) && MapOfContacts != null && MapOfContacts.containsKey(parentId))
            return MapOfContacts.get(parentId).accountId;
            
            //If task added to opportunity
            if(STRING_OPPORTUNITY_PREFIX.equals(prefix))
            return MapOfOpps.get(parentId).accountId;
            
            return null;
          }
          catch(exception e)
          {
            return null;
          }
    }
    
    //Source Object: Task/Event [As of now this is used only for task]
    //Source Prefix: First 3 chars of the id ['00T' for Task]
    public static String getPotentialContactId (SObject sourceObject, String sourcePrefix)
    {  
        try{
            String parentId =  null;            
            if(
                STRING_TASK_PREFIX.equals(sourcePrefix)
                || STRING_EVENT_PREFIX.equals(sourcePrefix)
            ) {
                //if added to contact
                if((String)sourceObject.get(STRING_WHOID) != null)
                parentId = (String)sourceObject.get(STRING_WHOID);
            }
            String prefix = parentId.substring(0, 3);
            //If task added to contact
            if(STRING_CONTACT_PREFIX.equals(prefix))
            return parentId;
            
            return null;
           }
          catch(exception e)
          {
            return null;
          }
    }
    
}