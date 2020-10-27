/*********************************************************************
Name    : emailUtilsInt
Author  : David Ragsdale
Date    : 28 Feb 2011 
Usage   : Contains logic for sending a reminder message to
          all approvers on a solution when the solution is pending 
          and has not been approved or rejected within the last 7 days.
           
          NOTE:  Sending mass emails has limits.  You can only call sendMail() 10 times in one
                 thread of execution.  Also, the MassEmail message can only send an email
                 to 250 users at one time.
*********************************************************************/
global class EmailUtilsInt {
    
//**************************************************************************************
// sendDailyCaseReminderEmail()
// Queries the system for all solution that are pending approval and sends a reminder email to 
// those listed as a solution approver if the solution has not been either approved
// or rejected within the last 7 days.
//**************************************************************************************/

    //@future    
    public static void sendDailyCaseReminderEmail (){  
        //CONSTANT
        string ORGWIDEEMAILID = '0D250000000TO5S';
        
        List <Case> lstCasesToUpdate = new List<Case>();
        
        string tmpSubject = 'REMINDER - Approval Required';
        string tmpBody = '';  
        
        DateTime oneDayAgo = DateTime.Now();
        DateTime twoDaysAgo = DateTime.Now();
       
        //Look 1 day in the past
        oneDayAgo = oneDayAgo.addDays(-1);

        //Look 2 Days in the past
        twoDaysAgo = twoDaysAgo.addDays(-2);

        List<Case> lstCase = new List<Case> (
            [SELECT 
                id, 
                CaseNumber, 
                Subject,
                AccountId,
                RecordTypeId, 
                Pending_Approval_Reminder_Date__c,
                hdnBaseURL__c
            FROM Case
            WHERE 
                SubStatus__c = 'Pending Approval' 
                AND Pending_Approval_Reminder_Date__c <= :oneDayAgo 
                AND CreatedDate > :System.now() -60
            LIMIT 10]);  

        for ( Case aCase :lstCase ) 
        { 
            List<CasePendingReminderEmailRecType__c> lstRecTypeId = 
                [SELECT RecTypeId__c from CasePendingReminderEmailRecType__c 
                WHERE RecTypeId__c = :aCase.RecordTypeId LIMIT 1
                ];


            if (lstRecTypeId.size() > 0)
            {
                //if flag = false - send email
                if (aCase.Pending_Approval_Reminder_Date__c < oneDayAgo)
                {
                    // Get the list of approvers for this CR
                    List<ProcessInstanceWorkItem> lstPIWI = new List<ProcessInstanceWorkItem> ([
                        SELECT 
                            actorId 
                        FROM 
                            ProcessInstanceWorkItem 
                        WHERE 
                            processinstanceid 
                            In (
                            SELECT 
                                Id 
                            FROM 
                                ProcessInstance 
                            WHERE 
                                status = 'Pending' 
                            AND 
                                TargetObjectId = :aCase.Id)]);
    
                    if ( lstPIWI.size() > 0 ) 
                    {
                        // This is the list of users who should receive an email. 
                        //Now we need to get their actual 
                        // email addresses from their User record
                        Set<Id> setUserIds = new Set<Id>();
            
                        for( ProcessInstanceWorkItem p :lstPIWI )
                        {
                            setUserIds.add(p.actorId);
                        } //end for
              
                        // Get the actual email addresses from the list of userIds
                        List<User> lstUsers = new List<User> ([
                            SELECT email 
                            FROM User
                            WHERE Id In :setUserIds]);

                        // Construct the email message
                        String strEmailTo = '';  
                        String[] toAddressList  = new String[]{};
              
                        Messaging.SingleEmailMessage objMail = new Messaging.SingleEmailMessage();
                        objMail.setReplyTo('qes.sfdc.noreply@qualcomm.com');
                        objMail.setOrgWideEmailAddressId(ORGWIDEEMAILID);
                        objMail.setSaveAsActivity(false); 
                        objMail.setSubject(tmpSubject);            
                
                        /**************************************************
                        ***CREATE EMAIL BODY
                        **************************************************/
                        tmpBody = '*** Case APPROVAL REMINDER NOTICE *** DO NOT REPLY TO THIS EMAIL ***\n\n'; 
                        tmpBody += '\nYou are receiving this email because you are a member of the approval group for the following Case which is waiting for approval.';
                        tmpBody += '\n\nPlease take a moment to review this Case and either approve or reject it.';
                        tmpBody += '\n\n';
                        tmpBody += 'Case #: ';
                        tmpBody += aCase.CaseNumber; 
                        tmpBody += '\nSubject: ';
                        tmpBody += aCase.Subject; 
                        tmpBody += '\n\nIf you are already logged in to Salesforce, you can View or Update this Case here: ';
                        tmpBody += aCase.hdnBaseURL__c + '/';
                        tmpBody += aCase.Id; 
                        tmpBody += '\n\nOtherwise, first use this link to log in to Salesforce: https://login.salesforce.com';
                        /***************************************************/
          
                        objMail.setPlainTextBody(tmpBody);
                  
                        Integer count = 0;              
                
                        for(User aUser :lstUsers)
                        {
                            // Per the documentation about single email, a single email can only have 100 recipients
                            if ( count < 100 )
                            {
                                toAddressList.add(aUser.email);
                                count += 1;
                            }else {
                                // Need to send this batch of emails out
                                // Add the last email address from the loop above to the list
                                toAddressList.add(aUser.email);                   
                                if (toAddressList.size() > 0)
                                {
                                    objMail.setToAddresses(toAddressList);       
                    
                                    // Send out this email with 100 recipients or less
                                    Messaging.sendEmail(new Messaging.SingleEmailMessage[] { objMail });
                                }
                                toAddressList.clear();
                                count=0;
                            } //end if 
                        }//end for

                        // send the remaining batch out    
                        if (toAddressList.size() > 0)
                        {
                            objMail.setToAddresses(toAddressList);        
                            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { objMail });
                        } 

                        // Reset the date/time until this solution is either approved or rejected
                        aCase.Pending_Approval_Reminder_Date__c = DateTime.Now(); 
                    }//end if
                    
                    lstCasesToUpdate.add(aCase);
                }//end if
            }//end if
        }//end for
  
        // Update the Case with a new approval reminder time
        if (lstCasesToUpdate.size() > 0)
        {
            update lstCasesToUpdate;
        }
    }

