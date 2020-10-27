/***************************************************************************************************
Program:        QuoteContract Class
Programmer:     Rex David - CloudSherpas
Date:           Oct 08, 2014
****************************************************************************************************/ 
public class ContractTriggerHandler {

    // Following piece code is added by Abhishek to stop the recursive logic as per case- #01820444
   
    private static boolean runBefore = true;
    private static boolean runAfter = true;

    public static boolean runOnceBefore(){
        if(runBefore){
            runBefore = false;
            return true;
        }
        else{
            return runBefore ;
        }
    }
    
    public static boolean runOnceAfter(){
        if(runAfter){
            runAfter = false;
            return true;
        }
        else{
            return runAfter ;
        }
    }
    
    
    
    public static void preventContractActivated (List<Contract> updatedContract, Map<Id, Contract> oldMap){
        for(Contract c : updatedContract){
            Contract oldCont = oldMap.get(c.Id);
            if(c.Status != oldCont.Status && c.Status == 'Active' && c.Activate_Required__c != 'Yes'){
                c.AddError('Please Activate the Contract using Activate button.');
            }
            if(c.Status != oldCont.Status && oldCont.Status == 'Active'){
                c.IsActive__c = false;
                c.Bypass_Rules__c = false;
                c.Activate_Required__c = 'No';
            }
        }
    }
    
    public static void activateContractOpportunities(Map<Id, Contract> oldMap, Map<Id, Contract> newMap) {
        Map<Id, Contract> activatedContracts = new Map<Id, Contract>();
        List<Opportunity> oppsToUpdate = new List<Opportunity>();
        Set<Id> oppIdsToUpdate = new Set<Id>();
            
        for (Contract c : newMap.values()){ 
            if (oldmap.get(c.Id).Status != 'Active' && c.Status == 'Active') {
                activatedContracts.put(c.Id, c);
            }
        }
        
        if (activatedContracts.size() > 0) {
            //Query for a list of effected Opportunities
            List<Opportunity_Contract__c> oppContracts = new List<Opportunity_Contract__c>();
            List<Opportunity_Contract__c> oppCons = [SELECT Opportunity__c FROM Opportunity_Contract__c WHERE Contract__c IN :activatedContracts.keySet()];
            Set<Id> oppIds = new Set<Id>();
            for (Opportunity_Contract__c oc : oppCons) {
                oppIds.add(oc.Opportunity__c);
            }
            oppContracts = [SELECT Contract__c, Opportunity__c, Contract__r.Status FROM Opportunity_Contract__c WHERE Opportunity__c IN :oppIds];

            //Check to see if there are other non-activated Contracts for the Opportunity
            
            for (Contract con : activatedContracts.values()) {
                Boolean found = false;
                for (Opportunity_Contract__c oc : oppContracts) {
                    if (oc.Contract__c != con.Id && oc.Contract__r.Status != 'Active') {
                        found = true;
                        break;
                    }
                }
                if (!found) {
                    for (Opportunity_Contract__c oc : oppContracts) {
                        if (oc.Contract__c == con.Id) {
                            oppIdsToUpdate.add(oc.Opportunity__c);
                        }
                    }
                }
            }

            for (Id oppId : oppIdsToUpdate) {
                Opportunity o = new Opportunity(Id = oppId);
                o.Contract_Activated__c = true;
                o.Legal_Review__c = 'Approved';
                oppsToUpdate.add(o);
            }
            
            if (oppsToUpdate.size() > 0) {
                update oppsToUpdate;
                System.debug('-- UPDATED: oppsToUpdate size = '+oppsToUpdate.size());
            }
        }
    }
    
    //Sripathi Gullapalli, Calling Spring CM when the contract is inactive
     public static void CallSpringCMOnTerminate(Map<Id, Contract> oldMap, Map<Id, Contract> newMap) {
        List<Contract> activatedContracts = new List<Contract>();
        Set<ID> contractIdSet = new Set<ID>();
        for (Contract c : newMap.values()){ 
            if (oldmap.get(c.Id).Status != 'Inactive' && c.Status == 'Inactive') {
                contractIdSet.add(c.ID);
            }
        }
        activatedContracts = [select Id, name, Account.name, AccountId, EndDate, Parent_Contract__c, Parent_Contract__r.name,ContractNumber from Contract where ID in :contractIDSet];
        if(activatedContracts != null && activatedContracts.size() > 0){
            SpringCMRestUtils.StartWorkflowTermination(activatedContracts,'Contract Termination');
        }
     }
     
