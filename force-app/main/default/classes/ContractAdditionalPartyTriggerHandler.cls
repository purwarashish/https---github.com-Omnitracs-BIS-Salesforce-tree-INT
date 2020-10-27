public class ContractAdditionalPartyTriggerHandler{
    public static void insertCAParty(List<Contract_Additional_Parties__c> lCap){
        Set<Id> sConIDs = new Set<Id>();
        for(Contract_Additional_Parties__c c : lCap){
            sConIDs.add(c.Contract__c);
        }
        
        Map<Id,Contract_Additional_Parties__c> mCapIns = new Map<Id,Contract_Additional_Parties__c>();
        for(Contract_Additional_Parties__c ca : lCap){
            mCapIns.put(ca.Contract__c,ca);
        }
        System.debug('***mCapInsert - '+mCapIns);
                    
        // List<Contract_Additional_Parties__c> childContractsCAParty = [SELECT Id,Contract__r.Parent_Contract__c FROM Contract_Additional_Parties__c WHERE Contract__r.Parent_Contract__c IN: sConIDs];
        List<Contract> childContracts = [SELECT Id,Parent_Contract__c FROM Contract WHERE Parent_Contract__c IN: sConIDs];
        // Map<Id,Contract_Additional_Parties__c> mCapChild = new Map<Id,Contract_Additional_Parties__c>();
        
        // for(Contract_Additional_Parties__c caa : childContractsCAParty){
        //     mCapChild.put(caa.Contract__c,caa);
        // }
        
        // System.debug('mCapChild - '+mCapChild);
        
        List<Contract_Additional_Parties__c> lCAPToIns = new List<Contract_Additional_Parties__c>();
        if(childContracts!=null&&!childContracts.isEmpty()){
            for(Contract c : childContracts){
                // if(mCapIns.containskey(c)){
                    Contract_Additional_Parties__c cap = new Contract_Additional_Parties__c();
                    cap.Contract__c = c.id;
                    cap.Additional_Company__c = mCapIns.get(c.Parent_Contract__c).Additional_Company__c;
                    cap.Party_Relation_Type__c = mCapIns.get(c.Parent_Contract__c).Party_Relation_Type__c;
                    cap.Party_Relation_Description__c = mCapIns.get(c.Parent_Contract__c).Party_Relation_Description__c;
                    cap.Relationship_Status__c = mCapIns.get(c.Parent_Contract__c).Relationship_Status__c;
                    cap.Party_Effective_Date__c = mCapIns.get(c.Parent_Contract__c).Party_Effective_Date__c;
                    cap.Party_Expiration_Date__c = mCapIns.get(c.Parent_Contract__c).Party_Expiration_Date__c;
                    lCAPToIns.add(cap);
                // }
            }
            if(lCAPToIns!=null&&!lCAPToIns.isEmpty()){
                system.debug('***lCAPToIns - '+lCAPToIns);
                insert lCAPToIns;
            }
        }
    }
    public static void updateClonedCAParty(List<Contract_Additional_Parties__c> lCap, Map<Id,Contract_Additional_Parties__c> mOldCap) {
        set<Id> sConIds = new set<Id>();
        set<Id> sAddCompany = new set<Id>();
        
        for(Contract_Additional_Parties__c cap : lCap){
            sConIds.add(cap.Contract__c);
//          sAddCompany.add(cap.Additional_Company__c);
            System.debug('***1-sConIds - ' +sConIds);
//          System.debug('***1-sAddCompany - ' +sAddCompany);
        }
        
        for(Contract_Additional_Parties__c cap : mOldCap.values()){
            sAddCompany.add(cap.Additional_Company__c);
            System.debug('***1-sAddCompany - ' +sAddCompany);
        }
        Map<Id,Contract_Additional_Parties__c> mCapIns = new Map<Id,Contract_Additional_Parties__c>();
        for(Contract_Additional_Parties__c ca : lCap){
            mCapIns.put(ca.Contract__c,ca);
        }
        System.debug('***mCapInsert - '+mCapIns);
        
        List<Contract_Additional_Parties__c> lCapChild = [SELECT Id,Contract__r.Parent_Contract__c, Additional_Company__c, Party_Relation_Type__c, Party_Relation_Description__c, Relationship_Status__c, Party_Effective_Date__c, Party_Expiration_Date__c FROM Contract_Additional_Parties__c WHERE Contract__r.Parent_Contract__c In:sConIds AND Additional_Company__c In: sAddCompany];
        System.debug('***2-lCapChild - '+lCapChild);
        Map<Id,Contract_Additional_Parties__c> mCAPchild = new Map<Id, Contract_Additional_Parties__c>();
        for(Contract_Additional_Parties__c c : lCapChild){
            mCAPchild.put(c.Contract__c,c);
            System.debug('***2-lCapChild - '+lCapChild);
        }
        List<Contract_Additional_Parties__c> lCAPToUpd = new List<Contract_Additional_Parties__c>();
        for(Contract_Additional_Parties__c c : mCAPchild.values()){
            Contract_Additional_Parties__c capp = new Contract_Additional_Parties__c();
            capp.Id=c.Id;
            
            capp.Additional_Company__c = mCapIns.get(c.Contract__r.Parent_Contract__c).Additional_Company__c;
      
            capp.Party_Relation_Type__c = mCapIns.get(c.Contract__r.Parent_Contract__c).Party_Relation_Type__c;

            capp.Party_Relation_Description__c = mCapIns.get(c.Contract__r.Parent_Contract__c).Party_Relation_Description__c;
      
            capp.Relationship_Status__c = mCapIns.get(c.Contract__r.Parent_Contract__c).Relationship_Status__c;
      
            capp.Party_Effective_Date__c = mCapIns.get(c.Contract__r.Parent_Contract__c).Party_Effective_Date__c;
      
            capp.Party_Expiration_Date__c = mCapIns.get(c.Contract__r.Parent_Contract__c).Party_Expiration_Date__c;
          
            lCAPToUpd.add(capp);
        }
        
        
        
        
        
        
        
//      for(Contract_Additional_Parties__c c : mCAP.values()){
// //           if(mCAP.containskey(c.Contract__c)){
//              System.debug('***3');
//              Contract_Additional_Parties__c capp = new Contract_Additional_Parties__c();
//              capp.Id = mCAP.get(c.Parent_Contract__c).Id;
//              capp.Additional_Company__c=c.Additional_Company__c;
//              if(c.Party_Relation_Type__c!=mOldCap.get(c.Id).Party_Relation_Type__c){
//                  capp.Party_Relation_Type__c = c.Party_Relation_Type__c;
//                  System.debug('***PARTY');
//              }
//              if(c.Party_Relation_Description__c!=mOldCap.get(c.Id).Party_Relation_Description__c){
//                  capp.Party_Relation_Description__c = c.Party_Relation_Description__c;
//              }
//              if(c.Relationship_Status__c!=mOldCap.get(c.Id).Relationship_Status__c){
//                  capp.Relationship_Status__c = c.Relationship_Status__c;
//              }
//              if(c.Party_Effective_Date__c!=mOldCap.get(c.Id).Party_Effective_Date__c){
//                  capp.Party_Effective_Date__c = c.Party_Effective_Date__c;
//              }
//              if(c.Party_Expiration_Date__c!=mOldCap.get(c.Id).Party_Expiration_Date__c){
//                  capp.Party_Expiration_Date__c = c.Party_Expiration_Date__c;
//              }
                
//              lCAPToUpd.add(capp);
// //           }
//      }
        if((lCAPToUpd!=null) && (!lCAPToUpd.isEmpty())){
            update lCAPToUpd;
        }
    }
}