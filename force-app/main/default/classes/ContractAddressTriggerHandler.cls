public class ContractAddressTriggerHandler{
    public static void insertContAddress(List<Contract_Address__c> lCAdd){
        set<Id> sConIds = new set<Id>();
        for(Contract_Address__c c : lCAdd){
            sConIDs.add(c.Contract__c);
        }
        
        Map<Id,Contract_Address__c> mCAddIns = new Map<Id,Contract_Address__c>();
        for(Contract_Address__c ca : lCAdd){
            mCAddIns.put(ca.Contract__c,ca);
        }
        System.debug('***mCAddInsert - '+mCAddIns);
        
        // List<Contract_Address__c> childContractsCAdd = [SELECT Id,Contract__r.Parent_Contract__c FROM Contract_Address__c WHERE Contract__r.Parent_Contract__c IN: sConIDs];
        List<Contract> childContracts = [SELECT Id,Parent_Contract__c FROM Contract WHERE Parent_Contract__c IN: sConIDs];
        // Map<Id,Contract_Address__c> mCAddChild = new Map<Id,Contract_Address__c>();
        
        // for(Contract_Address__c caa : childContractsCAdd){
        //     mCAddChild.put(caa.Contract__c,caa);
        // }
        
        // System.debug('mCAddChild - '+mCAddChild);
        List<Contract_Address__c> lCAddToIns = new List<Contract_Address__c>();
        if(childContracts!=null&&!childContracts.isEmpty()){
            for(Contract c : childContracts){
                // if(mCAddIns.containskey(c)){
                    Contract_Address__c cadd = new Contract_Address__c();
                    cadd.Contract__c = c.Id;
                    cadd.Location_Type__c = mCAddIns.get(c.Parent_Contract__c).Location_Type__c;
                    cadd.Address_Line_1__c = mCAddIns.get(c.Parent_Contract__c).Address_Line_1__c;
                    cadd.Address_Line_2__c = mCAddIns.get(c.Parent_Contract__c).Address_Line_2__c;
                    cadd.City__c = mCAddIns.get(c.Parent_Contract__c).City__c;
                    cadd.State_Province__c = mCAddIns.get(c.Parent_Contract__c).State_Province__c;
                    cadd.Zip_Postal_Code__c = mCAddIns.get(c.Parent_Contract__c).Zip_Postal_Code__c;
                    cadd.Country__c = mCAddIns.get(c.Parent_Contract__c).Country__c;
                    cadd.Account_Address__c = mCAddIns.get(c.Parent_Contract__c).Account_Address__c;
                    cadd.Attention__c = mCAddIns.get(c.Parent_Contract__c).Attention__c;
                    cadd.Phone_Number__c = mCAddIns.get(c.Parent_Contract__c).Phone_Number__c;
                    cadd.Fax_Number__c = mCAddIns.get(c.Parent_Contract__c).Fax_Number__c;
                    cadd.Email_Address__c = mCAddIns.get(c.Parent_Contract__c).Email_Address__c;
                    lCAddToIns.add(cadd);
                // }
            }
            if(lCAddToIns!=null&&!lCAddToIns.isEmpty()){
                system.debug('***lCAddToIns - '+lCAddToIns);
                insert lCAddToIns;
            }
        }
    }
    public static void updateCloneCAddress(List<Contract_Address__c> lCAdd, Map<Id,Contract_Address__c> mOldCAdd){
        set<Id> sConIds = new set<Id>();
        set<Id> sAccAddIds = new set<Id>();
        
        for(Contract_Address__c c : lCAdd){
            sConIds.add(c.Contract__c);
            //sAccAddIds.add(c.Account_Address__c);
        }
        for(Contract_Address__c c : mOldCAdd.values()){
            sAccAddIds.add(c.Account_Address__c);
        }
        
        Map<Id,Contract_Address__c> mCapIns = new Map<Id,Contract_Address__c>();
        for(Contract_Address__c ca : lCAdd){
            mCapIns.put(ca.Contract__c,ca);
        }
        System.debug('***mCapInsert - '+mCapIns);
        
        system.debug('***1sConIds - '+sConIds);
        system.debug('***2sAccAddIds - '+sAccAddIds);
        List<Contract_Address__c> lCaddChild = [SELECT Id,Contract__r.Parent_Contract__c,Location_Type__c,Address_Line_1__c,Address_Line_2__c,City__c,State_Province__c,Zip_Postal_Code__c,Country__c,Account_Address__c,Attention__c,Phone_Number__c,Fax_Number__c,Email_Address__c FROM Contract_Address__c WHERE Contract__r.Parent_Contract__c IN:sConIds AND Account_Address__c IN:sAccAddIds ];
        
        system.debug('***3lCaddChild - '+lCaddChild);
        
        Map<Id,Contract_Address__c> mCAdd = new Map<Id,Contract_Address__c>();
        for(Contract_Address__c c : lCaddChild){
            mCAdd.put(c.Contract__c,c);
        }
        system.debug('***4mCAdd - '+mCAdd);
        
        List<Contract_Address__c> lCAddToUpd = new List<Contract_Address__c>();
        for(Contract_Address__c c : mCAdd.values()){
            if(mCAdd.containskey(c.Contract__c)){
                Contract_Address__c cadd = new Contract_Address__c();
                cadd.Id = c.Id;
                cadd.Account_Address__c = mCapIns.get(c.Contract__r.Parent_Contract__c).Account_Address__c;
                cadd.Location_Type__c = mCapIns.get(c.Contract__r.Parent_Contract__c).Location_Type__c;
                cadd.Address_Line_1__c = mCapIns.get(c.Contract__r.Parent_Contract__c).Address_Line_1__c;
                cadd.Address_Line_2__c = mCapIns.get(c.Contract__r.Parent_Contract__c).Address_Line_2__c;
                cadd.City__c = mCapIns.get(c.Contract__r.Parent_Contract__c).City__c;
                cadd.State_Province__c = mCapIns.get(c.Contract__r.Parent_Contract__c).State_Province__c;
                cadd.Zip_Postal_Code__c = mCapIns.get(c.Contract__r.Parent_Contract__c).Zip_Postal_Code__c;
                cadd.Country__c = mCapIns.get(c.Contract__r.Parent_Contract__c).Country__c;
                cadd.Account_Address__c = mCapIns.get(c.Contract__r.Parent_Contract__c).Account_Address__c;
                cadd.Attention__c = mCapIns.get(c.Contract__r.Parent_Contract__c).Attention__c;
                cadd.Phone_Number__c = mCapIns.get(c.Contract__r.Parent_Contract__c).Phone_Number__c;
                cadd.Fax_Number__c = mCapIns.get(c.Contract__r.Parent_Contract__c).Fax_Number__c;
                cadd.Email_Address__c = mCapIns.get(c.Contract__r.Parent_Contract__c).Email_Address__c;
                lCAddToUpd.add(cadd);
            }
        }
        if((lCAddToUpd!=null)&&(!lCAddToUpd.isEmpty())){
            update lCAddToUpd;
        }
    }
}