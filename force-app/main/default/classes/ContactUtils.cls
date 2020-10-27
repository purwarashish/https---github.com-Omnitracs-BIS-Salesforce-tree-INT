/*********************************************************************
Name    : ContactUtils
Author  : Shruti Karn
Date    : 22 November 2010

Usage   : This controller is used by the Trigger "ContactAll" Contacts 
to find Contact getting inserted or updated by duplicate email Id.
    
Dependencies : Custom Setting (DuplicateContactProfileID)

Modifications:
4 Jan 2011 - DAR - Added check to allow specified profiles in Custom Setting to enter duplicate email addresses

Modifications:
18 Aug 2011 - Shruti Karn - Added check for Contact's Record Type.
*********************************************************************/
public class ContactUtils{

   /*static list<String> toAddr = new list<string>(); // to store email address of the Users in the Public Group 
   static list<Id> grpUserID = new list<Id>(); // to store the Id of the Users who are members of the Public Group
   static List<Account> acctsToUpdate = new List<Account>();
   static Map<String, Contact> contacts = new Map<String, Contact>();
   static List<Opportunity> oppsToUpdate = new List<Opportunity>();
/******************************************************************** 
    To find Contacts having duplicate email addresses and insert them with email field as blank.
********************************************************************/
    /*public static Boolean findDuplicate(list<contact> lstContact)
    {
        Boolean isSingle; // Used when a single record is updated with duplicate email address
        String userProfileId = userinfo.getProfileId();
                
        //Get List of Custom Settings showing Profiles that are allowed to duplicate email addresses
        List<DuplicateContactProfileID__c> listProfileID = [SELECT profileID__c from DuplicateContactProfileID__c WHERE ProfileID__c = :userProfileID LIMIT 1];
               
        //if user is part of Duplicate Group - no check 
        if (listProfileID.size() >  0)
        {
            isSingle = false;
            
        }else{
            
            list<String> lstContEmail = new list<String>();
            list<contact> lstExistingContact = new list<contact>();
            set<String> setExistingEmail = new set<String>();
            list<contact> lstDupContact = new list<Contact>();
            set<String> setNewEmail = new set<String>(); 
            
            // Modified by Shruti Karn for Record Type Check
            List<DuplicateContactRecordType__c> listRecType = [SELECT RecordTypeDeveloperName__c from DuplicateContactRecordType__c limit 10];
            list<string> lstDeveloperName = new list<String>();
            for(integer i=0;i<listRecType.size();i++)
                lstDeveloperName.add(listRecType[i].RecordTypeDeveloperName__c);
            map<Id,RecordType> mapRecTypeIdName = new map<Id,RecordType>([Select id,DeveloperName from RecordType where DeveloperName in :lstDeveloperName limit 10 ]);
                    
            
            for(integer i=0;i<lstContact.size();i++)
            {
                if(!(mapRecTypeIdName.containsKey(lstContact[i].RecordTypeId)))
                {
                   lstContEmail.add(lstContact[i].Email);
                }
            }
            
            lstExistingContact = [Select id ,email,Secondary_Contact__c from Contact 
               where email in:lstContEmail 
                   and Secondary_Contact__c= false 
                   and (email != '' or email != null) 
                   and recordtypeid not in: mapRecTypeIdName.keySet() 
                   limit 10000 ]; 
            
            if(lstExistingContact.size() >0)
            {
                for(integer i=0;i<lstExistingContact.size();i++)
                {
                    setExistingEmail.add(lstExistingContact[i].email);
                }
            }
            
            for(integer i=0;i<lstContact.size();i++)
            {
                if(setExistingEmail.contains(lstContact[i].email))
                {
                    if(!(lstContact[i].Secondary_Contact__c))
                        lstDupContact.add(lstContact[i]);
                }
                else
                {
                    if(lstContact[i].Secondary_Contact__c == false)
                    {
                        if(!(setNewEmail.contains(lstContact[i].email)))
                            setNewEmail.add(lstContact[i].email);
                        else
                            lstDupContact.add(lstContact[i]);
                    }
                }
                
                
            }  
            
system.debug('lstDupContact:'+lstDupContact);
            if(!(lstDupContact.isEmpty()))
            {
                for(Contact cnt : lstDupContact)
                {    
                    cnt.Email = '';
                    cnt.isDuplicateEmail__c = true;
                }
           
                if(lstDupContact.size() > 1)
                {               
                    isSingle = false; // More than 1 Contact record is being inserted / updated so the error message should not be displayed
                    getGroupEmail(); // Get the email address of the members of the Public Group
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    mail.setToAddresses(toAddr);
                    mail.setReplyTo('sfdc.support@qualcomm.com');
                    mail.setSenderDisplayName('Salesforce Contact Update');
                    mail.setSubject('Duplicate Email Address found');
                    mail.setUseSignature(false);
                    mail.setPlainTextBody('Number of Contact record(s) having duplicate email address : '+lstDupContact[0].id);
//Uncomment following line to send emails                    
                    //Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });    
                }else{
                    // return true;
                    isSingle = true; // Single Record has duplicate email address
                }
            }else{
                isSingle = false; // Records have different email address
            }
        }
        return isSingle;                    
    }
     
/******************************************************************** 
    // To find if the email is changed for the updated Contact record. 
    //If not then update the flag to false once the record is updated.
********************************************************************/   
    /*public static Boolean findDuplicate(list<contact> lstNewContact , list<contact> lstOldContact)
    {
        Boolean isSingle = false;
        list<contact> lstFinalContact = new list<Contact>();
        String userProfileId = userinfo.getProfileId();
        //Get List of Custom Settings showing Profiles that are allowed to duplicate email addresses
        List<DuplicateContactProfileID__c> listProfileID = [SELECT profileID__c from DuplicateContactProfileID__c WHERE ProfileID__c = :userProfileID LIMIT 1];
               
        //if user is part of Duplicate Group - no check 
        if (listProfileID.size() >  0)
        {
            isSingle = false;
        }else{
            for(integer i=0;i<lstNewContact.size();i++)
            {
                if(lstNewContact[i].Email != lstOldContact[i].Email && lstNewContact[i].Email != null)
                    lstFinalContact.add(lstNewContact[i]);
                else if(lstNewContact[i].Email == null && lstNewContact[i].isDuplicateEmail__c == false)
                {
                    isSingle = false;
                    lstNewContact[i].isDuplicateEmail__c = true;
                }
                else if(lstNewContact[i].Email == null && lstNewContact[i].isDuplicateEmail__c == true)
                {
                    isSingle = false;
                    lstNewContact[i].isDuplicateEmail__c = false;
                }         
            }
        
                if(lstFinalContact.size() > 0)           
                    isSingle = findDuplicate(lstFinalContact);
        }
                return isSingle;
    }

/******************************************************************** 
    Function to find the Id of the Public Group 
    This group is notified when duplicate emails are entered during bulk
    operations   
********************************************************************/  
    /*public static void getGroupEmail()
    {
        
        list<ID> grpId = new list<ID>(); 
        Group Grp = [Select id from group where name =: System.Label.Contact_Duplicate_Email_Grp limit 1];

        grpId.add(Grp.Id);  
        findGrpMembers(grpId); // to find email address of the Group members 

        list<User> lstUser = [Select id, email from User where Id in :grpUserID limit 500];

        for(integer i=0;i<lstUser.size();i++)
        {
            toAddr.add(lstUser[i].email);
        }   
    }

/********************************************************************    
    to find email address of the Group members
********************************************************************/  
    /*public static void findGrpMembers(list<Id> GrpId)
    {
        
        list<GroupMember> lstGrpMem = [Select g.UserOrGroupId, g.Id From GroupMember g where g.GroupId in :GrpId limit 500];
        list<Id> subGrpID = new list<Id>();

        for(integer i=0;i<lstGrpMem.size();i++)
        {
            String usrOrgrpId = lstGrpMem[i].UserOrGroupId;
            if(!(usrOrgrpId.substring(0,3)== '00G')) // Add to the list of Users since the Id represents a User
                grpUserID.add(lstGrpMem[i].UserOrGroupId);

            if(usrOrgrpId.substring(0,3)== '00G')
                subGrpID.add(lstGrpMem[i].UserOrGroupId); //  Add to the list of Group since the Id represents a Group
            
        }

        // If there are Groups as the member of the main Public Group then find the Users  in that Group 
        if(!(subGrpID.isEmpty()))
            findGrpMembers(subGrpID);               
    }
/******************************************************************
To validate format on phone fields
******************************************************************/
/*public static String validatePhone(String phoneNumber)
{
  if(phoneNumber == null)
  return '';
    
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
                System.debug('*************************** phoneNumber matches the format : ' + phoneNumber);
                return phoneNumber;
        }
        
     }
     System.debug('************************* WRONG FORMAT');
     return null;
     
}

@future
public static void updatePhoneAndFax(Map<id,String> mapOfContIdToPhoneNum, Map<id,String> mapOfContIdToFax)
{
    
    Set<Id> setOfIds = new Set<Id>();
    if(!mapOfContIdToPhoneNum.isEmpty())
    setOfIds.addAll(mapOfContIdToPhoneNum.keySet());
    if(!mapOfContIdToFax.isEmpty())
    setOfIds.addAll(mapOfContIdToFax.keySet());
    
    List<Contact> conList = [select id, phone, AccountId, fax from Contact where id IN: setOfIds];
    Set<Id> setOfAccountId = new Set<Id>();
    
    for(Contact c: conList)
    {
        if(mapOfContIdToPhoneNum.containsKey(c.id))
        {
            c.Phone  = mapOfContIdToPhoneNum.get(c.id);
        }
        if(mapOfContIdToFax.containsKey(c.id))
        {
            c.fax  = mapOfContIdToFax.get(c.id);
        }
        
        setOfAccountId.add(c.AccountId);
    }
    try{
    update conList;
    }
    catch(exception e)
    {
        System.debug('Error formating the phone: ' + e.getMessage());
    }
    List<Account> accList = [select id, phone, fax from Account where id IN: setOfAccountId];   
    List<Account> accTobeUpdated  = new List<Account>();
    for(Account a: accList )
    {       
        String phone = validatePhone(a.phone);
        String fax = validatePhone(a.fax);
        
        if((phone!= null && a.phone != phone) || (fax != null && a.fax != fax))
        {
            accTobeUpdated.add(a);  
        }
        
        if(phone!= null && a.phone != phone)
        {
            a.phone = phone;            
        }
        if(fax != null && a.fax != fax)
        {
            a.fax = fax;            
        }
    }
    try{
    update accTobeUpdated;
    }
    catch(exception e)
    {
        System.debug('Error formating the phone: ' + e.getMessage());
    }
}

/******************************************************************** 
   Clear Notification Type on contact if contact is inactive
   CR 92092
********************************************************************/
/*public static void updateNotification(List<Contact> listContact)
{
           
    for(Contact c:listContact)
    {  
        if(c.Inactive__c==true)
        {
            c.Notification_Type__c ='';                    
        }     
  } 
 
}

/******************************************************************** 
 Logic to popualte contact alert if contact is being inactivated.  For insert and update trigger 
 added by joseph hutchins 12/12/2014
********************************************************************/ 
/*public static void updateContactAlertForInactiveContacts(List<Contact> oldContacts, List<Contact> newContacts)
{
    final string INACTIVE_ALERT_TEXT = 'This contact was made inactive on ' + date.today().format() + '.  ';
     
     List<Contact> contactsThatAreInactive = new List<Contact>();
     
    if (oldContacts == null)//  trigger insert
    {
        for (Contact c : newContacts)
        {
            if (c.inactive__c)//  not sure why we would be creating inactive contacts but the logic is here
            {
               contactsThatAreInactive.add(c);
            }
        }
    }
    if (oldContacts != null)//  trigger update
    {
       for (integer i = 0; i < newContacts.size(); i++)
       {
           if (newContacts[i].inactive__c &&
               oldContacts[i].inactive__c != newContacts[i].inactive__c )
           {
               contactsThatAreInactive.add(newContacts[i]);
           }
       }
    }
    
    if (contactsThatAreInactive != null && contactsThatAreInactive.Size() > 0)
    {
        for (Contact c : contactsThatAreInactive)
        {
             if (Util.isblank(c.contact_alert__c))
             {
                c.contact_alert__c = INACTIVE_ALERT_TEXT;
             }
             else
             {
                c.Contact_Alert__c = INACTIVE_ALERT_TEXT + '\n' + c.contact_Alert__c;
             }
        }
    }
}

/******************************************************************** 
 Logic to update or Insert Lead to Source Most Recent Field in Account and Opportunity of the related Contact 
 CR 104728.
********************************************************************/ 
/*public static void updateAccandOppLeadSrcMostRec(List<Contact> listOfContacts)
{ 
       Map<Id, Contact> mapOfAccountIdToContact= new Map<Id, Contact>() ;    
       for(contact c: listOfContacts){
          mapOfAccountIdToContact.put(c.accountid, c);
       }
       list<account> accList = new list<account>();
       list<account> accListToUpdate = new  list<account>();
       list<Opportunity> oppListToUpdate = new list<Opportunity>();
       list<Opportunity> oppoList = new list<Opportunity>(); 
       accList= [Select Id,Lead_Source_Most_Recent__c from Account where Id in : mapOfAccountIdToContact.keySet() ];
       
       List<String> listOfClosedStatusToBeConsidered =  new List<String>();
       listOfClosedStatusToBeConsidered = Global_Variable__c.getInstance('Excluded_Closed_Opp_Status').value__c.split(';');
             
       oppoList = [Select Id,Lead_Source_Most_Recent__c,accountid from Opportunity where accountid in : mapOfAccountIdToContact.keySet() and (isClosed = False OR StageName IN: listOfClosedStatusToBeConsidered)] ;
      
       
           for(account a : accList){     
             if(a.Lead_Source_Most_Recent__c != mapOfAccountIdToContact.get(a.id).Lead_Source_Most_Recent__c)
             {          
                   a.Lead_Source_Most_Recent__c = mapOfAccountIdToContact.get(a.id).Lead_Source_Most_Recent__c;                   
                   accListToUpdate.add(a); 
                   system.debug('@@@ accListToUpdate'+accListToUpdate);
             }                    
           }
     
           for(Opportunity  o : oppoList ){
              if(o.Lead_Source_Most_Recent__c != mapOfAccountIdToContact.get(o.accountId).Lead_Source_Most_Recent__c)
              {        
                   o.Lead_Source_Most_Recent__c = mapOfAccountIdToContact.get(o.accountId).Lead_Source_Most_Recent__c;
                   oppListToUpdate.add(o);
                   system.debug('@@@ Opppolistupdate'+oppListToUpdate); 
              }           
            }
                                       
        
    
    update accListToUpdate;
    update oppListToUpdate;
   
}

@future
//Future method is needed as during lead conversion opportunities are not inserted when contact trigger called.
public static void updateAccandOppLeadSrcMostRecOnInsert(Set<Id> listOfContactIds)
{
    List<Contact> contactList = new List<Contact>([select id, AccountId, Lead_Source_Most_Recent__c from Contact where id IN: listOfContactIds]);
    updateAccandOppLeadSrcMostRec(contactList);
}
*/
}