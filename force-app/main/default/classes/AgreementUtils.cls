/*********************************************************************************************************
Objective: Utils class for all code related to Agreement(SIGN_Agreement) object

Modified By  : Rittu Roy
Modified Date: Nov 14, 2015
Purpose      : Added method 'updateContractStatus' to update contract and opportunity statuses once customer has sigend the 
               agreement.

**********************************************************************************************************/

public class AgreementUtils{
    public static final string WAITING_COUNTER_SIGN = 'Waiting for Counter-Signature';
    public static final string SIGNED_BY_CUST = 'Signed by Customer';
    public static final string SALES_COMPLETE = 'Sales Complete';
        
    public static void updateContractStatus(List<echosign_dev1__SIGN_Agreement__c> lstAgmnts,Map<Id,echosign_dev1__SIGN_Agreement__c> mapOldAgmnts){
        //List<echosign_dev1__SIGN_Agreement__c> lstAgmntsUpdated = new List<echosign_dev1__SIGN_Agreement__c>();
        List<Id> lstContractIds = new List<Id>();
        List<Id> lstOpptyIds = new List<Id>();
        List<Contract> lstContracts = new List<Contract>(); //List of contracts whose status need to be updated
        List<Opportunity> lstOppty = new List<Opportunity>();//List of opportunities whose stages need to be updated
        
        //Get list of contracts and opportunities whose Agreement status has been changed to Waiting for Counter Signature 
        for(echosign_dev1__SIGN_Agreement__c agmnt : lstAgmnts){
            if (agmnt.echosign_dev1__Status__c == WAITING_COUNTER_SIGN && agmnt.echosign_dev1__Status__c != mapOldAgmnts.get(agmnt.Id). echosign_dev1__Status__c){
                
                if (agmnt.echosign_dev1__Contract__c != null){
                    lstContractIds.add(agmnt.echosign_dev1__Contract__c);
                }
                if (agmnt.echosign_dev1__Opportunity__c != null){
                    lstOpptyIds.add(agmnt.echosign_dev1__Opportunity__c);
                }
            }
        }
        
        //Queries contract records
        for(Contract contractRecord : [SELECT id, Status FROM Contract WHERE Id IN :lstContractIds  LIMIT 50000]){
            contractRecord.Status = SIGNED_BY_CUST;
            lstContracts.add(contractRecord);
        }
        
        //Queries opportunity records
        for(Opportunity oppty : [SELECT id, StageName FROM Opportunity WHERE Id IN :lstOpptyIds  LIMIT 50000]){
            oppty.StageName = SALES_COMPLETE;
            lstOppty.add(oppty);
        }
        
        //Update Contracts
        if (!lstContracts.isEmpty()){
            try{
                update lstContracts;
            }Catch(Exception e){
                System.debug('Error occured while updating Contract: ' + e.getMessage());
            }
        }
        
        //Update Opportunities
        if (!lstOppty.isEmpty()){
            try{
                update lstOppty;
            }Catch(Exception e){
                System.debug('Error occured while updating Opportunity: ' + e.getMessage());
            }
        }
    }
}