/***************************************************************
  OLD METHODS
****************************************************************/
/**************************************************************************************
// send7DayCRReminderEmail()
// Queries the system for all solution that are pending approval and sends a reminder email to 
// those listed as a solution approver if the solution has not been either approved
// or rejected within the last 7 days.
//**************************************************************************************/

    //@future 
/*    public static void send7DayCRReminderEmail (){  
        string tmpSubject = 'REMINDER - Approval Required';
        string tmpBody = '';  
        
        DateTime sevenDaysAgo = DateTime.Now();
        DateTime oneDayAgo = DateTime.Now();
    
        List<Contract_Request__c> lstCR = new List<Contract_Request__c> ([
            SELECT 
                id, 
                Name, 
                Account__c, 
                Contact__c,
                Pending_Approval_Reminder_Date__c,
                X7DayApprovalSent__c,
                hdnBaseURL__c
            FROM Contract_Request__c
            WHERE System_Status__c = 'Pending Approval' 
                AND (Pending_Approval_Reminder_Date__c <= :sevenDaysAgo 
                OR (Pending_Approval_Reminder_Date__c <= :oneDayAgo 
                AND X7DayApprovalSent__c = true))
            LIMIT 10]);

        for ( Contract_Request__c aCR :lstCR ) 
        { 
            // Get the list of approvers for this CR
            List<ProcessInstanceWorkItem> lstPIWI = new List<ProcessInstanceWorkItem> ([
                SELECT actorId 
                FROM ProcessInstanceWorkItem 
                WHERE processinstanceid In 
                    (SELECT Id FROM ProcessInstance WHERE status = 'Pending' and TargetObjectId = :aCR.Id)]);
    
            if ( lstPIWI.size() > 0 ) 
            {
                // This is the list of users who should receive an email. 
                //Now we need to get their actual 
                // email addresses from their User record
                Set<Id> setUserIds = new Set<Id>();
            
                for( ProcessInstanceWorkItem p :lstPIWI ){
                    setUserIds.add(p.actorId);
                }
              
                // Get the actual email addresses from the list of userIds
                List<User> lstUsers = new List<User> ([
                    SELECT email 
                    FROM User
                    WHERE Id In :setUserIds]);

                // Construct the email message
                String strEmailTo = '';  
                String[] toAddressList  = new String[]{};
              
                Messaging.SingleEmailMessage objMail = new Messaging.SingleEmailMessage();
                objMail.setReplyTo('qes.sfdc.noreply@qualcomm.com');
                objMail.setSenderDisplayName('QES SFDC Support - No Reply');
                objMail.setSaveAsActivity(false); 
                objMail.setSubject(tmpSubject);            
                
                /**************************************************
                ***CREATE EMAIL BODY
                **************************************************/
