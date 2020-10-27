/*********************************************************************************************************
Modified By  : Arman Shah
Modified Date: 10/03/2018
Reason       : To remove references to child CustomerAsset objects, in order to
               prevent "Too Many SOQL queries 101 error"
**********************************************************************************************************/

public with sharing class RevenueForecastHandler {

    /* ARMAN: public static void calculateCustomerAssetFinancials(Id custAssetId) {
        System.debug('RevenueForecastHandler.calculateCustomerAssetFinancials(Id)');
        List<Customer_Asset__c> caList = new List<Customer_Asset__c>();
        caList = [
                select Id, Name, Term_End_Date__c, Term_Start_Date__c, Contract__c, Contract__r.StartDate, Contract__r.EndDate
                        , Steelbrick_Subscription__r.SBQQ__StartDate__c, Steelbrick_Subscription__r.SBQQ__EndDate__c
                        , Steelbrick_Asset__c, Steelbrick_Asset__r.SBQQ__LatestQuoteLine__r.SBQQ__EffectiveStartDate__c
                        , Steelbrick_Asset__r.SBQQ__LatestQuoteLine__r.SBQQ__EffectiveEndDate__c
                        , Product__r.Default_Billing_Frequency__c, Product__r.Forecast_Offset__c
                        , Product__r.SBQQ__SubscriptionPricing__c, Product__r.SBQQ__SubscriptionType__c
                        , Product__r.Product_Type__c, Total_One_Time_Fee_s__c, Quantity__c, Annual_Recurring_Revenue__c
                        , Product__r.Id, Product__c, Product__r.Revenue_Recognition_Frequency__c, Product__r.Shipment_Schedule_Required__c
                        , Product__r.Product_Sub_Type__c, Latest_Opportunity__r.Order_Type__c
                        , Latest_Quote_Line__r.SBQQ__ListPrice__c, Latest_Quote_Line__r.SBQQ__OriginalPrice__c
                , Latest_Quote_Line__r.SBQQ__RenewedSubscription__c
                from Customer_Asset__c
                where Id = :custAssetId
        ];
        calculateCustomerAssetFinancials(caList);
    }*/

    /* ARMAN: public static void calculateCustomerAssetFinancials(List<Id> custAssetIdList) {
        System.debug('RevenueForecastHandler.calculateCuatomerAssetFinancials(List<Id>)');
        List<Customer_Asset__c> caList = new List<Customer_Asset__c>();
        caList = [
                select Id, Name, Term_End_Date__c, Term_Start_Date__c, Contract__c, Contract__r.StartDate, Contract__r.EndDate
                        , Steelbrick_Subscription__r.SBQQ__StartDate__c, Steelbrick_Subscription__r.SBQQ__EndDate__c
                        , Steelbrick_Asset__c, Steelbrick_Asset__r.SBQQ__LatestQuoteLine__r.SBQQ__EffectiveStartDate__c
                        , Steelbrick_Asset__r.SBQQ__LatestQuoteLine__r.SBQQ__EffectiveEndDate__c
                        , Product__r.Default_Billing_Frequency__c, Product__r.Forecast_Offset__c
                        , Product__r.SBQQ__SubscriptionPricing__c, Product__r.SBQQ__SubscriptionType__c
                        , Product__r.Product_Type__c, Total_One_Time_Fee_s__c, Quantity__c, Annual_Recurring_Revenue__c
                        , Product__r.Id, Product__c, Product__r.Revenue_Recognition_Frequency__c, Product__r.Shipment_Schedule_Required__c
                        , Product__r.Product_Sub_Type__c, Latest_Opportunity__r.Order_Type__c
                        , Latest_Quote_Line__r.SBQQ__ListPrice__c, Latest_Quote_Line__r.SBQQ__OriginalPrice__c
                        , Latest_Quote_Line__r.SBQQ__RenewedSubscription__c
                from Customer_Asset__c
                where Id IN :custAssetIdList
        ];
        System.debug('caList: ' + caList);
        calculateCustomerAssetFinancials(caList);
    }*/

    /* ARMAN: public static void calculateCustomerAssetEstimateFinancials(List<Customer_Asset_Shipping_Estimate__c> seList) {
        System.debug('RevenueForecastHandler.calculateCustomerAssetEstimateFinancials(List<Customer_Asset_Shipping_Estimate__c>)');
        seList = [select Id, Customer_Asset_Shipping_Summary__r.Customer_Asset__c from Customer_Asset_Shipping_Estimate__c where Id in :seList];
        List<Id> caIdList = new List<Id>();
        for(Customer_Asset_Shipping_Estimate__c se : seList){
            caIdList.add(se.Customer_Asset_Shipping_Summary__r.Customer_Asset__c);
        }
        List<Customer_Asset__c> caList = new List<Customer_Asset__c>();
        caList = [
                select Id, Name, Term_End_Date__c, Term_Start_Date__c, Contract__c, Contract__r.StartDate, Contract__r.EndDate
                        , Steelbrick_Subscription__r.SBQQ__StartDate__c, Steelbrick_Subscription__r.SBQQ__EndDate__c
                        , Steelbrick_Asset__c, Steelbrick_Asset__r.SBQQ__LatestQuoteLine__r.SBQQ__EffectiveStartDate__c
                        , Steelbrick_Asset__r.SBQQ__LatestQuoteLine__r.SBQQ__EffectiveEndDate__c
                        , Product__r.Default_Billing_Frequency__c, Product__r.Forecast_Offset__c
                        , Product__r.SBQQ__SubscriptionPricing__c, Product__r.SBQQ__SubscriptionType__c
                        , Product__r.Product_Type__c, Total_One_Time_Fee_s__c, Quantity__c, Annual_Recurring_Revenue__c
                        , Product__r.Id, Product__c, Product__r.Revenue_Recognition_Frequency__c, Product__r.Shipment_Schedule_Required__c
                        , Product__r.Product_Sub_Type__c, Latest_Opportunity__r.Order_Type__c
                        , Latest_Quote_Line__r.SBQQ__ListPrice__c, Latest_Quote_Line__r.SBQQ__OriginalPrice__c
                        , Latest_Quote_Line__r.SBQQ__RenewedSubscription__c
                from Customer_Asset__c
                where Id IN :caIdList
        ];
        System.debug('caList: ' + caList);
        calculateCustomerAssetFinancials(caList);
    }*/


    /* ARMAN: public static void calculateCustomerAssetFinancials(List<Customer_Asset__c> custAssetList) {
        System.debug('RevenueForecastHandler.calculateCustomerAssetFinancials(List<Customer_Asset__c>)');
        System.debug('custAssetList:' + custAssetList);
        // iterate the customer asset list
        //List<Customer_Asset_Forecast__c> caForecastList = new List<Customer_Asset_Forecast__c>();
        List<Customer_Asset__c> caFCUpdatetList = new List<Customer_Asset__c>();

        //Map<Id, List<Customer_Asset_Forecast__c>> allOldForecastMap = buildCustomerAssetForecastMap(custAssetList);

        //Map<Id, Map<Date, Customer_Asset_Shipping_Estimate__c>> assetIdDateShippingEstimatesMap = getShippingEstimateDates(custAssetList);
        
        for (Customer_Asset__c customerAsset : custAssetList) {
            System.debug('Current Customer Asset: ' + customerAsset);

            Integer maxForecastNumber = 0;
            Boolean deleteOldForecasts = true;// if set to false it will create new forecast records every time the opp moves to closed won.
            if (deleteOldForecasts) {
                List<Customer_Asset_Forecast__c> oldForecastList = allOldForecastMap.get(customerAsset.Id);
                if (oldForecastList != null) {
                    try {
                        delete oldForecastList;
                        //allOldForecastMap.remove(customerAsset.Id);
                    } catch(Exception eek) {
                        // If the forecasts were deleted already, then we don't care that we can't delete them again.
                        System.debug('RevenueForecastHandler.calculateCustomerAssetFinancials() exception happened while deleting, most likely forecasts were deleted already. ' + eek.getMessage());
                    }
                }
            }
            else {
                maxForecastNumber = retrieveMaxForecastNumber(allOldForecastMap.get(customerAsset.Id));
            }
            customerAsset.Max_Forecast_Number__c = maxForecastNumber + 1;
            caFCUpdatetList.add(customerAsset);

            Date forecastStartDate = null;
            Date forecastEndDate = null;
            if (Test.isRunningTest()) {
                forecastStartDate = System.today().toStartOfMonth();
                forecastEndDate = System.today().addMonths(12).toStartOfMonth();
            } else {
                if (customerAsset.Term_Start_Date__c == null) {
                    forecastStartDate = customerAsset.Contract__r.StartDate.toStartOfMonth();
                } else {
                    forecastStartDate = customerAsset.Term_Start_Date__c.toStartOfMonth();
                }

                if (customerAsset.Term_End_Date__c == null) {
                    forecastEndDate = customerAsset.Contract__r.EndDate.toStartOfMonth();
                } else {
                    forecastEndDate = customerAsset.Term_End_Date__c.toStartOfMonth();
                }
            }

            System.debug('forecastStartDate: ' + forecastStartDate);
            System.debug('forecastEndDate: ' + forecastEndDate);

            Date nextDate = forecastStartDate;
            Integer forecastOffset = 0;
            if (customerAsset.Product__r.Forecast_Offset__c != null
                    && customerAsset.Latest_Opportunity__r.Order_Type__c == 'New') {
                forecastOffset = Integer.valueOf(customerAsset.Product__r.Forecast_Offset__c);
            }
            Integer billingFreqInt = 0;
            if (customerAsset.Product__r.Revenue_Recognition_Frequency__c != null) {
                // values in product are Once, Monthly, Quarterly, Annual
                String billingFrequency = customerAsset.Product__r.Revenue_Recognition_Frequency__c;
                if (billingFrequency == 'Once') {
                    billingFreqInt = 0;
                } else if (billingFrequency == 'Monthly') {
                    billingFreqInt = 1;
                } else if (billingFrequency == 'Quarterly') {
                    billingFreqInt = 3;
                } else if (billingFrequency == 'Annual') {
                    billingFreqInt = 12;
                }
            }
            System.debug('Billing Freq: ' + billingFreqInt);

            Map<Date, Customer_Asset_Shipping_Estimate__c> offsetMap = new Map<Date, Customer_Asset_Shipping_Estimate__c>();
            Map<Date, Customer_Asset_Shipping_Estimate__c> shipEstMap = assetIdDateShippingEstimatesMap.get(customerAsset.Id);

            // Faking a Customer_Asset_Shipping_Estimate__c if there isn't one for the beginning date
            if(!shipEstMap.containsKey(nextDate)) {
                Decimal previouslyShippedQuantity = 0.0;
                //Decimal previouslyShippedPrice = 0.0;
                List<Date> dateList = new List<Date> (shipEstMap.keySet());
                dateList.sort();
                for(Date aDate: dateList) {
                    if(aDate < nextDate) {
                        previouslyShippedQuantity = previouslyShippedQuantity + shipEstMap.get(aDate).Estimated_Shipping_Quantity__c;
                    }
                }
                
                shipEstMap.put(nextDate, new Customer_Asset_Shipping_Estimate__c(Estimated_Shipping_Date__c = nextDate, Estimated_Shipping_Quantity__c=previouslyShippedQuantity));
            }

            if (forecastOffset > 0) {
                for (Date seDate : shipEstMap.keySet()) {
                    Date offsetDate = seDate.addMonths(forecastOffset);
                    offsetMap.put(offsetDate.toStartOfMonth(), shipEstMap.get(seDate));
                }
            }
            if (offsetMap.size() > 0) {
                shipEstMap = offsetMap;
            }
            System.debug('shipEstMap: ' + shipEstMap);

            if (customerAsset.Product__r.Shipment_Schedule_Required__c) {
                if (customerAsset.Quantity__c > 0) {
                    System.debug('in Hardware if and customerAsset is: ' + customerAsset);
                    //Decimal totalPrice = customerAsset.Total_One_Time_Fee_s__c;
                    System.debug('renewed sub: ' + customerAsset.Latest_Quote_Line__r.SBQQ__RenewedSubscription__c);
                    Decimal totalPrice = 0.00;
                    if (customerAsset.Latest_Quote_Line__r.SBQQ__RenewedSubscription__c != null) {
                        //totalPrice = (customerAsset.Latest_Quote_Line__r.SBQQ__ListPrice__c - customerAsset.Latest_Quote_Line__r.SBQQ__OriginalPrice__c);
                        totalPrice = (customerAsset.Latest_Quote_Line__r.SBQQ__ListPrice__c);
                    } else {
                        totalPrice = customerAsset.Total_One_Time_Fee_s__c;
                    }
                    System.debug('Total Price: ' + totalPrice);
                    Decimal totalQty = customerAsset.Quantity__c;
                    Boolean readyToOutput = false;
                    Integer dn = 0;
                    if (billingFreqInt > 0) {
                        dn = 1;
                    }
                    Decimal rollingQuantity = 0.0;
                    Decimal rollingPrice = 0.0;
                    Decimal forecastPrice = 0.0;
                    while (nextDate < forecastEndDate) {
                        System.debug('Next Date: ' + nextDate);
                        if (dn < billingFreqInt) {
                            dn = dn + 1;
                            if (shipEstMap.containsKey(nextDate)) {
                                forecastPrice = shipEstMap.get(nextDate).Estimated_Shipping_Quantity__c * totalPrice;
                                rollingPrice = forecastPrice;
                                rollingQuantity = shipEstMap.get(nextDate).Estimated_Shipping_Quantity__c;
                            }
                        } else if (dn == billingFreqInt && dn != 0) {
                            if (shipEstMap.containsKey(nextDate)) {
                                Customer_Asset_Forecast__c caForecast = new Customer_Asset_Forecast__c();
                                caForecast.Customer_Asset__c = customerAsset.Id;
                                caForecast.Product__c = customerAsset.Product__r.Id;
                                caForecast.Forecast_Date__c = nextDate;
                                caForecast.Forecast_Created_Date__c = System.today();
                                caForecast.Forecast_Number__c = maxForecastNumber + 1;
                                forecastPrice = shipEstMap.get(nextDate).Estimated_Shipping_Quantity__c * totalPrice;
                                rollingPrice = forecastPrice;
                                rollingQuantity = shipEstMap.get(nextDate).Estimated_Shipping_Quantity__c;
                                caForecast.Forecast_Amount__c = rollingPrice;
                                caForecast.Forecast_Quantity__c = rollingQuantity;
                                caForecastList.add(caForecast);
                            } else {
                                Customer_Asset_Forecast__c caForecast = new Customer_Asset_Forecast__c();
                                caForecast.Customer_Asset__c = customerAsset.Id;
                                caForecast.Product__c = customerAsset.Product__r.Id;
                                caForecast.Forecast_Date__c = nextDate;
                                caForecast.Forecast_Created_Date__c = System.today();
                                caForecast.Forecast_Number__c = maxForecastNumber + 1;
                                caForecast.Forecast_Amount__c = rollingPrice;
                                caForecast.Forecast_Quantity__c = rollingQuantity;
                                caForecastList.add(caForecast);
                            }
                            dn = 1;
                        } else {
                            // billing freq of once
                            if (shipEstMap.containsKey(nextDate)) {
                                Customer_Asset_Forecast__c caForecast = new Customer_Asset_Forecast__c();
                                caForecast.Customer_Asset__c = customerAsset.Id;
                                caForecast.Product__c = customerAsset.Product__r.Id;
                                caForecast.Forecast_Date__c = nextDate;
                                caForecast.Forecast_Created_Date__c = System.today();
                                caForecast.Forecast_Number__c = maxForecastNumber + 1;
                                caForecast.Forecast_Amount__c = shipEstMap.get(nextDate).Estimated_Shipping_Quantity__c * totalPrice;
                                caForecast.Forecast_Quantity__c = shipEstMap.get(nextDate).Estimated_Shipping_Quantity__c;
                                caForecastList.add(caForecast);
                            }
                        }
                        nextDate = nextDate.addMonths(1).toStartOfMonth();
                    }
                }
            } else if (customerAsset.Product__r.Product_Type__c == 'Software'
                    && customerAsset.Product__r.Product_Sub_Type__c == 'Service Plans') {
                if (customerAsset.Quantity__c > 0) {
                    System.debug('RevenueForecastHandler renewed sub: ' + customerAsset.Latest_Quote_Line__r.SBQQ__RenewedSubscription__c);
                    Decimal totalPrice = 0.00;
                    if (customerAsset.Latest_Quote_Line__r.SBQQ__RenewedSubscription__c != null) {
                        //totalPrice = (customerAsset.Latest_Quote_Line__r.SBQQ__ListPrice__c - customerAsset.Latest_Quote_Line__r.SBQQ__OriginalPrice__c);
                        totalPrice = (customerAsset.Latest_Quote_Line__r.SBQQ__ListPrice__c);
                    } else {
                        totalPrice = customerAsset.Total_One_Time_Fee_s__c;
                    }
                    System.debug('RevenueForecastHandler Total Price: ' + totalPrice);
                    Decimal totalQty = customerAsset.Quantity__c;
                    Boolean spComplete = false;
                    Integer dn = 0;
                    if (billingFreqInt > 0) {
                        dn = 1;
                    }
                    Decimal rollingQuantity = 0.0;
                    Decimal rollingPrice = 0.0;
                    Decimal forecastPrice = 0.0;
                    System.debug('RevenueForecastHandler outside loop nextDate: ' + nextDate + ' endDate: ' + forecastEndDate);
                    while (nextDate < forecastEndDate) {
                        System.debug('RevenueForecastHandler insideloop nextDate: ' + nextDate + ' endDate: ' + forecastEndDate + 'dn: ' + dn + ' billingFreqInt: ' + billingFreqInt);
                        if (spComplete == true) {
                            break;
                        } else {
                            if (dn < billingFreqInt) {
                                dn = dn + 1;
                                if (shipEstMap.containsKey(nextDate)) {
                                    forecastPrice = shipEstMap.get(nextDate).Estimated_Shipping_Quantity__c * totalPrice;
                                    rollingPrice = rollingPrice + forecastPrice;
                                    rollingQuantity = rollingQuantity + shipEstMap.get(nextDate).Estimated_Shipping_Quantity__c;
                                }
                            } else if (dn == billingFreqInt && dn != 0) {
                                if (shipEstMap.containsKey(nextDate)) {
                                    Customer_Asset_Forecast__c caForecast = new Customer_Asset_Forecast__c();
                                    caForecast.Customer_Asset__c = customerAsset.Id;
                                    caForecast.Product__c = customerAsset.Product__r.Id;
                                    caForecast.Forecast_Date__c = nextDate;
                                    caForecast.Forecast_Created_Date__c = System.today();
                                    caForecast.Forecast_Number__c = maxForecastNumber + 1;
                                    forecastPrice = shipEstMap.get(nextDate).Estimated_Shipping_Quantity__c * totalPrice;
                                    rollingPrice = rollingPrice + forecastPrice;
                                    rollingQuantity = rollingQuantity + shipEstMap.get(nextDate).Estimated_Shipping_Quantity__c;
                                    caForecast.Forecast_Amount__c = rollingPrice;
                                    caForecast.Forecast_Quantity__c = rollingQuantity;
                                    caForecastList.add(caForecast);
                                } else {
                                    Customer_Asset_Forecast__c caForecast = new Customer_Asset_Forecast__c();
                                    caForecast.Customer_Asset__c = customerAsset.Id;
                                    caForecast.Product__c = customerAsset.Product__r.Id;
                                    caForecast.Forecast_Date__c = nextDate;
                                    caForecast.Forecast_Created_Date__c = System.today();
                                    caForecast.Forecast_Number__c = maxForecastNumber + 1;
                                    caForecast.Forecast_Amount__c = rollingPrice;
                                    caForecast.Forecast_Quantity__c = rollingQuantity;
                                    caForecastList.add(caForecast);
                                }
                                dn = 1;
                            } else {
                                // billing freq of once
                                if (shipEstMap.containsKey(nextDate)) {
                                    Customer_Asset_Forecast__c caForecast = new Customer_Asset_Forecast__c();
                                    caForecast.Customer_Asset__c = customerAsset.Id;
                                    caForecast.Product__c = customerAsset.Product__r.Id;
                                    caForecast.Forecast_Date__c = nextDate;
                                    caForecast.Forecast_Created_Date__c = System.today();
                                    caForecast.Forecast_Number__c = maxForecastNumber + 1;
                                    caForecast.Forecast_Amount__c = totalPrice;
                                    caForecast.Forecast_Quantity__c = totalQty;
                                    caForecastList.add(caForecast);
                                    spComplete = true;
                                }
                            }
                        }
                        nextDate = nextDate.addMonths(1).toStartOfMonth();
                    }
                }
            } else if (customerAsset.Product__r.Product_Type__c == 'Software'
                    && customerAsset.Product__r.Product_Sub_Type__c == 'Applications') {
                if (customerAsset.Quantity__c > 0) {
                    System.debug('renewed sub: ' + customerAsset.Latest_Quote_Line__r.SBQQ__RenewedSubscription__c);
                    Decimal totalPrice = 0.00;
                    if (customerAsset.Latest_Quote_Line__r.SBQQ__RenewedSubscription__c != null) {
                        //totalPrice = (customerAsset.Latest_Quote_Line__r.SBQQ__ListPrice__c - customerAsset.Latest_Quote_Line__r.SBQQ__OriginalPrice__c);
                        totalPrice = (customerAsset.Latest_Quote_Line__r.SBQQ__ListPrice__c);
                    } else {
                        totalPrice = customerAsset.Total_One_Time_Fee_s__c;
                    }
                    System.debug('Total Price: ' + totalPrice);
                    Decimal totalQty = customerAsset.Quantity__c;
                    Boolean apComplete = false;
                    Integer dn = 0;
                    if (billingFreqInt > 0) {
                        dn = 1;
                    }
                    Decimal rollingQuantity = 0.0;
                    Decimal rollingPrice = 0.0;
                    Decimal forecastPrice = 0.0;
                    while (nextDate < forecastEndDate) {
                        if (apComplete == true) {
                            break;
                        } else {
                            if (dn < billingFreqInt) {
                                dn = dn + 1;
                                if (shipEstMap.containsKey(nextDate)) {
                                    forecastPrice = shipEstMap.get(nextDate).Estimated_Shipping_Quantity__c * totalPrice;
                                    rollingPrice = rollingPrice + forecastPrice;
                                    rollingQuantity = rollingQuantity + shipEstMap.get(nextDate).Estimated_Shipping_Quantity__c;
                                }
                            } else if (dn == billingFreqInt && dn != 0) {
                                if (shipEstMap.containsKey(nextDate)) {
                                    Customer_Asset_Forecast__c caForecast = new Customer_Asset_Forecast__c();
                                    caForecast.Customer_Asset__c = customerAsset.Id;
                                    caForecast.Product__c = customerAsset.Product__r.Id;
                                    caForecast.Forecast_Date__c = nextDate;
                                    caForecast.Forecast_Created_Date__c = System.today();
                                    caForecast.Forecast_Number__c = maxForecastNumber + 1;
                                    forecastPrice = shipEstMap.get(nextDate).Estimated_Shipping_Quantity__c * totalPrice;
                                    rollingPrice = rollingPrice + forecastPrice;
                                    rollingQuantity = rollingQuantity + shipEstMap.get(nextDate).Estimated_Shipping_Quantity__c;
                                    caForecast.Forecast_Amount__c = rollingPrice;
                                    caForecast.Forecast_Quantity__c = rollingQuantity;
                                    caForecastList.add(caForecast);
                                } else {
                                    Customer_Asset_Forecast__c caForecast = new Customer_Asset_Forecast__c();
                                    caForecast.Customer_Asset__c = customerAsset.Id;
                                    caForecast.Product__c = customerAsset.Product__r.Id;
                                    caForecast.Forecast_Date__c = nextDate;
                                    caForecast.Forecast_Created_Date__c = System.today();
                                    caForecast.Forecast_Number__c = maxForecastNumber + 1;
                                    caForecast.Forecast_Amount__c = rollingPrice;
                                    caForecast.Forecast_Quantity__c = rollingQuantity;
                                    caForecastList.add(caForecast);
                                }
                                dn = 1;
                            } else {
                                // billing freq of once
                                if (shipEstMap.containsKey(nextDate)) {
                                    Customer_Asset_Forecast__c caForecast = new Customer_Asset_Forecast__c();
                                    caForecast.Customer_Asset__c = customerAsset.Id;
                                    caForecast.Product__c = customerAsset.Product__r.Id;
                                    caForecast.Forecast_Date__c = nextDate;
                                    caForecast.Forecast_Created_Date__c = System.today();
                                    caForecast.Forecast_Number__c = maxForecastNumber + 1;
                                    caForecast.Forecast_Amount__c = totalPrice;
                                    caForecast.Forecast_Quantity__c = totalQty;
                                    caForecastList.add(caForecast);
                                    apComplete = true;
                                }
                            }
                        }
                        nextDate = nextDate.addMonths(1).toStartOfMonth();
                    }
                }
            } else if (customerAsset.Product__r.Product_Type__c == 'Software'
                    && customerAsset.Product__r.Product_Sub_Type__c != 'Service Plans') {
                if (customerAsset.Quantity__c > 0) {
                    System.debug('***3renewed sub: ' + customerAsset.Latest_Quote_Line__r.SBQQ__RenewedSubscription__c);
                    Decimal totalPrice = 0.00;
                    if (customerAsset.Latest_Quote_Line__r.SBQQ__RenewedSubscription__c != null) {
                        //totalPrice = (customerAsset.Latest_Quote_Line__r.SBQQ__ListPrice__c - customerAsset.Latest_Quote_Line__r.SBQQ__OriginalPrice__c);
                        totalPrice = (customerAsset.Latest_Quote_Line__r.SBQQ__ListPrice__c);
                    } else {
                        totalPrice = customerAsset.Total_One_Time_Fee_s__c;
                    }
                    System.debug('Totat Price: ' + totalPrice);
                    Decimal totalQty = customerAsset.Quantity__c;
                    Boolean swComplete = false;
                    Integer dn = 0;
                    if (billingFreqInt > 0) {
                        dn = 1;
                    }
                    Decimal rollingQuantity = 0.0;
                    Decimal rollingPrice = 0.0;
                    Decimal forecastPrice = 0.0;
                    while (nextDate < forecastEndDate) {
                        if (swComplete == true) {
                            break;
                        } else {
                            if (dn < billingFreqInt) {
                                dn = dn + 1;
                                if (shipEstMap.containsKey(nextDate)) {
                                    forecastPrice = shipEstMap.get(nextDate).Estimated_Shipping_Quantity__c * totalPrice;
                                    rollingPrice = rollingPrice + forecastPrice;
                                    rollingQuantity = rollingQuantity + shipEstMap.get(nextDate).Estimated_Shipping_Quantity__c;
                                }
                            } else if (dn == billingFreqInt && dn != 0) {
                                if (shipEstMap.containsKey(nextDate)) {
                                    Customer_Asset_Forecast__c caForecast = new Customer_Asset_Forecast__c();
                                    caForecast.Customer_Asset__c = customerAsset.Id;
                                    caForecast.Product__c = customerAsset.Product__r.Id;
                                    caForecast.Forecast_Date__c = nextDate;
                                    caForecast.Forecast_Created_Date__c = System.today();
                                    caForecast.Forecast_Number__c = maxForecastNumber + 1;
                                    forecastPrice = shipEstMap.get(nextDate).Estimated_Shipping_Quantity__c * totalPrice;
                                    rollingPrice = rollingPrice + forecastPrice;
                                    rollingQuantity = rollingQuantity + shipEstMap.get(nextDate).Estimated_Shipping_Quantity__c;
                                    caForecast.Forecast_Amount__c = rollingPrice;
                                    caForecast.Forecast_Quantity__c = rollingQuantity;
                                    caForecastList.add(caForecast);
                                } else {
                                    Customer_Asset_Forecast__c caForecast = new Customer_Asset_Forecast__c();
                                    caForecast.Customer_Asset__c = customerAsset.Id;
                                    caForecast.Product__c = customerAsset.Product__r.Id;
                                    caForecast.Forecast_Date__c = nextDate;
                                    caForecast.Forecast_Created_Date__c = System.today();
                                    caForecast.Forecast_Number__c = maxForecastNumber + 1;
                                    caForecast.Forecast_Amount__c = rollingPrice;
                                    caForecast.Forecast_Quantity__c = rollingQuantity;
                                    caForecastList.add(caForecast);
                                }
                                dn = 1;
                            } else {
                                // billing freq of once
                                if (shipEstMap.containsKey(nextDate)) {
                                    Customer_Asset_Forecast__c caForecast = new Customer_Asset_Forecast__c();
                                    caForecast.Customer_Asset__c = customerAsset.Id;
                                    caForecast.Product__c = customerAsset.Product__r.Id;
                                    caForecast.Forecast_Date__c = nextDate;
                                    caForecast.Forecast_Created_Date__c = System.today();
                                    caForecast.Forecast_Number__c = maxForecastNumber + 1;
                                    caForecast.Forecast_Amount__c = totalPrice;
                                    caForecast.Forecast_Quantity__c = totalQty;
                                    caForecastList.add(caForecast);
                                    swComplete = true;
                                }
                            }
                        }
                        nextDate = nextDate.addMonths(1).toStartOfMonth();
                    }
                }
            }

        }
        //System.debug('customerAsset forecast list: ' + caForecastList);
        /*CustomerAssetHandler.bypassTrigger = true;
        if (caForecastList.size() > 0) {
            insert caForecastList;
        }
        if (caFCUpdatetList.size() > 0) {
            update caFCUpdatetList;
        }
        CustomerAssetHandler.bypassTrigger = false;
    }*/

    /* ARMAN: public static void calculateCustomerAssetShippedFinancials(List<Id> shipActualIdList) {
        System.debug('RevenueForecastHandler.calculateCuatomerAssetShippedFinancials(List<Id>)');
        System.debug('ship actual id list: ' + shipActualIdList);
        List<Id> custAssetIdList = new List<Id>();
         List<Customer_Asset_Shipping_Actual__c> saList = [
                select Id, Customer_Asset_Shipping_Summary__c, Customer_Asset_Shipping_Summary__r.Customer_Asset__c
                from Customer_Asset_Shipping_Actual__c
                where Id in :shipActualIdList
        ];
        for (Customer_Asset_Shipping_Actual__c casa : saList) {
            custAssetIdList.add(casa.Customer_Asset_Shipping_Summary__r.Customer_Asset__c);
        }

        List<Customer_Asset__c> caList = new List<Customer_Asset__c>();
        caList = [
                select Id, Name, Term_End_Date__c, Term_Start_Date__c, Contract__c, Contract__r.StartDate, Contract__r.EndDate
                        , Steelbrick_Subscription__r.SBQQ__StartDate__c, Steelbrick_Subscription__r.SBQQ__EndDate__c
                        , Steelbrick_Asset__c, Steelbrick_Asset__r.SBQQ__LatestQuoteLine__r.SBQQ__EffectiveStartDate__c
                        , Steelbrick_Asset__r.SBQQ__LatestQuoteLine__r.SBQQ__EffectiveEndDate__c
                        , Product__r.Default_Billing_Frequency__c, Product__r.Forecast_Offset__c
                        , Product__r.SBQQ__SubscriptionPricing__c, Product__r.SBQQ__SubscriptionType__c
                        , Product__r.Product_Type__c, Total_One_Time_Fee_s__c, Quantity__c, Annual_Recurring_Revenue__c
                        , Product__r.Id, Product__c, Product__r.Revenue_Recognition_Frequency__c, Product__r.Shipment_Schedule_Required__c
                        , Product__r.Product_Sub_Type__c
                from Customer_Asset__c
                where Id = :custAssetIdList
        ];
        System.debug('customerAsset list: ' + caList);
        calculateCustomerAssetShippedFinancials(caList);
    }*/

    /* ARMAN: public static void calculateCustomerAssetShippedFinancials(List<Customer_Asset__c> custAssetList) {
        System.debug('RevenueForecastHandler.calculateCustomerAssetShippedFinancials(List<Customer_Asset__c>)');
        // iterate the customer asset list
        List<Customer_Asset_Shipping_Forecast__c> casForecastList = new List<Customer_Asset_Shipping_Forecast__c>();
        List<Customer_Asset__c> casFCUpdatetList = new List<Customer_Asset__c>();

        Map<Id, List<Customer_Asset_Shipping_Forecast__c>> allOldForecastMap = buildCustomerAssetShippingForecastMap(custAssetList);
        Map<Id, Map<Date, Customer_Asset_Shipping_Actual__c>> customerAssetIdToDateActualsMap = getShippingActualDates(custAssetList);
        for (Customer_Asset__c customerAsset : custAssetList) {
            System.debug('Current Customer Asset: ' + customerAsset);

            Integer maxForecastNumber = 0;
            Boolean deleteOldForecasts = true;// if set to false it will create new forecast records every time the opp moves to closed won.
            if (deleteOldForecasts) {
                List<Customer_Asset_Shipping_Forecast__c> oldForecastList = allOldForecastMap.get(customerAsset.Id);
                if (oldForecastList != null) {
                    delete oldForecastList;
                }
            } else {
                maxForecastNumber = retrieveMaxForecastNumber(allOldForecastMap.get(customerAsset.Id));
            }
            customerAsset.Max_Forecast_Number__c = maxForecastNumber + 1;
            casFCUpdatetList.add(customerAsset);

            Date forecastStartDate = null;
            Date forecastEndDate = null;
            if (Test.isRunningTest()) {
                forecastStartDate = System.today().toStartOfMonth();
                forecastEndDate = System.today().addMonths(12).toStartOfMonth();
            } else {
                if (customerAsset.Term_Start_Date__c == null) {
                    forecastStartDate = customerAsset.Contract__r.StartDate;
                } else {
                    forecastStartDate = customerAsset.Term_Start_Date__c.toStartOfMonth();
                }

                if (customerAsset.Term_End_Date__c == null) {
                    forecastEndDate = customerAsset.Contract__r.EndDate;
                } else {
                    forecastEndDate = customerAsset.Term_End_Date__c.toStartOfMonth();
                }
            }

            System.debug('forecastStartDate: ' + forecastStartDate);
            System.debug('forecastEndDate: ' + forecastEndDate);

            Date nextDate = forecastStartDate;
            Integer forecastOffset = 0;
            if (customerAsset.Product__r.Forecast_Offset__c != null
                    && customerAsset.Latest_Opportunity__r.Order_Type__c == 'New') {
                forecastOffset = Integer.valueOf(customerAsset.Product__r.Forecast_Offset__c);
            }
            Integer billingFreqInt = 0;
            if (customerAsset.Product__r.Revenue_Recognition_Frequency__c != null) {
                // values in product are Once, Monthly, Quarterly, Annual
                String billingFrequency = customerAsset.Product__r.Revenue_Recognition_Frequency__c;
                if (billingFrequency == 'Once') {
                    billingFreqInt = 0;
                } else if (billingFrequency == 'Monthly') {
                    billingFreqInt = 1;
                } else if (billingFrequency == 'Quarterly') {
                    billingFreqInt = 3;
                } else if (billingFrequency == 'Annual') {
                    billingFreqInt = 12;
                }
            }
            System.debug('Billing Freq: ' + billingFreqInt);

            Map<Date, Customer_Asset_Shipping_Actual__c> offsetMap = new Map<Date, Customer_Asset_Shipping_Actual__c>();
            //Map<Date, Customer_Asset_Shipping_Actual__c> shipActMap = getShippingActualDates(customerAsset);
            Map<Date, Customer_Asset_Shipping_Actual__c> shipActMap = customerAssetIdToDateActualsMap.get(customerAsset.Id);
            if (forecastOffset > 0) {
                for (Date saDate : shipActMap.keySet()) {
                    Date offsetDate = saDate.addMonths(forecastOffset);
                    offsetMap.put(offsetDate.toStartOfMonth(), shipActMap.get(saDate));
                }
            }
            if (offsetMap.size() > 0) {
                shipActMap = offsetMap;
            }
            System.debug('shipActMap: ' + shipActMap);

            if (customerAsset.Product__r.Shipment_Schedule_Required__c) {
                if (customerAsset.Quantity__c > 0) {
                    System.debug('in Hardware if and customerAsset is: ' + customerAsset);
                    Decimal totalPrice = customerAsset.Total_One_Time_Fee_s__c;
                    Decimal totalQty = customerAsset.Quantity__c;
                    Boolean readyToOutput = false;
                    Integer dn = 0;
                    if (billingFreqInt > 0) {
                        dn = 1;
                    }
                    Decimal rollingQuantity = 0.0;
                    Decimal rollingPrice = 0.0;
                    Decimal forecastPrice = 0.0;
                    while (nextDate < forecastEndDate) {
                        System.debug('Next Date: ' + nextDate);
                        if (dn < billingFreqInt) {
                            dn = dn + 1;
                            if (shipActMap.containsKey(nextDate)) {
                                forecastPrice = shipActMap.get(nextDate).Actual_Shipped_Quantity__c * totalPrice;
                                rollingPrice = forecastPrice;
                                rollingQuantity = shipActMap.get(nextDate).Actual_Shipped_Quantity__c;
                            }
                        } else if (dn == billingFreqInt && dn != 0) {
                            if (shipActMap.containsKey(nextDate)) {
                                Customer_Asset_Shipping_Forecast__c casForecast = new Customer_Asset_Shipping_Forecast__c();
                                casForecast.Customer_Asset__c = customerAsset.Id;
                                casForecast.Product__c = customerAsset.Product__r.Id;
                                casForecast.Forecast_Date__c = nextDate;
                                casForecast.Forecast_Created_Date__c = System.today();
                                casForecast.Forecast_Number__c = maxForecastNumber + 1;
                                forecastPrice = shipActMap.get(nextDate).Actual_Shipped_Quantity__c * totalPrice;
                                rollingPrice = forecastPrice;
                                rollingQuantity = shipActMap.get(nextDate).Actual_Shipped_Quantity__c;
                                casForecast.Forecast_Amount__c = rollingPrice;
                                casForecast.Forecast_Quantity__c = rollingQuantity;
                                casForecastList.add(casForecast);
                            } else {
                                Customer_Asset_Shipping_Forecast__c casForecast = new Customer_Asset_Shipping_Forecast__c();
                                casForecast.Customer_Asset__c = customerAsset.Id;
                                casForecast.Product__c = customerAsset.Product__r.Id;
                                casForecast.Forecast_Date__c = nextDate;
                                casForecast.Forecast_Created_Date__c = System.today();
                                casForecast.Forecast_Number__c = maxForecastNumber + 1;
                                casForecast.Forecast_Amount__c = rollingPrice;
                                casForecast.Forecast_Quantity__c = rollingQuantity;
                                casForecastList.add(casForecast);
                            }
                            dn = 1;
                        } else {
                            // billing freq of once
                            if (shipActMap.containsKey(nextDate)) {
                                Customer_Asset_Shipping_Forecast__c casForecast = new Customer_Asset_Shipping_Forecast__c();
                                casForecast.Customer_Asset__c = customerAsset.Id;
                                casForecast.Product__c = customerAsset.Product__r.Id;
                                casForecast.Forecast_Date__c = nextDate;
                                casForecast.Forecast_Created_Date__c = System.today();
                                casForecast.Forecast_Number__c = maxForecastNumber + 1;
                                casForecast.Forecast_Amount__c = shipActMap.get(nextDate).Actual_Shipped_Quantity__c * totalPrice;
                                casForecast.Forecast_Quantity__c = shipActMap.get(nextDate).Actual_Shipped_Quantity__c;
                                casForecastList.add(casForecast);
                            }
                        }
                        nextDate = nextDate.addMonths(1).toStartOfMonth();
                    }
                }
            } else if (customerAsset.Product__r.Product_Type__c == 'Software'
                    && customerAsset.Product__r.Product_Sub_Type__c == 'Service Plans') {
                if (customerAsset.Quantity__c > 0) {
                    Decimal totalPrice = customerAsset.Total_One_Time_Fee_s__c;
                    Decimal totalQty = customerAsset.Quantity__c;
                    Boolean spComplete = false;
                    Integer dn = 0;
                    if (billingFreqInt > 0) {
                        dn = 1;
                    }
                    Decimal rollingQuantity = 0.0;
                    Decimal rollingPrice = 0.0;
                    Decimal forecastPrice = 0.0;
                    while (nextDate < forecastEndDate) {
                        if (spComplete == true) {
                            break;
                        } else {
                            if (dn < billingFreqInt) {
                                dn = dn + 1;
                                if (shipActMap.containsKey(nextDate)) {
                                    forecastPrice = shipActMap.get(nextDate).Actual_Shipped_Quantity__c * totalPrice;
                                    rollingPrice = rollingPrice + forecastPrice;
                                    rollingQuantity = rollingQuantity + shipActMap.get(nextDate).Actual_Shipped_Quantity__c;
                                }
                            } else if (dn == billingFreqInt && dn != 0) {
                                if (shipActMap.containsKey(nextDate)) {
                                    Customer_Asset_Shipping_Forecast__c casForecast = new Customer_Asset_Shipping_Forecast__c();
                                    casForecast.Customer_Asset__c = customerAsset.Id;
                                    casForecast.Product__c = customerAsset.Product__r.Id;
                                    casForecast.Forecast_Date__c = nextDate;
                                    casForecast.Forecast_Created_Date__c = System.today();
                                    casForecast.Forecast_Number__c = maxForecastNumber + 1;
                                    forecastPrice = shipActMap.get(nextDate).Actual_Shipped_Quantity__c * totalPrice;
                                    rollingPrice = rollingPrice + forecastPrice;
                                    rollingQuantity = rollingQuantity + shipActMap.get(nextDate).Actual_Shipped_Quantity__c;
                                    casForecast.Forecast_Amount__c = rollingPrice;
                                    casForecast.Forecast_Quantity__c = rollingQuantity;
                                    casForecastList.add(casForecast);
                                } else {
                                    Customer_Asset_Shipping_Forecast__c casForecast = new Customer_Asset_Shipping_Forecast__c();
                                    casForecast.Customer_Asset__c = customerAsset.Id;
                                    casForecast.Product__c = customerAsset.Product__r.Id;
                                    casForecast.Forecast_Date__c = nextDate;
                                    casForecast.Forecast_Created_Date__c = System.today();
                                    casForecast.Forecast_Number__c = maxForecastNumber + 1;
                                    casForecast.Forecast_Amount__c = rollingPrice;
                                    casForecast.Forecast_Quantity__c = rollingQuantity;
                                    casForecastList.add(casForecast);
                                }
                                dn = 1;
                            } else {
                                // billing freq of once
                                if (shipActMap.containsKey(nextDate)) {
                                    Customer_Asset_Shipping_Forecast__c casForecast = new Customer_Asset_Shipping_Forecast__c();
                                    casForecast.Customer_Asset__c = customerAsset.Id;
                                    casForecast.Product__c = customerAsset.Product__r.Id;
                                    casForecast.Forecast_Date__c = nextDate;
                                    casForecast.Forecast_Created_Date__c = System.today();
                                    casForecast.Forecast_Number__c = maxForecastNumber + 1;
                                    casForecast.Forecast_Amount__c = totalPrice;
                                    casForecast.Forecast_Quantity__c = totalQty;
                                    casForecastList.add(casForecast);
                                    spComplete = true;
                                }
                            }
                        }
                        nextDate = nextDate.addMonths(1).toStartOfMonth();
                    }
                }
            } else if (customerAsset.Product__r.Product_Type__c == 'Software'
                    && customerAsset.Product__r.Product_Sub_Type__c == 'Applications') {
                if (customerAsset.Quantity__c > 0) {
                    Decimal totalPrice = customerAsset.Total_One_Time_Fee_s__c;
                    Decimal totalQty = customerAsset.Quantity__c;
                    Boolean apComplete = false;
                    Integer dn = 0;
                    if (billingFreqInt > 0) {
                        dn = 1;
                    }
                    Decimal rollingQuantity = 0.0;
                    Decimal rollingPrice = 0.0;
                    Decimal forecastPrice = 0.0;
                    while (nextDate < forecastEndDate) {
                        if (apComplete == true) {
                            break;
                        } else {
                            if (dn < billingFreqInt) {
                                dn = dn + 1;
                                if (shipActMap.containsKey(nextDate)) {
                                    forecastPrice = shipActMap.get(nextDate).Actual_Shipped_Quantity__c * totalPrice;
                                    rollingPrice = rollingPrice + forecastPrice;
                                    rollingQuantity = rollingQuantity + shipActMap.get(nextDate).Actual_Shipped_Quantity__c;
                                }
                            } else if (dn == billingFreqInt && dn != 0) {
                                if (shipActMap.containsKey(nextDate)) {
                                    Customer_Asset_Shipping_Forecast__c casForecast = new Customer_Asset_Shipping_Forecast__c();
                                    casForecast.Customer_Asset__c = customerAsset.Id;
                                    casForecast.Product__c = customerAsset.Product__r.Id;
                                    casForecast.Forecast_Date__c = nextDate;
                                    casForecast.Forecast_Created_Date__c = System.today();
                                    casForecast.Forecast_Number__c = maxForecastNumber + 1;
                                    forecastPrice = shipActMap.get(nextDate).Actual_Shipped_Quantity__c * totalPrice;
                                    rollingPrice = rollingPrice + forecastPrice;
                                    rollingQuantity = rollingQuantity + shipActMap.get(nextDate).Actual_Shipped_Quantity__c;
                                    casForecast.Forecast_Amount__c = rollingPrice;
                                    casForecast.Forecast_Quantity__c = rollingQuantity;
                                    casForecastList.add(casForecast);
                                } else {
                                    Customer_Asset_Shipping_Forecast__c casForecast = new Customer_Asset_Shipping_Forecast__c();
                                    casForecast.Customer_Asset__c = customerAsset.Id;
                                    casForecast.Product__c = customerAsset.Product__r.Id;
                                    casForecast.Forecast_Date__c = nextDate;
                                    casForecast.Forecast_Created_Date__c = System.today();
                                    casForecast.Forecast_Number__c = maxForecastNumber + 1;
                                    casForecast.Forecast_Amount__c = rollingPrice;
                                    casForecast.Forecast_Quantity__c = rollingQuantity;
                                    casForecastList.add(casForecast);
                                }
                                dn = 1;
                            } else {
                                // billing freq of once
                                if (shipActMap.containsKey(nextDate)) {
                                    Customer_Asset_Shipping_Forecast__c casForecast = new Customer_Asset_Shipping_Forecast__c();
                                    casForecast.Customer_Asset__c = customerAsset.Id;
                                    casForecast.Product__c = customerAsset.Product__r.Id;
                                    casForecast.Forecast_Date__c = nextDate;
                                    casForecast.Forecast_Created_Date__c = System.today();
                                    casForecast.Forecast_Number__c = maxForecastNumber + 1;
                                    casForecast.Forecast_Amount__c = totalPrice;
                                    casForecast.Forecast_Quantity__c = totalQty;
                                    casForecastList.add(casForecast);
                                    apComplete = true;
                                }
                            }
                        }
                        nextDate = nextDate.addMonths(1).toStartOfMonth();
                    }
                }
            } else if (customerAsset.Product__r.Product_Type__c == 'Software'
                    && customerAsset.Product__r.Product_Sub_Type__c != 'Service Plans') {
                if (customerAsset.Quantity__c > 0) {
                    Decimal totalPrice = customerAsset.Total_One_Time_Fee_s__c;
                    Decimal totalQty = customerAsset.Quantity__c;
                    Boolean swComplete = false;
                    Integer dn = 0;
                    if (billingFreqInt > 0) {
                        dn = 1;
                    }
                    Decimal rollingQuantity = 0.0;
                    Decimal rollingPrice = 0.0;
                    Decimal forecastPrice = 0.0;
                    while (nextDate < forecastEndDate) {
                        if (swComplete == true) {
                            break;
                        } else {
                            if (dn < billingFreqInt) {
                                dn = dn + 1;
                                if (shipActMap.containsKey(nextDate)) {
                                    forecastPrice = shipActMap.get(nextDate).Actual_Shipped_Quantity__c * totalPrice;
                                    rollingPrice = rollingPrice + forecastPrice;
                                    rollingQuantity = rollingQuantity + shipActMap.get(nextDate).Actual_Shipped_Quantity__c;
                                }
                            } else if (dn == billingFreqInt && dn != 0) {
                                if (shipActMap.containsKey(nextDate)) {
                                    Customer_Asset_Shipping_Forecast__c casForecast = new Customer_Asset_Shipping_Forecast__c();
                                    casForecast.Customer_Asset__c = customerAsset.Id;
                                    casForecast.Product__c = customerAsset.Product__r.Id;
                                    casForecast.Forecast_Date__c = nextDate;
                                    casForecast.Forecast_Created_Date__c = System.today();
                                    casForecast.Forecast_Number__c = maxForecastNumber + 1;
                                    forecastPrice = shipActMap.get(nextDate).Actual_Shipped_Quantity__c * totalPrice;
                                    rollingPrice = rollingPrice + forecastPrice;
                                    rollingQuantity = rollingQuantity + shipActMap.get(nextDate).Actual_Shipped_Quantity__c;
                                    casForecast.Forecast_Amount__c = rollingPrice;
                                    casForecast.Forecast_Quantity__c = rollingQuantity;
                                    casForecastList.add(casForecast);
                                } else {
                                    Customer_Asset_Shipping_Forecast__c casForecast = new Customer_Asset_Shipping_Forecast__c();
                                    casForecast.Customer_Asset__c = customerAsset.Id;
                                    casForecast.Product__c = customerAsset.Product__r.Id;
                                    casForecast.Forecast_Date__c = nextDate;
                                    casForecast.Forecast_Created_Date__c = System.today();
                                    casForecast.Forecast_Number__c = maxForecastNumber + 1;
                                    casForecast.Forecast_Amount__c = rollingPrice;
                                    casForecast.Forecast_Quantity__c = rollingQuantity;
                                    casForecastList.add(casForecast);
                                }
                                dn = 1;
                            } else {
                                // billing freq of once
                                if (shipActMap.containsKey(nextDate)) {
                                    Customer_Asset_Shipping_Forecast__c casForecast = new Customer_Asset_Shipping_Forecast__c();
                                    casForecast.Customer_Asset__c = customerAsset.Id;
                                    casForecast.Product__c = customerAsset.Product__r.Id;
                                    casForecast.Forecast_Date__c = nextDate;
                                    casForecast.Forecast_Created_Date__c = System.today();
                                    casForecast.Forecast_Number__c = maxForecastNumber + 1;
                                    casForecast.Forecast_Amount__c = totalPrice;
                                    casForecast.Forecast_Quantity__c = totalQty;
                                    casForecastList.add(casForecast);
                                    swComplete = true;
                                }
                            }
                        }
                        nextDate = nextDate.addMonths(1).toStartOfMonth();
                    }
                }
            }

        }
        System.debug('cas forecast list: ' + casForecastList);
        CustomerAssetHandler.bypassTrigger = true;
        if (casForecastList.size() > 0) {
            insert casForecastList;
        }
        if (casFCUpdatetList.size() > 0) {
            update casFCUpdatetList;
        }
        CustomerAssetHandler.bypassTrigger = false;
    }*/

    /**
     * Builds an map of customer asset Id to a map of the Dates to Customer Shipping estimates.
     */
    /* ARMAN: private static Map<Id, Map<Date, Customer_Asset_Shipping_Estimate__c>> getShippingEstimateDates(List<Customer_Asset__c> customerAssetList) {
        Map<Id, Map<Date, Customer_Asset_Shipping_Estimate__c>> assetIdToMapDateShippingEstimatesMap = new Map<Id, Map<Date, Customer_Asset_Shipping_Estimate__c>>();
        List<Customer_Asset_Shipping_Estimate__c> shippingEstimateList = new List<Customer_Asset_Shipping_Estimate__c>();
        Map<Id, List<Customer_Asset_Shipping_Estimate__c>> assetIdToShippingEstimateListMap = new Map<Id, List<Customer_Asset_Shipping_Estimate__c>>();

        try {
            shippingEstimateList = [
                    SELECT Id, Name, Estimated_Shipping_Date__c, Estimated_Shipping_Quantity__c
                            , Customer_Asset_Shipping_Summary__c, Shipping_Notes__c, Customer_Asset_Shipping_Summary__r.Customer_Asset__c
                    FROM Customer_Asset_Shipping_Estimate__c
                    WHERE Customer_Asset_Shipping_Summary__r.Customer_Asset__c IN :customerAssetList
            ];
        } catch (Exception eek) {
            System.debug(LoggingLevel.INFO, 'RevenueForecastHandler.getShippingEstimateDates - no rows were found for the set of keys for shipping estimates: ' + customerAssetList + ' Message: ' + eek.getMessage());
        }

        for (Customer_Asset_Shipping_Estimate__c estimate: shippingEstimateList) {
            List<Customer_Asset_Shipping_Estimate__c> shippingList = new List<Customer_Asset_Shipping_Estimate__c>();
            if (assetIdToShippingEstimateListMap.containsKey(estimate.Customer_Asset_Shipping_Summary__r.Customer_Asset__c)) {
                shippingList = assetIdToShippingEstimateListMap.get(estimate.Customer_Asset_Shipping_Summary__r.Customer_Asset__c);
            } else {
                shippingList = new List<Customer_Asset_Shipping_Estimate__c>();
            }
            shippingList.add(estimate);
            assetIdToShippingEstimateListMap.put(estimate.Customer_Asset_Shipping_Summary__r.Customer_Asset__c, shippingList);
        }

        // Iterate over all the asset ids
        for (Customer_Asset__c asset: customerAssetList) {
            Map<Date, Customer_Asset_Shipping_Estimate__c> shipEstMap = new Map<Date, Customer_Asset_Shipping_Estimate__c>();
            if (assetIdToShippingEstimateListMap.containsKey(asset.Id)) {
                List<Customer_Asset_Shipping_Estimate__c> shipEstList = assetIdToShippingEstimateListMap.get(asset.Id);
                for (Customer_Asset_Shipping_Estimate__c she : shipEstList) {
                    if (shipEstMap.containsKey(she.Estimated_Shipping_Date__c.toStartOfMonth())) {
                        she.Estimated_Shipping_Quantity__c = she.Estimated_Shipping_Quantity__c + shipEstMap.get(she.Estimated_Shipping_Date__c.toStartOfMonth()).Estimated_Shipping_Quantity__c;
                        she.Shipping_Notes__c = she.Shipping_Notes__c + '\n' + shipEstMap.get(she.Estimated_Shipping_Date__c.toStartOfMonth()).Shipping_Notes__c;
                    }
                    shipEstMap.put(she.Estimated_Shipping_Date__c.toStartOfMonth(), she);
                }
            } else {
                System.debug('Could not match the customer asset to a list of shipping estimates so creating defaults: ' + asset.Id);
                Customer_Asset_Shipping_Summary__c ssum = new Customer_Asset_Shipping_Summary__c();
                ssum.Customer_Asset__c = asset.Id;
                insert ssum;

                Customer_Asset_Shipping_Estimate__c sest = new Customer_Asset_Shipping_Estimate__c();
                sest.Estimated_Shipping_Date__c = asset.Term_Start_Date__c;
                sest.Estimated_Shipping_Quantity__c = asset.Quantity__c;
                sest.Customer_Asset_Shipping_Summary__c = ssum.Id;
                insert sest;

                shipEstMap.put(asset.Term_Start_Date__c.toStartOfMonth(), sest);
            }
            assetIdToMapDateShippingEstimatesMap.put(asset.Id, shipEstMap);
        }
        return assetIdToMapDateShippingEstimatesMap;
    }*/

    /**
     * Builds an map of customer asset Id to a map of the Dates to Customer Shipping estimates.
     */
    /* ARMAN: private static Map<Id, Map<Date, Customer_Asset_Shipping_Actual__c>> getShippingActualDates(List<Customer_Asset__c> customerAssetList) {
        Map<Id, Map<Date, Customer_Asset_Shipping_Actual__c>> assetIdToMapDateShippingActualMap = new Map<Id, Map<Date, Customer_Asset_Shipping_Actual__c>>();
        List<Customer_Asset_Shipping_Actual__c> shippingActualList = new List<Customer_Asset_Shipping_Actual__c>();
        Map<Id, List<Customer_Asset_Shipping_Actual__c>> assetIdToShippingActualListMap = new Map<Id, List<Customer_Asset_Shipping_Actual__c>>();

        try {
            shippingActualList = [
                    SELECT Id, Name, Actual_Shipped_Date__c, Actual_Shipped_Quantity__c
                            , Customer_Asset_Shipping_Summary__c, Shipping_Notes__c, Customer_Asset_Shipping_Summary__r.Customer_Asset__c
                    FROM Customer_Asset_Shipping_Actual__c
                    WHERE Customer_Asset_Shipping_Summary__r.Customer_Asset__c IN :customerAssetList
            ];
        } catch (Exception eek) {
            System.debug(LoggingLevel.INFO, 'RevenueForecastHandler.getShippingActualDates - no rows were found for the set of keys for shipping estimates: ' + customerAssetList + ' Message: ' + eek.getMessage());
        }

        for (Customer_Asset_Shipping_Actual__c actual: shippingActualList) {
            List<Customer_Asset_Shipping_Actual__c> shippingList = new List<Customer_Asset_Shipping_Actual__c>();
            if (assetIdToShippingActualListMap.containsKey(actual.Customer_Asset_Shipping_Summary__r.Customer_Asset__c)) {
                shippingList = assetIdToShippingActualListMap.get(actual.Customer_Asset_Shipping_Summary__r.Customer_Asset__c);
            } else {
                shippingList = new List<Customer_Asset_Shipping_Actual__c>();
            }
            shippingList.add(actual);
            assetIdToShippingActualListMap.put(actual.Customer_Asset_Shipping_Summary__r.Customer_Asset__c, shippingList);
        }

        // Iterate over all the asset ids
        for (Customer_Asset__c asset: customerAssetList) {
            Map<Date, Customer_Asset_Shipping_Actual__c> shipActualMap = new Map<Date, Customer_Asset_Shipping_Actual__c>();
            if (assetIdToShippingActualListMap.containsKey(asset.Id)) {
                List<Customer_Asset_Shipping_Actual__c> shipEstList = assetIdToShippingActualListMap.get(asset.Id);
                for (Customer_Asset_Shipping_Actual__c she : shipEstList) {
                    if (shipActualMap.containsKey(she.Actual_Shipped_Date__c.toStartOfMonth())) {
                        she.Actual_Shipped_Quantity__c = she.Actual_Shipped_Quantity__c + shipActualMap.get(she.Actual_Shipped_Date__c.toStartOfMonth()).Actual_Shipped_Quantity__c;
                        she.Shipping_Notes__c = she.Shipping_Notes__c + '\n' + shipActualMap.get(she.Actual_Shipped_Date__c.toStartOfMonth()).Shipping_Notes__c;
                    }
                    shipActualMap.put(she.Actual_Shipped_Date__c.toStartOfMonth(), she);
                }
            } else {
                System.debug('Could not match the customer asset to a list of shipping estimates so creating defaults: ' + asset.Id);
                Customer_Asset_Shipping_Summary__c ssum = new Customer_Asset_Shipping_Summary__c();
                ssum.Customer_Asset__c = asset.Id;
                insert ssum;

                Customer_Asset_Shipping_Actual__c sest = new Customer_Asset_Shipping_Actual__c();
                sest.Actual_Shipped_Date__c = asset.Term_Start_Date__c;
                sest.Actual_Shipped_Quantity__c = asset.Quantity__c;
                sest.Customer_Asset_Shipping_Summary__c = ssum.Id;
                insert sest;

                shipActualMap.put(asset.Term_Start_Date__c.toStartOfMonth(), sest);
            }
            assetIdToMapDateShippingActualMap.put(asset.Id, shipActualMap);
        }
        return assetIdToMapDateShippingActualMap;
    } */

    /* ARMAN: private static Map<Date, Customer_Asset_Shipping_Actual__c> getShippingActualDates(Customer_Asset__c customerAsset) {
        List<Customer_Asset_Shipping_Actual__c> shipActList = new List<Customer_Asset_Shipping_Actual__c>();
        Map<Date, Customer_Asset_Shipping_Actual__c> shipActMap = new Map<Date, Customer_Asset_Shipping_Actual__c>();
        try {
            shipActList = [
                    select Id, Name, Actual_Shipped_Date__c, Actual_Shipped_Quantity__c
                            , Customer_Asset_Shipping_Summary__c, Shipping_Notes__c
                    from Customer_Asset_Shipping_Actual__c
                    where Customer_Asset_Shipping_Summary__r.Customer_Asset__c = :customerAsset.Id
            ];
            for (Customer_Asset_Shipping_Actual__c sha : shipActList) {
                if (shipActMap.containsKey(sha.Actual_Shipped_Date__c.toStartOfMonth())) {
                    sha.Actual_Shipped_Quantity__c = sha.Actual_Shipped_Quantity__c + shipActMap.get(sha.Actual_Shipped_Date__c.toStartOfMonth()).Actual_Shipped_Quantity__c;
                    sha.Shipping_Notes__c = sha.Shipping_Notes__c + '\n' + shipActMap.get(sha.Actual_Shipped_Date__c.toStartOfMonth()).Shipping_Notes__c;
                }
                shipActMap.put(sha.Actual_Shipped_Date__c.toStartOfMonth(), sha);
            }
        } catch (Exception ex) {
            Customer_Asset_Shipping_Summary__c ssum = new Customer_Asset_Shipping_Summary__c();
            ssum.Customer_Asset__c = customerAsset.Id;
            insert ssum;

            Customer_Asset_Shipping_Actual__c sact = new Customer_Asset_Shipping_Actual__c();
            sact.Actual_Shipped_Date__c = customerAsset.Term_Start_Date__c;
            sact.Actual_Shipped_Quantity__c = customerAsset.Quantity__c;
            sact.Customer_Asset_Shipping_Summary__c = ssum.Id;
            insert sact;

            shipActMap.put(customerAsset.Term_Start_Date__c.toStartOfMonth(), sact);
        }
        return shipActMap;
    }*/

    /* UNUSED: private static Map<Id, List<Customer_Asset_Forecast__c>> buildCustomerAssetForecastMap(List<Customer_Asset__c> custAssetList) {
        List<Customer_Asset_Forecast__c> allOldForecasts = [SELECT Id, Forecast_Date__c, Customer_Asset__c, Customer_Asset__r.Term_Start_Date__c FROM Customer_Asset_Forecast__c WHERE Customer_Asset__c IN :custAssetList];
        Map<Id, List<Customer_Asset_Forecast__c>> allOldForecastMap = new Map<Id, List<Customer_Asset_Forecast__c>>();
        for (Customer_Asset_Forecast__c caf: allOldForecasts) {
            List<Customer_Asset_Forecast__c> forecastList = new List<Customer_Asset_Forecast__c>();
            if (allOldForecastMap.containsKey(caf.Customer_Asset__c)) {
                forecastList = allOldForecastMap.get(caf.Customer_Asset__c);
            } else {
                forecastList = new List<Customer_Asset_Forecast__c>();
            }
            //do not want to delete the forecasts that are occuring before the current customer asset start date.
            if(caf.Forecast_Date__c >= caf.Customer_Asset__r.Term_Start_Date__c.toStartOfMonth()) {
                forecastList.add(caf);
            }
            allOldForecastMap.put(caf.Customer_Asset__c, forecastList);
        }
        return allOldForecastMap;
    }*/

    /* ARMAN: private static Map<Id, List<Customer_Asset_Shipping_Forecast__c>> buildCustomerAssetShippingForecastMap(List<Customer_Asset__c> custAssetList) {
        List<Customer_Asset_Shipping_Forecast__c> allOldForecasts = [SELECT Id, Forecast_Date__c, Customer_Asset__c, Customer_Asset__r.Term_Start_Date__c FROM Customer_Asset_Shipping_Forecast__c WHERE Customer_Asset__c IN :custAssetList];
        Map<Id, List<Customer_Asset_Shipping_Forecast__c>> allOldForecastMap = new Map<Id, List<Customer_Asset_Shipping_Forecast__c>>();
        for (Customer_Asset_Shipping_Forecast__c caf: allOldForecasts) {
            List<Customer_Asset_Shipping_Forecast__c> forecastList = new List<Customer_Asset_Shipping_Forecast__c>();
            if (allOldForecastMap.containsKey(caf.Customer_Asset__c)) {
                forecastList = allOldForecastMap.get(caf.Customer_Asset__c);
            } else {
                forecastList = new List<Customer_Asset_Shipping_Forecast__c>();
            }
            //do not want to delete the forecasts that are occuring before the current customer asset start date.
            if(caf.Forecast_Date__c >= caf.Customer_Asset__r.Term_Start_Date__c.toStartOfMonth()) {
                forecastList.add(caf);
            }
            allOldForecastMap.put(caf.Customer_Asset__c, forecastList);
        }
        return allOldForecastMap;
    } */

    /* ARMAN: private static Integer retrieveMaxForecastNumber(List<Customer_Asset_Forecast__c> forecastList) {
        Integer maxForecast = 0;
        for (Customer_Asset_Forecast__c forecast: forecastList) {
            if (forecast.Forecast_Number__c > maxForecast) {
                maxForecast = Integer.valueOf(forecast.Forecast_Number__c);
            }
        }
        return maxForecast;
    }*/

    /* ARMAN: private static Integer retrieveMaxForecastNumber(List<Customer_Asset_Shipping_Forecast__c> forecastList) {
        Integer maxForecast = 0;
        for (Customer_Asset_Shipping_Forecast__c forecast: forecastList) {
            if (forecast.Forecast_Number__c > maxForecast) {
                maxForecast = Integer.valueOf(forecast.Forecast_Number__c);
            }
        }
        return maxForecast;
    }*/

}