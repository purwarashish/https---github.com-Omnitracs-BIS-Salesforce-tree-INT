global class RollupParentUtils{
    public static boolean rollupParentExecuted = false;
    
    public static void updateRollupParentForUpsert(List<Account> acctList, Map<ID, Account> oldAcctMap, boolean isInsert, boolean isUpdate){
        if(!RollupParentUtils.rollupParentExecuted){
            RollupParentUtils.rollupParentExecuted = true;
            System.debug('RollupParentUtils updateRollupParentForUpsert called');
            Set<ID> parentIdSet = new Set<ID>();
            for(Account acct: acctList){
                if((isInsert && acct.ParentId != null) || (isUpdate && oldAcctMap.get(acct.Id).ParentId != acct.ParentId)){
                    if(acct.ParentId != null)
                        parentIdSet.add(acct.ParentId);
                    if(isUpdate && oldAcctMap.get(acct.Id).ParentId != null)
                        parentIdSet.add(oldAcctMap.get(acct.Id).ParentId);
                }
            }
            Map<ID, Account> parentAcctMap = new Map<ID, Account>([SELECT Id, ParentId, Rollup_Parent__c from Account where Id IN :parentIdSet]);
            if(isInsert){
                for(Account acct: acctList){
                    if(acct.ParentId != null){
                        Account parentAcct = parentAcctMap.get(acct.ParentId);
                        acct.Rollup_Parent__c = parentAcct.Rollup_Parent__c != null ? parentAcct.Rollup_Parent__c : parentAcct.Id;
                    }
                }
            }
            if(isUpdate && parentIdSet.size() > 0){
                Set<ID> rollupParentIdSet = new Set<ID>();
                for(Account acct: acctList){
                    rollupParentIdSet.add(acct.Rollup_Parent__c != null ? acct.Rollup_Parent__c : acct.Id); 
                }
                System.debug('rollupParentIdSet: ' + rollupParentIdSet);
                Map<ID, Account> rollupParentAcctMap = new Map<ID, Account>([SELECT Id, Name, ParentId, Rollup_Parent__c from Account where Rollup_Parent__c IN :rollupParentIdSet]);
                List<Account> childAcctsToUpdate = new List<Account>();
                for(Account acct: acctList){
                    System.debug('UpdateRollupParent for main Account: ' + acct.Name);
                    List<Account> acctsToUpdate = new List<Account>();
                    Account newParentAcct = parentAcctMap.get(acct.ParentId);
                    ID newRPAcctId = (newParentAcct == null ? null : (newParentAcct.Rollup_Parent__c != null ? newParentAcct.Rollup_Parent__c : newParentAcct.Id));
                    acct.Rollup_Parent__c = newRPAcctId;
                    if(newRPAcctId == null)
                        newRPAcctId = acct.Id;
                    //acctsToUpdate.add(acct);
                    Set<ID> parentSet = new Set<ID>();
                    Set<ID> updateSet = new Set<ID>();
                    parentSet.add(acct.Id);
                    for(Integer num = 0; num < rollupParentAcctMap.keySet().size(); num++){
                        for(ID key : rollupParentAcctMap.keySet()){
                            Account acc = rollupParentAcctMap.get(key);
                            if(parentSet.contains(acc.ParentId) && !updateSet.contains(key)){
                                System.debug('UpdateRollupParent for child Account: ' + acc.Name);
                                acc.Rollup_Parent__c = newRPAcctId;
                                acctsToUpdate.add(acc);
                                updateSet.add(key);
                                parentSet.add(acc.Id);
                                break;
                            }
                        }
                    }
                    childAcctsToUpdate.addAll(acctsToUpdate);
                }
                if(childAcctsToUpdate.size() > 0){
                    System.debug('Accts to be updated size: ' + childAcctsToUpdate.size());
                    update childAcctsToUpdate;
                }
            }
        }
    }
    
    public static void updateRollupParentForDelete(List<Account> acctList){
        if(!RollupParentUtils.rollupParentExecuted){
            RollupParentUtils.rollupParentExecuted = true;
            System.debug('RollupParentUtils updateRollupParentForDelete called');
            Set<ID> rollupParentIdSet = new Set<ID>();
            for(Account acct: acctList){
                rollupParentIdSet.add(acct.Rollup_Parent__c != null ? acct.Rollup_Parent__c : acct.Id); 
            }
            Map<ID, Account> rollupParentAcctMap = new Map<ID, Account>([SELECT Id, Name, ParentId, Rollup_Parent__c from Account where Rollup_Parent__c IN :rollupParentIdSet]);
            List<Account> childAcctsToUpdate = new List<Account>();
            for(Account acct: acctList){
                List<Account> acctsToUpdate = new List<Account>();
                Id deletedAcctId = acct.Id;
                Set<ID> updateSet = new Set<ID>();
                Map<ID, ID> parentRollupMap = new Map<ID, ID>();
                for(Integer num = 0; num < rollupParentAcctMap.keySet().size(); num++){
                    for(ID key : rollupParentAcctMap.keySet()){
                        Account acc = rollupParentAcctMap.get(key);
                        if(acc.ParentId == deletedAcctId && !updateSet.contains(key)){
                            acc.Rollup_Parent__c = null;
                            parentRollupMap.put(acc.Id, acc.Id);
                            System.debug('UpdateRollupParent for child Account: ' + acc.Name + ' (with -> ' + acc.Rollup_Parent__c + ')');
                            acctsToUpdate.add(acc);
                            updateSet.add(key);
                            break;
                        }else if(parentRollupMap.containsKey(acc.ParentId) && !updateSet.contains(key)){
                            acc.Rollup_Parent__c = parentRollupMap.get(acc.ParentId);
                            parentRollupMap.put(acc.Id, parentRollupMap.get(acc.ParentId));
                            System.debug('UpdateRollupParent for child Account: ' + acc.Name + ' (with -> ' + acc.Rollup_Parent__c + ')');
                            acctsToUpdate.add(acc);
                            updateSet.add(key);
                            break;
                        }
                    }
                }
                childAcctsToUpdate.addAll(acctsToUpdate);
            }
            if(childAcctsToUpdate.size() > 0){
                System.debug('Accts to be updated size: ' + childAcctsToUpdate.size());
                update childAcctsToUpdate;
            }
        }
    }
    
    public static void updateRollupParentForUndelete(List<Account> acctList){
        if(!RollupParentUtils.rollupParentExecuted){
            RollupParentUtils.rollupParentExecuted = true;
            System.debug('RollupParentUtils updateRollupParentForUndelete called');
            List<Account> childAcctsToUpdate = new List<Account>();
            for(Account acct: acctList){
                ID newRPAcctId = (acct.Rollup_Parent__c != null ? acct.Rollup_Parent__c : acct.Id);
                List<Account> childAccts = [SELECT Id, Name, ParentId, Rollup_Parent__c from Account where ParentId = :acct.Id];
                Set<ID> subParentIdSet = new Set<ID>();
                for(Account acc : childAccts){
                    acc.Rollup_Parent__c = newRPAcctId;
                    childAcctsToUpdate.add(acc);
                    System.debug('UpdateRollupParent for child Account: ' + acc.Name);
                    subParentIdSet.add(acc.Id);
                }
                boolean hasChildAcct = true;
                while(hasChildAcct){
                    hasChildAcct = false;
                    List<Account> subChildAccts = [SELECT Id, Name, ParentId, Rollup_Parent__c from Account where ParentId IN :subParentIdSet];
                    subParentIdSet = new Set<ID>();
                    for(Account accnt : subChildAccts){
                        subParentIdSet.add(accnt.Id);
                        accnt.Rollup_Parent__c = newRPAcctId;
                        System.debug('UpdateRollupParent for child Account: ' + accnt.Name);
                        childAcctsToUpdate.add(accnt);
                    }
                    if(subParentIdSet.size() > 0)
                        hasChildAcct = true;
                }
            }
            if(childAcctsToUpdate.size() > 0){
                System.debug('Accts to be updated size: ' + childAcctsToUpdate.size());
                update childAcctsToUpdate;
            }
        }
    }
}