/*                tmpBody = '*** Case APPROVAL REMINDER NOTICE *** DO NOT REPLY TO THIS EMAIL ***\n\n'; 
                tmpBody += '\nYou are receiving this email because you are a member of the approval group for the following CR which is waiting for approval.';
                tmpBody += '\n\nPlease take a moment to review this CR and either approve or reject it.';
                tmpBody += '\n\n';
                tmpBody += 'CR Name: ';
                tmpBody += aCR.Name; 
                //tmpBody += '\nSubject: ';
                //tmpBody += aCase.Subject; 
                tmpBody += '\n\nIf you are already logged in to Salesforce, you can View or Update this Case here: ';
                tmpBody += aCR.hdnBaseURL__c + '/';
                tmpBody += aCR.Id; 
                tmpBody += '\n\nOtherwise, first use this link to log in to Salesforce: https://login.salesforce.com';
                /***************************************************/
          
/*                objMail.setPlainTextBody(tmpBody);
                  
                Integer count = 0;              
                
                for(User aUser :lstUsers)
                {
                    // Per the documentation about single email, a single email can only have 100 recipients
                    if ( count < 100 )
                    {
                        toAddressList.add(aUser.email);
                        count += 1;
                    }else {
                        // Need to send this batch of emails out
                        // Add the last email address from the loop above to the list
                        toAddressList.add(aUser.email);                   
                        objMail.setToAddresses(toAddressList);       
                    
                        // Send out this email with 100 recipients or less
                        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { objMail });
                        toAddressList.clear();
                        count=0;
                    }  
                }

                // send the remaining batch out    
                objMail.setToAddresses(toAddressList);        
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { objMail });
            } 

            // Reset the date/time until this solution is either approved or rejected
            aCR.Pending_Approval_Reminder_Date__c = DateTime.Now(); 
        }
  
        // Update the Case with a new approval reminder time
        if (lstCR.size() > 0)
        {
            update (lstCR);
        }
    } 
   
    //@future
    public static void send7DayCRReminderEmail (){
  
    string tmpTitle = '';
    string tmpSubject1 = '7 Day Approval Reminder for ';
    string tmpSubject2 = ' has been in process for 7 Days';
    string tmpBody1 = ''; 
    
    //EmailTemplate et = [SELECT Id FROM EmailTemplate WHERE Name = 'Contract Request - 7 Day Reminder']; 
    //'00X50000001JYgVEAW';
    
    string tmp1DayTemplateId = '00X50000001JYgLEAW';
    
    DateTime sevenDaysAgo = DateTime.Now();
    DateTime oneDayAgo = DateTime.Now();
    
    // Look 7 days in the past
    sevenDaysAgo = sevenDaysAgo.addDays(-7);
    
    //Look 1 day in the past
    oneDayAgo = oneDayAgo.addDays(-1);
    
    List<Contract_Request__c> lstCR = new List<Contract_Request__c> ([
        SELECT 
            id, 
            Name, 
            Account__c, 
            Contact__c,
            Pending_Approval_Reminder_Date__c,
            X7DayApprovalSent__c
        FROM Contract_Request__c
        WHERE System_Status__c = 'Pending Approval' 
            AND (Pending_Approval_Reminder_Date__c <= :sevenDaysAgo 
                OR (Pending_Approval_Reminder_Date__c <= :oneDayAgo 
                AND X7DayApprovalSent__c = true))
                LIMIT 10]);

    for ( Contract_Request__c aCR :lstCR ) {
            //if (aCR.Pending_Approval_Reminder_Date__c <= sevenDaysAgo)
            //{
            //    tmpBody1 = tmp7DayTemplateId;
            //}else{
            //  tmpBody1 = tmp1DayTemplateId;
            //}
                 
        //sendReminderEmail(aCR.Id, aCR.Name, tmpTitle, tmpSubject1, tmpSubject2, tmpBody1);
        sendReminderEmail(aCR.Id, aCR.Name, aCR.Contact__c, tmpTitle, tmpSubject1, tmpSubject2);
        // Reset the date/time until this solution is either approved or rejected
        aCR.Pending_Approval_Reminder_Date__c = DateTime.Now(); 
    }
  
    // Update the solution with a new approval reminder time
    if (lstCR.size() > 0)
    update (lstCR);
    }

    //**************************************************************************************
    // SendReminderEmail()
    // Method to handle sending the reminder email to the list of approvers.
    //**************************************************************************************
    private static void sendReminderEmail(
        Id ObjectId, 
        String ObjectNumber, 
        Id ContactId,
        String ObjectTitle, 
        String Subject1, 
        String Subject2)
        //String Body1) 
    {
      
        // Get the list of approvers for this CR
        List<ProcessInstanceWorkItem> lstPIWI = new List<ProcessInstanceWorkItem> ([
            SELECT actorId 
            FROM ProcessInstanceWorkItem 
            WHERE processinstanceid In 
            (SELECT Id FROM ProcessInstance WHERE status = 'Pending' and TargetObjectId = :ObjectId)]);
    
        if ( lstPIWI.size() > 0 ) {
            // This is the list of users who should receive an email. Now we need to get their actual 
            // email addresses from their User record
            Set<Id> setUserIds = new Set<Id>();
            
            for( ProcessInstanceWorkItem p :lstPIWI ){
                setUserIds.add(p.actorId);
            }
              
            // Get the actual email addresses from the list of userIds
            List<User> lstUsers = new List<User> ([
                SELECT email 
                FROM User
                WHERE Id In :setUserIds]);

            // Construct the email message
            String strEmailTo = '';  
            String[] toAddressList  = new String[]{};
              
            Messaging.SingleEmailMessage objMail = new Messaging.SingleEmailMessage();
            objMail.setReplyTo('qes.sfdc.noreply@qualcomm.com');
            objMail.setSenderDisplayName('QES SFDC Support - No Reply');
            objMail.setSaveAsActivity(false); 
              
            String subject = Subject1;
                subject += objectNumber;
                subject += Subject2;
            //objMail.setSubject(subject);

            objMail.setWhatId(objectId);
            
            //EmailTemplate et = [SELECT Id FROM EmailTemplate WHERE DeveloperName = 'Contract_Request_7_Day_Reminder' LIMIT 1];
            
            //objMail.setTemplateID(et.Id);          
            objMail.setTemplateID('00X50000001JYgVEAW');
            //String body;
            //body = Body1;
            //    body = '*** SOLUTION APPROVAL REMINDER NOTICE *** DO NOT REPLY TO THIS EMAIL ***\n\n'; 
            //    body += '\nYou are receiving this email because you are a member of the approval group for the following solution which is waiting for approval.';
            //    body += '\n\nPlease take a moment to review this solution and either approve or reject it.';
            //    body += '\n\n';
            //    body += 'Solution #: ';
            //    body += solutionNumber; 
            //    body += '\nTitle: ';
            //    body += solutionTitle; 
            //    body += '\n\nIf you are already logged in to Salesforce, you can View or Update this solution here: https://qualcomm-cdmatech-support.my.salesforce.com/';
            //    body += solutionId; 
            //    body += '\n\nOtherwise, first use this link to log in to Salesforce: http://qctsalesforce.qualcomm.com/sfdc/loginPage.html';
          
            //objMail.setPlainTextBody(body);
                  
            Integer count = 0;              
                
            for(User aUser :lstUsers)
            {
                // Per the documentation about single email, a single email can only have 100 recipients
                if ( count < 100 )
                {
                    toAddressList.add(aUser.email);
                    count += 1;
                }else {
                    // Need to send this batch of emails out
                    // Add the last email address from the loop above to the list
                    toAddressList.add(aUser.email);                   
                    objMail.setToAddresses(toAddressList);       
                    
                    // Send out this email with 100 recipients or less
                    Messaging.sendEmail(new Messaging.SingleEmailMessage[] { objMail });
                    toAddressList.clear();
                        count=0;
                    }  
                }
                objMail.setTargetObjectId('00550000001ZWWu');
                // send the remaining batch out    
                objMail.setToAddresses(toAddressList);        
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { objMail });
            } 
      }
  */
  }