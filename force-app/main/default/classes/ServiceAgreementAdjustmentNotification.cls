/* Date : 6/25/2015
   Author : Abhishek Dey
   Functionality :
    This apex code will 
      -fetch specific contact records from the account associated with the contact for Service Agreement Adjustment(SAA) records
      -fetch specicic account address from the account associated with the contact for Service Agreement Adjustment(SAA) records
    the details will be added back to the SAA records
*/    

global class ServiceAgreementAdjustmentNotification {
  @InvocableMethod(label='Send Email')
  global static void sendEmail(List<Service_Agreement_Adjustment__c> serviceAgreementRequests) {
  
    list<id> lstSAAMapping = new list<id>();
    Map<id,id> accountMapping = new Map<id,id>();
    Map<id,id> sAAContactMapping = new Map<id,id>();
    Map<id,Address__c> sAAAddressMapping = new Map<id,Address__c>();
    
    Map<id,Address__c> accountAddressMapping = new Map<id,Address__c>();
    list<Service_Agreement_Adjustment__c> lstUpdate = new list<Service_Agreement_Adjustment__c>();
    
    
    for (Service_Agreement_Adjustment__c request : serviceAgreementRequests) {
     
      lstSAAMapping.add(request.account_Id__c);  
    }
    
  
   for(account accountData :[select id ,(select id from contacts where Notification_Type__c includes ('Price Increase') limit 1),
                                            (select  Account__c, id,Address_Line_1__c,
                                             Address_Line_2__c,
                                             City__c,
                                             State_Province__c,
                                             Zip_Postal_Code__c
                                             from Addresses__r where Location_Type__c = 'Corporate HQ' OR Location_Type__c = 'Notice Address - Primary' limit 1) 
                                             
                                             from account where id IN :lstSAAMapping ])
    {
      if(!accountData.contacts.isEmpty())
      {
      accountMapping.put(accountData.id,accountData.contacts[0].id);
      }
      if(!accountData.Addresses__r.isEmpty())
     {
       accountAddressMapping.put(accountData.id,accountData.Addresses__r[0]);
     }
    }
   
    
    for( Service_Agreement_Adjustment__c updateSAA : serviceAgreementRequests )
    {
        if(accountMapping.containsKey(updateSAA.account_Id__c))
        sAAContactMapping.put(updateSAA.id,accountMapping.get(updateSAA.account_Id__c));
        
        if(accountAddressMapping.containsKey(updateSAA.account_Id__c))
        sAAAddressMapping.put(updateSAA.id,accountAddressMapping.get(updateSAA.account_Id__c));
        
    }   
    
    for( Service_Agreement_Adjustment__c updateSAA : serviceAgreementRequests )
    {
        if((sAAContactMapping.containsKey(updateSAA.id))||(sAAAddressMapping.containskey(updateSAA.id)))
        {
                String address = '';
                Service_Agreement_Adjustment__c upsertSAA = new Service_Agreement_Adjustment__c(id= updateSAA.id);
            
            
            if(sAAContactMapping.containsKey(updateSAA.id))
            {
                upsertSAA.Contact__c = sAAContactMapping.get(updateSAA.id);
            }
            
            if(sAAAddressMapping.containskey(updateSAA.id))
            {
                        Address__c updateViaAddress = new Address__c();
                        updateViaAddress = sAAAddressMapping.get(updateSAA.id);
                       
                        
                       // Abhishek Modified the logic of Contact Address 1 population based on case - # 2102606 
                        if((updateViaAddress.Address_Line_2__c != null)&&(updateViaAddress.Address_Line_2__c != ''))
                         {
                             upsertSAA.Contact_Address_1__c = updateViaAddress.Address_Line_1__c + ', ' + updateViaAddress.Address_Line_2__c ;
                             
                         }
                        else
                         {
                         upsertSAA.Contact_Address_1__c = updateViaAddress.Address_Line_1__c;
                         }
                     
                      
                         if(updateViaAddress.City__c != null)
                         {
                             address = updateViaAddress.City__c;
                         }
                         if(updateViaAddress.State_Province__c != null)
                         {
                             if (address != '')
                             address = address +', ' + updateViaAddress.State_Province__c;
                             else
                             address = updateViaAddress.State_Province__c;
                         }
                         if(updateViaAddress.Zip_Postal_Code__c != null)
                         {
                             if (address != '')
                             address = address + ' ' + updateViaAddress.Zip_Postal_Code__c ;
                             else
                             address = updateViaAddress.Zip_Postal_Code__c ;
                         }
                        
                        upsertSAA.Contact_Address_2__c = address;
            }
            
             lstUpdate.add(upsertSAA);
        }
    }   
    
    if(!lstUpdate.isEmpty())
    {
        upsert lstUpdate;
    }
   
  } 
  }