     public static void updateOpportunity(List<Contract> newList) {
        Set<Id> oppIdSet = new Set<Id>();
        for (Contract c : newList){ 
            if(String.isNotBlank(c.SBQQ__Opportunity__c)){
                oppIdSet.add(c.SBQQ__Opportunity__c);
            }
        }
        
        if(oppIdSet.size() > 0){
            List<Opportunity> updateOppList = new List<Opportunity>();
            for(Opportunity opp : [select Id, Contracted__c from Opportunity where Id in :oppIdSet]){
                if(!opp.Contracted__c){
                    opp.Contracted__c = true;
                    updateOppList.add(opp);
                }
            }
            if(updateOppList.size() > 0){
                update updateOppList;
            }
        }
     }   
     
     //Cody Worth, Wrapping up fields from a Master Contracts quote for display on the Contract record on creation
    public static void populatePriceIncreaseCap(Map<Id, Contract> oldMap, Map<Id, Contract> newMap){
       
       List<Contract> contractsToUpdate = new List<Contract>();
       //Set<ID> contractSet = new Set<ID>();
       Map<Contract, ID> contractToQuote = new Map<Contract, ID>();
       
           for(contract c : newMap.values()){
           if((c.Agreement_Type__c == 'Master' || c.Contract_Category_1__c == 'Omni 1') && c.SpringCM_Quote__c != null && oldMap.get(c.ID).SpringCM_Quote__c == null){
               //contractset.add(c.ID);
               contractToQuote.put(c, c.SpringCM_Quote__c);
           }
       }   
       
       List<SBQQ__Quote__c> listOfQuotesToPullFrom = [SELECT ID, Uplift_Cap__c, Uplift_Language__c FROM SBQQ__Quote__c where ID IN: contractToQuote.values()];
       
       for(Contract c : contractToQuote.keySet()){
           for(SBQQ__Quote__c q  : listOfQuotesToPullFrom){
               //if(c.Agreement_Type__c == 'Master' && c.SpringCM_Quote__c == q.ID){
                   system.debug('Quote ID is: ' + String.valueOf(c.SpringCM_Quote__c));
                   if(q.Uplift_Language__c != null){
                       String string1 = string.valueOf(q.Uplift_Cap__c);
                       system.debug('Uplift cap is: '  + string1);
                       String string2 = q.Uplift_Language__c;
                       system.debug('Uplift Language is: ' + string2);
                       if(string1 != null){
                           string2 = string2.replaceAll('_____', string1);
                       }
                       system.debug('String 2 became: ' + string2);
                       c.Price_Increase_Cap__c = string2;
                       
                       contractsToUpdate.add(c);
                   }

                    else{
                    c.Price_Increase_Cap__c = 'Uncapped';
                    contractsToUpdate.add(c);
                    }
               //}
               
           }
           
       }
       //if(contractsToUpdate.isEmpty() == false) update contractsToUpdate;
    }
     

    // Roesler - 20170405 - renames a renewed SB Contract to "INACTIVE: ..."
    public static void renameSBParentContract(List<Contract> newContracts) {
        
        // map to hold the old contract title 
        Map<Id,String> contractTitles = new Map<Id,String>();
        
        // map from the renewal opportunity id to the new contract id
        Map<Id,Id> oppIDMap = new Map<Id,Id>();
        
        // maps back and forth between the new and renewed (old) contract
        Map<Id,Id> new2OldContract = new Map<Id,Id>();
        Map<Id,Id> old2NewContract = new Map<Id,Id>();

        // list of all contracts to be updated
        List<Contract> updatedContracts = new List<Contract>();
        
     
        // Create maps
        
        // Step 1: create a map from the renewal opportunity ID to the newly-created contract ID
        for (Contract c: newContracts){
            if(String.isNotBlank(c.SBQQ__Opportunity__c)){
                oppIDMap.put(c.SBQQ__Opportunity__c,c.Id);
            }
        }
        
        // Step 2: get the old (renewed) contract ID from the opportunity and map it to the newly-created ID
        if(oppIDMap.size() > 0){
            for(Opportunity opp : [select Id, SBQQ__RenewedContract__c from Opportunity where Id in :oppIDMap.keySet()]){
                if(String.isNotBlank(opp.SBQQ__RenewedContract__c)){
                    new2OldContract.put(oppIDMap.get(opp.Id),opp.SBQQ__RenewedContract__c);
                    old2NewContract.put(opp.SBQQ__RenewedContract__c,oppIDMap.get(opp.Id));
                    System.debug('Contract Trigger Handler: new contract Id = ' + oppIDMap.get(opp.Id));
                    System.debug('Contract Trigger Handler: renewed contract Id = ' + opp.SBQQ__RenewedContract__c);
                }
            }         
        }
        

        
        if(old2NewContract.size() > 0){
        
            // store the name of the old contract in the contractTitle map for future reference
            // rename the old contract
            for (Contract c: [select Id, Contract_Title__c from Contract where Id in :old2NewContract.keySet()]){
                contractTitles.put(c.Id,c.Contract_Title__c);
                System.debug('ContractTriggerHandler: Old Contract Title put into map = ' + contractTitles.get(c.Id));
                c.Contract_Title__c = 'INACTIVE: ' + c.Contract_Title__c;
                System.debug('ContractTriggerHandler: New Contract Title for old Id ' + c.Id + ' = ' + c.Contract_Title__c);
                updatedContracts.add(c);
            }
            
            // rename the new contract to match the old (renewed) contract's previous title
            // store the old (renewed) contract ID
            for (Contract c: [select id, Contract_Title__c,Renewed_Contract__c from Contract where Id in :new2OldContract.keySet()]){
                c.Contract_Title__c = contractTitles.get(new2OldContract.get(c.id));
                System.debug('ContractTriggerHandler: New Contract Title for new Id ' + c.Id + ' = ' + c.Contract_Title__c);
                c.Renewed_Contract__c = new2OldContract.get(c.Id);
                System.debug('ContractTriggerHandler: Renewed Contract for new Id ' + c.Id + ' = ' + c.Renewed_Contract__c);
                updatedContracts.add(c);
            }
        
            update updatedContracts;
        }
    }

