trigger QuoteLineTrigger on SBQQ__QuoteLine__c (after insert, after update) {
    System.debug('QuoteLineTrigger');
    if (QuoteLineRecursiveTriggerHandler.isFirstTime == true) {
        QuoteLineRecursiveTriggerHandler.isFirstTime = false;
        if (Trigger.isAfter) {
            if (Trigger.isInsert || Trigger.isUpdate) {
                List<Id> qlgList = new List<Id>();
                List<Id> qIdList = new List<Id>();
                for (SBQQ__QuoteLine__c ql : Trigger.new) {
                    if (ql.SBQQ__Group__c != null) {
                        qlgList.add(ql.SBQQ__Group__c);
                    }
                    qIdList.add(ql.SBQQ__Quote__c);
                }
                if (qlgList.size() > 0) {
                    QuoteLineGroupHandler.rollupQLGQuantities(qlgList);
                }
                /*if (qIdList.size() > 0) {
                    QuoteLineHandler.countShippingRequiredProducts(qIdList);
                }*/
            }
        }
    }
}