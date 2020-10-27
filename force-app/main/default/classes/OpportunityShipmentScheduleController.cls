public class OpportunityShipmentScheduleController {
   
    Public SBQQ__Quote__c thequote{get;set;}
    public opportunity opp{get;set;}
    Public List<Shipping_Line__c> Shippinglinelist{get;set;}
    Public List<Shipping_Line_Item__c> ShippingLineItem{get;set;}
    private Map<Id , Shipping_Line_Item__c> mapShippingLineItem = new Map<Id , Shipping_Line_Item__c>();
    public List<Shipping_Line__c> shippinglineItemList {get;set;}
    public List<SBQQ__QuoteLine__c> quoteLineItemList;
    public Map<String,quantityWrapper> quanityDetailMap{get;set;}
    
    public OpportunityShipmentScheduleController(ApexPages.StandardController stdController)
    {
        opp = (opportunity)stdcontroller.getRecord();
        thequote = queryquote(stdController.getId());
        shippinglineItemList = getOrderCont();
        quotelineitemlist = getQuoteLineItem();
        quanityDetailMap= new Map<String,quantityWrapper> ();
        
        for(SBQQ__QuoteLine__c qli :quotelineitemlist) 
        {
        	if(qli.Shipping_Line_Items__r.size() > 0)
            {
            	quantityWrapper qwp = new quantityWrapper (0,0,qli.SBQQ__ProductName__c);
            	if(quanityDetailMap.get(qli.SBQQ__ProductCode__c) !=  null) 
                {
                	qwp = quanityDetailMap.get(qli.SBQQ__ProductCode__c);
            	}
            qwp.effectivequantity = qwp.effectivequantity  + qli.SBQQ__EffectiveQuantity__c;
            qwp.savedquantity= qwp.savedquantity+ qli.SBQQ__EffectiveQuantity__c;
            qwp.ProductName = qli.SBQQ__ProductName__c;    
            quanityDetailMap.put(qli.SBQQ__ProductCode__c,qwp);
            }
        }
    }
    
    private static SBQQ__Quote__c queryQuote(string OpportunityID)
    {
        return [select Id, name, SBQQ__Opportunity2__c, SBQQ__Opportunity2__r.stagename, Expected_Shipment_Start__c, Schedule_Type__c from SBQQ__Quote__c where SBQQ__Opportunity2__c =: OpportunityID AND SBQQ__Primary__c= true limit 1];
    }
    
    public List<Shipping_Line__c> getOrderCont() 
    {
        Boolean Selected = false;
        List<Shipping_Line__c> Shippinglinelist = [Select id, name, quote__c, Quote__r.name, Quote__r.SBQQ__Opportunity2__c, Shipping_Date__c, (select Name, Product__c,Quote_Line__r.SBQQ__Product__r.name,Quote_Line__r.SBQQ__EffectiveQuantity__c, ProductCode__c, Quantity__c, Quote_line__c,Shipping_Date__c, Shipping_Line__c from Shipping_Line_Items__r ORDER By ProductCode__c) from Shipping_Line__c where quote__c =: theQuote.Id ORDER BY Shipping_Date__c DESC];
        return Shippinglinelist;
    }
    
    public list<SBQQ__QuoteLine__c> getQuoteLineItem () 
    {
        return [select id,SBQQ__EffectiveQuantity__c,SBQQ__ProductCode__c, SBQQ__ProductName__C, (select id from Shipping_Line_Items__r) from SBQQ__QuoteLine__c  where SBQQ__Quote__c=:thequote.id];
    }
    
    public class quantityWrapper 
    {
        public decimal effectivequantity{get;set;}
        public decimal savedquantity{get;set;}
        public String ProductName{get;set;}
        
        public quantityWrapper(decimal effectivequantity,decimal savedquantity, string ProductName) 
        {
            this.effectivequantity = effectivequantity;
            this.savedquantity = savedquantity;
            this.ProductName =ProductName;
        }
    }
    
    Public void AddShip()
    {
        Date shipmentdate = thequote.Expected_Shipment_Start__c;
        List<Shipping_Line_Item__c> SLI = new List<Shipping_Line_Item__c>();
        List<Shipping_Line__c> SHL = [Select Id from Shipping_Line__c where Quote__c = :thequote.Id];
        integer I = SHL.size();
        Shipping_Line__c SL;
        if(thequote.Schedule_Type__c == 'Back-end Load')
        {
            SL = [SELECT ID, Name, Quote__c, Shipping_Date__c FROM Shipping_Line__c WHERE Quote__c = : theQuote.Id ORDER BY CreatedDate DESC Limit 1];
        }
        else
        {
            SL = [SELECT ID, Name, Quote__c, Shipping_Date__c FROM Shipping_Line__c WHERE Quote__c = : theQuote.Id ORDER BY CreatedDate ASC Limit 1];
        }
        Shipping_Line__c SLCopy = SL.clone(false,true);
        SLCopy.Shipping_Date__c = Shipmentdate.addmonths(I);
        SlCopy.Name = thequote.Name + '_' + SLCopy.Shipping_Date__c.format();
        
        insert SLCopy;
        List<Shipping_Line_Item__c> SLIT = [SELECT Name, Product__c, ProductCode__c, Quantity__c, Quote_line__c, Quote_line__r.name, Shipping_Date__c, Shipping_Line__c FROM Shipping_Line_Item__c WHERE Shipping_Line__c = : SL.Id];
        for(Shipping_Line_Item__c c : SLIT)
        {
            Shipping_Line_Item__c SLITCopy = c.clone(false,true);
            SLITCopy.Shipping_Line__c = SLCopy.Id;
            SLITCopy.Name = SLITCopy.Quote_Line__r.name + '_' + SLCopy.Shipping_Date__c.format();
            SLITCopy.Quantity__c = 0;
            SLI.add(SLITCopy);
        }
        insert SLI;  
        shippinglineItemList = getOrderCont();
    }
    
    public PageReference save() 
    {
        Map<id,Decimal> QuantityMap = new Map<Id,Decimal> ();
        Map<id,Decimal> UpdatedQuantityMap = new Map<id,Decimal> ();
        list<Shipping_Line_Item__c> shippiLITMETOUpdate = new list<Shipping_Line_Item__c> ();
        
        for(String prdCode :quanityDetailMap.keyset()) 
        {
            quanityDetailMap.get(prdcode).savedquantity = 0;
        }
        for(Shipping_Line__c SL:shippinglineItemList)
        {
            
            shippiLITMETOUpdate.addAll(SL.Shipping_Line_Items__r);
            
            for(Shipping_Line_Item__c SLI : SL.Shipping_Line_Items__r) 
            {
                
                Decimal QuotelineQuantity;
                if(QuantityMap.get(SLI.Quote_Line__c) ==  null) 
                {
                    
                    QuantityMap.put(SLI.Quote_Line__c,SLI.Quote_Line__r.SBQQ__EffectiveQuantity__c);
                }
                QuotelineQuantity =QuantityMap.get(SLI.Quote_Line__c);
                
                QuotelineQuantity = QuotelineQuantity - SLI.Quantity__c;
                
                QuantityMap.put(SLI.Quote_Line__c,QuotelineQuantity);
                
                quanityDetailMap.get(SLI.ProductCode__c).savedquantity = quanityDetailMap.get(SLI.ProductCode__c).savedquantity+ SLI.Quantity__c;
            }   
        }
                
        for(ID quoteLineID : QuantityMap.keyset()) 
        {
            if(QuantityMap.get(quotelineid) != 0) 
            {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Please enter corrrect quanity to match the total effective quantity of Highlighted Product'));
                return null;
            }
        }
        update shippinglineItemList;
        system.debug(shippiLITMETOUpdate);
        update shippiLITMETOUpdate;
        return null;
    }
    
    
    Public pagereference BacktoOpportunity()
    {
        pagereference pg = new PageReference('/'+opp.id);
        return pg;
    }

}