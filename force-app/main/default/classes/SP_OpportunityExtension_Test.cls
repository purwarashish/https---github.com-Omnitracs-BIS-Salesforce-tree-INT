@isTest(seeAllData = true)
public class SP_OpportunityExtension_Test{
    public static testMethod void testOpportunityAdvanceStageController(){
        List<Account> acctList = TestDataFactory.createAcctList(1, 'SP Opportunity Extension Account Test');
		Account acc = acctList[0];
    	insert acc;
    	List<Contact> conList = TestDataFactory.createConList(1, 'LastName');
		Contact con = conList[0];
		con.AccountId = acc.Id;
        insert con;
        
        Opportunity_Stage__c oppStage1 = new Opportunity_Stage__c();
        oppStage1.Name = '1 - Plan';
        insert oppStage1;
        
        Opportunity_Stage__c oppStage2 = new Opportunity_Stage__c();
        oppStage2.Name = '2 - Develop';
        oppStage2.Next_Stage__c = oppStage1.id;
        insert oppStage2;
        
        Id PRODUCTSANDSERVRTYPE = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Products, Services and Maintenance').getRecordTypeId();
        Opportunity testOpportunity = new Opportunity(Name='asdasd',RecordTypeId=PRODUCTSANDSERVRTYPE,stagename='1 - Plan', closedate=Date.today(), Contact__c=con.Id, AccountId=acc.Id);
        testOpportunity.Opportunity_Stage__c = oppStage1.Id;
        insert testOpportunity;
        
        
        SP_OpportunityExtension testOpportunityExtension = new SP_OpportunityExtension(new ApexPages.StandardController(testOpportunity));
        if(testOpportunityExtension.OppStage == null){}
        if(testOpportunityExtension.nextStage == null){}
        if(testOpportunityExtension.advancementCriteria == null){}
        if(testOpportunityExtension.readyToAdvance){}
        testOpportunityExtension.advanceStage();
    }
}