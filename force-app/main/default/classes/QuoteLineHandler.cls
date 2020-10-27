/**
 * Handler for the functionality required in the QuoteLineTrigger.
 */

public with sharing class QuoteLineHandler {

    /**
     * Count the number of Shipping Required Products in a quote.
     *
     * @param quoteIdList - list of quote ids to iterate over an update.
     */
    public static void countShippingRequiredProducts(List<Id> quoteIdList) {
        System.debug('QuoteLineGroupHandler.CountShipReqProducts');
        List<SBQQ__QuoteLine__c> quoteLineList = new List<SBQQ__QuoteLine__c>();
        List<SBQQ__Quote__c> quoteList = new List<SBQQ__Quote__c>();
        List<SBQQ__Quote__c> quoteUpdateList = new List<SBQQ__Quote__c>();
        Map<Id, Integer> numberReqByQuoteMap = new Map<Id, Integer>();
        quoteLineList = [
                SELECT Id, Name, SBQQ__Quote__c, SBQQ__Product__r.Shipment_Schedule_Required__c, SBQQ__EffectiveQuantity__c
                FROM SBQQ__QuoteLine__c
                WHERE SBQQ__Quote__c in :quoteIdList
        ];

        for (SBQQ__QuoteLine__c quoteLine : quoteLineList) {
            if (quoteLine.SBQQ__Product__r.Shipment_Schedule_Required__c == true && quoteLine.SBQQ__EffectiveQuantity__c != null && quoteLine.SBQQ__EffectiveQuantity__c != 0) {
                Integer qProdCount = 0;
                if (numberReqByQuoteMap.containsKey(quoteLine.SBQQ__Quote__c)) {
                    qProdCount = numberReqByQuoteMap.get(quoteLine.SBQQ__Quote__c);
                }
                qProdCount = qProdCount + Integer.valueOf(quoteLine.SBQQ__EffectiveQuantity__c);
                numberReqByQuoteMap.put(quoteLine.SBQQ__Quote__c, qProdCount);
            }
        }
        quoteList = [SELECT Id, Shipping_Estimate_Required__c, SBQQ__Type__c FROM SBQQ__Quote__c WHERE Id IN :quoteIdList];

        for (SBQQ__Quote__c quote: quoteList) {
            Integer estReqCount = 0;
            if (numberReqByQuoteMap.containsKey(quote.Id)) {
                estReqCount = numberReqByQuoteMap.get(quote.Id);
            }

            // if the quote is not a renewal and the quantity is less than -50 or greater than 50, require the shipping estimate
            if (quote.SBQQ__Type__c != 'Renewal' && (-50 >= estReqCount || estReqCount >= 50)) {
                quote.Shipping_Estimate_Required__c = true;
            } else {
                quote.Shipping_Estimate_Required__c = false;
            }
            quoteUpdateList.add(quote);
        }
        if (quoteUpdateList.size() > 0) {
            update quoteUpdateList;
        }
    }

    public static void updateAccountData(Map<String, List<SBQQ__QuoteLineGroup__c>> qlgChangeMap, Map<Id,Id> qlgAffiliateMap) {
        System.debug('QuoteLineHandler.updateAccountData');

        Map<Id, Id> qlgData = new Map<Id, Id>();
        List<SBQQ__QuoteLineGroup__c> qlgList = new List<SBQQ__QuoteLineGroup__c>();
        for (String changeType : qlgChangeMap.keySet()) {
            qlgList = qlgChangeMap.get(changeType);
            for (SBQQ__QuoteLineGroup__c qlg : qlgChangeMap.get(changeType)) {
                if (changeType == 'Account') {
                    qlgData.put(qlg.Id, qlg.SBQQ__Account__c);
                } else if (changeType == 'Affiliate') {
                    if (qlgAffiliateMap.containsKey(qlg.Id)) {
                        qlgData.put(qlg.Id, qlgAffiliateMap.get(qlg.Id));
                        System.debug('qlgAffiliateMap.get(qlg.Id):');
                        System.debug(qlgAffiliateMap.get(qlg.Id));
                        System.debug('Succesffully assigned an affiliate to a QLG');
                    }
                    else {
                        qlgData.put(qlg.Id, null);
                        System.debug('UNSUCCESSFUL assignment of an affiliate to a QLG!');
                    }
                } else {
                    qlgData.put(qlg.Id, null);
                }
            }
        }
        List<SBQQ__QuoteLine__c> qlList = new List<SBQQ__QuoteLine__c>();
        qlList = [select Id, SBQQ__Group__c, AffiliateAccount__c from SBQQ__QuoteLine__c where SBQQ__Group__c in :qlgList];
        for (SBQQ__QuoteLine__c ql : qlList) {
            ql.AffiliateAccount__c = qlgData.get(ql.SBQQ__Group__c);
            ql.AffiliateAccount__c = qlgData.get(ql.SBQQ__Group__c);
            System.debug('qlgData.get(ql.SBQQ__Group__c):');
            System.debug(qlgData.get(ql.SBQQ__Group__c));
            System.debug('ql.Id:');
            System.debug(ql.Id);
        }

        if (qlList.size() > 0) {
            update qlList;
        }
    }
}