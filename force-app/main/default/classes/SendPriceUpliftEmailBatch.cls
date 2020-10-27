/***************************************************************************************************
Name     : SendPriceUpliftEmailBatch 
Objective: Batch class to send price uplift notifications to customers. This is called from ServiceAgreementAdjustmentUtils class
Author   : Rittu Roy
Date     : 3/2/2016

****************************************************************************************************/
global class SendPriceUpliftEmailBatch implements Database.Batchable<Service_Agreement_Adjustment__c>{
    
    public static final string NOTIFICATION_SENT_STATUS = 'Notification Sent';
    List<Service_Agreement_Adjustment__c> lstSAAs = new List<Service_Agreement_Adjustment__c>();
    List<Messaging.SingleEmailMessage> lstMails;
    List<Service_Agreement_Adjustment__c> lstSAAToUpdate;//SAA records whose status needs to be updated
    Map<Id,Service_Agreement_Adjustment__c> newMap = new Map<Id,Service_Agreement_Adjustment__c>();
    List<Id> lstSAAIds;
    String notificationTemplateId = '';
    String addntlRecipients = '';
    
    global SendPriceUpliftEmailBatch(List<Service_Agreement_Adjustment__c> lstSAAs,Map<Id,Service_Agreement_Adjustment__c> newMap, String templateId)
    {
        this.lstSAAs = lstSAAs;
        this.newMap = newMap;
        notificationTemplateId = templateId;
        
        //Gets additional recipients from custom settings
        if (Global_Variable__c.getInstance('SAA_PriceUplift_AddntlRecps') != null && String.isNotBlank(Global_Variable__c.getInstance('SAA_PriceUplift_AddntlRecps').Value__c)){
            addntlRecipients = Global_Variable__c.getInstance('SAA_PriceUplift_AddntlRecps').Value__c;
        }
    }

    global Iterable<Service_Agreement_Adjustment__c> start(Database.BatchableContext BC)
    {
        return lstSAAs;
    }
    
    global void execute(Database.BatchableContext BC,List<Service_Agreement_Adjustment__c> scope)
    {
        lstMails = new List<Messaging.SingleEmailMessage>();
        lstSAAToUpdate = new List<Service_Agreement_Adjustment__c>();
        lstSAAIds = new List<Id>();
        List<Messaging.SendEmailResult> results;
        
        //Frames the email
        for (Service_Agreement_Adjustment__c SAAObj : scope){
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setWhatId(SAAObj.Id);
            mail.setTemplateId(Id.valueOf(notificationTemplateId));
            mail.setSaveAsActivity(true);
            mail.setTargetObjectId(SAAObj.Fee_Increase_Contact__c);
            
            if (String.isNotBlank(addntlRecipients)){
                mail.setCCAddresses(addntlRecipients.split(';',0));
            }
            
            lstMails.add(mail);
            lstSAAIds.add(SAAObj.Id);   
        }
        
        //Sends emails
        if (!lstMails.isEmpty()){
           try{
               results = Messaging.sendEmail(lstMails, false);
           }Catch(Exception e){System.debug ('Error thrown: ' + e.getMessage());}
        
            //Update SAA Status and Notification send date only if email is sent successfully. Otherwise, throw error
            for(Integer i=0;i < results.size();i++){
                if (results[i].isSuccess()){
                    Service_Agreement_Adjustment__c SAAObj = new Service_Agreement_Adjustment__c(Id=lstMails.get(i).getWhatId());
                    SAAObj.SAA_Status__c =  NOTIFICATION_SENT_STATUS;
                    SAAObj.Email_Sent_Date__c =  System.Now(); 
                    lstSAAToUpdate.add(SAAObj);
                }
                //Else, Throw error
                else{
                    Service_Agreement_Adjustment__c SAAObj = newMap.get(lstMails.get(i).getWhatId());
                    SAAObj.AddError('Email not sent: '+ results[i].getErrors()[0].getMessage());
                }           
            }
        }
        
        //Update SAA records for which email has been sent
        if (!lstSAAToUpdate.isEmpty()){
            try{
                update lstSAAToUpdate;    
            }Catch(Exception e){System.debug ('Error thrown: ' + e.getMessage());}
        }
        
    }
    
    global void finish(Database.BatchableContext BC)
    {
       
    }

}