public class NonFamilyLinkedContractTriggerHandler {
    public static void insertNFLinkedContract(List<Non_Family_Linked_Contracts__c> lNFLCon){
        set<Id> sConIds = new set<Id>();
        for(Non_Family_Linked_Contracts__c nfl : lNFLCon){
            sConIds.add(nfl.Contract__c);
        }
        
        Map<Id,Non_Family_Linked_Contracts__c> mNFLIns = new Map<Id,Non_Family_Linked_Contracts__c>();
        for(Non_Family_Linked_Contracts__c nfl : lNFLCon){
            mNFLIns.put(nfl.Contract__c,nfl);
        }
        System.debug('***mCAddInsert - '+mNFLIns);
        
        // List<Non_Family_Linked_Contracts__c> childContractsCAdd = [SELECT Id,Contract__r.Parent_Contract__c FROM Non_Family_Linked_Contracts__c WHERE Contract__r.Parent_Contract__c IN: sConIDs];
        List<Contract> childContracts = [SELECT Id,Parent_Contract__c FROM Contract WHERE Parent_Contract__c IN: sConIDs];
        // Map<Id,Non_Family_Linked_Contracts__c> mCAddChild = new Map<Id,Non_Family_Linked_Contracts__c>();
        
        // for(Non_Family_Linked_Contracts__c nfl : childContractsCAdd){
        //     mCAddChild.put(nfl.Contract__c,nfl);
        // }
        
        // System.debug('mCAddChild - '+mCAddChild);
        List<Non_Family_Linked_Contracts__c> lNFLToIns = new List<Non_Family_Linked_Contracts__c>();
        if(childContracts!=null&&!childContracts.isEmpty()){
            for(Contract c : childContracts){
                // if(mNFLIns.containskey(c)){
                    Non_Family_Linked_Contracts__c nfl = new Non_Family_Linked_Contracts__c();
                    nfl.Contract__c = c.Id;
                    nfl.Contract_Project__c = mNFLIns.get(c.Parent_Contract__c).Contract_Project__c;
                    lNFLToIns.add(nfl);
                // }
            }
            if(lNFLToIns!=null&&!lNFLToIns.isEmpty()){
                system.debug('***lNFLToIns - '+lNFLToIns);
                insert lNFLToIns;
            }
        }
    }
    public static void updateNFLinkedContract(List<Non_Family_Linked_Contracts__c> lNFLCon,Map<Id,Non_Family_Linked_Contracts__c> mOldNFLCon){
        set<Id> sConIds = new set<Id>();
        set<Id> sConProjIds = new set<Id>();
        
        for(Non_Family_Linked_Contracts__c c : lNFLCon){
            sConIds.add(c.Contract__c);
            //sAccAddIds.add(c.Account_Address__c);
        }
        for(Non_Family_Linked_Contracts__c c : mOldNFLCon.values()){
            sConProjIds.add(c.Contract_Project__c);
        }
        
        Map<Id,Non_Family_Linked_Contracts__c> mNFLIns = new Map<Id,Non_Family_Linked_Contracts__c>();
        for(Non_Family_Linked_Contracts__c nfl : lNFLCon){
            mNFLIns.put(nfl.Contract__c,nfl);
        }
        
        System.debug('***mCapInsert - '+mNFLIns);
        
        List<Non_Family_Linked_Contracts__c> lClonedNFLCon = [SELECT Contract_Project__c,Contract__r.Parent_Contract__c FROM Non_Family_Linked_Contracts__c WHERE Contract__r.Parent_Contract__c IN:sConIds AND Contract_Project__c IN:sConProjIds];
        Map<Id,Non_Family_Linked_Contracts__c> mNFLCon = new Map<Id,Non_Family_Linked_Contracts__c>();
        for(Non_Family_Linked_Contracts__c c : lClonedNFLCon){
            mNFLCon.put(c.Contract__c,c);
        }
        
        List<Non_Family_Linked_Contracts__c> lNFLConToUpd = new List<Non_Family_Linked_Contracts__c>();
        for(Non_Family_Linked_Contracts__c c : mNFLCon.values()){
            if(mNFLCon.containskey(c.Contract__c)){
                
                Non_Family_Linked_Contracts__c nfl = new Non_Family_Linked_Contracts__c();
                nfl.Id = c.Id;
                nfl.Contract_Project__c = mNFLIns.get(c.Contract__r.Parent_Contract__c).Contract_Project__c;
                lNFLConToUpd.add(nfl);
            }
        }
        if((lNFLConToUpd!=null)&&(!lNFLConToUpd.isEmpty())){
            update lNFLConToUpd;
        }
    }
}