global class AssignToDirectSalesController{
    static List<Opportunity> lstOpportunity = new List<Opportunity>();
    Static SavePoint sp;
    webservice static void assignToDirectSales(String acctId){
        system.debug('@@account id'+ acctId);
        
        List<Account> lstAccount = [Select 
                                        id,
                                        name, 
                                        recordTypeId, 
                                        Partner_Agent__c, 
                                        ownerId,
                                        
                                        owner.email,
                                        QWBS_Market__c,
                                        Carrier_Type__c,
                                        Account_Manager__c,
                                        /*District__c,*/
                                        Account_Manager__r.email,
                                        RecordOwner__c,
                                        (Select Id,Subject,ownerId,IsTask From OpenActivities) 
                                    From 
                                        Account
                                    where 
                                        id= :acctId
                                    limit 1];
       if(lstAccount != null && !lstAccount.isEmpty()){
           lstAccount[0].recordtypeId = system.label.T_L_Sales_Accounts_RecType_Id;
           lstAccount[0].ownerId =  lstAccount[0].Account_Manager__c;
           
           lstAccount[0].RecordOwner__c = null;
           lstAccount[0].Partner_Agent__c = null;
           if(lstAccount[0].Carrier_Type__c == 'For-Hire' || lstAccount[0].Carrier_Type__c == null)
               lstAccount[0].QWBS_Market__c = 'T&L';
           else
               lstAccount[0].QWBS_Market__c = 'Private Fleet';
           sp  = Database.setSavepoint();
           try{
               //lstAccount[0].Mass_Transfer_Of_Related_Records__c = true;
               update lstAccount[0];
               
               //send email notification to owner
               Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setUseSignature(false); 
                List<String> lstMailIds = new List<String>();
                system.debug('To address:::'+lstAccount[0].Account_Manager__r.email );
                lstMailIds.add(lstAccount[0].Account_Manager__r.email);
                mail.setToAddresses(lstMailIds);
                mail.setSubject('Account transferred to you.');
                String mailContent = '';
                If(lstAccount[0] != null)
                { 
                     mailContent = mailContent + '<br/>';
                     mailContent = mailContent + 'Account '+ lstAccount[0].name  + ' has been assigned to you. Please click on the link below to view the record.';
                     String url = System.Label.Email;
                     mailContent = mailContent + '<br/><a href="'+url+lstAccount[0].id+'">'+url+lstAccount[0].id+'</a>';
                     mail.setHtmlBody(mailContent);
                     mail.setWhatId(lstAccount[0].id);
                     mail.setSaveAsActivity(true);
                     Messaging.sendEmail(new Messaging.SingleEmailMessage[]
                     {
                          mail
                     }
                   );       
                }
                
                  
               //transfer ownership of related record
               transferopportunities(acctId, lstAccount[0].Account_Manager__c);
               transferContact(acctId, lstAccount[0].Account_Manager__c);
               transferOpenActivities(lstAccount[0]);
               
               //lstAccount[0].Mass_Transfer_Of_Related_Records__c = false;
               update lstAccount[0];
           }
           catch(Exception e){
               Database.rollback(sp);
               system.debug('@@@@@Exception occured'+e.getMessage());    
           }
               
           
           
        }
        
    }
     
    public static void transferopportunities(String acctId, Id accntOwnerId){
        lstOpportunity = [Select 
                             AccountId,
                             ownerId,
                             name,
                             recordtypeId 
                         From 
                             Opportunity
                          where 
                              AccountId = :acctId
                          And
                              isClosed = False
                          limit 50000
                       ]; 
         if(!lstOpportunity.isEmpty()){
             for(Opportunity opp:lstOpportunity){
                 opp.ownerId = accntOwnerId;
                 opp.recordtypeId = system.label.Opportunity_Transportation_Logistic;
                 
             }   
             try{
                 update lstOpportunity;
             } 
             catch(Exception e){
             Database.rollback(sp);
                 system.debug('@@@@@Exception occured'+e.getMessage());
             }
         } 
         
                         
    }
    public static void transferContact(String acctId, Id accntOwnerId){
         List<Contact> lstContact = new List<Contact>();
         lstContact = [Select 
                             AccountId,
                             ownerId,
                             id,
                             name 
                         From 
                             contact
                          where 
                              AccountId = :acctId
                          limit 50000
                       ];
     if(!lstContact.isEmpty()){
          for(contact cont:lstContact){
              cont.ownerId = accntOwnerId;    
          }
          try{    
             update lstContact;
             }
             catch(exception e)
             {
               Database.rollback(sp);
               system.debug('Error in transferring contacts: ' + e.getMessage());
         } 
          
     }
      
        
    }
    public static void transferOpenActivities(Account currentAccount){
         list<string> lstTaskIds = new list<string>();
         list<Task> lstTask = new list<Task>();
         list<string> lstEventIds = new list<string>();
         list<Event> lstEvent = new list<Event>();  
         if(currentAccount.openActivities != null && currentAccount.openActivities.size() > 0)
         {
                    
             for(integer i=0;i<currentAccount.openActivities.size();i++)
             {
                 if(currentAccount.openActivities[i].isTask == true)
                 {
                     lstTaskIds.add(currentAccount.openActivities[i].id);     
                 }
                 else
                 {
                     lstEventIds.add(currentAccount.openActivities[i].id);
                 }
             }
                if(lstTaskIds != null && lstTaskIds.size() >0)
                {
                    lstTask = [select 
                                                id,
                                                ownerId,
                                                subject
                                            from
                                                Task
                                            where 
                                                id IN :lstTaskIds];
                    if(lstTask !=null && lstTask.size() > 0)
                    {
                        for(task records:lstTask)
                        {
                            records.ownerId = currentAccount.Account_Manager__c;   
                        }
                                   
                        try
                        {
                            update lstTask;
                        }
                        catch(Exception e)
                        {
                          Database.rollback(sp);
                          system.debug('Error in transferring tasks: ' + e.getMessage());
                        }    
                    }   
                    }
                    if(lstEventIds!= null && lstEventIds.size() >0)
                    {
                        lstEvent = [select 
                                                      id,
                                                      ownerId,
                                                      subject
                                                from
                                                      Event
                                                where 
                                                       id IN :lstEventIds];
                        if(lstEvent !=null && lstEvent.size() > 0)
                        {
                            for(Event records:lstEvent)
                            {
                                records.ownerId = currentAccount.Account_Manager__c;   
                            }
                            try
                            {
                                update lstEvent;
                            }
                            catch(Exception e)
                            {
                              Database.rollback(sp);
                              system.debug('Error in transferring events: ' + e.getMessage());
                            }    
                        } }} 
                         
    }
}