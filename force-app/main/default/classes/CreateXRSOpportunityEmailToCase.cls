global class CreateXRSOpportunityEmailToCase
{
    @InvocableMethod(label='SendXRSOpportunityEmail' description='used in Send_Sales_Info_from_XRS_Quotes Process builder')
    global static void SendXRSOpportunityEmail(List<Opportunity> lstOpportunity)
    {
        List<Opportunity> lstnewOpportunity = new List<Opportunity>();
        List<VCG_CPQ_Quote__c> lstQuote = new List<VCG_CPQ_Quote__c>();         
        List<opportunityLineItem> lstOpportunityProduct = new List<opportunityLineItem>();
        List<user> lstUser = new List<User>();
        Set<Id> setOpptyIds = new Set<Id>();
        
        for(Opportunity objOpportunity:lstOpportunity)
        {
            setOpptyIds.add(objOpportunity.Id);
        }
        
        lstQuote =[SELECT Opportunity__c,Name,ShippingAddress__r.Address_Line_1__c,ShippingAddress__r.Address_Line_2__c,
                   ShippingAddress__r.City__c,ShippingAddress__r.State_Province__c,ShippingAddress__r.Zip_Postal_Code__c,
                   Invoice_Address__r.Address_Line_1__c,Invoice_Address__r.Address_Line_2__c,Invoice_Address__r.City__c,
                   Invoice_Address__r.State_Province__c,Invoice_Address__r.Zip_Postal_Code__c
                   FROM VCG_CPQ_Quote__c WHERE Opportunity__c =: setOpptyIds AND Is_Primary__c = true LIMIT 50000];
             
        lstOpportunityProduct =[SELECT OpportunityId,Product2.Name, Quantity, ProductCode FROM opportunityLineItem WHERE 
                                OpportunityId =: setOpptyIds AND Product2.Product_Type__c = 'Hardware' LIMIT 50000];
                                   
        lstnewOpportunity = [SELECT Id, Name,Ownerid, Account.Name, Account.QWBS_Cust_ID__c, Host_Information__r.Host_Company_ID__c, 
                          Send_XRS_Shipment_Request__c, Freight_Method__c, Contact__r.Name, Contact__r.Phone, 
                          Contact__r.email, owner.Name, Owner.email FROM opportunity WHERE Id =: setOpptyIds LIMIT 50000];
       
        for(Id objOpptyId:setOpptyIds)
        {
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            String strSubject = 'Sales Information from XRS Quotes';
            
            String strProduct='';
            String strShipAddress='';
            String strBillAddress='';
            String strQuoteNumber='';
            String strCustomerName='';
            String strCustomerIDNumber='';
            String strHostCompanyID = '';
            String strShiptoContact = '';
            String strShiptoPhoneNumber = '';
            String strFreightMethod = '';
            String strPurchaseOrder = '';
            String strOpportunityLink = '';
            String strOpportunityOwnerName = '';
            String strOpportunityOwnerEmailAddress = '';
            String strContactEmailAddress = '';
            boolean isexecuted=true;
            for(opportunityLineItem objOpportunityProduct:lstOpportunityProduct)
            {
                if(objOpptyId == objOpportunityProduct.OpportunityId)
                {                                            
                    if(isexecuted)
                        strProduct ='Part number(s), Product Code(SKU), Quantity:';
                    if(objOpportunityProduct.Product2.Name != null)
                        strProduct = strProduct + '\n' + objOpportunityProduct.Product2.Name+', ';
                    if(objOpportunityProduct.ProductCode != null)
                        strProduct = strProduct + objOpportunityProduct.ProductCode+', ';
                    if(objOpportunityProduct.Quantity != null)
                        strProduct = strProduct + (Integer)objOpportunityProduct.Quantity;
                    else
                        strProduct = strProduct + '0';              
                    isexecuted=false;
                }
            }
            
            for(VCG_CPQ_Quote__c objQuote:lstQuote)
            {
                if(objOpptyId == objQuote.Opportunity__c)
                {    
                    if(objQuote.ShippingAddress__r != null && objQuote.ShippingAddress__r.Address_Line_1__c != null)
                        strShipAddress = objQuote.ShippingAddress__r.Address_Line_1__c+'; ';
                    if(objQuote.ShippingAddress__r != null && objQuote.ShippingAddress__r.Address_Line_2__c != null)
                        strShipAddress = strShipAddress + objQuote.ShippingAddress__r.Address_Line_2__c+'; ';
                    if(objQuote.ShippingAddress__r.City__c != null)
                    {
                        strShipAddress = strShipAddress + objQuote.ShippingAddress__r.City__c +', ';
                    }
                    if(objQuote.ShippingAddress__r.State_Province__c != null)
                    {
                        strShipAddress = strShipAddress + objQuote.ShippingAddress__r.State_Province__c+'. ';
                    }
                    if(objQuote.ShippingAddress__r.Zip_Postal_Code__c != null)
                    {
                        strShipAddress = strShipAddress + objQuote.ShippingAddress__r.Zip_Postal_Code__c;
                    }
                    
                    if(objQuote.Invoice_Address__r != null && objQuote.Invoice_Address__r.Address_Line_1__c != null)
                        strBillAddress = objQuote.Invoice_Address__r.Address_Line_1__c+'; ';
                    if(objQuote.Invoice_Address__r != null && objQuote.Invoice_Address__r.Address_Line_2__c != null)    
                        strBillAddress = strBillAddress + objQuote.Invoice_Address__r.Address_Line_2__c+'; ';
                    if(objQuote.Invoice_Address__r.City__c != null)
                    {
                        strBillAddress = strBillAddress + objQuote.Invoice_Address__r.City__c +', ';
                    }
                    if(objQuote.Invoice_Address__r.State_Province__c != null)
                    {
                        strBillAddress = strBillAddress + objQuote.Invoice_Address__r.State_Province__c+'. ';
                    }
                    if(objQuote.Invoice_Address__r.Zip_Postal_Code__c != null)
                    {
                        strBillAddress = strBillAddress + objQuote.Invoice_Address__r.Zip_Postal_Code__c;
                    }
                    
                    strQuoteNumber = objQuote.Name;
                }
            }
            
            for(Opportunity newOpportunity:lstnewOpportunity)
            {
                if(objOpptyId == newOpportunity.Id)
                {
                    if(newOpportunity.Account.Name != null) strCustomerName = newOpportunity.Account.Name;
                    if(newOpportunity.Account.QWBS_Cust_ID__c != null) strCustomerIDNumber = newOpportunity.Account.QWBS_Cust_ID__c;
                    if(newOpportunity.Host_Information__r != null) strHostCompanyID = newOpportunity.Host_Information__r.Host_Company_ID__c;
                    if(newOpportunity.Contact__r != null && newOpportunity.Contact__r.Name != null) strShiptoContact = newOpportunity.Contact__r.Name;
                    if(newOpportunity.Contact__r != null && newOpportunity.Contact__r.Phone != null) strShiptoPhoneNumber = newOpportunity.Contact__r.Phone;
                    if(newOpportunity.Freight_Method__c != null) strFreightMethod = newOpportunity.Freight_Method__c;
                //  if(newOpportunity.Purchase_Order_Number__c != null) strPurchaseOrder = newOpportunity.Purchase_Order_Number__c;
                    if(newOpportunity.Id != null) strOpportunityLink = URL.getSalesforceBaseUrl().toExternalForm()+'/'+newOpportunity.Id;
                    if(newOpportunity.owner.Name != null) strOpportunityOwnerName = newOpportunity.owner.Name;
                    if(newOpportunity.owner.email != null) strOpportunityOwnerEmailAddress = newOpportunity.owner.email;
                    if(newOpportunity.Contact__r != null && newOpportunity.Contact__r.email != null) strContactEmailAddress = newOpportunity.Contact__r.email;
                }
            }
                 
            String strHtmlBody = '<html><body>This is a request to ship XRS Hardware and will be processed as-is \n'+
            '\nQuote Number: '+strQuoteNumber+
            '\nCustomer Name: '+strCustomerName+
            '\nCustomer ID Number (if known): '+strCustomerIDNumber+
            '\nHost Company ID: '+strHostCompanyID+
            '\nShip to Contact: '+strShiptoContact+
            '\nShip to Phone Number: '+strShiptoPhoneNumber+
            '\nShip to Address: '+strShipAddress+
            '\nBill to Address: '+strBillAddress+
            '\nFreight Method: '+strFreightMethod+
            '\nPurchase Order: '+strPurchaseOrder+
            '\nOpportunity Link: '+strOpportunityLink+
            '\nOpportunity Owner Name: '+strOpportunityOwnerName+
            '\nOpportunity Owner Email Address: '+strOpportunityOwnerEmailAddress+
            '\nContact Email Address: '+strContactEmailAddress+'\n\n'+
            strProduct+
            '</body></html>';
            String[] toAddresses = new list<string> {System.Label.XRS_Sales_order_Support};
            mail.setToAddresses(toAddresses);
            //mail.replyTo = ;
            mail.setSaveAsActivity(false);
            mail.setHtmlBody(strHtmlBody);
            mail.setSubject(strSubject);
            //mail.senderDisplayName = ;
        
            try
            {
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    
            }catch(Exception e)
            {
                System.debug('Email Sending Failed'+e);
            
            }  
        }
    }   
}