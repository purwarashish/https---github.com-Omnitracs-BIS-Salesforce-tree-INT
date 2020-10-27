/*
 *  @Author:        Mark David De Chavez
 *  @Date-created:  October 15, 2014
 *  @Description:   test class for CsCaseTimeSummaryController 
 *  @Last-updated:
 */

@isTest(SeeAllData=True)
public class CsCaseTimeSummaryControllerTest {
    
    static testMethod void testDisplayCsCaseTimeSummary() {
       //Create Dummy test data
        
        Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Contact; 
        Map<String,Schema.RecordTypeInfo> ContactRecordTypeInfo = cfrSchema.getRecordTypeInfosByName();         
        Id ctId = ContactRecordTypeInfo.get('Resource').getRecordTypeId();
        
        Account testAcc = new Account(Name='Test Account', Phone='838-777-0340', 
                                      Account_Type__c='Association', /*District__c='West District 1',*/ 
                                      QWBS_Market__c='T&L', QWBS_Status__c='Active Prospect',
                                      BillingState='CA',BillingCountry='US');
        insert testAcc;

        Profile p = [SELECT Id FROM Profile WHERE Name='PSE - Management' LIMIT 1]; 
        //Querying from Id field
        id Uid = UserInfo.getUserId();
        User testUsr = [Select Id,Name FROM User WHERE Id =: Uid];              

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
        
        //System.runAs(testUsr){
            
            
            SYstem.debug('**testusr: '+ testUsr.Id);
            SYstem.debug('**testcon: '+ testCon.Id);
            Test.startTest();
                //Database.executeBatch(new TimeCardBatch(false));
            Test.stopTest();
        
            PageReference currentPage = page.CsCaseTimeSummaryPage;
            Test.setCurrentPage(currentPage);
            
            CsCaseTimeSummaryController controller = new CsCaseTimeSummaryController();  
            controller.dateCtrl = 'prev';
            Date lastEndDate = controller.endDate;
            controller.mapEndingDate();
            System.assertEquals(lastEndDate.addDays(-7), controller.endDate);
           
        //}

        List<pse__Timecard_Header__c> tmcardCheckList = [SELECT Id, pse__Project__r.pse__Account__r.Id, pse__Resource__r.pse__Salesforce_User__c, pse__Project__r.pse__Project_Type__c, pse__Total_Hours__c,
                                                         pse__Sunday_Hours__c, pse__Monday_Hours__c, pse__Tuesday_Hours__c, pse__Wednesday_Hours__c, pse__Thursday_Hours__c, pse__Friday_Hours__c, pse__Saturday_Hours__c  
                                                         FROM pse__Timecard_Header__c 
                                                         WHERE (pse__Start_Date__c = : Date.today().toStartofWeek() AND pse__End_Date__c = : Date.today().toStartofWeek().addDays(6)) 
                                                         AND pse__Resource__r.pse__Salesforce_User__c =: testUsr.Id];
        System.debug('**tmcard2323: '+ tmcardCheckList);
        
        //System.assertEquals(.50, tmcardCheckList[0].pse__Total_Hours__c);
    }
    
