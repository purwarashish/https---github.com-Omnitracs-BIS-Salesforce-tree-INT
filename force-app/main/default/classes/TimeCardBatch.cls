/*
 *  @Author:        Mark David De Chavez
 *  @Date-created:  September 29, 2014
 *  @Description:   Create/update FinancialForce Timecards (pse__Timecard_Header__c) 
 *                  based on Case Time entries, which are attached to Cases.
 *  @last-update:   October 29, 2014 | Mark David De Chavez | Insert a project if doesn't exist for an Account with Case Time Entry record
 */

global class TimeCardBatch implements Database.Batchable<sObject>, Database.Stateful {
    
    global final Boolean sendEmail;
    global list<String> errors;
    
    global TimeCardBatch (Boolean sEmail){
        sendEmail = sEmail;
        errors = new list<String>();
    }
    
    global database.querylocator start(Database.BatchableContext BC) {
        
        //Date startDate = Date.today().toStartofWeek();
        //Date endDate = Date.today().toStartofWeek().addDays(6);
        Date startDate = DateTime.now().DateGMT().toStartofWeek();
        Date endDate = DateTime.now().DateGMT().toStartofWeek().addDays(7);

        return Database.getQueryLocator( [SELECT Id, Case__r.AccountId, Case__r.Account.OwnerId, Case__r.Account.Name, CreatedDate,  Owner__r.Id, Owner__r.Name, Owner__r.Email, Work_Effort__c, Sync__c, Last_Synched__c, Timecard__c, Synched_Time__c
                                          FROM MIBOS_Case_Time__c 
                                          WHERE Sync__c = : true
                                          AND Work_Effort__c <> null
                                          AND Owner__c IN (SELECT pse__Salesforce_User__c FROM Contact)
                                          AND (CreatedDate >= : startDate AND CreatedDate < : endDate)
                                          ] );      

    }

    global void execute(Database.BatchableContext BC, List<MIBOS_Case_Time__c> caseTimeList) {

        System.debug('****case time entries: ' + caseTimeList);
        System.debug('llslssl: '+ caseTimeList[0].Owner__r.Name);
        
        Map<String, pse__Timecard_Header__c> timecardMap = new Map<String, pse__Timecard_Header__c>();
        Map<String, pse__Proj__c> projMap = new Map<String, pse__Proj__c >();
        Map<String, Contact> conMap = new Map<String, Contact>();
        Set<Id> accIdSet = new Set<Id>();
        Set<Id> usrIdSet = new Set<Id>();
        Set<Id> projSet = new Set<Id>();
        Set<Id> conSet = new Set<Id>();
        
        //new
        pse__Grp__c defaultGroup = new pse__Grp__c(Id = SystemIds__c.getInstance().RecordId_pse_defaultGroup__c);
        pse__Region__c defaultRegion = new pse__Region__c(Id=SystemIds__c.getInstance().RecordId_pse_defaultRegion__c);
        pse__Practice__c defaultPractice = new pse__Practice__c(Id=SystemIds__c.getInstance().RecordId_pse_defaultPractice__c);
        pse__Time_Period__c  defaultTimePeriod = new pse__Time_Period__c(Id=SystemIds__c.getInstance().RecordId_pse_defaultTimePeriod__c);
        Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.pse__Proj__c; 
        Map<String,Schema.RecordTypeInfo> projRecordTypeInfo = cfrSchema.getRecordTypeInfosByName();
        
        //for testing
        /*Id testAccId = '001W000000HBcAk';
        Id testAccId2 = '0015000000LG2G0';
        Id testAccId3 = '001W000000HHEBn';
        Id testProjId = 'a5lW00000004F62';
        Id testProjId2 = 'a5lW00000004FDw';        
        Id testUsrId = '005W0000001FO0O';
*/
        for (MIBOS_Case_Time__c mct : caseTimeList){
            //if ( (mct.Case__r.AccountId == testAccId || mct.Case__r.AccountId == testAccId2 || mct.Case__r.AccountId == testAccId3) && mct.Owner__r.Id == testUsrId){ //for testing
                accIdSet.add(mct.Case__r.AccountId);
                usrIdSet.add(mct.Owner__r.Id);
            //}//
        }
        
        System.debug('**accIdSet: '+ accIdSet);
        System.debug('**userIdSet: '+ usrIdSet);
        
        for (Contact con : [SELECT Id, pse__Salesforce_User__r.Id 
                              FROM Contact 
                             WHERE (pse__Salesforce_User__c in : usrIdSet 
                               AND pse__Salesforce_User__c <> null)]){
            //if (con.pse__Salesforce_User__r.Id == testUsrId){ // for testing
                conMap.put(con.pse__Salesforce_User__r.Id, con);
                conSet.add(con.Id);
            //}
        }   
        
        for (pse__Proj__c proj : [ SELECT Id, pse__Account__r.Id, pse__Start_Date__c, pse__End_Date__c 
                                     FROM pse__Proj__c 
                                    WHERE pse__Account__c in : accIdSet 
                                      AND pse__Project_Type__c =: 'Customer Support']){
            //if (proj.Id == testProjId || proj.Id == testProjId2){ // for testing
                projMap.put(proj.pse__Account__r.Id, proj);
            //}
        }
        
        Set<Id> queueIdSet = new Set<Id>();
        
        Map<String, pse__Proj__c> newProjMap = new Map<String, pse__Proj__c>();
                
        //create Proj if Account in Case Time Entry doesn't have any - new
        for (MIBOS_Case_Time__c mct : caseTimeList){
            //List all Account owners with Resource if the Project is not Customer Support, then email Account owners nad resource for notification
            
            if (!projMap.containsKey(mct.Case__r.AccountId) && conMap.containsKey(mct.Owner__r.Id)){
                //if(!queueIdSet.contains(mct.Case__r.AccountId)){
                    /*//if ( (mct.Case__r.AccountId == testAccId || mct.Case__r.AccountId == testAccId2) && mct.Owner__r.Id == testUsrId){ //for testing
                        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                        String[] ccAddress = new String[] {mct.Owner__r.Email};
                        
                        ////for testing purpose only
                        //  Id accOwner = '005W0000001FMrZ';//'005W0000001FMrZ';005W0000001FYY1
                        //  String[] resrc = new String[] {'mark.dechavez@cloudsherpas.com'};
                        //  mail.setTargetObjectId(accOwner); 
                        //  mail.setccAddresses(resrc);
                            
                        
                        mail.setTargetObjectId(mct.Case__r.Account.OwnerId); 
                        mail.setccAddresses(ccAddress);                         
                        mail.setSubject('Missing Project for Account ' + mct.Case__r.Account.Name);
                        String accUrl = 'https://qes--mibos.cs13.my.salesforce.com/' + mct.Case__r.AccountId;
                        mail.setSaveAsActivity(false); 
                        mail.setHtmlBody('A Customer Support Project must be set up for Account '+  mct.Case__r.Account.Name +' before Case Support time can be logged against it.<br/> <a href=' + accUrl +'>Link To Account</a>');
                        mlist.add(mail);
                        queueIdSet.add(mct.Case__r.AccountId);
                    //}*/
                    //if ( (mct.Case__r.AccountId == testAccId || mct.Case__r.AccountId == testAccId2 || mct.Case__r.AccountId == testAccId3) && mct.Owner__r.Id == testUsrId){ //for testing
                        // create proj if doesn't exist  - new
                        
                    
                        pse__Proj__c proj = new pse__Proj__c();
                        if (mct.Case__r.Account.Name.length() <= 62) {
                            proj.Name = 'CS - Case time - ' + mct.Case__r.Account.Name;
                        }
                        else {
                            proj.Name = 'CS - Case time - ' + mct.Case__r.Account.Name.substring(0,62);
                        }
                        proj.pse__Project_Type__c = 'Customer Support';
                        proj.pse__Account__c = mct.Case__r.AccountId;
                        proj.pse__Start_Date__c = Date.today();
                        proj.pse__End_Date__c = Date.today().addYears(5);
                        proj.RecordtypeId = projRecordTypeInfo.get('Customer Project').getRecordTypeId();
                        proj.pse__Group__c = defaultGroup.Id;
                        proj.pse__Practice__c = defaultPractice.Id;
                        proj.pse__Region__c = defaultRegion.Id;
                        proj.pse__Stage__c = 'In Progress';
                        proj.pse__Is_Active__c = true;
                        proj.pse__Include_In_Forecasting__c = true;
                        proj.pse__Exclude_From_Billing__c = true;
                        proj.pse__Exclude_from_Backlog__c = true;
                        proj.pse__Exclude_from_Project_Planner__c = true;
                        proj.pse__Closed_for_Expense_Entry__c = true;
                        proj.pse__Time_Credited__c = true;
                        proj.pse__Is_Template__c = false;
                        proj.Time_Approval_Method__c = 'Direct Manager';
                        proj.pse__Current_Time_Period__c = defaultTimePeriod.Id;  
                
                if (!newProjMap.containsKey(mct.Case__r.AccountId)){
                        newProjMap.put(mct.Case__r.AccountId, proj);
                }
                        //projMap.put(mct.Case__r.AccountId, proj);                        
                        //queueIdSet.add(mct.Case__r.AccountId);
                    //}// 
                //}
            }
        }
        
        //insert newproj
        try {
            insert newProjMap.values();    
        }
        catch(Exception ex) {
            System.debug('**Catch: newProjMap: ' + newProjMap);
            System.debug('**Inserting Projec record failed: '+ ex.getMessage());
            errors.add(ex.getMessage());
        }
        
        //combine
        projMap.putAll(newProjMap);
        
        for (String projId : projMap.keySet()){
            projSet.add(projMap.get(projId).Id);
        }
        
        System.debug('**projSet: '+ projSet);
        System.debug('**projMap: '+ projMap);
        System.debug('**conSet: '+ conSet);
        System.debug('**conMap: '+ conMap);

        Map<String, pse__Assignment__c> asgnMap = new Map<String, pse__Assignment__c>();
        for (pse__Assignment__c asgn : [SELECT Id, pse__Project__c, pse__Resource__c 
                                          FROM pse__Assignment__c 
                                         WHERE pse__Project__c in : projSet 
                                           AND pse__Resource__c in : conSet
                                           AND pse__End_Date__c >= TODAY
                                           ]){
            asgnMap.put(asgn.pse__Project__c + '|' + asgn.pse__Resource__c, asgn);
        }
        //List<Messaging.singleEmailMessage> mlist = new List<Messaging.singleEmailMessage>();      // for sending email        
        
        //List<pse__Assignment__c> insertAsgnList = new List<pse__Assignment__c>();
        Map<String, pse__Assignment__c> insertAsgnMap = new Map<String, pse__Assignment__c>(); //new
        
        //Set<pse__Schedule__c> schedSet = new Set<pse__Schedule__c>();
        Map<Id, pse__Schedule__c> schedToAsgnMap = new Map<Id, pse__Schedule__c>();
        
        for (MIBOS_Case_Time__c mct : caseTimeList){
            //List all projects that doesn't have an Assignemtn record
            if (projMap.containsKey(mct.Case__r.AccountId) && conMap.containsKey(mct.Owner__r.Id)){
                if (!asgnMap.containsKey(projMap.get(mct.Case__r.AccountId).Id + '|' + conMap.get(mct.Owner__r.Id).Id)){
                    pse__Schedule__c sched = new pse__Schedule__c();
                    sched.pse__Start_Date__c = System.today();//projMap.get(mct.Case__r.AccountId).pse__Start_Date__c;
                    sched.pse__End_Date__c   = System.today().addDays(8*7);//projMap.get(mct.Case__r.AccountId).pse__End_Date__c;
                    schedToAsgnMap.put(projMap.get(mct.Case__r.AccountId).Id, sched);
                    
                    pse__Assignment__c insertAsgn = new pse__Assignment__c();
                    insertAsgn.pse__Resource__c = conMap.get(mct.Owner__r.Id).Id;
                    insertAsgn.pse__Project__c = projMap.get(mct.Case__r.AccountId).Id;
                    insertAsgn.pse__Bill_Rate__c = 0;
                    //insertAsgnList.add(insertAsgn);
                    
                    //avoid inserting assignment with same proj and rewource - new 
                    if(!insertAsgnMap.containsKey(conMap.get(mct.Owner__r.Id).Id + '|' + projMap.get(mct.Case__r.AccountId).Id)){ //new
                        insertAsgnMap.put(conMap.get(mct.Owner__r.Id).Id + '|' + projMap.get(mct.Case__r.AccountId).Id, insertAsgn); //new
                    }//new
                }
            }
        }               

        //insert schedules
        if (schedToAsgnMap.size() > 0) {
            try {
                insert schedToAsgnMap.values();    
            }
            catch(Exception ex) {
                System.debug('**Catch: schedToAsgnMap: ' + schedToAsgnMap);
                System.debug('**Inserting schedule record failed: '+ ex.getMessage());
                errors.add(ex.getMessage());
            }           
        }
        
        /*//Assign sched to assignment
        for (pse__Assignment__c asgn : insertAsgnList){
            if (schedToAsgnMap.containskey(asgn.pse__Project__c)) {
                asgn.pse__Schedule__c = schedToAsgnMap.get(asgn.pse__Project__c).Id;
            }
        }*/
        
        //Assign sched to assignment - new
        for (String asgn : insertAsgnMap.keySet()){
            if (schedToAsgnMap.containskey(insertAsgnMap.get(asgn).pse__Project__c)) {
                insertAsgnMap.get(asgn).pse__Schedule__c = schedToAsgnMap.get(insertAsgnMap.get(asgn).pse__Project__c).Id;
            }
        }
        
        /*//insert Asgnment records in the list
        if(insertAsgnList.size() > 0){            
            try {
                insert insertAsgnList;
            }
            catch(Exception ex) {
                System.debug('**Inserting Assignment record failed: '+ ex.getMessage());
            }           
        }*/
        
        //insert Asgnment records in the map - new
        if(insertAsgnMap.size() > 0){            
            try {
                insert insertAsgnMap.values();
            }
            catch(Exception ex) {
                System.debug('**Catch: insertAsgnMap: ' + insertAsgnMap);
                System.debug('**Inserting Assignment record failed: '+ ex.getMessage());
                errors.add(ex.getMessage());
            }           
        }

        //send email
        //if(mlist.size() > 0 && sendEmail){
        //      Messaging.sendEmail(mlist);
        //}

        //query assignment again
        for (pse__Assignment__c asgn : [SELECT Id, pse__Project__c, pse__Resource__c 
                                          FROM pse__Assignment__c 
                                         WHERE pse__Project__c in : projSet 
                                           AND pse__Resource__c in : conSet
                                           AND pse__End_Date__c >= TODAY ]){
            asgnMap.put(asgn.pse__Project__c + '|' + asgn.pse__Resource__c, asgn);
        }

        //query existing time cards for resource and account
        for (pse__Timecard_Header__c tCard : [SELECT Id, pse__Project__r.pse__Account__r.Id, pse__Resource__r.pse__Salesforce_User__c, 
                                              pse__Sunday_Hours__c, pse__Monday_Hours__c, pse__Tuesday_Hours__c, pse__Wednesday_Hours__c, pse__Thursday_Hours__c, pse__Friday_Hours__c, pse__Saturday_Hours__c  
                                               FROM pse__Timecard_Header__c 
                                              WHERE pse__Start_Date__c = : Date.today().toStartofWeek() AND pse__End_Date__c = : Date.today().toStartofWeek().addDays(6)
                                                AND pse__Status__c =: 'Saved'
                                                AND pse__Project__r.pse__Project_Type__c =: 'Customer Support']){
            timecardMap.put(tCard.pse__Project__r.pse__Account__r.Id + '|' + tCard.pse__Resource__r.pse__Salesforce_User__c, tCard);
        }

        // Aggregate Case Time entries based on Date, Account and User. Sum the Work_Effort__c field and convert to hours.
        for (MIBOS_Case_Time__c mct : caseTimeList){
            //if ( (mct.Case__r.AccountId == testAccId || mct.Case__r.AccountId == testAccId2 || mct.Case__r.AccountId == testAccId3) && mct.Owner__r.Id == testUsrId){ //for testing
                //System.debug('*****xxxx: '+ (mct.Case__r.AccountId + '|' + mct.Owner__r.Id) );
                if (timecardMap.containsKey(mct.Case__r.AccountId + '|' + mct.Owner__r.Id) && mct.Work_Effort__c != null){
                    Datetime createdDateTime = (Datetime) mct.CreatedDate;
                    String dayOfWeek = createdDateTime.format('E');                 

                    Decimal hours = (mct.Work_Effort__c - (mct.Synched_Time__c != null ? mct.Synched_Time__c : 0)) / 60;

                    timecardMap.get(mct.Case__r.AccountId + '|' + mct.Owner__r.Id).pse__Sunday_Hours__c = (dayOfWeek == 'Sun' ? timecardMap.get(mct.Case__r.AccountId + '|' + mct.Owner__r.Id).pse__Sunday_Hours__c + hours : timecardMap.get(mct.Case__r.AccountId + '|' + mct.Owner__r.Id).pse__Sunday_Hours__c).setscale(1);
                    timecardMap.get(mct.Case__r.AccountId + '|' + mct.Owner__r.Id).pse__Monday_Hours__c = (dayOfWeek == 'Mon' ? timecardMap.get(mct.Case__r.AccountId + '|' + mct.Owner__r.Id).pse__Monday_Hours__c + hours : timecardMap.get(mct.Case__r.AccountId + '|' + mct.Owner__r.Id).pse__Monday_Hours__c).setscale(1);
                    timecardMap.get(mct.Case__r.AccountId + '|' + mct.Owner__r.Id).pse__Tuesday_Hours__c = (dayOfWeek == 'Tue' ? timecardMap.get(mct.Case__r.AccountId + '|' + mct.Owner__r.Id).pse__Tuesday_Hours__c + hours : timecardMap.get(mct.Case__r.AccountId + '|' + mct.Owner__r.Id).pse__Tuesday_Hours__c).setscale(1);
                    timecardMap.get(mct.Case__r.AccountId + '|' + mct.Owner__r.Id).pse__Wednesday_Hours__c = (dayOfWeek == 'Wed' ? timecardMap.get(mct.Case__r.AccountId + '|' + mct.Owner__r.Id).pse__Wednesday_Hours__c + hours : timecardMap.get(mct.Case__r.AccountId + '|' + mct.Owner__r.Id).pse__Wednesday_Hours__c).setscale(1);
                    timecardMap.get(mct.Case__r.AccountId + '|' + mct.Owner__r.Id).pse__Thursday_Hours__c = (dayOfWeek == 'Thu' ? timecardMap.get(mct.Case__r.AccountId + '|' + mct.Owner__r.Id).pse__Thursday_Hours__c + hours : timecardMap.get(mct.Case__r.AccountId + '|' + mct.Owner__r.Id).pse__Thursday_Hours__c).setscale(1);
                    timecardMap.get(mct.Case__r.AccountId + '|' + mct.Owner__r.Id).pse__Friday_Hours__c = (dayOfWeek == 'Fri' ? timecardMap.get(mct.Case__r.AccountId + '|' + mct.Owner__r.Id).pse__Friday_Hours__c + hours : timecardMap.get(mct.Case__r.AccountId + '|' + mct.Owner__r.Id).pse__Friday_Hours__c).setscale(1);
                    timecardMap.get(mct.Case__r.AccountId + '|' + mct.Owner__r.Id).pse__Saturday_Hours__c = (dayOfWeek == 'Sat' ? timecardMap.get(mct.Case__r.AccountId + '|' + mct.Owner__r.Id).pse__Saturday_Hours__c + hours : timecardMap.get(mct.Case__r.AccountId + '|' + mct.Owner__r.Id).pse__Saturday_Hours__c).setscale(1);                   
                }
                else {
                    if(projMap.containsKey(mct.Case__r.AccountId) && conMap.containsKey(mct.Owner__r.Id) && mct.Work_Effort__c != null){
                        pse__Timecard_Header__c tCard = new pse__Timecard_Header__c();
                        tCard.pse__Status__c = 'Saved';
                        tCard.pse__Resource__c = (conMap.containsKey(mct.Owner__r.Id) ? conMap.get(mct.Owner__r.Id).Id : null);
                        tCard.pse__Project__c = (projMap.containsKey(mct.Case__r.AccountId) ? projMap.get(mct.Case__r.AccountId).Id : null);
                        tCard.pse__Start_Date__c = mct.CreatedDate.date().toStartofWeek();
                        tCard.pse__End_Date__c = mct.CreatedDate.date().toStartofWeek().addDays(6);
                        System.debug('***proj: ' + tCard.pse__Project__c);
                        System.debug('***resrc: ' + tCard.pse__Resource__c);
                        if(String.isNotBlank(tCard.pse__Project__c) && String.isNotBlank(tCard.pse__Resource__c) && asgnMap.containsKey(tCard.pse__Project__c + '|' + tCard.pse__Resource__c)){
                            tCard.pse__Assignment__c = asgnMap.get(tCard.pse__Project__c + '|' + tCard.pse__Resource__c).Id;
                        }

                        Datetime createdDateTime = (Datetime) mct.CreatedDate;
                        String dayOfWeek = createdDateTime.format('E'); 

                        Decimal hours = mct.Work_Effort__c / 60;

                        hours = hours.setscale(1);                      

                        tCard.pse__Sunday_Hours__c = (dayOfWeek == 'Sun' ? hours : 0);
                        tCard.pse__Monday_Hours__c = (dayOfWeek == 'Mon' ? hours : 0);
                        tCard.pse__Tuesday_Hours__c = (dayOfWeek == 'Tue' ? hours : 0);
                        tCard.pse__Wednesday_Hours__c = (dayOfWeek == 'Wed' ? hours : 0);
                        tCard.pse__Thursday_Hours__c = (dayOfWeek == 'Thu' ? hours : 0);
                        tCard.pse__Friday_Hours__c = (dayOfWeek == 'Fri' ? hours : 0);
                        tCard.pse__Saturday_Hours__c = (dayOfWeek == 'Sat' ? hours : 0);

                        System.debug('*****yyyy: '+ (mct.Case__r.AccountId + '|' + mct.Owner__r.Id) );
                        timecardMap.put(mct.Case__r.AccountId + '|' + mct.Owner__r.Id, tCard);
                    }
                }
            //}//
        }
        
        try {
            upsert timecardMap.values();
            //throw new TestException('TEST ERROR 3');
        }
        catch(Exception ex) {
            System.debug('**Catch: timecardMap: ' + timecardMap);
            System.debug('**Upserting pse__timecard_header__c record failed: '+ ex.getMessage());
            errors.add(ex.getMessage());
        }       

        List<MIBOS_Case_Time__c> updateCaseTimeList = new List<MIBOS_Case_Time__c>();
        for (MIBOS_Case_Time__c mct : caseTimeList){
            //if ( (mct.Case__r.AccountId == testAccId || mct.Case__r.AccountId == testAccId2 || mct.Case__r.AccountId == testAccId3) && mct.Owner__r.Id == testUsrId){ //for testing
                if (timecardMap.containsKey(mct.Case__r.AccountId + '|' + mct.Owner__r.Id)){
                    MIBOS_Case_Time__c updateMct = mct;
                    updateMct.Sync__c = false;
                    updateMct.Last_Synched__c = DateTime.now();
                    if(timecardMap.containsKey(mct.Case__r.AccountId + '|' + mct.Owner__r.Id)){
                        updateMct.Timecard__c = timecardMap.get(mct.Case__r.AccountId + '|' + mct.Owner__r.Id).Id;
                    }
                    //updateMct.Timecard__c = timecardMap.get(mct.Case__r.AccountId + '|' + mct.Owner__r.Id).Id;
                    updateMct.Synched_Time__c  = updateMct.Work_Effort__c;
                    updateCaseTimeList.add(updateMct);      
                }
            //} //      
        }
        
        try {
            update updateCaseTimeList;
            //throw new TestException('TEST ERROR 2');
 
        }
        catch(Exception ex) {
            System.debug('**Catch: updateCaseTimeList: ' + updateCaseTimeList);
            System.debug('**Updating MIBOS_Case_Time__c record failed: '+ ex.getMessage());
            errors.add(ex.getMessage());
        } 
        
    }

    global void finish(Database.BatchableContext BC) {
    
        if(errors.size() > 0)
        {
            //
            // Email the errors that occured durring this batch process
            //
            
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            
            String[] toAddresses = new String[] {Label.Error_Email_Address}; 
            //String[] ccAddresses = new String[] {Label.Error_Email_Address};
              
            
            // Assign the addresses for the To and CC lists to the mail object.
            mail.setToAddresses(toAddresses);
            //mail.setCcAddresses(ccAddresses);
            
            // Specify the address used when the recipients reply to the email. 
            mail.setReplyTo('support@omnitracs.com');
            
            // Specify the name used as the display name.
            mail.setSenderDisplayName('Omnitracs Support');
            
            mail.setSubject('ERRORS in TimeCardBatch');
            mail.setSaveAsActivity(false); 
            String ErrorBody = 'The following errors occurred during TimeCardBatch processing:<br/><ol>';
            for(String s : errors)
            {
                ErrorBody += '<li>'+ s +'</li>';
            }
            ErrorBody += '</ol>';
            
            mail.setHtmlBody(ErrorBody);
            
            //send the email
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            
        }

    }
    
    //private class TestException extends Exception{}
}