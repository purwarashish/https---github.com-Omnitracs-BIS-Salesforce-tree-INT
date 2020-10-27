/*@Description:Set notification type on contact if Account Status is Contract Customer
*/

trigger SetNotificationType on Contact (before insert) {

     /*BypassTriggerUtility u = new BypassTriggerUtility();  
     if (u.isTriggerBypassed()) {
         return;
     }
    
 //Create a set of all the unique contactIds and corresponding account ids
 set<Id> contactIds=new Set<Id>();  
 Set<Id> accountIds = new Set<Id>();
 
 


     for(Contact c: Trigger.New){
        contactIds.add(c.Id);
        accountIds.add(c.AccountId);
        }
        //Map Contact count for each Account 
        Map<Id,AggregateResult> accContCount = new Map<id,AggregateResult>([SELECT AccountId Id, COUNT(Id) ContactCount
                                                                            FROM Contact 
                                                                            WHERE Inactive__c=False AND AccountId != NULL AND AccountId in :accountIds
                                                                            GROUP BY AccountId]);
                                                
       
        //Get the Account Status for all accounts
        Map<Id,Account> accStatus=new Map<Id,Account>([SELECT QWBS_Status__c FROM Account WHERE Id in :accountIds]);
        System.debug('Account Status'+accStatus);    
        
        
        //Active partner accounts, all contacts will be subscribed to NewsLetter,Prod Info and Downtime notifications
           
             
     
 //Do all the notification updates
     for(Contact c:trigger.New){
          if(c.RecordTypeId=='01250000000QjBI'){
        //Active partner accounts, all contacts will be subscribed to News Letter,Product Info,Downtime/Degraded,Sr.Management and Time Change
        if(accStatus.get(c.AccountId).QWBS_Status__c=='Contract Customer')//Contract Customer
            c.Notification_Type__c= 'News Letter;Product Info;Downtime/Degraded;Sr.Management;Time Change';
        //partner accounts that are not contract customers yet will be subscribed to NewsLetter and Prod Info only 
            else 
            c.Notification_Type__c='Newsletter;Product Info';  
        }
    else {
    //logic for Direct Accounts
        if(c.RecordTypeId=='01250000000DQCm'||c.RecordTypeId=='01250000000DQCh'){
            //contract customer
             if(accStatus.get(c.AccountId).QWBS_Status__c=='Contract Customer'){
                //if first contact 
                if(accContCount.Size()>0){
                AggregateResult temp = accContCount.get(c.accountid);
                Integer tempCount = Integer.valueOf(temp.get('ContactCount'));
                System.debug('Contact Count is'+tempCount);
                if(tempCount>=1)//if not first customer
                    c.Notification_Type__c='Downtime/Degraded;Newsletter;Press;Product Info'; 
                    }
                //If first contact
                else
                    c.Notification_Type__c='Downtime/Degraded;Newsletter;Press;Product Info';
             }   
            
        else
        
            c.Notification_Type__c='Newsletter';          
        }
    }    
         
     }*/
     
 }