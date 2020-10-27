/*****************************************************************************************************************************************************
Name	: UpdateAccountPrimaryProduct
Purpose	: To update the primary product field in account with the product which is generating highest revenue at the latest
Author	: Sai Krishna Kakani
Date	: 15th March 2019 
******************************************************************************************************************************************************/
global class UpdateAccountPrimaryProduct implements Database.Batchable<sObject>, Database.Stateful, Schedulable {
    String status = 'Account Updated Successfully';
    String Market;
    global String mailxlsContent = 'Primary Product Update Status, Market\n';
    global UpdateAccountPrimaryProduct(){}
    
    list<Revenue__c> revlist = new List<Revenue__c>(); 
    public Set<id> accIDset;    
    global Integer recordsProcessed = 0;
    global Database.QueryLocator start(Database.BatchableContext bc) {
        system.debug('Start Called');
     	//Date Newdate = Date.today().adddays(-45);
     	String rectype = 'Recurring';
        List<String> ProductLines = new List<String>{'MCP50','MCP110','Omnitracs IVG','XRS','XTP','XN','MCP100S','RNA - Roadnet Anywhere','MCP200','MCP100T','RTS','Roadnet Telematics','RNA','RDC','RNT - Telematics','RTS - Transportation Services'};
       	//return Database.GetQueryLocator('SELECT id,name, (SELECT id,Account__c, Account__r.name, Product_Line__c, Invoice_Date__c, net_revenue__c FROM Revenue__r Where (type__c =: rectype AND Product_Line__c=:ProductLines) ORDER By Account__r.name ASC, Invoice_Date__c DESC, Net_Revenue__c DESC, Billed_Units__c DESC  limit 1) from account where (id IN(select account__c from revenue__c Where type__c =: rectype AND Product_Line__c=:ProductLines) and primary_product__c = null)');
        return Database.GetQueryLocator('SELECT id,name, qwbs_market__c, (SELECT id,Account__c, Account__r.name, type__c, Product_Line__c, Invoice_Date__c, net_revenue__c FROM Revenue__r Where (type__c =: rectype AND Product_Line__c=:ProductLines) ORDER By Account__r.name ASC, Invoice_Date__c DESC, Net_Revenue__c DESC, Billed_Units__c DESC limit 1) from account where (id IN(select account__c from revenue__c Where (type__c =: rectype AND Product_Line__c=:ProductLines)) AND QWBS_Market__c != \'New Business\')');
        //return Database.GetQueryLocator('SELECT id,name, (SELECT id,Account__c, Account__r.name, Product_Line__c, Invoice_Date__c, net_revenue__c FROM Revenue__r Where (type__c =: rectype AND Product_Line__c=:ProductLines) ORDER By Account__r.name ASC, Invoice_Date__c DESC, Net_Revenue__c DESC, Billed_Units__c DESC limit 1) from account where id IN(select account__c from revenue__c where (createddate >= :Newdate AND type__c =: rectype AND Product_Line__c=:ProductLines))');
    }
    global void execute(Database.BatchableContext bc, List<Account> scope){
        system.debug('Execute Called');
        list<Account> acclistToUpdate = new list<Account> ();  
        for(Account acc : scope) 
		{
            if(acc.revenue__r != null && acc.revenue__r.size() > 0) {
                acc.Primary_Product__c=acc.revenue__r[0].product_line__c;
                acclistToUpdate.add(acc);
            }
        }
		 
        if(acclistToUpdate.size() > 0) {
        //update acclistToUpdate;
        	Database.SaveResult[] srList = Database.update(acclistToUpdate,false);
         	for (Integer i = 0; i < acclistToUpdate.size(); i++) {
            	Database.SaveResult sr = srlist[i];
                Account OrigRecord = acclistToUpdate[i];
                if (sr.isSuccess()) {
        			// Operation was successful, so get the ID of the record that was processed
        			System.debug('Successfully Updated account. Account ID: ' + sr.getId());
                    status = 'Successfully Updated Account. Account ID:' + sr.getId();
                    Market = OrigRecord.QWBS_Market__C;
    			}
    			else {
        			// Operation failed, so get all errors                
        			for(Database.Error err : sr.getErrors()) {
           		 	status = 'Error Occured for '+ OrigRecord + '. '+ err.getStatusCode() + '. ' +err.getMessage();
                    System.debug('The following error has occurred for' + OrigRecord);                    
            		System.debug(err.getStatusCode() + ' ' + err.getMessage()); 
        			} 
    			} mailxlsContent += status + ',' + Market + '\n';
			}
        }
    }
    
    global void execute(SchedulableContext sc) {
        UpdateAccountPrimaryProduct myBatchObject = new UpdateAccountPrimaryProduct();
        Database.executeBatch(myBatchObject, 10);
    }
        
    global void finish(Database.BatchableContext bc){
    	System.debug('Finish Called');
        String EmailBody = 'Please see the attached files for details of the Primary product Update through automated batch processing.';
        Blob xlsBlob = Blob.valueOf(mailxlsContent);
        Messaging.EmailFileAttachment xlsAttach = new Messaging.EmailFileAttachment();
        xlsAttach.setFileName('PrimaryProductinAccountUpdate_results.csv');
        xlsAttach.setContentType('text/csv');
        xlsAttach.setBody(xlsBlob);
        //Create Email      
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'omnitracs.sfdc.noreply@omnitracs.com'];
        if(owea.size() > 0){
            email.setOrgWideEmailAddressId(owea.get(0).Id);
        }else{
            email.setSenderDisplayName('Update Account - Primary Product Job Status');
        }
        String[] toAddresses = new List<String> {UserInfo.getUserEmail()};
        //String[] ccAddresses = new List<String> {'skrishna@omnitracs.com'};
        String[] ccAddresses = new List<String> {'skrishna@omnitracs.com','weisheit@omnitracs.com','Sales.ops@omnitracs.com','cdaville@omnitracs.com'};
       	//String[] toAddresses = new List<String> {'skrishna@omnitracs.com'};
        email.setSubject('Primary Product in Account Update Status');       
        email.setToAddresses(toAddresses);
       	email.setCcAddresses(ccAddresses);        
        email.setFileAttachments(new Messaging.EmailFileAttachment[]{xlsAttach});
        email.setPlainTextBody(EmailBody);
        Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
    }   
}