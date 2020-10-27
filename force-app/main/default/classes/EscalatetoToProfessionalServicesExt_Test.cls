/*
 *  @author:        Mark De Chavez | mark.dechavez@cloudsherpas.com
 *  @description:   Test class for EscalatetoToProfessionalServicesExt
 *  @date-created:  September 11, 2014
 *  @revision: 
 */
@isTest(SeeAllData=True)
public class  EscalatetoToProfessionalServicesExt_Test{
    
    static testMethod void updateCaseRecTest(){
        Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Case; 
        Map<String,Schema.RecordTypeInfo> caseRecordTypeInfo = cfrSchema.getRecordTypeInfosByName();         
        Id ctId = CaseRecordTypeInfo.get('Call Center').getRecordTypeId();
        
        QueueSobject qsObj = new QueueSobject();
        
        Account acc = new Account(Name='TestAcc', Phone='(111) 838-7703', 
                                  Account_Type__c='Association', /*District__c='Canada',*/ 
                                  QWBS_Market__c='T&L', QWBS_Status__c='Active Prospect');                    
        insert acc;
        
        Contact con = new Contact(AccountId = acc.Id, LastName = 'testLast', Title='Test', Phone='(111) 111-1111');
        insert con;
        
        Group group1 = new Group(Name = 'Sylectus Professional Services', Type = 'Queue');
        insert group1;
        
        Group group2 = new Group(Name = 'CNR Professional Services', Type = 'Queue');
        insert group2;                
        
        Case caseRec1 = new Case(AccountId = acc.Id, Work_Effort_In_Minutes__c = 5, ContactId = con.Id, Subject = 'test',
                                Business_Unit__c = 'Sylectus', Category__c = 'Call Center', Origin = 'Phone', Status='New - Unassigned');
        insert caseRec1;
        
        Case caseRec2 = new Case(AccountId = acc.Id, Work_Effort_In_Minutes__c = 5, ContactId = con.Id, Subject = 'test',
                                Business_Unit__c = 'Omnitracs MX', Category__c = 'Call Center', Origin = 'Phone', Status='New - Unassigned');        
        insert caseRec2;
        
        Test.startTest();
            Test.setCurrentPage(Page.EscalateToProfessionalServicesPage);
            EscalatetoToProfessionalServicesExt controller = new EscalatetoToProfessionalServicesExt(new ApexPages.StandardController(caseRec1));
            controller.updateFields();
            Case checkCase = [SELECT RecordType.Name, Owner.Name FROM Case WHERE Id = : caseRec1.Id];
            String idCheck = [SELECT Id, QueueId FROM QueueSobject WHERE Queue.Name = : 'Sylectus Professional Services'].QueueId;
            System.assertEquals('Professional Services', checkCase.RecordType.Name);
            System.assertEquals(idCheck, checkCase.OwnerId);
            controller = new EscalatetoToProfessionalServicesExt(new ApexPages.StandardController(caseRec2));
            controller.updateFields();          
        Test.stopTest();
        
        checkCase = new Case();
        checkCase = [SELECT RecordType.Name, Owner.Name FROM Case WHERE Id = : caseRec2.Id];
        idCheck = '';
        idCheck = [SELECT Id, QueueId FROM QueueSobject WHERE Queue.Name = : 'CNR Professional Services'].QueueId;
        System.assertEquals('Professional Services', checkCase.RecordType.Name);
        System.assertEquals(idCheck, checkCase.OwnerId);
    }
    
}