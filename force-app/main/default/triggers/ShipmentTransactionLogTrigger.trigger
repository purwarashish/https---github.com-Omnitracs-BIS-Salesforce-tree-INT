/* 
Description: Transaction Log record should be created Whenever a record gets created in Shipment Line object.
Author: Antharao Chirumamilla.
Date: 08/23/2018
Objects: Shipment Line and TXN Log.
*/
trigger ShipmentTransactionLogTrigger on Shipment_Line__c (after insert)
{
    List<TXN_Log__c> txnToInsert = new List<TXN_Log__c>();
    Map<String,String> storeOrderTypeWithEvent = new Map<String,String>();
    for(ShipmentTxnLog__c sts : [select id, EventType__c, OrderType__c from ShipmentTxnLog__c])
    {
        storeOrderTypeWithEvent.put(sts.OrderType__c,sts.EventType__c);
    }
    List<TXN_Log__c> TxnLogs= new List<TXN_Log__c>();
    for(Shipment_Line__c shp: Trigger.new)
    {
     // do not create tax line if values are missing on Shiptment line item object 
        if(shp.Item_ID__c!=null && shp.Oracle_Sales_Order_ID__c!=null)
        { 
        //if(shp.Item_SKU_Product_Id__c!=null && shp.Oracle_Sales_Order_ID__c!=null)
                TXN_Log__c txn= new TXN_Log__c();
                //txn.Account_Cust_ID__c=shp.Account__c; 
                if(shp.Shipped_Quantity__c!=null)
                txn.Quantity__c=shp.Shipped_Quantity__c;  
                txn.Product__c=shp.Item_Type__c;
                if(storeOrderTypeWithEvent!=null && storeOrderTypeWithEvent.get(shp.Order_Type__c)!=null)
                txn.Event__c=storeOrderTypeWithEvent.get(shp.Order_Type__c);
                txn.TXN_Date__c=shp.Requested_Ship_Date__c;
                if(shp.Account_Cust_Id__c!=null)
                txn.Account_Cust_ID__c=shp.Account_Cust_Id__c;
                //txn.Account_Cust_ID__c=Account__r.QWBS_Cust_ID__c;
                txn.Source_System__c='ERP';
                txn.Reference_Id__c=shp.Oracle_Sales_Order_ID__c; 
                txn.Item_SKU_Product_Id__c=shp.Item_ID__c;
                txn.CurrencyIsoCode=shp.CurrencyIsoCode;
                txnToInsert.add(txn);
        }
    }
    if(txnToInsert.size()>0)
    {
        insert txnToInsert;
    }
}