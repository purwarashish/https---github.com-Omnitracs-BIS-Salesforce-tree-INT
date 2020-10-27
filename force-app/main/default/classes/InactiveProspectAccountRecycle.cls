global class InactiveProspectAccountRecycle implements Database.Batchable<sObject>, Database.Stateful, Schedulable {

    String status;
    String PreviousOwner;
    String Account18DigitID;
    String AccountName;
    global String mailxlsContent = 'Account 18 Digit ID, Account Name, Previous Owner\n';
    global InactiveProspectAccountRecycle(){}
    
    global Database.QueryLocator start(Database.BatchableContext bc) 
    {
        system.debug('Start Called');
        return Database.GetQueryLocator('SELECT id, name, Parentid, Parent.QWBS_Status__c, QWBS_Status__c, QWBS_Market__c, createddate, Account_18_Digit_ID__c, Account_Owner_Change_Date__c, RecordType.Name, Owner.name, Account_Recycle_Date__c, (Select id, accountid, account.name, lastactivitydate, createddate, Stagename, Days_since_Last_Activity__c from opportunities where (Days_since_Last_Activity__c <= 90 OR (Days_since_Last_Activity__c = null AND CreatedDate = LAST_N_DAYS:90) OR CreatedDate = LAST_N_DAYS:90 OR StageName = \'Sales Complete\')) from Account where ((Account_Recycle_Date__c = Null AND QWBS_Status__c != \'Contract Customer\' AND QWBS_Status__c != \'Closed Contract Customer\' AND QWBS_Market__c != \'Other\' AND QWBS_Market__c != \'Intercomp\' AND RecordType.id != \'01250000000E5HG\' AND RecordType.id != \'01250000000E5L7\' AND RecordType.id != \'01250000000DTCp\' AND  RecordType.id != \'01250000000E5L9\' AND CreatedDate < LAST_N_DAYS:90 AND (Account_Owner_Change_Date__c < LAST_N_DAYS:90 OR Account_Owner_Change_Date__c = null)) OR (Account_Recycle_Date__c < LAST_N_DAYS:90 AND (Account_Owner_Change_Date__c < LAST_N_DAYS:90 OR Account_Owner_Change_Date__c = null) AND OwnerId != \'00550000006n9Hw\')) ORDER BY Createddate DESC ');
    }
    
    global void execute(Database.BatchableContext bc, List<Account> scope)
    {
        system.debug('Execute Called');
        list<Account> acclistToUpdate = new list<Account> ();
        list<Opportunity> optylistToUpdate = new list<Opportunity> ();
        Map<id,String>  oldOwnerName = new Map<id,String> ();
        for(Account acc: scope) 
        {
            Boolean isvalid = true;
            Account parentAcc = new Account ();
            parentAcc = acc;
            while (isvalid && parentAcc.parentId != null) 
            {
               
            	if(parentAcc.parent.QWBS_Status__c == 'Contract Customer') 
            	{
            		isvalid = false;
            	}
            	else
            	{
            		parentAcc = checkvalidAccount(parentAcc.parentid);
            	}
                
            }
            
            if(acc.opportunities.size() < 1 && isvalid) 
            {
                oldOwnerName.put(acc.id,acc.owner.name);
                acc.OwnerId = '00550000006n9Hw';
                acc.Account_Recycle_Date__c = System.Today();
                /*acc.QWBS_Market__c = 'Unassigned';
                acc.Region__c = '';*/
                acc.QWBS_Status__c = 'Inactive Prospect';
                acclistToUpdate.add(acc);
            }
        }
        
        list<Opportunity> oppty = new list<Opportunity>([select id, accountid, account.name, Stagename from opportunity where (accountid in: acclistToUpdate AND (Stagename != 'Closed won' OR Stagename != 'Closed Lost' OR Stagename != 'Sales Complete'))]);
        for(Opportunity opt: oppty) 
        {
        	opt.StageName = 'Closed Lost';
            opt.Reason_Lost__c = 'Data Cleanup';
            optylistToUpdate.add(opt);
        }
        
        if(acclistToUpdate.size() > 0) 
        {
        	//update Lists
        	Database.SaveResult[] srList = Database.update(acclistToUpdate,false);
            Database.SaveResult[] srListopt = Database.update(optylistToUpdate,false);
            
         	for (Integer i = 0; i < acclistToUpdate.size(); i++) 
            {
            	Database.SaveResult sr = srlist[i];
                Account OrigRecord = acclistToUpdate[i];
                if (sr.isSuccess()) 
                {
        			// Operation was successful, so get the ID of the record that was processed
        			System.debug('Successfully Updated account. Account ID: ' + sr.getId());
                  
                    status = sr.getId();
                    AccountName = OrigRecord.name;
                    PreviousOwner = oldOwnerName.get(sr.getId());
                    
    			}
    			else 
                {
        			// Operation failed, so get all errors                
        			for(Database.Error err : sr.getErrors()) 
                    {
           		 		status = 'Error Occured for '+ OrigRecord + '. '+ err.getStatusCode() + '. ' +err.getMessage();
                    	System.debug('The following error has occurred for' + OrigRecord);                    
            			System.debug(err.getStatusCode() + ' ' + err.getMessage()); 
        			} 
    			} 
                mailxlsContent += status +',' +AccountName +','+ PreviousOwner + '\n';
			}
        }
    }
    
    global void execute(SchedulableContext sc) 
    {
        InactiveProspectAccountRecycle myBatchObject = new InactiveProspectAccountRecycle();
        Database.executeBatch(myBatchObject, 10);
    }
    
    global void finish(Database.BatchableContext bc)
    {
        System.debug('Finish Called');
        String EmailBody = 'Hello,\n'+'Please see the attached files for details of the Inactive Prospect Account Recycle Update through automated batch processing.\n\n'+'Thanks,\n'+'SFDC Team';
        Blob xlsBlob = Blob.valueOf(mailxlsContent);
        Messaging.EmailFileAttachment xlsAttach = new Messaging.EmailFileAttachment();
        xlsAttach.setFileName('Inactive Prospect Account Recycle_results.csv');
        xlsAttach.setContentType('text/csv');
        xlsAttach.setBody(xlsBlob);
        //Create Email      
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'omnitracs.sfdc.noreply@omnitracs.com'];
        if(owea.size() > 0)
        {
            email.setOrgWideEmailAddressId(owea.get(0).Id);
        }
        else
        {
            email.setSenderDisplayName('Update Account - Inactive Prospect Account Recycle Job');
        }
        String[] toAddresses = new List<String> {'Sales.ops@omnitracs.com'};
        String[] ccAddresses = new List<String> {'skrishna@omnitracs.com'};
        email.setSubject('Inactive Prospect Account Recycle Status');       
        email.setToAddresses(toAddresses);
       	email.setCcAddresses(ccAddresses);        
        email.setFileAttachments(new Messaging.EmailFileAttachment[]{xlsAttach});
        email.setPlainTextBody(EmailBody);
        Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
    	
    }   
    
    global account checkvalidAccount(id parentaccid) 
    {
       
        List<Account> parentacc = new List<Account> ();
        parentacc = [select id, QWBS_Status__c, parent.QWBS_Status__c,parentid from account where id=:parentaccid];
        
        if(parentacc.size() > 0) 
        {
            return parentacc[0];
        }
        return null;
    }
}