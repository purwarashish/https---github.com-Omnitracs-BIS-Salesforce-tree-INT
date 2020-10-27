trigger ShippingEstimateTrigger on Shipping_Estimate__c (after update, after insert, after delete) {
    if (Trigger.isAfter) {
        if (Trigger.isInsert) {
        }
    }

    /* ARMAN:
    System.debug('ShippingEstimateTrigger');
    if(ShippingEstimateRecursiveTriggerHandler.isFirstTime) {
        ShippingEstimateRecursiveTriggerHandler.isFirstTime = false;
        if (Trigger.isAfter) {
            if (Trigger.isInsert) {
                System.debug('ShippingEstimateTrigger.AfterInsert');
                List<Id> seIdList = new List<Id>();
                for (Shipping_Estimate__c se : Trigger.new) {
                    System.debug('current se: ' + se);
                    if (se.Shipping_Summary__c != null) {
                        seIdList.add(se.Id);
                    }
                }
                if (seIdList.size() > 0) {
                    QuoteLineGroupHandler.calculateMaxShippingDate(seIdList);
                    List<Shipping_Estimate__c> seList = new List<Shipping_Estimate__c>();
                    seList = [
                            select Shipping_Summary__r.Quote_Line_Group__r.SBQQ__Quote__r.SBQQ__Opportunity2__r.Id
                            from Shipping_Estimate__c
                            where Id in :seIdList
                    ];
                    List<Id> seOppIdList = new List<Id>();
                    for (Shipping_Estimate__c se : seList) {
                        seOppIdList.add(se.Shipping_Summary__r.Quote_Line_Group__r.SBQQ__Quote__r.SBQQ__Opportunity2__r.Id);
                    }
                    if (seOppIdList.size() > 0) {
                        OpportunityFinancialsHandler.calculateOpportunityFinancials(seOppIdList);
                    }
                }
            }
            if (Trigger.isUpdate) {
                System.debug('ShippingEstimateTrigger.AfterUpdate');
                List<Id> dateChangeList = new List<Id>();
                List<Id> seIdList = new List<Id>();
                for (Shipping_Estimate__c se : Trigger.new) {
                    System.debug('current se: ' + se);
                    if (Trigger.oldMap.get(se.Id).Estimated_Shipping_Date__c != Trigger.newMap.get(se.Id).Estimated_Shipping_Date__c) {
                        dateChangeList.add(se.Id);
                        seIdList.add(se.Id);
                    } else if (Trigger.oldMap.get(se.Id).Estimated_Shipping_Quantity__c != Trigger.newMap.get(se.Id).Estimated_Shipping_Quantity__c) {
                        seIdList.add(se.Id);
                    }
                }
                if (dateChangeList.size() > 0) {
                    QuoteLineGroupHandler.calculateMaxShippingDate(dateChangeList);
                }
                if (seIdList.size() > 0) {
                    List<Shipping_Estimate__c> seList = new List<Shipping_Estimate__c>();
                    seList = [
                            select Shipping_Summary__r.Quote_Line_Group__r.SBQQ__Quote__r.SBQQ__Opportunity2__r.Id
                            from Shipping_Estimate__c
                            where Id in :seIdList
                    ];
                    List<Id> seOppIdList = new List<Id>();
                    for (Shipping_Estimate__c se : seList) {
                        seOppIdList.add(se.Shipping_Summary__r.Quote_Line_Group__r.SBQQ__Quote__r.SBQQ__Opportunity2__r.Id);
                    }
                    if (seOppIdList.size() > 0) {
                        OpportunityFinancialsHandler.calculateOpportunityFinancials(seOppIdList);
                    }
                }
            }
            if (Trigger.isDelete) {
                System.debug('ShippingEstimateTrigger.AfterDelete');
                List<Id> seIdList = new List<Id>();
                for (Shipping_Estimate__c se : Trigger.old) {
                    System.debug('current se: ' + se);
                    if (se.Shipping_Summary__c != null) {
                        seIdList.add(se.Id);
                    }
                }
                if (seIdList.size() > 0) {
                    QuoteLineGroupHandler.calculateMaxShippingDate(seIdList);
                }
            }
        }
    } */
}