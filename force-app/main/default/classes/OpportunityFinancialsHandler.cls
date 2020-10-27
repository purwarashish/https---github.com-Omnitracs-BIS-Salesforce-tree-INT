global class OpportunityFinancialsHandler {

    webservice static void calculateOpportunityFinancials(Id oppId) {
        System.debug(LoggingLevel.INFO, 'oppId:' + oppId);
        List<Id> oppIdList = new List<Id>();
        oppIdList.add(oppId);
        calculateOpportunityFinancials(oppIdList);
    }

    public static void calculateOpportunityFinancials(List<Id> oppIdList) {
        System.debug(LoggingLevel.INFO, 'oppIdList:' + oppIdList);
        List<Opportunity> oppList = new List<Opportunity>();
        oppList = [
                select Id, CloseDate, Max_Forecast_Number__c, SBQQ__PrimaryQuote__c, SBQQ__AmendedContract__c, SBQQ__AmendedContract__r.StartDate, SBQQ__AmendedContract__r.EndDate
                        , SBQQ__AmendedContract__r.Master_Term__c,SBQQ__AmendedContract__r.Master_Term_Remaining__c, RecordTypeId, Order_Type__c
                from Opportunity
                where Id in :oppIdList
        ];
        System.debug(LoggingLevel.INFO, 'oppList: ' + oppList);
        calculateOpportunityFinancials(oppList);
    }

    public static void calculateOpportunityFinancials(List<Opportunity> oppList) {
        System.debug(LoggingLevel.INFO, 'OpportunityFinancialsHandler.calculateOpportunityFinancials');
        // iterate the opportunity list
        /* ARMAN: List<Opportunity_Forecast__c> oppForecastList = new List<Opportunity_Forecast__c>();
        List<Opportunity> oppFCUpdateList = new List<Opportunity>();

        Map<Id, List<Opportunity_Forecast__c>> allOldForecastMap = buildOpportunityForecastMap(oppList);
        System.debug('OpportunityFinancialsHandler.calculateOpportunityFinancials allOldForecastMap: ' + allOldForecastMap.size() + ' oppList size: ' + oppList.size());
        */

        Map<Id, List<OpportunityLineItem>> allOppLineItemMap = buildOpportunityLineItemsMap(oppList);
        System.debug('OpportunityFinancialsHandler.calculateOpportunityFinancials allOppLineItemMap: ' + allOppLineItemMap.size() + ' oppList size: ' + oppList.size());
        Map<Id, List<SBQQ__QuoteLine__c>> allQuoteLinesPrimaryMap = buildQuoteLinePrimaryMap(oppList);
        System.debug('OpportunityFinancialsHandler.calculateOpportunityFinancials allQuoteLinesPrimaryMap: ' + allQuoteLinesPrimaryMap.size() + ' oppList size: ' + oppList.size());
        Map<Id, SBQQ__Quote__c> allPrimaryQuotesMap = buildPrimaryQuoteMap(oppList);
        System.debug('OpportunityFinancialsHandler.calculateOpportunityFinancials allPrimaryQuotesMap: ' + allPrimaryQuotesMap.size() + ' oppList size: ' + oppList.size());

        Map<Id, Opportunity> groupIdToOpportunityMap = new Map<Id, Opportunity>();
        for(Opportunity opportunity: oppList) {
            List<OpportunityLineItem> oliList = allOppLineItemMap.get(opportunity.Id);
            if(oliList != null) {
                for (OpportunityLineItem lineItem: oliList) {
                    groupIdToOpportunityMap.put(lineItem.SBQQ__QuoteLine__r.SBQQ__Group__r.Id, opportunity);
                }
            }
        }
        // ARMAN: Map<Id, Map<Date, Shipping_Estimate__c>> groupIdShippingEstimatesMap = getShippingEstimateDates(groupIdToOpportunityMap);

        Boolean incrementalIncrease = false;
        for (Opportunity opp : oppList) {
            System.debug(LoggingLevel.INFO, 'CurrentOpp: ' + opp);
            String oppRecTypeName = Schema.SObjectType.Opportunity.getRecordTypeInfosById().get(opp.RecordTypeId).getName();
            String oppOrderType = opp.Order_Type__c;

            // Only need to do the incremental version when Renewal Only AND order type is Annual Increase within Term.
            if(oppRecTypeName == 'Renewal Only' && oppOrderType == 'Annual Increase Within Term') {
                incrementalIncrease = true;
            }

            /* ARMAN: Integer maxForecastNumber = 0;
            Boolean deleteOldForecasts = true;// if set to false it will create new forecast records every time the opp moves to closed won.
            if (deleteOldForecasts) {
                List<Opportunity_Forecast__c> oldForecastList = allOldForecastMap.get(opp.Id);
                if (oldForecastList != null && oldForecastList.size() > 0) {
                    try {
                        delete oldForecastList;
                        //allOldForecastMap.remove(opp.Id);
                    } catch (Exception eek) {
                        // If the forecasts were deleted already, then we don't care that we can't delete them again.
                        System.debug('OpportunityFinancialsHandler.calculateOpportunityFinancials() exception happened while deleting, most likely forecasts were deleted already. ' + eek.getMessage());
                    }
                }
            } else {
                maxForecastNumber = retrieveMaxForecastNumber(allOldForecastMap.get(opp.Id));
            }
            opp.Max_Forecast_Number__c = maxForecastNumber + 1;
            oppFCUpdateList.add(opp);
            */

            // get the quote from the opportunity
            Id primQuote = opp.SBQQ__PrimaryQuote__c;
            if (Test.isRunningTest()) {
                primQuote = [SELECT Id, SBQQ__StartDate__c, SBQQ__EndDate__c, Master_Term_Remaining__c FROM SBQQ__Quote__c WHERE SBQQ__Opportunity2__c = :opp.Id].Id;
            }

            System.debug(LoggingLevel.INFO, 'primQuote: ' + primQuote);
            SBQQ__Quote__c pq;
            if (primQuote != null) {
                pq = allPrimaryQuotesMap.get(opp.Id);
            }
            //System.debug(LoggingLevel.INFO,'pq: ' + pq);
            Date forecastStartDate = null;
            Date forecastEndDate = null;
            if (Test.isRunningTest()) {
                forecastStartDate = System.today().toStartOfMonth();
                forecastEndDate = System.today().addMonths(12).toStartOfMonth();
            } else if (pq != null) {
                forecastStartDate = pq.SBQQ__StartDate__c.toStartOfMonth();
                forecastEndDate = pq.SBQQ__EndDate__c.toStartOfMonth();
            }

            // If we have an amendment quote type, we need to add the master term remaining to the quote end date for forecasting.
            if (pq != null && pq.SBQQ__Type__c == 'Amendment') {
                Integer monthsToAdd = Integer.valueOf(pq.Master_Term_Remaining__c);
                forecastEndDate = pq.SBQQ__EndDate__c.addMonths(monthsToAdd);
                forecastEndDate = forecastEndDate.toStartOfMonth();
                System.debug('OpportunityFinancialsHandler: Amendment forecastEndDate : ' + forecastEndDate);
            }

            System.debug('forecastStartDate: ' + forecastStartDate + ' forecastEndDate: ' + forecastEndDate);

            // get opportunity line items for next set of processing
            List<OpportunityLineItem> oliList = allOppLineItemMap.get(opp.Id);
            System.debug('Opp Line Item List: ' + oliList);
            if (oliList != null) {

                // get the quote lines from the primary quote
                List<SBQQ__QuoteLine__c> primQL = allQuoteLinesPrimaryMap.get(opp.SBQQ__PrimaryQuote__c);

                Map<Id, Decimal> groupHardwarePriceTotal = new Map<Id, Decimal>();
                Map<Id, Decimal> groupServicePlanPriceTotal = new Map<Id, Decimal>();
                Map<Id, Decimal> groupApplicationPriceTotal = new Map<Id, Decimal>();
                Map<Id, Decimal> groupSoftwarePriceTotal = new Map<Id, Decimal>();

                Map<Id, Decimal> groupQtyTotal = new Map<Id, Decimal>();

                for (OpportunityLineItem oli : oliList) {
                    System.debug(LoggingLevel.INFO, 'Current OLI: ' + oli);
                    if (oli.SBQQ__QuoteLine__r.SBQQ__Product__r.Shipment_Schedule_Required__c == true) {
                        groupHardwarePriceTotal = sumGroupTotalPrice(groupHardwarePriceTotal, oli, incrementalIncrease);
                    } else if (oli.SBQQ__QuoteLine__r.SBQQ__Product__r.Product_Type__c == 'Software'
                            && oli.SBQQ__QuoteLine__r.SBQQ__Product__r.Product_Sub_Type__c == 'Service Plans') {
                        groupServicePlanPriceTotal = sumGroupTotalPrice(groupServicePlanPriceTotal, oli, incrementalIncrease);
                    } else if (oli.SBQQ__QuoteLine__r.SBQQ__Product__r.Product_Type__c == 'Software'
                            && oli.SBQQ__QuoteLine__r.SBQQ__Product__r.Product_Sub_Type__c == 'Applications') {
                        groupApplicationPriceTotal = sumGroupTotalPrice(groupApplicationPriceTotal, oli, incrementalIncrease);
                    } else if (oli.SBQQ__QuoteLine__r.SBQQ__Product__r.Product_Type__c == 'Software'
                            && oli.SBQQ__QuoteLine__r.SBQQ__Product__r.Product_Sub_Type__c != 'Service Plans') {
                        groupSoftwarePriceTotal = sumGroupTotalPrice(groupSoftwarePriceTotal, oli, incrementalIncrease);
                    }

                    System.debug('OFH - setting Group_Service_Plan_Quantity_Rollup__c: ' + oli.SBQQ__QuoteLine__r.SBQQ__Group__r.Group_Service_Plan_Quantity_Rollup__c);
                    System.debug('OFH - setting Group_Hardware_Quantity_Rollup__c: ' + oli.SBQQ__QuoteLine__r.SBQQ__Group__r.Group_Hardware_Quantity_Rollup__c);
                    System.debug('OFH - setting Group_Application_Quantity_Rollup__c: ' + oli.SBQQ__QuoteLine__r.SBQQ__Group__r.Group_Application_Quantity_Rollup__c);
                    System.debug('OFH - setting Group_Software_Quantity_Rollup__c: ' + oli.SBQQ__QuoteLine__r.SBQQ__Group__r.Group_Software_Quantity_Rollup__c);
                    //groupQtyTotal = sumGroupTotalQty(groupQtyTotal, oli);
                    if (!groupQtyTotal.containsKey(oli.SBQQ__QuoteLine__r.SBQQ__Group__c)) {
                        if (oli.SBQQ__QuoteLine__r.SBQQ__Group__r.Group_Service_Plan_Quantity_Rollup__c != null && oli.SBQQ__QuoteLine__r.SBQQ__Group__r.Group_Service_Plan_Quantity_Rollup__c != 0) {
                            groupQtyTotal.put(oli.SBQQ__QuoteLine__r.SBQQ__Group__c, oli.SBQQ__QuoteLine__r.SBQQ__Group__r.Group_Service_Plan_Quantity_Rollup__c);
                        } else if (oli.SBQQ__QuoteLine__r.SBQQ__Group__r.Group_Hardware_Quantity_Rollup__c != null && oli.SBQQ__QuoteLine__r.SBQQ__Group__r.Group_Hardware_Quantity_Rollup__c != 0) {
                            groupQtyTotal.put(oli.SBQQ__QuoteLine__r.SBQQ__Group__c, oli.SBQQ__QuoteLine__r.SBQQ__Group__r.Group_Hardware_Quantity_Rollup__c);
                        } else if (oli.SBQQ__QuoteLine__r.SBQQ__Group__r.Group_Application_Quantity_Rollup__c != null && oli.SBQQ__QuoteLine__r.SBQQ__Group__r.Group_Application_Quantity_Rollup__c != 0) {
                            groupQtyTotal.put(oli.SBQQ__QuoteLine__r.SBQQ__Group__c, oli.SBQQ__QuoteLine__r.SBQQ__Group__r.Group_Application_Quantity_Rollup__c);
                        } else if (oli.SBQQ__QuoteLine__r.SBQQ__Group__r.Group_Software_Quantity_Rollup__c != null && oli.SBQQ__QuoteLine__r.SBQQ__Group__r.Group_Software_Quantity_Rollup__c != 0) {
                            groupQtyTotal.put(oli.SBQQ__QuoteLine__r.SBQQ__Group__c, oli.SBQQ__QuoteLine__r.SBQQ__Group__r.Group_Software_Quantity_Rollup__c);
                        }
                    }
                }

                for (OpportunityLineItem oli : oliList) {
                    System.debug(LoggingLevel.INFO, 'Current OLI iterator 2: ' + oli);
                    Date nextDate = forecastStartDate;
                    Integer forecastOffset = 0;
                    if (oli.SBQQ__QuoteLine__r.SBQQ__Product__r.Forecast_Offset__c != null
                            && oli.Opportunity.Order_Type__c == 'New') {
                        if (oli.Opportunity.RecordType.Name != 'Data Migration') {
                            forecastOffset = Integer.valueOf(oli.SBQQ__QuoteLine__r.SBQQ__Product__r.Forecast_Offset__c);
                        }
                    }
                    Integer billingFreqInt = 0;
                    Decimal freqMultiplier = 1;
                    if (oli.SBQQ__QuoteLine__r.SBQQ__Product__r.Revenue_Recognition_Frequency__c != null) {
                        // values in product are Once, Monthly, Quarterly, Annual
                        String revRecFrequency = oli.SBQQ__QuoteLine__r.SBQQ__Product__r.Revenue_Recognition_Frequency__c;
                        String billingFrequency = oli.SBQQ__QuoteLine__r.SBQQ__Product__r.Billing_Frequency_QLE__c;
                        
                        if (revRecFrequency == 'Once') {
                            billingFreqInt = 0;
                        } else if (revRecFrequency == 'Monthly') {
                            billingFreqInt = 1;
                        } else if (revRecFrequency == 'Quarterly') {
                            billingFreqInt = 3;
                        } else if (revRecFrequency == 'Annual') {
                            billingFreqInt = 12;
                        }
                        System.debug('*********** billingFrequency '+billingFrequency+' -- '+revRecFrequency);
                        if(String.isNotBlank(billingFrequency) && billingFrequency != revRecFrequency){
                        	if((billingFrequency == 'Once' || billingFrequency == 'Annual') && revRecFrequency == 'Monthly'){
                        		freqMultiplier = 0.083333;
                        	}
                        	
                        	else if(billingFrequency == 'Monthly' && (revRecFrequency == 'Once' || revRecFrequency == 'Annual')){
                        		freqMultiplier = 12;
                        	}
                        }
                    }
                    
                    System.debug(LoggingLevel.INFO, 'freqMultiplier: ' + freqMultiplier);
                    
                    System.debug(LoggingLevel.INFO, 'Billing Freq: ' + billingFreqInt);

                    Id groupId = oli.SBQQ__QuoteLine__r.SBQQ__Group__r.Id;
                    System.debug(LoggingLevel.INFO, 'groupId: ' + groupId);
                    /* ARMAN: Map<Date, Shipping_Estimate__c> offsetMap = new Map<Date, Shipping_Estimate__c>();

                    //Map<Date, Shipping_Estimate__c> shipEstMap = getShippingEstimateDates(groupId, opp);
                    Map<Date, Shipping_Estimate__c> shipEstMap = groupIdShippingEstimatesMap.get(groupId);
                    if (forecastOffset > 0) {
                        for (Date seDate : shipEstMap.keySet()) {
                            Date offsetDate = seDate.addMonths(forecastOffset);
                            offsetMap.put(offsetDate.toStartOfMonth(), shipEstMap.get(seDate));
                        }
                    }
                    if (offsetMap.size() > 0) {
                        shipEstMap = offsetMap;
                    }
                    System.debug(LoggingLevel.INFO, 'shipEstMap: ' + shipEstMap); */

                    System.debug(LoggingLevel.INFO, 'oli Shipment_Schedule_Required__c: ' + oli.SBQQ__QuoteLine__r.SBQQ__Product__r.Shipment_Schedule_Required__c);
                    System.debug(LoggingLevel.INFO, 'oli Product_Type__c: ' + oli.SBQQ__QuoteLine__r.SBQQ__Product__r.Product_Type__c);
                    System.debug(LoggingLevel.INFO, 'oli Product_Sub_Type__c: ' + oli.SBQQ__QuoteLine__r.SBQQ__Product__r.Product_Sub_Type__c);

                    if (oli.SBQQ__QuoteLine__r.SBQQ__Product__r.Shipment_Schedule_Required__c && oli.SBQQ__QuoteLine__r.SBQQ__Product__r.License_Type__c != 'Subscription') {
                        System.debug(LoggingLevel.INFO, 'Group Hardware Price Total Map: ' + groupHardwarePriceTotal);
                        if (groupHardwarePriceTotal.size() > 0) {
                            //Decimal totalPrice = oli.TotalPrice;
                            //Decimal finalUnitPrice = oli.SBQQ__QuoteLine__r.Final_Unit_Price__c;
                            Decimal totalPrice = 0.00;
                            if (incrementalIncrease) {
                                totalPrice = (oli.SBQQ__QuoteLine__r.SBQQ__ListPrice__c - oli.SBQQ__QuoteLine__r.SBQQ__OriginalPrice__c) * oli.Quantity;
                            } else {
                                if (oli.SBQQ__QuoteLine__r.Final_Unit_Price__c != 0) {
                                    totalPrice = oli.SBQQ__QuoteLine__r.Final_Unit_Price__c * oli.Quantity;
                                }
                            }
                            Decimal groupTotalPrice = groupHardwarePriceTotal.get(groupId);
                            Decimal groupTotalQty = groupQtyTotal.get(groupId);
                            Decimal linePctOfGroup = 1.00;
                            Decimal qtyPctOfGroup = 1.00;
                            Decimal groupAPUP = 0.00;
                            System.debug('totalPrice: ' + totalPrice);
                            System.debug('groupTotalPrice: ' + groupTotalPrice);
                            System.debug('aaa groupTotalQty: ' + groupTotalQty);
                            if(groupTotalQty == null) {
                                System.debug('OpportunityFinancialsHandler aaa groupId: ' + groupId + ' groupQtyTotal: ' + groupQtyTotal);
                            }
                            System.debug(LoggingLevel.INFO, 'record type: ' + oppRecTypeName + ' incIncrease: ' + incrementalIncrease);
                            if (incrementalIncrease) {
                                groupAPUP = oli.SBQQ__QuoteLine__r.SBQQ__ListPrice__c - oli.SBQQ__QuoteLine__r.SBQQ__OriginalPrice__c;
                            } else {
                                groupAPUP = oli.SBQQ__QuoteLine__r.Final_Unit_Price__c;
                            }
                            //if (oli.Quantity < 0) {
                            //    groupAPUP = 0.00;
                            //}
                            if (groupTotalPrice != 0) {
                                linePctOfGroup = (Math.abs(totalPrice) / Math.abs(groupTotalPrice));
                                if(groupTotalQty == null){
                                    qtyPctOfGroup = 1;
                                    groupAPUP = 1;
                                }else{
                                    qtyPctOfGroup = (Math.abs(oli.Quantity) / Math.abs(groupTotalQty));
                                    groupAPUP = (Math.abs(groupTotalPrice) / Math.abs(groupTotalQty));
                                }
                            }

                            System.debug(LoggingLevel.INFO, 'groupAPUP: ' + groupAPUP);
                            System.debug(LoggingLevel.INFO, 'linePctOfGroup: ' + linePctOfGroup);
                            Boolean readyToOutput = false;
                            Integer dn = 0;
                            if (billingFreqInt > 0) {
                                dn = 1;
                            }
                            Decimal rollingQuantity = 0.0;
                            Decimal rollingPrice = 0.0;
                            Decimal forecastPrice = 0.0;
                            // System.debug('OpportunityFinancialsHandler shipEstMap: ' + shipEstMap);
                            while (nextDate < forecastEndDate) {
                                System.debug('OpportunityFinancialsHandler 1 NextDate: ' + nextDate);
                                /* ARMAN: if (shipEstMap.containsKey(nextDate)) {
                                    System.debug(LoggingLevel.INFO, 'ship est qty: ' + shipEstMap.get(nextDate).Estimated_Shipping_Quantity__c);
                                }*/
                                System.debug('rolling quantity: ' + rollingQuantity);
                                System.debug('rolling price: ' + rollingPrice);
                                System.debug('forecast price: ' + forecastPrice);
                                if (dn < billingFreqInt) {
                                    System.debug('dn < billingFreqInt');
                                    dn = dn + 1;
                                    /* ARMAN: if (shipEstMap.containsKey(nextDate)) {
                                        forecastPrice = linePctOfGroup * groupAPUP * shipEstMap.get(nextDate).Estimated_Shipping_Quantity__c;
                                        rollingPrice = rollingPrice + forecastPrice;
                                        rollingQuantity = rollingQuantity + (qtyPctOfGroup * shipEstMap.get(nextDate).Estimated_Shipping_Quantity__c);
                                        readyToOutput = true;
                                    } */
                                } else if (dn == billingFreqInt && dn != 0) {
                                    System.debug(LoggingLevel.INFO, 'dn = billingFreqInt');
                                    /* ARMAN: if (shipEstMap.containsKey(nextDate)) {
                                        System.debug(LoggingLevel.INFO, 'dn=bf if 1');
                                        Opportunity_Forecast__c oppForecast = new Opportunity_Forecast__c();
                                        oppForecast.Opportunity__c = opp.Id;
                                        oppForecast.Product__c = oli.SBQQ__QuoteLine__r.SBQQ__Product__r.Id;
                                        oppForecast.Quote__c = opp.SBQQ__PrimaryQuote__r.Id;
                                        oppForecast.Quote_Line__c = oli.SBQQ__QuoteLine__r.Id;
                                        oppForecast.Quote_Line_Group__c = oli.SBQQ__QuoteLine__r.SBQQ__Group__r.Id;
                                        oppForecast.Forecast_Date__c = nextDate;
                                        oppForecast.Forecast_Created_Date__c = System.today();
                                        oppForecast.Forecast_Number__c = maxForecastNumber + 1;
                                        forecastPrice = linePctOfGroup * groupAPUP * shipEstMap.get(nextDate).Estimated_Shipping_Quantity__c;
                                        rollingPrice = forecastPrice;
                                        rollingQuantity = qtyPctOfGroup * shipEstMap.get(nextDate).Estimated_Shipping_Quantity__c;
                                        oppForecast.Forecast_Amount__c = (rollingPrice != null)?rollingPrice*freqMultiplier:rollingPrice;
                                        oppForecast.Forecast_Quantity__c = rollingQuantity;
                                        oppForecastList.add(oppForecast);
                                    }
                                    else */ if (readyToOutput == true) {
                                        System.debug(LoggingLevel.INFO, 'dn=bf else');
                                        /* ARMAN: Opportunity_Forecast__c oppForecast = new Opportunity_Forecast__c();
                                        oppForecast.Opportunity__c = opp.Id;
                                        oppForecast.Product__c = oli.SBQQ__QuoteLine__r.SBQQ__Product__r.Id;
                                        oppForecast.Quote__c = opp.SBQQ__PrimaryQuote__r.Id;
                                        oppForecast.Quote_Line__c = oli.SBQQ__QuoteLine__r.Id;
                                        oppForecast.Quote_Line_Group__c = oli.SBQQ__QuoteLine__r.SBQQ__Group__r.Id;
                                        oppForecast.Forecast_Date__c = nextDate;
                                        oppForecast.Forecast_Created_Date__c = System.today();
                                        oppForecast.Forecast_Number__c = maxForecastNumber + 1;
                                        oppForecast.Forecast_Amount__c = (rollingPrice != null)?rollingPrice*freqMultiplier:rollingPrice;
                                        oppForecast.Forecast_Quantity__c = rollingQuantity;
                                        oppForecastList.add(oppForecast);
                                        */
                                    }
                                    dn = 1;
                                } else {
                                    System.debug(LoggingLevel.INFO, 'final else');
                                    // billing freq of once
                                    /* ARMAN: if (shipEstMap.containsKey(nextDate)) {
                                        Opportunity_Forecast__c oppForecast = new Opportunity_Forecast__c();
                                        oppForecast.Opportunity__c = opp.Id;
                                        oppForecast.Product__c = oli.SBQQ__QuoteLine__r.SBQQ__Product__r.Id;
                                        oppForecast.Quote__c = opp.SBQQ__PrimaryQuote__r.Id;
                                        oppForecast.Quote_Line__c = oli.SBQQ__QuoteLine__r.Id;
                                        oppForecast.Quote_Line_Group__c = oli.SBQQ__QuoteLine__r.SBQQ__Group__r.Id;
                                        oppForecast.Forecast_Date__c = nextDate;
                                        oppForecast.Forecast_Created_Date__c = System.today();
                                        oppForecast.Forecast_Number__c = maxForecastNumber + 1;
                                        if (nextDate != null && shipEstMap.get(nextDate).Estimated_Shipping_Quantity__c != null) {
                                            forecastPrice = linePctOfGroup * groupAPUP * shipEstMap.get(nextDate).Estimated_Shipping_Quantity__c;
                                            rollingQuantity = qtyPctOfGroup * shipEstMap.get(nextDate).Estimated_Shipping_Quantity__c;
                                        }
                                        rollingPrice = forecastPrice;
                                        oppForecast.Forecast_Amount__c = (rollingPrice != null)?rollingPrice*freqMultiplier:rollingPrice;
                                        oppForecast.Forecast_Quantity__c = rollingQuantity;
                                        oppForecastList.add(oppForecast);
                                    } */
                                }
                                nextDate = nextDate.addMonths(1).toStartOfMonth();
                            }
                        }
                    } else if (oli.SBQQ__QuoteLine__r.SBQQ__Product__r.Shipment_Schedule_Required__c && oli.SBQQ__QuoteLine__r.SBQQ__Product__r.License_Type__c == 'Subscription') {
                        System.debug(LoggingLevel.INFO, 'Group Hardware Price Total Map: ' + groupHardwarePriceTotal);
                        if (groupHardwarePriceTotal.size() > 0) {
                            //Decimal totalPrice = oli.TotalPrice;
                            //Decimal finalUnitPrice = oli.SBQQ__QuoteLine__r.Final_Unit_Price__c;
                            Decimal totalPrice = 0.00;
                            if (incrementalIncrease) {
                                totalPrice = (oli.SBQQ__QuoteLine__r.SBQQ__ListPrice__c - oli.SBQQ__QuoteLine__r.SBQQ__OriginalPrice__c) * oli.Quantity;
                            } else {
                                if (oli.SBQQ__QuoteLine__r.Final_Unit_Price__c != 0) {
                                    totalPrice = oli.SBQQ__QuoteLine__r.Final_Unit_Price__c * oli.Quantity;
                                }
                            }
                            Decimal groupTotalPrice = groupHardwarePriceTotal.get(groupId);
                            Decimal groupTotalQty = groupQtyTotal.get(groupId);
                            Decimal linePctOfGroup = 1.00;
                            Decimal qtyPctOfGroup = 1.00;
                            Decimal groupAPUP = 0.00;
                            System.debug('totalPrice: ' + totalPrice);
                            System.debug('groupTotalPrice: ' + groupTotalPrice);
                            System.debug('aaa groupTotalQty: ' + groupTotalQty);
                            if(groupTotalQty == null) {
                                System.debug('OpportunityFinancialsHandler aaa groupId: ' + groupId + ' groupQtyTotal: ' + groupQtyTotal);
                            }
                            System.debug(LoggingLevel.INFO, 'record type: ' + oppRecTypeName + ' incIncrease: ' + incrementalIncrease);
                            if (incrementalIncrease) {
                                groupAPUP = oli.SBQQ__QuoteLine__r.SBQQ__ListPrice__c - oli.SBQQ__QuoteLine__r.SBQQ__OriginalPrice__c;
                            } else {
                                groupAPUP = oli.SBQQ__QuoteLine__r.Final_Unit_Price__c;
                            }
                            //if (oli.Quantity < 0) {
                            //    groupAPUP = 0.00;
                            //}
                            if (groupTotalPrice != 0) {
                                linePctOfGroup = (Math.abs(totalPrice) / Math.abs(groupTotalPrice));
                                if(groupTotalQty == null){
                                    qtyPctOfGroup = 1;
                                    groupAPUP = 1;
                                }else{
                                    qtyPctOfGroup = (Math.abs(oli.Quantity) / Math.abs(groupTotalQty));
                                    groupAPUP = (Math.abs(groupTotalPrice) / Math.abs(groupTotalQty));
                                }
                            }

                            System.debug(LoggingLevel.INFO, 'groupAPUP: ' + groupAPUP);
                            System.debug(LoggingLevel.INFO, 'linePctOfGroup: ' + linePctOfGroup);
                            Integer dn = 0;
                            if (billingFreqInt > 0) {
                                dn = 1;
                            }
                            Decimal rollingQuantity = 0.0;
                            Decimal rollingPrice = 0.0;
                            Decimal forecastPrice = 0.0;
                            //System.debug('OpportunityFinancialsHandler shipEstMap: ' + shipEstMap);
                            while (nextDate < forecastEndDate) {
                                System.debug('OpportunityFinancialsHandler 1 NextDate: ' + nextDate);
                                /* ARMAN: if (shipEstMap.containsKey(nextDate)) {
                                    System.debug(LoggingLevel.INFO, 'ship est qty: ' + shipEstMap.get(nextDate).Estimated_Shipping_Quantity__c);
                                } */
                                System.debug('rolling quantity: ' + rollingQuantity);
                                System.debug('rolling price: ' + rollingPrice);
                                System.debug('forecast price: ' + forecastPrice);
                                if (dn < billingFreqInt) {
                                    System.debug('dn < billingFreqInt');
                                    dn = dn + 1;
                                    /* ARMAN: if (shipEstMap.containsKey(nextDate)) {
                                        forecastPrice = linePctOfGroup * groupAPUP * shipEstMap.get(nextDate).Estimated_Shipping_Quantity__c;
                                        rollingPrice = rollingPrice + forecastPrice;
                                        rollingQuantity = rollingQuantity + (qtyPctOfGroup * shipEstMap.get(nextDate).Estimated_Shipping_Quantity__c);
                                    } */
                                } else if (dn == billingFreqInt && dn != 0) {
                                    System.debug(LoggingLevel.INFO, 'dn = billingFreqInt');
                                    /* ARMAN: if (shipEstMap.containsKey(nextDate)) {
                                        System.debug(LoggingLevel.INFO, 'dn=bf if 1');
                                        Opportunity_Forecast__c oppForecast = new Opportunity_Forecast__c();
                                        oppForecast.Opportunity__c = opp.Id;
                                        oppForecast.Product__c = oli.SBQQ__QuoteLine__r.SBQQ__Product__r.Id;
                                        oppForecast.Quote__c = opp.SBQQ__PrimaryQuote__r.Id;
                                        oppForecast.Quote_Line__c = oli.SBQQ__QuoteLine__r.Id;
                                        oppForecast.Quote_Line_Group__c = oli.SBQQ__QuoteLine__r.SBQQ__Group__r.Id;
                                        oppForecast.Forecast_Date__c = nextDate;
                                        oppForecast.Forecast_Created_Date__c = System.today();
                                        oppForecast.Forecast_Number__c = maxForecastNumber + 1;
                                        forecastPrice = linePctOfGroup * groupAPUP * shipEstMap.get(nextDate).Estimated_Shipping_Quantity__c;
                                        rollingPrice = rollingPrice + forecastPrice;
                                        rollingQuantity = rollingQuantity + (qtyPctOfGroup * shipEstMap.get(nextDate).Estimated_Shipping_Quantity__c);
                                        oppForecast.Forecast_Amount__c = (rollingPrice != null)?rollingPrice*freqMultiplier:rollingPrice;
                                        oppForecast.Forecast_Quantity__c = rollingQuantity;
                                        oppForecastList.add(oppForecast);
                                    } else  {
                                        System.debug(LoggingLevel.INFO, 'dn=bf else');
                                        Opportunity_Forecast__c oppForecast = new Opportunity_Forecast__c();
                                        oppForecast.Opportunity__c = opp.Id;
                                        oppForecast.Product__c = oli.SBQQ__QuoteLine__r.SBQQ__Product__r.Id;
                                        oppForecast.Quote__c = opp.SBQQ__PrimaryQuote__r.Id;
                                        oppForecast.Quote_Line__c = oli.SBQQ__QuoteLine__r.Id;
                                        oppForecast.Quote_Line_Group__c = oli.SBQQ__QuoteLine__r.SBQQ__Group__r.Id;
                                        oppForecast.Forecast_Date__c = nextDate;
                                        oppForecast.Forecast_Created_Date__c = System.today();
                                        oppForecast.Forecast_Number__c = maxForecastNumber + 1;
                                        oppForecast.Forecast_Amount__c = (rollingPrice != null)?rollingPrice*freqMultiplier:rollingPrice;
                                        oppForecast.Forecast_Quantity__c = rollingQuantity;
                                        oppForecastList.add(oppForecast);

                                    } */
                                    dn = 1;
                                } else {
                                    System.debug(LoggingLevel.INFO, 'final else');
                                    // billing freq of once
                                    /*if (shipEstMap.containsKey(nextDate)) {
                                        Opportunity_Forecast__c oppForecast = new Opportunity_Forecast__c();
                                        oppForecast.Opportunity__c = opp.Id;
                                        oppForecast.Product__c = oli.SBQQ__QuoteLine__r.SBQQ__Product__r.Id;
                                        oppForecast.Quote__c = opp.SBQQ__PrimaryQuote__r.Id;
                                        oppForecast.Quote_Line__c = oli.SBQQ__QuoteLine__r.Id;
                                        oppForecast.Quote_Line_Group__c = oli.SBQQ__QuoteLine__r.SBQQ__Group__r.Id;
                                        oppForecast.Forecast_Date__c = nextDate;
                                        oppForecast.Forecast_Created_Date__c = System.today();
                                        oppForecast.Forecast_Number__c = maxForecastNumber + 1;
                                        if (nextDate != null && shipEstMap.get(nextDate).Estimated_Shipping_Quantity__c != null) {
                                            forecastPrice = linePctOfGroup * groupAPUP * shipEstMap.get(nextDate).Estimated_Shipping_Quantity__c;
                                            rollingQuantity = qtyPctOfGroup * shipEstMap.get(nextDate).Estimated_Shipping_Quantity__c;
                                        }
                                        rollingPrice = forecastPrice;
                                        oppForecast.Forecast_Amount__c = (rollingPrice != null)?rollingPrice*freqMultiplier:rollingPrice;
                                        oppForecast.Forecast_Quantity__c = rollingQuantity;
                                        oppForecastList.add(oppForecast);
                                    }*/
                                }
                                nextDate = nextDate.addMonths(1).toStartOfMonth();
                            }
                        }
                    } else if (oli.SBQQ__QuoteLine__r.SBQQ__Product__r.Product_Type__c == 'Software'
                            && oli.SBQQ__QuoteLine__r.SBQQ__Product__r.Product_Sub_Type__c == 'Service Plans') {
                        System.debug(LoggingLevel.INFO, 'Group Service Plan Price Total Map: ' + groupServicePlanPriceTotal);
                        if (groupServicePlanPriceTotal.size() > 0) {
                            //Decimal finalUnitPrice = oli.SBQQ__QuoteLine__r.Final_Unit_Price__c;
                            //System.debug(LoggingLevel.INFO,'finalUnitPrice: ' + finalUnitPrice);
                            Decimal totalPrice = 0.00;
                            System.debug(LoggingLevel.INFO, 'totalPrice1: ' + totalPrice);
                            if (incrementalIncrease) {
                                System.debug('list price: ' + oli.SBQQ__QuoteLine__r.SBQQ__ListPrice__c);
                                System.debug('original price: ' + oli.SBQQ__QuoteLine__r.SBQQ__OriginalPrice__c);
                                totalPrice = (oli.SBQQ__QuoteLine__r.SBQQ__ListPrice__c - oli.SBQQ__QuoteLine__r.SBQQ__OriginalPrice__c) * oli.Quantity;
                                System.debug(LoggingLevel.INFO, 'totalPrice2: ' + totalPrice);
                            } else {
                                if (oli.SBQQ__QuoteLine__r.Final_Unit_Price__c != 0) {
                                    totalPrice = oli.SBQQ__QuoteLine__r.Final_Unit_Price__c * oli.Quantity;
                                }
                                System.debug(LoggingLevel.INFO, 'totalPrice3: ' + totalPrice);
                            }
                            Decimal groupTotalPrice = groupServicePlanPriceTotal.get(groupId);
                            Decimal groupTotalQty = groupQtyTotal.get(groupId);
                            Decimal linePctOfGroup = 1.00;
                            Decimal qtyPctOfGroup = 1.00;
                            Decimal groupAPUP = 0.00;
                            System.debug('totalPrice: ' + totalPrice);
                            System.debug('groupTotalPrice: ' + groupTotalPrice);
                            System.debug('aba groupTotalQty: ' + groupTotalQty);
                            if(groupTotalQty == null) {
                                System.debug('OpportunityFinancialsHandler aba groupId: ' + groupId + ' groupQtyTotal: ' + groupQtyTotal);
                            }
                            System.debug(LoggingLevel.INFO, 'record type: ' + oppRecTypeName + ' incrementalIncrease: ' + incrementalIncrease);
                            if (incrementalIncrease) {
                                groupAPUP = oli.SBQQ__QuoteLine__r.SBQQ__ListPrice__c - oli.SBQQ__QuoteLine__r.SBQQ__OriginalPrice__c;
                            } else {
                                groupAPUP = oli.SBQQ__QuoteLine__r.Final_Unit_Price__c;
                            }

                            if (groupTotalPrice != 0) {
                                linePctOfGroup = (Math.abs(totalPrice) / Math.abs(groupTotalPrice));
                                if(groupTotalQty == null){
                                    qtyPctOfGroup = 1;
                                    groupAPUP = 1;
                                }else{
                                    qtyPctOfGroup = (Math.abs(oli.Quantity) / Math.abs(groupTotalQty));
                                    groupAPUP = (Math.abs(groupTotalPrice) / Math.abs(groupTotalQty));
                                }
                            }

                            System.debug(LoggingLevel.INFO, 'linePctOfGroup: ' + linePctOfGroup);
                            System.debug(LoggingLevel.INFO, 'qtyPctOfGroup: ' + qtyPctOfGroup);
                            System.debug(LoggingLevel.INFO, 'groupAPUP: ' + groupAPUP);
                            Boolean spComplete = false;
                            Integer dn = 0;
                            if (billingFreqInt > 0) {
                                dn = 1;
                            }
                            Decimal rollingQuantity = 0.0;
                            Decimal rollingPrice = 0.0;
                            Decimal forecastPrice = 0.0;
                            while (nextDate < forecastEndDate) {
                                System.debug('OpportunityFinancialsHandler 2 NextDate: ' + nextDate);
                                System.debug(LoggingLevel.INFO, 'rolling quantity: ' + rollingQuantity);
                                System.debug(LoggingLevel.INFO, 'rolling price: ' + rollingPrice);
                                System.debug(LoggingLevel.INFO, 'forecast price: ' + forecastPrice);
                                if (spComplete == true) {
                                    break;
                                } else {
                                    if (dn < billingFreqInt) {
                                        dn = dn + 1;
                                        /* ARMAN: if (shipEstMap.containsKey(nextDate)) {
                                            forecastPrice = linePctOfGroup * groupAPUP * shipEstMap.get(nextDate).Estimated_Shipping_Quantity__c;
                                            rollingPrice = rollingPrice + forecastPrice;
                                            rollingQuantity = rollingQuantity + (qtyPctOfGroup * shipEstMap.get(nextDate).Estimated_Shipping_Quantity__c);
                                        } */
                                    } else if (dn == billingFreqInt && dn != 0) {
                                        /* ARMAN: if (shipEstMap.containsKey(nextDate)) {
                                            Opportunity_Forecast__c oppForecast = new Opportunity_Forecast__c();
                                            oppForecast.Opportunity__c = opp.Id;
                                            oppForecast.Product__c = oli.SBQQ__QuoteLine__r.SBQQ__Product__r.Id;
                                            oppForecast.Quote__c = opp.SBQQ__PrimaryQuote__r.Id;
                                            oppForecast.Quote_Line__c = oli.SBQQ__QuoteLine__r.Id;
                                            oppForecast.Quote_Line_Group__c = oli.SBQQ__QuoteLine__r.SBQQ__Group__r.Id;
                                            oppForecast.Forecast_Date__c = nextDate;
                                            oppForecast.Forecast_Created_Date__c = System.today();
                                            oppForecast.Forecast_Number__c = maxForecastNumber + 1;
                                            if (nextDate != null && shipEstMap.get(nextDate).Estimated_Shipping_Quantity__c != null) {
                                                forecastPrice = linePctOfGroup * groupAPUP * shipEstMap.get(nextDate).Estimated_Shipping_Quantity__c;
                                                rollingQuantity = rollingQuantity + (qtyPctOfGroup * shipEstMap.get(nextDate).Estimated_Shipping_Quantity__c);

                                            }
                                            rollingPrice = rollingPrice + forecastPrice;
                                            oppForecast.Forecast_Amount__c = (rollingPrice != null)?rollingPrice*freqMultiplier:rollingPrice;
                                            oppForecast.Forecast_Quantity__c = rollingQuantity;
                                            oppForecastList.add(oppForecast);
                                        } else {
                                            Opportunity_Forecast__c oppForecast = new Opportunity_Forecast__c();
                                            oppForecast.Opportunity__c = opp.Id;
                                            oppForecast.Product__c = oli.SBQQ__QuoteLine__r.SBQQ__Product__r.Id;
                                            oppForecast.Quote__c = opp.SBQQ__PrimaryQuote__r.Id;
                                            oppForecast.Quote_Line__c = oli.SBQQ__QuoteLine__r.Id;
                                            oppForecast.Quote_Line_Group__c = oli.SBQQ__QuoteLine__r.SBQQ__Group__r.Id;
                                            oppForecast.Forecast_Date__c = nextDate;
                                            oppForecast.Forecast_Created_Date__c = System.today();
                                            oppForecast.Forecast_Number__c = maxForecastNumber + 1;
                                            oppForecast.Forecast_Amount__c = (rollingPrice != null)?rollingPrice*freqMultiplier:rollingPrice;
                                            oppForecast.Forecast_Quantity__c = rollingQuantity;
                                            oppForecastList.add(oppForecast);
                                        } */
                                        dn = 1;
                                    } else {
                                        // billing freq of once
                                        /* ARMAN: if (shipEstMap.containsKey(nextDate)) {
                                            Opportunity_Forecast__c oppForecast = new Opportunity_Forecast__c();
                                            oppForecast.Opportunity__c = opp.Id;
                                            oppForecast.Product__c = oli.SBQQ__QuoteLine__r.SBQQ__Product__r.Id;
                                            oppForecast.Quote__c = opp.SBQQ__PrimaryQuote__r.Id;
                                            oppForecast.Quote_Line__c = oli.SBQQ__QuoteLine__r.Id;
                                            oppForecast.Quote_Line_Group__c = oli.SBQQ__QuoteLine__r.SBQQ__Group__r.Id;
                                            oppForecast.Forecast_Date__c = nextDate;
                                            oppForecast.Forecast_Created_Date__c = System.today();
                                            oppForecast.Forecast_Number__c = maxForecastNumber + 1;
                                            oppForecast.Forecast_Amount__c = (oli.TotalPrice != null)?oli.TotalPrice*freqMultiplier:oli.TotalPrice;
                                            oppForecast.Forecast_Quantity__c = oli.Quantity;
                                            oppForecastList.add(oppForecast);
                                            spComplete = true;
                                        } */
                                    }
                                }
                                nextDate = nextDate.addMonths(1).toStartOfMonth();
                            }
                        }
                    } else if (oli.SBQQ__QuoteLine__r.SBQQ__Product__r.Product_Type__c == 'Software'
                            && oli.SBQQ__QuoteLine__r.SBQQ__Product__r.Product_Sub_Type__c == 'Applications') {
                        System.debug(LoggingLevel.INFO, 'Group Application Price Total Map: ' + groupApplicationPriceTotal);
                        if (groupApplicationPriceTotal.size() > 0) {
                            //Decimal finalUnitPrice = oli.SBQQ__QuoteLine__r.Final_Unit_Price__c;
                            //System.debug(LoggingLevel.INFO,'finalUnitPrice: ' + finalUnitPrice);
                            Decimal totalPrice = 0.00;
                            if (incrementalIncrease) {
                                totalPrice = (oli.SBQQ__QuoteLine__r.SBQQ__ListPrice__c - oli.SBQQ__QuoteLine__r.SBQQ__OriginalPrice__c) * oli.Quantity;
                            } else {
                                if (oli.SBQQ__QuoteLine__r.Final_Unit_Price__c != 0) {
                                    totalPrice = oli.SBQQ__QuoteLine__r.Final_Unit_Price__c * oli.Quantity;
                                }
                            }
                            Decimal groupTotalPrice = groupApplicationPriceTotal.get(groupId);
                            Decimal groupTotalQty = groupQtyTotal.get(groupId);
                            Decimal linePctOfGroup = 1.00;
                            Decimal qtyPctOfGroup = 1.00;
                            Decimal groupAPUP = 0.00;
                            System.debug('totalPrice: ' + totalPrice);
                            System.debug('groupTotalPrice: ' + groupTotalPrice);
                            System.debug('aca groupTotalQty: ' + groupTotalQty);
                            if(groupTotalQty == null) {
                                System.debug('OpportunityFinancialsHandler aca groupId: ' + groupId + ' groupQtyTotal: ' + groupQtyTotal);
                            }
                            System.debug(LoggingLevel.INFO, 'record type: ' + oppRecTypeName + ' incrementalIncrease: ' + incrementalIncrease);
                            if (incrementalIncrease) {
                                groupAPUP = oli.SBQQ__QuoteLine__r.SBQQ__ListPrice__c - oli.SBQQ__QuoteLine__r.SBQQ__OriginalPrice__c;
                            } else {
                                groupAPUP = oli.SBQQ__QuoteLine__r.Final_Unit_Price__c;
                            }
                            if (groupTotalPrice != 0) {
                                linePctOfGroup = (Math.abs(totalPrice) / Math.abs(groupTotalPrice));
                                if(groupTotalQty == null){
                                    qtyPctOfGroup = 1;
                                    groupAPUP = 1;
                                }else{
                                    qtyPctOfGroup = (Math.abs(oli.Quantity) / Math.abs(groupTotalQty));
                                    groupAPUP = (Math.abs(groupTotalPrice) / Math.abs(groupTotalQty));
                                }
                                //groupAPUP = (Math.abs(groupTotalPrice) / Math.abs(groupTotalQty));
                            }

                            System.debug(LoggingLevel.INFO, 'groupAPUP: ' + groupAPUP);
                            System.debug(LoggingLevel.INFO, 'linePctOfGroup: ' + linePctOfGroup);
                            System.debug(LoggingLevel.INFO, 'qtyPctOfGroup: ' + qtyPctOfGroup);
                            Boolean spComplete = false;
                            Integer dn = 0;
                            if (billingFreqInt > 0) {
                                dn = 1;
                            }
                            Decimal rollingQuantity = 0.0;
                            Decimal rollingPrice = 0.0;
                            Decimal forecastPrice = 0.0;
                            while (nextDate < forecastEndDate) {
                                System.debug('OpportunityFinancialsHandler 3 NextDate: ' + nextDate);
                                System.debug(LoggingLevel.INFO, 'rolling quantity: ' + rollingQuantity);
                                System.debug(LoggingLevel.INFO, 'rolling price: ' + rollingPrice);
                                System.debug(LoggingLevel.INFO, 'forecast price: ' + forecastPrice);
                                if (spComplete == true) {
                                    break;
                                } else {
                                    if (dn < billingFreqInt) {
                                        dn = dn + 1;
                                        /* ARMAN: if (shipEstMap.containsKey(nextDate)) {
                                            forecastPrice = linePctOfGroup * groupAPUP * shipEstMap.get(nextDate).Estimated_Shipping_Quantity__c;
                                            rollingPrice = rollingPrice + forecastPrice;
                                            rollingQuantity = rollingQuantity + (qtyPctOfGroup * shipEstMap.get(nextDate).Estimated_Shipping_Quantity__c);
                                        } */
                                    } else if (dn == billingFreqInt && dn != 0) {
                                        /* ARMAN: if (shipEstMap.containsKey(nextDate)) {
                                            Opportunity_Forecast__c oppForecast = new Opportunity_Forecast__c();
                                            oppForecast.Opportunity__c = opp.Id;
                                            oppForecast.Product__c = oli.SBQQ__QuoteLine__r.SBQQ__Product__r.Id;
                                            oppForecast.Quote__c = opp.SBQQ__PrimaryQuote__r.Id;
                                            oppForecast.Quote_Line__c = oli.SBQQ__QuoteLine__r.Id;
                                            oppForecast.Quote_Line_Group__c = oli.SBQQ__QuoteLine__r.SBQQ__Group__r.Id;
                                            oppForecast.Forecast_Date__c = nextDate;
                                            oppForecast.Forecast_Created_Date__c = System.today();
                                            oppForecast.Forecast_Number__c = maxForecastNumber + 1;
                                            forecastPrice = linePctOfGroup * groupAPUP * shipEstMap.get(nextDate).Estimated_Shipping_Quantity__c;
                                            rollingPrice = rollingPrice + forecastPrice;
                                            rollingQuantity = rollingQuantity + (qtyPctOfGroup * shipEstMap.get(nextDate).Estimated_Shipping_Quantity__c);
                                            oppForecast.Forecast_Amount__c = (rollingPrice != null)?rollingPrice*freqMultiplier:rollingPrice;
                                            oppForecast.Forecast_Quantity__c = rollingQuantity;
                                            oppForecastList.add(oppForecast);
                                        } else {
                                            Opportunity_Forecast__c oppForecast = new Opportunity_Forecast__c();
                                            oppForecast.Opportunity__c = opp.Id;
                                            oppForecast.Product__c = oli.SBQQ__QuoteLine__r.SBQQ__Product__r.Id;
                                            oppForecast.Quote__c = opp.SBQQ__PrimaryQuote__r.Id;
                                            oppForecast.Quote_Line__c = oli.SBQQ__QuoteLine__r.Id;
                                            oppForecast.Quote_Line_Group__c = oli.SBQQ__QuoteLine__r.SBQQ__Group__r.Id;
                                            oppForecast.Forecast_Date__c = nextDate;
                                            oppForecast.Forecast_Created_Date__c = System.today();
                                            oppForecast.Forecast_Number__c = maxForecastNumber + 1;
                                            oppForecast.Forecast_Amount__c = (rollingPrice != null)?rollingPrice*freqMultiplier:rollingPrice;
                                            oppForecast.Forecast_Quantity__c = rollingQuantity;
                                            oppForecastList.add(oppForecast);
                                        } */
                                        dn = 1;
                                    } else {
                                        // billing freq of once
                                        /* ARMAN: if (shipEstMap.containsKey(nextDate)) {
                                            Opportunity_Forecast__c oppForecast = new Opportunity_Forecast__c();
                                            oppForecast.Opportunity__c = opp.Id;
                                            oppForecast.Product__c = oli.SBQQ__QuoteLine__r.SBQQ__Product__r.Id;
                                            oppForecast.Quote__c = opp.SBQQ__PrimaryQuote__r.Id;
                                            oppForecast.Quote_Line__c = oli.SBQQ__QuoteLine__r.Id;
                                            oppForecast.Quote_Line_Group__c = oli.SBQQ__QuoteLine__r.SBQQ__Group__r.Id;
                                            oppForecast.Forecast_Date__c = nextDate;
                                            oppForecast.Forecast_Created_Date__c = System.today();
                                            oppForecast.Forecast_Number__c = maxForecastNumber + 1;
                                            oppForecast.Forecast_Amount__c = (oli.TotalPrice != null)?oli.TotalPrice*freqMultiplier:oli.TotalPrice;
                                            oppForecast.Forecast_Quantity__c = oli.Quantity;
                                            oppForecastList.add(oppForecast);
                                            spComplete = true;
                                        } */
                                    }
                                }
                                nextDate = nextDate.addMonths(1).toStartOfMonth();
                            }
                        }
                    } else if (oli.SBQQ__QuoteLine__r.SBQQ__Product__r.Product_Type__c == 'Software'
                            && oli.SBQQ__QuoteLine__r.SBQQ__Product__r.Product_Sub_Type__c != 'Service Plans') {
                        System.debug(LoggingLevel.INFO, 'Group Software Price Total Map: ' + groupSoftwarePriceTotal);
                        System.debug('OpportunityFinancialsHandler aea groupId: ' + groupId + ' groupQtyTotal: ' + groupQtyTotal);
                        if (groupSoftwarePriceTotal.size() > 0) {
                            //Decimal finalUnitPrice = oli.SBQQ__QuoteLine__r.Final_Unit_Price__c;
                            //System.debug(LoggingLevel.INFO,'finalUnitPrice: ' + finalUnitPrice);
                            Decimal totalPrice = 0.00;
                            if (incrementalIncrease) {
                                totalPrice = (oli.SBQQ__QuoteLine__r.SBQQ__ListPrice__c - oli.SBQQ__QuoteLine__r.SBQQ__OriginalPrice__c) * oli.Quantity;
                            } else {
                                if (oli.SBQQ__QuoteLine__r.Final_Unit_Price__c != null && oli.SBQQ__QuoteLine__r.Final_Unit_Price__c != 0) {
                                    totalPrice = oli.SBQQ__QuoteLine__r.Final_Unit_Price__c * oli.Quantity;
                                }
                            }
                            Decimal groupTotalPrice = groupSoftwarePriceTotal.get(groupId);
                            Decimal groupTotalQty = groupQtyTotal.get(groupId);
                            Decimal linePctOfGroup = 1.00;
                            Decimal qtyPctOfGroup = 1.00;
                            Decimal groupAPUP = 0.00;
                            System.debug('totalPrice: ' + totalPrice);
                            System.debug('groupTotalPrice: ' + groupTotalPrice);
                            System.debug('ada groupTotalQty: ' + groupTotalQty);
                            if(groupTotalQty == null) {
                                System.debug('OpportunityFinancialsHandler ada groupId: ' + groupId + ' groupQtyTotal: ' + groupQtyTotal);
                            }
                            System.debug(LoggingLevel.INFO, 'record type: ' + oppRecTypeName + ' incrementalIncrease: ' + incrementalIncrease);

                            if (incrementalIncrease) {
                                groupAPUP = oli.SBQQ__QuoteLine__r.SBQQ__ListPrice__c - oli.SBQQ__QuoteLine__r.SBQQ__OriginalPrice__c;
                            } else {
                                groupAPUP = oli.SBQQ__QuoteLine__r.Final_Unit_Price__c;
                            }

                            if (groupTotalPrice != 0) {
                                linePctOfGroup = (Math.abs(totalPrice) / Math.abs(groupTotalPrice));
                                if(groupTotalQty == null){
                                    qtyPctOfGroup = 1;
                                    groupAPUP = 1;
                                }else{
                                    qtyPctOfGroup = (Math.abs(oli.Quantity) / Math.abs(groupTotalQty));
                                    groupAPUP = (Math.abs(groupTotalPrice) / Math.abs(groupTotalQty));
                                }
                            }

                            System.debug(LoggingLevel.INFO, 'groupAPUP: ' + groupAPUP);
                            System.debug(LoggingLevel.INFO, 'linePctOfGroup: ' + linePctOfGroup);
                            System.debug(LoggingLevel.INFO, 'qtyPctOfGroup: ' + qtyPctOfGroup);
                            Boolean sfComplete = false;
                            Integer dn = 0;
                            if (billingFreqInt > 0) {
                                dn = 1;
                            }
                            Decimal rollingQuantity = 0.0;
                            Decimal rollingPrice = 0.0;
                            Decimal forecastPrice = 0.0;
                            while (nextDate < forecastEndDate) {
                                System.debug('OpportunityFinancialsHandler 4 NextDate: ' + nextDate);
                                System.debug(LoggingLevel.INFO, 'rolling quantity: ' + rollingQuantity);
                                System.debug(LoggingLevel.INFO, 'rolling price: ' + rollingPrice);
                                System.debug(LoggingLevel.INFO, 'forecast price: ' + forecastPrice);
                                if (sfComplete == true) {
                                    break;
                                } else {
                                    if (dn < billingFreqInt) {
                                        dn = dn + 1;
                                        /* ARMAN: if (shipEstMap.containsKey(nextDate)) {
                                            forecastPrice = linePctOfGroup * groupAPUP * shipEstMap.get(nextDate).Estimated_Shipping_Quantity__c;
                                            rollingPrice = rollingPrice + forecastPrice;
                                            rollingQuantity = rollingQuantity + (qtyPctOfGroup * shipEstMap.get(nextDate).Estimated_Shipping_Quantity__c);
                                        } */
                                    } else if (dn == billingFreqInt && dn != 0) {
                                        /* ARMAN: if (shipEstMap.containsKey(nextDate)) {
                                            Opportunity_Forecast__c oppForecast = new Opportunity_Forecast__c();
                                            oppForecast.Opportunity__c = opp.Id;
                                            oppForecast.Product__c = oli.SBQQ__QuoteLine__r.SBQQ__Product__r.Id;
                                            oppForecast.Quote__c = opp.SBQQ__PrimaryQuote__r.Id;
                                            oppForecast.Quote_Line__c = oli.SBQQ__QuoteLine__r.Id;
                                            oppForecast.Quote_Line_Group__c = oli.SBQQ__QuoteLine__r.SBQQ__Group__r.Id;
                                            oppForecast.Forecast_Date__c = nextDate;
                                            oppForecast.Forecast_Created_Date__c = System.today();
                                            oppForecast.Forecast_Number__c = maxForecastNumber + 1;
                                            forecastPrice = linePctOfGroup * groupAPUP * shipEstMap.get(nextDate).Estimated_Shipping_Quantity__c;
                                            rollingPrice = rollingPrice + forecastPrice;
                                            rollingQuantity = rollingQuantity + (qtyPctOfGroup * shipEstMap.get(nextDate).Estimated_Shipping_Quantity__c);
                                            oppForecast.Forecast_Amount__c = (rollingPrice != null)?rollingPrice*freqMultiplier:rollingPrice;
                                            oppForecast.Forecast_Quantity__c = rollingQuantity;
                                            oppForecastList.add(oppForecast);
                                        } else {
                                            Opportunity_Forecast__c oppForecast = new Opportunity_Forecast__c();
                                            oppForecast.Opportunity__c = opp.Id;
                                            oppForecast.Product__c = oli.SBQQ__QuoteLine__r.SBQQ__Product__r.Id;
                                            oppForecast.Quote__c = opp.SBQQ__PrimaryQuote__r.Id;
                                            oppForecast.Quote_Line__c = oli.SBQQ__QuoteLine__r.Id;
                                            oppForecast.Quote_Line_Group__c = oli.SBQQ__QuoteLine__r.SBQQ__Group__r.Id;
                                            oppForecast.Forecast_Date__c = nextDate;
                                            oppForecast.Forecast_Created_Date__c = System.today();
                                            oppForecast.Forecast_Number__c = maxForecastNumber + 1;
                                            oppForecast.Forecast_Amount__c = (rollingPrice != null)?rollingPrice*freqMultiplier:rollingPrice;
                                            oppForecast.Forecast_Quantity__c = rollingQuantity;
                                            oppForecastList.add(oppForecast);
                                        } */
                                        dn = 1;
                                    } else {
                                        // billing freq of once
                                        /* ARMAN: if (shipEstMap.containsKey(nextDate)) {
                                            Opportunity_Forecast__c oppForecast = new Opportunity_Forecast__c();
                                            oppForecast.Opportunity__c = opp.Id;
                                            oppForecast.Product__c = oli.SBQQ__QuoteLine__r.SBQQ__Product__r.Id;
                                            oppForecast.Quote__c = opp.SBQQ__PrimaryQuote__r.Id;
                                            oppForecast.Quote_Line__c = oli.SBQQ__QuoteLine__r.Id;
                                            oppForecast.Quote_Line_Group__c = oli.SBQQ__QuoteLine__r.SBQQ__Group__r.Id;
                                            oppForecast.Forecast_Date__c = nextDate;
                                            oppForecast.Forecast_Created_Date__c = System.today();
                                            oppForecast.Forecast_Number__c = maxForecastNumber + 1;
                                            oppForecast.Forecast_Amount__c = (oli.TotalPrice != null)?oli.TotalPrice*freqMultiplier:oli.TotalPrice;
                                            oppForecast.Forecast_Quantity__c = oli.Quantity;
                                            oppForecastList.add(oppForecast);
                                            sfComplete = true;
                                        } */
                                    }
                                }
                                nextDate = nextDate.addMonths(1).toStartOfMonth();
                            }
                        }
                    }
                }
            }
            /* ARMAN: if (oppForecastList.size() > 0) {
                insert oppForecastList;
            }
            if (oppFCUpdateList.size() > 0) {
                update oppFCUpdateList;
            } */

            calculateOppProductTCV(oppList);
        }

    }

    public static void calculateOppProductTCV(List<Opportunity> oppList) {
        System.debug(LoggingLevel.INFO, 'OpportunityFinancialsHandler.calculateOppProductTCV');
// iterate the opportunity list
        List<OpportunityLineItem> oppItemUpdateList = new List<OpportunityLineItem>();

        // ARMAN: Map<Id, List<Opportunity_Forecast__c>> allOldForecastMap = buildOpportunityForecastMap(oppList);
        Map<Id, List<OpportunityLineItem>> allOppLineItemMap = buildOpportunityLineItemsMap(oppList);
        Map<Id, List<SBQQ__QuoteLine__c>> allQuoteLinesPrimaryMap = buildQuoteLinePrimaryMap(oppList);
        // ARMAN: Map<Id, List<AggregateResult>> allAggregateResultsByIds = buildAggregateResults(oppList);

        for (Opportunity opp : oppList) {
            //List<OpportunityLineItem> oliList = getOppLineItems(opp);
            List<OpportunityLineItem> oliList = allOppLineItemMap.get(opp.Id);
            if(oliList != null) {
                Map<Id, Decimal> qlTCVMap = new Map<Id, Decimal>();
                /* ARMAN: List<AggregateResult> qlForecastSumList = allAggregateResultsByIds.get(opp.Id);
                if(qlForecastSumList != null && qlForecastSumList.size() > 0) {
                    for (AggregateResult qlForecastSum : qlForecastSumList) {
                        System.debug(LoggingLevel.INFO, 'quote line: ' + qlForecastSum.get('Quote_Line__c'));
                        System.debug(LoggingLevel.INFO, 'quote line sum: ' + qlForecastSum.get('fcSum'));
                        Id qlId = (Id) qlForecastSum.get('Quote_Line__c');
                        Decimal fcSum = (Decimal) qlForecastSum.get('fcSum');
                        qlTCVMap.put(qlId, fcSum);
                    }
                }*/

                /* ARMAN: for (OpportunityLineItem oli : oliList) {
                    //Decimal ftcv = qlTCVMap.get(oli.SBQQ__QuoteLine__c);
                    if (qlTCVMap.containsKey(oli.SBQQ__QuoteLine__c) && qlTCVMap.get(oli.SBQQ__QuoteLine__c) != null) {
                        oli.Forecast_TCV__c = qlTCVMap.get(oli.SBQQ__QuoteLine__c);
                    } else {
                        oli.Forecast_TCV__c = oli.Total_Amount__c;
                    }

                    oppItemUpdateList.add(oli);
                }*/
            }
        }
        if (oppItemUpdateList.size() > 0) {
            update oppItemUpdateList;
        }
    }

    private static Map<Id, Decimal> sumGroupTotalPrice(Map<Id, Decimal> groupTotalPrice, OpportunityLineItem oli, Boolean incrementalIncrease) {
        if (groupTotalPrice.containsKey(oli.SBQQ__QuoteLine__r.SBQQ__Group__c)) {
            Decimal currentTotal = groupTotalPrice.get(oli.SBQQ__QuoteLine__r.SBQQ__Group__c);
            if (incrementalIncrease) {
                currentTotal = currentTotal + ((oli.SBQQ__QuoteLine__r.SBQQ__ListPrice__c - oli.SBQQ__QuoteLine__r.SBQQ__OriginalPrice__c) * oli.Quantity);
            } else if(oli.SBQQ__QuoteLine__r.Final_Unit_Price__c != null) {
                currentTotal = currentTotal + (oli.SBQQ__QuoteLine__r.Final_Unit_Price__c * oli.Quantity);
            }
            System.debug(LoggingLevel.INFO, 'current group total: ' + currentTotal);
            groupTotalPrice.put(oli.SBQQ__QuoteLine__r.SBQQ__Group__c, currentTotal);
        } else {
            Decimal newTotal = 0.00;
            if (incrementalIncrease) {
                newTotal = newTotal + ((oli.SBQQ__QuoteLine__r.SBQQ__ListPrice__c - oli.SBQQ__QuoteLine__r.SBQQ__OriginalPrice__c) * oli.Quantity);
            } else if(oli.SBQQ__QuoteLine__r.Final_Unit_Price__c != null) {
                newTotal = newTotal + (oli.SBQQ__QuoteLine__r.Final_Unit_Price__c * oli.Quantity);
            }
            System.debug(LoggingLevel.INFO, 'current group total: ' + newTotal);
            groupTotalPrice.put(oli.SBQQ__QuoteLine__r.SBQQ__Group__c, newTotal);
        }
        return groupTotalPrice;
    }

    /* ARMAN: private static Map<Id, Map<Date, Shipping_Estimate__c>> getShippingEstimateDates(Map<Id, Opportunity> groupIdToOpportunityMap) {
        Map<Id, Map<Date, Shipping_Estimate__c>> groupIdToDateToShippingEstimateMap = new Map<Id, Map<Date, Shipping_Estimate__c>>();
        Map<Id, List<Shipping_Estimate__c>> groupIdShippingEstimateMap = new Map<Id, List<Shipping_Estimate__c>>();
        List<Shipping_Estimate__c> shipEstimateList = new List<Shipping_Estimate__c>();
        List<Shipping_Estimate_Summary__c> shippingSummaryEstimateList = new List<Shipping_Estimate_Summary__c>();
        Map<Id, Shipping_Estimate_Summary__c> groupIdShippingEstimateSummaryMap = new Map<Id, Shipping_Estimate_Summary__c>();
        try{
            shippingSummaryEstimateList = [SELECT Id, Name, Quote_Line_Group__c FROM Shipping_Estimate_Summary__c WHERE Quote_Line_Group__c IN :groupIdToOpportunityMap.keySet()];
            for(Shipping_Estimate_Summary__c summary: shippingSummaryEstimateList) {
                groupIdShippingEstimateSummaryMap.put(summary.Quote_Line_Group__c, summary);
            }
        } catch (Exception eek) {
            System.debug(LoggingLevel.INFO, 'OpportunityFinancialsHandler.getShippingEstimate - no rows were found for the set of keys of summary estimates');
        }

        try {
            shipEstimateList = [
                    select Id, Name, Estimated_Shipping_Date__c, Estimated_Shipping_Quantity__c
                            , Shipping_Summary__c, Shipping_Notes__c, Shipping_Summary__r.Quote_Line_Group__c
                    from Shipping_Estimate__c
                    where Shipping_Summary__r.Quote_Line_Group__c IN :groupIdToOpportunityMap.keySet()
            ];
        } catch (Exception eek) {
            System.debug(LoggingLevel.INFO, 'OpportunityFinancialsHandler.getShippingEstimate - no rows were found for the set of keys for shipping estimates');
        }

        for (Shipping_Estimate__c estimate: shipEstimateList) {
            List<Shipping_Estimate__c> shippingList = new List<Shipping_Estimate__c>();
            if (groupIdShippingEstimateMap.containsKey(estimate.Shipping_Summary__r.Quote_Line_Group__c)) {
                shippingList = groupIdShippingEstimateMap.get(estimate.Shipping_Summary__r.Quote_Line_Group__c);
            } else {
                shippingList = new List<Shipping_Estimate__c>();
            }
            shippingList.add(estimate);
            groupIdShippingEstimateMap.put(estimate.Shipping_Summary__r.Quote_Line_Group__c, shippingList);
        }

        for (Id groupId: groupIdToOpportunityMap.keySet()) {
            Map<Date, Shipping_Estimate__c> shipEstMap = new Map<Date, Shipping_Estimate__c>();
            if (groupIdShippingEstimateMap.containsKey(groupId)) {
                List<Shipping_Estimate__c> shipEstList = groupIdShippingEstimateMap.get(groupId);
                for (Shipping_Estimate__c she : shipEstList) {
                    System.debug('sh est: ' + she);
                    System.debug('sh estimate opp date: ' + groupIdToOpportunityMap.get(groupId).CloseDate);
                    System.debug('sh est date stom: ' + she.Estimated_Shipping_Date__c);
                    if (she.Estimated_Shipping_Date__c == null) {
                        she.Estimated_Shipping_Date__c = groupIdToOpportunityMap.get(groupId).CloseDate;
                    }
                    System.debug('sh est qty: ' + she.Estimated_Shipping_Quantity__c);

                    if (shipEstMap.containsKey(she.Estimated_Shipping_Date__c.toStartOfMonth())) {
                        Double quantity = 0.0;
                        if(she.Estimated_Shipping_Quantity__c != null) {
                            quantity = she.Estimated_Shipping_Quantity__c;
                        }
                        she.Estimated_Shipping_Quantity__c = quantity + shipEstMap.get(she.Estimated_Shipping_Date__c.toStartOfMonth()).Estimated_Shipping_Quantity__c;
                        she.Shipping_Notes__c = she.Shipping_Notes__c + '\n' + shipEstMap.get(she.Estimated_Shipping_Date__c.toStartOfMonth()).Shipping_Notes__c;
                    }
                    shipEstMap.put(she.Estimated_Shipping_Date__c.toStartOfMonth(), she);
                }
                System.debug('sh est map: ' + shipEstMap);
            } else {
                System.debug('OpportunityFinancialsHandler Did not find a suitable shipping estimate for groupId: ' + groupId);
                Shipping_Estimate_Summary__c ssum = new Shipping_Estimate_Summary__c();
                if(groupIdShippingEstimateSummaryMap.containsKey(groupId)){
                    ssum = groupIdShippingEstimateSummaryMap.get(groupId);
                } else {
                    ssum.Quote_Line_Group__c = groupId;
                    //ssum.Quote_Line_Group_Id__c = groupId;
                    insert ssum;
                }

                Shipping_Estimate__c sest = new Shipping_Estimate__c();
                sest.Estimated_Shipping_Date__c = groupIdToOpportunityMap.get(groupId).CloseDate;
                sest.Estimated_Shipping_Quantity__c = 0.00;
                sest.Shipping_Summary__c = ssum.Id;
                sest.Default_Estimate__c = true;
                insert sest;

                shipEstMap.put(groupIdToOpportunityMap.get(groupId).CloseDate.toStartOfMonth(), sest);
            }
            groupIdToDateToShippingEstimateMap.put(groupId, shipEstMap);
        }
        return groupIdToDateToShippingEstimateMap;
    } */

    /* ARMAN: public static void calculateMaxShippingDate(List<Id> seIdList) {
        System.debug(LoggingLevel.INFO, 'QuoteLineGroupHandler.calculateMaxShippingDate');
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

    /* ARMAN: private static Map<Id, List<Opportunity_Forecast__c>> buildOpportunityForecastMap(List<Opportunity> oppList) {
        List<Opportunity_Forecast__c> allOldForecasts = [SELECT Id, Opportunity__c FROM Opportunity_Forecast__c WHERE Opportunity__c IN :oppList];
        Map<Id, List<Opportunity_Forecast__c>> allOldForecastMap = new Map<Id, List<Opportunity_Forecast__c>>();
        for (Opportunity_Forecast__c caf: allOldForecasts) {
            List<Opportunity_Forecast__c> forecastList = new List<Opportunity_Forecast__c>();
            if (allOldForecastMap.containsKey(caf.Opportunity__c)) {
                forecastList = allOldForecastMap.get(caf.Opportunity__c);
            } else {
                forecastList = new List<Opportunity_Forecast__c>();
            }
            forecastList.add(caf);
            allOldForecastMap.put(caf.Opportunity__c, forecastList);
        }
        return allOldForecastMap;
    } */

    /**
     * Map<Id, List<OpportunityLineItem>> allOppLineItemMap = buildOpportunityLineItemsMap(oppList);

     */
    private static Map<Id, List<OpportunityLineItem>> buildOpportunityLineItemsMap(List<Opportunity> oppList) {
        List<OpportunityLineItem> allLineItems = [
                Select Id, OpportunityId, ProductCode, SBQQ__QuoteLine__c, Opportunity.Order_Type__c, Opportunity.RecordType.Name
                        , Total_Amount__c
                        , SBQQ__QuoteLine__r.SBQQ__Group__c
                        , SBQQ__QuoteLine__r.SBQQ__Group__r.Shipping_Estimate_Summary_Exists__c
                        , SBQQ__QuoteLine__r.SBQQ__Group__r.SBQQ__Number__c, TotalPrice, Quantity
                        , SBQQ__QuoteLine__r.SBQQ__Group__r.Id, UnitPrice, ListPrice
                        , SBQQ__QuoteLine__r.SBQQ__Group__r.Group_Hardware_Quantity_Rollup__c
                        , SBQQ__QuoteLine__r.SBQQ__Group__r.Group_Service_Plan_Quantity_Rollup__c
                        , SBQQ__QuoteLine__r.SBQQ__Group__r.Group_Application_Quantity_Rollup__c
                        , SBQQ__QuoteLine__r.SBQQ__Group__r.Group_Software_Quantity_Rollup__c
                        , SBQQ__QuoteLine__r.SBQQ__Product__r.Billing_Frequency_QLE__c
                        , SBQQ__QuoteLine__r.SBQQ__Product__r.Revenue_Recognition_Frequency__c
                        , SBQQ__QuoteLine__r.SBQQ__Product__r.Product_Type__c
                        , SBQQ__QuoteLine__r.SBQQ__Product__r.Product_Sub_Type__c
                        , SBQQ__QuoteLine__r.SBQQ__Product__r.License_Type__c
                        , SBQQ__QuoteLine__r.SBQQ__Product__r.Shipment_Schedule_Required__c
                        , SBQQ__QuoteLine__r.SBQQ__Product__r.Forecast_Offset__c
                        , SBQQ__QuoteLine__r.SBQQ__Product__r.SBQQ__SubscriptionPricing__c
                        , SBQQ__QuoteLine__r.SBQQ__Product__r.SBQQ__SubscriptionType__c
                        , SBQQ__QuoteLine__r.Final_Unit_Price__c
                        , SBQQ__QuoteLine__r.SBQQ__OriginalPrice__c
                        , SBQQ__QuoteLine__r.SBQQ__ListPrice__c
                FROM OpportunityLineItem
                WHERE OpportunityId IN :oppList
                //AND SBQQ__QuoteLine__r.SBQQ__Group__r.Shipping_Estimate_Summary_Exists__c = true
        ];

        Map<Id, List<OpportunityLineItem>> allLineItemMap = new Map<Id, List<OpportunityLineItem>>();
        for (OpportunityLineItem caf: allLineItems) {
            List<OpportunityLineItem> lineItemList = new List<OpportunityLineItem>();
            if (allLineItemMap.containsKey(caf.OpportunityId)) {
                lineItemList = allLineItemMap.get(caf.OpportunityId);
            } else {
                lineItemList = new List<OpportunityLineItem>();
            }
            lineItemList.add(caf);
            allLineItemMap.put(caf.OpportunityId, lineItemList);
        }
        return allLineItemMap;
    }

    /**
     * Map<Id, List<SBQQ__QuoteLine__c>> allQuoteLinesPrimaryMap = buildQuoteLinePrimaryMap(oppList);
     */
    private static Map<Id, List<SBQQ__QuoteLine__c>> buildQuoteLinePrimaryMap(List<Opportunity> oppList) {
        Set<Id> primaryQuoteLineSet = new Set<Id>();
        for (Opportunity opportunity: oppList) {
            primaryQuoteLineSet.add(opportunity.SBQQ__PrimaryQuote__c);
        }

        List<SBQQ__QuoteLine__c> allQuoteLines = [
                SELECT Id, SBQQ__Group__r.SBQQ__Number__c
                        , SBQQ__Quote__c, SBQQ__NetTotal__c
                        , SBQQ__Product__r.Product_Group__c
                FROM SBQQ__QuoteLine__c
                WHERE SBQQ__Quote__c IN :primaryQuoteLineSet
        ];

        Map<Id, List<SBQQ__QuoteLine__c>> allQuoteLinesMap = new Map<Id, List<SBQQ__QuoteLine__c>>();
        for (SBQQ__QuoteLine__c caf: allQuoteLines) {
            List<SBQQ__QuoteLine__c> qlListList = new List<SBQQ__QuoteLine__c>();
            if (allQuoteLinesMap.containsKey(caf.SBQQ__Quote__c)) {
                qlListList = allQuoteLinesMap.get(caf.SBQQ__Quote__c);
            } else {
                qlListList = new List<SBQQ__QuoteLine__c>();
            }
            qlListList.add(caf);
            allQuoteLinesMap.put(caf.SBQQ__Quote__c, qlListList);
        }
        return allQuoteLinesMap;
    }

    /**
     * Build a map Opportunity Id to PrimaryQuote
    */
    private static Map<Id, SBQQ__Quote__c> buildPrimaryQuoteMap(List<Opportunity> oppList) {

        Set<Id> primaryQuoteSet = new Set<Id>();
        for (Opportunity opportunity: oppList) {
            primaryQuoteSet.add(opportunity.SBQQ__PrimaryQuote__c);
        }

        Map<Id, SBQQ__Quote__c> primaryQuoteMap = new Map<Id, SBQQ__Quote__c>();

        List<SBQQ__Quote__c> quoteList = [SELECT Id, Name, SBQQ__StartDate__c, SBQQ__EndDate__c, Master_Term_Remaining__c, SBQQ__Opportunity2__c, SBQQ__Type__c FROM SBQQ__Quote__c WHERE Id IN :primaryQuoteSet];
        for (SBQQ__Quote__c quote: quoteList) {
            primaryQuoteMap.put(quote.SBQQ__Opportunity2__c, quote);
        }
        return primaryQuoteMap;
    }

    /* ARMAN: private static Map<Id, List<AggregateResult>> buildAggregateResults(List<Opportunity> oppList) {
        //List<AggregateResult> qlForecastSumList = [select Quote_Line__c, SUM(Forecast_Amount__c)fcSum from Opportunity_Forecast__c where Quote_Line__c in :qlIdList group by Quote_Line__c];
        Map<Id, List<AggregateResult>> idAggregateResultMap = new Map<Id, List<AggregateResult>>();
        // ARMAN: List<AggregateResult> qlForecastSumList = [SELECT Opportunity__c, Quote_Line__c, SUM(Forecast_Amount__c)fcSum FROM Opportunity_Forecast__c WHERE Opportunity__c IN :oppList GROUP BY Opportunity__c, Quote_Line__c];

        List<AggregateResult> buildList = new List<AggregateResult>();
        for(AggregateResult aggregateResult: qlForecastSumList) {
            Id opportunityId = (Id) aggregateResult.get('Opportunity__c');
            if(idAggregateResultMap.containsKey(opportunityId)) {
                buildList = idAggregateResultMap.get(opportunityId);
            } else {
                buildList = new List<AggregateResult>();
            }
            buildList.add(aggregateResult);
            idAggregateResultMap.put(opportunityId, buildList);
        }
        return idAggregateResultMap;
    }*/

    /* ARMAN:
    private static Integer retrieveMaxForecastNumber(List<Opportunity_Forecast__c> forecastList) {
        Integer maxForecast = 0;
        for (Opportunity_Forecast__c forecast: forecastList) {
            if (forecast.Forecast_Number__c > maxForecast) {
                maxForecast = Integer.valueOf(forecast.Forecast_Number__c);
            }
        }
        return maxForecast;
    }*/
}