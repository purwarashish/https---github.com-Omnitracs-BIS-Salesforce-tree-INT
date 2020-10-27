@isTest(seeAllData = true)
public class FFProjectBillingTest {
    public static testmethod void testBillingAutomation(){
    
        Date billingDate = Date.today();
        List<pse__Proj__c> lstProj = new List<pse__Proj__c>();
        List<pse__Region__c> lstRegion = new List<pse__Region__c>();
         
        Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Contact; 
        Map<String,Schema.RecordTypeInfo> ContactRecordTypeInfo = cfrSchema.getRecordTypeInfosByName();         
        Id ctId = ContactRecordTypeInfo.get('Resource').getRecordTypeId();
        
        Schema.DescribeSObjectResult pfrSchema = Schema.SObjectType.pse__Proj__c; 
        Map<String,Schema.RecordTypeInfo> ProjectecordTypeInfo = pfrSchema.getRecordTypeInfosByName();         
        Id projectId = ProjectecordTypeInfo.get('Customer Project').getRecordTypeId();
        
        Test.starttest(); 
        Account testAcc = new Account();
        testAcc.Name = 'Test Account';
        testAcc.Phone = '838-777-0340';
        testAcc.Account_Type__c = 'Association';
        //testAcc.District__c = 'West District 1';
        testAcc.QWBS_Market__c = 'T&L' ;
        testAcc.QWBS_Status__c = 'Active Prospect';
        testAcc.BillingState = 'CA';
        testAcc.BillingCountry = 'US';
        testAcc.Segment__c = 'TL';
        insert testAcc;
        
        Contact testCon = new Contact(LastName='Test Last Name1');
        testCon.AccountId = testAcc.Id;
        testCon.Title='Title Name1';
        testCon.Phone = '(111) 111-1111';
        testCon.pse__Salesforce_User__c = UserInfo.getUserId();
        testCon.pse__Is_Resource__c = true;
        testCon.pse__Is_Resource_Active__c = true;
        testCon.RecordTypeId = ctId;
        insert testCon; 
        pse__Proj__c testProj = new pse__Proj__c();
        testProj.pse__Account__c = testAcc.Id;
        testProj.Name = 'Test Project';
        testProj.pse__Project_Type__c = 'Customer Support'; 
        testProj.pse__Start_Date__c = Date.today();
        testProj.pse__End_Date__c = Date.today().addDays(20);
        testProj.pse__Allow_Self_Staffing__c = true;
        testProj.Time_Approval_Method__c = 'Direct Manager';
        testProj.pse__Is_Active__c = true;
        testProj.pse__Exclude_From_Billing__c = true;
        testProj.pse__Billing_Type__c = 'Time and Materials';
        testProj.pse__Stage__c = 'In Progress';
        testProj.RecordTypeId = projectId; 
        insert testProj;       
        lstProj.add(testProj);
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
        
        pse__Timecard__c objTimeCard = new pse__Timecard__c();
        objTimeCard.pse__Total_Billable_Amount__c = 10.00;
        objTimeCard.pse__Approved__c = true;
        objTimeCard.pse__Status__c = 'Approved';
        objTimeCard.pse__Project__c = testProj.Id;
        objTimeCard.pse__Billable__c = true;
        objTimeCard.pse__Invoiced__c = false;
        objTimeCard.pse__Billed__c = false;
        objTimeCard.pse__End_Date__c = billingdate;
        objTimeCard.pse__Resource__c = testCon.Id;
        objTimeCard.pse__Assignment__c = insertAsgn.Id;
        objTimeCard.pse__Timecard_Header__c = tCard.Id;
        insert objTimeCard;
        
        FFProjectBillingController pbController = new FFProjectBillingController();
        pbController.getAllProjects();
        pbController.updateBillableProjects();
        pbController.exportToExcel();
        List<Id> timecardIds = new List<Id> {objTimeCard.Id};
        Database.executeBatch(new FFUpdateModeBillingReleaseInvoiceBatch(lstProj, timecardIds));
    }
}