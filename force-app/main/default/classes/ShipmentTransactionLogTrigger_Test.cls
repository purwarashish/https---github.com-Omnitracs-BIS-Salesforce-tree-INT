/* 
    Description: Test Class for ShipmentTransactionLogTrigger trigger.
    Author: Antharao Chirumamilla.
    Date: 08/23/2018
    Objects: Shipment Line and TXN Log.
*/

@isTest(SeeAlldata=true)
private class ShipmentTransactionLogTrigger_Test{

    static testMethod void PositiveTest(){
        test.starttest();
        // Insert Shipment Custom setting data
        ShipmentTxnLog__c stvs= new ShipmentTxnLog__c(name='testDate',EventType__c='ERP_RECEIPT',OrderType__c='RMA 82'); 
        insert  stvs; 
        /*
        // insert AccountRecordTypes__c
        
        AccountRecordTypes__c ars = new AccountRecordTypes__c(
            Name='TL_SALES_ACCOUNT_RECORD_TYPE_ID',
            RecordTypeID__c='01250000000DQBAAA4'
        );
        insert ars;
        */
        // Insert Account
        
        Account newAccount = new Account( 
            Name = 'test acct', 
            QWBS_Market__c = 'T&L Eastern Region',
            BillingStreet = '123 Main', 
            BillingCity = 'San Diego', 
            BillingState = 'CA', 
            BillingCountry = 'USA',
            CTS_Customer_ID__c = '18sa1k0ajna',
            QWBS_Cust_ID__c='asdaa1sda'
        );
        insert newAccount;
        
        // Insert Product
        
        Product2 p1 = TestUtils.getProduct('ut prod1', 'family');
        p1.External_ID__c ='aad1';
        insert p1;
        
        // Insert Shipment Line
        Shipment_Line__c slia = new Shipment_Line__c(
            Account__c=newAccount.id, 
            Event_Type__c='ERP_RECEIPT',
            Item_ID__c='a1dadaa',
            Item_Type__c=p1.id, 
            Line_Id__c='dq1dwsda',
            Oracle_Sales_Order_ID__c='asdasdasa3',
            Order_Type__c='RMA 82',
            Requested_Ship_Date__c=System.today().addDays(1),
            Shipped_Quantity__c=1
            
        ); 
        
        insert slia;
        
        System.assertEquals(1,[select id from TXN_Log__c limit 1].size());
        test.stoptest();
    }
    
    static testMethod void NegativeTest(){
        test.starttest();
        // Insert Shipment Custom setting data
        ShipmentTxnLog__c stvs= new ShipmentTxnLog__c(name='testDate',EventType__c='ERP_RECEIPT',OrderType__c='RMA 82'); 
        insert  stvs; 
        
        // Insert Account
        
        Account newAccount = new Account( 
            Name = 'test acct', 
            QWBS_Market__c = 'T&L Eastern Region',
            BillingStreet = '123 Main', 
            BillingCity = 'San Diego', 
            BillingState = 'CA', 
            BillingCountry = 'USA',
            CTS_Customer_ID__c = '18sa1k0ajna',
            QWBS_Cust_ID__c='asdaa1sda'
        );
        insert newAccount;
        
        // Insert Product
        
        Product2 p1 = TestUtils.getProduct('ut prod1', 'family');
        p1.External_ID__c ='aad1';
        insert p1;
        
        // Insert Shipment Line
        Shipment_Line__c slia = new Shipment_Line__c(
            Account__c=newAccount.id, 
            Item_ID__c='a1dadaa',
            Item_Type__c=p1.id, 
            Line_Id__c='dq1dwsda',
            Oracle_Sales_Order_ID__c='asdasdasa3',
            Order_Type__c='RMA 82',
            Requested_Ship_Date__c=System.today().addDays(1),
            Shipped_Quantity__c=1
            
        ); 
        try{
            insert slia;
        } catch (exception ex){
        }
        
        
        test.stoptest();
    }
}