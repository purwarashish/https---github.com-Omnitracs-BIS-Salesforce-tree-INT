/**
 * Created by CrutchfieldJody on 1/22/2017.
 */

trigger QuoteLineGroupTrigger on SBQQ__QuoteLineGroup__c (after insert, after update) {
    System.debug('QuoteLineGroupTrigger');

    /*if(Trigger.isBefore) {
        QuoteLineGroupHandler.quoteLineGroupSummaryUpdate(Trigger.new);
    }*/

    if (Trigger.isAfter) {
        if (Trigger.isInsert) {
            System.debug('QuoteLineGroupTrigger.AfterInsert');
            if (QuoteLineGroupRecursiveTriggerHandler.isFirstTime == true) {
                QuoteLineGroupRecursiveTriggerHandler.isFirstTime = false;

                List<Id> qlgRollupList = new List<Id>();
                List<SBQQ__QuoteLineGroup__c> qlgDefEstList = new List<SBQQ__QuoteLineGroup__c>();

                for (SBQQ__QuoteLineGroup__c qlgr : Trigger.new) {
                    qlgRollupList.add(qlgr.Id);
                    qlgDefEstList.add(qlgr);
                }

                if (qlgRollupList.size() > 0) {
                    QuoteLineGroupHandler.rollupQLGQuantities(qlgRollupList);
                }
                /* ARMAN: if (qlgDefEstList.size() > 0) {
                    QuoteLineGroupHandler.buildDefaultEstimates(qlgDefEstList);
                } */
            }
        }
    }

    if (Trigger.isAfter) {
        if (Trigger.isUpdate) {
            System.debug('QuoteLineGroupTrigger.AfterUpdate');
            if (QuoteLineGroupRecursiveTriggerHandler.isFirstTime == true) {
                QuoteLineGroupRecursiveTriggerHandler.isFirstTime = false;

                Set<Id> qlgRelatedAccountsIds = new Set<Id>();
                Map<String, List<SBQQ__QuoteLineGroup__c>> qlgChangeMap = new Map<String, List<SBQQ__QuoteLineGroup__c>>();
                List<SBQQ__QuoteLineGroup__c> qlgList = new List<SBQQ__QuoteLineGroup__c>();
                String changeType = '';

                List<SBQQ__QuoteLine__c> qlList = new List<SBQQ__QuoteLine__c>();
                qlList = [select Id, SBQQ__Group__c, AffiliateAccount__c from SBQQ__QuoteLine__c where SBQQ__Group__c in :Trigger.new];

                for (SBQQ__QuoteLineGroup__c qlg : Trigger.new) {
                    for (SBQQ__QuoteLine__c ql : qlList) {
                        if (ql.SBQQ__Group__c != qlg.Id) { continue; }

                        if (qlg.Affiliate_Account2__c != null) {
                            changeType = 'newAff';
                            break;
                        } else if (qlg.SBQQ__Account__c != null) {
                            changeType = 'newAcct';
                            break;
                        }
                    }

                    if (changeType == 'newAcct') {
                        qlgList = new List<SBQQ__QuoteLineGroup__c>();
                        if (qlgChangeMap.containsKey('Account')) {
                            qlgList = qlgChangeMap.get('Account');
                        }
                        qlgRelatedAccountsIds.add(qlg.SBQQ__Account__c);
                        qlgList.add(qlg);
                        qlgChangeMap.put('Account', qlgList);
                    } else if (changeType == 'newAff') {
                        qlgList = new List<SBQQ__QuoteLineGroup__c>();
                        if (qlgChangeMap.containsKey('Affiliate')) {
                            qlgList = qlgChangeMap.get('Affiliate');
                        }
                        qlgRelatedAccountsIds.add(qlg.Affiliate_Account2__c);
                        qlgList.add(qlg);
                        qlgChangeMap.put('Affiliate', qlgList);
                    } else {
                        qlgList = new List<SBQQ__QuoteLineGroup__c>();
                        if (qlgChangeMap.containsKey('Clear')) {
                            qlgList = qlgChangeMap.get('Clear');
                        }
                        qlgList.add(qlg);
                        qlgChangeMap.put('Clear', qlgList);
                    }
                }

                //+ Map QLG to Affiliates.
                Map<Id,Id> qlgAffiliateMap = new Map<Id,Id>();
                if (qlgRelatedAccountsIds.size() > 0) {
                    List<Related_Accounts__c> relatedAccountsList = [
                            SELECT
                                    Id,
                                    Child_Account__c
                            FROM Related_Accounts__c
                            WHERE Id IN :qlgRelatedAccountsIds
                    ];


                    for (SBQQ__QuoteLineGroup__c qlg : Trigger.new) {
                        for (Related_Accounts__c relatedAccount : relatedAccountsList) {
                            if (qlg.Affiliate_Account2__c == relatedAccount.Id) {
                                qlgAffiliateMap.put(qlg.Id, relatedAccount.Child_Account__c);
                                break;
                            }
                        }
                    }
                }
                //- Map QLG to Affiliates.

                if (qlgChangeMap.size() > 0) {
                    QuoteLineHandler.updateAccountData(qlgChangeMap, qlgAffiliateMap);
                }

                List<Id> qlgRollupList = new List<Id>();
                List<SBQQ__QuoteLineGroup__c> qlgDefEstList = new List<SBQQ__QuoteLineGroup__c>();
                List<Id> addSummaryList = new List<Id>();
                List<Id> delSummaryList = new List<Id>();
                for (SBQQ__QuoteLineGroup__c qlg : Trigger.new) {
                    /* ARMAN: if (Trigger.oldMap.get(qlg.Id).Shipping_Estimate_Summary__c != Trigger.newMap.get(qlg.Id).Shipping_Estimate_Summary__c) {
                        if (Trigger.newMap.get(qlg.Id).Shipping_Estimate_Summary__c == null) {
                            delSummaryList.add(qlg.Id);
                        } else {
                            addSummaryList.add(qlg.Id);
                        }
                    } */
                    qlgRollupList.add(qlg.Id);
                    qlgDefEstList.add(qlg);
                }

                /* ARMAN: if (addSummaryList.size() > 0 || delSummaryList.size() > 0) {
                    QuoteLineGroupHandler.setSummaryExists(addSummaryList, delSummaryList);
                } */

                if (qlgRollupList.size() > 0) {
                    QuoteLineGroupHandler.rollupQLGQuantities(qlgRollupList);
                }

                /* ARMAN: if (qlgDefEstList.size() > 0) {
                    QuoteLineGroupHandler.buildDefaultEstimates(qlgDefEstList);
                } */
            }
        }
    }
}