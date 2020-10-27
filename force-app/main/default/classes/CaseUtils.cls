/*********************************************************************
Name    : CaseUtils
Author  : David Ragsdale
Date    : 07 September 2010

Usage   : Provides various utility operations for the case object
    
Dependencies : 

Modified By : Shruti Karn
Modified Date : 8 December 2010

Comment : Changed the class to handle bulk operation to Change Owner of the Case.

Modified By : David Ragsdale
Modified Date : 29 March 2011

Comment : Added S2S code to update Case and allow changes to flow back to originating org

*********************************************************************/
global class CaseUtils {

/*********************************************************************
            GLOBAL VARIABLES
**********************************************************************/             
public static boolean chatterFeedUpdated = false;

/*********************************************************************
updateReportHours - updates a hidden field on the Case.  this field
is used in the <> report
*********************************************************************/
/*  Commented By Arindam Laik, replaced by 'Update HourCaseCreated when Case is inserted' WFR
//    @future
    public static void updateReportHours(Set<Id>CaseIds) {
        List<Case> ListCasesToInsert = new List<Case>();
        
        for (Case Cases : [SELECT Id, CreatedDate
            FROM Case WHERE Id IN :CaseIds])        
        {
            String sDate = String.valueOf(Cases.CreatedDate);        
            sDate = sDate.substring(11,13);
            Integer tempHour = Integer.valueOf(sDate);
            Cases.HourCaseCreated__c = tempHour;    
            ListCasesToInsert.add(Cases);
        }// end for

        try {
            //update the list
            update ListCasesToInsert;
        } catch (Exception e) {
            system.debug('Error updating Case ' + e);
        }
          
    }*/

/*********************************************************************
updateS2SAccountId - updates Account ID field on the Case when a S2S case is entered
*********************************************************************/
/*  Commented By Arindam Laik, as the calling trigger is inactive now
@future
    public static void updateS2SAccountId(Set<Id>CaseIds) {
        QESConstants.inFutureContext = true;
        
        List<Case> ListCasesToInsert = new List<Case>();
        
        for (Case Cases : [SELECT Id, CreatedDate
            FROM Case WHERE Id IN :CaseIds])        
        {
            //Cases.AccountId = system.Label.ConnectionAccountId;    
            ListCasesToInsert.add(Cases);
        }// end for

        try {
            //update the list
            update ListCasesToInsert;
        } catch (Exception e) {
            system.debug('Error updating Case ' + e);
        }
          
    }
*/
/***********************************************************************************************
Function to Change Owner of the Case to the CSR of the Account 
whose Cust ID is given in the description
************************************************************************************************/   
   @future   
    public static void changeOwner(map<Id, String> mapCaseCustId)
    {
        QESConstants.inFutureContext = true; 
        list<Case> lstCase = new list<case>(); //  To store list of Cases as it cannot be passed from Trigger
        list<Account> lstAccount = new list<Account>(); // List of Account having the given lsit of Cust Ids.
        list<Account> lstContactAccount = new list<Account>(); // List of Account of the Contact of the Case.
        map<Id,Account> mapContactAccount = new map<Id, Account>(); // List of Contact Id and Account
        try
        {
            lstCase = [Select id,Queue__c,OwnerId,Owner.Username,ContactId  , AccountId , Contact.AccountId from Case where id  in: mapCaseCustId.keySet() limit 500];
            lstAccount = [Select Id,Name,CSR__c, Inside_CSR__c  , QWBS_Cust_ID__c , CSR__r.Id , Inside_CSR__r.Id from Account where QWBS_Cust_ID__c in : mapCaseCustId.Values() limit 500];
            list<Id> lstID = new list<Id>();
            if(!(lstCase.isEmpty()))
            {
                for(integer i=0;i<lstCase.size();i++)
                {    
                    if(lstCase[i].Contact.AccountId != null)
                        lstID.add(lstCase[i].Contact.AccountId);
                }
            
                lstContactAccount = [Select Id,Name,CSR__c, Inside_CSR__c  , QWBS_Cust_ID__c , CSR__r.Id , Inside_CSR__r.Id from Account where Id in : lstID limit 500];
            
                if(!(lstContactAccount.isEmpty()))
                {
                    for(integer i=0;i<lstContactAccount.size();i++)
                    {
                        if(lstCase[i].Contact.AccountId == lstContactAccount[i].Id)
                            mapContactAccount.put(lstCase[i].ContactId , lstContactAccount[i]) ;
                    }
                }
                for(integer i=0;i<lstCase.size();i++)
                {
                    Account acct = new Account();
                    
                    // If the given Cust Id matches with the Cust Id of the Account queried.
                    if(!lstAccount.isEmpty())
                    {
                        if(mapCaseCustId.get(lstCase[i].Id) == lstAccount[i].QWBS_Cust_ID__c)
                        {
                            lstCase[i].AccountId = lstAccount[i].Id;
                            acct = lstAccount[i];
                            
                        }
                    }
                    // If invalid cust id is given
                    else
                    {
                              if(lstCase[i].ContactId != null)            
                              {
                                  if(lstCase[i].Contact.AccountId != null)
                                  {
                                      lstCase[i].AccountId = lstCase[i].Contact.AccountId;
                                      acct = mapContactAccount.get(lstCase[i].ContactId);
                                  }
                              }
                    }
                    
                    if(acct.CSR__c != null)
                    {
                        lstCase[i].OwnerId =  acct.CSR__r.Id;
                    }else if(acct.Inside_CSR__c != null){
                        lstCase[i].OwnerId =  acct.Inside_CSR__r.Id;                        
                    }
                        
                    Database.DMLOptions dlo = new Database.DMLOptions();
                    dlo.EmailHeader.triggerUserEmail = true;
                    lstCase[i].setOptions(dlo);
                }
                
               update lstCase;
           }        
       }
       catch(Exception e)
       {
           system.debug('Exception in Trigger:'+e);
           update lstCase;
       }
    }
    
/***********************************************************************************************
Function to check if the subject of the case belongs to accepted iq cases which needs to be Please contact System Administrator
auto assigned
************************************************************************************************/  

public static boolean checkIfIQCaseToBeAutoAssigned(String subject)
{
        
    Set<String> setOfSubjects = IQ_Cases_Auto_Assigned_To_CSR__c.getAll().keySet();
    
    for(String sub: setOfSubjects)
    {
        if(subject.contains(sub))
        return true;
    }
    
    if(subject.contains(CaseTrigger_Global_Variable__c.getInstance('mcp wib configuration change').Value__c) || subject.contains(CaseTrigger_Global_Variable__c.getInstance('reporting services access requested').Value__c))
    {
         return true;
    }
    
    return false;               
                    
}
/***********************************************************************************************
Function to check if the subject of the case belongs to accepted iq cases which needs to be
assigned to CSR
************************************************************************************************/  

public static boolean checkIfIQCaseToBeAssignedToCSR(String subject)
{
        
    Set<String> setOfSubjects = IQ_Cases_Auto_Assigned_To_CSR__c.getAll().keySet();
    
    for(String sub: setOfSubjects)
    {
        if(subject.contains(sub))
        return true;
    }
            
    return false;               
                    
}

}