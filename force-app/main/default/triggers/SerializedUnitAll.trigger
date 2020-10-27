/**
Author : Avinash Kaltari, Salesforce.com Developer, TCS.

Description: Trigger on Serialized Unit, to Update the PartnerScorecard record associated with its Account.

Events : After insert, After update, After delete

*/

trigger SerializedUnitAll on Serialized_Units__c (after insert, after update, after delete) 
{
/*
    List<Id> lstDraftAccountId = new List<Id>();
    List<Contact> lstContact = new list<Contact>();
    List<User> lstUser = new list<User>();
    List<Id> lstId = new List<Id>();
    
    
    if(Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate || Trigger.isDelete))
    {
        if(Trigger.isDelete)
        {
            for(Serialized_Units__c ser : Trigger.Old)
            {
                lstDraftAccountId.add(ser.Account__C);
            }
        }
        else    
        {
            for(Serialized_Units__c ser : Trigger.New)
            {
                lstDraftAccountId.add(ser.Account__C);
                
//Add Accounts, that were referenced by Serialized Unit earlier, to update their Partner Scorecards after the unit is updated
                if(Trigger.isUpdate && Trigger.OldMap.get(ser.id) != null && ser.OwnerId != Trigger.OldMap.get(ser.id).OwnerId)
                    lstDraftAccountId.add(Trigger.OldMap.get(ser.id).Account__C);
            }
        }
        
        if(lstDraftAccountId.size() > 0)
        {
            List<ID> lstOwnerId = new List<ID>();
            List<Account> lstChildAccount = new List<Account>();
            lstChildAccount = [select OwnerId from Account where Id IN :lstDraftAccountId limit 50000]; 
            
            for (Account a : lstChildAccount)
                lstOwnerId.add(a.OwnerId);
            
            if(lstOwnerId.size() > 0)
            {
                List<User> lstOwnerUser = new List<User>();
                lstOwnerUser = [select name, AccountId from User where Id IN :lstOwnerId limit 50000];
                lstDraftAccountId = new List<Id>();
            
                for (User u: lstOwnerUser)
                    lstDraftAccountId.add(u.AccountId);
            }
        }
        
        

        if(lstDraftAccountId.size() > 0)
        {
            List<Partner_Scorecard__c> lstDraftScorecard = [select name, Account__c, Account__r.Id from Partner_Scorecard__c where Account__r.Id IN :lstDraftAccountId AND Current_Scorecard__c = true limit 50000];
            if (lstDraftScorecard != null && lstDraftScorecard.size() > 0)
                update lstDraftScorecard;
        }
    }
    */
}