    static testMethod void testDisplayNonCsCaseTimeSummary() {
       //Create Dummy test data
        
        Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Contact; 
        Map<String,Schema.RecordTypeInfo> ContactRecordTypeInfo = cfrSchema.getRecordTypeInfosByName();         
        Id ctId = ContactRecordTypeInfo.get('Resource').getRecordTypeId();
        
        Account testAcc = new Account(Name='TestAcc', Phone='838-77-03', 
                                      Account_Type__c='Association', /*District__c='Canada',*/ 
                                         QWBS_Market__c='T&L', QWBS_Status__c='Active Prospect');
                                   
        Test.starttest();
        insert testAcc;

        Profile p = [SELECT Id FROM Profile WHERE Name='PSE - Management' LIMIT 1]; 
        
        User testUsr = [Select Id FROM User WHERE Id =: UserInfo.getUserId() LIMIT 1];              

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
        
        pse__Proj__c testProj = new pse__Proj__c(pse__Account__c = testAcc.Id, Name = 'Test Project', pse__Project_Type__c = 'Customer', pse__Start_Date__c = Date.today(), pse__End_Date__c = Date.today().addDays(20),
                                                   pse__Region__c = testReg.Id, pse__Practice__c = testPrac.Id, pse__Allow_Self_Staffing__c = true,
                                                   pse__Group__c = testGroup.Id, Time_Approval_Method__c = 'Direct Manager', pse__Is_Active__c = true);                
        insert testProj;
        test.stoptest();
        pse__Schedule__c sched = new pse__Schedule__c();
        sched.pse__Start_Date__c = Date.today().toStartofWeek();
        sched.pse__End_Date__c = Date.today().toStartofWeek().addDays(6);
        insert sched;
        
        pse__Assignment__c insertAsgn = new pse__Assignment__c();
        insertAsgn.pse__Resource__c = testCon.Id;
        insertAsgn.pse__Project__c = testProj.Id;
        insertAsgn.pse__Bill_Rate__c = 0;
        insertAsgn.pse__Schedule__c = sched.id;
        insert insertAsgn;
        
        
        pse__Timecard_Header__c tCard = new pse__Timecard_Header__c();
        tCard.pse__Status__c = 'Saved';
        tCard.pse__Resource__c = testCon.Id;
        tCard.pse__Project__c = testProj.Id;
        tCard.pse__Start_Date__c = Date.today().toStartofWeek();
        tCard.pse__End_Date__c = Date.today().toStartofWeek().addDays(6);
        tCard.pse__Assignment__c = insertAsgn.Id;                               
        tCard.pse__Sunday_Hours__c = 0;
        tCard.pse__Monday_Hours__c = 0;
        tCard.pse__Tuesday_Hours__c = 1;
        tCard.pse__Wednesday_Hours__c = 0;
        tCard.pse__Thursday_Hours__c = 0;
        tCard.pse__Friday_Hours__c = 0;
        tCard.pse__Saturday_Hours__c = 0;       
        insert tCard;
        //System.runAs(testUsr){
            
            
            SYstem.debug('**testusr: '+ testUsr.Id);
            SYstem.debug('**testcon: '+ testCon.Id);
            
               // Database.executeBatch(new TimeCardBatch(false));
            
        
            PageReference currentPage = page.CsCaseTimeSummaryPage;
            Test.setCurrentPage(currentPage);
            
            CsCaseTimeSummaryController controller = new CsCaseTimeSummaryController();  
            controller.dateCtrl = 'next';
            Date lastEndDate = controller.endDate;
            controller.mapEndingDate();
            System.assertEquals(lastEndDate.addDays(7), controller.endDate);
           
        //}

        List<pse__Timecard_Header__c> tmcardCheckList = [SELECT Id, pse__Project__r.pse__Account__r.Id, pse__Resource__r.pse__Salesforce_User__c, pse__Project__r.pse__Project_Type__c, pse__Total_Hours__c,
                                                         pse__Sunday_Hours__c, pse__Monday_Hours__c, pse__Tuesday_Hours__c, pse__Wednesday_Hours__c, pse__Thursday_Hours__c, pse__Friday_Hours__c, pse__Saturday_Hours__c  
                                                         FROM pse__Timecard_Header__c 
                                                         WHERE (pse__Start_Date__c = : Date.today().toStartofWeek() AND pse__End_Date__c = : Date.today().toStartofWeek().addDays(6)) 
                                                         AND pse__Resource__r.pse__Salesforce_User__c =: testUsr.Id];
        System.debug('**tmcard2323: '+ tmcardCheckList);
        
        System.assertEquals(1, tmcardCheckList[0].pse__Total_Hours__c);
    }
    
}