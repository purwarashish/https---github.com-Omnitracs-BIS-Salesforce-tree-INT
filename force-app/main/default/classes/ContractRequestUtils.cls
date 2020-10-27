public class ContractRequestUtils{
     
       
    // to update the value of AssignedTo and Sales Director with the Contract Request's Account's
    // Sales Director and Contract Administrator.
    public static void updateContractRequest(map<Id, Contract_Request__c> mapContReq)
    { 
        Id contReqRecType = [Select r.Id, r.DeveloperName From RecordType r where DeveloperName = 'FleetRisk_Advisors_Agreement' and SobjectType= 'Contract_Request__c' limit 1 ].ID;
        Id acctRecType = [Select r.Id, r.DeveloperName From RecordType r where DeveloperName = 'FleetRisk_Advisors_Accounts' and SobjectType= 'Account' limit 1 ].ID;
        
        list<Account> lstAccount = [Select Id, Account_Manager__c, FRA_Account_Manager__c, Sales_Director__c, Contracts_Administrator__c,FRA_Contracts_Administrator__c,RecordTypeId FROM Account WHERE Id in : mapContReq.keySet() limit 10000];
        
        for(integer i=0;i<lstAccount.size();i++)
        {            
             //Populate Sales Director
             mapContReq.get(lstAccount[i].Id).Sales_Director__c = lstAccount[i].Sales_Director__c;
             
             //if account rec type = fleetseek advisors - update the FRA Acount Manager to Account Manager on Account record
             if(lstAccount[i].RecordTypeId == acctRecType)
             {
                mapContReq.get(lstAccount[i].Id).FRA_Account_Manager__c = lstAccount[i].Account_Manager__c;
             //else update Conatract request FRA Account manger = FRA account manager on the account    
             }else{
                mapContReq.get(lstAccount[i].Id).FRA_Account_Manager__c = lstAccount[i].FRA_Account_Manager__c;
             }
             
             //Check account rec type against contact rec type / Not FRA Account rec type / list value for FRA_Contact_Administrator is not null
             if((mapContReq.get(lstAccount[i].Id).RecordTypeId == contReqRecType) && (lstAccount[i].RecordTypeId != acctRecType) && (lstAccount[i].FRA_Contracts_Administrator__c != null))
             {
                //Update Assigned To field
                mapContReq.get(lstAccount[i].Id).Assigned_To__c = lstAccount[i].FRA_Contracts_Administrator__c;
             }
             else
             {
                //if no assigned to value
                if(mapContReq.get(lstAccount[i].Id).Assigned_To__c == NULL)
                { 
                    mapContReq.get(lstAccount[i].Id).Assigned_To__c = lstAccount[i].Contracts_Administrator__c;
                }
                   
             } 
        }
    }
}