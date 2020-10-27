/***************************************************************************************************
Name     : ServiceAgreementAdjustmentUtils
Objective: Utils class for all code related to Service Agreement Adjustment object
Author   : Rittu Roy
Date     : 2/8/2016

****************************************************************************************************/
public class ServiceAgreementAdjustmentUtils{
    
    /*Sends uplift notification to customers when 'Send Email' checkbox is checked*/
    public static void sendUpliftNotification(Map<Id,Service_Agreement_Adjustment__c> newMap, Map<Id,Service_Agreement_Adjustment__c> oldMap){
        List<Service_Agreement_Adjustment__c> lstSAAsToNotify = new List<Service_Agreement_Adjustment__c>();//SAA records for which notification has to be sent
        String notificationTemplateId = '';
        String batchSize = '';//batch size for batch apex job
        
        //Gets template Id from custom settings
        if (Global_Variable__c.getInstance('SAA_PriceUplift_TemplateId') != null && String.isNotBlank(Global_Variable__c.getInstance('SAA_PriceUplift_TemplateId').Value__c)){
            notificationTemplateId = Global_Variable__c.getInstance('SAA_PriceUplift_TemplateId').Value__c;
        }
        
        //Gets batch size from custom settings
        if (Global_Variable__c.getInstance('SAA_PriceUplift_BatchSize') != null && String.isNotBlank(Global_Variable__c.getInstance('SAA_PriceUplift_BatchSize').Value__c)){
            batchSize = Global_Variable__c.getInstance('SAA_PriceUplift_BatchSize').Value__c;
        }
       
        for (Service_Agreement_Adjustment__c SAAObj : newMap.values()){
            if(
            ((oldMap != null && oldMap.get(SAAObj.Id).Email_Sent__c == false) || (oldMap == null )) && //On insert or update. If update, prior value of Email_Sent__c should be false
            (SAAObj.SAA_Status__c == 'New' || SAAObj.SAA_Status__c == 'Email Bounce Back') &&
            (SAAObj.Email_Sent__c == true && SAAObj.Contact__c != null && String.isNotBlank(SAAObj.Contact_Address_1__c) && String.isNotBlank(SAAObj.Contact_Address_2__c)) &&
            String.isNotBlank(notificationTemplateId)
            ){
                lstSAAsToNotify.add(SAAObj);
                
            }
        }
        
        //Call batch job to send email
        if (!lstSAAsToNotify.isEmpty() && String.isNotBlank(batchSize)){
            SendPriceUpliftEmailBatch controller = new SendPriceUpliftEmailBatch(lstSAAsToNotify,newMap,notificationTemplateId ) ;  
            database.executebatch(controller);  
        }
    }
	
	//Case #02275674, Sripathi Gullapalli, Method to update Last Uplifted Date on Contract from SAA when the Uplift Effective Date has been updated
	public static void updateContract(Map<Id,Service_Agreement_Adjustment__c> newMap, Map<Id,Service_Agreement_Adjustment__c> oldMap){
		Boolean isInsert = (oldMap == null || oldMap.size() == 0)?true:false;
		Map<Id, Contract> updateContractMap = new Map<Id, Contract>();
		try{
	    	for (Service_Agreement_Adjustment__c newSAA : newMap.values()){
	    		Service_Agreement_Adjustment__c oldSAA = isInsert ? null : oldMap.get(newSAA.Id);
			 	if(newSAA.Contract__c != null && newSAA.Uplift_Effective_Date__c != null && (isInsert || (oldSAA != null && newSAA.Uplift_Effective_Date__c != oldSAA.Uplift_Effective_Date__c))){
			 		updateContractMap.put(newSAA.Contract__c, new Contract(Id=newSAA.Contract__c, Last_Uplifted_Date__c = newSAA.Uplift_Effective_Date__c));
			 	}
		    }
		    
		    if(updateContractMap.size() > 0){
		    	Database.Update(updateContractMap.values());
		    }
		}catch(Exception e){
			System.debug('******************EXCEPTION OCCURED WHILE UPDATING CONTRACT IN SAA -- '+e.getMessage());
		}
	}
}