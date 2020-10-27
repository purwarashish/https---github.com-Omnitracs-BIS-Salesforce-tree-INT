/*
 *  @Author:        Mark David De Chavez
 *  @Date-created:  October 1, 2014
 *  @Description:   Tests Create/update FinancialForce Timecards (pse__Timecard_Header__c) 
 *                  based on Case Time entries, which are attached to Cases.
 */

@isTest(SeeAllData=True)
global class DateRTimeCardBatchTest { 

    static testMethod void testCreateTimeCard(){
        
        Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Contact; 
        Schema.DescribeSObjectResult accSchema = Schema.SObjectType.Account; 
        Map<String,Schema.RecordTypeInfo> ContactRecordTypeInfo = cfrSchema.getRecordTypeInfosByName();  
        Map<String,Schema.RecordTypeInfo> AccountRecordTypeInfo = accSchema.getRecordTypeInfosByName();  
        Id ctId = ContactRecordTypeInfo.get('Resource').getRecordTypeId();
        Id accId = AccountRecordTypeInfo.get('T&L Sales Accounts').getRecordTypeId();
        Account testAcc = new Account(Name='TestAcc', Phone='838-77-03', Account_Type__c='Association', /*District__c='Canada',*/ Account_Classification__c = 'Prospect', Ranking__c = 'Regional',
                                      RFC_ID__c = 'test', Primary_Business_Unit__c='Omnitracs Domestic', QWBS_Market__c='Other', QWBS_Status__c='Active Prospect', RecordTypeId = accId);
        insert testAcc;
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User' LIMIT 1];         
        User testUsr =[Select id, Alias, profileId from User where profileId=: p.Id AND isActive=True LIMIT 1];
        
        pse__Region__c testReg = new pse__Region__c();
        testReg.Name='Corporate';
        insert testReg;
        
        pse__Practice__c testPrac = new pse__Practice__c();
        testPrac.Name='Customer Support';
        insert testPrac;
        
        pse__Grp__c testGroup = new pse__Grp__c();
        testGroup.Name='Corporate';
        insert testGroup;
        
        pse__Time_Period__c testTimePeriod = new pse__Time_Period__c();
        testTimePeriod.Name = 'All Time Periods';
        testTimePeriod.pse__Start_Date__c = date.newInstance(Date.today().year(), 01, 01);
        testTimePeriod.pse__End_Date__c = date.newInstance(Date.today().year(), 12, 31);
        insert testTimePeriod;

        Contact testCon = new Contact( LastName='Test Last Name1');
        testCon.AccountId = testAcc.Id;
        testCon.Title='Title Name1';
        testCon.pse__Region__c=testReg.Id;
        testCon.pse__Practice__c=testPrac.Id;
        testCon.pse__Group__c=testGroup.Id;
        testCon.Phone = '(111) 111-1111';
        testCon.pse__Salesforce_User__c = testUsr.Id;
        testCon.pse__Is_Resource__c = true;
        testCon.pse__Is_Resource_Active__c = true;
        testCon.RecordTypeId = ctId;
        insert testCon;  
        
        pse__Proj__c testProj = new pse__Proj__c(pse__Account__c = testAcc.Id, Name = 'Test Project', pse__Project_Type__c = 'Customer Support', pse__Start_Date__c = Date.today(), pse__End_Date__c = Date.today().addDays(20),
                                                   pse__Region__c = testReg.Id, pse__Practice__c = testPrac.Id, pse__Allow_Self_Staffing__c = true,
                                                   pse__Group__c = testGroup.Id, Time_Approval_Method__c = 'Direct Manager', pse__Is_Active__c = true);                
        insert testProj;
        
        checkRecursiveAfter.resetRunOnceFlag();
        
        Case testCase = new Case(Subject = 'testCase', AccountId = testAcc.Id, Work_Effort_In_Minutes__c = 30, Status = 'Open', Category__c = 'Admin',  Type_Level_2__c = 'Cust Request',
                                     Description = 'Test Description', ContactId=testCon.Id);
        insert testCase;     
        System.debug('****caseTimeEntry: ' +  [Select Owner__c FROM MIBOS_Case_Time__c WHERE Case__r.Id =: testCase.Id]);
        
        MIBOS_Case_Time__c caseTimeEntry = new MIBOS_Case_Time__c(Case__c = testCase.Id, Owner__c = testUsr.Id, Work_Effort__c = 30, Sync__c = true);        
        insert caseTImeEntry;
        
        List<MIBOS_Case_Time__c> caseTimeEntryList = [Select Owner__c, CreatedDate FROM MIBOS_Case_Time__c WHERE Case__r.Id =: testCase.Id];
        for (MIBOS_Case_Time__c mct : caseTimeEntryList) {
            mct.Owner__c = testUsr.Id;
            mct.Sync__c = false;
            mct.Synched_Time__c = 5;
            mct.Last_Synched__c = Date.today().addDays(-1);            
        }        
        update caseTimeEntryList;
        //System.assertEquals(caseTimeEntryList.size() , 2);   
        System.debug('***afterINsert: ' + caseTimeEntryList);
        System.debug('**dateToday: ' + DateTime.now().DateGMT());
        System.debug('**dateTodayStartOfweek: '+ DateTime.now().DateGMT().toStartofWeek());
        System.debug('**dateTodayStartOfweek: '+ DateTime.now().DateGMT().toStartofWeek().addDays(6));
        
        System.runAs(testUsr){
            SYstem.debug('**testusr: '+ testUsr.Id);
            SYstem.debug('**testcon: '+ testCon.Id);
            Test.startTest();
                //Database.executeBatch(new DateRTimeCardBatch(false, date.today(), date.today().addDays(6)));
            Test.stopTest();
        }
                
        List<pse__Timecard_Header__c> tmcardCheckList = [SELECT Id 
                                                         FROM pse__Timecard_Header__c 
                                                         WHERE pse__Resource__r.Id = : testCon.Id 
                                                         AND pse__Project__r.pse__Account__c = : testAcc.Id];           
    }        
}