    ///////////////////////////////////////////////////////////////////////////
    /// By:   Arman Shah
    /// Date: 8/25/2018
    /// For setting the new Contract value on an Asset, when the old Contract has
    /// been Renewed
    ///////////////////////////////////////////////////////////////////////////
    public static void setContractOnAssets(List<Contract> newContracts) {
        System.debug('-- IN setContractOnAssets --');
        
        System.debug('-- newContracts = '+newContracts);

        // map from the renewal opportunity id to the new contract id
        Map<Id,Id> oppToNewContractMap = new Map<Id,Id>();
        
        // Step 1: create a map from the renewal opportunity ID to the newly-created contract ID
        for (Contract c: newContracts) {
            if (String.isNotBlank(c.SBQQ__Opportunity__c)) {
                oppToNewContractMap.put(c.SBQQ__Opportunity__c, c.Id);
            }
        }
        System.debug('-- oppToNewContractMap = '+oppToNewContractMap);
        
        // For the Opps, find the newContracts and the oldContracts
        // Step 2: get the old (renewed) contract ID from the opportunity and map it to the newly-created ID
        Set<Id> oldContractIdSet = new Set<Id>();
        Map<Id,Id> oldToNewContractMap = new Map<Id,Id>();

        if (oppToNewContractMap.size() > 0) {
            for (Opportunity opp : [SELECT Id, SBQQ__RenewedContract__c 
                FROM Opportunity 
                WHERE Id IN :oppToNewContractMap.keySet() ])
            {   
                Id oldContractId = opp.SBQQ__RenewedContract__c;
                System.debug('-- oldContractId = '+oldContractId);

                Id newContractId = oppToNewContractMap.get(opp.Id); // Get from Trigger.new, because NOT in Db yet
                System.debug('-- newContractId = '+newContractId);

                if (String.isNotBlank(oldContractId)) { // if Renewed Contract exists
                    oldContractIdSet.add(oldContractId);  
                    oldToNewContractMap.put(oldContractId, newContractId);
                }
            }         
        }
        System.debug('-- oldContractIdSet = '+oldContractIdSet);
        System.debug('-- oldToNewContractMap = '+oldToNewContractMap);

        if (oldContractIdSet.isEmpty()) { 
            System.debug('-- ZERO RenewedContracts exist --');
        }
        else {
            System.debug('-- Processing for RenewedContracts --');
            // Create oppToNewContractMap and oldContractIdSet, then oldToNewContractMap

            //For each oldContract, find its Assets; 
            Map<Id, Asset> sbAssetsMap = 
                new Map<Id, Asset>([SELECT Id, Contract__c
                    FROM Asset
                    WHERE Contract__c IN : oldContractIdSet]);

            System.debug('-- sbAssetsMap size ='+sbAssetsMap.size());
            System.debug('-- sbAssetsMap ='+sbAssetsMap);

            // Set the Contract__c for the related Asset
            List<Asset> assetsToUpdate = new List<Asset>();
            for (Asset a : sbAssetsMap.values()) {         
                // then need to find the newContract and set its value on the Asset
                Id newContractId = oldToNewContractMap.get(a.Contract__c); // sets newContract on Asset
                System.debug('-- newContractId = '+newContractId);
                a.Contract__c = newContractId;
                assetsToUpdate.add(a);
            }

            try {
                update assetsToUpdate;
                System.debug('-- UPDATED Assets = '+assetsToUpdate);
            }
            catch(Exception e) {
                System.debug(e.getStackTraceString());
            }
        }
    }
}