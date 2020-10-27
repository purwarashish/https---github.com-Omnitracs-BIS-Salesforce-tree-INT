/*
Author - Abhishek Dey
Date - 5/13/2015
Desciption : After cloning the Add- On quote products, this trigger will update the Add-On Source field to corresponsing Quote.

*/
public with sharing class QuoteProductUtil {

         Public void UpdateSourceAddOn(List<VCG_CPQ_Quote_Product__c> newQP)
          {
                List<VCG_CPQ_Quote_Product__c> triggerNewDummy = [select id,Add_on_Source_Quote_Product__c,Quote__c,Name,Add_on_Source_Quote_Product__r.name from VCG_CPQ_Quote_Product__c where id =: newQP ];
                Map<String,id> mapPartNumberToId; 
                List<id> lstQuoteId = new list<id>();
                Map<id,List<VCG_CPQ_Quote_Product__c>> newMap = new Map<id,List<VCG_CPQ_Quote_Product__c>>();
                
                for(VCG_CPQ_Quote_Product__c newQuoteProduct : triggerNewDummy )
                {
                    lstQuoteId.add(newQuoteProduct.Quote__c);
                }
                
                list <VCG_CPQ_Quote_Product__c> lstQP = [select id,Add_on_Source_Quote_Product__c,Quote__c,Name from VCG_CPQ_Quote_Product__c where Quote__c =:lstQuoteId];
                
                for(VCG_CPQ_Quote_Product__c dataVal : lstQP)
                {
                    list<VCG_CPQ_Quote_Product__c> addQP = new list<VCG_CPQ_Quote_Product__c>();
                    if(newMap.containskey(dataVal.Quote__c))
                    {
                        addQP = newMap.get(dataVal.Quote__c);
                        addQP.add(dataVal);
                        newMap.put(dataVal.Quote__c,addQP);
                    }
                    else
                    newMap.put(dataVal.Quote__c,new list<VCG_CPQ_Quote_Product__c>{dataVal});
                }
                
                
                for(VCG_CPQ_Quote_Product__c newQPData : triggerNewDummy )
                {    
                        mapPartNumberToId = new Map<String,id>();
                        for(VCG_CPQ_Quote_Product__c innerNewQPData :newMap.get(newQPData.Quote__c))
                        {
                            mapPartNumberToId.put(innerNewQPData.Name,innerNewQPData.id);
                        }
                        
                        newQPData.Add_on_Source_Quote_Product__c =  mapPartNumberToId.get(newQPData.Add_on_Source_Quote_Product__r.name);
                        
                }
                
                try{
                update triggerNewDummy;
                }
                catch(Exception e)
                {
                    system.debug('error in QuoteProductUtil class' + e.getMessage());
                }
                
          }
}