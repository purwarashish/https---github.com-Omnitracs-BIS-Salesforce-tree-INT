/* Change history
* 
* QuoteLineGroupHandler
* Created - August 2016 - Jody Crutchfield (ATG)
* 
* Date - Who - What
* 8/30/2016 Jody Crutchfield - add logic to roll up max date from shipping estimates.
* 11/2/2016 Jody Crutchfield - changed from hardware and software types to the 4 cpq types
* 
*/
public with sharing class QuoteLineGroupHandler {

    /**
     * Called to set fields on the QuoteLineGroup after adjusting the shipping estimate summaries.
     *
     * Set the Shipping Estimate Summary Exists field on the Quote Line Group.
     * Set the Shipping Estimate Summary Is Default field on the Quote Line Group.
     *
     * @param List<Id> addList - list of quote line ids that are to be added.
     * @param List<Id> delList - list of quote line ids that were deleted.
     */
    /* ARMAN: public static void setSummaryExists(List<Id> addList, List<Id> delList){
        System.debug('QuoteLineGroupHandler.setSummaryExists');

        List<SBQQ__QuoteLineGroup__c> qlgUpdateList = new List<SBQQ__QuoteLineGroup__c>();
        for(Id addId : addList){
            SBQQ__QuoteLineGroup__c aGroup = new SBQQ__QuoteLineGroup__c();
            aGroup.Id = addId;
            aGroup.Shipping_Estimate_Summary_Exists__c = true;

            qlgUpdateList.add(aGroup);
        }
        for(Id delId : delList){
            SBQQ__QuoteLineGroup__c dGroup = new SBQQ__QuoteLineGroup__c();
            dGroup.Id = delId;
            dGroup.Shipping_Estimate_Summary_Exists__c = false;
            qlgUpdateList.add(dGroup);
        }
        if(qlgUpdateList.size() > 0){
            update qlgUpdateList;
        }
    }*/

    public static void rollupQLGQuantities(List<Id> qlgList) {
        System.debug('QuoteLineGroupHandler.rollupQLGQuantities');
        Map<Id, Id> uniqueList = new Map<Id, Id>();
        for (Id g : qlgList) {
            uniqueList.put(g, g);
        }
        List<SBQQ__QuoteLine__c> qlList = new List<SBQQ__QuoteLine__c>();
        qlList = [
                select Id, Name, SBQQ__Group__c, SBQQ__Quantity__c, SBQQ__EffectiveQuantity__c
                        , SBQQ__Product__r.SBQQ__SubscriptionPricing__c
                        , SBQQ__Product__r.SBQQ__SubscriptionType__c
                        , SBQQ__Product__r.Shipment_Schedule_Required__c
                        , SBQQ__Product__r.Product_Type__c
                        , SBQQ__Product__r.Product_Sub_Type__c
                        , Quote_Line_Type__c
                from SBQQ__QuoteLine__c
                where SBQQ__Group__c in :uniqueList.keySet()
        ];
        Map<Id, Decimal> hardwareQtyMap = new Map<Id, Decimal>();
        Map<Id, Decimal> svcPlanQtyMap = new Map<Id, Decimal>();
        Map<Id, Decimal> applQtyMap = new Map<Id, Decimal>();
        Map<Id, Decimal> softwareQtyMap = new Map<Id, Decimal>();
        for (SBQQ__QuoteLine__c ql : qlList) {
            Decimal newQty = 0.0;
            Decimal qlQty = 0.0;
            if (ql.Quote_Line_Type__c == 'New' || ql.Quote_Line_Type__c == 'Renewal') {
                qlQty = ql.SBQQ__Quantity__c;
            } else {
                qlQty = ql.SBQQ__EffectiveQuantity__c;
            }
            System.debug('quote line quantity: ' + qlQty);
            if (ql.SBQQ__Product__r.Shipment_Schedule_Required__c == true) {
                System.debug('In Hardware');
                if (hardwareQtyMap.containsKey(ql.SBQQ__Group__c)) {
                    newQty = hardwareQtyMap.get(ql.SBQQ__Group__c) + qlQty;
                    hardwareQtyMap.put(ql.SBQQ__Group__c, newQty);
                } else {
                    newQty = qlQty;
                    hardwareQtyMap.put(ql.SBQQ__Group__c, newQty);
                }
            } else if (ql.SBQQ__Product__r.Product_Type__c == 'Software' && ql.SBQQ__Product__r.Product_Sub_Type__c == 'Service Plans') {
                System.debug('In Service Plan');
                if (svcPlanQtyMap.containsKey(ql.SBQQ__Group__c)) {
                    newQty = svcPlanQtyMap.get(ql.SBQQ__Group__c) + qlQty;
                    svcPlanQtyMap.put(ql.SBQQ__Group__c, newQty);
                } else {
                    newQty = qlQty;
                    svcPlanQtyMap.put(ql.SBQQ__Group__c, newQty);
                }
            } else if (ql.SBQQ__Product__r.Product_Type__c == 'Software' && ql.SBQQ__Product__r.Product_Sub_Type__c == 'Applications') {
                System.debug('In Applications');
                if (applQtyMap.containsKey(ql.SBQQ__Group__c)) {
                    newQty = applQtyMap.get(ql.SBQQ__Group__c) + qlQty;
                    applQtyMap.put(ql.SBQQ__Group__c, newQty);
                } else {
                    newQty = qlQty;
                    applQtyMap.put(ql.SBQQ__Group__c, newQty);
                }
            } else if (ql.SBQQ__Product__r.Product_Type__c == 'Software' && (ql.SBQQ__Product__r.Product_Sub_Type__c != 'Service Plans' && ql.SBQQ__Product__r.Product_Sub_Type__c != 'Applications')) {
                System.debug('In Software');
                if (softwareQtyMap.containsKey(ql.SBQQ__Group__c)) {
                    newQty = softwareQtyMap.get(ql.SBQQ__Group__c) + qlQty;
                    softwareQtyMap.put(ql.SBQQ__Group__c, newQty);
                } else {
                    newQty = qlQty;
                    softwareQtyMap.put(ql.SBQQ__Group__c, newQty);
                }
            }
        }
        List<SBQQ__QuoteLineGroup__c> finalQlgList = new List<SBQQ__QuoteLineGroup__c>();
        Map<Id, SBQQ__QuoteLineGroup__c> qlgMap = new Map<Id, SBQQ__QuoteLineGroup__c>();
        for (Id g : hardwareQtyMap.keySet()) {
            SBQQ__QuoteLineGroup__c qlg = new SBQQ__QuoteLineGroup__c();
            if (qlgMap.containsKey(g)) {
                qlg = qlgMap.get(g);
            } else {
                qlg.Id = g;
            }
            qlg.Group_Hardware_Quantity_Rollup__c = hardwareQtyMap.get(g);
            qlgMap.put(g, qlg);
        }

        for (Id g : svcPlanQtyMap.keySet()) {
            SBQQ__QuoteLineGroup__c qlg = new SBQQ__QuoteLineGroup__c();
            if (qlgMap.containsKey(g)) {
                qlg = qlgMap.get(g);
            } else {
                qlg.Id = g;
            }
            qlg.Group_Service_Plan_Quantity_Rollup__c = svcPlanQtyMap.get(g);
            qlgMap.put(g, qlg);
        }

        for (Id g : softwareQtyMap.keySet()) {
            SBQQ__QuoteLineGroup__c qlg = new SBQQ__QuoteLineGroup__c();
            if (qlgMap.containsKey(g)) {
                qlg = qlgMap.get(g);
            } else {
                qlg.Id = g;
            }
            qlg.Group_Software_Quantity_Rollup__c = softwareQtyMap.get(g);
            qlgMap.put(g, qlg);
        }

        for (Id g : applQtyMap.keySet()) {
            SBQQ__QuoteLineGroup__c qlg = new SBQQ__QuoteLineGroup__c();
            if (qlgMap.containsKey(g)) {
                qlg = qlgMap.get(g);
            } else {
                qlg.Id = g;
            }
            qlg.Group_Application_Quantity_Rollup__c = applQtyMap.get(g);
            qlgMap.put(g, qlg);
        }

        finalQlgList.addAll(qlgMap.values());
        if (finalQlgList.size() > 0) {
            update finalQlgList;
        }
    }

    /* ARMAN: private static Map<Id, Map<String, Decimal>> rollupQLGQuantities(List<SBQQ__QuoteLineGroup__c> qlgList) {
        System.debug('QuoteLineGroupHandler.rollupQLGQuantities');
        System.debug('qlgList: ' + qlgList);
        Map<Id, Map<String, Decimal>> retMap = new Map<Id, Map<String, Decimal>>();
        Map<Id, Id> uniqueList = new Map<Id, Id>();
        Boolean isAffliatedQLG = false;
        for (SBQQ__QuoteLineGroup__c g : qlgList) {
            //System.debug('current q: ' + g);
            uniqueList.put(g.Id, g.Id);
            if(String.isNotBlank(g.Affiliate_Account2__c)){
            	isAffliatedQLG = true;
            }
        }
        System.debug('uniqueList: ' + uniqueList);
        List<SBQQ__QuoteLine__c> qlList = new List<SBQQ__QuoteLine__c>();
        qlList = [
                select Id, Name, SBQQ__Group__c, SBQQ__Quantity__c, SBQQ__EffectiveQuantity__c
                        , SBQQ__Product__r.SBQQ__SubscriptionPricing__c
                        , SBQQ__Product__r.SBQQ__SubscriptionType__c
                        , SBQQ__Product__r.Shipment_Schedule_Required__c
                        , SBQQ__Product__r.Product_Type__c
                        , SBQQ__Product__r.Product_Sub_Type__c
                        , Quote_Line_Type__c
                from SBQQ__QuoteLine__c
                where SBQQ__Group__c in :uniqueList.keySet()
        ];
        //System.debug('qlList: ' + qlList);
        Map<String, Decimal> qtyMap = new Map<String, Decimal>();
        for (SBQQ__QuoteLine__c ql : qlList) {
            //System.debug('current ql: ' + ql);
            if (retMap.containsKey(ql.SBQQ__Group__c)) {
                qtyMap = retMap.get(ql.SBQQ__Group__c);
            }
            else if(isAffliatedQLG){
            	 qtyMap = new Map<String, Decimal>();
            }
            Decimal newQty = 0.0;
            Decimal qlQty = 0.0;
            if (ql.Quote_Line_Type__c == 'New' || ql.Quote_Line_Type__c == 'Renewal') {
                qlQty = ql.SBQQ__Quantity__c;
            } else {
                qlQty = ql.SBQQ__EffectiveQuantity__c;
            }
            System.debug('quote line quantity: ' + qlQty);
            if (ql.SBQQ__Product__r.Shipment_Schedule_Required__c == true) {
                System.debug('In Hardware');
                if (qtyMap.containsKey('hw')) {
                    newQty = qtyMap.get('hw') + qlQty;
                    qtyMap.put('hw', newQty);
                } else {
                    newQty = qlQty;
                    qtyMap.put('hw', newQty);
                }
            } else if (ql.SBQQ__Product__r.Product_Type__c == 'Software' && ql.SBQQ__Product__r.Product_Sub_Type__c == 'Service Plans') {
                System.debug('In Service Plan');
                if (qtyMap.containsKey('sp')) {
                    newQty = qtyMap.get('sp') + qlQty;
                    qtyMap.put('sp', newQty);
                } else {
                    newQty = qlQty;
                    qtyMap.put('sp', newQty);
                }
            } else if (ql.SBQQ__Product__r.Product_Type__c == 'Software' && ql.SBQQ__Product__r.Product_Sub_Type__c == 'Applications') {
                System.debug('In Applications');
                if (qtyMap.containsKey('ap')) {
                    newQty = qtyMap.get('ap') + qlQty;
                    qtyMap.put('ap', newQty);
                } else {
                    newQty = qlQty;
                    qtyMap.put('ap', newQty);
                }
            } else if (ql.SBQQ__Product__r.Product_Type__c == 'Software' && (ql.SBQQ__Product__r.Product_Sub_Type__c != 'Service Plans' && ql.SBQQ__Product__r.Product_Sub_Type__c != 'Applications')) {
                System.debug('In Software');
                if (qtyMap.containsKey('sw')) {
                    newQty = qtyMap.get('sw') + qlQty;
                    qtyMap.put('sw', newQty);
                } else {
                    newQty = qlQty;
                    qtyMap.put('sw', newQty);
                }
            }
            retMap.put(ql.SBQQ__Group__c, qtyMap);
        }
        return retMap;
    } */

    /* ARMAN: public static void calculateMaxShippingDate(List<Id> seIdList) {
        System.debug('QuoteLineGroupHandler.calculateMaxShippingDate');
        Map<Id, Shipping_Estimate__c> groupMap = new Map<Id, Shipping_Estimate__c>();
        List<Shipping_Estimate__c> seList = new List<Shipping_Estimate__c>();
        List<SBQQ__QuoteLineGroup__c> updateList = new List<SBQQ__QuoteLineGroup__c>();
        seList = [
                select Shipping_Summary__r.Quote_Line_Group__r.Id, Estimated_Shipping_Date__c
                from Shipping_Estimate__c
                where Id in :seIdList
        ];
        for (Shipping_Estimate__c se : seList) {
            if(se.Shipping_Summary__r.Quote_Line_Group__r.Id != null){
	            Date prevDate = null;
	            Date newDate = null;
	            if (groupMap.containsKey(se.Shipping_Summary__r.Quote_Line_Group__r.Id)) {
	                prevDate = groupMap.get(se.Shipping_Summary__r.Quote_Line_Group__r.Id).Estimated_Shipping_Date__c;
	                newDate = se.Estimated_Shipping_Date__c;
	                if (newDate > prevDate) {
	                    groupMap.put(se.Shipping_Summary__r.Quote_Line_Group__r.Id, se);
	                }
	            } else {
	                groupMap.put(se.Shipping_Summary__r.Quote_Line_Group__r.Id, se);
	            }
            }
        }
        for (Id qlg : groupMap.keySet()) {
            SBQQ__QuoteLineGroup__c grp = new SBQQ__QuoteLineGroup__c();
            grp.Id = qlg;
            grp.Max_Shipping_Estimate_Date__c = groupMap.get(qlg).Estimated_Shipping_Date__c;
            updateList.add(grp);
        }
        if (updateList.size() > 0) {
            System.debug('Group Update List: ' + updateList);
            update updateList;
        }
    }*/

    /* ARMAN: public static void buildDefaultEstimates(List<SBQQ__QuoteLineGroup__c> groupUpdateList) {
        //public static void buildDefaultEstimates(List<SBQQ__Quote__c> quoteList) {
        System.debug('QuoteLineGroupHandler.buildDefaultEstimates ' + groupUpdateList.size());
        List<Id> oppIdList = new List<Id>();
        Set<Id> quoteIdSet = new Set<Id>();
        List<Id> summaryAddIdList = new List<Id>();
        List<Id> summaryUpdateIdList = new List<Id>();
        Map<Id, Id> summaryAddIdMap = new Map<Id, Id>();
        List<Shipping_Estimate__c> updateEstimateList = new List<Shipping_Estimate__c>();
        List<Shipping_Estimate_Summary__c> summaryAddList = new List<Shipping_Estimate_Summary__c>();
        List<Id> quoteLineGroupIdList = new List<Id>();
        Map<Id, Map<String, Decimal>> qlgQuantitiesMap = new Map<Id, Map<String, Decimal>>();
        List<Shipping_Estimate_Summary__c> shippingEstSummaryList = new List<Shipping_Estimate_Summary__c>();
        qlgQuantitiesMap = QuoteLineGroupHandler.rollupQLGQuantities(groupUpdateList);

        Map<Id, Shipping_Estimate_Summary__c> shippingEstimateSummaryMap = new Map<Id, Shipping_Estimate_Summary__c>();
        try {
            shippingEstSummaryList = [SELECT Id, Name, Quote_Line_Group__c, Quote_Line_Group__r.Group_Service_Plan_Quantity_Rollup__c
                    , Quote_Line_Group__r.Group_Hardware_Quantity_Rollup__c
                    , Quote_Line_Group__r.Group_Application_Quantity_Rollup__c
                    , Quote_Line_Group__r.Group_Software_Quantity_Rollup__c
                    , Quote_Line_Group__r.SBQQ__Quote__r.SBQQ__Opportunity2__r.CloseDate
                    , Default_Estimates_Exist__c, Default_Estimate_Count__c, Number_of_Ship_Est_Records__c
                    FROM Shipping_Estimate_Summary__c WHERE Quote_Line_Group__c IN :groupUpdateList];
        } catch (Exception e){
            System.debug('No matching summary lines were found.');
        }

        for(Shipping_Estimate_Summary__c summary: shippingEstSummaryList) {
            shippingEstimateSummaryMap.put(summary.Quote_Line_Group__c, summary);
        }

        // Iterate over the quote line groups looking for ones who do not have shipping summaries or who still have default
        // shipping summaries.
        System.debug('QuoteLineGroupHandler.buildDefaultEstimates group size: ' + groupUpdateList.size());
        for (SBQQ__QuoteLineGroup__c qlGroup : groupUpdateList) {
            System.debug('QuoteLineGroupHandler.buildDefaultEstimates() Summary? ' + qlGroup.Shipping_Estimate_Summary__c);
            if (qlgQuantitiesMap.containsKey(qlGroup.Id) && !shippingEstimateSummaryMap.containsKey(qlGroup.Id)) {
                System.debug('QuoteLineGroupHandler.buildDefaultEstimates() creating a new Shipping Estimate Summary for ' + qlGroup.Id);
                Shipping_Estimate_Summary__c shipSum = new Shipping_Estimate_Summary__c();
                shipSum.Quote_Line_Group__c = qlGroup.Id;
                //shipSum.Quote_Line_Group_Id__c = qlGroup.Id;
                summaryAddList.add(shipSum);
            } else if(shippingEstimateSummaryMap.containsKey(qlGroup.Id) && (shippingEstimateSummaryMap.get(qlGroup.Id).Default_Estimates_Exist__c == true || shippingEstimateSummaryMap.get(qlGroup.Id).Number_of_Ship_Est_Records__c <= 0)) {
                System.debug('QuoteLineGroupHandler.buildDefaultEstimates() updating the Shipping Estimate Summary for ' + qlGroup.Id);
                summaryUpdateIdList.add(shippingEstimateSummaryMap.get(qlGroup.Id).Id);
            }
            quoteIdSet.add(qlGroup.SBQQ__Quote__c);
        }

        List<SBQQ__Quote__c> quotes = [
                SELECT
                    SBQQ__Opportunity2__c
                FROM SBQQ__Quote__c
                WHERE Id IN :quoteIdSet
        ];
        for (SBQQ__Quote__c quote : quotes) {
            oppIdList.add(quote.SBQQ__Opportunity2__c);
        }

        if(summaryUpdateIdList.size() > 0) {
            List<Shipping_Estimate__c> estimateList = [SELECT Id, Name, Estimated_Shipping_Quantity__c, Estimated_Shipping_Date__c, Shipping_Summary__c, Default_Estimate__c FROM Shipping_Estimate__c WHERE Shipping_Summary__c IN :summaryUpdateIdList];

            Map<Id, Shipping_Estimate_Summary__c> summaryMap = new Map<Id, Shipping_Estimate_Summary__c>([
                    select Id, Name, Quote_Line_Group__c, Quote_Line_Group__r.Group_Service_Plan_Quantity_Rollup__c
                            , Quote_Line_Group__r.Group_Hardware_Quantity_Rollup__c
                            , Quote_Line_Group__r.Group_Application_Quantity_Rollup__c
                            , Quote_Line_Group__r.Group_Software_Quantity_Rollup__c
                            , Quote_Line_Group__r.SBQQ__Quote__r.SBQQ__Opportunity2__r.CloseDate
                            , Default_Estimates_Exist__c
                    from Shipping_Estimate_Summary__c
                    where Id in :summaryUpdateIdList
            ]);

            for(Shipping_Estimate__c estimate: estimateList) {
                if(estimate.Default_Estimate__c == true) {
                    updateEstimateList.add(QuoteLineGroupHandler.updateShippingEstimate(estimate, qlgQuantitiesMap, summaryMap.get(estimate.Shipping_Summary__c)));
                }
            }

            if(updateEstimateList.size() > 0) {
                update updateEstimateList;
            }
        }

        System.debug('QuoteLineGroupHandler.buildDefaultEstimates() summary add list size: ' + summaryAddList.size());
        if (summaryAddList.size() > 0) {
            insert summaryAddList;
            Map<Id, Shipping_Estimate_Summary__c> summaryMap = new Map<Id, Shipping_Estimate_Summary__c>([
                    select Id, Name, Quote_Line_Group__c, Quote_Line_Group__r.Group_Service_Plan_Quantity_Rollup__c
                            , Quote_Line_Group__r.Group_Hardware_Quantity_Rollup__c
                            , Quote_Line_Group__r.Group_Application_Quantity_Rollup__c
                            , Quote_Line_Group__r.Group_Software_Quantity_Rollup__c
                            , Quote_Line_Group__r.SBQQ__Quote__r.SBQQ__Opportunity2__r.CloseDate
                    from Shipping_Estimate_Summary__c
                    where Id in :summaryAddList
            ]);
            List<Shipping_Estimate__c> insertEstimateList = new List<Shipping_Estimate__c>();
            System.debug('QuoteLineGroupHandler.buildDefaultEstimates() size summaryMap: ' + summaryMap.size());
            for (Shipping_Estimate_Summary__c sum : summaryMap.values()) {
                Shipping_Estimate__c newEstimate = new Shipping_Estimate__c();
                newEstimate.Default_Estimate__c = true;
                newEstimate.Shipping_Summary__c = sum.Id;
                newEstimate = QuoteLineGroupHandler.updateShippingEstimate(newEstimate, qlgQuantitiesMap, sum);
                System.debug('QuoteLineGroupHandler.buildDefault QLG: ' + sum.Name + ' EST Shipping: ' + newEstimate.Estimated_Shipping_Quantity__c);
                insertEstimateList.add(newEstimate);
                summaryAddIdMap.put(sum.Id, sum.Quote_Line_Group__c);
                quoteLineGroupIdList.add(sum.Quote_Line_Group__c);
            }
            //System.debug('summaryAddIdMap: ' + summaryAddIdMap);
            if (summaryAddIdMap.size() > 0) {
                OpportunityShippingController.updateGroupShipSummFuture(summaryAddIdMap);
                //OpportunityShippingController.quoteLineGroupSummaryUpdate(quoteLineGroupIdList);
            }
            if (insertEstimateList.size() > 0) {
                insert insertEstimateList;
            }
        }

        System.debug('QuoteLineGroupHandler.buildDefaultEstimates() oppIdList list size: ' + oppIdList.size());
        System.debug('QuoteLineGroupHandler.buildDefaultEstimates() oppIdList element: ' + oppIdList);

        if (oppIdList.size() > 0) {
            OpportunityFinancialsHandler.calculateOpportunityFinancials(oppIdList);
        }
    }*/

    /* ARMAN: private static Shipping_Estimate__c updateShippingEstimate(Shipping_Estimate__c estimate, Map<Id, Map<String, Decimal>> qlgQuantitiesMap, Shipping_Estimate_Summary__c summary) {
        estimate.Estimated_Shipping_Date__c = summary.Quote_Line_Group__r.SBQQ__Quote__r.SBQQ__Opportunity2__r.CloseDate;

        //System.debug('qlgQuantitiesMap: ' + qlgQuantitiesMap);
        if (qlgQuantitiesMap.get(summary.Quote_Line_Group__c) == null) {
            estimate.Estimated_Shipping_Quantity__c = 1;
        } else {
            Map<String, Decimal> qtyMap = qlgQuantitiesMap.get(summary.Quote_Line_Group__c);
            if (qtyMap.containsKey('sp') && qtyMap.get('sp') != 0) {
                estimate.Estimated_Shipping_Quantity__c = qtyMap.get('sp');
            } else if (qtyMap.containsKey('hw') && qtyMap.get('hw') != 0) {
                estimate.Estimated_Shipping_Quantity__c = qtyMap.get('hw');
            } else if (qtyMap.containsKey('ap') && qtyMap.get('ap') != 0) {
                estimate.Estimated_Shipping_Quantity__c = qtyMap.get('ap');
            } else if (qtyMap.containsKey('sw') && qtyMap.get('sw') != 0) {
                estimate.Estimated_Shipping_Quantity__c = qtyMap.get('sw');
            } else {
                estimate.Estimated_Shipping_Quantity__c = 1;
            }
        }

        return estimate;
    } */
}