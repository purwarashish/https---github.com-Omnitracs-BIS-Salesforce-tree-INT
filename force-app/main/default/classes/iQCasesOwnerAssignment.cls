public class iQCasesOwnerAssignment {

/***********************************************************************************
Date: 5/9/2010 
Author: Shruti Karn, Salesforce.com Developer
Tata Consultancy Services Limited

CR# 21051
************************************************************************************/

public static Integer firstExxecution;

@ future
public static void changeOwner(Id CaseObjId, String CustId,Id CaseAccountId)
{
    firstExxecution = 1;// This method should be executed only once in one call
    Id contact_AccountId;
    Id Case_contactId;
    Account acct;
    Case CaseObj;
    try
    {                      
        CaseObj = [Select id,Queue__c,OwnerId,Owner.Username,ContactId from Case where id =: CaseObjId limit 1];
        Case_contactId = CaseObj.ContactId;
        /* If contact exists for the case created via Email2Case, and a valid customer Id is given then
           the Account associated with the Customer Id shoul be searched and the Case should be updated with same.
           Otherwise, the Contact's Account should be the Case's Account.*/
        if(CaseObj.ContactId != null)
        {
            Contact acctId = [select AccountId from Contact where id = :CaseObj.ContactId limit 1];
            if(acctId != null)
                contact_AccountId = acctId.AccountId ;
           if(CaseAccountId != null)
           {
               if(CaseObj.ContactId != null)
               {
                   if(acctId.AccountId != null && CaseAccountId != acctId.AccountId)
                   {
                       acct = [Select Id,Name,CSR__c from Account where Id = : CaseAccountId limit 1];
                   }
                   else
                   {
                       if(custid.trim() != '')
                       {
                           acct = [Select Id,Name,CSR__c from Account where QWBS_Cust_ID__c = : custid limit 1];
                       }
                       else
                       {
                           update CaseObj;
                       }
                   }//end of if(acctId.AccountId != null && CaseAccountId != acctId.AccountId)
               }
               else
               {
                   acct = [Select Id,Name,CSR__c from Account where Id = : CaseAccountId limit 1];
               }//end ofif(CaseObj.ContactId != null)
           }//end of if(CaseAccountId != null)
        }
        else
        {
            if(custid.trim() != '')
                acct = [Select Id,Name,CSR__c from Account where QWBS_Cust_ID__c = : custid limit 1];
            else
                update CaseObj;
        }// end of if(CaseObj.ContactId != null)
       
    }//end of try block
    catch(Exception e)
    {
        system.debug('No Account Found'+e);
        update CaseObj;
    }
    
    if(acct!=null)
    {
        //if(contact_AccountId == null)
        CaseObj.AccountId = acct.Id;
        User Owner_Case;
        if(acct.CSR__c != null)
        {
            try
            {
               Owner_Case = [select Id, Name,Queue__c from User where Id =: acct.CSR__c limit 1];
            }
            catch(Exception e)
            {
                system.debug('Exception:'+e);
                update CaseObj;
            }// end of try-catch
        }
        try
        {
            if(acct.CSR__c != null)
                CaseObj.OwnerId = Owner_Case.Id;
            Database.DMLOptions dlo = new Database.DMLOptions();
            dlo.EmailHeader.triggerUserEmail = true;
            CaseObj.setOptions(dlo);
            update CaseObj;
        }
        catch(Exception e)
        {
            system.debug('Error in updating case:'+e);
        } //end of try-catch
        
    }

    
}




}