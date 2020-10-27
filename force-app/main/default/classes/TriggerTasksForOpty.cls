public class TriggerTasksForOpty
{
    @InvocableMethod
    public static void createTasks(List<Id> opportunityIds){
        createTasksAndCases(opportunityIds);
    }
    
    @future
    public static void createTasksAndCases(List<Id> opportunityIds){
        Map<Id, Opportunity> oppsMap = new Map<Id, Opportunity>([Select Id, Name, RecordTypeId, Order_Type__c, CloseDate, AccountId, Primary_Contact__c, OwnerId, Owner_Business_Unit__c from Opportunity where Id in :opportunityIds]);
        List<Id> canadaOptyIds = new List<Id>();
        List<Id> roadnetOptyIds = new List<Id>();
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Email Generated Cases').getRecordTypeId();
        Id dataMigrationRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Data Migration').getRecordTypeId();
        List<Case> caseList = new List<Case>();
        List<Task> taskList = new List<Task>();
        Id hubAdminOwnerId = [select Id from Group where Name = 'HubAdmin' AND Type = 'Queue'][0].Id;
        Id cicerOwnerId = [select Id from Group where Name = 'CICER' AND Type = 'Queue'][0].Id;
        for(Opportunity opty : oppsMap.values()){
            Date lastSevenDays = System.today().addDays(-7);
            if(opty.Owner_Business_Unit__c == 'Omnitracs Canada' && opty.Order_Type__c != 'Customer Portal' && opty.RecordTypeId != dataMigrationRecordTypeId)
                canadaOptyIds.add(opty.Id);
            else if(!opty.Name.containsIgnoreCase('Annual Increase') && !opty.Name.containsIgnoreCase('Contract Renewal') && opty.CloseDate >= lastSevenDays)
                roadnetOptyIds.add(opty.Id);
        }
        if(roadnetOptyIds.size() > 0){
            List<OpportunityLineItem> optyLineItems = [Select OpportunityId From OpportunityLineItem where (Product2.Name like '%RN Telematics%' OR Product2.Name like '%RNT%') AND (NOT Product2.Name like '%base charge%') AND OpportunityId in :roadnetOptyIds];
            Set<Id> setOptyId = new Set<Id>();
            for(OpportunityLineItem lineItem: optyLineItems)
                setOptyId.add(lineItem.OpportunityId);
            for(Id optyId: setOptyId){
                Opportunity opty = oppsMap.get(optyId);
                createCase(hubAdminOwnerId, recordTypeId, opty.AccountId, opty.Primary_Contact__c, opty.Name, opty.Name, caseList, 'HubAdmin');
            }
        }
        if(canadaOptyIds.size() > 0){
             /*'CDN SETUP-2H','OCAN-ICS-SU','OCAN-CEV-SU','OCAN-ALK-FEE',*/
            List<OpportunityLineItem> optyLineItems = [select Id, OpportunityId, ProductCode, Opportunity.AccountId, Opportunity.Primary_Contact__c from OpportunityLineItem where ProductCode in 
                                                       ('DISA-IFTA','HOS - AUTO','GROVE-F-HOS','OCAN-3RDSU','CDN SETUP-BRZ','OV VEHICLE PERFORMANCE','OCAN-WSDW-FEE','CDN SETUP-2_5H','IVG-SUB-COMP-B','IVG-SUB-CORE-B','IVG-SUB-EOBR-B','IVG-SUB-PERF-B','IVG-SUB-PREM-B','IVG-SUB-COMP','IVG-SUB-CORE','IVG-SUB-EOBR','IVG-SUB-PERF','IVG-SUB-PREM','PS300021','PS300025','PS500001','PS500002','PS500003','PS500004','PS500005','OV IVG SAT','OV VEHICLE MAINTENANCE','OV EXT FAULTS','OV CER BASIC',
                                                      'OV CER PREMIUM','OV CER SPEED','OV FCW','OV CEV IVG','OV OTNAV','OV COPILOT','OV COPILOT ROUTE','AAD','OV DRIVER WORKFLOW','MIPR 5 TERR','OV QHOS MOBILE','OV ICS','OV EH ICS','OV MMS','OV EF','OV TPM','OV ABS','OV VIR','OV DWPC','OV DWA','OV DWPC-ONADD','OV DWPC-ON','WSB-ABC','HOS-AUTO','C-TPAT','GROVE-DVIR','GROVE-PAY','OV-SDM','OV-SDM-ME','GROVE-SCORE','ELM','DISA-IFTA','OT1-FT') 
                                                       and Opportunity.StageName = 'Closed Won' and Opportunity.Owner_Business_Unit__c = 'Omnitracs Canada' and OpportunityId in :canadaOptyIds];
            Id userId = Id.valueOf(SystemIds__c.getInstance().UserId_Opportunity_Task_Creation__c);
            Id setupUserId = Id.valueOf(SystemIds__c.getInstance().UserId_Opportunity_Setup_Task_Creation__c);
            Id groveUserId = Id.valueOf(SystemIds__c.getInstance().UserId_Opportunity_Grove_Task_Creation__c);
            for(Id optyId: opportunityIds){
                createTask(userId, optyId, 'New - Opportunity Closed Won', 'Not Assigned', 0, taskList);
            }
            for(OpportunityLineItem lineItem: optyLineItems){
                System.debug('Creating Tasks for Opportunity: ' + lineItem.OpportunityId);
                String productCode = lineItem.ProductCode;
              /*  if (productCode == 'OCAN-ALK-FEE') {
                    //createTask(setupUserId, lineItem.OpportunityId, 'PRJ - ALK Navigation setup and Config', 'Not Started', 1, taskList);
                    createCase(hubAdminOwnerId, recordTypeId, lineItem.Opportunity.AccountId, lineItem.Opportunity.Primary_Contact__c, 'PRJ - ALK Navigation setup and Config', 'PRJ - ALK Navigation setup and Config', caseList, 'HubAdmin');
                } */
                
                    if (productCode == 'OCAN-3RDSU') {
                    List<Opportunity> Opportunity =new List<Opportunity>([SELECT id, SBQQ__PrimaryQuote__c FROM Opportunity where Id=:lineItem.OpportunityId]);
                    ID QuoteId = Opportunity[0].SBQQ__PrimaryQuote__c;
                    String EmailBody = 'Hi,<br><br>'+'An opportunity with a SKU that requires manual billing has now been closed.Below is the link to opportunity and quote.<br><br>';
                    EmailBody = EmailBody+'Opportunity Link:'+'<html><a href="'+URL.getSalesforceBaseUrl().toExternalForm()+'/'+lineItem.OpportunityId+'">'+URL.getSalesforceBaseUrl().toExternalForm()+'/'+lineItem.OpportunityId+'</a></html>';
                    EmailBody = EmailBody+'Quote Link:'+'<html><a href="'+URL.getSalesforceBaseUrl().toExternalForm()+'/'+QuoteId+'">'+URL.getSalesforceBaseUrl().toExternalForm()+'/'+QuoteId+'</a></html>';
                    //EmailBody = EmailBody+'Quote Link:' + QuoteId+ '<br><br>';
                    EmailBody = EmailBody+'Please review the quote and complete the manual billing for one time setup fees as quoted<br><br>';
                    EmailBody = EmailBody+'Thanks,<br>'+'Customer Setup Department';
                    Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                    OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'omnitracs.sfdc.noreply@omnitracs.com'];
                    if(owea.size() > 0){
                        email.setOrgWideEmailAddressId(owea.get(0).Id);
                    }else{
                        email.setSenderDisplayName('Cust Setup Department');
                    }
                    String[] toAddresses = new List<String> {'canada.billing@omnitracs.com'};
                    email.setToAddresses(toAddresses);
                    email.setSubject('Complete manual billing');
                    email.setHtmlBody(EmailBody);
                    Messaging.sendEmail(new Messaging.singleEmailMessage[] {email}); 
                  //createTask(groveUserId, lineItem.OpportunityId, 'PRJ - GROVE VIR - Setup and Config', 'Not Started', 1, taskList);
                    createCase(cicerOwnerId, recordTypeId, lineItem.Opportunity.AccountId, lineItem.Opportunity.Primary_Contact__c, 'PRJ - GROVE VIR - Setup and Config', 'PRJ - GROVE VIR - Setup and Config', caseList, 'CICER');
                  //createTask(groveUserId, lineItem.OpportunityId, 'PRJ - Finesse HOS Setup & Border Crossing', 'Not Started', 1, taskList);
                    createCase(cicerOwnerId, recordTypeId, lineItem.Opportunity.AccountId, lineItem.Opportunity.Primary_Contact__c, 'PRJ - Finesse HOS Setup & Border Crossing', 'PRJ - Finesse HOS Setup & Border Crossing', caseList, 'CICER');
                  //createTask(userId, lineItem.OpportunityId, 'PRJ - FINESSE HOS Initial Training', 'Not Assigned', 3, taskList);
                    createCase(cicerOwnerId, recordTypeId, lineItem.Opportunity.AccountId, lineItem.Opportunity.Primary_Contact__c, 'PRJ - FINESSE HOS Initial Training', 'PRJ - FINESSE HOS Initial Training', caseList, 'CICER');
                 // createTask(userId, lineItem.OpportunityId, 'PRJ - GROVE VIR Initial Training', 'Not Assigned', 3, taskList);
                    createCase(cicerOwnerId, recordTypeId, lineItem.Opportunity.AccountId, lineItem.Opportunity.Primary_Contact__c, 'PRJ - GROVE VIR Initial Training', 'PRJ - GROVE VIR Initial Training', caseList, 'CICER');
                    //createTask(setupUserId, lineItem.OpportunityId, 'PRJ - VIR Workflow Setup and Config', 'Not Started', 1, taskList);
                    createCase(hubAdminOwnerId, recordTypeId, lineItem.Opportunity.AccountId, lineItem.Opportunity.Primary_Contact__c, 'PRJ - VIR Workflow Setup and Config', 'PRJ - VIR Workflow Setup and Config', caseList, 'HubAdmin');
                    createTask(groveUserId, lineItem.OpportunityId, 'IVG Template added to Customers WMC', 'Not Started', 1, taskList);
                    createCase(cicerOwnerId, recordTypeId, lineItem.Opportunity.AccountId, lineItem.Opportunity.Primary_Contact__c, 'IVG Template added to Customers WMC', 'IVG Template added to Customers WMC', caseList, 'CICER');
                    //createTask(setupUserId, lineItem.OpportunityId, 'PRJ - HOS Setup and Config', 'Not Started', 1, taskList);
                    createCase(hubAdminOwnerId, recordTypeId, lineItem.Opportunity.AccountId, lineItem.Opportunity.Primary_Contact__c, 'PRJ - HOS Setup and Config', 'PRJ - HOS Setup and Config', caseList, 'HubAdmin');
                    createTask(userId, lineItem.OpportunityId, 'Send HOS Credentials and Training', 'Not Assigned', 1, taskList);
                    createTask(userId, lineItem.OpportunityId, 'PRJ - HOS OmniU Group Training', 'Not Assigned', 10, taskList);
                    createTask(userId, lineItem.OpportunityId, 'PRJ - HOS Private Training', 'Not Assigned', 14, taskList);
                    createTask(userId, lineItem.OpportunityId, 'Software Training', 'Not Assigned', 15, taskList);
                      
                } else if (productCode == 'CDN SETUP-BRZ') {
                    List<Opportunity> lstOpportunity =new List<Opportunity>([SELECT id, SBQQ__PrimaryQuote__c FROM Opportunity where Id=:lineItem.OpportunityId]);
                    ID QuoteId = lstOpportunity[0].SBQQ__PrimaryQuote__c;
                    String EmailBody = 'Hi,<br><br>'+'An opportunity with a SKU that requires manual billing has now been closed.Below is the link to opportunity and quote.<br><br>';
                    EmailBody = EmailBody+'Opportunity Link:'+'<html><a href="'+URL.getSalesforceBaseUrl().toExternalForm()+'/'+lineItem.OpportunityId+'">'+URL.getSalesforceBaseUrl().toExternalForm()+'/'+lineItem.OpportunityId+'</a></html>';
                    EmailBody = EmailBody+'Quote Link:'+'<html><a href="'+URL.getSalesforceBaseUrl().toExternalForm()+'/'+QuoteId+'">'+URL.getSalesforceBaseUrl().toExternalForm()+'/'+QuoteId+'</a></html>';
                    //EmailBody = EmailBody+'Quote Link:' + QuoteId+ '<br><br>';
                    EmailBody = EmailBody+'Please review the quote and complete the manual billing for one time setup fees as quoted<br><br>';
                    EmailBody = EmailBody+'Thanks,<br>'+'Customer Setup Department';
                    Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                    OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'omnitracs.sfdc.noreply@omnitracs.com'];
                    if(owea.size() > 0){
                        email.setOrgWideEmailAddressId(owea.get(0).Id);
                    }else{
                        email.setSenderDisplayName('Cust Setup Department');
                    }
                    String[] toAddresses = new List<String> {'canada.billing@omnitracs.com'};
                    email.setToAddresses(toAddresses);
                    email.setSubject('Complete manual billing');
                    email.setHtmlBody(EmailBody);
                    Messaging.sendEmail(new Messaging.singleEmailMessage[] {email}); 
                 /* createTask(groveUserId, lineItem.OpportunityId, 'PRJ - GROVE CTPAT - Setup and Config', 'Not Started', 1, taskList);
                    createTask(groveUserId, lineItem.OpportunityId, 'PRJ - GROVE CTPAT Initial Training', 'Not Started', 3, taskList);
                    createTask(setupUserId, lineItem.OpportunityId, 'PRJ - WORKFLOW Setup and Config', 'Not Started', 1, taskList);
                    createCase(hubAdminOwnerId, recordTypeId, lineItem.Opportunity.AccountId, lineItem.Opportunity.Primary_Contact__c, 'PRJ - WORKFLOW Setup and Config', 'PRJ - WORKFLOW Setup and Config', caseList, 'HubAdmin');
                    createTask(userId, lineItem.OpportunityId, 'PRJ - WORKFLOW Training', 'Not Assigned', 3, taskList);
                    createTask(setupUserId, lineItem.OpportunityId, 'PRJ - VM Setup and Config', 'Not Started', 1, taskList);
                    createCase(hubAdminOwnerId, recordTypeId, lineItem.Opportunity.AccountId, lineItem.Opportunity.Primary_Contact__c, 'PRJ - VM Setup and Config', 'PRJ - VM Setup and Config', caseList, 'HubAdmin');
                    createTask(userId, lineItem.OpportunityId, 'PRJ - VDiag Email Training', 'Not Assigned', 3, taskList);
                    createTask(setupUserId, lineItem.OpportunityId, 'PRJ - SG Setup and Config', 'Not Started', 1, taskList);
                    createCase(hubAdminOwnerId, recordTypeId, lineItem.Opportunity.AccountId, lineItem.Opportunity.Primary_Contact__c, 'PRJ - SG Setup and Config', 'PRJ - SG Setup and Config', caseList, 'HubAdmin');
                    createTask(userId, lineItem.OpportunityId, 'PRJ - SG Training request', 'Not Assigned', 3, taskList);
                    createTask(groveUserId, lineItem.OpportunityId, 'PRJ - GROVE Scorecard - Setup and Config', 'Not Started', 1, taskList);
                    createTask(userId, lineItem.OpportunityId, 'PRJ - GROVE Scorecard Initial Training', 'Not Assigned', 3, taskList);
                    createTask(groveUserId, lineItem.OpportunityId, 'PRJ - GROVE Payroll - Setup and Config', 'Not Started', 1, taskList);
                    createTask(userId, lineItem.OpportunityId, 'PRJ - GROVE Payroll Initial Training', 'Not Assigned', 3, taskList);*/
                } else if (productCode == 'OV VEHICLE PERFORMANCE') {
                    //createTask(setupUserId, lineItem.OpportunityId, 'PRJ - PM Setup and Config', 'Not Started', 1, taskList);
                    createCase(hubAdminOwnerId, recordTypeId, lineItem.Opportunity.AccountId, lineItem.Opportunity.Primary_Contact__c, 'PRJ - PM Setup and Config', 'PRJ - PM Setup and Config', caseList, 'HubAdmin');
                    createTask(userId, lineItem.OpportunityId, 'PRJ - PM Training', 'Not Assigned', 3, taskList);
                    createCase(hubAdminOwnerId, recordTypeId, lineItem.Opportunity.AccountId, lineItem.Opportunity.Primary_Contact__c, 'PRJ - Enable Performance Monitoring', 'Enable PM', caseList, 'HubAdmin');             
                    createCase(cicerOwnerId, recordTypeId, lineItem.Opportunity.AccountId, lineItem.Opportunity.Primary_Contact__c, 'PRJ - Performance Monitoring provide documentation and setup instructions', 'Email Documentation and instructions', caseList, 'CICER');                  
                } /* else if (productCode == 'CDN SETUP-2H') {
                    //createTask(setupUserId, lineItem.OpportunityId, 'PRJ - Web PORTAL Setup and Config', 'Not Started', 1, taskList);
                    createCase(hubAdminOwnerId, recordTypeId, lineItem.Opportunity.AccountId, lineItem.Opportunity.Primary_Contact__c, 'PRJ - Web PORTAL Setup and Config', 'PRJ - Web PORTAL Setup and Config', caseList, 'HubAdmin');
                    createTask(userId, lineItem.OpportunityId, 'PRJ - QTRACS BASIC Training', 'Not Assigned', 3, taskList);
                } */
                else if (productCode == 'OV CER BASIC') {
                    //createTask(setupUserId, lineItem.OpportunityId, 'PRJ - CERB Setup and Config', 'Not Started', 1, taskList);
                    createCase(hubAdminOwnerId, recordTypeId, lineItem.Opportunity.AccountId, lineItem.Opportunity.Primary_Contact__c, 'PRJ - Enable Critical Event Reporting', 'Enable CER', caseList, 'HubAdmin');
                    createCase(cicerOwnerId, recordTypeId, lineItem.Opportunity.AccountId, lineItem.Opportunity.Primary_Contact__c, 'PRJ - Critical Event Reporting provide documentation/instructions', 'Email Documentation and instructions', caseList, 'CICER');                  
                    createTask(userId, lineItem.OpportunityId, 'PRJ - CERB Email Training', 'Not Assigned', 3, taskList);
                } 
                /* else if (productCode == 'OCAN-CEV-SU') {
                    //createTask(setupUserId, lineItem.OpportunityId, 'PRJ - CEV Camera Setup', 'Not Started', 1, taskList);
                    createCase(hubAdminOwnerId, recordTypeId, lineItem.Opportunity.AccountId, lineItem.Opportunity.Primary_Contact__c, 'PRJ - CEV Camera Setup', 'PRJ - CEV Camera Setup', caseList, 'HubAdmin');
                    createTask(userId, lineItem.OpportunityId, 'Email: CEV Camera Installation Instructions 1620R', 'Not Assigned', 1, taskList);
                    createTask(userId, lineItem.OpportunityId, 'Email: CEV IVG Camera Installation', 'Not Assigned', 1, taskList);
                    createTask(userId, lineItem.OpportunityId, 'PRJ - CEV Camera Training', 'Not Assigned', 1, taskList);
                    createTask(userId, lineItem.OpportunityId, 'PRJ - CEV Camera Hardware Training', 'Not Assigned', 3, taskList);
                } */
                else if (productCode == 'OCAN-WSDW-FEE') {
                    //createTask(setupUserId, lineItem.OpportunityId, 'PRJ - Enable Drivewyze WSB', 'Not Started', 1, taskList);
                    createCase(hubAdminOwnerId, recordTypeId, lineItem.Opportunity.AccountId, lineItem.Opportunity.Primary_Contact__c, 'PRJ - Enable Drivewyze WSB', 'PRJ - Enable Drivewyze WSB', caseList, 'HubAdmin');
                    createTask(userId, lineItem.OpportunityId, 'PRJ - Drivewyze Setup (Email training)', 'Not Assigned', 1, taskList);
                } 
                /*else if (productCode == 'OCAN-ICS-SU') {
                    //createTask(setupUserId, lineItem.OpportunityId, 'PRJ - ENHANCED SCAN Setup and Config', 'Not Started', 1, taskList);
                    createCase(hubAdminOwnerId, recordTypeId, lineItem.Opportunity.AccountId, lineItem.Opportunity.Primary_Contact__c, 'PRJ - ENHANCED SCAN Setup and Config', 'PRJ - ENHANCED SCAN Setup and Config', caseList, 'HubAdmin');
                    createTask(userId, lineItem.OpportunityId, 'PRJ - Stessy ENHANCED SCAN Setup and Config', 'Not Assigned', 1, taskList);
                    createTask(userId, lineItem.OpportunityId, 'PRJ - Email setup done on Enhanced Scanning', 'Not Assigned', 1, taskList);
                } */
                else if (productCode == 'CDN SETUP-2_5H') {
                    //createTask(setupUserId, lineItem.OpportunityId, 'PRJ - TT150 Setup and Config', 'Not Started', 1, taskList);
                    createCase(hubAdminOwnerId, recordTypeId, lineItem.Opportunity.AccountId, lineItem.Opportunity.Primary_Contact__c, 'PRJ - TT150 Setup and Config', 'PRJ - TT150 Setup and Config', caseList, 'HubAdmin');
                    createTask(userId, lineItem.OpportunityId, 'PRJ - TT150 Welcome Email', 'Not Assigned', 1, taskList);
                    createTask(userId, lineItem.OpportunityId, 'PRJ - TT150 HW training', 'Not Assigned', 3, taskList);
                    createTask(userId, lineItem.OpportunityId, 'PRJ - TT150 SW training', 'Not Assigned', 7, taskList);
                } else if (productCode == 'IVG-SUB-COMP-B') {
                    createCase(hubAdminOwnerId, recordTypeId, lineItem.Opportunity.AccountId, lineItem.Opportunity.Primary_Contact__c, 'PRJ - COMPLIANCE Setup and Config - WebPortal', 'COMPLIANCE Setup and Config - WebPortal (QTRACS)', caseList, 'HubAdmin');
                    createCase(hubAdminOwnerId, recordTypeId, lineItem.Opportunity.AccountId, lineItem.Opportunity.Primary_Contact__c, 'PRJ - COMPLIANCE Setup and Config - HOS', 'COMPLIANCE Setup and Config - HOS', caseList, 'HubAdmin');
                    createCase(hubAdminOwnerId, recordTypeId, lineItem.Opportunity.AccountId, lineItem.Opportunity.Primary_Contact__c, 'PRJ - EOBR Setup and Config - VIR (GROVE or OMNIVIR)', 'EOBR Setup and Config - VIR.   If the opportunity contains SKU "CDN SETUP-BRZ" then setup for GroveVIR otherwise enable OmniVIR.  If OmniVIR enable application as per standard process. If Grove VIR, enable customer for Workflow, enable workflow application at Group level  and enable integration on the Portal.', caseList, 'HubAdmin');
                    createCase(cicerOwnerId, recordTypeId, lineItem.Opportunity.AccountId, lineItem.Opportunity.Primary_Contact__c, 'PRJ - COMPLIANCE - Send credentials and setup/training info', 'Send credentials - QTRACS, HOS, VIR', caseList, 'CICER');
                    createCase(cicerOwnerId, recordTypeId, lineItem.Opportunity.AccountId, lineItem.Opportunity.Primary_Contact__c, 'PRJ - Setup OmniU Group Training', 'Setup OmniU Group Training', caseList, 'CICER');
                    createCase(cicerOwnerId, recordTypeId, lineItem.Opportunity.AccountId, lineItem.Opportunity.Primary_Contact__c, 'PRJ - Project Check-In', 'Review implementation steps', caseList, 'CICER');
                    createCase(cicerOwnerId, recordTypeId, lineItem.Opportunity.AccountId, lineItem.Opportunity.Primary_Contact__c, 'PRJ - Project Check-Out', 'Review customer\'s setup', caseList, 'CICER'); 
                } else if (productCode == 'IVG-SUB-CORE-B') {
                    createCase(hubAdminOwnerId, recordTypeId, lineItem.Opportunity.AccountId, lineItem.Opportunity.Primary_Contact__c, 'PRJ - CORE  Setup and Config - WebPortal', 'CORE Setup and Config - WebPortal (QTRACS)', caseList, 'HubAdmin');                 
                    createCase(cicerOwnerId, recordTypeId, lineItem.Opportunity.AccountId, lineItem.Opportunity.Primary_Contact__c, 'PRJ - CORE - Send credentials and setup/training info', 'Send credentials  - QTRACS', caseList, 'CICER');
                    createCase(cicerOwnerId, recordTypeId, lineItem.Opportunity.AccountId, lineItem.Opportunity.Primary_Contact__c, 'PRJ - Setup OmniU Group Training', 'Setup OmniU Group Training', caseList, 'CICER');
                    createCase(cicerOwnerId, recordTypeId, lineItem.Opportunity.AccountId, lineItem.Opportunity.Primary_Contact__c, 'PRJ - Project Check-In', 'Review implementation steps', caseList, 'CICER');
                    createCase(cicerOwnerId, recordTypeId, lineItem.Opportunity.AccountId, lineItem.Opportunity.Primary_Contact__c, 'PRJ - Project Check-Out', 'Review customer\'s setup', caseList, 'CICER');
                } else if (productCode == 'IVG-SUB-EOBR-B') {
                    createCase(hubAdminOwnerId, recordTypeId, lineItem.Opportunity.AccountId, lineItem.Opportunity.Primary_Contact__c, 'PRJ - EOBR Setup and Config - WebPortal', 'EOBR Setup and Config - WebPortal (QTRACS) - NO Macros/Integration', caseList, 'HubAdmin');
                    createCase(hubAdminOwnerId, recordTypeId, lineItem.Opportunity.AccountId, lineItem.Opportunity.Primary_Contact__c, 'PRJ - EOBR Setup and Config - HOS', 'EOBR Setup and Config - HOS', caseList, 'HubAdmin');
                    createCase(hubAdminOwnerId, recordTypeId, lineItem.Opportunity.AccountId, lineItem.Opportunity.Primary_Contact__c, 'PRJ - EOBR Setup and Config - VIR (GROVE or OMNIVIR)', 'EOBR Setup and Config - VIR.   If the opportunity contains SKU "CDN SETUP-BRZ" then setup for GroveVIR otherwise enable OmniVIR.  If OmniVIR enable application as per standard process. If Grove VIR, enable customer for Workflow, enable workflow application at Group level  and enable integration on the Portal.', caseList, 'HubAdmin');
                    createCase(cicerOwnerId, recordTypeId, lineItem.Opportunity.AccountId, lineItem.Opportunity.Primary_Contact__c, 'PRJ - EOBR - Send credentials and setup/training info', 'Send credentials  - QTRACS, HOS, VIR', caseList, 'CICER');
                    createCase(cicerOwnerId, recordTypeId, lineItem.Opportunity.AccountId, lineItem.Opportunity.Primary_Contact__c, 'PRJ - Setup OmniU Group Training', 'Setup OmniU Group Training', caseList, 'CICER');
                    createCase(cicerOwnerId, recordTypeId, lineItem.Opportunity.AccountId, lineItem.Opportunity.Primary_Contact__c, 'PRJ - Project Check-In', 'Review implementation steps', caseList, 'CICER');
                    createCase(cicerOwnerId, recordTypeId, lineItem.Opportunity.AccountId, lineItem.Opportunity.Primary_Contact__c, 'PRJ - Project Check-Out', 'Review customer\'s setup', caseList, 'CICER');
                } else if (productCode == 'IVG-SUB-PERF-B') {
                    createCase(hubAdminOwnerId, recordTypeId, lineItem.Opportunity.AccountId, lineItem.Opportunity.Primary_Contact__c, 'PRJ - PERFORMANCE Setup and Config - WebPortal', 'PERFORMANCE Setup and Config - WebPortal (QTRACS)', caseList, 'HubAdmin');
                    createCase(hubAdminOwnerId, recordTypeId, lineItem.Opportunity.AccountId, lineItem.Opportunity.Primary_Contact__c, 'PRJ - PERFORMANCE Setup and Config - PM', 'PERFORMANCE Setup and Config - PM', caseList, 'HubAdmin');
                    createCase(hubAdminOwnerId, recordTypeId, lineItem.Opportunity.AccountId, lineItem.Opportunity.Primary_Contact__c, 'PRJ - PERFORMANCE Setup and Config - CER', 'PERFORMANCE Setup and Config - CER', caseList, 'HubAdmin');
                    createCase(cicerOwnerId, recordTypeId, lineItem.Opportunity.AccountId, lineItem.Opportunity.Primary_Contact__c, 'PRJ - PERFORMANCE - Send credentials and setup/training info', 'Send credentials - QTRACS, PM, CER', caseList, 'CICER');
                    createCase(cicerOwnerId, recordTypeId, lineItem.Opportunity.AccountId, lineItem.Opportunity.Primary_Contact__c, 'PRJ - Setup OmniU Group Training', 'Setup OmniU Group Training', caseList, 'CICER');
                    createCase(cicerOwnerId, recordTypeId, lineItem.Opportunity.AccountId, lineItem.Opportunity.Primary_Contact__c, 'PRJ - Project Check-In', 'Review implementation steps', caseList, 'CICER');
                    createCase(cicerOwnerId, recordTypeId, lineItem.Opportunity.AccountId, lineItem.Opportunity.Primary_Contact__c, 'PRJ - Project Check-Out', 'Review customer\'s setup', caseList, 'CICER');
                } else if (productCode == 'IVG-SUB-PREM-B') {
                    createCase(hubAdminOwnerId, recordTypeId, lineItem.Opportunity.AccountId, lineItem.Opportunity.Primary_Contact__c, 'PRJ - PREMIUM Setup and Config - WebPortal', 'PREMIUM Setup and Config - WebPortal (QTRACS)', caseList, 'HubAdmin');
                    createCase(hubAdminOwnerId, recordTypeId, lineItem.Opportunity.AccountId, lineItem.Opportunity.Primary_Contact__c, 'PRJ - PREMIUM Setup and Config - HOS', 'PREMIUM Setup and Config - HOS', caseList, 'HubAdmin');
                    createCase(hubAdminOwnerId, recordTypeId, lineItem.Opportunity.AccountId, lineItem.Opportunity.Primary_Contact__c, 'PRJ - EOBR Setup and Config - VIR (GROVE or OMNIVIR)', 'EOBR Setup and Config - VIR.   If the opportunity contains SKU "CDN SETUP-BRZ" then setup for GroveVIR otherwise enable OmniVIR.  If OmniVIR enable application as per standard process. If Grove VIR, enable customer for Workflow, enable workflow application at Group level  and enable integration on the Portal.', caseList, 'HubAdmin');
                    createCase(hubAdminOwnerId, recordTypeId, lineItem.Opportunity.AccountId, lineItem.Opportunity.Primary_Contact__c, 'PRJ - PREMIUM Setup and Config - PM', 'PREMIUM Setup and Config - PM', caseList, 'HubAdmin');
                    createCase(hubAdminOwnerId, recordTypeId, lineItem.Opportunity.AccountId, lineItem.Opportunity.Primary_Contact__c, 'PRJ - PREMIUM Setup and Config - CER', 'PREMIUM Setup and Config - CER', caseList, 'HubAdmin');
                    createCase(hubAdminOwnerId, recordTypeId, lineItem.Opportunity.AccountId, lineItem.Opportunity.Primary_Contact__c, 'PRJ - PREMIUM Setup and Config - WF', 'PREMIUM Setup and Config - WF', caseList, 'HubAdmin');
                    createCase(hubAdminOwnerId, recordTypeId, lineItem.Opportunity.AccountId, lineItem.Opportunity.Primary_Contact__c, 'PRJ - PREMIUM Setup and Config - FM', 'PREMIUM Setup and Config - FM', caseList, 'HubAdmin');
                    createCase(cicerOwnerId, recordTypeId, lineItem.Opportunity.AccountId, lineItem.Opportunity.Primary_Contact__c, 'PRJ - PREMIUM - Send credentials and setup/training info', 'Send credentials - QTRACS, HOS, VIR, PM, CER, WF, FM', caseList, 'CICER');
                    createCase(cicerOwnerId, recordTypeId, lineItem.Opportunity.AccountId, lineItem.Opportunity.Primary_Contact__c, 'PRJ - Setup OmniU Group Training', 'Setup OmniU Group Training', caseList, 'CICER');
                    createCase(cicerOwnerId, recordTypeId, lineItem.Opportunity.AccountId, lineItem.Opportunity.Primary_Contact__c, 'PRJ - Project Check-In', 'Review implementation steps', caseList, 'CICER');
                    createCase(cicerOwnerId, recordTypeId, lineItem.Opportunity.AccountId, lineItem.Opportunity.Primary_Contact__c, 'PRJ - Project Check-Out', 'Review customer\'s setup', caseList, 'CICER');
                } else if (productCode == 'IVG-SUB-COMP') {
                    createCase(hubAdminOwnerId, recordTypeId, lineItem.Opportunity.AccountId, lineItem.Opportunity.Primary_Contact__c, 'PRJ - COMPLIANCE Setup and Config - WebPortal', 'COMPLIANCE Setup and Config - WebPortal (QTRACS)', caseList, 'HubAdmin');
                    createCase(hubAdminOwnerId, recordTypeId, lineItem.Opportunity.AccountId, lineItem.Opportunity.Primary_Contact__c, 'PRJ - COMPLIANCE Setup and Config - HOS', 'COMPLIANCE Setup and Config - HOS', caseList, 'HubAdmin');
                    createCase(hubAdminOwnerId, recordTypeId, lineItem.Opportunity.AccountId, lineItem.Opportunity.Primary_Contact__c, 'PRJ - EOBR Setup and Config - VIR (GROVE or OMNIVIR)', 'EOBR Setup and Config - VIR. If the opportunity contains SKU "CDN SETUP-BRZ" then setup for GroveVIR otherwise enable OmniVIR. If OmniVIR enable application as per standard process. If Grove VIR, enable customer for Workflow, enable workflow application at Group level  and enable integration on the Portal.', caseList, 'HubAdmin');
                    createCase(cicerOwnerId, recordTypeId, lineItem.Opportunity.AccountId, lineItem.Opportunity.Primary_Contact__c, 'PRJ - COMPLIANCE - Send credentials and setup/training info', 'Send credentials - QTRACS, HOS, VIR', caseList, 'CICER');               
                }
                else if (productCode == 'IVG-SUB-CORE') {
                    createCase(hubAdminOwnerId, recordTypeId, lineItem.Opportunity.AccountId, lineItem.Opportunity.Primary_Contact__c, 'PRJ - CORE  Setup and Config - WebPortal', 'CORE Setup and Config - WebPortal (QTRACS)', caseList, 'HubAdmin');                 
                    createCase(cicerOwnerId, recordTypeId, lineItem.Opportunity.AccountId, lineItem.Opportunity.Primary_Contact__c, 'PRJ - CORE - Send credentials and setup/training info', 'Send credentials  - QTRACS', caseList, 'CICER');              
                }
                else if (productCode == 'IVG-SUB-EOBR') {
                    createCase(hubAdminOwnerId, recordTypeId, lineItem.Opportunity.AccountId, lineItem.Opportunity.Primary_Contact__c, 'PRJ - EOBR Setup and Config - WebPortal', 'EOBR Setup and Config - WebPortal (QTRACS) - NO Macros/Integration', caseList, 'HubAdmin');
                    createCase(hubAdminOwnerId, recordTypeId, lineItem.Opportunity.AccountId, lineItem.Opportunity.Primary_Contact__c, 'PRJ - EOBR Setup and Config - HOS', 'EOBR Setup and Config - HOS', caseList, 'HubAdmin');
                    createCase(hubAdminOwnerId, recordTypeId, lineItem.Opportunity.AccountId, lineItem.Opportunity.Primary_Contact__c, 'PRJ - EOBR Setup and Config - VIR (GROVE or OMNIVIR)', 'EOBR Setup and Config - VIR. If the opportunity contains SKU "CDN SETUP-BRZ" then setup for GroveVIR otherwise enable OmniVIR. If OmniVIR enable application as per standard process. If Grove VIR, enable customer for Workflow, enable workflow application at Group level  and enable integration on the Portal.', caseList, 'HubAdmin');
                    createCase(cicerOwnerId, recordTypeId, lineItem.Opportunity.AccountId, lineItem.Opportunity.Primary_Contact__c, 'PRJ - EOBR - Send credentials and setup/training info ', 'Send credentials - QTRACS, HOS, VIR', caseList, 'CICER');                
                }
                else if (productCode == 'IVG-SUB-PERF') {
                    createCase(hubAdminOwnerId, recordTypeId, lineItem.Opportunity.AccountId, lineItem.Opportunity.Primary_Contact__c, 'PRJ - PERFORMANCE Setup and Config - WebPortal', 'PERFORMANCE Setup and Config - WebPortal (QTRACS)', caseList, 'HubAdmin');    
                    createCase(hubAdminOwnerId, recordTypeId, lineItem.Opportunity.AccountId, lineItem.Opportunity.Primary_Contact__c, 'PRJ - PERFORMANCE Setup and Config - PM', 'PERFORMANCE Setup and Config - PM', caseList, 'HubAdmin');   
                    createCase(hubAdminOwnerId, recordTypeId, lineItem.Opportunity.AccountId, lineItem.Opportunity.Primary_Contact__c, 'PRJ - PERFORMANCE Setup and Config - CER', 'PERFORMANCE Setup and Config - CER', caseList, 'HubAdmin');                                     
                    createCase(cicerOwnerId, recordTypeId, lineItem.Opportunity.AccountId, lineItem.Opportunity.Primary_Contact__c, 'PRJ - PERFORMANCE - Send credentials and setup/training info', 'Send credentials - QTRACS, PM, CER', caseList, 'CICER');               
                }
                else if (productCode == 'IVG-SUB-PREM') {
                    createCase(hubAdminOwnerId, recordTypeId, lineItem.Opportunity.AccountId, lineItem.Opportunity.Primary_Contact__c, 'PRJ - PREMIUM Setup and Config - WebPortal', 'PREMIUM Setup and Config - WebPortal (QTRACS)', caseList, 'HubAdmin');    
                    createCase(hubAdminOwnerId, recordTypeId, lineItem.Opportunity.AccountId, lineItem.Opportunity.Primary_Contact__c, 'PRJ - PREMIUM Setup and Config - HOS', 'PREMIUM Setup and Config - HOS', caseList, 'HubAdmin'); 
                    createCase(hubAdminOwnerId, recordTypeId, lineItem.Opportunity.AccountId, lineItem.Opportunity.Primary_Contact__c, 'PRJ - EOBR Setup and Config - VIR (GROVE or OMNIVIR)', 'EOBR Setup and Config - VIR.   If the opportunity contains SKU "CDN SETUP-BRZ" then setup for GroveVIR otherwise enable OmniVIR.  If OmniVIR enable application as per standard process. If Grove VIR, enable customer for Workflow, enable workflow application at Group level  and enable integration on the Portal.', caseList, 'HubAdmin'); 
                    createCase(hubAdminOwnerId, recordTypeId, lineItem.Opportunity.AccountId, lineItem.Opportunity.Primary_Contact__c, 'PRJ - PREMIUM Setup and Config - PM', 'PREMIUM Setup and Config - PM', caseList, 'HubAdmin');   
                    createCase(hubAdminOwnerId, recordTypeId, lineItem.Opportunity.AccountId, lineItem.Opportunity.Primary_Contact__c, 'PRJ - PREMIUM Setup and Config - CER', 'PREMIUM Setup and Config - CER', caseList, 'HubAdmin');
                    createCase(hubAdminOwnerId, recordTypeId, lineItem.Opportunity.AccountId, lineItem.Opportunity.Primary_Contact__c, 'PRJ - PREMIUM Setup and Config - WF', 'PREMIUM Setup and Config - WF', caseList, 'HubAdmin');   
                    createCase(hubAdminOwnerId, recordTypeId, lineItem.Opportunity.AccountId, lineItem.Opportunity.Primary_Contact__c, 'PRJ - PREMIUM Setup and Config - FM', 'PREMIUM Setup and Config - FM', caseList, 'HubAdmin');   
                    createCase(cicerOwnerId, recordTypeId, lineItem.Opportunity.AccountId, lineItem.Opportunity.Primary_Contact__c, 'PRJ - PREMIUM - Send credentials and setup/training info', 'Send credentials - QTRACS, HOS, VIR, PM, CER, WF, FM', caseList, 'CICER');             
                } 
                else if (productCode == 'PS300021') {
                    createCase(cicerOwnerId, recordTypeId, lineItem.Opportunity.AccountId, lineItem.Opportunity.Primary_Contact__c, 'PRJ - Project Implementation Start', 'Review and complete implementation steps', caseList, 'CICER');
                    createCase(cicerOwnerId, recordTypeId, lineItem.Opportunity.AccountId, lineItem.Opportunity.Primary_Contact__c, 'PRJ - Project Implementation Follow up', 'Review customers setup and follow up', caseList, 'CICER');
                  }
                  else if (productCode == 'PS300025') {
                    createCase(cicerOwnerId, recordTypeId, lineItem.Opportunity.AccountId, lineItem.Opportunity.Primary_Contact__c, 'PRJ - Project Implementation Start', 'Review and complete implementation steps', caseList, 'CICER');
                    createCase(cicerOwnerId, recordTypeId, lineItem.Opportunity.AccountId, lineItem.Opportunity.Primary_Contact__c, 'PRJ - Project Implementation Follow up', 'Review customers setup and follow up', caseList, 'CICER');
                  }
                  else if (productCode == 'PS500001') {
                    createCase(cicerOwnerId, recordTypeId, lineItem.Opportunity.AccountId, lineItem.Opportunity.Primary_Contact__c, 'OD Operations Webinar Training - Core (5hr)', 'Setup OmniU seats based on Qty in Opportunity', caseList, 'CICER');
                  }
                  else if (productCode == 'PS500002') {
                    createCase(cicerOwnerId, recordTypeId, lineItem.Opportunity.AccountId, lineItem.Opportunity.Primary_Contact__c, 'OD Operations Webinar Training - Compliance/EOBR (9hr)', 'Setup OmniU seats based on Qty in Opportunity', caseList, 'CICER');
                  }
                  else if (productCode == 'PS500003') {
                    createCase(cicerOwnerId, recordTypeId, lineItem.Opportunity.AccountId, lineItem.Opportunity.Primary_Contact__c, 'OD Operations Webinar Training - Performance (7.5hr)', 'Setup OmniU seats based on Qty in Opportunity', caseList, 'CICER');
                  }
                  else if (productCode == 'PS500004') {
                    createCase(cicerOwnerId, recordTypeId, lineItem.Opportunity.AccountId, lineItem.Opportunity.Primary_Contact__c, 'OD Operations Webinar Training - Premium (11.5hr)', 'Setup OmniU seats based on Qty in Opportunity', caseList, 'CICER');
                  }
                  else if (productCode == 'PS500005') {
                    createCase(cicerOwnerId, recordTypeId, lineItem.Opportunity.AccountId, lineItem.Opportunity.Primary_Contact__c, 'OD Operations Webinar Training - A la Carte (1hr)', 'Setup OmniU seats based on qty and have hubadmin setup appropriate application based on opportunity', caseList, 'CICER');
                  }
                  else if (productCode == 'OV IVG SAT') {
                    createCase(hubAdminOwnerId, recordTypeId, lineItem.Opportunity.AccountId, lineItem.Opportunity.Primary_Contact__c, 'PRJ - IVG Satellite Data Plan', 'Enable Satellite at group level (CDEF 488)', caseList, 'HubAdmin');
                  }
                  else if (productCode == 'OV VEHICLE MAINTENANCE') {
                    createCase(hubAdminOwnerId, recordTypeId, lineItem.Opportunity.AccountId, lineItem.Opportunity.Primary_Contact__c, 'PRJ - Enable Fault Monitoring', 'Enable Fault Monitoring', caseList, 'HubAdmin');
                    createCase(cicerOwnerId, recordTypeId, lineItem.Opportunity.AccountId, lineItem.Opportunity.Primary_Contact__c, 'PRJ - Fault Monitoring Documentation/Instructions', 'Email Documentation to client', caseList, 'CICER');
                  }
                  else if (productCode == 'OV EXT FAULTS') {
                    createCase(hubAdminOwnerId, recordTypeId, lineItem.Opportunity.AccountId, lineItem.Opportunity.Primary_Contact__c, 'PRJ - Fault Monitoring - Extended Faults', 'Enable Fault Monitoring, Enabled integration', caseList, 'HubAdmin');                    
                  }
                  else if (productCode == 'OV CER BASIC') {
                    createCase(hubAdminOwnerId, recordTypeId, lineItem.Opportunity.AccountId, lineItem.Opportunity.Primary_Contact__c, 'PRJ - Enable Critical Even Reporting', 'Enable CER', caseList, 'HubAdmin');  
                    createCase(cicerOwnerId, recordTypeId, lineItem.Opportunity.AccountId, lineItem.Opportunity.Primary_Contact__c, 'PRJ - Critical Even Reporting provide documentation/instructions', 'Email Documentation and instructions', caseList, 'CICER');                  
                  }
                  else if (productCode == 'OV CER PREMIUM') {
                    createCase(hubAdminOwnerId, recordTypeId, lineItem.Opportunity.AccountId, lineItem.Opportunity.Primary_Contact__c, 'PRJ - CER - Add-on - Stability Control and Lane Departure Warning', 'Enable CER Premium', caseList, 'HubAdmin');             
                  }
                  else if (productCode == 'OV CER SPEED') {
                    createCase(hubAdminOwnerId, recordTypeId, lineItem.Opportunity.AccountId, lineItem.Opportunity.Primary_Contact__c, 'PRJ - CER - Add-on - Over Speed Events', 'Enable CER Overspeed', caseList, 'HubAdmin');             
                  }
                  else if (productCode == 'OV FCW') {
                    createCase(hubAdminOwnerId, recordTypeId, lineItem.Opportunity.AccountId, lineItem.Opportunity.Primary_Contact__c, 'PRJ - CER - Forward Collision Warning & Forward Time Violation', 'Enable CER FCW (Forward Collision)', caseList, 'HubAdmin');             
                  }
                  else if (productCode == 'OV CEV IVG') {
                    createCase(hubAdminOwnerId, recordTypeId, lineItem.Opportunity.AccountId, lineItem.Opportunity.Primary_Contact__c, 'PRJ - Enable CEV Application for IVG', 'Enable CEV', caseList, 'HubAdmin');             
                    createCase(cicerOwnerId, recordTypeId, lineItem.Opportunity.AccountId, lineItem.Opportunity.Primary_Contact__c, 'PRJ - CEV Application for IVG provide documentation/instructions', 'Email Documentation and instructions', caseList, 'CICER');                  
                  }
                  else if (productCode == 'OV OTNAV') {
                    createCase(hubAdminOwnerId, recordTypeId, lineItem.Opportunity.AccountId, lineItem.Opportunity.Primary_Contact__c, 'PRJ - Enable Omnitracs Navigation', 'Enable OT Nav', caseList, 'HubAdmin');             
                    createCase(cicerOwnerId, recordTypeId, lineItem.Opportunity.AccountId, lineItem.Opportunity.Primary_Contact__c, 'PRJ - Omnitracs Navigation provide documentation/instructions', 'Email Documentation and instructions', caseList, 'CICER');                  
                  }
                  else if (productCode == 'OV COPILOT') {
                    createCase(hubAdminOwnerId, recordTypeId, lineItem.Opportunity.AccountId, lineItem.Opportunity.Primary_Contact__c, 'PRJ - Enable ALK CoPilot', 'Enable CoPilot', caseList, 'HubAdmin');             
                    createCase(cicerOwnerId, recordTypeId, lineItem.Opportunity.AccountId, lineItem.Opportunity.Primary_Contact__c, 'PRJ - ALK CoPilot provide documentation/instructions', 'Email Documentation and instructions', caseList, 'CICER');                  
                  }
                  else if (productCode == 'OV COPILOT ROUTE') {
                    createCase(hubAdminOwnerId, recordTypeId, lineItem.Opportunity.AccountId, lineItem.Opportunity.Primary_Contact__c, 'PRJ - Enable ALK CoPilot RouteSync', 'Enable CoPilot RouteSync', caseList, 'HubAdmin');             
                    createCase(cicerOwnerId, recordTypeId, lineItem.Opportunity.AccountId, lineItem.Opportunity.Primary_Contact__c, 'PRJ - ALK CoPilot RouteSync provide documentation/instructions', 'Email Documentation and instructions', caseList, 'CICER');                  
                  }
                  else if (productCode == 'AAD') {
                    createCase(hubAdminOwnerId, recordTypeId, lineItem.Opportunity.AccountId, lineItem.Opportunity.Primary_Contact__c, 'PRJ - Automated Arrival & Departure', 'Enabled AAD', caseList, 'HubAdmin');   
                  }
                  else if (productCode == 'OV DRIVER WORKFLOW') {
                    createCase(hubAdminOwnerId, recordTypeId, lineItem.Opportunity.AccountId, lineItem.Opportunity.Primary_Contact__c, 'PRJ - Enable Driver Workflow', 'Enable WF', caseList, 'HubAdmin');   
                  }
                  else if (productCode == 'MIPR 5 TERR') {
                    createCase(hubAdminOwnerId, recordTypeId, lineItem.Opportunity.AccountId, lineItem.Opportunity.Primary_Contact__c, 'PRJ - Frequent Mobile Initiated Position Reporting', 'Enable Frequent MIPR', caseList, 'HubAdmin');   
                  }
                  else if (productCode == 'OV QHOS MOBILE') {
                    createCase(hubAdminOwnerId, recordTypeId, lineItem.Opportunity.AccountId, lineItem.Opportunity.Primary_Contact__c, 'PRJ - Enable Hours of Service', 'Enable HOS', caseList, 'HubAdmin');             
                    createCase(cicerOwnerId, recordTypeId, lineItem.Opportunity.AccountId, lineItem.Opportunity.Primary_Contact__c, 'PRJ - Setup Hours of Service and provide documentation and setup instructions', 'Help client setup and configure as well as provide setup instructions and documentation', caseList, 'CICER');                  
                  }
                  else if (productCode == 'OV ICS') {
                    createCase(hubAdminOwnerId, recordTypeId, lineItem.Opportunity.AccountId, lineItem.Opportunity.Primary_Contact__c, 'PRJ - Enable In-cab scanning', 'Enabled Scanning', caseList, 'HubAdmin');             
                    createCase(cicerOwnerId, recordTypeId, lineItem.Opportunity.AccountId, lineItem.Opportunity.Primary_Contact__c, 'PRJ - Setup In-cab scanning and provide documentation and setup instructions', 'Email Documentation and instructions', caseList, 'CICER');                  
                  }
                  else if (productCode == 'OV EH ICS') {
                    createCase(hubAdminOwnerId, recordTypeId, lineItem.Opportunity.AccountId, lineItem.Opportunity.Primary_Contact__c, 'PRJ - Enable In-cab scanning- enhanced', 'Enable Enhanced Scanning', caseList, 'HubAdmin');             
                    createCase(cicerOwnerId, recordTypeId, lineItem.Opportunity.AccountId, lineItem.Opportunity.Primary_Contact__c, 'PRJ - Setup Enhanced Scanning', 'Setup enhanced scanning', caseList, 'CICER');                  
                  }
                  else if (productCode == 'OV MMS') {
                    createCase(hubAdminOwnerId, recordTypeId, lineItem.Opportunity.AccountId, lineItem.Opportunity.Primary_Contact__c, 'PRJ - Enable Media Manager', 'Enable MMS', caseList, 'HubAdmin');             
                    createCase(cicerOwnerId, recordTypeId, lineItem.Opportunity.AccountId, lineItem.Opportunity.Primary_Contact__c, 'PRJ - Media Manager provide documentation and setup instructions', 'Email Documentation and instructions', caseList, 'CICER');                  
                  }
                  /*else if (productCode == 'OV VEHICLE PERFORMANCE') {
                    createCase(hubAdminOwnerId, recordTypeId, lineItem.Opportunity.AccountId, lineItem.Opportunity.Primary_Contact__c, 'PRJ - Enable Performance Monitoring', 'Enable PM', caseList, 'HubAdmin');             
                    createCase(cicerOwnerId, recordTypeId, lineItem.Opportunity.AccountId, lineItem.Opportunity.Primary_Contact__c, 'PRJ - Performance Monitoring provide documentation and setup instructions', 'Email Documentation and instructions', caseList, 'CICER');                  
                  }*/
                  else if (productCode == 'OV EF') {
                    createCase(hubAdminOwnerId, recordTypeId, lineItem.Opportunity.AccountId, lineItem.Opportunity.Primary_Contact__c, 'PRJ - Enable Exact Fuel Basic', 'Enable Exact Fuel', caseList, 'HubAdmin');             
                    createCase(cicerOwnerId, recordTypeId, lineItem.Opportunity.AccountId, lineItem.Opportunity.Primary_Contact__c, 'PRJ - Exact Fuel Basic provide documentation and setup instructions', 'Email Documentation and instructions', caseList, 'CICER');                  
                  }
                  else if (productCode == 'OV TPM') {
                    createCase(hubAdminOwnerId, recordTypeId, lineItem.Opportunity.AccountId, lineItem.Opportunity.Primary_Contact__c, 'PRJ - Tire pressure Monitoring', 'Enabled Tire Pressure Monitoring', caseList, 'HubAdmin');  
                  }
                  else if (productCode == 'OV ABS') {
                    createCase(hubAdminOwnerId, recordTypeId, lineItem.Opportunity.AccountId, lineItem.Opportunity.Primary_Contact__c, 'PRJ - Trailer ABS Connect', 'Enable Trailer ABS Connect', caseList, 'HubAdmin');  
                  }
                  else if (productCode == 'OV VIR') {
                    createCase(hubAdminOwnerId, recordTypeId, lineItem.Opportunity.AccountId, lineItem.Opportunity.Primary_Contact__c, 'PRJ - Enable Vehicle Inspection Report', 'Enable OmniVIR', caseList, 'HubAdmin');  
                    createCase(cicerOwnerId, recordTypeId, lineItem.Opportunity.AccountId, lineItem.Opportunity.Primary_Contact__c, 'PRJ - Vehicle Inspection Report provide documentation and setup instructions', 'Email Documentation and instructions', caseList, 'CICER');                  
                  }
                  else if (productCode == 'OV DWPC') {
                    createCase(hubAdminOwnerId, recordTypeId, lineItem.Opportunity.AccountId, lineItem.Opportunity.Primary_Contact__c, 'PRJ - Enable Weigh Station Bypass', 'Enable DriveWyze', caseList, 'HubAdmin');  
                    createCase(cicerOwnerId, recordTypeId, lineItem.Opportunity.AccountId, lineItem.Opportunity.Primary_Contact__c, 'PRJ - Setup Weigh Station Bypass', 'Setup DriveWyze account and provide details to client', caseList, 'CICER');                  
                  }
                  else if (productCode == 'OV DWA') {
                    createCase(hubAdminOwnerId, recordTypeId, lineItem.Opportunity.AccountId, lineItem.Opportunity.Primary_Contact__c, 'PRJ - Enable Weigh Station Bypass (Analytics)', 'Enable DriveWyze (Analytics)', caseList, 'HubAdmin');  
                    createCase(cicerOwnerId, recordTypeId, lineItem.Opportunity.AccountId, lineItem.Opportunity.Primary_Contact__c, 'PRJ - Setup Weigh Station Bypass (Analytics)', 'Setup DriveWyze account and provide details to client', caseList, 'CICER');                  
                  }
                  else if (productCode == 'OV DWPC-ONADD') {
                    createCase(hubAdminOwnerId, recordTypeId, lineItem.Opportunity.AccountId, lineItem.Opportunity.Primary_Contact__c, 'PRJ - Enable Weigh Station Bypass - Ontario (Add-on to US)', 'Enable DriveWyze (Ontario add on to US)', caseList, 'HubAdmin');  
                    createCase(cicerOwnerId, recordTypeId, lineItem.Opportunity.AccountId, lineItem.Opportunity.Primary_Contact__c, 'PRJ - Setup Weigh Station Bypass - Ontario (Add-on to US)', 'Setup DriveWyze account and provide details to client', caseList, 'CICER');                  
                  }
                  else if (productCode == 'OV DWPC-ON') {
                    createCase(hubAdminOwnerId, recordTypeId, lineItem.Opportunity.AccountId, lineItem.Opportunity.Primary_Contact__c, 'PRJ - Enable Weigh Station Bypass Ontario Only OV DWPC-ON', 'Enable DriveWyze Ontario Only', caseList, 'HubAdmin');  
                    createCase(cicerOwnerId, recordTypeId, lineItem.Opportunity.AccountId, lineItem.Opportunity.Primary_Contact__c, 'PRJ - Setup Weigh Station Bypass ( Ontario Only)', 'Setup DriveWyze account and provide details to client', caseList, 'CICER');                  
                  }
                  else if (productCode == 'WSB-ABC') {
                    createCase(hubAdminOwnerId, recordTypeId, lineItem.Opportunity.AccountId, lineItem.Opportunity.Primary_Contact__c, 'PRJ - Enable Weigh Station Bypass Alberta PIC', 'Enable DriveWyze Alberta PIC', caseList, 'HubAdmin');  
                    createCase(cicerOwnerId, recordTypeId, lineItem.Opportunity.AccountId, lineItem.Opportunity.Primary_Contact__c, 'PRJ - Setup Weigh Station Bypass (Alberta PIC)', 'Setup DriveWyze account and provide details to client', caseList, 'CICER');                  
                  }
                  else if (productCode == 'HOS-AUTO') {
                    createCase(hubAdminOwnerId, recordTypeId, lineItem.Opportunity.AccountId, lineItem.Opportunity.Primary_Contact__c, 'PRJ - Setup Border Crossing - HOS Auto Switch', 'Enable Portal Integration', caseList, 'HubAdmin');  
                    createCase(cicerOwnerId, recordTypeId, lineItem.Opportunity.AccountId, lineItem.Opportunity.Primary_Contact__c, 'PRJ - Setup Border Crossing - HOS Auto Switch', 'Initiate Grove Setup', caseList, 'CICER');                  
                  }
                  else if (productCode == 'C-TPAT') {
                    createCase(cicerOwnerId, recordTypeId, lineItem.Opportunity.AccountId, lineItem.Opportunity.Primary_Contact__c, 'PRJ - Setup C-TPAT', 'Enable CTPAT Template, intiate Grove Setup, EMail documentation', caseList, 'CICER');                  
                  }
                  else if (productCode == 'GROVE-DVIR') {
                    createCase(hubAdminOwnerId, recordTypeId, lineItem.Opportunity.AccountId, lineItem.Opportunity.Primary_Contact__c, 'PRJ - Enable Grove DVIR', 'Enable Workflow', caseList, 'HubAdmin');  
                    createCase(cicerOwnerId, recordTypeId, lineItem.Opportunity.AccountId, lineItem.Opportunity.Primary_Contact__c, 'PRJ - Setup Grove DVIR', 'Initiate Grove setup, provide instrucations and documentation', caseList, 'CICER');                  
                  }
                  else if (productCode == 'GROVE-F-HOS') {
                    createCase(hubAdminOwnerId, recordTypeId, lineItem.Opportunity.AccountId, lineItem.Opportunity.Primary_Contact__c, 'PRJ - Setup Finesse-HOS', 'Enable Portal Integration', caseList, 'HubAdmin');  
                    createCase(cicerOwnerId, recordTypeId, lineItem.Opportunity.AccountId, lineItem.Opportunity.Primary_Contact__c, 'PRJ - Setup Finesse-HOS', 'Initiate Grove setup, provide instructions and documentation', caseList, 'CICER');                  
                  }
                  else if (productCode == 'GROVE-PAY') {
                    createCase(cicerOwnerId, recordTypeId, lineItem.Opportunity.AccountId, lineItem.Opportunity.Primary_Contact__c, 'PRJ - Setup Payroll (Basic)', 'Enable Payroll, Work with client to setup payroll', caseList, 'CICER');                  
                  }
                  else if (productCode == 'OV-SDM') {
                    createCase(hubAdminOwnerId, recordTypeId, lineItem.Opportunity.AccountId, lineItem.Opportunity.Primary_Contact__c, 'PRJ - SG Setup and Config', 'Configure Speed Guage', caseList, 'HubAdmin');  
                    createCase(cicerOwnerId, recordTypeId, lineItem.Opportunity.AccountId, lineItem.Opportunity.Primary_Contact__c, 'PRJ - SG Training request', 'Setup Training', caseList, 'CICER');                  
                  }
                  else if (productCode == 'OV-SDM-ME') {
                    createCase(hubAdminOwnerId, recordTypeId, lineItem.Opportunity.AccountId, lineItem.Opportunity.Primary_Contact__c, 'PRJ - SG Setup and Config Managers Edition', 'Configure Speed Guage Managers Edition', caseList, 'HubAdmin');  
                    createCase(cicerOwnerId, recordTypeId, lineItem.Opportunity.AccountId, lineItem.Opportunity.Primary_Contact__c, 'PRJ - SG Training request Managers Edition', 'Setup Training Managers Edition', caseList, 'CICER');                  
                  }
                  else if (productCode == 'GROVE-SCORE') {
                    createCase(cicerOwnerId, recordTypeId, lineItem.Opportunity.AccountId, lineItem.Opportunity.Primary_Contact__c, 'PRJ - Setup Scorecard Portal', 'Enabled Grove Scorecard', caseList, 'CICER');                  
                  }
                  else if (productCode == 'ELM') {
                    createCase(cicerOwnerId, recordTypeId, lineItem.Opportunity.AccountId, lineItem.Opportunity.Primary_Contact__c, 'PRJ - ExpressLane - Mobile', 'Enable Expresslane', caseList, 'CICER');                  
                  }
                  else if (productCode == 'DISA-IFTA') {    
                    createCase(cicerOwnerId, recordTypeId, lineItem.Opportunity.AccountId, lineItem.Opportunity.Primary_Contact__c, 'PRJ - Setup Weigh Station Bypass (Analytics)', 'Setup DriveWyze account and provide details to client', caseList, 'CICER');                  
                  createCase(hubAdminOwnerId, recordTypeId, lineItem.Opportunity.AccountId, lineItem.Opportunity.Primary_Contact__c, 'PRJ - Setup Fuel Tax Automation (IFTA) - DISA', 'Enable Integration', caseList, 'HubAdmin');  
                    createCase(cicerOwnerId, recordTypeId, lineItem.Opportunity.AccountId, lineItem.Opportunity.Primary_Contact__c, 'PRJ - Setup Fuel Tax Automation (IFTA) - DISA', 'Email Documentation', caseList, 'CICER');                  
                  }
                  else if (productCode == 'OT1-FT') {
                    createCase(cicerOwnerId, recordTypeId, lineItem.Opportunity.AccountId, lineItem.Opportunity.Primary_Contact__c, 'PRJ - Tax Manager Setup', 'Request Tax Manager Setup, create customer portal credentials', caseList, 'Omnitracs Canada ICER');                  
                  }
                System.debug('Created Tasks for User: ' + userId);
            }
        }
        if(taskList.size() > 0){
            Database.DMLOptions dlo = new Database.DMLOptions();
            dlo.EmailHeader.triggerUserEmail = true;
            for(Task task: taskList){
                task.setOptions(dlo);
            }
            Database.insert(taskList, dlo);
        }
        if(caseList.size() > 0)
            insert caseList;
        System.debug(caseList);
    }
   
    public static void createTask(Id ownerId, Id optyId, String subject, String status, Integer triggerDueDay, List<Task> taskList){
        Task task = new Task(OwnerId = ownerId, Subject = subject, Status = status, Priority = 'Normal', WhatId = optyId, ActivityDate =  date.today()+triggerDueDay);
        taskList.add(task);
    }
    
    public static void createCase(Id ownerId, Id recordTypeId, Id accountId, Id contactId, String subject, String descr, List<Case> caseList, String type){
        String caseOrigin = (type == 'HubAdmin' ? 'Email-HubAdmin' : 'Salesforce');
        String category = (type == 'HubAdmin' ? 'HubAdmin' : 'New Install/Implementation');
        String queue = (type == 'HubAdmin' ? 'HubAdmin' : 'CICER');
        String level2 = (type == 'HubAdmin' ? 'Activate Service/Feature-HubAdm' : 'Training');
        caseList.add(new Case(Description =  descr, Priority = '2-Medium', AccountId = accountId, ContactId = contactId, Business_Unit__c = 'Omnitracs Canada', Status = 'New - Unassigned', Substatus__c = '', Subject = subject, Origin = caseOrigin, RecordTypeId = recordTypeId, OwnerId = ownerId, Category__c = category, Queue__c = queue, Type_Level_2__c = level2, Do_Not_Send_Closure_Email__c = TRUE));
    }
    
}