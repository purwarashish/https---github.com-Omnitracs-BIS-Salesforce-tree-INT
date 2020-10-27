/*********************************************************************
Name    : ContactAll
Author  : Shruti Karn
Date    : 22 November 2010

Usage   : This trigger is to find Contact getting inserted or updated by duplicate email Id  and then notify the Delegated Admins.
    
Dependencies : ContactUtils
*********************************************************************/
trigger ContactAll on Contact (before insert, before update, after update, after delete, after insert) 
{

     /*BypassTriggerUtility u = new BypassTriggerUtility();  
     if (u.isTriggerBypassed()) {
         return;
     }

/////  START - Trigger Code by Shruti Karn (before insert, before update) ////

    if(Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate))
    {
        Boolean isSingle;
        
        if(Trigger.isInsert)
///Determine if single insert or bulk
            isSingle=ContactUtils.findDuplicate(Trigger.new);
        
        if(Trigger.isUpdate)
        {
        
system.debug('@@@TriggerSize:'+Trigger.new.size());
    
            isSingle=ContactUtils.findDuplicate(Trigger.new,Trigger.Old);
        }
        
system.debug('isSingle in trigger:'+isSingle);
            
        if(isSingle && Trigger.new.size() == 1)
            Trigger.new[0].addError('Duplicate Email was found. Please give a unique Email address or leave the field blank');
    }
    
////  END - Trigger Code by Shruti Karn  ////


     if(Trigger.isInsert && Trigger.isAfter)
    {
        Map<id,String> mapOfContIdToPhoneNum = new Map<id,String>();
        Map<id,String> mapOfContIdToFax = new Map<id,String>();
        for(Contact c: Trigger.new)
        {
         //Should only fire for Partner contacts or Sales Contacts  
         //This validation is added in the Trigger and not in the validation rule as we want it to fire on Lead conversion too.
         //That is why we are using the after insert event.
         if(((c.RecordTypeId+'').contains(Label.Contact_Record_Type_Partner) || (c.RecordTypeId+'').contains(Label.Contact_Record_Type_Sales)) && c.Primary_Business_Unit__c == 'Omnitracs Domestic')   
         {
            if(c.Phone != null)
            {
                String phone = ContactUtils.validatePhone(c.phone);
                if(phone == null)
                c.addError('Phone number should be in the format (XXX) XXX-XXXX. Extension (if any) should be entered in the separate field provided.');
                else 
                {
                    if(c.phone != phone)
                    mapOfContIdToPhoneNum.put(c.id,phone);
                }
                mapOfContIdToPhoneNum.put(c.id,c.phone);
            }
            
            
            if(c.Fax != null)
            {
               
                String fax = ContactUtils.validatePhone(c.Fax);
                if(fax == null)
                c.addError('Fax number should be in the format (XXX) XXX-XXXX.');
                else
                {
                    if(c.fax != fax)
                    mapOfContIdToFax.put(c.id,fax);
                }
            }
         }  
         
         if(!mapOfContIdToFax.isEmpty() || !mapOfContIdToPhoneNum.isEmpty())
         {
            ContactUtils.updatePhoneAndFax(mapOfContIdToPhoneNum, mapOfContIdToFax);
         }
        }
    }
    
    //This piece of code is to populate the account of the inviter
    //This is used so that the Account name can be pulled up for the Unity Invite - Colleague invite template.
    if(Trigger.isBefore)
    {
        //Should fire only for invite process
        Set<String> setOfInvitorEmails = new Set<String>();
        String OmnitracsId = Label.Omnitracs_Account_Id;
        for(Contact c : trigger.new)
        {
            
            if(trigger.isInsert && c.Unity_Invitor_Email__c != null)
            {
                setOfInvitorEmails.add(c.Unity_Invitor_Email__c);
            }
            if(trigger.isUpdate && trigger.oldMap.get(c.id).Unity_Invitor_Email__c != c.Unity_Invitor_Email__c && c.Unity_Invitor_Email__c != null)
            {
                setOfInvitorEmails.add(c.Unity_Invitor_Email__c);
            }
            
            //Changes for CR 01205363
            if(c.Lead_Source_Most_Recent__c == null &&  c.LeadSource != null )
            {
                c.Lead_Source_Most_Recent__c = c.LeadSource;
            }
            if(c.Lead_Source_Most_Recent__c != null &&  (c.LeadSource == null || c.Lead_Source_Update_Date__c < (System.TODAY()-365)) )
            {
                c.LeadSource = c.Lead_Source_Most_Recent__c;
            }
        }
        if(setOfInvitorEmails.size() > 0)
        {
            Map<String, Contact> invitorMap = new Map<String, Contact>();
            Map<String, User> invitorUserMap = new Map<String, User>();
            for(Contact invitor :[select id, AccountId, email from Contact where email IN: setOfInvitorEmails])
            {
            invitorMap.put(invitor.email, invitor);
            }
            for(User invitor :[select id, AccountId, email from User where email IN: setOfInvitorEmails and  profileId != '00e500000018o1O'])
            {
            invitorUserMap.put(invitor.email, invitor);
            }
            for(Contact c : trigger.new)
            {
                if(setOfInvitorEmails.contains(c.Unity_Invitor_Email__c))
                {
                    if(invitorMap.containsKey(c.Unity_Invitor_Email__c))
                    {                   
                        c.Unity_Invitor_Account__c = invitorMap.get(c.Unity_Invitor_Email__c).AccountId;
                    }
                    if(invitorUserMap.containsKey(c.Unity_Invitor_Email__c))
                    {                   
                        c.Unity_Invitor_User__c = invitorUserMap.get(c.Unity_Invitor_Email__c).id;
                    } 
                }
                
                
                    if(c.Unity_Invitor_Email__c.toLowerCase().contains('qualcomm.com') || c.Unity_Invitor_Email__c.toLowerCase().contains('omnitracs.com') )
                    c.Unity_Invitor_Account__c = OmnitracsId;
                
            }
        }
    }
   //Clear notification type on contact if contact is inactive (CR 92092) 
   if(Trigger.isBefore && Trigger.isInsert || Trigger.isBefore && Trigger.isUpdate)
   {  
      ContactUtils.updateNotification(trigger.new);
      ContactUtils.updateContactAlertForInactiveContacts(Trigger.Old, Trigger.new);
  
   }
   // Logic to update or Insert Lead Source Most Recent Field in Account and Opportunity of the related Contact CR 104728.
   
   if(trigger.isInsert && trigger.isAfter){
    Set<Id> contactIds = new Set<Id>();
        for(Contact c : trigger.new){
            if(c.Lead_Source_Most_Recent__c != null && !System.isFuture()){
                    contactIds.add(c.id);     
            }
        }
        if(!contactIds.isEmpty() &&  !System.isFuture())
        ContactUtils.updateAccandOppLeadSrcMostRecOnInsert(contactIds);
    }        
    if(trigger.isUpdate && trigger.isAfter){
        Set<Id> contactIds = new Set<Id>();
        for(Contact c : trigger.new){
                        Contact oldContact = trigger.oldMap.get(c.Id);                             
                        if(c.Lead_Source_Most_Recent__c != oldContact.Lead_Source_Most_Recent__c && c.Lead_Source_Most_Recent__c != null){                            
                         contactIds.add(c.id);  
                        }
          }
          if(!contactIds.isEmpty() &&  !System.isFuture())
          ContactUtils.updateAccandOppLeadSrcMostRecOnInsert(contactIds);
     } 
    
     //Author:         JBarrameda (Cloudsherpas)
     //Description: Code that sync the contact record to Netsuite
         
     if(trigger.isAfter && (trigger.isInsert || trigger.isUpdate) && Trigger.size == 1 && !System.isFuture()){
        
         if (!NetsuiteSyncContactHelper.hasRun){
            
            Set<Id> conIdList = new Set<Id>();
            Set<Id> accountIdSet = new Set<Id>();
            Map<Id,Id> conAccountIdMap = new Map<Id,Id>();
            
            for(Contact c:trigger.new){
                if (c.Role__c != null && c.Role__c.contains('Legal Representative'))
                    accountIdSet.add(c.accountId);
            }
            
            for(Account a:[SELECT Id, Send_to_Netsuite__c FROM Account WHERE Id IN: accountIdSet]){
                 if(a.Send_to_Netsuite__c == true){
                     conAccountIdMap.put(a.Id,a.Id);
                 }
            }
            
            for(Contact c:trigger.new){
                
                if(conAccountIdMap.get(c.AccountId) != null){
                    System.debug('**** BEGIN CODE for Netsuite & Contact Integration:' + c.Id);
                    conIdList.add(c.Id);
                }            
            }  
            
            if(conIdList.size()>0){
                NetsuiteSyncContactHelper.postDataToNetsuite(conIdList);        
            }
            
            //Set hasRun boolean to false to prevent recursion
            NetsuiteSyncContactHelper.hasRun = true;
        }     
     }*/
}