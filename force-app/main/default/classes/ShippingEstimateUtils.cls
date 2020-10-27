/*********************************************************************
Name    : ShippingEstimateUtils
Author  : Yasir Arafat
Date    : 26 Feb 2019
*********************************************************************/

public class ShippingEstimateUtils{
    
    public static String createHardwareShippingLines(SBQQ__Quote__c quote){
        String status = 'Shipping Lines Created Successfully';
        try{
            if(quote != null && String.isNotBlank(quote.Delivery_Schedule__c) && String.isNotBlank(quote.Schedule_Type__c) 
                && String.isNotBlank(String.valueOf(quote.Expected_Shipment_Start__c))){
                List<Shipping_Line__c> existingShippingLines = [Select Id from Shipping_Line__c where Quote__c = :quote.Id];
                if(existingShippingLines.size() > 0)
                    delete existingShippingLines;
                Integer scheduleDelivery = Integer.valueOf(quote.Delivery_Schedule__c);
                String scheduleType = quote.Schedule_Type__c;
                Date expectedShipmentDate = quote.Expected_Shipment_Start__c;
                Decimal firstLoadPercent = (scheduleType == 'Front load' ? 0.5 : (scheduleType == 'Level load' ? 0.33 : 0.2));
                Decimal secondLoadPercent = (scheduleType == 'Front load' ? 0.3 : (scheduleType == 'Level load' ? 0.33 : 0.3));
                List<SBQQ__QuoteLine__c> quoteLineList = [Select Id, Name, SBQQ__EffectiveQuantity__c, SBQQ__Product__c, SBQQ__ProductCode__c From 
                SBQQ__QuoteLine__c Where SBQQ__Quote__c = :quote.Id AND SBQQ__EffectiveQuantity__c > 0 AND Quote_Line_Type__c IN ('New', 'Add-On') AND 
                SBQQ__Product__r.Product_Type__c = 'Hardware'];
                List<Shipping_Line__c> shippineLineList = new List<Shipping_Line__c>();
                List<Shipping_Line_Item__c> shippineLineItemList = new List<Shipping_Line_Item__c>();
                if(quoteLineList.size() > 0){
                    Integer eachLoadMonths = scheduleDelivery / 3;
                    Map<Id, List<Decimal>> quoteLineQtyDistMap = new Map<Id, List<Decimal>>();
                    for(SBQQ__QuoteLine__c quoteLine : quoteLineList){
                        if(!quoteLineQtyDistMap.containsKey(quoteLine.Id))
                            quoteLineQtyDistMap.put(quoteLine.Id, new List<Decimal>());
                        if(eachLoadMonths != 0){
                            Decimal totalQty = quoteLine.SBQQ__EffectiveQuantity__c;
                            Decimal firstLoadQty = Math.floor((totalQty * firstLoadPercent));
                            Decimal secondLoadQty = Math.floor((totalQty * secondLoadPercent));
                            Decimal thirdLoadQty = totalQty - (firstLoadQty + secondLoadQty);
                            List<Decimal> qtyLoads = new List<Decimal> {firstLoadQty, secondLoadQty, thirdLoadQty};
                            for(Decimal qty : qtyLoads){
                                Decimal equalQty = Math.floor(qty/eachLoadMonths);
                                Decimal remainderQty = Math.mod(Integer.valueOf(qty), eachLoadMonths);
                                for(Integer k = 1; k <= eachLoadMonths; k++){
                                    Decimal quantity = (equalQty == 0 && k == 1 ? remainderQty : (equalQty == 0 && k != 1 ? 0 : (k == eachLoadMonths ? equalQty + remainderQty : equalQty)));
                                    quoteLineQtyDistMap.get(quoteLine.Id).add(quantity);
                                }
                            }
                        }else{
                            quoteLineQtyDistMap.get(quoteLine.Id).add(quoteLine.SBQQ__EffectiveQuantity__c);
                        }
                    }
                    
                    for(Integer i=0; i<scheduleDelivery; i++){
                        Date shipmentDate = expectedShipmentDate.addMonths(i);
                        String name = quote.Name + '_' + shipmentDate.format();
                        Shipping_Line__c shippingLine = new Shipping_Line__c(Name = name, Quote__c = quote.Id, Shipping_Date__c = shipmentDate, Opportunity__c = quote.SBQQ__Opportunity2__c);
                        shippineLineList.add(shippingLine);
                    }
                    insert shippineLineList;
                    Integer cnt = 0;
                    for(Shipping_Line__c shippingLine : shippineLineList){
                        Date shipmentDate = shippingLine.Shipping_Date__c;
                        for(SBQQ__QuoteLine__c quoteLine : quoteLineList){
							String name = quoteLine.Name + '_' + shipmentDate.format();
							Shipping_Line_Item__c shippingLineItem = new Shipping_Line_Item__c(Name = name, Shipping_Line__c = shippingLine.Id, 
							Quote_Line__c = quoteLine.Id, Product__c = quoteLine.SBQQ__Product__c, ProductCode__c = quoteLine.SBQQ__ProductCode__c, 
							Quantity__c = quoteLineQtyDistMap.get(quoteLine.Id)[cnt]);
							shippineLineItemList.add(shippingLineItem);
                        }
                        cnt++;
                    }
                    insert shippineLineItemList;
                }else{
                    status = 'Shipping Lines not created as there were no Hardware Lines associated with the Quote';
                }
            }else{
                status = '"Either Quote is null or one of Delivery Schedule, Delivery Type and Expected Shipment Date is null"';
            }
        }catch(Exception e){
            status = 'Error Occured: ' + e.getMessage();
            System.debug(status);
        }
        return status;
    }
}