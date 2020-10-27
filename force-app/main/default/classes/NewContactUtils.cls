public class NewContactUtils{

static list<String> toAddr = new list<string>();  // to store email address of the Users in the Public Group 
static list<Id> grpUserID = new list<Id>();       // to store the Id of the Users who are members of the Public Group
//Get List of Custom Settings showing Profiles that are allowed to duplicate email addresses
static List<DuplicateContactProfileID__c> listProfileID = DuplicateContactProfileID__c.getall().values();
    
    public static Void SetNotificationType(list<contact> lstContact)
    {
        //Create a set of all the unique contactIds and corresponding account ids
        Set<Id> accountIds = new Set<Id>();
        
        if(lstContact !=null && lstContact.size()>0)
        { 
            String StrRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Partner Contacts').getRecordTypeId();
                       
            for(Contact objContact: lstContact)
            {
                if(objContact.RecordTypeId == StrRecordTypeId.left(15))
                    accountIds.add(objContact.AccountId);
            }
            
            // We are interested only in Partner Contacts
            if(accountIds.isEmpty()) 
                return;
            
            //Get the Account Status for all accounts
            Map<Id,Account> accStatus=new Map<Id,Account>([SELECT QWBS_Status__c FROM Account WHERE Id in :accountIds]);
       
            //Active partner accounts, all contacts will be subscribed to NewsLetter,Prod Info and Downtime notifications                            
            //Do all the notification updates
            for(Contact objContact:lstContact)
            {
               if(objContact.RecordTypeId == StrRecordTypeId.left(15))  
               {       
                   //Active partner accounts, all contacts will be subscribed to News Letter,Product Info,Downtime/Degraded,Sr.Management and Time Change
                   if(accStatus.get(objContact.AccountId).QWBS_Status__c=='Contract Customer')//Contract Customer
                       objContact.Notification_Type__c= 'News Letter;Product Info;Downtime/Degraded;Sr.Management;Time Change';
                   //partner accounts that are not contract customers yet will be subscribed to NewsLetter and Prod Info only 
                   else 
                       objContact.Notification_Type__c='Newsletter;Product Info';                                                                    
               }
            }
        }
    }
    
    /***************************************************************************
     This method is to restrict the storage of contacts with duplicate email field
     ****************************************************************************/
    public static Boolean findDuplicate(list<contact> lstContact)
    {
        Boolean isSingle; // true when single record is inserted with duplicate email id otherwise it is false
        String userProfileId = userinfo.getProfileId();        
        //if user is part of Duplicate Group - no check
        if(listProfileID != null && !listProfileID.isEmpty())
        {
            for(DuplicateContactProfileID__c objProfileID : listProfileID)
            {
                if(objProfileID.profileID__c == userProfileId)
                    return false;  
            }
        } 
          
        list<String> lstContEmail = new list<String>();  //Used to store the email of the newly instered/updated records
        list<contact> lstExistingContact = new list<contact>(); // Used to store the contacts whose email is equal to Trigger.New emails
        list<contact> lstDupContact = new list<Contact>(); //Used to store the contacts which has same emails
        list<string> lstDeveloperName = new list<String>(); //Used to store the name of the record type
        list<String> lstDeveloperId = new list<String>(); //Used to store the Id of the record type
            
        set<String> setExistingEmail = new set<String>(); //Used to store the emails of the existing contacts
        set<String> setNewEmail = new set<String>(); //Used to store the email of newly inserting/updating records
            
        map<String,String> mapRecTypeIdName = new map<String,String>(); //Used only to utilize the containsKey functionality
            
        //get all Record Types listed in DuplicateContactRecordType__c custom setting
        List<DuplicateContactRecordType__c> listRecType = DuplicateContactRecordType__c.getall().values();
        
        if(listRecType != null && !listRecType.isEmpty())
        {     
            for(DuplicateContactRecordType__c objRecType : listRecType)
            {
                if(objRecType.RecordTypeDeveloperName__c != null && objRecType.RecordTypeDeveloperName__c !='')
                    lstDeveloperName.add(objRecType.RecordTypeDeveloperName__c);
            }
            if(!lstDeveloperName.isEmpty())
            {
                for(String objDeveloperName : lstDeveloperName)
                {
                    if(schema.sObjectType.Contact.getRecordTypeInfosByName().get(objDeveloperName) != null)
                    {
                        String strRecordTypeId = schema.sObjectType.Contact.getRecordTypeInfosByName().get(objDeveloperName).getRecordTypeId();
                        lstDeveloperId.add(strRecordTypeId);
                        
                        mapRecTypeIdName.put(objDeveloperName,objDeveloperName);
                    }
                }
            }
        }    
       
        //code unit to verify if Contact's record type is among any of record type
        //listed in "Duplicate Contact Record Type" custom setting
        //if not then we will check their email against all existing Contact's email(except CNR, FRA, Sylectus record type)                  
        for(Contact objContact:lstContact)
        {
            String strRecordTypeName = schema.sObjectType.Contact.getRecordTypeInfosById().get(objContact.RecordTypeId).getName();
            if(!(mapRecTypeIdName.containsKey(strRecordTypeName)))
            {
                lstContEmail.add(objContact.Email);
            }
        }
        
        if(!lstContEmail.isEmpty())  
        {
            lstExistingContact = [SELECT id ,email,Secondary_Contact__c
                                      FROM Contact 
                                      WHERE email in:lstContEmail 
                                      AND Secondary_Contact__c= false 
                                      AND (email != '' or email != null) 
                                      AND recordtypeid not in: lstDeveloperId 
                                      LIMIT 10000 ]; 
        }
            
        if(!lstExistingContact.isEmpty())
        {
            for(Contact objContact:lstExistingContact)
            {
                setExistingEmail.add(objContact.email);
            }
        }
        
        //if contact Email is already present in any of existing Contact's email except CNR, FRA, Sylectus record type then
        //nullify corresponding Contact Email and set duplicateEmail field as true
        //OR for bulk insertion if more than two contact having same email then
        //keep nullify all other contact's Email except one and set duplicateEmail field as true 
        for(Contact objContact:lstContact)
        {
            if(setExistingEmail.contains(objContact.email)) 
            {
                if(!(objContact.Secondary_Contact__c))
                    lstDupContact.add(objContact);
            }
            else
            {
                if(objContact.Secondary_Contact__c == false)
                {
                    if(!(setNewEmail.contains(objContact.email)))
                        setNewEmail.add(objContact.email);
                    else
                        lstDupContact.add(objContact);
                }
            }
        }  
            
        if(!(lstDupContact.isEmpty()))
        {
            for(Contact objContact : lstDupContact)
            {    
                objContact.Email = '';
                objContact.isDuplicateEmail__c = true;
            }
            if(lstDupContact.size() > 1)
            {               
                isSingle = false; // More than 1 Contact record is being inserted / updated so the error message should not be displayed   
            }
            else
            {
                isSingle = true; // Single Record has duplicate email address
            }
        }
        else
        {
            isSingle = false; // Records have different email address
        }
        return isSingle;                    
   }
       
    /******************************************************************** 
     To find if the email is changed for the updated Contact record. 
     If not then update the flag to false once the record is updated.
    ********************************************************************/   
    public static Boolean findDuplicate(list<contact> lstNewContact , map<id,contact> mapOldContact)
    {
        Boolean isSingle = false;
        String userProfileId = userinfo.getProfileId();
        list<contact> lstFinalContact = new list<Contact>(); //Used to store the contacts whose email is updated
        
        //if user is part of Duplicate Group - no check
        if(listProfileID != null && !listProfileID.isEmpty())
        { 
            for(DuplicateContactProfileID__c objProfileID : listProfileID)
            {
                if(objProfileID.profileID__c == userProfileId)
                    return false;
            }
        }
        
        for(Contact objNewContact : lstNewContact)
        {
            if(objNewContact.Email != mapOldContact.get(objNewContact.Id).Email && objNewContact.Email != null)
                lstFinalContact.add(objNewContact);
            else if(objNewContact.Email == null && objNewContact.isDuplicateEmail__c == false)
            {
                isSingle = false;
                objNewContact.isDuplicateEmail__c = true;
            }
            else if(objNewContact.Email == null && objNewContact.isDuplicateEmail__c == true)
            {
                isSingle = false;
                objNewContact.isDuplicateEmail__c = false;
            }         
        }
        
        if(!lstFinalContact.isEmpty())           
            isSingle = findDuplicate(lstFinalContact);
  
        return isSingle;
    }

    public static void PhoneAndFaxFormatCheck(list<contact> lstContact)
    {
        Map<id,String> mapOfContIdToPhoneNum = new Map<id,String>();
        Map<id,String> mapOfContIdToFax = new Map<id,String>();
        Set<id> setAccountId = new Set<id>();
		for(Contact con : lstContact){
			setAccountId.add(con.AccountId);
		}
		Map<Id, Account> acctMap = new Map<Id, Account>([select Id, Primary_Business_Unit__c from Account where Id IN :setAccountId]);
        for(Contact objContact:lstContact){                        
            //Should only fire for Partner contacts or Sales Contacts  
            //This validation is added in the Trigger and not in the validation rule as we want it to fire on Lead conversion too.
            //That is why we are using the after insert event.
            if(((objContact.RecordTypeId+'').contains(Label.Contact_Record_Type_Partner) || (objContact.RecordTypeId+'').contains(Label.Contact_Record_Type_Sales)) && acctMap.get(objContact.AccountId).Primary_Business_Unit__c == 'Omnitracs Domestic') 
            {
                if(objContact.Phone != null)
                {
                    String phone = NewContactUtils.validatePhone(objContact.phone);
                    if(phone == null)
                    {
                        objContact.addError('Phone number should be in the format (XXX) XXX-XXXX. Extension (if any) should be entered in the separate field provided.');
                    }                                   
                    else if(objContact.phone != phone) 
                    {
                        mapOfContIdToPhoneNum.put(objContact.id,phone);
                    }
                }
            
                if(objContact.Fax != null)
                {
                    String fax = NewContactUtils.validatePhone(objContact.Fax);
                    if(fax == null)
                    {    
                        objContact.addError('Fax number should be in the format (XXX) XXX-XXXX.');
                    }
                    else if(objContact.Fax != fax) 
                    {
                        mapOfContIdToFax.put(objContact.id,fax);
                    }
                }
            }  
        }
        
        if(!mapOfContIdToPhoneNum.isEmpty() || !mapOfContIdToFax.isEmpty() || !setAccountId.isEmpty())
        {
            NewContactUtils.updatePhoneAndFax(mapOfContIdToPhoneNum, mapOfContIdToFax, setAccountId);
        }
    }
    
    /******************************************************************
    To validate format on phone fields
    ******************************************************************/
    public static String validatePhone(String phoneNumber)
    {
    
        //The only correct format : (xxx) xxx-xxxx
        String regExpValid = '\\(\\d{3}\\)[\\s]\\d{3}-\\d{4}';
        //Phone format which is acceptable, but which will later be formatted to the above correct format
        //Format : (xxx)xxx-xxxx
        String regExpValidButTobeConv1 = '\\(\\d{3}\\)\\d{3}-\\d{4}';
        //Format :  xxx-xxx-xxxx
        String regExpValidButTobeConv2 = '\\d{3}\\-\\d{3}\\-\\d{4}'; 
        Pattern validphonePattern = Pattern.compile(regExpValid);
        Pattern validphonePatternToBeConv1 = Pattern.compile(regExpValidButTobeConv1);  
        Pattern validphonePatternToBeConv2 = Pattern.compile(regExpValidButTobeConv2);
    
        Matcher phoneMatcherValid = validphonePattern.matcher(phoneNumber);
        Matcher phoneMatcherValidTobeConv1 = validphonePatternToBeConv1.matcher(phoneNumber);
        Matcher phoneMatcherValidTobeConv2 = validphonePatternToBeConv2.matcher(phoneNumber);
      
        if(phoneMatcherValid.matches()||phoneMatcherValidTobeConv1.matches() ||phoneMatcherValidTobeConv2.matches() )
        { 
            if(phoneMatcherValidTobeConv1.matches())
            {
                phoneNumber = phoneNumber.replace(')', ') ');
            }
            if(phoneMatcherValidTobeConv2.matches())
            {
                phoneNumber = phoneNumber.replaceFirst('-', ') ');
                phoneNumber = '(' + phoneNumber;
            }        
    
            //Check if the conversion worked.  
            Matcher phoneMatcherValid3 = validphonePattern.matcher(phoneNumber);
            if(phoneMatcherValid3.matches())
            {
                return phoneNumber;
            }
        }
        return null;   
    }
    
        
    @future
    public static void updatePhoneAndFax(Map<Id,String> mapOfContIdToPhoneNum, Map<Id,String> mapOfContIdToFax, set<Id> setOfAccountId)   
    {   
        Set<Id> setOfContactIds = new Set<Id>();
        List<Account> accTobeUpdated  = new List<Account>();
        String phone;
        String fax;
        
        if(!mapOfContIdToPhoneNum.isEmpty())
            setOfContactIds.addAll(mapOfContIdToPhoneNum.keySet());
        if(!mapOfContIdToFax.isEmpty())
            setOfContactIds.addAll(mapOfContIdToFax.keySet());
            
        if(!setOfContactIds.isEmpty())                
        {    
            List<Contact> lstContact = [select id, phone, AccountId, fax from Contact where id IN: setOfContactIds];         
            for(Contact objContact: lstContact)
            {
                if(mapOfContIdToPhoneNum.containsKey(objContact.id))
                {
                    objContact.Phone  = mapOfContIdToPhoneNum.get(objContact.id);
                }
                if(mapOfContIdToFax.containsKey(objContact.id))
                {
                    objContact.fax  = mapOfContIdToFax.get(objContact.id);
                }
            }
            try{
                update lstContact;
            }
            catch(exception e)
            {
                System.debug('Error formating the phone: ' + e.getMessage());
            }
        }
        
        if(!setOfAccountId.isEmpty())
        {    
            List<Account> lstAccount = [select id, phone, fax from Account where id IN: setOfAccountId];                  
            for(Account accObj: lstAccount)
            {    
                if(accObj.phone != null)
                    phone = validatePhone(accObj.phone);
                if(accObj.fax != null)
                    fax = validatePhone(accObj.fax);
                                                
                if((phone!= null && accObj.phone != phone) || (fax != null && accObj.fax != fax))
                {
                    if(phone!= null && accObj.phone != phone)
                    {
                        accObj.phone = phone;  
                    }
                    if(fax != null && accObj.fax != fax)
                    {
                        accObj.fax = fax;      
                    }
                    accTobeUpdated.add(accObj);  
                }
            }
        }
        try
        {
            if(accTobeUpdated != null && !accTobeUpdated.isEmpty())
                update accTobeUpdated;
        }
        catch(exception e)
        {
            System.debug('Error formating the phone: ' + e.getMessage());
        }
    }
    
/*******************************************************************
This piece of code is to populate the account of the invitor and User of the invitor
This is used so that the Account name can be pulled up for the Unity Invite - Colleague invite template.

***********************************************************************/
    public static void autoPopulateInvitorAccountandUser(List<Contact> lstNewContacts, Map<Id,Contact> mapOldContact)
    {
         //Should fire only for invite process
        Set<String> setOfInvitorEmails = new Set<String>();
        final String OMNITRACS_ACCOUNT_ID = Label.Omnitracs_Account_Id;    //Used to store the "Omnitracs, LLC" account Id
        
        for(Contact objContact : lstNewContacts)
        {        
            if(Trigger.isInsert && objContact.Unity_Invitor_Email__c != null)
            {
                setOfInvitorEmails.add(objContact.Unity_Invitor_Email__c);   
            }
            if(Trigger.isUpdate && mapOldContact.get(objContact.id).Unity_Invitor_Email__c != objContact.Unity_Invitor_Email__c && objContact.Unity_Invitor_Email__c != null)
            {
                setOfInvitorEmails.add(objContact.Unity_Invitor_Email__c);   
            }
    
            //Changes for CR 01205363
            if(objContact.Lead_Source_Most_Recent__c == null &&  objContact.LeadSource != null )
            {
                objContact.Lead_Source_Most_Recent__c = objContact.LeadSource;
            }
                        
            if(objContact.Lead_Source_Most_Recent__c != null &&  (objContact.LeadSource == null || objContact.Lead_Source_Update_Date__c < (System.TODAY()-365)) )
            {
                objContact.LeadSource = objContact.Lead_Source_Most_Recent__c;
            }
        }
                
        if(!setOfInvitorEmails.isEmpty())
        {
            Map<String, Contact> mapContact = new Map<String, Contact>();
            Map<String, User> mapUser = new Map<String, User>();
            String QesUnityProfileId = Label.QES_UNITY_Customer_Portal_User_SSO ; //Used to store the profile "QES UNITY Customer Portal User (SSO)"
            
            for(Contact objContact :[select id, AccountId, email from Contact where email IN: setOfInvitorEmails])
            {
                mapContact.put(objContact.email, objContact);
            }
            for(User objUser :[select id, AccountId, email from User where email IN: setOfInvitorEmails and  profileId !=:QesUnityProfileId ])
            {
                mapUser.put(objUser.email, objUser);
            }
            for(Contact objContact : lstNewContacts)
            { 
                
                if(setOfInvitorEmails.contains(objContact.Unity_Invitor_Email__c))
                {
                    if(mapContact.containsKey(objContact.Unity_Invitor_Email__c))
                    {                   
                        objContact.Unity_Invitor_Account__c = mapContact.get(objContact.Unity_Invitor_Email__c).AccountId;
                    }
                    if(mapUser.containsKey(objContact.Unity_Invitor_Email__c))
                    {                   
                        objContact.Unity_Invitor_User__c = mapUser.get(objContact.Unity_Invitor_Email__c).id;
                    } 
                }
                if(objContact.Unity_Invitor_Email__c != null && objContact.Unity_Invitor_Email__c != '')
                {
                    if(objContact.Unity_Invitor_Email__c.toLowerCase().contains('qualcomm.com') || objContact.Unity_Invitor_Email__c.toLowerCase().contains('omnitracs.com') )
                        objContact.Unity_Invitor_Account__c = OMNITRACS_ACCOUNT_ID;
                }
            }
        }
    }
    
   /******************************************************************** 
   Clear Notification Type on contact if contact is inactive
   CR 92092
   ********************************************************************/
    public static void updateNotification(List<Contact> listContact)
    {
        for(Contact objContact:listContact)
        {  
            if(objContact.Notification_Type__c!=null && objContact.Inactive__c==true)
            {
                    objContact.Notification_Type__c ='';                    
            }     
        }    
    }

    /******************************************************************** 
    Logic to popualte contact alert if contact is being inactivated.  For insert and update trigger 
    added by joseph hutchins 12/12/2014
    ********************************************************************/ 
    public static void updateContactAlertForInactiveContacts(List<Contact> lstNewContacts, List<Contact> lstOldContacts, Map<Id,Contact> mapOldContacts)
    {
        final string INACTIVE_ALERT_TEXT = 'This contact was made inactive on ' + date.today().format() + '.  ';
        List<Contact> lstContactsThatAreInactive = new List<Contact>(); //Used to store the inactive contacts
     
        if (lstOldContacts == null) //  trigger insert
        {
            for (Contact objNewContact : lstNewContacts)
            {
                if (objNewContact.inactive__c)//  not sure why we would be creating inactive contacts but the logic is here
                {
                    lstContactsThatAreInactive.add(objNewContact);
                }
            }
        }    
        else //trigger update
        {
            for (Contact objNewContacts:lstNewContacts)
            {
                if (objNewContacts.inactive__c && mapOldContacts.get(objNewContacts.Id).inactive__c != objNewContacts.inactive__c)
                {
                    lstContactsThatAreInactive.add(objNewContacts);                    
                }
            }
        }
    
        if (!lstContactsThatAreInactive.isEmpty())
        {        
            for (Contact objContact : lstContactsThatAreInactive)
            {
                if (Util.isblank(objContact.contact_alert__c))
                {
                    objContact.contact_alert__c = INACTIVE_ALERT_TEXT;
                }
                else
                {
                    if(mapOldContacts != null && mapOldContacts.get(objContact.id) != null)
                    {
                         //Restricting Contact_Alert__c to be set twice in a single transaction
                         if(mapOldContacts.get(objContact.id).contact_Alert__c != null)
                         {
                             objContact.Contact_Alert__c = INACTIVE_ALERT_TEXT + '\n' + objContact.contact_Alert__c;
                         }                        
                    }     
                }
            }
        }
    }

    /******************************************************************** 
    Used to collect the contact record ID's whose "Lead Source Most Recent field" is either updated or not null
    ********************************************************************/
    public static void AccandOppLeadSrcMostRecOnUpdate(List<Contact> newContacts, Map<ID,Contact> oldContacts)
    {
        Set<Id> contactIds = new Set<Id>(); //Used to store the contact ID's
        
        if(Trigger.isInsert)
        {
            for(Contact objContact : newContacts)
            {
                if(objContact.Lead_Source_Most_Recent__c != null && !System.isFuture())
                {
                    contactIds.add(objContact.id);     
                }
            }    
        }
        
        if(Trigger.isUpdate)
        {
            for(Contact objContact : newContacts)
            {                            
                if(objContact.Lead_Source_Most_Recent__c != oldContacts.get(objContact.Id).Lead_Source_Most_Recent__c && objContact.Lead_Source_Most_Recent__c != null)
                {                            
                    contactIds.add(objContact.id);  
                }
            }    
        }
        
        if(!contactIds.isEmpty() && !System.isFuture())
         updateAccandOppLeadSrcMostRecOnInsert(contactIds);
     
    }

    /******************************************************************** 
    Logic to update or Insert Lead to Source Most Recent Field in Account and Opportunity of the related Contact 
    CR 104728.
    ********************************************************************/ 
    public static void updateAccandOppLeadSrcMostRec(List<Contact> listOfContacts)
    {
        list<account> lstAccts = new list<account>();               //Used to store the account related to the contact
        list<account> accListToUpdate = new  list<account>();       //Used to store the account which needs to be updated
        list<Opportunity> oppListToUpdate = new list<Opportunity>(); //Used to store the opportunity 
        //list<Opportunity> lstOppts = new list<Opportunity>();       //Used to store the opportunity which needs to be updated
        List<String> listOfClosedStatusToBeConsidered =  new List<String>(); //Used to store the opportunity StageName
        Map<Id, Contact> mapOfAccountIdToContact= new Map<Id, Contact>() ; 
 
       try
       {
            for(contact objContact: listOfContacts)
            {
                mapOfAccountIdToContact.put(objContact.accountid,objContact);
            }
       
            lstAccts= [SELECT Id,Lead_Source_Most_Recent__c
                        FROM Account
                        WHERE Id in : mapOfAccountIdToContact.keySet()
                        LIMIT 50000];
             
            listOfClosedStatusToBeConsidered = Global_Variable__c.getInstance('Excluded_Closed_Opp_Status').value__c.split(';');
             
            /*lstOppts = [SELECT Id,Lead_Source_Most_Recent__c,accountid
                        FROM Opportunity
                        WHERE accountid in : mapOfAccountIdToContact.keySet() AND (isClosed = False OR StageName IN: listOfClosedStatusToBeConsidered)
                        LIMIT 50000] ;*/
            
           for(account objAcc : lstAccts)
           {     
              if(objAcc.Lead_Source_Most_Recent__c != mapOfAccountIdToContact.get(objAcc.id).Lead_Source_Most_Recent__c)
              {          
                   objAcc.Lead_Source_Most_Recent__c = mapOfAccountIdToContact.get(objAcc.id).Lead_Source_Most_Recent__c;                   
                   accListToUpdate.add(objAcc); 
              }                    
           } 
           
           //Case # 02293711     Sripathi Gullapalli
           /*for(Opportunity  objOpp : lstOppts )
           {
              if(objOpp.Lead_Source_Most_Recent__c != mapOfAccountIdToContact.get(objOpp.accountId).Lead_Source_Most_Recent__c)
               {        
                   objOpp.Lead_Source_Most_Recent__c = mapOfAccountIdToContact.get(objOpp.accountId).Lead_Source_Most_Recent__c;
                   oppListToUpdate.add(objOpp);
               }           
             }*/
        if(!accListToUpdate.isEmpty())
        {
            update accListToUpdate;   
        }
        if(!oppListToUpdate.isEmpty())
        {
            update oppListToUpdate;   
        }  
        }
        catch(Exception e)
        {
            system.debug('Error in "NewContactUtils" class method "updateAccandOppLeadSrcMostRec"'+e.getMessage());
        }
    }

    //Future method is needed as during lead conversion opportunities are not inserted when contact trigger called.
    @future
    public static void updateAccandOppLeadSrcMostRecOnInsert(Set<Id> listOfContactIds)
    {
        List<Contact> lstContact = new List<Contact>([select id, AccountId, Lead_Source_Most_Recent__c from Contact where id IN: listOfContactIds]);
        updateAccandOppLeadSrcMostRec(lstContact);
    }

    public static void  contactNetsuitesync(List<Contact> listOfContactIds)
    {
        Set<Id> conIdList = new Set<Id>();
        Set<Id> accountIdSet = new Set<Id>();
        Map<Id,Id> conAccountIdMap = new Map<Id,Id>();
            
     /* for(Contact objCon:listOfContactIds)
        {
            if (objCon.Role__c != null && objCon.Role__c.contains('Legal Representative'))
            accountIdSet.add(objCon.accountId);
        }*/
            
         for(Account objAcc:[SELECT Id, Send_to_Netsuite__c FROM Account WHERE Id IN: accountIdSet])
         {
            if(objAcc.Send_to_Netsuite__c == true)
            {
                conAccountIdMap.put(objAcc.Id,objAcc.Id);
             }
         }
            
         for(Contact objCon:listOfContactIds)
         {
            if(conAccountIdMap.get(objCon.AccountId) != null)
            {
                conIdList.add(objCon.Id);
            }            
         }  
            
            if(!conIdList.isEmpty())
            {
                NetsuiteSyncContactHelper.postDataToNetsuite(conIdList);        
            }
             //Set hasRun boolean to false to prevent recursion
        NetsuiteSyncContactHelper.hasRun = true;
     }       
    
    
    
}