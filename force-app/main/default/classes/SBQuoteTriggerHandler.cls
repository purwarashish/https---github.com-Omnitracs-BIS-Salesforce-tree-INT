/***
Developer   : Sripathi Gullapalli
Date        : 10/18/2016
Description : Handler class to update the "Primary Qupote Approval Status" field on the Opportunity from the Status field on the primary Quote
**/
public with sharing class SBQuoteTriggerHandler {
    
    public static void updateOppQuoteStatus(List<SBQQ__Quote__c> quoteList, Map<Id, SBQQ__Quote__c> oldMap){
        Map<Id, Opportunity> updateOpportunityMap = new Map<Id, Opportunity>();
        for(SBQQ__Quote__c newQuote : quoteList){
            
            SBQQ__Quote__c oldQuote = oldMap.get(newQuote.Id);
            Boolean approvalStatusChanged = String.isNotBlank(newQuote.ApprovalStatus__c) && newQuote.ApprovalStatus__c=='Approved' && 
                                            (newQuote.ApprovalStatus__c != oldQuote.ApprovalStatus__c);
            Boolean statusChanged = String.isNotBlank(newQuote.SBQQ__Status__c) && (newQuote.SBQQ__Status__c != oldQuote.SBQQ__Status__c) && 
                                    (newQuote.SBQQ__Status__c == 'Signed' || newQuote.SBQQ__Status__c == 'Accepted');
            if(newQuote.SBQQ__Primary__c && approvalStatusChanged){
                updateOpportunityMap.put(newQuote.SBQQ__Opportunity2__c, (new Opportunity(Id=newQuote.SBQQ__Opportunity2__c, Primary_Quote_Approval_Status__c='Approved', Primary_Quote_Effective_Date__c=newQuote.SBQQ__StartDate__c, Primary_Quote_Contract_Term__c=newQuote.SBQQ__SubscriptionTerm__c)));
            }
            
            if(statusChanged){
                if(updateOpportunityMap.containsKey(newQuote.SBQQ__Opportunity2__c)){
                    updateOpportunityMap.get(newQuote.SBQQ__Opportunity2__c).Legal_Review__c = 'Approved';
                }
                else{
                    updateOpportunityMap.put(newQuote.SBQQ__Opportunity2__c, (new Opportunity(Id=newQuote.SBQQ__Opportunity2__c, Legal_Review__c='Approved')));
                }
            }
        }
        
        if(updateOpportunityMap.size() > 0){
            update updateOpportunityMap.values();
        }
    }
    
   public static void setContractValuesOnQuote(List<SBQQ__Quote__c> quoteList){
        Set<Id> accountIds = new Set<Id>();
        Set<Id> contractIds = new Set<Id>();
        Set<Id> oppIds = new Set<Id>();
        Map<Id, Account> accountMap = new Map<Id, Account>();
        Map<Id, Opportunity> oppMap = new Map<Id, Opportunity>();
        //Map<Id, Contract> contractMap = new Map<Id, Contract>();
        List<SBQQ__Quote__c> aQuoteList = new List<SBQQ__Quote__c>();
        System.debug('************* Set Quote Values');
        for(SBQQ__Quote__c newQuote : quoteList){
            /*if(newQuote.SBQQ__SubscriptionTerm__c != null){
                newQuote.SBQQ__EndDate__c = newQuote.SBQQ__EndDate__c.addMonths(12);
            }
            if(newQuote.SBQQ__Type__c == 'Amendment'){*/
                if(String.isNotBlank(newQuote.SBQQ__Account__c)){
                    accountIds.add(newQuote.SBQQ__Account__c);
                }
                if(String.isNotBlank(newQuote.SBQQ__MasterContract__c)){
                    contractIds.add(newQuote.SBQQ__MasterContract__c);
                }
                aQuoteList.add(newQuote);
            //}
            oppIds.add(newQuote.SBQQ__Opportunity2__c);
        }
    
        if(accountIds.size() > 0){
            accountMap = new Map<Id, Account> ([select Id,(SELECT Id, Name, Account_Name__c, Legal_name__c,Attention__c, Location_Type__c, Address_Line_1__c, Address_Line_2__c, 
                                                                  City__c, State_Province__c, Zip_Postal_Code__c, Country__c from addresses__r order by LastModifiedDate desc) 
                                                  from Account where Id in :accountIds]);
        }
        
        if(oppIds.size() > 0){
            oppMap = new Map<Id, Opportunity> ([select Id, CloseDate,Primary_Contact__c, Order_Type__c, Order_Sub_Type__c, SBQQ__AmendedContract__c, 
                                                       SBQQ__AmendedContract__r.EndDate from Opportunity where Id in :oppIds]);
        }
        
        /*if(contractIds.size()>0){
            contractMap = new Map<Id, Contract> ([select Id,SBQQ__OpportunityPricebookId__c from Contract where Id in :contractIds]);
        }*/
        
        if(aQuoteList.size() > 0){
            Address__c corporateAddress = null;
            Address__c shippingAddress = null;
            Address__c billtoAddress = null;
            Id primaryContactId = null;
            for(SBQQ__Quote__c sbQuote : aQuoteList){
                Account accnt = accountMap.get(sbQuote.SBQQ__Account__c);
                if(oppMap != null && oppMap.size() > 0){
                    primaryContactId = (oppMap.get(sbQuote.SBQQ__Opportunity2__c) != null)?oppMap.get(sbQuote.SBQQ__Opportunity2__c).Primary_Contact__c:null;
                }
                //Contract cntrct = contractMap.get(sbQuote.SBQQ__MasterContract__c);
                
                /*if(cntrct != null && String.isNotBlank(cntrct.SBQQ__OpportunityPricebookId__c)){
                    sbQuote.SBQQ__PriceBook__c = cntrct.SBQQ__OpportunityPricebookId__c;
                    sbQuote.SBQQ__PricebookId__c = cntrct.SBQQ__OpportunityPricebookId__c;
                }*/
                
                if(accnt != null && accnt.addresses__r != null && accnt.addresses__r.size() > 0){
                	
                	for(Address__c address: accnt.addresses__r) {
                    	sbQuote.Ship_To_Attention__c = primaryContactId;
                    	sbQuote.Bill_To_Attention__c = primaryContactId; 
                        sbQuote.Corporate_Attention__c = primaryContactId;
                        sbQuote.SBQQ__PrimaryContact__c = primaryContactId;
                            
                        if(address.Location_Type__c == 'Shipping Address' && shippingAddress == null) {
                            shippingAddress = address;
                            sbQuote.Ship_To_Account_Address__c = address.Id;
                            sbQuote.Ship_To_Location_Type__c = address.Location_Type__c;
                            sbQuote.Ship_to_Account_Name__c = address.Legal_name__c;
                            sbQuote.SBQQ__ShippingStreet__c = address.Address_Line_1__c + ' ' + (address.Address_Line_2__c == null ? '' : address.Address_Line_2__c);
                            sbQuote.SBQQ__ShippingCity__c = address.City__c;
                            sbQuote.SBQQ__ShippingState__c = address.State_Province__c;
                            sbQuote.SBQQ__ShippingPostalCode__c = address.Zip_Postal_Code__c;
                            sbQuote.SBQQ__ShippingCountry__c = address.Country__c;
                        }
                        if((address.Location_Type__c == 'Billing Address' || address.Location_Type__c == 'Invoice Address') && billtoAddress == null) {
                            billtoAddress = address;
                            sbQuote.Bill_To_Account_Address2__c = billtoAddress.Id;
                            sbQuote.Bill_to_Location_Type__c = address.Location_Type__c;
                            sbQuote.Bill_to_Account_Name__c = address.Legal_name__c;
                            sbQuote.SBQQ__BillingStreet__c = address.Address_Line_1__c + ' ' + (address.Address_Line_2__c == null ? '' : address.Address_Line_2__c);
                            sbQuote.SBQQ__BillingCity__c = address.City__c;
                            sbQuote.SBQQ__BillingState__c = address.State_Province__c;
                            sbQuote.SBQQ__BillingPostalCode__c = address.Zip_Postal_Code__c;
                            sbQuote.SBQQ__BillingCountry__c = address.Country__c;
            
                        }
                        system.debug(address.Location_Type__c+','+corporateAddress);
                        if(address.Location_Type__c == 'Corporate HQ' && corporateAddress == null) {
                            corporateAddress = address;
                            sbQuote.Corporate_Account_Address__c = corporateAddress.Id;
                            sbQuote.Corporate_Location_Type__c = address.Location_Type__c;
                            sbQuote.Corporate_Account_Name__c = address.Legal_name__c;
                            sbQuote.Corporate_Street__c = address.Address_Line_1__c + ' ' + (address.Address_Line_2__c == null ? '' : address.Address_Line_2__c);
                            sbQuote.Corporate_City__c = address.City__c;
                            sbQuote.Corporate_State__c = address.State_Province__c;
                            sbQuote.Corporate_Postal_Code__c = address.Zip_Postal_Code__c;
                            sbQuote.Corporate_Country__c = address.Country__c;
                        }
                    }
                    
                    if(shippingAddress == null && corporateAddress != null){
                    	sbQuote.Ship_To_Account_Address__c = corporateAddress.Id;
                        sbQuote.Ship_To_Location_Type__c = corporateAddress.Location_Type__c;
                        sbQuote.Ship_to_Account_Name__c = corporateAddress.Legal_name__c;
                        sbQuote.SBQQ__ShippingStreet__c = corporateAddress.Address_Line_1__c + ' ' + (corporateAddress.Address_Line_2__c == null ? '' : corporateAddress.Address_Line_2__c);
                        sbQuote.SBQQ__ShippingCity__c = corporateAddress.City__c;
                        sbQuote.SBQQ__ShippingState__c = corporateAddress.State_Province__c;
                        sbQuote.SBQQ__ShippingPostalCode__c = corporateAddress.Zip_Postal_Code__c;
                        sbQuote.SBQQ__ShippingCountry__c = corporateAddress.Country__c;
                    }
                    
                 	if(billtoAddress == null && corporateAddress != null){
                    	sbQuote.Bill_To_Account_Address2__c = corporateAddress.Id;
                        sbQuote.Bill_to_Location_Type__c = corporateAddress.Location_Type__c;
                        sbQuote.Bill_to_Account_Name__c = corporateAddress.Legal_name__c;
                        sbQuote.SBQQ__BillingStreet__c = corporateAddress.Address_Line_1__c + ' ' + (corporateAddress.Address_Line_2__c == null ? '' : corporateAddress.Address_Line_2__c);
                        sbQuote.SBQQ__BillingCity__c = corporateAddress.City__c;
                        sbQuote.SBQQ__BillingState__c = corporateAddress.State_Province__c;
                        sbQuote.SBQQ__BillingPostalCode__c = corporateAddress.Zip_Postal_Code__c;
                        sbQuote.SBQQ__BillingCountry__c = corporateAddress.Country__c;
                    }
                }
            }
        }
        System.debug('*************************Updating Start and End date');
        if(oppMap.size()>0){
            for(SBQQ__Quote__c newQuote : quoteList){
                Opportunity opp = oppMap.get(newQuote.SBQQ__Opportunity2__c);
                System.debug('SBQuoteTriggerHandler.setContractValuesOnQuote() quote start date: [' + newQuote.SBQQ__StartDate__c + '] quote End Date: [' + newQuote.SBQQ__EndDate__c + '] Opp CloseDate: [' + opp.CloseDate + '] sub term: [' + newQuote.SBQQ__SubscriptionTerm__c + ']');
                if(newQuote.SBQQ__StartDate__c == null){
                    newQuote.SBQQ__StartDate__c = opp.CloseDate;
                }
                if((newQuote.SBQQ__EndDate__c == null) || (newQuote.SBQQ__EndDate__c <= newQuote.SBQQ__StartDate__c)){
                    Opportunity aOpp = oppMap.get(newQuote.SBQQ__Opportunity2__c);
                    if(newQuote.SBQQ__SubscriptionTerm__c != null){
                        newQuote.SBQQ__EndDate__c = newQuote.SBQQ__StartDate__c.addMonths(Integer.valueOf(newQuote.SBQQ__SubscriptionTerm__c));
                    }
                    else if(aOpp != null && aOpp.Order_Type__c == 'Contract Renewal' && aOpp.Order_Sub_Type__c == 'Decommission' && 
                            aOpp.SBQQ__AmendedContract__c != null && aOpp.SBQQ__AmendedContract__r.EndDate != null){
                        newQuote.SBQQ__EndDate__c = aOpp.SBQQ__AmendedContract__r.EndDate;
                    }
                    else{
                        newQuote.SBQQ__EndDate__c = newQuote.SBQQ__StartDate__c.addMonths(12);
                    }
                }
            }
        }
   }
   
   public static void updateEndDate(List<SBQQ__Quote__c> quoteList, Map<Id, SBQQ__Quote__c> oldMap){
        
        Set<ID> contractIds = new Set<ID>();
        Map<ID, Contract> contractMap = new Map<ID, Contract>();
        
        for(SBQQ__Quote__c newQuote : quoteList){
            if(newQuote.Order_Type__c == 'Contract Renewal' && newQuote.Order_Sub_Type__c == 'Decommission' && String.isNotBlank(newQuote.SBQQ__MasterContract__c)){
                contractIds.add(newQuote.SBQQ__MasterContract__c);
            }
        }
        
        if(contractIds.size() > 0){
            contractMap = new Map<ID, Contract> ([select Id, EndDate from Contract where Id in :contractIds]);
        }
        
        for(SBQQ__Quote__c newQuote : quoteList){
            SBQQ__Quote__c oldQuote = oldMap.get(newQuote.Id);
            if(newQuote.SBQQ__SubscriptionTerm__c != null && newQuote.SBQQ__StartDate__c != null && (newQuote.SBQQ__SubscriptionTerm__c  != oldQuote.SBQQ__SubscriptionTerm__c )){
                newQuote.SBQQ__EndDate__c = (newQuote.SBQQ__StartDate__c.addMonths(Integer.valueOf(newQuote.SBQQ__SubscriptionTerm__c))).addDays(-1);
            } else if(newQuote.SBQQ__EndDate__c <= newQuote.SBQQ__StartDate__c) {
                if(newQuote.SBQQ__SubscriptionTerm__c != null){
                    newQuote.SBQQ__EndDate__c = newQuote.SBQQ__StartDate__c.addMonths(Integer.valueOf(newQuote.SBQQ__SubscriptionTerm__c));
                } 
                else if(newQuote.Order_Type__c == 'Contract Renewal' && newQuote.Order_Sub_Type__c == 'Decommission' && 
                        String.isNotBlank(newQuote.SBQQ__MasterContract__c) && contractMap.size() > 0 && contractMap.get(newQuote.SBQQ__MasterContract__c) != null){
                    newQuote.SBQQ__EndDate__c = contractMap.get(newQuote.SBQQ__MasterContract__c).EndDate;
                }
                else {
                    newQuote.SBQQ__EndDate__c = newQuote.SBQQ__StartDate__c.addMonths(12);
                }
            }
            System.debug('********************* 17 '+newQuote.SBQQ__StartDate__c +' -- '+newQuote.SBQQ__SubscriptionTerm__c + ' -- '+newQuote.SBQQ__EndDate__c);
            
        }
        
        
   }
   
   //Sripathi Gullapalli, Method to update Wrapper and Product Option on Quote line, used only for migration
    public static void updateQuoteLines(List<SBQQ__Quote__c> quoteList, Map<Id, SBQQ__Quote__c> oldMap){

        //Map<String, ID> wrapperProductMap = new Map<String, Id>();
        Map<String, SBQQ__QuoteLine__c> wrapperQLMap = new Map<String,SBQQ__QuoteLine__c>();
        Map<Id, Id> quoteLineGroupMap = new Map<Id, Id>();
        Set<Id> quoteSet = new Set<Id>();
        //Set<String> wrapperSet = new Set<String>{'RTI Telematics Wrapper','RTS Wrapper','Legacy Wrapper','RNA Wrapper','Roadnet Professional Services Wrapper','Omnitracs MX Wrapper','Sylectus Wrapper','XRS Product Configuration'};
        List<SBQQ__QuoteLine__c> updateQuoteLineList = new List<SBQQ__QuoteLine__c>();
        List<SBQQ__QuoteLine__c> updateWrapperList = new List<SBQQ__QuoteLine__c>();
        Set<String> wrapperSet = new Set<String>();

        /*for(Product2 pd : [select Id,ProductCode,name from Product2 where Name in :wrapperSet]){
            wrapperProductMap.put(pd.Name, pd.Id);
        }*/

        for(SBQQ__Quote__c newQuote : quoteList){
            SBQQ__Quote__c oldQuote = oldMap.get(newQuote.Id);
            if(newQuote.Update_Quote_Lines__c && newQuote.From_Asset_Migration__c && (newQuote.Update_Quote_Lines__c != oldQuote.Update_Quote_Lines__c)){
                quoteSet.add(newQUote.Id);
            }
        }

        if(quoteSet.size() > 0){
           for(SBQQ__Quote__c qQuote : [Select Id,Migrated_Contracted_Assets__c,(select Id,name,SBQQ__Quote__c,SBQQ__RequiredBy__c,SBQQ__ProductOption__c,Test_Quote_Line_Wrapper__c,SBQQ__Product__c,SBQQ__NetTotal__c,SBQQ__Discount__c,
                                                SBQQ__Product__r.ProductCode,Migrated_Product_Option_ID__c,Migrate_Contracted_Asset__c,Migrate_Contracted_Asset__r.ARR__c, isWrapper__c,Migrated_ARR__c from SBQQ__LineItems__r),
                                                (Select Id From SBQQ__LineItemGroups__r)
                                          from SBQQ__Quote__c where Id in : quoteSet]){
                if(qQuote.SBQQ__LineItems__r != null && qQuote.SBQQ__LineItems__r.size()>0){
                    for(SBQQ__QuoteLine__c sql : qQuote.SBQQ__LineItems__r){
                        if(sql.isWrapper__c){
                            wrapperQLMap.put(qQuote.Id+'-'+sql.SBQQ__Product__r.ProductCode, sql);
                            updateWrapperList.add(sql);
                        }
                        else{
                            updateQuoteLineList.add(sql);
                        }

                    }

                }

                if(qQuote.SBQQ__LineItemGroups__r != null && qQuote.SBQQ__LineItemGroups__r.size() > 0){
                    quoteLineGroupMap.put(qQuote.Id, qQuote.SBQQ__LineItemGroups__r.get(0).Id);
                }
            }

            if(updateQuoteLineList.size() > 0){
                for(SBQQ__QuoteLine__c uql : updateQuoteLineList){
                    if(String.isNotBlank(uql.Migrated_Product_Option_ID__c) && String.isBlank(uql.SBQQ__ProductOption__c)){
                        //uql.SBQQ__ProductOption__c = uql.Migrated_Product_Option_ID__c;
                    }
                    SBQQ__QuoteLine__c wql = wrapperQLMap.get(uql.SBQQ__Quote__c+'-'+uql.Test_Quote_Line_Wrapper__c);
                    if(wql != null){
                        uql.SBQQ__RequiredBy__c = wql.Id;
                    }

                    System.debug('****MIGRATED ARR -- '+uql.Migrated_ARR__c + ' -- '+uql.SBQQ__NetTotal__c + ' -- ' + uql.SBQQ__Discount__c);
                    /*if(uql.Migrated_ARR__c != null){
                        if(uql.SBQQ__NetTotal__c != null && uql.SBQQ__NetTotal__c > 0){
                            uql.SBQQ__Discount__c = (1-(uql.Migrated_ARR__c/uql.SBQQ__NetTotal__c))*100;
                            System.debug('****Discount -- '+uql.SBQQ__Discount__c);
                        }
                    }*/
                    ID groupID = quoteLineGroupMap.get(uql.SBQQ__Quote__c);
                    if(String.isNotBlank(groupId)){
                        uql.SBQQ__Group__c = groupID;
                    }
                }

               for(SBQQ__QuoteLine__c wql : updateWrapperList){
                   ID groupID = quoteLineGroupMap.get(wql.SBQQ__Quote__c);
                   if(String.isNotBlank(groupId)){
                       wql.SBQQ__Group__c = groupID;
                   }
                   updateQuoteLineList.add(wql);
               }

               database.update(updateQuoteLineList);
            }
        }


    }
    
}

//Select Id, Update_Quote_Lines__c,SBQQ__Primary__c FROM SBQQ__Quote__c where From_Asset_Migration__c = true