/*********************************************************************************
Program:        QuoteContract Class
Programmer:     Rex David - CloudSherpas
Date:           Oct 02, 2014

Modified By  : Rittu Roy
Modified Date: 11-14-2015
Objective    : Rewrote the entire logic. Contract will be created when Opportunity stage is Negotiate and Primary Quote is Approved.
               Removed code to create contract addresses for new contract.
**********************************************************************************/ 
public class QuoteContract {
    public static final String QUOTE_APPROVED = 'Approved';
    public static final String OPPTY_NEGOTIATE = 'Negotiate';
    public static final String MEX_BU = 'Omnitracs MX';
    public static final String CUST_PORTAL = 'Customer Portal';
    public static final String CONTRACT_REQ = 'Contract Requested';
    public static final String PROF_SERVCS_PIKLIST = 'Professional Services Agreement';
    public static final String RECTYPE_PROF_SERVCS = 'Professional Services Agreement';
    public static final String RECTYPE_CUST_AGMNT = 'Customer Agreement';
    public static boolean contractCreateRunOnce = false;//TO prevent method running in recursion
    
    public static void createContract (List<Opportunity> lstOppty, Map<Id,Opportunity> mapOldOppty){
        List<Opportunity> lstOpptyWithProducts = new List<Opportunity>(); //List of opportunities with their related opportunity products
        List<Id> lstOpptyIds = new List<Id>();
        List<Contract> lstContractsToInsert = new List<Contract>(); //Contract records to be created
        Map<String, Schema.RecordTypeInfo> mapContractRecTypes = Schema.SObjectType.Contract.getRecordTypeInfosByName(); //Schema of Contract record types
        Map<String,Id> mapOpptyToId = new Map<String,Id>(); //Map of opportunity to its Id, where key value is a combination of opportunity name and its account Id
        List<Opportunity_Contract__c> lstOpptyContracts;
        Boolean errorThrown = false;
        contractCreateRunOnce = true;
        
        //Collect Ids of opportunities whose stage is Negotiate and Primary Quote Approval status is Approved
        for(Opportunity oppty : lstOppty){
            if ((oppty.Primary_Quote_Approval_Status__c != mapOldOppty.get(oppty.Id).Primary_Quote_Approval_Status__c || oppty.StageName != mapOldOppty.get(oppty.Id).StageName)
            && (oppty.Primary_Quote_Approval_Status__c == QUOTE_APPROVED && oppty.StageName == OPPTY_NEGOTIATE)
            && oppty.Owner_Business_Unit__c <> MEX_BU && oppty.Order_Type__c <> CUST_PORTAL){
            
                lstOpptyIds.add(oppty.Id);
            
            }
        }
        
        //Gets Opportunities along with their products
        if (!lstOpptyIds.isEmpty()){
            lstOpptyWithProducts = [SELECT Id, Name, AccountId,Account.Contracts_Administrator__c,(SELECT Id, Product2.Contract_Record_Type__c FROM OpportunityLineItems) FROM Opportunity WHERE Id IN :lstOpptyIds LIMIT 50000];
        }
        
        //Create Contract records for each of the opportunity
        for (Opportunity oppty : lstOpptyWithProducts){
            Boolean allProfServs = true;
            
            Contract newContract  =   new Contract();
            newContract.Contract_Title__c = oppty.Name;
            newContract.AccountId = oppty.AccountId;
            newContract.Status = CONTRACT_REQ;
            newContract.OwnerId = oppty.Account.Contracts_Administrator__c;
            
            //Identify Record type to be assigned. If all the opportunity products have 'Contract Record type' as Professional Services, assign Professional Services Agreement as the record type.
            //Else, assign 'Customer Agreement' record type     
            if (!oppty.OpportunityLineItems.isEmpty()){
                for(OpportunityLineItem lineItem : oppty.OpportunityLineItems){
                    if (lineItem.Product2.Contract_Record_Type__c != PROF_SERVCS_PIKLIST){
                        allProfServs = false;
                    }
                }
            }
            else{
                allProfServs = false;
            }
            
            //Assigns record type
            if (allProfServs && mapContractRecTypes.containsKey(RECTYPE_PROF_SERVCS)){
                newContract.RecordTypeId = mapContractRecTypes.get(RECTYPE_PROF_SERVCS).getRecordTypeId();
            }
            else if (!allProfServs && mapContractRecTypes.containsKey(RECTYPE_CUST_AGMNT)){
                newContract.RecordTypeId = mapContractRecTypes.get(RECTYPE_CUST_AGMNT).getRecordTypeId();
            }

            lstContractsToInsert.add(newContract);
            
            //Populate mapOpptyToId
            mapOpptyToId.put(oppty.Name + ':' + oppty.accountId,oppty.Id);
        }
        
        //Insert contracts
        if(!lstContractsToInsert.isEmpty()){
            try{
                insert lstContractsToInsert;
            }
            catch(DMLException e){
                errorThrown = true;
                System.debug('There was a problem inserting contracts - ' + e.getMessage());
            }
        }
        
        //Creates 'Opportunity Contract' record
        if (!errorThrown){
            lstOpptyContracts = new List<Opportunity_Contract__c>();
            for (Contract contractRec : lstContractsToInsert){
                if (contractRec.Id != null && mapOpptyToId.containsKey(contractRec.Contract_Title__c + ':' + contractRec.AccountId)){
                    Opportunity_Contract__c newOpptyContract = new Opportunity_Contract__c(Contract__c = contractRec.Id, Opportunity__c = mapOpptyToId.get(contractRec.Contract_Title__c + ':' + contractRec.AccountId));
                    lstOpptyContracts.add(newOpptyContract);
                }
            }
            
            if(!lstOpptyContracts.isEmpty()){
                try{
                    insert lstOpptyContracts;
                }
                catch(DMLException e){
                    System.debug('There was a problem inserting opportunity contracts - ' + e.getMessage());
                }
            }
        }
    }
}