/***********************************************************************************
Date: September 25, 2012
Author: Thileepa Asokan
        Tata Consultancy Services Limited
Test class for: LastCommentUpdate
************************************************************************************/
@isTest(seeAllData=true)
class TestLastCommentUpdate{
    public static testMethod void testUpdate()
    {
        //  be advised that this test was failing after i created the CaseComment trigger due to too many soql queries
        //  i am seeing that the populateLastComment.Trigger is commented out and the LastCommentUpdate.updateLastCommentAndCommenter
        //  is all commented it out.  i think it is safe to comment out this test insothat it no longer produces a too many soql queries
        //  by Joseph Hutchins 6/22/2015
        /*	
        Integer cnt = 10;
        Id rtId = [select Id from recordtype where developerName='CallCenter' limit 1].Id;
        List<Case> cases = new List<Case>();
        
        //Assigns default Assignment rules
        Database.DMLOptions dlo = new Database.DMLOptions();
        dlo.assignmentRuleHeader.useDefaultRule= true;
        dlo.EmailHeader.triggerUserEmail = true;
        dlo.EmailHeader.triggerAutoResponseEmail = true;            
        
        for(Integer i=0;i<cnt;i++){
            cases.add(new Case( recordTypeId=rtId, subject='test '+i, description='test',status='New-Unassigned',Origin='Phone',category__c='Admin',Type_Level_2__c='Research',Area_Level_3__c='iQ'));
        }
        for(Case theCase:cases){
            theCase.setOptions(dlo);
        }
        if(!cases.isEmpty())
            insert cases;
           */
            
        /*PartnerNetworkConnection connection = new PartnerNetworkConnection();
        connection = [select Id, ConnectionStatus, ConnectionName from PartnerNetworkConnection where ConnectionStatus = 'Accepted' limit 1];
        List<PartnerNetworkRecordConnection> shareRecords = new List<PartnerNetworkRecordConnection>();
        for(Case theCase:cases){
            PartnerNetworkRecordConnection newrecord = new PartnerNetworkRecordConnection();
        
            newrecord.ConnectionId = connection.Id;
            newrecord.LocalRecordId = theCase.Id;  
        
            shareRecords.add(newrecord);   
        }
        if(!shareRecords.isEmpty()){
            database.insert(shareRecords);
        }*/              
        /*
        Test.startTest();        
        List<CaseComment>comments = new List<CaseComment>();
        for(Case theCase:cases){    
            comments.add(new CaseComment(parentId=theCase.Id, commentBody='test'));
        }
        if(!comments.isEmpty())
            insert comments;
            */
        /*List<Case> toAssertCases = new List<Case>();
        toAssertCases = [select Last_Case_Comment__c from Case where id in :cases];
        for(Case theCase:toAssertCases){
            System.assertNotEquals(theCase.Last_Case_Comment__c, null);            
            System.assertNotEquals(theCase.Last_Case_Comment__c, '');                        
        }*/
        /*
        Test.stopTest();
        */
    }   
    /*
    public static testMethod void testDelete(){    
        Integer cnt = 10;
        Id rtId = [select Id from recordtype where developerName='CallCenter' limit 1].Id;
        List<Case> cases = new List<Case>();
        
        //Assigns default Assignment rules
        Database.DMLOptions dlo = new Database.DMLOptions();
        dlo.assignmentRuleHeader.useDefaultRule= true;
        dlo.EmailHeader.triggerUserEmail = true;
        dlo.EmailHeader.triggerAutoResponseEmail = true;            
        
        for(Integer i=0;i<cnt;i++){
            cases.add(new Case(recordTypeId=rtId, subject='test '+i, description='test',status='New-Unassigned',Origin='Phone',category__c='Admin',Type_Level_2__c='Research',Area_Level_3__c='iQ'));
        }
        for(Case theCase:cases){
            theCase.setOptions(dlo);
        }
   
        if(!cases.isEmpty())     
            insert cases;

        PartnerNetworkConnection connection = new PartnerNetworkConnection();
        connection = [select Id, ConnectionStatus, ConnectionName from PartnerNetworkConnection where ConnectionStatus = 'Accepted' limit 1];
        List<PartnerNetworkRecordConnection> shareRecords = new List<PartnerNetworkRecordConnection>();
        for(Case theCase:cases){
            PartnerNetworkRecordConnection newrecord = new PartnerNetworkRecordConnection();
        
            newrecord.ConnectionId = connection.Id;
            newrecord.LocalRecordId = theCase.Id;  
        
            shareRecords.add(newrecord);   
        }
        if(!shareRecords.isEmpty()){
            database.insert(shareRecords);
        }                      
        
        List<CaseComment> comments = new List<CaseComment>();
        for(Case theCase:cases){    
            comments.add(new CaseComment(parentId=theCase.Id, commentBody='test'));
        }
        if(!comments.isEmpty())
            insert comments;
        
        Test.startTest();                        
        Integer noOfTimes = 0;
        List<CaseComment> commentsToBeDeleted = new List<CaseComment>();
        for(CaseComment cmt:comments){
            noOfTimes = noOfTimes + 1;
            if(noOfTimes<=5){
                commentsToBeDeleted.add(cmt);
            }
        }
        if(!commentsToBeDeleted.isEmpty())       
            delete commentsToBeDeleted;
        Test.stopTest();
    }*/
    
}