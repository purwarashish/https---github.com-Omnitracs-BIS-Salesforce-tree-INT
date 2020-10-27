@isTest(SeeAllData = true)
private class TestScheduleUpdateRoadnetAssetEndDates {
	
	public static void setupData(){
		
		List <String> ProductNameList = new List<String>{'Database Maintenance - 1st Year','Database Maintenance - Renewal',
			'Subscription Fee - OnTrack Java - Initial','Subscription Fee - OnTrack Java - Renewal','MobileCast Smart Phone - Subscription',
			'MobileCast Smart Phone - Subscription Renewal','MC Subscription - MC JAVA','Subscription Fee - MC Java - Renewal',
			'Subscription Fee - RTI Web Services, Mobile Integrator - Renewal','Telematics Adaptor Subscription','Roadnet Telematics Adaptor Subscription - Renewal',
			'Monthly Subscription - GeoTab Telematics','Subscription Fee - Telematics Adapter - Renewal','Subscription Fee - Co-Pilot Navigation - Initial',
			'Roadnet Telematics Subscription'};
		
		List<Asset__c> assetsToAdd = new List<Asset__c>();
		List<Product2> prodsToAdd = new List<Product2>();
		
		Account a = TestUtils.getAccount('ut1 Acc');
        insert a;

        Contract ctrct = TestUtils.getContract(a);
        insert ctrct;
       
        Opportunity oppty = TestUtils.getOpportunity(a, 'UT Oppty1');
        oppty.Contract__c = ctrct.id;
        oppty.Type = 'New Customer';
        oppty.Order_Type__c = 'New';
        oppty.StageName = 'Sales Acceptance';
        oppty.Legal_Review__c = '';
        oppty.Finance_Status__c = '';
        insert oppty;
		
		for(String productName : ProductNameList){
			Product2 p0 = TestUtils.getProduct('ut prod0', productName);
			p0.Is_Assetizable__c = true;
			p0.Is_Bundle__c = true;
			
			prodsToAdd.add(p0);
		}
		
		insert prodsToAdd;
		
		Product2 p1 = TestUtils.getProduct('ut prod1', 'family');
        p1.Is_Assetizable__c = false;
        p1.Is_Bundle__c = false;
        p1.Family = 'Test';
        insert p1;
		
		for(Product2 prod : prodsToAdd){
			Asset__c ast = new Asset__c();
			ast.Account__c = a.Id;
			ast.Product__c = p1.Id;
			ast.ARR__c = 25;
			ast.Contract__c = ctrct.Id;
			ast.Bundle_Product__c = prod.Id;
			ast.Asset_Term_End_Date__c = Date.today();

			
			assetsToAdd.add(ast);
	}
		
		insert assetsToAdd;
	}
	
	public static testMethod void testOne() {
		Test.startTest();
		String CRON_EXP = '0 0 0 3 9 ? 2032';
        String jobId = System.schedule('UpdateRoadnetAssetEndDatesTest',CRON_EXP,new ScheduleUpdateRoadnetAssetEndDates());
            
         // Get the information from the CronTrigger API object
        CronTrigger ct = [SELECT id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
            
         // Verify the expressions are the same
        System.assertEquals(CRON_EXP,ct.CronExpression);
            
         // Verify the job has not run
        System.assertEquals(0, ct.TimesTriggered);
            
         // Verify the next time the job will run
        System.assertEquals('2032-09-03 00:00:00',String.valueOf(ct.NextFireTime));
		Test.stopTest();
	}
	
	public static testMethod void testTwo(){
		Test.startTest();
		
		ScheduleUpdateRoadnetAssetEndDates sched = new ScheduleUpdateRoadnetAssetEndDates();
		sched.doAssetUpdates();
		sched.dateChange(Date.today());
		
		Test.stopTest();
		
	}
}